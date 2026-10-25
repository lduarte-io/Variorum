//
//  LobbyVaultRoadTests.swift
//  VariorumTests — VX-529 unit 2, scope 3 (`notes/plans/fixes/vx-529-pair-catchup.md` — R-529-1, her pick: "Open through the
//  vault"): THE LOBBY'S VAULT ROAD. A typed passphrase that fails every local road, signed in and online, earns ONE bounded
//  vault read; derived under the VAULT's descriptor it opens the vault's master, the master opens the key file's master
//  lock ⇒ the library opens, and the catch-up lands in the same press with the typed secret in hand. Over the new road's
//  PLANTED leaves (no keychain, no network; headless in the implementer's SwiftPM harness too).
//    - THE BUG CLASS (RED on the pre-fix tree): the lagging library's lobby refused the account's CURRENT passphrase with
//      the bare "That passphrase doesn't open this library." (the VX-510 repro), and said the same over a passphrase that
//      opens neither while the change was readable — the sentence owed was never said.
//    - THE GUARDRAILS (green on both sides — guards): offline, signed out, another account, a read-only road — today's
//      refusal byte for byte, nothing written.
//    - THE LADDER, ROUND 1 — F-R1-1 (fix session L1): the read only where it can prove something. Over a library none of
//      whose held key files carries a master lock (it never synced), no vault-road answer can be anything but today's
//      refusal, so the lobby makes no read at all (RED on the pre-fix tree at the fetch counts); a synced library keeps its
//      one read; the refusal is today's, byte for byte, on both sides of the gate.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 2 — the lobby's vault road (planted, no keychain)")
@MainActor
struct LobbyVaultRoadTests {
    typealias Account = PlantedAccount
    typealias World = TouchIDUnlockSyncKeysTests.World

    static let changedPassphrase = "a passphrase made on the studio mac"

    /// Another device re-made the account's passphrase (a key door there: the vault's passphrase lock under a new
    /// descriptor; the master, the sync keys and this library's key unchanged).
    static func passphraseChangedElsewhere(_ vault: PlantedVaultLeaf) throws {
        let snapshot = try #require(vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
        var row = try #require(vault.accounts[Account.account])
        row.vault = try VaultModel.rewrappingPassphrase(
            snapshot.vault, master: master,
            passphrase: try PassphraseKey.derive(changedPassphrase, kdf: FastIDsLeaf().mintPassphraseKDF()),
            device: "Studio Mac")
        row.revision += 1
        row.updatedAt = (row.updatedAt ?? Date()).addingTimeInterval(3600)
        vault.accounts[Account.account] = row
    }

    /// A lagging Castle Always-ask library (the VX-510 repro's posture): synced, the passphrase re-made on another device,
    /// relaunched to its lobby (no keys in session).
    static func laggingCastle() async throws -> World {
        let world = try await TypedUnlockSyncKeysTests.castleAlwaysAskSynced()
        try Self.passphraseChangedElsewhere(world.vault)
        TouchIDUnlockSyncKeysTests.relaunched(world)
        return world
    }

    /// A lagging STANDARD library whose quiet roads failed (no silent item, no Apple key — the lobby asks).
    static func laggingStandard() async throws -> World {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        let turnOn = try #require(ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?
            .turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: turnOn, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        try Self.passphraseChangedElsewhere(vault)
        road.custody.items = [:]
        road.apple.keys = [:]
        keys.holdInSession(nil, accountID: Account.account)
        return World(road: road, vault: vault, keys: keys, session: session, words: words)
    }

    static func fetches(_ world: World) -> Int { world.vault.calls.filter { $0 == "fetch \(Account.account)" }.count }

    // MARK: - The bug class (RED on the pre-fix tree)

    /// THE ACCOUNT'S CURRENT PASSPHRASE OPENS THE LAGGING LIBRARY THROUGH THE VAULT (R-529-1), Castle Always ask and
    /// Standard: the library opens under its own key (never re-keyed), and the catch-up landed in the same press — the
    /// key file carries the account's pair (nothing owed), the old passphrase no longer opens it, today's does.
    @Test(arguments: [true, false])
    func theAccountsCurrentPassphraseOpensThroughTheVaultAndCatchesUp(_ castle: Bool) async throws {
        let world = castle ? try await Self.laggingCastle() : try await Self.laggingStandard()
        let key = world.session.key
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Self.changedPassphrase))
        else {
            Issue.record("the account's current passphrase opens the library through the vault")
            return
        }
        #expect(opened.key == key, "the library's own key — never re-keyed (rule 6)")
        let live = try #require(opened.library.keyFile)
        let reading = try #require(world.vault.snapshot(Account.account)).reading
        #expect(AssessRules.pairFollow(live, reading) == nil, "the catch-up landed: the key file carries the account's pair")
        #expect((try? live.open(.passphrase(Self.changedPassphrase), floor: .relaxedForTests)) == key)
        #expect((try? live.open(.passphrase(Account.passphrase), floor: .relaxedForTests)) == nil,
                "the old passphrase no longer opens the live library (rule 7's one pair)")
        let faces = try #require(ProtectionPaneRead.accountFaces(try await Account.read(opened, Account.signedIn)))
        #expect(faces.follow == .hidden, "nothing owed after")
    }

    /// A PASSPHRASE THAT OPENS NEITHER, WHILE THE CHANGE IS READABLE: the lobby says what happened (the device), never the
    /// bare refusal alone — RED on old (it said exactly "That passphrase doesn't open this library."). Nothing written.
    @Test func aPassphraseThatOpensNeitherNamesTheChange() async throws {
        let world = try await Self.laggingCastle()
        let before = try Plant.containerBytes(world.road)
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase("not anyone's passphrase"))
        else {
            Issue.record("a passphrase that opens neither is refused")
            return
        }
        #expect(sentence != ProtectionWords.passphraseDoesNotOpen, "the owed sentence, never the bare refusal alone")
        #expect(sentence.hasPrefix(ProtectionWords.passphraseDoesNotOpen) && sentence.contains("Studio Mac"), "\(sentence)")
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
    }

    // MARK: - The guardrails (guards — green on both sides)

    /// OFFLINE: today's refusal, byte-identical; the read was tried (bounded); nothing written.
    @Test func offlineKeepsTodaysRefusalByteIdentical() async throws {
        let world = try await Self.laggingCastle()
        world.vault.reachable = false
        let before = try Plant.containerBytes(world.road)
        for typed in [Self.changedPassphrase, "not anyone's passphrase"] {
            guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
                world.road.context(), secret: .passphrase(typed))
            else {
                Issue.record("offline: refused")
                return
            }
            #expect(sentence == ProtectionWords.passphraseDoesNotOpen, "today's refusal, byte for byte")
        }
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
    }

    /// A SLOW SERVER: the vault road waits at most its bound, then today's refusal (never hostage); nothing written.
    @Test func aSlowServerCostsTheBoundThenTodaysRefusal() async throws {
        let world = try await Self.laggingCastle()
        world.vault.fetchDelay = .seconds(2)
        let clock = ContinuousClock()
        let started = clock.now
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Self.changedPassphrase), syncKeysWithin: .milliseconds(200))
        else {
            Issue.record("past the bound: refused")
            return
        }
        #expect(clock.now - started < .milliseconds(1500), "the bound, never the slow read")
        #expect(sentence == ProtectionWords.passphraseDoesNotOpen)
        try await Task.sleep(for: .milliseconds(2200))
    }

    /// SIGNED OUT, or into ANOTHER account: no read, today's refusal, nothing written.
    @Test func signedOutOrAnotherAccountReadsNothing() async throws {
        let world = try await Self.laggingCastle()
        let before = try Plant.containerBytes(world.road)
        for signIn in [SessionFact.signedOut, .signedIn(accountID: Account.other, email: "someone@example.test")] {
            world.road.session = signIn
            let fetches = Self.fetches(world)
            guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
                world.road.context(), secret: .passphrase(Self.changedPassphrase))
            else {
                Issue.record("\(signIn): refused")
                return
            }
            #expect(sentence == ProtectionWords.passphraseDoesNotOpen, "\(signIn)")
            #expect(Self.fetches(world) == fetches, "\(signIn): the library's account's vault never read")
        }
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
    }

    /// A READ-ONLY ROAD (a hosted test run): no vault read, today's refusal.
    @Test func aReadOnlyRoadReadsNoVault() async throws {
        let world = try await Self.laggingCastle()
        let fetches = world.vault.calls.count
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
            world.road.context(writes: false), secret: .passphrase(Self.changedPassphrase))
        else {
            Issue.record("read-only: refused")
            return
        }
        #expect(sentence == ProtectionWords.passphraseDoesNotOpen && world.vault.calls.count == fetches)
    }

    // MARK: - F-R1-1 (the ladder's round 1, fix session L1): the read only where it can prove something

    static let ownPassphrase = "a passphrase only this library knows"

    /// An UNSYNCED library — its own passphrase lock (rule 3's first passphrase, set here), NO master lock (it never joined
    /// an account) — whose quiet roads failed (the lobby asks), on a Mac signed in to an account whose vault exists.
    static func unsyncedWhileSignedIn() async throws -> World {
        let (road, vault, keys) = Account.road()
        road.session = Account.signedIn
        let (session, words) = try await road.created()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: Self.ownPassphrase) == .set)
        _ = try vault.plant(
            accountID: Account.account, passphrase: Account.passphrase, words: try RecoveryPhrase.generate(), mode: .standard)
        let live = try #require(session.library.keyFile)
        #expect(live.passphrase != nil && live.master == nil && session.library.record?.account == nil,
                "precondition: unsynced — a passphrase lock of its own, no master lock, no account")
        road.custody.items = [:]
        road.apple.keys = [:]
        return World(road: road, vault: vault, keys: keys, session: session, words: words)
    }

    /// AN UNSYNCED LIBRARY MAKES NO VAULT READ: none of its held key files carries a master lock, so no answer of the vault
    /// road's can be anything but today's refusal — neither for a wrong passphrase nor for the ACCOUNT's own (which opens
    /// the vault's master, with nothing here for that master to open). RED on the pre-fix tree at the fetch counts (one
    /// read per press, up to the bound per typo); the refusal is today's, byte for byte, on both trees; nothing written.
    @Test func anUnsyncedLibraryMakesNoVaultRead() async throws {
        let world = try await Self.unsyncedWhileSignedIn()
        let before = try Plant.containerBytes(world.road)
        for typed in ["not anyone's passphrase", Account.passphrase] {
            let fetches = Self.fetches(world)
            guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
                world.road.context(), secret: .passphrase(typed))
            else {
                Issue.record("\(typed == Account.passphrase ? "the account's passphrase" : "a wrong passphrase"): refused")
                return
            }
            #expect(sentence == ProtectionWords.passphraseDoesNotOpen, "today's refusal, byte for byte")
            #expect(Self.fetches(world) == fetches,
                    "\(typed == Account.passphrase ? "the account's passphrase" : "a wrong passphrase"): no vault read")
        }
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
        guard case .opened = await ProtectionOpenRoad.openTyped(world.road.context(), secret: .passphrase(Self.ownPassphrase))
        else {
            Issue.record("a guard: the library's own passphrase still opens it locally")
            return
        }
    }

    /// THE GATE'S OTHER SIDE: a SYNCED library (a master lock), nothing changed elsewhere, a wrong passphrase — the read
    /// stays (ONE fetch: this is where an owed sentence can be proven), and the refusal is the same bytes as the gated
    /// side's. A guard — green on both trees.
    @Test func aSyncedLibraryKeepsItsOneReadAndTheSameRefusal() async throws {
        let world = try await TypedUnlockSyncKeysTests.castleAlwaysAskSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        #expect(world.session.library.keyFile?.master != nil, "precondition: synced — a master lock")
        let before = try Plant.containerBytes(world.road)
        let fetches = Self.fetches(world)
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase("not anyone's passphrase"))
        else {
            Issue.record("refused")
            return
        }
        #expect(sentence == ProtectionWords.passphraseDoesNotOpen, "today's refusal, byte for byte")
        #expect(Self.fetches(world) == fetches + 1, "ONE bounded read — where it can prove something")
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
    }

    // MARK: - The design rows (their tests — landed with the road)

    /// THE NAMED SENTENCE, exactly; and the catch-up's DURABLE notice (VX-457's mark) written by the open's faces from what
    /// the vault road landed; ONE bounded read before the open (the act's own reads after it are its plan's — E4); no
    /// Touch ID read anywhere on the road (a read is a prompt).
    @Test func theRoadSaysWhatItReadAndItsLandingIsTheSectionsNotice() async throws {
        let world = try await Self.laggingCastle()
        let snapshot = try #require(world.vault.snapshot(Account.account))
        guard case .refused(let sentence) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase("not anyone's passphrase"))
        else {
            Issue.record("refused")
            return
        }
        #expect(sentence == ProtectionWords.lobbyPassphraseChangedElsewhere(
            device: "Studio Mac", day: snapshot.updatedAt.map { ProtectionWords.day($0) }))
        let custodyPresses = world.road.custody.reads.filter { $0 == .touchid }.count
        let syncPresses = world.keys.touchIDReads
        let before = Self.fetches(world)
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Self.changedPassphrase))
        else {
            Issue.record("opened")
            return
        }
        #expect(opened.report.lobbyNotice == .followed(.pairChanged(passphrase: true, words: false)))
        #expect(Self.fetches(world) == before + 3, "ONE bounded read decides; the act's own two (its door, its step) follow")
        #expect(world.road.custody.reads.filter { $0 == .touchid }.count == custodyPresses && world.keys.touchIDReads
                == syncPresses, "no Touch ID read — no prompt")
        #expect(world.keys.sessionSyncKeys(accountID: Account.account) != nil, "the account's keys held for the session")
        let defaults = try FollowDoneNoticeTests.scratch("vx529-u2-lobby")
        _ = RoadStandingModel.make(opened, ledger: PassphraseReminderLedger(defaults: defaults))
        let libraryID = try #require(opened.library.record?.libraryID)
        #expect(FollowDoneMark.notice(libraryID, in: defaults) == .followed(.pairChanged(passphrase: true, words: false)),
                "the section's durable notice")
    }

    /// E6 — A SYNCED LIBRARY WITH NO PASSPHRASE LOCK OF ITS OWN (joined by the twelve words): signed in, the lobby offers
    /// the passphrase field with R-529-6's line (the why and the road); the account's passphrase opens it through the
    /// vault and the heal lands the lock (under the vault's descriptor — nothing else moved, the key unchanged), said as the
    /// section's notice; any other passphrase is "not this account's", nothing written; signed out, no field, no line.
    /// A library created here (no passphrase yet) JOINED an account that already syncs by its twelve words — E6 by birth
    /// (no passphrase lock of its own; the account's master with its words copy) — and its quiet roads failed later (the
    /// lobby asks).
    static func e6Joined() async throws -> World {
        let (road, vault, keys) = Account.road()
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
        #expect(live.passphrase == nil && live.master != nil && live.masterWordsCopy != nil, "precondition: E6")
        road.custody.items = [:]
        road.apple.keys = [:]
        keys.holdInSession(nil, accountID: Account.account)
        return World(road: road, vault: vault, keys: keys, session: session, words: accountWords)
    }

    @Test func e6_theAccountsPassphraseOpensThroughTheVaultAndTheLockLands() async throws {
        let world = try await Self.e6Joined()
        let session = world.session
        let face = ProtectionLobbyFace.derive(ProtectionOpenRoad.lobbyFacts(world.road.context()))
        #expect(face.passphraseField && face.wordsRoad == .disclosure, "the vault road's field, the words beside it")
        #expect(face.accountPassphraseLine == ProtectionWords.lobbyAccountPassphraseNotTypedHere)
        world.road.session = .signedOut
        let signedOut = ProtectionLobbyFace.derive(ProtectionOpenRoad.lobbyFacts(world.road.context()))
        #expect(!signedOut.passphraseField && signedOut.wordsRoad == .field && signedOut.accountPassphraseLine == nil,
                "signed out: the words alone, as today")
        world.road.session = Account.signedIn
        let before = try Plant.containerBytes(world.road)
        guard case .refused(let wrong) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase("not the account's"))
        else {
            Issue.record("refused")
            return
        }
        #expect(wrong == ProtectionWords.passphraseDoesNotOpenAccount)
        #expect(try Plant.containerBytes(world.road) == before, "nothing written")
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Account.passphrase))
        else {
            Issue.record("the account's passphrase opens an E6 library through the vault")
            return
        }
        #expect(opened.key == session.key)
        let live = try #require(opened.library.keyFile)
        let vault = try #require(world.vault.snapshot(Account.account))
        #expect(live.passphrase?.kdf == vault.vault.kdf, "the lock landed under the vault's descriptor")
        #expect((try? live.open(.passphrase(Account.passphrase), floor: .relaxedForTests)) == session.key)
        #expect(opened.report.lobbyNotice == .passphraseLanded)
        #expect(TypedUnlockSyncKeysTests.engineKeyID(opened) != nil, "the engine reads the account's keys (Standard: silent)")
        #expect(ProtectionLobbyFace.derive(ProtectionOpenRoad.lobbyFacts(world.road.context())).accountPassphraseLine == nil,
                "the line retires the moment the lock landed")
    }

    /// THE OLD PASSPHRASE STILL OPENS LOCALLY (the vault road is never reached — no read beyond today's sync-keys load),
    /// and the follow stays owed in Settings (a guard: the local roads are untouched).
    @Test func theOldPassphraseStillOpensLocally() async throws {
        let world = try await Self.laggingCastle()
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            world.road.context(), secret: .passphrase(Account.passphrase))
        else {
            Issue.record("the old passphrase opens the library")
            return
        }
        let faces = try #require(ProtectionPaneRead.accountFaces(try await Account.read(opened, Account.signedIn)))
        #expect(faces.follow.openDoor?.follow == .pairChanged(passphrase: true, words: false), "the follow stays owed")
    }
}
