import Foundation
import GRDB

// **THE DAILY JOURNAL UNDER SYNC, MOVABLE AND DELETABLE** (VX-435 + VX-436 —
// the VX-805 run; the proposal and the orchestrator's ruling are the run
// record's Unit B sections, the binding text SyncSpec §7's daily-Journal
// keeper + the cross-wing mend). The keeper's own legs stay in
// `Repairs.swift`, the drain order and its guard in `SyncEngine.swift`, the
// merge's mark in `Merge.swift`.
//
// 1. **The deleted-Journal mark** (option A): her delete stamps the
//    tombstone `profile='daily_deleted'`; the keeper's retirement keeps
//    wearing 'daily'. Converged state, never a clock, tells the two apart —
//    `isDeletedJournalTombstone` is the one reading of it the engine makes.
//
// 2. **THE CROSS-WING MEND** stood here for the daily Journal alone (VX-435's
//    ruling: "a synced-in entry whose Journal moved wings repairs by MOVING
//    the note into the Journal's wing, tags adopting by path"). VX-857 (the
//    VX-808 run — her #261 ruling, "no, no cross wing books … this is a gap
//    we should close") generalized it to EVERY live book: it lives in
//    `BookWingMend.swift`, the Journal its special case (A-808-1). The
//    Journal's one input of its own — the keeper's hand-overs (occasion (c))
//    — is handed to it exactly as before.
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
}
