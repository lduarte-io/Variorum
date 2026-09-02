//
//  CalmGrammar.swift
//  Variorum (Mac)
//
//  pre-13u Act 10 (W8-2) — **the mockup grammar as chrome vocabulary.**
//  Her ruling made `notes/plans/pre-13u-mockups/blocks-and-snippets.html`
//  the style guide ("treat them as an actual guide … the spacing felt
//  modern and satisfying … I want the whole app restyled in that modern app
//  look"), and W8-3 retired the hairline-grid / floating-pane grammar for
//  solid geometric structure. This file is that grammar, token-driven, so
//  Act 10's surfaces and 13u2's app-wide continuation restyle from ONE
//  vocabulary instead of per-view padding archaeology:
//
//    · **CalmCard** — the mockup's `.s-card`/`.c-row`: a calm bordered
//      card on the card surface, radius 10, generous padding; selection is
//      the wash + a tinted border, never a hairline row highlight.
//    · **CalmSectionHeader** — a quiet small-type header with an optional
//      one-line detail, replacing List section headers (whose fixed height
//      is exactly what clipped the tray's — item 1's traced class).
//    · **CalmButtonStyle** — the mockup's `.btn`: squarish-rounded (7),
//      bordered, generous target ("nice, generous buttons" — her amended
//      copy doctrine). Roles: ordinary · primary (accent-tinted) · danger.
//
//  It COMPOSES with VoiceControls (still the quiet-word vocabulary for
//  status lines and inline chrome); this is the card-and-control half the
//  mockups added. P-8 binds inside: every chrome text carries a lineLimit.
//

import SwiftUI

/// The mockup's calm card: content on `card`, radius 10, `line` border;
/// selected ⇒ wash + tinted border (the `.s-card.sel` grammar).
struct CalmCard<Content: View>: View {
    let tokens: VoiceTokens
    var selected = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(tokens.card),
                in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selected ? tokens.accent.opacity(0.42) : tokens.line,
                        lineWidth: 1))
    }
}

/// A quiet section header — a small faint title with an optional detail
/// line. An ordinary view in an ordinary stack: it can never be clipped by
/// a list's header-height measurement (item 1's traced class).
struct CalmSectionHeader: View {
    let tokens: VoiceTokens
    let title: String
    var detail: String?
    /// Row 89's pin seam (the `WorkbenchSeam.onFrame` pattern): the
    /// rendered detail's height — nil in the app.
    var onDetailHeight: ((CGFloat) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fontWeight(.semibold)
                .lineLimit(1)
            if let detail {
                // Row 89 (the Act 10 correction round, batch G — the
                // orchestrator's row-74 probe): the MEANING LINE is prose,
                // and it WRAPS to its full length — never `lineLimit`-
                // truncated ("…put back keeps a row; del…" at the tray's
                // default width was a sentence nobody could finish). P-8's
                // line-limit rule is for chrome LABELS; F's row 63 ("a
                // sentence's own point fell off the end") is the rule here.
                Text(tokens.chromeLabel(detail))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                        onDetailHeight?($0)
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
}

/// **Ellipsis at rest, marquee on hover** (Act 10 item 13 — her word:
/// "stereo style"). At rest an ordinary truncating one-liner; while the
/// pointer is over it, an overflowing title scrolls to its end and back so
/// the whole name can be read in place. A non-overflowing title never
/// moves. Chrome-cheap: one Text either way, animation only under the
/// pointer (P3).
struct MarqueeText: View {
    let text: String
    var font: Font
    var color: Color
    var weight: Font.Weight = .regular

    @State private var hovering = false
    @State private var phase = false
    @State private var textWidth: CGFloat = 0
    @State private var boxWidth: CGFloat = 0

    private var overflow: CGFloat { max(0, textWidth - boxWidth) }
    private var scrolling: Bool { hovering && overflow > 1 }

    var body: some View {
        Group {
            if scrolling {
                Text(text)
                    .font(font)
                    .fontWeight(weight)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(x: phase ? -overflow : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .onAppear {
                        withAnimation(
                            .linear(duration: max(0.8, Double(overflow) / 30))
                                .repeatForever(autoreverses: true)
                        ) {
                            phase = true
                        }
                    }
                    .onDisappear { phase = false }
            } else {
                Text(text)
                    .font(font)
                    .fontWeight(weight)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        // The measuring pair: the natural width (a hidden fixed-size twin)
        // against the box the title actually has.
        .background {
            Text(text)
                .font(font)
                .fontWeight(weight)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .hidden()
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                    textWidth = $0
                }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { boxWidth = $0 }
        .onHover { hovering = $0 }
    }
}

/// The mockup's `.btn`: squarish-rounded, bordered, generous.
struct CalmButtonStyle: ButtonStyle {
    enum Role {
        case ordinary
        /// The door you probably want — accent-tinted (`.btn.primary`).
        case primary
        /// A destructive act — alarm ink (`.btn.danger`).
        case danger
    }

    let tokens: VoiceTokens
    var role: Role = .ordinary
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(tokens.small)
            .fontWeight(role == .primary ? .semibold : .regular)
            .lineLimit(1)
            .foregroundStyle(ink)
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 4 : 7)
            .background(background, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(border, lineWidth: 1))
            .contentShape(RoundedRectangle(cornerRadius: 7))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }

    private var ink: Color {
        switch role {
        case .ordinary: tokens.ink
        case .primary: tokens.accent
        case .danger: tokens.alarm
        }
    }

    private var border: Color {
        switch role {
        case .ordinary: tokens.takeLine
        case .primary: tokens.accent.opacity(0.45)
        case .danger: tokens.alarm.opacity(0.3)
        }
    }

    private var background: AnyShapeStyle {
        switch role {
        case .ordinary: AnyShapeStyle(tokens.surface)
        case .primary: AnyShapeStyle(tokens.accent.opacity(0.09))
        case .danger: AnyShapeStyle(tokens.surface)
        }
    }
}
