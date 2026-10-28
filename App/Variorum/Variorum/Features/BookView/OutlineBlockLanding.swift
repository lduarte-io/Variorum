//
//  OutlineBlockLanding.swift
//  Variorum
//
//  **VX-680 — Index → Outline lands BLOCK-PRECISE** (P-B4-1's second option,
//  RULED at her 10-28 sitting, QUESTIONS #248: *"the Outline landing scrolls
//  the carried block's row into view"*). VX-630 made the click-over from the
//  Index arrive with the note LIVE at her block and caret; the PAGE still
//  landed the note's ROW at its top, so a block far down a long note sat live
//  below the visible page until she scrolled.
//
//  ── WHAT THIS IS ─────────────────────────────────────────────────────────
//  The carried block is the Outline landing's HOME: the one landing the
//  arrival already runs (`BookView.landOutline` over the one authority —
//  `Surface/LandingAuthority.swift`) converges, for this landing only, on the
//  block's MINIMAL REVEAL instead of the row's top — the Takes article's own
//  pure rule (`LandingAim.MinimalReveal`, her R-Q1: the row fully on screen,
//  moved the minimum to the nearest edge; never a forced top). Until the live
//  editor has laid the block out, the landing aims and reports the note's row
//  exactly as before (the row must realize and mount its editor first); once
//  the block's geometry exists, the row's reports carry the block's residual
//  and a correction reveals it. Same hold, same quiet interval, same budget,
//  same watchdog, same signpost — no second loop.
//
//  ── THE TEXTKIT 2 RAILS (TEXTKIT2_NOTES §3, binding) ────────────────────
//  - **No layout is ever forced.** The block's frame is read with
//    `enumerateTextLayoutFragments(…, options: [])`, and EVERY fragment it
//    reads must be `.layoutAvailable` — "a frame read with `options: []` is
//    a position only in `.layoutAvailable`" (VX-246 U4b); an unlaid fragment
//    answers "not ready", never a guess. Never a mid-document `.ensuresLayout`
//    on this whole-post surface (VX-246's poisoned-walk finding): the inline
//    editor's own whole walk (`InlineEditorSurface.remeasure`) is what lays
//    the note out, and the landing waits for it.
//  - **Nothing is frozen.** The viewport is the enclosing clip's bounds as it
//    stands at every read; the reveal is AppKit's own minimal scroll up the
//    clip-view chain (`NSView.scrollToVisible` — the road the inline editor's
//    caret already scrolls the Outline by, `CommentTextArea.revealForEditing`'s
//    precedent), which clamps to the document's live extent itself. No
//    `layoutViewport()` is called, so no clip re-read is owed; the landing's
//    next look re-reads the block where it now sits.
//  - **Nothing touches the live storage or the editor's identity machinery**
//    (`BlockRangeIndex` is read, never written; no attribute, no selection
//    change — the caret is VX-630's, placed by the editor's own seed).
//

import AppKit
import CoreGraphics

/// The pure halves (table-tested without a window).
nonisolated enum OutlineBlockLanding {
    /// **What the reveal brings into view**: the block's laid-out frame when
    /// it fits the page; a block TALLER than the page reveals the line her
    /// caret stands on instead (her place inside it — the block's top would
    /// leave her caret below the page; PROVISIONAL P-680-1); with no caret
    /// line in hand, the block's top, one page tall. Text-view coordinates.
    static func revealTarget(block: CGRect, caretLine: CGRect?, viewportHeight: CGFloat) -> CGRect {
        guard viewportHeight > 0, block.height > viewportHeight else { return block }
        if let caretLine, caretLine.minY >= block.minY - 0.5, caretLine.maxY <= block.maxY + 0.5 {
            return caretLine
        }
        return CGRect(x: block.minX, y: block.minY, width: block.width, height: viewportHeight)
    }

    /// **The landing's number for the block**: the minimal reveal's residual
    /// (`LandingAim.MinimalReveal.residual` — 0 while the target is wholly on
    /// the page; otherwise the signed distance the minimal scroll moves it,
    /// positive when the page must scroll DOWN). `targetTop` is the target's
    /// top relative to the viewport's top edge.
    static func residual(targetTop: CGFloat, targetHeight: CGFloat, viewportHeight: CGFloat) -> CGFloat {
        LandingAim.MinimalReveal.residual(
            rowFrame: CGRect(x: 0, y: targetTop, width: 1, height: targetHeight),
            viewportHeight: viewportHeight)
    }
}

/// What the live editor can say about the carried block right now.
@MainActor
struct OutlineBlockSighting {
    /// The reveal's target in the TEXT VIEW's coordinates (`revealTarget`).
    let target: CGRect
    /// The target's top relative to the page's top edge, and the page's height.
    let topInViewport: CGFloat
    let viewportHeight: CGFloat

    var residual: CGFloat {
        OutlineBlockLanding.residual(
            targetTop: topInViewport, targetHeight: target.height, viewportHeight: viewportHeight)
    }

    /// The block's place in `textView`, read from layout TextKit ALREADY
    /// HOLDS — nil when anything it needs is not there yet: no text view, no
    /// enclosing scroll, the block not in the editor's index, or any of the
    /// block's fragments not `.layoutAvailable` (never a guess, never a forced
    /// layout — the file header's rails). Cost ∝ the block's own fragments
    /// (one walk from its start) plus one pass over the index's entries.
    static func read(blockID: String, textView: NSTextView, index: BlockRangeIndex) -> OutlineBlockSighting? {
        guard let layoutManager = textView.textLayoutManager,
              let content = layoutManager.textContentManager,
              let clip = textView.enclosingScrollView?.contentView,
              let entry = index.entries.firstIndex(where: { $0.blockID == blockID })
        else { return nil }
        let range = index.range(ofEntryAt: entry)
        let documentStart = content.documentRange.location
        let length = content.offset(from: documentStart, to: content.documentRange.endLocation)
        // A block that STARTS at the document's end (an empty last block) is
        // inside no element — enumerating from the end location yields nothing
        // (JumpPrimitive's R2-1) — so it answers "not ready" and the landing
        // keeps the row's home, exactly as before (recorded).
        guard range.location < length,
              let start = content.location(documentStart, offsetBy: range.location)
        else { return nil }
        let caret = textView.selectedRange().location
        var top: CGFloat?
        var bottom: CGFloat = 0
        var caretLine: CGRect?
        var laidOut = true
        layoutManager.enumerateTextLayoutFragments(from: start, options: []) { fragment in
            let fragmentStart = content.offset(from: documentStart, to: fragment.rangeInElement.location)
            // Past the block's last paragraph (an empty block is one paragraph
            // at its own location — read once).
            if top != nil, fragmentStart > NSMaxRange(range) { return false }
            guard fragment.state == .layoutAvailable else {
                laidOut = false
                return false
            }
            let frame = fragment.layoutFragmentFrame
            top = min(top ?? frame.minY, frame.minY)
            bottom = max(bottom, frame.maxY)
            let fragmentEnd = fragmentStart + content.offset(
                from: fragment.rangeInElement.location, to: fragment.rangeInElement.endLocation)
            if caretLine == nil, caret >= fragmentStart, caret <= fragmentEnd {
                let lines = fragment.textLineFragments
                if let i = FragmentLines.lineIndex(
                    atLocalOffset: max(0, caret - fragmentStart),
                    lineRanges: lines.map(\.characterRange)) {
                    let bounds = lines[i].typographicBounds
                    caretLine = CGRect(
                        x: frame.minX, y: frame.minY + bounds.minY,
                        width: frame.width, height: bounds.height)
                }
            }
            return fragmentEnd < NSMaxRange(range)
        }
        guard laidOut, let top else { return nil }
        let origin = textView.textContainerOrigin
        let width = textView.bounds.width
        let block = CGRect(x: 0, y: top + origin.y, width: width, height: max(1, bottom - top))
        let caretInView = caretLine.map {
            CGRect(x: 0, y: $0.minY + origin.y, width: width, height: max(1, $0.height))
        }
        // The page as it stands right now, in the text view's own coordinates.
        let viewport = textView.convert(clip.bounds, from: clip)
        guard viewport.height > 0 else { return nil }
        let target = OutlineBlockLanding.revealTarget(
            block: block, caretLine: caretInView, viewportHeight: viewport.height)
        return OutlineBlockSighting(
            target: target, topInViewport: target.minY - viewport.minY,
            viewportHeight: viewport.height)
    }
}
