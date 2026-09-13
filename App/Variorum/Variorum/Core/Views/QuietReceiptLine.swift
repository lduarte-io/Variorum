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
//  empty string when there is nothing to say: zero width, nothing drawn, no
//  reflow. The words fade in and out on the centre's own clock.
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
