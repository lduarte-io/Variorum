//
//  StarredGatheringSeeder.swift
//  Shared (Variorum + VariorumMobile)
//
//  13i-b U4 — THE STARRED-NOTES GATHERING'S OCCASION (the sitting record §3;
//  P-13ib-4). The brain is the core op (`Operations.ensureStarredNotesGathering`
//  — discovery, her deletion honoured, the mint, one transaction); this file is
//  only WHEN, and what this device remembers.
//
//  The seeded books' discipline (`SampleLibrarySeeder`), at the size of one
//  row:
//    · ONCE PER STORE PER DEVICE — a per-store-variant mark in the device's
//      defaults. It is what keeps a deletion deleted after the Trash purges its
//      tombstone (the store's own evidence is gone by then), and it means a
//      later BIND or rename can never summon a fresh twin.
//    · THE SYNC GATE — a store that belongs to an account is not judged until
//      its first clean round has landed (the gathering may already be on its
//      way from another device). Declining is free: nothing is marked, and the
//      next launch asks again.
//    · SILENT — furniture never speaks; one log line says what happened.
//
//  Hoisted to `Shared/` so the phone's occasion is one call when the mobile
//  catch-up wires it (DEFERRED at U4 — the phone's first-write pins count the
//  readings that occasion mints; the 13i-b U4 record carries the row). On the
//  Mac it runs from the window's `.task`, after the sample books.
//

import Foundation
import OSLog
import VariorumCore

@MainActor
enum StarredGatheringSeeder {
    /// What one occasion did. Recorded, never surfaced.
    enum Outcome: Equatable {
        /// This device already settled it for this store — including the case
        /// where she then deleted the gathering. Never asked again.
        case alreadySeeded
        /// The store belongs to an account whose first clean round has not
        /// landed. NOT marked: the next launch asks again.
        case awaitingFirstSync
        /// The ensure ran and decided (minted · already present · deleted by
        /// her) — marked. A REFUSAL is carried here too but NOT marked.
        case ensured(Operations.StarredGatheringEnsure)
    }

    /// Scoped by store variant, like every seeded mark — one build can open
    /// either store, and a dev-store seed must never suppress the real one's.
    nonisolated static func seededDefaultsKey(for variant: AppDatabase.StoreVariant) -> String {
        "StarredGatheringSeeded.\(variant.rawValue)"
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "starred-gathering")

    @discardableResult
    static func seedIfNeeded(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SampleLibrarySeeder.SyncGate = .unowned,
        firstRoundWait: Duration = SampleLibrarySeeder.firstRoundWait,
        pollInterval: Duration = .milliseconds(100),
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil
    ) async -> Outcome {
        let key = seededDefaultsKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.bool(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }
        let outcome = await perform(
            session: session, gate: gate, firstRoundWait: firstRoundWait,
            pollInterval: pollInterval, load: load, save: save)
        log.notice("starred gathering: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(
        session: AppSession,
        gate: SampleLibrarySeeder.SyncGate,
        firstRoundWait: Duration,
        pollInterval: Duration,
        load: () -> Bool,
        save: (Bool) -> Void
    ) async -> Outcome {
        guard !load() else { return .alreadySeeded }
        if gate.belongsToAnAccount() {
            guard await waitForFirstCleanRound(
                gate: gate, limit: firstRoundWait, poll: pollInterval)
            else { return .awaitingFirstSync }
        }
        let ensured: Operations.StarredGatheringEnsure
        do {
            ensured = try await session.runner.run { ops in ops.ensureStarredNotesGathering() }
        } catch {
            return .ensured(.refused(String(describing: error)))
        }
        switch ensured {
        case .minted, .alreadyPresent, .deletedByTheReader:
            save(true)
        case .refused:
            break  // not marked: the next launch asks again
        }
        return .ensured(ensured)
    }

    /// Polled, the sample seeder's way (`SyncSession` exposes no
    /// round-completed closure; the gate reads the scheduler's status).
    private static func waitForFirstCleanRound(
        gate: SampleLibrarySeeder.SyncGate, limit: Duration, poll: Duration
    ) async -> Bool {
        if gate.hasSyncedCleanly() { return true }
        let deadline = ContinuousClock.now.advanced(by: limit)
        while ContinuousClock.now < deadline {
            do { try await Task.sleep(for: poll) } catch { return false }
            if gate.hasSyncedCleanly() { return true }
        }
        return gate.hasSyncedCleanly()
    }
}
