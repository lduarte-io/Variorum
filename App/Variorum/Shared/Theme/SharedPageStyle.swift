//
//  SharedPageStyle.swift
//  Variorum (shared: Mac + Mobile)
//
//  Mobile parity round, Stage D batch D1 — the ONE styling seam for the
//  shared account/encryption/tier pages (AccountView · EncryptionView — gone
//  with today's road at VX-329 U1 · SyncStatusRow · HostedSyncSection). Her instruction (the stage table's
//  D row): "they work, I just think they're a bit ugly right now and
//  don't follow UI principles" — the pages restyle AS THE PHONE RENDERS
//  THEM, through this seam, never a fork.
//
//  THE ONE-SEAM LAW, made structural:
//  · The style rides an OPTIONAL environment value. On macOS the accessor
//    is compiled to ALWAYS-NIL (the getter returns nil, the setter is
//    inert) — the Mac cannot be handed a style even deliberately, so
//    every helper below renders its nil arm there: the EXACT pre-D1
//    construction. Pinned by `SharedPageStyleTests` (Mac) and
//    `MobileSharedPageStyleTests` (phone).
//  · Every helper documents its nil arm; a nil arm is either `self`
//    (sites that carried no modifier) or byte-for-byte the modifiers the
//    call site carried before D1. The Mac's rendering is unchanged BY
//    CONSTRUCTION, not by review luck.
//  · The injection site is the mobile Settings sheet
//    (`MobileSettingsView`), around `SyncStatusRow` — the Account sheet
//    presents from inside the row, so the whole sheet chain inherits the
//    style through the environment (the SnapshotPrivacy precedent:
//    environment reaches presented sheets).
//
//  The styled arms speak the LK canon: the live voice's tokens (fonts,
//  ink, room/card/line), the phone sheet grammar (the Book Details /
//  Settings precedent — chrome voice-cased through `chromeLabel`, plain
//  accent doors, hairline-stroked cards), and the calm default. RULED
//  COPY is never re-cased: the 14b CF sentences, warnings, and refusals
//  render as written — only CHROME (tab words, door words, headings)
//  routes through the voice case, the P26/P43 one-register rule.
//

import SwiftUI

/// The shared pages' phone look: the live voice's tokens plus the small
/// grammar the pages share. Injected by the mobile Settings sheet; never
/// constructed on the Mac (the environment accessor below refuses it).
struct SharedPageStyle {
    var tokens: VoiceTokens

    /// Chrome voice-casing (terminal lowercases, study keeps case) —
    /// door words, tab words, headings. Ruled prose NEVER routes here.
    func chrome(_ text: String) -> String {
        tokens.chromeLabel(text)
    }
}

private struct SharedPageStyleKey: EnvironmentKey {
    static let defaultValue: SharedPageStyle? = nil
}

extension EnvironmentValues {
    /// iOS: nil until the mobile Settings sheet injects the live voice's
    /// style. macOS: ALWAYS nil by construction — the getter is compiled
    /// to `nil` and the setter is inert, so no Mac code path can ever
    /// carry a style to these views. This is the one-seam law's proof at
    /// the type level (pinned on both platforms).
    #if os(iOS)
    var sharedPageStyle: SharedPageStyle? {
        get { self[SharedPageStyleKey.self] }
        set { self[SharedPageStyleKey.self] = newValue }
    }
    #else
    var sharedPageStyle: SharedPageStyle? {
        get { nil }
        set { _ = newValue }
    }
    #endif
}

// MARK: - Text helpers (each nil arm is the exact pre-D1 construction)

extension View {
    /// Body prose. nil ⇒ `self` (sites that carried no modifiers).
    @ViewBuilder
    func pageProse(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.body).foregroundStyle(style.tokens.ink)
        } else {
            self
        }
    }

    /// Secondary body prose. nil ⇒ exactly `.foregroundStyle(.secondary)`.
    @ViewBuilder
    func pageSecondary(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.body).foregroundStyle(style.tokens.muted)
        } else {
            self.foregroundStyle(.secondary)
        }
    }

    /// Body-size warning. nil ⇒ exactly `.foregroundStyle(.orange)`.
    /// (Warning/error COLORS stay the system semantic ones in both arms —
    /// the LK canon has no warning token, and honesty outranks palette.)
    @ViewBuilder
    func pageWarning(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.body).foregroundStyle(Color.orange)
        } else {
            self.foregroundStyle(.orange)
        }
    }

    /// Caption. nil ⇒ exactly `.font(.caption).foregroundStyle(.secondary)`.
    @ViewBuilder
    func pageCaption(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.small).foregroundStyle(style.tokens.muted)
        } else {
            self.font(.caption).foregroundStyle(.secondary)
        }
    }

    /// Warning caption. nil ⇒ exactly `.font(.caption).foregroundStyle(.orange)`.
    @ViewBuilder
    func pageCaptionWarning(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.small).foregroundStyle(Color.orange)
        } else {
            self.font(.caption).foregroundStyle(.orange)
        }
    }

    /// Error caption. nil ⇒ exactly `.font(.caption).foregroundStyle(.red)`.
    @ViewBuilder
    func pageCaptionError(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.small).foregroundStyle(style.tokens.alarm)
        } else {
            self.font(.caption).foregroundStyle(.red)
        }
    }

    /// A caption that must read at full strength (the two understanding
    /// checkboxes' sentences). nil ⇒ exactly `.font(.caption)` (primary).
    @ViewBuilder
    func pageCaptionProminent(_ style: SharedPageStyle?) -> some View {
        if let style {
            self.font(style.tokens.small).foregroundStyle(style.tokens.ink)
        } else {
            self.font(.caption)
        }
    }

    /// Field chrome. nil ⇒ `self` (the Mac's default bordered field).
    /// Styled: a visible field — bare iOS text fields carry NO affordance
    /// at all (this pass's headline UI-principle fix), so the voice's
    /// card + hairline draw one.
    @ViewBuilder
    func pageFieldChrome(_ style: SharedPageStyle?) -> some View {
        if let style {
            self
                .font(style.tokens.body)
                .foregroundStyle(style.tokens.ink)
                .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(style.tokens.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style.tokens.line, lineWidth: 1)))
        } else {
            self
        }
    }

    /// The 12-words display's card (the ceremony's one focal object).
    /// nil ⇒ `self`. The `privacySensitive` mark stays on the Text
    /// itself — this wraps OUTSIDE it and never touches the marking.
    @ViewBuilder
    func pagePhraseCard(_ style: SharedPageStyle?) -> some View {
        if let style {
            self
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(style.tokens.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style.tokens.line, lineWidth: 1)))
        } else {
            self
        }
    }
}

// MARK: - PageHeading (section/step headings — chrome)

/// A heading. nil ⇒ exactly `Text(title).fontWeight(.semibold)` (the
/// pre-D1 line); styled ⇒ the voice's heading, voice-cased (headings are
/// chrome — the Book Details header precedent). Ruled PROSE never
/// routes through here.
struct PageHeading: View {
    let title: String
    let style: SharedPageStyle?

    init(_ title: String, style: SharedPageStyle?) {
        self.title = title
        self.style = style
    }

    var body: some View {
        if let style {
            Text(style.chrome(title))
                .font(style.tokens.heading)
                .foregroundStyle(style.tokens.ink)
                .accessibilityLabel(title)
        } else {
            Text(title).fontWeight(.semibold)
        }
    }
}

// MARK: - PageDivider

/// nil ⇒ exactly `Divider()`; styled ⇒ the voice hairline with a little
/// air (the Settings sheet's divider grammar).
struct PageDivider: View {
    let style: SharedPageStyle?

    init(_ style: SharedPageStyle?) {
        self.style = style
    }

    var body: some View {
        if let style {
            Divider()
                .overlay(style.tokens.line)
                .padding(.vertical, 4)
        } else {
            Divider()
        }
    }
}

// MARK: - PageDoor (buttons)

/// A door. Each form's nil arm is byte-for-byte the construction the
/// call site carried before D1:
///  · .act          ⇒ `Button(title, action:)` (the platform default)
///  · .borderless   ⇒ + `.buttonStyle(.borderless)`
///  · .bordered     ⇒ + `.buttonStyle(.bordered)`
///  · .destructive  ⇒ `Button(title, role: .destructive, action:)`
/// Styled arms speak the phone grammar: voice-cased labels, accent ink,
/// the Today-button card for primary acts, a visible hairline border for
/// the CF-3 reveal class (which must LOOK like a button — held), plain
/// accent for inline doors, red for destructive. Accessibility labels
/// stay the PLAIN words (the A3 rule: VoiceOver reads words, never a
/// register).
struct PageDoor: View {
    enum Form {
        case act, borderless, bordered, destructive
        /// An inline row door ("Sign out" beside its line). nil arm: the
        /// plain default `Button(title, action:)` EXACTLY (these sites
        /// carried no buttonStyle); styled arm: the borderless look —
        /// a boxed act would overweight an inline row.
        case inlineAct
    }

    let title: String
    let form: Form
    let style: SharedPageStyle?
    let action: () -> Void

    init(
        _ title: String, form: Form = .act, style: SharedPageStyle?,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.form = form
        self.style = style
        self.action = action
    }

    var body: some View {
        if let style {
            Button(role: form == .destructive ? .destructive : nil, action: action) {
                Text(style.chrome(title))
            }
            .buttonStyle(PageDoorButtonStyle(tokens: style.tokens, form: form))
            .accessibilityLabel(title)
        } else {
            switch form {
            case .act, .inlineAct:
                Button(title, action: action)
            case .borderless:
                Button(title, action: action)
                    .buttonStyle(.borderless)
            case .bordered:
                Button(title, action: action)
                    .buttonStyle(.bordered)
            case .destructive:
                Button(title, role: .destructive, action: action)
            }
        }
    }
}

private struct PageDoorButtonStyle: ButtonStyle {
    let tokens: VoiceTokens
    let form: PageDoor.Form

    func makeBody(configuration: Configuration) -> some View {
        PageDoorLabel(tokens: tokens, form: form, configuration: configuration)
    }
}

/// The style's body lives in a View so `isEnabled` is a live environment
/// read (disabled doors dim — `.plain`-class styles do not dim on their
/// own).
private struct PageDoorLabel: View {
    let tokens: VoiceTokens
    let form: PageDoor.Form
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        styled
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.55 : 1) : 0.35)
    }

    @ViewBuilder
    private var styled: some View {
        switch form {
        case .act, .destructive:
            configuration.label
                .font(tokens.body)
                .foregroundStyle(form == .destructive ? Color.red : tokens.accent)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 9)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tokens.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tokens.line, lineWidth: 1)))
        case .bordered:
            configuration.label
                .font(tokens.body)
                .foregroundStyle(tokens.accent)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tokens.line, lineWidth: 1))
        case .borderless, .inlineAct:
            configuration.label
                .font(tokens.body)
                .foregroundStyle(tokens.accent)
                .padding(.vertical, 6)
        }
    }
}
