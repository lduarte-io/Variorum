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

    /// VX-309 U1a — ONE PAIR ROAD AT A TIME: a pair, its far copy and the prune after them run whole before another
    /// run's begins, so two runs never race for one free name, one far copy or one prune (the hook's runs and VX-447's
    /// "the backup follows" each reach here from their own detached task).
    nonisolated private static let oneAtATime = NSLock()

    /// The pair: the live library under its key, the live key file frozen beside it (this Mac's device ID names
    /// the folder) — then, VX-309 U1a, the far leg (`now` the due-check's clock) and RETENTION (`guards` — every guard
    /// on in production; a DEBUG mutation pin turns one off).
    nonisolated static func takePair(
        _ session: ProtectionRoadSession, now: Date = Date(), guards: ProtectionGuards = .all
    ) -> PairOutcome {
        oneAtATime.lock()
        defer { oneAtATime.unlock() }
        let backups = session.system.backups
        guard !backups.copiesArePaused else {
            ProtectionOpenRoad.log("backup pair: copies are paused — none taken")
            return .paused
        }
        let key = session.key
        guard let keyFile = (try? session.system.leaves.keyFiles.readLiveKeyFile()) ?? nil,
              keyFile.fingerprint == KeyFingerprint.of(key) else {
            ProtectionOpenRoad.log("backup pair: no live key file of the current key — none taken")
            return .noKeyFileOfTheKey
        }
        let deviceID = session.library.section.deviceID
        let snapshot: URL
        do {
            snapshot = try backups.writeContainerPair(with: key, keyFile: keyFile, deviceID: deviceID)
            ProtectionOpenRoad.log(
                "backup pair: written under \(KeyFingerprint.short(keyFile.fingerprint)) in "
                    + ProtectionNames.backupsSubpath(libraryID: keyFile.libraryID, deviceID: deviceID))
        } catch {
            ProtectionOpenRoad.log("backup pair: failed — \(String(describing: error))")
            return .failed(String(describing: error))
        }
        _ = landFarPair(session, snapshot: snapshot, keyFile: keyFile, deviceID: deviceID, now: now)
        _ = prune(session, libraryID: keyFile.libraryID, deviceID: deviceID, now: now, guards: guards)
        return .written
    }

    /// **RETENTION** (VX-309 U1a — VX-302; VX-411 folded: this Mac's pairs accumulated on the new road with none): after a
    /// pair lands, core's `Retention.plan` (`.standard` — the newest 14 beside the library; 14 dailies + 4 weeklies in the
    /// picked folder) over a FRESH catalogue read, for the pair's library and this Mac, and EXACTLY its `prune` ids removed
    /// through the backups leaf — each snapshot with its own pair, a far id under the picked folder's scope — one id per
    /// call, so a delete that fails is logged and never stops the rest. The rule is the fence (only this Mac's backup pairs
    /// of this library; undated copies, `Previous Libraries/`, safety copies, other Macs' and other libraries' copies and
    /// foreign names are never candidates); nothing here adds or removes a candidate. Returns the ids removed. Never raises.
    @discardableResult
    nonisolated static func prune(
        _ session: ProtectionRoadSession, libraryID: String, deviceID: String, now: Date = Date(),
        guards: ProtectionGuards = .all
    ) -> [String] {
        let plan = Retention.plan(
            catalog: session.system.lister.catalog(), libraryID: libraryID, thisMac: deviceID, policy: .standard,
            now: now, guards: guards)
        let places = session.system.places
        var removed: [String] = []
        for id in plan.prune {
            do {
                try session.system.backups.deleteCopies(ids: [id])
            } catch {
                ProtectionOpenRoad.log("backup pair: retention could not remove \(id) — \(String(describing: error))")
                continue
            }
            // Said only of a copy that is gone now (a far folder out of reach since the read removes nothing).
            if places.withFile(catalogID: id, { !FileManager.default.fileExists(atPath: $0.path) }) == true {
                removed.append(id)
            }
        }
        if !removed.isEmpty {
            ProtectionOpenRoad.log(
                "backup pair: retention removed \(removed.count) of this Mac's pairs of this library — "
                    + removed.joined(separator: ", "))
        }
        return removed
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
