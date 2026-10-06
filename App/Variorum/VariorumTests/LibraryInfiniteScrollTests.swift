//
//  LibraryInfiniteScrollTests.swift
//  VariorumTests
//
//  **17y B1 item (k) — THE LIBRARY SCROLLS THROUGH EVERY NOTE** (a LAUNCH
//  BLOCKER in her words: "the fact that the library only shows you the first
//  40 notes is completely unacceptable… we need an area in which people can
//  scroll through ALL of their notes, that kind of access is literally what
//  library is supposed to be"), and its rider ("once books hit ~half of the
//  vertical area, books start to scroll within their own little view, so that
//  many books won't mean you see no notes").
//
//  USE-SHAPED pins over the WHOLE mounted catalog (the `LibraryPanelHostTests`
//  mount — a plain run-loop pump, never the click rig's event pump, which is
//  KnownIssues row 34's hang): the List and the Cards views are SCROLLED to
//  their bottom, again and again, through their own scroll views, and the
//  claim is what a scroll reaches.
//
//  RED ON THE PRE-FIX TREE, all three (they read only what that tree has —
//  `hits`, the oracle's note-row frames): the List and the Cards stopped at
//  the 40 newest notes however far she scrolled ("listed 40 of 130"), and
//  forty books in one list left no note row on screen at all.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B1 (k) — the Library scrolls through every note; the books leave room", .serialized)
struct LibraryInfiniteScrollTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(37) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "17y-b1-k-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// `count` notes, oldest first (each with a block, so each is "edited").
    @discardableResult
    private func notes(_ session: AppSession, _ count: Int) throws -> [String] {
        try (0..<count).map { index in
            let note = try session.operations.createPost(
                title: String(format: "note %03d", index))
            _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            return note.id
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 4,
        until predicate: () -> Bool = { false }
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func mount(
        _ session: AppSession, _ model: LibraryCatalogModel, height: CGFloat = 640
    ) -> (NSWindow, NSHostingView<AnyView>) {
        // AWAY from the machine's pointer: a card under a real pointer is
        // HOVERED, and a hovered untagged card's chip row has its own
        // behaviour (F-B1-… in the record) — these pins are about scrolling.
        let window = NSWindow(
            contentRect: Self.frameAwayFromThePointer(height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            LibraryCatalogView(
                session: session, model: model, library: LibraryViewModel(session: session),
                tags: TagsViewModel(session: session), onOpen: { _ in })))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private static func frameAwayFromThePointer(height: CGFloat) -> NSRect {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 2000, height: 1200)
        // The window is 1000 wide: put it on the half the pointer is not in,
        // vertically too.
        let x = mouse.x < screen.midX ? max(screen.midX, screen.maxX - 1_000) : screen.minX
        let y = mouse.y < screen.midY ? screen.maxY - height : screen.minY
        return NSRect(x: x, y: y, width: 1000, height: height)
    }

    private static func scrollViews(in view: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        if let scroll = view as? NSScrollView { found.append(scroll) }
        for sub in view.subviews { found += scrollViews(in: sub) }
        return found
    }

    private func listedNotes(_ model: LibraryCatalogModel) -> [String] {
        model.hits.filter { $0.kind == .post }.map(\.id)
    }

    /// Scroll the scroll view that carries the notes to its very bottom,
    /// again and again, until the listing stops growing — what HER scrolling
    /// to the end does.
    private func scrollToTheEnd(
        _ model: LibraryCatalogModel, _ window: NSWindow, _ hosting: NSView
    ) async {
        var stalled = 0
        var last = -1
        while stalled < 4 {
            // The notes' scroll view: the tallest document on screen.
            guard let scroll = Self.scrollViews(in: hosting)
                .max(by: { ($0.documentView?.frame.height ?? 0) < ($1.documentView?.frame.height ?? 0) }),
                  let document = scroll.documentView
            else { return }
            let clip = scroll.contentView
            clip.scroll(to: NSPoint(x: 0, y: max(0, document.frame.height - clip.bounds.height)))
            scroll.reflectScrolledClipView(clip)
            await settle(window, hosting, timeout: 0.4)
            let count = listedNotes(model).count
            stalled = count == last ? stalled + 1 : 0
            last = count
        }
    }

    /// **The List mode scrolls through EVERY note.** RED on the pre-fix tree:
    /// "listed 40 of 130".
    @Test func theListModeScrollsThroughEveryNote() async throws {
        try await withLibrary { session in
            let ids = try notes(session, 130)
            for name in ["a book", "b book", "c book"] {
                _ = try session.operations.createReading(name: name, kind: .book)
            }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("list"))
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            await scrollToTheEnd(model, window, hosting)
            let listed = listedNotes(model)
            #expect(listed.count == 130, "listed \(listed.count) of 130 notes")
            #expect(listed.last == ids.first, "the OLDEST note is reachable by scrolling")
            #expect(Set(listed).count == listed.count, "no note twice")
        }
    }

    /// **The Cards view scrolls through EVERY note too** (her bar names it:
    /// "including if it's in the notes view"). RED on the pre-fix tree.
    @Test func theCardsViewScrollsThroughEveryNote() async throws {
        try await withLibrary { session in
            let ids = try notes(session, 130)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("cards"))
            model.mode = .notes
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            await scrollToTheEnd(model, window, hosting)
            let listed = listedNotes(model)
            #expect(listed.count == 130, "listed \(listed.count) of 130 notes")
            #expect(listed.last == ids.first, "the OLDEST note is reachable by scrolling")
        }
    }

    /// **A page landing re-draws no row already built** — her bar: "SMOOTH
    /// like the rest of the app — no performance losses are acceptable for
    /// it! including if it's in the notes view". Measured on the 822-note
    /// fixture (the 17y B1 RECORD's § THE (k) NUMBERS): every row read the
    /// WHOLE listing's extras (`postTags`, `noteCards`, the owned-by facts),
    /// so a landing page's chips and card words re-drew every row SwiftUI
    /// held alive — 105–159 cards a landing, a 125–230 ms frame. The CARDS
    /// leg is RED on 2f26fff2 (the one-update page without the rows' own
    /// slices): "a page landing re-drew 7 rows already built" — the rows on
    /// screen. The LIST leg is green on both trees (the List's landing cost
    /// measured as the table's own update, not a row re-draw) and stays as
    /// the guard. Every note is tagged, so the page's chips are a real
    /// write; the Cards view also lands the page's card words.
    @Test(arguments: [false, true])
    func aPageLandingReDrawsNoRowAlreadyBuilt(cards: Bool) async throws {
        #if DEBUG
        try await withLibrary { session in
            let ids = try notes(session, 200)
            let tag = try session.operations.createTag(parent: nil, name: "everywhere")
            let tagID = tag.id
            try await session.runner.run { ops in
                for id in ids { _ = try ops.applyTag(tagID, toPost: id) }
            }
            let model = LibraryCatalogModel(
                session: session, defaults: try scrubbed(cards ? "land-cards" : "land-list"))
            if cards { model.mode = .notes }
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1.5)
            #expect(model.noteHits.count == LibraryCatalogModel.pageSize)
            let built = LibraryPagedNotesProbe.rowBodies
            #expect(built > 0, "the first page's rows on screen were built")

            // The next page lands below what she is looking at (no scroll).
            await model.loadMoreNotes()
            await settle(window, hosting, timeout: 1.5)
            #expect(model.noteHits.count == LibraryCatalogModel.pageSize * 2)
            let redrawn = LibraryPagedNotesProbe.rowBodies - built
            #expect(redrawn == 0, "a page landing re-drew \(redrawn) rows already built")
        }
        #endif
    }

    /// **Standing rows follow an appearance flip** (the B1 ladder's MAJOR-1 —
    /// a regression of this batch's own `Equatable` row hosts): the
    /// appearance choice reaches the rows only through the `colorScheme`
    /// environment (`NSApp.appearance` / the system — never an observable
    /// ThemeStore write), the catalog re-derives its scheme-keyed tokens, and
    /// a host equal on its `hit` alone skipped every standing row's body — so
    /// the rows kept the OLD scheme's ink/wash while every non-gated surface
    /// switched (a dark room with light-ink rows). RED on the pre-fix tree:
    /// "an appearance flip re-drew 0 standing rows". The fixture is titled,
    /// untagged, bookless notes so the first settle reaches a steady state
    /// (no extras or facts land between the two counts) — the only thing
    /// that changes between them is the appearance.
    @Test func standingRowsFollowAnAppearanceFlip() async throws {
        #if DEBUG
        try await withLibrary { session in
            try notes(session, 30)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("appearance"))
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            window.appearance = NSAppearance(named: .aqua)
            await settle(window, hosting, timeout: 2)
            let before = LibraryPagedNotesProbe.rowBodies
            #expect(before > 0, "the rows on screen were built")
            window.appearance = NSAppearance(named: .darkAqua)
            await settle(window, hosting, timeout: 2)
            let redrawn = LibraryPagedNotesProbe.rowBodies - before
            #expect(redrawn > 0,
                    "an appearance flip re-drew \(redrawn) standing rows — stale-scheme rows are illegible")
        }
        #endif
    }

    /// **Her rider: many books never mean no notes.** Forty books under "All"
    /// in a 640-pt window: the first note row is ON SCREEN, in the listing's
    /// lower half. RED on the pre-fix tree: the notes sat below forty book
    /// rows and no note row was ever drawn.
    @Test func manyBooksLeaveRoomForTheNotes() async throws {
        try await withLibrary { session in
            for index in 0..<40 {
                _ = try session.operations.createReading(
                    name: String(format: "book %02d", index), kind: .book)
            }
            try notes(session, 20)
            #if DEBUG
            LibraryPanelOracle.reset()
            #endif
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("rider"))
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            await settle(window, hosting, timeout: 3) { !LibraryPanelOracle.noteRowFrames.isEmpty }
            let root = try #require(LibraryPanelOracle.rootFrame)
            let firstNoteTop = LibraryPanelOracle.noteRowFrames.values.map(\.minY).min()
            let top = try #require(firstNoteTop, "a note row is on screen beside forty books")
            #expect(top < root.height * 0.75,
                    "the first note row sits at \(top) of a \(root.height)-pt catalog")
            #endif
        }
    }
}
