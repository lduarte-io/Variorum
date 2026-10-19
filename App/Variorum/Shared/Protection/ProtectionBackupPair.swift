//
//  ProtectionBackupPair.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, where backups run)
//
//  VX-306 U1b — RULE 5's PAIR, the one road (`ProtectionBackupHook.swift` attaches it to every backup run that wrote a
//  snapshot). VX-308 U3 moved `PairOutcome` and `takePair` here VERBATIM, out of the hook's file (which names the app's
//  `StoreBackup`), so the pair's one home also serves VX-447's banner door — record the words → a fresh key file → THE
//  BACKUP FOLLOWS (`RoadStandingModel`, after the look's mint) — and runs headless in the implementer's harness. Nothing
//  about the pair changed.
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
