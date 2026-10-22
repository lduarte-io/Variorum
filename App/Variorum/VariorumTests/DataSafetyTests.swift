//
//  DataSafetyTests.swift
//  VariorumTests
//
//  Phase 13l, Act 4 (ledger rows 11–13) — the backup run, the run log, and the runbook.
//
//  VX-329 U1 — THE RELEASE SWITCH: the pair road is the backup run's writer (`StoreBackup.pairRoad` — R-U1-5). Today's
//  flat legs — the container's snapshot and its integrity check, the second folder's copy and its 14+4 retention, the
//  listings of the app's own flat names — were today's road's writers and were deleted with it, their suites with them
//  (the 14+4 rule, the integrity check, the far leg's sentences, 18k C7's own-files pins). What stands, pinned through a
//  SCRIPTED pair road (the road's own legs are `ProtectionBackupHookTests`'): the run reports the road's legs and its
//  log keeps the newest runs; the runbook rides beside the copies and is the repo's document; the run is single-flight.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// A pair road the pins script: each call recorded (force, now); answers `written` when forced or when `due` says so,
/// else `upToDate` (VX-329 U1: the run's writer, `StoreBackup.PairRoad`).
final class ScriptedPairRoad: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [(force: Bool, now: Date)] = []
    private let due: @Sendable (Int) -> Bool

    /// `due(n)`: whether the n-th call (from 0) finds a pair due when not forced.
    init(due: @escaping @Sendable (Int) -> Bool = { $0 == 0 }) { self.due = due }

    var calls: [(force: Bool, now: Date)] { lock.withLock { recorded } }

    var road: StoreBackup.PairRoad {
        { [self] force, now in
            let n = lock.withLock { () -> Int in
                recorded.append((force, now))
                return recorded.count - 1
            }
            var primary = BackupRunRecord.Leg(outcome: force || due(n) ? .written : .upToDate)
            if primary.outcome == .written { primary.file = "variorum-backup-\(n).sqlite" }
            return (primary, BackupRunRecord.Leg(outcome: .noDestination))
        }
    }
}

@Suite("The backup run — the pair road's legs, the log (13l row 11)")
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

    /// The run reports what its writer did — the pair road's two legs, the container's destination named — and, with
    /// no library open on a writing road (no writer), says so rather than staying silent.
    @Test func aRunReportsThePairRoadsLegsAndSaysSoWithNoWriter() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let road = ScriptedPairRoad()
        let pairRoad = road.road
        let record = await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(),
                defaults: defaults(), now: Date(timeIntervalSince1970: 1_782_900_000),
                force: false, pairRoad: pairRoad)
        }.value
        #expect(record.primary.outcome == .written)
        #expect(record.primary.destination == BackupDestination.displayPath(dir), "the container's folder, named")
        #expect(record.secondary.outcome == .noDestination, "no folder picked: SAID, not silently skipped")
        #expect(record.everythingWorked)
        #expect(road.calls.count == 1 && road.calls.first?.force == false)

        let none = await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(),
                defaults: defaults(), now: Date(timeIntervalSince1970: 1_782_900_000),
                force: true, pairRoad: nil)
        }.value
        #expect(none.primary.outcome == .noDestination, "no writer — the run says it had nowhere to copy")
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
                now: Date(timeIntervalSince1970: 1_782_900_000), force: false, pairRoad: nil)
        }.value
        let runbook = dir.appendingPathComponent(StoreBackup.runbookFilename)
        let text = try String(contentsOf: runbook, encoding: .utf8)
        #expect(text == DataSafetyCopy.runbook)
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
        let pairRoad = ScriptedPairRoad().road
        // Both runs in ONE detached task: the second is deliberately not due,
        // so the pair is "wrote / did not write" and the log holds both.
        await Task.detached {
            for stamp in [noon, noon.addingTimeInterval(3600)] {
                let record = StoreBackup.performRun(
                    database: source, directory: dir, configuration: .init(),
                    defaults: defaults(), now: stamp, force: false, pairRoad: pairRoad)
                BackupLog.append(record, to: defaults())
            }
        }.value
        let log = BackupLog.read(defaults())
        #expect(log.count == 2)
        #expect(log[0].primary.outcome == .upToDate, "the second run was not due")
        #expect(log[0].primary.integrity == nil, "nothing written, nothing to check")
        #expect(log[1].primary.outcome == .written)
    }

    /// Back Up Now's promise reaches the writer: a forced run hands `force` to the pair road, which writes whatever
    /// the interval says.
    @Test func forcingARunWritesEvenWhenNothingIsDue() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let noon = Date(timeIntervalSince1970: 1_782_900_000)
        let road = ScriptedPairRoad(due: { _ in false })
        let pairRoad = road.road
        let (due, forced) = await Task.detached {
            (StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(), defaults: defaults(),
                now: noon, force: false, pairRoad: pairRoad),
             StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(), defaults: defaults(),
                now: noon.addingTimeInterval(3600), force: true, pairRoad: pairRoad))
        }.value
        #expect(due.primary.outcome == .upToDate)
        #expect(forced.primary.outcome == .written, "Back Up Now must not be silently ignored")
        #expect(road.calls.map(\.force) == [false, true])
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
        // VX-329 U1: the posture cards §8 was composed from left with today's road; their two floors stand in the
        // runbook as the cards last said them (the runbook's rewrite to the pair road is hers — the U1 record's
        // F-U1-4), so the floors are pinned as they stand.
        #expect(runbook.contains("**Standard** — the floor: you lose your writing only if you lose every Apple device"))
        #expect(runbook.contains("**Castle** — the floor: lose every enrolled device and both your passphrase and your twelve"))
        #expect(runbook.contains("Nobody can help — not Apple, not us."), "Castle's floor, never softened")
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
        // One clock reading for both requests: the same second, by construction.
        let backup = StoreBackup(
            database: source, directory: dir, configuration: .init(),
            defaults: defaults, now: { noon })
        let road = ScriptedPairRoad()
        backup.pairRoad = road.road
        let first = Task { await backup.backUpNow() }
        let second = Task { await backup.backUpNow() }
        let (a, b) = (await first.value, await second.value)

        #expect(BackupLog.read(defaults()).count == 1, "ONE run for two requests")
        #expect(a == b, "the second request is handed the first run's outcome")
        #expect(a.primary.outcome == .written)
        #expect(b.primary.outcome != .failed, "never a false 'failed' for a copy that landed")
        #expect(backup.lastError == nil)
        #expect(road.calls.count == 1, "the writer ran once (VX-329 U1: the pair road; the flat leg's keep-1 prune is gone)")
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
        let backup = StoreBackup(
            database: source, directory: dir, configuration: .init(),
            defaults: defaults, now: { noon })
        // A pair from an hour ago stands: the due-check has nothing to do.
        backup.pairRoad = ScriptedPairRoad(due: { _ in false }).road
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
        backup.pairRoad = ScriptedPairRoad().road
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

// (VX-329 U1: 18k C7's own-files suite pinned today's flat listings — the second folder's copy, the hourly check's
// newest flat file, the 14-real-copies prune, the face's flat-file reading — deleted with the flat legs. The pair road's
// due-check reads the catalogue's pairs, never a folder's newest file — `OwnCopies.pairIsDue`, pinned in the core.)
