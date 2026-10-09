import Foundation
import GRDB
import VariorumCore

/// **`read_note` with `with_ids: true`** (13n-b U2 — AF-5): the note as
/// structure — its blocks in order, each with its id, the SHOWN take's text
/// (the read-time rule: the placement's chosen take while it is live, active
/// and on this block, else the block default, else the fan's first), every
/// live ACTIVE take (id, label, whether it is the one shown, text — archived
/// takes are out of the fan, the export's rule) and its live comments. The ids
/// are the REAL row ids: every later write revalidates them per call against
/// current facts — and they are LIVE-WIRE ONLY (R-13nb-9, her doctrine: a
/// merge or a divide mints new blocks, so an id goes stale under her
/// structural edits; a stale id refuses honestly and a re-read recovers).
/// A block's NAME rides where set (R-13nb-8 — "in the xyz block" works
/// conversationally) as metadata only: ids stay the ONE write address (names
/// are not unique). Gated by the very same decision as the text form (the
/// caller's transaction), and ∝ the note — three statements, never the
/// corpus. Shaped to grow optional fields (R-13nb-7's `with_commits` is U3's).
enum MCPNoteStructure {
    static func read(_ db: Database, noteID: String, calendar: Calendar) throws -> [String: Any] {
        let title = try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar) ?? ""
        let placements = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id, b.name
                FROM container_block cb JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id
                """,
            arguments: [noteID])
        let blockIDs: [String] = placements.map { $0["block_id"] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        var takes: [String: [Row]] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT v.id, v.block_id, v.label, v.working_text FROM json_each(?) j
                JOIN variant v ON v.block_id = j.value
                WHERE v.deleted_at IS NULL AND v.status = 'active'
                ORDER BY v.fan_position, v.id
                """,
            arguments: [json]) {
            takes[row["block_id"], default: []].append(row)
        }
        var comments: [String: [[String: Any]]] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.block_id, c.text FROM json_each(?) j
                JOIN block_comment c ON c.block_id = j.value
                WHERE c.deleted_at IS NULL
                ORDER BY c.created_at, c.id
                """,
            arguments: [json]) {
            comments[row["block_id"], default: []].append(["comment_id": row["id"] as String, "text": row["text"] as String])
        }
        var blocks: [[String: Any]] = []
        for placement in placements {
            let blockID: String = placement["block_id"]
            let fan = takes[blockID] ?? []
            let ids = Set(fan.map { $0["id"] as String })
            let chosen: String? = placement["chosen_variant_id"]
            let fallback: String? = placement["default_variant_id"]
            let shown = [chosen, fallback].compactMap { $0 }.first { ids.contains($0) } ?? fan.first?["id"]
            var entries: [[String: Any]] = []
            var shownText = ""
            for take in fan {
                let id: String = take["id"]
                let text: String = take["working_text"]
                var entry: [String: Any] = ["take_id": id, "chosen": id == shown, "text": text]
                if let label: String = take["label"] { entry["label"] = label }
                entries.append(entry)
                if id == shown { shownText = text }
            }
            var entry: [String: Any] = [
                "block_id": blockID, "text": shownText, "takes": entries,
                "comments": comments[blockID] ?? [],
            ]
            if let name: String = placement["name"], !name.isEmpty { entry["name"] = name }
            blocks.append(entry)
        }
        return ["note_id": noteID, "title": title, "blocks": blocks]
    }
}
