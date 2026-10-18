//
//  BookOpenDoorTests.swift
//  VariorumTests
//
//  VX-303 — **every book open door lands in Write, at her block.**
//
//  Her report: *"when you click open in editor it brings you to the top of the
//  option"*; her correction: the door *"doesn't carry your block so it doesn't
//  follow the existing deep-link canon rule, it just doesn't work."* Her
//  ruling (2026-10-13): *"it can land in Write at the block - more consistent
//  and useful than the note's last used mode."* The orchestrator's rulings on
//  U1a (the plan file): R-U1a-1 — the book's caret feeds the note's ONE
//  per-note memory, so "edit here" lands where she was in the book (two
//  guards); R-U1a-2 — every door lands in WRITE, nothing-live included.
//
//  The five doors — Outline's expanded header "open ↗", the collapsed card's
//  body and its "open ↗", Index's "Open in the full editor", the spread page's
//  "open ↗" — all call `BookView.openInWrite`, published in DEBUG as
//  `BookOutlineGeometry.openDoors` (the focus door's pattern: a button's
//  closure is unreachable from a pin). What these hold:
//
//  · **THE RULE** (pure) — `BookOpenDoor.place` per mode, the landing's
//    clamped offset, the offset and the MODE riding the router's one park.
//  · **THE MEMORY** — another note's report feeds that note's memory and
//    leaves the mounted detail's observed fact alone (guard (ii)); a
//    surface's own caret placement never becomes her place (guard (i)), in
//    the editor's bracket and in the Index pane's going-live.
//  · **THE DOOR, PER MODE** — through a mounted book with the road captured:
//    the live note's door carries (block, offset) and Write; any other note's
//    door (the collapsed card's case) carries no block and Write.
//  · **THE WHOLE ROAD** — through the real shell: Write at her caret, and the
//    nothing-live door in Write too — never the remembered Lenses.
//  · **THE RIDER** — "edit here" lands where she was in the book.
//
//  RED ON OLD — the record's red-on-old plan names the revert per family:
//  the doors' road (piece 2's `openInWrite` body back to the broadcast), the
//  forced mode (its own commit), the memory (its own commit).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, pure

@Suite("VX-303 — the book's open door: the rule")
@MainActor
struct BookOpenDoorRuleTests {
    private typealias Place = BookOpenDoor.Place

    @Test func outlineAndTheSpreadCarryTheLiveEditorsCaretForItsNoteOnly() {
        let live = BookOpenDoor.Live(
            editorPostID: "X", editorCaret: Place(blockID: "b2", offsetInBlock: 7))
        for mode in [BookStructureModel.ViewMode.outline, .spread] {
            #expect(BookOpenDoor.place(of: "X", mode: mode, live: live)
                    == Place(blockID: "b2", offsetInBlock: 7),
                    "\(mode): the live note's door carries her caret")
            #expect(BookOpenDoor.place(of: "Y", mode: mode, live: live) == nil,
                    "\(mode): another note's door (a collapsed card's) carries no place")
            #expect(BookOpenDoor.place(
                        of: "X", mode: mode,
                        live: .init(editorPostID: "X", editorCaret: nil)) == nil,
                    "\(mode): a live note with no caret block (the open tail) carries no place")
            #expect(BookOpenDoor.place(
                        of: "X", mode: mode,
                        live: .init(editorPostID: nil,
                                    editorCaret: Place(blockID: "b2", offsetInBlock: 7))) == nil,
                    "\(mode): nothing live in the book (an unfocused pane) carries no place")
        }
    }

    @Test func indexCarriesTheLivePanesBlockAndTheCaretItReportedFromIt() {
        let live = BookOpenDoor.Live(
            indexPostID: "X", indexBlockID: "b2",
            indexCaret: Place(blockID: "b2", offsetInBlock: 5))
        #expect(BookOpenDoor.place(of: "X", mode: .index, live: live)
                == Place(blockID: "b2", offsetInBlock: 5))
        #expect(BookOpenDoor.place(of: "Y", mode: .index, live: live) == nil,
                "a row naming another note carries no place")
        var stale = live
        stale.indexCaret = Place(blockID: "b1", offsetInBlock: 40)
        #expect(BookOpenDoor.place(of: "X", mode: .index, live: stale)
                == Place(blockID: "b2", offsetInBlock: nil),
                "an offset reported from ANOTHER block is not an offset in this one — the block's start")
        #expect(BookOpenDoor.place(
                    of: "X", mode: .index, live: .init(indexPostID: "X", indexBlockID: nil)) == nil)
        #expect(BookOpenDoor.place(
                    of: "X", mode: .index,
                    live: .init(editorPostID: "X",
                                editorCaret: Place(blockID: "b9", offsetInBlock: 1))) == nil,
                "Index reads its own pane, never the Outline editor's caret")
    }

    @Test func readCarriesNothing() {
        let live = BookOpenDoor.Live(
            editorPostID: "X", editorCaret: Place(blockID: "b2", offsetInBlock: 7),
            indexPostID: "X", indexBlockID: "b2")
        #expect(BookOpenDoor.place(of: "X", mode: .read, live: live) == nil)
    }

    /// The landing's offset is clamped to the block where it lands: a block
    /// that shrank since the door read her caret must never push the caret
    /// into the NEXT block; nil is the block's start, every older road's.
    @Test func theLandingOffsetIsClampedToItsBlock() {
        let block = NSRange(location: 10, length: 20)
        #expect(PostDetailView.landingOffset(blockRange: block, offsetInBlock: 7) == 17)
        #expect(PostDetailView.landingOffset(blockRange: block, offsetInBlock: nil) == 10)
        #expect(PostDetailView.landingOffset(blockRange: block, offsetInBlock: 99) == 30)
        #expect(PostDetailView.landingOffset(blockRange: block, offsetInBlock: -3) == 10)
    }

    /// The offset is part of the ONE park: parked with its landing, answered
    /// for its own container only, spent and expired with it.
    @Test func theOffsetRidesThePark() {
        let router = ShellRouter()
        router.adopt(.post("X"), landing: "b2", offset: 7)
        #expect(router.landing(for: "X") == "b2")
        #expect(router.landingOffset(for: "X") == 7)
        #expect(router.landingOffset(for: "Y") == nil, "…and no other container's")
        router.spendLanding(for: "X")
        #expect(router.landingOffset(for: "X") == nil, "spent with its landing")

        router.adopt(.post("X"), landing: "b2", offset: 7)
        router.adopt(.library)
        #expect(router.landingOffset(for: "X") == nil, "expired by the next navigation")
        router.adopt(.post("X"), landing: "b4")
        #expect(router.landingOffset(for: "X") == nil, "a landing that names no offset carries none")
        #expect(ShellRouter.BlockLanding(.post("X"), blockID: nil, offsetInBlock: 3) == nil,
                "an offset never parks without a block")
    }

    /// R-U1a-2's road: the MODE a door names rides the same park — parked by
    /// the navigation that names it (with or without a block), answered for
    /// its own note only, spent at the mount and expired by the next door;
    /// one park is one new generation, however much it names.
    @Test func theModeRidesTheSamePark() {
        let router = ShellRouter()
        router.adopt(.post("X"), mode: .write)
        #expect(router.landingMode(for: "X") == .write, "a mode parks without a block")
        #expect(router.landing(for: "X") == nil)
        #expect(router.landingMode(for: "Y") == nil, "…and answers for its own note only")
        #expect(router.landingGeneration(for: "X") == 1, "a NEW park re-creates the detail")

        router.spendLanding(for: "X")
        #expect(router.landingMode(for: "X") == nil, "spent at the mount")
        #expect(router.landingGeneration(for: "X") == 1, "…without moving the identity")

        router.adopt(.post("X"), landing: "b2", offset: 3, mode: .write)
        #expect(router.landingGeneration(for: "X") == 2, "a block AND a mode are ONE new park")
        #expect(router.landingMode(for: "X") == .write && router.landing(for: "X") == "b2")
        router.adopt(.library)
        #expect(router.landingMode(for: "X") == nil, "expired by the next navigation")
        router.adopt(.reading("R"), mode: .write)
        #expect(router.modeLanding == nil, "only a NOTE arrives in a mode")
    }
}

// MARK: - The memory — the guards (R-U1a-1)

@Suite("VX-303 — another note's caret feeds its memory, never the mounted detail's fact (R-U1a-1)")
@MainActor
struct BookPlaceMemoryTests {
    /// Ids no other suite mints: the memory PERSISTS per note in the shared
    /// defaults domain (row 36), and suites run in parallel.
    private let noteA = "vx303-memory-A"
    private let noteB = "vx303-memory-B"

    /// **Guard (ii) and the rider's mechanism, at the router.** The mounted
    /// detail is note A; a surface showing note B (the book's inline editor,
    /// its Index pane) reports B's caret. B's MEMORY takes it — what "edit
    /// here" reads through `currentBlock(for:)` — and A's observed fact (the
    /// Block History pane's jump door) and its offset do not move. A
    /// block-less report for B (a surface holding no caret) names nothing.
    ///
    /// RED ON OLD (the memory commit reverted): B's memory stays nil — the
    /// router dropped every report for a note other than the detail's.
    @Test func anotherNotesReportFeedsItsMemoryAndLeavesTheMountedDetailAlone() {
        let router = CommandRouter()
        for id in [noteA, noteB] { router.forgetCurrentBlock(for: id) }
        defer { for id in [noteA, noteB] { router.forgetCurrentBlock(for: id) } }
        let token = router.registerDetail(postID: noteA, mode: .write, applyMode: { _ in })
        defer { router.unregisterDetail(token) }
        router.noteFocusedBlock("a1", variantID: "va1", postID: noteA, utf16Offset: 4)
        let mounted = router.focusedBlock

        // A reporter that does NOT exclude its own placements (the Takes
        // board — the spread's Takes form) feeds nothing for another note.
        router.noteFocusedBlock("b8", variantID: "vb8", postID: noteB, utf16Offset: 1)
        #expect(router.currentBlock(for: noteB) == nil,
                "a reporter that cannot exclude its own placements never feeds another note's memory")

        router.noteFocusedBlock(
            "b2", variantID: "vb2", postID: noteB, utf16Offset: 7, remembersOtherNotes: true)
        #expect(router.currentBlock(for: noteB)
                == FocusedBlock(postID: noteB, blockID: "b2", variantID: "vb2", utf16Offset: 7),
                "RED ON OLD: B's caret is remembered for B — where she was in the book")
        #expect(router.focusedBlock == mounted,
                "guard (ii): the mounted detail's observed fact AND its offset are untouched")
        #expect(router.currentBlock(for: noteA)?.blockID == "a1")

        router.noteFocusedBlock(nil, variantID: nil, postID: noteB, remembersOtherNotes: true)
        #expect(router.focusedBlock == mounted, "a block-less report for B clears nothing of A's")
        #expect(router.currentBlock(for: noteB)?.blockID == "b2", "…nor B's memory")
    }

    /// **Guard (i), at the router.** A surface placing its own caret — the
    /// mount's fill and focus seeds, bracketed by `duringCaretPlacement` —
    /// never becomes another note's remembered place; the mounted detail's
    /// reports inside the same bracket keep their road exactly.
    @Test func aSurfacesOwnPlacementIsNeverHerPlaceForAnotherNote() {
        let router = CommandRouter()
        for id in [noteA, noteB] { router.forgetCurrentBlock(for: id) }
        defer { for id in [noteA, noteB] { router.forgetCurrentBlock(for: id) } }
        let token = router.registerDetail(postID: noteA, mode: .write, applyMode: { _ in })
        defer { router.unregisterDetail(token) }
        router.noteFocusedBlock(
            "b5", variantID: "vb5", postID: noteB, utf16Offset: 30, remembersOtherNotes: true)

        router.duringCaretPlacement {
            // The fill's END, then a bare focus's seed at the note's start.
            router.noteFocusedBlock(
                "b9", variantID: "vb9", postID: noteB, utf16Offset: 120, remembersOtherNotes: true)
            router.noteFocusedBlock(
                "b1", variantID: "vb1", postID: noteB, utf16Offset: 0, remembersOtherNotes: true)
            // The detail's own report inside the same bracket.
            router.noteFocusedBlock("a3", variantID: "va3", postID: noteA, utf16Offset: 2)
        }
        #expect(router.caretPlacementDepth == 0, "the bracket closed")
        #expect(router.currentBlock(for: noteB)
                == FocusedBlock(postID: noteB, blockID: "b5", variantID: "vb5", utf16Offset: 30),
                "guard (i): the mount's placements never replace where she was")
        #expect(router.focusedBlock?.blockID == "a3" && router.focusedBlock?.utf16Offset == 2,
                "the detail's own road is untouched by the bracket")

        // After the bracket, her act is hers again.
        router.noteFocusedBlock(
            "b1", variantID: "vb1", postID: noteB, utf16Offset: 6, remembersOtherNotes: true)
        #expect(router.currentBlock(for: noteB)?.blockID == "b1"
                && router.currentBlock(for: noteB)?.utf16Offset == 6)
    }

    /// **Guard (i), in the Index pane.** A pane going live places its caret
    /// itself — its `string` write's END, then the armed landing — and only
    /// what follows is hers; a CLICK's own place is hers from the start; her
    /// edit ends a placement an empty take never reported.
    @Test func theIndexPanesGoingLivePlacementIsNotHers() async throws {
        try await withOpenDoorBook { session, _, book in
            let edit = BookIndexEditModel(session: session)
            defer { edit.teardown() }
            let p = book.postIDs[0]
            let rows = try await session.database.read { try Queries.blockTOC($0, post: p) }
            let second = rows[1]
            let secondLength = (second.text ?? "").utf16.count
            // A LANDING (nothing remembered ⇒ the block's start).
            edit.requestLiveBlock(LandingTarget(postID: p, blockID: second.blockID))
            #expect(edit.takePendingLiveBlock(postID: p, rows: rows) == second.blockID)
            let v2 = try #require(second.variantID)
            #expect(!edit.caretReportIsHers(
                        variantID: v2, offset: secondLength, textLength: secondLength),
                    "the `string` write's END is nobody's")
            #expect(!edit.caretReportIsHers(variantID: v2, offset: 0, textLength: secondLength),
                    "the landing's own place is the surface's")
            #expect(edit.caretReportIsHers(variantID: v2, offset: 9, textLength: secondLength),
                    "what follows the placement is hers")

            // A CLICK: its own place is hers.
            let first = rows[0]
            let v1 = try #require(first.variantID)
            let firstLength = (first.text ?? "").utf16.count
            edit.makeLive(postID: p, blockID: first.blockID, variantID: v1, clickOffset: 4)
            #expect(!edit.caretReportIsHers(variantID: v1, offset: firstLength, textLength: firstLength))
            #expect(edit.caretReportIsHers(variantID: v1, offset: 4, textLength: firstLength),
                    "a click's place is hers")
            #expect(edit.caretReportIsHers(variantID: v1, offset: 7, textLength: firstLength))

            // An EMPTY take's placement may report nothing: her edit ends it.
            let q = book.postIDs[2]
            let empty = try session.operations.newBlock(in: q, text: "", at: .end)
            let qRows = try await session.database.read { try Queries.blockTOC($0, post: q) }
            edit.requestLiveBlock(LandingTarget(postID: q, blockID: empty.block.id))
            #expect(edit.takePendingLiveBlock(postID: q, rows: qRows) == empty.block.id)
            edit.paneEdited(postID: q, variantID: empty.variant.id, oldText: "", newText: "h")
            #expect(edit.caretReportIsHers(variantID: empty.variant.id, offset: 1, textLength: 1),
                    "her edit ended the placement")
        }
    }
}

// MARK: - The fixture

private let prose = [
    "The first paragraph of this note, long enough to read like real writing.",
    "The second paragraph — the one her caret is standing in, somewhere in the middle.",
    "The third paragraph closes the note with a sentence or two of its own.",
]

private struct OpenDoorBook {
    let readingID: String
    let postIDs: [String]
    /// Per note: its blocks' ids, in order.
    let blocks: [String: [String]]
    /// Per note: its blocks' variant ids, in order.
    let variants: [String: [String]]
}

@MainActor
private func withOpenDoorBook<T>(
    _ body: @MainActor (AppSession, AppDatabase, OpenDoorBook) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // LIVE uuids: the oracle keys (the book's open door, its focus door)
        // are these ids, and suites run in parallel (the 18d ladder's MINOR-3).
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 303))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the open doors", kind: .book)
        var postIDs: [String] = []
        var blocks: [String: [String]] = [:]
        var variants: [String: [String]] = [:]
        for p in 0..<3 {
            let post = try session.operations.createPost(title: "note \(p)")
            for text in prose {
                let minted = try session.operations.newBlock(in: post.id, text: text, at: .end)
                blocks[post.id, default: []].append(minted.block.id)
                variants[post.id, default: []].append(minted.variant.id)
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        defer {
            for id in postIDs {
                session.commandRouter.forgetCurrentBlock(for: id)
                UserDefaults.standard.removeObject(forKey: "postMode.\(id)")
            }
        }
        // Row-36 hygiene: the current-block memory PERSISTS per note.
        for id in postIDs { session.commandRouter.forgetCurrentBlock(for: id) }
        return try await body(session, db, OpenDoorBook(
            readingID: reading.id, postIDs: postIDs, blocks: blocks, variants: variants))
    }
}

/// The document range of a note's `i`th block, as Write's `jump` reads it.
@MainActor
private func blockRange(_ db: AppDatabase, postID: String, block i: Int) async throws -> NSRange {
    let slots = try await db.read { try Queries.renderPost($0, containerID: postID) }
    return BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i)
}

@MainActor
private func pump(_ seconds: TimeInterval = 0.02) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 120
) async {
    for _ in 0..<maxTurns {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
        if predicate() { return }
    }
}

@MainActor
private func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
    var found: [V] = []
    if let v = view as? V { found.append(v) }
    for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
    return found
}

@MainActor
private func loadedBook(
    session: AppSession, db: AppDatabase, readingID: String
) async throws -> (BookViewModel, BookStructureModel) {
    let model = BookViewModel(session: session, readingID: readingID)
    await model.adopt(try await db.read { [readingID] in
        try Queries.assembleReading($0, readingID: readingID)
    })
    let structure = BookStructureModel(session: session, readingID: readingID)
    structure.adopt(.init(
        reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
        sections: [], deletedSections: [], assignments: [:]))
    return (model, structure)
}

// MARK: - The door, per mode (a mounted book, the road captured)

@Suite("VX-303 — a book's open door carries her place and Write, in every editing mode", .serialized)
@MainActor
struct BookOpenDoorMountTests {
    enum Mode: String, CaseIterable, Sendable {
        case outline, spread, index
    }

    /// **THE PIN, per mode.** Her caret stands in the live note's SECOND
    /// block, a few characters in; the door for that note carries exactly
    /// that block and offset onto the road, and WRITE. The door for any OTHER
    /// note — the collapsed card's case: its note is never the live one —
    /// carries no block, and Write all the same (R-U1a-2).
    ///
    /// Guard (i) rides along: the mount's own caret placement (the editor's
    /// focus seed, the Index pane's landing) leaves the note's memory as it
    /// was; in Index, her own move inside the live pane feeds it.
    ///
    /// RED ON OLD: piece 2 reverted — nothing rides the road; the mode
    /// commit reverted — the rides carry no mode; the memory commit reverted
    /// — the Index arm's memory stays nil.
    @Test(arguments: Mode.allCases)
    func theLiveNotesDoorCarriesHerBlockAndCaret(_ mode: Mode) async throws {
        try await withOpenDoorBook { session, db, book in
            let x = book.postIDs[0]
            let y = book.postIDs[1]
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: book.readingID)
            let rides = LockIsolated<[BookOpenDoor.Landing]>([])
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
#if DEBUG
                BookOutlineGeometry.forgetOpenDoor(book.readingID)
                BookOutlineGeometry.forgetFocusDoor(book.readingID)
#endif
            }
            switch mode {
            case .outline: structure.mode = .outline
            case .spread: structure.mode = .spread
            case .index: structure.mode = .index
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: book.readingID,
                model: model, structure: structure,
                onOpenSearchHit: { landing in rides.withValue { $0.append(landing) } })
                .environment(ThemeStore(session: session)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !model.entries.isEmpty }, maxTurns: 40)

            let second = book.blocks[x]![1]
            let range = try await blockRange(db, postID: x, block: 1)
            let inside = 7

            // HER PLACE: the caret in the second block, `inside` characters in.
            switch mode {
            case .outline, .spread:
                // The book's ONE editor, focused with the caret where she is.
                model.focus(x, caret: range.location + inside)
                await settle(window, hosting, until: {
                    let editor = session.editorRouter.editing
                    return editor?.postID == x
                        && editor?.caretIdentity()?.blockID == second
                        && editor?.caretIdentity()?.offset == inside
                })
                let caret = session.editorRouter.editing?.caretIdentity()
                #expect(caret?.blockID == second && caret?.offset == inside,
                        "\(mode): the premise — the editor's caret is in block 2 at \(inside): \(String(describing: caret))")
                #expect(session.commandRouter.currentBlock(for: x) == nil,
                        "\(mode) — guard (i): the mount's own placement (the focus seed) is not remembered as her place")
            case .index:
                // The Index's one live pane on that block, then her click inside it.
                model.requestLanding(LandingTarget(postID: x, blockID: second))
                let identifier = "pane:\(BookIndexEditModel.columnID)|\(book.variants[x]![1])"
                await settle(window, hosting, until: {
                    views(PaneTextView.self, in: hosting)
                        .contains { $0.isEditable && $0.identifier?.rawValue == identifier }
                })
                let pane = try #require(
                    views(PaneTextView.self, in: hosting)
                        .first { $0.isEditable && $0.identifier?.rawValue == identifier },
                    "index: the landed block went live")
                await settle(window, hosting, until: { false }, maxTurns: 4)
                #expect(session.commandRouter.currentBlock(for: x) == nil,
                        "index — guard (i): the landing's own placement is not remembered as her place")
                pane.setSelectedRange(NSRange(location: inside, length: 0))
                await settle(window, hosting, until: {
                    model.indexLiveBlockID == second
                        && model.indexCaret?.place == BookOpenDoor.Place(
                            blockID: second, offsetInBlock: inside)
                })
                #expect(model.indexLiveBlockID == second, "index: the premise — block 2 is live")
                #expect(session.commandRouter.currentBlock(for: x)?.blockID == second
                        && session.commandRouter.currentBlock(for: x)?.utf16Offset == inside,
                        "RED ON OLD — index: her move in the live pane is the note's remembered place")
            }

#if DEBUG
            let door = try #require(
                BookOutlineGeometry.openDoors[book.readingID], "the book published its open door")

            // THE LIVE NOTE'S DOOR: her block, her caret, and Write.
            door(x)
            await settle(window, hosting, until: { !rides.value.isEmpty })
            #expect(rides.value.last == BookOpenDoor.Landing(
                        postID: x, blockID: second, offsetInBlock: inside, mode: .write),
                    "RED ON OLD — \(mode): the door rides the shell's landing road with her block, her caret and Write; rode: \(rides.value)")

            // ANOTHER NOTE'S DOOR (the collapsed card's case): no block — the
            // plain open's place — and Write all the same (R-U1a-2).
            let before = rides.value.count
            door(y)
            await settle(window, hosting, until: { rides.value.count > before })
            #expect(rides.value.last == BookOpenDoor.Landing(postID: y, mode: .write),
                    "RED ON OLD — \(mode): a note she is not in opens with no block, in Write; rode: \(rides.value)")
#endif
        }
    }
}

// MARK: - The whole road (the real shell)

@Suite("VX-303 — a book's open door lands in Write, through the shell", .serialized)
@MainActor
struct BookOpenDoorShellTests {
    /// Mount the real shell on the book and wait for its two published doors.
    private func shellOnBook(
        _ session: AppSession, _ book: OpenDoorBook
    ) async throws -> (ShellRouter, NSWindow, NSView) {
        let router = ShellRouter()
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1200, height: 860),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: RootView(session: session, services: nil, router: router))
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        router.pendingSelection = .reading(book.readingID)
#if DEBUG
        await settle(window, hosting, until: {
            BookOutlineGeometry.focusDoors[book.readingID] != nil
                && BookOutlineGeometry.openDoors[book.readingID] != nil
        }, maxTurns: 160)
#endif
        return (router, window, hosting)
    }

    /// **THE TICKET'S PIN, end to end.** A book open in the real shell, a note
    /// live in Outline with her caret in its second block; the note is left in
    /// LENSES (her screenshot's mode). Its open door lands in WRITE — her
    /// ruling, never the remembered mode — with the caret exactly where she
    /// was: the block's start plus her offset. The note's mode memory says
    /// Write afterwards: she is in Write.
    ///
    /// RED ON OLD (piece 2's door body back to the broadcast): the plain open
    /// showed the note in Lenses at its start — no Write caret at her place.
    @Test func theDoorLandsInWriteAtHerCaretNotTheNotesStartInItsRememberedMode() async throws {
        try await withOpenDoorBook { session, db, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let range = try await blockRange(db, postID: x, block: 1)
            let documentLength = BlockRangeIndex(
                slots: try await db.read { try Queries.renderPost($0, containerID: x) },
                tail: nil).documentLength
            let inside = 9
            // Her screenshot's mode: the note was last left in Lenses.
            UserDefaults.standard.set(PostMode.lenses.rawValue, forKey: "postMode.\(x)")

            let (router, window, hosting) = try await shellOnBook(session, book)
            defer {
                window.orderOut(nil)
                window.close()
#if DEBUG
                BookOutlineGeometry.forgetOpenDoor(book.readingID)
                BookOutlineGeometry.forgetFocusDoor(book.readingID)
#endif
            }
#if DEBUG
            let focus = try #require(
                BookOutlineGeometry.focusDoors[book.readingID], "the book published its focus door")
            let door = try #require(
                BookOutlineGeometry.openDoors[book.readingID], "the book published its open door")

            // The note goes live in Outline; her caret moves into block 2.
            focus(x)
            await settle(window, hosting, until: {
                session.editorRouter.editing?.postID == x
                    && session.editorRouter.editing?.caretBlockID != nil
            }, maxTurns: 160)
            let editing = try #require(session.editorRouter.editing, "the note is live in Outline")
            let inlineView = try #require(editing.textView, "the book's editor has its text view")
            inlineView.setSelectedRange(NSRange(location: range.location + inside, length: 0))
            await settle(window, hosting, until: {
                editing.caretIdentity()?.blockID == second
            })
            #expect(editing.caretIdentity()?.blockID == second
                    && editing.caretIdentity()?.offset == inside,
                    "the premise: her caret is in block 2 at \(inside)")

            // THE DOOR.
            door(x)
            await settle(window, hosting, until: {
                guard router.workspace.focusedSelection == .post(x),
                      session.commandRouter.activeMode == .write,
                      let view = views(EditorTextView.self, in: hosting).first,
                      (view.string as NSString).length >= documentLength
                else { return false }
                return view.selectedRange().location == range.location + inside
            }, maxTurns: 200)
            #expect(router.workspace.focusedSelection == .post(x), "the door opened the note")
            #expect(session.commandRouter.activeMode == .write,
                    "RED ON OLD: it lands in WRITE — her ruling — not the note's remembered Lenses (\(String(describing: session.commandRouter.activeMode)))")
            let caret = views(EditorTextView.self, in: hosting).first?.selectedRange().location
            #expect(caret == range.location + inside,
                    "RED ON OLD: Write's caret is where she was in the book (\(range.location + inside)), not the note's start — caret \(String(describing: caret))")
            #expect(PostDetailView.rememberedMode(postID: x) == .write,
                    "the note's last used mode is Write now — she is in Write")
#endif
        }
    }

    /// **R-U1a-2's pin — the NOTHING-LIVE door.** A note she is not in (the
    /// collapsed card's case), left in LENSES: its door opens it in WRITE,
    /// with the plain open's place — the session's first open of the note,
    /// so its start (R-18l-1).
    ///
    /// RED ON OLD (the forced-mode commit reverted, or piece 2's door body
    /// back to the broadcast): the remembered mode decided — Lenses.
    @Test func theNothingLiveDoorOpensInWriteAtThePlainOpensPlace() async throws {
        try await withOpenDoorBook { session, db, book in
            let y = book.postIDs[1]
            UserDefaults.standard.set(PostMode.lenses.rawValue, forKey: "postMode.\(y)")
            let documentLength = BlockRangeIndex(
                slots: try await db.read { try Queries.renderPost($0, containerID: y) },
                tail: nil).documentLength

            let (router, window, hosting) = try await shellOnBook(session, book)
            defer {
                window.orderOut(nil)
                window.close()
#if DEBUG
                BookOutlineGeometry.forgetOpenDoor(book.readingID)
                BookOutlineGeometry.forgetFocusDoor(book.readingID)
#endif
            }
#if DEBUG
            let door = try #require(
                BookOutlineGeometry.openDoors[book.readingID], "the book published its open door")
            door(y)
            await settle(window, hosting, until: {
                guard router.workspace.focusedSelection == .post(y),
                      session.commandRouter.activeMode == .write,
                      let view = views(EditorTextView.self, in: hosting).first
                else { return false }
                return (view.string as NSString).length >= documentLength
            }, maxTurns: 200)
            #expect(router.workspace.focusedSelection == .post(y), "the door opened the note")
            #expect(session.commandRouter.activeMode == .write,
                    "RED ON OLD: the nothing-live door lands in WRITE, not the remembered Lenses (\(String(describing: session.commandRouter.activeMode)))")
            let caret = views(EditorTextView.self, in: hosting).first?.selectedRange().location
            #expect(caret == 0,
                    "the plain open's place: the session's first open is at the start — caret \(String(describing: caret))")
#endif
        }
    }
}

// MARK: - The rider — "edit here" lands where she was in the book

/// The last door the book handed its box (the shell's own slot, in a pin).
@MainActor
private final class DoorBox {
    var door: NoteBoxDoor?
}

@Suite("VX-303 — the note box's \"edit here\" lands where she was in the book (R-U1a-1)", .serialized)
@MainActor
struct BookEditHereRiderTests {
    /// **THE RIDER.** The note's OWN editor last left her in block 1, two
    /// characters in (its memory, as Write writes it). In the book's spread
    /// she then writes in block 3 — her caret four characters in — and
    /// clicks out, so the box shows the note SELECTED with its one door,
    /// "edit here". The door lands the book's editor where she just was:
    /// block 3, at 4.
    ///
    /// RED ON OLD (the memory commit reverted): the book's caret never reached
    /// the note's memory, so "edit here" landed in block 1 at 2 — where she
    /// last was in the note's own editor.
    @Test func editHereLandsWhereSheWasInTheBookNotInTheNotesOwnEditor() async throws {
        try await withOpenDoorBook { session, db, book in
            let x = book.postIDs[0]
            let router = session.commandRouter
            // The note's own editor's last place: block 1, at 2.
            let token = router.registerDetail(postID: x, mode: .write, applyMode: { _ in })
            router.noteFocusedBlock(
                book.blocks[x]![0], variantID: book.variants[x]![0], postID: x, utf16Offset: 2)
            router.unregisterDetail(token)
            #expect(router.currentBlock(for: x)?.blockID == book.blocks[x]![0],
                    "the premise: the note's own editor left her in block 1")

            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: book.readingID)
            structure.mode = .spread
            let doors = LockIsolated<[NoteBoxState]>([])
            let latest = DoorBox()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
#if DEBUG
                BookOutlineGeometry.forgetOpenDoor(book.readingID)
                BookOutlineGeometry.forgetFocusDoor(book.readingID)
#endif
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: book.readingID,
                model: model, structure: structure,
                onNoteBox: { _, report, door in
                    doors.withValue { $0.append(report?.state ?? .empty) }
                    if let door { latest.door = door }
                })
                .environment(ThemeStore(session: session)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !model.spreadEntries.isEmpty }, maxTurns: 40)

            // She writes in the spread: block 3, four characters in.
            let third = book.blocks[x]![2]
            let thirdRange = try await blockRange(db, postID: x, block: 2)
            model.focus(x)
            await settle(window, hosting, until: {
                session.editorRouter.editing?.postID == x
                    && session.editorRouter.editing?.caretBlockID != nil
            })
            let editing = try #require(session.editorRouter.editing, "the note is live on the spread")
            let textView = try #require(editing.textView)
            textView.setSelectedRange(NSRange(location: thirdRange.location + 4, length: 0))
            await settle(window, hosting, until: { editing.caretIdentity()?.blockID == third })
            #expect(router.currentBlock(for: x)?.blockID == third
                    && router.currentBlock(for: x)?.utf16Offset == 4,
                    "RED ON OLD: her caret in the book is the note's remembered place")

            // She clicks out: the box shows the note SELECTED, with "edit here".
            model.focus(nil)
            await settle(window, hosting, until: { doors.value.last == .selected(x) })
            #expect(doors.value.last == .selected(x), "the box points at the note, read-cheap")
            let door = try #require(latest.door, "the book handed the box its door")

            // "edit here".
            door.editHere()
            await settle(window, hosting, until: {
                guard let live = session.editorRouter.editing, live.postID == x,
                      let place = live.caretIdentity()
                else { return false }
                return place.blockID == third && place.offset == 4
            }, maxTurns: 160)
            let landed = session.editorRouter.editing?.caretIdentity()
            #expect(landed?.blockID == third && landed?.offset == 4,
                    "RED ON OLD: \"edit here\" lands where she was in the book (block 3 at 4), not in the note's own editor's last place (block 1 at 2) — landed \(String(describing: landed))")
        }
    }
}
