//
//  RoadKeyDoorRoadTests.swift
//  VariorumTests — VX-308 U3 piece 5: THE KEY DOORS (Change passphrase…, Reset forgotten passphrase…, New Words' face) over
//  the new road's PLANTED leaves (a real library on a temp slot, planted custody and memory, the planted vault — no
//  keychain, no network; headless in the implementer's harness too). The faces are `assess`'s doors over THE PANE'S ONE
//  READ (U1's R-2), each saying VX-263's one line; the press re-reads the door (VX-108), adopts the sign-in now (R-2) and
//  runs the core's act ON THE OPEN SESSION (no swap — the key doors re-lock the current key, rule 6); Castle's forgot road
//  takes the twelve words or a Touch ID PRESS (a read of this Mac's item); synced, the account's lock changes with the
//  library's (rule 7) and the refusals are the pane's (a follow owed, the vault out of reach, another account).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U3 — the key doors over planted leaves (no keychain, no network)")
@MainActor
struct RoadKeyDoorRoadTests {
    static let passphrase = "a passphrase of hers"

    static func faces(_ session: ProtectionRoadSession, _ signIn: SessionFact = .signedOut) async throws -> RoadKeyDoorFaces {
        try #require(await ProtectionKeyDoorRoad.read(session, signIn: signIn, exportSwitch: nil))
    }

    static func press(
        _ session: ProtectionRoadSession, _ door: RoadKeyDoor, signIn: SessionFact = .signedOut, current: String? = nil,
        new: String, words: [String]? = nil, touchID: Bool = false, shown: RoadKeyDoorOpen? = nil
    ) async throws -> RoadKeyDoorPress {
        let open: RoadKeyDoorOpen
        if let shown { open = shown } else { open = try #require(try await faces(session, signIn).face(door).openDoor) }
        return await ProtectionKeyDoorRoad.press(
            session, request: RoadKeyDoorRequest(
                door: door, shown: open, current: current, new: new, words: words, touchID: touchID),
            signIn: signIn, exportSwitch: nil)
    }

    /// A library with a passphrase (VX-306's set road — the reset door's plain confirm).
    static func withPassphrase(_ road: PlantedRoad) async throws -> (ProtectionRoadSession, [String]) {
        let (session, words) = try await road.created()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: passphrase) == .set)
        return (session, words)
    }

    /// A synced library (turning sync on hands the pair up — U1's road), the road's sign-in the account's.
    static func synced() async throws -> (PlantedRoad, PlantedVaultLeaf, ProtectionRoadSession, [String]) {
        let (road, vault, _) = PlantedAccount.road()
        let (session, words) = try await road.created()
        let shown = try #require(ProtectionPaneRead.accountFaces(
            try await PlantedAccount.read(session, PlantedAccount.signedIn))?.turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: shown, typed: TypedSecrets(words: words, newPassphrase: PlantedAccount.passphrase)),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        road.session = PlantedAccount.signedIn
        return (road, vault, session, words)
    }

    // MARK: - The faces

    /// No passphrase yet: the passphrase doors are not rendered (*Set a passphrase…* stands in their place); New Words
    /// stands with VX-263's line. With one: both doors, each saying VX-263's line; Standard's forgot road the plain confirm.
    @Test func thePassphraseDoorsStandOnlyWhereAPassphraseExistsEachSayingVX263sLine() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let none = try await Self.faces(session)
        #expect(none.changePassphrase == .hidden && none.resetForgottenPassphrase == .hidden)
        #expect(none.newWords.openDoor?.sentences == [ProtectionWords.keyDoorsLine])
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: Self.passphrase) == .set)
        let set = try await Self.faces(session)
        let change = try #require(set.changePassphrase.openDoor)
        #expect(change.sentences == [ProtectionWords.keyDoorsLine] && !change.synced && change.reset == nil)
        let reset = try #require(set.resetForgottenPassphrase.openDoor)
        #expect(reset.reset == .plainConfirm)
        #expect(reset.sentences == [ProtectionWords.keyDoorsLine, ProtectionWords.resetPassphraseStandardLead])
    }

    /// Castle's forgot road: the twelve words — and Touch ID only where this Mac has its item for the current key and a
    /// finger (the lead says which).
    @Test func castlesForgotRoadOffersTheWordsAndTouchIDWhereItsItemStands() async throws {
        let alwaysAsk = PlantedRoad()
        let (castle, _) = try await Crossing.inCastle(alwaysAsk)
        let plain = try #require(try await Self.faces(castle).resetForgottenPassphrase.openDoor)
        #expect(plain.reset == .wordsOrTouchID(touchID: false))
        #expect(plain.sentences.last == ProtectionWords.resetPassphraseCastleLead)

        let finger = PlantedRoad()
        finger.biometry = .ready
        let (session, words) = try await finger.created()
        _ = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        let touch = try #require(try await Self.faces(session).resetForgottenPassphrase.openDoor)
        #expect(touch.reset == .wordsOrTouchID(touchID: true))
        #expect(touch.sentences.last == ProtectionWords.resetPassphraseCastleTouchIDLead)
    }

    /// Rule 27's state (VX-447): the passphrase doors need the key file they re-lock — not rendered; New Words stands.
    @Test func withNoKeyFileAnywhereOnlyNewWordsStands() async throws {
        let road = PlantedRoad()
        _ = try await Self.withPassphrase(road)
        let session = try await NoKeyFileDoorTests.openedWithNoKeyFileAnywhere(road)
        let faces = try await Self.faces(session)
        #expect(faces.changePassphrase == .hidden && faces.resetForgottenPassphrase == .hidden)
        #expect(faces.newWords.openDoor != nil)
    }

    /// Synced: the passphrase doors say the account's passphrase changes with it (rule 7); the account moved elsewhere →
    /// every key door refuses in the pane's idiom (follow first); the vault out of reach → said; another account → said.
    @Test func syncedDoorsSayRule7AndRefuseInThePanesIdiom() async throws {
        let (road, vault, session, _) = try await Self.synced()
        defer { withExtendedLifetime(road) {} }  // the temp slot lives as long as the road
        let faces = try await Self.faces(session, PlantedAccount.signedIn)
        let change = try #require(faces.changePassphrase.openDoor)
        #expect(change.synced && change.sentences == [ProtectionWords.keyDoorsLine, ProtectionWords.keyDoorsSyncedPassphraseLine])
        #expect(faces.newWords.openDoor?.synced == true)

        vault.reachable = false
        let unreachable = try await Self.faces(session, PlantedAccount.signedIn)
        for door in RoadKeyDoor.allCases {
            #expect(unreachable.face(door) == .refused(ProtectionWords.doorRefusedNeedsVault), "\(door)")
        }
        vault.reachable = true
        let other = try await Self.faces(session, .signedIn(accountID: PlantedAccount.other, email: nil))
        for door in RoadKeyDoor.allCases {
            #expect(other.face(door) == .refused(ProtectionWords.doorRefusedOtherAccount), "\(door)")
        }
        vault.accounts[PlantedAccount.account]?.vault.mode = .castle  // another device entered Castle
        let moved = try await Self.faces(session, PlantedAccount.signedIn)
        for door in RoadKeyDoor.allCases {
            #expect(moved.face(door) == .refused(ProtectionWords.doorRefusedFollowOwed), "\(door)")
        }
        // …and a press of the door shown before the move refuses with the same sentence, nothing written.
        let before = try #require(try session.system.leaves.keyFiles.readLiveKeyFile())
        let press = try await Self.press(
            session, .changePassphrase, signIn: PlantedAccount.signedIn, current: PlantedAccount.passphrase,
            new: "another one", shown: change)
        #expect(press == .refused(ProtectionWords.doorRefusedFollowOwed))
        #expect(try session.system.leaves.keyFiles.readLiveKeyFile() == before)
    }

    // MARK: - The acts

    /// Change passphrase: the current one verified, the new one locks the CURRENT key (rule 6 — the key and its history
    /// unchanged); the old one no longer opens it. A wrong current passphrase refuses and writes nothing.
    @Test func changePassphraseReLocksTheCurrentKey() async throws {
        let road = PlantedRoad()
        let (session, _) = try await Self.withPassphrase(road)
        let before = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        let key = session.key
        #expect(try await Self.press(session, .changePassphrase, current: "not it", new: "x")
            == .refused(ProtectionWords.passphraseDoesNotOpen))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == before, "nothing written")
        let made = try await Self.press(session, .changePassphrase, current: Self.passphrase, new: "the new one")
        #expect(made == .made(ProtectionWords.changePassphraseReceipt))
        let after = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(session.key == key && after.fingerprint == before.fingerprint && after.history == before.history)
        #expect(try after.open(passphrase: .passphrase("the new one"), floor: .relaxedForTests) == key)
        #expect((try? after.open(passphrase: .passphrase(Self.passphrase), floor: .relaxedForTests)) == nil)
        #expect(after.words == before.words && after.apple == before.apple, "every other lock stays")
    }

    /// Standard's forgot road: the plain confirm (this Mac holds the key) — the new passphrase locks the current key.
    @Test func standardsResetIsThePlainConfirm() async throws {
        let road = PlantedRoad()
        let (session, _) = try await Self.withPassphrase(road)
        #expect(try await Self.press(session, .resetForgottenPassphrase, new: "chosen again")
            == .made(ProtectionWords.resetPassphraseReceipt))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?
            .open(passphrase: .passphrase("chosen again"), floor: .relaxedForTests) == session.key)
    }

    /// Castle's forgot road by the twelve words: wrong words refuse and write nothing; hers re-lock the current key.
    @Test func castlesResetTakesTheWords() async throws {
        let road = PlantedRoad()
        let (session, words) = try await Crossing.inCastle(road)
        let before = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try await Self.press(session, .resetForgottenPassphrase, new: "n", words: try RecoveryPhrase.generate())
            == .refused(ProtectionWords.wordsDoNotOpen))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == before)
        #expect(try await Self.press(session, .resetForgottenPassphrase, new: "set by the words", words: words)
            == .made(ProtectionWords.resetPassphraseReceipt))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?
            .open(passphrase: .passphrase("set by the words"), floor: .relaxedForTests) == session.key)
    }

    /// Castle's forgot road by Touch ID: the press is a READ of this Mac's item for the current key (it prompts); a press
    /// that confirms nothing refuses and writes nothing.
    @Test func castlesResetByTouchIDPressesTheItemFirst() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        let (session, words) = try await road.created()
        _ = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        let before = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        road.custody.unreadable = [session.library.fingerprint]
        #expect(try await Self.press(session, .resetForgottenPassphrase, new: "n", touchID: true)
            == .refused(ProtectionWords.resetPassphraseTouchIDNotConfirmed))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == before, "nothing written")
        road.custody.unreadable = []
        let reads = road.custody.reads.filter { $0 == .touchid }.count
        #expect(try await Self.press(session, .resetForgottenPassphrase, new: "by my finger", touchID: true)
            == .made(ProtectionWords.resetPassphraseReceipt))
        #expect(road.custody.reads.filter { $0 == .touchid }.count == reads + 1, "one press, at this door")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?
            .open(passphrase: .passphrase("by my finger"), floor: .relaxedForTests) == session.key)
    }

    /// VX-108: the door is RE-READ at the press — a door shown before the library entered Castle is re-shown (its forgot
    /// road is the words now), nothing written.
    @Test func vx108_theDoorIsReReadAtThePress() async throws {
        let road = PlantedRoad()
        let (session, words) = try await Self.withPassphrase(road)
        let shown = try #require(try await Self.faces(session).resetForgottenPassphrase.openDoor)
        _ = try await Crossing.press(session, .useCastle, typed: TypedSecrets(passphrase: Self.passphrase, words: words))
        let before = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        guard case .changed(let now) = try await Self.press(session, .resetForgottenPassphrase, new: "n", shown: shown) else {
            Issue.record("re-shown")
            return
        }
        #expect(now.reset == .wordsOrTouchID(touchID: false))
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == before)
    }

    /// RULE 7 synced: changing the passphrase changes the ACCOUNT's lock with the library's — the vault opens with the new
    /// passphrase and no longer with the old; the library's key file too.
    @Test func syncedChangeChangesTheAccountsPassphraseWithIt() async throws {
        let (road, vault, session, _) = try await Self.synced()
        // R-2: the executor carries a stale sign-in (an open made signed out) — the press adopts the sign-in NOW.
        session.executor.configuration.session = .signedOut
        let made = try await Self.press(
            session, .changePassphrase, signIn: PlantedAccount.signedIn, current: PlantedAccount.passphrase,
            new: "the account's new one")
        #expect(made == .made(ProtectionWords.changePassphraseReceipt))
        let account = try #require(vault.snapshot(PlantedAccount.account))
        let kdf = account.vault.kdf
        #expect(VaultModel.master(of: account.vault, passphrase: try PassphraseKey.derive("the account's new one", kdf: kdf),
                                  words: nil) != nil, "the account's lock is the new passphrase")
        #expect(VaultModel.master(of: account.vault, passphrase: try PassphraseKey.derive(PlantedAccount.passphrase, kdf: kdf),
                                  words: nil) == nil, "the old one no longer opens the account")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?
            .open(passphrase: .passphrase("the account's new one"), floor: .relaxedForTests) == session.key)
    }

    /// New Words is never pressed here (its door is the look's road).
    @Test func newWordsIsTheLooksRoadNeverThePress() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let shown = try #require(try await Self.faces(session).newWords.openDoor)
        let press = await ProtectionKeyDoorRoad.press(
            session, request: RoadKeyDoorRequest(door: .newWords, shown: shown, new: ""), signIn: .signedOut,
            exportSwitch: nil)
        #expect(press == .refused(ProtectionWords.crossingFailed))
    }
}
