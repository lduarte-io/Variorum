import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-764 (the VX-771 run, batch 3 — R-771-A (a), the dial DECLINED; the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 3 RECORD): the
// un-tag's REPORT at the operation. `removeTagForClient` answers, read inside its
// own transaction, the LIVING books whose readable rule names the removed tag
// POSITIVELY at-or-above it (intake's subtree rule — `appliedTag`, the grammar's
// `positiveTagIDs`) and that still hold the note as a member — and lands NOTHING
// on any book (un-tagging stays a non-event, §19). Cost ∝ the note's memberships
// (P1 — pinned on the statement's plan). New API, so these pins ride the build;
// the wire pins (`MCPRemoveTagStrandedServerTests`) are the red-on-old leg.

@Suite("VX-764 — the un-tag reports the living books that still hold the note")
struct UntagStillInBooksTests {
    private func rule(_ term: RuleTerm) throws -> String? { try RuleGrammar.encode(term) }

    private func memberships(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM reading_post ORDER BY id").map(\.description)
        }
    }

    /// Every shape that differs, one world: a book whose rule names the tag,
    /// one whose rule names its PARENT (the subtree rule), one naming it only
    /// under NOT, a finished, an archived and a malformed-rule book, a
    /// rule-less hand-made book, a book collecting by another tag, and a
    /// gathering naming the tag (which holds nothing). Listed: exactly the two
    /// living books that collect by it, in the order the note joined them.
    @Test func theReportIsTheLivingBooksCollectingByTheTagInJoinOrder() throws {
        try withOperations { ops, db in
            let board = try ops.createTag(name: "board")
            let doing = try ops.createTag(parent: board.id, name: "doing")
            let kept = try ops.createTag(name: "kept")
            let note = try ops.createPost(title: "card")
            _ = try ops.newBlock(in: note.id, text: "Ship it.", registeringUndo: false)
            let hand = try ops.createReading(name: "drafts", kind: .book)
            _ = try ops.addPostToReading(note.id, to: hand.id)
            let byKept = try ops.createReading(name: "kept", kind: .book, querySpec: try rule(.tag(kept.id)))
            let excluding = try ops.createReading(
                name: "not doing", kind: .book, querySpec: try rule(.and([.tag(kept.id), .not(.tag(doing.id))])))
            _ = try ops.applyTag(kept.id, toPost: note.id)                // seats it in "kept" and "not doing"
            let byDoing = try ops.createReading(name: "doing", kind: .book, querySpec: try rule(.tag(doing.id)))
            let byParent = try ops.createReading(name: "board", kind: .book, querySpec: try rule(.tag(board.id)))
            let finished = try ops.createReading(name: "done", kind: .book, querySpec: try rule(.tag(board.id)))
            let archived = try ops.createReading(name: "old", kind: .book, querySpec: try rule(.tag(board.id)))
            let gathering = try ops.createReading(name: "gathered", kind: .gathering, querySpec: try rule(.tag(doing.id)))
            _ = try ops.applyTag(doing.id, toPost: note.id)               // seats it in doing, board, done, old
            let malformed = try ops.createReading(name: "broken", kind: .book, querySpec: "{\"tag\":")
            _ = try ops.addPostToReading(note.id, to: malformed.id)
            try ops.lockReading(finished.id)
            try ops.archiveReading(archived.id)
            let held = try db.read { db in
                try Set(String.fetchAll(db, sql: """
                    SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'
                    """, arguments: [note.id]))
            }
            #expect(held == [hand.id, byKept.id, excluding.id, byDoing.id, byParent.id, finished.id, archived.id,
                             malformed.id], "the note is a member of every book: \(held)")
            #expect(try db.read { try RuleGrammar.read(Reading.fetchOne($0, key: malformed.id)?.querySpec) } == .malformed)
            _ = gathering
            let before = try memberships(db)

            let removal = try ops.removeTagForClient(path: "board/doing", fromNote: note.id, undoLabel: "x")
            #expect(removal.stillInBookIDs == [byDoing.id, byParent.id],
                    "the two living books collecting by the tag (or its parent), in join order")
            #expect(try memberships(db) == before, "nothing lands on a book")

            // A positive term inside a conjunction collects too ("not doing" is
            // `kept AND NOT doing`); a tag no living book collects by reports none.
            let byKeptToo = try ops.removeTagForClient(path: "kept", fromNote: note.id, undoLabel: "x")
            #expect(byKeptToo.stillInBookIDs == [byKept.id, excluding.id], "both collect by kept")
            let other = try ops.createTag(name: "loose")
            _ = try ops.applyTag(other.id, toPost: note.id)
            #expect(try ops.removeTagForClient(path: "loose", fromNote: note.id, undoLabel: "x").stillInBookIDs == [])
        }
    }

    /// P1: the report is driven by the NOTE's memberships
    /// (`idx_reading_post_post`), each book found by its key — never a scan of
    /// the readings or the memberships.
    @Test func theReportIsDrivenByTheNotesMembershipsNeverACorpusScan() throws {
        try withOperations { _, db in
            let plan = try db.read { db -> String in
                try Row.fetchAll(
                    db, sql: "EXPLAIN QUERY PLAN " + Operations.livingRuledMembershipsSQL, arguments: ["n"]
                ).map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
            }
            #expect(plan.contains("SEARCH rp USING INDEX idx_reading_post_post (post_id=?)"), "the note drives:\n\(plan)")
            #expect(plan.contains("SEARCH r USING INDEX sqlite_autoindex_reading_1 (id=?)"), "each book by key:\n\(plan)")
            #expect(!plan.contains("SCAN"), "no scan:\n\(plan)")
        }
    }
}
