import Foundation

/// **THE LINEAGE FACE's FAMILY, AS A VALUE** (VX-801, VX-827 U3b — THE DESIGN
/// MEMO, `notes/plans/fixes/vx-827-lineage.md`): *"VERTICAL, older above, NO
/// horizontal scroll anywhere: the family as a list (origin verb · first
/// words · where it lives · counts), this block marked; … Put back · Bring
/// back as take · Compare with now on the selected node's header; a Trash
/// node muted, no acts; a cross-wing node named with its wing, go-to only."*
///
/// A pure projection of `Queries.lineageTree` (U1's read) and the members'
/// counts: the ORDER (older above — ancestors deepest first, this block,
/// descendants nearest first, then the block's versions, each generation its
/// own band), where each member STANDS as the face names it, and which ACTS
/// its header carries — so the face draws and never decides (P-1/P-2: a door
/// that could never act is not offered). The wing rule is the operation's own
/// (`Operations.lineageCrossesWing`), so the face and the fence cannot drift.
public enum LineageFamily {
    /// A member's takes (live, active — the face's "N takes") and the commits
    /// of its live takes.
    public struct Counts: Equatable, Sendable {
        public let takes: Int
        public let commits: Int

        public init(takes: Int, commits: Int) {
            self.takes = takes
            self.commits = commits
        }
    }

    /// Where a member stands now.
    public enum Place: Equatable, Sendable {
        /// The block the face was opened on.
        case thisBlock
        /// Live and placed — in the face's own note (`sameNote`), another
        /// note, or the scraps.
        case placed(home: Queries.LineageHome, sameNote: Bool)
        /// Live, unplaced: kept whole as lineage (a divide-W's original, a
        /// merge's sources), released from the container `home` names.
        case keptAsLineage(home: Queries.LineageHome?)
        /// Live, unplaced and archived — set aside on purpose.
        case setAside(home: Queries.LineageHome?)
        /// In the Trash — the block, or the note it lives in.
        case inTrash(home: Queries.LineageHome?)
        /// In a note of ANOTHER wing: named with its wing, nothing more (no
        /// words across — #166(e)'s lineage line).
        case otherWing(wingID: String)
    }

    /// The acts a member's header carries.
    public enum Act: Hashable, Sendable {
        /// Back into the note it was released from (a kept original) or where
        /// it stood (a set-aside block) — the existing roads and landings.
        case putBack
        /// Its shown take becomes a take on the block you came from
        /// (`Operations.bringBackFromLineage`).
        case bringBackAsTake
        /// Its text beside the block you came from as it stands now.
        case compareWithNow
        /// Go to the wing it lives in.
        case goToWing(String)
    }

    public struct Member: Equatable, Sendable, Identifiable {
        public var id: String { blockID }
        public let blockID: String
        public let direction: Queries.LineageTreeNode.Direction
        public let depth: Int
        /// The band the member is drawn in, older above: ancestors negative
        /// (−depth), this block 0, descendants +depth, versions
        /// `versionBand`. A gap is drawn where it changes.
        public let generation: Int
        /// What happened — the connecting edge's `origin_op` (nil at this
        /// block and on an edge minted without one).
        public let originOp: String?
        /// The connecting edge's type — `version_of` reads "a version".
        public let edgeType: EdgeType?
        public let place: Place
        /// The take it shows (placed → chosen, else the default).
        public let shownTakeID: String?
        /// Its shown text — nil across a wing (no words cross) and for a
        /// block with no row.
        public let text: String?
        public let counts: Counts?
        public let acts: [Act]
        /// Selecting it swaps the face's pane and rail to this block.
        public let selectable: Bool

        public init(
            blockID: String, direction: Queries.LineageTreeNode.Direction, depth: Int,
            generation: Int, originOp: String?, edgeType: EdgeType?, place: Place,
            shownTakeID: String?, text: String?, counts: Counts?, acts: [Act], selectable: Bool
        ) {
            self.blockID = blockID
            self.direction = direction
            self.depth = depth
            self.generation = generation
            self.originOp = originOp
            self.edgeType = edgeType
            self.place = place
            self.shownTakeID = shownTakeID
            self.text = text
            self.counts = counts
            self.acts = acts
            self.selectable = selectable
        }

        /// A Trash member is drawn muted.
        public var isMuted: Bool {
            if case .inTrash = place { return true }
            return false
        }
    }

    /// The versions' band — after every descendant generation.
    public static let versionBand = Int.max

    /// **The family, older above.** Ancestors deepest first (then by the
    /// connecting edge's stamp, then id), this block, descendants nearest
    /// first (the same ties), then the version siblings (by stamp, then id).
    /// A block met twice — a duplicate's copy is both a descendant and a
    /// version; a cycle's block both an ancestor and a descendant — shows
    /// ONCE, at its first place in that order. A block with no row (a purged
    /// one) is walked through by the read and never described here.
    public static func members(
        _ tree: Queries.LineageTree, counts: [String: Counts]
    ) -> [Member] {
        func stamp(_ node: Queries.LineageTreeNode) -> String { node.via?.createdAt ?? "" }
        let ancestors = tree.ancestors.sorted {
            ($1.depth, stamp($0), $0.blockID) < ($0.depth, stamp($1), $1.blockID)
        }
        let descendants = tree.descendants.sorted {
            ($0.depth, stamp($0), $0.blockID) < ($1.depth, stamp($1), $1.blockID)
        }
        let versions = tree.versions.sorted { (stamp($0), $0.blockID) < (stamp($1), $1.blockID) }

        let faceHome = tree.origin.home
        var seen: Set<String> = []
        var out: [Member] = []
        func add(_ node: Queries.LineageTreeNode, generation: Int) {
            guard !seen.contains(node.blockID) else { return }
            seen.insert(node.blockID)
            if node.direction != .origin, node.state == .missing { return }
            out.append(member(node, generation: generation, faceHome: faceHome, counts: counts))
        }
        for node in ancestors { add(node, generation: -node.depth) }
        add(tree.origin, generation: 0)
        for node in descendants { add(node, generation: node.depth) }
        for node in versions { add(node, generation: versionBand) }
        return out
    }

    private static func member(
        _ node: Queries.LineageTreeNode, generation: Int, faceHome: Queries.LineageHome?,
        counts: [String: Counts]
    ) -> Member {
        let base = (
            blockID: node.blockID, direction: node.direction, depth: node.depth,
            originOp: node.originOp, edgeType: node.via?.type)
        func make(_ place: Place, text: String?, counts: Counts?, acts: [Act], selectable: Bool) -> Member {
            Member(
                blockID: base.blockID, direction: base.direction, depth: base.depth,
                generation: generation, originOp: base.originOp, edgeType: base.edgeType,
                place: place, shownTakeID: node.shownTakeID, text: text, counts: counts,
                acts: acts, selectable: selectable)
        }
        if node.direction == .origin {
            return make(.thisBlock, text: node.text, counts: counts[node.blockID], acts: [], selectable: true)
        }
        // Another wing: named with its wing, go-to only — no words, no counts.
        if Operations.lineageCrossesWing(faceHome, node.home), let home = node.home {
            return make(
                .otherWing(wingID: home.wingID), text: nil, counts: nil,
                acts: [.goToWing(home.wingID)], selectable: false)
        }
        let readable: [Act] = node.text == nil ? [] : [.bringBackAsTake, .compareWithNow]
        switch node.state {
        case .deleted:
            return make(.inTrash(home: node.home), text: node.text, counts: nil, acts: [], selectable: false)
        case .placed:
            guard let home = node.home, !home.isDeleted else {
                return make(.inTrash(home: node.home), text: node.text, counts: nil, acts: [], selectable: false)
            }
            return make(
                .placed(home: home, sameNote: home.containerID == faceHome?.containerID),
                text: node.text, counts: counts[node.blockID], acts: readable, selectable: true)
        case .preserved:
            // Put back PLACES it in the container it was released from —
            // only where that container still stands.
            let placeable = node.home.map { !$0.isDeleted } ?? false
            return make(
                .keptAsLineage(home: node.home), text: node.text, counts: counts[node.blockID],
                acts: (placeable ? [.putBack] : []) + readable, selectable: true)
        case .archived:
            let placeable = node.home.map { !$0.isDeleted } ?? false
            return make(
                .setAside(home: node.home), text: node.text, counts: counts[node.blockID],
                acts: (placeable ? [.putBack] : []) + readable, selectable: true)
        case .missing:
            return make(.inTrash(home: nil), text: nil, counts: nil, acts: [], selectable: false)
        }
    }

    /// **Which member the face opens on** (PROVISIONAL, P-U3b-1): the one a
    /// door asked for when it can be shown (the origin door's original);
    /// else the nearest ancestor that can — the block it came out of, A's
    /// reach — first in the drawn order; else this block.
    public static func opening(_ members: [Member], prefer: String?) -> String? {
        if let prefer, members.contains(where: { $0.blockID == prefer && $0.selectable }) {
            return prefer
        }
        if let parent = members.first(where: {
            $0.direction == .ancestor && $0.depth == 1 && $0.selectable
        }) {
            return parent.blockID
        }
        return members.first { $0.direction == .origin }?.blockID
    }
}
