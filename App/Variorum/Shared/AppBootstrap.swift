//
//  AppBootstrap.swift
//  Variorum (shared: Mac + Mobile)
//
//  The recoverable database open (resolves the KnownIssues
//  "AppDatabase.liveValue failure UX" entry): open explicitly through the
//  typed path, render failure as a recovery surface, and only wire the live
//  dependency on success. The package's fatalError fallback is never reached
//  from the app.
//
//  Phase 8, A4 (dev-store separation): the bootstrap opens the variant
//  `StoreLocation.resolve()` picks — debug builds default to the SEPARATE
//  dev store; the author's real corpus is opened from a debug build only
//  via the explicit opt-in. Both paths flow through the same recoverable
//  `openStore(at:)`.
//
//  Phase 13p, Batch 2 — THE LOCKED LOBBY (R13p-5, THE DESIGN's keyed-stack
//  paragraph). The launch ROUTES before any store open: under the demanded
//  at-open modes it stops at `.locked(StoreLobby)` — no store, no
//  migration, no session, no services (everything downstream exists only
//  inside `.ready`) — and the lobby's unlock is the only door forward.
//  RE-LOCK (`lock()`): the composition root's teardown — flush/stop via
//  `onWillLock`, flip to the lobby (views and their observations tear
//  down), then CLOSE the pool and DROP key material through the
//  `StoreBinding` the first open installed. The ambient `\.database` is
//  the binding's VIEW, so every ambient holder survives the re-lock and
//  the re-open without changing a line; an access racing the lock gets
//  the typed `StoreLockedError`.
//

import Foundation
import Observation
import VariorumCore

//  13l L-c (the ruled shape, mobile round 2 §58/§62 — B45-1): the open and
//  the migration set used to run SYNCHRONOUSLY ON THE MAIN THREAD inside
//  `init`, before first paint, on every launch of both apps — a P2
//  violation (OverallModel §5). MEASURED on the simulator: 54.0 ms first
//  launch (empty store, full migration set), 5.0 ms reopen, 3.6 ms at the
//  100k proving ground — **flat in corpus size**, because the cost is
//  O(migrations), not O(corpus). On her real iPhone it read "almost
//  imperceptible" (device walk D8), so this was never a hang; what makes it
//  worth closing is the direction of travel — **the migration set only
//  grows**, every future §12 lockstep event adds to that 54 ms, and it is
//  the one main-thread store road in either app.
//
//  The shape: an `.opening` state the roots render quietly, the file work
//  on a detached task, hopping back to the MainActor for `install` and the
//  state write, `retry()` re-entering the same road. **The "UI can touch a
//  store that is not ready" window cannot open by construction** —
//  `AppSession` exists only inside `.ready`, the property the failure views
//  already rely on.

@Observable
@MainActor
final class AppBootstrap {
    enum State {
        /// The store is being opened and migrated, off the main thread.
        case opening
        /// Phase 13p: a demanded at-open mode over an existing store —
        /// nothing runs until the lobby unlocks.
        case locked(StoreLobby)
        case ready(AppSession)
        case failed(AppDatabase.StoreOpenError)
    }

    private(set) var state: State = .opening
    /// Which store home this process resolved to (A4) — surfaced so a dev
    /// build is visibly a dev build.
    let storeVariant: AppDatabase.StoreVariant
    /// The launch-protection facts (13p) — real defaults/Keychain/sidecar
    /// in production, scripted in tests.
    @ObservationIgnored let gate: StoreLaunchGate
    /// `install` (prepareDependencies) must run exactly once per process;
    /// a retry after a failed first attempt still installs, a second success
    /// cannot happen (retry is only reachable from `.failed`).
    private var installed = false
    /// The lock/adopt handle (13p): set at the FIRST successful open; the
    /// ambient view routes through it forever after, so `lock()` closes
    /// and a later unlock adopts without a second install.
    @ObservationIgnored private var binding: StoreBinding?
    /// The bound view installed as the ambient `\.database` (and handed to
    /// every AppSession, so a session's captured database also survives).
    @ObservationIgnored private var ambient: AppDatabase?
    /// The composition root's pre-lock teardown (13p): flush pending
    /// buffers, savepoint, stop services. Runs BEFORE the state flips.
    @ObservationIgnored var onWillLock: (@MainActor () async -> Void)?
    /// The in-flight open, so a second `retry()` cannot start a second race
    /// for the same store. Test-visible so a pin can await the road rather
    /// than poll it.
    @ObservationIgnored private(set) var opening: Task<Void, Never>?

    /// TEST-ONLY. Replaces the file work with the caller's own, **and skips
    /// the process-global `prepareDependencies` installs with it** — that
    /// coupling is the point rather than a shortcut: an injected opener
    /// means the store is a test's own, and installing a test's store as the
    /// app's ambient one would poison every other test in the process (and
    /// `prepareDependencies` may only be called before anything reads a
    /// dependency). The state machine, the off-main hop, the lobby routing
    /// and `retry()` are otherwise exactly production's. (The opener runs
    /// for the unlock road too; the unlocked key reaches production's
    /// opener as custody and is deliberately not threaded into the test
    /// opener — lobby tests assert the choreography, the key's use is the
    /// production road's own pins.)
    @ObservationIgnored private let testOpener:
        (@Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>)?

    init(
        variant: AppDatabase.StoreVariant = StoreLocation.resolve(),
        gate: StoreLaunchGate = .live
    ) {
        storeVariant = variant
        self.gate = gate
        testOpener = nil
        beginOpening()
    }

    init(
        testOpener: @escaping @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>,
        gate: StoreLaunchGate = .live
    ) {
        storeVariant = .dev
        self.gate = gate
        self.testOpener = testOpener
        beginOpening()
    }

    func retry() {
        beginOpening()
    }

    /// Awaits the in-flight open. Production never calls it (the roots
    /// render `.opening`); pins use it instead of spinning.
    func awaitOpen() async {
        await opening?.value
    }

    // MARK: - The open road (routes first — 13p)

    private func beginOpening(unlockedKey: StoreKey? = nil) {
        guard opening == nil else { return }
        state = .opening
        let variant = storeVariant
        let testOpener = testOpener
        let gate = gate
        opening = Task { [weak self] in
            // OFF the main actor: routing (a defaults read + a 16-byte
            // header classification), then — on the open routes only —
            // `openStore`, which runs the migration set. The demanded
            // routes DEFER all of that behind the lobby.
            let outcome = await Task.detached(priority: .userInitiated) {
                Self.routeAndOpen(
                    variant: variant, gate: gate,
                    unlockedKey: unlockedKey, testOpener: testOpener)
            }.value
            guard let self else { return }
            // …and back, for `install` (a process-global dependency
            // installation) and the state write, both MainActor by contract.
            self.finish(outcome)
        }
    }

    private enum OpenOutcome: Sendable {
        case ready(AppDatabase)
        case locked(LobbyFacts)
        case failed(AppDatabase.StoreOpenError)
    }

    private struct LobbyFacts: Sendable {
        var demand: StoreAtOpenMode
        var biometryOffered: Bool
        var passphraseOffered: Bool
        var recoveryOffered: Bool
        var storeURL: URL?
    }

    private nonisolated static func routeAndOpen(
        variant: AppDatabase.StoreVariant,
        gate: StoreLaunchGate,
        unlockedKey: StoreKey?,
        testOpener: (@Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>)?
    ) -> OpenOutcome {
        let scope = variant.rawValue
        let storeURL = try? AppDatabase.defaultStoreURL(variant: variant)

        // An unlocked key means the lobby already ran — go straight to the
        // open with that key as custody.
        if unlockedKey == nil {
            let dials = gate.dials(scope)
            // The one pre-unlock file contact: 16 bytes of presence. The
            // test-opener path has no file of its own — it routes as
            // "store present" so demanded gates are exercisable.
            let presence: StoreFilePresence = testOpener != nil
                ? .encryptedOrUnknown
                : (storeURL.map(StoreFilePresence.classify(at:)) ?? .absent)
            switch StoreLaunchRoute.resolve(dials: dials, presence: presence) {
            case .open:
                break
            case .openResettingModeToAuto:
                // PROVISIONAL (run record): the demanded gate outlived its
                // store — reset the mode VISIBLY and proceed as a fresh
                // first launch (its unlock secrets reference a key whose
                // store is gone; the protection reconcile replaces the
                // stale envelope on the same launch).
                var dials = dials
                dials.mode = .auto
                gate.saveDials(dials, scope)
            case .lobby(let demand):
                let guardSeam = gate.guardFor(scope)
                let envelope = loadedEnvelope(gate, storeURL)
                return .locked(LobbyFacts(
                    demand: demand,
                    biometryOffered: demand == .biometric && guardSeam.gatedItemExists(),
                    passphraseOffered: envelope?.passphrase != nil,
                    recoveryOffered: envelope?.recovery != nil,
                    storeURL: storeURL))
            }
        }

        if let testOpener {
            switch testOpener() {
            case .success(let database): return .ready(database)
            case .failure(let error): return .failed(error)
            }
        }
        switch openStoreOffMain(
            variant: variant,
            custody: unlockedKey.map { StoreKeyCustody.inMemory(initial: $0) }
        ) {
        case .success(let database): return .ready(database)
        case .failure(let error): return .failed(error)
        }
    }

    private func finish(_ outcome: OpenOutcome) {
        opening = nil
        switch outcome {
        case .ready(let database):
            let view: AppDatabase
            if let binding {
                // The re-open after a lock: the SAME ambient view adopts
                // the fresh pool — no second install, no new view.
                do {
                    try binding.adopt(database)
                } catch {
                    state = .failed(AppDatabase.StoreOpenError(
                        storePath: "", reason: String(describing: error)))
                    return
                }
                view = ambient ?? database
            } else {
                let wrapped = database.asRebindable()
                binding = wrapped.binding
                ambient = wrapped.view
                view = wrapped.view
            }
            if !installed, testOpener == nil {
                AppDatabase.install(view)
                // Phase 9c, Step 4/5: the live owner identity reads the
                // persisted Variorum session per call — the Keychain is the
                // truth AuthSession.adopt/signOut writes, so sign-in state
                // reaches Operations' owner_id stamping with no mutable
                // global and no re-installation.
                OwnerIdentity.install(OwnerIdentity {
                    KeychainAuthStorage.load(
                        service: KeychainAuthStorage.variorumService)?.userID
                })
                installed = true
            }
            state = .ready(AppSession(database: view))
        case .locked(let facts):
            state = .locked(makeLobby(facts))
        case .failed(let error):
            state = .failed(error)
        }
    }

    private func makeLobby(_ facts: LobbyFacts) -> StoreLobby {
        let guardSeam = gate.guardFor(storeVariant.rawValue)
        let envelopeRoad = StoreLobby.envelopeRoad(
            storeURL: facts.storeURL ?? URL(fileURLWithPath: "/dev/null"),
            gate: gate)
        return StoreLobby(
            demand: facts.demand,
            biometryOffered: facts.biometryOffered,
            passphraseOffered: facts.passphraseOffered,
            recoveryOffered: facts.recoveryOffered,
            gatedRoad: { await guardSeam.unlockGated() },
            envelopeRoad: envelopeRoad,
            complete: { [weak self] key in
                self?.beginOpening(unlockedKey: key)
            })
    }

    // MARK: - Re-lock (13p — demanded modes only; Lock Now and the
    // re-lock policy both land here)

    /// Whether Lock Now is a real act right now (P-2: the door renders
    /// only where it acts): ready, bound, and a demanded mode.
    var canLock: Bool {
        guard case .ready = state, binding != nil else { return false }
        return gate.dials(storeVariant.rawValue).mode.isDemanded
    }

    /// The teardown, in the ruled order: flush/savepoint/stop (the
    /// composition root's `onWillLock`), flip to the lobby (views and
    /// their held observations tear down with the `.ready` subtree),
    /// then CLOSE the pool and DROP the key — off the main actor, since
    /// close blocks until in-flight accesses complete. Under Auto this
    /// refuses silently: a lock whose key auto-releases at the next open
    /// is theater, and no theater ships (R13p-14).
    func lock() async {
        guard case .ready = state, let binding else { return }
        let scope = storeVariant.rawValue
        let dials = gate.dials(scope)
        guard dials.mode.isDemanded else { return }
        await onWillLock?()
        let gate = gate
        let storeURL = try? AppDatabase.defaultStoreURL(variant: storeVariant)
        let facts = await Task.detached(priority: .userInitiated) { () -> LobbyFacts in
            let guardSeam = gate.guardFor(scope)
            let envelope = loadedEnvelope(gate, storeURL)
            return LobbyFacts(
                demand: dials.mode,
                biometryOffered: dials.mode == .biometric && guardSeam.gatedItemExists(),
                passphraseOffered: envelope?.passphrase != nil,
                recoveryOffered: envelope?.recovery != nil,
                storeURL: storeURL)
        }.value
        state = .locked(makeLobby(facts))
        _ = await Task.detached(priority: .userInitiated) {
            binding.lock()
        }.value
    }
}

/// The envelope-beside-the-store read, tolerant of an absent URL (the
/// scripted test gate ignores it) and of an unreadable sidecar (the
/// lobby's roads re-load and WORD that refusal; the facts only decide
/// which doors render).
private nonisolated func loadedEnvelope(
    _ gate: StoreLaunchGate, _ storeURL: URL?
) -> StoreKeyEnvelope? {
    let url = storeURL ?? URL(fileURLWithPath: "/dev/null")
    return (try? gate.loadEnvelope(url)) ?? nil
}

/// The FILE work, and nothing else — resolve the URL, assert the iOS
/// protection class, open and migrate. Nonisolated on purpose: this is what
/// runs off the main actor (13l L-c), and keeping it a free function makes
/// that impossible to lose in a later refactor by accident. `install` and
/// the state write deliberately stay behind, on the MainActor.
///
/// Phase 13p Batch 2: `custody` non-nil is the LOBBY's road — the unlocked
/// key rides in as in-memory custody, so `openStore` (and the migration)
/// runs with exactly the key the lobby unwrapped; the device-Keychain
/// custody is deliberately NOT consulted on that road (under the demanded
/// modes it holds nothing silently readable, by the custody law).
private nonisolated func openStoreOffMain(
    variant: AppDatabase.StoreVariant,
    custody: StoreKeyCustody? = nil
) -> Result<AppDatabase, AppDatabase.StoreOpenError> {
    do {
        let url = try AppDatabase.defaultStoreURL(variant: variant)
        #if os(iOS)
        prepareStoreDirectoryProtection(url)
        #endif
        // Phase 13p: custody is EXPLICIT here, and per-variant, on purpose —
        // two load-bearing consequences. (1) The dev store and the real
        // store never share key custody (the A4 fence extended to keys:
        // each variant's key lives under its own Keychain account).
        // (2) The app's own launch under a HOSTED TEST RUN still uses the
        // real device Keychain rather than the test-context ephemeral
        // custody — otherwise the host app would key its dev store under a
        // key that dies with the test process, bricking the dev store for
        // the next real run. Tests that open their OWN stores call
        // `openStore(at:)` bare and get the in-memory test custody; this
        // line is the app's store, which is real whichever process opens it.
        return .success(try AppDatabase.openStore(
            at: url, custody: custody ?? .deviceKeychain(scope: variant.rawValue)))
    } catch let error as AppDatabase.StoreOpenError {
        return .failure(error)
    } catch {
        // openStore/defaultStoreURL only throw StoreOpenError; this arm
        // keeps the compiler honest without a force-cast.
        return .failure(AppDatabase.StoreOpenError(
            storePath: "", reason: String(describing: error)))
    }
}

#if os(iOS)
/// The deliberate protection-class pick (Phase 8 plan risk note),
/// applied BEFORE the first open — iOS data protection is inherited at
/// CREATION time, so the directory's class must be set while the store
/// files don't exist yet (review round 1: a post-open attribute set
/// protected nothing; files created earlier keep their class).
///
/// `.completeUntilFirstUserAuthentication` — the same value as the
/// platform default for third-party app data, chosen EXPLICITLY (not
/// relied on): the store stays readable after the first unlock, so the
/// background-transition sync round can usually finish; a complete-lock
/// race still lands on the scheduler's offline posture. Recording the
/// choice here means a future entitlement or OS-default change cannot
/// silently unmake it.
private nonisolated func prepareStoreDirectoryProtection(_ storeURL: URL) {
    let directory = storeURL.deletingLastPathComponent()
    let protection: [FileAttributeKey: Any] =
        [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
    try? FileManager.default.createDirectory(
        at: directory, withIntermediateDirectories: true, attributes: protection)
    // Existing directory (later launches): keep the class asserted so
    // files created from now on (-wal/-shm rebuilds, backups) inherit it.
    try? FileManager.default.setAttributes(protection, ofItemAtPath: directory.path)
}
#endif
