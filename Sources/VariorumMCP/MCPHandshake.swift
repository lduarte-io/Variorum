import Darwin
import Foundation
import VariorumMCPSocket

/// **A CONNECTION's HANDSHAKE** (VX-168 — the VX-156 brief §12's K2, her
/// kickoff ruling R-VX168-1). Before the MCP SDK sees a byte, the session
/// reads the connection's opening: the shim's PREAMBLE line when there is one
/// (`MCPPreamble` — the setup key), then the client's `initialize` frame (past
/// any pre-initialize traffic — VX-180, below). The session decides the
/// connection once, through
/// `Operations.admitMCPConnection` (the pure `MCPSetupKeyRule` inside one
/// transaction): refused, it answers that frame with ONE honest JSON-RPC
/// error — the shim's own refusal shape — and the connection closes; admitted,
/// the frame is REPLAYED into the transport, so the SDK serves the connection
/// exactly as before.
///
/// **THE PRE-INITIALIZE WINDOW** (VX-180 — the kickoff
/// `notes/plans/vx-180-kickoff-prompt.md`; the record
/// `notes/plans/fixes/vx-180-discover-probe.md`). A client may speak BEFORE
/// its `initialize`: Claude Code 2.1.296 pipelines a `server/discover` request
/// ahead of it on every connection, and MCP's lifecycle lets any client ping
/// first. So the opening read does not take the first frame on trust: a
/// REQUEST for any other method is answered on its own id — `-32601` "Method
/// not found" (a `ping`, the empty result its utility requires) — a
/// NOTIFICATION is skipped (JSON-RPC answers none), and the read moves to the
/// next frame. Each answer is written BEFORE the next read blocks, so a client
/// that waits for it before sending `initialize` is never deadlocked. The
/// window is BOUNDED (`preInitializeLimit` frames); the frame past it — and
/// any frame that is no request or notification at all — is the opening's
/// frame exactly as before VX-180, and a non-`initialize` one meets the one
/// refusal. The window answers the same bytes whatever the connection
/// presented, so it is no oracle; it decides nothing — the admission still
/// decides once, on the `initialize` frame's name and the preamble's key.
///
/// The reads are byte-by-byte up to each newline, so nothing past the opening's
/// frame is consumed here — the transport's reader starts at the next byte.
enum MCPHandshake {
    /// What a connection opened with.
    struct Opening: Equatable, Sendable {
        /// The key the preamble presented; nil = no preamble (a bare shim).
        let presentedKey: String?
        /// The opening's frame, its newline removed: the `initialize` — or,
        /// when none came inside the pre-initialize window, the frame that
        /// ended it (VX-180), which the admission then refuses.
        let firstFrame: Data
    }

    /// The longest opening line read (a preamble is ~70 bytes and an
    /// `initialize` a few hundred; a line past this is no honest client's —
    /// the connection simply ends).
    static let lineLimit = 1 << 20
    /// Blank lines skipped before the opening (a peer sending only newlines
    /// ends rather than spins).
    static let blankLimit = 8
    /// **The pre-initialize window's bound** (VX-180): at most this many
    /// requests and notifications are answered or skipped before
    /// `initialize`; the next frame is the opening's whatever it is, so a
    /// peer that never initializes meets the refusal rather than holding an
    /// unadmitted connection in a loop. Claude Code sends ONE probe; eight is
    /// generous for any honest client's probing and small beside
    /// `lineLimit` (each frame read is still bounded by it). PROVISIONAL
    /// P-VX180-1 (the number).
    static let preInitializeLimit = 8

    /// JSON-RPC 2.0's code for a method the server does not serve — the
    /// window's answer to every pre-initialize request but `ping`.
    static let methodNotFoundCode = -32601
    /// JSON-RPC 2.0's own message for that code (its spec's words; no
    /// client-supplied text is echoed before the connection is decided).
    static let methodNotFoundMessage = "Method not found"

    /// **The ONE sentence every refused connection hears** — the same for a
    /// missing key, a key never issued, another name's key and a name bound
    /// to another key (no oracle; her Activity list speaks precisely).
    /// Technical register (P-13n-1, inside the door); provider-neutral; no
    /// pronouns on the wire. PROVISIONAL P-VX168-U1-4, her copy pass.
    static let refusal =
        "Variorum refused this connection: it needs the setup key from this client's own setup. In "
        + "Variorum, copy a fresh setup from Settings \u{25B8} MCP \u{25B8} Connect a client, run it, and "
        + "reconnect. If this client's name is already set up with another key, the author must deny it "
        + "there and approve it again first."

    /// **The STORE-ERROR sentence** (ladder R1, F-1): the admission's store
    /// threw, so the connection fails CLOSED — but the answer must not be the
    /// key advice above (a correctly keyed client told to re-copy its setup
    /// would rotate a good key for nothing). A store error is orthogonal to
    /// key standing, so a distinct sentence is no oracle. Nothing is logged
    /// for this arm: the store it would log to is the one that failed.
    /// PROVISIONAL words (P-VX168-U1-4's family, her copy pass).
    static let storeErrorRefusal =
        "Variorum couldn't check this connection \u{2014} try again."

    /// Read the opening on its OWN thread (blocking reads — and the window's
    /// small answers — never hold a cooperative-pool thread). nil when the
    /// connection ends (or a line overruns `lineLimit`, or a window answer
    /// cannot be written) before the opening's frame arrives.
    static func opening(fd: Int32) async -> Opening? {
        await withCheckedContinuation { continuation in
            let reader = Thread { continuation.resume(returning: readOpening(fd: fd)) }
            reader.name = "variorum.mcp.handshake"
            reader.start()
        }
    }

    /// The blocking read over ONE descriptor — no store, no state; since
    /// VX-180 it also WRITES to that descriptor, and only the pre-initialize
    /// window's fixed answers (`windowAnswer`), each before the next read.
    /// Pinned headless over a socket pair (and over a pipe where no frame
    /// asks for an answer).
    static func readOpening(fd: Int32) -> Opening? {
        guard let first = nextLine(fd) else { return nil }
        let presentedKey: String?
        var frame: Data
        switch MCPPreamble.classify(first) {
        case .frame:
            presentedKey = nil
            frame = first
        case .preamble(let key):
            guard let next = nextLine(fd) else { return nil }
            // Ladder R1, F-3: a tag-only preamble presents NOTHING — the
            // connection is bare (`classify` stays honest about the line;
            // the nothing-key maps to no key here, so her Activity says
            // "without a setup key"). The shim never speaks an empty key;
            // only a hand-rolled client reaches this.
            presentedKey = key.isEmpty ? nil : key
            frame = next
        }
        // VX-180: the pre-initialize window — bounded; the frame past it is
        // the opening's, whatever it is.
        for _ in 0..<preInitializeLimit {
            switch windowFrame(frame) {
            case .initialize, .other:
                return Opening(presentedKey: presentedKey, firstFrame: frame)
            case .request:
                // Answered NOW, before the next read blocks: a client that
                // waits for this answer before sending `initialize` must
                // hear it (a batched answer would deadlock that client).
                guard MCPSocketTransport.writeAll(fd, windowAnswer(toRequest: frame)) else { return nil }
            case .notification:
                break
            }
            guard let next = nextLine(fd) else { return nil }
            frame = next
        }
        return Opening(presentedKey: presentedKey, firstFrame: frame)
    }

    // MARK: - The pre-initialize window (VX-180)

    /// What a frame read before `initialize` is, to the window.
    enum WindowFrame: Equatable, Sendable {
        /// `initialize`, by its method — the opening's frame; from here the
        /// road is exactly the pre-VX-180 one.
        case initialize
        /// A request for any other method (a method and an id the refusal
        /// would echo — a string or a number): answered on its own id; the
        /// window continues.
        case request
        /// A notification (a method, no id): skipped — JSON-RPC answers
        /// none; the window continues.
        case notification
        /// Anything else — a line that is no JSON object naming a method (a
        /// response, a batch, a `null` id, malformed bytes): the opening's
        /// frame on the pre-VX-180 road, which refuses it.
        case other
    }

    /// Classify one frame read inside the window (pure).
    static func windowFrame(_ frame: Data) -> WindowFrame {
        guard let object = try? JSONSerialization.jsonObject(with: frame) as? [String: Any],
              let method = object["method"] as? String
        else { return .other }
        if method == "initialize" { return .initialize }
        guard let id = object["id"] else { return .notification }
        return isEchoableID(id) ? .request : .other
    }

    /// The window's answer to a REQUEST (pure; newline-framed): `ping` —
    /// MCP's one request a client may send before `initialize` is answered —
    /// gets the EMPTY result its utility requires (what this server's SDK
    /// answers a ping before initialize); every other method gets JSON-RPC's
    /// `-32601` with its own message. The id is echoed as it arrived (a
    /// string stays a string). The bytes depend on the frame alone — never on
    /// the key, the name, or the library.
    static func windowAnswer(toRequest frame: Data) -> Data {
        let object = (try? JSONSerialization.jsonObject(with: frame) as? [String: Any]) ?? [:]
        let id: Any = object["id"].flatMap { isEchoableID($0) ? $0 : nil } ?? NSNull()
        var response: [String: Any] = ["jsonrpc": "2.0", "id": id]
        if object["method"] as? String == "ping" {
            response["result"] = [String: Any]()
        } else {
            response["error"] = ["code": methodNotFoundCode, "message": methodNotFoundMessage]
        }
        let data = (try? JSONSerialization.data(withJSONObject: response, options: [.sortedKeys]))
            ?? Data(#"{"error":{"code":-32601,"message":"Method not found"},"id":null,"jsonrpc":"2.0"}"#.utf8)
        return data + Data("\n".utf8)
    }

    /// A request id the window answers by — the same rule the refusal echoes
    /// by (`MCPShim.refusalResponse`): a string or a number.
    private static func isEchoableID(_ id: Any) -> Bool {
        id is String || id is NSNumber
    }

    /// The first frame as an `initialize` request: the name and version its
    /// `clientInfo` declared. nil when the frame is not one (a client must
    /// open with `initialize` — MCP's lifecycle).
    static func initialize(_ frame: Data) -> (name: String, version: String?)? {
        guard let object = try? JSONSerialization.jsonObject(with: frame) as? [String: Any],
              object["method"] as? String == "initialize",
              let params = object["params"] as? [String: Any],
              let info = params["clientInfo"] as? [String: Any],
              let name = info["name"] as? String
        else { return nil }
        return (name, info["version"] as? String)
    }

    /// The refusal on the wire: the shim's shape, answering the first frame
    /// by its id.
    static func refusalResponse(toFirstFrame frame: Data) -> Data {
        MCPShim.refusalResponse(toFirstLine: frame, message: refusal)
    }

    // MARK: - The line reads

    /// The next non-blank line, newline removed.
    private static func nextLine(_ fd: Int32) -> Data? {
        for _ in 0...blankLimit {
            guard let line = readLine(fd) else { return nil }
            if !line.isEmpty { return line }
        }
        return nil
    }

    /// One line, read a byte at a time; nil at EOF/error before its newline
    /// or past `lineLimit`.
    private static func readLine(_ fd: Int32) -> Data? {
        var line = Data()
        var byte: UInt8 = 0
        while true {
            let count = read(fd, &byte, 1)
            if count < 0, errno == EINTR { continue }
            guard count == 1 else { return nil }
            if byte == UInt8(ascii: "\n") { return line }
            line.append(byte)
            if line.count > lineLimit { return nil }
        }
    }
}
