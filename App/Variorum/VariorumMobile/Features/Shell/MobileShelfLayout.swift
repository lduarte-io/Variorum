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

    /// The floor under the writing area. Below this the box stops being a
    /// place to write, so the books region yields further instead — the
    /// small-phone and keyboard-up case her sentence did not have to name.
    /// Four lines of prose plus the box's own chrome.
    static let minimumWritingHeight: CGFloat = 132

    // MARK: - Row metrics (estimates — see the header)

    /// `bookRow`: `tokens.body` (14 pt) with 11 pt of vertical padding a
    /// side. Also stands in for the trailing `+ new book` row and the
    /// Today fallback row, which carry the same padding at `tokens.small`.
    static let bookRowHeight: CGFloat = 42
    /// `starredRow`: `tokens.body` with 8 pt of padding a side.
    static let starredRowHeight: CGFloat = 36
    /// The starred section's header line plus its trailing divider block.
    static let starredChromeHeight: CGFloat = 38

    /// The quick-note box's own chrome inside the writing region — the
    /// status row, the box's padding, and the spacing between them. What
    /// is left is the FIELD.
    static let writingBoxChromeHeight: CGFloat = 56

    /// One rendered line of `tokens.small` (11.5 pt, both voices).
    /// Measured, not assumed — `MobileShelfLayoutTests` pins it against
    /// the real fonts both voices resolve to.
    static let smallLineHeight: CGFloat = 14

    /// The field never caps below this, however cramped the room —
    /// a three-line box is still a box.
    static let minimumWritingLines = 3

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
    static func naturalBooksHeight(
        bookRows: Int, starredRows: Int, extraRows: Int
    ) -> CGFloat {
        var height = CGFloat(max(0, bookRows)) * bookRowHeight
        height += CGFloat(max(0, extraRows)) * bookRowHeight
        if starredRows > 0 {
            height += starredChromeHeight
            height += CGFloat(starredRows) * starredRowHeight
        }
        return height
    }

    /// R27's whole ruling, as arithmetic.
    ///
    /// `region` is the real height available to books + writing together.
    /// The result always partitions it exactly (`books + writing == region`
    /// for any non-negative region), so nothing can fall off the bottom.
    static func split(
        region: CGFloat, bookRows: Int, starredRows: Int, extraRows: Int
    ) -> Split {
        guard region > 0 else { return Split(booksHeight: 0, writingHeight: 0) }

        let natural = naturalBooksHeight(
            bookRows: bookRows, starredRows: starredRows, extraRows: extraRows)
        // Her ~8 books, and the trailing door that always sits under them.
        let rowCap = CGFloat(visibleBookRowCap) * bookRowHeight + bookRowHeight
        // Her half-the-screen.
        let shareCap = region * maximumBooksShare

        let wanted = min(natural, min(rowCap, shareCap))
        // The writing area is the residual, floored — and the floor wins,
        // because a books list that scrolls is a smaller loss than a box
        // she cannot write in.
        let writing = max(region - wanted, min(region, minimumWritingHeight))
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
        writingHeight: CGFloat, lineHeight: CGFloat = smallLineHeight
    ) -> Int {
        guard lineHeight > 0 else { return minimumWritingLines }
        let fieldHeight = writingHeight - writingBoxChromeHeight
        let lines = Int((fieldHeight / lineHeight).rounded(.down))
        return max(minimumWritingLines, lines)
    }
}
