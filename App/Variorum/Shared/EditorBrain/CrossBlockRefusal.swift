//
//  CrossBlockRefusal.swift
//  Variorum
//
//  Phase 13j, batch 1 — her J8(b): the `.crossesBlockBoundary` refusal stops
//  GUESSING and starts DIAGNOSING.
//
//  The shipped line named three causes at once — *"a locked take, unsynced
//  text, or text that isn't a block yet"* — for a gesture that had exactly
//  one. Her screenshot report: *"the reason is really unclear to me why right
//  now."* Copy naming a cause the code never established is the defect class
//  itself (the enum-dump family, one level up), so this file is the one place
//  that asks WHICH condition actually declined and answers in her words.
//
//  **HOISTED to `Shared/` at 13u1 UNIT 2 (item 8's fifth: U-5).** It lived
//  Mac-app-local from 13j until the phone needed the same answers; the
//  mobile-round handoff's own row is blunt about what that cost —
//  *"`CrossBlockRefusal` was never hoisted … so the phone's cross-block
//  refusal names NONE of its four real causes"*, and the line it left behind
//  carried an unexecuted instruction to re-narrow itself. MobileSoul §3's
//  rule is the fix: brains live in `Shared/`, platforms own only faces.
//
//  **WHAT STAYS PLATFORM, and why it is a parameter rather than a fork:**
//  the ROADS out of a fan name Mac chords (⌘⇧M, ⌥⌘⇧M), and a shared home
//  must not hold a sentence that names a door one platform does not have
//  (MobileSoul §4.4, read from the other side). So the fan road arrives as
//  `fanRoads`, and every other road is the same sentence on both platforms
//  because the act it points at is the same act.
//
//  It is a PURE brain over the surface's own bookkeeping — the index's
//  tiling plus the projection's per-block counts — so every branch is
//  reachable in a unit test with no store, no AppKit, and no timing.
//

import Foundation
import VariorumCore

nonisolated enum CrossBlockRefusal {
    /// The causes, one per condition the routing arm can actually decline
    /// on. Each is traced to the guard that produces it in the cross-block
    /// arm of the editor's gate, in the order `diagnose` asks them.
    enum Cause: Equatable, Sendable {
        /// The span is exactly one inter-block seam and the block beside it
        /// carries takes — A7's carve declines (its authorization is "there
        /// is no text to lose") and #34's merge needs text on both sides.
        case seamBesideFan
        /// …or it carries prose the slot does not show. `carriesUnshownText`
        /// is ONE guard over TWO kinds (13c R1-1 + R2-1), and the diagnosis
        /// deliberately splits what the guard joins: a line that said
        /// "an archived take or a comment" would be the very guessing this
        /// row exists to end. When a block carries both, the archived take
        /// leads — it is the heavier prose and the harder one to find again.
        case seamBesideArchivedTake
        case seamBesideComment
        /// **A take in the span is LOCKED.** R-13u-1 (the 13u1 kickoff
        /// sitting) made this a REFUSE-WHOLE: one gesture, one answer, the
        /// bulk grammar's all-or-nothing precedent (#93(c)). It is now one
        /// of the only two things a cross-block edit refuses for.
        case lockedTake
        /// A block in the span has not arrived yet (a gap slot — no variant
        /// to write into). The gap fence's own reason: tombstoning a block
        /// whose text she has never seen would delete a peer's paragraph
        /// under tombstone-wins.
        case unsyncedBlock
        /// The span reaches into the open tail, which is not a block yet —
        /// a tail WITH TEXT, where waiting is a real road (the idle mint
        /// crystallizes it moments after she pauses). The EMPTY tail's
        /// doorstep is the case below.
        case openTail
        /// The span reaches the tail region while the tail is EMPTY — the
        /// trailing empty line a ⏎ at the note's end leaves behind. Split
        /// from `.openTail` at the 13u1 ladder, round 2 (the
        /// `seamBesideArchivedTake` doctrine: ONE declining guard — the
        /// plan's contiguity/tail condition — split into the causes whose
        /// ROADS differ): a typed-on tail crystallizes moments after she
        /// pauses, so `.openTail`'s waiting road is true there; an EMPTY
        /// tail never mints (every crystallizer guards
        /// `!tail.allSatisfy(\.isWhitespace)`, which an empty string
        /// satisfies vacuously), so that promise is false here and the true
        /// roads are the nudge and the empty line's own delete
        /// (`BlockRangeIndex.verdict`'s `.closeTail`).
        case emptyTailAtSpanEnd
        /// **THE SEAM KEYSTROKE NO CARVE COULD TAKE** (13u2 UNIT C). One of
        /// the two halves the retired boundary residual split into — the
        /// `seamBesideArchivedTake` doctrine again: ONE declining guard,
        /// split into the causes whose ROADS differ. This is the
        /// single-separator keystroke that reached `diagnose` step 1 and
        /// matched none of the seam's named conditions, and it has a
        /// different shape on each platform:
        ///
        /// - **Mac:** A7's empty-block carve declined on its own bounds
        ///   guard (`i < model.slots.count`) because the PROJECTION has not
        ///   arrived for that entry — `slots` is deliberately held stale
        ///   while the buffer is dirty and can be shorter than `entries` —
        ///   and step 1's fan/archived/comment reads are bounds-guarded, so
        ///   none of them can say which authorization failed.
        /// - **iPhone:** there are no seam carves at all (neither A7's nor
        ///   #34's is built there), so an ordinary backspace at a seam
        ///   between two texted blocks lands here permanently. A standing
        ///   parity gap, not a new one.
        ///
        /// The ROAD is the same on both and it genuinely opens: the
        /// DELIBERATE merge gesture, which is the act the keystroke was
        /// reaching for. (It arrives as `fanRoads` — the one sentence that
        /// names a platform's own chord or menu row.)
        case seamKeystrokeDeclined
        /// **THE RESIDUAL, AND IT IS NO LONGER A GEOMETRY** (13u2 UNIT C —
        /// her #109 ruling of 2026-09-15). This case used to be the
        /// boundary-edge shape: a selection whose end sat ON the separator
        /// between two blocks, in both sizes. **That whole family is GONE**
        /// — the boundary-clamp law clamps such a span to block text and
        /// either edits inside one block (shape (i)) or trims the separator
        /// into the run (shape (ii)), so no boundary-anchored selection
        /// refuses any more. The case did not become unreachable, though,
        /// and the ruling's own instruction was to name what genuinely
        /// survives rather than delete a cause that can still fire.
        ///
        /// What reaches it, after the split above: **`plan` declining on a
        /// surface that disagrees with its index**
        /// (`CrossBlockCompound.plan`'s `text.length == ranges[i].length`
        /// guard) — a desync the surface heals by re-rendering from the
        /// store, and the one production road to `diagnose`'s step 4. The
        /// words therefore name no geometry, because this shape has none:
        /// the editor's own bookkeeping has not caught up, and waiting a
        /// beat is a road that actually opens (the 13u1 ladder's rule).
        case surfaceNotSettled
    }

    /// Answers WHICH condition declined, given exactly what the routing arm
    /// knows. `slots` is the projection beside the index; it may be shorter
    /// than `entries` (it is deliberately held stale while the buffer is
    /// dirty), and every read of it is bounds-guarded — a missing slot simply
    /// cannot contribute a fan/unshown answer, and the geometry answers
    /// instead.
    ///
    /// **Precondition, relied on rather than re-checked (13u1 ladder,
    /// round 2):** `range` lies inside the document the index describes.
    /// The one production road here is the gate's `.crossesBlockBoundary`
    /// arm, and `BlockRangeIndex.verdict` fences an out-of-document range
    /// upstream as `.indexDesync` before any refusal can diagnose. A test
    /// that hand-feeds a range past `documentLength` is asking a question
    /// no production caller can ask.
    ///
    /// The order is most-specific-first, and each step names the guard it
    /// mirrors:
    ///
    /// 1. **the seam keystroke** — `interEntrySeparatorPair` non-nil means
    ///    A7 and #34 both looked at this and declined; only their own
    ///    reasons are left (fan / unshown text / not editable);
    /// 2. **the open tail** — the span overlaps the tail region, or ends ON
    ///    the tail's own separator (either way the compound's contiguity
    ///    guard is what declined, so the tail's cause and road speak);
    ///    an EMPTY tail answers `.emptyTailAtSpanEnd` instead, because the
    ///    waiting road is false for it (round 2's split);
    /// 3. **not editable** — an entry IN THE RUN is locked, or is a gap;
    /// 4. **everything left** — which, since 13u2 UNIT C built #109's
    ///    boundary-clamp law, is no longer a geometry at all: the
    ///    boundary-edge family is taken (clamped or trimmed), and what still
    ///    reaches here is a surface whose own bookkeeping has not caught up
    ///    (`.surfaceNotSettled`'s own doc names it). Step 1's own
    ///    fallthrough is `.seamKeystrokeDeclined`, split from it for the
    ///    road they do not share.
    ///
    /// **The RUN this walks is the span SHE MADE, not the clamped one, and
    /// that is what keeps the diagnosis honest** (13u2 UNIT C): the plan
    /// derives its run from the raw span too and clamps only the CUTS, so
    /// the entries this walk reads are exactly the entries the plan read. A
    /// locked take or a gap anywhere in that run still refuses the whole
    /// gesture (R-13u-1) — and a block whose separator the clamp merely
    /// trimmed is not in the run at all, because it contributes no
    /// characters, so a locked neighbour can never refuse a gesture that
    /// does not touch it.
    ///
    /// **Step 3 walks the RUN, not the intersected entries** (13u1 UNIT 2,
    /// with the compound that shares the rule): a zero-length entry — an
    /// empty block, or a GAP whose variant has not arrived — renders no
    /// characters, so a span runs straight past one without intersecting it.
    /// The old walk therefore could not see the very block that made the
    /// compound decline, and named the residual cause instead of the real
    /// one. This is the same widening the plan makes, and the two must agree
    /// or a refusal names a cause the planner did not decline on.
    static func diagnose(
        range: NSRange,
        index: BlockRangeIndex,
        slots: [Queries.RenderedBlock]
    ) -> Cause {
        let entries = index.entries

        // 1. The seam keystroke the two carves declined.
        //
        // `isDeletion: true` IS HARDCODED, AND THAT IS DELIBERATE — the
        // shield that makes it true is named here so an arm-list edit can
        // never make it false silently (VM-5 stability pass, NIT 5). This
        // terminal is handed no replacement, so step 1 reads every lone
        // inter-entry separator as a deletion. A TYPE-OVER of one never
        // arrives: #109's clamp (`CrossBlockCompound.clampedToBlockText`'s
        // degenerate shape, QUESTIONS #111) answers EVERY lone-separator
        // replacement with a zero-length in-block edit, and BOTH platforms
        // declare `.clampedInBlockEdit` above this terminal; the arms above
        // the clamp (the find fence, the two carves, J9) never claim a
        // non-empty replacement here. Pinned by name across both declared
        // lists: `EditorEditRouteTableTests
        // .aLoneSeparatorTypedOverNeverReachesTheDiagnosis`. If that pin
        // ever goes red, DO NOT simply pass the real fact: a non-deletion
        // reading falls through to `.surfaceNotSettled`, whose "try that
        // again in a moment" road is false for a type-over (retrying changes
        // nothing) — that shape would need its own cause and sentence, which
        // is the author's copy to rule, not this function's to improvise.
        if let (before, after) = index.interEntrySeparatorPair(deleting: range, isDeletion: true) {
            for i in [before, after] {
                if !entries[i].editable {
                    return entries[i].variantID == nil ? .unsyncedBlock : .lockedTake
                }
            }
            for i in [before, after] where i < slots.count {
                if slots[i].hasFan { return .seamBesideFan }
            }
            for i in [before, after] where i < slots.count {
                if slots[i].hasArchivedTakes { return .seamBesideArchivedTake }
            }
            for i in [before, after] where i < slots.count {
                if slots[i].hasComments { return .seamBesideComment }
            }
            return .seamKeystrokeDeclined
        }

        // 2. The open tail inside the span — or at its very END (the 13u1
        // ladder, round 1, the sanity-pass find on F-2's new sentence): a
        // span that covers the LAST block's trailing separator and stops
        // exactly where a non-empty tail begins intersects no tail
        // character, yet the plan refuses it on this same condition (its
        // contiguity guard excludes the tail), so the diagnosis declines on
        // the tail's ground too — the boundary residual's sentence says
        // "between two blocks", and the far side here is not a block yet.
        // The tail outranking step 3 is the plan's own order: contiguity
        // declines before the run's locks and gaps are ever read.
        //
        // (An earlier `tail.length == 0 && range.upperBound > tail.location`
        // arm was DELETED at the 13u1 ladder, round 2, as provably dead: with
        // an empty tail, `tail.location` IS `documentLength` — the document
        // ends at the tail separator — so no in-document range (the
        // precondition above) can end past it; and the separator arm below
        // subsumes it anyway (`tail.location = tailSeparatorOffset + 1`).
        // Without this sentence the arm reads as an uncovered case and comes
        // back.)
        if let tail = index.tailRange,
           NSIntersectionRange(range, tail).length > 0
            || (index.tailSeparatorOffset.map { range.upperBound > $0 } ?? false) {
            // Round 2's split: same declining guard, different true roads.
            // An empty tail can only arrive via the separator arm (a
            // zero-length region intersects nothing), and its waiting road
            // is false — see the Cause's own doc.
            return tail.length == 0 ? .emptyTailAtSpanEnd : .openTail
        }

        // 3. An entry IN THE RUN that no road can write into. ONE tiling
        // walk (13u1 UNIT 1's O(N²) class: this asked
        // `index.range(ofEntryAt: i)` per entry, and the accessor walks from
        // zero, so diagnosing a refusal cost Σi ≈ N²/2 — document-
        // proportional work at the exact moment the author is being told no.)
        let ranges = index.entryRanges()
        var first: Int?
        var last: Int?
        for i in entries.indices {
            let entryRange = ranges[i]
            let touches = (entryRange.upperBound > range.location
                && entryRange.location < range.upperBound)
                || (entries[i].length == 0
                    && entryRange.location >= range.location
                    && entryRange.location < range.upperBound)
            guard touches else { continue }
            if first == nil { first = i }
            last = i
        }
        if let first, let last {
            for i in first...last where !entries[i].editable {
                return entries[i].variantID == nil ? .unsyncedBlock : .lockedTake
            }
        }

        // 4. What is left. Since #109's boundary-clamp law (13u2 UNIT C) the
        // boundary-edge family never arrives here — the clamp took it — and
        // the production shape that does is the plan declining on a surface
        // that disagrees with its own index.
        return .surfaceNotSettled
    }

    /// **The cause, in one sentence, naming ONE thing.** Split from the road
    /// below so the pin can hold exactly the promise this row makes: the
    /// diagnosis half offers no menu of maybes. (The road half may well offer
    /// a choice — two ways out of one cause is help, not a guess.)
    static func causeClause(for cause: Cause) -> String {
        switch cause {
        case .seamBesideFan:
            "One of the blocks at this seam has takes."
        case .seamBesideArchivedTake:
            "That block looks empty, but it carries an archived take."
        case .seamBesideComment:
            "That block looks empty, but it carries a comment."
        case .lockedTake:
            // 13u1 UNIT 2 (R-13u-1): the sentence carries the ALL-OR-NOTHING
            // fact, because a refusal that does not say "nothing changed"
            // reads as a half-done gesture — the `blockGone` lesson, one door
            // over.
            "A take in this selection is locked — nothing was changed."
        case .unsyncedBlock:
            "A block in this selection hasn't arrived yet — nothing was changed."
        case .openTail:
            "The end of this selection isn't a block yet."
        case .emptyTailAtSpanEnd:
            // Round 2 (NIT-A): what she is looking at is the empty line her
            // ⏎ left at the note's end — name that, not an abstract region.
            "The end of this selection is the empty line at the note's end."
        case .seamKeystrokeDeclined:
            // 13u2 UNIT C: the half of the retired residual that really IS a
            // seam. It names what declined — this keystroke, at this seam —
            // and never why, because on the Mac the why is a projection that
            // has not arrived and on the phone it is a carve that was never
            // built. The ROAD is what both shapes share.
            "This keystroke can't join these two blocks."
        case .surfaceNotSettled:
            // 13u2 UNIT C. The boundary sentence this line used to carry —
            // *"One end of this selection sits on the boundary between two
            // blocks."* — RETIRED with the geometry it described: #109's
            // clamp law takes that family now, and a sentence describing a
            // shape that can no longer refuse is the same defect class F-2
            // fixed. What is left is a surface whose bookkeeping has not
            // caught up (the Cause's own doc names the shape), so the line
            // says exactly that and names no block, because this shape does
            // not know one.
            "This part of the note is still settling."
        }
    }

    /// The way out — a real road for every cause (P-2's spirit at the copy
    /// layer: a refusal that leaves you nowhere is a dead end, not an answer).
    ///
    /// `fanRoads` is the ONE platform-shaped sentence (it names chords), so
    /// each app hands in its own; everything else is the same road on both.
    static func roadClause(for cause: Cause, fanRoads: String) -> String {
        switch cause {
        case .seamBesideFan:
            // 13j ladder A round 1, finding A2 (MAJOR — fixed by the
            // reviewer): this line still taught "⌘⇧M to pair the takes
            // yourself" after the J4b flip made ⌘⇧M carry-all — the exact
            // sentence the batch-4 sweep fixed in `seamFanRefusal`, alive in
            // its second home, inside J8(b)'s own file. Both speakers now
            // read the ONE roads constant, which since the hoist arrives as
            // this parameter.
            "A keystroke won't fold a fan away \u{2014} " + fanRoads
        case .seamBesideArchivedTake:
            "Open its takes to see it, or use Delete Block to remove the block whole."
        case .seamBesideComment:
            "Open its comments, or use Delete Block to remove the block whole."
        case .lockedTake:
            "Branch it or unlock it, then try again."
        case .unsyncedBlock:
            "It stays read-only until it syncs."
        case .openTail:
            "It becomes one moments after you pause typing, and then it can go with the rest."
        case .emptyTailAtSpanEnd:
            // Round 2 (NIT-A): the crystallization promise is FALSE for an
            // empty tail (nothing will ever mint), so the road names the two
            // moves that exist — both platform-neutral: the nudge, and the
            // line's own delete (`.closeTail`).
            "Nudge that end back one character, or delete the empty line on its own."
        case .seamKeystrokeDeclined:
            // The deliberate merge is the act the keystroke was reaching
            // for, and it opens on BOTH platforms — the phone has the menu
            // row, the Mac the chords. Same roads constant the fan-fold
            // refusal reads, which is why it arrives as a parameter.
            fanRoads
        case .surfaceNotSettled:
            // The road the surviving shape actually has. The old
            // "nudge that end one character either way" retired with the
            // boundary geometry: nudging answers nothing when the decline
            // is an index that disagrees with the surface, which resolves on
            // its own within a beat — the surface re-renders from the store.
            "Try that again in a moment."
        }
    }

    /// The line she reads: the one cause, then the road out of it.
    static func message(for cause: Cause, fanRoads: String) -> String {
        causeClause(for: cause) + " " + roadClause(for: cause, fanRoads: fanRoads)
    }

    /// The one call site's convenience: diagnose, then speak.
    static func message(
        range: NSRange, index: BlockRangeIndex, slots: [Queries.RenderedBlock],
        fanRoads: String
    ) -> String {
        message(for: diagnose(range: range, index: index, slots: slots), fanRoads: fanRoads)
    }
}
