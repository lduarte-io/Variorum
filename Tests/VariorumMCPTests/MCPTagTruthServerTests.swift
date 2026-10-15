import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-361 · VX-362 (a) · VX-362 (b)'s wire-copy row — the run record
// `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`, the U9 UNIT RECORD (the
// traces probed on `35f9cd70`, D1–D3) and THE ORCHESTRATOR'S RULINGS ON U9's FORKS.
//
// Seen live in U8's real-client organization round: a client filed a note into a
// book whose OUTFLOW tags notes made inside it. The note was tagged in the same act
// (`applyAutoTag` on mint-inside, AppSpec §9), but `create_note` answered
// `tag_ids: []` — the answer listed only a document HEADER's tags, and `create_note`
// has none. The client tagged again and heard the raw Swift case
// `Refused: alreadyTagged(tagID: "…", targetID: "…")`. The trace found a third face:
// `import_document` into such a book with the outflow's tag in its header was
// REFUSED WHOLE by `SQLite error 19: UNIQUE constraint failed: post_tag…` (the header
// insert met the outflow's application).
//
// The ruled shapes: F-1 (a) (P-VX361-1) — `tag_ids` lists EVERY tag the note wears
// when the act lands (the header's in header order, then the outflow's the header
// didn't name, in outflow order), with `tags`, their paths, parallel; D1 — a header
// tag the note already wears is not applied again but IS reported; F-2 (P-VX362-1) —
// `apply_tag` on a tag the note wears answers success with `changed: false`, no undo
// entry and no receipt (her seven doors treat `alreadyTagged` as done), a landed apply
// `changed: true`; `remove_tag` of a tag the note doesn't wear keeps its worded
// refusal (a guard).
//
// Wire only (the SDK's own client over a real socket) plus one table row, so every
// pin compiles — and runs RED — on the tree before the fix.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-361 · VX-362 — the wire tells the truth about a note's tags", .serialized)
struct MCPTagTruthServerTests {
    /// A Home book that collects nothing by itself but tags every note written
    /// in it with `outflow` (her rule editor's outflow chooser).
    private func outflowBook(
        _ h: ServerHarness, _ name: String, outflow paths: [String]
    ) throws -> (book: Reading, tags: [VariorumCore.Tag]) {
        let book = try h.operations.createReading(name: name, kind: .book)
        let tags = try paths.map { try h.operations.createTag(name: $0) }
        try h.operations.setReadingOutflow(book.id, tagIDs: tags.map(\.id))
        return (book, tags)
    }

    /// The note's live tags, as the store holds them.
    private func worn(_ h: ServerHarness, _ noteID: String) async throws -> Set<String> {
        try await h.database.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", arguments: [noteID]))
        }
    }

    private func applications(_ h: ServerHarness, _ noteID: String, _ tagID: String) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                arguments: [noteID, tagID]) ?? -1
        }
    }

    // MARK: - VX-361: the answer lists every tag the note wears

    /// U8's round, exactly: `create_note` into a book with an outflow. Red on the
    /// old tree: `tag_ids` was `[]` and there was no `tags`.
    @Test func createNoteIntoAnOutflowBookAnswersTheTagItWears() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, tags) = try outflowBook(h, "green tea research", outflow: ["green-tea"])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let created = try await call(connection, "create_note", [
                "book_id": .string(book.id), "title": .string("brewing notes"),
                "text": .string("Water at 80 °C."),
            ])
            #expect(created.isError != true, "\(text(created))")
            let answer = try json(created)
            let noteID = try #require(answer["note_id"] as? String)
            #expect(try await worn(h, noteID) == [tags[0].id], "the outflow tagged the note in the same act")
            #expect(answer["tag_ids"] as? [String] == [tags[0].id], "the answer says the tag the note wears: \(answer)")
            #expect(answer["tags"] as? [String] == ["green-tea"], "…and its path, the wire's tag word: \(answer)")
            await h.hangUp(connection)
        }
    }

    /// The third face: a header naming the outflow's own tag. Red on the old
    /// tree: the whole import refused with the SQLite text.
    @Test func aDocumentWhoseHeaderNamesTheOutflowTagLandsAndListsItOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, tags) = try outflowBook(h, "green tea research", outflow: ["green-tea"])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let depth = h.undoStack.depth

            let imported = try await call(connection, "import_document", [
                "book_id": .string(book.id),
                "document": .string("{t:\"second\"} {#green-tea}\n\nSteep 2 minutes."),
            ])
            #expect(imported.isError != true, "the import lands whole: \(text(imported))")
            #expect(!text(imported).contains("SQLite") && !text(imported).contains("UNIQUE"), "\(text(imported))")
            let answer = try json(imported)
            let noteID = try #require(answer["note_id"] as? String)
            #expect(try await applications(h, noteID, tags[0].id) == 1, "worn once")
            #expect(answer["tag_ids"] as? [String] == [tags[0].id], "listed once: \(answer)")
            #expect(answer["tags"] as? [String] == ["green-tea"], "\(answer)")
            #expect(h.undoStack.depth == depth + 1, "the import's one entry")
            #expect(try await h.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [book.id, noteID])
            } == 1, "a member of the book")
            await h.hangUp(connection)
        }
    }

    /// The ruled order: the header's tags in header order (one the outflow also
    /// applied listed once, at its header place), then the outflow's the header
    /// didn't name, in outflow order. Red on the old tree: the first answer
    /// lacked the outflow's tags, the second import refused (the collision).
    @Test func headerTagsComeFirstThenTheOutflowsOthersInOutflowOrder() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, tags) = try outflowBook(h, "green tea research", outflow: ["green-tea", "research"])
            let (greenTea, research) = (tags[0], tags[1])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let first = try await call(connection, "import_document", [
                "book_id": .string(book.id), "document": .string("{t:\"one\"} {#steeping}\n\nOne."),
            ])
            #expect(first.isError != true, "\(text(first))")
            let firstAnswer = try json(first)
            let steeping = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM tag WHERE path = 'steeping' AND deleted_at IS NULL")
            }
            #expect(firstAnswer["tag_ids"] as? [String] == [steeping, greenTea.id, research.id].compactMap { $0 },
                    "\(firstAnswer)")
            #expect(firstAnswer["tags"] as? [String] == ["steeping", "green-tea", "research"], "\(firstAnswer)")

            let second = try await call(connection, "import_document", [
                "book_id": .string(book.id), "document": .string("{t:\"two\"} {#research} {#steeping}\n\nTwo."),
            ])
            #expect(second.isError != true, "\(text(second))")
            let secondAnswer = try json(second)
            #expect(secondAnswer["tag_ids"] as? [String] == [research.id, steeping, greenTea.id].compactMap { $0 },
                    "\(secondAnswer)")
            #expect(secondAnswer["tags"] as? [String] == ["research", "steeping", "green-tea"], "\(secondAnswer)")
            if let noteID = secondAnswer["note_id"] as? String {
                #expect(try await worn(h, noteID).count == 3, "every tag the answer names, the note wears")
            }
            await h.hangUp(connection)
        }
    }

    /// A note with no book: the answer names exactly the header's tags, as it
    /// always did, and now their paths. Red on the old tree by `tags`' absence.
    @Test func aBooklessNoteAnswersItsHeadersTagsAndTheirPaths() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let plain = try json(try await call(connection, "create_note", [
                "wing_id": .string(""), "text": .string("Untagged."),
            ]))
            #expect(plain["tag_ids"] as? [String] == [], "\(plain)")
            #expect(plain["tags"] as? [String] == [], "\(plain)")

            let imported = try json(try await call(connection, "import_document", [
                "wing_id": .string(""), "document": .string("{t:\"field notes\"} {#tea/green}\n\nNotes."),
            ]))
            let green = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM tag WHERE path = 'tea/green' AND deleted_at IS NULL")
            }
            #expect(imported["tag_ids"] as? [String] == [green].compactMap { $0 }, "\(imported)")
            #expect(imported["tags"] as? [String] == ["tea/green"], "\(imported)")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-362 (a): a tag the note already wears is done

    /// Red on the old tree: the first answer had no `changed`; the second was
    /// refused with the raw `alreadyTagged(…)` case.
    @Test func applyingATagTheNoteWearsAnswersUnchangedWithNothingToUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "brewing notes")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let first = try await call(connection, "apply_tag", ["note_id": .string(note.id), "tag": .string("drafts")])
            #expect(first.isError != true, "\(text(first))")
            let firstAnswer = try json(first)
            #expect(firstAnswer["changed"] as? Bool == true, "a landed apply says so: \(firstAnswer)")
            let depth = h.undoStack.depth
            let top = h.undoStack.topLabel
            let receipts = h.receipts.value.count
            #expect(top == "claude-code's tag")

            let again = try await call(connection, "apply_tag", ["note_id": .string(note.id), "tag": .string("drafts")])
            #expect(again.isError != true, "her doors treat a worn tag as done; so does the wire: \(text(again))")
            #expect(!text(again).contains("alreadyTagged") && !text(again).hasPrefix("Refused"), "\(text(again))")
            let answer = try json(again)
            #expect(answer["changed"] as? Bool == false, "\(answer)")
            #expect(answer["tag_id"] as? String == firstAnswer["tag_id"] as? String, "\(answer)")
            #expect(answer["tag"] as? String == "drafts" && answer["note_id"] as? String == note.id, "\(answer)")
            #expect(h.undoStack.depth == depth && h.undoStack.topLabel == top, "nothing written, nothing to undo")
            #expect(h.receipts.value.count == receipts, "a receipt may only claim what landed")
            let tagID = try #require(firstAnswer["tag_id"] as? String)
            #expect(try await applications(h, note.id, tagID) == 1)
            let logged = try await h.database.read { db in
                try String.fetchAll(
                    db, sql: "SELECT outcome FROM mcp_activity WHERE act = 'apply_tag' ORDER BY id")
            }
            #expect(logged == ["allowed", "allowed"], "the act's landed line, as every no-op on the wire logs")
            await h.hangUp(connection)
        }
    }

    /// U8's round's second half: the redundant tag after the outflow. Red on
    /// the old tree: refused with the raw case.
    @Test func theOrganizationRoundsRedundantTagIsUnchanged() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, tags) = try outflowBook(h, "green tea research", outflow: ["green-tea"])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let noteID = try #require(try json(try await call(connection, "create_note", [
                "book_id": .string(book.id), "text": .string("Water at 80 °C."),
            ]))["note_id"] as? String)
            let depth = h.undoStack.depth

            let tagged = try await call(connection, "apply_tag", ["note_id": .string(noteID), "tag": .string("green-tea")])
            #expect(tagged.isError != true, "\(text(tagged))")
            let answer = try json(tagged)
            #expect(answer["changed"] as? Bool == false && answer["tag_id"] as? String == tags[0].id, "\(answer)")
            #expect(h.undoStack.depth == depth)
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both trees): `remove_tag` of a tag the note doesn't wear
    /// keeps its worded refusal — her un-tag never meets that state, and a typo
    /// reads the same.
    @Test func removingATagTheNoteDoesNotWearStillRefusesInWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "brewing notes")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let refused = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("drafts")])
            #expect(refused.isError == true)
            #expect(text(refused) == MCPWriteTools.notWornWords("drafts"), "\(text(refused))")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-362 (b): the one sweep case only the wire can meet

    /// `invalidEntryDate`: the wire parses `entry_date` with its own formatter
    /// and the op with `JournalDay.isValid` — two validators are not one, so
    /// the op's refusal speaks the wire's own parse sentence (the SWEEP
    /// TABLE's E/belt row; its home is the wire copy, D3). Red on the old
    /// tree: no words (nil).
    @Test func anEntryDateTheOpRefusesSpeaksTheWiresParseSentence() {
        #expect(MCPWireRefusalCopy.words(OperationError.invalidEntryDate("2019-02-30"))
                == "entry_date must be a real day written yyyy-MM-dd (e.g. 2019-03-04).")
    }
}
