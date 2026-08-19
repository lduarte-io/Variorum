import Foundation
import GRDB

// Editor-facing projections (Phase 7): the header the editor renders a post
// under, the fan behind a block's badge, the per-variant commit list, and the
// split dates behind the restoreCommit pre-split warning (AppSpec §9). Read
// side only — same doctrine as the rest of Queries (missing rows tolerate,
// never crash), each fetch bounded by one container / block / variant, never
// the corpus (P1).
extension Queries {
    /// What the editor needs to know about the container it is editing,
    /// beyond the rendered slots: the seal, and which segmentation mode
    /// governs fresh text at the tail (AppSpec §7 segmentation trigger).
    public struct ContainerHeader: Equatable, Sendable {
        public let id: String
        public let kind: ContainerKind
        public let title: String?
        public let entryDate: String?
        /// The post-level seal (`container.locked`): while true the editor is
        /// read-only — the operations layer refuses everything under the post
        /// anyway; the header lets the UI say so instead of failing writes.
        public let locked: Bool
        /// Domain archive (kept, out of view) — direct address still renders.
        public let archived: Bool
        /// `container.segmentation_default`, falling back to the
        /// `default_segmentation` setting, falling back to `.paragraph`
        /// (the schema seed) — resolved here so the editor never re-derives it.
        public let effectiveSegmentation: Segmentation
        /// The per-POST word target (v1_12, 13b 4F — S4-28.1): display/
        /// progress only; the bars show "n% of Nw". nil = no target.
        public let wordTarget: Int?
        /// The mint stamp — carried so a header-fed display title can fall
        /// back to the created DAY for an untitled, undated note exactly as
        /// the listing rows do (DisplayTitle's one chain; C2 ladder R1-2:
        /// two surfaces must never disagree on one note's name).
        public let createdAt: String
    }

    /// nil ⇒ the container is missing or tombstoned (render nothing; the
    /// library will drop it too).
    public static func containerHeader(_ db: Database, containerID: String) throws -> ContainerHeader? {
        guard let container = try Container.fetchOne(db, key: containerID),
              container.deletedAt == nil
        else { return nil }
        let settingMode = try String
            .fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'default_segmentation'")
            .flatMap(Segmentation.init(rawValue:))
        return ContainerHeader(
            id: container.id,
            kind: container.kind,
            title: container.title,
            entryDate: container.entryDate,
            locked: container.locked,
            archived: container.archivedAt != nil,
            effectiveSegmentation: container.segmentationDefault ?? settingMode ?? .paragraph,
            wordTarget: container.wordTarget,
            // The raw TEXT stamp, not the record's Date — DisplayTitle's
            // day derivation reads the stored string exactly as the
            // timeline rows do (one chain, no encode round-trip).
            createdAt: try String.fetchOne(
                db, sql: "SELECT created_at FROM container WHERE id = ?",
                arguments: [containerID]) ?? "")
    }

    /// A block's live fan in fan order (`(fan_position, id)`), archived takes
    /// included with their statuses — the fan panel shows active cards and may
    /// reveal archived history; callers filter by `status`. Cost ∝ the fan.
    public static func blockFan(_ db: Database, blockID: String) throws -> [Variant] {
        try Variant.fetchAll(
            db,
            sql: """
                SELECT * FROM variant
                WHERE block_id = ? AND deleted_at IS NULL
                ORDER BY fan_position, id
                """,
            arguments: [blockID])
    }

    /// A variant's append-only commit history, newest first — the ordering
    /// rule is `(created_at, id)` exactly as AppSpec §7's commit_point note
    /// (never a per-variant seq). Cost ∝ the variant's own history.
    public static func commitHistory(_ db: Database, variantID: String) throws -> [CommitPoint] {
        try CommitPoint.fetchAll(
            db,
            sql: """
                SELECT * FROM commit_point
                WHERE variant_id = ?
                ORDER BY created_at DESC, id DESC
                """,
            arguments: [variantID])
    }

    /// The pre-split warning's pure predicate (AppSpec §9's documented
    /// restoreCommit behavior): a commit older than the NEWEST live
    /// divide/extract on the block still holds the full pre-split text,
    /// so restoring it resurrects both halves into this buffer — the
    /// editor warns first. Hoisted from the Mac's app-local `CommitRules`
    /// at parity C4a (the phone's history face reads the same brain —
    /// MobileSoul §3's one-brain rule; the Mac's enum delegates here).
    public static func commitPredatesSplit(commitDate: Date, splitDates: [Date]) -> Bool {
        guard let newest = splitDates.max() else { return false }
        return commitDate < newest
    }

    /// Creation dates of the live divide/extract lineage edges that split
    /// THIS block (block as ancestor: `derived_from(source=descendant,
    /// target=ancestor)` — AppSpec §7). Feeds the editor's pre-split warning
    /// predicate: a commit older than the newest of these predates a split
    /// and restoring it resurrects pre-split text (documented, AppSpec §9).
    public static func splitDates(_ db: Database, blockID: String) throws -> [Date] {
        try Edge.fetchAll(
            db,
            sql: """
                SELECT * FROM edge
                WHERE target_block_id = ?
                  AND type = 'derived_from'
                  AND origin_op IN ('divide', 'extract')
                  AND deleted_at IS NULL
                """,
            arguments: [blockID])
            .map(\.createdAt)
    }

    // MARK: - The block's PAST (13j J3 + the round-5 deleted-take ruling)

    /// A block's DELETED takes, newest tombstone first — the population that
    /// had no door anywhere in the app until 13j (verified by sweep at the
    /// sitting: no `restoreVariant` op, no deleted-take query, so a deleted
    /// take was unreachable forever).
    ///
    /// Read for a LIVE block, which is what makes the listing exactly the
    /// restorable set: a take that died WITH its block carries the block's
    /// stamp and comes back with `restoreBlock`, and one that died
    /// independently keeps its own stamp — so on a live block every tombstoned
    /// take is one `restoreVariant` can put back. Cost ∝ the block's own fan
    /// history (`idx_variant_block`), never the corpus.
    ///
    /// `now` (13j J1) is REQUIRED: a deleted take rides the same 30-day clock
    /// as everything else she deleted, and past it the History face stops
    /// offering a Put back it cannot honour.
    public static func deletedTakes(
        _ db: Database, blockID: String, now: Date
    ) throws -> [Variant] {
        try Variant.fetchAll(
            db,
            sql: """
                SELECT * FROM variant
                WHERE block_id = ? AND deleted_at IS NOT NULL AND deleted_at >= ?
                  AND NOT EXISTS (SELECT 1 FROM purge_intent pi
                    WHERE pi.table_name = 'variant' AND pi.row_id = variant.id)
                ORDER BY deleted_at DESC, id
                """,
            arguments: [blockID, TrashWindow.cutoffStamp(now: now)])
    }

    /// **What ONE block's History face shows besides its savepoints** (13j
    /// batch 3): the takes it has deleted, and the originals a divide or a
    /// merge preserved whole behind it.
    ///
    /// ONE projection rather than two because the face renders them as one
    /// quiet "past" region and both hosts (Write's inline history, the Takes
    /// history sheet) need exactly this pair — one observation, one model,
    /// two hosts.
    public struct BlockPast: Equatable, Sendable {
        public var deletedTakes: [Variant]
        public var origins: [UnplacedOrigin]

        public init(deletedTakes: [Variant] = [], origins: [UnplacedOrigin] = []) {
            self.deletedTakes = deletedTakes
            self.origins = origins
        }

        public var isEmpty: Bool { deletedTakes.isEmpty && origins.isEmpty }
    }

    public static func blockPast(
        _ db: Database, blockID: String, now: Date
    ) throws -> BlockPast {
        BlockPast(
            deletedTakes: try deletedTakes(db, blockID: blockID, now: now),
            origins: try unplacedOrigins(db, ofBlock: blockID))
    }
}

// MARK: - Live projections

extension AppDatabase {
    /// The editing container's header, live (seal toggles, retitles).
    public func observeContainerHeader(_ containerID: String) -> AsyncValueObservation<Queries.ContainerHeader?> {
        observe { try Queries.containerHeader($0, containerID: containerID) }
    }

    /// A block's deleted takes, live (13j batch 3) — the observation the
    /// round-5 ruling's Put back needs so a restored take leaves the listing
    /// without a hand-rolled reload.
    public func observeDeletedTakes(
        _ blockID: String, now: Date
    ) -> AsyncValueObservation<[Variant]> {
        observe { try Queries.deletedTakes($0, blockID: blockID, now: now) }
    }

    /// The block's past, live (13j batch 3). **Held only while the History
    /// face is on screen**, deliberately: it reads `variant`, which is the
    /// one table autosave writes, so a standing observation would re-run at
    /// keystroke rate (the `trayCounts` finding, one surface over). Bounded
    /// by construction either way — cost ∝ this block's own fan history and
    /// its own lineage edges, never the corpus (P1) — and the face is a
    /// summoned panel, not ambient chrome.
    public func observeBlockPast(
        _ blockID: String, now: Date
    ) -> AsyncValueObservation<Queries.BlockPast> {
        observe { try Queries.blockPast($0, blockID: blockID, now: now) }
    }
}
// (An observeBlockFan wrapper was dropped in the Phase 7 review round —
// the fan panel refreshes via one-shot blockFan reads; ship the live
// wrapper when a view actually holds it.)
