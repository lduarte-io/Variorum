//
//  StoreBindingTests.swift
//  VariorumCoreTests
//
//  Phase 13p, Batch 2 (commit 1) — the re-lock substrate's own tests (the
//  plan names this "real engineering and gets its own tests":
//  ValueObservation lifecycles must not outlive the pool). What is pinned:
//  a locked binding refuses reads, writes, backups, observations, and
//  artifact connections with the TYPED error; the pool closes cleanly;
//  key material stops being reachable through the value; adopting a fresh
//  open reconnects THE SAME ambient view with the data intact; and an
//  in-flight observation's consuming task ends under cancellation (the
//  app's teardown road) without crash or hang.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("Phase 13p — the lockable store binding")
struct StoreBindingTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-bind-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A keyed on-disk store with one recognizable row, wrapped rebindable.
    private func openRebindable(
        in dir: URL, key: StoreKey
    ) throws -> (view: AppDatabase, binding: StoreBinding, url: URL) {
        let url = dir.appendingPathComponent("variorum.sqlite")
        let database = try AppDatabase.onDisk(url: url, key: key)
        try database.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["binding_probe", "present"])
        }
        let (view, binding) = database.asRebindable()
        return (view, binding, url)
    }

    private func probeValue(_ database: AppDatabase) throws -> String? {
        try database.read { db in
            try String.fetchOne(
                db, sql: "SELECT value FROM setting WHERE key = 'binding_probe'")
        }
    }

    @Test func boundViewBehavesLikeTheStoreItWraps() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())
        #expect(!binding.isLocked)
        #expect(try probeValue(view) == "present")
    }

    @Test func lockRefusesReadsWritesAndBackups() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())

        let outcome = binding.lock()
        #expect(outcome.closedCleanly, "the pool must close cleanly: \(outcome.closeFailure ?? "")")
        #expect(binding.isLocked)

        #expect(throws: StoreLockedError()) { _ = try probeValue(view) }
        #expect(throws: StoreLockedError()) {
            try view.write { db in
                try db.execute(sql: "INSERT INTO setting (key, value) VALUES ('x', 'y')")
            }
        }
        #expect(throws: StoreLockedError()) {
            try view.backup(to: dir.appendingPathComponent("locked-backup.sqlite"))
        }
    }

    @Test func lockIsIdempotent() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (_, binding, _) = try openRebindable(in: dir, key: .mint())
        #expect(binding.lock().closedCleanly)
        #expect(binding.lock().closedCleanly, "a second lock is a quiet no-op")
    }

    /// "Drop key material" made observable: the locked view's artifact
    /// configuration REFUSES every connection rather than opening plain —
    /// there is no road from a locked binding to a keyed (or, worse,
    /// silently unkeyed) artifact connection.
    @Test func lockedArtifactConfigurationRefusesConnections() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())
        binding.lock()
        let scratch = dir.appendingPathComponent("artifact-probe.sqlite")
        #expect(throws: StoreLockedError()) {
            _ = try DatabaseQueue(path: scratch.path, configuration: view.artifactConfiguration())
        }
    }

    @Test func lockedObservationThrowsOnFirstIteration() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())
        binding.lock()
        let sequence = view.observe { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM setting") ?? 0
        }
        var iterator = sequence.makeAsyncIterator()
        await #expect(throws: StoreLockedError()) {
            _ = try await iterator.next()
        }
    }

    /// W-1 (the 13x closeout walk): the adoption gate reads a non-empty
    /// `-wal` beside the live store as "pool not closed" — so lock() must
    /// leave the wal CHECKPOINTED AWAY (absent or zero bytes), including
    /// with a live observation still consuming at lock time (the app's
    /// ready-road condition, where the refusal was met live).
    @Test func lockLeavesNoHotWalBesideTheClosedStore() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, url) = try openRebindable(in: dir, key: .mint())

        // A live observation, as the ready tree holds one at lock time.
        let firstDelivered = AsyncStream<Void>.makeStream()
        let consumer = Task {
            var sawFirst = false
            for try await _ in view.observe({ db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM setting") ?? 0
            }) {
                if !sawFirst {
                    sawFirst = true
                    firstDelivered.continuation.yield()
                }
            }
        }
        for await _ in firstDelivered.stream { break }

        // Fatten the wal the way a session's writes do.
        try await view.write { db in
            for i in 0..<200 {
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                    arguments: ["w1-fat-\(i)", String(repeating: "x", count: 4096)])
            }
        }
        let walPath = url.path + "-wal"
        let sizeBefore = (try? FileManager.default.attributesOfItem(atPath: walPath)[.size] as? Int) ?? 0
        #expect(sizeBefore > 0, "the condition needs a hot wal before the lock")

        let outcome = binding.lock()
        consumer.cancel()
        _ = try? await consumer.value

        let sizeAfter = (try? FileManager.default.attributesOfItem(atPath: walPath)[.size] as? Int) ?? 0
        #expect(outcome.closedCleanly, "the close must be clean: \(outcome.closeFailure ?? "")")
        #expect(sizeAfter == 0,
                "a locked store's wal must be checkpointed away — the adoption gate reads >0 as a hot pool (W-1)")
    }

    /// The app's teardown road, modeled: an observation started before the
    /// lock is consumed by a task; the lock lands; the task is cancelled
    /// (SwiftUI's `.task` teardown when the lobby replaces the views) and
    /// must END — no crash, no hang, no value delivered off a closed pool.
    @Test func inFlightObservationTaskEndsUnderCancellationAfterLock() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())

        let firstDelivered = AsyncStream<Void>.makeStream()
        let consumer = Task {
            var deliveredAfterLock = 0
            do {
                var sawFirst = false
                for try await _ in view.observe({ db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM setting") ?? 0
                }) {
                    if !sawFirst {
                        sawFirst = true
                        firstDelivered.continuation.yield()
                    } else if binding.isLocked {
                        deliveredAfterLock += 1
                    }
                }
            } catch {
                // A thrown end is as good as a cancelled one — the pin is
                // that the iteration ENDS and delivers nothing post-lock.
            }
            return deliveredAfterLock
        }
        var firstIterator = firstDelivered.stream.makeAsyncIterator()
        _ = await firstIterator.next()

        binding.lock()
        consumer.cancel()
        let deliveredAfterLock = await consumer.value
        #expect(deliveredAfterLock == 0, "a closed pool must deliver nothing")
    }

    @Test func adoptReconnectsTheSameAmbientView() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let key = StoreKey.mint()
        let (view, binding, url) = try openRebindable(in: dir, key: key)
        binding.lock()
        #expect(throws: StoreLockedError()) { _ = try probeValue(view) }

        // Unlock: a FRESH open of the same file (the composition root's
        // rebuild road), adopted into the same binding.
        let reopened = try AppDatabase.onDisk(url: url, key: key)
        try binding.adopt(reopened)
        #expect(!binding.isLocked)
        #expect(try probeValue(view) == "present",
                "the SAME view value reads the fresh pool — ambient holders survive re-lock")

        // And a fresh observation on the same view is live again.
        #expect(try view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM setting")
        } ?? 0 > 0)
    }

    @Test func adoptRefusesABoundView() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())
        #expect(throws: StoreBindingError.cannotAdoptBoundView) {
            try binding.adopt(view)
        }
    }

    @Test func rewrappingABoundViewReturnsItsOwnBinding() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let (view, binding, _) = try openRebindable(in: dir, key: .mint())
        let again = view.asRebindable()
        #expect(again.binding === binding, "no second binding over one pool")
    }
}
