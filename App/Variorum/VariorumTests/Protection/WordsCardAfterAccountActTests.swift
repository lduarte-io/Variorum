//
//  WordsCardAfterAccountActTests.swift
//  VariorumTests — VX-510 unit B2, D-B6: VX-511 (R-510-14, her "Join retires the card (Recommended)"). Her Air report: after
//  her 0.10 crossing JOINED her account, the band card above the quick entry offered her twelve words again — and its look
//  mints FRESH words through rule 6's act, which on a synced library re-wraps the ACCOUNT's vault lock: pressing it would
//  have silently replaced her account's recovery words. The card's ledger was marked recorded by a look, Make this my
//  library's carry and the empty-slot landing — never by an account act. Now an account act that LANDS with the library
//  holding the account's pair marks the library's words recorded: Turn on sync's SET-UP arm (she typed the library's
//  twelve words at the confirm — rule 14's reminder; the pair is handed up as the account's, rule 7), its JOIN arm in either
//  posture (the library adopts the account's pair — rule 7), and Move. Settings ▸ New Words stays the deliberate door.
//  Over the bootstrap on the PLANTED road (unit A's `FirstRoundWorld`; no services needed — the card is the protection
//  faces'), also headless in the implementer's SwiftPM harness.
//    - the set-up, the Standard join, the Castle join, the re-keying join (through the reopen) and Move each leave the card
//      offering no words for the library they landed, its ledger recorded (RED on the pre-fix tree);
//    - guards: a refused act marks nothing (the card still offers); a leave marks nothing; another library's ledger is
//      untouched.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-511 (D-B6) — a landed account act retires the words card (planted road, the bootstrap)", .serialized)
@MainActor
struct WordsCardAfterAccountActTests {
    typealias Account = PlantedAccount

    static let accountWords = FirstRunDrillTests.accountWords

    /// The test bootstrap's words ledger (its calm-asks defaults — a named test suite, never the app's).
    static var ledger: WordsCardLedger {
        WordsCardLedger(defaults: UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard)
    }

    static func libraryID(_ world: FirstRoundWorld) throws -> String {
        try #require(world.bootstrap.roadSession?.library.record?.libraryID)
    }

    static func band(_ world: FirstRoundWorld) throws -> WordsBandModel {
        try #require(world.bootstrap.roadStanding?.band, "the open library's card")
    }

    /// Before the act: a fresh library's words were never recorded — the card offers them.
    static func expectOffering(_ world: FirstRoundWorld) throws {
        let id = try Self.libraryID(world)
        #expect(!Self.ledger.recorded(id) && !Self.ledger.dismissed(id), "precondition: nothing recorded")
        #expect(try Self.band(world).offersWords, "precondition: the card offers the words")
    }

    /// After a landed act: the card offers no words for the library the act landed, and its ledger says recorded (so the
    /// card a later open builds offers none either).
    static func expectRetired(_ world: FirstRoundWorld, _ door: RoadAccountDoor) throws {
        let id = try Self.libraryID(world)
        #expect(Self.ledger.recorded(id), "\(door): the library's words are recorded")
        #expect(try !Self.band(world).offersWords, "\(door): the card offers no look that would replace the account's words")
        #expect(!Self.ledger.dismissed(id), "\(door): recorded, never dismissed (the toast's road is hers)")
    }

    // MARK: - The landings (RED on the pre-fix tree)

    /// THE SET-UP ARM: she typed the library's twelve words at the confirm, and the pair became the account's.
    @Test func vx511_theSetUpRetiresTheCard() async throws {
        try await FirstRoundWorld.run { world in
            try Self.expectOffering(world)
            let other = "another-library-\(UUID().uuidString)"
            _ = try await FirstRunDrillTests.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words,
                expecting: .setsUpInLibrarysMode)
            try Self.expectRetired(world, .turnOnSync)
            #expect(!Self.ledger.recorded(other), "another library's ledger untouched")
        }
    }

    /// THE STANDARD JOIN (the passphrase typed — the library adopts the account's pair; rule 7).
    @Test func vx511_aStandardJoinRetiresTheCard() async throws {
        try await FirstRoundWorld.run { world in
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
            try Self.expectOffering(world)
            _ = try await FirstRunDrillTests.press(world, passphrase: Account.passphrase, expecting: .sameMode)
            try Self.expectRetired(world, .turnOnSync)
        }
    }

    /// THE CASTLE JOIN, same posture, on the open session — the account's words typed.
    @Test func vx511_aCastleJoinRetiresTheCard() async throws {
        try await FirstRoundWorld.run { world in
            try await world.useCastle(gate: .alwaysAsk)
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .castle)
            try Self.expectOffering(world)
            _ = try await FirstRunDrillTests.press(world, words: Self.accountWords, expecting: .sameMode)
            try Self.expectRetired(world, .turnOnSync)
        }
    }

    /// THE RE-KEYING JOIN (a Standard library joins an account in Castle — through the reopen): the card the REOPENED
    /// library shows offers no words, and the library the reopen landed is the one recorded.
    @Test func vx511_aReKeyingJoinRetiresTheReopenedLibrarysCard() async throws {
        try await FirstRoundWorld.run { world in
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .castle)
            try Self.expectOffering(world)
            let before = try Self.libraryID(world)
            let bandBefore = try Self.band(world)
            _ = try await FirstRunDrillTests.press(
                world, passphrase: Account.passphrase, gate: .alwaysAsk, expecting: .entersCastle)
            #expect(world.bootstrap.roadSession?.library.record?.mode == .castle, "the reopen landed in Castle")
            #expect(try Self.band(world) !== bandBefore, "precondition: the reopen built the card anew")
            try Self.expectRetired(world, .turnOnSync)
            let after = try Self.libraryID(world)
            if after != before { #expect(!Self.ledger.recorded(before), "the outgoing id is not the one recorded") }
        }
    }

    /// MOVE (a library syncing with another account moves to the one signed in — rule 16's leave, then rule 7's adoption).
    @Test func vx511_moveRetiresTheCard() async throws {
        let other = SessionFact.signedIn(accountID: Account.other, email: "other@example.test")
        try await FirstRoundWorld.run(prepare: { _, vault, session, words in
            let read = try #require(await ProtectionPaneRead.read(session, signIn: other, exportSwitch: nil))
            let setUp = try #require(ProtectionPaneRead.accountFaces(read, session: session)?.turnOnSync.openDoor)
            let made = await ProtectionAccountRoad.press(
                session, request: RoadAccountRequest(
                    door: .turnOnSync, shown: setUp, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
                signIn: other, exportSwitch: nil)
            #expect(made == .made(receipt: ProtectionWords.turnOnSyncReceipt))
            try vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
        }) { world in
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.other)
            try Self.expectOffering(world)
            _ = try await FirstRunDrillTests.press(
                world, .moveToSignedInAccount, passphrase: Account.passphrase, expecting: .sameMode)
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account)
            try Self.expectRetired(world, .moveToSignedInAccount)
        }
    }

    // MARK: - Guards (green on both sides by design)

    /// A REFUSED act marks nothing: a join with a passphrase that is not the account's — the card still offers.
    @Test func aRefusedActMarksNothing() async throws {
        try await FirstRoundWorld.run { world in
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
            try Self.expectOffering(world)
            let account = try #require(world.bootstrap.roadAccount)
            await account.refresh()
            account.open(.turnOnSync)
            let confirm = try #require(account.confirm)
            await confirm.submit(passphrase: "not the account's passphrase")
            #expect(confirm.refusal != nil, "the act refused")
            #expect(world.bootstrap.roadSession?.library.record?.account == nil, "nothing landed")
            #expect(!Self.ledger.recorded(try Self.libraryID(world)), "a refused act marks nothing")
            #expect(try Self.band(world).offersWords, "the card still offers")
            confirm.cancel()
        }
    }

    /// A LEAVE marks nothing: a library bound before this open (its words never recorded here) stops syncing — the card
    /// still offers (rule 16 changes none of the library's keys or secrets).
    @Test func aLeaveMarksNothing() async throws {
        try await FirstRoundWorld.run(prepare: { _, _, session, words in
            let read = try #require(await ProtectionPaneRead.read(session, signIn: Account.signedIn, exportSwitch: nil))
            let setUp = try #require(ProtectionPaneRead.accountFaces(read, session: session)?.turnOnSync.openDoor)
            let made = await ProtectionAccountRoad.press(
                session, request: RoadAccountRequest(
                    door: .turnOnSync, shown: setUp, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
                signIn: Account.signedIn, exportSwitch: nil)
            #expect(made == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        }) { world in
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account)
            try Self.expectOffering(world)
            _ = try await FirstRunDrillTests.press(world, .stopSyncingHere)
            #expect(world.bootstrap.roadSession?.library.record?.account == nil, "the library left the account")
            #expect(!Self.ledger.recorded(try Self.libraryID(world)), "a leave marks nothing")
            #expect(try Self.band(world).offersWords, "the card still offers")
        }
    }
}
