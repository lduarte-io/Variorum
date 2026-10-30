//
//  TourOfferCardTests.swift
//  VariorumTests
//
//  13s-b U1a, piece 2 — the first-open TOUR OFFER (her rulings R-13s-2, -6,
//  -13; mockup v5's "first open" and "not now" frames), REBUILT AS A CARD at
//  VX-292 U4 (VX-559; R-292-5 and R-292-12, `notes/plans/vx-292-onboarding.md`
//  §U4). The lifecycle's rule is pinned headless in the core
//  (`TourOfferTests`, unchanged); these pin the app's half: the device's ONE
//  local record (written where the rule says, never anywhere else, with the
//  values every earlier answer was written in), the help-road timer, the
//  card's words and its two doors (yes · no, nothing else), and the card's
//  place in the Bookcase's BAND — between the shelf listing and the quick
//  entry, the main column's full width, above the words card — where its
//  help-road swap and its leaving move NOTHING under it.
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
@Suite("VX-292 U4 — the first-open tour offer, a card in the band", .serialized)
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

    /// The app's own sources, for the pins that read how a door is wired.
    private static let app = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum
        .appendingPathComponent("Variorum")

    /// A source file's CODE lines (comment lines dropped), so a pin about
    /// what the code does is never satisfied — or broken — by its prose.
    private static func code(_ relative: String) throws -> String {
        try String(contentsOf: app.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    // MARK: - The device's record

    /// A device that never answered is offered the card, and looking writes
    /// nothing. **The stored values are the line's, unchanged** (the brief:
    /// "the stored record values UNCHANGED so existing stores' answers
    /// hold"): every answer a device gave the quiet line still retires the
    /// card at launch. (VX-292 U4 — a JUSTIFIED EDIT of the 13s pin
    /// `aFreshDeviceIsOfferedAndKeepsARowForTheLine`: the held row retired
    /// with the line; the record half is new.)
    @Test func aFreshDeviceIsOfferedTheCardAndEveryEarlierAnswerHolds() async throws {
        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults)
            #expect(model.phase == .offering)
            #expect(model.line == .offer)
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil,
                    "looking writes nothing")
        }
        #expect(TourOfferModel.recordKey == "variorum.tour.offer")
        #expect(TourOffer.Record.allCases.map(\.rawValue) == ["declined", "completed", "ended"],
                "the values every earlier answer was written in")
        for record in TourOffer.Record.allCases {
            try await withDefaults { defaults in
                defaults.set(record.rawValue, forKey: TourOfferModel.recordKey)
                let model = TourOfferModel(defaults: defaults)
                #expect(model.phase == .retired, "\(record): an earlier answer holds")
                #expect(model.line == nil, "\(record): no card")
            }
        }
    }

    /// "no" → the help-road sentence → gone; the answer is kept AT the press,
    /// and the next launch has no card (R-13s-13, R-292-12).
    @Test func noShowsTheHelpRoadThenRetiresForGood() async throws {
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

    /// "yes" (or Help's door): the card steps aside and NOTHING is kept — a
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

    // MARK: - The doors and the words

    /// **R-292-12 — the doors are yes · no ONLY: no ✕, no snooze.** The card
    /// draws its doors from ONE table (`TourOfferCard.Door`), each button
    /// calling `press(_:)`; this pin presses them without a pointer. "yes" is
    /// the tour's one entry and nothing else (the card's stepping aside is
    /// the entry's `tourStarted()`, never the button's own); "no" is
    /// `decline()` — the help road, the answer kept at the press. The card's
    /// code draws exactly one `Button` (inside the table's `ForEach`) and no
    /// ✕ glyph, so no door can stand beside the table's two.
    @Test func theDoorsAreYesAndNoAndNothingElse() async throws {
        #expect(TourOfferCard.Door.allCases == [.yes, .no])
        #expect(TourOfferCard.Door.allCases.map(\.word) == ["yes", "no"])

        try await withDefaults { defaults in
            let model = TourOfferModel(defaults: defaults, helpRoadDuration: .seconds(60))
            var tourAsked = 0
            let card = TourOfferCard(model: model) { tourAsked += 1 }

            card.press(.yes)
            #expect(tourAsked == 1, "yes asks for the tour, once")
            #expect(model.phase == .offering, "the button itself changes nothing; the tour's entry does")
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil)

            card.press(.no)
            #expect(tourAsked == 1, "no never starts a tour")
            #expect(model.line == .helpRoad)
            #expect(defaults.string(forKey: TourOfferModel.recordKey)
                    == TourOffer.Record.declined.rawValue)
        }

        let source = try Self.code("Features/Onboarding/TourOfferCard.swift")
        #expect(source.components(separatedBy: "Button(").count - 1 == 1,
                "the card draws ONE button, its door table's")
        #expect(source.contains("ForEach(Door.allCases"))
        #expect(!source.contains("xmark"), "no ✕ (R-292-12)")
        #expect(!source.lowercased().contains("snooze") && !source.contains("later()"),
                "no snooze (R-292-12)")
    }

    /// The card's words (the U4 brief's, verbatim), and the one source the
    /// help road reads its door's name from: the registry's `.takeTour` verb,
    /// which is the Help menu's item. R-13s-22 / R-13s-30 / A5: no em dash, no
    /// emoji, no shouted word, no time promise.
    @Test func theWordsAreHersAndTheHelpRoadNamesTheMenusDoor() {
        // VX-292 U4 (VX-559; R-292-5/12) — the card's words, the brief's.
        #expect(TourOfferCopy.title == "Welcome to Variorum.")
        #expect(TourOfferCopy.sentence == "A short tour shows you around: books, notes, and takes.")
        #expect(TourOfferCopy.yes == "yes")
        #expect(TourOfferCopy.no == "no")
        #expect(TourOfferCopy.helpRoad
                == "This can always be started from Help \u{25B8} \(CapabilityRegistry.capability(.takeTour).verb).")
        #expect(CapabilityRegistry.capability(.takeTour).verb == TourOfferCopy.menuTitle)
        for words in [TourOfferCopy.title, TourOfferCopy.sentence, TourOfferCopy.yes,
                      TourOfferCopy.no, TourOfferCopy.helpRoad] {
            #expect(!words.contains("\u{2014}"), "no em dash: \(words)")
            #expect(!words.unicodeScalars.contains { $0.properties.isEmojiPresentation },
                    "no emoji: \(words)")
            for word in words.split(whereSeparator: { !$0.isLetter }) where word.count >= 2 {
                #expect(word != word.uppercased(), "no shouting caps: \(word) in \(words)")
            }
            #expect(!words.lowercased().contains("minute"), "A5: no time promise: \(words)")
        }
    }

    // MARK: - Help ▸ Take the Onboarding Tutorial, and the card's yes

    /// The standing door the help-road sentence names: in the Help menu,
    /// declared AND rendered (the registry walk's `menuRendered` set), a
    /// request the window adopts with the ONE entry the card's "yes" calls.
    /// The sentence is pinned literally so the copy pass reads the exact
    /// words a stranger sees. VX-292 U4 adds the card's half: the shell hands
    /// the Bookcase the card WITH that one entry, and the entry steps the
    /// card aside.
    @Test func theHelpMenuCarriesTheTourDoorTheSentenceNames() throws {
        // VX-602 (the VX-439 run — a DELIBERATE pin update, her words: "take
        // the tour should be the onboarding tutorial still"): the door and the
        // sentence that names it, re-worded together; VX-292 U4 (R-292-5):
        // the sentence's new words, the door's name kept.
        #expect(TourOfferCopy.menuTitle == "Take the Onboarding Tutorial")
        #expect(TourOfferCopy.helpRoad == "This can always be started from Help \u{25B8} Take the Onboarding Tutorial.")
        let doors = CapabilityRegistry.capability(.takeTour).doors
        #expect(doors.contains(.menuBar) && doors.contains(.surface))
        #expect(EditorCommands.menuRendered.contains(.takeTour))
        #expect(TourOfferCard.surfaceCapabilities == [.takeTour], "the card renders the line's one act")
        #expect(ShellRouter().tourRequested == false, "nothing asks for a tour by itself")

        let commands = try Self.code("EditorCommands.swift")
        #expect(commands.contains(
            "Button(verb(.takeTour)) { windows.creationRouter()?.tourRequested = true }"))
        let root = try Self.code("RootView.swift")
        #expect(root.contains(".onChange(of: router.tourRequested)"))
        #expect(root.contains("TourOfferCard(model: tourOffer, onTakeTour: startTour)"),
                "the card's yes is the tour's one entry")
        #expect(root.contains("tourOfferCard") && root.contains("offerCard: tourOfferCard"),
                "the shell hands the Bookcase the card for its band")
        #expect(root.contains("tourOffer?.tourStarted()"), "and the entry steps the card aside")
    }

    // MARK: - The card in the band

    /// **The band's ORDER in the Bookcase's own code** (P-292-13; the words
    /// card's composition pin's shape, `WordsBandSurfaceTests`): the listing,
    /// then the tour card, then the words card, then the quick entry, then
    /// the bottom bar — and no slot between the entry and the bar any more
    /// (the quiet line's row retired). The geometry pin below proves the same
    /// on a mounted Bookcase; this one names the order where it is written.
    @Test func theBandDrawsTheTourCardThenTheWordsCardThenTheEntry() throws {
        let shelf = try Self.code("Features/Shelf/ShelfView.swift")
        let body = try #require(shelf.range(of: "var body: some View {"))
        let tail = shelf[body.upperBound...]
        let listing = try #require(tail.range(of: "ScrollView {"))
        let tour = try #require(tail.range(of: "if let offerCard {"))
        let words = try #require(tail.range(of: "if let wordsBand {"))
        let entry = try #require(tail.range(of: "entryBar\n"))
        let bar = try #require(tail.range(of: "hintBar\n"))
        #expect(listing.upperBound < tour.lowerBound, "the listing, then the tour card")
        #expect(tour.upperBound < words.lowerBound, "the tour card ABOVE the words card")
        #expect(words.upperBound < entry.lowerBound, "the words card above the quick entry")
        #expect(entry.upperBound < bar.lowerBound, "the quick entry above the bottom bar")
        #expect(!tail[entry.upperBound..<bar.lowerBound].contains("if let"),
                "no slot between the quick entry and the bottom bar")
    }

    /// The two roads out of the card.
    enum Road: CaseIterable, Sendable, CustomStringConvertible {
        /// "no": the help-road sentence in the same frame, then the card goes.
        case no
        /// "yes": the tour's entry steps the card aside; the tour's end retires it.
        case yes

        var description: String {
            switch self {
            case .no: "no"
            case .yes: "yes"
            }
        }
    }

    /// **Where the card sits and that it moves nothing** (VX-559's "a real
    /// card in the band"; P-292-13's stacking). On a REAL Bookcase: the card
    /// is in the band — under the strip, over the quick entry — spanning the
    /// main column at the board's own gutter; with the words card standing it
    /// sits directly ABOVE it, the words card directly above the entry; the
    /// quiet line's old spot between the entry and the bottom bar is GONE (no
    /// held row: the entry meets the bar). "no" swaps the words in the SAME
    /// frame (the card, the words card and the entry do not move a point);
    /// "yes" asks for the tour once. When the card leaves the band — the help
    /// road's end, or the tour's entry and end — nothing under it moves: the
    /// listing above takes its height. The words card's real model is
    /// Castle's (out of this unit's scope), so a stand-in of a card's height
    /// fills its slot: the pin is about the BAND's composition.
    @Test(arguments: [true, false], Road.allCases)
    func theCardSitsInTheBandAboveTheWordsCardAndItsLeavingMovesNothing(
        withWordsCard: Bool, road: Road
    ) async throws {
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
                let card = TourOfferCard(model: offer) { tourAsked += 1 }
                BookcaseRowOracle.forgetAll()
                TourOfferCardOracle.forget()
                WordsCardStandIn.frame = nil

                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 900, height: 640),
                    styleMask: [.titled, .resizable], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: ShelfView(
                    session: session, model: shelf,
                    readings: ReadingsViewModel(session: session),
                    onOpen: { _ in }, onTodaysEntry: {},
                    offerCard: AnyView(card),
                    wordsBand: withWordsCard ? AnyView(WordsCardStandIn()) : nil))
                window.contentView = hosting
                window.orderFrontRegardless()
                defer {
                    window.orderOut(nil)
                    window.close()
                }

                await settle(window, hosting) {
                    TourOfferCardOracle.drawn == .offer
                        && TourOfferCardOracle.cardFrame.map { $0.width > 100 } == true
                        && (!withWordsCard || WordsCardStandIn.frame != nil)
                        && BookcaseRowOracle.frame(BookcaseRowOracle.stripKey) != nil
                        && BookcaseRowOracle.frame(BookcaseRowOracle.entryKey) != nil
                        && BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey) != nil
                }
                await settle(window, hosting, turns: 20) { false }
                let paper = try #require(TourOfferCardOracle.cardFrame)
                let strip = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.stripKey))
                let entry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                let hint = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey))
                let width = window.contentView?.bounds.width ?? 0

                // In the band: under the strip and the listing, over the entry.
                #expect(paper.minY > strip.maxY, "under the strip (card \(paper), strip \(strip))")
                #expect(paper.maxY < entry.minY, "over the quick entry (card \(paper), entry \(entry))")
                // The main column's full width, at the board's own gutter (the
                // words card's and the shelf listing's 28 pt).
                #expect(abs(paper.minX - 28) < 1.5, "the board's leading gutter (card \(paper))")
                #expect(abs((width - paper.maxX) - 28) < 1.5,
                        "the board's trailing gutter (card \(paper), width \(width))")
                // The quiet line's held row is gone: the entry meets the bottom bar.
                #expect(abs(entry.maxY - hint.minY) < 1.5,
                        "nothing between the entry and the bottom bar (entry \(entry), bar \(hint))")
                var words: CGRect?
                if withWordsCard {
                    let band = try #require(WordsCardStandIn.frame)
                    words = band
                    // P-292-13: the tour card ABOVE the words card, one band.
                    #expect(paper.maxY <= band.minY + 0.5,
                            "the tour card sits above the words card (card \(paper), words \(band))")
                    #expect(band.minY - paper.maxY < 16, "the two cards stack as one band")
                    #expect(band.maxY <= entry.minY + 0.5 && entry.minY - band.maxY < 12,
                            "the words card sits right on the entry (words \(band), entry \(entry))")
                    #expect(abs(band.minX - paper.minX) < 1.5 && abs(band.maxX - paper.maxX) < 1.5,
                            "one column: the two cards share their edges")
                } else {
                    #expect(entry.minY - paper.maxY < 12,
                            "alone, the card sits right on the entry (card \(paper), entry \(entry))")
                }
                #expect(tourAsked == 0, "nothing starts a tour by itself")

                switch road {
                case .no:
                    card.press(.no)
                    await settle(window, hosting, turns: 60) { TourOfferCardOracle.drawn == .helpRoad }
                    await settle(window, hosting, turns: 10) { false }
                    #expect(TourOfferCardOracle.drawn == .helpRoad)
                    let during = try #require(TourOfferCardOracle.cardFrame)
                    #expect(abs(during.minY - paper.minY) < 0.5 && abs(during.height - paper.height) < 0.5,
                            "the swap keeps the card's frame (\(paper) → \(during))")
                    let duringEntry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                    #expect(abs(duringEntry.minY - entry.minY) < 0.5, "the swap moves nothing")
                    if let words {
                        let duringWords = try #require(WordsCardStandIn.frame)
                        #expect(abs(duringWords.minY - words.minY) < 0.5, "nor the words card")
                    }
                    await settle(window, hosting, turns: 120) { offer.phase == .retired }
                    #expect(offer.phase == .retired)
                case .yes:
                    card.press(.yes)
                    #expect(tourAsked == 1, "yes asks for the tour, once")
                    // The tour's entry (`RootView.startTour`) steps the card
                    // aside; the tour's end retires it (`tourDoors`).
                    offer.tourStarted()
                    await settle(window, hosting, turns: 120) { TourOfferCardOracle.drawn == nil }
                    offer.tourEnded(completed: true)
                    #expect(offer.phase == .retired)
                }

                // The card leaves the band, and nothing under it moves.
                await settle(window, hosting, turns: 120) { TourOfferCardOracle.drawn == nil }
                await settle(window, hosting, turns: 40) { false }
                #expect(TourOfferCardOracle.drawn == nil, "the card has left the band")
                #expect(TourOfferCardOracle.cardFrame == nil)
                let afterEntry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
                #expect(abs(afterEntry.minY - entry.minY) < 0.5,
                        "its leaving moves nothing: the entry is where it was")
                if let words {
                    let afterWords = try #require(WordsCardStandIn.frame)
                    #expect(abs(afterWords.minY - words.minY) < 0.5,
                            "nor the words card under it (\(words) → \(afterWords))")
                }
                #expect(TourOfferModel(defaults: defaults).line == nil,
                        "answered: a later launch draws no card")
            }
        }
        #endif
    }
}

#if DEBUG
/// A stand-in for the words card in the band's slot: a card's height inside
/// the words card's own gutter and paddings (`WordsBandCard`: 28 pt sides, 4
/// above, 8 below), reporting where the slot drew it.
private struct WordsCardStandIn: View {
    @MainActor static var frame: CGRect?

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                WordsCardStandIn.frame = $0
            }
            .padding(.horizontal, 28)
            .padding(.top, 4)
            .padding(.bottom, 8)
    }
}
#endif
