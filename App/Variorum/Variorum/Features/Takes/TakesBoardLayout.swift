//
//  TakesBoardLayout.swift
//  Variorum
//
//  13b Stage 3, N10 — the TakesViewModel P-9 decomposition, seam 1 of 2
//  (the plan's "board layout/paging" candidate, proposed from the code):
//  the board's SESSION-ONLY view-geometry state — fan expansion, discrete
//  paging, follow-the-scroll row visibility, and the density inputs —
//  moved out of the conductor into one named, self-contained component.
//  Nothing here touches the store, the projection, or the authority: it
//  is exactly the state a board renders its geometry from, and it dies
//  with the session (the plan's letter: fans stay open once expanded,
//  close-all resets, nothing persists).
//
//  The view model forwards every existing property/method name, so every
//  view and pin call site reads unchanged (behavior parity is the batch
//  contract). Observation granularity is preserved: each piece of state
//  stays its OWN stored property on this @Observable class, so a view
//  reading only `pageOffsets` still doesn't re-render on an expansion
//  change (merging them into one struct property would have coarsened
//  invalidation).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class TakesBoardLayout {
    // MARK: - Follow-the-scroll (Phase 13 C2, R25)

    /// R25 — follow-the-scroll as a takes-viewing OPTION in all modes.
    /// Pushed by the View from the theme settings (models never read
    /// environments — the EditorView appearance pattern).
    var followTheScroll = false

    /// Near-viewport row bookkeeping: per-block REF COUNTS, because the
    /// multi-column compositions repeat a block's row — a disappear in one
    /// column must not blind the others. Observed (not ignored) so blooms
    /// re-render as rows come and go; when `followTheScroll` is off,
    /// `isBloomed` short-circuits before reading it, so Observation never
    /// tracks the churn (the calm default costs nothing).
    private var rowVisibility: [String: Int] = [:]

    func rowAppeared(_ blockID: String) {
        rowVisibility[blockID, default: 0] += 1
    }

    func rowDisappeared(_ blockID: String) {
        let next = (rowVisibility[blockID] ?? 0) - 1
        if next <= 0 {
            rowVisibility.removeValue(forKey: blockID)
        } else {
            rowVisibility[blockID] = next
        }
    }

    /// Whether a block's row is currently near the viewport (the
    /// conductor's `visibleFannedBlocks` derives from this against the
    /// projection, so a fan born mid-visibility is picked up without a
    /// re-appear).
    func isRowVisible(_ blockID: String) -> Bool {
        (rowVisibility[blockID] ?? 0) > 0
    }

    /// THE bloom rule (R25): explicitly expanded, OR — with follow-the-
    /// scroll on — any fanned row near the viewport.
    func isBloomed(_ slot: Queries.RenderedBlock) -> Bool {
        expandedBlocks.contains(slot.blockID)
            || (followTheScroll && slot.hasFan
                && (rowVisibility[slot.blockID] ?? 0) > 0)
    }

    /// R24's short/long rule for the margin grid: a SHORT fanned block gets
    /// the one-card-high horizontally-scrolling strip; longer blocks keep
    /// the vertical card column. The threshold is a character count (~200
    /// chars ≈ under three lines at the 68ch measure) — a BUILD-TIME CALL,
    /// recorded in the Stage C closeout + QUESTIONS #28.
    nonisolated static func usesHorizontalStrip(text: String?) -> Bool {
        (text ?? "").count < 200
    }

    // MARK: - Expansion (session-only)

    /// Fanned blocks currently bloomed — SESSION-ONLY by the plan's letter
    /// (fans stay open once expanded; close-all resets; nothing persists).
    private(set) var expandedBlocks: Set<String> = []

    /// The one insert door (reveals, landings, and the toggle share it).
    func bloom(_ blockID: String) {
        expandedBlocks.insert(blockID)
    }

    func toggleExpanded(_ blockID: String) {
        if expandedBlocks.contains(blockID) {
            expandedBlocks.remove(blockID)
        } else {
            expandedBlocks.insert(blockID)
        }
    }

    /// Expand-all-fans (AppSpec §12): every FANNED block blooms, in the set
    /// style; fans stay open once expanded; close-all resets. The conductor
    /// passes the projection's fanned set (this component never reads the
    /// projection).
    func expandAll(fannedBlockIDs: Set<String>) {
        expandedBlocks = fannedBlockIDs
    }

    func closeAllFans() {
        expandedBlocks = []
    }

    // MARK: - Discrete paging (session-only; model-owned)

    /// Per-key page offsets for the card rows (carousel, slot split, and —
    /// AD-2's fix — the margin rail): whole cards/columns, never halfway,
    /// an EXPLICIT ◀ ▶ door instead of an invisible horizontal scroll.
    /// Model-owned (13b 1a) so the AD-2 pin and the board soak can drive
    /// page coverage; session-only like expansion.
    private(set) var pageOffsets: [String: Int] = [:]

    /// The clamped current offset for a key (limit = last legal offset).
    func pageOffset(_ key: String, limit: Int) -> Int {
        min(max(pageOffsets[key] ?? 0, 0), max(limit, 0))
    }

    func stepPage(_ key: String, by delta: Int, limit: Int) {
        pageOffsets[key] = min(max(pageOffset(key, limit: limit) + delta, 0), max(limit, 0))
    }

    // MARK: - Density inputs + the rail's chunking (13b 1b — AD-2's
    // keyboard companion shares one brain with the board's rendering)

    /// Density inputs, pushed by the board (models never read @AppStorage).
    var beneathCount = 2
    var gridRows = 2
    var gridCols = 1

    /// R24's strip exception, one brain with the board's chunking.
    func railRowsPerColumn(slotText: String?) -> Int {
        (Self.usesHorizontalStrip(text: slotText) && gridRows == 1) ? 1 : gridRows
    }

    nonisolated static func railPageKey(_ blockID: String) -> String { "rail-\(blockID)" }
}
