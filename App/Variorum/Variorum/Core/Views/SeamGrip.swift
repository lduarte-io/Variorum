//
//  SeamGrip.swift
//  Variorum (Mac)
//
//  **THE DRAGGABLE SEAM — one line, one wide grip, one cursor rule.**
//
//  Ledger row 9 is her words: *"the hitbox for adjusting the size of the left
//  bar … too small … sometimes the I looking pointer."* 17o batch d fixed it
//  for the shell's seam THREE ways, and the three are inseparable — take one
//  away and her symptom comes back:
//
//   1. **The grip is a real layout participant, 14 pt wide**, a ZStack
//      SIBLING of the 1-pt line rather than an `.overlay` of it. An overlay
//      has no frame of its own to reason about, and 9 pt was too small even
//      where it worked.
//   2. **The seam hit-tests ABOVE its neighbour** — the host puts
//      `.zIndex(1)` on it, because in an `HStack` later siblings sit above
//      earlier ones, so without it the neighbour drawn after the seam wins
//      every point on ITS side of the line and half the grip is dead. (Which
//      half depends on the seam's edge: a trailing panel's grip loses its
//      right half to the panel; a LEADING panel's grip loses its right half
//      to the content — the prose column, the page. Either way, half.)
//   3. **The cursor is `.pointerStyle(.columnResize)`**, not
//      `NSCursor.push()` on `.onHover`. The window re-sets the pointer from
//      the view under it on every mouse-moved event, so a pushed cursor
//      loses to the text view's own cursor rects the moment she moves inside
//      the grip — her *"sometimes the I looking pointer"*, measured. The two
//      roads that failed before this one are written out at `ShellSplit`.
//
//  **Why it is a component and not a paragraph copied twice** (18d's ladder,
//  MAJOR-2): the fix lived only inside `ShellSplit`, so when 18d batch 3
//  gave the book navigator, the book Index's chapter panel and the note Read
//  contents column a draggable boundary through `SideColumn`, all three got
//  the UNFIXED 9-pt overlay — row 9's defect on three more seams, and the
//  batch's own walk recorded the symptom ("a drag whose press had missed the
//  9-pt grip, so nothing was ever written"). One component in the shared
//  home is CLAUDE.md's hoist rule and is the only shape in which a future
//  seam cannot be born with the old defect.
//
//  What the seam does NOT own: the arithmetic. It reports where the pointer
//  is, in the host's own coordinate space, and the host decides what that
//  means (a sidebar width, a panel width, a split fraction). That is why one
//  component serves seams whose maths have nothing in common.
//

import SwiftUI

struct SeamGrip: View {
    /// The honest line she sees.
    static let lineWidth: CGFloat = 1
    /// The target she aims at (row 9: it was 9, and half of that was dead).
    static let width: CGFloat = 14

    let tokens: VoiceTokens
    /// The coordinate space a drag reports in — the host's own, declared by
    /// the host on the container the arithmetic is relative to.
    let space: String
    /// A drag, at `location` in that space. The host does the arithmetic.
    let onDrag: (CGPoint) -> Void
    var help: String = "Drag to resize"
    /// Row 41 (17o batch d): the SHELL seam's line runs under the window's
    /// toolbar band, where the two columns' grounds run, or the window's own
    /// white shows through the gap. The GRIP deliberately does not — a
    /// resize drag under the toolbar band would be a new gesture, not a fix.
    /// Every other seam lives inside the detail and wants neither.
    var lineRunsUnderTheTopBand: Bool = false
    /// Where the DEBUG oracles want their rectangles measured. `.global` for
    /// the shell (its pin compares against the window); a named space for a
    /// seam inside a surface.
    var frameSpace: CoordinateSpace = .global
    var onLineFrame: ((CGRect) -> Void)? = nil
    var onGripFrame: ((CGRect) -> Void)? = nil

    var body: some View {
        ZStack {
            line
            Rectangle()
                .fill(Color.clear)
                .frame(width: Self.width)
                .contentShape(Rectangle())
                // (3) The supported way to say this inside a SwiftUI
                // hierarchy — nothing pushed, so nothing left unbalanced.
                .pointerStyle(.columnResize)
                .gesture(
                    DragGesture(coordinateSpace: .named(space))
                        .onChanged { onDrag($0.location) })
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: frameSpace)
                } action: { onGripFrame?($0) }
        }
        // (1) The seam occupies the LINE's width in its host's stack; the
        // grip overhangs it on both sides, which is the whole point.
        .frame(width: Self.lineWidth)
        .help(help)
    }

    @ViewBuilder private var line: some View {
        let rule = Rectangle()
            .fill(tokens.line)
            .frame(width: Self.lineWidth)
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: frameSpace)
            } action: { onLineFrame?($0) }
        if lineRunsUnderTheTopBand {
            rule.ignoresSafeArea(.container, edges: .top)
        } else {
            rule
        }
    }
}

#if DEBUG
/// **The seam oracle** — every `SeamGrip` outside the shell reports here
/// (18d's ladder: MAJOR-2 minted it, round 2's MINOR-2 corrected its key,
/// MINOR-1 added the pane row). "The grip is wide, centred on the line, and
/// reaches into both sides" is a claim about two rectangles, so a pin reads
/// rectangles. The shell's seam keeps `ShellGeometry`, whose row-9 pin is
/// older than this and rides unmodified.
///
/// **Keyed by the FAMILY *and its SUBJECT*, which is the whole rule** —
/// round 2's MINOR-2, and the correction of a doc that claimed the rule was
/// already followed. Swift Testing runs SUITES in parallel, and the first
/// cut keyed on `widthKey` alone: a per-HOST `@AppStorage` constant
/// (`"bookNavigatorWidth"`), so EVERY book navigator in every suite and
/// every window wrote the same two entries. Both failure directions are
/// real — another suite supplying both rectangles gives a green pin about
/// someone else's window; supplying one gives a SPURIOUS red, because
/// "centred on the line" would then compare two windows. The subject is the
/// book's or note's id, minted live per suite, exactly as the oracles this
/// one sits beside are keyed (`BookIndexGeometry.columnFrames[readingID]`,
/// `ReadModeOracle.indexColumnFrames[postID]`).
@MainActor
enum SeamGeometry {
    /// The one key rule, so a view and a pin can never spell it differently.
    static func key(_ family: String, subject: String) -> String {
        "\(family)|\(subject)"
    }

    static var lineFrames: [String: CGRect] = [:]
    static var gripFrames: [String: CGRect] = [:]

    /// A pin clears ITS OWN seam and no other (the round-end Fable pass,
    /// MINOR-2 (c)). The old `reset()` wiped every subject's entries — and
    /// `onGeometryChange` republishes only on CHANGE, so a still-mounted seam
    /// in a parallel suite was never republished and that suite's `#require`
    /// timed out with no defect behind it.
    static func forget(_ key: String) {
        lineFrames[key] = nil
        gripFrames[key] = nil
    }
}
#endif
