import Dependencies
import Foundation
import GRDB

// FINISHED AND SEALED — the book seal (13i-c U2; the sitting record §5, §24;
// the 13i-c plan §5; her kickoff ruling R-13ic-3).
//
// Her one line: "Finished = the table of contents is done; Sealed = the book
// is done." FINISHED is `reading.locked` (shipped — the assembly frozen,
// intake paused, pending arrivals dismissed on the finish's stamp). SEALED
// is Finished + TEXT IMMUTABILITY: every member note sealed on the BOOK's
// exact stamp (`reading.sealed_at` = each member's `container.locked_at`).
//
// The ladder reads open → finished → sealed going up, and sealed → open in
// ONE step down (R-13ic-3: "Unseal reopens the book too"); Reopen
// (`unlockReading`) is the other down-step, from Finished only.
//
// Seal is EDITION ZERO (§5, ruled — "seal as edition zero is perfect"):
// `sealed_at` is the edition's stamp and the members' matching `locked_at`
// its membership-level freeze. A future "cut an edition" is a saved
// snapshot of membership + note versions keyed on such a stamp — nothing
// here forecloses it.
extension Operations {
    /// What sealing did: the forks it made (listed in the confirm first —
    /// "the one copy-as-consequence in the design is never silent").
    public struct SealResult: Equatable, Sendable {
        public let forked: [OwnershipFork]
    }

    /// **SEAL** — in ONE transaction:
    /// 1. **the FORKS** — every live member that also lives in another live
    ///    book FORKS IN PLACE (the Own conversion's step, tags riding): the
    ///    seal must not freeze a note's text in books that are not done. An
    ///    OWNED book has none — "sealing an owned book needs no forks" (§5,
    ///    the composition prize);
    /// 2. **the finish** — if not finished: `locked = 1`, the pending
    ///    arrivals dismissed on this stamp (§24 — the confirm's "N waiting at
    ///    the door will be dismissed");
    /// 3. **the stamp** — `sealed_at = now`;
    /// 4. **the members sealed** — every live member note not already sealed
    ///    is sealed with `locked_at = now`, THE EXACT STAMP (the `lockPost`
    ///    body — dirty buffers insured by one quiet auto commit each). A
    ///    member sealed on its own earlier keeps its own stamp (independent).
    ///
    /// Refuses a GATHERING (`wrongReadingKind` — it holds no members to
    /// seal). Sealing a sealed book is a no-op. `Queries.sealPreview` lists
    /// the forks and the pending-arrival count for the confirm. NO structural-
    /// undo entry — Unseal is the door.
    @discardableResult
    public func sealReading(_ id: String) throws -> SealResult {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            guard reading.sealedAt == nil else { return SealResult(forked: []) }
            let now = date.now
            let forks = try forkSharedMembers(db, readingID: id, now: now)
            if !reading.locked {
                reading.locked = true
                try dismissPendingArrivals(db, readingID: id, now: now)
            }
            reading.sealedAt = now
            reading.updatedAt = now
            try reading.update(db)
            for postID in try liveMemberPostIDs(db, readingID: id) {
                try sealPost(db, id: postID, now: now)
            }
            return SealResult(forked: forks)
        }
    }

    /// **UNSEAL — and the book REOPENS** (R-13ic-3, her pick: "Unseal reopens
    /// the book too"): the members whose seal stamp EQUALS the book's unseal
    /// together (the exact-stamp pattern — an independently-sealed note stays
    /// sealed); `sealed_at` clears; `locked = 0`; and the un-finish CATCH-UP
    /// fires (the book is OPEN again — the gap's matches wait at Arrivals).
    /// Refuses a book that is not sealed (`readingNotSealed`). No undo entry
    /// — Seal is the door back.
    public func unsealReading(_ id: String) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard let sealedAt = reading.sealedAt else {
                throw OperationError.readingNotSealed(id: id)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: sealedAt)
            let now = date.now
            let sealedTogether = try String.fetchAll(
                db,
                sql: """
                    SELECT c.id FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                     AND c.kind = 'post' AND c.locked = 1 AND c.locked_at = ?
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.position, rp.id
                    """,
                arguments: [stamp, id])
            for postID in sealedTogether {
                try unsealPost(db, id: postID, now: now)
            }
            reading.sealedAt = nil
            reading.locked = false
            reading.updatedAt = now
            try reading.update(db)
            try intakeSweep(db, book: reading, occasion: .catchUp, now: now)
        }
    }

    /// The book's live member notes, in its order.
    func liveMemberPostIDs(_ db: Database, readingID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT rp.post_id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                 AND c.kind = 'post'
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.position, rp.id
                """,
            arguments: [readingID])
    }
}
