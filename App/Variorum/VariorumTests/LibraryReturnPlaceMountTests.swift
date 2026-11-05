//
//  LibraryReturnPlaceMountTests.swift
//  VariorumTests
//
//  **VX-823 (the VX-828 run, batch C) — THE LIBRARY COMES BACK WHERE SHE LEFT
//  IT**, USE-SHAPED over the WHOLE mounted catalog (the
//  `LibraryInfiniteScrollTests` mount — a plain run-loop pump, never the click
//  rig's event pump). Her ask: *"keeping where you were in the library after
//  entering a note and leaving it."*
//
//  Each pin scrolls the catalog's scroll view THROUGH ITS CLIP VIEW (the
//  catalog's scroll views are UNBOUND — no `.scrollPosition` — so the 18l-c U8
//  trap, a bound scroll view re-applying its last target over a programmatic
//  scroll, does not apply here), lets her scroll rest, then plays the trip the
//  shell plays: the catalog view LEAVES (the hosting view's root swapped out —
//  `paneDetail`'s arm swap, structurally) and a NEW catalog view mounts on the
//  SAME model (the window's `@State` model outlives the trip). The claim is
//  what the screen shows on return.
//
//  RED ON THE PRE-FIX TREE (this file uses nothing that tree lacks): its mount
//  re-asked a new question from the top — the scroll view at offset 0, the
//  first page alone listed — so a row she was reading deep in the Library is
//  off screen, or not listed at all.
//

import AppKit
import CoreGraphics
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-823 — the Library comes back where she left it (mounted)", .serialized)
struct LibraryReturnPlaceMountTests {
    private final class Clock: @unchecked Sendable {
        private let state: LockIsolated<Date>
        init(start: Date) { state = LockIsolated(start) }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(37) }
                return value
            }
        }
    }

    /// 09:00 local — every note lands on one day of her calendar (the day pin).
    private static let start: Date = {
        LibraryDayFace.calendar.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 9))!
    }()

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock(start: Self.start)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1823))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "vx823-mount-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func notes(_ session: AppSession, _ count: Int) throws {
        for index in 0..<count {
            let note = try session.operations.createPost(title: String(format: "note %03d", index))
            _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
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

    private func catalog(_ session: AppSession, _ model: LibraryCatalogModel) -> AnyView {
        AnyView(LibraryCatalogView(
            session: session, model: model, library: LibraryViewModel(session: session),
            tags: TagsViewModel(session: session), onOpen: { _ in }))
    }

    private func mount(
        _ session: AppSession, _ model: LibraryCatalogModel, height: CGFloat = 640
    ) -> (NSWindow, NSHostingView<AnyView>) {
        // AWAY from the machine's pointer (a hovered card has its own face).
        let window = NSWindow(
            contentRect: Self.frameAwayFromThePointer(height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: catalog(session, model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private static func frameAwayFromThePointer(height: CGFloat) -> NSRect {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 2000, height: 1200)
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

    /// The scroll view carrying the listing: the tallest document on screen.
    private static func listingScroll(_ hosting: NSView) -> NSScrollView? {
        scrollViews(in: hosting)
            .max { ($0.documentView?.frame.height ?? 0) < ($1.documentView?.frame.height ?? 0) }
    }

    /// Scroll to the very bottom until the listing stops growing (every page in).
    private func scrollToTheEnd(
        _ model: LibraryCatalogModel, _ window: NSWindow, _ hosting: NSView
    ) async {
        var stalled = 0
        var last = -1
        while stalled < 4 {
            guard let scroll = Self.listingScroll(hosting), let document = scroll.documentView
            else { return }
            let clip = scroll.contentView
            clip.scroll(to: NSPoint(x: 0, y: max(0, document.frame.height - clip.bounds.height)))
            scroll.reflectScrolledClipView(clip)
            await settle(window, hosting, timeout: 0.4)
            stalled = model.noteHits.count == last ? stalled + 1 : 0
            last = model.noteHits.count
        }
    }

    /// Her scroll: the listing's clip to `y`, then the rest (the place is
    /// noted when the scroll has been still).
    private func scroll(to y: CGFloat, _ window: NSWindow, _ hosting: NSView) async throws -> NSScrollView {
        let scroll = try #require(Self.listingScroll(hosting))
        scroll.contentView.scroll(to: NSPoint(x: 0, y: y))
        scroll.reflectScrolledClipView(scroll.contentView)
        await settle(window, hosting, timeout: 0.7)
        return scroll
    }

    /// The trip: the catalog view leaves (a note opens in its pane), then a
    /// NEW catalog view mounts on the same model (she comes back).
    private func leaveAndComeBack(
        _ session: AppSession, _ model: LibraryCatalogModel,
        _ window: NSWindow, _ hosting: NSHostingView<AnyView>,
        until arrived: () -> Bool
    ) async {
        hosting.rootView = AnyView(Color.clear)
        await settle(window, hosting, timeout: 0.4)
        hosting.rootView = catalog(session, model)
        await settle(window, hosting, timeout: 4, until: arrived)
        // Past the hold's last check: the place must STAY (no late snap).
        await settle(window, hosting, timeout: 1.0)
    }

    /// A note row fully on screen in the notes region, by the DEBUG oracle
    /// (frames in the catalog's own space).
    private func readingRow() -> (id: String, top: CGFloat)? {
        #if DEBUG
        guard let region = LibraryPanelOracle.notesRegionFrame else { return nil }
        let rows = LibraryPanelOracle.noteRowFrames.filter {
            $0.value.minY >= region.minY + 60 && $0.value.maxY <= region.maxY - 20
        }
        return rows.min { $0.value.minY < $1.value.minY }.map { ($0.key, $0.value.minY) }
        #else
        return nil
        #endif
    }

    private func top(of id: String) -> CGFloat? {
        #if DEBUG
        LibraryPanelOracle.noteRowFrames[id]?.minY
        #else
        nil
        #endif
    }

    // MARK: - The List, deep in the Library

    /// **She scrolled 130-odd notes down the List, opened one, came back.**
    /// The row she was reading is back exactly where it sat, and the List
    /// stands where she left it. RED ON OLD: the List came back at the top
    /// with only its first page listed — the row off screen, unlisted.
    @Test func theListComesBackWhereSheLeftItDeepInTheLibrary() async throws {
        #if DEBUG
        try await withLibrary { session in
            try notes(session, 200)
            LibraryPanelOracle.reset()
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("list"))
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            await scrollToTheEnd(model, window, hosting)
            try #require(model.noteHits.count == 200)
            let scroll = try await scroll(to: 3_500, window, hosting)
            let before = scroll.contentView.bounds.origin.y
            let reading = try #require(readingRow(), "a row on screen to read")
            let deepest = try #require(model.noteHits.firstIndex { $0.id == reading.id })
            #expect(deepest > LibraryCatalogModel.pageSize, "the row lives past the first page")

            await leaveAndComeBack(session, model, window, hosting) {
                top(of: reading.id).map { abs($0 - reading.top) <= 1 } ?? false
            }
            let after = try #require(top(of: reading.id), "the row she was reading is on screen again")
            #expect(abs(after - reading.top) <= 1,
                    "the row back where it sat: \(after) vs \(reading.top)")
            let now = try #require(Self.listingScroll(hosting)).contentView.bounds.origin.y
            #expect(abs(now - before) <= 1, "the List where she left it: \(now) vs \(before)")
            #expect(model.noteHits.count < 200, "the return re-asked to her place's depth, not the corpus")
        }
        #endif
    }

    // MARK: - The Cards

    /// **The Cards come back where she left them** (the place alone — the
    /// Cards draw no selection, P-828-14). RED ON OLD: at the top.
    @Test func theCardsComeBackWhereSheLeftThem() async throws {
        try await withLibrary { session in
            try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("cards"))
            _ = model.pickMode(.notes)
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            await scrollToTheEnd(model, window, hosting)
            let scroll = try await scroll(to: 4_000, window, hosting)
            let before = scroll.contentView.bounds.origin.y
            try #require(before > 1_000, "deep in the Cards")
            let firstSeen = model.visibleNoteIndices.min()

            await leaveAndComeBack(session, model, window, hosting) {
                guard let scroll = Self.listingScroll(hosting) else { return false }
                return abs(scroll.contentView.bounds.origin.y - before) <= 1
            }
            let now = try #require(Self.listingScroll(hosting)).contentView.bounds.origin.y
            #expect(abs(now - before) <= 1, "the Cards where she left them: \(now) vs \(before)")
            if let firstSeen, let seenNow = model.visibleNoteIndices.min() {
                #expect(abs(seenNow - firstSeen) <= 1, "the same cards before her eyes")
            }
        }
    }

    // MARK: - The search and the day ride along

    /// **A search live** — the answer sheet comes back where she left it, the
    /// field's words untouched. RED ON OLD: the sheet at the top.
    @Test func theAnswerSheetComesBackWhereSheLeftIt() async throws {
        #if DEBUG
        try await withLibrary { session in
            try notes(session, 120)
            LibraryPanelOracle.reset()
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("sheet"))
            model.query = "words"
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            try #require(model.isSearching)
            await scrollToTheEnd(model, window, hosting)
            let scroll = try await scroll(to: 1_800, window, hosting)
            let before = scroll.contentView.bounds.origin.y
            try #require(before > 1_000, "deep in the answer")
            let reading = try #require(readingRow(), "a group head on screen to read")

            await leaveAndComeBack(session, model, window, hosting) {
                top(of: reading.id).map { abs($0 - reading.top) <= 1 } ?? false
            }
            #expect(model.query == "words")
            #expect(model.isSearching)
            let after = try #require(top(of: reading.id))
            #expect(abs(after - reading.top) <= 1, "the group back where it sat: \(after) vs \(reading.top)")
            let now = try #require(Self.listingScroll(hosting)).contentView.bounds.origin.y
            #expect(abs(now - before) <= 1, "the sheet where she left it: \(now) vs \(before)")
        }
        #endif
    }

    /// **The day filter armed** — its whole answer comes back where she left
    /// it, the day still armed. RED ON OLD: at the top.
    @Test func theDaysAnswerComesBackWhereSheLeftIt() async throws {
        #if DEBUG
        try await withLibrary { session in
            try notes(session, 150)
            LibraryPanelOracle.reset()
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("day"))
            let day = JournalDay.dayString(from: Self.start, calendar: LibraryDayFace.calendar)
            model.setEditedOn(day)
            await model.search()
            try #require(model.noteHits.count == 150, "the day's answer, whole")
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            let scroll = try await scroll(to: 2_200, window, hosting)
            let before = scroll.contentView.bounds.origin.y
            try #require(before > 1_000)
            let reading = try #require(readingRow())

            await leaveAndComeBack(session, model, window, hosting) {
                top(of: reading.id).map { abs($0 - reading.top) <= 1 } ?? false
            }
            #expect(model.editedOn == day)
            let after = try #require(top(of: reading.id))
            #expect(abs(after - reading.top) <= 1, "the row back where it sat: \(after) vs \(reading.top)")
        }
        #endif
    }

    // MARK: - A new question still starts at the top (today's, kept)

    /// **Guard (green on both trees):** a new question asked while she is
    /// away — ⌘K's Library road writes the field and asks — starts the
    /// listing at the top on return.
    @Test func aNewQuestionAskedWhileAwayStartsAtTheTop() async throws {
        try await withLibrary { session in
            try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("fresh"))
            await model.search()
            let (window, hosting) = mount(session, model)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, timeout: 1)
            _ = try await scroll(to: 1_200, window, hosting)

            hosting.rootView = AnyView(Color.clear)
            await settle(window, hosting, timeout: 0.4)
            model.query = "note 01"
            await model.search()
            hosting.rootView = catalog(session, model)
            await settle(window, hosting, timeout: 1.5)
            let now = try #require(Self.listingScroll(hosting)).contentView.bounds.origin.y
            #expect(now <= 1, "a new question's answer from its top: \(now)")
        }
    }
}
