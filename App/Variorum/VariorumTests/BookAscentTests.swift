//
//  BookAscentTests.swift
//  VariorumTests
//
//  Phase 13f, batch 5 — the books-ascent family's pins: W21 (the mode
//  click-over carries your place), W20 (the ascent door + the one context
//  bar), W22 (the first-edit note).
//
//  Her round-8 opening named the finding these three answer, verbatim:
//  *"even if you navigated there some other way, there's gotta be a way from
//  a post/note to see what books it is present in and see it in the full
//  context of any of those books. I think the reason that it's been hard to
//  use post / notes is because there isn't a natural way to step back up
//  into the book."*
//
//  Everything that DECIDES anything is pure or model-level and is pinned
//  here: which post a mode is at, what a mode switch parks, who consumes it,
//  the chooser's order, the bar's presence, the ascent's broadcast, the
//  shell's routing of it, and the note's two conditions.
//
//  What is deliberately NOT claimed (the batch's honesty rule; batch 1
//  measured that this host cannot drive SwiftUI's hosted scroll/drag paths):
//  that `ScrollViewProxy.scrollTo` visibly lands in Outline or the reading
//  flow, and how the bar LOOKS folded. Those are on the batch record's
//  visual-verification-only list.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - W21: which post is a mode AT (the pure rule)

@Suite("The book's place (13f W21)")
struct BookAnchorTests {
    private func place(
        focused: String? = nil, spread: [String] = [], paged: String? = nil,
        standing: String? = nil
    ) -> BookAnchor.Place {
        BookAnchor.Place(
            focusedPostID: focused, spreadPostIDs: spread,
            pagedPostID: paged, standingPostID: standing)
    }

    /// THE TABLE. One rule per surface, each reading a fact that surface
    /// already holds — and every arm falling back to the standing anchor,
    /// because a carry that lands nowhere is indistinguishable from a carry
    /// that never happened.
    @Test func eachModeAnswersWithWhatItAlreadyKnows() {
        // Outline: the focused post is the place.
        #expect(BookAnchor.currentPost(
            mode: .outline, readForm: .flow,
            place: place(focused: "a", spread: ["b"], paged: "c", standing: "d")) == "a")
        #expect(BookAnchor.currentPost(
            mode: .outline, readForm: .flow, place: place(standing: "d")) == "d",
                "nothing focused ⇒ the standing anchor, never nil")

        // Book: the spread's LEFT page — unless the focused post is ON it.
        #expect(BookAnchor.currentPost(
            mode: .spread, readForm: .flow,
            place: place(focused: "a", spread: ["b", "c"], standing: "d")) == "b",
                "a focus that is not on the spread does not speak for the spread")
        #expect(BookAnchor.currentPost(
            mode: .spread, readForm: .flow,
            place: place(focused: "c", spread: ["b", "c"], standing: "d")) == "c",
                "the page under her hands keeps its claim")
        #expect(BookAnchor.currentPost(
            mode: .spread, readForm: .flow, place: place(standing: "d")) == "d")

        // Read ▸ Pages: the reader's own address.
        #expect(BookAnchor.currentPost(
            mode: .read, readForm: .pages,
            place: place(focused: "a", spread: ["b"], paged: "c", standing: "d")) == "c")
        #expect(BookAnchor.currentPost(
            mode: .read, readForm: .pages, place: place(focused: "a", standing: "d")) == "d",
                "no address yet ⇒ the standing anchor, not the focus of another mode")

        // Read ▸ Scroll: the one surface that tracks nothing.
        #expect(BookAnchor.currentPost(
            mode: .read, readForm: .flow,
            place: place(focused: "a", spread: ["b"], paged: "c", standing: "d")) == "d",
                "the flow's place is where she ARRIVED — recorded, not implied")
        #expect(BookAnchor.currentPost(
            mode: .read, readForm: .flow, place: place(focused: "a")) == nil,
                "and with nothing carried yet it honestly has no place at all")
    }
}

// MARK: - W21: the carry, at the model

@MainActor
@Suite("The mode click-over carries your place (13f W21)")
struct BookCarryTests {
    private func model(entries: [String]) -> BookViewModel {
        let db = try! AppDatabase.inMemory()
        let session = AppSession(database: db)
        let model = BookViewModel(session: session, readingID: "book")
        model.adopt(entries.map {
            Queries.ReadingEntry(postID: $0, title: nil, entryDate: nil, sectionPath: nil)
        })
        return model
    }

    /// Leaving OUTLINE carries the focused post.
    @Test func leavingOutlineCarriesTheFocusedPost() {
        let model = model(entries: ["p0", "p1", "p2"])
        model.focus("p2")
        model.carryPlace(from: .outline, readForm: .flow)
        #expect(model.pendingReveal == "p2")
        #expect(model.standingAnchorPostID == "p2")
    }

    /// Leaving BOOK carries the spread's left page — NOT the focus, which
    /// may be a post the spread is not showing. (Revert W21-A's arm.)
    @Test func leavingTheSpreadCarriesThePageOnScreen() {
        let model = model(entries: ["p0", "p1", "p2", "p3"])
        model.focus("p0")          // an outline focus from earlier
        model.openSpread(leftIndex: 2)  // …and the spread moved away from it
        #expect(model.focusedPostID == nil, "flipping released the ring (the standing rule)")
        model.carryPlace(from: .spread, readForm: .flow)
        #expect(model.pendingReveal == "p2", "the LEFT page, which is what she is looking at")
    }

    /// Leaving READ ▸ PAGES carries the reader's reported address. (Revert
    /// W21-A's second arm.)
    @Test func leavingPagedReadCarriesTheReportedAddress() {
        let model = model(entries: ["p0", "p1", "p2"])
        model.focus("p0")
        model.notePagedAnchor("p1")
        model.carryPlace(from: .read, readForm: .pages)
        #expect(model.pendingReveal == "p1")
    }

    /// Leaving READ ▸ SCROLL carries where she ARRIVED — the recorded gap,
    /// pinned as behaviour so it can never become a silent surprise.
    @Test func leavingTheReadingFlowCarriesWhereSheArrived() {
        let model = model(entries: ["p0", "p1", "p2"])
        model.focus("p2")
        model.carryPlace(from: .outline, readForm: .flow)   // outline → read
        model.consumeReveal()                               // the flow landed
        model.carryPlace(from: .read, readForm: .flow)      // read → book
        #expect(model.pendingReveal == "p2",
                "the flow tracks no scroll position, so the arrival is the place")
    }

    /// A book with no place at all carries NOTHING — and does not wipe the
    /// standing anchor on the way (the "leaves both slots alone" clause).
    @Test func aBookWithNoPlaceCarriesNothing() {
        let model = model(entries: ["p0"])
        model.carryPlace(from: .read, readForm: .flow)
        #expect(model.pendingReveal == nil)
        #expect(model.standingAnchorPostID == nil)

        model.requestReveal("p0")
        model.consumeReveal()
        model.carryPlace(from: .read, readForm: .flow)
        #expect(model.standingAnchorPostID == "p0", "the last place survives an empty carry")
    }

    /// The landing is consumed EXACTLY ONCE — the surfaces all consume, and
    /// a second surface mounting must not re-land an old request.
    /// (Revert W21-B's arm.)
    @Test func theLandingIsConsumedExactlyOnce() {
        let model = model(entries: ["p0", "p1"])
        model.requestReveal("p1")
        #expect(model.pendingReveal == "p1")
        model.consumeReveal()
        #expect(model.pendingReveal == nil)
        model.consumeReveal()
        #expect(model.pendingReveal == nil, "idempotent")
    }

    /// The SPREAD really lands (the one landing that is model-level on both
    /// sides): a reveal for an off-spread post moves the spread onto it.
    @Test func theSpreadLandsOnTheRevealedPost() {
        let model = model(entries: ["p0", "p1", "p2", "p3"])
        model.requestReveal("p3")
        // What `SpreadBookView.landReveal` does, exactly.
        let landing = model.pendingReveal
        model.consumeReveal()
        model.showPost(landing!)
        #expect(model.spreadEntries.contains { $0.postID == "p3" })
    }
}

// MARK: - W21: the paginated reader's report

@MainActor
@Suite("Read ▸ Pages reports its address (13f W21)")
struct PagedAnchorReportTests {
    @Test func theReaderNamesThePostItsAddressPointsAt() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            var entries: [Queries.ReadingEntry] = []
            for i in 0..<3 {
                let post = try session.operations.createPost(title: "post \(i)")
                _ = try session.operations.newBlock(
                    in: post.id, text: "Some prose for post \(i). It runs on a little.")
                entries.append(Queries.ReadingEntry(
                    postID: post.id, title: "post \(i)", entryDate: nil, sectionPath: nil))
            }
            let pages = PagedReadModel(session: session)
            #expect(pages.currentPostID == nil, "no entries yet ⇒ no address")
            await pages.adopt(entries: entries, chapterOpeners: [:])
            #expect(pages.currentPostID == entries[0].postID)
            pages.showPost(entries[2].postID)
            #expect(pages.currentPostID == entries[2].postID,
                    "the report follows the address, which is what the carry reads")
        }
    }
}

// MARK: - W20: the chooser's order and the bar's line

@Suite("The books chooser (13f W20 c)")
struct BookChooserOrderTests {
    private func book(_ id: String, _ name: String, _ kind: ReadingKind) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: id, name: name, kind: kind, createdAt: now, updatedAt: now)
    }

    /// Her round-10 shaping, as arithmetic: curated first, recency floating
    /// INSIDE each group (never across it — a recently-read smart book does
    /// not outrank a hand-made one).
    @Test func curatedComeFirstAndRecencyFloatsInsideEachGroup() {
        let books = [
            book("s1", "Alpha smart", .smart),
            book("c1", "Zeta curated", .curated),
            book("c2", "Beta curated", .curated),
            book("s2", "Zulu smart", .smart),
        ]
        let ordered = BookChooserOrder.ordered(books, recentlyVisited: ["s2", "c1"])
        #expect(ordered.map(\.id) == ["c1", "c2", "s2", "s1"])

        // With no recency at all it is a stable name order, per group.
        #expect(BookChooserOrder.ordered(books, recentlyVisited: []).map(\.id)
                == ["c2", "c1", "s1", "s2"])
    }

    /// Duplicate names cannot make the order ambiguous — the id breaks it,
    /// so every device shows the same list.
    @Test func theOrderIsTotal() {
        let twins = [book("b", "Same", .curated), book("a", "Same", .curated)]
        #expect(BookChooserOrder.ordered(twins, recentlyVisited: []).map(\.id) == ["a", "b"])
    }

    /// The in-line's sentence: the top pick, and how many others.
    @Test func theInLineNamesTheTopPickAndCountsTheRest() {
        #expect(BookChooserOrder.inLine([]) == nil, "no books ⇒ no line, not 'in no book'")
        #expect(BookChooserOrder.inLine([book("c", "Orbit", .curated)]) == "in Orbit")
        #expect(BookChooserOrder.inLine([
            book("c", "Orbit", .curated), book("d", "Field Notes", .curated),
            book("e", "Dreams", .smart),
        ]) == "in Orbit & 2 more")
    }
}

// MARK: - W20: ONE bar, folding as one thing

@MainActor
@Suite("The context bar (13f W20 b)")
struct ContextBarTests {
    private func book(_ name: String) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: name, name: name, kind: .curated, createdAt: now, updatedAt: now)
    }

    private func bar(origin: String?, books: [Reading], collapsed: Bool = false) -> ContextBar {
        ContextBar(
            tokens: .fallback(for: .light), originLabel: origin, books: books,
            collapsed: collapsed, onBack: {}, onOpenTopBook: {}, onToggleCollapse: {})
    }

    /// The bar exists exactly when it has something to say — a cold launch
    /// at the shelf keeps the chrome it had before this shipped.
    @Test func theBarRendersOnlyWhenItHasSomethingToSay() {
        #expect(!bar(origin: nil, books: []).hasContent)
        #expect(bar(origin: "Orbit", books: []).hasContent, "the back half alone")
        #expect(bar(origin: nil, books: [book("Orbit")]).hasContent, "the ascent half alone")
        #expect(bar(origin: "Shelf", books: [book("Orbit")]).hasContent)
        // Collapsing never removes the bar — her ruling asked for tidiness,
        // not for loss (both halves stay doors as glyphs).
        #expect(bar(origin: "Shelf", books: [book("Orbit")], collapsed: true).hasContent)
    }
}

// MARK: - W20: the door, the broadcast, and the shell's decision

@MainActor
@Suite("The ascent door (13f W20 a)")
struct AscentDoorTests {
    /// **THE TRACE, PINNED.** The chip's book link has rendered since Phase
    /// 13 and done NOTHING: it called an optional closure its one mount
    /// never passed. The optional is gone; the act is a named call, and this
    /// is the pin that call exists for.
    @Test func theChipsLinkBroadcastsTheBookAndThePost() {
        let received = LockIsolated<[[String: String]]>([])
        let token = NotificationCenter.default.addObserver(
            forName: .variorumOpenBookAtPost, object: nil, queue: nil
        ) { note in
            guard let book = note.userInfo?["bookID"] as? String,
                  let post = note.userInfo?["postID"] as? String else { return }
            received.withValue { $0.append(["bookID": book, "postID": post]) }
        }
        defer { NotificationCenter.default.removeObserver(token) }

        MembershipChip.ascend(bookID: "book-1", postID: "post-9")
        #expect(received.value == [["bookID": "book-1", "postID": "post-9"]])
    }

    /// The registry's fold: ONE act, two doors, one key — and available
    /// everywhere, because the state it fixes is "the bar is hidden".
    @Test func theFoldIsOneDeclaredActWithOneKey() {
        let capability = CapabilityRegistry.capability(.toggleContextBar)
        #expect(capability.scope == .app)
        #expect(capability.doors == [.menuBar, .palette])
        #expect(capability.shortcutLabel == "\u{2318}\u{21e7}I")
        #expect(capability.availability(CapabilityContext()) == .act,
                "a door whose job is to bring a hidden bar back must never be grey")
        let key = EditorCommands.keyEquivalent(for: .toggleContextBar)
        #expect(key?.0 == "i")
        #expect(key?.1 == [.command, .shift])
        #expect(EditorCommands.menuRendered.contains(.toggleContextBar))
        #expect(ShellActions.paletteActs.contains(.toggleContextBar))
    }

    /// …and it toggles ONE state, so the two halves can never hide
    /// separately (her ruling: never two hiding mechanisms).
    @Test func theFoldToggchesTheWholeBar() {
        let router = ShellRouter()
        #expect(!router.workspace.contextBarCollapsed)
        router.toggleContextBar()
        #expect(router.workspace.contextBarCollapsed)
        router.toggleContextBar()
        #expect(!router.workspace.contextBarCollapsed)
    }

    /// Visiting a book floats it in the chooser — recorded at the ONE
    /// recording point, so no door has to remember (and bounded, so a
    /// session trail cannot grow with the corpus).
    @Test func visitingABookFloatsItAndTheTrailIsBounded() {
        let workspace = WorkspaceModel()
        workspace.visit(.reading("b1"))
        workspace.visit(.reading("b2"))
        workspace.visit(.post("p1"))
        workspace.visit(.reading("b1"))
        #expect(workspace.recentBookIDs == ["b1", "b2"], "most recent first, no duplicates")

        for i in 0..<(WorkspaceModel.recentBookBound + 5) {
            workspace.visit(.reading("x\(i)"))
        }
        #expect(workspace.recentBookIDs.count == WorkspaceModel.recentBookBound)
    }
}

// MARK: - W20: the shell turns the broadcast into a navigation

@MainActor
@Suite("The shell routes the ascent (13f W20 a)", .serialized)
struct AscentRoutingTests {
    /// The shell's whole decision, pinned where it lives: the pane navigates
    /// to the BOOK, through the ONE adoption door — so the pane's history is
    /// pushed and ⌘[ returns to the note she ascended from.
    @Test func openingABookAtAPostNavigatesAndPushesHistory() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note")
            let reading = try session.operations.createReading(name: "Orbit", kind: .curated)
            try session.operations.addPostToReading(post.id, to: reading.id)

            let router = ShellRouter()
            let view = RootView(session: session, router: router)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: true)
            window.contentView = NSHostingView(rootView: view)
            window.orderFront(nil)
            defer { window.orderOut(nil) }
            for _ in 0..<8 {
                try? await Task.sleep(for: .milliseconds(25))
            }

            // She is IN the note…
            router.workspace.select(.post(post.id))
            // …and the chip's link fires.
            MembershipChip.ascend(bookID: reading.id, postID: post.id)
            for _ in 0..<12 {
                try? await Task.sleep(for: .milliseconds(25))
                if router.workspace.selections[router.workspace.focusedPane]
                    == .reading(reading.id) { break }
            }

            #expect(router.workspace.selections[router.workspace.focusedPane]
                    == .reading(reading.id), "the pane went to the book")
            #expect(router.workspace.history().origin == .post(post.id),
                    "…through the one adoption door, so ⌘[ comes back to the note")
        }
    }
}

// MARK: - W22: the first-edit note

@Suite("The first-edit note's conditions (13f W22)")
struct MultiBookEditNoteRuleTests {
    /// Both halves of the ruled trigger, in the one place the trigger site
    /// reads them from.
    @Test func itSpeaksOnceForATwoBookNoteAndNeverOtherwise() {
        #expect(MultiBookEditNote.shouldSpeak(bookCount: 2, seen: false))
        #expect(MultiBookEditNote.shouldSpeak(bookCount: 7, seen: false))
        #expect(!MultiBookEditNote.shouldSpeak(bookCount: 1, seen: false),
                "one book is not the confusion she described")
        #expect(!MultiBookEditNote.shouldSpeak(bookCount: 0, seen: false))
        #expect(!MultiBookEditNote.shouldSpeak(bookCount: 5, seen: true),
                "ONE TIME EVER — she learns the rule once")
    }

    /// Her ruled copy: the rule, and the door by name.
    @Test func theSentenceStatesTheRuleAndNamesTheDoor() {
        let sentence = MultiBookEditNote.sentence(bookCount: 3)
        #expect(sentence.contains("3 books"))
        #expect(sentence.contains("editing here edits it everywhere"))
        #expect(sentence.contains("Duplicate as Version"))
    }
}

@MainActor
@Suite("The first-edit note fires and writes nothing (13f W22)", .serialized)
struct MultiBookEditNoteTriggerTests {
    /// The coordinator's hook: ONCE per post, at the first edit, whichever
    /// surface made it (they share one coordinator — the N3 boundary).
    @Test func theCoordinatorAnnouncesTheFirstEditExactlyOnce() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let coordinator = AutosaveCoordinator(
                runner: session.runner, debounce: .milliseconds(1))
            let fired = LockIsolated(0)
            coordinator.onFirstEdit = { fired.withValue { $0 += 1 } }
            coordinator.record(variantID: "v1", text: "a", charDelta: 1)
            coordinator.record(variantID: "v1", text: "ab", charDelta: 1)
            coordinator.record(variantID: "v2", text: "c", charDelta: 1)
            #expect(fired.value == 1, "the FIRST edit, not every edit")
        }
    }

    /// End to end through the real session wiring — and the property that
    /// makes it safe to hang off the typing path: **ZERO STORE BYTES.**
    @Test func editingATwoBookNoteSpeaksOnceAndWritesNothingOfItsOwn() async throws {
        let db = try AppDatabase.inMemory()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: MultiBookEditNote.seenKey)
        defer { defaults.removeObject(forKey: MultiBookEditNote.seenKey) }

        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "shared")
            let block = try session.operations.newBlock(in: post.id, text: "Some prose.")
            for name in ["Orbit", "Field Notes"] {
                let reading = try session.operations.createReading(name: name, kind: .curated)
                try session.operations.addPostToReading(post.id, to: reading.id)
            }
            let before = try await db.read { db -> [Int] in
                [try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1]
            }

            // The first edit, through the shared per-post coordinator.
            session.autosave(forPost: post.id)
                .record(variantID: block.variant.id, text: "Some prose.", charDelta: 0)
            for _ in 0..<20 {
                try? await Task.sleep(for: .milliseconds(25))
                if session.status.current != nil { break }
            }
            let spoken = try #require(session.status.current?.text)
            #expect(spoken.contains("2 books"))
            #expect(spoken.contains("Duplicate as Version"))
            #expect(MultiBookEditNote.hasBeenSeen(), "the flag is set — once, ever")

            let after = try await db.read { db -> [Int] in
                [try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point") ?? -1,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1]
            }
            #expect(after == before, "the NOTE writes nothing — it reads and it speaks")
        }
    }

    /// A one-book note says nothing, and the flag stays unset so the note is
    /// still owed the first time a shared one is edited.
    @Test func editingASingleBookNoteSaysNothingAndKeepsTheNoteOwed() async throws {
        let db = try AppDatabase.inMemory()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: MultiBookEditNote.seenKey)
        defer { defaults.removeObject(forKey: MultiBookEditNote.seenKey) }

        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "lonely")
            let block = try session.operations.newBlock(in: post.id, text: "Some prose.")
            let reading = try session.operations.createReading(name: "Orbit", kind: .curated)
            try session.operations.addPostToReading(post.id, to: reading.id)

            session.autosave(forPost: post.id)
                .record(variantID: block.variant.id, text: "Some prose!", charDelta: 1)
            for _ in 0..<8 { try? await Task.sleep(for: .milliseconds(25)) }
            #expect(session.status.current == nil)
            #expect(!MultiBookEditNote.hasBeenSeen(), "still owed")
        }
    }
}
