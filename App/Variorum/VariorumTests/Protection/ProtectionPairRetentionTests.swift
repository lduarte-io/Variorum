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
//  VX-539 + VX-546 (VX-500 U2): THE SUITE RUNS ON ONE CLOCK AND FIXED INSTANTS. The old suite planted relative to its
//  own `Date()` while the road read another (`takePair`'s default) — and worse, the SCENE's true 14 + 4 answer depends
//  on where "now" sits in the Monday-aligned week (at a week-tail instant the 2…41-day world holds only THREE uncovered
//  weeks past the dailies, so the planner rightly keeps 17, not 18 — the drift VX-546 caught on a Saturday night). The
//  road's `now` defaults are the injected `\.date` now, each test wraps planting AND the press in ONE FIXED instant
//  (`withDependencies { $0.date = .constant(…) }`), and the counts are the planner's true answers at those instants,
//  deterministic on any run date. The FRESH pair the press writes is stamped by the leaf's own wall clock — months past
//  the fixed instants — so it reads as a FUTURE stamp: kept, never pruned, claiming no slot (18o U1's trusted-stamp
//  rule, the same posture production has when a pair's stamp lands past its run's clock; `Retention.plan`'s doc).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1a — retention wired: this Mac's pairs of this library pruned after every pair, nothing else ever", .serialized)
@MainActor
struct ProtectionPairRetentionTests {
    static let day: TimeInterval = 86_400

    /// OFF-BOUNDARY: 2026-01-07 12:00:00 UTC — a Wednesday noon, mid-day and mid-week, where the 2…41-day far world
    /// holds the full four uncovered weeks past the dailies (the planner's 18) and no bucket edge sits near.
    static let instant = Date(timeIntervalSince1970: 1_767_787_200)

    /// THE WEEK BOUNDARY (D-539's named instant): 2026-01-04 00:20:00 UTC — a Sunday, the LAST day of its Monday-aligned
    /// week, twenty minutes past the day line. Here the same 2…41-day world holds only THREE uncovered weeks past the
    /// dailies — the planner's true answer is 17, the shape the live flakes hit.
    static let boundary = Date(timeIntervalSince1970: 1_767_486_000)

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
    /// own pair; the fresh pair (wall-clock-stamped, past the fixed instant) is kept unslotted. RED ON OLD: they
    /// accumulate (VX-411 — 21 pairs).
    @Test func pairsPastTheNewestFourteenArePrunedBesideTheLibrary() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        var planted: [String] = []
        try withDependencies { $0.date = .constant(Self.instant) } operation: {
            for offset in 1...20 {
                planted.append(try FarPlant.pair(
                    in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session),
                    at: Self.instant.addingTimeInterval(-Double(offset) * Self.day)))
            }
            #expect(ProtectionBackupHook.takePair(session) == .written)
        }
        let left = FarPlant.snapshots(FarPlant.ownContainer(road, session))
        #expect(left.count == 15, "the newest 14 planted stay + the fresh pair (future-stamped: unslotted, kept) — \(left.count) left")
        #expect(Set(planted.prefix(14)).isSubset(of: Set(left)), "the 14 newest planted pairs")
        for gone in planted.suffix(6) {
            #expect(!left.contains(gone), "\(gone) is past the policy")
            let pair = String(gone.dropLast(".sqlite".count)) + ".keys.json"
            #expect(!FarPlant.names(FarPlant.ownContainer(road, session)).contains(pair), "\(pair) went with its snapshot")
        }
    }

    /// IN THE PICKED FOLDER: this Mac's pairs past 14 dailies + 4 weeklies are pruned after the next far pair lands —
    /// the EXACT kept set at the off-boundary instant (dailies = the 14 newest days, offsets 2…15; weeklies = the
    /// newest file of each of the four uncovered weeks, offsets 17 · 24 · 31 · 38). RED ON OLD: 41 pairs stay.
    @Test func pairsPastFourteenDailiesAndFourWeekliesArePrunedInThePickedFolder() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        var planted: [Int: String] = [:]
        try withDependencies { $0.date = .constant(Self.instant) } operation: {
            for offset in 2...41 {
                planted[offset] = try FarPlant.pair(
                    in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session),
                    at: Self.instant.addingTimeInterval(-Double(offset) * Self.day))
            }
            #expect(ProtectionBackupHook.takePair(session) == .written)
        }
        let keptOffsets = Set(2...15).union([17, 24, 31, 38])
        let left = Set(FarPlant.snapshots(FarPlant.ownFar(road, session)))
        #expect(left.count == 19, "14 dailies + 4 weeklies + the fresh far pair (future-stamped, unslotted) — \(left.count) left")
        for (offset, name) in planted.sorted(by: { $0.key < $1.key }) {
            #expect(left.contains(name) == keptOffsets.contains(offset),
                    "offset \(offset): \(keptOffsets.contains(offset) ? "kept" : "pruned")")
        }
        let catalog = road.system().lister.catalog()
        let own = OwnCopies.of(
            catalog, libraryID: FarPlant.libraryID(session), thisMac: FarPlant.deviceID(session), in: .farFolder)
        #expect(own.count == 19, "the catalogue's own count — \(own.count)")
    }

    /// NOTHING ELSE, EVER: another Mac's pairs, another library's, an orphan snapshot, today's flat files, a Previous
    /// Library, a safety copy and a name no build writes — beside the library AND in the picked folder — survive the prune
    /// that takes this Mac's own pairs past the policy. (Green on the pre-wiring tree by design: nothing is pruned there.
    /// The DEBUG mutation pin below turns the core guard off.)
    @Test func anotherMacsAndAnotherLibrarysCopiesSurviveEveryPrune() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        var foreignBeside: Set<String> = []
        var foreignFar: Set<String> = []
        try withDependencies { $0.date = .constant(Self.instant) } operation: {
            try Self.plantForeignWorld(road, session, now: Self.instant)
            foreignBeside = Self.files(road.slot.container)
            foreignFar = Self.files(FarPlant.farRoot(road))
            for offset in 2...41 {
                let when = Self.instant.addingTimeInterval(-Double(offset) * Self.day)
                try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session), at: when)
                try FarPlant.pair(in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session), at: when)
            }
            #expect(ProtectionBackupHook.takePair(session) == .written)
        }
        #expect(foreignBeside.isSubset(of: Self.files(road.slot.container)), "every foreign copy beside the library survived — gone: \(foreignBeside.subtracting(Self.files(road.slot.container)).sorted().prefix(4))")
        #expect(foreignFar.isSubset(of: Self.files(FarPlant.farRoot(road))), "every foreign copy in the picked folder survived — gone: \(foreignFar.subtracting(Self.files(FarPlant.farRoot(road))).sorted().prefix(4))")
        #expect(FarPlant.snapshots(FarPlant.ownContainer(road, session)).count == 15)
        #expect(FarPlant.snapshots(FarPlant.ownFar(road, session)).count == 19)
    }

    /// A delete that fails (here an immutable snapshot) is logged, never raised: the pair still lands, the other doomed
    /// pairs still go, the one that could not be removed stays.
    @Test func aDeleteThatFailsNeverFailsThePairOrStopsThePrune() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        var planted: [String] = []
        var locked: URL?
        try withDependencies { $0.date = .constant(Self.instant) } operation: {
            for offset in 1...16 {
                planted.append(try FarPlant.pair(
                    in: FarPlant.ownContainer(road, session), libraryID: FarPlant.libraryID(session),
                    at: Self.instant.addingTimeInterval(-Double(offset) * Self.day)))
            }
            // The two oldest are doomed (16 planted → 14 kept, 2 pruned; the fresh pair claims no slot); the oldest
            // cannot be removed.
            let immutable = FarPlant.ownContainer(road, session).appendingPathComponent(planted[15])
            try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: immutable.path)
            locked = immutable
            #expect(ProtectionBackupHook.takePair(session) == .written)
        }
        defer { if let locked { try? FileManager.default.setAttributes([.immutable: false], ofItemAtPath: locked.path) } }
        let left = FarPlant.snapshots(FarPlant.ownContainer(road, session))
        #expect(left.contains(planted[15]), "the immutable one stays")
        #expect(left.contains(planted[13]), "the 14th newest is kept — the fresh pair claims no slot")
        #expect(!left.contains(planted[14]), "the other doomed pair still went")
        #expect(left.count == 16, "14 kept + the immutable survivor + the fresh pair — \(left.count)")
    }

    /// **THE RED-ON-OLD PIN (D-539 + VX-546 — the week-boundary instant, 2026-01-04 00:20 UTC, a Sunday).** One fixed
    /// instant governs the plants and the press. At this week-tail instant the planner's TRUE far answer is 14 dailies
    /// (offsets 2…15) + THREE weeklies (offsets 21 · 28 · 35) — the 2…41-day world holds only three uncovered weeks
    /// here, the exact drift the live flakes hit — and a pair planted an hour PAST the instant claims no slot and is
    /// never pruned (18o U1). ON THE OLD ROAD (`takePair`'s own `Date()`, months past the instant): that future-of-the-
    /// instant pair reads as trusted-newest and takes a daily slot, offset 15's pair is pruned, and the counts land at
    /// 18 — RED deterministically, whatever today's date. On the new road both clocks are the instant — green. This
    /// also falsifies VX-546's "real miscount" reading: the planner is correct under one clock; the suite's two clocks
    /// (and its runtime-dependent scene) were the whole mechanism.
    @Test func theWeekBoundaryInstantGovernsThePlantsAndThePressAlike() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        var planted: [Int: String] = [:]
        var pastTheClock = ""
        try withDependencies { $0.date = .constant(Self.boundary) } operation: {
            for offset in 2...41 {
                planted[offset] = try FarPlant.pair(
                    in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session),
                    at: Self.boundary.addingTimeInterval(-Double(offset) * Self.day))
            }
            pastTheClock = try FarPlant.pair(
                in: FarPlant.ownFar(road, session), libraryID: FarPlant.libraryID(session),
                at: Self.boundary.addingTimeInterval(3_600))
            #expect(ProtectionBackupHook.takePair(session) == .written)
        }
        let keptOffsets = Set(2...15).union([21, 28, 35])
        let left = Set(FarPlant.snapshots(FarPlant.ownFar(road, session)))
        #expect(left.count == 19,
                "14 dailies + 3 weeklies (the week-tail's true answer) + the past-the-clock pair + the fresh far pair — \(left.count) left")
        #expect(left.contains(pastTheClock), "a pair stamped past the suite's clock claims no slot and is never pruned")
        for (offset, name) in planted.sorted(by: { $0.key < $1.key }) {
            #expect(left.contains(name) == keptOffsets.contains(offset),
                    "offset \(offset): \(keptOffsets.contains(offset) ? "kept" : "pruned")")
        }
    }
}

#if DEBUG
/// The core guard reaches THROUGH the pair road: switched off (DEBUG only), the pair road's prune is today's VX-302 shape —
/// another Mac's copies in the shared folder pruned by stamp — so the survival pin above is not hollow.
@Suite("VX-309 U1a — retention's guard, switched off, lets VX-302's cross-Mac prune through the pair road (DEBUG mutation pin)")
@MainActor
struct ProtectionPairRetentionGuardMutationTests {
    @Test func theGuardOffPrunesAnotherMacsCopiesThroughThePairRoad() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        var before: Set<String> = []
        try withDependencies { $0.date = .constant(ProtectionPairRetentionTests.instant) } operation: {
            try ProtectionPairRetentionTests.plantForeignWorld(road, session, now: ProtectionPairRetentionTests.instant)
            before = ProtectionPairRetentionTests.files(FarPlant.farRoot(road))
            var off = ProtectionGuards()
            off.pruneOwnCopiesOnly = false
            #expect(ProtectionBackupHook.takePair(session, guards: off) == .written)
        }
        let gone = before.subtracting(ProtectionPairRetentionTests.files(FarPlant.farRoot(road)))
        let library8 = ProtectionNames.library8(FarPlant.libraryID(session))
        let mac8 = ProtectionNames.mac8(FarPlant.deviceID(session))
        #expect(gone.contains { $0.hasPrefix("Backups/\(library8)/") && !$0.hasPrefix("Backups/\(library8)/\(mac8)/") },
                "red with the guard off: another Mac's copies pruned — \(gone.count) gone")
    }
}
#endif
