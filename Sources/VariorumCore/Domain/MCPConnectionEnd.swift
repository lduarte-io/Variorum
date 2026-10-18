import Foundation

/// **WHY AN MCP CONNECTION ENDED** (VX-394 — VX-348 U5, the run record
/// `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5, VX-394's section).
///
/// Her report: partway through a long session, at night with the Mac idle,
/// every Variorum tool vanished ("MCP server disconnected") while Settings ▸
/// MCP said the server was running. Nothing on her side said a connection had
/// ended, or why. Each connection that ends now leaves ONE line in the
/// activity log (`mcp_activity`, local-only), its act one of these — so the
/// log tells the two stories apart: the CLIENT ended it, or Variorum did (and
/// which of its roads). The words are the pane's (`MCPPaneCopy`); a client's
/// `list_my_activity` never lists them (they are not its tools —
/// `MCPOwnActivity`'s rule for every connection row).
///
/// Only a connection that named itself (a client admitted past the setup key,
/// its `initialize` read) leaves a line: a refused or never-initialized
/// connection already says itself in the setup-key rows, or is nobody.
public enum MCPConnectionEnd: String, CaseIterable, Sendable {
    /// The client's side closed the connection — the client quit or restarted
    /// its server, or its process ended (a reconnect from the client starts a
    /// new one). The server was still running.
    case clientClosed = "disconnect_client"
    /// Variorum closed the library — it LOCKED (Lock Now; under Castle, its
    /// re-lock on sleep, on screen lock, or after the time away its dial says,
    /// counted from her own use of Variorum), or it closed to open another
    /// library or to re-key this one. A locked library serves no one (A-8): the
    /// server stops with it and starts again at the next unlock, so the pane
    /// says "running" once she is back while the client stays disconnected.
    case libraryClosed = "disconnect_library_closed"
    /// The MCP server was switched off (Settings ▸ MCP's switch).
    case serverOff = "disconnect_server_off"
    /// The client sent a message past the size cap (answered, then closed —
    /// VX-184 U1).
    case overLimit = "disconnect_over_limit"

    /// The activity log's act for this end.
    public var act: String { rawValue }

    /// The end an activity row's act names (nil: not a connection's end).
    public init?(act: String) { self.init(rawValue: act) }
}
