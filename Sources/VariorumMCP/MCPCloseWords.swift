import Foundation
import VariorumCore
import VariorumMCPSocket

/// **What the app tells a client as it ends its connection** (VX-762 — B2 part
/// two, PROVISIONAL P-771-3; A-771-3 (3): her copy pass owns the words). One
/// sentence per stop that has a reason, sent as the connection's last line
/// (`MCPCloseLine`) and said by the shim on the client's stderr — the client's
/// MCP log, never the protocol. Provider-neutral beyond the command (O-4's net
/// bans names, not "/mcp" — VX-640). These are the CLIENT's words: the
/// Activity log's lines for the same ends (`MCPConnectionEnd`, the pane's own
/// words) are untouched by them.
enum MCPCloseWords {
    /// Her switch OFF (Settings ▸ MCP).
    static let serverOff =
        "Variorum's MCP server was turned off, so it closed this connection — reconnect with /mcp once it's on again."

    /// The library locked (Lock Now; Castle's re-lock on sleep, screen lock or
    /// time away) or closed (another library opened, a crossing re-keying it).
    static let libraryClosed =
        "Variorum's library locked or closed, so it closed this connection — reconnect with /mcp once it's open again."

    /// The app quit. FLAGGED for her beside P-VX394-5 ("a quit logs nothing" —
    /// the Activity log's rule, which stands: this line is the client's, and the
    /// quit still writes no Activity line).
    static let quit = "Variorum quit, so it closed this connection — reconnect with /mcp once it's open again."

    /// The words for a stop that ended a connection for `end` — nil for the ends
    /// that are not a stop's (the client's own close, a message over the cap).
    static func words(for end: MCPConnectionEnd) -> String? {
        switch end {
        case .serverOff: serverOff
        case .libraryClosed: libraryClosed
        case .clientClosed, .overLimit: nil
        }
    }

    /// The close line for `end`'s stop, framed (`MCPCloseLine.line`).
    static func line(for end: MCPConnectionEnd) -> Data? { words(for: end).flatMap(MCPCloseLine.line) }

    /// The quit's close line, framed.
    static var quitLine: Data? { MCPCloseLine.line(quit) }
}
