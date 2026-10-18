//
//  ProtectionPaneRoadRowTests.swift
//  VariorumTests — VX-306 ladder round 1, NIT 4: SETTINGS ▸ PROTECTION'S NEW-ROAD ROW, *Set a passphrase…*, RENDERS ONLY
//  WHILE THE LIBRARY HAS NO PASSPHRASE. The row opens the set-passphrase sheet (P-VX306-U2-0 (a)), which refuses at once
//  when a passphrase exists — so before the fix the pane offered, forever after the first passphrase, a door that could
//  only refuse (P-2: a door that cannot act is not rendered). A COMPOSITION pin (`SurfaceComposition` — the pane's own
//  `body` dumped, an untaken branch absent; the 17f/P47 road): red on the pre-fix pane (the row composed whatever the
//  library held), green after. The pane's lower title-case *Set a Passphrase…* is today's machinery and not this row.
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-306 ladder r1 NIT 4 — the Protection pane's Set a passphrase… row only while none exists", .serialized)
struct ProtectionPaneRoadRowTests {
    private func controller() -> ProtectionController {
        let backing = InMemoryStoreKeyGuardBacking(auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(nil), stamps: ScriptedStampsBox())
        return ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
    }

    private func standing(passphraseExists: Bool, defaults: UserDefaults) -> RoadStandingModel {
        let reminder = PassphraseReminderModel(
            libraryID: "lib", moment: nil, ledger: PassphraseReminderLedger(defaults: defaults),
            facts: { (passphraseSet: passphraseExists, dismissals: 0) }, recordDismissal: { true })
        return RoadStandingModel(
            faces: .none, reminder: reminder, setPassphrase: { _ in .alreadySet },
            passphraseExists: { passphraseExists }, receiptsOwed: { [] })
    }

    @Test func theRowRendersOnlyWhileTheLibraryHasNoPassphrase() async {
        let suite = PassphraseReminderTests.Suite()
        defer { withExtendedLifetime(suite) {} }
        let without = SurfaceComposition.text(of: ProtectionPane(
            controller: controller(), services: nil, roadStanding: standing(passphraseExists: false, defaults: suite.defaults)))
        #expect(SurfaceComposition.carries(ProtectionWords.reminderSetDoor, in: without), "no passphrase yet — the row")
        let with = ProtectionPane(
            controller: controller(), services: nil, roadStanding: standing(passphraseExists: true, defaults: suite.defaults))
        #expect(!SurfaceComposition.carries(ProtectionWords.reminderSetDoor, in: SurfaceComposition.text(of: with)),
                "a passphrase exists — the row (a sheet that could only refuse) is not rendered")
        await SurfaceComposition.host(with, size: NSSize(width: 640, height: 900))
    }
}
