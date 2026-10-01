import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13b Stage 3, batch 3B — N13: real chapters reach `assembleReading`
/// and `exportReading`. The sectioning truth is the BOOK VIEW's shipped
/// presentation (`BookStructureModel.grouped` + `chaptersActive`,
/// `App/.../BookView/BookStructureModel.swift`): chapters in `(position,
/// id)` order, entries in the reading's own order within their chapter,
/// unfiled entries trailing, EMPTY chapters visible, dangling pointers
/// unsectioned (AppSpec §7's fallback class), chapters WINNING over tag
/// grouping, smart books untouched (they refuse sections).
@Suite("Chapters reach assembly & export (Phase 13b 3B, N13)")
struct ChapterAssemblyExportTests {
    /// A curated book with `count` posts ("P1"… in membership order), each
    /// carrying one block of prose so exports have bodies.
    private func makeBook(
        _ ops: Operations, posts count: Int = 3
    ) throws -> (reading: Reading, postIDs: [String]) {
        let reading = try ops.createReading(name: "Field Notes", kind: .book)
        var ids: [String] = []
        for i in 1...count {
            let post = try ops.createPost(title: "P\(i)")
            try ops.newBlock(in: post.id, text: "Body \(i).", at: .end)
            try ops.addPostToReading(post.id, to: reading.id)
            ids.append(post.id)
        }
        return (reading, ids)
    }

    @Test func chapterAssemblyMirrorsTheBookViewsGroupedOrder() throws {
        try withOperations { ops, db in
            let (reading, posts) = try makeBook(ops, posts: 4)
            let chA = try ops.createSection(in: reading.id, name: "I / leaving")
            let chB = try ops.createSection(in: reading.id, name: "II / arrival")
            // Assignment order deliberately scrambles membership order:
            // P1 → II, P2 and P4 → I, P3 unfiled.
            try ops.assignPostToSection(posts[0], in: reading.id, section: chB.id)
            try ops.assignPostToSection(posts[1], in: reading.id, section: chA.id)
            try ops.assignPostToSection(posts[3], in: reading.id, section: chA.id)

            var entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            // Chapters by (position, id); within a chapter membership
            // order holds; the unfiled entry TRAILS (the book view's
            // stragglers-trail call).
            #expect(entries.map(\.postID) == [posts[1], posts[3], posts[0], posts[2]])
            #expect(entries.map(\.sectionPath)
                == ["I / leaving", "I / leaving", "II / arrival", nil])
            #expect(entries.map(\.sectionID) == [chA.id, chA.id, chB.id, nil])

            // Reordering the chapters reorders the assembly (the movable-
            // chapters gesture reaches export order too).
            try ops.reorderSection(chB.id, to: .before(chA.id))
            entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [posts[0], posts[1], posts[3], posts[2]])

            // A cap counts the GROUPED order — the same first-N the book
            // view and shelf render (the standing cap-follows-assembly
            // rule, now over chapter order).
            let capped = try db.read {
                try Queries.assembleReading($0, readingID: reading.id, limit: 2)
            }
            #expect(capped.map(\.postID) == [posts[0], posts[1]])
        }
    }

    @Test func danglingSectionPointerReadsUnsectionedAndRestoreReattaches() throws {
        try withOperations { ops, db in
            let (reading, posts) = try makeBook(ops, posts: 2)
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let keeper = try ops.createSection(in: reading.id, name: "II")
            try ops.assignPostToSection(posts[1], in: reading.id, section: chapter.id)
            try ops.assignPostToSection(posts[0], in: reading.id, section: keeper.id)

            // Tombstone the chapter: the membership keeps its pointer, but
            // it READS unsectioned — the entry trails as unfiled.
            try ops.deleteSection(chapter.id)
            var entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.sectionPath) == ["II", nil])
            #expect(entries.map(\.postID) == [posts[0], posts[1]])

            // restoreSection: the surviving assignment reattaches for free
            // (the dangle rule never rewrote it).
            try ops.restoreSection(chapter.id)
            entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.sectionPath) == ["I", "II"])
            #expect(entries.map(\.postID) == [posts[1], posts[0]])
        }
    }

    @Test func chaptersWinOverTagGroupingAndAChapterlessBookKeepsIt() throws {
        try withOperations { ops, db in
            let root = try ops.createTag(name: "book")
            let part = try ops.createTag(parent: root.id, name: "part-one")
            let post = try ops.createPost(title: "A")
            try ops.newBlock(in: post.id, text: "A body.", at: .end)
            try ops.applyTag(part.id, toPost: post.id)
            let reading = try ops.createReading(
                name: "Grouped", kind: .book, groupingTagId: root.id)
            try ops.addPostToReading(post.id, to: reading.id)

            // Chapterless: the Phase 4 tag grouping governs, unchanged.
            let tagged = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(tagged.map(\.sectionPath) == ["book/part-one"])
            #expect(tagged.map(\.sectionID) == [nil])

            // A live chapter appears: chapters WIN (the book view's
            // `chaptersActive` precedence) — even for a post left unfiled.
            let chapter = try ops.createSection(in: reading.id, name: "I")
            let chaptered = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(chaptered.map(\.sectionPath) == [nil],
                    "an unfiled post under a chaptered book reads unfiled, never tag-grouped")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            let filed = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(filed.map(\.sectionPath) == ["I"])

            // The last chapter dies: the tag grouping is back byte-for-byte.
            try ops.assignPostToSection(post.id, in: reading.id, section: nil)
            try ops.deleteSection(chapter.id)
            let back = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(back == tagged)
        }
    }

    @Test func smartBookAssemblyIsByteIdenticalWithSectionRowsPresent() throws {
        // Smart readings refuse sections through Operations; a stray row
        // can only arrive via a sync race. The smart branch must ignore it
        // ENTIRELY — this is the brief's smart-book byte-parity pin.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "S", profile: .blog)
            try ops.newBlock(in: post.id, text: "S body.", at: .end)
            let spec = try Queries.SmartQuerySpec(profile: "blog").encodedJSON()
            let reading = try ops.createReading(
                name: "Smart", kind: .gathering, querySpec: spec)

            let before = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(before.map(\.postID) == [post.id])

            // The sync-race shape: a section row on a smart reading,
            // inserted below the operations layer.
            try db.write { raw in
                try raw.execute(
                    sql: """
                        INSERT INTO reading_section
                          (id, reading_id, name, position, created_at, updated_at, sync_version)
                        VALUES ('stray-section', ?, 'stray', 'a5', '2026-07-20T00:00:00.000Z',
                                '2026-07-20T00:00:00.000Z', 0)
                        """,
                    arguments: [reading.id])
            }
            let after = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(after == before, "smart assembly never reads reading_section")
        }
    }

    @Test func chapteredExportEmitsHeadingsEmptyChaptersAndTheUnfiledTrail() throws {
        try withOperations { ops, db in
            let (reading, posts) = try makeBook(ops, posts: 2)
            let chA = try ops.createSection(in: reading.id, name: "I / leaving")
            _ = try ops.createSection(in: reading.id, name: "II / the long middle")
            try ops.assignPostToSection(posts[0], in: reading.id, section: chA.id)
            // posts[1] stays unfiled.

            let exported = try db.read { try Queries.exportReading($0, readingID: reading.id) }
            #expect(exported == """
                # Field Notes

                ## I / leaving

                ### P1

                Body 1.

                ## II / the long middle

                ## unfiled

                ### P2

                Body 2.
                """)
        }
    }

    @Test func sameNamedChaptersEachExportTheirOwnHeading() throws {
        // Chapter names carry no uniqueness (AppSpec §7 — "duplicate names
        // legal"); the book view renders one header per section ROW, and
        // the export mirrors it by grouping on `sectionID`, never the name.
        try withOperations { ops, db in
            let (reading, posts) = try makeBook(ops, posts: 2)
            let first = try ops.createSection(in: reading.id, name: "Drafts")
            let second = try ops.createSection(in: reading.id, name: "Drafts")
            try ops.assignPostToSection(posts[0], in: reading.id, section: first.id)
            try ops.assignPostToSection(posts[1], in: reading.id, section: second.id)

            let exported = try db.read { try Queries.exportReading($0, readingID: reading.id) }
            #expect(exported == """
                # Field Notes

                ## Drafts

                ### P1

                Body 1.

                ## Drafts

                ### P2

                Body 2.
                """)
        }
    }
}
