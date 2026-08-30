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
    /// Phase 14c (the deletion door): the best-effort subscription note —
    /// non-nil when the account holds an active entitlement row (the
    /// phase's stand-in; the checkout owns the real cancellation flow).
    /// The door's STATIC cancel-first advisory shows regardless; this
    /// line only strengthens it when the read succeeds. Batch 3 (B2-3
    /// promoted): DERIVED from `hostedSync` — one read, one truth.
    var subscriptionNote: String?
    /// Phase 14c batch 3 (L7, B2-3's real home): the tier standing as
    /// last read. `.unknown` until a read succeeds; a FAILED read leaves
    /// it untouched — quiet, never an error face (reads-as-normal).
    var hostedSync: HostedSyncStatus = .unknown
    /// Phase 14c batch 3 (L8): the sign-up flow's informational line —
    /// a NOTICE, never an error (the confirmation-email road is a normal
    /// outcome, not a failure). Cleared on sign-in and on the next act.
    var lastNotice: String?

    /// The confirmation-required outcome's words (pinned). Worded to stay
    /// TRUE under GoTrue's enumeration prevention: an already-registered
    /// email gets the same session-less 200 (a sanitized user body) and
    /// NO email is actually sent — the client cannot distinguish, so the
    /// notice covers both roads honestly without revealing which one this
    /// address took.
    static let confirmationNotice =
        "Check your email for a confirmation link, then sign in here. If this address "
        + "already has an account, no email arrives — sign in with its existing password "
        + "instead."
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
    /// The E2EE flows' state + doors (Phase 14b batch 3, L9) — one seam for
    /// Mac and phone, exactly like the account surface.
    let encryption: EncryptionSession
    /// The vault client the encryption flows AND the 14c account doors
    /// share (nil = unconfigured project; every door stays dormant).
    let keyVault: KeyVaultClient?
    let account = AccountState()

    /// The app session (store + runner) the services compose over —
    /// internal so the wiring tests can drive the production runner path.
    let session: AppSession

    /// 13j ladder B (B3): the LOCAL purge cadence — launch + hourly, each
    /// tick a no-op while sync is configured (`AppSession.sweepLocalPurge`
    /// gates itself). The transported janitor rides sync rounds; this is
    /// the never-signed-in install's only clock, riding the same rhythm the
    /// idle-commit sweep uses.
    private var localPurgeTask: Task<Void, Never>?

    /// Injectable transport composition (review round 1, MINOR: without
    /// the seam, the wiring tests fired real network requests at the
    /// production project URL — breaking the repo-wide no-network test
    /// discipline). Defaults compose the ProjectConfig production
    /// transports; tests inject recording fakes, which also turns the
    /// fence/wiring assertions into COMPOSITION checks, not network luck.
    private let makeSyncTransport: (any UserSessionProviding) -> any SyncTransport
    private let makeBridgeTransport:
        (any UserSessionProviding, _ expectedUserID: String) -> any FragmentsBridgeTransport
    /// The engine's E2EE key seam (Phase 14b batch 3 — batch 2's
    /// PROVISIONAL 2 resolved at THIS construction site): production is the
    /// Keychain-backed provider (enrollment-only cadence, R-6); tests
    /// inject fixed/locked providers so wiring pins never touch the real
    /// Keychain.
    private let makeSyncKeyProvider: () -> any SyncKeyProviding
    /// The BRIDGE's journal-class key seam (Phase 14b, gate-morning GM-2).
    /// **THE PAUSE ENDED AT 14D (2026-08-16, the deliberate act):** the
    /// Mac's production composition (VariorumApp) wires
    /// `DeviceBridgeKeyProvider` here, so bridge rounds run against
    /// Keychain custody; an unenrolled or locked device still refuses
    /// before network contact (the provider reads no keys). nil now means
    /// only the engine's refusing default (`UnenrolledBridgeKeyProvider`)
    /// — held by tests that model the keyless state and by the phone's
    /// composition (bridge disabled there; Phase 9b's Mac-side scope).
    /// History: production passed nil from 14b's gate morning through
    /// 14c — the RULED structural pause while the Fragments handoff waited.
    private let makeBridgeKeyProvider: (() -> any BridgeKeyProviding)?
    /// Phase 14c: the account lifecycle doors' server seam (the re-key's
    /// truncate, the deletion's purge, the entitlement read). Tests inject
    /// recording fakes; production composes the real client over the same
    /// session the sync transport rides.
    private let makeAccountLifecycle: (any UserSessionProviding) -> any AccountLifecycleProviding

    init(
        session: AppSession, storeVariant: AppDatabase.StoreVariant,
        backupEnabled: Bool, backupRunbookText: String? = nil,
        bridgeEnabled: Bool = false,
        auth: AuthSession? = nil, fragmentsAuth: AuthSession? = nil,
        encryption: EncryptionSession? = nil,
        bridgeMinimumRoundInterval: Duration = .seconds(60),
        makeSyncTransport: ((any UserSessionProviding) -> any SyncTransport)? = nil,
        makeBridgeTransport: ((any UserSessionProviding, String) -> any FragmentsBridgeTransport)? = nil,
        makeSyncKeyProvider: (() -> any SyncKeyProviding)? = nil,
        makeBridgeKeyProvider: (() -> any BridgeKeyProviding)? = nil,
        keyVault: KeyVaultClient? = nil,
        makeAccountLifecycle: ((any UserSessionProviding) -> any AccountLifecycleProviding)? = nil
    ) {
        self.session = session
        self.makeBridgeKeyProvider = makeBridgeKeyProvider
        self.makeAccountLifecycle = makeAccountLifecycle ?? { provider in
            AccountLifecycleClient(
                configuration: ProjectConfig.variorumTransport,
                sessionProvider: provider)
        }
        self.makeSyncTransport = makeSyncTransport ?? { provider in
            SupabaseTransport(
                configuration: ProjectConfig.variorumTransport,
                sessionProvider: provider)
        }
        self.makeSyncKeyProvider = makeSyncKeyProvider ?? { DeviceKeySyncProvider() }
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
        // 13j ladder B (B3): the purge doors' receipts and the local purge
        // road both read this — one truth, the sync session's own.
        session.syncConfigured = { [weak sync = sync] in sync?.isConfigured ?? false }
        // THE A4 FENCE EXTENDS TO THE BRIDGE (Phase 9b): the author's live
        // Fragments journal pairs with the REAL store only.
        bridge = BridgeSession(
            allowsBridge: bridgeEnabled && storeVariant == .real,
            minimumRoundInterval: bridgeMinimumRoundInterval)
        self.auth = auth ?? AuthSession(configuration: ProjectConfig.variorumAuth)
        self.fragmentsAuth = fragmentsAuth ?? AuthSession(
            configuration: ProjectConfig.fragmentsAuth,
            store: .keychain(service: KeychainAuthStorage.fragmentsService))
        // The E2EE flows compose over the SAME auth session the sync
        // transport rides — the vault lives on the account (R-1). One
        // vault client serves the flows AND the 14c account doors.
        let authSession = self.auth
        let vaultClient = keyVault ?? (ProjectConfig.variorumConfigured
            ? KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: ProjectConfig.variorumProjectURL,
                    apiKey: ProjectConfig.variorumPublishableKey),
                sessionProvider: authSession)
            : nil)
        self.keyVault = vaultClient
        self.encryption = encryption ?? EncryptionSession(
            store: .keychain(),
            client: vaultClient,
            signedIn: { await authSession.currentUserID != nil })
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
                    .appendingPathComponent("Backups", isDirectory: true),
                // 13l Act 4: the recipe that rides beside the copies. The
                // words are the Mac's (`DataSafetyCopy`), handed to shared
                // machinery — see StoreBackup.Configuration.runbookText.
                configuration: StoreBackup.Configuration(
                    runbookText: backupRunbookText,
                    // 13p: the wraps sidecar rides into every backup folder
                    // (the new-machine passphrase/recovery restore legs).
                    keyEnvelopeSourceURL: StoreKeyEnvelope.url(besideStore: storeURL)))
        } else {
            backup = nil
        }
    }

    /// Launch: adopt persisted sessions (Keychain), wire sign-in state into
    /// sync + bridge, run the idempotent owner adoption when signed in,
    /// then the sweep and the backup clock.
    func start() async {
        // Enrollment/setup landing keys heals the engine's keys-refusal
        // immediately (Phase 14b): one round, through the ordinary trigger.
        encryption.onKeysChanged = { [weak self] in
            self?.sync.triggerSync()
        }
        // Phase 14c (CF-8): the re-key door's runner — the AccountRekey
        // brain with the sync chain paused around it (no scheduler may
        // race the truncate/reinit window; the reconnect afterwards is
        // the ordinary sign-in composition, which also starts the drain).
        if keyVault != nil {
            encryption.rekeyRunner = { [weak self] passphrase in
                guard let self else { throw CancellationError() }
                return try await self.runAccountRekey(passphrase: passphrase)
            }
            // Ladder R1-1: the persisted marker's surface read —
            // refresh() projects the rerun prompt from it (the engine's
            // own rounds refuse on the same `sync_state` key).
            encryption.rekeyIncompleteCheck = { [database = session.database] in
                (try? await database.read { try AccountRekeyMarker.isSet($0) }) ?? false
            }
        }
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
        // 13j ladder B (B3): the local purge cadence — see the property.
        localPurgeTask?.cancel()
        localPurgeTask = Task { [weak session = session] in
            while !Task.isCancelled {
                await session?.sweepLocalPurge()
                do { try await Task.sleep(for: .seconds(60 * 60)) } catch { return }
            }
        }
    }

    func stop() {
        sync.stop()
        bridge.stop()
        idleCommits.stop()
        backup?.stop()
        localPurgeTask?.cancel()
        localPurgeTask = nil
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

    /// Phase 14c batch 3 (L8, THE DESIGN 6): account creation through the
    /// SAME seam as sign-in — email+password against the suite issuer.
    /// While the signups toggle is OFF (the corpus guard, flipped only as
    /// the gate's deliberate act), the server refuses and this surface
    /// speaks that refusal honestly (`signUpFailureMessage`'s closed
    /// arm). Two success shapes: autoconfirm signs straight in (the
    /// onChange wiring composes sync; the empty-store first pull reads as
    /// normal); confirmation-required posts the notice and sign-in
    /// completes after her email link.
    func signUpWithVariorum(email: String, password: String) async {
        guard ProjectConfig.variorumConfigured else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !account.busy else { return }  // the double-tap belt
        account.busy = true
        account.lastError = nil
        account.lastNotice = nil
        defer { account.busy = false }
        do {
            switch try await auth.signUp(email: email, password: password) {
            case .signedIn:
                break  // the onChange road takes it from here
            case .confirmationRequired:
                account.lastNotice = AccountState.confirmationNotice
            }
        } catch {
            account.lastError = ErrorPresentation.signUpFailureMessage(error)
        }
    }

    func signOutVariorum() async {
        await auth.signOut()
    }

    private func variorumSignInChanged(_ tokens: AuthTokens?) async {
        if let tokens {
            account.variorum = AccountState.SignedIn(
                userID: tokens.userID, email: tokens.email)
            account.lastNotice = nil  // the sign-up notice's job is done
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
        await sync.configure(
            transport: makeSyncTransport(auth), keyProvider: makeSyncKeyProvider())
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

    // MARK: - The account lifecycle doors (Phase 14c batch 2 — CF-8 + deletion)

    /// CF-8's runner (the EncryptionSession door calls this through the
    /// injected closure): the sync chain STOPS for the whole road — a
    /// scheduler round racing the truncate/reinit window would push
    /// against a half-re-keyed account — and the ordinary sign-in
    /// composition reconnects afterwards, success or failure (the failed
    /// arm's chain refuses at the fence until the rerun, visibly).
    private func runAccountRekey(passphrase: String) async throws -> DeviceKeyMaterial {
        guard let keyVault else { throw CancellationError() }
        sync.stop()
        let brain = AccountRekey(
            client: keyVault,
            lifecycle: makeAccountLifecycle(auth),
            transport: makeSyncTransport(auth),
            database: session.database,
            onNewVaultMaterial: { material in
                // The brain AWAITS this before its truncate — custody
                // must land before this device's rounds resume. STRONG
                // capture, deliberately (ladder R1-4): a weak self here
                // would let a gone AppServices complete this closure
                // WITHOUT adopting, and the brain would truncate with the
                // device stale against its own new vault. The closure
                // lives only for the run (the brain is a local), so the
                // strong reference makes the adopt-before-truncate
                // contract structural at zero cycle risk.
                // 13e batch 9 (B-1): `adoptRekeyedMaterial` is async now
                // (its Keychain write hops off the main thread), so the
                // hop to the MainActor is the call itself — and the await
                // still covers the whole adoption, which is what the
                // adopt-before-truncate contract needs.
                await self.encryption.adoptRekeyedMaterial(material)
            })
        do {
            let material = try await brain.run(passphrase: passphrase)
            await connectSyncIfAllowed()
            return material
        } catch {
            await connectSyncIfAllowed()
            throw error
        }
    }

    /// The deletion door (THE DESIGN 4, her Round-5 ruling): purge the
    /// account server-side (passphrase-authorized in the brain; the typed
    /// confirmation is the surface's), then the LOCAL after-acts — device
    /// custody cleared through the CF-11 forget machinery, then sign-out.
    /// The local STORE is deliberately untouched: the local copy
    /// survives, exactly her pinned rule, and the signed-out state reads
    /// as normal (the standing v1 principle).
    func deleteAccount(passphrase: String?) async {
        guard let keyVault else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !account.busy else { return }
        account.busy = true
        account.lastError = nil
        defer { account.busy = false }
        sync.stop()
        do {
            let deletion = AccountDeletion(
                client: keyVault, lifecycle: makeAccountLifecycle(auth))
            _ = try await deletion.run(passphrase: passphrase)
            // Ladder R1-1: a purged account owes no re-key completion —
            // clear the persisted marker so a future sign-in on this
            // store isn't refused for a road that no longer exists.
            try? await session.database.write { try AccountRekeyMarker.clear($0) }
            // Server side is gone; now the device's custody (CF-11's
            // machinery — the vault it unlocked no longer exists), then
            // the session (sign-out tears the sync chain down through the
            // ordinary onChange road).
            await encryption.forgetDeviceKeys()
            await auth.signOut()
        } catch {
            account.lastError = EncryptionSession.message(for: error)
            // The account survives a refused deletion — reconnect the
            // chain the door paused.
            await connectSyncIfAllowed()
        }
    }

    /// Phase 14c batch 3 (L7 — B2-3 promoted into its real home): the ONE
    /// entitlement read, feeding `AccountState.hostedSync` for the
    /// Account tab's tier section AND the deletion door's note below.
    /// The P-ii pattern (plain authenticated read of the account's own
    /// row); a FAILED read changes nothing — `.unknown` renders nothing
    /// and the surfaces stay quiet (reads-as-normal; when the server
    /// actually refuses a round, the sync row's tier line narrates).
    func refreshHostedSyncStatus() async {
        guard keyVault != nil else { return }  // unconfigured stays dormant
        let lifecycle = makeAccountLifecycle(auth)
        guard let entitlements = try? await lifecycle.fetchEntitlements() else { return }
        let active = entitlements.first { entitlement in
            entitlement.feature == HostedSyncTier.feature
                && HostedSyncTier.isCurrent(entitlement)
        }
        account.hostedSync = active.map { .active(expiresAt: $0.expiresAt) } ?? .inactive
    }

    /// The deletion door's best-effort subscription check — since batch 3
    /// a DERIVATION over the promoted read above (one read, one truth): a
    /// non-nil note strengthens the static cancel-first advisory. A
    /// failed read stays nil — the static advisory shows regardless.
    /// (Keys on the tier's ONE feature by design; a future second feature
    /// re-opens this derivation, recorded.)
    func refreshSubscriptionNote() async {
        account.subscriptionNote = nil
        await refreshHostedSyncStatus()
        if case .active = account.hostedSync {
            account.subscriptionNote =
                "This account has an active hosted-sync plan — cancel it first."
        }
    }

    // MARK: - The Fragments session (the bridge's — QUESTIONS #16 (c))

    // (The direct Fragments email+password door — `connectFragmentsJournal`
    // — was REMOVED at 14d: the batch retired her Fragments password
    // server-side (provider off, the grant 422s), so the door could only
    // ever refuse. The delegated road below is the one Fragments sign-in.)

    /// The DELEGATED road (Phase 14d — the door back in, her ruling at the
    /// kickoff sitting: "there should not be some kind of session
    /// dependency"): sign into the FRAGMENTS project through the suite
    /// issuer's provider entry (`custom:stargazing`, touchpoint #1) via
    /// the browser flow. One interactive flow per device; afterwards the
    /// same persisted-session + refresh loop as the password door — which
    /// touchpoint #1 retires, making this the ONLY road back in.
    func connectFragmentsJournalDelegated() async {
        guard ProjectConfig.fragmentsConfigured else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !account.busy else { return }
        account.busy = true
        account.lastError = nil
        defer { account.busy = false }
        do {
            let verifier = PKCE.generateVerifier()
            let authorizeURL = fragmentsAuth.authorizeURL(
                verifier: verifier,
                providerSlug: ProjectConfig.fragmentsSuiteProviderSlug,
                redirectURI: ProjectConfig.fragmentsBridgeRedirectURI)
            let scheme = URL(string: ProjectConfig.fragmentsBridgeRedirectURI)!.scheme!
            let callback = try await SignInFlow().run(
                authorizeURL: authorizeURL, callbackScheme: scheme)
            try await fragmentsAuth.handleCallback(callback, verifier: verifier)
        } catch SignInFlow.FlowError.cancelled {
            // A closed browser sheet is a decision, not an error.
        } catch {
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
            configuration: FragmentsBridgeConfiguration(userID: fragmentsUserID),
            // nil ⇒ the engine's refusing default. Through 14b–14c this
            // WAS the ruled structural pause (GM-2); since the 14d
            // un-pause production always passes the live provider, so
            // nil here means a test composition or a keyless state.
            keyProvider: makeBridgeKeyProvider?() ?? UnenrolledBridgeKeyProvider())
        await bridge.configure(engine: engine)
        bridge.trigger(manual: true)
    }
}
