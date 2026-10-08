//
//  TutorialWalkTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 2 (R113/P-6): THE TUTORIAL IS THE EXECUTABLE SPEC.
//  For every lesson of "the field guide", these tests execute the acts the
//  lesson's prose asks the reader to perform — headlessly, through the
//  same registry/operations doors the app's own surfaces route — against
//  freshly-seeded tutorial content, and assert the STORE outcomes the
//  prose promises. Green forever after: a change that breaks a tutorial
//  step is a regression by definition. The scripted screenshot walk is the
//  visual half.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The seeded world

@MainActor
private func withTutorialWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ bookID: String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // RUN A batch A2, row 8: the seeded-book marks are INJECTED — the
        // test host IS `io.lduarte.Variorum.debug`, and the tutorial door's
        // ensure both reads and (since row 8) writes this device's per-book
        // mark. A headless spine run must never decide by, or leave anything
        // in, the dev store's own defaults (the row-42 class).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        let bookID = try await TutorialSeeder.restore(session: session)
        return try await body(session, db, bookID)
    }
}

@MainActor
private func poll(
    _ condition: @MainActor () -> Bool, turns: Int = 400
) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// A lesson post's id by its exact title (the seeded titles are the plan's).
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
        throw TutorialWalkError.missingLesson(title)
    }
    return id
}

private enum TutorialWalkError: Error {
    case missingLesson(String)
    case missingStagedContent(String)
}

/// One user post's whole subtree, byte-for-byte (NIT-5: the wholesale pin
/// used to compare ONE container row — now its placements, blocks, and
/// variants ride the comparison too).
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

@MainActor
private func slots(_ db: AppDatabase, _ postID: String) async throws -> [Queries.RenderedBlock] {
    try await db.read { try Queries.renderPost($0, containerID: postID) }
}

@MainActor
private func projection(
    _ db: AppDatabase, _ postID: String
) async throws -> Queries.TakesProjection {
    try await db.read { try Queries.takesProjection($0, post: postID) }
}

private func utf16Offset(of needle: String, in text: String) throws -> Int {
    let range = (text as NSString).range(of: needle)
    guard range.location != NSNotFound else {
        throw TutorialWalkError.missingStagedContent(needle)
    }
    return range.location
}

// MARK: - The book itself (seed shape + the plan contract)

@MainActor
@Suite("Tutorial book shape (13b Stage 2, R113)")
struct TutorialBookShapeTests {
    @Test func theSeededBookMatchesTheLessonPlanExactly() async throws {
        try await withTutorialWorld { _, db, bookID in
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
            #expect(chapters == TutorialSeeder.plan.map(\.chapter))

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
            let planned = TutorialSeeder.plan.flatMap { chapter, lessons in
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
        // R57's class: journal-shaped rows are the daily Journal's assembly —
        // tutorial text must be structurally invisible to it (the rule's
        // original reason, the Fragments bridge's day sweep, retired
        // 2026-09-04; the rule stays).
        try await withTutorialWorld { _, db, _ in
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

    @Test func everyLessonWearsTheTutorialTagAndTheBookWearsItsFaces() async throws {
        try await withTutorialWorld { _, db, bookID in
            let (taggedIDs, lessonIDs, reading) = try await db.read { db -> (Set<String>, Set<String>, Reading?) in
                let tag = try Queries.allTags(db).first { $0.path == TutorialSeeder.tagName }
                let tagged = try tag.map {
                    Set(try Queries.everythingTagged(db, tagID: $0.id, includeSubtree: true).postIDs)
                } ?? []
                let lessons = Set(try String.fetchAll(
                    db,
                    sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [bookID]))
                return (tagged, lessons, try Queries.reading(db, id: bookID))
            }
            #expect(lessonIDs.isSubset(of: taggedIDs),
                    "the tag IS the restore identity — every lesson wears it")
            #expect(reading?.kind == .book)
            #expect(reading?.wordTarget == 4000, "the books lesson's extent face is real")
        }
    }

    @Test func actReadyStagingIsInPlace() async throws {
        try await withTutorialWorld { _, db, bookID in
            // The four-take fan (choosing & the board).
            let choosing = try await db.read { try lessonID($0, bookID: bookID, "choosing & the board") }
            let choosingProjection = try await projection(db, choosing)
            let rainBlock = try #require(choosingProjection.slots.first {
                $0.text?.contains("The rain came in from the sea") == true
            })
            #expect(choosingProjection.fans[rainBlock.blockID]?.count == 4,
                    "the paged-rail lesson has four takes to page")

            // The ceremony's three takes.
            let ceremony = try await db.read { try lessonID($0, bookID: bookID, "divide choosing takes") }
            let ceremonyProjection = try await projection(db, ceremony)
            let ferry = try #require(ceremonyProjection.slots.first {
                $0.text?.contains("The ferry crossed at dawn") == true
            })
            #expect(ceremonyProjection.fans[ferry.blockID]?.count == 3)

            // The sealed lesson is sealed.
            let sealed = try await db.read { try lessonID($0, bookID: bookID, "the seal") }
            let sealedHeader = try await db.read { try Queries.containerHeader($0, containerID: sealed) }
            #expect(sealedHeader?.locked == true, "the seal lesson ships sealed")

            // The named block + callout (shaping blocks).
            let shaping = try await db.read { try lessonID($0, bookID: bookID, "shaping blocks") }
            let toc = try await db.read { try Queries.blockTOC($0, post: shaping) }
            #expect(toc.contains { $0.name == "the named block" })
            let calloutJSON = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT b.presentation FROM block b
                        JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                        WHERE cb.container_id = ? AND b.presentation IS NOT NULL
                        """,
                    arguments: [shaping])
            }
            let presentation = BlockPresentation.decode(calloutJSON)
            #expect(presentation?.kind == BlockPresentation.calloutKind)
            #expect(presentation?.color == "blue")

            // The lens beside the lenses lesson.
            let lenses = try await db.read { try lessonID($0, bookID: bookID, "lenses") }
            let lensProjection = try await projection(db, lenses)
            #expect(lensProjection.lenses.contains { $0.name == "the other reading" })

            // The comment on the comments lesson.
            let comments = try await db.read { try lessonID($0, bookID: bookID, "comments & tags") }
            let commentSlots = try await slots(db, comments)
            let commentRows = try await db.read { db in
                try Queries.blockComments(db, blockID: commentSlots[0].blockID)
            }
            #expect(commentRows.count == 1, "the margin comment is staged")

            // The scrap pool with a fanned second scrap.
            let scrapCounts = try await db.read { db -> [Int] in
                guard let pool = try Queries.pools(db).first(
                    where: { $0.title == TutorialSeeder.scrapPoolTitle })
                else { return [] }
                return try Queries.renderPost(db, containerID: pool.id).map { slot in
                    try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM variant
                            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                            """,
                        arguments: [slot.blockID]) ?? 0
                }
            }
            #expect(scrapCounts == [1, 2], "two scraps, the second fanned for the ⌥-drag lesson")

            // The version twin (compare & versions).
            let versions = try await db.read { try lessonID($0, bookID: bookID, "compare & versions") }
            let versionSlots = try await slots(db, versions)
            let peers = try await db.read { try Queries.versionPeers($0, of: versionSlots[0].blockID) }
            #expect(!peers.isEmpty, "the compare lesson ships with a linked twin")
        }
    }

    /// **The formatting lesson demonstrates itself** (13g L12). Its prose is
    /// written IN the vocabulary it teaches — which under F-1 means the
    /// lesson's stored text literally IS the syntax the reader is shown — and
    /// the last paragraph sends her to Read, so the pin follows her there:
    /// the same text, rendered for reading, carries no markers at all.
    @Test func theFormattingLessonIsWrittenInTheVocabularyItTeaches() async throws {
        try await withTutorialWorld { _, db, bookID in
            let formatting = try await db.read {
                try lessonID($0, bookID: bookID, "formatting")
            }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: formatting)
            }
            for syntax in ["**markdown**", "*italic*", "~~struck out~~", "`inline code`",
                           "## Headings are sizes", "- Lists are lines", "- [ ] And a checkbox",
                           "- [x] CLICK the box", "[like this](https://apple.com)"] {
                #expect(stored.contains(syntax), "the lesson shows \(syntax) by BEING it")
            }

            // …and Read shows her the other face (F-5's surface rule). The
            // assertions name the SPANS rather than the characters, because
            // a lesson ABOUT markdown also talks about markers in prose
            // ("a line that starts with #, ## or ###"), and those are
            // ordinary words the transform must leave exactly alone.
            let rendered = MarkdownRendering.render(stored)
            for span in ["**markdown**", "*italic*", "~~struck out~~", "`inline code`",
                         "## Headings are sizes", "- [ ] And a checkbox",
                         "[like this](https://apple.com)"] {
                #expect(!rendered.text.contains(span), "Read hides \(span.debugDescription)")
            }
            #expect(rendered.text.contains("Headings are sizes"))
            #expect(rendered.text.contains("\u{2022} Lists are lines"))
            #expect(rendered.text.contains("\u{2610} And a checkbox"))
            #expect(rendered.text.contains("\u{2611} CLICK the box"))
            #expect(rendered.links.contains { $0.url == "https://apple.com" })
        }
    }

    /// 13g cold review R1-2: **the workspace lesson teaches where a quick
    /// note actually lands.** Batch 7 (R6-4) filed quick notes under the
    /// `quicknote` tag into the smart Quicknotes book — and out of the Pool
    /// (`poolPosts` excludes smart-collected notes, 13f Stage B) — but the
    /// lesson batch 1 seeded kept teaching "…kept as a note in the Pool":
    /// the WT-1 drift class, in the very lesson WT-1 minted, and in prose
    /// the shortcut drift guard cannot see.
    ///
    /// DISCRIMINATING REVERT (verified): restore the lesson's pre-fix
    /// sentence — this fails on the "Quicknotes" expectation while the
    /// seeder's plan==seed walk stays green (only body text moved).
    /// Restored, checksum-matched.
    @Test func theWorkspaceLessonTeachesTheQuicknotesLanding() async throws {
        try await withTutorialWorld { _, db, bookID in
            let workspace = try await db.read {
                try lessonID($0, bookID: bookID, "the workspace")
            }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: workspace)
            }
            #expect(stored.contains(Operations.defaultQuicknoteBookName),
                    "the lesson names the smart book that collects the pad's note (R6-4; 13s-b U1b — the one name constant)")
            #expect(stored.contains("quicknote"),
                    "…and the tag whose removal is the road back")
            #expect(!stored.contains("kept as a note in the Pool"),
                    "the pre-R6-4 landing claim is gone")
        }
    }

    /// **13u3 UNIT C (her R-13u-4):** the lesson taught the capture model
    /// this ruling replaced — *"Return there makes a new line, not a new
    /// note"* — which is now exactly backwards on both Mac capture boxes.
    /// RED ON OLD: the new-line sentence.
    @Test func theWorkspaceLessonTeachesTheCaptureKeys() async throws {
        try await withTutorialWorld { _, db, bookID in
            let workspace = try await db.read {
                try lessonID($0, bookID: bookID, "the workspace")
            }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: workspace)
            }
            #expect(stored.contains("\u{23CE} there FILES what you wrote"),
                    "⏎ files the capture (R-13u-4)")
            #expect(stored.contains("\u{21E7}\u{23CE} adds another paragraph"),
                    "…and ⇧⏎ is the paragraph key")
            #expect(!stored.contains("makes a new line, not a new note"),
                    "the retired model is no longer taught")
        }
    }

    /// **13u3 UNIT D (item 14): the saving lesson teaches the NAME.** ⌘S
    /// opens a field now, so a lesson that said "press ⌘S" and stopped was
    /// leaving her at an unexplained box — and the fast road (⏎) is exactly
    /// the half she must be told about, or the door reads as slower than it
    /// was. RED ON OLD: the shipped lesson had no ⏎ and no name anywhere.
    @Test func theSavingLessonTeachesTheNameAndTheSkipKey() async throws {
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "keeping takes safe")
            }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: lesson)
            }
            #expect(stored.contains("type a name for the moment"),
                    "the field is explained where the keystroke is taught")
            #expect(stored.contains("press \u{23CE} to save it unnamed"),
                    "…and so is the two-key fast road (her enter-to-skip)")
            #expect(stored.contains("the name is always editable, the saved text never is"),
                    "R-13u3-1 and I5, in one sentence")
        }
    }

    /// The Act 10 correction round, batch G — **row 85 (A's residue):** the
    /// lesson taught the RETIRED masthead fold ("＃ folds the note's tag
    /// cards away and back") and a four-door bar. It teaches the ＃ door's
    /// truth now: an inline field with the cursor in it, ⏎ applies, ⌘⇧I
    /// opens it; the bar is three doors. RED ON OLD: the fold sentence.
    @Test func theWorkspaceLessonTeachesTheMastheadTagDoor() async throws {
        try await withTutorialWorld { _, db, bookID in
            let workspace = try await db.read {
                try lessonID($0, bookID: bookID, "the workspace")
            }
            let stored = try await db.read {
                try Queries.renderedText($0, containerID: workspace)
            }
            #expect(stored.contains("tag field slides out with the cursor already in it"),
                    "the ＃ is the one tag door — the inline field (row 15)")
            #expect(stored.contains("\u{2318}\u{21E7}I opens the same field"),
                    "⌘⇧I is re-pointed at the field")
            #expect(stored.contains("always the same three doors"),
                    "the bar's own row is back · book · forward")
            #expect(!stored.contains("folds the note's tag cards"),
                    "the retired fold is no longer taught")
        }
    }

    /// **13i-d U7 continuation C3 — F-U7-4: row 85's twin, one lesson over.**
    /// Row 85 corrected "the workspace" to the masthead's ＃ tag field and ⌘⇧I
    /// OPENING it, and missed "comments & tags", which went on teaching tag
    /// cards "on the CONTEXT BAR at the top of its pane" and "Fold the bar with
    /// ⌘⇧I" — a fold the app retired. RED ON OLD: both retired clauses.
    @Test func theCommentsAndTagsLessonTeachesTheMastheadTagField() async throws {
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "comments & tags") }
            let stored = try await db.read { try Queries.renderedText($0, containerID: lesson) }
            #expect(!stored.contains("Fold the bar with"), "the retired fold is no longer taught")
            #expect(!stored.contains("CONTEXT BAR at the top of its pane"),
                    "tags live on the masthead, not the context bar (row 15)")
            #expect(stored.contains("masthead"), "where the cards really are")
            #expect(stored.contains("\u{2318}\u{21E7}I opens the same field"),
                    "⌘⇧I opens the tag field — the workspace lesson's own words")
            #expect(stored.contains("Make a Gathering"), "the Settings door the paragraph names")
        }
    }
}

// MARK: - The doors (seeding is a product door)

@MainActor
@Suite("Tutorial doors (13b Stage 2 — restore/open, registry-declared)")
struct TutorialDoorTests {
    @Test func restoreTutorialIsDeclaredAndAvailableEverywhere() {
        let capability = CapabilityRegistry.capability(.restoreTutorial)
        #expect(capability.doors.contains(.menuBar))
        #expect(capability.doors.contains(.palette))
        for mode in PostMode.allCases {
            #expect(CapabilityRegistry.isEnabled(
                .restoreTutorial, in: CapabilityContext(mode: mode)))
        }
        #expect(CapabilityRegistry.isEnabled(.restoreTutorial, in: CapabilityContext(mode: nil)))
    }

    @Test func restoreReplacesWholesaleAndTouchesNothingElse() async throws {
        try await withTutorialWorld { session, db, bookID in
            // A user's own world beside the tutorial.
            let userPost = try session.operations.createPost(title: "my real essay")
            _ = try session.operations.newBlock(in: userPost.id, text: "my own words.")
            let userBook = try session.operations.createReading(name: "my book", kind: .book)
            let userRows = try await db.read { [postID = userPost.id] db in
                try userPostRows(db, postID: postID).map(CopiedRow.init)
            }

            // Wound the tutorial: delete one lesson, edit another.
            let doomed = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            try session.operations.deleteContainer(doomed)
            let edited = try await db.read { try lessonID($0, bookID: bookID, "divide") }
            let editedSlots = try await slots(db, edited)
            try session.operations.autosave(
                editedSlots[0].variantID!, text: "scribbled over", charDelta: 14)

            let freshBookID = try await TutorialSeeder.restore(session: session)
            #expect(freshBookID != bookID, "wholesale: a fresh book, not a patch")

            let (bookCount, lessonCount, oldBookLive) = try await db.read { db -> (Int, Int, Bool) in
                let books = try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName }
                let lessons = try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [freshBookID]) ?? 0
                return (books.count, lessons, try Queries.reading(db, id: bookID) != nil)
            }
            #expect(bookCount == 1, "exactly one live field guide")
            #expect(lessonCount == TutorialSeeder.plan.flatMap(\.lessons).count)
            #expect(!oldBookLive, "the old book is gone")

            // The fresh divide lesson is pristine again.
            let freshDivide = try await db.read { try lessonID($0, bookID: freshBookID, "divide") }
            let freshSlots = try await slots(db, freshDivide)
            #expect(freshSlots[0].text?.contains("Divide cuts a block in two") == true)

            // The user's world is byte-untouched — the post AND its
            // placements/blocks/variants (NIT-5).
            let userRowsAfter = try await db.read { [postID = userPost.id] db in
                try userPostRows(db, postID: postID).map(CopiedRow.init)
            }
            #expect(!userRowsAfter.isEmpty)
            #expect(userRowsAfter == userRows, "restore never touches her rows — down to the variants")
            let userBookLive = try await db.read { try Queries.reading($0, id: userBook.id) != nil }
            #expect(userBookLive)
        }
    }

    /// Stage 2 ladder MAJOR-A pin (red-on-old): the confirm gates on the
    /// SAME predicate as the destruction — anything tutorial-shaped, not
    /// just a live book. The finding's concrete path: she deletes the book
    /// (lessons survive as tagged bookless posts) and tags one of her OWN
    /// posts `tutorial` (the tags lesson teaches the gesture); the old
    /// door saw no book, asked nothing, and silently tombstoned her post.
    @Test func theConfirmGatesOnEverythingTheReplaceDestroys() async throws {
        try await withTutorialWorld { session, db, bookID in
            try session.operations.deleteReading(bookID)
            let userPost = try session.operations.createPost(title: "my tagged essay")
            _ = try session.operations.newBlock(in: userPost.id, text: "my own words, wearing the tag.")
            let tagID = try await db.read { db in
                try Queries.allTags(db).first { $0.path == TutorialSeeder.tagName }?.id
            }
            _ = try session.operations.applyTag(try #require(tagID), toPost: userPost.id)

            let actions = ShellActions(session: session, shell: ShellRouter())
            var consulted = false
            actions.restoreTutorial(confirm: { consulted = true; return false })
            await poll { consulted }
            #expect(consulted, "no live book, but tagged content exists — the confirm still gates")
            await poll { !session.tutorialDoorInFlight }
            let userStillLive = try await db.read { db in
                try Container.fetchOne(db, key: userPost.id)?.deletedAt == nil
            }
            #expect(userStillLive == true, "an unconfirmed Restore deletes NOTHING — her post survives")
        }
    }

    /// Stage 2 ladder MINOR-D3 pin (red-on-old): cleanup destroys exactly
    /// what the confirm discloses — the EXACT `tutorial` tag, never its
    /// sub-tags. The seeder only ever applies the exact tag; a post tagged
    /// `tutorial/…` is hers.
    @Test func aSubTaggedUserPostSurvivesTheRestore() async throws {
        try await withTutorialWorld { session, db, _ in
            let parentID = try await db.read { db in
                try Queries.allTags(db).first { $0.path == TutorialSeeder.tagName }?.id
            }
            let parentTagID = try #require(parentID)
            let child = try session.operations.createTag(
                parent: parentTagID, name: "keepsake")
            let userPost = try session.operations.createPost(title: "my keepsake notes")
            _ = try session.operations.newBlock(in: userPost.id, text: "sub-tagged, mine.")
            _ = try session.operations.applyTag(child.id, toPost: userPost.id)

            _ = try await TutorialSeeder.restore(session: session)
            let stillLive = try await db.read { db in
                try Container.fetchOne(db, key: userPost.id)?.deletedAt == nil
            }
            #expect(stillLive == true, "a `tutorial/…` post is NOT the tutorial's to clean up")
        }
    }

    /// Stage 2 ladder MINOR-D4 (the architect's recorded call, built):
    /// keying stays NAME-BASED, accept-and-document — a USER reading named
    /// exactly "the field guide" is the replace's to delete (readings have
    /// no restore door — the standing pre-13 boundary), and the reshaped
    /// confirm (a) fires whenever anything exists and (b) discloses "every
    /// book named …" PLURAL, so the collision costs nothing undisclosed.
    /// Her member posts survive (cleanup deletes tagged posts only;
    /// deleting a reading never touches containers). Coverage pin — the
    /// behavior is accepted; the missing piece was a pin at the edge.
    @Test func aSameNamedUserBookDiesWithTheConfirmedReplaceButItsPostsSurvive() async throws {
        try await withTutorialWorld { session, db, bookID in
            let herBook = try session.operations.createReading(
                name: TutorialSeeder.bookName, kind: .book)
            let herPost = try session.operations.createPost(title: "her chapter draft")
            _ = try session.operations.newBlock(
                in: herPost.id, text: "her words, in her same-named book.")
            _ = try session.operations.addPostToReading(herPost.id, to: herBook.id)

            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            var consulted = false
            actions.restoreTutorial(confirm: { consulted = true; return true })
            await poll { shell.pendingSelection != nil }
            #expect(consulted, "the collision case is confirm-gated")

            let (fieldGuides, herBookLive, herPostLive) = try await db.read { db -> (Int, Bool, Bool) in
                (try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName }.count,
                 try Queries.reading(db, id: herBook.id) != nil,
                 try Container.fetchOne(db, key: herPost.id)?.deletedAt == nil)
            }
            #expect(fieldGuides == 1, "exactly one live field guide — name-based keying, documented")
            #expect(!herBookLive,
                    "her same-named book died with the replace — the accepted, DISCLOSED cost")
            #expect(herPostLive == true, "member posts survive; only the structure is gone")
        }
    }

    /// Stage 2 ladder MINOR-D5 pin (red-on-old): the open entrance on a
    /// book-DELETED store that still holds tutorial residue routes through
    /// the RESTORE path — confirm included — instead of seeding beside the
    /// residue (which grew a second "tutorial scraps" pool and kept
    /// orphaned old lessons beside fresh ones; titles aren't unique).
    @Test func openOnABooklessStoreWithResidueRestoresInsteadOfDuplicating() async throws {
        try await withTutorialWorld { session, db, bookID in
            try session.operations.deleteReading(bookID)

            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            var consulted = false
            actions.openTutorial(confirm: { consulted = true; return true })
            await poll { shell.pendingSelection != nil }
            #expect(consulted, "residue exists — the open door replaces, so it asks first")

            let (pools, tagged) = try await db.read { db -> (Int, Int) in
                let pools = try Queries.pools(db)
                    .filter { $0.title == TutorialSeeder.scrapPoolTitle }.count
                let tag = try Queries.allTags(db).first { $0.path == TutorialSeeder.tagName }
                let tagged = try tag.map {
                    try Queries.everythingTagged(db, tagID: $0.id, includeSubtree: false)
                        .postIDs.count
                } ?? 0
                return (pools, tagged)
            }
            #expect(pools == 1, "never a second scrap pool")
            #expect(tagged == TutorialSeeder.plan.flatMap(\.lessons).count + 1,
                    "the lessons + the twin, exactly once — no orphans beside fresh copies")
        }
    }

    /// Stage 2 ladder NIT-6 pin (red-on-old): a double-pressed Restore
    /// converges — the session latch makes the second press a synchronous
    /// no-op, so two discoveries can never race into two live field guides
    /// (and the confirm is asked ONCE, not once per press).
    @Test func aDoublePressedRestoreConvergesToOneFieldGuide() async throws {
        try await withTutorialWorld { session, db, _ in
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            var confirmCount = 0
            actions.restoreTutorial(confirm: { confirmCount += 1; return true })
            actions.restoreTutorial(confirm: { confirmCount += 1; return true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(confirmCount == 1, "the second press is a no-op — one door in flight per session")
            let fieldGuides = try await db.read { db in
                try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName }.count
            }
            #expect(fieldGuides == 1, "never two live field guides")
        }
    }

    /// Stage 2 ladder MINOR-D1 pin (red-on-old): seeding is not HER act —
    /// the session's structural-undo stack is untouched by a restore (the
    /// seed's `duplicateAsVersion` used to leave a stray "Duplicate as
    /// Version" inverse; her next unmatched ⌥⌘Z popped it and the twin
    /// lesson vanished — the R112 class through the tutorial's own door).
    @Test func theSeederNeverTouchesTheStructuralUndoStack() async throws {
        try await withTutorialWorld { session, _, _ in
            #expect(session.undoStack.depth == 0, "the world's own seed left no inverse")
            _ = try await TutorialSeeder.restore(session: session)
            #expect(session.undoStack.depth == 0,
                    "a restore leaves ⌥⌘Z exactly as it found it")
        }
    }

    @Test func theRestoreDoorConfirmsSeedsOpensAndSpeaks() async throws {
        try await withTutorialWorld { session, db, bookID in
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            // Declined confirm: the gate is REACHED (the spy proves it —
            // NIT-3: the old negative poll on pendingSelection passed on
            // its first turn and covered nothing), and nothing is replaced.
            var consulted = false
            actions.restoreTutorial(confirm: { consulted = true; return false })
            await poll { consulted }
            #expect(consulted, "the confirm was consulted")
            await poll { !session.tutorialDoorInFlight }  // the door finished
            #expect(shell.pendingSelection == nil, "a declined confirm opens nothing")
            let stillThere = try await db.read { try Queries.reading($0, id: bookID) != nil }
            #expect(stillThere, "Cancel keeps the existing book")

            // Confirmed: replaced, opened, spoken.
            actions.restoreTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            guard case .reading(let openedID)? = shell.pendingSelection else {
                Issue.record("the door opens the fresh book")
                return
            }
            #expect(openedID != bookID)
            // 18i: the restore door's report is a receipt.
            // 13i-d U6 (a), a JUSTIFIED EDIT: the restore door's receipt names
            // the area by its ruled name — the Bookcase (the sitting record §7).
            #expect(session.status.spoken?.text.contains("on your Bookcase") == true,
                    "the outcome lands in the one status presentation")
        }
    }

    @Test func theOpenEntranceFindsWithoutReseeding() async throws {
        try await withTutorialWorld { session, _, bookID in
            let shell = ShellRouter()
            ShellActions(session: session, shell: shell).openTutorial()
            await poll { shell.pendingSelection != nil }
            #expect(shell.pendingSelection == .reading(bookID),
                    "an existing book just opens — find-or-seed never duplicates")
        }
    }
}

// MARK: - writing (chapter acts)

@MainActor
@Suite("Tutorial acts — writing")
struct TutorialWritingActsTests {
    @Test func makeBlockFreesTheLonelyMiddleSentence() async throws {
        try await withTutorialWorld { session, db, bookID in
            let shaping = try await db.read { try lessonID($0, bookID: bookID, "shaping blocks") }
            let before = try await slots(db, shaping)
            let host = try #require(before.first {
                $0.text?.contains("This middle sentence wants to be a block of its own.") == true
            })
            let text = host.text ?? ""
            let sentence = "This middle sentence wants to be a block of its own."
            let start = try utf16Offset(of: sentence, in: text)
            let end = start + (sentence as NSString).length

            // The ⌘⇧K compound = two divides (middle span → own block).
            _ = try session.operations.divide(host.blockID, cut: start)
            let mid = try await slots(db, shaping)
            let second = try #require(mid.first { $0.text?.hasPrefix(sentence) == true })
            let cutInSecond = end - start
            _ = try session.operations.divide(second.blockID, cut: cutInSecond)

            let after = try await slots(db, shaping)
            #expect(after.count == before.count + 2)
            #expect(after.contains { $0.text == sentence },
                    "the lonely sentence stands alone, exactly")
        }
    }

    /// Stage 2 WALK FIX pin (red-on-old, behavioral-revert verified): the
    /// shaping lesson's callout frame was BLANK on an ordinary Write mount
    /// — `refreshDecorations` had run before the overlay controller wired
    /// `decorSink` (attach precedes install; the model was already
    /// loaded), and the `lastDecorState` equality gate then starved the
    /// new host until the next real change. Wiring now DELIVERS the
    /// current state: the callout renders the moment the host exists.
    @Test func aFreshlyMountedEditorRendersTheCalloutFrame() async throws {
        try await withTutorialWorld { session, db, bookID in
            let shaping = try await db.read { try lessonID($0, bookID: bookID, "shaping blocks") }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = EditorViewModel(session: session, postID: shaping)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            window.contentView = scrollView
            window.makeKeyAndOrderFront(nil)
            model.attach(textView: textView, scrollView: scrollView)

            // The starved order: everything adopted BEFORE the overlay
            // host exists (the loaded-model mount).
            let (slots, header, presentations) = try await db.read { db in
                (try Queries.renderPost(db, containerID: shaping),
                 try Queries.containerHeader(db, containerID: shaping),
                 try Queries.blockPresentations(db, containerID: shaping))
            }
            model.adoptHeader(header)
            model.applyProjection(slots)
            model.adoptPresentations(presentations)
            window.layoutIfNeeded()
            window.displayIfNeeded()

            // NOW the host wires — exactly the makeNSView order.
            let decor = BlockDecorOverlayController(model: model, textView: textView)
            _ = decor
            await poll {
                textView.subviews.contains {
                    String(describing: type(of: $0)).contains("DecorRectView")
                }
            }
            #expect(textView.subviews.contains {
                String(describing: type(of: $0)).contains("DecorRectView")
            }, "the callout frame renders the moment the host exists — never starved")
        }
    }

    /// Stage 2 ladder round-2 R2-B pin (red-on-old, behavioral-revert
    /// verified): the starved-host class's LAST field — the editor's
    /// BADGE sink. `BadgeOverlayController.init` wired `model.badgeSink`
    /// with no push, `refreshBadges` gates on `result != badges`, and
    /// nothing resets `badges` at attach — so a freshly-wired overlay
    /// over a loaded model (both editor representables build fresh
    /// coordinators) showed no ⑂ until a real badge/viewport change,
    /// which a fully-visible short post never produces. Wiring now
    /// DELIVERS (`pushBadgesToSink`), symmetric with the decor twin and
    /// the read tier.
    @Test func aFreshlyWiredBadgeOverlayShowsTheFans() async throws {
        try await withTutorialWorld { session, db, bookID in
            let choosing = try await db.read { try lessonID($0, bookID: bookID, "choosing & the board") }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = EditorViewModel(session: session, postID: choosing)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            window.contentView = scrollView
            window.makeKeyAndOrderFront(nil)
            model.attach(textView: textView, scrollView: scrollView)

            // The starved order: the model loads and computes badges
            // BEFORE the overlay host exists (the loaded-model mount).
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: choosing),
                 try Queries.containerHeader(db, containerID: choosing))
            }
            model.adoptHeader(header)
            model.applyProjection(slots)
            window.layoutIfNeeded()
            window.displayIfNeeded()
            model.refreshBadges()
            #expect(!model.badges.isEmpty,
                    "the rain fan is in view — the stored badge state exists BEFORE the host wires")

            // NOW the badge host wires — exactly the install order.
            let overlay = BadgeOverlayController(model: model, textView: textView)
            _ = overlay
            @MainActor func hasBadge() -> Bool {
                textView.subviews.contains { ($0 as? NSButton)?.title.contains("⑂") == true }
            }
            await poll { hasBadge() }
            #expect(hasBadge(),
                    "the ⑂ badge renders the moment the host exists — never starved")
        }
    }

    /// N14 pin (13b Stage 3F; red-on-old, behavioral-revert verified): THE
    /// COLD-MOUNT deterministic repro from the 3A drive — a post's FIRST
    /// mount since launch (no saved scroll anchor) rendered every ⑂ badge
    /// collapsed onto ONE top anchor, because every mount-time overlay
    /// refresh (renderFull's, the clip's, applyChrome's) runs BEFORE TK2's
    /// first layout pass and nothing refreshed after it — the only
    /// post-layout triggers were user scrolls and the saved-anchor jump,
    /// which is exactly why warm models and remounts healed. The
    /// layout-settle trigger (`EditorTextView.viewWillDraw` → one coalesced
    /// overlay refresh per storage generation) re-delivers real frames; the
    /// decor family rides the same one call.
    @Test func aColdFirstMountPlacesEachBadgeAtItsBlock() async throws {
        try await withTutorialWorld { session, db, bookID in
            // Two fanned blocks with real prose between them: their badges
            // must land at DIFFERENT heights once real layout exists.
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "extract & make block")
            }
            let before = try await slots(db, lesson)
            let firstSlot = try #require(before.first)
            let lastSlot = try #require(before.last)
            _ = try session.operations.branchVariant(
                firstSlot.blockID, from: #require(firstSlot.variantID))
            _ = try session.operations.branchVariant(
                lastSlot.blockID, from: #require(lastSlot.variantID))

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = EditorViewModel(session: session, postID: lesson)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            window.contentView = scrollView
            window.makeKeyAndOrderFront(nil)

            // THE REAL COLD ORDER (makeNSView): attach → the overlay host
            // wires (delivers whatever exists) → the projection renders
            // into UN-LAID storage (its refresh reads garbage frames) →
            // the first display pass lays the document out.
            model.attach(textView: textView, scrollView: scrollView)
            let badgeHost = BadgeOverlayController(model: model, textView: textView)
            _ = badgeHost
            let (slotsNow, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: lesson),
                 try Queries.containerHeader(db, containerID: lesson))
            }
            model.adoptHeader(header)
            model.applyProjection(slotsNow)
            window.layoutIfNeeded()
            window.display()

            @MainActor func badgeYs() -> [CGFloat] {
                textView.subviews
                    .compactMap { $0 as? NSButton }
                    .filter { $0.title.hasPrefix("⑂") }
                    .map { $0.frame.origin.y }
                    .sorted()
            }
            await poll {
                let ys = badgeYs()
                return ys.count == 2 && ys[1] - ys[0] > 40
            }
            let ys = badgeYs()
            #expect(ys.count == 2, "both fanned blocks carry a badge")
            #expect((ys.last ?? 0) - (ys.first ?? 0) > 40,
                    "each badge sits at its OWN block — never collapsed onto one top anchor (N14)")
        }
    }

    @Test func addBlockAtEndMintsAndHandsTheRingOver() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "blocks & typing") }
            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let before = model.projection.slots.count

            await model.addBlockAtEnd()
            let after = try await slots(db, lesson)
            #expect(after.count == before + 1)
            #expect(after.last?.text == "", "born empty — a place to type")
            model.adopt(try await projection(db, lesson))
            #expect(model.authority.livePane?.blockID == after.last?.blockID,
                    "typing continues instantly in the minted block")
        }
    }

    /// 13b 4D (N28's second half — S4-13 editor parity, the lesson's own
    /// promise): ⌘⇧⏎ mints an empty block RIGHT UNDER the one you're in,
    /// and the cursor lands in it — Write and Takes alike.
    @Test func newBlockBelowMintsUnderTheFocusedBlockInBothEditors() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "shaping blocks") }

            // — Takes: the focused pane's block is the target; the minted
            //   pane takes the ring when its slot arrives.
            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let before = model.projection.slots
            let target = before[1]
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: target.blockID, variantID: target.variantID!))
            await model.insertBlockBelowFocused()
            let afterTakes = try await slots(db, lesson)
            #expect(afterTakes.count == before.count + 1)
            let mintIndex = try #require(
                afterTakes.firstIndex { $0.blockID == target.blockID }) + 1
            #expect(afterTakes[mintIndex].text == "", "born empty, right below the focused block")
            model.adopt(try await projection(db, lesson))
            #expect(model.authority.livePane?.blockID == afterTakes[mintIndex].blockID,
                    "typing continues instantly in the minted block")

            // — Write: the caret block is the target; the caret lands in
            //   the mint (through the one structural door).
            let editor = EditorViewModel(session: session, postID: lesson)
            editor.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: editor)
            delegate.wire(to: textView)
            editor.attach(textView: textView, scrollView: scrollView)
            let (postSlots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: lesson),
                 try Queries.containerHeader(db, containerID: lesson))
            }
            editor.adoptHeader(header)
            editor.applyProjection(postSlots)
            let writeTarget = postSlots[0]
            textView.setSelectedRange(NSRange(location: 2, length: 0))  // inside block 0
            editor.updateCaretContext()
            #expect(editor.caretBlockID == writeTarget.blockID)
            await editor.insertBlockBelowCaret()
            let afterWrite = try await slots(db, lesson)
            #expect(afterWrite.count == afterTakes.count + 1)
            let writeMintIndex = try #require(
                afterWrite.firstIndex { $0.blockID == writeTarget.blockID }) + 1
            #expect(afterWrite[writeMintIndex].text == "",
                    "born empty, right below the caret block")
            #expect(editor.caretBlockID == afterWrite[writeMintIndex].blockID,
                    "the caret lands in the minted block")
        }
    }

    @Test func theSeamsToggleFlipsTheGlobalSetting() async throws {
        try await withTutorialWorld { session, db, _ in
            let before = try await db.read { try Queries.themeSettings($0).seamsVisible }
            ShellActions(session: session, shell: ShellRouter()).toggleSeams()
            var flipped = false
            for _ in 0..<200 {
                let now = try await db.read { try Queries.themeSettings($0).seamsVisible }
                if now != before {
                    flipped = true
                    break
                }
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(flipped, "⌘⇧B flips the seams setting (the lesson's promise)")
        }
    }
}

// MARK: - takes (chapter acts)

@MainActor
@Suite("Tutorial acts — takes")
struct TutorialTakesActsTests {
    @Test func branchAndBlankTakesGrowTheLighthouseFan() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "your first take") }
            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let lighthouse = try #require(model.projection.slots.first {
                $0.text?.contains("lighthouse keeper") == true
            })

            // ⌘T — branch of what's shown.
            let branched = await model.branchTake(
                blockID: lighthouse.blockID, from: lighthouse.variantID!)
            #expect(branched?.workingText.contains("lighthouse keeper") == true,
                    "a branch is born as a copy of what you were reading")

            // ⌥⌘T — a blank take, and it NEVER chooses (R90).
            _ = await model.newBlankTake(blockID: lighthouse.blockID)
            let after = try await projection(db, lesson)
            #expect(after.fans[lighthouse.blockID]?.count == 3)
            let slotNow = try #require(after.slots.first { $0.blockID == lighthouse.blockID })
            #expect(slotNow.variantID == lighthouse.variantID,
                    "minting never chooses — the post still shows the original")
        }
    }

    /// Stage 2 WALK FIX pin (red-on-old, behavioral-revert verified): ⌘T
    /// on a block with a CLOSED fan used to mint an INVISIBLE take — the
    /// handler focused the new pane but never opened the fan, so the
    /// article kept showing chosen and the only trace was the ⑂ counter.
    /// The lesson's promise is literal: "a second take appears beside it."
    /// Every mint door now REVEALS: fan open + ring on the minted take.
    @Test func branchOnAClosedFanRevealsTheNewTake() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "your first take") }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = TakesViewModel(session: session, postID: lesson)
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: lesson, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await poll { session.commandRouter.handlerCount > 0 }
            await poll { !model.projection.slots.isEmpty }
            let first = model.projection.slots[0]
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.blockID, variantID: first.variantID!))
            #expect(!model.expandedBlocks.contains(first.blockID), "the fan starts CLOSED")

            // The ⌘T door's exact routed body.
            session.commandRouter.dispatch(.takes(.branch))
            await poll {
                (model.projection.fans[first.blockID]?.count ?? 0) == 2
                    && model.expandedBlocks.contains(first.blockID)
            }
            #expect(model.expandedBlocks.contains(first.blockID),
                    "the fan OPENED — the second take appears beside the first")
            let fan = try #require(model.projection.fans[first.blockID])
            #expect(fan.count == 2)
            let minted = try #require(fan.first { $0.id != first.variantID })
            #expect(model.authority.livePane?.variantID == minted.id,
                    "the ring is on the new take — typing continues there")
            // Round-2 strengthening (R2-A sweep, red-on-old): the ring's
            // FULL key must name a pane the board renders — the mint is
            // an un-chosen take, rendered as a FAN card, never in the
            // article (which renders chosen). The old article-keyed
            // reveal left the authority on ("takes-main", block, mint):
            // no style renders that pane, so no ring was drawn anywhere.
            #expect(model.authority.livePane == TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: first.blockID, variantID: minted.id),
                    "the ring keys the fan card the bloom actually renders")
        }
    }

    @Test func choosingMovesThePostAmongTheFourTakes() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "choosing & the board") }
            let before = try await projection(db, lesson)
            let rain = try #require(before.slots.first {
                $0.text?.contains("The rain came in from the sea") == true
            })
            let fan = try #require(before.fans[rain.blockID])
            let target = try #require(fan.first { $0.workingText.contains("verdict") })

            try session.operations.chooseVariant(rain.blockID, variantID: target.id)
            let after = try await projection(db, lesson)
            let slotNow = try #require(after.slots.first { $0.blockID == rain.blockID })
            #expect(slotNow.variantID == target.id, "⌘⏎ — chosen is what the post is")
            #expect(slotNow.text?.contains("verdict") == true)
        }
    }

    @Test func commitHistoryAndRestoreKeepTheTakeSafe() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "keeping takes safe") }
            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let first = model.projection.slots[0]
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.blockID, variantID: first.variantID!))

            // ⌘S — the savepoint.
            await model.commitFocusedTake()
            let history = try await db.read { try Queries.commitHistory($0, variantID: first.variantID!) }
            #expect(history.count == 1, "the savepoint is listed")
            let savepoint = try #require(history.first)

            // Type over it, then Restore.
            try session.operations.autosave(
                first.variantID!, text: "typed right over the lesson", charDelta: 20)
            await model.restoreCommit(savepoint)
            let restored = try await db.read { db in
                try Variant.fetchOne(db, key: first.variantID!)?.workingText
            }
            #expect(restored == savepoint.text, "Restore loads the savepoint back")
            let historyAfter = try await db.read { try Queries.commitHistory($0, variantID: first.variantID!) }
            #expect(historyAfter.count >= 1, "commits append — nothing is overwritten")
        }
    }

    @Test func archiveLeavesTheBoardAndUnarchiveBringsItBack() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "keeping takes safe") }
            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let spareHost = try #require(model.projection.slots.first { slot in
                (model.projection.fans[slot.blockID]?.count ?? 0) == 2
            })
            let spare = try #require(model.projection.fans[spareHost.blockID]?
                .first { $0.workingText.contains("spare take") })

            await model.archiveTake(spare.id)
            let after = try await projection(db, lesson)
            #expect(after.fans[spareHost.blockID]?.contains { $0.id == spare.id } == false,
                    "⌘⇧A — out of the fan")
            // The road back the lesson teaches NOW lives on this board
            // (13b 3D — N1): the speech names the door, and the door's
            // listing is real.
            #expect(model.statusMessage?.contains("archived \u{B7} n") == true,
                    "the archive speech names the in-Takes road")
            model.adopt(after)
            await model.refreshArchived()
            #expect(model.archivedCounts[spareHost.blockID] == 1,
                    "the \u{201C}archived \u{B7} 1\u{201D} door the lesson promises is real")
            #expect(model.archivedTakes[spareHost.blockID]?.map(\.id) == [spare.id])

            // Unarchive — the listing's own act (Write's panel rides the
            // same model door).
            await model.unarchiveTake(spare.id)
            let back = try await projection(db, lesson)
            #expect(back.fans[spareHost.blockID]?.contains { $0.id == spare.id } == true,
                    "never gone — Unarchive restores it to the fan")
            model.adopt(back)
            await model.refreshArchived()
            #expect(model.archivedCounts[spareHost.blockID] == nil,
                    "the door retires when nothing is archived")
        }
    }
}

// MARK: - structure (chapter acts)

@MainActor
@Suite("Tutorial acts — structure")
struct TutorialStructureActsTests {
    @Test func divideCutsTheTwoThoughtBlockAndUndoRestoresIt() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide") }
            let before = try await slots(db, lesson)
            let block = try #require(before.first {
                $0.text?.contains("This block holds two thoughts") == true
            })
            let cut = try utf16Offset(of: "Put your cursor", in: block.text ?? "")

            _ = try await session.runner.run { ops in
                try ops.divide(block.blockID, cut: cut)
            }
            let after = try await slots(db, lesson)
            #expect(after.count == before.count + 1)
            #expect(after.contains { $0.text == "This block holds two thoughts and they deserve two blocks." })
            #expect(after.contains { $0.text?.hasPrefix("Put your cursor") == true })

            // ⌥⌘Z — and the report lands in the one status surface (N4).
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll { session.status.spoken != nil }
            // 18i: the undo report is a receipt (quiet by default).
            #expect(session.status.spoken?.text == "Undid: Divide")
            let restored = try await slots(db, lesson)
            #expect(restored.count == before.count, "one ⌥⌘Z puts it back together")
        }
    }

    @Test func divideFromTakesChoreographsToWriteAndCuts() async throws {
        // The choreography watched as a feature, on the tutorial's own
        // content: Takes parks the intent, the mode switches, the arriving
        // editor lands the caret and cuts.
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide") }
            var modes: [PostMode] = []
            _ = session.commandRouter.registerDetail(
                postID: lesson, mode: .takes
            ) { modes.append($0) }

            let model = TakesViewModel(session: session, postID: lesson)
            model.adopt(try await projection(db, lesson))
            let block = try #require(model.projection.slots.first {
                $0.text?.contains("This block holds two thoughts") == true
            })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: block.blockID, variantID: block.variantID!))
            model.moveToWriteAndRun(.structural(.divide))
            await poll { session.commandRouter.pendingWriteIntent != nil }
            #expect(modes == [.write], "the switch is visible — the app does the carrying")
            var intent = try #require(session.commandRouter.pendingWriteIntent)
            #expect(intent.blockID == block.blockID)

            // Land the caret inside the second thought (the walk's cursor).
            intent.offsetInBlock = try utf16Offset(of: "Put your cursor", in: block.text ?? "")
            session.commandRouter.pendingWriteIntent = intent

            let editor = EditorViewModel(session: session, postID: lesson)
            editor.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: editor)
            delegate.wire(to: textView)
            editor.attach(textView: textView, scrollView: scrollView)
            let (postSlots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: lesson),
                 try Queries.containerHeader(db, containerID: lesson))
            }
            editor.adoptHeader(header)
            editor.applyProjection(postSlots)
            #expect(session.commandRouter.pendingWriteIntent == nil, "consumed at first render")
            await poll { editor.pendingIntentTask == nil }
            await editor.pendingIntentTask?.value
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) })?.count ?? 0)
                    == postSlots.count + 1
            }
            let after = try await slots(db, lesson)
            #expect(after.count == postSlots.count + 1, "the carried divide LANDED")
        }
    }

    @Test func theCeremonyCutsCheckedTakesAndTheUncheckedStays() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide choosing takes") }
            let before = try await projection(db, lesson)
            let ferry = try #require(before.slots.first {
                $0.text?.contains("The ferry crossed at dawn") == true
            })
            let fan = try #require(before.fans[ferry.blockID])
            #expect(fan.count == 3)
            let original = try #require(fan.first { $0.workingText.hasPrefix("The ferry crossed") })
            let checked2 = try #require(fan.first { $0.workingText.contains("grey of first light") })
            let unchecked = try #require(fan.first { $0.workingText.hasPrefix("At dawn") })

            // The sheet's Confirm — each checked take gets its own cut.
            let cuts = [
                original.id: try utf16Offset(of: "Nobody", in: original.workingText),
                checked2.id: try utf16Offset(of: "The storm", in: checked2.workingText),
            ]
            let result = try await session.runner.run { ops in
                try ops.divideW(ferry.blockID, cuts: cuts)
            }
            #expect(result.first.variants.count == 2, "two first halves")
            #expect(result.second.variants.count == 2, "two endings — mix-and-matchable")

            let after = try await slots(db, lesson)
            #expect(after.count == before.slots.count + 1, "two blocks stand where one stood")

            // The unchecked take stays with the preserved original.
            let uncheckedRow = try await db.read { db in
                try Variant.fetchOne(db, key: unchecked.id)
            }
            #expect(uncheckedRow?.blockId == ferry.blockID)
            #expect(uncheckedRow?.deletedAt == nil, "nothing is lost")
            let originalPlaced = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [ferry.blockID]) ?? -1
            }
            #expect(originalPlaced == 0, "the original is preserved whole, off-stage")

            // ⌥⌘Z puts the whole thing back.
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) })?.count ?? 0)
                    == before.slots.count
            }
            let restored = try await projection(db, lesson)
            #expect(restored.fans[ferry.blockID]?.count == 3, "back as it was, takes and all")
        }
    }

    @Test func theCeremonyParksATakeAndItRidesWholeIntoTheFirstBlock() async throws {
        // 13b 4A (S4-22 ruling 2): the lesson now teaches parking — a take
        // whose ✂ sits at its very end doesn't split; the whole take rides
        // into the first block and has no say in the second.
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "divide choosing takes") }
            let before = try await projection(db, lesson)
            let ferry = try #require(before.slots.first {
                $0.text?.contains("The ferry crossed at dawn") == true
            })
            let fan = try #require(before.fans[ferry.blockID])
            let original = try #require(fan.first { $0.workingText.hasPrefix("The ferry crossed") })
            let parked = try #require(fan.first { $0.workingText.contains("grey of first light") })

            let cuts = [
                original.id: try utf16Offset(of: "Nobody", in: original.workingText),
                parked.id: parked.workingText.utf16.count,  // ✂ at the very end
            ]
            let result = try await session.runner.run { ops in
                try ops.divideW(ferry.blockID, cuts: cuts)
            }
            #expect(result.first.variants.count == 2,
                    "the split take's first half + the parked take, whole")
            #expect(result.first.variants.map(\.workingText).contains(parked.workingText),
                    "the parked take rides verbatim")
            #expect(result.second.variants.count == 1,
                    "the parked take has no say in the second block")
            #expect(result.second.sourceVariantIDs == [original.id])

            // ⌥⌘Z puts the whole thing back, parked takes and all.
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) })?.count ?? 0)
                    == before.slots.count
            }
            let restored = try await projection(db, lesson)
            #expect(restored.fans[ferry.blockID]?.count == 3, "back as it was")
        }
    }

    @Test func aLateStartSelectionInTheExtractLessonNowPlansAnExtract() async throws {
        // 13b 4A red-on-old (the N18 stumble, dissolved on the lesson's own
        // text): the prose re-widened to "select from anywhere in this
        // paragraph to its end" — a selection starting MID-WORD late in
        // the final stretch settles onto the word edge and extracts, where
        // the old sentence-only snap rounded forward to the block end and
        // refused.
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "extract & make block")
            }
            let lessonSlots = try await slots(db, lesson)
            let host = try #require(lessonSlots.first {
                $0.text?.contains("begging to stand alone") == true
            })
            let text = host.text ?? ""
            let index = BlockRangeIndex(
                entries: [.init(
                    blockID: host.blockID, variantID: host.variantID,
                    length: (text as NSString).length, editable: true)],
                tailLength: nil)
            let world = StructuralGesturePlanner.World(
                index: index, fanArities: [1], sealed: false, textAt: { _ in text })
            let start = try utf16Offset(of: "begging", in: text) + 3  // mid-word
            let plan = StructuralGesturePlanner.plan(
                .extractSelection,
                selection: NSRange(location: start, length: (text as NSString).length - start),
                world: world)
            guard case .extract(_, _, let span, let edge, _) = plan else {
                Issue.record("the lesson's promise must hold — got \(plan)")
                return
            }
            #expect(edge == .suffix)
            #expect(span.lowerBound == (try utf16Offset(of: "begging", in: text)),
                    "the start settles onto the word edge, not the block end")
        }
    }

    @Test func extractPullsTheClosingLineIntoItsOwnBlock() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "extract & make block") }
            let before = try await slots(db, lesson)
            let host = try #require(before.first {
                $0.text?.contains("begging to stand alone") == true
            })
            let text = host.text ?? ""
            let start = try utf16Offset(of: "\u{2014} and this closing line", in: text)
            _ = try await session.runner.run { ops in
                try ops.extract(host.blockID, span: start..<(text as NSString).length)
            }
            let after = try await slots(db, lesson)
            #expect(after.count == before.count + 1)
            let extracted = try #require(after.first {
                $0.blockID != host.blockID && $0.text?.contains("begging to stand alone") == true
            })
            #expect(extracted.text?.contains("closing line") == true)
            let source = try #require(after.first { $0.blockID == host.blockID })
            #expect(source.text?.contains("begging to stand alone") == false,
                    "the source survives, minus the extracted span")
        }
    }

    /// Renamed at 13u4 UNIT E3 — it was `…WithASingleSpace`, and her
    /// ruling R-13u4-3 made the door join the rendering newline. The
    /// lesson's own sentence moved in the same commit.
    @Test func mergeJoinsTheWaitingPairWithTheRenderingJoin() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            let before = try await slots(db, lesson)
            let first = try #require(before.first {
                $0.text == "These two short blocks are really one thought."
            })
            let second = try #require(before.first {
                $0.text?.hasPrefix("They have been waiting") == true
            })
            let result = try await session.runner.run { ops in
                try ops.merge(first.blockID, second.blockID)
            }
            #expect(result.variant.workingText
                    == "These two short blocks are really one thought.\n"
                    + "They have been waiting for your \u{2318}\u{21E7}M since the day they were seeded.",
                    "one newline at the seam — nothing else invented")
        }
    }

    @Test func mergingAFannedBlockKeepsTheOtherTakesInLineage() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            let before = try await projection(db, lesson)
            let fannedSlot = try #require(before.slots.first {
                $0.text?.hasPrefix("This block has a second take") == true
            })
            #expect(before.fans[fannedSlot.blockID]?.count == 2)
            let index = try #require(before.slots.firstIndex { $0.blockID == fannedSlot.blockID })
            let above = before.slots[index - 1]

            // The INSTANT op (13b 4B: in the UI a fanned pair now opens the
            // merge ceremony, whose ⏎ default reproduces exactly this WHEN
            // no session join memory is set — a fresh session; a remembered
            // join seeds the pre-pair instead, ruling 3's letter (the
            // ladder round 1 NIT-4 precision); the instant op remains the
            // chain path's brick — this pins the stored meaning the
            // ceremony's fresh-session default promises).
            let result = try await session.runner.run { ops in
                try ops.merge(above.blockID, fannedSlot.blockID)
            }
            #expect(result.variant.workingText.contains("This block has a second take"),
                    "the merged text is what you were LOOKING at")
            #expect(!result.variant.workingText.contains("The spare take"),
                    "other takes are not glued in — that way lies madness")

            // The released source keeps its takes, in lineage.
            let releasedTakes = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        """,
                    arguments: [fannedSlot.blockID]) ?? 0
            }
            #expect(releasedTakes == 2, "they stay with the released block — undo brings them back")
        }
    }

    @Test func theMergeCeremonyPairsAndCarriesTheStagedTakes() async throws {
        // 13b 4B (S4-23): the lesson now teaches the ceremony — pair the
        // two takes you were looking at, CARRY the spare, and the merged
        // block holds both; ⌥⌘Z restores the sources whole. Run on the
        // lesson's own staged fanned pair.
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "merge") }
            let before = try await projection(db, lesson)

            // The lesson's prose PROMISES the ceremony's grammar.
            //
            // A JUSTIFIED EDIT (13j batch 4, J4b): the CLAIM is unchanged —
            // the merge lesson must promise the ceremony's pairing grammar —
            // but its locator moved. The prose no longer says merge "opens a
            // small CEREMONY", because after her 2026-08-09 ruling it does
            // not: ⌘⇧M carries every take along and the ceremony is the
            // summoned ⌥⌘⇧M door. The locator is now the door's own name,
            // and both promised words are asserted exactly as before.
            let ceremonyProse = try #require(before.slots.first {
                $0.text?.contains("Merge choosing takes") == true
            }).text ?? ""
            #expect(ceremonyProse.contains("pre-paired"), "⏎ = the everyday join, promised")
            #expect(ceremonyProse.contains("carry"), "the carry option, promised")

            let fannedSlot = try #require(before.slots.first {
                $0.text?.hasPrefix("This block has a second take") == true
            })
            let fan = try #require(before.fans[fannedSlot.blockID])
            let rendered = try #require(fan.first { $0.id == fannedSlot.variantID })
            let spare = try #require(fan.first { $0.workingText.contains("The spare take") })
            let index = try #require(before.slots.firstIndex { $0.blockID == fannedSlot.blockID })
            let above = before.slots[index - 1]

            let result = try await session.runner.run { ops in
                try ops.mergeCeremony(
                    above.blockID, fannedSlot.blockID,
                    pairings: [.init(
                        firstVariantID: above.variantID!,
                        secondVariantID: rendered.id,
                        join: MergeJoinRule.door.join(
                            head: above.text ?? "", tail: rendered.workingText))],
                    carries: [spare.id])
            }
            #expect(result.variants.count == 2, "one joined take + the carried spare")
            // The pairing joins exactly what was shown, on the door's
            // rendering join (R-13u4-3; this read `+ " " +` before E3).
            #expect(result.variants[0].workingText
                == (above.text ?? "") + "\n" + rendered.workingText)
            #expect(result.variants[1].workingText == spare.workingText,
                    "the spare rides whole — pair me, carry me, the prose says")

            // ⌥⌘Z puts the whole thing back — takes and all.
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) })?.count ?? 0)
                    == before.slots.count
            }
            let restored = try await projection(db, lesson)
            #expect(restored.fans[fannedSlot.blockID]?.count == 2,
                    "the sources came back whole, spare take included")
        }
    }

    @Test func structuralUndoInsuresTextTypedAfterTheAct() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the two undos") }
            let before = try await slots(db, lesson)
            let block = try #require(before.first {
                $0.text?.contains("two undo stacks") == true
            })
            let cut = try utf16Offset(of: "\u{2318}Z is TEXT", in: block.text ?? "")
            _ = try await session.runner.run { ops in
                try ops.divide(block.blockID, cut: cut)
            }
            // Type into the FIRST half after the act (the source variant —
            // the undo will overwrite this buffer with the pre-image, so
            // this is exactly the text the insurance covers)…
            let sourceVariant = block.variantID!
            try await session.runner.run { ops in
                try ops.autosave(sourceVariant, text: "words typed after the divide", charDelta: 28)
            }
            // …then undo the structure. 13d batch 5 (A12): THIS is the one
            // undo that now asks first — it is the insurance class by
            // construction, which is exactly what the lesson teaches. A
            // RULED change to a shipped pin: the act is unchanged, the door
            // asks before it runs, and a headless caller answers.
            ShellActions(session: session, shell: ShellRouter())
                .structuralUndo(confirm: { _ in true })
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) })?.count ?? 0)
                    == before.count
            }
            let restored = try await slots(db, lesson)
            #expect(restored.count == before.count, "the shape is back")
            // The insurance: the newer text is one restore away (a quiet
            // auto savepoint), never lost.
            let insured = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND text = ?",
                    arguments: [sourceVariant, "words typed after the divide"]) ?? 0
            }
            #expect(insured == 1, "nothing typed is ever more than one restore away")
        }
    }
}

// MARK: - ways of looking (chapter acts)

@MainActor
@Suite("Tutorial acts — ways of looking")
struct TutorialLookingActsTests {
    @Test func adoptingTheOtherReadingSwapsAndNeverDestroys() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "lenses") }
            let before = try await projection(db, lesson)
            let lens = try #require(before.lenses.first { $0.name == "the other reading" })
            let picks = try #require(before.lensSelections[lens.id])
            let oldChosen = before.slots.compactMap(\.variantID)

            try await session.runner.run { ops in
                _ = try ops.adoptLensPreservingChosen(lens.id)
            }
            let after = try await projection(db, lesson)
            for (blockID, variantID) in picks {
                let slot = try #require(after.slots.first { $0.blockID == blockID })
                #expect(slot.variantID == variantID, "the post now shows the lens's picks")
            }
            // Adopting SWAPS, never destroys: the outgoing chosen is kept.
            let preservation = try #require(after.lenses.first { $0.name.hasPrefix("chosen until") })
            let preserved = after.lensSelections[preservation.id] ?? [:]
            for (blockID, variantID) in preserved {
                #expect(oldChosen.contains(variantID),
                        "the preservation lens holds the OLD chosen for \(blockID)")
            }
        }
    }

    @Test func theVersionTwinIsLinkedAndIndependent() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "compare & versions") }
            let lessonSlots = try await slots(db, lesson)
            let peers = try await db.read { try Queries.versionPeers($0, of: lessonSlots[0].blockID) }
            let peerBlock = try #require(peers.first)
            let twinPost = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT container_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [peerBlock])
            }
            let twinID = try #require(twinPost)

            // Edit the twin brutally; the original never feels it.
            let twinSlots = try await slots(db, twinID)
            try session.operations.autosave(
                twinSlots[0].variantID!, text: "rewritten beyond recognition", charDelta: 30)
            let originalAfter = try await slots(db, lesson)
            #expect(originalAfter[0].text == lessonSlots[0].text,
                    "a version is a different post — edits never bleed")

            // The twin wears the tag too (the restore identity promise).
            let twinTagged = try await db.read { db -> Bool in
                guard let tag = try Queries.allTags(db).first(
                    where: { $0.path == TutorialSeeder.tagName }) else { return false }
                return try Queries.everythingTagged(db, tagID: tag.id, includeSubtree: true)
                    .postIDs.contains(twinID)
            }
            #expect(twinTagged, "the twin is the tutorial's to clean up")
        }
    }

    /// 13b 4C: the mint's lesson home moved — the COMPARE lesson teaches
    /// "make outline post" now (Compare's header, the retired Outline
    /// tab's one unique power, S4-3/R99). The act runs on that lesson's
    /// own content, and the mint REGISTERS beside its draft through the
    /// same lineage kinship the board reads.
    @Test func outlineMintsALinkedCondensation() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "compare & versions")
            }
            // The lesson's prose PROMISES the door's new home.
            let prose = try await slots(db, lesson).compactMap(\.text).joined(separator: "\n")
            #expect(prose.contains("make outline note"),
                    "the compare lesson teaches the outline door")
            #expect(prose.contains("there is no relationship here"),
                    "the honesty line is promised where compare is taught")

            let result = try await session.runner.run { ops in
                try ops.mintOutlinePost(of: lesson)
            }
            #expect(result.post.title?.hasPrefix("outline of") == true)
            let outlineSlots = try await slots(db, result.post.id)
            let sourceSlots = try await slots(db, lesson)
            #expect(outlineSlots.count == sourceSlots.count, "one outline point per block")

            // "registered point by point": every outline block kins its
            // source in the board's own kinship read.
            let kinship = try await db.read { db in
                try Queries.blockKinship(db, anchor: lesson, other: result.post.id)
            }
            #expect(kinship.count == outlineSlots.count,
                    "every outline point registers beside the block it condenses")
        }
    }

    /// 13b 4C: the compare lesson's honesty promise, executable — an
    /// UNRELATED lesson post composes to ONE free segment (plain side by
    /// side, no aligned rows), while the seeded twin aligns.
    @Test func compareHonestyHoldsOnTheLessonsOwnContent() async throws {
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "compare & versions")
            }
            let unrelated = try await db.read {
                try lessonID($0, bookID: bookID, "blocks \u{B7} canvas")
            }
            let strangerKinship = try await db.read { db in
                try Queries.blockKinship(db, anchor: lesson, other: unrelated)
            }
            #expect(strangerKinship.isEmpty, "two lessons share no lineage")
            let lessonBlocks = try await slots(db, lesson).map(\.blockID)
            let strangerBlocks = try await slots(db, unrelated).map(\.blockID)
            let plain = CompareComposition.segments(
                anchorBlocks: lessonBlocks,
                peerBlocks: [strangerBlocks],
                kinships: [strangerKinship],
                followAnchorOrder: true)
            #expect(plain == [.free(anchor: lessonBlocks, peers: [strangerBlocks])],
                    "no relationship ⇒ plain side-by-side, no blanks, nothing aligned")

            // 13c 2E — the lesson's OWN promise about "related blocks only":
            // on an unrelated pair it must tell her there is nothing to show
            // rather than showing her nothing. The filter leaves both columns
            // empty, which is precisely the state the board speaks over.
            let filtered = CompareComposition.relatedOnly(
                anchorBlocks: lessonBlocks, peerBlocks: [strangerBlocks],
                kinships: [strangerKinship])
            #expect(filtered.anchorBlocks.isEmpty)
            #expect(filtered.peerBlocks == [[]])
            #expect(CompareComposition.segments(
                anchorBlocks: filtered.anchorBlocks, peerBlocks: filtered.peerBlocks,
                kinships: [strangerKinship], followAnchorOrder: true).isEmpty,
                    """
                    related-blocks-only over an unrelated pair composes NOTHING — \
                    the board says so instead of rendering emptiness as content
                    """)

            // The twin, by contrast, aligns everywhere lineage speaks.
            let versionSlots = try await slots(db, lesson)
            let peers = try await db.read { try Queries.versionPeers($0, of: versionSlots[0].blockID) }
            #expect(!peers.isEmpty, "the twin is still seeded")
        }
    }

    @Test func canvasRemembersAnArrangement() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "blocks \u{B7} canvas")
            }
            let first = try await slots(db, lesson)[0]
            _ = try await session.runner.run { ops in
                try ops.setCanvasPosition(container: lesson, block: first.blockID, x: 42, y: 17)
            }
            let layouts = try await db.read { try Queries.canvasLayouts($0, container: lesson) }
            #expect(layouts[first.blockID]?.x == 42)
            #expect(layouts[first.blockID]?.y == 17, "arrangement is yours and is remembered")
        }
    }

    /// 13b 4E (N30/S4-7f): the canvas lesson teaches the reworked canvas,
    /// and its one spatial→structural door RUNS on the lesson's own
    /// content — click cards in order, one Apply reorders the post, one
    /// ⌥⌘Z restores it whole.
    @Test func clickInOrderReordersTheCanvasLessonBlocks() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "blocks \u{B7} canvas")
            }
            // The lesson's prose PROMISES the package it teaches.
            let prose = try await slots(db, lesson).compactMap(\.text).joined(separator: "\n")
            #expect(prose.contains("order by clicking"),
                    "the lesson names the click-in-order door")
            #expect(prose.contains("edits land on the take the card is showing"),
                    "the lesson promises editable cards (S4-7c)")
            #expect(prose.contains("resize it from the corner grip"),
                    "the lesson promises resizable cards (S4-7d)")
            #expect(prose.contains("Fit all"), "the lesson names the fit-all door")
            #expect(prose.contains("\u{2325}\u{2318}Z undoes"), "the undo road is named")

            let before = try await slots(db, lesson).map(\.blockID)
            #expect(before.count >= 3, "the lesson has cards to order")

            let model = CanvasViewModel(session: session, containerID: lesson)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: lesson) })
            model.enterOrderMode()
            // Click the LAST card first, then the first — the numbered
            // preview shows as the prose promises.
            model.toggleOrderClick(blockID: before[before.count - 1])
            model.toggleOrderClick(blockID: before[0])
            #expect(model.pendingOrderNumber(blockID: before[before.count - 1]) == 1)
            await model.applyOrder()

            let after = try await slots(db, lesson).map(\.blockID)
            #expect(after.first == before.last,
                    "the clicked cards lead the post in click order")
            #expect(after[1] == before[0])

            // One ⌥⌘Z restores the whole arrangement (ONE compound).
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in
                try undoStack.undo(with: ops)
            }
            let restored = try await slots(db, lesson).map(\.blockID)
            #expect(restored == before, "one undo restores the pre-order arrangement")
        }
    }
}

// MARK: - the library of things (chapter acts)

@MainActor
@Suite("Tutorial acts — the library of things")
struct TutorialLibraryActsTests {
    @Test func theCommentSurvivesEditDeleteAndRestore() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "comments & tags") }
            let block = try await slots(db, lesson)[0]
            let comment = try #require(try await db.read { db in
                try Queries.blockComments(db, blockID: block.blockID).first
            })
            try session.operations.editBlockComment(comment.id, text: "an edited margin note")
            try session.operations.deleteBlockComment(comment.id)
            let deleted = try await db.read { try Queries.deletedBlockComments($0, blockID: block.blockID) }
            #expect(deleted.contains { $0.id == comment.id },
                    "deleted comments stay visible — never skimpy")
            try session.operations.restoreBlockComment(comment.id)
            let live = try await db.read { try Queries.blockComments($0, blockID: block.blockID) }
            #expect(live.contains { $0.id == comment.id && $0.text == "an edited margin note" })
        }
    }

    @Test func theBookFinishesReversiblyAndChaptersReorder() async throws {
        try await withTutorialWorld { session, db, bookID in
            // ✓ finished — freezes structure, reversibly.
            try session.operations.lockReading(bookID)
            #expect(throws: Error.self, performing: {
                try session.operations.createSection(in: bookID, name: "too late")
            })
            try session.operations.unlockReading(bookID)

            // Chapters reorder like everything else.
            let chapters = try await db.read { db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT id, name FROM reading_section
                        WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [bookID]
                ).map { (id: $0["id"] as String, name: $0["name"] as String) }
            }
            let last = try #require(chapters.last)
            try session.operations.reorderSection(last.id, to: .start)
            let reordered = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT name FROM reading_section
                        WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [bookID])
            }
            #expect(reordered.first == last.name, "chapters are real, reorderable things")
        }
    }

    /// 13b 4F (S4-9 + N36 + N37): the books lesson's new promises, run on
    /// the field guide itself — the pages flip the guide's own lessons,
    /// the per-post target face is real, and a deleted book restores
    /// WHOLE (the S4-28.2 reversal, exercised on the tutorial book).
    @Test func pagesFlipTheGuideTargetsAreRealAndTheBookRestoresWhole() async throws {
        try await withTutorialWorld { session, db, bookID in
            // The prose promises (P-6: the lesson says it, the app does it).
            // 13i-d U7, a JUSTIFIED EDIT (the subject MOVED, by the U7 brief):
            // "books & the shelf" left "the library of things" for the books
            // chapter — its views/targets paragraphs are "a book from the
            // inside", its deletion paragraph "membership, not ownership".
            // Every assertion below is unchanged; only where it reads moved.
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "a book from the inside") }
            let membership = try await db.read {
                try lessonID($0, bookID: bookID, "membership, not ownership")
            }
            let prose = try await slots(db, lesson).compactMap(\.text).joined(separator: "\n")
                + "\n" + (try await slots(db, membership).compactMap(\.text).joined(separator: "\n"))
            // 13c 2A/2B/2C: the lesson's vocabulary is the shipped one. The
            // old single "progress bar" claim is replaced by the four the
            // three modes actually make (A6 removed the bar itself).
            #expect(prose.contains("OUTLINE"), "the lesson teaches the writing surface")
            #expect(prose.contains("BOOK"), "…the two-up spread")
            #expect(prose.contains("READ"), "…and the reading pair")
            #expect(prose.contains("PAGES"), "the lesson teaches the paginated face")
            #expect(prose.contains("flowing across"), "…and says what makes it a page")
            #expect(prose.contains("click the word counts"))
            // 13j batch 6 — A JUSTIFIED PIN EDIT (the bounded copy alignment
            // the brief allows; batch 7 owns the deletion chapter itself):
            // the CLAIM is unchanged — the lesson teaches that a deleted book
            // is recoverable and names the door — but the door's verb is the
            // Trash's one verb now, and the lesson says the window too.
            #expect(prose.contains("Put back door"))
            #expect(prose.contains("30 days"))

            // PAGES: the page brain flips the guide post by post (the
            // model-driven domain — the entry list).
            let model = BookViewModel(session: session, readingID: bookID)
            await model.adopt(try await db.read { [bookID] in
                try Queries.assembleReading($0, readingID: bookID, limit: 300)
            })
            #expect(model.leftPage != nil)
            let total = model.entries.count
            // 13c 2B: the pages are a two-up SPREAD now — the same
            // model-driven domain (the entry list), turned a leaf at a time.
            model.openSpread(leftIndex: total - 1)
            #expect(model.leftPage?.postID == model.entries.last?.postID,
                    "the spread reaches the last page")
            #expect(model.rightPage == nil, "…and the last leaf is honest about its blank half")
            model.turnLeaf(by: 1)
            #expect(model.spreadLeftIndex == total - 1, "the last cover clamps")
            model.showPost(lesson)
            #expect(model.isOnSpread(lesson), "the navigator jumps to a page")

            // 13c 2C — PAGES: the guide paginates for real. The domain is
            // built from the extent index (lengths, no prose), the spread
            // draws two addresses, and turning the leaf walks two pages
            // ACROSS posts. Nothing here asks a layout engine for a height.
            let paged = PagedReadModel(session: session)
            await paged.adopt(entries: model.entries, chapterOpeners: [:])
            #expect(paged.index.totalPages >= model.entries.count,
                    "every lesson is at least a page")
            #expect(paged.leaves.compactMap { $0 }.count == 2, "a spread of two leaves")
            #expect(paged.pageLine.contains("pages 1–2"))
            let firstAddress = paged.position
            paged.turn(by: 2)
            try? await Task.sleep(for: .milliseconds(50))
            #expect(paged.position != firstAddress, "the leaf turned")
            #expect(paged.index.pageNumber(of: paged.position) == 3, "…by two pages")
            #expect(paged.realizedPostCount <= PagedReadModel.cacheLimit,
                    "and the rest of the guide was never composed (P1)")

            // The per-post word target on the lesson's own post: set,
            // progress computes, clear (display only — the lesson's words:
            // a measure, never a wall).
            try session.operations.setPostWordTarget(lesson, wordTarget: 500)
            let header = try await db.read { try Queries.containerHeader($0, containerID: lesson) }
            #expect(header?.wordTarget == 500)
            try session.operations.setPostWordTarget(lesson, wordTarget: nil)

            // The RESTORE door, on the field guide itself: delete the
            // whole book, restore it — chapters, memberships, and
            // assignments come back exactly (the exact-stamp rule).
            let before = try await db.read { [bookID] db in
                (sections: try Queries.readingSections(db, readingID: bookID).map(\.id),
                 entries: try Queries.assembleReading(db, readingID: bookID).map(\.postID),
                 assignments: try Queries.sectionAssignments(db, readingID: bookID))
            }
            try session.operations.deleteReading(bookID)
            let deadGuide: Reading? = try await db.read { [bookID] in
                try Queries.reading($0, id: bookID)
            }
            #expect(deadGuide == nil)
            let listedDeleted: [String] = try await db.read {
                try Queries.deletedReadings($0, now: harnessNow).map(\.id)
            }
            #expect(listedDeleted == [bookID],
                    "the recovery surface lists the deleted guide")
            try session.operations.restoreReading(bookID)
            let after = try await db.read { [bookID] db in
                (sections: try Queries.readingSections(db, readingID: bookID).map(\.id),
                 entries: try Queries.assembleReading(db, readingID: bookID).map(\.postID),
                 assignments: try Queries.sectionAssignments(db, readingID: bookID))
            }
            #expect(after.sections == before.sections, "all six chapters back, in order")
            #expect(after.entries == before.entries, "every lesson back, in order")
            #expect(after.assignments == before.assignments, "every chapter assignment back")
        }
    }

    @Test func scrapsDragCopyOutAndTheFanRidesWithOption() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "pool & scraps") }
            let (plainScrap, fannedScrap) = try await db.read { db -> (String, String) in
                guard let pool = try Queries.pools(db).first(
                    where: { $0.title == TutorialSeeder.scrapPoolTitle })
                else { throw TutorialWalkError.missingStagedContent("tutorial scraps") }
                let items = try Queries.renderPost(db, containerID: pool.id)
                return (items[0].blockID, items[1].blockID)
            }

            // Drag: a copy with lineage; the scrap stays home.
            let copy = try await session.runner.run { ops in
                try ops.poolDragCopy(plainScrap, to: lesson, at: .end)
            }
            let edge = try await db.read { db in
                try Edge.fetchOne(
                    db,
                    sql: """
                        SELECT * FROM edge WHERE source_block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [copy.block.id])
            }
            #expect(edge?.originOp == "pool_copy", "it lands as a COPY with lineage")
            let scrapStays = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [plainScrap]) ?? 0
            }
            #expect(scrapStays == 1, "the scrap stays in its pool")

            // ⌥-drag: the whole fan rides.
            let fanCopy = try await session.runner.run { ops in
                try ops.poolDragCopy(fannedScrap, to: lesson, at: .end, includeFan: true)
            }
            let copiedTakes = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        """,
                    arguments: [fanCopy.block.id]) ?? 0
            }
            #expect(copiedTakes == 2, "\u{2325}-drag carries both takes along")
        }
    }

    /// **13u4 UNIT S3 — KnownIssues row 68: the chapter's prose against the
    /// surface's own vocabulary.** It taught *"the Snippets area's pool menu
    /// switches between pools"* — a control no surface has — and called the
    /// items SCRAPS where every UI string says SNIPPET (the pre-13u
    /// vocabulary ruling, W8-1). That is the copy-truth class 13u3 UNIT H
    /// closed twice on the takes lesson, and the H pattern is its remedy:
    /// **the prose is written plainly and every door it names is asserted
    /// from that door's own constant here**, so the next rename makes this
    /// lesson RED rather than merely wrong.
    ///
    /// **RED ON OLD:** the seeded text at `bcd34d04` contains "pool menu"
    /// and "switches between pools", and contains neither "groups column"
    /// nor the word "snippet" at all.
    @Test func thePoolAndScrapsLessonSpeaksTheSurfacesVocabulary() async throws {
        try await withTutorialWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, "pool & scraps"))
            }

            // The retired control, and the retired noun for the ITEM.
            #expect(!prose.localizedCaseInsensitiveContains("pool menu"),
                    "no surface has a pool menu — the groups column is what switches")
            #expect(!prose.localizedCaseInsensitiveContains("between pools"))
            #expect(!prose.localizedCaseInsensitiveContains("a scrap"),
                    "the item's word is SNIPPET everywhere the app says it")

            // The words the SURFACE uses, each read from its own home.
            #expect(prose.contains(SnippetsCopy.groupsHeader),
                    "the column that switches, by its own name")
            #expect(prose.contains(SnippetsCopy.allGroups),
                    "…and the row at its top that shows every group at once")
            #expect(prose.contains(SnippetsCopy.tagsRow), "the tag door's own words")
            #expect(prose.contains(SnippetsCopy.moveRow), "and the move door's")
            #expect(prose.contains(PostDetailView.scrapsDoorTitle),
                    "the note's panel door, from the door's own constant")
            #expect(prose.contains(TutorialSeeder.scrapPoolTitle),
                    "the seeded group is named by the reserved identity itself")
            #expect(prose.localizedCaseInsensitiveContains("snippet"))

            // The dashed box's promise is the surface's promise — tied here
            // rather than quoted into the prose, which would make this line
            // assert nothing (this suite's own rule, one chapter over).
            #expect(prose.contains("standalone snippet"))
            #expect(SnippetsCopy.entryCue.contains("standalone snippet"),
                    "…and that is what the box itself says")

            // The POOL keeps its name (R29): the bookless-notes room was
            // never part of the Snippets vocabulary ruling, and a sweep that
            // took it too would have taught her a room that is not there.
            #expect(prose.contains("POOL (sidebar)"))
        }
    }

    @Test func exportsShowTheFansAndTheChapters() async throws {
        try await withTutorialWorld { _, db, bookID in
            let choosing = try await db.read { try lessonID($0, bookID: bookID, "choosing & the board") }
            let postMarkdown = try await db.read {
                try Queries.exportPost($0, postID: choosing, includeVariants: true)
            }
            #expect(postMarkdown.contains("Alternates"),
                    "a fanned block exports with its fan showing")
            #expect(postMarkdown.contains("verdict"), "every open take reaches paper")

            // The whole book exports as ONE document (every lesson inside)
            // WITH its chapters as headings — the 3B core seam (N13)
            // reaching paper through the existing door; the lesson now
            // promises it, so the walk asserts it (P-6).
            let bookMarkdown = try await db.read { try Queries.exportReading($0, readingID: bookID) }
            #expect(bookMarkdown.contains("# \(TutorialSeeder.bookName)"))
            for chapter in TutorialSeeder.plan.map(\.chapter) {
                #expect(bookMarkdown.contains("## \(chapter)"),
                        "every chapter heads its lessons on paper (N13/3B)")
            }
            for title in TutorialSeeder.plan.flatMap(\.lessons) {
                #expect(bookMarkdown.contains(title), "every lesson reaches the one document")
            }

            let rainBlockID = try await db.read { db -> String? in
                try Queries.renderPost(db, containerID: choosing)
                    .first { $0.text?.contains("The rain came in from the sea") == true }?
                    .blockID
            }
            let blockMarkdown = try await db.read { db in
                try Queries.exportBlock(db, blockID: rainBlockID ?? "")
            }
            #expect(blockMarkdown.contains("rain"), "a block exports alone")
        }
    }

    /// 13r U3-A — R-13r-14: the field guide teaches WHERE backups live on
    /// their own and the SECOND-FOLDER door, by the surfaces' own words —
    /// the Settings pane's title, the pane's section title (the SAME
    /// constant the pane renders), the door's registry verb, and the offer's
    /// own question (R-13r-12's toast). P-6: a renamed door is a red test.
    @Test func theExportLessonTeachesWhereBackupsLiveAndTheSecondFolderDoor() async throws {
        try await withTutorialWorld { _, db, bookID in
            let prose = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, "export \u{2014} it's all yours"))
            }
            #expect(prose.contains("BACKUPS happen on their own"))
            #expect(prose.contains("beside the library, on this Mac"),
                    "where the automatic copies live")
            #expect(prose.contains("Settings \u{25B8} \(SettingsPane.dataSafety.title)"),
                    "the pane's real name")
            #expect(prose.contains("\u{201C}\(DataSafetyCopy.secondFolderSection)\u{201D}"),
                    "the section's real title — the constant the pane renders")
            #expect(prose.contains(CapabilityRegistry.capability(.chooseBackupFolder).verb),
                    "the door's real verb")
            #expect(prose.contains("iCloud Drive"))
            #expect(prose.contains("\u{201C}\(ProtectionCopy.iCloudOfferTitle)\u{201D}"),
                    "the offer's own question, word for word")
        }
    }

    @Test func theSealRefusesOutLoudAndTheToastShowsIt() async throws {
        // The deliberate-refusal show-and-tell: the tutorial makes a
        // refusal happen ON PURPOSE and points at the spoken answer.
        try await withTutorialWorld { session, db, bookID in
            let sealedLesson = try await db.read { try lessonID($0, bookID: bookID, "the seal") }
            let model = TakesViewModel(session: session, postID: sealedLesson)
            model.adopt(try await projection(db, sealedLesson))
            let first = model.projection.slots[0]
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.blockID, variantID: first.variantID!))

            // ⌘S on the sealed post: the operation's REAL refusal, spoken.
            // 18m U3 (SANCTIONED EDIT S-2, the U3 CLASSIFICATION RULING): the
            // registry's seal line converged on ONE sentence — its old act
            // clause ("to change takes or choices") was false right here,
            // where ⌘S files a savepoint (PROVISIONAL, QUESTIONS #159).
            await model.commitFocusedTake()
            #expect(session.status.current?.text
                    == "This note is sealed — unseal it first.",
                    "the refusal lands in the one status presentation — that's the lesson")

            // Unseal (the bar's door), change a word, seal again. The real
            // board re-adopts the projection between toggles (observation
            // delivers it); the test mirrors that.
            await model.toggleSeal()
            let unsealed = try await db.read { try Queries.containerHeader($0, containerID: sealedLesson) }
            #expect(unsealed?.locked == false, "the unseal door is right in the bottom bar")

            try session.operations.autosave(
                first.variantID!, text: "changed while unsealed", charDelta: 10)
            model.adopt(try await projection(db, sealedLesson))
            await model.toggleSeal()
            let resealed = try await db.read { try Queries.containerHeader($0, containerID: sealedLesson) }
            #expect(resealed?.locked == true, "sealed again — reversible and gentle")
        }
    }

    @Test func threeWaysLessonCarriesItsPracticeFan() async throws {
        // The A10 absorption: the polish/thread/fork teaching now lives
        // here, act-ready.
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "three ways of working") }
            let lessonProjection = try await projection(db, lesson)
            let thread = try #require(lessonProjection.slots.first {
                $0.text?.contains("keeper's logbook") == true
            })
            #expect(lessonProjection.fans[thread.blockID]?.count == 2,
                    "the thread block has its practice take")
            let texts = lessonProjection.slots.compactMap(\.text).joined()
            #expect(texts.contains("POLISH IN PLACE"))
            #expect(texts.contains("THREAD ONE PIECE"))
            #expect(texts.contains("FORK THE PIECE"))
        }
    }
}

// MARK: - deleting & getting it back (chapter acts — 13j J10)

/// The chapter's name, in one place: the plan, the seeder's section and this
/// suite all mean the same six words.
private let deletionChapter = "deleting & getting it back"

/// An editor over a lesson, wired exactly as `withEditor` wires one — the
/// REAL `EditorTextView` through `EditorSurfaceDelegate`, so a selection and
/// a Delete key travel `shouldChangeTextIn` → the planners → the compound,
/// the same path her keyboard takes.
@MainActor
private func tutorialEditor(
    _ session: AppSession, _ db: AppDatabase, postID: String
) throws -> EditorHarness {
    let model = EditorViewModel(session: session, postID: postID)
    model.tailIdleSleep = { _ in throw CancellationError() }
    model.longBlockLayout.sleep = { _ in throw CancellationError() }
    let (scrollView, textView) = EditorTextView.makeEditor()
    let delegate = EditorSurfaceDelegate(model: model)
    delegate.wire(to: textView)
    model.attach(textView: textView, scrollView: scrollView)
    let harness = EditorHarness(
        session: session, database: db, model: model,
        textView: textView, surfaceDelegate: delegate, postID: postID)
    try harness.reload()
    return harness
}

/// The lesson's block whose text starts with `prefix` — the chapter stages
/// its practice blocks with loud prefixes precisely so a walk (and a reader)
/// can find them without counting.
@MainActor
private func staged(
    _ harness: EditorHarness, _ prefix: String
) throws -> Queries.RenderedBlock {
    let slots = try harness.storeSlots()
    guard let hit = slots.first(where: { $0.text?.hasPrefix(prefix) == true }) else {
        throw TutorialWalkError.missingStagedContent(prefix)
    }
    return hit
}

@MainActor
private func entryRange(_ harness: EditorHarness, _ blockID: String) throws -> NSRange {
    guard let index = harness.model.index.entries.firstIndex(where: { $0.blockID == blockID })
    else { throw TutorialWalkError.missingStagedContent(blockID) }
    return harness.model.index.range(ofEntryAt: index)
}

/// **What a TRIPLE-CLICK selects**, asked of the text view itself rather than
/// arithmetic'd: the lesson tells the reader to triple-click a paragraph (or
/// drag past its end), and that is the gesture whose range this walk deletes.
/// It matters that this is the view's own answer — a selection of the
/// paragraph's characters ALONE is an ordinary in-block edit (it empties the
/// block, the shipped behaviour the J9 pins characterize), and it is the
/// paragraph's terminator riding along that makes the span cross-block and
/// routes it to the delete compound.
@MainActor
private func tripleClickSelection(
    _ harness: EditorHarness, _ blockID: String
) throws -> NSRange {
    let entry = try entryRange(harness, blockID)
    return harness.textView.selectionRange(
        forProposedRange: NSRange(location: entry.location, length: 0),
        granularity: .selectByParagraph)
}

@MainActor
@Suite("Tutorial acts — deleting & getting it back")
struct TutorialDeletionActsTests {

    // MARK: - The chapter names only doors the app actually has (the J8 bar)

    /// **Every door the chapter promises, read from the door's OWN home.**
    /// The lessons are written in plain prose (never string-interpolated from
    /// the constants — a lesson that quoted the constant would assert
    /// nothing), and this pin ties each promise to the place the app spells
    /// it. A renamed door, a retired act or a re-worded section header makes
    /// this red, which is the J8 bar in executable form: *a lesson may not
    /// promise a door that isn't there.*
    @Test func everyDoorTheChapterNamesIsADoorTheAppHas() async throws {
        try await withTutorialWorld { _, db, bookID in
            let titles = try #require(
                TutorialSeeder.plan.first { $0.chapter == deletionChapter }?.lessons)
            let prose = try await db.read { db -> [String: String] in
                var out: [String: String] = [:]
                for title in titles {
                    out[title] = try Queries.renderedText(
                        db, containerID: lessonID(db, bookID: bookID, title))
                }
                return out
            }

            let deleting = try #require(prose["deleting blocks"])
            #expect(deleting.contains(TrayPath.menuLabel), "the tray's real name")
            #expect(deleting.contains(TrayPath.doorGlyph), "the badge's real glyph")
            #expect(deleting.contains(BlockSelectionCopy.deleteVerb(picked: 2)),
                    "the multi-delete row's real words")
            #expect(deleting.contains("\u{2325}\u{2318}Z") && deleting.contains("\u{21E7}\u{2325}\u{2318}Z"),
                    "both structural chords, as the hint itself names them")

            let trio = try #require(prose["archive \u{B7} delete \u{B7} scraps"])
            #expect(trio.contains(CapabilityRegistry.capability(.archiveBlock).verb))
            #expect(trio.contains(CapabilityRegistry.capability(.deleteBlock).verb))
            // Her G5 split: the archive lesson names the ARCHIVED view and
            // the delete lesson names LEAVING — the tray's own words, quoted
            // from the constants, so a rename reaches the lesson.
            // (18d batch 2 turned the two SECTIONS into the two VIEWS of a
            // segmented choice — U-9 — and the round-1 ladder's MAJOR-1 swept
            // the seeder; the claim is unchanged and now quotes the tab
            // constants, which the sections' names never were.)
            #expect(trio.contains("\(TrayPath.archivedTab) view"),
                    "the tray view archive's own row lands in")
            #expect(trio.contains("\(TrayPath.leavingTab) view"),
                    "and the one delete's row lands in")
            #expect(trio.contains(TrayPath.archivedForever), "archive's own promise, in its own words")
            // **A JUSTIFIED EDIT (13u3 UNIT H) — and the pin that should have
            // caught this instead LOCKED IT IN.** It asserted the literal
            // string `"Move out to a pool"` and called it "verbatim", but the
            // Blocks-mode row has read *"Move out to snippets (leaves this
            // note)"* since the Snippets vocabulary ruling (pre-13u, W8-1) —
            // so a reader following the lesson looked in the menu for a row
            // that is not in it, and a green pin said the words were right.
            // The claim is unchanged; its source is the ROW's own constant
            // now, which is what "verbatim" was supposed to mean. RED ON OLD:
            // the seeded trio at `4f069b1b` does not contain the row's text.
            #expect(trio.contains(SnippetsCopy.moveOutRow),
                    "the Blocks-mode row, from the row's own constant")
            #expect(trio.contains("\(TrashWindow.days) days"), "the ruled window, not a number of its own")

            let trash = try #require(prose["the tray & the Trash"])
            #expect(trash.contains(TrayPath.menuLabel))
            // **18d's round-1 ladder, MAJOR-1 (P-6: the tutorial is the
            // executable spec).** The lesson taught the control batch 2
            // retired — *"The tray has two sections"* and the takes *"(folded
            // away until you open them)"* — so she was sent looking for a
            // disclosure triangle that no longer exists under cards that are
            // no longer stacked under headers. It teaches the shipped control
            // now: two VIEWS at the top, one shared filter under them.
            // RED ON OLD: both retired phrases are in the seeded text at
            // `86f01d64`.
            #expect(!trash.contains("two sections"),
                    "the tray's two stacked sections became a segmented choice (U-9)")
            #expect(!trash.lowercased().contains("folded away"),
                    "and the takes fold became a filter chip carrying its own count")
            #expect(trash.contains(TrayPath.leavingTab) && trash.contains(TrayPath.archivedTab),
                    "the two views, by the names the control renders")
            #expect(trash.contains(RecoveryCopy.trayFilterAll)
                && trash.contains(RecoveryCopy.trayFilterBlocks)
                && trash.contains(RecoveryCopy.trayFilterTakes),
                    "and the one filter under them, chip by chip")
            // The post-13l polish round (ledger row 17): the lesson's path
            // constant now names the Block History pane's came-from region,
            // because that is where an unclocked original lives after her G5
            // ruling. The lesson quotes the CONSTANT, so it followed for free.
            #expect(trash.contains(BlockHistoryPath.cameFromSection))
            #expect(trash.contains(TrayPath.putBackVerb), "the one verb, both surfaces")
            #expect(trash.contains(RecoveryPath.menuLabel), "how the Library door reads")
            #expect(trash.contains(RecoveryPath.trashSection))
            #expect(trash.contains(RecoveryPath.archivedSection))
            #expect(trash.contains(CapabilityRegistry.capability(.deleteNow).verb))
            #expect(trash.contains(CapabilityRegistry.capability(.emptyTrash).verb))
            // **The post-13l polish round, ledger row 12 (D2).** This lesson
            // taught *"No door inside a note ever deletes something for
            // good"*, and her G5 ruling superseded it IN PART: the note's own
            // Leaving section carries Delete Now on its take rows, *"to keep
            // the capability"* after takes left the global Trash. The rule
            // that replaced it is checkable against the two surfaces
            // themselves, which is what makes this a lesson and not a slogan.
            // (18d batch 2 turned the Leaving SECTION into the tray's
            //  Leaving VIEW — U-9; the claim is the same one, quoted from the
            //  tab constant so a rename reaches the lesson.)
            #expect(trash.contains("\(TrayPath.leavingTab) view"),
                    "the second place a purge door lives, named")
            #expect(!trash.contains("No door inside a note"),
                    "…and the superseded absolute is gone")
            #expect(TrayPanel.surfaceCapabilities.contains(.deleteNow),
                    "the note's own trash section really carries it")
            #expect(!BlockHistoryPane.surfaceCapabilities.contains(.deleteNow),
                    "…and a block's history really does not, exactly as the lesson says")

            let past = try #require(prose["what a block leaves behind"])
            #expect(past.contains(BlockPastCopy.deletedTakesHeader))
            #expect(past.contains(OriginPeekCopy.doorVerb(op: "divide")),
                    "the context row's ruled wording")
            // The pane's own verb, not the retired peek's (the post-13l
            // polish round, ledger row 17): the came-from row's one button.
            #expect(past.contains(BlockHistoryPath.bringBackVerb))
            #expect(past.contains(BlockHistoryPath.cameFromSection))
            #expect(past.contains("the original is preserved"),
                    "the History face's lineage row, in the lesson's mouth")
            #expect(past.contains(TrayPath.goesWithItsFamily),
                    "the moving-over label, quoted from where it renders")
            // **A7's rider** (the post-13l polish round): her per-merge message
            // is DECLINED — *"it's annoying to see that message every time"* —
            // so the teaching it would have carried lands in the chapter
            // instead, and it has to say BOTH halves: that the silence is
            // deliberate, and where the joined blocks went.
            #expect(past.contains("says nothing at the time"),
                    "the declined message's teaching, in the lesson's mouth")
            #expect(past.contains("BOTH"),
                    "…and a merge's originals are ALL of them (her C2 ruling)")
        }
    }

    /// The staging the four lessons ask the reader to act on — the same
    /// contract `actReadyStagingIsInPlace` keeps for the older chapters.
    @Test func theChapterIsStagedForItsActs() async throws {
        try await withTutorialWorld { session, db, bookID in
            let deleting = try await db.read { try lessonID($0, bookID: bookID, "deleting blocks") }
            let deletingTexts = try await slots(db, deleting).compactMap(\.text)
            for prefix in ["SCRATCH ONE", "SCRATCH TWO", "SCRATCH THREE"] {
                #expect(deletingTexts.contains { $0.hasPrefix(prefix) },
                        "\(prefix) is staged to be deleted")
            }

            let trio = try await db.read {
                try lessonID($0, bookID: bookID, "archive \u{B7} delete \u{B7} scraps")
            }
            let trioTexts = try await slots(db, trio).compactMap(\.text)
            for prefix in ["ARCHIVE ME", "DELETE ME", "MOVE ME OUT"] {
                #expect(trioTexts.contains { $0.hasPrefix(prefix) }, "\(prefix) is staged")
            }

            let past = try await db.read {
                try lessonID($0, bookID: bookID, "what a block leaves behind")
            }
            let pastProjection = try await projection(db, past)
            let fanned = pastProjection.slots.filter {
                (pastProjection.fans[$0.blockID]?.count ?? 0) == 2
            }
            #expect(fanned.count == 2,
                    "one fanned block to divide, one carrying the spare take to delete")
            _ = session
        }
    }

    // MARK: - Lesson 1: deleting blocks

    /// **The lesson's first ask, executed:** select one whole paragraph and
    /// press ⌫. The block goes (never emptied, never merged), the receipt
    /// speaks, the block is in the note's tray, and one ⌥⌘Z brings it back.
    @Test func aWholeParagraphSelectionDeletesTheScratchBlockAndUndoBringsItBack() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "deleting blocks") }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let before = try harness.storeSlots()
            let scratch = try staged(harness, "SCRATCH ONE")

            let selection = try tripleClickSelection(harness, scratch.blockID)
            let scratchEntry = try entryRange(harness, scratch.blockID)
            #expect(selection.length == scratchEntry.length + 1,
                    """
                    a triple-click takes the paragraph AND its terminator — \
                    which is what makes this a delete rather than an emptying
                    """)
            harness.replace(selection, with: "")
            await harness.flush()

            let after = try harness.storeSlots()
            #expect(after.count == before.count - 1)
            #expect(!after.contains { $0.blockID == scratch.blockID },
                    "the paragraph is gone — not emptied, not joined to a neighbour")
            #expect(harness.model.statusMessage == BlockSelectionCopy.deletedNote(1),
                    "the delete compound's own receipt, never the refusal")

            // …and it is where the receipt says it is.
            let trayed = try await db.read { [now = session.now] db in
                try Queries.trayBlocks(db, postID: lesson, now: now)
            }
            #expect(trayed.contains { $0.blockID == scratch.blockID },
                    "the block waits in this note's tray, exactly as the lesson promises")

            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll { ((try? harness.storeSlots().count) ?? 0) == before.count }
            let restored = try harness.storeSlots()
            #expect(restored.map(\.blockID) == before.map(\.blockID),
                    "one ⌥⌘Z puts the paragraph back where it stood")
        }
    }

    /// **The lesson's second ask:** ⌘-click two blocks and use Delete 2
    /// Blocks. Both go under ONE undo entry — "one mistake to reverse, not
    /// five", which is what the prose promises.
    @Test func theTwoScratchParagraphsGoUnderOneUndoEntry() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "deleting blocks") }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let before = try harness.storeSlots()
            let two = try staged(harness, "SCRATCH TWO")
            let three = try staged(harness, "SCRATCH THREE")

            // The ⌘-click door itself (the surface's own entry point).
            #expect(harness.model.pickBlock(
                atOffset: try entryRange(harness, two.blockID).location, extending: false))
            #expect(harness.model.pickBlock(
                atOffset: try entryRange(harness, three.blockID).location, extending: false))
            #expect(harness.model.selectedBlocksInOrder == [two.blockID, three.blockID])
            #expect(harness.model.contextMenuItems().contains {
                $0.title == BlockSelectionCopy.deleteVerb(picked: 2)
            }, "the row the lesson names is on the menu, with the count in it")

            await harness.model.deleteSelectedBlocks()
            await harness.flush()
            let after = try harness.storeSlots()
            #expect(after.count == before.count - 2)
            #expect(harness.model.statusMessage?.hasPrefix(BlockSelectionCopy.deletedNote(2)) == true)
            #expect(harness.session.undoStack.topLabel == "Delete Blocks",
                    "ONE compound entry for the pair")

            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll { ((try? harness.storeSlots().count) ?? 0) == before.count }
            #expect(try harness.storeSlots().map(\.blockID) == before.map(\.blockID),
                    "one press brings back the whole delete")
        }
    }

    /// **The sign at the junction** (J7), met exactly where the lesson says
    /// it will be: a real ⌘Z in a real key window, after a structural delete,
    /// with nothing left in the text stack. The key is never consumed.
    @Test func commandZAfterTheLessonsDeleteNamesTheStructuralUndo() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "deleting blocks") }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let host = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
            host.addSubview(harness.textView)
            window.contentView = host
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(harness.textView)

            let scratch = try staged(harness, "SCRATCH ONE")
            harness.replace(try tripleClickSelection(harness, scratch.blockID), with: "")
            await harness.flush()
            #expect(session.undoMenuState.topLabel == "Delete Blocks")

            harness.textView.undoManager?.removeAllActions()
            harness.model.refuse("")
            let event = NSEvent.keyEvent(
                with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0,
                windowNumber: 0, context: nil, characters: "z",
                charactersIgnoringModifiers: "z", isARepeat: false, keyCode: 6)!
            let claimed = harness.textView.performKeyEquivalent(with: event)

            #expect(claimed == false, "⌘Z still does what ⌘Z does — the app only puts up a sign")
            #expect(harness.model.statusMessage == EditorUndoHint.message(
                for: .undo, textStackHasEntries: false,
                structuralUndoLabel: "Delete Blocks", structuralRedoLabel: nil))
        }
    }

    // MARK: - Lesson 2: archive · delete · scraps

    /// **The trio, all three fates, on the lesson's own staged blocks.**
    /// Archive keeps it with no clock; delete starts the 30-day countdown;
    /// move out cuts the tie to the note and leaves a scrap in the pool.
    @Test func theThreeVerbsSendTheirBlocksToThreeDifferentPlaces() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "archive \u{B7} delete \u{B7} scraps")
            }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let keeper = try staged(harness, "ARCHIVE ME")
            let doomed = try staged(harness, "DELETE ME")
            let mover = try staged(harness, "MOVE ME OUT")

            // ARCHIVE — the Block-menu / right-click door.
            harness.textView.setSelectedRange(
                NSRange(location: try entryRange(harness, keeper.blockID).location, length: 0))
            harness.model.updateCaretContext()
            await harness.model.archiveCaretBlock()
            await harness.flush()
            #expect(harness.model.statusMessage == BlockSelectionCopy.archivedNote)

            // DELETE — the same menu, one row down.
            try harness.reload()
            harness.textView.setSelectedRange(
                NSRange(location: try entryRange(harness, doomed.blockID).location, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()

            // MOVE OUT — Blocks (⌘6, the one mode order — this comment said ⌘5 until 13u3; the lesson itself was always right), the row's ⋯ menu.
            let pool = try await db.read { db in
                try Queries.pools(db).first { $0.title == TutorialSeeder.scrapPoolTitle }
            }
            let poolID = try #require(pool).id
            let toc = BlockTOCViewModel(session: session, postID: lesson)
            await toc.moveToPool(mover.blockID, poolID: poolID,
                                 poolTitle: TutorialSeeder.scrapPoolTitle)

            let (archived, deleted, poolBlocks, noteBlocks) = try await db.read {
                [now = session.now] db in
                (try Queries.archivedBlocks(db, postID: lesson).map(\.blockID),
                 try Queries.trayBlocks(db, postID: lesson, now: now),
                 try Queries.renderPost(db, containerID: poolID).map(\.blockID),
                 try Queries.renderPost(db, containerID: lesson).map(\.blockID))
            }
            #expect(archived == [keeper.blockID], "archived: kept, out of the note, no clock")
            #expect(deleted.map(\.blockID) == [doomed.blockID], "deleted: in the tray, counting down")
            #expect(TrashWindow.daysLeft(try #require(deleted.first).deletedAt, now: session.now)
                    == TrashWindow.days,
                    "…and the countdown starts at the full window")
            #expect(poolBlocks.contains(mover.blockID), "moved out: a scrap in the pool now")
            for gone in [keeper.blockID, doomed.blockID, mover.blockID] {
                #expect(!noteBlocks.contains(gone), "all three left the page")
            }

            // ⌥⌘Z brings the move back, as the lesson says.
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: lesson) }) ?? [])
                    .contains { $0.blockID == mover.blockID }
            }
            let backHome = try await db.read { try Queries.renderPost($0, containerID: lesson) }
            #expect(backHome.contains { $0.blockID == mover.blockID },
                    "the moved block comes home on one press")
        }
    }

    // MARK: - Lesson 3: the tray & the Trash

    /// **The tray's two sections and its one verb**, on the state lesson 2
    /// just produced: a deleted block, an archived block, and (after a
    /// fanned divide) a preserved original. Put back returns each of them to
    /// the place it stood in.
    @Test func theTrayPutsBackWhatTheNoteSetAside() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "archive \u{B7} delete \u{B7} scraps")
            }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let order = try harness.storeSlots().map(\.blockID)
            let keeper = try staged(harness, "ARCHIVE ME")
            let doomed = try staged(harness, "DELETE ME")

            harness.textView.setSelectedRange(
                NSRange(location: try entryRange(harness, keeper.blockID).location, length: 0))
            harness.model.updateCaretContext()
            await harness.model.archiveCaretBlock()
            await harness.flush()
            try harness.reload()
            harness.textView.setSelectedRange(
                NSRange(location: try entryRange(harness, doomed.blockID).location, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()

            let tray = TrayViewModel(session: session, postID: lesson)
            tray.adopt(try await db.read { [now = session.now] db in
                TrayViewModel.Snapshot(
                    deleted: try Queries.trayBlocks(db, postID: lesson, now: now),
                    archived: try Queries.archivedBlocks(db, postID: lesson),
                    originals: try Queries.preservedOriginals(db, postID: lesson),
                    strandedFates: try Queries.originFamilyClocks(
                        db, postID: lesson, now: now))
            })
            #expect(tray.deleted.map(\.blockID) == [doomed.blockID])
            #expect(tray.archived.map(\.blockID) == [keeper.blockID])
            #expect(!tray.isEmpty)

            await tray.putBackDeleted(doomed.blockID)
            #expect(tray.statusMessage == TrayPath.putBackWhereItWas)
            await tray.putBackArchived(keeper.blockID)
            #expect(tray.statusMessage == TrayPath.putBackWhereItWas)

            let restored = try await db.read {
                try Queries.renderPost($0, containerID: lesson).map(\.blockID)
            }
            #expect(restored == order,
                    "both come back in their own places — the lesson's \u{201C}where it stood\u{201D}")
        }
    }

    /// **The lesson's own practice, executed:** delete THIS lesson from the
    /// library, find it in the Trash with its countdown, and Put it back —
    /// into this book, in this chapter, in its place.
    @Test func theLessonItselfGoesToTheTrashAndComesBackIntoItsChapter() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "the tray & the Trash")
            }
            let before = try await db.read { [bookID] db in
                (entries: try Queries.assembleReading(db, readingID: bookID).map(\.postID),
                 assignments: try Queries.sectionAssignments(db, readingID: bookID))
            }

            // The library row's own door.
            let library = LibraryViewModel(session: session)
            await library.delete(postID: lesson)
            let gone = try await db.read { db in
                try Container.fetchOne(db, key: lesson)?.deletedAt != nil
            }
            #expect(gone == true)

            // The Trash lists it, with the days it has left.
            let recovery = RecoveryViewModel(session: session)
            let listing = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            recovery.adopt(archived: [], trash: listing)
            let row = try #require(recovery.trash.first { $0.id == lesson })
            #expect(row.kind == .note)
            #expect(recovery.daysLeft(row) == TrashWindow.days,
                    "a fresh tombstone wears the whole window")

            await recovery.putBack(row)
            #expect(recovery.lastError == nil)
            let after = try await db.read { [bookID] db in
                (entries: try Queries.assembleReading(db, readingID: bookID).map(\.postID),
                 assignments: try Queries.sectionAssignments(db, readingID: bookID))
            }
            #expect(after.entries == before.entries, "back in the book, in its place")
            #expect(after.assignments == before.assignments, "…and in its chapter")
        }
    }

    /// **The two doors that live in the Trash and nowhere else**, exactly as
    /// the lesson promises: registry-declared on ONE surface, and each
    /// confirm asked EVERY time, naming what it takes.
    @Test func thePurgeDoorsAreTrashOnlyAndAskEveryTime() async throws {
        try await withTutorialWorld { session, db, bookID in
            // In-Trash only, by declaration (P-1) — the lesson's "no door
            // inside a note ever deletes something for good".
            for id in [CapabilityID.deleteNow, .emptyTrash] {
                #expect(CapabilityRegistry.capability(id).doors == [.surface])
                #expect(RecoveryView.surfaceCapabilities.contains(id))
                #expect(!ContextBar.surfaceCapabilities.contains(id))
                #expect(!CommitBar.renderedCapabilities.contains(id))
                #expect(!TakesBottomBar.renderedCapabilities.contains(id))
            }

            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "the tray & the Trash")
            }
            let library = LibraryViewModel(session: session)
            await library.delete(postID: lesson)

            let recovery = RecoveryViewModel(session: session)
            recovery.adopt(archived: [], trash: try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            })
            let row = try #require(recovery.trash.first { $0.id == lesson })

            recovery.requestDeleteNow(row)
            let first = try #require(recovery.pendingConfirm)
            #expect(first.message == RecoveryPath.deleteNowConfirm(.note))
            recovery.cancelPendingPurge()
            recovery.requestDeleteNow(row)
            #expect(recovery.pendingConfirm != nil,
                    "asked EVERY time — there is no don't-ask-again to set")
            recovery.cancelPendingPurge()

            await recovery.requestEmptyTrash()
            let bulk = try #require(recovery.pendingConfirm)
            #expect(bulk.message.contains("1 note"),
                    "the bulk confirm names the full count by kind before it takes anything")
            recovery.cancelPendingPurge()
        }
    }

    // MARK: - Lesson 4: what a block leaves behind

    /// **The divide keeps the block it cut**, and the History face says so:
    /// the lineage row, the peek's own heading, and Put back in note — all
    /// on the lesson's own staged fanned block.
    @Test func theDividedBlocksPastNamesItsPreservedOriginalAndPutsItBack() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a block leaves behind")
            }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let before = try harness.storeSlots()
            let dividing = try #require(before.first {
                $0.text?.hasPrefix("This block has two takes") == true
            })
            let range = try entryRange(harness, dividing.blockID)

            // ⌘⇧D, mid-block — the fanned default (U-2, 18c batch 1): the
            // shown take is cut across two blocks, the other stays whole on
            // the first, and the block itself is kept preserved.
            harness.textView.setSelectedRange(
                NSRange(location: range.location + range.length / 2, length: 0))
            harness.model.updateCaretContext()
            await harness.model.invokeGesture(.divideAtCursor)
            await harness.flush()

            let after = try harness.storeSlots()
            #expect(after.count == before.count + 1)
            #expect(!after.contains { $0.blockID == dividing.blockID },
                    "the original was released, not edited — it is preserved whole")
            let successor = try #require(after.first {
                $0.text?.hasPrefix("This block has two takes") == true
            })

            let past = try await db.read { [now = session.now] db in
                try Queries.blockPast(db, blockID: successor.blockID, now: now)
            }
            let origin = try #require(past.origins.first)
            #expect(origin.blockID == dividing.blockID)
            #expect(OriginPeekCopy.lineageRow(op: origin.originOp, at: origin.at)
                .contains("the original is preserved"),
                    "the quiet row the lesson tells her to look for")
            #expect(OriginPeekCopy.doorVerb(op: origin.originOp)
                == "See original from divide\u{2026}", "the context row's ruled words")

            // …and the tray holds it in the clockless section meanwhile.
            let (originals, clocks) = try await db.read { db in
                (try Queries.preservedOriginals(db, postID: lesson).map(\.blockID),
                 try Queries.originFamilyClocks(db, postID: lesson, now: harnessNow))
            }
            #expect(originals.contains(dividing.blockID))
            #expect(clocks[dividing.blockID] == nil, "permanent while its descendants live")

            // The peek's first action.
            let receipt = try await PreservedOriginPutBack.run(
                session: session, postID: lesson, blockID: dividing.blockID)
            #expect(receipt == TrayPath.putBackBeside)
            let placed = try await db.read {
                try Queries.renderPost($0, containerID: lesson).map(\.blockID)
            }
            #expect(placed.contains(dividing.blockID), "Put back in note does what it says")
        }
    }

    /// **The deleting chapter's divide lesson teaches U-2's keep-on-top, and
    /// its words are pinned TO THE ACT** (ledger row 44; the 18f ladder's
    /// R3-2). Both the lesson's card 2 and the staged spare take dated from
    /// 13j's J4 duplicate default — *"the other take is copied whole onto
    /// both"*, *"I ride WHOLE onto both halves"* — and the U-2 sweep reached
    /// the structure chapter's ceremony lesson only, because neither text
    /// carries the word "ceremony". Since 18c batch 1 the act keeps the other
    /// takes whole on the FIRST block, so the prose predicted a shape the app
    /// no longer produces. P-6 (the guide is the executable spec): the same
    /// \u{2318}\u{21E7}D the lesson names is run here on the same staged fan,
    /// and the take counts it leaves are asserted beside the sentences that
    /// promise them — a future default flip makes BOTH halves red at once.
    @Test func theDeletingChaptersDivideLessonTeachesKeepOnTop() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a block leaves behind")
            }
            let projected = try await projection(db, lesson)
            let prose = projected.slots.compactMap(\.text).joined(separator: "\n")
            #expect(!prose.contains("copied whole onto both"),
                    "the retired J4 duplicate default, taught as fact")
            #expect(prose.contains("stays whole on the first block"),
                    "U-2's shape, in the lesson's own words")

            let dividing = try #require(projected.slots.first {
                $0.text?.hasPrefix("This block has two takes") == true
            })
            let fan = try #require(projected.fans[dividing.blockID])
            #expect(fan.count == 2, "the lesson's two takes are staged")
            let spare = try #require(fan.first {
                $0.workingText.hasPrefix("The other take of the dividing block")
            })
            #expect(!spare.workingText.contains("onto both halves"),
                    "the take she READS in the fan promised the old shape too")
            #expect(spare.workingText.contains("stay whole on the first block"),
                    "it says what it now does")

            // The act the lesson names, on the block the lesson stages.
            let harness = try tutorialEditor(session, db, postID: lesson)
            let wasThere = Set(try harness.storeSlots().map(\.blockID))
            let range = try entryRange(harness, dividing.blockID)
            harness.textView.setSelectedRange(
                NSRange(location: range.location + range.length / 2, length: 0))
            harness.model.updateCaretContext()
            await harness.model.invokeGesture(.divideAtCursor)
            await harness.flush()

            let successors = try harness.storeSlots()
                .filter { !wasThere.contains($0.blockID) }
            #expect(successors.count == 2)
            #expect(successors.map(\.activeVariantCount) == [2, 1],
                    "keep-on-top: the spare rides whole onto the FIRST block")
        }
    }

    /// **A deleted take waits in the same History face**, with Put back —
    /// label, place in the fan and savepoints intact, exactly as the lesson
    /// promises.
    @Test func theDeletedSpareTakeWaitsInTheBlocksPastAndComesBack() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a block leaves behind")
            }
            let projected = try await projection(db, lesson)
            let host = try #require(projected.slots.first {
                $0.text?.hasPrefix("Deleted TAKES wait") == true
            })
            let fan = try #require(projected.fans[host.blockID])
            #expect(fan.count == 2, "the spare take is staged")
            let spare = try #require(fan.first { $0.workingText.hasPrefix("the spare take") })

            // The take card's ⋯ menu ▸ Delete (both takes surfaces run this
            // one model door).
            let takes = TakesViewModel(session: session, postID: lesson)
            takes.adopt(projected)
            await takes.deleteTake(spare.id)

            let past = try await db.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: host.blockID, now: now)
            }
            #expect(past.deletedTakes.map(\.id) == [spare.id],
                    "listed under \(BlockPastCopy.deletedTakesHeader)")

            let model = BlockHistoryModel(
                session: session, postID: lesson, blockID: host.blockID)
            model.adopt(past)
            await model.putBackTake(spare.id)
            #expect(model.status == .receipt(BlockPastCopy.takeRestored))

            let back = try await projection(db, lesson)
            let restored = try #require(back.fans[host.blockID]?.first { $0.id == spare.id })
            #expect(restored.workingText == spare.workingText)
            #expect(restored.fanPosition == spare.fanPosition,
                    "its place in the fan came back with it")
        }
    }

    /// **The honest sentence, executed** (her round-8b ruling): the original
    /// is permanent only while a descendant lives. Delete the last one and
    /// the row MOVES onto the family's clock — and the delete that does it
    /// says so in its own receipt.
    @Test func theOriginalMovesOntoTheFamilysClockWhenItsLastDescendantGoes() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a block leaves behind")
            }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let wasThere = Set(try harness.storeSlots().map(\.blockID))
            let dividing = try staged(harness, "This block has two takes")
            let range = try entryRange(harness, dividing.blockID)
            harness.textView.setSelectedRange(
                NSRange(location: range.location + range.length / 2, length: 0))
            harness.model.updateCaretContext()
            await harness.model.invokeGesture(.divideAtCursor)
            await harness.flush()
            try harness.reload()

            // The two blocks that stand where the divided one stood — the
            // keep-on-top divide mints BOTH halves fresh (A is preserved).
            let successors = try harness.storeSlots().filter { !wasThere.contains($0.blockID) }
            #expect(successors.count == 2)

            // Delete both — the second one strands the original.
            for successor in successors {
                #expect(harness.model.pickBlock(
                    atOffset: try entryRange(harness, successor.blockID).location,
                    extending: false))
            }
            await harness.model.deleteSelectedBlocks()
            await harness.flush()

            #expect(harness.model.statusMessage?.hasSuffix(
                BlockSelectionCopy.strandedOriginalNote(1)) == true,
                "the receipt names the original it just put on the clock")

            let (clocks, originals) = try await db.read { db in
                (try Queries.originFamilyClocks(db, postID: lesson, now: harnessNow),
                 try Queries.preservedOriginals(db, postID: lesson))
            }
            #expect(clocks[dividing.blockID] != nil, "the original now rides the family's clock")

            let tray = TrayViewModel(session: session, postID: lesson)
            tray.adopt(TrayViewModel.Snapshot(
                deleted: try await db.read { [now = session.now] db in
                    try Queries.trayBlocks(db, postID: lesson, now: now)
                },
                archived: [], originals: originals, strandedFates: clocks))
            // The post-13l polish round (ledger row 20's staging, finished at
            // batch 4): the panel no longer LISTS unclocked originals at all
            // — they live in lineage now — so what this pin holds is the half
            // that still matters and always did: the row is visibly ON THE
            // CLOCK, in the section where she can watch it go.
            #expect(tray.stranded.contains { $0.blockID == dividing.blockID },
                    "…and it is visibly in the clock-bearing one, where she can see it go")
        }
    }
}

// MARK: - where things go (chapter acts — the post-13l polish round, G4)

/// The map chapter's name, in one place — the plan, the seeder's section and
/// this suite all mean the same three words.
private let placesChapter = "where things go"

/// **THE FIVE PLACES, EXECUTED.**
///
/// Her third-sitting expansion asked for a chapter that *"encouraged [the
/// reader] to get comfortable with each of the"* places, and her stated fear
/// is why: *"people are going to conclude that the one thing they really want
/// (my whole note at this point in time) … is way too hard to get, even though
/// we're actually offering infinitely more ways of saving your ideas."*
///
/// So this suite does what the deletion chapter's does one chapter up: it
/// PERFORMS what the prose asks the reader to perform, against freshly-seeded
/// content, and asserts the store outcomes the prose promises. A place the
/// lesson names that the app does not have is a red test.
@MainActor
@Suite("Tutorial acts — where things go")
struct TutorialWherePlacesActsTests {

    /// **Every place and door the chapter names, read from its OWN home.** The
    /// prose is written plainly (never interpolated from a constant it means
    /// to assert), and this ties each promise to the place the app spells it —
    /// so a renamed surface, a retired act or a re-worded region makes the
    /// lesson red rather than merely wrong.
    @Test func everyPlaceTheChapterNamesIsAPlaceTheAppHas() async throws {
        try await withTutorialWorld { _, db, bookID in
            let titles = try #require(
                TutorialSeeder.plan.first { $0.chapter == placesChapter }?.lessons)
            #expect(titles == ["the five places", "saving a moment",
                               "what a copy carries", "the two exits"],
                    "13u3 UNIT E (item 15(b)) added the copy lesson after ⌘⇧S's")
            let prose = try await db.read { db -> [String: String] in
                var out: [String: String] = [:]
                for title in titles {
                    out[title] = try Queries.renderedText(
                        db, containerID: lessonID(db, bookID: bookID, title))
                }
                return out
            }

            // ONE — the map itself, all five named where a reader meets them.
            let map = try #require(prose["the five places"])
            #expect(map.contains(RecoveryPath.archivedSurface), "TWO: Archive's own name")
            #expect(map.contains(CapabilityRegistry.capability(.archiveNote).verb))
            #expect(map.contains(RecoveryCopy.trashSection), "THREE: the Trash's")
            #expect(map.contains("\(TrashWindow.days)-day") || map.contains("\(TrashWindow.days) days"),
                    "the ruled window, never a number of its own")
            #expect(map.contains(VersionsPath.menuLabel), "FOUR: the door to a note's moments")
            #expect(map.contains(VersionsPath.openVerb) && map.contains(VersionsPath.restoreVerb)
                && map.contains(VersionsPath.promoteVerb),
                    "…and the three things a moment offers")
            #expect(map.contains(BlockHistoryPath.name), "FIVE: the panel's own name")
            #expect(map.contains(BlockHistoryPath.doorLabel), "…and the door's word")
            #expect(map.contains(BlockHistoryPath.cameFromSection))
            // The take's one home, said in the map so the Trash's absence of
            // takes is an answer rather than a hole (her D1 ruling).
            #expect(map.contains("never rows"))

            // TWO — the pair of keys (row 26). Both chords are read from the
            // registry, so a re-bind reaches the lesson.
            let saving = try #require(prose["saving a moment"])
            let commitChord = try #require(
                CapabilityRegistry.capability(.commitTake).shortcutLabel)
            let versionChord = try #require(
                CapabilityRegistry.capability(.saveNoteVersion).shortcutLabel)
            #expect(commitChord != versionChord, "the pairing rests on them differing")
            #expect(saving.contains(commitChord), "this take's moment")
            #expect(saving.contains(versionChord), "…and this note's")
            #expect(saving.contains(BlockHistoryPath.doorLabel)
                && saving.contains("commit"),
                    "the bottom-chrome pairing IS the teaching moment (her G4 words)")
            #expect(saving.contains(VersionsPath.restoreVerb)
                && saving.contains(VersionsPath.promoteVerb))
            #expect(!saving.lowercased().contains("one-way door"),
                    """
                    13u3 UNIT E: the confirm's over-promise was corrected at \
                    its own door, and the lesson may not go on making it
                    """)

            // THREE — what a copy carries (13u3 UNIT E, item 15(b)): her
            // sentence, both halves, in the words the app itself uses.
            let copies = try #require(prose["what a copy carries"])
            #expect(copies.contains("carries the WORDS, not the past"),
                    "the rule, in one clause")
            #expect(copies.contains("only what the note PLACES"),
                    "her words: \"you're only saving the placed notes\"")
            #expect(copies.contains(BlockHistoryPath.name)
                && copies.contains(BlockHistoryPath.doorLabel),
                    "…and where the past she is NOT copying actually lives")
            #expect(copies.contains(BlockHistoryPath.cameFromSection)
                && copies.contains(TrayPath.menuLabel),
                    "the two populations a version leaves with the note")
            #expect(copies.contains(VersionsPath.promoteVerb)
                && copies.contains("takes nothing"),
                    "the zero-loss road the confirm points at, taught here too")
            #expect(copies.contains("\u{2318}\u{21E7}S") && copies.contains("\u{2318}S"),
                    "both grains, because the rule is true of both")

            // FOUR — the two exits (row 27), and the rule in her own shape.
            let exits = try #require(prose["the two exits"])
            #expect(exits.contains("DELETION GOES TO THE TRASH")
                && exits.contains("TRANSFORMATION GOES TO LINEAGE"),
                    "her eleventh-sitting mandate, in the lesson's mouth")
            #expect(exits.contains(TrayPath.menuLabel), "the first exit's near listing")
            #expect(exits.contains(RecoveryCopy.trashSection), "…and its far one")
            #expect(exits.contains(TrayPath.putBackVerb))
            #expect(exits.contains(BlockHistoryPath.cameFromSection),
                    "the second exit's home")
            #expect(exits.contains(BlockHistoryPath.bringBackVerb),
                    "…and the one button back, by its real word")
        }
    }

    /// The staging the three lessons act on — the same contract
    /// `actReadyStagingIsInPlace` keeps for every older chapter.
    @Test func theMapsChapterIsStagedForItsActs() async throws {
        try await withTutorialWorld { _, db, bookID in
            let map = try await db.read { try lessonID($0, bookID: bookID, "the five places") }
            #expect(try await slots(db, map).compactMap(\.text)
                .contains { $0.hasPrefix("PRACTICE ME") },
                    "a block to visit with the history door")

            let saving = try await db.read {
                try lessonID($0, bookID: bookID, "saving a moment")
            }
            #expect(try await slots(db, saving).compactMap(\.text)
                .contains { $0.hasPrefix("PRACTICE TAKE") },
                    "a take to commit")

            let copies = try await db.read {
                try lessonID($0, bookID: bookID, "what a copy carries")
            }
            let copySlots = try await slots(db, copies).compactMap(\.text)
            #expect(copySlots.contains { $0.hasPrefix("PRACTICE COPY") },
                    "a block to save a moment of, then copy the note around")
            #expect(copySlots.count >= 3,
                    """
                    …and paragraphs either side of it, so the lesson's own \
                    merge act has two adjacent blocks to work on
                    """)

            let exits = try await db.read { try lessonID($0, bookID: bookID, "the two exits") }
            let exitProjection = try await projection(db, exits)
            let texts = exitProjection.slots.compactMap(\.text)
            #expect(texts.contains { $0.hasPrefix("EXIT ONE") }, "one to delete whole")
            let first = try #require(exitProjection.slots.firstIndex {
                $0.text?.hasPrefix("EXIT TWO, first half") == true
            })
            let second = try #require(exitProjection.slots.firstIndex {
                $0.text?.hasPrefix("EXIT TWO, second half") == true
            })
            #expect(second == first + 1, "the pair to join must be ADJACENT")
            for index in [first, second] {
                let blockID = exitProjection.slots[index].blockID
                #expect((exitProjection.fans[blockID]?.count ?? 1) == 1,
                        """
                        …and single-take: a cross-block edit joins the halves \
                        only where no fan hangs on the seam (the #11a ruling)
                        """)
            }
        }
    }

    /// **ALL FIVE PLACES, VISITED.** Each paragraph of the map lesson makes a
    /// promise about where something lives; this executes them one after
    /// another on the seeded content and asks the store where each thing went.
    @Test func theFivePlacesAreFivePlacesTheAppReallyHas() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the five places") }

            // ONE — where you left it: the ordinary case is a real case.
            let standing = try await slots(db, lesson)
            #expect(!standing.isEmpty, "the note is where she left it")

            // TWO — Archive: its own listing, no clock, and back again.
            let library = LibraryViewModel(session: session)
            await library.archive(postID: lesson)
            let (archived, trashed) = try await db.read { [now = session.now] db in
                (try Queries.archivedPosts(db).map(\.postID),
                 try Queries.trash(db, now: now).map(\.id))
            }
            #expect(archived.contains(lesson), "ARCHIVED holds it")
            #expect(!trashed.contains(lesson), "…and the Trash never does — no clock")
            await library.unarchive(postID: lesson)
            #expect(try await db.read { try Queries.library($0).map(\.postID) }
                .contains(lesson), "Unarchive puts it back in the Library")

            // THREE — the Trash: notes · books · blocks, each with its days.
            let doomed = try #require(standing.last).blockID
            try await session.runner.run { ops in try ops.deleteBlock(doomed) }
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let row = try #require(rows.first { $0.id == doomed })
            #expect(row.kind == .block)
            #expect(TrashWindow.daysLeft(row.deletedAt, now: session.now) == TrashWindow.days,
                    "a fresh tombstone wears the whole window")
            #expect(!TrashScope.listedKinds.contains(.take),
                    "…and a deleted take never rows here (her D1 ruling)")

            // FOUR — this note's Versions: ⌘⇧S's home, and NOT the Library's.
            _ = try await VersionActs.save(session: session, postID: lesson)
            let versions = try await db.read { try Queries.noteVersions($0, of: lesson) }
            #expect(versions.count == 1, "the moment is listed with its note")
            let versionID = try #require(versions.first).postID
            let (inLibrary, inArchived) = try await db.read { db in
                (try Queries.library(db).map(\.postID).contains(versionID),
                 try Queries.archivedPosts(db).map(\.postID).contains(versionID))
            }
            #expect(!inLibrary && !inArchived,
                    "a note's past is not another note — it stays out of both listings")

            // FIVE — this block's History: the block's own time, in one place.
            let opening = try #require(standing.first)
            let host = opening.blockID
            let variantID = try #require(opening.variantID)
            _ = try await session.runner.run { ops in
                try ops.commit(variantID, kind: .manual)
            }
            let history = try await db.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: host, now: now)
            }
            #expect(history.savepoints[variantID]?.count == 1,
                    "the moment ⌘S wrote is where the lesson says to look for it")
        }
    }

    /// **ROW 26 — THE TWO SIZES OF MOMENT, both saved, each in its own home.**
    /// The lesson's whole claim is that ⌘S and ⌘⇧S differ by one grain and one
    /// shift key; this drives both doors and asks where each moment landed.
    @Test func theTwoSavesKeepTwoSizesOfMoment() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "saving a moment")
            }
            let harness = try tutorialEditor(session, db, postID: lesson)
            let practice = try staged(harness, "PRACTICE TAKE")

            // ⌘S — the take's moment, through the bar's own door.
            harness.textView.setSelectedRange(
                NSRange(location: try entryRange(harness, practice.blockID).location, length: 0))
            harness.model.updateCaretContext()
            let take = try #require(harness.model.caretVariantID)
            // 13u3 UNIT D (item 14): the door now SUMMONS the optional
            // name and ⏎ files it — so this pin drives the whole two-key
            // road (⌘S, then ⏎ on an empty field), which is exactly what the
            // lesson tells her to press. Updated deliberately: the old
            // single-keystroke form would have asserted a door that no
            // longer exists.
            harness.model.commitCaretVariant()
            #expect(harness.model.savepointAsk != nil, "⌘S opens the name field")
            await harness.model.fileSavepoint(named: nil)
            var committed = 0
            for _ in 0..<200 {
                committed = (try? await db.read { db in
                    try Queries.commitHistory(db, variantID: take).count
                }) ?? 0
                if committed == 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(committed == 1, "the bar's own commit door wrote the take's moment")

            // ⌘⇧S — the note's moment, through the composition the door calls.
            _ = try await VersionActs.save(session: session, postID: lesson)

            let blocksInNote = try await slots(db, lesson).count
            let (history, versions) = try await db.read { [now = session.now] db in
                (try Queries.blockHistory(db, blockID: practice.blockID, now: now),
                 try Queries.noteVersions(db, of: lesson))
            }
            #expect(history.savepoints[take]?.count == 1,
                    "⌘S's moment is in the block's History, under this take")
            #expect(versions.count == 1, "⌘⇧S's moment is in the note's Versions")
            #expect(versions.first?.blockCount == blocksInNote,
                    "…and it is the WHOLE note — every block, not the one she was in")
            // The pairing the lesson teaches is only teachable while the two
            // chords really are the shifted twins of each other.
            #expect(CapabilityRegistry.capability(.commitTake).shortcutLabel == "\u{2318}S")
            #expect(CapabilityRegistry.capability(.saveNoteVersion).shortcutLabel
                == "\u{2318}\u{21E7}S")
        }
    }

    /// **13u3 UNIT E (item 15(b)) — A COPY CARRIES THE WORDS AND LEAVES THE
    /// MOMENTS BEHIND**, her instruction walked rather than asserted: *"when
    /// you make a version of a block or copy it or save it as a version …
    /// you're only saving the placed notes - not the history that rides with
    /// it."*
    ///
    /// The lesson's own PRACTICE COPY act, driven: save a moment of the take,
    /// save the whole note, then ask the store which of the two the copy got.
    @Test func theCopyLessonsPracticeKeepsTheWordsAndLeavesTheMoment() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a copy carries")
            }
            let practice = try #require(try await slots(db, lesson)
                .first { $0.text?.hasPrefix("PRACTICE COPY") == true })
            let take = try #require(practice.variantID)

            // ⌘S — the moment the lesson tells her to save.
            try await session.runner.run { ops in
                _ = try ops.commit(take, message: "the moment the lesson asks for")
            }
            // ⌘⇧S — the copy.
            _ = try await VersionActs.save(session: session, postID: lesson)
            let moment = try #require(try await db.read {
                try Queries.noteVersions($0, of: lesson)
            }.first)

            let (here, there) = try await db.read { db in
                (try Queries.renderedText(db, containerID: lesson),
                 try Queries.renderedText(db, containerID: moment.postID))
            }
            #expect(here == there, "\"every word is there\" — the lesson's own claim")

            let carried = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM commit_point c
                        JOIN variant v ON v.id = c.variant_id
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND c.kind = 'manual'
                        """,
                    arguments: [moment.postID]) ?? 0
            }
            #expect(carried == 0, "…and not one moment she wrote rode with them")
            #expect(try await db.read {
                try Queries.commitHistory($0, variantID: take)
            }.count == 1, "the moment is still here, on the take she pressed it on")
        }
    }

    /// **…AND A VERSION HOLDS ONLY WHAT THE NOTE PLACES** — the other half of
    /// her sentence, walked on the lesson's own paragraphs: a merge sets both
    /// sources aside WHOLE, and the version saved afterwards holds the page,
    /// never the things standing beside it.
    @Test func aVersionHoldsThePlacedParagraphsAndNotTheSetAsideOnes() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "what a copy carries")
            }
            let blocks = try await slots(db, lesson)
            #expect(blocks.count >= 3)
            let left = blocks[blocks.count - 2].blockID
            let right = blocks[blocks.count - 1].blockID
            try await session.runner.run { ops in _ = try ops.merge(left, right) }

            let setAside = try await db.read {
                try Queries.preservedOriginals($0, postID: lesson).map(\.blockID)
            }
            #expect(Set(setAside) == Set([left, right]),
                    "the merge kept both sources whole, beside the page")

            _ = try await VersionActs.save(session: session, postID: lesson)
            let moment = try #require(try await db.read {
                try Queries.noteVersions($0, of: lesson)
            }.first)

            let placed = try await slots(db, lesson).count
            #expect(moment.blockCount == placed,
                    "the version holds the note's placed paragraphs, one for one")
            for original in [left, right] {
                let copiedFrom = try await db.read { db in
                    try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM edge e
                            JOIN container_block cb
                              ON cb.block_id = e.source_block_id
                             AND cb.container_id = ? AND cb.deleted_at IS NULL
                            WHERE e.target_block_id = ? AND e.type = 'derived_from'
                            """,
                        arguments: [moment.postID, original]) ?? 0
                }
                #expect(copiedFrom == 0, "nothing in the moment came from a set-aside original")
            }
            #expect(try await db.read {
                try Queries.preservedOriginals($0, postID: lesson).map(\.blockID)
            }.sorted() == setAside.sorted(),
                    "…and they are still where the lesson says they are: with the NOTE")
        }
    }

    /// **ROW 27 — THE TWO EXITS, TAUGHT BY DOING** (her eleventh-sitting
    /// mandate: *"I deleted a paragraph, is it in deleted or in lineage? and
    /// lineage of what block"* must be legible).
    ///
    /// The lesson walks the reader through both exits in order, so this walks
    /// them too: a whole-paragraph delete lands in the tray AND the Trash with
    /// Put back real; a cross-seam edit joins two blocks and BOTH of them turn
    /// up in the joined block's came-from, one button from being back — with
    /// no clock anywhere, because nothing was deleted.
    @Test func theTwoExitsLandInTwoDifferentPlaces() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the two exits") }
            let harness = try tutorialEditor(session, db, postID: lesson)

            // ── EXIT ONE: deletion goes to the Trash ──────────────────────
            let doomed = try staged(harness, "EXIT ONE")
            harness.replace(try tripleClickSelection(harness, doomed.blockID), with: "")
            await harness.flush()

            let (trayed, trashed) = try await db.read { [now = session.now] db in
                (try Queries.trayBlocks(db, postID: lesson, now: now).map(\.blockID),
                 try Queries.trash(db, now: now))
            }
            #expect(trayed.contains(doomed.blockID), "the near listing: this note's tray")
            let row = try #require(trashed.first { $0.id == doomed.blockID })
            #expect(row.kind == .block, "…and the far one: the Library's Trash")
            #expect(TrashWindow.daysLeft(row.deletedAt, now: session.now) == TrashWindow.days,
                    "leaving means a countdown, and the row says so")

            // ── EXIT TWO: transformation goes to lineage ──────────────────
            try harness.reload()
            let first = try staged(harness, "EXIT TWO, first half")
            let second = try staged(harness, "EXIT TWO, second half")
            let firstRange = try entryRange(harness, first.blockID)
            let secondRange = try entryRange(harness, second.blockID)
            let span = NSRange(
                location: firstRange.location + firstRange.length / 2,
                length: (secondRange.location + secondRange.length / 2)
                    - (firstRange.location + firstRange.length / 2))
            let compound = try #require(
                harness.model.planCrossBlockEdit(range: span, replacement: ""),
                "two single-take neighbours: the lesson's own selection is eligible")
            await harness.model.runCrossBlockEdit(compound)
            await harness.flush()

            let after = try harness.storeSlots().map(\.blockID)
            #expect(!after.contains(first.blockID) && !after.contains(second.blockID),
                    "the two became one — neither original stands on the page")
            // The joined block is the one carrying what is left of both halves
            // — the lesson's own marker survives the cut it asks for.
            let standingSlots = try harness.storeSlots()
            let joined = try #require(standingSlots.first {
                $0.text?.contains("EXIT TWO") == true
            }).blockID
            #expect(after.contains(joined))

            let history = try await db.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: joined, now: now)
            }
            #expect(Set(history.origins.map(\.origin.blockID))
                == Set([first.blockID, second.blockID]),
                    "BOTH originals, in the block they became — not one of them")

            // …and NOTHING about that is a deletion: no clock, no Trash row.
            let (clocks, stillTrashed) = try await db.read { [now = session.now] db in
                (try Queries.originFamilyClocks(db, postID: lesson, now: now),
                 try Queries.trash(db, now: now).map(\.id))
            }
            for original in [first.blockID, second.blockID] {
                #expect(clocks[original] == nil,
                        "a preserved original has no clock while its descendant lives")
                #expect(!stillTrashed.contains(original),
                        "transformation never puts anything in the Trash")
            }

            // The one button back, through the door the lesson names.
            let model = BlockHistoryModel(session: session, postID: lesson, blockID: joined)
            model.adopt(history)
            await model.bringBack(first.blockID)
            #expect(model.status?.isRefusal != true)
            #expect(try await db.read {
                try Queries.renderPost($0, containerID: lesson).map(\.blockID)
            }.contains(first.blockID),
                    "Bring back really puts the original into the note again")
        }
    }
}

// MARK: - keeping it private (chapter contract — Phase 13p, knot 6)

/// The privacy chapter's name, in one place — the plan, the seeder's section
/// and this suite all mean the same three words.
private let privacyChapter = "keeping it private"

/// **THE PRIVACY CHAPTER SAYS WHAT THE APP SAYS.**
///
/// Her knot-6 ruling asked for a short chapter that makes *"the options that
/// are in settings clear (require lock every time to open, don't, what you
/// need to reset it, saving it in keychain or not, etc.)"*, states *"everything
/// they have to lose to lose their writing"*, names *"that there's an option
/// for a plaintext backup if they want"*, and lands *"in a non scary way, but
/// in a serious way."*
///
/// The DANGER with a chapter like this is drift: a settings pane re-worded at
/// 13s and a lesson left behind is a lesson that lies about a security
/// feature — the worst class of stale copy in the app. So the pins below tie
/// the prose to the app's OWN sentences (`ProtectionCopy` — the copy §7
/// constants both seeders render, the same brain the pane renders). A
/// re-worded posture name or a changed floor makes this red rather than
/// merely wrong.
///
/// It is a CONTRACT suite, not an acts suite, and deliberately so: every act
/// this chapter could ask a reader to perform is a Keychain or biometric act,
/// which no test may drive (the standing prompt rule). The behaviour those
/// sentences describe is pinned where it lives — `Phase13pLobbyTests`,
/// `Phase13pControllerTests`, `Phase13pProtectionBrainTests`.
@MainActor
@Suite("Tutorial contract — keeping it private")
struct TutorialPrivacyChapterTests {
    /// The two-register rule (copy §7b's head; design §1.22): the everyday
    /// surfaces and the tutorial name no key-family internals. ONE list,
    /// both platforms (the phone's twin reads the same words).
    static var forbiddenRegisterWords: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }

    @Test func theChapterIsTwoLessonsInTheRightPlace() {
        let index = TutorialSeeder.plan.firstIndex { $0.chapter == privacyChapter }
        #expect(index != nil)
        let places = TutorialSeeder.plan.firstIndex { $0.chapter == placesChapter }
        #expect(places != nil)
        #expect(index != nil && places != nil)
        if let index, let places {
            #expect(index == places + 1,
                    "the recovery map raises the question this chapter answers")
        }
        // pre-13x 5a: copy §7's two lessons, by the copy's own titles.
        #expect(TutorialSeeder.plan.first { $0.chapter == privacyChapter }?.lessons
            == [ProtectionCopy.privacyLessonOneTitle, ProtectionCopy.privacyLessonTwoTitle],
                "SHORT, as she ruled — two lessons")
    }

    /// **RENDER, DON'T RE-DERIVE** (pre-13x 5a): each lesson's prose is copy
    /// §7's paragraphs VERBATIM — the copy constants both seeders render —
    /// and the chapter says exactly what copy §7's parenthetical promises:
    /// both modes, both floors, keystone 3, keystone 4, and the book's door.
    @Test func theChapterRendersCopySevenVerbatimAndNamesBothModesBothFloorsTheKeystonesAndTheBooksDoor() async throws {
        try await withTutorialWorld { _, db, bookID in
            let one = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, ProtectionCopy.privacyLessonOneTitle))
            }
            let two = try await db.read { db in
                try Queries.renderedText(
                    db, containerID: lessonID(db, bookID: bookID, ProtectionCopy.privacyLessonTwoTitle))
            }
            for paragraph in ProtectionCopy.privacyLessonOneParagraphs {
                #expect(one.contains(paragraph), "lesson 1 carries the copy's paragraph verbatim")
            }
            for paragraph in ProtectionCopy.privacyLessonTwoParagraphs {
                #expect(two.contains(paragraph), "lesson 2 carries the copy's paragraph verbatim")
            }
            // Keystone 3, verbatim; keystone 4 rides a sentence that lowercases
            // its first word ("…changes: while Variorum is open…").
            #expect(one.contains(ProtectionCopy.keystoneAccountPassword))
            #expect(one.lowercased().contains(ProtectionCopy.keystoneOpenMeansReadable.lowercased()))
            #expect(one.contains("who holds a key"))
            // Both modes by their real words; both floors; the Castle keystone's
            // second clause; the book's door by the seeded book's own name.
            for posture in [Posture.standard, Posture.castle] {
                #expect(two.contains(ProtectionCopy.postureName(posture)))
            }
            #expect(two.contains(ProtectionCopy.privacyStandardFloorSentence))
            #expect(two.contains(ProtectionCopy.privacyCastleFloorSentence))
            #expect(two.contains("your passphrase is what lets a new device in"))
            // 13s-b U1b (R-13s-37, the U3 disposition 1 — a JUSTIFIED
            // EDIT): the book's-door arm INVERTS — the pointer paragraph
            // retired with the book's seed and doors, so the chapter must
            // no longer name a book a fresh store cannot hold. The two
            // never-soften floor arms above are byte-untouched.
            #expect(!two.contains(SampleLibraryEncryptionBook.name),
                    "the retired pointer stays gone")
            // The retired 13p dials lesson is gone: no reset door, no presets.
            #expect(!one.contains("Forgot It? Reset") && !two.contains("Forgot It? Reset"))
            // The two-register rule over the rendered chapter.
            for prose in [one, two] {
                #expect(!prose.contains(Self.forbiddenRegisterWords),
                        "the tutorial names no key-family internal: \(prose.prefix(80))…")
            }
        }
    }
}

// MARK: - THE FANNED CROSS-BLOCK MATRIX, taught by doing (13u1 UNIT 2)

/// **Row 27's deferred half, built.** The post-13l polish round wrote the
/// "two exits" lesson and recorded in its own ledger that *"the fanned
/// cross-block matrix is 13u's — its sitting + its own lesson update"*. Her
/// item 5 mandate is the reason it could not stay deferred past this unit:
/// *teachability is a design constraint*, and the gesture now has more than
/// one answer.
///
/// The lesson teaches the matrix and then asks the reader to DO it (her own
/// method for this chapter), so this walk does exactly what the EXIT THREE
/// cards say and asks the store where each block went.
@MainActor
@Suite("Tutorial acts — the fanned cross-block matrix (13u1 UNIT 2)")
struct TutorialFannedMatrixTests {

    @Test func theMatrixLessonTeachesTheThreeAnswersTheGestureHas() async throws {
        try await withTutorialWorld { _, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the two exits") }
            let prose = try await slots(db, lesson).compactMap(\.text).joined(separator: "\n")

            // The WHOLE/PART fork — the sentence the matrix rests on.
            #expect(prose.contains("covered WHOLE") && prose.contains("covered only IN PART"))
            #expect(prose.contains("with every take on it"),
                    "a fanned block covered whole goes WHOLE — her ruling")
            #expect(prose.contains("only the take you can SEE loses its piece"),
                    "…and a partly covered one touches the shown take only")
            // R-13u-2, in the lesson's mouth, BOTH kinds of break named.
            #expect(prose.contains("MIDDLE of a paragraph at both ends"))
            #expect(prose.contains("paragraph BREAK at either end"))
            #expect(prose.contains("a line break inside one"),
                    "the INTERNAL newline half of her ruling is named, not implied")
            // #11a's rule at the ends.
            #expect(prose.contains("never fold a fan away"))
        }
    }

    @Test func theMatrixLessonsOwnGestureLandsWhereItSaysItWill() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the two exits") }
            let harness = try tutorialEditor(session, db, postID: lesson)

            let top = try staged(harness, "EXIT THREE, top")
            let middle = try staged(harness, "EXIT THREE, middle")
            let bottom = try staged(harness, "EXIT THREE, bottom")

            // The middle really carries the fan the card promises.
            let fanBefore = try await db.read { [blockID = middle.blockID] db in
                try Queries.blockFan(db, blockID: blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active }
            }
            #expect(fanBefore.count == 2, "the staged fan the lesson names")

            // The gesture the cards ask for: from the middle of the top,
            // straight through the middle block, to the middle of the bottom.
            let topRange = try entryRange(harness, top.blockID)
            let bottomRange = try entryRange(harness, bottom.blockID)
            let from = topRange.location + topRange.length / 2
            let to = bottomRange.location + bottomRange.length / 2
            harness.replace(NSRange(location: from, length: to - from), with: "")
            await harness.flush()

            let standing = try harness.storeSlots().map(\.blockID)
            #expect(!standing.contains(middle.blockID), "the middle left the page")
            #expect(!standing.contains(top.blockID) && !standing.contains(bottom.blockID),
                    "the two ends joined into a fresh block")

            // …to the TRAY, with BOTH takes — the cell her ruling changed.
            let trayed = try await db.read { [now = session.now] db in
                try Queries.trayBlocks(db, postID: lesson, now: now).map(\.blockID)
            }
            #expect(trayed.contains(middle.blockID))
            let ridden = try await db.read { [blockID = middle.blockID, now = session.now] db in
                try Queries.deletedTakes(db, blockID: blockID, now: now).count
            }
            #expect(ridden == 2, "both takes rode to the Trash — Put back returns the family")

            // And the two ends are one block whose Came from names both.
            let joined = try #require(try harness.storeSlots().first {
                $0.text?.contains("EXIT THREE") == true
            }).blockID
            let history = try await db.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: joined, now: now)
            }
            #expect(Set(history.origins.map(\.origin.blockID))
                == Set([top.blockID, bottom.blockID]),
                    "BOTH ends, kept whole in the block they became")
        }
    }
}
