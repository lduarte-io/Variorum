//
//  CrashHarness.swift
//  VariorumCoreTests — VX-305 U3: "a crash injected after every step, then a
//  resume that finishes or rolls back, never a third state" (the phase plan
//  §5). Stronger than every step: the harness crashes after EVERY WRITE of a
//  clean run — the write lands, the process dies — relaunches (the lobby opens
//  the library by its roads), settles, and classifies the world: the act
//  finished, or it never happened, and never both or neither.
//

import Foundation
import Testing

@testable import VariorumCore

typealias ActRun = (EX, ProtectionExecutor, inout UnlockedLibrary) async throws -> Void
typealias WorldState = (EX, UnlockedLibrary) -> Bool

enum CrashHarness {
    /// The clean run's writes (the count the loop walks).
    static func cleanRun(_ make: () throws -> EX, _ act: ActRun) async throws -> (EX, UnlockedLibrary) {
        let fixture = try make()
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try await act(fixture, executor, &library)
        return (fixture, library)
    }

    /// Crash after every write; relaunch; settle. With the plan kept, every
    /// resume FINISHES; with the plan dropped (a missing plan), the act rolls
    /// back before its commit point and finishes from the record after.
    static func everywhere(
        _ make: () throws -> EX, act: ActRun, finished: WorldState, neverHappened: WorldState,
        dropPlan: Bool = false, typed: ((EX) -> TypedSecrets)? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        let (clean, cleanLibrary) = try await cleanRun(make, act)
        #expect(finished(clean, cleanLibrary), "the clean run did not finish", sourceLocation: sourceLocation)
        let count = clean.world.writes.count
        #expect(count > 3, sourceLocation: sourceLocation)
        // A crash before the plan's first write leaves an act with no plan —
        // rolled back, by design (the act named first, the plan after).
        let firstPlan = (clean.world.writes.firstIndex(of: .plan) ?? 0) + 1
        for crashAt in 1...count {
            let fixture = try make()
            fixture.world.crashAfterWrites = crashAt
            let executor = fixture.executor()
            var library = try fixture.unlocked(executor)
            do {
                try await act(fixture, executor, &library)
                Issue.record("write \(crashAt): no crash", sourceLocation: sourceLocation)
            } catch is SimulatedCrash {}
            let context = "crash after write \(crashAt) (\(clean.world.writes[crashAt - 1])):"
            let settled: UnlockedLibrary
            do {
                (_, settled, _) = try await fixture.relaunchAndSettle(typed?(fixture), dropPlan: dropPlan)
            } catch {
                Issue.record("\(context) the settle threw \(error)", sourceLocation: sourceLocation)
                continue
            }
            expectSettled(fixture, settled, context, sourceLocation: sourceLocation)
            let done = finished(fixture, settled), never = neverHappened(fixture, settled)
            #expect(done != never, "crash after write \(crashAt) (\(clean.world.writes[crashAt - 1])): \(done ? "both" : "neither") — a third state",
                    sourceLocation: sourceLocation)
            if !dropPlan, crashAt >= firstPlan {
                #expect(done, "crash after write \(crashAt) (\(clean.world.writes[crashAt - 1])): the plan's resume did not finish",
                        sourceLocation: sourceLocation)
            }
        }
    }
}
