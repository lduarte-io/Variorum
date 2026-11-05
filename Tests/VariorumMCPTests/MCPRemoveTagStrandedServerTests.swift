import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-764 (the VX-771 run, batch 3 — her ruling R-771-A, scope (a) only: the
// per-book "leave when the tag leaves" dial is DECLINED; the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 3 RECORD). The
// agent's report: a tag-rule book used as a BOARD keeps a note whose tag was
// removed — un-tagging is a non-event by design (§19), but `remove_tag`'s answer
// said nothing, so the agent believed the card had left the board. THE BUILD: a
// landed `remove_tag` answers the LIVING books whose rule collects by the removed
// tag (a positive reference at-or-above it, the subtree rule) and that still hold
// the note as a member — `still_in_books` names each one this client can READ
// (`{book_id, name}`), `still_in_books_hidden_count` counts every other one (a
// fenced book among them; absent when 0) — the `duplicate_note` `landed` /
// `move_note_to_wing` `left_books` discipline. NOTHING lands on a book.
//
// VX-825 (the VX-809 run, batch 1 — her R-825, JUSTIFIED EDITS, the ritual):
// the count RETIRED — a book this client can't read is neither named nor
// counted — and every landed answer carries `still_in_books` (`[]` when no
// readable book holds the note) beside the fixed scope words `beyond_reach`;
// the "strands nothing answers byte-unchanged" guard became "answers the same
// two keys" (a bare answer only when nothing hidden held the note would itself
// tell). `MCPReachPureAnswersServerTests` holds the two-store pins.
//
// Wire only (the SDK's own client over a real socket). RED ON OLD: the answer
// carried neither key (the stranded shapes), and the description said nothing of
// the books; the strands-nothing golden and the non-event are GUARDS, green on
// both sides.

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

@Suite("VX-764 — remove_tag names the books that still hold the note", .serialized)
struct MCPRemoveTagStrandedServerTests {
    /// Every membership row the store holds, whole (status, section, tombstone)
    /// — the proof that nothing landed on a book.
    private func memberships(_ h: ServerHarness) async throws -> [String] {
        try await h.database.read { db in
            try Row.fetchAll(db, sql: """
                SELECT id, reading_id, post_id, status, section_id, position, deleted_at FROM reading_post ORDER BY id
                """).map(\.description)
        }
    }

    private func rule(_ term: RuleTerm) throws -> String? { try RuleGrammar.encode(term) }

    // MARK: - The board shape: the readable book is named (RED ON OLD: no key)

    /// The board: a living book whose rule is `#board` took the note in when
    /// it was tagged; removing the tag leaves it there — and the answer says
    /// so, naming the book. A subtree tag (`board/doing` under a rule naming
    /// `board`) is the same shape. Nothing moves: every membership row is
    /// byte-identical, before and after, and after the undo.
    @Test func theStrandedBoardShapeNamesTheReadableBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let board = try h.operations.createTag(name: "board")
            let doing = try h.operations.createTag(parent: board.id, name: "doing")
            let living = try h.operations.createReading(name: "Board", kind: .book, querySpec: try rule(.tag(board.id)))
            let note = try h.operations.createPost(title: "card 1")
            _ = try h.operations.newBlock(in: note.id, text: "Ship it.", registeringUndo: false)
            _ = try h.operations.applyTag(board.id, toPost: note.id)   // the applying act: intake seats it
            let other = try h.operations.createPost(title: "card 2")
            _ = try h.operations.applyTag(doing.id, toPost: other.id)  // a subtree tag seats it too
            let before = try await memberships(h)
            #expect(before.filter { $0.contains(living.id) && $0.contains("member") }.count == 2,
                    "the board holds both cards: \(before)")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let removed = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("board")])
            #expect(removed.isError != true, "\(text(removed))")
            let answer = try json(removed)
            #expect(answer["note_id"] as? String == note.id && answer["tag"] as? String == "board"
                    && answer["removed"] as? Bool == true, "the old keys stand: \(answer)")
            let named = answer["still_in_books"] as? [[String: Any]]
            #expect(named?.count == 1 && named?.first?["book_id"] as? String == living.id
                    && named?.first?["name"] as? String == "Board", "the board is named: \(answer)")
            #expect(named?.first?.count == 2, "a book is its id and its name")
            #expect(answer["still_in_books_hidden_count"] == nil, "no count, ever (VX-825): \(answer)")
            #expect(answer["beyond_reach"] as? String == MCPWriteTools.beyondReachWords)

            let subtree = try json(try await call(connection, "remove_tag", [
                "note_id": .string(other.id), "tag": .string("board/doing"),
            ]))
            #expect((subtree["still_in_books"] as? [[String: Any]])?.map { $0["book_id"] as? String } == [living.id],
                    "a rule naming the parent collects the subtree: \(subtree)")

            #expect(try await memberships(h) == before, "removing a tag never evicts and bells nothing")
            _ = try h.undoStack.undo(with: h.writeOperations)
            _ = try h.undoStack.undo(with: h.writeOperations)
            #expect(try await memberships(h) == before, "and its undo is no applying act")
            await h.hangUp(connection)
        }
    }

    // MARK: - Unreadable and fenced books are neither named nor counted (VX-825)

    /// The note is reached by its own per-ask EDIT grant only (it is a member
    /// of a Private book, so it is fenced); the wing grant reads the plain
    /// board. The plain board is named; the Private book — fenced, matching
    /// no grant — is NOT said at all (VX-825 — it used to be counted), nor is a
    /// board of the same wing read by no grant once the wing grant is gone.
    @Test func anUnreadableOrFencedBookIsNeitherNamedNorCounted() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let board = try h.operations.createTag(name: "board")
            let open = try h.operations.createReading(name: "Board", kind: .book, querySpec: try rule(.tag(board.id)))
            let hidden = try h.operations.createReading(
                name: "Secret board", kind: .book, querySpec: try rule(.or([.tag(board.id), .star])))
            let note = try h.operations.createPost(title: "card")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            _ = try h.operations.applyTag(board.id, toPost: note.id)   // both boards seat it
            _ = try h.operations.setBookPrivate(hidden.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .note, note.id, .connection))
            let before = try await memberships(h)

            let removed = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("board")])
            #expect(removed.isError != true, "\(text(removed))")
            let answer = try json(removed)
            #expect((answer["still_in_books"] as? [[String: Any]])?.map { $0["book_id"] as? String } == [open.id],
                    "the readable board is named: \(answer)")
            #expect(answer["still_in_books_hidden_count"] == nil, "the Private board is not counted: \(answer)")
            #expect(!text(removed).contains(hidden.id) && !text(removed).contains("Secret"),
                    "a fenced book is never named nor its id said")
            #expect(try await memberships(h) == before)

            // A note grant alone reads no book: neither board is said — the
            // named list is there, empty, beside the scope words.
            _ = try h.undoStack.undo(with: h.writeOperations)
            let wing = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM mcp_grant WHERE scope_kind = 'wing' AND revoked_at IS NULL")
            })
            try h.operations.revokeMCPGrant(wing)
            let alone = try json(try await call(connection, "remove_tag", [
                "note_id": .string(note.id), "tag": .string("board"),
            ]))
            #expect((alone["still_in_books"] as? [[String: Any]])?.isEmpty == true, "\(alone)")
            #expect(alone["still_in_books_hidden_count"] == nil, "no board counted: \(alone)")
            #expect(alone["beyond_reach"] as? String == MCPWriteTools.beyondReachWords)
            #expect(try await memberships(h) == before)
            await h.hangUp(connection)
        }
    }

    // MARK: - What strands nothing answers the two keys, and nothing else (GUARD)

    /// The note sits in a hand-made book with no rule, in a living book that
    /// collects by ANOTHER tag, in a living book whose rule names the tag only
    /// under NOT (it never collected by it), in a FINISHED and an ARCHIVED book
    /// whose rule names it (their intake is paused), and is assembled by a
    /// GATHERING naming it (a gathering holds nothing) — none is "still holding
    /// it by this tag", so the answer is the pre-VX-764 answer plus exactly the
    /// two keys every landed answer carries since VX-825 (`still_in_books: []`
    /// and `beyond_reach`), byte for byte.
    @Test func aRemoveTagThatStrandsNothingAnswersExactlyAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let board = try h.operations.createTag(name: "board")
            let kept = try h.operations.createTag(name: "kept")
            let drafts = try h.operations.createReading(name: "drafts", kind: .book)
            let byKept = try h.operations.createReading(name: "Kept", kind: .book, querySpec: try rule(.tag(kept.id)))
            let excluding = try h.operations.createReading(
                name: "Not board", kind: .book, querySpec: try rule(.and([.tag(kept.id), .not(.tag(board.id))])))
            let finished = try h.operations.createReading(name: "Done", kind: .book, querySpec: try rule(.tag(board.id)))
            let archived = try h.operations.createReading(name: "Old", kind: .book, querySpec: try rule(.tag(board.id)))
            _ = try h.operations.createReading(name: "Gathered", kind: .gathering, querySpec: try rule(.tag(board.id)))
            let note = try h.operations.createPost(title: "card")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: drafts.id)
            _ = try h.operations.applyTag(kept.id, toPost: note.id)    // seats it in Kept and Not board
            _ = try h.operations.applyTag(board.id, toPost: note.id)   // seats it in Done and Old
            try h.operations.lockReading(finished.id)
            try h.operations.archiveReading(archived.id)
            let before = try await memberships(h)
            let held = try await h.database.read { db in
                try Set(String.fetchAll(db, sql: """
                    SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'
                    """, arguments: [note.id]))
            }
            #expect(held == [drafts.id, byKept.id, excluding.id, finished.id, archived.id],
                    "the note is a member of every book in the world: \(held)")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let removed = try await call(connection, "remove_tag", ["note_id": .string(note.id), "tag": .string("board")])
            #expect(removed.isError != true, "\(text(removed))")
            let answer = try json(removed)
            #expect(Set(answer.keys) == ["note_id", "tag_id", "tag", "removed", "still_in_books", "beyond_reach"],
                    "the two VX-825 keys and no other: \(answer)")
            #expect(text(removed) == Self.golden(noteID: note.id, tagID: board.id), "byte for byte: \(text(removed))")
            #expect(try await memberships(h) == before)
            await h.hangUp(connection)
        }
    }

    /// The pre-VX-764 answer's bytes (captured on the old tree, `ebe3df7bc`),
    /// with VX-825's two keys spliced in at their sorted places.
    static func golden(noteID: String, tagID: String) -> String {
        #"{"beyond_reach":"Books beyond your reach, if any, are not listed.","note_id":"\#(noteID)","#
            + #""removed":true,"still_in_books":[],"tag":"board","tag_id":"\#(tagID)"}"#
    }

    // MARK: - The description says why (RED ON OLD: no sentence)

    @Test func theDescriptionSaysUntaggingLeavesTheNoteInItsBooksAndPointsAtGatherings() throws {
        let description = try #require(MCPToolCatalog.declaration(named: "remove_tag")).description
        // VX-825 (justified edit): the count retired; the scope key in its place.
        for phrase in ["still_in_books", "beyond_reach", "remove_note_from_book", "gathering"] {
            #expect(description.contains(phrase), "remove_tag's description says \(phrase): \(description)")
        }
        #expect(!description.contains("hidden_count"), "no count promised: \(description)")
    }
}
