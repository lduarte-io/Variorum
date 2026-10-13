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

    // MARK: - The gutter's own faces (the lane suite's geometry cells, re-verdicted)

    /// **THE CALLOUT'S WASH HUGS THE PROSE COLUMN** (memo §2 C) — it no
    /// longer extends into either gutter, so the gutter belongs wholly to
    /// the stack and a tint can never read as the old frame-with-a-glyph.
    /// R17's white-gap rule on the VERTICAL axis is untouched.
    ///
    /// The successor to `theCardWidensToHoldItsGlyphAndTheGlyphSitsInside`,
    /// whose whole subject — a card that GREW LEFTWARD to hold its glyph —
    /// is what her ruling retired.
    @Test func theCalloutWashHugsTheProseColumn() {
        let block = CGRect(x: 0, y: 100, width: 400, height: 40)
        let wash = BlockDecor.calloutRect(
            block: block, gapAbove: nil, gapBelow: nil, textLeft: 300, textRight: 700)
        #expect(wash.minX == 300 && wash.maxX == 700, "the prose column exactly: \(wash)")
        // A glyph changes nothing about it (it is the gutter's now).
        #expect(BlockDecor.calloutRect(
            block: block, gapAbove: nil, gapBelow: nil,
            textLeft: 300, textRight: 700) == wash)
        // R17's vertical rule, unmoved.
        let capped = BlockDecor.calloutRect(
            block: block, gapAbove: 8, gapBelow: nil, textLeft: 28, textRight: 428)
        #expect(capped.minY == 99 && capped.height == 46)
        #expect(capped.minX == 28 && capped.maxX == 428)
    }

    /// **THE GLYPH LIVES IN THE GUTTER — and yields before the text does.**
    @Test func theGlyphSitsInTheGutterAndYieldsWhereThereIsNone() throws {
        let glyph = try #require(
            BlockDecor.calloutGlyphRect(textLeft: 300, blockTop: 40))
        #expect(glyph.maxX == 300 - BlockDecor.calloutGlyphAir, "beside the prose")
        #expect(glyph.minX >= BlockDecor.edgeMargin, "inside the page")
        #expect(glyph.minY == 40, "at the block's first line")
        #expect(glyph.size == BlockDecor.calloutGlyphBox)
        // Write's own floor still holds it…
        #expect(BlockDecor.calloutGlyphRect(textLeft: 28, blockTop: 0) != nil)
        // …a contained surface's 8 pt does not, and the glyph YIELDS rather
        // than clamping onto her first characters (memo §3 edge 1).
        #expect(BlockDecor.calloutGlyphRect(textLeft: 8, blockTop: 0) == nil)
        #expect(BlockDecor.calloutGlyphRect(textLeft: 20, blockTop: 0) == nil)
    }

    /// **THE STACK, AT EVERY WIDTH** (her ruling R-13u3-3, verbatim: *"stack
    /// them at any width, I think it would look better."*): the glyph at the
    /// block's first line, the comment face DIRECTLY UNDER it — a card where
    /// the gutter holds one, the badge below that. The successor to
    /// `theCommentFacesYieldTheGutterACalloutCardClaims`, whose horizontal
    /// clearance arithmetic her ruling retired.
    @Test func theStackPutsTheGlyphFirstAndTheCommentFaceUnderIt() throws {
        for textLeft in [300.0, 160, 28] as [CGFloat] {
            let glyph = BlockDecor.calloutGlyphRect(textLeft: textLeft, blockTop: 40)
            let top = BlockDecor.commentFaceTop(blockTop: 40, glyph: glyph)
            #expect(top == (glyph?.maxY ?? 40) + (glyph == nil ? 0 : BlockDecor.decorAir),
                    "at \(textLeft): the face begins under the glyph")
            let face = BlockDecor.gutterFitsCards(width: textLeft)
                ? BlockDecor.leftCardRect(textLeft: textLeft, top: top, blockHeight: 30)
                : BlockDecor.commentBadgeRect(textLeft: textLeft, top: top)
            let rect = try #require(face, "a face at \(textLeft)")
            #expect(rect.minY == top, "at \(textLeft): the face is where the stack says")
            #expect(rect.maxX <= textLeft, "at \(textLeft): never on the prose")
            if let glyph {
                #expect(!rect.intersects(glyph),
                        "at \(textLeft): stacked, never side by side")
            }
        }
        // One decoration alone sits at the first line.
        #expect(BlockDecor.commentFaceTop(blockTop: 40, glyph: nil) == 40)
    }

    /// **THE BADGE YIELDS RATHER THAN STAND ON PROSE** — and where the
    /// gutter holds it whole, it is BYTE-IDENTICAL to what shipped.
    /// *(KnownIssues row 50's first residual — Write at `minGutter` 28 — is
    /// this cell's middle line.)*
    @Test func theBadgeNeverStandsOnProse() {
        // Shipped, unmoved.
        #expect(BlockDecor.commentBadgeRect(textLeft: 60, top: 10)
            == CGRect(x: 24, y: 10, width: 32, height: 16))
        // Write's 28 pt floor: 32 will not fit beside the words, so the
        // badge narrows to the room — it used to clamp at 2 and cover them.
        let floored = BlockDecor.commentBadgeRect(textLeft: EditorTypography.minGutter, top: 0)
        #expect(floored?.width == 22 && floored?.maxX == 24)
        #expect((floored?.maxX ?? .infinity) <= EditorTypography.minGutter)
        // A contained surface's 8 pt is no gutter at all: no face, and the
        // text keeps every point of its measure.
        #expect(BlockDecor.commentBadgeRect(textLeft: 8, top: 0) == nil)
        #expect(BlockDecor.commentBadgeRect(textLeft: 24, top: 0) == nil,
                "below the width that can show a count, no badge")
    }

    /// **TWO COMMENTED BLOCKS' CARDS NEVER ABUT** (memo §2 B's rhythm; her
    /// *"the comments still also aren't spaced well"*).
    @Test func twoCommentedBlocksCardsNeverAbut() throws {
        // Adjacent short blocks, 40 pt apart: the ideal card (30 + 24 = 54)
        // would reach into its neighbour's, so it is clamped.
        let first = try #require(BlockDecor.leftCardRect(
            textLeft: 300, top: 0, blockHeight: 30, roomBelow: 40))
        let second = try #require(BlockDecor.leftCardRect(
            textLeft: 300, top: 40, blockHeight: 30, roomBelow: nil))
        #expect(first.maxY <= second.minY - BlockDecor.cardRhythmAir,
                "the rhythm's air: \(first) vs \(second)")
        // Far apart, nothing is clamped — the shipped card, byte for byte.
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, top: 40, blockHeight: 30, roomBelow: 400)
            == CGRect(x: 62, y: 40, width: 210, height: 54))
        // Too little room to be a card at all ⇒ nil, and the block shows
        // its badge instead (the render's own fallback).
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, top: 0, blockHeight: 30, roomBelow: 20) == nil)
        // …and 27 pt of room — two adjacent one-line commented blocks with a
        // glyph above the first face — still IS a card (the walk's own case).
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, top: 0, blockHeight: 30, roomBelow: 27)?.height == 21)
    }

    /// **VX-179 U2 — THE CARD GROWS TO THE BLOCK** (her ruling R-VX179-2:
    /// the card may grow to the block's own height plus a small pad, still
    /// bounded by the rhythm; a one-line block keeps a small card; the 96 pt
    /// cap retires). Her words behind it: *"sometimes a block is several
    /// paragraphs but the comment is always just one line."*
    ///
    /// **RED ON OLD** (the shipped `ideal = min(blockHeight + 24, 96)`): every
    /// tall-block HEIGHT cell answers 96 there — the 300 pt and 800 pt cards,
    /// the 200 pt rhythm bound (194), the narrow gutter's 500 pt block, and
    /// the one decision's 424 and its rhythm-bounded 404. The rest is green
    /// on both sides BY DESIGN (the parity half: the pad's value, the 17 pt
    /// and 72 pt cards, the floor, the width and x, the never-abut check).
    /// (Red-on-old BY REVERT is PENDING the stage — the app test target is
    /// stage-gated this session; the arithmetic above is the trace.)
    @Test func theCardGrowsToTheBlocksOwnHeightWithinTheRhythm() throws {
        let pad = BlockDecor.cardHeightPad
        #expect(pad == 24, "the shipped pad, kept — the parity claim stands on it")
        // A one-line block keeps a small card (Terminal's one line is 17 pt).
        #expect(BlockDecor.leftCardRect(textLeft: 300, top: 0, blockHeight: 17)?.height == 41)
        // The old cap's own edge, unmoved: 72 + 24 = 96 on both sides.
        #expect(BlockDecor.leftCardRect(textLeft: 300, top: 0, blockHeight: 72)?.height == 96)
        // A tall block's card FOLLOWS the block (red on old: 96, 96).
        let tall = try #require(BlockDecor.leftCardRect(
            textLeft: 300, top: 40, blockHeight: 300, roomBelow: 400))
        #expect(tall == CGRect(x: 62, y: 40, width: 210, height: 300 + pad),
                "x, width and top are the shipped ones; only the height grew: \(tall)")
        #expect(BlockDecor.leftCardRect(textLeft: 300, top: 0, blockHeight: 800)?.height
            == 800 + pad)
        // …still bounded by the rhythm: the next commented block's face
        // 200 pt below leaves 194 (the bound is the shipped line; red on old
        // only because the old ideal, 96, was already under it).
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, top: 0, blockHeight: 800, roomBelow: 200)?.height
            == 200 - BlockDecor.cardRhythmAir)
        // …and still floored: too little room is the badge's, as shipped.
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, top: 0, blockHeight: 800, roomBelow: 20) == nil)
        // The narrow-gutter width rule is untouched by the height change.
        let narrow = try #require(BlockDecor.leftCardRect(
            textLeft: 160, top: 0, blockHeight: 500))
        #expect(narrow.width == 160 - BlockDecor.leftCardLane && narrow.minX == 0)
        #expect(narrow.height == 500 + pad)

        // THE ONE DECISION carries it (the renderer and the ring both ask
        // `commentGutterFaces`): a 400 pt block with a comment gets a 424 pt
        // card (red on old: 96)…
        var state = BlockDecor.State()
        state.textLeft = 300
        state.textRight = 980
        state.frames = [
            .init(entryIndex: 0, blockID: "tall",
                  frame: CGRect(x: 300, y: 10, width: 680, height: 400)),
            .init(entryIndex: 1, blockID: "next",
                  frame: CGRect(x: 300, y: 420, width: 680, height: 17)),
        ]
        state.comments["tall"] = [.init(id: "c1", text: "a note")]
        guard case .card(let card) = BlockDecor.commentGutterFaces(state)["tall"] else {
            Issue.record("a 300-pt gutter holds a card")
            return
        }
        #expect(card.height == 400 + pad, "the card follows the block: \(card)")
        // …and when the NEXT block is commented too, the rhythm bounds it:
        // the neighbour's face begins at 420, so the tall card (ideal 424
        // from its top at 10) stops at 420 − 10 − 6 = 404 (the cards never
        // abut — memo §2 B, untouched; red on old: 96).
        state.comments["next"] = [.init(id: "c2", text: "another")]
        let faces = BlockDecor.commentGutterFaces(state)
        guard case .card(let bounded) = faces["tall"],
              case .card(let below) = faces["next"] else {
            Issue.record("both blocks hold cards: \(faces)")
            return
        }
        #expect(bounded.height == 420 - 10 - BlockDecor.cardRhythmAir)
        #expect(bounded.maxY <= below.minY - BlockDecor.cardRhythmAir)
    }

    /// **NOTHING IN THE GUTTER EVER COVERS PROSE** — mounted, at a wide
    /// window and at Write's own floor, over all four decoration
    /// combinations. The successor to
    /// `aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither` and
    /// `theLaneHoldsAtANarrowBookColumnToo`, which proved the same thing by
    /// MOVING the text.
    ///
    /// **RED ON OLD** (17p batch b's tree, with the lane defeated — which is
    /// what a contained surface at 8 pt was before the lane existed): the
    /// badge sat at [2, 34] and the glyph at [6, 24] inside a prose column
    /// starting at 8.
    @Test func nothingInTheGutterEverCoversProse() {
        for gutter in [ProseGutter.outline(bleed: 152), ProseGutter.pane] {
            for width in [1000.0, 760, 620] as [CGFloat] {
                let (view, window) = inlineSurface(width: width)
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                view.proseGutter = gutter
                view.layoutSubtreeIfNeeded()
                let controller = BlockDecorOverlayController(
                    textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
                defer { controller.uninstall() }
                let framed = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
                let settled = state(for: view, comment: true, presentation: framed)
                controller.render(settled)
                view.layoutSubtreeIfNeeded()

                let prose = CGRect(
                    x: settled.textLeft, y: settled.frames[0].frame.minY,
                    width: Swift.max(0, settled.textRight - settled.textLeft),
                    height: settled.frames[0].frame.height)
                let faces = view.subviews.filter {
                    !$0.isHidden && ($0 is CommentCardView || $0 is NSTextField)
                }
                for face in faces {
                    #expect(face.frame.maxX <= prose.minX + 0.01,
                            "\(gutter.minGutter)@\(width): \(type(of: face)) \(face.frame) reaches \(prose)")
                }
                // The WASH is the one decoration that may sit behind prose —
                // it is a background, and it hugs the column exactly.
                for wash in view.subviews.compactMap({ $0 as? DecorRectView }) {
                    #expect(wash.frame.minX >= settled.textLeft - 0.01
                        && wash.frame.maxX <= settled.textRight + 0.01,
                            "the wash hugs: \(wash.frame) vs \(prose)")
                }
            }
        }
    }

    // MARK: - The one-grapheme guard (her ruling R-13u3-4)

    /// **ONE GRAPHEME, AT THE DOOR AND AT THE RENDERER** — her ruling
    /// R-13u3-4, which dissolves KnownIssues row 50's second residual (a
    /// multi-glyph answer CLIPPING inside the fixed box) by deciding what a
    /// leading glyph is rather than growing the box.
    ///
    /// **RED ON OLD** (behavioral revert, verified): with
    /// `CalloutMenu.promptEmoji` returning `field.stringValue` and
    /// `renderCallouts` drawing `presentation.emoji`, a "🔥🔥🔥" answer was
    /// stored and drawn whole into an 18 pt box.
    @Test func aLeadingGlyphIsExactlyOneGrapheme() {
        // The DOOR keeps the first, trims, and leaves "no glyph" alone.
        #expect(CalloutMenu.firstGrapheme("\u{1f525}\u{1f525}\u{1f525}") == "\u{1f525}")
        #expect(CalloutMenu.firstGrapheme("  \u{1f4a1} ") == "\u{1f4a1}")
        #expect(CalloutMenu.firstGrapheme("") == "")
        #expect(CalloutMenu.firstGrapheme("   ") == "")
        // A grapheme CLUSTER is one glyph: a family, a skin tone, a flag.
        #expect(CalloutMenu.firstGrapheme("\u{1f469}\u{200d}\u{1f467}\u{200d}\u{1f466}x")
            == "\u{1f469}\u{200d}\u{1f467}\u{200d}\u{1f466}")
        #expect(CalloutMenu.firstGrapheme("\u{1f44d}\u{1f3fd}\u{1f44d}") == "\u{1f44d}\u{1f3fd}")
        #expect(CalloutMenu.firstGrapheme("\u{1f1e8}\u{1f1e6}\u{1f1e8}\u{1f1e6}")
            == "\u{1f1e8}\u{1f1e6}")
        // The RENDERER keeps the first of whatever is STORED — a value
        // typed before this guard, or one arriving from another device.
        #expect(BlockDecor.leadingGlyph(
            BlockPresentation(color: "sand", emoji: "\u{1f525}\u{1f525}\u{1f525}"))
            == "\u{1f525}")
        #expect(BlockDecor.leadingGlyph(BlockPresentation(color: "sand", emoji: "")) == nil)
        #expect(BlockDecor.leadingGlyph(BlockPresentation(color: "sand")) == nil)
        #expect(BlockDecor.leadingGlyph(nil) == nil)
        // A glyph on a NON-callout presentation is not a callout glyph.
        #expect(BlockDecor.leadingGlyph(
            BlockPresentation(kind: "future", emoji: "\u{1f4a1}")) == nil)
        #expect(!BlockDecor.hasLeadingGlyph(
            BlockPresentation(kind: "future", emoji: "\u{1f4a1}")))
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
