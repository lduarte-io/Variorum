//
//  SpanToTakeGesture.swift
//  Variorum (Mac)
//
//  **SELECTION → A TAKE ON THE SAME BLOCK** — the Write door's pure half
//  (13u4 UNIT C2; her item 9, ruled as R-13u4-4).
//
//  ONE BRAIN, two readers, the Phase 9 gesture contract's own discipline:
//  the door's RENDERING (P-2 — a door that can never act in its context is
//  not rendered) and the ACT itself both ask `plan`, so "is this selection
//  this gesture's" is answered once. Pure over a `BlockRangeIndex` snapshot —
//  no AppKit, no store — so every edge below is directly testable.
//
//  **Why this is not a `StructuralGesturePlanner.Command`.** That planner is
//  the ratified contract for the acts that change BLOCK STRUCTURE (divide,
//  extract, make block, merge) and every one of its verdicts ends in a block
//  boundary moving. This act moves no boundary at all: one block's text
//  shrinks and that block's fan grows by one. Growing the structural planner
//  to carry it would put a non-structural verdict inside the enum every
//  structural switch is exhaustive over — and would oblige the Takes board's
//  structural group to render a door this unit does not build
//  (`CapabilityRegistryTests.theBoardsStructuralGroupRendersEveryStructuralAct`
//  asserts exactly that, by construction, over `StructuralAct.allCases`).
//

import Foundation
import VariorumCore

nonisolated enum SpanToTakeGesture {
    /// What the act needs, in the surface's own coordinates.
    struct Plan: Equatable {
        let entryIndex: Int
        let blockID: String
        /// The take the span is leaving — the entry's rendered variant.
        let variantID: String
        /// The block-side span, in INTRA-BLOCK UTF-16 offsets.
        let intraRange: NSRange
    }

    /// The gesture's geometry, and ONLY its geometry: a non-empty selection
    /// that lies inside exactly ONE block which has a take to move out of.
    ///
    /// Returns nil — and the doors do not render — when:
    /// · nothing is selected (the caret alone is not this gesture);
    /// · the selection touches TWO OR MORE blocks (*"the door does not render
    ///   there"* — the standing cross-block roads own that population);
    /// · it touches the OPEN TAIL, which is not a block yet;
    /// · the block is a GAP SLOT with no take to move a span out of.
    ///
    /// What it deliberately does NOT decide: the SEAL and the LOCK. Those are
    /// the operation's refusals, spoken in the operation's own words when the
    /// door fires (P-2's other half) — and both are states she can resolve,
    /// where the four above are states in which the act has no meaning.
    ///
    /// **A swallowed separator is shrugged off, not refused.** The separator
    /// between two blocks belongs to no block (the `EditorDocument`
    /// doctrine), so a shift-selection that grazes one still names exactly
    /// one block's text, and the intersection IS that text. This is the same
    /// tolerance `StructuralGesturePlanner.shrinkSeparatorOverhang` gives
    /// every span gesture, arrived at by intersection rather than by a second
    /// copy of the walk.
    ///
    /// **Cost is the caret's own entry index, never the document** (P1): one
    /// accumulating pass with an early return the moment the running location
    /// reaches the selection's end — no later entry can intersect after that,
    /// so no later entry is visited. It runs on the enablement road, which
    /// `refreshGestureAvailability` drives from every caret move and every
    /// keystroke.
    static func plan(selection: NSRange, index: BlockRangeIndex) -> Plan? {
        guard selection.length > 0, selection.location >= 0,
              selection.upperBound <= index.documentLength
        else { return nil }
        // The open tail is not a block; a span cannot leave a take there
        // because there is no take yet (idle-mint makes one within seconds).
        if let tail = index.tailRange, NSIntersectionRange(selection, tail).length > 0 {
            return nil
        }
        var location = 0
        var found: (entryIndex: Int, start: Int, overlap: NSRange)?
        for (i, entry) in index.entries.enumerated() {
            let entryRange = NSRange(location: location, length: entry.length)
            let overlap = NSIntersectionRange(selection, entryRange)
            if overlap.length > 0 {
                if found != nil { return nil }  // it crosses blocks — not this gesture
                found = (i, location, overlap)
            }
            location += entry.length + 1
            if location >= selection.upperBound { break }
        }
        guard let found, let variantID = index.entries[found.entryIndex].variantID
        else { return nil }
        return Plan(
            entryIndex: found.entryIndex,
            blockID: index.entries[found.entryIndex].blockID,
            variantID: variantID,
            intraRange: NSRange(
                location: found.overlap.location - found.start,
                length: found.overlap.length))
    }
}

/// Everything this act says — in ONE home, because two doors speak it (the
/// selection context menu and the bar's `block ▾` row) and a sentence
/// written twice is how copy drifts (`SplitAtNewlinesCopy`'s own reason).
///
/// **18i's kinds, decided at the door that produces each line:** the
/// receipts report an act that LANDED; the refusals come from a door that
/// did NOTHING. The verb itself is the registry's, never duplicated here.
nonisolated enum SpanToTakeCopy {
    static let help =
        "Move the selected words out of the take you're in and into a new take "
        + "on this block — the take they leave is saved first, so nothing is lost."

    /// A door fired with the selection gone (menus are built when they open;
    /// the selection can change under an open one).
    static let nothingSelected =
        "Select the words you want to move into a take first."

    /// …and fired across a seam. It names the road that owns that shape
    /// rather than only refusing (P-2).
    static let crossBlockSpan =
        "That selection crosses a block boundary — this moves part of ONE block "
        + "into a take on it. Make Block from Selection (⌘⇧K) is the gesture for "
        + "a span across blocks."

    /// **The receipt, built from the operation's OWN result** (the 13e
    /// receipt rule, and the J8 copy-truth doctrine): the savepoint clause
    /// appears only when a savepoint was actually written. When the take's
    /// buffer already matched its last savepoint nothing was written — and
    /// the sentence does not claim it was, because that savepoint already
    /// holds the pre-move text and saying "saved first" for a write that did
    /// not happen is exactly the drift this rule exists to stop.
    static func receipt(savedFirst: Bool) -> String {
        savedFirst
            ? "Moved into a new take — the take it left was saved first. \u{2325}\u{2318}Z undoes it."
            : "Moved into a new take — \u{2325}\u{2318}Z undoes it."
    }
}
