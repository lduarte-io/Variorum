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
    #if DEBUG
    /// **This shell's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape). DEBUG-only.
    @State private var oracleOwner = UUID()
    #endif

    static var widthKey: String { "shellSidebarWidth" }
    static var minimumWidth: CGFloat { 180 }
    /// **The fresh-install width** — the column's width until she drags the
    /// seam (a dragged width is stored under `widthKey` and always wins).
    ///
    /// **VX-737 (the VX-736 run, B2 — her R-736-6: "maybe just make the
    /// sidebar start out wider").** It was 210, and at 210 the window
    /// toolbar's "in ‹wing›" label crossed the column's line: the toolbar's
    /// leading items (the traffic lights, the sidebar toggle and New Note's
    /// glass group, then the label) are laid out by the window, not by this
    /// column — this shell is an `HStack`, not a split view, so nothing moves
    /// them with the seam — and they reach x ≈ 223 pt with "in home" in
    /// Terminal (≈ 219 in Study), measured on macOS 27.0.1. At 240 the label
    /// and its hover wash clear the line in both voices
    /// (`FreshSidebarWidthTests`).
    static var idealWidth: Double { 240 }
    static var maximumWidth: CGFloat { 360 }
    static var dividerWidth: CGFloat { SeamGrip.lineWidth }
    /// **The detail's width in a fresh window** — the room the Library's
    /// controls row and bulk row are measured at (the VX-175 and 13n-c
    /// geometry oracles: 1029 pt, which was 1240 − 210 − 1).
    static var defaultDetailWidth: CGFloat { 1029 }
    /// **The main window's fresh size** (`VariorumApp`'s `.defaultSize`):
    /// the sidebar's fresh width, its seam, and the detail's. VX-737,
    /// PROVISIONAL P-736-4: a wider fresh sidebar WIDENS THE WINDOW rather
    /// than narrowing the detail, because the Library's controls row is one
    /// line at the default window with the panel closed by only ≈ 4 pt in
    /// Terminal (SurfaceContracts, The Library). So the window grew by the
    /// sidebar's 30 pt (1240 → 1270) and the detail kept its 1029.
    static var defaultWindowSize: CGSize {
        CGSize(width: CGFloat(idealWidth) + dividerWidth + defaultDetailWidth, height: 840)
    }
    /// **The seam's grip** (17o batch d, ledger row 9). Her words: *"the
    /// hitbox for adjusting the size of the left bar … too small … sometimes
    /// the I looking pointer."* It was 9 pt, and — worse — it was an
    /// `.overlay` on the 1-pt line, so only the half lying over the SIDEBAR
    /// could be reached: the detail is the HStack's next sibling and draws
    /// after the divider, so it won the right half's hits and gave her the
    /// editor's I-beam there. The grip is a real layout participant now, at
    /// `.zIndex(1)` over the seam, and this wide.
    ///
    /// **18d's ladder, MAJOR-2:** the shape below is no longer written here
    /// — it is `SeamGrip` in `Core/Views`, which `SideColumn`'s three
    /// boundaries consume too. This stays as the name the shell's own pins
    /// and docs use, forwarding to the one constant.
    static var gripWidth: CGFloat { SeamGrip.width }

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
        #if DEBUG
        // 18k C4: this shell's seam, and no other window's.
        .onDisappear { ShellGeometry.release(owner: oracleOwner) }
        #endif
    }

    /// The one honest line, and the grip over it — **the shared seam**
    /// (`SeamGrip`, `Core/Views`). Row 9's fix was written here in three
    /// parts; 18d's ladder (MAJOR-2) moved the parts a component can own
    /// into that component, because batch 3 gave three more boundaries a
    /// draggable seam through `SideColumn` and every one of them was born
    /// with the OLD 9-pt overlay. What stays here is the part only a host
    /// can own: `.zIndex(1)` in the HStack below, and the arithmetic.
    ///
    /// The two measured cursor failures that led to `.pointerStyle` are
    /// written out below, kept here because this is where they happened.
    private var divider: some View {
        SeamGrip(
            tokens: tokens,
            space: Self.splitSpace,
            onDrag: { location in
                sidebarWidth = Double(Self.clamped(Double(location.x)))
            },
            help: "Drag to resize the sidebar",
            // **Row 41** (17o batch d; her follow-up: *"the line that
            // separates the left pane from the main editor is white for just
            // a tiny bit at the top"*). MEASURED on the dev-store Debug
            // build, not guessed: at the seam's x the window is pure white
            // (255,255,255) for the first ~40 pt while the sidebar's ground
            // (246,246,241) and the detail's (251,251,247) are both painted
            // to y = 0. The two columns' BACKGROUNDS run under the window's
            // toolbar band, as backgrounds do; the divider is a laid-out
            // view inside the safe area, so it started below the band and
            // the window's own white showed through the 1-pt gap between
            // them. The LINE runs the height the grounds run; the GRIP
            // deliberately does not — a resize drag under the toolbar band
            // would be a new gesture, not a fix.
            lineRunsUnderTheTopBand: true,
            onLineFrame: { frame in
                #if DEBUG
                ShellGeometry.recordLine(frame, owner: oracleOwner)
                #endif
            },
            onGripFrame: { frame in
                #if DEBUG
                ShellGeometry.recordGrip(frame, owner: oracleOwner)
                #endif
            })
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
    // **18k UNIT C4 — the two frames NAME THEIR OWNER** (the rule and its
    // reasons: `Core/Views/DebugOracleOwnership.swift`): the mounted
    // `ShellSplit`'s `oracleOwner`, released when that shell leaves. They
    // were bare statics every shell overwrote — after one window closed the
    // seam was ITS (measured red, `DebugOracleTwoWindowTests`).
    private static var lineSlot = OwnedSlot<CGRect>()
    private static var gripSlot = OwnedSlot<CGRect>()

    static var dividerLineFrame: CGRect? { lineSlot.value }
    static var dividerGripFrame: CGRect? { gripSlot.value }

    static func recordLine(_ frame: CGRect, owner: UUID) { lineSlot.publish(frame, owner: owner) }

    static func recordGrip(_ frame: CGRect, owner: UUID) { gripSlot.publish(frame, owner: owner) }

    /// A shell leaving: its own seam, and no other window's.
    static func release(owner: UUID) {
        lineSlot.release(owner: owner)
        gripSlot.release(owner: owner)
    }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() {
        lineSlot.forget()
        gripSlot.forget()
    }
}
#endif
