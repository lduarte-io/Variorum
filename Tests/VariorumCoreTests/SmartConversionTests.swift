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
/// - what rides the row untouched (spec, grouping tag, extents, finish) and
///   what deliberately does not ride the fresh collector (extents, lock);
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

    @Test func theCapIsHonoredSoTheBookIsNeverBornOverItsOwnCapacity() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 4)
            try ops.setReadingMaxPosts(reading.id, maxPosts: 2)
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
            try ops.setReadingMaxPosts(reading.id, maxPosts: 9)
            try ops.setReadingWordTarget(reading.id, wordTarget: 5_000)

            try ops.convertSmartReadingToCurated(reading.id)

            let row = try db.read { try Queries.reading($0, id: reading.id) }
            #expect(row?.maxPosts == 9)
            #expect(row?.wordTarget == 5_000)
            #expect(row?.locked == false)
        }
    }

    // MARK: - The fresh-smart-book offer (the second half of her sentence)

    @Test func keepCollectingMintsASecondSmartBookOnTheSameFilter() throws {
        try withOperations { ops, db in
            let (reading, posts, tag) = try smartBookWithTaggedPosts(ops, count: 2)
            try ops.setReadingSort(reading.id, field: .entryDate, direction: .desc)
            let spec = try db.read { try Queries.reading($0, id: reading.id)?.querySpec }

            let result = try ops.convertSmartReadingToCurated(
                reading.id, keepCollecting: true)
            let fresh = try #require(result.collectingReading)

            #expect(fresh.kind == .gathering)
            #expect(fresh.name == "collected (collecting)")
            #expect(fresh.querySpec == spec)
            // The order it HAD, not the converted book's forced manual.
            #expect(fresh.sortField == .entryDate)
            #expect(fresh.sortDir == .desc)
            // Deliberately NOT carried: a collector born capped or finished
            // could not collect, which is the one thing it exists to do.
            #expect(fresh.maxPosts == nil)
            #expect(fresh.wordTarget == nil)
            #expect(fresh.locked == false)

            // It really collects: the converted book froze, the fresh one
            // takes the new match.
            let newcomer = try ops.createPost(title: "later")
            _ = try ops.applyTag(tag.id, toPost: newcomer.id)
            let frozen = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(Set(frozen.map(\.postID)) == Set(posts.map(\.id)))
            let collecting = try db.read {
                try Queries.assembleReading($0, readingID: fresh.id)
            }
            #expect(collecting.contains { $0.postID == newcomer.id })
        }
    }

    @Test func aBlankCollectingNameFallsBackToTheDefaultAndAGivenOneIsUsed() throws {
        try withOperations { ops, _ in
            let (a, _, _) = try smartBookWithTaggedPosts(ops, tag: "a", count: 0)
            let blank = try ops.convertSmartReadingToCurated(
                a.id, keepCollecting: true, collectingName: "   ")
            #expect(blank.collectingReading?.name == "collected (collecting)")

            let (b, _, _) = try smartBookWithTaggedPosts(ops, tag: "b", count: 0)
            let named = try ops.convertSmartReadingToCurated(
                b.id, keepCollecting: true, collectingName: "still #b")
            #expect(named.collectingReading?.name == "still #b")
        }
    }

    @Test func withoutTheOfferNoSecondBookExists() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 1)
            let before = try db.read { try Queries.readings($0).count }
            let result = try ops.convertSmartReadingToCurated(reading.id)
            #expect(result.collectingReading == nil)
            #expect(try db.read { try Queries.readings($0).count } == before)
        }
    }

    // MARK: - Refusals, and the one-transaction promise

    @Test func aFinishedBookRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 2)
            try ops.lockReading(reading.id)

            #expect(throws: OperationError.self) {
                try ops.convertSmartReadingToCurated(reading.id, keepCollecting: true)
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

            let result = try ops.convertSmartReadingToCurated(
                reading.id, keepCollecting: true)
            let freshID = try #require(result.collectingReading?.id)

            #expect(stack.topLabel == "Convert to Book")
            try stack.undo(with: ops)

            let undone = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(undone.kind == .gathering)
            #expect(undone.sortField == .createdAt)
            #expect(undone.sortDir == .desc)
            #expect(try liveMemberships(db, reading.id).isEmpty)
            #expect(try db.read { try Queries.reading($0, id: freshID) } == nil)
            // Still a working smart book afterwards.
            #expect(
                try db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == [posts[2].id, posts[1].id, posts[0].id])

            try stack.redo(with: ops)

            let redone = try #require(try db.read { try Queries.reading($0, id: reading.id) })
            #expect(redone.kind == .book)
            #expect(redone.sortField == .manual)
            // EXACT rows — the same membership ids, not fresh ones.
            #expect(try liveMemberships(db, reading.id).map(\.id) == result.membershipIDs)
            #expect(try db.read { try Queries.reading($0, id: freshID) } != nil)
        }
    }

    @Test func undoTombstonesOnlyWhatTheConversionMintedNotWhatSheAddedByHand() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let (reading, _, _) = try smartBookWithTaggedPosts(ops, count: 1)
            let result = try ops.convertSmartReadingToCurated(reading.id)

            // She adds a post by hand to her new hand-shaped book…
            let byHand = try ops.createPost(title: "by hand")
            let handRow = try ops.addPostToReading(byHand.id, to: reading.id)

            // …then undoes the conversion. Her row is hers.
            try stack.undo(with: ops)
            let surviving = try liveMemberships(db, reading.id)
            #expect(surviving.map(\.id) == [handRow.id])
            #expect(result.membershipIDs.allSatisfy { !surviving.map(\.id).contains($0) })

            // And a SECOND conversion doesn't trip uq_reading_post_live on
            // that surviving row — the pair is skipped, not duplicated.
            let again = try ops.convertSmartReadingToCurated(reading.id)
            #expect(!again.membershipIDs.contains(handRow.id))
            let rows = try liveMemberships(db, reading.id)
            #expect(rows.filter { $0.postId == byHand.id }.count == 1)
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
            let result = try ops.convertSmartReadingToCurated(
                reading.id, keepCollecting: true)

            let queued = try db.read { db in
                try Row.fetchAll(db, sql: "SELECT table_name, row_id FROM sync_outbox")
                    .map { ($0["table_name"] as String, $0["row_id"] as String) }
            }
            #expect(queued.contains { $0 == ("reading", reading.id) })
            #expect(queued.contains { $0 == ("reading", result.collectingReading!.id) })
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
