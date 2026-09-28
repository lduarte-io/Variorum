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
//    window over `last_touched_at` (+ the created_at branch for
//    NEVER-touched, mint-only posts), so a sweep costs ∝ containers edited
//    since the previous sweep, never the corpus (P1);
//  - the mark is per-device, PER-STORE-VARIANT bookkeeping (UserDefaults by
//    default; one build can open either store — the dev fence's opt-in — so
//    an unscoped key would let a dev-store sweep advance the real store's mark and
//    skip its window — review round 1). Losing a mark merely widens the
//    next sweep;
//  - the mark advances only when every candidate was asked successfully —
//    a transiently failing candidate is retried by the next sweep instead
//    of being swept past forever (review round 1).
//

import Foundation
import VariorumCore

@MainActor
final class IdleCommitScheduler {
    private let database: AppDatabase
    private let now: @Sendable () -> Date
    private let loadMark: () -> String?
    private let saveMark: (String) -> Void
    /// The per-candidate ask (default: `idleAutoCommit` through the
    /// runner) — injectable so the error posture is testable.
    private let ask: (String) async throws -> Int
    private var timerTask: Task<Void, Never>?
    /// Auto commits written by the last sweep (test observability).
    private(set) var lastSweepCommitCount = 0
    private(set) var lastError: String?

    /// Marks are scoped by store variant: `IdleCommitSweepMark.Variorum` /
    /// `IdleCommitSweepMark.Variorum-dev`.
    nonisolated static func markDefaultsKey(for variant: AppDatabase.StoreVariant) -> String {
        "IdleCommitSweepMark.\(variant.rawValue)"
    }

    init(
        database: AppDatabase,
        runner: OperationsRunner,
        storeVariant: AppDatabase.StoreVariant = .real,
        now: @escaping @Sendable () -> Date = { Date() },
        loadMark: (() -> String?)? = nil,
        saveMark: ((String) -> Void)? = nil,
        ask: ((String) async throws -> Int)? = nil
    ) {
        self.database = database
        self.now = now
        let key = Self.markDefaultsKey(for: storeVariant)
        self.loadMark = loadMark
            ?? { UserDefaults.standard.string(forKey: key) }
        self.saveMark = saveMark
            ?? { UserDefaults.standard.set($0, forKey: key) }
        self.ask = ask
            ?? { containerID in
                try await runner.run { ops in
                    try ops.idleAutoCommit(containerID).count
                }
            }
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
    /// gets one `idleAutoCommit` ask; the mark advances to the cutoff — only
    /// when no ask failed — so the next sweep pays only for edits since.
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
            var allAsksSucceeded = true
            for containerID in candidates {
                do {
                    lastSweepCommitCount += try await ask(containerID)
                } catch {
                    // A container sealed or deleted between the query and
                    // the ask self-clears (the next sweep's query excludes
                    // it); anything else retries next sweep because the
                    // mark below stays put.
                    lastError = String(describing: error)
                    allAsksSucceeded = false
                }
            }
            if allAsksSucceeded {
                saveMark(cutoff)
            }
        } catch {
            lastError = String(describing: error)
        }
    }
}
