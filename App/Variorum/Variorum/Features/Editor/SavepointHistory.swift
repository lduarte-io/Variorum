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

/// What a history face renders for ONE grouped row.
nonisolated enum SavepointHistoryFace {
    struct Rendered<Item> {
        /// The collapsed line's count, where this row is a run — nil for a
        /// lone savepoint, which renders as itself.
        var runCount: Int?
        /// Whether that line currently offers "hide" rather than "show".
        var expanded: Bool
        /// The savepoint rows to draw under it. A collapsed run draws none:
        /// that is what collapsing IS, and stating it here rather than in a
        /// view's `if` is what lets a test assert it.
        var items: [Item]
    }

    static func rendered<Item>(
        _ row: SavepointRuns.Row<Item>, expanded: Set<String>
    ) -> Rendered<Item> {
        guard let count = row.runCount else {
            return Rendered(runCount: nil, expanded: false, items: row.items)
        }
        let open = expanded.contains(row.id)
        return Rendered(runCount: count, expanded: open, items: open ? row.items : [])
    }

    /// The toggle both faces run — one rule for what a click on a run does.
    static func toggling(_ id: String, in expanded: Set<String>) -> Set<String> {
        var next = expanded
        if next.contains(id) { next.remove(id) } else { next.insert(id) }
        return next
    }
}

/// The collapsed line, shared by BOTH faces so they cannot tell different
/// stories about one run.
struct QuietRunRow: View {
    let count: Int
    let expanded: Bool
    let tokens: VoiceTokens
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(tokens.chromeLabel(SavepointRuns.runLabel(count: count)))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Button(expanded ? SavepointRuns.hideVerb : SavepointRuns.showVerb, action: onToggle)
                .controlSize(.small)
                .buttonStyle(.link)
            Spacer()
        }
        .help(SavepointRuns.runHelp)
    }
}
