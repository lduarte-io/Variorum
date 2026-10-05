//
//  TutorialBooksChapterTests.swift
//  VariorumTests
//
//  13i-d U7 — THE BOOKS CHAPTER IS THE EXECUTABLE SPEC (P-6; the sitting
//  record §25, written at her instruction as SECONDARY ACCEPTANCE CRITERIA:
//  "every lesson is a sentence the field guide must be able to say
//  TRUTHFULLY of the shipped build — if the build makes any sentence false,
//  the build is wrong, not the sentence").
//
//  Each of the eleven lesson sentences is a pin with three halves:
//    · THE PROSE — the seeded lesson says the sentence (her words, kept as
//      close as the shipped surface's own words allow);
//    · THE DOORS — every door the lesson names is tied to that door's OWN
//      constant (the H pattern: the prose is written plainly, never
//      interpolated from what it asserts, so a rename turns it RED);
//    · THE TRUTH — the sentence is EXECUTED headless against the store.
//  The five rituals (taught by DOING) are walked headless the same way; R5's
//  drags are pinned at the plan layer (the headless shape; F-U1-4's
//  "synthetic drags never commit" was F-B2-1's undeclared-type defect,
//  fixed in 17y B2 — drags commit now, and her hand still spot-checks them).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The world

/// A store with the field guide seeded and the Welcome arrangement made —
/// and, when `library`, the three seeded books first (the classics lesson's
/// subject). Marks are injected; nothing touches the test host's defaults.
@MainActor
private func withChapterWorld<T>(
    library: Bool = false,
    _ body: @MainActor (AppSession, AppDatabase, _ guideID: String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 25))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        if library {
            for book in SampleLibrarySeeder.Book.all {
                _ = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book, loadMark: { false }, saveMark: { _ in })
            }
        }
        let guideID = try await TutorialSeeder.restore(session: session)
        try await SampleLibraryWelcome.arrange(session: session, guideName: TutorialSeeder.bookName)
        return try await body(session, db, guideID)
    }
}

private enum ChapterError: Error { case missing(String) }

/// A lesson's whole stored text, by its exact title.
private func prose(_ db: AppDatabase, _ guideID: String, _ title: String) async throws -> String {
    try await db.read { db in
        guard let id = try String.fetchOne(
            db,
            sql: """
                SELECT c.id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                """,
            arguments: [guideID, title])
        else { throw ChapterError.missing(title) }
        return try Queries.renderedText(db, containerID: id)
    }
}

/// A plain note with one line of text, optionally minted inside a book.
@MainActor
private func note(_ session: AppSession, _ text: String, in bookID: String? = nil) throws -> String {
    let ops = session.operations
    let post: Container
    if let bookID {
        post = try ops.newPostInReading(bookID, section: nil, title: nil, profile: .generic)
    } else {
        post = try ops.createPost(title: nil)
    }
    _ = try ops.newBlock(in: post.id, text: text, at: .end, registeringUndo: false)
    return post.id
}

private func memberIDs(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                ORDER BY position, id
                """,
            arguments: [readingID])
    }
}

private func shown(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { try Queries.assembleReading($0, readingID: readingID, limit: 300).map(\.postID) }
}

private func firstVariant(_ db: AppDatabase, _ postID: String) async throws -> String {
    try await db.read { db in
        guard let id = try Queries.renderPost(db, containerID: postID).first?.variantID
        else { throw ChapterError.missing("a block in \(postID)") }
        return id
    }
}

private let chapterTitles = [
    "the classics walk", "a book from the inside", "membership, not ownership",
    "gatherings & arrivals", "owned, finished, sealed", "the bookcase",
    "the journal & the pool", "wings",
]

// MARK: - The eleven lessons

@MainActor
@Suite("Tutorial contract — books & the bookcase, the eleven lessons (§25)")
struct TutorialBooksLessonTests {

    /// The chapter is in the plan, LAST, eight lessons — and the seeded book
    /// matches (the spine's `theSeededBookMatchesTheLessonPlanExactly` holds
    /// the order; this holds the chapter's own shape).
    @Test func theChapterIsEightLessonsLastInTheGuide() async throws {
        #expect(TutorialSeeder.plan.last?.chapter == TutorialSeeder.booksChapter)
        #expect(TutorialSeeder.plan.last?.lessons == chapterTitles)
        #expect(!TutorialSeeder.plan.flatMap(\.lessons).contains("books & the shelf"),
                "the old lesson MOVED into this chapter — it is not taught twice")
        try await withChapterWorld { _, db, guideID in
            for title in chapterTitles {
                let text = try await prose(db, guideID, title)
                #expect(!text.isEmpty, "\(title) is seeded")
            }
        }
    }

    /// **Lesson 1 — the three kinds.** "A gathering shows you every note
    /// matching its rule — it holds nothing. A book holds its notes as
    /// members. An owned book is the only place its notes live."
    @Test func lessonOneTheThreeKinds() async throws {
        try await withChapterWorld(library: true) { session, db, guideID in
            let text = try await prose(db, guideID, "the classics walk")
            #expect(text.contains("A GATHERING shows you every note matching its rule \u{2014} it holds nothing."))
            #expect(text.contains("A BOOK holds its notes as members."))
            #expect(text.contains("An OWNED book is the only place its notes live."))
            // The doors and names it points at, from their own homes.
            #expect(text.contains("the \(Operations.welcomeShelfName) shelf"))
            #expect(text.contains("\u{201C}\(SampleLibraryWelcome.classicsGatheringName)\u{201D}"))
            // The U7 continuation (F-U7-1 RULED): the gathering is made from the
            // ONE seed tag both books' notes wear — a JUSTIFIED EDIT (the two
            // book tags were P-13id-U7-1's superseded stand-in).
            #expect(text.contains("#\(SampleLibrarySeeder.classicsTagPath)"))
            #expect(OwnershipBadgeCopy.ownedBy("x").hasPrefix("owned by"))
            #expect(text.contains("\u{201C}owned by\u{201D}"), "the badge, by its own words")
            // 17y B-DEDUPE (R-17y-8), the lesson's new claims: the GUIDE is
            // the plain-book example now, and Jekyll is the example you
            // choose — one Restore press away, named by its own door.
            #expect(text.contains("This guide is the plain kind"))
            #expect(text.contains("\u{201C}\(SampleLibraryJekyllBook.name)\u{201D}"),
                    "the Restore sentence names the book the door restores")

            // THE TRUTH, kind by kind.
            let readings = try await db.read { try Queries.readings($0) }
            let classics = try #require(readings.first { $0.name == SampleLibraryWelcome.classicsGatheringName })
            let jekyll = try #require(readings.first { $0.name == SampleLibrarySeeder.Book.jekyllAndHyde.name })
            let sherlock = try #require(readings.first { $0.name == SampleLibrarySeeder.Book.sherlock.name })
            #expect(classics.kind == .gathering)
            #expect(try await memberIDs(db, classics.id).isEmpty, "a gathering holds nothing…")
            #expect(!(try await shown(db, classics.id)).isEmpty, "…yet shows every match")
            let jekyllMembers = try await memberIDs(db, jekyll.id)
            let jekyllShown = try await shown(db, jekyll.id)
            #expect(!jekyllMembers.isEmpty && jekyllMembers == jekyllShown,
                    "a book holds its notes as members — what it shows IS its rows")
            // 17y B-DEDUPE (R-17y-8): the lesson's plain-book example is the
            // GUIDE itself now — a book whose notes are ordinary members —
            // and the restored Jekyll's notes join the gathering (the
            // Restore sentence's truth; this world holds the restored copy).
            #expect(!(try await memberIDs(db, guideID)).isEmpty,
                    "the guide is a plain book holding members")
            let classicsShown = Set(try await shown(db, classics.id))
            #expect(Set(jekyllMembers).isSubset(of: classicsShown),
                    "a restored Jekyll's notes join the gathering beside Sherlock's")
            #expect(sherlock.owned)
            let story = try #require(try await memberIDs(db, sherlock.id).last)
            let elsewhere = try session.operations.createReading(name: "elsewhere", kind: .book)
            #expect(throws: (any Error).self, "an owned book is the only place its notes live") {
                try session.operations.addPostToReading(story, to: elsewhere.id)
            }
            #expect(try await memberIDs(db, elsewhere.id).isEmpty)
        }
    }

    /// **Lesson 2 — the edit law.** "Editing a note that is in a book is
    /// always editing every book it appears in — owned or not. Adding a note
    /// to a book never copies it. A copy only ever happens because you asked
    /// for one, and it always remembers where it came from."
    @Test func lessonTwoTheEditLaw() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "membership, not ownership")
            #expect(text.contains("Editing a note that is in a book is always editing every book it appears in \u{2014} owned or not."))
            #expect(text.contains("Adding a note to a book never copies it."))
            #expect(text.contains("A copy only ever happens because you asked for one, and it always remembers where it came from."))

            let ops = session.operations
            let first = try ops.createReading(name: "first", kind: .book)
            let second = try ops.createReading(name: "second", kind: .book)
            let n = try note(session, "one note", in: first.id)
            let notesBefore = try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'") ?? 0 }
            _ = try ops.addPostToReading(n, to: second.id)
            let notesAfter = try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'") ?? 0 }
            #expect(notesAfter == notesBefore, "adding never copies")
            let inFirst = try await shown(db, first.id)
            let inSecond = try await shown(db, second.id)
            #expect(inFirst.contains(n) && inSecond.contains(n), "ONE note in both books")
            try ops.autosave(try await firstVariant(db, n), text: "edited once", charDelta: 4)
            let read = try await db.read { try Queries.renderedText($0, containerID: n) }
            #expect(read == "edited once", "editing it is editing it in every book")

            // A copy, because she asked: and it remembers.
            let third = try ops.createReading(name: "third", kind: .book)
            let copy = try ops.copyPostIntoReading(n, into: third.id).copy
            #expect(copy.id != n)
            let remembers = try await db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (
                          SELECT 1 FROM edge e
                          JOIN container_block a ON a.block_id = e.source_block_id AND a.container_id = ?
                          JOIN container_block b ON b.block_id = e.target_block_id AND b.container_id = ?
                          WHERE e.deleted_at IS NULL)
                        """,
                    arguments: [copy.id, n]) ?? false
            }
            #expect(remembers, "the copy's blocks carry lineage back to the original")
        }
    }

    /// **Lesson 3 — gatherings.** "A gathering is made from a tag. Remove the
    /// tag and the note leaves on its own. You can't rearrange a gathering —
    /// bind it into a book to take it in hand, and it keeps collecting after
    /// you do."
    @Test func lessonThreeGatherings() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "gatherings & arrivals")
            #expect(text.contains("A gathering is made from a tag. Remove the tag and the note leaves on its own."))
            #expect(text.contains("You can't rearrange a gathering \u{2014} bind it into a book to take it in hand, and it keeps collecting after you do."))
            #expect(text.contains(BindCopy.bindVerb), "the bind door by its own verb")
            #expect(text.contains(RuleEditorCopy.mintTitle), "the gathering mint by its own words")

            let ops = session.operations
            let tag = try ops.createTag(name: "lessonthree")
            let a = try note(session, "a")
            let b = try note(session, "b")
            _ = try ops.applyTag(tag.id, toPost: a)
            _ = try ops.applyTag(tag.id, toPost: b)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            #expect(Set(try await shown(db, gathering.id)) == [a, b], "made from a tag")
            try ops.removeTag(tag.id, fromPost: a)
            #expect(try await shown(db, gathering.id) == [b], "untag — it leaves on its own")
            #expect(throws: (any Error).self, "a gathering has no order of hers to rearrange") {
                try ops.reorderReadingPost(b, in: gathering.id, to: .start)
            }
            _ = try ops.convertSmartReadingToCurated(gathering.id)
            let bound = try #require(try await db.read { try Queries.reading($0, id: gathering.id) })
            #expect(bound.kind == .book, "bound — the same row, now a book")
            #expect(try await memberIDs(db, gathering.id) == [b])
            let c = try note(session, "c")
            _ = try ops.applyTag(tag.id, toPost: c)
            #expect(try await memberIDs(db, gathering.id) == [b, c], "…and it keeps collecting")
        }
    }

    /// **Lesson 4 — arrivals** (+ item 10's road back). "A collecting book
    /// auto-adds freely; anything it can't seat on its own waits at Arrivals
    /// for you to judge — add it, copy it in, or dismiss it. Finishing a book
    /// dismisses whatever is still waiting." + "Changed your mind? Add it by
    /// hand; dismissing only stops the book from adding it on its own."
    @Test func lessonFourArrivals() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "gatherings & arrivals")
            #expect(text.contains("A collecting book auto-adds freely; anything it can't seat on its own waits at Arrivals"))
            #expect(text.contains("for you to judge: add it, copy it in, or dismiss it."))
            #expect(text.contains("Finishing a book dismisses whatever is still waiting."))
            #expect(text.contains("Changed your mind? Add it by hand; dismissing only stops the book from adding it on its own."))
            // 17y B3 item (h) (R-17y-1/2) → FIXED at 17y B-DEDUPE (F-B3-1):
            // the door is the masthead's Arrivals icon beside the gear, and
            // the lesson now names THAT face — the retired "at the door"
            // line is gone from the prose (the wrapper this block carried
            // came off with the fix, as it demanded).
            #expect(ArrivalsCopy.word == "Arrivals")
            #expect(!text.contains("\u{201C}at the door\u{201D}"),
                    "the lesson names the door by the face's own word")
            #expect(text.contains("beside the book's settings gear"),
                    "…and points at the icon where it lives")
            #expect(text.contains(ArrivalsCopy.addVerb.lowercased() + " it"))
            #expect(text.contains(ArrivalsCopy.dismissVerb.lowercased() + " it"))
            #expect(MembershipChoiceCopy.copyInVerb.lowercased() == "copy in")
            #expect(ArrivalsCopy.dismissed("x").contains("add it by hand"),
                    "the door's own receipt teaches the same road back")

            let ops = session.operations
            let tag = try ops.createTag(name: "lessonfour")
            let rule = try RuleGrammar.encode(.tag(tag.id))
            // Auto-adds freely (the dial's default: join quietly).
            let free = try ops.createReading(name: "free", kind: .book, querySpec: rule)
            // Judged at the door.
            let judged = try ops.createReading(name: "judged", kind: .book, querySpec: rule)
            try ops.setReadingIntakeSeating(judged.id, .arrivals)
            let n = try note(session, "n")
            _ = try ops.applyTag(tag.id, toPost: n)
            #expect(try await memberIDs(db, free.id) == [n], "auto-adds freely")
            let door = try await db.read { try Queries.bookArrivals($0, readingID: judged.id, limit: 10) }
            let judgedMembers = try await memberIDs(db, judged.id)
            #expect(door.count == 1 && judgedMembers.isEmpty, "waits at Arrivals")
            try ops.dismissArrival(try #require(door.rows.first).id)
            #expect(try await db.read { try Queries.bookArrivals($0, readingID: judged.id, limit: 10) }.count == 0)
            _ = try ops.addPostToReading(n, to: judged.id)
            #expect(try await memberIDs(db, judged.id) == [n], "changed her mind: added by hand")
            // Finishing dismisses whatever is still waiting.
            let m = try note(session, "m")
            _ = try ops.applyTag(tag.id, toPost: m)
            #expect(try await db.read { try Queries.bookArrivals($0, readingID: judged.id, limit: 10) }.count == 1)
            try ops.lockReading(judged.id)
            #expect(try await db.read { try Queries.bookArrivals($0, readingID: judged.id, limit: 10) }.count == 0,
                    "finishing dismissed it")
        }
    }

    /// **Lesson 5 — owned.** "Put a note in an owned book and that book is
    /// its home. Want it elsewhere too? You'll get a copy, and you'll know.
    /// Remove it and it goes back to the Pool, whole."
    @Test func lessonFiveOwned() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "owned, finished, sealed")
            #expect(text.contains("Put a note in an owned book and that book is its home. Want it elsewhere too? You'll get a copy, and you'll know. Remove it and it goes back to the Pool, whole."))
            #expect(text.contains(BookStateCopy.ownVerb))
            #expect(text.contains(RemoveFromBookCopy.releaseVerb))
            #expect(text.contains(RemoveFromBookCopy.removeVerb))

            let ops = session.operations
            let owned = try ops.createReading(name: "owned", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let n = try note(session, "a note with a home", in: owned.id)
            let plain = try ops.createReading(name: "plain", kind: .book)
            #expect(throws: (any Error).self, "elsewhere means a copy, said at the door") {
                try ops.addPostToReading(n, to: plain.id)
            }
            let copy = try ops.copyPostIntoReading(n, into: plain.id).copy
            let plainMembers = try await memberIDs(db, plain.id)
            #expect(copy.id != n && plainMembers == [copy.id])
            let bookless = try ops.removePostFromReading(n, from: owned.id)
            #expect(bookless, "released — no book holds it now")
            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect((pool.loose + pool.tucked).map(\.postID).contains(n), "…it is in the Pool")
            #expect(try await db.read { try Queries.renderedText($0, containerID: n) } == "a note with a home",
                    "…whole")
        }
    }

    /// **Lesson 6 — finished and sealed.** "Finished means the table of
    /// contents is done — the writing inside can still change. Sealed means
    /// the book is done."
    @Test func lessonSixFinishedAndSealed() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "owned, finished, sealed")
            #expect(text.contains("Finished means the table of contents is done \u{2014} the writing inside can still change. Sealed means the book is done."))
            for verb in [BookStateCopy.finishVerb, BookStateCopy.sealVerb,
                         BookStateCopy.reopenVerb, BookStateCopy.unsealVerb, CollectingCopy.openVerb] {
                #expect(text.contains(verb), "the door \(verb), by its own verb")
            }
            #expect(BookStateCopy.sealLead.hasPrefix("Sealed means the book is done"),
                    "the seal's confirm says the lesson's sentence")

            let ops = session.operations
            let book = try ops.createReading(name: "done-ish", kind: .book)
            let n = try note(session, "still writable", in: book.id)
            let stray = try note(session, "stray")
            try ops.lockReading(book.id)
            #expect(throws: (any Error).self, "finished: the table of contents is done") {
                try ops.addPostToReading(stray, to: book.id)
            }
            try ops.autosave(try await firstVariant(db, n), text: "changed while finished", charDelta: 8)
            #expect(try await db.read { try Queries.renderedText($0, containerID: n) } == "changed while finished",
                    "…the writing inside can still change")
            try ops.unlockReading(book.id)
            _ = try ops.sealReading(book.id)
            let variant = try await firstVariant(db, n)
            #expect(throws: (any Error).self, "sealed: the book is done") {
                try ops.autosave(variant, text: "too late", charDelta: 3)
            }
            #expect(try await db.read { try Queries.renderedText($0, containerID: n) } == "changed while finished")
        }
    }

    /// **Lesson 7 — the Bookcase.** "Your books live on shelves, alphabetical
    /// until you choose otherwise — switch to your own order to place them by
    /// hand. The shelves run left to right exactly as All stacks them top to
    /// bottom. Unshelved books wait at the top until you file them."
    @Test func lessonSevenTheBookcase() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "the bookcase")
            #expect(text.contains("Your books live on shelves, alphabetical until you choose otherwise \u{2014} switch to your own order to place them by hand."))
            #expect(text.contains("The shelves run left to right exactly as All stacks them top to bottom."))
            #expect(text.contains("Unshelved books wait at the top until you file them."))
            for label in BookcaseOrderMode.allCases.map(\.label) {
                #expect(text.contains(label), "the order ▾ says \(label)")
            }
            #expect(text.contains(BookcaseCopy.moveToShelfVerb))
            #expect(text.contains(BookcaseCopy.sendToTopVerb))
            #expect(text.contains(StarCopy.starRow))
            #expect(text.contains(BookcaseCopy.unshelvedName))
            #expect(text.contains(Operations.welcomeShelfName))

            // Alphabetical until she chooses otherwise: the board's default.
            let suite = "u7-lesson7-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            #expect(ShelfViewModel(session: session, defaults: defaults).orderMode == .alphabetical)

            let ops = session.operations
            let second = try ops.createShelf(name: "Essays")
            let books = try await db.read { try Queries.bookcase($0, wingID: "") }
            let all = BookcaseBoard.sections(
                books: books.books, shelves: books.shelves, scope: .all, solo: nil,
                mode: .alphabetical, lastEdited: [:])
            let welcome = try #require(books.shelves.first { $0.role == Operations.welcomeShelfRole })
            #expect(all.map(\.id) == ["unshelved", welcome.id, second.id],
                    "unshelved at the TOP, then the shelves exactly in strip order")
            let names = all.first?.books.map(\.reading.name) ?? []
            #expect(names == names.sorted { $0.localizedStandardCompare($1) == .orderedAscending },
                    "alphabetical within the run")
        }
    }

    /// **Lesson 8 — deleting.** "Deleting a plain book never touches a note.
    /// Deleting an owned book asks: keep the notes (they go to the Pool) or
    /// take them too. The Trash gives back whatever went in together,
    /// together."
    @Test func lessonEightDeleting() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "owned, finished, sealed")
            #expect(text.contains("Deleting a plain book never touches a note. Deleting an owned book asks: keep the notes (they go to the Pool) or take them too. The Trash gives back whatever went in together, together."))
            let membership = try await prose(db, guideID, "membership, not ownership")
            #expect(membership.contains(BookStateCopy.deleteVerb), "the door, by its own verb")
            #expect(BookStateCopy.deleteOwnedBook(readingID: "r", name: "o", notes: 2).lines
                .joined().contains("go back to the Pool"), "the owned confirm offers the two choices")

            let ops = session.operations
            let plain = try ops.createReading(name: "plain", kind: .book)
            let p = try note(session, "plain's note", in: plain.id)
            try ops.deleteReading(plain.id)
            #expect(try await db.read { try Container.fetchOne($0, key: p)?.deletedAt } == nil,
                    "a plain book's delete never touches a note")

            let keep = try ops.createReading(name: "keep", kind: .book)
            _ = try ops.setReadingOwned(keep.id, owned: true)
            let k = try note(session, "kept", in: keep.id)
            try ops.deleteReading(keep.id)
            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect((pool.loose + pool.tucked).map(\.postID).contains(k), "book only: the notes go to the Pool")

            let take = try ops.createReading(name: "take", kind: .book)
            _ = try ops.setReadingOwned(take.id, owned: true)
            let t = try note(session, "taken", in: take.id)
            _ = try ops.deleteReadingWithNotes(take.id)
            #expect(try await db.read { try Container.fetchOne($0, key: t)?.deletedAt } != nil, "…or take them too")
            try ops.restoreReading(take.id)
            #expect(try await db.read { try Container.fetchOne($0, key: t)?.deletedAt } == nil)
            #expect(try await memberIDs(db, take.id) == [t], "together, together")
        }
    }

    /// **Lesson 9 — the daily Journal**, WHOLE (13i-e U2 — F-U7-2's pin
    /// FLIPPED, the guard having shipped at 13i-e U1): "The daily Journal is
    /// an ordinary book that is special in one way: it's where ⌘J and Today's
    /// Entry file. You can archive it; you can't delete it; it comes back when
    /// a day arrives." The second sentence was withheld until the build could
    /// say it truthfully; now it is asserted, and its truth executed headless:
    /// archive the Journal → it leaves the Bookcase → its delete refuses (and
    /// no face draws a Delete for it) → a day arrives (Today's Entry) → the
    /// SAME book is back, live, unarchived, the day's entry filed, the receipt
    /// spoken. (Red on old: the pre-sentence tree's prose lacks the sentence.)
    @Test func lessonNineTheDailyJournal() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "the journal & the pool")
            #expect(text.contains("The daily Journal is an ordinary book that is special in one way: it's where \u{2318}J and Today's Entry file."))
            let todays = CapabilityRegistry.capability(.todaysEntry)
            #expect(text.contains(todays.verb))
            #expect(text.contains(try #require(todays.shortcutLabel)))
            // THE SECOND SENTENCE — taught now that the guard ships (F-U7-2).
            #expect(text.contains("You can archive it; you can't delete it; it comes back when a day arrives."),
                    "lesson 9's second sentence lands WITH the guard (13i-e)")
            #expect(text.contains(CapabilityRegistry.capability(.archiveBook).verb.lowercased()),
                    "the door it names, by its own verb")

            let ops = session.operations
            let entry = try ops.createPost(title: nil)
            let shelved = ops.shelveInDailyJournalBook(entry.id)
            guard case .shelved(let journal) = shelved else {
                Issue.record("⌘J's filing lands in the daily Journal: \(shelved)")
                return
            }
            #expect(try await db.read { try Queries.dailyJournalBookID($0) } == journal)
            #expect(try await memberIDs(db, journal) == [entry.id], "⌘J files into it")
            #expect(try await db.read { try Queries.reading($0, id: journal) }?.kind == .book,
                    "an ordinary book")

            // "You can archive it" — and it leaves the Bookcase.
            try ops.archiveReading(journal)
            #expect(try await db.read { try Queries.bookshelf($0, wingID: "") }
                .allSatisfy { $0.reading.id != journal }, "archived: off the Bookcase")
            // "you can't delete it" — the op refuses, in the table's words, and
            // no face draws the door (P-2).
            do {
                try ops.deleteReading(journal)
                Issue.record("the daily Journal must refuse its delete")
            } catch {
                #expect(error as? OperationError == .dailyJournalCannotBeDeleted(id: journal))
                #expect(OpsRefusalCopy.words(for: error, roads: .mac)
                        == BookArchiveCopy.cannotDeleteDailyJournal)
            }
            let archived = try #require(try await db.read { try Queries.reading($0, id: journal) })
            #expect(!BookArchiveDoorSet.rendered(for: BookArchiveFacts(archived)).contains(.deleteBook))
            // "it comes back when a day arrives" — Today's Entry, the SAME book.
            let outcome = try await JournalBooks.openToday(session: session, day: "2026-10-04")
            let back = try #require(try await db.read { try Queries.reading($0, id: journal) })
            #expect(back.archivedAt == nil && back.deletedAt == nil, "back, live")
            #expect(try await db.read { try Queries.dailyJournalBookID($0) } == journal, "the SAME book")
            #expect(try await memberIDs(db, journal).contains(outcome.postID), "the day's entry filed")
            #expect(try await db.read { try Queries.bookshelf($0, wingID: "") }
                .contains { $0.reading.id == journal }, "back on the Bookcase")
            #expect(outcome.receipt == BookArchiveCopy.journalCameBack, "and it says so")
        }
    }

    /// **Lesson 10 — the Pool.** "The Pool is every note with no book. Notes
    /// that show in gatherings tuck behind the count in its masthead — one
    /// click shows them." — shown on the seeded quicknote.
    @Test func lessonTenThePool() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "the journal & the pool")
            #expect(text.contains("The Pool is every note with no book. Notes that show in gatherings tuck behind the count in its masthead \u{2014} one click shows them."))
            #expect(text.contains("click \(PoolTuckCopy.toggle(showing: false))"), "the one click, by its own word")
            #expect(text.contains("\u{201C}\(SampleLibraryWelcome.quicknoteTitle)\u{201D}"))

            let loose = try note(session, "a bookless note")
            let quicknote = try #require(try await db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM container WHERE title = ? AND deleted_at IS NULL",
                                    arguments: [SampleLibraryWelcome.quicknoteTitle])
            })
            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect(pool.loose.map(\.postID).contains(loose), "every note with no book")
            #expect(pool.tucked.map(\.postID).contains(quicknote),
                    "the seeded quicknote shows in Quicknotes, so it tucks behind the count")
            #expect(!pool.loose.map(\.postID).contains(quicknote))
        }
    }

    /// **Lesson 11 — wings.** "A wing is a separate library in the same app —
    /// a different room in the same house. Nothing crosses between wings
    /// except what you move or copy yourself."
    @Test func lessonElevenWings() async throws {
        try await withChapterWorld { session, db, guideID in
            let text = try await prose(db, guideID, "wings")
            #expect(text.contains(WingWords.lesson), "the lesson IS the New Wing prompt's sentence")
            #expect(text.contains(WingCopy.newWingVerb))
            #expect(text.contains(WingCopy.moveToWingVerb))
            #expect(text.contains(WingCopy.copyToWingVerb))

            let ops = session.operations
            let wing = try ops.createWing(name: "Annex")
            let there = try ops.createPost(title: "there", wingId: wing.id)
            let here = try note(session, "here")
            let homeLibrary = try await db.read { try Queries.library($0, wingID: "").map(\.postID) }
            #expect(!homeLibrary.contains(there.id), "nothing crosses on its own")
            #expect(homeLibrary.contains(here))
            _ = try ops.moveNoteToWing(here, to: wing.id)
            let after = try await db.read { try Queries.library($0, wingID: "").map(\.postID) }
            #expect(!after.contains(here), "…except what she moves herself")
        }
    }
}

// MARK: - The five rituals

@MainActor
@Suite("Tutorial rituals — books & the bookcase, R1…R5 (§25)")
struct TutorialBooksRitualTests {

    /// **R1 — the classics walk:** open the classics gathering on the Welcome
    /// shelf; see Jekyll's and Sherlock's notes side by side; notice
    /// Sherlock's wear the owned mark; open one through it and land in its
    /// book. (17y B-DEDUPE, R-17y-8: the fixture's `library: true` world is
    /// the POST-RESTORE shape now — Jekyll is the example the lesson's
    /// Restore press adds, not launch furniture; the walk's mechanics are
    /// identical either way.)
    @Test func ritualOneTheClassicsWalk() async throws {
        try await withChapterWorld(library: true) { _, db, _ in
            let readings = try await db.read { try Queries.readings($0) }
            let classics = try #require(readings.first { $0.name == SampleLibraryWelcome.classicsGatheringName })
            let sherlock = try #require(readings.first { $0.name == SampleLibrarySeeder.Book.sherlock.name })
            let jekyll = try #require(readings.first { $0.name == SampleLibrarySeeder.Book.jekyllAndHyde.name })
            let welcome = try #require(try await db.read { db in
                try Shelf.fetchOne(db, sql: "SELECT * FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL")
            })
            #expect(classics.shelfId == welcome.id, "the classics gathering sits on Welcome")
            let seen = Set(try await shown(db, classics.id))
            let sherlockNotes = Set(try await memberIDs(db, sherlock.id))
            let jekyllNotes = Set(try await memberIDs(db, jekyll.id))
            #expect(sherlockNotes.isSubset(of: seen) && jekyllNotes.isSubset(of: seen),
                    "both books' notes, side by side")
            let facts = try await db.read { try Queries.ownershipFacts($0, postIDs: Array(seen)) }
            let story = try #require(sherlockNotes.first)
            let badge = OwnershipBadgeFace.badge(facts[story], placement: .outside, badgesOn: true)
            guard case .ownedBy(let owner)? = badge else {
                Issue.record("a Sherlock note wears the owned mark in a gathering: \(String(describing: badge))")
                return
            }
            #expect(owner.id == sherlock.id)
            for id in jekyllNotes {
                #expect(OwnershipBadgeFace.badge(facts[id], placement: .outside, badgesOn: true) == nil,
                        "Jekyll's wear none")
            }
            // Open one through it: the badge's click is the ascent road, aimed
            // at the OWNING book and this very note.
            let landed = LockIsolated<[String: String]>([:])
            let token = NotificationCenter.default.addObserver(
                forName: Notification.Name.variorumOpenBookAtPost, object: nil, queue: nil
            ) { note in
                let book = note.userInfo?["bookID"] as? String ?? ""
                let post = note.userInfo?["postID"] as? String ?? ""
                landed.setValue(["bookID": book, "postID": post])
            }
            defer { NotificationCenter.default.removeObserver(token) }
            MembershipChip.ascend(bookID: owner.id, postID: story)
            #expect(landed.value["bookID"] == sherlock.id)
            #expect(landed.value["postID"] == story)
        }
    }

    /// **R2 — membership, by hand:** make a book, a chapter, a note inside it;
    /// add the same note to a second book; edit it and see both books change;
    /// delete one book and watch the note survive.
    @Test func ritualTwoMembershipByHand() async throws {
        try await withChapterWorld { session, db, _ in
            let ops = session.operations
            let practice = try ops.createReading(name: "practice", kind: .book)
            let chapter = try ops.createSection(in: practice.id, name: "one")
            let n = try ops.newPostInReading(practice.id, section: chapter.id, title: nil, profile: .generic).id
            _ = try ops.newBlock(in: n, text: "a line", at: .end, registeringUndo: false)
            let second = try ops.createReading(name: "practice two", kind: .book)
            _ = try ops.addPostToReading(n, to: second.id)
            try ops.autosave(try await firstVariant(db, n), text: "an edited line", charDelta: 3)
            let inPractice = try await shown(db, practice.id)
            let inSecond = try await shown(db, second.id)
            #expect(inPractice == [n] && inSecond == [n])
            #expect(try await db.read { try Queries.renderedText($0, containerID: n) } == "an edited line",
                    "both books changed — it is one note")
            try ops.deleteReading(second.id)
            #expect(try await db.read { try Container.fetchOne($0, key: n)?.deletedAt } == nil, "the note survives")
            #expect(try await memberIDs(db, practice.id) == [n])
        }
    }

    /// **R3 — the gathering's life:** tag two notes; make a gathering from the
    /// tag; untag one and watch it leave; bind the gathering into a book;
    /// reorder it; untag the other and watch it STAY. (The lesson re-tags the
    /// first so the bound book has two to reorder — "it keeps collecting".)
    @Test func ritualThreeTheGatheringsLife() async throws {
        try await withChapterWorld { session, db, guideID in
            let ops = session.operations
            // The lesson's own subjects: this lesson and the next.
            let ids = try await db.read { db in
                try ["gatherings & arrivals", "owned, finished, sealed"].map { title in
                    try #require(try String.fetchOne(
                        db,
                        sql: """
                            SELECT c.id FROM reading_post rp JOIN container c ON c.id = rp.post_id
                            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                            """,
                        arguments: [guideID, title]))
                }
            }
            let (one, two) = (ids[0], ids[1])
            let trial = try ops.createTag(name: "trial")
            _ = try ops.applyTag(trial.id, toPost: one)
            _ = try ops.applyTag(trial.id, toPost: two)
            let gathering = try ops.createReading(
                name: "trial", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(trial.id)))
            #expect(Set(try await shown(db, gathering.id)) == [one, two])
            try ops.removeTag(trial.id, fromPost: one)
            #expect(try await shown(db, gathering.id) == [two], "untagged — it leaves")
            _ = try ops.convertSmartReadingToCurated(gathering.id)
            #expect(try await memberIDs(db, gathering.id) == [two], "bound into a book")
            _ = try ops.applyTag(trial.id, toPost: one)
            #expect(try await memberIDs(db, gathering.id) == [two, one], "it keeps collecting")
            try ops.reorderReadingPost(one, in: gathering.id, to: .start)
            #expect(try await memberIDs(db, gathering.id) == [one, two], "reordered by hand")
            try ops.removeTag(trial.id, fromPost: two)
            #expect(try await memberIDs(db, gathering.id) == [one, two], "untagged — it STAYS")
        }
    }

    /// **R4 — ownership's boundary:** flip a book to Owned; try adding one of
    /// its notes to another book and meet the copy choice; remove a note and
    /// find it in the Pool.
    @Test func ritualFourOwnershipsBoundary() async throws {
        try await withChapterWorld { session, db, _ in
            let ops = session.operations
            let practice = try ops.createReading(name: "practice", kind: .book)
            let n = try note(session, "mine", in: practice.id)
            let forks = try ops.setReadingOwned(practice.id, owned: true)
            #expect(forks.copied.isEmpty, "a sole member owns in place")
            let other = try ops.createReading(name: "other", kind: .book)
            do {
                _ = try ops.addPostToReading(n, to: other.id)
                Issue.record("adding an owned note elsewhere must meet the choice")
            } catch OperationError.noteOwnedElsewhere(let postID, _, let owner) {
                #expect(postID == n && owner == practice.id, "the copy choice opens on this refusal")
            }
            _ = try ops.copyPostIntoReading(n, into: other.id)
            #expect(try await memberIDs(db, other.id).count == 1)
            _ = try ops.removePostFromReading(n, from: practice.id)
            let pool = try await db.read { try Queries.notePoolListing($0, window: 50) }
            #expect((pool.loose + pool.tucked).map(\.postID).contains(n), "found in the Pool")
        }
    }

    /// **R5 — the shelf gesture:** drag a book onto a shelf name; switch order
    /// to "my order" and place one by hand; star one and see it float. The
    /// drags' HANDLERS are pinned here (synthetic drags never commit — her
    /// hand walks them); the menu twins are the same model calls.
    @Test func ritualFiveTheShelfGesture() async throws {
        try await withChapterWorld { session, db, _ in
            let suite = "u7-r5-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let ops = session.operations
            let shelf = try ops.createShelf(name: "Mine")
            let alpha = try ops.createReading(name: "alpha", kind: .book)
            let beta = try ops.createReading(name: "beta", kind: .book)
            for _ in 0..<300 where model.books.count < 2 { try? await Task.sleep(for: .milliseconds(10)) }

            // A book dropped on a shelf's NAME (the drop handler = Move to Shelf).
            await model.reshelve(alpha.id, to: shelf.id)
            await model.reshelve(beta.id, to: shelf.id)
            #expect(try await db.read { try Queries.reading($0, id: alpha.id)?.shelfId } == shelf.id)

            // My order: place one by hand (drag = Send to Top's model call).
            model.orderMode = .mine
            await model.place(beta.id, at: .top)
            for _ in 0..<300 where model.sections.first(where: { $0.id == shelf.id })?.books.first?.reading.id != beta.id {
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(model.sections.first { $0.id == shelf.id }?.books.map(\.reading.id) == [beta.id, alpha.id])

            // Star one: it floats first, under any order.
            try ops.setStarred(.reading(alpha.id), starred: true)
            let snapshot = try await db.read { try Queries.bookcase($0, wingID: "") }
            let onShelf = snapshot.books.filter { $0.reading.shelfId == shelf.id }
            for mode in BookcaseOrderMode.allCases {
                #expect(BookcaseBoard.ordered(onShelf, mode: mode, lastEdited: [:]).first?.reading.id == alpha.id,
                        "starred floats first under \(mode.label)")
            }
        }
    }
}
