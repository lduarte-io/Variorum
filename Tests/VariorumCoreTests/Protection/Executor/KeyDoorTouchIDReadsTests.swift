//
//  KeyDoorTouchIDReadsTests.swift
//  VariorumCoreTests — VX-529 unit 3, the rider VX-530 (VX-510 unit B4's O-B4-1): A CASTLE + TOUCH ID KEY DOOR ASKS TOUCH ID
//  ONCE AT MOST — and not at all where a secret in hand or session memory already holds the account's keys. THE TRACE (the
//  run record's UNIT 3 — LIVE STATUS, VX-530): the door's `holdSyncKeysForTheSession` read the account's Touch ID sync-keys
//  item FIRST — before the typed secret it was handed (which derives the same keys from the vault) and before session
//  memory — and handed nothing on; the act's vault step then read the SAME item again in `syncMaterial` (custody before
//  session). On the production leaf every such read mints its own `LAContext`: a sheet each. The counting leaf is the
//  world's `syncKeysTouchIDReads` (VX-517's). Change passphrase: two reads → none; Reset by Touch ID with nothing in hand:
//  two → one; with session memory loaded (a Touch ID or typed unlock's): two → none; Reset by the words: one → none.
//  RED on the pre-fix tree. Headless core.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 unit 3 — VX-530: a Castle + Touch ID key door reads its Touch ID sync-keys item at most once")
struct KeyDoorTouchIDReadsTests {
    static let new = "a castle passphrase made anew"

    /// A synced Castle + Touch ID library: the account's keys in the Touch ID item (rule 15's Castle way), session memory
    /// EMPTY (nothing loaded them — the worst case), signed in.
    private func castleTouchIDSynced() throws -> (EX, ProtectionExecutor, UnlockedLibrary, String) {
        let fixture = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(fixture.account)
        #expect(fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] == fixture.material)
        #expect(fixture.world.session[account] == nil)
        let executor = fixture.executor()
        return (fixture, executor, try fixture.unlocked(executor), account)
    }

    /// The act landed: the account's vault opens under the NEW passphrase, and the library's key file too.
    private func expectLanded(_ fixture: EX, _ library: UnlockedLibrary, _ account: String) throws {
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.vault.master(passphrase: try PassphraseKey.derive(Self.new, kdf: vault.vault.kdf), words: nil) != nil,
                "the account's lock re-made (rule 7)")
        #expect(try fixture.world.liveFormat3?.open(passphrase: .passphrase(Self.new), floor: PF.floor) == library.key)
        #expect(fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] == fixture.material,
                "the item read, never written")
        expectSettled(fixture, library)
    }

    /// **Change passphrase (red on old: two reads).** The typed CURRENT passphrase opens the account's vault, so the keys
    /// derive from it at the door and ride into the act — no Touch ID sheet at all.
    @Test func changePassphraseReadsTheTouchIDItemNever() async throws {
        let (fixture, executor, library, account) = try castleTouchIDSynced()
        var open = library
        let before = fixture.world.syncKeysTouchIDReads
        _ = try await executor.changePassphrase(&open, current: fixture.passphrase, new: Self.new)
        #expect(fixture.world.syncKeysTouchIDReads - before == 0, "the secret in hand derives the keys — no prompt")
        try expectLanded(fixture, open, account)
    }

    /// **Reset by Touch ID, nothing in hand (red on old: two reads).** The press confirmed presence on the LIBRARY's item
    /// (the app's ruled presence confirm — a different item, not counted here); the account's keys are only in the Touch
    /// ID sync-keys item, read LAST and ONCE, then carried into the act.
    @Test func resetByTouchIDReadsTheTouchIDItemOnce() async throws {
        let (fixture, executor, library, account) = try castleTouchIDSynced()
        var open = library
        let before = fixture.world.syncKeysTouchIDReads
        _ = try await executor.resetPassphrase(&open, authorization: .touchID, new: Self.new)
        #expect(fixture.world.syncKeysTouchIDReads - before == 1, "once per act — never twice")
        try expectLanded(fixture, open, account)
    }

    /// **Reset by Touch ID with session memory loaded (red on old: two reads)** — what a Touch ID unlock (VX-487 (b)) or a
    /// typed unlock (VX-501) leaves: the keys are in hand; no sheet.
    @Test func resetByTouchIDWithTheKeysInSessionReadsNothing() async throws {
        let (fixture, executor, library, account) = try castleTouchIDSynced()
        fixture.world.session[account] = fixture.material
        var open = library
        let before = fixture.world.syncKeysTouchIDReads
        _ = try await executor.resetPassphrase(&open, authorization: .touchID, new: Self.new)
        #expect(fixture.world.syncKeysTouchIDReads - before == 0, "session memory first")
        try expectLanded(fixture, open, account)
    }

    /// **Reset by the words (red on old: one read).** The typed words open the account's vault: no sheet.
    @Test func resetByTheWordsReadsTheTouchIDItemNever() async throws {
        let (fixture, executor, library, account) = try castleTouchIDSynced()
        var open = library
        let before = fixture.world.syncKeysTouchIDReads
        _ = try await executor.resetPassphrase(&open, authorization: .words(fixture.words), new: Self.new)
        #expect(fixture.world.syncKeysTouchIDReads - before == 0, "the words in hand derive the keys")
        try expectLanded(fixture, open, account)
    }

    /// A guard (green on both sides): STALE session memory (another sync key's) never shadows the item — the door reads
    /// the Touch ID item, once, and the act lands.
    @Test func staleSessionMemoryNeverShadowsTheItem() async throws {
        let (fixture, executor, library, account) = try castleTouchIDSynced()
        fixture.world.session[account] = AccountKeys(
            master: Data(repeating: 7, count: 32), rowKeyID: "an-older-sync-key", rowKey: Data(repeating: 8, count: 32))
        var open = library
        let before = fixture.world.syncKeysTouchIDReads
        _ = try await executor.resetPassphrase(&open, authorization: .touchID, new: Self.new)
        #expect(fixture.world.syncKeysTouchIDReads - before <= 2, "the item answers")
        try expectLanded(fixture, open, account)
    }
}
