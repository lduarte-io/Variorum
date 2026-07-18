import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A1 — migration v1_10 `reading_section` +
/// `reading_post.section_id`: real chapters (rulings R28/R50; the sitting-1
/// books reversal). Ordered, reorderable, non-nesting; membership points at
/// its chapter; dangling pointers read as unsectioned.
@Suite("Reading sections / chapters (Phase 13, A1 — v1_10)")
struct ReadingSectionTests {
    private func makeBook(
        _ ops: Operations, posts: Int = 3
    ) throws -> (reading: Reading, postIDs: [String]) {
        let reading = try ops.createReading(name: "orbit", kind: .curated)
        var postIDs: [String] = []
        for index in 0..<posts {
            let post = try ops.createPost(title: "post \(index)", profile: .generic)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return (reading, postIDs)
    }

    // MARK: - Schema shape

    @Test func tableAndPointerShapeMatchTheEventsLetter() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(reading_section)")
                .map { $0["name"] as String }
            #expect(Set(columns) == [
                "id", "reading_id", "name", "position",
                "created_at", "updated_at", "deleted_at", "sync_version",
            ])
            let membershipColumns = try Row.fetchAll(db, sql: "PRAGMA table_info(reading_post)")
                .map { $0["name"] as String }
            #expect(membershipColumns.contains("section_id"))
            // No uniqueness — duplicate chapter names are legal.
            let uniques = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'index' AND tbl_name = 'reading_section'
                  AND sql LIKE 'CREATE UNIQUE INDEX%'
                """)
            #expect(uniques.isEmpty)
        }
    }

    // MARK: - CRUD + order

    @Test func createReorderRenameAndOrderedListing() throws {
        try withOperations { ops, db in
            let (reading, _) = try makeBook(ops)
            let one = try ops.createSection(in: reading.id, name: "I / leaving")
            let two = try ops.createSection(in: reading.id, name: "II / the long middle")
            let three = try ops.createSection(in: reading.id, name: "III / arrival")

            var listed = try db.read { try Queries.readingSections($0, readingID: reading.id) }
            #expect(listed.map(\.id) == [one.id, two.id, three.id])

            // The movable-chapters gesture: III moves before II.
            try ops.reorderSection(three.id, to: .before(two.id))
            listed = try db.read { try Queries.readingSections($0, readingID: reading.id) }
            #expect(listed.map(\.id) == [one.id, three.id, two.id])

            try ops.renameSection(one.id, name: "I / departures")
            listed = try db.read { try Queries.readingSections($0, readingID: reading.id) }
            #expect(listed.first?.name == "I / departures")

            #expect(throws: OperationError.invalidSectionName(name: " ")) {
                try ops.renameSection(one.id, name: " ")
            }
        }
    }

    @Test func assignmentSetsMovesAndClearsThePointer() throws {
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let other = try ops.createSection(in: reading.id, name: "II")

            try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
            try ops.assignPostToSection(postIDs[1], in: reading.id, section: other.id)
            var assignments = try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
            #expect(assignments == [postIDs[0]: chapter.id, postIDs[1]: other.id])

            // Move between chapters; clear back to unsectioned.
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: other.id)
            try ops.assignPostToSection(postIDs[1], in: reading.id, section: nil)
            assignments = try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
            #expect(assignments == [postIDs[0]: other.id])
        }
    }

    @Test func assignmentRefusalsAreTypedAndExact() throws {
        try withOperations { ops, _ in
            let (reading, postIDs) = try makeBook(ops)
            let (foreignReading, _) = try makeBook(ops, posts: 1)
            let foreignChapter = try ops.createSection(in: foreignReading.id, name: "not mine")
            let chapter = try ops.createSection(in: reading.id, name: "I")
            try ops.deleteSection(chapter.id)

            // A chapter of ANOTHER book refuses.
            #expect(throws: OperationError.sectionNotInReading(
                sectionID: foreignChapter.id, readingID: reading.id)) {
                try ops.assignPostToSection(postIDs[0], in: reading.id, section: foreignChapter.id)
            }
            // A DEAD chapter refuses at assign time (dangling is a read-time
            // tolerance, never a write-time goal).
            #expect(throws: OperationError.sectionNotFound(id: chapter.id)) {
                try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
            }
            // A post outside the book refuses.
            let stranger = try ops.createPost(title: "stray", profile: .generic)
            let live = try ops.createSection(in: reading.id, name: "II")
            #expect(throws: OperationError.postNotInReading(
                postID: stranger.id, readingID: reading.id)) {
                try ops.assignPostToSection(stranger.id, in: reading.id, section: live.id)
            }
        }
    }

    // MARK: - The dangling rule (the chosen-variant fallback class)

    @Test func deletingAChapterLeavesPostsAndPointersButReadsUnsectioned() throws {
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)

            try ops.deleteSection(chapter.id)

            // The membership row is untouched — the stored pointer stays.
            let stored = try db.fetchString(
                "SELECT section_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postIDs[0]])
            #expect(stored == chapter.id, "deleting a chapter never rewrites memberships")
            // But the read side resolves it as unsectioned.
            let assignments = try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
            #expect(assignments[postIDs[0]] == nil, "a dangling section_id reads as unsectioned")
            // And the post itself still assembles in the book.
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID).contains(postIDs[0]))
        }
    }

    @Test func restoreSectionReattachesTheSurvivingAssignmentsForFree() throws {
        // Stage A review round 1, MINOR 2: BECAUSE deleteSection never
        // rewrites membership pointers, the restore door is one tombstone
        // flip and the chapter gets its posts back without a write.
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
            try ops.assignPostToSection(postIDs[1], in: reading.id, section: chapter.id)

            try ops.deleteSection(chapter.id)
            #expect(try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
                    .isEmpty)
            let deleted = try db.read { try Queries.deletedReadingSections($0, readingID: reading.id) }
            #expect(deleted.map(\.id) == [chapter.id],
                    "the deleted chapter stays visible — the recovery surface")

            try ops.restoreSection(chapter.id)
            let assignments = try db.read { try Queries.sectionAssignments($0, readingID: reading.id) }
            #expect(assignments == [postIDs[0]: chapter.id, postIDs[1]: chapter.id],
                    "both posts reattach — no membership row was ever rewritten")
            #expect(try db.read { try Queries.readingSections($0, readingID: reading.id) }
                    .map(\.id) == [chapter.id])

            // Refusals: restoring a live chapter; restoring under a lock.
            #expect(throws: OperationError.sectionNotDeleted(id: chapter.id)) {
                try ops.restoreSection(chapter.id)
            }
            try ops.deleteSection(chapter.id)
            try ops.lockReading(reading.id)
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.restoreSection(chapter.id)
            }
        }
    }

    // MARK: - Guards

    @Test func smartReadingsRefuseChapters() throws {
        try withOperations { ops, _ in
            let smart = try ops.createReading(
                name: "star-notes", kind: .smart,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            #expect(throws: OperationError.wrongReadingKind(id: smart.id, expected: .curated)) {
                _ = try ops.createSection(in: smart.id, name: "I")
            }
        }
    }

    @Test func aLockedReadingFreezesChapterStructureButRenameStandsFree() throws {
        try withOperations { ops, _ in
            let (reading, postIDs) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let second = try ops.createSection(in: reading.id, name: "II")
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
            try ops.lockReading(reading.id)

            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                _ = try ops.createSection(in: reading.id, name: "III")
            }
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.deleteSection(chapter.id)
            }
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.reorderSection(second.id, to: .start)
            }
            #expect(throws: OperationError.lockedReading(id: reading.id)) {
                try ops.assignPostToSection(postIDs[0], in: reading.id, section: second.id)
            }
            // The renameReading parallel: a finished book's chapter can be
            // retitled without un-finishing it.
            try ops.renameSection(chapter.id, name: "I / departures")
        }
    }

    // MARK: - Cascade + outbox

    @Test func readingTombstoneCascadesToSectionsWithTheExactStamp() throws {
        try withOperations { ops, db in
            let (reading, _) = try makeBook(ops)
            let chapter = try ops.createSection(in: reading.id, name: "I")

            try ops.deleteReading(reading.id)
            let stamp = try db.deletedAt("reading", reading.id)
            #expect(stamp != nil)
            #expect(try db.deletedAt("reading_section", chapter.id) == stamp,
                    "the cascade stamps the chapter with the reading's exact deleted_at")
        }
    }

    @Test func sectionWritesReachTheOutboxAndApplyModeSuppresses() throws {
        try withOperations { ops, db in
            let (reading, postIDs) = try makeBook(ops, posts: 1)
            try db.clearOutbox()

            let chapter = try ops.createSection(in: reading.id, name: "I")
            #expect(try db.outboxContains("reading_section", chapter.id))
            try db.clearOutbox()

            // Assignment dirties the MEMBERSHIP row (the pointer lives there).
            try ops.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
            let membershipID = try db.fetchString(
                "SELECT id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postIDs[0]])!
            #expect(try db.outboxContains("reading_post", membershipID))
            try db.clearOutbox()

            try db.applyingRemote { db in
                try db.execute(
                    sql: "UPDATE reading_section SET name = 'remote' WHERE id = ?",
                    arguments: [chapter.id])
            }
            #expect(try !db.outboxContains("reading_section", chapter.id))
        }
    }
}
