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
            effectiveSegmentation: container.segmentationDefault ?? settingMode ?? .paragraph)
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
}

// MARK: - Live projections

extension AppDatabase {
    /// The editing container's header, live (seal toggles, retitles).
    public func observeContainerHeader(_ containerID: String) -> AsyncValueObservation<Queries.ContainerHeader?> {
        observe { try Queries.containerHeader($0, containerID: containerID) }
    }
}
// (An observeBlockFan wrapper was dropped in the Phase 7 review round —
// the fan panel refreshes via one-shot blockFan reads; ship the live
// wrapper when a view actually holds it.)
