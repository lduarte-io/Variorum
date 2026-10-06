// BRANCH-ONLY tests (`tools/strings-workbook`; never merges). Scratch stores only.

import Foundation
import GRDB
import Testing
@testable import StringsWorkbook
import VariorumCore

@Suite("StringsWorkbook — the ops-driven mint", .serialized)
struct WorkbookMintTests {
    /// A two-chapter synthetic plan whose every row the test can name.
    static let smallPlan = WorkbookPlan(chapters: [
        .init(name: "Tier A", notes: [
            .init(title: "Surface one", blocks: [
                .init(current: "Hello", locator: "a/B.swift:1\nsurface: Surface one", sourceLine: 1),
                .init(current: "two\nlines", locator: "⚠RULED — x\na/C.swift:2\nsurface: Surface one", sourceLine: 2),
            ]),
            .init(title: "Surface two", blocks: [
                .init(current: #"Tagged \(n) notes"#, locator: "a/D.swift:3\nsurface: Surface two\n(templated)", sourceLine: 3),
            ]),
        ]),
        .init(name: "Tier B (empty)", notes: []),
        .init(name: "Tier C", notes: [
            .init(title: "Surface three", blocks: [
                .init(current: "Last", locator: "a/E.swift:4\nsurface: Surface three", sourceLine: 4),
            ]),
        ]),
    ])

    @Test func theSmallPlanMintsExactlyItsRows() throws {
        let database = try AppDatabase.inMemory()
        let report = try WorkbookMint.mint(Self.smallPlan, into: database)
        #expect(report.chapters == 3)
        #expect(report.notes == 3)
        #expect(report.blocks == 4)
        #expect(report.takes == 12)
        try WorkbookMint.verify(Self.smallPlan, readingID: report.readingID, in: database)

        try database.read { db in
            // ONE book, plain: kind book, no rule, Home wing, unshelved, not starred.
            let books = try Row.fetchAll(db, sql: "SELECT * FROM reading WHERE deleted_at IS NULL")
            #expect(books.count == 1)
            let book = try #require(books.first)
            #expect(book["name"] as String == "App Strings")
            #expect(book["kind"] as String == "book")
            #expect(book["profile"] as String? == "book")
            #expect(book["query_spec"] as String? == nil)
            #expect(book["wing_id"] as String == "")
            #expect(book["shelf_id"] as String? == nil)
            #expect(book["starred"] as Int == 0)
            #expect(book["auto_tag_ids"] as String? == nil)

            // Chapters in order, the empty one included.
            let sections = try String.fetchAll(db, sql: """
                SELECT name FROM reading_section WHERE deleted_at IS NULL ORDER BY position, id
                """)
            #expect(sections == ["Tier A", "Tier B (empty)", "Tier C"])

            // Posts: Home wing, titled, members of the book, no tags applied.
            let posts = try Row.fetchAll(db, sql: """
                SELECT title, wing_id FROM container WHERE kind = 'post' AND deleted_at IS NULL ORDER BY created_at, id
                """)
            #expect(posts.map { $0["title"] as String? } == ["Surface one", "Surface two", "Surface three"])
            #expect(posts.allSatisfy { ($0["wing_id"] as String) == "" })
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM post_tag") == 0)

            // Every take: three per block, labels in fan order, take 2 empty,
            // the internal newline kept as content (I4), interpolation verbatim.
            let takes = try Row.fetchAll(db, sql: """
                SELECT v.label, v.working_text FROM variant v
                JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                JOIN reading_post rp ON rp.post_id = cb.container_id AND rp.deleted_at IS NULL
                JOIN reading_section rs ON rs.id = rp.section_id
                WHERE v.deleted_at IS NULL
                ORDER BY rs.position, rp.position, cb.position, v.fan_position
                """)
            #expect(takes.map { $0["label"] as String? } == Array(repeating: ["current", "rewrite", "where"], count: 4).flatMap { $0 })
            #expect(takes.map { $0["working_text"] as String } == [
                "Hello", "", "a/B.swift:1\nsurface: Surface one",
                "two\nlines", "", "⚠RULED — x\na/C.swift:2\nsurface: Surface one",
                #"Tagged \(n) notes"#, "", "a/D.swift:3\nsurface: Surface two\n(templated)",
                "Last", "", "a/E.swift:4\nsurface: Surface three",
            ])
            // Every minted row reached the outbox (ordinary op writes).
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox WHERE table_name = 'variant'") == 12)
            // Signed out: unowned, adopted at her next signed-in launch.
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block WHERE owner_id IS NOT NULL") == 0)
        }
    }

    @Test func theRealPlanMints3630BlocksAndReadsBackExactly() throws {
        let database = try AppDatabase.inMemory()
        var ticks = 0
        let report = try WorkbookMint.mint(RealDocs.plan, into: database) { done, total in
            ticks += 1
            #expect(total == 3630)
            #expect(done == ticks)
        }
        #expect(report.blocks == 3630)
        #expect(report.takes == 10890)
        #expect(report.notes == 37)
        #expect(report.chapters == 7)
        try WorkbookMint.verify(RealDocs.plan, readingID: report.readingID, in: database)
        func count(_ sql: String) throws -> Int? { try database.read { try Int.fetchOne($0, sql: sql) } }
        #expect(try count("SELECT COUNT(*) FROM block WHERE deleted_at IS NULL") == 3630)
        #expect(try count("SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") == 10890)
        #expect(try count("SELECT COUNT(*) FROM variant WHERE label = 'rewrite' AND working_text != ''") == 0)
        // ⚠RULED leads take 3 wherever the inventory carries it.
        #expect(try count("SELECT COUNT(*) FROM variant WHERE label = 'where' AND working_text LIKE '⚠RULED%'") == 349)
    }

    @Test func theMintIsOneShotEvenAgainstAnArchivedOrDifferentlyCasedTwin() throws {
        let database = try AppDatabase.inMemory()
        let report = try WorkbookMint.mint(Self.smallPlan, into: database)
        #expect(throws: WorkbookMint.MintError.alreadyMinted(existingName: "App Strings")) {
            try WorkbookMint.mint(Self.smallPlan, into: database)
        }
        // Archive it and rename to another casing: STILL refuses (stricter
        // than the E13 guard, which skips archived names).
        try WorkbookMint.withOperations(on: database) { ops in
            try ops.renameReading(report.readingID, name: "  app strings ")
            try ops.archiveReading(report.readingID)
        }
        #expect(throws: WorkbookMint.MintError.self) {
            try WorkbookMint.mint(Self.smallPlan, into: database)
        }
        // Nothing was written by the refused attempts.
        #expect(try database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM reading") } == 1)
    }

    @Test func theVerifierCatchesADriftedTake() throws {
        let database = try AppDatabase.inMemory()
        let report = try WorkbookMint.mint(Self.smallPlan, into: database)
        let rewriteID = try #require(try database.read {
            try String.fetchOne($0, sql: "SELECT id FROM variant WHERE label = 'rewrite' LIMIT 1")
        })
        try WorkbookMint.withOperations(on: database) { ops in
            try ops.autosave(rewriteID, text: "her words", charDelta: 9)
        }
        #expect(throws: WorkbookMint.VerificationError.self) {
            try WorkbookMint.verify(Self.smallPlan, readingID: report.readingID, in: database)
        }
    }
}
