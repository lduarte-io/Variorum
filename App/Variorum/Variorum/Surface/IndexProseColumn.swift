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

import CoreGraphics

nonisolated enum IndexProseColumn {
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
}
