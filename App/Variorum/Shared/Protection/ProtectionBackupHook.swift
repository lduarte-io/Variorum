//
//  ProtectionBackupHook.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, where backups run)
//
//  VX-306 U1b — STAGE 3 (P-VX306-K4; `notes/plans/vx-306-castle-open-road.md` §2 U1b): rule 5's backup PAIR on the
//  backup clock. VX-329 U1 — THE RELEASE SWITCH: the pair road is THE backup writer. `attach` hands `StoreBackup` the
//  open library's pair road as its run's writer (`pairRoad`), once per services instance and at every ready: a run that
//  is DUE (this Mac's newest pair of this library beside it older than the backup interval — `OwnCopies.pairIsDue`,
//  read fresh from the catalogue; never the folder's newest file) or forced (Back Up Now) lands a pair in this Mac's
//  `Backups/<library8>/<mac8>/` — a consistent snapshot under the library's own key and its frozen key file beside it —
//  then the picked folder's when due there, then retention (`ProtectionBackupPair.takePairReporting`). A run that found
//  nothing due writes nothing. Copies paused (an act between its prepare and its swap — §3.7) ⇒ nothing; the live key
//  file not the key's ⇒ nothing (a pair is never written with another key's file). Never in a hosted test run. A
//  failure is logged and recorded, never raised — a backup never takes the app down.
//

import Foundation
import VariorumCore

// VX-308 U3: the pair itself — `PairOutcome` and `takePair` — lives in `ProtectionBackupPair.swift` (moved verbatim, its
// one home now harness-visible); this file keeps the hook's attachment to the app's `StoreBackup`.
extension ProtectionBackupHook {
    /// Attach the pair road to `backup`'s runs — the road's session only (nil / read-only ⇒ no writer: a run writes
    /// nothing and says "No place to copy to.").
    @MainActor
    static func attach(to backup: StoreBackup?, session: ProtectionRoadSession?) {
        guard let backup else { return }
        guard let session, session.writes else {
            backup.pairRoad = nil
            return
        }
        backup.pairRoad = { force, now in
            let legs = runPair(session, force: force, now: now)
            if legs.primary.outcome == .written {
                // A pair that LANDED says so on the main actor — `CopyDoorsListModel.copiesChanged` — so a standing
                // Restore list re-reads (the ladder's round-1 m4, the walk's W-13).
                Task { @MainActor in
                    NotificationCenter.default.post(name: CopyDoorsListModel.copiesChanged, object: nil)
                }
            }
            return legs
        }
    }

    /// One run's two legs, worded as the run record's: the container's pair (written · up to date · failed) and the
    /// picked folder's (written · up to date · no folder · failed). Off the main actor (the clock's run is).
    nonisolated static func runPair(
        _ session: ProtectionRoadSession, force: Bool, now: Date, interval: TimeInterval = farInterval
    ) -> (primary: BackupRunRecord.Leg, secondary: BackupRunRecord.Leg) {
        let places = session.system.places
        var primary = BackupRunRecord.Leg(outcome: .upToDate)
        primary.destination = BackupDestination.displayPath(places.backups)
        var secondary = BackupRunRecord.Leg(outcome: .noDestination)
        let libraryID = session.library.record?.libraryID ?? ""
        let deviceID = session.library.section.deviceID
        if !force, !OwnCopies.pairIsDue(
            session.system.lister.catalog(), libraryID: libraryID, thisMac: deviceID, in: .container, now: now,
            interval: interval) {
            return (primary, secondary)
        }
        let report = takePairReporting(session, now: now)
        switch report.pair {
        case .written:
            primary.outcome = .written
            primary.file = report.snapshotName
        case .paused:
            primary.outcome = .failed
            primary.detail = "Copies are paused while a change to your library's keys finishes — the next run takes one."
        case .noKeyFileOfTheKey:
            primary.outcome = .failed
            primary.detail = "No key file of the library's current key sits beside it, so no copy was made."
        case .failed(let reason):
            primary.outcome = .failed
            primary.detail = reason
        }
        primary.pruned = report.pruned
        switch report.far {
        case .written?:
            secondary.outcome = .written
            secondary.file = report.snapshotName
        case .notDue?:
            secondary.outcome = .upToDate
        case .failed(let reason)?:
            secondary.outcome = .failed
            secondary.detail = reason
        case .noFarFolder?, nil:
            secondary.outcome = .noDestination
        }
        return (primary, secondary)
    }
}
