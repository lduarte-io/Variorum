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
        } else if let words = TourScript.card(step, takeCount: takeCount) {
            TourCoachCard(
                tokens: tokens, scheme: scheme,
                label: TourScript.label(Tour.position(of: step)),
                card: words,
                showsNext: Tour.hasNext(step), showsEnd: Tour.hasEndTour(step),
                onNext: { engine.next() }, onEnd: { engine.endTour() })
                .modifier(MeasuredCard(size: $cardSize))
                .padding(.leading, spot.width)
                .padding(.top, spot.height)
                .id(step)
                .transition(.opacity)
        }
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
        let spot = Tour.place(
            card: (Double(cardSize.width), Double(cardSize.height)), beside: anchor,
            in: (Double(container.width), Double(container.height)),
            sides: Tour.preferredSides(step), corner: Tour.fallbackCorner(step))
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
            if showsNext {
                Button(tokens.chromeLabel(TourScript.next), action: onNext)
                    .buttonStyle(VoicedButtonStyle(
                        tokens: tokens, role: .primary, font: tokens.body.weight(.semibold)))
                    .padding(.top, 10)
            }
            if showsEnd {
                Button(tokens.chromeLabel(TourScript.endTour), action: onEnd)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet, font: tokens.small))
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(width: Self.width, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(tokens.line, lineWidth: 1))
        // The app's floating-chrome shadow (light only — the fully black
        // room, R51, carries none; `MastheadPopover`'s precedent).
        .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.16), radius: 18, y: 8)
        .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.06), radius: 1.5, y: 1)
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
            Text(TourScript.endAside)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            VStack(alignment: .leading, spacing: 9) {
                choice(TourScript.keepGoing, .keepGoing, role: .primary,
                       font: tokens.body.weight(.semibold))
                choice(TourScript.openFieldGuide, .fieldGuide, role: .secondary,
                       font: tokens.body.weight(.medium))
                choice(TourScript.done, .done, role: .quiet, font: tokens.body)
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 26)
        .frame(width: Self.width, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.18), radius: 24, y: 10)
        .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.06), radius: 1.5, y: 1)
        .accessibilityElement(children: .contain)
    }

    private func choice(
        _ words: String, _ choice: Tour.EndChoice, role: VoicedButtonStyle.Role, font: Font
    ) -> some View {
        Button(tokens.chromeLabel(words)) { onChoose(choice) }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: role, font: font))
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
}
#endif
