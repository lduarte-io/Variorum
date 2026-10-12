//
//  MastheadPopover.swift
//  Variorum (Mac)
//
//  **librarywalkpolish VR-115 — ONE masthead-popover idiom** (R-LWP-1,
//  AMENDED at her screenshots, 2026-10-05). Her words: the native order menu
//  "looks out of place in the app"; the № float's "font and sizing and such
//  is better, but solo is fairly meaningless - highlighting the selected row
//  would be better... like making the order menu look a bit more in tune
//  with the rest of the app?"
//
//  So both of the Bookcase's droppers — № (the census) and order ▾ — open
//  THIS: the float's own type (the voice's small face, its row metrics), a
//  hairline and a menu-grade shadow, width to its content, seated under the
//  control that opened it. The SELECTED row wears a quiet fill (the strip's
//  filled-chip language — `QuietFill`, VR-119); there is no checkmark and no
//  "solo" column: the row itself is the act.
//
//  Placement is the HOST's (`MastheadDropper` anchors, read by the board's
//  root overlay), so the popover floats over the board without pushing a
//  row (17y (r)'s rule) and lands under its own control.
//

import SwiftUI

/// **The quiet fills** — one language for "this one" across the masthead:
/// the strip's chips at rest (a light wash square) and filled (the subtle
/// accent tone, VR-119), and the popover's selected row (the same fill).
/// Derived from the voice's tokens — never a literal (the 18j pin).
enum QuietFill {
    /// A chip at rest: the voice's selection wash, lightened.
    static func rest(_ tokens: VoiceTokens) -> Color { tokens.wash.opacity(0.55) }
    /// The chosen one: the subtle accent tone.
    static func chosen(_ tokens: VoiceTokens) -> Color { tokens.accent.opacity(0.13) }
    /// The near-square corner (her "very subtle and square").
    static let corner: CGFloat = 4
}

/// The controls a masthead popover hangs from.
enum MastheadDropper: Hashable {
    case census, order
    /// VX-170: the Takes board's `show ▾` (lens-aware Takes, R-VX170-4 — "the
    /// order-menu/census masthead-popover idiom").
    case takesShow
}

/// Each dropper control publishes its bounds; the board's root overlay seats
/// the open popover under it.
struct MastheadDropperAnchors: PreferenceKey {
    static let defaultValue: [MastheadDropper: Anchor<CGRect>] = [:]
    static func reduce(
        value: inout [MastheadDropper: Anchor<CGRect>],
        nextValue: () -> [MastheadDropper: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

extension View {
    /// Publish this control as the anchor of its masthead popover.
    func mastheadDropperAnchor(_ dropper: MastheadDropper) -> some View {
        anchorPreference(key: MastheadDropperAnchors.self, value: .bounds) { [dropper: $0] }
    }
}

/// One popover row: its words, whether it is the selected one, whether it can
/// act (a zero census row is faint and inert — P-2), and the act.
struct MastheadPopoverRow: Identifiable {
    let id: String
    let title: String
    var selected = false
    var enabled = true
    let action: () -> Void
}

/// **The popover face** — the rows, nothing else.
struct MastheadPopover: View {
    let tokens: VoiceTokens
    let rows: [MastheadPopoverRow]
    @Environment(\.colorScheme) private var scheme

    /// The rows' insets — the № float's, kept (her "font and sizing").
    static let rowInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 14)
    /// Where the popover sits under its control.
    static let gap: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(rows) { row in
                Button(action: row.action) {
                    Text(tokens.chromeLabel(row.title))
                        .font(tokens.small)
                        .fontWeight(row.selected ? .semibold : .regular)
                        .foregroundStyle(
                            row.selected ? tokens.ink : (row.enabled ? tokens.muted : tokens.faint))
                        .lineLimit(1)
                        .fixedSize()
                        .padding(Self.rowInsets)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            row.selected ? QuietFill.chosen(tokens) : Color.clear,
                            in: RoundedRectangle(cornerRadius: QuietFill.corner))
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!row.enabled)
                .accessibilityAddTraits(row.selected ? .isSelected : [])
            }
        }
        .mastheadPopoverChrome(tokens: tokens, scheme: scheme)
    }
}

extension View {
    /// **The popover's FACE, one copy** (VX-170): the vertical inset, one line
    /// per row, width to content, the surface, the hairline and the
    /// menu-grade shadow. `MastheadPopover`'s own body wears it unchanged (the
    /// same modifiers in the same order — a move, not a restyle), and a
    /// popover whose rows carry more than words (the Takes `show ▾`'s inline
    /// lens pickers) wears the same face instead of a second copy of it.
    func mastheadPopoverChrome(tokens: VoiceTokens, scheme: ColorScheme) -> some View {
        self
            .padding(.vertical, 5)
            .lineLimit(1)  // P-8: one line per row, so the width-to-content is never a wrapped one
            .fixedSize()
            .background(tokens.surface, in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1))
            // A menu-grade shadow (light only — the fully black room, R51,
            // carries none; the app's own shadow precedent).
            .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.13), radius: 12, y: 5)
            .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.07), radius: 1.5, y: 1)
    }
}
