//
//  ShellSplit.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch A (row 2) — **the sidebar's container,
//  flat.** W8-3 ruled the liquid-glass floating pane out (*"i'd rather have
//  these more solid, geometric lines"*); Act 10 flattened the column's
//  INTERIOR and left the pane itself, because the pane is
//  `NavigationSplitView`'s own Tahoe rendering. She saw it at once: *"the
//  left edge of the program still has the liquid glass floating edge."*
//
//  ── THE CONTAINER DECISION, AND ITS REASON ─────────────────────────────
//  No public opt-out exists. Searched at the code, not assumed: the macOS 26
//  SwiftUI interface offers `NavigationSplitViewStyle` in exactly three
//  forms (automatic · balanced · prominentDetail), none flat; AppKit's
//  `NSSplitViewItem` gained only `automaticallyAdjustsSafeAreaInsets` and
//  the accessory view controllers at 26.0; and the 13g measurement recorded
//  in `VariorumApp.swift` had already shown the floating card is the KEY-
//  window appearance of the system sidebar, not a window style. So the
//  container is ours: an `HStack` — the sidebar column, ONE honest 1 pt
//  divider in the voice's `line`, the detail — with the pane row's own drag
//  grammar on the divider (`RootView.paneDivider`), a width the app
//  remembers, and a collapse that animates. Everything `RootView` hosts
//  beside the sidebar (the pane row, its inspectors — scraps, references,
//  the tray, the info panel, Block History, Versions) is untouched: they
//  live INSIDE the detail and were never the split view's.
//
//  ── WHAT MOVED WITH IT ─────────────────────────────────────────────────
//  · the sidebar toggle: the split view's toolbar button was system chrome;
//    it is now a declared act (`.toggleSidebar` — a toolbar door here and a
//    View-menu item on the platform's own ⌃⌘S), per-window state on the
//    `ShellRouter`;
//  · the width: `@AppStorage` (the app remembers one sidebar width — the
//    split view kept it per session; remembering it across launches is the
//    kinder of the two);
//  · the bottom status rows: they were a `safeAreaInset` of the split view's
//    sidebar column; they are the column's own bottom now (`SidebarView`).
//

import AppKit
import SwiftUI

struct ShellSplit<Sidebar: View, Detail: View>: View {
    let tokens: VoiceTokens
    /// Whether the sidebar column is on screen (per window — the router's).
    let sidebarShown: Bool
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let detail: () -> Detail

    /// The remembered width. `AppStorage` rather than window state: one
    /// sidebar width for the app, kept across launches.
    @AppStorage(Self.widthKey) private var sidebarWidth: Double = Self.idealWidth

    static var widthKey: String { "shellSidebarWidth" }
    static var minimumWidth: CGFloat { 180 }
    static var idealWidth: Double { 210 }
    static var maximumWidth: CGFloat { 360 }
    static var dividerWidth: CGFloat { 1 }
    /// **The seam's grip** (17o batch d, ledger row 9). Her words: *"the
    /// hitbox for adjusting the size of the left bar … too small … sometimes
    /// the I looking pointer."* It was 9 pt, and — worse — it was an
    /// `.overlay` on the 1-pt line, so only the half lying over the SIDEBAR
    /// could be reached: the detail is the HStack's next sibling and draws
    /// after the divider, so it won the right half's hits and gave her the
    /// editor's I-beam there. The grip is a real layout participant now, at
    /// `.zIndex(1)` over the seam, and this wide.
    static var gripWidth: CGFloat { 14 }

    /// The width the column draws at — the remembered value, clamped, so a
    /// stale or hand-edited default can never draw an unusable column.
    static func clamped(_ width: Double) -> CGFloat {
        min(max(CGFloat(width), minimumWidth), maximumWidth)
    }

    /// The split's own coordinate space: the sidebar's left edge is x = 0
    /// in it (nothing sits before the column), so a drag's location IS the
    /// wanted width — the pane row's `location.x / rowWidth` arithmetic,
    /// one pane over.
    private static var splitSpace: String { "variorum-shell-split" }

    var body: some View {
        HStack(spacing: 0) {
            if sidebarShown {
                sidebar()
                    .frame(width: Self.clamped(sidebarWidth))
                    .frame(maxHeight: .infinity)
                    .transition(.move(edge: .leading))
                divider
                    // Row 9: the seam draws AND hit-tests above the detail,
                    // which is the whole reason half the old grip was dead.
                    .zIndex(1)
            }
            detail()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .coordinateSpace(name: Self.splitSpace)
        .animation(.easeInOut(duration: 0.2), value: sidebarShown)
    }

    /// The one honest line, and the grip over it — the pane row's seam
    /// grammar (`RootView.paneDivider`): a 1 pt `line` with a wide invisible
    /// grip centred on it and the resize cursor inside it.
    ///
    /// **Row 9's fix, in three parts.** (1) The grip is a ZStack SIBLING of
    /// the line rather than an `.overlay` of it, so it is a real layout
    /// participant with its own frame; (2) the whole divider carries
    /// `.zIndex(1)` in the HStack, so the seam hit-tests above the detail —
    /// without that the detail (the next sibling, drawn after) won every
    /// point right of the line and she got the editor's I-beam over half the
    /// grip she was aiming at; (3) the cursor comes from an AppKit cursor
    /// rect and tracking area (`SeamCursor`) rather than `NSCursor.push()`,
    /// because a pushed cursor loses to the text view's own cursor rects the
    /// moment the mouse moves — which is exactly the I-beam she saw. Nothing
    /// is pushed, so nothing can be left unbalanced.
    private var divider: some View {
        ZStack {
            Rectangle()
                .fill(tokens.line)
                .frame(width: Self.dividerWidth)
                // **Row 41** (17o batch d; her follow-up: *"the line that
                // separates the left pane from the main editor is white for
                // just a tiny bit at the top"*). MEASURED on the dev-store
                // Debug build, not guessed: at the seam's x the window is
                // pure white (255,255,255) for the first ~40 pt while the
                // sidebar's ground (246,246,241) and the detail's
                // (251,251,247) are both painted to y = 0. The two columns'
                // BACKGROUNDS run under the window's toolbar band, as
                // backgrounds do; the divider is a laid-out view inside the
                // safe area, so it started below the band and the window's
                // own white showed through the 1-pt gap between them. The
                // LINE runs the height the grounds run; the GRIP deliberately
                // does not — a resize drag under the toolbar band would be a
                // new gesture, not a fix.
                .ignoresSafeArea(.container, edges: .top)
            Rectangle()
                .fill(Color.clear)
                .frame(width: Self.gripWidth)
                .contentShape(Rectangle())
                // Row 9's cursor half, THE THIRD ATTEMPT and the one that
                // works — see `SeamGrip`'s retired doc below for the two
                // that did not.
                .pointerStyle(.columnResize)
                .gesture(
                    DragGesture(coordinateSpace: .named(Self.splitSpace))
                        .onChanged { value in
                            sidebarWidth = Double(Self.clamped(Double(value.location.x)))
                        })
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    ShellGeometry.dividerGripFrame = $0
                }
                #endif
        }
        .frame(width: Self.dividerWidth)
        #if DEBUG
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            ShellGeometry.dividerLineFrame = $0
        }
        #endif
        .help("Drag to resize the sidebar")
    }
}

// ── ROW 9's CURSOR: TWO MEASURED FAILURES, THEN THE SUPPORTED API ──────
//
// The pointer inside the grip is its own problem, and it took three cuts to
// land. Each was WALKED on the dev-store Debug build and captured, because
// no mounted view can be asked what the pointer looks like.
//
//  1. SwiftUI `.onHover` + `NSCursor.push()` (the shipped road): the
//     window's cursor-rect machinery re-sets the pointer from the view under
//     it on every mouse-moved event, so the editor's I-beam won back the
//     moment she moved inside the grip — her *"sometimes the I looking
//     pointer"*. Captured: an I-beam four points from the seam.
//  2. An AppKit `NSViewRepresentable` owning a cursor RECT and a
//     `.cursorUpdate` tracking area, first with `hitTest` returning nil (so
//     clicks passed to SwiftUI's drag) and then taking the hits and the drag
//     itself. Captured both ways: with `hitTest` nil the I-beam still won —
//     a view outside the hit-test chain gets neither its cursor rect
//     honoured nor its tracking area's `cursorUpdate`; taking the hits got
//     rid of the I-beam and produced the plain ARROW, never the resize
//     cursor. `NSHostingView` manages the pointer for its own subtree, and
//     a representable's cursor rects do not outrank it.
//  3. **SwiftUI's own `.pointerStyle(.columnResize)`** (macOS 15+; the
//     deployment target is 26): the supported way to say this inside a
//     SwiftUI hierarchy, and the one the hosting view honours. Nothing is
//     pushed or popped, so nothing can be left unbalanced — which was the
//     other half of what was wrong with (1).
//
// The DRAG stays SwiftUI's, because it was never the broken part: with the
// divider at `.zIndex(1)` the gesture reaches the whole grip, walked by
// dragging from four points INSIDE the detail — the half that was dead
// before — and watching the seam follow.

#if DEBUG
/// Row 9's oracle: the seam's line and its grip, in the window's own space —
/// "the grip is wide, centred on the line, and reaches into the detail" is a
/// claim about two rectangles (the `SidebarGeometry` pattern).
@MainActor
enum ShellGeometry {
    static var dividerLineFrame: CGRect?
    static var dividerGripFrame: CGRect?

    static func reset() {
        dividerLineFrame = nil
        dividerGripFrame = nil
    }
}
#endif
