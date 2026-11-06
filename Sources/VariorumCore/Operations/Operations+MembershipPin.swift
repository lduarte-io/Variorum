import Foundation
import GRDB

// VX-803 — PINNED NOTES (the run record `notes/plans/fixes/vx-808-arrivals-books.md`
// §3, her rulings: "SEVERAL pins allowed; the pinned group floats on top and
// orders among itself by the book's own sort"; "pins hold EVERYWHERE"). The
// float itself is a READ — `Queries.assembleReading`'s ORDER BY, the one order
// every book mode consumes; this is the one WRITE of the mark.
extension Operations {
    /// **Pin or unpin a note's membership in a book** — `reading_post.pinned_at`
    /// := now on a pin (the stamp doubling as since-when), NULL on an unpin.
    ///
    /// The posture, ruled at the B4 fork (A-808-12):
    /// - **A BOOK only** — a gathering holds no membership rows and refuses
    ///   `wrongReadingKind`, answered first after liveness (`lockReading`'s "the
    ///   kind, not the state, is the answer"); no door renders there either.
    /// - **A FINISHED book refuses `lockedReading`** — a pin is ORDER, and
    ///   Finished freezes the assembly: the sort dial's own posture
    ///   (`writeReadingSort`, `reorderMembershipRow`, `assignSectionRow`).
    ///   PROVISIONAL P-808-B4-1 (pinning inside a Finished book is a one-guard
    ///   flip, hers at the bundle). A SEALED book is locked too, so it refuses
    ///   by construction; a sealed NOTE in an OPEN book pins freely — the seal's
    ///   reach is authoring writes under the note, and a pin is book-side.
    /// - **A MEMBER only** — an arrival is never a member (`liveMembership`):
    ///   `postNotInReading`, the membership doors' one answer.
    /// - **Identity-level metadata:** no touch, no churn, no undo entry (the
    ///   `assignPostToSection` / `setStarred` class — Unpin is the way back), and
    ///   a write that changes nothing writes nothing (no row, no outbox entry).
    ///   `reading_post` has no `updated_at`: the pin's own stamp is the row's
    ///   only stamp, and `reading.updated_at` is untouched (the membership
    ///   siblings' posture). The outbox rides the ordinary UPDATE trigger.
    ///
    /// Sync: `pinned_at` is CAS metadata (server-wins) — two devices pinning or
    /// unpinning one row converge by the standing metadata rule; no repair class.
    public func setMembershipPinned(
        _ postID: String, in readingID: String, pinned: Bool
    ) throws {
        try database.write { db in
            try writeMembershipPin(db, postID: postID, readingID: readingID, pinned: pinned)
        }
    }

    /// `setMembershipPinned`'s row work inside a caller's transaction. Returns
    /// whether it changed the row (false = the no-op guard held).
    @discardableResult
    func writeMembershipPin(
        _ db: Database, postID: String, readingID: String, pinned: Bool
    ) throws -> Bool {
        let reading = try liveReading(db, readingID)
        guard reading.kind == .book else {
            throw OperationError.wrongReadingKind(id: readingID, expected: .book)
        }
        guard !reading.locked else {
            throw OperationError.lockedReading(id: readingID)
        }
        guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
            throw OperationError.postNotInReading(postID: postID, readingID: readingID)
        }
        guard (membership.pinnedAt != nil) != pinned else { return false }
        membership.pinnedAt = pinned ? date.now : nil
        try membership.update(db)
        return true
    }
}
