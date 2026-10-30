//
//  TourTests.swift
//  VariorumTests
//
//  13s-b U2 — THE ONBOARDING TOUR, the app's half (mockup v5, approved
//  R-13s-27). The rule is walked headlessly card by card in the core
//  (`TourWalkTests`); these pin what only the app can show:
//
//  · the WORDS — every card equals the approved fifth draft exactly, except
//    the five departures the U2 RECORD carries and VX-292 U1's two Prince
//    cards (each pinned as the one replacement it is), and the tone rules
//    hold (no em dash, no emoji, no shouting caps, no main-leg time promise —
//    A5);
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
    /// VX-292 U1 (R-292-1, the Prince replaced Sherlock in the launch at
    /// VX-633): steps 2 and 3 carry the plan's U1 COPY DRAFTS — step 2's body
    /// whole (with its title, below), step 3's last sentence. The approved
    /// table above stays mockup v5's text, so its mockup pin still reads it.
    static let departures: [Tour.Step: (from: String, to: String)] = [
        .seededBook: (
            "The adventures of sherlock holmes comes with the app, so you can try everything on real writing. Click into it.",
            "the prince comes with the app, so you can try everything on real writing. Machiavelli's Italian rides under every paragraph. Click into it."),
        .insideBook: ("Click into A Scandal in Bohemia.",
                      "Click into the chapter on whether it is better to be loved or feared."),
        .takeIcon: ("The \u{03C8}2 in the margin", "The \u{2442}2 in the margin"),
        .takesMode: ("its \u{2713} makes it the one the page shows",
                     "choose, at the top of its card, makes it the one the page shows"),
        .placeFollows: ("Your paragraph is still in focus, one level up.",
                        "Your note is still selected there, one level up."),
        .legStar: ("Click the star.", "Right-click your note under Open in the sidebar and choose Star."),
        .legSnippets: ("the snippets panel", "the Scraps panel"),
    ]

    /// The one TITLE departure (VX-292 U1, R-292-1): step 2 names the book
    /// the launch seeds now.
    static let titleDepartures: [Tour.Step: (from: String, to: String)] = [
        .seededBook: ("Sherlock Holmes, in Variorum", "The Prince, in Variorum"),
    ]

    @Test func everyCardIsTheApprovedDraftExceptTheRecordedDepartures() throws {
        for step in Tour.Step.allCases where step != .endCard {
            let (approvedTitle, approvedBody) = try #require(Self.approved[step], "\(step) has approved words")
            let card = try #require(TourScript.card(step), "\(step) has a card")
            var title = approvedTitle
            if let departure = Self.titleDepartures[step] {
                #expect(approvedTitle == departure.from, "\(step): the title departure names the approved title")
                title = departure.to
            }
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

    /// **VX-292 U1 (R-292-1) — steps 2 and 3 name what a fresh store
    /// holds.** The launch seeds *The Prince* (VX-633); the tour said
    /// Sherlock, so on a fresh store its words named a book that was not
    /// there and its rings found nothing. RED ON OLD: the old card says
    /// Sherlock and the old landmark title ("A Scandal in Bohemia") is no
    /// Prince note. The book's name and the chapter's title are read from the
    /// Prince's constants, and both are proven real here: the name is the
    /// LAUNCH book's, and the title is a `%%%` line of the bundled text — the
    /// title the import stores — so neither can drift away from the seed.
    @Test func stepsTwoAndThreeNameTheBookTheLaunchSeeds() throws {
        #expect(TourScript.seededBookName == SampleLibrarySeeder.Book.launchBook.name,
                "the tour's book is the one a fresh store is born with")
        #expect(TourScript.seededBookName == SampleLibraryPrinceBook.name)
        let two = try #require(TourScript.card(.seededBook))
        #expect(two.body.hasPrefix("\(SampleLibraryPrinceBook.name) comes with the app"),
                "the card says the book's own name")
        #expect(two.title.lowercased().hasPrefix(SampleLibraryPrinceBook.name),
                "the title names the same book")
        // The toured chapter: a real seeded note title, chapter XVII.
        let titles = try SampleLibrarySeeder.loadStories(for: .prince).map(\.title)
        #expect(titles.contains(TourScript.firstStoryTitle),
                "the landmark title is a note the Prince seeds: \(TourScript.firstStoryTitle)")
        #expect(SampleLibraryPrinceBook.chapterNumber(of: TourScript.firstStoryTitle) == 17)
        #expect(TourScript.firstStoryTitle.hasSuffix("whether it is better to be loved than feared"),
                "the card's question is this chapter's")
        #expect(try #require(TourScript.card(.insideBook)).body
                .hasSuffix("Click into the chapter on whether it is better to be loved or feared."))
        // P-292-1's reasons, held: a real middle to scroll to (step 4 asks for
        // the middle), and a Ricci third take in the chapter.
        let blocks = try SampleLibrarySeeder.loadStories(for: .prince)
            .first { $0.title == TourScript.firstStoryTitle }?.text
            .split(separator: "\n").count
        #expect(blocks == 8, "XVII seeds eight paragraphs")
        #expect(SampleLibraryPrinceBook.famousLines.contains { $0.noteTitle == TourScript.firstStoryTitle })
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

    /// A7 — PROVISIONAL P-U2-15: NEW words (not in the approved mockup),
    /// pinned so a strike is one visible change.
    @Test func theRoadBackLineIsOneMutedSentence() {
        #expect(TourScript.roadBack == "Follow the ring back.")
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
            TourScript.roadBack,
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
        #expect(spotlight.lit == [.sidebarArea(.bookcase)],
                "ONE ring, ever — the first candidate on screen (A3, the walk's two-ring find)")
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

    /// A6: a door taller than its viewport rings its VISIBLE part, pulled in
    /// by its outset and stroke so the ring closes on screen; outside any
    /// scroll view it rings whole; scrolled away, nothing.
    @Test func theRingClosesInsideTheViewport() {
        let door = CGRect(x: 0, y: 0, width: 300, height: 900)
        let viewport = CGRect(x: -24, y: 200, width: 348, height: 400)
        let pull = TourRing.outset + TourRing.lineWidth
        let visible = TourRing.visiblePart(door, viewport: viewport, outset: TourRing.outset)
        #expect(visible == CGRect(x: 0, y: 200 + pull, width: 300, height: 400 - 2 * pull),
                "the closing edges sit inside the viewport (\(String(describing: visible)))")
        #expect(TourRing.visiblePart(door, viewport: nil, outset: 3) == door)
        #expect(TourRing.visiblePart(
            door, viewport: CGRect(x: 0, y: 2000, width: 300, height: 400), outset: 3) == nil)
    }

    /// A2: a keep-clear region reports itself only while a tour runs, and
    /// leaves when it leaves.
    @Test func aKeepClearRegionReportsWhileATourRuns() async throws {
        let holder = SpotlightHolder()
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: 420, height: 260),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: KeepClearRig(holder: holder))
        window.contentView = hosting
        window.orderFrontRegardless()
        defer {
            window.orderOut(nil)
            window.close()
        }
        let spotlight = TourSpotlight()
        holder.spotlight = spotlight
        await settle(window, hosting) { spotlight.keepClear.count == 1 }
        #expect(spotlight.keepClear.count == 1)
        #expect(spotlight.keepClear.values.first.map { $0.width > 100 } == true)
        holder.showsFirst = false
        await settle(window, hosting) { spotlight.keepClear.isEmpty }
        #expect(spotlight.keepClear.isEmpty, "a region that leaves is forgotten")
    }

    /// VX-292 U2 (R-292-11): the STATUS TOAST is a region the tour's cards
    /// never cover — a tour's start that restores the launch's book speaks
    /// its receipt (or the door's refusal) there, and a card must not sit on
    /// the words. Inert with no tour; it leaves when the toast does. RED ON
    /// OLD by mechanism: the toast reported nothing to the spotlight.
    @Test func theStatusToastIsARegionTheCardsNeverCover() async throws {
        let holder = SpotlightHolder()
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: 620, height: 260),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: ToastKeepClearRig(holder: holder))
        window.contentView = hosting
        window.orderFrontRegardless()
        defer {
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting, turns: 10) { false }
        let spotlight = TourSpotlight()
        holder.spotlight = spotlight
        await settle(window, hosting) { spotlight.keepClear.count == 1 }
        #expect(spotlight.keepClear.count == 1, "the toast reports itself while a tour runs")
        let region = try #require(spotlight.keepClear.values.first)
        #expect(region.width > 100 && region.height > 10, "the toast's own frame (\(region))")
        holder.showsFirst = false
        await settle(window, hosting) { spotlight.keepClear.isEmpty }
        #expect(spotlight.keepClear.isEmpty, "a toast that leaves is forgotten")
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

private struct KeepClearRig: View {
    let holder: SpotlightHolder

    var body: some View {
        VStack {
            if holder.showsFirst {
                Text("the bottom bar").frame(width: 280, height: 30).tourKeepClear()
            }
        }
        .frame(width: 300, height: 200)
        .environment(holder.spotlight)
    }
}

/// VX-292 U2: the real `StatusToast` under a spotlight (its receipt's words).
private struct ToastKeepClearRig: View {
    let holder: SpotlightHolder

    var body: some View {
        VStack {
            if holder.showsFirst {
                StatusToast(
                    item: StatusCenter.Item(
                        id: UUID(), text: "Restored \u{201C}the prince\u{201D} \u{2014} 28 chapters came back.",
                        action: nil, kind: .receipt),
                    tokens: .fallback(for: .light), onDismiss: {})
            }
        }
        .frame(width: 600, height: 200)
        .environment(holder.spotlight)
    }
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
        var poolReveals = 0
        /// VX-292 R-292-11: the drives the engine asked for, in order.
        var drives: [Drive] = []
        /// VX-292 U2 (A-292-1/3): the reveals the engine asked for, in order.
        var reveals: [Reveal] = []

        struct Reveal: Equatable {
            let anchor: Tour.Anchor
            let place: Tour.Place
        }

        struct Drive: Equatable {
            let place: Tour.Place
            let mode: Tour.NoteMode
        }

        var doors: TourEngine.Doors {
            TourEngine.Doors(
                navigate: { self.navigations.append($0) },
                openFieldGuide: { self.fieldGuides += 1 },
                recordCompleted: { self.completions += 1 },
                finished: { self.finishes.append($0) },
                showPoolTucked: { self.poolReveals += 1 },
                drive: { self.drives.append(Drive(place: $0, mode: $1)) },
                reveal: { self.reveals.append(Reveal(anchor: $0, place: $1)) })
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

    /// F-U2-W-2 (option A, ruled): leg 3 brings her to the Pool AND opens its
    /// in-gatherings run — her starred note is tucked there — exactly once.
    @Test func legThreeOpensThePoolsTuckedRunOnArrival() async throws {
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
            func mine(starred: Bool, tags: Int) -> Tour.Facts {
                .init(place: .note("mine"), noteMode: .write,
                      note: .init(noteID: "mine", starred: starred, tagCount: tags, bookCount: 0))
            }
            engine.observe(mine(starred: false, tags: 0))
            engine.choose(.keepGoing)
            engine.observe(mine(starred: true, tags: 0))
            #expect(log.poolReveals == 0, "the run opens at leg 3, not before")
            engine.observe(mine(starred: true, tags: 1))
            #expect(engine.state.step == .legBook)
            #expect(log.navigations.last == .area(.pool))
            #expect(log.poolReveals == 1, "her tucked note's row is opened for the leg's door")
        }
    }

    /// VX-292 R-292-11 — the tutorial wins by driving: a chapter that
    /// arrives in a remembered mode its step does not teach in reaches the
    /// DRIVE door — once, with the step's mode — and never the plain
    /// navigate door (which would leave the note's memory to win again).
    @Test func aDriveReachesTheDriveDoorOnceAndNeverThePlainNavigate() async throws {
        try await withSession { session in
            let log = DoorLog()
            let engine = TourEngine(
                session: session, landmarks: Self.landmarks,
                facts: Tour.Facts(place: .area(.bookcase)), doors: log.doors)
            engine.next()
            engine.observe(.init(place: .book("sherlock")))
            engine.observe(.init(place: .note("scandal"), noteMode: .takes))
            #expect(engine.state.step == .write)
            #expect(log.drives == [.init(place: .note("scandal"), mode: .write)])
            #expect(log.navigations.isEmpty, "a drive is not a plain navigate")
            // Landed in Write: nothing more; her own switch later is hers.
            engine.observe(.init(place: .note("scandal"), noteMode: .write))
            engine.observe(.init(place: .note("scandal"), noteMode: .lenses))
            #expect(log.drives.count == 1)
        }
    }

    /// VX-292 U2 (R-292-11) — "A missing Prince is restored through the
    /// existing restore road at tour start", and ONLY then: no seeded book in
    /// the landmarks, the window in Home (where a restore mints it), and no
    /// live copy anywhere in the store (one she moved to another wing is
    /// hers — the restore would refuse "already whole" or re-mint chapters
    /// she deleted there). PROVISIONAL P-292-7.
    @Test func aTourStartRestoresTheLaunchBookOnlyWhenTheStoreHasNone() {
        let missing = Queries.TourLandmarks(seededBookID: nil, firstStoryID: nil, fieldGuideID: "guide")
        let found = Queries.TourLandmarks(seededBookID: "prince", firstStoryID: "xvii", fieldGuideID: "guide")
        #expect(TourEngine.restoresLaunchBook(landmarks: missing, wingID: "", storeHoldsIt: false))
        #expect(!TourEngine.restoresLaunchBook(landmarks: found, wingID: "", storeHoldsIt: true),
                "the book is here: nothing to restore")
        #expect(!TourEngine.restoresLaunchBook(landmarks: missing, wingID: "", storeHoldsIt: true),
                "a Prince she moved to another wing is hers")
        #expect(!TourEngine.restoresLaunchBook(landmarks: missing, wingID: "wing-b", storeHoldsIt: false),
                "outside Home a restore would land where this tour cannot see it")
        // A chapter she deleted is her edit: the book's presence alone decides.
        let chapterGone = Queries.TourLandmarks(seededBookID: "prince", firstStoryID: nil, fieldGuideID: "guide")
        #expect(!TourEngine.restoresLaunchBook(landmarks: chapterGone, wingID: "", storeHoldsIt: true))
    }

    /// VX-292 U2 (A-292-1/3): step 3's arrival in the seeded book reaches
    /// the REVEAL door — once, naming the toured chapter's card in that book
    /// — and never the navigate or drive doors; home and back is a new
    /// arrival.
    @Test func stepThreesArrivalReachesTheRevealDoorOncePerArrival() async throws {
        try await withSession { session in
            let log = DoorLog()
            let engine = TourEngine(
                session: session, landmarks: Self.landmarks,
                facts: Tour.Facts(place: .area(.bookcase)), doors: log.doors)
            engine.next()
            engine.observe(.init(place: .book("sherlock")))
            #expect(engine.state.step == .insideBook)
            #expect(log.reveals == [.init(anchor: .outlineCard("scandal"), place: .book("sherlock"))])
            #expect(log.navigations.isEmpty && log.drives.isEmpty)
            engine.observe(.init(place: .book("sherlock"), bookNoteSelected: true))
            #expect(log.reveals.count == 1, "her moves in the book are hers")
            engine.observe(.init(place: .area(.bookcase)))
            engine.observe(.init(place: .book("sherlock")))
            #expect(log.reveals.count == 2, "a new arrival, a new landing")
        }
    }

    /// VX-292 U2 (A-292-1's arm): the Outline a door NAMES while the book is
    /// still arriving outlives the seed — a finished book seeds READ (R2) at
    /// its first row, which would otherwise overrule it a beat later and lose
    /// the reveal with the Outline. Once seeded, naming does nothing (the
    /// tabs' own road serves then). RED ON OLD by mechanism: no naming
    /// existed, and the seed turned the book to Read.
    @Test func anOutlineNamedBeforeTheSeedOutlivesAFinishedBooksSeed() async throws {
        try await withSession { session in
            let now = Date(timeIntervalSince1970: 1_782_864_000)
            let finished = Reading(
                id: "prince", name: "the prince", kind: .book, locked: true,
                createdAt: now, updatedAt: now)
            #expect(BookStructureModel.defaultMode(for: finished) == .read, "the premise: R2")
            let snapshot = BookStructureModel.Snapshot(
                reading: finished, sections: [], deletedSections: [], assignments: [:])

            let named = BookStructureModel(session: session, readingID: "prince")
            named.nameModeBeforeTheSeed(.outline)
            named.adopt(snapshot)
            #expect(named.mode == .outline, "the named Outline stands through the seed")

            let plain = BookStructureModel(session: session, readingID: "prince")
            plain.adopt(snapshot)
            #expect(plain.mode == .read, "unnamed, the seed is R2's as ever")
            plain.nameModeBeforeTheSeed(.outline)
            #expect(plain.mode == .read, "after the seed, naming does nothing")
        }
    }

    /// The drive door names the app's mode for the rule's — every one, both
    /// ways (`TourPlaces.postMode` is `mode(_:)`'s inverse).
    @Test func everyRuleModeNamesItsAppModeBothWays() {
        for mode in Tour.NoteMode.allCases {
            #expect(TourPlaces.mode(TourPlaces.postMode(mode)) == mode)
        }
        for mode in PostMode.allCases {
            #expect(TourPlaces.postMode(TourPlaces.mode(mode)) == mode)
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

// MARK: - The Pool's tucked run, opened for the tour (F-U2-W-2)

@MainActor
@Suite("13s-b U2 — the Pool opens its tucked run for leg 3 (F-U2-W-2)", .serialized)
struct TourPoolTuckTests {
    /// The tour's door onto the Pool's "show" only ever OPENS (the masthead's
    /// toggle would close the run on a second ask), and leaving the page
    /// still tucks it away as every visit does.
    @Test func showTuckedOnlyOpensAndLeavingStillTucks() async throws {
        let db = try AppDatabase.inMemory()
        await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let model = PoolPostsModel(session: AppSession(database: db))
            #expect(!model.showsTucked, "a visit opens tucked")
            await model.showTucked()
            #expect(model.showsTucked)
            await model.showTucked()
            #expect(model.showsTucked, "a second ask never closes what the first opened")
            model.tuckAway()
            #expect(!model.showsTucked, "leaving the Pool tucks it away, as ever")
        }
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
            // VX-292 U1 (R-292-1) — A JUSTIFIED EDIT, RED ON OLD: the world
            // holds the LAUNCH's book (the Prince, by the tour's own constant)
            // and its toured chapter; the old engine looked Sherlock's name up,
            // so `seededBookID` below read nil and step 2 rang nothing.
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            try ops.addPostToReading(chapter.id, to: prince.id)
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
            #expect(engine.state.seededBookID == prince.id)
            #expect(engine.state.firstStoryID == chapter.id)
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
                engine.spotlight.frames[.bookcaseRow(prince.id)] != nil
            }
            #expect(engine.state.step == .seededBook)
            #expect(engine.spotlight.lit == [.bookcaseRow(prince.id)])
            await settle(window, hosting, turns: 30) { false }
            let row = try #require(engine.spotlight.frames[.bookcaseRow(prince.id)])
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

    /// **VX-292 R-292-11 — the tutorial wins, in the REAL shell.** Her words:
    /// *"if you were in takes on some chapter in the prince where the
    /// tutorial expects you to be in write, the tutorial wins."* The toured
    /// chapter remembers TAKES (`postMode.<id>`, the memory an earlier tour's
    /// step 7 leaves); at step 3 she takes it by a road that is not the
    /// card's door (the Open row's: a plain adoption, no mode named), so the
    /// note mounts in Takes — and the tour drives it to Write through the
    /// rail's own act, the step waiting for her click as designed. Nothing
    /// is refused; the only memory written is the switch's own; and a mode
    /// she then picks herself on the same note is left alone.
    ///
    /// RED ON OLD by mechanism: without `Tour.drive` (or the shell's drive
    /// door) nothing switches the mounted detail, so it stays in Takes.
    @Test func aChapterRememberedInTakesIsDrivenToWriteWhenTheTourMeetsIt() async throws {
        #if DEBUG
        let suite = "tour-drive-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // LIVE uuids: the chapter's mode memory is a REAL defaults key in
            // the test host (the dev app), so it must never collide with a
            // parallel suite's incrementing ids (`BookOpenDoorTests`' reason).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            // Blocks, or the detail's blockless guard would open it in Write
            // by itself and the pin would be hollow.
            for text in ["Upon this a question arises.", "One ought to be both.", "Men love at their own will."] {
                _ = try ops.newBlock(in: chapter.id, text: text, at: .end)
            }
            try ops.addPostToReading(chapter.id, to: prince.id)
            _ = try ops.createReading(name: TutorialSeeder.bookName, kind: .book)
            let memoryKey = "postMode.\(chapter.id)"
            UserDefaults.standard.set(PostMode.takes.rawValue, forKey: memoryKey)
            defer {
                UserDefaults.standard.removeObject(forKey: memoryKey)
                session.commandRouter.forgetCurrentBlock(for: chapter.id)
            }
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

            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay != nil }
            let engine = try #require(TourOracle.overlay, "the request started a tour")
            #expect(engine.state.firstStoryID == chapter.id)
            engine.next()
            router.adopt(.reading(prince.id), in: router.workspace.focusedPane)
            await settle(window, hosting) { engine.state.step == .insideBook }
            #expect(engine.state.step == .insideBook)

            // The Open row's road: a plain adoption — the note's memory wins
            // the mount (Takes), as it does for every door but the card's.
            router.adopt(.post(chapter.id), in: router.workspace.focusedPane)
            await settle(window, hosting) {
                session.commandRouter.activePostID == chapter.id
                    && session.commandRouter.activeMode == .write
            }
            #expect(session.commandRouter.activePostID == chapter.id)
            #expect(session.commandRouter.activeMode == .write,
                    "the tutorial won: Takes was driven to Write (\(String(describing: session.commandRouter.activeMode)))")
            #expect(engine.state.step == .write, "step 4 waits for her click, as designed")
            #expect(UserDefaults.standard.string(forKey: memoryKey) == PostMode.write.rawValue,
                    "the only write is the switch's own memory, as any mode switch writes it")
            #expect(session.status.current == nil,
                    "nothing refused (\(String(describing: session.status.current?.text)))")

            // Her own switch on the same note afterwards is hers.
            session.commandRouter.requestMode(.takes, postID: chapter.id)
            await settle(window, hosting, turns: 40) { false }
            #expect(session.commandRouter.activeMode == .takes, "never overruled on the same note")

            engine.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
        }
        #endif
    }

    /// **VX-292 U2 (R-292-11) — a missing Prince comes back at the start.**
    /// The store holds the field guide and NO Prince (a held restoree — the
    /// U1 walk's dev store exactly). Help's request runs the book's own
    /// restore road FIRST, awaited: the book is minted whole (the toured
    /// chapter with it), the door's own receipt is said, and the tour then
    /// starts with its landmarks found — on the Bookcase, never inside the
    /// book the door would have opened (`opening: false`). A second press
    /// while the restore runs is that same start (one restore, one tour).
    ///
    /// RED ON OLD by mechanism: the old start read the landmarks once — nil —
    /// and began with no seeded book; no restore ran, nothing was said.
    @Test func aMissingPrinceIsRestoredBeforeTheTourStartsOnTheBookcase() async throws {
        #if DEBUG
        let suite = "tour-restore-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // The seeded-book mark is the dev app's REAL defaults (the test
            // host): never written by a pin (`PrinceFreshStoreTests`' stub).
            session.markSeededBook = { _ in }
            // The receipt must still be on screen when the pin reads it.
            session.status.dismissAfter = .seconds(600)
            _ = try session.operations.createReading(name: TutorialSeeder.bookName, kind: .book)
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
            #expect(await !TourEngine.storeHoldsLaunchBook(session: session),
                    "the premise: no Prince in the store")

            router.tourRequested = true
            await settle(window, hosting, turns: 10) { false }
            router.tourRequested = true   // a second press, mid-restore
            await settle(window, hosting, turns: 1500) { TourOracle.overlay != nil }
            let engine = try #require(TourOracle.overlay, "the tour started after the restore")

            let princeName = TourScript.seededBookName
            let chapterTitle = TourScript.firstStoryTitle
            let princes = try await db.read { db in
                try Queries.readings(db).filter { $0.name == princeName && $0.deletedAt == nil }
            }
            #expect(princes.count == 1, "ONE restore, one book (\(princes.count))")
            let prince = try #require(princes.first)
            #expect(engine.state.seededBookID == prince.id, "the landmarks were read again after it")
            let princeID = prince.id
            let chapterID = try await db.read { db in
                try Queries.assembleReading(db, readingID: princeID)
                    .first { $0.title == chapterTitle }?.postID
            }
            #expect(chapterID != nil && engine.state.firstStoryID == chapterID,
                    "the toured chapter came back with its book")
            #expect(engine.state.step == .navigation)
            #expect(TourPlaces.place(router.workspace.focusedSelection) == .area(.bookcase),
                    "the tour stands on the Bookcase — the door's opening of the book is left out")
            #expect(session.status.spoken?.text.hasPrefix(
                "Restored \u{201C}\(princeName)\u{201D}") == true,
                    "the door's own receipt (\(String(describing: session.status.spoken?.text)))")

            engine.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
        }
        #endif
    }

    /// **VX-292 U2 (A-292-1/3) — step 3 brings the toured chapter ON THE
    /// PAGE, in the REAL shell.** A book of thirty notes whose toured chapter
    /// is the twenty-fifth: its collapsed Outline card lies far below the
    /// fold — beyond the Outline's near band, so it is not even DRAWN at the
    /// book's arrival (no registration, no ring — U1's walk). The tour's
    /// arrival reveal lands it through the book's own ascent road: the page
    /// travels, the card is drawn and LIT inside the window, and the park is
    /// spent. RED ON OLD by mechanism: with no reveal the page stays at its
    /// top and the far card never mounts, so nothing is lit.
    @Test func stepThreeLandsTheFarChapterOnThePage() async throws {
        try await revealWalk(finished: false)
    }

    /// …and A-292-1's arm: a FINISHED seeded book opens in Read (R2), where
    /// no Outline card exists; the tour's ascent turns it to its Outline
    /// through the tabs' own mode road first, then lands the chapter. RED ON
    /// OLD: the book stays in Read and nothing is lit.
    @Test func aFinishedSeededBookIsTurnedToItsOutlineAndTheChapterLanded() async throws {
        try await revealWalk(finished: true)
    }

    private func revealWalk(finished: Bool) async throws {
        #if DEBUG
        let suite = "tour-reveal-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // LIVE uuids: the Outline oracles are keyed by the book's id and
            // suites run in parallel (`BookOpenDoorTests`' reason).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let prose = "Upon this a question arises: whether it be better to be loved than "
                + "feared or feared than loved? It may be answered that one should wish to be "
                + "both, but, because it is difficult to unite them in one person, it is much "
                + "safer to be feared than loved, when, of the two, either must be dispensed with."
            var target = ""
            for index in 0..<30 {
                let title = index == 24 ? TourScript.firstStoryTitle : "chapter \(index + 1)"
                let note = try ops.createPost(title: title)
                for _ in 0..<2 { _ = try ops.newBlock(in: note.id, text: prose, at: .end) }
                try ops.addPostToReading(note.id, to: prince.id)
                if index == 24 { target = note.id }
            }
            if finished { try ops.lockReading(prince.id) }
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
            await settle(window, hosting, turns: 40) { false }

            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay != nil }
            let engine = try #require(TourOracle.overlay, "the request started a tour")
            #expect(engine.state.firstStoryID == target)
            engine.next()
            router.adopt(.reading(prince.id), in: router.workspace.focusedPane)
            await settle(window, hosting, turns: 400) {
                engine.spotlight.lit == [.outlineCard(target)]
                    && engine.spotlight.frames[.outlineCard(target)] != nil
            }
            #expect(engine.state.step == .insideBook)
            #expect(engine.spotlight.lit == [.outlineCard(target)],
                    "the far card is drawn and ringed (\(engine.spotlight.lit))")
            let card = try #require(engine.spotlight.frames[.outlineCard(target)])
            let content = try #require(window.contentView).bounds
            #expect(card.minY >= 0 && card.minY < content.height,
                    "the card's top is inside the window (\(card) in \(content))")
            let page = BookOutlineGeometry.outlineScrolls[prince.id]
            #expect((page?.offset ?? 0) > 1_000,
                    "the page travelled to it — it began far below the fold (\(String(describing: page)))")
            #expect(router.pendingBookAscent == nil, "the park is spent")

            engine.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
        }
        #endif
    }
}

// MARK: - The end card's doors (F-U2-W-1, the U2 walk)

@MainActor
@Suite("13s-b U2 — the end card's doors never truncate (F-U2-W-1)", .serialized)
struct TourEndCardTests {
    /// The walk's find: in the Terminal voice's monospace the two long doors
    /// were cut to an ellipsis ("keep going: two more minutes on stars,
    /// tag…"). Door text never truncates — each door's drawn words are at
    /// least as tall as the same words laid out at the same width with no
    /// line limit (a truncated line is one line where the words need two),
    /// and they stay inside the card's measure.
    ///
    /// **Rendered THROUGH THE LIVE PATH** (the U2 verify walk's ask): the
    /// real `TourOverlay` over a window, with a real engine walked to the end
    /// card — the overlay's GeometryReader, ZStack, layout placement, the
    /// card's `.fixedSize` and its measurement — never the card component on
    /// its own, so a clamp anywhere in the live composition reads here.
    @Test func theEndCardsDoorsWrapThroughTheLiveOverlay() async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for scheme in [ColorScheme.dark, .light] {
                let engine = Self.engineAtTheEndCard(session)
                #expect(engine.state.step == .endCard)
                let tokens = VoiceTokens.fallback(for: scheme)
                TourOracle.endDoorFrames = [:]
                let window = NSWindow(
                    contentRect: NSRect(x: 40, y: 40, width: 1100, height: 720),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: LiveEndCardRig(engine: engine, scheme: scheme))
                window.contentView = hosting
                window.orderFrontRegardless()
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                await settle(window, hosting) { TourOracle.endDoorFrames.count == 3 }
                await settle(window, hosting, turns: 20) { false }
                let measure = TourEndCard.width - 60  // the card's own side padding
                for door in TourEndCard.choices(tokens) {
                    let drawn = try #require(
                        TourOracle.endDoorFrames[door.key], "\(door.key) drew in the live overlay")
                    let free = NSHostingView(rootView: Text(door.words)
                        .font(door.font)
                        .frame(width: drawn.width, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true))
                    let needed = free.fittingSize.height
                    #expect(drawn.height >= needed - 0.5,
                            "\(scheme) \(door.key): drawn \(drawn.height) pt, the words need \(needed) pt — truncated")
                    #expect(drawn.width <= measure + 0.5, "\(door.key) stays inside the card")
                }
            }
        }
        #endif
    }

    /// A real engine, walked by facts to the end card (the main leg's own
    /// road, the engine test's shape).
    static func engineAtTheEndCard(_ session: AppSession) -> TourEngine {
        let engine = TourEngine(
            session: session,
            landmarks: .init(seededBookID: "sherlock", firstStoryID: "scandal", fieldGuideID: "guide"),
            facts: Tour.Facts(place: .area(.bookcase)),
            doors: TourEngine.Doors(
                navigate: { _ in }, openFieldGuide: {}, recordCompleted: {}, finished: { _ in }))
        func write(_ block: String, _ ordinal: Int, takes: Int = 1) -> Tour.Facts {
            .init(place: .note("scandal"), noteMode: .write,
                  caret: .init(noteID: "scandal", blockID: block, ordinal: ordinal, takeCount: takes))
        }
        engine.next()
        engine.observe(.init(place: .book("sherlock")))
        engine.observe(.init(place: .note("scandal"), noteMode: .write))
        engine.observe(write("b1", 1))
        engine.observe(write("b40", 40))
        engine.observe(write("b40", 40, takes: 2))
        engine.observe(.init(place: .note("scandal"), noteMode: .takes))
        engine.next()
        engine.next()
        engine.next()
        engine.observe(.init(place: .book("sherlock"), bookNoteLive: true))
        engine.observe(.init(place: .area(.bookcase)))
        engine.observe(.init(
            place: .note("mine"), noteMode: .write,
            note: .init(noteID: "mine", starred: false, tagCount: 0, bookCount: 0)))
        return engine
    }
}

/// The live composition the end card is drawn in: the real `TourOverlay`
/// over a window-filling page (as `RootView`'s tour layer lays it), its facts
/// standing on her own note.
private struct LiveEndCardRig: View {
    let engine: TourEngine
    let scheme: ColorScheme

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                TourOverlay(engine: engine, sources: TourFactSources(
                    selection: { .post("mine") },
                    noteDetail: { ("mine", .write) },
                    caret: { nil },
                    bookNoteLive: { false },
                    isStarred: { _ in false }))
            }
            .environment(\.colorScheme, scheme)
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


/// The extra-pass MINOR-1 honesty gate: the end card never promises a
/// readme the store does not hold. Red-on-old by construction (the choice
/// function does not exist before the gate), and the two texts are pinned
/// to the approved aside and its journal-alone derivation.
@Suite("13s-b extra pass — the end card's readme honesty gate")
@MainActor
struct TourEndCardAsideGateTests {
    @Test func theAsideNeverPromisesAReadmeTheStoreDoesNotHold() {
        #expect(TourEndCard.asideText(readmeExists: true) == TourScript.endAside)
        #expect(TourEndCard.asideText(readmeExists: false) == TourScript.endAsideJournalAlone)
        #expect(TourScript.endAside.hasPrefix("readme"))
        #expect(!TourScript.endAsideJournalAlone.contains("readme"),
                "the no-readme form must not name what is not there")
        // The derivation rule: the journal-alone form IS the approved second
        // sentence minus its connective, byte for byte.
        #expect(TourScript.endAside.hasSuffix("And " + TourScript.endAsideJournalAlone))
    }
}
