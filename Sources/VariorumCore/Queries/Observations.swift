import Foundation
import GRDB

// Live projections (Phase 4, Step 5): the Step 1–4 fetch functions wired
// through `AppDatabase.observe` — GRDB ValueObservation delivering distinct
// value-typed projections off the main thread (P2). These are what Phase 7+
// view models hold; UI state is a projection, never a source of truth.
extension AppDatabase {
    /// The rendered container (post or pool), live. Emits whenever the
    /// projection actually changes: edits, fan growth, chosen-variant
    /// changes, reorder, structural ops.
    public func observePost(_ containerID: String) -> AsyncValueObservation<[Queries.RenderedBlock]> {
        observe { try Queries.renderPost($0, containerID: containerID) }
    }

    /// An assembled reading, live: membership, member metadata (titles,
    /// entry dates), sort-stamp movement, sectioning. `limit` (Phase 10,
    /// additive): a held observation re-fetches on container writes
    /// (autosave stamps land there), so a standing assembly should be
    /// windowed like `observeLibrary` — the book view passes its window;
    /// nil preserves the whole-reading fetch for extent-bounded readings.
    public func observeReading(
        _ readingID: String, limit: Int? = nil
    ) -> AsyncValueObservation<[Queries.ReadingEntry]> {
        observe { try Queries.assembleReading($0, readingID: readingID, limit: limit) }
    }

    /// The library listing (folder view), live. `limit` is deliberately
    /// required: this observation re-fetches on every `container` write
    /// (autosave stamps touch/churn there), so the standing fetch must be
    /// bounded — a top-N over the container table, cost ∝ post count and
    /// flat in corpus text size (benchmarked). Deeper listing = a larger
    /// limit or one-shot `Queries.library(limit: nil)` pages on demand.
    public func observeLibrary(
        sort: Queries.LibrarySort = .lastTouched,
        direction: SortDirection = .desc,
        limit: Int,
        profile: Profile? = nil
    ) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe {
            try Queries.library(
                $0, sort: sort, direction: direction, limit: limit, profile: profile)
        }
    }

    /// A pool's contents with block tags, live.
    public func observePool(_ poolID: String) -> AsyncValueObservation<[Queries.PoolItem]> {
        observe { try Queries.poolListing($0, poolID: poolID) }
    }

    /// The live pools, live (Phase 10 — the shell's pool section).
    public func observePools() -> AsyncValueObservation<[Container]> {
        observe { try Queries.pools($0) }
    }

    /// The archived-posts recovery surface, live (Phase 10 — the face the
    /// Phase 4 closeout promised `unarchiveContainer`).
    public func observeArchivedPosts() -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe { try Queries.archivedPosts($0) }
    }

    /// The deleted-posts recovery surface, live (Phase 10 —
    /// `restoreContainer`'s listing).
    public func observeDeletedPosts() -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe { try Queries.deletedPosts($0) }
    }

    /// The live readings, live (Phase 10 — the readings-management face).
    /// Unbounded on purpose: author-scale metadata (the taxonomy precedent).
    public func observeReadings() -> AsyncValueObservation<[Reading]> {
        observe { try Queries.readings($0) }
    }

    /// The whole live taxonomy, live (Phase 10 — the tag-management face).
    /// Unbounded on purpose: the tag tree is author-scale metadata, cost
    /// ∝ tag count, never corpus text (the pool/tray precedent).
    public func observeTags() -> AsyncValueObservation<[Tag]> {
        observe { try Queries.allTags($0) }
    }

    /// The folder view's listing, live: posts tagged at or under a tag
    /// (archived included — tag lookups still find them, Phase 4).
    public func observeTaggedPosts(
        _ tagID: String, includeSubtree: Bool = true
    ) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe {
            try Queries.taggedPostItems($0, tagID: tagID, includeSubtree: includeSubtree)
        }
    }

    /// One post's applied tags, live (the per-post tag editor).
    public func observePostTags(_ postID: String) -> AsyncValueObservation<[Tag]> {
        observe { try Queries.postTags($0, postID: postID) }
    }

    /// A post's deleted-blocks tray, live.
    public func observeTray(_ postID: String) -> AsyncValueObservation<[Queries.TrayItem]> {
        observe { try Queries.trayBlocks($0, postID: postID) }
    }
}
