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
                // The chrome class rule (N15 / the wedged-window lesson):
                // a voiced button label is one line, always — under
                // compression it truncates, never wraps mid-word
                // ("com mit ⌘S").
                .lineLimit(1)
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

extension View {
    /// `.help` only when there is something to say — an EMPTY help string is
    /// a placeholder standing in for "no tooltip", and a `cond ? "" : "…"`
    /// in a body is a string-as-rule (the 18h ladder's R1-12; review focus
    /// F-0's own line). Pass nil or "" and the modifier is not applied.
    @ViewBuilder func help(ifPresent text: String?) -> some View {
        if let text, !text.isEmpty { self.help(text) } else { self }
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

/// A board-chrome NOTICE: status lines, seal notes, footer rules — any
/// wrapping text in NON-SCROLLING window chrome. The line limit beside
/// `fixedSize` is LOAD-BEARING: an unlimited fixedSize text here measures
/// one character per line under the window's near-zero-width minimum-size
/// probe, and its full height becomes the WINDOW's minimum (the
/// wedged-window root cause, b6dae25 — it recurred on the Lenses tab,
/// batch 12, through the boards' unlimited status texts). Pinned by
/// `ChromeMinHeightTests`.
struct ChromeNotice: View {
    let tokens: VoiceTokens
    let text: String
    var ink: Color?
    var lines: Int = 4

    var body: some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(ink ?? tokens.muted)
            .lineLimit(lines)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }
}

// MARK: - The two signal voices (the post-13l polish round, rows 29 and 31)

/// **A refusal, in the voice's own alarm** (ledger row 29 — her mid-round
/// ruling: *"Add it this round"*).
///
/// Why a MODIFIER and not "pass `tokens.alarm` at every site": the ~30 error
/// slots this replaces are scattered through nested private view structs, many
/// of which hold no tokens at all and painted `.foregroundStyle(.red)` for
/// exactly that reason — the literal was the path of least resistance, and a
/// sweep that made each of them acquire a `ThemeStore` would be thirty chances
/// to acquire it differently. This resolves the voice itself, at the one place
/// the app already resolves it, so `.foregroundStyle(.red)` → `.alarmVoice()`
/// is a one-token edit anywhere and cannot drift.
///
/// **Not for the fallback CANARY banners.** `EditorView` / `ReadPostView` /
/// `PaneSurface` paint white-on-red blocks when TextKit 2 silently downgrades
/// (TEXTKIT2 §4's third defensive practice). That is a build-integrity alarm
/// aimed at a developer, deliberately the loudest thing the app can draw, and
/// quieting it into the voice would be softening a signal whose whole job is
/// to be impossible to miss. They keep their literal red, on purpose.
struct AlarmVoice: ViewModifier {
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(
            (themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)).alarm)
    }
}

/// **A settled state, in the voice's quiet positive** (ledger row 31 — her
/// words: *"a gentle green on fully synced might look nice"*). Same resolution
/// road as `AlarmVoice`, same reason.
struct PositiveVoice: ViewModifier {
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(
            (themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)).positive)
    }
}

extension View {
    /// Paint this as a refusal — the voice's error/danger slot.
    func alarmVoice() -> some View { modifier(AlarmVoice()) }
    /// Paint this as a settled state — the voice's quiet positive slot.
    func positiveVoice() -> some View { modifier(PositiveVoice()) }
}
