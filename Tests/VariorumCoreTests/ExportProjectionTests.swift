import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11b, Step B1 — the export projections against the ratified shapes
/// (AppSpec §14 forward-planning delta 2026-07-06; bulk export 2026-07-07;
/// the 2026-07-12 conditional join). Exports are one-way projections: the
/// suite also pins that NO export path writes a row (review focus 2).
@Suite("Export projections (Phase 11b, B1)")
struct ExportProjectionTests {
    private func setLabel(_ db: AppDatabase, _ variantID: String, _ label: String) throws {
        // No variant-label operation exists (labels are minted by sync
        // landings); the projection is what's under test, so the label lands
        // by direct row write.
        try db.write { database in
            try database.execute(
                sql: "UPDATE variant SET label = ? WHERE id = ?",
                arguments: [label, variantID])
        }
    }

    // MARK: - Plain post export (== renderedText, the one join brain)

    @Test func plainPostExportIsRenderedTextIncludingStoredSpacing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Spaced")
            // Stored spacing (the 2026-07-12 ruling): the first block keeps
            // two trailing newlines; the conditional join completes the run.
            try ops.newBlock(in: post.id, text: "A\n\n")
            try ops.newBlock(in: post.id, text: "B")
            // A blank take skips like a gap.
            try ops.newBlock(in: post.id, text: "")
            try ops.newBlock(in: post.id, text: "C")

            let exported = try db.read { try Queries.exportPost($0, postID: post.id) }
            let rendered = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(exported == "A\n\n\nB\n\nC")
            #expect(exported == rendered)
        }
    }

    // MARK: - The fan section (labeled takes quoted, unlabeled numbered)

    @Test func fannedBlockExportShapesTheAlternatesSection() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Fanned")
            let minted = try ops.newBlock(in: post.id, text: "Chosen take.")
            let labeled = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(labeled.id, text: "Punchier take.", charDelta: 0)
            try setLabel(db, labeled.id, "punchier")
            // Branched from the labeled take so fan order reads original →
            // labeled → unlabeled (a branch lands beside its source).
            let unlabeled = try ops.branchVariant(minted.block.id, from: labeled.id)
            try ops.autosave(unlabeled.id, text: "Third take.", charDelta: 0)
            // A blank alternate contributes nothing (the blank-take skip).
            try ops.newBlankVariant(minted.block.id)
            // An archived take is out of the fan and out of the export.
            let archived = try ops.branchVariant(minted.block.id, from: unlabeled.id)
            try ops.autosave(archived.id, text: "Archived take.", charDelta: 0)
            try ops.archiveVariant(archived.id)

            let exported = try db.read { try Queries.exportBlock($0, blockID: minted.block.id) }
            #expect(exported == """
                Chosen take.

                --- Alternates for this block ---

                take: "punchier"

                Punchier take.

                take: 2

                Third take.

                --- end alternates ---
                """)
        }
    }

    @Test func includeVariantsPlacesEachSectionAfterItsBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Doc")
            try ops.newBlock(in: post.id, text: "Intro.")
            let fanned = try ops.newBlock(in: post.id, text: "Middle chosen.")
            let alt = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(alt.id, text: "Middle alt.", charDelta: 0)
            try ops.newBlock(in: post.id, text: "Outro.")

            let plain = try db.read { try Queries.exportPost($0, postID: post.id) }
            #expect(plain == "Intro.\n\nMiddle chosen.\n\nOutro.")

            let withTakes = try db.read {
                try Queries.exportPost($0, postID: post.id, includeVariants: true)
            }
            #expect(withTakes == """
                Intro.

                Middle chosen.

                --- Alternates for this block ---

                take: 1

                Middle alt.

                --- end alternates ---

                Outro.
                """)
        }
    }

    @Test func aBlankChosenTakeStillExportsItsAlternates() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Muted")
            let minted = try ops.newBlock(in: post.id, text: "The take.")
            let blank = try ops.newBlankVariant(minted.block.id)
            try ops.chooseVariant(minted.block.id, variantID: blank.id)

            // Plain export: the blank chosen skips — the post reads empty.
            let plain = try db.read { try Queries.exportPost($0, postID: post.id) }
            #expect(plain.isEmpty)

            // With variants: the block's takes are still the author's work.
            let withTakes = try db.read {
                try Queries.exportPost($0, postID: post.id, includeVariants: true)
            }
            #expect(withTakes == """
                --- Alternates for this block ---

                take: 1

                The take.

                --- end alternates ---
                """)
        }
    }

    // MARK: - Single-block export (read-time rule; unplaced default)

    @Test func blockExportRendersTheChosenTakeAndAnUnplacedBlocksDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "P")
            let minted = try ops.newBlock(in: post.id, text: "Default text.")
            let other = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(other.id, text: "Chosen text.", charDelta: 0)
            try ops.chooseVariant(minted.block.id, variantID: other.id)

            let placed = try db.read { try Queries.exportBlock($0, blockID: minted.block.id) }
            #expect(placed.hasPrefix("Chosen text."))

            // Release the block to lineage (merge releases both sources) —
            // an unplaced block renders its default variant.
            let second = try ops.newBlock(in: post.id, text: "Neighbor.")
            _ = try ops.merge(minted.block.id, second.block.id)
            let unplaced = try db.read { try Queries.exportBlock($0, blockID: minted.block.id) }
            // The released block kept its fan; its rendered take falls back
            // to the block default now that no placement chooses.
            #expect(unplaced.hasPrefix("Default text."))

            // A dead block exports empty (tolerant read).
            let missing = try db.read { try Queries.exportBlock($0, blockID: "no-such-block") }
            #expect(missing.isEmpty)
        }
    }

    // MARK: - Reading export

    @Test func readingExportOrdersPostsUnderHeadings() throws {
        try withOperations { ops, db in
            let first = try ops.createPost(title: "First")
            try ops.newBlock(in: first.id, text: "Alpha body.")
            let second = try ops.createPost(title: nil, entryDate: "2026-07-14")
            try ops.newBlock(in: second.id, text: "Beta body.")
            let reading = try ops.createReading(name: "My Book", kind: .book)
            try ops.addPostToReading(first.id, to: reading.id)
            try ops.addPostToReading(second.id, to: reading.id)

            let exported = try db.read { try Queries.exportReading($0, readingID: reading.id) }
            #expect(exported == """
                # My Book

                ## First

                Alpha body.

                ## 2026-07-14

                Beta body.
                """)

            // A missing reading exports empty (tolerant read).
            let missing = try db.read { try Queries.exportReading($0, readingID: "nope") }
            #expect(missing.isEmpty)
        }
    }

    @Test func groupedReadingExportEmitsSectionHeadings() throws {
        try withOperations { ops, db in
            let root = try ops.createTag(name: "book")
            let partOne = try ops.createTag(parent: root.id, name: "part-one")
            let partTwo = try ops.createTag(parent: root.id, name: "part-two")

            let a = try ops.createPost(title: "A")
            try ops.newBlock(in: a.id, text: "A body.")
            try ops.applyTag(partOne.id, toPost: a.id)
            let b = try ops.createPost(title: "B")
            try ops.newBlock(in: b.id, text: "B body.")
            try ops.applyTag(partTwo.id, toPost: b.id)

            let reading = try ops.createReading(
                name: "Grouped", kind: .book, groupingTagId: root.id)
            try ops.addPostToReading(a.id, to: reading.id)
            try ops.addPostToReading(b.id, to: reading.id)

            let exported = try db.read { try Queries.exportReading($0, readingID: reading.id) }
            #expect(exported == """
                # Grouped

                ## book/part-one

                ### A

                A body.

                ## book/part-two

                ### B

                B body.
                """)
        }
    }

    // MARK: - Bulk export (totality, layout, determinism)

    @Test func bulkExportManifestIsTotalOverLivePosts() throws {
        try withOperations { ops, db in
            let live = try ops.createPost(title: "Kept", entryDate: "2026-07-10")
            try ops.newBlock(in: live.id, text: "Kept body.")
            let untitled = try ops.createPost(title: nil, entryDate: "2026-07-11")
            try ops.newBlock(in: untitled.id, text: "Dated body.")
            let archived = try ops.createPost(title: "Shelved", entryDate: "2026-07-12")
            try ops.newBlock(in: archived.id, text: "Shelved body.")
            try ops.archiveContainer(archived.id)
            let deleted = try ops.createPost(title: "Gone", entryDate: "2026-07-13")
            try ops.newBlock(in: deleted.id, text: "Gone body.")
            try ops.deleteContainer(deleted.id)
            let reading = try ops.createReading(name: "Shelf", kind: .book)
            try ops.addPostToReading(live.id, to: reading.id)
            // Pools join the totality (author ruling 2026-07-16, #22c):
            // every live pool exactly once; a tombstoned pool absent.
            let pool = try ops.createPool(title: "Scraps")
            try ops.newBlock(in: pool.id, text: "Scrap one.")
            try ops.newBlock(in: pool.id, text: "Scrap two.")
            let deadPool = try ops.createPool(title: "Old Pool")
            try ops.newBlock(in: deadPool.id, text: "Dead scrap.")
            try ops.deleteContainer(deadPool.id)

            let manifest = try db.read { try Queries.bulkExportManifest($0) }
            let paths = manifest.map(\.relativePath)
            #expect(paths == [
                "2026-07-10 Kept.md",
                "2026-07-11.md",
                "Archived/2026-07-12 Shelved.md",
                "Pools/Scraps.md",
                "Readings/Shelf.md",
            ])
            // VX-126 (her option A, 2026-10-27) — a DELIBERATE byte-pin
            // update: a note's file is Copy full text's text, so a TITLED
            // note's file leads with its `{t:"…"}` header line (an untitled
            // one carries none — IC-11); pools and readings below are the
            // plain projection, unchanged.
            #expect(manifest[0].contents == "{t:\"Kept\"}\n\nKept body.")
            #expect(manifest[1].contents == "Dated body.")
            #expect(manifest[2].contents == "{t:\"Shelved\"}\n\nShelved body.")
            #expect(manifest[3].contents == "Scrap one.\n\nScrap two.")
            #expect(manifest[4].contents.contains("# Shelf"))
            #expect(manifest[4].contents.contains("Kept body."))
            // Totality: the deleted post and the deleted pool are nowhere.
            #expect(!manifest.contains { $0.contents.contains("Gone body.") })
            #expect(!manifest.contains { $0.contents.contains("Dead scrap.") })

            // Readings are the optional folder view; pools ride totality.
            let bare = try db.read {
                try Queries.bulkExportManifest($0, includeReadings: false)
            }
            #expect(bare.map(\.relativePath) == [
                "2026-07-10 Kept.md",
                "2026-07-11.md",
                "Archived/2026-07-12 Shelved.md",
                "Pools/Scraps.md",
            ])
        }
    }

    @Test func poolExportsRenderScrapsInPoolOrderWithCollisionHandling() throws {
        try withOperations { ops, db in
            // The Pools/ shape (author ruling 2026-07-16, #22c): the pool's
            // blocks through the one join brain — stored spacing included.
            let pool = try ops.createPool(title: "Ideas")
            try ops.newBlock(in: pool.id, text: "First scrap.\n")
            try ops.newBlock(in: pool.id, text: "Second scrap.")
            // An untitled pool and a same-named pool disambiguate like posts.
            let untitled = try ops.createPool(title: nil)
            try ops.newBlock(in: untitled.id, text: "Loose thought.")
            let twin = try ops.createPool(title: "ideas")
            try ops.newBlock(in: twin.id, text: "Twin scrap.")

            let manifest = try db.read { try Queries.bulkExportManifest($0) }
            let poolFiles = manifest.filter { $0.relativePath.hasPrefix("Pools/") }
            // 13k K2: a nameless pool is named by the day it was created,
            // here as well as in the app — the ONE display brain serves the
            // export half too (13g R6-3's reason, applied to pools).
            let untitledDay = try #require(
                DisplayTitle.day(fromStamp: DateFormatter.variorumISO8601.string(
                    from: untitled.createdAt)))
            #expect(poolFiles.map(\.relativePath) == [
                "Pools/Ideas.md",
                "Pools/\(untitledDay).md",
                "Pools/ideas \(twin.id.prefix(8)).md",
            ])
            #expect(poolFiles[0].contents == "First scrap.\n\nSecond scrap.")
            #expect(poolFiles[1].contents == "Loose thought.")
            #expect(poolFiles[2].contents == "Twin scrap.")
        }
    }

    @Test func bulkExportCollisionsDisambiguateWithTheIdSuffix() throws {
        try withOperations { ops, db in
            let one = try ops.createPost(title: "Same", entryDate: "2026-07-10")
            try ops.newBlock(in: one.id, text: "One.")
            let two = try ops.createPost(title: "same", entryDate: "2026-07-10")
            try ops.newBlock(in: two.id, text: "Two.")

            let manifest = try db.read { try Queries.bulkExportManifest($0) }
            #expect(manifest.count == 2)
            #expect(manifest[0].relativePath == "2026-07-10 Same.md")
            // Case-insensitive collision (APFS default): the second file
            // carries its post id's prefix — stable across runs.
            #expect(manifest[1].relativePath == "2026-07-10 same \(two.id.prefix(8)).md")
        }
    }

    @Test func sanitizedFilenameStripsSeparatorsAndBounds() {
        #expect(Queries.sanitizedFilename("a/b:c") == "a-b-c")
        #expect(Queries.sanitizedFilename("  lots   of\n space ") == "lots of- space")
        #expect(Queries.sanitizedFilename(".hidden.") == "hidden")
        #expect(Queries.sanitizedFilename(String(repeating: "x", count: 200)).count == 80)
        #expect(Queries.sanitizedFilename("") == "")
    }

    // MARK: - Pure projections (review focus 2)

    @Test func noExportPathWritesRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "P", entryDate: "2026-07-10")
            let minted = try ops.newBlock(in: post.id, text: "Body.")
            let alt = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(alt.id, text: "Alt.", charDelta: 0)
            let reading = try ops.createReading(name: "R", kind: .book)
            try ops.addPostToReading(post.id, to: reading.id)
            try db.clearOutbox()

            let counts: () throws -> [Int?] = {
                try [
                    db.fetchInt("SELECT COUNT(*) FROM container"),
                    db.fetchInt("SELECT COUNT(*) FROM block"),
                    db.fetchInt("SELECT COUNT(*) FROM variant"),
                    db.fetchInt("SELECT COUNT(*) FROM reading"),
                    db.fetchInt("SELECT SUM(sync_version) FROM variant"),
                    db.fetchInt("SELECT COUNT(*) FROM sync_outbox"),
                ]
            }
            let before = try counts()

            _ = try db.read { try Queries.exportPost($0, postID: post.id) }
            _ = try db.read { try Queries.exportPost($0, postID: post.id, includeVariants: true) }
            _ = try db.read { try Queries.exportBlock($0, blockID: minted.block.id) }
            _ = try db.read { try Queries.exportReading($0, readingID: reading.id) }
            _ = try db.read { try Queries.bulkExportManifest($0) }

            #expect(try counts() == before)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }
}
