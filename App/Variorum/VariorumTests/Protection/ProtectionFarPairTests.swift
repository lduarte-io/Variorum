//
//  ProtectionFarPairTests.swift
//  VariorumTests — VX-309 U1a piece 1: THE FAR PAIR LEG (P-VX306-U1a-4's deferral comes due — rule 5 reaches the picked
//  folder) and VX-397's due-check, over a PLANTED road (no keychain — this suite also runs headless in the implementer's
//  harness). A written container pair also lands in `<picked>/Variorum/Backups/<library8>/<mac8>/` — the SAME pair,
//  byte for byte, under the same name — when the far folder is DUE: when the catalogue holds no trusted-stamped far pair
//  of THIS library by THIS Mac younger than the backup interval. Another Mac's fresh copy, another library's, and a
//  future-stamped copy never satisfy it. No far folder, a vanished picked folder, paused copies: nothing, and a far
//  failure never fails the pair.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planting pairs into a road's folders (the catalogue reads names and key files; a planted snapshot's bytes are opaque).
@MainActor
enum FarPlant {
    static func libraryID(_ session: ProtectionRoadSession) -> String { session.library.record?.libraryID ?? "" }
    static func deviceID(_ session: ProtectionRoadSession) -> String { session.library.section.deviceID }

    /// `<root>/Backups/<library8>/<mac8>/` — `root` the container or the far folder's `Variorum/`.
    static func folder(_ root: URL, libraryID: String, deviceID: String) -> URL {
        root.appendingPathComponent(ProtectionNames.backupsSubpath(libraryID: libraryID, deviceID: deviceID), isDirectory: true)
    }

    static func farRoot(_ road: PlantedRoad) -> URL {
        road.slot.far.appendingPathComponent(CatalogNames.variorumFolderName, isDirectory: true)
    }

    /// This Mac's folder for the session's library in the far folder / the container.
    static func ownFar(_ road: PlantedRoad, _ session: ProtectionRoadSession) -> URL {
        folder(farRoot(road), libraryID: libraryID(session), deviceID: deviceID(session))
    }

    static func ownContainer(_ road: PlantedRoad, _ session: ProtectionRoadSession) -> URL {
        folder(road.slot.container, libraryID: libraryID(session), deviceID: deviceID(session))
    }

    /// A pair of `libraryID` stamped `at` in `folder`: an opaque snapshot and its own format-3 key file (a fresh key).
    @discardableResult
    static func pair(in folder: URL, libraryID: String, at date: Date) throws -> String {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let key = StoreKey.mint()
        let stem = CatalogNames.backupPrefix + CatalogNames.stampString(date) + "-"
            + StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
        try Data("planted snapshot".utf8).write(to: folder.appendingPathComponent(stem + ".sqlite"))
        try KeyFile(libraryID: libraryID, key: key, epoch: 1).encoded()
            .write(to: folder.appendingPathComponent(stem + ".keys.json"))
        return stem + ".sqlite"
    }

    static func names(_ folder: URL) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).filter { !$0.hasPrefix(".") }.sorted()
    }

    static func snapshots(_ folder: URL) -> [String] { names(folder).filter { $0.hasSuffix(".sqlite") } }

    /// Another Mac's device ID (its `<mac8>` differs from this Mac's).
    static func anotherMac(than deviceID: String) -> String {
        var other = UUID().uuidString.lowercased()
        while ProtectionNames.mac8(other) == ProtectionNames.mac8(deviceID) { other = UUID().uuidString.lowercased() }
        return other
    }
}

@Suite("VX-309 U1a — the far pair leg: rule 5's pair reaches the picked folder, due per library per Mac (VX-397)", .serialized)
@MainActor
struct ProtectionFarPairTests {
    /// THE LEG: a written container pair also lands in the picked folder — the same pair, byte for byte, under the same
    /// name, opening with the library's key, its key file the live key file frozen. RED ON OLD: no far pair at all.
    @Test func aWrittenPairAlsoLandsInThePickedFolderByteForByte() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let container = FarPlant.ownContainer(road, session)
        let far = FarPlant.ownFar(road, session)
        let snapshot = try #require(FarPlant.snapshots(container).first)
        #expect(FarPlant.names(far) == FarPlant.names(container), "the far folder holds the container's pair, by name")
        let pairName = String(snapshot.dropLast(".sqlite".count)) + ".keys.json"
        for name in [snapshot, pairName] {
            let near = try Data(contentsOf: container.appendingPathComponent(name))
            let farBytes = try? Data(contentsOf: far.appendingPathComponent(name))
            #expect(farBytes == near, "\(name): byte-identical to the container's")
        }
        #expect(ProtectionLibraryFiles.opens(far.appendingPathComponent(snapshot), key: session.key))
        let frozen = try KeyFile.decode(Data(contentsOf: far.appendingPathComponent(pairName)))
        #expect(frozen == (try road.system().leaves.keyFiles.readLiveKeyFile()), "the live key file, frozen beside it")
        // The catalogue reads it as this Mac's far pair of this library.
        let own = OwnCopies.of(
            road.system().lister.catalog(), libraryID: FarPlant.libraryID(session), thisMac: FarPlant.deviceID(session),
            in: .farFolder)
        #expect(own.map(\.name) == [snapshot])
    }

    /// THE FAR FOLDER'S OWN DUE-NESS: a second pair within the interval lands beside the library only.
    @Test func aSecondPairWithinTheIntervalLandsNoSecondFarPair() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        #expect(ProtectionBackupHook.takePair(session) == .written)
        #expect(ProtectionBackupHook.takePair(session) == .written)  // the next free stamp (the leaf steps a second on)
        #expect(FarPlant.snapshots(FarPlant.ownContainer(road, session)).count == 2)
        #expect(FarPlant.snapshots(FarPlant.ownFar(road, session)).count == 1, "the far folder had today's pair already")
    }

    /// VX-397 — THE WRONG SHAPE: another Mac's FRESH copy of this library in the shared folder, and this Mac's fresh copy
    /// of ANOTHER library, never satisfy this Mac's due-check — this Mac's own pair still lands, theirs untouched.
    @Test func anotherMacsFreshFarPairNeverSatisfiesThisMacsDueCheck() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let libraryID = FarPlant.libraryID(session), deviceID = FarPlant.deviceID(session)
        let otherMac = FarPlant.folder(FarPlant.farRoot(road), libraryID: libraryID, deviceID: FarPlant.anotherMac(than: deviceID))
        let theirs = try FarPlant.pair(in: otherMac, libraryID: libraryID, at: Date().addingTimeInterval(-3_600))
        let otherLibraryID = UUID().uuidString.lowercased()
        let otherLibrary = FarPlant.folder(FarPlant.farRoot(road), libraryID: otherLibraryID, deviceID: deviceID)
        let another = try FarPlant.pair(in: otherLibrary, libraryID: otherLibraryID, at: Date().addingTimeInterval(-3_600))
        #expect(ProtectionBackupHook.takePair(session) == .written)
        #expect(FarPlant.snapshots(FarPlant.ownFar(road, session)).count == 1, "this Mac's own pair landed")
        #expect(FarPlant.snapshots(otherMac) == [theirs], "another Mac's copy untouched")
        #expect(FarPlant.snapshots(otherLibrary) == [another], "another library's copy untouched")
    }

    /// This Mac's OWN fresh far pair makes it not due; a stale one (older than the interval) or one stamped ahead of the
    /// clock does not (a future stamp is not freshness — 18o U1's rule).
    @Test func onlyThisMacsOwnTrustedFreshFarPairMakesItNotDue() async throws {
        for (age, due) in [(-3_600.0, false), (-(25 * 3_600.0), true), (3_600.0, true)] {
            let road = PlantedRoad(farFolder: true)
            let (session, _) = try await road.created()
            let planted = try FarPlant.pair(
                in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session), at: Date().addingTimeInterval(age))
            #expect(ProtectionBackupHook.takePair(session) == .written)
            let far = FarPlant.snapshots(FarPlant.ownFar(road, session))
            #expect(far.contains(planted), "the planted pair stays")
            #expect(far.count == (due ? 2 : 1), "a pair stamped \(age) s from now: \(due ? "due" : "not due") — \(far)")
        }
    }

    /// No far folder picked: the container pair only, nothing made anywhere else.
    @Test func noPickedFolderLandsTheContainerPairOnly() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(ProtectionBackupHook.takePair(session) == .written)
        #expect(FarPlant.snapshots(FarPlant.ownContainer(road, session)).count == 1)
        #expect(!FileManager.default.fileExists(atPath: road.slot.far.path), "no far folder was made")
    }

    /// A picked folder that has vanished (deleted, an unplugged drive's mount point gone) is never re-created by the leg.
    @Test func aVanishedPickedFolderIsNeverRecreated() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        try FileManager.default.removeItem(at: road.slot.far)
        #expect(ProtectionBackupHook.takePair(session) == .written, "the container pair still lands")
        #expect(!FileManager.default.fileExists(atPath: road.slot.far.path), "the vanished folder was not re-made")
    }

    /// Paused copies: no pair anywhere (the container's gate is the leg's too).
    @Test func pausedCopiesLandNothingInThePickedFolder() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        session.system.backups.pauseCopies()
        #expect(ProtectionBackupHook.takePair(session) == .paused)
        #expect(FarPlant.names(FarPlant.ownFar(road, session)).isEmpty)
        session.system.backups.resumeCopies()
    }

    /// THE LEAF: a far copy that does not verify (here a "snapshot" the library's key does not open) is removed WHOLE —
    /// no orphan snapshot, no stray key file — and the leaf throws; the container's files are only read.
    @Test func aFarCopyThatDoesNotVerifyIsRemovedWhole() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let keyFile = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        let container = FarPlant.ownContainer(road, session)
        try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        let name = CatalogNames.backupPrefix + CatalogNames.stampString(Date()) + "-"
            + StoreKeyEnvelope.shortFingerprint(keyFile.fingerprint) + ".sqlite"
        let fake = container.appendingPathComponent(name)
        try Data("not a library".utf8).write(to: fake)
        try keyFile.encoded().write(to: FileBackupsLeaf.pairURL(of: fake))
        #expect(throws: FileBackupsLeaf.BackupsLeafError.farPairDidNotVerify) {
            _ = try session.system.backups.landFarPair(
                copying: fake, key: session.key, keyFile: keyFile, deviceID: FarPlant.deviceID(session))
        }
        #expect(FarPlant.names(FarPlant.ownFar(road, session)).isEmpty, "nothing half-landed")
        #expect(FarPlant.names(container).count == 2, "the container's files only read")
    }

    /// THE LEAF: a pair is written once — a name already in the far folder is refused, its bytes untouched.
    @Test func aNameAlreadyInThePickedFolderIsNeverOverwritten() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let keyFile = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        let snapshot = try session.system.backups.writeContainerPair(
            with: session.key, keyFile: keyFile, deviceID: FarPlant.deviceID(session))
        let far = FarPlant.ownFar(road, session)
        try FileManager.default.createDirectory(at: far, withIntermediateDirectories: true)
        let planted = Data("hers".utf8)
        try planted.write(to: far.appendingPathComponent(snapshot.lastPathComponent))
        #expect(throws: FileBackupsLeaf.BackupsLeafError.farPairExists) {
            _ = try session.system.backups.landFarPair(
                copying: snapshot, key: session.key, keyFile: keyFile, deviceID: FarPlant.deviceID(session))
        }
        #expect(try Data(contentsOf: far.appendingPathComponent(snapshot.lastPathComponent)) == planted)
        #expect(FarPlant.names(far) == [snapshot.lastPathComponent], "no key file beside a file it isn't the pair of")
    }

    /// A far failure (here: the far `Backups` is a file, so no folder can be made under it) is logged, never raised —
    /// the container pair stands, and nothing half-landed is left in the picked folder.
    @Test func aFarFailureNeverFailsThePair() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let farRoot = FarPlant.farRoot(road)
        try FileManager.default.createDirectory(at: farRoot, withIntermediateDirectories: true)
        try Data("not a folder".utf8).write(to: farRoot.appendingPathComponent(CatalogNames.backupsFolderName))
        #expect(ProtectionBackupHook.takePair(session) == .written)
        #expect(FarPlant.snapshots(FarPlant.ownContainer(road, session)).count == 1)
        #expect(FarPlant.names(farRoot) == [CatalogNames.backupsFolderName], "nothing else written there")
    }
}
