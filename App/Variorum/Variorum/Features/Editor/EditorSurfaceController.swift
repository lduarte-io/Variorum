//
//  EditorSurfaceController.swift
//  Variorum
//
//  13b Stage 3, N10 — the one-seam move both Stage 1 closeouts recorded:
//  EditorViewModel's gesture-execution band (`applyStructural`, the
//  boundary-fluidity compounds, the W ceremony state machine,
//  `runStructural`) and the projection EXECUTORS (`renderFull` /
//  `applyDifferential`) move TOGETHER into this editor-feature controller.
//  This is the store→surface REWRITE DOOR: everything that rewrites the
//  full-document TK2 surface from store state funnels through here —
//  projections and structural results alike.
//
//  Composition (the recorded seam, unchanged in meaning):
//  - `EditorViewModel` remains the STORAGE OWNER: composition,
//    crystallization (verbatim), decoration/badge geometry, and the
//    `viewText`/`programmaticReplace`/`setBlockAttribute` plumbing stay
//    there (the 1a call — the storage owner keeps its plumbing). This
//    controller reaches the storage ONLY through the model's narrow seam
//    primitives (`setSurfaceContent`, `applySeamEdit`, `adoptRewrite`,
//    `holdTailIdleClock`, `awaitMintSettle`) and its read surface.
//  - `EditorProjectionEngine` (1a) still holds the projection DECISION
//    (`EditorProjectionPolicy`) and the ledger; the model's
//    `applyProjection` executes verdicts by calling the executors here.
//  - Feature-side by design, NEVER the shared Registry layer:
//    storage-coupled code stays with the feature (the Stage 1b judgment
//    call #1 / Stage 1 closeout seam, built).
//
//  Behavior parity is the batch contract: every body below is the
//  EditorViewModel original verbatim, modulo `model.` receiver prefixes
//  and the seam primitives; every existing pin runs unmodified through
//  the model's forwarding surface.
//
//  Lifetime: the model owns this controller strongly; the back-reference
//  is `unowned`. Every entry point is invoked through the model's
//  forwarders, whose spawning Tasks capture the MODEL strongly (the
//  pre-move shape), so the model — and therefore this controller —
//  outlives every flight; internal deferred tasks keep the original
//  `[weak self]` posture (a dead controller means a dead model, exactly
//  the cases that no-opped before).
//

import AppKit
import Foundation
import VariorumCore

@MainActor
@Observable
final class EditorSurfaceController {
    @ObservationIgnored unowned let model: EditorViewModel

    init(model: EditorViewModel) {
        self.model = model
    }

    // MARK: - Moved observable state (forwarded by the model)

    /// The W ceremony's state machine — LIFTED OUT at 13d Batch 3 (A9) so
    /// a takes board can mount the same sheet; this controller is one of
    /// its two hosts. Everything below forwards, so every view binding and
    /// pin reads exactly as it did.
    @ObservationIgnored private(set) lazy var ceremony = DivideWCeremony(host: self)

    /// A divide invoked on a fanned block routes here: the W ceremony's ONE
    /// sheet (contract item 3). Non-nil = the sheet is up; the live editor
    /// is untouched for the ceremony's whole duration; cancel sets nil with
    /// no rows touched; confirm funnels back through the structural door.
    var divideWCeremony: DivideWCeremonyState? {
        get { ceremony.state }
        set { ceremony.state = newValue }
    }

    var crossBlockMakeConfirm: CrossBlockMakeState?

    /// One structural gesture lands at a time (Phase 9): the door is busy
    /// from invoke to rewrite, and a second invoke refuses visibly.
    /// Readable so the review-round pins can stage mid-flight interleavings.
    @ObservationIgnored private(set) var structuralInFlight = false

    /// Times the differential-apply DEBUG oracle found the surface diverged
    /// from the store projection — the soak asserts ZERO (the author-
    /// directed proof that the differential path lands safely).
    @ObservationIgnored private(set) var differentialOracleMisses = 0

    // The W ceremony's state types moved to `DivideWCeremony` (13d Batch
    // 3); typealiases keep every `EditorSurfaceController.X` and
    // `EditorViewModel.X` reference — views and pins — unchanged.
    typealias DivideWCeremonyState = DivideWCeremony.State
    typealias WTake = DivideWCeremony.WTake

    /// Forward (13d Batch 3): the legal-cut rule lives with the ceremony
    /// now; `WCutPlacementTests` addresses it here.
    nonisolated static func legalCutPositions(of text: String) -> [Int] {
        DivideWCeremony.legalCutPositions(of: text)
    }

    // MARK: - Projection → surface (the executors; the DECISION lives in
    // EditorProjectionPolicy and the model's applyProjection executes it)

    /// Same block sequence, different content (choose-variant, an external
    /// edit, restoreCommit): replace only the changed slots, last-to-first
    /// so earlier ranges stay valid.
    ///
    /// **Cost, stated honestly (13u1 UNIT 1 — P17).** The STORAGE WRITES are
    /// ∝ the changed blocks, which is what this comment used to claim for
    /// the whole method; the COMPARISON is ∝ the note's text, because
    /// deciding which slots changed means reading every slot's surface text.
    /// What was wrong beyond the wording was the tiling walk: this asked
    /// `model.index.range(ofEntryAt: i)` once per slot and that accessor
    /// walks the entries from zero, so the loop cost Σi ≈ N²/2 in the BLOCK
    /// COUNT on top of the linear term — a quadratic on the road every take
    /// switch, `restoreCommit` and sync landing takes. Measured at 8,000
    /// blocks, mounted: **4.41 s → 56.6 ms** (the 13u1 plan's UNIT 1 RECORD
    /// measurement table — the authority for these numbers; the ladder's
    /// round 1 caught an interim pair here citing that table for values it
    /// does not hold). The tiling is now read ONCE through the shared
    /// accumulating walk.
    ///
    /// **The ranges are computed BEFORE the loop and stay correct:** the
    /// walk descends, and replacing slot `j` changes the lengths of entries
    /// at or after `j` only — never the prefix sum of an entry below it,
    /// which is all `ranges[i]` for `i < j` depends on. (That is the same
    /// reason the loop descends at all.)
    func applyDifferential(_ new: [Queries.RenderedBlock]) {
        var edited = false
        let ranges = model.index.entryRanges()
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            // No bounds guard, deliberately: `.differential` is only chosen
            // when the block SEQUENCE matches, so `new.count ==
            // entries.count` by construction, and a violation should stay
            // the loud trap the accessor's own precondition always was
            // rather than becoming a silent skip.
            let range = ranges[i]
            if model.viewText(range) != newText {
                model.programmaticReplace(range, with: newText, blockID: new[i].blockID)
                edited = true
            }
        }
        model.adoptRewrite(
            index: BlockRangeIndex(
                slots: new, tail: model.hasOpenTail ? model.tailText : nil),
            slots: new, tailText: nil)
        if edited {
            // Undo entries recorded against the old surface would replay at
            // stale offsets — across-block corruption risk; drop them.
            model.textView?.undoManager?.removeAllActions()
        }
        model.updateCaretContext()
        model.refreshBadges()
    }

    func renderFull(_ new: [Queries.RenderedBlock], preserveTail: Bool) {
        guard let textView = model.textView, textView.textStorage != nil else { return }
        let tail: String?
        if preserveTail, model.hasOpenTail {
            tail = model.tailText
        } else {
            // No local tail (or nothing worth preserving): an empty post is
            // all tail by construction; a post with blocks has none.
            tail = new.isEmpty ? "" : nil
        }
        // 18l U0b (KnownIssues row 87): the reading position WITH ITS PLACE.
        // This restore replayed only the line, through the jump's "line at
        // the viewport TOP" — so a page resting in its top air lost it (her
        // backspace on an empty last block: A7's carve lands here, 24 pt, the
        // container's inset exactly) and a wheel-scrolled page snapped by the
        // edge's offset inside its line. A full re-render changed nothing
        // above the anchor that the offset does not carry: the line goes back
        // exactly where it was (`ReadingAnchor.exactLandingInset`).
        let anchor = model.readingAnchor()
        // The caret BY IDENTITY across the rewrite (the Act 10 correction
        // round, rows 39/49): replacing the storage wholesale parks the
        // insertion point at the document's END, and a full render that
        // arrives after the arrival's landing — the theme's chrome settling
        // a beat later, a forced re-render — used to carry her caret to the
        // last block with nothing re-landing it (row 49's "block 262/262").
        // The scroll anchor was already preserved; the caret now is too.
        let caret = model.caretIdentity()
        let (attributed, newIndex) = EditorDocument.materialize(new, tail: tail)
        model.setSurfaceContent(attributed)
        model.adoptRewrite(index: newIndex, slots: new, tailText: tail ?? "")
        if let caret,
           let i = model.index.entries.firstIndex(where: { $0.blockID == caret.blockID }) {
            let range = model.index.range(ofEntryAt: i)
            textView.setSelectedRange(NSRange(
                location: range.location + min(caret.offset, range.length), length: 0))
        }
        textView.undoManager?.removeAllActions()
        if let anchor {
            JumpPrimitive.jump(
                toOffset: min(anchor.offset, max(0, model.index.documentLength)),
                textView: textView, scrollView: model.scrollView,
                landingInset: anchor.exactLandingInset)
        } else if let saved = model.session.editorRouter.scrollPlaces[model.postID] {
            // 18l U0c: the page she left, WITH ITS PLACE — the line exactly
            // where it sat (`exactLandingInset`), so a re-open (her R-18l-1:
            // "restores where you were") keeps a page's top air and a
            // wheel-scrolled page's cut; an offset-only anchor (inset 0) lands
            // exactly as it always did.
            if model.loaded {
                // A warm re-render whose live anchor came back nil (the page
                // scrolled into the typewriter room): the frame is honest —
                // restore now, as always.
                JumpPrimitive.jump(
                    toOffset: min(saved.offset, max(0, model.index.documentLength)),
                    textView: textView, scrollView: model.scrollView,
                    landingInset: saved.exactLandingInset)
            } else {
                // The COLD mount (17o batch b's ladder, round 2 — RAISE-M1):
                // the storage was just replaced and the text view's frame is
                // still the pre-fill height, so a jump here clamps at
                // `maxScroll` ≈ a couple of dozen points and the anchor is
                // never restored — every mode round trip re-topped the page
                // on the caret's block. Park it for the N14 settle hop, the
                // first moment the frame is honest (the reveal's own road).
                model.parkAnchorRestore(saved.offset, landingInset: saved.exactLandingInset)
            }
        }
        model.updateCaretContext()
        model.refreshBadges()
    }

    // MARK: - Structural gestures (Phase 9)

    /// Plans against the CURRENT selection and applies — the invoke re-plans
    /// even when a menu's enablement said yes (enablement can go stale under
    /// a remote seal/lock; the refusal then surfaces here, never silently).
    ///
    /// 13j J4/J4b: `ceremony` is the DOOR she used, not a shape the planner
    /// answers — the plan is identical either way (the planner is pure over
    /// the surface and says only "this block/pair carries a fan"); what
    /// differs is what the fanned branch DOES. Defaulted so every existing
    /// door and pin reads unchanged.
    func invokeGesture(
        _ command: StructuralGesturePlanner.Command, ceremony: Bool = false
    ) async {
        guard let textView = model.textView else { return }
        let plan = StructuralGesturePlanner.plan(
            command, selection: textView.selectedRange(), world: model.gestureWorld())
        await applyStructural(plan, ceremony: ceremony)
    }

    /// THE one door for structural changes to the surface (plan ground
    /// rule): every gesture funnels through here; nothing else rewrites the
    /// editor for a structural result. The store leads — the surface is
    /// never pre-written optimistically; the rewrite renders the operation's
    /// known outcome, and the observation's later arrival is our own echo
    /// (`surfaceMatches` skips it).
    func applyStructural(
        _ plan: StructuralGesturePlanner.Plan, ceremony: Bool = false
    ) async {
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return
        }
        switch plan {
        case .refusal(let refusal):
            model.refuseFeedback(RefusalCopy.message(for: refusal))

        case .divideW(let i, let blockID, let activeCut):
            if ceremony {
                // Contract item 3: the W ceremony is ONE sheet; the live
                // editor is untouched for its whole duration. Opening
                // touches no rows — confirm funnels back through this door.
                // 13j J4: this is now the ⌥⌘⇧D door's road, not ⌘⇧D's.
                await openDivideWCeremony(blockID: blockID, activeCut: activeCut)
            } else {
                // **THE DEFAULT — KEEP ON TOP** (her ruling U-2,
                // 2026-09-06, superseding 13j J4's duplicate shape): the
                // displayed take is cut across B and C and every other take
                // rides WHOLE onto the top block.
                await runKeepOnTopDivide(
                    entryIndex: i, blockID: blockID, activeCut: activeCut)
            }

        case .divide(let i, let blockID, let cut):
            guard !ceremony else {
                // The ceremony door on an UNFANNED block: there is no fan to
                // place cuts in, so the door speaks its real reason and names
                // the one that acts (P-2 — a real refusal, not a lecture).
                model.refuseFeedback(FannedDefaultsCopy.divideCeremonyNeedsAFan)
                return
            }
            await runPlainDivide(entryIndex: i, blockID: blockID, cut: cut)

        case .extract(let i, let blockID, let span, let edge, let otherTakes):
            let base = model.index.range(ofEntryAt: i).location
            visiblySnap(NSRange(location: base + span.lowerBound, length: span.count))
            let landed = await runStructural { ops in
                let result = try ops.extract(blockID, span: span)
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: 0,  // the extracted block's start
                    seam: .extract(entryIndex: i, edge: edge,
                                   sourceID: blockID, extractedID: result.block.id))
            }
            if landed, otherTakes > 0 {
                // Contract item 8: passive, self-dismissing, never modal.
                model.showTransientReceipt(
                    otherTakes == 1
                        ? "This block has 1 other take — it keeps this span."
                        : "This block has \(otherTakes) other takes — they keep this span.")
            }

        case .makeBlock(let i, let blockID, let span):
            // Contract item 5: two divides as ONE undoable action —
            // UndoStack.withCompound folds their inverses into one entry
            // (atomic on partial failure), inside one serialized runner body.
            let entryRange = model.index.range(ofEntryAt: i)
            visiblySnap(NSRange(location: entryRange.location + span.lowerBound, length: span.count))
            let entryLength = entryRange.length
            let stack = model.session.undoStack
            _ = await runStructural { ops in
                try stack.withCompound(label: "Make Block", operations: ops) {
                    let first = try ops.divide(blockID, cut: span.lowerBound)
                    // The span's end, mapped into the successor: the
                    // successor lost `span.lowerBound` units plus whatever
                    // leading whitespace the seam trim dropped — derived
                    // from the op's actual output, never re-guessed.
                    let dropped = (entryLength - span.lowerBound)
                        - first.variant.workingText.utf16.count
                    let second = try ops.divide(first.block.id, cut: span.count - dropped)
                    return StructuralOutcome(
                        caretBlockID: first.block.id, caretOffset: 0,  // the middle block's start
                        seam: .makeBlock(entryIndex: i, sourceID: blockID,
                                         middleID: first.block.id, suffixID: second.block.id))
                }
            }

        case .merge(let leadingIndex, let trailingIndex, let leadingID, let trailingID):
            // The ceremony threshold (13b 4B — S4-23 ruling 4): ANY fan on
            // either side opens the merge ceremony, PRE-PAIRED with the two
            // rendered takes so ⏎ reproduces the instant outcome — exactly,
            // when no session join memory is set (a fresh session); with a
            // memory set the pre-pair joins by the MEMORY, not canon
            // (ruling 3's letter). The silent-vanish experience cannot
            // recur either way. Unfanned
            // pairs keep the instant path byte-unchanged. (Neither door
            // AUTHORIZES from the slots' arity any more: ⌘⇧M's unfanned
            // branch asks the store (18k C5, P27) and ⌥⌘⇧M's choice is the
            // ceremony open's own store read (18o U3, KnownIssues row 79);
            // the arity survives only as the fanned default's hint, whose
            // road re-reads truth and falls back.)
            //
            // **13j J4b — THE FLIPPED DEFAULT** (her 2026-08-09 ruling): the
            // threshold still forks on the fan, but the fanned side no longer
            // opens the ceremony by default — it CARRIES ALL (one pairing of
            // the two displayed takes + every other active take whole,
            // composed from this app's own `mergeCeremony`). The ceremony is
            // ⌥⌘⇧M's road now, and behind that door it is byte-unchanged.
            let leadingArity = leadingIndex < model.slots.count
                ? model.slots[leadingIndex].activeVariantCount : 1
            let trailingArity = trailingIndex < model.slots.count
                ? model.slots[trailingIndex].activeVariantCount : 1
            if ceremony {
                // **18o U3 (KnownIssues row 79) — the ceremony door's CHOICE is
                // the STORE's, never `slots`'** (P27's rule, the other branch's
                // turn). The slots are frozen for a typing burst, so a gate on
                // them refused "one take each" over a take born mid-burst, and
                // passed a pair whose fan had been archived meanwhile on to an
                // open that then merged INSTANTLY. The open reads the true fans
                // after its flush and decides both ways — the sheet, or the
                // ruled refusal — so there is ONE read for this one question
                // (the run door's shape, `openMergeRunChoice`), and the press
                // no longer reaches `runStructural` at all.
                await openMergeCeremony(leadingID: leadingID, trailingID: trailingID)
            } else if leadingArity > 1 || trailingArity > 1 {
                await runCarryAllMerge(leadingID: leadingID, trailingID: trailingID)
            } else {
                // **18k C5 (17e P27) — "unfanned" is AUTHORIZED BY THE STORE,
                // never by `slots`.** The projection is frozen while the
                // editor is busy, so a take born on either block mid-burst
                // reads as no fan here — and the instant merge below never
                // reads the store (`ops.merge` has no fan fence), so it would
                // release that take to lineage unsaid. The slots stay the
                // cheap hint for the fanned branch above (whose road re-reads
                // truth and falls back); THIS branch asks the store, the seam
                // keystroke's own shape (`runSeamMerge`). (The ceremony branch
                // above reads the store too since 18o U3 — row 79.)
                let fans: (leading: [Variant], trailing: [Variant])
                do {
                    fans = try await liveActiveFans(leadingID, trailingID)
                } catch {
                    model.showOperationError(error)
                    return
                }
                if fans.leading.count > 1 || fans.trailing.count > 1 {
                    await runCarryAllMerge(leadingID: leadingID, trailingID: trailingID)
                } else {
                    await runInstantMerge(leadingID: leadingID, trailingID: trailingID)
                }
            }

        case .makeBlockAcrossBlocks(let indices, let blockIDs, let startCut, let endCut):
            // Phase 11, A9 (the guided flow — the v1 refusal becomes a
            // CONFIRM, never a silent act): opening touches no rows; the
            // confirm funnels into `confirmCrossBlockMakeBlock`. The edge
            // blocks' rendered texts are snapshotted NOW — the confirm
            // CASes the divided edges against them (round 1, MINOR 5).
            func edgeSnapshot(_ i: Int) -> CrossBlockMakeState.EdgeSnapshot? {
                guard i < model.index.entries.count,
                      let variantID = model.index.entries[i].variantID else { return nil }
                return .init(variantID: variantID, text: model.viewText(model.index.range(ofEntryAt: i)))
            }
            crossBlockMakeConfirm = CrossBlockMakeState(
                entryIndices: indices, blockIDs: blockIDs,
                startCut: startCut, endCut: endCut,
                firstEdge: edgeSnapshot(indices.lowerBound),
                lastEdge: edgeSnapshot(indices.upperBound))

        case .mergeChain(_, let blockIDs):
            guard !ceremony else {
                // **U-16, 2026-09-07:** *"if you're merging several notes
                // together you should be given the choice of bringing every
                // take or only the currently shown ones, but i don't want a
                // super complex ceremony for merging multiple blocks
                // together."* The pairing ceremony IS pairwise by
                // construction (S4-23) and stays so; what retires is the
                // refusal that used to stand here — the door asks the two
                // questions instead of saying no.
                await openMergeRunChoice(blockIDs: blockIDs)
                return
            }
            await runMergeChain(blockIDs: blockIDs)
        }
    }

    /// #11c: how many OTHER takes the merged sources carry — they stay
    /// with the released blocks in lineage (merge's standing semantics),
    /// and the gesture says so instead of silently folding a fan away.
    private func mergedAwayTakes(_ entryIndices: [Int]) -> Int {
        entryIndices.reduce(0) { total, i in
            guard i < model.slots.count else { return total }
            return total + max(0, model.slots[i].activeVariantCount - 1)
        }
    }

    private func speakAboutMergedFans(_ otherTakes: Int) {
        guard otherTakes > 0 else { return }
        // 13b 3F (old-3H's canon-preserving half, N17c): the toast NAMES
        // the lineage road — the 3A drive proved the road exists but
        // nothing pointed at it ("in lineage" named no place). Copy only;
        // merge's semantics are canon.
        model.showTransientReceipt(
            otherTakes == 1
                ? "Merged the visible takes — 1 other take stays with the released block "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes)."
                : "Merged the visible takes — \(otherTakes) other takes stay with the released blocks "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes).")
    }

    /// The entry of `blockID` on the CURRENT surface, or nil when it is no
    /// longer tiled there. **18f ladder round 1, R1-2 (fable-reviewer):** the
    /// three merge roads read their lengths and seams through this, by block
    /// id, AT ACT TIME — never from an index a caller captured earlier.
    /// `runPlainDivide`'s rule ("an index taken before a suspension can
    /// address a re-tiled surface"), applied to the merge family: U-5's row
    /// made these roads the CONFIRM of a sheet that can sit open while the
    /// projection re-renders under it (a sync apply; a menu chord that stays
    /// live beneath a window-modal sheet), and `runInstantMerge` subscripted
    /// the projection with the open-time index unguarded — a trap on a
    /// two-block note, a mis-landed caret and a refused seam elsewhere.
    private func entryIndex(of blockID: String) -> Int? {
        model.index.entries.firstIndex { $0.blockID == blockID }
    }

    /// The everyday instant merge — today's exact `.merge` body, byte-
    /// unchanged (13b 4B moved it behind the ceremony threshold; unfanned
    /// pairs and the stale-projection fallthrough land here). Entries are
    /// resolved by id here (R1-2); a block gone from the surface refuses in
    /// the refresh road's own voice and touches nothing.
    ///
    /// **`joining` is R-13u4-3's classification, at the one body two
    /// classes share** (13u4 UNIT E3). Every DOOR that lands here takes the
    /// default — the rendering join. The SEAM KEYSTROKE (`runSeamMerge`)
    /// passes `.deleteKeystroke` and keeps the shipped join byte-unchanged,
    /// because a backspace that put back the newline it just removed would
    /// visibly do nothing. Two doors on one act share the body or they
    /// drift (13e/13j's standing rule), so the difference is an argument
    /// rather than a second copy of this function.
    @discardableResult
    private func runInstantMerge(
        leadingID: String, trailingID: String, joining: MergeJoinRule = .door
    ) async -> Bool {
        guard let leadingIndex = entryIndex(of: leadingID),
              let trailingIndex = entryIndex(of: trailingID)
        else {
            model.refuse(FannedDefaultsCopy.blocksChangedMerge)
            return false
        }
        let trailingLength = model.index.entries[trailingIndex].length
        // #11c (the sitting ruling, 2026-07-13): merge on fanned blocks
        // SPEAKS about what it does to the fan.
        let otherTakes = mergedAwayTakes([leadingIndex, trailingIndex])
        let landed = await runStructural { ops in
            let result = try ops.merge(leadingID, trailingID, joining: joining)
            // Caret at the join: right where the trailing half begins.
            let join = max(0, result.variant.workingText.utf16.count - trailingLength)
            return StructuralOutcome(
                caretBlockID: result.block.id, caretOffset: join,
                seam: .merge(leadingIndex: leadingIndex, mergedID: result.block.id))
        }
        if landed { speakAboutMergedFans(otherTakes) }
        return landed
    }

    // MARK: - 13j J4 / J4b — the FANNED DEFAULTS (her Q-M2 and 2026-08-09
    // rulings). Divide duplicates, merge carries all; both ceremonies live
    // behind ⌥⌘⇧D / ⌥⌘⇧M, byte-unchanged.

    /// The everyday in-place divide — the pre-13j `.divide` body verbatim,
    /// extracted so the flipped road's stale-projection fallback runs THE
    /// SAME code rather than a copy of it (the `deleteSelectedBlocks` /
    /// `planWholeBlockDeletion` precedent from 13e/13j batch 1: two doors on
    /// one act share the body or they drift).
    private func runPlainDivide(entryIndex i: Int, blockID: String, cut: Int) async {
        // Snap-and-proceed, visibly (contract item 2): the caret lands on the
        // snapped cut as part of the one invoke. Re-resolved by BLOCK ID
        // because the fallback road reaches here after a flush, and an index
        // taken before a suspension can address a re-tiled surface.
        if let j = model.index.entries.firstIndex(where: { $0.blockID == blockID }) {
            visiblySnap(NSRange(
                location: model.index.range(ofEntryAt: j).location + cut, length: 0))
        }
        _ = await runStructural { ops in
            let result = try ops.divide(blockID, cut: cut)
            return StructuralOutcome(
                caretBlockID: result.block.id, caretOffset: 0,  // the successor's start
                seam: .divide(entryIndex: i, sourceID: blockID, successorID: result.block.id))
        }
    }

    /// **U-2's road: the keep-on-top divide** (2026-09-06 — it SUPERSEDES
    /// J4's duplicate-shape road here). The displayed take's halves seed B
    /// and C; every OTHER active take rides WHOLE onto B — the top block,
    /// the one she divided; A is released preserved. `Operations.divideW`
    /// does all of that through S4-22's parking rule, and
    /// `KeepOnTopDivide.compose` is the one arrangement of its arguments
    /// that says so — this is the routing, the receipt and the guards.
    ///
    /// The undo entry is wrapped in a `withCompound(label: "Divide")` for
    /// ONE reason: divideW's own entry is labelled "Divide choosing takes"
    /// (the summoned door's name — correct while that door is its only
    /// unwrapped caller), and the Edit menu must keep reading **Undo Divide**
    /// for the everyday gesture. One leg in, one entry out — the compound's inverse
    /// and its exact-row redo are the op's own.
    ///
    /// **The fork is read from the STORE, never from the projection** (the
    /// 13d ruled discipline; `openMergeCeremony`'s own words: "the threshold
    /// rule reads truth, not the projection"). It matters more here than it
    /// ever did for the ceremony: the ceremony's stale-projection fallback
    /// merely showed a sheet, while acting on a stale "fanned" would RELEASE
    /// A instead of keeping it — a different outcome, not a different view.
    private func runKeepOnTopDivide(
        entryIndex i: Int, blockID: String, activeCut: Int?
    ) async {
        guard let cut = activeCut else {
            // A one-word take has no interior cut. Exactly what an unfanned
            // block answers for the same text (the planner's own
            // `.nothingToDo`), plus the door that CAN act on it: parking a
            // whole take at one end is the ceremony's vocabulary (S4-22).
            model.refuseFeedback(RefusalCopy.message(for: .nothingToDo)
                + " Divide choosing takes (⌥⌘⇧D) can send a whole take to one side.")
            return
        }
        // The take she is looking at: Write's full-document editor shows the
        // CHOSEN take, so the entry's own variant IS the displayed one.
        let displayedID = model.index.entries.first { $0.blockID == blockID }?.variantID
        // Flush FIRST — the op validates against the store and the cut was
        // placed against what she sees; after the flush those are the same
        // text. `runStructural` flushes again below (idempotent when clean).
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let fan: [Variant]
        do {
            fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active }
            }
        } catch {
            model.showOperationError(error)
            return
        }
        guard fan.count > 1 else {
            // The projection said fanned; the store says otherwise. The
            // ordinary in-place divide is the right act (A keeps its
            // identity) — `runCarryAllMerge`'s own fallback, same shape (the
            // DEFAULT doors fall back to the plain act; the ceremony doors
            // refuse instead — 18o U3, row 79).
            // The plain road edits a buffer, so a locked take refuses here
            // exactly as the planner would have refused it.
            let entry = model.index.entries.first { $0.blockID == blockID }
            guard entry?.editable != false else {
                model.refuseFeedback(RefusalCopy.message(for: .lockedVariant))
                return
            }
            await runPlainDivide(entryIndex: i, blockID: blockID, cut: cut)
            return
        }
        guard let composition = KeepOnTopDivide.compose(
            displayedID: displayedID, cut: cut, fan: fan)
        else {
            // The F-3 guard (13d cold review), now the composition's own:
            // the take the caret was in has vanished from the live fan. A
            // fallback would divide a take she was never in, at an offset
            // from the one that died.
            model.refuse(FannedDefaultsCopy.takesChangedDivide)
            return
        }
        if let j = model.index.entries.firstIndex(where: { $0.blockID == blockID }) {
            visiblySnap(NSRange(
                location: model.index.range(ofEntryAt: j).location + cut, length: 0))
        }
        let stack = model.session.undoStack
        _ = await runStructural { ops in
            let result = try stack.withCompound(label: "Divide", operations: ops) {
                try ops.divideW(
                    blockID, cuts: composition.cuts,
                    displayedVariantID: composition.displayedID)
            }
            // seam nil: A vanishes and TWO fresh blocks stand where it stood,
            // which no seam vocabulary describes — the ceremonial full
            // re-render, exactly as the W confirm takes.
            return StructuralOutcome(
                caretBlockID: result.second.block.id, caretOffset: 0,
                seam: nil,
                // The count comes from the op's OWN result inside the flight
                // (13e batch 3's receipt rule), never from a projection read
                // taken beside the write: B's fan is the split first half
                // plus every take that rode whole.
                note: FannedDefaultsCopy.divided(
                    kept: max(0, result.first.variants.count - 1),
                    stayedBehind: composition.unparkable.count))
        }
    }

    // MARK: - "Make every newline a block" (18c batch 3 — her U-6)

    /// **The NOTE's repair** (her U-6: *"a 'make all newlines blocks'
    /// button"*). Every block of the note through `splitBlockAtNewlines`,
    /// inside ONE `withCompound` — so the whole repair is ONE ⌥⌘Z, which is
    /// the point of a button that replaces *"a lot of divides to run"*.
    ///
    /// The order comes from the STORE, not from the index (the 13d
    /// discipline: a projection names targets, it never authorizes); each
    /// block is addressed by ID, so the blocks the earlier legs mint cannot
    /// disturb the later ones. `seam: nil` — many blocks vanish and many
    /// stand where they stood, which no seam vocabulary describes; the
    /// ceremonial full re-render is exactly the W confirm's road, and this
    /// is a summoned menu act, not a keystroke.
    ///
    /// The caret lands in the FIRST successor of the block it was in, so she
    /// stays where she was reading.
    func splitEveryNewlineIntoBlocks() async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let slots: [Queries.RenderedBlock]
        do {
            slots = try await model.session.database.read { [postID = model.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
        } catch {
            model.showOperationError(error)
            return
        }
        // A real refusal rather than a flight that rewrites the surface to
        // say nothing happened (P-2). The store still decides — the op
        // re-reads every block and no-ops on its own — this only keeps the
        // door from disabling the editor for a repair with nothing to do.
        guard slots.contains(where: { !NewlineSplitting.breaks(in: $0.text ?? "").isEmpty })
        else {
            model.refuseFeedback(SplitAtNewlinesCopy.noteAlreadyWhole)
            return
        }
        let order = slots.map(\.blockID)
        let caretBlockID = model.caretBlockID
        let stack = model.session.undoStack
        _ = await runStructural { ops in
            let results = try stack.withCompound(
                label: "Split at Newlines", operations: ops
            ) {
                try order.map { try ops.splitBlockAtNewlines($0) }
            }
            let landing = zip(order, results).first { $0.0 == caretBlockID }?.1.blockIDs.first
            return StructuralOutcome(
                caretBlockID: landing ?? caretBlockID ?? order[0],
                caretOffset: 0, seam: nil,
                note: SplitAtNewlinesCopy.receipt(
                    results, whenNothingSplit: SplitAtNewlinesCopy.noteAlreadyWhole),
                noteIsRefusal: !SplitAtNewlinesCopy.acted(results))
        }
    }

    /// **One block's repair** — the block ▾ row. No compound: the operation
    /// registers exactly one entry for the block it splits.
    func splitCaretBlockAtNewlines() async {
        guard let blockID = model.caretBlockID else {
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a block first — this splits the block you're in.")
            return
        }
        _ = await runStructural { ops in
            let result = try ops.splitBlockAtNewlines(blockID)
            return StructuralOutcome(
                caretBlockID: result.blockIDs.first ?? blockID, caretOffset: 0, seam: nil,
                note: SplitAtNewlinesCopy.receipt(
                    [result], whenNothingSplit: SplitAtNewlinesCopy.blockAlreadyWhole),
                noteIsRefusal: !SplitAtNewlinesCopy.acted([result]))
        }
    }

    /// **J4b's road: the carry-all merge.** ONE pairing of the two displayed
    /// takes plus every other active take carried whole, composed from this
    /// app's own `mergeCeremony` — zero core change, and the instant no-fan
    /// merge above stays byte-unchanged behind its own threshold.
    ///
    /// `leadingDisplayedID` / `trailingDisplayedID`: the pair to join. Nil
    /// (⌘⇧M, the seam) = whatever the surface shows at act time; the sheet's
    /// preset road passes the takes it SHOWED as the pair (18f ladder round
    /// 2, R2-2), so what she was shown is what joins.
    @discardableResult
    private func runCarryAllMerge(
        leadingID: String, trailingID: String,
        leadingDisplayedID: String? = nil, trailingDisplayedID: String? = nil
    ) async -> Bool {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        let fans: (leading: [Variant], trailing: [Variant])
        do {
            fans = try await liveActiveFans(leadingID, trailingID)
        } catch {
            model.showOperationError(error)
            return false
        }
        guard fans.leading.count > 1 || fans.trailing.count > 1 else {
            // The store says unfanned — the instant merge, byte-unchanged
            // (⌘⇧M's own answer for an unfanned pair, P27's road one branch
            // over).
            return await runInstantMerge(leadingID: leadingID, trailingID: trailingID)
        }
        guard let composition = CarryAllMerge.compose(
            leadingDisplayedID: leadingDisplayedID
                ?? model.index.entries.first { $0.blockID == leadingID }?.variantID,
            leadingFan: fans.leading,
            trailingDisplayedID: trailingDisplayedID
                ?? model.index.entries.first { $0.blockID == trailingID }?.variantID,
            trailingFan: fans.trailing)
        else {
            model.refuse(FannedDefaultsCopy.takesChangedMerge)
            return false
        }
        // By id, at act time (R1-2) — the length that places the caret at
        // the join must be the trailing block's, not whatever entry the
        // open-time index pointed at.
        guard let trailingIndex = entryIndex(of: trailingID) else {
            model.refuse(FannedDefaultsCopy.blocksChangedMerge)
            return false
        }
        let trailingLength = model.index.entries[trailingIndex].length
        return await runStructural { ops in
            let result = try ops.mergeCeremony(
                leadingID, trailingID,
                pairings: [composition.pairing], carries: composition.carries)
            // Caret at the join, the instant merge's own arithmetic: the
            // chosen take IS the joined one (the core's rendered×rendered
            // rule, and this composition always pairs exactly those two).
            let joined = CarryAllMerge.joinedTake(of: result)
            let join = max(0, (joined?.workingText.utf16.count ?? 0) - trailingLength)
            return StructuralOutcome(
                caretBlockID: result.block.id, caretOffset: join, seam: nil,
                note: FannedDefaultsCopy.merged(
                    carried: max(0, result.variants.count - 1)))
        }
    }

    /// The N-way chain (author 2026-07-09, superseding the binary rule) — a
    /// left-to-right run of binary merges under ONE undo entry
    /// (`withCompound`, the Make Block pattern), now with **carry-all
    /// links**: a link whose either side carries a fan composes through
    /// `mergeCeremony` exactly as the pair road does, and an unfanned link
    /// keeps `merge` byte-unchanged. A deliberate multi-block act takes the
    /// full-render door (seam nil).
    ///
    /// The chain's fans are read ONCE, from the store, before the compound:
    /// each link's LEADING side after the first is the previous link's own
    /// result, so nothing needs re-reading mid-compound. The accepted
    /// consequence, recorded rather than discovered: a carried take rides
    /// whole and never receives the other blocks' text, so in a chain the
    /// alternates end up standing alone beside a fully-joined chosen take —
    /// the pair road's own consequence, applied twice ("quick to delete").
    ///
    /// `displayed`: the shown take per block. Nil (⌘⇧M and the bulk doors) =
    /// whatever the surface shows at act time; the SHEET passes the ids its
    /// list marks (13u3 UNIT G, R3-5 — R2-2's pattern on `runCarryAllMerge`).
    ///
    /// **What `displayed` binds, said exactly (13u3 ladder round 1, R1-5):**
    /// only the CARRY-ALL road consumes it (`CarryAllMerge.compose` — which
    /// take seeds each join, which ride whole). The PLAIN road
    /// (`bringEveryTake: false`) joins through `ops.merge`, which resolves
    /// each side from the STORE's rendered take at op time and never reads
    /// this dictionary — its "what she was shown is what joins" promise is
    /// held by the sheet's drift check (`refreshMergeRunIfDrifted`, run on
    /// every preset confirm) plus the pinned equivalence of
    /// `Queries.renderedVariantIDs` with `Operations.renderedVariant`,
    /// modulo the recorded sub-ms confirm-to-transaction window. Do not
    /// weaken that check on the belief that `displayed` fences the plain
    /// road; it does not.
    @discardableResult
    private func runMergeChain(
        blockIDs: [String], bringEveryTake: Bool = true,
        displayed displayedOverride: [String: String?]? = nil
    ) async -> Bool {
        // By id, at act time (R1-2): the run's leading block, wherever the
        // surface tiles it now.
        guard let first = blockIDs.first, let leadingIndex = entryIndex(of: first) else {
            model.refuse(FannedDefaultsCopy.blocksChangedMerge)
            return false
        }
        let leadingLength = model.index.entries[leadingIndex].length
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        let fans: [String: [Variant]]
        do {
            fans = try await model.session.database.read { db in
                var result: [String: [Variant]] = [:]
                for id in blockIDs {
                    result[id] = try Queries.blockFan(db, blockID: id)
                        .filter { $0.deletedAt == nil && $0.status == .active }
                }
                return result
            }
        } catch {
            model.showOperationError(error)
            return false
        }
        let displayed = displayedOverride ?? Dictionary(
            uniqueKeysWithValues: model.index.entries
                .filter { blockIDs.contains($0.blockID) }
                .map { ($0.blockID, $0.variantID) })
        // A5 (ladder A round 1): validate BEFORE the compound — a fanned
        // link whose displayed take vanished under the gesture used to fall
        // to plain `merge` inside it, folding that fan to lineage with no
        // speech. The whole run refuses up front (nothing touched), the
        // pair road's own words.
        // The A5 validation is the CARRY-ALL road's: the plain road joins the
        // shown takes and depends on no displayed-take resolution, so gating
        // it on this would refuse a race it cannot suffer.
        if bringEveryTake, !CarryAllMerge.chainComposes(
            order: blockIDs, fans: fans, displayed: displayed) {
            model.refuse(FannedDefaultsCopy.takesChangedMerge)
            return false
        }
        let stack = model.session.undoStack
        return await runStructural { ops in
            try stack.withCompound(label: "Merge Blocks", operations: ops) {
                // ONE chain body, three surfaces (`MergeChainRun`): what
                // LANDED is counted from the ops' own answers, so a link that
                // fell to the plain road can never inflate the receipt.
                let landing = try MergeChainRun.run(
                    ops, order: blockIDs, fans: fans, displayed: displayed,
                    bringEveryTake: bringEveryTake)
                // Caret at the FIRST join (merge keeps the leading text
                // verbatim, so the leading length still addresses it).
                return StructuralOutcome(
                    caretBlockID: landing.blockID,
                    caretOffset: min(leadingLength, landing.mergedTextLength),
                    seam: nil,
                    note: FannedDefaultsCopy.mergedChain(
                        blocks: blockIDs.count,
                        carried: max(0, landing.takesOnMerged - 1)))
            }
        }
    }

    // MARK: - Insert block below (13b Stage 4, 4D — N28/S4-13)

    /// The Write half of the insert-below act: an EMPTY block mints right
    /// under the caret block (`newBlock(at: .after(...))` — the ops layer's
    /// fractional index places it) and the caret lands in it. Runs through
    /// `runStructural` — the one structural door: one flight at a time,
    /// flush-first, store-led rewrite, caret by identity. A sealed post
    /// refuses through the op, spoken.
    func insertBlockBelowCaret() async {
        guard let blockID = model.caretBlockID,
              let i = model.index.entries.firstIndex(where: { $0.blockID == blockID })
        else {
            // Fire-and-speak (no silent door): the open tail / empty post
            // cases say what makes blocks there instead of guessing a
            // position.
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a block first — the new block lands right below it.")
            return
        }
        let landed = await insertEmptyBlock(edge: .below, entryIndex: i, blockID: blockID)
        if landed { model.showReceipt("New block added below — type away.") }
    }

    /// **The one body behind BOTH doors onto "an empty block beside this
    /// one"** — ⌘⇧⏎'s menu act above and U-1's typed Return below (the
    /// standing rule from 13e/13j: two doors on one act share the body or
    /// they drift).
    ///
    /// **The seam is stated, and that is the P1 half of 18c batch 2.** An
    /// insert used to re-render the whole surface from the store (`seam:
    /// nil`), which was free while this was a menu gesture and would not be
    /// once every paragraph break travels it: a full `materialize` +
    /// `setSurfaceContent` per Return is cost ∝ document, exactly what P1
    /// forbids for a keystroke. The seam vocabulary describes SURFACE
    /// SHAPE, not which operation ran, and both shapes here already exist
    /// in it as their degenerate cases — an empty block after entry i is a
    /// divide whose second half is empty; an empty block before it is a
    /// prefix extract whose extracted text is empty. `StructuralSeamEdit`'s
    /// three guard layers verify that shape against the fresh projection
    /// and refuse to a full re-render when it does not hold, and the DEBUG
    /// oracle re-checks the landed surface against the store, so the
    /// cheaper road cannot land a wrong one.
    ///
    /// The caret: BELOW puts it in the new empty block ("the paragraph I
    /// just started"); ABOVE leaves it in the text block, which is what
    /// "push this paragraph down" means (§5.1).
    @discardableResult
    func insertEmptyBlock(
        edge: TypedReturn.Edge, entryIndex i: Int, blockID: String
    ) async -> Bool {
        await runStructural { [postID = model.postID] ops in
            switch edge {
            case .below:
                let result = try ops.newBlock(in: postID, text: "", at: .after(blockID))
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: 0,
                    seam: .divide(
                        entryIndex: i, sourceID: blockID, successorID: result.block.id))
            case .above:
                let result = try ops.newBlock(in: postID, text: "", at: .before(blockID))
                return StructuralOutcome(
                    caretBlockID: blockID, caretOffset: 0,
                    seam: .extract(
                        entryIndex: i, edge: .prefix,
                        sourceID: blockID, extractedID: result.block.id))
            }
        }
    }

    // MARK: - 18c batch 2 (U-1): the typed Return's act

    /// Schedules U-1's act for the next main-actor turn through the
    /// deferred-keystroke seam below. The seam's NAME is the class it was
    /// built for (#11a's merge-then-edit); what it IS, and why this rides
    /// it, is "a keystroke whose act runs on the next turn, CHAINED so two
    /// fast keystrokes compose instead of racing, and awaitable by teardown
    /// and by tests".
    func scheduleTypedReturn() {
        scheduleCrossBlockCompound { [weak self] in await self?.runTypedReturnAct() }
    }

    /// **The dispatch — and it re-derives.** The key answered "mine?" a turn
    /// ago against the surface as it then was; the act reads the decision
    /// again HERE, so a second Return pressed inside the first one's flight
    /// acts on the block the first one made (⏎⏎ = a new block, then nothing
    /// — never two blocks from one intent, never a divide at an offset that
    /// has moved). Nothing here edits a row: every arm dispatches to a door
    /// that already runs through `runStructural`, and every refusal — a
    /// sealed note, a locked take, a block with no interior word edge — is
    /// that door's own, spoken in its own words.
    private func runTypedReturnAct() async {
        // 18c ladder round 2, R2-1: NO replay here. Whatever road the act
        // takes — a flight, a spoken refusal, the empty block's no-op, a
        // `.content` re-derivation — the keys stashed since the CLAIM drain
        // from the ONE idle gate (`replayDeferredKeystrokesIfIdle`), which
        // the compound chain's tail runs once this act was the last thing
        // queued and nothing is in flight. (Round 1 replayed here for the
        // claim's own generation; a compound queued AHEAD of this act by a
        // replayed seam ⌫ drained the act's keys first — see the gate.)
        switch model.typedReturnAct() {
        case .content:
            // Re-derived to `.content`: the surface moved under the claim (a
            // replayed key, a flight's landing) and this keystroke is not
            // the gesture after all. Consumed, deliberately not spoken.
            //
            // **`.nothing` RETIRED here with the brain's own arm (R-13u4-2,
            // 13u4 UNIT E1):** the empty block's no-op is superseded — that
            // caret now mints through `insertEmptyBlock` below, like every
            // other end-of-block caret, and chains.
            return
        case .divideAtCaret:
            await invokeGesture(.divideAtCursor)
        case .emptyBlock(let edge, let entryIndex, let blockID, let closingEmptyTail):
            if closingEmptyTail { model.closeEmptyTailSeparator() }
            await insertEmptyBlock(edge: edge, entryIndex: entryIndex, blockID: blockID)
        }
    }

    // MARK: - Take ↔ block structure (13e batch 3 — her A20/A21, AR-1)

    /// **Her A20's Write half**: the take the caret is in leaves the fan and
    /// becomes its own block directly below. Runs through `runStructural`
    /// like every structural gesture (one flight, flush first, store-led
    /// rewrite, caret by identity) and lands the caret in the NEW block —
    /// the insert-below handover, exactly.
    ///
    /// The op archives the original on its block (AR-1), so the receipt says
    /// where it went: a door that quietly removes a take from a fan and does
    /// not say it is recoverable is the class R118/P-2 retired.
    func moveCaretTakeIntoBlockBelow() async {
        guard let blockID = model.caretBlockID, let variantID = model.caretVariantID else {
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a take first — this moves that take into its own block.")
            return
        }
        let landed = await runStructural { ops in
            let result = try ops.takeToBlockBelow(blockID, variantID: variantID)
            return StructuralOutcome(
                caretBlockID: result.block.id, caretOffset: 0, seam: nil)
        }
        if landed {
            model.showReceipt(TakeStructureCopy.movedNote)
        }
    }

    /// **Her A21's second half (the A45 repair), Write side**: every other
    /// take of the caret block becomes its own block below it, in fan order.
    /// The caret stays in the block it was in — which still shows exactly
    /// what it showed (AR-1(c)).
    func turnCaretBlockTakesIntoBlocks() async {
        guard let blockID = model.caretBlockID else {
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a block first — this turns its takes into blocks.")
            return
        }
        _ = await runStructural { ops in
            let result = try ops.takesToBlocks(blockID)
            // The receipt is built INSIDE the flight, from the op's own
            // result, and rides back on the outcome — the counts (and the
            // skipped blanks) are the operation's answer, never a projection
            // read taken beside it.
            return StructuralOutcome(
                caretBlockID: blockID, caretOffset: 0, seam: nil,
                note: TakeStructureCopy.convertedNote(
                    blocks: result.converted.count,
                    skippedBlanks: result.skippedBlankTakes))
        }
    }

    // MARK: - Delete block (13c batch 1B — A8)

    /// The Write half of the delete-block act (her A8: "I don't seem to
    /// have the ability to delete / archive empty blocks?"). Runs through
    /// `runStructural` like every structural gesture — one flight, flush
    /// first, store-led rewrite (seam nil: no seam vocabulary describes a
    /// removal), caret by identity. A sealed post refuses through the op,
    /// spoken.
    ///
    /// Deleting the post's LAST block is ALLOWED, deliberately: no
    /// invariant makes a post's block count load-bearing, and the
    /// blockless post is an explicitly-modelled state — it is what a fresh
    /// post is (`BlockRangeIndex`: "When there are no entries the tail IS
    /// the document"). The block is undoable (⌥⌘Z) and redoable (⇧⌥⌘Z).
    /// *(13j J8(a): this comment used to add "and waits in the post's
    /// deleted-blocks tray" — the tray has no face until batch 2 builds it,
    /// and the receipt now says only what is true.)*
    func deleteCaretBlock() async {
        guard let blockID = model.caretBlockID,
              let index = model.index.entries.firstIndex(where: { $0.blockID == blockID })
        else {
            // Fire-and-speak: the open tail and the empty post are not
            // blocks, and saying so beats a silent door.
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a block first — this removes the block you're in.")
            return
        }
        // 13j J8(a): the ONE shared receipt (see `BlockSelectionCopy`).
        // Ledger row 4(a): the road depends on WHAT this pane is over — the
        // scraps editor composes this same controller on a pool container,
        // and the note-bar tray it used to name is not there.
        await runDeleteBlock(
            blockID, entryIndex: index,
            note: BlockSelectionCopy.deletedNote(1, home: homeKind))
    }

    /// The container this pane is over. The header is observed, so this costs
    /// nothing; `.post` while it is still loading, which is what every
    /// receipt said before this existed.
    private var homeKind: ContainerKind { model.header?.kind ?? .post }

    /// **ARCHIVE the caret block** (13j, her round-7 ruling): the block
    /// leaves the note KEPT — its placement is released, `archived_at` is
    /// stamped, and it waits in the note's tray with no countdown. Delete's
    /// twin in every other respect: the same caret landing, the same
    /// structural undo (and redo), the same fire-and-speak refusals.
    func archiveCaretBlock() async {
        guard let blockID = model.caretBlockID,
              let index = model.index.entries.firstIndex(where: { $0.blockID == blockID })
        else {
            model.refuseFeedback(model.index.entries.isEmpty
                ? "No blocks yet — type on the page and each finished paragraph becomes one."
                : "Put the caret in a block first — this sets the block you're in aside.")
            return
        }
        let landing = caretLandingAfterRemoving(index)
        let landed = await runStructural { ops in
            try ops.archiveBlock(blockID)
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        // The post-13l polish round (batch 1's deferred item): the road this
        // names depends on WHAT this pane is over — the same read the delete
        // receipt takes, one act up.
        if landed { model.showReceipt(BlockSelectionCopy.archivedNote(home: homeKind)) }
    }

    /// The delete-block body behind the menu/bar act above. (A7's
    /// empty-block backspace has had its own one-transaction body since 13c
    /// R3-1, and its own caret landing since VX-290 — `runEmptyBlockDeletion`.)
    private func runDeleteBlock(_ blockID: String, entryIndex: Int, note: String) async {
        let landing = caretLandingAfterRemoving(entryIndex)
        let landed = await runStructural { ops in
            try ops.deleteBlock(blockID)
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        if landed {
            model.showReceipt(note + (await StrandedOriginals.note(
                session: model.session, blockIDs: [blockID]) ?? ""))
        }
    }

    // MARK: - Delete SELECTED blocks (13e batch 4 — E2, her A17)

    /// **Her A17, built: "delete several blocks at the same time from a post
    /// - highlighting all of the blocks perhaps? block highlight instead of
    /// text highlight across blocks?"**
    ///
    /// Write's half. The blocks are the ones she ⌘-clicked (the highlight is
    /// literally her word for it); the act is the STANDING unrestricted
    /// `deleteBlock` per block (QUESTIONS #33(a) — the block goes, whatever
    /// it holds), and all of them run under ONE `withCompound` entry so a
    /// multi-delete is ONE mistake to reverse. Every leg registers a redo, so
    /// the compound is redoable too (13c A10's rule: a compound is redoable
    /// exactly when every leg is).
    ///
    /// **No partial acts.** The compound is the guarantee, not a pre-check: a
    /// sealed post refuses at the first leg through the operation itself
    /// (P-2 — the door delivers the ops layer's real refusal rather than
    /// guessing at one), and a leg that throws after others landed unwinds
    /// them immediately. A picked block DELETED by another pane, another
    /// window, or a sync arrival between the pick and the press refuses the
    /// whole gesture with NOTHING deleted (`OpsRefusalCopy`'s
    /// `blockNotFound` words, which this act is the first door to make
    /// reachable). A picked block that merely MOVED to another unsealed
    /// note is live and is deleted where it now lives, counted by the
    /// success receipt (#60(c) — the pick names the block, not its address;
    /// ladder round 2, R2-1, correcting this comment's earlier claim).
    ///
    /// The order is read from the STORE inside `runStructural`'s flight
    /// (which flushes first): the surface's index names WHICH blocks, the
    /// store decides what actually happens to them.
    func deleteSelectedBlocks() async {
        let picked = model.selectedBlocksInOrder
        guard !picked.isEmpty else {
            model.refuseFeedback(BlockSelectionCopy.nothingPicked)
            return
        }
        if await runBlockDeleteCompound(picked) { model.clearBlockSelection() }
    }

    /// THE delete compound, one body, two doors (13j J9 made it two): the
    /// ⌘-click pick above, and a whole-block text selection + Delete below.
    /// Her J9 ruling is literally *"routes to the batch-4 delete compound"* —
    /// so the second door runs this body rather than a second copy of it, and
    /// the two can never drift on the label, the compound, or the receipt.
    private func runBlockDeleteCompound(_ blockIDs: [String]) async -> Bool {
        let landing = caretLandingAfterRemoving(blockIDs)
        let stack = model.session.undoStack
        let landed = await runStructural { ops in
            try stack.withCompound(label: "Delete Blocks", operations: ops) {
                for blockID in blockIDs { try ops.deleteBlock(blockID) }
            }
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        // **13j batch 7 — the STRANDING sentence reaches this door too.**
        // Traced while writing the deletion chapter: her round-8b ruling says
        // the delete that strands a preserved original names it in its own
        // receipt, and batch 6 wired that into the two SINGLE-block doors
        // (`runDeleteBlock` here, `deleteFocusedBlock` on the board) — but
        // not into the compound, which is the door most likely to strand one:
        // picking a divide's two successors together and deleting them is
        // exactly how a family's last live descendant goes. The receipt moved
        // out of `StructuralOutcome.note` for the same reason its single-block
        // sibling speaks after the flight: the store must be asked whether
        // anything was stranded, and that answer only exists once the delete
        // has landed.
        if landed {
            // Ledger row 4(a): the same home-aware road as the single-block
            // door — the compound is reachable from the scraps editor too.
            model.showReceipt(
                BlockSelectionCopy.deletedNote(blockIDs.count, home: homeKind)
                + (await StrandedOriginals.note(
                    session: model.session, blockIDs: blockIDs) ?? ""))
        }
        return landed
    }

    // MARK: - J9 (13j batch 1): a whole-block selection + Delete

    /// **Her J9, built.** Her report, verbatim: *"what kind of writing app
    /// won't let you delete a paragraph? there's not even a take on it right
    /// now"* — and her ruling: a selection covering exactly N whole blocks
    /// (N ≥ 1) plus Delete routes to the 13e batch-4 delete compound, ONE
    /// ⌥⌘Z-undoable entry, and the text-edit road never refuses that intent
    /// again. Partial-block selections keep today's behaviour.
    ///
    /// The plan is PURELY GEOMETRIC on purpose — which blocks does the span
    /// cover whole? — and carries no content guards at all. That is the
    /// 13c R3-1 lesson applied rather than re-learned: a plan-time guard
    /// reading `model.slots` is an enablement hint, never an authorization,
    /// because the projection is deliberately frozen for the length of a
    /// typing burst. The authorization is `deleteBlock`'s own — the STANDING
    /// unrestricted door (QUESTIONS #33(a), her ruling: the block goes,
    /// whatever it holds), which is exactly the act the ⌘-click multi-delete
    /// already performs on fanned blocks. A sealed note refuses at the first
    /// leg through the operation itself (P-2), with nothing deleted.
    struct WholeBlockDeletion: Sendable, Equatable {
        let blockIDs: [String]
    }

    /// The rule moved to the shared brain at mobile round 2, batch 1b
    /// (`BlockRangeIndex.wholeBlockDeletion` — R18 ≡ M11, the phone's face
    /// for this same capability): delete-never-type-over plus the geometry,
    /// one home, two platforms. This door is now the Mac's face on it, and
    /// the pins below are unchanged — which is the proof the hoist moved
    /// nothing but the address.
    func planWholeBlockDeletion(range: NSRange, replacement: String) -> WholeBlockDeletion? {
        guard let blockIDs = model.index.wholeBlockDeletion(
            covering: range, replacement: replacement)
        else { return nil }
        return WholeBlockDeletion(blockIDs: blockIDs)
    }

    func runWholeBlockDeletion(_ plan: WholeBlockDeletion) async {
        _ = await runBlockDeleteCompound(plan.blockIDs)
    }

    /// Where the caret goes when a whole SET of blocks leaves — the rule
    /// now lives in the shared brain beside the geometry it reads
    /// (`BlockRangeIndex.caretLandingAfterRemoving(_:)`, hoisted at mobile
    /// round 2 batch 1b so the phone's face inherits it). This stays as the
    /// controller's spelling of it.
    ///
    /// *(Its single-INDEX sibling below is deliberately untouched: it serves
    /// Mac-only doors — delete/archive-caret-block — and the phone has no
    /// consumer for it, so hoisting it would be a Mac refactor riding a mobile
    /// batch. Recorded rather than done.)*
    private func caretLandingAfterRemoving(
        _ blockIDs: [String]
    ) -> (blockID: String, offset: Int) {
        model.index.caretLandingAfterRemoving(blockIDs)
    }

    /// Where the caret goes when entry `i` leaves: the START of the block
    /// below (what the eye expects when the seam above the caret closes),
    /// else the END of the block above. On the post's only block there is
    /// no survivor — naming the departed block leaves the caret wherever
    /// the fresh-post re-render put it, which is the honest answer and a
    /// harmless no-op in `applyStructuralResult`.
    ///
    /// The Delete Block and archive doors' rule, and theirs alone since
    /// VX-290: A7's seam carve lands where the deleted line break was
    /// (`caretLanding(afterCarving:)`), which this helper cannot know — it is
    /// told which entry leaves, never which side of a separator it sat on.
    private func caretLandingAfterRemoving(_ i: Int) -> (blockID: String, offset: Int) {
        let entries = model.index.entries
        if i + 1 < entries.count { return (entries[i + 1].blockID, 0) }
        if i > 0 { return (entries[i - 1].blockID, entries[i - 1].length) }
        return (entries[i].blockID, 0)
    }

    // MARK: - The merge ceremony (13b Stage 4, Batch 4B — S4-23, ruled)

    /// The merge ceremony's ONE sheet: both blocks' takes side by side,
    /// ＋ pairings placed by hand, carry checkboxes, stay-behind default —
    /// the W's mirror. Non-nil = the sheet is up; opening touches no rows;
    /// cancel sets nil; confirm funnels through the one structural door
    /// into `Operations.mergeCeremony`.
    var mergeCeremony: MergeCeremonyState?

    struct MergeCeremonyState: Equatable, Identifiable {
        let firstBlockID: String
        let secondBlockID: String
        /// **The whole RUN** (18f batch 1, her U-16): two ids for a pair,
        /// three or more when a selection covered a run. A run offers exactly
        /// two arrangements and never the pairing surface, so `firstTakes` /
        /// `secondTakes` / `pairings` stay empty on that arm and the pair's
        /// whole state machine below is untouched by it.
        var blockIDs: [String]
        // (`entryIndices` — the run's OPEN-time entry indices, kept for the
        // confirm roads' caret arithmetic — left this state at the 18f ladder,
        // R1-2: a sheet sits open while the surface re-tiles, so every road
        // now resolves its entries by block id at act time.)
        /// Live active takes across the run BEYOND the shown one per block —
        /// what "bring every take" would bring. Read at open; the sentence's
        /// only input.
        var otherTakes: Int
        /// **The run's blocks, for the sheet to SHOW** (18f batch 2, mockup
        /// figure B's amendment: over a run *"the columns become one list of
        /// the run's blocks with their shown takes marked"*). DISPLAY ONLY and
        /// additive — every confirm road reads the store afresh and none of
        /// them looks at this; it exists so the run's sheet can show what it
        /// is about to join instead of only counting it.
        var runBlocks: [MergeRunBlock]
        /// Which of U-5/U-16's options the row is on. `bringEveryTake` on
        /// open — her J4b default, so ⏎ still reproduces the everyday merge.
        var arrangement: MergeArrangement
        /// The rendered take of each side at open time — the default
        /// pre-pairing's parts (S4-23 ruling 4: ⏎ = today's exact outcome
        /// when no session join memory is set; a remembered join seeds the
        /// pre-pair instead — ruling 3's letter).
        let firstRenderedID: String?
        let secondRenderedID: String?
        var firstTakes: [MergeTake]
        var secondTakes: [MergeTake]
        /// Ordered — sheet order IS the operation's pairing order (the
        /// chosen rule's fallback reads it).
        var pairings: [MergePairingDraft]

        /// **EVERY field, NO defaults — deliberately** (18f ladder round 2,
        /// R2-1, the implementer's rider adopted). Batch 1 added `blockIDs`,
        /// `otherTakes`, `runBlocks` and `arrangement` with property defaults
        /// and updated two of the three construction sites; Swift's memberwise
        /// init let the third (`refreshMergeCeremony`) omit all four SILENTLY
        /// — no diagnostic — so a drift refresh under "Pair by hand…" flipped
        /// the sheet to "Bring every take", emptied the run's ids (and with
        /// them R1-2's presence guard) and said "There are no other takes to
        /// bring" about a fanned pair. With this initializer a construction
        /// site that forgets a field fails to compile instead.
        init(
            firstBlockID: String, secondBlockID: String, blockIDs: [String],
            otherTakes: Int, runBlocks: [MergeRunBlock], arrangement: MergeArrangement,
            firstRenderedID: String?, secondRenderedID: String?,
            firstTakes: [MergeTake], secondTakes: [MergeTake], pairings: [MergePairingDraft]
        ) {
            self.firstBlockID = firstBlockID
            self.secondBlockID = secondBlockID
            self.blockIDs = blockIDs
            self.otherTakes = otherTakes
            self.runBlocks = runBlocks
            self.arrangement = arrangement
            self.firstRenderedID = firstRenderedID
            self.secondRenderedID = secondRenderedID
            self.firstTakes = firstTakes
            self.secondTakes = secondTakes
            self.pairings = pairings
        }

        var id: String { blockIDs.joined(separator: "+") }

        /// U-16's fork: three or more blocks get two choices and no pairing.
        var isRun: Bool { blockIDs.count > 2 }
        var offeredArrangements: [MergeArrangement] {
            MergeArrangement.offered(blocks: max(2, blockIDs.count))
        }
        /// The pair's canon join on the two SHOWN takes' stored texts — what
        /// both preset roads will actually join with (18f ladder R1-12).
        /// Since R-13u4-3 the canon rule IS the door rule, so the sentence
        /// says "join on a new line"; the former `.space` fallback for an
        /// unresolvable pair is gone because the rule answers the same for
        /// any texts, empty ones included.
        var canonJoin: MergeJoin {
            let head = firstTakes.first { $0.id == firstRenderedID }?.variant.workingText ?? ""
            let tail = secondTakes.first { $0.id == secondRenderedID }?.variant.workingText ?? ""
            return MergeJoinRule.door.join(head: head, tail: tail)
        }
        var arrangementSentence: String {
            MergeArrangementCopy.sentence(
                arrangement, blocks: max(2, blockIDs.count), otherTakes: otherTakes,
                join: canonJoin)
        }

        func take(_ id: String) -> MergeTake? {
            firstTakes.first { $0.id == id } ?? secondTakes.first { $0.id == id }
        }

        func isPaired(_ takeID: String) -> Bool {
            pairings.contains { $0.firstVariantID == takeID || $0.secondVariantID == takeID }
        }

        /// The columns show UNPAIRED takes; paired ones render in the
        /// pairings section (a take sits in exactly one place).
        var unpairedFirst: [MergeTake] { firstTakes.filter { !isPaired($0.id) } }
        var unpairedSecond: [MergeTake] { secondTakes.filter { !isPaired($0.id) } }

        var carriedIDs: [String] {
            (firstTakes + secondTakes).filter(\.carried).map(\.id)
        }

        /// Takes that stay with the released sources in lineage on confirm.
        var stayBehindCount: Int {
            (firstTakes + secondTakes).count - 2 * pairings.count - carriedIDs.count
        }

        /// Confirm gates on I10 at birth, with the reason spoken (the
        /// architect's precision): the merged block must receive at least
        /// one take. The op's `mergedBlockWouldHaveNoTake` is the belt.
        var confirmBlocker: String? {
            // The two preset roads place everything themselves — the only
            // gate left is the hand-placed sheet's own I10-at-birth rule.
            guard arrangement == .pairByHand else { return nil }
            if pairings.isEmpty && carriedIDs.isEmpty {
                return "Nothing would land on the merged block — pair takes with ＋, or check “carry” on at least one."
            }
            return nil
        }

        var canConfirm: Bool { confirmBlocker == nil }
    }

    /// One block of a RUN, as the sheet shows it (18f batch 2): the take that
    /// is currently shown there, and how many takes the block carries.
    ///
    /// **`shownVariantID` joined it at 13u3 UNIT G (the 18f ladder's R3-5).**
    /// The row used to carry TEXT and no id, which is what left the run arm
    /// with no drift check to run: the list showed a take, both confirm roads
    /// resolved the shown takes afresh at act time, and a re-point landed
    /// under the open sheet joined a take the list never showed. With the id
    /// here the row IS the comparison — read in the same store read as the
    /// fans, compared against that same read before the chain runs, and handed
    /// to `runMergeChain` as its `displayed` so what she was shown is what
    /// joins (R2-2's pattern on the pair, on the rarer surface).
    struct MergeRunBlock: Equatable, Identifiable {
        let blockID: String
        /// The take the block renders — the STORE's answer, never the
        /// surface's (the projection only ever lags it).
        let shownVariantID: String?
        let shownText: String
        let takeCount: Int
        var id: String { blockID }
    }

    struct MergeTake: Equatable, Identifiable {
        let variant: Variant
        var carried = false
        var id: String { variant.id }
    }

    struct MergePairingDraft: Equatable, Identifiable {
        let firstVariantID: String
        let secondVariantID: String
        var join: MergeJoin
        var id: String { firstVariantID + "+" + secondVariantID }
    }

    /// Builds the ceremony over the two blocks' live ACTIVE fans, pre-
    /// paired with the two rendered takes (ruling 4) under the session-
    /// remembered join or the canon default (ruling 3). The buffer flushes
    /// first so every take's stored text — what the sheet shows and the op
    /// will join — matches the surface. No rows are touched by opening.
    ///
    /// **This read IS ⌥⌘⇧M's authorization** (18o U3, KnownIssues row 79):
    /// the threshold rule reads truth, not the projection. Fanned → the
    /// sheet; unfanned → the door's ruled refusal
    /// (`FannedDefaultsCopy.mergeCeremonyNeedsAFan`), NEVER the instant
    /// merge. The instant fallthrough that stood here dates from 13b 4B,
    /// when ⌘⇧M itself opened this sheet and an unfanned pair's instant
    /// merge was that door's everyday answer; since 13j J4b the sheet is
    /// ⌥⌘⇧M's alone, and a ceremony door that merges on its own is the
    /// defect, not the fallback.
    private func openMergeCeremony(leadingID: String, trailingID: String) async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        do {
            // The threshold read, shared with the seam keystroke since 13d
            // batch 2 — ONE fan rule, one place (#34's point 2) — and, since
            // 13u3 UNIT G (the 18f ladder's R3-6), the shown pair rides in the
            // SAME read. The ids used to come from the projection while the
            // drift check compared the store, so opening inside the
            // sub-delivery window (a re-point landed, the surface not yet
            // caught up) made the first ⏎ refresh and say "the takes changed
            // while the sheet was open" about a change that predated the open.
            // The raise's rule — the store is the one truth both confirm roads
            // act on, the projection only lags it — applied at open too.
            let (firstFan, secondFan, rendered) = try await liveActiveFansAndRendered(
                leadingID, trailingID)
            guard firstFan.count > 1 || secondFan.count > 1 else {
                model.refuseFeedback(FannedDefaultsCopy.mergeCeremonyNeedsAFan)
                return
            }
            let firstRenderedID = rendered.first
            let secondRenderedID = rendered.second
            var state = MergeCeremonyState(
                firstBlockID: leadingID, secondBlockID: trailingID,
                blockIDs: [leadingID, trailingID],
                otherTakes: max(0, firstFan.count - 1) + max(0, secondFan.count - 1),
                runBlocks: [],
                arrangement: .bringEveryTake,
                firstRenderedID: firstRenderedID, secondRenderedID: secondRenderedID,
                firstTakes: firstFan.map { MergeTake(variant: $0) },
                secondTakes: secondFan.map { MergeTake(variant: $0) },
                pairings: [])
            // The default pre-pairing: the two RENDERED takes, joined by
            // the remembered choice or the canon rule. Precision (ladder
            // round 1, NIT-4): confirming immediately reproduces today's
            // exact outcome in a FRESH session — no join memory set; once
            // a session memory exists the pre-pair joins by the MEMORY,
            // not canon (ruling 3's letter).
            state.pairings = prePairing(
                firstFan: firstFan, secondFan: secondFan, rendered: rendered)
            mergeCeremony = state
        } catch {
            model.showOperationError(error)
        }
    }

    /// **The default pre-pairing, in ONE place** (S4-23 ruling 4: ⏎ = today's
    /// exact outcome when no session join memory is set; a remembered join
    /// seeds the pre-pair instead — ruling 3's letter). Hoisted at 13u3 UNIT G
    /// (the 18f ladder's R3-7) because the REFRESH owes the same seed: under a
    /// preset the pre-pair is invisible, so an open-time pre-pair used to
    /// survive a shown-pair refresh by liveness alone and "Pair by hand…"
    /// afterwards offered the pair the sheet no longer marked. Two expressions
    /// of one rule is exactly what that costs; this is the one expression.
    private func prePairing(
        firstFan: [Variant], secondFan: [Variant], rendered: (first: String?, second: String?)
    ) -> [MergePairingDraft] {
        guard let head = firstFan.first(where: { $0.id == rendered.first }),
              let tail = secondFan.first(where: { $0.id == rendered.second })
        else { return [] }
        return [MergePairingDraft(
            firstVariantID: head.id, secondVariantID: tail.id,
            join: model.session.mergeJoinMemory
                ?? MergeJoinRule.door.join(head: head.workingText, tail: tail.workingText))]
    }

    /// **U-16's two-option door over a RUN of three or more.** No columns,
    /// no pairing, no per-take state — the sheet asks the one question her
    /// ruling names and the confirm runs the chain either way. Opening
    /// touches no rows (the ceremony's standing contract), and the fans are
    /// read from the STORE for the sentence's count exactly as every fanned
    /// road on this surface reads them.
    ///
    /// A run with NO fan anywhere has nothing to choose between — both roads
    /// are byte-identically `merge` — so the door speaks the pair's own
    /// needs-a-fan refusal rather than asking a question with one answer.
    private func openMergeRunChoice(blockIDs: [String]) async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let read: RunRead
        do {
            read = try await runFansAndRendered(blockIDs)
        } catch {
            model.showOperationError(error)
            return
        }
        guard read.otherTakes > 0 else {
            model.refuseFeedback(FannedDefaultsCopy.mergeCeremonyNeedsAFan)
            return
        }
        mergeCeremony = MergeCeremonyState(
            firstBlockID: blockIDs[0], secondBlockID: blockIDs[1],
            blockIDs: blockIDs, otherTakes: read.otherTakes,
            runBlocks: read.blocks,
            arrangement: .bringEveryTake,
            firstRenderedID: nil, secondRenderedID: nil,
            firstTakes: [], secondTakes: [], pairings: [])
    }

    /// The run sheet's ONE store read — the fans, the count under the
    /// sentence, and each block's shown take, all from one snapshot (13u3
    /// UNIT G). Open builds the list from it; the confirm compares against it.
    /// Two reads for one question is how the open-time lag window was born on
    /// the pair (R3-6), so the run gets one from the start.
    private struct RunRead {
        let blocks: [MergeRunBlock]
        let otherTakes: Int
    }

    private func runFansAndRendered(_ blockIDs: [String]) async throws -> RunRead {
        let (fans, rendered) = try await model.session.database.read {
            db -> ([String: [Variant]], [String: String]) in
            var fans: [String: [Variant]] = [:]
            for id in blockIDs {
                fans[id] = try Queries.blockFan(db, blockID: id)
                    .filter { $0.deletedAt == nil && $0.status == .active }
            }
            // R3-9's reader: the rendered take of exactly these blocks, at the
            // cost of these blocks — `renderPost` would have loaded the whole
            // note's texts to answer it.
            return (fans, try Queries.renderedVariantIDs(db, blockIDs: blockIDs))
        }
        // The run's blocks as the sheet SHOWS them (18f batch 2, figure B's
        // amendment): the shown take named by the STORE, its text taken from
        // the same fans the count came from.
        let blocks = blockIDs.map { id -> MergeRunBlock in
            let fan = fans[id] ?? []
            let shownID = rendered[id]
            let take = fan.first { $0.id == shownID } ?? fan.first
            return MergeRunBlock(
                blockID: id, shownVariantID: take?.id, shownText: take?.workingText ?? "",
                takeCount: max(1, fan.count))
        }
        return RunRead(
            blocks: blocks,
            otherTakes: blockIDs.reduce(0) { $0 + max(0, (fans[$1]?.count ?? 1) - 1) })
    }

    /// Switches the merge row. Nothing is written — the sheet has touched no
    /// rows since 13b 4B and still doesn't.
    func setMergeArrangement(_ arrangement: MergeArrangement) {
        guard var state = mergeCeremony,
              state.offeredArrangements.contains(arrangement),
              state.arrangement != arrangement
        else { return }
        state.arrangement = arrangement
        mergeCeremony = state
    }

    /// Places a ＋ between two takes (one from each column). A newly paired
    /// take stops carrying — paired and carried are exclusive (the op's
    /// 1:1 arity, mirrored here so the sheet can never request a refusal).
    func pairMergeTakes(firstID: String, secondID: String) {
        guard var state = mergeCeremony,
              let head = state.firstTakes.first(where: { $0.id == firstID }),
              let tail = state.secondTakes.first(where: { $0.id == secondID }),
              !state.isPaired(firstID), !state.isPaired(secondID)
        else { return }
        setMergeCarried(&state, takeID: firstID, carried: false)
        setMergeCarried(&state, takeID: secondID, carried: false)
        state.pairings.append(MergePairingDraft(
            firstVariantID: firstID, secondVariantID: secondID,
            join: model.session.mergeJoinMemory
                ?? MergeJoinRule.door.join(
                    head: head.variant.workingText, tail: tail.variant.workingText)))
        mergeCeremony = state
    }

    func removeMergePairing(_ pairingID: String) {
        guard var state = mergeCeremony else { return }
        state.pairings.removeAll { $0.id == pairingID }
        mergeCeremony = state
    }

    func setMergeJoin(pairingID: String, join: MergeJoin) {
        guard var state = mergeCeremony,
              let i = state.pairings.firstIndex(where: { $0.id == pairingID }) else { return }
        state.pairings[i].join = join
        mergeCeremony = state
    }

    func toggleMergeCarry(_ takeID: String) {
        guard var state = mergeCeremony, !state.isPaired(takeID) else { return }
        let carried = state.take(takeID)?.carried ?? false
        setMergeCarried(&state, takeID: takeID, carried: !carried)
        mergeCeremony = state
    }

    private func setMergeCarried(
        _ state: inout MergeCeremonyState, takeID: String, carried: Bool
    ) {
        if let i = state.firstTakes.firstIndex(where: { $0.id == takeID }) {
            state.firstTakes[i].carried = carried
        }
        if let i = state.secondTakes.firstIndex(where: { $0.id == takeID }) {
            state.secondTakes[i].carried = carried
        }
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelMergeCeremony() {
        mergeCeremony = nil
    }

    /// **The confirm DISPATCHER** (18f batch 1): the row chose the road.
    /// "Bring every take" and "only the shown ones" are the surface's own
    /// standing roads — the carry-all and the plain merge, pair or chain —
    /// each of which flushes, reads the store, guards and speaks for itself;
    /// "pair by hand" is the shipped S4-23 confirm below, byte-unchanged. The
    /// sheet dismisses only when the act LANDED, on every road.
    func confirmMergeCeremony() async {
        guard let state = mergeCeremony, state.canConfirm else { return }
        // The one-flight door, checked synchronously BEFORE any await (the
        // W confirm's discipline): refuse visibly and KEEP the ceremony.
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return
        }
        guard state.arrangement == .pairByHand else {
            // 18f ladder R1-2: the sheet may have sat open while the surface
            // re-tiled under it (the pairing road's drift class, one level
            // up). The roads below resolve every entry BY BLOCK ID at act
            // time; a block no longer on the surface dismisses the sheet in
            // the refresh road's own voice, rows untouched — the same answer
            // `refreshMergeCeremony` gives when a side dissolves.
            // Non-vacuous by construction (18f ladder round 2, R2-1): an
            // EMPTY `blockIDs` must refuse too, never pass — the refreshed
            // state used to arrive here with none and this guard said yes.
            guard !state.blockIDs.isEmpty,
                  state.blockIDs.allSatisfy({ entryIndex(of: $0) != nil })
            else {
                mergeCeremony = nil
                model.refuse(FannedDefaultsCopy.blocksChangedMerge)
                return
            }
            // The preset roads confirm what the sheet SHOWED (18f ladder round
            // 2, R2-2): the same drift check the pairing branch runs, widened
            // to the shown takes — a chosen re-point under the open sheet
            // refreshes it onto what the blocks show now, for her to review,
            // instead of joining takes she was never shown.
            //
            // **The `if !state.isRun` fence retired at 13u3 UNIT G (R3-5).**
            // It rested on "a run's sheet marks a list of blocks, not a pair",
            // which figure B's amendment had already made false — the run's
            // list shows each block's shown take over its text, and both run
            // roads resolve those takes at act time. The check runs on every
            // preset road now; `refreshMergeSheetIfDrifted` dispatches to the
            // pair's arm or the run's.
            guard await refreshMergeSheetIfDrifted(state) == .current else { return }
            let bringEvery = state.arrangement == .bringEveryTake
            let landed: Bool
            if state.isRun {
                // The ids the LIST marks are the run's `displayed` (R2-2's
                // pattern on `runCarryAllMerge`) — so the carry-all seeds from
                // what she was shown rather than from a projection that only
                // ever lags the store.
                landed = await runMergeChain(
                    blockIDs: state.blockIDs, bringEveryTake: bringEvery,
                    displayed: Dictionary(
                        uniqueKeysWithValues: state.runBlocks.map {
                            ($0.blockID, $0.shownVariantID)
                        }))
            } else if bringEvery {
                // Composed from the STATE's rendered ids — the promise the
                // sheet's "＋ pairs with →" makes, literal by construction (a
                // shown take that has since died falls out through the
                // composition's own nil → `takesChangedMerge`).
                landed = await runCarryAllMerge(
                    leadingID: state.firstBlockID, trailingID: state.secondBlockID,
                    leadingDisplayedID: state.firstRenderedID,
                    trailingDisplayedID: state.secondRenderedID)
            } else {
                landed = await runInstantMerge(
                    leadingID: state.firstBlockID, trailingID: state.secondBlockID)
            }
            if landed { mergeCeremony = nil }
            return
        }
        // The sheet may have sat open while a sync round landed edits (the
        // W confirm's drift class): the previews and the canon-default
        // joins were derived from SNAPSHOT texts. Verify both fans — and the
        // shown pair — against the CURRENT store and surface first; on any
        // drift, refresh the ceremony (pairings and carries kept by take
        // identity, previews re-derived) instead of confirming what the
        // author wasn't shown.
        guard await refreshMergeSheetIfDrifted(state) == .current else { return }
        let pairings = state.pairings.map {
            Operations.MergePairing(
                firstVariantID: $0.firstVariantID,
                secondVariantID: $0.secondVariantID,
                join: $0.join)
        }
        let carries = state.carriedIDs
        let stayBehind = state.stayBehindCount
        let landed = await runStructural { ops in
            let result = try ops.mergeCeremony(
                state.firstBlockID, state.secondBlockID,
                pairings: pairings, carries: carries)
            // seam nil: ceremonial acts re-render fully from the store —
            // the permanent shape (author, 2026-07-07); caret at the
            // merged block's start (the W confirm's precedent).
            return StructuralOutcome(
                caretBlockID: result.block.id, caretOffset: 0, seam: nil)
        }
        // The sheet dismisses only when the merge LANDED — a refusal keeps
        // the ceremony and its pairings for the author.
        if landed {
            mergeCeremony = nil
            // Ruling 3: the session remembers the last CONFIRMED join.
            // Mechanical rule (recorded): when the confirmed pairings agree
            // on one join it is remembered; a mixed sheet leaves the memory
            // unchanged; carry-only confirms carry no join to remember.
            let joins = Set(pairings.map(\.join))
            if joins.count == 1, let only = joins.first {
                model.session.mergeJoinMemory = only
            }
            speakAboutStayBehindTakes(stayBehind)
        }
    }

    /// The ceremony's lineage-road speech (the instant path keeps its
    /// "visible takes" copy verbatim — this is the pairing wording of the
    /// same promise; the road survives on BOTH paths).
    private func speakAboutStayBehindTakes(_ count: Int) {
        guard count > 0 else { return }
        model.showTransientReceipt(
            count == 1
                ? "Merged — 1 take stays with the released blocks in lineage "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes)."
                : "Merged — \(count) takes stay with the released blocks in lineage "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes).")
    }

    private enum MergeSheetDrift { case current, refreshed, failed }

    /// **The PAIR sheet's ONE drift check, both branches** (the W confirm's
    /// discipline; widened at the 18f ladder round 2, R2-2). The sheet may
    /// have sat open while a sync round landed — a take's text, the fan's
    /// size, OR which take a block SHOWS. Any of the three refreshes the
    /// ceremony onto the current store (pairings and carries kept by
    /// identity, the shown pair re-marked) and the author reviews again;
    /// nothing is joined from what she wasn't shown. Before this the pairing
    /// branch checked texts and count, the preset branches checked nothing,
    /// and a pure chosen re-point — every text and count unchanged — escaped
    /// both.
    ///
    /// **The shown pair is read from the STORE, in the same read as the fans**
    /// (the implementer's round-2 raise): "Only the two shown" joins through
    /// `ops.merge`, which resolves each side from the store's chosen, and the
    /// projection only ever LAGS the store — so a re-point landed in the store
    /// and not yet adopted by the surface passed a projection-side compare and
    /// joined a take the sheet never showed. One resolution rule
    /// (`Queries.renderPost`, pinned equivalent to `Operations.renderedVariant`),
    /// one truth for both roads.
    private func refreshMergeSheetIfDrifted(_ state: MergeCeremonyState) async -> MergeSheetDrift {
        state.isRun
            ? await refreshMergeRunIfDrifted(state)
            : await refreshMergePairIfDrifted(state)
    }

    /// **The RUN's drift check** (13u3 UNIT G — the 18f ladder's R3-5; the
    /// pair arm's promise on the rarer surface). Round 2 fenced the check to a
    /// pair on the reading that *"a run's sheet marks a list of blocks, not a
    /// pair"* — true of the sheet it was written against, and false since
    /// figure B's amendment made the list SHOW each block's shown take over
    /// its text. Both run roads resolve the shown takes at act time (the plain
    /// chain through `ops.merge`, i.e. the store's chosen; the carry-all
    /// through `displayed`), so a re-point landed under the open sheet joined
    /// a take the list never showed, and `mergedChain`'s receipt then said
    /// *"the takes you were looking at joined"*.
    ///
    /// The comparison is the whole row — shown id, shown TEXT and take count,
    /// which are the pair arm's own three arms (a take's text, the fan's size,
    /// which take a block shows) read off the list the sheet draws. One read,
    /// the same one `openMergeRunChoice` built the list from.
    private func refreshMergeRunIfDrifted(_ state: MergeCeremonyState) async -> MergeSheetDrift {
        do {
            let read = try await runFansAndRendered(state.blockIDs)
            guard read.blocks != state.runBlocks else { return .current }
            // Every fan folded to a single (or a block dissolved): the two
            // roads are now byte-identically `merge`, so the question has one
            // answer and the ceremony no longer applies — the pair arm's own
            // response when a side dissolves, in the same words. Re-invoke and
            // the door re-decides against truth.
            guard read.otherTakes > 0, read.blocks.allSatisfy({ $0.shownVariantID != nil })
            else {
                mergeCeremony = nil
                model.refuse("These blocks' takes changed — try the merge again.")
                return .refreshed
            }
            var next = state
            next.runBlocks = read.blocks
            next.otherTakes = read.otherTakes
            mergeCeremony = next
            model.direct("The takes changed while the sheet was open — review before merging.")
            return .refreshed
        } catch {
            model.showOperationError(error)
            return .failed
        }
    }

    private func refreshMergePairIfDrifted(_ state: MergeCeremonyState) async -> MergeSheetDrift {
        do {
            // R3-9: the two ids come from the two-block reader now, in the
            // same read as the fans. `Queries.renderPost` answered this by
            // loading every slot's rendered TEXT of the whole note — inside
            // the app's cost model, but ∝ the note where ∝ the pair was
            // available, on a deliberate confirm.
            let (firstFan, secondFan, rendered) = try await liveActiveFansAndRendered(
                state.firstBlockID, state.secondBlockID)
            let snapshot = Dictionary(uniqueKeysWithValues:
                (state.firstTakes + state.secondTakes).map { ($0.id, $0.variant.workingText) })
            let current = firstFan + secondFan
            let drifted = current.count != snapshot.count
                || current.contains { snapshot[$0.id] != $0.workingText }
                || rendered.first != state.firstRenderedID
                || rendered.second != state.secondRenderedID
            guard drifted else { return .current }
            refreshMergeCeremony(
                from: state, firstFan: firstFan, secondFan: secondFan, rendered: rendered)
            return .refreshed
        } catch {
            model.showOperationError(error)
            return .failed
        }
    }

    /// Rebuilds the ceremony over the CURRENT fans: carries survive by
    /// take identity, pairings survive where BOTH sides still live, joins
    /// are kept (the author chose them), previews re-derive from the new
    /// texts, and the shown pair is re-marked from the STORE's rendered takes
    /// (R2-2; the raise). The author reviews and confirms again — nothing is
    /// joined from a drifted snapshot.
    private func refreshMergeCeremony(
        from state: MergeCeremonyState, firstFan: [Variant], secondFan: [Variant],
        rendered: (first: String?, second: String?)
    ) {
        guard !firstFan.isEmpty, !secondFan.isEmpty,
              firstFan.count > 1 || secondFan.count > 1
        else {
            // A side dissolved (or both fans folded to singles): the
            // ceremony no longer applies — re-invoke and the door
            // re-decides against truth.
            mergeCeremony = nil
            model.refuse("These blocks' takes changed — try the merge again.")
            return
        }
        let carried = Set(state.carriedIDs)
        // The row she chose, the run's ids and the sheet's identity SURVIVE
        // the refresh (18f ladder round 2, R2-1 — the divide refresh's own
        // rule, `DivideWCeremony.refresh`, applied here at last); the count
        // is re-read off the fresh fans, since that is what changed.
        var next = MergeCeremonyState(
            firstBlockID: state.firstBlockID, secondBlockID: state.secondBlockID,
            blockIDs: state.blockIDs,
            otherTakes: max(0, firstFan.count - 1) + max(0, secondFan.count - 1),
            runBlocks: state.runBlocks,
            arrangement: state.arrangement,
            firstRenderedID: rendered.first,
            secondRenderedID: rendered.second,
            firstTakes: firstFan.map { MergeTake(variant: $0, carried: carried.contains($0.id)) },
            secondTakes: secondFan.map { MergeTake(variant: $0, carried: carried.contains($0.id)) },
            pairings: [])
        if state.arrangement == .pairByHand {
            // HERS survive by identity, where both sides still live (R2-1).
            let firstIDs = Set(firstFan.map(\.id))
            let secondIDs = Set(secondFan.map(\.id))
            next.pairings = state.pairings.filter {
                firstIDs.contains($0.firstVariantID) && secondIDs.contains($0.secondVariantID)
            }
        } else {
            // **Under a PRESET the pre-pair is invisible** — the preview
            // columns mark the shown pair — so the open-time pre-pair used to
            // survive this refresh by liveness alone while the marking moved
            // (18f ladder R3-7). Pick "Pair by hand…" afterwards and the
            // Pairings section offered head ＋ tail, the pair the sheet no
            // longer marks, so S4-23 ruling 4's "⏎ reproduces the instant
            // outcome" stopped holding after a refresh. It re-seeds from the
            // freshly-read shown pair, exactly as opening does — one rule,
            // `prePairing`.
            next.pairings = prePairing(
                firstFan: firstFan, secondFan: secondFan, rendered: rendered)
        }
        mergeCeremony = next
        // A DIRECTION (row 56's class, named): the sheet REFRESHED itself —
        // nothing was refused, and she must see that her pairings moved.
        model.direct(state.arrangement == .pairByHand
            ? "The takes changed while the sheet was open — review the pairings before merging."
            : "The takes changed while the sheet was open — review before merging.")
    }

    /// What a structural operation reports back to the rewrite path: where
    /// the caret belongs (by identity) and the op's known seam shape — the
    /// differential strategy's input. `seam == nil` means full re-render
    /// (the W ceremony's confirm; author decision 2026-07-07: ceremonial
    /// acts rebuild from the store, permanently).
    struct StructuralOutcome: Sendable {
        let caretBlockID: String
        let caretOffset: Int
        let seam: StructuralSeam?
        /// 13e batch 3: a receipt built INSIDE the flight from the op's own
        /// result (counts the surface could otherwise only re-derive from a
        /// projection read taken beside the write). Spoken by
        /// `runStructural` once the rewrite lands; nil for every door that
        /// speaks its own fixed line, which is all of them before 13e.
        var note: String? = nil
        /// 18i: a note that reports NOTHING HAPPENED is a refusal, not a
        /// receipt — she must see it whatever her confirmations setting
        /// says (P-2). A plain `Bool` and not the centre's `Kind` because
        /// this value is built inside the runner's nonisolated closure.
        /// Only the split-at-newlines doors can produce one.
        var noteIsRefusal = false
    }

    // MARK: - Phase 11, A9: the boundary-fluidity package (committed scope)

    /// The guided cross-block Make Block's confirm state (the ratified
    /// flow: confirm → adjust the neighbor edges → compound divide/divide/
    /// merge under ONE undo entry).
    struct CrossBlockMakeState: Identifiable, Equatable {
        /// One divided edge's plan-time snapshot — the CONFIRM's
        /// compare-and-set input (review round 1, MINOR 5: the alert is a
        /// human-scale window; plan-time cuts must never land on a buffer
        /// that moved under it — the W ceremony's drift class, closed with
        /// the sibling compounds' CAS instead of a re-derive).
        struct EdgeSnapshot: Equatable {
            let variantID: String
            let text: String
        }

        let entryIndices: ClosedRange<Int>
        let blockIDs: [String]
        let startCut: Int
        let endCut: Int
        let firstEdge: EdgeSnapshot?
        let lastEdge: EdgeSnapshot?
        var id: String { blockIDs.joined(separator: "+") }
        var blockCount: Int { blockIDs.count }
    }

    /// The deferred keystroke-compound's handle (#11a/merge-then-edit):
    /// the keystroke is refused synchronously and the compound runs as the
    /// next main-actor turn — this seam CHAINS overlapping schedules and
    /// lets teardown/tests await quiescence. Execution is compare-and-set
    /// against the plan-time texts (`editTakesAtomically`'s expectedText /
    /// the merge compound's verification pass), so a keystroke landing in
    /// the scheduling window makes the compound REFUSE VISIBLY instead of
    /// clobbering newer text — the edit-during-await class, closed at the
    /// op boundary.
    @ObservationIgnored private(set) var pendingCrossBlockTask: Task<Void, Never>?

    @ObservationIgnored private var pendingCrossBlockToken = UUID()

    func scheduleCrossBlockCompound(_ body: @escaping @MainActor () async -> Void) {
        let previous = pendingCrossBlockTask
        let token = UUID()
        pendingCrossBlockToken = token
        pendingCrossBlockTask = Task { @MainActor [weak self] in
            if let previous { await previous.value }
            await body()
            // Round 3, NIT (post-cap): "pending" means pending — the
            // completed handle clears (unless a chained schedule replaced
            // it), so finalizeWork's guard and the quit fast-path read
            // true state instead of a stale completed Task.
            if let self, self.pendingCrossBlockToken == token {
                self.pendingCrossBlockTask = nil
                // 18c ladder round 2, R2-1: the chain just emptied — the
                // keys stashed for whatever it carried (a typed Return's
                // act; a compound a replayed key scheduled) drain now, on
                // the surface every queued act has landed on. A key the
                // drain replays may schedule again; the handle then
                // re-populates and the next tail drains for it.
                self.replayDeferredKeystrokesIfIdle()
            }
        }
    }

    /// **THE ONE DRAIN RULE for deferred keystrokes (18c ladder round 2,
    /// R2-1): the surface is IDLE** — no structural flight is up and no
    /// keystroke compound is queued. Called from a flight's `defer` and from
    /// the compound chain's tail; whichever of the two finds the surface
    /// idle drains and the other declines, so a replay can never land on a
    /// disabled surface, nor ahead of an act still waiting its turn behind a
    /// compound the drain itself scheduled (`EditorTextView.
    /// beginDeferringKeystrokes` carries the whole story, and the round-1
    /// generation token this replaces).
    func replayDeferredKeystrokesIfIdle() {
        guard !structuralInFlight, pendingCrossBlockTask == nil else { return }
        model.textView?.replayDeferredKeystrokes()
    }

    /// The confirm's executor: divide the FIRST block at the snapped start
    /// (its head stays out), divide the LAST at the snapped end (its tail
    /// stays out), merge every in-span piece left-to-right — ONE compound
    /// undo entry (the Make Block pattern), atomic on partial failure,
    /// through the one structural door (full re-render — a deliberate
    /// multi-block act, the mergeChain precedent).
    ///
    /// FANNED divided edges (the #10 sitting ruling, 2026-07-13):
    /// AUTO-PROCEED when the edge's cut maps UNIQUELY into every active
    /// take (CutPropagation — the same seeds the W ceremony uses); the
    /// edge divides through `divideW` with the mapped cuts, so the
    /// out-of-span half keeps its per-take fan while the in-span half
    /// joins the (single-variant) middle by merge's standing semantics.
    /// Where ANY take doesn't map uniquely, the W CEREMONY OPENS for that
    /// block instead — the sheet survives exactly where a genuine per-take
    /// decision exists; never a refusal, never a guess.
    func confirmCrossBlockMakeBlock(_ state: CrossBlockMakeState) async {
        crossBlockMakeConfirm = nil
        let firstIndex = state.entryIndices.lowerBound
        let lastIndex = state.entryIndices.upperBound
        // IDENTITY guard (round 2, MINOR 3): the alert is a human-scale
        // window and nothing suppresses projection adoption under it — a
        // remote structural change can SHIFT entry indices, re-addressing
        // every plan-time position (and the shifted-length
        // misclassification path would skip the text CAS entirely).
        // The plan named BLOCKS; the confirm verifies the indices still
        // address exactly those blocks, or refuses visibly.
        guard state.entryIndices.upperBound < model.index.entries.count,
              model.index.entries[firstIndex].blockID == state.blockIDs.first,
              model.index.entries[lastIndex].blockID == state.blockIDs.last
        else {
            model.refuseFeedback(
                "The blocks moved while the confirm was open — nothing was changed; "
                + "reselect and try again.")
            return
        }
        // PLAN-TIME lengths (round 3, MINOR — post-cap fix): the
        // boundary-vs-interior cut classification must come from the
        // snapshots the plan froze, never from confirm-time lengths — a
        // remote edit crossing the cut length under the open alert would
        // otherwise RECLASSIFY the edge (skipping both its CAS and its
        // divide: a silently wrong-SHAPE compound; the round-1/round-2
        // guards' residual corner). With plan-time lengths a drifted edge
        // always enters the interior branch, where the existing CAS
        // refuses the whole compound before any row changes.
        let firstLength = state.firstEdge.map { ($0.text as NSString).length }
            ?? model.index.entries[firstIndex].length
        let lastLength = state.lastEdge.map { ($0.text as NSString).length }
            ?? model.index.entries[lastIndex].length
        let firstArity = firstIndex < model.slots.count
            ? model.slots[firstIndex].activeVariantCount : 1
        let lastArity = lastIndex < model.slots.count
            ? model.slots[lastIndex].activeVariantCount : 1

        // The mapping reads STORE texts, so the buffer lands first (the
        // runStructural discipline, pulled ahead of the read — runStructural
        // flushes again, harmlessly).
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        var firstCuts: [String: Int]?
        if state.startCut > 0, state.startCut < firstLength, firstArity > 1 {
            guard let cuts = await propagatedCuts(
                blockID: state.blockIDs[0], activeCut: state.startCut)
            else { return }  // the ceremony opened, or the error surfaced
            firstCuts = cuts
        }
        var lastCuts: [String: Int]?
        if state.blockIDs.count > 1, state.endCut > 0, state.endCut < lastLength, lastArity > 1 {
            guard let cuts = await propagatedCuts(
                blockID: state.blockIDs[state.blockIDs.count - 1], activeCut: state.endCut)
            else { return }
            lastCuts = cuts
        }

        let stack = model.session.undoStack
        let frozenFirstCuts = firstCuts
        let frozenLastCuts = lastCuts
        // The divided edges' plan-time snapshots — CAS inputs. Middles
        // merge BY ID (their text drift is harmless: the user named the
        // blocks, not offsets).
        var edgeChecks: [Operations.TakeEdit] = []
        if state.startCut > 0, state.startCut < firstLength, let edge = state.firstEdge {
            edgeChecks.append(Operations.TakeEdit(
                variantID: edge.variantID, newText: edge.text,
                charDelta: 0, expectedText: edge.text))
        }
        if state.blockIDs.count > 1, state.endCut > 0, state.endCut < lastLength,
           let edge = state.lastEdge {
            edgeChecks.append(Operations.TakeEdit(
                variantID: edge.variantID, newText: edge.text,
                charDelta: 0, expectedText: edge.text))
        }
        let frozenEdgeChecks = edgeChecks
        _ = await runStructural { ops in
            try stack.withCompound(label: "Make Block", operations: ops) {
                // COMPARE-AND-SET across the alert's human-scale window
                // (round 1, MINOR 5): an edge buffer that moved since the
                // plan refuses the WHOLE compound before any row changes —
                // never a silently wrong-position split.
                _ = try ops.editTakesAtomically(frozenEdgeChecks, undoLabel: "Make Block")
                var pieces: [String] = []
                if state.startCut > 0, state.startCut < firstLength {
                    if let firstCuts = frozenFirstCuts {
                        // Fanned edge, unique matches everywhere: W-divide —
                        // B stays out with the first-half fan; C (the
                        // second halves) is the in-span piece.
                        pieces.append(try ops.divideW(state.blockIDs[0], cuts: firstCuts).second.block.id)
                    } else {
                        // The successor carries the in-span head; the first
                        // block keeps its out-of-span text and identity.
                        pieces.append(try ops.divide(state.blockIDs[0], cut: state.startCut).block.id)
                    }
                } else if state.startCut == 0 {
                    pieces.append(state.blockIDs[0])
                }  // startCut == firstLength: the first block stays out entirely
                pieces.append(contentsOf: state.blockIDs.dropFirst().dropLast())
                if state.blockIDs.count > 1 {
                    let lastID = state.blockIDs[state.blockIDs.count - 1]
                    if state.endCut > 0, state.endCut < lastLength {
                        if let lastCuts = frozenLastCuts {
                            // Fanned edge: B (the first halves) is the
                            // in-span piece; C stays out with its fan.
                            pieces.append(try ops.divideW(lastID, cuts: lastCuts).first.block.id)
                        } else {
                            // The last block keeps its in-span head; the
                            // minted successor carries the out-of-span tail.
                            _ = try ops.divide(lastID, cut: state.endCut)
                            pieces.append(lastID)
                        }
                    } else if state.endCut >= lastLength {
                        pieces.append(lastID)
                    }  // endCut == 0: the last block stays out entirely
                }
                var mergedID = pieces[0]
                for next in pieces.dropFirst() {
                    // R-13u4-3's DOOR class, stated (13u4 UNIT E3): Make
                    // Block is a deliberate gesture behind a confirm, and
                    // its whole promise is that the SPAN she selected
                    // becomes one block — her ruling's own sentence ("all
                    // newlines within the selected portion part of a single
                    // block"). So the pieces join with the rendering join
                    // and the minted block reads byte-identical to the
                    // selection; under the old space join a span crossing a
                    // paragraph break came back with the break replaced.
                    mergedID = try ops.merge(mergedID, next).block.id
                }
                return StructuralOutcome(caretBlockID: mergedID, caretOffset: 0, seam: nil)
            }
        }
    }

    /// The #10 auto-proceed's mapping: the active take's cut carried into
    /// EVERY other active take by CutPropagation's unique-match (the same
    /// discipline that pre-seeds the W ceremony). Returns nil after either
    /// OPENING THE CEREMONY (some take didn't map — the per-take decision
    /// is genuinely a human's; guidance shown) or surfacing a read error.
    private func propagatedCuts(blockID: String, activeCut: Int) async -> [String: Int]? {
        do {
            let fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let active = fan.filter { $0.status == .active }
            guard let renderedID = model.index.entries
                    .first(where: { $0.blockID == blockID })?.variantID,
                  let rendered = active.first(where: { $0.id == renderedID })
            else {
                model.refuseFeedback(RefusalCopy.message(for: .invalidSelection))
                return nil
            }
            var cuts: [String: Int] = [renderedID: activeCut]
            for take in active where take.id != renderedID {
                guard let mapped = CutPropagation.propose(
                    activeCut: activeCut,
                    activeText: rendered.workingText,
                    targetText: take.workingText)
                else {
                    await openDivideWCeremony(blockID: blockID, activeCut: activeCut)
                    model.directTransiently(
                        "One of this block's takes needs its cut placed by hand — "
                        + "finish Divide choosing takes, then run Make Block from Selection again.")
                    return nil
                }
                cuts[take.id] = mapped
            }
            return cuts
        } catch {
            model.showOperationError(error)
            return nil
        }
    }

    /// A cross-block DESTRUCTIVE EDIT on single-variant blocks (the
    /// author's ratified 2026-07-09 direction — "a cross-seam delete just
    /// works"): the refused keystroke becomes a MERGE-THEN-EDIT compound.
    /// Nil = not eligible — a FANNED span takes the VISIBLE-TAKE edit
    /// instead (the #11a sitting ruling, 2026-07-13); locked/gap/tail
    /// spans keep the speaking refusal.
    ///
    /// **The type and both halves of the act live in
    /// `Shared/EditorBrain/CrossBlockCompound`** — hoisted at mobile round 2,
    /// batch 3 (M22) and REBUILT to her item 5 rulings at 13u1 UNIT 2, where
    /// the phone inherits them instead of copying them (MobileSoul §3). The
    /// name survives here because it is what this controller's callers and
    /// pins have always said.
    typealias CrossBlockEdit = CrossBlockCompound.Plan

    /// A7 (13c 1B): the narrow carve out of the cross-block refusal — a
    /// backspace/forward-delete of the ONE separator beside an EMPTY block
    /// deletes that block instead of refusing.
    ///
    /// **The PLAN — its four ENABLEMENT guards and the why of each — moved to
    /// the shared brain at 18m U1** (`SeamCarvePlan.emptyBlockDeletion`,
    /// `Shared/EditorBrain/EditorEditRoute.swift`, ruled (c1)), so the ONE
    /// cross-block route can decide purely over its facts and the phone's
    /// future carve inherits it (KnownIssues row 51). The name and this
    /// forward stay so every caller and pin reads unchanged (the 3C proof);
    /// the AUTHORIZATION and the road stay here, in `runEmptyBlockDeletion`.
    typealias EmptyBlockDeletion = SeamCarvePlan.EmptyBlockDeletion

    func planEmptyBlockDeletion(range: NSRange, replacement: String) -> EmptyBlockDeletion? {
        SeamCarvePlan.emptyBlockDeletion(
            replacing: range, with: replacement, index: model.index, slots: model.slots)
    }

    /// Runs A7's carve through the one structural door as **ONE
    /// transaction** — `deleteBlock` re-checks the carve's whole
    /// authorization inside the tombstone's own write
    /// (`BlockDeletionPrecondition.emptyWithNothingUnshown`), so exactly one
    /// undo entry lands: "Delete Block".
    ///
    /// 13c Stage 1 ladder, R3-1/R3-3: this used to verify only the TEXT,
    /// through an `editTakesAtomically` with an unchanged buffer, in a
    /// transaction of its own — which left the fan/archive/comment guards
    /// standing on `model.slots`, an array the projection engine
    /// deliberately freezes while the buffer is dirty or a flight is up. A
    /// comment landing during a typing burst was therefore invisible to
    /// them, and the block (and its note) went. The plan-time guards (the
    /// shared `SeamCarvePlan`'s since 18m U1) stay as the ENABLEMENT layer —
    /// fail fast, don't refuse noisily — but the authorization is the
    /// operation's now, where it cannot be a snapshot.
    func runEmptyBlockDeletion(_ plan: EmptyBlockDeletion) async {
        let landing = caretLanding(afterCarving: plan)
        let landed = await runStructural { ops in
            try ops.deleteBlock(
                plan.blockID,
                requiring: .emptyWithNothingUnshown(variantID: plan.variantID))
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        if landed {
            model.showReceipt("Empty block deleted — ⌥⌘Z undoes it.")
        }
    }

    /// **VX-290 — the carve's caret lands where the deleted line break was**
    /// (her report, the ruling; the plan names which side survived —
    /// `SeamCarvePlan.EmptyBlockDeletion.Landing`). Before this the carve
    /// borrowed the Delete Block door's "start of the block below", which put
    /// the caret on the line the carved block had occupied, so each further ⌫
    /// — a deferred fast press included, which replays at this landing —
    /// carved the next block down. The END offset is the survivor's length
    /// as the surface holds it now, read at this call as the doors read
    /// theirs: a key that reached the survivor before this turn stays behind
    /// the caret.
    private func caretLanding(
        afterCarving plan: EmptyBlockDeletion
    ) -> (blockID: String, offset: Int) {
        switch plan.landing {
        case .startOf(let blockID):
            return (blockID, 0)
        case .endOf(let blockID):
            let length = model.index.entries.first { $0.blockID == blockID }?.length ?? 0
            return (blockID, length)
        }
    }

    // MARK: - #34 (13d batch 2): backspace at a TEXTED seam

    /// The pair a seam keystroke would join — and her #34 ruling's PLAN
    /// (geometry + liveness only; the fan is `runSeamMerge`'s store read,
    /// below). **Moved to the shared brain at 18m U1**
    /// (`SeamCarvePlan.textedSeamMerge`, `Shared/EditorBrain/EditorEditRoute
    /// .swift`, ruled (c1)) with the ruling's full text — the precedence at a
    /// deleted separator, why the plan never decides the fan, why locked
    /// takes do not refuse. The name and this forward stay so every caller
    /// and pin reads unchanged (the 3C proof).
    typealias SeamMerge = SeamCarvePlan.SeamMerge

    func planSeamMerge(range: NSRange, replacement: String) -> SeamMerge? {
        SeamCarvePlan.textedSeamMerge(
            replacing: range, with: replacement, index: model.index)
    }

    /// Fires exactly where the explicit merge gesture would be INSTANT, and
    /// refuses exactly where it would open the ceremony — one rule, read
    /// once, from the store.
    func runSeamMerge(_ plan: SeamMerge) async {
        do {
            let (leadingFan, trailingFan) = try await liveActiveFans(
                plan.leadingBlockID, plan.trailingBlockID)
            guard leadingFan.count == 1, trailingFan.count == 1 else {
                model.refuseFeedback(
                    Self.seamFanRefusal(leading: leadingFan.count, trailing: trailingFan.count))
                return
            }
        } catch {
            model.showOperationError(error)
            return
        }
        let landed = await runInstantMerge(
            leadingID: plan.leadingBlockID, trailingID: plan.trailingBlockID,
            // R-13u4-3's DELETE class: this is a keystroke that removed the
            // separator, so the join stays what it has always been. The
            // ruling's rendering join belongs to the doors — here it would
            // put back the exact byte the keystroke deleted.
            joining: .deleteKeystroke)
        if landed {
            // Load-bearing, not chatter (A7's carve set the shape): a
            // structural act landed from an ordinary keystroke, and ⌘Z — the
            // text stack — cannot take it back (the structural rewrite clears
            // it by design). The line names the door that can.
            model.showReceipt("Blocks joined — ⌥⌘Z undoes it.")
        }
    }

    /// Names the fan and points at the doors that can fold it deliberately.
    ///
    /// **13j J4b updated the second sentence, and only that.** #34's ruling
    /// stands verbatim — a keystroke won't fold a fan away — but ⌘⇧M no
    /// longer pairs takes by hand: it CARRIES them all (her 2026-08-09
    /// ruling), and the hand-pairing lives behind ⌥⌘⇧M. Copy that names a
    /// behaviour the app no longer has is the J8 defect class, so the line
    /// names both roads and what each one does.
    static func seamFanRefusal(leading: Int, trailing: Int) -> String {
        let subject: String
        switch (leading > 1, trailing > 1) {
        case (true, true): subject = "Both blocks at this seam have takes"
        case (true, false): subject = "The block above has takes"
        default: subject = "The block below has takes"
        }
        // A2 (ladder A round 1): the roads sentence comes from the ONE home
        // both fan-fold refusals share — see `FannedDefaultsCopy.fanFoldRoads`.
        return subject
            + " — backspace won't fold a fan away. " + FannedDefaultsCopy.fanFoldRoads
    }

    /// The merge ceremony's threshold read, shared by the ⌘⇧M door and the
    /// seam keystroke (S4-23 ruling 4): a merge is INSTANT when neither side
    /// carries a live ACTIVE fan and opens the ceremony when either does.
    /// From the store — never `model.slots`, which is deliberately stale
    /// while the editor is busy.
    private func liveActiveFans(
        _ leadingID: String, _ trailingID: String
    ) async throws -> (leading: [Variant], trailing: [Variant]) {
        try await model.session.database.read { db in
            (try Queries.blockFan(db, blockID: leadingID)
                .filter { $0.deletedAt == nil && $0.status == .active },
             try Queries.blockFan(db, blockID: trailingID)
                .filter { $0.deletedAt == nil && $0.status == .active })
        }
    }

    /// The same read plus **which take each side RENDERS** — the pair sheet's
    /// one snapshot (13u3 UNIT G; R3-6 at open, R3-9's reader for the ids).
    /// Open builds the sheet from it and the drift check compares against it,
    /// so the two can never be answering different questions; and the ids come
    /// from `Queries.renderedVariantIDs`, whose rule is pinned equal to
    /// `renderPost`'s and `Operations.renderedVariant`'s, at the cost of the
    /// TWO blocks named rather than the note around them.
    private func liveActiveFansAndRendered(
        _ leadingID: String, _ trailingID: String
    ) async throws -> (
        leading: [Variant], trailing: [Variant], rendered: (first: String?, second: String?)
    ) {
        try await model.session.database.read { db in
            let rendered = try Queries.renderedVariantIDs(
                db, blockIDs: [leadingID, trailingID])
            return (
                try Queries.blockFan(db, blockID: leadingID)
                    .filter { $0.deletedAt == nil && $0.status == .active },
                try Queries.blockFan(db, blockID: trailingID)
                    .filter { $0.deletedAt == nil && $0.status == .active },
                (rendered[leadingID], rendered[trailingID]))
        }
    }

    /// **The Mac's face on the shared cross-block compound** (her item 5,
    /// 13u1 UNIT 2). The plan is GEOMETRY plus the two fences the surface
    /// itself can answer — it takes NO fan arity, deliberately: the fan
    /// question decides whether the ends JOIN, and a decision read from
    /// `model.slots` would be read from an array the projection engine
    /// freezes for the length of a typing burst. That is U-1's whole finding
    /// (item 8's first), and its correctness half is a law rather than a
    /// preference: **never authorize from stale state.** `runCrossBlockEdit`
    /// asks the STORE instead.
    func planCrossBlockEdit(range: NSRange, replacement: String) -> CrossBlockEdit? {
        CrossBlockCompound.plan(
            replacing: range, with: replacement,
            index: model.index,
            surfaceText: { [model] range in model.viewText(range) })
    }

    /// The Mac's face on the shared compound: this door owns the flight
    /// (`runStructural` — the latch, the pre-op flush, the re-render and the
    /// caret write) and the WORDS; the ordering, the arithmetic and the
    /// rulings are `CrossBlockCompound.apply`'s, so the phone runs the same
    /// rule rather than a second copy of it.
    ///
    /// **The fan read is SYNCHRONOUS and inside the flight** (U-1's
    /// correctness half): `runStructural` has already flushed the buffer and
    /// holds the one-flight latch, and the body runs on the serialized
    /// operations runner — so this read sits as close to the merge as a read
    /// outside its transaction can. The remaining window is the recorded
    /// ms-window sync-apply residual, the W drift check's class, and it is
    /// strictly narrower than the projection's whole typing burst.
    /// **The receipt rides `StructuralOutcome.note`** — 18i's one structural
    /// receipt seam — because it is built from what the compound ACTUALLY
    /// did (how many blocks went to the Trash; whether the ends really
    /// joined), which only exists inside the flight. Her legibility mandate
    /// is exactly this: *receipts name where every block went.*
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        let stack = model.session.undoStack
        let database = model.session.database
        let home = homeKind
        _ = await runStructural { ops in
            let result = try CrossBlockCompound.apply(
                edit, ops: ops, undoStack: stack,
                liveActiveTakeCount: { blockID in
                    try database.read { db in
                        try Queries.blockFan(db, blockID: blockID)
                            .filter { $0.deletedAt == nil && $0.status == .active }
                            .count
                    }
                })
            return StructuralOutcome(
                caretBlockID: result.caretBlockID, caretOffset: result.caretOffset,
                seam: nil, note: CrossBlockEditCopy.receipt(result, home: home))
        }
    }

    // MARK: - Phase 11, A9 — the #11 sitting rulings (2026-07-13)

    // **#11a's VISIBLE-TAKE cross-block edit RETIRED at 13u1 UNIT 2**, and
    // what it ruled is kept rather than dropped.
    //
    // It was the plain gesture's everyday behaviour on a FANNED span: each
    // touched block's visible take lost exactly its piece, and fan, seam and
    // block structure stayed untouched — *two blocks, NOT a join; the fan
    // hangs on the seam.* Item 5's compound now answers every cross-block
    // span, fanned or not, and it carries #11a's rule forward at the ENDS:
    // a fanned surviving end takes its chosen take's edit and NOTHING else,
    // and a fan on either end suppresses the join (read from the store, not
    // from the projection).
    //
    // **What deliberately CHANGED, because she ruled it** (master plan item
    // 5): a FANNED MIDDLE block — one the selection covers WHOLE — now
    // deletes whole to the Trash/tray, *"recoverable, family intact"*, where
    // #11a emptied its shown take and left a blank block with a fan hanging
    // on it. That is the one place this supersedes the 2026-07-13 ruling,
    // and it supersedes it in her own words.

    /// #11b — "Delete in Every Take": the deliberate, NAMED command. The
    /// selection's per-block piece (the visible take's text) is located in
    /// every OTHER active take by UNIQUE match (the #10 discipline — one
    /// occurrence or nothing); matching takes are edited, non-matching
    /// takes are SKIPPED AND REPORTED (her explicit call over
    /// refuse-unless-all-match); locked takes skip with their own reason.
    /// One transaction, one undo compound, insurance-committed.
    func deleteInEveryTake() async {
        guard model.header?.locked != true else {
            model.refuseFeedback(SealedNoteCopy.sentence(act: "edit", words: .mac))
            return
        }
        guard let selection = model.textView?.selectedRange(), selection.length > 0 else {
            model.refuseFeedback("Select the text to delete in every take first.")
            return
        }
        // No tail: the open tail is not a block yet. ONE tiling walk (13u1
        // UNIT 1 — the same accessor-in-a-loop class as `planVisibleTakeEdit`
        // above, on the "Delete in Every Take" road; unnamed by the sweep,
        // found by its own completion rule).
        let entries = model.index.entries
        let ranges = model.index.entryRanges()
        var touched: [Int] = []
        for i in entries.indices {
            if NSIntersectionRange(selection, ranges[i]).length > 0 { touched.append(i) }
        }
        guard let first = touched.first, let last = touched.last,
              selection.location >= ranges[first].location,
              selection.upperBound <= ranges[last].upperBound
        else {
            model.refuseFeedback(RefusalCopy.message(for: .openTailTarget))
            return
        }
        struct Target {
            let blockID: String
            let renderedID: String
            let intraRange: NSRange
            let renderedText: String
        }
        var targets: [Target] = []
        for i in touched {
            guard let variantID = entries[i].variantID, entries[i].editable else {
                // 13j J8(b): this guard KNOWS which of the two it hit — a
                // gap slot or a locked take — so it says which, instead of
                // borrowing a line that listed both plus a third.
                model.refuseFeedback(CrossBlockRefusal.message(
                    for: entries[i].variantID == nil ? .unsyncedBlock : .lockedTake))
                return
            }
            let entryRange = ranges[i]
            let intersection = NSIntersectionRange(selection, entryRange)
            targets.append(Target(
                blockID: entries[i].blockID,
                renderedID: variantID,
                intraRange: NSRange(
                    location: intersection.location - entryRange.location,
                    length: intersection.length),
                renderedText: model.viewText(entryRange)))
        }

        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        // The per-take locate happens against STORE texts (== the flushed
        // surface); skips collect for the visible report.
        var edits: [Operations.TakeEdit] = []
        var applied = 0
        var skipped: [String] = []
        do {
            for target in targets {
                let fan = try await model.session.database.read { db in
                    try Queries.blockFan(db, blockID: target.blockID)
                }
                let needle = (target.renderedText as NSString)
                    .substring(with: target.intraRange)
                for take in fan where take.deletedAt == nil && take.status == .active {
                    if take.id == target.renderedID {
                        let text = target.renderedText as NSString
                        edits.append(Operations.TakeEdit(
                            variantID: take.id,
                            newText: text.replacingCharacters(in: target.intraRange, with: ""),
                            charDelta: target.intraRange.length,
                            expectedText: target.renderedText))
                        applied += 1
                        continue
                    }
                    if take.locked {
                        skipped.append(takeName(take) + " (locked)")
                        continue
                    }
                    if let range = TakeSpanMatch.uniqueRange(of: needle, in: take.workingText) {
                        let text = take.workingText as NSString
                        edits.append(Operations.TakeEdit(
                            variantID: take.id,
                            newText: text.replacingCharacters(in: range, with: ""),
                            charDelta: range.length,
                            expectedText: take.workingText))
                        applied += 1
                    } else {
                        skipped.append(takeName(take) + " (no unique match)")
                    }
                }
            }
        } catch {
            model.showOperationError(error)
            return
        }
        let allEdits = edits
        let caretBlockID = targets[0].blockID
        let caretOffset = targets[0].intraRange.location
        let landed = await runStructural { ops in
            _ = try ops.editTakesAtomically(allEdits, undoLabel: "Delete in Every Take")
            return StructuralOutcome(
                caretBlockID: caretBlockID,
                caretOffset: caretOffset,
                seam: nil)
        }
        if landed {
            // The REPORT is part of the ruling: visible, naming what was
            // skipped — applied-and-reported over refuse-unless-all-match.
            var message = "Deleted in \(applied) take\(applied == 1 ? "" : "s")."
            if !skipped.isEmpty {
                message += " Skipped \(skipped.count): \(skipped.joined(separator: ", "))."
            }
            model.showReceipt(message)
        }
    }

    private func takeName(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return "“\(label)”" }
        let preview = take.workingText.prefix(20)
        return preview.isEmpty ? "an empty take" : "“\(preview)…”"
    }

    // MARK: - 13u4 UNIT C2 — selection → a take on the same block (her item
    // 9, ruled R-13u4-4)

    /// **The Write door.** Her words: *"highlight part of a block and move it
    /// into a take on that block (out of the take it's currently in)"* —
    /// MOVE alone, with the quiet savepoint of the take it left as her ruled
    /// cover for the stay case (R-13u4-4).
    ///
    /// The whole act is the operation's (`moveSpanToNewTake` — one
    /// transaction, one undo entry), and this is only where the span comes
    /// from. Three things this door owes it and does here:
    ///
    /// 1. **the ONE brain's verdict** (`SpanToTakeGesture.plan`), which is
    ///    the same verdict that decided whether the door renders at all — so
    ///    a fired door and a rendered door can never disagree;
    /// 2. **the surface's own text as the compare-and-set image** — read
    ///    BEFORE the flight, exactly as `deleteInEveryTake` reads it, so a
    ///    plan can never land on a buffer that moved under it;
    /// 3. **`runStructural`, the one structural door** — the buffer flushes
    ///    first (so the store text the operation validates equals the surface
    ///    text this planned against), the surface is frozen for the flight,
    ///    keystrokes defer rather than drop, and the text-undo stack is
    ///    cleared by the rewrite because ⌥⌘Z is now the road back.
    ///
    /// `seam: nil` — the block count does not change and no seam shape in
    /// `StructuralSeamEdit` describes "one block's text shrank", so the
    /// rewrite re-renders from the store, which is truth. That is
    /// `deleteInEveryTake`'s and `replaceInEveryTake`'s own posture for the
    /// same reason, and the honest cost of a deliberate, occasional gesture.
    func moveSelectionToNewTake() async {
        guard model.header?.locked != true else {
            model.refuseFeedback(RefusalCopy.message(for: .sealed))
            return
        }
        guard let selection = model.textView?.selectedRange(), selection.length > 0 else {
            model.refuseFeedback(SpanToTakeCopy.nothingSelected)
            return
        }
        guard let plan = SpanToTakeGesture.plan(selection: selection, index: model.index)
        else {
            // The door renders only where a plan exists, so reaching here
            // means the selection moved under an open menu. Say which shape
            // it is now: a span across a seam is the commonest, and it has a
            // road of its own.
            let touchesTail = model.index.tailRange.map {
                NSIntersectionRange(selection, $0).length > 0
            } ?? false
            model.refuseFeedback(
                touchesTail
                    ? RefusalCopy.message(for: .openTailTarget)
                    : SpanToTakeCopy.crossBlockSpan)
            return
        }
        let entryRange = model.index.range(ofEntryAt: plan.entryIndex)
        let expected = model.viewText(entryRange)
        let span = plan.intraRange.location..<plan.intraRange.upperBound
        let variantID = plan.variantID
        let blockID = plan.blockID
        let caretOffset = plan.intraRange.location
        _ = await runStructural { ops in
            let result = try ops.moveSpanToNewTake(
                from: variantID, span: span, expectedText: expected)
            return StructuralOutcome(
                caretBlockID: blockID,
                caretOffset: caretOffset,
                seam: nil,
                note: SpanToTakeCopy.receipt(savedFirst: result.insuranceSavepoint != nil))
        }
    }

    // MARK: - 13e E9 — the takes-aware replace

    /// **"Replace All in Every Take"** — the KnownIssues row *"Find &
    /// replace — the takes-aware half"* (owner 13e), built on its own
    /// named precedent: `deleteInEveryTake`'s APPLY-AND-REPORT shape
    /// (matching takes edited; skipped takes named with their reason;
    /// ONE transaction, ONE undo entry, dirty targets insurance-committed
    /// by `editTakesAtomically`).
    ///
    /// It is deliberately NOT a second find surface (the row's letter):
    /// the matches and both strings are the shipped find bar's, approved
    /// by the shipped gate, and this method is only where they land.
    ///
    /// **Why the whole gesture rides the operations layer** — including
    /// the visible take, which the surface road would type through
    /// `insertText`: the other takes are on no surface at all, so they can
    /// only be written by an operation; putting the visible take through
    /// the same transaction is what makes ONE undo entry cover the act she
    /// performed. The consequence is stated in her report and logged at
    /// #63(c): this act undoes with ⌥⌘Z (structural undo), not ⌘Z.
    func replaceInEveryTake(_ plan: [FindReplaceItem]) async {
        defer { model.findReplaceTask = nil }
        guard model.header?.locked != true else {
            model.refuseFeedback(SealedNoteCopy.sentence(act: "edit", words: .mac))
            return
        }
        guard !plan.isEmpty else { return }

        // Which block each approved match sits in. The gate has already
        // refused anything crossing a boundary or sitting in the open
        // tail, so every item lands inside exactly one editable entry.
        struct Target {
            let blockID: String
            let renderedID: String
            let entryRange: NSRange
            var items: [FindReplaceItem]
        }
        let entries = model.index.entries
        // ONE tiling walk for the WHOLE placement pass (13u1 UNIT 1 — P22).
        // This asked `model.index.range(ofEntryAt: i)` inside a loop that is
        // itself inside the loop over approved matches, so the placement
        // pass was O(Σ_items k_item²) — worst case O(matches × blocks²) — on
        // the main actor, on the Replace-All-in-Every-Take road she presses.
        // The walk is hoisted out of BOTH loops; the inner break is
        // untouched.
        let ranges = model.index.entryRanges()
        var targets: [Target] = []
        var moved = 0
        for item in plan {
            var placed = false
            for i in entries.indices {
                let entryRange = ranges[i]
                guard item.range.location >= entryRange.location,
                      item.range.upperBound <= entryRange.upperBound
                else { continue }
                guard let variantID = entries[i].variantID, entries[i].editable else { break }
                if let existing = targets.firstIndex(where: { $0.blockID == entries[i].blockID }) {
                    targets[existing].items.append(item)
                } else {
                    targets.append(Target(
                        blockID: entries[i].blockID, renderedID: variantID,
                        entryRange: entryRange, items: [item]))
                }
                placed = true
                break
            }
            // No entry owns it any more — the surface moved under the
            // deferred window. The valve's own counter, same voice.
            if !placed { moved += 1 }
        }

        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }

        var edits: [Operations.TakeEdit] = []
        var skipped: [String] = []
        var replacements = 0
        var takesEdited = 0
        var caret: (blockID: String, offset: Int)?
        do {
            for target in targets {
                // The SUBSTRING VALVE, this road's half: the surface text is
                // re-read AFTER the flush, and a match is carried only if it
                // still holds exactly what the finder matched. `expectedText`
                // on every edit is the second layer — the whole batch refuses
                // if a buffer changed under the gesture.
                let renderedText = model.viewText(target.entryRange)
                let surface = renderedText as NSString
                var matches: [TakesReplacePlan.Match] = []
                for item in target.items {
                    let intra = NSRange(
                        location: item.range.location - target.entryRange.location,
                        length: item.range.length)
                    guard intra.upperBound <= surface.length,
                          let expected = item.expected,
                          surface.substring(with: intra) == expected
                    else {
                        moved += 1
                        continue
                    }
                    matches.append(TakesReplacePlan.Match(
                        range: intra, needle: expected, replacement: item.replacement))
                }
                guard !matches.isEmpty else { continue }
                if caret == nil, let first = matches.min(by: { $0.range.location < $1.range.location }) {
                    caret = (target.blockID,
                             first.range.location + (first.replacement as NSString).length)
                }

                let visible = TakesReplacePlan.applyMatches(matches, to: renderedText)
                edits.append(Operations.TakeEdit(
                    variantID: target.renderedID, newText: visible.text,
                    charDelta: visible.charDelta, expectedText: renderedText))
                replacements += matches.count
                takesEdited += 1

                let groups = TakesReplacePlan.groups(from: matches, visibleText: renderedText)
                let fan = try await model.session.database.read { db in
                    try Queries.blockFan(db, blockID: target.blockID)
                }
                for take in fan where take.deletedAt == nil && take.id != target.renderedID {
                    // Skipped AND REPORTED, never silently — the row's letter.
                    guard take.status == .active else {
                        skipped.append(takeName(take) + " (archived)")
                        continue
                    }
                    guard !take.locked else {
                        skipped.append(takeName(take) + " (locked)")
                        continue
                    }
                    switch TakesReplacePlan.apply(groups, toOtherTake: take.workingText) {
                    case .edited(let text, let charDelta, let count):
                        edits.append(Operations.TakeEdit(
                            variantID: take.id, newText: text,
                            charDelta: charDelta, expectedText: take.workingText))
                        replacements += count
                        takesEdited += 1
                    case .noMatch:
                        skipped.append(takeName(take) + " (no match)")
                    case .ambiguous:
                        skipped.append(takeName(take) + " (appears more than once)")
                    }
                }
            }
        } catch {
            model.showOperationError(error)
            return
        }

        guard !edits.isEmpty else {
            model.refuseFeedback(
                FindReplaceGate.nothingReplacedInAnyTake(moved: moved, skipped: skipped))
            return
        }
        let allEdits = edits
        let landing = caret ?? (blockID: targets[0].blockID, offset: 0)
        let landed = await runStructural { ops in
            _ = try ops.editTakesAtomically(allEdits, undoLabel: "Replace in Every Take")
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        if landed {
            model.showReceipt(FindReplaceGate.replacedInEveryTake(
                replacements: replacements, takes: takesEdited,
                skipped: skipped, moved: moved))
        }
    }

    // `StructuralSeam` lives beside its pure consumer in
    // StructuralSeamEdit.swift (review round 1, MINOR 5).

    /// Runs one structural operation through the runner and applies its
    /// outcome to the surface. Returns true when the operation landed.
    ///
    /// Discipline: the buffer flushes FIRST, so the store text the operation
    /// validates against equals the surface text the planner snapped
    /// against; the view is non-editable for the few-ms flight so no
    /// keystroke can slip between the flush and the operation (a stale
    /// whole-buffer autosave after a divide would resurrect the moved half —
    /// the forbidden text-duplication class).
    ///
    /// SELF-guarding (review round 3, MINOR): one flight at a time is
    /// enforced HERE, at the door itself, so every entrance — gestures via
    /// `applyStructural` AND the W ceremony's confirm — refuses while a
    /// flight is up. Overlapping flights would share the one
    /// `structuralInFlight` flag: the first finisher's defer would clear it
    /// and re-enable editing while the other was still between its op and
    /// its rewrite — reopening the keystroke window this fence closes.
    private func runStructural(
        _ body: @escaping @Sendable (Operations) throws -> StructuralOutcome
    ) async -> Bool {
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return false
        }
        structuralInFlight = true
        // The idle-mint clock is held for the flight (review round 1,
        // MAJOR): a mint must never be born between the pre-op mint wait
        // and the rewrite. idleMintTail's own guard is the second door.
        model.holdTailIdleClock()
        model.textView?.isEditable = false
        // 18c ladder round 1, R1-2: keystrokes during the flight are
        // DEFERRED, never dropped — AppKit discards typed input to the
        // disabled surface, and with ⏎ a structural act this window sat on
        // the hottest key in the app.
        model.textView?.beginDeferringKeystrokes()
        defer {
            structuralInFlight = false
            model.textView?.isEditable = model.header.map { !$0.locked } ?? false
            // Any surviving tail gets its clock back (arming is a no-op
            // when no non-blank tail exists).
            model.armTailIdleMint()
            // A projection deferred during the flight applies now (round 3
            // NIT: deliveries defer while a flight is up).
            model.applyPendingIfClean()
            // …and the keys she typed meanwhile land now, at the landed
            // caret — LAST, once the surface is settled (R1-2), and ONLY if
            // nothing is still queued behind this flight (round 2, R2-1: a
            // queued act's keys are its own; the chain's tail drains them).
            // A replayed ⏎ that re-arms for a chained act keeps what
            // follows it.
            replayDeferredKeystrokesIfIdle()
        }
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            // A refused flush keeps its text pending (Phase 7 MAJOR 1); a
            // structural op against a store that disagrees with the surface
            // must not run.
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        // An in-flight crystallization mint reconciles before the rewrite
        // (its tail bookkeeping must not land on a rewritten surface).
        await model.awaitMintSettle()
        do {
            let outcome = try await model.session.runner.run(body)
            let fresh = try await model.session.database.read { [postID = model.postID] in
                try Queries.renderPost($0, containerID: postID)
            }
            applyStructuralResult(fresh, outcome: outcome)
            // 13e batch 3: a receipt the op itself computed (see
            // `StructuralOutcome.note`), spoken once the surface agrees with
            // the store.
            // 18i: THE structural receipt seam — every door that hands
            // `runStructural` a note is reporting an act that landed, so
            // the whole family (divide, merge, split-at-newlines, convert,
            // delete) becomes a receipt at this ONE line. The one exception
            // declares itself: a note that says nothing happened.
            if let note = outcome.note {
                outcome.noteIsRefusal ? model.refuse(note) : model.showReceipt(note)
            }
            return true
        } catch {
            model.showOperationError(error)
            return false
        }
    }

    /// The single structural rewrite path — TWO strategies behind the ONE
    /// door (author decision 2026-07-07, superseding the full-re-render
    /// PROVISIONAL): the everyday gestures apply DIFFERENTIALLY (minimal
    /// text edits derived from the op result's known seams — untouched text
    /// never moves, the 2026-07-07 promise; no UNCONDITIONAL restore step —
    /// since 18l-b U-B5 the keeper below puts the untouched reading line
    /// back iff TextKit moved it, KnownIssues row 88); the W ceremony's
    /// confirm (seam == nil) and any seam whose expected shape the fresh
    /// projection doesn't match re-render fully from the store. Both
    /// strategies clear text-undo (stale-offset replays don't care which
    /// strategy rewrote) and place the caret BY IDENTITY.
    ///
    /// **The differential strategy KEEPS the untouched reading line (18l-b
    /// U-B5 — KnownIssues row 88):** the line the viewport's top is reading is
    /// captured BEFORE the rewrite, and once the result's synchronous work is
    /// done (the caret placed, its context refreshed — the last layout-forcing
    /// reads of this turn) `keepUntouchedReadingLine` puts it back exactly if
    /// TextKit moved it. A no-op on settled geometry; the full strategy
    /// restores through `renderFull`'s own anchor, unchanged.
    private func applyStructuralResult(
        _ fresh: [Queries.RenderedBlock], outcome: StructuralOutcome
    ) {
        let reading = outcome.seam == nil ? nil : model.readingAnchor()
        var differentialEditStart: Int?
        if let seam = outcome.seam,
           let editStart = applyDifferentialStructural(seam, fresh: fresh) {
            // Differential landed; bookkeeping done inside.
            differentialEditStart = editStart
        } else {
            renderFull(fresh, preserveTail: true)
        }
        if let textView = model.textView,
           let i = model.index.entries.firstIndex(where: { $0.blockID == outcome.caretBlockID }) {
            let range = model.index.range(ofEntryAt: i)
            let offset = range.location + min(max(0, outcome.caretOffset), range.length)
            textView.setSelectedRange(NSRange(location: offset, length: 0))
            model.updateCaretContext()
        }
        if let reading, let differentialEditStart {
            model.keepUntouchedReadingLine(reading, editStartingAt: differentialEditStart)
        }
        model.applyPendingIfClean()
    }

    // MARK: - The differential structural apply (author decision 2026-07-07)

    /// Applies the pure derivation's minimal edit to the storage (the
    /// derivation itself lives in `StructuralSeamEdit.derive` — review
    /// round 1, MINOR 5: pure computation out of the view model, so its
    /// guard fallbacks are directly testable). Returns false when the
    /// derivation refuses — the fresh projection doesn't match what the
    /// edit would assume (seam shape, non-seam geometry, or the retained
    /// bytes; a concurrent sync apply landed between the op and the fetch)
    /// — and the caller then re-renders fully from the store, truth, in
    /// EVERY build. On success it returns where the edit BEGAN (pre-edit
    /// document coordinates) — the line the keeper may hold is one that
    /// starts before it (18l-b U-B5).
    private func applyDifferentialStructural(
        _ seam: StructuralSeam, fresh: [Queries.RenderedBlock]
    ) -> Int? {
        guard let textView = model.textView, textView.textStorage != nil else { return nil }
        let edit = StructuralSeamEdit.derive(
            seam, oldIndex: model.index,
            oldTextAt: { [weak model] i in
                guard let model, i >= 0, i < model.index.entries.count else { return "" }
                return model.viewText(model.index.range(ofEntryAt: i))
            },
            fresh: fresh)
        guard let edit else { return nil }

        // Apply: one storage edit, then the attribute re-bracketing — the
        // storage bytes move through the model's seam primitive (the
        // storage owner keeps its plumbing).
        model.applySeamEdit(edit)

        // Adopt the fresh projection as the tiling truth (a value rebuild,
        // no surface cost — the store leads; nothing here was diffed).
        model.adoptRewrite(
            index: BlockRangeIndex(
                slots: fresh, tail: model.hasOpenTail ? model.tailText : nil),
            slots: fresh, tailText: nil)
        // The directive: text-undo clears on EVERY structural rewrite —
        // offsets after the seam shifted; a stale replay is the corruption
        // class regardless of rewrite strategy.
        textView.undoManager?.removeAllActions()
        verifyDifferentialOracle(fresh)
        model.refreshBadges()
        return edit.replaceRange.location
    }

    /// The DEBUG-ONLY oracle (author-directed posture): after every
    /// differential apply, the surface must equal the store's fresh
    /// projection — the soak exercising this with zero firings is the proof
    /// the differential lands safely. On a miss: count (test-visible),
    /// assert, heal via `renderFull`. NOTHING here compiles into release —
    /// there, a divergence that slipped the shape guard (a remote race
    /// changing the seam entry's text without changing shape) stands until
    /// the next projection delivery heals it, and that delivery is already
    /// in flight by construction: the same sync apply that caused the
    /// divergence fired the observation (review round 1, MINOR 3 — the
    /// release tripwire was considered and declined; disposition in the
    /// closeout).
    private func verifyDifferentialOracle(_ fresh: [Queries.RenderedBlock]) {
        #if DEBUG
        var matches = model.index.documentLength == (model.textView?.textStorage?.length ?? -1)
        if matches {
            // ONE tiling walk (13u1 UNIT 1 — the same accessor-in-a-loop
            // class, DEBUG-only but on every differential structural apply,
            // which is to say on every Debug build's every divide/merge).
            // (`adoptRewrite` above set the index FROM `fresh`, so the two
            // counts are equal by construction — no bounds guard is added,
            // for the same reason `applyDifferential` adds none.)
            let ranges = model.index.entryRanges()
            for (j, slot) in fresh.enumerated() {
                if model.viewText(ranges[j]) != (slot.text ?? "") {
                    matches = false
                    break
                }
            }
        }
        guard !matches else { return }
        differentialOracleMisses += 1
        assertionFailure("differential structural apply diverged from the store projection")
        renderFull(fresh, preserveTail: true)
        #endif
    }

    /// The visible snap (contract item 2): the selection moves to the
    /// snapped cut/span as part of the invoke — never silently, never as a
    /// separate confirm step.
    private func visiblySnap(_ range: NSRange) {
        model.textView?.setSelectedRange(range)
        model.updateCaretContext()
    }

    // MARK: - The W ceremony — the host conformance + forwards
    // (13d Batch 3: the state machine lives in `DivideWCeremony` so a
    // takes board can mount the same sheet; every body below is either a
    // forward or the host contract, and every pre-move pin runs unchanged
    // through them.)

    /// The rendered take of `blockID` on THIS surface — Write's seed. The
    /// full-document editor shows the CHOSEN take, so "the take you are
    /// looking at" and "the chosen take" are one sentence here; a takes
    /// board names its own seed (that is the generalization A9 needed).
    private func openDivideWCeremony(blockID: String, activeCut: Int?) async {
        let seed = model.index.entries.first { $0.blockID == blockID }?.variantID
        await ceremony.open(blockID: blockID, seedVariantID: seed, seedCut: activeCut)
    }

    func toggleWTake(_ takeID: String) {
        ceremony.toggleTake(takeID)
    }

    func placeWCut(takeID: String, cut: Int) {
        ceremony.placeCut(takeID: takeID, cut: cut)
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelDivideW() {
        ceremony.cancel()
    }

    func confirmDivideWCeremony() async {
        await ceremony.confirm()
    }
}

// MARK: - DivideWCeremonyHost (13d Batch 3)

extension EditorSurfaceController: DivideWCeremonyHost {
    var ceremonyDatabase: AppDatabase { model.session.database }

    /// Write's pending-text contract, unchanged: flush, and a REFUSED
    /// flush (which keeps its text pending — Phase 7 MAJOR 1) stops the
    /// act rather than running an op against a store the surface
    /// disagrees with.
    func flushPendingText() async -> Bool {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        return true
    }

    var structuralFlightInProgress: Bool { structuralInFlight }

    /// The confirm's act: `runStructural` exactly as before — seam nil, so
    /// the W confirm re-renders fully from the store (the permanent shape
    /// for ceremonial acts; author, 2026-07-07).
    ///
    /// **ONE caret rule for both divide shapes (18f ladder round 1, R1-13 —
    /// fable-reviewer, on the orchestrator's steer; PROVISIONAL):** the caret
    /// lands at the SECOND successor's start — where ⌘⇧D lands it
    /// (`runKeepOnTopDivide`), the cut's own position. The sheet used to
    /// land it at the FIRST successor's start, so "confirming the sheet
    /// unchanged reproduces the instant divide" was true of the rows and not
    /// of where she found herself afterwards.
    func runDivideW(
        blockID: String, cuts: [String: Int], displayedVariantID: String?
    ) async -> Bool {
        await runStructural { ops in
            let result = try ops.divideW(
                blockID, cuts: cuts, displayedVariantID: displayedVariantID)
            return StructuralOutcome(
                caretBlockID: result.second.block.id, caretOffset: 0, seam: nil)
        }
    }

    /// U-5's third preset, on the same terms: `runStructural`, seam nil, the
    /// caret at the second successor's start (the one rule above).
    func runDivideDuplicating(
        blockID: String, displayedVariantID: String, cut: Int
    ) async -> Bool {
        await runStructural { ops in
            let result = try ops.divideDuplicating(
                blockID, displayedVariantID: displayedVariantID, cut: cut)
            return StructuralOutcome(
                caretBlockID: result.second.block.id, caretOffset: 0, seam: nil)
        }
    }

    func speakCeremonyStatus(_ message: String) {
        model.refuse(message)
    }

    /// 18i: the ceremony’s one RECEIPT (the released original’s note) —
    /// its other four calls are refusals ("the takes changed, try again").
    func speakCeremonyReceipt(_ message: String) {
        model.showReceipt(message)
    }

    func speakCeremonyRefusal(_ message: String) {
        model.refuseFeedback(message)
    }

    func speakCeremonyError(_ error: Error) {
        model.showOperationError(error)
    }
}
