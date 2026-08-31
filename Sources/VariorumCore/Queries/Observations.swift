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
    ///
    /// `order` (13c 2D, additive — A31): hold the assembly in a way of
    /// LOOKING rather than the book's own order. A view that changes it
    /// restarts its observation (nothing is written), which is exactly why
    /// the parameter belongs here and not in a post-fetch re-sort: the
    /// window is applied by the query, so sorting the delivered rows would
    /// sort only the first N of the OLD order.
    public func observeReading(
        _ readingID: String, limit: Int? = nil, order: Queries.ReadingOrder? = nil
    ) -> AsyncValueObservation<[Queries.ReadingEntry]> {
        observe {
            try Queries.assembleReading($0, readingID: readingID, limit: limit, order: order)
        }
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

    /// Every group's snippets, live (pre-13u Act 10 wave 2b — the Snippets
    /// surface's "all snippets" rail row). Same region class as
    /// `observePool`, summed over the groups.
    public func observeAllPoolItems() -> AsyncValueObservation<[Queries.PoolItem]> {
        observe { try Queries.allPoolsListing($0) }
    }

    /// The archived-posts recovery surface, live (Phase 10 — the face the
    /// Phase 4 closeout promised `unarchiveContainer`). `limit` REQUIRED —
    /// archives accumulate over years (review round 1).
    ///
    /// Version history never lists here (the post-13l polish round, ledger
    /// row 8 — the V1 classifier; the reason is written out at
    /// `Queries.archivedPosts`): a saved version's one home is its note's
    /// Versions listing, so the surface that means *"notes I set aside"*
    /// shows exactly those.
    public func observeArchivedPosts(limit: Int) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe { try Queries.archivedPosts($0, limit: limit) }
    }
    // (No `now` here, and that is the point: ARCHIVE has no clock — 13j
    // round 3's ruling keeps Archived a calm forever-section beside the
    // Trash's countdown.)

    /// The deleted-posts recovery surface, live (Phase 10 —
    /// `restoreContainer`'s listing). `limit` REQUIRED — tombstones are
    /// forever under S2 (review round 1).
    public func observeDeletedPosts(
        now: Date, limit: Int
    ) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe { try Queries.deletedPosts($0, now: now, limit: limit) }
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
    /// (archived included — tag lookups still find them, Phase 4). `limit`
    /// is REQUIRED (review round 1 — the observeLibrary discipline): the
    /// listing is corpus-shaped and the standing fetch re-runs at
    /// container-write rate.
    public func observeTaggedPosts(
        _ tagID: String, includeSubtree: Bool = true, limit: Int
    ) -> AsyncValueObservation<[Queries.TimelineItem]> {
        observe {
            try Queries.taggedPostItems(
                $0, tagID: tagID, includeSubtree: includeSubtree, limit: limit)
        }
    }

    /// One post's applied tags, live (the per-post tag editor).
    public func observePostTags(_ postID: String) -> AsyncValueObservation<[Tag]> {
        observe { try Queries.postTags($0, postID: postID) }
    }

    /// A post's deleted-blocks tray, live. `limit` (13j ladder A, A6): a
    /// held observation passes `window + 1` — bounded in SQL, marker-safe.
    public func observeTray(
        _ postID: String, now: Date, limit: Int? = nil
    ) -> AsyncValueObservation<[Queries.TrayItem]> {
        observe { try Queries.trayBlocks($0, postID: postID, now: now, limit: limit) }
    }

    /// A post's PRESERVED ORIGINALS, live (13j J2 — the tray's second
    /// section). Bounded like every corpus-history-shaped listing.
    public func observePreservedOriginals(
        _ postID: String, limit: Int? = nil
    ) -> AsyncValueObservation<[Queries.PreservedOriginal]> {
        observe { try Queries.preservedOriginals($0, postID: postID, limit: limit) }
    }

    /// The tray door's two counts, live (13j J2). Deliberately the count
    /// query rather than the listings — see `Queries.trayCounts`: this one
    /// never reads `variant`, so an open note's badge does not re-run at
    /// autosave rate (P1).
    public func observeTrayCounts(
        _ postID: String, now: Date
    ) -> AsyncValueObservation<Queries.TrayCounts> {
        observe { try Queries.trayCounts($0, postID: postID, now: now) }
    }
}
