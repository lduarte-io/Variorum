//
//  WordsBandCard.swift
//  Variorum
//
//  VX-307 U2b — THE TWELVE WORDS, HER WAY, the Mac's faces (VX-412; `notes/CastleRules.md` rules 2, 3, 6 and 7 as
//  amended; her words in `notes/plans/vx-307-castle-crossings.md` §3a; her drawing
//  `notes/plans/vx-307/her-cards-area-2026-10-18.png`). The brains are `Shared/Protection/WordsBand.swift`'s.
//
//    - `WordsBandCard` — THE CARD ABOVE THE QUICK ENTRY: between the shelf listing and the quick-entry line, the main
//      column's full width (her drawing). Never a popup, never the lobby — the first open stays calm (nothing stands
//      between launch and the Bookcase). Its words row: rule 2's sentence (hers) as the door, *Later*, and the ✕ (whose
//      toast says where to find the words in Settings). Rule 3's reminder rides the same card — its line and doors
//      (the one home for both asks; the bottom bar no longer carries it).
//    - `WordsLookPanel` — the LOOK, wherever it is composed (the card, the tour's last card, Settings ▸ Protection):
//      the passphrase asked only where one exists; the twelve words numbered in two columns, never selectable,
//      privacy-sensitive; *Copy* through the one clipboard rule (VX-448: concealed, cleared at lock and quit — the host's `copyWords`);
//      "write these down now"; *I've written them down* → her warning, *Go back* · *Close*. No Return shortcut puts the
//      words away (a stray Return must never).
//    - `TourPassphraseAsk` · `TourWordsAsk` — the tour's two closing asks (rule 3: the passphrase, then the words), each
//      the face of a closing card of its own since VX-735 (they stood side by side on the end card before).
//    - `WordsLookSection` — Settings ▸ Protection's door (the ✕'s toast names it; rule 7's "new-words door").
//  All of it over the road's models (VX-329 U1: in every build — today's road, which rendered none of it, is gone).
//

import SwiftUI
import VariorumCore

// MARK: - The card above the quick entry

struct WordsBandCard: View {
    let standing: RoadStandingModel
    @Bindable var band: WordsBandModel
    /// The status seam's always-shown direction (the ✕'s toast: where the words live in Settings).
    let direct: (String) -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// The reminder's set-passphrase sheet (this card holds its own — the Protection pane holds another).
    @State private var sheet: SetPassphraseModel?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var wordsRow: Bool { band.offersWords || band.look.phase != .closed }

    var body: some View {
        if band.visible {
            VStack(alignment: .leading, spacing: 10) {
                if wordsRow { wordsPart }
                if wordsRow, band.showsReminder {
                    Divider().overlay(tokens.line)
                }
                if let showing = band.reminder.showing { reminderPart(showing) }
                // VX-529 unit 3 — VX-538: the E6 row (her R-529-6), the band's third ask in the same one home.
                if band.showsAccountPassphrase, let row = band.accountPassphrase {
                    if wordsRow || band.showsReminder { Divider().overlay(tokens.line) }
                    AccountPassphraseRow(row: row, tokens: tokens)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            // The board's own gutter (the shelf listing's), so the card spans the main column under the books.
            .padding(.horizontal, 28)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .sheet(item: $sheet) { sheet in
                SetPassphraseSheet(model: sheet)
            }
        }
    }

    // MARK: The words row (rule 2)

    @ViewBuilder
    private var wordsPart: some View {
        if band.look.phase == .closed {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "key")
                    .foregroundStyle(tokens.muted)
                // Her "click here": the whole sentence is the door.
                Button {
                    Task { await band.look.open() }
                } label: {
                    Text(ProtectionWords.wordsCardLine)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer(minLength: 8)
                Button(ProtectionWords.wordsCardLater) { band.later() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                Button {
                    if let toast = band.dismiss() { direct(toast) }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(tokens.muted)
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(ProtectionWords.wordsCardDismiss)
                .accessibilityLabel(ProtectionWords.wordsCardDismiss)
            }
            if let message = band.look.message {
                Text(message)
                    .font(tokens.small)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            WordsLookPanel(look: band.look, tokens: tokens)
        }
    }

    // MARK: Rule 3's reminder (folded in — the one home for both asks)

    private func reminderPart(_ showing: PassphraseReminderRules.Showing) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "lock")
                .foregroundStyle(tokens.muted)
            Text(ProtectionWords.reminderLine)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button(ProtectionWords.reminderSetDoor) {
                sheet = standing.makeSetPassphraseSheet { sheet = nil }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            Button(ProtectionWords.reminderNotNow) {
                Task { await band.reminder.notNow() }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens))
            if showing.offersDontShowAgain {
                Button(ProtectionWords.reminderDontShowAgain) {
                    Task { await band.reminder.dontShowAgain() }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
            }
        }
    }
}

// MARK: - VX-529 unit 3 — VX-538: the E6 row (her R-529-6 — the why and the road, recurring until it's done)

/// The band card's E6 row: the why and the road, the forgot-road, the account's passphrase typed right here (its one
/// door lands it as the library's own lock — the E6 heal), *Later* and the ✕. The brain is `AccountPassphraseCardModel`
/// (`Shared/Protection/WordsBand.swift`); the row goes when the STATE no longer reads E6.
struct AccountPassphraseRow: View {
    @Bindable var row: AccountPassphraseCardModel
    let tokens: VoiceTokens

    @State private var passphrase = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "lock")
                    .foregroundStyle(tokens.muted)
                VStack(alignment: .leading, spacing: 4) {
                    Text(ProtectionWords.accountPassphraseCardLine)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(ProtectionWords.accountPassphraseCardForgot)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Button(ProtectionWords.wordsCardLater) { row.later() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                    .disabled(row.busy)
                Button {
                    row.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(tokens.muted)
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(row.busy)
                .help(ProtectionWords.wordsCardDismiss)
                .accessibilityLabel(ProtectionWords.wordsCardDismiss)
            }
            HStack(spacing: 10) {
                PeekableSecretField(label: ProtectionWords.joinPassphraseField, text: $passphrase, onSubmit: submit)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                Button(ProtectionWords.accountPassphraseCardDoor) { submit() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .disabled(passphrase.isEmpty || row.busy)
                if row.busy { TravellingDotsIndicator(ink: tokens.muted) }
            }
            .padding(.leading, 26)
            if let message = row.message {
                Text(message)
                    .font(tokens.small)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 26)
            }
        }
    }

    private func submit() {
        let typed = passphrase
        guard !typed.isEmpty, !row.busy else { return }
        Task {
            await row.submit(passphrase: typed)
            if row.message == nil { passphrase = "" }
        }
    }
}

// MARK: - The look

struct WordsLookPanel: View {
    @Bindable var look: WordsLookModel
    let tokens: VoiceTokens
    /// **VX-735 — the narrow card's layout**: the tour's words card is a centred card, not the main column's width, so
    /// its shown words lay out top to bottom — the grid, then Copy with its clipboard caveat at the card's FULL width
    /// under it (never a squished side column), then the warning on its own line and its doors on theirs, whole. The
    /// band card and Settings keep the one-row layout (false).
    var stacked = false

    @State private var passphrase = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch look.phase {
            case .closed:
                EmptyView()
            case .asking:
                asking
            case .minting:
                HStack(spacing: 10) {
                    TravellingDotsIndicator(ink: tokens.muted)
                    Text(ProtectionWords.wordsLookMinting)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            case .shown, .warning:
                shown
            }
            if let message = look.message, look.phase != .closed {
                Text(message)
                    .font(tokens.small)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Rule 6: new words ask the passphrase where one exists. VX-308 U3 (F-U2-3): a synced library's look says, before
    /// anything is minted, that new words replace the account's words everywhere — her *Show my twelve words* is the yes.
    @ViewBuilder
    private var asking: some View {
        if stacked { askingStacked } else { askingInARow }
    }

    /// **VX-736 F-W3 (the walk's W3, adjudicated):** the narrow card's ask, top to bottom like its shown words — the field
    /// on its own row at the card's width, then Cancel · Show my twelve words, whole (the one-row ask cut the primary door
    /// to "Show my twelve w…" at the closing card's measure). The same lines and doors.
    private var askingStacked: some View {
        VStack(alignment: .leading, spacing: 8) {
            if look.saysAccountWords {
                Text(ProtectionWords.wordsLookReplacesAccountWords)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(ProtectionWords.wordsLookAsk)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            PeekableSecretField(label: ProtectionWords.wordsLookPassphraseField, text: $passphrase, onSubmit: submit)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
            HStack(spacing: 10) {
                Spacer(minLength: 0)
                Button {
                    passphrase = ""
                    look.cancel()
                } label: {
                    Text(ProtectionWords.wordsLookCancel).modifier(TourClosingDoorProbe(key: "cancel"))
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .fixedSize()
                Button { submit() } label: {
                    Text(ProtectionWords.wordsLookShow).modifier(TourClosingDoorProbe(key: "show"))
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .fixedSize()
                .disabled(passphrase.isEmpty)
            }
        }
    }

    /// The band card's and Settings' ask: the field and its two doors on one row.
    private var askingInARow: some View {
        VStack(alignment: .leading, spacing: 8) {
            if look.saysAccountWords {
                Text(ProtectionWords.wordsLookReplacesAccountWords)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(ProtectionWords.wordsLookAsk)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                PeekableSecretField(label: ProtectionWords.wordsLookPassphraseField, text: $passphrase, onSubmit: submit)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                Button {
                    passphrase = ""
                    look.cancel()
                } label: {
                    Text(ProtectionWords.wordsLookCancel).modifier(TourClosingDoorProbe(key: "cancel"))
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                Button { submit() } label: {
                    Text(ProtectionWords.wordsLookShow).modifier(TourClosingDoorProbe(key: "show"))
                }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .disabled(passphrase.isEmpty)
            }
        }
    }

    /// The words, once: "write these down now", the two columns, Copy, and the close behind her warning.
    @ViewBuilder
    private var shown: some View {
        if stacked { shownStacked } else { shownInARow }
    }

    /// VX-735: the narrow card's words — the same lines and doors, top to bottom.
    private var shownStacked: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ProtectionWords.wordsLookLead)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            if look.saysRuleSix {
                Text(ProtectionWords.wordsLookRuleSix)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            words
            Button(ProtectionWords.wordsLookCopy) { look.copy() }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .fixedSize()
            if look.copied {
                // The clipboard's caveat, under the grid at the card's whole width.
                Text(ProtectionWords.wordsLookCopied)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    #if DEBUG
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                        TourClosingOracle.copiedCaveatFrame = $0
                    }
                    #endif
            }
            // No Return shortcut on purpose: a stray Return must never put the once-shown words away.
            if look.phase == .warning {
                Text(ProtectionWords.wordsLookWarning)
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    Spacer(minLength: 0)
                    Button(ProtectionWords.wordsLookGoBack) { look.goBack() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens))
                        .fixedSize()
                    Button(ProtectionWords.wordsLookClose) { look.close() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                        .fixedSize()
                }
            } else {
                HStack(spacing: 10) {
                    Spacer(minLength: 0)
                    Button(ProtectionWords.wordsLookWrittenDown) { look.writtenDown() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                        .fixedSize()
                }
            }
        }
        #if DEBUG
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            TourClosingOracle.stackedLookFrame = $0
        }
        #endif
    }

    /// The band card's and Settings' row: Copy, its caption and the close's doors on one line.
    private var shownInARow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ProtectionWords.wordsLookLead)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            if look.saysRuleSix {
                Text(ProtectionWords.wordsLookRuleSix)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            words
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Button(ProtectionWords.wordsLookCopy) { look.copy() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                if look.copied {
                    Text(ProtectionWords.wordsLookCopied)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                Spacer(minLength: 8)
                // No Return shortcut on purpose: a stray Return must never put the once-shown words away.
                if look.phase == .warning {
                    Text(ProtectionWords.wordsLookWarning)
                        .font(tokens.small.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                    Button(ProtectionWords.wordsLookGoBack) { look.goBack() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens))
                    Button(ProtectionWords.wordsLookClose) { look.close() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                } else {
                    Button(ProtectionWords.wordsLookWrittenDown) { look.writtenDown() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                }
            }
        }
    }

    /// The twelve words, numbered, in two columns — never selectable (the Copy door is the one road), privacy-sensitive.
    private var words: some View {
        HStack(alignment: .top, spacing: 36) {
            ForEach(Array(look.columns.enumerated()), id: \.offset) { _, column in
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(column, id: \.number) { entry in
                        HStack(spacing: 8) {
                            Text("\(entry.number)")
                                .font(tokens.mono)
                                .foregroundStyle(tokens.faint)
                                .frame(minWidth: 20, alignment: .trailing)
                            Text(entry.word)
                                .font(tokens.mono)
                                .foregroundStyle(tokens.ink)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .textSelection(.disabled)
        .privacySensitive()
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(tokens.room.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }

    private func submit() {
        let typed = passphrase
        guard !typed.isEmpty else { return }
        Task {
            await look.submit(passphrase: typed)
            if look.phase != .asking { passphrase = "" }
        }
    }
}

// MARK: - The tour's closing asks (rule 3: the passphrase, then the words — VX-735: a card each)

/// **The passphrase card's face** (rule 3's ask; the end card's passphrase half, moved whole by VX-735): the explainer
/// sentence, the Passphrase/Again fields with the quiet hint, and Set passphrase. Once set here the card moves on (the
/// tour's facts read the library's ask as answered) and the passphrase is handed to the words card's look, so she is
/// never asked it twice.
struct TourPassphraseAsk: View {
    @Bindable var model: TourEndLibraryModel
    let tokens: VoiceTokens

    @State private var passphrase = ""
    @State private var again = ""

    var body: some View {
        if let ask = model.passphrase {
            if model.passphraseSet {
                Text(ProtectionWords.tourEndPassphraseSet)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ProtectionWords.setPassphraseLead)
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    PeekableSecretField(label: ProtectionWords.setPassphraseField, text: $passphrase)
                        .textFieldStyle(.roundedBorder)
                    // VX-309 U2 — VX-211: the quiet line, in the card's own voice.
                    if let hint = NewPassphraseRule.hint(passphrase) {
                        Text(hint)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    PeekableSecretField(label: ProtectionWords.setPassphraseAgain, text: $again, onSubmit: submit)
                        .textFieldStyle(.roundedBorder)
                    HStack(spacing: 10) {
                        if let refusal = ask.refusal {
                            Text(refusal)
                                .font(tokens.small)
                                .alarmVoice()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        if ask.busy { TravellingDotsIndicator(ink: tokens.muted) }
                        Button(ProtectionWords.setPassphraseButton) { submit() }
                            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                            .fixedSize()
                            .disabled(!ask.canSubmit(passphrase: passphrase, again: again))
                    }
                }
            }
        }
    }

    private func submit() {
        guard let ask = model.passphrase else { return }
        let typed = passphrase
        let twice = again
        Task {
            await ask.submit(passphrase: typed, again: twice)
            if model.passphraseSet {
                passphrase = ""
                again = ""
            }
        }
    }
}

/// **The words card's face** (rule 2's look; the end card's words half, moved whole by VX-735): rule 2's sentence as
/// the door, then the look — asked where a passphrase exists (never when one was just set on the card before), the
/// words once with Copy, her warning before the close — laid out for the narrow card (`WordsLookPanel(stacked:)`).
struct TourWordsAsk: View {
    @Bindable var model: TourEndLibraryModel
    let tokens: VoiceTokens

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if model.look.phase == .closed {
                Button {
                    Task { await model.showWords() }
                } label: {
                    Text(ProtectionWords.wordsCardLine)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if let message = model.look.message {
                    Text(message)
                        .font(tokens.small)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                WordsLookPanel(look: model.look, tokens: tokens, stacked: true)
            }
        }
    }
}

#if DEBUG
/// The closing cards' frames for the pins (`TourClosingCardTests` — the geometry oracle of the layout row: the caveat
/// at the card's full width, the doors whole).
@MainActor
enum TourClosingOracle {
    static var copiedCaveatFrame: CGRect?
    static var stackedLookFrame: CGRect?
    /// The look's ASK doors' drawn words (by key: "cancel", "show") — F-W3's pin reads them against the words' own width.
    static var askDoorFrames: [String: CGRect] = [:]
}
#endif

/// Records a door's drawn words for the pins (DEBUG only; nothing in a release build).
struct TourClosingDoorProbe: ViewModifier {
    let key: String

    func body(content: Content) -> some View {
        content
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                TourClosingOracle.askDoorFrames[key] = $0
            }
            #endif
    }
}

// MARK: - Settings ▸ Protection (the door the ✕'s toast names)

struct WordsLookSection: View {
    let standing: RoadStandingModel
    /// VX-308 U3 (R-U3-5): this door IS the key doors' New Words — its face read from `assess` over the pane's one read
    /// (its refusal said in its place — a follow owed, the vault out of reach, another account); nil: the door as U2b
    /// built it (no read yet, or a test's hand-made faces).
    var keyDoors: RoadKeyDoorsModel? = nil

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var look: WordsLookModel?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        Section(ProtectionWords.wordsSectionTitle) {
            Text(ProtectionWords.wordsSectionLine)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let look, look.phase != .closed {
                WordsLookPanel(look: look, tokens: tokens)
            } else if case .refused(let sentence)? = keyDoors?.faces?.newWords {
                Text(sentence)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if keyDoors?.faces?.newWords != .hidden {
                HStack {
                    Button(ProtectionWords.wordsSectionDoor) {
                        // A fresh look per press (it reads, at its making, whether words were recorded before).
                        let fresh = standing.makeWordsLook()
                        look = fresh
                        Task { await fresh.open() }
                    }
                    Spacer()
                }
                // VX-263's one line — the key door says it (rule 6: "the doors say so in one sentence").
                Text(ProtectionWords.keyDoorsLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let message = look?.message {
                    Text(message)
                        .font(.callout)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
