import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U2 — THE SUGGEST AND WRITE-NEW RUNGS END TO END, over a real socket
// driven by the SDK's own `Client` (U1's harness). The verification bar's
// write half: a suggest grant PROVABLY cannot modify an existing take; writes
// land inside the grant's scope only; every write is one undo entry under the
// client's name; the just-in-time ask never blocks and never becomes an
// existence oracle; once spends by its first write of any rung (AF-7 as amended); the Private mark fences the
// very next call of a connected client.

private func grant(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("13n-b U2 — the MCP server's suggest and write-new rungs end to end", .serialized)
struct MCPWriteServerTests {
    // MARK: - Her fact-check shape (the unit's acceptance, headless)

    @Test func theFactCheckShapeLandsATakeBesideEveryBlockSavesALensAndOneUndoWalksTheLastActBack() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            for text in ["Eu não pedi para herdar o observatório.", "Cuidar de um observatório dá trabalho."] {
                _ = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.suggest, .book, book.id))
            let names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(names == ["list_books", "list_notes", "read_note", "search", "export_note",
                              "add_take", "add_comment", "save_lens"],
                    "a suggest grant lists read + suggest, never a write-new door (P-2)")

            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(note.id), "with_ids": .bool(true)]))
            let blocks = try #require(read["blocks"] as? [[String: Any]])
            #expect(blocks.count == 2)
            var takeIDs: [Value] = []
            for (index, block) in blocks.enumerated() {
                let blockID = try #require(block["block_id"] as? String)
                let landed = try await call(connection, "add_take", [
                    "block_id": .string(blockID), "text": .string("english \(index)"), "label": .string("english"),
                ])
                #expect(landed.isError != true, "\(text(landed))")
                takeIDs.append(.string(try #require(try json(landed)["take_id"] as? String)))
            }
            let lens = try await call(connection, "save_lens", [
                "note_id": .string(note.id), "name": .string("english readings"), "take_ids": .array(takeIDs),
            ])
            #expect(lens.isError != true, "\(text(lens))")
            let lensID = try #require(try json(lens)["lens_id"] as? String)

            // Labeled, never chosen: the shown text is still hers.
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "Eu não pedi para herdar o observatório.\n\nCuidar de um observatório dá trabalho.")
            let labels = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT label FROM variant WHERE label IS NOT NULL ORDER BY label")
            }
            #expect(labels == ["claude-code · suggested · english", "claude-code · suggested · english"],
                    "P-13n-3: the fan always says who")
            #expect(h.undoStack.depth == 3 && h.undoStack.topLabel == "claude-code's lens")
            #expect(h.receipts.value.map(\.act) == [.take, .take, .lens])

            // ONE ⌥⌘Z walks the last act back.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's lens")
            #expect(try await h.database.read { try Lens.fetchOne($0, key: lensID) }?.deletedAt != nil)
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE label IS NOT NULL AND deleted_at IS NULL")
            } == 2, "the takes stand; only the last act came back")
            await h.hangUp(connection)
        }
    }

    // MARK: - THE PROOF (the verification bar's heart)

    /// **A SUGGEST GRANT PROVABLY CANNOT MODIFY AN EXISTING TAKE** (R-13n-4,
    /// test-pinned like any refusal). A client holding suggest on the whole
    /// wing calls EVERY declared tool, aimed at her existing takes and blocks
    /// every way the arguments allow — and every row of every take that
    /// existed before, every placement (its chosen take) and every block (its
    /// default) is byte-identical after. Mutation-checked (the unit record).
    @Test func aSuggestGrantProvablyCannotModifyAnExistingTake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "hers")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let one = try h.operations.newBlock(in: note.id, text: "her first paragraph", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "her second paragraph", registeringUndo: false)
            let branch = try h.operations.branchVariant(one.block.id, from: one.variant.id)
            try h.operations.autosave(branch.id, text: "her other take", charDelta: 3)
            try h.operations.setTakeLabel(branch.id, label: "hers, labeled")
            // U4 (justified edit — the proof's completeness grows with the
            // catalog): her TRAY holds a deleted block and a deleted take, so
            // put_back has something of hers to aim at.
            let gone = try h.operations.newBlock(in: note.id, text: "her deleted paragraph", registeringUndo: false)
            try h.operations.deleteBlock(gone.block.id)
            let deletedTake = try h.operations.branchVariant(two.block.id, from: two.variant.id)
            try h.operations.deleteVariant(deletedTake.id)
            let hersTakes = [one.variant.id, two.variant.id, branch.id, gone.variant.id, deletedTake.id]
            func snapshot() throws -> [String] {
                try h.database.read { db in
                    let takes = try Row.fetchAll(
                        db, sql: "SELECT * FROM variant WHERE id IN (?, ?, ?, ?, ?) ORDER BY id",
                        arguments: StatementArguments(hersTakes)).map(\.description)
                    let placements = try Row.fetchAll(
                        db, sql: "SELECT * FROM container_block ORDER BY id").map(\.description)
                    let blocks = try Row.fetchAll(db, sql: "SELECT * FROM block ORDER BY id").map(\.description)
                    let commits = try Row.fetchAll(db, sql: "SELECT * FROM commit_point ORDER BY id").map(\.description)
                    // U4: her note's date and her book's Collecting columns.
                    let dates = try String.fetchAll(db, sql: "SELECT COALESCE(entry_date, '-') FROM container ORDER BY id")
                    let rules = try Row.fetchAll(
                        db, sql: "SELECT query_spec, auto_tag_ids, intake_seating FROM reading ORDER BY id")
                        .map(\.description)
                    let filings = try Row.fetchAll(db, sql: "SELECT section_id FROM reading_post ORDER BY id")
                        .map(\.description)
                    return takes + placements + blocks + commits + dates + rules + filings
                }
            }
            let chapter = try h.operations.createSection(in: book.id, name: "1")
            let before = try snapshot()

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.suggest, .wing, ""))
            let listed = try await connection.client.listTools().tools
            #expect(listed.allSatisfy { declaration in
                MCPToolCatalog.declaration(named: declaration.name).map { $0.rung <= .suggest } ?? false
            }, "nothing above suggest is even offered")

            let blockIDs = [one.block.id, two.block.id]
            let takeIDs = hersTakes.map(Value.string)
            var calls: [(String, [String: Value])] = []
            for blockID in blockIDs {
                calls.append(("add_take", ["block_id": .string(blockID), "text": .string("ai"), "label": .string("x")]))
                calls.append(("add_comment", ["block_id": .string(blockID), "text": .string("a note")]))
            }
            // The lens picks her NON-chosen take (mutation check 2 of the unit
            // record: picking only chosen takes could not see a lens that
            // moved the chosen pointer — the first draft of this pin did).
            calls.append(("save_lens", ["note_id": .string(note.id), "name": .string("hers"),
                                        "take_ids": .array([.string(branch.id), takeIDs[1]])]))
            // Every write-new door, aimed at what is hers — each must refuse
            // at the rung (they are not even listed).
            calls.append(("create_note", ["text": .string("x"), "book_id": .string(book.id)]))
            calls.append(("import_document", ["document": .string("her first paragraph"), "book_id": .string(book.id)]))
            calls.append(("apply_tag", ["note_id": .string(note.id), "tag": .string("x")]))
            calls.append(("create_book", ["name": .string("x"), "wing_id": .string("")]))
            calls.append(("add_note_to_book", ["note_id": .string(note.id), "book_id": .string(book.id)]))
            // U3 (justified edit — the proof's completeness grows with the
            // catalog): write new's create_section and EVERY edit door,
            // aimed at what is hers, each refusing at the rung.
            calls.append(("create_section", ["book_id": .string(book.id), "name": .string("x")]))
            calls.append(("edit_take", ["take_id": .string(branch.id), "text": .string("x"),
                                        "expected_text": .string("her other take")]))
            calls.append(("divide_block", ["block_id": .string(one.block.id), "second_half_starts_with": .string("first")]))
            calls.append(("merge_blocks", ["first_block_id": .string(one.block.id), "second_block_id": .string(two.block.id)]))
            calls.append(("move_block", ["block_id": .string(two.block.id), "before_block_id": .string(one.block.id)]))
            calls.append(("delete_block", ["block_id": .string(two.block.id)]))
            calls.append(("set_block_name", ["block_id": .string(one.block.id), "name": .string("x")]))
            // U4 (justified edit, the ritual): the carriage's write doors —
            // edit's put_back and set_entry_date, write new's save_version,
            // file_note_in_chapter and set_book_rule — each refusing at the rung.
            calls.append(("put_back", ["block_id": .string(gone.block.id)]))
            calls.append(("put_back", ["take_id": .string(deletedTake.id)]))
            calls.append(("set_entry_date", ["note_id": .string(note.id), "entry_date": .string("2019-03-04")]))
            calls.append(("save_version", ["note_id": .string(note.id)]))
            calls.append(("file_note_in_chapter", ["note_id": .string(note.id), "book_id": .string(book.id),
                                                   "section_id": .string(chapter.id)]))
            calls.append(("set_book_rule", ["book_id": .string(book.id), "rule": .object(["star": .bool(true)])]))
            // And the read rung, for completeness (reads write no take).
            calls.append(("read_note", ["note_id": .string(note.id), "with_ids": .bool(true)]))
            calls.append(("export_note", ["note_id": .string(note.id)]))
            for (name, arguments) in calls {
                let result = try await call(connection, name, arguments)
                if let rung = MCPToolCatalog.declaration(named: name)?.rung, rung >= .writeNew {
                    #expect(result.isError == true, "\(name) refuses under a suggest grant")
                }
            }
            #expect(Set(calls.map(\.0)) == Set(MCPToolCatalog.all.map(\.name)).subtracting(["list_books", "list_notes", "search"]),
                    "every door that names a note, a block or a take was tried")
            #expect(try snapshot() == before,
                    "every take that existed, every chosen pointer and every default is byte-identical")
            await h.hangUp(connection)
        }
    }

    // MARK: - read_note with ids passes the same fence (AF-5)

    @Test func readNoteWithIDsPassesTheSameDecisionAndOnceStampAsTheTextForm() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "shared", kind: .book)
            let prose = try h.operations.createPost(title: "prose")
            let entry = try h.operations.createPost(title: "an entry", profile: .journal)
            let once = try h.operations.createPost(title: "once")
            for post in [prose, entry] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            let named = try h.operations.newBlock(in: prose.id, text: "words", registeringUndo: false)
            try h.operations.setBlockName(named.block.id, name: "the opening")
            _ = try h.operations.newBlock(in: prose.id, text: "more", registeringUndo: false)
            _ = try h.operations.newBlock(in: once.id, text: "once words", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.read, .book, book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, grant(.read, .note, once.id, .once))

            let shaped = try json(try await call(connection, "read_note", ["note_id": .string(prose.id), "with_ids": .bool(true)]))
            let blocks = try #require(shaped["blocks"] as? [[String: Any]])
            #expect(blocks.first?["text"] as? String == "words")
            #expect(blocks.first?["name"] as? String == "the opening", "R-13nb-8: a block's name rides where set")
            #expect(blocks.last?["name"] == nil, "and is absent where unset")
            #expect((blocks.first?["takes"] as? [[String: Any]])?.first?["chosen"] as? Bool == true)

            let textForm = try await call(connection, "read_note", ["note_id": .string(entry.id)])
            let idForm = try await call(connection, "read_note", ["note_id": .string(entry.id), "with_ids": .bool(true)])
            #expect(idForm.isError == true && text(idForm) == text(textForm), "the same fence, the same words")
            #expect(!text(idForm).contains("block_id"))

            #expect(try await call(connection, "read_note", ["note_id": .string(once.id), "with_ids": .bool(true)]).isError != true)
            #expect(try await call(connection, "read_note", ["note_id": .string(once.id)]).isError == true,
                    "the JSON form spent the once grant exactly as the text form does")
            await h.hangUp(connection)
        }
    }

    // MARK: - AF-7 end to end

    @Test func aOnceSuggestGrantLetsTheReadsRideFreeAndIsSpentByItsFirstWrite() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "graded")
            let block = try h.operations.newBlock(in: note.id, text: "my answer", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.suggest, .note, note.id, .once))
            for _ in 0..<2 {
                #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError != true,
                        "the reading a suggestion needs rides free")
            }
            let first = try await call(connection, "add_take", ["block_id": .string(block.block.id), "text": .string("B+")])
            #expect(first.isError != true, "\(text(first))")
            let second = try await call(connection, "add_take", ["block_id": .string(block.block.id), "text": .string("A")])
            #expect(second.isError == true, "the first write spent it; the second refuses")
            #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError == true)
            await h.hangUp(connection)
        }
    }

    @Test func aOnceWriteNewGrantIsSpentByItsFirstWriteOfAnyRung() async throws {
        // AF-7 AS AMENDED (the U2 ladder's F4): one write means one write,
        // whatever its rung — a suggest-rung write under a once write-new
        // grant IS the one write; it does not "ride free" below the rung.
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let note = try h.operations.createPost(title: "lesson 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let block = try h.operations.newBlock(in: note.id, text: "Q1?", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.writeNew, .book, book.id, .once))
            #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError != true,
                    "the content read still rides free")
            let take = try await call(connection, "add_take", ["block_id": .string(block.block.id), "text": .string("A")])
            #expect(take.isError != true, "\(text(take))")
            let second = try await call(connection, "create_note", ["text": .string("x"), "book_id": .string(book.id)])
            #expect(second.isError == true, "the suggest write spent the once write-new grant")
            await h.hangUp(connection)
        }
    }

    // MARK: - The Private mark, live (R-13nb-4 — the brief's pin)

    @Test func markingPrivateFencesTheVeryNextCallOfAConnectedClient() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "shared", kind: .book)
            let note = try h.operations.createPost(title: "ch 7")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let block = try h.operations.newBlock(in: note.id, text: "words", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.suggest, .book, book.id))
            #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError != true)

            try h.operations.setNotePrivate(note.id, true)
            let refused = try await call(connection, "read_note", ["note_id": .string(note.id)])
            #expect(refused.isError == true && text(refused).contains("marked Private"))
            #expect(!text(refused).contains("words"))
            #expect(try await call(connection, "add_take", ["block_id": .string(block.block.id), "text": .string("x")]).isError == true)

            try h.operations.setNotePrivate(note.id, false)
            try h.operations.setBookPrivate(book.id, true)
            #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError == true,
                    "a private BOOK fences its members on the next call too")
            let listed = try json(try await call(connection, "list_books", [:]))
            #expect((listed["books"] as? [Any])?.isEmpty == true, "and is never listed")
            await h.hangUp(connection)
        }
    }

    // MARK: - Write new: inside the grant's scope only

    @Test func writeNewCreatesInsideItsScopeOnlyAndNeverPullsAnUnreachableNoteIn() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let inside = try h.operations.createPost(title: "lesson 1")
            let outside = try h.operations.createPost(title: "her diary of drafts")
            _ = try h.operations.addPostToReading(inside.id, to: book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.writeNew, .book, book.id))
            let names = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(names.isSuperset(of: ["create_note", "import_document", "apply_tag", "add_note_to_book"]))
            #expect(!names.contains("create_book"), "a book grant can't make a book — no wing to land it in")

            let created = try await call(connection, "create_note", [
                "title": .string("lesson 2"), "text": .string("Q1?\n\nQ2?"), "book_id": .string(book.id),
            ])
            #expect(created.isError != true, "\(text(created))")
            let newNote = try #require(try json(created)["note_id"] as? String)
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                                 arguments: [book.id, newNote])
            } == 1, "created INSIDE the granted book")

            let wingRefused = try await call(connection, "create_note", ["text": .string("x"), "wing_id": .string("")])
            #expect(wingRefused.isError == true)
            #expect(text(wingRefused).hasPrefix("That wing isn't shared with this client"))
            let bookRefused = try await call(connection, "create_book", ["name": .string("x"), "wing_id": .string("")])
            #expect(bookRefused.isError == true)

            let pulled = try await call(connection, "add_note_to_book", [
                "note_id": .string(outside.id), "book_id": .string(book.id),
            ])
            #expect(pulled.isError == true, "an unreachable note is never pulled into the granted book")
            #expect(text(pulled).hasPrefix("That note isn't shared with this client"))
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                 arguments: [outside.id])
            } == 0)

            let tagged = try await call(connection, "apply_tag", ["note_id": .string(inside.id), "tag": .string("grammar/verbs")])
            #expect(tagged.isError != true, "\(text(tagged))")
            #expect(try json(tagged)["tag"] as? String == "grammar/verbs")
            #expect(h.undoStack.topLabel == "claude-code's tag")
            await h.hangUp(connection)
        }
    }

    @Test func aWholeBookImportLandsInAGrantedWingAndUndoesInOnePress() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.writeNew, .wing, ""))
            let malformed = try await call(connection, "import_document", [
                "document": .string("--- end alternates ---"), "wing_id": .string(""),
            ])
            #expect(malformed.isError == true && text(malformed).contains("line 1"),
                    "fail-honest: the parser's line rides the refusal")
            let imported = try await call(connection, "import_document", [
                "wing_id": .string(""),
                "book": .object([
                    "name": .string("worksheets"),
                    "chapters": .array([.object(["name": .string("week 1"), "documents": .array([
                        .string("{t:\"lesson 1\"}\n\nQ1?"), .string("{t:\"lesson 2\"}\n\nQ2?"),
                    ])])]),
                    "documents": .array([.string("{t:\"answers\"}\n\nA.")]),
                ]),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            let bookID = try #require(answer["book_id"] as? String)
            #expect((answer["note_ids"] as? [String])?.count == 3)
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's book import")
            #expect(h.receipts.value.last?.count == 3)
            #expect(try h.undoStack.undo(with: h.writeOperations) != nil)
            #expect(try await h.database.read { try Reading.fetchOne($0, key: bookID) }?.deletedAt != nil,
                    "an imported book comes back out in a single press")
            await h.hangUp(connection)
        }
    }

    // MARK: - The just-in-time ask (AF-6)

    @Test func asksRaiseOnlyForTargetsTheClientKnowsAndNotSharedStaysOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "shared", kind: .book)
            let privateBook = try h.operations.createReading(name: "mine", kind: .book)
            try h.operations.setBookPrivate(privateBook.id, true)
            let inside = try h.operations.createPost(title: "inside")
            let entry = try h.operations.createPost(title: "morning pages", profile: .journal)
            let unshared = try h.operations.createPost(title: "unshared")
            for post in [inside, entry] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            let block = try h.operations.newBlock(in: inside.id, text: "text", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.read, .book, book.id))
            let missingWords = text(try await call(connection, "read_note", ["note_id": .string("nope")]))
            #expect(h.asks.value.isEmpty, "a missing target raises nothing")

            let tooLow = try await call(connection, "add_take", ["block_id": .string(block.block.id), "text": .string("x")])
            #expect(text(tooLow) == "This client may only read here. " + MCPRefusalCopy.askedSentence)
            #expect(h.asks.value.last == MCPAsk(clientName: "claude-code", scopeKind: .note, scopeID: inside.id,
                                                title: "inside", rung: .suggest, fence: nil))

            let fenced = try await call(connection, "read_note", ["note_id": .string(entry.id)])
            #expect(text(fenced).hasSuffix(MCPRefusalCopy.askedSentence))
            #expect(h.asks.value.last?.fence == .journal && h.asks.value.last?.offersAlways == false)

            let unsharedWords = text(try await call(connection, "read_note", ["note_id": .string(unshared.id)]))
            #expect(unsharedWords == missingWords, "notShared stays ONE answer even when an ask was raised")
            #expect(h.asks.value.last?.scopeID == unshared.id, "her sheet still hears it (PROVISIONAL)")

            let countBefore = h.asks.value.count
            let privateRefusal = try await call(connection, "create_note", ["text": .string("x"), "book_id": .string(privateBook.id)])
            #expect(text(privateRefusal) == "That book is marked Private \u{2014} never shared with AI.")
            #expect(h.asks.value.count == countBefore, "a fenced BOOK never raises an ask — no grant could answer it")
            await h.hangUp(connection)
        }
    }

    @Test func theOperationsRefusalsSpeakToTheClientInTheAppsWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let owned = try h.operations.createReading(name: "owned", kind: .book)
            let plain = try h.operations.createReading(name: "plain", kind: .book)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            let note = try h.operations.createPost(title: "shared note")
            _ = try h.operations.addPostToReading(note.id, to: plain.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.writeNew, .wing, ""))
            let refused = try await call(connection, "add_note_to_book", [
                "note_id": .string(note.id), "book_id": .string(owned.id),
            ])
            #expect(refused.isError == true)
            #expect(text(refused).hasPrefix("Refused: noteMemberedElsewhere"),
                    "the ownership consult's own refusal, through the app's words hook")
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "add_note_to_book" && activity.first?.allowed == false)
            await h.hangUp(connection)
        }
    }
}
