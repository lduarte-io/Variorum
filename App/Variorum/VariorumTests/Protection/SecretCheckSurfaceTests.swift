//
//  SecretCheckSurfaceTests.swift
//  VariorumTests — VX-510 D-B7 (VX-513): THE READ-ONLY CHECK's Mac faces build and lay out (hosted in a real window — a face
//  that crashes or cannot lay out fails here) in every shape: the door's section standing and not, and the sheet empty and
//  saying each kind of answer. The logic is the models' and the road's (headless — `SecretCheckModelTests`,
//  `SecretCheckRoadTests`); the composition is pinned by source (`SecretCheckCompositionTests`). Mac only (not in the
//  implementer's SwiftPM harness — it hosts windows).
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-510 D-B7 — the read-only check's Mac faces (hosted)", .serialized)
struct SecretCheckSurfaceTests {
    private static func keyDoors(stands: Bool, answer: SecretCheckOutcome) async -> RoadKeyDoorsModel {
        var faces = RoadKeyDoorsModelTests.faces()
        faces.checkStands = stands
        let model = RoadKeyDoorsModel(roads: RoadKeyDoorRoads(
            read: { faces }, press: { _ in .refused("x") }, check: { _ in answer }))
        await model.refresh()
        return model
    }

    /// The door's section hosts standing (one button) and not (nothing rendered).
    @Test func theSectionHostsStandingAndNot() async {
        for stands in [true, false] {
            let model = await Self.keyDoors(stands: stands, answer: .opens(.passphrase, account: .notSynced))
            #expect(model.offersCheck == stands)
            await SurfaceComposition.host(
                Form { RoadSecretCheckSection(model: model) }.formStyle(.grouped), size: NSSize(width: 640, height: 200))
        }
    }

    /// The sheet hosts empty, then saying each kind of answer — the clear ones, the split (with VX-113's named change), the
    /// account-not-library arm, the not-opening lines, the account not checked, a refusal.
    @Test func theSheetHostsInEveryShape() async throws {
        let answers: [SecretCheckOutcome] = [
            .opens(.passphrase, account: .notSynced),
            .opens(.words, account: .opens),
            .opens(.passphrase, account: .doesNotOpen(
                changedElsewhere: ProtectionWords.passphraseChangedElsewhere(device: "Another Mac", day: "October 23"))),
            .opens(.words, account: .unchecked(ProtectionWords.doorRefusedNeedsVault)),
            .doesNotOpen(.passphrase, opensAccount: true),
            .doesNotOpen(.words, opensAccount: false),
            .refused(ProtectionWords.wordsChecksum),
        ]
        let empty = RoadSecretCheckModel(check: { _ in .refused("x") }, finished: {})
        await SurfaceComposition.host(RoadSecretCheckSheet(model: empty), size: NSSize(width: 480, height: 320))
        for answer in answers {
            let sheet = RoadSecretCheckModel(check: { _ in answer }, finished: {})
            await sheet.submit("typed")
            #expect(sheet.outcome == answer)
            await SurfaceComposition.host(RoadSecretCheckSheet(model: sheet), size: NSSize(width: 480, height: 360))
        }
    }
}
