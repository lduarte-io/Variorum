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
///
/// **VX-258: a key WAITING for her OK** (an "Any MCP client" copy under a name
/// that carries her approval — `awaitRebind`) is admitted to a connection
/// request's face: no tools, every call the request's sentence, no tool run at
/// all — the two method handlers are the one choke point — until the name's
/// bound key IS its key (her Allow), when it is told its tools changed and is
/// served from then on, no reconnect.
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
    /// VX-258: the hash of the key this connection presented while that key
    /// WAITS for her OK to take the name (`awaitRebind`); nil once she has
    /// allowed it (the name's bound key IS this key) or when it never waited.
    private var awaitingKey: String?

    /// The client's self-declared name, once `initialize` has run — and,
    /// VX-258, only once the connection IS that client: nil while its key
    /// waits for her OK, so a waiting connection never counts as the name's
    /// (the while-connected grants' lifetime, the pane's connected set).
    var clientName: String? { lock.withLock { awaitingKey == nil ? name : nil } }

    /// The name `initialize` declared, waiting or not.
    private var declaredName: String? { lock.withLock { name } }

    // MARK: - How the connection ended (VX-394 — VX-348 U5)

    /// The end the HOST said when it ended the connection (a stop, before its
    /// hang-up); nil while the connection's own end decides.
    private var endReason: MCPConnectionEnd?
    /// This connection's end line is written (or being written) — it is said
    /// once, whichever road says it first.
    private var endSaid = false
    /// The transport ended on a message past its cap.
    private var endedOverLimit = false

    /// The host is ending this connection, for `reason` (a stop): kept unless
    /// an earlier road already said why.
    func markEnding(_ reason: MCPConnectionEnd) {
        lock.withLock { if endReason == nil { endReason = reason } }
    }

    /// **Claim this connection's end line** — once. A connection that never
    /// named itself (refused at the key, never initialized, or still waiting
    /// for her OK — `clientName`'s rule) has no line. `reason` is the caller's
    /// when it ends the connection itself (`MCPServerHost.recordConnectionEnds`
    /// — the library closing); nil asks the connection's own end: what the
    /// host said at its stop, else the over-cap answer, else the client's
    /// close. Returns the client name and the end to log, or nil.
    func claimEndLine(_ reason: MCPConnectionEnd? = nil) -> (clientName: String, end: MCPConnectionEnd)? {
        lock.withLock {
            guard !endSaid, awaitingKey == nil, let name else { return nil }
            endSaid = true
            if let reason, endReason == nil { endReason = reason }
            return (name, endReason ?? (endedOverLimit ? .overLimit : .clientClosed))
        }
    }

    /// A claimed line that could not be written goes back, so the
    /// connection's own end may still say it.
    func releaseEndLine() {
        lock.withLock { endSaid = false }
    }

    /// **Write this connection's own end line** (VX-394's fix leg — the U5
    /// batch's red, live-confirmed): once (`claimEndLine`), through the
    /// session's OWN store and operations — so it lands whether or not the
    /// host that served it is still alive. The app's door stops its host and
    /// drops it in the same breath (`MCPDoor.stopServer`), and a host holds its
    /// sessions' ends only weakly, so a line written through the host was lost
    /// on every stop the door makes (her switch OFF). Quiet when the store is
    /// already gone (the lock road said it first, while it was open). Runs on
    /// the session's own task, never the main thread (P2).
    func writeEndLine() {
        guard let line = claimEndLine() else { return }
        try? database.write { db in
            try operations.recordMCPActivity(
                db, clientName: line.clientName, act: line.end.act, targetKind: nil, targetID: nil,
                targetTitle: nil, allowed: true)
        }
    }

    /// **VX-258 — does this connection still wait for her OK?** True while
    /// its key waits; it flips, once and for good, when the name's bound key
    /// IS this connection's key (her Allow). One indexed read per call.
    private func awaitsHerOK() throws -> Bool {
        guard let key = lock.withLock({ awaitingKey }), let name = declaredName else { return false }
        let bound = try database.read { db in
            try Queries.mcpClient(db, name: name).flatMap { try Queries.mcpSetupKeyHash(db, clientID: $0.id) }
        }
        guard bound == key else { return true }
        lock.withLock { awaitingKey = nil }
        return false
    }

    /// **What a waiting connection hears** (VX-258): exactly what a
    /// connection REQUEST hears — no tools, and every call the pending
    /// sentence (`MCPRefusalCopy.words(.clientPending, …)`, the same for every
    /// target) — so its holder cannot tell a name that carries her approval
    /// from a name never seen. A tool name no catalog knows answers as it
    /// does for anyone ("Unknown tool").
    private static func waitingAnswer(_ tool: String) -> MCPReadTools.Outcome {
        guard MCPToolCatalog.all.contains(where: { $0.tool.name == tool }) else {
            return MCPReadTools.Outcome(text: "Unknown tool: \(tool).", isError: true)
        }
        return MCPReadTools.Outcome(text: MCPRefusalCopy.words(.clientPending, .note), isError: true)
    }

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
    ///
    /// VX-197 (VX-336 U8a — the AI's docs; the bound 2,000 → 3,000 at
    /// R-VX184-3): the tools line says the built listing (`list_my_activity`
    /// is listed on approval alone — P-VX261-2 — so "tools appear only for
    /// what they have shared" was no longer true); the rungs say write new's
    /// end-of-note blocks (`insert_blocks`, P-VX255-1) and edit's reach
    /// (R-VX184-1); paging, the write digests (VX-254, VX-256) and the
    /// lost-answer road (VX-261) are NAMED WITHOUT A NUMBER (a page bound or a
    /// limit lives in `read_note`'s description, where a measured window may
    /// move it); the organization advice (the plan's "U7: the AI's docs" item
    /// 2); the three acts that stay the author's (R-VX184-2); and ONE sentence
    /// linking the public guide at its fixed URL (R-VX184-4 — a build
    /// carrying it ships publicly only after that page is live). Pinned in
    /// `MCPAdviceServerTests`; the count is the pin's to say.
    static let instructions = """
        Variorum is a writing app; this server is the door to its library, on the author's Mac, \
        open only while Variorum runs. A new client is a connection request until the author approves \
        it in Variorum \u{25B8} Settings \u{25B8} MCP. Once approved, list_my_activity is always listed; \
        other tools appear only for what the author has shared (re-announced when that changes).
        Grants have four rungs, each including those before it: read (read and search), \
        suggest (add takes and comments beside their text, save lenses), \
        write new (new notes, books, chapters, tags, versions; blocks added at a note's end), \
        edit (most of what the author can do at the keyboard: edit, choose and commit takes; \
        divide, merge, move, delete; rename, archive). Each names a note, a book or a wing \
        (list_wings lists yours), for once, \
        until you disconnect, or always; they may also open the whole library to reading (the open \
        book). A once grant is one act: a read grant's first read of a note's text, a higher grant's \
        first write. Until you disconnect lasts while any connection under your client's name stays \
        open, sessions opened later included; it ends when the last one closes or Variorum's server \
        stops, and reconnecting does not restore it.
        search covers standing grants only; read a once grant's note by id.
        A wing grant also reads that wing's gatherings (list_books lists them, kind gathering); \
        none is ever granted alone. move_note_to_wing needs edit on the note and write new on the \
        wing it goes to.
        Ids are live: after any divide or merge, theirs or yours, read again.
        read_note speaks the Variorum document format; when its header starts with \
        \(VariorumDocument.versionToken), a "\(VariorumDocument.blockMarker)" line separates the blocks. \
        Read a long note in pages (limit, then cursor); ids_only gives each take's sha256 instead of \
        its text. Many writes answer each take's sha256, to prove your words landed.
        Help the author stay organized: put plans, summaries and research into notes, not just chat; \
        file notes into books and chapters; tag them, and make books that collect by tag rules. Offer \
        a rewrite as a new take beside theirs, not an edit of their words; leave review as comments. \
        For a revision, copy the note with duplicate_note and edit the copy, so Compare lines the two up.
        Three acts are the author's alone: marking something Private, sealing a book (finished, its \
        text frozen) and making a book own its notes. You can't do them, but suggest one when it would \
        help.
        The daily Journal's entries and anything marked Private are shared one ask at a time; \
        snippets are not reachable at all. Anything you can't reach answers exactly as if it did \
        not exist.
        If a call is refused, don't retry around it: tell the author what you need (Variorum may \
        already have asked them). If an answer is lost, list_my_activity shows whether the call landed.
        Never call show_in_app unless the author asks you to show them something.
        Every change you make is one undo for the author, named after you; commits stay.
        The guide to this door: https://stargazing.tech/variorum/mcp
        """

    /// The advice's length bound (characters) — stated and pinned. 13n-c: her
    /// ruling (P-13nc-U5-5's bound half, 2026-10-11 — "yeah let's do 2,000
    /// because then we'll have a bit of wiggle room for future updates as
    /// well"): 1,500 → 2,000. VX-197 (VX-336 U8a): her R-VX184-3, carried from
    /// VX-184's pre-run sitting — 2,000 → 3,000, moved with its pin.
    static let instructionsBound = 3_000

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
        // VX-258: a key waiting for her OK is admitted to a REQUEST's face —
        // no tool runs for it until she allows it (the two handlers below are
        // the one choke point every list and call passes).
        if case .awaitRebind = admission.decision {
            lock.withLock { awaitingKey = opening.presentedKey.map(MCPSetupKeyRule.hash) }
        }
        let transport = MCPSocketTransport(fd: fd, replay: [opening.firstFrame])
        await server.withMethodHandler(ListTools.self) { [weak self] _ in
            guard let self, let name = self.declaredName else { return .init(tools: []) }
            if try self.awaitsHerOK() { return .init(tools: []) }
            let standing = try self.database.read { try MCPGrantAuthority.standing($0, clientName: name) }
            return .init(tools: MCPToolCatalog.listed(for: standing))
        }
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self else { throw MCPError.internalError("The session ended.") }
            guard let name = self.declaredName else {
                return .init(content: [.text(text: "Initialize first.", annotations: nil, _meta: nil)], isError: true)
            }
            if try self.awaitsHerOK() {
                let waiting = Self.waitingAnswer(params.name)
                return .init(content: [.text(text: waiting.text, annotations: nil, _meta: nil)], isError: waiting.isError)
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
        // VX-394: the over-cap end is the transport's to know.
        let overLimit = await transport.endedOverLimit
        lock.withLock { endedOverLimit = overLimit }
        await server.stop()
    }

    /// The client's grants changed: ask it to re-read its tools (a signal —
    /// the list itself is re-derived from the rows on `tools/list`, P-4).
    /// VX-258: a connection whose key still waits for her OK has nothing new
    /// to read; the moment she allows it (the binding is part of the grants
    /// fingerprint), it is told.
    func announceToolsChanged() async {
        guard declaredName != nil, (try? awaitsHerOK()) == false else { return }
        try? await server.notify(ToolListChangedNotification.message())
    }

    /// **The descriptor's end, under ONE lock** (VX-279 — VX-184's ladder,
    /// round 2): a session's number is only ever shut down or closed here,
    /// and once closed it is never touched again. A closed number is free —
    /// POSIX hands it to the next descriptor the PROCESS opens (any thread) —
    /// so a hang-up that arrived after the close would shut THAT socket down.
    private let connectionLock = NSLock()
    private var connectionClosed = false

    /// End the connection (server stop): the reader unblocks, the loop ends.
    /// VX-279: a no-op once the session has closed its descriptor — the
    /// number may already be another socket's.
    func hangUp() {
        connectionLock.withLock {
            guard !connectionClosed else { return }
            _ = shutdown(fd, SHUT_RDWR)
        }
    }

    /// The host's close of this session's descriptor once `run()` has
    /// returned and the host has let go of the session (VX-279): once, under
    /// the same lock as `hangUp()`, so a stop's hang-up can never land on the
    /// number after it was freed.
    func closeConnection() {
        connectionLock.withLock {
            guard !connectionClosed else { return }
            connectionClosed = true
            _ = close(fd)
        }
    }
}
