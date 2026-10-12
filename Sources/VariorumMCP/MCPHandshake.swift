import Darwin
import Foundation
import VariorumMCPSocket

/// **A CONNECTION's HANDSHAKE** (VX-168 — the VX-156 brief §12's K2, her
/// kickoff ruling R-VX168-1). Before the MCP SDK sees a byte, the session
/// reads the connection's opening: the shim's PREAMBLE line when there is one
/// (`MCPPreamble` — the setup key), then the FIRST FRAME (the client's
/// `initialize`). The session decides the connection once, through
/// `Operations.admitMCPConnection` (the pure `MCPSetupKeyRule` inside one
/// transaction): refused, it answers that frame with ONE honest JSON-RPC
/// error — the shim's own refusal shape — and the connection closes; admitted,
/// the frame is REPLAYED into the transport, so the SDK serves the connection
/// exactly as before.
///
/// The reads are byte-by-byte up to each newline, so nothing past the first
/// frame is consumed here — the transport's reader starts at the next byte.
enum MCPHandshake {
    /// What a connection opened with.
    struct Opening: Equatable, Sendable {
        /// The key the preamble presented; nil = no preamble (a bare shim).
        let presentedKey: String?
        /// The first MCP frame, its newline removed.
        let firstFrame: Data
    }

    /// The longest opening line read (a preamble is ~70 bytes and an
    /// `initialize` a few hundred; a line past this is no honest client's —
    /// the connection simply ends).
    static let lineLimit = 1 << 20
    /// Blank lines skipped before the opening (a peer sending only newlines
    /// ends rather than spins).
    static let blankLimit = 8

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

    /// Read the opening on its OWN thread (blocking reads never hold a
    /// cooperative-pool thread). nil when the connection ends (or a line
    /// overruns `lineLimit`) before a first frame arrives.
    static func opening(fd: Int32) async -> Opening? {
        await withCheckedContinuation { continuation in
            let reader = Thread { continuation.resume(returning: readOpening(fd: fd)) }
            reader.name = "variorum.mcp.handshake"
            reader.start()
        }
    }

    /// The blocking read (pure over a descriptor — pinned headless).
    static func readOpening(fd: Int32) -> Opening? {
        guard let first = nextLine(fd) else { return nil }
        switch MCPPreamble.classify(first) {
        case .frame:
            return Opening(presentedKey: nil, firstFrame: first)
        case .preamble(let key):
            guard let frame = nextLine(fd) else { return nil }
            return Opening(presentedKey: key, firstFrame: frame)
        }
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
