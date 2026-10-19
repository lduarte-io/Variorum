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
        /// pre-13x 2a (§3.8): a STANDARD library whose bound item is
        /// missing and whose iCloud key has not arrived — "Getting your key
        /// from iCloud Keychain…" (copy §2d), the passphrase / twelve words
        /// as doors that act, the Apple road re-probed until it lands.
        /// Never a silent mint over an existing store.
        case waitingForICloudKeychain(StoreLobby)
        /// pre-13x 1a (§3.7): a demanded mode over an ABSENT store — the
        /// three-door face; nothing opened, nothing persisted, the lock
        /// untouched.
        case libraryMissing(LibraryMissingLobby)
        case ready(AppSession)
        /// `recovery` (13p ladder R1-M3 — the sidecar-present unlock road):
        /// non-nil exactly when the failure is the encrypted-store-with-
        /// empty-custody refusal AND a `variorum-keys.json` with wraps sits
        /// beside the store — the failure surface then offers unlock by
        /// passphrase / recovery phrase through the SAME lobby machinery
        /// (same envelope road, never a new crypto road; same-machine
        /// scope — the full new-machine adoption door is 13x's).
        case failed(AppDatabase.StoreOpenError, recovery: StoreLobby?)
        /// VX-306 U1b — THE NEW ROAD's lobby (Debug, the one switch): roads only, before unlock; the quiet
        /// roads were already tried at once (`ProtectionOpenRoad.route`).
        case roadLobby(ProtectionLobbyModel)
        /// VX-306 U1b — the once-shown words card of a library just created on the new road (rule 2); its
        /// one button opens the library. VX-307 U2b: the PHONE's only — the Mac's first open has nothing in front
        /// (`ProtectionRoad.showsWordsAtCreation`; the words wait for her look, from the card above the quick entry).
        case newLibraryWords(LibraryWordsCardModel)
        /// VX-306 U2 — the open's INTERLUDE on the new road, in the lobby's room between the unlock and the
        /// library's open (PROVISIONAL P-VX306-U2-1): rule 21's notice (once), then the key-file offer; the last
        /// card answered, the open goes on.
        case roadInterlude(RoadInterludeModel)
    }

    private(set) var state: State = .opening
    /// Which store home this process resolved to (A4) — surfaced so a dev
    /// build is visibly a dev build.
    let storeVariant: AppDatabase.StoreVariant
    /// The launch-protection facts (13p) — real defaults/Keychain/sidecar
    /// in production, scripted in tests.
    @ObservationIgnored let gate: StoreLaunchGate
    /// pre-13x 4a (§3.6 / corner 17): the lobby's vault road — ONE
    /// authenticated vault read composed from the scoped token store alone
    /// (production `LobbyVaultRoad.live(scope:)`; nil = unconfigured, or a
    /// test world without one — the local copies are the only roads).
    @ObservationIgnored let lobbyVaultRoad: LobbyVaultRoad?
    /// The protection brain (13p Batch 2): dials, custody acts, notices,
    /// the reset door, and — on the Mac — the re-lock monitors. Owned
    /// here because the bootstrap is where the unlocked key passes
    /// through (`adoptResident`) and where `lock()` lives.
    let protection: ProtectionController
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
    /// VX-202 (gate i): a posture switch's re-key is in flight — set by
    /// `rekeyLibrary` before its reopen, cleared by the runner once the
    /// switch's custody move has landed (`endSwitch`). While set, the
    /// ready's R1-M3 re-landing is never scheduled: the reopen hands back
    /// L′ under a gate that is not demanded YET (custody moves after the
    /// reopen), and a silent save made there is unordered against the
    /// move's delete. Not the controller's `switchInProgress` (the ceremony
    /// models' span); this one belongs to the reopen and the runner.
    @ObservationIgnored private(set) var switchInProgress = false
    /// The R1-M3 re-landing in flight (nil = none scheduled since launch).
    /// Test-visible so a pin can await the road rather than poll it.
    @ObservationIgnored private(set) var relanding: Task<Void, Never>?

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
    /// TEST-ONLY (pre-13x 1a): what the route reads as the store's
    /// presence under a test opener (the default routes as "present" so
    /// demanded gates are exercisable; `.absent` drives the
    /// library-missing route), and the SCRATCH store url the route and the
    /// missing-library act work beside — never the real dev home.
    @ObservationIgnored private let testPresence: StoreFilePresence
    @ObservationIgnored private let testStoreURL: URL?
    /// VX-306 U1b — whether THIS bootstrap takes the rebuilt protection core's open road: the one switch
    /// (`ProtectionRoad.newRoadIsLive` — a Debug build on the Mac) for the production instance; OFF by default
    /// under a test opener, so every existing route suite runs today's road unchanged (the Release check's
    /// test override). Read at the head of `routeAndOpen`.
    @ObservationIgnored let newRoad: Bool
    /// VX-306 U1b — the new road's inputs (nil on today's road): the protection system composed per open on
    /// the main actor, the sign-in read off-main, whether the road may write (never in a hosted test run), and —
    /// under a test — the opener that takes the key in hand.
    @ObservationIgnored private let roadInputs: RoadInputs?
    /// VX-306 U1b — the library open on the new road (nil on today's road, and before the first open): the
    /// backup hook's key, key file and device ID; U2's faces read its report (the notice, the repairs, the
    /// faults, the acts owed).
    @ObservationIgnored private(set) var roadSession: ProtectionRoadSession?
    /// VX-307 U1 — the engine's key seam on the new road: attached to the road session at each ready; the
    /// composition site hands it to `AppServices` as the sync key provider when `newRoad` (today's road keeps
    /// `DeviceKeySyncProvider`, byte-unchanged).
    @ObservationIgnored let newRoadSyncKeys = NewRoadSyncKeyProvider()
    /// VX-306 U2 — the open library's protection faces on the new road (nil on today's road): rule 27's banner,
    /// the split pair's line, rule 3's reminder and its set-passphrase sheet, the receipts the open owes.
    private(set) var roadStanding: RoadStandingModel?
    /// VX-306 U2 — rule 3's local schedule (this Mac's defaults; a test bootstrap writes its own suite, never the
    /// app's domain).
    @ObservationIgnored private let reminderLedger: PassphraseReminderLedger
    /// VX-306 U3 — receipts the NEXT open on the new road owes the status seam (Make this my library's §7c (9)):
    /// handed to the session the reopen makes, then spoken by the ready composition like every owed receipt.
    @ObservationIgnored private var receiptsForNextRoadOpen: [String] = []
    /// VX-307 U2a — the crossings on the new road (nil on today's road, and before the first open): OWNED HERE because a
    /// crossing reopens the library — the `.ready` tree, the Settings pane and its `@State` go down and come back, and the
    /// confirm in flight, its refusal and rule 11's notice must survive that. Made at the first ready on the new road.
    private(set) var roadCrossings: RoadCrossingsModel?
    /// VX-307 U2a — this Mac's scheduled plain-text export (the weekly copy's switch, `MarkdownInsurance`): the
    /// production instance's standard defaults; a test bootstrap's own suite, never the app's domain.
    @ObservationIgnored private let exportSwitch: ScheduledExportSwitch

    init(
        variant: AppDatabase.StoreVariant = StoreLocation.resolve(),
        gate: StoreLaunchGate = .live
    ) {
        storeVariant = variant
        self.gate = gate
        testOpener = nil
        testPresence = .encryptedOrUnknown
        testStoreURL = nil
        // P-VX306-U1b-5: the new road reaches ONLY the fenced dev store — a Debug build opted into the real
        // store's variant keeps today's road (the phase's one law: "it reaches only the fenced dev store").
        newRoad = ProtectionRoad.opensOnTheNewRoad(devStore: variant == .dev)
        roadInputs = newRoad ? RoadInputs.live(variant: variant) : nil
        reminderLedger = PassphraseReminderLedger()
        exportSwitch = Self.markdownInsuranceSwitch(suiteName: nil)
        lobbyVaultRoad = LobbyVaultRoad.live(scope: variant.rawValue)
        protection = ProtectionController(configuration: .init(
            scope: variant.rawValue,
            storeURL: try? AppDatabase.defaultStoreURL(variant: variant),
            gate: gate,
            isRealVariant: variant == .real))
        protection.performLock = { [weak self] in await self?.lock() }
        // pre-13x 2a (§11): the production migration leaves — the Keychain,
        // the defaults, the store — per store id, built at ready. NEVER in
        // the TEST HOST: the tripwire refuses every real-scope Keychain
        // mutation there, so the road could not complete (a refused leg
        // every launch), and the dev scope's 14b login-keychain item sits
        // behind an ACL prompt for a rebuilt host binary ("Variorum Dev
        // wants to use your confidential information…", the login
        // password) that no test can answer — observed 2026-09-05 as the
        // runner timing out while preparing. The migration's Keychain
        // proof is the opt-in drill under throwaway scopes; the dev
        // store's own run is the Debug APP's, at her keychain password.
        let scope = variant.rawValue
        let storeURL = try? AppDatabase.defaultStoreURL(variant: variant)
        if KeychainTestTripwire.armed {
            makeMigrationLeaves = nil
        } else {
            makeMigrationLeaves = { [protection, gate] database, storeID in
                .live(scope: scope, storeID: storeID, storeURL: storeURL,
                      database: database, gate: gate, protection: protection)
            }
        }
        #if os(macOS)
        // Production instances only: the monitors re-check the dials at
        // fire time, so they are safe always-on listeners.
        protection.startRelockMonitors()
        #endif
        beginOpening()
    }

    init(
        testOpener: @escaping @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>,
        gate: StoreLaunchGate = .live,
        testPresence: StoreFilePresence = .encryptedOrUnknown,
        testStoreURL: URL? = nil,
        // pre-13x 2d: a pin over a real on-disk store (a store id beside it)
        // hands the controller ITS sync-custody leaves — else the id
        // resolves to the live Keychain's per-store items.
        syncCustodyLeaves: (@Sendable (_ storeID: String) -> E2EECustodyLeaves)? = nil,
        syncCustodySession: SyncCustodySession = .shared,
        // pre-13x 4a: a scripted vault road for the lobby's pins (nil = none).
        lobbyVaultRoad: LobbyVaultRoad? = nil,
        // VX-306 U1b: the one switch's test override — OFF (today's road) unless a new-road pin hands in its
        // harness: a protection system over a temp slot and a throwaway scope, and the keyed opener.
        protectionRoad: ProtectionRoadTestHarness? = nil
    ) {
        storeVariant = .dev
        self.gate = gate
        self.testOpener = testOpener
        self.testPresence = testPresence
        self.testStoreURL = testStoreURL
        newRoad = protectionRoad != nil
        roadInputs = protectionRoad.map(RoadInputs.test)
        reminderLedger = PassphraseReminderLedger(
            defaults: UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard)
        exportSwitch = Self.markdownInsuranceSwitch(suiteName: Self.crossingTestExportSuiteName)
        self.lobbyVaultRoad = lobbyVaultRoad
        protection = ProtectionController(configuration: .init(
            scope: AppDatabase.StoreVariant.dev.rawValue,
            storeURL: testStoreURL,
            gate: gate,
            isRealVariant: false,
            syncCustodyLeaves: syncCustodyLeaves,
            syncCustodySession: syncCustodySession))
        protection.performLock = { [weak self] in await self?.lock() }
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

    private func beginOpening(unlockedKey: StoreKey? = nil, roadOpened: ProtectionRoadSession? = nil) {
        guard opening == nil else { return }
        state = .opening
        let variant = storeVariant
        let testOpener = testOpener
        let testPresence = testPresence
        let testStoreURL = testStoreURL
        let gate = gate
        // VX-306 U1b: the new road's system, composed ONCE per open on the main actor (U1a's hand-forward).
        let newRoad = newRoad
        let road = newRoad ? roadInputs?.compose() : nil
        opening = Task { [weak self] in
            // OFF the main actor: routing (a defaults read + a 16-byte
            // header classification), then — on the open routes only —
            // `openStore`, which runs the migration set. The demanded
            // routes DEFER all of that behind the lobby.
            let outcome = await Task.detached(priority: .userInitiated) {
                await Self.routeAndOpen(
                    variant: variant, gate: gate,
                    unlockedKey: unlockedKey, testOpener: testOpener,
                    testPresence: testPresence, testStoreURL: testStoreURL,
                    newRoad: newRoad, road: road, roadOpened: roadOpened)
            }.value
            guard let self else { return }
            // …and back, for `install` (a process-global dependency
            // installation) and the state write, both MainActor by contract.
            self.finish(outcome)
        }
    }

    private enum OpenOutcome: Sendable {
        case ready(AppDatabase, unlockedKey: StoreKey?, road: ProtectionRoadSession? = nil)
        /// VX-306 U1b: the new road's lobby, its facts and the context its presses run in.
        case roadLobby(RoadLobbyFacts, RoadContext)
        /// VX-306 U1b: a library created on the new road — the words card first.
        case roadCreated(ProtectionRoadSession, OnceShownWords)
        /// VX-306 U2: an open on the new road that owes the interlude (rule 21's notice, the offer) first.
        case roadInterlude(ProtectionRoadSession, RoadContext)
        case locked(LobbyFacts)
        /// pre-13x 2a (§3.8): Standard's waiting state.
        case waiting(LobbyFacts)
        case libraryMissing(demand: StoreAtOpenMode, storeURL: URL?)
        case failed(AppDatabase.StoreOpenError, recovery: LobbyFacts?)
    }

    private struct LobbyFacts: Sendable {
        var kind: StoreLobby.Kind = .castle
        var demand: StoreAtOpenMode
        var biometryOffered: Bool
        var passphraseOffered: Bool
        var recoveryOffered: Bool
        /// P11: present-but-unreadable sidecar — the lobby's dead end says
        /// the true cause instead of "no passphrase … is on file".
        var envelopeUnreadable: Bool = false
        var storeURL: URL?

        /// pre-13x 4a: the secret roads' existence is the lobby's rule
        /// (`StoreLobby.passphraseRoadExists` / `recoveryRoadExists`).
        nonisolated static func passphraseRoadExists(_ envelope: StoreKeyEnvelope?) -> Bool {
            StoreLobby.passphraseRoadExists(envelope)
        }
        nonisolated static func recoveryRoadExists(_ envelope: StoreKeyEnvelope?) -> Bool {
            StoreLobby.recoveryRoadExists(envelope)
        }
    }

    /// The store id the dials are keyed by (pre-13x 1a): the key file's,
    /// beside the store, read without the key. nil = no key file (a fresh
    /// library) or no resolvable path.
    private nonisolated static func storeID(besideStore storeURL: URL?) -> String? {
        guard let storeURL else { return nil }
        if case .known(let id) = StoreIdentity.resolve(besideStore: storeURL) { return id }
        return nil
    }

    private nonisolated static func routeAndOpen(
        variant: AppDatabase.StoreVariant,
        gate: StoreLaunchGate,
        unlockedKey: StoreKey?,
        testOpener: (@Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>)?,
        testPresence: StoreFilePresence,
        testStoreURL: URL?,
        newRoad: Bool = false,
        road: ComposedRoad? = nil,
        roadOpened: ProtectionRoadSession? = nil
    ) async -> OpenOutcome {
        let scope = variant.rawValue
        // Under a test opener the route works beside the test's SCRATCH url
        // (nil = none) — never the real dev home.
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: variant))

        // VX-306 U1b — THE ONE SWITCH, read here: the new road (a Debug build on the Mac, the dev store) takes
        // the whole route; today's road below runs byte-for-byte as before when it is off.
        if newRoad {
            guard let road else {
                return .failed(AppDatabase.StoreOpenError(
                    storePath: storeURL?.path ?? "", reason: ProtectionWords.somethingWentWrong), recovery: nil)
            }
            return await routeOnNewRoad(
                road, variant: variant, gate: gate, unlockedKey: unlockedKey, roadOpened: roadOpened,
                storeURL: storeURL)
        }

        // An unlocked key means the lobby already ran — go straight to the
        // open with that key as custody.
        var unlockedKey = unlockedKey
        if unlockedKey == nil {
            // pre-13x 2a: the EFFECTIVE gate, derived at the route — the
            // posture from the key file beside the store (read without the
            // key; the 13p-era stored mode until §11 retires it) and
            // Castle's gate style from the store's dials. Never a stored mode.
            let effectiveGate = gate.effectiveGate(
                scope: scope, storeID: storeID(besideStore: storeURL), storeURL: storeURL)
            // The one pre-unlock file contact: 16 bytes of presence. The
            // test-opener path has no file of its own — it routes as the
            // scripted presence ("present" by default, so demanded gates
            // are exercisable; `.absent` for the missing-library pins).
            // P13 rider (pre-13u Act 9): a nil URL (`defaultStoreURL()`
            // threw) routes as UNKNOWN, never absent — "we could not even
            // resolve the path" must not read as a missing library.
            let presence: StoreFilePresence = testOpener != nil
                ? testPresence
                : (storeURL.map(StoreFilePresence.classify(at:)) ?? .encryptedOrUnknown)
            switch StoreLaunchRoute.resolve(gate: effectiveGate, presence: presence) {
            case .open:
                // pre-13x 2a — STANDARD'S OPEN ROAD (§3.8): the bound item
                // opens silently; a MISSING item (a restored copy on a
                // fresh device; a wiped Keychain) tries the key file's Apple
                // copy via A from iCloud Keychain; A absent — or another
                // Apple ID's — is the WAITING STATE with the passphrase and
                // the words as doors. Never a silent mint over an existing
                // store: the open below refuses typed without a key.
                if presence == .encryptedOrUnknown, let storeURL,
                   gate.guardFor(scope).loadAuto() == nil {
                    let reading = gate.readEnvelope(storeURL)
                    if reading.envelope?.apple != nil || reading.envelope?.passphrase != nil
                        || reading.envelope?.recovery != nil {
                        switch StoreLobby.openWithAppleKey(scope: scope, storeURL: storeURL, gate: gate) {
                        case .opened(let key):
                            unlockedKey = key  // re-landed as the bound item at ready (R1-M3)
                        case .appleKeyAbsent, .differentAppleID, .noAppleCopy:
                            let different: Bool
                            if case .differentAppleID = StoreLobby.openWithAppleKey(
                                scope: scope, storeURL: storeURL, gate: gate) {
                                different = true
                            } else {
                                different = false
                            }
                            return .waiting(LobbyFacts(
                                kind: .waitingForICloudKeychain(differentAppleID: different),
                                demand: .auto,
                                biometryOffered: false,
                                passphraseOffered: LobbyFacts.passphraseRoadExists(reading.envelope),
                                recoveryOffered: LobbyFacts.recoveryRoadExists(reading.envelope),
                                envelopeUnreadable: reading.isUnreadable,
                                storeURL: storeURL))
                        }
                    }
                }
            case .libraryMissing(let demand):
                // §3.7: THE LOCK STAYS — no dial write, no open, no mint.
                // The three-door face renders; "Start a New Library" is the
                // one deliberate act that mints, under a NEW store id.
                return .libraryMissing(demand: demand, storeURL: storeURL)
            case .lobby(let demand):
                let guardSeam = gate.guardFor(scope)
                let reading = gate.readEnvelope(storeURL)
                return .locked(LobbyFacts(
                    demand: demand,
                    biometryOffered: demand == .biometric && guardSeam.gatedItemExists(),
                    passphraseOffered: LobbyFacts.passphraseRoadExists(reading.envelope),
                    recoveryOffered: LobbyFacts.recoveryRoadExists(reading.envelope),
                    envelopeUnreadable: reading.isUnreadable,
                    storeURL: storeURL))
            }
        }

        if let testOpener {
            switch testOpener() {
            case .success(let database): return .ready(database, unlockedKey: unlockedKey)
            case .failure(let error):
                return failedOutcome(error, gate: gate, storeURL: storeURL)
            }
        }
        switch openStoreOffMain(
            variant: variant,
            custody: unlockedKey.map { StoreKeyCustody.inMemory(initial: $0) }
        ) {
        case .success(let database): return .ready(database, unlockedKey: unlockedKey)
        case .failure(let error):
            return failedOutcome(error, gate: gate, storeURL: storeURL)
        }
    }

    // MARK: - VX-306 U1b: THE NEW ROAD (reached only behind the one switch)

    /// The new road's route (`ProtectionOpenRoad.route` decides nothing — `assess` does), then the app's open
    /// with the key in hand. A session already opened (the lobby's press, the words card's button) goes
    /// straight to the open.
    private nonisolated static func routeOnNewRoad(
        _ road: ComposedRoad, variant: AppDatabase.StoreVariant, gate: StoreLaunchGate,
        unlockedKey: StoreKey?, roadOpened: ProtectionRoadSession?, storeURL: URL?
    ) async -> OpenOutcome {
        if let roadOpened {
            // VX-306 U2: a session the lobby's press opened may owe the interlude too (shown once per open).
            if roadOpened.owesInterlude { return .roadInterlude(roadOpened, road.context()) }
            return openOnNewRoad(roadOpened, road: road, variant: variant, gate: gate)
        }
        let ctx = road.context()
        #if DEBUG
        // Walk machinery (P-VX306-U1b-9): a launch asked to forget a quiet road does so once, before the facts; and
        // (VX-307 U2a, P-VX307-U2a-6) one asked to fail its first Touch ID press arms that on the road's custody leaf.
        if road.open == nil {
            ProtectionWalkSwitch.forgetOnceIfAsked(ctx)
            ProtectionWalkSwitch.failTouchIDOnceIfAsked(ctx)
        }
        #endif
        switch await ProtectionOpenRoad.route(ctx, keyInHand: unlockedKey) {
        case .opened(let session):
            // VX-306 U2: rule 21's notice and the key-file offer are said before the library shows.
            if session.owesInterlude { return .roadInterlude(session, ctx) }
            return openOnNewRoad(session, road: road, variant: variant, gate: gate)
        case .created(let session, let words):
            return .roadCreated(session, words)
        case .lobby(let facts):
            return .roadLobby(facts, ctx)
        case .libraryMissing:
            // `.libraryMissing`, and K5's `recordMissing` — the three-door face, no sentence about the store.
            return .libraryMissing(demand: .auto, storeURL: storeURL)
        case .failed(let sentence):
            return .failed(
                AppDatabase.StoreOpenError(storePath: road.system.places.slot.path, reason: sentence), recovery: nil)
        }
    }

    /// The app's open on the new road: the store identity (today's mint, so the rest of the app keeps its
    /// footing), then today's `openStoreOffMain` with the key in hand (`StoreKeyCustody.inMemory` — the device
    /// keychain's today-road items are never read on this road, rule 26).
    private nonisolated static func openOnNewRoad(
        _ session: ProtectionRoadSession, road: ComposedRoad, variant: AppDatabase.StoreVariant, gate: StoreLaunchGate
    ) -> OpenOutcome {
        let key = session.key
        if road.writes {
            ensureStoreIdentity(
                slot: road.system.places.slot, key: key, fresh: session.isFresh, gate: gate, scope: variant.rawValue)
        }
        let opened = road.open?(key) ?? openStoreOffMain(variant: variant, custody: .inMemory(initial: key))
        switch opened {
        case .success(let database): return .ready(database, unlockedKey: key, road: session)
        case .failure(let error): return .failed(error, recovery: nil)
        }
    }

    /// TODAY'S STORE ID beside the store (`StoreIdentity` — sync custody, the dials and the backup log are
    /// keyed by it): a library created on the new road mints a NEW one exactly as today's `startNewLibrary`
    /// does (the old key file aside, `establish` under the new key, the new id's own Auto dials — never today's
    /// silent custody, rule 26); a later open mints one only when none is there (a creation that died before it
    /// landed). An existing id is never re-minted (a later key change must not change it).
    nonisolated static func ensureStoreIdentity(
        slot: URL, key: StoreKey, fresh: Bool, gate: StoreLaunchGate, scope: String
    ) {
        if fresh {
            gate.setAsideEnvelope(slot)
        } else {
            guard case .none = StoreIdentity.resolve(besideStore: slot) else { return }
        }
        do {
            let storeID = try StoreIdentity.establish(besideStore: slot, key: key)
            gate.saveDials(ProtectionDials(), scope, storeID)
        } catch {
            ProtectionOpenRoad.log("road: the store id could not be written beside the library — \(String(describing: error))")
        }
    }

    /// 13p ladder R1-M3: a failed open lands `.failed` — and when the
    /// failure is the encrypted-store-with-empty-custody refusal (typed:
    /// `keyUnavailable`) with a wraps-bearing sidecar beside the store, it
    /// carries the RECOVERY facts, so the failure surface can offer the
    /// envelope's own unlock roads instead of a dead end. Before this,
    /// that state was doorless while the plan's own words claimed
    /// "Batch 2's recovery roads re-derive".
    ///
    /// VX-80 (the Castle-follow crash window): the WRONG-KEY class earns
    /// the SAME lobby — a key in hand that SQLCipher refused (typed:
    /// `keyRejected`) beside a wraps-bearing sidecar is the stranded state
    /// a death between the follow's verified swap and its custody move
    /// leaves behind: the store is whole under the NEW key, the NEWEST
    /// sidecar wraps exactly that key, and custody opens with the old one
    /// forever. The typed word unlocks through the sidecar; the ready
    /// housekeeping's reconcile then finds the pending `RotationMarker`
    /// and the resume road completes the interrupted follow (custody
    /// finally moves, snapshot, old key file retired, marker cleared).
    /// Before this, that state was the doorless dead end of the 2026-10-07
    /// production incident (the VX-80 record).
    private nonisolated static func failedOutcome(
        _ error: AppDatabase.StoreOpenError,
        gate: StoreLaunchGate,
        storeURL: URL?
    ) -> OpenOutcome {
        guard error.keyUnavailable || error.keyRejected else {
            return .failed(error, recovery: nil)
        }
        // P11 disposition note: an UNREADABLE sidecar reads as no roads
        // here — the failure surface stays doorless for it (unchanged
        // behavior; the StoreOpenError's own reason renders). The lobby
        // and the controller doors carry the unreadable honesty; widening
        // this surface would be new design, not a fix.
        let envelope = gate.readEnvelope(storeURL).envelope
        let passphrase = envelope?.passphrase != nil
        let recovery = envelope?.recovery != nil
        guard passphrase || recovery else { return .failed(error, recovery: nil) }
        // `demand: .passphrase` names the roads this lobby renders (typed
        // secrets only — on the empty-custody class no gated item exists,
        // or the open would not have failed; on the wrong-key class any
        // gated item holds exactly the key that just failed, so the typed
        // secrets are the only honest roads); the failure surface words
        // its own frame.
        return .failed(error, recovery: LobbyFacts(
            demand: .passphrase,
            biometryOffered: false,
            passphraseOffered: passphrase,
            recoveryOffered: recovery,
            storeURL: storeURL))
    }

    private func finish(_ outcome: OpenOutcome) {
        opening = nil
        switch outcome {
        case .ready(let database, let unlockedKey, let road):
            // VX-306 U1b: the library open on the new road (nil on today's road).
            roadSession = road
            // VX-307 U1: the engine's key seam follows the open (nil detaches).
            newRoadSyncKeys.attach(road)
            // VX-306 U3: a receipt an act owed this reopen (Make this my library) joins the open's own.
            if let road {
                for receipt in receiptsForNextRoadOpen { road.addReceipt(receipt) }
                receiptsForNextRoadOpen = []
            }
            // VX-306 U2: its protection faces (rule 27's banner, the split pair, rule 3's reminder, the receipts).
            roadStanding = road.map { RoadStandingModel.make($0, ledger: reminderLedger) }
            // VX-307 U2a: the crossings — made once, kept across every reopen; the faces carry them to the pane.
            if newRoad, road != nil, roadCrossings == nil { roadCrossings = RoadCrossingsModel(roads: crossingRoads()) }
            roadStanding?.crossings = roadCrossings
            let view: AppDatabase
            if let binding {
                // The re-open after a lock: the SAME ambient view adopts
                // the fresh pool — no second install, no new view.
                do {
                    try binding.adopt(database)
                } catch {
                    state = .failed(
                        AppDatabase.StoreOpenError(
                            storePath: "", reason: String(describing: error)),
                        recovery: nil)
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
                // pre-13x 2c (corner 47): the read is SCOPED by store
                // variant — a dev store's owner identity is its own
                // session's, never the installed build's.
                let sessionScope = storeVariant.rawValue
                OwnerIdentity.install(OwnerIdentity {
                    KeychainAuthStorage.load(
                        service: KeychainAuthStorage.variorumService, scope: sessionScope)?.userID
                })
                installed = true
            }
            let readySession = AppSession(database: view, storeVariant: storeVariant)
            #if os(macOS)
            // 13i-d U5: the Mac stands in the wing it was last in (a LOCAL
            // memory); a wing that died meanwhile returns it to Home.
            readySession.wing.attachMemory(.standard)
            Task { @MainActor [view] in
                let live = Set((try? await view.read { try Queries.wings($0).map(\.id) }) ?? [])
                readySession.wing.revalidate { $0.isEmpty || live.contains($0) }
            }
            #endif
            state = .ready(readySession)
            // pre-13x 2b: the reconcile's Apple arm reads the persisted
            // switch marker (a crashed switch pending its resume).
            protection.readSwitchPending = { [database] in
                (try? await database.read { try RotationMarker.isSet($0) }) ?? false
            }
            // pre-13x 3a (§3.6 — the owner distinction, the EXACT read): any
            // owner-carrying row stamped by another account, read at the
            // reconcile against the signed-in user id.
            protection.foreignOwner = { [database] user in
                (try? await database.read { try Queries.foreignOwnerExists($0, signedIn: user) }) ?? false
            }
            // 13p: the demanded modes' resident key (nil on the Auto
            // road — its Keychain releases on demand), then the launch
            // reconcile (escrow consistency, first-use stamp, notices) —
            // AFTER the stack exists, never before unlock.
            protection.adoptResident(unlockedKey)
            // 13p ladder R1-M3: an unlocked key arriving under a
            // NON-demanded mode is the failure surface's recovery road —
            // the Auto item was gone (that is why the open failed), and
            // the custody law says Auto keeps a silent item. Re-land the
            // PROVEN key so the next launch opens silently instead of
            // failing into the same surface. (The demanded modes' lobby
            // road never lands custody — that is its own law.)
            // VX-202: never mid-switch. Gate i — a switch's own reopen lands
            // here before its custody move, so nothing is scheduled at all
            // (a marker read inside the task could run after the move and
            // the marker's clear, and re-land L′ behind the delete). Gate ii
            // — a crashed switch's marker (the ordinary relaunch: the silent
            // open failed on the re-keyed file, the typed word unlocked):
            // re-landing L′ silently would open a half-switched library with
            // no gate. The async marker read is safe only on that road; the
            // in-memory flags are re-read after it, and the save rides the
            // custody queue, ahead of any custody move enqueued later.
            // VX-306 U1b: NEVER on the new road — the re-landing writes today's silent item (a quiet road the
            // protection core would not know of; rule 26: the new road writes none of today's names).
            if !newRoad, let unlockedKey, !switchInProgress, !currentEffectiveGate.isDemanded {
                let protection = protection
                relanding = Task { [weak self] in
                    let pending = await protection.readSwitchPending?() ?? false
                    guard !pending, let self, !self.switchInProgress, !protection.switchInProgress,
                          protection.keyInHand() == unlockedKey
                    else { return }
                    _ = await protection.relandSilentItem(unlockedKey)
                }
            }
            // pre-13x 2a (§11): the migration runs ONCE per store at ready
            // — before the reconcile, never before unlock — then the
            // reconcile (the launch housekeeping, the Apple arm, the
            // notices). The test-opener road runs it only when a test
            // injected leaves. pre-13x 2d: ONE act, `runReadyHousekeeping`,
            // which the roots call AGAIN once the vault hook is wired and
            // the session restored — decision 35's "next ready".
            readyHousekeeping = Task<Void, Never> { [weak self] in
                await self?.readyHousekeepingBody(database: database, unlockedKey: unlockedKey)
            }
            // pre-13x 2a: the idle clock starts at ready (decision 18 —
            // time since Variorum was last used).
            protection.noteActivity()
        case .locked(let facts):
            state = .locked(makeLobby(facts))
        case .waiting(let facts):
            let lobby = makeLobby(facts)
            state = .waitingForICloudKeychain(lobby)
            lobby.beginWaiting()
        case .libraryMissing(let demand, let storeURL):
            state = .libraryMissing(makeMissingLobby(demand: demand, storeURL: storeURL))
        case .failed(let error, let recoveryFacts):
            state = .failed(error, recovery: recoveryFacts.map(makeLobby))
        case .roadLobby(let facts, let ctx):
            state = .roadLobby(makeRoadLobby(facts, ctx))
        case .roadCreated(let session, let words):
            if ProtectionRoad.showsWordsAtCreation {
                // The phone (P-VX307-U2b-0): its creation card stands this phase.
                state = .newLibraryWords(LibraryWordsCardModel(words: words.words) { [weak self] in
                    self?.beginOpening(roadOpened: session)
                })
            } else {
                // VX-307 U2b (VX-412, rules 2–3 as amended): the Mac's first open is the Bookcase and the quick entry
                // with NOTHING in front of them — no card, no lobby. The creation's words are dropped here unseen
                // (nothing stores the words); the card above the quick entry offers fresh ones when she asks.
                ProtectionOpenRoad.log("road: created — the first open goes straight on (the words wait for her look)")
                beginOpening(roadOpened: session)
            }
        case .roadInterlude(let session, let ctx):
            state = .roadInterlude(makeInterlude(session, ctx))
        }
    }

    /// VX-306 U2 — the interlude (rule 21): the notice, then the offer; *Use it* runs off the main actor through
    /// the road; when the last card is answered the open goes on with the same session (shown once per open).
    /// VX-307 U2a — then VX-310's re-arm question, answered through the session's executor (`answerTouchIDRearm`).
    private func makeInterlude(_ session: ProtectionRoadSession, _ ctx: RoadContext) -> RoadInterludeModel {
        RoadInterludeModel(
            cards: RoadInterlude.cards(session.report),
            useOffer: { offer in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.useOffer(ctx, session: session, offer: offer)
                }.value
            },
            answerRearm: { yes in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionCrossings.answerRearm(session, yes: yes)
                }.value
            },
            receipt: { session.addReceipt($0) },
            finished: { [weak self] in
                session.markInterludeShown()
                self?.beginOpening(roadOpened: session)
            })
    }

    /// VX-306 U1b — the new road's lobby: its presses run off the main actor through the road; an opened
    /// session continues into the app's open; K5's `recordMissing` lands on the missing face.
    private func makeRoadLobby(_ facts: RoadLobbyFacts, _ ctx: RoadContext) -> ProtectionLobbyModel {
        ProtectionLobbyModel(
            standing: facts,
            typedRoad: { secret in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.openTyped(ctx, secret: secret)
                }.value
            },
            touchIDRoad: { facts in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.pressTouchID(ctx, facts: facts)
                }.value
            },
            refreshRoad: {
                await Task.detached(priority: .userInitiated) { ProtectionOpenRoad.lobbyFacts(ctx) }.value
            },
            opened: { [weak self] session in self?.beginOpening(roadOpened: session) },
            recordMissing: { [weak self] in
                guard let self else { return }
                self.state = .libraryMissing(self.makeMissingLobby(demand: .auto, storeURL: self.liveStoreURL))
            },
            // VX-306 U2 — rule 27's face's *Start a New Library*: the library no key file opens steps aside whole
            // first (PROVISIONAL P-VX306-U2-5), then the creation and the words card.
            startNew: { [weak self] in
                guard let self else { return nil }
                return await self.createOnNewRoadFromAFace()
            })
    }

    /// VX-306 — a face's *Start a New Library* on the new road (the missing face — K5's record-less store among the
    /// states it shows — and rule 27's face): whatever stands in the slot steps aside first, never written over
    /// (`ProtectionOpenRoad.startNewLibraryFromAFace`: P-VX306-U1b-3, P-VX306-U2-5; the ladder's round-1 m1), then the
    /// creation (rule 2) and the words card. nil = done; else the sentence the face shows.
    private func createOnNewRoadFromAFace() async -> String? {
        guard let road = roadInputs?.compose() else { return ProtectionWords.couldNotCreate }
        let route = await Task.detached(priority: .userInitiated) {
            // The context off the main actor: it reads the sign-in (a Keychain read).
            await ProtectionOpenRoad.startNewLibraryFromAFace(road.context())
        }.value
        switch route {
        case .created(let session, let words):
            finish(.roadCreated(session, words))
            return nil
        case .failed(let sentence):
            return sentence
        case .opened, .lobby, .libraryMissing:
            return ProtectionWords.couldNotCreate
        }
    }

    /// pre-13x 2d (decision 35) — THE READY ACT, whole: the §11 migration
    /// if it is not done (it stays undone while an enrolled library's
    /// vault is unread), then the reconcile (the vault's word, the follow's
    /// verdict, the Apple arm, the notices). The ready road runs it; the
    /// composition roots run it AGAIN after `wireOneSecretHooks` and
    /// `services.start()` — the vault readable, the session restored —
    /// which is what "retries at the next ready" means in-process (before
    /// 2d the ready road was the only caller, and it ran before the hooks
    /// existed: the window's "vault descriptor: next online ready" that
    /// never came). Awaitable, so a pin can wait for the ready-time run.
    @ObservationIgnored private(set) var readyHousekeeping: Task<Void, Never>?

    func runReadyHousekeeping() async {
        guard case .ready(let session) = state else { return }
        await readyHousekeeping?.value
        let unlocked = protection.keyInHand()
        let task = Task<Void, Never> { [weak self] in
            await self?.readyHousekeepingBody(database: session.database, unlockedKey: unlocked)
        }
        readyHousekeeping = task
        await task.value
    }

    /// The pin's door: wait for the run the ready road started.
    func awaitReadyHousekeeping() async {
        await readyHousekeeping?.value
    }

    private func readyHousekeepingBody(database: AppDatabase, unlockedKey: StoreKey?) async {
        // VX-306 U1b: today's ready housekeeping (the §11 migration, the reconcile's custody arms — the Apple
        // arm mints today's shared Apple key and lands its wrap in today's key file) is TODAY's road's; the new
        // road's repairs already ran at its open (`ProtectionOpenRoad.open` → `repairPasses`). Rule 26: the new road
        // writes none of today's names.
        guard !newRoad else { return }
        await runMigrationIfNeeded(database: database, unlockedKey: unlockedKey)
        if testOpener == nil || makeMigrationLeaves != nil {
            await protection.reconcile()
        }
    }

    /// §11 — the migration at ready (see `ProtectionMigration`): the facts
    /// are gathered here (the key in hand, the gate the route used, the
    /// posture the vault says when reachable, biometry), the leaves come
    /// from the composition, and the confirm's pending read is wired into
    /// the controller's notices. Awaited by the ready road so the reconcile
    /// that follows sees the migrated state.
    private func runMigrationIfNeeded(database: AppDatabase, unlockedKey: StoreKey?) async {
        guard let makeMigrationLeaves, let storeID = currentStoreID() else { return }
        let scope = storeVariant.rawValue
        let guardSeam = gate.guardFor(scope)
        guard let key = unlockedKey ?? guardSeam.loadAuto() else { return }
        let leaves = makeMigrationLeaves(database, storeID)
        protection.readMigrationConfirmPending = { leaves.isConfirmPending() }
        protection.clearMigrationConfirmPending = { leaves.setConfirmPending(false) }
        guard !leaves.isDone() else { return }
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
        _ = storeURL
        let effectiveGate = currentEffectiveGate
        let reading = await protection.readVaultPosture?()
        // pre-13x 2d (decision 35): the posture is derived INSIDE the run,
        // after leg 1 knows whether the library holds sync custody; the
        // bootstrap hands in the raw facts — the session, the vault's word,
        // the gate style — never a target it derived without them.
        let signedIn = await protection.isSignedIn?() ?? false
        let facts = ProtectionMigration.Facts(
            scope: scope, storeID: storeID, key: key,
            effectiveGate: effectiveGate,
            signedIn: signedIn,
            vaultHasAppleHeldCopy: reading?.hasAppleHeldCopy,
            alwaysAsk: gate.dials(scope, storeID).alwaysAsk,
            biometryAvailable: guardSeam.biometryAvailable(),
            vaultKDF: reading?.passphraseKDF,
            vaultRecoveryWrapDigest: reading?.recoveryWrapDigest)
        lastMigrationReport = await ProtectionMigration.run(facts: facts, leaves: leaves)
    }

    /// The persisted dials of THIS bootstrap's store, read fresh (pre-13x
    /// 1a: per store id — the one place a face or a monitor reads the gate's
    /// dials without knowing the id; the phone's relock coordinator).
    var currentDials: ProtectionDials {
        gate.dials(storeVariant.rawValue, currentStoreID())
    }

    /// pre-13x 2a: the EFFECTIVE gate of this bootstrap's store, derived
    /// fresh from the gate's own reads (the key file, the legacy mode, the
    /// dials) — the ACTING authority for `lock()` and the phone's relock
    /// coordinator; the controller's observable projection is the faces'.
    var currentEffectiveGate: StoreAtOpenMode {
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
        return gate.effectiveGate(
            scope: storeVariant.rawValue, storeID: currentStoreID(), storeURL: storeURL)
    }

    /// pre-13x 2a (decision 18, ledger row 7): the KEYLESS BYTE-COPY at
    /// lock time — run AFTER the pool closed and the key dropped, when a
    /// backup is due; the app's own folder only. Wired by the Mac's
    /// composition (the phone keeps no backups); nil = no copy.
    @ObservationIgnored var lockTimeCopy: (@Sendable () -> Void)?
    /// pre-13x 2a (§11): the migration's leaves, built at READY for the
    /// store id in hand — production's `.live` (the production init wires
    /// it); a test injects its recorders here BEFORE the open completes;
    /// nil = no migration runs (the test-opener default).
    @ObservationIgnored var makeMigrationLeaves:
        (@MainActor (_ database: AppDatabase, _ storeID: String) -> ProtectionMigration.Leaves)?
    /// The last migration's report (a test-visible receipt; nil = none ran).
    @ObservationIgnored private(set) var lastMigrationReport: ProtectionMigration.Report?

    /// The store id the dials are keyed by, for THIS bootstrap's store
    /// (pre-13x 1a) — re-read per call, since "Start a New Library"
    /// changes it.
    private func currentStoreID() -> String? {
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
        return Self.storeID(besideStore: storeURL)
    }

    /// pre-13x 1a (§3.7): the three-door face's brain. Its one built act
    /// mints a fresh library under a NEW store id through the GATE (the
    /// guard seam — scripted in tests, the Keychain in production).
    private func makeMissingLobby(demand: StoreAtOpenMode, storeURL: URL?) -> LibraryMissingLobby {
        // VX-306 U1b: on the new road, Start a New Library is the protection core's creation.
        var newRoadCreate: (@MainActor () async -> String?)?
        if newRoad {
            newRoadCreate = { [weak self] in
                guard let self else { return nil }
                return await self.createOnNewRoadFromAFace()
            }
        }
        return LibraryMissingLobby(
            demand: demand,
            storeURL: storeURL,
            gate: gate,
            scope: storeVariant.rawValue,
            begin: { [weak self] in self?.beginOpening() },
            newRoadCreate: newRoadCreate)
    }

    private func makeLobby(_ facts: LobbyFacts) -> StoreLobby {
        let scope = storeVariant.rawValue
        let guardSeam = gate.guardFor(scope)
        let storeURL = facts.storeURL ?? URL(fileURLWithPath: "/dev/null")
        // pre-13x 4a: the local copies first, then the vault road (§3.6) —
        // the derived key of the successful road held in the SHARED session
        // the reconcile reads at ready.
        let envelopeRoad = StoreLobby.envelopeRoad(
            storeURL: storeURL, gate: gate, session: protection.syncCustodySession,
            vaultRoad: lobbyVaultRoad)
        let waiting: Bool
        if case .waitingForICloudKeychain = facts.kind { waiting = true } else { waiting = false }
        return StoreLobby(
            kind: facts.kind,
            demand: facts.demand,
            biometryOffered: facts.biometryOffered,
            passphraseOffered: facts.passphraseOffered,
            recoveryOffered: facts.recoveryOffered,
            envelopeUnreadable: facts.envelopeUnreadable,
            gatedRoad: { await guardSeam.unlockGated() },
            phasedRoad: envelopeRoad,
            // pre-13x 2a: the waiting kind re-probes the Apple road.
            appleRoad: waiting ? StoreLobby.appleRoad(scope: scope, storeURL: storeURL, gate: gate) : nil,
            complete: { [weak self] key in
                self?.beginOpening(unlockedKey: key)
            })
    }

    // MARK: - 13x U2: THE ADOPTION ROADS (row 6 — the doors' composition)

    /// The live store's url (the adoption's landing slot and the hold
    /// marker's home) — the test slot's under a test opener.
    var liveStoreURL: URL? {
        testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
    }

    /// The READY-state adoption: tear down exactly as a lock does
    /// (flush/savepoint/stop via `onWillLock`, the `.ready` tree down,
    /// the pool CLOSED through the binding), run the adoption `work`
    /// off-main (the U1 brain + the door's completion acts), then REOPEN
    /// — with the opener as in-memory custody on success (the pair's
    /// first open is silent; under Auto the custody write already landed
    /// inside `work`, under the demanded modes the lobby law holds), or
    /// with NOTHING on failure, letting the route find what stands (the
    /// aside home and the safety copy are the nets — `LibraryAdoption`'s
    /// order guarantees them before anything moved). `work`'s error
    /// rethrows AFTER the reopen, the `rekeyLibrary` shape.
    func adoptLibrary(
        reopeningWith key: StoreKey?,
        work: @escaping @Sendable () throws -> Void
    ) async throws {
        struct AdoptionNotReady: Error {}
        guard case .ready = state, let binding else { throw AdoptionNotReady() }
        await onWillLock?()
        state = .opening
        protection.dropResident()
        protection.resetPerOpenDeferrals()
        protection.syncCustodySession.drop()
        let outcome: Result<Void, any Error> = await Task.detached(priority: .userInitiated) {
            binding.lock()
            do {
                try work()
                return .success(())
            } catch {
                return .failure(error)
            }
        }.value
        switch outcome {
        case .success:
            beginOpening(unlockedKey: key)
        case .failure:
            beginOpening()
        }
        await awaitOpen()
        if case .failure(let error) = outcome { throw error }
    }

    /// 13x F1 (ladder R1-M4): the non-ready adoption road calls this
    /// BEFORE its `work` — the standing lobby's Apple re-probe polls
    /// every ~5 s and `complete(key)` would open the pool over the
    /// DEPARTING store mid-move (two bindings over two files, an
    /// unowned state). Idempotent; the lobby stays on screen, its probe
    /// silent, until the reopen routes — or `resumeLobbyAfterFailedAdoption`
    /// re-arms it.
    func suspendLobbyForAdoption() {
        if case .waitingForICloudKeychain(let lobby) = state { lobby.suspendForAdoption() }
        if case .locked(let lobby) = state { lobby.suspendForAdoption() }
    }

    /// R1-M4's failure half: a refused non-ready adoption leaves the
    /// lobby standing — it must go back to WAITING (the probe re-armed)
    /// rather than wait dead until a relaunch.
    func resumeLobbyAfterFailedAdoption() {
        if case .waitingForICloudKeychain(let lobby) = state { lobby.resumeAfterAdoption() }
        if case .locked(let lobby) = state { lobby.resumeAfterAdoption() }
    }

    /// The NON-ready road's reopen (the welcome/waiting/absent-store
    /// doors): the model ran the adoption work itself — no pool was ever
    /// open in these states, and `LibraryAdoption` refuses a hot `-wal`
    /// regardless — so what remains is leaving the standing lobby (its
    /// Apple re-probe stopped — R1-M4 suspends it BEFORE the work; this
    /// stop is the belt for any road that skipped the suspension) and
    /// routing the open with the opener in hand.
    func reopenAfterAdoption(unlockedKey key: StoreKey?) {
        if case .waitingForICloudKeychain(let lobby) = state { lobby.stopWaiting() }
        if case .locked(let lobby) = state { lobby.stopWaiting() }
        beginOpening(unlockedKey: key)
    }

    // MARK: - VX-306 U3: THE TWO DOORS (the new road only — rule 17)

    /// The two doors' roads on the new road (nil on today's road, before a library opens, and on a hosted test run's
    /// read-only road). Each road reads the CURRENT session at its call (a reopen replaces it).
    func copyDoorsRoads() -> CopyDoorsRoads? {
        guard newRoad, case .ready = state, let session = roadSession, session.writes else { return nil }
        return CopyDoorsRoads(
            listing: { [weak self] in
                guard let session = self?.roadSession else { return .empty }
                return await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.listing(session) }.value
            },
            opensQuietly: { [weak self] copy in
                guard let session = self?.roadSession else { return false }
                return await Task.detached(priority: .userInitiated) {
                    ProtectionCopyDoors.opensQuietly(session, copy)
                }.value
            },
            passphraseSet: { [weak self] in self?.roadSession?.library.keyFile?.passphrase != nil },
            makeMine: { [weak self] row, copySecrets, currentPair in
                guard let self else { return .refused(.failed) }
                return await self.makeThisMyLibrary(row, copySecrets: copySecrets, currentPair: currentPair)
            },
            pick: { [weak self] url in
                guard let session = self?.roadSession else {
                    return .refused(ProtectionWords.makeMineFailed, detail: nil)
                }
                return await Task.detached(priority: .userInitiated) {
                    ProtectionCopyDoors.pick(url, session: session)
                }.value
            },
            // VX-306 U3 — LOOK INSIDE (P-VX306-U3-15): read-only, writes nothing, closing forgets.
            lookInside: { [weak self] copy, typed, quietRoads in
                guard let session = self?.roadSession else { return .refused(.failed) }
                return await Task.detached(priority: .userInitiated) {
                    ProtectionCopyDoors.lookInside(CopyDoorsContext(session), copy: copy, typed: typed, quietRoads: quietRoads)
                }.value
            })
    }

    /// VX-306 U3 — the two doors' roads with NO library open (the missing face's and rule 27's *Open Library…*,
    /// P-VX306-U3-7 narrowed at the ruling): a pick filed, then Look inside; Make this my library is not offered (no
    /// current pair to verify — the empty-slot landing, T-5, is VX-309's). nil on today's road and on a hosted test run's
    /// read-only road (the filing writes).
    func copyDoorsRoadsWithoutALibrary() -> CopyDoorsRoads? {
        guard newRoad, let road = roadInputs?.compose(), road.writes else { return nil }
        // The road's context (its sign-in read) is taken off the main actor, inside each detached read.
        let context: @Sendable () -> CopyDoorsContext = { CopyDoorsContext(road.context()) }
        return CopyDoorsRoads(
            listing: {
                await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.listing(context()) }.value
            },
            opensQuietly: { copy in
                await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.opensQuietly(context(), copy) }.value
            },
            passphraseSet: { false },
            makeMine: nil,
            pick: { url in
                await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.pick(url, context()) }.value
            },
            lookInside: { copy, typed, quietRoads in
                await Task.detached(priority: .userInitiated) {
                    ProtectionCopyDoors.lookInside(context(), copy: copy, typed: typed, quietRoads: quietRoads)
                }.value
            })
    }

    /// **MAKE THIS MY LIBRARY** (rule 17; the plan's U3 addendum) — one confirmed door, on the new road at ready. Every
    /// check first, all reads (`ProtectionCopyDoors.preflight` — a typo never tears the window down); then
    /// `adoptLibrary`'s seam shape: the composition root's teardown (`onWillLock` — flush, savepoint, stop), the
    /// `.ready` tree down, the app's pool CLOSED through the binding (a checkpoint-truncate, then the close — the
    /// swap's precondition), and the act off the main actor (`ProtectionCopyDoors.makeMine`: the restore hold by the
    /// core writer, the executor's plan, today's store id minted fresh); then the reopen THROUGH THE NEW ROAD with the
    /// key that opens the slot now in hand (the new library's; the old one's when nothing swapped). The receipt
    /// (§7c (9)) is owed to the reopened session. One act at a time on the session.
    func makeThisMyLibrary(
        _ row: CopyDoorRow, copySecrets: TypedSecrets, currentPair: TypedSecrets
    ) async -> CopyDoorOutcome {
        guard newRoad, case .ready = state, let binding, let session = roadSession, session.writes else {
            return .refused(.failed)
        }
        guard session.beginAct() else { return .refused(.busy) }
        let preflight = await Task.detached(priority: .userInitiated) {
            ProtectionCopyDoors.preflight(session, row: row, copySecrets: copySecrets, currentPair: currentPair)
        }.value
        let copy: CatalogCopy
        let catalog: Catalog
        switch preflight {
        case .refused(let why):
            session.endAct()
            return .refused(why)
        case .ready(let ready, let listed):
            copy = ready
            catalog = listed
        }
        await onWillLock?()
        state = .opening
        protection.dropResident()
        protection.resetPerOpenDeferrals()
        protection.syncCustodySession.drop()
        let gate = gate
        let scope = storeVariant.rawValue
        let result = await Task.detached(priority: .userInitiated) {
            binding.lock()
            return await ProtectionCopyDoors.makeMine(
                session, copy: copy, catalog: catalog, row: row, copySecrets: copySecrets, currentPair: currentPair,
                mintStoreIdentity: { key in
                    Self.ensureStoreIdentity(slot: session.system.places.slot, key: key, fresh: true, gate: gate, scope: scope)
                })
        }.value
        session.endAct()
        if result.outcome == .made { receiptsForNextRoadOpen.append(ProtectionWords.makeMineReceipt) }
        beginOpening(unlockedKey: result.reopenKey)
        await awaitOpen()
        return result.outcome
    }

    // MARK: - VX-307 U2a: THE CROSSINGS (the new road only — rules 11, 12; Replace All Keys)

    /// The crossings' roads on the new road. Each reads the CURRENT session at its call (a reopen replaces it); nil
    /// sessions, today's road and a hosted test run's read-only road answer with nothing done.
    func crossingRoads() -> RoadCrossingRoads {
        let exports = exportSwitch
        return RoadCrossingRoads(
            read: { [weak self] in
                guard let self, self.newRoad, case .ready = self.state, let session = self.roadSession else { return nil }
                return await Task.detached(priority: .userInitiated) {
                    ProtectionCrossings.readCrossings(session, exportSwitch: exports)
                }.value
            },
            cross: { [weak self] request in
                guard let self else { return .refused(ProtectionWords.crossingFailed) }
                return await self.crossOnNewRoad(request)
            },
            changeGate: { [weak self] gate, passphrase in
                guard let session = self?.roadSession, session.writes else { return .refused(ProtectionWords.gateRowFailed) }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionCrossings.changeGate(session, to: gate, passphrase: passphrase)
                }.value
            },
            turnExportBackOn: { [weak self] in
                guard let session = self?.roadSession, session.writes else { return false }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionCrossings.turnExportBackOn(session, exportSwitch: exports)
                }.value
            })
    }

    /// **A CROSSING** (Use Castle · Use Standard · Replace All Keys) — Make this my library's seam shape: every check
    /// first, all reads (`ProtectionCrossings.preflight` — the door RE-READ, VX-108; the typed pair against the live key
    /// file — a typo never tears the window down); then the composition root's teardown (`onWillLock` — flush,
    /// savepoint, stop), the `.ready` tree down, the app's pool CLOSED through the binding (the swap's precondition), and
    /// the core's act off the main actor on its sealed plan (rule 20); then the reopen THROUGH THE NEW ROAD with the key
    /// that opens the slot now (the new one; the old one when nothing swapped), the act's receipt owed to the reopened
    /// session, and Settings asked back to Protection, where she acted (VX-206's road). One act at a time on the session.
    func crossOnNewRoad(_ request: RoadCrossingRequest) async -> RoadCrossingPress {
        guard newRoad, case .ready = state, let binding, let session = roadSession, session.writes else {
            return .refused(ProtectionWords.crossingFailed)
        }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        let exports = exportSwitch
        let preflight = await Task.detached(priority: .userInitiated) {
            ProtectionCrossings.preflight(
                session, door: request.door, shown: request.shown, typed: request.typed, exportSwitch: exports)
        }.value
        switch preflight {
        case .ready:
            break
        case .refused(let sentence):
            session.endAct()
            return .refused(sentence)
        case .changed(let fresh):
            session.endAct()
            return .changed(fresh)
        }
        await onWillLock?()
        state = .opening
        protection.dropResident()
        protection.resetPerOpenDeferrals()
        protection.syncCustodySession.drop()
        let result = await Task.detached(priority: .userInitiated) {
            binding.lock()
            return await ProtectionCrossings.cross(
                session, door: request.door, typed: request.typed, gate: request.gate, exportSwitch: exports)
        }.value
        session.endAct()
        if case .made(let door, _) = result.outcome { receiptsForNextRoadOpen.append(door.receipt) }
        beginOpening(unlockedKey: result.reopenKey)
        await awaitOpen()
        protection.requestProtectionPaneForRoadCrossing()
        switch result.outcome {
        case .made(_, let exportTurnedOff): return .made(exportTurnedOff: exportTurnedOff)
        case .refused(let sentence): return .refused(sentence)
        }
    }

    /// The weekly plain-text copy's switch (`MarkdownInsurance`) over a defaults domain — nil: this Mac's standard
    /// defaults (production); a test bootstrap names its own suite.
    nonisolated static func markdownInsuranceSwitch(suiteName: String?) -> ScheduledExportSwitch {
        guard let suiteName else {
            return ScheduledExportSwitch(
                isOn: { MarkdownInsurance.isEnabled(in: .standard) },
                set: { MarkdownInsurance.setEnabled($0, in: .standard) })
        }
        // A named suite only — never falls back to the app's domain (a suite that can't be made reads off, writes nothing).
        return ScheduledExportSwitch(
            isOn: { UserDefaults(suiteName: suiteName).map { MarkdownInsurance.isEnabled(in: $0) } ?? false },
            set: { value in
                if let suite = UserDefaults(suiteName: suiteName) { MarkdownInsurance.setEnabled(value, in: suite) }
            })
    }

    /// A test bootstrap's scheduled-export domain — never the app's.
    nonisolated static let crossingTestExportSuiteName = "io.lduarte.Variorum.vx307-crossing-tests"

    // MARK: - pre-13x 2b: THE RE-KEY ROAD (§4 step 4 — "the pool closed
    // first; off-main")

    /// Re-key the open library: flush and stop (the composition root's
    /// `onWillLock`), tear the `.ready` tree down (`.opening` renders
    /// quietly), CLOSE the pool through the binding, run `work` (the
    /// export-and-swap — `StoreEncryptionMigration.rekey`) off-main, then
    /// REOPEN under whichever key opens the file now (the new one after
    /// the swap; the old one if the work threw before it — the file is
    /// under exactly one, pinned in core) and re-adopt through the same
    /// binding. `work`'s error rethrows AFTER the reopen, so the app is
    /// never left without its store. The runner's per-step marker owns the
    /// resume.
    func rekeyLibrary(
        from oldKey: StoreKey, to newKey: StoreKey,
        work: @escaping @Sendable () throws -> Void
    ) async throws {
        guard case .ready = state, let binding else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        // VX-202 (gate i): before the reopen below can reach the ready.
        switchInProgress = true
        await onWillLock?()
        state = .opening
        protection.dropResident()
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
        let outcome: Result<Void, any Error> = await Task.detached(priority: .userInitiated) {
            binding.lock()
            do {
                try work()
                return .success(())
            } catch {
                return .failure(error)
            }
        }.value
        // Which key opens the file NOW decides the reopen (the probe reads
        // one page; never a guess).
        let reopenKey: StoreKey = await Task.detached(priority: .userInitiated) {
            guard let storeURL else { return oldKey }
            return StoreEncryptionMigration.opens(storeURL, key: newKey) ? newKey : oldKey
        }.value
        beginOpening(unlockedKey: reopenKey)
        await awaitOpen()
        // VX-206: the reopen rebuilt the Settings scene at its default pane —
        // a ceremony hosted by Settings ▸ Protection asks for that pane back
        // (a no-op for every other host; the request outlives the window).
        protection.requestProtectionPaneForCeremony()
        if case .failure(let error) = outcome { throw error }
    }

    /// VX-202 (gate i): the runner's clear — the switch's custody move has
    /// landed. A road that throws before it leaves the flag set: the switch
    /// is still pending (its marker says so), and the resume clears it.
    func endSwitch() {
        switchInProgress = false
    }

    // MARK: - Re-lock (13p — demanded modes only; Lock Now and the
    // re-lock policy both land here)

    /// Whether Lock Now is a real act right now (P-2: the door renders
    /// only where it acts): ready, bound, and a demanded mode.
    ///
    /// Reads the OBSERVABLE dials projection (ladder R1-m2): `gate.dials`
    /// is an un-observed defaults read, so the Mac menu and the phone's
    /// sheet never re-evaluated on a mode flip — the Lock Now door went
    /// stale until the next unrelated state change. Every dial write goes
    /// through the controller (and `reconcile` re-reads the persisted
    /// truth for the one launch-route write that doesn't), so the
    /// projection is current; `lock()` keeps consulting the persisted gate
    /// as the ACTING authority.
    var canLock: Bool {
        // VX-306 U1b: no lock on the new road this phase — every library it opens is Standard (no Castle entry
        // exists before VX-307), and Standard never locks (rule 8's quiet roads; today's Auto refusal).
        guard !newRoad else { return false }
        guard case .ready = state, binding != nil else { return false }
        return protection.effectiveGate.isDemanded
    }

    /// The teardown, in the ruled order: flush/savepoint/stop (the
    /// composition root's `onWillLock`), flip to the lobby (views and
    /// their held observations tear down with the `.ready` subtree),
    /// then CLOSE the pool and DROP the key — off the main actor, since
    /// close blocks until in-flight accesses complete. Under Auto this
    /// refuses silently: a lock whose key auto-releases at the next open
    /// is theater, and no theater ships (R13p-14).
    func lock() async {
        guard !newRoad else { return }  // VX-306 U1b: see `canLock`
        guard case .ready = state, let binding else { return }
        let scope = storeVariant.rawValue
        // pre-13x 2a: the derived effective gate is the acting authority.
        let demand = currentEffectiveGate
        guard demand.isDemanded else { return }
        await onWillLock?()
        let gate = gate
        let storeURL = testOpener != nil
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
        let facts = await Task.detached(priority: .userInitiated) { () -> LobbyFacts in
            let guardSeam = gate.guardFor(scope)
            let reading = gate.readEnvelope(storeURL)
            return LobbyFacts(
                demand: demand,
                biometryOffered: demand == .biometric && guardSeam.gatedItemExists(),
                passphraseOffered: LobbyFacts.passphraseRoadExists(reading.envelope),
                recoveryOffered: LobbyFacts.recoveryRoadExists(reading.envelope),
                envelopeUnreadable: reading.isUnreadable,
                storeURL: storeURL)
        }.value
        state = .locked(makeLobby(facts))
        protection.dropResident()
        // pre-13x 4a (the 2c adjudication's item 1): a relock + unlock is an
        // OPEN — every per-open deferral (the follow's Later, the migration
        // confirm's Later, the change notice's dismiss) resets here.
        protection.resetPerOpenDeferrals()
        // pre-13x 1a: the sync keys held for the unlocked session (the
        // gated record, the Always-ask derived key) go with the library
        // key — a locked library reads as no keys (pinned). pre-13x 4a: the
        // CONTROLLER's session (production's `.shared`; a pin's own).
        protection.syncCustodySession.drop()
        let lockTimeCopy = lockTimeCopy
        _ = await Task.detached(priority: .userInitiated) {
            binding.lock()
            // pre-13x 2a (row 7): the keyless byte-copy of the CLOSED
            // library — after the pool closed and the key dropped, never
            // before (a copy is writing, never a device; no key opens it
            // here). Quiet on failure; the next unlock's run retries.
            lockTimeCopy?()
        }.value
    }
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
            at: url, custody: custody ?? .deviceKeychain(scope: variant.rawValue, storeURL: url)))
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

// MARK: - The library-missing lobby (pre-13x 1a — the postures design §3.7)

/// The absent-store route's brain, shared by both faces (the Mac's
/// `LibraryMissingView`, the phone's `MobileLibraryMissingView`). It holds
/// NO store: the library file is what is missing. Copy §3 renders verbatim
/// from `ProtectionCopy.libraryMissing*`.
///
/// THE DOORS, per P-2 (a door that cannot act is not rendered): **Start a
/// New Library** on both targets (built here); **Restore from a Backup…**
/// on the Mac only, revealing the app's own Backups folder beside the
/// runbook — the 13l restore is a manual road today — and only when that
/// folder exists; **Open an Existing Library…** on neither — it is 13x's
/// door, unbuilt (recorded in the 1a record).
///
/// STARTING NEW mints under a NEW STORE ID (decision 13 / §3.7): the old
/// key file beside the absent store is SET ASIDE (never deleted — its
/// wraps are the old library's recovery legs), a fresh key + key file are
/// minted (`StoreIdentity.establish` writes the id and fingerprint before
/// any custody exists), the new id's dials are written as Auto (the design's
/// Standard birth — a fresh library is Standard; the OLD library's lock —
/// its legacy scope dials and its per-store custody items — is untouched,
/// so restoring the old file routes it to its lobby exactly as before),
/// the key lands in custody through the gate's guard, and the ordinary
/// route then opens the fresh library. Nothing here touches the old
/// library's items: per-store naming makes them unreachable, never gone.
@MainActor
@Observable
final class LibraryMissingLobby {
    let demand: StoreAtOpenMode
    /// The absent store's url (nil = no resolvable path: no act can run).
    let storeURL: URL?
    private(set) var busy = false
    var lastError: String?

    private let gate: StoreLaunchGate
    private let scope: String
    private let begin: @MainActor () -> Void
    /// VX-306 U1b — on the new road (the one switch), the deliberate act is the protection core's creation;
    /// nil on today's road (the act below, unchanged). Answers the face's sentence, nil when it went on.
    private let newRoadCreate: (@MainActor () async -> String?)?

    init(
        demand: StoreAtOpenMode, storeURL: URL?, gate: StoreLaunchGate,
        scope: String, begin: @escaping @MainActor () -> Void,
        newRoadCreate: (@MainActor () async -> String?)? = nil
    ) {
        self.demand = demand
        self.storeURL = storeURL
        self.gate = gate
        self.scope = scope
        self.begin = begin
        self.newRoadCreate = newRoadCreate
    }

    /// The app's own Backups folder beside the (absent) store — the Mac's
    /// "Restore from a Backup…" reveals it; nil when there is none to show.
    var backupsFolderURL: URL? {
        guard let storeURL else { return nil }
        let folder = storeURL.deletingLastPathComponent()
            .appendingPathComponent("Backups", isDirectory: true)
        return FileManager.default.fileExists(atPath: folder.path) ? folder : nil
    }

    /// The one built act (§3.7): a fresh library under a NEW store id.
    func startNewLibrary() async {
        guard !busy, let storeURL else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        if let newRoadCreate {
            lastError = await newRoadCreate()
            return
        }
        let gate = gate
        let scope = scope
        let outcome = await Task.detached(priority: .userInitiated) { () -> String? in
            // 1. The old library's key file aside (never deleted).
            gate.setAsideEnvelope(storeURL)
            // 2. A fresh key + its key file — the NEW store id exists on
            //    disk before any custody does.
            let key = StoreKey.mint()
            let storeID: String
            do {
                storeID = try StoreIdentity.establish(besideStore: storeURL, key: key)
            } catch {
                return "The new library's key file could not be written beside the library: "
                    + "\(String(describing: error))"
            }
            // 3. The new library is born Standard (silent): its OWN dials,
            //    Auto — the old library's dials are never written.
            gate.saveDials(ProtectionDials(), scope, storeID)
            // 4. Custody, through the gate's guard (the Keychain in
            //    production; the scripted backing in tests).
            guard gate.guardFor(scope).saveAuto(key) else {
                return "The Keychain refused to keep the new library's key — nothing was created."
            }
            return nil
        }.value
        if let outcome {
            lastError = outcome
            return
        }
        // 5. The ordinary route: an absent store under Auto dials mints
        //    and opens the fresh library.
        begin()
    }
}
