//
//  TakesCalloutFrame.swift
//  Variorum
//
//  Phase 13k, K9 — THE CALLOUT FRAME, in Take mode.
//
//  Her instruction (2026-08-01): *"callouts are supposed to be added to take
//  mode as well"*, and the ruled shape (sitting round 2, Q4): **ONE FRAME
//  AROUND THE FAN** — the frame (colour + emoji) wraps the block's whole
//  takes region; one block, one frame, takes inside it.
//
//  ── Why one frame and never one per card ────────────────────────────────
//
//  R16/R27: a callout frame is the BLOCK's, and its takes SHARE it. A frame
//  per take card would say the opposite — that each take carries its own —
//  and it would be a lie the store cannot back: `block.presentation` is one
//  column on one block row. So the frame goes where the block's region is,
//  and every take renders inside it whatever the fan style does (stacked
//  beneath, in a carousel, split into the slot, or out in the margin rail —
//  the rail is part of the region, which is exactly why this wraps the row's
//  whole HStack rather than the cell).
//
//  ── The mechanism, and P-8 ──────────────────────────────────────────────
//
//  A SwiftUI background shape, never TK2 per-range rendering attributes:
//  the board's rows are ordinary SwiftUI views and the frame is a rounded
//  rect drawn behind one. (Write's frame is an overlay VIEW over the TK2
//  surface for the same reason — `BlockDecorOverlayController.renderCallouts`;
//  neither surface ever paints a callout with a text attribute.) The COLOUR
//  is `CalloutPalette`'s, so the two surfaces resolve the same token name to
//  the same wash and a new palette colour reaches both at once.
//
//  ── R17's white gap, honoured by construction ───────────────────────────
//
//  Write pads a callout only as far as leaves base background between it and
//  its neighbours (`BlockDecor.verticalPad`, minimum 6). Here the article's
//  `LazyVStack` already spaces rows by 6 and the frame pads by 5 VERTICALLY,
//  so two adjacent framed blocks keep a 6pt lane of surface between them and
//  the colour can never look like it spreads into the next block — the same
//  promise, obtained from the layout instead of from arithmetic.
//
//  ── The one law, sideways (VX-782) ─────────────────────────────────────
//
//  Horizontally the frame is BLEED, never layout: its colour reaches `pad`
//  past the row on each side, so the prose's measure and left edge are a
//  plain row's (pinned — `TakesCalloutOneLawTests`).
//

import SwiftUI
import VariorumCore

/// Wraps a block's takes region in its callout frame; a no-op where the
/// block is plain (`presentation == nil`), so an unframed row's layout is
/// byte-for-byte what it was.
struct TakesCalloutFrame: ViewModifier {
    let presentation: BlockPresentation?
    let tokens: VoiceTokens
    let dark: Bool
    /// The block the frame belongs to — the DEBUG frame probe's key (VX-782).
    let blockID: String

    /// The pad inside the frame, and the corner — Write's callout card's
    /// own numbers (`BlockDecor.calloutRect`'s ideal pad of 5, radius 8).
    static let pad: CGFloat = 5
    static let cornerRadius: CGFloat = 8
    /// Where the emoji sits from the frame's top-leading corner — named
    /// (VX-770 batch 2) so the row's comment face can stack UNDER it
    /// (R-13u3-3) without a second copy of the number.
    static let emojiOffset = CGSize(width: -18, height: 2)

    func body(content: Content) -> some View {
        if let presentation {
            content
                // R17's white gap: the frame's VERTICAL air stays layout (the
                // rows are 6 apart, the pad 5 — the header's promise).
                .padding(.vertical, Self.pad)
                // **VX-782 — the one law: the frame's HORIZONTAL air is BLEED,
                // never layout.** The colour reaches `pad` past the row on
                // each side (`ProseGutter.bleed`'s idiom), so the frame wraps
                // the prose exactly as it always looked while the row keeps the
                // plain row's measure and left edge — a decoration never moves
                // the prose (SurfaceContracts › The note; Write's wash is a
                // background for the same reason, `BlockDecor.calloutRect`).
                // The pre-fix `.padding(pad)` inset the row on all four sides,
                // so a callout block's prose started 5 pt right of a plain
                // block's and measured 10 pt narrower (R-B2-1).
                .background {
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .fill(Color(CalloutPalette.color(presentation.color, dark: dark)))
                        // VX-782's oracle (DEBUG): the frame's visible rectangle.
                        .takesCalloutFrameProbe(blockID: blockID)
                        .padding(.horizontal, -Self.pad)
                }
                // The emoji rides the frame's leading edge, the way Write's
                // sits in the block's left margin — a mark on the block, not
                // on any one take. `emojiOffset` is from the FRAME's corner,
                // which now stands `pad` left of this view's own edge.
                .overlay(alignment: .topLeading) {
                    if let emoji = presentation.emoji, !emoji.isEmpty {
                        Text(emoji)
                            .font(tokens.small)
                            .offset(x: -Self.pad + Self.emojiOffset.width, y: Self.emojiOffset.height)
                            .accessibilityHidden(true)
                    }
                }
        } else {
            content
        }
    }
}

#if DEBUG
/// **VX-782's oracle — a callout frame's visible rectangle, in the window.**
/// The one-law pin reads it beside the prose column the frame surrounds: the
/// frame must still be DRAWN around the prose (its colour on both sides),
/// while the prose's left edge and measure are a plain row's. Scoped by the
/// mounting session like `TakeRailGeometry` (parallel suites never read each
/// other's), keyed by the block, last report wins (a block has one frame).
@MainActor
enum TakesCalloutFrameGeometry {
    private static var worlds: [String: [String: CGRect]] = [:]

    static func record(blockID: String, _ frame: CGRect, in scope: String) {
        worlds[scope, default: [:]][blockID] = frame
    }

    static func frame(blockID: String, in scope: String) -> CGRect? {
        worlds[scope]?[blockID]
    }

    /// A pin resets ITS OWN scope before its mount, and no other.
    static func reset(_ scope: String) { worlds[scope] = nil }
}

private struct TakesCalloutFrameProbe: ViewModifier {
    let blockID: String
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            TakesCalloutFrameGeometry.record(blockID: blockID, $0, in: scope)
        }
    }
}
#endif

extension View {
    /// VX-782's oracle write: this view's frame is the callout frame's
    /// visible rectangle (a no-op outside DEBUG).
    @ViewBuilder
    func takesCalloutFrameProbe(blockID: String) -> some View {
        #if DEBUG
        self.modifier(TakesCalloutFrameProbe(blockID: blockID))
        #else
        self
        #endif
    }
}
