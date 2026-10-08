//
//  TourTests.swift
//  VariorumTests
//
//  13s-b U2 — THE ONBOARDING TOUR, the app's half (mockup v5, approved
//  R-13s-27). The rule is walked headlessly card by card in the core
//  (`TourWalkTests`); these pin what only the app can show:
//
//  · the WORDS — every card equals the approved fifth draft exactly, except
//    the five departures the U2 RECORD carries (each pinned as the one
//    replacement it is), and the tone rules hold (no em dash, no emoji, no
//    shouting caps, no main-leg time promise — A5);
//  · the RING — an anchored door rings itself only while lit, registers with
//    a tour that starts after it appeared, and leaves when it leaves; Write's
//    ⑂ badge is found read-only by the editor's own identifier convention;
//  · the ENGINE — the rule's effects reach the window's doors exactly once;
//  · the ENTRY — the offer's "yes"/Help's door starts the tour at step 1 on
//    the Bookcase in the REAL shell, releases the quick entry's caret
//    (W-U1a-1), rings the real sidebar and the real Bookcase row with the
//    card beside them, and End tour retires the offer as ended; a second
//    request starts over (Q12).
//
//  Every offer model sits on a throwaway defaults suite (the test host IS the
//  dev-store app — `TourOfferLineTests`' reason).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The words

@MainActor
@Suite("13s-b U2 — the tour's words")
struct TourScriptTests {
    /// The approved fifth draft, VERBATIM from mockup v5's frames
    /// (`notes/plans/13s-mockups/onboarding-tour.html`) — title and body.
    static let approved: [Tour.Step: (String, String)] = [
        .navigation: ("Navigation", "Everything lives in one of the places on the left. Bookcase holds your books. Library is everything, searchable. Pool holds notes that aren't in a book, and Snippets keeps pieces of text you reuse between notes."),
        .seededBook: ("Sherlock Holmes, in Variorum", "The adventures of sherlock holmes comes with the app, so you can try everything on real writing. Click into it."),
        .insideBook: ("Inside a book", "A book opens on its Outline: every chapter, and the beginning of every note. A book works like a scrapbook. Put a note in and it stays there. Click into A Scandal in Bohemia."),
        .write: ("Write", "Notes open in Write. Everything autosaves as you type; commit \u{2318}S in the bottom bar keeps a savepoint of a moment worth keeping. Scroll to the middle of the note and click into a paragraph there."),
        .makeTake: ("Make a take", "A block can keep more than one version of itself. These are takes, like takes in film, and they are the heart of Variorum. Click Takes in the bottom bar, then \u{FF0B} new take (branch), and change a few words."),
        .takeIcon: ("The take icon", "The \u{03C8}2 in the margin marks any block that keeps more than one version. Click into it any time to see them. Click into it now, then Open Takes mode."),
        .takesMode: ("Both takes, side by side", "This is Takes mode: the whole note, with every version of every block. The \u{2713} take is what the note says. Click into a take to work in it; its \u{2713} makes it the one the page shows. The original keeps its own card."),
        .deeperModes: ("Three more, for later", "Lenses shows different takes of this note side by side. Compare sets other notes beside this one. Blocks is a workbench for many blocks at once. The field guide teaches each of them."),
        .placeFollows: ("Your place follows you", "Bounce between Write (\u{2318}1) and Takes (\u{2318}2) as you like. Then click the book icon and pick Index, the book's own view of its notes. Your paragraph is still in focus, one level up. Your place follows you everywhere."),
        .downAndUp: ("Down and up", "In a book, the selected note's edit here door drops you back into it, and the book icon brings you up again. The ladder runs both directions. Click into it."),
        .home: ("Head home", "When you're done exploring, Bookcase in the sidebar heads home. Click into it."),
        .ownNote: ("One of your own", "The dashed line at the bottom reads new note, just start typing. Type a first line and press \u{23CE} to open your first note. No book needed; it waits in the Pool until you give it one."),
        .legStar: ("Star a note", "Click the star. Starred notes rise to the top of the sidebar, and the starred notes gathering on your Bookcase collects them automatically."),
        .legTags: ("Organize with tags", "The \u{FF03} on the masthead adds a tag. Tag a note ideas, and a gathering made from ideas shows it on its own. Make the tag."),
        .legBook: ("Put it in a book", "Your note has been waiting here in the Pool. Click into add to book, or make a new book around it. A note can sit in more than one book."),
        .legSnippets: ("Snippets", "Pieces of text you reuse between notes live here: a phrase, a quote, a line you cut. From inside any note, the snippets panel brings them alongside so you can pull one in. The snippet stays for next time."),
        .legEnd: ("The field guide", "Everything deeper lives in the field guide: takes in depth, divide and merge, books that collect, privacy. Interactive lessons, in order or as needed. That's the tour. Go write."),
    ]

    /// **The only departures from the frozen copy** — each a BUILD-VERIFY
    /// resolution or a fact the real app forced, each recorded in the U2
    /// RECORD with its alternative (P-U2-1/2/3/5 and BUILD-VERIFY 2).
    static let departures: [Tour.Step: (from: String, to: String)] = [
        .takeIcon: ("The \u{03C8}2 in the margin", "The \u{2442}2 in the margin"),
        .takesMode: ("its \u{2713} makes it the one the page shows",
                     "choose, at the top of its card, makes it the one the page shows"),
        .placeFollows: ("Your paragraph is still in focus, one level up.",
                        "Your note is still selected there, one level up."),
        .legStar: ("Click the star.", "Right-click your note under Open in the sidebar and choose Star."),
        .legSnippets: ("the snippets panel", "the Scraps panel"),
    ]

    @Test func everyCardIsTheApprovedDraftExceptTheRecordedDepartures() throws {
        for step in Tour.Step.allCases where step != .endCard {
            let (title, approvedBody) = try #require(Self.approved[step], "\(step) has approved words")
            let card = try #require(TourScript.card(step), "\(step) has a card")
            #expect(card.title == title, "\(step): the title is the approved one")
            var expected = approvedBody
            if let departure = Self.departures[step] {
                #expect(approvedBody.contains(departure.from), "\(step): the departure names real words")
                expected = approvedBody.replacingOccurrences(of: departure.from, with: departure.to)
            }
            #expect(card.body == expected, "\(step): \(card.body)")
        }
        #expect(TourScript.card(.endCard) == nil, "the end card has its own words")
        // The end card, verbatim (A3's restaged fork; A6's ⌘J line).
        #expect(TourScript.endTitle == "That's the tour.")
        #expect(TourScript.endBody
                == "Navigation on the left. Books on the Bookcase. Takes on any block. Your place follows you.")
        #expect(TourScript.endAside
                == "readme, a short welcome note, is waiting in your Library. And \u{2318}J opens today's journal entry, whenever you want one.")
        #expect(TourScript.keepGoing == "Keep going: two more minutes on stars, tags, books and snippets")
        #expect(TourScript.openFieldGuide == "Open the field guide, every feature as a lesson")
        #expect(TourScript.done == "Done, go write")
    }

    /// The departures quote the doors they name — a rename cannot strand them.
    @Test func theDeparturesQuoteTheDoorsTheyName() throws {
        #expect(PostDetailView.scrapsDoorTitle == "Scraps")
        #expect(StarCopy.starRow == "Star")
        #expect(WorkspaceNaming.openSectionHeader == "Open")
        #expect(NoteBoxCopy.editDoor == "edit here")
        #expect(try #require(TourScript.card(.legSnippets)).body
                .contains("the \(PostDetailView.scrapsDoorTitle) panel"))
        #expect(try #require(TourScript.card(.downAndUp)).body.contains(NoteBoxCopy.editDoor))
        // Step 6 says the badge's REAL count.
        #expect(try #require(TourScript.card(.takeIcon, takeCount: 3)).body.hasPrefix("The \u{2442}3 "))
    }

    /// When the mockup is in the tree, the approved table above IS its text
    /// (a drift in either is caught here; the table stands alone if the
    /// mockup is ever retired from the repo).
    @Test func theApprovedTableIsTheMockupsOwnText() throws {
        let mockup = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // the repo
            .appendingPathComponent("notes/plans/13s-mockups/onboarding-tour.html")
        guard let html = try? String(contentsOf: mockup, encoding: .utf8) else { return }
        for (step, words) in Self.approved {
            #expect(html.contains("\"\(words.0)\""), "\(step)'s title is the mockup's")
            #expect(html.contains("`\(words.1)`"), "\(step)'s body is the mockup's")
        }
        for words in [TourScript.endTitle, TourScript.endBody, TourScript.endAside,
                      TourScript.keepGoing, TourScript.openFieldGuide, TourScript.done] {
            #expect(html.contains(words), "the end card's \"\(words)\" is the mockup's")
        }
    }

    @Test func theCountLineReadsInSentenceCase() {
        #expect(TourScript.label(.main(number: 1, secondBeat: false)) == "Step 1 of 11")
        #expect(TourScript.label(.main(number: 10, secondBeat: true)) == "Step 10 of 11 \u{00B7} and home")
        #expect(TourScript.label(.leg(number: 1)) == "Keep going \u{00B7} 1 of 4")
        #expect(TourScript.label(.legEnd) == "The end")
        #expect(TourScript.label(.endCard) == nil)
        #expect(TourScript.next == "next \u{27F6}")
        #expect(TourScript.endTour == "End tour")
    }

    /// R-13s-22 (no em dashes, no emoji, her calm register), her caps ban
    /// (R-13s-30 — sentence case, never a shouted word), and A5 (no time
    /// promise on the main leg; "two more minutes" lives on the fork's first
    /// door only).
    @Test func theToneRulesHoldOnEveryRenderedString() {
        var strings: [String] = [
            TourScript.endTitle, TourScript.endBody, TourScript.endAside, TourScript.keepGoing,
            TourScript.openFieldGuide, TourScript.done, TourScript.next, TourScript.endTour,
        ]
        for step in Tour.Step.allCases {
            if let card = TourScript.card(step) { strings += [card.title, card.body] }
            if let label = TourScript.label(Tour.position(of: step)) { strings.append(label) }
        }
        for text in strings {
            #expect(!text.contains("\u{2014}"), "no em dash: \(text)")
            #expect(!text.unicodeScalars.contains { $0.properties.isEmojiPresentation },
                    "no emoji: \(text)")
            for word in text.split(whereSeparator: { !$0.isLetter }) where word.count >= 2 {
                #expect(word != word.uppercased() || word.lowercased() == word.uppercased(),
                        "no shouting caps: \(word) in \(text)")
            }
            if text != TourScript.keepGoing {
                #expect(!text.lowercased().contains("minute"), "A5: no time promise: \(text)")
            }
        }
    }

    /// **The ⑂ badge coupling** — the locator finds Write's badge by the two
    /// facts the editor's badge overlay gives it (the block id as its
    /// identifier, a `⑂N` title). Pinned at the source so a change there
    /// cannot leave the tour ringing nothing silently.
    @Test func theBadgeLocatorsConventionIsTheEditorsOwn() throws {
        #expect(TourScript.takeBadgeGlyph == "\u{2442}")
        let editor = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Editor/EditorView.swift"),
            encoding: .utf8)
        #expect(editor.contains("button.title = \"\u{2442}\\(badge.variantCount)\""))
        #expect(editor.contains("button.identifier = NSUserInterfaceItemIdentifier(blockID)"))
    }
}

// MARK: - The ring

@MainActor
@Suite("13s-b U2 — the tour's ring", .serialized)
struct TourSpotlightTests {
    @Test func theFirstCandidateOnScreenLightsAndDoorsCountTheirCopies() {
        let spotlight = TourSpotlight()
        spotlight.setGroups([[.bookcaseRow("b"), .sidebarArea(.bookcase)], [.panelOpenTakesMode]])
        #expect(spotlight.lit.isEmpty, "nothing on screen, nothing lit")
        spotlight.arrive(.sidebarArea(.bookcase))
        #expect(spotlight.lit == [.sidebarArea(.bookcase)], "the road back, while the row is away")
        spotlight.arrive(.bookcaseRow("b"))
        spotlight.arrive(.bookcaseRow("b"))
        #expect(spotlight.lit == [.bookcaseRow("b")], "the row wins once it is drawn")
        spotlight.depart(.bookcaseRow("b"))
        #expect(spotlight.lit == [.bookcaseRow("b")], "one copy left still counts")
        spotlight.depart(.bookcaseRow("b"))
        #expect(spotlight.lit == [.sidebarArea(.bookcase)])
        spotlight.arrive(.panelOpenTakesMode)
        #expect(spotlight.lit == [.sidebarArea(.bookcase), .panelOpenTakesMode], "one per group")
    }

    @Test func theCardSitsBesideTheFirstGroupsRingUnlessItLivesInThePanel() {
        let spotlight = TourSpotlight()
        spotlight.setGroups([[.panelNewTake]])
        spotlight.arrive(.panelNewTake)
        spotlight.report(CGRect(x: 1, y: 2, width: 3, height: 4), for: .panelNewTake)
        #expect(spotlight.isLit(.panelNewTake))
        #expect(spotlight.cardAnchor == nil, "a sheet's frame is another window's: the corner")
        spotlight.setGroups([[.barTakes]])
        spotlight.arrive(.barTakes)
        let frame = CGRect(x: 10, y: 20, width: 30, height: 12)
        spotlight.report(frame, for: .barTakes)
        #expect(spotlight.cardAnchor == .barTakes)
        #expect(spotlight.cardAnchorFrame == frame)
        spotlight.depart(.barTakes)
        #expect(spotlight.cardAnchorFrame == nil, "a door that left takes its frame with it")
    }

    @Test func aFoundAnchorIsPresentExactlyWhileItIsFound() {
        let spotlight = TourSpotlight()
        spotlight.setGroups([[.takeBadge("k")]])
        let frame = CGRect(x: 5, y: 5, width: 20, height: 14)
        spotlight.setFound(.takeBadge("k"), frame: frame)
        #expect(spotlight.lit == [.takeBadge("k")])
        #expect(spotlight.cardAnchorFrame == frame)
        spotlight.setFound(.takeBadge("k"), frame: nil)
        #expect(spotlight.lit.isEmpty)
    }

    /// A door registers with a tour that starts AFTER it appeared (the
    /// `onChange` road `onAppear` cannot see), rings only while lit (its ring
    /// is what reports the frame), and is inert with no tour at all.
    @Test func anAnchoredDoorRingsItselfOnlyWhileLitAndJoinsALateTour() async throws {
        let holder = SpotlightHolder()
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: 420, height: 260),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnchorRig(holder: holder))
        window.contentView = hosting
        window.orderFrontRegardless()
        defer {
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting, turns: 10) { false }

        let spotlight = TourSpotlight()
        spotlight.setGroups([[.barTakes, .quickEntry]])
        holder.spotlight = spotlight
        await settle(window, hosting) { (spotlight.presence[.quickEntry] ?? 0) > 0 }
        #expect(spotlight.presence[.barTakes] == 1, "the late tour found the door already there")
        #expect(spotlight.presence[.quickEntry] == 1)
        await settle(window, hosting) { spotlight.frames[.barTakes] != nil }
        #expect(spotlight.lit == [.barTakes])
        #expect(spotlight.frames[.barTakes] != nil, "the lit door's ring drew and reported")
        #expect(spotlight.frames[.quickEntry] == nil, "an unlit door draws no ring")

        holder.showsFirst = false
        await settle(window, hosting) { spotlight.presence[.barTakes] == nil }
        #expect(spotlight.presence[.barTakes] == nil, "a door that leaves departs")
        await settle(window, hosting) { spotlight.lit == [.quickEntry] }
        #expect(spotlight.lit == [.quickEntry], "the ring re-anchors on the next candidate")

        holder.spotlight = nil
        await settle(window, hosting, turns: 10) { false }
        #expect(spotlight.presence[.quickEntry] == 1,
                "the ended tour is simply gone — nothing writes to it any more")
    }

    /// The ⑂ badge, found read-only by its identifier and glyph, in the
    /// probe's own space.
    @Test func theBadgeLocatorFindsOnlyTheBadgeOfTheBlockAsked() throws {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.close() }
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        window.contentView = root
        let probe = TourWindowProbe.ProbeView(frame: root.bounds)
        root.addSubview(probe)
        let page = NSView(frame: NSRect(x: 50, y: 40, width: 300, height: 200))
        root.addSubview(page)
        let badge = NSButton(title: "\u{2442}2", target: nil, action: nil)
        badge.identifier = NSUserInterfaceItemIdentifier("block-1")
        badge.frame = NSRect(x: 240, y: 30, width: 30, height: 18)
        page.addSubview(badge)
        let decoy = NSButton(title: "comments", target: nil, action: nil)
        decoy.identifier = NSUserInterfaceItemIdentifier("block-2")
        page.addSubview(decoy)

        let found = try #require(TourBadgeLocator.frame(blockID: "block-1", in: probe))
        let expected = probe.convert(badge.bounds, from: badge)
        #expect(found == expected)
        #expect(TourBadgeLocator.frame(blockID: "block-2", in: probe) == nil,
                "a button without the badge's glyph is not the badge")
        #expect(TourBadgeLocator.frame(blockID: "block-9", in: probe) == nil)
        badge.isHidden = true
        #expect(TourBadgeLocator.frame(blockID: "block-1", in: probe) == nil, "a hidden badge is not on screen")
    }
}

@MainActor
@Observable
private final class SpotlightHolder {
    var spotlight: TourSpotlight?
    var showsFirst = true
}

private struct AnchorRig: View {
    let holder: SpotlightHolder

    var body: some View {
        VStack(spacing: 20) {
            if holder.showsFirst {
                Text("Takes").padding(6).tourAnchor(.barTakes)
            }
            Text("new note").padding(6).tourAnchor(.quickEntry)
            Text("not an anchor").padding(6).tourAnchor(nil)
        }
        .frame(width: 300, height: 200)
        .environment(holder.spotlight)
    }
}

// MARK: - The engine

@MainActor
@Suite("13s-b U2 — the tour engine's doors", .serialized)
struct TourEngineTests {
    @MainActor
    final class DoorLog {
        var navigations: [Tour.Place] = []
        var fieldGuides = 0
        var completions = 0
        var finishes: [Bool] = []

        var doors: TourEngine.Doors {
            TourEngine.Doors(
                navigate: { self.navigations.append($0) },
                openFieldGuide: { self.fieldGuides += 1 },
                recordCompleted: { self.completions += 1 },
                finished: { self.finishes.append($0) })
        }
    }

    private func withSession(_ body: (AppSession) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    static let landmarks = Queries.TourLandmarks(
        seededBookID: "sherlock", firstStoryID: "scandal", fieldGuideID: "guide")

    @Test func aStartAwayFromTheBookcaseTakesHerThereAndRingsTheSidebar() async throws {
        try await withSession { session in
            let log = DoorLog()
            let engine = TourEngine(
                session: session, landmarks: Self.landmarks,
                facts: Tour.Facts(place: .note("n")), doors: log.doors)
            #expect(engine.state.step == .navigation)
            #expect(log.navigations == [.area(.bookcase)])
            #expect(engine.spotlight.groups == [[.sidebarAreas]])
            engine.observe(Tour.Facts(place: .area(.bookcase)))
            engine.next()
            #expect(engine.state.step == .seededBook)
            #expect(engine.spotlight.groups == [[.bookcaseRow("sherlock")]])
        }
    }

    @Test func endTourFinishesOnceAsEndedAndTheSpotlightGoesDark() async throws {
        try await withSession { session in
            let log = DoorLog()
            let engine = TourEngine(
                session: session, landmarks: Self.landmarks,
                facts: Tour.Facts(place: .area(.bookcase)), doors: log.doors)
            engine.endTour()
            engine.endTour()
            engine.next()
            #expect(log.finishes == [false], "ended, once — the second press is a no-op")
            #expect(engine.spotlight.groups.isEmpty)
            #expect(log.completions == 0)
        }
    }

    @Test func theEndCardRecordsCompletionAndTheFieldGuideChoiceOpensIt() async throws {
        try await withSession { session in
            let log = DoorLog()
            let engine = TourEngine(
                session: session, landmarks: Self.landmarks,
                facts: Tour.Facts(place: .area(.bookcase)), doors: log.doors)
            engine.next()
            engine.observe(.init(place: .book("sherlock")))
            engine.observe(.init(place: .note("scandal"), noteMode: .write))
            func write(_ block: String, _ ordinal: Int, takes: Int = 1) -> Tour.Facts {
                .init(place: .note("scandal"), noteMode: .write,
                      caret: .init(noteID: "scandal", blockID: block, ordinal: ordinal, takeCount: takes))
            }
            engine.observe(write("b1", 1))
            engine.observe(write("b40", 40))
            engine.observe(write("b40", 40, takes: 2))
            engine.observe(.init(place: .note("scandal"), noteMode: .takes))
            engine.next()
            engine.next()
            engine.next()
            engine.observe(.init(place: .book("sherlock"), bookNoteLive: true))
            engine.observe(.init(place: .area(.bookcase)))
            #expect(engine.state.step == .ownNote)
            engine.observe(.init(
                place: .note("mine"), noteMode: .write,
                note: .init(noteID: "mine", starred: false, tagCount: 0, bookCount: 0)))
            #expect(engine.state.step == .endCard)
            #expect(log.completions == 1, "the end card retires the offer as completed at once")
            engine.choose(.fieldGuide)
            #expect(log.fieldGuides == 1)
            #expect(log.finishes == [true])
        }
    }

    /// The window's facts, assembled: a caret only for WRITE on the note she
    /// is in, its take count from the badges, the panel, the box only in a
    /// book, and the star through the stars model.
    @Test func theWindowsFactsSpeakTheRulesWords() {
        let caret = TourCaretReading(
            postID: "n", blockID: "b", ordinal: 4, takeCounts: ["b": 2, "c": 3],
            panelBlockID: "b")
        let inWrite = TourPlaces.facts(
            selection: .post("n"), detail: ("n", .write), caret: caret, bookNoteLive: true,
            note: nil, isStarred: { _ in false })
        #expect(inWrite.place == .note("n"))
        #expect(inWrite.noteMode == .write)
        #expect(inWrite.caret == Tour.Caret(
            noteID: "n", blockID: "b", ordinal: 4, takeCount: 2, panelOpen: true))
        #expect(!inWrite.bookNoteLive, "the box speaks only for a book")

        let inTakes = TourPlaces.facts(
            selection: .post("n"), detail: ("n", .takes), caret: caret, bookNoteLive: false,
            note: nil, isStarred: { _ in false })
        #expect(inTakes.caret == nil, "Write's caret is Write's")
        let elsewhere = TourPlaces.facts(
            selection: .post("m"), detail: ("n", .write), caret: caret, bookNoteLive: false,
            note: nil, isStarred: { _ in false })
        #expect(elsewhere.noteMode == nil && elsewhere.caret == nil, "another note's detail is not hers")

        let book = TourPlaces.facts(
            selection: .reading("r"), detail: (nil, nil), caret: nil, bookNoteLive: true,
            note: ("mine", Queries.TourNoteFacts(tagCount: 1, bookCount: 2)),
            isStarred: { $0 == "mine" })
        #expect(book.place == .book("r"))
        #expect(book.bookNoteLive)
        #expect(book.note == Tour.NoteFacts(noteID: "mine", starred: true, tagCount: 1, bookCount: 2))

        for selection: SidebarSelection in [
            .shelf, .library, .poolPosts, .blocks, .archived, .post("p"), .reading("r"), .pool("g"),
        ] {
            #expect(TourPlaces.selection(TourPlaces.place(selection)) == selection)
        }
        #expect(TourPlaces.place(nil) == .area(.bookcase), "no selection draws the Bookcase")
    }
}

// MARK: - The entry, in the real shell

@MainActor
@Suite("13s-b U2 — the tour starts in the real shell", .serialized)
struct TourEntryTests {
    /// The offer's "yes" and Help ▸ Take the Tour both arrive as the router's
    /// request (U1a piece 5). In the REAL shell: the tour starts at step 1
    /// with its landmarks found, the offer steps aside, the quick entry's
    /// caret is released (W-U1a-1), the real sidebar rings and the card sits
    /// beside it, step 2 rings the real Bookcase row with the card off it;
    /// End tour retires the offer as ENDED; and a request always starts over
    /// at step 1 (Q12).
    @Test func helpsDoorStartsTheTourAtStepOneAndEndTourRetiresTheOffer() async throws {
        #if DEBUG
        let suite = "tour-entry-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        // The shell's Bookcase reads its fold state from the dev app's REAL
        // defaults (the test host is the dev app); a section folded there
        // would hide the row this pin rings. Folded open for the pin, and
        // put back exactly as found.
        let foldKey = "bookcase.collapsed"
        let foldWas = UserDefaults.standard.object(forKey: foldKey)
        UserDefaults.standard.removeObject(forKey: foldKey)
        defer {
            if let foldWas { UserDefaults.standard.set(foldWas, forKey: foldKey) }
            else { UserDefaults.standard.removeObject(forKey: foldKey) }
        }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let sherlock = try ops.createReading(name: SampleLibrarySeeder.bookName, kind: .book)
            let scandal = try ops.createPost(title: TourScript.firstStoryTitle)
            try ops.addPostToReading(scandal.id, to: sherlock.id)
            let guide = try ops.createReading(name: TutorialSeeder.bookName, kind: .book)
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
            await settle(window, hosting, turns: 40) { false }
            await settle(window, hosting) { window.firstResponder is NSTextView }
            #expect(window.firstResponder is NSTextView,
                    "the precondition W-U1a-1 is about: the Bookcase put the caret in its quick entry")

            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay != nil }
            let engine = try #require(TourOracle.overlay, "the request started a tour")
            #expect(engine.state.step == .navigation)
            #expect(engine.state.seededBookID == sherlock.id)
            #expect(engine.state.firstStoryID == scandal.id)
            #expect(engine.state.fieldGuideID == guide.id)
            #expect(offer.phase == .touring, "the line steps aside; nothing is remembered yet")
            #expect(defaults.string(forKey: TourOfferModel.recordKey) == nil)
            #expect(!(window.firstResponder is NSTextView),
                    "W-U1a-1: the quick entry's caret is released (\(String(describing: window.firstResponder)))")

            // Step 1 rings the REAL sidebar's five places, the card beside them.
            await settle(window, hosting) {
                engine.spotlight.frames[.sidebarAreas] != nil && TourOracle.cardFrame != nil
            }
            #expect(engine.spotlight.lit == [.sidebarAreas])
            let areas = try #require(engine.spotlight.frames[.sidebarAreas])
            let card1 = try #require(TourOracle.cardFrame)
            #expect(!card1.intersects(areas), "the card never covers what it points at")

            // Step 2 rings the REAL Bookcase row of the seeded book.
            engine.next()
            await settle(window, hosting) {
                engine.spotlight.frames[.bookcaseRow(sherlock.id)] != nil
            }
            #expect(engine.state.step == .seededBook)
            #expect(engine.spotlight.lit == [.bookcaseRow(sherlock.id)])
            await settle(window, hosting, turns: 30) { false }
            let row = try #require(engine.spotlight.frames[.bookcaseRow(sherlock.id)])
            let card2 = try #require(TourOracle.cardFrame)
            #expect(!card2.intersects(row), "the card sits off the ringed row (\(card2) vs \(row))")
            let content = try #require(window.contentView).bounds
            #expect(card2.width <= content.width && card2.height <= content.height)

            // A request while touring starts over at step 1 (Q12).
            router.tourRequested = true
            await settle(window, hosting) {
                TourOracle.overlay.map { $0 !== engine } ?? false
            }
            let restarted = try #require(TourOracle.overlay)
            #expect(restarted !== engine)
            #expect(restarted.state.step == .navigation)

            // End tour: the overlay goes, the offer retires as ENDED.
            restarted.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
            #expect(TourOracle.overlay == nil)
            #expect(offer.phase == .retired)
            #expect(defaults.string(forKey: TourOfferModel.recordKey)
                    == TourOffer.Record.ended.rawValue)
            #expect(TourOfferModel(defaults: defaults).phase == .retired,
                    "ended before the end: the offer never comes back (R-13s-13)")
        }
        #endif
    }
}

// MARK: - The settle loop (the U1a pins' own shape)

@MainActor
private func pump() {
    RunLoop.main.run(until: Date().addingTimeInterval(0.02))
}

@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView, turns: Int = 200, until predicate: () -> Bool
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
