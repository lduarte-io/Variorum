//
//  SetPassphraseRowRereadTests.swift
//  VariorumTests — VX-309 U1c piece 5: VX-454 (W-VX308-2's trace, Suspected) — PROBE FIRST. "Set a passphrase…" still
//  renders above the key doors after turn-on-sync set one: over planted keychain leaves, the planted vault and a temp slot
//  (`PlantedRoad` + `PlantedAccount` — no keychain, no network; the suite also runs headless in the implementer's SwiftPM
//  harness), a library with NO passphrase turns sync on with a NEW one — an account act on the OPEN session, no reopen — and
//  the Protection pane's appearance then reads its rows. The set row (`RoadStandingModel.offersSetPassphrase`) and rule 3's
//  reminder (the card's reminder row) must both retire: a passphrase exists now.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-454: the set-passphrase row re-reads after an act set one (planted, no network)", .serialized)
@MainActor
struct SetPassphraseRowRereadTests {
    @Test func turningSyncOnWithANewPassphraseRetiresTheSetRowAndTheReminder() async throws {
        let (road, _, _) = PlantedAccount.road()
        let (session, words) = try await road.created()
        let libraryID = try #require(session.library.record?.libraryID)
        let store = ThrowawayDefaults()
        defer { store.purge() }
        // Rule 3's schedule due (past the third launch), so the card's reminder row shows at this open.
        store.defaults.set(5, forKey: PassphraseReminderLedger.Key.launches(libraryID))
        let standing = RoadStandingModel.make(session, ledger: PassphraseReminderLedger(defaults: store.defaults))
        #expect(standing.offersSetPassphrase, "no passphrase yet — the row stands (P-2)")
        #expect(standing.reminder.showing != nil, "rule 3's reminder shows")

        // Turn on sync — the pane's press, on the OPEN session (a first device: the library's pair hands up, a NEW
        // passphrase typed twice because it has none).
        let read = try await PlantedAccount.read(session, PlantedAccount.signedIn)
        let open = try #require(ProtectionPaneRead.accountFaces(read)?.face(.turnOnSync).openDoor)
        let outcome = await ProtectionAccountRoad.press(
            session,
            request: RoadAccountRequest(
                door: .turnOnSync, shown: open, typed: TypedSecrets(words: words, newPassphrase: PlantedAccount.passphrase)),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        #expect(outcome == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        #expect(ProtectionOpenRoad.passphraseExists(session.library), "a passphrase exists now")

        // The pane's appearance — its one read.
        await standing.refreshPane()
        #expect(!standing.offersSetPassphrase, "VX-454: the set row retires — a passphrase exists")
        #expect(standing.reminder.showing == nil, "rule 3's reminder retires with it")
    }
}
