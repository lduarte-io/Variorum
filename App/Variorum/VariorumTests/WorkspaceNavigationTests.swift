//
//  WorkspaceNavigationTests.swift
//  VariorumTests
//
//  Phase 13f, batch 3 — the NAVIGATION core's pins (her W3/A27 + W16
//  rulings). Everything that DECIDES anything here is pure arithmetic over
//  ids, and it is pinned as arithmetic: the per-pane history's trail, the
//  Open strip's order, membership and bounds, the ordinal keys' reach, and
//  the names the chip and the strip wear. The routing half pins at the
//  registry / shell-door layer (the 13d A14 precedent), including the
//  COLLISION SWEEP MADE PERMANENT.
//
//  **Batch 4, item 0 — the RULED ORDERING FLIP** (her sitting round 7.1:
//  *"insertion order, maybe they're draggable / reorderable manually like
//  browser tabs as well though? session only, not a setting"*). The strip's
//  ORDER pins are deliberately inverted here — batch 3 shipped recency for
//  both order and membership, and flagged the consequence to her rather
//  than deciding it; she ruled. Each flipped pin says so on its face, and
//  the new pins cover what the flip BUYS (stable ordinals), what it must
//  NOT cost (recency still decides who leaves at the bound), and the
//  reorder arithmetic her second half asks for.
//
//  What is deliberately NOT claimed here: how the strip LOOKS in the
//  sidebar and how the chip's fold FEELS — those are on the batch record's
//  visual-verification-only list.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure history (W16)

@Suite("Navigation history (13f batch 3, W16)")
struct NavigationHistoryTests {
    @Test func visitingBuildsTheTrailAndReVisitingTheCurrentIsANoOp() {
        var history = NavigationHistory()
        #expect(!history.canGoBack)
        #expect(history.origin == nil, "arriving from nowhere shows no chip")

        history.visit(.shelf)
        #expect(!history.canGoBack, "the first arrival has nothing behind it")
        history.visit(.reading("book"))
        history.visit(.post("p1"))
        #expect(history.back == [.shelf, .reading("book")])
        #expect(history.current == .post("p1"))

        // THE RE-ENTRANCY CLAIM: the shell reports every selection change,
        // including the one back/forward caused. Re-visiting the current
        // destination must change nothing at all — that is what lets
        // `goBack` set `current` itself and skip a flag.
        let before = history
        history.visit(.post("p1"))
        #expect(history == before)
    }

    @Test func backAndForwardWalkTheSameTrail() {
        var history = NavigationHistory()
        history.visit(.shelf)
        history.visit(.reading("book"))
        history.visit(.post("p1"))

        #expect(history.origin == .reading("book"), "the chip names the book")
        #expect(history.goBack() == .reading("book"))
        #expect(history.current == .reading("book"))
        #expect(history.canGoForward)
        #expect(history.goBack() == .shelf)
        #expect(history.goBack() == nil, "the trail ends")

        #expect(history.goForward() == .reading("book"))
        #expect(history.goForward() == .post("p1"))
        #expect(history.goForward() == nil)
        #expect(history.current == .post("p1"), "the round trip lands where it started")
    }

    @Test func aNewNavigationEndsTheForwardFuture() {
        var history = NavigationHistory()
        history.visit(.shelf)
        history.visit(.post("p1"))
        _ = history.goBack()
        #expect(history.canGoForward)

        history.visit(.post("p2"))  // a fresh branch
        #expect(!history.canGoForward, "the browser rule — and structural redo's")
        #expect(history.origin == .shelf)
    }

    @Test func theTrailIsBounded() {
        var history = NavigationHistory()
        for i in 0...(NavigationHistory.cap + 20) {
            history.visit(.post("p\(i)"))
        }
        #expect(history.back.count == NavigationHistory.cap, "held state gets a bound")
        // The bound drops the OLDEST, so the recent trail is intact.
        #expect(history.back.last == .post("p\(NavigationHistory.cap + 19)"))
    }
}

// MARK: - The pure Open list (W3/A27)

@Suite("Open notes (13f batch 3, W3/A27; ordering flipped 13f batch 4, round 7.1)")
struct OpenNotesTests {
    /// **A RULED FLIP** (her sitting round 7.1: *"insertion order"*).
    /// Batch 3's pin here read `["c","b","a"]` and "re-opening MOVES";
    /// both are deliberately inverted — the strip is a row of browser tabs
    /// now, not a most-recent list.
    @Test func openingAppendsInInsertionOrderAndNeverMovesAnOpenNote() {
        var open = OpenNotes()
        open.opened("a")
        open.opened("b")
        open.opened("c")
        #expect(open.ids == ["a", "b", "c"], "insertion order — a new note joins the END")

        open.opened("a")
        #expect(open.ids == ["a", "b", "c"],
                "re-opening leaves the row exactly where it sits (the ruled flip)")
        // Recency still moved, and it answers only one question — eviction.
        #expect(open.recency.first == "a")
    }

    /// The point of the flip, stated as the property it buys: a note's
    /// ⌘⇧n is a STABLE ADDRESS across navigation. Batch 3's judgment call
    /// 2 flagged exactly this ("⌘⇧1 is always the note you are already in,
    /// and the ordinals shuffle as she moves"), and she ruled it out.
    @Test func theOrdinalsDoNotShuffleAsSheMovesBetweenNotes() {
        var open = OpenNotes()
        open.opened("a")
        open.opened("b")
        open.opened("c")
        let addresses = (1...3).map { open.id(atOrdinal: $0) }
        #expect(addresses == ["a", "b", "c"])

        // Wander: back to a, over to c, back to a again.
        open.opened("a")
        open.opened("c")
        open.opened("a")
        #expect((1...3).map { open.id(atOrdinal: $0) } == addresses,
                "every key still addresses the note it addressed before")
    }

    @Test func closingARowRemovesOnlyThatRowAndNothingElse() {
        var open = OpenNotes()
        open.opened("a")
        open.opened("b")
        open.close("a")
        #expect(open.ids == ["b"])
        #expect(open.recency == ["b"], "the two lists hold the same set, always")
        open.close("nobody")
        #expect(open.ids == ["b"], "closing something absent is inert")
        // …and it is not a delete: the same note opens straight back — at
        // the END now (the ruled flip; batch 3's pin expected ["a","b"]).
        open.opened("a")
        #expect(open.ids == ["b", "a"])
    }

    @Test func theOrdinalsCoverTheFirstNineRows() {
        var open = OpenNotes()
        for i in 1...OpenNotes.ordinalCap { open.opened("p\(i)") }
        // Insertion order, so the FIRST opened is ⌘⇧1 (batch 3's pin read
        // the other way round — the ruled flip).
        #expect(open.id(atOrdinal: 1) == "p1")
        #expect(open.id(atOrdinal: OpenNotes.ordinalCap) == "p\(OpenNotes.ordinalCap)")
        #expect(open.id(atOrdinal: 0) == nil)
        #expect(open.id(atOrdinal: OpenNotes.ordinalCap + 1) == nil,
                "the keys are ⌘⇧1…⌘⇧9 and stop there")
        #expect(open.shown.count == OpenNotes.ordinalCap)
        // The keys are ⌘⇧1…⌘⇧9, so the ordinal reach is nine.
        #expect(OpenNotes.ordinalCap == 9)
    }

    /// **Act 10 item 9's mechanical half, pinned RED-ON-OLD:** a newly
    /// opened note is NEVER hidden. The old model showed a nine-row prefix
    /// of the insertion order, and a newcomer JOINS AT THE END — so the
    /// tenth note she opened was invisible (her report: the newcomer landed
    /// in the dead "…N more open" overflow). Now the strip shows every open
    /// note and the SECTION scrolls (the starred precedent) — there is no
    /// hidden set left to land in.
    @Test func aNewlyOpenedNoteIsAlwaysShown() {
        var open = OpenNotes()
        for i in 1...15 { open.opened("p\(i)") }
        // RED ON OLD: `shown` was `prefix(9)` and "p15" was hidden.
        #expect(open.shown.contains("p15"), "the newcomer is visible")
        #expect(open.shown == open.ids, "nothing is hidden — the section scrolls instead")
    }

    /// **The ruled auto-close cap (her word): 20.** Opening the 21st note
    /// quietly closes the least-recently-opened one — a tab is a pointer,
    /// nothing is lost.
    @Test func theTwentyFirstNoteClosesTheLeastRecentlyOpenedTab() {
        var open = OpenNotes()
        for i in 1...(OpenNotes.trackedCap + 5) { open.opened("p\(i)") }
        #expect(OpenNotes.trackedCap == 20, "her ruled cap")
        #expect(open.ids.count == OpenNotes.trackedCap, "the session memory's bound")
        #expect(open.recency.count == OpenNotes.trackedCap, "and it stays in step")
        #expect(open.shown.count == OpenNotes.trackedCap, "everything open is shown")
        #expect(!open.ids.contains("p1"), "the LRU-opened tab auto-closed")
        #expect(open.ids.contains("p\(OpenNotes.trackedCap + 5)"), "the newest stays")
    }

    /// The half of her ruling that is NOT insertion order: **membership is
    /// recency's**. A note opened first but returned to often must survive
    /// the bound, and one opened later and never revisited must be the one
    /// that goes.
    @Test func theBoundIsPaidByTheLeastRecentlyOpenedNoteNotTheOldestRow() {
        var open = OpenNotes()
        for i in 1...OpenNotes.trackedCap { open.opened("p\(i)") }
        // Keep returning to the FIRST row; never touch the second again.
        open.opened("p1")
        // One more note than the bound allows.
        open.opened("fresh")

        #expect(open.ids.contains("p1"),
                "the oldest ROW survives, because she keeps opening it")
        #expect(!open.ids.contains("p2"),
                "the least-recently-opened note is the one that leaves")
        #expect(open.ids.count == OpenNotes.trackedCap)
        #expect(open.recency.count == OpenNotes.trackedCap, "both lists shed it")
        // And it left the ORDER without disturbing anything around it.
        #expect(open.ids.first == "p1")
        #expect(open.ids.last == "fresh", "the new note is still at the END")
    }

    /// Her ruling's second half — the manual reorder, in the `onMove`
    /// convention (`destination` is a PRE-move index). This is the move
    /// arithmetic only. (VX-288, the VX-283 run: the List this comment once
    /// named is long gone — the Open list is a flat column whose rows drag
    /// with the system drag, and WHICH gap a drop names — the half of the row
    /// under the pointer — is `SidebarLayout.OpenListDrop`, pinned in
    /// `OpenListDragTests`.)
    @Test func theManualReorderMovesRowsAndTheKeysFollowThem() {
        var open = OpenNotes()
        for id in ["a", "b", "c", "d"] { open.opened(id) }

        // Drag "d" to the front.
        open.move(fromOffsets: IndexSet(integer: 3), toOffset: 0)
        #expect(open.ids == ["d", "a", "b", "c"])
        #expect(open.id(atOrdinal: 1) == "d", "⌘⇧1 follows the row she dragged")

        // Downward: a pre-move destination PAST the moved row lands it
        // after the rows it passed (the convention's shift).
        open.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)
        #expect(open.ids == ["a", "b", "d", "c"])

        // A multi-row drag keeps the moved rows' relative order.
        open.move(fromOffsets: IndexSet([0, 2]), toOffset: 4)
        #expect(open.ids == ["b", "c", "a", "d"])

        // Reordering is NOT using a note: recency is untouched, so the
        // bound still falls where it fell before.
        #expect(open.recency == ["d", "c", "b", "a"])

        // Out-of-range asks are inert rather than crashing or clamping
        // into a surprise.
        let before = open.ids
        open.move(fromOffsets: IndexSet(integer: 99), toOffset: 0)
        open.move(fromOffsets: IndexSet(integer: 0), toOffset: 99)
        #expect(open.ids == before)
    }

    /// The reorder's reach covers the WHOLE strip — since Act 10 item 9
    /// every open note is a shown row, so every row can be dragged; only an
    /// offset past the list itself is inert.
    @Test func theReorderCoversEveryOpenRow() {
        var open = OpenNotes()
        for i in 1...OpenNotes.trackedCap { open.opened("p\(i)") }
        let before = open.ids
        // Past the whole list: inert, never a clamp into a surprise.
        open.move(fromOffsets: IndexSet(integer: OpenNotes.trackedCap), toOffset: 0)
        #expect(open.ids == before, "an offset past the list is inert")

        // The LAST row drags to the front — under the old prefix window
        // this row was unreachable; now every row is on the strip.
        open.move(fromOffsets: IndexSet(integer: OpenNotes.trackedCap - 1), toOffset: 0)
        #expect(open.ids.first == "p\(OpenNotes.trackedCap)")
        #expect(open.shown.first == open.ids.first)
    }
}

// MARK: - The names (the chip's and the strip's words)

@Suite("Workspace naming (13f batch 3)")
struct WorkspaceNamingTests {
    @Test func everyDestinationKindNamesItself() {
        let titles = [
            "p1": "The Long Way Home", "b1": "Field Notes",
            "t1": "life/goals", "pool1": "Scraps", "blank": "",
        ]
        // 13i-d U1 (an honest edit — her §7 ruling renamed the section).
        #expect(WorkspaceNaming.label(for: .shelf, titles: titles) == "Bookcase")
        #expect(WorkspaceNaming.label(for: .library, titles: titles) == "Library")
        #expect(WorkspaceNaming.label(for: .poolPosts, titles: titles) == "Pool")
        #expect(WorkspaceNaming.label(for: .blocks, titles: titles) == "Snippets")
        // The recovery surface reads its ONE name (13f W10a's RecoveryPath)
        // — copy that invented a second word would send her to a door that
        // does not exist.
        #expect(WorkspaceNaming.label(for: .recovery, titles: titles)
                == RecoveryPath.menuLabel)
        #expect(WorkspaceNaming.label(for: .post("p1"), titles: titles) == "The Long Way Home")
        #expect(WorkspaceNaming.label(for: .reading("b1"), titles: titles) == "Field Notes")
        #expect(WorkspaceNaming.label(for: .tag("t1"), titles: titles) == "life/goals")
        #expect(WorkspaceNaming.label(for: .pool("pool1"), titles: titles) == "Scraps")
    }

    @Test func anUnresolvedOrEmptyNameStillReadsAsWhatItIs() {
        #expect(WorkspaceNaming.label(for: .post("missing"), titles: [:]) == "Untitled")
        #expect(WorkspaceNaming.label(for: .reading("missing"), titles: [:]) == "Book")
        #expect(WorkspaceNaming.label(for: .tag("missing"), titles: [:]) == "Tag")
        // An empty stored title is not a name — the app's shipped reading.
        #expect(WorkspaceNaming.label(for: .post("p"), titles: ["p": ""]) == "Untitled")
    }

    /// **13k K11:** the spelled-out chip label (`backLabel`) retired with
    /// the bar's old presentation — the arrow IS the door now — so the
    /// origin's name moved into the help, and the forward door gained its
    /// mirror. Both say why they are grey when they are, in the registry's
    /// own words.
    @Test func theTwoNavigationDoorsSpeakAndSayWhyTheyAreGrey() {
        #expect(WorkspaceNaming.backHelp(origin: "Field Notes")
                == "Back to Field Notes (\u{2325}\u{2318}[)")  // ⌥⌘[ since 13u4 S1 (#130): ⌘[ outdents; the help READS the declared chord
        #expect(WorkspaceNaming.forwardHelp(destination: "Orbit")
                == "Forward to Orbit (\u{2325}\u{2318}])")  // ⌥⌘] — the mirror
        #expect(WorkspaceNaming.backHelp(origin: nil)
                == "Nothing to go back to — this is where you started")
        #expect(WorkspaceNaming.forwardHelp(destination: nil)
                == "Nothing to go forward to — you haven't gone back")
        // The greys say what the registry says (one voice, two surfaces).
        #expect(CapabilityRegistry.capability(.navigateBack).unavailableNote
                == WorkspaceNaming.backHelp(origin: nil) + ".")
        #expect(CapabilityRegistry.capability(.navigateForward).unavailableNote
                == WorkspaceNaming.forwardHelp(destination: nil) + ".")
    }
}

// MARK: - The model (recording + the free-tiling rider)

@MainActor
@Suite("Workspace model (13f batch 3)")
struct WorkspaceModelTests {
    @Test func arrivingRecordsBothTheTrailAndTheStrip() {
        let workspace = WorkspaceModel()
        workspace.visit(.shelf)
        workspace.visit(.reading("book"))
        workspace.visit(.post("p1"))

        #expect(workspace.history().origin == .reading("book"))
        #expect(workspace.openNotes.ids == ["p1"], "only NOTES join the Open strip")
        workspace.visit(.post("p2"))
        // Insertion order since her round-7 ruling (batch 3 read ["p2","p1"]).
        #expect(workspace.openNotes.ids == ["p1", "p2"])
        // A book, a folder and the shelf are destinations, never rows.
        #expect(!workspace.openNotes.ids.contains("book"))
    }

    @Test func walkingBackDoesNotPushAgainWhenTheShellReportsTheArrival() {
        let workspace = WorkspaceModel()
        workspace.visit(.shelf)
        workspace.visit(.post("p1"))

        let destination = workspace.goBack()
        #expect(destination == .shelf)
        // The shell now sets its selection, which reports the arrival back
        // here — the end-to-end idempotence claim.
        workspace.visit(.shelf)
        #expect(workspace.history().canGoForward, "the forward future survived the report")
        #expect(workspace.goForward() == .post("p1"))
    }

    /// **A RULED FLIP** (round 7.1). Batch 3's pin here was
    /// `returningToANoteMovesItToTheFrontOfTheStrip`; her ruling is that it
    /// must NOT move. Arriving is still opening — the note is still touched
    /// for the bound's sake — but the strip holds still under her.
    @Test func returningToANoteLeavesTheStripsOrderExactlyWhereItWas() {
        let workspace = WorkspaceModel()
        workspace.visit(.post("p1"))
        workspace.visit(.post("p2"))
        #expect(workspace.openNotes.ids == ["p1", "p2"])
        _ = workspace.goBack()
        workspace.visit(.post("p1"))  // the shell's report of the walk back
        #expect(workspace.openNotes.ids == ["p1", "p2"],
                "the rows do not shuffle — her ruled flip")
        #expect(workspace.openNotes.recency.first == "p1",
                "arriving IS opening, however you got there — for the BOUND")
    }

    /// The reorder reaches the strip through the model (the Open list's
    /// drop calls exactly this — VX-288; there is no `onMove` any more).
    @Test func theModelPassesAManualReorderThrough() {
        let workspace = WorkspaceModel()
        workspace.visit(.post("p1"))
        workspace.visit(.post("p2"))
        workspace.visit(.post("p3"))
        workspace.moveOpenNotes(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        #expect(workspace.openNotes.ids == ["p3", "p1", "p2"])
    }

    /// THE FREE-TILING RIDER (her ruling, round 2: *"make sure the
    /// architecture isn't going down a road closed to [free tiling]"*).
    /// Today one pane exists; the key exists anyway, and two panes'
    /// histories are already independent.
    @Test func historiesAreKeyedByPaneAndDoNotBleed() {
        let workspace = WorkspaceModel()
        let second = PaneID("second")
        workspace.visit(.shelf)
        workspace.visit(.post("p1"))
        workspace.visit(.reading("book"), in: second)
        workspace.visit(.post("p2"), in: second)

        #expect(workspace.history().origin == .shelf)
        #expect(workspace.history(second).origin == .reading("book"))
        #expect(workspace.goBack(in: second) == .reading("book"))
        #expect(workspace.history().current == .post("p1"),
                "the primary pane never moved")
        // The strip is the WINDOW's, not a pane's — both panes' notes are
        // open notes.
        #expect(Set(workspace.openNotes.ids) == ["p1", "p2"])
    }

    /// **13k K11 retired the whole-bar collapse** — and this pin with it.
    /// The workspace no longer holds a `contextBarCollapsed` (13f's session
    /// state) and 13g's WT-2 born-collapsed default is gone: her ruling
    /// made the bar a constant icon row (*"the collapsing and growing in
    /// that bar is a little annoying to me"*). The one surviving fold is
    /// the tag cards', which is a STICKY this-Mac preference rather than
    /// window state — pinned in `ContextBarShapeTests`.
    ///
    /// What this test now holds is the part of the old claim that survives:
    /// a fresh workspace carries no navigation state at all.
    @Test func aFreshWorkspaceHasNothingToGoBackTo() {
        let workspace = WorkspaceModel()
        #expect(!workspace.history().canGoBack)
        #expect(!workspace.history().canGoForward)
        #expect(workspace.history().origin == nil)
        #expect(workspace.history().next == nil)
    }

    /// Her guarantee, at the layer that could break it: closing a row is
    /// PURE VIEW STATE. The note stays live in the store and opens straight
    /// back.
    @Test func closingARowNeverTouchesTheStore() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "Keep me")
            }
            let workspace = WorkspaceModel()
            workspace.visit(.post(post.id))
            #expect(workspace.openNotes.ids == [post.id])

            workspace.closeNote(post.id)
            #expect(workspace.openNotes.ids.isEmpty)

            let live = try await db.read { db in
                try Queries.containerHeader(db, containerID: post.id)
            }
            #expect(live?.title == "Keep me", "closing a ROW deletes nothing")
        }
    }

    @Test func titlesResolveForEveryKindOnScreen() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (post, book) = try await session.runner.run { ops in
                (try ops.createPost(title: "The Long Way Home"),
                 try ops.createReading(name: "Field Notes", kind: .book))
            }
            let workspace = WorkspaceModel()
            workspace.visit(.reading(book.id))
            workspace.visit(.post(post.id))
            await workspace.resolveTitles(session: session)

            #expect(workspace.label(for: .post(post.id)) == "The Long Way Home")
            #expect(workspace.label(for: .reading(book.id)) == "Field Notes",
                    "the chip names the book she came from")
        }
    }

    /// **Row 18 — "renaming a note won't rename it on the sidebar until you
    /// click on something else."** `resolveTitles` was a ONE-SHOT read keyed
    /// on `titleSubjectsKey`, which changes only when the SET of things on
    /// screen (or its order) changes — so a rename of a note already in the
    /// strip changed no key and the strip kept the old name until the next
    /// navigation. §4.3's one fix: the same fetch, held as a bounded
    /// observation, so the write itself moves the name.
    ///
    /// The pin renames through the ordinary operation with the strip's task
    /// running, and waits for the map — no click, no re-visit. RED ON OLD:
    /// the label stays at the old title until `resolveTitles` is called again
    /// by hand.
    @Test func renamingANoteMovesTheOpenStripsNameWithNoClick() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (post, book) = try await session.runner.run { ops in
                (try ops.createPost(title: "The Long Way Home"),
                 try ops.createReading(name: "Field Notes", kind: .book))
            }
            let workspace = WorkspaceModel()
            workspace.visit(.reading(book.id))
            workspace.visit(.post(post.id))

            let watching = Task { await workspace.observeTitles(session: session) }
            defer { watching.cancel() }
            await poll { workspace.label(for: .post(post.id)) == "The Long Way Home" }
            #expect(workspace.label(for: .post(post.id)) == "The Long Way Home")

            try await session.runner.run { [id = post.id] ops in
                try ops.renameContainer(id, title: "The Boscombe Valley Mystery")
            }
            await poll { workspace.label(for: .post(post.id)) == "The Boscombe Valley Mystery" }
            #expect(workspace.label(for: .post(post.id)) == "The Boscombe Valley Mystery",
                    "the write moved the name, with nothing clicked")

            // A note whose title is CLEARED falls back to its date, from the
            // one display brain — the derived half of the same read.
            try await session.runner.run { [id = post.id] ops in
                try ops.renameContainer(id, title: nil)
                try ops.setEntryDate(id, entryDate: "2026-03-04")
            }
            let dated = try await db.read { [id = post.id] in
                try Queries.noteDisplayTitle($0, id: id)
            } ?? ""
            await poll { workspace.label(for: .post(post.id)) == dated }
            #expect(workspace.label(for: .post(post.id)) == dated,
                    "and a DATE change moves it too — the strip's row 19")

            // A book renamed beside it moves the same way (one observation,
            // every kind on screen — the fix is not note-only by accident).
            try await session.runner.run { [id = book.id] ops in
                try ops.renameReading(id, name: "Case Notes")
            }
            await poll { workspace.label(for: .reading(book.id)) == "Case Notes" }
            #expect(workspace.label(for: .reading(book.id)) == "Case Notes")
        }
    }
}

@MainActor
private func poll(
    _ predicate: @MainActor () -> Bool, timeout: TimeInterval = 5
) async {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate(), Date() < deadline {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }
}

// MARK: - The doors (registry + shell routing)

@MainActor
@Suite("The navigation doors (13f batch 3)")
struct NavigationDoorsTests {
    /// THE COLLISION SWEEP, MADE PERMANENT (the 13d A14 precedent). The
    /// sweep found ⌘[ and ⌘] free across `keyEquivalent`, every
    /// `.keyboardShortcut(` call site in `Variorum/`+`Shared/`, every
    /// `NSMenuItem` key equivalent, and the one `performKeyEquivalent`
    /// override (⌘S). This keeps the ONE table where keys are declared free
    /// of duplicates for good — including the next chord anyone adds.
    @Test func theKeyTableHasNoCollisionsAndTheNavigationKeysAreOurs() {
        var owners: [String: CapabilityID] = [:]
        for capability in CapabilityRegistry.all {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: capability.id)
            else { continue }
            let chord = "\(key.character)|\(modifiers.rawValue)"
            #expect(owners[chord] == nil,
                    "\(capability.id) collides with \(owners[chord]?.rawValue ?? "") on \(chord)")
            owners[chord] = capability.id
        }
        // 13u4 S1 (#130, PROVISIONAL): ⌘[ / ⌘] are OUTDENT / INDENT (the text-editor
        // convention, Apple Notes' own resolution); back/forward moved to ⌥⌘[ / ⌥⌘].
        // These pins were rewritten to that ruling at the 13u4 closeout — the ruled-change
        // class, no red-on-old owed (they asserted the superseded 13f assignment).
        let optionCommand = EventModifiers([.command, .option]).rawValue
        #expect(owners["[|\(EventModifiers.command.rawValue)"] == .formatOutdent)
        #expect(owners["]|\(EventModifiers.command.rawValue)"] == .formatIndent)
        #expect(owners["[|\(optionCommand)"] == .navigateBack)
        #expect(owners["]|\(optionCommand)"] == .navigateForward)
        // The ordinal families wire per index in the menu, never here — so
        // no ⌘⇧<digit> may appear in this table at all.
        let shiftCommand = EventModifiers([.command, .shift]).rawValue
        for digit in 1...9 {
            #expect(owners["\(digit)|\(shiftCommand)"] == nil,
                    "⌘⇧\(digit) belongs to the Open strip's per-ordinal wiring")
        }
        #expect(EditorCommands.keyEquivalent(for: .openNote) == nil,
                "the family declares one label and wires a key per row")
    }

    @Test func theNavigationDoorsAreDeclaredAndRendered() {
        let openNote = CapabilityRegistry.capability(.openNote)
        #expect(openNote.scope == .app, "a workspace act — no surface is behind another")
        #expect(openNote.shortcutLabel == "\u{2318}\u{21e7}1\u{2013}9")
        // **13k K11 UPDATED THIS EXPECTATION, deliberately and on the
        // record:** back and forward gained a `.surface` door — the context
        // bar's ← and →. The claim itself is unchanged (every one of these
        // is a declared menu item); what changed is that two of them are now
        // ALSO rendered on a surface, and the walk
        // (`theSurfacesRenderExactlyTheDeclaredSurfaceActs`) is what holds
        // that half.
        #expect(openNote.doors == [.menuBar])
        for id in [CapabilityID.openNote, .navigateBack, .navigateForward] {
            #expect(CapabilityRegistry.capability(id).doors.contains(.menuBar))
            #expect(EditorCommands.menuRendered.contains(id), "every shortcut is a menu item")
        }
        for id in [CapabilityID.navigateBack, .navigateForward] {
            #expect(CapabilityRegistry.capability(id).doors == [.menuBar, .surface])
            #expect(ContextBar.surfaceCapabilities.contains(id), "the bar's own icon")
        }
        // W16's Compare half: a surface door on the peer column.
        #expect(CapabilityRegistry.capability(.openPeerPost).doors == [.surface])
        #expect(CompareBoardView.surfaceCapabilities.contains(.openPeerPost))
    }

    @Test func theNavigationDoorsAreGreyWhereTheyCannotAct() {
        let empty = CapabilityContext(mode: nil)
        for id in [CapabilityID.openNote, .navigateBack, .navigateForward] {
            #expect(!CapabilityRegistry.isEnabled(id, in: empty),
                    "\(id): a key that could only be dead is grey instead")
            #expect(!CapabilityRegistry.capability(id).unavailableNote.isEmpty,
                    "\(id) says why")
        }
        #expect(CapabilityRegistry.isEnabled(
            .openNote, in: CapabilityContext(mode: nil, openNoteCount: 1)))
        #expect(CapabilityRegistry.isEnabled(
            .navigateBack, in: CapabilityContext(mode: nil, canNavigateBack: true)))
        #expect(CapabilityRegistry.isEnabled(
            .navigateForward, in: CapabilityContext(mode: nil, canNavigateForward: true)))
        // Compare's peer door exists exactly where a peer column does.
        #expect(CapabilityRegistry.isEnabled(
            .openPeerPost, in: CapabilityContext(mode: .compare)))
        #expect(!CapabilityRegistry.isEnabled(
            .openPeerPost, in: CapabilityContext(mode: .write, writeEditorAttached: true)))
    }

    /// The shell's doors: every one of them names a DESTINATION and hands
    /// it to the router, which is what RootView adopts (P-4). Nothing here
    /// navigates itself.
    @Test func theShellDoorsRouteTheRightDestination() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        router.workspace.visit(.reading("book"))
        router.workspace.visit(.post("p1"))

        router.goBack()
        #expect(router.pendingSelection == .reading("book"))
        router.pendingSelection = nil  // RootView consumes it
        router.workspace.visit(.reading("book"))

        router.goForward()
        #expect(router.pendingSelection == .post("p1"))
        router.pendingSelection = nil
        router.workspace.visit(.post("p1"))

        router.workspace.visit(.post("p2"))
        // p1 was opened first, so it keeps ⌘⇧1 and p2 takes ⌘⇧2 (batch 3's
        // pin read the other way — the ruled insertion-order flip, 7.1).
        router.openNote(ordinal: 2)
        #expect(router.pendingSelection == .post("p2"), "⌘⇧2 = the second SHOWN row")
        router.pendingSelection = nil
        router.openNote(ordinal: 1)
        #expect(router.pendingSelection == .post("p1"),
                "and ⌘⇧1 still addresses the note it addressed before p2 opened")
        router.pendingSelection = nil
        router.openNote(ordinal: 7)
        #expect(router.pendingSelection == nil, "a key past the strip does nothing")
    }

    /// The two halves that live in the VIEW and could not be caught by any
    /// pure pin: the registry context is wired to THIS window's workspace,
    /// and the pane's history is SEEDED with what the window already shows.
    ///
    /// Both are load-bearing and both fail silently. Unseeded, the very
    /// first navigation out of the shelf pushes nothing — the first back
    /// chip she could ever want is the one that never appears. Unwired, the
    /// menu's Back/Forward/Open Notes stay grey forever, because the
    /// router's defaults answer "no" to everything.
    @Test func mountingTheShellWiresTheContextAndSeedsThePane() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            // Pre-fix defaults, stated so the assertions below discriminate.
            #expect(session.commandRouter.openNoteCount() == 0)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<200 where router.workspace.history().current == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }

            #expect(router.workspace.history().current == .shelf,
                    "the pane's history knows what it is already showing")
            router.workspace.visit(.post("p1"))
            #expect(session.commandRouter.openNoteCount() == 1,
                    "the registry context reads THIS window's workspace")
            #expect(session.commandRouter.canNavigateBack(),
                    "…and its pane's trail — the shelf is behind us")
            #expect(!session.commandRouter.canNavigateForward())
        }
    }

    @Test func aPaneWithNowhereToGoAsksForNothing() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        router.goBack()
        router.goForward()
        #expect(router.pendingSelection == nil,
                "the doors are grey here; a race must not navigate anyway")
    }
}
