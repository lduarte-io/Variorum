//
//  CommentGutterFace.swift
//  Variorum (Mac)
//
//  **VX-770 batch 2 — the BOARD surfaces' comment face: Write's gutter
//  machinery, hosted per ROW** (VX-730 · VX-731 · VX-728; the contract line,
//  SurfaceContracts › The note: *"Comments and callouts render in the
//  whitespace gutter outside the text area on every surface, stacked
//  vertically, and the prose column's measure and left edge never move for a
//  decoration"*).
//
//  Write draws a block's comments with ONE machinery (P-3): the ladder that
//  decides card / badge / nothing (`BlockDecor.commentFace`), the face that
//  draws it (`CommentCardView`, presented through `presentGutterFace`), and
//  the door (the comments panel). Write hosts it as overlay subviews of its
//  text view (`BlockDecorOverlayController`). The Takes article and Compare
//  are SwiftUI rows of per-block panes, so they cannot host subviews of one
//  text view — this is the same machinery hosted the other way: per row, as a
//  SwiftUI overlay that places the SAME AppKit face where the SAME ladder
//  says, opening the SAME panel. Nothing here decides, measures or presents a
//  comment on its own; the host supplies only geometry and the texts its own
//  feed already read.
//
//  The face never touches the prose: it is an overlay in the row's gutter, so
//  the row's layout — and with it the prose column's measure and left edge —
//  is identical with and without comments (pinned per surface).
//

import AppKit
import SwiftUI
import VariorumCore

/// One block's comment face on a board row.
struct CommentGutterFace: View {
    let session: AppSession
    let blockID: String
    /// The block's comments, panel order — from the host's own feed.
    let entries: [String]
    let tokens: VoiceTokens
    let geometry: Geometry
    /// Called when her comments panel closes (a host whose feed is not live
    /// re-reads then — the Takes row's shipped refresh).
    var onPanelClosed: () -> Void = {}
    @State private var panelShown = false

    /// **Where the gutter is, in the host's own terms** — the ladder's inputs.
    struct Geometry: Equatable {
        /// The prose container's left edge, measured from the GUTTER's left
        /// edge (Write's `textLeft`): how much whitespace the ladder may use.
        var textLeft: CGFloat
        /// How far right of the gutter's left edge the host's own leading
        /// edge sits — the overlay's origin.
        var hostLeading: CGFloat
        /// The face's top, in the host's coordinates (the block's first line,
        /// or under its callout glyph — R-13u3-3's stack).
        var top: CGFloat
        /// The block's text height (the card grows to it — R-VX179-2).
        var blockHeight: CGFloat
        /// How far below `top` the next face may begin (nil: nothing below).
        var roomBelow: CGFloat?

        /// The ONE decision (T1) — Write's ladder.
        var face: BlockDecor.CommentFace {
            BlockDecor.commentFace(
                textLeft: textLeft, top: top, blockHeight: blockHeight, roomBelow: roomBelow)
        }
    }

    var body: some View {
        let face = geometry.face
        if !entries.isEmpty, let rect = face.rect {
            CommentCardFaceView(
                face: face, entries: entries, tokens: tokens, identity: blockID,
                onClick: { panelShown = true })
                .frame(width: rect.width, height: rect.height)
                .popover(isPresented: $panelShown) {
                    CommentsPanel(session: session, blockID: blockID)
                }
                .onChange(of: panelShown) { _, shown in
                    if !shown { onPanelClosed() }
                }
                .recordsBoardCommentFace(blockID: blockID, Self.oracleFace(face, entries: entries))
                // The rect is in GUTTER coordinates; the overlay's origin is
                // the host's leading edge.
                .offset(x: rect.minX - geometry.hostLeading, y: rect.minY)
        }
    }

    /// What the oracle records for a face the ladder drew.
    static func oracleFace(_ face: BlockDecor.CommentFace, entries: [String]) -> BoardCommentFace {
        switch face {
        case .badge:
            BoardCommentFace(
                kind: .badge, entries: [], lineCap: 1,
                label: CommentCardView.badgeText(count: entries.count))
        case .card, .yields:
            BoardCommentFace(kind: .card, entries: entries, lineCap: nil, label: nil)
        }
    }
}

/// The AppKit face itself — `CommentCardView`, presented through the one road
/// (T2). The card is its own door (a press opens the panel), takes the wheel
/// only when its entries overflow it (`CommentCardLayout.wheelOwner`), and is
/// keyed to its block so its inner scroll returns to the top when it shows
/// another block's comments.
private struct CommentCardFaceView: NSViewRepresentable {
    let face: BlockDecor.CommentFace
    let entries: [String]
    let tokens: VoiceTokens
    let identity: String
    let onClick: () -> Void

    func makeNSView(context: Context) -> CommentCardView { CommentCardView() }

    func updateNSView(_ card: CommentCardView, context: Context) {
        card.identity = identity
        // Before the presentation: a face that is a door is the one that may
        // carry the inner scroller (`presentCard`).
        card.onClick = onClick
        card.presentGutterFace(face, entries: entries, tokens: tokens)
    }
}
