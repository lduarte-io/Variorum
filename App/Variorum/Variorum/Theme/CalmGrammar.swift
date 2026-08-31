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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fontWeight(.semibold)
                .lineLimit(1)
            if let detail {
                Text(tokens.chromeLabel(detail))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
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
