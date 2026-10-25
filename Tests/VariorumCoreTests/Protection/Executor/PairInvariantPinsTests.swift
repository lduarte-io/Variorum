//
//  PairInvariantPinsTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 4: FACT 1's GUARD
//  (`notes/plans/fixes/vx-529-pair-catchup.md` — "the build VERIFIES every
//  synced road that writes `settingPassphrase` uses the vault's descriptor, with
//  a pin per road"). Detection reads a pair changed elsewhere from two
//  comparisons — the key file's passphrase lock's descriptor against the vault's,
//  and the master's twelve-words copy against the vault's recovery wrap — so a
//  synced road that left either one off the vault's would owe a follow that
//  nothing elsewhere caused. EXISTING-BEHAVIOR pins (not a fix): after every
//  synced road that writes a passphrase lock or the words copy, the key file
//  carries the account's pair exactly as the vault holds it.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// Fact 1: the key file of a synced library carries the account's pair — any passphrase lock under the VAULT's own
/// descriptor, the master with its twelve-words copy being the vault's recovery wrap byte for byte (§3.5a).
/// `passphraseLock`: whether this road leaves a passphrase lock at all (nil: either is the road's own business).
func expectTheKeyFileCarriesTheAccountsPair(
    _ fixture: EX, passphraseLock: Bool?, _ road: String, sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let account = try #require(fixture.liveRecord?.account, "\(road): the library names no account", sourceLocation: sourceLocation)
    let vault = try #require(fixture.world.server.snapshot(account), "\(road): no vault", sourceLocation: sourceLocation).vault
    let live = try #require(fixture.world.liveFormat3, "\(road): no live key file", sourceLocation: sourceLocation)
    #expect(live.fingerprint == fixture.world.live?.fingerprint, "\(road): the key file is another key's",
            sourceLocation: sourceLocation)
    if let lock = live.passphrase {
        #expect(lock.kdf == vault.kdf, "\(road): the passphrase lock is under another descriptor than the vault's",
                sourceLocation: sourceLocation)
    }
    if let expected = passphraseLock {
        #expect((live.passphrase != nil) == expected, "\(road): a passphrase lock \(expected ? "missing" : "kept")",
                sourceLocation: sourceLocation)
    }
    #expect(live.master != nil, "\(road): no master lock", sourceLocation: sourceLocation)
    #expect(live.masterWordsCopy == vault.masterByWords, "\(road): the words copy is not the vault's recovery wrap",
            sourceLocation: sourceLocation)
    // …and the reading detection makes of it (the same two comparisons) owes nothing.
    let reading = VaultSnapshot(accountID: account, revision: 0, vault: vault).reading
    #expect(live.passphrase.map { $0.kdf == reading.kdf } ?? true, sourceLocation: sourceLocation)
    #expect(live.masterWordsCopy == reading.recoveryWrap, sourceLocation: sourceLocation)
}

@Suite("VX-529 scope 4 — fact 1: every synced road leaves the key file carrying the account's pair (existing behavior)")
struct PairInvariantPinsTests {
    // MARK: Turning sync on, joining, Move

    @Test(arguments: ProtectionMode.allCases)
    func setUpSync(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "set up sync (\(mode))")
    }

    @Test func joinInTheSamePostureByThePassphrase() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        try expectTheKeyFileCarriesTheAccountsPair(laptop, passphraseLock: true, "join, same posture, by the passphrase")
    }

    /// Joined by the words: the library's own passphrase lock (another descriptor) goes — edge E6's state (no kdf leg).
    @Test func joinInTheSamePostureByTheWords() async throws {
        let mac = try EX(.castle, synced: true)
        let laptop = try EX(.castle, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words))
        try expectTheKeyFileCarriesTheAccountsPair(laptop, passphraseLock: false, "join, same posture, by the words")
    }

    @Test(arguments: [false, true])
    func joinACastleAccountFromStandard(byPassphrase: Bool) async throws {
        let mac = try EX(.castle, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        let typed = byPassphrase ? TypedSecrets(passphrase: mac.passphrase) : TypedSecrets(words: mac.words)
        _ = try await executor.enroll(&library, typed: typed, gate: .touchID)
        try expectTheKeyFileCarriesTheAccountsPair(
            laptop, passphraseLock: byPassphrase, "join into Castle by the \(byPassphrase ? "passphrase" : "words")")
    }

    @Test func joinAStandardAccountFromCastle() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.castle, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase, words: mac.words))
        try expectTheKeyFileCarriesTheAccountsPair(laptop, passphraseLock: true, "join out of Castle")
    }

    @Test func moveToTheSignedInAccount() async throws {
        let x = try EX(.standard, synced: true)
        let y = try EX(.standard, synced: true, world: ExecutorWorld(icloud: x.world.icloud, server: x.world.server))
        let executor = x.executor(session: y.session)
        var library = try x.unlocked(executor)
        _ = try await executor.move(&library, typed: TypedSecrets(passphrase: y.passphrase, words: y.words))
        try expectTheKeyFileCarriesTheAccountsPair(x, passphraseLock: true, "Move")
    }

    // MARK: The follows

    @Test(arguments: [false, true])
    func followIntoCastle(byPassphrase: Bool) async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let typed = byPassphrase ? TypedSecrets(passphrase: phone.passphrase) : TypedSecrets(words: phone.words)
        _ = try await executor.follow(&library, kind: .intoCastle, typed: typed)
        try expectTheKeyFileCarriesTheAccountsPair(
            phone, passphraseLock: byPassphrase, "follow into Castle by the \(byPassphrase ? "passphrase" : "words")")
    }

    @Test func followOutOfCastleQuietly() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        _ = try await executor.follow(&library, kind: .intoStandard, typed: .none)
        try expectTheKeyFileCarriesTheAccountsPair(phone, passphraseLock: false, "follow out of Castle")
    }

    @Test func followCatchingUpOnReplacedKeys() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        _ = try await executor.follow(&library, kind: .keysReplaced, typed: TypedSecrets(passphrase: phone.passphrase))
        try expectTheKeyFileCarriesTheAccountsPair(phone, passphraseLock: true, "follow, keys replaced")
    }

    // MARK: The crossings and Replace All Keys, synced

    @Test func useCastleSynced() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "Use Castle")
    }

    @Test func useStandardSynced() async throws {
        let fixture = try EX(.castle, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "Use Standard")
    }

    @Test(arguments: ProtectionMode.allCases)
    func replaceAllKeys(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "Replace All Keys (\(mode))")
    }

    // MARK: The key doors, synced

    @Test(arguments: ProtectionMode.allCases)
    func changePassphrase(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "a passphrase chosen today")
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "Change passphrase (\(mode))")
    }

    @Test(arguments: ProtectionMode.allCases)
    func resetForgottenPassphrase(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let authorization: ResetAuthorization = mode == .castle ? .words(fixture.words) : .plainConfirm
        _ = try await executor.resetPassphrase(&library, authorization: authorization, new: "a passphrase chosen today")
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "Reset forgotten passphrase (\(mode))")
    }

    @Test(arguments: ProtectionMode.allCases)
    func newWords(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: try PF.words())
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "New words (\(mode))")
    }

    /// THE GUARD BITES (a negative control — the pins above are green on both sides by nature): a lock under another
    /// descriptor, and a words copy that is not the vault's, are each caught.
    @Test func theGuardBitesOnALockOffTheVaultsDescriptorAndAStaleCopy() async throws {
        let fixture = try EX(.standard, synced: true)
        let live = try #require(fixture.world.liveFormat3)
        fixture.world.liveKeyFile = try live.settingPassphrase(try PF.passphraseKey(fixture.passphrase), for: fixture.key)
        withKnownIssue("a passphrase lock under another descriptor than the vault's") {
            try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "planted: another descriptor")
        }
        fixture.world.liveKeyFile = live.refreshingMasterWordsCopy(try AES.KeyWrap.wrap(SymmetricKey(size: .bits256),
                                                                                        using: fixture.w.key))
        withKnownIssue("a words copy that is not the vault's recovery wrap") {
            try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "planted: a stale copy")
        }
    }

    /// VX-447's mint (no key file anywhere): the fresh file's locks are the vault's too.
    @Test(arguments: ProtectionMode.allCases)
    func newWordsMintingTheFileThatWasGoneEverywhere(_ mode: ProtectionMode) async throws {
        let fixture = try EX(mode, synced: true)
        fixture.world.liveKeyFile = nil
        fixture.world.memories = [:]
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: try PF.words())
        try expectTheKeyFileCarriesTheAccountsPair(fixture, passphraseLock: true, "New words, minting the file (\(mode))")
    }
}
