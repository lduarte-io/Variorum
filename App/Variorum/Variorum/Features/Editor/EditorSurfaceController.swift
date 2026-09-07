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
    /// so earlier ranges stay valid. Cost ∝ changed blocks, never the post.
    func applyDifferential(_ new: [Queries.RenderedBlock]) {
        var edited = false
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            let range = model.index.range(ofEntryAt: i)
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
        let anchor = model.topVisibleOffset()
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
                toOffset: min(anchor, max(0, model.index.documentLength)),
                textView: textView, scrollView: model.scrollView)
        } else if let saved = model.session.editorRouter.scrollAnchors[model.postID] {
            JumpPrimitive.jump(
                toOffset: min(saved, max(0, model.index.documentLength)),
                textView: textView, scrollView: model.scrollView)
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
                model.showTransientStatus(
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
            // pairs keep the instant path byte-unchanged. (The slots' arity
            // is the door's cheap gate; the open re-reads the true fans and
            // falls back to the instant path if the projection was stale.)
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
                guard leadingArity > 1 || trailingArity > 1 else {
                    model.refuseFeedback(FannedDefaultsCopy.mergeCeremonyNeedsAFan)
                    return
                }
                await openMergeCeremony(
                    leadingIndex: leadingIndex, trailingIndex: trailingIndex,
                    leadingID: leadingID, trailingID: trailingID)
            } else if leadingArity > 1 || trailingArity > 1 {
                await runCarryAllMerge(
                    leadingIndex: leadingIndex, trailingIndex: trailingIndex,
                    leadingID: leadingID, trailingID: trailingID)
            } else {
                await runInstantMerge(
                    leadingIndex: leadingIndex, trailingIndex: trailingIndex,
                    leadingID: leadingID, trailingID: trailingID)
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

        case .mergeChain(let indices, let blockIDs):
            guard !ceremony else {
                // The pairing ceremony is PAIRWISE by construction (S4-23) —
                // it has two columns. A run of three or more has no ceremony
                // to open, so the door says so and names the one that acts.
                model.refuseFeedback(
                    FannedDefaultsCopy.mergeCeremonyIsPairwise(blocks: blockIDs.count))
                return
            }
            await runMergeChain(indices: indices, blockIDs: blockIDs)
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
        model.showTransientStatus(
            otherTakes == 1
                ? "Merged the visible takes — 1 other take stays with the released block "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes)."
                : "Merged the visible takes — \(otherTakes) other takes stay with the released blocks "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes).")
    }

    /// The everyday instant merge — today's exact `.merge` body, byte-
    /// unchanged (13b 4B moved it behind the ceremony threshold; unfanned
    /// pairs and the stale-projection fallthrough land here).
    @discardableResult
    private func runInstantMerge(
        leadingIndex: Int, trailingIndex: Int, leadingID: String, trailingID: String
    ) async -> Bool {
        let trailingLength = model.index.entries[trailingIndex].length
        // #11c (the sitting ruling, 2026-07-13): merge on fanned blocks
        // SPEAKS about what it does to the fan.
        let otherTakes = mergedAwayTakes([leadingIndex, trailingIndex])
        let landed = await runStructural { ops in
            let result = try ops.merge(leadingID, trailingID)
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
    /// ONE reason: divideW's own entry is labelled "Divide into Variants"
    /// (the ceremony's name, correct while the ceremony was its only
    /// caller), and the Edit menu must keep reading **Undo Divide** for the
    /// everyday gesture. One leg in, one entry out — the compound's inverse
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
                + " Divide with Ceremony (⌥⌘⇧D) can send a whole take to one side.")
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
            // identity) — `openMergeCeremony`'s own fallthrough, same shape.
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
            model.showStatus(FannedDefaultsCopy.takesChangedDivide)
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
                    results, whenNothingSplit: SplitAtNewlinesCopy.noteAlreadyWhole))
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
                    [result], whenNothingSplit: SplitAtNewlinesCopy.blockAlreadyWhole))
        }
    }

    /// **J4b's road: the carry-all merge.** ONE pairing of the two displayed
    /// takes plus every other active take carried whole, composed from this
    /// app's own `mergeCeremony` — zero core change, and the instant no-fan
    /// merge above stays byte-unchanged behind its own threshold.
    private func runCarryAllMerge(
        leadingIndex: Int, trailingIndex: Int, leadingID: String, trailingID: String
    ) async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let fans: (leading: [Variant], trailing: [Variant])
        do {
            fans = try await liveActiveFans(leadingID, trailingID)
        } catch {
            model.showOperationError(error)
            return
        }
        guard fans.leading.count > 1 || fans.trailing.count > 1 else {
            // The store says unfanned — the instant merge, byte-unchanged
            // (the ceremony door's own fallthrough, one road over).
            await runInstantMerge(
                leadingIndex: leadingIndex, trailingIndex: trailingIndex,
                leadingID: leadingID, trailingID: trailingID)
            return
        }
        guard let composition = CarryAllMerge.compose(
            leadingDisplayedID: model.index.entries.first { $0.blockID == leadingID }?.variantID,
            leadingFan: fans.leading,
            trailingDisplayedID: model.index.entries.first { $0.blockID == trailingID }?.variantID,
            trailingFan: fans.trailing)
        else {
            model.showStatus(FannedDefaultsCopy.takesChangedMerge)
            return
        }
        let trailingLength = trailingIndex < model.index.entries.count
            ? model.index.entries[trailingIndex].length : 0
        _ = await runStructural { ops in
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
    private func runMergeChain(indices: ClosedRange<Int>, blockIDs: [String]) async {
        let leadingLength = indices.lowerBound < model.index.entries.count
            ? model.index.entries[indices.lowerBound].length : 0
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
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
            return
        }
        let displayed = Dictionary(
            uniqueKeysWithValues: model.index.entries
                .filter { blockIDs.contains($0.blockID) }
                .map { ($0.blockID, $0.variantID) })
        // A5 (ladder A round 1): validate BEFORE the compound — a fanned
        // link whose displayed take vanished under the gesture used to fall
        // to plain `merge` inside it, folding that fan to lineage with no
        // speech. The whole run refuses up front (nothing touched), the
        // pair road's own words.
        guard CarryAllMerge.chainComposes(
            order: blockIDs, fans: fans, displayed: displayed)
        else {
            model.showStatus(FannedDefaultsCopy.takesChangedMerge)
            return
        }
        let stack = model.session.undoStack
        _ = await runStructural { ops in
            try stack.withCompound(label: "Merge Blocks", operations: ops) {
                var mergedID = blockIDs[0]
                var leadingFan = fans[blockIDs[0]] ?? []
                var leadingDisplayedID = displayed[blockIDs[0]] ?? nil
                var mergedLength = 0
                // What LANDED on the merged block, counted from the ops'
                // own answers — so a link that fell to the plain road
                // (genuinely unfanned, or a take that vanished under the
                // gesture) can never inflate the receipt.
                var takesOnMerged = leadingFan.count
                for nextID in blockIDs.dropFirst() {
                    let trailingFan = fans[nextID] ?? []
                    if leadingFan.count > 1 || trailingFan.count > 1,
                       let composition = CarryAllMerge.compose(
                        leadingDisplayedID: leadingDisplayedID, leadingFan: leadingFan,
                        trailingDisplayedID: displayed[nextID] ?? nil,
                        trailingFan: trailingFan) {
                        let result = try ops.mergeCeremony(
                            mergedID, nextID,
                            pairings: [composition.pairing], carries: composition.carries)
                        let joined = CarryAllMerge.joinedTake(of: result)
                        mergedID = result.block.id
                        leadingFan = result.variants
                        leadingDisplayedID = joined?.id
                        mergedLength = joined?.workingText.utf16.count ?? 0
                        takesOnMerged = result.variants.count
                    } else {
                        let result = try ops.merge(mergedID, nextID)
                        mergedID = result.block.id
                        leadingFan = [result.variant]
                        leadingDisplayedID = result.variant.id
                        mergedLength = result.variant.workingText.utf16.count
                        takesOnMerged = 1
                    }
                }
                // Caret at the FIRST join (merge keeps the leading text
                // verbatim, so the leading length still addresses it).
                return StructuralOutcome(
                    caretBlockID: mergedID,
                    caretOffset: min(leadingLength, mergedLength),
                    seam: nil,
                    note: FannedDefaultsCopy.mergedChain(
                        blocks: blockIDs.count, carried: max(0, takesOnMerged - 1)))
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
        if landed { model.showStatus("New block added below — type away.") }
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
        switch model.typedReturnAct() {
        case .content, .nothing:
            // `.nothing` is the empty block's ruled no-op (U-19 (2)):
            // consumed, deliberately not spoken.
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
            model.showStatus(TakeStructureCopy.movedNote)
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
        if landed { model.showStatus(BlockSelectionCopy.archivedNote(home: homeKind)) }
    }

    /// The one delete-block body both doors use: the menu/bar act above and
    /// A7's empty-block backspace below.
    private func runDeleteBlock(_ blockID: String, entryIndex: Int, note: String) async {
        let landing = caretLandingAfterRemoving(entryIndex)
        let landed = await runStructural { ops in
            try ops.deleteBlock(blockID)
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        if landed {
            model.showStatus(note + (await StrandedOriginals.note(
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
            model.showStatus(
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
    /// Mac-only doors — A7's empty-block carve, delete/archive-caret-block —
    /// and the phone has no consumer for it, so hoisting it would be a Mac
    /// refactor riding a mobile batch. Recorded rather than done.)*
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
        var id: String { firstBlockID + "+" + secondBlockID }

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
            if pairings.isEmpty && carriedIDs.isEmpty {
                return "Nothing would land on the merged block — pair takes with ＋, or check “carry” on at least one."
            }
            return nil
        }

        var canConfirm: Bool { confirmBlocker == nil }
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
    /// If the true fans turn out unfanned (the slots' arity was a stale
    /// projection), the instant path runs instead — the threshold rule
    /// reads truth, not the projection.
    private func openMergeCeremony(
        leadingIndex: Int, trailingIndex: Int, leadingID: String, trailingID: String
    ) async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        do {
            // The threshold read, shared with the seam keystroke since 13d
            // batch 2 — ONE fan rule, one place (#34's point 2).
            let (firstFan, secondFan) = try await liveActiveFans(leadingID, trailingID)
            guard firstFan.count > 1 || secondFan.count > 1 else {
                await runInstantMerge(
                    leadingIndex: leadingIndex, trailingIndex: trailingIndex,
                    leadingID: leadingID, trailingID: trailingID)
                return
            }
            let firstRenderedID = model.index.entries
                .first { $0.blockID == leadingID }?.variantID
            let secondRenderedID = model.index.entries
                .first { $0.blockID == trailingID }?.variantID
            var state = MergeCeremonyState(
                firstBlockID: leadingID, secondBlockID: trailingID,
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
            if let head = firstFan.first(where: { $0.id == firstRenderedID }),
               let tail = secondFan.first(where: { $0.id == secondRenderedID }) {
                state.pairings = [MergePairingDraft(
                    firstVariantID: head.id, secondVariantID: tail.id,
                    join: model.session.mergeJoinMemory
                        ?? MergeJoin.canon(head: head.workingText, tail: tail.workingText))]
            }
            mergeCeremony = state
        } catch {
            model.showOperationError(error)
        }
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
                ?? MergeJoin.canon(
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

    func confirmMergeCeremony() async {
        guard let state = mergeCeremony, state.canConfirm else { return }
        // The one-flight door, checked synchronously BEFORE any await (the
        // W confirm's discipline): refuse visibly and KEEP the ceremony.
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return
        }
        // The sheet may have sat open while a sync round landed edits (the
        // W confirm's drift class): the previews and the canon-default
        // joins were derived from SNAPSHOT texts. Verify both fans against
        // the CURRENT store first; on any drift, refresh the ceremony
        // (pairings and carries kept by take identity, previews re-derived)
        // instead of confirming what the author wasn't shown.
        do {
            let (firstFan, secondFan) = try await model.session.database.read {
                db -> ([Variant], [Variant]) in
                (try Queries.blockFan(db, blockID: state.firstBlockID)
                    .filter { $0.deletedAt == nil && $0.status == .active },
                 try Queries.blockFan(db, blockID: state.secondBlockID)
                    .filter { $0.deletedAt == nil && $0.status == .active })
            }
            let snapshot = Dictionary(uniqueKeysWithValues:
                (state.firstTakes + state.secondTakes).map { ($0.id, $0.variant.workingText) })
            let current = firstFan + secondFan
            let drifted = current.count != snapshot.count
                || current.contains { snapshot[$0.id] != $0.workingText }
            if drifted {
                refreshMergeCeremony(from: state, firstFan: firstFan, secondFan: secondFan)
                return
            }
        } catch {
            model.showOperationError(error)
            return
        }
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
        model.showTransientStatus(
            count == 1
                ? "Merged — 1 take stays with the released blocks in lineage "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes)."
                : "Merged — \(count) takes stay with the released blocks in lineage "
                    + "(\(TrayPath.originalsPath); ⌥⌘Z undoes).")
    }

    /// Rebuilds the ceremony over the CURRENT fans: carries survive by
    /// take identity, pairings survive where BOTH sides still live, joins
    /// are kept (the author chose them), previews re-derive from the new
    /// texts. The author reviews and confirms again — nothing is joined
    /// from a drifted snapshot.
    private func refreshMergeCeremony(
        from state: MergeCeremonyState, firstFan: [Variant], secondFan: [Variant]
    ) {
        guard !firstFan.isEmpty, !secondFan.isEmpty,
              firstFan.count > 1 || secondFan.count > 1
        else {
            // A side dissolved (or both fans folded to singles): the
            // ceremony no longer applies — re-invoke and the door
            // re-decides against truth.
            mergeCeremony = nil
            model.showStatus("These blocks' takes changed — try the merge again.")
            return
        }
        let carried = Set(state.carriedIDs)
        var next = MergeCeremonyState(
            firstBlockID: state.firstBlockID, secondBlockID: state.secondBlockID,
            firstRenderedID: state.firstRenderedID,
            secondRenderedID: state.secondRenderedID,
            firstTakes: firstFan.map { MergeTake(variant: $0, carried: carried.contains($0.id)) },
            secondTakes: secondFan.map { MergeTake(variant: $0, carried: carried.contains($0.id)) },
            pairings: [])
        let firstIDs = Set(firstFan.map(\.id))
        let secondIDs = Set(secondFan.map(\.id))
        next.pairings = state.pairings.filter {
            firstIDs.contains($0.firstVariantID) && secondIDs.contains($0.secondVariantID)
        }
        mergeCeremony = next
        model.showStatus("The takes changed while the sheet was open — review the pairings before merging.")
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
            }
        }
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
                    model.showTransientStatus(
                        "One of this block's takes needs its cut placed by hand — "
                        + "finish the take ceremony, then run Make Block from Selection again.")
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
    /// **The type and both halves of the act HOISTED** to
    /// `Shared/EditorBrain/CrossBlockEditPlanner` at mobile round 2, batch 3
    /// (M22), where the phone inherits them instead of copying them
    /// (MobileSoul §3). The name survives here because it is what this
    /// controller's callers and pins have always said.
    typealias CrossBlockEdit = CrossBlockEditPlanner.Edit

    /// A7 (13c 1B): the narrow carve out of the cross-block refusal — a
    /// backspace/forward-delete of the ONE separator beside an EMPTY block
    /// deletes that block instead of refusing.
    ///
    /// **Where the authorization actually lives, since round 3 moved it**
    /// (13c Stage 1 ladder, R3-1). The four guards below are the
    /// ENABLEMENT layer: they read `model.slots`, decide fast, and let an
    /// ordinary seam keystroke fall through to the ratified refusal without
    /// a noisy message. They are NOT the authorization, because `slots` is
    /// deliberately held stale whenever the editor is busy
    /// (`EditorProjectionPolicy.decide` returns `.deferUntilClean` while the
    /// buffer is dirty or a mint/structural flight is up, and autosave's
    /// debounce re-arms on every keystroke — so for a whole typing burst
    /// this array is frozen). A comment arriving in that window — from sync,
    /// or from her own comments sheet — was invisible to guard 3, and the
    /// block went with its note.
    ///
    /// The authorization is now `Operations.BlockDeletionPrecondition
    /// .emptyWithNothingUnshown`, re-read INSIDE the tombstone's own
    /// transaction (see `runEmptyBlockDeletion`). Read the two together:
    /// what follows says WHY each condition matters; the operation is what
    /// makes it true at the moment the row is written.
    ///
    /// The four guards, and together they are what keeps the carve from
    /// widening:
    ///
    /// 1. the block's SURFACE text is empty (the index's rule) — a block
    ///    with any text keeps the ratified refusal;
    /// 2. the block has NO FAN (`activeVariantCount == 1`) — takes are
    ///    text, and a seam-key must never take one away unseen;
    /// 3. the block carries NO UNSHOWN TEXT — `carriesUnshownText`, the ONE
    ///    read that answers the carve's only authorization ("there is no
    ///    text to lose"). Two kinds live behind it, found one ladder round
    ///    apart and deliberately wired through one name rather than two
    ///    parallel guards: an **archived take** (R1-1 — archive is
    ///    out-of-the-fan, not gone; reachable in three ordinary gestures:
    ///    branch · archive the one with the prose · blank the survivor) and
    ///    a **block COMMENT** (R2-1 — `addBlockComment` has no empty-block
    ///    rule, and a note on an empty block is ordinary: *"I'll rewrite
    ///    this — see the note"*). Both die in `deleteBlock`'s cascade, and
    ///    the comment half additionally defeats AppSpec §7's ratified
    ///    "deleted comments are visible and resurrectable — never skimpy",
    ///    since `deletedBlockComments` is keyed by block and a tombstoned
    ///    block is only in the tray;
    /// 4. the slot is editable (a live variant, unlocked, not a gap).
    ///
    /// PROVISIONAL (13c R2-1, QUESTIONS #40): a NAMED or CALLOUT empty
    /// block still carves. `block.name` and `block.presentation` are
    /// columns on the block row — the tombstone keeps them, undo and
    /// `restoreBlock` bring them back with the block, and the tray lists
    /// the block by its name — so nothing of them becomes unrecoverable,
    /// which is the line the two counted kinds cross. Guarding on every
    /// datum attached to a block (tags cascade too) would narrow the carve
    /// back out of existence and undo A7.
    ///
    /// Every one of the four is re-checked in the operation's own
    /// transaction, so a sync apply — or her comments sheet, or another
    /// surface — changing any of them between the keystroke and the write
    /// refuses the whole gesture rather than deleting text nobody saw.
    struct EmptyBlockDeletion: Sendable, Equatable {
        let blockID: String
        let variantID: String
        let entryIndex: Int
    }

    func planEmptyBlockDeletion(range: NSRange, replacement: String) -> EmptyBlockDeletion? {
        guard replacement.isEmpty,
              let i = model.index.emptyBlockDeletion(replacing: range, isDeletion: true)
        else { return nil }
        let entry = model.index.entries[i]
        guard entry.editable, let variantID = entry.variantID else { return nil }
        // No fan: a block with several takes carries text in the ones you
        // are not looking at, so the "nothing to lose" argument fails.
        guard i < model.slots.count, model.slots[i].activeVariantCount == 1 else { return nil }
        // …and nothing the slot does not SHOW (R1-1's archived take, R2-1's
        // block comments). This is the guard that actually says "there is
        // no text to lose"; a third kind of unshown prose extends
        // `carriesUnshownText`, never this line.
        guard !model.slots[i].carriesUnshownText else { return nil }
        return EmptyBlockDeletion(blockID: entry.blockID, variantID: variantID, entryIndex: i)
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
    /// them, and the block (and its note) went. The plan-time guards below
    /// stay as the ENABLEMENT layer — fail fast, don't refuse noisily — but
    /// the authorization is the operation's now, where it cannot be a
    /// snapshot.
    func runEmptyBlockDeletion(_ plan: EmptyBlockDeletion) async {
        let landing = caretLandingAfterRemoving(plan.entryIndex)
        let landed = await runStructural { ops in
            try ops.deleteBlock(
                plan.blockID,
                requiring: .emptyWithNothingUnshown(variantID: plan.variantID))
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.offset, seam: nil)
        }
        if landed {
            model.showStatus("Empty block deleted — ⌥⌘Z undoes it.")
        }
    }

    // MARK: - #34 (13d batch 2): backspace at a TEXTED seam

    /// The pair a seam keystroke would join. Geometry + liveness only — the
    /// fan question is `runSeamMerge`'s, on the store (see below).
    struct SeamMerge: Sendable, Equatable {
        let leadingIndex: Int
        let trailingIndex: Int
        let leadingBlockID: String
        let trailingBlockID: String
    }

    /// Her QUESTIONS #34 ruling (13c ratify walk, 2026-07-27), option (ii):
    /// **backspace at a seam between two TEXTED blocks MERGES when NEITHER
    /// block has takes, and refuses-and-speaks when either does.** The second
    /// named exception to the ratified cross-block destructive-edit refusal —
    /// A7's empty-block carve (13c 1B) is the first, and this one is granted
    /// on a different argument: not *"there is no text to lose"* but *"basic
    /// text should behave like basic text"*, her own words at #34.
    ///
    /// The precedence at a deleted inter-block separator, in order:
    /// 1. **A7's carve** — an empty neighbour with nothing unshown: the block
    ///    goes (exactly as shipped; its guards and #40/#42's rulings are
    ///    untouched by this batch);
    /// 2. **this** — both neighbours texted, neither fanned: the ordinary
    ///    binary MERGE of the two, through the standing gesture path;
    /// 3. **this, refusing** — both texted, either side fanned: the fan is
    ///    named and the explicit door pointed at. A keystroke must never fold
    ///    a fan away, and must never open a sheet.
    ///
    /// What this plan deliberately does NOT decide is the fan. There is
    /// exactly ONE fan rule in the app — the merge ceremony's own threshold
    /// (S4-23 ruling 4: any live active fan on either side opens the
    /// ceremony) — and it is read from the STORE, never from `model.slots`,
    /// which the projection engine deliberately freezes for the length of a
    /// typing burst. That freeze is what the 13c ladder's R3-1 finding was
    /// about, one door over: a plan-time guard reading it is an enablement
    /// hint, never an authorization. Here the authorization is the run's
    /// truth read, and a fan arriving mid-burst therefore stops the merge
    /// (pinned).
    ///
    /// Locked takes deliberately do NOT refuse: merge COPIES the rendered
    /// texts and never edits a buffer, so the explicit gesture allows them
    /// (Phase 3 op semantics, `StructuralGesturePlanner.merge`) and parity is
    /// the rule for this door too. A sealed post never reaches here —
    /// `shouldChangeText` refuses at the seal before any plan runs.
    func planSeamMerge(range: NSRange, replacement: String) -> SeamMerge? {
        guard replacement.isEmpty,
              let (leading, trailing) = model.index.textedSeamPair(
                deleting: range, isDeletion: true)
        else { return nil }
        let entries = model.index.entries
        // A gap slot has nothing to merge (the planner's `.gapSlot` refusal);
        // by geometry a gap is length 0 and so is never a texted seam, but
        // the pair the merge gesture requires is stated here rather than
        // inferred.
        guard entries[leading].variantID != nil, entries[trailing].variantID != nil
        else { return nil }
        return SeamMerge(
            leadingIndex: leading, trailingIndex: trailing,
            leadingBlockID: entries[leading].blockID,
            trailingBlockID: entries[trailing].blockID)
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
            leadingIndex: plan.leadingIndex, trailingIndex: plan.trailingIndex,
            leadingID: plan.leadingBlockID, trailingID: plan.trailingBlockID)
        if landed {
            // Load-bearing, not chatter (A7's carve set the shape): a
            // structural act landed from an ordinary keystroke, and ⌘Z — the
            // text stack — cannot take it back (the structural rewrite clears
            // it by design). The line names the door that can.
            model.showStatus("Blocks joined — ⌥⌘Z undoes it.")
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

    /// The Mac's face on the shared plan (M22's hoist): the index, the
    /// per-entry fan arities beside it, and the live surface text.
    func planCrossBlockEdit(range: NSRange, replacement: String) -> CrossBlockEdit? {
        CrossBlockEditPlanner.plan(
            replacing: range, with: replacement,
            index: model.index,
            fanArities: model.slots.map(\.activeVariantCount),
            surfaceText: { [model] range in model.viewText(range) })
    }

    /// The Mac's face on the shared compound (M22's hoist): this door owns
    /// the flight (`runStructural` — the latch, the pre-op flush, the
    /// re-render and the caret write); the merge chain and the merged-range
    /// arithmetic are `CrossBlockEditPlanner.apply`'s, so the phone runs the
    /// same rule rather than a second copy of it.
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        let stack = model.session.undoStack
        _ = await runStructural { ops in
            let landing = try CrossBlockEditPlanner.apply(edit, ops: ops, undoStack: stack)
            return StructuralOutcome(
                caretBlockID: landing.blockID, caretOffset: landing.caretOffset, seam: nil)
        }
    }

    // MARK: - Phase 11, A9 — the #11 sitting rulings (2026-07-13)

    /// #11a — the VISIBLE-TAKE cross-block edit: the plain gesture's
    /// everyday behavior on a FANNED span (supersedes the shipped refusal).
    /// Each touched block's VISIBLE take loses exactly its piece of the
    /// selection (the replacement, if any, lands where typing started —
    /// the first block's cut point); fan, seam, and block structure stay
    /// UNTOUCHED — the ruled deviation from basic text: the result is two
    /// blocks, NOT a join; the fan hangs on the seam. Never guesses:
    /// nothing is touched in unseen takes.
    struct VisibleTakeEdit: Sendable, Equatable {
        struct Piece: Sendable, Equatable {
            let variantID: String
            /// The piece's intra-take range in the take's CURRENT text.
            let intraRange: NSRange
            /// The take's surface text at plan time (flushed = store text).
            let text: String
        }
        let pieces: [Piece]
        let replacement: String
        /// Caret identity after the compound.
        let caretBlockID: String
        let caretOffset: Int
    }

    /// Nil = not eligible (gap/locked visible take, tail overlap, or a
    /// single-block range) — the remaining refusal speaks.
    func planVisibleTakeEdit(range: NSRange, replacement: String) -> VisibleTakeEdit? {
        let entries = model.index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = model.index.range(ofEntryAt: i)
            if NSIntersectionRange(range, entryRange).length > 0 {
                touched.append(i)
            }
        }
        guard touched.count >= 2, let first = touched.first, let last = touched.last else {
            return nil
        }
        guard range.location >= model.index.range(ofEntryAt: first).location,
              range.upperBound <= model.index.range(ofEntryAt: last).upperBound
        else { return nil }
        var pieces: [VisibleTakeEdit.Piece] = []
        for i in touched {
            guard let variantID = entries[i].variantID, entries[i].editable else { return nil }
            let entryRange = model.index.range(ofEntryAt: i)
            let intersection = NSIntersectionRange(range, entryRange)
            let intraRange = NSRange(
                location: intersection.location - entryRange.location,
                length: intersection.length)
            pieces.append(VisibleTakeEdit.Piece(
                variantID: variantID,
                intraRange: intraRange,
                text: model.viewText(entryRange)))
        }
        // The replacement (if any) rides the FIRST piece — placed by
        // `runVisibleTakeEdit`, which empties every later piece's slot.
        return VisibleTakeEdit(
            pieces: pieces,
            replacement: replacement,
            caretBlockID: entries[first].blockID,
            caretOffset: max(0, range.location - model.index.range(ofEntryAt: first).location)
                + (replacement as NSString).length)
    }

    /// The compound: ONE `editTakesAtomically` (one transaction, one undo
    /// entry, dirty targets insurance-committed) through the structural
    /// door — the flush-first fence keeps a pending autosave of the
    /// pre-delete surface from resurrecting the deleted span.
    func runVisibleTakeEdit(_ edit: VisibleTakeEdit) async {
        _ = await runStructural { ops in
            var edits: [Operations.TakeEdit] = []
            for (i, piece) in edit.pieces.enumerated() {
                let text = piece.text as NSString
                guard piece.intraRange.upperBound <= text.length else {
                    throw OperationError.invalidCut(
                        variantID: piece.variantID, cut: piece.intraRange.location)
                }
                let replacement = i == 0 ? edit.replacement : ""
                let newText = text.replacingCharacters(in: piece.intraRange, with: replacement)
                edits.append(Operations.TakeEdit(
                    variantID: piece.variantID,
                    newText: newText,
                    charDelta: piece.intraRange.length + (replacement as NSString).length,
                    expectedText: piece.text))
            }
            _ = try ops.editTakesAtomically(edits, undoLabel: "Delete Across Blocks")
            return StructuralOutcome(
                caretBlockID: edit.caretBlockID, caretOffset: edit.caretOffset, seam: nil)
        }
    }

    /// #11b — "Delete in Every Take": the deliberate, NAMED command. The
    /// selection's per-block piece (the visible take's text) is located in
    /// every OTHER active take by UNIQUE match (the #10 discipline — one
    /// occurrence or nothing); matching takes are edited, non-matching
    /// takes are SKIPPED AND REPORTED (her explicit call over
    /// refuse-unless-all-match); locked takes skip with their own reason.
    /// One transaction, one undo compound, insurance-committed.
    func deleteInEveryTake() async {
        guard model.header?.locked != true else {
            model.refuseFeedback("This note is sealed — unlock it to edit.")
            return
        }
        guard let selection = model.textView?.selectedRange(), selection.length > 0 else {
            model.refuseFeedback("Select the text to delete in every take first.")
            return
        }
        // No tail: the open tail is not a block yet.
        let entries = model.index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = model.index.range(ofEntryAt: i)
            if NSIntersectionRange(selection, entryRange).length > 0 { touched.append(i) }
        }
        guard let first = touched.first, let last = touched.last,
              selection.location >= model.index.range(ofEntryAt: first).location,
              selection.upperBound <= model.index.range(ofEntryAt: last).upperBound
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
            let entryRange = model.index.range(ofEntryAt: i)
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
            model.showStatus(message)
        }
    }

    private func takeName(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return "“\(label)”" }
        let preview = take.workingText.prefix(20)
        return preview.isEmpty ? "an empty take" : "“\(preview)…”"
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
            model.refuseFeedback("This note is sealed — unlock it to edit.")
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
        var targets: [Target] = []
        var moved = 0
        for item in plan {
            var placed = false
            for i in entries.indices {
                let entryRange = model.index.range(ofEntryAt: i)
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
            model.showStatus(FindReplaceGate.replacedInEveryTake(
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
        defer {
            structuralInFlight = false
            model.textView?.isEditable = model.header.map { !$0.locked } ?? false
            // Any surviving tail gets its clock back (arming is a no-op
            // when no non-blank tail exists).
            model.armTailIdleMint()
            // A projection deferred during the flight applies now (round 3
            // NIT: deliveries defer while a flight is up).
            model.applyPendingIfClean()
        }
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            // A refused flush keeps its text pending (Phase 7 MAJOR 1); a
            // structural op against a store that disagrees with the surface
            // must not run.
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
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
            if let note = outcome.note { model.showStatus(note) }
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
    /// never moves, no scroll restore step exists at all); the W ceremony's
    /// confirm (seam == nil) and any seam whose expected shape the fresh
    /// projection doesn't match re-render fully from the store. Both
    /// strategies clear text-undo (stale-offset replays don't care which
    /// strategy rewrote) and place the caret BY IDENTITY.
    private func applyStructuralResult(
        _ fresh: [Queries.RenderedBlock], outcome: StructuralOutcome
    ) {
        if let seam = outcome.seam, applyDifferentialStructural(seam, fresh: fresh) {
            // Differential landed; bookkeeping done inside.
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
    /// EVERY build.
    private func applyDifferentialStructural(
        _ seam: StructuralSeam, fresh: [Queries.RenderedBlock]
    ) -> Bool {
        guard let textView = model.textView, textView.textStorage != nil else { return false }
        let edit = StructuralSeamEdit.derive(
            seam, oldIndex: model.index,
            oldTextAt: { [weak model] i in
                guard let model, i >= 0, i < model.index.entries.count else { return "" }
                return model.viewText(model.index.range(ofEntryAt: i))
            },
            fresh: fresh)
        guard let edit else { return false }

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
        return true
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
            for (j, slot) in fresh.enumerated() {
                if model.viewText(model.index.range(ofEntryAt: j)) != (slot.text ?? "") {
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
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        return true
    }

    var structuralFlightInProgress: Bool { structuralInFlight }

    /// The confirm's act: `runStructural` exactly as before — seam nil, so
    /// the W confirm re-renders fully from the store (the permanent shape
    /// for ceremonial acts; author, 2026-07-07).
    func runDivideW(blockID: String, cuts: [String: Int]) async -> Bool {
        await runStructural { ops in
            let result = try ops.divideW(blockID, cuts: cuts)
            return StructuralOutcome(
                caretBlockID: result.first.block.id, caretOffset: 0, seam: nil)
        }
    }

    func speakCeremonyStatus(_ message: String) {
        model.showStatus(message)
    }

    func speakCeremonyRefusal(_ message: String) {
        model.refuseFeedback(message)
    }

    func speakCeremonyError(_ error: Error) {
        model.showOperationError(error)
    }
}
