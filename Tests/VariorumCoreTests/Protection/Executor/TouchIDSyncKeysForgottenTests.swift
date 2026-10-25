//
//  TouchIDSyncKeysForgottenTests.swift
//  VariorumCoreTests — VX-517 (the VX-510 run record's D-B8, on unit B2's trace T-B5-2 / T-B5-4): the TOUCH ID class of
//  sync keys was never forgotten. The production leaf's listing (`KeychainSyncKeysLeaf.syncKeyItems()`) is BLIND to a
//  Touch ID item with no silent sibling — it skips an item that would need authentication and probes by name only for
//  the accounts its silent items name (production wires no candidates) — and every forget read that listing: the leaves'
//  `forgetSyncKeys(of:)`, the finishing `forgetUnboundSyncKeys`, the plan runner's rollback sweep, and `holdSyncKeys`'
//  drops (whose listing was taken BEFORE the silent write). So a Castle + Touch ID library's item outlived its leave, Use
//  Standard, the follow out of Castle and a rolled-back join — rule 16's "this Mac forgets its sync keys", untrue — and
//  every reader that took the Touch ID class FIRST then met it on a STANDARD library: a prompt per read (VX-503's), and,
//  where the stale item's keys were not the account's current ones, a key door that refused as "the account moved" and a
//  set-up's finish that bound nothing (the stale item shadowed the silent one).
//  THE FIX (D-B8 (a) + (c)): every forget and drop deletes BOTH classes BY NAME for every account it means (a delete of
//  nothing is nothing; an ACL'd item's delete never prompts); and the Touch ID class is read only where the account's keys
//  can be filed there — a library in Castle, or an act taking one into Castle (its own filing before its swap); a library
//  that is and stays Standard files silently (rule 15) and never reads it.
//  Over `ExecutorWorld` with `syncKeysListingLikeProduction` ON (the production listing — never the all-seeing one, which
//  is why no test saw this) and `syncKeysTouchIDReads` (every Touch ID sync-keys read — a prompt on the real leaf).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-517 (D-B8) — the Touch ID class of sync keys is forgotten by name, and a Standard library never reads it")
struct TouchIDSyncKeysForgottenTests {
    /// Keys a LEFT library leaves in a Touch ID item for the account (not the account's current ones).
    static func staleKeys() -> AccountKeys {
        AccountKeys(master: Data(repeating: 7, count: 32), rowKeyID: "stale-row-key", rowKey: Data(repeating: 8, count: 32))
    }

    static func item(_ fixture: EX, _ account: String, _ itemClass: ProtectionNames.CustodyClass) -> AccountKeys? {
        fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: itemClass)]
    }

    /// The write after which `act` must crash, read off a dry run's write log by `index`; then a fresh fixture, the act
    /// crashing exactly there (the write lands, then the process dies). Returns the crashed fixture.
    static func crashed(
        _ make: () async throws -> EX, at index: ([String]) -> Int?,
        act: (EX, ProtectionExecutor, inout UnlockedLibrary) async throws -> Void
    ) async throws -> EX {
        let dry = try await make()
        let dryExecutor = dry.executor()
        var dryLibrary = try dry.unlocked(dryExecutor)
        try await act(dry, dryExecutor, &dryLibrary)
        let log = dry.world.writeLog()
        let crashAt = try #require(index(log), "the dry run's log: \(log)")
        let fixture = try await make()
        fixture.world.crashAfterWrites = crashAt + 1
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        do {
            try await act(fixture, executor, &library)
            Issue.record("the act did not crash where the dry run's log said")
        } catch is SimulatedCrash {}
        return fixture
    }

    // MARK: - (a) the forgets and drops, BY NAME

    /// RULE 16 — a Castle + Touch ID library's LEAVE forgets its Touch ID item (each of the three leaves). RED on the pre-fix
    /// tree: the leave's forget walked the listing, blind to the item (its only one — Castle keeps no silent item).
    @Test(arguments: [ProtectionAct.thisMacOnly, .stopSyncingHere, .deleteAccountHere])
    func vx517_aCastleTouchIDLibrarysLeaveForgetsItsTouchIDItem(_ act: ProtectionAct) async throws {
        let fixture = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(fixture.account)
        fixture.world.syncKeysListingLikeProduction = true
        #expect(Self.item(fixture, account, .touchid) != nil, "precondition: the account's keys in the Touch ID item")
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(act, &library)
        #expect(fixture.liveRecord?.account == nil, "the record stops naming the account")
        #expect(Self.item(fixture, account, .touchid) == nil, "this Mac forgets the account's Touch ID item")
        #expect(fixture.world.syncItems.isEmpty && fixture.world.session[account] == nil)
        #expect(fixture.world.syncKeysTouchIDReads == 0, "a leave reads no sync keys")
        expectSettled(fixture, library)
    }

    /// USE STANDARD on a synced Castle + Touch ID library (both secrets typed) leaves NO Touch ID item and reads none. RED
    /// on the pre-fix tree: `holdSyncKeys`' drop read a listing taken before the silent write — no sibling yet, the item
    /// unlisted, never dropped. (The no-read leg is unit B2's VX-503 fix, guarded here.)
    @Test func vx517_useStandardOnASyncedCastleTouchIDLibraryLeavesNoTouchIDItem() async throws {
        let fixture = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(fixture.account)
        fixture.world.syncKeysListingLikeProduction = true
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        #expect(fixture.liveRecord?.mode == .standard && fixture.world.server.snapshot(account)?.mode == .standard)
        #expect(Self.item(fixture, account, .touchid) == nil, "the Castle-era Touch ID item goes with the posture")
        #expect(Self.item(fixture, account, .silent) == fixture.material, "the keys filed silently (Standard's custody)")
        #expect(fixture.world.syncKeysTouchIDReads == 0, "no Touch ID read — no prompt")
        expectSettled(fixture, library)
    }

    /// …and a LATER KEY DOOR on that (now Standard) library reads no Touch ID. RED on the pre-fix tree: the Castle-era item
    /// stood (above), and Change passphrase read the Touch ID class first — twice (the door's session hold, then its vault
    /// step's custody fallback): two prompts on a Standard library.
    @Test func vx517_aKeyDoorAfterUseStandardReadsNoTouchID() async throws {
        let fixture = try EX(.castle, synced: true, gate: .touchID)
        fixture.world.syncKeysListingLikeProduction = true
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        let reads = fixture.world.syncKeysTouchIDReads
        _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "a passphrase for the standard era")
        #expect(fixture.world.syncKeysTouchIDReads == reads, "the key door on a Standard library reads no Touch ID")
        let account = try #require(fixture.account)
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.vault.master(
            passphrase: try PassphraseKey.derive("a passphrase for the standard era", kdf: vault.vault.kdf), words: nil) != nil,
                "the door re-wrapped the account's lock")
        expectSettled(fixture, library)
    }

    /// The FOLLOW OUT OF CASTLE (rule 12 — nothing typed) still reads its Touch ID item (custody serves: the library is in
    /// Castle until its swap — a guard on (c)), files the keys silently, and leaves NO Touch ID item. The last leg is RED on
    /// the pre-fix tree (the same blind drop as Use Standard's).
    @Test func vx517_theQuietFollowOutReadsItsTouchIDItemThenLeavesNone() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, gate: .touchID, joining: mac)
        let account = try #require(phone.account)
        phone.world.syncKeysListingLikeProduction = true
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let outcome = try await executor.follow(&library, kind: .intoStandard, typed: .none)
        #expect(outcome.notices.contains(.followedOutOfCastle) && phone.liveRecord?.mode == .standard)
        #expect(phone.world.syncKeysTouchIDReads > 0, "guard: the quiet follow out read its Touch ID item (nothing typed)")
        #expect(Self.item(phone, account, .silent) != nil, "the keys filed silently")
        #expect(Self.item(phone, account, .touchid) == nil, "and the Touch ID item goes with the posture")
        expectSettled(phone, library)
    }

    /// A STANDARD JOIN with a stale Touch ID item standing (VX-503's road) leaves none behind: the join's silent filing drops
    /// the other class by name. RED on the pre-fix tree (T-B5-4: "the stale item survives the join").
    @Test func vx517_aStandardJoinLeavesNoStaleTouchIDItem() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let account = try #require(mac.account)
        laptop.account = account
        laptop.world.syncKeysListingLikeProduction = true
        laptop.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] = Self.staleKeys()
        let executor = laptop.executor()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(laptop.liveRecord?.account == account && laptop.liveRecord?.mode == .standard)
        #expect(Self.item(laptop, account, .silent) == mac.material, "the account's keys, filed silently")
        #expect(Self.item(laptop, account, .touchid) == nil, "the stale Touch ID item is gone")
        #expect(laptop.world.syncKeysTouchIDReads == 0, "no Touch ID read — no prompt")
        expectSettled(laptop, library)
    }

    /// A CASTLE join under ALWAYS ASK with a stale Touch ID item standing: the keys in session memory, no silent item, and no
    /// Touch ID item left. RED on the pre-fix tree (the Always-ask arm's drop read the blind listing).
    @Test func vx517_aCastleAlwaysAskFilingLeavesNoStaleTouchIDItem() async throws {
        let mac = try EX(.castle, synced: true, gate: .alwaysAsk)
        let laptop = try EX(.castle, gate: .alwaysAsk, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let account = try #require(mac.account)
        laptop.account = account
        laptop.world.syncKeysListingLikeProduction = true
        laptop.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] = Self.staleKeys()
        let executor = laptop.executor()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase), gate: .alwaysAsk)
        #expect(laptop.liveRecord?.account == account && laptop.liveRecord?.mode == .castle)
        #expect(laptop.world.session[account] == mac.material, "Always ask: the keys in session memory")
        #expect(Self.item(laptop, account, .silent) == nil, "Castle keeps no silent item")
        #expect(Self.item(laptop, account, .touchid) == nil, "Always ask keeps no Touch ID item — the stale one is gone")
        expectSettled(laptop, library)
    }

    /// How the next open comes to roll the crashed act back.
    enum RollbackRoad: String, CaseIterable, Sendable {
        /// The plan is gone: the sweep knows the act's account only by the sign-in.
        case planGone
        /// The plan stands, the vault is out of reach: the act's own account is in its plan.
        case vaultOutOfReach
        /// The plan stands, signed OUT at the open (the vault out of reach by the sign-in): only the plan names the account.
        case signedOutAtTheOpen
    }

    /// THE ROLLBACK SWEEP removes a Touch ID-only item: a Standard library joining a CASTLE account (Touch ID chosen) filed
    /// the account's keys in a Touch ID item before its swap, then crashed; the next open rolls the act back — with its plan
    /// gone; with its plan but the vault out of reach; with its plan, signed out. RED on the pre-fix tree: the sweep walked
    /// the blind listing and the picked-up Touch ID item survived the rollback (the signed-out road was added with Piece 4,
    /// its red shown by restoring the pre-fix product files — the record's RE-0).
    @Test(arguments: RollbackRoad.allCases)
    func vx517_theRollbackSweepRemovesATouchIDOnlyItem(_ road: RollbackRoad) async throws {
        let mac = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(mac.account)
        let laptop = try await Self.crashed({
            let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: ExecutorVault()))
            laptop.world.server.accounts = mac.world.server.accounts
            laptop.account = account
            laptop.world.syncKeysListingLikeProduction = true
            return laptop
        }, at: { $0.firstIndex(of: "sync+ touchid") }, act: { _, executor, library in
            _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase), gate: .touchID)
        })
        #expect(Self.item(laptop, account, .touchid) != nil, "precondition: the act filed the keys in a Touch ID item")
        #expect(laptop.liveRecord?.account == nil, "precondition: crashed before the swap")
        switch road {
        case .planGone: break
        case .vaultOutOfReach: laptop.world.server.reachable = false
        case .signedOutAtTheOpen: laptop.account = nil
        }
        let (outcome, library, _) = try await laptop.relaunchAndSettle(TypedSecrets.none, dropPlan: road == .planGone)
        #expect(outcome == .rolledBack(.enroll), "\(outcome)")
        #expect(laptop.liveRecord?.account == nil && laptop.liveRecord?.mode == .standard, "the old state")
        #expect(laptop.world.syncItems.isEmpty, "the keys the act picked up go with it — the Touch ID item included")
        #expect(laptop.world.session[account] == nil)
        expectSettled(laptop, library)
    }

    /// THE ROLLBACK'S SECOND SWEEP — the bound account's keys the act TOOK: a Standard library FOLLOWING its account into
    /// Castle (Touch ID chosen) filed the account's new keys in a Touch ID item (its silent item dropped), stamped the key it
    /// took, then crashed; the next open's resume cannot reach the vault and rolls back. The library is Standard again, so
    /// the Touch ID item is the act's Castle-way filing and goes. RED on the pre-fix tree: the sweep found it through the
    /// blind listing only, and it stayed.
    @Test func vx517_aRolledBackFollowIntoCastleLeavesNoTouchIDItem() async throws {
        var account = ""
        let phone = try await Self.crashed({
            let mac = try EX(.standard, synced: true)
            let phone = try EX(.standard, synced: true, joining: mac)
            let macExecutor = mac.executor()
            var macLibrary = try mac.unlocked(macExecutor)
            _ = try await macExecutor.useCastle(&macLibrary, typed: mac.typed, gate: .touchID)
            phone.world.syncKeysListingLikeProduction = true
            account = try #require(phone.account)
            return phone
        }, at: { log in
            // The act's stamp of the key it took — the plan written right after its Castle-way filing dropped the silent item.
            guard let dropped = log.firstIndex(of: "sync- silent") else { return nil }
            return log[(dropped + 1)...].firstIndex(of: "plan")
        }, act: { fixture, executor, library in
            _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(passphrase: fixture.passphrase),
                                          gate: .touchID)
        })
        #expect(Self.item(phone, account, .touchid) != nil, "precondition: the act filed the new keys in a Touch ID item")
        #expect(phone.liveRecord?.mode == .standard, "precondition: crashed before the swap")
        phone.world.server.reachable = false
        let (outcome, library, _) = try await phone.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.follow), "\(outcome)")
        #expect(phone.liveRecord?.mode == .standard && phone.liveRecord?.account == account, "the old state")
        #expect(Self.item(phone, account, .touchid) == nil, "the act's Castle-way filing goes with the rollback")
        expectSettled(phone, library)
    }

    /// THE FINISHING FORGET (`forgetUnboundSyncKeys`) removes the Touch ID item of the account the record no longer names: a
    /// Castle + Touch ID library's leave crashed after the record let the account go, its plan gone; the next open finishes
    /// it from the record. The account is known by name — the sign-in (the leave's own account). RED on the pre-fix tree:
    /// the finishing forget walked the blind listing.
    @Test func vx517_theFinishingForgetRemovesTheLeftAccountsTouchIDItem() async throws {
        let fixture = try await Self.crashed({
            let fixture = try EX(.castle, synced: true, gate: .touchID)
            fixture.world.syncKeysListingLikeProduction = true
            return fixture
        }, at: { log in
            // The leave's own record write (bindAccount) — the first record written after the act's plan.
            guard let plan = log.firstIndex(of: "plan") else { return nil }
            return log[(plan + 1)...].firstIndex { $0.hasPrefix("record") }
        }, act: { _, executor, library in
            _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        })
        let account = try #require(fixture.account)
        #expect(fixture.liveRecord?.account == nil, "precondition: the record let the account go before the crash")
        #expect(Self.item(fixture, account, .touchid) != nil, "precondition: the Touch ID item still stands")
        let (outcome, library, _) = try await fixture.relaunchAndSettle(TypedSecrets.none, dropPlan: true)
        guard case .finishedFromRecord = outcome else {
            Issue.record("finished from the record: \(outcome)")
            return
        }
        #expect(Self.item(fixture, account, .touchid) == nil, "the left account's Touch ID item is forgotten")
        #expect(fixture.world.syncItems.isEmpty && fixture.world.session[account] == nil)
        expectSettled(fixture, library)
    }

    // MARK: - (c) a Standard library never reads the Touch ID class

    /// A STANDARD library's key doors with a stale Touch ID item standing read no Touch ID and land. RED on the pre-fix
    /// tree: the door's session hold and its vault step's custody fallback read the Touch ID class FIRST — a prompt each
    /// on the real leaf — and the fallback took the stale item's keys ahead of the silent item's, so the act refused as
    /// "the account moved" (rolled back) though nothing had moved.
    @Test(arguments: [ProtectionAct.changePassphrase, .resetPassphrase])
    func vx517_aStandardKeyDoorWithAStaleTouchIDItemReadsNoneAndLands(_ door: ProtectionAct) async throws {
        let fixture = try EX(.standard, synced: true)
        let account = try #require(fixture.account)
        fixture.world.syncKeysListingLikeProduction = true
        fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] = Self.staleKeys()
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let new = "a new passphrase for this door"
        if door == .changePassphrase {
            _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: new)
        } else {
            _ = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: new)
        }
        #expect(fixture.world.syncKeysTouchIDReads == 0, "a Standard library reads no Touch ID — no prompt")
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.vault.master(passphrase: try PassphraseKey.derive(new, kdf: vault.vault.kdf), words: nil) != nil,
                "the door landed: the account's lock re-wrapped under the new passphrase")
        expectSettled(fixture, library)
    }

    /// A STANDARD set-up FINISHED FROM THE RECORD with a stale Touch ID item standing binds the library: the finish reads the
    /// silent item, never the Touch ID class. The set-up crashed right after filing its keys silently (before its drop), its
    /// plan gone. RED on the pre-fix tree: the finish read the Touch ID class first, took the stale keys, saw them not the
    /// vault's, and bound nothing — the library left unbound over an account it had just made.
    @Test func vx517_aStandardSetUpsFinishReadsNoTouchIDAndBinds() async throws {
        let account = PF.id()
        let fixture = try await Self.crashed({
            let fixture = try EX(.standard)
            fixture.account = account
            fixture.world.syncKeysListingLikeProduction = true
            fixture.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] = Self.staleKeys()
            return fixture
        }, at: { $0.firstIndex(of: "sync+ silent") }, act: { fixture, executor, library in
            _ = try await executor.setUpSync(&library, typed: fixture.typed)
        })
        #expect(fixture.world.server.snapshot(account) != nil && fixture.liveRecord?.account == nil,
                "precondition: the vault made, the library not yet bound")
        let reads = fixture.world.syncKeysTouchIDReads
        let (outcome, library, _) = try await fixture.relaunchAndSettle(TypedSecrets.none, dropPlan: true)
        guard case .finishedFromRecord = outcome else {
            Issue.record("finished from the record: \(outcome)")
            return
        }
        #expect(fixture.world.syncKeysTouchIDReads == reads, "the finish reads no Touch ID — no prompt")
        #expect(fixture.liveRecord?.account == account, "the finish bound the library to the vault it made")
        expectSettled(fixture, library)
    }

    // MARK: - Guards: Castle's own reads still work

    /// GUARD (green on both sides): a CASTLE + Touch ID library's key door still finds the account's keys in its Touch ID
    /// item (custody serves — the door's secrets are the NEW ones).
    /// VX-529 unit 3 — VX-530: FLIPPED DELIBERATELY from Change passphrase to Reset by Touch ID. Change no longer reads the
    /// item at all — its typed CURRENT passphrase opens the vault and derives the keys first (`KeyDoorTouchIDReadsTests`,
    /// the counting pin); Reset by Touch ID with nothing in hand is the door where the Touch ID item is the only source, so
    /// the guard's intent (Castle still finds its keys there) is pinned on it.
    @Test func aCastleTouchIDKeyDoorStillFindsItsKeysInItsTouchIDItem() async throws {
        let fixture = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(fixture.account)
        fixture.world.syncKeysListingLikeProduction = true
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.resetPassphrase(&library, authorization: .touchID, new: "a castle passphrase anew")
        #expect(fixture.world.syncKeysTouchIDReads > 0, "Castle reads its Touch ID item")
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(vault.vault.master(
            passphrase: try PassphraseKey.derive("a castle passphrase anew", kdf: vault.vault.kdf), words: nil) != nil)
        #expect(Self.item(fixture, account, .touchid) == fixture.material, "the Touch ID item stays (the posture's own)")
        expectSettled(fixture, library)
    }

    /// GUARD (green on both sides): an act TAKING a Standard library INTO Castle reads its own Touch ID filing before its
    /// swap — a join into a Castle account (Touch ID chosen) crashed right after filing the keys there, then resumed at the
    /// next open with NOTHING typed (the library opens by its quiet road): the resume finds the keys in the Touch ID item
    /// and finishes in Castle. (Reading the Touch ID class by the library's posture ALONE would leave this act in flight
    /// for good — rule 20.)
    @Test func anActIntoCastleResumedWithNothingTypedReadsItsOwnTouchIDFiling() async throws {
        let mac = try EX(.castle, synced: true, gate: .touchID)
        let account = try #require(mac.account)
        let laptop = try await Self.crashed({
            let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: ExecutorVault()))
            laptop.world.server.accounts = mac.world.server.accounts
            laptop.account = account
            laptop.world.syncKeysListingLikeProduction = true
            return laptop
        }, at: { $0.firstIndex(of: "sync+ touchid") }, act: { _, executor, library in
            _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase), gate: .touchID)
        })
        let (outcome, library, _) = try await laptop.relaunchAndSettle(TypedSecrets.none)
        guard case .resumed = outcome else {
            Issue.record("the act resumed and finished: \(outcome)")
            return
        }
        #expect(laptop.liveRecord?.mode == .castle && laptop.liveRecord?.account == account)
        #expect(Self.item(laptop, account, .touchid) == mac.material, "the keys filed the Castle way")
        expectSettled(laptop, library)
    }
}
