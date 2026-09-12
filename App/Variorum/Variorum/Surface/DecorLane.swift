//
//  DecorLane.swift
//  Variorum (Mac)
//
//  **THE DECORATION LANE — ONE BRAIN FOR EVERY CONTAINED TEXT SURFACE**
//  (17p batch b, rows 5–6; her ruling R-Q4: *"the callout goes on top of the
//  comment badge which is on top of the text… in book view the comment thing
//  needs to be moved or only accessible on the left because it's blocking the
//  text"* → *"Reserve a left lane; emoji inside the frame"*).
//
//  ── WHY IT IS ITS OWN FILE ───────────────────────────────────────────────
//  The batch's WALK found that the book Outline shows a note through TWO
//  different text views — `EditorTextView.makeInlineEditor()` for the focused
//  note, and the read tier's `PaneTextView.makeReadSurface()` for every
//  expanded-but-unfocused one (`BookView`'s two branches) — and the second is
//  what an Outline shows by default, so it is the surface her screenshots
//  were of. Two sibling `NSTextView` subclasses cannot inherit one
//  implementation, and two copies of this arithmetic is exactly the drift
//  class (MobileSoul §3, review focus F-0). So the RULE lives here as a
//  value, and each surface is a three-line adopter: hold one, write the inset
//  the brain names, and override `textContainerOrigin` to the leading edge it
//  names.
//
//  ── THE THREE DECORATED SURFACES, AND WHAT EACH GETS ─────────────────────
//  There are exactly three hosts of `BlockDecorOverlayController` (grepped):
//    · the FULL editor (`EditorSurface`) — NO lane. Its gutter is the dynamic
//      centering inset (`EditorTypography.gutterInset`), already wide enough
//      for a margin comment card at any window that is not at `minGutter`; a
//      lane bolted onto it would fight `updateGutters` at every reflow.
//    · the CONTAINED editor (`InlineEditorSurface`) — LANE.
//    · the READ tier (`ReadPostView`) — LANE. Same 8 pt prose inset, same
//      decorations, same defect.
//  Each cell is pinned in `BlockDecorLaneTests`.
//

import AppKit

/// **A CONTAINED SURFACE'S ASYMMETRIC PROSE INSETS.**
///
/// `NSTextView.textContainerInset` is SYMMETRIC, so a left-only lane rides as
/// the pair's MEAN with the container's origin overridden to the LEADING
/// edge: the container's width becomes `bounds - (leading + trailing)` and its
/// right edge stays at `bounds - trailing`, untouched. The measure narrows by
/// the lane, which is the point (R9 — the margins stay sacred); growing the
/// symmetric inset instead would take the lane off the RIGHT margin too, for
/// room only the left needs.
///
/// **THE BRAIN IS THE ONE WRITER of a laned surface's horizontal inset, and
/// it never reads the view's inset back** — `originX` and `proseRight` are
/// answered from `insets`, so a second writer (the full editor's gutter rule,
/// `EditorTextView.updateGutters`) would move the container while the
/// decorations stayed self-consistent with the text somewhere else. A
/// surface therefore takes exactly ONE of the two: `updateGutters` refuses a
/// laned surface by precondition, and both contained factories are born at
/// the resting inset (`inlineSurfaceInset`) the brain measures against.
struct DecorLaneReservation {
    /// Does this surface reserve a lane at all? False for every surface but
    /// the two contained ones, so the whole mechanism is inert elsewhere and
    /// their inset paths are byte-identical.
    var reserves = false

    /// nil = the ORDINARY symmetric road (no lane reserved, released, or
    /// never) — the `textContainerOrigin` override defers to `super` exactly
    /// while this is nil.
    private(set) var insets: (leading: CGFloat, trailing: CGFloat)?

    init(reserves: Bool = false) {
        self.reserves = reserves
    }

    /// Reserve (or release) the lane. Returns the SYMMETRIC inset width the
    /// surface should now carry, or **nil when nothing changed** — the caller
    /// writes nothing and reports nothing, so a settled lane costs one
    /// comparison per render.
    ///
    /// "Nothing changed" is measured against the surface's RESTING leading
    /// inset, never against "never asked" (17p batch b ladder round 1,
    /// R1-2): the first ask on a laneless surface used to read `nil != 8`,
    /// answer "moved", and send every contained surface's first render back
    /// through its host door for nothing — once per visible note in a book
    /// Outline — while leaving the `textContainerOrigin` override live at
    /// the resting value, correct only by coincidence. A released lane
    /// returns to nil, so the override defers to `super` exactly while no
    /// lane is reserved.
    mutating func reserve(needed: Bool, trailing: CGFloat) -> CGFloat? {
        guard reserves else { return nil }
        let resting = EditorTypography.inlineInset(needsLane: false)
        let leading = EditorTypography.inlineInset(needsLane: needed)
        guard (insets?.leading ?? resting) != leading else { return nil }
        insets = needed ? (leading, trailing) : nil
        return ((leading + trailing) / 2).rounded()
    }

    /// The container's leading edge, or nil to defer to `super`.
    var originX: CGFloat? { insets?.leading }

    /// The prose column's right edge. With no lane this is the shipped
    /// arithmetic (`bounds - textContainerInset.width`) by identity, which is
    /// what keeps every existing decoration geometry unchanged.
    func proseRight(bounds: CGFloat, symmetricInset: CGFloat) -> CGFloat {
        bounds - (insets?.trailing ?? symmetricInset)
    }
}

/// **The one question the decoration controller asks its surface.**
///
/// Both contained text views adopt it, so `BlockDecorOverlayController`
/// reserves the lane without knowing which class it is driving — no type
/// switch, and a future contained surface joins by adopting.
@MainActor
protocol DecorLaneSurface: AnyObject {
    /// Reserve or release the lane. Returns true when the prose column
    /// actually MOVED, which is the caller's cue to have the decorations
    /// computed again against the new edge (they were computed against the
    /// old one — the walk's finding W-1).
    @discardableResult
    func setDecorLane(needed: Bool) -> Bool

    /// The prose column, in this view's own space.
    var proseLeft: CGFloat { get }
    var proseRight: CGFloat { get }
}
