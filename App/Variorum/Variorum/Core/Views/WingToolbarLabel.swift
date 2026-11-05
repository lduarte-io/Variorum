//
//  WingToolbarLabel.swift
//  Variorum (MAC ONLY) — Core/Views (the window toolbar's "in ‹wing›", the
//  wing switcher's door — `RootView` composes it)
//
//  **VX-833 (2) + VX-844 (the VX-828 run, batch B).** Her two asks about the
//  toolbar's "in ‹wing›" label (VX-552/VX-644 — the switcher's door):
//  · VX-833: it sits RIGHT-ALIGNED in the sidebar's top bar, never crossing
//    the vertical divider into the content area (her screenshot: it floated
//    loosely after the sidebar buttons);
//  · VX-844: a name longer than its space SCROLLS within the space it has,
//    car-radio style — the ellipsis explicitly declined.
//
//  THE MECHANISM (traced, B0): the label was the toolbar's third `.navigation`
//  item with `.frame(maxWidth: 160, alignment: .leading)` and a tail
//  truncation — a width that knew nothing of the column. The toolbar's leading
//  items are laid out by the WINDOW (traffic lights, the sidebar toggle, New
//  Note's glass group), never by the column (`ShellSplit` is an `HStack`), so
//  the label floated after New Note, and any name past the ≈ 58 pt left at the
//  240-pt default crossed the line (J5's "in walk wing").
//
//  THE BUILD (the fork's ruling — VX-833 (2)'s shape confirmed; P-828-2 (a)):
//  · the SPACE (pure, `WingLabelSpace`): the column's line (the clamped
//    `shellSidebarWidth` — the column's width IS its line's x) − 8 pt of air
//    (`FreshSidebarWidthTests.air`) − the item's own leading edge, READ live in
//    window coordinates by a zero-size AppKit probe (`WindowLeadingEdgeProbe` —
//    the leading items move: full screen drops the traffic lights), the VX-736
//    measurement standing in until the first read. The words stand at the
//    space's TRAILING edge; the hover wash hugs the words, never the empty run
//    before them. Two edges, ruled: under a 24-pt space the label is NOT drawn
//    (a sliver that cannot show a letter is no door — P-2; ⌘L and both
//    mastheads remain); with the sidebar hidden there is no line, so the label
//    keeps its old place after New Note with the old 160-pt cap.
//  · the MARQUEE (pure plan, `WingMarqueePlan`; the view, `WingMarquee`): the
//    TICKER — rest on the name's start 2.5 s, travel left at 25 pt/s with a
//    24-pt gap and the name again behind it, until that copy stands exactly
//    where the start rested (a seamless wrap), rest, repeat. Decided purely by
//    (the words' width, the space): when the words fit there is NO clock of
//    any kind (no TimelineView, no timer, no repeating animation — P-8); the
//    loop is a cancellable task keyed on (name, space, plan), so a rename, a
//    resize or a switch that makes the name fit stops it, and so does the view
//    leaving. Hard clips at both edges (no ellipsis — declined; no fade — the
//    car radio's own window). Reduce Motion: no movement — the start, clipped;
//    the hover's help carries the whole name.
//

import AppKit
import SwiftUI

// MARK: - The space (pure, pinned)

nonisolated enum WingLabelSpace {
    /// Air between the label's hover wash and the column's line — the VX-736
    /// oracle's (`FreshSidebarWidthTests.air`).
    static let air: CGFloat = 8
    /// Under this the label is not drawn (P-828-2's first edge).
    static let floor: CGFloat = 24
    /// The words' cap where no column line exists (the sidebar hidden) — the
    /// label's old frame, kept for that one case (P-828-2's second edge).
    static let looseWordsCap: CGFloat = 160
    /// The item's leading edge before the probe's first read — VX-736's
    /// measurement (the words' origin ≈ 173.8 pt in both voices, less the
    /// quiet style's 5-pt wash inset; `vx-736-hotfix-101.md:370`).
    static let fallbackOrigin: CGFloat = 169

    enum Placement: Equatable, Sendable {
        /// No room for a letter — nothing drawn.
        case hidden
        /// The item's whole width, its words trailing — the line minus the
        /// air minus the item's leading edge.
        case column(CGFloat)
        /// The sidebar hidden: the old leading place, the words capped here.
        case loose(wordsCap: CGFloat)
    }

    /// **THE RULE.** `columnLine` is the column's width (its line's x in the
    /// window); `origin` the item's leading edge in the window, nil until read.
    static func placement(sidebarShown: Bool, columnLine: CGFloat, origin: CGFloat?) -> Placement {
        guard sidebarShown else { return .loose(wordsCap: looseWordsCap) }
        let space = columnLine - air - (origin ?? fallbackOrigin)
        return space < floor ? .hidden : .column(space)
    }

    /// The widest the words may draw inside a placement — the space less the
    /// quiet style's wash inset on both sides (the wash IS the button's frame).
    static func wordsMaxWidth(in placement: Placement, washInset: CGFloat) -> CGFloat {
        switch placement {
        case .hidden: 0
        case .column(let width): max(width - 2 * washInset, 0)
        case .loose(let cap): cap
        }
    }
}

// MARK: - The marquee's plan (pure, pinned — P-828-2 (a), the ticker)

nonisolated enum WingMarqueePlan: Equatable, Sendable {
    /// The words fit (or Reduce Motion): drawn still — no clock exists.
    case still
    /// The words overflow: the ticker.
    case ticker(Ticker)

    struct Ticker: Equatable, Sendable {
        /// How far one pass travels — the words and the gap — so the copy
        /// behind them ends exactly where the start rested.
        let travel: CGFloat
        /// One pass, at the steady speed.
        let duration: Double
        /// The rest on the name's start before each pass.
        let rest: Double
    }

    /// The ruled numbers (PROVISIONAL — her eye on the walk).
    static let rest: Double = 2.5
    static let speed: CGFloat = 25
    static let gap: CGFloat = 24
    /// Sub-point differences are measurement noise, never an overflow.
    static let tolerance: CGFloat = 0.5

    static func plan(words: CGFloat, viewport: CGFloat, reduceMotion: Bool) -> WingMarqueePlan {
        guard !reduceMotion, viewport > 0, words > viewport + tolerance else { return .still }
        let travel = words + gap
        return .ticker(Ticker(travel: travel, duration: Double(travel / speed), rest: rest))
    }

    /// Whether this plan runs a loop at all — false is "no standing timer on
    /// the common case" (P-8), as a state.
    var loops: Bool {
        if case .ticker = self { return true }
        return false
    }

    /// The loop's key: the name, the space (whole points) and the plan — a
    /// change to any restarts (or ends) the loop.
    struct LoopKey: Equatable, Sendable {
        let words: String
        let space: Int
        let plan: WingMarqueePlan
    }
}

// MARK: - The marquee (the words, still or ticking)

struct WingMarquee: View {
    /// The words as drawn (the voice's chrome case already applied).
    let words: String
    /// The widest the words may draw before they scroll.
    let maxWidth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The words' natural width in the environment's face (read, not guessed).
    @State private var wordsWidth: CGFloat?
    @State private var offset: CGFloat = 0

    var body: some View {
        let plan = WingMarqueePlan.plan(
            words: wordsWidth ?? 0, viewport: maxWidth, reduceMotion: reduceMotion)
        let viewport = max(min(wordsWidth ?? maxWidth, maxWidth), 0)
        HStack(spacing: WingMarqueePlan.gap) {
            Text(words).lineLimit(1).fixedSize()
            if plan.loops { Text(words).lineLimit(1).fixedSize() }
        }
        .lineLimit(1)
        .offset(x: plan.loops ? offset : 0)
        .frame(width: viewport, alignment: .leading)
        .clipped()
        .background(alignment: .leading) {
            Text(words)
                .lineLimit(1)
                .fixedSize()
                .hidden()
                .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width in
                    if wordsWidth != width { wordsWidth = width }
                }
        }
        // The words once, whatever the ticker draws.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(words)
        .task(id: WingMarqueePlan.LoopKey(words: words, space: Int(maxWidth.rounded()), plan: plan)) {
            await run(plan)
        }
    }

    /// The loop — only for a ticker; a still plan returns at once (no clock).
    private func run(_ plan: WingMarqueePlan) async {
        rest()
        guard case .ticker(let ticker) = plan else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(ticker.rest))
            guard !Task.isCancelled else { return }
            withAnimation(.linear(duration: ticker.duration)) { offset = -ticker.travel }
            try? await Task.sleep(for: .seconds(ticker.duration))
            guard !Task.isCancelled else { return }
            // The copy behind the words now stands where the start rested:
            // the jump back draws the same frame — the seamless wrap.
            rest()
        }
    }

    private func rest() {
        var still = Transaction()
        still.disablesAnimations = true
        withTransaction(still) { offset = 0 }
    }
}

// MARK: - The placement (the slot's layout — what the geometry pin mounts)

struct WingLabelPlacementView<Content: View>: View {
    let placement: WingLabelSpace.Placement
    let content: (_ wordsMaxWidth: CGFloat) -> Content

    init(
        placement: WingLabelSpace.Placement,
        @ViewBuilder content: @escaping (_ wordsMaxWidth: CGFloat) -> Content
    ) {
        self.placement = placement
        self.content = content
    }

    var body: some View {
        let words = WingLabelSpace.wordsMaxWidth(in: placement, washInset: VoicedButtonStyle.labelInset)
        switch placement {
        case .hidden:
            // Nothing drawn — one clear point keeps the item (and its probe)
            // in the toolbar, so a wider column brings the label back.
            Color.clear.frame(width: 1, height: 1)
        case .column(let width):
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                content(words)
            }
            .frame(width: width)
        case .loose:
            content(words)
        }
    }
}

// MARK: - The slot (the column's line, the item's edge, the placement)

struct WingToolbarSlot<Content: View>: View {
    let sidebarShown: Bool
    let content: (_ wordsMaxWidth: CGFloat) -> Content

    /// The column's remembered width — the shell's own key and default
    /// (`ShellSplit`), read here so a seam drag re-lays the label alone.
    @AppStorage(ShellSplit<EmptyView, EmptyView>.widthKey)
    private var sidebarWidth: Double = ShellSplit<EmptyView, EmptyView>.idealWidth
    /// The item's leading edge in the window, as the probe last read it.
    @State private var origin: CGFloat?

    init(
        sidebarShown: Bool,
        @ViewBuilder content: @escaping (_ wordsMaxWidth: CGFloat) -> Content
    ) {
        self.sidebarShown = sidebarShown
        self.content = content
    }

    var body: some View {
        WingLabelPlacementView(
            placement: WingLabelSpace.placement(
                sidebarShown: sidebarShown,
                columnLine: ShellSplit<EmptyView, EmptyView>.clamped(sidebarWidth),
                origin: origin),
            content: content)
        .background {
            WindowLeadingEdgeProbe { edge in
                if origin != edge { origin = edge }
            }
        }
    }
}

// MARK: - The probe (the item's leading edge, in window coordinates)

/// A zero-hit AppKit view that reports where its own leading edge sits in the
/// WINDOW — read on layout, on arriving in a window, and on the window's
/// resize and full-screen moves (the toolbar's leading items shift when the
/// traffic lights leave). Reports only a change of half a point or more.
struct WindowLeadingEdgeProbe: NSViewRepresentable {
    let onEdge: (CGFloat) -> Void

    func makeNSView(context: Context) -> ProbeView {
        let view = ProbeView()
        view.onEdge = onEdge
        return view
    }

    func updateNSView(_ nsView: ProbeView, context: Context) {
        nsView.onEdge = onEdge
        nsView.measureSoon()
    }

    final class ProbeView: NSView {
        var onEdge: ((CGFloat) -> Void)?
        private var reported: CGFloat?
        private var observers: [NSObjectProtocol] = []

        /// Never takes a click — the button above it does.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            for observer in observers { NotificationCenter.default.removeObserver(observer) }
            observers = []
            reported = nil
            guard let window else { return }
            let moves: [Notification.Name] = [
                NSWindow.didResizeNotification,
                NSWindow.didEnterFullScreenNotification,
                NSWindow.didExitFullScreenNotification,
            ]
            for name in moves {
                observers.append(NotificationCenter.default.addObserver(
                    forName: name, object: window, queue: .main
                ) { [weak self] _ in
                    MainActor.assumeIsolated { self?.measureSoon() }
                })
            }
            measureSoon()
        }

        override func layout() {
            super.layout()
            measureSoon()
        }

        /// After the current layout pass — never a state write mid-update.
        func measureSoon() {
            Task { [weak self] in self?.measure() }
        }

        private func measure() {
            guard window != nil else { return }
            let edge = convert(bounds, to: nil).minX
            if let reported, abs(reported - edge) < 0.5 { return }
            reported = edge
            onEdge?(edge)
        }
    }
}
