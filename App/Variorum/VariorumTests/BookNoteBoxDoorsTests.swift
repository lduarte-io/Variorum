//
//  BookNoteBoxDoorsTests.swift
//  VariorumTests
//
//  VX-304 — **the note box's "open ↗", and the Index's takes.**
//
//  Her addition (verbatim): *"wait but you can't see the "open ↗" next to the
//  note title very easily if it's a long note even if your carat is in the
//  right place. can you add it somewhere in this menu on the left? either as an
//  icon or as something else?"* And: *"you can make a ticket for the smallest
//  useful version of the rest of book view so index can get take badges and
//  that open in write here would be good."*
//
//  What these hold (the plan file's §U1b RECORD names each family's revert):
//  · **THE BOX DOOR, PER MODE (B)** — the box hands an "open ↗" in every book
//    mode; pressed while LIVE it rides VX-303's road with her block, her caret
//    and Write; pressed while SELECTED, the note and Write (the plain open's
//    place, R-U1a-2).
//  · **THE BOX'S FACES (B, C)** — the door drawn where the brief places it
//    (beside "edit here" while selected; by the title while live), whole inside
//    the box in both voices; the Index-live box's "Takes".
//  · **THE INDEX'S TAKES (C)** — a block with takes wears "⑂N"; the box's
//    "Takes" opens the LIVE block's takes in place, her typing landed first and
//    the live pane released; the badge's road (the request slot) the same.
//  · **THE CARRY (D)** — Outline → Index lands with her block live, at her
//    caret.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The fixture

private let prose = [
    "The first paragraph of this note, long enough to read like real writing.",
    "The second paragraph — the one with takes, where her caret stands.",
    "The third paragraph closes the note with a sentence or two of its own.",
]

private struct TakesBook {
    let readingID: String
    let postIDs: [String]
    /// Per note: its blocks' ids, in order.
    let blocks: [String: [String]]
    /// Per note: its blocks' (chosen) variant ids, in order.
    let variants: [String: [String]]
}

/// Three notes of three blocks in one book; note 0's SECOND block keeps two
/// takes (a branch — minting never chooses, so the first stays chosen).
@MainActor
private func withTakesBook<T>(
    _ body: @MainActor (AppSession, AppDatabase, TakesBook) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // LIVE uuids: every oracle key below is one of these ids, and suites
        // run in parallel (the 18d ladder's MINOR-3).
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 304))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the takes book", kind: .book)
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
        let fanned = blocks[postIDs[0]]![1]
        _ = try session.operations.branchVariant(fanned, from: variants[postIDs[0]]![1])
        defer {
            for id in postIDs {
                session.commandRouter.forgetCurrentBlock(for: id)
                NoteMemoryDefaults.store.removeObject(forKey: "postMode.\(id)")
            }
        }
        // Row-36 hygiene: the current-block memory PERSISTS per note.
        for id in postIDs { session.commandRouter.forgetCurrentBlock(for: id) }
        return try await body(session, db, TakesBook(
            readingID: reading.id, postIDs: postIDs, blocks: blocks, variants: variants))
    }
}

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

/// The Index's one live pane on `variantID`, if it is mounted and editable.
@MainActor
private func indexPane(_ variantID: String, in view: NSView) -> PaneTextView? {
    views(PaneTextView.self, in: view).first {
        $0.isEditable && $0.identifier?.rawValue == "pane:\(BookIndexEditModel.columnID)|\(variantID)"
    }
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

/// What the book handed its box, pass by pass (the shell's own slot, in a pin).
@MainActor
private final class BoxLog {
    var states: [NoteBoxState] = []
    var door: NoteBoxDoor?
}

/// A book mounted in a window, its box and its road captured.
@MainActor
private struct MountedBook {
    let window: NSWindow
    let hosting: NSView
    let model: BookViewModel
    let structure: BookStructureModel
    let box: BoxLog
    let rides: LockIsolated<[BookOpenDoor.Landing]>

    func close(_ readingID: String) {
        window.attachedSheet.map { window.endSheet($0) }
        window.orderOut(nil)
        window.close()
#if DEBUG
        BookOutlineGeometry.forgetOpenDoor(readingID)
        BookOutlineGeometry.forgetFocusDoor(readingID)
        BookOutlineGeometry.forgetModeDoor(readingID)
#endif
    }
}

@MainActor
private func mountBook(
    _ session: AppSession, _ db: AppDatabase, _ book: TakesBook,
    mode: BookStructureModel.ViewMode
) async throws -> MountedBook {
    let (model, structure) = try await loadedBook(
        session: session, db: db, readingID: book.readingID)
    structure.mode = mode
    let box = BoxLog()
    let rides = LockIsolated<[BookOpenDoor.Landing]>([])
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    let hosting = NSHostingView(rootView: BookView(
        session: session, readingID: book.readingID,
        model: model, structure: structure,
        onNoteBox: { _, report, door in
            box.states.append(report?.state ?? .empty)
            box.door = door
        },
        onOpenSearchHit: { landing in rides.withValue { $0.append(landing) } })
        .environment(ThemeStore(session: session)))
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    await settle(window, hosting, until: { !model.entries.isEmpty }, maxTurns: 40)
    return MountedBook(
        window: window, hosting: hosting, model: model, structure: structure,
        box: box, rides: rides)
}

/// Make note `x`'s second block HER place, live, in `mode`: the book's one
/// editor focused and her caret moved into block 2 at `inside` (Outline, the
/// spread); the Index's one live pane landed on block 2 and her caret moved
/// there (Index). Her MOVE, so the note's memory takes it (R-U1a-1).
@MainActor
private func makeBlockTwoLive(
    _ mounted: MountedBook, _ session: AppSession, _ db: AppDatabase, _ book: TakesBook,
    mode: BookStructureModel.ViewMode, inside: Int
) async throws {
    let x = book.postIDs[0]
    let second = book.blocks[x]![1]
    switch mode {
    case .outline, .spread:
        let range = try await blockRange(db, postID: x, block: 1)
        mounted.model.focus(x)
        await settle(mounted.window, mounted.hosting, until: {
            session.editorRouter.editing?.postID == x
                && session.editorRouter.editing?.caretBlockID != nil
        })
        let editing = try #require(session.editorRouter.editing, "\(mode): the note is live")
        let textView = try #require(editing.textView)
        textView.setSelectedRange(NSRange(location: range.location + inside, length: 0))
        await settle(mounted.window, mounted.hosting, until: {
            editing.caretIdentity()?.blockID == second && editing.caretIdentity()?.offset == inside
        })
        #expect(editing.caretIdentity()?.blockID == second
                && editing.caretIdentity()?.offset == inside,
                "\(mode): the premise — her caret is in block 2 at \(inside)")
    case .index:
        mounted.model.requestLanding(LandingTarget(postID: x, blockID: second))
        await settle(mounted.window, mounted.hosting, until: {
            indexPane(book.variants[x]![1], in: mounted.hosting) != nil
        })
        let pane = try #require(
            indexPane(book.variants[x]![1], in: mounted.hosting), "index: block 2 went live")
        await settle(mounted.window, mounted.hosting, until: { false }, maxTurns: 4)
        pane.setSelectedRange(NSRange(location: inside, length: 0))
        await settle(mounted.window, mounted.hosting, until: {
            mounted.model.indexLiveBlockID == second
                && mounted.model.indexCaret?.place
                    == BookOpenDoor.Place(blockID: second, offsetInBlock: inside)
        })
        #expect(mounted.model.indexLiveBlockID == second, "index: the premise — block 2 is live")
    case .read:
        Issue.record("Read has no live place")
    }
}

// MARK: - B — the box door, per mode

@Suite("VX-304 — the note box's open ↗ lands like the book's own open door, in every book mode", .serialized)
@MainActor
struct BookNoteBoxOpenDoorTests {
    enum Mode: String, CaseIterable, Sendable {
        case outline, spread, index

        var viewMode: BookStructureModel.ViewMode {
            switch self {
            case .outline: .outline
            case .spread: .spread
            case .index: .index
            }
        }
    }

    /// **THE PIN, per mode.** SELECTED (the spread's left page; the Index's
    /// seeded row — Outline has no selected state: its focus IS its
    /// liveness): the box's door rides with the note and Write, no block (the
    /// plain open's place — R-U1a-2). LIVE, her caret in block 2 at a few
    /// characters in: the door rides with that block, that offset and Write —
    /// exactly what the book's own "open ↗" by the title carries (VX-303).
    /// The Index-live box also hands "Takes" (the Index has no bar); Outline
    /// and the spread hand none (their bar carries it).
    ///
    /// RED ON OLD (B reverted): the box hands no open door — `openInWrite` is
    /// nil in every state. (C reverted: the Index-live box hands no Takes.)
    @Test(arguments: Mode.allCases)
    func theBoxDoorCarriesHerPlaceWhileLiveAndWriteWhileSelected(_ mode: Mode) async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let inside = 6
            let mounted = try await mountBook(session, db, book, mode: mode.viewMode)
            defer { mounted.close(book.readingID) }

            if mode != .outline {
                await settle(mounted.window, mounted.hosting, until: {
                    mounted.box.states.last == .selected(x)
                })
                #expect(mounted.box.states.last == .selected(x),
                        "\(mode): the premise — the box shows the note selected (\(mounted.box.states))")
                let door = try #require(
                    mounted.box.door?.openInWrite,
                    "RED ON OLD — \(mode): the SELECTED box hands an open ↗")
                door()
                await settle(mounted.window, mounted.hosting, until: { !mounted.rides.value.isEmpty })
                #expect(mounted.rides.value.last == BookOpenDoor.Landing(postID: x, mode: .write),
                        "\(mode): selected — the note, in Write, no block (the plain open's place); rode \(mounted.rides.value)")
                #expect(mounted.box.door?.openTakes == nil, "\(mode): a selected box hands no Takes")
            }

            try await makeBlockTwoLive(mounted, session, db, book, mode: mode.viewMode, inside: inside)
            await settle(mounted.window, mounted.hosting, until: {
                mounted.box.states.last == .live(x)
            })
            #expect(mounted.box.states.last == .live(x), "\(mode): the premise — the box is live")
            let door = try #require(
                mounted.box.door?.openInWrite, "RED ON OLD — \(mode): the LIVE box hands an open ↗")
            let before = mounted.rides.value.count
            door()
            await settle(mounted.window, mounted.hosting, until: {
                mounted.rides.value.count > before
            })
            #expect(mounted.rides.value.last == BookOpenDoor.Landing(
                        postID: x, blockID: second, offsetInBlock: inside, mode: .write),
                    "RED ON OLD — \(mode): live — her block, her caret and Write; rode \(mounted.rides.value)")
            switch mode {
            case .index:
                #expect(mounted.box.door?.openTakes != nil,
                        "RED ON OLD (C) — index: the live box hands the block's Takes (the Index has no bar)")
            case .outline, .spread:
                #expect(mounted.box.door?.openTakes == nil,
                        "\(mode): the live box's bar carries Takes — the book hands no second one")
            }
        }
    }
}

// MARK: - B, C — what the box DRAWS

/// The column the box stands in (the `NoteBoxMountTests` host's shape): the
/// sidebar at its default width, the box in the rail's slot.
@MainActor
private struct DoorBoxHost: View {
    let session: AppSession
    let library: LibraryViewModel
    let pool: PoolViewModel
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    var selection: SidebarSelection?
    var box: AnyView?

    var body: some View {
        SidebarView(
            session: session, model: library, pool: pool,
            workspace: workspace, stars: stars,
            selection: .constant(selection),
            noteBox: box)
            .frame(width: 230)
            .environment(theme)
    }
}

@Suite("VX-304 — the box draws open ↗ and the Index's Takes where the brief places them", .serialized)
@MainActor
struct SidebarNoteBoxDoorFacesTests {
    private enum Case: CaseIterable {
        /// Selected (every mode): "edit here" and "open ↗" side by side.
        case selected
        /// Live in the Index: no bar — "open ↗" by the title, and "Takes".
        case liveIndex
        /// Live where the bar carries Takes: "open ↗" by the title only.
        case liveWithoutTakes

        var state: (String) -> NoteBoxState {
            switch self {
            case .selected: { .selected($0) }
            case .liveIndex, .liveWithoutTakes: { .live($0) }
            }
        }
    }

    /// **The faces, and the door WHOLE inside the box**, in both voices at
    /// the column's default width under a title long enough to wrap — the
    /// selected row and the live title line each keep the door on screen.
    ///
    /// RED ON OLD (B reverted): no "open" face is drawn and no door frame is
    /// published; (C reverted): the Index-live box draws no "takes".
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func theBoxDrawsItsDoorsInsideItself(voice: ThemeVoice) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 34))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note")
            _ = try session.operations.newBlock(in: post.id, text: "so the rail has a note.")
            let book = try session.operations.createReading(name: "a book", kind: .book)
            let theme = ThemeStore(session: session)
            let tokens = VoiceTokens.resolve(voice: voice, dark: false)
#if DEBUG
            for kind in Case.allCases {
                SidebarGeometry.forgetBox(subject: book.id)
                let box = AnyView(SidebarNoteBox(
                    tokens: tokens,
                    subjectKey: book.id,
                    state: kind.state(post.id),
                    identity: NoteBoxIdentity(
                        postID: post.id,
                        title: "The Adventure of the Engineer's Thumb, a title long enough to wrap",
                        chapter: "chapter two", index: 5, total: 12),
                    facts: NoteBoxFacts(words: 3214, blocks: 41, fannedBlocks: 2),
                    caretLabel: nil,
                    onEditHere: {},
                    onOpenInWrite: {},
                    onOpenTakes: kind == .liveIndex ? {} : nil))
                let workspace = WorkspaceModel()
                workspace.visit(.post(post.id))
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 230, height: 900),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: DoorBoxHost(
                    session: session, library: LibraryViewModel(session: session),
                    pool: PoolViewModel(session: session), workspace: workspace,
                    stars: StarsModel(session: session), theme: theme,
                    selection: .reading(book.id), box: box))
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                await settle(window, hosting, until: {
                    SidebarGeometry.noteBoxFrames[book.id] != nil
                        && SidebarGeometry.noteBoxOpenDoorFrames[book.id] != nil
                }, maxTurns: 60)
                let faces = SidebarGeometry.noteBoxFaces[book.id] ?? [:]
                let boxFrame = SidebarGeometry.noteBoxFrames[book.id]
                let doorFrame = SidebarGeometry.noteBoxOpenDoorFrames[book.id]
                window.orderOut(nil)
                window.close()

                #expect((faces["open"] ?? 0) == 1,
                        "RED ON OLD — \(voice) · \(kind): the box draws ONE open ↗ (\(faces))")
                switch kind {
                case .selected:
                    #expect((faces["door"] ?? 0) == 1, "\(voice): \"edit here\" stays (\(faces))")
                    #expect((faces["takes"] ?? 0) == 0, "\(voice): a selected box draws no Takes")
                case .liveIndex:
                    #expect((faces["takes"] ?? 0) == 1,
                            "RED ON OLD (C) — \(voice): the Index-live box draws Takes (\(faces))")
                    #expect((faces["door"] ?? 0) == 0, "\(voice): no \"edit here\" while live")
                case .liveWithoutTakes:
                    #expect((faces["takes"] ?? 0) == 0, "\(voice): no Takes handed, none drawn")
                }
                let drawnBox = try #require(boxFrame, "\(voice) · \(kind): the box drew")
                let drawnDoor = try #require(
                    doorFrame, "RED ON OLD — \(voice) · \(kind): the open ↗ published its frame")
                #expect(drawnBox.insetBy(dx: -0.5, dy: -0.5).contains(drawnDoor),
                        "\(voice) · \(kind): the door stands WHOLE inside the box — door \(drawnDoor), box \(drawnBox)")
                #expect(drawnDoor.width >= 20 && drawnDoor.height >= 14,
                        "\(voice) · \(kind): the door is a real target, not a sliver — \(drawnDoor)")
            }
            SidebarGeometry.forgetBox(subject: book.id)
#endif
        }
    }
}

// MARK: - The ladder's R1-7 — the Index-live box's Takes CELL takes the click

@Suite("VX-382 ladder R1-7 — the box's Takes cell answers a press anywhere inside its border", .serialized)
@MainActor
struct SidebarNoteBoxTakesCellClickTests {
    /// **The probe (walk finding W-1's idiom — a real click: down, a beat,
    /// up).** The Index-live box draws "Takes" as a bordered cell the box's
    /// full width, the word centred in it (`CommitBar.boxCell`'s grammar,
    /// copied). A press on the word opens the takes — the CONTROL, which also
    /// proves the click road's coordinates; a press 4 pt inside the cell's
    /// LEFT border, far from the word, must open them too. If only the word
    /// answers, the rest of the cell is dead: W-1's class (a macOS button
    /// counts a press only inside its own bounds, and this Button's own frame
    /// is the word's).
    ///
    /// The cell's rectangle is read off the box's own published frame (the
    /// cell is the box's last row, outside its scroll, at `takesCellHeight`
    /// inside the `inset` padding) — no oracle of its own.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aPressAnywhereInTheCellOpensTheTakes(voice: ThemeVoice) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 37))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note")
            _ = try session.operations.newBlock(in: post.id, text: "so the box has a note.")
            let book = try session.operations.createReading(name: "a book", kind: .book)
            let presses = SharedIconCounter()
            let tokens = VoiceTokens.resolve(voice: voice, dark: false)
            let rig = SharedIconRig(
                SidebarNoteBox(
                    tokens: tokens,
                    subjectKey: book.id,
                    state: .live(post.id),
                    identity: NoteBoxIdentity(
                        postID: post.id, title: "a note", chapter: nil, index: 1, total: 3),
                    facts: NoteBoxFacts(words: 5, blocks: 1, fannedBlocks: 1),
                    caretLabel: nil,
                    onOpenInWrite: {},
                    onOpenTakes: { presses.count += 1 })
                    .frame(width: 230, height: 360),
                width: 230, height: 360)
            defer { rig.close() }
#if DEBUG
            defer { SidebarGeometry.forgetBox(subject: book.id) }
            // SwiftUI's `.global` runs from the WINDOW's top (title bar
            // included — W-1's measured conversion); AppKit's window points
            // from its bottom.
            @MainActor func windowPoint(_ p: CGPoint) -> NSPoint {
                NSPoint(x: p.x, y: rig.window.frame.height - p.y)
            }
            _ = await rig.poll(timeout: 8) {
                SidebarGeometry.noteBoxFrames[book.id] != nil
                    && (SidebarGeometry.noteBoxFaces[book.id]?["takes"] ?? 0) == 1
            }
            let box = try #require(SidebarGeometry.noteBoxFrames[book.id], "\(voice): the box drew")
            #expect((SidebarGeometry.noteBoxFaces[book.id]?["takes"] ?? 0) == 1,
                    "\(voice): the premise — the Index-live box draws its Takes cell")
            let inset = SidebarNoteBox.inset
            let cell = CGRect(
                x: box.minX + inset, y: box.maxY - inset - SidebarNoteBox.takesCellHeight,
                width: box.width - 2 * inset, height: SidebarNoteBox.takesCellHeight)

            // The control: the word, centred in the cell.
            await rig.click(at: windowPoint(CGPoint(x: cell.midX, y: cell.midY)))
            #expect(await rig.poll(timeout: 3) { presses.count == 1 },
                    "\(voice): the control — a press on the word opens the takes (presses \(presses.count); cell \(cell))")
            await rig.poll(timeout: 0.4) { false }
            // The edge: 4 pt inside the cell's left border, far from the word.
            await rig.click(at: windowPoint(CGPoint(x: cell.minX + 4, y: cell.midY)))
            #expect(await rig.poll(timeout: 3) { presses.count == 2 },
                    "R1-7 — \(voice): a press 4 pt inside the cell's left border opens the takes too (presses \(presses.count) — only the word answered; cell \(cell))")
#endif
        }
    }
}

// MARK: - C — the Index's takes

@Suite("VX-304 — the Index's takes: the ⑂ badge and the in-place sheet", .serialized)
@MainActor
struct BookIndexTakesTests {
    /// **The badge.** The block that keeps two takes wears "⑂2"; its
    /// neighbours wear nothing.
    ///
    /// RED ON OLD (C reverted): the Index drew no takes mark at all.
    @Test func anIndexBlockWithTakesWearsItsCount() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let (first, fanned, third) = (book.blocks[x]![0], book.blocks[x]![1], book.blocks[x]![2])
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
#if DEBUG
            await settle(mounted.window, mounted.hosting, until: {
                BookIndexGeometry.paneReadTierFrames[third] != nil
                    && BookIndexGeometry.takesBadges[fanned] != nil
            }, maxTurns: 160)
            #expect(BookIndexGeometry.paneReadTierFrames[third] != nil,
                    "the premise: note 0's blocks are realized")
            #expect(BookIndexGeometry.takesBadges[fanned] == 2,
                    "RED ON OLD: the block with two takes wears ⑂2 (\(String(describing: BookIndexGeometry.takesBadges[fanned])))")
            #expect(BookIndexGeometry.takesBadges[first] == nil && BookIndexGeometry.takesBadges[third] == nil,
                    "a block with one take wears nothing")
#endif
        }
    }

    /// **THE BOX'S "Takes", on the live block.** Block 2 live in the Index,
    /// she types a letter (pending — not yet written), then presses the box's
    /// Takes: the sheet opens IN PLACE on block 2's takes, the store already
    /// holding her letter when it appears (her typing lands first), the
    /// panel's chosen take showing it, and the Index's live pane RELEASED (a
    /// live pane cannot adopt the panel's edits — P-U1b-4). The panel's
    /// "Open Takes mode" still refuses inside a book (no detail mounted —
    /// non-regression).
    ///
    /// RED ON OLD (C reverted): the box hands no Takes door.
    @Test func theBoxsTakesOpensTheLiveBlocksTakesInPlaceHerTypingFirst() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let fanned = book.blocks[x]![1]
            let chosen = book.variants[x]![1]
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
            try await makeBlockTwoLive(mounted, session, db, book, mode: .index, inside: 4)
            await settle(mounted.window, mounted.hosting, until: { mounted.box.states.last == .live(x) })
            let pane = try #require(indexPane(chosen, in: mounted.hosting))
            pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
            pane.insertText("Q", replacementRange: pane.selectedRange())
            #expect(pane.string.hasSuffix("Q"), "the premise: she typed into the live pane")

            let takes = try #require(
                mounted.box.door?.openTakes, "RED ON OLD: the Index-live box hands Takes")
#if DEBUG
            let storedAtOpen = LockIsolated<String?>(nil)
            takes()
            await settle(mounted.window, mounted.hosting, until: {
                guard BookIndexGeometry.takesSheets[book.readingID] != nil else { return false }
                if storedAtOpen.value == nil {
                    storedAtOpen.setValue(try? db.read { db in
                        try String.fetchOne(
                            db, sql: "SELECT working_text FROM variant WHERE id = ?",
                            arguments: [chosen])
                    })
                }
                return mounted.window.attachedSheet != nil
            }, maxTurns: 200)
            #expect(BookIndexGeometry.takesSheets[book.readingID]
                    == LandingTarget(postID: x, blockID: fanned),
                    "the sheet holds the LIVE block's takes (\(String(describing: BookIndexGeometry.takesSheets[book.readingID])))")
            #expect(storedAtOpen.value?.hasSuffix("Q") == true,
                    "her typing was written before the sheet read the store — stored: \(String(describing: storedAtOpen.value))")
            let sheet = try #require(mounted.window.attachedSheet, "the sheet is up, over the book")
            let sheetView = try #require(sheet.contentView)
            await settle(sheet, sheetView, until: {
                views(PaneTextView.self, in: sheetView)
                    .contains { $0.identifier?.rawValue == "pane:panel|\(chosen)" }
            })
            let card = views(PaneTextView.self, in: sheetView)
                .first { $0.identifier?.rawValue == "pane:panel|\(chosen)" }
            #expect(card?.string.hasSuffix("Q") == true,
                    "the panel's chosen take shows her letter: \(String(describing: card?.string))")
            #expect(views(PaneTextView.self, in: sheetView).count >= 2,
                    "both of block 2's takes are in the sheet")
            #expect(indexPane(chosen, in: mounted.hosting) == nil && mounted.model.indexLiveBlockID == nil,
                    "the Index's live pane was released for the sheet (P-U1b-4)")
            #expect(!session.commandRouter.requestMode(.takes, postID: x),
                    "\"Open Takes mode\" refuses inside a book — no detail is mounted (non-regression)")
#endif
        }
    }

    /// **The badge's road**: a block that is NOT live (nothing is) asks the
    /// Index — through the one request slot the badge and the box share — and
    /// the sheet opens on THAT block's takes. A request naming no block parks
    /// nothing.
    ///
    /// RED ON OLD (C reverted): the request is never taken; no sheet.
    @Test func aRequestedBlocksTakesOpenInPlaceWithNothingLive() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let fanned = book.blocks[x]![1]
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
            mounted.model.requestIndexTakes(LandingTarget(postID: x))
            #expect(mounted.model.pendingIndexTakes == nil, "a request naming no block parks nothing")
#if DEBUG
            mounted.model.requestIndexTakes(LandingTarget(postID: x, blockID: fanned))
            await settle(mounted.window, mounted.hosting, until: {
                BookIndexGeometry.takesSheets[book.readingID] != nil
                    && mounted.window.attachedSheet != nil
            }, maxTurns: 200)
            #expect(BookIndexGeometry.takesSheets[book.readingID]
                    == LandingTarget(postID: x, blockID: fanned),
                    "RED ON OLD: the sheet holds the requested block's takes")
            #expect(mounted.model.pendingIndexTakes == nil, "the request was taken, once")
#endif
        }
    }
}

// MARK: - D — Outline → Index carries the live block

@Suite("VX-304 — the click-over from Outline to Index carries her block", .serialized)
@MainActor
struct BookCarryLiveBlockTests {
    /// The rule, pure: leaving OUTLINE with her caret live in the carried
    /// note names that block; any other note, any other arm, no caret ⇒ the
    /// note alone, exactly as before.
    @Test func leavingOutlineNamesHerBlockAndNothingElseDoes() {
        var place = BookAnchor.Place(focusedPostID: "X")
        place.livePostID = "X"
        place.liveBlockID = "b2"
        #expect(BookAnchor.landing(mode: .outline, readForm: .flow, place: place)
                == LandingTarget(postID: "X", blockID: "b2"))
        var other = place
        other.livePostID = "Y"
        #expect(BookAnchor.landing(mode: .outline, readForm: .flow, place: other)
                == LandingTarget(postID: "X"), "a caret in ANOTHER note is not this note's block")
        var noCaret = place
        noCaret.liveBlockID = nil
        #expect(BookAnchor.landing(mode: .outline, readForm: .flow, place: noCaret)
                == LandingTarget(postID: "X"), "no caret block (the open tail) ⇒ the note alone")
        var spread = place
        spread.spreadPostIDs = ["X"]
        #expect(BookAnchor.landing(mode: .spread, readForm: .flow, place: spread)
                == LandingTarget(postID: "X"), "the spread's arm carries the note alone (the brief's letter)")
        #expect(BookAnchor.landing(mode: .read, readForm: .flow, place: BookAnchor.Place()) == nil,
                "no place ⇒ nothing")
    }

    /// The model: the carry parks the block landing beside the reveal — the
    /// slot the Index consumes (`landOrSeed`, the Read click's road).
    ///
    /// RED ON OLD (D reverted): the reveal alone; no block landing.
    @Test func theCarryParksTheBlockLanding() async throws {
        try await withTakesBook { session, _, book in
            let x = book.postIDs[0]
            let model = BookViewModel(session: session, readingID: book.readingID)
            await model.adopt(book.postIDs.map {
                Queries.ReadingEntry(postID: $0, title: nil, entryDate: nil, sectionPath: nil)
            })
            model.focus(x)
            model.carryPlace(
                from: .outline, readForm: .flow, livePostID: x, liveBlockID: book.blocks[x]![1])
            #expect(model.pendingReveal == x)
            #expect(model.pendingLanding == LandingTarget(postID: x, blockID: book.blocks[x]![1]),
                    "RED ON OLD: the carry parks her block (\(String(describing: model.pendingLanding)))")
            model.consumeReveal()
            model.carryPlace(from: .outline, readForm: .flow)
            #expect(model.pendingReveal == x && model.pendingLanding == nil,
                    "no live block ⇒ the note alone, exactly as before")
        }
    }

    /// **THE PIN, mounted.** Her caret in Outline in block 2, a few
    /// characters in; the mode tabs' act switches to Index; the Index arrives
    /// with block 2 LIVE and her caret where it was (the block from the carry,
    /// the offset from the note's one memory — R-U1a-1).
    ///
    /// RED ON OLD (D reverted): the Index selects the note and no block goes
    /// live.
    @Test func outlineToIndexLandsWithHerBlockLiveAtHerCaret() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let chosen = book.variants[x]![1]
            let inside = 9
            let mounted = try await mountBook(session, db, book, mode: .outline)
            defer { mounted.close(book.readingID) }
            try await makeBlockTwoLive(mounted, session, db, book, mode: .outline, inside: inside)
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            modeDoor(.index)
            await settle(mounted.window, mounted.hosting, until: {
                indexPane(chosen, in: mounted.hosting)?.selectedRange().location == inside
            }, maxTurns: 240)
            #expect(mounted.structure.mode == .index, "the click-over arrived in Index")
            let pane = indexPane(chosen, in: mounted.hosting)
            #expect(pane != nil, "RED ON OLD: block 2 arrives LIVE in the Index")
            #expect(pane?.selectedRange().location == inside,
                    "her caret where it was in block 2 (\(inside)) — \(String(describing: pane?.selectedRange()))")
#endif
        }
    }

    /// **The ladder's R1-2, the carry's half.** Her CLICK into the Outline's
    /// read-cheap card at block 2, nine characters in (the card's focus
    /// request — `model.focus(x, caret:)`, the click road), and no caret move
    /// after; the mode tabs switch to Index: block 2 arrives live AT HER
    /// CLICK (the block rides the carry, the offset the note's one memory —
    /// R-U1a-1).
    ///
    /// RED ON THE TIP (the fix reverted): the click's seed was bracketed with
    /// the mount's own placements, so the memory never held it and the Index
    /// entered block 2 at its start.
    @Test func aClickIntoOutlineThenIndexLandsAtTheClick() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let chosen = book.variants[x]![1]
            let inside = 9
            let mounted = try await mountBook(session, db, book, mode: .outline)
            defer { mounted.close(book.readingID) }
            let range = try await blockRange(db, postID: x, block: 1)
            mounted.model.focus(x, caret: range.location + inside)
            await settle(mounted.window, mounted.hosting, until: {
                guard let editing = session.editorRouter.editing, editing.postID == x,
                      let place = editing.caretIdentity()
                else { return false }
                return place.blockID == second && place.offset == inside
            })
            let clicked = session.editorRouter.editing?.caretIdentity()
            #expect(clicked?.blockID == second && clicked?.offset == inside,
                    "the premise: the click put the caret in block 2 at \(inside) — \(String(describing: clicked))")
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            modeDoor(.index)
            await settle(mounted.window, mounted.hosting, until: {
                indexPane(chosen, in: mounted.hosting)?.selectedRange().location == inside
            }, maxTurns: 240)
            let pane = indexPane(chosen, in: mounted.hosting)
            #expect(pane != nil, "the premise: block 2 arrives LIVE in the Index (the carry)")
            #expect(pane?.selectedRange().location == inside,
                    "RED ON OLD: the Index enters block 2 at her CLICK (\(inside)), not its start — \(String(describing: pane?.selectedRange()))")
#endif
        }
    }
}

// MARK: - VX-630 — Index → Outline carries her block back

/// **VX-630 (Bug · Confirmed — VX-562's ladder r1 finding 12, seen live at its
/// walk 2 leg 8):** an Outline → Index → Outline round trip moved the caret
/// from block 2 to block 1 of the live note. The mechanism: `BookAnchor
/// .landing`'s `.index` arm carried only the NOTE (VX-304 built the Outline →
/// Index direction alone), and the departing Index's live pane was never read
/// (`switchMode` read only the full-document editor, which Index never mounts),
/// so the Outline's editor re-mounted on the bare focus's seed — the note's
/// start. The fix: the Index's live block rides the carry, and an arrival in
/// Outline focuses the note AT it (the offset from the note's one memory).
///
/// RED ON OLD (behavioural revert: the `.index` arm back among the note-only
/// arms): the pure arm, the model's focus-at-block, and both mounted roads.
@Suite("VX-630 — the click-over from Index back to Outline keeps her block", .serialized)
@MainActor
struct BookIndexCarryBlockTests {
    /// The rule, pure: leaving INDEX with its live pane in the carried note
    /// names the pane's block; a pane in another note, or none, carries the
    /// note alone — VX-304's outline arm, mirrored.
    @Test func leavingIndexNamesItsLivePanesBlock() {
        var place = BookAnchor.Place(standingPostID: "X")
        place.livePostID = "X"
        place.liveBlockID = "b2"
        #expect(BookAnchor.landing(mode: .index, readForm: .flow, place: place)
                == LandingTarget(postID: "X", blockID: "b2"),
                "RED ON OLD: the Index's live block rides the carry")
        var selected = place
        selected.indexPostID = "X"
        #expect(BookAnchor.landing(mode: .index, readForm: .flow, place: selected)
                == LandingTarget(postID: "X", blockID: "b2"), "her selection is the live note")
        var other = place
        other.livePostID = "Y"
        #expect(BookAnchor.landing(mode: .index, readForm: .flow, place: other)
                == LandingTarget(postID: "X"), "a pane in ANOTHER note is not this note's block")
        var nothingLive = place
        nothingLive.liveBlockID = nil
        #expect(BookAnchor.landing(mode: .index, readForm: .flow, place: nothingLive)
                == LandingTarget(postID: "X"), "nothing live ⇒ the note alone")
    }

    /// The model: a carry from Index INTO Outline focuses the note at the
    /// block, the offset the note's memory holds for THAT block; into any other
    /// mode it only parks the landing, and a memory naming another block lands
    /// at the block's start.
    @Test func theCarryIntoOutlineFocusesTheNoteAtHerBlock() async throws {
        try await withTakesBook { session, _, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let model = BookViewModel(session: session, readingID: book.readingID)
            await model.adopt(book.postIDs.map {
                Queries.ReadingEntry(postID: $0, title: nil, entryDate: nil, sectionPath: nil)
            })
            model.noteIndexAnchor(x)   // her selection in the Index — the carry's note
            session.commandRouter.noteFocusedBlock(
                second, variantID: book.variants[x]![1], postID: x, utf16Offset: 9,
                remembersOtherNotes: true)

            model.carryPlace(
                from: .index, to: .spread, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.pendingLanding == LandingTarget(postID: x, blockID: second),
                    "RED ON OLD: the Index's block rides the carry")
            #expect(model.focusedPostID == nil && model.caretBlockSeed == nil,
                    "into the spread: the landing only — no focus")
            model.consumeReveal()

            model.carryPlace(
                from: .index, to: .outline, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.focusedPostID == x, "RED ON OLD: arriving in Outline, the note is focused")
            #expect(model.caretBlockSeed
                    == FocusedBlock(postID: x, blockID: second, utf16Offset: 9),
                    "RED ON OLD: at her block, at the memory's offset (\(String(describing: model.caretBlockSeed)))")
            model.consumeReveal()

            session.commandRouter.noteFocusedBlock(
                book.blocks[x]![2], variantID: book.variants[x]![2], postID: x, utf16Offset: 4,
                remembersOtherNotes: true)
            model.carryPlace(
                from: .index, to: .outline, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.caretBlockSeed
                    == FocusedBlock(postID: x, blockID: second, utf16Offset: nil),
                    "a memory naming another block ⇒ the block's start")

            model.focus(x)
            #expect(model.caretBlockSeed == nil, "any other focus clears the block seed")
        }
    }

    /// **THE PIN, her road (walk 2 leg 8).** Her caret in Outline in block 2,
    /// nine characters in; the mode tabs go to Index (block 2 arrives live at
    /// 9 — VX-304) and back to Outline: the Outline's editor reopens IN block
    /// 2 at 9, never at the note's start.
    ///
    /// RED ON OLD: the caret at block 1, offset 0 (the bare focus's seed).
    @Test func outlineToIndexAndBackKeepsHerBlockAndCaret() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let chosen = book.variants[x]![1]
            let inside = 9
            let mounted = try await mountBook(session, db, book, mode: .outline)
            defer { mounted.close(book.readingID) }
            try await makeBlockTwoLive(mounted, session, db, book, mode: .outline, inside: inside)
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            modeDoor(.index)
            await settle(mounted.window, mounted.hosting, until: {
                indexPane(chosen, in: mounted.hosting)?.selectedRange().location == inside
            }, maxTurns: 240)
            #expect(indexPane(chosen, in: mounted.hosting)?.selectedRange().location == inside,
                    "the premise: block 2 arrived live in the Index at \(inside) (VX-304)")

            modeDoor(.outline)
            await settle(mounted.window, mounted.hosting, until: {
                guard let editing = session.editorRouter.editing, editing.postID == x,
                      let place = editing.caretIdentity()
                else { return false }
                return place.blockID == second && place.offset == inside
            }, maxTurns: 240)
            #expect(mounted.structure.mode == .outline, "the click-over arrived back in Outline")
            let place = session.editorRouter.editing?.caretIdentity()
            #expect(session.editorRouter.editing?.postID == x, "the note is live in the Outline")
            #expect(place?.blockID == second,
                    "RED ON OLD: the Outline reopens in block 2, not the note's start — \(String(describing: place))")
            #expect(place?.offset == inside, "…at her caret (\(inside)) — \(String(describing: place))")
#endif
        }
    }

    /// The other road in: a book working in INDEX, her caret in block 2 there
    /// (nothing focused in the Outline); the mode tabs go to Outline, which
    /// arrives with the note LIVE at her block and caret.
    ///
    /// RED ON OLD: the Outline lands the note's row and nothing is live.
    @Test func indexToOutlineArrivesWithHerBlockLive() async throws {
        try await withTakesBook { session, db, book in
            let x = book.postIDs[0]
            let second = book.blocks[x]![1]
            let inside = 9
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
            try await makeBlockTwoLive(mounted, session, db, book, mode: .index, inside: inside)
            #expect(mounted.model.focusedPostID == nil, "the premise: nothing focused in the Outline")
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            modeDoor(.outline)
            await settle(mounted.window, mounted.hosting, until: {
                guard let editing = session.editorRouter.editing, editing.postID == x,
                      let place = editing.caretIdentity()
                else { return false }
                return place.blockID == second && place.offset == inside
            }, maxTurns: 240)
            #expect(mounted.model.focusedPostID == x, "RED ON OLD: the carried note is live")
            let place = session.editorRouter.editing?.caretIdentity()
            #expect(place?.blockID == second && place?.offset == inside,
                    "RED ON OLD: at her block and caret — \(String(describing: place))")
#endif
        }
    }
}

// MARK: - VX-680 — Index → Outline lands block-precise

/// A book whose FIRST note is long — forty blocks of a few lines each — and
/// two short notes after it, so a block far down the first note sits well
/// below the Outline's fold when the note's row is at the top of the page.
@MainActor
private func withLongNoteBook<T>(
    _ body: @MainActor (AppSession, AppDatabase, TakesBook) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 680))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the long-note book", kind: .book)
        var postIDs: [String] = []
        var blocks: [String: [String]] = [:]
        var variants: [String: [String]] = [:]
        for p in 0..<3 {
            let post = try session.operations.createPost(title: "note \(p)")
            for b in 0..<(p == 0 ? 40 : 2) {
                let minted = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(b) of note \(p). We were seated at breakfast one morning, my "
                        + "wife and I, when the maid brought in a telegram. It was from Sherlock "
                        + "Holmes and ran in this way: have you a couple of days to spare?",
                    at: .end)
                blocks[post.id, default: []].append(minted.block.id)
                variants[post.id, default: []].append(minted.variant.id)
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        defer {
            for id in postIDs {
                session.commandRouter.forgetCurrentBlock(for: id)
                NoteMemoryDefaults.store.removeObject(forKey: "postMode.\(id)")
            }
        }
        for id in postIDs { session.commandRouter.forgetCurrentBlock(for: id) }
        return try await body(session, db, TakesBook(
            readingID: reading.id, postIDs: postIDs, blocks: blocks, variants: variants))
    }
}

/// **VX-680 (Improvement · Medium — P-B4-1's second option, RULED at #248):**
/// an Index → Outline click-over with a block live arrived with the note LIVE
/// at her block (VX-630) while the PAGE landed the note's row — a block far
/// down a long note sat live below the visible page. Ruled: the Outline
/// landing scrolls the carried block's row into view — minimally, never a
/// forced top. The fix: the arrival's landing homes on the block's minimal
/// reveal (`OutlineBlockLanding`) once the live editor has laid it out.
///
/// RED ON OLD (`rev680`: the park is never taken — the landing homes on the
/// row's top): the model's park lines and the mounted far-block pin.
@Suite("VX-680 — Index → Outline lands block-precise", .serialized)
@MainActor
struct BookIndexToOutlineBlockLandingTests {
    /// The park, at the model: the carry INTO Outline with a block parks it
    /// beside VX-630's focus; the Outline's landing of that note takes it
    /// ONCE; every later navigation drops it; a carry anywhere else parks
    /// nothing.
    @Test func theCarryIntoOutlineParksHerBlockForItsLanding() async throws {
        try await withTakesBook { session, _, book in
            let x = book.postIDs[0], y = book.postIDs[1]
            let second = book.blocks[x]![1]
            let model = BookViewModel(session: session, readingID: book.readingID)
            await model.adopt(book.postIDs.map {
                Queries.ReadingEntry(postID: $0, title: nil, entryDate: nil, sectionPath: nil)
            })
            model.noteIndexAnchor(x)
            model.carryPlace(from: .index, to: .outline, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.pendingOutlineBlockLanding == LandingTarget(postID: x, blockID: second),
                    "RED ON OLD (rev680): the carry parks her block for the Outline's landing")
            #expect(model.takeOutlineBlockLanding(for: x) == second,
                    "RED ON OLD (rev680): the Outline's landing of that note takes it")
            #expect(model.takeOutlineBlockLanding(for: x) == nil, "taken ONCE")

            // Another note's landing spends the park and takes nothing.
            model.carryPlace(from: .index, to: .outline, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.takeOutlineBlockLanding(for: y) == nil, "another note's landing takes nothing")
            #expect(model.pendingOutlineBlockLanding == nil, "…and spends the park")

            // Every later navigation drops it.
            let drops: [(String, (BookViewModel) -> Void)] = [
                ("a focus", { $0.focus(y) }),
                ("a reveal", { $0.requestReveal(y) }),
                ("a block landing", { $0.requestLanding(LandingTarget(postID: y, blockID: book.blocks[y]![0])) }),
                ("a chapter landing", { $0.requestChapterReveal("any-chapter") }),
                ("collapsing the note", { $0.collapse(x) }),
                ("collapse all", { $0.collapseAll() }),
            ]
            for (what, drop) in drops {
                model.carryPlace(from: .index, to: .outline, readForm: .flow, livePostID: x, liveBlockID: second)
                drop(model)
                #expect(model.pendingOutlineBlockLanding == nil, "\(what) drops the parked block")
            }

            // A carry anywhere else parks nothing.
            model.carryPlace(from: .index, to: .spread, readForm: .flow, livePostID: x, liveBlockID: second)
            #expect(model.pendingOutlineBlockLanding == nil, "into the spread: nothing parked")
            model.consumeReveal()
            model.carryPlace(from: .index, to: .outline, readForm: .flow, livePostID: y, liveBlockID: second)
            #expect(model.pendingOutlineBlockLanding == nil,
                    "a live pane in another note carries no block (VX-630's rule) — nothing parked")
        }
    }

    /// Mount the long-note book in INDEX with the long note's block `i` LIVE
    /// and her caret nine characters in (her move — the note's memory takes
    /// it), then click over to Outline through the mode door; settle until the
    /// Outline's editor is live at that block and the landing has ENDED.
    private func indexBlockToOutline(
        _ mounted: MountedBook, _ session: AppSession, _ book: TakesBook, block i: Int, inside: Int
    ) async throws -> EditorViewModel {
        let x = book.postIDs[0]
        let blockID = book.blocks[x]![i]
        let variantID = book.variants[x]![i]
        mounted.model.requestLanding(LandingTarget(postID: x, blockID: blockID))
        await settle(mounted.window, mounted.hosting, until: {
            indexPane(variantID, in: mounted.hosting) != nil
        }, maxTurns: 240)
        let pane = try #require(indexPane(variantID, in: mounted.hosting), "the premise: block \(i) went live in the Index")
        await settle(mounted.window, mounted.hosting, until: { false }, maxTurns: 4)
        pane.setSelectedRange(NSRange(location: inside, length: 0))
        await settle(mounted.window, mounted.hosting, until: {
            mounted.model.indexLiveBlockID == blockID
                && mounted.model.indexCaret?.place == BookOpenDoor.Place(blockID: blockID, offsetInBlock: inside)
        })
        try #require(mounted.model.indexLiveBlockID == blockID, "the premise: her caret in block \(i) in the Index")
#if DEBUG
        BookOutlineGeometry.trace = []
        let modeDoor = try #require(BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
        modeDoor(.outline)
        let anchor = BookOutlineRows.Row.noteAnchor(x)
        await settle(mounted.window, mounted.hosting, until: {
            guard let editing = session.editorRouter.editing, editing.postID == x,
                  let place = editing.caretIdentity(), place.blockID == blockID, place.offset == inside
            else { return false }
            return BookOutlineGeometry.trace.contains { $0.hasPrefix("\(anchor) DONE:") }
        }, maxTurns: 400)
        await settle(mounted.window, mounted.hosting, until: { false }, maxTurns: 6)
        print("VX-680 block \(i):", BookOutlineGeometry.trace.filter {
            $0.contains("block-home") || $0.contains("DONE") || $0.contains("BLOCK-REVEAL")
        }.suffix(6))
#endif
        let editing = try #require(session.editorRouter.editing, "the Outline's editor is live")
        try #require(editing.postID == x && editing.caretIdentity()?.blockID == blockID,
                     "the premise (VX-630): the note arrived live at block \(i) — \(String(describing: editing.caretIdentity()))")
        return editing
    }

    /// **THE PIN, her road.** Index: the long note's block 30 live, her caret
    /// nine in. The mode door → Outline: the note arrives live at block 30
    /// (VX-630) AND the page shows block 30 — wholly on the page.
    ///
    /// RED ON OLD (`rev680`): the page lands the note's ROW at the top and
    /// block 30 sits ~2,000 pt below the visible page.
    @Test func aFarBlockArrivesOnThePage() async throws {
        try await withLongNoteBook { session, db, book in
            let x = book.postIDs[0]
            let block = book.blocks[x]![30]
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
            let editing = try await indexBlockToOutline(mounted, session, book, block: 30, inside: 9)
            let textView = try #require(editing.textView)
            let seen = try #require(
                OutlineBlockSighting.read(blockID: block, textView: textView, index: editing.index),
                "the premise: the live editor has laid block 30 out")
            print("VX-680 FAR: residual \(seen.residual), top-in-page \(seen.topInViewport), page \(seen.viewportHeight)")
            #expect(abs(seen.residual) <= LandingPolicy.bookOutline.tolerance,
                    "RED ON OLD: block 30 is wholly on the page, not \(seen.residual) pt beyond it")
            #expect(textView.visibleRect.intersects(seen.target),
                    "RED ON OLD: the text view's visible part holds block 30")
            #expect(session.editorRouter.editing?.caretIdentity()?.blockID == block,
                    "her caret still in block 30 (VX-630's arrival, untouched)")
        }
    }

    /// **The guard — minimal, never a forced top; and the row first.** A
    /// carried block ALREADY on the page when the note's row lands (block 2,
    /// near the row's top): the page does not move for it — the row stays at
    /// the top.
    ///
    /// RED ON THE AS-BUILT VX-680 HAND-OVER (`vx677-b2/revB`; observed red at
    /// window vx677-b2 on post61 and rev662, `row-top=97`): in this small
    /// book the column briefly measures shorter than the page while the
    /// editor mounts, the page clamps and the row falls 97 pt back down; the
    /// block, still on the page, read as home and the row was never corrected
    /// (the VX-677 dispositions record, D-2). GREEN on `rev680` (no block
    /// home — the row's own correction) and on the fix (the row first while
    /// the block fits below it — `OutlineBlockLanding.homeIsTheRow`).
    @Test func aBlockAlreadyOnThePageMovesNothing() async throws {
        try await withLongNoteBook { session, db, book in
            let x = book.postIDs[0]
            let block = book.blocks[x]![1]
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
            let editing = try await indexBlockToOutline(mounted, session, book, block: 1, inside: 9)
            let textView = try #require(editing.textView)
            let seen = try #require(
                OutlineBlockSighting.read(blockID: block, textView: textView, index: editing.index),
                "the live editor has laid block 2 out")
            #expect(abs(seen.residual) <= LandingPolicy.bookOutline.tolerance, "block 2 is on the page")
#if DEBUG
            let top = BookOutlineGeometry.anchorTops[BookOutlineRows.Row.noteAnchor(x)]
            #expect(top.map { abs($0) <= 4 } == true,
                    "the note's row stays at the top of the page — the reveal never moved it (\(String(describing: top)))")
#endif
        }
    }
}

// MARK: - VX-662 — the Index's carry anchor never goes stale

/// **VX-662 (Bug · Low · Suspected — statically traced at VX-648 batch 4, the
/// record's FINDING paragraph; never observed live).** The Index's carry
/// anchor (`BookViewModel.indexAnchorPostID` — what leaving Index carries,
/// `BookAnchor.currentPost`'s `.index` arm: `indexPostID ?? standingPostID`)
/// was written ONLY by her selection (`BookIndexView.select(report: true)`) and
/// never cleared, while a CARRIED arrival selects with `report: false`. So:
/// her click on note A in an earlier Index visit, a later Outline → Index carry
/// of note B (block 2 live there), and leaving Index carried A — with B's block
/// live the block could not ride either (live note ≠ carried note), and the
/// Outline landed A.
///
/// PIN FIRST (the confirm): written and committed on the pre-fix tree.
/// RED ON OLD: the carry out of Index names A (`standingAnchorPostID`), and
/// the Outline's editor is not at B's block 2.
@Suite("VX-662 — the Index's carry anchor is what the Index shows, never an old click", .serialized)
@MainActor
struct BookIndexCarryAnchorTests {
    /// **HER ROAD.** Index: she selects note A (the select road's write —
    /// `noteIndexAnchor`, exactly what `select(report: true)` does on her
    /// click). Outline: her caret in note B's block 2, nine in. Outline →
    /// Index: B arrives with block 2 live (VX-304). Index → Outline: the
    /// Outline must reopen in B at block 2, nine in (VX-630) — never land A.
    @Test func aCarriedArrivalInIndexIsWhatLeavingIndexCarries() async throws {
        try await withTakesBook { session, db, book in
            let b = book.postIDs[0]          // the carried note (makeBlockTwoLive's note)
            let a = book.postIDs[1]          // her earlier click
            let second = book.blocks[b]![1]
            let chosen = book.variants[b]![1]
            let inside = 9
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            // 1 — Index, her click on A (the selection's own report).
            mounted.model.noteIndexAnchor(a)
            // 2 — leave for the Outline: the click-over carries A, as it should.
            modeDoor(.outline)
            await settle(mounted.window, mounted.hosting, until: { mounted.structure.mode == .outline })
            #expect(mounted.model.standingAnchorPostID == a, "the premise: leaving Index carried her click (A)")
            // 3 — Outline: her caret in B's block 2.
            try await makeBlockTwoLive(mounted, session, db, book, mode: .outline, inside: inside)
            // 4 — Outline → Index: B arrives with block 2 live (VX-304's carry).
            modeDoor(.index)
            await settle(mounted.window, mounted.hosting, until: {
                indexPane(chosen, in: mounted.hosting)?.selectedRange().location == inside
            }, maxTurns: 240)
            try #require(indexPane(chosen, in: mounted.hosting) != nil,
                         "the premise: B's block 2 arrived live in the Index")
            #expect(mounted.model.indexSelectedPostID == b, "the premise: the Index shows B")
            // 5 — Index → Outline, touching nothing in between.
            modeDoor(.outline)
            await settle(mounted.window, mounted.hosting, until: {
                guard let editing = session.editorRouter.editing, editing.postID == b,
                      let place = editing.caretIdentity()
                else { return false }
                return place.blockID == second && place.offset == inside
            }, maxTurns: 240)
            #expect(mounted.structure.mode == .outline, "the click-over arrived back in Outline")
            #expect(mounted.model.standingAnchorPostID == b,
                    "RED ON OLD: leaving Index carries the note it SHOWS (B), never her old click (A) — carried \(String(describing: mounted.model.standingAnchorPostID))")
            let place = session.editorRouter.editing?.caretIdentity()
            #expect(session.editorRouter.editing?.postID == b && place?.blockID == second
                        && place?.offset == inside,
                    "RED ON OLD: the Outline reopens in B at block 2, nine in (VX-630's arrival) — \(String(describing: place))")
#endif
        }
    }

    /// The guard: her OWN selection in this Index visit is still what leaving
    /// carries (the select road's write stands). Arrive carried on B, then
    /// her click on A in the column ⇒ leaving carries A.
    @Test func herSelectionInThisVisitIsStillWhatLeavingCarries() async throws {
        try await withTakesBook { session, db, book in
            let b = book.postIDs[0]
            let a = book.postIDs[1]
            let mounted = try await mountBook(session, db, book, mode: .outline)
            defer { mounted.close(book.readingID) }
#if DEBUG
            let modeDoor = try #require(
                BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
            mounted.model.focus(b)
            await settle(mounted.window, mounted.hosting, until: {
                session.editorRouter.editing?.postID == b
            })
            modeDoor(.index)
            await settle(mounted.window, mounted.hosting, until: {
                mounted.model.indexSelectedPostID == b
            }, maxTurns: 120)
            #expect(mounted.model.indexSelectedPostID == b, "the premise: carried into Index on B")
            mounted.model.noteIndexAnchor(a)   // her click on A, this visit
            modeDoor(.spread)
            await settle(mounted.window, mounted.hosting, until: { mounted.structure.mode == .spread })
            #expect(mounted.model.standingAnchorPostID == a, "her selection this visit is what leaving carries")
#endif
        }
    }
}

// MARK: - The ladder's R1-1 — D-2's class, the departing INDEX

/// Forty one-block notes in one book (a realistic card preview each — the
/// `BookOutlineLandingTests` fixture's), so a note far down the book sits far
/// below the Outline's fold when the Outline arrives at its own top.
@MainActor
private func withLongBook<T>(
    _ body: @MainActor (AppSession, AppDatabase, TakesBook) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 382))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the long book", kind: .book)
        var postIDs: [String] = []
        for p in 0..<40 {
            let post = try session.operations.createPost(title: "note \(p)")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "Prose of note \(p). It was a cold morning of the early spring, and we "
                    + "sat after breakfast on either side of a cheery fire in the old room at "
                    + "Baker Street, with a thick fog rolling down between the lines of "
                    + "dun-coloured houses opposite.",
                at: .end)
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        defer {
            for id in postIDs { session.commandRouter.forgetCurrentBlock(for: id) }
        }
        return try await body(session, db, TakesBook(
            readingID: reading.id, postIDs: postIDs, blocks: [:], variants: [:]))
    }
}

@Suite("VX-382 ladder R1-1 — the departing Index never eats the reveal the arriving Outline lands on", .serialized)
@MainActor
struct BookIndexToOutlineCarryTests {
    enum Road: String, CaseIterable, Sendable {
        /// The masthead's mode tabs — `BookView.switchMode`, through the
        /// published mode door (W21's click-over).
        case modeTabs
        /// The Index row menu's "Show in Outline" — `BookView`'s
        /// `onEditInOutline` closure, its three statements replayed verbatim
        /// (`focus` · `requestReveal` · `mode = .outline`, one synchronous
        /// run): a row menu's closure is unreachable from a pin.
        case showInOutline
    }

    /// **THE DECIDER (round 1's R1-1).** A note far down a long book is HER
    /// place in the Index (the Index landed it — its own `select`); the road
    /// leaves for the Outline. The ARRIVING Outline must land that note's row
    /// at the top of its page (W21: "the arriving surface consumes"). If the
    /// departing Index's `.onChange(of: pendingReveal)` fires in the switch's
    /// own update — as the departing Outline's did (D-2) — `landOrSeed`
    /// consumes the reveal on the way out, and the Outline arrives at its own
    /// top with the note ~2,600 pt below the fold.
    ///
    /// RED on the tip ⇒ the Index needs D-2's mode guard; GREEN on the tip ⇒
    /// R1-1 is hollow and this stays as the non-regression line.
    @Test(arguments: Road.allCases)
    func theOutlineArrivesOnTheCarriedNote(_ road: Road) async throws {
        try await withLongBook { session, db, book in
            let far = book.postIDs[25]
            let mounted = try await mountBook(session, db, book, mode: .index)
            defer { mounted.close(book.readingID) }
#if DEBUG
            // Her place in the Index: the far note, selected and shown.
            mounted.model.requestReveal(far)
            await settle(mounted.window, mounted.hosting, until: {
                mounted.model.pendingReveal == nil && mounted.model.indexSelectedPostID == far
            })
            #expect(mounted.model.pendingReveal == nil && mounted.model.indexSelectedPostID == far,
                    "the premise: the Index landed the far note (\(String(describing: mounted.model.indexSelectedPostID)))")

            switch road {
            case .modeTabs:
                let modeDoor = try #require(
                    BookOutlineGeometry.modeDoors[book.readingID], "the book published its mode door")
                modeDoor(.outline)
            case .showInOutline:
                mounted.model.focus(far)
                mounted.model.requestReveal(far)
                mounted.structure.mode = .outline
            }
            let anchor = BookOutlineRows.Row.noteAnchor(far)
            await settle(mounted.window, mounted.hosting, until: {
                BookOutlineGeometry.anchorTops[anchor].map { abs($0) <= BookView.landingTolerance }
                    ?? false
            }, maxTurns: 240)
            #expect(mounted.structure.mode == .outline, "\(road): the road arrived in Outline")
            let top = BookOutlineGeometry.anchorTops[anchor]
            #expect(top.map { abs($0) <= 4 } == true,
                    "R1-1 — \(road): the arriving Outline lands the carried note at the top of its page, not \(String(describing: top)) pt away (the departing Index ate the reveal)")
            #expect(mounted.model.pendingReveal == nil, "\(road): the reveal was consumed")
#endif
        }
    }
}
