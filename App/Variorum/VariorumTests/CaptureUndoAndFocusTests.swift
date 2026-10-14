//
//  CaptureUndoAndFocusTests.swift
//  VariorumTests
//
//  VX-282 U4 — THE CAPTURE BOX'S TWO MEMBERS (`Core/Views/CaptureTextView
//  .swift`, the ONE box both capture doors compose: the Bookcase's and the
//  Library's quick-entry bar, and the quick-note pad). The binding record
//  is `notes/plans/fixes/vx-282-editor-notes-fixes.md` § U4.
//
//  VX-193 — LEAD: THE SIBLING, the defect that is real in use. The box's
//  typing history lived in the WINDOW's undo manager and survived a
//  programmatic clear, so ⌘Z after an EMPTY filing (three spaces and ⏎ — the
//  box clears and keeps the caret) replayed ranges of the old text against
//  the new one: `NSRangeException` from `NSUndoTyping undoRedo:`, reproduced
//  in use on the pre-fix build at the U4 walk (AppKit caught it; the box's
//  undo was dead afterwards). Fixed: the box owns its history and a
//  programmatic replacement ends it.
//
//  VX-193 — THE TICKET'S HEADLINE (⌘Z leaves the binding stale, ⏎ files the
//  undone words): NOT REPRODUCED IN USE. On the pre-fix build in the running
//  app a real ⌘Z / ⇧⌘Z kept the binding in step (the U4 walk). The desync
//  exists only where undo is driven OUTSIDE the live event road — this test
//  host (whose windows are never key: `WindowsTests`' header), VX-179's
//  offscreen probe, U4's windowless probes — where AppKit posts no
//  `textDidChange` for an undo or a redo (measured; why the live road differs
//  did not converge headlessly). The box keeps its did-undo/did-redo re-sync
//  as a BELT — VX-179's comments panel carries the same pair on the same
//  basis — and the cells below that drive undo through `undo:`/`redo:` here
//  are GUARDS OF THAT BELT on the programmatic-undo road, not pins of a
//  symptom she can meet.
//
//  VX-112 — THE FOCUS RE-GRAB. The box's initial focus request ("asked
//  ONCE, on arrival") was never cleared, so a box made with one re-claimed
//  the keyboard on EVERY re-attach — after a release, and over any other
//  responder; and a box whose caret came by a counted request (the bar's)
//  lost the keyboard silently when SwiftUI detached and re-attached it
//  (TEXTKIT2 §3, 18l-c U7). Her rule, recorded at this run's kickoff: the
//  shared box re-takes only focus it HELD, never steals — `PaneTextView`'s
//  rule (`PaneFindFaceTests` pins it four ways for the pane; these pin it for
//  the box).
//
//  Every RED-ON-OLD cell below names itself; the rest are guards. The old
//  product is the build of the commit that added this file (the pins land
//  ahead of the fix).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Shared rig

@MainActor
private enum CaptureRig {
    static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// Lets main-queue turns PASS: the box defers its initial focus and its
    /// caret reports by one turn, the hosts file inside a `Task`, and a
    /// nested run loop does not drain main-queue blocks while an async test
    /// body is itself one (VX-179 U3's FIX LEG) — so each turn also suspends.
    static func settle(
        _ window: NSWindow, turns: Int = 12, until predicate: () -> Bool = { false }
    ) async {
        for _ in 0..<turns {
            window.contentView?.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    static func box(in view: NSView) -> CaptureNSTextView? {
        if let found = view as? CaptureNSTextView { return found }
        for sub in view.subviews {
            if let found = box(in: sub) { return found }
        }
        return nil
    }

    /// A real window — the keyboard is a window's — holding the host and a
    /// stand-in for ANOTHER responder (a field, a sheet's control).
    static func window(hosting: NSView, size: NSSize) -> (NSWindow, NSTextField) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: size.width, height: size.height + 40),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height + 40))
        hosting.frame = NSRect(x: 0, y: 40, width: size.width, height: size.height)
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        return (window, field)
    }

    static func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.contentView = nil
        window.close()
    }

    /// The hosting view carrying the box — detached and re-attached the way
    /// SwiftUI moves a representable's view (`PaneFindFaceTests.reparent`).
    static func reparent(_ window: NSWindow, between: () -> Void = {}) throws {
        let content = try #require(window.contentView)
        let host = try #require(content.subviews.first { !($0 is NSTextField) })
        host.removeFromSuperview()
        between()
        content.addSubview(host)
    }

    /// Typing, ONE UNDO STEP PER CALL — made explicit. This host dispatches no
    /// events, so an undo manager's by-event groups never close between two
    /// calls and both chunks would undo together (the u4 window's W1/W2 found
    /// exactly that: ⌘Z emptied the box). Each chunk is its own group here,
    /// opened and closed around the real `insertText`, with by-event grouping
    /// restored at once (probed headlessly on the box's own manager and on a
    /// window's: two steps, the redo restoring the first chunk), and typing
    /// coalescing broken after it so the next chunk is a new typing action.
    static func type(_ text: String, into box: NSTextView, window: NSWindow) async {
        let history = box.undoManager
        history?.groupsByEvent = false
        history?.beginUndoGrouping()
        box.insertText(text, replacementRange: box.selectedRange())
        history?.endUndoGrouping()
        history?.groupsByEvent = true
        box.breakUndoCoalescing()
        await settle(window, turns: 3)
    }

    /// ⌘Z and ⇧⌘Z by the PROGRAMMATIC road: the action sent up the responder
    /// chain from the box to the window, which undoes through the first
    /// responder's undo manager. Not the live keyboard road (this host has no
    /// key window — `WindowsTests`' header) — the road on which AppKit posts
    /// no `textDidChange`, i.e. the belt's road.
    static func undo(_ box: NSTextView, window: NSWindow) async {
        _ = box.tryToPerform(Selector(("undo:")), with: nil)
        await settle(window, turns: 3)
    }

    static func redo(_ box: NSTextView, window: NSWindow) async {
        _ = box.tryToPerform(Selector(("redo:")), with: nil)
        await settle(window, turns: 3)
    }
}

/// A host for the bare box: the binding a capture door files, and its
/// counted focus request (`QuickNoteView` starts at 1, `QuickEntryBar` at 0
/// and raises it once the box is up).
@MainActor
@Observable
private final class BoxRig {
    var text = ""
    var focusRequest: Int

    init(focusRequest: Int) { self.focusRequest = focusRequest }
}

private struct BoxRigView: View {
    @Bindable var rig: BoxRig

    var body: some View {
        CaptureTextView(
            text: $rig.text, style: CaptureTextStyle(tokens: .terminalLight),
            maxHeight: 160, focusRequest: rig.focusRequest, onFile: {})
            .frame(width: 400, height: 60)
    }
}

@MainActor
private func mountBox(focusRequest: Int) async throws -> (NSWindow, CaptureNSTextView, NSTextField, BoxRig) {
    let rig = BoxRig(focusRequest: focusRequest)
    let hosting = NSHostingView(rootView: BoxRigView(rig: rig))
    let (window, field) = CaptureRig.window(hosting: hosting, size: NSSize(width: 420, height: 80))
    await CaptureRig.settle(window, turns: 15) { CaptureRig.box(in: hosting) != nil }
    let box = try #require(CaptureRig.box(in: hosting), "the box mounted")
    return (window, box, field, rig)
}

/// What the bar's ⏎ opened (its `onOpen`).
@MainActor
private final class OpenedNote {
    var postID: String?
}

@MainActor
private func withCaptureWorld<T>(
    seed: UInt64, _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - VX-193's sibling — the box owns its history (the defect real in use)

@MainActor
@Suite("VX-193's sibling — the capture box owns its undo history, and a programmatic clear ends it",
       .serialized)
struct CaptureUndoHistoryTests {
    /// **RED ON OLD** (the identity cell and the `#require` — which stops the
    /// old tree BEFORE its ⌘Z, the one that raised `NSRangeException` there):
    /// the host clears the box programmatically (an EMPTY filing — a
    /// whitespace-only or tokens-only capture keeps the box on screen with the
    /// caret in it), and the box's history ends with the words it described.
    /// The history is the box's OWN, never the window's (P-VX179-U3-4,
    /// carried: undo is per area — P-U4-1).
    @Test func aProgrammaticClearEndsTheBoxsOwnHistory() async throws {
        let (window, box, _, rig) = try await mountBox(focusRequest: 0)
        defer { CaptureRig.close(window) }
        window.makeFirstResponder(box)
        await CaptureRig.type("   ", into: box, window: window)
        #expect(box.undoManager?.canUndo == true, "her typing is undoable while it is in the box")
        #expect(box.undoManager !== window.undoManager,
                "the box's history is its own — never the window's, which other text shares")

        rig.text = ""  // the host's clear (`QuickEntryModel.submit`'s empty branch)
        await CaptureRig.settle(window, turns: 4)
        #expect(box.string.isEmpty)
        try #require(box.undoManager?.canUndo == false,
                     "the words left the box — there is nothing in it to undo into")

        await CaptureRig.undo(box, window: window)
        #expect(box.string.isEmpty && rig.text.isEmpty, "⌘Z after the clear changes nothing")

        // The history starts over with her next words.
        await CaptureRig.type("new", into: box, window: window)
        await CaptureRig.undo(box, window: window)
        #expect(box.string.isEmpty, "the new words undo alone")
    }

    /// **RED ON OLD (the `#require` — it stops the old tree before the ⌘Z
    /// that raised there)**: an EMPTY filing — three spaces and ⏎ — clears the
    /// box programmatically and leaves it on screen with the caret in it (the
    /// bar stays on the Bookcase; the pad stays open on `.nothingToFile`). The
    /// box's history ends with the words it described. The U4 walk reproduced
    /// the old tree's exception IN USE (the bar: three spaces, ⏎, a real ⌘Z —
    /// `NSRangeException` from `NSUndoTyping undoRedo:`, undo dead after).
    @Test func anEmptyFilingLeavesNothingToUndoIntoInEitherHost() async throws {
        try await withCaptureWorld(seed: 47) { session, db in
            let bar = NSHostingView(rootView: QuickEntryBar(session: session, onOpen: { _ in }))
            let pad = NSHostingView(rootView: QuickNoteView(
                session: session, windows: WindowRegistry()))
            for (hosting, size) in [(bar as NSView, NSSize(width: 600, height: 160)),
                                    (pad as NSView, NSSize(width: 360, height: 260))] {
                let (window, _) = CaptureRig.window(hosting: hosting, size: size)
                defer { CaptureRig.close(window) }
                await CaptureRig.settle(window, turns: 15) { CaptureRig.box(in: hosting) != nil }
                let box = try #require(CaptureRig.box(in: hosting))
                window.makeFirstResponder(box)
                await CaptureRig.type("   ", into: box, window: window)

                box.keyDown(with: CaptureKeysTests.returnEvent(windowNumber: window.windowNumber))
                await CaptureRig.settle(window, turns: 40) { box.string.isEmpty }
                #expect(box.string.isEmpty, "an empty filing clears the box")
                #expect(box.window === window, "…and leaves it on screen")
                try #require(box.undoManager?.canUndo == false,
                             "nothing is left to undo into after the clear")
                await CaptureRig.undo(box, window: window)
                #expect(box.string.isEmpty, "⌘Z after the clear brings nothing back")
            }
            #expect(try await CaptureStore.livePostIDs(db).isEmpty, "nothing was filed by either door")
        }
    }
}

/// The store reads the host cells share.
@MainActor
private enum CaptureStore {
    static func blocks(_ db: AppDatabase, _ postID: String) async throws -> [String] {
        try await db.read { try Queries.renderPost($0, containerID: postID) }
            .compactMap(\.text)
    }

    static func livePostIDs(_ db: AppDatabase) async throws -> [String] {
        try await db.read {
            try String.fetchAll(
                $0, sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL")
        }
    }
}

// MARK: - VX-193's belt — the programmatic-undo road (NOT the live road)

@MainActor
@Suite("VX-193's belt — on the programmatic-undo road the capture box's binding follows ⌘Z and ⇧⌘Z",
       .serialized)
struct CaptureUndoSyncTests {
    /// **A GUARD OF THE BELT, red on old ON THIS ROAD (each binding cell).**
    /// Undo and redo driven by `undo:`/`redo:` in this host move the box's
    /// text with NO `textDidChange` (measured), so without the box's
    /// did-undo/did-redo re-sync the binding stays on the last TYPED text.
    /// In USE — a real ⌘Z/⇧⌘Z in the running app — the pre-fix build's binding
    /// followed (the U4 walk): this pins the belt, not a symptom she can meet.
    @Test func aProgrammaticUndoAndRedoReachTheBinding() async throws {
        let (window, box, _, rig) = try await mountBox(focusRequest: 0)
        defer { CaptureRig.close(window) }
        window.makeFirstResponder(box)
        await CaptureRig.type("first thought", into: box, window: window)
        await CaptureRig.type(" and more", into: box, window: window)
        #expect(rig.text == "first thought and more", "typing reaches the binding (as ever)")

        await CaptureRig.undo(box, window: window)
        #expect(box.string == "first thought", "non-vacuity: ⌘Z undid the last words")
        #expect(rig.text == box.string, "the binding follows the undo")

        await CaptureRig.undo(box, window: window)
        #expect(box.string.isEmpty, "non-vacuity: …and the first ones")
        #expect(rig.text == box.string, "…all the way back to empty")

        await CaptureRig.redo(box, window: window)
        #expect(box.string == "first thought", "non-vacuity: ⇧⌘Z brought the first words back")
        #expect(rig.text == box.string, "…and the binding follows the redo")
    }
}

// MARK: - VX-193's belt in both hosts — what ⏎ FILES after a programmatic ⌘Z

@MainActor
@Suite("VX-193's belt in both hosts — ⏎ files what the capture box shows after a programmatic ⌘Z",
       .serialized)
struct CaptureHostsUndoFilingTests {
    /// The two gestures: ⌘Z, and ⌘Z ⌘Z ⇧⌘Z. Either way the box shows the
    /// FIRST words, and that is what must file.
    enum Gesture: String, CaseIterable, Sendable {
        case undo
        case undoTwiceThenRedo
    }

    private static let first = "alpha"
    private static let second = " beta"

    private func perform(_ gesture: Gesture, on box: NSTextView, window: NSWindow) async {
        await CaptureRig.type(Self.first, into: box, window: window)
        await CaptureRig.type(Self.second, into: box, window: window)
        switch gesture {
        case .undo:
            await CaptureRig.undo(box, window: window)
        case .undoTwiceThenRedo:
            await CaptureRig.undo(box, window: window)
            await CaptureRig.undo(box, window: window)
            await CaptureRig.redo(box, window: window)
        }
    }

    /// **A GUARD OF THE BELT, red on old ON THIS ROAD — the bar filed "alpha
    /// beta"** while the box showed "alpha", because ⏎ files the binding
    /// (`QuickEntryModel.submit`) and, on this road, the binding never heard
    /// the ⌘Z. (In use the pre-fix bar's binding followed — the U4 walk.)
    @Test(arguments: Gesture.allCases)
    func theBarFilesWhatTheBoxShows(_ gesture: Gesture) async throws {
        try await withCaptureWorld(seed: 41) { session, db in
            let opened = OpenedNote()
            let hosting = NSHostingView(rootView: QuickEntryBar(
                session: session,
                onOpen: { selection in
                    if case .post(let id) = selection { opened.postID = id }
                }))
            let (window, _) = CaptureRig.window(hosting: hosting, size: NSSize(width: 600, height: 160))
            defer { CaptureRig.close(window) }
            await CaptureRig.settle(window, turns: 15) { CaptureRig.box(in: hosting) != nil }
            let box = try #require(CaptureRig.box(in: hosting))
            window.makeFirstResponder(box)

            await perform(gesture, on: box, window: window)
            #expect(box.string == Self.first, "non-vacuity: the box shows the first words")

            box.keyDown(with: CaptureKeysTests.returnEvent(windowNumber: window.windowNumber))
            await CaptureRig.settle(window, turns: 100) { opened.postID != nil }
            let postID = try #require(opened.postID, "⏎ filed and opened a note")
            #expect(try await CaptureStore.blocks(db, postID) == [Self.first],
                    "⏎ files exactly what the box shows")
        }
    }

    /// **A GUARD OF THE BELT, red on old ON THIS ROAD — the pad filed "alpha
    /// beta"** by the same road (`QuickNotePad.take` reads the binding; its
    /// ⌘⏎ button, its close and its quit filing read the same binding).
    @Test(arguments: Gesture.allCases)
    func thePadFilesWhatTheBoxShows(_ gesture: Gesture) async throws {
        try await withCaptureWorld(seed: 43) { session, db in
            let hosting = NSHostingView(rootView: QuickNoteView(
                session: session, windows: WindowRegistry()))
            let (window, _) = CaptureRig.window(hosting: hosting, size: NSSize(width: 360, height: 260))
            defer { CaptureRig.close(window) }
            await CaptureRig.settle(window, turns: 15) { CaptureRig.box(in: hosting) != nil }
            let box = try #require(CaptureRig.box(in: hosting))
            window.makeFirstResponder(box)

            await perform(gesture, on: box, window: window)
            #expect(box.string == Self.first, "non-vacuity: the box shows the first words")

            box.keyDown(with: CaptureKeysTests.returnEvent(windowNumber: window.windowNumber))
            var posts: [String] = []
            for _ in 0..<100 {
                posts = try await CaptureStore.livePostIDs(db)
                if !posts.isEmpty { break }
                await CaptureRig.settle(window, turns: 1)
            }
            let postID = try #require(posts.first, "⏎ filed a note")
            #expect(posts.count == 1, "one summon, one note")
            #expect(try await CaptureStore.blocks(db, postID) == [Self.first],
                    "⏎ files exactly what the box shows")
        }
    }
}

// MARK: - VX-112, the re-attach rule

@MainActor
@Suite("VX-112 — the capture box re-takes only the keyboard it held, never steals", .serialized)
struct CaptureFocusReattachTests {
    /// The two births: `bornAsking` is the pad's (a request at make — 1);
    /// otherwise the bar's (0 at make, raised once the box is up).
    private func mountHolding(bornAsking: Bool) async throws
        -> (NSWindow, CaptureNSTextView, NSTextField, BoxRig)
    {
        let (window, box, field, rig) = try await mountBox(focusRequest: bornAsking ? 1 : 0)
        if !bornAsking {
            rig.focusRequest += 1
        }
        await CaptureRig.settle(window, turns: 15) { window.firstResponder === box }
        return (window, box, field, rig)
    }

    /// GUARD (green both sides): the first-mount autofocus lands where it
    /// does today, by either birth — and a later counted request (her click
    /// on the padding, the title chip) still puts the caret back.
    @Test(arguments: [true, false])
    func theFirstMountAutofocusStillLands(bornAsking: Bool) async throws {
        let (window, box, field, rig) = try await mountHolding(bornAsking: bornAsking)
        defer { CaptureRig.close(window) }
        #expect(window.firstResponder === box, "the box opened with the caret in it")
        window.makeFirstResponder(field)
        rig.focusRequest += 1
        await CaptureRig.settle(window) { window.firstResponder === box }
        #expect(window.firstResponder === box, "an explicit request still takes the caret")
    }

    /// **RED ON OLD for the pad's birth** (`bornAsking: true`): the "asked
    /// ONCE" flag was never cleared, so after a release (the tour's, say) a
    /// detach/re-attach put the caret back. GUARD for the bar's birth (its
    /// flag was never set).
    @Test(arguments: [true, false])
    func aReleasedBoxStaysAwayAcrossAReattach(bornAsking: Bool) async throws {
        let (window, box, _, _) = try await mountHolding(bornAsking: bornAsking)
        defer { CaptureRig.close(window) }
        #expect(window.firstResponder === box, "non-vacuity: the box held the keyboard")
        window.makeFirstResponder(nil)  // the release (the tour's own act)
        await CaptureRig.settle(window, turns: 4)
        #expect(window.firstResponder !== box)

        try CaptureRig.reparent(window)
        await CaptureRig.settle(window)
        #expect(window.firstResponder !== box,
                "released, then re-attached — the box never takes the keyboard back")
    }

    /// **RED ON OLD for the bar's birth** (`bornAsking: false`): AppKit drops
    /// a detached first responder to the window, and nothing re-took it —
    /// the bar's caret was lost silently (TEXTKIT2 §3, 18l-c U7's class).
    /// GUARD for the pad's birth (its never-cleared flag re-grabbed).
    @Test(arguments: [true, false])
    func aBoxThatHeldTheKeyboardKeepsItAcrossAReattach(bornAsking: Bool) async throws {
        let (window, box, _, _) = try await mountHolding(bornAsking: bornAsking)
        defer { CaptureRig.close(window) }
        #expect(window.firstResponder === box, "non-vacuity: the box held the keyboard")
        try CaptureRig.reparent(window) {
            #expect(window.firstResponder === window, "AppKit drops a detached first responder")
        }
        await CaptureRig.settle(window) { window.firstResponder === box }
        #expect(window.firstResponder === box, "re-attached, the box takes back what it held")
    }

    /// **RED ON OLD for the pad's birth** (`bornAsking: true`): the old
    /// arrival claim checked only that the box was not ALREADY first
    /// responder, so it took the keyboard from whatever had it. GUARD for
    /// the bar's birth.
    @Test(arguments: [true, false])
    func aReattachNeverStealsFromAnotherResponder(bornAsking: Bool) async throws {
        let (window, box, field, _) = try await mountHolding(bornAsking: bornAsking)
        defer { CaptureRig.close(window) }
        #expect(window.firstResponder === box, "non-vacuity: the box held the keyboard")
        try CaptureRig.reparent(window) { window.makeFirstResponder(field) }
        await CaptureRig.settle(window)
        #expect(window.firstResponder !== box,
                "another responder took the keyboard meanwhile — the box leaves it there")
    }
}

// MARK: - VX-112, the tour's road (her walk's shape, in the real shell)

@MainActor
@Suite("VX-112 — the tour's steps 1–2 never put the caret back in the quick entry", .serialized)
struct CaptureTourFocusTests {
    /// Her walk's road: the tour started ON the Bookcase (the offer line lives
    /// there), the caret released at the tour's arrival (W-U1a-1), and steps
    /// 1–2 run. RED OR GREEN ON OLD IS THE FINDING: on the static trace
    /// neither candidate fires on this road (the record § U4), so this is
    /// expected GREEN on both sides — a guard — and the walk's sighting is
    /// W3's to decide (the Terminal voice's block cursor, drawn exactly while
    /// the box does NOT hold the caret). A red here on the old product would
    /// mean the harness reproduces a re-grab the trace did not find.
    @Test func stepsOneAndTwoNeverPutTheCaretBackInTheQuickEntry() async throws {
        #if DEBUG
        let suite = "vx112-tour-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        // Two deliberate departures from `TourEntryTests`' world, so the two
        // can never trip over each other inside one test process: no write to
        // the dev app's real defaults (this pin needs no Bookcase row on
        // screen — it never waits on step 2's ring), and RANDOM ids, so the
        // engine `TourOracle` (a process-wide DEBUG slot) reports is told
        // apart from any other suite's by this store's seeded book.
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 53))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let sherlock = try ops.createReading(name: SampleLibrarySeeder.bookName, kind: .book)
            let scandal = try ops.createPost(title: TourScript.firstStoryTitle)
            try ops.addPostToReading(scandal.id, to: sherlock.id)
            _ = try ops.createReading(name: TutorialSeeder.bookName, kind: .book)
            let offer = TourOfferModel(defaults: defaults)
            let router = ShellRouter()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1100, height: 720),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: RootView(
                session: session, router: router, tourOffer: offer))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let inQuickEntry = { window.firstResponder is CaptureNSTextView }
            await CaptureRig.settle(window, turns: 40)
            await CaptureRig.settle(window, turns: 200, until: inQuickEntry)
            #expect(inQuickEntry(), "the precondition: the Bookcase put the caret in its quick entry")

            router.tourRequested = true
            let ours = { TourOracle.overlay?.state.seededBookID == sherlock.id }
            await CaptureRig.settle(window, turns: 200, until: ours)
            let engine = try #require(ours() ? TourOracle.overlay : nil, "the request started a tour")
            #expect(engine.state.step == .navigation)
            #expect(!inQuickEntry(), "W-U1a-1: the tour's arrival released the caret")

            // Step 1 runs (the ring on the sidebar, the card beside it).
            await CaptureRig.settle(window, turns: 60)
            #expect(!inQuickEntry(), "step 1: the caret never came back to the quick entry")

            // Step 2 (the Bookcase row of the seeded book).
            engine.next()
            #expect(engine.state.step == .seededBook)
            await CaptureRig.settle(window, turns: 60)
            #expect(!inQuickEntry(), "step 2: the caret never came back to the quick entry")

            engine.endTour()
            await CaptureRig.settle(window, turns: 20)
        }
        #endif
    }
}
