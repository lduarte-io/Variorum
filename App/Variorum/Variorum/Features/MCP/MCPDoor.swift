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
    }

    /// How many rows each list shows before its "all N ›" road (R-13n-10 —
    /// PROVISIONAL P-13nb-U1-8: requests 3, clients 5, shared 5).
    nonisolated static let pendingCap = 3
    nonisolated static let clientCap = 5
    nonisolated static let sharedCap = 5

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
    /// Whether this process may run a server at all (never a test process —
    /// the test host IS the dev-store app).
    @ObservationIgnored private let serverAllowed: Bool
    @ObservationIgnored private let makeHost: @MainActor (AppDatabase) -> MCPServerHost?

    init(
        serverAllowed: Bool = !KeychainTestTripwire.armed,
        makeHost: (@MainActor (AppDatabase) -> MCPServerHost?)? = nil
    ) {
        self.serverAllowed = serverAllowed
        self.makeHost = makeHost ?? { database in
            guard let directory = MCPDoor.socketDirectory else { return nil }
            return MCPServerHost(
                database: database, operations: Operations(), directory: directory,
                version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0")
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
    func attach(session: AppSession) {
        // Idempotent per session: the same ready re-appearing keeps its
        // server and its connections.
        guard session !== self.session else { return }
        detach()
        self.session = session
        database = session.database
        runner = session.runner
        let database = session.database
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
        guard serverAllowed, let database else {
            serverState = .waitingForLibrary
            return
        }
        if let host, host.state == .running || starting {
            if host.state == .running { serverState = .running }
            return
        }
        guard let fresh = host ?? makeHost(database) else {
            serverState = .failed("the app's container could not be located")
            return
        }
        fresh.onConnectionsChanged = { [weak self] in
            Task { @MainActor in self?.refreshConnected() }
        }
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
            sharedCount: try Queries.mcpSharedCount(db))
    }

    nonisolated static func liveGrantCount(_ db: Database, clientID: String) throws -> Int {
        try Queries.mcpGrants(db, clientID: clientID).map(\.ruleGrant).filter(\.isLive).count
    }
}
