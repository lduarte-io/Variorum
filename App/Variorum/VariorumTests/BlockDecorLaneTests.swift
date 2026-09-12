//
//  BlockDecorLaneTests.swift
//  VariorumTests
//
//  **17p batch b, rows 5–6 — THE DECORATION LANE AND THE GLYPH INSIDE ITS
//  FRAME.** Her report, verbatim: *"the callout goes on top of the comment
//  badge which is on top of the text. not good it should move it. and in book
//  view the comment thing needs to be moved or only accessible on the left
//  because it's blocking the text"* (images 10, 11). Her ruling **R-Q4** —
//  *"Reserve a left lane; emoji inside the frame"*: the book's editor reserves
//  room on the LEFT whenever the note carries a comment or a callout glyph;
//  the badge sits in the lane; the glyph moves inside the callout frame's
//  leading inset; nothing covers text; comments stay on the left.
//
//  ── THE TRACED MECHANISM ─────────────────────────────────────────────────
//  A CONTAINED (book) editor's prose starts `EditorTypography
//  .inlineSurfaceInset` = 8 pt from its own left edge, and both left-margin
//  decorations place themselves LEFT of that edge and clamp at 2:
//     the count badge at `max(2, textLeft - 36)`, 32 wide → [2, 34]
//     the callout glyph at `max(2, textLeft - width - 8)` → [2, 2 + width]
//  With `textLeft == 8` both sit ON the first characters and ON each other.
//  In Write the gutter is wide, so the badge and glyph land in the margin —
//  but the glyph landed OUTSIDE its own card there too (`calloutRect`'s
//  leading edge is `textLeft - 12`, the glyph's was `textLeft - width - 8`),
//  which is the *"the callout goes on top of the comment badge"* half at any
//  width: a card and a badge both aiming at the same corner collide.
//
//  ── WHAT IS PINNED HERE ──────────────────────────────────────────────────
//  · the lane is reserved, and RELEASED, by the note's own decorations, and
//    only on the surface that opts in (`reservesDecorLane`);
//  · the trailing inset never moves (the measure narrows by the lane — the
//    margins stay sacred, R9);
//  · badge, glyph and prose are pairwise DISJOINT in a laned surface (the
//    red-on-old pin);
//  · Write's margin card and a plain callout's card are BYTE-IDENTICAL to
//    what shipped (the parity claim: this batch may not move Write's faces);
//  · a laned surface stays on TextKit 2 — the fallback canary is silent
//    (overriding `textContainerOrigin` is not a TK1 API, TEXTKIT2_NOTES §4,
//    but "not a downgrade trigger" is a claim that must be measured).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The decoration lane and the glyph in its frame (17p batch b, rows 5–6)", .serialized)
struct BlockDecorLaneTests {
    /// A real contained (book) editor in a real window — the surface whose
    /// prose starts 8 pt in, which is the surface the rows are about.
    private func inlineSurface(width: CGFloat = 620)
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
    /// column — which is exactly what `EditorViewModel.sendDecorState` does
    /// (`textView.proseLeft` / `proseRight`), so the pin reads the production
    /// geometry rather than a guessed pair of numbers.
    private func state(
        for view: EditorTextView, comment: Bool, presentation: BlockPresentation?
    ) -> BlockDecor.State {
        var state = BlockDecor.State()
        state.frames = [
            .init(entryIndex: 0, blockID: "b0",
                  frame: CGRect(x: 0, y: 10, width: view.bounds.width, height: 34)),
        ]
        state.entryCount = 1
        state.viewWidth = view.bounds.width
        state.textLeft = view.proseLeft
        state.textRight = view.proseRight
        if comment { state.comments["b0"] = [.init(id: "c1", text: "a note")] }
        if let presentation { state.presentations["b0"] = presentation }
        return state
    }

    /// The prose column, as a rect over the block's own band: the ONLY place
    /// the surface can draw text, so "covers text" is "intersects this".
    private func proseRect(_ state: BlockDecor.State) -> CGRect {
        let band = state.frames[0].frame
        return CGRect(
            x: state.textLeft, y: band.minY,
            width: max(0, state.textRight - state.textLeft), height: band.height)
    }

    // MARK: - The lane itself

    /// **THE LANE IS THE NOTE'S OWN, and it is given back.**
    ///
    /// RED ON OLD by construction: before this batch the contained editor's
    /// leading prose inset was 8 pt in every state, which is the whole defect.
    @Test func theBookEditorsLaneArrivesWithADecorationAndLeavesWithIt() {
        let (view, window) = inlineSurface()
        defer {
            window.orderOut(nil)
            window.close()
        }
        let controller = BlockDecorOverlayController(
            textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
        defer { controller.uninstall() }

        // At rest: the shipped 8 pt, both sides.
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset)
        #expect(view.proseRight == view.bounds.width - EditorTypography.inlineSurfaceInset)

        // A COMMENT arrives → the lane is reserved, on the LEFT only.
        controller.render(state(for: view, comment: true, presentation: nil))
        view.layoutSubtreeIfNeeded()
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset
            + EditorTypography.commentLane,
                "the lane: \(view.proseLeft)")
        #expect(view.proseRight == view.bounds.width - EditorTypography.inlineSurfaceInset,
                "the trailing inset never moves — the measure narrows by the lane (R9)")

        // A CALLOUT GLYPH alone reserves it too (her R-Q4's second trigger).
        controller.render(BlockDecor.State())
        view.layoutSubtreeIfNeeded()
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset,
                "…and it is given back when the note carries nothing")
        controller.render(state(
            for: view, comment: false,
            presentation: BlockPresentation(color: "sand", emoji: "\u{1f4a1}")))
        view.layoutSubtreeIfNeeded()
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset
            + EditorTypography.commentLane)

        // A callout with NO glyph reserves NOTHING: its card pads 12 pt into
        // the gutter and has always had room for that.
        controller.render(state(
            for: view, comment: false, presentation: BlockPresentation(color: "sand")))
        view.layoutSubtreeIfNeeded()
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset,
                "no glyph, no comment — no lane: \(view.proseLeft)")
    }

    /// **ONLY THE CONTAINED SURFACE OPTS IN.** The full-document editor's
    /// gutter is the dynamic centering inset, and a lane bolted onto it would
    /// fight `updateGutters` every reflow.
    @Test func theFullEditorReservesNoLaneAtAll() {
        let (scrollView, full) = EditorTextView.makeEditor()
        _ = scrollView
        #expect(!full.reservesDecorLane)
        full.setDecorLane(needed: true)
        #expect(full.proseLeft == full.textContainerOrigin.x,
                "inert: the symmetric road, unchanged")
        let inline = EditorTextView.makeInlineEditor()
        #expect(inline.reservesDecorLane)
    }

    /// **A LANED SURFACE STAYS ON TEXTKIT 2** — the override is not a
    /// downgrade trigger (TEXTKIT2_NOTES §4.2/§4.3: never trust that, measure
    /// it). Driven through a real edit, because the canary fires on API use
    /// and layout alike.
    @Test func aLanedSurfaceStaysOnTextKit2() {
        let (view, window) = inlineSurface()
        defer {
            window.orderOut(nil)
            window.close()
        }
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
        // …and the prose really is where the override says it is: the first
        // fragment lays out inside the lane, not over it.
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset
            + EditorTypography.commentLane)
        #expect(view.textContainer?.size.width ?? 0
            <= view.bounds.width - EditorTypography.commentLane,
                "the container really narrowed: \(view.textContainer?.size ?? .zero)")
    }

    // MARK: - Rows 5–6: nothing covers anything

    /// **THE ROW, PINNED: badge, glyph and prose are pairwise DISJOINT.**
    ///
    /// **RED ON OLD** (behavioral revert, verified): make
    /// `EditorTextView.setDecorLane` return early — the contained editor's
    /// prose stays at 8 pt — and this fails with the badge at [2, 34] and the
    /// glyph at [6, 24] both inside a prose column starting at 8.
    @Test func aCommentedCalloutWithAGlyphCoversNoTextAndNothingElseEither() throws {
        let (view, window) = inlineSurface()
        defer {
            window.orderOut(nil)
            window.close()
        }
        let controller = BlockDecorOverlayController(
            textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
        defer { controller.uninstall() }

        let framed = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
        // Pass one reserves the lane; pass two is the production loop's
        // second visit, with the state rebuilt against the new prose column
        // (which is what the layout-settle hop does in the app).
        controller.render(state(for: view, comment: true, presentation: framed))
        view.layoutSubtreeIfNeeded()
        let settled = state(for: view, comment: true, presentation: framed)
        controller.render(settled)
        view.layoutSubtreeIfNeeded()

        // Hard requires, never `try?`: a pin that passes because it found no
        // faces is the vacuity class this batch's own record warns about.
        let badges = view.subviews.compactMap { $0 as? CommentCardView }
        let glyphs = view.subviews.compactMap { $0 as? NSTextField }
            .filter { !($0 is CommentCardView) }
        let cards = view.subviews.compactMap { $0 as? DecorRectView }
        #expect(badges.count == 1 && glyphs.count == 1 && cards.count == 1,
                "one of each is drawn: \(badges.count)/\(glyphs.count)/\(cards.count)")
        let badge = try #require(badges.first)
        let glyph = try #require(glyphs.first)
        let card = try #require(cards.first)
        #expect(glyph.stringValue == "\u{1f4a1}", "the glyph really is the glyph")

        let prose = proseRect(settled)
        #expect(!badge.frame.intersects(prose),
                "the badge is in the lane, off the words: \(badge.frame) vs \(prose)")
        #expect(!glyph.frame.intersects(prose),
                "the glyph never reaches the words: \(glyph.frame) vs \(prose)")
        #expect(!badge.frame.intersects(glyph.frame),
                "…and they do not collide: \(badge.frame) vs \(glyph.frame)")
        // The glyph is INSIDE its own card (her R-Q4's letter), and the badge
        // stands clear of that card rather than on its tint.
        #expect(card.frame.contains(glyph.frame),
                "the glyph is the frame's: \(glyph.frame) inside \(card.frame)")
        #expect(badge.frame.maxX <= card.frame.minX + 0.5,
                "the badge stops at the card: \(badge.frame) vs \(card.frame)")
        // Comments stay on the LEFT (her R5-3 letter, R-Q4's last clause).
        #expect(badge.frame.maxX <= settled.textLeft)
    }

    /// **THE SWEEP, at the OTHER width** (the constitution's closing form): a
    /// laned surface narrow enough to be a book column still covers nothing.
    @Test func theLaneHoldsAtANarrowBookColumnToo() {
        for width in [360.0, 480.0, 900.0] as [CGFloat] {
            let (view, window) = inlineSurface(width: width)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let controller = BlockDecorOverlayController(
                textView: view, onOpenComments: { _ in }, onMoveBlock: { _, _ in })
            defer { controller.uninstall() }
            let framed = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
            controller.render(state(for: view, comment: true, presentation: framed))
            view.layoutSubtreeIfNeeded()
            let settled = state(for: view, comment: true, presentation: framed)
            controller.render(settled)
            view.layoutSubtreeIfNeeded()
            let prose = proseRect(settled)
            let faces = view.subviews.filter { $0 is CommentCardView || $0 is NSTextField }
            #expect(faces.count == 2, "badge + glyph at \(width): \(faces.count)")
            for face in faces {
                #expect(!face.frame.intersects(prose),
                        "at \(width): \(type(of: face)) \(face.frame) vs \(prose)")
            }
        }
    }

    // MARK: - The pure rules

    /// The card widens LEFTWARD to hold its glyph, and the glyph sits in the
    /// room it grew. No text attribute, no paragraph style, no
    /// `exclusionPaths` — the geometry alone (TEXTKIT2_NOTES §3).
    @Test func theCardWidensToHoldItsGlyphAndTheGlyphSitsInside() {
        let block = CGRect(x: 0, y: 100, width: 400, height: 40)
        let plain = BlockDecor.calloutRect(
            block: block, gapAbove: nil, gapBelow: nil,
            textLeft: 300, textRight: 700)
        let framed = BlockDecor.calloutRect(
            block: block, gapAbove: nil, gapBelow: nil,
            textLeft: 300, textRight: 700, hasGlyph: true)
        #expect(plain.minX == 288, "the shipped 12 pt of air, unchanged")
        #expect(framed.minX == 300 - BlockDecor.calloutLeadingPad(hasGlyph: true))
        #expect(framed.minX == 266, "12 + 4 + 18")
        #expect(framed.maxX == plain.maxX, "the TRAILING edge never moves")
        #expect(framed.minY == plain.minY && framed.height == plain.height,
                "the white-gap rule is untouched (R17)")

        let glyph = BlockDecor.calloutGlyphRect(card: framed, blockTop: block.minY)
        #expect(framed.contains(glyph), "inside its own frame: \(glyph) in \(framed)")
        #expect(glyph.maxX <= 300, "and never over the text: \(glyph)")
        #expect(glyph.minY == block.minY, "aligned to the block's first line")
        // A glyph in a card clamped at the view's edge is still inside it.
        let clamped = BlockDecor.calloutRect(
            block: block, gapAbove: nil, gapBelow: nil,
            textLeft: 20, textRight: 400, hasGlyph: true)
        #expect(clamped.minX == 2)
        #expect(clamped.contains(
            BlockDecor.calloutGlyphRect(card: clamped, blockTop: block.minY)))
    }

    /// The comment faces yield the gutter a callout card claims — one
    /// clearance answer for the badge and the margin card alike.
    @Test func theCommentFacesYieldTheGutterACalloutCardClaims() {
        // No callout: each face keeps its own shipped air.
        #expect(BlockDecor.commentClearance(
            hasCallout: false, hasGlyph: false, own: BlockDecor.leftCardLane) == 28)
        #expect(BlockDecor.commentClearance(hasCallout: false, hasGlyph: false, own: 4) == 4)
        // A plain callout's 12 + 4 is inside the card's own 28, so the margin
        // card does not move — the parity claim, as arithmetic.
        #expect(BlockDecor.commentClearance(
            hasCallout: true, hasGlyph: false, own: BlockDecor.leftCardLane) == 28)
        // …and a glyphed one claims more than either face's own air.
        #expect(BlockDecor.commentClearance(
            hasCallout: true, hasGlyph: true, own: BlockDecor.leftCardLane) == 38)
        #expect(BlockDecor.commentClearance(hasCallout: true, hasGlyph: true, own: 4) == 38)

        // The badge's own placement, unchanged where nothing else claims the
        // gutter: `textLeft - 36` for a 32-wide badge.
        let plain = BlockDecor.commentBadgeRect(textLeft: 60, blockTop: 10, clearance: 4)
        #expect(plain == CGRect(x: 24, y: 10, width: 32, height: 16))
        // And clear of a glyphed callout's card in a laned surface.
        let laned = BlockDecor.commentBadgeRect(
            textLeft: 72, blockTop: 10,
            clearance: BlockDecor.commentClearance(
                hasCallout: true, hasGlyph: true, own: 4))
        #expect(laned.minX == 2 && laned.maxX == 34)
        let card = BlockDecor.calloutRect(
            block: CGRect(x: 0, y: 10, width: 620, height: 34),
            gapAbove: nil, gapBelow: nil, textLeft: 72, textRight: 612, hasGlyph: true)
        #expect(card.minX == 38 && laned.maxX <= card.minX)
    }

    /// **THE LANE'S TRIGGER** — her R-Q4's own words, as a value.
    @Test func theLanesTriggerIsACommentOrACalloutGlyph() {
        var state = BlockDecor.State()
        #expect(!BlockDecor.needsLane(state))
        state.presentations["b0"] = BlockPresentation(color: "sand")
        #expect(!BlockDecor.needsLane(state), "a callout with no glyph needs no lane")
        state.presentations["b0"] = BlockPresentation(color: "sand", emoji: "")
        #expect(!BlockDecor.needsLane(state), "an EMPTY glyph is no glyph")
        state.presentations["b0"] = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
        #expect(BlockDecor.needsLane(state))
        state.presentations = [:]
        state.comments["b0"] = [.init(id: "c1", text: "a note")]
        #expect(BlockDecor.needsLane(state))
        // A glyph on a NON-callout presentation is not a callout glyph.
        state.comments = [:]
        state.presentations["b0"] = BlockPresentation(kind: "future", emoji: "\u{1f4a1}")
        #expect(!BlockDecor.needsLane(state))
        #expect(!BlockDecor.hasLeadingGlyph(state.presentations["b0"]))
    }

    // MARK: - The parity claim: Write's faces do not move

    /// **BYTE-IDENTICAL IN WRITE** for everything but a glyphed callout. This
    /// batch's brief forbids moving Write's shipped placements, and the two
    /// numbers are the ones the shipped pins already assert.
    @Test func writesMarginCardAndPlainCalloutAreWhereTheyShipped() {
        // The margin card at a wide gutter (the shipped
        // `aMarginCommentCardSitsInTheLEFTGutterClearOfTheHandleLane`
        // numbers, recomputed through the defaulted clearance).
        let card = BlockDecor.leftCardRect(textLeft: 300, blockTop: 40, blockHeight: 30)
        #expect(card == CGRect(x: 62, y: 40, width: 210, height: 54))
        #expect(BlockDecor.leftCardRect(
            textLeft: 300, blockTop: 40, blockHeight: 30,
            clearance: BlockDecor.commentClearance(
                hasCallout: true, hasGlyph: false, own: BlockDecor.leftCardLane)) == card,
                "a callout with no glyph moves the card not at all")
        // A plain callout's card (the shipped `theWhiteGapRuleCapsCalloutPadding`
        // numbers).
        let plain = BlockDecor.calloutRect(
            block: CGRect(x: 0, y: 100, width: 400, height: 40),
            gapAbove: 8, gapBelow: nil, textLeft: 28, textRight: 428)
        #expect(plain == CGRect(x: 16, y: 99, width: 424, height: 46))
        // And the badge at the narrow-gutter width the shipped sweep pin uses.
        #expect(BlockDecor.commentBadgeRect(textLeft: 60, blockTop: 0, clearance: 4)
            == CGRect(x: 24, y: 0, width: 32, height: 16))
    }
}
