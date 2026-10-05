//
//  BookArrivalsTests.swift
//  VariorumTests
//
//  13i-b U2 — THE ARRIVALS FACE (the 13i-b plan §3 + §5's U2 row; the
//  sitting record §4, §24, §25 lesson 4). What these hold:
//
//  · the WORDS, pure (`ArrivalsCopy` — the line, the stamp through the one
//    stamp vocabulary, the receipts, the refusals that name their roads);
//  · the line MOUNTED in a real hosted book view: ABSENT with nothing waiting
//    (her clutter mandate — the common case draws nothing), PRESENT as one
//    line with N waiting on Index AND Book, absent on Outline and Read (the
//    ruled surfaces only), expanding inline to the rows with both judgment
//    doors on each, and folding shut when the last one is judged;
//  · the two ACTS against a real store: Add seats the note at the END,
//    unsectioned (and the book's assembly carries it there), Dismiss
//    tombstones the row, and every refusal — the capacity one first — is the
//    operation's own, spoken on the one status seam as a refusal;
//  · the registry: the line is the two acts' ONE renderer (the surface walk
//    itself is `CapabilityRegistryTests`').
//
//  Mounted pins read `ArrivalsLineProbe` (DEBUG — the `TrayRowDoorProbe`
//  pattern): a hosted SwiftUI tree exposes no accessibility children here,
//  so "what did the line draw" is recorded by the line itself.
//
//  17y B3 item (h) — JUSTIFIED EDITS THROUGHOUT THE MOUNTED HALF (R-17y-1 /
//  R-17y-2, her pre-answered rulings): the "N at the door" line LEFT the
//  book's content; the door is the masthead's ICON beside the gear (CALM when
//  nothing waits, PRESENCE when something does), recorded by
//  `ArrivalsDoorProbe`, and its popover hosts the rows (`BookArrivalsList`,
//  recorded by `ArrivalsLineProbe`'s rows — mounted directly here, since a
//  popover does not render under the test host). Each pin keeps its subject:
//  absent-when-empty became calm-when-empty; "says how many" holds on the
//  door, now in EVERY mode; the rows still carry both judgment doors; the
//  last judgment still returns the face to its quiet state.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A living book on `#inbox` whose new matches WAIT at the door (the join
/// dial at "wait at Arrivals"), `members` seated by hand (in one chapter when
/// `chaptered`), and `waiting` notes rung to the door by real intake.
@MainActor
private func withArrivalsBook<T>(
    members: Int, waiting: Int, maxPosts: Int? = nil, chaptered: Bool = false,
    seating: IntakeSeating = .arrivals,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String,
        _ memberIDs: [String], _ waitingIDs: [String]
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let ops = session.operations
        let inbox = try ops.createTag(name: "inbox")
        let rule = try #require(try RuleGrammar.encode(.tag(inbox.id)))
        let book = try ops.createReading(
            name: "the living book", kind: .book, querySpec: rule,
            maxPosts: maxPosts, intakeSeating: seating)
        var memberIDs: [String] = []
        for m in 0..<members {
            let post = try ops.createPost(title: "member \(m)")
            _ = try ops.newBlock(in: post.id, text: "Member \(m)'s prose, a sentence long.")
            try ops.addPostToReading(post.id, to: book.id)
            memberIDs.append(post.id)
        }
        if chaptered {
            let chapter = try ops.createSection(in: book.id, name: "the first chapter")
            for id in memberIDs {
                try ops.assignPostToSection(id, in: book.id, section: chapter.id)
            }
        }
        var waitingIDs: [String] = []
        for w in 0..<waiting {
            let post = try ops.createPost(title: "waiting \(w)")
            _ = try ops.newBlock(in: post.id, text: "Waiting note \(w), at the door.")
            _ = try ops.applyTag(inbox.id, toPost: post.id)
            waitingIDs.append(post.id)
        }
        return try await body(session, db, book.id, memberIDs, waitingIDs)
    }
}

@MainActor
@Suite("13i-b U2 — the Arrivals face (the line, its doors, its words)", .serialized)
struct BookArrivalsTests {
    // MARK: - Hosting

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool = { false }, maxTurns: Int = 8
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// The book view in `mode`, its three models loaded by hand (hosted
    /// `.task` callbacks don't fire under the test host).
    private func mounted(
        session: AppSession, db: AppDatabase, readingID: String,
        mode: BookStructureModel.ViewMode
    ) async throws -> (
        window: NSWindow, hosting: NSHostingView<BookView>,
        arrivals: BookArrivalsModel, structure: BookStructureModel, model: BookViewModel
    ) {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        structure.mode = mode
        let arrivals = BookArrivalsModel(session: session, readingID: readingID)
        try await refreshDoor(arrivals, db)
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure, arrivals: arrivals))
        hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting, arrivals, structure, model)
    }

    /// What the observation would deliver now, adopted by hand.
    private func refreshDoor(_ arrivals: BookArrivalsModel, _ db: AppDatabase) async throws {
        let readingID = arrivals.readingID
        let limit = arrivals.listingLimit
        arrivals.adopt(try await db.read {
            try Queries.bookArrivals($0, readingID: readingID, limit: limit)
        })
    }

    private func pairRow(_ db: AppDatabase, _ id: String) async throws -> ReadingPost? {
        try await db.read { try ReadingPost.fetchOne($0, key: id) }
    }

    // MARK: - The words (pure)

    @Test func theWordsLiveInOneHomeAndSayTheTruth() throws {
        // 17y B3 (h): the ONE word, and the door's count (calm = none).
        #expect(ArrivalsCopy.word == "Arrivals")
        #expect(ArrivalsCopy.doorCount(0) == nil, "calm: no count")
        #expect(ArrivalsCopy.doorCount(12) == "12")
        #expect(ArrivalsCopy.header(count: 3) == "Arrivals \u{00B7} 3 waiting")
        #expect(ArrivalsCopy.doorHelp(count: 0).hasPrefix("Arrivals"))
        #expect(ArrivalsCopy.more(4) == "and 4 more waiting")

        // When it arrived — the app's ONE stamp vocabulary, with this row's
        // own verb; an unreadable stamp says nothing rather than a lie.
        let now = Date(timeIntervalSince1970: 1_782_900_000)
        let then = now.addingTimeInterval(-3 * 86_400)
        let iso = DateFormatter.variorumISO8601.string(from: then)
        #expect(ArrivalsCopy.arrived(iso, now: now)
                == "arrived " + TimeStampFace.relative(then, now: now))
        #expect(ArrivalsCopy.arrived("not a stamp", now: now) == nil)

        // The receipts say where Add landed — the END (§4), outside the
        // chapters when there are chapters — and what Dismiss did. (13i-d U6
        // (f), a JUSTIFIED EDIT: the plan's item 10 RULED the dismiss receipt
        // to teach the road back, so "nothing more" became the ruled sentence.)
        #expect(ArrivalsCopy.added("Ode", chaptered: false)
                == "\u{201C}Ode\u{201D} added at the end of the book.")
        // 17y B3 item (i) — A JUSTIFIED EDIT (R-17y-4): the chapterless
        // place speaks the headers' one word; the subject (the receipt says
        // WHERE Add landed) holds.
        #expect(ArrivalsCopy.added("Ode", chaptered: true)
                == "\u{201C}Ode\u{201D} added at the end of the book, unfiled.")
        #expect(ArrivalsCopy.dismissed("Ode")
                == "Dismissed \u{201C}Ode\u{201D} \u{2014} it won\u{2019}t come back on its own; "
                    + "add it by hand any time.")

        // The refusals name their ROAD (P-2), never a raw enum.
        let full = ArrivalsCopy.refusal(
            for: OperationError.readingAtCapacity(id: "b"), book: "Poems", cap: 3)
        #expect(full == "\u{201C}Poems\u{201D} is full \u{2014} its cap is 3 notes. "
                + "Raise the note cap in the book\u{2019}s settings (the gear), then add it.")
        let capless = ArrivalsCopy.refusal(
            for: OperationError.readingAtCapacity(id: "b"), book: nil, cap: nil)
        #expect(capless.hasPrefix("This book is at its note cap."))
        let finished = ArrivalsCopy.refusal(
            for: OperationError.lockedReading(id: "b"), book: "Poems", cap: nil)
        #expect(finished.contains("is finished"))
        #expect(finished.contains("Reopen it in the book\u{2019}s settings"))
        let judged = ArrivalsCopy.refusal(
            for: OperationError.arrivalNotFound(id: "r"), book: "Poems", cap: nil)
        #expect(judged.contains("already judged"))
        for error in [
            OperationError.readingAtCapacity(id: "b"), .lockedReading(id: "b"),
            .arrivalNotFound(id: "r"), .containerNotFound(id: "n"),
            .readingNotFound(id: "b"), .wrongReadingKind(id: "b", expected: .book),
        ] {
            let words = ArrivalsCopy.refusal(for: error, book: "Poems", cap: 3)
            #expect(!words.contains("OperationError") && !words.contains("id:")
                    && !words.hasPrefix("Refused") && !words.hasPrefix("The operation"),
                    "a readable sentence, never the enum: \(words)")
        }

        // Whether the line shows is ONE value (§23's composition point).
        #expect(!ArrivalsLineFace.isShown(.none))
        let door = Queries.BookArrivals(
            count: 5, rows: [Queries.BookArrival(
                id: "r", postID: "p", title: "t", arrivedAt: iso)])
        #expect(ArrivalsLineFace.isShown(door))
        #expect(ArrivalsLineFace.hidden(door) == 4)
    }

    // MARK: - The door, mounted (17y B3 (h) — the masthead icon)

    /// The rows, mounted ON THEIR OWN (they are the door's popover content;
    /// a popover does not render under the test host).
    private func mountedList(
        session: AppSession, arrivals: BookArrivalsModel, structure: BookStructureModel
    ) -> (window: NSWindow, hosting: NSView) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 640, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: BookArrivalsList(model: arrivals, structure: structure))
        hosting.frame = NSRect(x: 0, y: 0, width: 640, height: 400)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    @Test func theDoorIsCalmWhenNothingWaits() async throws {
        ArrivalsLineProbe.reset()
        ArrivalsDoorProbe.reset()
        try await withArrivalsBook(members: 3, waiting: 0) { session, db, readingID, _, _ in
            for mode: BookStructureModel.ViewMode in [.index, .spread] {
                let hosted = try await mounted(
                    session: session, db: db, readingID: readingID, mode: mode)
                defer {
                    hosted.window.orderOut(nil)
                    hosted.window.close()
                }
                await settle(hosted.window, hosted.hosting) {
                    ArrivalsDoorProbe.drawn[readingID] != nil
                }
                #expect(hosted.arrivals.door == .none)
                let door = try #require(ArrivalsDoorProbe.drawn[readingID],
                                        "\(mode): the door is drawn — calm, but there")
                #expect(door.count == 0 && door.presence == false, "\(mode): CALM — no count, no accent")
                #expect(ArrivalsLineProbe.drawn[readingID] == nil,
                        "\(mode): no row draws anywhere — no line atop the content")
            }
        }
    }

    @Test func theDoorSaysHowManyWaitInEveryMode() async throws {
        ArrivalsLineProbe.reset()
        ArrivalsDoorProbe.reset()
        try await withArrivalsBook(members: 2, waiting: 3) { session, db, readingID, _, _ in
            let hosted = try await mounted(
                session: session, db: db, readingID: readingID, mode: .index)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            // The masthead rides every mode (Index's column carries it; the
            // navigator carries it beside the others) — Read included now:
            // the door is the book's chrome, never a seat on the page.
            for mode: BookStructureModel.ViewMode in [.index, .spread, .outline, .read] {
                hosted.structure.mode = mode
                await settle(hosted.window, hosted.hosting, until: {
                    ArrivalsDoorProbe.drawn[readingID]?.count == 3
                }, maxTurns: 12)
                let door = try #require(ArrivalsDoorProbe.drawn[readingID], "\(mode)")
                #expect(door.count == 3 && door.presence, "\(mode): PRESENCE — the count, the accent")
                #expect(door.open == false, "\(mode): closed until she opens it")
                #expect(ArrivalsLineProbe.drawn[readingID] == nil,
                        "\(mode): no row draws until the door opens — nothing atop the content")
            }
        }
    }

    @Test func theDoorsRowsCarryBothJudgmentDoors() async throws {
        ArrivalsLineProbe.reset()
        try await withArrivalsBook(members: 1, waiting: 2) { session, db, readingID, _, waitingIDs in
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: readingID) },
                sections: [], deletedSections: [], assignments: [:]))
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.setDoorOpen(true)
            #expect(arrivals.listingLimit == BookArrivalsModel.window,
                    "opening the door asks the observation for the rows")
            try await refreshDoor(arrivals, db)
            #expect(arrivals.door.rows.map(\.postID) == waitingIDs,
                    "the waiting notes, oldest arrival first")
            let hosted = mountedList(session: session, arrivals: arrivals, structure: structure)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) {
                ArrivalsLineProbe.drawn[readingID]?.rows.count == 2
            }
            let drawn = try #require(ArrivalsLineProbe.drawn[readingID])
            #expect(Set(drawn.rows.keys) == Set(arrivals.door.rows.map(\.id)),
                    "one row per waiting ARRIVAL ROW")
            for verbs in drawn.rows.values {
                #expect(verbs == [ArrivalsCopy.addVerb, ArrivalsCopy.dismissVerb],
                        "each row carries both judgment doors")
            }
            // Closing the door stops the listing (the count alone again).
            arrivals.setDoorOpen(false)
            #expect(arrivals.listingLimit == 0)
        }
    }

    // MARK: - The acts

    @Test func addSeatsTheNoteAtTheEndUnsectionedAndTheBookCarriesIt() async throws {
        try await withArrivalsBook(members: 2, waiting: 2, chaptered: true) {
            session, db, readingID, memberIDs, waitingIDs in
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.toggle()  // a no-op while the door reads empty…
            try await refreshDoor(arrivals, db)
            arrivals.toggle()  // …and opens once something waits
            try await refreshDoor(arrivals, db)
            let first = try #require(arrivals.door.rows.first)
            #expect(first.postID == waitingIDs[0])
            let book = try await db.read { try Queries.reading($0, id: readingID) }

            await arrivals.seat(first, book: book, chaptered: true)

            // The SAME row, now a member — at the END, unsectioned (§4).
            let row = try #require(try await pairRow(db, first.id))
            #expect(row.status == .member)
            #expect(row.deletedAt == nil)
            #expect(row.sectionId == nil, "unsectioned — the bin that renders last")
            let positions = try await db.read { db in
                try String.fetchAll(
                    db, sql: """
                        SELECT position FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                          AND id <> ?
                        """,
                    arguments: [readingID, first.id])
            }
            #expect(positions.allSatisfy { $0 < row.position }, "at the END")
            // The book carries it there: the assembly ends with it, after the
            // chapter's members.
            let assembled = try await db.read {
                try Queries.assembleReading($0, readingID: readingID).map(\.postID)
            }
            #expect(assembled == memberIDs + [first.postID])
            // The door answers one fewer.
            try await refreshDoor(arrivals, db)
            #expect(arrivals.door.count == 1)
            #expect(arrivals.door.rows.map(\.postID) == [waitingIDs[1]])
            // A RECEIPT on the seam, naming where it landed.
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text
                    == ArrivalsCopy.added(first.title, chaptered: true))
        }
    }

    @Test func dismissTombstonesTheArrivalAndSpeaksAReceipt() async throws {
        try await withArrivalsBook(members: 1, waiting: 1) { session, db, readingID, memberIDs, _ in
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            try await refreshDoor(arrivals, db)
            arrivals.toggle()
            try await refreshDoor(arrivals, db)
            let waiting = try #require(arrivals.door.rows.first)
            let book = try await db.read { try Queries.reading($0, id: readingID) }

            await arrivals.dismiss(waiting, book: book)

            let row = try #require(try await pairRow(db, waiting.id))
            #expect(row.deletedAt != nil, "the decision record — a tombstoned arrival row")
            #expect(row.status == .arrival, "never seated on the way out")
            let assembled = try await db.read {
                try Queries.assembleReading($0, readingID: readingID).map(\.postID)
            }
            #expect(assembled == memberIDs, "dismissing never touches membership")
            try await refreshDoor(arrivals, db)
            #expect(arrivals.door == .none)
            #expect(arrivals.expanded == false, "the emptied door folds shut")
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text == ArrivalsCopy.dismissed(waiting.title))
        }
    }

    /// The plan §5's walk shape, headless: at capacity intake WAITS at the
    /// door even under the quiet dial, and Add speaks the operation's own
    /// capacity refusal — on the seam, as a refusal (always shown) — and
    /// leaves the bell ringing.
    @Test func theCapacityRefusalSpeaksOnTheSeamAndTheBellKeepsRinging() async throws {
        try await withArrivalsBook(members: 2, waiting: 1, maxPosts: 2, seating: .auto) {
            session, db, readingID, memberIDs, waitingIDs in
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            try await refreshDoor(arrivals, db)
            #expect(arrivals.door.count == 1, "at capacity, intake waits at the door")
            arrivals.toggle()
            try await refreshDoor(arrivals, db)
            let waiting = try #require(arrivals.door.rows.first)
            #expect(waiting.postID == waitingIDs[0])
            let book = try await db.read { try Queries.reading($0, id: readingID) }

            await arrivals.seat(waiting, book: book, chaptered: false)

            #expect(session.status.current?.kind == .refusal, "a refusal is always the toast")
            #expect(session.status.current?.text == ArrivalsCopy.refusal(
                for: OperationError.readingAtCapacity(id: readingID),
                book: "the living book", cap: 2))
            let row = try #require(try await pairRow(db, waiting.id))
            #expect(row.status == .arrival && row.deletedAt == nil, "the bell keeps ringing")
            let assembled = try await db.read {
                try Queries.assembleReading($0, readingID: readingID).map(\.postID)
            }
            #expect(assembled == memberIDs)
            #expect(arrivals.judging.isEmpty, "the row's doors come back after the refusal")
        }
    }

    @Test func aRowAlreadyJudgedSaysSoHonestly() async throws {
        try await withArrivalsBook(members: 0, waiting: 1) { session, db, readingID, _, _ in
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            try await refreshDoor(arrivals, db)
            arrivals.toggle()
            try await refreshDoor(arrivals, db)
            let waiting = try #require(arrivals.door.rows.first)
            let book = try await db.read { try Queries.reading($0, id: readingID) }
            await arrivals.seat(waiting, book: book, chaptered: false)
            #expect(session.status.spoken?.kind == .receipt)
            // A stale row (another window judged it; the observation has not
            // caught up) — the second press is the op's own refusal, worded.
            await arrivals.dismiss(waiting, book: book)
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text == ArrivalsCopy.refusal(
                for: OperationError.arrivalNotFound(id: waiting.id), book: book?.name, cap: nil))
            let row = try #require(try await pairRow(db, waiting.id))
            #expect(row.status == .member && row.deletedAt == nil,
                    "the refused dismissal touched nothing")
        }
    }

    @Test func whenTheLastArrivalIsJudgedTheDoorGoesCalm() async throws {
        ArrivalsDoorProbe.reset()
        try await withArrivalsBook(members: 1, waiting: 1) { session, db, readingID, _, _ in
            let hosted = try await mounted(
                session: session, db: db, readingID: readingID, mode: .spread)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            hosted.arrivals.setDoorOpen(true)
            try await refreshDoor(hosted.arrivals, db)
            await settle(hosted.window, hosted.hosting) {
                ArrivalsDoorProbe.drawn[readingID]?.count == 1
            }
            // The door WAS present — so "calm" below is the judgment's doing.
            #expect(ArrivalsDoorProbe.drawn[readingID]?.presence == true)
            let waiting = try #require(hosted.arrivals.door.rows.first)
            await hosted.arrivals.seat(
                waiting, book: hosted.structure.reading, chaptered: false)
            try await refreshDoor(hosted.arrivals, db)
            await hosted.model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            await settle(hosted.window, hosted.hosting) {
                ArrivalsDoorProbe.drawn[readingID]?.presence == false
            }
            let door = try #require(ArrivalsDoorProbe.drawn[readingID])
            #expect(door.count == 0 && door.presence == false,
                    "nothing waits any more — the door is calm again, never gone")
            #expect(hosted.model.entries.last?.postID == waiting.postID)
        }
    }

    // MARK: - The registry

    @Test func theRowsAreTheActsOneRendererAndTheyAreDeclaredAsDrawn() {
        // 13i-c U4 (an honest edit — the subject is unchanged: every door the
        // line draws is declared as drawn): the plan's §4 row 19 gave the line
        // the two OWNERSHIP arms, Copy In and Move In, beside Add and Dismiss.
        #expect(BookArrivalsList.surfaceCapabilities
                == [.seatArrival, .dismissArrival, .copyIn, .moveIn])
        for id in BookArrivalsList.surfaceCapabilities {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.surface], "\(id): an inline door, no key, no palette row")
            #expect(capability.scope == .book)
            #expect(capability.shortcutLabel == nil)
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext()) == .act)
        }
        // The verbs the rows draw ARE the declared verbs.
        #expect(CapabilityRegistry.capability(.seatArrival).verb == ArrivalsCopy.addVerb)
        #expect(CapabilityRegistry.capability(.dismissArrival).verb == ArrivalsCopy.dismissVerb)
    }
}
