import Darwin
import Foundation

@testable import VariorumMCPSocket

// VX-850 (the VX-926 run, U1 — the record `notes/plans/fixes/vx-926-test-flakes.md`,
// "## U1 record") — THE HARNESS's ONE WAIT.
//
// The server under test runs on this test process's cooperative pool, exactly
// `activeProcessorCount` threads wide: `MCPServerHost.serve` starts each connection
// as a task, the handshake resumes onto the pool, the admission is a store write on a
// pool thread, and the SDK's loops are pool tasks. The socket suites used to wait for
// that server's answer by BLOCKING a pool thread — a `read()` under a receive timeout
// inside an async test body — so once their waits (plus any other busy test bodies)
// covered the pool, no server could take a thread to answer any of them until the
// timeouts expired: a circular wait, red as "got no answer to its initialize", a nil
// read, a premise miss (Phase 1, C2–C4; pinned by `MCPHarnessPoolTests`).
//
// Every wait whose answer depends on the server under test goes through here, on
// TWO rules:
//   1. OFF THE POOL — the blocking call runs on ITS OWN THREAD and the test task
//      awaits it, holding no pool thread meanwhile: the door's own idiom
//      (`MCPHandshake.openingOutcome`: "blocking reads … never hold a
//      cooperative-pool thread").
//   2. THE HARNESS's ONE BOUND — the wait is bounded by `HarnessDeadline.seconds`
//      (`receiveSeconds`), the limit every SDK-driven act already carries: O-7's
//      rule (the VX-771 run, which gave four raw helpers this bound and "took them
//      out of the family"), carried to every raw wait. A bound exists so a server
//      that never answers fails a test NAMED instead of hanging the run (VX-132);
//      an in-process server under a congested pool answers seconds late (8.9 s seen
//      in a full MCP-target run), so a hand-picked 5 s bound read the pool's queue,
//      never the server.
//
// Read a task-local (`HarnessDeadline.seconds`) BEFORE the hop: a plain thread sees
// none.
enum HarnessWait {
    /// Run `body` — a blocking wait bounded by its own descriptor's or semaphore's
    /// timeout — on a dedicated thread, and await its result.
    static func offPool<T: Sendable>(_ body: @escaping @Sendable () -> T) async -> T {
        await withCheckedContinuation { continuation in
            let thread = Thread { continuation.resume(returning: body()) }
            thread.name = "variorum.mcp.harness-wait"
            thread.start()
        }
    }

    /// The same for a wait that throws (a raw client's connect-and-name helper).
    static func offPoolThrowing<T: Sendable>(_ body: @escaping @Sendable () throws -> T) async throws -> T {
        try await offPool { Result { try body() } }.get()
    }

    /// The harness's one bound for a raw wait, in whole seconds for `SO_RCVTIMEO`
    /// (rule 2) — read in the TASK, before any hop.
    static var receiveSeconds: Int { Int(HarnessDeadline.seconds.rounded(.up)) }

    /// Bound `fd`'s reads by `seconds` (`SO_RCVTIMEO`).
    static func bound(_ fd: Int32, seconds: Int) {
        var timeout = timeval(tv_sec: seconds, tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    }
}

// MARK: - The raw clients, one copy (VX-850: these were three files' private copies,
// one of them still on a hand-picked 5 s bound)

/// A raw client on `directory`'s socket that NAMES ITSELF: its setup key's
/// preamble, then an `initialize` as `name`, the server's answer read under the
/// harness's bound — off the pool. The caller closes the descriptor.
func namedClient(_ directory: URL, key: String, as name: String) async throws -> Int32 {
    let seconds = HarnessWait.receiveSeconds
    return try await HarnessWait.offPoolThrowing {
        try namedClientBlocking(directory, key: key, as: name, receiveSeconds: seconds)
    }
}

/// The same, BLOCKING — only for a caller already off the pool (a probe the host
/// runs inside a stop the test made on its own thread).
func namedClientBlocking(_ directory: URL, key: String, as name: String, receiveSeconds: Int) throws -> Int32 {
    guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
        throw HarnessFailure("could not connect as \(name)")
    }
    HarnessWait.bound(fd, seconds: receiveSeconds)
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

/// The server hung this connection up: reading reaches EOF (anything the server
/// still had to say is read past) within the descriptor's bound — false on a
/// timeout, i.e. a connection still open. Off the pool.
func reachesEOF(_ fd: Int32) async -> Bool {
    await HarnessWait.offPool {
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(fd, &buffer, buffer.count)
            if count == 0 { return true }
            if count < 0 { return false }
        }
    }
}

/// Every byte until EOF (nil on a timeout — the connection still open). Off the pool.
func everyByteUntilEOF(_ fd: Int32) async -> Data? {
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
