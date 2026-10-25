//
//  PairRefusalSplitTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 3: THE REFUSAL SPLIT at Change
//  passphrase's vault-verify arm (`notes/plans/fixes/vx-529-pair-catchup.md`).
//  The VX-510 repro (unit C, 22:36–22:46): the account's passphrase changed on
//  one Mac; on the lagging library Change passphrase old → new refused "That
//  passphrase doesn't open this library." — false: the old passphrase DOES open
//  this library. The mechanism: a synced library verifies the typed current
//  passphrase against the VAULT, where the old one no longer opens, and the arm
//  threw the plain refusal. Split: opens this library but not the vault ⇒
//  VX-113's `passphraseChangedElsewhere` (the vault's last writer and day);
//  opens neither ⇒ the plain refusal.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 scope 3 — Change passphrase after the account's passphrase changed elsewhere says so")
struct PairRefusalSplitTests {
    /// Two devices of one account; the first changes the account's passphrase through its own door. The second lags:
    /// its key file still carries the account's passphrase as it last knew it (rule 7's one pair, fact 1).
    static func laggingPair(_ mode: ProtectionMode) async throws -> (mac: EX, air: EX, vault: VaultSnapshot) {
        let mac = try EX(mode, synced: true, gate: mode == .castle ? .alwaysAsk : nil)
        let air = try EX(mode, synced: true, gate: mode == .castle ? .alwaysAsk : nil, joining: mac)
        let executor = mac.executor()
        var library = try mac.unlocked(executor)
        _ = try await executor.changePassphrase(&library, current: mac.passphrase, new: "a passphrase made on the other Mac")
        let vault = try #require(mac.world.server.snapshot(mac.account!))
        return (mac, air, vault)
    }

    /// RED ON THE PRE-FIX TREE (it threw `passphraseDoesNotOpen`): the old passphrase opens this library — and the
    /// door names the change, writing nothing.
    @Test(arguments: ProtectionMode.allCases)
    func theOldPassphraseThatOpensTheLibraryButNotTheVaultNamesTheChange(_ mode: ProtectionMode) async throws {
        let (_, air, vault) = try await Self.laggingPair(mode)
        let live = try #require(air.world.liveFormat3)
        #expect(try live.open(passphrase: .passphrase(air.passphrase), floor: PF.floor) == air.key,
                "the fixture: the old passphrase opens this library")
        #expect(live.passphrase?.kdf != vault.vault.kdf, "the fixture: the account's passphrase changed elsewhere")
        let executor = air.executor()
        var library = try air.unlocked(executor)
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt)) {
            _ = try await executor.changePassphrase(&library, current: air.passphrase, new: "a newer passphrase still")
        }
        #expect(air.world.writes.isEmpty, "the refused door wrote \(air.world.writeLog())")
        #expect(library.section.actInFlight == nil)
    }

    /// A passphrase that opens neither this library nor the account keeps the plain refusal.
    @Test(arguments: ProtectionMode.allCases)
    func aPassphraseThatOpensNeitherKeepsThePlainRefusal(_ mode: ProtectionMode) async throws {
        let (_, air, _) = try await Self.laggingPair(mode)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.changePassphrase(&library, current: "not any passphrase of hers", new: "a newer passphrase still")
        }
        #expect(air.world.writes.isEmpty)
    }

    /// With nothing changed elsewhere, a wrong passphrase is the plain refusal too (the split never names a change
    /// that didn't happen: the library's lock is the vault's descriptor, so nothing opens one and not the other).
    @Test func withNothingChangedElsewhereAWrongPassphraseIsThePlainRefusal() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.changePassphrase(&library, current: "not any passphrase of hers", new: "a newer passphrase still")
        }
    }
}

/// THE CLASS'S OTHER SEAMS (the architect's ruling, S-5 overruled in part; the sweep table in the run record's P6e): a
/// typed secret that still opens THIS library but no longer the account's vault, refused with a sentence saying it doesn't
/// open this library. RED ON THE PRE-FIX TREE, row by row. The passphrase rows take P1's split
/// (`passphraseChangedElsewhere`, the vault's last writer and day); the words rows — no refusal names a words change, and
/// none is minted here — take the existing `accountMoved` ("Your account changed on another device. Follow it first."),
/// true and pointing at the act owed, at the doors that are not the follow itself.
@Suite("VX-529 P6e — the false-refusal class at its sibling seams: New words, the crossings, Replace All Keys, Reset")
struct PairRefusalSiblingSeamTests {
    static func expectRefused(
        _ air: EX, _ refusal: ExecutorRefusal, _ row: String, sourceLocation: SourceLocation = #_sourceLocation,
        _ press: (ProtectionExecutor, inout UnlockedLibrary) async throws -> Void
    ) async throws {
        let executor = air.executor()
        var library = try air.unlocked(executor)
        air.world.writes = []
        do {
            try await press(executor, &library)
            Issue.record("\(row): it landed", sourceLocation: sourceLocation)
        } catch let error as ExecutorRefusal {
            #expect(error == refusal, "\(row): \(error)", sourceLocation: sourceLocation)
        }
        #expect(air.world.writes.isEmpty, "\(row): the refused door wrote \(air.world.writeLog())", sourceLocation: sourceLocation)
        #expect(library.section.actInFlight == nil, sourceLocation: sourceLocation)
    }

    /// F-4's first seam: New words' synced arm verifies the current passphrase against the vault.
    @Test(arguments: ProtectionMode.allCases)
    func newWordsWithTheOldPassphraseNamesTheChange(_ mode: ProtectionMode) async throws {
        let (mac, air, _, _) = try await pairMovedElsewhere(mode, gate: mode == .castle ? .alwaysAsk : nil)
        let vault = try pairVault(mac)
        let changed = ExecutorRefusal.passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt)
        try await Self.expectRefused(air, changed, "New words, \(mode), the old passphrase") { executor, library in
            _ = try await executor.regenerateWords(&library, passphrase: air.passphrase, newWords: try PF.words())
        }
        try await Self.expectRefused(air, .passphraseDoesNotOpen, "New words, \(mode), neither") { executor, library in
            _ = try await executor.regenerateWords(&library, passphrase: "not any passphrase of hers", newWords: try PF.words())
        }
    }

    /// F-4's second seam: `doorSecrets`' synced arm (Use Castle, Use Standard, Replace All Keys).
    @Test(arguments: ProtectionMode.allCases)
    func theCrossingsAndReplaceAllKeysWithTheOldPassphraseNameTheChange(_ mode: ProtectionMode) async throws {
        let (mac, air, _, _) = try await pairMovedElsewhere(mode, gate: mode == .castle ? .alwaysAsk : nil)
        let vault = try pairVault(mac)
        let changed = ExecutorRefusal.passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt)
        let old = TypedSecrets(passphrase: air.passphrase, words: air.words)
        try await Self.expectRefused(air, changed, "the crossing, \(mode), the old passphrase") { executor, library in
            if mode == .standard {
                _ = try await executor.useCastle(&library, typed: old, gate: .alwaysAsk)
            } else {
                _ = try await executor.useStandard(&library, typed: old)
            }
        }
        try await Self.expectRefused(air, changed, "Replace All Keys, \(mode), the old passphrase") { executor, library in
            _ = try await executor.replaceAllKeys(&library, typed: old)
        }
        try await Self.expectRefused(air, .passphraseDoesNotOpen, "Replace All Keys, \(mode), neither") { executor, library in
            _ = try await executor.replaceAllKeys(&library, typed: TypedSecrets(passphrase: "not any passphrase of hers", words: air.words))
        }
    }

    /// The words twin at `doorSecrets`: the account's words re-made elsewhere; the OLD words (they open this library —
    /// its own lock) typed beside the account's passphrase.
    @Test(arguments: ProtectionMode.allCases)
    func theCrossingsWithTheOldWordsPointAtTheFollow(_ mode: ProtectionMode) async throws {
        let (_, air, _, _) = try await pairMovedElsewhere(
            mode, gate: mode == .castle ? .alwaysAsk : nil, passphrase: false, words: true)
        #expect(try air.world.liveFormat3?.open(.words(air.words), floor: PF.floor) == air.key, "the fixture")
        let typed = TypedSecrets(passphrase: air.passphrase, words: air.words)
        try await Self.expectRefused(air, .accountMoved, "Replace All Keys, \(mode), the old words") { executor, library in
            _ = try await executor.replaceAllKeys(&library, typed: typed)
        }
        try await Self.expectRefused(air, .wordsDoNotOpen, "Replace All Keys, \(mode), words of nobody's") { executor, library in
            _ = try await executor.replaceAllKeys(&library, typed: TypedSecrets(passphrase: air.passphrase, words: try PF.words()))
        }
    }

    /// The words twin at Reset forgotten passphrase (Castle, by the words — `holdSyncKeysForTheSession`): no keys held
    /// (Always ask, unlocked by the OLD words), the old words verified against this library, the vault refusing them.
    @Test func resetByTheOldWordsPointsAtTheFollow() async throws {
        let (_, air, _, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk, passphrase: false, words: true)
        air.world.session = [:]
        try await Self.expectRefused(air, .accountMoved, "Reset, Castle, the old words") { executor, library in
            _ = try await executor.resetPassphrase(&library, authorization: .words(air.words), new: "a passphrase chosen today")
        }
    }
}

/// F-10 (sweep rows 8–9), on R-529-5's brief: the class's words twin INSIDE THE FOLLOW. Old words typed at a follow —
/// they open THIS library (its own lock) but the account's words were changed elsewhere — said "Those twelve words don't
/// open this library." Now `wordsChangedElsewhere(device:day:)` (VX-113's twin, the vault's last writer and day); words
/// that open neither keep the plain refusal. RED ON THE PRE-FIX TREE.
@Suite("VX-529 P7-2 — the follow's words arms name a words change elsewhere")
struct PairFollowWordsRefusalTests {
    /// Row 8 — a posture follow whose words also changed elsewhere: the Mac re-made the words, then entered Castle.
    @Test func theFollowIntoCastleWithTheOldWordsNamesTheChange() async throws {
        let mac = try EX(.standard, synced: true)
        let air = try EX(.standard, synced: true, joining: mac)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        let fresh = try PF.words()
        _ = try await macExecutor.regenerateWords(&macLibrary, passphrase: mac.passphrase, newWords: fresh)
        _ = try await macExecutor.useCastle(&macLibrary, typed: TypedSecrets(passphrase: mac.passphrase, words: fresh), gate: .alwaysAsk)
        let vault = try pairVault(mac)
        #expect(try air.world.liveFormat3?.open(.words(air.words), floor: PF.floor) == air.key, "the fixture")
        try await PairRefusalSiblingSeamTests.expectRefused(
            air, .wordsChangedElsewhere(device: "Mac A", day: vault.updatedAt), "the follow into Castle, the old words"
        ) { executor, library in
            _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: air.words))
        }
        try await PairRefusalSiblingSeamTests.expectRefused(air, .wordsDoNotOpen, "the follow into Castle, nobody's words") {
            executor, library in
            _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: try PF.words()))
        }
    }

    /// Row 9 — the pair catch-up's own door: both halves moved; the OLD words typed (the E14 / words-arm ask).
    @Test(arguments: ProtectionMode.allCases)
    func thePairDoorWithTheOldWordsNamesTheChange(_ mode: ProtectionMode) async throws {
        let (mac, air, _, _) = try await pairMovedElsewhere(
            mode, gate: mode == .castle ? .alwaysAsk : nil, passphrase: true, words: true)
        let vault = try pairVault(mac)
        try await PairRefusalSiblingSeamTests.expectRefused(
            air, .wordsChangedElsewhere(device: "Mac A", day: vault.updatedAt), "the pair door, \(mode), the old words"
        ) { executor, library in
            _ = try await executor.follow(&library, kind: .pairChanged(passphrase: true, words: true), typed: TypedSecrets(words: air.words))
        }
        try await PairRefusalSiblingSeamTests.expectRefused(air, .wordsDoNotOpen, "the pair door, \(mode), nobody's words") {
            executor, library in
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: true, words: true), typed: TypedSecrets(words: try PF.words()))
        }
    }
}
