//
//  ProtectionBackupHook.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, where backups run)
//
//  VX-306 U1b — STAGE 3 ON THE NEW ROAD (P-VX306-K4; `notes/plans/vx-306-castle-open-road.md` §2 U1b): rule 5's
//  backup PAIR. Today's `StoreBackup` keeps writing its flat snapshot (Release parity; its files are VX-348's this
//  window — zero edits to `StoreBackup.swift`); its existing after-every-run callback (`onRun`) is attached ONCE
//  per services instance, under the new road only, to the production `BackupsLeaf.takeBackupPair` — so every run
//  that WROTE a snapshot (a scheduled run that was due, or Back Up Now) also lands a pair in this Mac's
//  `Backups/<library8>/<mac8>/`: a consistent snapshot under the library's own key and its frozen key file
//  beside it. A run that found nothing due writes no pair (the hourly re-check would otherwise mint a pair an
//  hour). Copies paused (an act between its prepare and its swap — §3.7) ⇒ nothing; the live key file not the
//  key's ⇒ nothing (a pair is never written with another key's file). Never in a hosted test run. A failure is
//  logged, never raised — a backup never takes the app down.
//

import Foundation
import VariorumCore

// VX-308 U3: the pair itself — `PairOutcome` and `takePair` — lives in `ProtectionBackupPair.swift` (moved verbatim, its
// one home now harness-visible); this file keeps the hook's attachment to the app's `StoreBackup`. (VX-309 U1a: that road
// now also lands the pair in the picked folder when it is due there, and prunes this Mac's pairs of this library after.)
extension ProtectionBackupHook {
    /// Attach the pair to `backup`'s runs — the new road's session only (nil / read-only ⇒ nothing attached).
    @MainActor
    static func attach(to backup: StoreBackup?, session: ProtectionRoadSession?) {
        guard let backup, let session, session.writes else { return }
        backup.onRun = { record in _ = handle(record, session: session) }
    }

    /// One run's record → the pair, off the main actor, only when the run wrote a snapshot. A pair that LANDED
    /// (written) says so on the main actor — `CopyDoorsListModel.copiesChanged` — so a standing Restore list re-reads
    /// (the ladder's round-1 m4, the walk's W-13).
    @MainActor
    @discardableResult
    static func handle(_ record: BackupRunRecord, session: ProtectionRoadSession) -> Task<PairOutcome, Never>? {
        guard record.primary.outcome == .written else { return nil }
        return Task.detached(priority: .utility) {
            let outcome = takePair(session)
            if outcome == .written {
                await MainActor.run {
                    NotificationCenter.default.post(name: CopyDoorsListModel.copiesChanged, object: nil)
                }
            }
            return outcome
        }
    }
}
