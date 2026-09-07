//
//  Phase8ServicesTests.swift
//  VariorumTests
//
//  Phase 8's app-layer services: A4 dev-store separation (the fence), A1
//  rotating store backups (the net), and Step 5's idle auto-commit
//  scheduler (the insurance clock) — deterministic clocks throughout.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// Phase 14b: the App-suite fixed E2EE key world — a working provider so
/// wiring tests' rounds reach their transports (post-14b there is no
/// plaintext mode; a refusing provider is the pre-enrollment state, pinned
/// separately). Target-internal, shared by every wiring suite; never the
/// real Keychain.
struct AppTestKeyProvider: SyncKeyProviding {
    func currentKeys() throws -> SyncEncryptionKeys {
        SyncEncryptionKeys(
            corpusKey: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x40) })),
            corpusKeyID: "app-test-corpus-key-000000000001",
            keyProof: KeyProof.wireToken(
                master: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x20) }))))
    }
    /// pre-13x 1a: the identity rides the provider (never the store).
    func deviceIdentity() throws -> String { "app-test-device-0001" }
}

// MARK: - A4: dev-store separation

@Suite("Store location (Phase 8, A4)")
struct StoreLocationTests {
    @Test func debugBuildsDefaultToTheDevStore() {
        #expect(StoreLocation.resolve(
            isDebugBuild: true, arguments: [], environment: [:]) == .dev)
    }

    @Test func theOptInReachesTheRealStoreFromADebugBuild() {
        #expect(StoreLocation.resolve(
            isDebugBuild: true,
            arguments: [StoreLocation.realStoreArgument],
            environment: [:]) == .real)
        #expect(StoreLocation.resolve(
            isDebugBuild: true,
            arguments: [],
            environment: [StoreLocation.realStoreEnvironmentKey: "1"]) == .real)
        // A non-"1" value is not an opt-in.
        #expect(StoreLocation.resolve(
            isDebugBuild: true,
            arguments: [],
            environment: [StoreLocation.realStoreEnvironmentKey: "0"]) == .dev)
    }

    @Test func releaseBuildsOpenTheRealStoreUnconditionally() {
        #expect(StoreLocation.resolve(
            isDebugBuild: false, arguments: [], environment: [:]) == .real)
    }

    @Test func theTwoVariantsResolveToSeparateHomes() throws {
        let real = try AppDatabase.defaultStoreURL(variant: .real)
        let dev = try AppDatabase.defaultStoreURL(variant: .dev)
        #expect(real != dev)
        #expect(real.pathComponents.contains("Variorum"))
        #expect(dev.pathComponents.contains("Variorum-dev"))
        #expect(real.lastPathComponent == "variorum.sqlite")
        #expect(dev.lastPathComponent == "variorum.sqlite",
                "same file name, different home — both flow through openStore(at:)")
    }
}

// MARK: - A1: rotating store backups

@Suite("Store backup (Phase 8, A1)")
struct StoreBackupTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-backup-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func populatedDatabase() throws -> AppDatabase {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "backed up", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "The words worth keeping.")
        }
        return db
    }

    @Test func aBackupCopyOpensAndMatchesTheSourceRowCounts() async throws {
        let source = try populatedDatabase()
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let url = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: directory,
                configuration: .init(), now: Date(timeIntervalSince1970: 1_782_900_000))
        }.value
        let copyURL = try #require(url)

        // The copy opens through the SAME recoverable-open path the app uses.
        let copy = try AppDatabase.openStore(at: copyURL)
        for table in ["container", "block", "variant", "container_block"] {
            let sourceCount = try await source.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM \(table)") ?? -1
            }
            let copyCount = try await copy.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM \(table)") ?? -2
            }
            #expect(sourceCount == copyCount, "\(table) row count drifted in the copy")
        }
    }

    @Test func aFreshEnoughBackupSuppressesTheNext() async throws {
        let source = try populatedDatabase()
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let noon = Date(timeIntervalSince1970: 1_782_900_000)

        let first = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: directory, configuration: .init(), now: noon)
        }.value
        #expect(first != nil)

        // One hour later: not due (interval 24 h).
        let second = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: directory, configuration: .init(),
                now: noon.addingTimeInterval(3600))
        }.value
        #expect(second == nil)

        // A day + later: due again.
        let third = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: directory, configuration: .init(),
                now: noon.addingTimeInterval(25 * 3600))
        }.value
        #expect(third != nil)
        #expect(try StoreBackup.existingBackups(in: directory).count == 2)
    }

    @Test func rotationPrunesOldestDownToTheCap() async throws {
        let source = try populatedDatabase()
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        // 16 daily backups at a keep-3 cap → 3 newest survive.
        let start = Date(timeIntervalSince1970: 1_782_900_000)
        for day in 0..<16 {
            _ = try await Task.detached {
                try StoreBackup.performBackupIfDue(
                    database: source, directory: directory,
                    configuration: .init(interval: 24 * 3600, keep: 3),
                    now: start.addingTimeInterval(Double(day) * 25 * 3600))
            }.value
        }
        let survivors = try StoreBackup.existingBackups(in: directory)
        #expect(survivors.count == 3)
        // Newest survive: the last file's stamp is the final run's.
        let dates = survivors.compactMap(StoreBackup.date(fromBackupURL:))
        #expect(dates.count == 3)
        #expect(dates == dates.sorted())
        #expect(dates.last.map { $0 > start.addingTimeInterval(14 * 25 * 3600) } == true)
    }

    /// pre-13x 1a (§6): a KEYED store's snapshot is named
    /// `variorum-backup-<stamp>-<fp8>.sqlite`; both that name and the 13p-era
    /// one list and date-parse, and the short fingerprint reads back. RED ON
    /// OLD: the name carried no fingerprint and `date(fromBackupURL:)`
    /// refused the suffixed name.
    @Test func aKeyedStoresSnapshotCarriesItsShortFingerprintAndBothNamesParse() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-backup-fp-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(
            at: dir.appendingPathComponent("variorum.sqlite"), custody: .inMemory(initial: key))
        let backups = dir.appendingPathComponent("Backups", isDirectory: true)
        let now = Date(timeIntervalSince1970: 1_782_900_000)
        let written = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: database, directory: backups, configuration: .init(), now: now, force: true)
        }.value
        let url = try #require(written)
        let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
        #expect(url.lastPathComponent.hasSuffix("-\(fp8).sqlite"), "the snapshot names its key")
        #expect(StoreBackup.shortFingerprint(fromBackupURL: url) == fp8)
        #expect(StoreBackup.date(fromBackupURL: url) == now)
        // The 13p-era name beside it lists and parses too.
        let legacy = backups.appendingPathComponent("variorum-backup-2026-07-18-020000.sqlite")
        try Data("x".utf8).write(to: legacy)
        let listed = try StoreBackup.existingBackups(in: backups)
        #expect(listed.count == 2)
        #expect(StoreBackup.date(fromBackupURL: legacy) != nil)
        #expect(StoreBackup.shortFingerprint(fromBackupURL: legacy) == nil)
        #expect(StoreBackup.date(fromBackupURL: backups.appendingPathComponent("variorum-backup-2026-07-18-020000x.sqlite")) == nil,
                "a malformed tail never parses as a date")
    }

    @Test func backupOfAnInUseWALStoreIsConsistent() async throws {
        // A real on-disk WAL pool with writes landing DURING the backup.
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("live.sqlite")
        let store = try AppDatabase.openStore(at: storeURL)

        let postID = try withDependencies {
            $0.database = store
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "busy", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "first")
            return post.id
        }

        // Concurrent writer hammering the store while the backup runs.
        let writer = Task.detached {
            try withDependencies {
                $0.database = store
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_100))
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
            } operation: {
                let ops = Operations()
                for index in 0..<50 {
                    _ = try ops.newBlock(in: postID, text: "concurrent \(index)")
                }
            }
        }
        let copyURL = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: store, directory: directory.appendingPathComponent("Backups"),
                configuration: .init(), now: Date())
        }.value
        try await writer.value

        let copy = try AppDatabase.openStore(at: try #require(copyURL))
        // Consistent snapshot: integrity passes and every placed block has
        // its variant (the copy is transactionally whole, wherever the
        // snapshot fell in the write stream).
        let integrity = try await copy.read { try String.fetchOne($0, sql: "PRAGMA integrity_check") }
        #expect(integrity == "ok")
        let dangling = try await copy.read {
            try Int.fetchOne($0, sql: """
                SELECT COUNT(*) FROM container_block cb
                WHERE NOT EXISTS (SELECT 1 FROM block b WHERE b.id = cb.block_id)
                """) ?? -1
        }
        #expect(dangling == 0)
    }
}

// MARK: - Step 5: the idle auto-commit scheduler

@MainActor
@Suite("Idle auto-commit scheduler (Phase 8, Step 5)")
struct IdleCommitSchedulerTests {
    /// One deterministic world: in-memory store, ticking ops clock from
    /// 2026-07-01T00:00:00Z, a scheduler with an injected wall clock and an
    /// in-memory sweep mark.
    private func withWorld<T>(
        _ body: @MainActor (AppSession, IdleCommitScheduler, LockIsolated<Date>, LockIsolated<[String]>) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let clock = LockIsolated(start)
            let marks = LockIsolated<[String]>([])
            let scheduler = IdleCommitScheduler(
                database: db,
                runner: session.runner,
                now: { clock.value },
                loadMark: { marks.value.last },
                saveMark: { mark in marks.withValue { $0.append(mark) } })
            return try await body(session, scheduler, clock, marks)
        }
    }

    @Test func aDirtyThenIdlePostGetsExactlyOneAutoCommit() async throws {
        try await withWorld { session, scheduler, clock, _ in
            let post = try session.operations.createPost(title: "journal", profile: .journal)
            let minted = try session.operations.newBlock(in: post.id, text: "typed")
            try session.operations.autosave(
                minted.variant.id, text: "typed, then left alone", charDelta: 17)

            // 26 h later (well past `idle_commit_hours`, which 13j J11 moved
            // from 24 h to 2 h): one quiet insurance commit. The number is
            // left where it was — it was never the bar, only a time past it.
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 26 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 1)
            let kinds = try await session.database.read {
                try String.fetchAll($0, sql: "SELECT kind FROM commit_point")
            }
            #expect(kinds == ["auto"])

            // A later sweep finds nothing: at most one per idle period.
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 30 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 0)
            #expect(try await session.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM commit_point") ?? -1
            } == 1)
        }
    }

    @Test func notYetIdleUntouchedAndCleanPostsGetNoCommit() async throws {
        try await withWorld { session, scheduler, clock, _ in
            // Not yet idle: edited "recently" relative to the clock.
            let fresh = try session.operations.createPost(title: "fresh", profile: .journal)
            let freshMint = try session.operations.newBlock(in: fresh.id, text: "warm")
            try session.operations.autosave(freshMint.variant.id, text: "warm edit", charDelta: 5)

            // Untouched: a post with no blocks at all.
            _ = try session.operations.createPost(title: "empty", profile: .journal)

            // Clean: committed after its last edit.
            let clean = try session.operations.createPost(title: "clean", profile: .journal)
            let cleanMint = try session.operations.newBlock(in: clean.id, text: "done")
            _ = try session.operations.commit(cleanMint.variant.id)

            // 13j J11 (her cadence ruling — a CONSEQUENTIAL pin edit,
            // annotated in place): the backstop bar moved 24 h → 2 h, so the
            // two probes move with it. The CLAIM is byte-unchanged — a
            // not-yet-idle post gets nothing, and past the bar exactly the
            // dirty one is insured while the clean and empty ones still get
            // nothing.
            //
            // Only 1 h passes: nothing is idle past the 2 h bar…
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 1 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 0)

            // …then 4 h: the fresh (dirty) post gets its one commit; the
            // clean and empty posts still get none.
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 4 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 1)
        }
    }

    @Test func theMarkAdvancesSoSweepsPayOnlyForNewEdits() async throws {
        try await withWorld { session, scheduler, clock, marks in
            let post = try session.operations.createPost(title: "journal", profile: .journal)
            let minted = try session.operations.newBlock(in: post.id, text: "day one")
            try session.operations.autosave(minted.variant.id, text: "day one text", charDelta: 5)

            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 26 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 1)
            #expect(marks.value.count == 1, "the sweep advances the low-water mark")

            // The next sweep's window opens at the recorded mark — the old
            // edit is never revisited (bounded by NEW edits, P1).
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 50 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 0)
            #expect(marks.value.count == 2)
            #expect(marks.value[1] > marks.value[0], "marks are monotone")
        }
    }
}

// MARK: - Review round 1: the A4 fence's sync seam (BLOCKER) and the
// session-layer serialization guarantee (MINOR)

/// A transport that parks the round at a gate — proves the old round is
/// mid-flight while the session is asked to re-configure.
private actor RoundGateTransport: SyncTransport {
    private var gated = true
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []
    private var parked = false

    func awaitParked() async {
        if parked { return }
        await withCheckedContinuation { arrivalWaiters.append($0) }
    }

    func open() {
        gated = false
        let waiters = gateWaiters
        gateWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func pass() async {
        guard gated else { return }
        parked = true
        await withCheckedContinuation { continuation in
            gateWaiters.append(continuation)
            let arrivals = arrivalWaiters
            arrivalWaiters.removeAll()
            for arrival in arrivals { arrival.resume() }
        }
        parked = false
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
        await pass()
        return batch.map { _ in .rejected(current: nil) }
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
        await pass()
        return []
    }

    /// Round plumbing (SyncSpec §12) — never parks; the gate models the
    /// round's DATA calls.
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

private actor RecordingTransport: SyncTransport {
    private(set) var calls = 0
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
        calls += 1
        return batch.map { _ in .rejected(current: nil) }
    }
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
        calls += 1
        return []
    }
    /// Uncounted round plumbing (the pins count data calls).
    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
}

@MainActor
@Suite("Sync session fences (Phase 8, review round 1)")
struct SyncSessionFenceTests {
    /// THE BLOCKER PIN (re-shaped at Phase 9c, Step 5 — the paste-in is
    /// retired, but the fence's mechanism is unchanged): debug and release
    /// builds share a Keychain, so once the author signs in, an ungated
    /// dev-store session would auto-configure sync and pair the dev store
    /// with the ONE production mirror — pulling her corpus into the dev
    /// store and pushing dev-bug writes to her real devices. A dev-store
    /// session must refuse EVERY transport composition (the sign-in wiring
    /// funnels through `configure(transport:)` now).
    @Test func devStoreSessionsNeverConfigureSyncWhateverTransportIsComposed() async throws {
        let db = try AppDatabase.inMemory()

        // The dev-store session, in the exact post-sign-in state a debug
        // smoke launch would find (the signed-in wiring composing a chain).
        let dev = SyncSession(database: db, allowsSync: false)
        await dev.configure(transport: RecordingTransport(), keyProvider: AppTestKeyProvider())
        #expect(!dev.isConfigured,
                "a dev-store session must never pair with the production mirror")
        dev.stop()

        // The real-store session configures from the same composition.
        let real = SyncSession(database: db, allowsSync: true)
        await real.configure(transport: RecordingTransport(), keyProvider: AppTestKeyProvider())
        #expect(real.isConfigured)
        real.stop()
    }

    /// THE RE-CONFIGURE PIN (MINOR): a key-rotation re-paste while a round
    /// is mid-flight must drain the old scheduler before a new chain can
    /// run — A3's one-round-at-a-time is per-scheduler, so the session owns
    /// the cross-scheduler guarantee.
    @Test func reconfigureDrainsTheInFlightRoundBeforeTheNewChainRuns() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let gate = RoundGateTransport()
        let spy = RecordingTransport()

        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            await session.configure(transport: gate, keyProvider: AppTestKeyProvider())
            session.triggerSync()
            await gate.awaitParked()  // the old round is provably mid-flight

            let reconfigure = Task { await session.configure(transport: spy, keyProvider: AppTestKeyProvider()) }
            // A trigger landing mid-reconfigure must not start a round on
            // any chain while the old round is still in flight.
            try await Task.sleep(for: .milliseconds(50))
            session.triggerSync()
            try await Task.sleep(for: .milliseconds(50))
            #expect(!session.isConfigured,
                    "the new chain must not exist until the old round drained")
            #expect(await spy.calls == 0,
                    "no round may run on the new transport while the old round is mid-flight")

            await gate.open()
            await reconfigure.value
            #expect(session.isConfigured)

            // The new chain works once the old one drained.
            session.triggerSync()
            for _ in 0..<2000 {
                if await spy.calls > 0 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(await spy.calls > 0)
            session.stop()
        }
    }

    /// pre-13x ladder round 1, F2 (MAJOR-1) — THE MECHANISM PIN: `stop()`
    /// retires the scheduler, so a later `triggerSync()` runs NOTHING (the
    /// pre-F2 resume leaf's exact no-op — a refused ceremony left sync dead
    /// for the session); the resume road is a RE-CONFIGURE, after which a
    /// trigger runs a round again.
    @Test func aStoppedSessionRunsNothingOnTriggerAndTheReconnectRoadRunsARoundAgain() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let spy = RecordingTransport()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            await session.configure(transport: spy, keyProvider: AppTestKeyProvider())
            #expect(session.isConfigured)
            // The ceremony's pause.
            session.stop()
            #expect(!session.isConfigured, "stop() retires the chain")
            // The pre-F2 resume leaf: a bare trigger.
            session.triggerSync()
            for _ in 0..<50 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(2))
            }
            #expect(await spy.calls == 0, "a trigger after stop() runs no round — the no-op MAJOR-1 traced")
            // The F2 resume road: reconnect, then trigger.
            await session.configure(transport: spy, keyProvider: AppTestKeyProvider())
            #expect(session.isConfigured)
            session.triggerSync()
            for _ in 0..<2000 {
                if await spy.calls > 0 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(await spy.calls > 0, "the reconnected chain runs a round")
            session.stop()
        }
    }
}

// MARK: - Review round 1: the sweep mark's variant scoping + error posture
// (MINOR)

@MainActor
@Suite("Idle sweep mark scoping & error posture (Phase 8, review round 1)")
struct IdleSweepMarkTests {
    @Test func aDevStoreSweepNeverAdvancesTheRealStoresMark() async throws {
        let devKey = IdleCommitScheduler.markDefaultsKey(for: .dev)
        let realKey = IdleCommitScheduler.markDefaultsKey(for: .real)
        UserDefaults.standard.removeObject(forKey: devKey)
        UserDefaults.standard.removeObject(forKey: realKey)
        defer {
            UserDefaults.standard.removeObject(forKey: devKey)
            UserDefaults.standard.removeObject(forKey: realKey)
        }

        let db = try AppDatabase.inMemory()
        let session = try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
        } operation: { @MainActor in
            AppSession(database: db)
        }
        // Default (UserDefaults-backed) persistence, DEV variant.
        let devScheduler = IdleCommitScheduler(
            database: db, runner: session.runner, storeVariant: .dev,
            now: { Date(timeIntervalSince1970: 1_782_864_000 + 48 * 3600) })
        await devScheduler.sweepNow()

        #expect(UserDefaults.standard.string(forKey: devKey) != nil,
                "the dev sweep records its own mark")
        #expect(UserDefaults.standard.string(forKey: realKey) == nil,
                "a dev-store sweep must never advance the real store's mark — real edits in the skipped window would lose idle insurance")
    }

    @Test func aFailingAskHoldsTheMarkSoTheNextSweepRetries() async throws {
        struct AskFailure: Error {}
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 10))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "journal", profile: .journal)
            let minted = try session.operations.newBlock(in: post.id, text: "draft")
            try session.operations.autosave(minted.variant.id, text: "draft, grown", charDelta: 7)

            let marks = LockIsolated<[String]>([])
            let failing = LockIsolated(true)
            let runner = session.runner
            let scheduler = IdleCommitScheduler(
                database: db,
                runner: runner,
                now: { start.addingTimeInterval(30 * 3600) },
                loadMark: { marks.value.last },
                saveMark: { mark in marks.withValue { $0.append(mark) } },
                ask: { containerID in
                    if failing.value { throw AskFailure() }
                    return try await runner.run { ops in
                        try ops.idleAutoCommit(containerID).count
                    }
                })

            // The transient failure: the mark must NOT advance — the next
            // sweep re-asks instead of skipping the window forever.
            await scheduler.sweepNow()
            #expect(scheduler.lastError != nil)
            #expect(marks.value.isEmpty,
                    "a failed ask holds the mark for retry — never swept past")

            // Healed: the retry commits and the mark advances.
            failing.setValue(false)
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 1)
            #expect(marks.value.count == 1)
        }
    }
}
