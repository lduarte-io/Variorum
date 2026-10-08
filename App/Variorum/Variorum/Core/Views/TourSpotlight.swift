//
//  TourSpotlight.swift
//  Variorum (Mac)
//
//  13s-b U2 — **THE TOUR'S RING, AND THE VOCABULARY EVERY DOOR SPEAKS IT IN**
//  (mockup v5, approved R-13s-27; the rule is `VariorumCore/Domain/Tour`).
//
//  Her ruling R-13s-12, the one this file exists to honour: *"ok definitely
//  don't dim the screen to make the take tour highlight button pop up"*. So
//  the tour never lays anything over the room. The thing a card points at
//  rings ITSELF — an accent ring with a soft glow, drawn as the door's own
//  overlay — and the room stays at full light.
//
//  Why the door draws its own ring rather than an overlay drawing it from a
//  reported frame: an overlay over the window would ring a row a scroll view
//  has clipped away (drawing over whatever sits above it), and it cannot reach
//  Write's takes panel at all (a sheet is its own window). A ring that belongs
//  to the door is clipped exactly as the door is and lives wherever the door
//  lives.
//
//  Composition (CLAUDE.md's cross-feature rule): this is SHARED vocabulary in
//  `Core/Views`, and the only thing a feature does is RENDER a modifier on its
//  own door — `.tourAnchor(.bookcaseRow(id))`. No feature holds or calls the
//  onboarding feature's model; the spotlight reaches them through the
//  environment from `RootView`, and it is nil whenever no tour runs, so every
//  anchor in the app is inert — no ring, no registration, no geometry
//  tracking — outside a tour.
//

import Observation
import SwiftUI
import VariorumCore

/// **What is lit, what is on screen, and where the card's anchor is.** One per
/// running tour (the window's); the tour's engine writes the step's ring
/// groups, the anchored doors write their own presence and — only while lit —
/// their frame.
@MainActor
@Observable
final class TourSpotlight {
    /// The step's rings as ordered candidates (`Tour.ringGroups`): each inner
    /// list lights the first of its anchors that is on screen.
    private(set) var groups: [[Tour.Anchor]] = []
    /// How many mounted doors carry each anchor right now (a row can be drawn
    /// twice — the Bookcase's starred shelf and its own — and a door leaves
    /// one at a time).
    private(set) var presence: [Tour.Anchor: Int] = [:]
    /// Where the lit anchors last were, in `.global` (the window's own space).
    private(set) var frames: [Tour.Anchor: CGRect] = [:]

    func setGroups(_ groups: [[Tour.Anchor]]) {
        guard groups != self.groups else { return }
        self.groups = groups
    }

    func arrive(_ anchor: Tour.Anchor) {
        presence[anchor, default: 0] += 1
    }

    func depart(_ anchor: Tour.Anchor) {
        guard let count = presence[anchor] else { return }
        if count <= 1 {
            presence[anchor] = nil
            frames[anchor] = nil
        } else {
            presence[anchor] = count - 1
        }
    }

    /// An anchor the overlay itself finds (Write's ⑂ badge is AppKit's):
    /// present or not, by search rather than by a door's own report.
    func setFound(_ anchor: Tour.Anchor, frame: CGRect?) {
        if let frame {
            if presence[anchor] == nil { presence[anchor] = 1 }
            if frames[anchor] != frame { frames[anchor] = frame }
        } else if presence[anchor] != nil {
            presence[anchor] = nil
            frames[anchor] = nil
        }
    }

    func report(_ frame: CGRect, for anchor: Tour.Anchor) {
        guard frames[anchor] != frame else { return }
        frames[anchor] = frame
    }

    /// The anchors ringing now: per group, its first candidate on screen.
    var lit: [Tour.Anchor] {
        groups.compactMap { group in group.first { (presence[$0] ?? 0) > 0 } }
    }

    func isLit(_ anchor: Tour.Anchor) -> Bool { lit.contains(anchor) }

    /// The anchor the card sits beside — the first group's lit one — unless
    /// it lives in Write's takes panel (a sheet: its frame is another
    /// window's), in which case the card takes its corner.
    var cardAnchor: Tour.Anchor? {
        guard let first = groups.first,
              let lit = first.first(where: { (presence[$0] ?? 0) > 0 }),
              !lit.isInPanel
        else { return nil }
        return lit
    }

    /// The card anchor's last frame (`.global`), if it reported one.
    var cardAnchorFrame: CGRect? { cardAnchor.flatMap { frames[$0] } }
}

/// **The ring's one look** (mockup v5's `.spot`: a 3 px accent ring and a
/// soft glow, never a dim). Theme tokens only.
struct TourRing: View {
    let tokens: VoiceTokens
    var cornerRadius: CGFloat = TourRing.cornerRadius
    var outset: CGFloat = TourRing.outset

    static let cornerRadius: CGFloat = 8
    static let outset: CGFloat = 3
    static let lineWidth: CGFloat = 2.5

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(tokens.accent, lineWidth: Self.lineWidth)
            .shadow(color: tokens.accent.opacity(0.45), radius: 7)
            .padding(-outset)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// The anchor a door carries. Inert unless a tour runs: no ring, no
/// registration, and no geometry tracking (the frame is read only by the
/// ring itself, which exists only while lit).
///
/// **Structure never changes with the tour** — the content is always wrapped
/// by the same modifiers, and only the overlay's CONTENT comes and goes — so
/// starting or ending a tour can never re-create a door's own state (a focused
/// field, a live editor).
private struct TourAnchorModifier: ViewModifier {
    /// nil: this door is not a tour anchor right now (a list whose FIRST row
    /// is the anchor passes nil for the rest — the modifier stays the same,
    /// so a row moving to the top never changes its structure).
    let anchor: Tour.Anchor?
    let cornerRadius: CGFloat
    let outset: CGFloat

    @Environment(TourSpotlight.self) private var spotlight: TourSpotlight?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// Which spotlight this door registered with, and as which anchor (a
    /// restarted tour is a new spotlight; the old one is gone with its
    /// window's engine).
    @State private var registered: Registration?

    private struct Registration: Equatable {
        let spotlight: ObjectIdentifier
        let anchor: Tour.Anchor
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var lit: Bool { anchor.map { spotlight?.isLit($0) ?? false } ?? false }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if lit, let spotlight, let anchor {
                        TourRing(tokens: tokens, cornerRadius: cornerRadius, outset: outset)
                            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                                frame in spotlight.report(frame, for: anchor)
                            }
                            .transition(.opacity)
                    }
                }
                // Scoped to the ring: the door's own layout never animates.
                .animation(.easeOut(duration: 0.25), value: lit)
            }
            // Above its siblings while lit, so the ring's glow is not drawn
            // under the next row.
            .zIndex(lit ? 1 : 0)
            .onAppear { register() }
            .onDisappear { unregister() }
            .onChange(of: spotlight.map(ObjectIdentifier.init)) { _, _ in
                // The tour started (or restarted) while this door was already
                // on screen — the case `onAppear` cannot see.
                unregister()
                register()
            }
            .onChange(of: anchor) { _, _ in
                // The door now names another anchor (or none).
                unregister()
                register()
            }
    }

    private func register() {
        guard let spotlight, let anchor, registered == nil else { return }
        spotlight.arrive(anchor)
        registered = Registration(spotlight: ObjectIdentifier(spotlight), anchor: anchor)
    }

    private func unregister() {
        guard let registered else { return }
        if let spotlight, ObjectIdentifier(spotlight) == registered.spotlight {
            spotlight.depart(registered.anchor)
        }
        self.registered = nil
    }
}

extension View {
    /// **This door is something the tour can point at.** Inert outside a
    /// tour. `outset` and `cornerRadius` shape the ring to the door (a row's
    /// soft corners, a word's tight ones).
    func tourAnchor(
        _ anchor: Tour.Anchor?,
        cornerRadius: CGFloat = TourRing.cornerRadius,
        outset: CGFloat = TourRing.outset
    ) -> some View {
        modifier(TourAnchorModifier(anchor: anchor, cornerRadius: cornerRadius, outset: outset))
    }
}
