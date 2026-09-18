//
//  ViewportCarry.swift
//  Variorum (Mac) — Surface (the pure surface authorities' home, beside
//  `BookHeightManifest`, `LandingAuthority` and `PaneTextAuthority`)
//
//  **Phase 13u2b UNIT 3 — a mode switch keeps the carried block's height.**
//
//  The binding design record is `notes/plans/navigation-landing-architecture-trace.md`
//  §6, which measured the whole of her secondary report: the cross-mode carry
//  WORKS (`CurrentBlockMemory` carries the block), but *"each surface has its
//  own REVEAL POLICY: Write asks AppKit for minimal scroll-to-visible; Takes
//  restores its remembered article offset…; Read/Index land the block at the
//  TOP… Same block, four policies ⇒ four heights — by design, each defensible
//  alone, never chosen as a set."* This file is the missing set: ONE rule for
//  NOTE MODE SWITCHES — **the carried block is placed at the same VIEWPORT
//  FRACTION it occupied in the outgoing mode.**
//
//  **A fraction, never a pixel**, and that is the trace's own conclusion
//  rather than a shortcut: the surfaces' visual deltas — take strips, callout
//  frames, the editing ring's wrap difference, P3's read-cheap/live tier split
//  — make pixel identity a false promise, and she pre-accepted the tolerance
//  in advance (*"if this is very difficult bc of the different visual elements
//  of takes & stuff, I do think that's fine"*).
//
//  **What "the same viewport fraction" MEANS here, stated once because
//  everything below is arithmetic on it:** the block's own f-point sits at the
//  viewport's f-point. f = 0 is the block flush with the top of the viewport,
//  f = 1 flush with the bottom, f = 0.5 the block centred. This is exactly
//  SwiftUI's `UnitPoint` anchor semantics, which is why the SwiftUI surfaces
//  can honour it EXACTLY through the `scrollTo(_:anchor:)` they already use —
//  no new scroll mechanism, no second landing road — and it is the one
//  definition both an AppKit surface (which knows its block's height at aim
//  time) and a SwiftUI one (which does not) can express without lying.
//
//  It also degrades in the right direction. A block that renders δ points
//  taller in the arriving surface than in the one she left lands with its top
//  at most f·δ away from where it was; the "distance from the top as a
//  fraction of the viewport" definition would be off by f·blockHeight — the
//  whole block — which on a three-line paragraph is several lines rather than
//  a fraction of one.
//
//  Pure: no SwiftUI view, no AppKit, no store, no clock. Every number is
//  handed in, so the whole rule is arithmetic a unit test can pin from both
//  ends.
//

import CoreGraphics
import Foundation
import SwiftUI

/// The one rule for where a mode switch puts the carried block.
nonisolated enum ViewportCarry {
    /// What one surface says about where the carried block sits, handed to the
    /// arriving surface through the router. In-memory and one-shot: a mode
    /// switch is one act, and nothing here is ever persisted (a per-note
    /// `UserDefaults` key is the hazard class `KnownIssuesAndTechDebt`'s row
    /// on per-note defaults already owns — this fact is worth less than that
    /// leak).
    struct Place: Equatable, Sendable {
        /// The note the place is about — a place in another note means nothing.
        let postID: String
        /// The block the place is about. The arriving surface consumes the
        /// carry only for THIS block: if the current block changed between the
        /// switch and the arrival, the standing reveal is the honest answer.
        let blockID: String
        /// Where it sat, in the sense the file header defines.
        let fraction: Double
    }

    /// The fraction a block occupies of its viewport — the CAPTURE half.
    ///
    /// `blockTop` is the block's top relative to the viewport's top (negative
    /// when the block starts above the fold); `blockHeight` its full height,
    /// including any internal newlines' lines (I4 — a block is one paragraph
    /// on the surface, but its text may hold several).
    ///
    /// **The clamps, each with its reason, all pinned:**
    /// - **No geometry** (a viewport or block of zero/negative height, or a
    ///   number that is not finite) ⇒ `nil`. Nothing to carry.
    /// - **The block is wholly off screen** ⇒ `nil`, deliberately. Carrying
    ///   "it was 400 pt above the fold" would land the arriving surface with
    ///   the block off screen, which is not continuity; the arriving surface
    ///   keeps its own standing reveal, which at least shows her the block.
    /// - **The block is PARTLY off screen** ⇒ clamped into 0…1. It was at an
    ///   edge; the arriving surface puts it at that edge.
    /// - **The block is exactly as tall as the viewport** (within a point) ⇒
    ///   0.5. Every anchor produces the same placement there, so the value has
    ///   only to be defined, not chosen.
    /// - **The block is TALLER than the viewport** ⇒ no special case at all:
    ///   the same formula yields 0…1 exactly when the block covers the
    ///   viewport, and the clamp catches the rest.
    static func fraction(
        blockTop: Double, blockHeight: Double, viewportHeight: Double
    ) -> Double? {
        guard blockTop.isFinite, blockHeight.isFinite, viewportHeight.isFinite,
              viewportHeight > 0, blockHeight > 0
        else { return nil }
        guard blockTop < viewportHeight, blockTop + blockHeight > 0 else { return nil }
        let span = viewportHeight - blockHeight
        guard abs(span) >= 1 else { return 0.5 }
        return min(max(blockTop / span, 0), 1)
    }

    /// The SwiftUI APPLY half: the anchor a `ScrollViewProxy.scrollTo` gets.
    ///
    /// `scrollTo(_:anchor:)` aligns the target's anchor point with the scroll
    /// view's — which is this file's definition of the fraction, exactly. So a
    /// SwiftUI surface honours the carry by passing this where it passed
    /// `.center` or `.top`, and nothing else about its landing changes.
    static func anchor(_ fraction: Double) -> UnitPoint {
        UnitPoint(x: 0.5, y: CGFloat(min(max(fraction, 0), 1)))
    }

    /// The AppKit APPLY half: how many points to leave between the viewport's
    /// top and the block's top, so that the block lands at `fraction`.
    ///
    /// Negative for a block taller than the viewport (the page is scrolled
    /// PAST its top, which is what "the block's f-point at the viewport's
    /// f-point" means there) — deliberate, and pinned.
    static func topInset(
        fraction: Double, blockHeight: Double, viewportHeight: Double
    ) -> Double {
        guard blockHeight.isFinite, viewportHeight.isFinite else { return 0 }
        return min(max(fraction, 0), 1) * (viewportHeight - blockHeight)
    }
}
