import Darwin
import Foundation
import GRDB
import VariorumCore
import VariorumMCPSocket

/// **THE SERVER's LIFECYCLE** (13n-b U1, A-8): the socket listener inside the
/// app. It runs iff the Settings ▸ MCP toggle is ON and a store is open and
/// unlocked — the app's composition starts it at store-open and stops it at
/// store close, lock and quit, and on the toggle. Start sweeps every
/// while-connected grant (no connection survives a stop or a crash), binds
/// `<container>/Data/mcp.sock` (`0600`), and accepts; each connection is its
/// own `MCPSession`. Stop closes the listener, UNLINKS the socket (it dies
/// with the app) and hangs up every session. A session's last connection for
/// a client ending revokes that client's while-connected grants.
///
/// The host owns no text surface and decides nothing: grants are rows the
/// pure rule reads per call. When the grants store changes it re-announces
/// the tool list to every session (a signal; the list is re-derived).
public final class MCPServerHost: @unchecked Sendable {
    public enum State: Equatable, Sendable {
        case stopped
        case running
        case failed(String)
        /// **VX-612 — the listener died while the server ran** (a fatal
        /// `poll`/`accept` failure, or the listener reporting an error): its
        /// socket is closed and removed, so no new client can connect; the
        /// connections already served keep being served until they end. Never
        /// restarted by itself — the door says so and waits for her switch (or
        /// the next unlock), which starts a fresh host.
        case stoppedByItself(String)
    }

    private let database: AppDatabase
    private let operations: Operations
    private let directory: URL
    private let version: String
    /// U2 (AF-8): where the write tools run — the session's runner in the
    /// app, a serial executor over `operations` otherwise.
    private let executor: any MCPWriteExecutor
    private let lock = NSLock()
    private var listenFD: Int32 = -1
    private var wakePipe: (read: Int32, write: Int32) = (-1, -1)
    private var acceptDone: DispatchSemaphore?
    private var sessions: [UUID: MCPSession] = [:]
    private var observation: Task<Void, Never>?
    private var _state: State = .stopped

    /// Called (off the main thread) when a connection opens, names itself or
    /// closes — a SIGNAL for the pane to re-read; it carries no decision.
    public var onConnectionsChanged: (@Sendable () -> Void)?

    /// **VX-612** — called (off the main thread) when the host's state changes
    /// BY ITSELF (the listener died: `.stoppedByItself`) — a SIGNAL for the door
    /// to re-read `state` (P-4: it carries no decision). Her own starts and
    /// stops are the door's acts and never signal here.
    public var onStateChanged: (@Sendable () -> Void)?

    /// U2: the app's seams — refusal words, the just-in-time ask, the write
    /// receipt. Set before `start()`; every session reads them as it opens.
    public var hooks = MCPHostHooks()

    public init(
        database: AppDatabase, operations: Operations, directory: URL, version: String,
        executor: (any MCPWriteExecutor)? = nil
    ) {
        self.database = database
        self.operations = operations
        self.directory = directory
        self.version = version
        self.executor = executor ?? MCPSerialExecutor(operations: operations)
    }

    public var state: State { lock.withLock { _state } }

    /// The self-declared names of the clients connected right now.
    public var connectedClientNames: Set<String> {
        lock.withLock { Set(sessions.values.compactMap(\.clientName)) }
    }

    // MARK: - Start / stop

    public func start() throws {
        lock.lock()
        guard _state != .running else { lock.unlock(); return }
        lock.unlock()
        do {
            try operations.sweepMCPConnectionGrants()
            let fd = try MCPSocketRoad.listen(directory: directory)
            var pipeFDs: [Int32] = [-1, -1]
            guard pipe(&pipeFDs) == 0 else {
                close(fd)
                MCPSocketRoad.unlink(directory: directory)
                throw MCPSocketRoad.ListenError(kind: .failed(step: "pipe", errno: errno))
            }
            let done = DispatchSemaphore(value: 0)
            lock.withLock {
                listenFD = fd
                wakePipe = (pipeFDs[0], pipeFDs[1])
                acceptDone = done
                _state = .running
            }
            let wakeRead = pipeFDs[0]
            let thread = Thread { [weak self] in
                // VX-612: a loop that ends on a FATAL failure says so — the
                // listener closed, the host flipped, the door signalled — where
                // it used to return in silence with the pane saying "running".
                if case .fatal(let reason)? = self?.acceptLoop(listenFD: fd, wakeFD: wakeRead) {
                    self?.listenerDied(fd, reason: reason)
                }
                done.signal()
            }
            thread.name = "variorum.mcp.accept"
            thread.start()
            startObservingGrants()
        } catch {
            lock.withLock { _state = .failed(String(describing: error)) }
            throw error
        }
    }

    /// Stop: close the listener, unlink its socket, hang up every session (`halt`).
    /// **VX-394 (VX-348 U5): `reason` is why** — each connection this stop ends
    /// leaves that end in the activity log (`MCPConnectionEnd`), written as the
    /// session ends (the store is open on the switch's road); on the library's
    /// closing road the door has already said it, before the store closed
    /// (`recordConnectionEnds`), and the line is never said twice.
    public func stop(ending reason: MCPConnectionEnd = .serverOff) {
        halt { $0.markEnding(reason) }
    }

    /// **THE APP QUITS** (VX-394 — VX-548 batch 2b; P-VX394-5, "a QUIT logs
    /// nothing"): the server stops with the process and NO connection's end is
    /// said — each live connection's line is forgone before its hang-up, so
    /// neither its own end nor a late write can say it. Since VX-348's fix leg
    /// a connection writes its own end through its own store, host or no host,
    /// so the quit's old stop ("as the library closes" — the door's `detach()`)
    /// raced the process's exit: "‹client› was disconnected when the library
    /// locked or closed" on some quits, nothing on others. A connection whose
    /// client had already left keeps its own line (it was said first).
    public func stopWithTheProcess() {
        halt { $0.forgoEndLine() }
    }

    /// **The one stop** (`stop` · `stopWithTheProcess`): close the listener,
    /// remove THIS host's socket, then end every connection the accept loop
    /// registered — `ending` says (or forgoes) each one's end before its
    /// hang-up. Two findings of VX-548 batch 2b's stop-road sweep
    /// (`MCPStopRoadsServerTests`), both closed here:
    ///   - **The socket file is removed only by the host that bound it**, and
    ///     while its listener still holds the path — no other host can bind a
    ///     live path (`MCPSocketRoad.listen`'s probe), so the file removed is
    ///     always this host's own. A host that never served (the door's stale
    ///     start after a quick OFF → ON, which found the path served, or one
    ///     stopped before its start ran) used to unlink the SERVING host's file:
    ///     the pane said "running" while every client heard "Variorum must be
    ///     open".
    ///   - **The connections are listed after the accept loop has stopped**, so
    ///     one accepted while the server stops is ended with the rest. It was
    ///     listed before, and a client accepted in between outlived the stop —
    ///     served on with the switch OFF, its end never said.
    private func halt(ending: (MCPSession) -> Void) {
        let (fd, wake, done, watcher): (Int32, (read: Int32, write: Int32), DispatchSemaphore?, Task<Void, Never>?) =
            lock.withLock {
                let snapshot = (listenFD, wakePipe, acceptDone, observation)
                listenFD = -1
                wakePipe = (-1, -1)
                acceptDone = nil
                observation = nil
                _state = .stopped
                return snapshot
            }
        #if DEBUG
        stopWindowProbe?()
        #endif
        watcher?.cancel()
        if wake.write >= 0 {
            var byte: UInt8 = 1
            _ = write(wake.write, &byte, 1)
        }
        _ = done?.wait(timeout: .now() + 2)
        if fd >= 0 {
            MCPSocketRoad.unlink(directory: directory)
            close(fd)
        }
        if wake.read >= 0 { close(wake.read) }
        if wake.write >= 0 { close(wake.write) }
        let live = lock.withLock { Array(sessions.values) }
        for session in live {
            ending(session)
            session.hangUp()
        }
    }

    #if DEBUG
    /// TEST-ONLY (VX-548 batch 2b): runs inside a stop, after the listener's
    /// state is taken and BEFORE the accept loop is woken — the window a
    /// client connecting just as the server stops can land in.
    var stopWindowProbe: (() -> Void)?
    #endif

    /// **VX-394 — say every live connection's end NOW, before the store goes**
    /// (the library locking or closing — `MCPConnectionEnd.libraryClosed`): one
    /// activity line per connection that named itself, in ONE write, called by
    /// the app's lock road while the store is still open (the line a session's
    /// own end would write races the store's close). Each line is said once:
    /// the hang-up that follows (`stop(ending:)`) writes nothing more for these
    /// connections. Synchronous — the caller runs it off the main thread (P2).
    public func recordConnectionEnds(_ reason: MCPConnectionEnd) throws {
        let live = lock.withLock { Array(sessions.values) }
        let claimed = live.compactMap { session in session.claimEndLine(reason).map { (session, $0) } }
        guard !claimed.isEmpty else { return }
        do {
            try database.write { db in
                // VX-626: each line stamps its client's last seen, on its clock read.
                for (_, line) in claimed {
                    try operations.recordMCPConnectionEnd(db, clientName: line.clientName, end: line.end)
                }
            }
        } catch {
            for (session, _) in claimed { session.releaseEndLine() }
            throw error
        }
    }

    // MARK: - Accept

    /// How the accept loop ended: woken by a stop, or a FATAL failure (VX-612).
    enum AcceptLoopExit: Equatable {
        case woken
        case fatal(String)
    }

    /// **VX-612 — THE ACCEPT LOOP's failures, classified** (the VX-548 batch 2b
    /// trace, M1: the loop returned on EMFILE / ENFILE / ENOMEM / ENOBUFS, poll's
    /// EAGAIN or a listener error, and nothing told the host or the door — the
    /// pane said "running" while no new client was ever served). Pure; pinned.
    enum AcceptStep: String, Sendable { case poll, accept }
    enum AcceptFailure: Equatable, Sendable {
        /// Interrupted, or a connection that died before it was accepted: try
        /// again at once (the loop's old continue).
        case again
        /// A resource the process will get back (descriptors, memory, buffers):
        /// pause — bounded backoff, `pause(afterRetries:)` — and try again.
        case retry
        /// The listener itself is broken: the loop ends and says so.
        case fatal
    }

    static func classify(_ step: AcceptStep, errno code: Int32) -> AcceptFailure {
        switch (step, code) {
        case (_, EINTR): .again
        case (.accept, ECONNABORTED): .again
        case (.poll, EAGAIN), (.poll, ENOMEM): .retry
        case (.accept, EMFILE), (.accept, ENFILE), (.accept, ENOMEM), (.accept, ENOBUFS), (.accept, EAGAIN): .retry
        default: .fatal
        }
    }

    /// The pause before the next try, in milliseconds: 10 ms doubling to a
    /// one-second cap — bounded, and woken at once by a stop. The tries
    /// themselves never run out (a transient condition passes when the process
    /// gets its descriptors or memory back); a success resets the count.
    static func pause(afterRetries retries: Int) -> Int32 {
        Int32(min(10 << min(retries, 7), Int(pauseCap)))
    }
    static let pauseCap: Int32 = 1_000

    /// The words a fatal exit leaves on the host's state (the pane shows them).
    static func reason(_ step: AcceptStep, errno code: Int32) -> String {
        "\(step.rawValue): \(String(cString: strerror(code)))"
    }

    #if DEBUG
    /// TEST-ONLY (VX-612): a fault for the loop's next `poll` or `accept` —
    /// return an errno and that call fails with it instead of running; nil runs
    /// the real call. Read once per call, on the accept thread.
    var acceptLoopFault: (@Sendable (AcceptStep) -> Int32?)?
    #endif

    private func faulted(_ step: AcceptStep) -> Int32? {
        #if DEBUG
        return acceptLoopFault?(step)
        #else
        return nil
        #endif
    }

    private func acceptLoop(listenFD: Int32, wakeFD: Int32) -> AcceptLoopExit {
        var retries = 0
        /// A transient failure: pause (woken at once by a stop), then try again.
        func pausedThroughAStop() -> Bool {
            var wake = [pollfd(fd: wakeFD, events: Int16(POLLIN), revents: 0)]
            let woken = poll(&wake, 1, Self.pause(afterRetries: retries)) > 0 && wake[0].revents != 0
            retries += 1
            return woken
        }
        while true {
            var fds = [pollfd(fd: listenFD, events: Int16(POLLIN), revents: 0),
                       pollfd(fd: wakeFD, events: Int16(POLLIN), revents: 0)]
            let pollFault = faulted(.poll)
            let ready = pollFault == nil ? poll(&fds, 2, -1) : -1
            if ready < 0 {
                let code = pollFault ?? errno
                switch Self.classify(.poll, errno: code) {
                case .again: continue
                case .retry:
                    if pausedThroughAStop() { return .woken }
                    continue
                case .fatal: return .fatal(Self.reason(.poll, errno: code))
                }
            }
            if fds[1].revents != 0 { return .woken }
            guard fds[0].revents & Int16(POLLIN) != 0 else {
                // POLLERR / POLLHUP / POLLNVAL on the listener: it is broken.
                if fds[0].revents != 0 { return .fatal("the listener reported an error (\(fds[0].revents))") }
                continue
            }
            let acceptFault = faulted(.accept)
            let connection = acceptFault == nil ? accept(listenFD, nil, nil) : -1
            guard connection >= 0 else {
                let code = acceptFault ?? errno
                switch Self.classify(.accept, errno: code) {
                case .again: continue
                case .retry:
                    if pausedThroughAStop() { return .woken }
                    continue
                case .fatal: return .fatal(Self.reason(.accept, errno: code))
                }
            }
            retries = 0
            MCPSocketRoad.suppressSIGPIPE(connection)
            _ = fcntl(connection, F_SETFD, FD_CLOEXEC)
            serve(connection)
        }
    }

    /// **VX-612 — the listener died: say so, honestly.** The loop has ended on a
    /// fatal failure. Unless a stop has already taken the listener (then the
    /// stop is the one ending it, and removes it), the host closes its listener
    /// and removes its OWN socket — while the listener still holds the path, so
    /// the file removed is this host's (`halt`'s rule) — flips to
    /// `.stoppedByItself` and signals the door. Sessions already served are
    /// left serving (their own descriptors are healthy); a later stop ends them.
    private func listenerDied(_ fd: Int32, reason: String) {
        let owned: Bool = lock.withLock {
            guard listenFD == fd, _state == .running else { return false }
            listenFD = -1
            _state = .stoppedByItself(reason)
            return true
        }
        guard owned else { return }
        MCPSocketRoad.unlink(directory: directory)
        close(fd)
        onStateChanged?()
    }

    /// Round 1 F7 — the session ceiling: each session costs a reader thread,
    /// so live sessions are capped; without one, a client stuck in a
    /// reconnect loop grows the app a thread per connection until the APP
    /// dies. Claude Code uses one or two; sixteen is generous.
    static let sessionCap = 16

    static let overCapMessage =
        "Variorum's MCP server is already serving its maximum of \(sessionCap) connections. "
        + "Close another MCP client, then reconnect."

    private func serve(_ fd: Int32) {
        let overCap: Bool = lock.withLock {
            guard sessions.count < Self.sessionCap else { return true }
            return false
        }
        guard !overCap else {
            refuseOverCap(fd)
            return
        }
        // VX-605: the connection is heard twice on its way in — as it
        // registers (no name yet) and as it names itself at `initialize` (the
        // session's `onNamed`, this same road). Weak: a host already let go of
        // (the door's stops drop it at once) signals no one.
        let session = MCPSession(
            fd: fd, database: database, operations: operations, version: version,
            executor: executor, hooks: hooks,
            onNamed: { [weak self] in self?.onConnectionsChanged?() })
        lock.withLock { sessions[session.id] = session }
        onConnectionsChanged?()
        Task { [weak self] in
            await session.run()
            // VX-279: the host lets go of the session BEFORE its number is
            // freed (`ended` closes it after deregistering), so a stop that
            // snapshots the sessions afterwards never sees it.
            // VX-394's fix leg: a host already let go of (the door's stop drops
            // it at once) still has its session's end said — by the session.
            if let self {
                self.ended(session)
            } else {
                session.closeConnection()
                session.writeEndLine()
            }
        }
    }

    /// Past the cap: answer the connection's FIRST request with one honest
    /// JSON-RPC error — its id echoed, the shim's refusal shape — then close
    /// (a bare close would leave the client saying only "failed"; P-2's
    /// honesty on the wire). A short-lived helper thread reads that first
    /// line, so a client can never stall the accept loop; every read it
    /// makes runs under a 2 s receive timeout (`SO_RCVTIMEO`, per read — so
    /// a silent client holds the thread ~2 s, while a peer that keeps
    /// dripping bytes can hold it longer, bounded by `MCPHandshake`'s
    /// `lineLimit` and window; ladder R1, NIT 3).
    /// VX-168: the opening read is the handshake's — past a setup key's
    /// preamble to the `initialize` frame — so the refusal still answers the
    /// request by its id (a keyed shim's first line is the preamble).
    /// VX-180: the same read answers a pre-initialize probe on its way (the
    /// window's answers, before each next read), so the cap's sentence lands
    /// on the client's `initialize` — the request it reports — never on a
    /// probe. The window is bounded (`MCPHandshake.preInitializeLimit`) and
    /// every read in it still runs under the receive timeout.
    private func refuseOverCap(_ fd: Int32) {
        let thread = Thread {
            var timeout = timeval(tv_sec: 2, tv_usec: 0)
            _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            let frame = MCPHandshake.readOpening(fd: fd)?.firstFrame ?? Data()
            _ = MCPSocketTransport.writeAll(
                fd, MCPShim.refusalResponse(toFirstLine: frame, message: Self.overCapMessage))
            close(fd)
        }
        thread.name = "variorum.mcp.overcap"
        thread.start()
    }

    /// A connection closed: if it was its client's LAST, the client's
    /// while-connected grants end with it (R-13n-4).
    ///
    /// **VX-279 — deregister, THEN close** (VX-184's ladder, round 2): the
    /// session leaves `sessions` under the host lock first, and only then is
    /// its descriptor closed. Until this fix the descriptor was closed while
    /// the session was still registered, so `stop()` could snapshot it and
    /// hang up a number some other socket of the process had just been handed.
    /// (A stop that snapshotted the session BEFORE it left is safe too: its
    /// hang-up is a no-op once the session has closed — `MCPSession`'s one
    /// lock.)
    private func ended(_ session: MCPSession) {
        let (name, stillConnected): (String?, Bool) = lock.withLock {
            sessions[session.id] = nil
            let name = session.clientName
            return (name, sessions.values.contains { $0.clientName == name && name != nil })
        }
        session.closeConnection()
        // VX-394 (VX-348 U5): the connection's end, in the activity log, once
        // — why the host ended it (a stop's reason), else the over-cap answer,
        // else the client's own close. Quiet when the store is already gone
        // (the library's closing road said it first, while it was open).
        session.writeEndLine()
        if let name, !stillConnected,
           let client = try? database.read({ try Queries.mcpClient($0, name: name) }) {
            try? operations.endMCPConnectionGrants(clientID: client.id)
        }
        onConnectionsChanged?()
    }

    // MARK: - The tool list follows the grants

    private func startObservingGrants() {
        let observed = database.observe { db in try MCPServerHost.grantsFingerprint(db) }
        let task = Task { [weak self] in
            var first = true
            do {
                for try await _ in observed {
                    if first { first = false; continue }
                    guard let self else { return }
                    let live = self.lock.withLock { Array(self.sessions.values) }
                    for session in live { await session.announceToolsChanged() }
                    self.onConnectionsChanged?()
                }
            } catch {}
        }
        lock.withLock { observation = task }
    }

    /// Everything the tool list depends on, in one small value: the decided
    /// clients, the grants' stamps, the switches (the grants store is small
    /// and bounded — the pending room and the log are capped). VX-258: and
    /// each decided client's binding — her Allow of a waiting setup changes
    /// it, and the waiting connection is told its tools changed. VX-676: the
    /// show dial's row is NOT among them — the tool list never depends on it
    /// (show_in_app is listed under every dial value), so turning it announces
    /// nothing to a connected client.
    static func grantsFingerprint(_ db: Database) throws -> String {
        try String.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT IFNULL(group_concat(id || ':' || state || ':' || IFNULL(setup_key_hash, ''), ','), '')
                   FROM mcp_client WHERE state <> 'pending')
                  || '|' || (SELECT COUNT(*) || ':' || IFNULL(MAX(created_at), '') || ':'
                             || IFNULL(MAX(revoked_at), '') || ':' || IFNULL(MAX(consumed_at), '') FROM mcp_grant)
                  || '|' || (SELECT IFNULL(group_concat(key || value, ','), '') FROM mcp_switch WHERE key <> ?)
                """, arguments: [Queries.mcpShowDialKey]) ?? ""
    }
}
