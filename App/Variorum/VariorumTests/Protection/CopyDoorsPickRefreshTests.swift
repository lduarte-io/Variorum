//
//  CopyDoorsPickRefreshTests.swift
//  VariorumTests — VX-306 ladder round 2, NIT 3 (m4's class): A PICKED COPY FILED INTO THIS MAC'S SAFETY COPIES TELLS THE
//  STANDING RESTORE LIST. `ProtectionCopyDoors.pick` files a picked pair or library folder into
//  `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (P-VX306-U3-0: "the copy then stays listed") — but before the fix
//  nothing said so: only the backup hook posted `CopyDoorsListModel.copiesChanged` (m4's seam), and the Data Safety pane's
//  `.task` reads the list once per appearance, so after the picked copy's sheet closed the Restore list omitted the copy
//  she had just filed until the pane was opened again. The fix posts on m4's seam once a filing lands (a pick that files
//  nothing — a copy already catalogued, used where it is; a refusal — has nothing to say). Planted keychain leaves over a
//  temp slot with the real file leaves (`PlantedRoad`, the U3 suites' road — no keychain), heard through the list's own
//  observer (`CopiesChangedObserver`, m4's); everything it names exists on both sides of the fix, so it is RED on the
//  pre-fix tree by construction (no post exists there). Its red side presumes no other suite posts while it runs (the
//  only other posters are m4's two suites) — run it alone for the red leg.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 ladder r2 NIT 3 — a filed pick tells the standing Restore list (planted, no keychain)", .serialized)
@MainActor
struct CopyDoorsPickRefreshTests {
    /// Counts every `CopyDoorsListModel.copiesChanged` heard while it stands — through the list's own observer.
    @MainActor
    final class Heard {
        private(set) var count = 0
        private var observer: CopiesChangedObserver?

        init() { observer = CopiesChangedObserver { [weak self] in self?.count += 1 } }
    }

    /// Waits (bounded) until `done` holds.
    static func settle(_ done: () -> Bool) async throws {
        for _ in 0..<200 where !done() { try await Task.sleep(for: .milliseconds(5)) }
    }

    /// Someone else's library, AirDropped into a folder outside both containers (stage 10's road, `PickedCopyRoadTests`).
    static func airDropped(beside mine: PlantedRoad) async throws -> (folder: URL, theirID: String) {
        let theirs = PlantedRoad()
        let (theirSession, _) = try await theirs.created()
        try CopyDoorsPlant.migrate(theirs, key: theirSession.key)
        let theirID = try #require(theirSession.library.record?.libraryID)
        let downloads = mine.slot.root.appendingPathComponent("Downloads/vx306-airdrop", isDirectory: true)
        try FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        try FileManager.default.copyItem(
            at: theirs.slot.places.slot, to: downloads.appendingPathComponent(CatalogNames.libraryFilename))
        try FileManager.default.copyItem(
            at: theirs.slot.places.liveKeyFile, to: downloads.appendingPathComponent(ProtectionNames.keyFilename))
        return (downloads, theirID)
    }

    /// The Restore list stands (her library's one backup); she picks an AirDropped library — it is FILED — and the
    /// standing list now shows the filed copy under *Other libraries on this Mac*, with no pane reopened.
    @Test func aFiledPickTellsTheStandingListAndItShowsTheCopy() async throws {
        let mine = PlantedRoad()
        let (session, _, backup) = try await CopyDoorsPlant.libraryWithABackup(mine)
        var roads = PlantedCopyDoors().roads
        roads.listing = { ProtectionCopyDoors.listing(session) }
        let list = CopyDoorsListModel(roads: roads)
        await list.refresh()
        #expect(list.listing.thisLibrary.map(\.id) == [backup.id] && list.listing.otherLibraries.isEmpty)
        let heard = Heard()
        let (folder, theirID) = try await Self.airDropped(beside: mine)
        guard case .copy(let row) = ProtectionCopyDoors.pick(folder, session: session) else {
            Issue.record("the pair is filed and catalogued")
            return
        }
        #expect(row.kind == .adoptionSafetyCopy && row.copy.library == theirID)
        try await Self.settle { heard.count > 0 && list.listing.otherLibraries.contains { $0.id == row.id } }
        #expect(heard.count > 0, "the filing said nothing — the copies changed unannounced")
        #expect(list.listing.otherLibraries.map(\.id) == [row.id],
                "the standing list still omits the copy she just filed: \(list.listing.otherLibraries.map(\.id))")
        #expect(list.listing.thisLibrary.map(\.id) == [backup.id])
    }
}
