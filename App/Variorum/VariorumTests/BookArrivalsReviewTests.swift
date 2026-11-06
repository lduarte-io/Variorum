//
//  BookArrivalsReviewTests.swift
//  VariorumTests
//
//  VX-821 (the VX-808 run, Unit B3) — THE ARRIVALS REVIEW AREA (R-808-5, her
//  pick "Full book area, one home"; the bulk ruling A-808-11). NEW CAPABILITY
//  — red on old by construction (none of it existed); the walk at the stage
//  window is the face's acceptance gate. What these hold:
//
//  · the WORDS, pure (`ArrivalsReviewCopy` — why each row waits for all nine
//    kinds, since when, the header, the bar, the bulk messages, the confirm);
//  · the RULES, pure — the pick (click / ⌘ / ⇧ through the Library's one
//    brain, ⌘A, the walked row, ↑ ↓ and ⇧-walk, the prune that keeps a
//    choice row picked and slides the next row under the keyboard), the key
//    map, the bulk message's composition, which navigation closes the
//    review, and the receipt's home while the review covers a bar;
//  · the BULK ROADS against a real store — per-row acts in listing order,
//    one message per press, NO undo entry, choice rows named and kept, the
//    book's refusal ending the run, a row's own refusal skipping it, "all"
//    reaching past the listed window, Dismiss all's confirm acting on
//    exactly the rows it named, ⏎ / ⌫ on the walked row;
//  · the review MOUNTED over a book's mode: its header, its doors (the bar's
//    pair appearing with a pick), its rows' why lines, the calm empty answer.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A living book on `#inbox` whose new matches WAIT at the door, `members`
/// seated by hand, and `waiting` notes rung to the door by real intake.
@MainActor
private func withReviewBook<T>(
    members: Int = 0, waiting: Int, maxPosts: Int? = nil,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String, _ tagID: String, _ waitingIDs: [String]
    ) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 821))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let ops = session.operations
        let inbox = try ops.createTag(name: "inbox")
        let rule = try #require(try RuleGrammar.encode(.tag(inbox.id)))
        let book = try ops.createReading(
            name: "the living book", kind: .book, querySpec: rule,
            maxPosts: maxPosts, intakeSeating: .arrivals)
        for m in 0..<members {
            let post = try ops.createPost(title: "member \(m)")
            try ops.addPostToReading(post.id, to: book.id)
        }
        var waitingIDs: [String] = []
        for w in 0..<waiting {
            let post = try ops.createPost(title: "waiting \(w)")
            _ = try ops.applyTag(inbox.id, toPost: post.id)
            waitingIDs.append(post.id)
        }
        return try await body(session, db, book.id, inbox.id, waitingIDs)
    }
}

@MainActor
@Suite("VX-821 — the Arrivals review area (the pick, the keys, the bulk doors, why it waits)", .serialized)
struct BookArrivalsReviewTests {
    // MARK: - Helpers

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 30
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            if predicate() { return }
        }
    }

    /// What the observation would deliver now (its window, or `limit`),
    /// adopted by hand, with the rows' facts and first words.
    private func refresh(
        _ model: BookArrivalsModel, _ db: AppDatabase, limit: Int? = nil
    ) async throws {
        let readingID = model.readingID
        let window = limit ?? model.listingLimit
        model.adopt(try await db.read {
            try Queries.bookArrivals($0, readingID: readingID, limit: window)
        })
        await model.loadFacts()
    }

    private func book(_ db: AppDatabase, _ id: String) async throws -> Reading? {
        try await db.read { try Queries.reading($0, id: id) }
    }

    private func row(_ db: AppDatabase, _ id: String) async throws -> ReadingPost? {
        try await db.read { try ReadingPost.fetchOne($0, key: id) }
    }

    private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
        try await db.read { try Queries.assembleReading($0, readingID: readingID) }.map(\.postID)
    }

    private func arrival(
        _ id: String, kind: ArrivalProvenance.Kind? = nil, client: String? = nil,
        reason: String? = nil, after: ArrivalProvenance.CatchUpCause? = nil,
        tagPath: String? = nil, archived: Bool = false
    ) -> Queries.BookArrival {
        Queries.BookArrival(
            id: id, postID: "p-\(id)", title: "t-\(id)", arrivedAt: "2026-11-05T10:00:00.000Z",
            archived: archived,
            provenance: kind.map {
                ArrivalProvenance(kind: $0, client: client, reason: reason, tag: tagPath == nil ? nil : "tag", after: after)
            },
            tagPath: tagPath)
    }

    // MARK: - The words (pure)

    @Test func everyCauseSaysWhyItWaitsInOneLine() {
        typealias Copy = ArrivalsReviewCopy
        #expect(Copy.why(arrival("a", kind: .proposed, client: "claude-code")) == "Proposed by claude-code")
        #expect(Copy.why(arrival("a", kind: .ruleEdit)) == "Matched the book\u{2019}s new rule")
        #expect(Copy.why(arrival("a", kind: .ruleEdit, client: "claude-code"))
                == "Matched the book\u{2019}s new rule, set by claude-code")
        #expect(Copy.why(arrival("a", kind: .backfill)) == "Matched when the book was made")
        #expect(Copy.why(arrival("a", kind: .catchup, after: .unarchive)) == "Caught up after un-archiving")
        #expect(Copy.why(arrival("a", kind: .catchup, after: .restore)) == "Caught up after restoring the book")
        #expect(Copy.why(arrival("a", kind: .catchup, after: .reopen)) == "Caught up after reopening the book")
        #expect(Copy.why(arrival("a", kind: .catchup, after: .unseal)) == "Caught up after unsealing the book")
        #expect(Copy.why(arrival("a", kind: .catchup)) == "Caught up when the book resumed collecting")
        #expect(Copy.why(arrival("a", kind: .tagged, tagPath: "life/goals")) == "Tagged #life/goals")
        #expect(Copy.why(arrival("a", kind: .tagged, client: "cc", tagPath: "work")) == "Tagged #work by cc")
        #expect(Copy.why(arrival("a", kind: .tagged)) == "Tagged", "a dead tag falls back to the kind word")
        #expect(Copy.why(arrival("a", kind: .starred)) == "Starred")
        #expect(Copy.why(arrival("a", kind: .starred, client: "cc")) == "Starred by cc")
        #expect(Copy.why(arrival("a", kind: .journalFiling)) == "Filed for today \u{2014} another book owns it")
        #expect(Copy.why(arrival("a", kind: .ownedElsewhere)) == "Came back while another book owns it")
        #expect(Copy.why(arrival("a", kind: .wingMend))
                == "Filed here from another wing \u{2014} the note lives with another book now")
        // NULL, or a kind this build doesn't know: since-when only.
        #expect(Copy.why(arrival("a")) == nil)
        let newer = Queries.BookArrival(
            id: "n", postID: "p", title: "t", arrivedAt: "x",
            provenance: ArrivalProvenance.decode(#"{"kind":"from_the_future"}"#))
        #expect(newer.provenance != nil && Copy.why(newer) == nil, "an unknown kind says nothing")
        // The reason is the proposal's own prose, quoted — never another cause's.
        #expect(Copy.reason(arrival("a", kind: .proposed, client: "cc", reason: "fits chapter two"))
                == "\u{201C}fits chapter two\u{201D}")
        #expect(Copy.reason(arrival("a", kind: .proposed, client: "cc")) == nil)
        #expect(Copy.reason(arrival("a", kind: .ruleEdit, reason: "stray")) == nil)
    }

    @Test func theHeaderBarAndBulkWordsAreHers() {
        typealias Copy = ArrivalsReviewCopy
        #expect(ArrivalsCopy.header(count: 4) == "Arrivals \u{2014} 4 waiting")
        #expect(Copy.addAllVerb == "Add all" && Copy.dismissAllVerb == "Dismiss all")
        #expect(Copy.addSelectedLabel(3) == "Add 3" && Copy.dismissSelectedLabel(3) == "Dismiss 3")
        #expect(Copy.selected(3) == "3 selected")
        #expect(Copy.doneVerb == "Done")
        #expect(Copy.addedMany(3, chaptered: false, archived: 0) == "Added 3 notes at the end of the book.")
        #expect(Copy.addedMany(3, chaptered: true, archived: 1)
                == "Added 3 notes at the end of the book, unfiled. One is archived, so it waits in the "
                    + "book\u{2019}s archived line.")
        #expect(Copy.dismissedMany(4)
                == "Dismissed 4 notes \u{2014} they won\u{2019}t come back on their own; add any of them "
                    + "by hand any time.")
        #expect(Copy.waitOnChoice(["A"]).hasPrefix("\u{201C}A\u{201D} waits on your choice"))
        #expect(Copy.waitOnChoice(["A", "B"]).hasPrefix("\u{201C}A\u{201D} and \u{201C}B\u{201D} wait on your choice"))
        #expect(Copy.namedList(["a", "b", "c", "d", "e"])
                == "\u{201C}a\u{201D}, \u{201C}b\u{201D}, \u{201C}c\u{201D} and 2 more")
        #expect(Copy.dismissAllTitle(12) == "Dismiss all 12 waiting notes?")
        #expect(Copy.dismissAllTitle(1) == "Dismiss the waiting note?")
        #expect(Copy.dismissAllConfirm(12) == "Dismiss 12")
        // Sentence case throughout — never a capital for emphasis. Initialisms
        // are not shouting (the no-shouty-caps rule bans EMPHASIS capitals):
        // the app's standing ones are allowed, by name, and nothing else.
        let initialisms: Set<String> = ["AI"]
        for words in [Copy.keysHint, Copy.nothingWaiting, Copy.doneHelp, Copy.addAllHelp,
                      Copy.dismissAllHelp, Copy.dismissedMany(2), Copy.waitOnChoice(["a"])] {
            let shouted = words.split(separator: " ").contains { token in
                let letters = token.filter(\.isLetter)
                return letters.count > 1 && letters == letters.uppercased()
                    && !initialisms.contains(letters)
            }
            #expect(!shouted, "no word in capitals: \(words)")
        }
    }

    // MARK: - The bulk message (pure)

    private func bulkRow(_ id: String, choice: Bool = false, archived: Bool = false) -> ArrivalsBulk.Row {
        ArrivalsBulk.Row(id: id, name: id, archived: archived, needsChoice: choice)
    }

    @Test func onePressSpeaksOneMessageWithEveryFact() {
        // Every row landed: a receipt.
        let all = ArrivalsBulk.words(
            .add, outcomes: [(bulkRow("a"), .landed), (bulkRow("b"), .landed)],
            bookRefusal: nil, chaptered: false)
        #expect(all.receipt == "Added 2 notes at the end of the book." && all.refusal == nil)
        // One row speaks the single act's own words.
        let one = ArrivalsBulk.words(.add, outcomes: [(bulkRow("a"), .landed)], bookRefusal: nil, chaptered: false)
        #expect(one.receipt == ArrivalsCopy.added("a", chaptered: false))
        let oneDismiss = ArrivalsBulk.words(
            .dismiss, outcomes: [(bulkRow("a"), .landed)], bookRefusal: nil, chaptered: false)
        #expect(oneDismiss.receipt == ArrivalsCopy.dismissed("a"))
        // Mixed: a REFUSAL carrying both facts (the Trash's shape).
        let mixed = ArrivalsBulk.words(
            .add,
            outcomes: [(bulkRow("a"), .landed), (bulkRow("b"), .landed),
                       (bulkRow("c", choice: true), .waitsOnChoice),
                       (bulkRow("d"), .refused("That one was judged.")),
                       (bulkRow("e"), .stillWaiting), (bulkRow("f"), .stillWaiting)],
            bookRefusal: "The book is full.", chaptered: false)
        #expect(mixed.receipt == nil)
        #expect(mixed.refusal
                == "Added 2 notes at the end of the book. " + ArrivalsReviewCopy.waitOnChoice(["c"])
                    + " 1 couldn\u{2019}t be added: That one was judged. 2 still wait: The book is full.")
        // Nothing landed: the book's refusal alone reads as itself.
        let full = ArrivalsBulk.words(
            .add, outcomes: [(bulkRow("a"), .stillWaiting)], bookRefusal: "The book is full.", chaptered: false)
        #expect(full.refusal == "The book is full." && full.receipt == nil)
        let choiceOnly = ArrivalsBulk.words(
            .add, outcomes: [(bulkRow("a", choice: true), .waitsOnChoice)], bookRefusal: nil, chaptered: false)
        #expect(choiceOnly.refusal == ArrivalsReviewCopy.waitOnChoice(["a"]))
        // The classification: the BOOK's refusals end the run; ownership is a choice.
        #expect(ArrivalsBulk.endsTheRun(OperationError.readingAtCapacity(id: "b")))
        #expect(ArrivalsBulk.endsTheRun(OperationError.lockedReading(id: "b")))
        #expect(ArrivalsBulk.endsTheRun(OperationError.readingNotFound(id: "b")))
        #expect(!ArrivalsBulk.endsTheRun(OperationError.arrivalNotFound(id: "r")))
        #expect(!ArrivalsBulk.endsTheRun(OperationError.containerNotFound(id: "n")))
    }

    // MARK: - The pick and the walked row (pure)

    @Test func thePickFollowsTheMacIdiomAndTheKeyboardWalks() {
        let order = ["a", "b", "c", "d"]
        var pick = ArrivalsSelection()
        pick.prune(toVisible: order)
        #expect(pick.walked == "a" && pick.isEmpty, "a fresh listing walks its first row, picks nothing")
        #expect(pick.targets(in: order) == ["a"], "⏎ / ⌫ act on the walked row while nothing is picked")
        pick.click("b", modifiers: .none, order: order)
        #expect(pick.picked == ["b"] && pick.walked == "b")
        pick.click("d", modifiers: .shift_, order: order)
        #expect(pick.picked == ["b", "c", "d"], "⇧ takes the range from the anchor")
        pick.click("c", modifiers: .command_, order: order)
        #expect(pick.picked == ["b", "d"], "⌘ toggles one")
        pick.toggle("a", order: order)
        #expect(pick.picked == ["a", "b", "d"], "the checkbox is ⌘-click's meaning")
        #expect(pick.targets(in: order) == ["a", "b", "d"], "a pick acts in LISTING order")
        pick.clearPick()
        pick.selectAll(order)
        #expect(pick.picked == Set(order), "⌘A picks every listed row")

        var walk = ArrivalsSelection()
        walk.walk(.down, extend: false, order: order)
        #expect(walk.walked == "a")
        walk.walk(.down, extend: false, order: order)
        walk.walk(.down, extend: false, order: order)
        #expect(walk.walked == "c" && walk.isEmpty, "arrows walk, they never pick")
        walk.walk(.up, extend: true, order: order)
        #expect(walk.walked == "b" && walk.picked == ["b", "c"], "⇧-arrows extend the pick")
        var top = ArrivalsSelection()
        top.walk(.up, extend: false, order: order)
        #expect(top.walked == "d", "↑ from nowhere starts at the bottom")
        top.walk(.down, extend: false, order: order)
        #expect(top.walked == "d", "the walk stops at the ends")
    }

    @Test func aJudgedRowsSuccessorSlidesUnderTheKeyboardAndAChoiceRowStaysPicked() {
        var pick = ArrivalsSelection()
        pick.prune(toVisible: ["a", "b", "c"])
        pick.walk(.down, extend: false, order: ["a", "b", "c"])  // a → b
        #expect(pick.walked == "b")
        // b was judged: the row that took its place is walked.
        pick.prune(toVisible: ["a", "c"])
        #expect(pick.walked == "c")
        // The last one judged: the walk falls back to the row above.
        pick.prune(toVisible: ["a"])
        #expect(pick.walked == "a")
        pick.prune(toVisible: [])
        #expect(pick.walked == nil && pick.targets(in: []) == [])
        // A bulk Add left a choice row waiting: it STAYS picked (the retry is
        // one press); the landed ones leave the pick.
        var bulk = ArrivalsSelection()
        bulk.selectAll(["x", "y", "z"])
        bulk.prune(toVisible: ["y"])
        #expect(bulk.picked == ["y"])
    }

    @Test func theKeysAreHerRuledKeysAndNeverAChord() {
        #expect(ArrivalsKey.act(for: .down, shift: false) == .walk(.down, extend: false))
        #expect(ArrivalsKey.act(for: .up, shift: true) == .walk(.up, extend: true))
        #expect(ArrivalsKey.act(for: .returnKey, shift: false) == .add)
        #expect(ArrivalsKey.act(for: .delete, shift: false) == .dismiss)
        #expect(ArrivalsKey.act(for: .escape, shift: false) == .done)
        #expect(ArrivalsKey.act(for: .returnKey, shift: true) == nil)
        #expect(ArrivalsKey.act(for: .up, shift: false, command: true) == nil, "⌘↑ is never ours")
        #expect(ArrivalsKey.act(for: .delete, shift: false, option: true) == nil)
        #expect(ArrivalsKey.act(for: .returnKey, shift: false, control: true) == nil)
    }

    @Test func aNavigationSheAskedForClosesTheReviewAndASurfaceFinishingItsWorkDoesNot() {
        let rest = ArrivalsReviewSignal(
            mode: .outline, focusedPostID: "n1", indexSelectedPostID: nil,
            spreadFirstPostID: nil, reveal: nil, chapterReveal: nil, landingPostID: nil)
        var next = rest
        next.mode = .index
        #expect(ArrivalsReviewSignal.navigated(from: rest, to: next), "a mode")
        next = rest
        next.focusedPostID = "n2"
        #expect(ArrivalsReviewSignal.navigated(from: rest, to: next), "a note focused")
        next = rest
        next.reveal = "n3"
        #expect(ArrivalsReviewSignal.navigated(from: rest, to: next), "a reveal asked for")
        next = rest
        next.chapterReveal = "c1"
        #expect(ArrivalsReviewSignal.navigated(from: rest, to: next), "a chapter asked for")
        var parked = rest
        parked.reveal = "n3"
        #expect(!ArrivalsReviewSignal.navigated(from: parked, to: rest), "a reveal CONSUMED is the surface's own")
        #expect(!ArrivalsReviewSignal.navigated(from: rest, to: rest))
    }

    /// **W-1 (the leg-2 walk, A-808-11 F-4)** — the review's OWN acts are
    /// never navigation. Seating into an EMPTY book fills the spread's first
    /// page from nothing and seeds the Index's cold selection from nothing
    /// (`BookIndexView.landOrSeed`), and the book releasing a focus it no
    /// longer shows is its own housekeeping: none of these is her ask to see
    /// something. A page or selection MOVING from one note to another, and a
    /// note focused, still are. Red on old: the old rule closed on any change.
    @Test func theBooksContentArrivingIsNeverNavigation() {
        let empty = ArrivalsReviewSignal(
            mode: .outline, focusedPostID: nil, indexSelectedPostID: nil,
            spreadFirstPostID: nil, reveal: nil, chapterReveal: nil, landingPostID: nil)
        var seeded = empty
        seeded.spreadFirstPostID = "first seated"
        #expect(!ArrivalsReviewSignal.navigated(from: empty, to: seeded),
                "an empty book's first seat fills the spread's first page — content, not navigation")
        seeded.indexSelectedPostID = "first seated"
        #expect(!ArrivalsReviewSignal.navigated(from: empty, to: seeded),
                "the Index's cold seed selects from nothing — content, not navigation")
        var focused = empty
        focused.focusedPostID = "n1"
        #expect(!ArrivalsReviewSignal.navigated(from: focused, to: empty),
                "a released focus is the book's housekeeping, never an ask")
        // Still navigation: a page or a selection MOVING, a note focused.
        var paged = seeded
        paged.spreadFirstPostID = "another"
        #expect(ArrivalsReviewSignal.navigated(from: seeded, to: paged), "the spread turned")
        var reselected = seeded
        reselected.indexSelectedPostID = "another"
        #expect(ArrivalsReviewSignal.navigated(from: seeded, to: reselected), "the Index moved")
        #expect(ArrivalsReviewSignal.navigated(from: empty, to: focused), "a note focused")
    }

    @Test func whileTheReviewCoversABarItsOwnBarHostsTheReceipt() {
        typealias Home = BookNoteBox.QuietReceiptHome
        let home = { (mode: BookStructureModel.ViewMode, reviewing: Bool) -> Home in
            BookNoteBox.quietReceiptHome(
                mode: mode, pagedRead: false, modeBarShown: true, box: nil, reviewing: reviewing)
        }
        #expect(home(.outline, false) == .pageFoot && home(.outline, true) == .reviewBar)
        #expect(home(.spread, false) == .modeBottomBar && home(.spread, true) == .reviewBar)
        #expect(home(.read, true) == .reviewBar)
        #expect(home(.index, true) == .indexColumnFooter, "Index's column stays in view beside the review")
    }

    // MARK: - The bulk roads (state transitions, a real store)

    @Test func addSelectedSeatsEachPickedRowAtTheEndInListingOrderAndRegistersNoUndo() async throws {
        try await withReviewBook(members: 1, waiting: 3) { session, db, readingID, _, waitingIDs in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let rows = model.door.rows
            try #require(rows.map(\.postID) == waitingIDs)
            model.click(rows[2].id, modifiers: .none)
            model.click(rows[0].id, modifiers: .command_)
            let depth = session.undoStack.depth
            let membersBefore = try await members(db, readingID)

            await model.addSelected(book: try await book(db, readingID), chaptered: false)

            #expect(try await members(db, readingID) == membersBefore + [waitingIDs[0], waitingIDs[2]],
                    "seated at the END, in the order they rang")
            #expect(try await row(db, rows[1].id)?.status == .arrival, "the unpicked row waits")
            #expect(session.undoStack.depth == depth, "no ⌥⌘Z entry — the single acts' own posture")
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text == "Added 2 notes at the end of the book.")
            try await refresh(model, db)
            #expect(model.selection.isEmpty, "the landed rows left the pick")
            #expect(model.judging.isEmpty && !model.bulkInFlight)
        }
    }

    @Test func dismissSelectedTombstonesEachPickedRowAndSpeaksOnce() async throws {
        try await withReviewBook(waiting: 3) { session, db, readingID, _, _ in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let rows = model.door.rows
            model.selectAll()
            let depth = session.undoStack.depth
            await model.dismissSelected(book: try await book(db, readingID))
            for arrival in rows {
                let stored = try #require(try await row(db, arrival.id))
                #expect(stored.deletedAt != nil && stored.status == .arrival, "the decision record")
            }
            #expect(session.undoStack.depth == depth)
            #expect(session.status.spoken?.text == ArrivalsReviewCopy.dismissedMany(3))
            #expect(try await members(db, readingID).isEmpty, "dismissing never touches membership")
        }
    }

    @Test func aBooksRefusalEndsTheRunAndCountsTheRestAsWaiting() async throws {
        try await withReviewBook(members: 1, waiting: 3, maxPosts: 2) { session, db, readingID, _, waitingIDs in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let reading = try await book(db, readingID)
            await model.addAll(book: reading, chaptered: false)
            let seated = try await members(db, readingID)
            #expect(seated.count == 2 && seated.last == waitingIDs[0], "the first lands, then the book is full")
            #expect(session.status.current?.kind == .refusal)
            let full = ArrivalsCopy.refusal(
                for: OperationError.readingAtCapacity(id: readingID), book: "the living book", cap: 2)
            #expect(session.status.current?.text
                    == ArrivalsCopy.added("waiting 0", chaptered: false) + " "
                        + ArrivalsReviewCopy.stillWaiting(2, reason: full))
            try await refresh(model, db)
            #expect(model.door.count == 2, "the rest still wait")
        }
    }

    @Test func aRowsOwnRefusalSkipsItAndTheRunGoesOn() async throws {
        try await withReviewBook(waiting: 3) { session, db, readingID, _, waitingIDs in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let rows = model.door.rows
            model.selectAll()
            // Another window judged the middle row; this listing has not caught up.
            try session.operations.dismissArrival(rows[1].id)
            await model.addSelected(book: try await book(db, readingID), chaptered: false)
            #expect(try await members(db, readingID) == [waitingIDs[0], waitingIDs[2]])
            let judged = ArrivalsCopy.refusal(
                for: OperationError.arrivalNotFound(id: rows[1].id), book: "the living book", cap: nil)
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text
                    == "Added 2 notes at the end of the book. "
                        + ArrivalsReviewCopy.couldNot(1, act: .add, reason: judged))
        }
    }

    @Test func allReachesPastTheListedWindowAndDismissAllActsOnExactlyWhatItAsked() async throws {
        try await withReviewBook(waiting: 3) { session, db, readingID, tagID, _ in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db, limit: 1)
            #expect(model.door.count == 3 && model.door.rows.count == 1, "one listed, three waiting")
            let reading = try await book(db, readingID)
            await model.requestDismissAll(book: reading)
            let asked = try #require(model.pendingDismissAll)
            #expect(asked.count == 3, "the ask names the header's N, not the listed window")
            // A note rings AFTER the ask — she was never asked about it.
            let late = try session.operations.createPost(title: "late")
            _ = try session.operations.applyTag(tagID, toPost: late.id)
            await model.confirmDismissAll(asked, book: reading)
            #expect(model.pendingDismissAll == nil)
            try await refresh(model, db)
            #expect(model.door.rows.map(\.postID) == [late.id], "the late bell still waits")
            #expect(session.status.spoken?.text == ArrivalsReviewCopy.dismissedMany(3))
        }
    }

    @Test func aBulkAddNamesTheRowsThatWaitOnHerChoiceAndKeepsThemPicked() async throws {
        try await withReviewBook(waiting: 0) { session, db, _, _, _ in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let rule = try #require(try RuleGrammar.encode(.tag(t.id)))
            let mine = try ops.createReading(
                name: "Mine", kind: .book, querySpec: rule, intakeSeating: .arrivals)
            try ops.setReadingOwned(mine.id, owned: true)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            try ops.addPostToReading(shared.id, to: other.id)
            let free = try ops.createPost(title: "free")
            _ = try ops.applyTag(t.id, toPost: shared.id)
            _ = try ops.applyTag(t.id, toPost: free.id)

            let model = BookArrivalsModel(session: session, readingID: mine.id)
            model.setReviewOpen(true)
            try await refresh(model, db)
            #expect(Set(model.door.rows.map(\.postID)) == [shared.id, free.id])
            model.selectAll()
            let reading = try await book(db, mine.id)
            await model.addSelected(book: reading, chaptered: false)

            #expect(try await members(db, mine.id) == [free.id], "the free note landed")
            let sharedRow = try #require(model.door.rows.first { $0.postID == shared.id })
            #expect(try await row(db, sharedRow.id)?.status == .arrival, "the choice row was never run")
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text
                    == ArrivalsCopy.added("free", chaptered: false) + " "
                        + ArrivalsReviewCopy.waitOnChoice(["shared"]))
            try await refresh(model, db)
            #expect(model.selection.picked == [sharedRow.id], "it stays picked — the retry is one press")
        }
    }

    @Test func returnAndDeleteJudgeTheWalkedRowWhenNothingIsPicked() async throws {
        try await withReviewBook(waiting: 3) { session, db, readingID, _, waitingIDs in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let reading = try await book(db, readingID)
            #expect(model.selection.walked == model.door.rows.first?.id, "the keyboard starts on the first row")
            await model.addKeyTargets(book: reading, chaptered: false)
            #expect(try await members(db, readingID) == [waitingIDs[0]])
            #expect(session.status.spoken?.text == ArrivalsCopy.added("waiting 0", chaptered: false),
                    "one row speaks the single act's own words")
            try await refresh(model, db)
            #expect(model.selection.walked == model.door.rows.first?.id, "the next row slid under the keyboard")
            let next = try #require(model.door.rows.first)
            await model.dismissKeyTargets(book: reading)
            #expect(try await row(db, next.id)?.deletedAt != nil)
            #expect(session.status.spoken?.text == ArrivalsCopy.dismissed("waiting 1"))
        }
    }

    @Test func pressesOverNothingSaySo() async throws {
        try await withReviewBook(waiting: 0) { session, db, readingID, _, _ in
            let model = BookArrivalsModel(session: session, readingID: readingID)
            model.setReviewOpen(true)
            try await refresh(model, db)
            let reading = try await book(db, readingID)
            await model.addSelected(book: reading, chaptered: false)
            #expect(session.status.current?.text == ArrivalsReviewCopy.nothingSelected)
            await model.addAll(book: reading, chaptered: false)
            #expect(session.status.current?.text == ArrivalsReviewCopy.nothingWaitingToJudge)
            await model.requestDismissAll(book: reading)
            #expect(model.pendingDismissAll == nil, "no ask over nothing")
            // Closing forgets the pick; reopening starts clean.
            model.setReviewOpen(false)
            #expect(model.listingLimit == 0 && model.selection == ArrivalsSelection())
        }
    }

    // MARK: - Mounted

    @Test func theReviewDrawsOverTheBookWithItsHeaderItsDoorsAndWhyEachRowWaits() async throws {
        ArrivalsReviewProbe.reset()
        ArrivalsLineProbe.reset()
        ArrivalsDoorProbe.reset()
        try await withReviewBook(members: 1, waiting: 2) { session, db, readingID, tagID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await book(db, readingID), sections: [], deletedSections: [],
                assignments: [:]))
            structure.mode = .outline
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setReviewOpen(true)
            try await refresh(arrivals, db)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure, arrivals: arrivals))
            hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) {
                ArrivalsReviewProbe.drawn[readingID] != nil
                    && (ArrivalsLineProbe.drawn[readingID]?.rows.count ?? 0) == 2
            }
            let review = try #require(ArrivalsReviewProbe.drawn[readingID], "the review is drawn over the book")
            #expect(review.header == "Arrivals \u{2014} 2 waiting")
            #expect(review.doors == ["Add all", "Dismiss all", "Done"], "no pick, no bar pair")
            #expect(review.empty == false)
            #expect(review.walked == arrivals.door.rows.first?.id)
            #expect(ArrivalsDoorProbe.drawn[readingID]?.open == true, "the door says the review is open")
            let rows = try #require(ArrivalsLineProbe.drawn[readingID])
            for arrival in arrivals.door.rows {
                #expect(rows.rows[arrival.id] == [ArrivalsCopy.addVerb, ArrivalsCopy.dismissVerb])
                #expect(rows.why[arrival.id] == "Tagged #inbox", "why it waits, drawn")
            }
            _ = tagID

            // A pick grows the bar's pair, with its count.
            arrivals.click(try #require(arrivals.door.rows.first).id, modifiers: .none)
            await settle(window, hosting) {
                ArrivalsReviewProbe.drawn[readingID]?.doors.contains("Add 1") == true
            }
            #expect(ArrivalsReviewProbe.drawn[readingID]?.doors
                    == ["Add all", "Dismiss all", "Add 1", "Dismiss 1", "Done"])

            // Done returns the book: the review is gone, the door calm-or-present again.
            arrivals.setReviewOpen(false)
            await settle(window, hosting) { ArrivalsReviewProbe.drawn[readingID] == nil }
            #expect(ArrivalsReviewProbe.drawn[readingID] == nil, "the review left the book's area")
            #expect(ArrivalsDoorProbe.drawn[readingID]?.open == false)
        }
    }

    /// **W-1 (the leg-2 walk), mounted — red on old.** The walk's shape: a
    /// book with NO members, a bulk Add over a pick holding a choice row. The
    /// free note lands, the book's assembly is no longer empty (the spread's
    /// first page fills from nothing), and the review must STAY OPEN with
    /// the choice row still picked — F-4's one-press retry. On the old rule
    /// the content change read as navigation and closed the review, the
    /// pick with it.
    @Test func aBulkAddWithALeftoverKeepsTheReviewOpenWithTheLeftoverPicked() async throws {
        ArrivalsReviewProbe.reset()
        try await withReviewBook(waiting: 0) { session, db, _, _, _ in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let rule = try #require(try RuleGrammar.encode(.tag(t.id)))
            let mine = try ops.createReading(
                name: "Mine", kind: .book, querySpec: rule, intakeSeating: .arrivals)
            try ops.setReadingOwned(mine.id, owned: true)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            try ops.addPostToReading(shared.id, to: other.id)
            let free = try ops.createPost(title: "free")
            _ = try ops.applyTag(t.id, toPost: shared.id)
            _ = try ops.applyTag(t.id, toPost: free.id)
            let readingID = mine.id

            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
            #expect(model.entries.isEmpty, "the walk's shape: a book with no members yet")
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await book(db, readingID), sections: [], deletedSections: [],
                assignments: [:]))
            structure.mode = .outline
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setReviewOpen(true)
            try await refresh(arrivals, db)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure, arrivals: arrivals))
            hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) { ArrivalsReviewProbe.drawn[readingID] != nil }

            arrivals.selectAll()
            await arrivals.addSelected(book: try await book(db, readingID), chaptered: false)
            // What the book's and the door's observations would deliver now.
            await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
            try await refresh(arrivals, db)
            #expect(model.entries.map(\.postID) == [free.id], "the free note landed")
            await settle(window, hosting, until: { false }, maxTurns: 12)

            let sharedRow = try #require(arrivals.door.rows.first { $0.postID == shared.id })
            #expect(arrivals.reviewOpen, "the review's own act is never navigation — it stays open")
            #expect(arrivals.selection.picked == [sharedRow.id], "the leftover stays picked: one press retries")
            #expect(ArrivalsReviewProbe.drawn[readingID]?.picked == [sharedRow.id])
        }
    }

    /// **W-2 (the leg-2 walk) — the row's shape by a stable width class.**
    /// Inline while the box, the text's floor and the arms fit side by side;
    /// else the arms wrap under the text. The rule reads the row's width and
    /// the arms' own width only — never the text's.
    @Test func aRowWrapsItsArmsUnderTheTextByAStableWidth() {
        let box: CGFloat = 20
        let arms: CGFloat = 266  // Copy In · Move In · Dismiss
        let threshold = box + ArrivalRowFit.spacing + ArrivalRowFit.textFloor + ArrivalRowFit.armsGap + arms
        #expect(!ArrivalRowFit.stacked(rowWidth: threshold, boxWidth: box, armsWidth: arms), "exactly fits: inline")
        #expect(ArrivalRowFit.stacked(rowWidth: threshold - 1, boxWidth: box, armsWidth: arms), "a point less: stacked")
        #expect(!ArrivalRowFit.stacked(rowWidth: 868, boxWidth: box, armsWidth: arms), "the full measure: inline")
        #expect(ArrivalRowFit.stacked(rowWidth: 400, boxWidth: box, armsWidth: arms), "a narrow pane: stacked")
        // Inline the text keeps what the arms leave; stacked it takes the row.
        #expect(ArrivalRowFit.textWidth(rowWidth: 868, boxWidth: box, armsWidth: arms, stacked: false)
                == 868 - box - ArrivalRowFit.spacing - ArrivalRowFit.armsGap - arms)
        #expect(ArrivalRowFit.textWidth(rowWidth: 400, boxWidth: box, armsWidth: arms, stacked: true)
                == 400 - box - ArrivalRowFit.spacing)
        // Stacked arms take the text's indent while it holds them, else the row's edge.
        #expect(ArrivalRowFit.stackedArmsIndented(rowWidth: 400, boxWidth: box, armsWidth: arms))
        #expect(!ArrivalRowFit.stackedArmsIndented(rowWidth: 290, boxWidth: box, armsWidth: arms))
    }

    /// **F-2 (the ladder's round 1; the B3+B4 walk's nit): the WHY gets the
    /// line's width first and the SINCE gives way first.** At a ~370-pt pane
    /// the walk saw "Ta…" beside a whole timestamp: the old line fixed the
    /// since's size and truncated the why. The rule keeps the why's words
    /// whole while the line holds them. Beside it, the since steps down whole
    /// → short → dropped and is never cut mid-word, and its whole fact rides
    /// the why's hover. With room, both show whole. Each threshold is pinned
    /// to the point.
    @Test func theWhyWinsTheLineAndTheSinceGivesWayFirst() throws {
        typealias Fit = ArrivalMetaFit
        let why: CGFloat = 92  // "Tagged #harbour"
        let dot: CGFloat = 4
        let since = (whole: CGFloat(168), short: CGFloat(122))  // "waiting since …" · "since …"
        let beside = why + 2 * Fit.gap + dot
        func plan(_ width: CGFloat?) -> Fit.Plan { Fit.plan(width: width, why: why, dot: dot, since: since) }

        // With room, or asked with no width at all: both whole.
        let roomy = plan(600)
        #expect(roomy == Fit.Plan(why: why, dot: dot, since: since.whole, form: .whole))
        #expect(plan(nil) == roomy)
        #expect(roomy.sinceOffset == beside && roomy.dotOffset == why + Fit.gap)
        #expect(plan(beside + since.whole) == roomy, "exactly fits: both whole")

        // A point less: the SINCE gives way (to its short form). The why keeps every point.
        let tighter = plan(beside + since.whole - 1)
        #expect(tighter == Fit.Plan(why: why, dot: dot, since: since.short, form: .short))
        #expect(plan(beside + since.short).form == .short, "the short form exactly fits")

        // A point less than that: the since drops whole (never "waiting si…"), the dot
        // with it. The why is still whole.
        let dropped = plan(beside + since.short - 1)
        #expect(dropped == Fit.Plan(why: why, dot: 0, since: 0, form: .dropped))
        #expect(dropped.width == why)

        // The why truncates ONLY when its own words outrun the line.
        #expect(plan(why) == dropped, "the why's own width: whole")
        #expect(plan(why - 1) == Fit.Plan(why: why - 1, dot: 0, since: 0, form: .dropped))
        #expect(plan(0) == Fit.Plan(why: 0, dot: 0, since: 0, form: .dropped))

        // The walk's line: the old layout left the why 20 pt beside the whole stamp.
        // Now the why keeps all 92 and the stamp gives way.
        let walked = plan(20 + 2 * Fit.gap + dot + since.whole)
        #expect(walked.why == why && walked.form == .dropped, "\(walked)")

        // Never wider than it was offered, at every width; the why gets its
        // share before the since gets anything.
        for width in stride(from: CGFloat(0), through: 400, by: 1) {
            let p = plan(width)
            #expect(p.width <= width, "\(width): \(p)")
            #expect(p.since == 0 || p.why == why, "\(width): the since drew while the why was cut")
        }

        // A since with no why beside it has nothing to give way to: whole, else
        // short (truncating only past that). It never drops.
        #expect(Fit.plan(width: 400, why: nil, dot: dot, since: since)
                == Fit.Plan(why: 0, dot: 0, since: since.whole, form: .whole))
        #expect(Fit.plan(width: 150, why: nil, dot: dot, since: since)
                == Fit.Plan(why: 0, dot: 0, since: since.short, form: .short))
        #expect(Fit.plan(width: 100, why: nil, dot: dot, since: since)
                == Fit.Plan(why: 0, dot: 0, since: 100, form: .short))
        // No readable stamp: the why alone.
        #expect(Fit.plan(width: 400, why: why, dot: dot, since: nil)
                == Fit.Plan(why: why, dot: 0, since: 0, form: nil))

        // The words (PROVISIONAL P-808-B3-8). The short form is the same stamp
        // without "waiting". The why's hover carries the since's whole fact,
        // so a dropped since is still one hover away.
        let now = Date(timeIntervalSince1970: 1_782_900_000)
        let then = now.addingTimeInterval(-3 * 86_400)
        let iso = DateFormatter.variorumISO8601.string(from: then)
        #expect(ArrivalsReviewCopy.sinceShort(iso, now: now) == "since " + TimeStampFace.relative(then, now: now))
        #expect(ArrivalsReviewCopy.since(iso, now: now) == "waiting " + (ArrivalsReviewCopy.sinceShort(iso, now: now) ?? ""))
        #expect(ArrivalsReviewCopy.sinceShort("not a stamp", now: now) == nil)
        let whole = try #require(ArrivalsReviewCopy.sinceHelp(iso))
        #expect(ArrivalsReviewCopy.whyHelp("Tagged #harbour", since: whole) == "Tagged #harbour\n" + whole)
        #expect(ArrivalsReviewCopy.whyHelp("Tagged #harbour", since: nil) == "Tagged #harbour",
                "no stamp: the why alone, byte for byte")
    }

    /// **W-2 + W-3 mounted (the walk's shape).** An owned book's bell for a
    /// membered note draws THREE arms (Copy In · Move In · Dismiss). At a
    /// narrow pane they sit whole INSIDE the list, under the text; grown back
    /// wide, the rows re-measure (the list's width is the rows' layout input)
    /// and the arms return to the trailing edge, beside the text.
    @Test func atANarrowPaneTheArmsWrapInsideAndGrowingBackReMeasures() async throws {
        ArrivalsLineProbe.reset()
        try await withReviewBook(waiting: 0) { session, db, _, _, _ in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let rule = try #require(try RuleGrammar.encode(.tag(t.id)))
            let mine = try ops.createReading(
                name: "Mine", kind: .book, querySpec: rule, intakeSeating: .arrivals)
            try ops.setReadingOwned(mine.id, owned: true)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "Notes from the harbour, a longer title")
            try ops.addPostToReading(shared.id, to: other.id)
            _ = try ops.applyTag(t.id, toPost: shared.id)
            let readingID = mine.id
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await book(db, readingID), sections: [], deletedSections: [],
                assignments: [:]))
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setReviewOpen(true)
            try await refresh(arrivals, db)
            let rowID = try #require(arrivals.door.rows.first?.id)

            let narrow: CGFloat = 420
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: narrow, height: 400),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookArrivalsList(model: arrivals, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: narrow, height: 400)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) {
                (ArrivalsLineProbe.drawn[readingID]?.listWidth ?? 0) == narrow
                    && ArrivalsLineProbe.drawn[readingID]?.arms[rowID] != nil
            }
            let tight = try #require(ArrivalsLineProbe.drawn[readingID])
            #expect(tight.rows[rowID] == ["Copy In", "Move In", ArrivalsCopy.dismissVerb])
            let tightArms = try #require(tight.arms[rowID])
            #expect(tightArms.minX >= 0 && tightArms.maxX <= narrow + 0.5,
                    "every arm whole inside the pane — none clipped, none off-screen: \(tightArms)")
            #expect(tightArms.minY > 30, "the arms wrapped UNDER the text: \(tightArms)")

            // W-3: the window grows back — the rows re-measure.
            let wide: CGFloat = 1100
            window.setContentSize(NSSize(width: wide, height: 400))
            hosting.frame = NSRect(x: 0, y: 0, width: wide, height: 400)
            await settle(window, hosting) {
                (ArrivalsLineProbe.drawn[readingID]?.listWidth ?? 0) == wide
                    && (ArrivalsLineProbe.drawn[readingID]?.arms[rowID]?.minY ?? 99) < 30
            }
            let roomy = try #require(ArrivalsLineProbe.drawn[readingID])
            #expect(roomy.listWidth == wide, "the rows' layout input followed the width")
            let roomyArms = try #require(roomy.arms[rowID])
            #expect(roomyArms.minY < 30, "inline again, beside the text: \(roomyArms)")
            #expect(abs(roomyArms.maxX - (wide - BookArrivalsList.rowInset)) < 1,
                    "at the row's trailing edge: \(roomyArms)")
        }
    }

    /// **W-4 (the rewalk) — the header and the bar by a stable width class.**
    /// One line while the leading group keeps its floor beside the door(s)
    /// whole; else two. The leading group yields toward its floor so the
    /// bar's receipt gets its ideal first, never below the floor.
    @Test func theHeaderAndTheBarWrapTheirDoorsByAStableWidth() {
        typealias Fit = ReviewChromeFit
        // The header: the title's floor beside "Add all · Dismiss all".
        let doors: CGFloat = 183
        let fits = Fit.titleFloor + Fit.gap + doors
        #expect(!Fit.stacked(width: fits, leadingFloor: Fit.titleFloor, trailingWidth: doors))
        #expect(Fit.stacked(width: fits - 1, leadingFloor: Fit.titleFloor, trailingWidth: doors),
                "a point less: the doors go under the title")
        #expect(Fit.stacked(width: 322, leadingFloor: Fit.titleFloor, trailingWidth: doors),
                "the rewalk's ~370-pt pane (322 inside the padding): two lines")
        #expect(!Fit.stacked(width: 852, leadingFloor: Fit.titleFloor, trailingWidth: doors))
        // The bar: the pick's whole group beside Done; the hint yields wholly.
        let pickGroup: CGFloat = 246
        let done: CGFloat = 66
        #expect(Fit.stacked(width: 322, leadingFloor: pickGroup, trailingWidth: done),
                "the rewalk's pane with a pick: Done takes a second line")
        #expect(!Fit.stacked(width: 322, leadingFloor: 0, trailingWidth: done),
                "the hint truncates; it never pushes Done off the line")
        // On one line the leading group yields to the receipt, down to its floor.
        #expect(Fit.inlineLeadingWidth(available: 400, leadingIdeal: 300, leadingFloor: 0, flexibleIdeal: nil) == 300)
        #expect(Fit.inlineLeadingWidth(available: 200, leadingIdeal: 300, leadingFloor: 0, flexibleIdeal: nil) == 200)
        #expect(Fit.inlineLeadingWidth(available: 400, leadingIdeal: 300, leadingFloor: 0, flexibleIdeal: 150)
                == 400 - Fit.gap - 150, "the hint gives the receipt its ideal")
        #expect(Fit.inlineLeadingWidth(available: 400, leadingIdeal: 246, leadingFloor: 246, flexibleIdeal: 300)
                == 246, "the pick's doors never yield below their whole width")
    }

    /// **W-4 mounted (the rewalk's shape).** The review at a ~370-pt pane with
    /// a pick: the header's Dismiss all and the bar's Done sit wholly inside
    /// the review — none clipped at its edge.
    @Test func atANarrowPaneTheHeaderAndBarDoorsStayWhole() async throws {
        ArrivalsReviewProbe.reset()
        try await withReviewBook(waiting: 5) { session, db, readingID, _, _ in
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await book(db, readingID), sections: [], deletedSections: [],
                assignments: [:]))
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setReviewOpen(true)
            try await refresh(arrivals, db)
            arrivals.selectAll()
            let narrow: CGFloat = 370
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: narrow, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookArrivalsReview(
                model: arrivals, structure: structure, onDone: {}))
            hosting.frame = NSRect(x: 0, y: 0, width: narrow, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) {
                let drawn = ArrivalsReviewProbe.drawn[readingID]
                return drawn?.frames["done"] != nil && drawn?.frames["dismissAll"] != nil
                    && (drawn?.doors.contains("Add 5") ?? false)
            }
            let review = try #require(ArrivalsReviewProbe.drawn[readingID])
            #expect(review.doors == ["Add all", "Dismiss all", "Add 5", "Dismiss 5", "Done"])
            let done = try #require(review.frames["done"])
            let dismissAll = try #require(review.frames["dismissAll"])
            #expect(done.minX >= 0 && done.maxX <= narrow + 0.5, "Done whole inside the review: \(done)")
            #expect(dismissAll.minX >= 0 && dismissAll.maxX <= narrow + 0.5,
                    "Dismiss all whole inside the review: \(dismissAll)")
        }
    }

    @Test func anEmptyReviewSaysNothingIsWaitingBesideDone() async throws {
        ArrivalsReviewProbe.reset()
        try await withReviewBook(waiting: 0) { session, db, readingID, _, _ in
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await book(db, readingID), sections: [], deletedSections: [],
                assignments: [:]))
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setReviewOpen(true)
            try await refresh(arrivals, db)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookArrivalsReview(
                model: arrivals, structure: structure, onDone: {}))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) { ArrivalsReviewProbe.drawn[readingID] != nil }
            let review = try #require(ArrivalsReviewProbe.drawn[readingID])
            #expect(review.empty && review.header == "Arrivals" && review.doors == ["Done"])
        }
    }

    /// The one home, said in source (the `ArrivalsDoorPlacementTests` form):
    /// the book composes the review ONCE, and the popover is gone.
    @Test func theReviewIsTheOneHomeAndThePopoverRetired() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        func code(_ file: String) throws -> String {
            try String(contentsOf: root.appending(path: "Variorum/Features/BookView/\(file)"), encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
                .joined(separator: "\n")
        }
        let bookView = try code("BookView.swift")
        #expect(bookView.components(separatedBy: "BookArrivalsReview(").count == 2,
                "the book composes the review area once")
        #expect(!(try code("BookArrivals.swift")).contains(".popover("), "the popover retired")
        // R2-2 (the ladder's round 2): `theWhyWinsTheLineAndTheSinceGivesWayFirst`
        // holds the rule; this holds that the row READS it. The why · since line
        // composes `ArrivalMetaLayout` with the since's short form, so the old
        // HStack (the since `.fixedSize()`, the why truncating) can't silently return.
        let arrivals = try code("BookArrivals.swift")
        #expect(arrivals.contains("ArrivalMetaLayout {") && arrivals.contains(".arrivalMetaRole(.sinceShort)"),
                "the row's why · since line is laid out by ArrivalMetaLayout (R2-2)")
    }
}
