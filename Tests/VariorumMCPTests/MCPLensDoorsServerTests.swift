import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-168 U3 — THE LENS DOORS END TO END, over a real socket driven by the
// SDK's own `Client` (U1's harness; `connect(as:)` presents the name's own
// setup key). VX-171 (R-VX171-2, door-only): the take-CREATION roads accept a
// blank take — `add_take` an empty text, `create_note`'s structured takes a
// take of `""` (minted, never dropped) — while `edit_take` to empty stays
// refused (P-VX171-2). VX-172: `read_note` reads a note THROUGH a lens.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-168 U3 — VX-171's blank-take doors end to end", .serialized)
struct MCPBlankTakeDoorsServerTests {
    /// A note in a book with one block — her take, chosen.
    private struct World {
        let book: Reading
        let note: Container
        let blockID: String
        let hers: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her scaffold line.", registeringUndo: false)
        return World(book: book, note: note, blockID: one.block.id, hers: one.variant.id)
    }

    /// The block's live fan as `(text, label, chosen)` in fan order.
    private func fan(_ h: ServerHarness, _ blockID: String) async throws -> [[String?]] {
        try await h.database.read { db in
            let chosen = try String.fetchOne(
                db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            return try Row.fetchAll(
                db,
                sql: """
                    SELECT id, working_text, label FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id
                    """,
                arguments: [blockID]
            ).map { [$0["working_text"], $0["label"], ($0["id"] as String) == chosen ? "chosen" : nil] }
        }
    }

    // MARK: - add_take

    /// R-VX171-2: a blank take is a legal take — the Mac's own blank-take
    /// gesture (`newBlankVariant`, `''`) made reachable at the suggest door.
    /// RED ON OLD: `add_take` refused an empty text ("text is required.").
    @Test func addTakeAcceptsAnEmptyTextAsABlankTake() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))

            let blank = try await call(connection, "add_take", ["block_id": .string(w.blockID), "text": .string("")])
            #expect(blank.isError != true, "a blank take is a legal take: \(text(blank))")
            let takeID = try #require(try json(blank)["take_id"] as? String)
            #expect(try await fan(h, w.blockID) == [
                ["Her scaffold line.", nil, "chosen"],
                ["", "claude-code \u{00B7} suggested", nil],
            ], "at the fan's end, labeled, never chosen — her text untouched")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
                    == "Her scaffold line.")
            #expect(h.undoStack.topLabel == "claude-code's take", "one client-named undo, as any take")
            #expect(try await h.database.read { db in
                try Variant.fetchOne(db, key: takeID).map { [$0.workingText, $0.status.rawValue] }
            } == ["", "active"])

            // The key must still be said: no text at all is no take.
            let absent = try await call(connection, "add_take", ["block_id": .string(w.blockID)])
            #expect(absent.isError == true && text(absent) == "text is required.", "\(text(absent))")

            // PROVISIONAL P-VX168-U3-1: the creation doors take ANY text —
            // whitespace alone too (create_note's takes always did).
            let spaces = try await call(connection, "add_take", ["block_id": .string(w.blockID), "text": .string("  ")])
            #expect(spaces.isError != true, "\(text(spaces))")
            #expect(try await fan(h, w.blockID).map { $0[0] } == ["Her scaffold line.", "", "  "])
            await h.hangUp(connection)
        }
    }

    // MARK: - create_note's takes

    /// R-VX171-2: `create_note`'s structured takes MINT a blank take — before
    /// this unit an empty take was silently DROPPED (P-13nb-U3-9's "empty-text
    /// takes drop", superseded at this door). RED ON OLD: the fan held two.
    @Test func createNoteMintsABlankTakeInsteadOfDroppingIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))

            let created = try await call(connection, "create_note", [
                "book_id": .string(w.book.id), "title": .string("the review"),
                "blocks": .array([
                    .object([
                        "text": .string("Kept as written."),
                        "takes": .array([
                            .object(["text": .string("")]),
                            .object(["text": .string("A second reading."), "label": .string("alt")]),
                        ]),
                    ]),
                ]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let blockID = try #require((try json(created)["block_ids"] as? [String])?.first)
            #expect(try await fan(h, blockID) == [
                ["Kept as written.", nil, "chosen"],
                ["", nil, nil],
                ["A second reading.", "alt", nil],
            ], "the blank take joins the fan in document order, unchosen — never dropped")
            #expect(try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT v.working_text FROM block b JOIN variant v ON v.id = b.default_variant_id WHERE b.id = ?",
                    arguments: [blockID])
            } == "Kept as written.", "the in-place text stays the block's default")
            await h.hangUp(connection)
        }
    }

    /// The FILE format's door is untouched (R-VX171-2 names add_take and
    /// create_note's takes only; "one format, one meaning" — R-13nb-11 G-2):
    /// the Level 0 format cannot carry a blank take, and import_document
    /// mints exactly what the format says.
    @Test func importDocumentStillMintsOnlyWhatTheFormatCarries() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let document = try await h.database.read { db -> String in
                try Queries.variorumDocumentText(db, postID: w.note.id)
            }
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(w.book.id),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let blockID = try #require((try json(imported)["block_ids"] as? [String])?.first)
            #expect(try await fan(h, blockID) == [["Her scaffold line.", nil, "chosen"]])
            await h.hangUp(connection)
        }
    }

    // MARK: - edit_take to empty stays refused

    /// P-VX171-2 (QUESTIONS #211): clearing a take's text is a different act
    /// from blanking in a lens — `edit_take` to empty refuses, the relaxation
    /// lives at the creation doors only. Nothing is written: no text, no
    /// bracket commit, no undo entry, no receipt.
    @Test func editTakeToEmptyStillRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            // RED ON OLD (the probe, before the refusal existed): the clear
            // LANDED — her text emptied, both bracket commits written, an
            // undo entry and a receipt. P-VX171-2's "stays refused" had no
            // standing refusal under it.
            for blank in ["", "  ", "\n\n"] {
                let cleared = try await call(connection, "edit_take", [
                    "take_id": .string(w.hers), "text": .string(blank), "expected_text": .string("Her scaffold line."),
                ])
                #expect(cleared.isError == true && text(cleared) == MCPWriteTools.editTakeBlankRefusal,
                        "clearing a take is not the edit door's act: \(text(cleared))")
            }
            #expect(MCPWriteTools.editTakeBlankRefusal
                    == "edit_take never empties a take. For a blank take, use add_take with an empty text.")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
                    == "Her scaffold line.")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point")
            } == 0, "no bracket commits for a refused edit")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)

            // A blank take the client ADDED is no exception: the edit door
            // never empties a take, and fills a blank one like any other.
            let added = try json(try await call(connection, "add_take", [
                "block_id": .string(w.blockID), "text": .string(""),
            ]))
            let blankID = try #require(added["take_id"] as? String)
            let filled = try await call(connection, "edit_take", [
                "take_id": .string(blankID), "text": .string("Now with words."), "expected_text": .string(""),
            ])
            #expect(filled.isError != true, "\(text(filled))")
            let emptied = try await call(connection, "edit_take", [
                "take_id": .string(blankID), "text": .string(""), "expected_text": .string("Now with words."),
            ])
            #expect(emptied.isError == true && text(emptied) == MCPWriteTools.editTakeBlankRefusal)
            await h.hangUp(connection)
        }
    }
}

@Suite("VX-168 U3 — VX-172's read_note through a lens end to end", .serialized)
struct MCPLensReadServerTests {
    /// A note in a book, every lens case on one page, and a lens over it:
    /// 1 the lens shows another take · 2 the lens shows the chosen take ·
    /// 3 the lens names nothing · 4 the lens shows a BLANK take (her own
    /// blank-take gesture) · 5 the lens's take was archived since (dangling)
    /// · 6 a two-paragraph block (format v2 in place) the lens shows a
    /// one-paragraph take of · 7 the lens's take was deleted since
    /// (dangling); block 1 wears a callout frame (the export maps it).
    private struct World {
        let book: Reading
        let note: Container
        let blocks: [String]
        let lensID: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let ops = h.operations
        let book = try ops.createReading(name: "drafts", kind: .book)
        let note = try ops.createPost(title: "ch 1")
        _ = try ops.addPostToReading(note.id, to: book.id)
        func block(_ text: String, _ alternate: String?) throws -> (String, String?) {
            let minted = try ops.newBlock(in: note.id, text: text, registeringUndo: false)
            guard let alternate else { return (minted.block.id, nil) }
            let take = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(take.id, text: alternate, charDelta: 1)
            return (minted.block.id, take.id)
        }
        let one = try block("One.", "One, bolder.")
        let two = try block("Two.", "Two, other.")
        let three = try block("Three.", nil)
        let four = try block("Four.", nil)
        let blank = try ops.newBlankVariant(four.0)
        let five = try block("Five.", "Five, archived since.")
        let six = try block("Six.\n\nStill six.", "Six, in one.")
        let seven = try block("Seven.", "Seven, deleted since.")
        try ops.setBlockPresentation(one.0, BlockPresentation(color: "blue", emoji: "\u{2605}"))
        let lens = try ops.createLens(post: note.id, name: "the review")
        let twoChosen = try h.database.read { db in
            try String.fetchOne(db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ?",
                                arguments: [two.0])
        }
        for (blockID, takeID) in [(one.0, one.1), (two.0, twoChosen), (four.0, blank.id), (five.0, five.1),
                                  (six.0, six.1), (seven.0, seven.1)] {
            _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: try #require(takeID))
        }
        try ops.archiveVariant(try #require(five.1))
        try ops.deleteVariant(try #require(seven.1))
        return World(book: book, note: note, blocks: [one.0, two.0, three.0, four.0, five.0, six.0, seven.0],
                     lensID: lens.id)
    }

    /// Her Lenses board's own read of a lens column, from the projection her
    /// board observes (`Queries.takesProjection`): per slot, the lens's
    /// EFFECTIVE pick where it is a take in the block's ACTIVE fan, else the
    /// slot's chosen resolution — `PaneTextAuthority.resolvedText`'s rule
    /// (App/Variorum/Variorum/Surface/PaneTextAuthority.swift:157), its
    /// buffer overlay empty at rest. Answers (text, via) per block.
    private func boardColumn(_ h: ServerHarness, _ noteID: String, _ lensID: String) async throws -> [[String]] {
        try await h.database.read { db in
            let projection = try Queries.takesProjection(db, post: noteID)
            return projection.slots.map { slot in
                let pick = projection.lensSelections[lensID]?[slot.blockID]
                if let pick, let take = projection.fans[slot.blockID]?.first(where: { $0.id == pick }) {
                    return [take.workingText, "lens"]
                }
                return [slot.text ?? "", "chosen"]
            }
        }
    }

    private func blocksOf(_ answer: [String: Any]) -> [[String: Any]] {
        (answer["blocks"] as? [[String: Any]]) ?? []
    }

    // MARK: - The byte-for-byte match with her Lenses board

    @Test func aLensReadMatchesHerLensesBoardByteForByte() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book.id))

            let read = try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "lens_id": .string(w.lensID), "with_ids": .bool(true),
            ])
            #expect(read.isError != true, "\(text(read))")
            let answer = try json(read)
            #expect(answer["lens_id"] as? String == w.lensID, "the view the blocks were read through, said")
            let wire = blocksOf(answer).map { [$0["text"] as? String ?? "<none>", $0["via"] as? String ?? "<none>"] }
            #expect(wire == [
                ["One, bolder.", "lens"],
                ["Two.", "lens"],
                ["Three.", "chosen"],
                ["", "lens"],
                ["Five.", "chosen"],
                ["Six, in one.", "lens"],
                ["Seven.", "chosen"],
            ], "per block the lens's take where it names one, the chosen take elsewhere — a dangling pick falls through")
            #expect(blocksOf(answer).map { $0["block_id"] as? String ?? "" } == w.blocks)

            // Her board's own read of the same lens, byte for byte…
            #expect(wire == (try await boardColumn(h, w.note.id, w.lensID)))
            // …and the core's lens render (`renderPost(…, throughLens:)`).
            let rendered = try await h.database.read { db in
                try Queries.renderPost(db, containerID: w.note.id, throughLens: w.lensID).map { $0.text ?? "" }
            }
            #expect(wire.map { $0[0] } == rendered)

            // A view, never a change: each take's `chosen` stays the NOTE's.
            let chosenTexts = blocksOf(answer).map { block in
                ((block["takes"] as? [[String: Any]]) ?? []).first { $0["chosen"] as? Bool == true }?["text"] as? String
            }
            #expect(chosenTexts == ["One.", "Two.", "Three.", "Four.", "Five.", "Six.\n\nStill six.", "Seven."])
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
                    == "One.\n\nTwo.\n\nThree.\n\nFour.\n\nFive.\n\nSix.\n\nStill six.\n\nSeven.")

            // Without lens_id nothing about the answer changes: no `via`, no echo.
            let plain = try json(try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "with_ids": .bool(true),
            ]))
            #expect(plain["lens_id"] == nil && blocksOf(plain).allSatisfy { $0["via"] == nil })
            #expect(blocksOf(plain).map { $0["text"] as? String ?? "" }
                    == ["One.", "Two.", "Three.", "Four.", "Five.", "Six.\n\nStill six.", "Seven."])
            await h.hangUp(connection)
        }
    }

    // MARK: - The text form: the note as if the lens were the note

    @Test func theLensTextReadIsTheNoteAsItWouldReadWereTheLensMadeTheNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book.id))

            let plainBefore = text(try await call(connection, "read_note", ["note_id": .string(w.note.id)]))
            let throughLens = try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "lens_id": .string(w.lensID),
            ])
            #expect(throughLens.isError != true, "\(text(throughLens))")
            #expect(text(throughLens) == (try await h.database.read {
                try Queries.variorumDocumentText($0, postID: w.note.id, throughLens: w.lensID)
            }))
            #expect(text(throughLens) != plainBefore, "a lens that shows other takes reads differently")
            // The in-place prose the format carries is the lens's, in order
            // (block 1's callout mapped as the export maps it; block 4's
            // blank take skips in place, as a blank chosen take always has —
            // and its section then reads under "Three.", the format's
            // documented v1 corner: VariorumDocument's doc comment, "a
            // blank-chosen fanned block right after a FANLESS paragraph").
            let parsed = try VariorumDocument.parse(text(throughLens))
            #expect(parsed.blocks.map(\.text).filter { !$0.isEmpty }
                    == ["\u{2605} One, bolder.".blockquoted, "Two.", "Three.", "Five.", "Six, in one.", "Seven."])

            // Make the lens the note (her ✓-everything door, the bare op):
            // the note's own read is now EXACTLY what the lens read was.
            try h.operations.adoptLens(w.lensID)
            let plainAfter = text(try await call(connection, "read_note", ["note_id": .string(w.note.id)]))
            #expect(plainAfter == text(throughLens), "read through a lens = the note as if the lens were the note")
            await h.hangUp(connection)
        }
    }

    // MARK: - No oracle: every bad lens id is an id naming nothing

    @Test func aBadLensIDAnswersExactlyAsANoteIDNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let ops = h.operations
            // A dead lens of THIS note.
            let dead = try ops.createLens(post: w.note.id, name: "gone")
            try ops.deleteLens(dead.id)
            // A live lens of ANOTHER note the client CAN read (same book)…
            let sibling = try ops.createPost(title: "ch 2")
            _ = try ops.addPostToReading(sibling.id, to: w.book.id)
            _ = try ops.newBlock(in: sibling.id, text: "Sibling.", registeringUndo: false)
            let siblingLens = try ops.createLens(post: sibling.id, name: "sibling's")
            // …of a note it cannot (unshared), and of a Private note in its book.
            let outside = try ops.createPost(title: "not shared")
            _ = try ops.newBlock(in: outside.id, text: "Elsewhere.", registeringUndo: false)
            let outsideLens = try ops.createLens(post: outside.id, name: "theirs")
            let privateNote = try ops.createPost(title: "private")
            _ = try ops.addPostToReading(privateNote.id, to: w.book.id)
            _ = try ops.newBlock(in: privateNote.id, text: "Hers alone.", registeringUndo: false)
            let privateLens = try ops.createLens(post: privateNote.id, name: "hers")
            try ops.setNotePrivate(privateNote.id, true)
            // …and a lens whose note was deleted (its lens dies on the stamp).
            let deletedNote = try ops.createPost(title: "deleted")
            let deletedLens = try ops.createLens(post: deletedNote.id, name: "orphan")
            try ops.deleteContainer(deletedNote.id)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book.id))
            let nothing = try await call(connection, "read_note", ["note_id": .string("no-such-note")])
            #expect(nothing.isError == true && text(nothing) == MCPRefusalCopy.words(.notShared, .note))

            let bad: [String] = [
                "no-such-lens", dead.id, siblingLens.id, outsideLens.id, privateLens.id, deletedLens.id,
                w.note.id, w.blocks[0], w.book.id, "",
            ]
            for lensID in bad {
                for withIDs in [false, true] {
                    let answer = try await call(connection, "read_note", [
                        "note_id": .string(w.note.id), "lens_id": .string(lensID), "with_ids": .bool(withIDs),
                    ])
                    #expect(answer.isError == nothing.isError && text(answer) == text(nothing),
                            "lens_id \(lensID) (with_ids \(withIDs)) answered: \(text(answer))")
                }
            }
            // The one asked of it (a lens is the live note's; a version has none)
            // is an argument error said the same for any lens id.
            for lensID in [w.lensID, "no-such-lens"] {
                let pair = try await call(connection, "read_note", [
                    "note_id": .string(w.note.id), "lens_id": .string(lensID), "version_id": .string("any"),
                ])
                #expect(pair.isError == true
                        && text(pair) == "Pass version_id or lens_id, not both: a saved version has no lenses.")
            }
            #expect(h.asks.value.isEmpty, "an id naming nothing raises no ask, and neither does a bad lens")
            // The good lens still reads.
            let good = try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "lens_id": .string(w.lensID),
            ])
            #expect(good.isError != true)
            await h.hangUp(connection)
        }
    }

    // MARK: - ONCE: a refused lens spends nothing

    @Test func aRefusedLensNeverSpendsAOnceReadGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, w.note.id, .once))
            let refused = try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "lens_id": .string("no-such-lens"),
            ])
            #expect(refused.isError == true)
            let first = try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "lens_id": .string(w.lensID), "with_ids": .bool(true),
            ])
            #expect(first.isError != true, "the refused lens left the once grant unspent: \(text(first))")
            let second = try await call(connection, "read_note", ["note_id": .string(w.note.id)])
            #expect(second.isError == true, "the lens read was the one read the grant allowed")
            await h.hangUp(connection)
        }
    }

    // MARK: - The blank-take round trip (VX-171 × VX-172)

    /// R-VX171-2's road end to end: a client adds a BLANK take at the door,
    /// saves a lens on it, and the block reads as the empty line — in her
    /// Lenses board's read, and on the wire as `""` with `via: lens`. Her
    /// note itself never changes.
    @Test func aBlankTakeAddedAtTheDoorBlanksTheBlockInALens() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "readme", kind: .book)
            let note = try h.operations.createPost(title: "draft")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let kept = try h.operations.newBlock(in: note.id, text: "Kept.", registeringUndo: false)
            let scaffold = try h.operations.newBlock(in: note.id, text: "(scaffold — cut me)", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, book.id))

            let added = try await call(connection, "add_take", [
                "block_id": .string(scaffold.block.id), "text": .string(""), "label": .string("cut"),
            ])
            #expect(added.isError != true, "\(text(added))")
            let blankID = try #require(try json(added)["take_id"] as? String)
            let saved = try await call(connection, "save_lens", [
                "note_id": .string(note.id), "name": .string("without the scaffold"),
                "take_ids": .array([.string(blankID)]),
            ])
            #expect(saved.isError != true, "\(text(saved))")
            let lensID = try #require(try json(saved)["lens_id"] as? String)

            // Her Lenses board reads the block as the empty line…
            #expect(try await boardColumn(h, note.id, lensID) == [["Kept.", "chosen"], ["", "lens"]])
            #expect(try await h.database.read { db in
                try Queries.renderPost(db, containerID: note.id, throughLens: lensID).map(\.text)
            } == ["Kept.", ""])
            // …the wire reads the same: "" with via: lens…
            let wire = blocksOf(try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "lens_id": .string(lensID), "with_ids": .bool(true),
            ])))
            #expect(wire.map { [$0["block_id"] as? String ?? "", $0["text"] as? String ?? "<none>",
                                $0["via"] as? String ?? "<none>"] }
                    == [[kept.block.id, "Kept.", "chosen"], [scaffold.block.id, "", "lens"]])
            // …and the text form leaves the block's prose out of the page (the
            // format's blank-in-place skip), its own take still listed in its
            // section — exactly the document the format writes for that state.
            let lensText = text(try await call(connection, "read_note", [
                "note_id": .string(note.id), "lens_id": .string(lensID),
            ]))
            #expect(lensText == VariorumDocument.serialize(VariorumDocument.Document(
                title: "draft", tagPaths: [],
                blocks: [.init(text: "Kept."), .init(text: "", alternates: [.init(label: nil, text: "(scaffold — cut me)")])])))

            // Her note is untouched: the scaffold still reads in place.
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "Kept.\n\n(scaffold — cut me)")
            await h.hangUp(connection)
        }
    }
}

private extension String {
    /// The export's callout mapping of a one-line text (`> ` + the line).
    var blockquoted: String { "> " + self }
}
