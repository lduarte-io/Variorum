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
//  It is a PURE brain over the surface's own bookkeeping — the index's
//  tiling plus the projection's per-block counts — so every branch is
//  reachable in a unit test with no store, no AppKit, and no timing.
//

import Foundation
import VariorumCore

nonisolated enum CrossBlockRefusal {
    /// The causes, one per condition the routing arm can actually decline
    /// on. Each is traced to the guard that produces it in
    /// `EditorViewModel.shouldChangeText`'s cross-block arm, in the order
    /// `diagnose` asks them.
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
        /// A block in the span is locked: no road edits a frozen buffer.
        case lockedTake
        /// A block in the span has not arrived yet (a gap slot — no variant
        /// to write into).
        case unsyncedBlock
        /// The span reaches into the open tail, which is not a block yet.
        case openTail
        /// The span crosses a block boundary while covering some block only
        /// PARTIALLY on one side — the residual geometry after every road
        /// above. Her J9 ruling keeps this case's behaviour deliberately:
        /// whole-block selections delete, partial ones do not.
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
    /// 2. **the open tail** — the span overlaps the tail region, which
    ///    `planCrossBlockEdit` and `planVisibleTakeEdit` both exclude by
    ///    their contiguity guard;
    /// 3. **not editable** — a touched entry is locked, or is a gap;
    /// 4. **partial coverage** — everything left.
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

        // 3. A touched block that no road can write into. ONE tiling walk
        // (13u1 UNIT 1 — the O(N²) class): this asked
        // `index.range(ofEntryAt: i)` per entry, and the accessor walks from
        // zero, so diagnosing a refusal cost Σi ≈ N²/2 — document-
        // proportional work at the exact moment the author is being told no.
        let ranges = index.entryRanges()
        for i in entries.indices {
            let entryRange = ranges[i]
            guard NSIntersectionRange(range, entryRange).length > 0 else { continue }
            if !entries[i].editable {
                return entries[i].variantID == nil ? .unsyncedBlock : .lockedTake
            }
        }

        // 4. The residual: a boundary crossed with a block covered in part.
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
            "A take in this selection is locked."
        case .unsyncedBlock:
            "A block in this selection hasn't arrived yet."
        case .openTail:
            "The end of this selection isn't a block yet."
        case .partialBlockAcrossSeam:
            "This selection crosses a block boundary and covers one of the blocks only in part."
        }
    }

    /// The way out — a real road for every cause (P-2's spirit at the copy
    /// layer: a refusal that leaves you nowhere is a dead end, not an answer).
    static func roadClause(for cause: Cause) -> String {
        switch cause {
        case .seamBesideFan:
            // 13j ladder A round 1, finding A2 (MAJOR — fixed by the
            // reviewer): this line still taught "⌘⇧M to pair the takes
            // yourself" after the J4b flip made ⌘⇧M carry-all — the exact
            // sentence the batch-4 sweep fixed in `seamFanRefusal`, alive in
            // its second home, inside J8(b)'s own file. Both speakers now
            // read the ONE roads constant.
            "A keystroke won't fold a fan away \u{2014} "
                + FannedDefaultsCopy.fanFoldRoads
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
            "Select the whole paragraphs to delete them, or edit inside one block."
        }
    }

    /// The line she reads: the one cause, then the road out of it.
    static func message(for cause: Cause) -> String {
        causeClause(for: cause) + " " + roadClause(for: cause)
    }

    /// The one call site's convenience: diagnose, then speak.
    static func message(
        range: NSRange, index: BlockRangeIndex, slots: [Queries.RenderedBlock]
    ) -> String {
        message(for: diagnose(range: range, index: index, slots: slots))
    }
}
