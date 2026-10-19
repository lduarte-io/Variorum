//
//  ProtectionPairRetentionTests.swift
//  VariorumTests — VX-309 U1a piece 3: RETENTION WIRED (VX-302; VX-411 folded — this Mac's pairs of this library
//  accumulated on the new road with no retention at all). After the pair road lands a pair (beside the library, and in the
//  picked folder), it prunes by core's `Retention.plan` (`.standard`: newest 14 beside the library; 14 dailies + 4 weeklies
//  in the picked folder) over a FRESH catalogue read — exactly the plan's ids, each snapshot with its own pair. Another
//  Mac's pairs, another library's, a snapshot whose key file doesn't read, today's flat files, `Previous Libraries/`, the
//  safety copies and names no build writes SURVIVE every prune (rule 19's listing of other libraries' copies is U1b's door;
//  nothing here deletes them). Over a PLANTED road — also headless in the implementer's harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1a — retention wired: this Mac's pairs of this library pruned after every pair, nothing else ever", .serialized)
@MainActor
struct ProtectionPairRetentionTests {
    static let day: TimeInterval = 86_400

    /// Every file under `root`'s `Backups/` and `Previous Libraries/` (relative paths) — the world a prune must leave
    /// alone but for the doomed pairs.
    static func files(_ root: URL) -> Set<String> {
        var found: Set<String> = []
        for top in [CatalogNames.backupsFolderName, CatalogNames.previousLibrariesFolderName] {
            let base = root.appendingPathComponent(top, isDirectory: true)
            for path in (try? FileManager.default.subpathsOfDirectory(atPath: base.path)) ?? [] {
                var isFolder: ObjCBool = false
                if FileManager.default.fileExists(atPath: base.appendingPathComponent(path).path, isDirectory: &isFolder),
                   !isFolder.boolValue {
                    found.insert(top + "/" + path)
                }
            }
        }
        return found
    }

    /// The foreign world beside the library and in the picked folder: another Mac's pairs (past any policy), this Mac's
    /// pairs of another library (past any policy), a snapshot whose key file is missing, today's flat files, a Previous
    /// Library, an adoption safety copy and a name no build writes.
    static func plantForeignWorld(_ road: PlantedRoad, _ session: ProtectionRoadSession, now: Date) throws {
        let libraryID = FarPlant.libraryID(session), deviceID = FarPlant.deviceID(session)
        let otherMac = FarPlant.anotherMac(than: deviceID)
        let another = UUID().uuidString.lowercased()
        for root in [road.slot.container, FarPlant.farRoot(road)] {
            for offset in 1...30 {
                let when = now.addingTimeInterval(-Double(offset) * day)
                try FarPlant.pair(in: FarPlant.folder(root, libraryID: libraryID, deviceID: otherMac), libraryID: libraryID, at: when)
                try FarPlant.pair(in: FarPlant.folder(root, libraryID: another, deviceID: deviceID), libraryID: another, at: when)
            }
            let orphan = try FarPlant.pair(
                in: FarPlant.folder(root, libraryID: libraryID, deviceID: otherMac), libraryID: libraryID,
                at: now.addingTimeInterval(-90 * day))
            try FileManager.default.removeItem(at: FileBackupsLeaf.pairURL(
                of: FarPlant.folder(root, libraryID: libraryID, deviceID: otherMac).appendingPathComponent(orphan)))
            let flat = root.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
            for offset in 1...20 {
                let name = CatalogNames.backupPrefix + CatalogNames.stampString(now.addingTimeInterval(-Double(offset) * day))
                    + ".sqlite"
                try Data("today's flat file".utf8).write(to: flat.appendingPathComponent(name))
            }
            try Data("hers".utf8).write(to: flat.appendingPathComponent("variorum-backup-a1-window-2026-10-01T000000Z.sqlite"))
        }
        let stamp = CatalogNames.stampString(now.addingTimeInterval(-60 * day))
        let aside = road.slot.container.appendingPathComponent(CatalogNames.previousLibrariesFolderName, isDirectory: true)
            .appendingPathComponent(stamp, isDirectory: true)
        let safety = road.slot.container.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
            .appendingPathComponent(CatalogNames.safetyCopiesFolderName, isDirectory: true)
            .appendingPathComponent(CatalogNames.adoptionSafetyPrefix + stamp, isDirectory: true)
        for folder in [aside, safety] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try Data("a set-aside library".utf8).write(to: folder.appendingPathComponent(CatalogNames.libraryFilename))
            try KeyFile(libraryID: libraryID, key: StoreKey.mint(), epoch: 1).encoded()
                .write(to: folder.appendingPathComponent(ProtectionNames.keyFilename))
        }
    }

    /// BESIDE THE LIBRARY: this Mac's pairs past the newest 14 are pruned after the next pair lands, each snapshot with its
    /// own pair. RED ON OLD: they accumulate (VX-411 — 21 pairs).
    @Test func pairsPastTheNewestFourteenArePrunedBesideTheLibrary() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let now = Date()
        var planted: [String] = []
        for offset in 1...20 {
            planted.append(try FarPlant.pair(
                in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session),
                at: now.addingTimeInterval(-Double(offset) * Self.day)))
        }
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let left = FarPlant.snapshots(FarPlant.ownContainer(road, session))
        #expect(left.count == 14, "the newest 14 stay — \(left.count) left")
        #expect(Set(planted.prefix(13)).isSubset(of: Set(left)), "the 13 newest planted pairs and the new one")
        for gone in planted.suffix(7) {
            #expect(!left.contains(gone), "\(gone) is past the policy")
            let pair = String(gone.dropLast(".sqlite".count)) + ".keys.json"
            #expect(!FarPlant.names(FarPlant.ownContainer(road, session)).contains(pair), "\(pair) went with its snapshot")
        }
    }

    /// IN THE PICKED FOLDER: this Mac's pairs past 14 dailies + 4 weeklies are pruned after the next far pair lands. RED ON
    /// OLD: 41 pairs stay.
    @Test func pairsPastFourteenDailiesAndFourWeekliesArePrunedInThePickedFolder() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let now = Date()
        for offset in 2...41 {
            try FarPlant.pair(
                in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session),
                at: now.addingTimeInterval(-Double(offset) * Self.day))
        }
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let catalog = road.system().lister.catalog()
        let own = OwnCopies.of(
            catalog, libraryID: FarPlant.libraryID(session), thisMac: FarPlant.deviceID(session), in: .farFolder)
        #expect(own.count == 18, "14 dailies + 4 weeklies — \(own.count) left")
        let newestDays = own.compactMap(\.stamp).sorted(by: >).prefix(14)
        #expect(newestDays.first.map { now.timeIntervalSince($0) < Self.day } == true, "today's pair is kept")
        #expect(FarPlant.snapshots(FarPlant.ownFar(road, session)).count == 18, "the files themselves")
    }

    /// NOTHING ELSE, EVER: another Mac's pairs, another library's, an orphan snapshot, today's flat files, a Previous
    /// Library, a safety copy and a name no build writes — beside the library AND in the picked folder — survive the prune
    /// that takes this Mac's own pairs past the policy. (Green on the pre-wiring tree by design: nothing is pruned there.
    /// The DEBUG mutation pin below turns the core guard off.)
    @Test func anotherMacsAndAnotherLibrarysCopiesSurviveEveryPrune() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let now = Date()
        try Self.plantForeignWorld(road, session, now: now)
        let foreignBeside = Self.files(road.slot.container)
        let foreignFar = Self.files(FarPlant.farRoot(road))
        for offset in 2...41 {
            let when = now.addingTimeInterval(-Double(offset) * Self.day)
            try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session), at: when)
            try FarPlant.pair(in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session), at: when)
        }
        #expect(ProtectionBackupHook.takePair(session) == .written)
        #expect(foreignBeside.isSubset(of: Self.files(road.slot.container)), "every foreign copy beside the library survived — gone: \(foreignBeside.subtracting(Self.files(road.slot.container)).sorted().prefix(4))")
        #expect(foreignFar.isSubset(of: Self.files(FarPlant.farRoot(road))), "every foreign copy in the picked folder survived — gone: \(foreignFar.subtracting(Self.files(FarPlant.farRoot(road))).sorted().prefix(4))")
        #expect(FarPlant.snapshots(FarPlant.ownContainer(road, session)).count == 14)
        #expect(FarPlant.snapshots(FarPlant.ownFar(road, session)).count == 18)
    }

    /// A delete that fails (here an immutable snapshot) is logged, never raised: the pair still lands, the other doomed
    /// pairs still go, the one that could not be removed stays.
    @Test func aDeleteThatFailsNeverFailsThePairOrStopsThePrune() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let now = Date()
        var planted: [String] = []
        for offset in 1...16 {
            planted.append(try FarPlant.pair(
                in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session),
                at: now.addingTimeInterval(-Double(offset) * Self.day)))
        }
        // The two oldest are doomed (16 + 1 → 14 kept, 3 pruned); the oldest cannot be removed.
        let locked = FarPlant.ownContainer(road, session).appendingPathComponent(planted[15])
        try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: locked.path)
        defer { try? FileManager.default.setAttributes([.immutable: false], ofItemAtPath: locked.path) }
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let left = FarPlant.snapshots(FarPlant.ownContainer(road, session))
        #expect(left.contains(planted[15]), "the immutable one stays")
        #expect(!left.contains(planted[14]) && !left.contains(planted[13]), "the other doomed pairs still went")
        #expect(left.count == 15)
    }
}
