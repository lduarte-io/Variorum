//
//  BookMintArrivalTests.swift
//  VariorumTests
//
//  VX-1039 (the VX-1036 run, batch 1 — N-1, N-2, N-3): the book's ONE mint
//  act's model half, as exact state transitions. A note a door makes ARRIVES:
//  focused at once, its landing parked until the entries hold it
//  (`BookViewModel.arrive`), let go by any later navigation, never released
//  by a delivery read before the write, and — born past the 300-note window —
//  the window widens to hold it. Plus the general doors' neighbour rule
//  (`BookNoteBox.mintNeighbour`, PROVISIONAL) and the chapter door's one
//  declaration (P-1). The hosted end-to-end is `BookMintLandingTests`.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1039 — a note made inside a book arrives: focused, landed once delivered, the window widened", .serialized)
struct BookMintArrivalTests {
    private func withBook<T>(
        members: Int,
        _ body: @MainActor (AppSession, AppDatabase, _ bookID: String, _ memberIDs: [String]) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        // The operations stamp through `\.date` and place through the
        // fractional index's `\.withRandomNumberGenerator`; both are provided
        // here the BookView neighbours' way (`withMintLandingBook`) — a
        // one-second ticking clock and a seeded generator — so the host's
        // test context never meets an unimplemented dependency.
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1039))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "the allotment year", kind: .book)
            var ids: [String] = []
            for i in 0..<members {
                ids.append(try session.operations.newPostInReading(book.id, title: "note \(i)").id)
            }
            return try await body(session, db, book.id, ids)
        }
    }

    private func entries(
        _ db: AppDatabase, _ bookID: String, limit: Int? = nil
    ) async throws -> [Queries.ReadingEntry] {
        try await db.read { try Queries.assembleReading($0, readingID: bookID, limit: limit) }
    }

    // MARK: - N-1 — the arrival

    @Test func aNoteMadeHereIsFocusedAtOnceAndLandedWhenItsEntriesArrive() async throws {
        try await withBook(members: 3) { session, db, bookID, _ in
            let model = BookViewModel(session: session, readingID: bookID)
            await model.adopt(try await entries(db, bookID))
            let minted = try session.operations.newPostInReading(bookID, title: "new").id

            await model.arrive(at: minted)
            #expect(model.focusedPostID == minted, "focused at once — the keyboard leaves the note she was in")
            #expect(model.pendingReveal == nil, "no landing is asked for a note the entries do not hold yet")
            #expect(model.pendingArrival == minted, "the landing waits for the entries")

            await model.adopt(try await entries(db, bookID))
            #expect(model.pendingReveal == minted, "the entries hold it: its landing is asked for now")
            #expect(model.pendingArrival == nil)
            #expect(model.focusedPostID == minted)
        }
    }

    @Test func aNoteAlreadyDeliveredLandsAtOnce() async throws {
        try await withBook(members: 2) { session, db, bookID, _ in
            let model = BookViewModel(session: session, readingID: bookID)
            let minted = try session.operations.newPostInReading(bookID, title: "new").id
            await model.adopt(try await entries(db, bookID))   // the delivery won the race
            await model.arrive(at: minted)
            #expect(model.pendingReveal == minted && model.pendingArrival == nil)
        }
    }

    /// A delivery READ BEFORE THE WRITE can land after the mint's turn: it
    /// lacks the new note, and must not release the arrival's focus (the old
    /// `releaseFocusIfItLeftTheBook` would have).
    @Test func aDeliveryFromBeforeTheWriteNeverReleasesTheArrival() async throws {
        try await withBook(members: 3) { session, db, bookID, _ in
            let model = BookViewModel(session: session, readingID: bookID)
            let before = try await entries(db, bookID)
            await model.adopt(before)
            let minted = try session.operations.newPostInReading(bookID, title: "new").id
            await model.arrive(at: minted)
            await model.adopt(before)   // the stale delivery
            #expect(model.focusedPostID == minted, "still focused")
            #expect(model.pendingArrival == minted, "still waiting")
            await model.adopt(try await entries(db, bookID))
            #expect(model.pendingReveal == minted)
        }
    }

    @Test func aLaterNavigationLetsAnArrivalGo() async throws {
        try await withBook(members: 3) { session, db, bookID, ids in
            for later in ["focus elsewhere", "click out", "a reveal", "a chapter landing", "collapse all", "collapse it"] {
                let model = BookViewModel(session: session, readingID: bookID)
                await model.adopt(try await entries(db, bookID))
                let minted = try session.operations.newPostInReading(bookID, title: later).id
                await model.arrive(at: minted)
                switch later {
                case "focus elsewhere": model.focus(ids[0])
                case "click out": model.focus(nil)
                case "a reveal": model.requestReveal(ids[1])
                case "a chapter landing": model.requestChapterReveal("some-chapter")
                case "collapse all": model.collapseAll()
                default: model.collapse(minted)
                }
                #expect(model.pendingArrival == nil, "\(later): the arrival is let go")
                await model.adopt(try await entries(db, bookID))
                #expect(model.pendingReveal != minted, "\(later): a slow delivery never yanks the page to it")
            }
        }
    }

    // MARK: - N-3 — born past the window

    @Test func theWindowGrowsByWholeWindowsToHoldAnIndex() {
        let w = BookViewModel.entryWindow
        #expect(BookViewModel.window(holding: 0, current: w) == w)
        #expect(BookViewModel.window(holding: w - 1, current: w) == w, "the last place in the window: held")
        #expect(BookViewModel.window(holding: w, current: w) == 2 * w, "one past it: one more window")
        #expect(BookViewModel.window(holding: 2 * w + 5, current: w) == 3 * w)
        #expect(BookViewModel.window(holding: 10, current: 2 * w) == 2 * w, "never narrows")
    }

    @Test func aNoteBornPastTheWindowWidensItToHoldIt() async throws {
        let w = BookViewModel.entryWindow
        try await withBook(members: w + 1) { session, db, bookID, _ in
            let model = BookViewModel(session: session, readingID: bookID)
            // The book's own observation reads window + 1 (the truncation probe).
            await model.adopt(try await entries(db, bookID, limit: model.window + 1))
            #expect(model.truncated && model.window == w)
            let minted = try session.operations.newPostInReading(bookID, title: "born at the end").id

            await model.arrive(at: minted)
            #expect(model.window == 2 * w, "the window widened by a whole window to hold the new note")
            #expect(model.observationKey.window == 2 * w, "so the book's observation restarts over it")
            await model.adopt(try await entries(db, bookID, limit: model.window + 1))
            #expect(model.entries.contains { $0.postID == minted })
            #expect(model.pendingReveal == minted, "and it lands")
        }
    }

    @Test func aNoteTheFilterHidesIsNeitherWaitedForNorKeptFocused() async throws {
        try await withBook(members: 2) { session, db, bookID, ids in
            let poems = try session.operations.createTag(name: "poems")
            _ = try session.operations.applyTag(poems.id, toPost: ids[0])
            let model = BookViewModel(session: session, readingID: bookID)
            model.viewFilter = .tag(poems.id)   // the Index's in-book filter
            await model.adopt(try await db.read {
                try Queries.assembleReading($0, readingID: bookID, filter: .tag(poems.id))
            })
            let minted = try session.operations.newPostInReading(bookID, title: "untagged").id
            await model.arrive(at: minted)
            #expect(model.pendingArrival == nil, "this view will never show it: nothing waits")
            #expect(model.focusedPostID == nil, "and nothing hidden is held focused")
        }
    }

    // MARK: - N-2 — the general doors' neighbour (PROVISIONAL), and the chapter door

    @Test func theNoteSheIsOnIsTheLiveThenTheSelectedThenTheViewedNote() {
        #expect(BookNoteBox.mintNeighbour(live: "l", selected: "s", viewed: "v") == "l")
        #expect(BookNoteBox.mintNeighbour(live: nil, selected: "s", viewed: "v") == "s")
        #expect(BookNoteBox.mintNeighbour(live: nil, selected: nil, viewed: "v") == "v")
        #expect(BookNoteBox.mintNeighbour(live: nil, selected: nil, viewed: nil) == nil, "with none, the end")
    }

    @Test func theChapterDoorIsDeclaredOnceAndRenderedByTheBook() {
        let door = CapabilityRegistry.capability(.newNoteInChapter)
        #expect(door.verb == "New Note in This Chapter")
        #expect(door.doors == [.surface])
        #expect(door.shortcutLabel == nil)
        #expect(!door.unavailableNote.isEmpty, "its refusal copy is declared")
        #expect(CapabilityRegistry.all.filter { $0.id == .newNoteInChapter }.count == 1)
        #expect(BookView.surfaceCapabilities.contains(.newNoteInChapter), "the outline's chapter heading renders it")
    }
}
