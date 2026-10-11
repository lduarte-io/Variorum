//
//  SavepointHistory.swift
//  Variorum (Mac)
//
//  Phase 13j, J11 — **the quiet-run collapse, where both history faces meet.**
//
//  Her round-1 ruling gave the app a savepoint cadence AND asked for history
//  that still reads: *"history reads as one row per sitting"*. The grouping
//  itself is pure and lives in core (`SavepointRuns`, shared with the phone,
//  which owes only faces). What lives HERE is the two things the faces share
//  above it: the per-row RENDER DECISION — collapsed line, or line plus its
//  savepoints — and the collapsed line itself.
//
//  Both are here rather than in either face for the `BlockPastSection`
//  reason, one region down the same panel: Write's inline history and the
//  Takes bar's history sheet are two renderings of one past, and two copies
//  of one rule drift. Write's list is newest-first, the sheet's is
//  oldest-first, and neither difference reaches this file.
//

import SwiftUI
import VariorumCore

// (`SavepointHistoryFace` moved to `Shared/BlockHistoryFace.swift` at
//  mobile round 2 batch 6a: it was already the rule two Mac faces
//  shared, and the phone's Block History is the third. `QuietRunRow`
//  below is a Mac SwiftUI view and stayed.)

/// The collapsed line, shared by BOTH faces so they cannot tell different
/// stories about one run.
struct QuietRunRow: View {
    let count: Int
    let expanded: Bool
    let tokens: VoiceTokens
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // VX-144 (the quiet ledger, precision 6): the voice's own small
            // type and muted ink — it drew in the system caption + secondary,
            // a sans-serif line between mono rows in the Terminal voice.
            Text(tokens.chromeLabel(SavepointRuns.runLabel(count: count)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            // `VoicedButtonStyle`, not `.buttonStyle(.link)` — P-8's chrome
            // vocabulary rule (`Theme/VoiceControls.swift` is THE vocabulary),
            // and the capture made the cost of the shortcut visible: the link
            // style is AppKit-backed and `ImageRenderer` drew its
            // unsupported-view placeholder where the verb belongs, so the one
            // piece of this batch's chrome that CAN be inspected offscreen
            // could not have been.
            Button(tokens.chromeLabel(
                expanded ? SavepointRuns.hideVerb : SavepointRuns.showVerb), action: onToggle)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            Spacer()
        }
        .help(SavepointRuns.runHelp)
    }
}
