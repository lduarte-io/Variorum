//
//  AppServices.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8: the session-scoped background services both apps start after a
//  successful store open — sync lifecycle (Step 6), the idle auto-commit
//  sweep (Step 5), and (where enabled) rotating store backups (A1).
//  Composition-root property, injected downward; no globals.
//
//  Phase 9c, Step 5 — the sign-in era: AppServices owns the TWO auth
//  sessions (the Variorum session — the identity everything keys on; and
//  the bridge's direct Fragments-project session — QUESTIONS #16 shape
//  (c)) and wires sign-in state into everything downstream: the
//  owner-adoption backfill runs at sign-in and at every signed-in launch
//  (idempotent — Step 4), the sync chain is composed over the AuthSession
//  session provider (Step 2's seam), the bridge engine is composed over
//  the Fragments session, and sign-out tears the chains down. The Phase 8
//  paste-in is fully retired; its Keychain item is cleared on the first
//  real sign-in.
//
//  Phase 14a, batch 1 — the Variorum sign-in goes DIRECT (round 0h): the
//  suite email+password drives the password grant against the Variorum
//  project itself; the delegated browser flow is retired from this file
//  (the Fragments batch rebuilds delegation for the BRIDGE's session,
//  against the live suite provider).
//

import Foundation
import Observation
import VariorumCore

/// The sign-in surface's observable projection (views render this and call
/// AppServices methods; the AuthSession actors stay the truth).
@MainActor
@Observable
final class AccountState {
    struct SignedIn: Equatable {
        var userID: String
        var email: String?
    }

    var variorum: SignedIn?
    var fragments: SignedIn?
    var busy = false
    var lastError: String?
}

@MainActor
final class AppServices {
    let sync: SyncSession
    /// The Fragments journal bridge (Phase 9b). Mac-side only this phase;
    /// configured by the Fragments session's sign-in below.
    let bridge: BridgeSession
    let idleCommits: IdleCommitScheduler
    /// Rotating cold copies (A1). Wired on the Mac; nil on iOS — the
    /// phone's store is re-derivable from the mirror.
    let backup: StoreBackup?
    /// The Variorum-project session (the suite account, signed in direct —
    /// Phase 14a round 0h): the identity `owner_id` and the mirror's RLS
    /// key on.
    let auth: AuthSession
    /// The bridge's Fragments-project session (QUESTIONS #16, shape (c)).
    let fragmentsAuth: AuthSession
    let account = AccountState()

    /// The app session (store + runner) the services compose over —
    /// internal so the wiring tests can drive the production runner path.
    let session: AppSession

    /// Injectable transport composition (review round 1, MINOR: without
    /// the seam, the wiring tests fired real network requests at the
    /// production project URL — breaking the repo-wide no-network test
    /// discipline). Defaults compose the ProjectConfig production
    /// transports; tests inject recording fakes, which also turns the
    /// fence/wiring assertions into COMPOSITION checks, not network luck.
    private let makeSyncTransport: (any UserSessionProviding) -> any SyncTransport
    private let makeBridgeTransport:
        (any UserSessionProviding, _ expectedUserID: String) -> any FragmentsBridgeTransport

    init(
        session: AppSession, storeVariant: AppDatabase.StoreVariant,
        backupEnabled: Bool, bridgeEnabled: Bool = false,
        auth: AuthSession? = nil, fragmentsAuth: AuthSession? = nil,
        bridgeMinimumRoundInterval: Duration = .seconds(60),
        makeSyncTransport: ((any UserSessionProviding) -> any SyncTransport)? = nil,
        makeBridgeTransport: ((any UserSessionProviding, String) -> any FragmentsBridgeTransport)? = nil
    ) {
        self.session = session
        self.makeSyncTransport = makeSyncTransport ?? { provider in
            SupabaseTransport(
                configuration: ProjectConfig.variorumTransport,
                sessionProvider: provider)
        }
        self.makeBridgeTransport = makeBridgeTransport ?? { provider, expectedUserID in
            FragmentsRPCTransport(
                configuration: FragmentsRPCTransport.Configuration(
                    projectURL: ProjectConfig.fragmentsProjectURL,
                    apiKey: ProjectConfig.fragmentsPublishableKey,
                    expectedUserID: expectedUserID),
                sessionProvider: provider)
        }
        // THE A4 FENCE, SYNC SEAM (Phase 8 review round 1, BLOCKER): only
        // the REAL store may pair with the one production mirror. Debug and
        // release builds share a bundle identity and Keychain, so a
        // dev-store session must never adopt the signed-in session for
        // syncing — a dev bug's writes would push to the mirror and
        // replicate to her real devices.
        sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)
        // THE A4 FENCE EXTENDS TO THE BRIDGE (Phase 9b): the author's live
        // Fragments journal pairs with the REAL store only.
        bridge = BridgeSession(
            allowsBridge: bridgeEnabled && storeVariant == .real,
            minimumRoundInterval: bridgeMinimumRoundInterval)
        self.auth = auth ?? AuthSession(configuration: ProjectConfig.variorumAuth)
        self.fragmentsAuth = fragmentsAuth ?? AuthSession(
            configuration: ProjectConfig.fragmentsAuth,
            store: .keychain(service: KeychainAuthStorage.fragmentsService))
        // Bridge rounds ride the sync cadence: AFTER each sync round, never
        // interleaved with one (a landing sees the store the mirror sync
        // just settled). Unconfigured sessions no-op.
        sync.onRoundCompleted = { [weak bridge = bridge] in
            bridge?.trigger()
        }
        // The sweep's low-water mark is per-store bookkeeping: scoped by
        // variant so a dev-store sweep can never advance the real store's
        // mark (review round 1, MINOR).
        idleCommits = IdleCommitScheduler(
            database: session.database, runner: session.runner, storeVariant: storeVariant)
        if backupEnabled,
           let storeURL = try? AppDatabase.defaultStoreURL(variant: storeVariant) {
            // Backups live beside the store they copy — a dev store backs
            // up into the dev home (A4's separation holds here too).
            backup = StoreBackup(
                database: session.database,
                directory: storeURL.deletingLastPathComponent()
                    .appendingPathComponent("Backups", isDirectory: true))
        } else {
            backup = nil
        }
    }

    /// Launch: adopt persisted sessions (Keychain), wire sign-in state into
    /// sync + bridge, run the idempotent owner adoption when signed in,
    /// then the sweep and the backup clock.
    func start() async {
        await auth.setOnChange { [weak self] tokens in
            Task { @MainActor [weak self] in
                await self?.variorumSignInChanged(tokens)
            }
        }
        await fragmentsAuth.setOnChange { [weak self] tokens in
            Task { @MainActor [weak self] in
                await self?.fragmentsSignInChanged(tokens)
            }
        }
        // Persisted sessions from a previous launch.
        if let userID = await auth.currentUserID {
            account.variorum = AccountState.SignedIn(
                userID: userID, email: await auth.currentEmail)
            await connectSyncIfAllowed()
        }
        if let userID = await fragmentsAuth.currentUserID {
            account.fragments = AccountState.SignedIn(
                userID: userID, email: await fragmentsAuth.currentEmail)
            await connectBridgeIfAllowed(fragmentsUserID: userID)
        }
        idleCommits.start()
        backup?.start()
    }

    func stop() {
        sync.stop()
        bridge.stop()
        idleCommits.stop()
        backup?.stop()
    }

    /// THE LIFECYCLE CADENCE PULSE (the app's became-active hook; launch runs
    /// its own through the sign-in chains): one sync round, and — only when
    /// sync cannot deliver one — one bridge round directly.
    ///
    /// **A2 (Phase 13c) — the traced hole.** Bridge rounds ride
    /// `sync.onRoundCompleted` above, which is the ordering contract and
    /// stays exactly as it is (a landing sees the store the mirror sync just
    /// settled). But an UNCONFIGURED sync session completes no rounds at
    /// all, so in that state the bridge lost EVERY cadence trigger it has
    /// and ran exactly once per launch. That is not a corner: it is the
    /// state the author was in from 2026-07-20 to 07-25 (signed out of the
    /// Variorum project while the Fragments session stayed valid — her
    /// report was "the bridge doesn't seem to refresh often enough"), and it
    /// is equally reachable through an expired Variorum session or a failed
    /// owner adoption, since `connectSyncIfAllowed` returns before composing
    /// on either. The 9b plan's Step 5 names the bridge's cadence as
    /// "launch / became-active / post-write-settle"; this makes the
    /// became-active half hold when sync is off.
    ///
    /// When sync IS configured, behaviour is byte-identical to before — the
    /// bridge still follows the completed round and never interleaves with
    /// one. The fallback is a CADENCE trigger (never manual), so the 60 s
    /// throttle still guards the corpus hash sweep (QUESTIONS #15) against
    /// rapid app switching.
    func triggerLifecycleRound() {
        sync.triggerSync()
        if !sync.isConfigured { bridge.trigger() }
    }

    // MARK: - The Variorum sign-in (Phase 14a: direct — the identity)

    /// The direct suite sign-in (round 0h — "the 9c AuthSession password
    /// grant, re-aimed"): email+password against the Variorum project
    /// itself, the suite's account home. One door for Mac and mobile; the
    /// testable machinery lives in AuthSession — this method is the
    /// UI-facing composition.
    func signInWithVariorum(email: String, password: String) async {
        guard ProjectConfig.variorumConfigured else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        // The round-2 double-tap belt: the button disables on busy, but
        // two taps can both enqueue before the first sets it.
        guard !account.busy else { return }
        account.busy = true
        account.lastError = nil
        defer { account.busy = false }
        do {
            try await auth.signInWithPassword(email: email, password: password)
        } catch {
            // The R94 doctrine at the sign-in door (review round 1, R1-1):
            // classify and speak — a wrong password says so in words, never
            // as a raw enum dump.
            account.lastError = ErrorPresentation.signInFailureMessage(error)
        }
    }

    func signOutVariorum() async {
        await auth.signOut()
    }

    private func variorumSignInChanged(_ tokens: AuthTokens?) async {
        if let tokens {
            account.variorum = AccountState.SignedIn(
                userID: tokens.userID, email: tokens.email)
            // The paste-in's retirement completes at the first real
            // sign-in: the legacy Keychain item dies here (idempotent).
            LegacyPasteInCleanup.clear()
            await connectSyncIfAllowed()
        } else {
            account.variorum = nil
            sync.stop()
        }
    }

    /// Composes the authenticated sync chain (Step 2's seam over Step 1's
    /// session) and runs the Step 4 adoption first — idempotent, and the
    /// order matters: post-04-flip the mirror refuses unowned rows, so the
    /// backfill must precede the first push of any locally-minted rows.
    /// A FAILED adoption gates composition (review round 1, NIT):
    /// composing anyway would guarantee failing rounds post-flip until a
    /// relaunch — refusing with a visible message is the same §12 posture
    /// the engine itself takes (stall, never guess).
    private func connectSyncIfAllowed() async {
        guard sync.allowsSync else { return }
        guard await runOwnerAdoption() else { return }
        await sync.configure(transport: makeSyncTransport(auth))
        sync.triggerSync()
    }

    /// Step 4's backfill, at sign-in and at every signed-in launch:
    /// idempotent (NULL owners only), and self-healing for rows that
    /// arrived unowned from a not-yet-updated device. Failure surfaces on
    /// the account state; sign-out/in or a relaunch retries.
    private func runOwnerAdoption() async -> Bool {
        do {
            try await session.runner.run { ops in
                _ = try ops.adoptOwnerID()
            }
            return true
        } catch {
            account.lastError =
                "Owner adoption failed: \(error) — sync held; sign out and back in (or relaunch) to retry"
            return false
        }
    }

    // MARK: - The Fragments session (the bridge's — QUESTIONS #16 (c))

    /// The bridge's direct Fragments-project sign-in: her Fragments
    /// email+password once; only the session persists, never the password.
    func connectFragmentsJournal(email: String, password: String) async {
        guard ProjectConfig.fragmentsConfigured else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !account.busy else { return }  // the round-2 double-tap belt
        account.busy = true
        account.lastError = nil
        defer { account.busy = false }
        do {
            try await fragmentsAuth.signInWithPassword(email: email, password: password)
        } catch {
            // Same door class, same R94 treatment (R1-1): this form's
            // wrong-password refusal is the identical 400/invalid_grant.
            account.lastError = ErrorPresentation.signInFailureMessage(error)
        }
    }

    func disconnectFragmentsJournal() async {
        await fragmentsAuth.signOut()
    }

    private func fragmentsSignInChanged(_ tokens: AuthTokens?) async {
        if let tokens {
            account.fragments = AccountState.SignedIn(
                userID: tokens.userID, email: tokens.email)
            await connectBridgeIfAllowed(fragmentsUserID: tokens.userID)
        } else {
            account.fragments = nil
            bridge.stop()
        }
    }

    /// Composes the bridge engine over the Fragments session: the transport
    /// cross-checks the session's user against the configured one (the 9b
    /// round-2 guard), and the engine resolves the canonical user from
    /// `user_settings` each round with the fail-closed gate (9b's
    /// reconciled contract — nothing here guesses identity).
    private func connectBridgeIfAllowed(fragmentsUserID: String) async {
        guard bridge.allowsBridge else { return }
        let engine = BridgeEngine(
            transport: makeBridgeTransport(fragmentsAuth, fragmentsUserID),
            configuration: FragmentsBridgeConfiguration(userID: fragmentsUserID))
        await bridge.configure(engine: engine)
        bridge.trigger(manual: true)
    }
}
