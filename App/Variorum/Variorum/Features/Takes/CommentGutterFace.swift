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
    /// **VX-793 — a DOOR's ask to open this block's panel** (Compare's
    /// Comments… and ⌘⇧'), nil where the host has no such door (the Takes
    /// board: its door is the bottom bar's sheet). The ask opens THE SAME
    /// panel the face's own press opens, anchored where the face stands — so
    /// an uncommented block (no face drawn) can be given its FIRST comment.
    var openRequest: OpenRequest? = nil
    @State private var panelShown = false
    /// The panel was opened by the door, not the face's press (VX-793): where
    /// the ladder yields (no room for a face) the panel still needs an anchor.
    @State private var openedByDoor = false
    /// **The face's SEAT under her open panel (VX-732, VX-770 batch 3).** The
    /// face is her comments panel's door AND its popover's anchor, and every
    /// host's feed is live (Compare's projection, the Takes board's
    /// `TakesCommentFeed`) — so deleting the block's LAST comment inside the
    /// panel would empty the face and tear the panel down under her, deleted
    /// fold and Restore included. While the panel is open the face keeps the
    /// entries it showed when she opened it if the live ones run out; once the
    /// panel closes it follows the store again.
    @State private var seat: [String] = []

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

        /// Where a DOOR-opened panel anchors when the ladder yields (no room
        /// for a face): a point at the gutter's edge on the block's first line
        /// (VX-793). Never drawn.
        var doorAnchor: CGRect {
            CGRect(x: max(0, textLeft - 1), y: top, width: 1, height: 1)
        }
    }

    /// **A door's ask, as the host hands it** (VX-793): `pending` is read in
    /// the face's body (so the observation is the face's own), `taken` tells
    /// the host the face opened its panel.
    struct OpenRequest {
        let pending: () -> Bool
        let taken: () -> Void
    }

    var body: some View {
        if let openRequest {
            // VX-793: a host with a door keeps a zero-size listener standing,
            // so the ask reaches the face even while it draws nothing (an
            // uncommented block).
            let asked = openRequest.pending()
            ZStack(alignment: .topLeading) {
                Color.clear.frame(width: 0, height: 0).allowsHitTesting(false)
                faceAndPanel
            }
            .onChange(of: asked, initial: true) { _, asked in
                guard asked else { return }
                // The seat a press would take (F1): her panel keeps what it
                // showed — for a first comment, nothing — whatever leaves.
                seat = entries
                openedByDoor = true
                panelShown = true
                openRequest.taken()
            }
            .onChange(of: panelShown) { _, shown in
                if !shown { openedByDoor = false }
            }
        } else {
            faceAndPanel
        }
    }

    /// The face, and the panel it is the door and the anchor of. A face is
    /// drawn only where there are comments to show; the anchor stands while
    /// the panel is open too — opened on an uncommented block by the door
    /// (VX-793), or kept by the SEAT after her last comment left (F1).
    /// Without a door (the Takes host) the panel opens only from a drawn
    /// face, so this is exactly the pre-VX-793 face.
    @ViewBuilder private var faceAndPanel: some View {
        let face = geometry.face
        let shown = panelShown && entries.isEmpty ? seat : entries
        if let rect = face.rect ?? (panelShown && openedByDoor ? geometry.doorAnchor : nil),
           !shown.isEmpty || panelShown {
            ZStack {
                Color.clear.allowsHitTesting(false)
                if !shown.isEmpty, face.rect != nil {
                    CommentCardFaceView(
                        face: face, entries: shown, tokens: tokens, identity: blockID,
                        onClick: {
                            seat = shown
                            panelShown = true
                        })
                        .recordsBoardCommentFace(blockID: blockID, Self.oracleFace(face, entries: shown))
                }
            }
            .frame(width: rect.width, height: rect.height)
            .popover(isPresented: $panelShown) {
                CommentsPanel(session: session, blockID: blockID)
            }
            .recordsBoardCommentPanel(blockID: blockID, open: panelShown)
            // The rect is in GUTTER coordinates; the overlay's origin is the
            // host's leading edge.
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
