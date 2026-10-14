import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-318 — DOES A SESSION'S TRANSPORT READER EVER READ PAST ITS SESSION'S END?
// (VX-246 U1's OWED 3, traced by reading: "`MCPSocketTransport`'s reader THREAD
// may outlive `session.run()` — a reader descheduled between two `read`s could
// issue its next `read` after the host has closed and the process reused the
// number, reading another socket's bytes." The run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1b piece 2.)
//
// THE PRODUCTION ROAD, with the reuse made DETERMINISTIC: a real `MCPSession`
// over one end of a socketpair, admitted by a real setup key, its transport's
// reader running; a burst of frames in flight (so the reader is mid-loop, not
// parked in a `read`) when the session ends — by each road a session ends in
// production: the client hangs up (EOF), the server stops (`hangUp()`), a
// message runs past the cap (the reader's over-limit arm). The moment `run()`
// returns, the host's own close (`closeConnection()`), then the number is
// handed to a FRESH socket at once (`dup2` — the reuse POSIX makes likely,
// made certain), and a byte is written to that socket. If any reader read
// past the session's end, the byte is gone.
//
// THE TRACE says it cannot be (the record's piece 2): the host closes only
// after `run()` returns, which waits for the SDK's message loop to end, which
// ends only when the transport's stream finishes — and nothing finishes that
// stream before the reader's own last `read` returned ≤ 0 (or over the cap):
// `disconnect()` runs only from `server.stop()`, which `run()` calls after the
// loop has ended, and the loop's task is never cancelled sooner. These pins
// read that ordering on the production road; GREEN on the tree they were
// written against means the row is HOLLOW (recorded, not fixed).

private let initialize =
    #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"vx318-probe","version":"1"}}}"#
private let initialized = #"{"jsonrpc":"2.0","method":"notifications/initialized"}"#

private func listTools(_ id: Int) -> String { #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/list"}"# }

@Suite("VX-318 — a session's reader never reads past the session's end", .serialized)
struct MCPReaderAfterCloseTests {
    enum Ending: String, CaseIterable, Sendable { case clientHangsUp, serverStops, overTheCap }

    private struct World {
        let database: AppDatabase
        let operations: Operations
    }

    private func world() throws -> World {
        let database = try AppDatabase.inMemory()
        let operations = withDependencies {
            $0.database = database
            $0.date = DateGenerator { Date() }
            $0.uuid = UUIDGenerator { UUID() }
        } operation: { Operations() }
        return World(database: database, operations: operations)
    }

    private func prepare(_ fd: Int32, receiveTimeout seconds: Int) {
        var one: Int32 = 1
        _ = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout<Int32>.size))
        var timeout = timeval(tv_sec: seconds, tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    }

    /// A bounded wait (synchronous — never on the awaiting task itself).
    private func waitBounded(_ semaphore: DispatchSemaphore, seconds: Int) {
        _ = semaphore.wait(timeout: .now() + .seconds(seconds))
    }

    /// One line from `fd` (bounded by its receive timeout); nil on EOF/timeout.
    private func readLine(_ fd: Int32) -> Data? {
        var line = Data()
        var byte: UInt8 = 0
        while true {
            let n = Darwin.read(fd, &byte, 1)
            guard n > 0 else { return line.isEmpty ? nil : line }
            if byte == UInt8(ascii: "\n") { return line }
            line.append(byte)
        }
    }

    /// One session's life, ended by `ending`; then the host's close and the
    /// number reused at once. Returns whether the fresh socket still holds
    /// its byte (nil when a premise failed — said by the caller).
    private func oneSession(_ w: World, ending: Ending, round: Int) async throws -> Bool? {
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        let number = pair[0]
        let client = pair[1]
        prepare(number, receiveTimeout: 0)
        prepare(client, receiveTimeout: 5)
        let key = try w.operations.mintMCPSetupKey(copiedFor: "vx318-probe")
        let session = MCPSession(
            fd: number, database: w.database, operations: w.operations, version: "test",
            executor: MCPSerialExecutor(operations: w.operations), hooks: MCPHostHooks())
        let running = Task.detached { await session.run() }

        // The opening; the initialize answered ⇒ the transport's reader runs.
        _ = MCPShim.writeAll(client, MCPPreamble.line(key: key) + Data((initialize + "\n" + initialized + "\n").utf8))
        guard let opened = readLine(client), String(decoding: opened, as: UTF8.self).contains("\"id\":1") else {
            close(client)
            session.hangUp()
            await running.value
            session.closeConnection()
            return nil
        }
        // Drain every answer on its own thread (the burst's answers must never
        // fill the client's buffer and stall the session's writes).
        let drained = DispatchSemaphore(value: 0)
        Thread { while readLine(client) != nil {}; drained.signal() }.start()

        // A burst in flight, so the reader is mid-loop when the session ends.
        var burst = Data()
        for id in 0..<(8 + round % 24) { burst += Data((listTools(100 + id) + "\n").utf8) }
        _ = MCPShim.writeAll(client, burst)
        switch ending {
        case .clientHangsUp:
            _ = shutdown(client, SHUT_WR)
        case .serverStops:
            session.hangUp()
        case .overTheCap:
            let over = Data(repeating: UInt8(ascii: "a"), count: MCPSocketTransport.lineCap + 1) + Data("\n".utf8)
            Thread { _ = MCPShim.writeAll(client, over) }.start()
        }
        await running.value

        // The host's road: the session's close — then the number REUSED at
        // once by a fresh socket (dup2: the reuse made certain).
        session.closeConnection()
        var fresh: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &fresh) == 0)
        try #require(dup2(fresh[0], number) == number, "the closed session's number now names a fresh socket")
        prepare(number, receiveTimeout: 1)
        let byte = Data("X".utf8)
        _ = MCPShim.writeAll(fresh[1], byte)
        // Any reader still alive gets its chance at the byte.
        try await Task.sleep(for: .milliseconds(20))
        var got: UInt8 = 0
        let n = Darwin.read(number, &got, 1)
        close(number)
        close(fresh[0])
        close(fresh[1])
        close(client)
        waitBounded(drained, seconds: 5)
        return n == 1 && got == UInt8(ascii: "X")
    }

    /// Every ending road, many times: the fresh socket always keeps its byte.
    @Test(arguments: [Ending.clientHangsUp, .serverStops])
    func aReusedNumberKeepsItsBytesAfterTheSessionEnds(_ ending: Ending) async throws {
        let w = try world()
        var kept = 0
        var premiseFailures = 0
        let rounds = 150
        for round in 0..<rounds {
            switch try await oneSession(w, ending: ending, round: round) {
            case true?: kept += 1
            case false?: break
            case nil: premiseFailures += 1
            }
        }
        #expect(premiseFailures == 0, "premise: every session's initialize was answered (\(premiseFailures) not)")
        #expect(kept == rounds - premiseFailures,
                "\(ending): a reader read a fresh socket's byte after its session ended in \(rounds - premiseFailures - kept) of \(rounds) rounds")
    }

    /// The over-cap road (the one where the reader ends WITHOUT an EOF) — a
    /// few rounds (each moves 16 MiB).
    @Test func aReusedNumberKeepsItsBytesAfterAnOverTheCapEnding() async throws {
        let w = try world()
        for round in 0..<4 {
            let kept = try await oneSession(w, ending: .overTheCap, round: round)
            #expect(kept == true, "round \(round): \(String(describing: kept))")
        }
    }
}
