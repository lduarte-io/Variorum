//
//  TourOfferCardTests.swift
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
struct TourOfferCardTests {
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
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil,
                    "looking writes nothing")
        }
    }

    /// "not now" → the help-road sentence → gone; the answer is kept AT the
    /// press, and the next launch has neither a line nor a row.
    @Test func notNowShowsTheHelpRoadThenRetiresForGood() async throws {
        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults, helpRoadDuration: .milliseconds(150))
            model.decline()
            #expect(model.line == .helpRoad)
            #expect(defaults.string(forKey: TourOfferModel.recordKey)
                    == TourOffer.Record.declined.rawValue,
                    "kept at the press — a quit during the sentence never re-offers")
            for _ in 0..<100 where model.phase != .retired {
                try await Task.sleep(for: .milliseconds(20))
            }
            #expect(model.phase == .retired, "the sentence has its few seconds, then goes")
            #expect(model.line == nil)

            let nextLaunch = TourOfferModel(defaults: defaults)
            #expect(nextLaunch.phase == .retired, "R-13s-13: the offer never comes back")
            #expect(nextLaunch.line == nil, "and a later launch draws no card at all")
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
        // VX-292 U4 (VX-559; R-292-5/12) — the card's words, the brief's.
        #expect(TourOfferCopy.title == "Welcome to Variorum.")
        #expect(TourOfferCopy.sentence == "A short tour shows you around: books, notes, and takes.")
        #expect(TourOfferCopy.yes == "yes")
        #expect(TourOfferCopy.no == "no")
        #expect(TourOfferCopy.helpRoad
                == "This can always be started from Help \u{25B8} \(CapabilityRegistry.capability(.takeTour).verb).")
        #expect(CapabilityRegistry.capability(.takeTour).verb == TourOfferCopy.menuTitle)
        // R-13s-22's tone ruling: no em dash anywhere in the card's words.
        for words in [TourOfferCopy.title, TourOfferCopy.sentence, TourOfferCopy.helpRoad] {
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
        // VX-602 (the VX-439 run — a DELIBERATE pin update, her words: "take
        // the tour should be the onboarding tutorial still"): the door and the
        // sentence that names it, re-worded together.
        #expect(TourOfferCopy.menuTitle == "Take the Onboarding Tutorial")
        #expect(TourOfferCopy.helpRoad == "This can always be started from Help \u{25B8} Take the Onboarding Tutorial.")
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

    // MARK: - The card in the band

    // (13s-b U1a's `theLineSitsAboveTheBarOnTheRightAndItsLeavingMovesNothing`
    // — the quiet line's place below the box and its held row — retired with
    // the line at VX-292 U4 piece 1; the band's composition pins land at
    // piece 2.)
}
