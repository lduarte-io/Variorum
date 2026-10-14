//
//  FixedScenarios.swift
//  VariorumCoreTests — VX-305 U4: THE FIXED SCENARIOS (the phase plan §6's
//  list — each a named test). Every scenario runs on the world with the
//  promises checked after every step (`SWorld.step`), and then asserts what
//  its own sentence says. The ones that guard a known bug re-run with their
//  guard off in `MutationPins.swift` and must fail there.
//
//  This file: the starting states through the migration, and the old marker.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A world built from a starting state.
func scenarioWorld(_ seed: UInt64 = 11, guards: ProtectionGuards = .all, _ build: (SWorld) throws -> Void) rethrows -> SWorld {
    let world = SWorld(seed: seed)
    world.guards = guards
    try build(world)
    return world
}

/// Every promise held at every step, else the log.
func expectPromisesKept(_ world: SWorld, _ context: String = "", sourceLocation: SourceLocation = #_sourceLocation) {
    let found = world.violations.map(\.0)
    #expect(found.isEmpty, "\(context)\n\(found.map(\.description).joined(separator: "\n"))\n\(world.log)", sourceLocation: sourceLocation)
}

extension SWorld {
    /// Run steps, expecting each to be done (not refused, not crashed).
    func done(_ actions: [Action], sourceLocation: SourceLocation = #_sourceLocation) async {
        for action in actions {
            let result = await step(action, words: true)
            #expect(result == .done, "\(action) → \(result)\n\(log)", sourceLocation: sourceLocation)
        }
    }

    var record: (SDevice) -> ProtectionRecord? { { $0.slot?.record } }
}

@Suite("VX-305 U4 fixed — today's stores through the migration (§3.13)")
struct MigrationScenarios {
    /// "today's Standard-waiting and exposed libraries through the migration:
    /// the current key takes step 2's mode" — and, the world settled, promise
    /// 3 holds: the migration gives the live Standard library this Mac's own
    /// Apple key (step 7) even where no old shared key ever landed.
    @Test func todaysStandardWaitingAndExposedLibrariesThroughTheMigration() async throws {
        for (name, spec) in [
            ("exposed", TodaySpec(mode: .standard, passphrase: false, words: false, appleLanded: false)),
            ("Standard-waiting", TodaySpec(mode: .standard, appleLanded: false)),
            ("Standard, landed", TodaySpec(mode: .standard)),
        ] {
            let world = try scenarioWorld { try $0.today(on: $0.macA, spec) }
            await world.done([.launch("macA"), .settle])
            let record = try #require(world.macA.slot?.record, "\(name)")
            // Step 2: today's rule — the Standard-waiting library with a
            // passphrase is corner 45's ambiguous case: Castle, not confirmed.
            if name == "Standard-waiting" {
                #expect(record.mode == .castle && !record.modeConfirmed, "\(name)")
            } else {
                #expect(record.mode == .standard && record.modeConfirmed, "\(name)")
                #expect(world.liveKeyFile(world.macA)?.apple != nil, "\(name): no Apple key of this Mac's own")
            }
            expectPromisesKept(world, name)
        }
    }

    /// §3.13 step 1's "a vault that moved while the library didn't is an
    /// ordinary follow": a Mac still on today's build in Castle, its account
    /// left Castle on another device; it migrates after. Its library is
    /// recorded by its own key's kind — Castle — and the follow into Standard
    /// (one secret typed, a fresh key, the anchor) is owed; the Castle-born key
    /// never lands in a silent item or under an Apple key.
    @Test func aVaultThatMovedWhileTheLibraryDidntIsAnOrdinaryFollow() async throws {
        let world = try scenarioWorld { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .castle)
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, account: account))
            try w.today(on: w.macB, TodaySpec(mode: .castle, gate: .alwaysAsk, account: account))
            w.macB.build = .older
        }
        let k0 = try #require(world.macB.slot?.fingerprint)
        await world.done([.useStandard("macA"), .updateToNewBuild("macB"), .launch("macB")])
        let record = try #require(world.macB.slot?.record)
        #expect(record.mode == .castle && record.currentFingerprint == k0, "the migration took the vault's word over the library's own key")
        #expect(world.owedFollow(world.macB) == .intoStandard)
        #expect(!world.macB.keychain.local.contains { $0.key.service == ProtectionNames.custodyService && !$0.value.touchID && $0.value.value.libraryKey.map(PF.fp) == k0 })
        await world.done([.follow("macB", .passphrase), .settle])
        #expect(world.macB.slot?.record?.mode == .standard && world.macB.slot?.fingerprint != k0)
        expectPromisesKept(world)
    }

    /// "signed out with keys": a synced Standard library migrated while
    /// signed out is recorded NOT YET CONFIRMED (§3.13 step 2) — no custody
    /// repair, nothing Apple-reachable written. Signed in, the vault answers
    /// Standard; confirming it runs what the migration deferred — the per-key
    /// item and this Mac's own Apple key (step 7: "once its mode is confirmed
    /// Standard") — so promise 3 settles.
    @Test func signedOutWithKeysThenTheVaultAnswers() async throws {
        let (world, account) = try syncedWorld(.standard, devices: ["macA"])
        await world.done([.signOut("macA"), .launch("macA")])
        let record = try #require(world.macA.slot?.record)
        #expect(record.mode == .standard && !record.modeConfirmed)
        #expect(world.liveKeyFile(world.macA)?.apple == nil, "an Apple write before the mode was confirmed")
        await world.done([.signIn("macA", account: account), .launch("macA"), .settle])
        #expect(world.macA.slot?.record?.modeConfirmed == true)
        #expect(world.liveKeyFile(world.macA)?.apple != nil)
        expectPromisesKept(world)
    }

    /// "corner 45's ambiguous case: no custody repair until the notice is
    /// answered, and confirming Standard is a key change" — a VX-202 victim
    /// (recorded Castle, not confirmed, its key in today's silent item). Once
    /// she answers Standard, the leave's new key takes nothing, and nothing a
    /// login-password holder reads — today's silent item included — opens the
    /// copies from before it (promise 13).
    @Test func corner45sAmbiguousCase() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .alwaysAsk, silentInCastle: true))
        }
        let k0 = try #require(world.macA.slot?.fingerprint)
        await world.done([.launch("macA")])
        let record = try #require(world.macA.slot?.record)
        #expect(record.mode == .castle && !record.modeConfirmed)
        #expect(world.assessed(world.macA).acts.contains(.corner45Notice))
        // No custody repair until the notice is answered: today's item stays.
        let bound = KName.legacyBound(SWorld.scope, record.libraryID)
        #expect(world.macA.keychain.local[bound] != nil)
        await world.done([.backup("macA"), .settle, .answerCorner45("macA", .standard)])
        let after = try #require(world.macA.slot?.record)
        #expect(after.mode == .standard && after.currentFingerprint != k0, "confirming Standard is a key change")
        #expect(world.macA.keychain.local[bound] == nil, "today's silent item still holds the Castle-era key after the leave")
        expectPromisesKept(world)
    }
}
