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
            }
            detail()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .coordinateSpace(name: Self.splitSpace)
        .animation(.easeInOut(duration: 0.2), value: sidebarShown)
    }

    /// The one honest line, and the drag under it — the pane row's seam
    /// grammar (`RootView.paneDivider`): a 1 pt `line`, a 9 pt invisible
    /// grip, the resize cursor on hover.
    private var divider: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(width: Self.dividerWidth)
            .overlay {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 9)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(coordinateSpace: .named(Self.splitSpace))
                            .onChanged { value in
                                sidebarWidth = Double(Self.clamped(Double(value.location.x)))
                            })
                    .onHover { inside in
                        if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                    }
            }
            .help("Drag to resize the sidebar")
    }
}
