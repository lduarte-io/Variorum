//
//  SampleLibraryTests.swift
//  VariorumTests
//
//  Pre-13u round, Act 3 — the sample library's acceptance bar, as tests.
//
//  Two of these are HER OWN verification items, named in the plan:
//    · the Pool (bookless notes) is BLANK on a fresh seeded store — *"the
//      Pool is the library for items not in a book — that'll be blank for
//      new users"*; a seeding bug that left the stories bookless would fill
//      a new reader's Pool with twelve strangers on first launch;
//    · the `sherlock holmes` tag selects the WHOLE set, so the library is
//      findable and removable in one gesture.
//
//  The rest pin the traps the act was warned about: no structural-undo
//  entries for furniture the reader never placed (trap 2), idempotence
//  (trap 3), and — because the seed runs from a cancellable window task —
//  resumability.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withSampleWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1661))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A defaults-free mark, so a pin never touches this machine's real ones.
@MainActor
private final class Mark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

@MainActor
@Suite("The sample library — Sherlock as a real book")
struct SampleLibraryTests {

    // MARK: - The bundled text

    @Test("The bundled text is the twelve adventures, unwrapped into paragraphs")
    func bundledTextIsTheTwelveAdventures() throws {
        let stories = try SampleLibrarySeeder.loadStories()
        #expect(stories.count == 12)
        #expect(stories.first?.title == "A Scandal in Bohemia")
        #expect(stories.last?.title == "The Adventure of the Copper Beeches")

        // Her two targets in one corpus: ~105k words in the book, ~10k in a
        // note. If a future re-extraction changes the shape, this says so.
        let words = stories.reduce(0) { $0 + $1.text.split(separator: " ").count }
        #expect(words > 100_000 && words < 110_000)
        let longest = stories.map { $0.text.split(separator: " ").count }.max() ?? 0
        #expect(longest > 9_000)

        // The unwrapping is the load-bearing part: `bulkSegments` splits
        // paragraph mode on every non-blank LINE, so hard-wrapped text would
        // mint ~11,000 one-line blocks instead of 2,530 paragraphs.
        let blocks = stories.reduce(0) {
            $0 + SegmentationRules.bulkSegments($1.text, mode: .paragraph).count
        }
        #expect(blocks > 2_000 && blocks < 3_000)

        // No Project Gutenberg boilerplate rides along.
        for story in stories {
            #expect(!story.text.contains("Project Gutenberg"))
            #expect(!story.text.contains("PROJECT GUTENBERG"))
        }
    }

    @Test("Delimiter parsing takes the titles and never stores the delimiter")
    func parsingTakesTitlesAndDropsDelimiters() {
        let stories = SampleLibrarySeeder.parse("""
            %%% First Story

            One paragraph.

            Another paragraph.

            %%% Second Story

            Only one here.
            """)
        #expect(stories.map(\.title) == ["First Story", "Second Story"])
        #expect(stories[0].text == "One paragraph.\n\nAnother paragraph.")
        #expect(stories[1].text == "Only one here.")
    }

    // MARK: - What a seeded store holds

    @Test("Twelve stories become twelve notes in twelve chapters, plus the attribution")
    func seedMintsTheBook() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, let stories) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(stories == 12)
            #expect(mark.value)

            try await db.read { db in
                let book = try Queries.reading(db, id: bookID)
                #expect(book?.name == SampleLibrarySeeder.bookName)
                #expect(book?.kind == .curated)

                // 13 chapters: the front matter, then one per story — and
                // every chapter carries exactly one note (this is the first
                // real book `reading_section` has ever held).
                let chapters = try Queries.readingSections(db, readingID: bookID)
                #expect(chapters.count == 13)
                #expect(chapters.first?.name == SampleLibrarySeeder.frontMatterChapter)

                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.count == 13)
                #expect(entries.allSatisfy { $0.sectionPath != nil })
                let sections = Set(entries.compactMap(\.sectionPath))
                #expect(sections.count == 13)  // no chapter holds two notes

                // The prose really landed: paragraphs, not one giant block.
                let scandal = try #require(
                    entries.first { $0.title == "A Scandal in Bohemia" })
                let blocks = try Queries.renderPost(db, containerID: scandal.postID)
                #expect(blocks.count > 200)
            }
        }
    }

    /// **The midpoint review's M1, pinned.** The seed used to mint through
    /// `importPost`'s GLOBAL-setting chain, so a reader who had chosen the
    /// shipped "One block" segmentation option got the whole sample library
    /// as thirteen giant blocks — Blocks/Index/Outline showing thirteen
    /// rows for 105k words, and an autosave rewriting ~60 KB per keystroke
    /// inside a story. That inverts the act's entire purpose (her ruling:
    /// the library exists to make the app's power legible at scale), and
    /// nothing in the shipped suite could see it, because every other pin
    /// ran under the schema's `.paragraph` seed.
    ///
    /// *Red on the old code:* `.oneBlock` → the scandal renders as ONE
    /// block, so `> 200` fails. Verified by reverting the fix.
    @Test("The seed names its own mode: 'One block' does not flatten the library")
    func theSeedIsIndependentOfTheReadersSegmentationSetting() async throws {
        try await withSampleWorld { session, db in
            // The reader's document-global choice — the one door that sets
            // it (13d batch 4, her A16).
            try await session.runner.run { ops in
                try ops.setDefaultSegmentation(.oneBlock)
            }
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            try await db.read { db in
                let book = try #require(
                    Queries.readings(db)
                        .first { $0.name == SampleLibrarySeeder.bookName })
                let entries = try Queries.assembleReading(db, readingID: book.id)
                let scandal = try #require(
                    entries.first { $0.title == "A Scandal in Bohemia" })
                let blocks = try Queries.renderPost(db, containerID: scandal.postID)
                #expect(blocks.count > 200,
                        "the sample library must be paragraphs whatever the reader's setting says")

                // …and the reader's own setting is UNTOUCHED: naming a mode
                // for shipped content must never rewrite her document
                // semantics (`setting` rows are synced).
                #expect(try Queries.defaultSegmentation(db) == .oneBlock)
            }
        }
    }

    @Test("HER CHECK: the Pool is blank on a freshly seeded store")
    func thePoolIsBlank() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            let bookless = try await db.read { db in
                try Queries.poolPosts(db, limit: 100)
            }
            #expect(bookless.isEmpty)
        }
    }

    @Test("HER CHECK: the sherlock holmes tag selects the whole set")
    func theTagSelectsTheWholeSet() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            try await db.read { db in
                let tag = try #require(
                    Queries.allTags(db).first { $0.path == SampleLibrarySeeder.tagName })
                let tagged = try Queries.everythingTagged(db, tagID: tag.id)
                #expect(tagged.postIDs.count == 13)
                let titles = Set(
                    try tagged.postIDs.compactMap {
                        try Container.fetchOne(db, key: $0)?.title
                    })
                #expect(titles.contains("A Scandal in Bohemia"))
                #expect(titles.contains(SampleLibrarySeeder.frontMatterTitle))
            }
        }
    }

    /// **The midpoint review's m6, pinned (PROVISIONAL — her nod pending).**
    /// The seed is default-on into EXISTING stores, so stamping at seed time
    /// put thirteen Conan Doyle notes at the TOP of the Library and the
    /// Timeline, above her own recent writing, on her real store at the next
    /// launch. The stamps were wrong, not the sort: seeded stories carry the
    /// work's publication date, so they sort where they belong and read
    /// honestly on a timeline.
    ///
    /// *Red on the old code:* the seeded thirteen lead `.lastTouched` desc
    /// and her note is 14th; the timeline's oldest page is 2026, not 1892.
    /// Verified by reverting the fix.
    @Test("Seeded stories are stamped 1892, so they never displace her own writing")
    func theLibraryIsBackDatedToItsPublication() async throws {
        try await withSampleWorld { session, db in
            // Her own writing, minted on the ordinary clock.
            let hers = try await session.runner.run { ops in
                try ops.importPost(title: "Mine", text: "Today's thought.").container.id
            }

            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }

            let stamp = SampleLibrarySeeder.publicationStamp
            try await db.read { db in
                // HER note leads every recency listing; the thirteen trail.
                let recent = try Queries.library(
                    db, sort: .lastTouched, direction: .desc, limit: 50)
                #expect(recent.count == 14)
                #expect(recent.first?.postID == hers,
                        "her own note must lead the Library's recency sort")
                #expect(recent.dropFirst().allSatisfy { $0.stamp == stamp },
                        "every seeded story sits below it, at the publication date")

                // The same for the by-revision stamp (the churn crossing the
                // first minted block always lands) and for `created_at`.
                let revised = try Queries.library(
                    db, sort: .lastMajorRevision, direction: .desc, limit: 50)
                #expect(revised.first?.postID == hers)
                let created = try Queries.library(
                    db, sort: .createdAt, direction: .desc, limit: 50)
                #expect(created.first?.postID == hers)

                // …and the Timeline really places them in 1892 — the oldest
                // page is the sample library, stamped to the day.
                let oldest = try Queries.timelinePage(
                    db, order: .lastTouched, direction: .asc, limit: 13)
                #expect(oldest.count == 13)
                #expect(oldest.allSatisfy { $0.stamp == stamp })
                #expect(oldest.allSatisfy { $0.createdAt == stamp })
            }
        }
    }

    // MARK: - The traps

    @Test("TRAP 2: seeding leaves no structural-undo entry — the reader's first ⌥⌘Z is hers")
    func seedRegistersNoUndoEntry() async throws {
        try await withSampleWorld { session, _ in
            let mark = Mark()
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(session.undoStack.depth == 0)
            #expect(session.undoStack.topLabel == nil)
        }
    }

    @Test("TRAP 3: seeding twice mints no second book")
    func seedingTwiceIsANoOp() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            // The device mark is the first guard.
            let second = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(second == .alreadySeeded)
            // And with the mark gone — a reinstall, or another store variant
            // — DISCOVERY is the guard that holds.
            mark.value = false
            let third = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(third == .alreadyPresent)

            try await db.read { db in
                let books = try Queries.readings(db)
                    .filter { $0.name == SampleLibrarySeeder.bookName }
                #expect(books.count == 1)
                let posts = try Queries.library(db, limit: 200)
                #expect(posts.count == 13)
            }
        }
    }

    @Test("A cancelled seed resumes: the missing stories are minted, the rest untouched")
    func aPartialSeedResumes() async throws {
        try await withSampleWorld { session, db in
            // Seed only the first four stories — what a window closed
            // mid-seed leaves behind.
            let all = try SampleLibrarySeeder.loadStories()
            _ = try await SampleLibrarySeeder.seed(
                session: session, stories: Array(all.prefix(4)),
                existing: SampleLibrarySeeder.Existing())
            let partial = try await db.read { db in
                try Queries.library(db, limit: 100).count
            }
            #expect(partial == 5)  // 4 stories + the attribution

            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(_, let minted) = outcome else {
                Issue.record("expected a resumed seed, got \(outcome)")
                return
            }
            #expect(minted == 8)
            try await db.read { db in
                #expect(try Queries.library(db, limit: 200).count == 13)
                let books = try Queries.readings(db)
                    .filter { $0.name == SampleLibrarySeeder.bookName }
                #expect(books.count == 1)
                let chapters = try Queries.readingSections(db, readingID: books[0].id)
                #expect(chapters.count == 13)
            }
        }
    }

    /// **The midpoint review's m5(a), pinned.** `createSection` and
    /// `importPost` are separate transactions, so a seed cancelled between
    /// them leaves a chapter standing with no note in it — and chapter
    /// names are deliberately NOT unique (AppSpec §7: duplicate names
    /// legal, no natural key, no repair class). Resumability keyed on
    /// `presentTitles` alone therefore minted a SECOND chapter of the same
    /// name beside the empty one, and nothing would ever clear it.
    ///
    /// *Red on the old code:* 14 chapters, two of them "A Scandal in
    /// Bohemia", one empty. Verified by reverting the fix.
    @Test("A seed cancelled between the chapter and the note mints into THAT chapter")
    func aResumedSeedReusesAnEmptyChapterInsteadOfDoublingIt() async throws {
        try await withSampleWorld { session, db in
            let all = try SampleLibrarySeeder.loadStories()
            // A plain `String`: `Story` is nested in the `@MainActor` seeder,
            // so its members cannot be read from the nonisolated closures.
            let scandalTitle = try #require(all.first).title

            // The exact half-state: the book, and the first story's chapter,
            // with the note that belongs in it never minted.
            let half = try await session.runner.run {
                ops -> (book: String, chapter: String) in
                let book = try ops.createReading(
                    name: SampleLibrarySeeder.bookName, kind: .curated, profile: "book")
                let chapter = try ops.createSection(in: book.id, name: scandalTitle)
                return (book.id, chapter.id)
            }
            let bookID = half.book
            let halfState = try await db.read { db in
                (chapters: try Queries.readingSections(db, readingID: bookID).count,
                 entries: try Queries.assembleReading(db, readingID: bookID).count)
            }
            #expect(halfState == (chapters: 1, entries: 0))

            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let seededBook, let minted) = outcome else {
                Issue.record("expected a resumed seed, got \(outcome)")
                return
            }
            #expect(seededBook == bookID)   // the half-built book was adopted
            #expect(minted == 12)

            try await db.read { db in
                let chapters = try Queries.readingSections(db, readingID: bookID)
                #expect(chapters.count == 13,
                        "a resumed seed must not mint a second chapter of the same name")
                #expect(chapters.filter { $0.name == scandalTitle }.count == 1)

                // …and the note landed IN the chapter that was already there.
                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.count == 13)
                let entry = try #require(entries.first { $0.title == scandalTitle })
                #expect(entry.sectionID == half.chapter,
                        "the note must land in the chapter that was already standing")
                #expect(Set(entries.compactMap(\.sectionPath)).count == 13)
            }
        }
    }

    /// The ladder's F13: this pins the LAUNCH seed only — the device mark
    /// short-circuits it after a deletion. The restore door (Help ▸ Restore
    /// the Sample Library, wave 1) is the one road back and is pinned by
    /// `theRestoreDoorReMembersSurvivingStoriesInsteadOfMintingTwins` below.
    @Test("The launch seed never re-mints a deleted library — the restore door is the only road back")
    func theLaunchSeedNeverReMintsADeletedLibrary() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let tagged = try await db.read { db -> [String] in
                guard let tag = try Queries.allTags(db)
                    .first(where: { $0.path == SampleLibrarySeeder.tagName })
                else { return [] }
                return try Queries.everythingTagged(db, tagID: tag.id).postIDs
            }
            try await session.runner.run { ops in
                for postID in tagged { try ops.deleteContainer(postID) }
                try ops.deleteReading(bookID)
            }
            let again = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(again == .alreadySeeded)
            let books = try await db.read { db in
                try Queries.readings(db).filter { $0.name == SampleLibrarySeeder.bookName }
            }
            #expect(books.isEmpty)
        }
    }

    /// **RED ON OLD (the ladder's F10, MINOR):** deleting the BOOK tombstones
    /// its memberships and never its notes, so the thirteen stories survive
    /// alive and bookless — and the restore door, deriving presence from
    /// membership alone, minted thirteen fresh twins beside them (26 Sherlock
    /// notes, the tag on both sets). Discovery now finds the survivors by the
    /// reserved tag and RE-MEMBERS them; only an absent title mints.
    @Test("Restore after deleting the BOOK re-members the surviving stories instead of minting twins")
    func theRestoreDoorReMembersSurvivingStoriesInsteadOfMintingTwins() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let originalNoteIDs = try await db.read { db -> Set<String> in
                Set(try Queries.assembleReading(db, readingID: bookID).map(\.postID))
            }
            #expect(originalNoteIDs.count == 13)
            try await session.runner.run { ops in try ops.deleteReading(bookID) }

            // The door's own two steps (`ShellActions.restoreSampleLibrary`).
            let stories = try SampleLibrarySeeder.loadStories()
            let existing = try await db.read { db in try SampleLibrarySeeder.discover(db) }
            #expect(existing.bookID == nil, "the book is gone")
            #expect(existing.presentTitles.isEmpty)
            #expect(existing.strayNoteIDsByTitle.count == 13,
                    "…but all thirteen notes survive, found by the reserved tag")
            let restored = try await SampleLibrarySeeder.seed(
                session: session, stories: stories, existing: existing)
            let newBookID = restored.readingID
            let cameBack = restored.minted
            #expect(cameBack == 12, "every story came back — by membership, not by mint")

            let facts = try await db.read { db -> (notes: Int, members: Set<String>, chapters: Int) in
                let liveNotes = try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? 0
                let members = Set(try Queries.assembleReading(db, readingID: newBookID).map(\.postID))
                let chapters = try Queries.readingSections(db, readingID: newBookID).count
                return (liveNotes, members, chapters)
            }
            #expect(facts.notes == 13, "exactly thirteen Sherlock notes in the store (old: 26)")
            #expect(facts.members == originalNoteIDs, "the SAME notes are the book's members again")
            #expect(facts.chapters == 13, "one chapter per note, rebuilt")
        }
    }

    @Test("A store that belongs to an account waits for its first clean round")
    func theSyncGateDeclinesUntilTheFirstRound() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let declined = await SampleLibrarySeeder.seedIfNeeded(
                session: session,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true }, hasSyncedCleanly: { false }),
                firstRoundWait: .milliseconds(30),
                pollInterval: .milliseconds(5),
                loadMark: mark.load, saveMark: mark.save)
            #expect(declined == .awaitingFirstSync)
            #expect(!mark.value)  // never marked — the next launch asks again
            let empty = try await db.read { db in try Queries.readings(db) }
            #expect(empty.isEmpty)

            // Once the round has landed, the same call seeds.
            let seeded = await SampleLibrarySeeder.seedIfNeeded(
                session: session,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true }, hasSyncedCleanly: { true }),
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = seeded else {
                Issue.record("expected a seed once the round landed, got \(seeded)")
                return
            }
        }
    }

    // MARK: - The sync dedupe's contract (pre-13u ladder round 2, R2-5)

    /// **THE SEED-SHAPE DRIFT GUARD.** The sync engine's sample-library
    /// dedupe (`SampleLibraryDedupe.swift`, core) classifies a seeded copy
    /// PRISTINE from a fixed list of legs — and it reads the seeder's shape
    /// through injected facts it cannot otherwise see. This pin walks every
    /// leg the classifier reads over the REAL shipped seed, so a change to
    /// either side announces itself here rather than as "both Sherlock
    /// copies survive forever, silently" on a reader's second device. It
    /// deliberately mirrors the classifier's queries one for one; keep the
    /// two in step. (Chapter NAMES are not a leg: the front chapter is not
    /// named after its note, and the facts carry note titles only.)
    @Test("The shipped seed satisfies the sync dedupe's PRISTINE contract — every leg the classifier reads")
    func theShippedSeedSatisfiesTheDedupesPristineContract() async throws {
        try await expectPristineContract(book: .sherlock)
    }

    /// pre-13x 5a: the SECOND seeded book (*Encryption Explained*) satisfies
    /// the same contract — its facts are the list's second entry.
    @Test("Encryption Explained's seed satisfies the sync dedupe's PRISTINE contract too")
    func theEncryptionBookSeedSatisfiesTheDedupesPristineContract() async throws {
        try await expectPristineContract(book: .encryptionExplained)
    }

    private func expectPristineContract(book: SampleLibrarySeeder.Book) async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let facts = SampleLibrarySeeder.dedupeFacts(for: book)
            let manifest = try facts.loadNoteHashes()

            try await db.read { db in
                // The book: the schema's default sort, no finish, no extent,
                // no grouping.
                let book = try #require(try Row.fetchOne(
                    db,
                    sql: """
                        SELECT locked, word_target, max_posts, grouping_tag_id, sort_field, sort_dir
                        FROM reading WHERE id = ? AND deleted_at IS NULL
                        """,
                    arguments: [bookID]))
                #expect(book["locked"] as Int == 0)
                #expect(book["word_target"] as Int? == nil)
                #expect(book["max_posts"] as Int? == nil)
                #expect(book["grouping_tag_id"] as String? == nil)
                #expect(book["sort_field"] as String == SortField.manual.rawValue)
                #expect(book["sort_dir"] as String == SortDirection.asc.rawValue)

                // Chapters ↔ memberships: one chapter per note, minted in
                // note order, each membership assigned to its own chapter —
                // memberships in book order name the live chapters in
                // chapter order.
                let assigned = try Row.fetchAll(
                    db,
                    sql: """
                        SELECT section_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [bookID]).map { $0["section_id"] as String? }
                let chapters = try String.fetchAll(
                    db,
                    sql: """
                        SELECT id FROM reading_section
                        WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [bookID])
                #expect(assigned.allSatisfy { $0 != nil }, "every note is assigned to a chapter")
                #expect(assigned.compactMap { $0 } == chapters, "memberships in book order name the chapters in chapter order")
                #expect(chapters.count == manifest.count)

                let reservedTagID = try String.fetchOne(
                    db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
                    arguments: [facts.tagPath])
                #expect(reservedTagID != nil)

                // Every note: a manifest title, untouched metadata, the
                // reserved tag landed, no engagement, one plain unlocked
                // unnamed unframed take per block, the shipped hash.
                let posts = try String.fetchAll(
                    db,
                    sql: "SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [bookID])
                var titles = Set<String>()
                for postID in posts {
                    let post = try #require(try Row.fetchOne(
                        db,
                        sql: """
                            SELECT title, locked, archived_at, entry_date, floating_notes
                            FROM container WHERE id = ? AND deleted_at IS NULL
                            """,
                        arguments: [postID]))
                    let title: String = try #require(post["title"] as String?)
                    #expect(manifest[title] != nil, "\(title) is a manifest title")
                    #expect(titles.insert(title).inserted, "\(title) appears once")
                    #expect(post["locked"] as Int == 0)
                    #expect(post["archived_at"] as String? == nil)
                    #expect(post["entry_date"] as String? == nil)
                    #expect((post["floating_notes"] as String? ?? "").isEmpty)
                    #expect(try Bool.fetchOne(
                        db,
                        sql: """
                            SELECT EXISTS (SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                                           WHERE pt.post_id = ? AND t.path = ? AND pt.deleted_at IS NULL)
                            """,
                        arguments: [postID, facts.tagPath]) == true,
                        "\(title) carries the reserved tag — the classifier's completeness guard")
                    #expect(try Bool.fetchOne(
                        db,
                        sql: """
                            SELECT EXISTS (SELECT 1 FROM reading_post
                                           WHERE post_id = ?1 AND reading_id <> ?2 AND deleted_at IS NULL)
                                OR EXISTS (SELECT 1 FROM post_tag
                                           WHERE post_id = ?1 AND deleted_at IS NULL AND tag_id <> ?3)
                                OR EXISTS (SELECT 1 FROM block_tag bt
                                           JOIN container_block cb ON cb.block_id = bt.block_id
                                           WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                             AND bt.deleted_at IS NULL)
                                OR EXISTS (SELECT 1 FROM block_comment bc
                                           JOIN container_block cb ON cb.block_id = bc.block_id
                                           WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                             AND bc.deleted_at IS NULL)
                                OR EXISTS (SELECT 1 FROM commit_point cp
                                           JOIN variant v ON v.id = cp.variant_id
                                           JOIN container_block cb ON cb.block_id = v.block_id
                                           WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                             AND cp.kind = 'manual')
                                OR EXISTS (SELECT 1 FROM reference
                                           WHERE container_id = ?1 AND deleted_at IS NULL)
                            """,
                        arguments: [postID, bookID, reservedTagID ?? ""]) == false,
                        "\(title) shows no engagement")
                    let blocks = try String.fetchAll(
                        db,
                        sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                        arguments: [postID])
                    #expect(!blocks.isEmpty)
                    for blockID in blocks {
                        let block = try #require(try Row.fetchOne(
                            db, sql: "SELECT name, presentation FROM block WHERE id = ?",
                            arguments: [blockID]))
                        #expect((block["name"] as String? ?? "").isEmpty)
                        #expect(block["presentation"] as String? == nil)
                        let shape = try #require(try Row.fetchOne(
                            db,
                            sql: """
                                SELECT COUNT(*) AS total,
                                  COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'active'
                                                    THEN 1 ELSE 0 END), 0) AS active,
                                  COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'archived'
                                                    THEN 1 ELSE 0 END), 0) AS archived,
                                  COALESCE(SUM(CASE WHEN locked = 1 THEN 1 ELSE 0 END), 0) AS locked
                                FROM variant WHERE block_id = ?
                                """,
                            arguments: [blockID]))
                        #expect(shape["active"] as Int == 1)
                        #expect(shape["archived"] as Int == 0)
                        #expect(shape["locked"] as Int == 0)
                    }
                    #expect(manifest[title] == facts.hash(try Queries.renderedText(db, containerID: postID)),
                            "\(title) hashes to the shipped manifest")
                }
                #expect(titles.count == manifest.count)
            }
        }
    }
}


// MARK: - pre-13x 5a: the SECOND seeded book — Encryption Explained (copy §7b)

/// *Encryption Explained* rides the seeder generalized to a per-book
/// description (the postures design §1.22 / §8): one note per chapter in
/// Chapter 1 → 8 order, the front-matter note the register rule's
/// definitions, its own reserved name and tag, its OWN defaults mark (so an
/// existing store whose Sherlock mark is set still seeds this book), the
/// same resumable seed, the same manifest recipe — and Sherlock's every
/// value unchanged (every pin above rides unmodified).
@MainActor
@Suite("The second seeded book — Encryption Explained (pre-13x 5a)")
struct EncryptionExplainedSeedTests {
    @Test("The bundled text is the eight chapters of copy §7b, headed by their chapter titles")
    func bundledTextIsTheEightChapters() throws {
        let chapters = try SampleLibrarySeeder.loadStories(for: .encryptionExplained)
        #expect(chapters.count == 8)
        #expect(chapters.first?.title == "Chapter 1 — What is encrypted, and with what")
        #expect(chapters.last?.title == "Chapter 8 — What we can and cannot do for you")
        #expect(chapters[0].text.hasPrefix("Your library is one file."))
        // Every chapter paragraph-segments into more than one block.
        for chapter in chapters {
            #expect(SegmentationRules.bulkSegments(chapter.text, mode: .paragraph).count >= 2, Comment(rawValue: chapter.title))
        }
    }

    @Test("The seed mints the book: eight chapter notes plus the front matter, one chapter each, tagged")
    func seedMintsTheBook() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .encryptionExplained, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, let chapters) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(chapters == 8)
            #expect(mark.value)
            try await db.read { db in
                let book = try #require(try Queries.reading(db, id: bookID))
                #expect(book.name == SampleLibraryEncryptionBook.name && book.kind == .curated)
                let sections = try Queries.readingSections(db, readingID: bookID)
                #expect(sections.count == 9)
                #expect(sections.first?.name == SampleLibraryEncryptionBook.frontMatterChapter)
                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.count == 9)
                #expect(entries.first?.title == SampleLibraryEncryptionBook.frontMatterTitle)
                #expect(entries[1].title == "Chapter 1 — What is encrypted, and with what")
                #expect(Set(entries.compactMap(\.sectionPath)).count == 9)
                let tag = try #require(try Queries.allTags(db).first { $0.path == SampleLibraryEncryptionBook.tagName })
                #expect(try Queries.everythingTagged(db, tagID: tag.id).postIDs.count == 9)
                // The Pool stays blank: every note is a member.
                #expect(try Queries.poolPosts(db, limit: 100).isEmpty)
                // The book is not an 1892 text: stamped on the ambient clock.
                #expect(book.createdAt != SampleLibrarySeeder.publicationDate)
            }
        }
    }

    /// The load-bearing pin (the phone's `theManifestMatchesWhatTheSeedActuallyStores`,
    /// for the second book): the manifest hashes the bundled source; the
    /// dedupe hashes what the STORE holds; they must agree note by note.
    @Test("The manifest matches what the seed actually stores, note by note")
    func theManifestMatchesWhatTheSeedStores() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .encryptionExplained, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let manifest = try SampleLibrarySeeder.manifest(for: .encryptionExplained)
            #expect(manifest.bookName == SampleLibraryEncryptionBook.name)
            #expect(manifest.tagName == SampleLibraryEncryptionBook.tagName)
            #expect(manifest.titles.count == 9)
            let verdicts = try await db.read { db -> [(String, Bool)] in
                try Queries.assembleReading(db, readingID: bookID).map { entry in
                    let title = entry.title ?? ""
                    let text = try Queries.renderedText(db, containerID: entry.postID)
                    return (title, manifest.isPristine(title: title, renderedText: text))
                }
            }
            #expect(verdicts.count == 9)
            for (title, pristine) in verdicts {
                #expect(pristine, "a freshly seeded \"\(title)\" must read as pristine")
            }
        }
    }

    @Test("Its own mark: a store whose Sherlock mark is set still seeds this book, and only it")
    func theMarksAreIndependent() async throws {
        try await withSampleWorld { session, db in
            let variant = AppDatabase.StoreVariant.real.rawValue
            #expect(SampleLibrarySeeder.seededDefaultsKey(for: .real) == "SampleLibrarySeeded.\(variant)",
                    "Sherlock's key is UNCHANGED — an existing store's mark still stands")
            #expect(SampleLibrarySeeder.seededDefaultsKey(for: .real, book: .encryptionExplained)
                    == "SampleLibrarySeeded.\(variant).encryption-explained")
            // An existing store: Sherlock marked (seeded in an earlier build).
            let sherlockMark = Mark()
            sherlockMark.value = true
            let encryptionMark = Mark()
            for book in SampleLibrarySeeder.Book.all {
                let mark = book == .sherlock ? sherlockMark : encryptionMark
                _ = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            }
            try await db.read { db in
                let names = try Queries.readings(db).map(\.name)
                #expect(!names.contains(SampleLibrarySeeder.bookName), "Sherlock's mark short-circuits")
                #expect(names.contains(SampleLibraryEncryptionBook.name), "the new book seeds at the next occasion")
            }
            #expect(encryptionMark.value)
        }
    }

    @Test("Help ▸ Restore for this book re-members the surviving chapters instead of minting twins")
    func theRestoreRoadReMembersSurvivingChapters() async throws {
        try await withSampleWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .encryptionExplained, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let original = try await db.read { db in
                Set(try Queries.assembleReading(db, readingID: bookID).map(\.postID))
            }
            try await session.runner.run { ops in try ops.deleteReading(bookID) }
            let chapters = try SampleLibrarySeeder.loadStories(for: .encryptionExplained)
            let existing = try await db.read { db in try SampleLibrarySeeder.discover(db, book: .encryptionExplained) }
            #expect(existing.bookID == nil && existing.strayNoteIDsByTitle.count == 9)
            let restored = try await SampleLibrarySeeder.seed(
                session: session, book: .encryptionExplained, stories: chapters, existing: existing)
            let newBookID = restored.readingID
            let cameBack = restored.minted
            #expect(cameBack == 8)
            let members = try await db.read { db in
                Set(try Queries.assembleReading(db, readingID: newBookID).map(\.postID))
            }
            #expect(members == original, "the SAME notes are the book's members again")
        }
    }
}
