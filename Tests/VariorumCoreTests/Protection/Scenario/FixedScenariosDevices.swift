//
//  FixedScenariosDevices.swift
//  VariorumCoreTests — VX-305 U4: the fixed scenarios about DEVICES (§6's
//  list) — this Mac's settings acts crashed at every write. (VX-378 U1 cut the
//  replacement Mac's takeover — rule 23 — the restore of the key file from a
//  copy — rule 21 — and the open copy's own line — rule 17.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — devices: this Mac's settings acts")
struct DeviceScenarios {
    /// A crash at every write of this Mac's settings acts (the gate style, the
    /// re-arm), then a relaunch: each finishes or rolls back (promise 6) —
    /// the plan-less finish needs nothing only the press had.
    @Test func aCrashAtEveryWriteOfASettingsChangeSettles() async throws {
        for act in [Action.setGate("macA", .alwaysAsk), .setScheduledExport("macA", true), .setIdleLock("macA", minutes: 30)] {
            for n in 1...8 {
                let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .touchID) }
                await world.done([.launch("macA")])
                await world.step(.crash(act, afterWrites: n))
                await world.step(.launch("macA"))
                #expect(world.macA.library?.section.actInFlight == nil, "\(act) crashed after write \(n): still in flight")
                expectPromisesKept(world, "\(act) after write \(n)")
            }
        }
    }
}
