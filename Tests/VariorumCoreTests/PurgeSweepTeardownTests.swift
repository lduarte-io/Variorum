//
//  PurgeSweepTeardownTests.swift
//  VariorumCoreTests
//
//  VX-855 (the VX-849 run, batch 5 — TRACE-FIRST, the ticket Suspected): the
//  purge sweep's in-flight pool READ against the store's in-process teardown.
//
//  The ticket's one .ips: a test host crashed at teardown on
//  `GRDB.DatabasePool.reader.1` inside `PurgeJanitor.collectRoots ←
//  LocalPurge.sweep(afterFamily:) ← AppDatabase.read`, deep in the SQLCipher
//  codec's page decrypt. The suspected class: the sweep's reader still in use
//  while the pool (or its key) is torn down under it.
//
//  THIS SUITE IS THE CONFIRM for the in-process half of that class: it holds
//  the sweep's `collectRoots` read MID-STEP — a progress handler on the pool's
//  one reader connection parks the reader's thread inside `sqlite3_step`, the
//  .ips's own frame — and then tears the store down through the lock road's
//  OWN call (`StoreBinding.lock()`: the binding swapped to locked, the pool
//  closed, the key dropped). Deterministic: the read is provably in flight
//  (the handler said so) before the teardown starts, and released only after.
//
//  What it pins (the batch record's trace): a close cannot run under an
//  in-flight read — GRDB's `DatabasePool.close()` runs inside the reader
//  pool's barrier, which waits for every reader to be released — so the held
//  read finishes on a live connection, the lock returns only after it, the
//  sweep's next access meets the typed `StoreLockedError`, and nothing of the
//  family is half-done. (The .ips's actual teardown is PROCESS EXIT, which a
//  pin cannot drive in-process; the record traces it and its two faces.)
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// Parks a reader connection's thread inside `sqlite3_step` — once, when armed —
/// until released. Installed as the connection's progress handler.
private final class ReaderHold: @unchecked Sendable {
    private let lock = NSLock()
    private var armed = false
    private var fired = false
    private var released = false
    private let entered = DispatchSemaphore(value: 0)
    private let gate = DispatchSemaphore(value: 0)

    func arm() { lock.withLock { armed = true } }

    /// True once the test has let the held read go on.
    var isReleased: Bool { lock.withLock { released } }

    /// The test's release: the flag first, then the gate.
    func release() {
        lock.withLock { released = true }
        gate.signal()
    }

    /// Waits off the cooperative pool for the reader to be parked.
    func awaitEntered(seconds: Double) async -> Bool {
        await Task.detached { [self] in waitEnteredBlocking(seconds: seconds) }.value
    }

    /// The blocking half (a synchronous function — semaphores never wait in an
    /// async context).
    private func waitEnteredBlocking(seconds: Double) -> Bool {
        entered.wait(timeout: .now() + seconds) == .success
    }

    /// The progress handler's body, on the reader's own thread.
    func step() {
        let parks: Bool = lock.withLock {
            guard armed, !fired else { return false }
            fired = true
            return true
        }
        guard parks else { return }
        entered.signal()
        gate.wait()
    }
}

/// The sqlite progress-handler trampoline (no captures — the hold rides the context).
private let readerHoldCallback: @convention(c) (UnsafeMutableRawPointer?) -> Int32 = { context in
    if let context {
        Unmanaged<ReaderHold>.fromOpaque(context).takeUnretainedValue().step()
    }
    return 0
}

@Suite("VX-855 — the purge sweep's in-flight read against the store's teardown", .serialized)
struct PurgeSweepTeardownTests {
    /// One keyed on-disk store (a `DatabasePool`, as production's) holding one
    /// never-synced deleted note with a Delete Now intent — the local road's
    /// eligible family (`QuitPurgeQuiesceTests`' shape, core-side) — wrapped
    /// rebindable as the composition root wraps the app's store.
    private struct World {
        let dir: URL
        let url: URL
        let key: StoreKey
        let view: AppDatabase
        let binding: StoreBinding
        let postID: String

        static let now = Date(timeIntervalSince1970: 1_782_864_000)

        static func make() throws -> World {
            let dir = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-vx855-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let url = dir.appendingPathComponent("variorum.sqlite")
            let key = StoreKey.mint()
            let store = try AppDatabase.onDisk(url: url, key: key)
            let postID: String = try withDependencies {
                $0.database = store
                $0.uuid = .incrementing
                $0.date = .constant(now)
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 855))
            } operation: {
                let ops = Operations()
                let post = try ops.createPost(title: "doomed", profile: .generic)
                _ = try ops.newBlock(in: post.id, text: "Going.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "Going too.", at: .end)
                try ops.deleteContainer(post.id)
                _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post.id)])
                return post.id
            }
            let (view, binding) = store.asRebindable()
            return World(dir: dir, url: url, key: key, view: view, binding: binding, postID: postID)
        }

        func cleanUp() {
            binding.lock()
            try? FileManager.default.removeItem(at: dir)
        }

        /// The hold installed on the pool's reader: the first read creates the
        /// pool's one reader connection and leaves the handler on it, so the
        /// sweep's read (the first available reader) is the one that parks.
        func plant(_ hold: ReaderHold) throws {
            let context = Unmanaged.passUnretained(hold).toOpaque()
            try view.read { db in
                sqlite3_progress_handler(db.sqliteConnection, 1, readerHoldCallback, context)
                _ = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent")
            }
        }

        /// The production sweep, bound to this store's view (the ambient view
        /// the app's session holds), started as a task the way the app's held
        /// sweep starts.
        func startSweep() -> Task<Result<LocalPurge.SweepReport, any Error>, Never> {
            let view = view
            return withDependencies {
                $0.date = .constant(World.now)
            } operation: {
                let purge = LocalPurge(database: view)
                return Task {
                    do { return .success(try await purge.sweep()) } catch { return .failure(error) }
                }
            }
        }

        /// The store as it stands after the teardown, opened fresh with its key
        /// (the unlock's own road): the family's rows and its live intents.
        func reopenedFacts() throws -> (container: Int, blocks: Int, intents: Int, store: AppDatabase) {
            let reopened = try AppDatabase.onDisk(url: url, key: key)
            let facts = try reopened.read { db in
                (
                    try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM container WHERE id = ?", arguments: [postID]) ?? 0,
                    // Reached through the note's placements (`PurgeConvergenceTests.familyRowCount`'s
                    // form) — a note's delete cascades its blocks without stamping `last_container_id`.
                    try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM block WHERE id IN (SELECT block_id FROM container_block WHERE container_id = ?)",
                        arguments: [postID]) ?? 0,
                    try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM purge_intent WHERE row_id = ? AND deleted_at IS NULL",
                        arguments: [postID]) ?? 0
                )
            }
            return (facts.0, facts.1, facts.2, reopened)
        }
    }

    /// Starts the lock road's own teardown on a background thread and waits for
    /// its first act (the swap to locked) to be visible. The task answers the
    /// close outcome and whether the held read had ALREADY been released when
    /// `lock()` returned.
    private func startLock(
        _ world: World, _ hold: ReaderHold
    ) async throws -> Task<(clean: Bool, failure: String?, returnedAfterRelease: Bool), Never> {
        let binding = world.binding
        let locking = Task.detached { () -> (clean: Bool, failure: String?, returnedAfterRelease: Bool) in
            let outcome = binding.lock()
            return (clean: outcome.closedCleanly, failure: outcome.closeFailure, returnedAfterRelease: hold.isReleased)
        }
        let deadline = Date().addingTimeInterval(5)
        while !binding.isLocked, Date() < deadline {
            try await Task.sleep(for: .milliseconds(2))
        }
        try #require(binding.isLocked, "the lock began: the binding swapped to locked")
        return locking
    }

    /// **THE CONFIRM (the lock road's teardown, mid-read):** the sweep's
    /// `collectRoots` read is parked inside `sqlite3_step`; the store is locked
    /// under it (`StoreBinding.lock()` — close + key drop, the app's lock road's
    /// call). The CLASS would read: the lock returns, or the connections close,
    /// while the read is still in flight. What must hold: new accesses refuse at
    /// once (typed); the lock returns only AFTER the held read was let go (the
    /// close waited for it); the read itself finished on a live connection, so
    /// the sweep ends at its next access with the typed `StoreLockedError` — never
    /// a database error from a connection closed under it; the close is clean; the
    /// family stands whole (nothing half-done) and a later sweep purges it.
    @Test func aLockLandingMidSweepClosesOnlyAfterTheHeldReadEnds() async throws {
        let world = try World.make()
        defer { world.cleanUp() }
        let hold = ReaderHold()
        try world.plant(hold)
        hold.arm()

        let sweep = world.startSweep()
        let parked = await hold.awaitEntered(seconds: 10)
        try #require(parked, "the sweep's collectRoots read is parked mid-step on the pool's reader")

        let locking = try await startLock(world, hold)
        #expect(throws: StoreLockedError()) {
            _ = try world.view.read { db in try Int.fetchOne(db, sql: "SELECT 1") }
        }
        // The window a close that does not wait would return in.
        try await Task.sleep(for: .milliseconds(500))
        hold.release()

        let ended = await sweep.value
        let lock = await locking.value

        #expect(lock.returnedAfterRelease,
                "the lock returned only after the held read was let go — the close waited for it")
        #expect(lock.clean, "the close is clean: \(lock.failure ?? "")")
        switch ended {
        case .success(let report):
            Issue.record("the sweep cannot finish a family on a locked store: \(report)")
        case .failure(let error):
            #expect(error is StoreLockedError,
                    "the read finished on a live connection; the sweep ended at its NEXT access, typed: \(error)")
        }

        let after = try world.reopenedFacts()
        #expect(after.container == 1 && after.blocks == 2 && after.intents == 1,
                "the family stands whole and its intent live — nothing half-done: \(after)")
        // Control: the world is real — the family WAS eligible, and a sweep over
        // the reopened store purges it.
        let report = try await withDependencies {
            $0.date = .constant(World.now)
        } operation: {
            try await LocalPurge(database: after.store).sweep()
        }
        #expect(report.familiesPurged == 1)
        let remaining = try await after.store.read { db in
            try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM container WHERE id = ?", arguments: [world.postID]) ?? 0
        }
        #expect(remaining == 0, "the control sweep purged the family the teardown left whole")
        after.store.asRebindable().binding.lock()
    }

    /// **The lock road's own ORDER (`AppServices.stop()` cancels the held sweep
    /// without awaiting it, THEN the pool closes):** the sweep is cancelled while
    /// its read is parked, then the store is locked under it. Whatever the
    /// cancelled read answers (it may finish, or be interrupted), the lock still
    /// returns only after the read was let go, the close is clean, nothing
    /// purged, and the family stands whole.
    @Test func theLockRoadsCancelThenCloseMidReadEndsTheSweepWithNothingHalfDone() async throws {
        let world = try World.make()
        defer { world.cleanUp() }
        let hold = ReaderHold()
        try world.plant(hold)
        hold.arm()

        let sweep = world.startSweep()
        let parked = await hold.awaitEntered(seconds: 10)
        try #require(parked, "the sweep's collectRoots read is parked mid-step on the pool's reader")

        sweep.cancel()
        let locking = try await startLock(world, hold)
        try await Task.sleep(for: .milliseconds(500))
        hold.release()

        let ended = await sweep.value
        let lock = await locking.value

        #expect(lock.returnedAfterRelease,
                "the lock returned only after the held read was let go — the close waited for it")
        #expect(lock.clean, "the close is clean: \(lock.failure ?? "")")
        if case .success(let report) = ended {
            #expect(report.familiesPurged == 0 && report.rowsPurgedLocally == 0,
                    "a cancelled sweep under a lock purges nothing: \(report)")
        }

        let after = try world.reopenedFacts()
        #expect(after.container == 1 && after.blocks == 2 && after.intents == 1,
                "the family stands whole and its intent live — nothing half-done: \(after)")
        after.store.asRebindable().binding.lock()
    }
}
