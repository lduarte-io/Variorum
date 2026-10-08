//
//  TourOfferLineTests.swift
//  VariorumTests
//
//  13s-b U1a, piece 2 — the first-open TOUR OFFER (her rulings R-13s-2, -6,
//  -13; mockup v5's "first open" and "not now" frames). The lifecycle's rule
//  is pinned headless in the core (`TourOfferTests`); these pin the app's
//  half: the device's ONE local record (written where the rule says, never
//  anywhere else), the help-road timer, and the line's place on the Bookcase
//  — between the quick-entry box and the bottom bar, on the right, and
//  moving NOTHING as it changes or leaves (R-13s-2/12).
//
//  Every model here sits on a throwaway `UserDefaults` suite: the test host
//  IS the dev-store app and shares its real defaults, so a pin that wrote the
//  real key would retire the offer on the dev store the walks use.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13s-b U1a — the first-open tour offer", .serialized)
struct TourOfferLineTests {
    private func withDefaults<T>(_ body: (UserDefaults) async throws -> T) async throws -> T {
        let suite = "tour-offer-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        return try await body(defaults)
    }

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, turns: Int = 150, until predicate: () -> Bool
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    // MARK: - The device's record

    @Test func aFreshDeviceIsOfferedAndKeepsARowForTheLine() async throws {
        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults)
            #expect(model.phase == .offering)
            #expect(model.line == .offer)
            #expect(model.holdsRow)
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil,
                    "looking writes nothing")
        }
    }

    /// "not now" → the help-road sentence → gone; the answer is kept AT the
    /// press, and the next launch has neither a line nor a row.
    @Test func notNowShowsTheHelpRoadThenRetiresForGood() async throws {
        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults, helpRoadDuration: .milliseconds(150))
            model.notNow()
            #expect(model.line == .helpRoad)
            #expect(defaults.string(forKey: TourOfferModel.recordKey)
                    == TourOffer.Record.declined.rawValue,
                    "kept at the press — a quit during the sentence never re-offers")
            for _ in 0..<100 where model.phase != .retired {
                try await Task.sleep(for: .milliseconds(20))
            }
            #expect(model.phase == .retired, "the sentence has its few seconds, then goes")
            #expect(model.line == nil)
            #expect(model.holdsRow, "the row keeps its height for the rest of this process")

            let nextLaunch = TourOfferModel(defaults: defaults)
            #expect(nextLaunch.phase == .retired, "R-13s-13: the offer never comes back")
            #expect(!nextLaunch.holdsRow, "and a later launch draws no row at all")
        }
    }

    /// "yes" (or Help's door): the line steps aside and NOTHING is kept — a
    /// tour abandoned by quitting offers again (Q12: no resume, step 1). The
    /// tour's end retires it (U2's hook).
    @Test func takingTheTourKeepsNothingUntilTheTourEnds() async throws {
        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults)
            model.tourStarted()
            #expect(model.phase == .touring)
            #expect(model.line == nil, "not offered to someone already taking it")
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil)
            #expect(TourOfferModel(defaults: defaults).phase == .offering,
                    "a quit mid-tour offers again next launch")

            model.tourEnded(completed: true)
            #expect(model.phase == .retired)
            #expect(defaults.string(forKey: TourOfferModel.recordKey)
                    == TourOffer.Record.completed.rawValue)
            #expect(TourOfferModel(defaults: defaults).phase == .retired)
        }
    }

    /// The copy the line speaks, and the one source the help road reads its
    /// door's name from (the Help menu's item and the registry's verb).
    @Test func theWordsAreHersAndTheHelpRoadNamesTheMenusDoor() {
        #expect(TourOfferCopy.offer == "Welcome to Variorum. Take the tour?")
        #expect(TourOfferCopy.yes == "yes")
        #expect(TourOfferCopy.notNow == "not now")
        #expect(TourOfferCopy.helpRoad
                == "Run it any time from Help \u{25B8} \(TourOfferCopy.menuTitle).")
        #expect(CapabilityRegistry.capability(.takeTour).verb == TourOfferCopy.menuTitle)
        // R-13s-22's tone ruling: no em dash anywhere in the line's words.
        for words in [TourOfferCopy.offer, TourOfferCopy.helpRoad] {
            #expect(!words.contains("\u{2014}"), "no em dash: \(words)")
        }
    }

    // MARK: - Help ▸ Take the Tour (piece 5)

    /// The standing door the help-road sentence names: in the Help menu,
    /// declared AND rendered (the registry walk's `menuRendered` set), a
    /// request the window adopts with the ONE entry the line's "yes" calls.
    /// The sentence is pinned literally so U2 and the copy pass read the
    /// exact words a stranger sees (the menu name is PROVISIONAL P-U1a-9).
    @Test func theHelpMenuCarriesTheTourDoorTheSentenceNames() throws {
        #expect(TourOfferCopy.menuTitle == "Take the Tour")
        #expect(TourOfferCopy.helpRoad == "Run it any time from Help \u{25B8} Take the Tour.")
        let doors = CapabilityRegistry.capability(.takeTour).doors
        #expect(doors.contains(.menuBar) && doors.contains(.surface))
        #expect(EditorCommands.menuRendered.contains(.takeTour))
        #expect(ShellRouter().tourRequested == false, "nothing asks for a tour by itself")

        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Variorum")
        let commands = try String(
            contentsOf: app.appendingPathComponent("EditorCommands.swift"), encoding: .utf8)
        #expect(commands.contains(
            "Button(verb(.takeTour)) { windows.creationRouter()?.tourRequested = true }"))
        let root = try String(
            contentsOf: app.appendingPathComponent("RootView.swift"), encoding: .utf8)
        #expect(root.contains(".onChange(of: router.tourRequested)"))
    }

    // MARK: - The line on the Bookcase

    /// Where the line sits and that it moves nothing: between the quick-entry
    /// box and the bottom bar, its words on the RIGHT (R-13s-3: "the tutorial
    /// offer can live above that bar on the right side"); "not now" swaps the
    /// words and, when they fade, the box above has not moved a point.
    @Test func theLineSitsAboveTheBarOnTheRightAndItsLeavingMovesNothing() async throws {
        #if DEBUG
        try await withDefaults { defaults in
            let db = try AppDatabase.inMemory()
            try await withDependencies {
                $0.database = db
                $0.uuid = .incrementing
                $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
            } operation: { @MainActor in
                let session = AppSession(database: db)
                _ = try session.operations.createReading(name: "alpha", kind: .book)
                let shelf = ShelfViewModel(session: session, defaults: defaults)
                let offer = TourOfferModel(defaults: defaults, helpRoadDuration: .milliseconds(300))
                var tourAsked = 0
                BookcaseRowOracle.forgetAll()
                TourOfferLineOracle.forget()

                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 900, height: 640),
                    styleMask: [.titled, .resizable], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: ShelfView(
                    session: session, model: shelf,
                    readings: ReadingsViewModel(session: session),
                    onOpen: { _ in }, onTodaysEntry: {},
                    offerLine: AnyView(TourOfferLine(model: offer) { tourAsked += 1 })))
                window.contentView = hosting
                window.orderFrontRegardless()
                defer {
                    window.orderOut(nil)
                    window.close()
                }

                await settle(window, hosting) {
                    TourOfferLineOracle.drawn == .offer
                        && TourOfferLineOracle.contentFrame.map { $0.width > 100 } == true
                        && BookcaseRowOracle.frame(BookcaseRowOracle.offerRowKey) != nil
                        && BookcaseRowOracle.frame(BookcaseRowOracle.entryKey) != nil
                        && BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey) != nil
                }
                let entry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                let row = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.offerRowKey))
                let hint = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey))
                let words = try #require(TourOfferLineOracle.contentFrame)
                let width = window.contentView?.bounds.width ?? 0

                #expect(abs(entry.maxY - row.minY) < 1.5, "the row sits right under the box")
                #expect(abs(row.maxY - hint.minY) < 1.5, "and right above the bottom bar")
                // "On the right side" (R-13s-3) = the line's centre sits in the
                // right half AND its end meets the board's inset (below). The
                // first draft asked for the line's START to be right of
                // centre, which only holds while the line is narrower than
                // half the board; with piece 4's mark leading it, in this
                // pin's fallback (Terminal, monospace) face, it is 431 pt in
                // a 900-pt window and starts at 441 — right-aligned, centred
                // at 656 (the stage window's red, recorded in the U1a RECORD).
                #expect(words.midX > width / 2,
                        "the words sit on the RIGHT (words \(words), window width \(width))")
                #expect(width - words.maxX < 40,
                        "right-aligned at the board's own inset (words end \(words.maxX))")
                #expect(tourAsked == 0, "nothing starts a tour by itself")

                offer.notNow()
                await settle(window, hosting, turns: 60) { TourOfferLineOracle.drawn == .helpRoad }
                #expect(TourOfferLineOracle.drawn == .helpRoad)
                let duringEntry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                #expect(abs(duringEntry.minY - entry.minY) < 0.5, "the swap moves nothing")

                await settle(window, hosting, turns: 120) { offer.phase == .retired }
                await settle(window, hosting, turns: 40) { false }
                #expect(offer.phase == .retired)
                #expect(TourOfferLineOracle.drawn == nil, "the line has gone")
                let afterEntry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                let afterRow = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.offerRowKey))
                #expect(abs(afterEntry.minY - entry.minY) < 0.5,
                        "its leaving moves nothing: the box is where it was")
                #expect(abs(afterRow.height - row.height) < 0.5, "the row keeps its height")
            }
        }
        #endif
    }
}
