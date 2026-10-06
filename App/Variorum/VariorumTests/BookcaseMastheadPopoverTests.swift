//
//  BookcaseMastheadPopoverTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-115 (R-LWP-1, AMENDED at her screenshots) + VR-118
//  (R-LWP-4) — the Bookcase's two droppers become ONE masthead-popover
//  idiom, and "my order" steps back for 0.9.2.**
//
//  Her words: the NATIVE order menu "looks out of place in the app"; the №
//  float's "font and sizing and such is better, but solo is fairly
//  meaningless - highlighting the selected row would be better... like
//  making the order menu look a bit more in tune with the rest of the app?"
//  And: "let's just hide 'my order' from the user, hide the send to top and
//  bottom options, and add it next week or something as a post release
//  update".
//
//  THE RULED SHAPE: № and order ▾ open the SAME popover (the float's own
//  type, a hairline + a menu-grade shadow, width to its content, seated
//  under its control); the selected row wears a quiet wash — no checkmark,
//  no "solo"/"clear" column, the row is the act; the order popover offers
//  a–z · last edited; opening either closes the other. "My order" is
//  hidden WHOLE (its rows, its grips, its row drops, Send to Top/Bottom) —
//  the machinery (`shelf_position`, `placeReading`) untouched for its
//  return (VR-120), and a stored my-order preference READS as a–z while
//  hidden, never rewritten (PROVISIONAL, #188).
//
//  Red-on-old, stated: the first two pins were committed AHEAD of the fix
//  and ran red on that tree — a stored "my order" placed by hand (the grips,
//  the row drops and Send to Top/Bottom all read `placesByHand`), and the
//  utility run drew the native `Menu` and the census's "solo"/"clear"
//  column. The idiom's own pins land with the fix.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-115/VR-118 — one masthead popover for № and order ▾; my order steps back", .serialized)
struct BookcaseMastheadPopoverTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    private func defaults() throws -> UserDefaults {
        let suite = "bookcase-masthead-popover-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func withSession<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    /// VR-118: a stored "my order" no longer places by hand — no grip, no row
    /// drop, no Send to Top/Bottom (all three read this one value) — and the
    /// stored preference is LEFT where she put it.
    @Test func aStoredMyOrderNoLongerPlacesByHand() async throws {
        try await withSession { session in
            let defaults = try defaults()
            BookcasePrefs(defaults: defaults, wingID: "").orderMode = .mine
            let model = ShelfViewModel(session: session, defaults: defaults)
            #expect(!model.placesByHand, "my order steps back whole for 0.9.2 — nothing places by hand")
            #expect(BookcasePrefs(defaults: defaults, wingID: "").orderMode == .mine,
                    "the stored preference is never rewritten — the return finds it where she left it")
        }
    }

    /// VR-115: the utility run draws no native order menu, and the census
    /// draws no "solo"/"clear" column — the selected row is washed instead.
    @Test func theDroppersAreTheAppsOwnPopovers() throws {
        let strip = try Self.source("Variorum/Features/Shelf/BookcaseStrip.swift")
        #expect(!strip.contains("VoicedMenu("), "order ▾ is no longer the native menu")
        #expect(!strip.contains("active ? \"clear\" : \"solo\""), "no solo/clear column")
    }

    // MARK: - The idiom's own pins (landed with the fix)

    /// Opening either dropper closes the other; any other masthead menu
    /// closes both; a pick closes the order popover.
    @Test func openingEitherDropperClosesTheOther() async throws {
        try await withSession { session in
            let model = ShelfViewModel(session: session, defaults: try defaults())
            model.censusOpen = false
            model.toggleCensus()
            #expect(model.censusOpen && !model.orderOpen)
            model.toggleOrder()
            #expect(model.orderOpen && !model.censusOpen, "order ▾ closed the census")
            model.toggleCensus()
            #expect(model.censusOpen && !model.orderOpen, "№ closed the order popover")
            model.toggleOrder()
            model.mastheadDoorOpened()
            #expect(!model.censusOpen && !model.orderOpen, "the wing switcher closes both")
            model.toggleOrder()
            model.pickOrder(.lastEdited)
            #expect(model.orderMode == .lastEdited && !model.orderOpen, "a pick is the act and closes")
            model.toggleOrder()
            model.toggleOrder()
            #expect(!model.orderOpen, "order ▾ again closes it")
        }
    }

    /// VR-118's rule, pure: a stored my order DRAWS A–Z while hand placing
    /// steps back; the offered orders are A–Z · last edited; turned back on
    /// (the machinery's return), my order is offered and placed again.
    @Test func myOrderStepsBackAndReturnsByOneValue() async throws {
        #expect(!ShelfViewModel.handPlacingOfferedThisRelease, "0.9.2: hand placing steps back")
        #expect(ShelfViewModel.effectiveOrder(.mine, handPlacingOffered: false) == .alphabetical)
        #expect(ShelfViewModel.effectiveOrder(.lastEdited, handPlacingOffered: false) == .lastEdited)
        #expect(ShelfViewModel.effectiveOrder(.mine, handPlacingOffered: true) == .mine)
        try await withSession { session in
            let model = ShelfViewModel(session: session, defaults: try defaults())
            #expect(model.offeredOrderModes == [.alphabetical, .lastEdited])
            model.orderMode = .mine
            #expect(model.effectiveOrderMode == .alphabetical && !model.placesByHand)
            model.handPlacingOffered = true
            #expect(model.offeredOrderModes == [.alphabetical, .lastEdited, .mine])
            #expect(model.effectiveOrderMode == .mine && model.placesByHand, "the return is one value")
        }
    }

    /// The rows, as data: the census's six (the active solo washed, a zero row
    /// inert, no "solo" word anywhere); the washed row's click CLEARS it
    /// (PROVISIONAL #188). The order's two (the drawn order washed — a stored
    /// my order shows A–Z washed).
    @Test func theRowsAreTheActs() async throws {
        try await withSession { session in
            let ops = session.operations
            _ = try ops.createReading(name: "a book", kind: .book)
            let defaults = try defaults()
            BookcasePrefs(defaults: defaults, wingID: "").orderMode = .mine
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            for _ in 0..<300 where model.books.isEmpty { try? await Task.sleep(for: .milliseconds(10)) }

            var rows = BookcaseCensusPanel.rows(model)
            #expect(rows.map(\.id) == BookcaseSolo.allCases.map(\.rawValue))
            #expect(rows.allSatisfy { !$0.selected })
            #expect(!rows.contains { $0.title.contains("solo") || $0.title.contains("clear") })
            #expect(rows.first { $0.id == "books" }?.enabled == true)
            #expect(rows.first { $0.id == "gatherings" }?.enabled == false, "a zero row is inert")
            rows.first { $0.id == "books" }?.action()
            rows = BookcaseCensusPanel.rows(model)
            #expect(model.solo == .books)
            #expect(rows.filter(\.selected).map(\.id) == ["books"], "the active solo's row is washed")
            rows.first { $0.id == "books" }?.action()
            #expect(model.solo == nil, "the washed row's click clears it")

            let order = BookcaseOrderPanel.rows(model)
            #expect(order.map(\.title) == ["A\u{2013}Z", "last edited"])
            #expect(order.filter(\.selected).map(\.title) == ["A\u{2013}Z"],
                    "a stored my order shows A–Z washed (the order the board draws)")
        }
    }

    /// **The rider, VERIFIED (her "you should be able to sort within a shelf
    /// for the books versus gatherings"):** a census solo COMPOSES with a
    /// solo'd shelf — it filters WITHIN it, never exits to All — and the
    /// census counts what that shelf holds. Shipped behaviour (13i-d U1's
    /// `BookcaseBoard.sections` applies the solo inside every scope; nothing
    /// clears a solo when the shelf changes): this pin guards it — green on
    /// both sides, a verification, never a fix.
    @Test func aCensusSoloFiltersWithinASoloedShelf() async throws {
        try await withSession { session in
            let ops = session.operations
            let work = try ops.createShelf(name: "Work")
            let spec = try RuleGrammar.encode(.star)
            _ = try ops.createReading(name: "work book", kind: .book, shelfId: work.id)
            let gathering = try ops.createReading(
                name: "work gathering", kind: .gathering, querySpec: spec, shelfId: work.id)
            _ = try ops.createReading(
                name: "loose gathering", kind: .gathering, querySpec: spec)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            for _ in 0..<300 where model.books.count < 3 { try? await Task.sleep(for: .milliseconds(10)) }
            model.scope = .shelf(work.id)
            model.toggleSolo(.gatherings)
            #expect(model.effectiveScope == .shelf(work.id), "the solo never exits the shelf")
            #expect(model.sections.map(\.id) == [work.id])
            #expect(model.sections.first?.books.map(\.reading.id) == [gathering.id],
                    "only the shelf's gatherings")
            #expect(model.census[.gatherings] == 1 && model.census[.books] == 1,
                    "the census counts the shelf, not the wing")
            model.scope = .all
            #expect(model.solo == .gatherings, "the solo rides a shelf change")
        }
    }

    private nonisolated static func pump() {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
    }

    /// **The mounted board:** each popover hangs UNDER the strip's controls
    /// (never above the strip, never pushing a row), the order popover right
    /// of the census's seat (under order ▾, right of №).
    @Test func thePopoversAreSeatedUnderTheirControls() async throws {
        #if DEBUG
        try await withSession { session in
            let book = try session.operations.createReading(name: "alpha", kind: .book)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            model.censusOpen = false
            BookcaseRowOracle.forgetAll()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model, readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer { window.orderOut(nil); window.close() }
            @MainActor func settle(_ turns: Int = 60, until: () -> Bool = { false }) async {
                for _ in 0..<turns {
                    hosting.layoutSubtreeIfNeeded()
                    window.displayIfNeeded()
                    Self.pump()
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(10))
                    if until() { return }
                }
            }
            await settle(150) { BookcaseRowOracle.frame(book.id) != nil }
            let row = try #require(BookcaseRowOracle.frame(book.id))
            let strip = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.stripKey))

            model.toggleCensus()
            await settle { BookcaseRowOracle.frame(BookcaseRowOracle.censusPanelKey) != nil }
            let census = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.censusPanelKey))
            #expect(census.minY > strip.minY + 10 && census.minY <= strip.maxY + 1.5,
                    "the census hangs under its control, inside the strip's foot (strip \(strip), panel \(census))")
            #expect(census.maxX <= strip.maxX, "it stays on the board")

            model.toggleOrder()
            await settle { BookcaseRowOracle.frame(BookcaseRowOracle.orderPanelKey) != nil }
            let order = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.orderPanelKey))
            #expect(!model.censusOpen)
            #expect(order.minY > strip.minY + 10 && order.minY <= strip.maxY + 1.5,
                    "the order popover hangs under order ▾ (strip \(strip), panel \(order))")
            #expect(order.minX > census.minX, "under order ▾, right of the №")
            let rowNow = try #require(BookcaseRowOracle.frame(book.id))
            #expect(abs(rowNow.minY - row.minY) < 0.5, "an open popover pushes no row")
        }
        #endif
    }

    // MARK: - Round 1 (librarywalkpolish ladder) — the fix round's pins

    /// **Round 1's MINOR-1 — the order popover lives like a MENU, and a menu
    /// never outlives its surface** (the reviewer's pin, as specified: red on
    /// the shipped board, whose only close was a board-local catcher). Open
    /// it, take the board off screen (⌘K/⌘N/⌘J or a sidebar click replace the
    /// root exactly this way), bring the board back: closed. And — a menu's
    /// other two ends — it closes when its window stops being key and when
    /// the app stops being active. The census is NOT a menu (its open state
    /// is remembered, #188(b)) and rides none of these.
    @Test func theOrderPopoverNeverOutlivesItsBoard() async throws {
        try await withSession { session in
            _ = try session.operations.createReading(name: "alpha", kind: .book)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            model.censusOpen = false
            let readings = ReadingsViewModel(session: session)
            let board = {
                AnyView(ShelfView(
                    session: session, model: model, readings: readings,
                    onOpen: { _ in }, onTodaysEntry: {}))
            }
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: board())
            window.contentView = hosting
            window.orderFrontRegardless()
            defer { window.orderOut(nil); window.close() }
            @MainActor func settle(_ turns: Int = 30) async {
                for _ in 0..<turns {
                    hosting.layoutSubtreeIfNeeded()
                    window.displayIfNeeded()
                    Self.pump()
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(10))
                }
            }
            await settle(60)

            model.toggleOrder()
            await settle()
            #expect(model.orderOpen)
            hosting.rootView = AnyView(Text("elsewhere"))
            await settle()
            hosting.rootView = board()
            await settle()
            #expect(!model.orderOpen, "navigating away and back finds no popover open")

            model.toggleOrder()
            await settle()
            #expect(model.orderOpen)
            NotificationCenter.default.post(name: NSWindow.didResignKeyNotification, object: window)
            await settle(5)
            #expect(!model.orderOpen, "its window stopped being key — a menu closes")

            model.toggleOrder()
            await settle()
            #expect(model.orderOpen)
            NotificationCenter.default.post(name: NSApplication.didResignActiveNotification, object: NSApp)
            await settle(5)
            #expect(!model.orderOpen, "the app stopped being active — a menu closes")

            model.censusOpen = true
            NotificationCenter.default.post(name: NSWindow.didResignKeyNotification, object: window)
            await settle(5)
            #expect(model.censusOpen, "the census is a remembered float, never a menu")
        }
    }
}
