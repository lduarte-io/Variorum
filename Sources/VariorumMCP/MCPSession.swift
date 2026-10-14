import Foundation
import MCP
import VariorumCore
import VariorumMCPSocket

/// **ONE MCP SESSION = ONE CONNECTION** (13n-b U1, A-3). Its own SDK `Server`
/// over its own socket; the client is whatever `clientInfo.name` its
/// `initialize` declared (A-4 — the ruled honest boundary: a grant gates the
/// DOOR, never a process). First contact records a PENDING connection request
/// with no access; every later call reads the client's standing fresh.
///
/// **VX-168 (K2, R-VX168-1): the name must come with its SETUP KEY.** Before
/// the SDK sees a byte, the session reads the connection's opening
/// (`MCPHandshake` — the shim's preamble line, then the `initialize` frame;
/// VX-180: past any pre-initialize request or notification, which the
/// handshake's bounded window answers or skips — a request never reaches the
/// SDK, and the frame the session decides on is still the `initialize`)
/// and admits or refuses it ONCE, through `Operations.admitMCPConnection`
/// (the pure `MCPSetupKeyRule`): a refusal answers the frame with one
/// sentence and ends the connection; an admission replays the frame into the
/// transport and serves exactly as before.
final class MCPSession: @unchecked Sendable {
    let id = UUID()
    let fd: Int32
    private let server: Server
    private let tools: MCPReadTools
    private let writes: MCPWriteTools
    private let shows: MCPShowTool
    private let database: AppDatabase
    private let operations: Operations
    private let lock = NSLock()
    private var name: String?

    /// The client's self-declared name, once `initialize` has run.
    var clientName: String? { lock.withLock { name } }

    /// **THE AI'S ADVICE** — what the server says about itself at `initialize`.
    /// Every client reads it before it holds a single grant (the honest frame
    /// for a client that sees no tools yet), so it is where a user's AI learns
    /// how the door works (13n-c U5, D-2 — her kickoff: "notes / documentation
    /// for the user need to be made clear (especially since that's what a
    /// user's AI might need as advice too)"). The SAME FACTS as the field
    /// guide's MCP chapter, terse and imperative for a model.
    ///
    /// Bounded: at most `instructionsBound` characters (a client may put it in
    /// every turn's context). Pinned (`MCPAdviceServerTests`): the bound, every
    /// tool it names declared in `MCPToolCatalog`, the format's markers read
    /// from `VariorumDocument` (never retyped), and its arrival over the wire.
    /// The U1 ladder's F5: "Every refusal says why." is GONE — a fenced or
    /// unshared target answers the one not-shared answer by design (T-2). The
    /// U1 ladder's R2-8: `search` serves standing grants only (P-13nb-U1-2's
    /// spirit — a once grant reads by id). Her sitting (2026-10-11, the U6
    /// addendum): the while-connected duration says its BUILT meaning — the
    /// grant belongs to the client's NAME and ends only when that name's last
    /// open connection closes (`MCPServerHost.ended`) or the server stops
    /// (every session hung up; every start sweeps); a reconnect after the end
    /// finds it gone. Pinned against the mechanics in `MCPAdviceServerTests`.
    /// VX-168 U2: the edit step names choosing and committing takes (VX-174's
    /// merge button, VX-169's commit), and the undo sentence says what is
    /// true of a commit — it stays (append-only, I5; her own commits are
    /// outside structural undo too, and `edit_take`'s brackets stay when its
    /// edit is undone — P-13nb-U3-2). 1,941 of the 2,000 characters after it.
    static let instructions = """
        Variorum is a writing app; this server is the door to its library, on the author's Mac, \
        open only while Variorum runs. A new client is a connection request until the author approves \
        it in Variorum \u{25B8} Settings \u{25B8} MCP. Tools appear only for what they have shared \
        (re-announced when that changes).
        Grants have four rungs, each including those before it: read (read and search), \
        suggest (add takes and comments beside their text, save lenses), \
        write new (new notes, books, chapters, tags, versions), edit (edit, choose and commit takes; \
        divide, merge, move, delete). Each names a note, a book or a wing, for once, until you disconnect, or \
        always; they may also open the whole library to reading (the open book). A once grant is \
        one act: a read grant's first read of a note's text, a higher grant's first write. \
        Until you disconnect lasts while any connection under your client's name stays open, \
        sessions opened later included; it ends when the last one closes or Variorum's server \
        stops, and reconnecting does not restore it.
        search covers standing grants only; read a once grant's note by id.
        A wing grant also reads that wing's gatherings (list_books lists them, kind gathering); \
        none is ever granted alone. move_note_to_wing needs edit on the note and write new on the \
        wing it goes to.
        Ids are live: after any divide or merge, theirs or yours, read again.
        read_note speaks the Variorum document format; when its header starts with \
        \(VariorumDocument.versionToken), a "\(VariorumDocument.blockMarker)" line separates the blocks.
        The daily Journal's entries and anything marked Private are shared one ask at a time; \
        snippets are not reachable at all. Anything you can't reach answers exactly as if it did \
        not exist.
        If a call is refused, don't retry around it: tell the author what you need (Variorum may \
        already have asked them).
        Never call show_in_app unless the author asks you to show them something.
        Every change you make is one undo for the author, named after you; commits stay.
        """

    /// The advice's length bound (characters) — stated and pinned. 13n-c: her
    /// ruling (P-13nc-U5-5's bound half, 2026-10-11 — "yeah let's do 2,000
    /// because then we'll have a bit of wiggle room for future updates as
    /// well"): 1,500 → 2,000.
    static let instructionsBound = 2_000

    init(
        fd: Int32, database: AppDatabase, operations: Operations, version: String,
        executor: any MCPWriteExecutor, hooks: MCPHostHooks
    ) {
        self.fd = fd
        self.database = database
        self.operations = operations
        var reads = MCPReadTools(database: database, operations: operations)
        reads.hooks = hooks
        self.tools = reads
        var writes = MCPWriteTools(database: database, grants: operations, executor: executor)
        writes.hooks = hooks
        self.writes = writes
        var shows = MCPShowTool(database: database, operations: operations)
        shows.hooks = hooks
        self.shows = shows
        self.server = Server(
            name: VariorumMCP.serverName, version: version, title: "Variorum",
            instructions: Self.instructions,
            capabilities: .init(tools: .init(listChanged: true)))
    }

    /// Serve until the connection closes — after the handshake admits it.
    func run() async {
        let opening: MCPHandshake.Opening
        switch await MCPHandshake.openingOutcome(fd: fd) {
        case .opened(let opened): opening = opened
        case .ended: return
        case .overLimit:
            // VX-184 U1 (the record's "Over-cap answers"): a line past the
            // opening's cap is ANSWERED — one error on `id: null`, the same
            // for every connection (nothing was decided) — then the host
            // closes. No admission runs: no client, no key, nothing logged.
            _ = MCPSocketTransport.writeAll(fd, MCPHandshake.overLimitResponse)
            return
        }
        let declared = MCPHandshake.initialize(opening.firstFrame)
        // Fail CLOSED: a store that cannot answer admits nobody — and says
        // THE STORE failed, never the key (ladder R1, F-1: the key advice
        // would send a correctly keyed client to rotate a good key for
        // nothing). Nothing is logged for this arm — the store it would log
        // to is the one that threw.
        let admission: Operations.MCPConnectionAdmission
        do {
            admission = try operations.admitMCPConnection(
                name: declared?.name ?? "", version: declared?.version, presentedKey: opening.presentedKey)
        } catch {
            _ = MCPSocketTransport.writeAll(
                fd,
                MCPShim.refusalResponse(
                    toFirstLine: opening.firstFrame, message: MCPHandshake.storeErrorRefusal))
            return
        }
        guard admission.decision.admits, let admitted = admission.client?.name else {
            // VX-198: a replaced key hears its own sentence; every other
            // refusal the one.
            let reason: MCPSetupKeyRule.Refusal? =
                if case .refuse(let reason) = admission.decision { reason } else { nil }
            _ = MCPSocketTransport.writeAll(
                fd, MCPHandshake.refusalResponse(toFirstFrame: opening.firstFrame, reason: reason))
            return
        }
        let transport = MCPSocketTransport(fd: fd, replay: [opening.firstFrame])
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
            // U2: the write rungs run on the session's executor (AF-8);
            // the reads stay where U1 built them.
            // U4: show_in_app awaits the app's delivery (AF-11 F-3).
            let outcome = MCPWriteTools.handledToolNames.contains(params.name)
                ? await self.writes.call(params.name, arguments: params.arguments, clientName: name)
                : MCPShowTool.handledToolNames.contains(params.name)
                    ? await self.shows.call(params.name, arguments: params.arguments, clientName: name)
                    : self.tools.call(params.name, arguments: params.arguments, clientName: name)
            return .init(
                content: [.text(text: outcome.text, annotations: nil, _meta: nil)], isError: outcome.isError)
        }
        do {
            try await server.start(transport: transport) { [weak self] info, _ in
                guard let self else { return }
                // The SDK reads the SAME replayed frame the handshake decided
                // on; a name that differs (it cannot, short of two JSON
                // readers disagreeing) is refused, never served.
                guard info.name.trimmingCharacters(in: .whitespacesAndNewlines) == admitted else {
                    throw MCPError.serverError(code: MCPShim.refusalCode, message: MCPHandshake.refusal)
                }
                self.lock.withLock { self.name = admitted }
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

    /// The host's close of this session's descriptor once `run()` has
    /// returned (VX-279's seam — the host's own `close(fd)`, moved here so
    /// the session sees its descriptor's end).
    func closeConnection() {
        close(fd)
    }
}
