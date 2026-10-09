import Foundation
import GRDB

// THE PRIVATE MARK (13n-b U2 — R-13nb-4, hers: "should we add a designation or
// book setting like 'Private', so that people can have books that are not
// shared with AI without them having to be journal type?"). Two synced stamps
// (v1_25 — `container.ai_private_at`, `reading.ai_private_at`; PLAIN under
// E2EE, the `archived_at` class): a per-NOTE mark (the primitive) and a
// per-BOOK mark (its members, and every future member). The FENCE they feed
// is journal-class and lives in ONE place (`Queries.mcpNoteFacts` — privacy
// wins ties); these two ops only set and clear the stamps.
//
// Conventions, each the standing one for identity-level metadata
// (`setTakeLabel`, `setBlockName`, `setJournalTrait`):
// - **no touch stamp, no churn** — marking a note is not working on the prose
//   and must never reshuffle the library's sort (§10);
// - **no-op-guarded** — marking a marked note (or clearing an unmarked one)
//   writes nothing: no row, no outbox entry;
// - **no undo entry** — the door is its own recovery (press it again);
// - **ALLOWED under a seal, on a finished, sealed or archived book, and on an
//   archived note** — PROVISIONAL (P-13nb-U2-1): the mark PROTECTS rather
//   than authors (the seal freezes authoring; withholding a note from AI
//   writes no word of it), so the guard that refuses authoring has nothing to
//   refuse here. The conservative alternative (refuse under a seal, the
//   comment/label letter) is recorded for her.
//
// Refusals: a scraps group (pool) is not markable in v1 (`wrongContainerKind`
// — the design addendum's restraint); a GATHERING refuses
// (`wrongReadingKind` — fence-by-rule would be unpredictable; the
// Owned/extents/lock pattern). Ownership is untouched (Private ⊥ Owned).
//
// Fencing is IMMEDIATE on connected clients: the server consults the rule per
// call against current facts, so the very next call after a mark reads it.
extension Operations {
    /// Marks (or clears) a note's own Private stamp. Returns whether anything
    /// was written (false = the no-op).
    @discardableResult
    public func setNotePrivate(_ postID: String, _ on: Bool) throws -> Bool {
        try database.write { db in
            _ = try livePost(db, postID)
            let marked = try Queries.isNotePrivate(db, postID: postID)
            guard marked != on else { return false }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            try db.execute(
                sql: "UPDATE container SET ai_private_at = ?, updated_at = ? WHERE id = ?",
                arguments: [on ? now : nil, now, postID])
            return true
        }
    }

    /// Marks (or clears) a BOOK's Private stamp — every live member is fenced
    /// while it holds, future members included. Returns whether anything was
    /// written.
    @discardableResult
    public func setBookPrivate(_ readingID: String, _ on: Bool) throws -> Bool {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            let marked = try Queries.isBookPrivate(db, readingID: readingID)
            guard marked != on else { return false }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            try db.execute(
                sql: "UPDATE reading SET ai_private_at = ?, updated_at = ? WHERE id = ?",
                arguments: [on ? now : nil, now, readingID])
            return true
        }
    }
}
