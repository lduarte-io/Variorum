import Foundation
import GRDB

// VX-827 U1 (the run record `notes/plans/fixes/vx-827-lineage.md` U1 RECORD) —
// ONE block's whole lineage, the read VX-801's lineage door (U3) draws: every
// ancestor and descendant over `derived_from`, the block's `version_of`
// siblings, each node's state and the text it shows. The note-level sibling is
// `lineagePeers` (LineagePeers.swift).
extension Queries {
    /// **Where a lineage node stands now.**
    public enum LineageBlockState: Equatable, Sendable {
        /// Live and placed in a container (a note — or a pool, the Snippets).
        case placed(containerID: String)
        /// Live, unplaced, not archived: preserved as lineage (a divide-W's
        /// whole original, a merge's released sources) — `last_container_id`
        /// names the note it was released from, when it has one.
        case preserved(lastContainerID: String?)
        /// Live, unplaced and ARCHIVED — a set-aside she chose (the tray's
        /// "kept aside"; 13j batch 6: never a leftover, its own road is the
        /// tray's Put back).
        case archived(lastContainerID: String?)
        /// Tombstoned — the Trash's business (whether it still LISTS there is
        /// the Trash window's and the purge fence's question, not this read's).
        case deleted(deletedAt: String, lastContainerID: String?)
        /// An edge names a block id with no row (a purged block, sync debris):
        /// walked through, never described.
        case missing
    }

    /// The container a node lives in or was last in — what a surface needs to
    /// name it.
    public struct LineageHome: Equatable, Sendable {
        public let containerID: String
        public let kind: ContainerKind
        /// The display name (`DisplayTitle.note` / `.pool` — never a write).
        public let title: String
        public let wingID: String
        /// The container is itself tombstoned.
        public let isDeleted: Bool
        /// A saved version of a note (born archived — AppSpec §9's classifier).
        public let isSavedVersion: Bool

        public init(
            containerID: String, kind: ContainerKind, title: String, wingID: String,
            isDeleted: Bool, isSavedVersion: Bool
        ) {
            self.containerID = containerID
            self.kind = kind
            self.title = title
            self.wingID = wingID
            self.isDeleted = isDeleted
            self.isSavedVersion = isSavedVersion
        }
    }

    /// **One edge inside a lineage tree.** `derived_from` reads "source is
    /// derived from target" (AppSpec §7); `version_of` is stored canonically.
    public struct LineageTreeEdge: Equatable, Sendable {
        public let id: String
        public let sourceBlockID: String
        public let targetBlockID: String
        public let type: EdgeType
        public let originOp: String?
        public let createdAt: String
        /// Non-nil only for an edge tombstoned WITH one of its endpoint blocks
        /// (the delete cascade's exact stamp) — the one kind of tombstoned edge
        /// a tree walks; it revives when that block is put back.
        public let deletedAt: String?

        public init(
            id: String, sourceBlockID: String, targetBlockID: String, type: EdgeType,
            originOp: String?, createdAt: String, deletedAt: String?
        ) {
            self.id = id
            self.sourceBlockID = sourceBlockID
            self.targetBlockID = targetBlockID
            self.type = type
            self.originOp = originOp
            self.createdAt = createdAt
            self.deletedAt = deletedAt
        }
    }

    /// **One node of a lineage tree.**
    public struct LineageTreeNode: Equatable, Sendable {
        public enum Direction: String, Equatable, Sendable {
            /// The block the tree was asked about (depth 0).
            case origin
            /// Something the origin was derived from.
            case ancestor
            /// Something derived from the origin.
            case descendant
            /// A `version_of` sibling of the origin (depth 1).
            case version
        }

        public let blockID: String
        public let direction: Direction
        /// Shortest edge distance from the origin (0 for the origin itself).
        public let depth: Int
        /// The edge that reaches this node from one a step nearer the origin
        /// on a shortest path (the smallest such neighbour's id, then the
        /// smallest edge id) — nil for the origin. `edges` holds every other.
        public let via: LineageTreeEdge?
        public let state: LineageBlockState
        /// Where it lives (placed) or last lived (unplaced, deleted); nil when
        /// it has no container to name, or no row.
        public let home: LineageHome?
        /// The take it shows and that take's text: a placed block's chosen
        /// take (live, active, on this block), else the block's default take;
        /// a deleted block's default take as it died with it (the Trash's
        /// rule). nil for a missing block.
        public let shownTakeID: String?
        public let text: String?

        public init(
            blockID: String, direction: Direction, depth: Int, via: LineageTreeEdge?,
            state: LineageBlockState, home: LineageHome?, shownTakeID: String?, text: String?
        ) {
            self.blockID = blockID
            self.direction = direction
            self.depth = depth
            self.via = via
            self.state = state
            self.home = home
            self.shownTakeID = shownTakeID
            self.text = text
        }

        /// The connecting edge's `origin_op` — what happened (nil at the
        /// origin, or on an edge minted without one).
        public var originOp: String? { via?.originOp }
    }

    /// **A whole lineage tree**: the origin, then every ancestor, every
    /// descendant and every `version_of` sibling, and every edge between them.
    public struct LineageTree: Equatable, Sendable {
        public let origin: LineageTreeNode
        /// Ancestors by (depth, block id), then descendants by (depth, block
        /// id), then version siblings by block id. A block on a cycle through
        /// the origin's lineage can appear once per direction.
        public let nodes: [LineageTreeNode]
        /// Every admitted edge the walks met, by id.
        public let edges: [LineageTreeEdge]

        public init(origin: LineageTreeNode, nodes: [LineageTreeNode], edges: [LineageTreeEdge]) {
            self.origin = origin
            self.nodes = nodes
            self.edges = edges
        }

        public var ancestors: [LineageTreeNode] { nodes.filter { $0.direction == .ancestor } }
        public var descendants: [LineageTreeNode] { nodes.filter { $0.direction == .descendant } }
        public var versions: [LineageTreeNode] { nodes.filter { $0.direction == .version } }
    }

    /// **The edge admission rule every lineage-tree walk reads** — a LIVE
    /// edge, or one tombstoned on the EXACT stamp of one of its endpoint
    /// blocks (the delete cascade, `cascade_block_tombstone`: the act still
    /// happened, and the edge revives with the block). An edge tombstoned on a
    /// stamp no endpoint shares — `unmarkPostsAsVersions`, `removeVersionOf`,
    /// sync debris — was taken apart on purpose and is not lineage. The
    /// `versionHistoryPredicate` edge fence, verbatim in meaning (the 13l
    /// exact-stamp doctrine).
    private static func admitted(_ e: String) -> String {
        """
        (\(e).deleted_at IS NULL OR EXISTS (
          SELECT 1 FROM block cascaded
          WHERE cascaded.id IN (\(e).source_block_id, \(e).target_block_id)
            AND cascaded.deleted_at = \(e).deleted_at))
        """
    }

    /// **One block's lineage tree** (VX-827 U1 — the read VX-801's lineage
    /// door draws): every ANCESTOR (walking `derived_from` source→target) and
    /// every DESCENDANT (target→source) of `blockID`, transitively, plus its
    /// direct `version_of` siblings; each node with its shortest depth, the
    /// edge that reaches it, its state (placed · preserved as lineage · set
    /// aside · deleted · missing), its home and the text it shows. nil when
    /// no block row has this id.
    ///
    /// Edges are admitted by `admitted` — live, or cascade-dead with a deleted
    /// endpoint — so a block in the Trash is IN its tree (and the tree walks
    /// through it to whatever it led to), while an edge taken apart on its own
    /// is not. A dead block's tree answers too. A missing row is walked
    /// through, never described. Cycles terminate: each walk is a ONE-column
    /// `UNION` set, every node visited once — the VX-654 lesson; a depth
    /// column in the recursion would revisit a node once per path length,
    /// quadratic in a seam history (⏎/⌫ rounds deepen the chain by one each).
    /// Depths and `via` come from a breadth-first pass in Swift over the
    /// fetched edges (linear in them).
    ///
    /// **Cost ∝ this block's own lineage — its ancestors, descendants and
    /// siblings and their edges — never the corpus (P1).** Each walk seeds
    /// from the origin by index (`idx_edge_source` / `idx_edge_target`), each
    /// set is MATERIALIZED and every join out of it driven by `CROSS JOIN`
    /// (`originalsStrandedBy`'s discipline); the node facts are primary-key
    /// and `uq_cblock_ownership` seeks over the visited ids. Pinned by
    /// `LineageTreeTests` (exact trees over every structural shape; the
    /// library-growth, seam-history and plan pins).
    public static func lineageTree(
        _ db: Database, blockID: String, calendar: Calendar = .current
    ) throws -> LineageTree? {
        let edgeColumns = "e.id, e.source_block_id, e.target_block_id, e.type, e.origin_op, e.created_at, e.deleted_at"
        let rows = try Row.fetchAll(
            db,
            sql: """
                WITH RECURSIVE anc(id) AS (
                  SELECT e.target_block_id FROM edge e
                  WHERE e.source_block_id = :origin AND e.type = 'derived_from' AND \(admitted("e"))
                  UNION
                  SELECT e.target_block_id FROM anc a
                  JOIN edge e ON e.source_block_id = a.id AND e.type = 'derived_from'
                  WHERE \(admitted("e"))
                ),
                upset(id) AS MATERIALIZED (SELECT :origin UNION SELECT id FROM anc),
                des(id) AS (
                  SELECT e.source_block_id FROM edge e
                  WHERE e.target_block_id = :origin AND e.type = 'derived_from' AND \(admitted("e"))
                  UNION
                  SELECT e.source_block_id FROM des dw
                  JOIN edge e ON e.target_block_id = dw.id AND e.type = 'derived_from'
                  WHERE \(admitted("e"))
                ),
                downset(id) AS MATERIALIZED (SELECT :origin UNION SELECT id FROM des)
                SELECT 'up' AS side, \(edgeColumns)
                FROM upset u CROSS JOIN edge e ON e.source_block_id = u.id AND e.type = 'derived_from'
                WHERE \(admitted("e"))
                UNION ALL
                SELECT 'down' AS side, \(edgeColumns)
                FROM downset dn CROSS JOIN edge e ON e.target_block_id = dn.id AND e.type = 'derived_from'
                WHERE \(admitted("e"))
                UNION ALL
                SELECT 'version' AS side, \(edgeColumns)
                FROM edge e
                WHERE e.source_block_id = :origin AND e.type = 'version_of' AND \(admitted("e"))
                UNION ALL
                SELECT 'version' AS side, \(edgeColumns)
                FROM edge e
                WHERE e.target_block_id = :origin AND e.type = 'version_of' AND \(admitted("e"))
                """,
            arguments: ["origin": blockID])

        var up: [LineageTreeEdge] = [], down: [LineageTreeEdge] = [], version: [LineageTreeEdge] = []
        var all: [String: LineageTreeEdge] = [:]
        for row in rows {
            let edge = LineageTreeEdge(
                id: row["id"], sourceBlockID: row["source_block_id"], targetBlockID: row["target_block_id"],
                type: EdgeType(rawValue: row["type"]) ?? .derivedFrom, originOp: row["origin_op"],
                createdAt: row["created_at"], deletedAt: row["deleted_at"])
            all[edge.id] = edge
            switch row["side"] as String {
            case "up": up.append(edge)
            case "down": down.append(edge)
            default: version.append(edge)
            }
        }

        // Breadth-first from the origin, one direction at a time: a node's
        // depth is the level it is first reached at, its `via` the edge from
        // the smallest-id neighbour one level nearer (then the smallest edge
        // id). Deterministic on every device.
        func breadthFirst(
            _ edges: [LineageTreeEdge], near: KeyPath<LineageTreeEdge, String>,
            far: KeyPath<LineageTreeEdge, String>
        ) -> [(id: String, depth: Int, via: LineageTreeEdge)] {
            let out = Dictionary(grouping: edges, by: { $0[keyPath: near] })
                .mapValues { $0.sorted { ($0[keyPath: far], $0.id) < ($1[keyPath: far], $1.id) } }
            var seen: Set<String> = [blockID]
            var frontier = [blockID]
            var reached: [(id: String, depth: Int, via: LineageTreeEdge)] = []
            var depth = 0
            while !frontier.isEmpty {
                depth += 1
                var best: [String: LineageTreeEdge] = [:]
                for node in frontier.sorted() {
                    for edge in out[node] ?? [] where !seen.contains(edge[keyPath: far]) {
                        if best[edge[keyPath: far]] == nil { best[edge[keyPath: far]] = edge }
                    }
                }
                let level = best.keys.sorted()
                for id in level { reached.append((id, depth, best[id]!)) }
                seen.formUnion(level)
                frontier = level
            }
            return reached
        }
        let ancestors = breadthFirst(up, near: \.sourceBlockID, far: \.targetBlockID)
        let descendants = breadthFirst(down, near: \.targetBlockID, far: \.sourceBlockID)
        var siblings: [String: LineageTreeEdge] = [:]
        for edge in version.sorted(by: { $0.id < $1.id }) {
            let other = edge.sourceBlockID == blockID ? edge.targetBlockID : edge.sourceBlockID
            if other != blockID, siblings[other] == nil { siblings[other] = edge }
        }

        // The node facts, one batched read over every id the walks met.
        var ids = Set([blockID])
        ids.formUnion(ancestors.map(\.id))
        ids.formUnion(descendants.map(\.id))
        ids.formUnion(siblings.keys)
        let facts = try lineageNodeFacts(db, ids: ids.sorted(), calendar: calendar)
        guard let originFacts = facts[blockID], originFacts.state != .missing else { return nil }

        func node(_ id: String, _ direction: LineageTreeNode.Direction, _ depth: Int, _ via: LineageTreeEdge?)
            -> LineageTreeNode
        {
            let fact = facts[id] ?? NodeFacts(state: .missing, home: nil, shownTakeID: nil, text: nil)
            return LineageTreeNode(
                blockID: id, direction: direction, depth: depth, via: via, state: fact.state,
                home: fact.home, shownTakeID: fact.shownTakeID, text: fact.text)
        }
        var nodes: [LineageTreeNode] = []
        nodes += ancestors.map { node($0.id, .ancestor, $0.depth, $0.via) }
        nodes += descendants.map { node($0.id, .descendant, $0.depth, $0.via) }
        nodes += siblings.keys.sorted().map { node($0, .version, 1, siblings[$0]) }
        return LineageTree(
            origin: node(blockID, .origin, 0, nil), nodes: nodes,
            edges: all.values.sorted { $0.id < $1.id })
    }

    private struct NodeFacts {
        let state: LineageBlockState
        let home: LineageHome?
        let shownTakeID: String?
        let text: String?
    }

    /// Each visited block's state, home and shown text — one statement, every
    /// row sought by primary key (the live placement by `uq_cblock_ownership`).
    private static func lineageNodeFacts(
        _ db: Database, ids: [String], calendar: Calendar
    ) throws -> [String: NodeFacts] {
        let json = String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT j.value AS id, b.id AS row_id, b.deleted_at, b.archived_at, b.last_container_id,
                       cb.container_id AS placed_in,
                       COALESCE(chosen.id, dflt.id) AS take_id,
                       COALESCE(chosen.working_text, dflt.working_text) AS text,
                       home.id AS home_id, home.kind AS home_kind, home.title AS home_title,
                       home.entry_date AS home_entry_date, home.created_at AS home_created_at,
                       home.wing_id AS home_wing, home.deleted_at AS home_deleted,
                       (home.archived_at IS NOT NULL AND home.archived_at = home.created_at) AS home_version
                FROM json_each(?) j
                LEFT JOIN block b ON b.id = j.value
                LEFT JOIN container_block cb
                  ON cb.block_id = b.id AND cb.deleted_at IS NULL AND b.deleted_at IS NULL
                LEFT JOIN variant chosen
                  ON chosen.id = cb.chosen_variant_id AND chosen.block_id = b.id
                 AND chosen.deleted_at IS NULL AND chosen.status = 'active'
                LEFT JOIN variant dflt
                  ON dflt.id = b.default_variant_id
                 AND (dflt.deleted_at IS NULL OR dflt.deleted_at = b.deleted_at)
                LEFT JOIN container home ON home.id = COALESCE(cb.container_id, b.last_container_id)
                """,
            arguments: [json])
        var facts: [String: NodeFacts] = [:]
        for row in rows {
            let id: String = row["id"]
            guard (row["row_id"] as String?) != nil else {
                facts[id] = NodeFacts(state: .missing, home: nil, shownTakeID: nil, text: nil)
                continue
            }
            let last: String? = row["last_container_id"]
            let state: LineageBlockState
            if let deletedAt: String = row["deleted_at"] {
                state = .deleted(deletedAt: deletedAt, lastContainerID: last)
            } else if let placed: String = row["placed_in"] {
                state = .placed(containerID: placed)
            } else if (row["archived_at"] as String?) != nil {
                state = .archived(lastContainerID: last)
            } else {
                state = .preserved(lastContainerID: last)
            }
            var home: LineageHome?
            if let homeID: String = row["home_id"], let kind = ContainerKind(rawValue: row["home_kind"]) {
                let title: String? = row["home_title"]
                home = LineageHome(
                    containerID: homeID, kind: kind,
                    title: kind == .pool
                        ? DisplayTitle.pool(title: title, createdAtStamp: row["home_created_at"], calendar: calendar)
                        : DisplayTitle.note(
                            title: title, entryDate: row["home_entry_date"], createdAt: row["home_created_at"],
                            calendar: calendar),
                    wingID: row["home_wing"], isDeleted: (row["home_deleted"] as String?) != nil,
                    isSavedVersion: (row["home_version"] as Int?) == 1)
            }
            facts[id] = NodeFacts(state: state, home: home, shownTakeID: row["take_id"], text: row["text"])
        }
        return facts
    }
}
