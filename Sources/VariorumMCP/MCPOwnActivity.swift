import Foundation
import VariorumCore

/// **`list_my_activity`'s projection — a client's own rows, AS LOGGED** (VX-261,
/// VX-336 U7 — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
/// U7 UNIT RECORD D-261-2/4/6 and THE ORCHESTRATOR'S RULINGS ON U7's FORKS).
///
/// **The oracle rule (D-261-4):** an entry answers only what the client SENT or
/// was TOLD at act time — never the current state of a target. It is a pure
/// projection of one `mcp_activity` row, joined to nothing: the tool (`act`),
/// `outcome`, `at`, the target the row names, and — on an ALLOWED row only — the
/// title it was told then. A REFUSED row never carries a title (F1: the log keeps
/// the real title of a note the client was told is not shared — answered as is, it
/// would be an oracle twice over), so a refused act on a hidden target and one on
/// a missing id read the same.
///
/// **The rows whose logged target is NOT an id the client sent** answer their
/// refusals without `target_*`:
/// - `duplicate_note`'s wing-side refusal logs the source's RESOLVED wing (F7) —
///   P-VX261-5 (b), RULED by the orchestrator: the oracle rule's strict letter.
/// - **PROVISIONAL P-VX261-6 (builder A — the same class, missed by the design's
///   trace):** the chapter acts (`rename_chapter`, `delete_chapter`,
///   `move_chapter`) log the chapter's BOOK, resolved from the section id even
///   when the client cannot reach it (`""` when the section names nothing), and
///   `delete_take` logs a LAST take's BLOCK, resolved likewise (the sent take id
///   otherwise). As logged, a refused row would tell a hidden chapter or take
///   from a missing one — so EVERY refused row of those acts answers no target,
///   and hidden and missing read byte-identical. Their ALLOWED rows keep the
///   target: the act's answer told the client that id (`book_id`, `block_id`).
///
/// A future act that logs a resolved id must join this table (the Hard rules:
/// no field may tell hidden from missing).
enum MCPOwnActivity {
    /// The acts the answer lists: every catalog tool but this one; the read
    /// rung's (`list_books`, `list_notes`, `read_note`, `export_note`,
    /// `search`, `show_in_app`) only when asked (F-261-5 (a)). Never a
    /// connection row (`connect_*`, the setup waits) — they are not tools.
    static func listedActs(includeReads: Bool) -> [String] {
        MCPToolCatalog.all
            .filter { $0.name != MCPToolCatalog.listMyActivity.name && (includeReads || $0.rung != .read) }
            .map(\.name)
    }

    /// The refused rows whose logged target is resolved, not sent.
    static func hidesTarget(_ row: MCPActivityRow) -> Bool {
        guard !row.allowed else { return false }
        switch row.act {
        case MCPToolCatalog.duplicateNote.name: return row.targetKind == "wing"
        case MCPToolCatalog.renameChapter.name, MCPToolCatalog.deleteChapter.name,
             MCPToolCatalog.moveChapter.name, MCPToolCatalog.deleteTake.name:
            return true
        default: return false
        }
    }

    /// One row, as logged (D-261-2): `tool`, `outcome`, `at`, the target when
    /// the row has one (and `hidesTarget` allows), and `title` on an allowed
    /// row that has one.
    static func entry(_ row: MCPActivityRow) -> [String: Any] {
        var entry: [String: Any] = ["tool": row.act, "outcome": row.allowed ? "allowed" : "refused", "at": row.at]
        if !hidesTarget(row) {
            if let kind = row.targetKind { entry["target_kind"] = kind }
            if let id = row.targetID { entry["target_id"] = id }
        }
        if row.allowed, let title = row.targetTitle { entry["title"] = title }
        return entry
    }

    /// The keyset cursor (D-261-6): opaque base64 of `a\n<row id>` — its own
    /// shape, so `list_notes`' cursors (and anything undecodable) answer the
    /// stale sentence.
    static func cursor(after id: Int64) -> String {
        Data("a\n\(id)".utf8).base64EncodedString()
    }

    static func rowID(decoding cursor: String) -> Int64? {
        guard let data = Data(base64Encoded: cursor), let text = String(data: data, encoding: .utf8) else { return nil }
        let parts = text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, parts[0] == "a", let id = Int64(parts[1]) else { return nil }
        return id
    }
}
