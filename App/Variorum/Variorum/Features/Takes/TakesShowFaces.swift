//
//  TakesShowFaces.swift
//  Variorum
//
//  **VX-170 — the `show ▾` door, its chip, and its popover** (R-VX170-4: *"the
//  control is a masthead `show ▾` popover (the order-menu/census masthead-
//  popover idiom), resting as 'all takes', wearing a quiet chip while a filter
//  is active"*). The door sits on the Takes board's own header line — the
//  Takes mode's masthead — dressed as the Bookcase's `order ▾` (a quiet word
//  with a hover wash, publishing its anchor); the popover wears the ONE
//  masthead-popover face (`mastheadPopoverChrome`), seated under the door by
//  the board's overlay, and lives like a menu. Its rows: "all takes" (the
//  clear), then the four forms of R-VX170-1 with the note's lenses as inline
//  pickers ("the chosen takes" the fixed second operand of the last form). The
//  active form's row wears the quiet fill. Every rule is the controller's.
//

import SwiftUI
import VariorumCore

extension TakesShowCopy {
    /// Segments as one `Text`: app words voiced (`chromeLabel`), lens names
    /// verbatim (they are hers — never case-folded).
    static func text(_ segments: [Segment], tokens: VoiceTokens) -> Text {
        segments.reduce(Text(verbatim: "")) { text, segment in
            let next = switch segment {
            case .words(let words): Text(verbatim: tokens.chromeLabel(words))
            case .name(let name): Text(verbatim: name)
            }
            return Text("\(text)\(next)")
        }
    }

    /// A flat reading of segments — the door's tooltip, and the pins' words.
    static func plain(_ segments: [Segment]) -> String {
        segments.map {
            switch $0 {
            case .words(let words): words
            case .name(let name): name
            }
        }.joined()
    }
}

/// The header's door and, while a filter is active, its quiet chip.
struct TakesShowDoor: View {
    let filter: TakesLensFilterController
    let tokens: VoiceTokens
    @State private var hovering = false

    /// "show: " + the expression + " ▾" — the app's words voiced, the lens
    /// names verbatim.
    private var doorLabel: Text {
        let lead = Text(verbatim: tokens.chromeLabel("show: "))
        let expression = TakesShowCopy.text(filter.label, tokens: tokens)
        let caret = Text(verbatim: " \u{25BE}")
        return Text("\(lead)\(expression)\(caret)")
    }

    var body: some View {
        HStack(spacing: 6) {
            Button { filter.toggleMenu() } label: {
                doorLabel
                    .font(tokens.small)
                    .foregroundStyle(
                        filter.menuOpen || filter.filter != nil ? tokens.ink : tokens.muted)
                    // One line; under a crowded header the EXPRESSION yields
                    // (the tail ellipsizes) — the tooltip says it whole.
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        hovering || filter.menuOpen ? tokens.wash : Color.clear,
                        in: RoundedRectangle(cornerRadius: 4))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            .help(filter.filter == nil
                  ? "Show only the blocks a lens names — in a lens, in one and not another, "
                    + "or where a lens disagrees"
                  : "Showing: " + TakesShowCopy.plain(filter.label))
            .mastheadDropperAnchor(.takesShow)
            if let chip = filter.chip {
                // The quiet chip (VoicedChip's resting face — a word in a
                // hairline capsule — as a MARK, never a second door: clearing
                // is the popover's first row).
                Text(verbatim: tokens.chromeLabel(chip))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 1)
                    .overlay(Capsule().stroke(tokens.line, lineWidth: 1))
                    .help(TakesShowCopy.chipHelp)
            }
        }
    }
}

/// The popover: the rows, on the one masthead-popover face.
struct TakesShowPopover: View {
    let filter: TakesLensFilterController
    let tokens: VoiceTokens
    @Environment(\.colorScheme) private var scheme

    /// One run of a row: words, or the picker for operand `index`.
    private enum Part: Hashable {
        case words(String)
        case picker(Int)
    }

    private func parts(_ row: TakesShowMenuRow) -> [Part] {
        guard let form = row.form else { return [.words(TakesShowCopy.allTakes)] }
        var index = 0
        return TakesShowCopy.rowWords(form).map { words in
            if let words { return .words(words) }
            defer { index += 1 }
            return .picker(index)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filter.menuRows) { row in
                rowView(row)
            }
        }
        .mastheadPopoverChrome(tokens: tokens, scheme: scheme)
    }

    private func rowView(_ row: TakesShowMenuRow) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(parts(row).enumerated()), id: \.offset) { _, part in
                switch part {
                case .words(let words):
                    Text(verbatim: tokens.chromeLabel(words))
                case .picker(let index):
                    picker(row, at: index)
                }
            }
        }
        .font(tokens.small)
        .fontWeight(row.selected ? .semibold : .regular)
        .foregroundStyle(row.selected ? tokens.ink : (row.enabled ? tokens.muted : tokens.faint))
        .lineLimit(1)
        .fixedSize()
        .padding(MastheadPopover.rowInsets)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            row.selected ? QuietFill.chosen(tokens) : Color.clear,
            in: RoundedRectangle(cornerRadius: QuietFill.corner))
        .padding(.horizontal, 4)
        // The row's WORDS apply it (its pickers take their own presses).
        .contentShape(Rectangle())
        .onTapGesture { filter.choose(row) }
        .disabled(!row.enabled)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(row.selected ? [.isSelected, .isButton] : .isButton)
        .help(row.form == nil
              ? "Every block, every take — Takes as it always reads"
              : (row.enabled ? "Show only the blocks where this holds"
                             : "This one needs two lenses on the note"))
    }

    /// An inline lens picker: the operand's NAME (verbatim) and ▾; its menu
    /// lists the note's lenses but the row's other operand. A pick applies the
    /// form at once and the popover stays open.
    private func picker(_ row: TakesShowMenuRow, at index: Int) -> some View {
        let named = row.operands.indices.contains(index)
        return Menu {
            ForEach(filter.pickerLenses(row, at: index), id: \.id) { lens in
                Button(lens.name) { filter.pick(lens.id, at: index, in: row) }
            }
        } label: {
            Text(verbatim: (named ? filter.name(ofLens: row.operands[index])
                            : tokens.chromeLabel("another lens")) + " \u{25BE}")
                .underline(named, color: tokens.faint)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        // P-8 (VX-245): the lens's name and its ▾ are one-line chrome.
        .lineLimit(1)
        .fixedSize()
        .disabled(!named)
    }
}
