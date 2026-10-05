//
//  AppServices.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8: the session-scoped background services both apps start after a
//  successful store open — sync lifecycle (Step 6), the idle auto-commit
//  sweep (Step 5), and (where enabled) rotating store backups (A1).
//  Composition-root property, injected downward; no globals.
//
//  Phase 9c, Step 5 — the sign-in era: AppServices owns the Variorum auth
//  session (the identity everything keys on) and wires sign-in state into
//  everything downstream: the owner-adoption backfill runs at sign-in and
//  at every signed-in launch (idempotent — Step 4), the sync chain is
//  composed over the AuthSession session provider (Step 2's seam), and
//  sign-out tears the chain down. The Phase 8 paste-in is fully retired;
//  its Keychain item is cleared on the first real sign-in.
//
//  Phase 14a, batch 1 — the Variorum sign-in goes DIRECT (round 0h): the
//  suite email+password drives the password grant against the Variorum
//  project itself; the delegated browser flow is retired from this file.
//
//  2026-09-04 — THE FRAGMENTS BRIDGE RETIRED (pre-13x batch 0b; archived at
//  tag `archive/fragments-bridge-2026-09-04`, `notes/archive/fragments-bridge.md`):
//  the second auth session (the bridge's Fragments-project session), the
//  bridge engine's composition, its key-provider seam and its round trigger
//  all left this file. One session, one chain.
//

import Dependencies  // the T1 probe's database binding (Act 10 wave 2a)
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
    let idleCommits: IdleCommitScheduler
    /// Rotating cold copies (A1). Wired on the Mac; nil on iOS — the
    /// phone's store is re-derivable from the mirror.
    let backup: StoreBackup?
    /// The Variorum-project session (the suite account, signed in direct —
    /// Phase 14a round 0h): the identity `owner_id` and the mirror's RLS
    /// key on.
    let auth: AuthSession
    /// The E2EE flows' state + doors (Phase 14b batch 3, L9) — one seam for
    /// Mac and phone, exactly like the account surface.
    let encryption: EncryptionSession
    /// The vault client the encryption flows AND the 14c account doors
    /// share (nil = unconfigured project; every door stays dormant).
    let keyVault: KeyVaultClient?
    /// pre-13x 5b (ledger 64): the store variant these services serve — the
    /// iCloud Drive offer's mark is scoped by it (a dev-store offer never
    /// suppresses the real store's).
    let storeVariant: AppDatabase.StoreVariant
    let account = AccountState()

    /// The app session (store + runner) the services compose over —
    /// internal so the wiring tests can drive the production runner path.
    let session: AppSession
    /// The retired-credential sweep (`LegacyPasteInCleanup.clear` in
    /// production; a spy in the wiring pins): runs at every REAL-STORE
    /// `start()` and every REAL-STORE sign-in, off-main, through the ONE
    /// private `runRetiredCredentialSweep()` (pre-13x batch 1a — the bridge
    /// retirement's round-3 finding 1: the sign-in occasion used to run
    /// bare on the MainActor and ungated, so a dev-store sign-in reached
    /// the login keychain the launch gate exists to fence). REQUIRED at
    /// this seam so every composition site decides (finding 2 — the
    /// `makeSyncKeyProvider` precedent): no test world can reach the login
    /// keychain by a defaulted argument.
    private let legacyCleanup: @Sendable () -> Void

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
    /// The engine's E2EE key seam (Phase 14b batch 3 — batch 2's
    /// PROVISIONAL 2 resolved at THIS construction site): production is the
    /// Keychain-backed provider (enrollment-only cadence, R-6); tests
    /// inject fixed/locked providers so wiring pins never touch the real
    /// Keychain.
    private let makeSyncKeyProvider: () -> any SyncKeyProviding
    /// Phase 14c: the account lifecycle doors' server seam (the re-key's
    /// truncate, the deletion's purge, the entitlement read). Tests inject
    /// recording fakes; production composes the real client over the same
    /// session the sync transport rides.
    private let makeAccountLifecycle: (any UserSessionProviding) -> any AccountLifecycleProviding
    /// 17y B-DEDUPE (R-17y-5): the seeded-furniture fold's facts for this
    /// PLATFORM — the shared half by default; the Mac's construction site
    /// appends the guide's half (`TutorialSeeder.furnitureFactsHalf()`).
    private let furnitureFacts: SeededFurnitureDedupeFacts

    init(
        session: AppSession, storeVariant: AppDatabase.StoreVariant,
        backupEnabled: Bool, backupRunbookText: String? = nil,
        auth: AuthSession? = nil,
        encryption: EncryptionSession? = nil,
        makeSyncTransport: ((any UserSessionProviding) -> any SyncTransport)? = nil,
        makeSyncKeyProvider: (() -> any SyncKeyProviding)? = nil,
        keyVault: KeyVaultClient? = nil,
        makeAccountLifecycle: ((any UserSessionProviding) -> any AccountLifecycleProviding)? = nil,
        furnitureFacts: SeededFurnitureDedupeFacts? = nil,
        legacyCleanup: @escaping @Sendable () -> Void
    ) {
        self.session = session
        self.legacyCleanup = legacyCleanup
        self.furnitureFacts = furnitureFacts ?? SampleLibrarySeeder.furnitureDedupeFacts()
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
        // pre-13x 1a: ONE per-store custody store (the key file's id beside
        // the store; the shape from its dials; the session shared with the
        // bootstrap's relock) serves the E2EE flows AND the engine's key
        // provider — the same custody by construction.
        let keyStore = DeviceKeyStore.keychain(
            scope: storeVariant.rawValue,
            storeURL: try? AppDatabase.defaultStoreURL(variant: storeVariant))
        self.makeSyncKeyProvider = makeSyncKeyProvider ?? { DeviceKeySyncProvider(store: keyStore) }
        // THE A4 FENCE, SYNC SEAM (Phase 8 review round 1, BLOCKER): only
        // the REAL store may pair with the one production mirror. Debug and
        // release builds share a bundle identity and Keychain, so a
        // dev-store session must never adopt the signed-in session for
        // syncing — a dev bug's writes would push to the mirror and
        // replicate to her real devices. (The Debug build's bundle identity
        // is `io.lduarte.Variorum.debug`, the installed Release build's
        // `io.lduarte.Variorum` — they share the machine's LOGIN KEYCHAIN,
        // not an identity; the retirement's round-2 N1 corrected this
        // comment's old "share a bundle identity" wording.)
        sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)
        // 13j ladder B (B3): the purge doors' receipts and the local purge
        // road both read this — one truth, the sync session's own.
        session.syncConfigured = { [weak sync = sync] in sync?.isConfigured ?? false }
        // pre-13x 2c (corner 47): the session's Keychain item is SCOPED by
        // store variant — a dev-store build starts signed out and never
        // adopts the installed build's session.
        self.auth = auth ?? AuthSession(
            configuration: ProjectConfig.variorumAuth,
            store: .keychain(scope: storeVariant.rawValue))
        // The E2EE flows compose over the SAME auth session the sync
        // transport rides — the vault lives on the account (R-1). One
        // vault client serves the flows AND the 14c account doors.
        let authSession = self.auth
        let vaultClient = keyVault ?? (ProjectConfig.variorumConfigured
            ? KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: ProjectConfig.variorumProjectURL,
                    apiKey: ProjectConfig.variorumPublishableKey,
                    // pre-13x 2c (decision 34): every vault write names THIS
                    // device — its own name, never an id.
                    deviceName: DeviceName.current),
                sessionProvider: authSession)
            : nil)
        self.keyVault = vaultClient
        self.storeVariant = storeVariant
        self.encryption = encryption ?? EncryptionSession(
            store: keyStore,
            client: vaultClient,
            signedIn: { await authSession.currentUserID != nil })
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
                    // 13p: the wraps key file rides into every backup folder
                    // (the new-machine passphrase/recovery restore legs);
                    // pre-13x 1a: located beside the STORE at run time.
                    keyEnvelopeStoreURL: storeURL))
        } else {
            backup = nil
        }
    }

    /// Launch: adopt the persisted session (Keychain), wire sign-in state
    /// into sync, run the idempotent owner adoption when signed in, then
    /// the sweep and the backup clock.
    func start() async {
        // Enrollment/setup landing keys heals the engine's keys-refusal
        // immediately (Phase 14b): one round, through the ordinary trigger.
        encryption.onKeysChanged = { [weak self] in
            self?.sync.triggerSync()
        }
        // pre-13x 2b: the re-key door's runner is the composition ROOT's
        // (`PostureSwitchRunner` — it needs the bootstrap's re-key road and
        // the protection controller, which this type does not hold; the
        // root wires `encryption.replaceKeysDoor` after building it — pre-13x 3b). The 14c
        // `AccountRekey` brain and the T1 recency probe's caller retired
        // with the truncate road. What stays here: the persisted marker's
        // surface read — refresh() projects the resume prompt from it (the
        // engine's own rounds refuse on the same `sync_state` key).
        if keyVault != nil {
            encryption.rekeyIncompleteCheck = { [database = session.database] in
                (try? await database.read { try RotationMarker.isSet($0) }) ?? false
            }
        }
        await auth.setOnChange { [weak self] tokens in
            Task { @MainActor [weak self] in
                await self?.variorumSignInChanged(tokens)
            }
        }
        // The retired-credential sweep, every start (the launch occasion —
        // a persisted session adopted below never routes through
        // `variorumSignInChanged`, so without this the bridge's retired
        // Fragments-project item would outlive every launch of a user who
        // never signs out again; round-1 MINOR-1). The gate and the
        // off-main hop live in the one sweep function.
        runRetiredCredentialSweep()
        // The persisted session from a previous launch.
        if let userID = await auth.currentUserID {
            account.variorum = AccountState.SignedIn(
                userID: userID, email: await auth.currentEmail)
            await connectSyncIfAllowed()
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
        idleCommits.stop()
        backup?.stop()
        localPurgeTask?.cancel()
        localPurgeTask = nil
    }

    /// THE ONE retired-credential sweep road (pre-13x batch 1a — the bridge
    /// retirement's round-3 finding 1), serving BOTH occasions: every
    /// `start()` and every sign-in. REAL STORE ONLY (round-2 N1): a
    /// dev-store session — Xcode Run, the test host — shares the machine's
    /// login keychain with the installed Release build under a different
    /// bundle identity, and the retired item there is the INSTALLED build's;
    /// the A4 fence's own seam gates it (`sync.allowsSync` IS
    /// `storeVariant == .real`). OFF-MAIN always (the 13e class: no
    /// synchronous Keychain call ever runs on the main thread — the two
    /// `SecItemDelete`s ride a detached utility task).
    private func runRetiredCredentialSweep() {
        guard sync.allowsSync else { return }
        Task.detached(priority: .utility) { [legacyCleanup] in legacyCleanup() }
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

    /// pre-13x 3b (decision 20; copy §4): SIGN OUT EVERYWHERE — every session
    /// of the account revoked (`scope=global`), this one included; the keys
    /// in custody untouched (the local clear is the ordinary sign-out's).
    func signOutEverywhere() async {
        await auth.signOut(scope: .global)
    }

    private func variorumSignInChanged(_ tokens: AuthTokens?) async {
        if let tokens {
            account.variorum = AccountState.SignedIn(
                userID: tokens.userID, email: tokens.email)
            account.lastNotice = nil  // the sign-up notice's job is done
            // The paste-in's retirement completes at the first real
            // sign-in: the legacy Keychain items die here (idempotent; the
            // same sweep also runs at every start — see the seam's doc).
            // The SAME gated, off-main road as the launch occasion (pre-13x
            // 1a): never bare on the MainActor, never on a dev store.
            runRetiredCredentialSweep()
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
            transport: makeSyncTransport(auth), keyProvider: makeSyncKeyProvider(),
            furnitureFacts: furnitureFacts)
        sync.triggerSync()
    }

    /// pre-13x ladder round 1, F2 (MAJOR-1): THE CEREMONIES' RESUME LEAF
    /// (`PostureSwitchRunner.Leaves.resumeSync` in production). The
    /// ceremonies pause the chain with `sync.stop()` — the scheduler
    /// retired — so a resume must RECONNECT it (`connectSyncIfAllowed`'s
    /// shape, `deleteAccount`'s own refusal road) rather than trigger a
    /// round on a session that has nothing to run one with. When the chain
    /// is already live — the re-key's reopen rebuilt these services and
    /// `start()` connected them — a bare trigger is all that is owed; a
    /// second `configure` would only drain and replace a working chain.
    /// Before F2 the leaf was `sync.triggerSync()`: a no-op after `stop()`,
    /// so every refusal before the reopen left sync dead for the session.
    func resumeSync() async {
        if sync.isConfigured {
            sync.triggerSync()
        } else {
            await connectSyncIfAllowed()
        }
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

    // MARK: - pre-13x 3a: THE ADOPT ROAD (decision 17; §3.6; corner 29/31)

    /// CONNECT (copy §3's *Connect…*): a library that last synced under
    /// ANOTHER account — a deleted-then-recreated account, a library moved
    /// between accounts — joins THIS one. The typed passphrase or words
    /// unwrap this account's master (a wrong word refuses before anything
    /// is written); then `adoptLibrary` re-stamps every owner-carrying row
    /// and re-initializes sync; custody and the key file land through the
    /// session's adopt; sync resumes and the WHOLE library uploads into
    /// this account's partition (corpus-shaped, once — P1's letter; the
    /// 14c `(owner_id, id)` keys let the same ids under X and Y coexist).
    /// NO `resyncReinitialize` for a same-owner rotated account — that is
    /// the follow (§7), never this door.
    func connectLibrary(passphrase: String?, recoveryWords: [String]?) async throws {
        guard let keyVault else { throw ConnectLibraryError.unconfigured }
        guard let userID = await auth.currentUserID else { throw ConnectLibraryError.signedOut }
        let enrollment = VaultEnrollment(client: keyVault)
        let material: DeviceKeyMaterial
        if let passphrase, !passphrase.isEmpty {
            material = try await enrollment.enroll(passphrase: passphrase)
        } else if let recoveryWords, !recoveryWords.isEmpty {
            material = try await enrollment.enroll(recoveryWords: recoveryWords)
        } else {
            throw PostureSwitchError.secretRequired
        }
        guard let fetched = try await keyVault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
        try await adoptLibrary(into: userID)
        _ = await encryption.adoptEnrolledMaterial(
            material, kdf: fetched.format.kdf, recoveryWrapDigest: fetched.format.recoveryWrapDigest,
            typedPassphrase: passphrase, typedWords: recoveryWords)
        await connectSyncIfAllowed()
    }

    /// The adopt's two writes, shared by Connect and by sync SETUP over a
    /// foreign-stamped library (copy §2a's *Move It to This Account*): the
    /// sync chain stopped; every owner-carrying row re-stamped to the
    /// signed-in id in ONE transaction (`Operations.restampOwner`); the
    /// engine's `resyncReinitialize` (`sync_version` → 0, `sync_row_seq`
    /// cleared, the cursor cleared, every row enqueued). The caller
    /// reconnects the chain.
    func adoptLibrary(into userID: String) async throws {
        sync.stop()
        try await session.runner.run { ops in
            _ = try ops.restampOwner(to: userID)
        }
        let engine = SyncEngine(transport: makeSyncTransport(auth), keyProvider: makeSyncKeyProvider())
        let database = session.database
        try await withDependencies { $0.database = database } operation: {
            try await engine.resyncReinitialize()
        }
    }

    /// SYNC SETUP over a foreign-stamped library (copy §2a's *Move It to
    /// This Account*): the same two writes right after the create — the
    /// material was just minted, so no enroll — then the chain reconnects.
    func adoptLibraryAfterSetup() async throws {
        guard let userID = await auth.currentUserID else { throw ConnectLibraryError.signedOut }
        try await adoptLibrary(into: userID)
        await connectSyncIfAllowed()
    }

    /// The signed-in library's owner verdict, read for the setup ceremony's
    /// pre-Screen-1 confirm (copy §2a): true when ANY owner-carrying row was
    /// stamped by another account (`Queries.foreignOwnerExists`).
    func libraryOwnerIsForeign() async -> Bool {
        guard let userID = await auth.currentUserID else { return false }
        let database = session.database
        return (try? await database.read { try Queries.foreignOwnerExists($0, signedIn: userID) }) ?? false
    }

    // MARK: - The account lifecycle doors (Phase 14c batch 2 — deletion;
    // the CF-8 re-key's composition moved to the root at pre-13x 2b)

    /// The deletion door (pre-13x 3b — decision 16; copy §4): the ACCOUNT
    /// password typed and verified by a fresh re-authentication (the grant's
    /// pair discarded and revoked), the typed phrase being the surface's;
    /// then the purge (`AccountDeletion` — the session alone authorizes the
    /// server act; the vault dies whole); then the LOCAL after-acts: the
    /// persisted marker cleared, sign-out. **Custody is KEPT** (copy §4:
    /// *every library stays, and still opens exactly as it does today* —
    /// the keys sit dead server-side; A stays in iCloud; a later account
    /// adopts the library at setup). The local STORE is untouched.
    func deleteAccount(accountPassword: String) async {
        guard keyVault != nil else {
            account.lastError = "Project keys not configured (ProjectConfig.swift)"
            return
        }
        guard !account.busy else { return }
        account.busy = true
        account.lastError = nil
        defer { account.busy = false }
        sync.stop()
        do {
            guard try await auth.verifyPassword(accountPassword) else {
                account.lastError = ProtectionCopy.deleteAccountWrongPassword
                await connectSyncIfAllowed()
                return
            }
            let deletion = AccountDeletion(lifecycle: makeAccountLifecycle(auth))
            _ = try await deletion.run()
            // Ladder R1-1: a purged account owes no re-key completion —
            // clear the persisted marker so a future sign-in on this
            // store isn't refused for a road that no longer exists.
            try? await session.database.write { try RotationMarker.clear($0) }
            // The server side is gone; custody STAYS (decision 16 / copy §4);
            // the session goes (sign-out tears the sync chain down through
            // the ordinary onChange road).
            await auth.signOut()
        } catch {
            account.lastError = error is URLError
                ? "Couldn't reach the server — check your connection and try again."
                : EncryptionSession.message(for: error)
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
}

/// pre-13x 3a: the Connect door's own refusals (worded by
/// `EncryptionSession.message(for:)`'s describing arm).
nonisolated enum ConnectLibraryError: Error, Equatable, Sendable, CustomStringConvertible {
    case unconfigured
    case signedOut
    var description: String {
        switch self {
        case .unconfigured: return "Project keys not configured (ProjectConfig.swift)"
        case .signedOut: return "sign in first"
        }
    }
}
