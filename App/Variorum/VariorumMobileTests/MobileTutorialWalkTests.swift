//
//  MobileTutorialWalkTests.swift
//  VariorumMobileTests
//
//  Parity round Stage B, batch B1 — THE POCKET GUIDE'S WALKS (P-6: the
//  tutorial is the executable spec, the phone's edition). For every
//  lesson of "the pocket guide", these suites execute the acts the
//  lesson's prose asks the reader to perform — headlessly, through the
//  same controllers/operations the app's own surfaces route — against
//  freshly-seeded tutorial content, and assert the STORE outcomes the
//  prose promises. They JOIN the `MobileWalkTests` family as the
//  round's permanent acceptance spine: every suite here rides the
//  baseline mobile suite, and a broken walk step is a regression by
//  definition.
//
//  THE SPINE'S SUITE TYPE NAMES (the -only-testing trap — per-test and
//  file-name selectors silently select zero; run these SEVEN by name):
//  MobileWalkTests · MobileTutorialBookShapeTests ·
//  MobileTutorialDoorTests · MobileTutorialWritingWalkTests ·
//  MobileTutorialTakesWalkTests · MobileTutorialStructureWalkTests ·
//  MobileTutorialLibraryWalkTests.
//
//  Windowless throughout (the corrected A3 machinery lesson): every
//  surface here is a bare frame'd view — no UIWindow ever joins the
//  baseline suite from this file.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The seeded world

@MainActor
private func withPocketGuideWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ bookID: String) async throws -> T
) async throws -> T {
    // The default voice, deterministically (the withEditorWorld rule —
    // voice tests set and restore their own).
    MobileEditorStyle.voice = .terminal
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_783_036_800)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 21))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let bookID = try await MobileTutorialSeeder.restore(session: session)
        return try await body(session, db, bookID)
    }
}

@MainActor
private func poll(
    _ condition: @MainActor () -> Bool, turns: Int = 2000
) async {
    // One polling body suite-wide (C2 ladder R1-6): delegate to the
    // shared `settle` (MobileBooksTests) — the name stays for the walks'
    // call sites.
    await settle(attempts: turns, condition)
}

private enum PocketGuideWalkError: Error {
    case missingLesson(String)
    case missingStagedContent(String)
}

/// A lesson note's id by its exact title (the seeded titles are the plan's).
private func lessonID(_ db: Database, bookID: String, _ title: String) throws -> String {
    guard let id = try String.fetchOne(
        db,
        sql: """
            SELECT c.id FROM reading_post rp
            JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
            """,
        arguments: [bookID, title])
    else {
        throw PocketGuideWalkError.missingLesson(title)
    }
    return id
}

/// One user note's whole subtree, byte-for-byte (the Mac walk's NIT-5
/// shape: the wholesale pin compares placements, blocks, and variants —
/// never just the container row).
private func userPostRows(_ db: Database, postID: String) throws -> [Row] {
    try Row.fetchAll(db, sql: "SELECT * FROM container WHERE id = ?", arguments: [postID])
        + Row.fetchAll(
            db,
            sql: "SELECT * FROM container_block WHERE container_id = ? ORDER BY id",
            arguments: [postID])
        + Row.fetchAll(
            db,
            sql: """
                SELECT * FROM block WHERE id IN
                  (SELECT block_id FROM container_block WHERE container_id = ?)
                ORDER BY id
                """,
            arguments: [postID])
        + Row.fetchAll(
            db,
            sql: """
                SELECT * FROM variant WHERE block_id IN
                  (SELECT block_id FROM container_block WHERE container_id = ?)
                ORDER BY id
                """,
            arguments: [postID])
}

/// A block's live active take count (the fan's size, store truth).
private func fanCount(_ db: Database, blockID: String) throws -> Int {
    try Int.fetchOne(
        db,
        sql: """
            SELECT COUNT(*) FROM variant
            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
            """,
        arguments: [blockID]) ?? -1
}

/// The chosen pointer on a block's live placement.
private func chosenVariantID(_ db: Database, blockID: String) throws -> String? {
    try String.fetchOne(
        db,
        sql: """
            SELECT chosen_variant_id FROM container_block
            WHERE block_id = ? AND deleted_at IS NULL
            """,
        arguments: [blockID])
}

private func utf16Offset(of needle: String, in text: String) throws -> Int {
    let range = (text as NSString).range(of: needle)
    guard range.location != NSNotFound else {
        throw PocketGuideWalkError.missingStagedContent(needle)
    }
    return range.location
}

/// The full real editor over a lesson (the walk-1 surface: TK2-explicit
/// view in the keyboard-avoiding container, canary armed, windowless).
@MainActor
private func makeLessonSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    return (model, surface)
}

// MARK: - The book itself (seed shape + the plan contract)

@MainActor
@Suite("Mobile tutorial book shape (parity B1, P-6)")
struct MobileTutorialBookShapeTests {
    @Test func theSeededBookMatchesTheLessonPlanExactly() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let chapters = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT name FROM reading_section
                        WHERE reading_id = ? AND deleted_at IS NULL
                        ORDER BY position, id
                        """,
                    arguments: [bookID])
            }
            #expect(chapters == MobileTutorialSeeder.plan.map(\.chapter))

            // Lessons, in book order, each under its declared chapter.
            let rows: [(title: String, chapter: String?)] = try await db.read { db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT c.title AS title, rs.name AS chapter FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        LEFT JOIN reading_section rs
                          ON rs.id = rp.section_id AND rs.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                        ORDER BY rp.position, rp.id
                        """,
                    arguments: [bookID]
                ).map { ($0["title"], $0["chapter"]) }
            }
            let planned = MobileTutorialSeeder.plan.flatMap { chapter, lessons in
                lessons.map { (title: $0, chapter: chapter) }
            }
            #expect(rows.count == planned.count, "every lesson is in the book exactly once")
            for (row, plan) in zip(rows, planned) {
                #expect(row.title == plan.title)
                #expect(row.chapter == plan.chapter, "\(plan.title) sits in \(plan.chapter)")
            }
        }
    }

    @Test func nothingSeededIsJournalShaped() async throws {
        // R57's class: journal-shaped rows are the daily Journal's and the
        // phone's journal list's — no tutorial text may ever be structurally
        // visible there (the rule's original reason, the Fragments bridge's
        // day sweep, retired 2026-09-04; the rule stays).
        try await withPocketGuideWorld { _, db, _ in
            let journalShaped = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container
                        WHERE deleted_at IS NULL
                          AND (profile = 'journal' OR entry_date IS NOT NULL)
                        """) ?? -1
            }
            #expect(journalShaped == 0, "no tutorial row can ever reach the daily Journal")
        }
    }

    /// 13s-b U4 (her R-13s-31, *"I want that changed everywhere"*): the
    /// pocket guide speaks COMMIT — every take of every block it seeds, every
    /// title, every chapter name. Red on the pre-U4 seed by construction:
    /// five of its sentences said "savepoint" (one of them in caps).
    @Test func thePocketGuideSaysCommitNeverSavepoint() async throws {
        try await withPocketGuideWorld { _, db, _ in
            let texts = try await db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE deleted_at IS NULL")
                    + String.fetchAll(
                        db, sql: "SELECT COALESCE(title, '') FROM container WHERE deleted_at IS NULL")
                    + String.fetchAll(
                        db, sql: "SELECT name FROM reading_section WHERE deleted_at IS NULL")
            }
            #expect(texts.count > 20, "the walk read the seeded guide (\(texts.count) texts)")
            let offenders = texts.filter {
                $0.range(of: #"\bsavepoints?\b"#, options: [.regularExpression, .caseInsensitive]) != nil
            }
            #expect(offenders.isEmpty,
                    "the pocket guide still says savepoint: \(offenders.map { $0.prefix(80) })")
            #expect(texts.contains { $0.contains("a commit is the deliberate extra") },
                    "the term it defines is commit, lowercase")
        }
    }

    @Test func everyLessonWearsTheTagAndTheGuideSitsPinned() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let (taggedIDs, lessonIDs, reading, pins) = try await db.read {
                db -> (Set<String>, Set<String>, Reading?, [String]) in
                let tag = try Queries.allTags(db).first {
                    $0.path == MobileTutorialSeeder.tagName
                }
                let tagged = try tag.map {
                    Set(try Queries.everythingTagged(db, tagID: $0.id, includeSubtree: false)
                        .postIDs)
                } ?? []
                let lessons = Set(try String.fetchAll(
                    db,
                    sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [bookID]))
                return (tagged, lessons, try Queries.reading(db, id: bookID),
                        try Queries.shelfPins(db))
            }
            #expect(lessonIDs.isSubset(of: taggedIDs),
                    "the tag IS the restore identity — every lesson wears it")
            #expect(taggedIDs.count == lessonIDs.count + 1,
                    "…plus exactly the loose practice note")
            #expect(reading?.kind == .book)
            #expect(pins.contains(bookID),
                    "the guide is pinned — the shelf's pin face, taught by wearing it")
        }
    }

    @Test func actReadyStagingIsInPlace() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            // The swipe lesson's three-take rain block.
            let swipe = try await db.read { try lessonID($0, bookID: bookID, "swipe & choose") }
            let rain = try await db.read { db -> Queries.RenderedBlock? in
                try Queries.renderPost(db, containerID: swipe)
                    .first { $0.text?.contains("The rain came in from the sea") == true }
            }
            let rainBlock = try #require(rain)
            #expect(try await db.read { try fanCount($0, blockID: rainBlock.blockID) } == 3,
                    "the swipe lesson has three takes to flip")

            // The browser lesson's spare take.
            let browser = try await db.read { try lessonID($0, bookID: bookID, "the browser") }
            let keeper = try #require(try await db.read { db -> Queries.RenderedBlock? in
                try Queries.renderPost(db, containerID: browser)
                    .first { $0.text?.contains("The keeper logged the weather") == true }
            })
            #expect(try await db.read { try fanCount($0, blockID: keeper.blockID) } == 2,
                    "the browser lesson has its spare take")

            // The fanned-divide lesson's two-take ferry block.
            let fanned = try await db.read { try lessonID($0, bookID: bookID, "divide with takes") }
            let ferry = try #require(try await db.read { db -> Queries.RenderedBlock? in
                try Queries.renderPost(db, containerID: fanned)
                    .first { $0.text?.contains("The ferry crossed at dawn") == true }
            })
            #expect(try await db.read { try fanCount($0, blockID: ferry.blockID) } == 2)

            // The merge lesson's fanned tail (the carry-all's demonstrator).
            let merge = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            let tail = try #require(try await db.read { db -> Queries.RenderedBlock? in
                try Queries.renderPost(db, containerID: merge)
                    .first { $0.text?.contains("This block has a spare take") == true }
            })
            #expect(try await db.read { try fanCount($0, blockID: tail.blockID) } == 2)

            // The comment and the callout on their lesson.
            let furniture = try await db.read {
                try lessonID($0, bookID: bookID, "comments & callouts")
            }
            let furnitureSlots = try await db.read { try Queries.renderPost($0, containerID: furniture) }
            let comments = try await db.read { [id = furnitureSlots[0].blockID] db in
                try Queries.blockComments(db, blockID: id)
            }
            #expect(comments.count == 1, "the margin comment is staged")
            let calloutJSON = try await db.read { [id = furnitureSlots[1].blockID] db in
                try String.fetchOne(
                    db, sql: "SELECT presentation FROM block WHERE id = ?", arguments: [id])
            }
            let presentation = BlockPresentation.decode(calloutJSON)
            #expect(presentation?.kind == BlockPresentation.calloutKind)
            #expect(presentation?.color == "blue")

            // The seal lesson ships sealed.
            let sealed = try await db.read { try lessonID($0, bookID: bookID, "the seal") }
            let sealedHeader = try await db.read { try Queries.containerHeader($0, containerID: sealed) }
            #expect(sealedHeader?.locked == true, "the seal lesson ships sealed")

            // The loose practice note: bookless, and in the pool listing.
            let loose = try #require(try await db.read { db -> Container? in
                try Container.fetchOne(
                    db,
                    sql: "SELECT * FROM container WHERE title = ? AND deleted_at IS NULL",
                    arguments: [MobileTutorialSeeder.looseNoteTitle])
            })
            let memberships = try await db.read { [id = loose.id] db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [id]) ?? -1
            }
            #expect(memberships == 0, "the loose note belongs to no book")
            let poolIDs = try await db.read { db in
                try Queries.poolPosts(db, limit: 50).map(\.postID)
            }
            #expect(poolIDs.contains(loose.id),
                    "…and the Library's bookless filter lists it (the lesson's promise)")
        }
    }

    /// The formatting lesson demonstrates itself: its stored text IS the
    /// syntax it teaches (markdown-as-content), and the Read face — the
    /// book's read door — renders it with the markers gone.
    @Test func theFormattingLessonIsWrittenInTheVocabularyItTeaches() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let formatting = try await db.read { try lessonID($0, bookID: bookID, "formatting") }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: formatting)
            }
            for syntax in ["**markdown**", "**bold**", "*italic*", "`inline code`",
                           "~~struck words~~", "[links](https://commonmark.org)",
                           "## Headings are sizes", "- lists are lines",
                           "- [ ] a checkbox", "- [x] tap a box"] {
                #expect(stored.contains(syntax), "the lesson shows \(syntax) by BEING it")
            }

            // The Read face (MobileReadPage renders through the one core
            // brain): markers gone, forms in their place.
            let rendered = MarkdownRendering.render(stored)
            for span in ["**markdown**", "*italic*", "`inline code`",
                         "~~struck words~~", "](https://commonmark.org)",
                         "## Headings are sizes", "- [ ] a checkbox"] {
                #expect(!rendered.text.contains(span), "read hides \(span.debugDescription)")
            }
            #expect(rendered.text.contains("Headings are sizes"))
            let paragraphs = MobileReadPage.paragraphs(of: stored)
            #expect(!paragraphs.isEmpty, "the read page composes the lesson")
        }
    }
}

// MARK: - The doors (find-or-seed / wholesale restore)

@MainActor
@Suite("Mobile tutorial doors (parity B1 — the Mac door grammar)")
struct MobileTutorialDoorTests {
    @Test func restoreReplacesWholesaleAndTouchesNothingElse() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            // A user's own world beside the tutorial.
            let userPost = try await session.runner.run { ops in
                let post = try ops.createPost(title: "my real essay")
                _ = try ops.newBlock(in: post.id, text: "my own words.", at: .end)
                return post
            }
            let userBook = try await session.runner.run { ops in
                try ops.createReading(name: "my book", kind: .book)
            }
            let userRows = try await db.read { [postID = userPost.id] db in
                try userPostRows(db, postID: postID).map(CopiedRow.init)
            }

            // Wound the tutorial: delete one lesson, scribble on another.
            let doomed = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            try await session.runner.run { ops in try ops.deleteContainer(doomed) }
            let edited = try await db.read { try lessonID($0, bookID: bookID, "divide") }
            let editedSlots = try await db.read { try Queries.renderPost($0, containerID: edited) }
            let editedVariant = try #require(editedSlots.first?.variantID)
            try await session.runner.run { ops in
                try ops.autosave(editedVariant, text: "scribbled over", charDelta: 14)
            }

            let freshBookID = try await MobileTutorialSeeder.restore(session: session)
            #expect(freshBookID != bookID, "wholesale: a fresh book, not a patch")

            let (bookCount, lessonCount, oldBookLive) = try await db.read { db -> (Int, Int, Bool) in
                let books = try Queries.readings(db).filter {
                    $0.name == MobileTutorialSeeder.bookName
                }
                let lessons = try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [freshBookID]) ?? 0
                return (books.count, lessons, try Queries.reading(db, id: bookID) != nil)
            }
            #expect(bookCount == 1, "exactly one live pocket guide")
            #expect(lessonCount == MobileTutorialSeeder.plan.flatMap(\.lessons).count)
            #expect(!oldBookLive, "the old book is gone")

            // The fresh divide lesson is pristine again.
            let freshDivide = try await db.read { try lessonID($0, bookID: freshBookID, "divide") }
            let freshSlots = try await db.read { try Queries.renderPost($0, containerID: freshDivide) }
            #expect(freshSlots[0].text?.contains("Divide cuts a block in two") == true)

            // The user's world is byte-untouched — the note AND its
            // placements/blocks/variants.
            let userRowsAfter = try await db.read { [postID = userPost.id] db in
                try userPostRows(db, postID: postID).map(CopiedRow.init)
            }
            #expect(!userRowsAfter.isEmpty)
            #expect(userRowsAfter == userRows,
                    "restore never touches her rows — down to the variants")
            let userBookLive = try await db.read { try Queries.reading($0, id: userBook.id) != nil }
            #expect(userBookLive)

            // The pins setting never accrues dead ids across restores
            // (cleanup unpins the doomed book; the fresh one pins).
            let pins = try await db.read { try Queries.shelfPins($0) }
            #expect(!pins.contains(bookID), "the dead book's pin is gone")
            #expect(pins.contains(freshBookID), "the fresh guide is pinned")
        }
    }

    /// The confirm gates on the SAME predicate as the destruction: no
    /// live book, but tagged content exists (residue — which may include
    /// HER tagged notes, hers to refuse for) ⇒ the door asks first, and
    /// a declined confirm deletes NOTHING.
    @Test func theConfirmGatesOnEverythingTheReplaceDestroys() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            try await session.runner.run { ops in try ops.deleteReading(bookID) }
            let userPost = try await session.runner.run { ops -> Container in
                let post = try ops.createPost(title: "my tagged essay")
                _ = try ops.newBlock(
                    in: post.id, text: "my own words, wearing the tag.", at: .end)
                return post
            }
            let tagID = try await db.read { db in
                try Queries.allTags(db).first { $0.path == MobileTutorialSeeder.tagName }?.id
            }
            let requiredTag = try #require(tagID)
            try await session.runner.run { ops in
                _ = try ops.applyTag(requiredTag, toPost: userPost.id)
            }

            var consulted = false
            let outcome = try await MobileTutorialSeeder.findOrSeed(
                session: session, confirmReplace: { consulted = true; return false })
            #expect(consulted, "no live book, but tagged content exists — the confirm gates")
            #expect(outcome == nil, "a declined confirm seeds nothing")
            let userStillLive = try await db.read { [id = userPost.id] db in
                try Container.fetchOne(db, key: id)?.deletedAt == nil
            }
            #expect(userStillLive == true,
                    "an unconfirmed restore deletes NOTHING — her note survives")
        }
    }

    /// Cleanup destroys exactly what the confirm discloses — the EXACT
    /// tag, never its sub-tags (the Mac's MINOR-D3 discipline).
    @Test func aSubTaggedUserNoteSurvivesTheRestore() async throws {
        try await withPocketGuideWorld { session, db, _ in
            let parentID = try await db.read { db in
                try Queries.allTags(db).first { $0.path == MobileTutorialSeeder.tagName }?.id
            }
            let parent = try #require(parentID)
            let userPost = try await session.runner.run { ops -> Container in
                let child = try ops.createTag(parent: parent, name: "keepsake")
                let post = try ops.createPost(title: "my keepsake notes")
                _ = try ops.newBlock(in: post.id, text: "sub-tagged, mine.", at: .end)
                _ = try ops.applyTag(child.id, toPost: post.id)
                return post
            }

            _ = try await MobileTutorialSeeder.restore(session: session)
            let stillLive = try await db.read { [id = userPost.id] db in
                try Container.fetchOne(db, key: id)?.deletedAt == nil
            }
            #expect(stillLive == true,
                    "a \u{201C}pocket guide/…\u{201D} note is NOT the tutorial's to clean up")
        }
    }

    /// The open entrance on a book-deleted store that still holds
    /// residue routes through the RESTORE path — confirm included —
    /// instead of seeding beside the residue (orphaned old lessons
    /// beside fresh ones; titles aren't unique).
    @Test func openOnAResidueStoreRestoresInsteadOfDuplicating() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            try await session.runner.run { ops in try ops.deleteReading(bookID) }

            var consulted = false
            let fresh = try await MobileTutorialSeeder.findOrSeed(
                session: session, confirmReplace: { consulted = true; return true })
            #expect(consulted, "residue exists — the open door replaces, so it asks first")
            #expect(fresh != nil)

            let (books, tagged) = try await db.read { db -> (Int, Int) in
                let books = try Queries.readings(db)
                    .filter { $0.name == MobileTutorialSeeder.bookName }.count
                let tag = try Queries.allTags(db).first {
                    $0.path == MobileTutorialSeeder.tagName
                }
                let tagged = try tag.map {
                    try Queries.everythingTagged(db, tagID: $0.id, includeSubtree: false)
                        .postIDs.count
                } ?? 0
                return (books, tagged)
            }
            #expect(books == 1, "never a second pocket guide")
            #expect(tagged == MobileTutorialSeeder.plan.flatMap(\.lessons).count + 1,
                    "the lessons + the loose note, exactly once — no orphans beside fresh copies")

            // And an existing book just reports itself — find-or-seed
            // never duplicates.
            let again = try await MobileTutorialSeeder.findOrSeed(
                session: session, confirmReplace: { Issue.record("no confirm owed"); return false })
            #expect(again == fresh, "an existing guide simply opens")
        }
    }

    /// Seeding is not HER act: the session's structural-undo stack is
    /// untouched by a restore (the Mac's MINOR-D1 — the phone has no
    /// undo door today, and entries must not accumulate against the day
    /// it gains one).
    @Test func theSeederNeverTouchesTheStructuralUndoStack() async throws {
        try await withPocketGuideWorld { session, _, _ in
            #expect(session.undoStack.depth == 0, "the world's own seed left no inverse")
            _ = try await MobileTutorialSeeder.restore(session: session)
            #expect(session.undoStack.depth == 0,
                    "a restore leaves the undo stack exactly as it found it")
        }
    }
}

// MARK: - writing (the taught flows, on the lessons' own text)

@MainActor
@Suite("Mobile tutorial walk — writing")
struct MobileTutorialWritingWalkTests {
    /// The blocks lesson's promise, executed on its own page: type at
    /// the end and each finished paragraph quietly becomes its own
    /// block; the trailing paragraph stays the open tail until teardown.
    ///
    /// Driven through `typeEdit` — the harness's policed-edit simulator
    /// (gate first, then the storage mutation) — because the open-tail
    /// gesture is GATE-routed: windowless programmatic `insertText`
    /// never consults the delegate (the A3 machinery lesson's
    /// input-controller trace), so it exercises only `fallbackVerdict`,
    /// which deliberately cannot open a tail (gate-bypassing system
    /// paths must never mint blocks). Real keyboards consult the gate.
    @Test func typingIntoTheBlocksLessonCrystallizes() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "blocks & typing") }
            let before = try await storedBlockTexts(db, postID: lesson)
            // 5 since parity C4a: the savepoint paragraph landed WITH the
            // commit/history doors (tutorial-as-spec — lesson + walk in
            // the same commit).
            #expect(before.count == 5)

            let (model, storage) = makeEditor(session, postID: lesson)
            await model.loadOnce()

            // The single newline at the exact document end OPENS the
            // tail (the paragraph-crystallization gesture)…
            #expect(typeAtEnd(model, storage, "\n"), "the gate admits the open-tail newline")
            #expect(model.index.tailLength == 0, "the tail opened")
            // …the finished paragraph crystallizes as its own block…
            #expect(typeAtEnd(model, storage, "A fresh paragraph of my own."))
            #expect(typeAtEnd(model, storage, "\n"))
            #expect(typeAtEnd(model, storage, "And the tail begins"))
            await model.awaitMintSettle()
            #expect(try await storedBlockTexts(db, postID: lesson)
                    == before + ["A fresh paragraph of my own."],
                    "the finished paragraph quietly became its own block")

            // …and teardown lands the open tail as the last block.
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: lesson)
                    == before + ["A fresh paragraph of my own.", "And the tail begins"],
                    "teardown lands the open tail as the last block")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.statusMessage == nil)
        }
    }

    /// **THE SAVEPOINT PARAGRAPH'S ROADS EXIST** (batch 9's fix wave,
    /// cold-review MAJOR 2 — the second of the two shipped lessons that
    /// went on naming the retired block-⋯ history row).
    ///
    /// Both doors it teaches are asserted against the menus that carry
    /// them, so a MOVE reds here rather than shipping a false
    /// instruction into her pocket guide: `Commit Take` must still be a
    /// block-⋯ row, and `Block History…` must NOT be — it is a take
    /// card's row now, reached through the bar's ⑂.
    ///
    /// **Red on old (behavioural revert):** restore the pre-fix sentence
    /// (*"Commit Take, in ⋯ … and Block History… beside it"*) and the
    /// beside-it assertion reds.
    @Test func theSavepointLessonTeachesRoadsThatStillExist() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, "blocks & typing"))
            }
            // The act that STAYED, named from the menu that still holds it.
            #expect(prose.contains(MobileBlockMenuController.commitTitle))
            #expect(MobileBlockMenuController.rowTitles
                    .contains(MobileBlockMenuController.commitTitle))
            // The face that MOVED, named from the door that now carries it…
            #expect(prose.contains(MobileTakesBrowserController.historyTitle))
            #expect(!MobileBlockMenuController.rowTitles.contains {
                $0.localizedCaseInsensitiveContains("history")
            }, "the block ⋯ no longer carries it, so the lesson must not say it does")
            // …and the lesson must not put the two side by side any more.
            #expect(!prose.contains("\(MobileTakesBrowserController.historyTitle) beside"),
                    "the retired 'beside it' pairing must not be taught")
            #expect(prose.contains("⑂ on the bottom bar"),
                    "the takes road, in the phone's own glyph")
            // The no-redirect principle, as everywhere in the guide.
            #expect(!prose.contains("Mac"))
            #expect(!prose.contains("⌘"))
        }
    }

    /// The formatting lesson's acts fire on its own text: bold wraps a
    /// selection, the heading picker's direct pick and clear land, and a
    /// tap on the staged box ticks it — stored bytes byte-checked.
    @Test func theFormattingActsFireOnTheLessonsOwnText() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "formatting") }
            let (model, surface) = await makeLessonSurface(session, postID: lesson)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)

            // BOLD a plain word (the lesson: "B or I wraps whatever
            // you've selected").
            let word = (view.textStorage.string as NSString).range(of: "small")
            #expect(word.location != NSNotFound)
            view.selectedRange = word
            bar.fireBold()
            #expect(view.textStorage.string.contains("**small**"),
                    "two stars around the word ARE the bold")

            // THE HEADING PICKER's direct pick, then clear (the lesson:
            // "press and HOLD it to pick Heading 1, 2, or 3 directly, or
            // clear one") — on the first paragraph's line.
            let first = (view.textStorage.string as NSString).range(of: "Formatting is")
            view.selectedRange = NSRange(location: first.location + 2, length: 0)
            bar.applyHeadingPick(level: 2)
            #expect(view.textStorage.string.contains("## Formatting is"),
                    "the direct pick leads the line")
            bar.applyHeadingClear()
            #expect(!view.textStorage.string.contains("## Formatting is"),
                    "clear takes the lead off")

            // TAP the staged box (the lesson: "tap a box on the page to
            // tick it").
            surface.layoutIfNeeded()
            let boxLine = (view.textStorage.string as NSString).range(of: "- [ ] a checkbox")
            #expect(boxLine.location != NSNotFound)
            let boxStart = boxLine.location + 2 // the "[" of "- [ ]"
            guard let from = view.position(from: view.beginningOfDocument, offset: boxStart + 1),
                  let to = view.position(from: view.beginningOfDocument, offset: boxStart + 2),
                  let boxRange = view.textRange(from: from, to: to)
            else {
                Issue.record("no laid-out geometry for the box")
                return
            }
            let rect = view.firstRect(for: boxRange)
            #expect(MobileMarkdownActs.toggleCheckbox(
                at: CGPoint(x: rect.midX, y: rect.midY), in: view))
            #expect(view.textStorage.string.contains("- [x] a checkbox"),
                    "the box ticked — an ordinary edit")

            // The store holds the walk's bytes exactly.
            await model.awaitMintSettle()
            await model.autosave.flushNow()
            let stored = try await storedBlockTexts(db, postID: lesson)
            #expect(stored.contains { $0.contains("**small**") })
            #expect(stored.contains { $0.contains("- [x] a checkbox") })
            #expect(!stored.joined().contains("## Formatting is"),
                    "the cleared heading never reached the store as a lead")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!view.canaryFired)
        }
    }
}

// MARK: - takes (the taught flows, on the lessons' own fans)

@MainActor
@Suite("Mobile tutorial walk — takes")
struct MobileTutorialTakesWalkTests {
    /// The first-take lesson: the browser's two mint gestures on the
    /// staged harbor block — branch is born a copy, blank is born
    /// empty, and minting never chooses.
    @Test func theFirstTakeLessonMintsACopyAndABlank() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "your first take") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let harbor = try #require(model.slots.first {
                $0.text?.contains("The harbor kept its lights on") == true
            })
            let harborText = try #require(harbor.text)
            let chosenBefore = try await db.read { try chosenVariantID($0, blockID: harbor.blockID) }

            model.takesBrowser.open(blockID: harbor.blockID)
            let branched = await model.takesBrowser.branchDisplayed()
            let branchedTake = try #require(branched)
            #expect(branchedTake.workingText == harborText,
                    "branch is born a copy of what you were reading")

            let blank = await model.takesBrowser.newBlank()
            #expect(try await storedText(db, variantID: try #require(blank).id) == "",
                    "blank is the genuinely-different gesture")

            #expect(try await db.read { try fanCount($0, blockID: harbor.blockID) } == 3)
            #expect(try await db.read { try chosenVariantID($0, blockID: harbor.blockID) }
                    == chosenBefore,
                    "minting never chooses — the note keeps saying what it said")
            await model.takesBrowser.close()
            #expect(model.statusMessage == nil)
        }
    }

    /// The swipe lesson: the flip peeks in place (store untouched,
    /// sticky marker, the pill), and the ✓ chooses — the peek ends
    /// because what you see is now what the note says.
    @Test func theSwipeLessonPeeksStickyAndTheCheckChooses() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "swipe & choose") }
            let (model, surface) = await makeLessonSurface(session, postID: lesson)
            let view = surface.textView
            let chrome = try #require(view.takesChrome)
            let rain = try #require(model.slots.first {
                $0.text?.contains("The rain came in from the sea without an opinion") == true
            })
            let original = try #require(rain.text)
            let storeBefore = try await storedBlockTexts(db, postID: lesson)

            // SWIPE (the gesture's act): the first flip. Fan order is
            // branch-beside-source by construction (each branch mints
            // between its source and the earlier mint), so the
            // last-seeded take sits at fan position 2.
            model.takes.flip(blockID: rain.blockID, forward: true)
            #expect(view.textStorage.string.contains("the sea did not explain itself"),
                    "the takes flip in place")
            #expect(!view.textStorage.string.contains(original))
            #expect(try await storedBlockTexts(db, postID: lesson) == storeBefore,
                    "a flip is a PEEK — the store is untouched")
            #expect(model.takes.isPeeking(rain.blockID))
            #expect(chrome.markerView(for: rain.blockID) != nil, "the sticky peek's marker")
            #expect(chrome.pillIsShowing, "take 2/3, ◀ ▶ and the ✓")

            // The second flip walks on.
            model.takes.flip(blockID: rain.blockID, forward: true)
            #expect(view.textStorage.string.contains("like a verdict"))

            // ✓ CHOOSES — the only act that changes what the note says.
            let peeked = try #require(model.slot(for: rain.blockID)?.variantID)
            await model.takes.chooseDisplayed(blockID: rain.blockID)
            #expect(try await db.read { try chosenVariantID($0, blockID: rain.blockID) }
                    == peeked)
            #expect(!model.takes.isPeeking(rain.blockID), "the peek ends at the ✓")
            #expect(chrome.markerView(for: rain.blockID) == nil)
            #expect(model.statusMessage == nil)
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    /// Branch under a PEEK: the displayed take is the peeked one, and
    /// the browser's branch inherits ITS text (the peek-aware displayed
    /// — the browser lesson's "branches the one you were reading").
    @Test func branchUnderAPeekSeedsFromThePeekedTake() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "swipe & choose") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let rain = try #require(model.slots.first {
                $0.text?.contains("The rain came in from the sea without an opinion") == true
            })

            model.takes.flip(blockID: rain.blockID, forward: true)
            let peekedText = try #require(model.slot(for: rain.blockID)?.text)
            #expect(peekedText.contains("the sea did not explain itself"),
                    "the peeked take (fan order is branch-beside-source)")

            model.takesBrowser.open(blockID: rain.blockID)
            let branched = await model.takesBrowser.branchDisplayed()
            #expect(try #require(branched).workingText == peekedText,
                    "the branch inherits the PEEKED take — the one you were reading")
            #expect(try await db.read { try fanCount($0, blockID: rain.blockID) } == 4)
        }
    }

    /// The lens lesson (parity C5 — the ruled saved-peek shape): the
    /// seeded lens lists, switching to it applies its pick as a sticky
    /// peek (zero store writes — viewing, never choosing), "the note"
    /// returns to truth, saving the current view mints a SPARSE lens,
    /// and ✓ adopt makes the view the note with the outgoing
    /// arrangement preserved as a lens of its own.
    @Test func theLensLessonSwitchesSavesAndAdopts() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "lenses") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let lenses = MobileLensesModel(session: session, postID: lesson, editor: model)
            let lighthouse = try #require(model.slots.first {
                $0.text == "The lighthouse keeps its own hours."
            })
            let chosenBefore = try #require(lighthouse.variantID)
            let storeBefore = try await storedBlockTexts(db, postID: lesson)

            // The seeded lens lists with its honest meta.
            await lenses.refresh()
            let row = try #require(lenses.rows.first { $0.name == "the other reading" })
            #expect(row.pickCount == 1 && row.unavailable == 0)

            // SWITCH: the lens's pick becomes a sticky peek.
            await lenses.activate(row.id)
            #expect(model.slot(for: lighthouse.blockID)?.text
                    == "The lighthouse answers to nobody's clock.")
            #expect(model.takes.isPeeking(lighthouse.blockID))
            #expect(lenses.chipLabel == "lens: the other reading")
            #expect(try await storedBlockTexts(db, postID: lesson) == storeBefore,
                    "a lens is viewing — the store is untouched")
            #expect(try await db.read { try chosenVariantID($0, blockID: lighthouse.blockID) }
                    == chosenBefore)

            // "the note" ends the session; the display is truth again.
            lenses.returnToNote()
            #expect(model.slot(for: lighthouse.blockID)?.text
                    == "The lighthouse keeps its own hours.")
            #expect(lenses.chipLabel == "lens")

            // Arrange by hand (the swipe), save the current view: a
            // SPARSE lens — exactly the one divergence — and you're in it.
            model.takes.flip(blockID: lighthouse.blockID, forward: true)
            #expect(await lenses.saveCurrentView(name: "my reading"))
            let saved = try #require(lenses.rows.first { $0.name == "my reading" })
            #expect(saved.pickCount == 1)
            #expect(lenses.activeLensName == "my reading")

            // ✓ ADOPT: the view becomes the note; the outgoing chosen is
            // preserved as a lens of its own; the peek and session end.
            await lenses.adoptView()
            #expect(try await db.read { try chosenVariantID($0, blockID: lighthouse.blockID) }
                    != chosenBefore)
            #expect(!model.takes.isPeeking(lighthouse.blockID))
            #expect(lenses.rows.contains { $0.name.hasPrefix("chosen until") },
                    "the old arrangement is kept — the road back visible")
            #expect(lenses.activeLensID == nil, "adopting ends the lens session")
        }
    }
}

// MARK: - structure (the taught flows, on the lessons' own blocks)

@MainActor
@Suite("Mobile tutorial walk — structure")
struct MobileTutorialStructureWalkTests {
    /// The divide lesson's staged cut, and merge as the road back.
    ///
    /// **Rewritten at 13u4 UNIT E3 to her ruling R-13u4-3.** It used to
    /// assert that a SENTENCE cut merged back to exactly the sentence you
    /// started with — the old single-space join's promise, and the lesson
    /// said so. The door join is the rendering newline now, so the road
    /// back returns the two halves as ONE block holding a line break: the
    /// blocks are back, the bytes are the sentence plus that break, and
    /// the lesson's own prose moved in the same commit.
    @Test func theDivideLessonCutsAndMergeIsTheRoadBack() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let before = try await storedBlockTexts(db, postID: lesson)
            let staged = try #require(model.slots.first {
                $0.text?.contains("This block holds two thoughts") == true
            })
            let stagedText = try #require(staged.text)
            let blockRange = try #require(model.rangeOfBlock(staged.blockID))
            let cut = blockRange.location + (try utf16Offset(of: "Put the cursor", in: stagedText))

            await model.structural.divide(atSurfaceCaret: cut)
            #expect(model.statusMessage == nil)
            let after = try await storedBlockTexts(db, postID: lesson)
            #expect(after.count == before.count + 1)
            #expect(after.contains("This block holds two thoughts and they deserve two blocks."))
            #expect(after.contains { $0.hasPrefix("Put the cursor") })

            // Merge is the road back — byte-exact.
            let successor = try #require(model.slots.first {
                $0.text?.hasPrefix("Put the cursor") == true
            })
            let successorRange = try #require(model.rangeOfBlock(successor.blockID))
            await model.structural.mergeWithPrevious(
                atSurfaceCaret: successorRange.location + 2)
            #expect(model.statusMessage == nil)
            let roundTripped = try await storedBlockTexts(db, postID: lesson)
            #expect(roundTripped.count == before.count, "the block count is back")
            let stagedIndex = try #require(before.firstIndex(of: stagedText))
            // Merge is the road back — the halves rejoin, the cut leaving
            // the line break her ruling asked for.
            #expect(
                roundTripped[stagedIndex]
                    == stagedText.replacingOccurrences(
                        of: ". Put the cursor", with: ".\nPut the cursor"))
        }
    }

    /// The fanned-divide lesson: swipe to the take you want cut, then
    /// divide — the PEEKED take is cut in two, every other take rides
    /// whole onto BOTH successors, and the original keeps everything
    /// off-stage (Q-M2, her duplicate shape, on the lesson's own ferry).
    ///
    /// **KNOWN ISSUE (13u1 ladder round 1 — `KnownIssuesAndTechDebt.md`'s
    /// row, owner the mobile project): the phone's tutorial still TEACHES
    /// the retired duplicate-divide default.** Her U-2 (2026-09-06) made a
    /// fanned divide KEEP-ON-TOP on both platforms and 18c flipped the
    /// phone's behaviour in lockstep — but this lesson's prose was never
    /// rewritten, so the pin, which drives the lesson's own gesture and
    /// asserts the shape the LESSON promises, fails against the app the
    /// lesson no longer describes. The pin is doing its job; the lesson and
    /// the pin come right TOGETHER at the mobile project's rewrite, which
    /// removes this wrapper. Wrapped rather than left red so the suite's
    /// green signal stays meaningful (the suite's standing pattern), and
    /// wrapped WHOLE knowingly: until the rewrite, anything else this body
    /// would catch is muted with it — re-exposed the day the wrapper goes.
    /// If the wrapper itself ever fails ("issue did not occur"), the app has
    /// regressed BACK to the duplicate shape: that is the tripwire, loud.
    @Test func theFannedDivideLessonLandsTheDuplicateShape() async throws {
        try await withKnownIssue(
            "the phone's tutorial teaches the retired duplicate-divide default — KnownIssuesAndTechDebt row (owner: the mobile project); the lesson's rewrite fixes prose + pin and removes this wrapper"
        ) {
            try await Self.fannedDivideLessonDuplicateShapeBody()
        }
    }

    private static func fannedDivideLessonDuplicateShapeBody() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide with takes") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let before = try await storedBlockTexts(db, postID: lesson)
            let ferry = try #require(model.slots.first {
                $0.text?.contains("The ferry crossed at dawn") == true
            })
            let ferryText = try #require(ferry.text)

            // Swipe to the take to cut (the lesson's own instruction).
            model.takes.flip(blockID: ferry.blockID, forward: true)
            let peeked = try #require(model.slot(for: ferry.blockID)?.text)
            #expect(peeked.contains("At dawn the ferry crossed"))

            let blockRange = try #require(model.rangeOfBlock(ferry.blockID))
            let cut = blockRange.location + (try utf16Offset(of: "The storm stayed", in: peeked))
            await model.structural.divide(atSurfaceCaret: cut)
            #expect(model.statusMessage == nil)

            // The halves lead the successors — the peeked take was cut.
            let after = try await storedBlockTexts(db, postID: lesson)
            #expect(after.count == before.count + 1)
            #expect(after.contains("At dawn the ferry crossed."))
            #expect(after.contains {
                $0.hasPrefix("The storm stayed in everyone's coat pockets")
            })

            // Every other take rode whole onto BOTH successors.
            let successors = model.slots.filter { $0.blockID != ferry.blockID }
                .filter { slot in
                    slot.text == "At dawn the ferry crossed."
                        || slot.text?.hasPrefix("The storm stayed") == true
                }
            #expect(successors.count == 2)
            for slot in successors {
                #expect(try await db.read { try fanCount($0, blockID: slot.blockID) } == 2,
                        "each successor carries its cut half plus the duplicate")
                let texts = try await db.read { [id = slot.blockID] db in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT working_text FROM variant
                            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                            ORDER BY fan_position, id
                            """,
                        arguments: [id])
                }
                #expect(texts.contains(ferryText),
                        "the un-cut take rides along whole — nothing needs a matching cut")
            }

            // The original keeps everything, off-stage, in lineage.
            let ferryPlacements = try await db.read { [id = ferry.blockID] db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [id]) ?? -1
            }
            #expect(ferryPlacements == 0, "released, not destroyed")
            #expect(try await db.read { try fanCount($0, blockID: ferry.blockID) } == 2,
                    "the original block keeps both takes in lineage")
        }
    }

    /// The merge lesson: the staged neighbors join with the rendering
    /// join (R-13u4-3; it was a single space until 13u4 UNIT E3, and the
    /// lesson's prose moved with it), byte-exact — and merging the fanned tail CARRIES the spare take
    /// along whole (parity C5's ruled carry-all: the two displayed takes
    /// join; every other take rides onto the merged block), exactly as
    /// the prose promises. The tail's text and its spare take are the
    /// lesson's STAGED cursor-instruction material (PB1-3's sanctioned
    /// coupling class — the seeder names this walk beside them).
    @Test func theMergeLessonJoinsExactlyAndAFanRidesAlong() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            let first = try #require(model.slots.first {
                $0.text == "These two short blocks are really one thought."
            })
            let second = try #require(model.slots.first {
                $0.text?.hasPrefix("They have been waiting") == true
            })
            _ = first
            let secondRange = try #require(model.rangeOfBlock(second.blockID))

            await model.structural.mergeWithPrevious(atSurfaceCaret: secondRange.location + 2)
            #expect(model.statusMessage == nil)
            let joined = try await storedBlockTexts(db, postID: lesson)
            #expect(joined.contains(
                "These two short blocks are really one thought.\n"
                + "They have been waiting for a merge since the day they were seeded."),
                "one newline at the seam — nothing else invented")

            // The fanned tail: the spare take rides the merge whole.
            let countBefore = joined.count
            let tailText = "This block has a spare take, so a merge here carries it "
                + "along whole."
            let spareText = "the spare take that rides the merge whole."
            let tail = try #require(model.slots.first { $0.text == tailText })
            let spareID = try await db.read { [id = tail.blockID] db -> String? in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL
                          AND status = 'active' AND working_text = ?
                        """,
                    arguments: [id, spareText])
            }
            let tailRange = try #require(model.rangeOfBlock(tail.blockID))
            await model.structural.mergeWithPrevious(atSurfaceCaret: tailRange.location + 2)

            #expect(model.statusMessage == nil,
                    "the carry-all merges — no refusal, no redirect")
            let after = try await storedBlockTexts(db, postID: lesson)
            #expect(after.count == countBefore - 1, "two blocks became one")
            let mergedText = try #require(
                after.first { $0.hasSuffix("\n" + tailText) },
                "the displayed takes joined with the canon rendering join")
            // The merged block wears BOTH takes: the joined text chosen,
            // the spare take riding whole behind it as a FRESH row (the
            // source keeps its original in lineage).
            let mergedBlockID = try #require(try await db.read { db -> String? in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT cb.block_id FROM container_block cb
                        JOIN variant v ON v.id = cb.chosen_variant_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.working_text = ?
                        """,
                    arguments: [lesson, mergedText])
            }, "the merged block's chosen is the joined text")
            let mergedFan = try await db.read { db -> [(id: String, text: String)] in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT id, working_text FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL
                          AND status = 'active'
                        ORDER BY fan_position, id
                        """,
                    arguments: [mergedBlockID]
                ).map { (id: $0["id"], text: $0["working_text"]) }
            }
            #expect(mergedFan.map(\.text) == [mergedText, spareText],
                    "pairing first, the carried take whole behind it")
            #expect(mergedFan.last?.id != spareID,
                    "the carry is a fresh row; the source keeps its original")
            // The released source stays live in lineage with its own fan.
            let sourceFanCount = try await db.read { [id = tail.blockID] db in
                try fanCount(db, blockID: id)
            }
            #expect(sourceFanCount == 2,
                    "the released source keeps both takes in lineage")
        }
    }
}

// MARK: - the library of things (shelf · book · library · seal · furniture · voice)

@MainActor
@Suite("Mobile tutorial walk — the library of things")
struct MobileTutorialLibraryWalkTests {
    /// The shelf's promise: the pinned guide sits first, wearing LK5's
    /// faces (note count + the tag's leaf).
    @Test func theShelfShowsThePinnedGuideFirstWithItsFaces() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            // A rival book, unpinned — pin order must beat name order.
            _ = try await session.runner.run { ops in
                try ops.createReading(name: "a rival almanac", kind: .book)
            }
            let shelf = MobileShelfViewModel(session: session)
            let observation = Task { await shelf.start() }
            defer { observation.cancel() }
            await poll { shelf.books.count >= 2 }
            await shelf.refreshTags()

            let ordered = shelf.orderedBooks
            #expect(ordered.first?.reading.id == bookID,
                    "pinned books always sit first — the guide leads the shelf")
            let guide = try #require(ordered.first)
            #expect(shelf.rowName(for: guide) == MobileTutorialSeeder.bookName)
            #expect(shelf.rowMeta(for: guide)
                    == "\(MobileTutorialSeeder.plan.flatMap(\.lessons).count) notes"
                    + " · #\(MobileTutorialSeeder.tagName)",
                    "LK5's faces: note count + the tag's leaf")
        }
    }

    /// The getting-around promise: a book opens into its CONTENTS
    /// (chapters grouped in book order), and read — the door — assembles
    /// the same book as the calm continuous page.
    @Test func theBookOpensContentsFirstAndReadAssemblesTheChapters() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let book = MobileBookViewModel(session: session, readingID: bookID)
            let observation = Task { await book.start() }
            defer { observation.cancel() }
            let lessonCount = MobileTutorialSeeder.plan.flatMap(\.lessons).count
            await poll { book.entries.count == lessonCount }

            #expect(book.groupedRows.map(\.section)
                    == MobileTutorialSeeder.plan.map(\.chapter),
                    "the contents list groups by the book's own chapters")
            #expect(MobileBookView.readDoorTitle == "Read", "read is the door (P35)")

            // The Read flow's assembly: the same chapters, the page meta.
            let chapters = MobileReadPage.assemble(book.groupedRows)
            // DERIVED from the plan, not transcribed from it (13p Batch 4):
            // the caption list used to be a hand-copied literal, so ADDING a
            // chapter — the privacy chapter did exactly this — failed a test
            // whose subject is the ASSEMBLY, not the table of contents. What
            // this pins is that Read captions every chapter, in book order,
            // in the ratified LK9 frame; the format itself keeps one literal
            // anchor below so a change to the frame still trips.
            #expect(chapters.map(\.caption)
                    == MobileTutorialSeeder.plan.enumerated().map { index, chapter in
                        "\(MobileReadPage.roman(index + 1).uppercased()) · "
                        + chapter.chapter.uppercased()
                    })
            #expect(chapters.first?.caption == "I · WELCOME", "the LK9 frame itself")
            let slots = chapters.flatMap(\.notes)
            #expect(slots.count == lessonCount)
            #expect(slots.map(\.ordinal) == Array(1...lessonCount))
            let last = try #require(slots.last)
            #expect(MobileReadPage.pageMeta(
                ordinal: last.ordinal, total: book.entries.count,
                chapterIndex: last.chapterIndex)
                == "note \(lessonCount) of \(lessonCount) · "
                + MobileReadPage.roman(MobileTutorialSeeder.plan.count))
        }
    }

    /// The Library's promise: everything is listed, search finds a
    /// lesson by its title, and the bookless filter — the pool — holds
    /// the loose practice note (and no lesson).
    @Test func theLibraryFindsTheGuideAndThePoolHoldsTheLooseNote() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let looseID = try #require(try await db.read { db -> String? in
                try String.fetchOne(
                    db,
                    sql: "SELECT id FROM container WHERE title = ? AND deleted_at IS NULL",
                    arguments: [MobileTutorialSeeder.looseNoteTitle])
            })
            let aLesson = try await db.read { try lessonID($0, bookID: bookID, "getting around") }

            let library = MobileLibraryViewModel(session: session)
            let listing = Task { await library.startAll() }
            defer { listing.cancel() }
            await poll { library.all.contains { $0.postID == aLesson } }
            #expect(library.all.contains { $0.postID == looseID })

            // Search finds the lesson by its title; the hit navigates to
            // the note.
            await library.search("getting around")
            let hit = try #require(library.hits?.first { $0.kind == .post && $0.id == aLesson })
            #expect(MobileLibraryViewModel.destination(for: hit)
                    == .note(aLesson, focus: false))

            // The bookless filter is the pool: the loose note waits
            // there; the shelved lessons never do.
            let bookless = Task { await library.startBookless() }
            defer { bookless.cancel() }
            await poll { library.bookless.contains { $0.postID == looseID } }
            #expect(library.bookless.contains { $0.postID == looseID },
                    "the loose practice note waits in the pool")
            #expect(!library.bookless.contains { $0.postID == aLesson },
                    "a lesson lives in the book, not the pool")
        }
    }

    /// The seal lesson's show-and-tell: typing and dividing refuse OUT
    /// LOUD; the unlock door opens the note; resealing quietly keeps a
    /// savepoint of the unsaved take first.
    @Test func theSealLessonRefusesOutLoudThenUnlocksAndReseals() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the seal") }
            let (model, _) = await makeLessonSurface(session, postID: lesson)
            #expect(model.isSealed, "the lesson ships sealed")

            // Typing refuses out loud (the gate's own answer).
            #expect(!model.shouldChangeText(
                in: NSRange(location: 0, length: 0), replacement: "x"))
            #expect(model.statusMessage == "This note is locked — unlock it to edit.")
            model.report(nil)

            // Dividing refuses out loud (the structural door's answer).
            await model.structural.divide(atSurfaceCaret: 5)
            #expect(model.statusMessage == "This note is locked — unlock it to restructure.")
            model.report(nil)

            // Unlock — the masthead's door — and the note opens.
            await model.unlockNote()
            #expect(!model.isSealed)
            let first = try #require(model.slots.first)
            let variantID = try #require(first.variantID)
            let reworded = "This note was SEALED a moment ago — you unlocked it."
            try await session.runner.run { ops in
                try ops.autosave(variantID, text: reworded, charDelta: 12)
            }

            // Reseal: the guard insures exactly what it protects — the
            // unsaved take gets a quiet savepoint.
            await model.lockNote()
            #expect(model.isSealed, "sealed again — one tap each way")
            let insured = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND text = ?",
                    arguments: [variantID, reworded]) ?? 0
            }
            #expect(insured == 1, "sealing quietly kept a savepoint of the unsaved take")
        }
    }

    /// The comments-and-callouts lesson renders its staged furniture on
    /// its own page — the ●1 mark, the callout frame — and the comments
    /// sheet's verbs work right there.
    @Test func theFurnitureLessonRendersItsMarkAndFrame() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "comments & callouts")
            }
            let (model, surface) = await makeLessonSurface(session, postID: lesson)
            let view = surface.textView
            let commented = try #require(model.slots.first)
            let callout = model.slots[1]

            #expect(model.slot(for: commented.blockID)?.commentCount == 1,
                    "the staged comment counts")
            surface.layoutIfNeeded()
            view.refreshChrome()
            let mark = try #require(
                view.blockDecor?.commentMark(for: commented.blockID) as? UIButton)
            #expect(mark.title(for: .normal) == "●1", "the ●1 at the block's edge")
            #expect(view.blockDecor?.frameView(for: callout.blockID) != nil,
                    "the callout wears its frame")
            #expect(model.presentations[callout.blockID]?.color == "blue")

            // The sheet's verbs, on the lesson's own block.
            model.openComments(blockID: commented.blockID)
            await poll { !model.comments.comments.isEmpty }
            #expect(model.comments.comments.first?.text.contains("a comment lives beside")
                    == true)
            await model.comments.add("a second working note, added by the walk")
            #expect(model.comments.comments.count == 2)
            model.comments.close()
        }
    }

    /// The voice-switch lesson's promise, on its own text: the switch
    /// restyles every face and touches no bytes.
    @Test func theVoiceSwitchLessonRestylesWithoutTouchingBytes() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the voice switch") }
            let (model, storage) = makeEditor(session, postID: lesson)
            await model.loadOnce()
            let bytes = storage.string
            #expect(bytes.contains("two voices"))
            let proseAt = (bytes as NSString).range(of: "voices").location

            let terminalFont = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(terminalFont?.fontDescriptor.symbolicTraits.contains(.traitMonoSpace) == true)

            MobileEditorStyle.voice = .study
            defer { MobileEditorStyle.voice = .terminal }
            model.applyVoiceChange()
            #expect(storage.string == bytes, "the switch touches no text at all")
            let studyFont = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(studyFont?.familyName == "Iowan Old Style", "study is serif and bookish")

            MobileEditorStyle.voice = .terminal
            model.applyVoiceChange()
            #expect(storage.string == bytes)
            let backFont = storage.attribute(.font, at: proseAt, effectiveRange: nil) as? UIFont
            #expect(backFont?.fontDescriptor.symbolicTraits.contains(.traitMonoSpace) == true)
        }
    }
}

// MARK: - keeping it private (the phone's privacy lesson — 13p, knot 6)

/// **THE PHONE'S PRIVACY LESSON SAYS WHAT THE PHONE'S SETTINGS SAY.**
///
/// Her knot-6 ruling asked the tutorial to make the settings options clear
/// and to state honestly what it would take to lose the writing. The Mac's
/// field guide got a two-lesson chapter; the pocket guide gets ONE lesson,
/// because the phone's Protection screen already states the per-mode
/// sentence, the chain and the one-device fact live — the lesson's job is to
/// send a reader there knowing what they will find.
///
/// It exists on the phone AT ALL because of her Batch-1 rider — *"some
/// people will be mobile only users"*: a phone-only reader never opens the
/// Mac's field guide, so a teaching that lived only there would not reach
/// them. Same anti-drift discipline as the Mac's suite: the prose names the
/// app's own words (`ProtectionCopy`), so a re-worded sentence makes this red
/// rather than merely stale.
@MainActor
@Suite("Mobile tutorial walk — keeping it private")
struct MobilePocketGuidePrivacyTests {
    /// The two-register rule (copy §7b's head; design §1.22) — the Mac's
    /// twin reads the same list.
    static var forbiddenRegisterWords: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }

    @Test func theChapterIsOneLessonAtTheEnd() {
        #expect(MobileTutorialSeeder.plan.last?.chapter == "keeping it private")
        #expect(MobileTutorialSeeder.plan.last?.lessons == [ProtectionCopy.privacyLessonOneTitle])
    }

    /// pre-13x 5a — RENDER, DON'T RE-DERIVE: the phone's one lesson carries
    /// BOTH of copy §7's lessons' paragraphs verbatim in the phone's nouns,
    /// and says what the copy's parenthetical promises: both modes, both
    /// floors, keystone 3, keystone 4, and the book's door.
    @Test func theLessonRendersCopySevenInThePhonesNouns() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, ProtectionCopy.privacyLessonOneTitle))
            }
            for paragraph in ProtectionCopy.privacyLessonOneParagraphs + ProtectionCopy.privacyLessonTwoParagraphs {
                #expect(prose.contains(paragraph), "the lesson carries the copy's paragraph verbatim")
            }
            #expect(prose.contains(ProtectionCopy.keystoneAccountPassword))
            #expect(prose.lowercased().contains(ProtectionCopy.keystoneOpenMeansReadable.lowercased()))
            // (VX-329 U1: the posture names and the two floor sentences came from today's copy, deleted with today's
            // road; the floors still ride the lesson inside copy §7's paragraphs, pinned verbatim above — the chapter's
            // rewrite for the road is VM-8's, the U1 record's F-U1-5.)
            // 13s-b U1b (R-13s-37): the book's-door arm inverts — the
            // pointer paragraph retired with the book's seed and doors.
            #expect(!prose.contains(SampleLibraryEncryptionBook.name),
                    "the retired pointer stays gone")
            // The phone's nouns, and nothing names the Mac (the no-redirect
            // principle — a phone-only reader's whole story).
            #expect(prose.contains("Face ID opens this iPhone for you"))
            #expect(prose.contains("at your unlocked iPhone"))
            #expect(!prose.contains("Mac") && !prose.contains("Touch ID"))
            #expect(!prose.contains("no old passphrase needed"), "the retired reset road is gone")
            #expect(!prose.contains(Self.forbiddenRegisterWords))
        }
    }
}

// MARK: - 13i-d F-U2-1: the seed survives a full star cap

/// 13i-d U2's union star routed the public `setShelfPinned` through the
/// capped star write, which made the seeder's guide-leads-the-shelf star
/// able to ABORT a restore mid-seed with the cap full — a regression on
/// the phone's Restore Tutorial road (F-U2-1). The architect's ruled fix:
/// the star is a nicety; with the cap full the guide seeds UNSTARRED and
/// the restore completes whole. RED ON OLD: on the pre-fix seeder this
/// restore throws `starLimitReached` and the test fails at the `#require`.
@Suite("Mobile tutorial seed under a full star cap (13i-d F-U2-1)")
struct MobileTutorialStarCapTests {
    @Test func restoreCompletesUnstarredWhenTheCapIsFull() async throws {
        try await withPocketGuideWorld { session, db, bookID in
            // Free the guide's own star, then fill the cap exactly with
            // her notes — the next book star must refuse.
            try await session.runner.run { ops in
                try ops.setShelfPinned(bookID, pinned: false)
                for i in 0..<Operations.starLimit {
                    let post = try ops.createPost(title: "starred note \(i)")
                    try ops.setStarred(.post(post.id), starred: true)
                }
            }

            let freshBookID = try await MobileTutorialSeeder.restore(session: session)

            let (fresh, lessonCount, noteStars) = try await db.read { db -> (Reading?, Int, Int) in
                let fresh = try Queries.reading(db, id: freshBookID)
                let lessons = try Queries.assembleReading(db, readingID: freshBookID).count
                let stars = try Queries.starred(db).count
                return (fresh, lessons, stars)
            }
            let guide = try #require(fresh, "the restore completed and the guide stands")
            #expect(guide.starred == false, "the guide seeded unstarred, not failed")
            #expect(lessonCount == MobileTutorialSeeder.plan.flatMap(\.lessons).count,
                    "the seed ran WHOLE past the refused star")
            #expect(noteStars == Operations.starLimit, "her 15 note stars are untouched")
        }
    }
}

// MARK: - keeping & letting go (PR22 — the deletion chapter, batch 6b)

/// **THE FIVE-PLACES MAP, RE-TAUGHT IN PHONE GRAMMAR** (round 2, batch 6b —
/// §69.8). The Mac's field guide teaches the same map, the two sizes of
/// moment, and the TWO EXITS by doing; its text names Mac doors and chords,
/// so the pocket guide re-teaches rather than copying (MobileSoul §4.4).
///
/// Same anti-drift discipline as the privacy suite: the prose names the app's
/// OWN words where it can (`TrashWindow.days`, the tray's segment words), so
/// a re-worded door makes this red rather than merely stale.
@MainActor
@Suite("Mobile tutorial walk — keeping & letting go")
struct MobilePocketGuideDeletionTests {
    @Test func theChapterSitsBeforePrivacyAndCarriesTwoLessons() {
        let index = try? #require(
            MobileTutorialSeeder.plan.firstIndex { $0.chapter == "keeping & letting go" })
        let privacy = MobileTutorialSeeder.plan.firstIndex {
            $0.chapter == "keeping it private"
        }
        #expect(index != nil)
        if let index, let privacy { #expect(index < privacy) }
        #expect(MobileTutorialSeeder.plan.first {
            $0.chapter == "keeping & letting go"
        }?.lessons == ["the five places", "the two exits"])
    }

    /// All five places are named, each with the phone road that reaches it —
    /// and the take's own paragraph, which is the one thing the Trash never
    /// holds (her D1 ruling).
    @Test func theFivePlacesLessonNamesEveryPlaceAndItsPhoneRoad() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, "the five places"))
            }
            // 1–5, each by name.
            #expect(prose.contains("WHERE YOU LEFT IT"))
            #expect(prose.contains("ARCHIVED"))
            #expect(prose.contains("THE TRASH"))
            #expect(prose.contains("THIS NOTE'S VERSIONS"))
            #expect(prose.contains("THIS BLOCK'S HISTORY"))
            // The roads, in the phone's own words.
            #expect(prose.contains(MobileBlocksSegment.archived.word))
            #expect(prose.contains(MobileBlocksSegment.leaving.word))
            #expect(prose.contains(MobileBlockMenuController.archiveTitle))
            // **THE ROAD, not merely the FACE'S NAME** (batch 9's fix
            // wave, cold-review MAJOR 2). This line used to read
            // `prose.contains(BlockHistoryPath.name)` — the face's name —
            // so the navigation sentence could be arbitrarily wrong and
            // the pin stayed green. It WAS wrong: batch 9 moved the door
            // off the block ⋯ onto each take's own ⋯, and this lesson —
            // the guide's ONLY road to the came-from and deleted-takes
            // regions — went on teaching the retired one, in a store that
            // ships. So the pin now asserts the road that EXISTS and
            // refuses the road that does not.
            #expect(prose.contains(MobileTakesBrowserController.historyTitle))
            #expect(prose.contains("⑂ on the bottom bar"),
                    "the takes road, in the phone's own glyph")
            #expect(!prose.contains("⋯ on the bottom bar, then \(BlockHistoryPath.name)"),
                    "the retired block-⋯ road must not be taught")
            #expect(prose.contains(RecoveryCopy.putBackVerb))
            #expect(prose.contains(RecoveryCopy.deleteNowVerb))
            #expect(prose.contains("\(TrashWindow.days) days"))
            // The take's exception — the one thing the Trash never holds.
            #expect(prose.contains("TAKES are the one thing that never rows in the Trash"))
            // The no-redirect principle: no Mac door, no chord.
            #expect(!prose.contains("Mac"))
            #expect(!prose.contains("⌘"))
        }
    }

    /// The two exits, told apart — and the lesson ASKS her to do both, which
    /// is the guide's own device (every lesson performs what it teaches).
    @Test func theTwoExitsLessonTellsDeletionFromTransformationAndStagesBoth()
        async throws
    {
        try await withPocketGuideWorld { _, db, bookID in
            let noteID = try await db.read { db in
                try lessonID(db, bookID: bookID, "the two exits")
            }
            let prose = try await db.read { db in
                try Queries.renderedText(db, containerID: noteID)
            }
            #expect(prose.contains("DELETION GOES TO THE TRASH"))
            #expect(prose.contains("TRANSFORMATION GOES TO LINEAGE"))
            // The distinction that matters: a transformed original is NOT
            // deleted, so it wears no countdown.
            #expect(prose.contains("kept WHOLE and set aside"))
            #expect(prose.contains("wears no countdown"))
            #expect(prose.contains(BlockHistoryPath.cameFromSection))
            #expect(prose.contains(BlockHistoryPath.bringBackVerb))
            #expect(prose.contains(MobileBlocksSegment.leaving.word))
            #expect(!prose.contains("Mac"))

            // The staged block the lesson asks her to act on — and its take,
            // so the divide it teaches is the fanned kind whose original is
            // exactly what "Came from" holds.
            let blocks = try await db.read { db in
                try Queries.blockTOC(db, post: noteID)
            }
            let last = try #require(blocks.last)
            #expect(last.hasFan, "the practice block carries a take")
            #expect(last.text?.contains("Delete me") == true)
        }
    }

    /// **THE BATCH-5 REVIEW'S GUIDE NIT, CLOSED** (its own words: *"the
    /// pocket guide now describes a shelf that does not exist"*). The
    /// "getting around" lesson described a full-width Today's Entry door
    /// batch 5 had replaced with a BADGE, and `grep` found no mention of the
    /// quick-note box anywhere in the seeder — the surface that batch made
    /// half the shelf.
    @Test func theShelfLessonDescribesTheShelfThatExists() async throws {
        try await withPocketGuideWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, "getting around"))
            }
            // The badge, in the ONE declaration's own words (a re-word of
            // the door reds this rather than leaving it stale).
            #expect(prose.contains(MobileShelfFaces.todayDoorTitle))
            #expect(prose.contains("badge"))
            // …and its fallback state, which is a real road she can meet.
            #expect(prose.contains("its own row at the list's end"))
            // The quick-note box, which had no mention at all.
            #expect(prose.contains("QUICK NOTE box"))
            #expect(prose.contains("just start typing"))
            #expect(prose.contains("open ↵"))
            // The retired shape is gone.
            #expect(!prose.contains("✎ Today's Entry opens today's journal page"))
        }
    }
}
