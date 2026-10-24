//
//  ProtectionJoinFollowRoadTests.swift
//  VariorumTests — VX-308 U2 piece 3: THE JOIN AND THE FOLLOW over the new road's PLANTED leaves — a real library on the
//  planted road, the planted vault (the core `ExecutorVault`'s semantics, no network) and planted sync keys; the account's
//  other device is the planted vault written the way the core's `VaultModel` writes it (an entry into Castle — a new
//  master and sync key; a leave — the mode flag). Also runs headless in the implementer's SwiftPM harness. The bootstrap's
//  seam around the re-keying acts (the pool closed, the reopen) is the Mac route suite's; here the preflight and the act
//  run as the seam runs them, with no pool to close.
//
//  THE JOIN (rules 7, 14): one of the account's secrets; the account's pair adopted (the words replaced — rule 7's
//  notice); into a Castle account it enters Castle (rule 11 around it — the export notice), out of one it leaves.
//  MOVE (rules 16, 7). THE FOLLOW (rules 10, 12, 15): into Castle with one secret and the gate, out of it quietly, on a
//  replaced key with one secret; VX-113 — the old passphrase after a change elsewhere names the device and the day, and the
//  preflight says exactly what the core's act would; VX-107 — a follow crashed past its swap, twice, says its Done with its
//  other-device sentence at the open whose settle finishes it, read from durable facts.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

extension PlantedVaultLeaf {
    /// The account's OTHER device enters Castle (rule 11, rule 15 — `VaultModel.enteringCastle`: a new master and sync key,
    /// the earlier keys carried) under `passphrase` — a NEW descriptor when `newPassphraseLock` (a passphrase changed there
    /// too, VX-113's world). Returns the account's new keys.
    @discardableResult
    func enterCastleElsewhere(
        _ accountID: String, held: AccountKeys, passphrase: String, words: [String], newPassphraseLock: Bool = false,
        device: String = "Studio Mac"
    ) throws -> AccountKeys {
        let account = try #require(accounts[accountID])
        let kdf = newPassphraseLock ? FastIDsLeaf().mintPassphraseKDF() : account.vault.kdf
        let (next, keys) = try VaultModel.enteringCastle(
            account.vault, held: held, passphrase: try PassphraseKey.derive(passphrase, kdf: kdf),
            words: try WordsKey.derive(words), device: device, ids: FastIDsLeaf())
        clock += 3600
        accounts[accountID] = Account(revision: account.revision + 1, vault: next, updatedAt: clock)
        return keys
    }

    /// The account's other device leaves Castle (rule 12 — the mode flag; no key changes).
    func leaveCastleElsewhere(_ accountID: String, device: String = "Studio Mac") throws {
        let account = try #require(accounts[accountID])
        clock += 3600
        accounts[accountID] = Account(
            revision: account.revision + 1, vault: VaultModel.leavingCastle(account.vault, device: device), updatedAt: clock)
    }
}

@Suite("VX-308 U2 — the join and the follow over planted leaves (no network)")
@MainActor
struct ProtectionJoinFollowRoadTests {
    typealias Account = PlantedAccount

    /// The account's own pair (another device turned sync on first).
    static let accountWords = (try? RecoveryPhrase.generate()) ?? []

    struct World {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let keys: PlantedSyncKeysLeaf
        let session: ProtectionRoadSession
        /// The library's own words (its creation's).
        let words: [String]
        /// The account's keys as the vault holds them now.
        var accountKeys: AccountKeys
    }

    /// A library on the planted road (Standard — or Castle, entered locally under Always ask), and an account that
    /// already syncs, in `mode`, under the account's pair.
    private func world(
        library castle: Bool = false, account mode: ProtectionMode, biometry: BiometryFacts = .none
    ) async throws -> World {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        road.biometry = biometry
        let (session, words): (ProtectionRoadSession, [String])
        if castle {
            (session, words) = try await Crossing.inCastle(road)
        } else {
            (session, words) = try await road.created()
        }
        let accountKeys = try vault.plant(
            accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: mode)
        return World(road: road, vault: vault, keys: keys, session: session, words: words, accountKeys: accountKeys)
    }

    private func shown(
        _ world: World, _ door: RoadAccountDoor, _ signIn: SessionFact = Account.signedIn, exports: PlantedExportSwitch? = nil
    ) async throws -> RoadAccountDoorOpen {
        let read = try #require(await ProtectionPaneRead.read(world.session, signIn: signIn, exportSwitch: exports?.road))
        let faces = try #require(ProtectionPaneRead.accountFaces(read, session: world.session))
        return try #require(faces.face(door).openDoor, "\(door): \(faces.face(door))")
    }

    /// The press as the bootstrap runs it: an open-session door through `press`; a re-keying door through the seam's
    /// preflight then `perform` (no pool here to close).
    private func press(
        _ world: World, _ door: RoadAccountDoor, typed: TypedSecrets, gate: GateStyle? = nil,
        exports: PlantedExportSwitch? = nil, signIn: SessionFact = Account.signedIn
    ) async throws -> AccountActResult {
        let open = try await shown(world, door, signIn, exports: exports)
        let request = RoadAccountRequest(door: door, shown: open, typed: typed, gate: gate)
        guard open.rekeys else {
            let press = await ProtectionAccountRoad.press(
                world.session, request: request, signIn: signIn, exportSwitch: exports?.road)
            return AccountActResult(press: press, reopenKey: world.session.key, landedWhole: true)
        }
        let preflight = await ProtectionAccountRoad.preflight(
            world.session, request: request, signIn: signIn, exportSwitch: exports?.road)
        guard preflight == .ready else {
            if case .refused(let sentence) = preflight {
                return AccountActResult(press: .refused(sentence), reopenKey: world.session.key, landedWhole: false)
            }
            Issue.record("the preflight: \(preflight)")
            return AccountActResult(press: .refused("preflight"), reopenKey: world.session.key, landedWhole: false)
        }
        #expect(world.session.beginAct())
        defer { world.session.endAct() }
        return await ProtectionAccountRoad.perform(world.session, request: request, signIn: signIn, exportSwitch: exports?.road)
    }

    /// A library bound to the account in its posture (a same-posture join typing the account's words AND passphrase).
    private func joined(_ world: World) async throws {
        let result = try await press(
            world, .turnOnSync, typed: TypedSecrets(passphrase: Account.passphrase, words: Self.accountWords))
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true))
        #expect(world.session.library.record?.account == Account.account)
    }

    // MARK: - The join (rules 7, 14)

    /// THE SAME POSTURE, the words typed: the account's pair adopted (its words open the library now, the library's own
    /// don't), the key unchanged, the vault untouched, the sync keys held the Standard way — and rule 7's words moment owed.
    @Test func aSamePostureJoinAdoptsTheAccountsPairAndKeepsTheKey() async throws {
        let world = try await world(account: .standard)
        let before = world.session.library
        let result = try await press(world, .turnOnSync, typed: TypedSecrets(words: Self.accountWords))
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true))
        let after = world.session.library
        #expect(after.record?.account == Account.account && after.fingerprint == before.fingerprint, "the key unchanged")
        let live = try #require(after.keyFile)
        #expect(try live.open(.words(Self.accountWords), floor: .relaxedForTests) == after.key, "the account's words open it")
        #expect((try? live.open(.words(world.words), floor: .relaxedForTests)) == nil, "its own words don't any more")
        #expect(!world.vault.calls.contains { $0.hasPrefix("update") || $0.hasPrefix("create") }, "the vault untouched")
        #expect(world.keys.items.keys.contains(SyncKeysItemFact(accountID: Account.account, itemClass: .silent)))
    }

    /// THE SAME POSTURE, the PASSPHRASE typed: the words are still replaced (the account's master with its words copy opens
    /// the file) — the moment owed, with nothing to show (P-VX378-U2-3 (a)).
    @Test func aPassphraseTypedJoinStillReplacesTheWords() async throws {
        let world = try await world(account: .standard)
        let result = try await press(world, .turnOnSync, typed: TypedSecrets(passphrase: Account.passphrase))
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true))
        let live = try #require(world.session.library.keyFile)
        #expect(try live.open(.words(Self.accountWords), floor: .relaxedForTests) == world.session.key)
        #expect((try? live.open(.words(world.words), floor: .relaxedForTests)) == nil)
    }

    /// VX-309 U2 — VX-456 OVER THE PLANTED ROAD (red on old): joined by the passphrase, Stop syncing here (rule 16 — no key,
    /// lock or secret changes), then signing back in is a join by the passphrase again — the library's words already ARE the
    /// account's (no own words lock; its master's copy is the vault's recovery wrap), so no moment is owed. And the join's
    /// door carries the account's email for her draft's sentence.
    @Test func vx456_aRejoinWhoseWordsAreAlreadyTheAccountsOwesNoMoment() async throws {
        let world = try await world(account: .standard)
        let door = try await shown(world, .turnOnSync)
        #expect(door.accountEmail == PlantedAccount.email, "her draft names the account by its email")
        let first = try await press(world, .turnOnSync, typed: TypedSecrets(passphrase: Account.passphrase))
        #expect(first.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: true),
                "the library's own words were replaced — said")
        let left = try await press(world, .stopSyncingHere, typed: .none)
        #expect(left.press == .made(receipt: ProtectionWords.stopSyncingReceipt, wordsReplaced: false))
        #expect(world.session.library.record?.account == nil)
        let again = try await press(world, .turnOnSync, typed: TypedSecrets(passphrase: Account.passphrase))
        #expect(again.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: false), wordsReplaced: false),
                "the words were the account's already — no moment")
        #expect(world.session.library.record?.account == Account.account)
    }

    /// A wrong secret is refused in the act's own words, nothing written (the same posture, the open session). VX-464
    /// (W-VX309-3): the secret a join types is the ACCOUNT's (rule 14 — it is checked against the vault), so the refusal
    /// names the account, never "this library" (FLIPPED DELIBERATELY at VX-329 R1: the old pin held the mis-aimed line).
    @Test func aWrongSecretWritesNothing() async throws {
        let world = try await world(account: .standard)
        let before = try Plant.containerBytes(world.road)
        let wrong = try await press(world, .turnOnSync, typed: TypedSecrets(passphrase: "not it"))
        #expect(wrong.press == .refused(ProtectionWords.passphraseDoesNotOpenAccount))
        let words = try await press(world, .turnOnSync, typed: TypedSecrets(words: try RecoveryPhrase.generate()))
        #expect(words.press == .refused(ProtectionWords.wordsDoNotOpenAccount))
        #expect(try Plant.containerBytes(world.road) == before && world.session.library.record?.account == nil)
    }

    /// INTO A CASTLE ACCOUNT the join enters Castle (rule 11 — one posture at a time): a new Castle key carrying the old one,
    /// no silent item, this Mac's Apple key retired, the scheduled export off with rule 11's notice owed; a typo at the
    /// preflight tears nothing down.
    @Test func aJoinIntoACastleAccountEntersCastle() async throws {
        let world = try await world(account: .castle)
        let before = world.session.library
        let libraryID = try #require(before.record?.libraryID)
        let bytes = try Plant.containerBytes(world.road)
        // R-U2-3: the PREFLIGHT itself refuses a typo against the vault — before the bootstrap would close anything.
        let shownJoin = try await shown(world, .turnOnSync)
        // VX-464: the account's secret's refusal names the account (FLIPPED DELIBERATELY at VX-329 R1).
        for (typed, said) in [(TypedSecrets(passphrase: "not it"), ProtectionWords.passphraseDoesNotOpenAccount),
                              (TypedSecrets(words: try RecoveryPhrase.generate()), ProtectionWords.wordsDoNotOpenAccount),
                              (TypedSecrets.none, ProtectionWords.crossingSecretsMissing)] {
            let preflight = await ProtectionAccountRoad.preflight(
                world.session, request: RoadAccountRequest(door: .turnOnSync, shown: shownJoin, typed: typed, gate: .alwaysAsk),
                signIn: Account.signedIn, exportSwitch: nil)
            #expect(preflight == .refused(said))
        }
        #expect(try Plant.containerBytes(world.road) == bytes, "the preflight read only — nothing written")
        let exports = PlantedExportSwitch(true)
        let result = try await press(
            world, .turnOnSync, typed: TypedSecrets(words: Self.accountWords), gate: .alwaysAsk, exports: exports)
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.entersCastle, moved: false), wordsReplaced: true))
        #expect(result.landedWhole && result.reopenKey == world.session.key && world.session.key != before.key)
        let after = world.session.library
        #expect(after.record?.mode == .castle && after.record?.account == Account.account)
        #expect(after.keyFile?.heldFingerprints.contains(before.fingerprint) == true, "rule 4: the history carries it")
        #expect(after.keyFile?.apple == nil && Crossing.items(world.road, .silent).isEmpty)
        #expect(try world.road.apple.appleKeyIDs(ofLibrary: libraryID).isEmpty, "this Mac's Apple key retired")
        #expect(!exports.value && exports.noticeOwed, "rule 11: the export off, its notice owed")
    }

    /// OUT OF CASTLE into a Standard account the join leaves Castle (rule 12): a new Standard key carrying the Castle one,
    /// the on-device road and a fresh Apple road back.
    @Test func aJoinIntoAStandardAccountLeavesCastle() async throws {
        let world = try await world(library: true, account: .standard)
        let castle = world.session.library.fingerprint
        let result = try await press(world, .turnOnSync, typed: TypedSecrets(passphrase: Account.passphrase))
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.leavesCastle, moved: false), wordsReplaced: true))
        let after = world.session.library
        #expect(after.record?.mode == .standard && after.keyFile?.heldFingerprints.contains(castle) == true)
        #expect(Crossing.items(world.road, .silent) == [after.fingerprint] && after.keyFile?.apple != nil)
    }

    /// MOVE (rule 16 then rule 7): bound to another account, the one signed in already syncs — the library now names it,
    /// the old account's sync keys forgotten; its key unchanged in the same posture.
    @Test func moveLeavesTheOldAccountAndJoinsTheSignedInOne() async throws {
        let world = try await world(account: .standard)
        let other = SessionFact.signedIn(accountID: Account.other, email: "other@example.test")
        let setUp = try await shown(world, .turnOnSync, other)
        _ = await ProtectionAccountRoad.press(
            world.session, request: RoadAccountRequest(
                door: .turnOnSync, shown: setUp, typed: TypedSecrets(words: world.words, newPassphrase: "own passphrase")),
            signIn: other, exportSwitch: nil)
        #expect(world.session.library.record?.account == Account.other)
        let key = world.session.key
        let result = try await press(world, .moveToSignedInAccount, typed: TypedSecrets(words: Self.accountWords))
        #expect(result.press == .made(receipt: ProtectionWords.joinedReceipt(.sameMode, moved: true), wordsReplaced: true))
        #expect(world.session.library.record?.account == Account.account && world.session.key == key)
        #expect(!world.keys.accountsHeld.contains(Account.other), "this Mac forgets the old account's sync keys")
    }

    /// VX-464 — MOVE types the signed-in ACCOUNT's secret (rule 14): a wrong one is refused naming the account, on the
    /// open session's road (`press` → the core's act) and on the re-keying seam's (`preflight`) alike; nothing written.
    @Test func vx464_aWrongSecretAtMoveNamesTheAccount() async throws {
        let world = try await world(account: .standard)
        let other = SessionFact.signedIn(accountID: Account.other, email: "other@example.test")
        let setUp = try await shown(world, .turnOnSync, other)
        _ = await ProtectionAccountRoad.press(
            world.session, request: RoadAccountRequest(
                door: .turnOnSync, shown: setUp, typed: TypedSecrets(words: world.words, newPassphrase: "own passphrase")),
            signIn: other, exportSwitch: nil)
        #expect(world.session.library.record?.account == Account.other)
        let before = try Plant.containerBytes(world.road)
        let wrong = try await press(world, .moveToSignedInAccount, typed: TypedSecrets(passphrase: "not it"))
        #expect(wrong.press == .refused(ProtectionWords.passphraseDoesNotOpenAccount))
        let words = try await press(world, .moveToSignedInAccount, typed: TypedSecrets(words: try RecoveryPhrase.generate()))
        #expect(words.press == .refused(ProtectionWords.wordsDoNotOpenAccount))
        let shownMove = try await shown(world, .moveToSignedInAccount)
        for (typed, said) in [(TypedSecrets(passphrase: "not it"), ProtectionWords.passphraseDoesNotOpenAccount),
                              (TypedSecrets(words: try RecoveryPhrase.generate()), ProtectionWords.wordsDoNotOpenAccount)] {
            let preflight = await ProtectionAccountRoad.preflight(
                world.session, request: RoadAccountRequest(door: .moveToSignedInAccount, shown: shownMove, typed: typed),
                signIn: Account.signedIn, exportSwitch: nil)
            #expect(preflight == .refused(said))
        }
        #expect(try Plant.containerBytes(world.road) == before && world.session.library.record?.account == Account.other)
    }

    // MARK: - The follow (rules 10, 12, 15)

    /// VX-464's GUARD: the follow types the library's own pair — which the account's already is (rule 7) — so its wrong
    /// passphrase keeps the library's sentence; nothing written.
    @Test func vx464_theFollowsWrongPassphraseKeepsTheLibrarysSentence() async throws {
        var world = try await world(account: .standard)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        let bytes = try Plant.containerBytes(world.road)
        let wrong = try await press(world, .follow, typed: TypedSecrets(passphrase: "not it"), gate: .alwaysAsk)
        #expect(wrong.press == .refused(ProtectionWords.passphraseDoesNotOpen))
        #expect(try Plant.containerBytes(world.road) == bytes)
    }

    /// INTO CASTLE (another device entered): one secret, the gate, the library re-keyed into Castle following the new
    /// sync key — the Done says the other-device sentence; the export follows rule 11; nothing more is owed.
    @Test func theFollowIntoCastleTypesOneSecretAndFollows() async throws {
        var world = try await world(account: .standard)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        let exports = PlantedExportSwitch(true)
        let result = try await press(
            world, .follow, typed: TypedSecrets(passphrase: Account.passphrase), gate: .alwaysAsk, exports: exports)
        #expect(result.press == .made(receipt: ProtectionWords.followDone(.intoCastle)) && result.landedWhole)
        let after = world.session.library
        #expect(after.record?.mode == .castle && after.record?.accountRowKeyID == world.accountKeys.rowKeyID)
        #expect(!exports.value && exports.noticeOwed, "rule 11 for the follower too")
        let faces = try #require(ProtectionPaneRead.accountFaces(try await Account.read(world.session, Account.signedIn)))
        #expect(faces.follow == .hidden, "nothing owed any more")
    }

    /// OUT OF CASTLE (rule 12 — quietly): nothing typed; the library back in Standard under a new key; the Done said.
    @Test func theFollowOutOfCastleIsQuiet() async throws {
        var world = try await world(account: .standard)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        _ = try await press(world, .follow, typed: TypedSecrets(words: Self.accountWords), gate: .alwaysAsk)
        try world.vault.leaveCastleElsewhere(Account.account)
        let castleKey = world.session.library.fingerprint
        let result = try await press(world, .follow, typed: .none)
        #expect(result.press == .made(receipt: ProtectionWords.followDone(.intoStandard)))
        #expect(world.session.library.record?.mode == .standard
                && world.session.library.keyFile?.heldFingerprints.contains(castleKey) == true)
    }

    /// A REPLACED KEY (this library lagged through the whole Castle stretch): one secret catches it up, the posture kept.
    @Test func aLaggedLibraryCatchesUpWithOneSecret() async throws {
        var world = try await world(account: .standard)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        try world.vault.leaveCastleElsewhere(Account.account)
        let open = try await shown(world, .follow)
        #expect(open.follow == .keysReplaced)
        let result = try await press(world, .follow, typed: TypedSecrets(words: Self.accountWords))
        #expect(result.press == .made(receipt: ProtectionWords.followDone(.keysReplaced)))
        #expect(world.session.library.record?.mode == .standard
                && world.session.library.record?.accountRowKeyID == world.accountKeys.rowKeyID)
    }

    /// VX-113 — her #205 ruling (ii): the account entered Castle elsewhere under a CHANGED passphrase; the old one typed
    /// into the follow names the change — the device and the day the vault's row says — and the preflight says exactly
    /// what the core's act would (the act itself throws `passphraseChangedElsewhere` with the same facts); nothing written.
    /// The new passphrase follows.
    @Test func vx113_theOldPassphraseNamesTheChangeAndTheNewOneFollows() async throws {
        var world = try await world(account: .standard)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: "a new passphrase", words: Self.accountWords,
            newPassphraseLock: true)
        let snapshot = try #require(world.vault.snapshot(Account.account))
        let named = "Your passphrase was changed on Studio Mac on \(ProtectionWords.day(try #require(snapshot.updatedAt)))."
        let bytes = try Plant.containerBytes(world.road)
        let old = try await press(world, .follow, typed: TypedSecrets(passphrase: Account.passphrase), gate: .alwaysAsk)
        #expect(old.press == .refused(named))
        #expect(try Plant.containerBytes(world.road) == bytes)
        // The core's own refusal, the same facts (its check runs before its plan begins — nothing written).
        let executor = world.session.executor
        executor.configuration.session = Account.signedIn
        var library = world.session.library
        var thrown: (any Error)?
        do {
            _ = try await executor.follow(
                &library, kind: .intoCastle, typed: TypedSecrets(passphrase: Account.passphrase), gate: .alwaysAsk)
        } catch {
            thrown = error
        }
        #expect(thrown as? ExecutorRefusal
            == .passphraseChangedElsewhere(device: "Studio Mac", day: snapshot.updatedAt))
        #expect(RoadAccountFaces.actRefusalSentence(try #require(thrown), unfinished: false) == named,
                "the preflight's sentence IS the act's")
        let after = try Plant.containerBytes(world.road)
        #expect(library.section.actInFlight == nil && after == bytes)
        let new = try await press(world, .follow, typed: TypedSecrets(passphrase: "a new passphrase"), gate: .alwaysAsk)
        #expect(new.press == .made(receipt: ProtectionWords.followDone(.intoCastle)))
    }

    // MARK: - VX-107

    /// VX-107 — THE DOUBLE CRASH: the follow stops past its swap (a step after it fails), the next open's settle fails
    /// again, the open after finishes it — and THAT open says the follow's Done with its other-device sentence, its kind
    /// read from durable facts (the act in flight the record names, the mode after). Into Castle and out of it (out of it
    /// the outcome's notice lives in the `memory` step, which the first run spent — a notice-read face says nothing).
    @Test(arguments: [FollowKind.intoCastle, .intoStandard])
    func vx107_aDoubleCrashedFollowStillSaysItsDone(_ kind: FollowKind) async throws {
        var world = try await world(account: .standard, biometry: .ready)
        try await joined(world)
        world.accountKeys = try world.vault.enterCastleElsewhere(
            Account.account, held: world.accountKeys, passphrase: Account.passphrase, words: Self.accountWords)
        if kind == .intoStandard {
            // Into Castle first under Touch ID (so the Castle key has an item for the follow out to retire), then the
            // account leaves elsewhere.
            _ = try await press(world, .follow, typed: TypedSecrets(passphrase: Account.passphrase), gate: .touchID)
            #expect(Crossing.items(world.road, .touchid) == [world.session.library.fingerprint])
            try world.vault.leaveCastleElsewhere(Account.account)
        }
        world.road.custody.failingDeletes = 2  // the in-process run, then the first open's settle
        let typed = kind == .intoCastle ? TypedSecrets(passphrase: Account.passphrase) : .none
        let crashed = try await press(world, .follow, typed: typed, gate: kind == .intoCastle ? .alwaysAsk : nil)
        #expect(crashed.press == .made(receipt: nil) && !crashed.landedWhole, "landed past its swap; its Done not said here")
        // The first relaunch: its settle stops again — nothing finished, nothing said.
        guard case .opened(let first) = await ProtectionOpenRoad.route(world.road.context(), keyInHand: crashed.reopenKey)
        else {
            Issue.record("the first relaunch opens")
            return
        }
        #expect(first.report.settledFollow == nil && first.library.section.actInFlight?.act == .follow)
        #expect(!first.takeReceipts().contains(ProtectionWords.followDone(kind)))
        // The second relaunch: the settle finishes the follow — and the open says its Done.
        guard case .opened(let second) = await ProtectionOpenRoad.route(world.road.context(), keyInHand: first.key) else {
            Issue.record("the second relaunch opens")
            return
        }
        #expect(second.library.section.actInFlight == nil)
        #expect(second.library.record?.mode == (kind == .intoCastle ? .castle : .standard))
        #expect(second.report.settledFollow == kind)
        // VX-309 U2 — VX-457, FLIPPED DELIBERATELY: the Done is no one-shot receipt any more (`receipt_style` off hid it, a
        // quit lost it) — the open whose settle finished the follow MARKS it, by library, as the account section's durable
        // notice: standing at a later open (a fresh faces build), cleared only by its OK.
        #expect(!second.takeReceipts().contains(ProtectionWords.followDone(kind)), "no receipt")
        let defaults = try FollowDoneNoticeTests.scratch("vx107-\(kind)")
        let ledger = PassphraseReminderLedger(defaults: defaults)
        let libraryID = try #require(second.library.record?.libraryID)
        _ = RoadStandingModel.make(second, ledger: ledger)
        #expect(FollowDoneMark.owed(libraryID, in: defaults) == kind, "marked by the open that settled it")
        guard case .opened(let third) = await ProtectionOpenRoad.route(world.road.context(), keyInHand: second.key) else {
            Issue.record("the third relaunch opens")
            return
        }
        #expect(third.report.settledFollow == nil)
        _ = RoadStandingModel.make(third, ledger: ledger)
        #expect(FollowDoneMark.owed(libraryID, in: defaults) == kind, "still standing at a later open — never re-said, never lost")
        FollowDoneMark.set(libraryID, nil, in: defaults)  // her OK (the section's road)
        _ = RoadStandingModel.make(third, ledger: ledger)
        #expect(FollowDoneMark.owed(libraryID, in: defaults) == nil, "OK clears it for good")
    }

    /// The durable reading itself (pure): a settle that finished a follow names its kind from the act in flight's
    /// `fromKind` and the record's mode after; nothing for another act, a roll back, or nothing in flight.
    /// VX-529 unit 2 — FIXTURE CORRECTED DELIBERATELY (the run record's F-U2-5): a re-keying follow's act in flight names
    /// its new key (minted at its press); the fixture used to leave it nil, which is now the PAIR catch-up's own mark
    /// (`PairFollowDoneTests` pins that arm). Every assertion below is unchanged.
    @Test func theSettledFollowIsReadFromDurableFacts() {
        let follow = ActInFlight(sequence: 3, act: .follow, toFingerprint: "new-key", fromKind: .castle, startedAt: Date())
        let quiet = ActOutcome(act: .follow, fingerprint: "f")  // a resume that ran no notice-bearing step
        #expect(RoadSettledFollow.kind(.resumed(quiet), inFlight: follow, modeAfter: .standard) == .intoStandard)
        #expect(RoadSettledFollow.kind(.finishedFromRecord(quiet), inFlight: follow, modeAfter: .castle) == .keysReplaced)
        var standard = follow
        standard.fromKind = .standard
        #expect(RoadSettledFollow.kind(.resumed(quiet), inFlight: standard, modeAfter: .castle) == .intoCastle)
        #expect(RoadSettledFollow.kind(.rolledBack(.follow), inFlight: follow, modeAfter: .castle) == nil)
        #expect(RoadSettledFollow.kind(.nothingInFlight, inFlight: nil, modeAfter: .castle) == nil)
        let crossing = ActInFlight(sequence: 3, act: .enterCastle, fromKind: .standard, startedAt: Date())
        #expect(RoadSettledFollow.kind(.resumed(ActOutcome(act: .enterCastle, fingerprint: "f")), inFlight: crossing,
                                       modeAfter: .castle) == nil)
    }
}
