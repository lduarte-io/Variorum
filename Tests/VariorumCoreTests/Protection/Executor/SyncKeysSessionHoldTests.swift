//
//  SyncKeysSessionHoldTests.swift
//  VariorumCoreTests — VX-487 (VX-488 M1, pin 1): THE CASTLE + TOUCH ID ARM HOLDS THE ACCOUNT'S SYNC KEYS IN SESSION TOO.
//  `ActContext.holdSyncKeys` files the keys the account's way (rule 15's custody): under Castle with Touch ID chosen and
//  a finger enrolled, the Touch ID item — and, since VX-487 (a), session memory beside it, because the engine's provider
//  never reads the Touch ID item (a press per round is nobody's wish — P-VX307-U1-3: "rounds run while an act or unlock
//  has loaded session memory"). RED on the pre-fix tree: the arm ended `holdInSession(nil, …)`, so after the act the keys
//  lived ONLY in the Touch ID item and every round refused `encryptionKeysUnavailable` ("Sync locked").
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-487 (a) — the castle + Touch ID arm holds the account's sync keys in session too")
struct SyncKeysSessionHoldTests {
    /// Use Castle on a synced library, Touch ID chosen and a finger enrolled (rules 11, 15): the account's ONE vault write
    /// mints the new sync key; the act files it in the Touch ID item (as before) AND holds it in session memory (VX-487).
    @Test func useCastleWithTouchIDHoldsTheNewKeysInSessionBesideTheItem() async throws {
        let fixture = try EX(.standard, synced: true)
        let account = try #require(fixture.account)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let vault = try #require(fixture.world.server.snapshot(account))
        let item = try #require(
            fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)], "the Touch ID item, as before")
        #expect(item.rowKeyID == vault.rowKeyID, "the item holds the account's NEW sync key")
        #expect(fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)] == nil, "no silent item")
        #expect(fixture.world.session[account] == item,
                "VX-487 (a): session memory holds the keys the act just filed — the engine reads session, never the item")
        expectSettled(fixture, library)
    }

    /// HER PATH (VX-487's live report): a Standard library JOINS an account that is in Castle, Touch ID chosen — joining
    /// is entering Castle (rule 7); the account's keys are filed the Castle way and held in session too.
    @Test func joiningACastleAccountWithTouchIDHoldsTheAccountsKeysInSession() async throws {
        let mac = try EX(.castle, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let account = try #require(mac.account)
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words), gate: .touchID)
        #expect(laptop.liveRecord?.mode == .castle && laptop.liveRecord?.account == account)
        let item = try #require(
            laptop.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)], "the Touch ID item")
        #expect(item.rowKeyID == mac.world.server.snapshot(account)?.rowKeyID)
        #expect(laptop.world.session[account] == item, "VX-487 (a): held in session beside the item")
        expectSettled(laptop, library)
    }

    /// The other arms, unchanged (a guard — green on both sides by design): Castle under Always ask holds the keys in
    /// session ONLY (no Touch ID item); Standard files them silently and holds nothing in session (the provider reads the
    /// silent item itself).
    @Test func theOtherArmsAreUnchanged() async throws {
        let ask = try EX(.standard, synced: true)
        let account = try #require(ask.account)
        let e1 = ask.executor()
        var l1 = try ask.unlocked(e1)
        _ = try await e1.useCastle(&l1, typed: ask.typed, gate: .alwaysAsk)
        #expect(ask.world.syncItems.keys.filter { $0.accountID == account }.isEmpty, "Always ask: no item at all")
        #expect(ask.world.session[account]?.rowKeyID == ask.world.server.snapshot(account)?.rowKeyID)

        let standard = try EX(.standard)
        let other = PF.id()
        let e2 = standard.executor(session: .signedIn(accountID: other, email: nil))
        var l2 = try standard.unlocked(e2)
        _ = try await e2.setUpSync(&l2, typed: standard.typed)
        #expect(standard.world.syncItems.keys.map(\.itemClass) == [.silent])
        #expect(standard.world.session[other] == nil, "Standard holds nothing in session")
    }
}
