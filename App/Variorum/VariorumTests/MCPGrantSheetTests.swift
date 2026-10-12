//
//  MCPGrantSheetTests.swift
//  VariorumTests (Mac)
//
//  13n-c U2 — THE GRANT SHEET REBUILT (VX-156 items 1 + 6; her kickoff's
//  "hundreds of books and notes … sort by shelf … favorites"; round 2's
//  "recently edited"; the approved mockup §1/§1b/§11): the ONE picker's
//  sections (quick sections only before typing; a match once, under its home),
//  the book picker's two layouts in the Bookcase's order, the distinguisher on
//  a collision, the durations a target can take with the why, the confirm with
//  the distinguisher (and "on" for a note), R-AIR-8's words with L1, R2-3's
//  inert row, F2's clause on the ask road, and the door's reads behind them.
//  A ruled BUILD — the walk (or, while the session is locked, the gated
//  capture harness) shows the faces.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()
private let enUS = Locale(identifier: "en_US")
/// 2026-10-11 12:00 UTC.
private let now = Date(timeIntervalSince1970: 1_791_720_000)

private func stamp(day: Int, hour: Int = 12) -> String {
    let date = utc.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    return DateFormatter.variorumISO8601.string(from: date)
}

private func book(
    _ id: String, _ name: String, wing: String = "", shelf: String? = nil, starred: Bool = false,
    notes: Int = 1, made: Int = 1, edited: Int = 2
) -> Queries.MCPGrantableBook {
    Queries.MCPGrantableBook(
        id: id, name: name, wingID: wing, shelfID: shelf, starred: starred, noteCount: notes,
        createdAt: stamp(day: made), lastEdited: stamp(day: edited))
}

private func shelf(_ id: String, _ name: String, position: String, wing: String = "", glyph: String? = nil) -> Shelf {
    Shelf(id: id, wingId: wing, name: name, glyph: glyph, position: position,
          createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
}

private func ask(
    _ kind: MCPGrantRule.ScopeKind, id: String = "b1", title: String = "the adventures of sherlock holmes",
    rung: MCPGrantRule.Rung = .suggest
) -> MCPAsk {
    MCPAsk(clientName: "claude-code", scopeKind: kind, scopeID: id, title: title, rung: rung, fence: nil)
}

@MainActor
@Suite("13n-c U2 — the grant sheet rebuilt", .serialized)
struct MCPGrantSheetTests {
    // MARK: - The ONE picker's sections (a pure brain extension)

    private let sections = [
        SearchPickerSection(id: "recent", title: "Recently edited", options: [
            SearchPickerOption(id: "b2", label: "percy"),
        ], isQuick: true),
        SearchPickerSection(id: "starred", title: "Starred", options: [
            SearchPickerOption(id: "b1", label: "a letter"),
        ], isQuick: true),
        SearchPickerSection(id: "shelf:s1", title: "Welcome", options: [
            SearchPickerOption(id: "b1", label: "a letter"),
            SearchPickerOption(id: "b2", label: "percy"),
        ]),
        SearchPickerSection(id: "empty", title: "research", options: []),
        SearchPickerSection(id: "unshelved", title: "Unshelved", options: [
            SearchPickerOption(id: "b3", label: "Pérez notes"),
        ]),
    ]

    @Test func quickSectionsShowOnlyBeforeTypingAndAMatchShowsOnceUnderItsHome() {
        #expect(SearchPickerBrain.visible(sections, query: "").map(\.id)
                == ["recent", "starred", "shelf:s1", "unshelved"], "an empty shelf draws no header")
        let typed = SearchPickerBrain.visible(sections, query: "PER")
        #expect(typed.map(\.id) == ["shelf:s1", "unshelved"], "quick sections vanish once she types")
        #expect(typed.flatMap(\.options).map(\.id) == ["b2", "b3"],
                "percy once (under its shelf, not Recently edited); Pérez by the brain's diacritic sameness")
        #expect(SearchPickerBrain.visible(sections, query: "zzz").isEmpty)
    }

    @Test func returnTakesTheFirstVisibleRow() {
        #expect(SearchPickerBrain.returnChoice(sections: sections, query: "") == .pick("b2"))
        #expect(SearchPickerBrain.returnChoice(sections: sections, query: "letter") == .pick("b1"))
        #expect(SearchPickerBrain.returnChoice(sections: sections, query: "zzz") == .nothing)
    }

    // MARK: - The book picker's layouts (her "sort by shelf … favorites")

    private var places: MCPGrantPlaces {
        MCPGrantPlaces(
            books: [
                book("b1", "a letter", shelf: "s2", edited: 3),
                book("b2", "Book 10", shelf: "s1", starred: true, edited: 9),
                book("b3", "Book 9", shelf: "s1", edited: 4),
                book("b4", "loose", edited: 8),
                book("b5", "percy", wing: "w1", shelf: "s3", starred: true, edited: 7),
                book("b6", "the adventures of sherlock holmes", shelf: "s1", notes: 12, made: 9, edited: 5),
                book("b7", "The Adventures of Sherlock Holmes", shelf: "s1", notes: 12, made: 11, edited: 6),
            ],
            shelves: [
                shelf("s2", "research", position: "b"),
                shelf("s1", "Welcome", position: "a", glyph: "\u{2726}"),
                shelf("s3", "worksheets", position: "a", wing: "w1"),
            ].sorted { $0.position < $1.position },
            wings: [Wing(id: "w1", name: "variorum", position: "a",
                         createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))])
    }

    @Test func byShelfIsRecentThenStarredThenEachShelfInStripOrderThenUnshelvedPerWing() {
        let layouts = MCPGrantPicker.bookArrangements(places, now: now, calendar: utc, locale: enUS)
        #expect(layouts.map(\.label) == ["by shelf", "a\u{2013}z"])
        let byShelf = layouts[0].sections
        #expect(byShelf.map(\.title) == [
            "Recently edited", "Starred", "\u{2726} Welcome", "research", "Unshelved",
            "variorum \u{00B7} worksheets", "variorum \u{00B7} unshelved",
        ], "Home's shelves in strip order, Home's unshelved, then the next wing's — named")
        #expect(byShelf[0].isQuick && byShelf[1].isQuick && !byShelf[2].isQuick)
        #expect(byShelf[0].options.map(\.id) == ["b2", "b4", "b5", "b7", "b6"], "the 5 most recently edited")
        #expect(byShelf[1].options.map(\.id) == ["b2", "b5"], "starred, a–z")
        #expect(byShelf[2].options.map(\.id) == ["b3", "b2", "b6", "b7"],
                "inside a shelf the Bookcase's digit-aware a–z (Book 9 before Book 10)")
        let az = layouts[1].sections
        #expect(az.map(\.title) == ["Recently edited", "Starred", "All books"])
        #expect(az[2].options.map(\.id) == ["b1", "b3", "b2", "b4", "b5", "b6", "b7"])
    }

    @Test func aCollidingNameWearsItsDistinguisherInAccentAndEveryRowItsContext() {
        let rows = MCPGrantPicker.bookArrangements(places, now: now, calendar: utc, locale: enUS)[0]
            .sections.flatMap(\.options)
        let first = rows.first { $0.id == "b6" }, second = rows.first { $0.id == "b7" }
        #expect(first?.annotation == "made Oct 9" && first?.emphasized == true, "mockup §1b's pair")
        #expect(second?.annotation == "made Oct 11" && second?.emphasized == true)
        #expect(first?.detail == "Welcome \u{00B7} 12 notes \u{00B7} edited Oct 5",
                "the context line: shelf (its name — the glyph is the section's) · N notes · (marks) · last edited")
        let percy = rows.first { $0.id == "b5" }
        #expect(percy?.annotation == nil && percy?.emphasized == false, "a name of its own needs no distinguisher")
        #expect(percy?.detail == "variorum wing \u{00B7} worksheets \u{00B7} 1 note \u{00B7} edited Oct 7")
    }

    // MARK: - How long

    @Test func aFencedNoteIsNeverOfferedAlwaysAndTheSheetSaysWhy() {
        #expect(MCPGrantPicker.durations(connected: true, noteFence: nil) == [.once, .connection, .always])
        #expect(MCPGrantPicker.durations(connected: true, noteFence: .journal) == [.once, .connection])
        #expect(MCPGrantPicker.durations(connected: false, noteFence: .privateMark) == [.once])
        #expect(MCPGrantPicker.durationWhys(
            connected: true, clientChosen: true, note: ("morning pages \u{2014} oct 9", .journal))
                == ["\u{201C}morning pages \u{2014} oct 9\u{201D} is a daily Journal entry \u{2014} it's only ever shared one ask at a time, so always isn't offered."],
                "mockup §1's note leg, verbatim")
        #expect(MCPGrantPicker.durationWhys(connected: false, clientChosen: true, note: nil)
                == [MCPPaneCopy.whileConnectedNote])
        #expect(MCPGrantPicker.durationWhys(connected: false, clientChosen: false, note: nil).isEmpty,
                "no client chosen yet ⇒ nothing to say about its connection")
    }

    // MARK: - The confirm

    @Test func theConfirmNamesThePlaceWithItsDistinguisherAndANoteReadsOn() {
        #expect(MCPPaneCopy.confirm(
            verb: "Grant", rung: .suggest, scope: .book, place: "the adventures of sherlock holmes",
            distinguisher: "made Oct 9", duration: .always)
                == "Grant suggest in “the adventures of sherlock holmes” (made Oct 9) always, including to future entries",
                "mockup §1's confirm + R-AIR-3's clause")
        #expect(MCPPaneCopy.confirm(verb: "Grant", scope: .note, place: "morning pages — oct 9", duration: .once)
                == "Grant read on “morning pages — oct 9” once", "mockup §1's note leg: “on”")
        let parts = MCPPaneCopy.confirmParts(
            verb: "Grant", rung: .read, scope: .book, place: "x", distinguisher: "made Oct 9", duration: .once)
        #expect(parts.place == "x" && parts.tail.hasPrefix("” (made Oct 9) once"),
                "the distinguisher rides the tail — it never compresses away")
    }

    @Test func aLongPlaceShortensInTheMiddleAndOnlyThePlace() {
        #expect(MCPPaneCopy.shortPlace("dream journal") == "dream journal")
        let long = String(repeating: "abcdefghij", count: 6)
        let short = MCPPaneCopy.shortPlace(long)
        #expect(short.count == MCPPaneCopy.confirmPlaceLimit && short.contains("\u{2026}"))
        #expect(short.hasPrefix("abcdefghij") && short.hasSuffix("abcdefghij"), "head and tail kept")
    }

    // MARK: - R-AIR-8 and L1

    @Test func theSettingsClassWordsSayNoAIAndTheBoundaryIsSaid() {
        // Her sitting's second round (A JUSTIFIED EDIT, the ritual): the
        // Shared section's title is her carve-out — "AI" is fair inside the
        // MCP pane — so it leaves the no-"AI" list and is pinned to her words.
        let words = [
            MCPPaneCopy.enableBlurb, MCPPaneCopy.sheetLead,
            MCPPaneCopy.sheetTitleChoosing, MCPPaneCopy.noApprovedClient, MCPPaneCopy.fencedBooksNote,
            MCPPaneCopy.clientBoundary, MCPPaneCopy.noBooks, MCPPaneCopy.openBookDetail,
            MCPPaneCopy.wingDetail("Home"), MCPPaneCopy.whileConnectedNote, MCPPaneCopy.noClients,
            MCPPaneCopy.inertDetail(.privateMark, kind: .book), MCPPaneCopy.inertDetail(.journal, kind: .book),
            MCPPaneCopy.inertDetail(.journal, kind: .note),
        ]
        for line in words {
            #expect(line.range(of: #"\bAI\b"#, options: .regularExpression) == nil, "R-AIR-8: \(line)")
        }
        #expect(MCPPaneCopy.sharedSection == "Shared with AI", "P-13nc-U2-2 reversed in-pane, her ruling")
        // 13n-c U6 JOB 4c (ladder R2-N2): Revoke's unavailable note names the
        // section by the noun she now reads there (PROVISIONAL — final words
        // hers at the copy pass).
        #expect(CapabilityRegistry.capability(.mcpRevokeGrant).unavailableNote
                == "Sharing with AI is revoked in Settings \u{25B8} MCP.",
                "R2-N2: the note's noun follows the \(MCPPaneCopy.sharedSection) section")
        #expect(MCPPaneCopy.clientBoundary
                == "A client names itself when it connects. Variorum can't verify the name: a grant lets whatever connects under that name do what you granted.",
                "L1 — the brief §12's words, verbatim")
    }

    // MARK: - R2-3: inert, never called shared

    @Test func anInertRowSaysInertAndWhyAndTheClientRowCountsOnlyReaching() {
        #expect(MCPPaneCopy.inertDetail(.privateMark, kind: .book)
                == "inert \u{2014} the book is marked Private, which always asks")
        #expect(MCPPaneCopy.inertDetail(.journal, kind: .book)
                == "inert \u{2014} it's your daily Journal now, which always asks")
        #expect(MCPPaneCopy.reads(2, inert: 0) == "2 shared places")
        #expect(MCPPaneCopy.reads(2, inert: 1) == "2 shared places \u{00B7} 1 inert")
        #expect(MCPPaneCopy.reads(0, inert: 1) == "nothing shared \u{00B7} 1 inert")
    }

    // MARK: - The ask road (F2 + the one rule's label)

    @Test func theAskWearsItsDistinguisherAndABookAskSaysItsLiveReach() {
        #expect(MCPAskCopy.title(ask(.book), distinguisher: "made Oct 11")
                == "claude-code asks to suggest in “the adventures of sherlock holmes” (made Oct 11)",
                "mockup §1b's ask title")
        #expect(MCPAskCopy.title(ask(.book)) == "claude-code asks to suggest in “the adventures of sherlock holmes”")
        // Stage B R1 B9 (A JUSTIFIED EDIT — the ritual + the truth pin): "Any
        // answer below grants it" was false for Don't allow, which grants
        // nothing; the line names the answers that grant.
        #expect(MCPAskCopy.reachLine(ask(.book))
                == "Allowing grants it in “the adventures of sherlock holmes”, including to future entries.",
                "F2: R-AIR-3's clause where an answer MINTS a book grant")
        #expect(MCPAskCopy.reachLine(ask(.book), distinguisher: "made Oct 11")
                == "Allowing grants it in “the adventures of sherlock holmes” (made Oct 11), including to future entries.",
                "the reach line names the same book the title does")
        #expect(MCPAskCopy.reachLine(ask(.wing, id: "", title: "Home"))
                == "Allowing grants it in the Home wing, including notes added later.")
        for kind in [MCPGrantRule.ScopeKind.book, .wing] {
            let line = MCPAskCopy.reachLine(ask(kind, id: "", title: "Home")) ?? ""
            #expect(!line.localizedCaseInsensitiveContains("any answer"),
                    "\(MCPAskCopy.dontAllow) grants nothing — the line never says every answer grants")
        }
        #expect(MCPAskCopy.reachLine(ask(.note, id: "n1", title: "ch 7")) == nil, "a note grant names one note")
    }

    // MARK: - The door's reads (an in-memory store)

    @Test func theNoteFeedMarksTheFenceStaysInTheChosenWingAndNamesAPrefilledNote() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = session.operations
            let studio = try ops.createWing(name: "studio")
            let open = try ops.createPost(title: "parser notes")
            let marked = try ops.createPost(title: "parser secrets")
            _ = try ops.setNotePrivate(marked.id, true)
            let elsewhere = try ops.createPost(title: "parser elsewhere", wingId: studio.id)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }

            let home = await door.grantNotes(query: "parser", wingID: "")
            #expect(Set(home.map(\.id)) == [open.id, marked.id], "one wing at a time")
            #expect(home.first { $0.id == marked.id }?.fence == .privateMark, "fence-marked on the one facts")
            #expect(home.first { $0.id == open.id }?.fence == nil)
            #expect(await door.grantNotes(query: "parser", wingID: studio.id).map(\.id) == [elsewhere.id])

            let sections = MCPGrantPicker.noteSections(await door.grantNotes(query: "", wingID: ""), query: "")
            #expect(sections.first?.title == "Recently edited", "the feed's resting state, titled")
            let row = sections.first?.options.first { $0.id == marked.id }
            #expect(row?.annotation == "Private" && row?.emphasized == true)
            #expect(MCPGrantPicker.dayWords("2026-09-30", now: now, calendar: utc, locale: enUS) == "Sep 30",
                    "a day key in the sheet's own day words (the book rows' “edited …”)")
            #expect(MCPGrantPicker.dayWords("not a day", now: now) == "not a day")

            let named = await door.grantNote(elsewhere.id)
            #expect(named?.title == "parser elsewhere" && named?.wingID == studio.id,
                    "a pre-filled note brings its own wing (U3's doors)")
        }
    }

    /// The dev-store scale seed (DEBUG-only, env-gated — `ScaleFixture`'s
    /// books part): shelves, books, the same-named pair, the fence's
    /// exclusions, the notes filed — once.
    @Test func theScaleSeedMintsTheGrantRoadsLibraryOnce() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let request = ScaleFixture.Request(notes: 30, longBlocks: 2, books: 45, shelves: 4)
            #expect(ScaleFixture.Request.parse("notes=520,long=40,books=160,shelves=9")
                    == ScaleFixture.Request(notes: 520, longBlocks: 40, books: 160, shelves: 9))
            #expect(try await ScaleFixture.seed(session: session, request: request))
            let places = try await db.read { try Queries.mcpGrantPlaces($0) }
            #expect(places.shelves.count == 4)
            #expect(places.books.count == 44, "45 minted, the Private one never offered")
            #expect(places.books.filter { $0.name == "the adventures of sherlock holmes" }.count == 2)
            #expect(places.books.contains { $0.shelfID == nil }, "some unshelved")
            #expect(places.books.contains { $0.marks.finished } && places.books.contains { $0.marks.archived })
            #expect(places.books.map(\.noteCount).reduce(0, +) > 0, "the fixture's notes filed into books")
            let labels = places.bookDistinguishers(now: Date())
            let pair = places.books.filter { $0.name == "the adventures of sherlock holmes" }.map(\.id)
            #expect(pair.allSatisfy { labels[$0]?.hasPrefix("made ") == true }, "the pair falls to the made day: \(labels)")
            #expect(try await ScaleFixture.seed(session: session, request: request) == false, "a relaunch mints nothing")
        }
    }

    @Test func thePlacesAndWhoTheSheetReadsAreTheCoresAndTheDistinguishersMatch() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let ops = session.operations
            let first = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let second = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let older = try ops.recordMCPContact(name: "older", version: nil)
            try ops.approveMCPClient(older.id, granting: .init(rung: .read, scopeKind: .book, scopeID: first.id, duration: .always))
            let newer = try ops.recordMCPContact(name: "newer", version: nil)
            try ops.approveMCPClient(newer.id, granting: .init(rung: .read, scopeKind: .book, scopeID: second.id, duration: .always))
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(await door.clientsByRecentGrant().map(\.name) == ["newer", "older"])
            let places = await door.grantPlaces()
            #expect(Set(places.books.map(\.id)) == [first.id, second.id])
            let labels = await door.placeDistinguishers(now: now)
            #expect(labels.books[first.id] != nil && labels.books[first.id] != labels.books[second.id],
                    "the pane's rows and the ask wear the picker's own distinguishers")
            #expect(labels.books == places.bookDistinguishers(now: now))
        }
    }
}
