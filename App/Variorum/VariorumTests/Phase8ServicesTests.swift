//
//  Phase8ServicesTests.swift
//  VariorumTests
//
//  Phase 8's app-layer services: A4 dev-store separation (the fence), A1
//  rotating store backups (the net), and Step 5's idle auto-commit
//  scheduler (the insurance clock) — deterministic clocks throughout.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

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

            // 26 h later (idle_commit_hours = 24): one quiet insurance commit.
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

            // Only 23 h pass: nothing is idle past the 24 h bar…
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 23 * 3600))
            await scheduler.sweepNow()
            #expect(scheduler.lastSweepCommitCount == 0)

            // …then 26 h: the fresh (dirty) post gets its one commit; the
            // clean and empty posts still get none.
            clock.setValue(Date(timeIntervalSince1970: 1_782_864_000 + 26 * 3600))
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
