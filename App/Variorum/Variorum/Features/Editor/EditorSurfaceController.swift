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

    /// A divide invoked on a fanned block routes here: the W ceremony's ONE
    /// sheet (contract item 3). Non-nil = the sheet is up; the live editor
    /// is untouched for the ceremony's whole duration; cancel sets nil with
    /// no rows touched; confirm funnels back through the structural door.
    var divideWCeremony: DivideWCeremonyState?

    var crossBlockMakeConfirm: CrossBlockMakeState?

    /// One structural gesture lands at a time (Phase 9): the door is busy
    /// from invoke to rewrite, and a second invoke refuses visibly.
    /// Readable so the review-round pins can stage mid-flight interleavings.
    @ObservationIgnored private(set) var structuralInFlight = false

    /// Times the differential-apply DEBUG oracle found the surface diverged
    /// from the store projection — the soak asserts ZERO (the author-
    /// directed proof that the differential path lands safely).
    @ObservationIgnored private(set) var differentialOracleMisses = 0

    struct DivideWCeremonyState: Equatable, Identifiable {
        let blockID: String
        /// The rendered variant at invoke time — pre-marked, its cut
        /// pre-placed at the gesture's snapped position.
        let activeVariantID: String?
        var takes: [WTake]
        var id: String { blockID }

        /// Every marked take needs a legal cut before the mint (the op's
        /// own requirement, mirrored so Confirm can gate).
        var canConfirm: Bool {
            let marked = takes.filter(\.marked)
            return !marked.isEmpty && marked.allSatisfy { $0.cut != nil }
        }

        var markedCuts: [String: Int] {
            Dictionary(uniqueKeysWithValues: takes.compactMap { take in
                guard take.marked, let cut = take.cut else { return nil }
                return (take.variant.id, cut)
            })
        }
    }

    struct WTake: Equatable, Identifiable {
        let variant: Variant
        var marked: Bool
        /// The cut carried through this take (UTF-16, interior boundary of
        /// its text) — pre-seeded by string-context matching, freely
        /// adjusted; nil = unseeded (no unique match) until placed.
        var cut: Int?
        /// The legal cut positions in this take's text (interior
        /// sentence/paragraph boundaries) — the click-to-place targets.
        let boundaries: [Int]
        var id: String { variant.id }
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
        let (attributed, newIndex) = EditorDocument.materialize(new, tail: tail)
        model.setSurfaceContent(attributed)
        model.adoptRewrite(index: newIndex, slots: new, tailText: tail ?? "")
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
    func invokeGesture(_ command: StructuralGesturePlanner.Command) async {
        guard let textView = model.textView else { return }
        let plan = StructuralGesturePlanner.plan(
            command, selection: textView.selectedRange(), world: model.gestureWorld())
        await applyStructural(plan)
    }

    /// THE one door for structural changes to the surface (plan ground
    /// rule): every gesture funnels through here; nothing else rewrites the
    /// editor for a structural result. The store leads — the surface is
    /// never pre-written optimistically; the rewrite renders the operation's
    /// known outcome, and the observation's later arrival is our own echo
    /// (`surfaceMatches` skips it).
    func applyStructural(_ plan: StructuralGesturePlanner.Plan) async {
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return
        }
        switch plan {
        case .refusal(let refusal):
            model.refuseFeedback(RefusalCopy.message(for: refusal))

        case .divideW(_, let blockID, let activeCut):
            // Contract item 3: the W ceremony is ONE sheet; the live editor
            // is untouched for its whole duration. Opening touches no rows —
            // confirm funnels back through this door.
            await openDivideWCeremony(blockID: blockID, activeCut: activeCut)

        case .divide(let i, let blockID, let cut):
            // Snap-and-proceed, visibly (contract item 2): the caret lands
            // on the snapped cut as part of the one invoke.
            visiblySnap(NSRange(
                location: model.index.range(ofEntryAt: i).location + cut, length: 0))
            _ = await runStructural { ops in
                let result = try ops.divide(blockID, cut: cut)
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: 0,  // the successor's start
                    seam: .divide(entryIndex: i, sourceID: blockID, successorID: result.block.id))
            }

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
            // N-way merge (author 2026-07-09, supersedes the binary rule):
            // a left-to-right chain of the existing binary merges under ONE
            // undo entry (withCompound, the Make Block pattern). A deliberate
            // multi-block act takes the full-render door (seam: nil) — the
            // differential seam edit stays the binary merge's.
            let leadingLength = model.index.entries[indices.lowerBound].length
            let chainOtherTakes = mergedAwayTakes(Array(indices))
            let stack = model.session.undoStack
            let chainLanded = await runStructural { ops in
                try stack.withCompound(label: "Merge Blocks", operations: ops) {
                    var mergedID = blockIDs[0]
                    var mergedLength = 0
                    for nextID in blockIDs.dropFirst() {
                        let result = try ops.merge(mergedID, nextID)
                        mergedID = result.block.id
                        mergedLength = result.variant.workingText.utf16.count
                    }
                    // Caret at the FIRST join (merge keeps the leading text
                    // verbatim, so the leading length still addresses it).
                    return StructuralOutcome(
                        caretBlockID: mergedID,
                        caretOffset: min(leadingLength, mergedLength),
                        seam: nil)
                }
            }
            if chainLanded { speakAboutMergedFans(chainOtherTakes) }
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
        model.showTransientStatus(
            otherTakes == 1
                ? "Merged the visible takes — 1 other take stays with the released block in lineage (undo brings it back here)."
                : "Merged the visible takes — \(otherTakes) other takes stay with the released blocks in lineage (undo brings them back here).")
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
    struct CrossBlockEdit: Sendable, Equatable {
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

        static func == (lhs: CrossBlockEdit, rhs: CrossBlockEdit) -> Bool {
            lhs.blockIDs == rhs.blockIDs
                && lhs.pieces.elementsEqual(rhs.pieces, by: ==)
                && lhs.intraStart == rhs.intraStart
                && lhs.intraEndInLast == rhs.intraEndInLast
                && lhs.lastPieceLength == rhs.lastPieceLength
                && lhs.replacement == rhs.replacement
        }
        /// The last block's surface length at plan time (locates the tail
        /// suffix in the merged text — derived from op output, never
        /// re-guessed).
        let lastPieceLength: Int
        let replacement: String
    }

    func planCrossBlockEdit(range: NSRange, replacement: String) -> CrossBlockEdit? {
        let entries = model.index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = model.index.range(ofEntryAt: i)
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
        guard range.location >= model.index.range(ofEntryAt: first).location,
              range.upperBound <= model.index.range(ofEntryAt: last).upperBound
        else { return nil }
        for i in touched {
            guard entries[i].variantID != nil, entries[i].editable else { return nil }
            // A fanned block routes to the VISIBLE-TAKE edit instead (the
            // #11a sitting ruling, 2026-07-13 — merge-then-edit stays the
            // single×single behavior: the halves JOIN only where no fan
            // hangs on the seam).
            guard i < model.slots.count, model.slots[i].activeVariantCount == 1 else { return nil }
        }
        let firstRange = model.index.range(ofEntryAt: first)
        let lastRange = model.index.range(ofEntryAt: last)
        return CrossBlockEdit(
            blockIDs: touched.map { entries[$0].blockID },
            pieces: touched.map {
                (entries[$0].variantID!, model.viewText(model.index.range(ofEntryAt: $0)))
            },
            intraStart: max(0, range.location - firstRange.location),
            intraEndInLast: min(lastRange.length, max(0, range.upperBound - lastRange.location)),
            lastPieceLength: lastRange.length,
            replacement: replacement)
    }

    /// The compound itself: merge the touched run left-to-right, then apply
    /// the intended edit to the merged buffer — ONE undo compound, one
    /// serialized runner body, through the one structural door. The mapped
    /// range's ends live in the verbatim-preserved leading/trailing pieces,
    /// so the join characters merge minted die with the deleted span — the
    /// surface reads exactly "the selection vanished" (her principle: text
    /// that looks like basic text behaves like basic text).
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        let stack = model.session.undoStack
        _ = await runStructural { ops in
            try stack.withCompound(label: "Merge & Edit", operations: ops) {
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
                return StructuralOutcome(
                    caretBlockID: mergedID,
                    caretOffset: start + (edit.replacement as NSString).length,
                    seam: nil)
            }
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
        for (position, i) in touched.enumerated() {
            guard let variantID = entries[i].variantID, entries[i].editable else { return nil }
            let entryRange = model.index.range(ofEntryAt: i)
            let intersection = NSIntersectionRange(range, entryRange)
            let intraRange = NSRange(
                location: intersection.location - entryRange.location,
                length: intersection.length)
            // The replacement (if any) rides the FIRST piece.
            _ = position
            pieces.append(VisibleTakeEdit.Piece(
                variantID: variantID,
                intraRange: intraRange,
                text: model.viewText(entryRange)))
        }
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
            model.refuseFeedback("This post is sealed — unlock it to edit.")
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
                model.refuseFeedback(model.message(for: .crossesBlockBoundary))
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

    // MARK: - The W ceremony (Step 6, contract item 3)

    /// Builds the one-sheet ceremony state: the block's live ACTIVE fan as
    /// a checklist (the rendered take pre-marked with the gesture's snapped
    /// cut), per-take cut proposals by string-context matching, per-take
    /// legal cut positions. The buffer flushes first so every take's stored
    /// text — what the sheet shows and the op will cut — matches the
    /// surface. No rows are touched by opening.
    private func openDivideWCeremony(blockID: String, activeCut: Int) async {
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let activeVariantID = model.index.entries.first { $0.blockID == blockID }?.variantID
        do {
            let fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            guard liveActive.count > 1,
                  let activeTake = liveActive.first(where: { $0.id == activeVariantID })
            else {
                // The fan changed under us (sync race): re-plan next invoke.
                model.showStatus("This block's takes changed — try the divide again.")
                return
            }
            let takes = liveActive.map { variant in
                WTake(
                    variant: variant,
                    marked: variant.id == activeTake.id,
                    cut: variant.id == activeTake.id
                        ? activeCut
                        : CutPropagation.propose(
                            activeCut: activeCut,
                            activeText: activeTake.workingText,
                            targetText: variant.workingText),
                    boundaries: interiorBoundaries(of: variant.workingText))
            }
            divideWCeremony = DivideWCeremonyState(
                blockID: blockID, activeVariantID: activeTake.id, takes: takes)
        } catch {
            model.showOperationError(error)
        }
    }

    private func interiorBoundaries(of text: String) -> [Int] {
        let end = text.utf16.count
        return BoundarySnapping.boundaries(in: text, granularity: .sentence)
            .filter { $0 != 0 && $0 != end }
    }

    func toggleWTake(_ takeID: String) {
        guard var state = divideWCeremony,
              let i = state.takes.firstIndex(where: { $0.id == takeID }) else { return }
        state.takes[i].marked.toggle()
        divideWCeremony = state
    }

    func placeWCut(takeID: String, cut: Int) {
        guard var state = divideWCeremony,
              let i = state.takes.firstIndex(where: { $0.id == takeID }),
              state.takes[i].boundaries.contains(cut) else { return }
        state.takes[i].cut = cut
        divideWCeremony = state
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelDivideW() {
        divideWCeremony = nil
    }

    func confirmDivideWCeremony() async {
        guard let state = divideWCeremony, state.canConfirm else { return }
        // The one-flight door, checked synchronously BEFORE the drift
        // check's await (review round 3, MINOR): a gesture can be mid-
        // flight while the sheet is up (menu key equivalents stay live
        // under a window-modal sheet) — refuse visibly and KEEP the
        // ceremony and its cuts; `runStructural`'s own self-guard is the
        // belt behind this.
        guard !structuralInFlight else {
            model.refuseFeedback("Another structural change is still landing.")
            return
        }
        let cuts = state.markedCuts
        let blockID = state.blockID
        // The sheet may have sat open while a sync round landed edits to
        // the takes (review round 2, MINOR): cuts were placed against the
        // SNAPSHOT texts, and cutting the current store at those offsets
        // would land a well-formed but wrong-position cut, silently. Verify
        // every marked take against the CURRENT store first; on any drift,
        // refresh the ceremony (marks kept, cuts re-seeded) instead.
        do {
            let fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            let drifted = state.takes.filter(\.marked).contains { snapshot in
                guard let current = liveActive.first(where: { $0.id == snapshot.id })
                else { return true }  // a marked take vanished (deleted/archived remotely)
                return current.workingText != snapshot.variant.workingText
            }
            if drifted {
                refreshDivideWCeremony(from: state, liveActive: liveActive)
                return
            }
        } catch {
            model.showOperationError(error)
            return
        }
        // Accepted residual (review round 3, NIT — same class as the
        // ceremony-open flush→fetch window): the drift check above is
        // check-then-act — a sync apply committing in the ms between that
        // read and the op below still lands a stale-offset cut. A true fix
        // needs op-level expected-text preconditions (a core change this
        // phase has no cause to make); the cut stays well-formed,
        // recoverable by undo, and the window is delivery-cadence narrow.
        // Recorded in the closeout's residuals.
        let landed = await runStructural { ops in
            let result = try ops.divideW(blockID, cuts: cuts)
            // seam nil: the W confirm re-renders fully from the store —
            // the permanent shape for ceremonial acts (author, 2026-07-07).
            return StructuralOutcome(
                caretBlockID: result.first.block.id, caretOffset: 0, seam: nil)
        }
        // The sheet dismisses only when the cut LANDED — a refusal (busy
        // door, op error) keeps the ceremony and its cuts for the author.
        if landed {
            divideWCeremony = nil
        }
    }

    /// Rebuilds the ceremony over the CURRENT fan: marks survive by take
    /// identity, unchanged takes keep their placed cuts, changed takes get
    /// re-seeded cuts (the active take's cut re-snapped into its new text;
    /// others re-proposed from it via string-context matching). The author
    /// reviews and confirms again — nothing is cut on a drifted snapshot.
    private func refreshDivideWCeremony(
        from state: DivideWCeremonyState, liveActive: [Variant]
    ) {
        guard liveActive.count > 1,
              let activeCurrent = liveActive.first(where: { $0.id == state.activeVariantID })
        else {
            // The fan itself dissolved (a single take remains, or the
            // rendered take died): the ceremony no longer applies.
            divideWCeremony = nil
            model.showStatus("This block's takes changed — try the divide again.")
            return
        }
        let previous = Dictionary(uniqueKeysWithValues: state.takes.map { ($0.id, $0) })
        let previousActive = previous[activeCurrent.id]
        let activeCut: Int? = {
            guard let cut = previousActive?.cut else { return nil }
            if previousActive?.variant.workingText == activeCurrent.workingText { return cut }
            return StructuralGesturePlanner.snapToInteriorBoundary(
                cut, in: activeCurrent.workingText)
        }()
        let takes = liveActive.map { variant -> WTake in
            let old = previous[variant.id]
            let cut: Int?
            if variant.id == activeCurrent.id {
                cut = activeCut
            } else if old?.variant.workingText == variant.workingText, let kept = old?.cut {
                cut = kept
            } else if let activeCut {
                cut = CutPropagation.propose(
                    activeCut: activeCut,
                    activeText: activeCurrent.workingText,
                    targetText: variant.workingText)
            } else {
                cut = nil
            }
            return WTake(
                variant: variant,
                marked: old?.marked ?? false,
                cut: cut,
                boundaries: interiorBoundaries(of: variant.workingText))
        }
        divideWCeremony = DivideWCeremonyState(
            blockID: state.blockID, activeVariantID: activeCurrent.id, takes: takes)
        model.showStatus("This block's takes changed while the sheet was open — the cuts were re-proposed; review before dividing.")
    }
}
