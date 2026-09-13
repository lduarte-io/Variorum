//
//  QuietReceiptLine.swift
//  Variorum (Mac)
//
//  **18i — THE QUIET SLOT** (her ruling R-Q5, from the 2026-09-12 report:
//  *"i either need them off, more subtle in the bottom bar in more muted
//  text, or a setting"*). This is the "more subtle in the bottom bar in more
//  muted text" half, and it is ONE view every bar composes — never a per-bar
//  copy, and never a second `if setting` beside the centre's one routing
//  rule (the round's review focus F-6).
//
//  What it renders: `StatusCenter.quietLine` — a RECEIPT under her `.quiet`
//  setting. Refusals and offers never reach it (they are the shell toast's,
//  under every setting), and under `.toast` or `.off` this slot stays empty
//  by construction, because the centre never writes it.
//
//  ── WHY IT IS ALWAYS MOUNTED, AND FADES RATHER THAN APPEARING ────────────
//  A `Text` that comes and goes changes a bar's layout six seconds after
//  every act — doors moving under her cursor is the hazard the app's own
//  walk standard names. So the view is always in the row and carries the
//  empty string when there is nothing to say, and the words fade in and out
//  on the centre's own clock.
//
//  **What "takes no room" means exactly** (corrected at the 18i ladder round
//  1, J31 — the shipped header said "zero width, nothing drawn, no reflow",
//  which is true of the three FLAT bars and false of the fourth site):
//  · in the horizontal bars (`CommitBar`'s three tiers, `TakesBottomBar`'s
//    two arrangements) an idle slot measures **zero width** and the row's
//    height is the doors' — nothing reflows, which is the claim those bars
//    depend on;
//  · in the VERTICAL composition — the book's sidebar note-box footer, where
//    this view has its own row — an idle slot measures zero width but still
//    **one line's height** (14 pt measured), and that reservation is
//    DELIBERATE: the footer holds the word counts and the `?` helper DOOR,
//    and collapsing the row would move a door 18 pt when a receipt lands and
//    18 pt back six seconds later — precisely the noise her setting exists
//    to remove. The box's content scrolls inside a column-fixed frame, so
//    the reserved row costs a blank line and nothing below it moves.
//  Both halves are pinned (`ConfirmationsSettingTests.theQuietSlotIsWeightlessUntilItSpeaks`).
//
//  ── AND WHY IT YIELDS FIRST ──────────────────────────────────────────────
//  `layoutPriority(-1)`: the counts, the doors and the `?` take their ideal
//  width first and the receipt takes what is left, truncating to nothing at
//  a narrow window rather than pushing anything off the bar. The whole
//  sentence is always one hover away (`help`), and `.toast` shows it whole.
//  P-8's rule is satisfied the way it is written: a chrome text with
//  `fixedSize` carries a `lineLimit` — this one carries a `lineLimit` and
//  deliberately no horizontal `fixedSize`, which is the same rule's other
//  side.
//

import SwiftUI

struct QuietReceiptLine: View {
    let status: StatusCenter
    let tokens: VoiceTokens
    /// 1 in the flat bars (one row, truncating — the bar's height must never
    /// move); 2 in the sidebar note box, whose column is ~200 pt wide and
    /// whose content already scrolls inside a fixed frame, so wrapping costs
    /// nothing and a one-line truncation there would say almost nothing.
    var lines: Int = 1

    var body: some View {
        let item = status.quietLine
        Text(item?.text ?? "")
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(lines)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: lines > 1)
            .textSelection(.enabled)
            .opacity(item == nil ? 0 : 1)
            .animation(.easeInOut(duration: 0.18), value: item?.id)
            .help(item?.text ?? "")
            .accessibilityHidden(item == nil)
            .layoutPriority(-1)
    }
}
