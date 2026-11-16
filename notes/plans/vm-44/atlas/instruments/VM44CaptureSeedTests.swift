//
//  VM44CaptureSeedTests.swift — THROWAWAY (VM-44 capture atlas). NEVER COMMITTED.
//
//  Lives in notes/plans/vm-44/atlas/instruments/; copied into the
//  throwaway worktree ~/dev/variorum-vm44-capture/App/Variorum/VariorumMobileTests/
//  only so it compiles into the hosted test bundle. Run ONCE, under a held stage
//  claim, against the dedicated "MobileCatchup Capture" simulator:
//
//      xcodebuild test-without-building … -only-testing:VariorumMobileTests/VM44CaptureSeedTests
//
//  PRECONDITION: the app has been launched once normally on this simulator (the
//  library exists — a hosted test's protection road is read-only and never
//  creates) and the first write has landed (the starter Journal + the Prince).
//
//  What it does: opens the simulator's DEV library through the production road
//  (`AppBootstrap(variant: .dev, launch: .app)` — a quiet, read-only open), then
//  seeds a realistic multi-wing library through ordinary Operations on a quiet
//  facade (undoStack nil), with a moving clock so stamps spread over ~4 months.
//  Refuses to seed twice (the "Work" wing is the marker).
//

import Dependencies
import Foundation
import GRDB
import XCTest
import VariorumCore
@testable import VariorumMobile

/// A settable clock for the seed (Operations read `\.date` once per op).
private nonisolated final class SeedClock: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Date
    init(_ start: Date) { value = start }
    var now: Date {
        lock.lock(); defer { lock.unlock() }
        return value
    }
    func set(_ date: Date) {
        lock.lock(); value = date; lock.unlock()
    }
}

final class VM44CaptureSeedTests: XCTestCase {

    static let summaryPath =
        "notes/plans/vm-44/atlas/instruments/seed-summary.txt"

    @MainActor
    func testSeedCaptureLibrary() async throws {
        let bootstrap = AppBootstrap(variant: .dev, launch: .app)
        await bootstrap.awaitOpen()
        guard case .ready(let session) = bootstrap.state else {
            XCTFail("VM44-SEED: the dev library did not open on the road — state: \(String(describing: bootstrap.state))")
            return
        }
        let db = session.database
        let already = try await db.read { db in
            try Queries.wings(db).contains { $0.name == "Work" }
        }
        if already {
            XCTFail("VM44-SEED: already seeded (a wing named Work exists) — refusing to seed twice")
            return
        }

        let stories = try SampleLibrarySeeder.loadStories(for: .sherlock)
        let filler = Filler(stories: stories)
        let clock = SeedClock(Date())

        try withDependencies {
            $0.database = db
            $0.date = DateGenerator { clock.now }
            $0.uuid = UUIDGenerator { UUID() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            let ops = Operations(undoStack: nil)
            var seed = CaptureSeed(ops: ops, db: db, clock: clock, filler: filler)
            try seed.run()
        }

        let summary = try await db.read { db -> String in
            func count(_ sql: String) throws -> Int { try Int.fetchOne(db, sql: sql) ?? -1 }
            let lines = [
                "VM44-SEED summary (written \(Date()))",
                "wings: \(try count("SELECT COUNT(*) FROM wing WHERE deleted_at IS NULL")) (+ virtual Home)",
                "shelves: \(try count("SELECT COUNT(*) FROM shelf WHERE deleted_at IS NULL"))",
                "books live: \(try count("SELECT COUNT(*) FROM reading WHERE kind='book' AND deleted_at IS NULL"))",
                "gatherings live: \(try count("SELECT COUNT(*) FROM reading WHERE kind='gathering' AND deleted_at IS NULL"))",
                "books archived: \(try count("SELECT COUNT(*) FROM reading WHERE archived_at IS NOT NULL AND deleted_at IS NULL"))",
                "books in trash: \(try count("SELECT COUNT(*) FROM reading WHERE deleted_at IS NOT NULL"))",
                "notes live: \(try count("SELECT COUNT(*) FROM container WHERE kind='post' AND deleted_at IS NULL"))",
                "notes archived: \(try count("SELECT COUNT(*) FROM container WHERE kind='post' AND archived_at IS NOT NULL AND deleted_at IS NULL"))",
                "notes in trash: \(try count("SELECT COUNT(*) FROM container WHERE kind='post' AND deleted_at IS NOT NULL"))",
                "arrivals waiting: \(try count("SELECT COUNT(*) FROM reading_post WHERE status='arrival' AND deleted_at IS NULL"))",
                "fanned blocks: \(try count("SELECT COUNT(*) FROM (SELECT block_id FROM variant WHERE deleted_at IS NULL AND status='active' GROUP BY block_id HAVING COUNT(*) > 1)"))",
                "comments live: \(try count("SELECT COUNT(*) FROM block_comment WHERE deleted_at IS NULL"))",
                "callouts: \(try count("SELECT COUNT(*) FROM block WHERE presentation IS NOT NULL AND deleted_at IS NULL"))",
                "commits: \(try count("SELECT COUNT(*) FROM commit_point"))",
                "tags: \(try count("SELECT COUNT(*) FROM tag WHERE deleted_at IS NULL"))",
                "longest note words (approx): \(try count("SELECT MAX(w) FROM (SELECT cb.container_id, SUM(LENGTH(v.working_text) - LENGTH(REPLACE(v.working_text, ' ', '')) + 1) AS w FROM container_block cb JOIN variant v ON v.id = cb.chosen_variant_id WHERE cb.deleted_at IS NULL GROUP BY cb.container_id)"))",
            ]
            return lines.joined(separator: "\n")
        }
        print(summary)
        try? summary.write(toFile: Self.summaryPath, atomically: true, encoding: .utf8)
    }
}

// MARK: - Prose filler (public-domain Sherlock paragraphs, bundled with the app)

@MainActor
private struct Filler {
    let paragraphs: [String]
    let stories: [SampleLibrarySeeder.Story]
    private var cursor = 0

    init(stories: [SampleLibrarySeeder.Story]) {
        self.stories = stories
        paragraphs = stories.flatMap { story in
            story.text.components(separatedBy: "\n\n")
                .map { $0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 80 && !$0.hasPrefix("I.") && !$0.hasPrefix("II.") }
        }
    }

    mutating func next() -> String {
        defer { cursor = (cursor + 7) % max(1, paragraphs.count) }
        return paragraphs[cursor % max(1, paragraphs.count)]
    }
}

// MARK: - The seed

@MainActor
private struct CaptureSeed {
    let ops: Operations
    let db: AppDatabase
    let clock: SeedClock
    var filler: Filler

    init(ops: Operations, db: AppDatabase, clock: SeedClock, filler: Filler) {
        self.ops = ops
        self.db = db
        self.clock = clock
        self.filler = filler
    }

    // Time: "today" is the run's day; everything else is days before it.
    private let today = Date()
    private func at(daysAgo: Double, hour: Double = 10) -> Date {
        let cal = Calendar.current
        let start = cal.startOfDay(for: today)
        return start.addingTimeInterval(-daysAgo * 86_400 + hour * 3_600)
    }
    private func dayKey(daysAgo: Int) -> String {
        let cal = Calendar.current
        let d = cal.date(byAdding: .day, value: -daysAgo, to: cal.startOfDay(for: today)) ?? today
        let c = cal.dateComponents([.year, .month, .day], from: d)
        return String(format: "%04d-%02d-%02d", c.year ?? 2026, c.month ?? 1, c.day ?? 1)
    }

    /// Mint one note's body: the opening line, then `extra` filler paragraphs.
    @discardableResult
    private mutating func body(_ postID: String, opening: String, extra: Int) throws -> [Operations.NewBlockResult] {
        var minted: [Operations.NewBlockResult] = []
        minted.append(try ops.newBlock(in: postID, text: opening, at: .end, registeringUndo: false))
        for _ in 0..<extra {
            minted.append(try ops.newBlock(in: postID, text: filler.next(), at: .end, registeringUndo: false))
        }
        return minted
    }

    /// A fan on `block`: extra takes with labels; returns the take ids.
    @discardableResult
    private func fan(_ block: Operations.NewBlockResult, takes: [(label: String?, text: String)],
                     labelOriginal: String? = nil) throws -> [String] {
        if let labelOriginal { try ops.setTakeLabel(block.variant.id, label: labelOriginal) }
        var ids: [String] = []
        for take in takes {
            let v = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(v.id, text: take.text, charDelta: take.text.count)
            if let label = take.label { try ops.setTakeLabel(v.id, label: label) }
            ids.append(v.id)
        }
        return ids
    }

    mutating func run() throws {
        // ── Wings, tags, shelves ────────────────────────────────────────
        clock.set(at(daysAgo: 130))
        let work = try ops.createWing(name: "Work")
        let fiction = try ops.createWing(name: "Fiction")

        func tag(_ name: String, parent: String? = nil, wing: String = "") throws -> Tag {
            try ops.createTag(parent: parent, name: name, wingID: wing)
        }
        let tEssay = try tag("essay"), tIdea = try tag("idea"), tQuote = try tag("quote")
        let tReading = try tag("reading"), tRecipe = try tag("recipe"), tTravel = try tag("travel")
        let tBlog = try tag("blog"), tDraft = try tag("draft"), tPeople = try tag("people")
        let tLife = try tag("life")
        let tGoals = try tag("goals", parent: tLife.id)
        let tHealth = try tag("health", parent: tLife.id)
        let wMeeting = try tag("meeting", wing: work.id), wSpec = try tag("spec", wing: work.id)
        let wIdea = try tag("idea", wing: work.id), wQ4 = try tag("q4", wing: work.id)
        let fCharacter = try tag("character", wing: fiction.id), fSetting = try tag("setting", wing: fiction.id)
        let fDraft = try tag("draft", wing: fiction.id)

        let sWriting = try ops.createShelf(name: "Writing")
        try ops.setShelfGlyph(sWriting.id, glyph: "✎")
        let sReading = try ops.createShelf(name: "Reading & reference")
        let sLife = try ops.createShelf(name: "Life")
        try ops.setShelfGlyph(sLife.id, glyph: "☼")
        let sProjects = try ops.createShelf(name: "Projects", wingID: work.id)

        // ── Living book with arrivals FIRST (intake hears later tag acts) ──
        clock.set(at(daysAgo: 120))
        let ideasInbox = try ops.createReading(
            name: "Ideas inbox", kind: .book, querySpec: try RuleGrammar.encode(.tag(tIdea.id)),
            intakeSeating: .arrivals, shelfId: sWriting.id)
        let quotes = try ops.createReading(
            name: "Quotes", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tQuote.id)))

        // ── Home: Essays (starred, shelf Writing) ────────────────────────
        let essays = try ops.createReading(name: "Essays", kind: .book, shelfId: sWriting.id)
        try ops.setStarred(.reading(essays.id), starred: true)
        let essayTitles: [(String, String)] = [
            ("On keeping a commonplace book", "I started copying sentences into a notebook the winter I stopped trusting my memory for them."),
            ("The case for slow mornings", "Nothing good I have written began after nine o'clock, and I have stopped pretending otherwise."),
            ("Why I write in pencil first", "Pencil forgives. Ink argues back, and a keyboard has opinions about everything."),
            ("Against the tidy desk", "A clean desk is a desk that has given up on surprising you."),
            ("What the river taught me about revision", "Every spring the river moves its bank a little and nobody calls it a mistake."),
            ("Letters I never sent", "There is a drawer of them, and the drawer is the point."),
            ("Walking as a writing tool", "The paragraph I could not finish at the desk finished itself somewhere past the bakery."),
            ("Notes on attention", "Attention is the only thing I own that grows when I spend it."),
        ]
        var essayPosts: [Container] = []
        for (i, entry) in essayTitles.enumerated() {
            clock.set(at(daysAgo: Double(110 - i * 12), hour: 9 + Double(i % 5)))
            let post = try ops.newPostInReading(essays.id, title: entry.0, profile: .generic)
            let blocks = try body(post.id, opening: entry.1, extra: 2 + i % 3)
            _ = try ops.applyTag(tEssay.id, toPost: post.id)
            if i == 0 {
                // The showcase fan: three takes on the opening, labels, a commit, a comment, a callout.
                try fan(blocks[0], takes: [
                    ("shorter", "I copy sentences into a notebook because my memory stopped keeping them."),
                    ("warmer", "That winter I began copying other people's sentences into a little notebook, and it felt like keeping company."),
                ], labelOriginal: "original")
                _ = try ops.commit(blocks[0].variant.id, kind: .manual, message: "first pass")
                _ = try ops.addBlockComment(to: blocks[0].block.id, text: "Lead with the winter? Or with the notebook itself?")
                _ = try ops.addBlockComment(to: blocks[1].block.id, text: "Find the Montaigne quote for this paragraph.")
                try ops.setBlockPresentation(blocks[2].block.id, BlockPresentation(color: "blue", emoji: "💡"))
                try ops.setStarred(.post(post.id), starred: true)
                _ = try ops.applyTag(tGoals.id, toPost: post.id)
            }
            if i == 2 {
                _ = try ops.commit(blocks[0].variant.id, kind: .manual, message: "before the rewrite")
                clock.set(at(daysAgo: Double(110 - i * 12) - 1))
                _ = try ops.saveNoteVersion(post.id)
                try ops.autosave(blocks[0].variant.id,
                                 text: "Pencil forgives. Ink argues back. A keyboard has opinions about everything, mostly wrong.",
                                 charDelta: 12)
            }
            if i == 4 {
                let ids = try fan(blocks[1], takes: [("alt ending", filler.next()), (nil, filler.next())])
                try ops.archiveVariant(ids[1])
                try ops.lockVariant(ids[0])
            }
            essayPosts.append(post)
        }
        // A pinned membership in Essays.
        try ops.setMembershipPinned(essayPosts[3].id, in: essays.id, pinned: true)

        // ── Home: Blog drafts (chapters) ─────────────────────────────────
        clock.set(at(daysAgo: 100))
        let blog = try ops.createReading(name: "Blog drafts", kind: .book, shelfId: sWriting.id)
        let chPublished = try ops.createSection(in: blog.id, name: "Published")
        let chProgress = try ops.createSection(in: blog.id, name: "In progress")
        let chSomeday = try ops.createSection(in: blog.id, name: "Someday")
        let blogTitles: [(String, String, String)] = [
            ("Five apps I deleted this year", "None of them were bad. All of them wanted me back.", chPublished.id),
            ("A year of daily notes", "Three hundred and forty entries, eleven of them worth rereading.", chPublished.id),
            ("How I organise research", "Folders failed me, tags failed me, and then I stopped organising and started writing.", chProgress.id),
            ("The tyranny of the blank page", "The blank page is not empty. It is full of everything you have not decided yet.", chProgress.id),
            ("Draft: on phones and attention", "I want a phone that is boring in the best way.", chProgress.id),
            ("Ideas for a newsletter", "Monthly, short, one good link and one honest paragraph.", chSomeday.id),
            ("Why I still print things", "Paper shows me the shape of a piece before I have read a word of it.", chSomeday.id),
        ]
        for (i, entry) in blogTitles.enumerated() {
            clock.set(at(daysAgo: Double(95 - i * 9), hour: 20))
            let post = try ops.newPostInReading(blog.id, section: entry.2, title: entry.0, profile: .blog)
            let blocks = try body(post.id, opening: entry.1, extra: 1 + i % 3)
            _ = try ops.applyTag(tBlog.id, toPost: post.id)
            if i >= 2 && i <= 4 { _ = try ops.applyTag(tDraft.id, toPost: post.id) }
            if i == 4 {
                try fan(blocks[0], takes: [
                    ("punchier", "I want a boring phone."),
                    (nil, "What I want from a phone is the dullness of a good hammer."),
                ])
            }
        }

        // ── Home: Reading notes (sorted last touched, desc) ──────────────
        clock.set(at(daysAgo: 90))
        let readingBook = try ops.createReading(
            name: "Reading notes", kind: .book, sortField: .lastTouched, sortDir: .desc, shelfId: sReading.id)
        let readingTitles = [
            ("Middlemarch — notes", "Eliot's narrator keeps stepping in front of the camera, and I have stopped minding."),
            ("The Rings of Saturn", "Sebald walks and the walking becomes the argument."),
            ("Bird by Bird", "Short assignments. Shitty first drafts. I keep coming back to the second one."),
            ("Pilgrim at Tinker Creek", "She sees the world as if she has been told it will be taken away tomorrow."),
            ("The Sense of Style", "Classic style: the writer shows the reader something they could see for themselves."),
            ("Essays of Montaigne, book I", "He changes his mind mid-sentence and calls it honesty. It is."),
        ]
        for (i, entry) in readingTitles.enumerated() {
            clock.set(at(daysAgo: Double(88 - i * 13), hour: 22))
            let post = try ops.newPostInReading(readingBook.id, title: entry.0, profile: .generic)
            let blocks = try body(post.id, opening: entry.1, extra: 2)
            _ = try ops.applyTag(tReading.id, toPost: post.id)
            if i == 1 {
                try ops.setBlockPresentation(blocks[1].block.id, BlockPresentation(color: "sand", emoji: nil))
            }
        }

        // ── Home: Recipes ────────────────────────────────────────────────
        clock.set(at(daysAgo: 85))
        let recipes = try ops.createReading(name: "Recipes", kind: .book, shelfId: sLife.id)
        let recipeTitles = [
            ("Saturday bread", "500 g flour, 350 g water, 10 g salt, a little starter, and most of a day."),
            ("Lentil soup for cold weeks", "Onion, carrot, celery, red lentils, a lemon at the end. Always the lemon."),
            ("Grandmother's plum cake", "She never measured, so these are guesses that taste right."),
            ("Weeknight noodles", "Ten minutes if the water is already boiling, which it never is."),
            ("Pickled red onions", "One onion, one cup vinegar, a spoon of sugar, a pinch of salt."),
        ]
        for (i, entry) in recipeTitles.enumerated() {
            clock.set(at(daysAgo: Double(80 - i * 11), hour: 18))
            let post = try ops.newPostInReading(recipes.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 1)
            _ = try ops.applyTag(tRecipe.id, toPost: post.id)
        }

        // ── Home: Lisbon trip (journal trait, dated) ─────────────────────
        clock.set(at(daysAgo: 70))
        let lisbon = try ops.createReading(
            name: "Lisbon trip", kind: .book, profile: Queries.journalTraitProfile,
            sortField: .entryDate, sortDir: .asc, shelfId: sLife.id)
        let lisbonDays = [
            (66, "Arrival", "The light here is yellow in the afternoon, like an old photograph of itself."),
            (65, "Alfama", "Lost on purpose for three hours. Found a bakery that was worth being lost for."),
            (64, "Sintra", "Too many stairs, too many tourists, and still worth it."),
            (63, "Last day", "Sat by the river and wrote nothing, which was the plan."),
        ]
        for entry in lisbonDays {
            clock.set(at(daysAgo: Double(entry.0), hour: 21))
            let post = try ops.newPostInReading(
                lisbon.id, title: entry.1, profile: .journal, entryDate: dayKey(daysAgo: entry.0))
            try body(post.id, opening: entry.2, extra: 1)
            _ = try ops.applyTag(tTravel.id, toPost: post.id)
        }

        // ── Home: Letters (finished) and Old projects (archived) and Scratch (deleted) ──
        clock.set(at(daysAgo: 60))
        let letters = try ops.createReading(name: "Letters", kind: .book, shelfId: sWriting.id)
        for (i, entry) in [("To M., about the move", "I keep starting this letter and then going to look at the boxes."),
                            ("To my younger self", "You will be fine, and you will not believe me, which is also fine."),
                            ("To the neighbour with the piano", "Thank you for Chopin on Sunday mornings.")].enumerated() {
            clock.set(at(daysAgo: Double(58 - i * 4)))
            let post = try ops.newPostInReading(letters.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 1)
            _ = try ops.applyTag(tPeople.id, toPost: post.id)
        }
        clock.set(at(daysAgo: 40))
        try ops.lockReading(letters.id)

        clock.set(at(daysAgo: 125))
        let oldProjects = try ops.createReading(name: "Old projects", kind: .book)
        for (i, entry) in [("The podcast that never was", "Twelve episode outlines and zero episodes."),
                            ("Garden plan 2025", "Tomatoes along the south fence. This time for real."),
                            ("Novel attempt #2", "A detective who solves nothing and is happy about it.")].enumerated() {
            clock.set(at(daysAgo: Double(124 - i * 3)))
            let post = try ops.newPostInReading(oldProjects.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 1)
        }
        clock.set(at(daysAgo: 30))
        try ops.archiveReading(oldProjects.id)

        clock.set(at(daysAgo: 20))
        let scratch = try ops.createReading(name: "Scratch", kind: .book)
        for entry in [("scratch — headlines", "Ten headlines, all bad, one salvageable."),
                      ("scratch — list", "Milk, stamps, call the dentist, finish the essay.")] {
            let post = try ops.newPostInReading(scratch.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
        }
        clock.set(at(daysAgo: 6))
        _ = try ops.deleteReading(scratch.id)

        // ── Home: the daily Journal (the furniture's, or one the op creates) ──
        let journalLines = [
            (24, "Slept badly. Wrote anyway. The anyway is the whole trick."),
            (21, "Rain all day. Finished the commonplace book essay's second section."),
            (19, "Coffee with R. — she said the essay is too polite. She is right."),
            (17, "Long walk by the river. Two good sentences, both about herons."),
            (15, "Tired. Read instead of writing. Middlemarch, chapter 20."),
            (12, "Started the lighthouse story again, from the keeper's side this time."),
            (10, "A slow morning, on purpose. It worked."),
            (8, "Too many meetings. Wrote one paragraph on the train home."),
            (6, "Cleaned the desk, then regretted it."),
            (4, "Good day. The second chapter finally has a door into it."),
            (2, "Short entry. Grateful for the neighbour's piano."),
            (1, "Planning the week: essay edits, two letters, groceries."),
        ]
        for entry in journalLines {
            clock.set(at(daysAgo: Double(entry.0), hour: 7.5))
            let result = try ops.newJournalEntry(entryDate: dayKey(daysAgo: entry.0))
            try body(result.container.id, opening: entry.1, extra: entry.0 % 3 == 0 ? 1 : 0)
            if entry.0 == 21 || entry.0 == 4 { _ = try ops.applyTag(tHealth.id, toPost: result.container.id) }
        }

        // ── Home: bookless notes (the Pool), quotes, ideas (→ arrivals) ──
        let bookless: [(String?, String, Double)] = [
            (nil, "call the framer about the map", 3),
            (nil, "title idea: The Keeper's Hours", 5),
            (nil, "Remember: the bakery on Rua da Rosa closes at two", 9),
            (nil, "what if the essay is actually a letter?", 0.2),
            ("Grocery list", "Lemons, lentils, flour, the good butter.", 1.5),
            ("Books to borrow", "Ask J. for the Sebald and the Annie Dillard.", 14),
            ("Questions for the accountant", "Is the home office deduction worth the paperwork?", 27),
            ("Gift ideas", "A fountain pen for D. A plant for the office.", 33),
        ]
        var booklessPosts: [Container] = []
        for entry in bookless {
            clock.set(at(daysAgo: entry.2, hour: 12))
            let post = try ops.createPost(title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
            booklessPosts.append(post)
        }
        try ops.setStarred(.post(booklessPosts[4].id), starred: true)

        let quoteTexts = [
            ("Annie Dillard", "How we spend our days is, of course, how we spend our lives."),
            ("Montaigne", "I quote others only in order the better to express myself."),
            ("Mary Oliver", "Attention is the beginning of devotion."),
            ("Anne Lamott", "Almost all good writing begins with terrible first efforts."),
            ("Eliot", "It is never too late to be what you might have been."),
            ("Sebald", "Men and animals regard each other across a gulf of mutual incomprehension."),
        ]
        for (i, entry) in quoteTexts.enumerated() {
            clock.set(at(daysAgo: Double(50 - i * 7), hour: 23))
            let post = try ops.createPost(title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
            _ = try ops.applyTag(tQuote.id, toPost: post.id)
        }

        let ideaTexts = [
            ("A shelf of unfinished things", "An essay that is only first paragraphs, each one abandoned honestly."),
            ("Podcast, second attempt", "Five minutes, one sentence read slowly, and why it works."),
            ("Map of every walk", "Pin every walk where a paragraph arrived."),
            ("The keeper's logbook as a frame", "Tell the lighthouse story entirely in logbook entries."),
            ("Write the bread recipe as a poem", "Flour, water, salt, and patience in the wrong order."),
        ]
        var ideaPosts: [Container] = []
        for (i, entry) in ideaTexts.enumerated() {
            clock.set(at(daysAgo: Double(18 - i * 3), hour: 16))
            let post = try ops.createPost(title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
            _ = try ops.applyTag(tIdea.id, toPost: post.id)   // bells an arrival in Ideas inbox
            ideaPosts.append(post)
        }
        // Seat two of the five arrivals; three stay waiting.
        clock.set(at(daysAgo: 2, hour: 9))
        for post in ideaPosts.prefix(2) {
            let pairID = try self.db.read { db in
                try String.fetchOne(db, sql: """
                    SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ?
                    AND status = 'arrival' AND deleted_at IS NULL
                    """, arguments: [ideasInbox.id, post.id])
            }
            if let pairID { _ = try ops.seatArrival(pairID) }
        }
        _ = quotes

        // Scraps (the pool container).
        clock.set(at(daysAgo: 11))
        let pool = try ops.createPool(title: "Pool")
        for (i, text) in ["a heron, standing like a question mark",
                          "the sea doesn't keep appointments",
                          "Every lighthouse is a promise somebody keeps at night.",
                          "salt on the window glass"].enumerated() {
            let b = try ops.newBlock(in: pool.id, text: text, at: .end, registeringUndo: false)
            if i == 2 { _ = try ops.applyTag(tQuote.id, toBlock: b.block.id) }
        }

        // Archived notes (one in Essays, one bookless) and trash.
        clock.set(at(daysAgo: 25))
        try ops.archiveContainer(essayPosts[5].id)
        try ops.archiveContainer(booklessPosts[7].id)
        clock.set(at(daysAgo: 12))
        try ops.deleteContainer(booklessPosts[6].id)
        clock.set(at(daysAgo: 3))
        try ops.deleteContainer(booklessPosts[5].id)

        // ── Work wing ───────────────────────────────────────────────────
        clock.set(at(daysAgo: 115))
        let meetings = try ops.createReading(
            name: "Meeting notes", kind: .book, sortField: .entryDate, sortDir: .desc,
            wingId: work.id, shelfId: sProjects.id)
        let meetingTitles = [
            (98, "Kickoff — onboarding redesign", "Goal: a first open with no popup and nothing to dismiss."),
            (84, "Weekly sync", "Search is slow on big libraries; profile before guessing."),
            (70, "Design review", "The quick entry box reads as a form, not a place to write."),
            (56, "Weekly sync", "Ship the export fix first; the rest can wait a week."),
            (42, "Planning — Q4", "Three bets: mobile parity, search speed, the import door."),
            (28, "1:1 with D.", "D. wants more time for the migration tests. Agreed."),
            (14, "Retro", "What went well: the release. What did not: the release notes."),
            (3, "Weekly sync", "Phone feedback: the font is too small and the buttons are tiny."),
        ]
        for (i, entry) in meetingTitles.enumerated() {
            clock.set(at(daysAgo: Double(entry.0), hour: 11))
            let post = try ops.newPostInReading(
                meetings.id, title: entry.1, profile: .generic, entryDate: dayKey(daysAgo: entry.0))
            try body(post.id, opening: entry.2, extra: 1 + i % 2)
            _ = try ops.applyTag(wMeeting.id, toPost: post.id)
            if i >= 4 { _ = try ops.applyTag(wQ4.id, toPost: post.id) }
        }
        let specs = try ops.createReading(name: "Product specs", kind: .book, wingId: work.id, shelfId: sProjects.id)
        var specPosts: [Container] = []
        for (i, entry) in [("Spec — export subset", "Export only what the reader can see, and say what was left out."),
                            ("Spec — search ranking", "Title matches first, then recent edits, then everything else."),
                            ("Spec — offline capture", "The phone must accept a note with no network, ever."),
                            ("Spec — onboarding cards", "One card at a time, never before the first note.")].enumerated() {
            clock.set(at(daysAgo: Double(76 - i * 15), hour: 15))
            let post = try ops.newPostInReading(specs.id, title: entry.0, profile: .generic)
            let blocks = try body(post.id, opening: entry.1, extra: 3)
            _ = try ops.applyTag(wSpec.id, toPost: post.id)
            if i == 1 { _ = try ops.addBlockComment(to: blocks[2].block.id, text: "Needs numbers from the 100k fixture.") }
            specPosts.append(post)
        }
        clock.set(at(daysAgo: 30))
        try ops.lockPost(specPosts[0].id)   // a sealed note
        // The name twin: an "Ideas inbox" in Work too (legal per wing — on the phone the two meet in one list).
        let workIdeas = try ops.createReading(name: "Ideas inbox", kind: .book, wingId: work.id)
        for (i, entry) in [("Faster cold start", "Measure the first frame on the oldest supported phone."),
                            ("Undo history panel", "A list of what undo would do, before you do it."),
                            ("Keyboard shortcuts on iPad", "If the iPad ever happens, ⌘K first.")].enumerated() {
            clock.set(at(daysAgo: Double(35 - i * 6), hour: 14))
            let post = try ops.newPostInReading(workIdeas.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
            _ = try ops.applyTag(wIdea.id, toPost: post.id)
        }
        clock.set(at(daysAgo: 4, hour: 10))
        let workLoose = try ops.createPost(title: "Expense report reminder", profile: .generic, wingId: work.id)
        try body(workLoose.id, opening: "Submit the October expenses before Friday.", extra: 0)

        // ── Fiction wing ────────────────────────────────────────────────
        clock.set(at(daysAgo: 105))
        let lighthouse = try ops.createReading(name: "The Lighthouse Keeper", kind: .book, wingId: fiction.id)
        try ops.setStarred(.reading(lighthouse.id), starred: true)
        let p1 = try ops.createSection(in: lighthouse.id, name: "Part one — the island")
        let p2 = try ops.createSection(in: lighthouse.id, name: "Part two — the storm")
        let p3 = try ops.createSection(in: lighthouse.id, name: "Part three — the relief boat")
        let scenes: [(String, String, String)] = [
            ("The keeper wakes", "Elias woke before the lamp went out, as he had every morning for eleven years.", p1.id),
            ("The logbook", "The logbook had a column for weather and a column for ships and no column for loneliness.", p1.id),
            ("Supply day", "The boat came on Thursdays, when it came at all.", p1.id),
            ("The letter", "There was a letter in the supplies, and it was not from the Board.", p2.id),
            ("Barometer", "The needle fell all afternoon, slowly, like a decision being made.", p2.id),
            ("The night of the storm", "At midnight the sea began to climb the rocks as if it meant to come inside.", p2.id),
            ("Morning after", "The lamp had held. The jetty had not.", p3.id),
            ("The relief boat", "The new keeper was younger than Elias had been, and far more afraid of the stairs.", p3.id),
            ("Elias leaves", "He did not look back at the tower, because he did not need to.", p3.id),
        ]
        var sceneBlocks: [Operations.NewBlockResult] = []
        for (i, scene) in scenes.enumerated() {
            clock.set(at(daysAgo: Double(100 - i * 10), hour: 6))
            let post = try ops.newPostInReading(lighthouse.id, section: scene.2, title: scene.0, profile: .bookChapter)
            let blocks = try body(post.id, opening: scene.1, extra: 3 + i % 2)
            _ = try ops.applyTag(fDraft.id, toPost: post.id)
            if i == 5 {
                // The heavy fan: four takes on the storm's opening, labelled; comments; a callout; commits.
                try fan(blocks[0], takes: [
                    ("quieter", "At midnight the sea rose."),
                    ("Elias's eyes", "Elias watched the sea climb the rocks the way a man watches a debt come due."),
                    ("present tense", "At midnight the sea climbs the rocks as if it means to come inside."),
                ], labelOriginal: "draft 1")
                _ = try ops.commit(blocks[0].variant.id, kind: .manual, message: "storm, first full draft")
                _ = try ops.commit(blocks[1].variant.id, kind: .auto, message: nil)
                _ = try ops.addBlockComment(to: blocks[0].block.id, text: "Which one sounds like Elias and not like me?")
                _ = try ops.addBlockComment(to: blocks[2].block.id, text: "Too long — cut the second half?")
                try ops.setBlockPresentation(blocks[3].block.id, BlockPresentation(color: "sand", emoji: "⚓"))
                try ops.setMembershipPinned(post.id, in: lighthouse.id, pinned: true)
                _ = try ops.addReference(to: post.id, kind: .url, name: "Lighthouse — Wikipedia",
                                         url: "https://en.wikipedia.org/wiki/Lighthouse")
                try ops.setStarred(.post(post.id), starred: true)
                // A block deleted from this note (This Note's Tray ▸ Leaving), and a deleted comment.
                clock.set(at(daysAgo: 5))
                try ops.deleteBlock(blocks[blocks.count - 1].block.id)
                let gone = try ops.addBlockComment(to: blocks[1].block.id, text: "(old note — no longer true)")
                try ops.deleteBlockComment(gone.id)
            }
            if i == 1 { _ = try ops.applyTag(fSetting.id, toPost: post.id) }
            sceneBlocks.append(blocks[0])
        }
        _ = sceneBlocks

        clock.set(at(daysAgo: 95))
        let bible = try ops.createReading(name: "Character bible", kind: .book, wingId: fiction.id)
        for (i, entry) in [("Elias Varga", "Sixty-one. Keeper for eleven years. Writes everything down, says almost nothing."),
                            ("Marta", "The letter writer. We never meet her; we only meet her handwriting."),
                            ("The new keeper", "Twenty-four. Brave about the sea, terrified of the stairs."),
                            ("The Board", "Never a person. Always a letterhead.")].enumerated() {
            clock.set(at(daysAgo: Double(94 - i * 8), hour: 7))
            let post = try ops.newPostInReading(bible.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 1)
            _ = try ops.applyTag(fCharacter.id, toPost: post.id)
        }

        // The very long note: the Sherlock stories as a "manuscript", ~40k words.
        clock.set(at(daysAgo: 45, hour: 5))
        let manuscript = try ops.createReading(name: "Manuscript", kind: .book, wingId: fiction.id)
        let long = try ops.newPostInReading(manuscript.id, title: "Full draft — v3", profile: .bookChapter)
        var words = 0
        var blockIndex = 0
        storyLoop: for story in filler.stories {
            let heading = try ops.newBlock(in: long.id, text: "## \(story.title)", at: .end, registeringUndo: false)
            _ = heading
            let paragraphs = story.text.components(separatedBy: "\n\n")
                .map { $0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            for paragraph in paragraphs {
                let b = try ops.newBlock(in: long.id, text: paragraph, at: .end, registeringUndo: false)
                words += paragraph.split(separator: " ").count
                blockIndex += 1
                if blockIndex % 53 == 7 {
                    try fan(b, takes: [("alt", filler.next())])
                }
                if blockIndex % 71 == 11 {
                    _ = try ops.addBlockComment(to: b.block.id, text: "margin note at block \(blockIndex)")
                }
                if blockIndex % 131 == 17 {
                    try ops.setBlockPresentation(b.block.id, BlockPresentation(color: "blue", emoji: nil))
                }
                if words >= 40_000 { break storyLoop }
            }
        }
        _ = try ops.applyTag(fDraft.id, toPost: long.id)
        try ops.setStarred(.post(long.id), starred: true)
        clock.set(at(daysAgo: 0.5, hour: 8))
        _ = try ops.newBlock(in: long.id, text: "(continue from here — the ending still needs the relief boat)",
                             at: .end, registeringUndo: false)

        // A trashed Fiction note.
        clock.set(at(daysAgo: 8))
        let cut = try ops.createPost(title: "Cut scene — the second keeper's dream", profile: .generic, wingId: fiction.id)
        try body(cut.id, opening: "He dreamed of a lighthouse with no stairs at all.", extra: 1)
        clock.set(at(daysAgo: 7))
        try ops.deleteContainer(cut.id)

        // ── The other six wings (her real library has NINE: Home + eight; uneven on purpose) ──
        // Research (medium), Family (medium-small), Health (small), Side project (small),
        // Poetry (nearly empty: one bookless note), Taxes 2025 (nearly empty: one empty book).
        clock.set(at(daysAgo: 128))
        let research = try ops.createWing(name: "Research")
        let family = try ops.createWing(name: "Family")
        let health = try ops.createWing(name: "Health")
        let side = try ops.createWing(name: "Side project")
        let poetry = try ops.createWing(name: "Poetry")
        let taxes = try ops.createWing(name: "Taxes 2025")

        let rSource = try tag("source", wing: research.id)
        let rInterview = try tag("interview", wing: research.id)
        let sources = try ops.createReading(name: "Sources", kind: .book, wingId: research.id)
        for (i, entry) in [("Lighthouse service records, 1890–1920", "Keepers were paid quarterly and fined for a dark lamp."),
                            ("Fresnel lens — how it works", "Concentric prisms bend the light into one beam; the lamp itself is small."),
                            ("Shipwreck registers", "Most wrecks were within sight of a light. That is the cruel part."),
                            ("Island supply logs", "Thursday boats, weather permitting, which it often did not."),
                            ("Keepers' wives — letters archive", "The letters are about bread, children and wind, in that order.")].enumerated() {
            clock.set(at(daysAgo: Double(120 - i * 9), hour: 13))
            let post = try ops.newPostInReading(sources.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 2)
            _ = try ops.applyTag(rSource.id, toPost: post.id)
        }
        let interviews = try ops.createReading(name: "Interview transcripts", kind: .book, wingId: research.id)
        for (i, entry) in [("Interview — retired keeper, Cape Ray", "He still wakes at four. He said that first, before his name."),
                            ("Interview — harbour master", "Nobody misses the lighthouses except the people who never lived in one."),
                            ("Interview — museum archivist", "The logbooks are the best source and the least read.")].enumerated() {
            clock.set(at(daysAgo: Double(60 - i * 11), hour: 15))
            let post = try ops.newPostInReading(interviews.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 3)
            _ = try ops.applyTag(rInterview.id, toPost: post.id)
        }

        let kids = try ops.createReading(name: "Kids' sayings", kind: .book, wingId: family.id)
        for (i, entry) in [("“The moon is following us”", "Said from the back seat, with total confidence and some suspicion."),
                            ("On bedtime", "“I'm not tired, my eyes are just resting their whole body.”"),
                            ("Dinosaurs", "A list of every dinosaur we were told about at breakfast."),
                            ("First joke", "Why did the banana go to the doctor? It wasn't peeling well.")].enumerated() {
            clock.set(at(daysAgo: Double(90 - i * 20), hour: 19))
            let post = try ops.newPostInReading(kids.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
        }
        let holidays = try ops.createReading(name: "Holidays", kind: .book, wingId: family.id)
        for entry in [("Christmas menu", "Same as last year, minus the sprouts nobody ate."),
                      ("Summer at the lake", "Book the cabin before March or don't bother.")] {
            clock.set(at(daysAgo: 52, hour: 20))
            let post = try ops.newPostInReading(holidays.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
        }

        let hRun = try tag("run", wing: health.id)
        let runningLog = try ops.createReading(
            name: "Running log", kind: .book, profile: Queries.journalTraitProfile,
            sortField: .entryDate, sortDir: .desc, wingId: health.id)
        for entry in [(22, "5 km, easy", "Legs heavy, head clear."), (15, "8 km", "New route along the river. Herons."),
                      (9, "Intervals", "6 × 400 m. Never again. Until Thursday."), (2, "10 km", "First double-digit run since spring.")] {
            clock.set(at(daysAgo: Double(entry.0), hour: 6.5))
            let post = try ops.newPostInReading(
                runningLog.id, title: entry.1, profile: .journal, entryDate: dayKey(daysAgo: entry.0))
            try body(post.id, opening: entry.2, extra: 0)
            _ = try ops.applyTag(hRun.id, toPost: post.id)
        }

        let appIdeas = try ops.createReading(name: "App ideas", kind: .book, wingId: side.id)
        for entry in [("A tide-table widget", "Just the next high tide, big, nothing else."),
                      ("Shared grocery list that isn't a chat", "Two people, one list, no notifications.")] {
            clock.set(at(daysAgo: 44, hour: 22))
            let post = try ops.newPostInReading(appIdeas.id, title: entry.0, profile: .generic)
            try body(post.id, opening: entry.1, extra: 0)
        }

        clock.set(at(daysAgo: 37, hour: 23))
        let poem = try ops.createPost(title: "untitled (heron)", profile: .generic, wingId: poetry.id)
        try body(poem.id, opening: "grey question mark / on one leg / the river answers nothing", extra: 0)

        clock.set(at(daysAgo: 100))
        _ = try ops.createReading(name: "Receipts", kind: .book, wingId: taxes.id)   // nearly empty: a book with no notes

        // Most-recent touch: a fresh edit on an essay so "newest first" leads with something real.
        clock.set(at(daysAgo: 0.1, hour: 9))
        _ = try ops.newBlock(in: essayPosts[1].id, text: "(add: the experiment with the 6 a.m. alarm)",
                             at: .end, registeringUndo: false)
        _ = (tHealth, wQ4)
    }
}
