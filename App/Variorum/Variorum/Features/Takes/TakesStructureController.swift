//
//  TakesStructureController.swift
//  Variorum
//
//  Phase 13e, LADDER ROUND A (A-2 — the P-9 finding): the takes/lenses
//  board's STRUCTURAL DOORS, lifted out of `TakesViewModel`.
//
//  The constitution names `TakesViewModel` as P-9's standing counterexample,
//  and this phase grew it from 2057 to 2521 lines: the pure brains came out
//  as they were written (`BlockSelection`, `TakeClipboard`, the ordering
//  resolver), but the acts that MINT, JOIN, MOVE and REMOVE rows kept
//  accreting on the conductor. The editor side already had the answer in
//  the repo — `EditorSurfaceController` is Write's gesture-execution band,
//  living beside its model rather than inside it — so this is that shape,
//  one surface over.
//
//  THE SEAM (stated so it can be held later):
//  - This controller owns the board's WRITE-DOOR band: the block placement
//    doors, the native divide (and its planner plumbing), fan reordering,
//    the take↔block pair, and the two selection acts (merge, delete).
//  - `TakesViewModel` remains the CONDUCTOR and the state owner: the
//    projection lifecycle and delivery policy, the pane/liveness authority
//    mapping, columns and lenses, the mint-and-reveal family, view memory,
//    the keyboard family, and the status line. It keeps every pre-move name
//    as a forwarder, so every call site and every pin reads UNCHANGED —
//    zero test edits is the parity proof (the 3C pattern).
//  - The controller reaches the model only through named internal members:
//    `setStatus`, `run`, `speak`, `flushPendingText`, `structuralInFlight`,
//    `commandTargetSlot`, `clearMergeSelection`, and its read surface
//    (`projection`, `board`, `choreography`, `authority`, `session`).
//  - What deliberately did NOT move: the `DivideWCeremonyHost` conformance
//    and the `structuralInFlight` latch. The latch is a fact about the
//    SURFACE (its panes freeze for a flight), not about this band, and the
//    ceremony conformance is a protocol face the board wears as a whole —
//    `DivideWCeremony(host:)` is constructed with the model, both hosts'
//    sheets bind through it, and moving it would change a type rather than
//    a file. `divideFocused` opens that sheet through `model.ceremony`
//    exactly as it did before.
//
//  Behaviour parity is the contract: every body here is the `TakesViewModel`
//  original verbatim, modulo `model.` receiver prefixes.
//
//  Lifetime: the model owns this controller strongly and the back-reference
//  is `unowned` — every entry point is invoked through the model's
//  forwarders, so the model outlives every awaited flight (the
//  `EditorSurfaceController` posture, unchanged). The ONE exception is the
//  fire-and-forget door (`runStructuralDoor`'s divide Task, which returns
//  before its work ends): it captures the MODEL strongly, because that is
//  what its pre-move `self` did. Skipping that was a real crash, not a
//  hypothetical — the suite caught it immediately.
//

import Foundation
import VariorumCore

@MainActor
final class TakesStructureController {
    unowned let model: TakesViewModel

    init(model: TakesViewModel) {
        self.model = model
    }

    // MARK: - Block placement (13b 1b · 13b 4D · 13c 1B)

    /// D3's third leg — the add-block door, NATIVE in Takes/Lenses: an
    /// empty block mints at the post's end and its pane takes the ring the
    /// moment its slot arrives ("just start typing", literally).
    func addBlockAtEnd() async {
        model.setStatus(nil)
        do {
            let result: Operations.NewBlockResult = try await model.session.runner
                .run { [postID = model.postID] ops in
                    try ops.newBlock(in: postID, text: "", at: .end)
                }
            model.choreography.parkFocus(onVariant: result.variant.id)
            model.setStatus("New block added at the end — type away.")
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// 13b 4D (N28's second half — the Takes trap's insert door; S4-13):
    /// an empty block mints right BELOW the focused block (the pane you're
    /// in; on a one-block post, THE block) and its pane takes the ring the
    /// moment its slot arrives — the addBlockAtEnd ring-handover precedent
    /// at `.after(...)`. Position through the ops layer's fractional index
    /// (the architect precision); sealed posts refuse through the op,
    /// spoken.
    func insertBlockBelowFocused() async {
        guard let slot = model.commandTargetSlot else {
            model.speak("Click into a block first — the new block lands right below it.")
            return
        }
        model.setStatus(nil)
        do {
            let result: Operations.NewBlockResult = try await model.session.runner
                .run { [postID = model.postID] ops in
                    try ops.newBlock(in: postID, text: "", at: .after(slot.blockID))
                }
            model.choreography.parkFocus(onVariant: result.variant.id)
            model.setStatus("New block added below — type away.")
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// 13c 1B (A8 — her "I don't seem to have the ability to delete /
    /// archive empty blocks?"): the delete door where takes live, NATIVE
    /// (R118 parity — Write is never the privileged surface). The ring
    /// lands on the neighbour that takes the departed block's place (the
    /// insert-below handover precedent, other direction). Flushes first,
    /// so a pending buffer never lands in a tombstoned variant; sealed
    /// posts refuse through the op, spoken.
    func deleteFocusedBlock() async {
        guard let slot = model.commandTargetSlot else {
            model.speak("Click into a block first — this removes the block you're in.")
            return
        }
        let slots = model.projection.slots
        let survivor: Queries.RenderedBlock? = slots
            .firstIndex { $0.blockID == slot.blockID }
            .flatMap { i in i + 1 < slots.count ? slots[i + 1] : (i > 0 ? slots[i - 1] : nil) }
        await model.autosave.flushNow()
        // 13c Stage 1 ladder, R2-6: the flush can REFUSE and keep its text
        // pending (Phase 7 MAJOR 1), and `runStructural` — the Write door
        // for this same declared act — has always checked that before
        // running an op against a store the surface disagrees with. One
        // declared act, one contract, however many doors (P-1's own
        // reasoning); without this the two native doors differed.
        guard !model.autosave.isDirty else {
            model.speak("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        model.setStatus(nil)
        do {
            try await model.session.runner.run { ops in try ops.deleteBlock(slot.blockID) }
            if let variantID = survivor?.variantID {
                model.choreography.parkFocus(onVariant: variantID)
            }
            // 13j J8(a): ONE receipt for every delete door — shared so the
            // Takes board and Write can never drift on it. 13j round 8b: it
            // also names a preserved original this delete just stranded.
            model.setStatus(BlockSelectionCopy.deletedNote(1)
                + (await StrandedOriginals.note(
                    session: model.session, blockIDs: [slot.blockID]) ?? ""))
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// **ARCHIVE the focused block** (13j, her round-7 ruling) — Takes' and
    /// Lenses' door onto the third verb, the same shape as `deleteFocusedBlock`
    /// above so the two acts cannot drift on their guards, their flush
    /// discipline, or their ring landing.
    func archiveFocusedBlock() async {
        guard let slot = model.commandTargetSlot else {
            model.speak("Click into a block first — this sets the block you're in aside.")
            return
        }
        let slots = model.projection.slots
        let survivor: Queries.RenderedBlock? = slots
            .firstIndex { $0.blockID == slot.blockID }
            .flatMap { i in i + 1 < slots.count ? slots[i + 1] : (i > 0 ? slots[i - 1] : nil) }
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.speak("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        model.setStatus(nil)
        do {
            try await model.session.runner.run { ops in try ops.archiveBlock(slot.blockID) }
            if let variantID = survivor?.variantID {
                model.choreography.parkFocus(onVariant: variantID)
            }
            model.setStatus(BlockSelectionCopy.archivedNote)
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    // MARK: - "Make every newline a block" (18c batch 3 — her U-6)

    /// **The NOTE's repair, on the boards** — Write's `note ▾` row, here
    /// too (R6-2's one grammar, R118's letter: no surface is privileged).
    /// One `withCompound` over every block, so the whole repair is ONE ⌥⌘Z.
    func splitEveryNewlineIntoBlocks() async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        guard await model.flushPendingText() else { return }
        let slots: [Queries.RenderedBlock]
        do {
            slots = try await model.session.database.read { [postID = model.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        guard slots.contains(where: { !NewlineSplitting.breaks(in: $0.text ?? "").isEmpty })
        else {
            model.speak(SplitAtNewlinesCopy.noteAlreadyWhole)
            return
        }
        await runSplit(over: slots.map(\.blockID),
                       whenNothingSplit: SplitAtNewlinesCopy.noteAlreadyWhole)
    }

    /// **One block's repair** — the board's `block ▾` row, on the block you
    /// are standing in (`deleteFocusedBlock`'s own target rule).
    func splitFocusedBlockAtNewlines() async {
        guard let slot = model.commandTargetSlot else {
            model.speak("Click into a block first — this splits the block you're in.")
            return
        }
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        guard await model.flushPendingText() else { return }
        await runSplit(over: [slot.blockID],
                       whenNothingSplit: SplitAtNewlinesCopy.blockAlreadyWhole)
    }

    /// **The picked blocks' repair** — the selection banner's row, beside
    /// merge and delete (13e E2/E3's own selection).
    func splitSelectedBlocksAtNewlines() async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        let picked = model.board.mergeSelection
        guard !picked.isEmpty else {
            model.speak(BlockSelectionCopy.nothingPicked)
            return
        }
        guard await model.flushPendingText() else { return }
        let order: [String]
        do {
            order = try await model.session.database.read { [postID = model.postID] db in
                try Queries.renderPost(db, containerID: postID).map(\.blockID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        // The `deleteSelectedBlocks` chain rule, unchanged: a pick the post
        // no longer holds rides at the FRONT so the operation meets it before
        // any survivor's leg lands, and the compound's atomic rollback covers
        // the true race.
        let chain = picked.subtracting(order).sorted() + order.filter { picked.contains($0) }
        await runSplit(over: chain, whenNothingSplit: SplitAtNewlinesCopy.pickedAlreadyWhole,
                       clearingSelection: true)
    }

    /// The one body all three board doors run — one compound, one receipt,
    /// counted from the operation's own results.
    private func runSplit(
        over blockIDs: [String], whenNothingSplit: String, clearingSelection: Bool = false
    ) async {
        model.structuralInFlight = true
        defer { model.structuralInFlight = false }
        model.setStatus(nil)
        do {
            let stack = model.session.undoStack
            let results: [Operations.SplitAtNewlinesResult] = try await model.session.runner
                .run { ops in
                    try stack.withCompound(label: "Split at Newlines", operations: ops) {
                        try blockIDs.map { try ops.splitBlockAtNewlines($0) }
                    }
                }
            if clearingSelection { model.clearMergeSelection() }
            model.setStatus(SplitAtNewlinesCopy.receipt(
                results, whenNothingSplit: whenNothingSplit))
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// 13b 4C (S4-2d, the lenses half): block drag-reorder on the board —
    /// ONE post, ONE order, so every column moves together BY CONSTRUCTION
    /// (columns render `projection.slots` order; no column holds an order
    /// of its own). An ordinary `reorder` through ops — one op per drop,
    /// ⌥⌘Z undoes; the drag FACE was the missing piece, never the
    /// machinery. `before: nil` ⇒ the post's end.
    func reorderBlock(_ blockID: String, before targetBlockID: String?) async {
        let slots = model.projection.slots
        guard slots.contains(where: { $0.blockID == blockID }) else { return }
        if let targetBlockID {
            guard targetBlockID != blockID,
                  slots.contains(where: { $0.blockID == targetBlockID })
            else { return }
            // Dropping right before its own successor is a no-op.
            if let from = slots.firstIndex(where: { $0.blockID == blockID }),
               let to = slots.firstIndex(where: { $0.blockID == targetBlockID }),
               to == from + 1 { return }
        } else if slots.last?.blockID == blockID {
            return  // already last
        }
        let insert: Operations.InsertPosition = targetBlockID.map { .before($0) } ?? .end
        await model.run { ops in try ops.reorder(blockID, to: insert) }
    }

    // MARK: - The structural doors (13d Batch 3, A9)

    /// THE structural door for both boards: divide acts NATIVELY here;
    /// extract, make-block and merge keep the carry choreography. One
    /// entry point so the three call sites (the Takes handler, the Lenses
    /// handler, the bottom bar's buttons) cannot drift into three answers
    /// — the sediment class this phase's constitution names.
    func runStructuralDoor(_ act: StructuralAct) {
        switch act {
        case .divide, .divideWithCeremony:
            // 13j J4: BOTH divide doors act natively here — the duplicating
            // default and the ceremony sheet alike (the sheet has mounted on
            // this board since 13d Batch 3, so there is nothing to carry).
            let ceremony = act == .divideWithCeremony
            // The Task captures the MODEL strongly — the pre-move shape,
            // and load-bearing rather than stylistic: before A-2 this
            // closure's `self` WAS the model, so the flight outlived the
            // caller's scope. A Task capturing only the controller would
            // let the model die under it (the controller's back-reference
            // is `unowned`), which a fire-and-forget door reached the
            // moment its caller returned — caught by
            // `TakesDivideTests.theDivideDoorNeverParksAWriteIntent`.
            Task { [model] in await model.structure.divideFocused(ceremony: ceremony) }
        case .extract, .makeBlock, .merge, .mergeWithCeremony:
            // 13j J4b: the PAIRING sheet mounts in Write alone, so its door
            // carries the pair there exactly as ⌘⇧M always has.
            model.moveToWriteAndRun(.structural(act))
        }
    }

    /// A9, verbatim: *"i desperately need divide in takes mode"* — divide
    /// WITHOUT leaving Takes. An unfanned block takes a plain divide at the
    /// pane caret; a fanned block opens the take ceremony right here, its
    /// cut seeded from the take the caret is actually in.
    ///
    /// The verdict is `StructuralGesturePlanner`'s — the SAME brain Write's
    /// door consults, handed a single-entry world over the take the caret
    /// sits in. The seal refusal, the gap refusal, the locked-take refusal
    /// and the S4-22 word-rule snap all come back from it, byte-identical
    /// to Write's (pinned as such: `theTakesPlanAndWritesPlanAgree`).
    ///
    /// 13j J4: `ceremony` names the door — ⌘⇧D on a fanned block now runs
    /// the DUPLICATING divide (her Q-M2 shape), and ⌥⌘⇧D opens the sheet
    /// this door has always opened. The plan is the same either way.
    func divideFocused(ceremony: Bool = false) async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        guard let slot = model.commandTargetSlot else {
            model.speak("Click into a block first — divide cuts the block you're in.")
            return
        }
        guard let seed = seedTakeForDivide(slot: slot) else {
            model.speak("This block has no renderable take to divide.")
            return
        }
        model.structuralInFlight = true
        guard let prepared = await prepareDivide(slot: slot, seed: seed) else {
            model.structuralInFlight = false  // it already spoke
            return
        }
        switch prepared.plan {
        case .divide(_, let blockID, let cut):
            guard !ceremony else {
                // The ceremony door on an unfanned block — Write's own
                // answer, word for word (P-2: the ceremony genuinely cannot
                // act, so the door says why and names the one that can).
                model.structuralInFlight = false
                model.speak(FannedDefaultsCopy.divideCeremonyNeedsAFan)
                return
            }
            // The act runs with the panes still FROZEN — that window is
            // exactly what the latch exists for.
            await runDivide(blockID: blockID, cut: cut)
            model.structuralInFlight = false
        case .divideW(_, let blockID, let activeCut):
            guard ceremony else {
                // **THE DEFAULT — KEEP ON TOP (her ruling U-2), superseding
                // 13j J4.** `prepareDivide` has already flushed and read the
                // live ACTIVE fan from the STORE, and `seedTakeID` is
                // verified to be in it, so the composition has everything it
                // needs and there is no second read.
                await runKeepOnTopDivide(
                    blockID: blockID, displayedVariantID: prepared.seedTakeID,
                    fan: prepared.liveActiveFan, activeCut: activeCut)
                model.structuralInFlight = false
                return
            }
            // The ceremony opens IN PLACE — no mode switch (A9's whole
            // point). The latch releases FIRST: the sheet is window-modal
            // and its confirm is its own flight, which re-takes the latch
            // (Write's arrangement exactly — opening the ceremony has
            // never been a flight there either). Holding it across the
            // sheet would drop the live ring for as long as she reads.
            model.structuralInFlight = false
            await model.ceremony.open(
                blockID: blockID, seedVariantID: prepared.seedTakeID, seedCut: activeCut)
        case .refusal(let refusal):
            model.structuralInFlight = false
            model.speak(RefusalCopy.message(for: refusal))
        default:
            // The remaining plans are span gestures the divide command
            // never returns; nothing here can act on them.
            model.structuralInFlight = false
            model.speak(RefusalCopy.message(for: .nothingToDo))
        }
    }

    /// Flush, read the fan from the STORE, and plan. Returns nil having
    /// SPOKEN when it cannot get that far. The live ACTIVE fan rides back
    /// with the plan because the keep-on-top composition needs exactly the
    /// set this function already read — a second read would be a second
    /// truth (and the fan could move between them).
    private func prepareDivide(
        slot: Queries.RenderedBlock, seed: (variantID: String, caret: Int)
    ) async -> (plan: StructuralGesturePlanner.Plan, seedTakeID: String,
                liveActiveFan: [Variant])? {
        // Flush FIRST: the op validates against the store, and the plan
        // snaps against what she SEES — after the flush those are the same
        // text. A refused flush keeps its text pending (Phase 7 MAJOR 1)
        // and stops the act, the one-act-one-contract rule 13c R2-6
        // established for this surface's other native door.
        guard await model.flushPendingText() else { return nil }
        // THE FORK IS READ FROM THE STORE, not from `projection.fans`
        // (13d Batch 3, ruled — batch 2's precedent): the takes projection
        // is deliberately frozen while any buffer is dirty, so a plan-time
        // arity is an enablement hint and never an authorization. Batch 2's
        // revert D is the receipt for what a projection-read fan guard
        // costs — it ate a take that had just arrived.
        let fan: [Variant]
        do {
            fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: slot.blockID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return nil
        }
        let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
        // The seed must still BE in the live fan (13d cold review, F-3):
        // when the caret's take has vanished (archived/deleted by sync or a
        // sibling surface mid-race), refuse-and-speak exactly as Write's
        // door does — a fallback to some other live take silently divided a
        // take she was never in, at a caret offset from the one that died.
        guard let seedTake = liveActive.first(where: { $0.id == seed.variantID })
        else {
            model.speak("This block's takes changed — try the divide again.")
            return nil
        }
        let plan = StructuralGesturePlanner.plan(
            .divideAtCursor,
            selection: NSRange(location: seed.caret, length: 0),
            world: divideWorld(slot: slot, take: seedTake, arity: liveActive.count))
        return (plan, seedTake.id, liveActive)
    }

    /// The take the caret is in, and where the caret is within it. The
    /// carried-caret rule is the choreographer's own, reused: a reported
    /// selection counts only when it belongs to the focused pane's take
    /// (a stale selection from a pane she has left names nothing). With no
    /// caret the offset is 0, and divide there refuses "nothing to divide"
    /// — which is exactly what the carry door does today, so this is
    /// parity rather than invention.
    private func seedTakeForDivide(
        slot: Queries.RenderedBlock
    ) -> (variantID: String, caret: Int)? {
        guard let variantID = model.focusedPane?.variantID ?? slot.variantID else { return nil }
        guard let selection = model.paneSelection, selection.variantID == variantID else {
            return (variantID, 0)
        }
        return (variantID, selection.range.location)
    }

    /// A single-entry world over the take the caret is in — the planner is
    /// pure over a tiling, and one take IS a one-entry tiling. `tailLength:
    /// nil` because a board has no open tail; `editable` is the take's own
    /// lock (a locked take refuses a plain divide and permits the ceremony,
    /// which copies — the Phase 3 op semantics the planner already encodes).
    /// Internal, not private, so the PARITY PIN can drive it through the
    /// model's forwarder: constraint 1's one-brain claim is enforced by
    /// test, never by comment (`theTakesWorldAndWritesWorldPlanAlike`).
    func divideWorld(
        slot: Queries.RenderedBlock, take: Variant, arity: Int
    ) -> StructuralGesturePlanner.World {
        let text = model.authority.text(variantID: take.id, storeText: take.workingText)
        return StructuralGesturePlanner.World(
            index: BlockRangeIndex(
                entries: [BlockRangeIndex.Entry(
                    blockID: slot.blockID,
                    variantID: take.id,
                    length: text.utf16.count,
                    editable: !take.locked)],
                tailLength: nil),
            fanArities: [arity],
            sealed: model.projection.sealed,
            textAt: { _ in text })
    }

    /// The plain divide's act. The board shows the successors through its
    /// ORDINARY projection path — the observation fires and `adopt` runs
    /// (it lands rather than defers precisely because the flush left the
    /// buffer clean), so there is no bespoke re-render here. The ring goes
    /// to the SUCCESSOR, mirroring Write's caret rule for this gesture.
    private func runDivide(blockID: String, cut: Int) async {
        model.setStatus(nil)
        do {
            let result: Operations.DivideResult = try await model.session.runner.run { ops in
                try ops.divide(blockID, cut: cut)
            }
            model.choreography.parkFocus(onVariant: result.variant.id)
            model.setStatus("Block divided — ⌥⌘Z undoes it.")
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// **U-2's road on this board** — the keep-on-top divide (2026-09-06,
    /// superseding 13j J4's duplicate shape here too). The seed take's
    /// halves lead B and C; every other active take rides WHOLE onto B; A is
    /// released preserved. Same composition, same receipt words and same
    /// ring rule as Write's road (the second successor leads), because two
    /// doors on one act share the brain and the copy or they drift.
    ///
    /// The seed take here is the take the CARET is in, which on this board
    /// is often not the block's chosen one — so the composition's
    /// `displayedID` rides into `divideW` as the anchor for both successors'
    /// chosen/default (QUESTIONS #91). Without it B would render the chosen
    /// take whole beside C's tail of the one she actually divided.
    private func runKeepOnTopDivide(
        blockID: String, displayedVariantID: String, fan: [Variant], activeCut: Int?
    ) async {
        guard let cut = activeCut else {
            // A one-word seed take has no interior cut — Write's answer,
            // verbatim (the ceremony's parking is the road for that).
            model.speak(RefusalCopy.message(for: .nothingToDo)
                + " Divide choosing takes (⌥⌘⇧D) can send a whole take to one side.")
            return
        }
        guard let composition = KeepOnTopDivide.compose(
            displayedID: displayedVariantID, cut: cut, fan: fan)
        else {
            // `prepareDivide` already verified the seed against this same
            // live fan, so this is belt-and-braces — and it speaks Write's
            // F-3 sentence rather than inventing a second one.
            model.speak(FannedDefaultsCopy.takesChangedDivide)
            return
        }
        model.setStatus(nil)
        do {
            let stack = model.session.undoStack
            let result: Operations.DivideWResult
                = try await model.session.runner.run { ops in
                // One leg, one entry — and the entry keeps reading "Divide"
                // (divideW's own label names the ceremony). Write's road
                // does exactly the same.
                try stack.withCompound(label: "Divide", operations: ops) {
                    try ops.divideW(
                        blockID, cuts: composition.cuts,
                        displayedVariantID: composition.displayedID)
                }
            }
            // The ring goes to the SECOND successor's leading take — Write's
            // caret rule for this shape, in this board's vocabulary.
            model.choreography.parkFocus(onVariant: result.second.variants[0].id)
            model.setStatus(FannedDefaultsCopy.divided(
                kept: max(0, result.first.variants.count - 1),
                stayedBehind: composition.unparkable.count))
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    // MARK: - Fan ORDER (13e E4 — her A19: "Reorder takes")

    /// Move a take one place earlier (`delta < 0`) or later in its block's
    /// fan. The card's own ◀ ▶ / ▲ ▼ door calls this.
    ///
    /// **Flush first, then read the fan FROM THE STORE** — 13d batch 3's
    /// precedent on this surface, for its exact reason: the takes projection
    /// is deliberately frozen while any buffer is dirty, so a projection-read
    /// neighbour is an enablement hint and never an authorization (a take
    /// that arrived mid-burst would otherwise make the move land beside the
    /// wrong card). A refused flush keeps its text pending and stops the act
    /// (13c R2-6's one-act-one-contract rule).
    ///
    /// Stepping happens within the ACTIVE fan — the set the cards show. An
    /// archived take keeps its own place in the ordering; it is neither
    /// stepped onto nor stepped over.
    func moveTake(_ variantID: String, in blockID: String, by delta: Int) async {
        guard delta != 0 else { return }
        guard await model.flushPendingText() else { return }
        let fan: [Variant]
        do {
            fan = try await model.session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        let active = fan.filter { $0.status == .active }
        guard let index = active.firstIndex(where: { $0.id == variantID }) else {
            model.speak("This block's takes changed — try the move again.")
            return
        }
        let target = index + delta
        guard active.indices.contains(target) else {
            model.speak(delta < 0
                        ? "This take is already first in the fan."
                        : "This take is already last in the fan.")
            return
        }
        let anchor = active[target].id
        model.setStatus(nil)
        do {
            try await model.session.runner.run { ops in
                try ops.reorderTake(
                    variantID, to: delta < 0 ? .before(anchor) : .after(anchor))
            }
            model.speak(
                "Take moved \(delta < 0 ? "earlier" : "later") — \u{2325}\u{2318}Z undoes it.")
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    // MARK: - Take ↔ block structure (13e batch 3 — her A20/A21, AR-1)

    /// **Her A20 on the boards**: the take you're in leaves the fan and
    /// becomes the block below. Native here (R118 — the take card is exactly
    /// where you are looking at a take), the ring hands over to the minted
    /// block's pane the moment its slot arrives (the insert-below handover
    /// precedent).
    ///
    /// The target is named explicitly by the card's own door (a right-click
    /// never moves the keyboard — 13k K6); the routed door falls back to the
    /// pane you're in, then the shown take of the one block on a one-block
    /// note (`commandTargetSlot`'s rule).
    ///
    /// Flushes first and lets the OP validate — the fan arity, the blank
    /// take, the seal and I10 are all decided inside the write, never from
    /// the frozen projection (13d batch 3's rule for this surface).
    func moveTakeIntoBlockBelow(blockID: String? = nil, variantID: String? = nil) async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        guard let target = takeTarget(blockID: blockID, variantID: variantID) else {
            model.speak("Click into a take first — this moves that take into its own block.")
            return
        }
        guard await model.flushPendingText() else { return }
        model.structuralInFlight = true
        defer { model.structuralInFlight = false }
        model.setStatus(nil)
        do {
            let result: Operations.TakeToBlockResult = try await model.session.runner.run { ops in
                try ops.takeToBlockBelow(target.blockID, variantID: target.variantID)
            }
            model.choreography.parkFocus(onVariant: result.variant.id)
            model.speak(TakeStructureCopy.movedNote)
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// **Her A21's second half on the boards (the A45 repair)**: every other
    /// take of the target block becomes its own block below it, in fan order,
    /// under ONE undo entry. The block keeps showing what it showed.
    func turnTakesIntoBlocks(blockID: String? = nil) async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        guard let targetID = blockID ?? model.commandTargetSlot?.blockID else {
            model.speak("Click into a block first — this turns its takes into blocks.")
            return
        }
        guard await model.flushPendingText() else { return }
        model.structuralInFlight = true
        defer { model.structuralInFlight = false }
        model.setStatus(nil)
        do {
            let result: Operations.TakesToBlocksResult = try await model.session.runner.run { ops in
                try ops.takesToBlocks(targetID)
            }
            model.speak(TakeStructureCopy.convertedNote(
                blocks: result.converted.count, skippedBlanks: result.skippedBlankTakes))
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }

    /// The take a take-scoped routed act addresses: the pane you're in;
    /// failing that, the shown take of the block the command targets (the
    /// one-block-note case `commandTargetSlot` already covers). An explicit
    /// pair from a card's own door always wins.
    private func takeTarget(
        blockID: String?, variantID: String?
    ) -> (blockID: String, variantID: String)? {
        if let blockID, let variantID { return (blockID, variantID) }
        if let pane = model.focusedPane { return (pane.blockID, pane.variantID) }
        guard let slot = model.commandTargetSlot, let shown = slot.variantID else { return nil }
        return (slot.blockID, shown)
    }

    // MARK: - The selection's two acts (13e E3 · E2 — her A18 / A17)

    /// **Her A18, built: "⌘-click in Takes to select blocks to merge; merge
    /// several when they have no takes."**
    ///
    /// Merge semantics are untouched canon (AppSpec §9): neighbours only,
    /// nothing cartesian, the sources released to lineage. What this door adds
    /// is WHICH blocks — pointed at directly instead of derived from a text
    /// selection Write's planner reads.
    ///
    /// **13j J4b RETIRED THE FORK** (her 2026-08-09 ruling — this door's own
    /// pre-13j comment named row 4b as the owner of the flip, and this is
    /// it). There is no longer a road that leaves this surface: every pick,
    /// fanned or not, merges RIGHT HERE as a left-to-right chain under ONE
    /// undo entry — byte-for-byte Write's own `mergeChain` behaviour, with
    /// Write's own carry-all links (a link whose either side carries a fan
    /// composes through `mergeCeremony`; an unfanned link keeps `merge`
    /// byte-unchanged). Nothing is folded away and nothing is lectured
    /// about, so no surface is behind another (R118). The PAIRING ceremony
    /// keeps its own door (⌥⌘⇧M, `.mergeWithCeremony`), which still carries
    /// to Write because that is where its sheet mounts.
    ///
    /// Adjacency, order and the fans are read FROM THE STORE, never from the
    /// frozen projection: a wrong pair would merge blocks she never picked.
    ///
    /// **18f batch 1 (her U-16):** the banner's second door names the ROAD —
    /// bring every take (the carry-all chain, the default this door has run
    /// since J4b) or only the shown ones (the plain chain). One chain body
    /// serves both (`MergeChainRun`), shared with Write and the workbench.
    func mergeSelectedBlocks(bringEveryTake: Bool = true) async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        let picked = model.board.mergeSelection
        guard picked.count >= 2 else {
            model.speak("\u{2318}-click a second block first — merge joins the blocks you pick.")
            return
        }
        guard await model.flushPendingText() else { return }
        let slots: [Queries.RenderedBlock]
        do {
            slots = try await model.session.database.read { [postID = model.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        let order = slots.map(\.blockID)
        // LADDER ROUND A (A-3): EXISTENCE BEFORE CONTIGUITY. A pick the post
        // no longer holds fails the contiguity test too — `isContiguousRun`
        // requires every picked id to appear in the order — so asking
        // adjacency first reported a gap where the truth is that a block is
        // gone, and sent her looking for a neighbour that is already there.
        // Same race the delete door meets, so it wears the same words one
        // verb apart.
        guard picked.isSubset(of: Set(order)) else {
            model.speak(BlockSelectionCopy.blockGoneForMerge)
            return
        }
        guard TakesBoardLayout.isContiguousRun(picked, in: order) else {
            model.speak("Merge joins neighbouring blocks — these aren't next to each other. "
                + "Pick blocks that sit side by side.")
            return
        }
        let chain = order.filter { picked.contains($0) }
        // **13j J4b — the carry-all default reaches THIS door too** (the row
        // her ruling names: "every merge door"). The pre-13j branch carried a
        // fanned PAIR to Write to open the ceremony, and its own comment
        // named this batch as the owner of the flip. There is nothing left to
        // carry: the carry-all composes from `mergeCeremony` and needs no
        // sheet, so a fanned pair merges RIGHT HERE like every other pick —
        // one chain body, every link carrying all.
        //
        // Fans are read FROM THE STORE for the composition — the projection
        // stays what it has always been on this surface: the selection aid
        // that decides nothing (batch 2's rule, unchanged).
        let fans: [String: [Variant]]
        do {
            fans = try await model.session.database.read { db in
                var result: [String: [Variant]] = [:]
                for id in chain {
                    result[id] = try Queries.blockFan(db, blockID: id)
                        .filter { $0.deletedAt == nil && $0.status == .active }
                }
                return result
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        // The take she is LOOKING at, per block: the board's own rendered
        // pick, which is the slot's chosen take.
        let displayed = Dictionary(
            uniqueKeysWithValues: chain.map { id in
                (id, slots.first { $0.blockID == id }?.variantID)
            })
        // A5 (ladder A round 1): Write's pre-compound validation, on this
        // door too — one chain body, one refusal rule. (This board reads
        // its slots fresh, so the residual reachability here is the
        // archived-default sync-race class rather than the frozen
        // projection; the guard is the same either way.)
        // The A5 validation is the CARRY-ALL road's; the plain road depends
        // on no displayed-take resolution and cannot suffer that race.
        if bringEveryTake,
           !CarryAllMerge.chainComposes(order: chain, fans: fans, displayed: displayed) {
            model.speak(FannedDefaultsCopy.takesChangedMerge)
            return
        }
        model.structuralInFlight = true
        defer { model.structuralInFlight = false }
        model.setStatus(nil)
        do {
            let stack = model.session.undoStack
            let landing: MergeChainRun.Landing
                = try await model.session.runner.run { ops in
                try stack.withCompound(label: "Merge Blocks", operations: ops) {
                    try MergeChainRun.run(
                        ops, order: chain, fans: fans, displayed: displayed,
                        bringEveryTake: bringEveryTake)
                }
            }
            model.clearMergeSelection()
            model.choreography.parkFocus(onVariant: landing.variantID)
            model.speak(FannedDefaultsCopy.mergedChain(
                blocks: chain.count, carried: max(0, landing.takesOnMerged - 1)))
        } catch {
            // Ladder round 2 (R2-2): the read-to-write race — a pick that
            // died or moved between the existence read above and
            // `ops.merge` — speaks THIS door's verb. Without this arm,
            // `blockNotFound` mapped to the DELETE door's words ("Nothing
            // was deleted") and `blockNotPlaced` fell to the raw-enum arm.
            let op = error as? OperationError
            if case .blockNotFound = op {
                model.setRefusal(BlockSelectionCopy.blockGoneForMerge)
            } else if case .blockNotPlaced = op {
                model.setRefusal(BlockSelectionCopy.blockGoneForMerge)
            } else {
                model.setRefusal(TakesViewModel.message(for: error))
            }
        }
    }

    /// **Her A17, built (13e E2): "delete several blocks at the same time
    /// from a post."** The board's half — the same ⌘-click selection E3
    /// merges, pointed at the delete door instead (a selection was never
    /// merge's private property; it names what the pointer is pointing at).
    ///
    /// The act is the STANDING unrestricted `deleteBlock` per block
    /// (QUESTIONS #33(a): the block goes, whatever it holds), run under ONE
    /// `withCompound` entry — so a multi-delete is ONE mistake to reverse,
    /// which is exactly what makes deleting a dozen blocks a safe gesture at
    /// all. Every leg registers a redo, so the compound is redoable too.
    ///
    /// **No partial acts, and the compound is what guarantees it, not a
    /// pre-check.** A seal refuses at the first leg through the operation
    /// itself (P-2 — the door delivers the ops layer's real refusal, never
    /// its own guess at one), and a leg that throws AFTER others landed
    /// unwinds them immediately (`UndoStack.withCompound`'s atomicity). A
    /// picked block another surface DELETED between the pick and the act
    /// refuses the WHOLE gesture — nothing deleted, `blockGone` spoken. A
    /// picked block that merely MOVED to another unsealed note is live and
    /// is deleted where it now lives, counted by the success receipt
    /// (#60(c) — the pick names the block, not its address; ladder round 2,
    /// R2-1, correcting this comment's earlier deleted-or-moved claim).
    ///
    /// Order is the POST's, read from the STORE: the projection is a
    /// selection aid, never an authorization (batch 2's rule, unchanged).
    func deleteSelectedBlocks() async {
        guard !model.structuralInFlight else {
            model.speak("Another structural change is still landing.")
            return
        }
        let picked = model.board.mergeSelection
        guard !picked.isEmpty else {
            model.speak(BlockSelectionCopy.nothingPicked)
            return
        }
        guard await model.flushPendingText() else { return }
        let order: [String]
        do {
            order = try await model.session.database.read { [postID = model.postID] db in
                try Queries.renderPost(db, containerID: postID).map(\.blockID)
            }
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
            return
        }
        // LADDER ROUND A (A-1): the picks are NOT pre-filtered against the
        // order. Filtering them WAS the half-act: a pick the post had lost
        // silently dropped out of the chain and the survivors were deleted
        // anyway — one declared act with two behaviours, since Write's host
        // hands every pick to the compound and lets the operation refuse
        // (`blockNotFound` → the whole gesture unwinds → `blockGone`). The
        // order still comes from the STORE for the blocks it holds; a pick it
        // does not hold rides at the FRONT (ladder round 2, R2-3), where
        // `deleteBlock` meets it BEFORE any survivor's leg lands — a
        // detectable stale pick refuses with zero transient tombstones and
        // the redo future intact (R1-10 burns the future per REGISTERED leg,
        // so legs that never run can't burn it). The compound's atomic
        // rollback remains the guarantee for the true race that opens
        // BETWEEN this read and the write, which no ordering can detect.
        let chain = picked.subtracting(order).sorted()
            + order.filter { picked.contains($0) }
        model.structuralInFlight = true
        defer { model.structuralInFlight = false }
        model.setStatus(nil)
        do {
            let stack = model.session.undoStack
            try await model.session.runner.run { ops in
                try stack.withCompound(label: "Delete Blocks", operations: ops) {
                    for blockID in chain { try ops.deleteBlock(blockID) }
                }
            }
            model.clearMergeSelection()
            // 13j batch 7: the stranding sentence rides the board's compound
            // too — the same gap, the same fix, on the twin door (Write's
            // `runBlockDeleteCompound` carries the trace).
            model.speak(BlockSelectionCopy.deletedNote(chain.count)
                + (await StrandedOriginals.note(
                    session: model.session, blockIDs: chain) ?? ""))
        } catch {
            model.setRefusal(TakesViewModel.message(for: error))
        }
    }
}
