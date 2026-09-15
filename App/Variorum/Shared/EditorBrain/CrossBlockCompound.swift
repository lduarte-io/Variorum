//
//  CrossBlockCompound.swift
//  Variorum
//
//  **THE CROSS-BLOCK COMPOUND — her item 5, built to the rulings** (13u1
//  UNIT 2). Her direction, verbatim (2026-08-21): *"obvious and intuitive
//  operations like selecting a bunch of visible text and deleting should be
//  allowed - the refusing because of different blocks is more annoying than
//  it's worth"*, and the north star beside it: *"my goal is for it to not
//  feel like a headache compared to using a different editor - and denying
//  select and delete across blocks is too much of a pain for people to
//  understand."*
//
//  ONE GESTURE = ONE STRUCTURAL COMPOUND. The rules, each a ruling and each
//  named at the line that implements it:
//
//  1. **A block the selection covers WHOLE rides `deleteBlock`** — the 13j
//     Trash/tray road: every take preserved, Put back real. A FANNED middle
//     deletes whole too (her ruling, master plan item 5) — which is the one
//     place this supersedes #11a's visible-take edit, deliberately: emptying
//     the shown take of a block you selected entirely left a blank block
//     with a fan hanging on it, and "recoverable, family intact" is what she
//     ruled instead.
//  2. **A block the selection covers in PART keeps its identity** and its
//     CHOSEN take takes an ordinary buffer edit — on a fanned edge that
//     touches the chosen take only (the standing fanned-extract class).
//  3. **The two surviving ends MERGE when BOTH cut ends sit MID-PARAGRAPH**
//     (her ruling, 2026-08-21) — the standing `merge`, so both originals are
//     preserved whole with `derived_from` edges and her condition rides it:
//     *the previous blocks must be EASY TO SEE in lineage* (Block History's
//     came-from region is the mechanism). **They do NOT merge at a paragraph
//     break of EITHER kind — a block seam or an internal newline** (R-13u-2,
//     the 13u1 kickoff sitting; I4's surface paragraphs).
//  4. **A fan on either surviving end suppresses the JOIN, never the edit**
//     (#11a's standing rule, 2026-07-13: *the halves JOIN only where no fan
//     hangs on the seam*). That question is asked of the STORE at run time,
//     never of the editor's projection, which is deliberately held stale
//     while the buffer is dirty (the 13c R3-1 doctrine: a plan-time guard
//     reading a projection is an ENABLEMENT hint, never an authorization).
//  5. **The SEVENTH quiet auto-commit occasion lands first** — her own
//     insurance idea: a quiet savepoint of every take this compound will
//     EDIT, before a single row changes (`Operations.insureTakes`).
//  6. **Refusals shrink to the genuinely impossible:** a sealed note (the
//     gate refuses before any plan runs) and a LOCKED take anywhere in the
//     run — REFUSE WHOLE, naming the lock (R-13u-1). Plus the standing gap
//     fence: a block that has not ARRIVED is never tombstoned on a promise
//     the app made aloud one keystroke earlier.
//  7. **⌥⌘Z reverts the whole gesture as ONE entry**, with the exact-row
//     redo beside it — the 13e batch-4 delete compound's grammar, which is
//     the grammar the Blocks workbench's bulk bar speaks. One undo grammar,
//     one refusal grammar, never two.
//
//  **What this REPLACES.** `CrossBlockEditPlanner` (the ratified 2026-07-09
//  merge-then-edit) merged the WHOLE touched run into one block and then
//  applied the edit to the merged buffer — so a selection across five
//  paragraphs destroyed the identity of all five, including the two she
//  could still see half of. The trick that made it work is kept and is the
//  reason rule 3 is ordered the way it is (merge FIRST, with both texts
//  whole, then write the joined remainder over the merged buffer), because
//  the canon merge puts a SPACE at the join and a cross-seam delete must
//  read as "the selection vanished", never as "the selection vanished and
//  left a space".
//
//  The split of duties mirrors `BlockRangeIndex`'s J9 pair:
//    · `plan`  — pure geometry + the conditions, over an index snapshot.
//    · `apply` — the compound BODY over `Operations`, so neither platform
//      re-derives the ordering or the arithmetic. The FACE around it (the
//      in-flight latch, the pre-op flush, the caret write, the words spoken)
//      stays per-platform.
//

import Foundation
import VariorumCore

nonisolated enum CrossBlockCompound {

    // MARK: - The paragraph-break rule (R-13u-2)

    /// **R-13u-2, as ONE rule for both ends of the selection.** Her ruling
    /// at the 13u1 kickoff sitting: *"paragraph break" covers BOTH a block
    /// seam and an internal newline (I4's surface paragraphs) — the edge-join
    /// remainders merge only when both cut ends sit mid-paragraph; a cut at
    /// either kind of paragraph break suppresses the merge.*
    ///
    /// `offset` is a cut point INSIDE one block's take text, and the answer
    /// is the same question the surface would be asked: is this position
    /// adjacent to a paragraph boundary?
    ///
    /// - **The block's own edges are boundaries.** `offset == 0` sits
    ///   immediately after the SEPARATOR the eye reads as a paragraph break
    ///   (or at the document's own start); `offset == length` sits
    ///   immediately before one. That is the BLOCK SEAM half of her ruling,
    ///   and it needs no separate rule because the surface really does
    ///   carry a newline there.
    /// - **An internal newline is a boundary too** — the INTERNAL half: a
    ///   multi-paragraph block's newlines are content (I4) and paragraph
    ///   breaks all the same, so a cut immediately before or after one is at
    ///   a break.
    ///
    /// Symmetric on purpose: one function answers for the selection's start
    /// and for its end, so the two halves of her ruling cannot drift apart.
    static func cutIsAtAParagraphBreak(_ text: NSString, offset: Int) -> Bool {
        guard offset > 0, offset < text.length else { return true }
        return text.character(at: offset - 1) == 0x0A || text.character(at: offset) == 0x0A
    }

    // MARK: - The plan (pure)

    /// A surviving end: it keeps its block identity and its chosen take takes
    /// an ordinary buffer edit.
    struct Edge: Sendable, Equatable {
        let blockID: String
        let variantID: String
        /// The take's PLAN-TIME surface text — the compare-and-set input. A
        /// buffer that moved since planning refuses the whole compound,
        /// visibly (`bufferChangedSinceGesture`), before a row changes.
        let oldText: String
        /// The text after the gesture. For the LEADING end that is the kept
        /// prefix plus the replacement; for the TRAILING end, the kept
        /// suffix. In the MERGE road the two concatenate to the merged
        /// block's whole text — which is why the join character the merge
        /// mints never survives: it is inside what the gesture removed.
        let newText: String
        /// **AppSpec §10's churn for THIS end: characters removed plus
        /// characters inserted, equal weight** — computed from the CUT, at
        /// plan time, where the span is known. The rule 13u1 UNIT 1 landed
        /// on the keystroke road applies here for the same reason: the cost
        /// is the EDIT's, never a storage report's or a length difference's
        /// (a replacement of equal length is not a zero-cost edit).
        let charDelta: Int
    }

    struct Plan: Sendable, Equatable {
        /// The blocks the selection covers WHOLE, in surface order.
        let deletedBlockIDs: [String]
        /// The run's FIRST entry when it survives (covered in part, or kept
        /// because the gesture types something and the typed text belongs
        /// where the selection opened).
        let leading: Edge?
        /// The run's LAST entry when it survives.
        let trailing: Edge?
        /// **R-13u-2's answer, and geometry only.** True when BOTH ends
        /// survive and neither cut sits at a paragraph break. The FAN
        /// question is deliberately not here: it is asked of the store at
        /// run time (`apply`), where it cannot be a snapshot.
        let joinsEnds: Bool
        /// Where the caret belongs, BY IDENTITY, when nothing merges. Never
        /// a surface offset: the surface re-renders from the store between
        /// the compound and the write (the `caretLandingAfterRemoving`
        /// doctrine, same reason).
        let caretBlockID: String
        let caretOffset: Int

        /// The takes this compound will EDIT — the seventh quiet
        /// auto-commit occasion's exact input (the blocks it DELETES are not
        /// here on purpose: `deleteBlock` preserves them whole and Put back
        /// is real, so nothing on them becomes unreachable).
        var editedVariantIDs: [String] {
            [leading?.variantID, trailing?.variantID].compactMap { $0 }
        }
    }

    /// What the compound DID, for the receipt that names where every block
    /// went (her legibility mandate: *"receipts name where every block
    /// went"*).
    struct Outcome: Sendable, Equatable {
        let deletedCount: Int
        /// The ends really merged (both survived, both cuts mid-paragraph,
        /// and neither carried a fan at run time).
        let merged: Bool
        /// The geometry said join and the STORE said no: a take hangs on one
        /// of the surviving ends. The edit still landed on the chosen takes;
        /// only the join stood down (#11a).
        let joinSuppressedByFan: Bool
        let caretBlockID: String
        let caretOffset: Int
    }

    /// Routes a refused cross-block range to the compound, or answers nil so
    /// the caller's remaining roads (and finally its refusal) speak.
    ///
    /// **THE RUN, and why it is an index RANGE rather than the intersected
    /// set** (this is U-3's and U-4's fix, both from the mobile-round seam
    /// backlog): a ZERO-LENGTH entry — an empty block, or a GAP whose
    /// variant has not arrived — renders no characters, so a span can run
    /// straight past one without ever intersecting it. The old planner
    /// therefore built a piece list that skipped it and then merged ACROSS
    /// it, which the operations layer refused with `blocksNotAdjacent` — a
    /// raw enum dump on the Mac, and a refusal naming a cause that is not
    /// there. The run here is the CONTIGUOUS index range the span covers,
    /// so an interior empty block is an ordinary member (covered whole ⇒
    /// deleted) and an interior gap is caught by the fence below.
    ///
    /// The conditions, each a ruling:
    ///
    /// 1. **at least two entries in the run** — a single-entry range was
    ///    never a cross-block edit;
    /// 2. **contiguity + no tail** — the range must sit inside the run,
    ///    which also excludes any span reaching the open tail (not a block
    ///    yet; idle-mint makes it one within seconds);
    /// 3. **every entry in the run has ARRIVED** (`variantID != nil`) — the
    ///    gap fence: tombstoning a block whose text she has never seen would
    ///    delete a peer's paragraph under tombstone-wins, one keystroke
    ///    after the app said aloud that the block is read-only until it
    ///    syncs (`BlockRangeIndex.wholeBlockDeletion`'s own fence, same
    ///    doctrine, same words);
    /// 4. **every entry in the run is EDITABLE** — R-13u-1: a locked take
    ///    anywhere in the selection REFUSES THE WHOLE gesture, naming the
    ///    lock. One gesture, one answer (the bulk grammar's all-or-nothing
    ///    precedent, #93(c)). *(The J9 whole-block delete road above this
    ///    one keeps its own ruling — #33(a)'s unrestricted delete — and is
    ///    consulted first; this condition governs the gesture that EDITS.)*
    ///
    /// `surfaceText` reads the live surface for a document range (the buffer
    /// is authoritative while dirty — the compound must compare-and-set
    /// against what the author sees). **It is called at most TWICE** — once
    /// for each surviving end — never once per entry and never per document
    /// (P1: cost ∝ the edit, never the note).
    static func plan(
        replacing range: NSRange,
        with replacement: String,
        index: BlockRangeIndex,
        surfaceText: (NSRange) -> String
    ) -> Plan? {
        let entries = index.entries
        guard !entries.isEmpty else { return nil }
        let ranges = index.entryRanges()

        // THE RUN: every entry the span genuinely overlaps, plus any
        // zero-length entry sitting inside it (an empty block, a gap).
        var first: Int?
        var last: Int?
        for i in entries.indices {
            let entryRange = ranges[i]
            let overlaps = entryRange.upperBound > range.location
                && entryRange.location < range.upperBound
            let emptyInside = entries[i].length == 0
                && entryRange.location >= range.location
                && entryRange.location < range.upperBound
            guard overlaps || emptyInside else { continue }
            if first == nil { first = i }
            last = i
        }
        guard let first, let last, last > first else { return nil }

        // Contiguity + no tail: the range must sit inside the run.
        guard range.location >= ranges[first].location,
              range.upperBound <= ranges[last].upperBound
        else { return nil }

        for i in first...last {
            // 3 — the gap fence. 4 — R-13u-1's refuse-whole lock.
            guard entries[i].variantID != nil, entries[i].editable else { return nil }
        }

        let replacementLength = (replacement as NSString).length
        let firstRange = ranges[first]
        let lastRange = ranges[last]
        let intraStart = max(0, range.location - firstRange.location)
        let intraEnd = min(lastRange.length, max(0, range.upperBound - lastRange.location))

        // WHOLE vs PART. Given the contiguity guard, the first entry is
        // covered whole exactly when the span opens at its start, and the
        // last exactly when the span closes at its end; every entry between
        // them is covered whole by construction.
        let firstIsWhole = intraStart == 0
        let lastIsWhole = intraEnd == lastRange.length

        // **A gesture that TYPES keeps the first block** even where the span
        // covers it whole: the typed text belongs where the selection
        // opened, and putting it into a surviving block further down would
        // move her caret and her words. (With nothing typed, a wholly
        // covered first block is an ordinary delete — select three whole
        // paragraphs and type, and you get ONE paragraph holding what you
        // typed, which is what every editor does.) No second rule is needed
        // for the join: a wholly covered first block's cut sits at offset 0,
        // which the paragraph-break rule already answers as a break.
        let keepsFirst = !firstIsWhole || replacementLength > 0

        var leading: Edge?
        var trailing: Edge?
        var deleted: [String] = []
        for i in first...last {
            let isEdge = (i == first && keepsFirst) || (i == last && !lastIsWhole)
            guard isEdge else {
                deleted.append(entries[i].blockID)
                continue
            }
            let text = surfaceText(ranges[i]) as NSString
            // A surface that disagrees with the index about this entry's
            // length is a desync, not a plan: refuse and let the caller's
            // recovery re-render from the store, which is truth.
            guard text.length == ranges[i].length else { return nil }
            guard let variantID = entries[i].variantID else { return nil }
            if i == first {
                leading = Edge(
                    blockID: entries[i].blockID, variantID: variantID,
                    oldText: text as String,
                    newText: text.substring(to: intraStart) + replacement,
                    charDelta: (text.length - intraStart) + replacementLength)
            } else {
                trailing = Edge(
                    blockID: entries[i].blockID, variantID: variantID,
                    oldText: text as String,
                    newText: text.substring(from: intraEnd),
                    charDelta: intraEnd)
            }
        }

        // **R-13u-2, the geometry half.** Both ends must survive AND both
        // cuts must sit mid-paragraph. A cut at either kind of paragraph
        // break — the block's own edge, or an internal newline — suppresses
        // the join: she selected from a paragraph's beginning, or to a
        // paragraph's end, and meant whole paragraphs.
        var joinsEnds = false
        if let leading, let trailing {
            let head = leading.oldText as NSString
            let tail = trailing.oldText as NSString
            joinsEnds = !cutIsAtAParagraphBreak(head, offset: intraStart)
                && !cutIsAtAParagraphBreak(tail, offset: intraEnd)
        }

        // The caret, by identity, for every road but the merge (which can
        // only name its block once the merge has minted it).
        let caret: (blockID: String, offset: Int)
        if let leading {
            caret = (leading.blockID, intraStart + replacementLength)
        } else if let trailing {
            caret = (trailing.blockID, 0)
        } else {
            caret = index.caretLandingAfterRemoving(deleted)
        }

        return Plan(
            deletedBlockIDs: deleted,
            leading: leading, trailing: trailing,
            joinsEnds: joinsEnds,
            caretBlockID: caret.blockID, caretOffset: caret.offset)
    }

    // MARK: - The compound (over Operations)

    /// The compound itself — ONE undo entry, the 13e batch-4 grammar the
    /// Blocks workbench's bulk bar already speaks. The order is the whole
    /// design and every step is load-bearing:
    ///
    /// 1. **INSURE** the takes about to be edited (the seventh quiet
    ///    auto-commit occasion, her own idea). First, so that a compound
    ///    that then refuses has still left the savepoint behind — insurance
    ///    that a failure can cancel is not insurance.
    /// 2. **COMPARE-AND-SET** the surviving ends against their plan-time
    ///    text, as a no-op `editTakesAtomically` — a pure verification that
    ///    writes nothing and refuses the WHOLE compound if a buffer moved
    ///    since planning. (The remaining verify→act gap inside this ONE
    ///    serialized runner body is the recorded ms-window sync-apply
    ///    residual, the W drift check's class.)
    /// 3. **DELETE** the wholly covered blocks — `deleteBlock`, the standing
    ///    unrestricted door (#33(a)), which is also what makes the two ends
    ///    adjacent for step 5.
    /// 4. **EDIT** the surviving ends when they will NOT merge.
    /// 5. **MERGE, then write** when they will: the merge copies both texts
    ///    whole (so both originals land in lineage with `derived_from` edges
    ///    — her easy-to-see condition), and the joined remainder is written
    ///    over the merged buffer in one autosave, which is what deletes the
    ///    join character the canon merge minted.
    ///
    /// `liveActiveTakeCount` answers the FAN question from the STORE at run
    /// time — U-1's correctness half, stated as a law: *never authorize from
    /// stale state.* A fan arriving during a typing burst is invisible to the
    /// editor's projection, so the projection may enable a road and never
    /// authorize one.
    static func apply(
        _ plan: Plan,
        ops: Operations,
        undoStack: UndoStack,
        liveActiveTakeCount: (String) throws -> Int
    ) throws -> Outcome {
        // 1 — the seventh occasion, OUTSIDE the compound deliberately:
        // commits are append-only and register no undo entry, and insurance
        // that unwinds with the act it was insuring against protects
        // nothing.
        try ops.insureTakes(plan.editedVariantIDs)

        let joins: Bool
        if plan.joinsEnds, let leading = plan.leading, let trailing = plan.trailing {
            joins = try liveActiveTakeCount(leading.blockID) == 1
                && liveActiveTakeCount(trailing.blockID) == 1
        } else {
            joins = false
        }
        let joinSuppressedByFan = plan.joinsEnds && !joins

        return try undoStack.withCompound(label: Self.undoLabel, operations: ops) {
            // 2 — the compare-and-set, before a single row changes.
            let ends = [plan.leading, plan.trailing].compactMap { $0 }
            if !ends.isEmpty {
                _ = try ops.editTakesAtomically(
                    ends.map {
                        Operations.TakeEdit(
                            variantID: $0.variantID, newText: $0.oldText,
                            charDelta: 0, expectedText: $0.oldText)
                    },
                    undoLabel: Self.undoLabel)
            }

            // 3 — the wholly covered blocks take the Trash/tray road.
            for blockID in plan.deletedBlockIDs {
                try ops.deleteBlock(blockID)
            }

            guard joins, let leading = plan.leading, let trailing = plan.trailing else {
                // 4 — two blocks, two ordinary buffer edits (a fanned end
                // touches its chosen take only).
                let edits = ends.map {
                    Operations.TakeEdit(
                        variantID: $0.variantID, newText: $0.newText,
                        charDelta: $0.charDelta, expectedText: $0.oldText)
                }
                if !edits.isEmpty {
                    _ = try ops.editTakesAtomically(edits, undoLabel: Self.undoLabel)
                }
                return Outcome(
                    deletedCount: plan.deletedBlockIDs.count,
                    merged: false, joinSuppressedByFan: joinSuppressedByFan,
                    caretBlockID: plan.caretBlockID, caretOffset: plan.caretOffset)
            }

            // 5 — the ends join. Merge FIRST with both texts whole: the
            // originals are preserved and edged, and the join character the
            // canon merge mints falls inside what the gesture removed.
            let result = try ops.merge(leading.blockID, trailing.blockID)
            let joined = leading.newText + trailing.newText
            // The merge itself stamps touch without churn (restructuring must
            // never reshuffle the meaningful sort, AppSpec §9); the GESTURE's
            // own cost rides this one write — both ends' cuts, summed.
            try ops.autosave(
                result.variant.id, text: joined,
                charDelta: leading.charDelta + trailing.charDelta)
            return Outcome(
                deletedCount: plan.deletedBlockIDs.count,
                merged: true, joinSuppressedByFan: false,
                caretBlockID: result.block.id,
                caretOffset: (leading.newText as NSString).length)
        }
    }

    /// **The undo entry's ONE label**, so ⌥⌘Z's menu says the same thing
    /// wherever the gesture was made — and so the Blocks workbench's bulk
    /// bar and this keystroke road speak one grammar, never two.
    static let undoLabel = "Edit Across Blocks"

}
