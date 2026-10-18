//
//  ProtectionRestoreReceiptTests.swift
//  VariorumTests — VX-306 U2 piece 5: RULE 1's RESTORE RECEIPT from planted facts — the live key file gone, this Mac's sealed copy
//  put back by the open's repair, §7c (6)'s receipt owed and spoken ONCE on the status seam's door.
//  (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; the contract `notes/CastleRules.md`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 1's restore receipt (planted facts)")
@MainActor
struct ProtectionRestoreReceiptTests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    // MARK: - Rule 1: the restore receipt

    @Test func theRestoreFromThisMacsCopyOwesOneReceipt() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it")
            return
        }
        #expect(session.report.repairsDone.contains(.restoreKeyFileFromMirror))
        #expect(RoadStandingFaces.derive(session.report).receipts == [ProtectionWords.restoredFromMirror])
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() != nil, "the file is back")
        let standing = RoadStandingModel.make(session, ledger: PassphraseReminderLedger(
            defaults: UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard))
        var spoken: [String] = []
        standing.speak = { spoken.append($0) }
        standing.speak = { spoken.append($0) }
        #expect(spoken == [ProtectionWords.restoredFromMirror], "spoken ONCE")
    }
}
