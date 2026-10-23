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

/// VX-488 ladder round 1, F1 (`notes/plans/fixes/vx-488-ladder-round-1.md` — THE FINAL CALLS): with the process's ONE
/// sync-keys leaf (F-M1-1), an account's session hold must leave with the library that earned it. MAKE THIS MY LIBRARY
/// (every adopt road's act — the swap) lands a record naming NO account, so it drops the OUTGOING record's account hold
/// (clear 1 — the load-bearing one: under Always ask session memory is the only custody, with no keychain item to iterate);
/// and the account family's finish-from-record step that forgets every unbound account's ITEMS forgets their session
/// holds beside them (clear 2 — `PlanRunner`'s rollback idiom). RED on the pre-fix tree: neither touched session memory.
@Suite("VX-488 R1 F1 — an adopt drops the outgoing account's session hold; the unbound forget clears session too")
struct SyncKeysSessionHoldAcrossAdoptTests {
    /// A synced library adopts a copy (rule 17 — a NEW library, no account): the hold for the account the outgoing record
    /// named goes. Always ask (session memory is the only custody) and Touch ID (the unlock's load held it) alike.
    @Test func makeThisMyLibraryDropsTheOutgoingAccountsSessionHold() async throws {
        for gate in [GateStyle.alwaysAsk, .touchID] {
            let mine = try EX(.castle, synced: true, gate: gate)
            let account = try #require(mine.account)
            let held = try #require(mine.material)
            mine.world.session[account] = held  // Always ask: the fixture's own; Touch ID: what the unlock's load holds
            let theirs = try EX(.castle, gate: .alwaysAsk)
            let (copy, catalog) = try plantCopy(
                mine, libraryID: theirs.libraryID, key: theirs.key, keyFile: try #require(theirs.world.liveKeyFile),
                record: theirs.liveRecord)
            let executor = mine.executor()
            var library = try mine.unlocked(executor)
            _ = try await executor.makeThisMyLibrary(
                &library, copy: copy, in: catalog, copySecrets: theirs.typed, currentPair: mine.typed)
            #expect(mine.liveRecord?.account == nil, "\(gate): the adopted library names no account (rule 17)")
            #expect(mine.world.session[account] == nil,
                    "\(gate): the outgoing account's session hold left with the library that earned it")
            expectSettled(mine, library)
        }
    }

    /// The account family's finish-from-record (a leave whose plan is gone, past its unbinding): `forgetUnboundSyncKeys`
    /// forgets the unbound account's session hold beside its items. (A real crash empties session memory; the hold is
    /// planted after the relaunch so the step's own clear is what the assertion sees.)
    @Test func theUnboundForgetClearsSessionBesideTheItems() async throws {
        let fixture = try EX(.castle, synced: true, gate: .alwaysAsk)
        let account = try #require(fixture.account)
        fixture.world.crashAfterWrites = 4  // the begin's three writes, then the leave's unbinding record write
        let e1 = fixture.executor()
        var l1 = try fixture.unlocked(e1)
        await #expect(throws: SimulatedCrash.self) { _ = try await e1.leaveAccount(.stopSyncingHere, &l1) }
        try #require(fixture.liveRecord?.account == nil, "the crash landed just past the record's unbinding")
        fixture.world.relaunch()
        fixture.world.plan = nil
        fixture.world.session[account] = try #require(fixture.material)
        let e2 = fixture.executor()
        var l2 = try fixture.unlocked(e2)
        let settled = try await e2.settle(&l2, typed: fixture.typed)
        guard case .finishedFromRecord = settled else {
            Issue.record("the leave finishes from its record: \(settled)")
            return
        }
        #expect(fixture.world.session[account] == nil, "the unbound account's session hold forgotten with its items")
        expectSettled(fixture, l2)
    }
}
