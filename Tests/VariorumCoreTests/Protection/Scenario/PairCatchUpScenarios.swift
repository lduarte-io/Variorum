//
//  PairCatchUpScenarios.swift
//  VariorumCoreTests — VX-529: THE PAIR CATCH-UP in the scenario world, under
//  every promise (`notes/plans/fixes/vx-529-pair-catchup.md`). Her other Mac
//  re-makes the account's passphrase and/or words; this Mac owes the follow's
//  third kind, presses it with what she knows today, and afterwards her
//  current secrets open the live library directly — the floor (promise 4)
//  held, nothing half-done (promise 6), the four things followed (promise 7).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 — the pair catch-up in the scenario world, every promise checked")
struct PairCatchUpScenarios {
    @Test(arguments: [(ProtectionMode.castle, GateStyle.alwaysAsk), (.castle, .touchID), (.standard, .touchID)])
    func herOtherMacChangesThePairAndThisMacCatchesUp(_ mode: ProtectionMode, _ gate: GateStyle) async throws {
        for (passphrase, words) in [(true, false), (false, true), (true, true)] {
            let (world, account) = try await syncedWorld(mode, devices: ["macA", "macB"], gate: gate)
            var changes: [Action] = [.launch("macA"), .launch("macB")]
            if words { changes.append(.regenerateWords("macA")) }
            if passphrase { changes.append(.changePassphrase("macA")) }
            await world.done(changes)
            let context = "\(mode) \(gate) passphrase \(passphrase) words \(words)"
            // The follow is offered from a fresh read of the vault (the world's `.follow` action reads it the same way).
            _ = try await world.macB.executor?.readVault(accountID: account)
            #expect(world.owedFollow(world.macB) == .pairChanged(passphrase: passphrase, words: words), "\(context)")
            await world.done([.follow("macB", .passphrase)])
            #expect(world.owedFollow(world.macB) == nil, "\(context): still owed after the catch-up")
            let today = world.known(account)
            let live = try #require(world.liveKeyFile(world.macB))
            #expect((try? live.open(.passphrase(try #require(today.passphrase)), floor: PF.floor)) != nil,
                    "\(context): today's passphrase doesn't open the caught-up library")
            #expect((try? live.open(.words(try #require(today.words)), floor: PF.floor)) != nil,
                    "\(context): today's words don't open the caught-up library")
            expectPromisesKept(world, context)
            await world.done([.settle])
            expectPromisesKept(world, "\(context), settled")
        }
    }
}
