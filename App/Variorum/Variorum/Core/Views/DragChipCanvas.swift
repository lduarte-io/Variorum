//
//  DragChipCanvas.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  **The compact drag image, AT THE GRAB POINT** — librarywalkpolish VR-116
//  (W-4, R-LWP-3), her words: *"maybe as you drag it becomes just the title"*,
//  and *"it should move to be where your cursor is so dragging into something
//  feels natural and you aren't dragging with an offset"*.
//
//  **MOVED HERE from the Bookcase (`Features/Shelf/ShelfView.swift`) at its
//  second consumer** — VX-288, the Open list's rows (the VX-283 run, U2; her
//  ruling on VX-70: the chip rides VX-288 *"Only on the Open list's rows"*).
//  CLAUDE.md's placement rule: a view consumed by two features moves to the
//  shared home at the next touch. A parity move: the Bookcase's names
//  (`BookDragChip`, `BookDragSource.chipCenter` / `.placement` / `.canvas`)
//  still compile and answer exactly as before — `BookcaseDragFaceTests` is
//  untouched — and read these.
//

import SwiftUI

/// **Where the chip sits** (pure, pinned — `BookcaseDragFaceTests`). SwiftUI
/// centres a drag preview over its SOURCE view (Apple's own words for
/// `draggable(_:preview:)`), so the preview is a canvas CENTRED ON THE SOURCE
/// — clear everywhere but the chip, which sits centred on where the pointer
/// took hold. librarywalkpolish round 1's MAJOR-1: the canvas grows by the
/// chip's own size on every side, so a grab near a row's edge never cuts it
/// (clamping the chip inside a row-sized canvas would move it OFF the cursor
/// near the edges — the offset R-LWP-3 forbids).
nonisolated enum DragChipPlacement {
    /// Where the chip centres, in the SOURCE's space: the grab point, held to
    /// the source (its centre when no pointer was seen).
    static func chipCenter(size: CGSize, grab: CGPoint?) -> CGPoint {
        let point = grab ?? CGPoint(x: size.width / 2, y: size.height / 2)
        return CGPoint(
            x: min(max(point.x, 0), max(size.width, 0)),
            y: min(max(point.y, 0), max(size.height, 0)))
    }

    /// The canvas — the source grown by one chip on every side — and the
    /// chip's top-left in it: grab + margin − half a chip, on whole points (so
    /// its edges draw crisp, at most half a point from the exact grab).
    static func placement(
        source: CGSize, chip: CGSize, grab: CGPoint?
    ) -> (canvas: CGSize, chipOrigin: CGPoint) {
        let center = chipCenter(size: source, grab: grab)
        let canvas = CGSize(
            width: max(source.width, 1) + 2 * chip.width,
            height: max(source.height, 1) + 2 * chip.height)
        let origin = CGPoint(
            x: (center.x + chip.width / 2).rounded(),
            y: (center.y + chip.height / 2).rounded())
        return (canvas, origin)
    }
}

/// The drag canvas's layout: it measures its one subview (the chip) and
/// answers `DragChipPlacement.placement` — the margin IS the chip's own size,
/// whatever the title makes it. (The Bookcase's `GrabCanvas`, moved.)
struct DragChipCanvas: Layout {
    let source: CGSize
    let grab: CGPoint?

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let chip = subviews.first?.sizeThatFits(.unspecified) ?? .zero
        return DragChipPlacement.placement(source: source, chip: chip, grab: grab).canvas
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard let chipView = subviews.first else { return }
        let chip = chipView.sizeThatFits(.unspecified)
        let origin = DragChipPlacement.placement(source: source, chip: chip, grab: grab).chipOrigin
        chipView.place(
            at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
            anchor: .topLeading, proposal: ProposedViewSize(chip))
    }
}

/// **The compact title chip** — a title (and the star, when starred) on the
/// voice's paper with a hairline: the row's words, lifted. The Bookcase's book
/// chip at its board's body size; the Open list's at the sidebar's own
/// register (`font` says which).
struct DragTitleChip: View {
    let title: String
    var starred: Bool = false
    let font: Font
    let tokens: VoiceTokens

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            if starred {
                Text(StarCopy.glyph)
                    .font(tokens.small)
                    .foregroundStyle(tokens.star)
            }
            Text(tokens.chromeLabel(title))
                .font(font)
                .foregroundStyle(tokens.ink)
        }
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1))
    }
}

/// **A row as a drag source whose image is a chip at the grab point** — the
/// payload made when the drag BEGINS (`draggable`'s payload is an autoclosure
/// SwiftUI runs then, never while drawing), the preview the chip on a canvas
/// centred over the row, the chip where the pointer last hovered (which is
/// where a press lands). The Bookcase's `BookDragSource` shape, generic.
struct ChipDragSource<Payload: Transferable, Chip: View>: ViewModifier {
    let payload: () -> Payload
    @ViewBuilder let chip: () -> Chip

    @State private var grab: CGPoint?
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .onContinuousHover(coordinateSpace: .local) { phase in
                if case .active(let point) = phase { grab = point }
            }
            .draggable(payload()) {
                DragChipCanvas(source: size, grab: grab) { chip() }
            }
    }
}
