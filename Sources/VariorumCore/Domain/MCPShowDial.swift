import Foundation

/// **VX-676 — THE SHOW DIAL** (her sitting 2026-10-28, ruling (3): "GLOBAL — one
/// setting in Settings ▸ MCP, move at once · ask · never"; ruling (1): "DEFAULT =
/// ASK"). How a client's `show_in_app` lands: moved at once, offered for her one
/// press, or not at all. The record is `notes/plans/fixes/vx-677-editor-panes-ai-door.md`
/// (BATCH 3).
///
/// **Her mid-run amendment (2026-10-28, RATIFIED):** the dial governs a FRONTMOST
/// arrival only — a show arriving while Variorum is not the app in front (or
/// without a full window) is never refused for that reason and always lands as the
/// ask, under every dial value but never ("if you've been out of the screen it
/// would be weird to suddenly be looking at something new"). The pure verdict is
/// `MCPShowRule` (VariorumMCP); this is the stored fact it reads.
///
/// Stored as ONE key of the local-only `mcp_switch` key/value family (A-6:
/// boundary state lives beside the grants the rule reads — never the synced
/// `setting` table, never UserDefaults), so the dial needs no migration and never
/// syncs: like every grant, it is this library's on this Mac.
public enum MCPShowDial: String, CaseIterable, Sendable {
    /// Moves her view at once — only while Variorum is in front in a full
    /// window; anywhere else the ask stands in for it (the amendment).
    case moveAtOnce = "move"
    /// Offered on the status seam for her one press (the default).
    case ask
    /// Nothing is shown or offered: the call answers in words.
    case never

    /// Her ruling (1): the ask.
    public static let `default`: MCPShowDial = .ask

    /// A stored value, read: absent (never set) or unknown (a value a later
    /// build wrote) reads as the default — the ask never moves anything without
    /// her, so it is the conservative reading of a value this build can't name.
    public init(stored value: String?) {
        self = value.flatMap(MCPShowDial.init(rawValue:)) ?? .default
    }
}

/// **VX-676 ruling (4) — "the activity log records the ask and the take"**, as
/// their own rows. The ask is logged on the CLIENT's call (its act; a move at once
/// keeps `show_in_app`'s own row, "showed you …"); the take is logged on HER press
/// under the asking client's name — her act, never the client's, so
/// `list_my_activity` never lists it (the connection-end lines' precedent): the
/// wire is fire-and-forget, and no road, polling included, tells a client she
/// took it. A dismissed ask is not logged (the ruling names the ask and the take).
public enum MCPShowActivity {
    /// The client's call landed as an ask (offered, nothing moved).
    public static let offeredAct = "show_in_app_offered"
    /// She opened what a client asked to show her.
    public static let takenAct = "show_in_app_taken"
}
