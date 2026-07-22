import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13b, Stage 4 Batch 4F — `restoreReading` (ledger N37; the author's
/// S4-28.2 ruling, DELIBERATELY reversing the standing pre-13 "readings
/// have no restore door" boundary): the `restoreContainer` pattern —
/// tombstone flip + exact-stamp revival of the reading's own cascade
/// victims (chapters + memberships), with diverged stories left dead.
@Suite("Restore reading (13b Stage 4, 4F — N37)")
struct RestoreReadingTests {
    private func makeBook(
        _ ops: Operations, posts: Int = 3
    ) throws -> (reading: Reading, postIDs: [String]) {
        let reading = try ops.createReading(name: "orbit", kind: .curated)
        var postIDs: [String] = []
        for index in 0..<posts {
            let post = try ops.createPost(title: "post \(index)", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Prose of post \(index).", at: .end)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return (reading, postIDs)
    }

    @Test func restoreRevivesTheBookWholeChaptersAndAssignmentsIncluded() throws {
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops)
            let one = try ops.createSection(in: reading.id, name: "I / leaving")
            let two = try ops.createSection(in: reading.id, name: "II / arrival")
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: one.id)
            try ops.assignPostToSection(postIDs[1], in: reading.id, section: two.id)

            try ops.deleteReading(reading.id)
            let stamp = try db.deletedAt("reading", reading.id)
            #expect(stamp != nil)
            #expect(try db.deletedAt("reading_section", one.id) == stamp)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL
                """, [reading.id]) == 0)
            let listedDeleted = try db.read { try Queries.deletedReadings($0) }
            #expect(listedDeleted.map(\.id) == [reading.id],
                    "the deleted book is visible — the recovery surface's feed")

            try ops.restoreReading(reading.id)

            #expect(try db.deletedAt("reading", reading.id) == nil)
            // Chapters back, in their original order.
            let sections = try db.read { try Queries.readingSections($0, readingID: reading.id) }
            #expect(sections.map(\.id) == [one.id, two.id])
            // Memberships back — the book assembles exactly as before.
            let assembled = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(assembled.map(\.postID) == postIDs)
            // Assignments reattach for FREE (the dangle rule never rewrote
            // the pointers; the exact-stamp revival brought both sides back).
            let assignments = try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
            #expect(assignments == [postIDs[0]: one.id, postIDs[1]: two.id])
        }
    }

    @Test func divergedStoriesStayDead() throws {
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let independent = try ops.createSection(in: reading.id, name: "II / removed early")

            // Diverged BEFORE the delete: a membership removed by hand and
            // a chapter deleted by hand carry their own stamps.
            try ops.removePostFromReading(postIDs[2], from: reading.id)
            try ops.deleteSection(independent.id)
            // A post deleted BEFORE the reading: the container cascade
            // stamps its membership with the POST's stamp.
            try ops.deleteContainer(postIDs[1])

            try ops.deleteReading(reading.id)
            try ops.restoreReading(reading.id)

            // The surviving post's membership revived; the removed one and
            // the dead post's one stayed dead.
            let assembled = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(assembled.map(\.postID) == [postIDs[0]],
                    "only the undiverged membership revives")
            // The hand-deleted chapter stays dead; the cascade victim lives.
            let sections = try db.read { try Queries.readingSections($0, readingID: reading.id) }
            #expect(sections.map(\.id) == [chapter.id])
            // The dead post itself is untouched (restoreReading never
            // revives posts — membership is not ownership).
            #expect(try db.deletedAt("container", postIDs[1]) != nil)
        }
    }

    @Test func aPostThatDiedAfterTheReadingStaysOutOnRestore() throws {
        // The live-post guard's exact case: the reading dies first (its
        // cascade stamps the membership), THEN the post dies — the
        // membership matches the reading's stamp, but reviving it would
        // point a live row at a dead post.
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops, posts: 2)
            try ops.deleteReading(reading.id)
            try ops.deleteContainer(postIDs[0])

            try ops.restoreReading(reading.id)
            let assembled = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(assembled.map(\.postID) == [postIDs[1]],
                    "the dead post's membership stays dead despite the matching stamp")
            // DOCUMENTED CORNER (13b 4F — a finding, not a bug): the
            // membership died with the READING's stamp (it was already
            // dead when the post's own cascade fired, so the container
            // cascade never restamped it). `restoreContainer` sweeps by
            // the POST's stamp, so restoring the post brings the post back
            // but NOT this membership — the row's story diverged across
            // two deaths, and the standing doctrine leaves diverged rows
            // alone. The road back is the ordinary add-to-book door.
            try ops.restoreContainer(postIDs[0])
            #expect(try db.deletedAt("container", postIDs[0]) == nil)
            let after = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(after.map(\.postID) == [postIDs[1]],
                    "the twice-orphaned membership stays dead through BOTH restores")
            _ = try ops.addPostToReading(postIDs[0], to: reading.id)
            let rejoined = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(Set(rejoined.map(\.postID)) == Set(postIDs),
                    "the ordinary membership door is the honest road back")
        }
    }

    @Test func theRevivedReadingOpensTheRestoreSectionDoor() throws {
        // The boundary-reversal interaction (the brief's named check):
        // restoreSection refuses while the reading is dead (readingNotFound
        // through liveReading); after restoreReading, an INDEPENDENTLY
        // deleted chapter — which the exact-stamp sweep deliberately left
        // dead — now has a working door.
        try withOperations { ops, db in
            let (reading, _) = try makeBook(ops, posts: 1)
            let chapter = try ops.createSection(in: reading.id, name: "I / early cut")
            try ops.deleteSection(chapter.id)
            try ops.deleteReading(reading.id)

            #expect(throws: OperationError.readingNotFound(id: reading.id)) {
                try ops.restoreSection(chapter.id)
            }

            try ops.restoreReading(reading.id)
            #expect(try db.deletedAt("reading_section", chapter.id) != nil,
                    "the independently deleted chapter stayed dead through the restore")
            try ops.restoreSection(chapter.id)
            #expect(try db.deletedAt("reading_section", chapter.id) == nil,
                    "the two-step road: revive the reading first, then the chapter")
        }
    }

    @Test func refusalsAreTypedAndExact() throws {
        try withOperations { ops, _ in
            let (reading, _) = try makeBook(ops, posts: 1)
            #expect(throws: OperationError.readingNotDeleted(id: reading.id)) {
                try ops.restoreReading(reading.id)
            }
            #expect(throws: OperationError.readingNotFound(id: "nope")) {
                try ops.restoreReading("nope")
            }
        }
    }

    @Test func aSmartBookRestoresByTheFlipAlone() throws {
        // Recorded reading: the op does not refuse smart readings — the
        // flip restores the book and its query spec; membership is derived,
        // so the exact-stamp sweeps match nothing.
        try withOperations { ops, db in
            let spec = try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON()
            let smart = try ops.createReading(name: "star-notes", kind: .smart, querySpec: spec)
            try ops.deleteReading(smart.id)
            try ops.restoreReading(smart.id)
            let restored = try db.read { try Queries.reading($0, id: smart.id) }
            #expect(restored?.deletedAt == nil)
            #expect(restored?.querySpec == spec, "the spec IS the smart book's identity")
        }
    }

    @Test func aFinishedBookRestoresFinished() throws {
        // The restore restores what was there — locked included (the
        // restoreContainer parallel: no lock guard on the recovery door).
        try withOperations { ops, db in
            let (reading, _) = try makeBook(ops, posts: 1)
            try ops.lockReading(reading.id)
            try ops.deleteReading(reading.id)
            try ops.restoreReading(reading.id)
            let restored = try db.read { try Queries.reading($0, id: reading.id) }
            #expect(restored?.locked == true)
        }
    }

    @Test func restoreWritesReachTheOutbox() throws {
        // Ordinary local writes outside apply mode — the triggers capture
        // every revived row (nothing here needs the explicit-enqueue rule;
        // that rule is for repairs INSIDE apply mode).
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops, posts: 1)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let membershipID = try db.fetchString(
                "SELECT id FROM reading_post WHERE post_id = ?", [postIDs[0]])!
            try ops.deleteReading(reading.id)
            try db.clearOutbox()

            try ops.restoreReading(reading.id)
            #expect(try db.outboxContains("reading", reading.id))
            #expect(try db.outboxContains("reading_section", chapter.id))
            #expect(try db.outboxContains("reading_post", membershipID))
        }
    }

    @Test func deletedReadingsListsNewestFirstAndBounded() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "alpha", kind: .curated)
            let second = try ops.createReading(name: "beta", kind: .curated)
            let third = try ops.createReading(name: "gamma", kind: .smart)
            try ops.deleteReading(first.id)
            try ops.deleteReading(second.id)
            try ops.deleteReading(third.id)

            let all = try db.read { try Queries.deletedReadings($0) }
            #expect(all.map(\.id) == [third.id, second.id, first.id],
                    "newest deletion first — smart books list too")
            let bounded = try db.read { try Queries.deletedReadings($0, limit: 2) }
            #expect(bounded.map(\.id) == [third.id, second.id])
        }
    }
}
