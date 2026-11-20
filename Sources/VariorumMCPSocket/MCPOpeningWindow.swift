import Darwin
import Foundation

/// **THE PRE-INITIALIZE WINDOW — one rule, both doors** (VX-180 built it in
/// the app's handshake — the record `notes/plans/fixes/vx-180-discover-probe.md`;
/// VX-181 moved it here so the `variorum-mcp` shim reads it too — the record
/// `notes/plans/fixes/vx-184-mcp-launch-polish.md`, U1).
///
/// A client may speak BEFORE its `initialize`: Claude Code 2.1.296 pipelines a
/// `server/discover` request ahead of it on every connection, and MCP's
/// lifecycle lets any client ping first. Whoever reads a connection's opening —
/// the app's handshake (`MCPHandshake`), or the shim when it cannot reach the
/// app and must refuse — reads it through this window: a REQUEST for any other
/// method is answered on its own id (`-32601` "Method not found"; a `ping`, the
/// empty result its utility requires), a NOTIFICATION is skipped (JSON-RPC
/// answers none), and the read moves on. Each answer is written BEFORE the next
/// read blocks, so a client that waits for it before sending `initialize` is
/// never deadlocked. The window is BOUNDED (`limit` frames); the frame that
/// ends it — the `initialize`, the frame past the bound, or any frame that is
/// no request or notification at all — is the opening's, and the caller
/// decides it (the app admits or refuses; the shim answers it with its honest
/// sentence). The answers depend on the frame alone, so the window is no
/// oracle, and it decides nothing.
///
/// VX-952 (the VX-981 run, batch 4): the lines are read in CHUNKS by the
/// opening's `Reader` (they were read a byte at a time — a 1 MiB opening line
/// cost a million `read` calls on the handshake's thread), and nothing is lost:
/// whatever the reader read past the opening's frame is its `leftover`, handed
/// on byte for byte to whoever reads the connection next (the app's transport).
/// Foundation and Darwin only, like the rest of this module (the shim links
/// nothing of Variorum's).
public enum MCPOpeningWindow {
    // MARK: - The bounds

    /// How many requests and notifications are answered or skipped before
    /// `initialize`; the next frame is the opening's whatever it is.
    /// PROVISIONAL P-VX180-1 (the number).
    public static let limit = 8
    /// The longest line read in an opening (a preamble is ~70 bytes and an
    /// `initialize` a few hundred): one byte more and the opening is OVER —
    /// its reader answers it on `id: null` and the connection ends.
    public static let lineLimit = 1 << 20
    /// Blank lines skipped before a frame (a peer sending only newlines ends
    /// rather than spins).
    public static let blankLimit = 8

    // MARK: - The answers' words

    /// JSON-RPC 2.0's code for a method the server does not serve.
    public static let methodNotFoundCode = -32601
    /// JSON-RPC 2.0's own message for that code (no client-supplied text is
    /// echoed before the connection is decided).
    public static let methodNotFoundMessage = "Method not found"

    // MARK: - What a frame is to the window (pure)

    public enum Frame: Equatable, Sendable {
        /// `initialize`, by its method — the opening's frame.
        case initialize
        /// A request for any other method (a method and an echoable id):
        /// answered on its own id; the window continues.
        case request
        /// A notification (a method, no id): skipped; the window continues.
        case notification
        /// Anything else — a response, a batch, a `null` id, an id no answer
        /// could echo, malformed bytes: the opening's frame at once.
        case other
    }

    /// **The ONE echoable-id rule** (VX-180's ladder, NIT 1 — discharged at
    /// VX-181): an id an answer may carry back is a string or a number
    /// (booleans included — `CFBoolean` is an `NSNumber`, the shim's rule
    /// since 13n-b). Every answer the door writes before a connection is
    /// decided — the window's, the shim's refusal, the app's refusal and
    /// over-cap answers — reads this one predicate.
    public static func isEchoableID(_ id: Any) -> Bool {
        id is String || id is NSNumber
    }

    /// Classify one frame read inside the window.
    public static func classify(_ frame: Data) -> Frame {
        guard let object = try? JSONSerialization.jsonObject(with: frame) as? [String: Any],
              let method = object["method"] as? String
        else { return .other }
        if method == "initialize" { return .initialize }
        guard let id = object["id"] else { return .notification }
        return isEchoableID(id) ? .request : .other
    }

    /// The window's answer to a REQUEST (newline-framed): `ping` gets the
    /// EMPTY result (P-VX180-2), every other method `-32601`. The id is
    /// echoed as it arrived. The bytes depend on the frame alone.
    public static func answer(toRequest frame: Data) -> Data {
        let object = (try? JSONSerialization.jsonObject(with: frame) as? [String: Any]) ?? [:]
        let id: Any = object["id"].flatMap { isEchoableID($0) ? $0 : nil } ?? NSNull()
        var response: [String: Any] = ["jsonrpc": "2.0", "id": id]
        if object["method"] as? String == "ping" {
            response["result"] = [String: Any]()
        } else {
            response["error"] = ["code": methodNotFoundCode, "message": methodNotFoundMessage]
        }
        // The fallback is unreachable (this dictionary always serializes);
        // built from the same constants so it can never drift from them
        // (VX-180 ladder R1, NIT 2).
        let data = (try? JSONSerialization.data(withJSONObject: response, options: [.sortedKeys]))
            ?? Data(#"{"error":{"code":\#(methodNotFoundCode),"message":"\#(methodNotFoundMessage)"},"id":null,"jsonrpc":"2.0"}"#.utf8)
        return data + Data("\n".utf8)
    }

    // MARK: - The reads (VX-952: buffered — the opening's own reader)

    /// One read of a line.
    public enum LineRead: Equatable, Sendable {
        /// A complete line, its newline removed.
        case line(Data)
        /// EOF or an error before the newline (or only blank lines past
        /// `blankLimit`).
        case ended
        /// The line ran past `lineLimit` bytes before its newline.
        case overLimit
    }

    /// **The opening's reader** (VX-952 — the vx-940 run's F-W4-3): one
    /// descriptor, read in CHUNKS — a line of the full 1 MiB costs seventeen
    /// `read` calls, not a million — handing out lines with the byte-at-a-time
    /// reader's exact verdicts (a line of `limit` bytes is a line, one byte more
    /// is over, wherever its newline falls; EOF or an error ends it). A read is
    /// made only when no complete line is buffered, so it blocks exactly where
    /// a byte-at-a-time read would (the window's answer is always written
    /// before it). Whatever it read past the lines it handed out is its
    /// `leftover` — the NEXT reader's to start with, byte for byte (the app's
    /// transport; the shim and the over-cap refusal end the connection and drop
    /// it).
    public struct Reader {
        /// The bytes each read asks for — the transport's own (`readLines`).
        public static let chunk = 64 * 1024

        private let fd: Int32
        private let read: (Int32, UnsafeMutableRawPointer, Int) -> Int
        private var scratch: [UInt8]
        /// Bytes read and not yet handed out begin at `start`.
        private var pending: [UInt8] = []
        private var start = 0

        public init(_ fd: Int32) {
            self.init(fd, chunk: Self.chunk) { Darwin.read($0, $1, $2) }
        }

        /// A reader over `read` (a pin counts its calls), asking `chunk` bytes
        /// at a time.
        init(_ fd: Int32, chunk: Int, read: @escaping (Int32, UnsafeMutableRawPointer, Int) -> Int) {
            self.fd = fd
            self.read = read
            self.scratch = [UInt8](repeating: 0, count: max(chunk, 1))
        }

        /// Every byte read past the lines handed out, in order.
        public var leftover: Data { Data(pending[start...]) }

        /// One line, its newline removed.
        public mutating func readLine(limit: Int = lineLimit) -> LineRead {
            var scanned = start  // the bytes before `scanned` hold no newline
            while true {
                if let newline = pending[scanned...].firstIndex(of: UInt8(ascii: "\n")) {
                    guard newline - start <= limit else { return .overLimit }
                    let line = Data(pending[start..<newline])
                    start = newline + 1
                    if start == pending.count {
                        pending.removeAll(keepingCapacity: true)
                        start = 0
                    } else if start >= Self.chunk {
                        pending.removeFirst(start)   // a long line handed out: keep only what follows it
                        start = 0
                    }
                    return .line(line)
                }
                guard pending.count - start <= limit else { return .overLimit }
                scanned = pending.count
                guard fill() else { return .ended }
            }
        }

        /// The next non-blank line.
        public mutating func nextLine() -> LineRead {
            for _ in 0...blankLimit {
                let result = readLine()
                if case .line(let line) = result, line.isEmpty { continue }
                return result
            }
            return .ended
        }

        /// One read appended to `pending`; false at EOF or an error.
        private mutating func fill() -> Bool {
            let (fd, read) = (self.fd, self.read)
            while true {
                let count = scratch.withUnsafeMutableBytes { read(fd, $0.baseAddress!, $0.count) }
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { return false }
                pending.append(contentsOf: scratch[0..<count])
                return true
            }
        }
    }

    /// How a window's read ended.
    public enum Opening: Equatable, Sendable {
        /// The opening's frame: the `initialize`, the frame past the bound, or
        /// a frame that is no request or notification.
        case frame(Data)
        /// The connection ended first (EOF, or an answer that could not be
        /// written — the client is gone).
        case ended
        /// A line ran past `lineLimit`.
        case overLimit
    }

    /// **Read past the window**, from `first` (the line already read), on
    /// `reader`, answering its requests on `output` — each answer written
    /// before the next read (VX-952: the reader reads only when no complete
    /// line is buffered, so it blocks exactly where a byte-at-a-time read did).
    public static func read(startingWith first: Data, from reader: inout Reader, answeringOn output: Int32) -> Opening {
        var frame = first
        for _ in 0..<limit {
            switch classify(frame) {
            case .initialize, .other:
                return .frame(frame)
            case .request:
                guard writeAll(output, answer(toRequest: frame)) else { return .ended }
            case .notification:
                break
            }
            switch reader.nextLine() {
            case .line(let next): frame = next
            case .ended: return .ended
            case .overLimit: return .overLimit
            }
        }
        return .frame(frame)
    }

    /// Read a whole opening from `reader` — its first non-blank line, then the
    /// window — answering on `output`.
    public static func read(from reader: inout Reader, answeringOn output: Int32) -> Opening {
        switch reader.nextLine() {
        case .line(let first): read(startingWith: first, from: &reader, answeringOn: output)
        case .ended: .ended
        case .overLimit: .overLimit
        }
    }

    @discardableResult
    static func writeAll(_ fd: Int32, _ data: Data) -> Bool {
        var offset = 0
        return data.withUnsafeBytes { raw -> Bool in
            while offset < raw.count {
                let written = write(fd, raw.baseAddress! + offset, raw.count - offset)
                if written < 0, errno == EINTR { continue }
                guard written > 0 else { return false }
                offset += written
            }
            return true
        }
    }
}
