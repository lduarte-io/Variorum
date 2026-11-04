//
//  TakesPostUndoStalenessTests.swift
//  VariorumTests
//
//  **VX-770 batch 3 — the post-undo staleness pair on the Takes board**
//  (VX-732 · VX-733; her recording of 2026-11-01, the MCP demo: ⌥⌘Z undid the
//  AI's comments and its takes, the receipts said so, and the board kept
//  drawing both — the comments in the gutter until a mode switch, the open-fan
//  wash on the now one-take blocks through a Write round trip, until "close
//  all").
//
//  THE TRACED MECHANISMS (the run record's BATCH 3 trace — two, not one):
//  - VX-732 — the row's comment face kept a per-row copy filled by ONE read,
//    keyed only on the block id (`CommentMarginNote`'s `.task(id: blockID)`):
//    the undo's delivery re-rendered the row, the copy survived it, nothing
//    re-read it.
//  - VX-733 — the wash IS open-set membership (`isBloomed`), and the open set
//    was reconciled only on a showing's first projection and only against
//    block ids: a block whose fan collapsed to one take stayed open, and the
//    session memory carried it through the mode switch.
//
//  Every pin stages her acts as the app runs them: the AI's batch through the
//  same operation the MCP door calls (`addComments`, `addTakes` — one undo entry
//  each, labeled with the client), then the real structural undo
//  (`UndoStack.undo`, the ⌥⌘Z door's own call) while THE takes board is
//  mounted, the store's change reaching the board through its own
//  observation. RED ON OLD is verified by the behavioural revert (the fix's
//  wiring neutered, these tests at HEAD); the GUARDs are green on both trees by
//  design — her R-770-1 (fans she opened that still hold takes stay open), R72's
//  first-take door, the archive road, and her open comments panel.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG

// MARK: - The words

nonisolated private let aiNoteOne =
    "From the review: the opening sentence promises a turn the paragraph never takes."
nonisolated private let aiNoteTwo = "Second note: the last clause repeats the title."

/// A paragraph that wraps several times at the article's measure, so a comment
/// card beside it is a card (and its row has real height).
nonisolated private func stalenessProse(_ i: Int) -> String {
    (1...4).map { s in
        "Paragraph \(i), sentence \(s): honest prose on the measured line, long enough "
            + "that the block wraps"
    }.joined(separator: " ") + "."
}

// MARK: - The rig

@MainActor
private func pump(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// The mounted suites' settle: layout, display, a run-loop turn AND an await
/// (a nested run loop runs no main-queue hop — TEXTKIT2_NOTES' harness fact —
/// and the board's observation delivers on one).
@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView,
    until predicate: () -> Bool, maxTurns: Int = 60
) async {
    for _ in 0..<maxTurns {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(20))
        if predicate() { return }
    }
}

@MainActor
private func cards(in view: NSView) -> [CommentCardView] {
    var found: [CommentCardView] = []
    if let card = view as? CommentCardView { found.append(card) }
    for sub in view.subviews { found.append(contentsOf: cards(in: sub)) }
    return found
}

@MainActor
private func panes(in view: NSView) -> [PaneTextView] {
    var found: [PaneTextView] = []
    if let pane = view as? PaneTextView { found.append(pane) }
    for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
    return found
}

/// One note of `count` blocks. Block `i` carries a second take of its OWN (the
/// author's, before the AI arrives) when `ownFan(i)`.
@MainActor
private struct StalenessWorld {
    let session: AppSession
    let db: AppDatabase
    let postID: String
    let blocks: [(block: String, chosen: String, spare: String?)]
    let defaults: UserDefaults

    var blockIDs: [String] { blocks.map(\.block) }

    func projection() async throws -> Queries.TakesProjection {
        try await db.read { [postID] in try Queries.takesProjection($0, post: postID) }
    }

    /// THE takes board's model, wired in `TakesBoardView.init`'s order: told it
    /// is THE board (the moment VX-428 seeds it), then its first projection.
    func boardModel() async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        model.landingEnabled = true
        model.adopt(try await projection())
        return model
    }

    /// The note's open fans as the SESSION remembers them (VX-428's memory).
    var remembered: Set<String>? { session.editorRouter.takesExpandedBlocks[postID] }

    func slot(_ model: TakesViewModel, _ blockID: String) -> Queries.RenderedBlock? {
        model.projection.slots.first { $0.blockID == blockID }
    }

    func isBloomed(_ model: TakesViewModel, _ blockID: String) -> Bool {
        slot(model, blockID).map(model.isBloomed) ?? false
    }

    func liveComments(_ blockID: String) throws -> [BlockComment] {
        try db.read { try Queries.blockComments($0, blockID: blockID) }
    }

    func mount(_ model: TakesViewModel, width: CGFloat = 1100) async -> (NSWindow, NSView) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: 800),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: TakesBoardView(session: session, postID: postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
        await settle(window, hosting, until: { false }, maxTurns: 8)
        return (window, hosting)
    }

    func close(_ window: NSWindow, _ model: TakesViewModel) {
        model.teardown()
        window.orderOut(nil)
        window.close()
    }
}

@MainActor
private func withStalenessWorld(
    blocks count: Int,
    style: FanStyle = .stack,
    ownFan: @escaping (Int) -> Bool = { _ in false },
    _ body: @MainActor (StalenessWorld) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    let suiteName = "TakesPostUndoStaleness-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    defer { defaults.removePersistentDomain(forName: suiteName) }
    try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 732))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(.terminal)
        try session.operations.setFanStyle(style)
        let post = try session.operations.createPost(title: "post-undo staleness fixture")
        var made: [(block: String, chosen: String, spare: String?)] = []
        for i in 0..<count {
            let minted = try session.operations.newBlock(in: post.id, text: stalenessProse(i + 1))
            var spare: String?
            if ownFan(i) {
                let take = try session.operations.branchVariant(minted.block.id, from: minted.variant.id)
                let words = "Her own other take of paragraph \(i + 1), in its own words."
                try session.operations.autosave(take.id, text: words, charDelta: words.count)
                spare = take.id
            }
            made.append((minted.block.id, minted.variant.id, spare))
        }
        try await body(StalenessWorld(
            session: session, db: db, postID: post.id, blocks: made, defaults: defaults))
    }
}

// MARK: - VX-732 — the comments leave the gutter (mounted)

@MainActor
@Suite("VX-732 — comments the store no longer holds leave the Takes gutter (mounted)", .serialized)
struct TakesCommentFeedLivenessTests {

    /// **RED ON OLD — her repro, every fan style.** The AI's two comments on a
    /// block (one `add_comments` batch, one undo entry), drawn in the gutter;
    /// ⌥⌘Z with the board up → the face leaves within the board's own refresh
    /// (the store's change reaching it through its observation), no mode
    /// switch. Then ⇧⌥⌘Z puts them back by the same road.
    @Test(arguments: [FanStyle.stack, .marginGrid, .slotSplit, .carousel])
    func anUndoneAIsCommentsLeaveTheGutter(style: FanStyle) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withStalenessWorld(blocks: 3, style: style, ownFan: { $0 == 0 }) { world in
            let block = world.blockIDs[0]
            _ = try world.session.operations.addComments(
                [.init(blockID: block, text: aiNoteOne), .init(blockID: block, text: aiNoteTwo)],
                inNote: world.postID, author: "claude-code", undoLabel: "claude-code's comments")
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            model.toggleExpanded(block)  // the fan open (every bloom form keeps the face)
            let (window, hosting) = await world.mount(model)
            defer { world.close(window, model) }
            let card = { cards(in: hosting).first { $0.identity == block } }
            await settle(window, hosting, until: { oracle.face(block) != nil && card() != nil })

            let drawn = oracle.face(block)
            #expect(drawn != nil, "non-vacuity (\(style)): the AI's comments are drawn in the gutter")
            if drawn?.kind == .card {
                #expect(drawn?.entries == [aiNoteOne, aiNoteTwo], "non-vacuity: both, as entries")
            } else {
                #expect(drawn?.label == CommentCardView.badgeText(count: 2), "non-vacuity: the count badge says two")
            }

            let undone = try world.session.undoStack.undo(with: world.session.operations)
            #expect(undone == "claude-code's comments", "fixture: ⌥⌘Z undid the AI's batch (\(undone ?? "nothing"))")
            #expect(try world.liveComments(block).isEmpty, "fixture: the store holds none of them")
            // Two observations reach the board (the takes projection, the
            // comments): wait for both before judging either.
            await settle(window, hosting, until: {
                oracle.face(block) == nil && card() == nil
                    && world.slot(model, block)?.commentCount == 0
            })

            #expect(oracle.face(block) == nil,
                    """
                    RED ON OLD (\(style)): the gutter still draws the comments ⌥⌘Z took — \
                    \(oracle.face(block).map { "\($0.kind) \($0.entries.count) entries \($0.label ?? "")" } ?? "")
                    """)
            #expect(card() == nil, "…and no Write card stands for them on the board")
            #expect(model.loaded && world.slot(model, block)?.commentCount == 0,
                    "fixture: the board's own projection already says the block has none")

            let redone = try world.session.undoStack.redo(with: world.session.operations)
            #expect(redone == "claude-code's comments", "fixture: ⇧⌥⌘Z put the batch back")
            await settle(window, hosting, until: { oracle.face(block) != nil && card() != nil })
            #expect(oracle.face(block) != nil && card() != nil,
                    "the redo's comments come back to the gutter by the same live road")
        }
    }

    /// **RED ON OLD — any road, not just the undo.** A comment edited and then
    /// deleted from OUTSIDE the board (another window's panel, the AI, a sync
    /// apply — the operations they all run): the face follows the store, entry
    /// by entry, while the board is up.
    @Test func aCommentChangedFromOutsideTheBoardFollowsTheStore() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withStalenessWorld(blocks: 3) { world in
            let block = world.blockIDs[0]
            let first = try world.session.operations.addBlockComment(to: block, text: aiNoteOne)
            let second = try world.session.operations.addBlockComment(to: block, text: aiNoteTwo)
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            let (window, hosting) = await world.mount(model)
            defer { world.close(window, model) }
            await settle(window, hosting, until: { oracle.face(block)?.entries.count == 2 })
            #expect(oracle.face(block)?.entries == [aiNoteOne, aiNoteTwo], "non-vacuity: both drawn")

            let edited = "Edited elsewhere: the opening now takes its turn."
            try world.session.operations.editBlockComment(first.id, text: edited)
            await settle(window, hosting, until: { oracle.face(block)?.entries.first == edited })
            #expect(oracle.face(block)?.entries == [edited, aiNoteTwo],
                    "RED ON OLD: an edit made outside the board reaches its gutter (drew \(oracle.face(block)?.entries ?? []))")

            try world.session.operations.deleteBlockComment(second.id)
            await settle(window, hosting, until: { oracle.face(block)?.entries.count == 1 })
            #expect(oracle.face(block)?.entries == [edited],
                    "RED ON OLD: a deletion made outside the board leaves its gutter (drew \(oracle.face(block)?.entries ?? []))")

            try world.session.operations.deleteBlockComment(first.id)
            await settle(window, hosting, until: { oracle.face(block) == nil })
            #expect(oracle.face(block) == nil && !cards(in: hosting).contains { $0.identity == block },
                    "RED ON OLD: the last one gone, the face goes with it")
        }
    }

    /// **GUARD (green on both trees by design) — her open panel keeps its
    /// seat.** The face is her comments panel's door AND its popover's anchor:
    /// with a live feed, deleting the block's last comment inside the panel
    /// must not tear the panel down under her (the deleted fold, with its
    /// Restore, is right there). The face holds what it showed until the panel
    /// closes. (The old one-shot feed never updated while the panel was open —
    /// this pins that the live feed keeps that.)
    @Test func herOpenPanelKeepsItsSeatWhenTheLastCommentLeaves() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withStalenessWorld(blocks: 3) { world in
            let block = world.blockIDs[0]
            let only = try world.session.operations.addBlockComment(to: block, text: aiNoteOne)
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            let (window, hosting) = await world.mount(model)
            defer { world.close(window, model) }
            let card = { cards(in: hosting).first { $0.identity == block } }
            await settle(window, hosting, until: { card() != nil })
            let door = try #require(card()?.onClick, "fixture: the face is a door")
            door()  // her press: the comments panel opens on the face
            await settle(window, hosting, until: { false }, maxTurns: 6)

            try world.session.operations.deleteBlockComment(only.id)  // as her panel's Delete does
            await settle(window, hosting, until: { false }, maxTurns: 12)
            #expect(card() != nil,
                    "the face stays seated under her open panel when its last comment leaves")
            #expect(oracle.face(block)?.entries == [aiNoteOne],
                    "…showing what it showed when she opened the panel")
        }
    }
}

// MARK: - VX-733 — the wash leaves a collapsed fan (mounted)

@MainActor
@Suite("VX-733 — an undo that collapses an open fan takes its wash with it (mounted)", .serialized)
struct TakesCollapsedFanWashTests {

    /// **RED ON OLD — her repro, every fan style; R-770-1 and R72 riding as
    /// guards.** Block A has her own second take; the AI's one `add_takes` batch
    /// gives A, B and C a take each; expand all opens A, B, C, and D's
    /// first-take door is open too. ⌥⌘Z with the board up: B and C hold one take
    /// again — their wash (and bloom) goes, in the layout AND the session
    /// memory, so a Write round trip does not bring it back. A still holds two
    /// takes — its fan STAYS OPEN (R-770-1); D never held two — its door stays
    /// open (R72). The wash is drawn from exactly `isBloomed` (`washedCell`'s
    /// `washed:` argument).
    @Test(arguments: [FanStyle.stack, .marginGrid, .slotSplit, .carousel])
    func anUndoneAIsTakesCloseTheFansTheyCollapsed(style: FanStyle) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withStalenessWorld(blocks: 5, style: style, ownFan: { $0 == 0 }) { world in
            let b = world.blockIDs
            let (a, bb, c, d) = (b[0], b[1], b[2], b[3])
            _ = try world.session.operations.addTakes(
                [.init(blockID: a, text: "The AI's take of paragraph 1."),
                 .init(blockID: bb, text: "The AI's take of paragraph 2."),
                 .init(blockID: c, text: "The AI's take of paragraph 3.")],
                inNote: world.postID, undoLabel: "claude-code's takes")
            let model = try await world.boardModel()
            model.expandAllFans()       // A, B, C — every fanned block
            model.toggleExpanded(d)     // D's first-take door (⑂+)
            #expect(world.remembered == [a, bb, c, d], "non-vacuity: the session holds all four open")
            let (window, hosting) = await world.mount(model)
            var closed = false
            defer { if !closed { world.close(window, model) } }
            for id in [a, bb, c, d] {
                #expect(world.isBloomed(model, id), "non-vacuity (\(style)): every open block draws open")
            }

            let undone = try world.session.undoStack.undo(with: world.session.operations)
            #expect(undone == "claude-code's takes", "fixture: ⌥⌘Z undid the AI's takes (\(undone ?? "nothing"))")
            await settle(window, hosting, until: {
                world.slot(model, bb)?.hasFan == false && world.slot(model, c)?.hasFan == false
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(world.slot(model, bb)?.activeVariantCount == 1 && world.slot(model, a)?.activeVariantCount == 2,
                    "fixture: the board adopted the undo (B one take, A two)")

            for id in [bb, c] {
                #expect(!world.isBloomed(model, id),
                        "RED ON OLD (\(style)): a block whose fan collapsed to one take keeps the wash")
                #expect(!model.expandedBlocks.contains(id), "…and leaves the open set")
            }
            #expect(world.remembered == [a, d],
                    "RED ON OLD: …and the session forgets it, so a Write round trip cannot wash it again (\(world.remembered ?? []))")
            #expect(world.isBloomed(model, a),
                    "GUARD (R-770-1): A still holds two takes — the fan she opened stays open, washed")
            #expect(world.isBloomed(model, d),
                    "GUARD (R72): D's first-take door never held two takes — it stays open")

            // Her Write round trip (the board remounts — a fresh model, seeded).
            world.close(window, model)
            closed = true
            await settle(window, hosting, until: { false }, maxTurns: 4)
            let back = try await world.boardModel()
            defer { back.teardown() }
            #expect(back.expandedBlocks == [a, d],
                    "RED ON OLD: back from Write, only the fans that still hold takes (and D's door) are open (\(back.expandedBlocks))")
            #expect(!world.isBloomed(back, bb) && !world.isBloomed(back, c))
        }
    }
}

// MARK: - VX-733 — every road, and the guards (no mount: the conductor's state transitions)

@MainActor
@Suite("VX-733 — an open fan that collapses closes, by every road; what stays open stays", .serialized)
struct TakesCollapsedFanRoadsTests {

    /// **RED ON OLD — the collapse while the board is DOWN.** The open fans are
    /// remembered; ⌥⌘Z is pressed in Write (the AI's undo entry is global); she
    /// comes back to Takes: the fresh board, seeded before its first
    /// projection, must not wash a block that now holds one take — and the
    /// fan that still holds two comes back open (R-770-1).
    @Test func aFanThatCollapsesWhileTheBoardIsAwayComesBackClosed() async throws {
        try await withStalenessWorld(blocks: 3, ownFan: { $0 == 0 }) { world in
            let (a, bb) = (world.blockIDs[0], world.blockIDs[1])
            _ = try world.session.operations.addTakes(
                [.init(blockID: a, text: "The AI's take of paragraph 1."),
                 .init(blockID: bb, text: "The AI's take of paragraph 2.")],
                inNote: world.postID, undoLabel: "claude-code's takes")
            let first = try await world.boardModel()
            first.expandAllFans()
            #expect(world.remembered == [a, bb], "non-vacuity: both open, remembered")
            first.teardown()  // she switches to Write

            _ = try world.session.undoStack.undo(with: world.session.operations)  // ⌥⌘Z, in Write

            let back = TakesViewModel(session: world.session, postID: world.postID, defaults: world.defaults)
            back.landingEnabled = true  // `TakesBoardView.init` — the seed
            back.adopt(try await world.projection())
            defer { back.teardown() }
            #expect(!world.isBloomed(back, bb),
                    "RED ON OLD: back in Takes, the block that holds one take again is washed open")
            #expect(back.expandedBlocks == [a] && world.remembered == [a],
                    "RED ON OLD: the open set and the memory keep only the fan that still holds takes (\(back.expandedBlocks))")
            #expect(world.isBloomed(back, a), "GUARD (R-770-1): A's fan, still two takes, comes back open")
        }
    }

    /// **RED ON OLD — any road inside the showing.** Her own take deleted from
    /// an open two-take fan (the card's Delete — the same tombstone the undo
    /// writes): the fan closes. Then the PROVISIONAL B3-P2 (a): a ⌥⌘Z that puts
    /// the take back brings the fan back CLOSED (its ⑂n badge is the door) —
    /// the open state belonged to a fan that had collapsed.
    @Test func deletingAnOpenFansSecondTakeClosesIt() async throws {
        try await withStalenessWorld(blocks: 3, ownFan: { $0 == 0 }) { world in
            let blockA = world.blocks[0]
            let a = blockA.block
            let spare = try #require(blockA.spare)
            let model = try await world.boardModel()
            defer { model.teardown() }
            model.toggleExpanded(a)
            #expect(world.isBloomed(model, a), "non-vacuity: her fan is open")

            try world.session.operations.deleteVariant(spare)
            model.adopt(try await world.projection())
            #expect(!world.isBloomed(model, a),
                    "RED ON OLD: the fan collapsed to one take and stays washed open")
            #expect(world.remembered == nil, "RED ON OLD: …and the session forgets it")

            _ = try world.session.undoStack.undo(with: world.session.operations)  // the delete, undone
            model.adopt(try await world.projection())
            #expect(world.slot(model, a)?.hasFan == true, "fixture: the take is back")
            #expect(!world.isBloomed(model, a),
                    "PROVISIONAL B3-P2 (a): a fan that comes back after collapsing comes back closed")
        }
    }

    /// **GUARD (green on both trees) — the archive road (PROVISIONAL B3-P1 (a)).**
    /// Archiving an open fan's second take drops the fan to one ACTIVE take, but
    /// the archived take stays on the block and its bloom shows it — "archived ·
    /// n", the road back the archive receipt names. The block stays open.
    @Test func archivingAnOpenFansSecondTakeKeepsTheArchivedRoadOpen() async throws {
        try await withStalenessWorld(blocks: 3, ownFan: { $0 == 0 }) { world in
            let blockA = world.blocks[0]
            let a = blockA.block
            let spare = try #require(blockA.spare)
            let model = try await world.boardModel()
            defer { model.teardown() }
            model.toggleExpanded(a)

            try world.session.operations.archiveVariant(spare)
            model.adopt(try await world.projection())
            #expect(world.slot(model, a)?.hasFan == false && world.slot(model, a)?.hasArchivedTakes == true,
                    "fixture: one active take, one archived")
            #expect(world.isBloomed(model, a),
                    "the block stays open — its archived take is still under it, the receipt's road back")
            #expect(world.remembered == [a], "…and remembered open")
        }
    }

    /// **GUARD (green on both trees) — R72's first-take door.** An unfanned
    /// block she opened through ⑂+ stays open through later projections and a
    /// mode round trip: it never held two takes, so nothing collapsed.
    @Test func theFirstTakeDoorStaysOpenThroughProjectionsAndARoundTrip() async throws {
        try await withStalenessWorld(blocks: 3, ownFan: { $0 == 0 }) { world in
            let (a, d) = (world.blocks[0], world.blockIDs[2])
            let first = try await world.boardModel()
            first.toggleExpanded(d)
            // An unrelated write elsewhere in the note, adopted.
            try world.session.operations.autosave(a.chosen, text: "Paragraph 1, retyped.", charDelta: 4)
            first.adopt(try await world.projection())
            #expect(world.isBloomed(first, d), "the door stays open through a later projection")
            first.teardown()

            let back = try await world.boardModel()
            defer { back.teardown() }
            #expect(world.isBloomed(back, d), "…and through a mode round trip")
            #expect(world.remembered == [d])
        }
    }
}

#endif
