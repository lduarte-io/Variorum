import Foundation

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
// Every wait whose answer depends on the server under test goes through here: the
// blocking call runs on ITS OWN THREAD and the test task awaits it, holding no pool
// thread meanwhile — the door's own idiom (`MCPHandshake.openingOutcome`: "blocking
// reads … never hold a cooperative-pool thread"). The call is unchanged — the same
// read, under the same receive timeout set on its descriptor — so every bound means
// what it meant: how long the SERVER may take, never how long the pool stays full.
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
}
