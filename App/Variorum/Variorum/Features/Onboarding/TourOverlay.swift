//
//  TourOverlay.swift
//  Variorum
//
//  13s-b U2 — **THE TOUR'S FACES**: the coach card, the end card, and the one
//  ring the overlay draws itself (Write's ⑂ badge is AppKit's). Mockup v5,
//  frame for frame: a small card saying one idea, its count, the user's real
//  click advancing, End tour always there; NO DIM, EVER (R-13s-12 — the room
//  stays at full light, and nothing here covers anything but the card's own
//  rectangle: the overlay is transparent to every click outside the card).
//
//  It is drawn over the whole window by `RootView` while a tour runs, and its
//  body is also where the window's facts are READ (`TourFactSources`), so the
//  observation the tour needs lands on this small view and never on the
//  shell's body.
//

import AppKit
import SwiftUI
import VariorumCore

struct TourOverlay: View {
    let engine: TourEngine
    let sources: TourFactSources

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The overlay's own frame in `.global` — the space the anchors report in.
    @State private var origin: CGRect = .zero
    /// The card as measured (its first frame uses the estimate).
    @State private var cardSize = CGSize(width: TourCoachCard.width, height: 170)
    /// The probe view filling the overlay — the AppKit conversions' target.
    @State private var probe = TourWindowProbe.Handle()
    /// Write's ⑂ badge, when this step points at it — overlay-local.
    @State private var badgeFrame: CGRect?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The window's facts, read HERE (the observation lands on this view).
    private var facts: Tour.Facts {
        TourPlaces.facts(
            selection: sources.selection(), detail: sources.noteDetail(),
            caret: sources.caret(), bookNoteLive: sources.bookNoteLive(),
            note: engine.noteFacts, isStarred: sources.isStarred)
    }

    /// The ⑂ badge the current step points at, if any (by its block).
    private var badgeBlockID: String? {
        for group in engine.spotlight.groups {
            for anchor in group { if case .takeBadge(let id) = anchor { return id } }
        }
        return nil
    }

    var body: some View {
        let facts = facts
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if let badgeFrame, let id = badgeBlockID,
                   engine.spotlight.isLit(.takeBadge(id)) {
                    TourRing(tokens: tokens, cornerRadius: badgeFrame.height / 2)
                        .frame(width: badgeFrame.width, height: badgeFrame.height)
                        .offset(x: badgeFrame.minX, y: badgeFrame.minY)
                        .transition(.opacity)
                }
                card(in: proxy.size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .animation(.easeOut(duration: 0.2), value: engine.state.step)
        }
        .background {
            // The probe's arrival in the window is the tour's arrival: the
            // window's first responder is released once (the U1a walk's
            // W-U1a-1 — "yes" left the caret in the Bookcase's quick entry,
            // where the next keystroke would have minted a note).
            TourWindowProbe(handle: probe) { window in window.makeFirstResponder(nil) }
        }
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { origin = $0 }
        .onChange(of: facts, initial: true) { _, now in engine.observe(now) }
        // A3: while Write's takes panel is up at steps 5–6, the card moves
        // INTO the panel (its slot draws it above the sheet's scrim).
        .onChange(of: panelCardKey, initial: true) { _, _ in
            engine.spotlight.panelCard = cardInPanel ? AnyView(coachCard(width: nil)) : nil
        }
        .onDisappear { engine.spotlight.panelCard = nil }
        .task(id: engine.noteOfInterest) { await engine.watchNoteFacts() }
        .task(id: badgeBlockID) { await followBadge() }
        #if DEBUG
        .onAppear { TourOracle.overlay = engine }
        .onDisappear {
            if TourOracle.overlay === engine {
                TourOracle.overlay = nil
                TourOracle.cardFrame = nil
            }
        }
        #endif
    }

    @ViewBuilder
    private func card(in container: CGSize) -> some View {
        let step = engine.state.step
        let spot = placement(for: step, in: container)
        if step == .endCard {
            TourEndCard(tokens: tokens, scheme: scheme) { engine.choose($0) }
                .fixedSize(horizontal: false, vertical: true)
                .modifier(MeasuredCard(size: $cardSize))
                // Placed by layout, not by `offset`, so the card's frame (and
                // so its click area and the oracle's reading) IS where it draws.
                .padding(.leading, spot.width)
                .padding(.top, spot.height)
                .transition(.opacity)
        } else if !cardInPanel {
            coachCard(width: TourCoachCard.width)
                .modifier(MeasuredCard(size: $cardSize))
                .padding(.leading, spot.width)
                .padding(.top, spot.height)
                .id(step)
                .transition(.opacity)
        }
    }

    /// The step's coach card (nil width: the panel's own width — A3).
    @ViewBuilder
    private func coachCard(width: CGFloat?) -> some View {
        let step = engine.state.step
        if let words = TourScript.card(step, takeCount: takeCount) {
            TourCoachCard(
                tokens: tokens, scheme: scheme,
                label: TourScript.label(Tour.position(of: step)),
                card: words,
                showsNext: Tour.hasNext(step), showsEnd: Tour.hasEndTour(step),
                onNext: { engine.next() }, onEnd: { engine.endTour() },
                width: width, roadBack: roadBack)
        }
    }

    /// **A3 (the U2 UI assessment):** while Write's takes panel — a sheet,
    /// whose scrim dims the window under it — is up at steps 5–6, the card is
    /// drawn by the panel's own slot instead, above the scrim; the window's
    /// copy steps aside so there is never a card under the dim.
    private var cardInPanel: Bool {
        let step = engine.state.step
        return (step == .makeTake || step == .takeIcon)
            && engine.state.facts.caret?.panelOpen == true
    }

    /// What the panel's card depends on — the slot is refilled when it moves.
    private struct PanelCardKey: Equatable {
        let step: Tour.Step
        let inPanel: Bool
        let takeCount: Int
        let roadBack: Bool
    }

    private var panelCardKey: PanelCardKey {
        PanelCardKey(
            step: engine.state.step, inPanel: cardInPanel, takeCount: takeCount,
            roadBack: roadBack)
    }

    /// A7 (PROVISIONAL P-U2-15): the lit ring is the ROAD BACK to the step's
    /// place, not the step's own target — the card says so.
    private var roadBack: Bool {
        Tour.isRoadBack(engine.state) && !engine.spotlight.lit.isEmpty
    }

    /// Step 6 names the badge with its real count — the toured block's, read
    /// while the caret is on it (the card's own default is the ⑂2 she made).
    private var takeCount: Int {
        guard let caret = engine.state.facts.caret, caret.blockID == engine.state.tourBlockID
        else { return 2 }
        return caret.takeCount
    }

    /// Where the card goes: beside the lit anchor (in this overlay's space),
    /// else the step's corner (`Tour.place`, pinned headlessly).
    private func placement(for step: Tour.Step, in container: CGSize) -> CGSize {
        var anchor: Tour.Rect?
        if let global = engine.spotlight.cardAnchorFrame {
            let local = global.offsetBy(dx: -origin.minX, dy: -origin.minY)
            anchor = Tour.Rect(
                x: local.minX, y: local.minY, width: local.width, height: local.height)
        }
        // A2: the keep-clear regions the doors report (the sidebar, the
        // mastheads, the bottom bars), in this overlay's space.
        let avoid = engine.spotlight.keepClear.values.map { global -> Tour.Rect in
            let local = global.offsetBy(dx: -origin.minX, dy: -origin.minY)
            return Tour.Rect(
                x: local.minX, y: local.minY, width: local.width, height: local.height)
        }
        let spot = Tour.place(
            card: (Double(cardSize.width), Double(cardSize.height)), beside: anchor,
            in: (Double(container.width), Double(container.height)),
            sides: Tour.preferredSides(step), corner: Tour.fallbackCorner(step),
            avoid: avoid)
        return CGSize(width: spot.x, height: spot.y)
    }

    /// While the step points at Write's ⑂ badge, find it (read-only, by the
    /// identifier the editor's badge overlay gives it) and report it: the
    /// spotlight learns it is on screen, and this view rings it. A quarter
    /// second is plenty for a ring on a margin glyph, and the loop exists
    /// only for the one step that needs it.
    private func followBadge() async {
        guard let blockID = badgeBlockID else {
            badgeFrame = nil
            return
        }
        defer { engine.spotlight.setFound(.takeBadge(blockID), frame: nil) }
        while !Task.isCancelled {
            let local = probe.view.flatMap { TourBadgeLocator.frame(blockID: blockID, in: $0) }
            if local != badgeFrame { badgeFrame = local }
            engine.spotlight.setFound(
                .takeBadge(blockID),
                frame: local.map { $0.offsetBy(dx: origin.minX, dy: origin.minY) })
            try? await Task.sleep(for: .milliseconds(250))
        }
    }
}

/// The card's measured size (the placement's input) — and, in DEBUG, its
/// frame for the pins (`TourOracle.cardFrame`).
private struct MeasuredCard: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                TourOracle.cardFrame = $0
            }
            #endif
    }
}

// MARK: - The coach card

/// One idea: the count, a title, at most a few short sentences, and the ways
/// on — "next" where the card teaches without asking for an act, and End
/// tour always (mockup v5's `.coach`).
struct TourCoachCard: View {
    let tokens: VoiceTokens
    let scheme: ColorScheme
    let label: String?
    let card: TourScript.Card
    let showsNext: Bool
    let showsEnd: Bool
    let onNext: () -> Void
    let onEnd: () -> Void
    /// The card's width — the mockup's 300 pt over the window; nil (inside
    /// Write's takes panel, A3) takes the panel's width.
    var width: CGFloat? = TourCoachCard.width
    /// A7 (PROVISIONAL P-U2-15): the ring is a road back, not the step's own
    /// target — the card says so in one muted sentence.
    var roadBack = false

    /// The mockup's `max-width: 300px`.
    static let width: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                Text(tokens.chromeLabel(label))
                    .font(tokens.small)
                    .tracking(0.6)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .padding(.bottom, 6)
            }
            Text(tokens.chromeLabel(card.title))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
            Text(card.body)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            if roadBack {
                // A7 (PROVISIONAL P-U2-15 — new words, hers to strike): the
                // ring and the text stop contradicting when she has wandered.
                Text(TourScript.roadBack)
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
            }
            if showsNext {
                Button(tokens.chromeLabel(TourScript.next), action: onNext)
                    .buttonStyle(VoicedButtonStyle(
                        tokens: tokens, role: .primary, font: tokens.body.weight(.semibold)))
                    // A5 (the U2 UI assessment): ONE face in both rooms — the
                    // quiet accent word. The light room drew a filled pill: the
                    // window's keyboard focus landing on the card's first
                    // button once the tour releases the first responder, and
                    // the system focus effect painting it. A coach card's doors
                    // are clicked, never tabbed to.
                    .focusEffectDisabled()
                    .focusable(false)
                    .padding(.top, 10)
            }
            if showsEnd {
                Button(tokens.chromeLabel(TourScript.endTour), action: onEnd)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet, font: tokens.small))
                    .focusEffectDisabled()
                    .focusable(false)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(width: width, alignment: .leading)
        .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
        .modifier(TourCardChrome(tokens: tokens, scheme: scheme, cornerRadius: 12))
        .accessibilityElement(children: .contain)
    }
}

// MARK: - The end card (the fork — over her own note, A3)

struct TourEndCard: View {
    let tokens: VoiceTokens
    let scheme: ColorScheme
    let onChoose: (Tour.EndChoice) -> Void

    /// The mockup's `.centercard` `max-width: 450px`.
    static let width: CGFloat = 450

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(tokens.chromeLabel(TourScript.endTitle))
                .font(tokens.title)
                .foregroundStyle(tokens.ink)
                .padding(.bottom, 8)
            Text(TourScript.endBody)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            // A4 (the U2 UI assessment): muted, not tiny — the readme and ⌘J
            // line reads at the body's size in the muted ink.
            Text(TourScript.endAside)
                .font(tokens.body)
                .foregroundStyle(tokens.muted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            VStack(alignment: .leading, spacing: 9) {
                ForEach(Self.choices(tokens), id: \.key) { door in
                    choice(door)
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 26)
        .frame(width: Self.width, alignment: .leading)
        .modifier(TourCardChrome(tokens: tokens, scheme: scheme, cornerRadius: 14))
        .accessibilityElement(children: .contain)
    }

    /// **The three doors, as ONE table** — the card iterates it and the
    /// no-truncation pin measures it, so the two can never disagree about a
    /// door's words or face.
    struct Door {
        let key: String
        let choice: Tour.EndChoice
        let words: String
        let role: VoicedButtonStyle.Role
        let font: Font
    }

    static func choices(_ tokens: VoiceTokens) -> [Door] {
        [
            Door(key: "keepGoing", choice: .keepGoing, words: tokens.chromeLabel(TourScript.keepGoing),
                 role: .primary, font: tokens.body.weight(.semibold)),
            Door(key: "fieldGuide", choice: .fieldGuide,
                 words: tokens.chromeLabel(TourScript.openFieldGuide),
                 role: .secondary, font: tokens.body.weight(.medium)),
            Door(key: "done", choice: .done, words: tokens.chromeLabel(TourScript.done),
                 role: .quiet, font: tokens.body),
        ]
    }

    /// The most lines a door's words may take (her two long doors are one
    /// sentence each; three lines is the narrowest card's worst case).
    static let doorLines = 3

    private func choice(_ door: Door) -> some View {
        Button { onChoose(door.choice) } label: {
            Text(door.words)
                // **F-U2-W-1 (the U2 walk): the end card's doors WRAP, never
                // truncate.** They are sentences ("Keep going: two more
                // minutes on stars, tags, books and snippets"), and the
                // voiced word-button's one-line rule (`VoicedButtonStyle`,
                // N15) cut both long ones to an ellipsis in the Terminal
                // voice's monospace — door text never truncates. The same
                // ink, hover wash and press fade, on as many lines as the
                // sentence needs (bounded — P-8's line rule).
                .lineLimit(Self.doorLines)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    TourOracle.endDoorFrames[door.key] = $0
                }
                #endif
        }
        .buttonStyle(TourDoorStyle(tokens: tokens, role: door.role, font: door.font))
        .focusEffectDisabled()
        .focusable(false)
    }
}

/// **The cards' one chrome** — the paper, the edge, the lift. A1 (the U2 UI
/// assessment): in the DARK room the card had no visible edge (`tokens.line`
/// is a near-black hairline on near-black paper, and the light-only shadow
/// precedent drew nothing), so there the edge is the room's FAINT ink and the
/// shadow is a real one; the light room keeps the floating-chrome look that
/// already separated cleanly (`MastheadPopover`'s precedent).
struct TourCardChrome: ViewModifier {
    let tokens: VoiceTokens
    let scheme: ColorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(tokens.card, in: shape)
            .overlay(shape.stroke(scheme == .dark ? tokens.faint : tokens.line, lineWidth: 1))
            .shadow(color: .black.opacity(scheme == .dark ? 0.6 : 0.16), radius: scheme == .dark ? 24 : 18, y: 8)
            .shadow(color: .black.opacity(scheme == .dark ? 0.35 : 0.06), radius: 1.5, y: 1)
    }
}

/// **The end card's door face** — `VoicedButtonStyle`'s ink, wash and press
/// fade, WITHOUT its one-line clamp (F-U2-W-1): a door that is a sentence
/// wraps inside the card instead of losing its end to an ellipsis.
struct TourDoorStyle: ButtonStyle {
    let tokens: VoiceTokens
    var role: VoicedButtonStyle.Role = .secondary
    var font: Font?

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration, tokens: tokens, role: role, font: font)
    }

    private struct BodyView: View {
        let configuration: Configuration
        let tokens: VoiceTokens
        let role: VoicedButtonStyle.Role
        let font: Font?
        @State private var hovering = false
        @Environment(\.isEnabled) private var enabled

        var body: some View {
            configuration.label
                .font(font ?? tokens.body)
                .foregroundStyle(ink)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    hovering && enabled ? tokens.wash : Color.clear,
                    in: RoundedRectangle(cornerRadius: 4))
                .opacity(configuration.isPressed ? 0.6 : (enabled ? 1 : 0.4))
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
        }

        private var ink: Color {
            switch role {
            case .primary: tokens.accent
            case .secondary: tokens.ink
            case .quiet: tokens.muted
            }
        }
    }
}

// MARK: - AppKit: the probe and the badge

/// A transparent AppKit view filling the overlay — never a click target — so
/// an AppKit rectangle (the ⑂ badge's) converts straight into the overlay's
/// own space, whatever the window's chrome adds above it.
struct TourWindowProbe: NSViewRepresentable {
    /// A box the overlay keeps across renders, holding the live view.
    final class Handle {
        weak var view: NSView?
    }

    let handle: Handle
    /// Called ONCE, when the probe first arrives in a window.
    var onArrival: ((NSWindow) -> Void)? = nil

    final class ProbeView: NSView {
        var onArrival: ((NSWindow) -> Void)?
        private var arrived = false

        override var isFlipped: Bool { true }
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window, !arrived else { return }
            arrived = true
            onArrival?(window)
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = ProbeView()
        view.onArrival = onArrival
        handle.view = view
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        handle.view = nsView
    }
}

/// **Finds Write's ⑂ badge for a block — read-only.** The editor's badge
/// overlay (`BadgeOverlayController`) gives each badge the block's id as its
/// identifier and a `⑂N` title; both facts are pinned (`TourScriptTests`), so
/// this coupling cannot drift silently. Nothing in the editor is touched.
@MainActor
enum TourBadgeLocator {
    /// The badge's frame in `probe`'s space (nil: not on screen).
    static func frame(blockID: String, in probe: NSView) -> CGRect? {
        guard let root = probe.window?.contentView,
              let badge = find(blockID: blockID, in: root)
        else { return nil }
        // `visibleRect` is NOT bounded by the view's own bounds when no
        // ancestor clips (`clipsToBounds` is false by default on the 14+
        // SDK) — measured at the U2 stage window: it came back as the whole
        // window. Over the editor it would be the clip view's whole visible
        // page. The badge's visible part is that rect AND its own bounds.
        let visible = badge.visibleRect.intersection(badge.bounds)
        guard !visible.isEmpty else { return nil }
        return probe.convert(visible, from: badge)
    }

    static func find(blockID: String, in view: NSView) -> NSButton? {
        for sub in view.subviews {
            if let button = sub as? NSButton,
               button.identifier?.rawValue == blockID,
               button.title.hasPrefix(TourScript.takeBadgeGlyph),
               !button.isHiddenOrHasHiddenAncestor {
                return button
            }
            if let found = find(blockID: blockID, in: sub) { return found }
        }
        return nil
    }
}

#if DEBUG
/// The running tour this process last drew — the Mac pins' handle on the
/// engine a mounted shell holds in `@State` (the `BookOutlineGeometry` focus
/// door's precedent: a pin that mounts the real shell has no other road).
@MainActor
enum TourOracle {
    static weak var overlay: TourEngine?
    /// The card's last frame, `.global`.
    static var cardFrame: CGRect?
    /// The end card's doors' words, as drawn (by `TourEndCard.Door.key`).
    static var endDoorFrames: [String: CGRect] = [:]
}
#endif
