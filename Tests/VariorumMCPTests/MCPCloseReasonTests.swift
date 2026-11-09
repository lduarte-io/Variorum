import Darwin
import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-762 — B2 PART TWO: the close reason (PROVISIONAL P-771-3; the orchestrator's
// A-771-3; the record `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 4
// RECORD). As a stop ends a connection the app writes ONE close line on it — 0x1E,
// the words, a newline — and the shim keeps that line off the client's stdout and
// says its words on stderr. A-771-3's conditions, each pinned here: (1) the divert
// never blocks or reorders a relayed byte, its buffer is capped, and overflow or a
// torn line falls back to part one's sentence; (2) the client's byte stream is
// byte-identical with and without a close line, a torn line → the generic
// sentence, a close line mid-session diverts without corrupting what follows, and
// a contended write lock skips the line without blocking the stop; (3) the
// Activity side is untouched.

// MARK: - The relay, pure

/// Runs `stream` through the relay in chunks of `size` bytes (0 = whole): the
/// bytes it writes to stdout, and the words it would say.
private func relayed(_ stream: Data, chunk size: Int) -> (stdout: Data, words: String?) {
    var relay = MCPCloseLine.Relay()
    var out = Data()
    let bytes = [UInt8](stream)
    let step = size == 0 ? max(bytes.count, 1) : size
    var start = 0
    while start < bytes.count {
        let end = min(start + step, bytes.count)
        let piece = Array(bytes[start..<end])
        let spans = piece.withUnsafeBufferPointer { relay.take($0) }
        for span in spans { out.append(contentsOf: piece[span]) }
        start = end
    }
    return (out, relay.closingWords)
}

private let chunkSizes = [0, 1, 2, 3, 5, 7, 13, 64, 4096]

/// Frames as the app writes them: JSON lines, some long, some not ASCII.
private let frames: Data = {
    let lines = [
        #"{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-06-18","serverInfo":{"name":"variorum"}}}"#,
        #"{"jsonrpc":"2.0","id":2,"result":{"content":[{"type":"text","text":"o ladrão de raios — “quoted” ✓"}]}}"#,
        #"{"jsonrpc":"2.0","method":"notifications/tools/list_changed"}"#,
        #"{"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":""# + String(repeating: "x", count: 9_000) + #""}]}}"#,
    ]
    return Data(lines.map { $0 + "\n" }.joined().utf8)
}()

private let words = MCPCloseWords.libraryClosed
private var closeLine: Data { MCPCloseLine.line(words)! }

@Suite("VX-762 — B2 part two: the relay keeps the close line off stdout (A-771-3)")
struct MCPCloseLineRelayTests {
    /// **RED ON OLD** (behavioural revert — the record names it): the client's
    /// stdout is BYTE-IDENTICAL with and without a close line, at every chunking;
    /// the close line's words are what the relay would say.
    @Test(arguments: chunkSizes)
    func aCloseLineNeverReachesStdoutAndTheStreamIsByteIdentical(_ size: Int) {
        let without = relayed(frames, chunk: size)
        let with = relayed(frames + closeLine, chunk: size)
        #expect(without.stdout == frames, "every frame relayed verbatim")
        #expect(with.stdout == without.stdout, "byte-identical with the close line")
        #expect(!with.stdout.contains(MCPCloseLine.marker), "no marker byte ever reaches stdout")
        #expect(with.words == words)
        #expect(without.words == nil)
    }

    /// A close line torn at EOF (no newline came) is never said: the generic
    /// sentence stands — and its bytes still never reach stdout.
    @Test(arguments: chunkSizes)
    func aTornCloseLineAtEOFFallsBackToTheGenericSentence(_ size: Int) {
        let torn = frames + closeLine.dropLast(10)
        let out = relayed(torn, chunk: size)
        #expect(out.stdout == frames)
        #expect(out.words == nil)
    }

    /// **RED ON OLD** (the same revert): a close line arriving MID-SESSION is
    /// diverted, and every later frame is relayed whole and in order.
    @Test(arguments: chunkSizes)
    func aCloseLineMidSessionDivertsWithoutCorruptingLaterRelay(_ size: Int) {
        let later = Data(#"{"jsonrpc":"2.0","id":9,"result":{}}"#.utf8) + Data("\n".utf8)
        let out = relayed(frames + closeLine + later, chunk: size)
        #expect(out.stdout == frames + later, "the frames before and after, verbatim, in order")
        #expect(out.words == words, "the latest complete close line's words")
    }

    /// Overflow (A-771-3 (1)): a close line past the cap is diverted whole — never
    /// on stdout — and never said; the generic sentence stands.
    @Test(arguments: chunkSizes)
    func anOverlongCloseLineIsNeverSaidAndNeverRelayed(_ size: Int) {
        var long = Data([MCPCloseLine.marker])
        long.append(Data(String(repeating: "w", count: MCPCloseLine.cap + 1).utf8))
        long.append(UInt8(ascii: "\n"))
        let out = relayed(frames + long, chunk: size)
        #expect(out.stdout == frames)
        #expect(out.words == nil)
    }

    /// Only a LINE START decides: a 0x1E byte inside a line (which no JSON text
    /// can hold — this is the relay's own discipline, not a wire shape) is
    /// relayed as it came; and words that could break a terminal are never said.
    @Test func onlyALineStartDecidesAndUnspeakableWordsFallBack() {
        let inside = Data("abc".utf8) + Data([MCPCloseLine.marker]) + Data("def\n".utf8)
        for size in chunkSizes {
            let out = relayed(inside, chunk: size)
            #expect(out.stdout == inside, "chunk \(size)")
            #expect(out.words == nil)
        }
        let control = Data([MCPCloseLine.marker]) + Data("bell\u{07}\n".utf8)
        #expect(relayed(control, chunk: 0).words == nil)
        #expect(MCPCloseLine.line("") == nil)
        #expect(MCPCloseLine.line("two\nlines") == nil)
        #expect(MCPCloseLine.line(String(repeating: "w", count: MCPCloseLine.cap + 1)) == nil)
        let framed = MCPCloseLine.line(words)
        #expect(framed?.first == MCPCloseLine.marker && framed?.last == UInt8(ascii: "\n"))
    }

    /// The words (PROVISIONAL, her copy pass): one per stop, each one line, each
    /// naming the reconnect road; the two ends that are no stop say nothing.
    @Test func theWordsForEachStop() {
        #expect(MCPCloseWords.words(for: .serverOff) == MCPCloseWords.serverOff)
        #expect(MCPCloseWords.words(for: .libraryClosed) == MCPCloseWords.libraryClosed)
        #expect(MCPCloseWords.words(for: .clientClosed) == nil)
        #expect(MCPCloseWords.words(for: .overLimit) == nil)
        for said in [MCPCloseWords.serverOff, MCPCloseWords.libraryClosed, MCPCloseWords.quit] {
            #expect(MCPCloseLine.line(said) != nil, "\(said) is speakable")
            #expect(said.contains("/mcp"))
        }
    }
}

// MARK: - The server, end to end

private func tempDirectory(_ prefix: String) -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("\(prefix)-\(UUID().uuidString.prefix(8))", isDirectory: true)
}

/// A raw client on `directory`'s socket that names itself (its key's preamble, an
/// `initialize`, the answer read under the harness's receive bound — `HarnessDeadline.seconds`, O-7).
/// VX-850: the read runs off the pool (`HarnessWait`); the task-local bound is
/// read here, before the hop (a plain thread sees none).
private func namedClient(_ directory: URL, key: String, as name: String) async throws -> Int32 {
    let seconds = Int(HarnessDeadline.seconds.rounded(.up))
    return try await HarnessWait.offPoolThrowing {
        try namedClientBlocking(directory, key: key, as: name, receiveSeconds: seconds)
    }
}

private func namedClientBlocking(_ directory: URL, key: String, as name: String, receiveSeconds: Int) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw HarnessFailure("could not connect as \(name)")
    }
    var timeout = timeval(tv_sec: receiveSeconds, tv_usec: 0)
    _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var opening = MCPPreamble.line(key: key)
    let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
    opening.append(Data((initialize + "\n").utf8))
    _ = MCPShim.writeAll(fd, opening)
    guard !MCPShim.readFirstLine(fd, limit: 1 << 20).isEmpty else {
        close(fd)
        throw HarnessFailure("\(name) got no answer to its initialize")
    }
    return fd
}

/// Every byte until EOF (nil on a timeout — the connection still open).
/// VX-850: off the pool.
private func readToEOF(_ fd: Int32) async -> Data? {
    await HarnessWait.offPool {
        var all = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(fd, &buffer, buffer.count)
            if count == 0 { return all }
            if count < 0 {
                if errno == EINTR { continue }
                return nil
            }
            all.append(contentsOf: buffer[0..<count])
        }
    }
}

/// The connection-end rows, oldest first, as (client, act).
private func ends(_ database: AppDatabase) throws -> [(client: String, act: String)] {
    let acts = Set(MCPConnectionEnd.allCases.map(\.act))
    return try database.read { db in try Queries.mcpActivity(db) }
        .reversed()
        .filter { acts.contains($0.act) }
        .map { ($0.clientName, $0.act) }
}

/// The three stops with a reason, as the door runs them.
enum StopWithAReason: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case switchOff, libraryLocks, appQuits
    var testDescription: String { rawValue }

    var words: String {
        switch self {
        case .switchOff: MCPCloseWords.serverOff
        case .libraryLocks: MCPCloseWords.libraryClosed
        case .appQuits: MCPCloseWords.quit
        }
    }

    func stop(_ host: MCPServerHost) throws {
        switch self {
        case .switchOff: host.stop(ending: .serverOff)
        case .libraryLocks:
            try host.recordConnectionEnds(.libraryClosed)
            host.stop(ending: .libraryClosed)
        case .appQuits: host.stopWithTheProcess()
        }
    }
}

@Suite("VX-762 — B2 part two: each stop says why as the connection's last line", .serialized)
struct MCPCloseReasonServerTests {
    /// **RED ON OLD** (behavioural revert): each stop with a reason writes ONE
    /// close line, the connection's last bytes before EOF, carrying its words.
    @Test(arguments: StopWithAReason.allCases)
    func eachStopSaysItsWordsAsTheConnectionsLastLine(_ road: StopWithAReason) async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let fd = try await namedClient(h.directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(fd) }
        try road.stop(h.host)
        let stream = await readToEOF(fd)
        #expect(stream != nil, "\(road): the stop ends the connection")
        let bytes = stream ?? Data()
        let expected = MCPCloseLine.line(road.words)!
        #expect(bytes.suffix(expected.count) == expected, "\(road): the close line is the last thing said")
        let markers = bytes.filter { $0 == MCPCloseLine.marker }.count
        #expect(markers == 1, "\(road): one close line")
    }

    /// A connection still in its handshake (its opening not yet read — no
    /// transport) is told nothing: it has not named itself.
    @Test func aConnectionStillInItsHandshakeIsToldNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        guard case .success(let fd) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        defer { close(fd) }
        var timeout = timeval(tv_sec: Int(HarnessDeadline.seconds.rounded(.up)), tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        let nobodyNamed = h.host.connectedClientNames.isEmpty
        #expect(nobodyNamed, "nothing named itself")
        try await Task.sleep(for: .milliseconds(100))  // the session is reading its opening (VX-850: suspended, not holding a pool thread the session needs)
        h.host.stop(ending: .libraryClosed)
        let bytes = await readToEOF(fd) ?? Data()
        #expect(!bytes.contains(MCPCloseLine.marker), "no close line before a name: \(bytes.count) bytes")
    }

    /// **A-771-3 (2) — the try()-lock skip road:** a frame mid-write holds the
    /// transport's write lock as the server stops; the close line is SKIPPED,
    /// the stop never waits on it, and the connection still ends.
    @Test func aContendedWriteLockSkipsTheLineAndNeverBlocksTheStop() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let fd = try await namedClient(h.directory, key: try h.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(fd) }
        let holder = LockHolder()
        h.host.hangUpProbe = { session in
            guard let lock = session.transportWriteLockForTesting else { return }
            holder.hold(lock)
        }
        let started = Date()
        h.host.stop(ending: .libraryClosed)
        let took = Date().timeIntervalSince(started)
        h.host.hangUpProbe = nil
        #expect(took < 1.0, "the stop never waits on the write lock: \(took) s")
        let held = holder.wasHeld
        #expect(held, "the lock was held as the server stopped")
        let bytes = await readToEOF(fd)
        holder.release()
        #expect(bytes != nil, "the connection still ends")
        #expect(!(bytes ?? Data()).contains(MCPCloseLine.marker), "the line was skipped, never written mid-frame")
    }

    /// **A-771-3 (3) — the Activity side is byte-untouched by this work:** the
    /// four ends' acts keep their shipped values; the quit still writes NO
    /// Activity line though it now says why on the wire; the lock road writes
    /// exactly its one line, once.
    @Test func theActivitySideIsUntouched() async throws {
        #expect(MCPConnectionEnd.allCases.map(\.act)
                == ["disconnect_client", "disconnect_library_closed", "disconnect_server_off", "disconnect_over_limit"])

        let quitting = try ServerHarness()
        defer { quitting.tearDown() }
        let quitFD = try await namedClient(quitting.directory, key: try quitting.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(quitFD) }
        quitting.host.stopWithTheProcess()
        let quitBytes = await readToEOF(quitFD) ?? Data()
        #expect(quitBytes.contains(MCPCloseLine.marker), "the quit now says why on the wire")
        try await Task.sleep(for: .milliseconds(400))
        let quitLogged = try ends(quitting.database)
        #expect(quitLogged.isEmpty, "a quit still logs nothing (P-VX394-5): \(quitLogged)")

        let locking = try ServerHarness()
        defer { locking.tearDown() }
        let lockFD = try await namedClient(locking.directory, key: try locking.setupKey(for: "claude-code"), as: "claude-code")
        defer { close(lockFD) }
        try locking.host.recordConnectionEnds(.libraryClosed)
        locking.host.stop(ending: .libraryClosed)
        _ = await readToEOF(lockFD)
        try await Task.sleep(for: .milliseconds(400))
        let lockLogged = try ends(locking.database)
        #expect(lockLogged.map(\.client) == ["claude-code"]
                && lockLogged.map(\.act) == [MCPConnectionEnd.libraryClosed.act],
                "the lock road's one line, once: \(lockLogged)")
    }
}

/// Holds a lock from ITS OWN thread (an NSLock is unlocked by the thread that
/// locked it), as a frame mid-write would, until released.
private final class LockHolder: @unchecked Sendable {
    private let held = DispatchSemaphore(value: 0)
    private let letGo = DispatchSemaphore(value: 0)
    private let finished = DispatchSemaphore(value: 0)
    private let state = NSLock()
    private var holding = false

    func hold(_ lock: NSLock) {
        let thread = Thread { [self] in
            lock.lock()
            state.withLock { holding = true }
            held.signal()
            _ = letGo.wait(timeout: .now() + 10)
            lock.unlock()
            finished.signal()
        }
        thread.start()
        _ = held.wait(timeout: .now() + 5)
    }

    var wasHeld: Bool { state.withLock { holding } }

    func release() {
        guard wasHeld else { return }
        letGo.signal()
        _ = finished.wait(timeout: .now() + 5)
    }
}

// MARK: - The shim on a real session

@Suite("VX-762 — B2 part two: the shim says the app's words on stderr", .serialized)
struct MCPShimCloseReasonTests {
    /// Pumps a real session through the shim, stops the server as `stop` does,
    /// and returns (stdout bytes after the initialize answer, stderr).
    private func pumped(
        _ h: ServerHarness, stop: (MCPServerHost) throws -> Void
    ) async throws -> (answer: Data, stdout: Data, stderr: String) {
        guard case .success(let socket) = MCPSocketRoad.connect(directory: h.directory) else {
            throw HarnessFailure("could not connect")
        }
        var input: [Int32] = [-1, -1], output: [Int32] = [-1, -1], errors: [Int32] = [-1, -1]
        guard pipe(&input) == 0, pipe(&output) == 0, pipe(&errors) == 0 else { throw HarnessFailure("pipe") }
        let key = try h.setupKey(for: "shim-test")
        let (shimInput, shimOutput, shimErrors) = (input[0], output[1], errors[1])
        let served = DispatchSemaphore(value: 0)
        let upstreamEnded = DispatchSemaphore(value: 0)
        let pump = Thread {
            _ = MCPShim.writeAll(socket, MCPPreamble.line(key: key))
            MCPShim.pump(
                input: shimInput, output: shimOutput, socket: socket, errorOutput: shimErrors,
                onUpstreamEnd: { upstreamEnded.signal() })
            served.signal()
        }
        pump.start()
        let initialize = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"shim-test","version":"1"}}}"#
        _ = MCPShim.writeAll(input[1], Data((initialize + "\n").utf8))
        let clientReads = output[0]
        // VX-850: off the pool — the session answering through the pump needs a pool thread.
        let answer = await HarnessWait.offPool { MCPShim.readFirstLine(clientReads, limit: 1 << 20) }
        try stop(h.host)
        // Bounded waits on the pump's own thread — awaited off the pool (a
        // semaphore can't be waited on from an async context).
        _ = await HarnessWait.offPool { served.wait(timeout: .now() + 10) == .success }
        close(input[1])
        _ = await HarnessWait.offPool { upstreamEnded.wait(timeout: .now() + 10) == .success }
        close(socket)
        close(output[1])
        close(errors[1])
        func drain(_ fd: Int32) -> Data {
            var all = Data()
            var buffer = [UInt8](repeating: 0, count: 4096)
            while true {
                let count = read(fd, &buffer, buffer.count)
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { return all }
                all.append(contentsOf: buffer[0..<count])
            }
        }
        let rest = drain(output[0])
        let said = String(decoding: drain(errors[0]), as: UTF8.self)
        close(output[0])
        close(errors[0])
        close(input[0])
        return (answer, rest, said)
    }

    /// **RED ON OLD** (behavioural revert): the library locks under a live session
    /// pumped by the shim — its stderr is ONE line, the lock road's words; its
    /// stdout carried the answer and nothing of the close line.
    @Test func theLockRoadsWordsReachTheClientsStderr() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let out = try await pumped(h) { host in
            try host.recordConnectionEnds(.libraryClosed)
            host.stop(ending: .libraryClosed)
        }
        #expect(!out.answer.isEmpty, "the session answered through the shim")
        #expect(!out.stdout.contains(MCPCloseLine.marker) && !out.answer.contains(MCPCloseLine.marker))
        #expect(out.stderr == MCPCloseWords.libraryClosed + "\n", "\(out.stderr.debugDescription)")
    }

    /// A-771-3 (2): the contended lock's skip road, seen by the client — no line
    /// came, so the shim says its own generic sentence.
    @Test func aSkippedCloseLineLeavesTheGenericSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let holder = LockHolder()
        h.host.hangUpProbe = { session in
            guard let lock = session.transportWriteLockForTesting else { return }
            holder.hold(lock)
        }
        let out = try await pumped(h) { host in host.stop(ending: .serverOff) }
        h.host.hangUpProbe = nil
        let held = holder.wasHeld
        holder.release()
        #expect(held, "the lock was held as the server stopped")
        #expect(out.stderr == MCPShim.appClosedMessage + "\n", "\(out.stderr.debugDescription)")
    }
}
