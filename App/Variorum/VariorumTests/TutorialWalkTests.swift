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
        // R57's class: the Fragments bridge sweeps journal days — tutorial
        // text must be structurally invisible to it.
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
            #expect(journalShaped == 0, "no tutorial row can ever reach the bridge")
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
            #expect(reading?.kind == .curated)
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
            let ceremony = try await db.read { try lessonID($0, bookID: bookID, "the take ceremony") }
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
            let userBook = try session.operations.createReading(name: "my book", kind: .curated)
            let userRows = try await db.read { [postID = userPost.id] db in
                try userPostRows(db, postID: postID)
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
                try userPostRows(db, postID: postID)
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
            let child = try session.operations.createTag(
                parent: try #require(parentID), name: "keepsake")
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
                name: TutorialSeeder.bookName, kind: .curated)
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
            #expect(session.status.current?.text.contains("on your shelf") == true,
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
            func hasBadge() -> Bool {
                textView.subviews.contains { ($0 as? NSButton)?.title.contains("⑂") == true }
            }
            await poll { hasBadge() }
            #expect(hasBadge(),
                    "the ⑂ badge renders the moment the host exists — never starved")
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

            // The honest road back the lesson names: Write's takes panel
            // rides the same model door.
            await model.unarchiveTake(spare.id)
            let back = try await projection(db, lesson)
            #expect(back.fans[spareHost.blockID]?.contains { $0.id == spare.id } == true,
                    "never gone — Unarchive restores it to the fan")
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
            await poll { session.status.current != nil }
            #expect(session.status.current?.text == "Undid: Divide")
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
            let lesson = try await db.read { try lessonID($0, bookID: bookID, "the take ceremony") }
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

    @Test func mergeJoinsTheWaitingPairWithASingleSpace() async throws {
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
                    == "These two short blocks are really one thought. "
                    + "They have been waiting for your \u{2318}\u{21E7}M since the day they were seeded.",
                    "a single space at the seam — nothing else invented")
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

            // From Takes, merge joins UPWARD: focused block into the one above.
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
            // …then undo the structure.
            ShellActions(session: session, shell: ShellRouter()).structuralUndo()
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

    @Test func outlineMintsALinkedCondensation() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "outline \u{B7} blocks \u{B7} canvas")
            }
            let result = try await session.runner.run { ops in
                try ops.mintOutlinePost(of: lesson)
            }
            #expect(result.post.title?.hasPrefix("outline of") == true)
            let outlineSlots = try await slots(db, result.post.id)
            let sourceSlots = try await slots(db, lesson)
            #expect(outlineSlots.count == sourceSlots.count, "one outline point per block")
        }
    }

    @Test func canvasRemembersAnArrangement() async throws {
        try await withTutorialWorld { session, db, bookID in
            let lesson = try await db.read {
                try lessonID($0, bookID: bookID, "outline \u{B7} blocks \u{B7} canvas")
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

    @Test func exportsShowTheFansAndTheChapters() async throws {
        try await withTutorialWorld { _, db, bookID in
            let choosing = try await db.read { try lessonID($0, bookID: bookID, "choosing & the board") }
            let postMarkdown = try await db.read {
                try Queries.exportPost($0, postID: choosing, includeVariants: true)
            }
            #expect(postMarkdown.contains("Alternates"),
                    "a fanned block exports with its fan showing")
            #expect(postMarkdown.contains("verdict"), "every open take reaches paper")

            // The whole book exports as ONE document (every lesson inside).
            // Honesty note (Stage 2 walk finding → ledger): reading_section
            // CHAPTERS don't reach exportReading — its section headings ride
            // the smart-book grouping tag only (`assembleReading.sectionPath`;
            // core-frozen this stage, routed to Stage 3). The lesson prose
            // deliberately doesn't promise chapter headings on paper.
            let bookMarkdown = try await db.read { try Queries.exportReading($0, readingID: bookID) }
            #expect(bookMarkdown.contains("# \(TutorialSeeder.bookName)"))
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
            await model.commitFocusedTake()
            #expect(session.status.current?.text
                    == "This post is sealed — unseal it to change takes or choices.",
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
