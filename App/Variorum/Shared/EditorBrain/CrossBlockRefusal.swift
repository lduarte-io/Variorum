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
        /// compound now takes all of those. What is left is the span that
        /// crosses a seam while touching the characters of only ONE block —
        /// a selection ending exactly where the next block begins, or
        /// starting exactly where the previous one ends (QUESTIONS #109,
        /// PROVISIONAL: it keeps its pre-item-5 refusal).
        case partialBlockAcrossSeam
    }

    /// Answers WHICH condition declined, given exactly what the routing arm
    /// knows. `slots` is the projection beside the index; it may be shorter
    /// than `entries` (it is deliberately held stale while the buffer is
    /// dirty), and every read of it is bounds-guarded — a missing slot simply
    /// cannot contribute a fan/unshown answer, and the geometry answers
    /// instead.
    ///
    /// The order is most-specific-first, and each step names the guard it
    /// mirrors:
    ///
    /// 1. **the seam keystroke** — `interEntrySeparatorPair` non-nil means
    ///    A7 and #34 both looked at this and declined; only their own
    ///    reasons are left (fan / unshown text / not editable);
    /// 2. **the open tail** — the span overlaps the tail region, which the
    ///    compound excludes by its contiguity guard;
    /// 3. **not editable** — an entry IN THE RUN is locked, or is a gap;
    /// 4. **partial coverage** — everything left.
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

        // 2. The open tail inside the span.
        if let tail = index.tailRange,
           NSIntersectionRange(range, tail).length > 0
            || (tail.length == 0 && range.upperBound > tail.location) {
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

        // 4. The residual: a boundary crossed with only one block's
        // characters inside the span.
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
            // 13u1 UNIT 2: the compound took every span that covers a block
            // in part, so this line no longer speaks for her commonest
            // gesture. What is left is the span that crosses a seam while
            // touching only ONE block's characters, and the sentence says
            // exactly that instead of the old, wider claim.
            "This selection stops right at a block boundary without reaching into the next block."
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
            "Reach a little further into the next block, or select the whole paragraphs."
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
