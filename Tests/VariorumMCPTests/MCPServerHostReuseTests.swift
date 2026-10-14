import Darwin
import Dependencies
import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-279 — A STOPPED HOST NEVER SHUTS DOWN A SOCKET THAT REUSED A SESSION'S
// NUMBER (VX-184's ladder, round 2; the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-279").
//
// `MCPServerHost.serve` closed a session's descriptor while the session was
// still registered, and `stop()` hangs up every registered session with a bare
// `shutdown(fd, SHUT_RDWR)` — so a session that ended inside the stop's window
// had freed its number, POSIX handed that number to the next descriptor the
// process opened, and the stale hang-up shut THAT socket down (the MCP
// target's load flakes: "Client disconnected", "Unable to parse empty data").
//
// The pin is the round-2 reviewer's probe `hangUpAfterCloseShutsDownAReused…`,
// rebuilt: the session's connection closed by the host's road
// (`closeConnection()`), a fresh socketpair opened until one end reuses the
// number, then the stale `hangUp()` — the fresh pair must still carry bytes
// both ways.

@Suite("VX-279 — a hang-up after the close leaves a reused descriptor alone")
struct MCPServerHostReuseTests {
    /// `count` bytes read from `fd` (bounded by its receive timeout), or what
    /// arrived before EOF / the timeout.
    private func read(_ fd: Int32, count: Int) -> Data {
        var buffer = [UInt8](repeating: 0, count: count)
        var got = 0
        while got < count {
            let n = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress! + got, count - got) }
            guard n > 0 else { break }
            got += n
        }
        return Data(buffer.prefix(got))
    }

    private func write(_ fd: Int32, _ data: Data) -> Int {
        data.withUnsafeBytes { Darwin.write(fd, $0.baseAddress, data.count) }
    }

    private func prepare(_ fd: Int32) {
        var one: Int32 = 1
        _ = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, socklen_t(MemoryLayout<Int32>.size))
        var timeout = timeval(tv_sec: 2, tv_usec: 0)
        _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    }

    @Test func hangUpAfterCloseLeavesAReusedDescriptorAlone() throws {
        let database = try AppDatabase.inMemory()
        let operations = withDependencies { $0.database = database } operation: { Operations() }
        var pair: [Int32] = [-1, -1]
        try #require(socketpair(AF_UNIX, SOCK_STREAM, 0, &pair) == 0)
        let number = pair[0]
        let session = MCPSession(
            fd: number, database: database, operations: operations, version: "test",
            executor: MCPSerialExecutor(operations: operations), hooks: MCPHostHooks())
        close(pair[1])

        // The session ended: the host closes its descriptor (its road)…
        session.closeConnection()

        // …and the process opens a fresh socket on the freed number (the
        // lowest free number is POSIX's rule; holes below it fill first).
        var reused: (mine: Int32, peer: Int32)?
        var spare: [Int32] = []
        for _ in 0..<64 where reused == nil {
            var fresh: [Int32] = [-1, -1]
            guard socketpair(AF_UNIX, SOCK_STREAM, 0, &fresh) == 0 else { break }
            if fresh[0] == number {
                reused = (fresh[0], fresh[1])
            } else if fresh[1] == number {
                reused = (fresh[1], fresh[0])
            } else {
                spare += fresh
            }
        }
        for fd in spare { close(fd) }
        let socket = try #require(reused, "premise: a fresh socket reused the closed session's number \(number)")
        defer {
            close(socket.mine)
            close(socket.peer)
        }
        prepare(socket.mine)
        prepare(socket.peer)

        // The stale hang-up a stop() makes on its snapshot of the sessions.
        session.hangUp()

        let hello = Data("hello\n".utf8)
        #expect(write(socket.peer, hello) == hello.count, "the unrelated socket still takes bytes")
        #expect(read(socket.mine, count: hello.count) == hello, "…and still reads them")
        #expect(write(socket.mine, hello) == hello.count, "the unrelated socket still writes")
        #expect(read(socket.peer, count: hello.count) == hello, "…and its peer still reads them")
    }
}
