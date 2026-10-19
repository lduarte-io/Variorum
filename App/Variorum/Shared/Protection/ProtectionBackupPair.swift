//
//  ProtectionBackupPair.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, where backups run)
//
//  VX-306 U1b — RULE 5's PAIR, the one road (`ProtectionBackupHook.swift` attaches it to every backup run that wrote a
//  snapshot). VX-308 U3 moved `PairOutcome` and `takePair` here VERBATIM, out of the hook's file (which names the app's
//  `StoreBackup`), so the pair's one home also serves VX-447's banner door — record the words → a fresh key file → THE
//  BACKUP FOLLOWS (`RoadStandingModel`, after the look's mint) — and runs headless in the implementer's harness.
//
//  VX-309 U1a — RULE 5 REACHES THE PICKED FOLDER (P-VX306-U1a-4's deferral comes due; VX-397): after the container pair
//  lands, THE FAR LEG copies that same pair into `<picked>/Variorum/Backups/<library8>/<mac8>/` when the far folder is
//  DUE — the catalogue holding no trusted-stamped far pair of THIS library by THIS Mac younger than the backup interval
//  (`OwnCopies.farPairIsDue`, read fresh — never the folder's newest file, so another Mac's copy in a shared folder never
//  satisfies it). No far folder, an unresolved bookmark, a vanished picked folder: nothing; a failure is logged, never
//  raised — the container pair stands either way, and today's flat far leg (`StoreBackup`) runs untouched beside it.
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

    /// VX-309 U1a — what the far leg did with a written container pair (said in the log; the pair's outcome is the
    /// container's, whatever happens here).
    nonisolated enum FarOutcome: Equatable, Sendable {
        /// The pair landed in the picked folder (its catalogue id).
        case written(String)
        /// The picked folder holds this Mac's fresh pair of this library already.
        case notDue
        /// No far folder picked, or its bookmark does not resolve now.
        case noFarFolder
        case failed(String)
    }

    /// The backup interval the far folder's due-ness reads: `StoreBackup.Configuration`'s default `interval` (24 h — the
    /// app's backup runs on it), restated so this file stays free of the app's `StoreBackup` (headless); a Mac pin holds
    /// the two equal.
    nonisolated static let farInterval: TimeInterval = 24 * 60 * 60

    /// The pair: the live library under its key, the live key file frozen beside it (this Mac's device ID names
    /// the folder) — then, VX-309 U1a, the far leg (`now` the due-check's clock).
    nonisolated static func takePair(_ session: ProtectionRoadSession, now: Date = Date()) -> PairOutcome {
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
        let deviceID = session.library.section.deviceID
        let snapshot: URL
        do {
            snapshot = try backups.writeContainerPair(with: key, keyFile: keyFile, deviceID: deviceID)
            ProtectionOpenRoad.log(
                "backup pair: written under \(StoreKeyEnvelope.shortFingerprint(keyFile.fingerprint)) in "
                    + ProtectionNames.backupsSubpath(libraryID: keyFile.libraryID, deviceID: deviceID))
        } catch {
            ProtectionOpenRoad.log("backup pair: failed — \(String(describing: error))")
            return .failed(String(describing: error))
        }
        _ = landFarPair(session, snapshot: snapshot, keyFile: keyFile, deviceID: deviceID, now: now)
        return .written
    }

    /// **THE FAR LEG** (VX-309 U1a): the container pair just written (`snapshot` — this act's own, handed through) copied
    /// into the picked folder when it is due. Never raises.
    nonisolated static func landFarPair(
        _ session: ProtectionRoadSession, snapshot: URL, keyFile: KeyFile, deviceID: String, now: Date
    ) -> FarOutcome {
        guard session.system.places.farFolder() != nil else { return .noFarFolder }
        let catalog = session.system.lister.catalog()
        guard OwnCopies.farPairIsDue(
            catalog, libraryID: keyFile.libraryID, thisMac: deviceID, now: now, interval: farInterval) else {
            ProtectionOpenRoad.log("backup pair: the picked folder holds this Mac's fresh pair of this library — none copied there")
            return .notDue
        }
        do {
            guard let id = try session.system.backups.landFarPair(
                copying: snapshot, key: session.key, keyFile: keyFile, deviceID: deviceID) else { return .noFarFolder }
            ProtectionOpenRoad.log("backup pair: copied to the picked folder — \(id)")
            return .written(id)
        } catch {
            ProtectionOpenRoad.log("backup pair: the picked folder's copy failed — \(String(describing: error))")
            return .failed(String(describing: error))
        }
    }
}
