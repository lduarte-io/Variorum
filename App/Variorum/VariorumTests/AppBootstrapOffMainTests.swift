//
//  AppBootstrapOffMainTests.swift
//  VariorumTests
//
//  Phase 13l, ACT 3 / L-c — the store opens OFF the main thread.
//
//  RED ON THE PRE-FIX TREE: `AppBootstrap.init` called `open()` inline, so
//  there was no `.opening` case to be in and `init` returned only after the
//  whole migration set had run on the main thread, before first paint.
//  `initReturnsBeforeTheStoreIsOpen` fails there twice over — it does not
//  compile against a two-case `State`, and its budget is the 54 ms the
//  measurement recorded.
//
//  VX-329 U1 — THE RELEASE SWITCH: the bootstrap has one road, so these pins
//  run it — a library created on the PLANTED road (no keychain), the test
//  bootstrap's harness carrying the staged opener (today's `testOpener` went
//  with today's route). The claims are unchanged: init returns before the
//  store opens; a failed open lands `.failed` and retry re-enters; a second
//  retry mid-open starts nothing; the launch cost, printed.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("AppBootstrap opens off the main thread (13l L-c)")
struct AppBootstrapOffMainTests {
    /// The bootstrap's `.ready` arm builds an `AppSession`, and the whole
    /// road (open → `finish` → session) reads injected dependencies, so
    /// every pin runs inside one scope. `Task {}` inherits task-locals from
    /// where it is created, which is why wrapping the BODY is enough.
    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body()
        }
    }

    /// Opening runs the migration set, which reads `@Dependency(\.date)`
    /// and friends — and the bootstrap's own open runs on a DETACHED task,
    /// which does not inherit a `withDependencies` scope. So the pins open
    /// their store out here and hand the opener a ready one: the state
    /// machine and the off-main hop are what they are exercising. The
    /// library is created on the planted road first, so the road's route
    /// opens it quietly (Standard, its silent item) and calls the opener.
    private func plantedLibrary() async throws -> (road: PlantedRoad, database: AppDatabase) {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let database = try AppDatabase.openStore(at: road.slot.places.slot, custody: .inMemory(initial: session.key))
        return (road, database)
    }

    /// The test bootstrap over `road`, its opener `open` (the harness's — the road hands it the key).
    private func bootstrap(
        _ road: PlantedRoad, open: @escaping @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>
    ) -> AppBootstrap {
        AppBootstrap(
            testStoreURL: road.slot.places.slot,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), open: { _ in open() }))
    }

    /// **THE FIX, stated as behaviour.** `init` must return with the store
    /// still unopened — that is what "before first paint" means. Staged with
    /// an opener that takes a deliberate 50 ms, so the assertion is about
    /// the STRUCTURE (init did not wait for it) and not about a machine's
    /// speed.
    @Test func initReturnsBeforeTheStoreIsOpen() async throws {
        try await withDeps {
            let (road, database) = try await plantedLibrary()
            let started = ContinuousClock.now
            let bootstrap = bootstrap(road) {
                Thread.sleep(forTimeInterval: 0.05)
                return .success(database)
            }
            let initCost = ContinuousClock.now - started

            if case .opening = bootstrap.state {} else {
                Issue.record("init must leave the bootstrap opening, not ready")
            }
            #expect(initCost < .milliseconds(25),
                    "init returned without waiting for a 50 ms open")

            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the open should have completed")
                return
            }
        }
    }

    @Test func aFailedOpenLandsInFailedAndRetryReEnters() async throws {
        try await withDeps {
            let attempts = LockIsolated(0)
            let (road, database) = try await plantedLibrary()
            let bootstrap = bootstrap(road) {
                let n = attempts.withValue { value -> Int in
                    value += 1
                    return value
                }
                guard n > 1 else {
                    return .failure(AppDatabase.StoreOpenError(
                        storePath: "/nowhere", reason: "staged"))
                }
                return .success(database)
            }

            await bootstrap.awaitOpen()
            guard case .failed(let error) = bootstrap.state else {
                Issue.record("a failed open must land in .failed")
                return
            }
            #expect(error.reason == "staged")

            bootstrap.retry()
            if case .opening = bootstrap.state {} else {
                Issue.record("retry re-enters the same road, so it is opening again")
            }
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("retry should have reached ready")
                return
            }
            #expect(attempts.value == 2, "retry re-entered exactly once")
        }
    }

    /// A second `retry()` while one is already in flight must not start a
    /// second race for the same store file.
    @Test func aRetryDuringAnOpenDoesNotStartASecondOne() async throws {
        try await withDeps {
            let attempts = LockIsolated(0)
            let (road, database) = try await plantedLibrary()
            let bootstrap = bootstrap(road) {
                attempts.withValue { $0 += 1 }
                Thread.sleep(forTimeInterval: 0.03)
                return .success(database)
            }
            bootstrap.retry()
            bootstrap.retry()
            await bootstrap.awaitOpen()

            #expect(attempts.value == 1)
            guard case .ready = bootstrap.state else {
                Issue.record("the one open should have completed")
                return
            }
        }
    }

    /// The RE-MEASUREMENT the fix was asked for (mobile round 2 §58's
    /// numbers were the simulator's; these are the Mac's). Printed rather
    /// than asserted tightly — the number that matters is the FIRST one, and
    /// the second is what used to be paid on the main thread before paint.
    @Test func theLaunchCostIsMeasuredAgain() async throws {
        try await withDeps {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-13l-\(UUID().uuidString)", isDirectory: true)
                .appendingPathComponent("variorum.sqlite")
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

            // A real first open — the whole migration set, empty store.
            let coldStart = ContinuousClock.now
            _ = try AppDatabase.openStore(at: url)
            let coldOpen = ContinuousClock.now - coldStart

            let warmStart = ContinuousClock.now
            _ = try AppDatabase.openStore(at: url)
            let warmOpen = ContinuousClock.now - warmStart

            let (road, database) = try await plantedLibrary()
            let initStart = ContinuousClock.now
            let bootstrap = bootstrap(road) { .success(database) }
            let initCost = ContinuousClock.now - initStart
            await bootstrap.awaitOpen()

            print("PERF[mac] AppBootstrap.init (MAIN THREAD, before first paint): "
                  + "\(initCost) — was the full open below")
            print("PERF[mac] openStore first (empty store, full migration set): \(coldOpen)")
            print("PERF[mac] openStore reopened: \(warmOpen)")

            // Generous by design: this is a structural claim (init does not open
            // the store), not a machine benchmark. The known-flake lesson —
            // a budget that reds under load cannot do the job it exists for.
            #expect(initCost < .milliseconds(20))
        }
    }
}
