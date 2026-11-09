//
//  TakesCalloutOneLawTests.swift
//  VariorumTests
//
//  **VX-782 — the callout frame never moves the Takes prose** (the VX-915
//  run, batch 2; R-B2-1 of `notes/plans/fixes/vx-770-takes-compare-window.md`;
//  SurfaceContracts › The note: *"Comments and callouts render in the
//  whitespace gutter outside the text area on every surface … and the prose
//  column's measure and left edge never move for a decoration (pinned per
//  surface)"*).
//
//  THE TRACED MECHANISM (the run record's BATCH 2 trace): `TakesCalloutFrame`
//  padded the article row's whole `HStack` by 5 pt on every side — LAYOUT —
//  so the row's content was offered 10 pt less than the article measure, the
//  680-pt column shrank to 670, and a callout block's prose started 5 pt right
//  of a plain block's and measured 10 pt narrower, in every fan style.
//
//  The pin mounts the real board with one framed block and one plain block of
//  the same prose and reads both article panes' prose columns in WINDOW
//  coordinates (`PaneTextView.proseLeft/proseRight`), plus the frame's visible
//  rectangle from its DEBUG oracle (`TakesCalloutFrameGeometry`, the seam
//  commit — the pre-fix frame reports it too), so both trees answer the same
//  questions. RED ON OLD is verified by the behavioural revert (the fix's
//  production files restored to the pin commit, this file at HEAD): the
//  position lines fail there by 5 pt and 10 pt in every arm, and at the
//  card-threshold arm the comment face's rung (the gutter's width — the fix's
//  second reader, `TakesBoardView.commentGutter`) fails too; the frame lines
//  are the guard (green on both — the visible frame is kept, only the prose
//  stops moving).
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

/// One tall paragraph — both blocks carry the same shape of prose, so their
/// panes are directly comparable.
nonisolated private func calloutProse(_ tag: String) -> String {
    (1...6).map { i in
        "\(tag), sentence \(i): honest prose on the measured line, long enough "
            + "that the paragraph wraps"
    }.joined(separator: " ") + "."
}

@MainActor
private func calloutPump(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func calloutSettle(
    _ window: NSWindow, _ hosting: NSView,
    until predicate: () -> Bool, maxTurns: Int = 60
) async {
    for _ in 0..<maxTurns {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        calloutPump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(20))
        if predicate() { return }
    }
}

@MainActor
private func calloutPanes(in view: NSView) -> [PaneTextView] {
    var found: [PaneTextView] = []
    if let pane = view as? PaneTextView { found.append(pane) }
    for sub in view.subviews { found.append(contentsOf: calloutPanes(in: sub)) }
    return found
}

@MainActor
private func calloutCards(in view: NSView) -> [CommentCardView] {
    var found: [CommentCardView] = []
    if let card = view as? CommentCardView { found.append(card) }
    for sub in view.subviews { found.append(contentsOf: calloutCards(in: sub)) }
    return found
}

@MainActor
private func articlePane(variant: String, in view: NSView) -> PaneTextView? {
    calloutPanes(in: view).first { $0.identifier?.rawValue == "pane:article|\(variant)" }
}

/// A pane's prose column in WINDOW coordinates: (left edge, right edge, width).
@MainActor
private func prose(_ pane: PaneTextView) -> (left: CGFloat, right: CGFloat, width: CGFloat) {
    let left = pane.convert(NSPoint(x: pane.proseLeft, y: 0), to: nil).x
    let right = pane.convert(NSPoint(x: pane.proseRight, y: 0), to: nil).x
    return (left, right, right - left)
}

@MainActor
@Suite("VX-782 — a callout frame never moves the Takes prose (the one law, pinned on the board)", .serialized)
struct TakesCalloutOneLawTests {
    /// The arms: the frame wraps the row in every style, so the closed row,
    /// an open stack fan (its cards below the article cell) and an open margin
    /// grid (the engaged rail inside the frame) are each asked — at 1600 pt,
    /// room for an engaged rail beside the 680 column, so both rows keep the
    /// full column and the only difference between them is the frame. The
    /// fourth arm sits the board AT THE CARD THRESHOLD (958 pt: the gutter's
    /// `textLeft` is 147 — three points under Write's 150-pt card rung), where
    /// a gutter that still counted the old 5-pt pad would seat a CARD on the
    /// framed row and a badge on the plain one: the comment face's rung is the
    /// second reader's discriminator (`TakesBoardView.commentGutter`).
    enum Arm: String, CaseIterable, Sendable, CustomTestStringConvertible {
        case stackClosed, stackOpen, marginGridOpen, stackClosedAtTheCardThreshold
        var style: FanStyle { self == .marginGridOpen ? .marginGrid : .stack }
        var open: Bool { self == .stackOpen || self == .marginGridOpen }
        var boardWidth: CGFloat { self == .stackClosedAtTheCardThreshold ? 958 : 1600 }
        var testDescription: String { rawValue }
    }

    @Test(arguments: Arm.allCases)
    func aFramedBlocksProseStartsAndMeasuresExactlyAsAPlainBlocks(_ arm: Arm) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let suiteName = "TakesCalloutOneLaw-\(UUID().uuidString)"
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 782))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            try ops.setThemeVoice(.terminal)
            try ops.setFanStyle(arm.style)
            let post = try ops.createPost(title: "callout one-law fixture")
            // Block 1 — FRAMED, fanned (a second take, so the open arms bloom).
            let framed = try ops.newBlock(in: post.id, text: calloutProse("The framed block"))
            let spare = try ops.branchVariant(framed.block.id, from: framed.variant.id)
            let spareText = calloutProse("The framed block's other take")
            try ops.autosave(spare.id, text: spareText, charDelta: spareText.count)
            try ops.setBlockPresentation(
                framed.block.id, BlockPresentation(color: "violet", emoji: "★"))
            // …and a comment, so the row's gutter face (placed from the
            // board's `commentGutter`, the fix's second reader) is drawn.
            _ = try ops.addBlockComment(to: framed.block.id, text: "Keep the frame, move nothing.")
            // Block 2 — PLAIN, the same shape of prose.
            let plain = try ops.newBlock(in: post.id, text: calloutProse("The plain block"))
            // …commented too: its card is the second reader's measuring stick
            // (both rows' cards are placed from one board width, so a legacy
            // scroller's offset moves both alike).
            _ = try ops.addBlockComment(to: plain.block.id, text: "The plain block's note.")
            _ = try ops.newBlock(in: post.id, text: "A short closing line.")

            let model = TakesViewModel(session: session, postID: post.id, defaults: defaults)
            model.adopt(try await db.read { [postID = post.id] in
                try Queries.takesProjection($0, post: postID)
            })
            #expect(model.calloutFrame(framed.block.id) != nil, "fixture: block 1 wears a callout frame")
            #expect(model.calloutFrame(plain.block.id) == nil, "fixture: block 2 is plain")
            if arm.open { model.toggleExpanded(framed.block.id) }

            let scope = session.debugProbeScope
            TakesCalloutFrameGeometry.reset(scope)
            let width = arm.boardWidth
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: width, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: TakesBoardView(
                session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 900)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            // The board's live comment feed, delivered as its `.task` would
            // (`TakesViewModel.observeComments`'s own read).
            model.commentFeed.adopt(try await db.read { [postID = post.id] db in
                try Queries.containerComments(db, containerID: postID).mapValues { comments in
                    comments.map { BlockDecor.CommentBrief(id: $0.id, text: $0.text) }
                }
            })
            await calloutSettle(window, hosting, until: {
                articlePane(variant: framed.variant.id, in: hosting) != nil
                    && calloutCards(in: hosting).contains { $0.identity == framed.block.id }
                    && calloutCards(in: hosting).contains { $0.identity == plain.block.id }
                    && articlePane(variant: plain.variant.id, in: hosting) != nil
                    && TakesCalloutFrameGeometry.frame(blockID: framed.block.id, in: scope) != nil
            })
            await calloutSettle(window, hosting, until: { false }, maxTurns: 8)

            let framedPane = try #require(articlePane(variant: framed.variant.id, in: hosting),
                                          "\(arm): the framed block's article pane is drawn")
            let plainPane = try #require(articlePane(variant: plain.variant.id, in: hosting),
                                         "\(arm): the plain block's article pane is drawn")
            let withFrame = prose(framedPane)
            let without = prose(plainPane)

            // THE LAW (red on the pre-fix tree: 5 pt and 10 pt).
            #expect(abs(withFrame.left - without.left) < 0.5,
                    """
                    \(arm): the framed block's prose starts where the plain block's does \
                    (\(withFrame.left) vs \(without.left))
                    """)
            #expect(abs(withFrame.width - without.width) < 0.5,
                    "\(arm): …at the same measure (\(withFrame.width) vs \(without.width))")

            // THE GUARD (green on both trees): the frame is still DRAWN, around
            // the prose — its colour reaches past the text on both sides by at
            // least the frame's pad, and the plain block wears none.
            let frame = try #require(
                TakesCalloutFrameGeometry.frame(blockID: framed.block.id, in: scope),
                "\(arm): the framed block's callout frame is drawn")
            #expect(frame.minX <= withFrame.left - TakesCalloutFrame.pad + 0.5,
                    "\(arm): the frame's colour starts left of the text (\(frame.minX) vs \(withFrame.left))")
            #expect(frame.maxX >= withFrame.right + TakesCalloutFrame.pad - 0.5,
                    "\(arm): …and ends right of it (\(frame.maxX) vs \(withFrame.right))")
            #expect(TakesCalloutFrameGeometry.frame(blockID: plain.block.id, in: scope) == nil,
                    "\(arm): a plain block wears no frame")

            // THE SECOND READER. (a) A guard: the framed row's comment face
            // stands exactly as far short of ITS prose as the plain row's does
            // of its own — green on both trees wherever both rows take the
            // same rung (the 1600-pt arms: a face is placed relative to its
            // row, so the gutter's width input does not move it there); at the
            // threshold arm the pre-fix tree's rungs differ, so it reds there.
            let framedCard = try #require(
                calloutCards(in: hosting).first { $0.identity == framed.block.id },
                "\(arm): the framed block's comment face is drawn")
            let plainCard = try #require(
                calloutCards(in: hosting).first { $0.identity == plain.block.id },
                "\(arm): the plain block's comment face is drawn")
            let framedGap = withFrame.left - framedCard.convert(framedCard.bounds, to: nil).maxX
            let plainGap = without.left - plainCard.convert(plainCard.bounds, to: nil).maxX
            #expect(abs(framedGap - plainGap) < 0.5,
                    """
                    \(arm): the framed row's comment card stands as far from its prose as the \
                    plain row's does (\(framedGap) vs \(plainGap))
                    """)
            #expect(framedGap > 0, "\(arm): …left of the prose, in the gutter (\(framedGap))")
            // (b) The discriminator: the gutter's WIDTH — the ladder's input —
            // is a plain row's, so the two rows' faces take the same rung.
            // Red on the pre-fix tree at the threshold arm (the framed row's
            // content really sat 5 pt right, its gutter 5 pt wider: a card
            // beside the plain row's badge), and red on a fix that moved the
            // content but left `commentGutter` adding the pad.
            let faces = BoardCommentFaceOracle.reader(scope, board: model)
            let framedKind = faces.face(framed.block.id)?.kind
            let plainKind = faces.face(plain.block.id)?.kind
            #expect(framedKind != nil && framedKind == plainKind,
                    """
                    \(arm): a framed row's comment face takes the plain row's rung \
                    (framed \(framedKind.map { "\($0)" } ?? "none"), plain \(plainKind.map { "\($0)" } ?? "none"))
                    """)
            if arm == .stackClosedAtTheCardThreshold {
                #expect(plainKind == .badge,
                        "fixture: the board sits under the card rung (the plain row's gutter seats the badge)")
            }
        }
    }
}

#endif
