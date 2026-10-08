import Foundation
import GRDB

// **VX-84a — A `#tag` TYPED ALONE NARROWS THE LIBRARY** (the 13o follow-up run,
// VX-83; her report: *"classics are not showing notes tagged classics, in fact
// searching a tag is not revealing the notes tagged that at all"*; the
// provisional call D-1 in `notes/plans/fixes/vx-83-search-followup.md`).
//
// The notes half rides the catalog's own paged listing (`catalogNotesPage`'s
// `narrowing`); this file is the BLOCKS half — the Blocks scope, by BLOCK-level
// tags (block tags "primarily serve the pool", AppSpec §7) — read through the
// ONE composer's narrowing (R-13o-8), never a re-derived tag walk.
extension Queries {
    /// **The blocks a text-less tag question names** — every live, PLACED
    /// block carrying a typed tag at block level (each `#path`'s subtree,
    /// several tags intersecting), in the current wing — scraps homes in every
    /// wing (the shared room, P-13o-U1-5) — under the question's archived
    /// facet, as the catalog's own block hits (handle · its home), newest edit
    /// first (`catalogBlocks`' own order).
    ///
    /// The answer is a SET, answered whole (the day's precedent — a set has no
    /// honest cap): DRIVEN from the tag's block applications, so its cost is ∝
    /// those applications, never ∝ the corpus. A released block has no home to
    /// land in and never lists (P-13o-U1-8's letter). Empty when the question
    /// has words or no typed tag.
    public static func catalogTaggedBlocks(
        _ db: Database, narrowing question: SearchQuery, wingID: String,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> [CatalogHit] {
        guard let narrowing = SearchComposer.listingNarrowing(
            question, kind: .blocks, wingID: wingID, environment: try searchEnvironment(db))
        else { return [] }
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT b.id AS id, b.name AS name,
                       SUBSTR(COALESCE(\(renderedTakeTextSQL), ''), 1, 240) AS text,
                       c.id AS home_id, c.kind AS home_kind, c.title AS home_title,
                       c.entry_date AS home_entry_date, c.created_at AS home_created_at
                FROM (\(narrowing.driver)) t
                CROSS JOIN block b ON b.id = t.tagged_id
                JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                JOIN container c ON c.id = cb.container_id
                \(renderedTakeJoinSQL)
                WHERE \(narrowing.conditions)
                ORDER BY b.updated_at DESC, b.id DESC
                """,
            arguments: arguments(narrowing.driverArguments + narrowing.conditionArguments))
        return rows.map { row in
            let isPool = (row["home_kind"] as String) == "pool"
            let home: String = isPool
                ? DisplayTitle.pool(title: row["home_title"], createdAtStamp: row["home_created_at"], calendar: calendar)
                : DisplayTitle.note(
                    title: row["home_title"], entryDate: row["home_entry_date"],
                    createdAt: row["home_created_at"], calendar: calendar)
            return CatalogHit(
                kind: .block, id: row["id"],
                title: blockHandle(name: row["name"], text: row["text"]),
                detail: home, homeContainerID: row["home_id"], homeIsPool: isPool)
        }
    }

    /// A listed block's handle: its NAME when it has one, else the first line
    /// of words its rendered take holds (the catalog's "first-line handle"),
    /// else the word "block".
    static func blockHandle(name: String?, text: String?) -> String {
        if let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty { return name }
        let line = (text ?? "").split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty }
        return line.map { String($0.prefix(80)) } ?? "block"
    }
}
