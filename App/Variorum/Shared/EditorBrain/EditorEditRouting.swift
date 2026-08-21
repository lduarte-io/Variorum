//
//  EditorEditRouting.swift
//  Variorum
//
//  Mobile round 2, batch 1 — the two shared pieces of the delete-at-the-end
//  crash fix (`notes/plans/mobile-round-2-crash-trace.md`). Both platforms'
//  editors run the SAME two-phase edit protocol, so both get these once:
//  MobileSoul §3's rule (brains in the shared layer, faces per platform),
//  and this round's M-C.
//
//  · `ArmedEdit` — the gate's answer BOUND to the edit it answered about.
//  · `EditorAssertionSeam` — the honest road's debug voice, made testable.
//

import Foundation

// MARK: - The armed gate verdict, bound to its edit

/// One approved edit, as the keyboard gate answered it.
///
/// **The bug this type exists to kill.** `shouldChangeText` computes a
/// verdict against the PRE-edit index and parks it; `storageDidEdit` then
/// takes the *identity* from that parked answer (`.block(i)` / `.tail`)
/// and the *magnitude* from a completely different source (the storage's
/// own `changeInLength` report) — and nothing ever checked that the two
/// described the same edit. A verdict carried no range, no document
/// length, and no expiry, so any gap between "what the gate was asked
/// about" and "what actually landed in storage" applied the wrong
/// bookkeeping to the wrong region.
///
/// That gap is ordinary, not exotic. `NSTextStorage.coordinateEditing:`
/// coalesces however many mutations happen inside it into ONE
/// `didProcessEditing` carrying the union range and the NET delta — and
/// UIKit's `deleteBackward` composes a delete with a re-insert inside one
/// such block (her crash's frames 6–13; the repo had already measured the
/// same class on AppKit's Replace All, `EditorFind.swift`'s M1/M1b). A
/// door can also arm the gate for an edit that then does not land
/// (`MobileMarkdownActs.handleReturnKey`'s `.continueList` early return),
/// leaving the arming for the next keystroke to consume. And the index
/// itself moves under a parked verdict at every full render and every
/// crystallization.
///
/// `describes(...)` is the whole fix: an arming is consumed only while it
/// still describes the report that arrived, and anything else falls
/// through to `fallbackVerdict`, which recomputes against the pre-edit
/// index and is provably safe for a deletion (the trace's §3a lemma).
nonisolated struct ArmedEdit {
    let verdict: BlockRangeIndex.Verdict
    /// The range the gate approved, in PRE-edit coordinates.
    let range: NSRange
    /// `index.documentLength` at the moment the gate answered.
    let documentLength: Int
    /// The policed edit's EXACT churn cost (old + new UTF-16 lengths,
    /// captured at the gate because iOS's report can widen). Nil where a
    /// platform derives cost from the report instead (the Mac).
    let cost: Int?

    init(
        verdict: BlockRangeIndex.Verdict,
        range: NSRange,
        documentLength: Int,
        cost: Int? = nil
    ) {
        self.verdict = verdict
        self.range = range
        self.documentLength = documentLength
        self.cost = cost
    }

    /// Does this arming still describe the edit the storage just reported?
    ///
    /// Three questions, one per way the arming goes stale:
    ///
    /// 1. **The index must not have moved underneath it.** A full render,
    ///    a differential rewrite or a crystallization replaces the tiling
    ///    the verdict was computed against; a `.tail` verdict armed before
    ///    the tail closed is the sharpest case (its region no longer
    ///    exists at all).
    /// 2. **A deletion can never remove more than was approved.** This is
    ///    the coalescing guard, and the one her crashes needed: the gate
    ///    approved a 5-character sub-range while the report carried a
    ///    15-character net deletion.
    /// 3. **The landing must start inside what was approved.** An arming
    ///    consumed by an edit somewhere else entirely is the
    ///    armed-but-never-landed case; the upper bound is inclusive
    ///    because an approved insertion's range is empty and lands
    ///    exactly at its own location.
    ///
    /// A rejection is never a refusal of the EDIT — it only declines the
    /// shortcut, and the report is routed from scratch.
    func describes(editedRange: NSRange, delta: Int, documentLength current: Int) -> Bool {
        guard documentLength == current else { return false }
        guard -delta <= range.length else { return false }
        return editedRange.location >= range.location
            && editedRange.location <= range.upperBound
    }
}

// MARK: - The honest road's debug voice

/// The editor's "this should be impossible" voice, with a test seam.
///
/// Both view models assert on three states that Release recovers from
/// silently: a surface desynced from its index (`desyncRecovery` — which
/// then flushes, re-reads and re-renders from the store), an editable
/// entry with no variant, and — on iOS — an identity projection that
/// disagrees with the index. Debug builds SHOULD stop the world on those:
/// they mean a bug, and finding it in her Xcode drops is the point.
///
/// But a pin that exercises the healing road cannot survive an assertion
/// that stops the world, and the healing road is exactly what this round
/// needed to pin. So the assertion goes through one replaceable handler —
/// the `FallbackCanary` / `MobileFallbackCanary` N2 pattern this repo
/// already uses for the same reason. Production never touches it; a test
/// swaps it for its own scope and asserts the models' counters
/// (`desyncRecoveryCount`, `identityAuditFailures`) instead, which is the
/// stronger oracle anyway.
@MainActor
enum EditorAssertionSeam {
    static var handler: @MainActor (String) -> Void = { assertionFailure($0) }

    static func fire(_ message: String) { handler(message) }
}
