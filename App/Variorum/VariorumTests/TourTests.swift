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
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The words

@MainActor
@Suite("13s-b U2 — the tour's words")
struct TourScriptTests {
    /// The approved fifth draft, VERBATIM from mockup v5's frames
    /// (`notes/plans/13s-mockups/onboarding-tour.html`) — title and body,
    /// keyed by the MOCKUP's step names (VX-292 U3: three of them —
    /// `takesMode`, `deeperModes`, `placeFollows` — were reworked into the
    /// grown tour's cards, so the table stands as the mockup's text and the
    /// U3 drafts table below carries what replaced them).
    static let approved: [String: (String, String)] = [
        "navigation": ("Navigation", "Everything lives in one of the places on the left. Bookcase holds your books. Library is everything, searchable. Pool holds notes that aren't in a book, and Snippets keeps pieces of text you reuse between notes."),
        "seededBook": ("Sherlock Holmes, in Variorum", "The adventures of sherlock holmes comes with the app, so you can try everything on real writing. Click into it."),
        "insideBook": ("Inside a book", "A book opens on its Outline: every chapter, and the beginning of every note. A book works like a scrapbook. Put a note in and it stays there. Click into A Scandal in Bohemia."),
        "write": ("Write", "Notes open in Write. Everything autosaves as you type; commit \u{2318}S in the bottom bar keeps a savepoint of a moment worth keeping. Scroll to the middle of the note and click into a paragraph there."),
        "makeTake": ("Make a take", "A block can keep more than one version of itself. These are takes, like takes in film, and they are the heart of Variorum. Click Takes in the bottom bar, then \u{FF0B} new take (branch), and change a few words."),
        "takeIcon": ("The take icon", "The \u{03C8}2 in the margin marks any block that keeps more than one version. Click into it any time to see them. Click into it now, then Open Takes mode."),
        "takesMode": ("Both takes, side by side", "This is Takes mode: the whole note, with every version of every block. The \u{2713} take is what the note says. Click into a take to work in it; its \u{2713} makes it the one the page shows. The original keeps its own card."),
        "deeperModes": ("Three more, for later", "Lenses shows different takes of this note side by side. Compare sets other notes beside this one. Blocks is a workbench for many blocks at once. The field guide teaches each of them."),
        "placeFollows": ("Your place follows you", "Bounce between Write (\u{2318}1) and Takes (\u{2318}2) as you like. Then click the book icon and pick Index, the book's own view of its notes. Your paragraph is still in focus, one level up. Your place follows you everywhere."),
        "downAndUp": ("Down and up", "In a book, the selected note's edit here door drops you back into it, and the book icon brings you up again. The ladder runs both directions. Click into it."),
        "home": ("Head home", "When you're done exploring, Bookcase in the sidebar heads home. Click into it."),
        "ownNote": ("One of your own", "The dashed line at the bottom reads new note, just start typing. Type a first line and press \u{23CE} to open your first note. No book needed; it waits in the Pool until you give it one."),
        "legStar": ("Star a note", "Click the star. Starred notes rise to the top of the sidebar, and the starred notes gathering on your Bookcase collects them automatically."),
        "legTags": ("Organize with tags", "The \u{FF03} on the masthead adds a tag. Tag a note ideas, and a gathering made from ideas shows it on its own. Make the tag."),
        "legBook": ("Put it in a book", "Your note has been waiting here in the Pool. Click into add to book, or make a new book around it. A note can sit in more than one book."),
        "legSnippets": ("Snippets", "Pieces of text you reuse between notes live here: a phrase, a quote, a line you cut. From inside any note, the snippets panel brings them alongside so you can pull one in. The snippet stays for next time."),
        "legEnd": ("The field guide", "Everything deeper lives in the field guide: takes in depth, divide and merge, books that collect, privacy. Interactive lessons, in order or as needed. That's the tour. Go write."),
    ]

    /// **The only departures from the frozen copy** — each a BUILD-VERIFY
    /// resolution or a fact the real app forced, each recorded in the U2
    /// RECORD with its alternative (P-U2-1/2/3/5 and BUILD-VERIFY 2).
    /// VX-292 U1 (R-292-1, the Prince replaced Sherlock in the launch at
    /// VX-633): steps 2 and 3 carry the plan's U1 COPY DRAFTS — step 2's body
    /// whole (with its title, below), step 3's last sentence. The approved
    /// table above stays mockup v5's text, so its mockup pin still reads it.
    static let departures: [String: (from: String, to: String)] = [
        "seededBook": (
            "The adventures of sherlock holmes comes with the app, so you can try everything on real writing. Click into it.",
            "the prince comes with the app, so you can try everything on real writing. Machiavelli's Italian rides under every paragraph. Click into it."),
        "insideBook": ("Click into A Scandal in Bohemia.",
                       "Click into the chapter on whether it is better to be loved or feared."),
        "takeIcon": ("The \u{03C8}2 in the margin", "The \u{2442}2 in the margin"),
        "legStar": ("Click the star.", "Right-click your note under Open in the sidebar and choose Star."),
        "legSnippets": ("the snippets panel", "the Scraps panel"),
    ]

    /// The one TITLE departure (VX-292 U1, R-292-1): step 2 names the book
    /// the launch seeds now.
    static let titleDepartures: [String: (from: String, to: String)] = [
        "seededBook": ("Sherlock Holmes, in Variorum", "The Prince, in Variorum"),
    ]

    /// **VX-292 U3 — the grown tour's cards, the architect's U3 COPY DRAFTS
    /// VERBATIM** (`notes/plans/vx-292-onboarding.md` §U3 COPY DRAFTS — a
    /// pin below holds this table to that text). Step 7's two beats share
    /// one card; step 11's third beat is the mockup's `downAndUp`, verbatim.
    static let u3Drafts: [Tour.Step: (String, String)] = {
        let flip = ("Both takes, side by side", "This is Takes mode: the whole note, with every version of every block. The \u{2713} take is what the note says. Find the take named il principe 1532 and press choose: the page now reads Italian. Choose the English take to bring it back. Choosing decides what the note says; clicking into a take just works in it.")
        return [
            .takesMode: flip,
            .takesFlipBack: flip,
            .readInNote: ("Read", "Click Read in the rail. It opens on edit, an outline of the note you can type in; flip the switch to read for the calm page. When you want to write again, click any sentence and you land back at that very block."),
            .lensesLive: ("Lenses", "Lenses shows different takes of this note side by side. Click Lenses in the rail, then open the column named il principe 1532: the whole chapter in Italian beside the English. Same note, two readings."),
            .deeperModes: ("Two more, for later", "Compare sets other notes beside this one. Blocks is a workbench for many blocks at once. The field guide teaches each of them."),
            .upToBook: ("Up to the book", "Click the book icon: you're back in the prince, one level up, with your chapter in view. A book has four views of its own along the top: Outline, Index, Book and Read."),
            .bookAndRead: ("Book and Read", "Click Book: the chapters become pages, like a bound copy. Then click Read to read straight through. Books are for reading whole; notes are where you write."),
            .legSettings: ("Make it yours", "Settings holds the look: two voices, light and dark, and seventeen colour palettes, sea glass leading. The MCP pane connects an AI to your library if you ever want one; nothing connects unless you turn it on. Have a look, then come back."),
        ]
    }()

    /// **VX-292 U3's departures from its drafts** — each a real-app fact,
    /// recorded in the U3 RECORD with its alternative: the mode list's home
    /// is the sidebar's "this note" section ("the rail" is the code's word,
    /// never the app's), and choosing a take flips ONE paragraph, not the page.
    static let u3Departures: [Tour.Step: [(from: String, to: String)]] = [
        .takesMode: [("the page now reads Italian", "this paragraph now reads Italian")],
        .takesFlipBack: [("the page now reads Italian", "this paragraph now reads Italian")],
        .readInNote: [("in the rail", "in the sidebar")],
        .lensesLive: [("in the rail", "in the sidebar")],
    ]

    /// Every card is its draft — mockup v5's approved text with the
    /// recorded departures, or (VX-292 U3) the U3 drafts with theirs. Every
    /// step is covered by exactly one of the two tables.
    @Test func everyCardIsTheApprovedDraftExceptTheRecordedDepartures() throws {
        for step in Tour.Step.allCases where step != .endCard {
            let card = try #require(TourScript.card(step), "\(step) has a card")
            if let (draftTitle, draftBody) = Self.u3Drafts[step] {
                #expect(Self.approved[step.rawValue] == nil || [.takesMode, .deeperModes].contains(step),
                        "\(step): one table speaks for each card")
                var expected = draftBody
                for departure in Self.u3Departures[step] ?? [] {
                    #expect(expected.contains(departure.from), "\(step): the departure names real words")
                    expected = expected.replacingOccurrences(of: departure.from, with: departure.to)
                }
                #expect(card.title == draftTitle, "\(step): the title is the draft's")
                #expect(card.body == expected, "\(step): \(card.body)")
                continue
            }
            let (approvedTitle, approvedBody) = try #require(
                Self.approved[step.rawValue], "\(step) has approved words")
            var title = approvedTitle
            if let departure = Self.titleDepartures[step.rawValue] {
                #expect(approvedTitle == departure.from, "\(step): the title departure names the approved title")
                title = departure.to
            }
            #expect(card.title == title, "\(step): the title is the approved one")
            var expected = approvedBody
            if let departure = Self.departures[step.rawValue] {
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

    /// **VX-292 U3 — the U3 drafts table IS the plan's own text** (the mockup
    /// pin's twin): every draft's title and body appear verbatim in the
    /// plan's §U3 COPY DRAFTS, so a drift in either is caught here.
    @Test func theU3TableIsThePlansOwnDrafts() throws {
        let plan = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // the repo
            .appendingPathComponent("notes/plans/vx-292-onboarding.md")
        guard let text = try? String(contentsOf: plan, encoding: .utf8) else { return }
        let drafts = try #require(text.components(separatedBy: "## U3 COPY DRAFTS").dropFirst().first)
        for (step, words) in Self.u3Drafts {
            #expect(drafts.contains("`\(words.0)`"), "\(step)'s title is the plan's draft")
            #expect(drafts.contains("`\(words.1)`"), "\(step)'s body is the plan's draft")
        }
    }

    /// **VX-292 U3 (P-292-11) — step 3 says the ring's chapter when it is
    /// not XVII.** Under R-292-17's fallback the ring sits on another fanned
    /// chapter, and the approved sentence would name one the ring is not on.
    @Test func stepThreeNamesTheRingsChapterWhenItIsNotTheNamedOne() throws {
        let named = try #require(TourScript.card(.insideBook, namedChapter: true))
        let ringed = try #require(TourScript.card(.insideBook, namedChapter: false))
        #expect(named.body.hasSuffix("Click into the chapter on whether it is better to be loved or feared."))
        #expect(ringed.body.hasSuffix(" " + TourScript.insideBookRingedChapter))
        #expect(TourScript.insideBookRingedChapter == "Click into the chapter the ring marks.")
        #expect(named.body.replacingOccurrences(
            of: "Click into the chapter on whether it is better to be loved or feared.",
            with: TourScript.insideBookRingedChapter) == ringed.body,
                "only the last sentence changes")
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
        // VX-292 U3: the grown tour's words name doors by their constants.
        #expect(TakeChooseHeader.chooseWord == "choose")
        #expect(TakeChooseHeader.chosenWord == "\u{2713} chosen")
        #expect(try #require(TourScript.card(.takesMode)).body
                .contains("press \(TakeChooseHeader.chooseWord):"))
        #expect(TourScript.italianName == SampleLibraryPrinceBook.italianTakeLabel)
        #expect(TourScript.italianName == "il principe 1532")
        for step in [Tour.Step.takesMode, .lensesLive] {
            #expect(try #require(TourScript.card(step)).body.contains(TourScript.italianName))
        }
        #expect(PostMode.read.rawValue == "Read" && PostMode.lenses.rawValue == "Lenses")
        #expect(PostMode.compare.rawValue == "Compare" && PostMode.blocks.rawValue == "Blocks")
        #expect(BookView.tabOrder.map(BookView.tabLabel) == ["Outline", "Index", "Book", "Read"])
        #expect(try #require(TourScript.card(.upToBook)).body
                .hasSuffix("along the top: Outline, Index, Book and Read."))
        #expect(try #require(TourScript.card(.upToBook)).body
                .contains("back in \(SampleLibraryPrinceBook.name),"))
        // The Settings stop: the count is the strip's, the leading palette
        // is the one a store with no palette wears, the pane its title.
        #expect(SettingsPane.mcp.title == "MCP")
        #expect(TourScript.paletteCountWord == "seventeen")
        #expect(PaletteCopy.label(Queries.ThemeSettings.unsetStorePalette) == PaletteCopy.label(.seaglass))
        #expect(try #require(TourScript.card(.legSettings)).body
                .contains("\(TourScript.paletteCountWord) colour palettes, sea glass leading."))
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
        #expect(TourScript.label(.main(number: 1, beat: 1)) == "Step 1 of 13")
        // VX-292 U3: a step's beats share its number (the mockup's "· and
        // home" beat retired when home became step 12 of its own).
        #expect(TourScript.label(.main(number: 7, beat: 2)) == "Step 7 of 13")
        #expect(TourScript.label(.main(number: 11, beat: 3)) == "Step 11 of 13")
        #expect(TourScript.label(.leg(number: 1)) == "Keep going \u{00B7} 1 of 5")
        #expect(TourScript.label(.legEnd) == "The end")
        #expect(TourScript.label(.endCard) == nil)
        #expect(TourScript.next == "next \u{27F6}")
        #expect(TourScript.endTour == "End tour")
    }

    /// The all-capitals words that are names, not shouts (VX-292 U3's
    /// Settings stop names the MCP pane and an AI).
    static let acronyms: Set<String> = ["MCP", "AI"]

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
            // VX-292 U3: an acronym the app names a thing by (the MCP pane,
            // an AI) is a name, not a shout.
            for word in text.split(whereSeparator: { !$0.isLetter }) where word.count >= 2 {
                guard !Self.acronyms.contains(String(word)) else { continue }
                #expect(word != word.uppercased() || word.lowercased() == word.uppercased(),
                        "no shouting caps: \(word) in \(text)")
            }
            if text != TourScript.keepGoing {
                #expect(!text.lowercased().contains("minute"), "A5: no time promise: \(text)")
            }
        }
    }

    /// **VX-292 U3 — every ring the rule names is worn by a door in the
    /// app** (P-6: a step whose ring no door wears is a regression by
    /// definition). The switch below is exhaustive, so a new anchor case
    /// must say its name here; each name must appear inside a `.tourAnchor(`
    /// call in the app's sources — except the ⑂ badge, which the overlay
    /// finds itself (AppKit). RED ON OLD by mechanism for the three new rings
    /// (no door wore them).
    @Test func everyRingTheRuleNamesIsWornByADoorInTheApp() throws {
        func name(_ anchor: Tour.Anchor) -> String {
            switch anchor {
            case .sidebarAreas: "sidebarAreas"
            case .sidebarArea: "sidebarArea"
            case .sidebarMode: "sidebarMode"
            case .sidebarOpenRow: "sidebarOpenRow"
            case .bookcaseRow: "bookcaseRow"
            case .quickEntry: "quickEntry"
            case .outlineCard: "outlineCard"
            case .bookModeTab: "bookModeTab"
            case .indexNoteRow: "indexNoteRow"
            case .noteBoxEditHere: "noteBoxEditHere"
            case .barTakes: "barTakes"
            case .panelNewTake: "panelNewTake"
            case .panelOpenTakesMode: "panelOpenTakesMode"
            case .takeBadge: "takeBadge"
            case .takesBlock: "takesBlock"
            case .takeChoose: "takeChoose"
            case .readFaceSwitch: "readFaceSwitch"
            case .lensAddColumn: "lensAddColumn"
            case .contextBarBook: "contextBarBook"
            case .mastheadTagDoor: "mastheadTagDoor"
            case .poolAddToBook: "poolAddToBook"
            case .firstSnippetCard: "firstSnippetCard"
            }
        }
        let all: [Tour.Anchor] = [
            .sidebarAreas, .sidebarArea(.bookcase), .sidebarMode(.read), .sidebarOpenRow("n"),
            .bookcaseRow("b"), .quickEntry, .outlineCard("n"), .bookModeTab(.book),
            .indexNoteRow("n"), .noteBoxEditHere, .barTakes, .panelNewTake, .panelOpenTakesMode,
            .takeBadge("k"), .takesBlock("k"), .takeChoose("t"), .readFaceSwitch, .lensAddColumn,
            .contextBarBook, .mastheadTagDoor, .poolAddToBook("n"), .firstSnippetCard,
        ]
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum")
        let files = try #require(FileManager.default.enumerator(at: app, includingPropertiesForKeys: nil))
        var windows: [String] = []
        for case let url as URL in files where url.pathExtension == "swift" {
            let text = try String(contentsOf: url, encoding: .utf8)
            var rest = text[...]
            while let hit = rest.range(of: ".tourAnchor(") {
                windows.append(String(rest[hit.upperBound...].prefix(160)))
                rest = rest[hit.upperBound...]
            }
        }
        #expect(!windows.isEmpty, "non-vacuity: the app's doors were read")
        for anchor in all where !anchor.isAppKit {
            let word = name(anchor)
            #expect(windows.contains { $0.contains(".\(word)") },
                    "\(word): no door in the app wears this ring")
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
        /// VX-292 U3: how many times the Settings stop asked for Settings.
        var settingsOpened = 0
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
                reveal: { self.reveals.append(Reveal(anchor: $0, place: $1)) },
                openSettings: { self.settingsOpened += 1 })
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
            walkFromTakesToTheBookcase(engine)
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
            walkFromTakesToTheBookcase(engine)
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

    /// VX-292 U2 — the start's restore gate, as one table. **Case 1**
    /// (R-292-11, P-292-7): no seeded book in the landmarks, Home, and no
    /// live copy in any wing. **Case 2** (R-292-17 — her *"what if they've
    /// deleted all the takes in the prince?"*): the book stands here with its
    /// props broken AND the road can reach a mend (it is the book the road
    /// acts on, and a shipped chapter is missing). Never: an intact or merely
    /// edited book, props the road cannot reach (every chapter standing, its
    /// fans emptied inside), a book that does not admit new chapters
    /// (Finished, Sealed, at its note cap), a book she moved to another wing,
    /// any window outside Home, an unreadable store. RED ON OLD for case 2 by
    /// mechanism: the old gate restored only a book that was not there; the
    /// admission line was red at d370fd28b (the window of 2026-10-30).
    @Test func aTourStartRestoresOnlyWhatDeletionsBrokeAndTheRoadCanReach() {
        func marks(_ book: String?, broken: Bool = false) -> Queries.TourLandmarks {
            Queries.TourLandmarks(
                seededBookID: book, firstStoryID: book == nil ? nil : "xvii",
                fieldGuideID: "guide", seededBookPropsBroken: broken)
        }
        typealias Facts = TourEngine.LaunchBookFacts
        func restores(_ m: Queries.TourLandmarks, wing: String = "", _ f: Facts?) -> Bool {
            TourEngine.restoresLaunchBook(landmarks: m, wingID: wing, store: f)
        }
        // Case 1 — no book.
        #expect(restores(marks(nil), Facts(liveBookID: nil, isComplete: true)))
        #expect(!restores(marks(nil), Facts(liveBookID: "moved", isComplete: true)),
                "a Prince she moved to another wing is hers")
        #expect(!restores(marks(nil), wing: "wing-b", Facts(liveBookID: nil, isComplete: true)),
                "outside Home a restore would land where this tour cannot see it")
        // Case 2 — broken props the road can reach.
        #expect(restores(marks("prince", broken: true), Facts(liveBookID: "prince", isComplete: false)),
                "a chapter gone: the road mints it back with its takes")
        #expect(!restores(marks("prince", broken: true), Facts(liveBookID: "prince", isComplete: true)),
                "every chapter standing, fans emptied inside: beyond the road (it would only refuse)")
        #expect(!restores(marks("prince", broken: false), Facts(liveBookID: "prince", isComplete: false)),
                "a chapter she deleted while the props hold: her edit, untouched")
        #expect(!restores(marks("prince"), Facts(liveBookID: "prince", isComplete: true)),
                "an intact book is never touched")
        #expect(!restores(marks("prince", broken: true), Facts(liveBookID: "other", isComplete: false)),
                "the road would act on another copy than the one this tour stands on")
        // The 2026-10-30 window's gap: a book that does not ADMIT new chapters
        // (Finished, Sealed, at its note cap — her deliberate acts) is beyond
        // the road's reach; the door would only refuse, at every start.
        #expect(!restores(marks("prince", broken: true),
                          Facts(liveBookID: "prince", isComplete: false, acceptsChapters: false)),
                "a Finished, Sealed or full book is left as it is: the floor")
        #expect(!restores(marks("prince", broken: true), wing: "wing-b",
                          Facts(liveBookID: "prince", isComplete: false)),
                "a book in another wing is respected")
        #expect(!restores(marks(nil), nil), "an unreadable store attempts nothing")
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

    /// **VX-292 U3 (R-292-8) — the Settings stop reaches the Settings door
    /// exactly once** (Settings opens on General through the shell's road),
    /// never a navigate; its next heads home as the leg's end always did.
    /// RED ON OLD by construction (no stop, no door).
    @Test func theSettingsStopReachesTheSettingsDoorOnce() async throws {
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
            walkFromTakesToTheBookcase(engine)
            func mine(starred: Bool, tags: Int, books: Int = 0, at place: Tour.Place = .note("mine")) -> Tour.Facts {
                .init(place: place, noteMode: .write,
                      note: .init(noteID: "mine", starred: starred, tagCount: tags, bookCount: books))
            }
            engine.observe(mine(starred: false, tags: 0))
            #expect(engine.state.step == .endCard)
            engine.choose(.keepGoing)
            engine.observe(mine(starred: true, tags: 0))
            engine.observe(mine(starred: true, tags: 1))
            engine.observe(mine(starred: true, tags: 1, books: 1, at: .area(.pool)))
            #expect(engine.state.step == .legSnippets)
            #expect(log.settingsOpened == 0, "not before the stop")
            let navigationsBefore = log.navigations.count
            engine.next()
            #expect(engine.state.step == .legSettings)
            #expect(log.settingsOpened == 1, "Settings opens, once")
            #expect(log.navigations.count == navigationsBefore, "the window stays where she is")
            engine.observe(mine(starred: true, tags: 1, books: 1, at: .area(.library)))
            #expect(log.settingsOpened == 1, "never asked twice")
            engine.next()
            #expect(engine.state.step == .legEnd)
            #expect(log.navigations.last == .area(.bookcase))
            #expect(log.settingsOpened == 1)
        }
    }

    /// **VX-292 U3 — step 7 watches its block in the store.** The engine,
    /// walked to the flip with a real note, observes the toured block: its
    /// shown take, its takes in fan order, and the take wearing the Prince's
    /// Italian label; choosing the Italian is seen. RED ON OLD by
    /// construction (no watch, no read).
    @Test func theFlipWatchReadsTheToursBlockFromTheStore() async throws {
        try await withSession { session in
            let ops = session.operations
            let note = try ops.createPost(title: "XVII")
            let first = try ops.newBlock(in: note.id, text: "Upon this a question arises.", at: .end)
            let toured = try ops.newBlock(in: note.id, text: "One ought to be both.", at: .end)
            let italian = try ops.branchVariant(toured.block.id, from: toured.variant.id)
            try ops.setTakeLabel(italian.id, label: TourScript.italianName)
            let engine = TourEngine(
                session: session,
                landmarks: .init(seededBookID: "book", firstStoryID: note.id, fieldGuideID: nil),
                facts: Tour.Facts(place: .area(.bookcase)), doors: DoorLog().doors)
            func write(_ block: String, _ ordinal: Int, takes: Int) -> Tour.Facts {
                .init(place: .note(note.id), noteMode: .write,
                      caret: .init(noteID: note.id, blockID: block, ordinal: ordinal, takeCount: takes))
            }
            engine.next()
            engine.observe(.init(place: .book("book")))
            engine.observe(write(first.block.id, 1, takes: 1))
            engine.observe(write(toured.block.id, 2, takes: 2))
            engine.observe(write(toured.block.id, 2, takes: 3))
            engine.observe(.init(place: .note(note.id), noteMode: .takes))
            #expect(engine.state.step == .takesMode)
            #expect(engine.flipInterestKey == "\(note.id)|\(toured.block.id)")
            let watch = Task { await engine.watchFlipFacts() }
            defer { watch.cancel() }
            for _ in 0..<200 where engine.flipFacts == nil { try await Task.sleep(for: .milliseconds(10)) }
            #expect(engine.flipFacts == Tour.BlockFacts(
                noteID: note.id, blockID: toured.block.id, chosenTakeID: toured.variant.id,
                takeIDs: [toured.variant.id, italian.id], namedTakeID: italian.id))
            try ops.chooseVariant(toured.block.id, variantID: italian.id)
            for _ in 0..<200 where engine.flipFacts?.chosenTakeID != italian.id {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(engine.flipFacts?.chosenTakeID == italian.id, "the choose is seen")
        }
    }

    /// **VX-292 U3 — the grown tour's facts speak only where they belong:**
    /// the book's mode for a book; the Lenses board's columns for the note it
    /// shows, while that note IS in Lenses; the flip's block as the store
    /// said it. And the router's board report leaves with its own board only.
    @Test func theGrownToursFactsSpeakOnlyWhereTheyBelong() {
        let inBook = TourPlaces.facts(
            selection: .reading("r"), detail: (nil, nil), caret: nil, bookNoteLive: false,
            note: nil, isStarred: { _ in false }, bookMode: .read, lensBoard: ("n", 2))
        #expect(inBook.bookMode == .read)
        #expect(inBook.lensColumns == nil, "a book has no Lenses board")
        let inLenses = TourPlaces.facts(
            selection: .post("n"), detail: ("n", .lenses), caret: nil, bookNoteLive: false,
            note: nil, isStarred: { _ in false }, bookMode: .book, lensBoard: ("n", 2))
        #expect(inLenses.lensColumns == 2)
        #expect(inLenses.bookMode == nil, "the book's mode speaks only for a book")
        let inWrite = TourPlaces.facts(
            selection: .post("n"), detail: ("n", .write), caret: nil, bookNoteLive: false,
            note: nil, isStarred: { _ in false }, lensBoard: ("n", 2))
        #expect(inWrite.lensColumns == nil, "a board left standing is not the mode she is in")
        let otherNote = TourPlaces.facts(
            selection: .post("m"), detail: ("m", .lenses), caret: nil, bookNoteLive: false,
            note: nil, isStarred: { _ in false }, lensBoard: ("n", 2))
        #expect(otherNote.lensColumns == nil, "another note's board is not hers")
        let block = Tour.BlockFacts(noteID: "n", blockID: "b", chosenTakeID: "t", takeIDs: ["t", "u"])
        #expect(TourPlaces.facts(
            selection: .post("n"), detail: ("n", .takes), caret: nil, bookNoteLive: false,
            note: nil, isStarred: { _ in false }, block: block).block == block)

        let router = CommandRouter()
        router.reportLensBoard(postID: "n", columns: 1)
        #expect(router.lensBoard == .init(postID: "n", columns: 1))
        router.reportLensBoard(postID: "m", columns: nil)
        #expect(router.lensBoard?.postID == "n", "another board leaving never wipes this one")
        router.reportLensBoard(postID: "n", columns: nil)
        #expect(router.lensBoard == nil)
        let asked = router.generalSettingsRequest
        router.requestGeneralSettings()
        #expect(router.generalSettingsRequest == asked + 1)
        #expect(AppSettingsView.adopts(
            request: router.generalSettingsRequest, adopted: router.generalSettingsRequestAdopted))
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
            // VX-292 U2 (the 2026-10-30 window): the seeded-book mark is the
            // dev app's REAL defaults — never written by a pin.
            session.markSeededBook = { _ in }
            let ops = session.operations
            // VX-292 U1 (R-292-1) — A JUSTIFIED EDIT, RED ON OLD: the world
            // holds the LAUNCH's book (the Prince, by the tour's own constant)
            // and its toured chapter; the old engine looked Sherlock's name up,
            // so `seededBookID` below read nil and step 2 rang nothing.
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            // VX-292 U2 — A JUSTIFIED EDIT (the 2026-10-30 window): a TRUE
            // Prince chapter is born FANNED. Under R-292-17's read a bare
            // chapter reads as broken props, so the start ran the restore road
            // into this world and the tour rang a minted chapter instead.
            try mintFannedBlock(ops, in: chapter.id)
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

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay?.state.seededBookID == prince.id }
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
            session.markSeededBook = { _ in }
            let ops = session.operations
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            // Blocks, or the detail's blockless guard would open it in Write
            // by itself and the pin would be hollow.
            for text in ["Upon this a question arises.", "One ought to be both.", "Men love at their own will."] {
                _ = try ops.newBlock(in: chapter.id, text: text, at: .end)
            }
            // The 2026-10-30 window: a TRUE Prince chapter carries its fan
            // (R-292-17's read prefers the named chapter only while it does).
            try mintFannedBlock(ops, in: chapter.id)
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

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay?.state.seededBookID == prince.id }
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

    /// **VX-292 U3 — the book's mode and the Lenses board's columns reach
    /// the tour, in the REAL shell.** The focused book says its tab (Outline,
    /// then Read through the tabs' own act), and a note in Lenses says how
    /// many columns stand beside its own (one, then two when a saved lens
    /// opens through the board's own landing road) — the facts steps 9 and
    /// 11 advance on. RED ON OLD by mechanism: neither surface published, so
    /// both facts read nil.
    @Test func theBooksModeAndTheLensBoardReachTheToursFactsInTheRealShell() async throws {
        #if DEBUG
        let suite = "tour-facts-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // LIVE uuids: the Lenses board's column memory and the note's mode
            // memory are REAL defaults keys in the test host (the dev app).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.markSeededBook = { _ in }
            let ops = session.operations
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            let minted = try ops.newBlock(in: chapter.id, text: "Upon this a question arises.", at: .end)
            let italian = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.addPostToReading(chapter.id, to: prince.id)
            let lens = try ops.saveLens(
                post: chapter.id, name: TourScript.italianName,
                picks: [minted.block.id: italian.id], undoLabel: "Save Lens")
            _ = try ops.createReading(name: TutorialSeeder.bookName, kind: .book)
            let memoryKeys = [
                "postMode.\(chapter.id)", TakesViewMemory.defaultsKeyPrefix + chapter.id,
            ]
            defer {
                for key in memoryKeys { UserDefaults.standard.removeObject(forKey: key) }
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

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay?.state.seededBookID == prince.id }
            let engine = try #require(TourOracle.overlay, "the request started a tour")

            // The book says its mode.
            router.adopt(.reading(prince.id), in: router.workspace.focusedPane)
            await settle(window, hosting, turns: 300) { engine.state.facts.bookMode == .outline }
            #expect(engine.state.facts.place == .book(prince.id))
            #expect(engine.state.facts.bookMode == .outline, "the book's arrival tab")
            let modeDoor = try #require(BookOutlineGeometry.modeDoors[prince.id], "the book published its mode door")
            modeDoor(.read)
            await settle(window, hosting, turns: 300) { engine.state.facts.bookMode == .read }
            #expect(engine.state.facts.bookMode == .read, "the tabs' own act, heard")

            // The note in Lenses says its columns.
            router.adopt(.post(chapter.id), in: router.workspace.focusedPane, mode: .lenses)
            await settle(window, hosting, turns: 300) { engine.state.facts.lensColumns == 1 }
            #expect(engine.state.facts.noteMode == .lenses)
            #expect(engine.state.facts.lensColumns == 1, "the note's own column")
            #expect(engine.state.facts.bookMode == nil, "a book's mode speaks only for a book")
            session.commandRouter.pendingLensLanding = LensLanding(postID: chapter.id, lensID: lens.id)
            await settle(window, hosting, turns: 300) { engine.state.facts.lensColumns == 2 }
            #expect(engine.state.facts.lensColumns == 2, "the saved lens beside it")

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
            #expect(await TourEngine.launchBookFacts(
                        session: session,
                        landmarks: .init(seededBookID: nil, firstStoryID: nil, fieldGuideID: nil)
                    )?.liveBookID == nil,
                    "the premise: no Prince in the store")

            await endAnyStaleTour(window, hosting)
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

    /// **VX-292 R-292-17 — a Prince whose toured chapter was deleted is
    /// mended at the start, in place.** Her words: *"what if they've deleted
    /// all the takes in the prince? wouldn't that ruin the tutorial?… maybe
    /// it should still be restored"*. The REAL Prince (seeded through its own
    /// restore road into an in-memory store), chapter XVII deleted to the
    /// Trash: the tour's start runs the book's road, which mints exactly that
    /// chapter back — FRESH, through the seeder's bilingual pass, so it
    /// carries its fans — into the same book; every chapter that stood is
    /// the same note; the door's receipt is said; and the tour rings the
    /// mended chapter. A second start finds the props whole and restores
    /// nothing (an intact book is never touched).
    ///
    /// RED ON OLD by mechanism: the old start restored only a book that was
    /// not there, and the old landmarks named XVII or nothing — so
    /// `firstStoryID` was nil (the gate reverted alone: the new fallback
    /// rings the first fanned chapter instead, not XVII — red at the title).
    @Test func aPrinceMissingItsTouredChapterHasItMintedBackWithItsTakes() async throws {
        #if DEBUG
        let suite = "tour-mend-\(UUID().uuidString)"
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
            session.markSeededBook = { _ in }
            session.status.dismissAfter = .seconds(600)
            _ = try await SeededBookRestore.restore(session: session, book: .launchBook)
            _ = try session.operations.createReading(name: TutorialSeeder.bookName, kind: .book)
            let princeName = TourScript.seededBookName
            let chapterTitle = TourScript.firstStoryTitle
            let princeID = try #require(try await db.read { db in
                try Queries.readings(db).first { $0.name == princeName && $0.deletedAt == nil }?.id
            })
            func entries() async throws -> [Queries.ReadingEntry] {
                try await db.read { try Queries.assembleReading($0, readingID: princeID) }
            }
            let before = try await entries()
            let oldChapter = try #require(before.first { $0.title == chapterTitle }?.postID)
            let standing = before.map(\.postID).filter { $0 != oldChapter }
            try session.operations.deleteContainer(oldChapter)
            session.status.clear()

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

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting, turns: 1500) {
                TourOracle.overlay?.state.seededBookID == princeID
            }
            let engine = try #require(TourOracle.overlay, "the tour started after the mend")
            #expect(engine.state.seededBookID == princeID, "the same book, mended in place")
            let mended = try #require(engine.state.firstStoryID, "the tour rings a chapter")
            let after = try await entries()
            #expect(mended != oldChapter, "a fresh chapter (the deleted one stays in the Trash)")
            #expect(after.first { $0.postID == mended }?.title == chapterTitle,
                    "the toured chapter is XVII again")
            #expect(Set(standing).isSubset(of: Set(after.map(\.postID))),
                    "every chapter that stood is the same note, untouched")
            let fannedBlocks = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container_block cb
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                      AND (SELECT COUNT(*) FROM variant v WHERE v.block_id = cb.block_id
                           AND v.deleted_at IS NULL AND v.status = 'active') >= 2
                    """, arguments: [mended]) ?? 0
            }
            #expect(fannedBlocks > 0, "minted through the bilingual pass: its fans came with it")
            #expect(session.status.spoken?.text.hasPrefix(
                "Restored \u{201C}\(princeName)\u{201D}") == true,
                    "the door's own receipt (\(String(describing: session.status.spoken?.text)))")

            // Whole again: a second start touches nothing and says nothing.
            engine.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
            session.status.clear()
            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay != nil }
            let again = try #require(TourOracle.overlay)
            #expect(again.state.firstStoryID == mended)
            #expect(try await entries().count == after.count, "nothing minted")
            #expect(session.status.spoken == nil, "nothing restored, nothing said")
            again.endTour()
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

    /// **The 2026-10-30 window's gap, closed.** A FINISHED Prince whose
    /// props deletions broke (its named chapter unfanned, no fan anywhere,
    /// shipped chapters missing): the restore road would refuse it
    /// (`lockedReading`), so the start never asks — the Finished state is her
    /// deliberate act and the tour walks on the floor (the named chapter as
    /// it stands). Nothing is minted and NOTHING IS SAID (no failure line at
    /// every start). RED ON OLD (d370fd28b's gate): the road ran, refused,
    /// and its failure line was spoken.
    @Test func aFinishedPrinceWithBrokenPropsIsLeftAsItIsAndNothingIsSaid() async throws {
        #if DEBUG
        let suite = "tour-finished-\(UUID().uuidString)"
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
            session.markSeededBook = { _ in }
            session.status.dismissAfter = .seconds(600)
            let ops = session.operations
            let prince = try ops.createReading(name: TourScript.seededBookName, kind: .book)
            let chapter = try ops.createPost(title: TourScript.firstStoryTitle)
            _ = try ops.newBlock(in: chapter.id, text: "One ought to be both.", at: .end)
            try ops.addPostToReading(chapter.id, to: prince.id)
            try ops.lockReading(prince.id)
            _ = try ops.createReading(name: TutorialSeeder.bookName, kind: .book)
            // The premises: broken props, a book the road cannot reach.
            let marks = await TourEngine.landmarks(session: session)
            #expect(marks.seededBookID == prince.id && marks.seededBookPropsBroken,
                    "the premise: the props read broken")
            let facts = await TourEngine.launchBookFacts(session: session, landmarks: marks)
            #expect(facts?.acceptsChapters == false, "the premise: a Finished book admits nothing")
            let membersBefore = try await db.read { try Queries.assembleReading($0, readingID: prince.id).count }

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
            session.status.clear()

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting, turns: 600) {
                TourOracle.overlay?.state.seededBookID == prince.id
            }
            let engine = try #require(TourOracle.overlay, "the tour started")
            #expect(engine.state.firstStoryID == chapter.id, "the floor: the named chapter as it stands")
            await settle(window, hosting, turns: 30) { false }
            #expect(session.status.spoken == nil,
                    "nothing attempted, nothing said (\(String(describing: session.status.spoken?.text)))")
            #expect(try await db.read { try Queries.assembleReading($0, readingID: prince.id).count }
                    == membersBefore, "nothing minted into her Finished book")

            engine.endTour()
            await settle(window, hosting) { TourOracle.overlay == nil }
        }
        #endif
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
            session.markSeededBook = { _ in }
            session.status.dismissAfter = .seconds(600)
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
                // A TRUE Prince world (the 2026-10-30 window): every chapter is
                // born fanned, so the props read whole and the named chapter
                // is the toured one — the restore road is never asked.
                try mintFannedBlock(ops, in: note.id)
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
            session.status.clear()

            await endAnyStaleTour(window, hosting)
            router.tourRequested = true
            await settle(window, hosting) { TourOracle.overlay?.state.seededBookID == prince.id }
            let engine = try #require(TourOracle.overlay, "the request started a tour")
            #expect(engine.state.firstStoryID == target)
            #expect(session.status.spoken == nil,
                    "whole props: the restore road is never asked, nothing is said (\(String(describing: session.status.spoken?.text)))")
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
        walkFromTakesToTheBookcase(engine)
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

// MARK: - VX-292 U3 — the grown tour's middle, walked by facts

/// **Steps 7 to 12, the designed road** (R-292-13's flow): from Takes mode,
/// next past the flip (offered, never required — P-292-8), next past Read,
/// a second Lenses column, next past Compare and Blocks, up to the book and
/// next, its Read, then down through a live box and home to the Bookcase —
/// where step 13 waits for her own note.
@MainActor
private func walkFromTakesToTheBookcase(_ engine: TourEngine) {
    engine.next()
    engine.next()
    engine.observe(.init(place: .note("scandal"), noteMode: .lenses, lensColumns: 2))
    engine.next()
    engine.observe(.init(place: .book("sherlock"), bookMode: .outline))
    engine.next()
    engine.observe(.init(place: .book("sherlock"), bookMode: .read))
    engine.observe(.init(place: .book("sherlock"), bookNoteLive: true, bookMode: .index))
    engine.observe(.init(place: .area(.bookcase)))
}

// MARK: - VX-292 U2's world helpers (the 2026-10-30 window)

/// A block carrying a SECOND take — the fan every real Prince chapter is born
/// with (R-292-17's read prefers the named chapter only while it carries
/// one; a bare chapter reads as broken props and the start would run the
/// restore road into a pin's world).
@MainActor
private func mintFannedBlock(_ ops: Operations, in noteID: String) throws {
    let minted = try ops.newBlock(in: noteID, text: "Men love at their own will.", at: .end)
    _ = try ops.branchVariant(minted.block.id, from: minted.variant.id)
}

/// A pin that stopped early (a failed `#require`) leaves its tour's engine
/// alive in `TourOracle` — the window's finding: the next pin read the
/// previous pin's engine. End it, so the next read is this pin's own.
@MainActor
private func endAnyStaleTour(_ window: NSWindow, _ hosting: NSView) async {
    #if DEBUG
    guard let stale = TourOracle.overlay else { return }
    stale.endTour()
    await settle(window, hosting) { TourOracle.overlay == nil }
    #endif
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
