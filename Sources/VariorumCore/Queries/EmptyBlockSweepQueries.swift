import Foundation
import GRDB

// **THE TRASH'S EMPTY-BLOCK SWEEP — the read side** (VX-800; R-828-1 read row
// by row at the VX-828 batch D fork and ruled there —
// `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch D — THE FORK'S
// RULING"). The rule itself is `Domain/EmptyBlockSweep`; this file gathers
// its facts and names the candidates, for the door's count (a held
// observation), its confirm, and the act's in-transaction re-check
// (`Operations.sweepEmptyTrashBlocks`) — one read, three readers.
extension Queries {
    /// **The sweep's candidates that qualify**, in the Trash's own order
    /// (newest first) — the ids the door counts and the confirm carries.
    ///
    /// The candidate set is EXACTLY the Trash's own block rows — the block
    /// arm of `Queries.trash`, unwindowed and never narrowed by the kind
    /// picker (the door is over this wing's whole Trash, Empty Trash's
    /// scope). Reusing the arm, never a twin, inherits: the 30-day window;
    /// the wing fence (`wingID` exactly as `trash` reads it — nil = every
    /// wing); the stamp-aware purge-intent fence (a row already going is
    /// never re-taken); and, load-bearing, the CASCADE-VICTIM EXCLUSION — a
    /// block that died WITH its note is part of that note's one row, so it is
    /// never swept alone and a note's whole Put back is never broken by this
    /// door.
    ///
    /// Cost: the block arm's one window scan of `block` (the listing pays the
    /// same) plus indexed per-candidate counts — ∝ the Trash's block rows, a
    /// summoned surface's read, never the corpus (P1).
    public static func emptyTrashBlocks(
        _ db: Database, now: Date, wingID: String? = nil
    ) throws -> [String] {
        let listed = try trash(db, now: now, kinds: [.block], wingID: wingID).map(\.id)
        guard !listed.isEmpty else { return [] }
        return try emptyBlockSweepFacts(db, blockIDs: listed)
            .filter(EmptyBlockSweep.qualifies)
            .map(\.blockID)
    }

    /// **The counted facts of each named block, in the order given** (a
    /// missing id is simply absent). Each count's row-level reading is the
    /// ruled one (R-828-1 / P-828-7…9):
    /// - `worded_takes` — EVERY variant row of the block, any status, any
    ///   tombstone (the purge family takes all of them), whose text is not
    ///   zero-length (`working_text <> ''` — the carve's empty test; a
    ///   whitespace-only take is worded);
    /// - `savepoints` — `commit_point` rows on any of those variants;
    /// - `comments` — ANY `block_comment` row, live or tombstoned;
    /// - `name` / `presentation` — the stored columns, verbatim (any non-NULL
    ///   value counts);
    /// - `living_links` — edge rows of ANY type and ANY edge tombstone with
    ///   the block on one side and a block that is not deleted on the other
    ///   (a self-edge excluded; a dead or absent other side never counts).
    ///   Two sums rather than one `OR`, so each side seeks its own index
    ///   (`idx_edge_source`, `idx_edge_target`).
    public static func emptyBlockSweepFacts(
        _ db: Database, blockIDs: [String]
    ) throws -> [EmptyBlockSweep.Facts] {
        guard !blockIDs.isEmpty else { return [] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        let rows = try Row.fetchAll(db, sql: emptyBlockSweepFactsSQL, arguments: [json])
        let byID = Dictionary(
            rows.map { row -> (String, EmptyBlockSweep.Facts) in
                let id: String = row["block_id"]
                return (id, EmptyBlockSweep.Facts(
                    blockID: id,
                    wordedTakes: row["worded_takes"],
                    savepoints: row["savepoints"],
                    comments: row["comments"],
                    name: row["name"],
                    presentation: row["presentation"],
                    livingLinks: row["living_links"]))
            },
            uniquingKeysWith: { first, _ in first })
        var seen = Set<String>()
        return blockIDs.compactMap { id in
            guard seen.insert(id).inserted else { return nil }
            return byID[id]
        }
    }

    /// The statement `emptyBlockSweepFacts` runs. The given ids drive
    /// (`CROSS JOIN` — SQLite never reorders one), each block found by its
    /// primary key, every count a correlated indexed read.
    static let emptyBlockSweepFactsSQL = """
        SELECT b.id AS block_id, b.name AS name, b.presentation AS presentation,
          (SELECT COUNT(*) FROM variant v
            WHERE v.block_id = b.id AND v.working_text <> '') AS worded_takes,
          (SELECT COUNT(*) FROM commit_point cp
            WHERE cp.variant_id IN (SELECT v.id FROM variant v WHERE v.block_id = b.id))
            AS savepoints,
          (SELECT COUNT(*) FROM block_comment bc WHERE bc.block_id = b.id) AS comments,
          (SELECT COUNT(*) FROM edge e JOIN block o ON o.id = e.target_block_id
            WHERE e.source_block_id = b.id AND o.id <> b.id AND o.deleted_at IS NULL)
          + (SELECT COUNT(*) FROM edge e JOIN block o ON o.id = e.source_block_id
            WHERE e.target_block_id = b.id AND o.id <> b.id AND o.deleted_at IS NULL)
            AS living_links
        FROM json_each(?) j
        CROSS JOIN block b ON b.id = j.value
        """

    /// **Every table the sweep's read touches, in any arm, under any fence**
    /// — its held observation's NAMED region (the `trashTables` discipline,
    /// VX-670): the Trash's block arm (`block`, `variant` for the row's text,
    /// `container` for the home and the wing, `container_block` for the
    /// cascade test, `purge_intent` for the fence, `wing` for Home's fence)
    /// and the facts (`variant`, `commit_point`, `block_comment`, `edge`,
    /// `block`). Pinned EXACT against the regions GRDB derives from every
    /// statement the read runs (`EmptyBlockSweepTests`).
    public static let emptyBlockSweepTables: [String] = [
        "block", "variant", "container", "container_block", "purge_intent", "wing",
        "commit_point", "block_comment", "edge",
    ]
}

extension AppDatabase {
    /// **The sweep's qualifying ids, live** — the Trash door's count and its
    /// confirm's ids (VX-800). Woken by NAMED tables (`observe(tracking:)`),
    /// so its re-fetch runs on a READER after a commit, never on the writer
    /// inside one (VX-670's lesson: the open Trash must never make a write
    /// wait for its reads).
    public func observeEmptyTrashBlocks(
        now: Date, wingID: String? = nil
    ) -> AsyncValueObservation<[String]> {
        observe(tracking: Queries.emptyBlockSweepTables.map { Table($0) }) {
            try Queries.emptyTrashBlocks($0, now: now, wingID: wingID)
        }
    }
}
