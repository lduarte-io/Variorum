//
//  BookPanelMCPMarksTests.swift
//  VariorumTests (Mac)
//
//  VX-330 (RUN VX-336, U6b) — THE BOOK PANEL'S COLLAPSED ONE-NOTE CHAPTER ROW
//  WEARS ITS NOTE'S TWO MCP MARKS. Her words, verbatim: "It's an issue where
//  combined chapter / note headings don't show any AI symbol but that's how the
//  example sherlock holmes looks and i think people might share that book with
//  AI as an example so i want it fixed pre launch."
//
//  The row-8 rule collapses a chapter whose ONE note says its name into ONE
//  line, and that line IS the note's row (its click opens the note, its menu is
//  the note's). The panel held the note's reach (`entryIDs` maps every entry)
//  and the window's board held its asks, but only the NOTE row drew the shared
//  icon and the waiting-ask glyph — so every chapter of the seeded sherlock
//  wore neither. These pins:
//    · the ONE decision (`BookPanelBrain.markedNote`), pure: a note line and a
//      collapsed chapter line stand for their note; a plain heading and
//      "unfiled" for none;
//    · the face, MOUNTED and CLICKED (VX-281 ladder R1-5's rig): the collapsed
//      row draws both marks, the ask glyph's press answers that ask, the icon's
//      press presents its popover, and the row's open never fires;
//    · the sweep, MOUNTED: under a book grant, with an ask on every note, the
//      panel draws exactly one icon and one ask glyph per note — every row that
//      stands for a note, the collapsed one included, and no heading.
//
//  RED-ON-OLD, stated: the strict pre-fix tree has no `markedNote` and no ask
//  glyph probe, so the red tree is the SEAM (U6b piece 1): this API with the
//  OLD behaviour behind it — a chapter line stands for no note, exactly what
//  the old face drew. The red product `vx336-u6b-red` is the final tree with
//  ONLY the fix's line reverted; every collapsed-row leg below reads nil, 0 or
//  a short count there.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private let marksStamp = Date(timeIntervalSince1970: 1_782_864_000)

private func marksSection(_ id: String, _ name: String, _ position: String) -> ReadingSection {
    ReadingSection(id: id, readingId: "b", name: name, position: position,
                   createdAt: marksStamp, updatedAt: marksStamp)
}

private func marksEntry(_ id: String, _ title: String) -> Queries.ReadingEntry {
    Queries.ReadingEntry(postID: id, title: title, entryDate: nil, sectionPath: nil)
}

/// The asks a mount pin's road answered (her press on a pending glyph).
@MainActor
private final class AnsweredAsks {
    var ids: [String] = []
}

@MainActor
@Suite("VX-330 — the Book Panel's collapsed one-note chapter row wears its note's MCP marks", .serialized)
struct BookPanelMCPMarksTests {
    // MARK: - The ONE decision (pure)

    /// The note each line stands for — whose shared icon and waiting ask it
    /// wears. The navigator's own grouping (`BookPanelTests`' fixture): a
    /// chapter with two notes (a plain heading), a chapter whose one note says
    /// its name (row 8 — collapsed), and a straggler under "unfiled".
    @Test func aLineThatStandsForANoteWearsItsMarksAndAHeadingWearsNone() {
        let one = marksSection("s1", "Beginnings", "a")
        let two = marksSection("s2", "The Storm", "b")
        let e1 = marksEntry("p1", "first"), e2 = marksEntry("p2", "second")
        let e3 = marksEntry("p3", "The Storm"), e4 = marksEntry("p4", "loose")
        let groups = BookStructureModel.grouped(
            entries: [e1, e2, e3, e4], sections: [one, two],
            assignments: ["p1": "s1", "p2": "s1", "p3": "s2"])
        let lines = BookPanelBrain.lines(groups)
        #expect(lines == [
            .chapter(one, collapsed: nil), .note(e1, indented: true), .note(e2, indented: true),
            .chapter(two, collapsed: e3), .unfiled, .note(e4, indented: false),
        ], "the fixture is the navigator's grouping (row 8 collapses \"The Storm\")")
        #expect(lines.map(BookPanelBrain.markedNote) == [nil, "p1", "p2", "p3", nil, "p4"],
                "every note's row is marked exactly once — the collapsed chapter row for its note")
        #expect(BookPanelBrain.markedNote(.chapter(two, collapsed: e3)) == "p3",
                "the collapsed one-note chapter row IS its note's row (red on the seam)")
        #expect(BookPanelBrain.markedNote(.chapter(one, collapsed: nil)) == nil,
                "a plain chapter heading is no MCP place")
        #expect(BookPanelBrain.markedNote(.unfiled) == nil, "\"unfiled\" is no MCP place")
        #expect(BookPanelBrain.markedNote(.note(e1, indented: true)) == "p1")
        #expect(BookPanelBrain.markedNote(.note(e4, indented: false)) == "p4")
    }

    // MARK: - The world (the R1-5 click pins' shape)

    private func withWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return marksStamp.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 330))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    @discardableResult
    private func approved(_ ops: Operations, _ name: String) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) — words", registeringUndo: false)
        return post
    }

    private func grant(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
    }

    /// Wait (bounded, ~4 s) for a condition a held observation settles.
    private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<400 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    /// One waiting ask on a note, as the window's board carries it.
    private func ask(_ id: String, on noteID: String, by client: String) -> MCPAskFace {
        MCPAskFace(id: id, target: .note(noteID), clientName: client,
                   here: "\(client) asks to suggest here",
                   named: "\(client) asks to suggest in a note")
    }

    /// The window's road, its ask presses recorded (no sheet — the pin reads
    /// the press, not the sheet it would open).
    private func road(_ answered: AnsweredAsks) -> MCPShareRoad {
        MCPShareRoad(
            canShare: true, indicatorOn: true, open: { _ in },
            sheet: { _, _ in AnyView(EmptyView()) }, revoke: { _ in },
            answerAsk: { answered.ids.append($0) })
    }

    /// The panel's held reads, started by hand (the test host never fires a
    /// view's `.task`): the membership, the shown book's contents, the reach
    /// over its entries. Returns the tasks to cancel.
    private func holdThePanel(
        _ session: AppSession, open: Container, book: Reading, model: BookPanelModel,
        membership: NoteMembershipModel, notes: Int
    ) async throws -> [Task<Void, Never>] {
        let track = Task { await membership.track(session: session, postID: open.id) }
        let contents = Task { await model.observe(bookID: book.id) }
        #expect(try await settle {
            model.entryIDs(for: book.id).count == notes && membership.readings(for: open.id).count == 1
        }, "the panel's book and its \(notes) entries landed")
        let hold = Task { await model.holdReach(model.entryIDs(for: book.id)) }
        return [track, contents, hold]
    }

    private func countOpens() -> (LockIsolated<Int>, NSObjectProtocol) {
        let opens = LockIsolated(0)
        let observer = NotificationCenter.default.addObserver(
            forName: .variorumOpenBookAtPost, object: nil, queue: nil
        ) { _ in opens.withValue { $0 += 1 } }
        return (opens, observer)
    }

    // MARK: - The collapsed row's two marks, drawn and pressed

    /// sherlock's shape in miniature: a chapter whose one note says its name
    /// (collapsed), the open note unfiled. A client reaches the story; an ask
    /// waits on it. The collapsed row draws BOTH marks — her press on the
    /// waiting ask answers that ask, her press on the icon presents its
    /// popover — and the row's own open (the click-through to the book) never
    /// fires for either.
    @Test func theCollapsedChapterRowWearsItsNotesIconAndWaitingAskAndEachPressIsItsOwn() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "vx330-panel")
            let open = try note(ops, "the open note")
            let story = try note(ops, "a scandal in bohemia")
            let book = try ops.createReading(name: "the adventures", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)
            _ = try ops.addPostToReading(story.id, to: book.id)
            let chapter = try ops.createSection(in: book.id, name: "a scandal in bohemia")
            try ops.assignPostToSection(story.id, in: book.id, section: chapter.id)
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, story.id))

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            let tasks = try await holdThePanel(
                session, open: open, book: book, model: model, membership: membership, notes: 2)
            defer { tasks.forEach { $0.cancel() } }
            #expect(try await settle { model.reach[story.id] != nil }, "the story's reach landed")
            let lines = BookPanelBrain.lines(model.groups(for: book.id))
            #expect(lines.contains {
                if case .chapter(_, let collapsed) = $0 { return collapsed?.postID == story.id }
                return false
            }, "the story's chapter collapses into ONE row (row 8) — the fixture is sherlock's shape")
            #expect(!lines.contains {
                if case .note(let entry, _) = $0 { return entry.postID == story.id }
                return false
            }, "the story has no note row of its own — the chapter row is its only row")

            let answered = AnsweredAsks()
            let (opens, observer) = countOpens()
            defer { NotificationCenter.default.removeObserver(observer) }
            let rig = SharedIconRig(
                BookPanelView(session: session, postID: open.id, membership: membership, model: model)
                    .environment(\.mcpAskBoard, MCPAskBoard(faces: [ask("ask-vx330", on: story.id, by: "vx330-panel")]))
                    .environment(\.mcpShareRoad, road(answered)),
                width: 340, height: 600)
            defer { rig.close() }

            // The waiting ask, first (its press opens no popover to dismiss).
            let glyphDrawn = await rig.poll(timeout: 8) { MCPAskGlyphProbe.frames(in: rig.window).count == 1 }
            await rig.poll(timeout: 0.6) { false }
            #expect(glyphDrawn && MCPAskGlyphProbe.frames(in: rig.window).count == 1,
                    "the collapsed row wears the waiting ask (\(MCPAskGlyphProbe.frames(in: rig.window).count) drawn)")
            let glyph = try #require(MCPAskGlyphProbe.frames(in: rig.window).first, "the waiting ask drew")
            #expect(glyph.width >= 6 && glyph.height >= 6, "the glyph has a body to press (\(glyph))")
            await rig.click(at: NSPoint(x: glyph.midX, y: glyph.midY))
            #expect(await rig.poll(timeout: 3) { answered.ids == ["ask-vx330"] },
                    "her press on the glyph answers THAT ask (\(answered.ids))")
            await rig.poll(timeout: 0.4) { false }
            #expect(opens.value == 0, "the row's open never fired for the glyph's press")

            // The shared icon, on the same row.
            let iconDrawn = await rig.poll(timeout: 4) { MCPSharedIconProbe.frames(in: rig.window).count == 1 }
            #expect(iconDrawn, "the collapsed row wears the shared icon (\(MCPSharedIconProbe.frames(in: rig.window).count) drawn)")
            let icon = try #require(MCPSharedIconProbe.frames(in: rig.window).first, "the icon drew")
            #expect(abs(icon.midY - glyph.midY) <= 4, "the icon and the waiting ask sit on ONE row (\(icon) · \(glyph))")
            #expect(icon.maxX <= glyph.minX + 1, "the icon comes first, then the ask — the Bookcase's order")
            let before = MCPSharedIconProbe.presentations(of: "vx330-panel")
            await rig.click(at: NSPoint(x: icon.midX, y: icon.midY))
            #expect(await rig.poll(timeout: 3) { MCPSharedIconProbe.presentations(of: "vx330-panel") > before },
                    "her press on the icon presents its popover")
            await rig.poll(timeout: 0.4) { false }
            #expect(opens.value == 0, "the row's open never fired for the icon's press")
        }
    }

    // MARK: - The sweep: every note's row marked exactly once, no heading

    /// A chaptered book with every row shape: a collapsed one-note chapter, a
    /// plain heading over two notes, "unfiled" over the open note. A BOOK grant
    /// reaches all four notes; an ask waits on each. The panel draws exactly
    /// four icons and four ask glyphs — one per note, each on the one row that
    /// stands for it (a heading has no note to wear) — so no row shape is left.
    @Test func underABookGrantEveryNotesRowWearsBothMarksTheCollapsedChapterRowIncluded() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "vx330-sweep")
            let open = try note(ops, "the open note")
            let lone = try note(ops, "the lone story")
            let first = try note(ops, "first of two")
            let second = try note(ops, "second of two")
            let book = try ops.createReading(name: "the sweep book", kind: .book)
            for post in [open, lone, first, second] { _ = try ops.addPostToReading(post.id, to: book.id) }
            let solo = try ops.createSection(in: book.id, name: "the lone story")
            let pair = try ops.createSection(in: book.id, name: "two stories")
            try ops.assignPostToSection(lone.id, in: book.id, section: solo.id)
            try ops.assignPostToSection(first.id, in: book.id, section: pair.id)
            try ops.assignPostToSection(second.id, in: book.id, section: pair.id)
            _ = try ops.grantMCPAccess(client.id, grant(.read, .book, book.id))

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            let tasks = try await holdThePanel(
                session, open: open, book: book, model: model, membership: membership, notes: 4)
            defer { tasks.forEach { $0.cancel() } }
            #expect(try await settle { model.reach.count == 4 }, "the book grant reaches all four rows' notes")
            let lines = BookPanelBrain.lines(model.groups(for: book.id))
            #expect(lines.count == 6 && lines.compactMap(BookPanelBrain.markedNote).count == 4,
                    "six lines — a collapsed chapter, a heading, two notes, unfiled, the open note — four stand for notes")

            let notes = [open, lone, first, second]
            let board = MCPAskBoard(faces: notes.enumerated().map { index, post in
                ask("ask-\(index)", on: post.id, by: "vx330-sweep")
            })
            let answered = AnsweredAsks()
            let rig = SharedIconRig(
                BookPanelView(session: session, postID: open.id, membership: membership, model: model)
                    .environment(\.mcpAskBoard, board)
                    .environment(\.mcpShareRoad, road(answered)),
                width: 340, height: 600)
            defer { rig.close() }
            let drawn = await rig.poll(timeout: 8) {
                MCPSharedIconProbe.frames(in: rig.window).count == 4
                    && MCPAskGlyphProbe.frames(in: rig.window).count == 4
            }
            await rig.poll(timeout: 0.6) { false }
            #expect(drawn, "four icons and four waiting asks — one per note (icons \(MCPSharedIconProbe.frames(in: rig.window).count), asks \(MCPAskGlyphProbe.frames(in: rig.window).count))")
            #expect(MCPSharedIconProbe.frames(in: rig.window).count == 4, "never a fifth: a heading wears no icon")
            #expect(MCPAskGlyphProbe.frames(in: rig.window).count == 4, "never a fifth: a heading wears no ask")
            // Each note's two marks share its row: four distinct rows.
            let iconRows = Set(MCPSharedIconProbe.frames(in: rig.window).map { Int($0.midY.rounded()) })
            let askRows = Set(MCPAskGlyphProbe.frames(in: rig.window).map { Int($0.midY.rounded()) })
            #expect(iconRows.count == 4 && askRows.count == 4, "four rows, one pair each")
        }
    }
}

// MARK: - VX-354 — the readings the panel NAMES wear their marks too

//  RUN VX-548, batch 2a (the run record `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`,
//  BATCH 2a RECORD; born as the VX-336 U6b sweep's OUTSIDE rows, its OWED 2): the
//  panel's HEADER (the shown book's name) and the names its "appears in N gatherings"
//  line opens wore neither `MCPSharedIcon` nor `MCPAskGlyph`, while every note row
//  did. They wear the Bookcase row's pair now, the reach read through each kind's ONE
//  rule (`Queries.mcpBookReaches` — `decide` / `decideGathering`), for the readings
//  DRAWN only (`BookPanelBrain.markedReadings`), nothing read while no client is
//  approved; a note- or book-level share never icons a gathering (R-VX185-1).
//  Red-on-old is by construction: the old panel held no reading reach and drew no mark
//  beside the header or a gathering's name (and the hold, `holdReadingReach`, is new).
//  The sweep above stays as it was: it never starts the reading hold, so its count is
//  the note rows' alone.
extension BookPanelMCPMarksTests {
    /// The pure decision: the shown book always; the gatherings only while
    /// their line is open; drawing order, each once.
    @Test func thePanelHoldsTheReachOfExactlyTheReadingsItNames() {
        #expect(BookPanelBrain.markedReadings(shown: "b", gatherings: ["g1", "g2"], gatheringsOpen: false) == ["b"],
                "a closed gatherings line draws no names, so holds none")
        #expect(BookPanelBrain.markedReadings(shown: "b", gatherings: ["g1", "g2"], gatheringsOpen: true)
                == ["b", "g1", "g2"])
        #expect(BookPanelBrain.markedReadings(shown: nil, gatherings: ["g1"], gatheringsOpen: true) == ["g1"],
                "a note in no book: its gatherings only")
        #expect(BookPanelBrain.markedReadings(shown: nil, gatherings: [], gatheringsOpen: true) == [])
        #expect(BookPanelBrain.markedReadings(shown: "b", gatherings: ["b", "g1"], gatheringsOpen: true) == ["b", "g1"],
                "each once")
    }

    /// The shown book's name wears the shared icon (a BOOK grant reaches it)
    /// and a waiting ask on the book — the Bookcase's order, on the header's
    /// own row above the table of contents; her press on the glyph answers
    /// THAT ask, her press on the icon presents its popover, and no open
    /// fires for either.
    @Test func theShownBooksNameWearsItsIconAndItsWaitingAskAndEachPressIsItsOwn() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "vx354-header")
            let open = try note(ops, "the open note")
            let book = try ops.createReading(name: "the shared book", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)
            _ = try ops.grantMCPAccess(client.id, grant(.read, .book, book.id))

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            var tasks = try await holdThePanel(
                session, open: open, book: book, model: model, membership: membership, notes: 1)
            tasks.append(Task {
                await model.holdReadingReach(BookPanelBrain.markedReadings(
                    shown: book.id, gatherings: [], gatheringsOpen: false))
            })
            defer { tasks.forEach { $0.cancel() } }
            #expect(try await settle { model.readingReach[book.id] != nil && model.reach[open.id] != nil },
                    "the book's reach and its note's landed")
            #expect(model.readingReach[book.id]?.map(\.clientName) == ["vx354-header"])

            let answered = AnsweredAsks()
            let (opens, observer) = countOpens()
            defer { NotificationCenter.default.removeObserver(observer) }
            let bookAsk = MCPAskFace(
                id: "ask-vx354-book", target: .book(book.id), clientName: "vx354-header",
                here: "vx354-header asks to suggest here", named: "vx354-header asks to suggest in a book")
            let rig = SharedIconRig(
                BookPanelView(session: session, postID: open.id, membership: membership, model: model)
                    .environment(\.mcpAskBoard, MCPAskBoard(faces: [bookAsk]))
                    .environment(\.mcpShareRoad, road(answered)),
                width: 340, height: 600)
            defer { rig.close() }

            let drawn = await rig.poll(timeout: 8) {
                MCPSharedIconProbe.frames(in: rig.window).count == 2
                    && MCPAskGlyphProbe.frames(in: rig.window).count == 1
            }
            await rig.poll(timeout: 0.6) { false }
            #expect(drawn, "two icons (the header's, the note row's) and the book's one waiting ask (icons \(MCPSharedIconProbe.frames(in: rig.window).count), asks \(MCPAskGlyphProbe.frames(in: rig.window).count))")
            let icons = MCPSharedIconProbe.frames(in: rig.window).sorted { $0.midY > $1.midY }
            let header = try #require(icons.first, "the header's icon drew")
            let glyph = try #require(MCPAskGlyphProbe.frames(in: rig.window).first, "the book's ask drew")
            #expect(icons.count == 2 && header.midY > icons[1].midY + 4,
                    "the header's icon sits above the table of contents (\(icons))")
            #expect(abs(glyph.midY - header.midY) <= 6, "the icon and the waiting ask share the header's row")
            #expect(header.maxX <= glyph.minX + 1, "the icon comes first, then the ask — the Bookcase's order")

            await rig.click(at: NSPoint(x: glyph.midX, y: glyph.midY))
            #expect(await rig.poll(timeout: 3) { answered.ids == ["ask-vx354-book"] },
                    "her press on the header's glyph answers the BOOK's ask (\(answered.ids))")
            let before = MCPSharedIconProbe.presentations(of: "vx354-header")
            await rig.click(at: NSPoint(x: header.midX, y: header.midY))
            #expect(await rig.poll(timeout: 3) { MCPSharedIconProbe.presentations(of: "vx354-header") > before },
                    "her press on the header's icon presents its popover")
            await rig.poll(timeout: 0.4) { false }
            #expect(opens.value == 0, "no open fired for either mark")
        }
    }

    /// A gathering's name, once the line is open, wears the shared icon ONLY
    /// through wing-level reach (R-VX185-1): under a book grant and a note
    /// grant it wears none — while the header and the note row do — and a
    /// wing grant made while the panel stands lights it, on the held read.
    @Test func aGatheringsNameWearsTheIconOnlyThroughItsWingNeverThroughANoteOrBookGrant() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "vx354-gathering")
            let open = try note(ops, "the open note")
            let book = try ops.createReading(name: "the book", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)
            let tea = try ops.createTag(name: "tea")
            _ = try ops.applyTag(tea.id, toPost: open.id)
            let gathering = try ops.createReading(
                name: "everything tea", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tea.id)))
            _ = try ops.grantMCPAccess(client.id, grant(.read, .book, book.id))
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, open.id))

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            // The panel's held reads by hand (`holdThePanel`'s three, settled on
            // TWO readings — the book and the gathering).
            var tasks: [Task<Void, Never>] = [
                Task { await membership.track(session: session, postID: open.id) },
                Task { await model.observe(bookID: book.id) },
            ]
            #expect(try await settle {
                model.entryIDs(for: book.id).count == 1 && membership.readings(for: open.id).count == 2
            }, "the panel's book and its one entry landed, and the note's two readings")
            tasks.append(Task { await model.holdReach(model.entryIDs(for: book.id)) })
            #expect(membership.gatherings(for: open.id).map(\.id) == [gathering.id],
                    "the note shows in the gathering (the fixture)")
            let named = BookPanelBrain.markedReadings(
                shown: book.id, gatherings: membership.gatherings(for: open.id).map(\.id), gatheringsOpen: true)
            #expect(named == [book.id, gathering.id])
            tasks.append(Task { await model.holdReadingReach(named) })
            defer { tasks.forEach { $0.cancel() } }
            #expect(try await settle { model.readingReach[book.id] != nil }, "the book's reach landed")
            #expect(model.readingReach[gathering.id] == nil,
                    "a book grant and a note grant never reach a gathering (R-VX185-1)")

            let rig = SharedIconRig(
                BookPanelView(
                    session: session, postID: open.id, membership: membership, model: model,
                    gatheringsOpen: true)
                    .environment(\.mcpAskBoard, MCPAskBoard())
                    .environment(\.mcpShareRoad, road(AnsweredAsks())),
                width: 340, height: 600)
            defer { rig.close() }
            let two = await rig.poll(timeout: 8) { MCPSharedIconProbe.frames(in: rig.window).count == 2 }
            await rig.poll(timeout: 0.6) { false }
            #expect(two && MCPSharedIconProbe.frames(in: rig.window).count == 2,
                    "the header and the note row — never the gathering (\(MCPSharedIconProbe.frames(in: rig.window).count) drawn)")

            // A wing grant on its wing: the gathering's name lights, on the held read.
            _ = try ops.grantMCPAccess(client.id, grant(.read, .wing, ""))
            #expect(try await settle { model.readingReach[gathering.id] != nil }, "the wing grant reaches the gathering")
            let three = await rig.poll(timeout: 8) { MCPSharedIconProbe.frames(in: rig.window).count == 3 }
            #expect(three, "the header, the note row, and now the gathering's name (\(MCPSharedIconProbe.frames(in: rig.window).count) drawn)")
            let lowest = try #require(MCPSharedIconProbe.frames(in: rig.window).min { $0.midY < $1.midY })
            let others = MCPSharedIconProbe.frames(in: rig.window).filter { $0 != lowest }
            #expect(others.allSatisfy { $0.midY > lowest.midY + 4 },
                    "the new icon is the gathering's — below the table of contents, on the gatherings line")
            #expect(MCPAskGlyphProbe.frames(in: rig.window).isEmpty, "no ask waits; none is drawn")
        }
    }

    /// VX-272's gate at the panel: with no approved client the reading hold
    /// reads nothing — even with the open book on — and no mark is drawn.
    @Test func nothingIsReadOrDrawnWhileNoClientIsApproved() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            _ = try ops.recordMCPContact(name: "vx354-pending", version: "2")
            try ops.setMCPSwitch(.openBook, on: true)
            let open = try note(ops, "the open note")
            let book = try ops.createReading(name: "the book", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)

            let membership = NoteMembershipModel()
            let model = BookPanelModel(session: session, postID: open.id)
            var tasks = try await holdThePanel(
                session, open: open, book: book, model: model, membership: membership, notes: 1)
            tasks.append(Task { await model.holdReadingReach([book.id]) })
            defer { tasks.forEach { $0.cancel() } }
            try await Task.sleep(for: .milliseconds(500))  // every held read has landed by now
            #expect(model.readingReach.isEmpty, "no approved client: the read stops at the grants store")
            #expect(model.reach.isEmpty)

            let rig = SharedIconRig(
                BookPanelView(session: session, postID: open.id, membership: membership, model: model)
                    .environment(\.mcpAskBoard, MCPAskBoard())
                    .environment(\.mcpShareRoad, road(AnsweredAsks())),
                width: 340, height: 600)
            defer { rig.close() }
            await rig.poll(timeout: 1) { false }
            #expect(MCPSharedIconProbe.frames(in: rig.window).isEmpty, "no mark anywhere")
        }
    }
}
