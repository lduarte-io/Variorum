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
}
