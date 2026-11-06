import Foundation

/// **VX-874 — THE TRAIL DIAL** (her rulings 2026-11-04/05 on the sidebar's AI
/// section — the record `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3):
/// TWO off switches as ONE three-state control, home Settings ▸ MCP — **everything
/// on · notices off · fully off**. Notices off hides the rows of what a client
/// changed or what she opened, while a client's navigation asks (an ask to show
/// her something, not yet followed) still show — her "turning off notices won't
/// turn off navigation requests, right?", ruled yes; fully off ("add the ability
/// to turn off showing it period") draws no section at all, so a navigation ask
/// then arrives only as its transient bottom-bar offer. The ask's one-press offer
/// on the status seam is a separate road that no value of this dial touches.
///
/// A FILTER of what the section DRAWS: the session's trail keeps recording under
/// every value (memory only), so turning notices back on shows the session's
/// notices again.
///
/// Stored as ONE key of the local-only `mcp_switch` key/value family — the show
/// dial's precedent (`MCPShowDial`, VX-676): beside the grants, never the synced
/// `setting` table, never UserDefaults, so it needs no migration and never syncs.
public enum MCPTrailDial: String, CaseIterable, Sendable {
    /// Every row: a client's navigation asks and its notices (the default — the
    /// section as VX-679 built it).
    case everything = "all"
    /// Only a client's navigation asks (rows of kind `shown`); its notices —
    /// what it changed, what she opened — are left off.
    case asksOnly = "asks"
    /// No section at all.
    case off

    /// The section as it always was.
    public static let `default`: MCPTrailDial = .everything

    /// A stored value, read: absent (never set) or unknown (a value a later build
    /// wrote) reads as the default — the section shows what it always showed.
    public init(stored value: String?) {
        self = value.flatMap(MCPTrailDial.init(rawValue:)) ?? .default
    }

    /// Whether the section draws a client's notices (its writes, what she opened).
    public var drawsNotices: Bool { self == .everything }

    /// Whether the section draws at all.
    public var drawsSection: Bool { self != .off }
}
