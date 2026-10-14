//
//  FixedScenariosAccounts.swift
//  VariorumCoreTests — VX-305 U4: the fixed scenarios about ACCOUNTS — every
//  leave re-keying, joining by the joining rules, Replace All Keys and its
//  follow, the signed-in/out/other-account walk, This Mac Only (§6's list).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced account in `mode` on Mac A, built from today's formats, and its
/// other devices (each holding its own library, joined to the account).
func syncedWorld(_ mode: ProtectionMode, devices names: [String] = ["macA"], seed: UInt64 = 11,
                 gate: GateStyle = .touchID, guards: ProtectionGuards = .all) throws -> (SWorld, String) {
    var account = ""
    let world = try scenarioWorld(seed, guards: guards) { w in
        account = w.rng.uuid()
        try w.todayAccount(account, mode: mode)
        for name in names { try w.today(on: w.device(name), TodaySpec(mode: mode, gate: gate, account: account)) }
    }
    return (world, account)
}

@Suite("VX-305 U4 fixed — accounts: leaves, joins, Replace All Keys, the signed-out screens")
struct AccountScenarios {
    /// "Replace All Keys on an account still on the old shared key, its follow,
    /// and a new device joining one (its key file under its own key)" — and,
    /// where the account's Apple key can't be read here (decision 30's road
    /// has nothing to keep the master under), the act is refused at its door,
    /// with nothing written and nothing left in flight.
    @Test func replaceAllKeysOnAnAccountStillOnTheOldSharedKey() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .replaceAllKeys("macA", newWords: false)])
        let vault = try #require(world.server.accounts.values.first?.format)
        let shared = try #require(world.oldSharedKey(world.macA))
        #expect(vault.appleKeyID != shared.id, "re-linked first: the new master under the account's own key")
        await world.done([.syncICloud("macA"), .follow("phone", .passphrase), .settle])
        // A new device joining the account: its key file under its own key.
        await world.done([.createLibrary("macB", secrets: true), .signIn("macB", account: world.server.accounts.keys.first!),
                          .turnOnSync("macB"), .settle])
        let joined = try #require(world.liveKeyFile(world.macB)?.apple?.keyID)
        #expect(world.macB.library?.section.appleKeys.contains { $0.id == joined && $0.isOwnLibraryKey } == true)
        expectPromisesKept(world)

        // The account's key unreadable here: refused before any write.
        let (other, _) = try syncedWorld(.standard, devices: ["macA"])
        await other.done([.launch("macA"), .switchAppleID("macA", to: SWorld.appleB)])
        let writes = other.macA.writeCount
        let result = await other.step(.replaceAllKeys("macA", newWords: false))
        #expect(result != .done)
        #expect(other.macA.library?.section.actInFlight == nil, "the refusal left the act in flight")
        #expect(other.macA.container.files[SPath.plan] == nil)
        #expect(other.macA.writeCount == writes, "refused after writing")
        expectPromisesKept(other)
    }
}
