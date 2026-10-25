//
//  E6BandCardTests.swift
//  VariorumTests — VX-529 unit 3, the rider VX-538 (her R-529-6, verbatim in the run record: "maybe make sure that that's
//  clearly expressed … I honestly feel like maybe it should be a recurrent notification until it's done … I do think we
//  should make it clear it's not the 'ideal' state for users and encourage them to resolve it. they can still change their
//  passphrase if they forgot it."): THE E6 STATE — a SYNCED library whose live key file carries NO passphrase lock of its
//  own (joined by the twelve words, or the catch-up's words arm) — surfaces in the band card's one home above the quick
//  entry, with the why and the road, recurring until it's done, retiring itself the moment a passphrase lock lands.
//  F-U2-6 is its reason: a Standard E6 library whose quiet roads work never meets a lobby, so the card is its one surface.
//  THE PIN (red on the pre-fix tree, compiling there): an open E6 library at its third launch hears nothing — the band
//  stays empty (the words recorded by the join, rule 3's reminder silent for a synced library). Planted leaves (no keychain,
//  the planted vault — no network); headless in the implementer's harness too.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 3 — VX-538: the E6 band card (planted, no keychain)", .serialized)
@MainActor
struct E6BandCardTests {
    typealias Account = PlantedAccount

    /// An OPEN library created here (no passphrase yet) that JOINED an account already syncing, by its twelve words — E6
    /// by birth: no passphrase lock of its own, the account's master with its words copy. The bootstrap's VX-511 mark
    /// (the words are the account's — recorded) is made as the landing makes it.
    static func e6Open() async throws -> (road: PlantedRoad, vault: PlantedVaultLeaf, session: ProtectionRoadSession,
                                          words: [String]) {
        let (road, vault, _) = Account.road()
        road.session = Account.signedIn
        let (session, _) = try await road.created()
        let accountWords = try RecoveryPhrase.generate()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase, words: accountWords, mode: .standard)
        let join = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let joined = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(door: .turnOnSync, shown: join, typed: TypedSecrets(words: accountWords)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(joined == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true))
        let live = try #require(session.library.keyFile)
        #expect(live.passphrase == nil && live.master != nil && session.library.record?.account == Account.account,
                "precondition: E6")
        return (road, vault, session, accountWords)
    }

    /// This Mac's calm-asks ledger at the library's THIRD launch (rule 3's first showing): two launches noted, the third
    /// counted by the faces' make; the join's VX-511 mark made.
    static func ledgerAtTheThirdLaunch(_ session: ProtectionRoadSession, _ store: ThrowawayDefaults) throws
        -> PassphraseReminderLedger {
        let libraryID = try #require(session.library.record?.libraryID)
        let ledger = PassphraseReminderLedger(defaults: store.defaults)
        ledger.noteLaunch(libraryID)
        ledger.noteLaunch(libraryID)
        WordsCardLedger(defaults: store.defaults).record(libraryID)
        return ledger
    }

    /// **THE PIN (red on old).** An open E6 library at its third launch: the band card is ON SCREEN — the one home says the
    /// state is not the ideal one.
    @Test func anE6LibraryHearsTheBandCardAtItsThirdLaunch() async throws {
        let (_, _, session, _) = try await Self.e6Open()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(session, ledger: try Self.ledgerAtTheThirdLaunch(session, store))
        let band = try #require(standing.band)
        #expect(!band.offersWords && !band.showsReminder, "the words recorded by the join; rule 3 silent (synced)")
        #expect(band.visible, "E6 surfaces in the band — the why and the road")
    }

    /// A guard (green on both sides): a synced library WITH its passphrase lock (it typed the account's passphrase) hears
    /// nothing — no E6, no card.
    @Test func aSyncedLibraryWithItsPassphraseLockHearsNothing() async throws {
        let (road, _, _) = Account.road()
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        let turnOn = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: turnOn, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        #expect(session.library.keyFile?.passphrase != nil)
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(session, ledger: try Self.ledgerAtTheThirdLaunch(session, store))
        #expect(standing.band?.visible == false)
    }
}
