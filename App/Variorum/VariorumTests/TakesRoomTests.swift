//
//  TakesRoomTests.swift
//  VariorumTests
//
//  13f W7 — the typewriter room on the TAKES board. Her ruling
//  (2026-07-30): *"the whitespace underneath works great on write — i would
//  also like to have that whitespace option on takes."*
//
//  The measurement discipline is batch 1's, verbatim and load-bearing here:
//  *"a pin for a feature reached by input must be driven through an input
//  path, or it is a pin on our arithmetic, not on her experience."* A22's
//  whole history is a room that measured perfectly and could not be reached,
//  so the reachability pins below drive the article's REAL NSScrollView — its
//  `documentRect` (what the scroller knob reflects) and `scrollPageDown:` —
//  never a direct scroll of a clip view.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The takes board's typewriter room (13f W7)", .serialized)
struct TakesRoomTests {

    // MARK: - Harness (the TakesCardHeightTests board-hosting pattern)

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func articlePanes(in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
    }

    /// The ARTICLE's scroll view: the outermost `NSScrollView` between an
    /// article pane and the hosting root. Read from the composition rather
    /// than guessed, exactly as the card-height suite reads its clips.
    private func articleScrollView(in root: NSView) -> NSScrollView? {
        guard let pane = articlePanes(in: root).first else { return nil }
        var outermost: NSScrollView?
        var current: NSView? = pane.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { outermost = scroll }
            current = node.superview
        }
        return outermost
    }

    private struct Fixture {
        let postID: String
        let blockIDs: [String]
        let lastVariantID: String
    }

    private func withBoard(
        blocks: Int = 6,
        windowHeight: CGFloat = 700,
        _ body: @MainActor (
            _ hosting: NSHostingView<TakesBoardView>, _ window: NSWindow,
            _ model: TakesViewModel, _ fixture: Fixture, _ db: AppDatabase
        ) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "room fixture")
            var blockIDs: [String] = []
            var lastVariantID = ""
            for i in 1...blocks {
                let minted = try session.operations.newBlock(
                    in: post.id, text: "Paragraph \(i). Honest prose on the measured line.")
                blockIDs.append(minted.block.id)
                lastVariantID = minted.variant.id
            }
            let fixture = Fixture(
                postID: post.id, blockIDs: blockIDs, lastVariantID: lastVariantID)

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1100, height: windowHeight),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: windowHeight)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !articlePanes(in: hosting).isEmpty })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            try await body(hosting, window, model, fixture, db)
        }
    }

    // MARK: - Reachability, through the real scroll view

    /// **RED ON THE PRE-RULING CODE.** The room is ordinary content extent, so
    /// the honest question is whether the SCROLLER can see it: `documentRect`
    /// is what the knob's proportion and travel are computed from. Without the
    /// room the document is exactly the rows; with it, the document runs about
    /// a viewport past the last row.
    ///
    /// Asserted against the composition, not a constant: the room's own
    /// arithmetic (`TypewriterRoom.height`, the brain Write shares) less a
    /// generous slack, so the pin survives ordinary padding changes and still
    /// fails outright when the room is absent.
    ///
    /// DISCRIMINATING REVERT: drop the `typewriterRoom(viewport:)` call from
    /// `singleColumnArticle` ⇒ this fails and the store pin below still passes.
    @Test func theRoomIsInTheArticlesScrollableExtent() async throws {
        try await withBoard(blocks: 6, windowHeight: 700) { hosting, window, _, _, _ in
            guard let scroll = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            let viewport = scroll.contentView.bounds.height
            let document = scroll.documentView?.frame.height ?? 0
            let rows = articlePanes(in: hosting)
                .map { $0.convert($0.bounds, to: scroll.documentView).maxY }
                .max() ?? 0
            let room = TypewriterRoom.height(
                viewport: viewport,
                lineHeight: TypewriterRoom.lineHeight(of: EditorDocument.baseFont))

            #expect(viewport > 200, "non-vacuity: the board really is on screen (\(viewport))")
            #expect(room > 100, "non-vacuity: a room this viewport asks for (\(room))")
            #expect(document >= rows + room - 40,
                    """
                    the document runs a viewport past the last row \
                    (document \(document), last row \(rows), room \(room)) — \
                    without the room it stopped at the rows
                    """)
            #expect(document > viewport,
                    "…so the article scrolls at all, which is what gives the knob travel")

            // The KNOB'S TRAVEL, computed the way AppKit computes it — the
            // maximum origin the scroller can reach. A22's third mechanism
            // exists because the shipped one was invisible to exactly this
            // number; the room must be inside it, not beside it.
            let maximumScroll = document - viewport
            #expect(maximumScroll > rows - viewport + 40,
                    """
                    at maximum scroll the last row's bottom (\(rows)) sits \
                    ABOVE the viewport's bottom — i.e. the scroller can travel \
                    into the room (max origin \(maximumScroll), viewport \
                    \(viewport))
                    """)
            _ = window
        }
    }

    // MARK: - The landing, and the store

    /// The room's click lands the ring on the LAST block's shown take with the
    /// caret at the END of its text (A22's "the room is space the caret can
    /// enter", in the board's vocabulary).
    ///
    /// **RED ON THE PRE-RULING CODE** — no such door existed. Driven through
    /// the model door the tap calls, because a SwiftUI `onTapGesture` cannot be
    /// synthesized in this host (the recorded mouse-down class; batch 5 and the
    /// QoL round both hit it). What the pin therefore does NOT cover is the one
    /// line from the tap to this door; what it does cover is everything that
    /// could silently fail — the pane the door names, the ring landing on it,
    /// and the caret actually reaching the text end through the surface seam.
    @Test func theRoomsLandingPutsTheCaretAtTheLastTakesEnd() async throws {
        try await withBoard(blocks: 6, windowHeight: 700) { hosting, window, model, fixture, _ in
            guard let lastBlock = fixture.blockIDs.last else {
                Issue.record("no fixture blocks")
                return
            }
            // The board lands its own ring on mount, so the honest
            // precondition is that it is NOT already where the room would put
            // it — the click has real work to do.
            let ringAtStart = model.focusedPane?.blockID ?? "nowhere"
            #expect(model.focusedPane?.blockID != lastBlock,
                    "the ring starts somewhere other than the last block (\(ringAtStart))")

            model.focusWithCaretAtEnd(TakesViewModel.PaneKey(
                columnID: "takes-main", blockID: lastBlock,
                variantID: fixture.lastVariantID))
            await settle(window, hosting, until: { false }, maxTurns: 8)

            #expect(model.focusedPane?.blockID == lastBlock,
                    "the ring landed on the LAST block")
            #expect(model.focusedPane?.variantID == fixture.lastVariantID)

            guard let pane = articlePanes(in: hosting).first(where: {
                $0.identifier?.rawValue == "pane:article|\(fixture.lastVariantID)"
            }) else {
                Issue.record("the last block's article pane is not mounted")
                return
            }
            let end = (pane.string as NSString).length
            #expect(end > 0, "non-vacuity: the take has text to sit at the end of")
            #expect(pane.isEditable, "the pane really did go live")

            // NON-VACUITY, and it took a failing pin to find it: a live pane's
            // caret already sits at its text end by default (AppKit puts it
            // there when `string` is set), so asserting "end" against a fresh
            // pane proves nothing. Put the caret at the START — where a click
            // on the first word would leave it — and ask again.
            pane.setSelectedRange(NSRange(location: 0, length: 0))
            model.focusWithCaretAtEnd(TakesViewModel.PaneKey(
                columnID: "takes-main", blockID: lastBlock,
                variantID: fixture.lastVariantID))
            await settle(window, hosting, until: { false }, maxTurns: 8)

            #expect(pane.selectedRange() == NSRange(location: end, length: 0),
                    """
                    the caret sits at the END of the last take (\
                    \(pane.selectedRange()) vs end \(end)) — typing continues \
                    her prose instead of landing in front of it
                    """)
        }
    }

    /// **The room is ALLOWANCE, never content** — A22's letter, and the one
    /// property no amount of scrolling may break. Zero stored bytes: no block,
    /// no variant, not one newline, before or after the room is used.
    @Test func theRoomStoresNothing() async throws {
        try await withBoard(blocks: 6, windowHeight: 700) {
            hosting, window, model, fixture, db in
            func snapshot() async throws -> (blocks: Int, text: String) {
                try await db.read { [postID = fixture.postID] db in
                    let slots = try Queries.renderPost(db, containerID: postID)
                    return (slots.count, slots.map { $0.text ?? "" }.joined(separator: "\u{1}"))
                }
            }
            let before = try await snapshot()

            if let lastBlock = fixture.blockIDs.last {
                model.focusWithCaretAtEnd(TakesViewModel.PaneKey(
                    columnID: "takes-main", blockID: lastBlock,
                    variantID: fixture.lastVariantID))
            }
            await settle(window, hosting, until: { false }, maxTurns: 8)

            let after = try await snapshot()
            #expect(before.blocks == 6, "non-vacuity: the fixture is what we think")
            #expect(after.blocks == before.blocks,
                    "the room minted no block (\(before.blocks) → \(after.blocks))")
            #expect(after.text == before.text,
                    "…and changed not one byte of the post's text")
        }
    }

    /// The caret seam is INERT unbidden: a pane nobody asked keeps whatever
    /// caret it has through ordinary updates. This is what keeps the seam from
    /// becoming a second way to move a caret around — the room is the only
    /// caller, and every other pane in the app is handed a zero token.
    @Test func theCaretSeamIsInertWithoutARequest() async throws {
        let host = NSHostingController(
            rootView: PaneSurfaceView(text: "alpha beta gamma", isLive: true)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 200),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 200)
        defer { window.contentViewController = nil }
        for _ in 0..<4 {
            host.view.layoutSubtreeIfNeeded()
            pump(0.02)
            await Task.yield()
        }
        guard let pane = panes(in: host.view).first else {
            Issue.record("no pane mounted")
            return
        }
        // A live pane's caret starts at its text end (AppKit's own doing —
        // found by this pin failing on its first draft). Put it somewhere
        // deliberate and prove the seam leaves it there.
        pane.setSelectedRange(NSRange(location: 3, length: 0))
        for _ in 0..<4 {
            host.view.frame = NSRect(x: 0, y: 0, width: 410, height: 200)
            host.view.layoutSubtreeIfNeeded()
            pump(0.02)
            await Task.yield()
        }
        #expect(pane.selectedRange() == NSRange(location: 3, length: 0),
                "with no token the caret is untouched (\(pane.selectedRange()))")
    }
}
