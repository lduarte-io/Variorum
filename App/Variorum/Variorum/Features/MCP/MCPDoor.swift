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
        let liveGrantCount: Int
    }

    /// What the pane shows, read in one go from the grants store.
    nonisolated struct Snapshot: Equatable, Sendable {
        var enabled = false
        var openBook = false
        var pending: [MCPClient] = []
        var pendingCount = 0
        var clients: [ClientRow] = []
        var clientCount = 0
        var shared: [MCPSharedRow] = []
        var sharedCount = 0
        /// U3 — the ACTIVITY face: the newest coalesced lines and the log's
        /// whole row count (the "all N ›" road's N).
        var activity: [MCPActivityFace.Line] = []
        var activityCount = 0
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
    private(set) var serverState: ServerState = .off
    /// The pane's own caption (Settings has no status seam): the last
    /// refusal or receipt, plainly — rendered BESIDE the door that spoke
    /// (the copy receipt under its button; a refusal at the pane's head).
    nonisolated struct Note: Equatable, Sendable {
        enum Place: Equatable, Sendable { case top, connect }
        let text: String
        let place: Place
    }
    var note: Note?

    @ObservationIgnored private weak var session: AppSession?
    @ObservationIgnored private var database: AppDatabase?
    @ObservationIgnored private var runner: OperationsRunner?
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
    /// · rung, capped; the main window's sheet serves the FIRST, one at a time.
    private(set) var asks: [MCPAsk] = []
    /// The asks kept waiting at once (PROVISIONAL P-13nb-U2-9, with the
    /// queue's shape): past it the oldest WAITING one (never the one on
    /// screen) is forgotten.
    nonisolated static let askCap = 8
    var presentedAsk: MCPAsk? { asks.first }

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
                    self.reconcileServer()
                }
            } catch {}
        }
    }

    /// The store is closing (lock, quit): stop the server — the socket is
    /// unlinked, every session hung up — and let the store go.
    func detach() {
        observation?.cancel()
        observation = nil
        stopServer()
        adoptionLandingPending = false
        asks = []
        receiptRun = []
        lastShow = nil
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
            onWrite: { [weak self] receipt in Task { @MainActor in self?.speak(receipt) } },
            // U4 (AF-11 F-3): the move dial's delivery — the rule applied on
            // the main actor, in the same hop as any move.
            show: { [weak self] target in
                await self?.agentShow(target) ?? .refuse(MCPShowRule.unavailableWords)
            })
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

    // MARK: - The pane's acts (operations, through the runner)

    func setEnabled(_ on: Bool) {
        act { try $0.setMCPSwitch(.server, on: on) }
    }

    func setOpenBook(_ on: Bool) {
        act { try $0.setMCPSwitch(.openBook, on: on) }
    }

    func approve(_ clientID: String, granting spec: Operations.MCPGrantSpec) {
        act { _ = try $0.approveMCPClient(clientID, granting: spec) }
    }

    /// Change… on an approved client: one more grant (the U1 sheet adds; a
    /// grant is taken away with its own Revoke).
    func grant(_ clientID: String, _ spec: Operations.MCPGrantSpec) {
        act { _ = try $0.grantMCPAccess(clientID, spec) }
    }

    /// Deny (a request) and Revoke (a client — P-13nb-U1-5): every grant
    /// revoked, the client blocked.
    func deny(_ clientID: String) {
        act { try $0.denyMCPClient(clientID) }
    }

    func revoke(grantID: String) {
        act { try $0.revokeMCPGrant(grantID) }
    }

    /// Copy setup command (R-13nb-5): the command on the clipboard, the
    /// receipt in the pane's caption.
    func copySetupCommand(to pasteboard: NSPasteboard = .general) {
        pasteboard.clearContents()
        pasteboard.setString(setupCommand, forType: .string)
        note = Note(text: MCPPaneCopy.copiedReceipt, place: .connect)
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
    /// never blocks). Queued once per client · target · rung.
    func enqueue(_ ask: MCPAsk) {
        guard session != nil, !asks.contains(where: { $0.id == ask.id }) else { return }
        asks.append(ask)
        while asks.count > Self.askCap { asks.remove(at: 1) }
    }

    enum AskAnswer: Equatable, Sendable {
        case grant(MCPGrantRule.Duration)
        case dontAllow
    }

    /// The durations an ask may offer: "while connected" only to a client
    /// connected now (U1's rule carried), "always" never on a fenced target
    /// (R-13n-4; R2-1's fix).
    func durations(for ask: MCPAsk) -> [MCPGrantRule.Duration] {
        var offered: [MCPGrantRule.Duration] = [.once]
        if connected.contains(ask.clientName) { offered.append(.connection) }
        if ask.offersAlways { offered.append(.always) }
        return offered
    }

    /// Her answer: a grant through the ordinary ops (the ask's rung, its
    /// target as the scope), or nothing. Either way the ask leaves the queue.
    func answer(_ ask: MCPAsk, _ answer: AskAnswer) {
        asks.removeAll { $0.id == ask.id }
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
    func speak(_ receipt: MCPWriteReceipt, now: Date = Date()) {
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
    func agentShow(_ target: MCPShowTarget) async -> MCPShowRule.Verdict {
        let (standing, router) = currentStanding()
        let verdict = MCPShowRule.verdict(standing)
        guard verdict == .navigate, let session, let router else {
            return verdict == .navigate ? .refuse(MCPShowRule.unavailableWords) : verdict
        }
        await MCPNavigator(session: session).deliver(target, into: router)
        return .navigate
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
                ClientRow(client: client, liveGrantCount: try MCPDoor.liveGrantCount(db, clientID: client.id))
            }
        } ?? []
    }

    func allShared() async -> [MCPSharedRow] {
        await read { try Queries.mcpSharedRows($0) } ?? []
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
            clients: try clients.map { client in
                ClientRow(client: client, liveGrantCount: try liveGrantCount(db, clientID: client.id))
            },
            clientCount: try Queries.mcpClientCount(db, states: [.approved, .denied]),
            shared: try Queries.mcpSharedRows(db, limit: sharedCap),
            sharedCount: try Queries.mcpSharedCount(db),
            activity: Array(MCPActivityFace.lines(try Queries.mcpActivity(db, limit: activityWindow))
                .prefix(activityCap)),
            activityCount: try Queries.mcpActivityCount(db))
    }

    nonisolated static func liveGrantCount(_ db: Database, clientID: String) throws -> Int {
        try Queries.mcpGrants(db, clientID: clientID).map(\.ruleGrant).filter(\.isLive).count
    }
}
