//
//  BookcaseCensusMenuTests.swift
//  VariorumTests
//
//  **17y B-WALK W-3 — THE № CENSUS FLOAT NEVER COVERS AN OPEN MASTHEAD MENU
//  (her ruling, the walk of 2026-10-05).** Her finding, verbatim: the census
//  float covers the order ▾ menu when clicked second — "unexcusable UI. not
//  good at all". The float (17y (r), an in-window overlay hung over the
//  board's top-right) stood open while the masthead's own menus and popover
//  opened over the same corner, and nothing in the Bookcase connected the
//  two: opening order ▾ (a SwiftUI `Menu` — no open callback), the wing
//  switcher ▾, the ⋯ shelf panel, or a shelf name's right-click menu left
//  `censusOpen` exactly as it was.
//
//  THE RULE (ruled): opening any masthead menu or popover DISMISSES the
//  float; № toggles cleanly beside them. One state door on the model
//  (`ShelfViewModel.mastheadDoorOpened`), reached from every masthead
//  menu/popover through ONE press report (`Core/Views/PressReporter`) — the
//  SwiftUI `Menu` says nothing when it opens, so the press that opens it is
//  what reports.
//
//  Red-on-old, stated: the source pin was committed AHEAD of the fix and ran
//  red on that tree (no masthead door reached the census). The model's rule
//  and the mounted wiring pins land with the fix.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B-WALK W-3 — opening a masthead menu or popover dismisses the № float", .serialized)
struct BookcaseCensusMenuTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    /// Every masthead menu/popover door reports its press to the one
    /// dismissal door: the order ▾ menu, the ⋯ shelf panel and the shelf
    /// names' right-click menus in the strip; the wing switcher ▾ in the
    /// masthead.
    @Test func everyMastheadMenuDoorReachesTheDismissal() throws {
        let strip = try Self.source("Variorum/Features/Shelf/BookcaseStrip.swift")
        let shelf = try Self.source("Variorum/Features/Shelf/ShelfView.swift")
        #expect(strip.contains(".reportsPress { model.mastheadDoorOpened() }"),
                "the order ▾ menu reports its press")
        #expect(strip.contains("panelShown.toggle()\n                    model.mastheadDoorOpened()")
                    || strip.contains("model.mastheadDoorOpened()\n                    panelShown"),
                "the ⋯ shelf panel's door dismisses the float")
        #expect(strip.contains(".reportsPress(secondaryOnly: true) { model.mastheadDoorOpened() }"),
                "the shelf names' right-click menus report their press")
        #expect(shelf.contains("WingSwitcherMenu(tokens: tokens, wings: wings)\n                    .reportsPress { model.mastheadDoorOpened() }"),
                "the wing switcher ▾ reports its press")
    }

    // MARK: - The rule and its wiring (landed with the fix)

    private func defaults() throws -> UserDefaults {
        let suite = "bookcase-census-menu-\(UUID().uuidString)"
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

    /// The state door: an open float closes (and is remembered closed — the
    /// float is closed until № opens it); a closed one stays closed; № is
    /// still the float's own toggle.
    @Test func aMastheadDoorClosesTheFloatAndNumeroStillToggles() async throws {
        try await withSession { session in
            let defaults = try defaults()
            let model = ShelfViewModel(session: session, defaults: defaults)
            model.censusOpen = true
            model.mastheadDoorOpened()
            #expect(!model.censusOpen, "a masthead menu opening dismissed the float")
            #expect(!ShelfViewModel(session: session, defaults: defaults).censusOpen,
                    "the dismissal is the remembered close")
            model.mastheadDoorOpened()
            #expect(!model.censusOpen, "a closed float stays closed")
            model.censusOpen.toggle()
            #expect(model.censusOpen, "№ toggles cleanly beside the menus")
        }
    }

    /// The press rule: inside the bounds, a primary or a secondary press;
    /// `secondaryOnly`, the secondary ones alone; outside, nothing.
    @Test func thePressRule() {
        let bounds = NSRect(x: 0, y: 0, width: 40, height: 16)
        let inside = NSPoint(x: 20, y: 8)
        let outside = NSPoint(x: 60, y: 8)
        typealias R = PressReporterView
        #expect(R.reports(kind: .leftMouseDown, modifiers: [], at: inside, in: bounds, secondaryOnly: false))
        #expect(R.reports(kind: .rightMouseDown, modifiers: [], at: inside, in: bounds, secondaryOnly: false))
        #expect(!R.reports(kind: .leftMouseDown, modifiers: [], at: outside, in: bounds, secondaryOnly: false))
        #expect(!R.reports(kind: .leftMouseDown, modifiers: [], at: inside, in: bounds, secondaryOnly: true),
                "a plain click on a shelf name solos it — the float stays")
        #expect(R.reports(kind: .rightMouseDown, modifiers: [], at: inside, in: bounds, secondaryOnly: true))
        #expect(R.reports(kind: .leftMouseDown, modifiers: .control, at: inside, in: bounds, secondaryOnly: true),
                "a control-click is a right-click")
        #expect(!R.reports(kind: .leftMouseUp, modifiers: [], at: inside, in: bounds, secondaryOnly: false))
    }

    private nonisolated static func pump() {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
    }

    private static func reporters(in view: NSView) -> [PressReporterView] {
        var found: [PressReporterView] = []
        if let reporter = view as? PressReporterView { found.append(reporter) }
        for sub in view.subviews { found += reporters(in: sub) }
        return found
    }

    private static func press(
        _ reporter: PressReporterView, _ kind: NSEvent.EventType, inside: Bool = true
    ) throws {
        let window = try #require(reporter.window)
        let local = inside
            ? NSPoint(x: reporter.bounds.midX, y: reporter.bounds.midY)
            : NSPoint(x: reporter.bounds.maxX + 30, y: reporter.bounds.midY)
        let point = reporter.convert(local, to: nil)
        let event = try #require(NSEvent.mouseEvent(
            with: kind, location: point, modifierFlags: [], timestamp: 0,
            windowNumber: window.windowNumber, context: nil, eventNumber: 0,
            clickCount: 1, pressure: 1))
        // Straight to the monitor's body — never through the window, where
        // a real `Menu` would start its modal tracking.
        reporter.handle(event)
    }

    /// **The mounted board:** the float open, a press on each masthead
    /// menu's own reporter closes it — order ▾ and the wing switcher ▾ on a
    /// primary press, a shelf name on a right-click only (its plain click
    /// solos, the float stays); a press beside a door closes nothing.
    @Test func theMountedMastheadMenusDismissTheFloat() async throws {
        try await withSession { session in
            _ = try session.operations.createShelf(name: "research")
            _ = try session.operations.createReading(name: "alpha", kind: .book)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model, readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}, wings: WingsModel(session: session)))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer { window.orderOut(nil); window.close() }
            for _ in 0..<60 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                Self.pump()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
                if !model.shelves.isEmpty, Self.reporters(in: hosting).count >= 3 { break }
            }
            let all = Self.reporters(in: hosting)
            let primary = all.filter { !$0.secondaryOnly }
            let names = all.filter(\.secondaryOnly)
            #expect(primary.count == 2, "order ▾ and the wing switcher ▾ report (found \(primary.count))")
            #expect(!names.isEmpty, "the shelf names report their right-click")

            for reporter in primary {
                model.censusOpen = true
                try Self.press(reporter, .leftMouseDown, inside: false)
                #expect(model.censusOpen, "a press BESIDE a door closes nothing")
                try Self.press(reporter, .leftMouseDown)
                #expect(!model.censusOpen, "opening a masthead menu dismissed the float")
            }
            if let name = names.first {
                model.censusOpen = true
                try Self.press(name, .leftMouseDown)
                #expect(model.censusOpen, "a shelf name's plain click leaves the float")
                try Self.press(name, .rightMouseDown)
                #expect(!model.censusOpen, "a shelf name's right-click menu dismissed the float")
            }
        }
    }
}
