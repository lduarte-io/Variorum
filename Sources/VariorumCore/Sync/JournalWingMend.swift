import Foundation
import GRDB

// **THE DAILY JOURNAL UNDER SYNC, MOVABLE AND DELETABLE** (VX-435 + VX-436 —
// the VX-805 run; the proposal and the orchestrator's ruling are the run
// record's Unit B sections, the binding text SyncSpec §7's daily-Journal
// keeper + the cross-wing mend). Two pieces live here; the keeper's own legs
// stay in `Repairs.swift`, the drain order and its guard in `SyncEngine.swift`,
// the merge's mark in `Merge.swift`.
//
// 1. **The deleted-Journal mark** (option A): her delete stamps the
//    tombstone `profile='daily_deleted'`; the keeper's retirement keeps
//    wearing 'daily'. Converged state, never a clock, tells the two apart —
//    `isDeletedJournalTombstone` is the one reading of it the engine makes.
//
// 2. **THE CROSS-WING MEND** — her VX-435 ruling: "a synced-in entry whose
//    Journal moved wings repairs by MOVING the note into the Journal's wing,
//    tags adopting by path — the same members-move-with-the-book semantics as
//    moveReadingToWing." A live MEMBER of the live daily Journal whose note
//    sits in another wing moves into the Journal's EFFECTIVE wing, through the
//    note move's ONE relocation (`Operations.relocateNote` — "a thing's past
//    goes where the thing goes": its saved versions ride, its post and block
//    tags re-point by path, adopt-else-mint, as row copies, no intake), with
//    EVERY write enqueued explicitly (apply mode mutes the outbox triggers).
//    Nothing else moves: no stay-behind membership is severed, arrivals wait
//    (P-805-B3), chapters/comments/lenses carry no wing. Deterministic on
//    every device (the keeper and the Journal's wing are converged state; two
//    devices mending one note write the same wing and their fresh
//    application/tag ids converge by the standing tag.path and pure-duplicate
//    repairs). Idempotent (a mended note is in the Journal's wing). Never for
//    a dead book: the scope is the LIVE daily Journal only.
//
//    Its occasions are ∝ the batch (P1), never a container landing (a
//    deliberate note move out of the Journal can be met between its
//    container chunk and its membership-tombstone chunk — mending then would
//    undo her move):
//    (a) a LIVE membership of the Journal LANDED (the posts it names);
//    (b) the Journal's own row LANDED with a changed wing pointer (its live
//        members still in the wing it moved FROM — the offline filings a
//        device made while it stood there), or landed NEW here (its members);
//    (c) the keeper handed a loser's children over this batch (those posts).
extension SyncEngine {
    /// A `reading` TOMBSTONE wearing the deleted-Journal mark — her delete of
    /// the daily Journal (VX-436, option A). Every other dead `'daily'` row is
    /// the keeper's retirement (or an older build's delete).
    static func isDeletedJournalTombstone(_ row: SyncRow) -> Bool {
        guard row.table == "reading", row.isTombstoned,
              case .text(let profile) = row.columns["profile"]
        else { return false }
        return profile == Queries.dailyJournalDeletedProfile
    }

    /// THE MEND (the file header's piece 2). Runs post-batch, right after the
    /// Journal keeper, inside the apply transaction. Returns the repair writes
    /// it enqueued.
    func mendJournalMembersIntoItsWing(
        _ db: Database, touched: TouchedRows, keeperMoved: Set<String>
    ) throws -> Int {
        guard let journalID = try Queries.dailyJournalBookID(db),
              let journal = try Reading.fetchOne(db, key: journalID)
        else { return 0 }
        // A wing pointer naming NO local wing row is a straggler (causal
        // order delivers the wing first, so this is defensive): reading it as
        // Home would mend toward the wrong wing. Never write on it.
        if !journal.wingId.isEmpty,
           try !(Bool.fetchOne(
               db, sql: "SELECT EXISTS (SELECT 1 FROM wing WHERE id = ?)",
               arguments: [journal.wingId]) ?? false) {
            return 0
        }
        let target = try Queries.wingIsLive(db, id: journal.wingId) ? journal.wingId : ""

        // The scope — the three occasions, never the corpus.
        var scope = keeperMoved                                            // (c)
        scope.formUnion(touched.liveMembershipLandings[journalID] ?? [])  // (a)
        if let landing = touched.readingWingLandings[journalID] {          // (b)
            let members = try liveMemberPostIDs(db, journalID: journalID)
            if let priorWing = landing {
                let moved = try Queries.wingIsLive(db, id: priorWing) ? priorWing : ""
                for postID in members where try Queries.effectiveWing(db, ofPost: postID) == moved {
                    scope.insert(postID)
                }
            } else {
                scope.formUnion(members)
            }
        }
        guard !scope.isEmpty else { return 0 }

        let ops = Operations()
        let now = date.now
        var adoption = Operations.TagAdoption(wing: target)
        var repairs = 0
        for postID in scope.sorted() {
            guard try isLiveMember(db, postID: postID, journalID: journalID),
                  let wing = try Queries.effectiveWing(db, ofPost: postID), wing != target,
                  let post = try Container.fetchOne(db, key: postID),
                  post.deletedAt == nil, post.kind == .post
            else { continue }
            // Keep EVERY reading the note has rows in: the mend severs nothing
            // (the ruled "what moves" — the note, its versions, its tags).
            let keeping = Set(try ops.wingMoveMemberships(db, postID: postID).map(\.reading.id))
            _ = try ops.relocateNote(
                db, postID: postID, to: target, keeping: keeping, adoption: &adoption, now: now)
            try enqueueExplicitly(db, table: "container", rowID: postID)
            repairs += 1
            for versionID in try Queries.noteVersionIDs(db, of: postID) {
                guard try Container.fetchOne(db, key: versionID)?.deletedAt == nil else { continue }
                try enqueueExplicitly(db, table: "container", rowID: versionID)
                repairs += 1
            }
        }
        for written in adoption.written {
            try enqueueExplicitly(db, table: written.table, rowID: written.rowID)
            repairs += 1
        }
        return repairs
    }

    private func liveMemberPostIDs(_ db: Database, journalID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                ORDER BY post_id
                """,
            arguments: [journalID])
    }

    private func isLiveMember(_ db: Database, postID: String, journalID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member')
                """,
            arguments: [journalID, postID]) ?? false
    }
}
