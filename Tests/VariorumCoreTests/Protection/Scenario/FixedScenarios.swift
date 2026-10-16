//
//  FixedScenarios.swift
//  VariorumCoreTests — VX-305 U4: THE FIXED SCENARIOS (the phase plan §6's
//  list — each a named test). Every scenario runs on the world with the
//  promises checked after every step (`SWorld.step`), and then asserts what
//  its own sentence says. The ones that guard a known bug re-run with their
//  guard off in `MutationPins.swift` and must fail there.
//
//  This file: the helpers. (The migration's scenarios left with rule 26 —
//  VX-378 U1.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A world built by the app's own doors (`StartingStates.swift`).
func scenarioWorld(_ seed: UInt64 = 11, guards: ProtectionGuards = .all, _ build: (SWorld) async throws -> Void) async rethrows -> SWorld {
    let world = SWorld(seed: seed)
    world.guards = guards
    try await build(world)
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
