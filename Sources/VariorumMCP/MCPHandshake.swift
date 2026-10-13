import Darwin
import Foundation
import VariorumCore
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

    /// The longest opening line read — `MCPOpeningWindow.lineLimit` (1 MiB):
    /// a line past it is no honest client's, and since VX-184 U1 it is
    /// ANSWERED (`overLimitRefusal`, on `id: null`) before the connection
    /// ends.
    static let lineLimit = MCPOpeningWindow.lineLimit
    /// Blank lines skipped before the opening — `MCPOpeningWindow.blankLimit`.
    static let blankLimit = MCPOpeningWindow.blankLimit
    /// **The pre-initialize window's bound** (VX-180) —
    /// `MCPOpeningWindow.limit`: at most this many requests and notifications
    /// are answered or skipped before `initialize`; the next frame is the
    /// opening's whatever it is. PROVISIONAL P-VX180-1 (the number).
    static let preInitializeLimit = MCPOpeningWindow.limit

    /// JSON-RPC 2.0's code for a method the server does not serve — the
    /// window's answer to every pre-initialize request but `ping`.
    static let methodNotFoundCode = MCPOpeningWindow.methodNotFoundCode
    /// JSON-RPC 2.0's own message for that code.
    static let methodNotFoundMessage = MCPOpeningWindow.methodNotFoundMessage

    /// **The ONE sentence every refused connection hears** — the same for a
    /// missing key, a key never issued, another name's key and a name bound
    /// to another key (no oracle; her Activity list speaks precisely).
    /// Technical register (P-13n-1, inside the door); provider-neutral; no
    /// pronouns on the wire. PROVISIONAL P-VX168-U1-4, her copy pass.
    /// VX-198 (R-VX184-5): its last clause ("If this client's name is already
    /// set up with another key, the author must deny it there and approve it
    /// again first.") was falsified — a fresh setup now re-binds the name by
    /// itself — and is gone.
    static let refusal =
        "Variorum refused this connection: it needs the setup key from this client's own setup. In "
        + "Variorum, copy a fresh setup from Settings \u{25B8} MCP \u{25B8} Connect a client, run it, and "
        + "reconnect."

    /// **The REPLACED key's own sentence** (VX-198 — her R-VX184-5: "a newer
    /// setup replaced this one — run its setup again"): heard ONLY by a
    /// connection presenting the key a newer setup replaced under the name it
    /// claims — it tells that key's holder its own key's history and nothing
    /// about any other key or name, so it opens no oracle. PROVISIONAL
    /// P-VX198-2, her copy pass.
    static let replacedRefusal =
        "Variorum refused this connection: a newer setup replaced this one. Run this client's setup "
        + "again \u{2014} copy a fresh one from Settings \u{25B8} MCP \u{25B8} Connect a client \u{2014} "
        + "and reconnect."

    /// The sentence a refusal speaks: the replaced key's own, else the one.
    static func refusal(for reason: MCPSetupKeyRule.Refusal) -> String {
        reason == .replaced ? replacedRefusal : refusal
    }

    /// **The STORE-ERROR sentence** (ladder R1, F-1): the admission's store
    /// threw, so the connection fails CLOSED — but the answer must not be the
    /// key advice above (a correctly keyed client told to re-copy its setup
    /// would rotate a good key for nothing). A store error is orthogonal to
    /// key standing, so a distinct sentence is no oracle. Nothing is logged
    /// for this arm: the store it would log to is the one that failed.
    /// PROVISIONAL words (P-VX168-U1-4's family, her copy pass).
    static let storeErrorRefusal =
        "Variorum couldn't check this connection \u{2014} try again."

    /// **The OVER-LIMIT sentences** (VX-184 U1 — the record's "Over-cap
    /// answers"): a line ran past a cap before its newline, so its id cannot
    /// be read — the answer rides `id: null` (JSON-RPC 2.0's rule when the id
    /// cannot be detected), in the door's refusal shape (`MCPShim.refusalCode`),
    /// and the connection then closes. Before admission nothing was decided —
    /// the admission never ran — so the answer is the same for every
    /// connection: no oracle. PROVISIONAL words (her copy pass).
    static func overLimitRefusal(limit: Int, beforeInitialize: Bool) -> String {
        let size = "\(limit >> 20) MiB (\(grouped(limit)) bytes)"
        return beforeInitialize
            ? "Variorum closed this connection: a message before initialize ran past \(size)."
            : "Variorum closed this connection: a message ran past \(size), the most one message may "
                + "carry. Send smaller messages and reconnect."
    }

    /// The opening's over-limit answer, framed (`id: null`).
    static var overLimitResponse: Data {
        MCPShim.refusalResponse(
            toFirstLine: Data(), message: overLimitRefusal(limit: lineLimit, beforeInitialize: true))
    }

    /// 1048576 → "1,048,576" (fixed grouping — no locale on the wire).
    private static func grouped(_ value: Int) -> String {
        let digits = Array(String(value))
        var out = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index) % 3 == 0 { out.append(",") }
            out.append(digit)
        }
        return out
    }

    /// Read the opening on its OWN thread (blocking reads — and the window's
    /// small answers — never hold a cooperative-pool thread). nil when the
    /// connection ends (or a line overruns `lineLimit`, or a window answer
    /// cannot be written) before the opening's frame arrives.
    static func opening(fd: Int32) async -> Opening? {
        guard case .opened(let opening) = await openingOutcome(fd: fd) else { return nil }
        return opening
    }

    /// The same read, its ending told apart (VX-184 U1: the session answers an
    /// over-limit opening before it closes).
    static func openingOutcome(fd: Int32) async -> OpeningRead {
        await withCheckedContinuation { continuation in
            let reader = Thread { continuation.resume(returning: readOpeningOutcome(fd: fd)) }
            reader.name = "variorum.mcp.handshake"
            reader.start()
        }
    }

    /// How an opening read ended (VX-184 U1 — the over-limit arm told apart,
    /// so it can be answered).
    enum OpeningRead: Equatable, Sendable {
        case opened(Opening)
        /// EOF or error first (or a window answer that could not be written).
        case ended
        /// A line ran past `lineLimit` before its newline.
        case overLimit
    }

    /// The blocking read over ONE descriptor — no store, no state; since
    /// VX-180 it also WRITES to that descriptor, and only the pre-initialize
    /// window's fixed answers, each before the next read. Since VX-181 the
    /// window is `MCPOpeningWindow`'s — the SAME read the shim's closed-app
    /// refusal runs. Pinned headless over a socket pair (and over a pipe
    /// where no frame asks for an answer).
    static func readOpeningOutcome(fd: Int32) -> OpeningRead {
        let first: Data
        switch MCPOpeningWindow.nextLine(fd) {
        case .line(let line): first = line
        case .ended: return .ended
        case .overLimit: return .overLimit
        }
        let presentedKey: String?
        let start: Data
        switch MCPPreamble.classify(first) {
        case .frame:
            presentedKey = nil
            start = first
        case .preamble(let key):
            switch MCPOpeningWindow.nextLine(fd) {
            case .line(let next): start = next
            case .ended: return .ended
            case .overLimit: return .overLimit
            }
            // Ladder R1, F-3: a tag-only preamble presents NOTHING — the
            // connection is bare (`classify` stays honest about the line;
            // the nothing-key maps to no key here, so her Activity says
            // "without a setup key"). The shim never speaks an empty key;
            // only a hand-rolled client reaches this.
            presentedKey = key.isEmpty ? nil : key
        }
        // VX-180: the pre-initialize window — bounded; the frame past it is
        // the opening's, whatever it is.
        switch MCPOpeningWindow.read(startingWith: start, from: fd, answeringOn: fd) {
        case .frame(let frame): return .opened(Opening(presentedKey: presentedKey, firstFrame: frame))
        case .ended: return .ended
        case .overLimit: return .overLimit
        }
    }

    /// The opening, or nil when the connection ended or overran first (the
    /// over-cap refusal's read, and the VX-168/180 pins').
    static func readOpening(fd: Int32) -> Opening? {
        guard case .opened(let opening) = readOpeningOutcome(fd: fd) else { return nil }
        return opening
    }

    // MARK: - The pre-initialize window (VX-180) — since VX-181, `MCPOpeningWindow`'s

    /// What a frame read before `initialize` is, to the window.
    typealias WindowFrame = MCPOpeningWindow.Frame

    /// Classify one frame read inside the window (pure).
    static func windowFrame(_ frame: Data) -> WindowFrame { MCPOpeningWindow.classify(frame) }

    /// The window's answer to a REQUEST (pure; newline-framed).
    static func windowAnswer(toRequest frame: Data) -> Data { MCPOpeningWindow.answer(toRequest: frame) }

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
    /// by its id (VX-198: in the sentence `reason` speaks).
    static func refusalResponse(toFirstFrame frame: Data, reason: MCPSetupKeyRule.Refusal? = nil) -> Data {
        MCPShim.refusalResponse(toFirstLine: frame, message: reason.map(refusal(for:)) ?? refusal)
    }
}
