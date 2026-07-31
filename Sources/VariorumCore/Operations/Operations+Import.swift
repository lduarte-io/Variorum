import Dependencies
import Foundation
import GRDB

// Import (Phase 11b, Step B2 — the KnownIssues drop-in row): dropped
// `.md`/plain text becomes ordinary blocks through the EXISTING bulk-entry
// pipeline (`SegmentationRules.bulkSegments` — paste, drop, capture, and
// import are one class, so the 2026-07-12 spacing ruling rides for free:
// k newlines between pieces store k−1 trailing on the preceding block, and
// export re-creates the paste byte-for-byte). The source file is a ONE-WAY
// source — never edited in place, never linked (in-place file editing is
// the rejected diff-recovered-blob model, OverallModel §8); the app face
// only ever READS the dropped URL.
extension Operations {
    /// What an import minted, for callers and state-transition tests.
    public struct ImportResult: Equatable, Sendable {
        /// The post the library door created, or the existing container the
        /// pool door appended to.
        public let container: Container
        public let blockIDs: [String]
        /// False when the text landed in an existing container.
        public let createdContainer: Bool
    }

    /// The LIBRARY door: dropped text → a NEW post, segmented by the
    /// global `default_segmentation` setting (a fresh post carries no
    /// per-post override; the effective-default chain is the ordinary one).
    /// Whitespace-only text refuses — nothing to import beats an empty
    /// post. Minting text is working on the post (the ratified `newBlock`
    /// stamp rule): touch + churn accumulate per minted block, exactly as
    /// N `newBlock` calls would. Undo tombstones the minted post
    /// (`restoreContainer` stays the recovery door — the copy-op pattern).
    ///
    /// **`undoLabel` (13f batch 6, W5 — the architect's ruling):** the undo
    /// entry's words, defaulted to this door's own name. It is a parameter
    /// and not a constant because the QUICK NOTE mints through exactly this
    /// path, and "Undo Import" is not what she did — a menu that says
    /// "Undo Quick Note" says what happened. Nothing else about the entry
    /// changes: same inverse, same redo, same recovery door.
    @discardableResult
    public func importPost(
        title: String?, text: String, undoLabel: String = "Import"
    ) throws -> ImportResult {
        let result: ImportResult = try database.write { db in
            let mode = try globalSegmentation(db)
            let segments = SegmentationRules.bulkSegments(text, mode: mode)
            guard !segments.isEmpty else { throw OperationError.emptyImport }
            let post = try insertPost(db, title: title, profile: nil, entryDate: nil)
            let blockIDs = try mintSegments(db, segments, into: post.id)
            return ImportResult(container: post, blockIDs: blockIDs, createdContainer: true)
        }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertMintedContainer(result.container.id) },
            redo: { try $0.reapplyMintedContainer(result.container.id) })
        return result
    }

    /// The POOL door (and any container's): dropped text → blocks appended
    /// at the end of an EXISTING live container, segmented by that
    /// container's effective default (`segmentation_default`, else the
    /// global setting — the `containerHeader` chain). A sealed container
    /// refuses like every write under it. Undo tombstones exactly the
    /// minted blocks (tray-recoverable, like any deleted block).
    @discardableResult
    public func importBlocks(into containerID: String, text: String) throws -> ImportResult {
        let result: ImportResult = try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)
            let mode = try container.segmentationDefault ?? globalSegmentation(db)
            let segments = SegmentationRules.bulkSegments(text, mode: mode)
            guard !segments.isEmpty else { throw OperationError.emptyImport }
            let blockIDs = try mintSegments(db, segments, into: containerID)
            return ImportResult(container: container, blockIDs: blockIDs, createdContainer: false)
        }
        let blockIDs = result.blockIDs
        undoStack?.register(
            label: "Import",
            inverse: { try $0.revertImportedBlocks(blockIDs) },
            redo: { try $0.reapplyImportedBlocks(blockIDs) })
        return result
    }

    // MARK: - Internals

    /// The effective global segmentation: the `default_segmentation`
    /// setting, falling back to `.paragraph` (the schema seed) — the same
    /// chain `Queries.containerHeader` resolves for the editor.
    private func globalSegmentation(_ db: Database) throws -> Segmentation {
        try String
            .fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'default_segmentation'")
            .flatMap(Segmentation.init(rawValue:)) ?? .paragraph
    }

    /// Mints one block per segment at the container's end, in order, each
    /// stamping touch + churn like `newBlock` (one transaction around all
    /// of them — the caller's).
    private func mintSegments(
        _ db: Database, _ segments: [String], into containerID: String
    ) throws -> [String] {
        var blockIDs: [String] = []
        for segment in segments {
            let now = date.now
            let minted = try mintBlock(db, text: segment, in: containerID, at: .end, now: now)
            try registerTextChange(
                db, blockID: minted.block.id, charDelta: segment.count,
                forceMajorRevision: false, now: now)
            blockIDs.append(minted.block.id)
        }
        return blockIDs
    }

    /// Inverse of the pool-door import: tombstone the minted blocks (the
    /// `deleteBlock` transition without its own undo registration —
    /// inverses never push entries). Already-dead blocks are obsolete
    /// no-ops; `last_container_id` stamps so an undone import stays
    /// reachable in the tray (the insurance doctrine).
    func revertImportedBlocks(_ blockIDs: [String]) throws {
        try database.write { db in
            for blockID in blockIDs {
                guard var block = try Block.fetchOne(db, key: blockID),
                      block.deletedAt == nil
                else { continue }
                try ensurePlacementUnlocked(db, blockID: blockID)
                let now = date.now
                if let placement = try livePlacement(db, blockID: blockID) {
                    block.lastContainerId = placement.containerId
                }
                block.deletedAt = now
                block.updatedAt = now
                try block.update(db)
            }
        }
    }
}
