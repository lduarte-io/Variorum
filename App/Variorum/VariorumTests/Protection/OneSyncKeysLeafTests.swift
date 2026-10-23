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
        #expect(system.contains("ProtectionSystem(scope: variant.rawValue, places: places, session: session, syncKeys: syncKeys)"),
                "`live` hands it to the system")
    }
}
