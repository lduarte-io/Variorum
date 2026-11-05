import Foundation
import GRDB

// **IS A TAG STILL WORN? — THE ONE BRAIN** (VX-825, the VX-809 run, batch 1 —
// A-809-9; shared with VX-840's Settings ▸ Tags unused-tag sweep, built in
// VX-828's run: both doors consume THIS predicate, never a twin).
//
// A tag is WORN while it — or any live tag under it (its subtree, by the
// materialized path: `deleteTag` deletes the subtree, so a tag whose child is
// worn is never "unused") — has a live application on a wearer the SCOPE
// counts:
// - a NOTE wears it through a live `post_tag` row on a live post;
// - a BLOCK wears it through a live `block_tag` row on a live block; on the
//   wire a block counts only through the live note that places it (a snippet
//   — a pool's block — or an unplaced block is reachable by no client).
//
// The SCOPE decides which wearers count:
// - `.library` — her own surface: every live wearer in the library, snippets
//   included. `countingTrashRevivable` (VX-840's Trash judgment — A-809-1's
//   lean, TRANSFERRED with VX-840 to VX-828, theirs to pass): also count an
//   application a restore would bring back — a tombstoned row on the exact
//   stamp of its tombstoned (not purged) wearer, the cascade victims
//   `restoreContainer` / `restoreBlock` revive;
// - `.reach` — the MCP door (her R-825: an answer is a pure function of the
//   client's reachable state): only wearers whose NOTE `readable` admits. The
//   closure takes candidate note ids in batches and answers the ones the
//   client can read; nothing else about the library enters the answer, so a
//   tag worn only by notes the client can't reach is "unused" to it exactly as
//   in a store where those notes do not exist. Trashed notes are reachable by
//   no client (the Trash is not the wire's), so `.reach` never counts them.
//
// P1: ∝ the subtree's applications, read in pages; `.reach` stops at the
// first readable wearer.
extension Queries {
    /// Which wearers of a tag count (see the file's head).
    public enum TagWearerScope {
        /// Her surface — every live wearer; optionally the Trash's revivable ones.
        case library(countingTrashRevivable: Bool)
        /// The wire — only wearers whose note the closure admits (batches of
        /// candidate note ids in, the readable ones out).
        case reach(readable: ([String]) throws -> Set<String>)
    }

    /// **Is `tagID` — or any live tag under it — worn by a wearer `scope`
    /// counts?** A missing or tombstoned tag is worn by nothing (false).
    public static func tagSubtreeIsWorn(
        _ db: Database, tagID: String, scope: TagWearerScope
    ) throws -> Bool {
        let subtree = try tagSubtree(db, rootID: tagID).map(\.id)
        guard !subtree.isEmpty else { return false }
        let tags = try json(subtree)
        switch scope {
        case .library(let countingTrashRevivable):
            let live = try Bool.fetchOne(db, sql: """
                SELECT EXISTS (
                    SELECT 1 FROM json_each(?) j
                    JOIN post_tag pt ON pt.tag_id = j.value AND pt.deleted_at IS NULL
                    JOIN container c ON c.id = pt.post_id AND c.deleted_at IS NULL
                ) OR EXISTS (
                    SELECT 1 FROM json_each(?) j
                    JOIN block_tag bt ON bt.tag_id = j.value AND bt.deleted_at IS NULL
                    JOIN block b ON b.id = bt.block_id AND b.deleted_at IS NULL
                )
                """, arguments: [tags, tags]) ?? false
            guard !live, countingTrashRevivable else { return live }
            return try Bool.fetchOne(db, sql: """
                SELECT EXISTS (
                    SELECT 1 FROM json_each(?) j
                    JOIN post_tag pt ON pt.tag_id = j.value AND pt.deleted_at IS NOT NULL
                    JOIN container c ON c.id = pt.post_id AND c.deleted_at = pt.deleted_at
                ) OR EXISTS (
                    SELECT 1 FROM json_each(?) j
                    JOIN block_tag bt ON bt.tag_id = j.value AND bt.deleted_at IS NOT NULL
                    JOIN block b ON b.id = bt.block_id AND b.deleted_at = bt.deleted_at
                )
                """, arguments: [tags, tags]) ?? false
        case .reach(let readable):
            // Every live note wearing a tag of the subtree, itself or through
            // a block it places — keyset-paged on the note id, each page asked
            // of the closure; the first readable wearer answers.
            var after = ""
            while true {
                let page = try String.fetchAll(db, sql: """
                    SELECT wearers.id FROM (
                        SELECT pt.post_id AS id FROM json_each(:tags) j
                        JOIN post_tag pt ON pt.tag_id = j.value AND pt.deleted_at IS NULL
                        UNION
                        SELECT cb.container_id AS id FROM json_each(:tags) j
                        JOIN block_tag bt ON bt.tag_id = j.value AND bt.deleted_at IS NULL
                        JOIN block b ON b.id = bt.block_id AND b.deleted_at IS NULL
                        JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                    ) wearers
                    JOIN container c ON c.id = wearers.id AND c.deleted_at IS NULL AND c.kind = 'post'
                    WHERE wearers.id > :after
                    ORDER BY wearers.id
                    LIMIT \(Self.tagWearerPage)
                    """, arguments: ["tags": tags, "after": after])
                guard let last = page.last else { return false }
                if try !readable(page).isEmpty { return true }
                after = last
            }
        }
    }

    /// The `.reach` walk's page size.
    static let tagWearerPage = 200

    private static func json(_ ids: [String]) throws -> String {
        String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
    }
}
