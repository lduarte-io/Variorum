import Foundation

/// **WHICH TRASHED BLOCK IS "EMPTY WITH NO HISTORY"** (VX-800 — her ask,
/// verbatim: *"delete all empty blocks with no history from trash."*; the
/// predicate is her R-828-1, read row by row at the VX-828 batch D fork and
/// ruled there — `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch D —
/// THE FORK'S RULING").
///
/// One pure rule over a block's COUNTED facts. The facts are gathered by
/// `Queries.emptyBlockSweepFacts`, which is where each count's row-level
/// reading lives (and is pinned exact-rows); this is where the six of them
/// meet, once, so the door's count, the confirm and the act's in-transaction
/// re-check can never disagree about what qualifies.
///
/// A block qualifies when ALL six hold:
/// 1. **no worded take** — no variant of the block, in ANY status or
///    tombstone state, holds a non-zero-length `working_text` (P-828-8 (a):
///    zero-length is the seam carve's own empty test, one app-wide meaning;
///    whitespace is content she owns);
/// 2. **no savepoint** on any of its variants;
/// 3. **no comment row** at all, live or tombstoned (every comment row is
///    still retrievable — Put back revives the stamp-matched ones and the
///    deleted fold resurrects the rest);
/// 4. **no name**;
/// 5. **no callout frame** (any stored presentation, even one that reads as
///    plain, keeps it out);
/// 6. **no link to a living block** — no edge row of any type, WHATEVER the
///    edge's own tombstone, joining it to a block that is not deleted
///    (P-828-7 (a): a deleted block's edges are cascade-tombstoned with it,
///    so a live-edges-only reading would protect nothing; and this reading
///    is what keeps the purge family from ever stranding-and-purging a live
///    original through `PurgeFamily.joinStrandedOriginals`).
///
/// NOT history (P-828-9 (a) and the fork's list): block tags, take labels, a
/// locked take, canvas/lens rows, `archived_at` — the purge family takes them
/// with the block.
public enum EmptyBlockSweep {
    /// The counted facts of one block — what `qualifies` decides over.
    public struct Facts: Equatable, Sendable {
        public let blockID: String
        /// Variant rows (any status, any tombstone) with non-empty text.
        public let wordedTakes: Int
        /// `commit_point` rows on any of the block's variants.
        public let savepoints: Int
        /// `block_comment` rows on the block, live or tombstoned.
        public let comments: Int
        public let name: String?
        public let presentation: String?
        /// Edge rows (any type, any edge tombstone) joining the block to a
        /// block that is not deleted — itself excluded.
        public let livingLinks: Int

        public init(
            blockID: String, wordedTakes: Int = 0, savepoints: Int = 0, comments: Int = 0,
            name: String? = nil, presentation: String? = nil, livingLinks: Int = 0
        ) {
            self.blockID = blockID
            self.wordedTakes = wordedTakes
            self.savepoints = savepoints
            self.comments = comments
            self.name = name
            self.presentation = presentation
            self.livingLinks = livingLinks
        }
    }

    /// R-828-1: empty, and nothing that is history.
    public static func qualifies(_ facts: Facts) -> Bool {
        facts.wordedTakes == 0
            && facts.savepoints == 0
            && facts.comments == 0
            && facts.name == nil
            && facts.presentation == nil
            && facts.livingLinks == 0
    }
}
