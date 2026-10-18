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
        index: String? = nil, standing: String? = nil
    ) -> BookAnchor.Place {
        BookAnchor.Place(
            focusedPostID: focused, spreadPostIDs: spread,
            pagedPostID: paged, indexPostID: index, standingPostID: standing)
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

        // Index (wave 2c): the column's reported selection is the place.
        #expect(BookAnchor.currentPost(
            mode: .index, readForm: .flow,
            place: place(focused: "a", spread: ["b"], paged: "c",
                         index: "e", standing: "d")) == "e")
        #expect(BookAnchor.currentPost(
            mode: .index, readForm: .flow, place: place(focused: "a", standing: "d")) == "d",
                "nothing selected yet ⇒ the standing anchor, not another mode's focus")
    }
}

// MARK: - W21: the carry, at the model

@MainActor
@Suite("The mode click-over carries your place (13f W21)")
struct BookCarryTests {
    private func model(entries: [String]) async -> BookViewModel {
        let db = try! AppDatabase.inMemory()
        // 13j batch 6: the session snapshots a READ-side clock at
        // construction (the 30-day Trash window is a required argument
        // wherever it applies), and a dependency read with no override is an
        // issue in a test context by design — so this synthetic world names
        // its clock like every other harness here. Nothing else changes: this
        // suite drives a model by `adopt`.
        let session = withDependencies {
            $0.database = db
            $0.date = DateGenerator { harnessNow }
        } operation: { AppSession(database: db) }
        let model = BookViewModel(session: session, readingID: "book")
        await model.adopt(entries.map {
            Queries.ReadingEntry(postID: $0, title: nil, entryDate: nil, sectionPath: nil)
        })
        return model
    }

    /// Leaving OUTLINE carries the focused post.
    @Test func leavingOutlineCarriesTheFocusedPost() async {
        let model = await model(entries: ["p0", "p1", "p2"])
        model.focus("p2")
        model.carryPlace(from: .outline, readForm: .flow)
        #expect(model.pendingReveal == "p2")
        #expect(model.standingAnchorPostID == "p2")
    }

    /// Leaving BOOK carries the spread's left page — NOT the focus, which
    /// may be a post the spread is not showing. (Revert W21-A's arm.)
    @Test func leavingTheSpreadCarriesThePageOnScreen() async {
        let model = await model(entries: ["p0", "p1", "p2", "p3"])
        model.focus("p0")          // an outline focus from earlier
        model.openSpread(leftIndex: 2)  // …and the spread moved away from it
        #expect(model.focusedPostID == nil, "flipping released the ring (the standing rule)")
        model.carryPlace(from: .spread, readForm: .flow)
        #expect(model.pendingReveal == "p2", "the LEFT page, which is what she is looking at")
    }

    /// Leaving READ ▸ PAGES carries the reader's reported address. (Revert
    /// W21-A's second arm.)
    @Test func leavingPagedReadCarriesTheReportedAddress() async {
        let model = await model(entries: ["p0", "p1", "p2"])
        model.focus("p0")
        model.notePagedAnchor("p1")
        model.carryPlace(from: .read, readForm: .pages)
        #expect(model.pendingReveal == "p1")
    }

    /// Leaving READ ▸ SCROLL carries where she ARRIVED — the recorded gap,
    /// pinned as behaviour so it can never become a silent surprise.
    @Test func leavingTheReadingFlowCarriesWhereSheArrived() async {
        let model = await model(entries: ["p0", "p1", "p2"])
        model.focus("p2")
        model.carryPlace(from: .outline, readForm: .flow)   // outline → read
        model.consumeReveal()                               // the flow landed
        model.carryPlace(from: .read, readForm: .flow)      // read → book
        #expect(model.pendingReveal == "p2",
                "the flow tracks no scroll position, so the arrival is the place")
    }

    /// Leaving INDEX carries the column's reported selection (wave 2c —
    /// the `notePagedAnchor` pattern, same reason: the selection is the
    /// index's own fact, traveled one step to be readable here).
    @Test func leavingTheIndexCarriesItsSelection() async {
        let model = await model(entries: ["p0", "p1", "p2"])
        model.focus("p0")
        model.noteIndexAnchor("p2")
        model.carryPlace(from: .index, readForm: .flow)
        #expect(model.pendingReveal == "p2")
        #expect(model.standingAnchorPostID == "p2")
    }

    /// A book with no place at all carries NOTHING — and does not wipe the
    /// standing anchor on the way (the "leaves both slots alone" clause).
    @Test func aBookWithNoPlaceCarriesNothing() async {
        let model = await model(entries: ["p0"])
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
    @Test func theLandingIsConsumedExactlyOnce() async {
        let model = await model(entries: ["p0", "p1"])
        model.requestReveal("p1")
        #expect(model.pendingReveal == "p1")
        model.consumeReveal()
        #expect(model.pendingReveal == nil)
        model.consumeReveal()
        #expect(model.pendingReveal == nil, "idempotent")
    }

    /// The SPREAD really lands (the one landing that is model-level on both
    /// sides): a reveal for an off-spread post moves the spread onto it.
    @Test func theSpreadLandsOnTheRevealedPost() async {
        let model = await model(entries: ["p0", "p1", "p2", "p3"])
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
            book("s1", "Alpha smart", .gathering),
            book("c1", "Zeta curated", .book),
            book("c2", "Beta curated", .book),
            book("s2", "Zulu smart", .gathering),
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
        let twins = [book("b", "Same", .book), book("a", "Same", .book)]
        #expect(BookChooserOrder.ordered(twins, recentlyVisited: []).map(\.id) == ["a", "b"])
    }

    /// **13k K11 retired the in-line** (`BookChooserOrder.inLine`, and this
    /// pin with it): the bar's spelled-out "in <top pick> & N more" became
    /// the book ICON, whose three arities are pinned by
    /// `ContextBarDoors.bookClick` and whose words are
    /// `WorkspaceNaming.ascentHelp`. The ORDER the sentence read from is
    /// untouched, and is pinned by the three tests above.
    @Test func theBooksWordsNowLiveOnTheIconsHelp() {
        #expect(WorkspaceNaming.ascentHelp(topBook: nil, count: 0)
                == "This note isn't in any book yet")
        #expect(WorkspaceNaming.ascentHelp(topBook: "Orbit", count: 1)
                == "Open \u{201c}Orbit\u{201d} at this note (\u{2318}-click to see it listed)")
        #expect(WorkspaceNaming.ascentHelp(topBook: "Orbit", count: 3)
                == "This note is in 3 books — click to pick one")
        #expect(WorkspaceNaming.ascentListHeader(count: 1)
                == "This note is in 1 book — open it at this note:")
        #expect(WorkspaceNaming.ascentListHeader(count: 3)
                == "This note is in 3 books — open one at this note:")
    }
}

// MARK: - W20: ONE bar, folding as one thing

@MainActor
@Suite("The context bar (13f W20 b)")
struct ContextBarTests {
    private func book(_ name: String) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: name, name: name, kind: .book, createdAt: now, updatedAt: now)
    }

    /// 13k K11 rebuilt the bar's face: no `collapsed`, a real forward door,
    /// and the tag fold as its own sticky preference. The claim below is
    /// unchanged — this is the new call shape.
    private func bar(
        origin: String?, books: [Reading], forward: String? = nil, isNote: Bool = false
    ) -> ContextBar {
        ContextBar(
            tokens: .fallback(for: .light), originLabel: origin, forwardLabel: forward,
            books: books, isNote: isNote,
            onBack: {}, onForward: {}, onOpenBook: { _ in })
    }

    /// The bar exists exactly when it has something to say — a cold launch
    /// at the shelf keeps the chrome it had before this shipped.
    @Test func theBarRendersOnlyWhenItHasSomethingToSay() {
        #expect(!bar(origin: nil, books: []).hasContent)
        #expect(bar(origin: "Orbit", books: []).hasContent, "the back door alone")
        #expect(bar(origin: nil, books: [book("Orbit")]).hasContent, "the ascent alone")
        #expect(bar(origin: "Shelf", books: [book("Orbit")]).hasContent)
        // 13k K11: a pane that has only gone BACK still has a bar — the →
        // is a door now, so "somewhere to go forward" is something to say.
        #expect(bar(origin: nil, books: [], forward: "Orbit").hasContent)
        // …and a note always has one (13g R6-1's widening, unchanged).
        #expect(bar(origin: nil, books: [], isNote: true).hasContent)
    }

    /// **13k K11 — THE ROW NEVER CHANGES SHAPE.** Her ruling: *"the
    /// collapsing and growing in that bar is a little annoying to me"* …
    /// *"it should always look like this"*. So a note's bar renders all
    /// three doors whatever the state is, and the ones that cannot act are
    /// GREY rather than gone. *(Act 10 item 5: the ＃ and the cards left
    /// for the masthead cluster — the row is three doors now; the
    /// constancy claim is unchanged.)*
    ///
    /// DISCRIMINATING REVERT: make `ContextBar.renderedIcons` drop `.back`
    /// when `originLabel == nil` (13f's own shape, where the back half
    /// rendered only with a history) — the first expectation fails.
    @Test func theIconRowIsTheSameThreeDoorsWhateverTheState() {
        let cold = bar(origin: nil, books: [], isNote: true)
        #expect(cold.renderedIcons == [.back, .book, .forward])
        #expect(!cold.backEnabled && !cold.forwardEnabled && !cold.bookEnabled,
                "all three greys, none of them absent")
        let full = bar(
            origin: "Shelf", books: [book("Orbit")], forward: "Field Notes", isNote: true)
        #expect(full.renderedIcons == [.back, .book, .forward],
                "the same three, in the same order")
        #expect(full.backEnabled && full.forwardEnabled && full.bookEnabled)
        // A pane holding a PLACE has no book door (P-2: a door that can
        // never act in its context isn't rendered) — a different rule from
        // the greys INSIDE a note's row, and the reason the shelf's chrome
        // is unchanged by the always-visible row.
        #expect(bar(origin: "Shelf", books: []).renderedIcons == [.back, .forward])
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

    /// **The Act 10 correction round, row 15 (a JUSTIFIED PIN EDIT — the
    /// fold's pin becomes the act's):** ⌘⇧I is `.tagNote`'s chord now. The
    /// fold (`.toggleTagChips` — 13f W20(b)'s, repointed by 13k K11/K12 at
    /// the tag cards) is RETIRED: the masthead has ONE tag door, the ＃,
    /// which opens the inline field, and the key opens the same field. What
    /// this pin held — ONE act, three doors (menu · palette · surface), one
    /// key — it still holds, of the successor. Scope is `.post` and the act
    /// is note-scoped (a field with no note under it has nothing to tag),
    /// which is the one deliberate change from the fold's always-availability.
    @Test func theFoldIsOneDeclaredActWithOneKey() {
        let capability = CapabilityRegistry.capability(.tagNote)
        #expect(capability.scope == .post)
        #expect(capability.doors == [.menuBar, .palette, .surface])
        #expect(capability.shortcutLabel == "\u{2318}\u{21e7}I")
        #expect(capability.availability(CapabilityContext()) == .unavailable,
                "with no note open the field has nothing to tag — honestly grey")
        #expect(capability.availability(CapabilityContext(mode: .write)) == .act)
        let key = EditorCommands.keyEquivalent(for: .tagNote)
        #expect(key?.0 == "i")
        #expect(key?.1 == [.command, .shift])
        #expect(EditorCommands.menuRendered.contains(.tagNote))
        #expect(ShellActions.paletteActs.contains(.tagNote))
        // The bar's own icon row declares its doors, so the `.surface` walk
        // covers them.
        //
        // **13e E11 (JUSTIFIED EDIT — called out so a reviewer checks it
        // rather than assuming):** the ASCENT joined the list. 13k left it
        // out deliberately and recorded the omission as a build-time call
        // (#55(i)); she ratified that WITH the declare-it alternative open
        // ("13e's if ever wanted") and then asked for the registry to be kept
        // up to date — so the fourth element is her ruling landing, and this
        // flipped expectation is that change's own red-on-old proof (the
        // pre-13e registry has no `.openBookAtNote` at all). The three
        // originals and their order are untouched.
        // **13e E8 (a SECOND justified edit, same convention):** the tag
        // CARDS' own doors (`＋` / `✕`) are declared now as `.tagNote` —
        // they have worked since 13g R6-1 and were never in the catalog,
        // and E8 gave the Library's rows the same act, so it is declared
        // once with both renderers naming it. The four earlier elements
        // and their order are untouched.
        // **13j J2 (a THIRD justified edit, same convention):** the TRAY
        // badge — the bar's fifth door and the only conditional one (it
        // renders when this note has deleted something). The five earlier
        // elements and their order are untouched.
        // **Act 10 item 5 (a FOURTH justified edit, same convention — and
        // this one REMOVES):** the tag cards and the ＃ fold moved to the
        // masthead's right edge by her ruling, so the tag acts are declared
        // by `MastheadTagCluster` now — the acts moved WITH their renderer,
        // asserted here from both sides so a drift in either home fails by
        // name. **The Act 10 correction round, row 15 (a FIFTH):** the
        // masthead declares ONE tag act — the fold is retired.
        #expect(ContextBar.surfaceCapabilities
                == [.navigateBack, .navigateForward, .openBookAtNote, .showNoteTray])
        #expect(MastheadTagCluster.surfaceCapabilities == [.tagNote])
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
            let reading = try session.operations.createReading(name: "Orbit", kind: .book)
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
        // VX-372 (P-C-1 — JUSTIFIED EDIT): the door by its declared verb.
        #expect(sentence.contains(CapabilityRegistry.capability(.duplicateNoteWithTags).verb))
        #expect(!sentence.contains("Duplicate as Version"))
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
                let reading = try session.operations.createReading(name: name, kind: .book)
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
            // VX-372 (P-C-1 — JUSTIFIED EDIT): the door by its declared verb.
            #expect(spoken.contains(CapabilityRegistry.capability(.duplicateNoteWithTags).verb))
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
            let reading = try session.operations.createReading(name: "Orbit", kind: .book)
            try session.operations.addPostToReading(post.id, to: reading.id)

            session.autosave(forPost: post.id)
                .record(variantID: block.variant.id, text: "Some prose!", charDelta: 1)
            for _ in 0..<8 { try? await Task.sleep(for: .milliseconds(25)) }
            // 18i: NOTHING was said — read both slots, so a receipt
            // landing quietly could never pass as silence.
            #expect(session.status.spoken == nil)
            #expect(!MultiBookEditNote.hasBeenSeen(), "still owed")
        }
    }
}

// MARK: - W23: the diverge doors (13f batch 5's continuation)

@MainActor
@Suite("Diverge for this book — the doors (13f W23)")
struct DivergeDoorTests {
    private func book(_ id: String, _ name: String, _ kind: ReadingKind) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: id, name: name, kind: kind, createdAt: now, updatedAt: now)
    }

    /// The declaration: a `.surface` act on the chip's book rows, for the
    /// same reason `.openPeerPost` is one — the target is the row you point
    /// at, so nothing has to guess which book she meant.
    @Test func theDoorIsDeclaredAsASurfaceActOnThePostsChip() {
        let capability = CapabilityRegistry.capability(.divergeForBook)
        #expect(capability.scope == .post)
        #expect(capability.doors == [.surface])
        #expect(capability.availability(CapabilityContext(mode: .write)) == .act)
        #expect(capability.availability(CapabilityContext(mode: nil)) == .unavailable,
                "no post open ⇒ no chip ⇒ honestly unavailable")
        #expect(MembershipChip.surfaceCapabilities.contains(.divergeForBook),
                "declared ⇔ rendered — the walk's union covers the rest")
    }

    /// The words, in one place so both doors say the same thing: what the
    /// act does, what it did, and the ONE refusal that needs its own
    /// sentence (a smart book has no membership row to swap).
    @Test func theCopyNamesTheBookTheUndoAndTheTagRoad() {
        #expect(DivergeCopy.buttonLabel(book: "Orbit").contains("Orbit"))
        #expect(DivergeCopy.help(book: "Orbit").contains("original stays"))

        let done = DivergeCopy.done(book: "Orbit")
        #expect(done.contains("Orbit"))
        #expect(done.contains("\u{2325}\u{2318}Z"), "the ratified undo grammar")

        let smart = DivergeCopy.refusal(
            for: OperationError.wrongReadingKind(id: "r", expected: .book), book: "Dreams")
        #expect(smart.contains("tags"), "it names the tag road rather than staying silent")
        // VX-372 (P-C-1 — JUSTIFIED EDIT): the door by its declared verb.
        #expect(smart.contains(CapabilityRegistry.capability(.duplicateNoteWithTags).verb))
        #expect(!smart.contains("Duplicate as Version"))
        // Everything else falls through to the standing chip wording.
        #expect(DivergeCopy.refusal(for: OperationError.lockedReading(id: "r"), book: "Orbit")
                == ChipRefusals.message(
                    for: OperationError.lockedReading(id: "r"), bookName: "Orbit"))
    }

    /// **L17 (her WT-7 round-4 ruling), built at the cold review (R1-1)
    /// after the batches dropped it.** Two halves, both hers:
    ///
    /// - the RECEIPT reads as a receipt — "tied to the past act and naming
    ///   its book" (the round-4 disposition's words): the diverge's landing
    ///   button carries the book that now holds the copy, and the plain
    ///   duplicate's (whose copy has no book) stays the bare receipt beside
    ///   its own status line;
    /// - the EXPLAINER conditions on membership: "everywhere it appears" is
    ///   said only where an elsewhere exists; a bookless note — including
    ///   the ORIGINAL right after a diverge moved it out of its only book,
    ///   her screenshot's exact state — gets the door's plain lead-in.
    ///
    /// DISCRIMINATING REVERT (verified): make `openCopyLabel(book:)` return
    /// the bare "Open the Copy" regardless ⇒ the first expectation fails;
    /// make `explainerLine` return the "everywhere" sentence
    /// unconditionally ⇒ the bookless expectation fails. Each restored,
    /// checksum-matched.
    @Test func theCopyReceiptNamesItsBookAndTheExplainerNeedsAnElsewhere() {
        #expect(DivergeCopy.openCopyLabel(book: "my book :)")
                == "Open the Copy in \u{201c}my book :)\u{201d}")
        #expect(DivergeCopy.openCopyLabel(book: nil) == "Open the Copy",
                "a plain duplicate's copy has no book to name")

        #expect(!MembershipChip.explainerLine(bookCount: 0).contains("everywhere"),
                "a bookless note has no elsewhere — the claim would be vacuous")
        #expect(MembershipChip.explainerLine(bookCount: 0).contains("separate"),
                "the door still gets its lead-in")
        #expect(MembershipChip.explainerLine(bookCount: 2)
                .contains("everywhere it appears"), "R31/R35's truth, where it IS true")
        #expect(MembershipChip.explainerLine(bookCount: 2).contains("diverge"))
    }

    /// The note's TARGET rule (her round-10 item 4, W22's button): the first
    /// CURATED book in the chooser's order — which is the book she came from
    /// whenever she came from one, because arriving floats it.
    @Test func theNotesButtonTargetsTheFirstCuratedBookInTheChoosersOrder() {
        let books = [
            book("s1", "Alpha smart", .gathering),
            book("c1", "Zeta curated", .book),
            book("c2", "Beta curated", .book),
        ]
        #expect(MultiBookEditNote.divergeTarget(books, recentlyVisited: [])?.id == "c2",
                "no recency ⇒ the chooser's plain order")
        #expect(MultiBookEditNote.divergeTarget(books, recentlyVisited: ["c1"])?.id == "c1",
                "the book she came from floats and takes the button")
        #expect(MultiBookEditNote.divergeTarget(books, recentlyVisited: ["s1"])?.id == "c2",
                "a recent SMART book never takes it — it could only refuse")
        #expect(MultiBookEditNote.divergeTarget(
            [book("s1", "Only smart", .gathering), book("s2", "Also smart", .gathering)],
            recentlyVisited: []) == nil,
                "every membership derived ⇒ the note speaks with NO button")
    }

    /// **THE COLD REVIEW'S R1-4 PIN (red on the pre-fix code).** The
    /// diverge doors are OFFERED at the first dirty keystroke (the note's
    /// trigger fires from `record`), so the shared entry
    /// (`AppSession.divergeForBook`) flushes the post's pending buffer
    /// before copying — without the flush, a click inside the debounce
    /// minted a book copy missing the very keystrokes that summoned the
    /// offer (`copyPost` reads `working_text` rows; the insure-before-copy
    /// doctrine).
    @Test func aDivergeCarriesThePendingUnflushedText() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "shared")
            let block = try session.operations.newBlock(in: post.id, text: "Alpha beta.")
            let book = try session.operations.createReading(name: "Orbit", kind: .book)
            try session.operations.addPostToReading(post.id, to: book.id)

            // The bug's exact state: the edit is PENDING in the shared
            // coordinator's debounce, not yet in the store.
            session.autosave(forPost: post.id).record(
                variantID: block.variant.id, text: "Alpha beta. NEW", charDelta: 4)
            let stored = try await db.read { db in
                try Queries.renderPost(db, containerID: post.id).first?.text
            }
            #expect(stored == "Alpha beta.",
                    "the premise: the store has not seen the edit yet")

            let result = try await session.divergeForBook(post.id, in: book.id)
            let copyText = try await db.read { db in
                try Queries.renderPost(db, containerID: result.copy.post.id).first?.text
            }
            #expect(copyText == "Alpha beta. NEW",
                    "the copy carries what she just typed — the flush ran first")
        }
    }

    /// A status item may carry ONE door, and carrying one changes nothing
    /// about the ones that don't (13u2 UNIT E — row 56: the door that carries
    /// one is `offer`, the one that does not is `refuse`; before the rename
    /// both were `speak` and the class was inferred).
    @Test func aStatusNoteCanCarryOneDoor() {
        let center = StatusCenter()
        center.refuse("plain")
        #expect(center.current?.action == nil)

        let fired = LockIsolated(0)
        center.offer("offer", action: StatusCenter.Item.Action(
            label: "Do it", perform: { fired.withValue { $0 += 1 } }))
        let action = center.current?.action
        #expect(action != nil)
        #expect(action?.label == "Do it")
        action?.perform()
        #expect(fired.value == 1)
    }
}
