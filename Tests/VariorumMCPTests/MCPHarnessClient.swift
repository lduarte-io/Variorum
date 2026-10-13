import Darwin
import Foundation
import Logging
import MCP
import System

// VX-132 — THE HARNESS's CLIENT (the run record
// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1 — "VX-132 — the trace").
// The tests drive the server through the MCP SDK's own `Client` over the
// socket, and the pinned SDK has two gaps that stalled whole runs: its message
// loop spins forever once its stream ends (a server that closed), and nothing
// fails a pending request at that end. So the harness hands the SDK a
// transport that ENDS THE CLIENT when the stream ends, and bounds every act.

/// A connection as the tests hold it. `fd` is the transport's: it is closed
/// when the client disconnects (never by a test).
typealias HarnessConnection = (client: HarnessClient, fd: Int32)

/// **The SDK's own `StdioTransport`, with one thing added: the client never
/// outlives its stream.** The SDK's message loop asks `receive()` once, and
/// asks AGAIN only after that stream has ended and every line in it was
/// handled. That second ask is where the SDK would spin; here the loop is
/// parked on a stream that never yields, and the client is disconnected —
/// which fails every pending request instead of leaving it waiting. The
/// descriptor is closed only after the SDK's read loop is done with it (its
/// `disconnect` returned), so a number another test reopens is never read.
actor HarnessTransport: Transport {
    nonisolated let logger: Logger
    private let fd: Int32
    private let inner: StdioTransport
    private var stream: AsyncThrowingStream<Data, Swift.Error>?
    private var parked: AsyncThrowingStream<Data, Swift.Error>.Continuation?
    private var whenDrained: (@Sendable () async -> Void)?
    private var closed = false
    /// How many times the client's message loop asked for its stream — one
    /// while connected, two once it ended (the hygiene pin reads it).
    private(set) var receiveCalls = 0

    init(fd: Int32) {
        self.fd = fd
        let inner = StdioTransport(input: FileDescriptor(rawValue: fd), output: FileDescriptor(rawValue: fd))
        self.inner = inner
        self.logger = inner.logger
    }

    /// What ends the client once its stream has drained.
    func onDrained(_ handler: @escaping @Sendable () async -> Void) { whenDrained = handler }

    func connect() async throws {
        try await inner.connect()
        stream = await inner.receive()
    }

    func disconnect() async {
        guard !closed else { return }
        closed = true
        parked?.finish()
        parked = nil
        await inner.disconnect()   // after this the SDK's read loop never reads again
        close(fd)
    }

    func send(_ data: Data) async throws { try await inner.send(data) }

    func receive() -> AsyncThrowingStream<Data, Swift.Error> {
        receiveCalls += 1
        if receiveCalls == 1, let stream { return stream }
        let (waiting, continuation) = AsyncThrowingStream<Data, Swift.Error>.makeStream()
        if closed { continuation.finish() } else { parked = continuation }
        if let handler = whenDrained {
            whenDrained = nil
            Task { await handler() }
        }
        return waiting
    }

    /// The deadline's end of the act: hang up the socket (its reader sees
    /// EOF; the client then ends as above). Never touches a closed number.
    func end() {
        guard !closed else { return }
        shutdown(fd, SHUT_RDWR)
    }
}

/// **The SDK client, every act bounded** (`HarnessDeadline`): the methods the
/// tests call, by the SDK's own names, each failing NAMED past its limit.
struct HarnessClient: Sendable {
    let sdk: Client
    let transport: HarnessTransport
    /// What `initialize` answered — the server's info and its advice.
    let initialized: Initialize.Result

    func callTool(name: String, arguments: [String: Value]? = nil) async throws
        -> (content: [Tool.Content], isError: Bool?) {
        let sdk = self.sdk
        return try await HarnessDeadline.run("callTool(\(name))", onTimeout: hangUp) {
            let result: (content: [Tool.Content], isError: Bool?) =
                try await sdk.callTool(name: name, arguments: arguments)
            return result
        }
    }

    func listTools() async throws -> (tools: [Tool], nextCursor: String?) {
        let sdk = self.sdk
        return try await HarnessDeadline.run("listTools", onTimeout: hangUp) {
            try await sdk.listTools()
        }
    }

    @discardableResult
    func onNotification<N: MCP.Notification>(
        _ type: N.Type, handler: @escaping @Sendable (Message<N>) async throws -> Void
    ) async -> HarnessClient {
        await sdk.onNotification(type, handler: handler)
        return self
    }

    /// The client hangs up: the SDK disconnects and the transport closes the
    /// socket, so the server sees the session end.
    func disconnect() async {
        let sdk = self.sdk
        _ = try? await HarnessDeadline.run("disconnect", onTimeout: hangUp) { await sdk.disconnect() }
    }

    private var hangUp: @Sendable () -> Void {
        let transport = self.transport
        return { Task { await transport.end() } }
    }
}
