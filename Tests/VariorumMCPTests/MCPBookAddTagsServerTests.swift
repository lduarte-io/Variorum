import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-365 (RUN VX-548, batch 2a — the run record
// `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2a RECORD; born as the
// VX-336 U9 UNIT RECORD's OWED 4, the sibling VX-361 left out of scope).
//
// THE TRACED MECHANISM: `add_note_to_book` runs the hand-add's ONE choke point
// (`Operations.addNoteToBook` → `addPostToReading`), whose last line applies the
// book's OUTFLOW (`applyAutoTag` — every tag of the set, each through the one
// application road). So a note added to a book with an outflow WEARS the outflow's
// tags when the act lands — while the answer (`MCPWriteTools.perform`'s
// `.addNoteToBook` arm) said only `{note_id, book_id, section_id?}`. A client that
// meant to tag the note learned nothing; VX-361 fixed exactly this for `create_note`
// and one `import_document`, and kept `add_note_to_book` out of its scope.
//
// The build (VX-361's shape, P-VX361-1 — the brief's "applied-then-outflow, each
// once"): the answer gains `tag_ids` + parallel `tags` (paths) — EVERY tag the note
// wears when the act lands: the note's own tags first, in the order they were
// applied, then the outflow's in outflow order, a tag listed once at its first place —
// composed INSIDE the act's transaction (no read after the commit). Always present
// (`[]` when the note wears none), as `create_note` answers them. The refusals and the
// fence are untouched (a guard below).
//
// Wire only (the SDK's own client over a real socket), so every pin compiles — and
// runs RED — on the tree before the fix: the old answer lacks both keys.

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

@Suite("VX-365 — add_note_to_book answers every tag the note wears, the outflow's included", .serialized)
struct MCPBookAddTagsServerTests {
    /// A Home book that tags every note added to it with `outflow`.
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

    /// Her own case: a note she tagged, added by a client to a book whose
    /// outflow tags two more. The answer lists all three — the note's own
    /// first, then the outflow's in outflow order — with their paths, and
    /// nothing else changes in its shape. RED ON OLD: no `tag_ids`, no `tags`.
    @Test func addingANoteToAnOutflowBookAnswersEveryTagItNowWears() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, outflow) = try outflowBook(h, "green tea research", outflow: ["green-tea", "research"])
            let steeping = try h.operations.createTag(name: "steeping")
            let note = try h.operations.createPost(title: "brewing notes")
            _ = try h.operations.newBlock(in: note.id, text: "Water at 80 °C.", registeringUndo: false)
            _ = try h.operations.applyTag(steeping.id, toPost: note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let depth = h.undoStack.depth

            let added = try await call(connection, "add_note_to_book", [
                "note_id": .string(note.id), "book_id": .string(book.id),
            ])
            #expect(added.isError != true, "\(text(added))")
            let answer = try json(added)
            #expect(Set(answer.keys) == ["note_id", "book_id", "tag_ids", "tags"],
                    "the answer's shape: the old two keys plus the tags, nothing else: \(answer.keys.sorted())")
            #expect(answer["note_id"] as? String == note.id && answer["book_id"] as? String == book.id)
            let expected = [steeping.id, outflow[0].id, outflow[1].id]
            #expect(answer["tag_ids"] as? [String] == expected,
                    "the note's own tag first, then the outflow's in outflow order: \(answer)")
            #expect(answer["tags"] as? [String] == ["steeping", "green-tea", "research"],
                    "…and their paths, parallel — the wire's tag word: \(answer)")
            #expect(try await worn(h, note.id) == Set(expected), "the answer says exactly what the note wears")
            #expect(h.undoStack.depth == depth + 1, "still the add's ONE undo entry")
            await h.hangUp(connection)
        }
    }

    /// An outflow tag the note ALREADY wore is listed once, at its own place
    /// (the outflow's road skips a worn tag — `applyAutoTag` — and the answer
    /// says what the note wears, never what the act inserted). RED ON OLD.
    @Test func anOutflowTagTheNoteAlreadyWoreIsListedOnceAtItsOwnPlace() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, outflow) = try outflowBook(h, "reading list", outflow: ["green-tea", "research"])
            let steeping = try h.operations.createTag(name: "steeping")
            let note = try h.operations.createPost(title: "already tagged")
            _ = try h.operations.newBlock(in: note.id, text: "Notes.", registeringUndo: false)
            // Applied in THIS order: steeping, then the outflow's second tag.
            _ = try h.operations.applyTag(steeping.id, toPost: note.id)
            _ = try h.operations.applyTag(outflow[1].id, toPost: note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let added = try await call(connection, "add_note_to_book", [
                "note_id": .string(note.id), "book_id": .string(book.id),
            ])
            #expect(added.isError != true, "\(text(added))")
            let answer = try json(added)
            #expect(answer["tag_ids"] as? [String] == [steeping.id, outflow[1].id, outflow[0].id],
                    "her two in the order she applied them, then the one the outflow added: \(answer)")
            #expect(answer["tags"] as? [String] == ["steeping", "research", "green-tea"], "\(answer)")
            #expect(try await h.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                    arguments: [note.id, outflow[1].id])
            } == 1, "worn once")
            await h.hangUp(connection)
        }
    }

    /// A book with no outflow: the note's own tags (or none — `[]`, always
    /// present, as `create_note` answers), and a chapter filing keeps its
    /// echo. RED ON OLD: no `tag_ids`, no `tags`.
    @Test func aBookWithNoOutflowAnswersTheNotesOwnTagsOrNoneAndKeepsTheChapterEcho() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "plain", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "one")
            let bare = try h.operations.createPost(title: "untagged")
            let tagged = try h.operations.createPost(title: "tagged")
            let dream = try h.operations.createTag(name: "dream")
            _ = try h.operations.applyTag(dream.id, toPost: tagged.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let first = try json(try await call(connection, "add_note_to_book", [
                "note_id": .string(bare.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ]))
            #expect(Set(first.keys) == ["note_id", "book_id", "section_id", "tag_ids", "tags"],
                    "the chapter's echo stays beside the tags: \(first.keys.sorted())")
            #expect(first["section_id"] as? String == chapter.id)
            #expect(first["tag_ids"] as? [String] == [] && first["tags"] as? [String] == [],
                    "a note wearing nothing answers empty lists, never absent keys: \(first)")

            let second = try json(try await call(connection, "add_note_to_book", [
                "note_id": .string(tagged.id), "book_id": .string(book.id),
            ]))
            #expect(second["tag_ids"] as? [String] == [dream.id] && second["tags"] as? [String] == ["dream"],
                    "the note's own tag, no outflow to add: \(second)")
            await h.hangUp(connection)
        }
    }

    // MARK: - GUARD (green on both sides, by design — not a red pin)

    /// The fence and the refusals are byte-unchanged: a note the client can't
    /// reach answers the ONE not-shared sentence, identical for a hidden note
    /// and a missing id — never a tag, never an oracle — and nothing is added.
    @Test func aRefusedAddAnswersTheOneNotSharedShapeWithNoTags() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let (book, _) = try outflowBook(h, "granted", outflow: ["green-tea"])
            let hidden = try h.operations.createPost(title: "not shared")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))

            let refused = try await call(connection, "add_note_to_book", [
                "note_id": .string(hidden.id), "book_id": .string(book.id),
            ])
            let missing = try await call(connection, "add_note_to_book", [
                "note_id": .string("no-such-note"), "book_id": .string(book.id),
            ])
            #expect(refused.isError == true && missing.isError == true)
            #expect(text(refused) == text(missing), "hidden reads exactly as missing")
            #expect(text(refused).hasPrefix("That note isn't shared with this client"), "\(text(refused))")
            #expect(!text(refused).contains("tag"), "a refusal names no tag")
            #expect(try await worn(h, hidden.id).isEmpty, "nothing was added, nothing tagged")
            await h.hangUp(connection)
        }
    }
}
