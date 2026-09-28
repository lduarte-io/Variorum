//
//  IndexProseColumn.swift
//  Variorum
//
//  **13u2 UNIT B — her item 19 (R-13u-10), verbatim:** *"the text indents in
//  index mode where you're editing it, which should not be happening the
//  second you click into a block."*
//
//  The mechanism, measured on the dev-store Debug build: an index-like
//  surface renders every block TWICE over its life — read-cheap SwiftUI
//  `Text` at rest, a live `PaneSurfaceView` the moment she clicks in — and
//  the two tiers were padded by the HOST alone. But a pane's first glyph does
//  not sit at its frame's edge: the text container is inset, and AppKit adds
//  its own `lineFragmentPadding` on top (`PaneTextView.proseLeadingInset`).
//  So the book Index's block paid 6 pt of host padding at rest and 6 + 11 pt
//  live, and the text stepped ~11 pt to the right on the click; the note's
//  Read ▸ edit stepped ~7.
//
//  The fix is one number per surface — where its prose starts, from the block
//  ROW's leading edge — with BOTH tiers' padding derived from it, so they
//  cannot drift apart again. The read tier never moves LEFT of where it sat
//  (`max`), which is why a surface's resting padding is still its own choice.
//
//  Pure, so the arithmetic is pinned rather than observed
//  (`IndexProseColumnTests`).
//
//  **18l-c UNIT U5 — THE TIERS' ONE METRICS VOCABULARY** (her 2026-09-27
//  report, verbatim: *"when you click onto text to edit, the whitespace
//  around it moves around. This happens in both book and individual note
//  index mode… In the individual note I noticed some words get compressed and
//  there's different spacing, in the book mode a larger space seems to be
//  added."*). 13u2 B aligned the LEADING edge and the first line's TOP; the
//  rest of the geometry — the measure's trailing edge, the bottom, and how the
//  lines are spaced — each tier still answered from its own head: the read
//  tier drew its paragraphs with `lineSpacing(4)` 8 pt apart, the live pane
//  with the Write editor's paragraph style (no line spacing, a gap of half the
//  font size) inside an 11-pt-narrower measure and a 6-pt bottom inset nobody
//  paid back. So the block went live and re-wrapped under her pointer. The
//  numbers U5 measured are in the plan file's U5 RECORD.
//
//  This file is now the ONE home of that geometry for the two index-like
//  tiers — where the prose sits (the column) AND how its lines are spaced
//  (`lines`). The read tier draws with it, the click's replica
//  (`ReadTierClickPlace`) lays out with it, and the live pane is handed it by
//  its HOST (`PaneSurfaceView.lineMetrics` — a host's call through one named
//  parameter, never a global; every other pane host passes nothing and keeps
//  the Write editor's base style byte for byte). A drift between the tiers is
//  now a pin failure (`IndexTierMetricsTests`), not a discovery of hers.
//
//  What NO metric can align, stated so nobody chases it: a live editor shows
//  the STORED text, so a line whose markdown markers the read tier hides
//  (`**bold**`, `# heading`, `- item`) still changes on going live (the held
//  18e's), and a stored BLANK line — the sample library keeps one under every
//  paragraph — is a real line in the live pane where the read tier folds it
//  into its paragraph gap (QUESTIONS #154, PROVISIONAL).
//

import AppKit
import CoreGraphics

/// **How a prose surface spaces its lines** — the vertical half of a text
/// surface's metrics, as ONE value a host hands its surface (18l-c U5).
///
/// It carries the read tier's own two numbers — the spacing between two lines
/// of one paragraph, and the gap between two paragraphs — and derives the one
/// thing a TextKit 2 paragraph style needs from them, because the two
/// renderers disagree about where a paragraph's line spacing goes: SwiftUI's
/// `Text.lineSpacing` sits only BETWEEN a paragraph's own lines (so a `VStack`
/// of paragraphs `gap` apart shows exactly `gap`), while TextKit 2 also lays a
/// paragraph's `lineSpacing` ABOVE the following paragraph's first line
/// (measured on 27.0, U5 RECORD: `lineSpacing 4, paragraphSpacing 8` puts two
/// paragraphs 12 pt apart). The style therefore carries `gap − lineSpacing`.
nonisolated struct ProseLineMetrics: Equatable, Sendable {
    /// Extra points between two lines of one paragraph.
    var lineSpacing: CGFloat
    /// The visible gap between two paragraphs — last line's bottom to the next
    /// paragraph's first line's top.
    var paragraphGap: CGFloat

    /// What a TextKit 2 paragraph style's `paragraphSpacing` must be to draw
    /// `paragraphGap` (see the type's doc for why it is not the gap itself).
    var textKitParagraphSpacing: CGFloat { max(0, paragraphGap - lineSpacing) }

    /// The paragraph style a TK2 surface lays these metrics out with — the
    /// ONLY two properties it sets (the Write editor's base style sets only
    /// `paragraphSpacing`; nothing else a pane draws reads the style).
    var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.paragraphSpacing = textKitParagraphSpacing
        return style
    }
}

nonisolated enum IndexProseColumn {
    /// **THE READ TIER'S LINE METRICS** — what both index-like read tiers
    /// draw every block with (`BookIndexPaneNote.blockView`,
    /// `ReadEditBlock`): each paragraph a `Text` with `.lineSpacing(4)`, the
    /// paragraphs 8 apart in a `VStack`. The numbers are the read tier's
    /// SHIPPED ones (18l U0 named them on `ReadTierClickPlace`; U5 promoted
    /// them here) — changing them is a look call, hers.
    static let lines = ProseLineMetrics(lineSpacing: 4, paragraphGap: 8)

    /// **The two surfaces' RESTING padding** — what each chose for itself
    /// before the two tiers had to agree, named here so a pin can read them
    /// (both hosts' row types are `private`) and so the pair lives in one
    /// place. Trailing and bottom keep these values unchanged.
    ///
    /// The book Index's pane (`BookIndexPaneNote`) padded 6 on every side;
    /// the note's Read ▸ edit (`ReadEditBlock`) padded 10 horizontally and 6
    /// vertically.
    static let bookIndexResting: CGFloat = 6
    static let bookIndexRestingTop: CGFloat = 6
    static let readEditResting: CGFloat = 10
    static let readEditRestingTop: CGFloat = 6

    /// Where a block's prose starts, from the block row's leading edge: the
    /// surface's resting padding, or the pane's own internal inset, whichever
    /// is greater — so the live pane is never pushed OUTSIDE its row to line
    /// up, and the read tier never moves left of where it sat.
    static func proseLeading(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        max(resting, paneInset)
    }

    /// What the READ tier pads on its leading edge — the whole distance,
    /// because a `Text` has no inset of its own.
    static func readTierLeading(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset)
    }

    /// What the LIVE pane's HOST pads on its leading edge — the remainder,
    /// because the pane supplies `paneInset` itself.
    static func livePaneLeading(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset) - paneInset
    }

    /// The same split on the vertical axis, so the first LINE of a block sits
    /// at the same height in both tiers (the pane's container is inset top
    /// and bottom as well as left and right).
    static func readTierTop(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset)
    }

    static func livePaneTop(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset) - paneInset
    }

    // MARK: - 18l-c U5: the two edges 13u2 B left unaligned

    /// What the LIVE pane's HOST pads on its TRAILING edge, so the pane's
    /// prose ENDS where the read tier's does — the two tiers wrap at ONE
    /// measure. The read tier pads `resting` there (a `Text` has no inset of
    /// its own); the pane's prose stops `paneInset` short of its own frame.
    ///
    /// **It may be NEGATIVE** — and is, on both hosts today (6 − 11, 10 − 11):
    /// the pane's frame then reaches past its row by the difference, which is
    /// `ProseGutter`'s doctrine on the other axis (13u3 A1 — *the text view's
    /// frame absorbs the host's whitespace; the prose does not move a point*).
    /// The leading edge keeps 13u2 B's `max` (the pane never pushed outside
    /// its row there: Read ▸ edit's ordinal sits in that margin); the trailing
    /// whitespace holds nothing, and a narrower pane measure is what re-wrapped
    /// her lines. The row's own width is unchanged either way.
    static func livePaneTrailing(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        resting - paneInset
    }

    /// The same split on the BOTTOM edge as on the top, so a block's LAST
    /// line's bottom sits the same distance above the next block in both
    /// tiers — the pane's container is inset at the bottom exactly as at the
    /// top, and before U5 the host paid its resting padding on top of it.
    static func readTierBottom(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset)
    }

    static func livePaneBottom(resting: CGFloat, paneInset: CGFloat) -> CGFloat {
        proseLeading(resting: resting, paneInset: paneInset) - paneInset
    }
}
