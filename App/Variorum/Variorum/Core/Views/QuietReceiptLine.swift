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
//  **What "takes no room" means exactly** (round 1's J31, RE-TAKEN at round
//  2's J39 on a measurement that falsified its premise; the width clause
//  corrected at round 3's N1). It is a claim about what the slot ASKS FOR:
//  · in the horizontal bars (`CommitBar`'s three tiers, `TakesBottomBar`'s
//    two arrangements) an idle slot asks for **zero width**, so nothing in
//    the row reflows for it — the claim those bars depend on — and the row's
//    height is the doors';
//  · in the VERTICAL composition — the book's sidebar note-box footer, where
//    this view has its own row — an idle slot asks for zero width but takes
//    **one line's height** (14 pt measured), reserved DELIBERATELY: the
//    footer holds the word counts and the `?` helper DOOR, and a row that
//    came and went would move that door 18 pt on every receipt and 18 pt
//    back six seconds later. (Its RENDERED width there is the column's — the
//    round-2 oracle measures it constrained and asserts the height, not the
//    width, which is why the width half of this clause is about the ideal
//    size and not about what the pin reads.)
//
//  **ONE LINE, EVERYWHERE — and that is why there is no `lines` knob** (J39).
//  This view shipped with a two-line option for the box, on the reasoning
//  that "a one-line truncation in a ~200 pt column would say almost nothing".
//  The measurement refutes it: at `tokens.small` the receipt *"Blocks joined
//  — ⌥⌘Z undoes it."* is **204 pt** wide, so in the box's 200 pt column the
//  second line carried about one character — and bought that with a real
//  14 pt shove of the counts row and the `?` door on every receipt over
//  roughly 28 characters, which is most of them. At one line the claim above
//  is LITERALLY true in every composition: the row is reserved once, nothing
//  ever moves for it, the words truncate at the column's edge exactly as
//  they do in the three flat bars, and the whole sentence is one hover away
//  (`help`) — the shape she already walked. Pinned, WIDTH-CONSTRAINED, at
//  `ConfirmationsSettingTests.theQuietSlotIsWeightlessUntilItSpeaks`; the
//  round-1 version of that pin measured an unconstrained `fittingSize` and
//  could not fail.
//
//  ── AND WHY IT YIELDS FIRST ──────────────────────────────────────────────
//  `layoutPriority(-1)`: the counts, the doors and the `?` take their ideal
//  width first and the receipt takes what is left, truncating to nothing at
//  a narrow window rather than pushing anything off the bar. The whole
//  sentence is always one hover away (`help`), and `.toast` shows it whole.
//  P-8's rule is satisfied the way it is written: a chrome text with
//  `fixedSize` carries a `lineLimit` — this one carries a `lineLimit` and no
//  `fixedSize` at all, which is the same rule's other side.
//
//  ── AND WHY IT IS SELECTABLE ─────────────────────────────────────────────
//  `.textSelection(.enabled)` in window chrome is deliberate (the 18i ladder
//  round 1, N5): `StatusToast` and `WriteTakesPanel`'s own status slot carry
//  the same modifier, so this line speaks the chrome's existing vocabulary,
//  and a receipt naming an export path or a block's name is worth being able
//  to copy. The hit-target it adds is bounded by construction — idle the view
//  has zero width, and speaking it sits at the bar's trailing end where
//  `layoutPriority(-1)` guarantees it overlaps no door.
//

import SwiftUI

struct QuietReceiptLine: View {
    let status: StatusCenter
    let tokens: VoiceTokens
    /// 13n-c UX walk W-UX-15: a bar whose hint TEXT follows this slot (the
    /// Bookcase's "⌘J today · ⌘N new note", a reading bar's page line) asks
    /// for a hairline after a SPEAKING receipt, so its words — and its door's
    /// "Open ›" — never run into the hint's. Drawn only while it speaks: an
    /// idle slot still asks for zero width (the weightless claim).
    var separated = false

    var body: some View {
        let item = status.quietLine
        HStack(spacing: 6) {
            Text(item?.text ?? "")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                // 13n-b U4 walk W-1: a receipt that carries a door (an AI
                // write's "Open ›") gives the door its width, so on a crowded
                // bar it truncates in the MIDDLE — the head says who, the tail
                // keeps "⌥⌘Z undoes" (the U2 walk's W-2 promise: the undo
                // hint is never what the truncation eats). Door-less receipts
                // keep the tail truncation they always had.
                .truncationMode(item?.action == nil ? .tail : .middle)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .help(item?.text ?? "")
            // 13n-c U3 (R-AIR-4; T-U3-6): a share receipt carries a SECOND
            // door — "Change…" beside "Revoke ›" — drawn before the act's own
            // door, the toast's order (`StatusToast`: secondary, then
            // action). Like the first, only while such a receipt speaks.
            if let secondary = item?.secondary {
                Button(secondary.label) {
                    status.clear()
                    secondary.perform()
                }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
                .fixedSize()
                // Two doors side by side read as two in a mono voice too (the
                // U3 capture: Terminal's "Change… Revoke ›" ran together).
                .padding(.trailing, 4)
            }
            // 13n-b U4 (R-13nb-23 (a), AF-11 F-2): a receipt may carry ONE
            // door — an AI write's "Open ›". Drawn only while such a receipt
            // speaks, so an idle slot still asks for zero width (the
            // weightless claim above holds); its keyboard road is ⌥⌘O.
            if let action = item?.action {
                Button(action.label) {
                    status.clear()
                    action.perform()
                }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
                .fixedSize()
            }
            if separated, item != nil {
                Rectangle()
                    .fill(tokens.line)
                    .frame(width: 1, height: 11)
                    .padding(.leading, 6)
                    .accessibilityHidden(true)
            }
        }
        .opacity(item == nil ? 0 : 1)
        .animation(.easeInOut(duration: 0.18), value: item?.id)
        .accessibilityHidden(item == nil)
        .layoutPriority(-1)
    }
}
