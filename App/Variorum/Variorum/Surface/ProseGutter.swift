//
//  ProseGutter.swift
//  Variorum (Mac)
//
//  **THE ONE GUTTER GEOMETRY — 13u3 UNIT A1, built to `notes/plans/
//  phase-13u3-memo-gutter.md` §2 A (her ruling R-13u-9 / the master plan's
//  item 20, verbatim: *"comments need to make use of the whitespace gutter
//  and should never have an impact on moving the actual text around - same
//  with callouts"*).**
//
//  ── THE ONE LAW ──────────────────────────────────────────────────────────
//  The prose column's MEASURE and LEFT EDGE are decided by the surface's
//  width and NOTHING ELSE. No decoration — comment card, count badge,
//  callout wash, callout glyph — may move them, on any surface, ever. That
//  is what this type makes structural: a surface's horizontal geometry is a
//  pure function of its own width, computed here, and the decoration layer
//  is a READER of it with no door to write through. (`DecorLaneReservation`,
//  which the decorations DID write through — 17p batch b's lane, her R-Q4 —
//  is retired whole by this file; QUESTIONS #102's whole option space went
//  with it.)
//
//  ── WHY THE FRAME GREW INSTEAD ───────────────────────────────────────────
//  Decorations are overlay subviews OF THE TEXT VIEW (`BlockDecor
//  OverlayController`; never rendering attributes — TEXTKIT2 §3), so a
//  decoration has exactly the room the text view's own bounds give it. The
//  contained surfaces (the book Outline's inline editor and the read tier —
//  which is also the workspace read-cheap pane, the note window's read face
//  and the spread book's page) were sized BY THEIR HOST to the prose column
//  itself, so there was no room inside the view at all: 8 pt, and every
//  decoration clamped at 2, on the words. 17p batch b answered that by
//  moving the TEXT (the lane); she reversed it. The answer here is the other
//  one: the text view's FRAME absorbs the host's whitespace — the centring
//  leftover and the host's own padding — and the container is placed back
//  where the host used to put it. The prose does not move a point; the
//  gutter it always had on screen is now INSIDE the view, where a decoration
//  can stand in it.
//
//  ── BYTE-IDENTICAL, PROVED PER HOST ──────────────────────────────────────
//  Every conversion is a pair: a `bleed` (how far the surface reaches beyond
//  its SwiftUI slot, each side) and a placement. The pair is chosen so that
//  `(leading, column width)` in the HOST's coordinates is what it already
//  was at every window width — so heights are unchanged, `BookHeight
//  Manifest` learns nothing, and `SurfaceSizeMemory` keeps its records. The
//  proofs are in the UNIT A1 RECORD's host table (`notes/plans/
//  phase-13u3-faces.md`).
//

import AppKit
import Foundation

/// **A text surface's horizontal placement — ONE rule for every TK2 surface
/// in the app**, from Write's full-document editor to a take pane.
///
/// `NSTextView.textContainerInset` is SYMMETRIC, so an asymmetric placement
/// rides as the pair's MEAN with the container's origin overridden to the
/// LEADING edge (`widthTracksTextView` makes the container
/// `bounds − 2 × inset`, so the mean gives exactly `leading + trailing` of
/// total inset and the origin says where that total sits). The mean is NOT
/// rounded: rounding it would move the container's WIDTH by up to a point,
/// and the container's width is the measure the whole app's heights stand on.
nonisolated struct ProseGutter: Equatable, Sendable {
    /// The widest the prose column may be. nil = no cap — the column is
    /// whatever the surface's width leaves after the gutters (the workspace
    /// pane's shipped behaviour, and a take pane's).
    var maxColumn: CGFloat?
    /// The smallest gutter on either side — R9's floor, per surface.
    var minGutter: CGFloat
    /// Centred (Write's own rule: the column sits in the middle and both
    /// gutters grow) or anchored at the leading gutter (the spread book's
    /// page, whose whitespace has always been trailing).
    var centred: Bool
    /// How far this surface's FRAME reaches beyond the slot its SwiftUI host
    /// gives it, on each side — the host's whitespace, absorbed. Zero for a
    /// surface whose host already hands it the whole width (Write, the take
    /// panes). Consumed by the host as `.padding(.horizontal, -bleed)`, so
    /// the host's own reported geometry — and therefore every remembered
    /// length and every manifest row — is unmoved.
    var bleed: CGFloat = 0

    init(maxColumn: CGFloat?, minGutter: CGFloat, centred: Bool, bleed: CGFloat = 0) {
        self.maxColumn = maxColumn
        self.minGutter = minGutter
        self.centred = centred
        self.bleed = bleed
    }

    /// The leading and trailing insets at a given view width. PURE — this is
    /// the whole of the app's horizontal text geometry, so it is pinned
    /// rather than observed.
    ///
    /// The CENTRED arm is `EditorTypography.gutterInset` term for term (that
    /// function forwards here now), which is what makes Write's own geometry
    /// unmoved by this rework; the LEADING arm keeps the leading gutter fixed
    /// and lets the cap decide the column, which is what makes the spread
    /// book's page unmoved.
    func insets(viewWidth: CGFloat) -> (leading: CGFloat, trailing: CGFloat) {
        let room = max(0, viewWidth - 2 * minGutter)
        let column = min(maxColumn ?? room, room)
        guard centred else {
            return (minGutter, max(minGutter, viewWidth - minGutter - column))
        }
        // The column is EXACT and the odd point goes to the trailing gutter.
        // (`EditorTypography.gutterInset` — Write's shipped symmetric number —
        // is this leading value, so Write's left edge is unmoved; what moves
        // is the odd half-point that used to widen the CONTAINER to 681 at an
        // odd window width. The column's designed measure is 680, and an
        // exact column is what lets a host's clamp-then-inset be matched
        // point for point.)
        let leading = max(minGutter, ((viewWidth - column) / 2).rounded(.down))
        return (leading, max(minGutter, viewWidth - column - leading))
    }

    /// The prose column's width at a view width — `insets`' other face, for
    /// the readers that care about the MEASURE rather than the edges (the
    /// width-gated remeasure; the one-law pin).
    func columnWidth(viewWidth: CGFloat) -> CGFloat {
        let insets = insets(viewWidth: viewWidth)
        return max(0, viewWidth - insets.leading - insets.trailing)
    }

    // MARK: - The presets (one per host kind; the host table proves each)

    /// **Write's full-document editor** — R9's centred bounded column with
    /// the 28 pt floor. Byte-identical to the shipped
    /// `EditorTypography.gutterInset` by construction (it forwards here).
    static let write = ProseGutter(
        maxColumn: EditorTypography.maxColumnWidth,
        minGutter: EditorTypography.minGutter, centred: true)

    /// **A contained surface with no host conversion** — the shipped 8 pt
    /// each side, no cap. The default, so a host this unit did not convert
    /// (a drill's mounted read tier, a pin's bare surface) behaves exactly
    /// as it always did.
    static let contained = ProseGutter(
        maxColumn: nil, minGutter: EditorTypography.inlineSurfaceInset, centred: false)

    /// **The book Outline's two text tiers.** Its host centres a
    /// `BookView.proseColumn` column inside a 20 pt-padded pane, so
    /// absorbing BOTH gives Write's own rule at the pane's width — which is
    /// what "the Outline renders Write's surface at Write's column" (13c 2A)
    /// has always meant, now true of the gutter too.
    static func outline(bleed: CGFloat) -> ProseGutter {
        ProseGutter(
            maxColumn: EditorTypography.maxColumnWidth,
            minGutter: EditorTypography.minGutter, centred: true, bleed: bleed)
    }

    /// **The spread/paged book's page.** Leading-anchored, because that is
    /// where its prose has always sat (the page's whitespace is trailing);
    /// the 20 pt page padding is the bleed, and the 28 pt floor is exactly
    /// that padding plus the surface's own shipped 8.
    static let page = ProseGutter(
        maxColumn: EditorTypography.maxColumnWidth,
        minGutter: EditorTypography.minGutter, centred: false, bleed: 20)

    /// **The workspace's read-cheap pane and the note window's read face.**
    /// No cap — their prose has always run the pane's full measure, and
    /// capping it would narrow the measure, which is a face ruling nobody
    /// has made (QUESTIONS #117). The 20 pt pane padding is the bleed and
    /// becomes the gutter.
    static let pane = ProseGutter(
        maxColumn: nil, minGutter: EditorTypography.minGutter, centred: true, bleed: 20)
}

/// **The one question a decoration host asks its surface.** Both contained
/// text views and Write's editor adopt it, so `BlockDecorOverlayController`
/// reads one prose column without knowing which class it is driving.
///
/// It is READ-ONLY by design (17p batch b's `setDecorLane` was the write
/// door, and the write door was the defect): the surface's geometry is its
/// width's, and a decoration has no say in it.
@MainActor
protocol ProseGutterSurface: AnyObject {
    /// This surface's placement rule. Setting it re-places the container.
    var proseGutter: ProseGutter { get set }
    /// The prose column, in this view's own space.
    var proseLeft: CGFloat { get }
    var proseRight: CGFloat { get }
}

/// The shared implementation both `NSTextView` subclasses hold — a value,
/// not a base class, because `EditorTextView` and `PaneTextView` are
/// siblings (the `DecorLaneReservation` precedent, and the same reason).
nonisolated struct ProseGutterPlacement {
    private(set) var gutter: ProseGutter = .contained
    private(set) var leading: CGFloat = 0
    private(set) var trailing: CGFloat = 0
    /// False until a real (non-zero) width has been placed — a surface that
    /// has never laid out answers from its factory's own symmetric inset, so
    /// a pin or a preview that never lays out reads exactly what it always
    /// read.
    private(set) var isPlaced = false

    /// Re-place for this view width. Returns the SYMMETRIC inset the view
    /// should carry, or **nil when nothing moved** — so a settled surface
    /// costs two comparisons per layout pass and writes nothing.
    mutating func place(gutter: ProseGutter, viewWidth: CGFloat) -> CGFloat? {
        // A view with no width yet keeps the inset its factory gave it: a
        // placement computed at zero would write a zero gutter and the first
        // real layout pass would write it back, which is a visible flash on
        // every mount for no information at all.
        guard viewWidth > 0 else {
            self.gutter = gutter
            return nil
        }
        let insets = gutter.insets(viewWidth: viewWidth)
        let settled = isPlaced
            && abs(leading - insets.leading) < 0.01
            && abs(trailing - insets.trailing) < 0.01
        self.gutter = gutter
        guard !settled else { return nil }
        leading = insets.leading
        trailing = insets.trailing
        isPlaced = true
        return (insets.leading + insets.trailing) / 2
    }

    /// The container's leading edge — the `textContainerOrigin` override.
    var originX: CGFloat { leading }
    /// The prose column's right edge in the view's own space.
    func proseRight(bounds: CGFloat) -> CGFloat { bounds - trailing }
}
