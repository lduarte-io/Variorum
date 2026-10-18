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
//  Phase 13l, Act 5 (ledger row 16) — a THIRD leg: the plain-text
//  insurance (`MarkdownInsurance`), on its own weekly due-ness, into the
//  picked folder's `md-exports/`. It rides this run rather than minting a
//  second clock, so there is one tick, one record, and one face. The unit
//  itself lives in its own file on purpose — see its header.
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
        /// 13l Act 5 (row 16): the plain-text insurance's cadence and
        /// retention — PROVISIONAL (weekly, keep 4; QUESTIONS #75).
        var markdownInsurance: MarkdownInsurance.Policy = .standard
        /// The restore recipe dropped beside the copies, when the platform
        /// has one to give. A PARAMETER rather than a Shared constant: the
        /// text is entirely Mac-shaped (container paths, Finder steps), and
        /// `Shared/` means both platforms compile it — so the machinery is
        /// shared and the words are the caller's. nil = write nothing.
        var runbookText: String?
        /// Phase 13p Batch 2: the store-key ENVELOPE (the wrapped-copies
        /// key file beside the store) rides into every backup folder — a
        /// ciphertext backup restored on a NEW machine is unopenable
        /// without it, so "restore via passphrase / recovery phrase" is
        /// true only if the wraps travel with the copies. Every byte in
        /// the file is non-secret by design (wrapped blobs, salts, an
        /// id), so a cloud-synced folder may hold it. pre-13x 1a: this is
        /// the STORE's URL — the run locates the store's CURRENT key file
        /// beside it at run time (`StoreKeyEnvelope.locate`; the name
        /// carries the key's fingerprint and may change at a re-key). nil
        /// = no store to look beside.
        var keyEnvelopeStoreURL: URL?
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
    /// pre-13x 5b (ledger 64): told after EVERY run, on the main actor —
    /// the iCloud Drive offer's trigger ("at the first backup run"). A
    /// caller that attaches after a run already landed reads `lastRun`.
    var onRun: (@MainActor (BackupRunRecord) -> Void)?

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

    /// **18k C5 (17e P38) — ONE RUN AT A TIME.** A snapshot's name is
    /// second-granular, so two runs in one second wrote the SAME path, raced
    /// `integrityCheck`'s sidecar deletion and both `prune`d one doomed set
    /// (the loser's `removeItem` surfacing as a false `failed`). Several
    /// doors reach `run` with no latch they share — the hourly tick, Back Up
    /// Now, the insurance toggle, the iCloud offer, the posture switch — so
    /// the latch lives HERE, where they all meet. `id` lets a finished run
    /// clear only its own slot.
    private var inFlight: (id: Int, task: Task<BackupRunRecord, Never>, forced: Bool)?
    private var runSerial = 0

    /// The single-flight door. A request while a run is in flight is handed
    /// THAT run's outcome — never a parallel run — whenever that run does at
    /// least what the request asks: any request behind a forced run, and a
    /// due-check behind anything. The one exception is Back Up Now's own
    /// promise ("a fresh snapshot regardless of the interval", above): a
    /// FORCED request behind a due-check that may find nothing due waits for
    /// it and then runs its own, so it is never answered "already up to date"
    /// — still one run at a time, one after the other.
    private func run(force: Bool) async -> BackupRunRecord {
        if let current = inFlight, current.forced || !force {
            return await current.task.value
        }
        let behind = inFlight?.task
        runSerial += 1
        let id = runSerial
        let task = Task { @MainActor in
            _ = await behind?.value
            let record = await performOneRun(force: force)
            if inFlight?.id == id { inFlight = nil }
            return record
        }
        inFlight = (id, task, force)
        return await task.value
    }

    /// One run, start to finish — the pre-18k `run(force:)` body, byte-
    /// unchanged but for its name: only `run` above may call it.
    private func performOneRun(force: Bool) async -> BackupRunRecord {
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
        onRun?(record)
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
    ///
    /// **18k C7 (W-3): the copy is THIS ACT'S snapshot, handed through** — the
    /// file the primary leg just wrote, or the fresh one its due-check stood on
    /// — never re-discovered by listing the folder. Before, the second leg took
    /// the folder listing's last NAME, which any stray `variorum-backup-*` file
    /// could be: her second folder was sent a July drill file on the dev store,
    /// and (by the same rule) an A1-rail safety copy from 5 September on hers.
    nonisolated static func performRun(
        database: AppDatabase, directory: URL, configuration: Configuration,
        defaults: UserDefaults, now: Date, force: Bool
    ) -> BackupRunRecord {
        dispatchPrecondition(condition: .notOnQueue(.main))
        // Phase 13p: a keyed store's backups are ciphertext under the same
        // key, so every artifact open below carries the store's own keyed
        // configuration (an unkeyed open of a ciphertext copy would report
        // "could not be checked" on every copy the app ever makes).
        let artifactConfiguration = database.artifactConfiguration()
        var primary = BackupRunRecord.Leg(outcome: .upToDate)
        primary.destination = BackupDestination.displayPath(directory)
        // pre-13x 2a (row 7): the lock-time copies made keyless are checked
        // NOW, with the key in hand — "checked the next time you unlock".
        let lockTimeChecks = checkPendingLockTimeCopies(
            in: directory, defaults: defaults, using: artifactConfiguration)
        // 18k C7: the snapshot this act stands on — handed to the second leg.
        var standing: URL?
        do {
            switch try performPrimaryLeg(
                database: database, directory: directory,
                configuration: configuration, now: now, force: force) {
            case .written(let written):
                primary.outcome = .written
                primary.file = written.lastPathComponent
                primary.integrity = integrityCheck(of: written, using: artifactConfiguration)
                standing = written
            case .fresh(let fresh):
                standing = fresh
            }
        } catch {
            primary.outcome = .failed
            primary.detail = String(describing: error)
        }
        if !lockTimeChecks.isEmpty {
            primary.detail = ([primary.detail].compactMap { $0 } + lockTimeChecks)
                .joined(separator: " · ")
        }

        // The recipe rides beside the copies it is about (13l row 13). The
        // moment a restore recipe gets read is the moment the app may not
        // open, so a copy that lives only inside the app is not a runbook.
        writeRunbook(configuration.runbookText, into: directory)
        // 13p: the recovery legs ride beside the recipe (see Configuration).
        // pre-13x 1a: the CURRENT key file, located beside the store per run.
        let keyFile = configuration.keyEnvelopeStoreURL
            .flatMap { StoreKeyEnvelope.locate(besideStore: $0) }
        copyKeyEnvelope(keyFile, into: directory)

        let secondary = performSecondLeg(
            source: standing, directory: directory, configuration: configuration,
            defaults: defaults, now: now, force: force,
            artifactConfiguration: artifactConfiguration)

        // 13l Act 5 (row 16): the plain-text insurance rides this run rather
        // than minting a second clock — one hourly tick, one record, one
        // log, one face. Its DUE-NESS is its own (weekly), so on six days
        // out of seven this costs a directory listing. It runs LAST because
        // it is the heaviest leg and the least urgent: the snapshots are the
        // restore road, and this is the "even if SQLite itself is the
        // problem" net beside them.
        let markdown = MarkdownInsurance.performRun(
            database: database, defaults: defaults,
            policy: configuration.markdownInsurance, now: now, force: force)
        return BackupRunRecord(
            at: now, primary: primary, secondary: secondary, markdown: markdown)
    }

    /// Phase 13p Batch 2 → pre-13x 1a: copy the store's key file into a
    /// backup folder, under the SOURCE'S OWN NAME (`variorum-keys-<fp>.json`
    /// — one per library key the folder has ever held; the legacy
    /// `variorum-keys.json` serves legacy snapshots), and ONLY WHEN ABSENT.
    /// A backup folder's key file is NEVER rewritten after it is written
    /// (the design's decision 11 / §6: not at a passphrase change, a words
    /// regeneration or a posture change — a snapshot opens with the
    /// passphrase its folder's key file was written under, or the twelve
    /// words, or the master copy); two keys' files coexist by name, so no
    /// key's file ever overwrites another's. (13p wrote-when-bytes-changed;
    /// that refresh is exactly the rewrite the design forbids.) Quiet on
    /// failure like every leg-side write — the next run retries; the
    /// snapshots themselves never depend on it.
    nonisolated static func copyKeyEnvelope(_ source: URL?, into folder: URL) {
        guard let source,
              let bytes = try? Data(contentsOf: source) else { return }
        let destination = folder.appendingPathComponent(source.lastPathComponent)
        guard !FileManager.default.fileExists(atPath: destination.path) else { return }
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        try? bytes.write(to: destination, options: .atomic)
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
    /// `artifactConfiguration` keys the far copy's integrity check exactly
    /// as the primary's (13p — the copies are ciphertext now), and it is
    /// REQUIRED (ladder R1-m5): a defaulted plain configuration re-opened,
    /// one level up, the exact door `integrityCheck`'s required parameter
    /// closed — a future caller quietly checking ciphertext copies with a
    /// plain connection and reporting every one "could not be checked".
    ///
    /// `source` is the act's own snapshot (18k C7) — REQUIRED, the R1-m5 shape
    /// again: a caller must hand the file it means, never let this leg find one.
    /// nil (the primary leg failed, so this act has no snapshot) copies nothing.
    nonisolated static func performSecondLeg(
        source: URL?, directory: URL, configuration: Configuration,
        defaults: UserDefaults, now: Date, force: Bool,
        artifactConfiguration: GRDB.Configuration
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
                // 13p: the far folder gets the recovery legs too — this is
                // the copy a NEW machine restores from (pre-13x 1a: the
                // current key file, located per run; never rewritten).
                copyKeyEnvelope(
                    configuration.keyEnvelopeStoreURL
                        .flatMap { StoreKeyEnvelope.locate(besideStore: $0) },
                    into: BackupDestination.variorumFolder(in: resolved.picked))
                // Due-ness is the FAR folder's own question: picking a folder
                // today must seed it immediately even though the container's
                // copy is hours old, and a run that copied yesterday must not
                // copy again this afternoon.
                // 18o U1 (row 84): the newest copy stamped no later than
                // now — a future stamp is not evidence of freshness.
                if !force, let newest = try newestTrustedBackup(in: target, now: now),
                   now.timeIntervalSince(newest.date) < configuration.interval {
                    leg.outcome = .upToDate
                    leg.file = newest.url.lastPathComponent
                    return
                }
                guard let source else {
                    leg.outcome = .failed
                    // 18k ladder round 1 (NIT 1; PROVISIONAL — QUESTIONS
                    // #148): THIS RUN made no snapshot (the primary leg
                    // failed), so there is nothing of this act's to hand
                    // through. The old sentence ("There is no snapshot to
                    // copy yet.") claimed none EXISTED — false whenever
                    // older copies sit beside the library.
                    leg.detail = "This run made no snapshot to copy."
                    return
                }
                let destination = target.appendingPathComponent(source.lastPathComponent)
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: source, to: destination)
                // VX-338: this Mac wrote this copy — on its own list, so its own
                // retention may one day prune it, and no other Mac's can be.
                recordOwnFarSnapshot(destination.lastPathComponent, in: defaults)
                // pre-13x 2a (row 42): the pair travels with its snapshot —
                // written once beside the far copy, never rewritten.
                let sourcePair = pairedKeyFile(for: source)
                let farPair = pairedKeyFile(for: destination)
                if FileManager.default.fileExists(atPath: sourcePair.path),
                   !FileManager.default.fileExists(atPath: farPair.path) {
                    try? FileManager.default.copyItem(at: sourcePair, to: farPair)
                }
                leg.outcome = .written
                leg.file = destination.lastPathComponent
                leg.integrity = integrityCheck(of: destination, using: artifactConfiguration)
                leg.pruned = try pruneSecond(
                    in: target, policy: configuration.secondPolicy, defaults: defaults)
            }
        } catch {
            leg.outcome = .failed
            leg.detail = String(describing: error)
        }
        return leg
    }

    /// The 14+4 sweep — over THIS MAC'S OWN copies only (VX-338). The RULE
    /// is `BackupRetention` (pure, tested); this is only the filesystem half.
    ///
    /// **VX-338 (her ruling 2026-10-14, VX-266 design §9 call 4 — "yeah we
    /// can do the small bug fix"): two Macs sharing a picked folder pruned
    /// each other's backups.** The iCloud Drive offer opens at iCloud Drive's
    /// root, so her Pro and her Air, both accepting it, write into one
    /// `<pick>/Variorum/Backups/`; this sweep counted EVERY app-named snapshot
    /// there, whichever Mac wrote it, and the 14+4 rule (newest per day wins)
    /// deleted the other Mac's copies on each run. Now a snapshot counts — and
    /// can be deleted — only when it is on THIS Mac's own list
    /// (`ownFarSnapshots`: the names this Mac copied into the picked folder,
    /// device-local). Another Mac's copy is never on it, so it is never
    /// counted against this Mac's rule and never deleted; nor is any copy
    /// written before this fix (no Mac's list holds it) — an existing shared
    /// folder is never cleaned up by deletion. The list is reconciled here:
    /// a name whose file is gone (deleted by hand, or by an older build on the
    /// other Mac) leaves it, so it stays bounded by the rule's 18.
    nonisolated static func pruneSecond(
        in directory: URL, policy: BackupRetention.Policy, defaults: UserDefaults
    ) throws -> Int {
        let candidates = try existingBackups(in: directory).compactMap { url in
            date(fromBackupURL: url).map { BackupRetention.Candidate(url: url, date: $0) }
        }
        let own = ownFarSnapshots(in: defaults)
        var stillOwn = own.intersection(candidates.map(\.url.lastPathComponent))
        // Whatever happens below, the list keeps exactly the own copies left.
        defer { setOwnFarSnapshots(stillOwn, in: defaults) }
        let doomed = BackupRetention.prune(candidates, policy: policy, ownedBy: own)
        for url in doomed {
            try removeSnapshotPair(url)
            stillOwn.remove(url.lastPathComponent)
        }
        return doomed.count
    }

    // MARK: - This Mac's own copies in the picked folder (VX-338)

    /// The names of the snapshots THIS Mac copied into the picked folder —
    /// device-local (`UserDefaults`, like the folder's bookmark and the log:
    /// never synced, never written into the folder), so another Mac sharing
    /// the folder holds its own list and never this one. Names, not paths:
    /// a snapshot's name IS its identity (stamp + key fingerprint), and a
    /// folder she moves keeps its copies' names.
    nonisolated static let ownFarSnapshotsKey = "variorum.backup.ownFarSnapshots"

    nonisolated static func ownFarSnapshots(in defaults: UserDefaults) -> Set<String> {
        Set(defaults.stringArray(forKey: ownFarSnapshotsKey) ?? [])
    }

    nonisolated static func recordOwnFarSnapshot(_ name: String, in defaults: UserDefaults) {
        var own = ownFarSnapshots(in: defaults)
        own.insert(name)
        setOwnFarSnapshots(own, in: defaults)
    }

    nonisolated private static func setOwnFarSnapshots(_ names: Set<String>, in defaults: UserDefaults) {
        defaults.set(names.sorted(), forKey: ownFarSnapshotsKey)
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
    /// Phase 13p: `using` is the SOURCE STORE's artifact configuration
    /// (`AppDatabase.artifactConfiguration()`) — a keyed store's copies are
    /// ciphertext and can only be opened with the same key. REQUIRED at the
    /// call site so no future caller quietly checks a ciphertext copy with
    /// a plaintext connection and reports every backup as uncheckable. For
    /// a plaintext-era store the configuration is plain and behavior is
    /// exactly what it was.
    nonisolated static func integrityCheck(
        of url: URL, using configuration: GRDB.Configuration
    ) -> String {
        do {
            let answer: (mode: String?, integrity: String)
            do {
                let queue = try DatabaseQueue(path: url.path, configuration: configuration)
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
                var config = configuration
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
        if case .written(let url) = try performPrimaryLeg(
            database: database, directory: directory,
            configuration: configuration, now: now, force: force) {
            return url
        }
        return nil
    }

    /// What the primary leg did, naming the snapshot either way (18k C7): the
    /// one it WROTE, or the newest one its due-check found fresh — the file this
    /// act stands on, which `performRun` hands to the second leg.
    nonisolated enum PrimarySnapshot: Equatable, Sendable {
        case written(URL)
        case fresh(URL)
    }

    /// The primary leg: a new snapshot when the newest of the app's own is
    /// older than the interval (or none exists, or `force`), else the fresh one.
    nonisolated static func performPrimaryLeg(
        database: AppDatabase, directory: URL,
        configuration: Configuration, now: Date, force: Bool
    ) throws -> PrimarySnapshot {
        dispatchPrecondition(condition: .notOnQueue(.main))
        // 18o U1 (row 84): the newest copy stamped no later than now — a
        // future stamp is not evidence of freshness (`newestTrustedBackup`).
        if !force, let newest = try newestTrustedBackup(in: directory, now: now),
           now.timeIntervalSince(newest.date) < configuration.interval {
            return .fresh(newest.url)
        }
        // pre-13x 1a (§6): a keyed store's snapshot carries its key's short
        // fingerprint — `variorum-backup-<stamp>-<fp8>.sqlite` — so a folder
        // holding several keys' snapshots says which key file opens which.
        let fingerprintSuffix = database.storeKeyFingerprint
            .map { "-" + StoreKeyEnvelope.shortFingerprint($0) } ?? ""
        let url = directory.appendingPathComponent(
            "\(filePrefix)\(stampFormatter.string(from: now))\(fingerprintSuffix).\(fileExtension)")
        try database.backup(to: url)
        // pre-13x 2a (row 42 — decision 11 as ruled): EVERY SNAPSHOT has
        // its own key file, written with it and never rewritten — the live
        // key file's bytes of this moment, under the snapshot's name.
        writeSnapshotKeyFile(
            for: url,
            from: configuration.keyEnvelopeStoreURL
                .flatMap { StoreKeyEnvelope.locate(besideStore: $0) })
        try prune(directory: directory, keep: configuration.keep)
        return .written(url)
    }

    // MARK: - Snapshot pairs (pre-13x 2a, row 42)

    /// `variorum-backup-<stamp>-<fp8>.keys.json` — the snapshot's OWN key
    /// file, beside it.
    nonisolated static func pairedKeyFile(for snapshot: URL) -> URL {
        snapshot.deletingPathExtension().appendingPathExtension("keys.json")
    }

    /// The live key file's bytes, copied beside a snapshot as its pair —
    /// ONLY WHEN ABSENT (a pair is written with its snapshot and NEVER
    /// rewritten: a passphrase change between two snapshots leaves the
    /// earlier pair byte-identical and the later pair under the new word).
    /// Quiet on failure like every leg-side write; the folder file
    /// (`copyKeyEnvelope`) and the master copy still serve the snapshot.
    nonisolated static func writeSnapshotKeyFile(for snapshot: URL, from liveKeyFile: URL?) {
        guard let liveKeyFile, let bytes = try? Data(contentsOf: liveKeyFile) else { return }
        let pair = pairedKeyFile(for: snapshot)
        guard !FileManager.default.fileExists(atPath: pair.path) else { return }
        try? bytes.write(to: pair, options: .atomic)
    }

    /// Remove a snapshot AND its pair (the pair goes with its snapshot;
    /// a 1a-era snapshot has no pair — nothing extra to remove).
    nonisolated static func removeSnapshotPair(_ snapshot: URL) throws {
        try FileManager.default.removeItem(at: snapshot)
        let pair = pairedKeyFile(for: snapshot)
        if FileManager.default.fileExists(atPath: pair.path) {
            try FileManager.default.removeItem(at: pair)
        }
    }

    /// Oldest-first pruning down to `keep` — over the app's OWN snapshots only
    /// (`existingBackups`, 18k C7): a foreign file is never counted against the
    /// keep and never deleted. Pairs go with their snapshots.
    nonisolated static func prune(directory: URL, keep: Int) throws {
        let backups = try existingBackups(in: directory)
        guard backups.count > keep else { return }
        for url in backups.dropLast(keep) {
            try removeSnapshotPair(url)
        }
    }

    // MARK: - The keyless byte-copy at lock time (pre-13x 2a, row 7)

    /// The lock-time copies awaiting their integrity check ("checked the
    /// next time you unlock" — copy §6): filenames, device-local.
    nonisolated static let pendingLockTimeChecksKey = "variorum.backup.pendingLockTimeChecks"

    /// **A keyless byte-copy of the CLOSED library when a backup is due**
    /// (decision 18; the app's own folder only). Runs AFTER the pool closed
    /// and the key dropped — no key opens the file here, so the copy is
    /// plain `Data`, ciphertext as it sits on disk; its pair rides beside
    /// it. A library whose `-wal` still holds frames (an unclean close) is
    /// NOT copied — a byte-copy of a half-checkpointed store would open
    /// inconsistent; the next unlock's keyed run takes the snapshot
    /// instead. Returns the copy's URL, or nil (not due · no key file · a
    /// live WAL · a write failure). Never throws.
    @discardableResult
    nonisolated static func performLockTimeCopyIfDue(
        storeURL: URL, directory: URL, interval: TimeInterval,
        defaults: UserDefaults, now: Date
    ) -> URL? {
        guard StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown else { return nil }
        // 18o U1 (row 84): the same trusted-newest rule as the keyed legs.
        if let newest = try? newestTrustedBackup(in: directory, now: now),
           now.timeIntervalSince(newest.date) < interval {
            return nil
        }
        let wal = URL(fileURLWithPath: storeURL.path + "-wal")
        if let size = try? FileManager.default.attributesOfItem(atPath: wal.path)[.size] as? Int,
           size > 0 {
            return nil
        }
        guard let keyFileURL = StoreKeyEnvelope.locate(besideStore: storeURL),
              let envelope = try? StoreKeyEnvelope.load(at: keyFileURL),
              let fingerprint = envelope.keyFingerprint,
              let bytes = try? Data(contentsOf: storeURL)
        else { return nil }
        let url = directory.appendingPathComponent(
            "\(filePrefix)\(stampFormatter.string(from: now))-"
            + "\(StoreKeyEnvelope.shortFingerprint(fingerprint)).\(fileExtension)")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try bytes.write(to: url, options: .atomic)
        } catch {
            return nil
        }
        writeSnapshotKeyFile(for: url, from: keyFileURL)
        copyKeyEnvelope(keyFileURL, into: directory)
        try? prune(directory: directory, keep: 14)
        var pending = defaults.stringArray(forKey: pendingLockTimeChecksKey) ?? []
        pending.append(url.lastPathComponent)
        defaults.set(pending, forKey: pendingLockTimeChecksKey)
        return url
    }

    /// The next unlock's check of every pending lock-time copy, with the
    /// store's keyed configuration (a keyless copy can only be checked
    /// once a key is in hand). Returns one line per copy for the run
    /// record; clears the pending list.
    nonisolated static func checkPendingLockTimeCopies(
        in directory: URL, defaults: UserDefaults, using configuration: GRDB.Configuration
    ) -> [String] {
        let pending = defaults.stringArray(forKey: pendingLockTimeChecksKey) ?? []
        guard !pending.isEmpty else { return [] }
        defaults.removeObject(forKey: pendingLockTimeChecksKey)
        return pending.map { name in
            let url = directory.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else {
                return "lock-time copy \(name): gone before it could be checked"
            }
            return "lock-time copy \(name): \(integrityCheck(of: url, using: configuration))"
        }
    }

    /// This directory's backup files, oldest first — **the app's OWN snapshots
    /// and nothing else** (18k C7, the held walks' W-3): a name `date(fromBackupURL:)`
    /// accepts, with the `.sqlite` extension. Every "newest copy" in this file is
    /// this list's `.last`, and every prune counts it — so it must never hold a
    /// file the app did not write. It used to keep ANY `variorum-backup-*.sqlite`
    /// sorted by name, and a foreign file that merely starts the same way (the A1
    /// rail's `variorum-backup-a1-…` safety copies, a July drill's
    /// `variorum-backup-seed-drill-…`) sorts after every dated copy (`2` < `a` <
    /// `s`): it became the copy sent to the second folder, the reason every hourly
    /// check wrote a fresh snapshot, and a slot the prune kept while deleting real
    /// copies. Such files are the author's (or a session's), never candidates and
    /// never pruned here — `MarkdownInsurance.existingExports` has always filtered
    /// the same way. Sorted by the parsed stamp (name as the tiebreak), not by the
    /// raw name, so the order is the dates' whatever a name's tail carries.
    nonisolated static func existingBackups(in directory: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .compactMap { url -> (url: URL, date: Date)? in
                guard url.pathExtension == fileExtension,
                      let date = date(fromBackupURL: url) else { return nil }
                return (url, date)
            }
            .sorted { ($0.date, $0.url.lastPathComponent) < ($1.date, $1.url.lastPathComponent) }
            .map(\.url)
    }

    /// **A stamp later than now is not evidence of freshness** (18o U1 —
    /// KnownIssues row 84, 18k C7's NOTICED 1). The ONE rule every freshness
    /// question in the backup run consults: the due-checks here (primary, the
    /// second folder, the lock-time copy), the weekly export's
    /// (`MarkdownInsurance`), and the Data Safety face (`DataSafetyModel`).
    ///
    /// A clock that once ran fast leaves a copy stamped ahead of now. Each
    /// check used to take the newest stamp as-is and ask `now − newest <
    /// interval` — NEGATIVE for a future stamp, so every check read "fresh"
    /// until the clock passed the stamp plus a whole interval: the automatic
    /// backups stopped and nothing said so, and the face (asking the same of
    /// the same stamp) never turned stale. Treating a future newest as DUE
    /// instead would not do: the future copy stays the newest by stamp, so
    /// every hourly check would write again (C7's reader-3 storm). So a
    /// future-stamped copy is simply not what freshness is read from. The
    /// copy itself STAYS — a real snapshot with a wrong date is never this
    /// rule's to delete, and the prune keeps it in the slot its date gives it.
    nonisolated static func stampIsTrusted(_ stamp: Date, now: Date) -> Bool {
        stamp <= now
    }

    /// The newest of the app's own copies whose stamp `stampIsTrusted` —
    /// what every due-check here reads as "the newest copy".
    nonisolated static func newestTrustedBackup(
        in directory: URL, now: Date
    ) throws -> (url: URL, date: Date)? {
        for url in try existingBackups(in: directory).reversed() {
            if let date = date(fromBackupURL: url), stampIsTrusted(date, now: now) {
                return (url, date)
            }
        }
        return nil
    }

    /// Both of the app's names parse (pre-13x 1a): the 13p-era
    /// `variorum-backup-<stamp>` and the fingerprinted `variorum-backup-<stamp>-<fp8>`
    /// — and ONLY those (18k C7): the tail is empty or `-` plus the key's eight
    /// lowercase hex characters (`StoreKeyEnvelope.shortFingerprint`), and the stamp
    /// must read back exactly as the writer formats it. A foreign name that happens
    /// to START with a stamp (`…-<stamp>-a1-window.sqlite`) is not the app's.
    nonisolated static func date(fromBackupURL url: URL) -> Date? {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix(filePrefix) else { return nil }
        let rest = name.dropFirst(filePrefix.count)
        let stamp = String(rest.prefix(stampLength))
        let tail = rest.dropFirst(stampLength)
        guard tail.isEmpty || isFingerprintSuffix(tail) else { return nil }
        guard let date = stampFormatter.date(from: stamp),
              stampFormatter.string(from: date) == stamp else { return nil }
        return date
    }

    /// `-` + eight lowercase hex characters — the suffix `performBackupIfDue` and
    /// the lock-time copy write.
    nonisolated private static func isFingerprintSuffix(_ tail: Substring) -> Bool {
        tail.count == 9 && tail.first == "-"
            && tail.dropFirst().allSatisfy { "0123456789abcdef".contains($0) }
    }

    /// The short fingerprint a snapshot's name carries, nil for a legacy
    /// name — the restore surface's "which key file opens this" fact.
    nonisolated static func shortFingerprint(fromBackupURL url: URL) -> String? {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix(filePrefix) else { return nil }
        let tail = name.dropFirst(filePrefix.count).dropFirst(stampLength)
        guard tail.hasPrefix("-"), tail.count == 9 else { return nil }
        return String(tail.dropFirst())
    }

    /// `yyyy-MM-dd-HHmmss` is 17 characters.
    nonisolated private static let stampLength = 17

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
