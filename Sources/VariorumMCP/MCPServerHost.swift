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

    public init(database: AppDatabase, operations: Operations, directory: URL, version: String) {
        self.database = database
        self.operations = operations
        self.directory = directory
        self.version = version
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

    public func stop() {
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
        for session in live { session.hangUp() }
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

    private func serve(_ fd: Int32) {
        let session = MCPSession(fd: fd, database: database, operations: operations, version: version)
        lock.withLock { sessions[session.id] = session }
        onConnectionsChanged?()
        Task { [weak self] in
            await session.run()
            close(fd)
            self?.ended(session)
        }
    }

    /// A connection closed: if it was its client's LAST, the client's
    /// while-connected grants end with it (R-13n-4).
    private func ended(_ session: MCPSession) {
        let (name, stillConnected): (String?, Bool) = lock.withLock {
            sessions[session.id] = nil
            let name = session.clientName
            return (name, sessions.values.contains { $0.clientName == name && name != nil })
        }
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
    /// and bounded — the pending room and the log are capped).
    static func grantsFingerprint(_ db: Database) throws -> String {
        try String.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT IFNULL(group_concat(id || ':' || state, ','), '') FROM mcp_client WHERE state <> 'pending')
                  || '|' || (SELECT COUNT(*) || ':' || IFNULL(MAX(created_at), '') || ':'
                             || IFNULL(MAX(revoked_at), '') || ':' || IFNULL(MAX(consumed_at), '') FROM mcp_grant)
                  || '|' || (SELECT IFNULL(group_concat(key || value, ','), '') FROM mcp_switch)
                """) ?? ""
    }
}
