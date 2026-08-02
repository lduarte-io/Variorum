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
//  `LazyVStack` already spaces rows by 6 and the frame pads by 5, so two
//  adjacent framed blocks keep a 6pt lane of surface between them and the
//  colour can never look like it spreads into the next block — the same
//  promise, obtained from the layout instead of from arithmetic.
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

    /// The pad inside the frame, and the corner — Write's callout card's
    /// own numbers (`BlockDecor.calloutRect`'s ideal pad of 5, radius 8).
    static let pad: CGFloat = 5
    static let cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        if let presentation {
            content
                .padding(Self.pad)
                .background(
                    Color(CalloutPalette.color(presentation.color, dark: dark)),
                    in: RoundedRectangle(cornerRadius: Self.cornerRadius))
                // The emoji rides the frame's leading edge, the way Write's
                // sits in the block's left margin — a mark on the block, not
                // on any one take.
                .overlay(alignment: .topLeading) {
                    if let emoji = presentation.emoji, !emoji.isEmpty {
                        Text(emoji)
                            .font(tokens.small)
                            .offset(x: -18, y: 2)
                            .accessibilityHidden(true)
                    }
                }
        } else {
            content
        }
    }
}
