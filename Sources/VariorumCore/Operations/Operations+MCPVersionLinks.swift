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
                if let stamp = try ops.revertVersionLinks(ids) { undoneOn.setValue(stamp) }
            },
            redo: { try $0.reapplyVersionLinks(ids, undoneOn: undoneOn.value) })
        return edges
    }

    /// The inverse: every still-live minted edge tombstoned on ONE stamp;
    /// that stamp, or nil when every edge was already gone.
    func revertVersionLinks(_ ids: [String]) throws -> String? {
        try database.write { db in
            let stamp = DateFormatter.variorumISO8601.string(from: date.now)
            var wrote = false
            for id in ids {
                try db.execute(
                    sql: "UPDATE edge SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL", arguments: [stamp, id])
                wrote = wrote || db.changesCount > 0
            }
            return wrote ? stamp : nil
        }
    }

    /// The redo: the edges that died on the undo's stamp, back — each only
    /// while both its blocks live and no live twin joins the pair.
    func reapplyVersionLinks(_ ids: [String], undoneOn stamp: String?) throws {
        guard let stamp else { return }
        try database.write { db in
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
            }
        }
    }
}
