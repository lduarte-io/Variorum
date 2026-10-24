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
//  THE PROTECTION ROAD (VX-306 U1b → VX-329 U1, the release switch): the
//  launch ROUTES through the rebuilt protection core (`ProtectionOpenRoad`
//  — `assess` decides, the executor acts) before any store open: the quiet
//  roads at once, else the road's lobby — no store, no migration, no
//  session, no services (everything downstream exists only inside
//  `.ready`) — and the lobby's unlock is the only door forward. It is the
//  ONLY road, in every build (`ProtectionRoad`); today's road (the 13p
//  lobby, the pre-13x posture and migration machinery, the 13x adoption)
//  was deleted at the switch (CastleRules rule 26). RE-LOCK (`lock()`,
//  Castle only): the composition root's teardown — flush/stop via
//  `onWillLock`, the `.ready` tree down, then CLOSE the pool and DROP key
//  material through the `StoreBinding` the first open installed, and land
//  in the road's own lobby. The ambient `\.database` is the binding's VIEW,
//  so every ambient holder survives the re-lock and the re-open without
//  changing a line; an access racing the lock gets the typed
//  `StoreLockedError`.
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
        /// No library in the slot (the road's `.libraryMissing`) — the
        /// three-door face; nothing opened, nothing persisted.
        case libraryMissing(LibraryMissingLobby)
        case ready(AppSession)
        /// The open failed — the road's own sentence, or the store open's
        /// typed failure; the retry is the only door.
        case failed(AppDatabase.StoreOpenError)
        /// VX-306 U1b — THE ROAD's lobby: roads only, before unlock; the quiet
        /// roads were already tried at once (`ProtectionOpenRoad.route`).
        case roadLobby(ProtectionLobbyModel)
        /// VX-306 U1b — the once-shown words card of a library just created on the road (rule 2); its
        /// one button opens the library. VX-307 U2b: the PHONE's only — the Mac's first open has nothing in front
        /// (`ProtectionRoad.showsWordsAtCreation`; the words wait for her look, from the card above the quick entry).
        case newLibraryWords(LibraryWordsCardModel)
        /// VX-306 U2 — the open's INTERLUDE, in the lobby's room between the unlock and the
        /// library's open (PROVISIONAL P-VX306-U2-1): rule 21's notice (once), then the key-file offer; the last
        /// card answered, the open goes on.
        case roadInterlude(RoadInterludeModel)
    }

    private(set) var state: State = .opening
    /// Which store home this process resolved to (A4) — surfaced so a dev
    /// build is visibly a dev build.
    let storeVariant: AppDatabase.StoreVariant
    /// The relock monitors (sleep · screen lock · idle) and the Settings pane
    /// request — VX-329: the controller's road arms only.
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

    /// TEST-ONLY: a bootstrap over a test's own temp slot (`init(testStoreURL:protectionRoad:)`) — it **skips the
    /// process-global `prepareDependencies` installs**: installing a test's store as the app's ambient one would poison
    /// every other test in the process (and `prepareDependencies` may only be called before anything reads a
    /// dependency). The state machine, the off-main hop, the lobby routing and `retry()` are otherwise production's.
    @ObservationIgnored private let isTestBootstrap: Bool
    /// TEST-ONLY: the SCRATCH store url a test bootstrap's slot and the missing-library face work beside — never the
    /// real dev home.
    @ObservationIgnored private let testStoreURL: URL?
    /// VX-306 U1b — the road's inputs: the protection system composed per open on the main actor, the sign-in read
    /// off-main, whether the road may write (never in a hosted test run), and — under a test — the opener that takes
    /// the key in hand.
    @ObservationIgnored private let roadInputs: RoadInputs
    /// VX-306 U1b — the library open on the road (nil before the first open and behind the lobby): the backup hook's
    /// key, key file and device ID; U2's faces read its report (the notice, the repairs, the faults, the acts owed).
    @ObservationIgnored private(set) var roadSession: ProtectionRoadSession?
    /// VX-307 U1 — the engine's key seam: attached to the road session at each ready; the composition site hands it to
    /// `AppServices` as the sync key provider.
    @ObservationIgnored let newRoadSyncKeys = NewRoadSyncKeyProvider()
    /// VX-329 U3 — VX-423: THE PROCESS'S ONE REFRESH AUTHORITY — the scope's signed-in session, its rotating refresh
    /// token refreshed single-flight in this one actor for every caller. Owned HERE because the bootstrap lives for the
    /// process (across every lobby, locked window and reopen) while the services die at each relock: the road's inputs
    /// hand it to every composed system's vault leaf, and the composition root hands it to `AppServices` (`auth:` —
    /// required). The only `AuthSession` the product mints (`authority(_:)`); two used to stand over the one stored
    /// token — the services' and the vault leaf's — and the second to refresh presented a token the first had spent
    /// (`refresh_token_already_used`: the family revoked, sync stopped until a new sign-in). Construction reads nothing
    /// (13e B-1's lazy load: the Keychain is consulted at first use, on the actor's executor).
    @ObservationIgnored let auth: AuthSession
    /// VX-487 F-M1-1 — THE PROCESS'S ONE SYNC-KEYS LEAF (the run record's THE RULING, option (i) — VX-423's shape): the
    /// account's sync keys in SESSION memory (Always ask's custody; a Castle + Touch ID act's hold and the Touch ID
    /// unlock's load) live in this one instance, handed to every system the road composes (`RoadInputs.live` →
    /// `ProtectionSystem.live`), because every re-keying act reopens through a FRESH composition and a leaf minted per
    /// system lost the act's hold at that reopen ("Sync locked" right after a join). Owned HERE because the bootstrap lives
    /// for the process; the explicit clears (the lock's drop, a rollback's, a leave's) reach it unchanged, and "gone at a
    /// relock or a crash" holds by them and by the process. One process serves one store variant, so one leaf is one per
    /// scope. Construction reads nothing (the Keychain is touched only by a read or a write).
    @ObservationIgnored private let syncKeys: any SyncKeysLeaf
    /// VX-306 U2 — the open library's protection faces: rule 27's banner, rule 3's reminder and its set-passphrase
    /// sheet, the receipts the open owes.
    private(set) var roadStanding: RoadStandingModel?
    /// VX-306 U2 — rule 3's local schedule (this Mac's defaults; a test bootstrap writes its own suite, never the
    /// app's domain).
    @ObservationIgnored private let reminderLedger: PassphraseReminderLedger
    /// VX-306 U3 — receipts the NEXT open owes the status seam (Make this my library's §7c (9)): handed to the session
    /// the reopen makes, then spoken by the ready composition like every owed receipt.
    @ObservationIgnored private var receiptsForNextRoadOpen: [String] = []
    /// **VX-468 (her "wait", QUESTIONS #237):** a copy door landed a library in this process — Make this my library, the
    /// empty slot's landing, a plain-text copy brought in. Set before the landing's open, so the ready window that open
    /// makes reads it: the Mac's What's New waits for the next ordinary launch rather than greeting the adopted library's
    /// first open (`WhatsNewLedger.claimAutoShow(afterAdoption:)`). Never reset — one process, one automatic show.
    @ObservationIgnored private(set) var adoptedALibraryThisProcess = false
    /// VX-307 U2a — the crossings (nil before the first open): OWNED HERE because a crossing reopens the library — the
    /// `.ready` tree, the Settings pane and its `@State` go down and come back, and the confirm in flight, its refusal
    /// and rule 11's notice must survive that. Made at the first ready.
    private(set) var roadCrossings: RoadCrossingsModel?
    /// VX-308 U1 — THE ONE PRESENTER for the protection sheets (VX-239 + VX-243) and the account section's model:
    /// owned here beside the crossings for the same reason (a crossing's reopen rebuilds every view). Made at the first
    /// ready; the presenter drops its sheet at every settled closed state (`finish`).
    private(set) var protectionSheets: ProtectionSheetPresenter?
    private(set) var roadAccount: RoadAccountModel?
    /// VX-308 U3 — the key doors (Change passphrase…, Reset forgotten passphrase…, New Words' face), made once beside the
    /// crossings and the account section for the same reason, presenting through the one presenter.
    private(set) var roadKeyDoors: RoadKeyDoorsModel?
    /// VX-307 U2a — this Mac's scheduled plain-text export (the weekly copy's switch, `MarkdownInsurance`): the
    /// production instance's standard defaults; a test bootstrap's own suite, never the app's domain.
    @ObservationIgnored private let exportSwitch: ScheduledExportSwitch

    init(variant: AppDatabase.StoreVariant = StoreLocation.resolve()) {
        storeVariant = variant
        isTestBootstrap = false
        testStoreURL = nil
        // pre-13x 2c (corner 47): the session's Keychain item is SCOPED by store variant — a dev-store build starts
        // signed out and never adopts the installed build's session.
        auth = Self.authority(.keychain(scope: variant.rawValue))
        syncKeys = KeychainSyncKeysLeaf(scope: variant.rawValue)
        roadInputs = RoadInputs.live(variant: variant, auth: auth, syncKeys: syncKeys)
        reminderLedger = PassphraseReminderLedger()
        exportSwitch = Self.markdownInsuranceSwitch(suiteName: nil)
        protection = ProtectionController()
        protection.performLock = { [weak self] in await self?.lock() }
        // VX-308 U4 — VX-445: the relock monitors read the OPEN library's policy (Castle; this Mac's sealed idle minutes).
        protection.roadRelock = { [weak self] in self?.roadRelockPolicy }
        #if os(macOS)
        // Production instances only: the monitors re-check the policy at
        // fire time, so they are safe always-on listeners.
        protection.startRelockMonitors()
        #endif
        beginOpening()
    }

    /// TEST-ONLY: a bootstrap over a test's temp slot and a throwaway scope — the protection system, the sign-in and
    /// the keyed opener the harness hands in (`ProtectionRoadTestHarness`).
    init(testStoreURL: URL? = nil, protectionRoad: ProtectionRoadTestHarness) {
        storeVariant = .dev
        isTestBootstrap = true
        self.testStoreURL = testStoreURL
        // VX-423: a test bootstrap's authority is signed out and in memory — its road is the harness's (a planted
        // system), and no test reaches the scope's Keychain item through it.
        auth = Self.authority(.inMemory())
        // VX-487 F-M1-1: the harness's own leaf (its one system — tests inject their own; nothing is minted here).
        syncKeys = protectionRoad.system.leaves.syncKeys
        roadInputs = RoadInputs.test(protectionRoad)
        reminderLedger = PassphraseReminderLedger(
            defaults: UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard)
        exportSwitch = Self.markdownInsuranceSwitch(suiteName: Self.crossingTestExportSuiteName)
        protection = ProtectionController()
        protection.performLock = { [weak self] in await self?.lock() }
        // VX-308 U4 — VX-445: the production init's wiring, the same on a test bootstrap.
        protection.roadRelock = { [weak self] in self?.roadRelockPolicy }
        beginOpening()
    }

    func retry() {
        beginOpening()
    }

    /// VX-423 — the product's ONE `AuthSession` construction (the composition pin counts it): the Variorum project's
    /// sign-in over `store`.
    private static func authority(_ store: AuthTokensStore) -> AuthSession {
        AuthSession(configuration: ProjectConfig.variorumAuth, store: store)
    }

    /// Awaits the in-flight open. Production never calls it (the roots
    /// render `.opening`); pins use it instead of spinning.
    func awaitOpen() async {
        await opening?.value
    }

    // MARK: - The open road (routes first)

    private func beginOpening(unlockedKey: StoreKey? = nil, roadOpened: ProtectionRoadSession? = nil) {
        guard opening == nil else { return }
        state = .opening
        let variant = storeVariant
        let storeURL = liveStoreURL
        // VX-306 U1b: the road's system, composed ONCE per open on the main actor (U1a's hand-forward).
        let road = roadInputs.compose()
        opening = Task { [weak self] in
            // OFF the main actor: the road's facts (custody, the key file, the memory item), then — on the open
            // routes only — `openStore`, which runs the migration set. The lobby DEFERS all of that.
            let outcome = await Task.detached(priority: .userInitiated) {
                await Self.routeAndOpen(
                    variant: variant, storeURL: storeURL, unlockedKey: unlockedKey, road: road, roadOpened: roadOpened)
            }.value
            guard let self else { return }
            // …and back, for `install` (a process-global dependency
            // installation) and the state write, both MainActor by contract.
            self.finish(outcome)
        }
    }

    private enum OpenOutcome: Sendable {
        case ready(AppDatabase, unlockedKey: StoreKey?, road: ProtectionRoadSession? = nil)
        /// VX-306 U1b: the road's lobby, its facts and the context its presses run in.
        case roadLobby(RoadLobbyFacts, RoadContext)
        /// VX-306 U1b: a library created on the road — the words card first.
        case roadCreated(ProtectionRoadSession, OnceShownWords)
        /// VX-306 U2: an open that owes the interlude (rule 21's notice, the offer) first.
        case roadInterlude(ProtectionRoadSession, RoadContext)
        case libraryMissing(storeURL: URL?)
        case failed(AppDatabase.StoreOpenError)
    }

    /// The road's route (`ProtectionOpenRoad.route` decides nothing — `assess` does), then the app's open
    /// with the key in hand. A session already opened (the lobby's press, the words card's button) goes
    /// straight to the open.
    private nonisolated static func routeAndOpen(
        variant: AppDatabase.StoreVariant, storeURL: URL?, unlockedKey: StoreKey?, road: ComposedRoad?,
        roadOpened: ProtectionRoadSession?
    ) async -> OpenOutcome {
        guard let road else {
            return .failed(AppDatabase.StoreOpenError(
                storePath: storeURL?.path ?? "", reason: ProtectionWords.somethingWentWrong))
        }
        if let roadOpened {
            // VX-306 U2: a session the lobby's press opened may owe the interlude too (shown once per open).
            if roadOpened.owesInterlude { return .roadInterlude(roadOpened, road.context()) }
            return openOnTheRoad(roadOpened, road: road, variant: variant)
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
            return openOnTheRoad(session, road: road, variant: variant)
        case .created(let session, let words):
            return .roadCreated(session, words)
        case .lobby(let facts):
            return .roadLobby(facts, ctx)
        case .libraryMissing:
            // `.libraryMissing`, and K5's `recordMissing` — the three-door face, no sentence about the store.
            return .libraryMissing(storeURL: storeURL)
        case .failed(let sentence):
            return .failed(AppDatabase.StoreOpenError(storePath: road.system.places.slot.path, reason: sentence))
        }
    }

    /// The app's open with the road's key in hand (`StoreKeyCustody.inMemory` — no device-keychain custody exists
    /// outside the protection core, rule 26).
    private nonisolated static func openOnTheRoad(
        _ session: ProtectionRoadSession, road: ComposedRoad, variant: AppDatabase.StoreVariant
    ) -> OpenOutcome {
        let key = session.key
        let opened = road.open?(key) ?? openStoreOffMain(variant: variant, custody: .inMemory(initial: key))
        switch opened {
        case .success(let database): return .ready(database, unlockedKey: key, road: session)
        case .failure(let error): return .failed(error)
        }
    }


    private func finish(_ outcome: OpenOutcome) {
        opening = nil
        // VX-308 U1 (VX-239's rule): an open that settles anywhere but ready — the lobby, the interlude, the missing
        // face, a failure, a creation — drops the protection sheet standing, so it never re-presents after an unlock.
        // (A crossing's own reopen settles ready, so its confirm survives it.)
        if case .ready = outcome {} else {
            protectionSheets?.libraryClosed()
            // VX-308 U3 — VX-448: and the words a look copied leave the clipboard (the lock's clear).
            Self.clearWordsAtLock()
        }
        switch outcome {
        case .ready(let database, _, let road):
            // VX-306 U1b: the library open on the road.
            roadSession = road
            // VX-307 U1: the engine's key seam follows the open (nil detaches).
            newRoadSyncKeys.attach(road)
            // VX-306 U3: a receipt an act owed this reopen (Make this my library) joins the open's own.
            if let road {
                for receipt in receiptsForNextRoadOpen { road.addReceipt(receipt) }
                receiptsForNextRoadOpen = []
            }
            // VX-307 ladder round 1 (MAJOR-1): rule 11's switch-off reconciled at every ready — an entry finished by
            // this open's settle (it stopped past its swap) has its switch followed here, and says so once.
            if let road, road.writes, ProtectionCrossings.reconcileExport(road.library, exportSwitch: exportSwitch) {
                road.addReceipt(ProtectionWords.exportTurnedOffNotice)
            }
            // VX-306 U2: its protection faces (rule 27's banner, rule 3's reminder, the receipts).
            // VX-307 U2b: …and the card above the quick entry (the words' look copies through the platform's one rule).
            roadStanding = road.map {
                RoadStandingModel.make($0, ledger: reminderLedger, copyWords: { Self.copyWords($0) }, signInNow: signInNow)
            }
            // VX-307 U2a: the crossings — made once, kept across every reopen; the faces carry them to the pane.
            // VX-308 U1: the one presenter and the account section beside them, made once the same way; the crossings
            // present through the presenter (VX-239 + VX-243).
            if road != nil, protectionSheets == nil { protectionSheets = ProtectionSheetPresenter() }
            if road != nil, roadCrossings == nil, let sheets = protectionSheets {
                roadCrossings = RoadCrossingsModel(roads: crossingRoads(), presenter: sheets)
            }
            if road != nil, roadAccount == nil, let sheets = protectionSheets {
                roadAccount = RoadAccountModel(roads: accountRoads(), presenter: sheets)
            }
            // VX-308 U3: the key doors, made once the same way.
            if road != nil, roadKeyDoors == nil, let sheets = protectionSheets {
                roadKeyDoors = RoadKeyDoorsModel(roads: keyDoorRoads(), presenter: sheets)
            }
            roadStanding?.crossings = roadCrossings
            roadStanding?.account = roadAccount
            roadStanding?.sheets = protectionSheets
            roadStanding?.keyDoors = roadKeyDoors
            // VX-308 ladder round 1 (MINOR-2): the pane's appearance reads ONCE for its three sections.
            roadStanding?.paneWave = { [weak self] in await self?.paneWave() ?? ProtectionPaneWave() }
            let view: AppDatabase
            if let binding {
                // The re-open after a lock: the SAME ambient view adopts
                // the fresh pool — no second install, no new view.
                do {
                    try binding.adopt(database)
                } catch {
                    state = .failed(AppDatabase.StoreOpenError(storePath: "", reason: String(describing: error)))
                    return
                }
                view = ambient ?? database
            } else {
                let wrapped = database.asRebindable()
                binding = wrapped.binding
                ambient = wrapped.view
                view = wrapped.view
            }
            if !installed, !isTestBootstrap {
                AppDatabase.install(view)
                // Phase 9c, Step 4/5: the live owner identity reads the
                // persisted Variorum session per call — the Keychain is the
                // truth AuthSession.adopt/signOut writes, so sign-in state
                // reaches Operations' owner_id stamping with no mutable
                // global and no re-installation.
                // pre-13x 2c (corner 47): the read is SCOPED by store
                // variant — a dev store's owner identity is its own
                // session's, never the installed build's.
                // VX-329 U1 — STOP-AND-FLAG F-U1-1 (the plan's U1 record): the design's replacement (vx-266 §3.8 —
                // "new rows are stamped with the record's account, never the session's"; joining claims unowned rows)
                // is unbuilt, so this session read stands until it is.
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
            // pre-13x 2a: the idle clock starts at ready (decision 18 —
            // time since Variorum was last used).
            protection.noteActivity()
        case .libraryMissing(let storeURL):
            state = .libraryMissing(makeMissingLobby(storeURL: storeURL))
        case .failed(let error):
            state = .failed(error)
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

    /// VX-307 U2b — the words' Copy door: the Mac's one clipboard rule; the phone renders no look this phase (its
    /// pasteboard arm is the mobile row's). VX-308 U3 — VX-448 (her ruling): the new road's rule, `WordsClipboard
    /// .copyConcealed` — the concealed type, no timer, nothing restored; cleared at the lock and at quit (`clearWordsAtLock`
    /// below; the app delegate's `applicationWillTerminate`). Every caller is a protection
    /// face.
    private static func copyWords(_ words: [String]) {
        #if os(macOS)
        WordsClipboard.copyConcealed(words)
        #endif
    }

    /// VX-308 U3 — VX-448's clear AT THE LOCK: the words a new-road look copied leave the clipboard when the library closes
    /// behind the lobby (an open settled anywhere but ready — `finish`'s non-ready arm, beside the presenter's
    /// `libraryClosed`, VX-239's rule; U4's lock lands there), only if the board still holds that copy. Nothing on today's
    /// road (it never makes the concealed copy — its own 60-second rule is untouched).
    static func clearWordsAtLock() {
        #if os(macOS)
        if WordsClipboard.clearHeld() {
            ProtectionOpenRoad.log("road: the library closed — the twelve words left the clipboard (VX-448)")
        }
        #endif
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
                self.state = .libraryMissing(self.makeMissingLobby(storeURL: self.liveStoreURL))
            },
            // VX-306 U2 — rule 27's face's *Start a New Library*: the library no key file opens steps aside whole
            // first (PROVISIONAL P-VX306-U2-5), then the creation and the words card.
            startNew: { [weak self] in
                guard let self else { return nil }
                return await self.createOnNewRoadFromAFace()
            },
            // VX-329 U4 — her pre-design face's *Start fresh…* (on her confirm's yes): the library from before this design
            // set aside WHOLE into Previous Libraries (THE RULING (a)), then the calm creation. Wired, so the door is
            // offered on the fact (P-2: doors act).
            startFresh: { [weak self] in
                guard let self else { return nil }
                return await self.startFreshOverAPreDesignStore()
            })
    }

    /// VX-329 U4 — *Start fresh…*: off the main actor through the road (`ProtectionOpenRoad
    /// .startFreshOverAPreDesignStore`), one act at a time beside the no-library landings (Open Library…'s, which set the
    /// same slot aside); a library created opens exactly as a creation does. nil = done; else the sentence the face shows.
    private func startFreshOverAPreDesignStore() async -> String? {
        guard let road = roadInputs.compose() else { return ProtectionWords.couldNotCreate }
        guard !copyLandingRunning else { return ProtectionWords.copyDoorBusy }
        copyLandingRunning = true
        defer { copyLandingRunning = false }
        let route = await Task.detached(priority: .userInitiated) {
            // The context off the main actor: it reads the sign-in (a Keychain read).
            await ProtectionOpenRoad.startFreshOverAPreDesignStore(road.context())
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

    /// VX-306 — a face's *Start a New Library* on the new road (the missing face — K5's record-less store among the
    /// states it shows — and rule 27's face): whatever stands in the slot steps aside first, never written over
    /// (`ProtectionOpenRoad.startNewLibraryFromAFace`: P-VX306-U1b-3, P-VX306-U2-5; the ladder's round-1 m1), then the
    /// creation (rule 2) and the words card. nil = done; else the sentence the face shows.
    private func createOnNewRoadFromAFace() async -> String? {
        guard let road = roadInputs.compose() else { return ProtectionWords.couldNotCreate }
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

    /// pre-13x 1a (§3.7): the three-door face's brain. Its one built act — Start a New Library — is the protection
    /// core's creation (VX-306 U1b): whatever stands in the slot steps aside first, never written over.
    private func makeMissingLobby(storeURL: URL?) -> LibraryMissingLobby {
        LibraryMissingLobby(storeURL: storeURL) { [weak self] in
            guard let self else { return nil }
            return await self.createOnNewRoadFromAFace()
        }
    }

    /// The live store's url (the slot, and the hold marker's home) — the test slot's under a test bootstrap.
    var liveStoreURL: URL? {
        isTestBootstrap
            ? testStoreURL
            : (try? AppDatabase.defaultStoreURL(variant: storeVariant))
    }

    // MARK: - VX-306 U3: THE TWO DOORS (the new road only — rule 17)

    /// The two doors' roads (nil before a library opens, and on a hosted test run's
    /// read-only road). Each road reads the CURRENT session at its call (a reopen replaces it).
    func copyDoorsRoads() -> CopyDoorsRoads? {
        guard case .ready = state, let session = roadSession, session.writes else { return nil }
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
            // VX-309 U2 — VX-264 item 7: the open library's posture and sync, for the confirm's concrete lead.
            libraryShape: { [weak self] in self?.roadSession.flatMap { OpenLibraryShape.of($0.library) } },
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
            },
            // VX-307 U2c — VX-413: the note page's Copy full text (the platform's clipboard rule).
            copyFullText: Self.copyFullTextRoad,
            // VX-309 U1b — T-8: a plaintext export brought in as a new library (this one steps aside whole).
            bringInPlaintextExport: { [weak self] url in await self?.bringInPlaintextExport(url) ?? .refused(.failed) },
            // VX-309 U1c — VX-265: rule 19's delete on the open session (one act at a time); the receipt on the status seam.
            deleteCopies: { [weak self] libraryID in
                guard let session = self?.roadSession else { return .refused(.deleteFailed) }
                let outcome = await Task.detached(priority: .userInitiated) {
                    await ProtectionCopyDoors.deleteCopies(session, libraryID: libraryID)
                }.value
                if case .deleted(let count) = outcome { self?.roadStanding?.speak?(ProtectionWords.deleteCopiesReceipt(count)) }
                return outcome
            })
    }

    /// VX-306 U3 — the two doors' roads with NO library open (the missing face's and rule 27's *Open Library…*,
    /// P-VX306-U3-7 narrowed at the ruling): a pick filed, then Look inside; and — VX-309 U1b, T-5 — Make this my library
    /// INTO THE EMPTY SLOT (`makeThisMyLibraryInTheEmptySlot`: no current pair exists, so the copy's own typed secret is the
    /// one thing asked). nil on a hosted test run's read-only road (the filing writes).
    func copyDoorsRoadsWithoutALibrary() -> CopyDoorsRoads? {
        guard let road = roadInputs.compose(), road.writes else { return nil }
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
            makeMine: { [weak self] row, copySecrets, _ in
                guard let self else { return .refused(.failed) }
                return await self.makeThisMyLibraryInTheEmptySlot(row, copySecrets: copySecrets)
            },
            pick: { url in
                await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.pick(url, context()) }.value
            },
            lookInside: { copy, typed, quietRoads in
                await Task.detached(priority: .userInitiated) {
                    ProtectionCopyDoors.lookInside(context(), copy: copy, typed: typed, quietRoads: quietRoads)
                }.value
            },
            // VX-307 U2c — VX-413: the note page's Copy full text (the platform's clipboard rule).
            copyFullText: Self.copyFullTextRoad,
            landsInTheEmptySlot: true,
            // VX-309 U1b — T-8: a plaintext export brought in as a new library.
            bringInPlaintextExport: { [weak self] url in await self?.bringInPlaintextExport(url) ?? .refused(.failed) },
            // VX-309 U1c — VX-265: rule 19's delete with no library open (never a library this Mac remembers); one
            // landing or delete at a time (a delete never runs under a landing that may be reading the copy).
            deleteCopies: { [weak self] libraryID in
                guard let self else { return .refused(.deleteFailed) }
                return await self.deleteCopiesWithNoLibraryOpen(libraryID, context: context)
            })
    }

    /// VX-309 U1c — rule 19's delete with NO library open (the empty-slot listing): only where no library is open, one at a
    /// time beside the landings, off the main actor; the listing's own receipt line says what went.
    private func deleteCopiesWithNoLibraryOpen(
        _ libraryID: String, context: @escaping @Sendable () -> CopyDoorsContext
    ) async -> CopyDeleteOutcome {
        if case .ready = state { return .refused(.deleteFailed) }
        guard !copyLandingRunning else { return .refused(.busy) }
        copyLandingRunning = true
        defer { copyLandingRunning = false }
        return await Task.detached(priority: .userInitiated) {
            ProtectionCopyDoors.deleteCopies(context(), libraryID: libraryID)
        }.value
    }

    /// **A PLAINTEXT EXPORT BROUGHT IN AS A NEW LIBRARY** (VX-309 U1b — T-8; the mapping ruled at the plan's §5b-R). From an
    /// open library (`.ready`) or none (the missing face, rule 27's lobby). THE PREFLIGHT first, all reads (the export
    /// planned on a private staged copy — a refusal never tears the window down); then, with a library open, the reopening
    /// seam's first half (the composition root's teardown, the `.ready` tree down, the app's pool CLOSED); then the act off
    /// the main actor (`ProtectionCopyDoors.landPlaintextExport` — what stands steps aside whole, the creation's road, the
    /// content minted headless into the new store); then the new library opens exactly as a creation does (`.roadCreated`:
    /// its words dropped unseen — the band card offers fresh ones), the receipt naming what landed owed to that open. Nothing
    /// made ⇒ the open finds what still stands (the library, under its own key, when it never moved).
    func bringInPlaintextExport(_ url: URL) async -> CopyDoorOutcome {
        guard let road = roadInputs.compose(), road.writes else { return .refused(.failed) }
        var open: ProtectionRoadSession?
        switch state {
        case .ready:
            guard let session = roadSession, session.writes, binding != nil else { return .refused(.failed) }
            open = session
        case .libraryMissing: break
        // VX-329 U4 — (D): her pre-design face admits the landing by its OWN fact (what stands steps aside WHOLE —
        // `setAsideLibraryWholeFor`'s pre-design arm); rule 27's face as before; every other occupied shape refuses.
        case .roadLobby(let lobby) where lobby.face.noKeyFileAnywhere != nil || lobby.face.preDesignStore: break
        default: return .refused(.failed)
        }
        guard !copyLandingRunning else { return .refused(.busy) }
        if let open, !open.beginAct() { return .refused(.busy) }
        copyLandingRunning = true
        defer { copyLandingRunning = false }
        let read = await Task.detached(priority: .userInitiated) { ProtectionCopyDoors.readPlaintextExport(url) }.value
        guard case .plan(let plan) = read else {
            open?.endAct()
            if case .refused(let why) = read { return .refused(why) }
            return .refused(.failed)
        }
        let oldKey = open?.key
        let binding = binding
        if open != nil {
            await onWillLock?()
            state = .opening
        }
        let closesThePool = open != nil
        // VX-488 R1 F1: the library open now — its account's session hold leaves with it once the landing creates the new one.
        let outgoing = open
        let result = await Task.detached(priority: .userInitiated) {
            if closesThePool { binding?.lock() }
            // The context off the main actor: it reads the sign-in (a Keychain read).
            return await ProtectionCopyDoors.landPlaintextExport(road.context(), plan: plan, outgoing: outgoing)
        }.value
        open?.endAct()
        guard let created = result.created else {
            if open != nil {
                beginOpening(unlockedKey: oldKey)
                await awaitOpen()
            }
            return .refused(result.refusal ?? .failed)
        }
        adoptedALibraryThisProcess = true
        // VX-309 U2: the receipt says where the previous library went when one was open (the lead said it would).
        receiptsForNextRoadOpen.append(ProtectionWords.bringInReceipt(
            result.landing, stoppedEarly: result.stoppedEarly, steppedAside: open != nil))
        finish(.roadCreated(created.session, created.words))
        await awaitOpen()
        return .made
    }

    /// **SEND LIBRARY** (VX-329 U1 — PROVISIONAL P-VX329-U1-1; rule 18, vx-266 §3.7): the road's `sendLibrary` act —
    /// the open library's pair (`variorum.sqlite` + this design's key file) into a fresh "Variorum Library — <date>"
    /// folder under `parent`, off the main actor, one act at a time on the session. Today's producer (a snapshot beside
    /// today's key file) left with today's road.
    func sendLibrary(into parent: URL) async -> Result<URL, LibraryHandOff.HandOffError> {
        guard case .ready = state, let session = roadSession, session.writes else {
            return .failure(.failed(ProtectionWords.somethingWentWrong))
        }
        guard session.beginAct() else { return .failure(.failed(ProtectionWords.copyDoorBusy)) }
        defer { session.endAct() }
        return await Task.detached(priority: .userInitiated) { () -> Result<URL, LibraryHandOff.HandOffError> in
            let folder = LibraryHandOff.availableFolderURL(in: parent, now: Date())
            var library = session.library
            do {
                _ = try await session.executor.sendLibrary(&library, to: folder.path)
                session.library = library
                return .success(folder)
            } catch ExecutorRefusal.noLiveKeyFile {
                try? FileManager.default.removeItem(at: folder)
                return .failure(.noKeyFile)
            } catch {
                // A pair either exists whole or not at all.
                try? FileManager.default.removeItem(at: folder)
                return .failure(.failed(String(describing: error)))
            }
        }.value
    }

    /// One landing at a time with no library in hand — T-5's empty-slot landing, T-8's bring-in (a second press while one
    /// runs refuses busy).
    @ObservationIgnored private var copyLandingRunning = false

    /// **MAKE THIS MY LIBRARY INTO THE EMPTY SLOT** (VX-309 U1b — T-5; rule 17 with no library open). Offered only where
    /// no library is open: the missing face, and rule 27's lobby (its *Open Library…* renders only in that state). No pool
    /// is open on the slot, so nothing closes: the act runs off the main actor (`ProtectionCopyDoors.makeMineInTheEmptySlot`
    /// — the preflight's reads, the restore hold, what stands in the slot set aside whole, the core's act, today's store id
    /// minted fresh), then the open goes THROUGH THE NEW ROAD with the new key in hand (or, if the act stopped past its
    /// swap, by the new library's own quiet road), the receipt owed to that open's status seam.
    func makeThisMyLibraryInTheEmptySlot(_ row: CopyDoorRow, copySecrets: TypedSecrets) async -> CopyDoorOutcome {
        guard let road = roadInputs.compose(), road.writes else { return .refused(.failed) }
        switch state {
        case .libraryMissing: break
        // VX-329 U4 — (D): her pre-design face admits the landing by its own fact (the slot set aside WHOLE first).
        case .roadLobby(let lobby) where lobby.face.noKeyFileAnywhere != nil || lobby.face.preDesignStore: break
        default: return .refused(.failed)
        }
        guard !copyLandingRunning else { return .refused(.busy) }
        copyLandingRunning = true
        defer { copyLandingRunning = false }
        // VX-309 U1c — F-U1b-5: the band card's ledger (her typed words become the new library's — recorded).
        let wordsLedger = WordsCardLedger(defaults: reminderLedger.defaults)
        let result = await Task.detached(priority: .userInitiated) {
            // The context off the main actor: it reads the sign-in (a Keychain read).
            let ctx = CopyDoorsContext(road.context())
            return await ProtectionCopyDoors.makeMineInTheEmptySlot(
                ctx, row: row, copySecrets: copySecrets, wordsLedger: wordsLedger)
        }.value
        guard result.outcome == .made else { return result.outcome }
        adoptedALibraryThisProcess = true
        receiptsForNextRoadOpen.append(ProtectionWords.makeMineEmptySlotReceipt)
        beginOpening(unlockedKey: result.key)
        await awaitOpen()
        return .made
    }

    /// VX-307 U2c — VX-413 (her ruling: "copy full text is a good idea"): Look inside's *Copy full text* writes the
    /// Mac's general pasteboard exactly as a live note's Copy full text does (`CopyForAI.put` — the one clipboard rule,
    /// no expiry: the note is her writing, not a secret). The phone has no Look inside (P-VX306-U3-18): no road there.
    static var copyFullTextRoad: (@MainActor (String) -> Void)? {
        #if os(macOS)
        return { CopyForAI.put($0) }
        #else
        return nil
        #endif
    }

    /// **MAKE THIS MY LIBRARY** (rule 17; the plan's U3 addendum) — one confirmed door, on the new road at ready. Every
    /// check first, all reads (`ProtectionCopyDoors.preflight` — a typo never tears the window down); then
    /// 13x's adoption seam's shape (`adoptLibrary`, deleted with today's road at VX-329 U1): the composition root's teardown (`onWillLock` — flush, savepoint, stop), the
    /// `.ready` tree down, the app's pool CLOSED through the binding (a checkpoint-truncate, then the close — the
    /// swap's precondition), and the act off the main actor (`ProtectionCopyDoors.makeMine`: the restore hold by the
    /// core writer, the executor's plan); then the reopen THROUGH THE ROAD with the
    /// key that opens the slot now in hand (the new library's; the old one's when nothing swapped). The receipt
    /// (§7c (9)) is owed to the reopened session. One act at a time on the session.
    func makeThisMyLibrary(
        _ row: CopyDoorRow, copySecrets: TypedSecrets, currentPair: TypedSecrets
    ) async -> CopyDoorOutcome {
        guard case .ready = state, let binding, let session = roadSession, session.writes else {
            return .refused(.failed)
        }
        guard session.beginAct() else { return .refused(.busy) }
        let preflight = await Task.detached(priority: .userInitiated) {
            ProtectionCopyDoors.preflight(session, row: row, copySecrets: copySecrets, currentPair: currentPair)
        }.value
        let copy: CatalogCopy
        let catalog: Catalog
        let opened: LookedInside
        switch preflight {
        case .refused(let why):
            session.endAct()
            return .refused(why)
        case .ready(let ready, let listed, let look):
            copy = ready
            catalog = listed
            // VX-307 U2c: the copy as her press opened it — the act takes its key, so one press opens it once.
            opened = look
        }
        await onWillLock?()
        state = .opening
        // VX-309 U1c — VX-444: the band card's ledger (the outgoing library's words marks carry with the pair).
        let wordsLedger = WordsCardLedger(defaults: reminderLedger.defaults)
        let result = await Task.detached(priority: .userInitiated) {
            binding.lock()
            return await ProtectionCopyDoors.makeMine(
                session, copy: copy, catalog: catalog, row: row, opened: opened, currentPair: currentPair,
                wordsLedger: wordsLedger)
        }.value
        session.endAct()
        if result.outcome == .made {
            adoptedALibraryThisProcess = true
            receiptsForNextRoadOpen.append(ProtectionWords.makeMineReceipt)
        }
        beginOpening(unlockedKey: result.reopenKey)
        await awaitOpen()
        return result.outcome
    }

    // MARK: - VX-307 U2a: THE CROSSINGS (the new road only — rules 11, 12; Replace All Keys)

    /// The crossings' roads on the new road. Each reads the CURRENT session at its call (a reopen replaces it); nil
    /// sessions and a hosted test run's read-only road answer with nothing done.
    func crossingRoads() -> RoadCrossingRoads {
        let exports = exportSwitch
        let signInNow = signInNow
        return RoadCrossingRoads(
            read: { [weak self] in
                guard let self, case .ready = self.state, let session = self.roadSession else { return nil }
                // VX-308 U1 (R-2): the pane's ONE read — the sign-in now and a fresh vault read.
                return await Task.detached(priority: .userInitiated) {
                    let read = await ProtectionPaneRead.read(session, signIn: signInNow(), exportSwitch: exports)
                    return read.flatMap { ProtectionCrossings.readCrossings(session, exportSwitch: exports, read: $0) }
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
            },
            // MAJOR-1: rule 11's notice is the durable mark's, re-read at each refresh; *OK* clears it. VX-308 U4
            // (NIT-R2-1): the OPEN library's mark — another library's unanswered notice is never this pane's, nor cleared here.
            exportNoticeOwed: { [weak self] in
                guard let libraryID = self?.roadSession?.library.record?.libraryID else { return false }
                return exports.noticeOwed(libraryID)
            },
            dismissExportNotice: { [weak self] in
                ProtectionCrossings.dismissExportNotice(
                    exportSwitch: exports, libraryID: self?.roadSession?.library.record?.libraryID)
            },
            // VX-308 U1 (VX-264, R-1 as amended): the signed-out road's Continue — This Mac Only, re-read at the press.
            leaveForThisMacOnly: { [weak self] in
                guard let self, case .ready = self.state, let session = self.roadSession else {
                    return ProtectionWords.crossingFailed
                }
                let refused = await Task.detached(priority: .userInitiated) {
                    await ProtectionAccountRoad.leaveForUseCastle(session, signIn: signInNow(), exportSwitch: exports)
                }.value
                if refused == nil { await self.roadAccount?.refresh() }
                return refused
            },
            // VX-309 U1c — VX-451: the idle dial (this Mac's sealed minutes, `changeSettings` on the open session).
            changeIdleLock: { [weak self] minutes in
                guard let session = self?.roadSession, session.writes else { return .refused(ProtectionWords.gateRowFailed) }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionCrossings.changeIdleLock(session, minutes: minutes)
                }.value
            },
            // VX-309 U1c — VX-451: Lock Library Now from the pane — the one lock (`lock()`, VX-445's road).
            lockNow: { [weak self] in await self?.lock() })
    }

    /// VX-308 ladder round 1 (MINOR-2) — the Protection pane's appearance: the pane's ONE read taken ONCE for the
    /// crossings, the account section and the key doors (`ProtectionPaneRead.wave` — one facts gather, one vault fetch, the
    /// three faces derived as each section's own road derives them), off the main actor. Nothing open on the new road: no
    /// faces (each section's own road answers nil the same way).
    func paneWave() async -> ProtectionPaneWave {
        guard case .ready = state, let session = roadSession else { return ProtectionPaneWave() }
        let exports = exportSwitch
        let signInNow = signInNow
        return await Task.detached(priority: .userInitiated) {
            await ProtectionPaneRead.wave(session, signIn: signInNow(), exportSwitch: exports)
        }.value
    }

    /// VX-308 U1 (R-2) — who is signed in NOW (the scope's stored session — a read, taken off the main actor by every
    /// caller).
    private var signInNow: @Sendable () -> SessionFact { roadInputs.sessionFact }

    /// VX-308 U1 — the account section's roads on the new road. Each reads the CURRENT session at its call (a reopen
    /// replaces it); the press runs on the open session (no reopen — none of U1's acts swaps the key; VX-308 U2's re-keying
    /// acts take the reopening seam); a landed act re-reads the crossings (the library's account changed under them) and
    /// speaks on the status seam.
    func accountRoads() -> RoadAccountRoads {
        let exports = exportSwitch
        let signInNow = signInNow
        return RoadAccountRoads(
            read: { [weak self] in
                guard let self, case .ready = self.state, let session = self.roadSession else { return nil }
                return await Task.detached(priority: .userInitiated) {
                    let read = await ProtectionPaneRead.read(session, signIn: signInNow(), exportSwitch: exports)
                    return read.flatMap({ ProtectionPaneRead.accountFaces($0, session: session) })
                }.value
            },
            press: { [weak self] request in
                guard let self, case .ready = self.state, let session = self.roadSession else {
                    return .refused(ProtectionWords.crossingFailed)
                }
                // VX-308 U2 (R-U2-2): an act that re-keys (a join across postures, every follow) runs through the one
                // reopening seam; the rest on the open session.
                if request.shown.rekeys { return await self.accountActOnNewRoad(request) }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionAccountRoad.press(
                        session, request: request, signIn: signInNow(), exportSwitch: exports)
                }.value
            },
            // VX-309 U1c — VX-454: an account act can set a passphrase on the OPEN session (turning sync on with a new one,
            // a join adopting the account's pair) — the set row and rule 3's reminder re-read, and the key doors with them
            // (Change and Reset stand where the set row retires).
            landed: { [weak self] in
                await self?.roadCrossings?.refresh()
                self?.roadStanding?.rereadPassphrase()
                // VX-473: the hold banner's account clause follows the record (turning sync on, a leave).
                self?.roadStanding?.rereadAccountBinding()
                await self?.roadKeyDoors?.refresh()
            },
            receipt: { [weak self] text in self?.roadStanding?.speak?(text) },
            // VX-308 U2 — the words moment's Copy: the Mac's one words clipboard rule (the card's own road).
            copyWords: { Self.copyWords($0) },
            // VX-309 U2 — VX-457: the follow's Done as the section's durable notice — the OPEN library's mark, in the
            // calm-asks ledger's defaults (a test bootstrap's own suite), read at every landing and cleared at its OK.
            followDoneOwed: { [weak self] in
                guard let self, let libraryID = self.roadSession?.library.record?.libraryID else { return nil }
                return FollowDoneMark.owed(libraryID, in: self.reminderLedger.defaults)
            },
            dismissFollowDone: { [weak self] in
                guard let self, let libraryID = self.roadSession?.library.record?.libraryID else { return }
                FollowDoneMark.set(libraryID, nil, in: self.reminderLedger.defaults)
            })
    }

    /// VX-308 U3 — the key doors' roads on the new road. Each reads the CURRENT session at its call (a reopen replaces it);
    /// the press runs on the OPEN session (the key doors re-lock the current key and never swap it — no reopening seam);
    /// a landed act speaks its receipt on the status seam and re-reads the account section (a synced passphrase change is
    /// the account's too).
    func keyDoorRoads() -> RoadKeyDoorRoads {
        let exports = exportSwitch
        let signInNow = signInNow
        return RoadKeyDoorRoads(
            read: { [weak self] in
                guard let self, case .ready = self.state, let session = self.roadSession else { return nil }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionKeyDoorRoad.read(session, signIn: signInNow(), exportSwitch: exports)
                }.value
            },
            press: { [weak self] request in
                guard let self, case .ready = self.state, let session = self.roadSession else {
                    return .refused(ProtectionWords.crossingFailed)
                }
                return await Task.detached(priority: .userInitiated) {
                    await ProtectionKeyDoorRoad.press(session, request: request, signIn: signInNow(), exportSwitch: exports)
                }.value
            },
            receipt: { [weak self] text in self?.roadStanding?.speak?(text) },
            landed: { [weak self] in await self?.roadAccount?.refresh() })
    }

    /// **VX-510 D-A1 — THE SERVICES-HELD ROADS, wired in ONE place** (the composition glue moved out of view code, so a
    /// test drives exactly what ships: bootstrap + services + a fake server, end to end). The app's services die at each
    /// lock and every reopen composes fresh ones (`VariorumApp`'s `.task`), while the account section's model and this
    /// bootstrap live on — so each services instance is attached here as it is made, and the faces' roads follow the newest
    /// one (captured weakly: a stopped instance answers nothing). Today's roads: the Account sheet's Delete Account runs the
    /// protection half (`accountDeletedOnNewRoad` — P-VX308-U1-F1); the account section's *Sign out…* signs out through the
    /// services' one session. (The phone wires its deletion hook inline: it renders no account section until VM-8, P-2.)
    func attach(services: AppServices) {
        services.afterAccountDeleted = { [weak self] account in
            await self?.accountDeletedOnNewRoad(account)
        }
        roadAccount?.signOutRoad = { [weak services] in await services?.signOutVariorum() }
    }

    /// **P-VX308-U1-F1's hook** (the U1 ARBITRATION's refined (b)) — the Account sheet's Delete Account landed for
    /// `accountID` (the composition root wires `AppServices.afterAccountDeleted` to this on the new road): the protection
    /// half runs when the open library names that account — the record stops naming it, this Mac forgets its sync keys
    /// (rule 16's local leave). When it cannot run (no library open on the new road, another act running, a failure), the
    /// record keeps naming the deleted account; the next read finds no one signed in and the signed-out screens' *Use this
    /// Mac only…* closes it.
    func accountDeletedOnNewRoad(_ accountID: String) async {
        guard case .ready = state, let session = roadSession, session.writes else { return }
        guard session.library.record?.account == accountID else { return }
        guard session.beginAct() else {
            ProtectionOpenRoad.log("road: the account was deleted while another act ran — the signed-out screens close it")
            return
        }
        let signIn = signInNow
        _ = await Task.detached(priority: .userInitiated) {
            await ProtectionAccountRoad.accountDeleted(session, accountID: accountID, signIn: signIn())
        }.value
        session.endAct()
        await roadAccount?.refresh()
        await roadCrossings?.refresh()
    }

    /// **A CROSSING** (Use Castle · Use Standard · Replace All Keys) — Make this my library's seam shape: every check
    /// first, all reads (`ProtectionCrossings.preflight` — the door RE-READ, VX-108; the typed pair against the live key
    /// file — a typo never tears the window down); then the composition root's teardown (`onWillLock` — flush,
    /// savepoint, stop), the `.ready` tree down, the app's pool CLOSED through the binding (the swap's precondition), and
    /// the core's act off the main actor on its sealed plan (rule 20); then the reopen THROUGH THE NEW ROAD with the key
    /// that opens the slot now (the new one; the old one when nothing swapped), the act's receipt owed to the reopened
    /// session, and Settings asked back to Protection, where she acted (VX-206's road). One act at a time on the session.
    func crossOnNewRoad(_ request: RoadCrossingRequest) async -> RoadCrossingPress {
        guard case .ready = state, let binding, let session = roadSession, session.writes else {
            return .refused(ProtectionWords.crossingFailed)
        }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        let exports = exportSwitch
        let signInNow = signInNow
        let preflight = await Task.detached(priority: .userInitiated) {
            // VX-308 U1 (R-2): the door re-read the way the shown one was (the pane's one read), and the sign-in now
            // adopted into the executor under the act — a synced crossing acts as whoever is signed in now.
            let signIn = signInNow()
            let read = await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exports)
            session.executor.configuration.session = signIn
            return ProtectionCrossings.preflight(
                session, door: request.door, shown: request.shown, typed: request.typed, exportSwitch: exports,
                read: read)
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
        let result = await reopenAround(session, binding: binding) {
            let result = await ProtectionCrossings.cross(
                session, door: request.door, typed: request.typed, gate: request.gate, exportSwitch: exports)
            var owed: [String] = []
            if case .made(let door, _) = result.outcome {
                // VX-308 U1: the signed-out road's crossing ends its receipt with the born-Castle sentence.
                owed.append(request.receiptNote.map { door.receipt + " " + $0 } ?? door.receipt)
            }
            return (result, result.reopenKey, owed)
        }
        switch result.outcome {
        case .made(_, let exportTurnedOff): return .made(exportTurnedOff: exportTurnedOff)
        case .refused(let sentence): return .refused(sentence)
        }
    }

    /// **THE REOPENING SEAM** — ONE for every act that re-keys the open library on the new road (VX-307 U2a's crossings;
    /// VX-308 U2's join across postures and every follow — R-U2-2), Make this my library's seam shape, its order exactly
    /// the crossing's: the composition root's teardown (`onWillLock` — flush, savepoint, stop), the `.ready` tree down,
    /// the app's pool CLOSED through the binding (the swap's precondition), `act` off the main actor on the session the
    /// caller holds (its one-act lock, released here), the receipts it owes handed to the reopened session, then the
    /// reopen THROUGH THE NEW ROAD with the key that opens the slot now and Settings asked back to Protection, where she
    /// acted (VX-206's road). The caller ran every check first (all reads) and holds `session.beginAct()`.
    private func reopenAround<Result: Sendable>(
        _ session: ProtectionRoadSession, binding: StoreBinding,
        act: @escaping @Sendable () async -> (result: Result, reopenKey: StoreKey, owed: [String])
    ) async -> Result {
        await onWillLock?()
        state = .opening
        let done = await Task.detached(priority: .userInitiated) {
            binding.lock()
            return await act()
        }.value
        session.endAct()
        receiptsForNextRoadOpen += done.owed
        beginOpening(unlockedKey: done.reopenKey)
        await awaitOpen()
        protection.requestProtectionPaneForRoadCrossing()
        return done.result
    }

    /// **A RE-KEYING ACCOUNT ACT** (VX-308 U2, R-U2-2 — a join that crosses postures, every follow): every check first, all
    /// reads (`ProtectionAccountRoad.preflight` — the door RE-READ through the pane's one read, VX-108; the typed secret
    /// against the vault that read fetched, R-U2-3 — a typo never tears the window down), the sign-in now adopted under the
    /// act (R-2); then THE REOPENING SEAM around `ProtectionAccountRoad.perform`. The act's receipt is owed to the reopened
    /// session when the act landed WHOLE; one that stopped past its swap is finished by that reopen's settle, which says its
    /// Done (VX-107 — never said twice). The press answers with no receipt of its own (the reopen speaks it).
    func accountActOnNewRoad(_ request: RoadAccountRequest) async -> RoadAccountPress {
        guard case .ready = state, let binding, let session = roadSession, session.writes else {
            return .refused(ProtectionWords.crossingFailed)
        }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        let exports = exportSwitch
        let signInNow = signInNow
        let preflight = await Task.detached(priority: .userInitiated) {
            await ProtectionAccountRoad.preflight(session, request: request, signIn: signInNow(), exportSwitch: exports)
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
        // (The ledger, not its defaults: it is Sendable — the seam's act runs off the main actor.)
        let followDoneLedger = reminderLedger
        return await reopenAround(session, binding: binding) {
            let done = await ProtectionAccountRoad.perform(
                session, request: request, signIn: signInNow(), exportSwitch: exports)
            switch done.press {
            case .made(_, let wordsReplaced):
                // VX-309 U2 — VX-457: a follow that landed whole owes its Done DURABLY (the account section's notice
                // until her OK — `FollowDoneMark`), never a receipt; any other act's receipt rides to the reopen as before.
                let owed = ProtectionAccountRoad.owed(after: done, request: request)
                if let kind = owed.followDone, let libraryID = session.library.record?.libraryID {
                    FollowDoneMark.set(libraryID, kind, in: followDoneLedger.defaults)
                }
                return (.made(receipt: nil, wordsReplaced: wordsReplaced), done.reopenKey, owed.receipts)
            case .refused, .changed:
                return (done.press, done.reopenKey, [])
            }
        }
    }

    /// The weekly plain-text copy's switch (`MarkdownInsurance`) over a defaults domain — nil: this Mac's standard
    /// defaults (production); a test bootstrap names its own suite.
    /// VX-307 ladder round 1 (MAJOR-1) — rule 11's notice owed, beside the weekly copy's switch (this Mac's defaults; a
    /// boolean, never a secret). VX-308 U4 (NIT-R2-1): ONE PER LIBRARY (`ExportNoticeMark` — the key carries the library's
    /// id; an earlier build's unkeyed mark migrates at its first consult).
    nonisolated static func markdownInsuranceSwitch(suiteName: String?) -> ScheduledExportSwitch {
        guard let suiteName else {
            return ScheduledExportSwitch(
                isOn: { MarkdownInsurance.isEnabled(in: .standard) },
                set: { MarkdownInsurance.setEnabled($0, in: .standard) },
                noticeOwed: { ExportNoticeMark.owed($0, in: .standard) },
                setNoticeOwed: { libraryID, owed in ExportNoticeMark.set(libraryID, owed: owed, in: .standard) })
        }
        // A named suite only — never falls back to the app's domain (a suite that can't be made reads off, writes nothing).
        return ScheduledExportSwitch(
            isOn: { UserDefaults(suiteName: suiteName).map { MarkdownInsurance.isEnabled(in: $0) } ?? false },
            set: { value in
                if let suite = UserDefaults(suiteName: suiteName) { MarkdownInsurance.setEnabled(value, in: suite) }
            },
            noticeOwed: { libraryID in
                UserDefaults(suiteName: suiteName).map { ExportNoticeMark.owed(libraryID, in: $0) } ?? false
            },
            setNoticeOwed: { libraryID, owed in
                guard let suite = UserDefaults(suiteName: suiteName) else { return }
                ExportNoticeMark.set(libraryID, owed: owed, in: suite)
            })
    }

    /// A test bootstrap's scheduled-export domain — never the app's.
    nonisolated static let crossingTestExportSuiteName = "io.lduarte.Variorum.vx307-crossing-tests"

    // MARK: - Re-lock (Castle only; Lock Now and the re-lock policy both land here)

    /// Whether Lock Now is a real act right now (P-2: the door renders only where it acts). VX-308 U4 — VX-445
    /// (R-U4-1): Lock Now acts where the open library is in CASTLE (its record's mode); Standard never locks (rule 8's
    /// quiet roads would open it again at once — R13p-14's no-theater rule). Each reopen changes `state`, so the
    /// observed read follows the posture.
    var canLock: Bool { roadRelockPolicy != nil }

    /// VX-308 U4 — VX-445: the OPEN library's relock policy (`RoadRelockPolicy` — Castle, with this Mac's sealed idle
    /// minutes): ready, bound, a road session in Castle; nil otherwise (Standard, nothing open). Lock Now's door, the
    /// relock monitors (through `ProtectionController.roadRelock`) and the lock itself read it.
    var roadRelockPolicy: RoadRelockPolicy? {
        guard case .ready = state, binding != nil, let session = roadSession else { return nil }
        return RoadRelockPolicy.of(session.library)
    }

    /// The lock — see `lockOnNewRoad` (Castle only; a lock whose key the quiet roads would hand back at once is
    /// theater, and no theater ships — R13p-14).
    func lock() async {
        await lockOnNewRoad()
    }

    // MARK: - VX-308 U4 — VX-445: THE LOCK ON THE NEW ROAD (the record's R-U4-1..3)

    /// **THE LOCK ON THE NEW ROAD** — Castle only (`roadRelockPolicy`; Standard's quiet roads would open it again at once).
    /// One act at a time: an act running on the session, or an open in flight, is waited out first — a teardown never
    /// lands under an act (`awaitTheLockSeam`, PROVISIONAL P-VX308-U4-2). Then the crossings' seam's first half: the
    /// composition root's teardown (`onWillLock` — flush, savepoint, stop), the `.ready` tree down, the per-open state
    /// dropped, the account's sync keys in session memory dropped (the leaf's "gone at a relock"), the road session, its
    /// standing faces and the engine's key seam let go (nothing keeps the key), the app's pool CLOSED through the binding off
    /// the main actor; then THE LOBBY — the open road's own, over a freshly composed road (the quiet roads are not tried: a
    /// lock is never theater), landed through `finish`, so the one presenter drops its sheet and VX-448's words leave the
    /// clipboard (F-U3-3). Always ask types; Touch ID auto-asks — the lobby's existing behaviour. No lock-time byte copy on
    /// the new road (PROVISIONAL P-VX308-U4-3 — rule 5: a backup is the library and its key file, the new road's pair).
    private func lockOnNewRoad() async {
        guard let session = await awaitTheLockSeam() else { return }
        guard let binding, let road = roadInputs.compose() else {
            session.endAct()
            ProtectionOpenRoad.log("road: the lock found no road to land in — the library stays open")
            return
        }
        await onWillLock?()
        state = .opening
        ProtectionRoadLock.dropSessionMemory(session)
        roadStanding = nil
        roadSession = nil
        newRoadSyncKeys.attach(nil)
        let lobby = await Task.detached(priority: .userInitiated) { () -> (facts: RoadLobbyFacts, ctx: RoadContext) in
            binding.lock()
            // The context off the main actor: it reads the sign-in (a Keychain read).
            let ctx = road.context()
            return (ProtectionRoadLock.lobby(ctx), ctx)
        }.value
        session.endAct()
        ProtectionOpenRoad.log("road: locked — the library closed behind the lobby (VX-445)")
        finish(.roadLobby(lobby.facts, lobby.ctx))
    }

    /// One act at a time (R-U4-2): the session to lock, its one-act lock HELD — an act running on it (a key door's press,
    /// a crossing's preflight) or an open in flight (a crossing's reopen) is waited out first, so a sleep or screen lock
    /// arriving mid-act still locks once the act lands; nil when nothing (any more) locks — Standard, the library closed.
    private func awaitTheLockSeam() async -> ProtectionRoadSession? {
        while !Task.isCancelled {
            if case .opening = state {
                // An open in flight: lock what it opens (or nothing, when it settles closed).
            } else {
                guard roadRelockPolicy != nil, let session = roadSession else { return nil }
                if session.beginAct() { return session }
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return nil
    }
}

/// The FILE work, and nothing else — resolve the URL, assert the iOS
/// protection class, open and migrate. Nonisolated on purpose: this is what
/// runs off the main actor (13l L-c), and keeping it a free function makes
/// that impossible to lose in a later refactor by accident. `install` and
/// the state write deliberately stay behind, on the MainActor.
///
/// `custody` is the road's key in hand (`.inMemory` — VX-329: no device-keychain custody exists outside the protection
/// core), so `openStore` (and the migration) runs with exactly the key the road opened. REQUIRED, never defaulted: the
/// ambient test-context custody would key the app's store under a key that dies with the process.
private nonisolated func openStoreOffMain(
    variant: AppDatabase.StoreVariant,
    custody: StoreKeyCustody
) -> Result<AppDatabase, AppDatabase.StoreOpenError> {
    do {
        let url = try AppDatabase.defaultStoreURL(variant: variant)
        #if os(iOS)
        prepareStoreDirectoryProtection(url)
        #endif
        return .success(try AppDatabase.openStore(at: url, custody: custody))
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
/// NO store: the library file is what is missing. Its one built act —
/// **Start a New Library** — is the protection core's creation (VX-306 U1b:
/// whatever stands in the slot steps aside first, never written over; the
/// creation, then the open). The Mac's *Restore from Backup…* and *Open
/// Library…* are the copy doors (VX-309 U1b — rule 17), composed by the face.
/// (VX-329 U1: today's act — a fresh key and today's key file under a new
/// store id, custody through today's guard — and today's Finder-revealing
/// restore left with today's road.)
@MainActor
@Observable
final class LibraryMissingLobby {
    /// The absent store's url (nil = no resolvable path: no act can run).
    let storeURL: URL?
    private(set) var busy = false
    var lastError: String?

    /// The road's creation; answers the face's sentence, nil when it went on.
    private let create: @MainActor () async -> String?

    init(storeURL: URL?, create: @escaping @MainActor () async -> String?) {
        self.storeURL = storeURL
        self.create = create
    }

    /// VX-309 U1b — a home of this Mac's copies stands beside the (absent) store (`Backups/` or `Previous Libraries/`):
    /// *Restore from a Backup…* lists them (P-2: no home, no door).
    var copiesHomeExists: Bool {
        guard let storeURL else { return false }
        let container = storeURL.deletingLastPathComponent()
        return [CatalogNames.backupsFolderName, CatalogNames.previousLibrariesFolderName].contains {
            FileManager.default.fileExists(atPath: container.appendingPathComponent($0, isDirectory: true).path)
        }
    }

    /// The one built act (§3.7): a fresh library.
    func startNewLibrary() async {
        guard !busy, storeURL != nil else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        lastError = await create()
    }
}
