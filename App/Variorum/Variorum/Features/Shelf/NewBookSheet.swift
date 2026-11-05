//
//  NewBookSheet.swift
//  Variorum (Mac)
//
//  VX-561 (the VX-805 run, Unit A) — THE NEW BOOK DIALOG, WITH ITS WAY OUT.
//
//  The Bookcase masthead's "+ New Book" presented `.alert("New Book")`: a Name
//  field and FOUR buttons — Create Book, Create Gathering…, Create Journal
//  Book, and `Button("Cancel", role: .cancel)`. On macOS 26/27 the alert draws
//  its buttons stacked, and the stage walk (2026-11-05, captures
//  `walk-vx805/08–12`, and her own Esc on the real keyboard) saw only the
//  three create buttons: the declared cancel-role button never rendered, so
//  the alert carried no Escape key equivalent — Esc did nothing, a click away
//  did nothing (an alert sheet is modal), ⌘Q was held while it stood, and the
//  only way out was to create a book. The beta report's "now I can't Esc-out
//  of the dialog" was this.
//
//  The fix gives the dialog the app's sheet conventions (`MintGatheringSheet`,
//  the rule editor): a real sheet whose Cancel button is drawn and carries
//  `.cancelAction` (Esc), whose Create Book carries `.defaultAction` (⏎, the
//  alert's blue button), with the Name field focused on arrival. Cancel mints
//  nothing and drops the typed name, as every creation dialog does (the door
//  clears the field at each open). The CHOICE runs after the sheet is gone
//  (`ShelfView`'s `onDismiss`), so "Create Gathering…" can present the
//  gathering mint sheet without two sheets racing one host.
//

import SwiftUI
import VariorumCore

/// The dialog's words — the alert's own, carried verbatim.
nonisolated enum NewBookCopy {
    static let title = "New Book"
    static let createBook = "Create Book"
    /// The gathering door: the mint sheet's title with the ellipsis (it asks
    /// more — the rule), as the alert said it.
    static let createGathering = RuleEditorCopy.mintTitle + "\u{2026}"
    static let createJournalBook = "Create Journal Book"
    static let cancel = "Cancel"
    static let namePrompt = "Name"
}

struct NewBookSheet: View {
    /// What she chose. Nil until a create door is pressed — Cancel (or Esc)
    /// leaves it nil, and nothing is minted.
    enum Choice: Equatable, Sendable {
        case book, gathering, journalBook
    }

    @Binding var name: String
    /// The shelf sentence ("It lands on “‹shelf›”, the shelf you're looking
    /// at. ") or empty — the alert's message lead, unchanged.
    let shelfLine: String
    /// Records the choice; the host acts on it once the sheet has gone.
    let onChoose: (Choice) -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NewBookCopy.title)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(shelfLine + BookcaseCopy.newBookMessage)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            TextField(NewBookCopy.namePrompt, text: $name)
                .focused($nameFocused)
                .onSubmit { choose(.book) }
            HStack {
                Button(tokens.chromeLabel(NewBookCopy.cancel)) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(tokens.chromeLabel(NewBookCopy.createGathering)) { choose(.gathering) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                Button(tokens.chromeLabel(NewBookCopy.createJournalBook)) { choose(.journalBook) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                Button(tokens.chromeLabel(NewBookCopy.createBook)) { choose(.book) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 520, alignment: .leading)
        .background(tokens.surface)
        .onAppear { nameFocused = true }
    }

    private func choose(_ choice: Choice) {
        onChoose(choice)
        dismiss()
    }
}
