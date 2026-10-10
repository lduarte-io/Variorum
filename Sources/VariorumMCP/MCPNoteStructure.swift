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
/// caller's transaction), and ∝ the note — never the corpus.
///
/// **U3 grows it (the wire-document memo's shape, R-13nb-11/R-13nb-7):**
/// - `entry_date` where the note carries one (read-only here; set at create —
///   R-13nb-26 (b));
/// - `books`: the BOOKS holding the note that THIS CLIENT MAY READ, each with
///   the chapter it is filed under (AF-10 (f): a book the grant does not
///   reach keeps its name — names stay with grants; a dangling chapter
///   pointer reads unsectioned, the app's own rule);
/// - **`with_commits`** (R-13nb-7 — commits reached BY EXPLICIT ASK, never
///   ambient, never in the Level 0 text): each take carries its commits
///   newest first (`commit_id`, `kind`, `message`, `created_at`, `length`,
///   `text`). Texts ride newest-first ACROSS the note until the answer
///   carries `commitTextBudget` characters of them; a commit past that says
///   `text_omitted: true` and is fetched by id (`commit_ids`, ≤20 per call,
///   always with text) — a bounded answer with complete reach (AF-10 (d)).
enum MCPNoteStructure {
    /// What the caller asked for beyond the blocks.
    struct Options: Sendable {
        var withCommits = false
        /// Commits whose text rides whatever the budget (validated to be
        /// commits of THIS note's takes).
        var commitIDs: [String] = []
    }

    /// The characters of commit text one answer carries before later
    /// commits say `text_omitted` (AF-10 (d)).
    static let commitTextBudget = 100_000
    static let maxCommitIDs = 20

    static func read(
        _ db: Database, noteID: String, calendar: Calendar,
        standing: MCPGrantAuthority.Standing? = nil, options: Options = Options()
    ) throws -> [String: Any] {
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
        let commitLists = options.withCommits || !options.commitIDs.isEmpty
            ? try commits(db, takeIDs: takes.values.flatMap { $0.map { $0["id"] as String } }, options: options)
            : nil
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
                if let commitLists { entry["commits"] = commitLists[id] ?? [] }
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
        var answer: [String: Any] = ["note_id": noteID, "title": title, "blocks": blocks]
        if let entryDate = try String.fetchOne(
            db, sql: "SELECT entry_date FROM container WHERE id = ?", arguments: [noteID]), !entryDate.isEmpty {
            answer["entry_date"] = entryDate
        }
        if let standing {
            answer["books"] = try books(db, noteID: noteID, standing: standing)
        }
        return answer
    }

    /// The books holding the note that this client may READ, with each
    /// membership's chapter (a dangling pointer reads unsectioned).
    static func books(
        _ db: Database, noteID: String, standing: MCPGrantAuthority.Standing
    ) throws -> [[String: Any]] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.name, s.id AS section_id, s.name AS section_name
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                LEFT JOIN reading_section s
                  ON s.id = rp.section_id AND s.deleted_at IS NULL AND s.reading_id = rp.reading_id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY r.name COLLATE NOCASE, r.id
                """,
            arguments: [noteID]
        ).compactMap { row -> [String: Any]? in
            let bookID: String = row["id"]
            guard MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .read
            ).isAllowed else { return nil }
            var entry: [String: Any] = ["book_id": bookID, "name": row["name"] as String]
            if let sectionID: String = row["section_id"] {
                entry["section_id"] = sectionID
                entry["section_name"] = row["section_name"] as String
            }
            return entry
        }
    }

    /// Each take's commits, newest first, with texts riding newest-first
    /// across the note until the budget is spent; `commitIDs` always ride
    /// with text and must be commits of these takes.
    static func commits(
        _ db: Database, takeIDs: [String], options: Options
    ) throws -> [String: [[String: Any]]] {
        let json = String(decoding: try JSONEncoder().encode(takeIDs), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.variant_id, c.kind, c.message, c.created_at, c.text FROM json_each(?) j
                JOIN commit_point c ON c.variant_id = j.value
                ORDER BY c.created_at DESC, c.id DESC
                """,
            arguments: [json])
        let known = Set(rows.map { $0["id"] as String })
        if let stranger = options.commitIDs.first(where: { !known.contains($0) }) {
            throw MCPReadTools.ArgumentFailure(message: "commit_id \(stranger) isn't a commit of this note.")
        }
        let asked = Set(options.commitIDs)
        var budget = commitTextBudget
        var lists: [String: [[String: Any]]] = [:]
        for row in rows {
            let id: String = row["id"]
            let text: String = row["text"]
            var entry: [String: Any] = [
                "commit_id": id, "kind": row["kind"] as String, "created_at": row["created_at"] as String,
                "length": text.count,
            ]
            if let message: String = row["message"] { entry["message"] = message }
            if asked.contains(id) {
                entry["text"] = text
            } else if text.count <= budget {
                entry["text"] = text
                budget -= text.count
            } else {
                entry["text_omitted"] = true
                budget = 0
            }
            lists[row["variant_id"], default: []].append(entry)
        }
        return lists
    }
}
