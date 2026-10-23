//
//  OneSyncKeysLeafTests.swift
//  VariorumTests — VX-487 F-M1-1 (RULED option (i), `notes/plans/fixes/vx-488-window-hotfixes.md`): THE PROCESS'S ONE
//  SYNC-KEYS LEAF. Session memory (Always ask's custody, and since VX-487 (a)/(b) the Castle + Touch ID hold too) lives in
//  `KeychainSyncKeysLeaf`'s instance. Every re-keying act ends in a REOPEN that composes a fresh `ProtectionSystem`
//  (`AppBootstrap.reopenAround` → `beginOpening` → `roadInputs.compose()`), and before this each system minted its OWN leaf
//  — so an act's hold died at the act's own reopen ("Sync locked" right after joining a Castle account, her Air crossing).
//  The bootstrap now mints ONE leaf for the process and hands it to every system the road composes (VX-423's
//  one-authority shape); the explicit clears (the lock's drop, a rollback's, a leave's) reach that one leaf unchanged.
//    - THE COMPOSITION (source): the product mints the leaf once, in the bootstrap, and every production system is handed
//      it. RED on the pre-fix tree (the mint sat in `ProtectionSystem.init`'s default — one per system).
//    - THE ROAD (behavioral, through the PRODUCTION composition — `RoadInputs.live` → `compose()` → `ProtectionSystem.live`,
//      the planted world shares one leaf set and cannot see this): keys held through one composed system survive into the
//      next system the same road composes. RED by behavioral revert (the per-system mint restored).
//    - THE CLEARS (a guard): the lock's drop and an executor's clear (a rollback's / a leave's `holdInSession(nil, …)`)
//      still clear — through the shared leaf, for every system the road composes.
//  Composing reads nothing: no slot, keychain item or network is touched (the leaves' constructors only keep their
//  inputs; session memory is the leaf's instance dictionary).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-487 F-M1-1 — the process's one sync-keys leaf: the composition (source)")
struct OneSyncKeysLeafCompositionTests {
    typealias Sources = OneRefreshAuthorityCompositionTests

    /// `name(` as a construction — never a longer name ending in it.
    static func constructions(of name: String, in text: String) -> Int {
        text.ranges(of: name + "(").filter { range in
            guard range.lowerBound > text.startIndex else { return true }
            let before = text[text.index(before: range.lowerBound)]
            return !(before.isLetter || before.isNumber || before == "_")
        }.count
    }

    static func mints(of name: String) throws -> [String: Int] {
        var found: [String: Int] = [:]
        for url in Sources.productSources() {
            let count = constructions(of: name, in: try Sources.code(url))
            if count > 0 { found[url.lastPathComponent, default: 0] += count }
        }
        return found
    }

    @Test func theProductMintsItsSyncKeysLeafOnceInTheBootstrapAndHandsItToEverySystem() throws {
        #expect(Sources.productSources().count > 100, "the walk reads the product's sources")
        #expect(try Self.mints(of: "KeychainSyncKeysLeaf") == ["AppBootstrap.swift": 1],
                "ONE sync-keys leaf per process, minted by the bootstrap — never one per composed system")
        #expect(try Self.mints(of: "ProtectionSystem") == ["ProtectionSystem.swift": 1],
                "the product's one system construction is `ProtectionSystem.live`'s")
        let bootstrap = try Sources.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("RoadInputs.live(variant: variant, auth: auth, syncKeys: syncKeys)"),
                "the bootstrap hands its one leaf to the road")
        let road = try Sources.code("Shared/Protection/ProtectionOpenRoad.swift")
        #expect(road.contains("ProtectionSystem.live(variant: variant, session: auth, syncKeys: syncKeys)"),
                "the road hands it to every system it composes")
        let system = try Sources.code("Shared/Protection/ProtectionSystem.swift")
        #expect(system.contains("ProtectionSystem(scope: variant.rawValue, places: places, syncKeys: syncKeys, session: session)"),
                "`live` hands it to the system")
    }
}

@Suite("VX-487 F-M1-1 — the process's one sync-keys leaf: through the production composition")
@MainActor
struct OneSyncKeysLeafRoadTests {
    static let account = "acct-vx487"

    static func keys(_ rowKeyID: String) -> AccountKeys {
        AccountKeys(master: Data(repeating: 7, count: 32), rowKeyID: rowKeyID, rowKey: Data(repeating: 8, count: 32))
    }

    /// The production road's inputs as the bootstrap composes them: its variant, an authority (signed out, in memory —
    /// nothing is dialled), and ONE sync-keys leaf, the production type.
    static func liveRoad() -> RoadInputs {
        RoadInputs.live(
            variant: .dev, auth: AuthSession(configuration: ProjectConfig.variorumAuth, store: .inMemory()),
            syncKeys: KeychainSyncKeysLeaf(scope: AppDatabase.StoreVariant.dev.rawValue))
    }

    static func executor(_ system: ProtectionSystem) -> ProtectionExecutor {
        ProtectionExecutor(
            leaves: system.leaves,
            configuration: ExecutorConfiguration(
                scope: system.scope, libraryID: "", deviceName: "Test Mac", floor: .relaxedForTests, session: .signedOut),
            guards: .all)
    }

    /// A road session over `system` whose record names the account (the lock's drop reads only that).
    static func session(_ system: ProtectionSystem) -> ProtectionRoadSession {
        let key = StoreKey.mint()
        let library = UnlockedLibrary(
            key: key,
            record: ProtectionRecord.minting(
                libraryID: "library-vx487", mode: .castle, account: account, currentFingerprint: KeyFingerprint.of(key),
                at: Date()),
            section: DeviceSection(deviceID: "device-vx487", settings: DeviceSettings(gateStyle: .touchID)),
            memory: nil, keyFile: nil)
        return ProtectionRoadSession(
            system: system, executor: executor(system), library: library, report: RoadOpenReport(), isFresh: false,
            writes: false)
    }

    /// THE PIN: an act holds the keys through the system it ran on; its REOPEN composes a fresh system (as every
    /// re-keying act's does); the reopened system — the one the engine's session is built on — reads them. RED on the
    /// per-system mint: the reopened system's leaf was a new, empty one.
    @Test func keysHeldThroughOneComposedSystemSurviveIntoTheNextTheSameRoadComposes() throws {
        let road = Self.liveRoad()
        let acted = try #require(road.compose(), "the production road composes").system
        let reopened = try #require(road.compose(), "…and again — the act's reopen").system
        #expect(acted !== reopened, "a fresh system per composition, as every reopen makes")
        acted.leaves.syncKeys.holdInSession(Self.keys("held-by-the-act"), accountID: Self.account)
        #expect(reopened.leaves.syncKeys.sessionSyncKeys(accountID: Self.account)?.rowKeyID == "held-by-the-act",
                "the act's hold reaches the reopened system")
        #expect(Self.executor(reopened).leaves.syncKeys.sessionSyncKeys(accountID: Self.account) != nil,
                "…and every executor built on it")
        #expect(acted.leaves.syncKeys === reopened.leaves.syncKeys, "ONE leaf behind both")
    }

    /// THE GUARD: the explicit clears keep their meaning on the shared leaf — the lock's drop
    /// (`ProtectionRoadLock.dropSessionMemory`) on a session a LATER composition built, and an executor's own clear (a
    /// rollback's, a leave's: `leaves.syncKeys.holdInSession(nil, …)`), each clear what any composed system held, for
    /// every system the road composes after.
    @Test func aKeyChangePathsExplicitClearStillClearsThroughTheSharedLeaf() throws {
        let road = Self.liveRoad()
        let acted = try #require(road.compose()).system
        acted.leaves.syncKeys.holdInSession(Self.keys("held"), accountID: Self.account)
        let locked = try #require(road.compose()).system
        ProtectionRoadLock.dropSessionMemory(Self.session(locked))
        #expect(acted.leaves.syncKeys.sessionSyncKeys(accountID: Self.account) == nil, "gone at the relock")
        #expect(try #require(road.compose()).system.leaves.syncKeys.sessionSyncKeys(accountID: Self.account) == nil,
                "…for every system composed after")

        acted.leaves.syncKeys.holdInSession(Self.keys("held-again"), accountID: Self.account)
        let rolledBack = try #require(road.compose()).system
        Self.executor(rolledBack).leaves.syncKeys.holdInSession(nil, accountID: Self.account)
        #expect(acted.leaves.syncKeys.sessionSyncKeys(accountID: Self.account) == nil,
                "a rollback's or a leave's clear, through any executor's leaves")
    }
}
