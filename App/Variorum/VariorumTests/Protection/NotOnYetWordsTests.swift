//
//  NotOnYetWordsTests.swift
//  VariorumTests — VX-510 unit A (VX-506, riding): "sync shouldn't seem like you're restarting it." Two faces said a lock
//  or a restart where there is only a not-yet:
//    - Settings ▸ Protection's door over the JOIN arm (the signed-in account already syncs — its vault exists) read "Turn on
//      sync…", the set-up arm's own name, for an account that is already on (her words: "should that not be sign into sync
//      instead of turn on?"). The join arm's door gets its own label; the set-up arm keeps "Turn on sync…". RED on old.
//  Words PROVISIONAL, hers (the run record's OPEN ITEMS, P-VX510-3 (a) built). Over the planted road (no keychain, the
//  planted vault — no network); also runs headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-510 unit A — the not-yet words (VX-506)")
@MainActor
struct NotOnYetWordsTests {
    typealias Account = PlantedAccount

    /// **VX-506 — THE JOIN ARM'S DOOR (red on old: it wore "Turn on sync…", the set-up arm's name).** With no vault on the
    /// signed-in account the door is the set-up — "Turn on sync…"; once the account syncs (another device turned it on) the
    /// same door is the JOIN and says so in its own words, in every posture the join can take.
    @Test(arguments: [ProtectionMode.standard, .castle])
    func theJoinArmsDoorHasItsOwnLabel(_ accountMode: ProtectionMode) async throws {
        let (road, vault, _) = Account.road()
        let (session, _) = try await road.created()
        let setUp = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(setUp.spec.join == .setsUpInLibrarysMode, "no vault yet — the set-up arm")
        #expect(setUp.doorLabel == "Turn on sync\u{2026}", "the set-up arm keeps its name")

        try vault.plant(
            accountID: Account.account, passphrase: "another device's", words: try RecoveryPhrase.generate(),
            mode: accountMode)
        let join = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(join.spec.join != nil && join.spec.join != .setsUpInLibrarysMode, "the account syncs — the join arm")
        #expect(join.doorLabel == "Sync this library\u{2026}", "the join's own door (PROVISIONAL, hers)")
        #expect(join.doorLabel != setUp.doorLabel, "never the set-up arm's name over the join")
    }
}
