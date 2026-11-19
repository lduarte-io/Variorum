//
//  MobileBookFixesTests.swift
//  VariorumMobileTests
//
//  VM-78 batch A — the books family's fixes, pinned (VM-81 · VM-83 · VM-21;
//  the run record `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH A).
//
//  Every pin here compiles against the SEAM commit (the shipped behaviour
//  expressed through the testable surfaces the fixes then change), so the
//  red-on-old run reverts the product files to that commit and these go red
//  by ASSERTION, never by a missing symbol. Expected words are typed locals
//  (batch B's lesson: an optional compared against a long concatenation can
//  time out the type-checker).
//

import Foundation
import GRDB
import Testing
import UIKit  // the hosted guards read the presented `UIAlertController`
import VariorumCore
@testable import VariorumMobile

// MARK: - Shared fixtures

/// A live BOOK whose rule collects #inbox and whose new matches WAIT at
/// Arrivals, with `waiting` notes already waiting.
private func bookWithArrivals(_ ops: Operations, waiting: Int) throws -> String {
    let tag = try ops.createTag(name: "inbox")
    let rule = try RuleGrammar.encode(.tag(tag.id))
    let book = try ops.createReading(
        name: "Ideas inbox", kind: .book, querySpec: rule, intakeSeating: .arrivals)
    for index in 0..<waiting {
        let note = try ops.createPost(title: "idea \(index)")
        try ops.applyTag(tag.id, toPost: note.id)
    }
    return book.id
}

private func liveArrivals(_ db: AppDatabase, _ readingID: String) async throws -> Int {
    try await db.read { db in try Queries.pendingArrivalCount(db, readingID: readingID) }
}

private func isLocked(_ db: AppDatabase, _ readingID: String) async throws -> Bool {
    try await db.read { db in try Queries.reading(db, id: readingID)?.locked } ?? false
}

private func reading(
    _ name: String, kind: ReadingKind = .book, locked: Bool = false, sealed: Bool = false,
    archived: Bool = false
) -> Reading {
    Reading(
        id: name, name: name, kind: kind, locked: locked || sealed,
        sealedAt: sealed ? Date() : nil, archivedAt: archived ? Date() : nil,
        createdAt: Date(), updatedAt: Date())
}

// MARK: - VM-81: Finish asks (W-105)

@MainActor
@Suite("VM-81 — Finish asks before it dismisses what waits at Arrivals (W-105)")
struct MobileFinishConfirmTests {
    /// RED ON OLD: the shipped Finish acted at once — the book locked and
    /// `lockReading` dismissed both waiting notes, a judgment she never saw.
    @Test func finishWithArrivalsWaitingAsksWithTheCountAndDoesNotLock() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try bookWithArrivals(ops, waiting: 2)
            }
            #expect(try await liveArrivals(db, bookID) == 2, "the fixture: two notes wait")
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()

            await model.requestFinish()

            let title: String = "Finish \u{201C}Ideas inbox\u{201D}?"
            let line: String = "2 waiting at Arrivals will be dismissed."
            let confirm = try #require(model.pendingFinish, "the door asks first")
            #expect(confirm.title == title)
            #expect(confirm.line == line)
            #expect(try await isLocked(db, bookID) == false, "asking finishes nothing")
            #expect(try await liveArrivals(db, bookID) == 2, "asking dismisses nothing")

            await model.confirmFinish(confirm)
            #expect(model.pendingFinish == nil)
            #expect(try await isLocked(db, bookID), "confirming finishes the book")
            #expect(try await liveArrivals(db, bookID) == 0,
                    "…and dismisses what waited, as the confirm said")
            #expect(model.lastError == nil)
        }
    }

    /// RED ON OLD (the door finished at once). Cancel leaves the book exactly
    /// as it was. The alert's Cancel acts nothing; what clears the confirm is
    /// the binding SwiftUI writes back on dismissal (`finishConfirmPresented =
    /// false` — the shelf delete's rule), so that is the road this drives
    /// (round 1, F5: the retired `cancelFinish()` was a road the face never took).
    @Test func cancellingTheConfirmLeavesTheBookAsItWas() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try bookWithArrivals(ops, waiting: 1)
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            await model.requestFinish()
            #expect(model.pendingFinish?.line == "1 waiting at Arrivals will be dismissed.")
            model.finishConfirmPresented = false
            #expect(model.pendingFinish == nil)
            #expect(try await isLocked(db, bookID) == false)
            #expect(try await liveArrivals(db, bookID) == 1)
        }
    }

    /// GREEN ON BOTH SIDES (round 1, F5 — batch 4.5b's ordering, stated at
    /// the model): a real tap writes the binding back BEFORE the action's
    /// task runs, so the confirm must reach the act as its parameter. Write
    /// the binding back first, then confirm: the book still finishes and
    /// what waited is dismissed.
    @Test func aConfirmWhoseBindingWasWrittenBackFirstStillFinishes() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try bookWithArrivals(ops, waiting: 2)
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            await model.requestFinish()
            let confirm = try #require(model.pendingFinish, "the door asks first")

            model.finishConfirmPresented = false
            #expect(model.pendingFinish == nil, "the write-back clears the confirm")
            await model.confirmFinish(confirm)

            #expect(try await isLocked(db, bookID), "the confirm still finishes the book")
            #expect(try await liveArrivals(db, bookID) == 0, "…and nothing waits")
            #expect(model.lastError == nil)
        }
    }

    /// **The confirm's FACE** (round 1, F5 — a GUARD, green on the tip by
    /// design, not a red-on-old pin): the real sheet, the Finish row driven by
    /// its label, the alert that really presents (title and line exact — the
    /// `presenting:` value), and its real Finish action acting on the confirm
    /// it was handed. `writeBack: {}` — the sheet owns its model, so the
    /// binding's write-back is not simulated here (the
    /// `aRefusedDeleteIsSpokenOnTheSheetThatRaisedIt` precedent); the
    /// ordering is pinned at the model, above. On a product whose Finish row
    /// has no label this goes red at the door's label, which says nothing
    /// about the confirm.
    @Test func theFinishRowsConfirmPresentsAndItsFinishActs() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try bookWithArrivals(ops, waiting: 2)
            }
            try await withHostedSurface(
                MobileBookDetailsSheet(session: session, readingID: bookID, tokens: .terminalLight)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(BookStateCopy.finishVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert, "the confirm must actually present")
                let title: String = "Finish \u{201C}Ideas inbox\u{201D}?"
                let line: String = "2 waiting at Arrivals will be dismissed."
                #expect(alert.title == title)
                #expect(alert.message == line)
                let actions: [String] = surface.alertActionTitles.map { $0.lowercased() }
                #expect(actions.contains("finish"))
                #expect(actions.contains("cancel"))
                #expect(try await isLocked(db, bookID) == false, "the confirm alone finishes nothing")

                #expect(surface.tapAlertAction(BookStateCopy.finishVerb, writeBack: {}),
                        "the confirm's Finish must be drivable")
                for _ in 0..<200 {
                    if try await isLocked(db, bookID) { break }
                    await surface.settle(2)
                }
            }
            #expect(try await isLocked(db, bookID), "the confirm's Finish finishes the book")
            #expect(try await liveArrivals(db, bookID) == 0, "…and dismisses what waited")
        }
    }

    /// The same face's Cancel (a GUARD, as above): its real action changes
    /// nothing in the store.
    @Test func theFinishRowsConfirmCancelChangesNothing() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try bookWithArrivals(ops, waiting: 1)
            }
            try await withHostedSurface(
                MobileBookDetailsSheet(session: session, readingID: bookID, tokens: .terminalLight)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(BookStateCopy.finishVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                _ = try #require(surface.presentedAlert, "the confirm must actually present")
                #expect(surface.tapAlertAction("Cancel", writeBack: {}),
                        "the confirm's Cancel must be drivable")
                await surface.settle(40)
            }
            #expect(try await isLocked(db, bookID) == false, "Cancel finishes nothing")
            #expect(try await liveArrivals(db, bookID) == 1, "…and dismisses nothing")
        }
    }

    /// GREEN ON BOTH SIDES (the control — the Mac's `finishNeedsConfirm`):
    /// with nothing waiting, Finish simply acts.
    @Test func finishWithNothingWaitingActsAtOnce() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try ops.createReading(name: "Poems", kind: .book).id
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            await model.requestFinish()
            #expect(model.pendingFinish == nil, "nothing waits, so nothing is asked")
            #expect(try await isLocked(db, bookID))
        }
    }
}

// MARK: - VM-81: the finish row's words and doors (W-106, W-110)

@MainActor
@Suite("VM-81 — the finish row says the truth and draws only where it acts (W-106, W-110)")
struct MobileBookStateRowTests {
    /// RED ON OLD: "freezes its notes" / "its notes and order are frozen" —
    /// false, a finished book's text stays editable (AppSpec §7). The Mac's
    /// sentence; a SEALED book says the sealed one (its text IS frozen).
    @Test func theFinishCaptionSaysWhatFinishedMeans() {
        let finishedMeans: String =
            "Finished means the table of contents is done \u{2014} the writing inside can still change."
        let sealedMeans: String = "Sealed \u{2014} the book is done; no note in it can change."
        typealias M = MobileBookDetailsModel
        #expect(M.finishCaption(for: reading("Open")) == finishedMeans)
        #expect(M.finishCaption(for: reading("Done", locked: true)) == finishedMeans)
        #expect(M.finishCaption(for: reading("Kept", sealed: true)) == sealedMeans)
        // The phone speaks the SHARED sentences — never a fork.
        #expect(finishedMeans == BookStateCopy.finishedMeans)
        #expect(sealedMeans == BookStateCopy.sealedMeans)
        for caption in [
            M.finishCaption(for: reading("Open")), M.finishCaption(for: reading("Done", locked: true)),
        ] {
            #expect(!caption.contains("freez") && !caption.contains("frozen"), "\(caption)")
        }
    }

    /// RED ON OLD: Finish was drawn on an open gathering, and `lockReading`
    /// then refused it raw (`wrongReadingKind`). The Mac's table: a gathering
    /// has no Finish; one ALREADY finished keeps Reopen as its way out; a
    /// sealed book keeps Reopen too (the brief — the phone has no Unseal door
    /// until wave 4, so the refusal explains).
    @Test func finishIsNotDrawnOnAGathering() {
        typealias M = MobileBookDetailsModel
        #expect(M.finishRowAct(for: reading("G", kind: .gathering)) == nil)
        #expect(M.finishRowAct(for: reading("G", kind: .gathering, locked: true)) == .reopen)
        #expect(M.finishRowAct(for: reading("B")) == .finish)
        #expect(M.finishRowAct(for: reading("B", locked: true)) == .reopen)
        #expect(M.finishRowAct(for: reading("S", sealed: true)) == .reopen)
    }

    /// RED ON OLD: Reopen on a sealed book reached her as the raw enum
    /// ("That couldn't be done — readingSealed(…)."). It speaks the shared
    /// table's sentence (`OpsRefusalTable`, the phone's roads — no Unseal door
    /// named, because the phone has none yet).
    @Test func reopenOnASealedBookSpeaksTheSharedSentence() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Kept", kind: .book)
                _ = try ops.sealReading(book.id)
                return book.id
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            await model.setFinished(false)
            let sentence: String = "This book is sealed, so it can't be reopened here."
            #expect(model.lastError == sentence)
            #expect(try await isLocked(db, bookID), "the refusal changed nothing")
        }
    }

    /// RED ON OLD: Diverge was drawn on a gathering's row and then refused
    /// (a gathering has no membership row to swap — P-2).
    @Test func divergeIsNotDrawnOnAGatheringRow() {
        #expect(!MobileMembershipModel.rowCarriesDiverge(reading("G", kind: .gathering)))
        #expect(MobileMembershipModel.rowCarriesDiverge(reading("B")))
    }
}

// MARK: - VM-81: a starred archived book's way out (W-120)

@MainActor
@Suite("VM-81 — a starred archived book's Details carries its way out (W-120)")
struct MobileArchivedStarredBookTests {
    /// RED ON OLD: Details read only the shelf's listing, which drops archived
    /// books, so the archived Journal she could still open from Starred showed
    /// an EMPTY sheet and no way back.
    @Test func anArchivedStarredBooksDetailsCarriesTheUnarchiveDoor() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Old projects", kind: .book)
                let note = try ops.createPost(title: "The podcast, first attempt")
                _ = try ops.addPostToReading(note.id, to: book.id)
                try ops.setStarred(.reading(book.id), starred: true)
                try ops.archiveReading(book.id)
                return book.id
            }
            let starred = try await db.read { db in try Queries.starred(db) }
            #expect(starred.contains { $0.target == .reading(bookID) },
                    "the fixture: archiving never unstars, so Starred still opens it")

            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            let name: String = "Old projects (archived)"
            #expect(model.book != nil, "the sheet resolves the archived book")
            #expect(model.nameLine == name, "and says it is archived, in the shared words")
            #expect(model.metaLine == "1 note")
            #expect(model.offersUnarchive, "the way out is drawn")

            await model.unarchive()
            #expect(model.lastError == nil)
            #expect(model.offersUnarchive == false)
            #expect(model.nameLine == "Old projects")
            let shelf = try await db.read { db in try Queries.bookshelf(db) }
            #expect(shelf.contains { $0.reading.id == bookID }, "unarchiving returns it to the shelf")
        }
    }

    /// RED ON THE PRE-FIX-PASS TIP (round 1, F3): the sheet reads once and
    /// after its own acts, so a book unarchived elsewhere while it is open — or
    /// a second press queued behind the first — meets `readingNotArchived`,
    /// which fell to `DeletionRefusal`'s fallback and reached her as the raw
    /// enum. It speaks the shared table's sentence.
    @Test func aRacedUnarchiveSpeaksTheSharedSentence() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Old projects", kind: .book)
                try ops.archiveReading(book.id)
                return book.id
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            // Unarchived elsewhere while the sheet stands on it.
            try await session.runner.run { ops in _ = try ops.unarchiveReading(bookID) }

            await model.unarchive()

            let sentence: String = "That book isn't archived any more \u{2014} nothing changed."
            #expect(model.lastError == sentence)
            let archived = try await db.read { db in try Queries.reading(db, id: bookID)?.archivedAt }
            #expect(archived == nil, "the book stays out of the archive")
        }
    }
}

// MARK: - VM-83: the shelf's order (W-068 — her ruling: a–z now, the choice in wave 3)

@MainActor
@Suite("VM-83 — the shelf sorts a–z, digit-aware, starred first (W-068)")
struct MobileShelfOrderTests {
    /// RED ON OLD: the retired `ShelfOrder` rule — pins, then journal-trait
    /// books, then the rest by case-sensitive `<` ("Zebra" before "apple",
    /// "Book 10" before "Book 2"). The shared `BookcaseBoard` rule the Mac's
    /// Bookcase uses: starred float first, then a–z, Finder's comparison.
    @Test func theShelfSortsAToZDigitAwareWithStarredFirst() async throws {
        try await withEditorWorld { session, _ in
            let ids = try await session.runner.run { ops -> [String: String] in
                var ids: [String: String] = [:]
                for name in ["Zebra", "apple", "Book 10", "Book 2", "Yak"] {
                    ids[name] = try ops.createReading(name: name, kind: .book).id
                }
                ids["Dreams"] = try ops.createReading(
                    name: "Dreams", kind: .book, profile: "journal",
                    sortField: .entryDate, sortDir: .desc).id
                try ops.setStarred(.reading(ids["Yak"] ?? ""), starred: true)
                return ids
            }
            let model = MobileShelfViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            await settle { model.books.count == 6 }

            let names = model.orderedBooks.map(\.reading.name)
            let expected: [String] = ["Yak", "apple", "Book 2", "Book 10", "Dreams", "Zebra"]
            #expect(names == expected,
                    "starred first, then a–z — case-blind and digit-aware; a journal is a book like any other")
            #expect(ids.count == 6)
        }
    }

    /// A GUARD (round 1, N1 — green on the tip by design): a star taken or
    /// given while the shelf is OPEN moves the book, through the row's own
    /// Star door. The held observation reads the union star inside its
    /// region (`Queries.bookshelf` → `starredReadingIDs`), so the order
    /// follows without a re-open — the coverage the retired pin test carried.
    @Test func aStarTakenWithTheShelfOpenReordersIt() async throws {
        try await withEditorWorld { session, _ in
            let ids = try await session.runner.run { ops -> [String: String] in
                var ids: [String: String] = [:]
                for name in ["Zebra", "apple", "Book 10", "Book 2", "Yak"] {
                    ids[name] = try ops.createReading(name: name, kind: .book).id
                }
                ids["Dreams"] = try ops.createReading(
                    name: "Dreams", kind: .book, profile: "journal",
                    sortField: .entryDate, sortDir: .desc).id
                try ops.setStarred(.reading(ids["Yak"] ?? ""), starred: true)
                return ids
            }
            let model = MobileShelfViewModel(session: session)
            let stars = MobileStarsModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            await settle { model.books.count == 6 }
            await stars.refresh()

            let book10 = try #require(ids["Book 10"])
            await stars.toggle(.reading(book10), from: .shelf)
            let starredBoth: [String] = ["Book 10", "Yak", "apple", "Book 2", "Dreams", "Zebra"]
            await settle { model.orderedBooks.map(\.reading.name) == starredBoth }
            #expect(model.orderedBooks.map(\.reading.name) == starredBoth,
                    "a star given with the shelf open floats the book at once")

            let yak = try #require(ids["Yak"])
            await stars.refresh()
            await stars.toggle(.reading(yak), from: .shelf)
            let yakUnstarred: [String] = ["Book 10", "apple", "Book 2", "Dreams", "Yak", "Zebra"]
            await settle { model.orderedBooks.map(\.reading.name) == yakUnstarred }
            #expect(model.orderedBooks.map(\.reading.name) == yakUnstarred,
                    "a star taken back returns the book to its a–z place")
        }
    }
}

// MARK: - VM-83: one star door (W-071)

@MainActor
@Suite("VM-83 — the shelf row's menu has one star door and no Pin (W-071)")
struct MobileShelfRowActsTests {
    /// RED ON OLD: the row offered "Pin to Shelf Top" beside Star — two doors
    /// writing the one union star (`setShelfPinned` is `setStarred`), so
    /// pressing Pin flipped Star's label too.
    @Test func theRowMenuOffersStarAndNoPin() async throws {
        try await withEditorWorld { session, _ in
            let (bookID, gatheringID, journalID) = try await session.runner.run {
                ops -> (String, String, String) in
                let book = try ops.createReading(name: "Essays", kind: .book)
                let tag = try ops.createTag(name: "quote")
                let gathering = try ops.createReading(
                    name: "Quotes", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
                let journal = try ops.createReading(
                    name: "Journal", kind: .book, profile: "journal",
                    sortField: .entryDate, sortDir: .desc)
                try ops.setDailyJournalBook(journal.id)
                return (book.id, gathering.id, journal.id)
            }
            let model = MobileShelfViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            await settle { model.books.count == 3 && model.dailyBookID != nil }
            let book = try #require(model.books.first { $0.reading.id == bookID })
            let gathering = try #require(model.books.first { $0.reading.id == gatheringID })
            let journal = try #require(model.books.first { $0.reading.id == journalID })

            let bookMenu: [String] = ["Star", "Delete Book\u{2026}"]
            let starredMenu: [String] = ["Unstar", "Delete Book\u{2026}"]
            let gatheringMenu: [String] = ["Star", "Delete Gathering\u{2026}"]
            let journalMenu: [String] = ["Star", "Archive"]
            #expect(model.rowActs(for: book, starred: false).map(\.title) == bookMenu)
            #expect(model.rowActs(for: book, starred: true).map(\.title) == starredMenu)
            #expect(model.rowActs(for: gathering, starred: false).map(\.title) == gatheringMenu)
            #expect(model.rowActs(for: journal, starred: false).map(\.title) == journalMenu)
            for row in [book, gathering, journal] {
                for starred in [false, true] {
                    #expect(!model.rowActs(for: row, starred: starred)
                        .contains { $0.title.contains("Pin") },
                            "no Pin door on any row — the star is the one door")
                }
            }
        }
    }
}

// MARK: - VM-83: "gathering", never "smart" (W-073)

@MainActor
@Suite("VM-83 — the phone says \"gathering\", never \"smart\" (W-073)")
struct MobileGatheringWordTests {
    private func shelfBook(_ reading: Reading, posts: Int = 0) -> Queries.ShelfBook {
        Queries.ShelfBook(reading: reading, postCount: posts, sectionCount: 0)
    }

    /// RED ON OLD ("smart · #books"): the shelf row's kind word is the Mac
    /// shelf row's own ("gathering").
    @Test func theShelfRowCallsAGatheringAGathering() {
        let meta: String = "gathering \u{00B7} #books"
        #expect(MobileShelfFaces.meta(
            for: shelfBook(reading("Reading notes", kind: .gathering)),
            tagPaths: ["books"], isDaily: false) == meta)
    }

    /// RED ON OLD ("Delete Book…" / "Delete Book" / "Book moved to the
    /// Trash…" on a gathering): the door, the confirm and the receipt name
    /// what they delete — the Mac's `deleteVerb(_:)` / `deleteDoorLabel(_:)`.
    @Test func theDeleteDoorConfirmAndReceiptNameAGathering() async throws {
        let gatheringDoor: String = "Delete Gathering\u{2026}"
        let gatheringConfirm: String = "Delete Gathering"
        let bookDoor: String = "Delete Book\u{2026}"
        let bookConfirm: String = "Delete Book"
        #expect(MobileShelfFaces.deleteDoorTitle(for: .gathering) == gatheringDoor)
        #expect(MobileShelfFaces.deleteConfirmTitle(for: .gathering) == gatheringConfirm)
        #expect(MobileShelfFaces.deleteDoorTitle(for: .book) == bookDoor)
        #expect(MobileShelfFaces.deleteConfirmTitle(for: .book) == bookConfirm)

        try await withEditorWorld { session, db in
            let (gatheringID, bookID) = try await session.runner.run { ops -> (String, String) in
                let tag = try ops.createTag(name: "quote")
                let gathering = try ops.createReading(
                    name: "Quotes", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
                let book = try ops.createReading(name: "Essays", kind: .book)
                return (gathering.id, book.id)
            }
            let shelf = try await db.read { db in try Queries.bookshelf(db) }
            let gathering = try #require(shelf.first { $0.reading.id == gatheringID })
            let book = try #require(shelf.first { $0.reading.id == bookID })
            let model = MobileShelfViewModel(session: session)

            #expect(await model.confirmDeleteBook(gathering))
            let gatheringReceipt: String =
                "Gathering moved to the Trash \u{2014} \(TrashWindow.days) days to put it back."
            #expect(model.lastReport == gatheringReceipt)

            #expect(await model.confirmDeleteBook(book))
            let bookReceipt: String =
                "Book moved to the Trash \u{2014} \(TrashWindow.days) days to put it back."
            #expect(model.lastReport == bookReceipt, "a book's receipt is unchanged")
        }
    }

    /// RED ON OLD: the membership row's mark said "smart"; the create sheet
    /// offered "Smart Book" and said "A smart book collects notes by these
    /// tags". The create sheet's sentences are DRAFTS for her wording pass
    /// (the run record), pinned exactly so a change is deliberate.
    @Test func theMembershipAndCreateSheetsSayGathering() {
        let mark: String = "gathering"
        #expect(MobileMembershipModel.kindMark(for: reading("Quotes", kind: .gathering)) == mark)
        #expect(MobileMembershipModel.kindMark(for: reading("Essays")) == nil)

        typealias C = MobileCreateBookModel
        let label: String = "Gathering"
        let caption: String =
            "A gathering shows every note these tags match and holds none of them \u{2014} "
            + "the tags stay on the notes."
        let noTags: String =
            "No tags yet \u{2014} notes get tags first; a gathering shows the notes that match them."
        #expect(C.kindLabel(.smartFromTags) == label)
        #expect(C.caption(for: .smartFromTags) == caption)
        #expect(C.noTagsLine == noTags)
        // The other two kinds keep their shipped words.
        #expect(C.kindLabel(.notes) == "Book")
        #expect(C.kindLabel(.journal) == "Journal Book")
    }

    /// RED ON OLD ("(empty book)"): an untitled gathering in the Trash is
    /// named by its own kind word (VX-611's `RecoveryCopy` rule).
    @Test func theTrashNamesAnUntitledGatheringAGathering() {
        let gathering = Queries.TrashItem(
            kind: .book, id: "g", deletedAt: "2026-11-19T00:00:00.000Z", isGathering: true)
        let book = Queries.TrashItem(kind: .book, id: "b", deletedAt: "2026-11-19T00:00:00.000Z")
        #expect(MobileTrashView.rowTitle(gathering) == "(empty gathering)")
        #expect(MobileTrashView.rowTitle(book) == "(empty book)")
    }

    /// RED ON THE PRE-FIX-PASS TIP (round 1, N2): with the row in hand the
    /// placeholder reads `RecoveryCopy.rowKind(item)` — the shared file's rule
    /// "wherever the row itself is in hand", and the word the row's own meta
    /// line already speaks — so an untitled saved version is named as one,
    /// never "(empty note)".
    @Test func theTrashNamesAnUntitledSavedVersionAsOne() {
        let version = Queries.TrashItem(
            kind: .note, id: "v", deletedAt: "2026-11-19T00:00:00.000Z", versionOfNoteID: "n")
        let expected: String = "(empty \(RecoveryCopy.rowKind(version)))"
        #expect(MobileTrashView.rowTitle(version) == expected)
        #expect(MobileTrashView.rowTitle(version) != "(empty note)")
        let note = Queries.TrashItem(kind: .note, id: "p", deletedAt: "2026-11-19T00:00:00.000Z")
        #expect(MobileTrashView.rowTitle(note) == "(empty note)", "a plain note keeps its word")
    }

    /// The brief's pin — no phone string these faces render says "smart", in
    /// any case. A HAND-KEPT LIST of what these faces render, not a source
    /// scan (round 1, N7): a new literal in these faces would pass it. The
    /// Mac's source-scanning ban (`DeadVocabularyTests`) is the mechanism to
    /// adopt for the phone once the last two sites go (the Today door's note,
    /// VM-85; the pocket guide, VM-212).
    @Test func noRenderedStringInTheseFacesSaysSmart() {
        let gathering = reading("Reading notes", kind: .gathering)
        let trashed = Queries.TrashItem(
            kind: .book, id: "g", deletedAt: "2026-11-19T00:00:00.000Z", isGathering: true)
        var rendered: [String] = [
            MobileShelfFaces.meta(for: shelfBook(gathering), tagPaths: ["books"], isDaily: false),
            MobileShelfFaces.deleteDoorTitle(for: .gathering),
            MobileShelfFaces.deleteConfirmTitle(for: .gathering),
            MobileShelfFaces.deleteBookConfirmDetail(name: "Reading notes"),
            MobileMembershipModel.kindMark(for: gathering) ?? "",
            MobileMembershipModel.addRowLabel(for: gathering),
            MobileMembershipModel.memberRowName(for: gathering),
            MobileCreateBookModel.noTagsLine,
            MobileTrashView.rowTitle(trashed),
        ]
        for kind in MobileCreateBookModel.BookKind.allCases {
            rendered.append(MobileCreateBookModel.kindLabel(kind))
            rendered.append(MobileCreateBookModel.caption(for: kind))
        }
        for line in rendered {
            #expect(line.range(of: "smart", options: .caseInsensitive) == nil, "\(line)")
        }
    }
}

// MARK: - VM-21: the collect receipt and the "(archived)" marks (F4, F5)

@MainActor
@Suite("VM-21 — the collect receipt names the star and is honest on an archived gathering")
struct MobileCollectReceiptTests {
    /// A gathering on `term`, a fresh untagged note, and the note's sheet.
    private func world(
        _ session: AppSession, name: String, archived: Bool = false,
        term: @escaping @Sendable (Operations) throws -> RuleTerm
    ) async throws -> (MobileMembershipModel, Reading) {
        let (postID, gatheringID) = try await session.runner.run { ops -> (String, String) in
            let gathering = try ops.createReading(
                name: name, kind: .gathering, querySpec: try RuleGrammar.encode(try term(ops)))
            if archived { try ops.archiveReading(gathering.id) }
            return (try ops.createPost(title: "loose piece").id, gathering.id)
        }
        let model = MobileMembershipModel(session: session, postID: postID)
        await model.refresh()
        let gathering = try #require(model.addableSmartBooks.first { $0.id == gatheringID })
        return (model, gathering)
    }

    /// RED ON OLD ("Added by tagging  — “Starred notes” collects by filter."
    /// — no star named, and an empty tag list).
    @Test func aStarOnlyCollectNamesTheStar() async throws {
        try await withEditorWorld { session, _ in
            let (model, gathering) = try await world(session, name: "Starred notes") { _ in .star }
            await model.collect(into: gathering)
            let receipt: String = "Starred \u{2014} the gathering shows it now."
            #expect(model.status == receipt)
        }
    }

    /// RED ON OLD ("Added by tagging #drafts — …" — the star it set unnamed).
    @Test func aTagAndStarCollectNamesBoth() async throws {
        try await withEditorWorld { session, _ in
            let (model, gathering) = try await world(session, name: "Drafts") { ops in
                .and([.tag(try ops.createTag(name: "drafts").id), .star])
            }
            await model.collect(into: gathering)
            let receipt: String = "Tagged #drafts and starred \u{2014} the gathering shows it now."
            #expect(model.status == receipt)
        }
    }

    /// RED ON OLD ("…“Harbor” collects by filter." on a gathering that, being
    /// archived, shows nothing anywhere until it is unarchived).
    @Test func anArchivedGatheringsReceiptSaysWhenItWillShow() async throws {
        try await withEditorWorld { session, _ in
            let (model, gathering) = try await world(session, name: "Harbor", archived: true) { ops in
                .tag(try ops.createTag(name: "sea").id)
            }
            await model.collect(into: gathering)
            let receipt: String = "Tagged #sea \u{2014} the gathering shows it once it's unarchived."
            #expect(model.status == receipt)
        }
    }

    /// GREEN ON BOTH SIDES (the controls): a live tags-only collect and an
    /// already-matching one keep the chip's shipped words.
    @Test func aLiveTagsOnlyCollectKeepsTheChipsWords() async throws {
        try await withEditorWorld { session, _ in
            let (model, gathering) = try await world(session, name: "By the Water") { ops in
                .tag(try ops.createTag(name: "sea").id)
            }
            await model.collect(into: gathering)
            let receipt: String =
                "Added by tagging #sea \u{2014} \u{201C}By the Water\u{201D} collects by filter."
            #expect(model.status == receipt)
            await model.collect(into: gathering)
            let again: String =
                "Already collected \u{2014} it matches \u{201C}By the Water\u{201D}'s filter."
            #expect(model.status == again)
        }
    }

    /// RED ON OLD: the add list and the membership rows named an archived
    /// book bare. The shared `BookArchiveCopy` mark; a gathering's add row
    /// keeps its road word (and carries the mark too — PROVISIONAL, the run
    /// record lists the options).
    @Test func pickersMarkAnArchivedBook() async throws {
        typealias M = MobileMembershipModel
        let archivedBook: String = "Old projects (archived)"
        let archivedGathering: String = "Quotes (archived) (by tagging)"
        let finishedArchived: String = "Old projects \u{2713} (archived)"
        #expect(M.addRowLabel(for: reading("Old projects", archived: true)) == archivedBook)
        #expect(M.addRowLabel(for: reading("Essays")) == "Essays")
        #expect(M.addRowLabel(for: reading("Quotes", kind: .gathering)) == "Quotes (by tagging)")
        #expect(M.addRowLabel(for: reading("Quotes", kind: .gathering, archived: true))
                == archivedGathering)
        #expect(M.memberRowName(for: reading("Old projects", archived: true)) == archivedBook)
        #expect(M.memberRowName(for: reading("Old projects", locked: true, archived: true))
                == finishedArchived)
        #expect(M.memberRowName(for: reading("Essays")) == "Essays")

        // And the store's own listing offers the archived book (explicit adds
        // stay open), wearing the mark.
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Old projects", kind: .book)
                try ops.archiveReading(book.id)
                return try ops.createPost(title: "a note").id
            }
            let model = MobileMembershipModel(session: session, postID: postID)
            await model.refresh()
            #expect(model.addableBooks.map(M.addRowLabel(for:)) == [archivedBook])
        }
    }
}
