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
                source: nil, directory: dir, configuration: .init(), defaults: defaults(),
                now: Date(), force: false,
                artifactConfiguration: GRDB.Configuration())
        }.value
        #expect(leg.outcome == .failed)
        #expect(leg.detail?.isEmpty == false)
        #expect(leg.succeeded == false)
    }

    /// **18k ladder round 1, NIT 1 — the failed-primary sentence is honest
    /// (copy correctness; PROVISIONAL, QUESTIONS #148).** When THIS RUN made
    /// no snapshot (the primary leg failed) and the far folder is due, the
    /// far leg copies nothing by design (C7's pass-through — it never
    /// re-discovers by listing). Its sentence must blame THIS run, not claim
    /// no snapshot exists at all: snapshots usually do, beside the library —
    /// this act just has none to hand through. RED-ON-OLD by the old string
    /// ("There is no snapshot to copy yet.").
    @Test func aFailedPrimaryLegLeavesTheFarFolderAnHonestSentence() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        // A REACHABLE picked folder that is DUE (empty) — so the guard the
        // sentence lives in is the one that answers, not the resolve.
        let picked = dir.appendingPathComponent("picked", isDirectory: true)
        try FileManager.default.createDirectory(at: picked, withIntermediateDirectories: true)
        let bookmark = try picked.bookmarkData(
            options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults().set(bookmark, forKey: BackupDestination.defaultsKey)

        let leg = await Task.detached {
            StoreBackup.performSecondLeg(
                source: nil, directory: dir, configuration: .init(), defaults: defaults(),
                now: Date(), force: false,
                artifactConfiguration: GRDB.Configuration())
        }.value
        #expect(leg.outcome == .failed, "a due far folder handed no file is a failed leg")
        #expect(leg.detail == "This run made no snapshot to copy.",
                "the sentence blames THIS run — it never claims no snapshot exists")
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
    /// and pointed at *Encryption Explained* until 13s-b U1b retired the
    /// book with its pointer (R-13s-37).
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
        // 13s-b U1b (R-13s-37, a JUSTIFIED EDIT — the arm INVERTS): the
        // book is neither seeded nor restorable, so §8's pointer retired
        // with it; the floors above are byte-untouched.
        #expect(!runbook.contains("Encryption Explained"), "the retired pointer stays gone")
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

// MARK: - 18k C7 (W-3): the act's own file · the app's own names

/// **18k C7 — the second backup folder received the wrong file (the held walks' W-3).**
/// Every "newest copy" in `StoreBackup` was the `.last` of ONE listing that kept any
/// `variorum-backup-*.sqlite` name and sorted by NAME — so a foreign file whose name
/// merely starts the same way (the A1 rail's `variorum-backup-a1-…`, a July drill's
/// `variorum-backup-seed-drill-…`) sorted AFTER every dated copy (`2` < `a` < `s`) and
/// became "the newest": the copy sent to her second folder, the reason every hourly
/// check wrote again, and a slot the prune kept while it deleted real copies. These
/// pins stand one per reader; each names what reached where when it fails, so the
/// red run on the pre-fix tree IS the harness reproduction the brief asks for.
@Suite("The act's own file; the app's own names (18k C7 — W-3)")
struct BackupOwnFilesTests {
    /// The foreign names, verbatim: the dev walk's drill file, and the three A1-rail
    /// copies the orchestrator's read-only listing found in her REAL `Backups/`.
    static let drillName = "variorum-backup-seed-drill-2026-07-18T095149Z.sqlite"
    static let a1Names = [
        "variorum-backup-a1-bridge-retirement-2026-09-04T185230Z.sqlite",
        "variorum-backup-a1-pre13x-window-20260905T235821Z.sqlite",
        "variorum-backup-a1-13y-window-20260924T212417Z.sqlite",
    ]

    /// 2026-09-25 12:00:00 UTC — the act's clock.
    private let noon = ISO8601DateFormatter().date(from: "2026-09-25T12:00:00Z")!

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-18k-c7-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Never `.standard` (the dev store's own domain while the suite runs).
    private func scratchDefaults() -> @Sendable () -> UserDefaults {
        let suite = "variorum-18k-c7-tests-\(UUID().uuidString)"
        return { UserDefaults(suiteName: suite)! }
    }

    /// The app's real store shape since 13p: on disk and KEYED, so its snapshots are
    /// ciphertext — a plaintext stray then reads "file is not a database" at the far
    /// check exactly as W-3's pane said, and a same-key stray reads "ok".
    private func keyedStore(in dir: URL) throws -> AppDatabase {
        let db = try AppDatabase.onDisk(
            url: dir.appendingPathComponent("store.sqlite"), key: StoreKey.mint())
        try write("Words written before any stray copy existed.", into: db)
        return db
    }

    private func write(_ text: String, into db: AppDatabase) throws {
        try withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: text, profile: .journal)
            _ = try ops.newBlock(in: post.id, text: text)
        }
    }

    /// The app's own snapshot name for `date` (the writer's format, UTC).
    private func ownName(_ date: Date, fingerprint: String?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let suffix = fingerprint.map { "-" + StoreKeyEnvelope.shortFingerprint($0) } ?? ""
        return "\(StoreBackup.filePrefix)\(formatter.string(from: date))\(suffix).\(StoreBackup.fileExtension)"
    }

    /// A real snapshot the app itself would have written at `stamp`.
    private func snapshot(_ source: AppDatabase, in dir: URL, at stamp: Date) async throws -> URL {
        try #require(try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: dir, configuration: .init(), now: stamp, force: true)
        }.value)
    }

    /// The A1 rail's shape: the SAME library under the SAME key, taken earlier — a
    /// consistent stand-in for its byte copy of the closed store.
    private func a1Copy(of source: AppDatabase, at url: URL) async throws {
        try await Task.detached { try source.backup(to: url) }.value
    }

    /// The July drill's shape: a PLAINTEXT database.
    private func plaintextDrill(at url: URL) throws {
        let queue = try DatabaseQueue(path: url.path)
        try queue.write { try $0.execute(sql: "CREATE TABLE drill (x TEXT)") }
    }

    private func pickSecondFolder(_ picked: URL, in defaults: UserDefaults) throws {
        let bookmark = try picked.bookmarkData(
            options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
    }

    /// Every `.sqlite` name in a folder, foreign ones included (a raw listing — never
    /// the rule under test).
    private func sqliteNames(in dir: URL) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".sqlite") }
            .sorted()
    }

    private func run(
        _ source: AppDatabase, _ dir: URL, _ defaults: @escaping @Sendable () -> UserDefaults,
        at stamp: Date, force: Bool
    ) async -> BackupRunRecord {
        await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(),
                defaults: defaults(), now: stamp, force: force)
        }.value
    }

    /// The copy's own-file arm, over the two shapes that matter: the dev walk's
    /// (a plaintext drill + one A1 copy) and HERS (the three A1 copies alone — the
    /// silent case: same key, so the far check on a stale copy reads "ok").
    private func theSecondFolderReceivesTheActsOwnSnapshot(strays: [String]) async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        let picked = try temporaryDirectory()
        defer { for d in [storeDir, backups, picked] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let defaults = scratchDefaults()
        _ = try await snapshot(source, in: backups, at: noon.addingTimeInterval(-86_400))
        for name in strays {
            let url = backups.appendingPathComponent(name)
            if name == Self.drillName { try plaintextDrill(at: url) } else { try await a1Copy(of: source, at: url) }
        }
        // Written AFTER the strays were taken: only the act's own snapshot holds these.
        try write("Words written after every stray copy.", into: source)
        try pickSecondFolder(picked, in: defaults())

        // Back Up Now's shape (forced), at noon.
        let record = await run(source, backups, defaults, at: noon, force: true)

        #expect(record.primary.outcome == .written)
        let act = try #require(record.primary.file)
        let far = BackupDestination.backupsFolder(in: picked)
        #expect(sqliteNames(in: far) == [act],
                "the second folder received \(sqliteNames(in: far)), not the act's \(act)")
        #expect(record.secondary.file == act, "the log names what was sent")
        #expect(record.secondary.integrity == "ok",
                "the far check said “\(record.secondary.integrity ?? "nil")”")
        // `cmp`: byte-identical to the act's file beside the store.
        let farBytes = try? Data(contentsOf: far.appendingPathComponent(act))
        let actBytes = try Data(contentsOf: backups.appendingPathComponent(act))
        #expect(farBytes == actBytes, "the far copy is the act's file, byte for byte")
        // And it carries what only the act's snapshot holds. (Opened only when it
        // arrived — a DatabaseQueue on a missing path would CREATE an empty one.)
        let farURL = far.appendingPathComponent(act)
        if FileManager.default.fileExists(atPath: farURL.path) {
            let farCopy = try DatabaseQueue(path: farURL.path, configuration: source.artifactConfiguration())
            let newest = try farCopy.inDatabase { db in
                try Int.fetchOne(db, sql: "SELECT count(*) FROM variant WHERE working_text = ?",
                                 arguments: ["Words written after every stray copy."])
            }
            #expect(newest == 1, "the far copy holds the words written after the strays")
        }
        // THE FACE (her second folder's row): one copy, and its newest is this act.
        guard case .set(_, let summary) = DataSafetyModel.summarizeSecondDestination(in: defaults()) else {
            Issue.record("the second folder should read as set"); return
        }
        #expect(summary.count == 1, "the face counts \(summary.count) copies there")
        #expect(summary.newest == noon, "the face's Newest is \(String(describing: summary.newest))")
        // Nothing the app did not write ever travels.
        for name in strays { #expect(!sqliteNames(in: far).contains(name), "\(name) travelled") }
    }

    /// THE W-3 PIN, the dev walk's shape.
    @Test func theSecondFolderReceivesTheActsFileBesideADrillAndAnA1Copy() async throws {
        try await theSecondFolderReceivesTheActsOwnSnapshot(strays: [Self.drillName, Self.a1Names[1]])
    }

    /// THE W-3 PIN, HER real `Backups/` shape (the three A1 copies alone).
    @Test func theSecondFolderReceivesTheActsFileBesideHerThreeA1Copies() async throws {
        try await theSecondFolderReceivesTheActsOwnSnapshot(strays: Self.a1Names)
    }

    /// THE PASS-THROUGH'S OWN PIN: the copy is the file this act WROTE, never a
    /// re-discovered "newest" — even an own-pattern copy stamped after the act (a copy
    /// taken while the clock ran a day ahead) is not what the second folder gets.
    @Test func theCopyIsTheActsFileEvenBesideANewerStampedCopy() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        let picked = try temporaryDirectory()
        defer { for d in [storeDir, backups, picked] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let defaults = scratchDefaults()
        let ahead = try await snapshot(source, in: backups, at: noon.addingTimeInterval(86_400))
        try pickSecondFolder(picked, in: defaults())

        let record = await run(source, backups, defaults, at: noon, force: true)

        let act = try #require(record.primary.file)
        #expect(act != ahead.lastPathComponent)
        let far = BackupDestination.backupsFolder(in: picked)
        #expect(sqliteNames(in: far) == [act],
                "the second folder received \(sqliteNames(in: far)), not the act's \(act)")
        #expect(record.secondary.file == act)
    }

    /// THE PRIMARY DUE-CHECK: a foreign name is never "the newest copy", so an hourly
    /// check beside a fresh copy writes nothing (it wrote a new snapshot EVERY hour).
    @Test func aForeignNameNeverMakesTheHourlyCheckWriteAgain() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        defer { for d in [storeDir, backups] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let fresh = try await snapshot(source, in: backups, at: noon.addingTimeInterval(-3_600))
        for name in Self.a1Names {
            try Data("an A1-rail copy".utf8).write(to: backups.appendingPathComponent(name))
        }

        let record = await run(source, backups, scratchDefaults(), at: noon, force: false)

        #expect(record.primary.outcome == .upToDate,
                "an hour-old copy is fresh; the check \(record.primary.outcome) (\(record.primary.file ?? "-"))")
        #expect(sqliteNames(in: backups) == ([fresh.lastPathComponent] + Self.a1Names).sorted(),
                "the folder now holds \(sqliteNames(in: backups))")
    }

    /// THE PRIMARY PRUNE: fourteen REAL copies are kept, and a foreign name is neither
    /// counted nor ever deleted (the app did not write it; it is not the app's to prune).
    @Test func pruningKeepsFourteenRealCopiesAndNeverAForeignName() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        defer { for d in [storeDir, backups] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let fingerprint = source.storeKeyFingerprint
        let older = (1...14).map { ownName(noon.addingTimeInterval(Double(-$0) * 86_400), fingerprint: fingerprint) }
        for name in older { try Data("a day's copy".utf8).write(to: backups.appendingPathComponent(name)) }
        let foreign = Self.a1Names + [Self.drillName]
        for name in foreign { try Data("not the app's".utf8).write(to: backups.appendingPathComponent(name)) }

        let record = await run(source, backups, scratchDefaults(), at: noon, force: true)

        let act = try #require(record.primary.file)
        let names = sqliteNames(in: backups)
        let own = names.filter { !foreign.contains($0) }
        #expect(own.count == 14, "\(own.count) real copies kept (the keep is 14): \(own)")
        #expect(own.contains(act))
        #expect(!own.contains(older.last!), "the OLDEST real copy is the one pruned")
        for name in foreign { #expect(names.contains(name), "\(name) was pruned") }
    }

    /// THE SECOND FOLDER'S DUE-CHECK: a foreign file already in the second folder (her
    /// real one holds A1 copies sent there since early September) never makes every run
    /// copy again — the far folder's newest is its newest REAL copy.
    @Test func aForeignFileInTheSecondFolderNeverDefeatsItsDueCheck() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        let picked = try temporaryDirectory()
        defer { for d in [storeDir, backups, picked] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let defaults = scratchDefaults()
        let fresh = try await snapshot(source, in: backups, at: noon.addingTimeInterval(-3_600))
        let far = BackupDestination.backupsFolder(in: picked)
        try FileManager.default.createDirectory(at: far, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: fresh, to: far.appendingPathComponent(fresh.lastPathComponent))
        let stale = far.appendingPathComponent(Self.a1Names[1])
        try Data("the stale A1 copy sent here in September".utf8).write(to: stale)
        try pickSecondFolder(picked, in: defaults())

        let record = await run(source, backups, defaults, at: noon, force: false)

        #expect(record.secondary.outcome == .upToDate,
                "the second folder already holds an hour-old copy; the leg \(record.secondary.outcome)")
        #expect(record.secondary.file == fresh.lastPathComponent)
        #expect(try Data(contentsOf: stale) == Data("the stale A1 copy sent here in September".utf8),
                "and the foreign file is left exactly as it was")
    }

    /// THE RULE ITSELF: the app's own names are `variorum-backup-<stamp>[-<fp8>].sqlite`
    /// and nothing else — not an A1 or drill name, and not a foreign name that happens
    /// to START with a stamp. The last expectation is the Castle switch's delete offer,
    /// whose listing is this rule filtered by fingerprint (`PostureSwitch.Leaves.live`'s
    /// `pairs`): a foreign file is never "one of the app's own pre-switch copies".
    @Test func theListingIsTheAppsOwnNamesOnly() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let own = "variorum-backup-2026-09-25-120000-0123abcd.sqlite"
        let legacy = "variorum-backup-2026-09-25-110000.sqlite"
        let foreign = Self.a1Names + [
            Self.drillName,
            "variorum-backup-2026-09-25-130000-a1-window.sqlite",
            "variorum-backup-2026-09-25-140000-drill.sqlite",
        ]
        for name in [own, legacy] + foreign + [
            "variorum-backup-2026-09-25-120000-0123abcd.keys.json",
            "variorum-backup-2026-09-25-120000-0123abcd.sqlite-wal",
        ] {
            try Data("x".utf8).write(to: dir.appendingPathComponent(name))
        }

        let listed = try StoreBackup.existingBackups(in: dir).map(\.lastPathComponent)
        #expect(listed == [legacy, own], "the app's own copies, oldest first — listed \(listed)")
        let offered = try StoreBackup.existingBackups(in: dir)
            .filter { StoreBackup.shortFingerprint(fromBackupURL: $0) != "0123abcd" }
            .map(\.lastPathComponent)
        #expect(offered == [legacy], "the Castle offer would delete \(offered)")
    }

    /// THE FACE (a guard, and the record's HOLLOW verdict for the face as a defect): the
    /// Data Safety rows read the folder by DATE, so a foreign file was never their
    /// "Newest" — green on the pre-fix tree too. What the face showed wrong was the
    /// damage (a short reach, a stale far folder), never a foreign name.
    @Test func theFaceReadsByDateAndNeverNamedAForeignFile() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let earlier = noon.addingTimeInterval(-86_400)
        for name in [ownName(earlier, fingerprint: nil), ownName(noon, fingerprint: nil)]
            + Self.a1Names + [Self.drillName] {
            try Data("x".utf8).write(to: dir.appendingPathComponent(name))
        }
        let summary = DataSafetyModel.summarize(dir)
        #expect(summary.count == 2)
        #expect(summary.newest == noon)
        #expect(summary.oldest == earlier)
    }
}
