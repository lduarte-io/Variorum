//
//  ProseGutterTests.swift
//  VariorumTests
//
//  **13u3 UNIT A1 — THE ONE LAW, PINNED.** Her ruling (the master plan's
//  item 20 / R-13u-9, 2026-09-14, verbatim): *"I approved comments moving
//  all of the text to the right but now that I see it, I think it's ugly and
//  weirdly spaced. I think comments need to make use of the whitespace
//  gutter and should never have an impact on moving the actual text around -
//  same with callouts."*
//
//  **THE LAW:** the prose column's MEASURE and LEFT EDGE are decided by the
//  surface's width and NOTHING ELSE. A comment, a count badge, a callout
//  wash, a callout glyph — none of them may move either, on any surface,
//  ever.
//
//  ── THIS FILE SUPERSEDES `BlockDecorLaneTests` ───────────────────────────
//  Every cell of 17p batch b's lane suite is carried here, re-verdicted by
//  the ruling that retired the lane (the record's pin table names each one):
//  the lane's arrive/release cells become the law's byte-identity cells; the
//  "reserving the lane says so" and "the first laneless ask" cells become
//  `theGutterMovesOnlyWithTheSurfacesOwnWidth` (there is no ask left to
//  make); the lane's TRIGGER cell (`needsLane`) is retired by ruling — no
//  trigger exists; the two production-loop cells INVERT (a comment arriving
//  must now move NOTHING), and that inversion is the red-on-old pin for the
//  whole rework.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The prose gutter — the one law (13u3 UNIT A1)", .serialized)
struct ProseGutterTests {
    // MARK: - The rule itself

    /// **THE PLACEMENT IS A PURE FUNCTION OF THE SURFACE'S WIDTH**, and at
    /// every width it puts the prose exactly where the host's own
    /// clamp-then-inset put it. Both halves matter: the first is the law, the
    /// second is why heights, `BookHeightManifest` and `SurfaceSizeMemory`
    /// need to learn nothing.
    ///
    /// The three conversions, as arithmetic (the record's host table):
    /// - the book OUTLINE centres `BookView.proseColumn` in a 20 pt-padded
    ///   pane, so the surface absorbs BOTH and lands on Write's own rule;
    /// - the spread book's PAGE leading-anchors the same column after 20 pt
    ///   of padding, so its floor is 28 and its column is the cap;
    /// - the workspace PANE and the note window never capped at all, so
    ///   their column stays the pane's measure and only the padding becomes
    ///   gutter.
    @Test func theProseColumnIsAPureFunctionOfTheSurfacesWidth() {
        let column = BookView.proseColumn            // 696 = 680 + 2 × 8
        let inset = EditorTypography.inlineSurfaceInset  // 8
        let max = EditorTypography.maxColumnWidth    // 680

        for pane in [420.0, 600, 696, 700, 730, 736, 760, 900, 1000, 1441] as [CGFloat] {
            // ── the book Outline ────────────────────────────────────────
            // TODAY: the pane is padded 20, two flexible margins centre a
            // `min(pane − 40, 696)` column, the surface insets 8.
            let hostColumn = Swift.min(pane - 40, column)
            let wasLeft = (pane - hostColumn) / 2 + inset
            let wasMeasure = Swift.max(0, hostColumn - 2 * inset)
            // NOW: the frame spans the pane and carries Write's own rule.
            let outline = ProseGutter.outline(bleed: Swift.max(20, (pane - column) / 2))
            let now = outline.insets(viewWidth: hostColumn + 2 * outline.bleed)
            #expect(hostColumn + 2 * outline.bleed == pane,
                    "the bleed reaches the pane's edges exactly at \(pane)")
            #expect(abs(now.leading - wasLeft) <= 0.5,
                    "Outline left edge at \(pane): \(now.leading) vs \(wasLeft)")
            #expect(abs(outline.columnWidth(viewWidth: pane) - wasMeasure) <= 0.5,
                    "Outline measure at \(pane): \(outline.columnWidth(viewWidth: pane)) vs \(wasMeasure)")

            // ── the spread book's page ──────────────────────────────────
            // TODAY: 20 pt padding, then a leading-anchored `min(pane − 40,
            // 696)` column, then the surface's 8.
            let pageWas = (left: 20 + inset, measure: Swift.max(0, hostColumn - 2 * inset))
            let pageView = hostColumn + 2 * ProseGutter.page.bleed
            let pageNow = ProseGutter.page.insets(viewWidth: pageView)
            #expect(abs(pageNow.leading - pageWas.left) <= 0.5,
                    "page left edge at \(pane): \(pageNow.leading) vs \(pageWas.left)")
            #expect(abs(ProseGutter.page.columnWidth(viewWidth: pageView) - pageWas.measure) <= 0.5,
                    "page measure at \(pane): \(ProseGutter.page.columnWidth(viewWidth: pageView)) vs \(pageWas.measure)")

            // ── the workspace pane / the note window ────────────────────
            // TODAY: 20 pt padding, no cap at all, then the surface's 8.
            let paneWas = (left: 20 + inset, measure: Swift.max(0, pane - 40 - 2 * inset))
            let paneNow = ProseGutter.pane.insets(viewWidth: pane)
            #expect(paneNow.leading == paneWas.left,
                    "workspace left edge at \(pane): \(paneNow.leading) vs \(paneWas.left)")
            #expect(abs(ProseGutter.pane.columnWidth(viewWidth: pane) - paneWas.measure) <= 0.5,
                    "workspace measure at \(pane): \(ProseGutter.pane.columnWidth(viewWidth: pane)) vs \(paneWas.measure)")

            // ── Write itself, unmoved ───────────────────────────────────
            #expect(ProseGutter.write.insets(viewWidth: pane).leading
                == EditorTypography.gutterInset(viewWidth: pane),
                    "Write's own rule at \(pane)")
            _ = max
        }
    }

    /// **THE GUTTER MOVES ONLY WITH THE SURFACE'S OWN WIDTH** — the
    /// successor to the lane's `reservingTheLaneSaysSoSoTheDecorationsAre
    /// ComputedAgain` and `theFirstLanelessAskReportsNoMovement`: there is no
    /// ask left to make, because the geometry has no input but the width.
    @Test func theGutterMovesOnlyWithTheSurfacesOwnWidth() {
        var placement = ProseGutterPlacement()
        // Never laid out: nothing is claimed.
        #expect(!placement.isPlaced)
        #expect(placement.place(gutter: .write, viewWidth: 0) == nil,
                "a zero-width view keeps the inset its factory gave it")
        #expect(!placement.isPlaced)
        // A real width places once…
        #expect(placement.place(gutter: .write, viewWidth: 1000) == 160)
        #expect(placement.isPlaced && placement.originX == 160)
        // …and a settled surface writes nothing on every later pass.
        #expect(placement.place(gutter: .write, viewWidth: 1000) == nil)
        #expect(placement.place(gutter: .write, viewWidth: 1000) == nil)
        // A WIDTH change moves it; a narrow one lands on the floor.
        #expect(placement.place(gutter: .write, viewWidth: 1200) == 260)
        #expect(placement.place(gutter: .write, viewWidth: 600)
            == EditorTypography.minGutter)
        // An asymmetric placement rides as the pair's MEAN, unrounded, so
        // the container's WIDTH is exact (the heights stand on it).
        var page = ProseGutterPlacement()
        let mean = page.place(gutter: .page, viewWidth: 1001)
        let insets = ProseGutter.page.insets(viewWidth: 1001)
        #expect(mean == (insets.leading + insets.trailing) / 2)
        #expect(1001 - 2 * (mean ?? 0) == ProseGutter.page.columnWidth(viewWidth: 1001))
        #expect(page.originX == insets.leading)
    }

    /// **THE SWEEP TABLE** (the constitution's closing form for a fixed
    /// class) — the successor to `everyDecoratedSurfaceHasItsLaneAnswered
    /// OneWayOrTheOther`. Every TK2 surface factory answers the one rule,
    /// and every one of them is born where it always was.
    @Test func everyTextSurfaceCarriesTheOneGutterRule() {
        let (_, full) = EditorTextView.makeEditor()
        #expect(full.proseGutter == .write)
        #expect(full.proseGutter.maxColumn == EditorTypography.maxColumnWidth)
        // The two CONTAINED surfaces are born `.contained` — the shipped
        // 8 pt — and their HOST hands them the room it has (the host table).
        #expect(EditorTextView.makeInlineEditor().proseGutter == .contained)
        #expect(PaneTextView.makeReadSurface().proseGutter == .contained)
        // A TAKE pane hosts no decoration controller at all; its shipped
        // 6 pt, through the same rule.
        let take = PaneTextView.makeTakeSurface()
        #expect(take.proseGutter.minGutter == PaneTextView.takeSurfaceInset)
        #expect(take.proseGutter.maxColumn == nil)
        #expect(take.proseGutter.bleed == 0)
    }

    /// The two CONTAINED surfaces place their prose identically — one brain,
    /// so the book Outline's focused note and its expanded-but-unfocused
    /// neighbour cannot disagree about where the text begins (the successor
    /// to `theReadTiersLaneMovesItsProseColumnTheSameWay`).
    @Test func theTwoContainedSurfacesPlaceTheirProseIdentically() {
        let editor = EditorTextView.makeInlineEditor()
        let read = PaneTextView.makeReadSurface()
        for surface in [editor as any ProseGutterSurface, read as any ProseGutterSurface] {
            let view = surface as! NSTextView
            view.frame = NSRect(x: 0, y: 0, width: 1000, height: 400)
            surface.proseGutter = .outline(bleed: 152)
            view.layoutSubtreeIfNeeded()
            #expect(surface.proseLeft == 160, "\(type(of: view)): \(surface.proseLeft)")
            #expect(surface.proseRight == 840, "\(type(of: view)): \(surface.proseRight)")
        }
    }

    /// **A GUTTER-PLACED SURFACE STAYS ON TEXTKIT 2** — the override is not a
    /// downgrade trigger (TEXTKIT2_NOTES §4.2/§4.3: never trust that, measure
    /// it). Driven through a real edit, because the canary fires on API use
    /// and layout alike. (The successor to `aLanedSurfaceStaysOnTextKit2`.)
    @Test func aGutteredSurfaceStaysOnTextKit2() {
        let (view, window) = inlineSurface(width: 1000)
        defer {
            window.orderOut(nil)
            window.close()
        }
        view.proseGutter = .outline(bleed: 152)
        let controller = BlockDecorOverlayController(
            textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
        defer { controller.uninstall() }
        let canary = FallbackCanary()
        canary.arm(for: view)
        defer { canary.disarm() }

        controller.render(state(
            for: view, comment: true,
            presentation: BlockPresentation(color: "sand", emoji: "\u{1f4a1}")))
        view.layoutSubtreeIfNeeded()
        view.insertText("more words ", replacementRange: NSRange(location: 0, length: 0))
        view.layoutSubtreeIfNeeded()
        window.displayIfNeeded()

        #expect(!canary.fired, "no silent fallback (TEXTKIT2_NOTES §4.3)")
        #expect(view.textLayoutManager != nil, "still TK2")
        #expect(view.proseLeft == 160)
        #expect(view.textContainer?.size.width ?? 0 <= EditorTypography.maxColumnWidth + 0.5,
                "the container really is the column: \(view.textContainer?.size ?? .zero)")
    }

    // MARK: - The law, on real surfaces

    /// **THE ONE LAW, PINNED ON EVERY CONTAINED SURFACE KIND:** render the
    /// same note plain, with a comment, with a glyphed callout, and with
    /// both — `textLeft`, `textRight` and EVERY fragment's origin are
    /// byte-identical.
    ///
    /// **RED ON OLD** (17p batch b's tree): a comment or a glyph reserved the
    /// 64 pt lane, so `textLeft` read 8 plain and 72 decorated, and every
    /// fragment's origin moved with it.
    @Test func noDecorationMovesTheProseColumnOnAnySurface() {
        for narrow in [false, true] {
            let width: CGFloat = narrow ? 620 : 1000
            let bleed: CGFloat = narrow ? 20 : 152
            let (view, window) = inlineSurface(width: width)
            defer {
                window.orderOut(nil)
                window.close()
            }
            view.proseGutter = .outline(bleed: bleed)
            view.layoutSubtreeIfNeeded()
            let controller = BlockDecorOverlayController(
                textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
            defer { controller.uninstall() }

            let framed = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
            let baseline = (left: view.proseLeft, right: view.proseRight,
                            origins: fragmentOrigins(of: view))
            #expect(!baseline.origins.isEmpty, "the fixture really laid out")

            for (comment, presentation) in [
                (true, nil), (false, framed), (true, framed),
            ] as [(Bool, BlockPresentation?)] {
                controller.render(state(for: view, comment: comment, presentation: presentation))
                view.layoutSubtreeIfNeeded()
                #expect(view.proseLeft == baseline.left,
                        "at \(width): left moved to \(view.proseLeft)")
                #expect(view.proseRight == baseline.right,
                        "at \(width): right moved to \(view.proseRight)")
                #expect(fragmentOrigins(of: view) == baseline.origins,
                        "at \(width): the text itself moved")
            }
        }
    }

    // MARK: - The production loops (the lane's two cells, INVERTED)

    /// A paragraph long enough that a 64 pt-narrower measure would re-wrap it
    /// by lines — the fixture the lane's own pins used, kept so the inversion
    /// is measured against the same shape.
    private var longParagraph: String {
        (0..<220).map { "word\($0 % 97)" }.joined(separator: " ")
    }

    private func pump(_ window: NSWindow? = nil, until condition: @MainActor () -> Bool) async {
        for _ in 0..<200 {
            if condition() { return }
            window?.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    @MainActor private final class HeightLog {
        var last: CGFloat = 0
    }

    /// **THE READ TIER: A COMMENT ARRIVING MOVES NOTHING** — not the prose,
    /// not the measure, not the published height. Driven through the REAL
    /// wiring (`ReadPostSurfaceCoordinator.install`, the comment written
    /// through the operations layer and delivered by the model's own decor
    /// observation), because that is the loop the lane used to run in.
    ///
    /// **RED ON OLD** (17p batch b's tree): this is the exact inverse of
    /// `theReadTiersLaneReMeasuresItsHeightThroughTheProductionLoop`, which
    /// asserted `measured > before + 10` and `proseLeft == 72`. Both were
    /// true there; both are forbidden here.
    @Test func theReadTiersProseIsUnmovedByACommentThroughTheProductionLoop() async throws {
        try await withReadTier(seedBlocks: [longParagraph, "A second block."]) { h in
            h.textView.frame = NSRect(x: 0, y: 0, width: 1000, height: 400)
            h.textView.proseGutter = .outline(bleed: 152)
            let coordinator = ReadPostSurfaceCoordinator(model: h.model)
            coordinator.install(textView: h.textView)
            defer { coordinator.uninstall() }
            h.model.remeasure()
            let before = h.model.contentHeight
            let left = h.textView.proseLeft
            let measure = h.textView.proseRight - h.textView.proseLeft
            #expect(before > 40, "the harness measured the seeded paragraph: \(before)")
            #expect(left == 160 && measure == EditorTypography.maxColumnWidth,
                    "Write's own column: \(left) / \(measure)")

            let slots = try await h.database.read { try Queries.renderPost($0, containerID: h.postID) }
            _ = try h.session.operations.addBlockComment(
                to: slots[0].blockID, text: "a note in the margin")

            // Wait for the comment to reach the decoration layer — the card
            // is the proof the loop ran at all (non-vacuity).
            await pump {
                h.textView.subviews.contains { $0 is CommentCardView }
            }
            #expect(h.textView.subviews.contains { $0 is CommentCardView },
                    "the comment's face arrived through the observation")
            #expect(h.textView.proseLeft == left,
                    "the prose did not move: \(h.textView.proseLeft) vs \(left)")
            #expect(h.textView.proseRight - h.textView.proseLeft == measure,
                    "the measure did not move")
            #expect(abs(h.model.contentHeight - before) < 0.5,
                    "and the height stood still: \(h.model.contentHeight) vs \(before)")
        }
    }

    /// **THE CONTAINED EDITOR: the same, one host over** — the real
    /// `InlineEditorSurface.Coordinator.install`, its height report captured
    /// exactly as `makeNSView` captures it, the comment adopted through the
    /// model's own door.
    ///
    /// **RED ON OLD**: the inverse of
    /// `theContainedEditorsLaneReReportsItsHeightThroughTheProductionLoop`.
    @Test func theContainedEditorsProseIsUnmovedByACommentThroughTheProductionLoop() async throws {
        try await withInlineEditor(seedBlocks: [longParagraph, "A second block."]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 300),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 1000, height: 300))
            window.contentView = container
            h.textView.frame = NSRect(x: 0, y: 0, width: 1000, height: 300)
            h.textView.proseGutter = .outline(bleed: 152)
            container.addSubview(h.textView)
            let log = HeightLog()
            let coordinator = InlineEditorSurface.Coordinator(model: h.model)
            coordinator.install(textView: h.textView) { height in
                log.last = height
                h.textView.frame = NSRect(x: 0, y: 0, width: 1000, height: height)
            }
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            window.orderFrontRegardless()
            coordinator.remeasure()
            let before = log.last
            let left = h.textView.proseLeft
            #expect(before > 24, "steady state before the comment: \(before)")
            #expect(left == 160, "Write's own column: \(left)")

            let slots = try h.storeSlots()
            h.model.adoptComments([slots[0].blockID: [.init(id: "c1", text: "a note in the margin")]])

            await pump(window) {
                h.textView.subviews.contains { $0 is CommentCardView }
            }
            #expect(h.textView.subviews.contains { $0 is CommentCardView },
                    "the comment's face arrived through the model's door")
            #expect(h.textView.proseLeft == left,
                    "the prose did not move: \(h.textView.proseLeft) vs \(left)")
            #expect(abs(log.last - before) < 0.5,
                    "and the reported height stood still: \(log.last) vs \(before)")
        }
    }

    // MARK: - Fixtures

    /// A real contained (book) editor in a real window.
    private func inlineSurface(width: CGFloat = 1000)
        -> (view: EditorTextView, window: NSWindow)
    {
        let view = EditorTextView.makeInlineEditor()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        view.frame = NSRect(x: 0, y: 0, width: width, height: 400)
        window.contentView?.addSubview(view)
        view.string = "A callout paragraph that carries a comment.\nA second block."
        view.layoutSubtreeIfNeeded()
        return (view, window)
    }

    /// One block's decoration state, built against the surface's OWN prose
    /// column — exactly what `EditorViewModel.sendDecorState` does.
    private func state(
        for view: some ProseGutterSurface, comment: Bool, presentation: BlockPresentation?
    ) -> BlockDecor.State {
        let bounds = (view as! NSView).bounds
        var state = BlockDecor.State()
        state.frames = [
            .init(entryIndex: 0, blockID: "b0",
                  frame: CGRect(x: 0, y: 10, width: bounds.width, height: 34)),
        ]
        state.entryCount = 1
        state.viewWidth = bounds.width
        state.textLeft = view.proseLeft
        state.textRight = view.proseRight
        if comment { state.comments["b0"] = [.init(id: "c1", text: "a note")] }
        if let presentation { state.presentations["b0"] = presentation }
        return state
    }

    /// Every laid-out fragment's origin — "the text itself did not move",
    /// measured rather than argued.
    private func fragmentOrigins(of view: NSTextView) -> [CGPoint] {
        guard let layoutManager = view.textLayoutManager else { return [] }
        var origins: [CGPoint] = []
        layoutManager.enumerateTextLayoutFragments(from: nil, options: [.ensuresLayout]) {
            fragment in
            origins.append(fragment.layoutFragmentFrame.origin)
            return true
        }
        return origins
    }
}
