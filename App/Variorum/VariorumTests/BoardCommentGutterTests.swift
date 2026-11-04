//
//  BoardCommentGutterTests.swift
//  VariorumTests
//
//  **VX-770 batch 2 — the gutter contract on the board surfaces** (VX-730 ·
//  VX-731 · VX-728; SurfaceContracts › The note: *"Comments and callouts
//  render in the whitespace gutter outside the text area on every surface,
//  stacked vertically, and the prose column's measure and left edge never move
//  for a decoration (pinned per surface)"*; her R-770-2 for Compare, "Yes, show
//  them"; the orchestrator's P-770-3, option B).
//
//  THE TRACED MECHANISMS (the run record's BATCH 2 survey):
//  - VX-730 — the Takes article drew comments with its own SwiftUI note: the
//    FIRST comment only, capped at four lines, "+N more" for the rest.
//  - VX-731, slot split — an open fan replaces the article cell, and the note
//    rode the cell: no face at all.
//  - VX-731, carousel — the note rides the carousel cell by the code; the
//    survey found no carousel-only road. The ruling's note (a): the
//    style-independent road is the Study voice's compact chip, which printed
//    the voice's comment mark — "" in Study — so a one-comment block at a
//    narrow margin showed NOTHING. Both arms are pinned; the window's red run
//    says which one her sighting was.
//  - VX-728 — Compare read no comments and had no gutter to draw them in.
//
//  The pins read `BoardCommentFaceOracle` (the seam commit — the pre-fix note
//  reports what it draws), so every assertion asks the same question of both
//  trees; red on the pre-fix tree is verified by the BEHAVIOURAL REVERT (the
//  fix's source files restored to the seam commit, these tests at HEAD).
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

/// A review note long enough that four lines at the old note's 150-pt column
/// cut it (≈ 290 characters), and short enough that Write's card beside a
/// tall block holds it whole.
nonisolated private let longComment =
    "A long note from the review: this paragraph says the same thing twice, once "
    + "at its opening and again at its close, and the second saying is the weaker "
    + "one — cut it, or move the stronger image from the middle up to replace it, "
    + "so that the paragraph ends on the picture rather than on the claim."
nonisolated private let shortComment = "Second note: keep the last line as it is."

/// One tall paragraph (≈ 1,200 characters — a dozen lines at the article's
/// 680-pt measure), so Write's card beside it has room for both comments.
nonisolated private func tallProse(_ tag: String) -> String {
    (1...9).map { i in
        "\(tag), sentence \(i): honest prose on the measured line, long enough "
            + "that the paragraph wraps"
    }.joined(separator: " ") + "."
}

// MARK: - Shared rig

@MainActor
private func pump(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

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

@MainActor
private func pane(_ role: String, variant: String, in view: NSView) -> PaneTextView? {
    panes(in: view).first { $0.identifier?.rawValue == "pane:\(role)|\(variant)" }
}

/// A pane's prose column in WINDOW coordinates: (left edge, width).
@MainActor
private func proseColumn(_ pane: PaneTextView) -> (left: CGFloat, width: CGFloat) {
    let left = pane.convert(NSPoint(x: pane.proseLeft, y: 0), to: nil).x
    let right = pane.convert(NSPoint(x: pane.proseRight, y: 0), to: nil).x
    return (left, right - left)
}

@MainActor
private func windowFrame(_ view: NSView) -> CGRect { view.convert(view.bounds, to: nil) }

@MainActor
private func makeWindow(width: CGFloat, height: CGFloat) -> NSWindow {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: width, height: height),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    return window
}

// MARK: - The Takes world

@MainActor
private struct TakesCommentWorld {
    let session: AppSession
    let db: AppDatabase
    let postID: String
    /// The commented block (block 1 — fanned: its chosen take and a spare).
    let commented: (block: String, chosen: String, spare: String)
    /// An uncommented, unfanned block of the same height (block 2).
    let plain: (block: String, chosen: String)
    /// The commented block's comments, panel order.
    let comments: [String]
    let commentIDs: [String]
    let defaults: UserDefaults

    func boardModel() async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        model.adopt(try await db.read { [postID] in try Queries.takesProjection($0, post: postID) })
        return model
    }
}

@MainActor
private func withTakesCommentWorld(
    style: FanStyle, voice: ThemeVoice = .terminal, comments: [String],
    _ body: @MainActor (TakesCommentWorld) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    let suiteName = "BoardCommentGutter-\(UUID().uuidString)"
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 730))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(voice)
        try session.operations.setFanStyle(style)
        let post = try session.operations.createPost(title: "board comments fixture")
        let a = try session.operations.newBlock(in: post.id, text: tallProse("The commented block"))
        let spare = try session.operations.branchVariant(a.block.id, from: a.variant.id)
        let spareText = tallProse("The commented block's other take")
        try session.operations.autosave(spare.id, text: spareText, charDelta: spareText.count)
        let b = try session.operations.newBlock(in: post.id, text: tallProse("The plain block"))
        _ = try session.operations.newBlock(in: post.id, text: "A short closing line.")
        var ids: [String] = []
        for text in comments {
            ids.append(try session.operations.addBlockComment(to: a.block.id, text: text).id)
        }
        try await body(TakesCommentWorld(
            session: session, db: db, postID: post.id,
            commented: (a.block.id, a.variant.id, spare.id),
            plain: (b.block.id, b.variant.id),
            comments: comments, commentIDs: ids, defaults: defaults))
    }
}

@MainActor
private func mountTakes(
    _ model: TakesViewModel, _ world: TakesCommentWorld,
    width: CGFloat, theme: ThemeStore? = nil
) -> (NSWindow, NSView) {
    let window = makeWindow(width: width, height: 800)
    let board = TakesBoardView(session: world.session, postID: world.postID, model: model)
    let hosting: NSView
    if let theme {
        hosting = NSHostingView(rootView: board.environment(theme))
    } else {
        hosting = NSHostingView(rootView: board)
    }
    hosting.frame = NSRect(x: 0, y: 0, width: width, height: 800)
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    return (window, hosting)
}

@MainActor
private func closeTakes(_ window: NSWindow, _ model: TakesViewModel) {
    model.teardown()
    window.orderOut(nil)
    window.close()
}

// MARK: - VX-730 / VX-731 — the Takes board

@MainActor
@Suite("VX-730/VX-731 — the Takes board's comments, whole, in Write's gutter", .serialized)
struct TakesCommentGutterTests {
    /// What every style must show for the commented block: Write's CARD in the
    /// gutter, every comment its own entry, whole and uncapped, held without an
    /// inner scroll beside a block this tall, standing left of the prose.
    private func expectWholeCard(
        _ world: TakesCommentWorld, _ oracle: BoardCommentFaceOracle.Reader,
        _ hosting: NSView, board width: CGFloat, _ label: String
    ) {
        let face = oracle.face(world.commented.block)
        #expect(face != nil, "\(label): the commented block has a comment face on the board")
        #expect(face?.kind == .card,
                "\(label): the face is a card of comments (drew \(face.map { "\($0.kind)" } ?? "nothing"))")
        #expect(face?.entries == world.comments,
                """
                \(label): every comment, each its own entry, whole — drew \
                \(face?.entries.count ?? 0) of \(world.comments.count) \
                (label \(face?.label ?? "none"))
                """)
        #expect(face?.lineCap == nil,
                "\(label): no line cap on any entry (capped at \(face?.lineCap.map(String.init) ?? "-") lines)")

        let card = cards(in: hosting).first { $0.identity == world.commented.block }
        #expect(card != nil, "\(label): Write's card face (CommentCardView) draws them")
        guard let card else { return }
        #expect(card.showsStackedEntries && card.shownEntryCount == world.comments.count,
                "\(label): the card stacks \(card.shownEntryCount) entries")
        let scroll = card.innerScrollView
        let document = scroll.documentView?.frame.height ?? 0
        #expect(document <= scroll.contentSize.height + 0.5,
                """
                \(label): beside a block this tall the card holds its entries whole, \
                no inner scroll (entries \(document) pt, card \(scroll.contentSize.height) pt)
                """)
        // In the gutter: Write's card ends its handle-lane clearance short of
        // the prose's container edge (the article column's leading edge plus
        // the article's own text inset).
        let columnLeft = (width - TakesBoardView.articleMeasure(engagedRailWidth: nil)) / 2
        let textLeft = columnLeft + TakesBoardView.articleTextLeadingInset
        let rect = windowFrame(card)
        #expect(rect.maxX <= textLeft - BlockDecor.leftCardLane + 0.5,
                "\(label): the card stands in the gutter (its right edge \(rect.maxX), the prose at \(textLeft))")
        #expect(rect.minX >= -0.5, "\(label): …inside the board (\(rect.minX))")
    }

    /// **VX-730 — RED ON OLD.** Stack, at rest and with the fan open: the old
    /// note drew the first comment only, four lines at most, "+1 more".
    @Test(arguments: [false, true])
    func stackShowsEveryCommentWhole(open: Bool) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withTakesCommentWorld(style: .stack, comments: [longComment, shortComment]) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            if open { model.toggleExpanded(world.commented.block) }
            let (window, hosting) = mountTakes(model, world, width: 1100)
            defer { closeTakes(window, model) }
            await settle(window, hosting, until: { oracle.face(world.commented.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            expectWholeCard(world, oracle, hosting, board: 1100, "stack, fan \(open ? "open" : "closed")")
        }
    }

    /// **VX-731, slot split — RED ON OLD.** An open fan replaces the article
    /// cell; the note rode the cell, so the block had no face at all.
    @Test func slotSplitKeepsTheGutterOnAnOpenFan() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withTakesCommentWorld(style: .slotSplit, comments: [longComment, shortComment]) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            model.toggleExpanded(world.commented.block)
            let (window, hosting) = mountTakes(model, world, width: 1100)
            defer { closeTakes(window, model) }
            await settle(window, hosting, until: { oracle.face(world.commented.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            // Non-vacuity: the split bloom is what is drawn (the cell is gone).
            #expect(pane("article", variant: world.commented.chosen, in: hosting) == nil,
                    "fixture: the open slot split replaced the article cell")
            expectWholeCard(world, oracle, hosting, board: 1100, "slot split, fan open")
        }
    }

    /// **VX-731, carousel — the presence arm.** By the code read the old note
    /// rode the carousel's cell, so this arm's PRESENCE line may be green on
    /// the old tree (then carousel's "none" is not this road — the empty-chip
    /// pin below is); its whole-text lines are VX-730's and red there.
    @Test func carouselKeepsTheGutterOnAnOpenFan() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withTakesCommentWorld(style: .carousel, comments: [longComment, shortComment]) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            model.toggleExpanded(world.commented.block)
            let (window, hosting) = mountTakes(model, world, width: 1100)
            defer { closeTakes(window, model) }
            await settle(window, hosting, until: { oracle.face(world.commented.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            expectWholeCard(world, oracle, hosting, board: 1100, "carousel, fan open")
        }
    }

    /// **VX-731, carousel — the EMPTY-CHIP road (the ruling's note (a)) — RED
    /// ON OLD.** In Study, at a margin under the old note's 90 pt, a block with
    /// ONE comment drew the compact chip, which printed Study's comment mark:
    /// the empty string. Write's ladder seats its count badge there.
    @Test func aOneCommentBlockStillSaysSoInStudyAtANarrowMargin() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withTakesCommentWorld(
            style: .carousel, voice: .study, comments: [shortComment]
        ) { world in
            let theme = ThemeStore(session: world.session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = try await world.boardModel()
            // 800 pt: a 60-pt gutter — under the old note's 90, over Write's
            // badge floor.
            let (window, hosting) = mountTakes(model, world, width: 800, theme: theme)
            defer { closeTakes(window, model) }
            await settle(window, hosting, until: {
                theme.settings.voice == .study && oracle.face(world.commented.block) != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            #expect(theme.settings.voice == .study, "fixture: the board wears Study")

            let face = oracle.face(world.commented.block)
            #expect(face != nil, "the commented block has a face")
            let words = (face?.label ?? "") + (face?.entries.joined() ?? "")
            #expect(!words.isEmpty,
                    """
                    the face SAYS the block has a comment (it drew \
                    \(face.map { "\($0.kind) “\($0.label ?? "")”" } ?? "nothing")) — \
                    Study's comment mark is the empty string
                    """)
            #expect(face?.kind == .badge && face?.label == CommentCardView.badgeText(count: 1),
                    "at a 60-pt gutter Write's ladder seats its count badge")
            if let card = cards(in: hosting).first(where: { $0.identity == world.commented.block }),
               let prose = pane("article", variant: world.commented.chosen, in: hosting) {
                #expect(windowFrame(card).maxX <= proseColumn(prose).left - BlockDecor.commentBadgeAir + 0.5,
                        "the badge stands left of the prose (\(windowFrame(card).maxX) vs \(proseColumn(prose).left))")
            }
        }
    }

    /// **THE GUARD (the contract's "pinned per surface"; GREEN ON BOTH TREES
    /// by design).** A commented block's prose starts where an uncommented
    /// one's does, at the same measure, and deleting the comments moves
    /// neither.
    ///
    /// **Reconciled (VX-770 batch 2, after the window's red at the deletion
    /// arm on both trees):** this pin mounts TWO boards in one session, so it
    /// reads each board's own records (`BoardCommentFaceOracle.reader(_:board:)`).
    /// The red was the first board's leftover — its window closed with its
    /// hosting view alive, so its face never ran `onDisappear` — answering the
    /// second board's question through a session-keyed oracle. The face lines
    /// are the arms' NON-VACUITY (the first board drew the comments; the board
    /// mounted after the deletion draws none); the position lines are the
    /// guard.
    @Test func aCommentNeverMovesTheTakesProse() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withTakesCommentWorld(style: .stack, comments: [longComment, shortComment]) { world in
            let scope = world.session.debugProbeScope
            BoardCommentFaceOracle.reader(scope).reset()
            let first = try await world.boardModel()
            let firstBoard = BoardCommentFaceOracle.reader(scope, board: first)
            let (windowA, hostingA) = mountTakes(first, world, width: 1100)
            await settle(windowA, hostingA, until: { firstBoard.face(world.commented.block) != nil })
            await settle(windowA, hostingA, until: { false }, maxTurns: 8)
            #expect(firstBoard.face(world.commented.block) != nil,
                    "non-vacuity: the first board draws the comments")
            let commented = try #require(pane("article", variant: world.commented.chosen, in: hostingA))
            let plain = try #require(pane("article", variant: world.plain.chosen, in: hostingA))
            let withComments = proseColumn(commented)
            let uncommented = proseColumn(plain)
            #expect(abs(withComments.left - uncommented.left) < 0.5,
                    "the commented block's prose starts where the plain block's does (\(withComments.left) vs \(uncommented.left))")
            #expect(abs(withComments.width - uncommented.width) < 0.5,
                    "…at the same measure (\(withComments.width) vs \(uncommented.width))")
            for card in cards(in: hostingA) {
                #expect(windowFrame(card).maxX < withComments.left,
                        "every comment face stands left of the prose (\(windowFrame(card).maxX))")
            }
            closeTakes(windowA, first)

            for id in world.commentIDs { try world.session.operations.deleteBlockComment(id) }
            let second = try await world.boardModel()
            let secondBoard = BoardCommentFaceOracle.reader(scope, board: second)
            let (windowB, hostingB) = mountTakes(second, world, width: 1100)
            defer { closeTakes(windowB, second) }
            await settle(windowB, hostingB, until: {
                pane("article", variant: world.commented.chosen, in: hostingB) != nil
            })
            await settle(windowB, hostingB, until: { false }, maxTurns: 10)
            // The diagnostic the reconciliation asked for — never asserted:
            // what the CLOSED first board's record says now (a leftover if its
            // face never left; nil if its graph heard the deletion or the close).
            print("VX770-RECON: the closed first board's record after the deletion = "
                + (firstBoard.face(world.commented.block).map {
                    "\($0.kind) \($0.entries.count) entries" } ?? "none"))
            #expect(secondBoard.face(world.commented.block) == nil,
                    "non-vacuity: the board mounted after the deletion draws no face")
            let after = proseColumn(try #require(
                pane("article", variant: world.commented.chosen, in: hostingB)))
            #expect(abs(after.left - withComments.left) < 0.5 && abs(after.width - withComments.width) < 0.5,
                    "deleting the comments moves the prose not a point (\(after) vs \(withComments))")
        }
    }
}

// MARK: - VX-728 — Compare

@MainActor
private struct CompareCommentWorld {
    let session: AppSession
    let db: AppDatabase
    let anchor: String
    let twin: String
    let stranger: String
    /// The anchor's tall first block and its chosen take.
    let tall: (block: String, chosen: String)
    /// The anchor's second block (never commented).
    let other: (block: String, chosen: String)
}

@MainActor
private func withCompareCommentWorld(
    comments: [String], _ body: @MainActor (CompareCommentWorld) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 728))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let ops = session.operations
        let anchor = try ops.createPost(title: "the revised piece")
        let tall = try ops.newBlock(in: anchor.id, text: tallProse("The revised opening"))
        let other = try ops.newBlock(in: anchor.id, text: "Second block of the piece.")
        let twin = try ops.duplicateAsVersion(anchor.id)
        let stranger = try ops.createPost(title: "unrelated")
        _ = try ops.newBlock(in: stranger.id, text: "Nothing to do with it.")
        // After the duplicate, so only the anchor's block carries them.
        for text in comments { _ = try ops.addBlockComment(to: tall.block.id, text: text) }
        try await body(CompareCommentWorld(
            session: session, db: db, anchor: anchor.id, twin: twin.post.id,
            stranger: stranger.id, tall: (tall.block.id, tall.variant.id),
            other: (other.block.id, other.variant.id)))
    }
}

@MainActor
private func adoptCompare(
    _ model: CompareViewModel, _ world: CompareCommentWorld, peers: [String]
) async throws {
    model.adopt(try await world.db.read { db in
        try CompareViewModel.read(db, anchor: world.anchor, peers: peers)
    })
}

@MainActor
private func mountCompare(
    _ model: CompareViewModel, _ world: CompareCommentWorld, width: CGFloat
) -> (NSWindow, NSView) {
    let window = makeWindow(width: width, height: 760)
    let hosting = NSHostingView(
        rootView: CompareBoardView(session: world.session, postID: world.anchor, model: model)
            .environment(ThemeStore(session: world.session)))
    hosting.frame = NSRect(x: 0, y: 0, width: width, height: 760)
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    return (window, hosting)
}

@MainActor
@Suite("VX-728 — Compare shows block comments in its gutter (R-770-2, P-770-3)", .serialized)
struct CompareCommentGutterTests {
    /// **RED ON OLD — nothing on the Compare board read comments.** Two
    /// columns at 1100 pt: Write's card, every comment whole, in the cell's
    /// lane — left of the cell's chrome and its prose.
    @Test func aCommentedBlockShowsItsCommentsInItsColumn() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        let comments = [longComment, shortComment]
        try await withCompareCommentWorld(comments: comments) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = CompareViewModel(session: world.session, anchorPostID: world.anchor)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptCompare(model, world, peers: [world.twin])
            let (window, hosting) = mountCompare(model, world, width: 1100)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { oracle.face(world.tall.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)

            let face = oracle.face(world.tall.block)
            #expect(face != nil, "the commented block has a comment face in its Compare column")
            #expect(face?.kind == .card, "a two-column board's lane seats Write's card")
            #expect(face?.entries == comments, "every comment, each its own entry, whole")
            #expect(face?.lineCap == nil, "no line cap")
            #expect(oracle.face(world.other.block) == nil, "an uncommented block draws no face")
            let card = cards(in: hosting).first { $0.identity == world.tall.block }
            #expect(card != nil, "Write's card face draws them")
            if let card, let prose = pane("compare", variant: world.tall.chosen, in: hosting) {
                let rect = windowFrame(card)
                #expect(rect.maxX < windowFrame(prose).minX,
                        "the card stands in the lane, left of the cell's pane (\(rect.maxX) vs \(windowFrame(prose).minX))")
                #expect(rect.minX >= CompareBoardView.boardInset - 0.5,
                        "…inside its own column (\(rect.minX))")
                let scroll = card.innerScrollView
                #expect((scroll.documentView?.frame.height ?? 0) <= scroll.contentSize.height + 0.5,
                        "beside a block this tall the card holds both comments without an inner scroll")
            }
        }
    }

    /// **RED ON OLD.** Three columns at 1100 pt: each ~353 pt, too narrow for a
    /// card lane — Write's ladder seats its count badge in the badge lane.
    @Test func aNarrowColumnSeatsWritesCountBadge() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withCompareCommentWorld(comments: [longComment, shortComment]) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = CompareViewModel(session: world.session, anchorPostID: world.anchor)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            model.addPeerSlot()
            model.setPeer(slotID: model.peerSlots[1].id, postID: world.stranger)
            model.relatedOnly = false
            try await adoptCompare(model, world, peers: [world.twin, world.stranger])
            let (window, hosting) = mountCompare(model, world, width: 1100)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { oracle.face(world.tall.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)

            #expect(model.peerSlots.count == 2, "fixture: three columns")
            let face = oracle.face(world.tall.block)
            #expect(face?.kind == .badge, "a narrow column's lane seats the badge (drew \(face.map { "\($0.kind)" } ?? "nothing"))")
            #expect(face?.label == CommentCardView.badgeText(count: 2), "…carrying the count")
            if let card = cards(in: hosting).first(where: { $0.identity == world.tall.block }),
               let prose = pane("compare", variant: world.tall.chosen, in: hosting) {
                #expect(windowFrame(card).maxX < windowFrame(prose).minX,
                        "the badge stands in the lane, left of the cell's pane")
            }
        }
    }

    /// **THE GUARD — P-770-3's rider 1 (the lane is the column width's, never
    /// a comment's).** Adding a comment, then deleting it, moves neither the
    /// prose's left edge nor its measure. Its POSITION lines are green on both
    /// trees by design; its non-vacuity line (the face appeared) is VX-728's
    /// and red on the old tree.
    @Test func addingOrDeletingACommentNeverMovesTheCompareProse() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withCompareCommentWorld(comments: []) { world in
            let oracle = BoardCommentFaceOracle.reader(world.session.debugProbeScope)
            oracle.reset()
            let model = CompareViewModel(session: world.session, anchorPostID: world.anchor)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptCompare(model, world, peers: [world.twin])
            let (window, hosting) = mountCompare(model, world, width: 1100)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: {
                pane("compare", variant: world.tall.chosen, in: hosting) != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            let before = proseColumn(try #require(pane("compare", variant: world.tall.chosen, in: hosting)))

            let comment = try world.session.operations.addBlockComment(
                to: world.tall.block, text: shortComment)
            try await adoptCompare(model, world, peers: [world.twin])
            await settle(window, hosting, until: { oracle.face(world.tall.block) != nil })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(oracle.face(world.tall.block) != nil, "non-vacuity: the new comment is drawn")
            let commented = proseColumn(try #require(pane("compare", variant: world.tall.chosen, in: hosting)))
            #expect(abs(commented.left - before.left) < 0.5 && abs(commented.width - before.width) < 0.5,
                    "adding a comment moves the prose not a point (\(commented) vs \(before))")

            try world.session.operations.deleteBlockComment(comment.id)
            try await adoptCompare(model, world, peers: [world.twin])
            await settle(window, hosting, until: { oracle.face(world.tall.block) == nil })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(oracle.face(world.tall.block) == nil, "the deleted comment leaves the board (the feed is live)")
            let after = proseColumn(try #require(pane("compare", variant: world.tall.chosen, in: hosting)))
            #expect(abs(after.left - before.left) < 0.5 && abs(after.width - before.width) < 0.5,
                    "deleting it moves the prose not a point (\(after) vs \(before))")
        }
    }
}

// MARK: - The shared rules (pure — no mount)

@Suite("VX-770 batch 2 — the one ladder, the width-only lane")
struct BoardCommentGutterRuleTests {
    /// The decision every host asks IS Write's: `commentGutterFaces` answers,
    /// per block, exactly what `commentFace` answers for the same inputs.
    @Test(arguments: [CGFloat(220), 150, 149, 60, 25, 20])
    func writesFacesAreTheOneDecision(textLeft: CGFloat) {
        var state = BlockDecor.State()
        state.textLeft = textLeft
        state.frames = [
            BlockDecor.Frame(entryIndex: 0, blockID: "a", frame: CGRect(x: 0, y: 10, width: 600, height: 80)),
            BlockDecor.Frame(entryIndex: 1, blockID: "b", frame: CGRect(x: 0, y: 100, width: 600, height: 20)),
        ]
        state.comments = [
            "a": [.init(id: "1", text: "x")], "b": [.init(id: "2", text: "y")],
        ]
        let faces = BlockDecor.commentGutterFaces(state)
        #expect(faces["a"] == BlockDecor.commentFace(
            textLeft: textLeft, top: 10, blockHeight: 80, roomBelow: 90))
        #expect(faces["b"] == BlockDecor.commentFace(
            textLeft: textLeft, top: 100, blockHeight: 20, roomBelow: nil))
    }

    /// A per-row host's card never reaches the next row's face.
    @Test func aRowHostsCardStaysInItsRow() {
        let top: CGFloat = 8
        let row: CGFloat = 120
        let face = BlockDecor.commentFace(
            textLeft: 220, top: top, blockHeight: row - 16,
            roomBelow: BlockDecor.roomBelowInOwnRow(rowHeight: row, top: top, rowSpacing: 6))
        guard case .card(let rect) = face else {
            Issue.record("a wide gutter seats a card (\(face))")
            return
        }
        #expect(rect.maxY <= row + 6 - BlockDecor.cardRhythmAir + 0.01,
                "the card ends the rhythm's air short of the next row's top (\(rect.maxY))")
    }

    /// **P-770-3: the lane is a function of the column's width only** — and
    /// each lane seats the face it is named for, wholly inside itself.
    @Test func compareLaneTable() {
        #expect(BlockDecor.gutterFitsCards(width: CompareGutter.cardLane))
        #expect(!BlockDecor.gutterFitsCards(width: CompareGutter.cardLane - 1))
        // The default window's 2 / 3 / 4 columns, and a column too narrow to spare one.
        #expect(CompareGutter.lane(columnWidth: 499) == CompareGutter.cardLane)
        #expect(CompareGutter.lane(columnWidth: 330) == CompareGutter.badgeLane)
        #expect(CompareGutter.lane(columnWidth: 245) == CompareGutter.badgeLane)
        #expect(CompareGutter.lane(columnWidth: 200) == 0)
        #expect(CompareGutter.columnWidth(boardWidth: 1030, columns: 2, inset: 12, spacing: 8) == 499)

        let card = BlockDecor.commentFace(textLeft: CompareGutter.cardLane, top: 6, blockHeight: 200, roomBelow: nil)
        guard case .card(let cardRect) = card else {
            Issue.record("the card lane seats a card (\(card))")
            return
        }
        #expect(cardRect.minX >= 0 && cardRect.maxX <= CompareGutter.cardLane)
        let badge = BlockDecor.commentFace(textLeft: CompareGutter.badgeLane, top: 6, blockHeight: 200, roomBelow: nil)
        guard case .badge(let badgeRect) = badge else {
            Issue.record("the badge lane seats a badge (\(badge))")
            return
        }
        #expect(badgeRect.width == BlockDecor.commentBadgeSize.width, "a full 32-pt badge")
        #expect(badgeRect.minX >= 0 && badgeRect.maxX <= CompareGutter.badgeLane)
    }
}

#endif
