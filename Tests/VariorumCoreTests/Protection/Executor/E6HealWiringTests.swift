//
//  E6HealWiringTests.swift
//  VariorumCoreTests — VX-529 unit 2, scope 7 (`notes/plans/fixes/vx-529-pair-catchup.md` — P-VX529-4, PROVISIONAL): THE E6
//  HEAL, WIRED. A SYNCED library with no passphrase lock of its own (joined by the twelve words — edge E6 — or R-529-5's
//  words arm's window) lands the account's current passphrase as its lock at a moment that passphrase is typed and
//  verified against the account's vault:
//    - THE LOBBY'S VAULT ROAD — `ProtectionExecutor.landTheAccountsPassphraseLock` (an unplanned ONE-write re-lock: the key
//      file, then the mirror; nothing else); its refusals write nothing;
//    - THE SYNCED KEY DOORS — New words lands it inside its own plan (the one key-file write it already makes): the door
//      types the account's passphrase and verifies it against the vault. (Change and Reset set a passphrase lock anyway.)
//  Never the check door (its contract: checking changes nothing — the app's own pins).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 unit 2 — the E6 heal, wired (P-VX529-4)")
struct E6HealWiringTests {
    /// A synced library in `mode` in E6's state: its own passphrase lock gone (the master with the vault's words copy is
    /// its words' road), the mirror the same.
    static func e6(_ mode: ProtectionMode) throws -> EX {
        let fixture = try EX(mode, synced: true)
        let live = try #require(fixture.world.liveFormat3)
        let e6 = live.droppingPassphrase()
        #expect(e6.opensWithTheWords && e6.passphrase == nil)
        fixture.world.liveKeyFile = e6
        let memory = DeviceMemory(
            libraryID: fixture.libraryID, currentFingerprint: PF.fp(fixture.key), deviceID: fixture.deviceID, keyFileMirror: e6)
        fixture.world.memories[fixture.libraryID] = try memory.sealed(under: fixture.key)
        fixture.world.writes = []
        return fixture
    }

    static func vault(_ fixture: EX) throws -> VaultSnapshot {
        let account = try #require(fixture.account)
        return try #require(fixture.world.server.snapshot(account))
    }

    // MARK: - The lobby's heal

    /// IT LANDS — the account's passphrase as this library's own lock under the VAULT's descriptor, opening the current
    /// key; nothing else in the file moves (byte for byte but the lock); the mirror follows; ONE key-file write and the
    /// mirror's, nothing else (no vault, no custody, no sync keys, no record, no plan). Twice: the second lands nothing.
    @Test(arguments: ProtectionMode.allCases)
    func theHealLandsTheAccountsPassphraseAndNothingElse(_ mode: ProtectionMode) async throws {
        let fixture = try Self.e6(mode)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = try #require(fixture.world.liveFormat3)
        fixture.world.writes = []
        let landed = try await executor.landTheAccountsPassphraseLock(&library, passphrase: fixture.passphrase)
        #expect(landed)
        let after = try #require(fixture.world.liveFormat3)
        let vault = try Self.vault(fixture)
        #expect(after.passphrase?.kdf == vault.vault.kdf, "under the vault's own descriptor (fact 1)")
        #expect(try after.open(.passphrase(fixture.passphrase), floor: PF.floor) == fixture.key)
        var unlocked = after
        unlocked.passphrase = nil
        #expect(unlocked == before, "nothing but the lock moved")
        #expect(fixture.memoryValue()?.keyFileMirror == after, "the mirror follows the file (rule 1)")
        let kinds = fixture.world.writes.map { write -> String in
            switch write {
            case .keyFile: return "keyFile"
            case .memory: return "memory"
            default: return "\(write)"
            }
        }
        #expect(kinds == ["keyFile", "memory"], "ONE key-file write, then the mirror — nothing else: \(fixture.world.writes)")
        #expect(library.keyFile == after && library.section.actInFlight == nil)
        fixture.world.writes = []
        #expect(try await executor.landTheAccountsPassphraseLock(&library, passphrase: fixture.passphrase) == false)
        #expect(fixture.world.writes.isEmpty, "a lock stands — nothing written")
    }

    /// THE CALLER'S READ — the lobby passes the vault it just read (one bounded read); the heal verifies against it and reads
    /// nothing more.
    @Test func theHealTakesTheLobbysReadAndReadsNoMore() async throws {
        let fixture = try Self.e6(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.server.reachable = false
        #expect(try await executor.landTheAccountsPassphraseLock(
            &library, passphrase: fixture.passphrase, vault: try Self.vault(fixture)))
        #expect(fixture.world.liveFormat3?.passphrase != nil)
    }

    /// AN EXISTING LOCK IS NEVER REPLACED (the account's, or a stale one owing the catch-up): nothing written.
    @Test func anExistingLockIsNeverReplaced() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = fixture.world.liveFormat3
        fixture.world.writes = []
        #expect(try await executor.landTheAccountsPassphraseLock(&library, passphrase: fixture.passphrase) == false)
        #expect(fixture.world.writes.isEmpty && fixture.world.liveFormat3 == before)
    }

    /// THE REFUSALS — each writes nothing: a passphrase the vault refuses (the plain refusal: E6 has no lock of its own to
    /// name a change by); a library that doesn't sync; the account moved (posture, or a sync key this library doesn't
    /// follow — the follow first); an act in flight; another account's vault handed in.
    @Test func theRefusalsWriteNothing() async throws {
        let fixture = try Self.e6(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        func refuses(_ expected: ExecutorRefusal, _ library: inout UnlockedLibrary, passphrase: String,
                     vault: VaultSnapshot? = nil, sourceLocation: SourceLocation = #_sourceLocation) async {
            fixture.world.writes = []
            do {
                _ = try await executor.landTheAccountsPassphraseLock(&library, passphrase: passphrase, vault: vault)
                Issue.record("expected \(expected)", sourceLocation: sourceLocation)
            } catch {
                #expect(error as? ExecutorRefusal == expected, "\(error)", sourceLocation: sourceLocation)
            }
            #expect(fixture.world.writes.isEmpty, sourceLocation: sourceLocation)
        }
        await refuses(.passphraseDoesNotOpen, &library, passphrase: "not the account's passphrase")
        // Another account's vault handed in.
        var other = try Self.vault(fixture)
        other.accountID = "another-account"
        await refuses(.accountMoved, &library, passphrase: fixture.passphrase, vault: other)
        // The account moved posture elsewhere.
        var moved = try Self.vault(fixture)
        moved.vault = VaultModel.enteringCastleFlagOnly(moved.vault)
        await refuses(.accountMoved, &library, passphrase: fixture.passphrase, vault: moved)
        // An act in flight.
        var busy = library
        busy.section = busy.section.beginningAct(.follow, from: busy.fingerprint, to: nil, fromKind: .standard, at: PF.t0).0
        await refuses(.actInFlight(.follow), &busy, passphrase: fixture.passphrase)
        // A library that doesn't sync.
        let local = try EX(.standard)
        let localExecutor = local.executor()
        var localLibrary = try local.unlocked(localExecutor)
        localLibrary.keyFile = localLibrary.keyFile?.droppingPassphrase()
        do {
            _ = try await localExecutor.landTheAccountsPassphraseLock(&localLibrary, passphrase: local.passphrase)
            Issue.record("an unsynced library refuses")
        } catch {
            #expect(error as? ExecutorRefusal == .notSynced)
        }
        #expect(fixture.world.liveFormat3?.passphrase == nil, "nothing landed")
    }

    // MARK: - The synced key doors

    /// NEW WORDS ON AN E6 LIBRARY (the door types the account's passphrase and verifies it against the vault): the act's own
    /// key-file write lands the passphrase lock too — under the vault's descriptor, opening the current key — beside the new
    /// words. RED without the wiring (the lock stayed missing).
    @Test(arguments: ProtectionMode.allCases)
    func newWordsLandsTheMissingPassphraseLock(_ mode: ProtectionMode) async throws {
        let fixture = try Self.e6(mode)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let newWords = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: newWords)
        let after = try #require(fixture.world.liveFormat3)
        let vault = try Self.vault(fixture)
        #expect(after.passphrase?.kdf == vault.vault.kdf, "the account's passphrase landed under the vault's descriptor")
        #expect((try? after.open(.passphrase(fixture.passphrase), floor: PF.floor)) == fixture.key)
        #expect(try after.open(.words(newWords), floor: PF.floor) == fixture.key, "the new words open it")
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "New words on E6 (\(mode))")
    }
}

extension VaultModel {
    /// Test-only: the vault's posture flag flipped to Castle with nothing else touched (a moved account, as `assess` and
    /// the heal read it — the posture alone).
    static func enteringCastleFlagOnly(_ vault: AccountVault) -> AccountVault {
        var next = vault
        next.mode = .castle
        return next
    }
}
