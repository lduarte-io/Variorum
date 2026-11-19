import Darwin
import Dependencies
import Foundation

@testable import VariorumMCPSocket

// VX-951 · VX-944 (the VX-981 run, batch 3 — the record
// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 3 — RECORD): THE
// ANNOUNCE PINS' RAW CLIENT. The pins need what the SDK's own `Client` hides: the
// exact order of every frame the server writes (an SDK client swallows a
// notification it reads before its `initialize` answer), when — or whether — the
// client says `initialized`, and a client that STOPS READING. Every blocking call
// runs off the cooperative pool (`HarnessWait`'s rule 1): the reader is a thread of
// its own, every wait is a bounded poll that only sleeps.

/// The bound for "within the bound" (VX-944): a reading session hears a notice
/// the server owes it in milliseconds; ten seconds is a stall, never a slow pool.
let announceStallBound: Double = 10

/// One raw client on the host's socket.
final class AnnounceRawClient: @unchecked Sendable {
    let fd: Int32
    private let collected = LockIsolated<[Data]>([])
    private let readerDone = DispatchSemaphore(value: 0)
    private let started = LockIsolated(false)

    private init(fd: Int32) { self.fd = fd }

    /// Connect, then ONE write: the setup key's preamble (when given), an
    /// `initialize` as `name` with request id `id`, and `then` (whole frames,
    /// each newline-terminated — what a client PIPELINES behind its `initialize`).
    static func open(
        _ directory: URL, key: String?, as name: String, id: Int, then pipelined: String = ""
    ) async throws -> AnnounceRawClient {
        guard case .success(let fd) = MCPSocketRoad.connect(directory: directory) else {
            throw HarnessFailure("could not connect as \(name)")
        }
        var bytes = key.map { MCPPreamble.line(key: $0) } ?? Data()
        bytes.append(Data((initialize(name, id: id) + "\n" + pipelined).utf8))
        let all = bytes
        _ = await HarnessWait.offPool { MCPShim.writeAll(fd, all) }
        return AnnounceRawClient(fd: fd)
    }

    static func initialize(_ name: String, id: Int) -> String {
        #"{"jsonrpc":"2.0","id":\#(id),"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"\#(name)","version":"1"}}}"#
    }
    static let initialized = #"{"jsonrpc":"2.0","method":"notifications/initialized"}"# + "\n"
    static func ping(_ id: Int) -> String { #"{"jsonrpc":"2.0","id":\#(id),"method":"ping"}"# + "\n" }
    static func listTools(_ id: Int) -> String { #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/list","params":{}}"# + "\n" }
    static func call(_ tool: String, id: Int) -> String {
        #"{"jsonrpc":"2.0","id":\#(id),"method":"tools/call","params":{"name":"\#(tool)","arguments":{}}}"# + "\n"
    }

    /// Write frames (off the pool — the server reading them runs on its own thread).
    func write(_ frames: String) async {
        let fd = self.fd
        let bytes = Data(frames.utf8)
        _ = await HarnessWait.offPool { MCPShim.writeAll(fd, bytes) }
    }

    /// Read every line the server writes, as it comes, until EOF — on a thread of
    /// its own (a client that READS). Once.
    func startReading() {
        guard started.withValue({ was in defer { was = true }; return !was }) else { return }
        let fd = self.fd
        let collected = self.collected
        let done = readerDone
        let reader = Thread {
            var pending = Data()
            var buffer = [UInt8](repeating: 0, count: 64 * 1024)
            while true {
                let count = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { break }
                pending.append(contentsOf: buffer[0..<count])
                while let newline = pending.firstIndex(of: UInt8(ascii: "\n")) {
                    let line = pending.subdata(in: pending.startIndex..<newline)
                    pending = pending.subdata(in: (newline + 1)..<pending.endIndex)
                    collected.withValue { $0.append(line) }
                }
            }
            done.signal()
        }
        reader.name = "vx981.announce-reader"
        reader.start()
    }

    /// Every line read so far, in order.
    var lines: [Data] { collected.value }

    /// A line as a JSON object (nil when it is not one).
    static func object(_ line: Data) -> [String: Any]? {
        try? JSONSerialization.jsonObject(with: line) as? [String: Any]
    }

    static func isListChanged(_ line: Data) -> Bool {
        object(line)?["method"] as? String == "notifications/tools/list_changed"
    }

    /// The answer carrying `id`, as read so far.
    static func answer(_ lines: [Data], to id: Int) -> [String: Any]? {
        lines.lazy.compactMap(object).first { ($0["id"] as? Int) == id && $0["method"] == nil }
    }

    /// How many `tools/list_changed` notices were read so far.
    var listChangedCount: Int { lines.filter(Self.isListChanged).count }

    /// Wait (a bounded poll that only sleeps) until `condition` holds over the
    /// lines read so far.
    func waitUntil(_ seconds: Double = HarnessDeadline.seconds, _ condition: @escaping ([Data]) -> Bool) async -> Bool {
        await pollUntil(seconds) { condition(self.lines) }
    }

    /// Bytes the server wrote that this client has not read (`SO_NREAD`).
    var unreadBytes: Int {
        var value: Int32 = 0
        var size = socklen_t(MemoryLayout<Int32>.size)
        return getsockopt(fd, SOL_SOCKET, SO_NREAD, &value, &size) == 0 ? Int(value) : 0
    }

    /// End this client: its socket shut both ways (the reader's `read` returns),
    /// its reader awaited (bounded), then the descriptor closed — never under a
    /// live reader.
    func finish() async {
        _ = shutdown(fd, SHUT_RDWR)
        if started.value {
            let done = readerDone
            _ = await HarnessWait.offPool { done.wait(timeout: .now() + 5) }
        }
        close(fd)
    }
}

/// A bounded poll that only sleeps between looks (no blocking call on the pool).
func pollUntil(_ seconds: Double, _ condition: @escaping () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(2))
    }
    return condition()
}
