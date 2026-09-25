//
//  DataSafetyTests.swift
//  VariorumTests
//
//  Phase 13l, Act 4 (ledger rows 11–13) — the second backup destination, its
//  retention rule, the per-run integrity check, the run log, and the runbook.
//
//  What these pin, in the order they matter:
//   · the RETENTION rule as a pure function (14 dailies + 4 weeklies — her
//     unobjected kickoff default), including the two things it deliberately
//     is not: a calendar window, and a promotion schedule;
//   · that a run WRITES TO BOTH destinations, checks the copy it just wrote,
//     and records what it did — including when it could not;
//   · that an unreachable folder is REPORTED rather than silently skipped
//     (the silent-stop failure this whole phase exists to kill);
//   · that the runbook shipped in the app and the one in the repo are the
//     same document, and that the three sentences the app says are in it.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Backup retention — the 14+4 rule (13l row 11)")
struct BackupRetentionTests {
    private func day(_ index: Int, hour: Int = 3) -> Date {
        Date(timeIntervalSince1970: Double(index) * 86_400 + Double(hour) * 3600)
    }

    private func candidate(_ index: Int, hour: Int = 3) -> BackupRetention.Candidate {
        BackupRetention.Candidate(
            url: URL(fileURLWithPath: "/tmp/variorum-backup-d\(index)-h\(hour).sqlite"),
            date: day(index, hour: hour))
    }

    @Test func fourteenConsecutiveDaysAreAllKept() {
        let files = (0..<14).map { candidate(20_000 + $0) }
        #expect(BackupRetention.keep(files, policy: .secondDestination).count == 14)
        #expect(BackupRetention.prune(files, policy: .secondDestination).isEmpty)
    }

    @Test func beyondFourteenDaysOnlyOnePerWeekSurvives() {
        // 60 consecutive daily copies: 14 dailies + one from each of the 4
        // weeks before them = 18 files, and the rest go.
        let files = (0..<60).map { candidate(20_000 + $0) }
        let kept = BackupRetention.keep(files, policy: .secondDestination)
        #expect(kept.count == 18)
        #expect(BackupRetention.prune(files, policy: .secondDestination).count == 42)
        // The newest 14 days are among the survivors — the recent past is
        // never traded for the distant one.
        for index in 46..<60 {
            #expect(kept.contains(candidate(20_000 + index).url))
        }
    }

    @Test func theRuleCountsDAYSWITHCOPIESNotCalendarDays() {
        // The failure this guards: a fortnight away from the machine writes
        // no copies, and "keep 14 days' worth" must not then mean "keep
        // nothing". Two copies, 200 days apart, both survive.
        let files = [candidate(20_000), candidate(20_200)]
        #expect(BackupRetention.keep(files, policy: .secondDestination).count == 2)
    }

    @Test func aSecondCopyOnTheSameDayNeverCostsThatDayItsSlot() {
        // Automatic at 03:00, "Back Up Now" at 11:00 — one day, one slot,
        // and the NEWER file is the one kept.
        var files = (0..<14).map { candidate(20_000 + $0) }
        let manual = candidate(20_013, hour: 11)
        files.append(manual)
        let kept = BackupRetention.keep(files, policy: .secondDestination)
        #expect(kept.contains(manual.url), "the newest copy of a day represents it")
        #expect(!kept.contains(candidate(20_013).url), "its older twin goes")
        #expect(kept.count == 14, "a second copy of one day does not buy a 15th day")
    }

    @Test func keepAndPrunePartitionTheInputExactly() {
        let files = (0..<90).map { candidate(20_000 + $0) }
        let kept = BackupRetention.keep(files, policy: .secondDestination)
        let doomed = Set(BackupRetention.prune(files, policy: .secondDestination))
        #expect(kept.isDisjoint(with: doomed))
        #expect(kept.union(doomed) == Set(files.map(\.url)))
    }

    @Test func theOldestKeptDateIsTheHonestReach() {
        let files = (0..<60).map { candidate(20_000 + $0) }
        let oldest = BackupRetention.oldestKept(files, policy: .secondDestination)
        // 14 dailies covers days 46–59; the four weeklies reach back into
        // the 40s/30s/20s — about six weeks, never ninety days.
        let reachDays = (day(20_059).timeIntervalSince(try! #require(oldest))) / 86_400
        #expect(reachDays > 28 && reachDays < 49, "reach was \(reachDays) days")
    }
}

@Suite("The backup run — both destinations, integrity, the log (13l row 11)")
struct BackupRunTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13l-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A defaults suite of this test's own — never `.standard`, which is the
    /// author's real Mac while the suite runs beside her app. `@Sendable`
    /// provider rather than the object: `UserDefaults` is not `Sendable`, and
    /// the runs under test happen off-main by contract.
    private func scratchDefaults() -> @Sendable () -> UserDefaults {
        let suite = "variorum-13l-tests-\(UUID().uuidString)"
        return { UserDefaults(suiteName: suite)! }
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
            let post = try ops.createPost(title: "the second destination", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Words that must reach two places.")
        }
        return db
    }

    @Test func aRunChecksTheCopyItJustWroteAndSaysSo() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()

        let record = await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(),
                defaults: defaults(), now: Date(timeIntervalSince1970: 1_782_900_000),
                force: false)
        }.value

        #expect(record.primary.outcome == .written)
        #expect(record.primary.integrity == "ok",
                "the run checks the artifact, not just the mechanism")
        #expect(record.primary.integrityFailed == false)
        // No folder picked: SAID, not silently skipped.
        #expect(record.secondary.outcome == .noDestination)
        #expect(record.everythingWorked)
    }

    @Test func theCheckAnswersOnAWALFlaggedCopyAndLeavesItSelfContained() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        // An ON-DISK WAL source, not the in-memory double — and that is the
        // whole point of this test rather than a detail of it. SQLite's
        // backup API copies the source's header, so a copy of a WAL store is
        // ITSELF flagged WAL, and a read-only open of a WAL database is the
        // one shape that can fail for reasons a `DatabaseQueue` over a
        // journal-mode file never shows. Measured during the 13l drill:
        // reading one of the author's real backup copies is exactly what
        // creates the `-wal`/`-shm` siblings that turn up beside them.
        let storeURL = dir.appendingPathComponent("live.sqlite")
        let source = try AppDatabase.openStore(at: storeURL)
        try await source.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                VALUES ('c-wal', 'post', 'written under WAL', '2026-08-24T00:00:00.000Z',
                        '2026-08-24T00:00:00.000Z')
                """)
        }
        let copy = dir.appendingPathComponent("variorum-backup-2026-08-24-000000.sqlite")
        try await Task.detached { try source.backup(to: copy) }.value
        #expect(!FileManager.default.fileExists(atPath: copy.path + "-wal"),
                "a closed backup copy is self-contained — no sidecar carries content")

        // 13p: the source is a keyed store now (openStore under the test
        // custody), so its copy is ciphertext — the check carries the
        // store's own artifact configuration, exactly as performRun does.
        #expect(StoreBackup.integrityCheck(of: copy, using: source.artifactConfiguration())
                    == "ok",
                "a WAL-flagged copy — which every real copy is — must be checkable")
        // And it leaves no journal siblings behind: the -wal/-shm files that
        // make a restored file dangerous if they travel with it, and that a
        // read-only open of a WAL file needs and cannot create.
        for suffix in ["-wal", "-shm"] {
            #expect(!FileManager.default.fileExists(atPath: copy.path + suffix),
                    "the check left a \(suffix) sibling")
        }
        // Self-contained afterwards: a READ-ONLY open now works, which is the
        // property the runbook promises and the one that failed before.
        // (13p: with the store's key — the copy is ciphertext.)
        var readOnly = source.artifactConfiguration()
        readOnly.readonly = true
        let reopened = try DatabaseQueue(path: copy.path, configuration: readOnly)
        let title = try reopened.inDatabase { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-wal'")
        }
        #expect(title == "written under WAL", "and the content is untouched")
    }

    @Test func aCorruptedCopyIsReportedRatherThanCalledOK() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let notADatabase = dir.appendingPathComponent("variorum-backup-2026-08-24-000001.sqlite")
        try Data("this is not a database".utf8).write(to: notADatabase)
        let answer = StoreBackup.integrityCheck(of: notADatabase, using: GRDB.Configuration())
        #expect(answer != "ok", "a broken file must never read as ok")
        #expect(answer.contains("could not be checked") || answer.contains("malformed"))
    }

    @Test func theRunbookRidesBesideTheCopies() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let scratch = scratchDefaults()
        _ = await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir,
                configuration: .init(runbookText: DataSafetyCopy.runbook),
                defaults: scratch(),
                now: Date(timeIntervalSince1970: 1_782_900_000), force: false)
        }.value
        let runbook = dir.appendingPathComponent(StoreBackup.runbookFilename)
        let text = try String(contentsOf: runbook, encoding: .utf8)
        #expect(text == DataSafetyCopy.runbook)
    }

    @Test func anUnreachableFolderIsReportedNotSkipped() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        // A bookmark for a folder that no longer exists: the resolve fails,
        // and the run must SAY it failed. Silence here is the exact failure
        // mode ("the job that silently stopped") this phase exists to kill.
        let doomed = dir.appendingPathComponent("gone", isDirectory: true)
        try FileManager.default.createDirectory(at: doomed, withIntermediateDirectories: true)
        let bookmark = try doomed.bookmarkData(
            options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults().set(bookmark, forKey: BackupDestination.defaultsKey)
        try FileManager.default.removeItem(at: doomed)

        let leg = await Task.detached {
            // R1-m5 made the artifact configuration REQUIRED — this
            // plaintext-era scenario passes the plain one DELIBERATELY
            // (the store under test is unkeyed), which is now a visible
            // decision rather than a silent default.
            StoreBackup.performSecondLeg(
                directory: dir, configuration: .init(), defaults: defaults(),
                now: Date(), force: false,
                artifactConfiguration: GRDB.Configuration())
        }.value
        #expect(leg.outcome == .failed)
        #expect(leg.detail?.isEmpty == false)
        #expect(leg.succeeded == false)
    }

    @Test func theLogKeepsTheNewestRunsAndSurvivesAtItsCap() {
        let defaults = scratchDefaults()
        for index in 0..<(BackupLog.capacity + 5) {
            BackupLog.append(
                BackupRunRecord(
                    at: Date(timeIntervalSince1970: Double(index)),
                    primary: .init(outcome: .written, file: "f\(index)"),
                    secondary: .init(outcome: .noDestination)),
                to: defaults())
        }
        let log = BackupLog.read(defaults())
        #expect(log.count == BackupLog.capacity)
        #expect(log.first?.primary.file == "f\(BackupLog.capacity + 4)", "newest first")
    }

    @Test func aRunThatWroteNothingStillLeavesEvidence() async throws {
        // The one thing the files can never report: a run that produced no
        // file at all. That is what the log is for.
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        // Both runs in ONE detached task: the second is deliberately not due,
        // so the pair is "wrote / did not write" and the log holds both.
        await Task.detached {
            for stamp in [noon, noon.addingTimeInterval(3600)] {
                let record = StoreBackup.performRun(
                    database: source, directory: dir, configuration: .init(),
                    defaults: defaults(), now: stamp, force: false)
                BackupLog.append(record, to: defaults())
            }
        }.value
        let log = BackupLog.read(defaults())
        #expect(log.count == 2)
        #expect(log[0].primary.outcome == .upToDate, "the second run was not due")
        #expect(log[0].primary.integrity == nil, "nothing written, nothing to check")
        #expect(log[1].primary.outcome == .written)
    }

    @Test func forcingARunWritesEvenWhenNothingIsDue() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        _ = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: dir, configuration: .init(), now: noon)
        }.value
        let forced = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: dir, configuration: .init(),
                now: noon.addingTimeInterval(3600), force: true)
        }.value
        #expect(forced != nil, "Back Up Now must not be silently ignored")
    }
}

@Suite("The runbook and the sentences the app says (13l row 13)")
struct DataSafetyRunbookTests {
    /// The repo's own copy, located the way this repo's DDL walk does it.
    private var repoRunbook: URL {
        URL(fileURLWithPath: #filePath)          // …/App/Variorum/VariorumTests/…
            .deletingLastPathComponent()          // …/App/Variorum/VariorumTests
            .deletingLastPathComponent()          // …/App/Variorum
            .deletingLastPathComponent()          // …/App
            .deletingLastPathComponent()          // the repo root
            .appendingPathComponent("notes/DataSafetyRunbook.md")
    }

    @Test func theShippedRunbookAndTheRepoCopyAreOneDocument() throws {
        let onDisk = try String(contentsOf: repoRunbook, encoding: .utf8)
        if onDisk != DataSafetyCopy.runbook {
            // 13p ladder R1-M1 made §8 a COMPOSITION over
            // `ProtectionCopy` (one brain), so a re-worded protection
            // sentence now changes the rendered runbook and the repo file
            // must follow. On mismatch, write the rendered text somewhere
            // the fixer can copy from, and say where.
            let rendered = FileManager.default.temporaryDirectory
                .appendingPathComponent("DataSafetyRunbook-rendered.md")
            try? DataSafetyCopy.runbook.write(
                to: rendered, atomically: true, encoding: .utf8)
            let hint = "notes/DataSafetyRunbook.md has drifted from "
                + "DataSafetyCopy.runbook — the rendered text is at "
                + "\(rendered.path); copy it over the repo file."
            Issue.record(Comment(rawValue: hint))
        }
    }

    @Test func theRunbookCarriesTheThreeSentencesTheAppSays() {
        for sentence in [
            DataSafetyCopy.syncedRestoreWarning,
            DataSafetyCopy.localRestoreWarning,
            DataSafetyCopy.bothSidedDeletionTruth,
        ] {
            #expect(DataSafetyCopy.runbook.contains(sentence),
                    "the runbook must say what the app says")
        }
    }

    @Test func bothPopulationsAreWarnedAndNeitherIsSoftened() {
        // Her post-sitting ruling's letter: BOTH warnings ship, and the
        // synced one carries the real nuance rather than a comfortable half.
        #expect(DataSafetyCopy.syncedRestoreWarning.contains("Trash"))
        #expect(DataSafetyCopy.syncedRestoreWarning.contains("permanently deleted"))
        #expect(DataSafetyCopy.localRestoreWarning.contains("time travel"))
        #expect(DataSafetyCopy.localRestoreWarning.contains("permanently"))
        // Her clarity mandate: the BOTH-SIDED truth, both sides present.
        #expect(DataSafetyCopy.bothSidedDeletionTruth.contains("not from backup files"))
        #expect(DataSafetyCopy.bothSidedDeletionTruth.contains("still inside that backup file"))
    }

    /// **Ladder R1-M1 — §8 tells the encrypted-era truth, composed from
    /// the ONE brain.** The shipped RESTORE.md's §8 once claimed *"Your
    /// local store and these backups are NOT encrypted by that key, so
    /// your writing is still here"* — false since 13p Batch 1, and written
    /// into every backup folder each run. pre-13x 5a (§13): the 13p loss
    /// legs / loss math retired with the at-open presets; §8 is now
    /// COMPOSED from the posture cards' FLOORS (copy §1 — the same
    /// sentences the pane's cards show; the two floors of design §1.21),
    /// and points at *Encryption Explained*. This pin holds it there.
    /// (5b rewrites the whole runbook per posture on top of this.)
    @Test func sectionEightIsComposedFromTheProtectionBrainAndClaimsNothingStale() {
        let runbook = DataSafetyCopy.runbook
        #expect(!runbook.contains("are NOT encrypted by that key"),
                "the plaintext-era claim must not survive anywhere in the runbook")
        #expect(!runbook.contains("your writing is still here"),
                "the unconditional conclusion contradicts the ruled floors")
        for posture in [Posture.standard, Posture.castle] {
            #expect(runbook.contains("**\(ProtectionCopy.postureName(posture))** — the floor:"))
            let floor = ProtectionCopy.postureCard(posture).first { $0.label == "The floor" }?.text
            #expect(floor != nil)
            if let floor { #expect(runbook.contains(floor), "§8 carries the \(posture) floor verbatim from the card") }
        }
        #expect(runbook.contains("“Encryption Explained”"), "§8 points at the seeded book")
        #expect(!runbook.contains("at-open mode"), "the retired 13p mode vocabulary is gone from §8")
    }

    @Test func theRunbookCoversWhatItsTableOfContentsPromises() {
        // The ledger row's own list, asserted as section headings so a
        // future edit cannot quietly drop one.
        for heading in [
            "## 1. What protects your writing, in order",
            "## 2. Where the backups are",
            "## 3. Restoring a backup",
            "## 4. What restoring does to things you deleted",
            "## 5. What deletion means",
            "## 6. Reading one backup without restoring it",
            "## 7. If the mirror is lost, or a device is",
            "## 8. If you forget the passphrase",
        ] {
            #expect(DataSafetyCopy.runbook.contains(heading), "missing \(heading)")
        }
        // The mirror section's load-bearing claim (her overnight questions):
        // a peer, not a backup — and the two proven roads named.
        #expect(DataSafetyCopy.runbook.contains("A PEER, not a backup"))
        #expect(DataSafetyCopy.runbook.contains("recovery phrase"))
        // The recovery-as-copy doctrine (her regret-road ruling).
        #expect(DataSafetyCopy.runbook.contains("Always copy out as new"))
    }
}

/// A main-actor flag the pin's Task sets (a captured `var` may not be
/// mutated from a Task's closure).
@MainActor
private final class SingleFlightFlag {
    var value = false
}

/// **18k C5 — 17e's P38: the backup run is SINGLE-FLIGHT.**
///
/// `StoreBackup.run` used to spawn a detached run per request with no
/// in-flight guard, and a snapshot's name is second-granular — so two forced
/// runs in one second wrote the SAME path, raced `integrityCheck`'s sidecar
/// deletion, and both `prune`d the same doomed set (the loser's `removeItem`
/// throwing out as a false `failed` for a snapshot that succeeded). Doors that
/// reach it with no shared latch: the hourly tick, the insurance toggle (no
/// `busy`), the iCloud offer, the posture switch.
///
/// RED-ON-OLD (behavioural revert R1-i5, recorded in the 18k C5 record): two
/// runs, two log records, two outcomes — and the pane never busy.
@MainActor
@Suite("Backup single-flight (18k C5 — 17e P38)")
struct BackupSingleFlightTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-18k-c5-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Never `.standard` (the dev store's own domain while the suite runs).
    private func scratchDefaults() -> @Sendable () -> UserDefaults {
        let suite = "variorum-18k-c5-tests-\(UUID().uuidString)"
        return { UserDefaults(suiteName: suite)! }
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
            let post = try ops.createPost(title: "one copy, once", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Words worth one careful copy.")
        }
        return db
    }

    /// The shape the app's real store has: an on-disk WAL pool (readers run
    /// beside the writer), so two runs' snapshot reads are not serialised by
    /// the source the way an in-memory queue's are.
    private func populatedOnDiskDatabase(in dir: URL) throws -> AppDatabase {
        let db = try AppDatabase.onDisk(
            url: dir.appendingPathComponent("store.sqlite"), key: nil)
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "one copy, once", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Words worth one careful copy.")
        }
        return db
    }

    /// An older copy already in the folder, so a run's prune (keep 1) has
    /// something to take — the half of the race that produced the false
    /// `failed`.
    private func seedOlderCopy(_ source: AppDatabase, in dir: URL, at stamp: Date) async throws {
        _ = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: dir, configuration: .init(), now: stamp, force: true)
        }.value
    }

    /// THE P38 pin: Back Up Now twice inside one second (two doors, or one
    /// door and the insurance toggle) is ONE run — one snapshot, one log
    /// record, the second request handed the first run's outcome.
    @Test func twoForcedRunsInOneSecondAreOneRun() async throws {
        let storeDir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: storeDir) }
        let source = try populatedOnDiskDatabase(in: storeDir)
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        try await seedOlderCopy(source, in: dir, at: noon.addingTimeInterval(-2 * 86_400))

        var configuration = StoreBackup.Configuration()
        configuration.keep = 1
        // One clock reading for both requests: the same second, by construction.
        let backup = StoreBackup(
            database: source, directory: dir, configuration: configuration,
            defaults: defaults, now: { noon })
        let first = Task { await backup.backUpNow() }
        let second = Task { await backup.backUpNow() }
        let (a, b) = (await first.value, await second.value)

        #expect(BackupLog.read(defaults()).count == 1, "ONE run for two requests")
        #expect(a == b, "the second request is handed the first run's outcome")
        #expect(a.primary.outcome == .written)
        #expect(b.primary.outcome != .failed, "never a false 'failed' for a copy that landed")
        #expect(backup.lastError == nil)
        let copies = try StoreBackup.existingBackups(in: dir)
        #expect(copies.count == 1, "one snapshot kept (keep 1), the older one pruned once")
        #expect(copies.first?.lastPathComponent == a.primary.file)
    }

    /// The guard on the one call this fix had to make: a FORCED request
    /// arriving while an UNFORCED run is in flight is not handed that run's
    /// "already up to date" — Back Up Now promises a fresh copy regardless of
    /// the interval. It waits for the due-check, then runs its own (never in
    /// parallel). Green on the unlatched door too (there the two ran side by
    /// side); what it guards is the latch's shape (mutation M-P38c:
    /// "coalesce every request").
    @Test func aForcedRequestBehindADueCheckStillWritesAFreshCopy() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        // A copy from an hour ago: the due-check has nothing to do.
        try await seedOlderCopy(source, in: dir, at: noon.addingTimeInterval(-3_600))

        let backup = StoreBackup(
            database: source, directory: dir, configuration: .init(),
            defaults: defaults, now: { noon })
        let tick = Task { await backup.backupIfDue() }
        let pressed = Task { await backup.backUpNow() }
        let (due, forced) = (await tick.value, await pressed.value)

        #expect(due.primary.outcome == .upToDate, "the tick found nothing due")
        #expect(forced.primary.outcome == .written,
                "Back Up Now wrote a fresh copy — it was not handed the tick's answer")
        #expect(BackupLog.read(defaults()).count == 2, "two runs, one after the other")
        #expect(backup.lastError == nil)
    }

    /// The pane's un-latched door: turning the plain-text insurance ON runs a
    /// forced backup, and it now holds the pane's ONE latch while it does —
    /// so Back Up Now and the folder doors grey (`.disabled(model.busy)`)
    /// exactly as they do behind their own runs, and a Back Up Now that
    /// reaches the model anyway starts nothing.
    @Test func theInsuranceToggleHoldsThePanesLatchWhileItsBackupRuns() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        let backup = StoreBackup(
            database: source, directory: dir, configuration: .init(),
            defaults: defaults, now: { noon })
        let model = DataSafetyModel(backup: backup, defaults: defaults)

        let finished = SingleFlightFlag()
        let toggling = Task {
            await model.setInsurance(true)
            finished.value = true
        }
        var sawBusy = false
        for _ in 0..<5000 where !finished.value {
            if model.busy { sawBusy = true; break }
            await Task.yield()
        }
        #expect(sawBusy, "the toggle's backup pass holds the pane busy — its siblings grey")
        // A Back Up Now that reaches the model while the pass runs starts nothing.
        await model.backUpNow()
        await toggling.value

        #expect(!model.busy, "and lets go when it lands")
        #expect(model.insuranceEnabled)
        #expect(BackupLog.read(defaults()).count == 1, "one run: the toggle's")
        #expect(model.note?.contains("Copied") == true, "the toggle's receipt speaks")
    }
}
