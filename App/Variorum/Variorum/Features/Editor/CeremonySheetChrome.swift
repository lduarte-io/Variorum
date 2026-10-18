//
//  CeremonySheetChrome.swift
//  Variorum (Mac)
//
//  **THE TWO CEREMONIES' ONE FACE** — 18f batch 2, mockup figures A and B
//  (`notes/plans/use-report-2026-09-06-mockups/ceremony-and-note-box.html`).
//  Figure B's note says why this file exists: *"the same first-row grammar as
//  divide, so the two ceremonies read as one family."* One vocabulary, two
//  sheets — the alternative is two faces drifting apart at every touch.
//
//  Built on the app's own chrome vocabulary (P-8): `CalmGrammar`'s card and
//  button grammar (the pre-13u style guide — squarish-rounded controls, calm
//  cards, generous targets) and `VoiceTokens` throughout, so both voices and
//  both schemes come for free and no literal colour lives here.
//
//  Everything in this file is presentation. No state, no store, no rows.
//

import SwiftUI

// MARK: - The header (title · facts · the folded ?)

/// The sheet's head: its name, a quiet facts line, and the `?` that holds the
/// keyboard legend and the long explainers (§5.2: *"explainers folded"* — the
/// shipped sheet stacked three paragraphs above the takes).
struct CeremonySheetHeader: View {
    let tokens: VoiceTokens
    let title: String
    let facts: [String]
    /// The folded explainers, in order. Markdown-lite (`**bold**`) is
    /// rendered — the sheet's copy already speaks it.
    let help: [String]
    @State private var helpShown = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if !facts.isEmpty {
                    // Always the middle dot — the voice's own path separator
                    // is "/" in terminal, which would read as a fraction here.
                    Text(facts.joined(separator: " \u{00B7} "))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            if !help.isEmpty {
                Button { helpShown.toggle() } label: {
                    Text("?")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .frame(width: 22, height: 22)
                        .background(tokens.card, in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(tokens.line, lineWidth: 1))
                        .contentShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                // Row 3's rule (18f batch 1): a control in this sheet must
                // never quietly take the placement keys' first responder.
                .focusable(false)
                .help("What the keys do, and what a check means")
                .popover(isPresented: $helpShown, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(help.enumerated()), id: \.offset) { _, line in
                            Text(.init(line))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .lineLimit(8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(14)
                    .frame(width: 380)
                }
            }
        }
    }
}

// MARK: - The arrangement row (U-5 · U-16)

/// One option in the row of four (divide) or three (merge): a calm card with
/// its title and its one-line description, selected ⇒ accent border + wash.
/// The deliberate option ("Choose per take…", "Pair by hand…") wears a dashed
/// border — the mockup's `.opt.custom`, and her *"something you really have
/// to choose to do"* said in the border.
struct ArrangementOptionCard: View {
    let tokens: VoiceTokens
    let title: String
    let detail: String
    let selected: Bool
    var deliberate = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(selected ? tokens.accent : tokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(tokens.card),
                in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        selected ? tokens.accent : tokens.line,
                        style: StrokeStyle(
                            lineWidth: selected ? 1.5 : 1,
                            dash: deliberate && !selected ? [4, 3] : [])))
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        // Row 3 (18f batch 1): these act; they never need focus.
        .focusable(false)
    }
}

// MARK: - The footer

/// The sheet's foot: the confirm blocker in the LEFT slot in the warning
/// colour when it applies, the resting line when it does not, and the two
/// buttons. §5.2's letter, and 13f W10a's promise kept in the resting line.
struct CeremonySheetFooter: View {
    let tokens: VoiceTokens
    let blocker: String?
    let restingLine: String
    let confirmTitle: String
    let canConfirm: Bool
    let cancel: () -> Void
    let confirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            HStack(alignment: .center, spacing: 16) {
                Text(blocker ?? restingLine)
                    .font(tokens.small)
                    .foregroundStyle(blocker == nil ? tokens.muted : tokens.alarm)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Cancel") { cancel() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                    .keyboardShortcut(.cancelAction)
                Button(confirmTitle) { confirm() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
                    // VX-194 (R-VX381-A2): the disabled face is the STYLE's
                    // now — it reads this `.disabled`. The local 0.45 fade
                    // that stood here would have dimmed it twice.
                    .disabled(!canConfirm)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Badges

/// A take's quiet badge — "shown here", "locked". The mockup's `.badge`.
struct CeremonyBadge: View {
    let tokens: VoiceTokens
    let text: String
    var tint: Color?

    var body: some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tint ?? tokens.muted)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(
                (tint ?? tokens.muted).opacity(0.09),
                in: RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke((tint ?? tokens.line).opacity(tint == nil ? 1 : 0.35), lineWidth: 1))
    }
}

/// The two calm paper tints the divide card shows its halves in, and the
/// swatch that names them in the card's footer.
///
/// §5.2 leaves the tint to the implementer; the mockup's are a faint green
/// above and a warm paper below. Token-derived so both voices and both schemes
/// carry them: `chosen` is the green in ALL FOUR voices, and `ring` is the
/// warm brown in the study voice (the mockup's own `--bottom`) and the blue in
/// the terminal one — which is also the ✂ mark's colour, so the lower half
/// wears the hue of the cut that made it. **Two token-derived faint washes,
/// never a literal (P-8); the hues are placeholders revisable at 13s's design
/// review, like `alarm`'s and `positive`'s.**
enum CeremonyHalfTint {
    static func top(_ tokens: VoiceTokens) -> Color { tokens.chosen.opacity(0.15) }
    static func bottom(_ tokens: VoiceTokens) -> Color { tokens.ring.opacity(0.13) }
}

struct CeremonySwatch: View {
    let color: Color
    let label: String
    let tokens: VoiceTokens

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(tokens.line, lineWidth: 0.5))
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
    }
}
