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
