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

    /// The label's own horizontal inset inside the button (its hover wash's
    /// margin). Named so a host that lines a voiced word up with text beside
    /// it reads THIS number rather than re-typing it (VX-179 U3 — the
    /// comments panel's deleted fold).
    static let labelInset: CGFloat = 5

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
                .padding(.horizontal, VoicedButtonStyle.labelInset)
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
    /// **A label built by the caller, for a chip whose words are not all the
    /// app's** (13u3 UNIT B): `chromeLabel` LOWERCASES in the Terminal voice,
    /// which is right for the chrome vocabulary and wrong for a chip that
    /// quotes the author's own prose — a suggested title drawn
    /// `name it “garden plans…”` would not be the title she gets. A caller
    /// with prose in its label composes the `Text` itself and case-folds only
    /// its own words; `text` stays the plain-string answer for tooltips and
    /// accessibility.
    var content: Text?
    /// **How many lines this chip's label may take.** nil is the shipped
    /// behaviour — unlimited, which is what every chip in the app has always
    /// had and what several of them are measured at.
    ///
    /// 13u3 UNIT B tried to make ONE line the rule here (P-8's chrome class),
    /// because `TitleSuggestionChip` can be handed a 48-character name and a
    /// 300 pt pad to draw it in. **The book Outline's landing suite caught
    /// it**: some chip inside an expanded story wraps today, so clamping the
    /// family changed a book row's height and a landing that had settled
    /// moved 3,424 pt during its hold (`BookOutlineLandingTests.
    /// openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`, green on
    /// the pre-change tree and red with the clamp — measured both ways).
    /// A row height the book's manifest does not know about is the drift
    /// class 13u2b closed, so the clamp is OPT-IN and only the new chip takes
    /// it. The wrapping chip itself is recorded for that owner.
    var lines: Int?

    var body: some View {
        Button { action?() } label: {
            (content ?? Text(tokens.chromeLabel(text)))
                .font(tokens.small)
                .lineLimit(lines)
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
        // VX-223: the popped rows follow the control's size, so the chrome's
        // own menu pins regular — a VoicedMenu placed in a row of mini
        // controls can never pop 9-pt rows (`ChromePullDown`'s class; no
        // VoicedMenu sits in a mini row today, so this changes nothing seen).
        .controlSize(.regular)
        // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
        // states its own line policy, so its IDEAL width can never be a
        // wrapped one (the b6dae25 class's window-sizing hazard).
        // THE chrome vocabulary's own menu — so every VoicedMenu in the
        // app inherits the policy from one place.
        .lineLimit(1)
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

/// **THE CHROME PULL-DOWN** (VX-223 — the class VX-155 found on the take card;
/// the run record `notes/plans/fixes/vx-214-settings-launch-polish.md`, BATCH 3
/// RECORD): the ONE borderless pull-down in the app — a row's ⋯, a card's
/// menu, a column's ⧉ door.
///
/// A borderless SwiftUI `Menu` is an `NSPopUpButton` underneath, and its
/// popped rows draw in the pop-up's font, which follows the control's SIZE.
/// These menus live in rows of mini controls (the ↑ ↓ keys beside a ⋯), and
/// every one of them inherited `.controlSize(.mini)` — so its popped rows
/// drew at 9 pt (her report: "very small text on Read mode's three-dots
/// dropdown", Blocks, Lenses). This component PINS its own control size to
/// regular, so no host's mini or small can ever reach the rows, and carries
/// the chrome's mini metric on the LABEL's own font (VX-155's shape) — the
/// control keeps exactly the frame the mini control drew (measured: 28×11
/// with the chevron, 15×11 without, either way), so nothing around it moves.
///
/// `ChromeMenuRowSizeTests` holds the class: no borderless pull-down may be
/// spelled outside this file.
struct ChromePullDown<Label: View, Content: View>: View {
    var showsIndicator: Bool = true
    let content: () -> Content
    let label: () -> Label

    init(
        showsIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.showsIndicator = showsIndicator
        self.content = content
        self.label = label
    }

    var body: some View {
        Menu {
            content()
        } label: {
            label()
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(showsIndicator ? .automatic : .hidden)
        // THE FIX: the popped rows read at the standard menu size, whatever
        // control size the row around this menu carries.
        .controlSize(.regular)
        // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
        // states its own line policy, so its IDEAL width can never be a
        // wrapped one (the b6dae25 class's window-sizing hazard).
        .lineLimit(1)
        .fixedSize()
    }
}

extension ChromePullDown where Label == Text {
    /// A word or glyph at the chrome's mini metric — "⋯", "⧉ Make this a
    /// note".
    init(
        _ title: String, showsIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(showsIndicator: showsIndicator, content: content) {
            Text(title).font(ChromePullDownMetric.labelFont)
        }
    }
}

/// The chrome pull-down's label metric — a non-generic home so a caller
/// building its own label (the take card's glyph) states the same size.
enum ChromePullDownMetric {
    /// The chrome's mini metric, carried by a label rather than the control
    /// (VX-155): the size the mini control drew its own title at.
    static var labelFont: Font {
        Font(NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini)))
    }

    /// The borderless style's disclosure chevron, at the size it draws next
    /// to a mini label — for a menu that keeps JUST the dropdown (the take
    /// card, VX-223). The size `RestingRowControls` already paints its
    /// resting hint's chevron at.
    static var indicatorFont: Font { .system(size: 7, weight: .semibold) }
}

/// **A voiced text field** (13i-d U3 — the 13i-c orchestrator walk's polish
/// note: the Book Settings sheet's Name · Word target · Note cap were
/// system-font Aqua fields beside its voiced sections). The book Index's
/// filter field's idiom, given a label: a muted chrome word over a plain field
/// in the voice's card box with a hairline — the app's own corner, never a
/// bezel. The label is the field's accessibility title too.
struct VoicedField: View {
    let tokens: VoiceTokens
    let label: String
    @Binding var text: String
    /// A faint hint inside the empty field ("blank = none").
    var prompt: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            TextField(
                label, text: $text,
                prompt: prompt.map { Text(tokens.chromeLabel($0)).foregroundStyle(tokens.faint) })
                .labelsHidden()
                .textFieldStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
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
