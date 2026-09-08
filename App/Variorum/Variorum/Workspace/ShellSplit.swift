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
            Rectangle()
                .fill(Color.clear)
                .frame(width: Self.gripWidth)
                .contentShape(Rectangle())
                .overlay { SeamCursor() }
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

/// **The seam's cursor, from AppKit** (17o batch d, row 9). SwiftUI's
/// `.onHover` + `NSCursor.push()` is the wrong tool over a text view: the
/// window's cursor-rect machinery re-sets the cursor on every mouse-moved
/// event from the view under the pointer, so the editor's I-beam wins back
/// the moment she moves inside the grip — her *"sometimes the I looking
/// pointer"*. A cursor RECT plus a `.cursorUpdate` tracking area speak the
/// same language AppKit does. `hitTest` returns nil so the view is
/// transparent to clicks and SwiftUI's drag gesture is untouched.
private struct SeamCursor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { SeamCursorView() }
    func updateNSView(_ view: NSView, context: Context) {}

    private final class SeamCursorView: NSView {
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func resetCursorRects() {
            discardCursorRects()
            addCursorRect(bounds, cursor: .resizeLeftRight)
        }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            for area in trackingAreas { removeTrackingArea(area) }
            addTrackingArea(NSTrackingArea(
                rect: .zero,
                options: [.cursorUpdate, .activeInKeyWindow, .inVisibleRect],
                owner: self))
        }

        override func cursorUpdate(with event: NSEvent) {
            NSCursor.resizeLeftRight.set()
        }
    }
}

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
