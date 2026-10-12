//
//  MCPDoor.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — THE MCP DOOR's app-side owner (A-8): one per app (the app
//  delegate holds it, the `crashReports` reason), attached to the open store
//  at ready and detached at lock and quit. It runs the server iff the
//  Settings ▸ MCP toggle (the grants store's `server` switch, A-6) is ON and a
//  store is attached — and never inside a test process. It holds no rule: the
//  grants are rows the pure rule reads per call, and every act here is an
//  operation through the session's runner (off the main thread, P2). The
//  pane renders its `snapshot` — bounded lists (R-13n-10) observed from the
//  grants store, which is small by construction (the pending room and the log
//  are capped).
//

import AppKit
import Foundation
import GRDB
import Observation
import VariorumCore
import VariorumMCP
import VariorumMCPSocket

/// U2 (AF-8): the session's runner IS the MCP write executor — the road her
/// own gestures take (`OperationsRunner.run`'s exact signature).
extension OperationsRunner: MCPWriteExecutor {}

@MainActor
@Observable
final class MCPDoor {
    enum ServerState: Equatable {
        case off
        case running
        /// The toggle is ON but no library is open (locked, opening, or a
        /// test process) — the server starts when one is.
        case waitingForLibrary
        case failed(String)
    }

    /// One client row: the client and its live grants.
    nonisolated struct ClientRow: Equatable, Identifiable, Sendable {
        var id: String { client.id }
        let client: MCPClient
        /// 13n-c U2 (R2-3): the live grants that REACH their target — the
        /// row's "N shared places" (an inert one is never called shared).
        let liveGrantCount: Int
        /// The live grants whose target is fenced since (P-13nb-U2-3).
        var inertGrantCount: Int = 0
    }

    /// What the pane shows, read in one go from the grants store.
    nonisolated struct Snapshot: Equatable, Sendable {
        var enabled = false
        var openBook = false
        var pending: [MCPClient] = []
        var pendingCount = 0
        var clients: [ClientRow] = []
        var clientCount = 0
        /// 13n-c U3: Shared places, ONE ROW PER ACT (`Queries.mcpSharedGroups`
        /// — a bulk share's N note grants on one stamp read as one row).
        var sharedGroups: [MCPSharedGroup] = []
        /// How many ACTS Shared places holds (the "all N ›" road's N).
        var sharedCount = 0
        /// 13n-c U3 (R-AIR-8): how many clients are APPROVED — every share
        /// face outside the pane renders only when this is at least one.
        var approvedCount = 0
        /// U3 — the ACTIVITY face: the newest coalesced lines and the log's
        /// whole row count (the "all N ›" road's N).
        var activity: [MCPActivityFace.Line] = []
        var activityCount = 0

        /// The shown acts' rows (each act's titled members) — the shape the
        /// pane's pins have read since 13n-b.
        var shared: [MCPSharedRow] { sharedGroups.flatMap(\.rows) }
    }

    /// How many rows each list shows before its "all N ›" road (R-13n-10 —
    /// PROVISIONAL P-13nb-U1-8: requests 3, clients 5, shared 5).
    nonisolated static let pendingCap = 3
    nonisolated static let clientCap = 5
    nonisolated static let sharedCap = 5
    /// U3 (R-13n-10, PROVISIONAL with U1's caps): the activity list shows
    /// its newest 5 lines, coalesced from the newest 50 rows; the "all N ›"
    /// road holds the whole log (capped at 500 rows by the store).
    nonisolated static let activityCap = 5
    nonisolated static let activityWindow = 50

    private(set) var snapshot = Snapshot()
    private(set) var connected: Set<String> = []
    /// 13n-c U3 — THE SHARE FACES' TWO GATES, as NARROW observables (set only
    /// when they change, so a window composing its `MCPShareRoad` from them
    /// never re-renders on a snapshot that changed nothing it reads — the
    /// snapshot itself can re-land at autosave rate while a note grant's
    /// title is listed). R-AIR-8: at least one APPROVED client. R-AIR-7: the
    /// server switch ON.
    private(set) var hasApprovedClient = false
    private(set) var serverOn = false
    private(set) var serverState: ServerState = .off
    /// The pane's own caption (Settings has no status seam): the last
    /// refusal or receipt, plainly — rendered BESIDE the door that spoke
    /// (the copy receipt under its button; a refusal at the pane's head).
    nonisolated struct Note: Equatable, Sendable {
        /// 13n-c UX walk W-UX-8: `.waiting` — the pane's caption BY Waiting,
        /// where her press was (a gone ask's line).
        enum Place: Equatable, Sendable { case top, connect, waiting }
        let text: String
        let place: Place
    }
    var note: Note?

    // 13n-c U3: readable (never writable) from the share road's acts —
    // `MCPDoor+Share.swift`, the door's second file.
    @ObservationIgnored private(set) weak var session: AppSession?
    @ObservationIgnored private(set) var database: AppDatabase?
    @ObservationIgnored private(set) var runner: OperationsRunner?
    @ObservationIgnored private var host: MCPServerHost?
    @ObservationIgnored private var observation: Task<Void, Never>?
    /// A start is in flight off the main thread — never start twice.
    @ObservationIgnored private var starting = false
    /// R-13nb-6: an adopted library's OFF write has not landed yet — the
    /// server may not start (row 10).
    @ObservationIgnored private var adoptionLandingPending = false
    /// Whether this process may run a server at all (never a test process —
    /// the test host IS the dev-store app).
    @ObservationIgnored private let serverAllowed: Bool
    @ObservationIgnored private let makeHost: @MainActor (AppDatabase, any MCPWriteExecutor) -> MCPServerHost?

    /// U2 — THE JUST-IN-TIME ASKS waiting for her (AF-6): in memory (a
    /// dropped ask costs the client one re-ask), deduped per client · target
    /// · rung, capped. **13n-c U4 — ARRIVAL X (the brief §5; supersedes
    /// P-13nb-U2-9's arrival):** an ask WAITS — at its pending glyph on the
    /// thing it names and in Settings ▸ MCP ▸ Waiting. Nothing presents
    /// itself: the main window's self-presenting sheet is retired, and a
    /// sheet opens only on HER press (the window's road — `answerAsk`).
    private(set) var askQueue = MCPAskQueue()
    /// The keyed projection every face reads (`MCPAskBoard`) — reassigned only
    /// when the queue changes, so a window handing it down re-renders only
    /// the faces that read it, only then.
    private(set) var askBoard = MCPAskBoard.empty
    /// The asks whose sheet she has OPEN (a glyph's press, Waiting's
    /// Answer…) — the cap never forgets one of these.
    @ObservationIgnored private var answering: Set<String> = []
    /// **13n-c Stage B R2-1 (b) — THE ASK WATCH:** one observation, alive only
    /// while an ask waits, whose fetch IS the re-validation (`askStanding`
    /// over every waiting ask, one read — ∝ the queue, never the corpus),
    /// NAMED on `reading` + `wing` (`AppDatabase.observe(tracking:_:)`): a
    /// book's death, un-binding or mark and a wing's death wake it; an
    /// autosave never does (measured — `RegionObservationTests`: an autosave's
    /// full-record `container` stamp is indistinguishable from a note's trip
    /// to the Trash, so a note's death is caught where its mark can still
    /// show — Waiting's render — and at her press). Restarted (one immediate
    /// re-validation of EVERY waiting ask) whenever the set of asks changes.
    @ObservationIgnored private var askWatch: Task<Void, Never>?
    @ObservationIgnored private var watchedAskIDs: Set<String> = []
    /// The asks kept waiting at once (PROVISIONAL P-13nb-U2-9, with the
    /// queue's shape): past it the oldest waiting one she is not answering is
    /// forgotten.
    nonisolated static let askCap = MCPAskQueue.cap
    /// How many Waiting rows Settings ▸ MCP shows before its "all N ›" road
    /// (mockup §4 draws three — the requests list's cap, R-13n-10).
    nonisolated static let waitingCap = 3
    /// The waiting asks, oldest first (the 13n-b shape the pins read).
    var asks: [MCPAsk] { askQueue.entries.map(\.ask) }
    /// Newest first — Waiting's order.
    var waiting: [MCPAskQueue.Entry] { askQueue.newestFirst }
    /// One waiting ask by id — nil once it was answered (anywhere), forgotten
    /// by the cap, or the library closed (a sheet holding it then closes).
    func ask(_ id: String) -> MCPAsk? { askQueue.entry(id)?.ask }
    /// 13n-c UX walk W-UX-1 — her press: THE raise of this ask waiting now
    /// (nil once it no longer waits — the press then opens nothing).
    func opening(_ id: String) -> MCPAskOpening? { askQueue.entry(id)?.opening }
    /// The ask a host's sheet presents for the raise her press opened — only
    /// while THAT raise waits: an equal ask raised after she answered is a new
    /// raise, and waits at its mark (arrival X — W-UX-1).
    func ask(_ opening: MCPAskOpening) -> MCPAsk? {
        guard let entry = askQueue.entry(opening.id), entry.raise == opening.raise else { return nil }
        return entry.ask
    }

    /// 13n-c U4 — ⌥⌘, (MCP Settings…): a REQUEST that Settings adopts (its
    /// pane → MCP) and the MCP pane answers (scrolled to Waiting when an ask
    /// waits). A counter, so every press is a fresh request and the two
    /// readers each keep their own "seen" mark — neither clears it under the
    /// other.
    private(set) var settingsRequest = 0
    @ObservationIgnored var settingsRequestAdopted = 0
    @ObservationIgnored var settingsRequestScrolled = 0

    /// U4 (R-13nb-23 (a), AF-11 F-2) — THE AI's LAST CHANGE this session:
    /// where the most recent write receipt's "Open ›" goes. Observable, so
    /// "Show the AI's Last Change" (⌥⌘O) greys and ungreys with it;
    /// session-scoped (cleared at detach — R-13nb-19's session-bounded twin).
    private(set) var lastShow: MCPShowTarget?
    /// U4 (AF-11 F-3): the windows `show_in_app` may move — set at attach.
    @ObservationIgnored private weak var windows: WindowRegistry?
    /// U4 (AF-11 F-3): where the app stands, asked ON THE MAIN ACTOR in the
    /// delivery's own hop (injectable for the pins).
    @ObservationIgnored var standingProvider: (@MainActor () -> (MCPShowRule.Standing, ShellRouter?))?

    /// U2 — the receipt RUN: consecutive acts by one client on one target
    /// within the window speak as one coalesced line (her fact-check's
    /// "added 2 takes and saved the lens …").
    @ObservationIgnored private var receiptRun: [MCPWriteReceipt] = []
    @ObservationIgnored private var receiptRunAt = Date.distantPast
    nonisolated static let receiptWindow: TimeInterval = 120

    init(
        serverAllowed: Bool = !KeychainTestTripwire.armed,
        makeHost: (@MainActor (AppDatabase, any MCPWriteExecutor) -> MCPServerHost?)? = nil
    ) {
        self.serverAllowed = serverAllowed
        self.makeHost = makeHost ?? { database, executor in
            guard let directory = MCPDoor.socketDirectory else { return nil }
            return MCPServerHost(
                database: database, operations: Operations(), directory: directory,
                version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0",
                executor: executor)
        }
    }

    // MARK: - Where the socket lives (THE one rule — the shim reads the same)

    /// `<the app's container>/Data` — from this app's bundle id and the real
    /// home, exactly as the shim derives it from its own bundle.
    static var socketDirectory: URL? {
        guard let bundleID = Bundle.main.bundleIdentifier, let home = MCPSocketRoad.realHome() else { return nil }
        return MCPSocketRoad.containerDataDirectory(bundleIdentifier: bundleID, realHome: home)
    }

    /// The embedded shim this build ships.
    static var shimPath: String {
        Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/variorum-mcp").path
    }

    static var isDebugBuild: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    var setupCommand: String {
        MCPPaneCopy.setupCommand(shimPath: Self.shimPath, isDebugBuild: Self.isDebugBuild)
    }

    /// 13n-c U5 (R-AIR-13): the setup menu's chosen client's text — the
    /// command or the stanza the pane shows. VX-168 (K2): SHOWN with the key
    /// masked (`MCPPaneCopy.shownKey`); the copy carries a freshly minted one.
    func setupText(for client: MCPSetupClient) -> String {
        client.text(shimPath: Self.shimPath, isDebugBuild: Self.isDebugBuild)
    }

    // MARK: - Attach / detach (A-8)

    /// The store is open: observe the grants store; start the server when the
    /// toggle says so.
    ///
    /// 13n-b U2 (ledger row 10, R-13nb-6 — ADOPTION LANDS OFF): `storeURL` is
    /// the open library's path. When a 13x RESTORE HOLD stands beside it, the
    /// grants store's acknowledgement of THAT hold is asked first
    /// (`landMCPAfterAdoption` — the switch OFF on a hold not yet seen, one
    /// transaction) and the server may not start until the answer lands: an
    /// adopted library never serves before its OFF write. The grants
    /// observation itself starts only AFTER that write commits, so no value
    /// computed before it (a stale "on") can ever reach `reconcileServer`. A
    /// failed landing keeps the server down for this session (the
    /// conservative direction); the pane still renders.
    func attach(session: AppSession, storeURL: URL? = nil, windows: WindowRegistry? = nil) {
        // U4: the windows a show may move (kept across re-attaches of the
        // same session — the window register outlives a ready).
        if let windows { self.windows = windows }
        // Idempotent per session: the same ready re-appearing keeps its
        // server and its connections.
        guard session !== self.session else { return }
        detach()
        self.session = session
        database = session.database
        runner = session.runner
        // U4 (AF-11 F-2): the registry's fact for "Show the AI's Last Change".
        session.commandRouter.aiLastChangeAvailable = { [weak self] in self?.lastShow != nil }
        guard let storeURL, let hold = LibraryRestoreHold.read(besideStore: storeURL) else {
            observe(session.database)
            return
        }
        adoptionLandingPending = true
        let stamp = DateFormatter.variorumISO8601.string(from: hold.heldAt)
        let runner = session.runner
        Task { @MainActor [weak self] in
            let landed = (try? await runner.run { try $0.landMCPAfterAdoption(holdStamp: stamp) }) != nil
            guard let self, self.session === session else { return }
            self.adoptionLandingPending = !landed
            self.observe(session.database)
        }
    }

    private func observe(_ database: AppDatabase) {
        // One observation at a time (a detach + re-attach of the same
        // session can race two landings to this line).
        observation?.cancel()
        let observed = database.observe { db in try MCPDoor.read(db) }
        observation = Task { [weak self] in
            do {
                for try await snapshot in observed {
                    guard let self else { return }
                    self.snapshot = snapshot
                    self.adoptGates(snapshot)
                    self.reconcileServer()
                }
            } catch {}
        }
    }

    /// The narrow gates follow the snapshot — written only on a change.
    private func adoptGates(_ snapshot: Snapshot) {
        let approved = snapshot.approvedCount > 0
        if hasApprovedClient != approved { hasApprovedClient = approved }
        if serverOn != snapshot.enabled { serverOn = snapshot.enabled }
    }

    /// The store is closing (lock, quit): stop the server — the socket is
    /// unlinked, every session hung up — and let the store go.
    func detach() {
        observation?.cancel()
        observation = nil
        stopServer()
        adoptionLandingPending = false
        // A closed library's asks die with it (and so does every glyph — and
        // the ask watch, which an empty queue stops).
        adoptQueue(MCPAskQueue())
        answering = []
        receiptRun = []
        lastShow = nil
        // A locked library shows no share face (R-AIR-8's gate reads no store).
        if hasApprovedClient { hasApprovedClient = false }
        session = nil
        database = nil
        runner = nil
        serverState = snapshot.enabled ? .waitingForLibrary : .off
    }

    /// Start or stop the server to match the toggle.
    private func reconcileServer() {
        guard snapshot.enabled else {
            stopServer()
            serverState = .off
            return
        }
        guard serverAllowed, let database, !adoptionLandingPending else {
            serverState = .waitingForLibrary
            return
        }
        if let host, host.state == .running || starting {
            if host.state == .running { serverState = .running }
            return
        }
        // U2 (AF-8): MCP writes run on the SESSION's runner — her own
        // gestures' road, the serialization the undo stack requires.
        guard let runner, let fresh = host ?? makeHost(database, runner) else {
            serverState = .failed("the app's container could not be located")
            return
        }
        fresh.onConnectionsChanged = { [weak self] in
            Task { @MainActor in self?.refreshConnected() }
        }
        fresh.hooks = MCPHostHooks(
            // "Every refusal speaks to the client exactly as it speaks to
            // her": the Mac's own table.
            refusalWords: { OpsRefusalCopy.message(for: $0) },
            onAsk: { [weak self] ask in Task { @MainActor in self?.enqueue(ask) } },
            onWrite: { [weak self] receipt in Task { @MainActor in self?.landReceipt(receipt) } },
            // U4 (AF-11 F-3): the move dial's delivery — the rule applied on
            // the main actor, in the same hop as any move.
            show: { [weak self] target in
                await self?.agentShow(target) ?? .refuse(MCPShowRule.unavailableWords)
            },
            // 13n-c U6: her Move to Wing door's own sentence for a frozen book
            // (the server speaks it where the client can read the book).
            wingMoveFrozenWords: Self.wingMoveFrozenWords)
        host = fresh
        starting = true
        // The start sweeps the while-connected grants (a write) and binds —
        // OFF the main thread (P2); the state lands back here.
        Task { @MainActor [weak self] in
            let outcome: Result<Void, Error> = await Task.detached { Result { try fresh.start() } }.value
            guard let self else { return }
            self.starting = false
            guard self.host === fresh else {
                // Stopped (toggle OFF, lock, quit) while it was starting.
                fresh.stop()
                return
            }
            switch outcome {
            case .success: self.serverState = .running
            case .failure(let error): self.serverState = .failed(String(describing: error))
            }
            self.refreshConnected()
        }
    }

    private func stopServer() {
        host?.stop()
        host = nil
        starting = false
        connected = []
    }

    private func refreshConnected() {
        connected = host?.connectedClientNames ?? []
    }

    #if DEBUG
    /// The capture harness's seam (13n-c U2 — DEBUG only): who reads as
    /// connected, so an offscreen render can show "while connected" and the
    /// WHO row's "connected now" without a live client.
    func previewConnected(_ names: Set<String>) { connected = names }
    #endif

    // MARK: - The pane's acts (operations, through the runner)

    func setEnabled(_ on: Bool) {
        act { try $0.setMCPSwitch(.server, on: on) }
    }

    func setOpenBook(_ on: Bool) {
        act { try $0.setMCPSwitch(.openBook, on: on) }
    }

    /// Approve a request (or a denied client). 13n-c UX walk W-UX-2 (her
    /// ruling — APPROVE ALONE, GRANT SEPARATE): `spec` is nil unless she
    /// picked a grant in the approval sheet; nil admits with zero reach.
    func approve(_ clientID: String, granting spec: Operations.MCPGrantSpec?) {
        act { _ = try $0.approveMCPClient(clientID, granting: spec) }
    }

    /// Change… on an approved client: one more grant (the U1 sheet adds; a
    /// grant is taken away with its own Revoke).
    func grant(_ clientID: String, _ spec: Operations.MCPGrantSpec) {
        act { _ = try $0.grantMCPAccess(clientID, spec) }
    }

    /// Deny (a request) and Revoke (a client — P-13nb-U1-5): every grant
    /// revoked, the client blocked. 13n-c U4 (T-U4-4): its waiting asks leave
    /// too — an answer to them could only refuse (`mcpClientNotApproved`), and
    /// a glyph whose press can only refuse is a dead door (P-2).
    func deny(_ clientID: String) {
        guard let runner, let database else { return }
        note = nil
        Task { @MainActor [weak self] in
            do {
                try await runner.run { try $0.denyMCPClient(clientID) }
                let name = try? await database.read { try Queries.mcpClient($0, id: clientID)?.name }
                if let name = name ?? nil { self?.forgetAsks(client: name) }
            } catch {
                self?.note = Note(text: MCPPaneCopy.refusal(error), place: .top)
            }
        }
    }

    func revoke(grantID: String) {
        act { try $0.revokeMCPGrant(grantID) }
    }

    /// 13n-c U3: a Shared places row ONE act minted — Revoke covers every
    /// member, in one act.
    func revoke(grantIDs: [String]) {
        act { try $0.revokeMCPGrants(grantIDs) }
    }

    /// Copy setup command (R-13nb-5): the command on the clipboard, the
    /// receipt in the pane's caption. 13n-c U5 (R-AIR-13): the setup menu's
    /// CHOSEN client — Claude Code (the default), Codex, or any MCP client's
    /// JSON — each with its own receipt.
    ///
    /// **VX-168 (K2 — the mint moved to copy time): every copy MINTS a fresh
    /// setup key** (`mintMCPSetupKey` — its hash kept in the grants store,
    /// off the main thread through the session's runner, P2) and copies the
    /// chosen setup CARRYING it. The clipboard is written only once the key
    /// is kept: a setup whose key the library never kept would only be
    /// refused. No library open → nowhere to keep a key → said, nothing copied.
    func copySetupCommand(for client: MCPSetupClient = .claudeCode, to pasteboard: NSPasteboard = .general) async {
        guard let runner else {
            note = Note(text: MCPPaneCopy.setupNeedsLibrary, place: .connect)
            return
        }
        clearConnectNote()
        do {
            let key = try await runner.run { try $0.mintMCPSetupKey() }
            pasteboard.clearContents()
            pasteboard.setString(
                client.text(shimPath: Self.shimPath, isDebugBuild: Self.isDebugBuild, key: key), forType: .string)
            note = Note(text: client.copiedReceipt, place: .connect)
        } catch {
            note = Note(text: MCPPaneCopy.refusal(error), place: .connect)
        }
    }

    /// 13n-c U5: a copy receipt names ONE client's next step, so choosing
    /// another client in the menu clears it (a "Copied … Claude Code" caption
    /// under Codex's text would be a lie). A refusal at the head stays.
    func clearConnectNote() {
        if note?.place == .connect { note = nil }
    }

    private func act(_ body: @escaping @Sendable (Operations) throws -> Void) {
        guard let runner else { return }
        note = nil
        Task { @MainActor [weak self] in
            do {
                try await runner.run(body)
            } catch {
                self?.note = Note(text: MCPPaneCopy.refusal(error), place: .top)
            }
        }
    }

    // MARK: - The just-in-time ask (AF-6)

    /// A client asked past its grant (the call already answered — an ask
    /// never blocks). Queued once per client · target · rung, stamped with
    /// when it first arrived. **It only WAITS** (13n-c U4, arrival X): the
    /// board gains its target, and nothing — no sheet, no toast, no raised
    /// window — presents itself (R-13nb-23/26g: etiquette is law).
    func enqueue(_ ask: MCPAsk, now: Date = Date()) {
        guard session != nil else { return }
        var queue = askQueue
        guard queue.enqueue(ask, at: now, answering: answering) else { return }
        adoptQueue(queue)
    }

    /// The queue and its projection move together; the board is reassigned
    /// only when it changed.
    private func adoptQueue(_ queue: MCPAskQueue) {
        // UX-fix ladder UXR1-6: Waiting's own caption (W-UX-8's gone line)
        // speaks about the rows she pressed among; once those rows change —
        // an ask arriving, answered or forgotten — it would speak over a list
        // no longer shown (or stale above FRESH asks), so it leaves. A press
        // that removes its own ask says so AFTER this (`refreshAsk`).
        if note?.place == .waiting, queue.entries.map(\.id) != askQueue.entries.map(\.id) { note = nil }
        askQueue = queue
        let board = queue.board
        if board != askBoard { askBoard = board }
        watchAsks()
    }

    /// (Re)start the ask watch when the set of waiting asks changed; stop it
    /// when none waits (Stage B R2-1 (b)).
    private func watchAsks() {
        let ids = Set(askQueue.entries.map(\.id))
        guard ids != watchedAskIDs else { return }
        watchedAskIDs = ids
        askWatch?.cancel()
        askWatch = nil
        guard !ids.isEmpty, let database else { return }
        let asks = askQueue.entries.map(\.ask)
        let observed = database.observe(tracking: [Table("reading"), Table("wing")]) { db in
            try MCPDoor.asksStanding(db, asks)
        }
        askWatch = Task { [weak self] in
            do {
                for try await standing in observed {
                    guard let self, !Task.isCancelled else { return }
                    self.adoptStanding(standing)
                }
            } catch {}
        }
    }

    /// **One re-validation of every waiting ask, now** (Stage B R2-1 (b) —
    /// Waiting's render: the one face where a note's dead mark can still
    /// show). Silent: a gone target's ask is forgotten, a standing one takes
    /// its fresh picture. One read, ∝ the queue.
    func revalidateAsks() async {
        let asks = askQueue.entries.map(\.ask)
        guard !asks.isEmpty,
              let standing = await read({ db in try MCPDoor.asksStanding(db, asks) }) else { return }
        adoptStanding(standing)
    }

    /// The batch's verdicts, applied to the queue AS IT STANDS NOW (an ask
    /// answered or forgotten meanwhile is simply not there): gone ⇒ forgotten
    /// (silently — the mark leaving is the change; an open sheet closes, as
    /// when its ask is answered elsewhere), standing ⇒ its fresh picture.
    private func adoptStanding(_ standing: [AskStanding]) {
        var queue = askQueue
        var changed = false
        for verdict in standing {
            if let fresh = verdict.ask {
                if queue.refresh(fresh) { changed = true }
            } else if queue.remove(verdict.id) != nil {
                answering.remove(verdict.id)
                changed = true
            }
        }
        if changed { adoptQueue(queue) }
    }

    /// One waiting ask's verdict: its target as it stands, or nil when gone.
    nonisolated struct AskStanding: Equatable, Sendable {
        let id: String
        let ask: MCPAsk?
    }

    /// Every waiting ask's verdict in ONE read (≤ `MCPAskQueue.cap`), each
    /// through `askStanding` — the one derivation site.
    nonisolated static func asksStanding(_ db: Database, _ asks: [MCPAsk]) throws -> [AskStanding] {
        try asks.map { AskStanding(id: $0.id, ask: try askStanding(db, $0)) }
    }

    /// A client's waiting asks, forgotten whole (T-U4-4).
    func forgetAsks(client name: String) {
        var queue = askQueue
        guard queue.forget(client: name) > 0 else { return }
        adoptQueue(queue)
    }

    /// An ask's sheet is open (her press) — the cap must not forget it while
    /// she reads it.
    func beginAnswering(_ id: String) { answering.insert(id) }
    func endAnswering(_ id: String) { answering.remove(id) }

    /// ⌥⌘, — Settings at MCP (at Waiting when an ask waits).
    func requestSettings() { settingsRequest += 1 }

    enum AskAnswer: Equatable, Sendable {
        case grant(MCPGrantRule.Duration)
        case dontAllow
    }

    /// The durations an ask may offer: "while connected" only to a client
    /// connected now (U1's rule carried), "always" never on a fenced target
    /// (R-13n-4; R2-1's fix). 13n-c Stage B R1 B2: read on the ask's CURRENT
    /// facts (`refreshAsk`), and a BOOK a fence covers now offers NOTHING — a
    /// fenced book is never a grant scope (`insertMCPGrant` refuses every
    /// duration), so any answer drawn there would be a dead door (P-2).
    func durations(for ask: MCPAsk) -> [MCPGrantRule.Duration] {
        if ask.scopeKind == .book, ask.fence != nil { return [] }
        var offered: [MCPGrantRule.Duration] = [.once]
        if connected.contains(ask.clientName) { offered.append(.connection) }
        if ask.offersAlways { offered.append(.always) }
        return offered
    }

    /// **13n-c Stage B R1 B2 — a waiting ask, read on CURRENT facts.** An ask
    /// carries the fence and title its client's call saw when it ARRIVED; under
    /// arrival X it may wait for hours, and a Private mark, a new daily
    /// Journal or a deletion since makes that snapshot a lie (Always offered
    /// on a note now fenced — a press that can only refuse). Her press reads
    /// the target again through the ONE derivation site (`askStanding`): the
    /// queue's entry takes the fresh payload (its stamp and place kept), and a
    /// target that is gone forgets its ask (the sheet closes — it reads the
    /// queue). Returns the ask as it stands, nil when it no longer waits.
    ///
    /// **13n-c Stage B R2-1 (a):** her press opened a sheet that then closed
    /// because its place is gone — a door that did nothing — so it SAYS so, a
    /// refusal naming the place (`MCPAskCopy.gone`), on the seam of the host
    /// she pressed in: a window's status line, or the pane's own caption
    /// (Settings has no status seam). Said even when the ask watch forgot the
    /// ask during this read — her press is the one that found nothing.
    @discardableResult
    func refreshAsk(_ id: String, from seam: AskSeam = .window) async -> MCPAsk? {
        guard let waiting = ask(id) else { return nil }
        guard let standing = await read({ db in try MCPDoor.askStanding(db, waiting) }) else {
            return ask(id)  // the read failed: nothing learned, nothing changed
        }
        var queue = askQueue
        guard let fresh = standing else {
            if queue.remove(id) != nil { adoptQueue(queue) }
            answering.remove(id)
            sayGone(waiting, in: seam)
            return nil
        }
        if queue.refresh(fresh) { adoptQueue(queue) }
        return ask(id)
    }

    /// Where an ask's sheet was opened (Stage B R2-1 (a)): a WINDOW (its
    /// status seam) or the Settings PANE (no status seam — the door's own
    /// caption at the pane's head, its refusals' home).
    nonisolated enum AskSeam: Sendable { case window, pane }

    /// UX-fix ladder UXR1-6: the pane went away (another pane, Settings
    /// closed) — Waiting's caption spoke about the press she made there, so it
    /// goes with it; a caption elsewhere in the pane is not Waiting's.
    func letWaitingNoteGo() {
        if note?.place == .waiting { note = nil }
    }

    private func sayGone(_ ask: MCPAsk, in seam: AskSeam) {
        let words = MCPAskCopy.gone(ask)
        switch seam {
        case .window: session?.status.refuse(words)
        // 13n-c UX walk W-UX-8 (T-15): BY WAITING, where she pressed — the
        // pane's head sat inside the server card, off-screen or clipped once
        // ⌥⌘, had scrolled the pane down to Waiting.
        case .pane: note = Note(text: words, place: .waiting)
        }
    }

    /// An ask's target as it stands now — its title and fence through the
    /// ONE derivation site (`mcpNoteFacts` / `mcpBookFacts`, never
    /// re-derived), or nil when the target is gone (deleted, or no longer a
    /// note or book a grant may name; a dead wing).
    nonisolated static func askStanding(_ db: Database, _ ask: MCPAsk) throws -> MCPAsk? {
        let fence: MCPGrantRule.Fence?
        switch ask.scopeKind {
        case .note:
            guard let facts = try Queries.mcpNoteFacts(db, noteID: ask.scopeID) else { return nil }
            fence = facts.fence
        case .book:
            guard let facts = try Queries.mcpBookFacts(db, readingID: ask.scopeID) else { return nil }
            fence = facts.fence
        case .wing:
            fence = nil
        }
        guard let title = try Queries.mcpScopeTitle(db, kind: ask.scopeKind, id: ask.scopeID) else { return nil }
        return MCPAsk(
            clientName: ask.clientName, scopeKind: ask.scopeKind, scopeID: ask.scopeID, title: title,
            rung: ask.rung, fence: fence)
    }

    /// Her answer: a grant through the ordinary ops (the ask's rung, its
    /// target as the scope), or nothing. Either way the ask leaves the queue.
    /// 13n-c U4 (T-U4-5): ONLY an ask still waiting is answered — a second
    /// sheet on the same ask (another window, the pane) answers nothing, so
    /// one ask can never mint two grants.
    func answer(_ ask: MCPAsk, _ answer: AskAnswer) {
        var queue = askQueue
        guard queue.remove(ask.id) != nil else { return }
        adoptQueue(queue)
        answering.remove(ask.id)
        guard case .grant(let duration) = answer, let runner, let database, let session else { return }
        let spec = Operations.MCPGrantSpec(
            rung: ask.rung, scopeKind: ask.scopeKind, scopeID: ask.scopeID, duration: duration)
        Task { @MainActor in
            do {
                try await runner.run { ops in
                    guard let client = try database.read({ try Queries.mcpClient($0, name: ask.clientName) }) else {
                        throw OperationError.mcpClientNotFound(id: ask.clientName)
                    }
                    _ = try ops.grantMCPAccess(client.id, spec)
                }
                session.status.receipt(MCPAskCopy.granted(ask, duration: duration))
            } catch {
                session.status.refuse(MCPPaneCopy.refusal(error))
            }
        }
    }

    // MARK: - Receipts (the app's voice — P-13n-1)

    /// A write landed: say it on the one status seam, coalesced with the
    /// client's run on the same target (P-4: the signal carries no decision).
    func landReceipt(_ receipt: MCPWriteReceipt, now: Date = Date()) {
        guard let session else { return }
        if let last = receiptRun.last, last.clientName == receipt.clientName,
           last.targetID == receipt.targetID, now.timeIntervalSince(receiptRunAt) < Self.receiptWindow {
            receiptRun.append(receipt)
        } else {
            receiptRun = [receipt]
        }
        receiptRunAt = now
        // U4 (R-13nb-23 (a), AF-11 F-2): the line STAYS A RECEIPT (her
        // receipt_style governs it) and grows the one-press door — "Open ›"
        // to the act's landing; the same target is the session's last AI
        // change, which ⌥⌘O opens after the line has faded (or never showed).
        if let show = receipt.show { lastShow = show }
        let door = receipt.show.map { target in
            StatusCenter.Item.Action(label: MCPReceiptCopy.openDoor) { [weak self] in self?.openShow(target) }
        }
        session.status.deliver(MCPReceiptCopy.line(receiptRun), kind: .receipt, action: door)
    }

    /// 13n-c U6 — `move_note_to_wing`'s refusal for a note held by a finished
    /// or sealed book: HER door's sentence (`WingCopy.frozen`), ONE source.
    nonisolated static let wingMoveFrozenWords: @Sendable (String, String) -> String = {
        WingCopy.frozen($0, book: $1)
    }

    // MARK: - Navigation (U4 — R-13nb-23, AF-11 F-2/F-3)

    /// Where the app stands, read now (main actor): Variorum frontmost
    /// (`NSApp.isActive`) AND its KEY window a FULL window (one that
    /// navigates) — the router that window owns rides along.
    func currentStanding() -> (MCPShowRule.Standing, ShellRouter?) {
        if let standingProvider { return standingProvider() }
        guard NSApp.isActive else { return (.notFrontmost, nil) }
        guard let entry = windows?.entry(for: NSApp.keyWindow), entry.kind == .full else {
            return (.frontmostOtherWindow, nil)
        }
        return (.frontmostMainWindow, entry.router)
    }

    /// **`show_in_app`'s delivery** — her etiquette FIRST (`MCPShowRule`,
    /// one pure verdict), and the move only on `.navigate`, into the key
    /// window, never raising another. Never automatic: only a client's
    /// explicit call reaches here.
    ///
    /// Ladder round 1, F-4: the delivery's ANSWER is the delivery's TRUTH —
    /// a takes/lens landing that never arrived (the note's detail did not
    /// register in time, or she left the app during the wait: the
    /// `stillStanding` re-check after the suspension) refuses
    /// `partialShowWords` instead of claiming shown.
    func agentShow(_ target: MCPShowTarget) async -> MCPShowRule.Verdict {
        let (standing, router) = currentStanding()
        let verdict = MCPShowRule.verdict(standing)
        guard verdict == .navigate, let session, let router else {
            return verdict == .navigate ? .refuse(MCPShowRule.unavailableWords) : verdict
        }
        let delivered = await MCPNavigator(session: session).deliver(
            target, into: router,
            stillStanding: { [weak self] in
                guard let self else { return false }
                return MCPShowRule.verdict(self.currentStanding().0) == .navigate
            })
        return delivered ? .navigate : .refuse(MCPShowRule.partialShowWords)
    }

    /// HER press — a receipt's "Open ›" or ⌥⌘O: she is at the app, so no
    /// etiquette gate; the window that can show it is used (and raised when
    /// a note-only window is key — `creationRouter`, her creation doors'
    /// own rule).
    func openShow(_ target: MCPShowTarget) {
        guard let session, let router = windows?.creationRouter() else { return }
        Task { @MainActor in await MCPNavigator(session: session).deliver(target, into: router) }
    }

    /// ⌥⌘O — "Show the AI's Last Change" (session-scoped; grey when none).
    func showLastChange() {
        guard let lastShow else {
            session?.status.refuse(CapabilityRegistry.capability(.showLastAIChange).unavailableNote)
            return
        }
        openShow(lastShow)
    }

    // MARK: - The full lists ("all N ›") and the sheet's choices

    func allPending() async -> [MCPClient] {
        await read { try Queries.mcpClients($0, states: [.pending]) } ?? []
    }

    func allClients() async -> [ClientRow] {
        await read { db in
            try Queries.mcpClients(db, states: [.approved, .denied]).map { client in
                try MCPDoor.clientRow(db, client)
            }
        } ?? []
    }

    /// 13n-c U3: the whole Shared places list, one row per act.
    func allSharedGroups() async -> [MCPSharedGroup] {
        await read { try Queries.mcpSharedGroups($0) } ?? []
    }

    /// 13n-c Stage B R1 B3: one act's members, every one named — the road
    /// behind a grouped row's "and N more ›" (∝ the act). R2-2: nil when the
    /// read failed (nothing learned) — distinct from an act with no live
    /// member left, which closes the members sheet.
    func sharedMembers(_ grantIDs: [String]) async -> [MCPSharedRow]? {
        await read { try Queries.mcpSharedActMembers($0, grantIDs: grantIDs) }
    }

    /// U3: the whole log (≤ the store's 500-row cap), coalesced.
    func allActivity() async -> [MCPActivityFace.Line] {
        await read { MCPActivityFace.lines(try Queries.mcpActivity($0)) } ?? []
    }

    nonisolated struct Choices: Sendable {
        var books: [Queries.MCPGrantableBook] = []
        /// Home first (`''`), then every live wing, with its name.
        var wings: [(id: String, name: String)] = []
    }

    func choices() async -> Choices {
        await read { db in
            Choices(
                books: try Queries.mcpGrantableBooks(db),
                wings: [("", Queries.mcpHomeWingName)] + (try Queries.wings(db)).map { ($0.id, $0.name) })
        } ?? Choices()
    }

    // MARK: - The grant sheet's reads (13n-c U2 — one-shot, never held)

    /// Everything the book and wing pickers show (`Queries.mcpGrantPlaces`).
    func grantPlaces() async -> MCPGrantPlaces {
        await read { try Queries.mcpGrantPlaces($0) } ?? MCPGrantPlaces()
    }

    /// WHO: the approved clients, most recently granted first.
    func clientsByRecentGrant() async -> [MCPClient] {
        await read { try Queries.mcpClientsByRecentGrant($0) } ?? []
    }

    /// The wing the window is in — the note leg's default.
    var currentWingID: String { session?.wing.currentID ?? "" }

    /// **The note leg's feed** — the bounded `corpusNotes` road (≤30 rows
    /// per query, recent first; the one note picker's feed) in the chosen
    /// wing, each row fence-marked on the ONE derivation site (one batched
    /// `mcpNoteFacts` per page — ∝ the page, P1).
    func grantNotes(query: String, wingID: String) async -> [MCPGrantPicker.NoteRow] {
        guard let session else { return [] }
        let rows = await NotePickerSource.corpusNotes(session: session, excluding: nil, inWing: wingID)
            .search(query)
        let ids = rows.map(\.id)
        let facts = await read { try Queries.mcpNoteFacts($0, noteIDs: ids) } ?? [:]
        return rows.map { row in
            MCPGrantPicker.NoteRow(
                id: row.id, title: row.title, snippet: row.snippet, day: row.detail,
                fence: facts[row.id]?.fence, wingID: facts[row.id]?.wingID)
        }
    }

    /// One note, named (a pre-filled WHERE — U3's doors): its title and its
    /// fence, or nil when it is not a note a grant may name.
    /// **13n-c +4b (her ruling, sitting round 5) — DISPLAY-ONLY:** the Private
    /// books a note's mark comes through, for the grant sheet's why — the SAME
    /// pair the lock popover reads (`Queries.isNotePrivate` +
    /// `Queries.privateBooksHolding`), never a fence: whether always is
    /// offered stays `mcpNoteFacts`' answer. Empty when the note wears its own
    /// mark (its own sentence stands) or no Private book holds it.
    func privateMarkBooks(noteID: String) async -> [String] {
        await read { db in
            guard try !Queries.isNotePrivate(db, postID: noteID) else { return [] }
            return try Queries.privateBooksHolding(db, postID: noteID)
        } ?? []
    }

    func grantNote(_ id: String) async -> MCPGrantPicker.NoteRow? {
        await read { db in
            guard let facts = try Queries.mcpNoteFacts(db, noteID: id),
                  let title = try Queries.mcpScopeTitle(db, kind: .note, id: id) else { return nil }
            return MCPGrantPicker.NoteRow(
                id: id, title: title, snippet: nil, day: nil, fence: facts.fence, wingID: facts.wingID)
        } ?? nil
    }

    /// 13n-c U3 — several notes, named (the Library's "Share N notes…"
    /// pre-fill): each live note a grant may name, with its title and fence,
    /// in the order given; a note that is not one is left out. One batched
    /// facts read (∝ the pick).
    func namedNotes(_ ids: [String]) async -> [MCPGrantPicker.NoteRow] {
        await read { db in
            let facts = try Queries.mcpNoteFacts(db, noteIDs: ids)
            return try ids.compactMap { id in
                guard let fact = facts[id],
                      let title = try Queries.mcpScopeTitle(db, kind: .note, id: id) else { return nil }
                return MCPGrantPicker.NoteRow(
                    id: id, title: title, snippet: nil, day: nil, fence: fact.fence, wingID: fact.wingID)
            }
        } ?? []
    }

    /// **The distinguishers the pane's rows and the ask sheet wear** — the
    /// ONE rule (`PlaceLabels`) over the OFFERED books and the wings, so a
    /// shared row or an ask names the same book the sheet's picker did.
    func placeDistinguishers(now: Date = Date()) async -> (books: [String: String], wings: [String: String]) {
        let places = await grantPlaces()
        return (places.bookDistinguishers(now: now), places.wingDistinguishers(now: now))
    }

    private func read<T: Sendable>(_ body: @escaping @Sendable (Database) throws -> T) async -> T? {
        guard let database else { return nil }
        return try? await database.read(body)
    }

    // MARK: - The snapshot read

    nonisolated static func read(_ db: Database) throws -> Snapshot {
        let clients = try Queries.mcpClients(db, states: [.approved, .denied], limit: clientCap)
        return Snapshot(
            enabled: try Queries.mcpSwitch(db, .server),
            openBook: try Queries.mcpSwitch(db, .openBook),
            pending: try Queries.mcpClients(db, states: [.pending], limit: pendingCap),
            pendingCount: try Queries.mcpClientCount(db, states: [.pending]),
            clients: try clients.map { client in try clientRow(db, client) },
            clientCount: try Queries.mcpClientCount(db, states: [.approved, .denied]),
            sharedGroups: try Queries.mcpSharedGroups(db, limit: sharedCap),
            sharedCount: try Queries.mcpSharedGroupCount(db),
            approvedCount: try Queries.mcpClientCount(db, states: [.approved]),
            activity: Array(MCPActivityFace.lines(try Queries.mcpActivity(db, limit: activityWindow))
                .prefix(activityCap)),
            activityCount: try Queries.mcpActivityCount(db))
    }

    /// One client's row (13n-c U2, R2-3): its reaching and inert grants.
    nonisolated static func clientRow(_ db: Database, _ client: MCPClient) throws -> ClientRow {
        let counts = try Queries.mcpGrantReachCounts(db, clientID: client.id)
        return ClientRow(client: client, liveGrantCount: counts.reaching, inertGrantCount: counts.inert)
    }
}
