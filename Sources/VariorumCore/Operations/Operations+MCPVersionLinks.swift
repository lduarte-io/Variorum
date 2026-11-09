import Dependencies
import Foundation
import GRDB

// A CLIENT LINKING TWO NOTES AS VERSIONS (VX-184 U3 — VX-187; her ruling
// R-VX187-1 in `notes/plans/mcp-launch-polish-kickoff.md`: the AI NAMES the
// paragraph pairs — at least one {block_a, block_b} across the two notes,
// never positional guessing). Posts are edges-only across versions (I8, I9):
// every pair is ONE `version_of` edge minted through her own road
// (`insertVersionOfEdge` — stored canonically `(min(id), max(id))`, a self-link
// and a live duplicate refused), `origin_op 'manual'` (her mark's own value).
// ONE linked pair makes the notes version peers (`Queries.versionPeerPosts`
// matches ANY live `version_of` edge between their placed blocks), so Compare
// offers each beside the other. Who may link is the server's decision (handed
// in as the guard); this act decides nothing about clients.
extension Operations {
    /// One named pair: `blockA` a block of the first note, `blockB` of the second.
    public struct MCPVersionPair: Equatable, Sendable {
        public var blockA: String
        public var blockB: String

        public init(blockA: String, blockB: String) {
            self.blockA = blockA
            self.blockB = blockB
        }
    }

    /// Why a link refused, naming the pair where one is at fault.
    public enum MCPVersionLinkRefusal: Error, Equatable, Sendable {
        case sameNote
        /// The two notes live in different wings (each wing a separate
        /// library — her own picker never offers another wing's note).
        case differentWings
        /// `side` "a" or "b": that pair's block is not a live block of its note.
        case blockNotInNote(index: Int, side: String)
        case repeatedPair(index: Int)
        /// A live `version_of` edge already joins that pair's blocks.
        case alreadyLinked(index: Int)
    }

    /// **`link_versions`' act** — ONE transaction: the caller's guard first;
    /// both notes live posts, distinct, in the same wing (as surfaces read
    /// wings — a dangling pointer is Home's); then each pair in order — its
    /// blocks live and placed in their notes, never a repeat — minted through
    /// `insertVersionOfEdge` (a pair already linked refuses the whole act,
    /// named). A link writes no text: free under a seal, as her mark is; no
    /// touch, no churn. ONE undo entry, `undoLabel`: exactly the minted edges
    /// tombstoned on one stamp; the redo revives exactly the edges that died
    /// on that stamp (a live twin of the pair keeps the pair; a dead block
    /// keeps its edge dead).
    @discardableResult
    public func linkVersionsForClient(
        noteA: String, noteB: String, pairs: [MCPVersionPair], undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> [Edge] {
        let edges: [Edge] = try database.write { db in
            try guardian?(db)
            let a = try livePost(db, noteA)
            let b = try livePost(db, noteB)
            guard a.id != b.id else { throw MCPVersionLinkRefusal.sameNote }
            guard try sameEffectiveWing(db, a.wingId, b.wingId) else { throw MCPVersionLinkRefusal.differentWings }
            let now = date.now
            var seen = Set<[String]>()
            var minted: [Edge] = []
            for (index, pair) in pairs.enumerated() {
                for (side, block, note) in [("a", pair.blockA, noteA), ("b", pair.blockB, noteB)] {
                    guard (try? liveBlock(db, block)) != nil,
                          try livePlacement(db, blockID: block)?.containerId == note
                    else { throw MCPVersionLinkRefusal.blockNotInNote(index: index, side: side) }
                }
                guard seen.insert([pair.blockA, pair.blockB]).inserted else {
                    throw MCPVersionLinkRefusal.repeatedPair(index: index)
                }
                do {
                    minted.append(try insertVersionOfEdge(db, pair.blockA, pair.blockB, originOp: "manual", now: now))
                } catch OperationError.versionLinkExists {
                    throw MCPVersionLinkRefusal.alreadyLinked(index: index)
                }
            }
            return minted
        }
        let ids = edges.map(\.id)
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertVersionLinks(ids) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyVersionLinks(ids, undoneOn: undoneOn.value) })
        return edges
    }

    /// The inverse: every still-live minted edge tombstoned on ONE stamp;
    /// that stamp, or nil when every edge was already gone.
    func revertVersionLinks(_ ids: [String]) throws -> String? {
        try database.write { db in
            let stamp = DateFormatter.variorumISO8601.string(from: date.now)
            return try Self.tombstoneVersionEdges(db, ids, stamp: stamp) ? stamp : nil
        }
    }

    /// **THE ONE TOMBSTONE a client's version-link edges take** (VX-943 —
    /// `revertVersionLinks`' statement, lifted so `unlink_versions`' act
    /// writes through it too): each still-live edge of `ids` dies on `stamp`;
    /// true when any did. An ordinary update of a synced table — its outbox
    /// trigger carries it, exactly as her own unmark's tombstone.
    static func tombstoneVersionEdges(_ db: Database, _ ids: [String], stamp: String) throws -> Bool {
        var wrote = false
        for id in ids {
            try db.execute(
                sql: "UPDATE edge SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL", arguments: [stamp, id])
            wrote = wrote || db.changesCount > 0
        }
        return wrote
    }

    /// The redo: the edges that died on the undo's stamp, back — each only
    /// while both its blocks live and no live twin joins the pair.
    @discardableResult
    func reapplyVersionLinks(_ ids: [String], undoneOn stamp: String?) throws -> Bool {
        guard let stamp else { return false }
        return try database.write { db in
            var revived = false
            for id in ids {
                guard let row = try Row.fetchOne(
                    db,
                    sql: """
                        SELECT e.source_block_id, e.target_block_id FROM edge e
                        JOIN block s ON s.id = e.source_block_id AND s.deleted_at IS NULL
                        JOIN block t ON t.id = e.target_block_id AND t.deleted_at IS NULL
                        WHERE e.id = ? AND e.deleted_at = ?
                        """,
                    arguments: [id, stamp])
                else { continue }
                let twin = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM edge WHERE type = 'version_of' AND deleted_at IS NULL
                          AND source_block_id = ? AND target_block_id = ?)
                        """,
                    arguments: [row["source_block_id"] as String, row["target_block_id"] as String]) ?? false
                guard !twin else { continue }
                try db.execute(sql: "UPDATE edge SET deleted_at = NULL WHERE id = ?", arguments: [id])
                try voidPurgeIntents(db, table: "edge", rowID: id)
                revived = true
            }
            return revived
        }
    }
}

// A CLIENT UNLINKING ONE VERSION LINK (VX-943 — her relay: "an unlink_versions
// that takes the ID link_versions already returns, at the same permission
// level"; the run record `notes/plans/fixes/vx-915-recents-sweep.md` BATCH 6).
// `link_versions` answers each pair's `edge_id`, and no other wire answer
// carries an edge id — so this act takes back exactly one link a client made.
// Its semantic reference is her own unmark in Compare
// (`unmarkPostsAsVersions` — a bare tombstone of the link, both notes
// untouched), with that door's one exception kept: a link that ties a note to
// one of its SAVED VERSIONS is never bare-unlinked (her door promotes the
// version after a confirm instead, because a bare unlink declassifies it —
// `Queries.versionHistoryPredicate`), so here it REFUSES. Who may unlink is the
// server's decision (handed in as the guard); this act decides nothing about
// clients.
extension Operations {
    /// Why an unlink refused.
    public enum MCPVersionUnlinkRefusal: Error, Equatable, Sendable {
        /// The id names no `version_of` link between two notes' placed blocks.
        case noSuchLink
        /// The link ties a note to one of its saved versions (her door
        /// promotes there; the wire never bare-unlinks one).
        case savedVersion
        /// The link is already tombstoned.
        case alreadyUnlinked
    }

    /// What one unlink did: the link's two ends as it found them, and whether
    /// ANOTHER live link still makes the two notes versions of each other
    /// (Compare's peer read — a multi-pair link answered several ids).
    public struct MCPVersionUnlink: Equatable, Sendable {
        public let ends: Queries.MCPVersionLinkEnds
        public let stillVersions: Bool
    }

    /// **`unlink_versions`' act** — ONE transaction: the caller's guard first;
    /// then the link by its id (`Queries.mcpVersionLinkEnds` — a `version_of`
    /// edge whose two blocks are live and placed in live notes); a link that
    /// ties a note to one of its saved versions refuses (`savedVersion`), a
    /// dead one refuses (`alreadyUnlinked`); then the edge tombstoned through
    /// THE one statement (`tombstoneVersionEdges`). A link writes no text:
    /// free under a seal, as her unmark is; no touch, no churn; no wing rule
    /// (her unmark has none). ONE undo entry, `undoLabel` — VX-276's posture:
    /// the inverse revives exactly that edge, and only while it is still dead
    /// on the act's OWN stamp with both blocks live and no live twin
    /// (`reapplyVersionLinks`; quiet and retired otherwise); the redo
    /// tombstones it again only while it is live (`revertVersionLinks`),
    /// re-stamping for the next undo.
    @discardableResult
    public func unlinkVersionForClient(
        _ edgeID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPVersionUnlink {
        let (unlink, stamp): (MCPVersionUnlink, String) = try database.write { db in
            try guardian?(db)
            guard let ends = try Queries.mcpVersionLinkEnds(db, edgeID: edgeID) else {
                throw MCPVersionUnlinkRefusal.noSuchLink
            }
            guard try Queries.mcpSavedVersionNote(db, of: ends) == nil else {
                throw MCPVersionUnlinkRefusal.savedVersion
            }
            guard ends.live else { throw MCPVersionUnlinkRefusal.alreadyUnlinked }
            let stamp = DateFormatter.variorumISO8601.string(from: date.now)
            _ = try Self.tombstoneVersionEdges(db, [edgeID], stamp: stamp)
            let still = try Queries.notesShareALiveVersionLink(db, ends.noteIDs[0], ends.noteIDs[1])
            return (MCPVersionUnlink(ends: ends, stillVersions: still), stamp)
        }
        let unlinkedOn = LockIsolated<String?>(stamp)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reapplyVersionLinks([edgeID], undoneOn: unlinkedOn.value) },
            redo: { ops in
                guard let stamp = try ops.revertVersionLinks([edgeID]) else { return false }
                unlinkedOn.setValue(stamp)
                return true
            })
        return unlink
    }
}

extension Queries {
    /// **A version link's two ends, by its edge id** (VX-943): the `version_of`
    /// edge, live or dead, whose two blocks are LIVE and live-placed in live
    /// NOTES — nil for anything else (no such row, another edge type, an end
    /// released to lineage, in a scraps group, or gone). `blockIDs` and
    /// `noteIDs` are parallel, in the link's stored order (source, then
    /// target — the canonical `(min(id), max(id))`). ∝ one edge: its key, its
    /// two blocks' keys and their one live placement each (`uq_cblock_ownership`).
    public struct MCPVersionLinkEnds: Equatable, Sendable {
        public let edgeID: String
        public let live: Bool
        public let blockIDs: [String]
        public let noteIDs: [String]
    }

    public static func mcpVersionLinkEnds(_ db: Database, edgeID: String) throws -> MCPVersionLinkEnds? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT e.source_block_id, e.target_block_id, (e.deleted_at IS NULL) AS live,
                       sp.container_id AS source_note, tp.container_id AS target_note
                FROM edge e
                CROSS JOIN block s ON s.id = e.source_block_id AND s.deleted_at IS NULL
                CROSS JOIN block t ON t.id = e.target_block_id AND t.deleted_at IS NULL
                CROSS JOIN container_block sp ON sp.block_id = s.id AND sp.deleted_at IS NULL
                CROSS JOIN container_block tp ON tp.block_id = t.id AND tp.deleted_at IS NULL
                CROSS JOIN container sc ON sc.id = sp.container_id AND sc.deleted_at IS NULL AND sc.kind = 'post'
                CROSS JOIN container tc ON tc.id = tp.container_id AND tc.deleted_at IS NULL AND tc.kind = 'post'
                WHERE e.id = ? AND e.type = 'version_of'
                """,
            arguments: [edgeID])
        else { return nil }
        return MCPVersionLinkEnds(
            edgeID: edgeID, live: row["live"],
            blockIDs: [row["source_block_id"], row["target_block_id"]],
            noteIDs: [row["source_note"], row["target_note"]])
    }

    /// **Does this link tie a note to one of its SAVED VERSIONS?** The NOTE's
    /// id when one end's note is a saved version of the other's
    /// (`isVersionHistory` — the one classifier, asked of the named pair), nil
    /// otherwise. ∝ the pair's placements and their links.
    public static func mcpSavedVersionNote(_ db: Database, of ends: MCPVersionLinkEnds) throws -> String? {
        let (x, y) = (ends.noteIDs[0], ends.noteIDs[1])
        guard x != y else { return nil }
        if try isVersionHistory(db, x, of: y) { return y }
        if try isVersionHistory(db, y, of: x) { return x }
        return nil
    }

    /// **Do two notes still share a live version link?** — Compare's peer
    /// read (`versionPeerPosts`: any live `version_of` edge between a live
    /// placement of each), asked of one named pair and driven from `a`'s
    /// placements (`idx_cblock_order`) through each link direction
    /// (`idx_edge_source` / `idx_edge_target`) to the other end's one live
    /// placement (`uq_cblock_ownership`) — ∝ `a`'s blocks and their links,
    /// never the corpus (CROSS JOIN pins the loop order). A note is never its
    /// own version: false when `a == b`.
    public static func notesShareALiveVersionLink(_ db: Database, _ a: String, _ b: String) throws -> Bool {
        guard a != b else { return false }
        func arm(_ mine: String, _ theirs: String) -> String {
            """
            SELECT 1 FROM container_block pa
            CROSS JOIN edge e ON e.\(mine) = pa.block_id AND e.type = 'version_of' AND e.deleted_at IS NULL
            CROSS JOIN container_block pb ON pb.block_id = e.\(theirs) AND pb.deleted_at IS NULL
            WHERE pa.container_id = :a AND pa.deleted_at IS NULL AND pb.container_id = :b
            """
        }
        return try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (\(arm("source_block_id", "target_block_id")) UNION ALL "
                + "\(arm("target_block_id", "source_block_id")))",
            arguments: ["a": a, "b": b]) ?? false
    }
}
