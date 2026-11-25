//
//  BookTagsSwitch.swift
//  Variorum (Mac)
//
//  **VX-1038 (T-5 / R-1036-39) — the per-book tags switch's face**: a chip
//  beside "expand all · collapse all", three positions — hidden (the default) ·
//  other tags · all tags. Her words (sitting 3): *"I like showing the tags that
//  aren't part of the rule of where it is as an option, to minimize visual
//  clutter"*; the dialog's pick, "Third position on the switch". A value and a
//  closure (the model is `BookCardTagsModel`), so the face renders without a
//  store. One of the four faces §4f names as existing only in words — shown to
//  her at the run's walk (R-1036-47 waived it to the morning checklist).
//

import SwiftUI
import VariorumCore

// MARK: - The switch's face (T-5 / R-1036-39)

/// The words the switch says (public copy, sentence case; Terminal lowers its
/// chrome). PROVISIONAL with the face (§4f names the face as one she sees at
/// the walk): the chip reads "tags: hidden / other / all", its menu the
/// ruling's three positions.
nonisolated enum BookTagsSwitchCopy {
    static let label = "tags"
    static func chip(_ position: BookTagsShown) -> String {
        switch position {
        case .hidden: "\(label): hidden"
        case .otherTags: "\(label): other"
        case .allTags: "\(label): all"
        }
    }
    static func row(_ position: BookTagsShown) -> String {
        switch position {
        case .hidden: "Hidden"
        case .otherTags: "Other tags"
        case .allTags: "All tags"
        }
    }
    /// True on BOTH kinds (the VX-1036 ladder's N3): "other tags" leaves off
    /// the tags that place a note only in a GATHERING; in a plain book it shows
    /// everything (R-1036-39's letter, `BookCardTagsModel.pills(for:)`).
    static let help =
        "Show each note\u{2019}s tags on its card \u{2014} all of them, or the other tags only "
        + "(in a gathering, every tag but the ones that place the note there; in a book, all of them). "
        + "A way of looking: remembered for this book on this Mac."
}

/// **The per-book switch** — a chip beside "expand all · collapse all" (the
/// round-1 mockup's seat, grown to three values — R-1036-39). A menu of the
/// three positions with the native checkmark (an inline picker — the Index
/// `group ▾`'s idiom; not `VoicedMenu`, whose `.fixedSize()` the Index
/// control declined for the same column). A way of looking: undeclared in the
/// registry, as the Index's grouping and the dial's looks are.
struct BookTagsSwitch: View {
    let tokens: VoiceTokens
    /// The book's position, and the act that chooses one
    /// (`BookCardTagsModel.setPosition` — remembered per book, this Mac).
    let position: BookTagsShown
    let choose: (BookTagsShown) -> Void

    var body: some View {
        let selection = Binding<BookTagsShown>(get: { position }, set: { choose($0) })
        Menu {
            Picker(BookTagsSwitchCopy.label, selection: selection) {
                ForEach(BookTagsShown.allCases, id: \.self) { position in
                    Text(tokens.chromeLabel(BookTagsSwitchCopy.row(position))).tag(position)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } label: {
            Text(tokens.chromeLabel(BookTagsSwitchCopy.chip(position)))
                .font(tokens.small)
                .foregroundStyle(position == .hidden ? tokens.muted : tokens.accent)
                .lineLimit(1)
                .padding(.horizontal, 7)
                .padding(.vertical, 1)
                .overlay(Capsule().stroke(position == .hidden ? tokens.line : tokens.accent.opacity(0.5), lineWidth: 1))
                .fixedSize()
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .help(BookTagsSwitchCopy.help)
    }
}

