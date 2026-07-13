//
//  StructuralGesturePlanner.swift
//  Variorum
//
//  Phase 9 Step 1 — the ONE brain behind every structural gesture door.
//  Menu-bar enablement, context-menu enablement, shortcut invocation, and
//  the gesture itself all call the same `plan(_:selection:world:)`; there is
//  no second opinion anywhere (the ratified contract: enablement = the
//  planner's verdict). Pure functions over a BlockRangeIndex snapshot +
//  per-entry context — no AppKit, no store, exhaustively testable.
//
//  Discipline (plan ground rule): raw AppKit selections are never trusted at
//  fragment boundaries (TEXTKIT2_NOTES §3) — everything normalizes through
//  the index's tiling here first, and the offsets handed onward are
//  BoundarySnapping-snapped, so the operations layer (which checks
//  well-formedness only — Phase 3 ratification) always receives legal cuts.
//
//  The pure layer never asserts (the Phase 7 MINOR-7 lesson): impossible
//  states answer with a refusal, and the caller recovers.
//

import Foundation
import VariorumCore

nonisolated enum StructuralGesturePlanner {
    /// The author-ratified command set (2026-07-06 gesture contract): two
    /// named split commands — never a smart unified "Split" — plus the
    /// composed middle-span gesture and the explicit binary merge.
    enum Command: Equatable, Sendable, CaseIterable {
        case divideAtCursor
        case extractSelection
        case makeBlockFromSelection
        case mergeBlocks
    }

    /// Everything the planner may consult, snapshotted at plan time.
    /// `textAt` is lazy so enablement (recomputed per selection change)
    /// costs one block's text, never the document (P1).
    struct World {
        let index: BlockRangeIndex
        /// Per-entry live active-variant counts, aligned with
        /// `index.entries`. May briefly run SHORTER than the entries during
        /// a crystallization window (the index learns of a mint before the
        /// projection echoes back) — missing entries read as arity 1, which
        /// is exactly what a fresh mint is.
        let fanArities: [Int]
        /// The post-level seal (refuses everything under the post).
        let sealed: Bool
        /// The live surface text of entry i (the buffer is authoritative
        /// while dirty — gestures plan against what the author sees).
        let textAt: (Int) -> String
    }

    /// Closed refusal vocabulary — every case gets human copy in
    /// `RefusalCopy` (a new case without copy fails the build there).
    enum Refusal: Equatable, Sendable, CaseIterable {
        /// The post is sealed: nothing under it changes (AppSpec §9).
        case sealed
        /// The slot's block/variant hasn't arrived (SyncSpec §5): no local
        /// text to restructure.
        case gapSlot
        /// The rendered take is locked and this gesture would edit its
        /// buffer — branch or unlock (W and merge COPY, so they don't care).
        case lockedVariant
        /// The open tail is not a block yet; idle-mint makes it one within
        /// seconds — structural gestures wait for that.
        case openTailTarget
        /// The span crosses a block boundary — v1's ratified refusal
        /// (KnownIssues re-bracketing line); the copy names the workaround.
        case crossBlockSpan
        /// The span is the whole block — it already is a block.
        case wholeBlockSpan
        /// Extract on a middle span: that gesture is Make Block from
        /// Selection (or a divide) — extract needs a boundary-adjacent span.
        case middleSpanNeedsMakeBlock
        /// Make Block on a fanned block: the other takes have no cut marks —
        /// that decision is the W ceremony's.
        case fannedMiddleSpan
        /// A cross-block gesture touching a FANNED block: deliberately OPEN
        /// design (QUESTIONS #10/#11 — the author settles it live at the
        /// checkpoint; her uncertainty is recorded, never guessed at). The
        /// copy names the open question and today's doors.
        case fannedCrossBlockSpan
        /// Merge needs a caret at a block seam or a selection spanning
        /// two or more blocks.
        case notASeam
        /// Nothing for this gesture here: no selection where one is needed,
        /// no legal interior cut, a blank span, a snap that collapsed.
        case nothingToDo
        /// The selection lies outside the document the index describes —
        /// desync-class; the caller re-renders from the store, never crashes.
        case invalidSelection
    }

    enum Plan: Equatable {
        /// Single-variant divide at a snapped interior cut (intra-block
        /// UTF-16, valid against the entry's current text).
        case divide(entryIndex: Int, blockID: String, snappedCut: Int)
        /// Divide invoked on a fanned block: route to the W ceremony sheet,
        /// with the active (rendered) variant's snapped cut as the seed.
        case divideW(entryIndex: Int, blockID: String, activeCut: Int)
        /// Boundary-adjacent span: extract. `otherTakes` > 0 drives the
        /// passive fanned-extract hint (contract item 8).
        case extract(entryIndex: Int, blockID: String, snappedSpan: Range<Int>,
                     edge: BoundarySnapping.ExtractableSpan, otherTakes: Int)
        /// Middle span on a single-variant block: the composed two-divide
        /// gesture (contract item 5).
        case makeBlock(entryIndex: Int, blockID: String, snappedSpan: Range<Int>)
        /// Exactly two adjacent blocks, leading then trailing.
        case merge(leadingIndex: Int, trailingIndex: Int,
                   leadingBlockID: String, trailingBlockID: String)
        /// Three or more blocks (author 2026-07-09, superseding the binary
        /// rule): the contiguous run the selection touches — INCLUDING empty
        /// blocks it spans (no characters to select, but the author selected
        /// across them) — merges as a left-to-right chain of binary merges
        /// under one undo entry. Caret-at-seam stays the binary gesture.
        case mergeChain(entryIndices: ClosedRange<Int>, blockIDs: [String])
        /// Phase 11, A9 (the boundary-fluidity package — COMMITTED scope):
        /// Make Block across block boundaries, single-variant×single-variant
        /// only (fanned → `.fannedCrossBlockSpan`, the OPEN #10/#11
        /// territory). The v1 refusal becomes a CONFIRM → adjust the
        /// neighbor edges (divide first/last at the snapped cuts) → merge
        /// the in-span pieces, ONE undo compound. `startCut`/`endCut` are
        /// intra-block UTF-16 in the first/last touched entries (0 = the
        /// whole first block rides; endCut == last length = the whole last
        /// block rides; a snapped-off edge drops that block from the span).
        case makeBlockAcrossBlocks(
            entryIndices: ClosedRange<Int>, blockIDs: [String],
            startCut: Int, endCut: Int)
        case refusal(Refusal)
    }

    // MARK: - The one entry point (all doors call this)

    static func plan(_ command: Command, selection: NSRange, world: World) -> Plan {
        guard selection.location >= 0, selection.length >= 0,
              selection.upperBound <= world.index.documentLength
        else { return .refusal(.invalidSelection) }
        // The seal outranks every other answer: the menu reads "disabled"
        // for the same reason the op would refuse.
        guard !world.sealed else { return .refusal(.sealed) }
        // The open tail is not a block (idle-mint will make it one) — any
        // gesture touching the tail region refuses before shape questions.
        if touchesTailRegion(selection, index: world.index) {
            return .refusal(.openTailTarget)
        }
        switch command {
        case .divideAtCursor:
            return divide(atCaret: selection.location, world: world)
        case .extractSelection:
            return span(selection, world: world, composed: false)
        case .makeBlockFromSelection:
            return span(selection, world: world, composed: true)
        case .mergeBlocks:
            return merge(selection, world: world)
        }
    }

    // MARK: - Divide (contract items 1–3)

    /// A non-empty selection divides at its start — the caret-position
    /// reading of "at Cursor" (the visible snap collapses the selection to
    /// the snapped cut as part of the action).
    private static func divide(atCaret caret: Int, world: World) -> Plan {
        guard let (i, intra) = entryTouching(caret: caret, index: world.index) else {
            return .refusal(.nothingToDo)
        }
        let entry = world.index.entries[i]
        guard entry.variantID != nil else { return .refusal(.gapSlot) }
        let text = world.textAt(i)
        guard let cut = snapToInteriorBoundary(intra, in: text) else {
            return .refusal(.nothingToDo)
        }
        if fanArity(world, i) > 1 {
            // The W door: marked variants are COPIED through, so a locked
            // rendered take does not refuse here (Phase 3 op semantics).
            return .divideW(entryIndex: i, blockID: entry.blockID, activeCut: cut)
        }
        guard entry.editable else { return .refusal(.lockedVariant) }
        return .divide(entryIndex: i, blockID: entry.blockID, snappedCut: cut)
    }

    /// Divide's legal cuts are INTERIOR boundaries only — 0 and the end are
    /// boundaries but not cuts (the op refuses empty halves), so the nearest
    /// LEGAL boundary is the nearest interior one. The legal set is
    /// sentence ∪ paragraph marks (contract item 2 names both;
    /// `.sentence` granularity is exactly that superset). Internal:
    /// CutPropagation snaps its W-ceremony proposals through this same
    /// function (one implementation of "legal cut").
    static func snapToInteriorBoundary(_ cut: Int, in text: String) -> Int? {
        let end = text.utf16.count
        let interior = BoundarySnapping.boundaries(in: text, granularity: .sentence)
            .filter { $0 != 0 && $0 != end }
        let clamped = min(max(cut, 0), end)
        return interior.min { a, b in
            let (da, db) = (abs(a - clamped), abs(b - clamped))
            return da == db ? a < b : da < db
        }
    }

    // MARK: - Spans: extract & the composed middle-span gesture (items 1–2, 5–6, 8)

    private static func span(_ selection: NSRange, world: World, composed: Bool) -> Plan {
        guard selection.length > 0 else { return .refusal(.nothingToDo) }
        // Never trust a raw AppKit selection at a boundary: shrink endpoint
        // overhang off separator characters first (a shift-End or
        // double-click selection routinely swallows the neighboring
        // separator — the intent is the block-side span).
        let normalized = shrinkSeparatorOverhang(selection, index: world.index)
        guard normalized.length > 0 else { return .refusal(.nothingToDo) }

        let touched = entriesIntersecting(normalized, index: world.index)
        if touched.count > 1 {
            // Phase 11, A9: the composed gesture crosses boundaries through
            // the GUIDED flow (author-committed scope); extract keeps the
            // v1 refusal (its op is single-source by definition).
            guard composed else { return .refusal(.crossBlockSpan) }
            return crossBlockMakeBlock(normalized, touched: touched, world: world)
        }
        guard let i = touched.first else { return .refusal(.nothingToDo) }
        let entry = world.index.entries[i]
        guard entry.variantID != nil else { return .refusal(.gapSlot) }

        let text = world.textAt(i)
        let entryRange = world.index.range(ofEntryAt: i)
        let intraStart = max(0, normalized.location - entryRange.location)
        let intraEnd = min(entryRange.length, normalized.upperBound - entryRange.location)
        let snapped = snapSpan(intraStart..<intraEnd, in: text)
        guard snapped.lowerBound < snapped.upperBound,
              let indices = BoundarySnapping.graphemeRange(snapped, in: text)
        else { return .refusal(.nothingToDo) }

        // Classify against the whole text, mirroring the op's own
        // extractable-span logic (whitespace-tolerant at the outer edges).
        guard text[indices].contains(where: { !$0.isWhitespace }) else {
            return .refusal(.nothingToDo)
        }
        let headBlank = text[..<indices.lowerBound].allSatisfy(\.isWhitespace)
        let tailBlank = text[indices.upperBound...].allSatisfy(\.isWhitespace)
        switch (headBlank, tailBlank) {
        case (true, true):
            return .refusal(.wholeBlockSpan)
        case (true, false), (false, true):
            // Boundary-adjacent: this is an extract — for BOTH commands
            // (Make Block degrades here deliberately: one op beats two).
            guard entry.editable else { return .refusal(.lockedVariant) }
            return .extract(
                entryIndex: i, blockID: entry.blockID, snappedSpan: snapped,
                edge: headBlank ? .prefix : .suffix,
                otherTakes: fanArity(world, i) - 1)
        case (false, false):
            // A true middle span: the composed gesture's territory.
            guard composed else { return .refusal(.middleSpanNeedsMakeBlock) }
            guard fanArity(world, i) == 1 else { return .refusal(.fannedMiddleSpan) }
            guard entry.editable else { return .refusal(.lockedVariant) }
            return .makeBlock(entryIndex: i, blockID: entry.blockID, snappedSpan: snapped)
        }
    }

    /// Phase 11, A9 — the guided cross-block Make Block's plan (the
    /// boundary-fluidity package; single×single ratified 2026-07-09). The
    /// classification is deliberate: gaps first (nothing local to cut),
    /// then FANNED blocks (the OPEN #10/#11 question — refuse and SPEAK,
    /// never guess), then the edge blocks' editability (only they get
    /// divided; middles are merge-COPIED, so their locks don't refuse —
    /// the merge doctrine).
    private static func crossBlockMakeBlock(
        _ selection: NSRange, touched: [Int], world: World
    ) -> Plan {
        let entries = world.index.entries
        for i in touched {
            guard entries[i].variantID != nil else { return .refusal(.gapSlot) }
        }
        if touched.contains(where: { fanArity(world, $0) > 1 }) {
            return .refusal(.fannedCrossBlockSpan)
        }
        guard let first = touched.first, let last = touched.last else {
            return .refusal(.nothingToDo)
        }
        let firstText = world.textAt(first)
        let lastText = world.textAt(last)
        let firstRange = world.index.range(ofEntryAt: first)
        let lastRange = world.index.range(ofEntryAt: last)
        let startCut = BoundarySnapping.snap(
            max(0, selection.location - firstRange.location),
            in: firstText, granularity: .sentence)
        let endCut = BoundarySnapping.snap(
            min(lastRange.length, selection.upperBound - lastRange.location),
            in: lastText, granularity: .sentence)
        // The pieces that actually ride the span (a snapped-off edge drops
        // its block): fewer than two pieces means the "cross-block" span
        // collapsed to nothing worth a compound.
        var pieceCount = touched.count - 2
        if startCut < firstRange.length { pieceCount += 1 }
        if endCut > 0 { pieceCount += 1 }
        guard pieceCount >= 2 else { return .refusal(.nothingToDo) }
        // Only the DIVIDED edges edit a buffer; a locked edge refuses.
        if startCut > 0, startCut < firstRange.length, !entries[first].editable {
            return .refusal(.lockedVariant)
        }
        if endCut > 0, endCut < lastRange.length, !entries[last].editable {
            return .refusal(.lockedVariant)
        }
        return .makeBlockAcrossBlocks(
            entryIndices: first...last,
            blockIDs: touched.map { entries[$0].blockID },
            startCut: startCut, endCut: endCut)
    }

    /// Both span ends snap to the nearest legal boundary (full set — 0 and
    /// the end are legal span edges, unlike divide cuts).
    private static func snapSpan(_ span: Range<Int>, in text: String) -> Range<Int> {
        let lower = BoundarySnapping.snap(span.lowerBound, in: text, granularity: .sentence)
        let upper = BoundarySnapping.snap(span.upperBound, in: text, granularity: .sentence)
        return min(lower, upper)..<max(lower, upper)
    }

    // MARK: - Merge (contract item 4)

    private static func merge(_ selection: NSRange, world: World) -> Plan {
        let entries = world.index.entries
        let pair: (Int, Int)
        if selection.length == 0 {
            guard let seam = seamPair(atCaret: selection.location, index: world.index) else {
                return .refusal(.notASeam)
            }
            pair = seam
        } else {
            // Selected CHARACTERS decide which blocks the author means —
            // zero-width endpoint grazes and swallowed edge separators do
            // not (a shift-selection routinely ends exactly at a third
            // block's start having selected nothing of it — gate-review
            // observation, pinned). The one exception: a selection of
            // exactly one separator character is the pure-seam gesture and
            // names that separator's pair.
            let normalized = shrinkSeparatorOverhang(selection, index: world.index)
            if normalized.length == 0 {
                guard let seam = separatorPair(coveredBy: selection, index: world.index) else {
                    return .refusal(.notASeam)
                }
                pair = seam
            } else {
                let touched = entriesIntersecting(normalized, index: world.index)
                guard let first = touched.first, let last = touched.last,
                      first < last
                else { return .refusal(.notASeam) }
                if touched.count == 2, last == first + 1 {
                    pair = (first, last)
                } else {
                    // N-way (author 2026-07-09): the contiguous closure
                    // [first...last] — empty blocks the selection spans have
                    // no characters to intersect but join the chain.
                    for k in first...last {
                        guard entries[k].variantID != nil else {
                            return .refusal(.gapSlot)
                        }
                    }
                    return .mergeChain(
                        entryIndices: first...last,
                        blockIDs: (first...last).map { entries[$0].blockID })
                }
            }
        }
        for k in [pair.0, pair.1] {
            guard entries[k].variantID != nil else { return .refusal(.gapSlot) }
        }
        // Locked takes do NOT refuse: merge copies the rendered texts, it
        // never edits a buffer (Phase 3 op semantics).
        return .merge(
            leadingIndex: pair.0, trailingIndex: pair.1,
            leadingBlockID: entries[pair.0].blockID,
            trailingBlockID: entries[pair.1].blockID)
    }

    /// The pair named by a selection covering exactly ONE separator
    /// character (the pure-seam merge gesture).
    private static func separatorPair(
        coveredBy selection: NSRange, index: BlockRangeIndex
    ) -> (Int, Int)? {
        guard selection.length == 1 else { return nil }
        for i in 0..<max(0, index.entries.count - 1) {
            if selection.location == index.range(ofEntryAt: i).upperBound {
                return (i, i + 1)
            }
        }
        return nil
    }

    /// A caret sits at the seam between entries i and i+1 when it is at the
    /// separator's either side: the leading block's exact end, or the
    /// trailing block's exact start.
    private static func seamPair(atCaret caret: Int, index: BlockRangeIndex) -> (Int, Int)? {
        for i in 0..<max(0, index.entries.count - 1) {
            let separator = index.range(ofEntryAt: i).upperBound
            if caret == separator || caret == separator + 1 {
                return (i, i + 1)
            }
        }
        return nil
    }

    // MARK: - Tiling geometry (all consultation of the index lives here)

    /// True when the selection touches the open-tail TEXT. A caret at the
    /// last block's exact end is block-side; so is a non-empty selection
    /// whose only overshoot is the tail SEPARATOR itself (review round 1,
    /// NIT 7: a shift-selection swallowing the one dangling separator means
    /// the block suffix — the same overhang tolerance interior seams get;
    /// only selected tail text makes a selection tail-side).
    private static func touchesTailRegion(_ selection: NSRange, index: BlockRangeIndex) -> Bool {
        guard let tail = index.tailRange else { return false }
        guard !index.entries.isEmpty else { return true }  // a fresh post is all tail
        guard let separator = index.tailSeparatorOffset else { return true }
        if selection.length == 0 {
            return selection.location >= tail.location
        }
        return selection.upperBound > separator + 1
    }

    /// The entry whose closed range [start, end] contains the caret, with
    /// the intra-entry offset. A caret on a separator's trailing side maps
    /// to the following entry's start.
    private static func entryTouching(caret: Int, index: BlockRangeIndex) -> (Int, Int)? {
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            if caret >= location, caret <= location + entry.length {
                return (i, caret - location)
            }
            location += entry.length + 1
        }
        return nil
    }

    /// Entries with at least one CHARACTER of the range inside them
    /// (strict intersection — endpoint touches don't count). Span logic.
    private static func entriesIntersecting(_ range: NSRange, index: BlockRangeIndex) -> [Int] {
        var result: [Int] = []
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            let overlapStart = max(range.location, location)
            let overlapEnd = min(range.upperBound, location + entry.length)
            if overlapStart < overlapEnd { result.append(i) }
            location += entry.length + 1
        }
        return result
    }

    /// Shrinks a span's endpoints inward off separator characters (the
    /// separator belongs to no block — EditorDocument doctrine — so a span
    /// that swallowed one meant the block text beside it).
    private static func shrinkSeparatorOverhang(_ range: NSRange, index: BlockRangeIndex) -> NSRange {
        var separators: Set<Int> = []
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            location += entry.length
            if i < index.entries.count - 1 { separators.insert(location) }
            location += 1
        }
        var start = range.location
        var end = range.upperBound
        while start < end, separators.contains(start) { start += 1 }
        while end > start, separators.contains(end - 1) { end -= 1 }
        return NSRange(location: start, length: end - start)
    }

    private static func fanArity(_ world: World, _ i: Int) -> Int {
        guard i >= 0, i < world.fanArities.count else { return 1 }
        return max(1, world.fanArities[i])
    }
}
