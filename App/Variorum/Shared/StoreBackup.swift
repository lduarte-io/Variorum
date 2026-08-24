//
//  StoreBackup.swift
//  Variorum (shared; wired on the Mac — the phone's store is re-derivable
//  from the mirror)
//
//  Phase 8, A1 — rotating cold copies (author decision 2026-07-06):
//  Supabase is a live MIRROR, not a backup — a destructive bug replicates
//  faithfully. These copies are the missing net: on launch and daily while
//  running, one consistent snapshot via SQLite's backup API (safe under
//  WAL), kept to a cap, pruned oldest-first. Restore stays manual — point
//  the recoverable-open path at a copy; the restore DRILL is Phase 12's.
//
//  Phase 13l, Act 4 (ledger row 11) — THE SECOND DESTINATION. A1's copies
//  live beside the store they copy: same disk, same container, so they
//  survive a destructive bug and a bad merge but not the disk. The gap the
//  13l brief names is exactly that — "the real gap is the second location,
//  not the mechanism" — so this class gained three things and no new
//  scheduler:
//    · a USER-PICKED folder (her ruling; `BackupDestination`) that receives
//      the same snapshot, keeps it on the 14-dailies-plus-4-weeklies rule
//      (`BackupRetention`), and is claimed per run rather than held;
//    · a per-run `PRAGMA integrity_check` on whatever was just written, at
//      BOTH destinations — Phase 8 pinned integrity in a test, which proves
//      the mechanism, not this morning's file;
//    · a RUN RECORD (`BackupRunRecord`/`BackupLog`), so the Data Safety face
//      can say what happened without asking anything to run — including for
//      a run that produced no file at all, which the files can never report.
//  The restore side is `notes/DataSafetyRunbook.md`, rehearsed end to end.
//

import Foundation
import GRDB  // the integrity check opens the COPY read-only, never migrating
import VariorumCore

@MainActor
final class StoreBackup {
    struct Configuration: Sendable {
        /// A new copy when the newest is older than this (launch + daily).
        var interval: TimeInterval = 24 * 60 * 60
        /// Copies kept; older ones pruned.
        var keep: Int = 14
        /// The picked folder's rule (13l): longer reach, fewer files.
        var secondPolicy: BackupRetention.Policy = .secondDestination
        /// The restore recipe dropped beside the copies, when the platform
        /// has one to give. A PARAMETER rather than a Shared constant: the
        /// text is entirely Mac-shaped (container paths, Finder steps), and
        /// `Shared/` means both platforms compile it — so the machinery is
        /// shared and the words are the caller's. nil = write nothing.
        var runbookText: String?
    }

    nonisolated static let filePrefix = "variorum-backup-"
    nonisolated static let fileExtension = "sqlite"
    /// The restore recipe's filename in a backup folder. Here rather than
    /// with the text, because the WRITER owns the file's name and the
    /// caller owns its words.
    nonisolated static let runbookFilename = "RESTORE.md"

    private let database: AppDatabase
    /// The in-container `Backups/` folder — internal so the Data Safety face
    /// can read its files directly (the freshness evidence that cannot lie).
    let directory: URL
    private let configuration: Configuration
    /// Injectable clock (tests) — the default is the wall clock.
    private let now: @Sendable () -> Date
    /// Injectable defaults (tests) — the destination bookmark and the log
    /// both live here, device-locally. A PROVIDER rather than the object:
    /// `UserDefaults` is not `Sendable`, and the run's work happens off-main,
    /// so the closure resolves it on the thread that uses it.
    private let defaults: @Sendable () -> UserDefaults
    private var timerTask: Task<Void, Never>?
    private(set) var lastError: String?
    /// The most recent run this process performed. `nil` until one runs —
    /// the face falls back to the persisted log, which survives relaunch.
    private(set) var lastRun: BackupRunRecord?

    init(
        database: AppDatabase,
        directory: URL,
        configuration: Configuration = Configuration(),
        defaults: @escaping @Sendable () -> UserDefaults = { .standard },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.database = database
        self.directory = directory
        self.configuration = configuration
        self.defaults = defaults
        self.now = now
    }

    /// Launch + daily while running: one due-check now, then hourly
    /// re-checks (cheap directory stat; the interval decides if a copy is
    /// actually written).
    func start(recheckEvery recheck: Duration = .seconds(60 * 60)) {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                _ = await self?.backupIfDue()
                do { try await Task.sleep(for: recheck) } catch { return }
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    /// Writes a copy when the newest existing one is older than the
    /// interval (or none exists), then mirrors it to the picked folder.
    /// Off the main thread (P2).
    @discardableResult
    func backupIfDue() async -> BackupRunRecord {
        await run(force: false)
    }

    /// "Back Up Now…" — the ADJUNCT door (the recorded lean: welcome on top
    /// of the automatic job, never the load-bearing mechanism). Forces a
    /// fresh snapshot at both destinations regardless of the interval.
    @discardableResult
    func backUpNow() async -> BackupRunRecord {
        await run(force: true)
    }

    private func run(force: Bool) async -> BackupRunRecord {
        let database = database
        let directory = directory
        let configuration = configuration
        let defaults = defaults
        let stamp = now()
        let record = await Task.detached(priority: .utility) {
            let store = defaults()
            let record = StoreBackup.performRun(
                database: database, directory: directory,
                configuration: configuration, defaults: store,
                now: stamp, force: force)
            BackupLog.append(record, to: store)
            return record
        }.value
        lastRun = record
        // A failed backup must never take the app down — surfaced, retried
        // on the next check. `lastError` keeps its Phase 8 meaning (the
        // primary destination's failure, which is the one that means the
        // mechanism is broken rather than the folder unreachable).
        lastError = record.primary.outcome == .failed ? record.primary.detail : nil
        return record
    }

    // MARK: - The run (13l): both destinations, integrity, retention

    /// ONE run, both destinations, never throwing — a run reports what
    /// happened; it does not fail the app. Static + nonisolated so tests
    /// drive it deterministically, off-main by contract like its Phase 8
    /// sibling below.
    ///
    /// The second destination receives a COPY OF THE PRIMARY FILE rather
    /// than a second `backup(to:)`. Deliberate, and it is the difference
    /// between "two backups" and "one backup in two places": a second
    /// snapshot would be taken at a different instant, so the two folders
    /// would hold different states and neither would be the one the log
    /// names. Copying guarantees byte-identity, and it is also what makes
    /// the integrity check on the far copy meaningful — it is checking the
    /// TRANSFER, which is the part that can go wrong on an external volume
    /// or a cloud-synced folder.
    nonisolated static func performRun(
        database: AppDatabase, directory: URL, configuration: Configuration,
        defaults: UserDefaults, now: Date, force: Bool
    ) -> BackupRunRecord {
        dispatchPrecondition(condition: .notOnQueue(.main))
        var primary = BackupRunRecord.Leg(outcome: .upToDate)
        primary.destination = BackupDestination.displayPath(directory)
        do {
            let written = try performBackupIfDue(
                database: database, directory: directory,
                configuration: configuration, now: now, force: force)
            if let written {
                primary.outcome = .written
                primary.file = written.lastPathComponent
                primary.integrity = integrityCheck(of: written)
            }
        } catch {
            primary.outcome = .failed
            primary.detail = String(describing: error)
        }

        // The recipe rides beside the copies it is about (13l row 13). The
        // moment a restore recipe gets read is the moment the app may not
        // open, so a copy that lives only inside the app is not a runbook.
        writeRunbook(configuration.runbookText, into: directory)

        let secondary = performSecondLeg(
            directory: directory, configuration: configuration,
            defaults: defaults, now: now, force: force)
        return BackupRunRecord(at: now, primary: primary, secondary: secondary)
    }

    /// Drops `RESTORE.md` into a folder, only when its bytes would change —
    /// a picked folder may be cloud-synced, and rewriting an identical file
    /// every hour would be upload churn for nothing.
    nonisolated static func writeRunbook(_ text: String?, into folder: URL) {
        guard let text else { return }
        let url = folder.appendingPathComponent(runbookFilename)
        if let existing = try? String(contentsOf: url, encoding: .utf8), existing == text {
            return
        }
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    /// The picked folder's half. Never throws for the same reason: an
    /// unplugged drive is a thing to SAY, not a thing to crash on.
    nonisolated static func performSecondLeg(
        directory: URL, configuration: Configuration,
        defaults: UserDefaults, now: Date, force: Bool
    ) -> BackupRunRecord.Leg {
        var leg = BackupRunRecord.Leg(outcome: .noDestination)
        guard BackupDestination.isSet(in: defaults) else { return leg }
        guard let resolved = BackupDestination.resolve(in: defaults) else {
            leg.outcome = .failed
            leg.detail = "The backup folder can't be found — it may have moved, "
                + "been renamed, or be on a disconnected drive. Pick it again."
            return leg
        }
        let target = BackupDestination.backupsFolder(in: resolved.picked)
        leg.destination = BackupDestination.displayPath(target)
        do {
            try BackupDestination.withAccess(to: resolved.picked) {
                try FileManager.default.createDirectory(
                    at: target, withIntermediateDirectories: true)
                // One step up from the snapshots — the folder she actually
                // opens when she goes looking.
                writeRunbook(
                    configuration.runbookText,
                    into: BackupDestination.variorumFolder(in: resolved.picked))
                // Due-ness is the FAR folder's own question: picking a folder
                // today must seed it immediately even though the container's
                // copy is hours old, and a run that copied yesterday must not
                // copy again this afternoon.
                let existing = try existingBackups(in: target)
                if !force, let newest = existing.last,
                   let newestDate = date(fromBackupURL: newest),
                   now.timeIntervalSince(newestDate) < configuration.interval {
                    leg.outcome = .upToDate
                    leg.file = newest.lastPathComponent
                    return
                }
                guard let source = try existingBackups(in: directory).last else {
                    leg.outcome = .failed
                    leg.detail = "There is no snapshot to copy yet."
                    return
                }
                let destination = target.appendingPathComponent(source.lastPathComponent)
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: source, to: destination)
                leg.outcome = .written
                leg.file = destination.lastPathComponent
                leg.integrity = integrityCheck(of: destination)
                leg.pruned = try pruneSecond(
                    in: target, policy: configuration.secondPolicy)
            }
        } catch {
            leg.outcome = .failed
            leg.detail = String(describing: error)
        }
        return leg
    }

    /// The 14+4 sweep. The RULE is `BackupRetention` (pure, tested); this is
    /// only the filesystem half.
    nonisolated static func pruneSecond(
        in directory: URL, policy: BackupRetention.Policy
    ) throws -> Int {
        let candidates = try existingBackups(in: directory).compactMap { url in
            date(fromBackupURL: url).map { BackupRetention.Candidate(url: url, date: $0) }
        }
        let doomed = BackupRetention.prune(candidates, policy: policy)
        for url in doomed { try FileManager.default.removeItem(at: url) }
        return doomed.count
    }

    /// `PRAGMA integrity_check` on a copy just written, plus the one step
    /// that makes the copy genuinely self-contained. Returns SQLite's own
    /// answer, or the reason it could not be asked; never throws, and never
    /// runs the MIGRATOR against the artifact (which is why this opens a bare
    /// `DatabaseQueue` rather than going through `AppDatabase.openStore`).
    ///
    /// **Why it does not simply open read-only, which is what it did first.**
    /// SQLite's backup API copies the source's header, so a copy of a
    /// WAL-mode store is itself flagged WAL — and a READ-ONLY open of a
    /// WAL database needs a `-shm` file it is not allowed to create, so it
    /// fails outright: *"SQLite error 14: unable to open database file"*.
    /// Every real backup copy is that shape. Caught by this method's own test
    /// during the 13l drill, before it had run on a real folder once; the
    /// read-only version would have reported a failure on every copy the app
    /// ever made.
    ///
    /// So the copy is opened read-write and moved to `journal_mode = DELETE`
    /// FIRST. That is not a workaround, it is the artifact getting the
    /// property the runbook already promises it has: after this, the `.sqlite`
    /// file is the whole snapshot, it needs no companion files, and anything
    /// — including a read-only tool on a locked volume — can open it. The
    /// fallback below covers a copy that genuinely cannot be written (a
    /// read-only destination): the check still runs, on whatever terms the
    /// file allows.
    nonisolated static func integrityCheck(of url: URL) -> String {
        do {
            let answer: (mode: String?, integrity: String)
            do {
                let queue = try DatabaseQueue(path: url.path)
                answer = try queue.inDatabase { db in
                    // Checkpoints and removes the -wal, then leaves the file
                    // in a journal mode a read-only open can always handle.
                    let mode = try String.fetchOne(db, sql: "PRAGMA journal_mode = DELETE")
                    let integrity = try String.fetchOne(db, sql: "PRAGMA integrity_check")
                    return (mode, integrity ?? "no answer")
                }
            }
            // The connection is closed by here. Leaving WAL usually takes the
            // sidecars with it, but the `-shm` has been observed to survive
            // (measured, 13l Act 4) — and a stray sidecar beside a snapshot is
            // exactly what makes a hand-copied restore dangerous. Once the
            // file is out of WAL they carry nothing, so they go.
            if answer.mode?.lowercased() != "wal" {
                for suffix in ["-wal", "-shm"] {
                    try? FileManager.default.removeItem(
                        at: URL(fileURLWithPath: url.path + suffix))
                }
            }
            return answer.integrity
        } catch {
            do {
                var config = GRDB.Configuration()
                config.readonly = true
                let queue = try DatabaseQueue(path: url.path, configuration: config)
                return try queue.read { db in
                    try String.fetchOne(db, sql: "PRAGMA integrity_check") ?? "no answer"
                }
            } catch {
                return "could not be checked: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - The blocking worker (off-main by contract)

    /// Returns the new copy's URL, or nil when the newest copy is fresh
    /// enough. Static + nonisolated so tests drive it deterministically.
    @discardableResult
    nonisolated static func performBackupIfDue(
        database: AppDatabase, directory: URL,
        configuration: Configuration, now: Date, force: Bool = false
    ) throws -> URL? {
        dispatchPrecondition(condition: .notOnQueue(.main))
        if !force, let newest = try existingBackups(in: directory).last,
           let newestDate = date(fromBackupURL: newest),
           now.timeIntervalSince(newestDate) < configuration.interval {
            return nil
        }
        let url = directory.appendingPathComponent(
            "\(filePrefix)\(stampFormatter.string(from: now)).\(fileExtension)")
        try database.backup(to: url)
        try prune(directory: directory, keep: configuration.keep)
        return url
    }

    /// Oldest-first pruning down to `keep` (names sort chronologically —
    /// the stamp format is lexicographic).
    nonisolated static func prune(directory: URL, keep: Int) throws {
        let backups = try existingBackups(in: directory)
        guard backups.count > keep else { return }
        for url in backups.dropLast(keep) {
            try FileManager.default.removeItem(at: url)
        }
    }

    /// This directory's backup files, oldest first.
    nonisolated static func existingBackups(in directory: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter {
                $0.lastPathComponent.hasPrefix(filePrefix)
                    && $0.pathExtension == fileExtension
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    nonisolated static func date(fromBackupURL url: URL) -> Date? {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix(filePrefix) else { return nil }
        return stampFormatter.date(from: String(name.dropFirst(filePrefix.count)))
    }

    /// Filename-safe, lexicographically chronological. (DateFormatter is
    /// documented thread-safe for formatting on modern OS versions.)
    nonisolated private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
