//
//  VoiceControls.swift
//  Variorum
//
//  Sitting 9, batch 9 (R101) — the CHROME joins the voice. The round-2
//  mockup's grammar: chrome is quiet text, never bezels — words you can
//  click, a chip for a toggled state, the muted status line at the
//  bottom. One vocabulary, token-driven, both voices; feature chrome
//  stops shipping stock Aqua control rows around voiced pages.
//

import SwiftUI

/// The voiced text-word button: the terminal canon's clickable words
/// ("expand all", "history", "seal"). No bezel; hover reveals a soft
/// wash; disabled fades. `role` picks the ink register.
struct VoicedButtonStyle: ButtonStyle {
    enum Role {
        /// Accent ink — the door you probably want.
        case primary
        /// Body ink — an ordinary action.
        case secondary
        /// Muted ink — present, not calling.
        case quiet
    }

    let tokens: VoiceTokens
    var role: Role = .secondary
    var font: Font?

    func makeBody(configuration: Configuration) -> some View {
        BodyView(configuration: configuration, tokens: tokens, role: role, font: font)
    }

    private struct BodyView: View {
        let configuration: Configuration
        let tokens: VoiceTokens
        let role: Role
        let font: Font?
        @State private var hovering = false
        @Environment(\.isEnabled) private var enabled

        var body: some View {
            configuration.label
                .font(font ?? tokens.small)
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

/// The round-2 chip ("boundaries: shown" / "wash: on") — a bordered
/// state word; click toggles where an action is wired.
struct VoicedChip: View {
    let tokens: VoiceTokens
    let text: String
    var on: Bool = false
    var action: (() -> Void)?

    var body: some View {
        Button { action?() } label: {
            Text(tokens.chromeLabel(text))
                .font(tokens.small)
                .foregroundStyle(on ? tokens.accent : tokens.muted)
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
                .overlay(
                    Capsule()
                        .stroke(on ? tokens.accent.opacity(0.55) : tokens.line, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

/// A voiced menu: a quiet clickable word with its own "▾", no bezel —
/// how a rare-but-real action set stays one click away without a row of
/// shouting buttons (the batch-9 complaint).
struct VoicedMenu<Content: View>: View {
    let tokens: VoiceTokens
    let label: String
    var role: VoicedButtonStyle.Role = .secondary
    @ViewBuilder var content: () -> Content
    @State private var hovering = false

    var body: some View {
        Menu {
            content()
        } label: {
            Text(tokens.chromeLabel(label) + " ▾")
                .font(tokens.small)
                .foregroundStyle(ink)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(hovering ? tokens.wash : Color.clear, in: RoundedRectangle(cornerRadius: 4))
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

/// The faint dot that separates status-line clusters (replaces bezel-era
/// vertical dividers in voiced chrome).
struct StatusDot: View {
    let tokens: VoiceTokens

    var body: some View {
        Text("·")
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
    }
}
