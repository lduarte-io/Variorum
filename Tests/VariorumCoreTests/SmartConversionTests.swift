import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// Phase 13c, Batch 2D — the smart→curated conversion (committed scope C2 /
/// ledger N38) and the read-time ORDER override (her A31).
///
/// Both are NEW surface, so red-on-old is STRUCTURAL for this suite: neither
/// `convertSmartReadingToCurated` nor `Queries.ReadingOrder` existed before
/// this batch, and every test here fails to compile against the pre-2D tree.
/// What the suite pins is the CONTRACT the memo's shape A promises:
///
/// - conversion materializes exactly what she was LOOKING at, in that order,
///   and the book is an ordinary curated book from that instant;
/// - it is ONE transaction — a refusal leaves nothing half-converted;
/// - what rides the row untouched (spec, grouping tag, extents, finish) —
///   and no sibling is ever minted (ladder F-R1-5 retired the
///   "(collecting)" offer's dead parameters with their pins);
/// - undo is exact-row and redo ping-pongs on the same ids (the 1B contract);
/// - the order override is a way of LOOKING: `assembleReading(order: X)`
///   returns byte-identically to `setReadingSort(X)` + `assembleReading()`,
///   and writes nothing.
@Suite("Smart→curated conversion + read-time order (13c 2D — N38, A31)")
struct SmartConversionTests {
    // MARK: - Helpers

    /// A smart book collecting `#tag`, plus `count` posts tagged into it,
    /// created oldest-first so `created_at` order is `p0 … pN`.
    private func smartBookWithTaggedPosts(
        _ ops: Operations, tag path: String = "work", count: Int
    ) throws -> (reading: Reading, posts: [Container], tag: VariorumCore.Tag) {
        let tag = try ops.createTag(name: path)
        let spec = try Queries.SmartQuerySpec(tags: [path]).encodedJSON()
        let reading = try ops.createReading(name: "collected", kind: .gathering, querySpec: spec)
        var posts: [Container] = []
        for i in 0..<count {
            let post = try ops.createPost(title: "post \(i)")
            _ = try ops.applyTag(tag.id, toPost: post.id)
            posts.append(post)
        }
        return (reading, posts, tag)
    }

    private func liveMemberships(_ db: AppDatabase, _ readingID: String) throws -> [ReadingPost] {
        try db.read { db in
            try ReadingPost.fetchAll(
                db,
                sql: """
                    SELECT * FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [readingID])
        }
    }

    // MARK: - The conversion's exact state transition

    @Test func conversionMaterializesTheCurrentResultsInTheOrderSheWasLookingAt() throws {
        try withOperations { ops, db in
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 3)
            // She is reading it NEWEST-first; that is what must be frozen.
            try ops.setReadingSort(reading.id, field: .createdAt, direction: .desc)
            let before = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(before.map(\.postID) == [posts[2].id, posts[1].id, posts[0].id])
            #expect(try liveMemberships(db, reading.id).isEmpty)  // derived, no rows

            let result = try ops.convertSmartReadingToCurated(reading.id)

            // Rows written: exactly three memberships, in that order.
            let rows = try liveMemberships(db, reading.id)
            #expect(rows.map(\.postId) == [posts[2].id, posts[1].id, posts[0].id])
            #expect(rows.map(\.id) == result.membershipIDs)
            #expect(rows.allSatisfy { $0.sectionId == nil })

            // The row flipped: curated, manual — so NOTHING moves on screen.
            let after = try db.read { try Queries.reading($0, id: reading.id) }
            #expect(after?.kind == .book)
            #expect(after?.sortField == .manual)
            let entries = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(entries.map(\.postID) == before.map(\.postID))
        }
    }

    /// 13c K6 review, K2 (MAJOR — red-on-old by behavioral revert: drop the
    /// `order:` forwarding inside `convertSmartReadingToCurated` and the
    /// minted rows land in the STORED order, failing both halves below).
    ///
    /// The mechanism the fix closes: A31's view-order override and the
    /// conversion shipped in the same batch, on the same surface — so "the
    /// order she is looking at" can differ from the stored sort, and a
    /// conversion that read only the stored pair froze an order she was NOT
    /// looking at. The offer sheet's own sentence ("Its current N posts
    /// stay, in the order you're looking at them") was false exactly then,
    /// and the mismatch surfaced only later, when dropping the override
    /// reordered the book under her.
    @Test func conversionUnderAViewOrderOverrideFreezesTheOrderSheIsLookingAt() throws {
        try withOperations { ops, db in
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 3)
            // Stored order: created ASC (the smart-manual fallback) — what
            // every reader sees until she saves something else.
            let stored = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(stored.map(\.postID) == [posts[0].id, posts[1].id, posts[2].id])

            // She is LOOKING through the A31 override: newest first.
            let looking = Queries.ReadingOrder(field: .createdAt, direction: .desc)
            let seen = try db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id, order: looking)
            }
            #expect(seen.map(\.postID) == [posts[2].id, posts[1].id, posts[0].id],
                    "non-vacuity: the override order differs from the stored one")

            try ops.convertSmartReadingToCurated(reading.id, order: looking)

            // The rows freeze the order she SAW, not the stored pair.
            let rows = try liveMemberships(db, reading.id)
            #expect(rows.map(\.postId) == seen.map(\.postID))

            // …and the converted book (manual, no override) now READS in
            // that same order — nothing moves when the override drops.
            let after = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(after.map(\.postID) == seen.map(\.postID))
        }
    }

    @Test func theSpecAndTheGroupingTagRideTheRowAsProvenanceAndKeepWorking() throws {
        try withOperations { ops, db in
            let root = try ops.createTag(name: "life")
            let child = try ops.createTag(parent: root.id, name: "goals")
            let spec = try Queries.SmartQuerySpec(tags: ["life"]).encodedJSON()
            let reading = try ops.createReading(
                name: "grouped", kind: .gathering, groupingTagId: root.id, querySpec: spec)
            let post = try ops.createPost(title: "one")
            _ = try ops.applyTag(child.id, toPost: post.id)

            let grouped = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(grouped.map(\.sectionPath) == ["life/goals"])

            try ops.convertSmartReadingToCurated(reading.id)

            let row = try db.read { try Queries.reading($0, id: reading.id) }
            // 13i-a: the stored rule is the normalized v2 value (the tag
            // by ID); conversion still keeps it on the row untouched.
            #expect(row?.querySpec == (try RuleGrammar.encode(.tag(root.id))))
            #expect(row?.groupingTagId == root.id)
            // The derived sections SURVIVE — curated assembly honors a
            // grouping tag while the book has no live chapters. Real
            // chapters take over the moment she makes one (shipped rule).
            let after = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(after.map(\.sectionPath) == ["life/goals"])

            _ = try ops.createSection(in: reading.id, name: "I")
            let chaptered = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(chaptered.map(\.sectionPath) == [nil])  // unfiled, trailing
        }
    }

    /// 13i-d U4 ACT 0 (F-U3-1, the (c) arm RULED): the ops refuse a
    /// gathering's finish and non-nil extents now, so the LEGACY gathering
    /// these conversion pins start from (a pre-13i-d store, or another
    /// device's synced row) is staged as the raw row it is — the fixture
    /// moved, never an assertion.
    private func stageLegacy(
        _ db: AppDatabase, _ id: String,
        locked: Bool = false, maxPosts: Int? = nil, wordTarget: Int? = nil
    ) throws {
        try db.write { db in
            try db.execute(
                sql: "UPDATE reading SET locked = ?, max_posts = ?, word_target = ? WHERE id = ?",
                arguments: [locked ? 1 : 0, maxPosts, wordTarget, id])
        }
    }

    @Test func theCapIsHonoredSoTheBookIsNeverBornOverItsOwnCapacity() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 4)
            try stageLegacy(db, reading.id, maxPosts: 2)
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(shown.count == 2)

            let result = try ops.convertSmartReadingToCurated(reading.id)
            #expect(result.membershipIDs.count == 2)
            #expect(try liveMemberships(db, reading.id).map(\.postId) == shown.map(\.postID))

            // …and the standing capacity gate holds against it immediately.
            let extra = try ops.createPost()
            #expect(throws: OperationError.self) {
                try ops.addPostToReading(extra.id, to: reading.id)
            }
        }
    }

    @Test func extentsAndFinishRideTheConvertedRowUntouched() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 1)
            try stageLegacy(db, reading.id, maxPosts: 9, wordTarget: 5_000)

            try ops.convertSmartReadingToCurated(reading.id)

            let row = try db.read { try Queries.reading($0, id: reading.id) }
            #expect(row?.maxPosts == 9)
            #expect(row?.wordTarget == 5_000)
            #expect(row?.locked == false)
        }
    }

    // MARK: - The bind mints no sibling and keeps collecting (13i-b; ladder F-R1-5)

    /// *(Ladder F-R1-5 — the retirement's pin, replacing the three
    /// "(collecting)"-offer pins: the sibling's reason was N38 shape A's
    /// stops-collecting, superseded by §14.6, and the dead parameters could
    /// still mint a door-less double-collector.)* The bind touches exactly
    /// ONE reading row — the gathering's own, flipped in place (§19.6) —
    /// and the BOUND book itself keeps collecting: the rule rides the row,
    /// so intake seats a fresh tagging act's match at the END. The deliberate
    /// sibling road is the SPAWN door (`BindDoorTests`).
    @Test func theBindMintsNoSiblingAndTheBoundBookKeepsCollecting() throws {
        try withOperations { ops, db in
            let (reading, posts, tag) = try smartBookWithTaggedPosts(ops, count: 2)
            let before = try db.read { try Queries.readings($0).count }

            _ = try ops.convertSmartReadingToCurated(reading.id)
            #expect(try db.read { try Queries.readings($0).count } == before,
                    "one row, flipped in place — never a second book")

            let newcomer = try ops.createPost(title: "later")
            _ = try ops.applyTag(tag.id, toPost: newcomer.id)
            #expect(try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                .map(\.postID) == [posts[0].id, posts[1].id, newcomer.id],
                "§14.6: the bound book seats the fresh match at the end")
        }
    }

    // MARK: - Refusals, and the one-transaction promise

    @Test func aFinishedBookRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 2)
            try stageLegacy(db, reading.id, locked: true)

            #expect(throws: OperationError.self) {
                try ops.convertSmartReadingToCurated(reading.id)
            }
            // Nothing half-converted: no memberships, no second book, kind
            // untouched.
            #expect(try liveMemberships(db, reading.id).isEmpty)
            #expect(try db.read { try Queries.readings($0).count } == 1)
            #expect(try db.read { try Queries.reading($0, id: reading.id)?.kind } == .gathering)
        }
    }

    @Test func anAlreadyCuratedBookRefusesAsTheWrongKind() throws {
        try withOperations { ops, _ in
            let reading = try ops.createReading(name: "hand-shaped", kind: .book)
            #expect(throws: OperationError.self) {
                try ops.convertSmartReadingToCurated(reading.id)
            }
        }
    }

    @Test func aDeletedBookRefusesAsMissing() throws {
        try withOperations { ops, _ in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 1)
            try ops.deleteReading(reading.id)
            #expect(throws: OperationError.self) {
                try ops.convertSmartReadingToCurated(reading.id)
            }
        }
    }

    // MARK: - Undo / redo (the 13c 1B contract, applied here)

    @Test func undoRestoresTheSmartBookExactlyAndRedoPutsTheSameRowsBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 3)
            try ops.setReadingSort(reading.id, field: .createdAt, direction: .desc)

            let result = try ops.convertSmartReadingToCurated(reading.id)

            #expect(stack.topLabel == "Convert to Book")
            try stack.undo(with: ops)

            let undone = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(undone.kind == .gathering)
            #expect(undone.sortField == .createdAt)
            #expect(undone.sortDir == .desc)
            #expect(try liveMemberships(db, reading.id).isEmpty)
            // Still a working smart book afterwards.
            #expect(
                try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == [posts[2].id, posts[1].id, posts[0].id])

            try stack.redo(with: ops)

            let redone = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(redone.kind == .book)
            #expect(redone.sortField == .manual)
            // EXACT rows — the same membership ids, not fresh ones, and
            // (ladder F-R1-1) each restored AS a member: the revert flips
            // its taken rows to the dismissal class, so a redo that forgot
            // statuses would return her members as arrivals.
            let revived = try liveMemberships(db, reading.id)
            #expect(revived.map(\.id) == result.membershipIDs)
            #expect(revived.allSatisfy { $0.status == .member },
                    "members return as members — the redo restores statuses, not only ids")
        }
    }

    /// **Rewritten at 13i-b U3 — the ruled new truth (P-13ib-6).** This pin
    /// used to assert the opposite — "undo tombstones only what the
    /// conversion minted; a row she added by hand is hers" — which left that
    /// row LIVE on a GATHERING, and a gathering holds nothing (the sitting
    /// record §1). The architect's ruling: the undo takes every live row,
    /// hand-added included; the REDO is her road back to it (the
    /// `undoingABind…` pins below hold the exact-row round trip).
    @Test func undoTakesHerHandAddedRowTooAndAFreshBindStillWorks() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 1)
            try ops.convertSmartReadingToCurated(reading.id)

            // She adds a post by hand to her new book…
            let byHand = try ops.createPost(title: "by hand")
            let handRow = try ops.addPostToReading(byHand.id, to: reading.id)

            // …then undoes the bind: the gathering holds nothing.
            try stack.undo(with: ops)
            #expect(try liveMemberships(db, reading.id).isEmpty)
            let dead = try #require(try db.read { try ReadingPost.fetchOne($0, key: handRow.id) })
            #expect(dead.deletedAt != nil, "her row is tombstoned, not destroyed")

            // A FRESH bind (not the redo) materializes the gathering's
            // current assembly — the one tagged note — and the tombstoned
            // hand row never trips `uq_reading_post_live`.
            let again = try ops.convertSmartReadingToCurated(reading.id)
            #expect(!again.membershipIDs.contains(handRow.id))
            #expect(try liveMemberships(db, reading.id).map(\.postId) == [posts[0].id])
        }
    }

    /// **Binding preserves identity** (the sitting record §19.6, ratified §20:
    /// "the gathering's row IS the book's row (same id; the mode flips) —
    /// name, star, shelf spot, glyphless chip, everything survives the
    /// bind"). The shelf row is staged by direct insert — no shelf door
    /// exists before 13i-d — exactly as the 13i-a hand-off pins stage state.
    @Test func bindingPreservesTheRowsIdentityNameStarShelfSpotAndWing() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 2)
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO shelf (id, wing_id, name, position, created_at, updated_at)
                    VALUES ('shelf-1', '', 'Work', 'a0', '2026-01-01T00:00:00.000Z',
                            '2026-01-01T00:00:00.000Z')
                    """)
                try db.execute(
                    sql: """
                        UPDATE reading SET shelf_id = 'shelf-1', shelf_position = 'b7',
                               starred = 1 WHERE id = ?
                        """,
                    arguments: [reading.id])
            }
            let before = try #require(try db.read { try Queries.reading($0, id: reading.id) })

            let result = try ops.convertSmartReadingToCurated(reading.id)

            let after = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(result.reading.id == before.id)
            #expect(after.id == before.id)
            #expect(after.name == before.name)
            #expect(after.starred == true)
            #expect(after.shelfId == "shelf-1")
            #expect(after.shelfPosition == "b7")
            #expect(after.wingId == before.wingId)
            #expect(after.querySpec == before.querySpec, "the rule rides the row — it keeps collecting")
            #expect(after.kind == .book)
            #expect(try db.read { try Queries.readings($0).count } == 1, "no second row")
        }
    }

    // MARK: - P-13ib-6 (13i-b U3 — the architect's ruling, PROVISIONAL)

    /// **Undoing a BIND leaves NO live row on the reverted row — a gathering
    /// holds nothing** (the sitting record §1's table is the law). Since U1 a
    /// bound book keeps collecting, so rows the bind did NOT mint stand on it
    /// by the time an undo comes: intake's seats (no hand involved — F-4) and
    /// her hand-adds alike. The pre-U3 inverse tombstoned only the do-time
    /// minted ids, leaving those rows live on a GATHERING — invisible in its
    /// assembly, but counted as membership by the Pool exclusion and
    /// `readingsContaining`'s membership leg.
    ///
    /// RED-ON-OLD (by behavioural revert, verified): on the pre-U3 inverse the
    /// "a gathering holds nothing" expectation fails with the intake-seated
    /// row and the hand-added row still live. The redo half is the exact-row
    /// contract (AppSpec §9): every row the undo tombstoned comes back, by id.
    @Test func undoingABindLeavesNoLiveRowAndRedoBringsEveryRowBackByID() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, tag) = try smartBookWithTaggedPosts(ops, count: 2)
            let bound = try ops.convertSmartReadingToCurated(reading.id)
            #expect(bound.membershipIDs.count == 2)

            // It keeps collecting: a fresh tagging act SEATS a newcomer (a row
            // the bind never minted) …
            let later = try ops.createPost(title: "later")
            _ = try ops.applyTag(tag.id, toPost: later.id)
            // … and she adds one by hand.
            let byHand = try ops.createPost(title: "by hand")
            let handRow = try ops.addPostToReading(byHand.id, to: reading.id)
            let beforeUndo = try liveMemberships(db, reading.id)
            #expect(Set(beforeUndo.map(\.postId))
                    == Set([posts[0].id, posts[1].id, later.id, byHand.id]),
                    "non-vacuity: the intake seat and the hand-add both stand")
            #expect(beforeUndo.contains { $0.id == handRow.id })

            #expect(stack.topLabel == "Convert to Book")
            try stack.undo(with: ops)

            let undone = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(undone.kind == .gathering)
            #expect(try liveMemberships(db, reading.id).isEmpty,
                    "a gathering holds nothing — every live row tombstones at the revert")
            // Its matches still SHOW (a gathering assembles; the hand-added
            // note is no match, so it is simply not shown here any more).
            #expect(Set(try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                .map(\.postID)) == Set([posts[0].id, posts[1].id, later.id]))

            try stack.redo(with: ops)
            let redone = try liveMemberships(db, reading.id)
            #expect(Set(redone.map(\.id)) == Set(beforeUndo.map(\.id)),
                    "the redo revives exactly the rows the undo took — the same ids")
            #expect(redone.allSatisfy { $0.status == .member },
                    "…and as what they were: members return as members (ladder F-R1-1)")
            #expect(try db.read { try Queries.reading($0, id: reading.id)?.kind } == .book)
        }
    }

    /// The same law for a waiting ARRIVAL: a gathering has no door, so an
    /// arrival row standing on the bound book at the undo tombstones with the
    /// members — and the redo brings it back AS an arrival (its status rides
    /// the row untouched).
    @Test func undoingABindTakesAWaitingArrivalAndRedoReturnsItWaiting() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, _, tag) = try smartBookWithTaggedPosts(ops, count: 1)
            try ops.convertSmartReadingToCurated(reading.id)
            try ops.setReadingIntakeSeating(reading.id, .arrivals)
            let newcomer = try ops.createPost(title: "newcomer")
            _ = try ops.applyTag(tag.id, toPost: newcomer.id)
            let waiting = try #require(try liveMemberships(db, reading.id)
                .first { $0.postId == newcomer.id })
            #expect(waiting.status == .arrival, "non-vacuity: the dial sent it to the door")

            try stack.undo(with: ops)
            #expect(try liveMemberships(db, reading.id).isEmpty)

            try stack.redo(with: ops)
            let back = try #require(try liveMemberships(db, reading.id)
                .first { $0.id == waiting.id })
            #expect(back.status == .arrival)
        }
    }

    /// **F-R1-1 (ladder round 1, the architect's ruling):** an un-bind's
    /// residue ranks as the DISMISSAL class, never as left-as-member. The
    /// pre-fix inverse tombstoned rows with `status='member'`, and under U1's
    /// tombstone-means-decided a member tombstone is "removed for good" — so
    /// after a RE-BIND, any pair that was a member at the undo but out of the
    /// assembly at the re-bind was permanently deaf to intake: a fresh
    /// applying act answered silence, against the bind sheet's own
    /// keeps-collecting promise. The ruling's ground is her ratified U1-1
    /// ("if there's a new tag on there, i might want it to come in"): an
    /// un-bind says "I take back the binding," not "these notes never
    /// belong." A member she REMOVED BY HAND keeps its member-class
    /// tombstone — removed stays out, exactly as ratified.
    ///
    /// RED-ON-OLD (watched): on the pre-fix inverse the `#require` below
    /// fails — the pair keeps its one member-class tombstone and no row
    /// rings. The control (a note still matching at the re-bind) is green on
    /// both sides.
    @Test func anUndoneBindsResidueRingsAgainAsAnArrivalAfterARebind() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, tag) = try smartBookWithTaggedPosts(ops, count: 2)
            try ops.convertSmartReadingToCurated(reading.id)
            try stack.undo(with: ops)

            // A leaves the assembly before the re-bind; B stays (the control).
            try ops.removeTag(tag.id, fromPost: posts[0].id)
            _ = try ops.convertSmartReadingToCurated(reading.id)
            #expect(try liveMemberships(db, reading.id).map(\.postId) == [posts[1].id],
                    "control: the still-matching note re-binds as a member")

            // The fresh applying act on A: the residue is the dismissal
            // class, so A RINGS AGAIN — a LIVE ARRIVAL exactly (P-13ib-U1-1:
            // never auto-seated over a dismissal; a seat here would override
            // the ruling's class as surely as silence betrays it).
            _ = try ops.applyTag(tag.id, toPost: posts[0].id)
            let rung = try #require(
                try liveMemberships(db, reading.id).first { $0.postId == posts[0].id },
                "the re-bound book must HEAR the fresh act on an un-bind residue pair")
            #expect(rung.status == .arrival,
                    "exactly an arrival — judged by her, never seated by the machine")
        }
    }

    /// THE CONTROL (the sanity pass's item 1, taken at the closeout): a
    /// member she REMOVED BY HAND before the undo keeps its member-class
    /// tombstone through the un-bind — the revert takes only LIVE rows —
    /// so the pair stays DECIDED against a fresh act (removed stays out,
    /// her ratified U1-1 boundary). Green on both sides by construction;
    /// a guard, not a red-on-old.
    @Test func aHandRemovedMemberStaysRemovedThroughAnUnbind() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, tag) = try smartBookWithTaggedPosts(ops, count: 2)
            try ops.convertSmartReadingToCurated(reading.id)
            try ops.removePostFromReading(posts[0].id, from: reading.id)
            try stack.undo(with: ops)

            let removedRow = try #require(
                try db.read { database in
                    try ReadingPost.fetchAll(
                        database,
                        sql: """
                            SELECT * FROM reading_post
                            WHERE reading_id = ? AND post_id = ? AND deleted_at IS NOT NULL
                            """,
                        arguments: [reading.id, posts[0].id])
                }.first,
                "her removal's tombstone survives the un-bind")
            #expect(removedRow.status == .member,
                    "the hand-removal keeps its MEMBER-class tombstone — never flipped")

            // The F-R1-1 pin's own staging, expecting the OPPOSITE: untag
            // (so the note leaves the assembly), RE-BIND (a deliberate bind
            // re-members only what the gathering shows), then the fresh
            // applying act — a hand-REMOVED pair stays silent where a
            // dismissed one rings (the ratified boundary).
            try ops.removeTag(tag.id, fromPost: posts[0].id)
            _ = try ops.convertSmartReadingToCurated(reading.id)
            _ = try ops.applyTag(tag.id, toPost: posts[0].id)
            #expect(try liveMemberships(db, reading.id)
                .allSatisfy { $0.postId != posts[0].id },
                "removed stays out: no live row of any status for the pair")
        }
    }

    @Test func aRedoWhoseMemberPostDiedLeavesThatMembershipDead() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 2)
            try ops.convertSmartReadingToCurated(reading.id)
            try stack.undo(with: ops)
            // The member dies BELOW the operations layer — a remote
            // tombstone arriving through a sync apply, which registers no
            // undo entry and clears no redo future. (This used to press
            // `deleteContainer`; since 17b P6 that door clears the future
            // like every other new structural act, so it can no longer
            // stage this state — the re-apply's liveness guard is still
            // exactly what is under test.)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE container SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: ["2026-01-01T00:00:00.000Z", "2026-01-01T00:00:00.000Z",
                                posts[0].id])
            }

            try stack.redo(with: ops)
            let rows = try liveMemberships(db, reading.id)
            #expect(rows.map(\.postId) == [posts[1].id])
        }
    }

    @Test func aConversionUndoneUnderAFinishedBookStaysOnTheStackForRetry() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 1)
            try ops.convertSmartReadingToCurated(reading.id)
            try ops.lockReading(reading.id)

            #expect(throws: OperationError.self) { try stack.undo(with: ops) }
            #expect(stack.depth == 1)
            #expect(try db.read { try Queries.reading($0, id: reading.id)?.kind } == .book)

            try ops.unlockReading(reading.id)
            try stack.undo(with: ops)
            #expect(try db.read { try Queries.reading($0, id: reading.id)?.kind } == .gathering)
        }
    }

    @Test func conversionWritesThroughTheOutboxLikeAnyOtherOperation() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 2)
            try db.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
            let result = try ops.convertSmartReadingToCurated(reading.id)

            let queued = try db.read { db in
                try Row.fetchAll(db, sql: "SELECT table_name, row_id FROM sync_outbox")
                    .map { ($0["table_name"] as String, $0["row_id"] as String) }
            }
            #expect(queued.contains { $0 == ("reading", reading.id) })
            for id in result.membershipIDs {
                #expect(queued.contains { $0 == ("reading_post", id) })
            }
        }
    }

    // MARK: - A31: the read-time order override

    @Test func anOrderOverrideReturnsExactlyWhatSavingItWouldShow() throws {
        // The whole promise of a preview, pinned: browse == save-then-look.
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "book", kind: .book)
            var posts: [Container] = []
            for (i, day) in ["2026-03-02", "2026-01-05", "2026-02-09"].enumerated() {
                let post = try ops.createPost(title: "p\(i)", entryDate: day)
                try ops.addPostToReading(post.id, to: reading.id)
                posts.append(post)
            }
            let orders: [Queries.ReadingOrder] = [
                .init(field: .entryDate, direction: .asc),
                .init(field: .entryDate, direction: .desc),
                .init(field: .createdAt, direction: .asc),
                .init(field: .lastTouched, direction: .desc),
                .init(field: .manual, direction: .asc),
            ]
            for order in orders {
                let browsed = try db.read {
                    try Queries.assembleReading($0, readingID: reading.id, order: order)
                }
                try ops.setReadingSort(
                    reading.id, field: order.field, direction: order.direction)
                let saved = try db.read {
                    try Queries.assembleReading($0, readingID: reading.id)
                }
                #expect(browsed == saved, "order \(order) diverged between browse and save")
            }
            #expect(posts.count == 3)
        }
    }

    @Test func browsingByAnAttributeWritesNothingAndKeepsTheHandOrderIntact() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "book", kind: .book)
            let late = try ops.createPost(title: "late", entryDate: "2026-05-01")
            let early = try ops.createPost(title: "early", entryDate: "2026-01-01")
            try ops.addPostToReading(late.id, to: reading.id)
            try ops.addPostToReading(early.id, to: reading.id)  // her hand order

            try db.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
            let byDate = try db.read {
                try Queries.assembleReading(
                    $0, readingID: reading.id,
                    order: .init(field: .entryDate, direction: .asc))
            }
            #expect(byDate.map(\.postID) == [early.id, late.id])
            // A way of looking writes nothing at all.
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") } == 0)
            #expect(try db.read { try Queries.reading($0, id: reading.id)?.sortField } == .manual)
            // …and her own order is still exactly there.
            #expect(
                try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == [late.id, early.id])
        }
    }

    @Test func anOverrideOrdersWithinChaptersRatherThanFlatteningThem() throws {
        // Chapters keep governing — the same precedence a STORED stamp sort
        // has always had on a chaptered book. One rule, not two.
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "book", kind: .book)
            let one = try ops.createSection(in: reading.id, name: "I")
            let two = try ops.createSection(in: reading.id, name: "II")
            let lateInOne = try ops.createPost(title: "late-I", entryDate: "2026-09-01")
            let earlyInOne = try ops.createPost(title: "early-I", entryDate: "2026-01-01")
            let midInTwo = try ops.createPost(title: "mid-II", entryDate: "2026-05-01")
            for post in [lateInOne, earlyInOne, midInTwo] {
                try ops.addPostToReading(post.id, to: reading.id)
            }
            try ops.assignPostToSection(lateInOne.id, in: reading.id, section: one.id)
            try ops.assignPostToSection(earlyInOne.id, in: reading.id, section: one.id)
            try ops.assignPostToSection(midInTwo.id, in: reading.id, section: two.id)

            let byDate = try db.read {
                try Queries.assembleReading(
                    $0, readingID: reading.id,
                    order: .init(field: .entryDate, direction: .asc))
            }
            #expect(byDate.map(\.postID) == [earlyInOne.id, lateInOne.id, midInTwo.id])
            #expect(byDate.map(\.sectionPath) == ["I", "I", "II"])
        }
    }

    @Test func anOverrideAppliesBeforeTheWindowNotAfterIt() throws {
        // The reason the parameter belongs in the query: with a window, a
        // post-fetch re-sort would sort the first N of the OLD order.
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "book", kind: .book)
            var posts: [Container] = []
            for i in 0..<5 {
                let post = try ops.createPost(
                    title: "p\(i)", entryDate: String(format: "2026-01-%02d", 5 - i))
                try ops.addPostToReading(post.id, to: reading.id)
                posts.append(post)
            }
            let windowed = try db.read {
                try Queries.assembleReading(
                    $0, readingID: reading.id, limit: 2,
                    order: .init(field: .entryDate, direction: .asc))
            }
            // The two EARLIEST-dated posts, which are the last two she added.
            #expect(windowed.map(\.postID) == [posts[4].id, posts[3].id])
        }
    }

    @Test func aSmartBookBrowsesByAnAttributeToo() throws {
        try withOperations { ops, db in
            let (reading, posts, _) = try smartBookWithTaggedPosts(ops, count: 3)
            let byCreationDesc = try db.read {
                try Queries.assembleReading(
                    $0, readingID: reading.id,
                    order: .init(field: .createdAt, direction: .desc))
            }
            #expect(byCreationDesc.map(\.postID) == [posts[2].id, posts[1].id, posts[0].id])
            // The book's own order is the ratified created-ASC manual
            // fallback, untouched.
            #expect(
                try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == posts.map(\.id))
        }
    }
}
