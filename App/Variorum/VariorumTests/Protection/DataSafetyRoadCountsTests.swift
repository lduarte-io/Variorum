//
//  DataSafetyRoadCountsTests.swift
//  VariorumTests — VX-309 U1a piece 2 (VX-397): Settings ▸ Data Safety's two rows on the NEW road count THIS Mac's backup
//  pairs of THIS library in their place — the catalogue, per library per Mac — while their paths and the picked folder's
//  set/unset/unreachable states stay as read; with no `roadCounts` (no library's faces) they count nothing — today's
//  flat-file count went with today's road at the release switch (VX-329 U1, R-U1-5). Also the two restatements the pair road and core make of `StoreBackup`'s rules (the interval, the trusted
//  stamp), held equal here where `StoreBackup` is in reach. Mac-only (`DataSafetyModel`, `StoreBackup`): the run is the
//  orchestrator's under the stage.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1a — Data Safety's rows on the new road count this Mac's pairs of this library (VX-397)", .serialized)
@MainActor
struct DataSafetyRoadCountsTests {
    private func scratchDefaults() -> @Sendable () -> UserDefaults {
        let suite = "variorum-vx309-u1a-\(UUID().uuidString)"
        return { UserDefaults(suiteName: suite)! }
    }

    /// The planted world: today's flat files in both places (3 beside the library, 2 in the picked folder); THIS Mac's
    /// pairs of THIS library (2 beside, 1 in the picked folder); another Mac's fresh pair in the picked folder; another
    /// library's pair beside the library.
    private func plantedWorld(_ road: PlantedRoad, _ session: ProtectionRoadSession, now: Date) throws {
        let libraryID = FarPlant.libraryID(session), deviceID = FarPlant.deviceID(session)
        let farRoot = FarPlant.farRoot(road)
        for (root, count) in [(road.slot.container, 3), (farRoot, 2)] {
            let flat = root.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
            try FileManager.default.createDirectory(at: flat, withIntermediateDirectories: true)
            for hour in 1...count {
                let name = CatalogNames.backupPrefix
                    + CatalogNames.stampString(now.addingTimeInterval(-Double(hour) * 3_600)) + ".sqlite"
                try Data("today's flat file".utf8).write(to: flat.appendingPathComponent(name))
            }
        }
        try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: libraryID, at: now.addingTimeInterval(-2 * 86_400))
        try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: libraryID, at: now.addingTimeInterval(-86_400))
        try FarPlant.pair(in: FarPlant.ownFar(road, session), libraryID: libraryID, at: now.addingTimeInterval(-86_400))
        try FarPlant.pair(
            in: FarPlant.folder(farRoot, libraryID: libraryID, deviceID: FarPlant.anotherMac(than: deviceID)),
            libraryID: libraryID, at: now)
        let another = UUID().uuidString.lowercased()
        try FarPlant.pair(in: FarPlant.folder(road.slot.container, libraryID: another, deviceID: deviceID),
                          libraryID: another, at: now)
    }

    private func model(
        _ road: PlantedRoad, defaults: @escaping @Sendable () -> UserDefaults, roadCounts: (() async -> RoadCopyCounts)?
    ) throws -> DataSafetyModel {
        let backup = StoreBackup(
            database: try AppDatabase.inMemory(),
            directory: road.slot.container.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true),
            defaults: defaults)
        return DataSafetyModel(backup: backup, defaults: defaults, roadCounts: roadCounts)
    }

    /// THE ROWS: this Mac's pairs of this library, per place — never today's flat files, never another Mac's or another
    /// library's. And with NO road counts (no library's faces — the model's nil), the rows count nothing: today's flat
    /// files never count, either way, while each row's path and the picked folder's set state stay as read. RED ON OLD
    /// (VX-309 U1a — the orchestrator's behavioural revert, the refresh's two road lines back to `read.primary` /
    /// `read.secondary`): the rows read the flat files' 3 and 2. VX-329's Mac-suite fix leg: the second half was
    /// `…AndTodaysRoadIsUnchanged` — it held TODAY's road (no road counts → the flat files counted as before), whose
    /// flat-file count U1 deleted with today's flat legs (R-U1-5); the first run after the switch read it 0 and 0, as
    /// designed, so the half now holds the new truth over the same planted world.
    @Test func theRowsCountThisMacsPairsOfThisLibraryAndNeverTheFlatFiles() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let now = Date()
        try plantedWorld(road, session, now: now)
        let defaults = scratchDefaults()
        defaults().set(
            try road.slot.far.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil),
            forKey: BackupDestination.defaultsKey)

        let newRoad = try model(road, defaults: defaults, roadCounts: { ProtectionCopyCounts.read(session) })
        await newRoad.refresh()
        let primary = try #require(newRoad.primary)
        #expect(primary.count == 2, "beside the library: this Mac's two pairs of this library — \(primary)")
        #expect(primary.displayPath == BackupDestination.displayPath(
            road.slot.container.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)),
                "the row's path stays the folder it always named")
        guard case .set(_, let far) = newRoad.destination else {
            Issue.record("the picked folder reads as set: \(newRoad.destination)"); return
        }
        #expect(far.count == 1, "the picked folder: this Mac's one pair — never another Mac's fresh copy — \(far)")

        // No road counts: nothing counted — never the three flat files beside the library nor the picked folder's two.
        let noCounts = try model(road, defaults: defaults, roadCounts: nil)
        await noCounts.refresh()
        let bare = try #require(noCounts.primary)
        #expect(bare == DataSafetyModel.FolderSummary(
            displayPath: primary.displayPath, exists: true, count: 0, newest: nil, oldest: nil),
                "beside the library: none counted (the flat files planted there never count), its path and folder as read — \(bare)")
        guard case .set(let farPath, let bareFar) = noCounts.destination else {
            Issue.record("the picked folder still reads as set with no road counts: \(noCounts.destination)"); return
        }
        guard case .set(let farPathWithCounts, _) = newRoad.destination else {
            Issue.record("the counted model's picked folder reads as set: \(newRoad.destination)"); return
        }
        #expect(farPath == farPathWithCounts, "the picked folder's path stays as read")
        #expect(bareFar.count == 0 && bareFar.newest == nil && bareFar.oldest == nil,
                "the picked folder: none counted (its two flat files never count) — \(bareFar)")
    }

    /// The mapping keeps a row's path and its folder's state; only the counts move. Unset and unreachable stay as they are.
    @Test func theCountsMoveAndNothingElse() {
        let read = DataSafetyModel.FolderSummary(
            displayPath: "~/Backups", exists: true, count: 9, newest: Date(timeIntervalSince1970: 9), oldest: nil)
        let own = OwnCopies.Summary(count: 2, newest: Date(timeIntervalSince1970: 5), oldest: Date(timeIntervalSince1970: 1))
        #expect(DataSafetyModel.counted(read, own) == DataSafetyModel.FolderSummary(
            displayPath: "~/Backups", exists: true, count: 2, newest: own.newest, oldest: own.oldest))
        #expect(DataSafetyModel.counted(.unset, own) == .unset)
        #expect(DataSafetyModel.counted(.unreachable, own) == .unreachable)
        #expect(DataSafetyModel.counted(.set(displayPath: "~/Desktop", summary: read), own)
            == .set(displayPath: "~/Desktop", summary: DataSafetyModel.counted(read, own)))
    }

    /// The pair road's interval and core's trusted-stamp rule are restatements of `StoreBackup`'s (the pair road stays
    /// headless; core owns its own reads) — held equal here.
    @Test func theRestatedRulesAreStoreBackups() {
        #expect(ProtectionBackupHook.farInterval == StoreBackup.Configuration().interval)
        let now = Date()
        for offset in [-86_400.0, -1, 0, 1, 86_400] {
            let stamp = now.addingTimeInterval(offset)
            #expect(OwnCopies.stampIsTrusted(stamp, now: now) == StoreBackup.stampIsTrusted(stamp, now: now), "\(offset)")
        }
    }

    /// The composition: the pane hands the open library's road to the model; the faces build it from the open's session.
    @Test func thePaneHandsTheOpenLibrarysRoadToTheModel() throws {
        let pane = try VX379PaneRowsTests.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(pane.contains("roadCounts: roadStanding?.copyCounts))"))
        let faces = try VX379PaneRowsTests.code("Shared/Protection/ProtectionOpenFaces.swift")
        #expect(faces.contains("await Task.detached(priority: .utility) { ProtectionCopyCounts.read(session) }.value"))
    }
}
