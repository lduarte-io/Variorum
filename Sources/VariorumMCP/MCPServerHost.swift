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
                self?.acceptLoop(listenFD: fd, wakeFD: wakeRead)
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

    /// Stop: close the listener, unlink the socket, hang up every session.
    /// **VX-394 (VX-348 U5): `reason` is why** — each connection this stop ends
    /// leaves that end in the activity log (`MCPConnectionEnd`), written as the
    /// session ends (the store is open on the switch's road); on the library's
    /// closing road the door has already said it, before the store closed
    /// (`recordConnectionEnds`), and the line is never said twice.
    public func stop(ending reason: MCPConnectionEnd = .serverOff) {
        let (fd, wake, done, live, watcher): (Int32, (read: Int32, write: Int32), DispatchSemaphore?, [MCPSession], Task<Void, Never>?) =
            lock.withLock {
                let snapshot = (listenFD, wakePipe, acceptDone, Array(sessions.values), observation)
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
        if fd >= 0 { close(fd) }
        if wake.read >= 0 { close(wake.read) }
        if wake.write >= 0 { close(wake.write) }
        MCPSocketRoad.unlink(directory: directory)
        for session in live {
            session.markEnding(reason)
            session.hangUp()
        }
    }

    /// **THE APP QUITS** (VX-394 — VX-548 batch 2b): the server stops with the
    /// process. SEAM ONLY in this commit — the body is the road the quit took
    /// until now (the door's `detach()`: a stop "as the library closes"), so
    /// the batch's pins read the old behaviour through it.
    public func stopWithTheProcess() {
        stop(ending: .libraryClosed)
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
                for (_, line) in claimed {
                    try operations.recordMCPActivity(
                        db, clientName: line.clientName, act: line.end.act, targetKind: nil, targetID: nil,
                        targetTitle: nil, allowed: true)
                }
            }
        } catch {
            for (session, _) in claimed { session.releaseEndLine() }
            throw error
        }
    }

    // MARK: - Accept

    private func acceptLoop(listenFD: Int32, wakeFD: Int32) {
        while true {
            var fds = [pollfd(fd: listenFD, events: Int16(POLLIN), revents: 0),
                       pollfd(fd: wakeFD, events: Int16(POLLIN), revents: 0)]
            let ready = poll(&fds, 2, -1)
            if ready < 0 {
                if errno == EINTR { continue }
                return
            }
            if fds[1].revents != 0 { return }
            guard fds[0].revents & Int16(POLLIN) != 0 else {
                if fds[0].revents != 0 { return }
                continue
            }
            let connection = accept(listenFD, nil, nil)
            guard connection >= 0 else {
                if errno == EINTR || errno == ECONNABORTED { continue }
                return
            }
            MCPSocketRoad.suppressSIGPIPE(connection)
            _ = fcntl(connection, F_SETFD, FD_CLOEXEC)
            serve(connection)
        }
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
        let session = MCPSession(
            fd: fd, database: database, operations: operations, version: version,
            executor: executor, hooks: hooks)
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
    /// it, and the waiting connection is told its tools changed.
    static func grantsFingerprint(_ db: Database) throws -> String {
        try String.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT IFNULL(group_concat(id || ':' || state || ':' || IFNULL(setup_key_hash, ''), ','), '')
                   FROM mcp_client WHERE state <> 'pending')
                  || '|' || (SELECT COUNT(*) || ':' || IFNULL(MAX(created_at), '') || ':'
                             || IFNULL(MAX(revoked_at), '') || ':' || IFNULL(MAX(consumed_at), '') FROM mcp_grant)
                  || '|' || (SELECT IFNULL(group_concat(key || value, ','), '') FROM mcp_switch)
                """) ?? ""
    }
}
