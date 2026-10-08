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
            // 13s-b U1a (her explicit ruling, 2026-10-05 — "default mode study
            // is an explicit ruling"): a STORE that carries no voice wakes in
            // Study. JUSTIFIED EDIT: this line pinned R1's Terminal here; the
            // ruling moved the unset read and nothing else (the next suite
            // pins what stays).
            #expect(settings.voice == .study, "2026-10-05: a fresh store wakes in Study")
            #expect(settings.seamsVisible == false, "§12: boundaries invisible at rest")
            #expect(settings.editingIndicator == .off, "R14/R22: off is the default")
            #expect(settings.inlineComments == false, "R7: margin is the ruling")
            #expect(settings.followTheScroll == false, "R25: an OPTION, not a default")
            #expect(settings.fanStyle == .stack)
            // 18i (her R-Q5): *"Quiet should be the default, but toast
            // should still be an option"* — the DEFAULT is the ruling, so
            // an unseeded store resolves it here and nowhere else.
            #expect(settings.receiptStyle == .quiet, "R-Q5: quiet is her default")
        }
    }

    /// 18i: the receipt-style setting is a `setting` row like every other
    /// one on this pane — read-time default, round-trip, a garbage value
    /// reading as the default, and the outbox row that makes it synced
    /// document semantics.
    @Test func receiptStyleRoundTripsAndGarbageReadsAsQuiet() throws {
        try withOperations { ops, db in
            try ops.setReceiptStyle(.toast)
            #expect(try db.read { try Queries.themeSettings($0) }.receiptStyle == .toast)
            #expect(try db.outboxContains("setting", "receipt_style"),
                    "synced document semantics, the fan_style class")
            try ops.setReceiptStyle(.off)
            #expect(try db.read { try Queries.themeSettings($0) }.receiptStyle == .off)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'receipt_style'") == 1,
                    "upsert-only — never a second row")

            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'fireworks' WHERE key = 'receipt_style'")
            }
            #expect(try db.read { try Queries.themeSettings($0) }.receiptStyle == .quiet,
                    "an unrecognized value reads as her default, never as silence")
        }
    }

    /// 18l-c U8 (her R-18l-7 — *"you should also be able to turn this flash
    /// where your cursor is setting off, but it should default to on"*): the
    /// arrival-flash switch is a `setting` row of the receipt style's kind —
    /// the DEFAULT resolved at read time (ON, no seed), a round-trip, one row
    /// ever (upsert-only), the outbox row that makes it synced, and a value
    /// nobody recognizes reading as her default (ON), never as a silent OFF.
    @Test func arrivalFlashDefaultsOnRoundTripsAndGarbageReadsAsOn() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.themeSettings($0) }.arrivalFlash,
                    "R-18l-7: the flash defaults ON (no seed — the read-time default)")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'arrival_flash'") == 0,
                    "no seed: the default lives in the read")
            try ops.setArrivalFlash(false)
            #expect(try db.read { try Queries.themeSettings($0) }.arrivalFlash == false)
            #expect(try db.outboxContains("setting", "arrival_flash"),
                    "synced document semantics, the receipt_style class")
            try ops.setArrivalFlash(true)
            #expect(try db.read { try Queries.themeSettings($0) }.arrivalFlash)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'arrival_flash'") == 1,
                    "upsert-only — never a second row")
            #expect(try db.fetchString(
                "SELECT value FROM setting WHERE key = 'arrival_flash'") == "1",
                    "E2EE-clean: the stored value is a token, never prose")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'sparkle' WHERE key = 'arrival_flash'")
            }
            #expect(try db.read { try Queries.themeSettings($0) }.arrivalFlash,
                    "an unrecognized value reads as her default (ON), never as a silent OFF")
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
            // 13s-b U1a: an unreadable voice reads as the store's own default,
            // which is Study since 2026-10-05 (a JUSTIFIED EDIT of `.terminal`).
            #expect(settings.voice == .study)
            #expect(settings.editingIndicator == .off)
        }
    }

    // MARK: - Study as the fresh-store voice (13s-b U1a — her 2026-10-05 ruling)

    /// **The flip is the UNSET read and nothing else.** Her ruling: a fresh
    /// store wakes in Study; existing stores keep whatever voice is set — a
    /// default flip, never a migration. So: no key reads Study; a store that
    /// CARRIES a voice reads exactly that voice, Terminal included; and the
    /// read writes nothing (no seed, no outbox row — a migration in disguise
    /// would be both).
    @Test func aFreshStoreWakesInStudyAndAStoreThatCarriesAVoiceKeepsIt() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.themeSettings($0) }.voice == .study)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'theme_voice'") == 0,
                    "no seed: the default lives in the read")
            #expect(try !db.outboxContains("setting", "theme_voice"),
                    "reading the default wrote nothing to sync")

            try ops.setThemeVoice(.terminal)
            #expect(try db.read { try Queries.themeSettings($0) }.voice == .terminal,
                    "a store carrying Terminal keeps Terminal")
            try ops.setThemeVoice(.study)
            #expect(try db.read { try Queries.themeSettings($0) }.voice == .study)
        }
    }

    /// The two defaults are NAMED apart on purpose: the voice an unanswered
    /// STORE reads (Study, the ruling) and the placeholder a host draws
    /// before any store has answered — or forever, with no store at all —
    /// which stays the leading voice (R1's Terminal), `VoiceTokens.fallback`'s
    /// twin. Moving the placeholder would re-voice every storeless host (the
    /// lobby, previews, every mounted test surface) without a store ever
    /// having said Study.
    @Test func theUnsetStoreVoiceIsStudyAndThePlaceholderStaysTheLeadingVoice() {
        #expect(Queries.ThemeSettings.unsetStoreVoice == .study)
        #expect(Queries.ThemeSettings().voice == .terminal,
                "the pre-landing / storeless placeholder is unchanged")
    }

    // MARK: - The colour palette (18g — her R-Q6 · R-Q11 · R-Q13)

    /// The palette is a `setting` row of exactly its neighbours' kind:
    /// read-time default, round-trip, upsert-only, an outbox row (synced —
    /// her R-Q6), and a value nobody recognizes reading as the DEFAULT,
    /// which is the one reading that can never leave the app half-coloured.
    @Test func thePaletteRoundTripsAndGarbageReadsAsTheDefault() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.themeSettings($0) }.palette == .default,
                    "R-Q6: default = each voice's shipped colours")

            try ops.setThemePalette(.lavender)
            #expect(try db.read { try Queries.themeSettings($0) }.palette == .lavender)
            #expect(try db.outboxContains("setting", "theme_palette"),
                    "synced document semantics, the theme_voice class")

            try ops.setThemePalette(.goldAndBlack)
            #expect(try db.read { try Queries.themeSettings($0) }.palette == .goldAndBlack)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'theme_palette'") == 1,
                    "upsert-only — never a second row")

            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'chartreuse' WHERE key = 'theme_palette'")
            }
            #expect(try db.read { try Queries.themeSettings($0) }.palette == .default,
                    "an unrecognized palette reads as the shipped colours")
        }
    }

    /// **Her R-Q13's custom pair, validated on BOTH sides.** The setter
    /// normalizes what she typed (`#b9a7e6` and `B9A7E6` are one colour, so
    /// two devices converge to the same bytes under CAS); a value that is
    /// not a colour refuses the WHOLE write, leaving neither key touched;
    /// nil clears; and a value that reached the row by some other road
    /// reads as absent.
    @Test func theCustomSeedsNormalizeRefuseAndClear() throws {
        try withOperations { ops, db in
            var settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.customRoom == nil)
            #expect(settings.customAccent == nil)

            try ops.setThemeTints(room: "#b9a7e6", accent: nil)
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.customRoom == "B9A7E6", "canonical: no #, uppercase")
            #expect(settings.customAccent == nil, "an absent accent means DERIVED")
            #expect(try db.outboxContains("setting", "theme_tint"))

            // The optional second (the two-tone case).
            try ops.setThemeTints(room: "8A7A3A", accent: " #d4a72c ")
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.customRoom == "8A7A3A")
            #expect(settings.customAccent == "D4A72C")

            // A malformed half refuses the whole write — nothing lands.
            #expect(throws: OperationError.self) {
                try ops.setThemeTints(room: "8A7A3A", accent: "octarine")
            }
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.customAccent == "D4A72C", "the refused write changed nothing")
            #expect(throws: OperationError.self) {
                try ops.setThemeTints(room: "12345", accent: nil)
            }
            #expect(try db.read { try Queries.themeSettings($0) }.customRoom == "8A7A3A")

            // nil clears both, and the row survives (upsert-only, never
            // tombstoned — the cleared form is the empty string).
            try ops.setThemeTints(room: nil, accent: nil)
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.customRoom == nil)
            #expect(settings.customAccent == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = 'theme_tint'") == 1)

            // A value that arrived by another road is not a colour and is
            // not treated as one.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = 'rgb(1,2,3)' WHERE key = 'theme_tint'")
            }
            #expect(try db.read { try Queries.themeSettings($0) }.customRoom == nil)
        }
    }

    @Test func shelfPinsAppendRemoveAndSurviveMalformedJSON() throws {
        try withOperations { ops, db in
            let one = try ops.createReading(name: "journal", kind: .book)
            let two = try ops.createReading(name: "orbit", kind: .book)
            try ops.setShelfPinned(one.id, pinned: true)
            try ops.setShelfPinned(two.id, pinned: true)
            try ops.setShelfPinned(one.id, pinned: true)  // idempotent
            #expect(try db.read { try Queries.shelfPins($0) } == [one.id, two.id])

            try ops.setShelfPinned(one.id, pinned: false)
            #expect(try db.read { try Queries.shelfPins($0) } == [two.id])

            // 13i-a: the star lives ON the row (`reading.starred`); the
            // old setting is retired-as-read, so corrupting it changes
            // NOTHING — the sturdier form of "presentation, never truth".
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO setting (key, value) VALUES ('shelf_pins', 'not json')
                    ON CONFLICT (key) DO UPDATE SET value = excluded.value
                    """)
            }
            #expect(try db.read { try Queries.shelfPins($0) } == [two.id],
                    "the retired setting cannot touch the listing")
        }
    }

    /// 13i-e: the delete door refuses the daily Journal now (the guard), so
    /// the dead Journal arrives the ways one still can — an older build's
    /// delete or another device's tombstone — written as that row write. The
    /// designation is DERIVED from the live marker-bearer, so a dead one
    /// reads as none whatever the cached setting still names.
    @Test func dailyJournalBookDanglesToNil() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Journal", kind: .book, profile: "journal")
            try ops.setDailyJournalBook(book.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == book.id)
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: book.id)) {
                try ops.deleteReading(book.id)
            }
            try db.write { db in
                let stamp = DateFormatter.variorumISO8601.string(from: harnessNow)
                try db.execute(
                    sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, book.id])
            }
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil,
                    "a dead designated book reads as none (the fallback class)")
        }
    }
}

/// 18g — the ONE seed rule, on its own (`ThemeTint`): what it tolerates,
/// what it refuses, and the canonical form both the setter and the read
/// agree on.
@Suite("Palette seeds (18g — ThemeTint)")
struct ThemeTintTests {
    @Test func sixHexDigitsInAnyOfTheWaysSheWouldWriteThem() {
        #expect(ThemeTint.normalize("B9A7E6") == "B9A7E6")
        #expect(ThemeTint.normalize("b9a7e6") == "B9A7E6")
        #expect(ThemeTint.normalize("#b9a7e6") == "B9A7E6")
        #expect(ThemeTint.normalize("  #B9A7E6\n") == "B9A7E6")
        #expect(ThemeTint.value("#000000") == 0x000000)
        #expect(ThemeTint.value("ffffff") == 0xFFFFFF)
        #expect(ThemeTint.value("3D6B8E") == 0x3D6B8E)
    }

    @Test func everythingElseIsNotAColour() {
        for raw in [
            "", " ", "#", "12345", "1234567", "##B9A7E6", "B9A7E", "GGGGGG",
            "0x123456", "rgb(1,2,3)", "lavender", "B9 A7 E6", "B9A7E6FF",
        ] {
            #expect(ThemeTint.normalize(raw) == nil, "not a colour: \u{201C}\(raw)\u{201D}")
            #expect(ThemeTint.value(raw) == nil)
        }
        #expect(ThemeTint.normalize(nil) == nil)
        #expect(ThemeTint.normalize(ThemeTint.cleared) == nil, "the cleared form reads as absent")
    }

    /// Full-width digits satisfy `isHexDigit` and are not hexadecimal — the
    /// `radix: 16` parse would reject them a step later, so the two halves
    /// agree HERE rather than disagreeing there.
    @Test func lookalikeDigitsAreRefusedByTheSameRule() {
        #expect(ThemeTint.normalize("Ｂ９Ａ７Ｅ６") == nil)
        #expect(ThemeTint.value("Ｂ９Ａ７Ｅ６") == nil)
    }
}

@Suite("Shelf, pool & catalog queries (Phase 13, B2)")
struct ShelfQueryTests {
    @Test func bookshelfCountsPostsAndChapters() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "orbit", kind: .book)
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
            let book = try ops.createReading(name: "orbit", kind: .book)
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
            let book = try ops.createReading(name: "orbit", kind: .book)
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
            let book = try ops.createReading(name: "orbit", kind: .book)
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
                name: "star-notes", kind: .gathering,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            // 13i-d U5 R1: a LEGACY targeted gathering — the mint refuses an
            // extent now, so the fixture writes the raw row (U4's precedent:
            // how a pre-13i-d or synced one exists). Assertions untouched.
            try db.write {
                try $0.execute(
                    sql: "UPDATE reading SET word_target = 100 WHERE id = ?",
                    arguments: [smart.id])
            }

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
                name: "star-notes", kind: .gathering,
                querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            // 13i-d U5 R1: a LEGACY capped gathering, written raw (the mint
            // refuses an extent now — U4's re-staging precedent).
            try db.write {
                try $0.execute(
                    sql: "UPDATE reading SET max_posts = 2 WHERE id = ?", arguments: [smart.id])
            }

            let curated = try ops.createReading(name: "orbit", kind: .book)
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
            let book = try ops.createReading(name: "b", kind: .book)
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
                name: "star-notes", kind: .gathering,
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
            _ = try ops.createReading(name: "corrupt", kind: .gathering, querySpec: "not json")
            pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            #expect(Set(pool.map(\.postID)) == [tagged.id, plain.id])
        }
    }

    @Test func readingsContainingFeedsTheMembershipChip() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "shared", profile: .generic)
            let one = try ops.createReading(name: "alpha", kind: .book)
            let two = try ops.createReading(name: "beta", kind: .book)
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
            let book = try ops.createReading(name: "orbit", kind: .book)
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
            let book = try ops.createReading(name: "Orbit", kind: .book)
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
