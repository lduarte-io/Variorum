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
    /// entry dates), sort-stamp movement, sectioning.
    public func observeReading(_ readingID: String) -> AsyncValueObservation<[Queries.ReadingEntry]> {
        observe { try Queries.assembleReading($0, readingID: readingID) }
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
        limit: Int
    ) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe { try Queries.library($0, sort: sort, direction: direction, limit: limit) }
    }

    /// A pool's contents with block tags, live.
    public func observePool(_ poolID: String) -> AsyncValueObservation<[Queries.PoolItem]> {
        observe { try Queries.poolListing($0, poolID: poolID) }
    }

    /// A post's deleted-blocks tray, live.
    public func observeTray(_ postID: String) -> AsyncValueObservation<[Queries.TrayItem]> {
        observe { try Queries.trayBlocks($0, postID: postID) }
    }
}
