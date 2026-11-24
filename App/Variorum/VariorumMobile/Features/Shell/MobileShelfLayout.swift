//
//  MobileShelfLayout.swift
//  VariorumMobile
//
//  Mobile Round 2, batch 5 — THE SHELF'S PROPORTIONS, as a pure brain
//  (her R26/R27 ruling; the binding record is `mobile-round-2.md` §40/§41).
//
//  Her words, verbatim (R27): *"right now today's entry is under the +
//  new book text - in its own separated little box. that's where I want
//  the writing a note to go, so that there's a good amount of space. I
//  would make sure that if you have more than ~8 books (which will take
//  up a good amount of the top half of the screen) that you have to
//  scroll through the books so that the main area still can be 'new note
//  - just start typing' and there's enough room that you can type in that
//  for about half the phone screen."*
//
//  **She is describing PROPORTIONS, not a position** — which is why this
//  is a brain and not a modifier. The architect's earlier "pin the box to
//  the bottom" reading was superseded by hers, and hers is better: bound
//  what sits ABOVE the writing area and the writing area is generous by
//  construction at any shelf size.
//
//  THE RULE, in one sentence: the books region takes what its rows
//  naturally need, capped by ~8 book rows AND by half the room, and the
//  writing region takes everything else — with a floor under it, so the
//  box never degenerates into a line.
//
//  ── §53 ROW 6: WHY THE KEYBOARD OPT-OUT IS *NOT* THE FIX ───────────────
//  The sweep recorded that `MobileShelfView` carries no
//  `.ignoresSafeArea(.keyboard)`, unlike `MobileWriteView`, and predicted
//  the ruled half-screen writing area would be "the first casualty" when
//  the keyboard rises. The prediction is right; the proposed remedy would
//  be wrong. **Opting the shelf out of keyboard avoidance would leave the
//  box UNDER the keyboard** — the shelf's field DWELLS at the bottom of
//  the layout, unlike Write's, whose own text view scrolls itself.
//
//  So avoidance stays ON (the box is never covered) and what needed
//  designing is **which region absorbs the shrink**. This brain answers
//  it: the books region is a share of whatever room exists, so a keyboard
//  that halves the room halves the BOOKS and the writing area keeps its
//  ruled share of what is left. Her own instinct, applied to a case her
//  sentence did not have to name — *bound the books, not the box*.
//
//  ── WHAT IS MEASURED AND WHAT IS ESTIMATED (stated, not buried) ────────
//  `region` is REAL: it comes from a `GeometryReader` around exactly the
//  books+writing area, so it already carries the keyboard's inset, the
//  safe areas, the path line, the status rows and the tab bar.
//
//  The per-row heights below are ESTIMATES of what the shelf's own rows
//  render at, and they are used for ONE decision only — whether the books
//  region can shrink BELOW its cap because few books exist. An error
//  there costs a little empty air or a slightly early scroll; it can
//  never mis-size the writing area, which is always the residual.
//  `MobileShelfLayoutTests` measures the real rendered rows off a hosted
//  surface and fails if a constant drifts out of tolerance.
//

import CoreGraphics
import Foundation

nonisolated enum MobileShelfLayout {

    // MARK: - Her numbers

    /// R27.2 — *"more than ~8 books … you have to scroll through the
    /// books"*. The books region never renders taller than this many book
    /// rows (plus its trailing door); past it the LIST scrolls inside
    /// itself and the writing area does not move.
    static let visibleBookRowCap = 8

    /// R27.3 — *"about half the phone screen"*. The books region may never
    /// take more than this share of the room, so the writing area keeps
    /// roughly the other half however many books exist.
    static let maximumBooksShare: CGFloat = 0.5

    /// **HER GUARANTEE (2026-08-30, after reading batch 5's result):**
    /// *"the shelf should be bounded so it always has a decent amount of
    /// room to write."* This raises what was a defensive floor to a
    /// promise, and it is expressed in LINES because that is what "room to
    /// write" means — a pixel count would drift the moment the type or the
    /// chrome changed.
    ///
    /// `theWritingFloorIsAGuaranteeInEveryShelfState` pins the PROMISE
    /// (`writing >= min(region, minimumWritingHeight)`, for every shelf
    /// state this app can render) rather than the arithmetic that
    /// currently produces it — so a later layout change that violates it
    /// fails loudly instead of eroding it quietly.
    static let guaranteedWritingLines = 6

    /// The floor under the EXPANDED writing area, derived from her
    /// guarantee. Below this the box stops being a place to write, so the
    /// books region yields further instead — the small-phone,
    /// large-Dynamic-Type and keyboard-up cases her sentence did not have
    /// to name.
    ///
    /// **In LINES of the box's own text, at its own size** (VM-48): the box
    /// types in the note body, which grows with Dynamic Type, so the shelf
    /// hands in the box's line at the current text size and six of THOSE
    /// are what the floor keeps.
    static func minimumWritingHeight(lineHeight: CGFloat) -> CGFloat {
        CGFloat(guaranteedWritingLines) * lineHeight + writingBoxChromeHeight
    }

    /// The floor at the default text size.
    static var minimumWritingHeight: CGFloat {
        minimumWritingHeight(lineHeight: quickEntryLineHeight)
    }

    // MARK: - Row metrics (estimates — see the header)

    // **VM-48 (W-024): these are re-derived from the phone layer's roles**
    // rather than from the Mac's 11.5 pt caption, which the whole shelf
    // used to be set in.

    /// One line of the quick-entry box at the default text size — the
    /// sizing sheet's 24 pt line for the box's note-body type ("Resting
    /// height 48: 11 · one 24 pt line · 11"). The box draws its text on this
    /// pitch. Measured against the real fonts by `MobileShelfLayoutTests`.
    static let quickEntryLineHeight: CGFloat = 24

    /// One meta line at the default text size (the sheet's 13 / 18) — the
    /// box's status row ("✓ saved" and the `open ↵` door).
    static let metaLineHeight: CGFloat = 18

    /// `bookRow`: the row title's line (`rowTitle`, the sheet's 17 / 22)
    /// with 11 pt of vertical padding a side. Also stands in for the
    /// trailing `+ new book` row and the Today fallback row, which carry
    /// the same padding at the control size.
    static let bookRowHeight: CGFloat = 22 + 2 * 11

    /// The quick-note box's own chrome inside the writing region — the
    /// box's padding (10 a side), the gap to the status row (6), the status
    /// row (one meta line), the box's bottom margin (8) and 8 pt of air.
    /// What is left is the FIELD.
    static let writingBoxChromeHeight: CGFloat = 2 * 10 + 6 + metaLineHeight + 8 + 8

    /// The field never caps below this, however cramped the room —
    /// a three-line box is still a box.
    static let minimumWritingLines = 3

    // MARK: - At rest, the box is ONE LINE (her 2026-08-30 ruling)

    /// Her words: *"the box should be one line until you click into it."*
    ///
    /// **This CLOSED batch 5's own PROVISIONAL** about a near-empty shelf
    /// showing a large empty rectangle — she ruled it in this direction,
    /// so the shelf now has two resting shapes rather than one.
    ///
    /// The two states are a LAYOUT fact, not a decoration: at rest the
    /// books get everything above one collapsed line, and the ~8-row cap
    /// does not apply — the cap exists only to protect a writing area, and
    /// at rest there is none to protect. On focus the R27 split takes over
    /// and her floor guarantee binds, which is exactly when writing room
    /// matters most.
    enum WritingState: Equatable {
        /// Not focused: one line, anchored at the bottom of the shelf.
        case collapsed
        /// Focused: R27's proportions, and her floor guarantee.
        case expanded
    }

    /// The collapsed box's whole region — one line plus the box's chrome
    /// (its border padding, and the saved-indicator row that appears the
    /// moment there is text to be honest about).
    static func collapsedWritingHeight(lineHeight: CGFloat) -> CGFloat {
        lineHeight + writingBoxChromeHeight
    }

    /// The collapsed box at the default text size.
    static var collapsedWritingHeight: CGFloat {
        collapsedWritingHeight(lineHeight: quickEntryLineHeight)
    }

    // MARK: - The split

    struct Split: Equatable {
        /// The bounded, self-scrolling books region.
        var booksHeight: CGFloat
        /// The writing region — the quick-note box's whole home.
        var writingHeight: CGFloat
    }

    /// The natural height of everything the books region wants to show.
    /// `extraRows` counts the region's trailing doors (`+ new book`, and
    /// the Today fallback row when it renders).
    ///
    /// **The starred rows left this region at batch 10** and the parameter
    /// that reserved height for them went with them at the cold review's
    /// NIT 1: its only caller had passed `0` since the starred page shipped,
    /// and a live parameter whose every value is dead reads as a rule the
    /// shelf does not have. Her writing-floor guarantee is unchanged — the
    /// pin that spans it simply no longer spans a dimension the shelf cannot
    /// enter.
    static func naturalBooksHeight(bookRows: Int, extraRows: Int) -> CGFloat {
        var height = CGFloat(max(0, bookRows)) * bookRowHeight
        height += CGFloat(max(0, extraRows)) * bookRowHeight
        return height
    }

    /// R27's whole ruling, as arithmetic.
    ///
    /// `region` is the real height available to books + writing together.
    /// The result always partitions it exactly (`books + writing == region`
    /// for any non-negative region), so nothing can fall off the bottom.
    ///
    /// `lineHeight` is one line of the box's text at the current text size
    /// (VM-48 — the box types in the note body, which scales); the default
    /// is the default size's.
    static func split(
        region: CGFloat, bookRows: Int, extraRows: Int,
        writing state: WritingState = .expanded,
        lineHeight: CGFloat = quickEntryLineHeight
    ) -> Split {
        guard region > 0 else { return Split(booksHeight: 0, writingHeight: 0) }

        // AT REST (her one-line ruling): one line at the bottom, and the
        // books take everything else. No cap here — capping the books
        // against a collapsed box would only mint dead air above it.
        if state == .collapsed {
            let box = min(region, collapsedWritingHeight(lineHeight: lineHeight))
            return Split(booksHeight: region - box, writingHeight: box)
        }

        let natural = naturalBooksHeight(bookRows: bookRows, extraRows: extraRows)
        // Her ~8 books, and the trailing door that always sits under them.
        let rowCap = CGFloat(visibleBookRowCap) * bookRowHeight + bookRowHeight
        // Her half-the-screen.
        let shareCap = region * maximumBooksShare

        let wanted = min(natural, min(rowCap, shareCap))
        // The writing area is the residual, floored — and the floor wins,
        // because a books list that scrolls is a smaller loss than a box
        // she cannot write in.
        let writing = max(
            region - wanted, min(region, minimumWritingHeight(lineHeight: lineHeight)))
        return Split(
            booksHeight: max(0, region - writing), writingHeight: writing)
    }

    /// How many lines the quick-note field may grow to before it scrolls
    /// inside itself — derived from the writing region so the box fills
    /// its ruled area on a big phone and cannot overflow it on a small one.
    ///
    /// (R27's architect ruling: *"the box WRAPS AND GROWS into that area
    /// rather than staying a single line. ⏎ is unchanged"* — so this is
    /// about WRAPPING, never about holding several paragraphs.)
    static func writingLineCap(
        writingHeight: CGFloat, lineHeight: CGFloat = quickEntryLineHeight
    ) -> Int {
        guard lineHeight > 0 else { return minimumWritingLines }
        let fieldHeight = writingHeight - writingBoxChromeHeight
        let lines = Int((fieldHeight / lineHeight).rounded(.down))
        return max(minimumWritingLines, lines)
    }
}
