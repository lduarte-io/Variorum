//
//  SyncSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the app-side sync lifecycle over the Phase 5 engine:
//  wiring, not building (SyncSpec §10). One SyncScheduler (A3: serialized,
//  coalescing, pull→push) over SupabaseTransport with a foreground-simple
//  schedule; offline is free — the outbox queues, capture never blocks on
//  the network. Phase 9c, Step 5: the Phase 8 paste-in retired — the
//  transport is composed by AppServices' sign-in wiring over the
//  AuthSession session provider; this type no longer knows credentials
//  exist.
//
//  THE A4 FENCE, SYNC SEAM (Phase 8 review round 1, BLOCKER): there is
//  exactly ONE production mirror, and it pairs with the REAL store only.
//  Debug and release builds share the machine's login Keychain (their
//  bundle identities differ: `.debug` vs the installed one — the bridge
//  retirement's round-2 N3 corrected this sentence), so once the author
//  signs in, an ungated dev-store session
//  would auto-configure sync, pull her whole corpus into the dev store,
//  and push every dev-session write — a dev bug's destructive writes
//  included — into the mirror that replicates to her real devices.
//  `allowsSync` is therefore derived from the store variant (AppServices):
//  a dev-store session NEVER configures sync, whatever transport a caller
//  composes. (VX-483 — the one exception, DEBUG walk machinery only: a
//  launch whose walk switch resolved to a project that is NOT the
//  production mirror lifts the fence for that launch; a production ref
//  refuses. VX-510 D-B3 — the second, the prod test road: armed by its
//  switch and the allowlist, the dev store may sync with production only
//  while a listed test account is signed in. Release: absolute.)
//
//  Triggers wired HERE (both platforms): after local writes settle (the
//  outbox observation, debounced). Platform files add their own: foreground/
//  became-active, launch, and the iOS background transition.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

/// **VX-510 D-A1 — what an account act's first round came to** (`SyncSession.roundNow`, through
/// `AppServices.runFirstRound`): the act's sheet confirms it or says what blocks it, in the sync row's own words (VX-507).
nonisolated enum FirstRoundOutcome: Equatable, Sendable {
    /// The restore hold stands: no round runs before the one Resume press (13x row 7).
    case held
    /// No chain to run a round with — the A4 fence, a signed-out session, a failed owner adoption (F-5).
    case notConfigured
    /// The round ran; the scheduler's status as it left it.
    case ran(SyncScheduler.Status)
}

@MainActor
@Observable
final class SyncSession {
    /// The one-row functional status surface (SyncSpec §10 scope).
    private(set) var status = SyncScheduler.Status()
    var isConfigured: Bool { scheduler != nil }
    /// False for dev-store sessions (the A4 fence's sync seam, above).
    let allowsSync: Bool
    /// 13x U2 row 7 — THE RESTORE-HOLD's one chokepoint (the round-3
    /// ruling: an adopted copy lands OPEN with sync WAITING until the one
    /// Resume press). Consulted by `triggerSync()` and `flush()` — every
    /// trigger road funnels through them (the settle observation, the
    /// became-active hook, the post-configure trigger), so while it
    /// answers true NO round runs for this store; the kept outbox (QD)
    /// pushes at the first resumed round because nothing cleared it.
    /// nil = never held (every existing composition unchanged); the Mac
    /// wires it to the `LibraryRestoreHold` marker's standing state.
    var roundsHeld: (@MainActor () -> Bool)?
    private let database: AppDatabase
    /// Post-write settle debounce: outbox growth quiets down for this long
    /// before a round runs (keystroke-rate autosaves coalesce; S1's outbox
    /// absorbs the rest).
    private let settleDebounce: Duration
    private var scheduler: SyncScheduler?
    private var observationTasks: [Task<Void, Never>] = []
    private var settleTask: Task<Void, Never>?

    init(
        database: AppDatabase,
        allowsSync: Bool = true,
        settleDebounce: Duration = .seconds(3)
    ) {
        self.database = database
        self.allowsSync = allowsSync
        self.settleDebounce = settleDebounce
    }

    /// Builds the transport → engine → scheduler chain and starts the
    /// write-settle + status observations. The production caller is
    /// AppServices' sign-in wiring (Phase 9c, Step 5 — the transport rides
    /// the AuthSession session provider; the Phase 8 paste-in and its
    /// credential paths are retired); tests inject fakes here.
    /// Re-configuring replaces the chain — after DRAINING the old one: the
    /// old scheduler may be mid-round, and A3's one-round-at-a-time
    /// guarantee is per-scheduler, so the session must never let a new
    /// chain run while the old round is in flight (Phase 8 review round 1,
    /// MINOR). Refused wholesale for dev-store sessions (the fence): the
    /// one production mirror pairs with the real store only, whatever
    /// transport a caller composes.
    ///
    /// `keyProvider` (Phase 14b batch 3 — batch 2's PROVISIONAL 2 resolved):
    /// the engine's E2EE key seam, REQUIRED at this seam so every
    /// composition site decides — the production caller passes the
    /// protection road's `NewRoadSyncKeyProvider` (VX-329 U1: today's
    /// `DeviceKeySyncProvider` left with today's road); tests pass fixed or locked
    /// providers. There is no plaintext mode: a refusing provider means
    /// every round refuses visibly, which is the designed pre-enrollment
    /// state, never a wiring accident.
    func configure(
        transport: any SyncTransport, keyProvider: any SyncKeyProviding,
        furnitureFacts: SeededFurnitureDedupeFacts? = nil,
        accountBinding: SyncAccountBinding? = nil
    ) async {
        guard allowsSync else { return }
        let old = scheduler
        stopObservations()
        scheduler = nil
        if let old {
            // Retire FIRST, then drain: a `triggerSync` Task that captured
            // the old scheduler before this swap must not revive the
            // retired chain after the drain (review round 2) — a retired
            // scheduler refuses all new rounds; awaitIdle covers the one
            // already in flight.
            await old.retire()
            await old.awaitIdle()
        }

        // Phase 13j (batch 6b): the purge janitor rides the scheduler —
        // wired exactly when the transport carries the purge surface
        // (`SupabaseTransport` does; test wrappers don't, so their worlds
        // are untouched). The janitor sweeps after each clean round: the
        // ledger reconciliation, the horizon-gated family purges, and the
        // savepoint pruning mints — the memo's §4b, riding the existing
        // scheduler as designed.
        // The sample-library dedupe's facts (pre-13u Act 0, R-pre13u-8):
        // the engine cannot see the seeder, so the identity predicate and
        // per-note manifest are handed in here — the one composition site
        // both platforms share. pre-13x 5a: EVERY seeded book's facts
        // (Sherlock + *Encryption Explained*), a list. 17y B-DEDUPE: the
        // seeded-furniture fold's facts ride the same seam (nil = the
        // SHARED half — the caller passes the platform's whole set).
        let engine = SyncEngine(
            transport: transport, keyProvider: keyProvider,
            sampleLibraryFacts: SampleLibrarySeeder.allDedupeFacts(),
            furnitureFacts: furnitureFacts ?? SampleLibrarySeeder.furnitureDedupeFacts(),
            accountBinding: accountBinding)
        let janitor = (transport as? any SyncTransport & SyncPurgeTransport)
            .map { PurgeJanitor(transport: $0, keyProvider: keyProvider) }
        let scheduler = SyncScheduler(engine: engine, janitor: janitor)
        self.scheduler = scheduler

        // Status → the observable surface (`roundsCompleted` increments
        // exactly once per finished round; the scheduler counts it).
        observationTasks.append(Task { [weak self] in
            // (A round-completed closure seam lived here for the Fragments
            // bridge, Phase 9b → 2026-09-04; it left with its one subscriber
            // — the status stream IS the seam, `roundsCompleted` its count.)
            for await status in await scheduler.statusUpdates() {
                guard let self else { break }
                self.status = status
            }
        })
        // Local writes settle → one round. The outbox observation fires at
        // write rate; the debounce coalesces a burst into one trigger.
        observationTasks.append(Task { [weak self, database] in
            do {
                for try await pending in database.observe({ db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
                }) {
                    guard let self, pending > 0 else { continue }
                    self.scheduleSettleTrigger()
                }
            } catch {
                // Observation ended (cancellation/teardown) — triggers from
                // foreground events still run rounds.
            }
        })
    }

    /// One sync round, serialized/coalesced by the scheduler (A3).
    func triggerSync() {
        guard roundsHeld?() != true else { return }
        guard let scheduler else { return }
        Task { await scheduler.trigger() }
    }

    /// **VX-510 D-A1 — ONE ROUND, RUN TO ITS END, AND WHAT IT CAME TO** (an account act's first round — VX-498/VX-507).
    /// Held like every other road (13x row 7): under the restore hold nothing runs (`.held`). No chain to run one with —
    /// the A4 fence, a signed-out session, a failed owner adoption (the run record's F-5) — says so (`.notConfigured`)
    /// rather than waiting forever. Otherwise the scheduler's EXISTING public API (no `Sync/` line): a trigger (coalescing —
    /// a round already in flight is followed by exactly one more, which reads the keys as they stand now), then the wait
    /// for idle, then the scheduler's own status as the round left it. Nothing here cancels a round: a caller that stops
    /// waiting leaves it running.
    func roundNow() async -> FirstRoundOutcome {
        guard roundsHeld?() != true else { return .held }
        guard let scheduler else { return .notConfigured }
        await scheduler.trigger()
        await scheduler.awaitIdle()
        return .ran(await scheduler.status)
    }

    /// Waits for in-flight rounds — the iOS background transition uses this
    /// to push before suspension. Held like every other road (13x row 7):
    /// a restored library pushes nothing before Resume.
    func flush() async {
        guard roundsHeld?() != true else { return }
        guard let scheduler else { return }
        await scheduler.trigger()
        await scheduler.awaitIdle()
    }

    /// Teardown only (no new chain follows). Retiring CANCELS an in-flight
    /// round (VX-494 D3): its download stops between pull windows, the
    /// windows it completed staged for the next round, while a save already
    /// running finishes (ladder R3, R3-1 — a lock then waits for it on the
    /// writer); nothing here awaits it. Chain REPLACEMENT goes through
    /// `configure`, which drains.
    /// Retiring closes the stale-trigger door here too.
    func stop() {
        stopObservations()
        let old = scheduler
        scheduler = nil
        if let old {
            Task { await old.retire() }
        }
    }

    private func stopObservations() {
        for task in observationTasks { task.cancel() }
        observationTasks.removeAll()
        settleTask?.cancel()
        settleTask = nil
    }

    private func scheduleSettleTrigger() {
        settleTask?.cancel()
        settleTask = Task { [weak self, settleDebounce] in
            guard (try? await Task.sleep(for: settleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.triggerSync()
        }
    }
}
