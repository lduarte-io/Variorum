import Foundation
import MCP
import VariorumCore

/// **ONE MCP SESSION = ONE CONNECTION** (13n-b U1, A-3). Its own SDK `Server`
/// over its own socket; the client is whatever `clientInfo.name` its
/// `initialize` declared (A-4 — the ruled honest boundary: a grant gates the
/// DOOR, never a process). First contact records a PENDING connection request
/// with no access; every later call reads the client's standing fresh.
final class MCPSession: @unchecked Sendable {
    let id = UUID()
    let fd: Int32
    private let server: Server
    private let transport: MCPSocketTransport
    private let tools: MCPReadTools
    private let database: AppDatabase
    private let operations: Operations
    private let lock = NSLock()
    private var name: String?

    /// The client's self-declared name, once `initialize` has run.
    var clientName: String? { lock.withLock { name } }

    /// What the server says about itself at `initialize` (every client reads
    /// it — the honest frame for a client that sees no tools yet).
    static let instructions = """
        Variorum is a writing app; this server is its library's MCP door. A new client is a \
        connection request until the author approves it in Variorum \u{25B8} Settings \u{25B8} MCP, \
        and tools appear only for what she has shared (they are re-announced when that changes). \
        read_note returns the Variorum document format. Every refusal says why.
        """

    init(fd: Int32, database: AppDatabase, operations: Operations, version: String) {
        self.fd = fd
        self.database = database
        self.operations = operations
        self.transport = MCPSocketTransport(fd: fd)
        self.tools = MCPReadTools(database: database, operations: operations)
        self.server = Server(
            name: VariorumMCP.serverName, version: version, title: "Variorum",
            instructions: Self.instructions,
            capabilities: .init(tools: .init(listChanged: true)))
    }

    /// Serve until the connection closes.
    func run() async {
        await server.withMethodHandler(ListTools.self) { [weak self] _ in
            guard let self, let name = self.clientName else { return .init(tools: []) }
            let standing = try self.database.read { try MCPGrantAuthority.standing($0, clientName: name) }
            return .init(tools: MCPToolCatalog.listed(for: standing))
        }
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self else { throw MCPError.internalError("The session ended.") }
            guard let name = self.clientName else {
                return .init(content: [.text(text: "Initialize first.", annotations: nil, _meta: nil)], isError: true)
            }
            let outcome = self.tools.call(params.name, arguments: params.arguments, clientName: name)
            return .init(
                content: [.text(text: outcome.text, annotations: nil, _meta: nil)], isError: outcome.isError)
        }
        do {
            try await server.start(transport: transport) { [weak self] info, _ in
                guard let self else { return }
                let client = try self.operations.recordMCPContact(name: info.name, version: info.version)
                self.lock.withLock { self.name = client.name }
            }
            await server.waitUntilCompleted()
        } catch {
            // A transport that would not start ends the session; the host
            // closes the socket either way.
        }
        await server.stop()
    }

    /// The client's grants changed: ask it to re-read its tools (a signal —
    /// the list itself is re-derived from the rows on `tools/list`, P-4).
    func announceToolsChanged() async {
        guard clientName != nil else { return }
        try? await server.notify(ToolListChangedNotification.message())
    }

    /// End the connection (server stop): the reader unblocks, the loop ends.
    func hangUp() {
        shutdown(fd, SHUT_RDWR)
    }
}
