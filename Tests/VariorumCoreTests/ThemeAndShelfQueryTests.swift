import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Stage B core seams: the appearance settings (B1) and the
/// shelf/pool/catalog read side (B2). Behavioral seams pinned per the
/// ground rules; the SwiftUI faces stay untested visual work.
@Suite("Appearance settings (Phase 13, B1)")
struct AppearanceSettingsTests {
    @Test func defaultsMatchTheSittingsLetter() throws {
        try withOperations { _, db in
            let settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.voice == .terminal, "R1: the Terminal voice LEADS")
            #expect(settings.seamsVisible == false, "§12: boundaries invisible at rest")
            #expect(settings.editingIndicator == .off, "R14/R22: off is the default")
            #expect(settings.inlineComments == false, "R7: margin is the ruling")
            #expect(settings.followTheScroll == false, "R25: an OPTION, not a default")
            #expect(settings.fanStyle == .stack)
        }
    }

    @Test func settersRoundTripAndUpsertNeverDuplicates() throws {
        try withOperations { ops, db in
            try ops.setThemeVoice(.study)
            try ops.setSeamsVisible(true)
            try ops.setEditingIndicator(.outline)
            try ops.setInlineComments(true)
            try ops.setFollowTheScroll(true)
            var settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.voice == .study)
            #expect(settings.seamsVisible)
            #expect(settings.editingIndicator == .outline)
            #expect(settings.inlineComments)
            #expect(settings.followTheScroll)

            // Re-set: upsert updates in place (settings are upsert-only,
            // never duplicated — AppSpec §7).
            try ops.setThemeVoice(.terminal)
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.voice == .terminal)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'theme_voice'") == 1)
            // And the write reached the outbox (synced document semantics).
            #expect(try db.outboxContains("setting", "theme_voice"))
        }
    }

    @Test func garbageStoredValuesReadAsDefaults() throws {
        try withOperations { _, db in
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO setting (key, value) VALUES
                      ('theme_voice', 'neon'), ('editing_indicator', 'strobe')
                    """)
            }
            let settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.voice == .terminal)
            #expect(settings.editingIndicator == .off)
        }
    }

    @Test func shelfPinsAppendRemoveAndSurviveMalformedJSON() throws {
        try withOperations { ops, db in
            let one = try ops.createReading(name: "journal", kind: .curated)
            let two = try ops.createReading(name: "orbit", kind: .curated)
            try ops.setShelfPinned(one.id, pinned: true)
            try ops.setShelfPinned(two.id, pinned: true)
            try ops.setShelfPinned(one.id, pinned: true)  // idempotent
            #expect(try db.read { try Queries.shelfPins($0) } == [one.id, two.id])

            try ops.setShelfPinned(one.id, pinned: false)
            #expect(try db.read { try Queries.shelfPins($0) } == [two.id])

            try db.write { db in
                try db.execute(sql: "UPDATE setting SET value = 'not json' WHERE key = 'shelf_pins'")
            }
            #expect(try db.read { try Queries.shelfPins($0) } == [],
                    "malformed pins read as none — presentation, never truth")
        }
    }

    @Test func dailyJournalBookDanglesToNil() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Journal", kind: .curated, profile: "journal")
            try ops.setDailyJournalBook(book.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == book.id)
            try ops.deleteReading(book.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil,
                    "a dead designated book reads as none (the fallback class)")
        }
    }
}

@Suite("Shelf, pool & catalog queries (Phase 13, B2)")
struct ShelfQueryTests {
    @Test func bookshelfCountsPostsAndChapters() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .curated)
            _ = try ops.createSection(in: book.id, name: "I")
            _ = try ops.createSection(in: book.id, name: "II")
            for index in 0..<3 {
                let post = try ops.createPost(title: "p\(index)", profile: .generic)
                _ = try ops.addPostToReading(post.id, to: book.id)
            }
            let shelf = try db.read { try Queries.bookshelf($0) }
            #expect(shelf.count == 1)
            #expect(shelf[0].postCount == 3)
            #expect(shelf[0].sectionCount == 2)
        }
    }

    @Test func bookWordCountsSumTheRenderedTakesOnly() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .curated)
            let post = try ops.createPost(title: "p", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "one two three", at: .end)
            // A second take with MORE words — unchosen, must not count.
            let alt = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(alt.id, text: "one two three four five six", charDelta: 14)
            _ = try ops.newBlock(in: post.id, text: "four five", at: .end)
            _ = try ops.addPostToReading(post.id, to: book.id)

            let counts = try db.read { try Queries.bookWordCounts($0) }
            #expect(counts[book.id] == 5, "3 + 2 rendered words; the unchosen take never counts")
        }
    }

    @Test func wordCountsUseTheEditorsRuleNotSpaceArithmetic() throws {
        // Round 2, MAJOR 4 (red-on-old): newlines separate words (I4's
        // multi-paragraph blocks; the 2026-07-12 spacing ruling stores
        // meaningful newlines), consecutive spaces don't multiply, and the
        // rule is the editor's own Unicode .byWords — two surfaces, ONE
        // answer.
        #expect(Queries.wordCount("one\ntwo") == 2, "the old SQL counted 1")
        #expect(Queries.wordCount("a  b") == 2, "the old SQL counted 3")
        #expect(Queries.wordCount("  ") == 0)
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .curated)
            let post = try ops.createPost(title: "p", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "first line\nsecond  line", at: .end)
            _ = try ops.addPostToReading(post.id, to: book.id)
            let counts = try db.read { try Queries.bookWordCounts($0) }
            #expect(counts[book.id] == 4)
        }
    }

    @Test func wordCountsExcludeArchivedMembersAndCountSmartBooks() throws {
        // Round 2, MINOR skews (red-on-old both halves): the book view
        // excludes archived members (the Phase 4 ambient ratification) —
        // the shelf number must agree; and a word target on a SMART book
        // must show real progress, never a perpetual 0%.
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .curated)
            let live = try ops.createPost(title: "live", profile: .generic)
            _ = try ops.newBlock(in: live.id, text: "three live words", at: .end)
            _ = try ops.addPostToReading(live.id, to: book.id)
            let archived = try ops.createPost(title: "archived", profile: .generic)
            _ = try ops.newBlock(in: archived.id, text: "these words must not count", at: .end)
            _ = try ops.addPostToReading(archived.id, to: book.id)
            try ops.archiveContainer(archived.id)

            let stars = try ops.createTag(parent: nil, name: "stars")
            let tagged = try ops.createPost(title: "tagged", profile: .generic)
            _ = try ops.newBlock(in: tagged.id, text: "two words", at: .end)
            try ops.applyTag(stars.id, toPost: tagged.id)
            let smart = try ops.createReading(
                name: "star-notes", kind: .smart,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON(),
                wordTarget: 100)

            let counts = try db.read { try Queries.bookWordCounts($0) }
            #expect(counts[book.id] == 3, "the archived member's words never count")
            #expect(counts[smart.id] == 2, "smart books count their derived members")
        }
    }

    @Test func cappedBooksCountExactlyTheAssemblysCappedSet() throws {
        // Round 3 NIT (red-on-old: the pre-fix counts summed EVERY match/
        // member): max_posts LIMITs the book view read-side, so the shelf
        // number counts the capped, ordered set the reader sees — for a
        // capped SMART book and for a curated book whose cap was lowered
        // below its membership (#25(d) legal).
        try withOperations { ops, db in
            let stars = try ops.createTag(parent: nil, name: "stars")
            for text in ["one two", "one two three", "one two three four"] {
                let post = try ops.createPost(title: text, profile: .generic)
                _ = try ops.newBlock(in: post.id, text: text, at: .end)
                try ops.applyTag(stars.id, toPost: post.id)
            }
            let smart = try ops.createReading(
                name: "star-notes", kind: .smart,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON(),
                maxPosts: 2)

            let curated = try ops.createReading(name: "orbit", kind: .curated)
            let a = try ops.createPost(title: "a", profile: .generic)
            _ = try ops.newBlock(in: a.id, text: "alpha beta gamma", at: .end)
            _ = try ops.addPostToReading(a.id, to: curated.id)
            let b = try ops.createPost(title: "b", profile: .generic)
            _ = try ops.newBlock(in: b.id, text: "delta epsilon", at: .end)
            _ = try ops.addPostToReading(b.id, to: curated.id)
            try ops.setReadingMaxPosts(curated.id, maxPosts: 1)  // lowered below membership

            let counts = try db.read { try Queries.bookWordCounts($0) }
            // Smart, capped at 2: created_at-ASC order → the 2- and 3-word
            // posts count; the 4-word third match does NOT (old code: 9).
            #expect(counts[smart.id] == 5,
                    "a capped smart book counts its assembly's capped set")
            // Curated, cap lowered to 1: only the first member counts
            // (old code: 5).
            #expect(counts[curated.id] == 3,
                    "a lowered cap counts what the book view shows")

            // And the counts agree with the assembly itself — one brain.
            let smartAssembly = try db.read { try Queries.assembleReading($0, readingID: smart.id) }
            #expect(smartAssembly.count == 2)
        }
    }

    @Test func poolPostsAreExactlyTheBooklessLivePosts() throws {
        try withOperations { ops, db in
            let inBook = try ops.createPost(title: "in a book", profile: .generic)
            let book = try ops.createReading(name: "b", kind: .curated)
            _ = try ops.addPostToReading(inBook.id, to: book.id)
            let floating = try ops.createPost(title: "floating", profile: .generic)
            let archived = try ops.createPost(title: "archived", profile: .generic)
            try ops.archiveContainer(archived.id)
            let deleted = try ops.createPost(title: "deleted", profile: .generic)
            try ops.deleteContainer(deleted.id)
            _ = try ops.createPool(title: "scraps")  // pools are never posts

            let pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(pool.map(\.postID) == [floating.id],
                    "bookless + live + unarchived, nothing else")

            // Removing the membership returns the post to the pool —
            // the surface is a query, never a state to maintain.
            try ops.removePostFromReading(inBook.id, from: book.id)
            let after = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(Set(after.map(\.postID)) == [floating.id, inBook.id])
        }
    }

    @Test func promotedSmartBooksDrainThePoolAndFeedTheChip() throws {
        // Round 2, MAJOR 3 (red-on-old): R30's flagship gesture — promote
        // #stars to a book — must DRAIN the pool and show on the R35 chip;
        // derived membership counts as being in a book. The flap is the
        // recorded consequence (#26(h)): tag edits move posts in and out.
        try withOperations { ops, db in
            let stars = try ops.createTag(parent: nil, name: "stars")
            let tagged = try ops.createPost(title: "starry", profile: .generic)
            _ = try ops.newBlock(in: tagged.id, text: "Prose.", at: .end)
            try ops.applyTag(stars.id, toPost: tagged.id)
            let plain = try ops.createPost(title: "plain", profile: .generic)
            _ = try ops.newBlock(in: plain.id, text: "Prose.", at: .end)

            // Before the promotion: both are bookless.
            var pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(Set(pool.map(\.postID)) == [tagged.id, plain.id])

            // The promotion (R30: tags → a saved smart book).
            let smart = try ops.createReading(
                name: "star-notes", kind: .smart,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())

            pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(pool.map(\.postID) == [plain.id],
                    "the tagged post DRAINED — derived membership is membership")
            let chip = try db.read { try Queries.readingsContaining($0, postID: tagged.id) }
            #expect(chip.map(\.id) == [smart.id],
                    "the chip shows the smart book — one membership truth")

            // The flap (recorded): untag → back to the pool, off the chip.
            try ops.removeTag(stars.id, fromPost: tagged.id)
            pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(Set(pool.map(\.postID)) == [tagged.id, plain.id])
            #expect(try db.read { try Queries.readingsContaining($0, postID: tagged.id) }.isEmpty)

            // A MALFORMED spec matches nothing (fail closed — the ratified
            // rule): the pool is unaffected by a corrupt book.
            _ = try ops.createReading(name: "corrupt", kind: .smart, querySpec: "not json")
            pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(Set(pool.map(\.postID)) == [tagged.id, plain.id])
        }
    }

    @Test func readingsContainingFeedsTheMembershipChip() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "shared", profile: .generic)
            let one = try ops.createReading(name: "alpha", kind: .curated)
            let two = try ops.createReading(name: "beta", kind: .curated)
            _ = try ops.addPostToReading(post.id, to: one.id)
            _ = try ops.addPostToReading(post.id, to: two.id)
            let books = try db.read { try Queries.readingsContaining($0, postID: post.id) }
            #expect(books.map(\.name) == ["alpha", "beta"])

            try ops.removePostFromReading(post.id, from: one.id)
            #expect(try db.read { try Queries.readingsContaining($0, postID: post.id) }
                .map(\.name) == ["beta"])
        }
    }

    @Test func shelfBookTagsRankMemberTagsByFrequency() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .curated)
            let sailing = try ops.createTag(parent: nil, name: "sailing")
            let rare = try ops.createTag(parent: nil, name: "rare")
            for index in 0..<3 {
                let post = try ops.createPost(title: "p\(index)", profile: .generic)
                _ = try ops.addPostToReading(post.id, to: book.id)
                try ops.applyTag(sailing.id, toPost: post.id)
                if index == 0 { try ops.applyTag(rare.id, toPost: post.id) }
            }
            let tags = try db.read { try Queries.shelfBookTags($0) }
            #expect(tags[book.id] == ["sailing", "rare"])
        }
    }

    @Test func searchCatalogFindsBooksPostsAndBlocks() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orbit", kind: .curated)
            let post = try ops.createPost(title: "the storm chapter", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            try ops.setBlockName(made.block.id, name: "the storm thesis")
            let pool = try ops.createPool(title: "scraps")
            _ = try ops.newBlock(in: pool.id, text: "a storm scrap idea", at: .end)

            let hits = try db.read { try Queries.searchCatalog($0, query: "storm") }
            let kinds = Dictionary(grouping: hits, by: \.kind)
            #expect(kinds[.post]?.map(\.title) == ["the storm chapter"])
            #expect(Set((kinds[.block] ?? []).map(\.title))
                    == ["the storm thesis", "a storm scrap idea"])
            #expect(kinds[.book] == nil)

            let orbit = try db.read { try Queries.searchCatalog($0, query: "orb") }
            #expect(orbit.contains { $0.kind == .book && $0.id == book.id })

            // The resting state: books + recent posts, no block noise.
            let resting = try db.read { try Queries.searchCatalog($0, query: "") }
            #expect(resting.contains { $0.kind == .book })
            #expect(resting.contains { $0.kind == .post })
            #expect(!resting.contains { $0.kind == .block })
        }
    }
}

/// 13d batch 4 (A16 — N34's deferred GLOBAL half). Her row: the
/// newline-makes-a-block setting reachable beyond the per-post chip. 13b's
/// 4D record named the exact blocker — *"no public `default_segmentation`
/// setter exists; `upsertSetting` is Operations-internal"* — so this suite
/// pins the setter and its read, and above all pins that NOTHING about
/// segmentation's meaning moved: the value has been consulted by
/// `containerHeader` since Phase 7, and the per-post override still wins.
@Suite("Global segmentation default (13d A16)")
struct GlobalSegmentationDefaultTests {
    @Test func theSeededDefaultIsParagraphAndReadsThroughTheQuery() throws {
        try withOperations { _, db in
            let seeded = try db.read { try Queries.defaultSegmentation($0) }
            #expect(seeded == .paragraph)
        }
    }

    @Test func theSetterRoundTripsUpsertsInPlaceAndReachesTheOutbox() throws {
        try withOperations { ops, db in
            try ops.setDefaultSegmentation(.oneBlock)
            let off = try db.read { try Queries.defaultSegmentation($0) }
            #expect(off == .oneBlock)
            try ops.setDefaultSegmentation(.paragraph)
            let on = try db.read { try Queries.defaultSegmentation($0) }
            #expect(on == .paragraph)
            // Upsert-only, never duplicated (AppSpec §7's setting class)…
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'default_segmentation'") == 1)
            // …and synced like every other document-semantics setting.
            #expect(try db.outboxContains("setting", "default_segmentation"))
        }
    }

    @Test func anAbsentOrGarbageValueReadsAsParagraph() throws {
        try withOperations { _, db in
            try db.write {
                try $0.execute(
                    sql: "DELETE FROM setting WHERE key = 'default_segmentation'")
            }
            let absent = try db.read { try Queries.defaultSegmentation($0) }
            #expect(absent == .paragraph)
            try db.write {
                try $0.execute(sql: """
                    INSERT INTO setting (key, value)
                    VALUES ('default_segmentation', 'stanza')
                    """)
            }
            let garbage = try db.read { try Queries.defaultSegmentation($0) }
            #expect(garbage == .paragraph)
        }
    }

    /// The whole point of the setting, and the reason it needed no
    /// semantics work: `containerHeader.effectiveSegmentation` has resolved
    /// per-post override → this setting → `.paragraph` since Phase 7.
    @Test func theGlobalGovernsPostsWithoutAnOverrideAndNeverThoseWithOne() throws {
        try withOperations { ops, db in
            let inherits = try ops.createPost(title: "inherits")
            let pinned = try ops.createPost(title: "pinned")
            try ops.setSegmentationDefault(pinned.id, segmentation: .paragraph)

            func mode(_ id: String) throws -> Segmentation? {
                try db.read { try Queries.containerHeader($0, containerID: id) }?
                    .effectiveSegmentation
            }
            let inheritsBefore = try mode(inherits.id)
            let pinnedBefore = try mode(pinned.id)
            #expect(inheritsBefore == .paragraph)
            #expect(pinnedBefore == .paragraph)

            try ops.setDefaultSegmentation(.oneBlock)
            let inheritsAfter = try mode(inherits.id)
            let pinnedAfter = try mode(pinned.id)
            #expect(inheritsAfter == .oneBlock, "no override ⇒ the global governs")
            #expect(pinnedAfter == .paragraph, "an override still wins — untouched")
        }
    }

    /// The consequence the app's copy has to speak about (13d batch 4's
    /// honesty fix): under a global `one_block`, the per-post chip's "on"
    /// writes NIL — 4D's deliberate inherit mapping — and the post still
    /// does not mint. The mapping is pinned here so the app's note can be
    /// pinned against it rather than against a guess.
    @Test func turningAPostBackOnUnderAGlobalOneBlockStillInherits() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p")
            try ops.setDefaultSegmentation(.oneBlock)
            try ops.setSegmentationDefault(post.id, segmentation: .paragraph)
            let overridden = try db.read {
                try Queries.containerHeader($0, containerID: post.id)
            }?.effectiveSegmentation
            #expect(overridden == .paragraph)

            // The chip's "on" = clear the override.
            try ops.setSegmentationDefault(post.id, segmentation: nil)
            let inherited = try db.read {
                try Queries.containerHeader($0, containerID: post.id)
            }?.effectiveSegmentation
            #expect(inherited == .oneBlock)
        }
    }
}
