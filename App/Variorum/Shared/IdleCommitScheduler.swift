//
//  IdleCommitScheduler.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 5 — resolves the KnownIssues "Idle auto-commit scheduling"
//  entry for the PRODUCT, not one platform. AppSpec §9 assigns idle
//  DETECTION (the `idle_commit_hours` clock, default 24 h) to the app;
//  `Operations.idleAutoCommit` already enforces the commit rules (at most
//  one quiet auto commit per dirty variant, idempotent). This scheduler only
//  decides WHEN to ask, and WHOM:
//
//  - on launch and periodically while running (injectable clock);
//  - candidates from `Queries.idleCommitCandidates` — a low-water-mark
//    window over `last_touched_at` (+ the created_at branch for mint-only
//    posts), so a sweep costs ∝ containers edited since the previous sweep,
//    never the corpus (P1);
//  - the mark is per-device bookkeeping (UserDefaults by default) — losing
//    it merely widens the next sweep.
//

import Foundation
import VariorumCore

@MainActor
final class IdleCommitScheduler {
    private let database: AppDatabase
    private let runner: OperationsRunner
    private let now: @Sendable () -> Date
    private let loadMark: () -> String?
    private let saveMark: (String) -> Void
    private var timerTask: Task<Void, Never>?
    /// Auto commits written by the last sweep (test observability).
    private(set) var lastSweepCommitCount = 0
    private(set) var lastError: String?

    static let markDefaultsKey = "IdleCommitSweepMark"

    init(
        database: AppDatabase,
        runner: OperationsRunner,
        now: @escaping @Sendable () -> Date = { Date() },
        loadMark: (() -> String?)? = nil,
        saveMark: ((String) -> Void)? = nil
    ) {
        self.database = database
        self.runner = runner
        self.now = now
        self.loadMark = loadMark
            ?? { UserDefaults.standard.string(forKey: Self.markDefaultsKey) }
        self.saveMark = saveMark
            ?? { UserDefaults.standard.set($0, forKey: Self.markDefaultsKey) }
    }

    /// Launch sweep + periodic re-sweeps while the app runs.
    func start(resweepEvery interval: Duration = .seconds(60 * 60)) {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.sweepNow()
                do { try await Task.sleep(for: interval) } catch { return }
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    /// One sweep: everything last touched in `(mark, now − idle_commit_hours]`
    /// gets one `idleAutoCommit` ask; the mark advances to the cutoff so the
    /// next sweep pays only for edits since.
    func sweepNow() async {
        lastSweepCommitCount = 0
        do {
            let database = database
            let idleHours = try await database.read { try Queries.idleCommitHours($0) }
            let cutoffDate = now().addingTimeInterval(-idleHours * 60 * 60)
            let cutoff = DateFormatter.variorumISO8601.string(from: cutoffDate)
            let mark = loadMark() ?? ""
            guard cutoff > mark else { return }  // nothing new can be idle yet

            let candidates = try await database.read { db in
                try Queries.idleCommitCandidates(db, afterMark: mark, cutoff: cutoff)
            }
            for containerID in candidates {
                do {
                    let committed = try await runner.run { ops in
                        try ops.idleAutoCommit(containerID)
                    }
                    lastSweepCommitCount += committed.count
                } catch {
                    // A container sealed between the query and the ask, a
                    // race with a delete — quiet insurance skips quietly
                    // and the sweep continues.
                    lastError = String(describing: error)
                }
            }
            saveMark(cutoff)
        } catch {
            lastError = String(describing: error)
        }
    }
}
