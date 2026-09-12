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
//    but "not a downgrade trigger" is a claim that must be measured);
//  · THE LOOP, DRIVEN (the ladder's R1-1 / R1-5): on BOTH contained hosts,
//    through the real coordinator wiring, a comment's arrival reserves the
//    lane, the host door fires, and the surface is then READ — its
//    published height equals its measured (re-wrapped) height and the
//    badge the loop finally drew stands left of the prose the loop finally
//    placed. The two mounted disjointness pins below rebuild pass two by
//    hand and so pin the pure geometry of the faces, never the loop.
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

    /// **THE WALK'S OWN FINDING (W-1), PINNED.** Reserving the lane moves
    /// where the text begins — and every decoration's rect is computed from
    /// that edge. The render that RESERVES the lane is working from the OLD
    /// `textLeft`, so without a second decoration pass the badge stays
    /// exactly where it was: on the words. The batch's first walk met that
    /// (the book Outline's `#1` badge still covering "lo" of "loose") while
    /// every unit pin was green, because the pins rebuilt the state from the
    /// view's new prose column BY HAND and so simulated a loop that did not
    /// run.
    ///
    /// The model's decoration loop is driven by `overlayLayoutDidSettle`,
    /// whose generation gate only opens on a REPORTED geometry change, and
    /// `onWidthReflow` is that report (`EditorViewModel.attach` wires it to
    /// bump the generation and run the settle hop). A lane IS a prose-column
    /// reflow, so `setDecorLane` reports one.
    ///
    /// **RED ON OLD** (this tree, before the one-line fix): `reflows == 0`.
    @Test func reservingTheLaneSaysSoSoTheDecorationsAreComputedAgain() {
        // Every contained surface answers the ONE question, and answers TRUE
        // only when the column really moved.
        for surface in [
            EditorTextView.makeInlineEditor() as any DecorLaneSurface,
            PaneTextView.makeReadSurface() as any DecorLaneSurface,
        ] {
            #expect(surface.setDecorLane(needed: true),
                    "the prose column moved — ask the decorations again")
            #expect(!surface.setDecorLane(needed: true),
                    "change-gated: a settled lane says nothing")
            #expect(surface.setDecorLane(needed: false),
                    "giving the lane back moves it too")
            #expect(!surface.setDecorLane(needed: false))
        }
        // …and INERT on the surface that reserves none, so the full editor
        // never asks for a spurious second pass.
        let (_, full) = EditorTextView.makeEditor()
        #expect(!full.setDecorLane(needed: true))
        #expect(!full.reservesDecorLane)
    }

    /// **THE FIRST LANELESS ASK SAYS NOTHING** (the ladder's R1-2). Every
    /// contained surface's first render asks `setDecorLane(needed: false)`
    /// before any comment exists; the brain answered "moved" (its state was
    /// nil, and nil is not 8) and so sent that first render back through the
    /// host door for nothing — once per contained surface, once per visible
    /// note in a book Outline — and left the origin override live at the
    /// resting value. RED ON OLD: both surfaces returned true on the first
    /// ask.
    @Test func theFirstLanelessAskReportsNoMovement() {
        for surface in [
            EditorTextView.makeInlineEditor() as any DecorLaneSurface,
            PaneTextView.makeReadSurface() as any DecorLaneSurface,
        ] {
            #expect(!surface.setDecorLane(needed: false),
                    "nothing moved — the resting inset IS the resting inset")
            #expect(!surface.setDecorLane(needed: false))
            #expect(surface.proseLeft == EditorTypography.inlineSurfaceInset)
            // …and a lane reserved then released returns the surface to the
            // ordinary road: the same resting numbers, and nothing to say
            // on the next laneless ask.
            #expect(surface.setDecorLane(needed: true))
            #expect(surface.setDecorLane(needed: false))
            #expect(surface.proseLeft == EditorTypography.inlineSurfaceInset)
            #expect(!surface.setDecorLane(needed: false))
        }
    }

    /// **THE SWEEP TABLE** (the constitution's closing form for a fixed
    /// class): every host of `BlockDecorOverlayController` — there are
    /// exactly three — and what each gets. The batch's WALK found the read
    /// tier's cell empty after the editor's was filled, which is precisely
    /// why the table is the pin.
    @Test func everyDecoratedSurfaceHasItsLaneAnsweredOneWayOrTheOther() {
        // 1 — the CONTAINED editor (`InlineEditorSurface`): a lane.
        #expect(EditorTextView.makeInlineEditor().reservesDecorLane)
        // 2 — the READ tier (`ReadPostView`): a lane. Same 8 pt prose inset,
        //     same decorations, and the surface an expanded-but-unfocused
        //     note in the book Outline renders (`BookView`'s read-cheap
        //     branch) — her screenshots' own surface.
        #expect(PaneTextView.makeReadSurface().reservesDecorLane)
        // 3 — the FULL editor (`EditorSurface`): none. Its gutter is the
        //     dynamic centering inset, already wide enough for a margin card
        //     at any window that is not at `minGutter`.
        let (_, full) = EditorTextView.makeEditor()
        #expect(!full.reservesDecorLane)
        // …and a TAKE pane, which hosts no decoration controller at all,
        //     reserves nothing either.
        #expect(!PaneTextView.makeTakeSurface().reservesDecorLane)
    }

    /// The read tier's lane does the same geometry the editor's does — one
    /// brain, so the two contained surfaces cannot disagree about where a
    /// note's badge lives.
    @Test func theReadTiersLaneMovesItsProseColumnTheSameWay() {
        let view = PaneTextView.makeReadSurface()
        view.frame = NSRect(x: 0, y: 0, width: 620, height: 400)
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset)
        #expect(view.proseRight == 620 - EditorTypography.inlineSurfaceInset)
        view.setDecorLane(needed: true)
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset
            + EditorTypography.commentLane)
        #expect(view.proseRight == 620 - EditorTypography.inlineSurfaceInset,
                "the trailing inset never moves here either")
        view.setDecorLane(needed: false)
        #expect(view.proseLeft == EditorTypography.inlineSurfaceInset)
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
        // Pass one reserves the lane; pass two rebuilds the state BY HAND
        // against the new prose column. That makes this a pin of the PURE
        // GEOMETRY of the three faces at a laned edge — not of the
        // production loop, which it bypasses (the ladder's R1-5: the batch's
        // walk found W-1 and W-2 while this pin was green). The loop itself
        // — host door, re-measure, the badge's FINAL rect — is driven
        // end-to-end by the `…ThroughTheProductionLoop` pins below.
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
    /// Pass two is hand-fed here too — pure geometry at three widths; the
    /// loop is the `…ThroughTheProductionLoop` pins' (R1-5).
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

    // MARK: - The loop, driven (the ladder's R1-1 MAJOR + R1-5)

    /// A paragraph long enough that the 64 pt-narrower measure re-wraps it
    /// by lines — the shape the walk's ONE-LINE fixture could not take, which
    /// is why the walk saw the badge move and never the height stay.
    private var longParagraph: String {
        (0..<220).map { "word\($0 % 97)" }.joined(separator: " ")
    }

    /// The proven wait (the N14 pins' shape): async polling drains the
    /// controller's next-turn door and the settle hop; `display` gives any
    /// draw-pass report its chance.
    private func pump(_ window: NSWindow? = nil, until condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            window?.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// The last height a host published — a box, so the closure the real
    /// coordinator calls and the poll that reads it share one cell.
    @MainActor private final class HeightLog {
        var last: CGFloat = 0
    }

    /// **THE READ TIER RE-MEASURES ITS HEIGHT WHEN THE LANE NARROWS ITS
    /// MEASURE — driven through the production loop, never a hand-built
    /// state** (the ladder's R1-1, MAJOR; and R1-5's effect-level pin for
    /// W-1/W-2 on the surface the book Outline shows by default).
    ///
    /// The REAL wiring, end to end: `ReadPostSurfaceCoordinator.install` (what
    /// `makeNSView` does), the comment written through the operations layer
    /// and delivered by the model's own decor-context observation, the lane
    /// reserved by the controller's render, the host door fired on the next
    /// turn. Then the surface is READ, not rebuilt: its published
    /// `contentHeight` equals its measured height, that height GREW (the
    /// paragraph re-wrapped — the pin's own non-vacuity guard), and the badge
    /// the loop finally drew stands left of the prose the loop finally placed.
    ///
    /// **RED ON OLD** (behavioral revert — the pre-fix `ReadPostView` whose
    /// door was `pushOverlaysToSinks`): `contentHeight` stays at the pre-lane
    /// number while `PaneMeasurement.height` reads the re-wrapped one, i.e.
    /// the last lines outside the frame `ReadPostView` gives the surface.
    @Test func theReadTiersLaneReMeasuresItsHeightThroughTheProductionLoop() async throws {
        try await withReadTier(seedBlocks: [longParagraph, "A second block."]) { h in
            let coordinator = ReadPostSurfaceCoordinator(model: h.model)
            coordinator.install(textView: h.textView)
            defer { coordinator.uninstall() }
            let before = h.model.contentHeight
            #expect(before > 40, "the harness measured the seeded paragraph: \(before)")
            #expect(abs(before - PaneMeasurement.height(of: h.textView)) < 0.5,
                    "steady state before the lane")
            #expect(h.textView.proseLeft == EditorTypography.inlineSurfaceInset)

            // The comment lands the way it lands in the app: a row, observed.
            let slots = try await h.database.read { try Queries.renderPost($0, containerID: h.postID) }
            _ = try h.session.operations.addBlockComment(
                to: slots[0].blockID, text: "a note in the margin")

            await pump {
                h.textView.proseLeft == EditorTypography.inlineInset(needsLane: true)
                    && h.model.contentHeight > before
                    && abs(h.model.contentHeight - PaneMeasurement.height(of: h.textView)) < 0.5
            }
            #expect(h.textView.proseLeft == EditorTypography.inlineInset(needsLane: true),
                    "the lane arrived through the observation: \(h.textView.proseLeft)")
            let measured = PaneMeasurement.height(of: h.textView)
            #expect(measured > before + 10,
                    "the paragraph re-wrapped under the narrower measure: \(before) → \(measured)")
            #expect(abs(h.model.contentHeight - measured) < 0.5,
                    "R1-1: the published height follows the lane: \(h.model.contentHeight) vs \(measured)")
            // R1-5: the badge the LOOP drew, against the prose the LOOP placed.
            let badge = try #require(h.textView.subviews.compactMap { $0 as? CommentCardView }.first)
            #expect(badge.frame.maxX <= h.textView.proseLeft,
                    "the badge's final rect is in the lane: \(badge.frame) vs \(h.textView.proseLeft)")
        }
    }

    /// **THE CONTAINED EDITOR RE-REPORTS ITS HEIGHT WHEN THE LANE NARROWS
    /// ITS MEASURE** — the same loop one host over: the real
    /// `InlineEditorSurface.Coordinator.install` (its height report captured
    /// exactly as `makeNSView` captures it), the comment adopted through the
    /// model's own door, the lane reserved by the controller's render, and the
    /// coordinator's re-measure composed onto the host door.
    ///
    /// **RED ON OLD** (behavioral revert — the pre-fix `EditorView` where the
    /// coordinator left the door to the model alone): the last reported height
    /// stays at the pre-lane number — no storage edit re-measured, and the
    /// decoration projections are `@ObservationIgnored`, so no SwiftUI pass
    /// followed the comment either.
    @Test func theContainedEditorsLaneReReportsItsHeightThroughTheProductionLoop() async throws {
        try await withInlineEditor(seedBlocks: [longParagraph, "A second block."]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 620, height: 300),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 620, height: 300))
            window.contentView = container
            h.textView.frame = NSRect(x: 0, y: 0, width: 620, height: 300)
            container.addSubview(h.textView)
            let log = HeightLog()
            let coordinator = InlineEditorSurface.Coordinator(model: h.model)
            coordinator.install(textView: h.textView) { height in
                log.last = height
                h.textView.frame = NSRect(x: 0, y: 0, width: 620, height: height)
            }
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            window.orderFrontRegardless()
            coordinator.remeasure()
            let before = log.last
            #expect(before > 24 && abs(before - PaneMeasurement.height(of: h.textView)) < 0.5,
                    "steady state before the lane: \(before)")
            #expect(h.textView.proseLeft == EditorTypography.inlineSurfaceInset)

            let slots = try h.storeSlots()
            h.model.adoptComments([slots[0].blockID: [.init(id: "c1", text: "a note in the margin")]])

            await pump(window) {
                h.textView.proseLeft == EditorTypography.inlineInset(needsLane: true)
                    && log.last > before
                    && abs(log.last - PaneMeasurement.height(of: h.textView)) < 0.5
            }
            #expect(h.textView.proseLeft == EditorTypography.inlineInset(needsLane: true),
                    "the lane arrived through the model's door: \(h.textView.proseLeft)")
            let measured = PaneMeasurement.height(of: h.textView)
            #expect(measured > before + 10,
                    "the paragraph re-wrapped under the narrower measure: \(before) → \(measured)")
            #expect(abs(log.last - measured) < 0.5,
                    "R1-1: the reported height follows the lane: \(log.last) vs \(measured)")
            let badge = try #require(h.textView.subviews.compactMap { $0 as? CommentCardView }.first)
            #expect(badge.frame.maxX <= h.textView.proseLeft,
                    "the badge's final rect is in the lane: \(badge.frame) vs \(h.textView.proseLeft)")
        }
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
