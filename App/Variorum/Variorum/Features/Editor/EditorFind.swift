//
//  EditorFind.swift
//  Variorum
//
//  IN-POST FIND & REPLACE (QoL round 2026-07-29, batch 3 — her **L6**:
//  *"i also realized that we need to ship some kind of text find and replace
//  … at least of the chosen text, because i noticed myself reaching for that
//  and not having it"*). Her ruling scoped v1 to the post you are in, acting
//  on the chosen (rendered) takes as ordinary edits; the takes-aware replace
//  and whole-library body search are recorded future scope (owner 13e).
//
//  ── WHY THIS FILE EXISTS AT ALL, i.e. why find & replace is not just
//     `usesFindBar = true` ────────────────────────────────────────────────
//
//  Two measured facts (the batch's step-1 measurements, on macOS 26.5.2):
//
//  **M1b — AppKit applies Replace All as ONE COALESCED STORAGE
//  TRANSACTION.** Three matches across three blocks produced exactly one
//  `didProcessEditing` with `editedRange = {4, 48}` and `changeInLength = 0`
//  — a single edited range spanning both block seams. Our pipeline routes a
//  storage edit by asking the index which BLOCK owns the edited range
//  (`fallbackVerdict`), so a multi-block range resolves to
//  `.refuse(.crossesBlockBoundary)` and lands in `desyncRecovery()`. The
//  first cut of that measurement wired the real model in and the process
//  died with *"Fatal error: editor surface desynced from the block index"*.
//  So "let the replacements ride the ordinary pipeline one at a time" is not
//  something AppKit will do for us — there are no per-range storage edits to
//  ride.
//
//  **M1 — the gate is BATCHED.** Replace All asks ONE question about ALL its
//  ranges (`shouldChangeTextInRanges:` with three ranges, zero single-range
//  calls). A single boolean cannot apply some and refuse others, which is
//  why the ruled shape for a partly-blocked Replace All is ALL-OR-NOTHING:
//  partial application is not merely undesirable here, it is unreachable.
//
//  So this file does the only honest thing: it answers the finder's own
//  client question with NO — nothing AppKit applies — and then re-drives the
//  author's intent through the editor's ORDINARY input path,
//  `insertText(_:replacementRange:)`, once per match, LAST MATCH FIRST so
//  the earlier offsets stay valid (the reason the SDK header gives for its
//  own reverse ordering). Each of those is indistinguishable from typing:
//  the delegate is consulted, the verdict routes, `BlockRangeIndex` updates,
//  autosave and churn record, NSTextView registers undo. Nothing is written
//  to the store by this file, and no operation is added to `Operations/` —
//  her L6 ruling's letter.
//
//  ── THE SAFETY CORE ──────────────────────────────────────────────────────
//
//  A match that spans an inter-block separator must NOT be replaced. On the
//  shipped editor a cross-block edit with a replacement does not refuse: it
//  routes to `planCrossBlockEdit`, which MERGES the blocks and then applies
//  the edit to the merged buffer (the ratified 2026-07-09 merge-then-edit).
//  That contract was made for a deliberate hand-made selection; nothing ever
//  ratified it for a machine-driven sweep, and a Replace All that silently
//  restructured her post would be the worst kind of surprise. So every range
//  is checked BEFORE anything is applied, and `isFindReplacing` guards the
//  application itself so a race cannot turn a replacement into a merge.
//

import AppKit
import Foundation
import VariorumCore

// MARK: - The gate's pure half

/// What a find-replace gesture may do, decided without touching anything.
/// Pure so the counting refusals are unit-testable without a text view.
nonisolated enum FindReplaceGate {
    /// Why a match cannot be replaced. Named for the reason SHE would give,
    /// not for the verdict case.
    enum Blocker: Equatable, Sendable {
        case crossesBlockBoundary
        case lockedTake
        case unsyncedBlock
    }

    /// The counting refusal (the ruled ALL-OR-NOTHING outcome): nothing is
    /// applied, and the message says how many and why.
    static func refusal(total: Int, blockers: [Blocker]) -> String {
        let blocked = blockers.count
        let matches = total == 1 ? "match" : "matches"
        return "Nothing was replaced — \(blocked) of \(total) \(matches) can't be: "
            + causes(blockers) + "."
    }

    /// The single-match refusal — one match, one honest reason, and the way
    /// out named (⌘⇧M is the merge gesture the boundary case points at).
    static func refusal(single blocker: Blocker) -> String {
        switch blocker {
        case .crossesBlockBoundary:
            "That match crosses a block boundary — replace inside one block, "
                + "or merge the blocks first (⌘⇧M)."
        case .lockedTake:
            "That match is in a locked take — branch it or unlock it to edit."
        case .unsyncedBlock:
            "That match is in a block that hasn't fully synced; it is read-only for now."
        }
    }

    static func replaced(_ count: Int) -> String {
        count == 1 ? "Replaced 1 match." : "Replaced \(count) matches."
    }

    /// "2 cross a block boundary, 1 is in a locked take" — only the causes
    /// that actually occurred, in a stable order.
    private static func causes(_ blockers: [Blocker]) -> String {
        let boundary = blockers.count { $0 == .crossesBlockBoundary }
        let locked = blockers.count { $0 == .lockedTake }
        let unsynced = blockers.count { $0 == .unsyncedBlock }
        var parts: [String] = []
        if boundary > 0 { parts.append("\(boundary) cross\(boundary == 1 ? "es" : "") a block boundary") }
        if locked > 0 { parts.append("\(locked) \(locked == 1 ? "is" : "are") in a locked take") }
        if unsynced > 0 { parts.append("\(unsynced) \(unsynced == 1 ? "is" : "are") in an unsynced block") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - The editor's find doors

@MainActor
extension EditorViewModel {
    /// Runs one find-family action on THIS editor. Returns whether this
    /// editor answered — the inline book/spread/pool editor declines (it owns
    /// no scroll view, so it has no find bar), and the router then speaks the
    /// capability's declared note instead of a per-site copy (P-2).
    @discardableResult
    func performFind(_ action: FindAction) -> Bool {
        guard let textView, scrollView != nil else { return false }
        let item = NSMenuItem()
        item.tag = action.finderAction.rawValue
        textView.performTextFinderAction(item)
        return true
    }

    /// The finder's replace gate — called from `EditorTextView`'s client
    /// method, which has already told AppKit NO. Everything from here is ours.
    func gateFindReplace(ranges: [NSRange], strings: [String]) {
        guard let textView else { return }
        guard header?.locked != true else {
            refuseFeedback("This post is sealed — unlock it to edit.")
            return
        }
        guard !ranges.isEmpty else { return }
        // A flight already in progress, or a structural op landing: the
        // surface is not ours to rewrite (the standing fence).
        guard !structuralInFlight else {
            refuseFeedback("Another structural change is still landing.")
            return
        }

        var blockers: [FindReplaceGate.Blocker] = []
        for range in ranges {
            switch index.verdict(
                replacing: range, replacementIsSingleNewline: false,
                segmentation: header?.effectiveSegmentation ?? .paragraph
            ) {
            case .block, .tail:
                continue
            case .refuse(.lockedVariant):
                blockers.append(.lockedTake)
            case .refuse(.readOnlySlot):
                blockers.append(.unsyncedBlock)
            case .refuse(.crossesBlockBoundary), .refuse(.indexDesync),
                 .openTail, .closeTail:
                blockers.append(.crossesBlockBoundary)
            }
        }
        guard blockers.isEmpty else {
            // ALL-OR-NOTHING (ruled, and structurally forced by M1's batched
            // gate): nothing is applied, and the refusal counts and names.
            refuseFeedback(
                ranges.count == 1
                    ? FindReplaceGate.refusal(single: blockers[0])
                    : FindReplaceGate.refusal(total: ranges.count, blockers: blockers))
            return
        }

        // We are INSIDE AppKit's finder call (measured synchronous, M5) —
        // rewriting storage here would be re-entrant. The same reason
        // `shouldChangeText` defers its cross-block compounds: refuse now,
        // reproduce the exact intent on the next turn.
        let plan = zip(ranges, paddedStrings(strings, to: ranges.count)).map { ($0, $1) }
        findReplaceTask = Task { @MainActor [weak self] in
            self?.applyFindReplace(plan, in: textView)
        }
    }

    /// The finder hands a parallel `strings` array; a Replace All may send one
    /// string for every range. Neither shape is guessed at a call site.
    private func paddedStrings(_ strings: [String], to count: Int) -> [String] {
        if strings.count >= count { return Array(strings.prefix(count)) }
        return Array(repeating: strings.first ?? "", count: count)
    }

    /// Applies the replacements through the editor's ORDINARY input path —
    /// LAST MATCH FIRST, so every earlier offset is still valid — under ONE
    /// undo group, so a Replace All undoes as the single act she performed.
    private func applyFindReplace(
        _ plan: [(range: NSRange, replacement: String)], in textView: EditorTextView
    ) {
        let manager = textView.undoManager
        manager?.beginUndoGrouping()
        var applied = 0
        for (range, replacement) in plan.sorted(by: { $0.range.location > $1.range.location }) {
            // Re-checked against the CURRENT index, not the plan's snapshot:
            // between the gate and here the store may have delivered a
            // projection. A stale range must refuse, never merge.
            guard range.upperBound <= index.documentLength else { continue }
            let allowed = textView.withFindReplace {
                textView.shouldChangeText(in: range, replacementString: replacement)
            }
            guard allowed else { continue }
            textView.withFindReplace {
                textView.replaceCharacters(in: range, with: replacement)
                textView.didChangeText()
            }
            applied += 1
        }
        manager?.endUndoGrouping()
        showStatus(
            applied == plan.count
                ? FindReplaceGate.replaced(applied)
                : "Replaced \(applied) of \(plan.count) — the rest moved before they could be.")
        findReplaceTask = nil
    }
}

extension FindAction {
    /// The registry's vocabulary → AppKit's. The registry never imports
    /// AppKit (the `StructuralAct` layering); this is the feature-side map.
    var finderAction: NSTextFinder.Action {
        switch self {
        case .show: .showFindInterface
        case .showReplace: .showReplaceInterface
        case .next: .nextMatch
        case .previous: .previousMatch
        case .useSelection: .setSearchString
        }
    }
}
