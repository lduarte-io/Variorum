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
    /// global `default_segmentation` setting unless the caller names a mode
    /// (a fresh post carries no per-post override; the effective-default
    /// chain is the ordinary one).
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
    ///
    /// **`segmentation` (pre-13u midpoint review, M1):** an EXPLICIT mode
    /// for callers whose text has a shape of its own, defaulting to `nil`
    /// — the reader's setting, which is what every door that lands HER
    /// text keeps. It exists because SHIPPED CONTENT is not her text: the
    /// sample library's twelve stories are paragraphed prose whose whole
    /// job is to show the app at scale, and under the shipped "One block"
    /// option the global chain would have seeded 105k words as thirteen
    /// giant blocks — Blocks/Index/Outline showing thirteen rows, and an
    /// autosave rewriting ~60 KB per keystroke inside a story. Seeded
    /// furniture must not depend on a setting the reader can change, so
    /// the seeder names its mode and `TutorialSeeder`'s `newBlock` road
    /// (mode-independent by construction) keeps its property here.
    /// Every other caller passes nothing and is byte-unchanged.
    ///
    /// `wingId` (13i-d U5, additive — '' = Home, every existing caller): the
    /// Bookcase's entry bar and the sidebar's import land the note in the
    /// wing she is standing in (the quick-note pad keeps Home — Home holds
    /// quick notes and their gathering).
    @discardableResult
    public func importPost(
        title: String?, text: String, undoLabel: String = "Import",
        segmentation: Segmentation? = nil, wingId: String = ""
    ) throws -> ImportResult {
        // VX-357: U+0000 removed before segmenting (`StoredText`), so the
        // segments, their counts and the empty-import guard see what is stored.
        let text = StoredText.stripped(text)
        let result: ImportResult = try database.write { db in
            try requireLiveWing(db, wingId)
            let mode = try segmentation ?? globalSegmentation(db)
            let segments = SegmentationRules.bulkSegments(text, mode: mode)
            guard !segments.isEmpty else { throw OperationError.emptyImport }
            let post = try insertPost(
                db, title: title, profile: nil, entryDate: nil, wingId: wingId)
            let blockIDs = try mintSegments(db, segments, into: post.id)
            return ImportResult(container: post, blockIDs: blockIDs, createdContainer: true)
        }
        registerMintedContainerEntry(label: undoLabel, result.container.id)
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
        let text = StoredText.stripped(text)  // VX-357 (`importPost`'s reason)
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
        // VX-246 U2 — an entry with PARTS (the blocks): each half moves only
        // the blocks its partner last moved, so a block she put back from the
        // tray between ⌥⌘Z and ⇧⌥⌘Z is never tombstoned by the next ⌥⌘Z.
        let moved = LockIsolated<Set<String>?>(nil)
        undoStack?.register(
            label: "Import",
            inverse: { ops in
                let tombstoned = try ops.revertImportedBlocks(blockIDs, only: moved.value)
                moved.setValue(tombstoned)
                return !tombstoned.isEmpty
            },
            redo: { ops in
                let revived = try ops.reapplyImportedBlocks(blockIDs, only: moved.value)
                moved.setValue(revived)
                return !revived.isEmpty
            })
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
    @discardableResult
    func revertImportedBlocks(_ blockIDs: [String], only: Set<String>? = nil) throws -> Set<String> {
        try database.write { db in
            var tombstoned: Set<String> = []
            for blockID in blockIDs where only?.contains(blockID) ?? true {
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
                tombstoned.insert(blockID)
            }
            return tombstoned
        }
    }
}
