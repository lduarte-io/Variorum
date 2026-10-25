//
//  JoinSheetWordsTests.swift
//  VariorumTests — VX-529 unit 3, the rider VX-526 (the VX-510 walk's W-11 + W-12): THE JOIN SHEET'S WORDS.
//    - W-11: Settings ▸ Protection's door over the JOIN arm reads "Sync this library…" (VX-506), but the sheet it opens
//      still TITLES itself and its button "Turn on sync" — the set-up arm's name, for an account that is already on
//      (P-VX510-A4). The sheet's title and button follow the door's own name; the set-up arm keeps "Turn on sync".
//    - W-12: the words moment after a passphrase-typed join says "your previous twelve words still open backups you made
//      before today" — imprecise: a backup made EARLIER TODAY, before the join, opens with the previous words too. The
//      honest floor is CastleRules rule 5's: a backup opens with the words you had when you made it.
//  RED on the pre-fix tree (the title and button "Turn on sync"; the notice "before today"). Words PROVISIONAL, hers.
//  Over the planted road (no keychain, the planted vault — no network); also runs headless in the implementer's harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 3 — VX-526: the join sheet's words")
@MainActor
struct JoinSheetWordsTests {
    typealias Account = PlantedAccount

    /// **W-11 (red on old: "Turn on sync").** The set-up arm's sheet keeps its name; once the account syncs (another device
    /// turned it on) the same door is the JOIN — its sheet's title and button say the join's own words, in every posture
    /// the join can take, and never the set-up arm's.
    @Test(arguments: [ProtectionMode.standard, .castle])
    func theJoinSheetsTitleAndButtonFollowItsDoor(_ accountMode: ProtectionMode) async throws {
        let (road, vault, _) = Account.road()
        let (session, _) = try await road.created()
        let setUp = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(setUp.spec.join == .setsUpInLibrarysMode, "no vault yet — the set-up arm")
        let setUpSheet = RoadAccountConfirmModel(door: setUp, act: { _ in .refused("unused") }, finished: { _ in })
        #expect(setUpSheet.title == "Turn on sync" && setUpSheet.button == "Turn on sync",
                "the set-up arm keeps its name — door, title and button")

        try vault.plant(
            accountID: Account.account, passphrase: "another device's", words: try RecoveryPhrase.generate(),
            mode: accountMode)
        let join = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(join.spec.join != nil && join.spec.join != .setsUpInLibrarysMode, "the account syncs — the join arm")
        let joinSheet = RoadAccountConfirmModel(door: join, act: { _ in .refused("unused") }, finished: { _ in })
        #expect(join.doorLabel == "Sync this library\u{2026}", "the door (VX-506)")
        #expect(joinSheet.title == "Sync this library", "the sheet's title follows its door (PROVISIONAL, hers)")
        #expect(joinSheet.button == "Sync this library", "the sheet's button follows its door (PROVISIONAL, hers)")
        #expect(joinSheet.title != setUpSheet.title && joinSheet.button != setUpSheet.button,
                "never the set-up arm's name over the join")
    }

    /// Move keeps its own sheet (it names the account signed in) — the join arm's words are the Turn-on-sync door's only.
    @Test func moveKeepsItsOwnSheet() {
        let spec = DoorSpec(requires: .oneSecret, synced: true, join: .sameMode)
        let move = RoadAccountDoorOpen(
            door: .moveToSignedInAccount, ask: .oneSecret, newPassphrase: false, sentences: [], spec: spec)
        let sheet = RoadAccountConfirmModel(door: move, act: { _ in .refused("unused") }, finished: { _ in })
        #expect(sheet.title == ProtectionWords.moveTitle && sheet.button == ProtectionWords.moveButton)
    }

    /// **W-12 (red on old: "before today").** The passphrase-typed words moment says the honest floor — the previous words
    /// open the backups made WITH them (rule 5) — and never a day boundary the floor doesn't have.
    @Test func thePassphraseArmsWordsSayTheHonestFloor() {
        for email in ["lillian@example.test", nil] as [String?] {
            let moment = ProtectionWords.joinWordsNotShown(email)
            #expect(!moment.contains("before today"), "no day boundary: \(moment)")
            #expect(moment.contains("Your previous twelve words still open backups made with them."),
                    "rule 5's floor (PROVISIONAL, hers): \(moment)")
        }
    }
}
