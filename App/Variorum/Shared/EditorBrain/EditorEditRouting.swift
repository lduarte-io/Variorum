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
    /// The UTF-16 length of the replacement the gate approved. With
    /// `range.length` it fixes the edit's NET change exactly — which is
    /// what `describes` polices (round-2 ladder round 1, MAJOR 1).
    let replacementLength: Int

    /// The policed edit's EXACT churn cost — old + new UTF-16 lengths,
    /// known at the gate and therefore immune to the report widening
    /// **BOTH platforms apply** (measured on iOS: a 5→6 replacement
    /// reported length 7; measured on macOS 26: a one-character insertion
    /// at offset 2 of "Alpha" reports `{2, 5}`, so the old
    /// report-derived arithmetic recorded 9 for a true cost of 1).
    ///
    /// **This sentence used to read "Platforms that derive cost from the
    /// report simply never read it (the Mac)", and it was written before
    /// 13l measured the macOS widening** — so it documented the Mac's
    /// non-use as though the report were exact there. It is not: the Mac
    /// adopted this value at 13u1 UNIT 1 (the 2026-08-30 sweep's P24 +
    /// P25), and BOTH `recordAutosave`s now read it, falling back to the
    /// report only where the arming did not bind. TEXTKIT2_NOTES §3's rule
    /// — clamp to the VERDICT's range, never the report's — applied to the
    /// arithmetic as well as to the attribute stamp.
    var exactCost: Int { range.length + replacementLength }

    init(
        verdict: BlockRangeIndex.Verdict,
        range: NSRange,
        documentLength: Int,
        replacementLength: Int
    ) {
        self.verdict = verdict
        self.range = range
        self.documentLength = documentLength
        self.replacementLength = replacementLength
    }

    /// Does this arming still describe the edit the storage just reported?
    ///
    /// Three things must hold, and it is worth being exact about which:
    ///
    /// 1. **The index must not have moved underneath it.** A full render,
    ///    a differential rewrite or a crystallization replaces the tiling
    ///    the verdict was computed against; a `.tail` verdict armed before
    ///    the tail closed is the sharpest case (its region no longer
    ///    exists at all).
    /// 2. **The net change must be EXACTLY the one that was approved** —
    ///    `delta == replacementLength - range.length`. The gate knows both
    ///    numbers, so the arming can insist on its own arithmetic instead
    ///    of merely bounding it. This is the guard her crashes needed (a
    ///    5-character approval consumed by a 15-character net deletion),
    ///    and it is the one that also catches the composed shape her stack
    ///    actually names — `_deleteBackwardAndNotify:reinsertText:`, a
    ///    delete COMPOSED WITH A REINSERTION, whose net change lands
    ///    somewhere the earlier magnitude-only bound could not see.
    /// 3. **The landing must start inside what was approved.** An arming
    ///    consumed by an edit somewhere else entirely is the
    ///    armed-but-never-landed case. **The bound is ASYMMETRIC, and
    ///    deliberately so** (round-2 ladder round 2, M15 Q2(b)): for a
    ///    NON-EMPTY approved range the start must be strictly inside it
    ///    (`< upperBound`), because no legitimate report begins at the
    ///    character *after* the last character the gate approved — that is
    ///    a different edit, and at `delta == 0` it binds with every other
    ///    oracle satisfied, sending the WRONG block's text to
    ///    `recordAutosave`. For an EMPTY range (an approved insertion) the
    ///    bound must stay inclusive: such a range's `upperBound` IS its
    ///    `location`, so a strict bound would reject every insertion the
    ///    gate approves. Attribute fixing cannot reopen the hole from the
    ///    other side — both measured iOS widenings keep `location` fixed
    ///    and grow only `length`.
    ///
    /// **What is deliberately NOT policed, and why:** the report's
    /// EXTENT. `NSTextStorage` attribute fixing widens `editedRange`
    /// beyond the characters that actually moved (measured on iOS: a
    /// one-character insertion reported `{8, 9}`), so an extent bound
    /// would reject ordinary keystrokes. Widening never touches `delta`,
    /// which is why the net-change identity above is the right thing to
    /// police. The residue this leaves is narrow but real: a transaction
    /// that starts inside the approved range, runs past its end, and
    /// nets to exactly the approved change would still bind. Nothing
    /// observed produces that shape, and the honest road is one step away
    /// if it ever appears — the mutators refuse and `desyncRecovery`
    /// re-renders from the store.
    ///
    /// A rejection is never a refusal of the EDIT — it only declines the
    /// shortcut, and the report is routed from scratch.
    ///
    /// **This is the GEOMETRY half; the consumers bind through `binds`**,
    /// which adds the one CONTENT check a verdict's meaning needs (below).
    func describes(editedRange: NSRange, delta: Int, documentLength current: Int) -> Bool {
        guard documentLength == current else { return false }
        // Subsumes the earlier `-delta <= range.length` bound: an approved
        // replacement's length is never negative, so an exact match can
        // never remove more than the range held — and unlike the bound, it
        // constrains INSERTIONS too (for `delta >= 0` the old predicate was
        // vacuously true, so an arming could absorb unbounded growth).
        guard delta == replacementLength - range.length else { return false }
        guard editedRange.location >= range.location else { return false }
        // Strictly inside a non-empty approval; inclusive for an empty one
        // (see 3. above — an approved insertion lands exactly at its own
        // location, and its `upperBound` is that same location).
        return range.length > 0
            ? editedRange.location < range.upperBound
            : editedRange.location <= range.upperBound
    }

    /// **THE BINDING both `storageDidEdit`s consume through: the geometry
    /// above, then the CONTENT check for the one verdict whose meaning IS
    /// content** (VM-5 stability pass, MAJOR 2).
    ///
    /// `describes` polices where an edit landed and by how much — never WHAT
    /// landed — and for three of the four armable verdicts that is the whole
    /// truth: `.block` and `.tail` are content-agnostic (any characters in
    /// that region belong to it), and `.closeTail` is a deletion (it lands
    /// no bytes to read, and while the arming describes its report the
    /// character it removed at the separator offset WAS the separator).
    ///
    /// **`.openTail` is the exception.** The gate arms it only for a typed
    /// `"\n"` at the exact document end, and consuming it declares that
    /// character a SEPARATOR. A gate-LESS one-character insert of anything
    /// else at that spot (autocorrect, dictation, a marked-text commit
    /// arriving after an armed newline that never landed — the consult/
    /// perform mismatch class E1 proved on her hardware) passes every
    /// geometry oracle — same length, net +1, the empty approval's inclusive
    /// bound — and the old binding opened an empty tail over a visible
    /// character: unowned, never autosaved, dropped at the next full render.
    /// So the landed bytes are read here (`replacementLength` characters at
    /// the approval's location — `describes` has just proven the landing
    /// starts there and nets exactly that), and anything but the separator
    /// declines the arming; `fallbackVerdict` then routes the report from
    /// scratch and answers the block the character joined.
    ///
    /// `landedText` reads the POST-edit surface (the storage the report
    /// describes); it is consulted only for `.openTail`, so the ordinary
    /// keystroke pays nothing. The switch is EXHAUSTIVE on purpose: a new
    /// armable verdict must decide here whether its meaning is content.
    func binds(
        editedRange: NSRange, delta: Int, documentLength current: Int,
        landedText: (NSRange) -> String
    ) -> Bool {
        guard describes(editedRange: editedRange, delta: delta, documentLength: current)
        else { return false }
        switch verdict {
        case .openTail:
            // "\n" is what the gate approved (`replacementIsSingleNewline`)
            // and what the tail's separator IS (`openTail()`'s own doc: the
            // typed newline that opened the tail is the separator before it).
            return landedText(NSRange(location: range.location, length: replacementLength))
                == EditorDocument.separator
        case .block, .tail, .closeTail, .refuse:
            return true
        }
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
///
/// **Why the handler is a `@TaskLocal` and not a `static var`** (round-2
/// ladder round 1, MINOR 4): a plain static is PROCESS-GLOBAL state, and
/// the suites that mute it hold the mute across hundreds of `await`s.
/// Swift Testing runs suites in parallel, so any other `@MainActor` test
/// scheduled during those suspensions would run with the editor's Debug
/// assertions silently disabled — the oracle turned off nondeterministically
/// in whichever tests happened to interleave. A task-local override is
/// scoped to the muting task and the tasks it spawns (which is exactly the
/// reach needed: `desyncRecovery` fires synchronously and then heals inside
/// a `Task {}` created in the same scope), and is invisible to every other
/// test running beside it.
enum EditorAssertionSeam {
    @TaskLocal static var handler: @Sendable @MainActor (String, StaticString, UInt) -> Void =
        { assertionFailure($0, file: $1, line: $2) }

    /// `#fileID`/`#line` default to the CALL SITE and are handed to the
    /// assertion itself, so the three distinct conditions stay
    /// distinguishable by location instead of all reporting this file
    /// (round-2 ladder round 1, NIT 7).
    @MainActor
    static func fire(
        _ message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        handler(message, file, line)
    }
}
