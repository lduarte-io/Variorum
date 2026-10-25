//
//  PairPreflightAndGateTests.swift
//  VariorumTests — VX-529 unit 2, scope 5 (`notes/plans/fixes/vx-529-pair-catchup.md`): THE PREFLIGHT AND THE GATE say
//  what the account did. Over the new road's PLANTED leaves (no keychain, no network; headless in the implementer's SwiftPM
//  harness too).
//    - THE PREFLIGHT'S WORDS TWIN (bug-class, RED on the pre-fix tree): a re-keying follow's preflight
//      (`ProtectionAccountRoad.accountSecretRefusal` — it runs BEFORE the bootstrap closes anything and stands in for the
//      core's own check) said "Those twelve words don't open this library." for OLD words that DO open it after the
//      account's words were re-made on another device — the core's follow names the change since unit 1's P7-2
//      (`wordsChangedElsewhere`, VX-113's twin), so the preflight pre-empted the honest refusal with a false one.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 2 — the preflight and the gate name the account's change (planted, no keychain)")
@MainActor
struct PairPreflightAndGateTests {
    typealias Account = PlantedAccount

    /// The account's own pair (another device turned sync on first) and the words it re-makes later.
    static let accountWords = (try? RecoveryPhrase.generate()) ?? []
    static let newWords = (try? RecoveryPhrase.generate()) ?? []

    struct World {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let keys: PlantedSyncKeysLeaf
        let session: ProtectionRoadSession
        var accountKeys: AccountKeys
    }

    /// A Standard library joined to the planted account in its posture (the account's words AND passphrase typed).
    static func joinedWorld() async throws -> World {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (session, _) = try await road.created()
        let accountKeys = try vault.plant(
            accountID: Account.account, passphrase: Account.passphrase, words: accountWords, mode: .standard)
        let join = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let joined = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: join, typed: TypedSecrets(passphrase: Account.passphrase, words: accountWords)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(joined == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true))
        return World(road: road, vault: vault, keys: keys, session: session, accountKeys: accountKeys)
    }

    static func shown(_ world: World, _ door: RoadAccountDoor) async throws -> RoadAccountDoorOpen {
        let read = try await Account.read(world.session, Account.signedIn)
        let faces = try #require(ProtectionPaneRead.accountFaces(read, session: world.session))
        return try #require(faces.face(door).openDoor, "\(door): \(faces.face(door))")
    }

    /// THE PREFLIGHT'S WORDS TWIN (RED on old): the account entered Castle on another device under NEW twelve words; this
    /// library's OLD words still open it (its own key file — the master's words copy as it last knew it), not the account's
    /// vault. The follow into Castle's preflight names the change — the device and the day — exactly as the core's act
    /// would; nothing written. Words that open neither keep the plain refusal (a guard).
    @Test func theFollowsPreflightNamesAWordsChangeElsewhere() async throws {
        var world = try await Self.joinedWorld()
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.newWords)
        let live = try #require(world.session.library.keyFile)
        #expect(try live.open(.words(Self.accountWords), floor: .relaxedForTests) == world.session.key,
                "precondition: the old words open this library")
        let follow = try await Self.shown(world, .follow)
        #expect(follow.follow == .intoCastle && follow.rekeys, "precondition: the re-keying follow's preflight runs")
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let named = ProtectionWords.wordsChangedElsewhere(
            device: "Studio Mac", day: snapshot.updatedAt.map { ProtectionWords.day($0) })
        let bytes = try Plant.containerBytes(world.road)
        let old = await ProtectionAccountRoad.preflight(
            world.session, request: RoadAccountRequest(
                door: .follow, shown: follow, typed: TypedSecrets(words: Self.accountWords), gate: .alwaysAsk),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(old == .refused(named), "the old words name the change — never \"don't open this library\"")
        let nobodys = await ProtectionAccountRoad.preflight(
            world.session, request: RoadAccountRequest(
                door: .follow, shown: follow, typed: TypedSecrets(words: try RecoveryPhrase.generate()), gate: .alwaysAsk),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(nobodys == .refused(ProtectionWords.wordsDoNotOpen), "words that open neither: the plain refusal")
        #expect(try Plant.containerBytes(world.road) == bytes, "the preflight read only — nothing written")
        // The core's own act says the same (its check runs before its plan begins — nothing written).
        let executor = world.session.executor
        executor.configuration.session = Account.signedIn
        var library = world.session.library
        var thrown: (any Error)?
        do {
            _ = try await executor.follow(
                &library, kind: .intoCastle, typed: TypedSecrets(words: Self.accountWords), gate: .alwaysAsk)
        } catch {
            thrown = error
        }
        #expect(RoadAccountFaces.actRefusalSentence(try #require(thrown), unfinished: false) == named,
                "the preflight's sentence IS the act's")
    }

    /// Another device re-made the account's PASSPHRASE (a key door there: the vault's passphrase lock under a new
    /// descriptor, nothing else moved) — the planted vault written the way `VaultModel` writes it.
    static func passphraseChangedElsewhere(_ world: World, to passphrase: String, device: String = "Studio Mac") throws {
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        let fresh = try PassphraseKey.derive(passphrase, kdf: FastIDsLeaf().mintPassphraseKDF())
        var account = try #require(world.vault.accounts[Account.account])
        account.vault = try VaultModel.rewrappingPassphrase(snapshot.vault, master: master, passphrase: fresh, device: device)
        account.revision += 1
        account.updatedAt = (account.updatedAt ?? Date()).addingTimeInterval(3600)
        world.vault.accounts[Account.account] = account
    }

    /// THE GATE (R-529-3 — a design row; its face test): with the pair catch-up owed, the passphrase key doors refuse in
    /// their place with the pair's own sentence — what changed, on which device and day — and the road (the follow); the
    /// generic "Your account changed on another device. Follow it first." stays every other follow's.
    @Test func theKeyDoorsGateSaysThePairChangeAndPointsAtTheFollow() async throws {
        let world = try await Self.joinedWorld()
        try Self.passphraseChangedElsewhere(world, to: "a passphrase made elsewhere")
        let read = try await Account.read(world.session, Account.signedIn)
        let faces = try #require(ProtectionKeyDoorRoad.faces(read))
        let reading = try #require(read.facts.vault)
        let said = ProtectionWords.followFirstToCatchUp(
            .pairChanged(passphrase: true, words: false), device: "Studio Mac",
            day: reading.updatedAt.map { ProtectionWords.day($0) })
        #expect(said.hasPrefix(ProtectionWords.followNotice(
            .pairChanged(passphrase: true, words: false), device: "Studio Mac",
            day: reading.updatedAt.map { ProtectionWords.day($0) })))
        for door in [RoadKeyDoor.changePassphrase, .newWords, .resetForgottenPassphrase] {
            #expect(faces.face(door) == .refused(said), "\(door): \(faces.face(door))")
        }
        // Every other follow keeps the generic gate (a guard): the account entered Castle elsewhere.
        var moved = try await Self.joinedWorld()
        moved.accountKeys = try moved.vault.enterCastleElsewhere(
            Account.account, held: moved.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        let other = try #require(ProtectionKeyDoorRoad.faces(try await Account.read(moved.session, Account.signedIn)))
        #expect(other.face(.changePassphrase) == .refused(ProtectionWords.doorRefusedFollowOwed))
    }
}
