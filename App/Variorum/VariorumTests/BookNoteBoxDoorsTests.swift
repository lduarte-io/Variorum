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
                UserDefaults.standard.removeObject(forKey: "postMode.\(id)")
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
