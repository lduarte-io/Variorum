//
//  TagInlineField.swift
//  Variorum (MAC ONLY) — Core/Views: the inline tag field
//
//  Born in `Features/Tags/MastheadTagCluster.swift` (the Act 10 correction
//  round's row 15 — her "tag creator" field, cursor already active) and moved
//  here at VX-1036 batch 2, when a second feature began to render it: the book
//  Outline's card headers open it from their "+" (VX-1038's T-3). A move: the
//  type keeps its name; the masthead's ＃ opens it exactly as before.
//

import SwiftUI
import VariorumCore

/// **The inline tag field** (row 15 — her "tag creator" field, cursor
/// already active). The popover's brain in an inline body: one squarish
/// field (W8-2's search-field grammar), focused on appear; ⏎ applies what
/// was typed (creating the path if it is new — the standing door), ⎋
/// dismisses, and the live taxonomy's matches hang under it as a small
/// list a click applies.
struct TagInlineField: View {
    let tokens: VoiceTokens
    let allTags: [Tag]
    let applied: Set<String>
    let onApply: (String) -> Void
    /// Row 40: the field resigned the keyboard — the CLUSTER decides what
    /// that means, because only it knows whether the note carries a tag.
    let onFocusLost: () -> Void
    let onDismiss: () -> Void
    /// VX-576: how many live notes wear each tag (by id) — the suggestions
    /// order most-used first; empty (the default) keeps the path order.
    var uses: [String: Int] = [:]

    @State private var typed = ""
    @FocusState private var focused: Bool

    /// The field's width — room for a nested path, never a search bar.
    static let width: CGFloat = 190

    private var suggestions: [Tag] {
        TagChipAdder.suggestions(allTags, typed: typed, applied: applied, limit: 6, uses: uses)
    }

    var body: some View {
        TextField("", text: $typed, prompt: Text(tokens.chromeLabel("tag — ⏎ applies · / nests")))
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .focused($focused)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .frame(width: Self.width)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(focused ? tokens.accent.opacity(0.45) : tokens.line, lineWidth: 1))
            .onSubmit { apply(typed) }
            .onExitCommand { onDismiss() }
            // Row 40: clicking out reports. A suggestion row is a plain
            // `Button`, which does not take the keyboard on macOS, so this
            // cannot fire under a click on the list below.
            .onChange(of: focused) { _, nowFocused in
                if !nowFocused { onFocusLost() }
            }
            // The matches hang UNDER the field, over whatever sits below the
            // masthead (the masthead's z-order lifts them above the page).
            .overlay(alignment: .topLeading) {
                if focused, !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.id) { tag in
                            Button {
                                apply(tag.path)
                            } label: {
                                Text(tokens.chromeLabel(tag.path))
                                    .font(tokens.small)
                                    .foregroundStyle(
                                        TagChipColor.color(forPath: tag.path, dark: false))
                                    .lineLimit(1)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .frame(width: Self.width, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(tokens.line, lineWidth: 1))
                    .offset(y: 26)
                    // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                    // states its own line policy, so its IDEAL width can never be a
                    // wrapped one (the b6dae25 class's window-sizing hazard).
                    // The suggestion rows carry their own `lineLimit(1)` inside; the
                    // PANEL states it too, so the class is mechanical rather than a
                    // fact four lines down the file.
                    .lineLimit(1)
                    .fixedSize()
                }
            }
            .task { focused = true }
            .help("Tag this note — type a path (\u{201C}/\u{201D} nests: life/goals), \u{23CE} applies, \u{238B} closes")
    }

    private func apply(_ path: String) {
        let trimmed = path.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        typed = ""
        onApply(trimmed)
    }
}
