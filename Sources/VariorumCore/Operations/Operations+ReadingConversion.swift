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
        /// 13i-c U2 — the assembly's notes OWNED ELSEWHERE (the owned-notes
        /// limb): under `.copyIn` each one's ceremony copy, standing in its
        /// slot; empty under `.leaveOut`.
        public var copied: [OwnershipFork] = []
        /// …and under `.leaveOut`, the notes left out (nothing materialized
        /// for them — "leave-out means gone from this book", §3).
        public var leftOut: [String] = []
    }

    /// **The bind's OWNED-NOTES LIMB** (13i-c U2 — the sitting record §3: "owned
    /// notes in the assembly can't materialize, so the confirm lists them:
    /// copy in / leave out"). A bound book is a plain book, so a note another
    /// book OWNS cannot become its member (the ownership table's `copyOnly`).
    public enum BindOwnedNotes: Equatable, Sendable {
        /// The DEFAULT (PROVISIONAL P-13ic-4 — copies are ceremonies, never
        /// silent): nothing materializes for them; they are gone from this
        /// book (a book shows members only — no ghost display, deliberately).
        case leaveOut
        /// A ceremony copy per such note (tags riding) takes its slot.
        case copyIn
    }

    /// Pre-images captured at do-time, so the inverse restores exact rows
    /// rather than re-deriving anything (the standing undo discipline).
    struct SmartConversionPreImage: Sendable {
        let sortField: SortField
        let sortDir: SortDirection
    }

    /// **THE BIND** (13i-b's recast of 13c 2D's conversion): a gathering's
    /// CURRENT assembly becomes real `reading_post` rows in the order she is
    /// looking at, and `kind` flips to book — the SAME row (§19.6). The rule
    /// stays on the row, so the bound book is a LIVING book: it keeps
    /// collecting (the sitting record §14.6).
    ///
    /// *(Ladder F-R1-5: the `keepCollecting`/`collectingName` parameters and
    /// the "(collecting)" sibling they minted are RETIRED — the sibling's
    /// reason was N38 shape A's "the converted book stops collecting", which
    /// §14.6 superseded; a reachable dead door that double-collected. The
    /// deliberate sibling road is the SPAWN door.)*
    ///
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
    ///   ordinary door can produce one on a gathering (`addPostToReading`
    ///   refuses `wrongReadingKind`) and the bind's own undo takes every
    ///   live row (P-13ib-6), but a sync-arrived stray can stand there —
    ///   and `uq_reading_post_live` would otherwise make the bind throw.
    ///   Defensive, cheap.
    ///
    /// - `ownedNotes` *(13i-c U2 — the 13i-c plan §3/§4 row 6)*: the
    ///   assembly's notes OWNED ELSEWHERE consult the ownership table and
    ///   cannot materialize as plain members — `.leaveOut` (the default)
    ///   materializes nothing for them; `.copyIn` mints a ceremony copy per
    ///   note in its slot. `Queries.bindOwnedNotesPreview` lists them for the
    ///   confirm. The un-bind takes the copies' rows like any other row
    ///   standing on the book; the copies persist as the notes they are.
    @discardableResult
    public func convertSmartReadingToCurated(
        _ readingID: String,
        order: Queries.ReadingOrder? = nil,
        ownedNotes: BindOwnedNotes = .leaveOut
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
                var copied: [OwnershipFork] = []
                var leftOut: [String] = []
                for entry in entries {
                    guard try livePairRow(
                        db, postID: entry.postID, readingID: readingID) == nil
                    else { continue }
                    // 13i-c U2 — the owned-notes limb: the bound book is
                    // plain, so a note another book owns is `copyOnly`.
                    var memberID = entry.postID
                    let owner = try Queries.noteMemberships(
                        db, postID: entry.postID, excluding: readingID
                    ).first { $0.owned }
                    if let owner {
                        guard ownedNotes == .copyIn else {
                            leftOut.append(entry.postID)
                            continue
                        }
                        memberID = try ceremonyCopy(db, sourceID: entry.postID, now: now).id
                        copied.append(OwnershipFork(
                            originalID: entry.postID, copyID: memberID,
                            elsewhereNames: [owner.book.name]))
                    }
                    let membership = ReadingPost(
                        id: newID(), readingId: readingID, postId: memberID,
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

                return (
                    SmartConversionResult(
                        reading: reading, membershipIDs: membershipIDs,
                        copied: copied, leftOut: leftOut),
                    preImage)
            }

        // Structural undo (AppSpec §9): conversion mints N rows, changes a
        // book's kind, and may mint a whole second book — materially more
        // than the `addPostToReading` class that deliberately registers
        // nothing, and there is no "convert back" door to hand-reverse it
        // with (memo Q5's lean is that curated → smart should not exist).
        // Both halves ride the SAME do-time ids, so undo↔redo ping-pongs
        // without re-deriving membership (13c 1B's redo contract).
        //
        // P-13ib-6 (13i-b U3 — the architect's ruling): the inverse takes
        // EVERY live row standing on the book at the revert, not only the
        // do-time mints (a bound book keeps collecting, so intake's seats and
        // her hand-adds stand there too, and a gathering holds nothing). Those
        // rows exist only at UNDO time, so the inverse hands them to the redo
        // through this box — still exact-row (the same ids come back), never
        // a re-run. Each entry carries the row's UNDO-time STATUS beside its
        // id (ladder F-R1-1: the revert flips its rows to the dismissal
        // class, so the redo must restore what each row WAS — a member
        // returns a member, a waiting arrival returns waiting).
        // VX-246 U2: the box also carries the stamp the revert tombstoned
        // the rows on, so the redo revives only rows still dead on it; the
        // revert answers whether it changed anything (a book already deleted
        // — by her Delete since — is quiet, and retires the entry).
        let takenAtRevert = LockIsolated<SmartConversionUndone?>(nil)
        undoStack?.register(
            label: "Convert to Book",
            inverse: {
                let undone = try $0.revertSmartConversion(
                    readingID: readingID,
                    sortField: preImage.sortField, sortDir: preImage.sortDir)
                takenAtRevert.setValue(undone)
                return undone != nil
            },
            redo: {
                try $0.reapplySmartConversion(
                    readingID: readingID, undone: takenAtRevert.value)
            })
        return result
    }

    // MARK: - The two halves of the undo entry

    /// Inverse of `convertSmartReadingToCurated` (the BIND): restore `kind`
    /// + the stored sort pair from the do-time pre-images — and **tombstone
    /// EVERY live row standing on the book**, on one stamp (P-13ib-6, 13i-b U3 — the architect's
    /// ruling, PROVISIONAL): a gathering holds nothing (the sitting record §1),
    /// and since 13i-b U1 a bound book keeps collecting, so rows the bind
    /// never minted stand there by the time an undo comes — intake's seats,
    /// a waiting ARRIVAL, her hand-adds alike. *(This replaced "tombstone only
    /// what the conversion minted — a row she added by hand is hers", which
    /// left those rows live on a gathering: invisible in its assembly but
    /// counted as membership by the Pool exclusion and `readingsContaining`.)*
    /// Their notes keep showing wherever the rule matches them.
    ///
    /// **The taken rows rank as the DISMISSAL class** (ladder round 1
    /// F-R1-1 — the architect's ruling, PROVISIONAL, bundled beside
    /// P-13ib-U3-3): each row this revert takes flips to `status='arrival'`
    /// AS it tombstones, one write per row. A member-class tombstone means
    /// "removed for good" under U1's table, and an un-bind says "I take back
    /// the binding," never "these notes never belong" — her ratified U1-1
    /// ground ("if there's a new tag on there, i might want it to come in").
    /// So after a RE-BIND, a fresh applying act on a residue pair rings the
    /// bell again (an arrival, never an auto-seat) instead of permanent
    /// silence, and the bind sheet's keeps-collecting promise survives the
    /// round trip. A member she REMOVED BY HAND before the undo was already
    /// tombstoned and is untouched here — its member-class tombstone stands,
    /// removed stays out, exactly as ratified. *(Recorded, not built — the
    /// bundle carries both: the remove→re-add-by-hand→undo corner, where the
    /// OLDER member tombstone still outranks this flip in `intakePairState`;
    /// and the cross-device race where one device's un-bind flips a row
    /// another device hand-removed — server-wins CAS keeps one, and the
    /// worst case is her removal ranked as a dismissal: the note rings again
    /// as an ARRIVAL on a fresh act, never auto-seated. Self-limiting; no
    /// repair — zero `Sync/` stands.)*
    ///
    /// Returns `(id, undo-time status)` per taken row, in book order, so the
    /// REDO revives exactly those rows AS WHAT THEY WERE (exact-row —
    /// AppSpec §9; ids and statuses both survive the round trip).
    ///
    /// Refusal buckets, the standing ones: a book deleted meanwhile ⇒
    /// obsolete, quiet, nothing taken (its cascade already took the rows); a
    /// book FINISHED meanwhile ⇒ throws, so the entry stays on the stack for
    /// retry after un-finishing.
    /// What the revert did (VX-246 U2): the rows it took, each with its
    /// undo-time status, and the stamp it tombstoned them on.
    struct SmartConversionUndone: Sendable {
        let taken: [(id: String, status: MembershipStatus)]
        let stamp: String
    }

    /// Returns what it did — nil when it changed nothing (the book gone, or
    /// already the gathering it was with no row standing).
    @discardableResult
    func revertSmartConversion(
        readingID: String,
        sortField: SortField, sortDir: SortDirection
    ) throws -> SmartConversionUndone? {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID),
                  reading.deletedAt == nil
            else { return nil }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            let now = date.now
            let standing = try ReadingPost.fetchAll(
                db,
                sql: """
                    SELECT * FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [readingID])
            for var row in standing {
                row.status = .arrival  // the dismissal class (F-R1-1)
                row.deletedAt = now
                try row.update(db)
            }
            // Pre-images by construction: the loop mutates COPIES (`var
            // row`), so `standing`'s elements still carry each row's
            // undo-time status.
            let undone = SmartConversionUndone(
                taken: standing.map { (id: $0.id, status: $0.status) },
                stamp: DateFormatter.variorumISO8601.string(from: now))
            guard reading.kind != .gathering || reading.sortField != sortField
                || reading.sortDir != sortDir
            else { return standing.isEmpty ? nil : undone }
            reading.kind = .gathering
            reading.sortField = sortField
            reading.sortDir = sortDir
            reading.updatedAt = now
            try reading.update(db)
            return undone
        }
    }

    /// The RE-APPLY half (13c 1B's contract: a re-apply is exact-row, never
    /// a re-run of the forward operation — re-running would mint fresh
    /// UUIDs and strand the inverse's captured ids). The rows the INVERSE
    /// took (P-13ib-6 — every live row at the revert, handed over by the
    /// registration's box) come back out of their tombstones **as what they
    /// were** — each restored to its captured undo-time STATUS (ladder
    /// F-R1-1: the revert flipped them to the dismissal class, so without
    /// this a redo would return her members as arrivals): a member returns
    /// a member, a waiting arrival returns waiting. The kind/sort flip is
    /// re-applied.
    ///
    /// A membership whose POST has since died stays dead (`restoreReading`'s
    /// live-parent guard — a live pointer at a dead post helps nobody), and
    /// a pair that somehow already has a live row is skipped rather than
    /// duplicated (`uq_reading_post_live`).
    ///
    /// **13i-d U6 ACT 0 (F-U5b-2, RULED (a)):** if ANY row it would revive
    /// now pairs a note and this book across WINGS (a member moved away
    /// while the book was unbound, or the gathering itself moved), the whole
    /// redo is OBSOLETE — quiet, nothing written, the gathering stays a
    /// gathering: the deleted bucket's shape, checked before any write and
    /// ahead of the finished throw (the ruled letter: an inverse whose
    /// revival would cross treats its ENTRY as obsolete — PROVISIONAL
    /// P-13id-U6-1 records the row-level alternative). A fresh bind by hand
    /// gives the current assembly, which is wing-scoped by construction.
    /// Returns whether it re-applied anything (VX-246 U2); revives only rows
    /// still dead on the revert's own stamp.
    @discardableResult
    func reapplySmartConversion(
        readingID: String, undone: SmartConversionUndone?
    ) throws -> Bool {
        guard let undone else { return false }
        return try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID),
                  reading.deletedAt == nil
            else { return false }
            // The rows this redo WOULD revive, read before any write (each
            // taken row is a distinct note — one live row per pair at the
            // revert — so reading them up front is the loop's own answer).
            var revivable: [(membership: ReadingPost, status: MembershipStatus)] = []
            for row in undone.taken {
                guard let membership = try ReadingPost.fetchOne(db, key: row.id),
                      membership.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == undone.stamp
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
                revivable.append((membership, row.status))
            }
            for entry in revivable {
                guard try Queries.membershipRevivalStaysInOneWing(
                    db, postID: entry.membership.postId, readingID: readingID)
                else { return false }
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            let now = date.now
            var revived: [String] = []
            var flipped = false
            for entry in revivable {
                var membership = entry.membership
                membership.status = entry.status
                membership.deletedAt = nil
                try membership.update(db)
                revived.append(membership.postId)
            }
            if reading.kind != .book || reading.sortField != .manual {
                reading.kind = .book
                reading.sortField = .manual
                reading.updatedAt = now
                try reading.update(db)
                flipped = true
            }
            // 13i-c U2 (the 13i-c plan §4 row 9): the redo REVIVES rows, so
            // ownership is re-asserted over them — a note claimed by an owned
            // book since the undo keeps its earliest membership; R2's shape.
            // AFTER the kind flip: the pass reads BOOKS' rows only, and until
            // the flip this row is a gathering's.
            try enforceOwnershipAfterRevival(db, postIDs: revived, now: now)
            return flipped || !revived.isEmpty
        }
    }
}
