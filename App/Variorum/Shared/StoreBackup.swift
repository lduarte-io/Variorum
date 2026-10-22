//
//  StoreBackup.swift
//  Variorum (shared; wired on the Mac — the phone's store is re-derivable
//  from the mirror)
//
//  Phase 8, A1 — rotating cold copies (author decision 2026-07-06):
//  Supabase is a live MIRROR, not a backup — a destructive bug replicates
//  faithfully. These copies are the missing net: on launch and daily while
//  running, one consistent snapshot, kept to a cap. This class is the CLOCK
//  and the RECORD: one due-check at launch and hourly after, Back Up Now,
//  one run at a time, a run record (`BackupRunRecord`/`BackupLog`) so the
//  Data Safety face can say what happened without asking anything to run.
//
//  VX-329 U1 — THE RELEASE SWITCH: the run's WRITER is the protection road's
//  pair road (rule 5 — "a backup is the library plus its key file"), handed
//  in by `ProtectionBackupHook.attach` as `pairRoad`: this Mac's pair of the
//  library beside it (`Backups/<library8>/<mac8>/`), the same pair in the
//  picked folder when due there, and retention after (`Retention` —
//  `ProtectionBackupHook.runPair`). Today's flat legs (the container's
//  `Backups/variorum-backup-<stamp>.sqlite`, its second-folder copy and its
//  14+4 sweep, today's key-file copies beside them, the lock-time keyless
//  byte copy) were today's road's writers and were deleted with it.
//
//  Phase 13l, Act 5 (ledger row 16) — the plain-text insurance
//  (`MarkdownInsurance`) rides this run on its own weekly due-ness, into the
//  picked folder's `md-exports/` — one tick, one record, one face. The unit
//  itself lives in its own file on purpose — see its header.
//

import Foundation
import VariorumCore

@MainActor
final class StoreBackup {
    struct Configuration: Sendable {
        /// A new copy when the newest is older than this (launch + daily).
        var interval: TimeInterval = 24 * 60 * 60
        /// 13l Act 5 (row 16): the plain-text insurance's cadence and
        /// retention — PROVISIONAL (weekly, keep 4; QUESTIONS #75).
        var markdownInsurance: MarkdownInsurance.Policy = .standard
        /// The restore recipe dropped beside the copies, when the platform
        /// has one to give. A PARAMETER rather than a Shared constant: the
        /// text is entirely Mac-shaped (container paths, Finder steps), and
        /// `Shared/` means both platforms compile it — so the machinery is
        /// shared and the words are the caller's. nil = write nothing.
        var runbookText: String?
    }

    /// What the pair road did for one run — its two legs, already worded as the record's (the container's pair, the
    /// picked folder's). `force`: Back Up Now — a fresh pair whatever the interval.
    typealias PairRoad = @Sendable (_ force: Bool, _ now: Date) -> (primary: BackupRunRecord.Leg, secondary: BackupRunRecord.Leg)

    /// The restore recipe's filename in a backup folder. Here rather than
    /// with the text, because the WRITER owns the file's name and the
    /// caller owns its words.
    nonisolated static let runbookFilename = "RESTORE.md"

    private let database: AppDatabase
    /// The in-container `Backups/` folder — the Data Safety face's "beside your library" row names it.
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
    /// VX-329 U1: the run's writer — the road's pair road for the library open now (`ProtectionBackupHook.attach`, at
    /// every ready); nil — no library open on a writing road — writes no pair and says so ("No place to copy to.").
    var pairRoad: PairRoad?

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
    /// re-checks (a catalogue read; the interval decides if a pair is
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

    /// Writes a pair when this Mac's newest pair of the library is older than
    /// the interval (or none exists), the picked folder's when due there.
    /// Off the main thread (P2).
    @discardableResult
    func backupIfDue() async -> BackupRunRecord {
        await run(force: false)
    }

    /// "Back Up Now…" — the ADJUNCT door (the recorded lean: welcome on top
    /// of the automatic job, never the load-bearing mechanism). Forces a
    /// fresh pair beside the library regardless of the interval.
    @discardableResult
    func backUpNow() async -> BackupRunRecord {
        await run(force: true)
    }

    /// **18k C5 (17e P38) — ONE RUN AT A TIME.** Several doors reach `run`
    /// with no latch they share — the hourly tick, Back Up Now, the insurance
    /// toggle, the iCloud offer — so the latch lives HERE, where they all
    /// meet. `id` lets a finished run clear only its own slot.
    private var inFlight: (id: Int, task: Task<BackupRunRecord, Never>, forced: Bool)?
    private var runSerial = 0

    /// The single-flight door. A request while a run is in flight is handed
    /// THAT run's outcome — never a parallel run — whenever that run does at
    /// least what the request asks: any request behind a forced run, and a
    /// due-check behind anything. The one exception is Back Up Now's own
    /// promise ("a fresh pair regardless of the interval", above): a FORCED
    /// request behind a due-check that may find nothing due waits for it and
    /// then runs its own, so it is never answered "already up to date" —
    /// still one run at a time, one after the other.
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

    /// One run, start to finish — only `run` above may call it.
    private func performOneRun(force: Bool) async -> BackupRunRecord {
        let database = database
        let directory = directory
        let configuration = configuration
        let defaults = defaults
        let pairRoad = pairRoad
        let stamp = now()
        let record = await Task.detached(priority: .utility) {
            let store = defaults()
            let record = StoreBackup.performRun(
                database: database, directory: directory,
                configuration: configuration, defaults: store,
                now: stamp, force: force, pairRoad: pairRoad)
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

    // MARK: - The run: the pair road, the recipe, the plain-text leg

    /// ONE run, never throwing — a run reports what happened; it does not fail
    /// the app. Static + nonisolated so tests drive it deterministically,
    /// off-main by contract.
    nonisolated static func performRun(
        database: AppDatabase, directory: URL, configuration: Configuration,
        defaults: UserDefaults, now: Date, force: Bool, pairRoad: PairRoad?
    ) -> BackupRunRecord {
        dispatchPrecondition(condition: .notOnQueue(.main))
        var legs = pairRoad?(force, now) ?? (
            primary: BackupRunRecord.Leg(outcome: .noDestination),
            secondary: BackupRunRecord.Leg(outcome: .noDestination))
        if legs.primary.destination == nil { legs.primary.destination = BackupDestination.displayPath(directory) }

        // The recipe rides beside the copies it is about (13l row 13). The
        // moment a restore recipe gets read is the moment the app may not
        // open, so a copy that lives only inside the app is not a runbook.
        writeRunbook(configuration.runbookText, into: directory)
        // One step up from the picked folder's copies — the folder she actually opens when she goes looking.
        if BackupDestination.isSet(in: defaults), let resolved = BackupDestination.resolve(in: defaults) {
            BackupDestination.withAccess(to: resolved.picked) {
                writeRunbook(configuration.runbookText, into: BackupDestination.variorumFolder(in: resolved.picked))
            }
        }

        // 13l Act 5 (row 16): the plain-text insurance rides this run rather
        // than minting a second clock — one hourly tick, one record, one
        // log, one face. Its DUE-NESS is its own (weekly), so on six days
        // out of seven this costs a directory listing. It runs LAST because
        // it is the heaviest leg and the least urgent.
        let markdown = MarkdownInsurance.performRun(
            database: database, defaults: defaults,
            policy: configuration.markdownInsurance, now: now, force: force)
        return BackupRunRecord(
            at: now, primary: legs.primary, secondary: legs.secondary, markdown: markdown)
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

    /// **A stamp later than now is not evidence of freshness** (18o U1 —
    /// KnownIssues row 84, 18k C7's NOTICED 1). The ONE rule every freshness
    /// question consults: the pair road's due-checks (`OwnCopies` restates it
    /// byte-equal in core), the weekly export's (`MarkdownInsurance`), and the
    /// Data Safety face (`DataSafetyModel`). A copy stamped ahead of the clock
    /// is not what freshness is read from; the copy itself STAYS.
    nonisolated static func stampIsTrusted(_ stamp: Date, now: Date) -> Bool {
        stamp <= now
    }
}
