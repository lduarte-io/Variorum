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
}
