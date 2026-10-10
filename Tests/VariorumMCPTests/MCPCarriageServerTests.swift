import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U4 — THE CARRIAGE END TO END, over a real socket driven by the SDK's
// own `Client` (U1's harness): the tray read and put_back (client-named undo),
// versions saved / listed / read, lineage and take ancestry (with AF-11 F-4's
// ONE uniform stub beyond the grant), archived reach mirroring the facet,
// lenses read, set_entry_date (the journal fence governing from the moment
// she files the note), the book facts and set_book_rule (AF-11 F-1: her Save,
// mirrored), file_note_in_chapter (PROVISIONAL), and the rungs' listing.

private func spec(
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

private func blocks(_ shaped: [String: Any]) -> [[String: Any]] {
    shaped["blocks"] as? [[String: Any]] ?? []
}

@Suite("13n-b U4 — the carriage end to end", .serialized)
struct MCPCarriageServerTests {
    // MARK: - The tray and put_back

    @Test func theTrayReadsAndPutBackLandsAndUndoesClientNamed() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            _ = try h.operations.newBlock(in: note.id, text: "First.", registeringUndo: false)
            let gone = try h.operations.newBlock(in: note.id, text: "Second, deleted.", registeringUndo: false)
            _ = try h.operations.newBlock(in: note.id, text: "Third.", registeringUndo: false)
            let take = try h.operations.branchVariant(gone.block.id, from: gone.variant.id)
            try h.operations.autosave(take.id, text: "a take that went", charDelta: 4)
            try h.operations.deleteVariant(take.id)
            try h.operations.deleteBlock(gone.block.id)
            let kept = try h.operations.newBlock(in: note.id, text: "Kept.", registeringUndo: false)
            let keptTake = try h.operations.branchVariant(kept.block.id, from: kept.variant.id)
            try h.operations.setTakeLabel(keptTake.id, label: "alt")
            try h.operations.deleteVariant(keptTake.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let plain = text(try await call(connection, "read_note", ["note_id": .string(note.id)]))
            #expect(!plain.contains("Second, deleted."), "never in the Level 0 text")
            let shaped = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "with_tray": .bool(true),
            ]))
            let tray = try #require(shaped["tray"] as? [String: Any])
            let trayBlocks = try #require(tray["blocks"] as? [[String: Any]])
            #expect(trayBlocks.map { $0["block_id"] as? String } == [gone.block.id])
            #expect(trayBlocks.first?["text"] as? String == "Second, deleted.")
            let trayTakes = try #require(tray["takes"] as? [[String: Any]])
            #expect(trayTakes.map { $0["take_id"] as? String } == [keptTake.id],
                    "a take that died WITH its block rides the block's row (the tray's own rule)")
            #expect(trayTakes.first?["label"] as? String == "alt")

            let back = try await call(connection, "put_back", ["block_id": .string(gone.block.id)])
            #expect(back.isError != true, "\(text(back))")
            #expect(try json(back)["landed"] as? String == "its_old_place")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "First.\n\nSecond, deleted.\n\nThird.\n\nKept.")
            #expect(h.undoStack.topLabel == "claude-code's put back")
            let again = try await call(connection, "put_back", ["block_id": .string(gone.block.id)])
            #expect(again.isError == true && text(again) == "Refused: blockNotDeleted(id: \"\(gone.block.id)\")",
                    "already back: the op's own refusal speaks (the app's words are its table's — the Mac pin)")
            #expect(try await call(connection, "put_back", ["take_id": .string(keptTake.id)]).isError != true)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's put back")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's put back")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "First.\n\nThird.\n\nKept.", "⌥⌘Z walks the put back away — in the tray again")
            #expect(h.receipts.value.map(\.act) == [.putBack, .putBack])
            await h.hangUp(connection)
        }
    }

    @Test func putBackRefusesWhatHerTrayDoesNotOfferAndPastItsGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let granted = try h.operations.createPost(title: "granted")
            let other = try h.operations.createPost(title: "other")
            _ = try h.operations.newBlock(in: granted.id, text: "Stays.", registeringUndo: false)
            _ = try h.operations.newBlock(in: other.id, text: "Stays too.", registeringUndo: false)
            let mine = try h.operations.newBlock(in: granted.id, text: "Mine, deleted.", registeringUndo: false)
            let theirs = try h.operations.newBlock(in: other.id, text: "Theirs, deleted.", registeringUndo: false)
            try h.operations.deleteBlock(mine.block.id)
            try h.operations.deleteBlock(theirs.block.id)
            // A block deleted WITH its whole note is the note's, never a tray's.
            let doomed = try h.operations.createPost(title: "doomed")
            let victim = try h.operations.newBlock(in: doomed.id, text: "Victim.", registeringUndo: false)
            try h.operations.deleteContainer(doomed.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, granted.id))

            let past = try await call(connection, "put_back", ["block_id": .string(theirs.block.id)])
            #expect(past.isError == true && text(past).hasPrefix("That note isn't shared with this client"),
                    "a tray item of an unshared note answers the ONE answer")
            let gone = try await call(connection, "put_back", ["block_id": .string(victim.block.id)])
            #expect(gone.isError == true && text(gone).hasPrefix("That note isn't shared with this client"))
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: other.id) } == "Stays too.")
            #expect(h.undoStack.depth == 0)
            _ = mine
            await h.hangUp(connection)
        }
    }

    // MARK: - Versions

    @Test func saveVersionMintsTheMomentAndVersionsListAndReadItOnTheNotesGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "design doc")
            let block = try h.operations.newBlock(in: note.id, text: "Edition one.", registeringUndo: false)
            let stranger = try h.operations.createPost(title: "another doc")
            _ = try h.operations.newBlock(in: stranger.id, text: "Not this one.", registeringUndo: false)
            let strangerVersion = try h.operations.saveNoteVersion(stranger.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .note, note.id))

            let saved = try json(try await call(connection, "save_version", ["note_id": .string(note.id)]))
            let versionID = try #require(saved["version_id"] as? String)
            #expect(h.undoStack.topLabel == "claude-code's version")
            try h.operations.autosave(block.variant.id, text: "Edition two.", charDelta: 3)

            let listed = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "with_versions": .bool(true),
            ]))
            let versions = try #require(listed["versions"] as? [[String: Any]])
            #expect(versions.map { $0["version_id"] as? String } == [versionID])
            #expect(blocks(listed).first?["text"] as? String == "Edition two.")

            let readText = try await call(connection, "read_note", [
                "note_id": .string(note.id), "version_id": .string(versionID),
            ])
            #expect(text(readText).contains("Edition one.") && !text(readText).contains("Edition two."))
            let readJSON = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "version_id": .string(versionID), "with_ids": .bool(true),
            ]))
            #expect(readJSON["version_of"] as? String == note.id && readJSON["version_id"] as? String == versionID)
            #expect(blocks(readJSON).first?["text"] as? String == "Edition one.")

            let foreign = try await call(connection, "read_note", [
                "note_id": .string(note.id), "version_id": .string(strangerVersion.post.id),
            ])
            #expect(foreign.isError == true && text(foreign).hasPrefix("version_id isn't a saved version of this note"),
                    "another note's moment never reads through this note's grant")
            #expect(try await call(connection, "read_note", ["note_id": .string(versionID)]).isError == true,
                    "a version has no facts of its own — only through its note")
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try await h.database.read { try Queries.noteVersions($0, of: note.id) }.isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - Lineage and take ancestry (AF-11 F-4 + its RIDER)

    @Test func lineageAndAncestryAreExactAndBeyondTheGrantIsOneUniformStub() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "shared")
            let a = try h.operations.newBlock(in: note.id, text: "Alpha.", registeringUndo: false)
            let b = try h.operations.newBlock(in: note.id, text: "Beta.", registeringUndo: false)
            let merged = try h.operations.merge(a.block.id, b.block.id)
            let branch = try h.operations.branchVariant(merged.block.id, from: merged.variant.id)
            let readable = try h.operations.createPost(title: "readable")
            let readableBlock = try h.operations.newBlock(in: readable.id, text: "R.", registeringUndo: false)
            let unshared = try h.operations.createPost(title: "unshared")
            let unsharedBlock = try h.operations.newBlock(in: unshared.id, text: "U.", registeringUndo: false)
            let journal = try h.operations.createPost(title: "an entry", profile: .journal)
            let journalBlock = try h.operations.newBlock(in: journal.id, text: "J.", registeringUndo: false)
            let pool = try h.operations.createPool(title: "scraps")
            let scrap = try h.operations.newBlock(in: pool.id, text: "S.", registeringUndo: false)
            // Fixture edges, identical but for the far side.
            try await h.database.write { db in
                for (id, target) in [("e-r", readableBlock.block.id), ("e-u", unsharedBlock.block.id),
                                     ("e-j", journalBlock.block.id), ("e-s", scrap.block.id)] {
                    try db.execute(
                        sql: """
                            INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                            VALUES (?, ?, ?, 'derived_from', 'manual', '2026-07-01T00:30:00.000Z')
                            """,
                        arguments: [id, merged.block.id, target])
                }
                // A take whose parent lives in the unshared note.
                try db.execute(sql: "UPDATE variant SET parent_variant_id = ? WHERE id = ?",
                               arguments: [unsharedBlock.variant.id, merged.variant.id])
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, readable.id))

            let plainIDs = try json(try await call(connection, "read_note", ["note_id": .string(note.id), "with_ids": .bool(true)]))
            #expect(blocks(plainIDs).first?["lineage"] == nil, "never ambient")
            let shaped = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "with_lineage": .bool(true),
            ]))
            let block = try #require(blocks(shaped).first)
            let lineage = try #require(block["lineage"] as? [[String: Any]])
            let released = lineage.filter { $0["released"] as? Bool == true }
            #expect(Set(released.compactMap { $0["block_id"] as? String }) == [a.block.id, b.block.id],
                    "the merge's released sources are this note's own history")
            #expect(Set(released.compactMap { $0["text"] as? String }) == ["Alpha.", "Beta."])
            #expect(released.allSatisfy { $0["relation"] as? String == "derived_from" && $0["origin_op"] as? String == "merge" })
            let toReadable = try #require(lineage.first { $0["block_id"] as? String == readableBlock.block.id })
            #expect(toReadable["note_id"] as? String == readable.id, "a note the client can read is addressable")
            let stubs = lineage.filter { $0["beyond_grant"] as? Bool == true }
            #expect(stubs.count == 3, "unshared, journal-fenced and scrap far sides — each a stub, none omitted")
            let encoded = try stubs.map {
                String(decoding: try JSONSerialization.data(withJSONObject: $0, options: [.sortedKeys]), as: UTF8.self)
            }
            #expect(Set(encoded) == ["{\"beyond_grant\":true,\"relation\":\"derived_from\"}"],
                    "THE RIDER: a fenced far side is byte-identical to an unshared one — no id, title or kind")
            #expect(!text(try await call(connection, "read_note", ["note_id": .string(note.id), "with_lineage": .bool(true)]))
                .contains(journal.id), "the fenced note's id appears nowhere")

            let takes = try #require(block["takes"] as? [[String: Any]])
            let shown = try #require(takes.first { $0["take_id"] as? String == merged.variant.id })
            #expect(shown["parent_beyond_grant"] as? Bool == true && shown["parent_take_id"] == nil)
            let branched = try #require(takes.first { $0["take_id"] as? String == branch.id })
            #expect(branched["parent_take_id"] as? String == merged.variant.id, "take ancestry, exact")
            await h.hangUp(connection)
        }
    }

    /// Ladder round 1, F-3 (RED-ON-OLD): a version read's lineage addresses
    /// the LIVE NOTE the grant covers — on the old code the version branch
    /// passed no standing, so the very note whose grant authorized the call
    /// wore the beyond-grant stub (false words, and the moment's most
    /// interesting far side unreadable).
    @Test func aVersionReadsLineageAddressesTheLiveNoteItIsAMomentOf() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "doc")
            let block = try h.operations.newBlock(in: note.id, text: "Edition one.", registeringUndo: false)
            let version = try h.operations.saveNoteVersion(note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id))

            let shaped = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "version_id": .string(version.post.id), "with_lineage": .bool(true),
            ]))
            let lineage = try #require(blocks(shaped).first?["lineage"] as? [[String: Any]])
            let toLive = try #require(lineage.first { $0["relation"] as? String == "version_of" })
            #expect(toLive["note_id"] as? String == note.id && toLive["block_id"] as? String == block.block.id,
                    "the live note is addressable from its own moment")
            #expect(toLive["beyond_grant"] == nil, "never the stub for the note whose grant authorized the call")
            #expect(shaped["books"] == nil, "a moment is membered nowhere — the books key stays the live read's")
            await h.hangUp(connection)
        }
    }

    // MARK: - Archived reach (the facet's posture) and lenses

    @Test func archivedReachMirrorsTheFacetAndLensesRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "shelf", kind: .book)
            let note = try h.operations.createPost(title: "living")
            let kept = try h.operations.createPost(title: "kept away")
            for post in [note, kept] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            let block = try h.operations.newBlock(in: note.id, text: "Zebra living words.", registeringUndo: false)
            let archivedTake = try h.operations.branchVariant(block.block.id, from: block.variant.id)
            try h.operations.autosave(archivedTake.id, text: "an archived take", charDelta: 3)
            try h.operations.archiveVariant(archivedTake.id)
            let alt = try h.operations.branchVariant(block.block.id, from: block.variant.id)
            _ = try h.operations.newBlock(in: kept.id, text: "Zebra archived words.", registeringUndo: false)
            try h.operations.archiveContainer(kept.id)
            let lens = try h.operations.createLens(post: note.id, name: "alt reading")
            _ = try h.operations.setLensChoice(lens: lens.id, block: block.block.id, variant: alt.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, book.id))

            let resting = try json(try await call(connection, "read_note", ["note_id": .string(note.id), "with_ids": .bool(true)]))
            #expect(!((blocks(resting).first?["takes"] as? [[String: Any]]) ?? []).contains { $0["take_id"] as? String == archivedTake.id })
            let asked = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "include_archived": .bool(true),
            ]))
            let archived = ((blocks(asked).first?["takes"] as? [[String: Any]]) ?? []).first { $0["take_id"] as? String == archivedTake.id }
            #expect(archived?["archived"] as? Bool == true && archived?["chosen"] as? Bool == false)

            let restingSearch = try json(try await call(connection, "search", ["query": .string("zebra")]))
            #expect((restingSearch["passages"] as? [[String: Any]])?.allSatisfy { $0["note_id"] as? String != kept.id } == true)
            let archivedSearch = try json(try await call(connection, "search", [
                "query": .string("zebra"), "include_archived": .bool(true),
            ]))
            let hit = (archivedSearch["passages"] as? [[String: Any]])?.first { $0["note_id"] as? String == kept.id }
            #expect(hit?["archived"] as? Bool == true, "the archived facet's wire form (PROVISIONAL)")
            // Reach untouched: an archived note answers under its grant by id.
            #expect(try await call(connection, "read_note", ["note_id": .string(kept.id)]).isError != true)

            let lensed = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "with_lenses": .bool(true),
            ]))
            let lenses = try #require(lensed["lenses"] as? [[String: Any]])
            #expect(lenses.first?["name"] as? String == "alt reading")
            #expect((lenses.first?["picks"] as? [[String: Any]])?.first?["take_id"] as? String == alt.id)
            await h.hangUp(connection)
        }
    }

    // MARK: - set_entry_date and the journal fence's moment

    @Test func setEntryDateLandsAndTheFenceGovernsFromTheMomentSheFilesTheNoteInAJournal() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "old entry")
            _ = try h.operations.newBlock(in: note.id, text: "Years ago.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let dated = try json(try await call(connection, "set_entry_date", [
                "note_id": .string(note.id), "entry_date": .string("2019-03-04"),
            ]))
            #expect(dated["changed"] as? Bool == true)
            #expect(try await h.database.read { try String.fetchOne($0, sql: "SELECT entry_date FROM container WHERE id = ?",
                                                               arguments: [note.id]) } == "2019-03-04")
            #expect(h.undoStack.topLabel == "claude-code's date")
            let bad = try await call(connection, "set_entry_date", [
                "note_id": .string(note.id), "entry_date": .string("2019-02-30"),
            ])
            #expect(bad.isError == true && text(bad).hasPrefix("entry_date must be a real day"))
            // She files it in a JOURNAL book: from that moment the fence governs.
            let journal = try h.operations.createReading(name: "journal", kind: .book, profile: "journal")
            _ = try h.operations.addPostToReading(note.id, to: journal.id)
            let fenced = try await call(connection, "set_entry_date", [
                "note_id": .string(note.id), "entry_date": .null,
            ])
            #expect(fenced.isError == true && text(fenced).hasPrefix("That's a journal entry"))
            #expect(try await h.database.read { try String.fetchOne($0, sql: "SELECT entry_date FROM container WHERE id = ?",
                                                               arguments: [note.id]) } == "2019-03-04")
            await h.hangUp(connection)
        }
    }

    // MARK: - Book facts and set_book_rule (AF-11 F-1)

    @Test func bookFactsReadAndSetBookRuleMirrorsHerSave() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let percy = try h.operations.createTag(name: "percy")
            let book = try h.operations.createReading(name: "percy lessons", kind: .book)
            let finished = try h.operations.createReading(name: "finished", kind: .book)
            try h.operations.lockReading(finished.id)
            let gathering = try h.operations.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(percy.id)))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let set = try json(try await call(connection, "set_book_rule", [
                "book_id": .string(book.id),
                "rule": .object(["or": .array([.object(["tag": .string("percy")]), .object(["tag": .string("#percy/pt-en")])])]),
                "outflow": .array([.string("lessons")]), "new_matches": .string("wait"),
            ]))
            #expect(set["changed"] as? Bool == true && set["minted_tags"] as? Int == 2)
            let rule = try #require(set["rule"] as? [String: Any])
            #expect(((rule["or"] as? [[String: Any]]) ?? []).compactMap { $0["tag"] as? String } == ["percy", "percy/pt-en"],
                    "the answer speaks PATHS — the store holds ids")
            #expect(set["outflow"] as? [String] == ["lessons"] && set["new_matches"] as? String == "wait")
            #expect(set["intake_paused"] == nil)
            #expect(h.undoStack.topLabel == "claude-code's book rule")

            let listed = try json(try await call(connection, "list_books", [:]))["books"] as? [[String: Any]]
            let row = try #require(listed?.first { $0["id"] as? String == book.id })
            #expect(row["new_matches"] as? String == "wait" && row["collecting"] as? Bool == true)
            #expect(listed?.first { $0["id"] as? String == finished.id }?["finished"] as? Bool == true)

            let onFinished = try json(try await call(connection, "set_book_rule", [
                "book_id": .string(finished.id), "rule": .object(["star": .bool(true)]),
            ]))
            #expect(onFinished["changed"] as? Bool == true, "her Save lands on a finished book — so does this")
            #expect(onFinished["intake_paused"] as? String == MCPBookFacts.intakePausedWords)

            let onGathering = try await call(connection, "set_book_rule", [
                "book_id": .string(gathering.id), "rule": .object(["star": .bool(true)]),
            ])
            #expect(onGathering.isError == true && text(onGathering).hasPrefix("That book isn't shared with this client"),
                    "a gathering is never a grant target (P-13nb-U1-4): the one answer")
            let legacy = try await call(connection, "set_book_rule", [
                "book_id": .string(book.id), "rule": .object(["profile": .string("journal")]),
            ])
            #expect(legacy.isError == true && text(legacy) == MCPBookFacts.legacyTermWords)
            try await h.database.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = '{bad' WHERE id = ?", arguments: [finished.id])
            }
            let unreadable = try await call(connection, "set_book_rule", [
                "book_id": .string(finished.id), "rule": .null,
            ])
            #expect(unreadable.isError == true && text(unreadable) == MCPBookFacts.unreadableRuleWords)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book rule")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book rule")
            #expect(try await h.database.read { try String.fetchOne($0, sql: "SELECT query_spec FROM reading WHERE id = ?",
                                                               arguments: [book.id]) } == nil)
            await h.hangUp(connection)
        }
    }

    /// Ladder round 1, F-1 (RED-ON-OLD): a client's OWN rule write must never
    /// expand its reach. On the old code the rule write's backfill SEATED
    /// every matching note as a MEMBER, a book grant reaches members, and the
    /// previously-unshared note's full text then answered — and the honest
    /// member count doubled as a how-many-notes-wear-this-tag oracle. The
    /// bell override (P-13nb-U4-16): matches wait at Arrivals; only HER seat
    /// expands reach.
    @Test func aRuleWriteNeverExpandsTheClientsOwnReach() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let percy = try h.operations.createTag(name: "percy")
            let hidden = try h.operations.createPost(title: "not shared")
            _ = try h.operations.newBlock(in: hidden.id, text: "Private by silence.", registeringUndo: false)
            _ = try h.operations.applyTag(percy.id, toPost: hidden.id)
            let book = try h.operations.createReading(name: "mine", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            #expect(try await call(connection, "read_note", ["note_id": .string(hidden.id)]).isError == true,
                    "pre-state: the tagged note is beyond the grant")
            let set = try json(try await call(connection, "set_book_rule", [
                "book_id": .string(book.id), "rule": .object(["tag": .string("percy")]),
            ]))
            #expect(set["changed"] as? Bool == true)
            #expect(set["matches_wait"] as? String == MCPBookFacts.matchesWaitWords,
                    "the answer says where the matches went — unconditionally, never per-match")
            let after = try await call(connection, "read_note", ["note_id": .string(hidden.id)])
            #expect(after.isError == true && text(after).hasPrefix("That note isn't shared with this client"),
                    "the rule write BELLED — the grant's reach is unmoved")
            let status = try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ?",
                    arguments: [book.id, hidden.id])
            }
            #expect(status == "arrival", "the match waits at Arrivals for HER judgment")
            let listed = try json(try await call(connection, "list_books", [:]))["books"] as? [[String: Any]]
            #expect(listed?.first { $0["id"] as? String == book.id }?["notes"] as? Int == 0,
                    "the member count stays still — no tag-probe oracle")
            await h.hangUp(connection)
        }
    }

    // MARK: - file_note_in_chapter (PROVISIONAL)

    @Test func filingAMemberIntoAChapterLandsAndAFinishedBookRefusesInTheOpsWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "1 basics")
            let note = try h.operations.createPost(title: "lesson 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let outsider = try h.operations.createPost(title: "outsider")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let filed = try json(try await call(connection, "file_note_in_chapter", [
                "note_id": .string(note.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ]))
            #expect(filed["changed"] as? Bool == true)
            let listed = try json(try await call(connection, "list_notes", ["book_id": .string(book.id)]))["notes"]
                as? [[String: Any]]
            #expect(listed?.first?["section_name"] as? String == "1 basics")
            #expect(h.undoStack.topLabel == "claude-code's chapter filing")
            let stranger = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(outsider.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(stranger.isError == true && text(stranger).hasPrefix("That note isn't shared with this client"),
                    "a note the client cannot reach is never reorganized")
            try h.operations.lockReading(book.id)
            let locked = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(note.id), "book_id": .string(book.id), "section_id": .null,
            ])
            #expect(locked.isError == true && text(locked) == "Refused: lockedReading(id: \"\(book.id)\")",
                    "the op's own refusal (the app's words are the Mac table's — pinned there)")
            await h.hangUp(connection)
        }
    }

    /// Ladder round 1, F-2 (RED-ON-OLD): BOTH of the filing's sides raise the
    /// just-in-time ask — on the old code the note was decided only inside
    /// the guard, whose bare refusal queued nothing and never said the asked
    /// sentence. The arm where it matters most: a FENCED member (a journal or
    /// Private note is reachable per-ask only — without the ask, she never
    /// hears it and the road is a dead end).
    @Test func filingAFencedMemberRaisesTheAskAndSaysSo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "plain book", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "1")
            let entry = try h.operations.createPost(title: "an entry", profile: .journal)
            _ = try h.operations.addPostToReading(entry.id, to: book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let refused = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(entry.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(refused.isError == true && text(refused).hasPrefix("That's a journal entry"))
            #expect(text(refused).hasSuffix(MCPRefusalCopy.askedSentence),
                    "the asked sentence — the ask was raised, not just worded")
            let asks = h.asks.value
            #expect(asks.map(\.scopeID) == [entry.id] && asks.first?.rung == .writeNew,
                    "her sheet hears the one ask: the note, at the act's rung")
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT section_id FROM reading_post WHERE post_id = ?",
                                    arguments: [entry.id])
            } == nil, "nothing was filed")
            await h.hangUp(connection)
        }
    }

    /// Self-review find (red-on-old): `file_note_in_chapter` decides the
    /// book AND the note inside its transaction — with ONE once grant
    /// covering both (a once wing grant), the first decision must not spend
    /// it out from under the second. One write, one spend.
    @Test func aOnceWingGrantFilesANoteOnceAndIsSpentOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "1")
            let note = try h.operations.createPost(title: "lesson 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, "", .once))

            let filed = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(note.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(filed.isError != true, "the one write lands: \(text(filed))")
            #expect(try await h.database.read { try String.fetchOne(
                $0, sql: "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [note.id]) } == chapter.id)
            let again = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(note.id), "book_id": .string(book.id), "section_id": .null,
            ])
            #expect(again.isError == true, "the once grant was spent by its one write")
            await h.hangUp(connection)
        }
    }

    // MARK: - The wire-only refusals speak words, never an enum

    @Test func theWireOnlyRefusalsSpeakWordsNotAnEnum() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let otherBook = try h.operations.createReading(name: "other", kind: .book)
            let foreignChapter = try h.operations.createSection(in: otherBook.id, name: "x")
            let member = try h.operations.createPost(title: "member")
            _ = try h.operations.addPostToReading(member.id, to: book.id)
            let loose = try h.operations.createPost(title: "loose")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let notMember = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(loose.id), "book_id": .string(book.id), "section_id": .null,
            ])
            #expect(notMember.isError == true && text(notMember) == MCPWireRefusalCopy.words(
                OperationError.postNotInReading(postID: loose.id, readingID: book.id)))
            let wrongChapter = try await call(connection, "file_note_in_chapter", [
                "note_id": .string(member.id), "book_id": .string(book.id), "section_id": .string(foreignChapter.id),
            ])
            #expect(wrongChapter.isError == true && text(wrongChapter).hasPrefix("section_id isn't a chapter of this book"))
            let blankPath = try await call(connection, "set_book_rule", [
                "book_id": .string(book.id), "outflow": .array([.string(" / ")]),
            ])
            #expect(blankPath.isError == true && text(blankPath).contains("isn't a tag path"))
            #expect(!text(notMember).contains("Refused:") && !text(wrongChapter).contains("Refused:"))
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - The rungs' listing (P-2 on the wire)

    @Test func theCarriageToolsAreListedAtTheirRungsOnly() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "b", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            let grant = try #require(try h.approve("claude-code", spec(.suggest, .book, book.id)))
            let suggest = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(suggest.isDisjoint(with: ["save_version", "file_note_in_chapter", "set_book_rule", "put_back", "set_entry_date"]))
            try h.operations.revokeMCPGrant(grant)
            let writeNewGrant = try #require(try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .book, book.id)))
            let writeNew = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(writeNew.isSuperset(of: ["save_version", "file_note_in_chapter", "set_book_rule"]))
            #expect(writeNew.isDisjoint(with: ["put_back", "set_entry_date"]))
            try h.operations.revokeMCPGrant(writeNewGrant)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .book, book.id))
            let edit = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(edit.isSuperset(of: ["put_back", "set_entry_date", "save_version", "set_book_rule"]))
            await h.hangUp(connection)
        }
    }
}
