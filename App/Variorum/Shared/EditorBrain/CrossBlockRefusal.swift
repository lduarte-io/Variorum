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
        /// The span reaches into the open tail, which is not a block yet.
        case openTail
        /// **The residual geometry, and 13u1 UNIT 2 shrank it to almost
        /// nothing.** Before item 5 this covered every cross-block selection
        /// with a partially covered block in it — her commonest gesture, and
        /// the refusal she called *"more annoying than it's worth"*. The
        /// compound now takes all of those. **What is left is the span with
        /// an end SITTING ON a boundary separator** (the ladder's round-1
        /// correction — the first wording claimed only the one-block case):
        /// a selection ending exactly where the next block begins or
        /// starting exactly where the previous one ends, touching one
        /// block's characters — AND its wider sibling, a span that reaches
        /// into two or more blocks while opening or closing ON the
        /// separator (anchor at a paragraph's end, ⇧-extend two paragraphs
        /// down). All of it keeps the pre-item-5 refusal — the compound's
        /// contiguity guard — and whether the compound should instead trim
        /// the boundary separator into the run is QUESTIONS #109 (a) and
        /// (d), PROVISIONAL, hers.
        case partialBlockAcrossSeam
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
    /// 3. **not editable** — an entry IN THE RUN is locked, or is a gap;
    /// 4. **the boundary-edge residual** — everything left: a span end
    ///    sitting on a boundary separator (either orientation, one block's
    ///    characters or several).
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
            return .partialBlockAcrossSeam
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
            return .openTail
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

        // 4. The residual: an end of the span sits ON a boundary separator
        // (whether the span touches one block's characters or reaches into
        // several — the ladder's round-1 correction).
        return .partialBlockAcrossSeam
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
        case .partialBlockAcrossSeam:
            // 13u1 UNIT 2 re-narrowed this line; the LADDER's round 1
            // corrected it — the first sentence here claimed the selection
            // did not reach the next block, which is FALSE for the residual's
            // wider member (a span reaching into two blocks while opening ON
            // the separator: anchor at a paragraph's end, ⇧-extend two
            // paragraphs down). What every residual shape shares is an end
            // sitting ON the boundary between two blocks, so that is what
            // the sentence says — true in both orientations and at both
            // span widths.
            "One end of this selection sits on the boundary between two blocks."
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
        case .partialBlockAcrossSeam:
            // The road must work for every residual shape: extending helps
            // the trailing cases, retracting helps the leading ones, so the
            // sentence names the MOVE (off the boundary) rather than one
            // direction — and the whole-paragraphs road (J9's delete) works
            // for all of them.
            "Nudge that end one character either way, or select the whole paragraphs."
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
