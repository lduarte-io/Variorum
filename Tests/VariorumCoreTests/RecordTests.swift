import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Record types (Phase 1, Step 5)")
struct RecordTests {
    /// Whole-second fixtures round-trip exactly through the millisecond format.
    let t0 = DateFormatter.variorumISO8601.date(from: "2026-07-04T09:30:00.000Z")!
    let t1 = DateFormatter.variorumISO8601.date(from: "2026-07-04T10:00:00.000Z")!

    // MARK: Round-trips, one per table

    @Test func everyRecordRoundTrips() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            let container = Container(
                id: "c1", kind: .post, title: "First post", profile: .journal,
                entryDate: "2026-07-04", floatingNotes: "margin note",
                segmentationDefault: .oneBlock, lastTouchedAt: t1,
                churnAccumulator: 12.5, baselineLength: 240,
                createdAt: t0, updatedAt: t1)
            try container.insert(db)
            #expect(try Container.fetchOne(db, key: "c1") == container)

            var block = Block(id: "b1", lastContainerId: "c1", createdAt: t0, updatedAt: t0)
            try block.insert(db)
            #expect(try Block.fetchOne(db, key: "b1") == block)

            let variant = Variant(
                id: "v1", blockId: "b1", workingText: "Working prose.",
                label: "first take", fanPosition: "V", createdAt: t0, updatedAt: t1)
            try variant.insert(db)
            #expect(try Variant.fetchOne(db, key: "v1") == variant)

            // Close the circular FK: block → its default variant.
            block.defaultVariantId = "v1"
            try block.update(db)
            #expect(try Block.fetchOne(db, key: "b1") == block)

            let commit = CommitPoint(
                id: "cp1", variantId: "v1", text: "Committed prose.",
                kind: .manual, message: "keep this", createdAt: t1)
            try commit.insert(db)
            #expect(try CommitPoint.fetchOne(db, key: "cp1") == commit)

            let block2 = Block(id: "b2", createdAt: t0, updatedAt: t0)
            try block2.insert(db)
            let edge = Edge(
                id: "e1", sourceBlockId: "b2", targetBlockId: "b1",
                type: .derivedFrom, originOp: "extract", createdAt: t1)
            try edge.insert(db)
            #expect(try Edge.fetchOne(db, key: "e1") == edge)

            let cb = ContainerBlock(
                id: "cb1", containerId: "c1", blockId: "b1", position: "V",
                chosenVariantId: "v1", createdAt: t0, updatedAt: t0)
            try cb.insert(db)
            #expect(try ContainerBlock.fetchOne(db, key: "cb1") == cb)

            let tag = Tag(id: "t1", name: "goals", path: "life/goals", createdAt: t0, updatedAt: t0)
            try tag.insert(db)
            #expect(try Tag.fetchOne(db, key: "t1") == tag)

            let reading = Reading(
                id: "r1", name: "The Journal, Year One", kind: .curated,
                profile: "journal", sortField: .entryDate, sortDir: .desc,
                groupingTagId: "t1", maxPosts: 365, createdAt: t0, updatedAt: t0)
            try reading.insert(db)
            #expect(try Reading.fetchOne(db, key: "r1") == reading)

            let rp = ReadingPost(id: "rp1", readingId: "r1", postId: "c1", position: "V", createdAt: t0)
            try rp.insert(db)
            #expect(try ReadingPost.fetchOne(db, key: "rp1") == rp)

            let pt = PostTag(id: "pt1", tagId: "t1", postId: "c1", createdAt: t0)
            try pt.insert(db)
            #expect(try PostTag.fetchOne(db, key: "pt1") == pt)

            let bt = BlockTag(id: "bt1", tagId: "t1", blockId: "b1", createdAt: t0)
            try bt.insert(db)
            #expect(try BlockTag.fetchOne(db, key: "bt1") == bt)

            let reference = Reference(
                id: "ref1", containerId: "c1", kind: .file, name: "source.pdf",
                fileBookmark: Data([0x01, 0x02, 0x03]), viewState: #"{"page":4}"#,
                position: "V", createdAt: t0, updatedAt: t0)
            try reference.insert(db)
            #expect(try Reference.fetchOne(db, key: "ref1") == reference)

            let setting = Setting(key: "default_segmentation", value: "sentence")
            try setting.update(db)  // seeded row: exercise update + fetch
            #expect(try Setting.fetchOne(db, key: "default_segmentation") == setting)
        }
    }

    // MARK: Enum and timestamp storage formats

    @Test func enumColumnsStoreRawValuesAndDecodeBack() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Container(
                id: "c1", kind: .post, profile: .bookChapter,
                segmentationDefault: .oneBlock, createdAt: t0, updatedAt: t0
            ).insert(db)

            // Swift → SQL: raw snake_case strings land in the columns.
            let row = try Row.fetchOne(
                db, sql: "SELECT kind, profile, segmentation_default FROM container WHERE id = 'c1'")!
            #expect(row["kind"] == "post")
            #expect(row["profile"] == "book_chapter")
            #expect(row["segmentation_default"] == "one_block")

            // SQL → Swift: a row written by hand decodes to the enum cases.
            try db.execute(sql: """
                INSERT INTO container (id, kind, profile, segmentation_default, created_at, updated_at)
                VALUES ('c2', 'pool', 'pool', 'paragraph', '2026-07-04T09:30:00.000Z', '2026-07-04T09:30:00.000Z')
                """)
            let fetched = try Container.fetchOne(db, key: "c2")
            #expect(fetched?.kind == .pool)
            #expect(fetched?.profile == .pool)
            #expect(fetched?.segmentationDefault == .paragraph)
        }
    }

    @Test func timestampsStoreInCanonicalISO8601() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Block(id: "b1", createdAt: t0, updatedAt: t1).insert(db)
            let row = try Row.fetchOne(db, sql: "SELECT created_at, updated_at FROM block WHERE id = 'b1'")!
            // Byte-identical to strftime('%Y-%m-%dT%H:%M:%fZ') output, so
            // Swift-written and trigger-written timestamps sort together.
            #expect(row["created_at"] == "2026-07-04T09:30:00.000Z")
            #expect(row["updated_at"] == "2026-07-04T10:00:00.000Z")
        }
    }

    /// The ID convention (SyncSpec §9): random UUIDv4 minted via
    /// `@Dependency(\.uuid)` — deterministic under test override. Records are
    /// pure values; the operations layer (Phase 2) is what mints for real.
    @Test func idsMintDeterministicallyUnderTheUUIDDependency() throws {
        try withDependencies {
            $0.uuid = .incrementing
        } operation: {
            @Dependency(\.uuid) var uuid
            let db = try AppDatabase.inMemory()
            let block = Block(id: uuid().uuidString, createdAt: t0, updatedAt: t0)
            #expect(block.id == "00000000-0000-0000-0000-000000000000")
            try db.write { db in try block.insert(db) }
            #expect(try db.read { db in try Block.fetchOne(db, key: block.id) } == block)
        }
    }

    // MARK: Associations

    @Test func associationsFetchExpectedRows() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            // Two blocks in one post; b1 fans out to two variants; v1 has two
            // commits; the post lives in a reading; a tag with two children.
            try Container(id: "c1", kind: .post, createdAt: t0, updatedAt: t0).insert(db)
            try Block(id: "b1", createdAt: t0, updatedAt: t0).insert(db)
            try Block(id: "b2", createdAt: t0, updatedAt: t0).insert(db)
            try Variant(id: "v1", blockId: "b1", fanPosition: "V", createdAt: t0, updatedAt: t0).insert(db)
            try Variant(id: "v2", blockId: "b1", fanPosition: "W", createdAt: t0, updatedAt: t0).insert(db)
            try Variant(id: "v3", blockId: "b2", fanPosition: "V", createdAt: t0, updatedAt: t0).insert(db)
            try CommitPoint(id: "cp1", variantId: "v1", text: "one", createdAt: t0).insert(db)
            try CommitPoint(id: "cp2", variantId: "v1", text: "two", createdAt: t1).insert(db)
            try ContainerBlock(id: "cb1", containerId: "c1", blockId: "b1", position: "A", createdAt: t0, updatedAt: t0).insert(db)
            try ContainerBlock(id: "cb2", containerId: "c1", blockId: "b2", position: "B", createdAt: t0, updatedAt: t0).insert(db)
            try Reading(id: "r1", name: "r", kind: .curated, createdAt: t0, updatedAt: t0).insert(db)
            try ReadingPost(id: "rp1", readingId: "r1", postId: "c1", position: "V", createdAt: t0).insert(db)
            try Tag(id: "t1", name: "life", path: "life", createdAt: t0, updatedAt: t0).insert(db)
            try Tag(id: "t2", parentId: "t1", name: "goals", path: "life/goals", createdAt: t0, updatedAt: t0).insert(db)
            try Tag(id: "t3", parentId: "t1", name: "books", path: "life/books", createdAt: t0, updatedAt: t0).insert(db)

            let b1 = try Block.fetchOne(db, key: "b1")!
            let fan = try b1.request(for: Block.variants).order(Column("fan_position")).fetchAll(db)
            #expect(fan.map(\.id) == ["v1", "v2"])

            let v1 = try Variant.fetchOne(db, key: "v1")!
            let commits = try v1.request(for: Variant.commitPoints).order(Column("created_at"), Column("id")).fetchAll(db)
            #expect(commits.map(\.id) == ["cp1", "cp2"])

            let c1 = try Container.fetchOne(db, key: "c1")!
            let slots = try c1.request(for: Container.containerBlocks).order(Column("position"), Column("id")).fetchAll(db)
            #expect(slots.map(\.blockId) == ["b1", "b2"])

            let r1 = try Reading.fetchOne(db, key: "r1")!
            let members = try r1.request(for: Reading.readingPosts).fetchAll(db)
            #expect(members.map(\.postId) == ["c1"])

            let t1Tag = try Tag.fetchOne(db, key: "t1")!
            let children = try t1Tag.request(for: Tag.children).order(Column("path")).fetchAll(db)
            #expect(children.map(\.name) == ["books", "goals"])
        }
    }
}
