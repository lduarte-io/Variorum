import Dependencies
import Foundation
import GRDB

// SMART → CURATED conversion (Phase 13c, Batch 2D — committed scope C2 /
// ledger N38; designed on paper first in
// `notes/plans/phase-13c-memo-smart-to-curated.md`, which is the binding
// record for WHY this shape and not the other two).
//
// Her direction, verbatim (S4-28.4): *"adding a chapter and curating a
// smart book a little should be allowed, but then you should be able to
// make a new 'smart book' off the same tag. so maybe the book converts
// from smart to a smart + curated book?"*
//
// **Built to the memo's SHAPE A — materialize-and-convert.** The whole
// thing is PROVISIONAL (QUESTIONS #46): the memo's five plain-language
// rulings are hers and she was not present, so each one is implemented at
// its most spec-defensible reading with the alternative recorded.
//
// What makes A cheap is worth stating: it needs NO schema. A smart book's
// membership is derived — no `reading_post` rows exist — and a chapter
// assignment has nowhere to live without one (`reading_post.section_id`).
// Materializing the CURRENT results into ordinary membership rows and
// flipping `kind` (a CHECK-legal value already) turns the book into an
// ordinary curated book from that instant: chapters, hand order, the
// capacity gate, `restoreReading` — every one of them already shipped and
// already tested. The alternatives cost either a large new semantic
// surface (shape B's derived ∪ pinned union, which every membership
// consumer would have to learn) or a third `kind` value (a CHECK rebuild
// + mirror + SyncSpec §12 lockstep event).
extension Operations {
    /// What a conversion did — for callers, and for exact state-transition
    /// tests (the minted rows are named, not counted).
    public struct SmartConversionResult: Equatable, Sendable {
        /// The converted book, post-flip (`kind == .book`).
        public let reading: Reading
        /// The membership rows minted, in materialized order. Posts that
        /// already carried a live membership row are NOT here (see below).
        public let membershipIDs: [String]
        /// The fresh smart book minted to keep collecting, when asked for.
        public let collectingReading: Reading?
    }

    /// Pre-images captured at do-time, so the inverse restores exact rows
    /// rather than re-deriving anything (the standing undo discipline).
    struct SmartConversionPreImage: Sendable {
        let sortField: SortField
        let sortDir: SortDirection
    }

    /// Turns a smart book into a hand-shaped one: its CURRENT results
    /// become real `reading_post` rows in the order she is looking at, and
    /// `kind` flips to `curated`.
    ///
    /// - `keepCollecting`: also mint a fresh smart book carrying the SAME
    ///   filter, so the tag keeps flowing somewhere while this book freezes
    ///   into hand-shape (the second half of her sentence).
    /// - `collectingName`: that book's name; blank/nil defaults to
    ///   `"<name> (collecting)"`.
    /// - `order` *(13c K6 review, K2)*: the A31 view-order override the
    ///   caller's surface is currently LOOKING through, if any. "The order
    ///   she is looking at" stopped being synonymous with the stored sort
    ///   the moment A31 shipped a read-time override on the same surface —
    ///   a conversion that ignored it froze an order she was not looking
    ///   at, silently (the mismatch surfaced only when she later dropped
    ///   the override). nil = the book's stored order, exactly as before.
    ///
    /// ONE transaction: a refusal part-way leaves no half-converted book.
    ///
    /// Decisions taken here, each recorded as a PROVISIONAL in QUESTIONS
    /// #46 with what the alternative would have changed:
    ///
    /// - **Materialization order is what she currently SEES**, frozen: the
    ///   assembly runs with the book's own sort — or the caller's active
    ///   A31 view-order override (`order:`), which is what "currently sees"
    ///   means when one is on — and `sort_field` then flips to `manual` so
    ///   nothing moves at the moment of conversion (memo Q4's lean — the
    ///   point of converting is hand-shape).
    /// - **The extent cap is honored**: `assembleReading` applies
    ///   `max_posts`, so a capped smart book materializes exactly the posts
    ///   it was displaying. What-you-see-is-what-you-keep, and it is also
    ///   the only reading that cannot mint a book born over its own cap.
    /// - **`query_spec` stays on the row as provenance.** Curated assembly
    ///   ignores it; keeping it means the fresh-smart-book offer still works
    ///   later, and nothing she wrote is thrown away.
    /// - **`grouping_tag_id` stays too, and keeps working**: curated
    ///   assembly honors a grouping tag whenever the book has no live
    ///   chapters, so the tag-derived sections she was reading SURVIVE the
    ///   conversion untouched and hand off to real chapters the moment she
    ///   creates one (`chaptersActive`'s shipped precedence). No new rule.
    /// - **A LOCKED (finished) book refuses** — converting is a structural
    ///   act on a book declared done; un-finish first (the standing
    ///   `lockedReading` bucket every other structural reading op uses).
    /// - **Posts already carrying a live membership row are skipped.** No
    ///   ordinary door can produce one on a smart reading (`addPostToReading`
    ///   refuses `wrongReadingKind`), but undo leaves the possibility open —
    ///   its inverse tombstones only what IT minted, so a hand-added row
    ///   could survive a re-conversion — and `uq_reading_post_live` would
    ///   otherwise make that second conversion throw. Defensive, cheap, and
    ///   it makes convert → undo → hand-add → convert a legal sequence.
    @discardableResult
    public func convertSmartReadingToCurated(
        _ readingID: String,
        keepCollecting: Bool = false,
        collectingName: String? = nil,
        order: Queries.ReadingOrder? = nil
    ) throws -> SmartConversionResult {
        let now = date.now
        let (result, preImage): (SmartConversionResult, SmartConversionPreImage) =
            try database.write { db in
                var reading = try liveReading(db, readingID)
                guard reading.kind == .gathering else {
                    throw OperationError.wrongReadingKind(id: readingID, expected: .gathering)
                }
                guard !reading.locked else {
                    throw OperationError.lockedReading(id: readingID)
                }

                // What she is looking at, in the order she is looking at it
                // — the book's own assembly (through the caller's view-order
                // override, when one is active), never a second ordering
                // brain.
                let entries = try Queries.assembleReading(
                    db, readingID: readingID, order: order)
                var membershipIDs: [String] = []
                for entry in entries {
                    guard try livePairRow(
                        db, postID: entry.postID, readingID: readingID) == nil
                    else { continue }
                    let membership = ReadingPost(
                        id: newID(), readingId: readingID, postId: entry.postID,
                        position: try readingPosition(db, readingID: readingID, at: .end),
                        createdAt: now)
                    try membership.insert(db)
                    membershipIDs.append(membership.id)
                }

                let preImage = SmartConversionPreImage(
                    sortField: reading.sortField, sortDir: reading.sortDir)
                reading.kind = .book
                reading.sortField = .manual
                reading.updatedAt = now
                try reading.update(db)

                // The fresh collector: the same filter, the same sectioning
                // story, the same ORDER it had — but deliberately NOT the
                // extents or the finish state. A book born at its cap (or
                // born finished) could not collect anything, which is the
                // one thing this book exists to do.
                var collecting: Reading?
                if keepCollecting {
                    let trimmed = (collectingName ?? "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let fresh = Reading(
                        id: newID(), ownerId: currentOwnerID(),
                        name: trimmed.isEmpty ? "\(reading.name) (collecting)" : trimmed,
                        kind: .gathering,
                        profile: reading.profile,
                        sortField: preImage.sortField, sortDir: preImage.sortDir,
                        groupingTagId: reading.groupingTagId,
                        querySpec: reading.querySpec,
                        createdAt: now, updatedAt: now)
                    try fresh.insert(db)
                    collecting = fresh
                }

                return (
                    SmartConversionResult(
                        reading: reading, membershipIDs: membershipIDs,
                        collectingReading: collecting),
                    preImage)
            }

        // Structural undo (AppSpec §9): conversion mints N rows, changes a
        // book's kind, and may mint a whole second book — materially more
        // than the `addPostToReading` class that deliberately registers
        // nothing, and there is no "convert back" door to hand-reverse it
        // with (memo Q5's lean is that curated → smart should not exist).
        // Both halves ride the SAME do-time ids, so undo↔redo ping-pongs
        // without re-deriving membership (13c 1B's redo contract).
        let membershipIDs = result.membershipIDs
        let collectingID = result.collectingReading?.id
        undoStack?.register(
            label: "Convert to Book",
            inverse: {
                try $0.revertSmartConversion(
                    readingID: readingID, membershipIDs: membershipIDs,
                    sortField: preImage.sortField, sortDir: preImage.sortDir,
                    collectingReadingID: collectingID)
            },
            redo: {
                try $0.reapplySmartConversion(
                    readingID: readingID, membershipIDs: membershipIDs,
                    collectingReadingID: collectingID)
            })
        return result
    }

    // MARK: - The two halves of the undo entry

    /// Inverse of `convertSmartReadingToCurated`: exact-row, like every
    /// other inverse. Tombstone precisely the memberships this conversion
    /// minted (never a blanket sweep — a row she added by hand after
    /// converting is hers), put the fresh collector back in its tombstone,
    /// and restore `kind` + the stored sort pair from the do-time
    /// pre-images.
    ///
    /// Refusal buckets, the standing ones: a book deleted meanwhile ⇒
    /// obsolete, quiet (its cascade already took the memberships); a book
    /// FINISHED meanwhile ⇒ throws, so the entry stays on the stack for
    /// retry after un-finishing.
    func revertSmartConversion(
        readingID: String, membershipIDs: [String],
        sortField: SortField, sortDir: SortDirection,
        collectingReadingID: String?
    ) throws {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID),
                  reading.deletedAt == nil
            else { return }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            let now = date.now
            for id in membershipIDs {
                guard var membership = try ReadingPost.fetchOne(db, key: id),
                      membership.deletedAt == nil
                else { continue }
                membership.deletedAt = now
                try membership.update(db)
            }
            if let collectingReadingID,
               var fresh = try Reading.fetchOne(db, key: collectingReadingID),
               fresh.deletedAt == nil {
                fresh.deletedAt = now
                fresh.updatedAt = now
                try fresh.update(db)
            }
            guard reading.kind != .gathering || reading.sortField != sortField
                || reading.sortDir != sortDir
            else { return }
            reading.kind = .gathering
            reading.sortField = sortField
            reading.sortDir = sortDir
            reading.updatedAt = now
            try reading.update(db)
        }
    }

    /// The RE-APPLY half (13c 1B's contract: a re-apply is exact-row, never
    /// a re-run of the forward operation — re-running would mint fresh
    /// UUIDs and strand the inverse's captured ids). The same membership
    /// rows come back out of their tombstones and the kind/sort flip is
    /// re-applied.
    ///
    /// A membership whose POST has since died stays dead (`restoreReading`'s
    /// live-parent guard — a live pointer at a dead post helps nobody), and
    /// a pair that somehow already has a live row is skipped rather than
    /// duplicated (`uq_reading_post_live`).
    func reapplySmartConversion(
        readingID: String, membershipIDs: [String], collectingReadingID: String?
    ) throws {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID),
                  reading.deletedAt == nil
            else { return }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            let now = date.now
            for id in membershipIDs {
                guard var membership = try ReadingPost.fetchOne(db, key: id),
                      membership.deletedAt != nil
                else { continue }
                let postIsLive = try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM container "
                        + "WHERE id = ? AND deleted_at IS NULL)",
                    arguments: [membership.postId]) ?? false
                guard postIsLive else { continue }
                guard try livePairRow(
                    db, postID: membership.postId, readingID: readingID) == nil
                else { continue }
                membership.deletedAt = nil
                try membership.update(db)
            }
            if let collectingReadingID,
               var fresh = try Reading.fetchOne(db, key: collectingReadingID),
               fresh.deletedAt != nil {
                fresh.deletedAt = nil
                fresh.updatedAt = now
                try fresh.update(db)
            }
            guard reading.kind != .book || reading.sortField != .manual else { return }
            reading.kind = .book
            reading.sortField = .manual
            reading.updatedAt = now
            try reading.update(db)
        }
    }
}
