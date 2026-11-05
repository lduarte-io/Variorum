//
//  JournalSegmentationClearing.swift
//  Variorum (Mac)
//
//  VX-799 (the VX-805 run, Unit A) — WHEN the journal entries' stored
//  `one_block` override is cleared. Her sitting ruling (2026-11-04): new
//  journal entries stop seeding `one_block` AND the stored override on
//  EXISTING entries is cleared ("i don't think it matters that much"). The
//  brain is the core op (`Operations.clearJournalOneBlockOverrides` — the
//  exact class, one transaction, idempotent); this file is only the occasion
//  and what this device remembers.
//
//  WHY HERE, AND WHY NOT A MIGRATION (the choice, recorded in the run record's
//  Unit A section): the precedent for "a mint default changed; flip the
//  existing rows" is `v1_19_journals_newest_first`, a data-only migration —
//  but a migration is the heavier road for a ruling she called low-stakes: a
//  store or plaintext export that has run it reads `.newerSchema` on an older
//  build and refuses (VX-502's classifier), and the append-only registry is
//  shared with the parallel runs (a number collision at merge). An ops-road
//  pass at the launch's occasion changes no schema and no migration set.
//
//  The seeders' discipline (`StarredGatheringSeeder`), at the size of one
//  UPDATE:
//    · THE SYNC GATE — a store that belongs to an account waits for its first
//      clean round, so a device that is joining sees the rows it is about to
//      hold. Declining is free: nothing is marked, the next launch asks again.
//    · SETTLED WHEN NOTHING IS LEFT — the device marks the store settled only
//      when a pass finds NOTHING to clear. A pass that cleared rows is not
//      marked: the next launch runs it again and marks it when it comes up
//      empty. That is what makes it self-healing: a clear that lost a
//      server-wins CAS race to another device's concurrent edit of the same
//      container (the row comes back `one_block`) is cleared again at the next
//      launch, and the cost is bounded — a few launches at most.
//    · SILENT — a store pass never speaks; one log line says what happened.
//
//  THE RESIDUALS, NAMED: an entry that arrives by sync AFTER this device
//  settled, minted by a device still on an older build, keeps its override
//  (the chip turns it off; once every device runs this build no mint seeds
//  one). A library this device ADOPTS (Open Library, Make this my library)
//  is judged by the device's existing mark. A Trash restoree keeps its
//  override (the op skips tombstoned rows). Mac-only: the phone's store
//  receives the Mac's cleared rows by sync; a phone-only store keeps its
//  overrides until the mobile catch-up wires this occasion (one call).
//

import Foundation
import OSLog
import VariorumCore

@MainActor
enum JournalSegmentationClearing {
    /// What one occasion did. Recorded, never surfaced.
    enum Outcome: Equatable {
        /// This device already settled this store. Never asked again.
        case alreadySettled
        /// The store belongs to an account whose first clean round has not
        /// landed. NOT marked: the next launch asks again.
        case awaitingFirstSync
        /// The pass cleared this many rows. NOT marked: the next launch runs
        /// it again and settles when it finds nothing.
        case cleared(Int)
        /// The pass found nothing left to clear — marked settled.
        case settled
        /// The op refused (a store failure). NOT marked.
        case refused(String)
    }

    /// Scoped by store variant, like every seeded mark — one build can open
    /// either store, and a dev-store settle must never suppress the real one's.
    nonisolated static func settledDefaultsKey(for variant: AppDatabase.StoreVariant) -> String {
        "JournalOneBlockCleared.\(variant.rawValue)"
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "journal-segmentation")

    @discardableResult
    static func runIfNeeded(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SampleLibrarySeeder.SyncGate = .unowned,
        firstRoundWait: Duration = SampleLibrarySeeder.firstRoundWait,
        pollInterval: Duration = .milliseconds(100),
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil
    ) async -> Outcome {
        let key = settledDefaultsKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.bool(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }
        let outcome = await perform(
            session: session, gate: gate, firstRoundWait: firstRoundWait,
            pollInterval: pollInterval, load: load, save: save)
        log.notice("journal one_block clearing: \(String(describing: outcome), privacy: .public)")
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
        guard !load() else { return .alreadySettled }
        if gate.belongsToAnAccount() {
            guard await waitForFirstCleanRound(
                gate: gate, limit: firstRoundWait, poll: pollInterval)
            else { return .awaitingFirstSync }
        }
        let cleared: Int
        do {
            cleared = try await session.runner.run { ops in try ops.clearJournalOneBlockOverrides() }
        } catch {
            return .refused(String(describing: error))
        }
        guard cleared == 0 else { return .cleared(cleared) }
        save(true)
        return .settled
    }

    /// Polled, the seeders' way (`SyncSession` exposes no round-completed
    /// closure; the gate reads the scheduler's status).
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
