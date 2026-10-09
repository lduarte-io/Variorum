import Foundation

/// **THE MCP DOOR's server module** (13n-b, A-1 — the plan
/// `notes/plans/phase-13n-b-mcp-door.md`). The wire half of the door: the
/// socket transport, the per-connection MCP session, the grant authority's
/// per-call consult, and the tool projections. The grants substrate (the
/// local-only tables, their operations, the pure grant rule) lives in
/// VariorumCore so it tests headless with no SDK; this module is linked only
/// by the Mac app target.
public enum VariorumMCP {
    /// The server's name as `initialize` answers it.
    public static let serverName = "variorum"
}
