//
//  CrossBlockEditPlanner.swift
//  Variorum
//
//  MERGE-THEN-EDIT — the author's ratified 2026-07-09 direction ("a
//  cross-seam delete just works"): a destructive edit whose selection opens
//  inside one paragraph and closes inside another does NOT refuse. It MERGES
//  the touched run and applies the edit to the merged buffer, as ONE undo
//  compound. Her own principle is what carries it: *"if your text looks like
//  basic text with no variants, it should behave like basic text"* — and,
//  from mobile round 2 (§31, R16): *"basically obvious and intuitive
//  operations like selecting a bunch of visible text and deleting should be
//  allowed - the refusing because of different blocks is more annoying than
//  it's worth."*
//
//  HOISTED HERE at mobile round 2, batch 3 (M22), out of the Mac-app-local
//  `EditorSurfaceController`, where the pair lived from 2026-07-09 until a
//  second platform needed the same answer. MobileSoul §3 is the rule: brains
//  live in core/`Shared/`, platforms own only faces — a byte-copy on the
//  phone would have been a parity defect at birth (the KnownIssues "six
//  mobile brains are byte-copies" row is the standing scar this avoids).
//  Both platforms' consumers are thin: the Mac's `planCrossBlockEdit` /
//  `runCrossBlockEdit` are delegates, and the phone's gate + structural door
//  compose the same two functions.
//
//  WHAT IS DELIBERATELY NOT HERE — the FANNED span. A cross-block span where
//  a touched block carries takes routes to the Mac's VISIBLE-TAKE edit (the
//  #11a sitting ruling, 2026-07-13: the halves JOIN only where no fan hangs
//  on the seam), which is Mac-app code and stays there. `plan` therefore
//  declines any touched entry whose live active-take count is not exactly 1,
//  exactly as it always did — that condition is a RULING, not an
//  implementation detail, and this hoist does not touch it.
//
//  The split of duties, mirroring `BlockRangeIndex`'s J9 pair:
//    · `plan`  — pure geometry + the conditions, over an index snapshot.
//    · `apply` — the compound BODY over `Operations` (the merge chain and
//      the merged-range arithmetic), so neither platform re-derives the
//      mapping. The FACE around it (the in-flight latch, the pre-op flush,
//      the caret write, the words spoken) stays per-platform.
//

import Foundation
import VariorumCore

nonisolated enum CrossBlockEditPlanner {

    /// A cross-block DESTRUCTIVE EDIT on single-variant blocks. Nil from
    /// `plan` = not eligible — a FANNED span takes the VISIBLE-TAKE edit
    /// instead (the #11a sitting ruling, 2026-07-13); locked/gap/tail spans
    /// keep the speaking refusal.
    ///
    /// **Constructible only by `plan`** (the init is fileprivate), so the
    /// guarantees `apply` reads off it — at least two block IDs, one piece
    /// per ID, in surface order — hold by construction rather than by
    /// convention. That is what lets `apply` index the head of the run
    /// without a trap: the state the index would trap on cannot be built.
    struct Edit: Sendable, Equatable {
        let blockIDs: [String]
        /// The touched blocks' rendered variants + their PLAN-TIME surface
        /// texts — the compound's compare-and-set inputs (a buffer that
        /// moved since planning refuses the whole compound, visibly).
        let pieces: [(variantID: String, text: String)]
        /// The edit's start, intra the FIRST block (merge preserves the
        /// leading text verbatim, so this addresses the merged text too).
        let intraStart: Int
        /// The edit's end, intra the LAST block.
        let intraEndInLast: Int
        /// The last block's surface length at plan time (locates the tail
        /// suffix in the merged text — derived from op output, never
        /// re-guessed).
        let lastPieceLength: Int
        let replacement: String

        fileprivate init(
            blockIDs: [String], pieces: [(variantID: String, text: String)],
            intraStart: Int, intraEndInLast: Int, lastPieceLength: Int, replacement: String
        ) {
            self.blockIDs = blockIDs
            self.pieces = pieces
            self.intraStart = intraStart
            self.intraEndInLast = intraEndInLast
            self.lastPieceLength = lastPieceLength
            self.replacement = replacement
        }

        static func == (lhs: Edit, rhs: Edit) -> Bool {
            lhs.blockIDs == rhs.blockIDs
                && lhs.pieces.elementsEqual(rhs.pieces, by: ==)
                && lhs.intraStart == rhs.intraStart
                && lhs.intraEndInLast == rhs.intraEndInLast
                && lhs.lastPieceLength == rhs.lastPieceLength
                && lhs.replacement == rhs.replacement
        }
    }

    /// Where the caret belongs once the compound lands, by IDENTITY — the
    /// merged block plus an intra-block offset. Never a surface offset: the
    /// surface re-renders from the store between the compound and the write,
    /// so an offset computed against the old tiling would be stale (the
    /// `caretLandingAfterRemoving` doctrine, same reason).
    struct Landing: Sendable, Equatable {
        let blockID: String
        let caretOffset: Int
    }

    // MARK: - The plan (pure)

    /// Routes a refused cross-block range to the merge-then-edit compound,
    /// or answers nil so the caller's remaining roads (and finally its
    /// refusal) speak.
    ///
    /// The conditions, unchanged by the hoist and each one a ruling:
    ///
    /// 1. **at least two touched entries** — a single-entry range was never
    ///    a cross-block edit;
    /// 2. **contiguity + no tail** — the range must sit inside the touched
    ///    run, which also excludes any span reaching the open tail (not a
    ///    block yet; idle-mint makes it one within seconds);
    /// 3. **every touched entry has arrived and is editable**
    ///    (`variantID != nil && editable`) — a gap has nothing to merge and a
    ///    locked take's buffer is frozen;
    /// 4. **every touched entry carries exactly ONE live active take** — a
    ///    fanned block routes to the visible-take edit instead (#11a).
    ///
    /// `fanArities` is the per-entry live active-take count, aligned with
    /// `index.entries` (both platforms pass `slots.map(\.activeVariantCount)`).
    /// It may run SHORTER than the entries during a crystallization window,
    /// and a missing arity **declines** here — deliberately STRICTER than
    /// `StructuralGesturePlanner.World.fanArity`, which reads a missing entry
    /// as arity 1. That asymmetry is the shipped Mac behaviour, preserved
    /// verbatim: this road MERGES blocks, so an unknown fan is not a fan it
    /// may assume away.
    ///
    /// `surfaceText` reads the live surface for a document range (the buffer
    /// is authoritative while dirty — the compound must compare-and-set
    /// against what the author sees). It is called once per TOUCHED entry,
    /// never per document.
    ///
    /// **ONE PASS over the tiling (P1/P-8), and the ONE deviation this hoist
    /// makes from the Mac's shipped bytes — measured, not argued.** The
    /// original asked `index.range(ofEntryAt: i)` inside the collection loop,
    /// and that accessor walks the entries from zero every time: the loop was
    /// O(N²) in the note's BLOCK COUNT, on a MAIN-ACTOR keystroke road.
    /// Measured on the iOS 26.2 simulator at 20,000 entries: **23.8 s for one
    /// plan** (`MobileCrossBlockEditBrainTests.thePlanStaysCheapAtTwentyThousandBlocks`
    /// carries the number), which at the author's own 100k-word bar
    /// (~1,400 paragraphs) is still ~100 ms of freeze per cross-block
    /// keystroke — a cost proportional to the document, which is the one
    /// thing P1 forbids. The fix is arithmetic, not policy: `starts[i]` is
    /// BY DEFINITION `Σ(length + 1)` over the preceding entries, which is
    /// exactly what the accessor computes, so accumulating it once answers
    /// identically (`theWalkAgreesWithTheIndexsOwnAccessor` pins that against
    /// `range(ofEntryAt:)` on an irregular tiling, empty entries included).
    /// Every CONDITION below is untouched.
    static func plan(
        replacing range: NSRange,
        with replacement: String,
        index: BlockRangeIndex,
        fanArities: [Int],
        surfaceText: (NSRange) -> String
    ) -> Edit? {
        let entries = index.entries
        var ranges: [NSRange] = []
        ranges.reserveCapacity(entries.count)
        var location = 0
        for entry in entries {
            ranges.append(NSRange(location: location, length: entry.length))
            location += entry.length + 1
        }
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = ranges[i]
            if NSIntersectionRange(range, entryRange).length > 0
                || (range.length == 0 && range.location >= entryRange.location
                    && range.location <= entryRange.upperBound) {
                touched.append(i)
            }
        }
        guard touched.count >= 2, let first = touched.first, let last = touched.last else {
            return nil
        }
        // Contiguity + no tail: the range must sit inside the touched run.
        guard range.location >= ranges[first].location,
              range.upperBound <= ranges[last].upperBound
        else { return nil }
        for i in touched {
            guard entries[i].variantID != nil, entries[i].editable else { return nil }
            // A fanned block routes to the VISIBLE-TAKE edit instead (the
            // #11a sitting ruling, 2026-07-13 — merge-then-edit stays the
            // single×single behavior: the halves JOIN only where no fan
            // hangs on the seam).
            guard i < fanArities.count, fanArities[i] == 1 else { return nil }
        }
        let firstRange = ranges[first]
        let lastRange = ranges[last]
        return Edit(
            blockIDs: touched.map { entries[$0].blockID },
            pieces: touched.map { (entries[$0].variantID!, surfaceText(ranges[$0])) },
            intraStart: max(0, range.location - firstRange.location),
            intraEndInLast: min(lastRange.length, max(0, range.upperBound - lastRange.location)),
            lastPieceLength: lastRange.length,
            replacement: replacement)
    }

    // MARK: - The compound (over Operations)

    /// The compound itself: merge the touched run left-to-right, then apply
    /// the intended edit to the merged buffer — ONE undo compound, one
    /// serialized runner body, through the one structural door. The mapped
    /// range's ends are anchored in the verbatim-preserved leading/trailing
    /// pieces (`intraStart` from the first piece's start; the trailing keep
    /// measured back from the last piece's end), so every join character
    /// the merges minted falls inside the replaced span and is deleted
    /// with it — the surface reads exactly "the selection vanished" (her
    /// principle: text that looks like basic text behaves like basic
    /// text).
    ///
    /// Hoisted with `plan` (round 2, batch 3): the merged-range arithmetic is
    /// a RULE, and a second copy of it on the phone would be exactly the
    /// drift MobileSoul §3 forbids. What stays per-platform is the face
    /// around this call — the in-flight latch, the pre-op flush, the caret
    /// write, and the words a refusal speaks.
    static func apply(_ edit: Edit, ops: Operations, undoStack: UndoStack) throws -> Landing {
        try undoStack.withCompound(label: "Merge & Edit", operations: ops) {
            // COMPARE-AND-SET first (the edit-during-await guard): a
            // no-op TakeEdit with expectedText is a pure verification —
            // any buffer that moved since planning refuses the whole
            // compound before a single row changes. (The remaining
            // verify→merge gap inside this ONE serialized runner body
            // is the recorded ms-window sync-apply residual, the W
            // drift check's class.)
            _ = try ops.editTakesAtomically(
                edit.pieces.map {
                    Operations.TakeEdit(
                        variantID: $0.variantID, newText: $0.text,
                        charDelta: 0, expectedText: $0.text)
                },
                undoLabel: "Merge & Edit")
            var mergedID = edit.blockIDs[0]
            var mergedVariantID: String?
            var mergedText = ""
            for next in edit.blockIDs.dropFirst() {
                let result = try ops.merge(mergedID, next)
                mergedID = result.block.id
                mergedVariantID = result.variant.id
                mergedText = result.variant.workingText
            }
            guard let variantID = mergedVariantID else {
                throw OperationError.blockNotFound(id: mergedID)
            }
            let merged = mergedText as NSString
            let start = edit.intraStart
            let end = merged.length - (edit.lastPieceLength - edit.intraEndInLast)
            guard start >= 0, end >= start, end <= merged.length else {
                throw OperationError.invalidCut(variantID: variantID, cut: start)
            }
            let replaced = NSRange(location: start, length: end - start)
            let newText = merged.replacingCharacters(in: replaced, with: edit.replacement)
            let cost = replaced.length + (edit.replacement as NSString).length
            try ops.autosave(variantID, text: newText, charDelta: cost)
            return Landing(
                blockID: mergedID,
                caretOffset: start + (edit.replacement as NSString).length)
        }
    }
}
