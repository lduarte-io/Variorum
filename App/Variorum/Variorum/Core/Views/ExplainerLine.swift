//
//  ExplainerLine.swift
//  Variorum (MAC ONLY)
//
//  VX-281 U1 — R-VX184-6, her words: "every explainer cut to one line with
//  the full text behind an (i) popover" (the MCP pane — "as a settings pane,
//  it has a LOT of text"). ONE line of explanation that never wraps, and an
//  (i) beside it whose popover holds the WHOLE text — the line is a summary,
//  the popover the truth it summarizes, so no explanation is lost by the cut.
//  When the line already IS the whole text there is no (i) (a door that
//  opens onto the same words would be a dead one — P-2).
//
//  Shared Mac chrome (`Core/Views/`) on purpose: the MCP pane and its grant
//  sheet use it first, and the settings effort (her Settings wording pass,
//  VX-234) is its next reader. Token-free — semantic styles only — so any
//  Settings pane can put it in a grouped form beside the system's own rows.
//

import SwiftUI

struct ExplainerLine: View {
    /// What reads on the pane: one line, in the line's own font.
    let line: String
    /// The whole explanation, shown in the (i)'s popover.
    let detail: String
    var font: Font = .caption
    /// **A VOICED host's tokens** (VX-431, the VX-440 run — Block History's
    /// region lines adopt this idiom). Given, the line speaks in the voice —
    /// the voice's small type and faint ink, its chrome casing — the rule the
    /// pane's own lines already keep (`CommitsPageLedgerTests`' precision 6:
    /// no system caption between mono rows). Nil — every Settings host — is
    /// the token-free form, byte for byte. The STORED strings stay raw either
    /// way; the voice is applied where they are drawn.
    var tokens: VoiceTokens? = nil
    @State private var showing = false

    private var lineFont: Font { tokens?.small ?? font }
    private var lineInk: AnyShapeStyle {
        tokens.map { AnyShapeStyle($0.faint) } ?? AnyShapeStyle(.secondary)
    }
    private func voiced(_ text: String) -> String { tokens?.chromeLabel(text) ?? text }

    /// The (i)'s name — its help tag and what VoiceOver says (PROVISIONAL
    /// words — VX-234).
    static let moreLabel = "More about this"

    /// The popover's measure: a comfortable reading width for a paragraph.
    static let popoverWidth: CGFloat = 320

    /// Whether this line carries an (i) — only when there is more to say.
    nonisolated static func opens(line: String, detail: String) -> Bool {
        line != detail && !detail.isEmpty
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(voiced(line))
                .font(lineFont)
                .foregroundStyle(lineInk)
                // P-8: one line, by her ruling — the whole text is one press
                // away, so the summary never wraps (and never measures one
                // character per line under a probe).
                .lineLimit(1)
                .truncationMode(.tail)
            if Self.opens(line: line, detail: detail) {
                Button {
                    showing.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .font(lineFont)
                        .foregroundStyle(lineInk)
                }
                .buttonStyle(.borderless)
                .help(Self.moreLabel)
                .accessibilityLabel(Self.moreLabel)
                .popover(isPresented: $showing, arrowEdge: .bottom) {
                    Text(voiced(detail))
                        .font(tokens?.body ?? .callout)
                        .textSelection(.enabled)
                        // P-8, deliberate: the WHOLE explanation — truncating
                        // it would undo the very cut the line made.
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: Self.popoverWidth, alignment: .leading)
                        .padding(14)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}
