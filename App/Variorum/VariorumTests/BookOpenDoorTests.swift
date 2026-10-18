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
//  and useful than the note's last used mode."*
//
//  The five doors — Outline's expanded header "open ↗", the collapsed card's
//  body and its "open ↗", Index's "Open in the full editor", the spread page's
//  "open ↗" — all call `BookView.openInWrite`, published in DEBUG as
//  `BookOutlineGeometry.openDoors` (the focus door's pattern: a button's
//  closure is unreachable from a pin). What these hold:
//
//  · **THE RULE** (pure) — `BookOpenDoor.place` per mode, the landing's
//    clamped offset (`PostDetailView.landingOffset`), and the router's offset
//    parked, expired and spent WITH its landing.
//  · **THE DOOR, PER MODE** — through a mounted book with the road captured:
//    the live note's door carries (block, offset); any other note's door
//    (the collapsed card's case) carries nothing — today's plain open.
//  · **THE WHOLE ROAD** — through the real shell: the note opens in WRITE
//    (never its remembered mode — the fixture leaves it in Lenses, her
//    screenshot's mode) with the caret exactly where she was in the book.
//
//  RED ON OLD — by reverting the U1a piece-2 commit alone (piece 1 keeps every
//  seam called here): the door posted `.variorumOpenPost` with the note's id,
//  so nothing rode the road (the per-mode pins capture nothing) and the shell
//  opened a plain note — Lenses, at the start (the whole-road pin finds no
//  Write caret at her place). The record has the measured numbers.
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
                    "\(mode): another note's door (a collapsed card's) opens plainly")
            #expect(BookOpenDoor.place(
                        of: "X", mode: mode,
                        live: .init(editorPostID: "X", editorCaret: nil)) == nil,
                    "\(mode): a live note with no caret block (the open tail) opens plainly")
            #expect(BookOpenDoor.place(
                        of: "X", mode: mode,
                        live: .init(editorPostID: nil,
                                    editorCaret: Place(blockID: "b2", offsetInBlock: 7))) == nil,
                    "\(mode): nothing live in the book (an unfocused pane) opens plainly")
        }
    }

    @Test func indexCarriesTheLivePanesBlockAndTheCaretItReportedFromIt() {
        let live = BookOpenDoor.Live(
            indexPostID: "X", indexBlockID: "b2",
            indexCaret: Place(blockID: "b2", offsetInBlock: 5))
        #expect(BookOpenDoor.place(of: "X", mode: .index, live: live)
                == Place(blockID: "b2", offsetInBlock: 5))
        #expect(BookOpenDoor.place(of: "Y", mode: .index, live: live) == nil,
                "a row naming another note opens it plainly")
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

/// One captured ride of the road — what `RootView` would have been handed.
private struct Ride: Equatable, Sendable {
    let postID: String
    let blockID: String?
    let offsetInBlock: Int?
}

// MARK: - The door, per mode (a mounted book, the road captured)

@Suite("VX-303 — a book's open door carries her place, in every editing mode", .serialized)
@MainActor
struct BookOpenDoorMountTests {
    enum Mode: String, CaseIterable, Sendable {
        case outline, spread, index
    }

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

    /// **THE PIN, per mode.** Her caret stands in the live note's SECOND block,
    /// a few characters in; the door for that note carries exactly that block
    /// and offset onto the road. The door for any OTHER note — the collapsed
    /// card's case: its note is never the live one — carries nothing, which
    /// the shell reads as today's plain open.
    ///
    /// RED ON OLD (piece 2 reverted): the door posted `.variorumOpenPost` and
    /// never touched the road — nothing is captured.
    @Test(arguments: Mode.allCases)
    func theLiveNotesDoorCarriesHerBlockAndCaret(_ mode: Mode) async throws {
        try await withOpenDoorBook { session, db, book in
            let x = book.postIDs[0]
            let y = book.postIDs[1]
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: book.readingID)
            let rides = LockIsolated<[Ride]>([])
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
                onOpenSearchHit: { postID, blockID, offset, _ in
                    rides.withValue { $0.append(Ride(postID: postID, blockID: blockID, offsetInBlock: offset)) }
                })
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
                pane.setSelectedRange(NSRange(location: inside, length: 0))
                await settle(window, hosting, until: {
                    model.indexLiveBlockID == second
                        && model.indexCaret?.place == BookOpenDoor.Place(
                            blockID: second, offsetInBlock: inside)
                })
                #expect(model.indexLiveBlockID == second, "index: the premise — block 2 is live")
            }

#if DEBUG
            let door = try #require(
                BookOutlineGeometry.openDoors[book.readingID], "the book published its open door")

            // THE LIVE NOTE'S DOOR: her block and her caret ride the road.
            door(x)
            await settle(window, hosting, until: { !rides.value.isEmpty })
            #expect(rides.value.last == Ride(postID: x, blockID: second, offsetInBlock: inside),
                    "RED ON OLD — \(mode): the door rides the shell's landing road with her block and caret; rode: \(rides.value)")

            // ANOTHER NOTE'S DOOR (the collapsed card's case): a plain open, on
            // the same road.
            let before = rides.value.count
            door(y)
            await settle(window, hosting, until: { rides.value.count > before })
            #expect(rides.value.last == Ride(postID: y, blockID: nil, offsetInBlock: nil),
                    "\(mode): a note she is not in opens plainly; rode: \(rides.value)")
#endif
        }
    }
}

// MARK: - The whole road (the real shell)

@Suite("VX-303 — a book's open door lands in Write at her caret, through the shell", .serialized)
@MainActor
struct BookOpenDoorShellTests {
    /// **THE TICKET'S PIN, end to end.** A book open in the real shell, a note
    /// live in Outline with her caret in its second block; the note is left in
    /// LENSES (her screenshot's mode). Its open door lands in WRITE — her
    /// ruling, never the remembered mode — with the caret exactly where she
    /// was: the block's start plus her offset.
    ///
    /// RED ON OLD (piece 2 reverted): the broadcast's plain open showed the
    /// note in Lenses at its start — no Write caret at her place.
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

            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 860),
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
#endif
        }
    }
}
