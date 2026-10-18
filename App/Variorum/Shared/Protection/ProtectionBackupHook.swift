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

enum ProtectionBackupHook {
    /// What one pair attempt did.
    nonisolated enum PairOutcome: Equatable, Sendable {
        case written
        case paused
        /// No live key file of the current key to freeze beside the snapshot.
        case noKeyFileOfTheKey
        case failed(String)
    }

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

    /// The pair: the live library under its key, the live key file frozen beside it (this Mac's device ID names
    /// the folder).
    nonisolated static func takePair(_ session: ProtectionRoadSession) -> PairOutcome {
        let backups = session.system.backups
        guard !backups.copiesArePaused else {
            ProtectionOpenRoad.log("backup pair: copies are paused — none taken")
            return .paused
        }
        let key = session.key
        guard let keyFile = (try? session.system.leaves.keyFiles.readLiveKeyFile()) ?? nil,
              keyFile.fingerprint == StoreKeyEnvelope.fingerprint(of: key) else {
            ProtectionOpenRoad.log("backup pair: no live key file of the current key — none taken")
            return .noKeyFileOfTheKey
        }
        do {
            try backups.takeBackupPair(with: key, keyFile: keyFile, deviceID: session.library.section.deviceID)
            ProtectionOpenRoad.log(
                "backup pair: written under \(StoreKeyEnvelope.shortFingerprint(keyFile.fingerprint)) in "
                    + ProtectionNames.backupsSubpath(libraryID: keyFile.libraryID, deviceID: session.library.section.deviceID))
            return .written
        } catch {
            ProtectionOpenRoad.log("backup pair: failed — \(String(describing: error))")
            return .failed(String(describing: error))
        }
    }
}
