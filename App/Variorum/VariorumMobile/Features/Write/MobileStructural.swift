//
//  MobileStructural.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M10; divide re-ruled at the gate — Q-M2) —
//  the phone's divide/merge doors. A sibling type beside the takes
//  controllers (the S1 NIT-3 law); the VM routes thinly.
//
//  DIVIDE — **KEEP ON TOP** (her ruling U-2, 2026-09-06, and her
//  follow-up the next night: *"the phone divide should update to match
//  this default divide behavior"*; SUPERSEDES the Q-M2 duplicate shape
//  this door shipped with, which had itself superseded M10's
//  auto-proceed/refuse pair): single-take divide is the everyday
//  in-place op; a FANNED block divides through the SHARED composition
//  `KeepOnTopDivide` (core Domain — `Sources/VariorumCore/Domain/`; the
//  Mac's three doors' and the newline repair's brain too)
//  and `Operations.divideW`'s parking rule — the DISPLAYED (peek-aware)
//  take is cut into B and C, and every OTHER active take rides WHOLE
//  onto B, the top block. Still no `CutPropagation`, no unique-match
//  gate, no refusal naming any platform. An EMPTY other take cannot
//  park and stays on the released original in lineage. The cut snaps
//  through the ONE snap brain (`StructuralGesturePlanner.snapToInteriorBoundary`
//  — the ruled word rule with the gentle settle, S4-22's letter).
//
//  MERGE (re-ruled at parity C5 — the CARRY-ALL, her workaround
//  doctrine; SUPERSEDES M10's refuse-to-the-ceremony): instant
//  (`Operations.merge`) when NEITHER side carries a fan — byte-
//  unchanged. A fan on either side routes through the canon ceremony op
//  (`Operations.mergeCeremony`, S4-23) with ONE peek-aware pairing —
//  the two DISPLAYED takes joined under the canon rule — and every
//  OTHER active take CARRIED WHOLE onto the merged block: Q-M2's
//  duplicate logic, merge's edition ("quick to delete" beats the hunt).
//  M10's silently-dropping-her-options concern dissolves by
//  construction — NOTHING is dropped; every take survives on the merged
//  block, visible under the ⑂ badge. Archived takes stay with the
//  released sources in lineage (the divide's parallel — the keep-on-top
//  composition marks only the live ACTIVE fan; the core refuses
//  archived carries by design). The fan check reads the
//  STORE, never the projection (the 13d ruled discipline: a plan-time
//  arity is an enablement hint, never an authorization).
//
//  WHOLE-BLOCK DELETE (round 2, batch 1b — R18 ≡ M11; the Mac's 13j J9
//  parity, inherited not invented): a text selection covering N WHOLE
//  paragraphs plus delete routes here instead of refusing at the gate.
//  The decision is the SHARED brain's (`BlockRangeIndex.wholeBlockDeletion`
//  + `caretLandingAfterRemoving`, hoisted out of Mac app code by this
//  batch); the door is the phone's face on it.
//
//  Every door FLUSHES FIRST (the Takes board's `prepareDivide` contract:
//  the op validates against the store and the cut was placed against
//  what she sees — after the flush those are the same text) and settle
//  through the VM's one fresh-read door. Structural UNDO stays Mac-side
//  in v1 (recorded deliberate absence): divide and merge are reversible
//  pointer moves the Mac's ⌥⌘Z and lineage doors recover.
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileStructuralController {
    private let session: AppSession
    weak var model: MobileEditorViewModel?

    /// One structural flight at a time (the Mac's latch, the same copy).
    private(set) var structuralInFlight = false

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - Divide (M10)

    /// The menu door: divides the caret's block at the caret.
    func divideAtCaret() async {
        let caret = model?.textView?.selectedRange.location
            ?? model?.index.documentLength ?? 0
        await divide(atSurfaceCaret: caret)
    }

    func divide(atSurfaceCaret caret: Int) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        // The seal outranks every other answer (the planner's rule).
        if model.isSealed {
            model.report("This note is locked — unlock it to restructure.")
            return
        }
        guard let (i, intra) = entryTouching(caret: caret) else {
            model.report(tailOrEmptyRefusal(
                empty: "No blocks yet — type on the page and each finished paragraph becomes one.",
                tail: "This text isn't a block yet — it becomes one moments after you pause typing."))
            return
        }
        let entry = model.index.entries[i]
        guard entry.variantID != nil else {
            model.report("This block hasn't fully synced yet — try again once it arrives.")
            return
        }

        // Flush FIRST: the op validates against the store, and the cut
        // snaps against what she SEES — after the flush those agree.
        guard await flushPendingText() else { return }
        // The flush SUSPENDS, and main-actor work landing in that window
        // can re-index the entries (S4 ladder MINOR 2 — the R2-10 class,
        // hardened here because the guard is one line): re-resolve
        // against the caret and refuse on drift, rather than trusting
        // the pre-flush index into a re-tiled surface.
        guard let (j, freshIntra) = entryTouching(caret: caret),
              model.index.entries[j].blockID == entry.blockID
        else {
            model.report("This block's takes changed — try the divide again.")
            return
        }
        let fresh = model.index.entries[j]

        let text = model.viewText(model.index.range(ofEntryAt: j))
        guard let cut = StructuralGesturePlanner.snapToInteriorBoundary(freshIntra, in: text)
        else {
            model.report("No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks.")
            return
        }

        // THE FORK IS READ FROM THE STORE (the 13d ruled discipline).
        let blockID = fresh.blockID
        let fan: [Variant]
        do {
            fan = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
        } catch {
            model.report(String(describing: error))
            return
        }
        let active = fan.filter { $0.deletedAt == nil && $0.status == .active }

        if active.count <= 1 {
            guard fresh.editable else {
                model.report(MobileEditorViewModel.lockedTakeRefusal)
                return
            }
            await runDivide(blockID: blockID) { ops in
                try ops.divide(blockID, cut: cut).block.id
            }
            return
        }

        // The fanned path — **KEEP ON TOP** (her ruling U-2, 2026-09-06;
        // her follow-up made it the phone's too: *"the phone divide should
        // update to match this default divide behavior"*). The DISPLAYED
        // (peek-aware) take is cut; every other active take rides WHOLE
        // onto the TOP block, through the shared composition and
        // `Operations.divideW`'s parking rule. The displayed take must
        // still BE in the live fan (the Takes board's F-3 guard — a
        // fallback would divide a take she was never in), which is what
        // `compose` returning nil means.
        guard let composition = KeepOnTopDivide.compose(
            displayedID: fresh.variantID, cut: cut, fan: active)
        else {
            model.report("This block's takes changed — try the divide again.")
            return
        }
        // ONE undo entry, still labelled "Divide": divideW's own label
        // names the summoned door ("Divide choosing takes"), and the phone's
        // undo door reads the label out loud.
        let stack = session.undoStack
        await runDivide(blockID: blockID) { ops in
            try stack.withCompound(label: "Divide", operations: ops) {
                try ops.divideW(
                    blockID, cuts: composition.cuts,
                    displayedVariantID: composition.displayedID).first.block.id
            }
        }
    }

    /// Runs a divide body, settles through the one fresh-read door, and
    /// lands the caret at the leading successor's start (the Mac's own
    /// caret rule for both divide shapes).
    private func runDivide(
        blockID: String, _ body: @escaping @Sendable (Operations) throws -> String
    ) async {
        guard let model else { return }
        do {
            let landingBlockID = try await session.runner.run(body)
            // **NO SENTENCE, an ACTION** (round 2 batch 4 — M20). Divide
            // has always said nothing: the text rearranged on screen, which
            // is the whole report. What it lacked was the way back, so the
            // receipt slot carries the bare Undo and no new chatter — the
            // calmest shape, and it leaves every shipped "says nothing"
            // pin true.
            model.report(nil, action: .undo)
            await model.refreshTakesFromStore()
            if let range = model.rangeOfBlock(landingBlockID) {
                model.textView?.selectedRange = NSRange(location: range.location, length: 0)
            }
        } catch {
            model.report(Self.refusalMessage(error, act: "divide the block"))
        }
    }

    // MARK: - Merge with previous (M10)

    func mergeWithPrevious() async {
        let caret = model?.textView?.selectedRange.location
            ?? model?.index.documentLength ?? 0
        await mergeWithPrevious(atSurfaceCaret: caret)
    }

    func mergeWithPrevious(atSurfaceCaret caret: Int) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        if model.isSealed {
            model.report("This note is locked — unlock it to restructure.")
            return
        }
        guard let (i, _) = entryTouching(caret: caret) else {
            model.report(tailOrEmptyRefusal(
                empty: "No blocks yet — type on the page and each finished paragraph becomes one.",
                tail: "Put the caret in a block — merge joins it with the block above."))
            return
        }
        guard i > 0 else {
            model.report("This is the note's first block — there's nothing above to merge with.")
            return
        }
        let leading = model.index.entries[i - 1]
        let trailing = model.index.entries[i]
        for entry in [leading, trailing] where entry.variantID == nil {
            model.report("This block hasn't fully synced yet — try again once it arrives.")
            return
        }

        guard await flushPendingText() else { return }
        // The post-flush re-verify (S4 ladder MINOR 2 — divide's twin):
        // both neighbors must still be the pair the caret named before
        // the flush's suspension, or the act is refused.
        guard let (j, _) = entryTouching(caret: caret), j > 0,
              model.index.entries[j].blockID == trailing.blockID,
              model.index.entries[j - 1].blockID == leading.blockID
        else {
            model.report("This block's takes changed — try the merge again.")
            return
        }

        // THE FORK IS READ FROM THE STORE (the 13d ruled discipline —
        // never the projection). Parity C5's RULING: a fan on either
        // side routes through the canon ceremony op with ONE peek-aware
        // pairing (the two DISPLAYED takes, the canon join) and every
        // OTHER active take carried WHOLE — the carry-all (the header's
        // doctrine). The displayed take ids and the caret arithmetic are
        // captured HERE, post-re-verify, before the read's suspension.
        let leadingID = leading.blockID
        let trailingID = trailing.blockID
        let displayedLeadingID = model.index.entries[j - 1].variantID
        let displayedTrailingID = model.index.entries[j].variantID
        let leadingLength = model.index.entries[j - 1].length
        let fans: (leading: [Variant], trailing: [Variant])
        do {
            fans = try await session.database.read { db in
                func active(_ blockID: String) throws -> [Variant] {
                    try Queries.blockFan(db, blockID: blockID)
                        .filter { $0.deletedAt == nil && $0.status == .active }
                }
                return (try active(leadingID), try active(trailingID))
            }
        } catch {
            model.report(String(describing: error))
            return
        }

        let body: @Sendable (Operations) throws -> String
        if fans.leading.count > 1 || fans.trailing.count > 1 {
            // The displayed (peek-aware) takes must still BE in their
            // live fans (the divide door's F-3 guard class — the store
            // may have moved in the flush/read window; a fallback would
            // pair a take she was never looking at).
            guard let head = fans.leading.first(where: { $0.id == displayedLeadingID }),
                  let tail = fans.trailing.first(where: { $0.id == displayedTrailingID })
            else {
                model.report("This block's takes changed — try the merge again.")
                return
            }
            // The DOOR join resolved on the post-flush store texts — the
            // plain merge's exact rule, through the ONE join brain. Since
            // her ruling R-13u4-3 (2026-09-20) that rule is the rendering
            // join, and the phone flips WITH the Mac because the rule is
            // core-side (the U-2 keep-on-top precedent): "Merge with
            // Previous" is a door.
            let pairing = Operations.MergePairing(
                firstVariantID: head.id, secondVariantID: tail.id,
                join: MergeJoinRule.door.join(
                    head: head.workingText, tail: tail.workingText))
            let carries = (fans.leading + fans.trailing)
                .map(\.id).filter { $0 != head.id && $0 != tail.id }
            body = { ops in
                try ops.mergeCeremony(
                    leadingID, trailingID,
                    pairings: [pairing], carries: carries
                ).block.id
            }
        } else {
            body = { ops in try ops.merge(leadingID, trailingID).block.id }
        }
        do {
            let mergedBlockID = try await session.runner.run(body)
            model.report(nil, action: .undo)  // the bare Undo — see divide
            await model.refreshTakesFromStore()
            // Caret at the join: right where the trailing half begins
            // (the Mac's instant-merge caret rule; the carry-all's chosen
            // is the JOINED take — the core's rendered×rendered rule —
            // so the same arithmetic serves both roads).
            if let range = model.rangeOfBlock(mergedBlockID) {
                let join = min(leadingLength, range.length)
                model.textView?.selectedRange = NSRange(
                    location: range.location + join, length: 0)
            }
        } catch {
            model.report(Self.refusalMessage(error, act: "merge the blocks"))
        }
    }

    // MARK: - Extract + Make Block on the selection menu (parity C4b
    // item 4 — her mid-chain ruling 5: "cross via the selection menu")

    /// Extract Selection — AppSpec §9's boundary-adjacent split (source
    /// survives), planned by the ONE shared planner both platforms run.
    func extractSelection(range: NSRange) async {
        await runSpanGesture(.extractSelection, range: range)
    }

    /// Make Block from Selection — the composed middle-span gesture
    /// (two divides as ONE compound, the Mac's exact execution).
    func makeBlockFromSelection(range: NSRange) async {
        await runSpanGesture(.makeBlockFromSelection, range: range)
    }

    /// The two span acts' one body. Order matters and mirrors the
    /// sibling doors' contract: latch → flush FIRST → plan against the
    /// POST-flush surface (planning after the flush is what the divide
    /// door's re-verify buys by other means — the plan can never hold a
    /// pre-flush reading of a re-tiled surface) → execute through the
    /// standing core ops → settle through the one fresh-read door.
    private func runSpanGesture(
        _ command: StructuralGesturePlanner.Command, range: NSRange
    ) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        guard await flushPendingText() else { return }
        let world = StructuralGesturePlanner.World(
            index: model.index,
            fanArities: model.slots.map(\.activeVariantCount),
            sealed: model.isSealed,
            textAt: { [weak model] i in
                guard let model, i >= 0, i < model.index.entries.count else { return "" }
                return model.viewText(model.index.range(ofEntryAt: i))
            })
        let plan = StructuralGesturePlanner.plan(command, selection: range, world: world)

        switch plan {
        case .refusal(let refusal):
            model.report(Self.spanRefusalMessage(refusal))

        case .extract(_, let blockID, let span, _, let otherTakes):
            do {
                let result = try await session.runner.run { ops in
                    try ops.extract(blockID, span: span)
                }
                // The fanned-extract hint (AppSpec §9 review #10's
                // documented behavior — "the editor may hint"; the Mac's
                // contract item 8 sentence, spoken through the phone's
                // status line, its transient face. PROVISIONAL).
                model.report(
                    otherTakes > 0 ? Self.fannedExtractHint(otherTakes) : nil,
                    action: .undo)
                await model.refreshTakesFromStore()
                if let landing = model.rangeOfBlock(result.block.id) {
                    model.textView?.selectedRange = NSRange(
                        location: landing.location, length: 0)
                }
            } catch {
                model.report(Self.refusalMessage(error, act: "extract the selection"))
            }

        case .makeBlock(let i, let blockID, let span):
            // The Mac's exact execution: two divides as ONE undoable
            // compound (atomic on partial failure), the span's end
            // mapped through the first divide's ACTUAL output — the
            // seam trim may drop leading whitespace, so the second cut
            // is derived, never re-guessed.
            let entryLength = model.index.range(ofEntryAt: i).length
            let stack = session.undoStack
            do {
                let middleID = try await session.runner.run { ops in
                    try stack.withCompound(label: "Make Block", operations: ops) {
                        let first = try ops.divide(blockID, cut: span.lowerBound)
                        let dropped = (entryLength - span.lowerBound)
                            - first.variant.workingText.utf16.count
                        _ = try ops.divide(first.block.id, cut: span.count - dropped)
                        return first.block.id
                    }
                }
                model.report(nil, action: .undo)  // the bare Undo — see divide
                await model.refreshTakesFromStore()
                if let landing = model.rangeOfBlock(middleID) {
                    model.textView?.selectedRange = NSRange(
                        location: landing.location, length: 0)
                }
            } catch {
                model.report(Self.refusalMessage(error, act: "make the block"))
            }

        case .makeBlockAcrossBlocks:
            // The Mac's guided cross-block flow runs through the W
            // machinery (ceremony arms the phone deliberately lacks —
            // the ruled exclusion); the road is named instead, in
            // phone words: both halves of it exist here.
            model.report(Self.crossBlockMakeBlockRefusal)

        case .divide, .divideW, .merge, .mergeChain:
            // Unreachable from the two span commands (the planner's own
            // switch); an impossible state answers with a refusal, never
            // a crash (the pure layer's rule, held at the door too).
            model.report(Self.spanRefusalMessage(.invalidSelection))
        }
    }

    /// The planner's refusal vocabulary in phone words — no platform
    /// named anywhere (the no-redirect principle); the roads named are
    /// the PHONE's own doors. The Mac's `RefusalCopy` is the tone
    /// reference; sentences shared where they were already
    /// platform-neutral.
    static func spanRefusalMessage(
        _ refusal: StructuralGesturePlanner.Refusal
    ) -> String {
        switch refusal {
        case .sealed:
            "This note is locked — unlock it to restructure."
        case .gapSlot:
            "This block hasn't fully synced yet — try again once it arrives."
        case .lockedVariant:
            MobileEditorViewModel.lockedTakeRefusal
        case .openTailTarget:
            "This text isn't a block yet — it becomes one moments after you pause typing."
        case .crossBlockSpan:
            "The selection crosses a block boundary — divide the neighbors "
                + "at the edges you want, then merge the middle pieces."
        case .wholeBlockSpan:
            "That selection already is a whole block — select part of it to split one out."
        case .middleSpanNeedsMakeBlock:
            "Extract takes a span at the block's start or end — for a "
                + "middle span, use Make Block from Selection."
        case .fannedMiddleSpan:
            // The Mac's answer opens the W ceremony; the phone's honest
            // road is its own ruled divide (Q-M2 — the other takes ride
            // onto both halves whole), named instead of a ceremony it
            // deliberately doesn't have.
            "This block has other takes — divide at the span's edges "
                + "instead: the other takes ride onto both halves whole."
        case .notASeam:
            "To merge, put the caret at a block seam or select across the blocks to join."
        case .nothingToDo:
            "No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks."
        case .invalidSelection:
            "The editor lost track of the selection — try again."
        }
    }

    /// The cross-block Make Block refusal (the guided flow's phone
    /// stand-in — a road named, never a redirect).
    static let crossBlockMakeBlockRefusal =
        "That selection crosses blocks — select within one block, or "
        + "merge the blocks first (⋯ → Merge with Previous)."

    /// The fanned-extract hint (the Mac's contract-item-8 sentence,
    /// shared verbatim).
    static func fannedExtractHint(_ otherTakes: Int) -> String {
        otherTakes == 1
            ? "This block has 1 other take — it keeps this span."
            : "This block has \(otherTakes) other takes — they keep this span."
    }

    // MARK: - Insert block below (parity C4b item 1 — the Mac 13b 4D act's
    // phone door; the matrix's "mechanical" row)

    /// Mints an EMPTY block right under the given block and lands the
    /// caret in it — `newBlock(text: "", at: .after(...))`, the Mac
    /// `insertBlockBelowCaret`'s exact op (I10 holds: the empty variant IS
    /// the block's one live take; blank takes render as the kept line).
    /// The awkward type-into-next-then-divide road retires as THE road;
    /// the door rides the ⋯ menu, which already resolves the caret's
    /// block and refuses honestly in the open tail. Same structural-act
    /// contract as every sibling: one flight, flush-first (a refused
    /// flush refuses the act — the insert itself reads no buffer, but a
    /// landed insert re-renders the surface, and re-rendering over
    /// unlandable pending bytes is the text-loss class the contract
    /// exists to kill), store-led settle, caret by identity.
    func insertBlockBelow(blockID: String) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        if model.isSealed {
            model.report("This note is locked — unlock it to add a block.")
            return
        }
        guard await flushPendingText() else { return }
        do {
            let result = try await session.runner.run { [postID = model.postID] ops in
                try ops.newBlock(in: postID, text: "", at: .after(blockID))
            }
            model.report(Self.blockInsertedStatus)
            await model.refreshTakesFromStore()
            if let range = model.rangeOfBlock(result.block.id) {
                model.textView?.selectedRange = NSRange(location: range.location, length: 0)
            }
        } catch {
            model.report(Self.refusalMessage(error, act: "add a block"))
        }
    }

    /// The Mac door's own note, verbatim (one sentence, both platforms).
    /// **No Undo rides it** (round 2 batch 4 — M20): `newBlock` registers
    /// no structural undo entry (AppSpec §9's list does not include it), so
    /// a button here would pop whatever entry happened to be on top — some
    /// EARLIER act she never asked to reverse. Verified by reading the op,
    /// not assumed.
    static let blockInsertedStatus = "New block added below — type away."


    // MARK: - Delete block (the ⋯ menu's destructive act — S4 ladder MAJOR 1)

    /// Deletes a block through the SAME structural-act contract as
    /// divide/merge — the one-flight latch, then flush-FIRST with the
    /// post-flush dirty re-check. `deleteBlock` IS a structural op (it
    /// registers structural undo and rides `runStructural` on the Mac),
    /// and the contract's second half is what makes the deleted block
    /// RECOVERABLE at all: a refused flush keeps its text pending
    /// (`isDirty` stays true), and a tombstone landed past it would strand
    /// the typed bytes outside both the surface and the tombstoned take
    /// they belong to — the text-loss class the flush-first contract exists
    /// to kill (the `.none` door does not
    /// refuse a locked take, so the op itself is no belt here).
    func deleteBlock(blockID: String) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        guard await flushPendingText() else { return }
        // The landing is read BEFORE the tombstone, from the index that
        // still holds the departing block (the run door's rule, applied to
        // one ID — ladder NIT 8: the two delete doors answered the caret
        // differently, and this one answered nothing at all).
        let landing = model.index.caretLandingAfterRemoving([blockID])
        do {
            try await session.runner.run { ops in
                try ops.deleteBlock(blockID)
            }
            model.report(
                Self.blockDeletedStatus
                    + (await strandedOriginalsNote(blockIDs: [blockID]) ?? ""),
                action: .undo)
            await model.refreshTakesFromStore()
            landCaret(landing)
        } catch {
            model.report(Self.refusalMessage(
                error, act: "delete the block", nothingWas: "deleted"))
        }
    }

    /// The delete report. **13j batch 2 made it true on the phone's own
    /// terms** — this app had no tray face, so naming one would have sent
    /// her looking for a door that was not there — and **round 2 batch 6b
    /// built the tray, so the sentence names it.** That is the J8 copy
    /// doctrine read from its other side: a line that keeps saying "no road"
    /// after the road opens is the same defect as one promising a road that
    /// does not exist. `MobileBlockMenuController.deleteConfirmDetail`
    /// carries the full history. Pinned static.
    static var blockDeletedStatus: String {
        "Block deleted \u{2014} \(MobileNoteTrayModel.putBackRoadPhrase)."
    }

    // MARK: - Archive block (PR6 — the gentler of the two ways a block
    // leaves the page; 13j's round-7 ruling built the op, batch 6b gives the
    // phone its door and its way back)

    /// **Set the block aside: `archiveBlock`.** Kept, forever, NO clock —
    /// which is the whole difference from the row beneath it in the menu,
    /// and the reason this door carries no confirm: nothing is destroyed and
    /// the receipt names the road back (blocks ▸ archived, one tap away in
    /// the same sheet).
    ///
    /// It rides the STRUCTURAL contract rather than the menu controller's
    /// own latch, exactly as Delete Block does, and for the same reason:
    /// `archiveBlock` RELEASES the placement, so the block leaves the
    /// surface and the caret needs somewhere to land — which is the shared
    /// brain's answer (`caretLandingAfterRemoving`), read BEFORE the write
    /// from the index that still holds the departing block.
    ///
    /// **No pre-checks (P-2, fire-and-DO):** the seal and a vanished block
    /// both refuse through the OPERATION, with nothing archived, and the
    /// door speaks the ops layer's real answer.
    func archiveBlock(blockID: String) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        guard await flushPendingText() else { return }
        let landing = model.index.caretLandingAfterRemoving([blockID])
        do {
            try await session.runner.run { ops in
                try ops.archiveBlock(blockID)
            }
            model.report(Self.blockArchivedStatus, action: .undo)
            await model.refreshTakesFromStore()
            landCaret(landing)
        } catch {
            model.report(Self.refusalMessage(
                error, act: "archive the block", nothingWas: "archived"))
        }
    }

    /// The archive receipt — what happened, and where it went. Archive's one
    /// promise is that there is no countdown, so the sentence says it
    /// (`RecoveryCopy.archivedForever` is the shared words for exactly that
    /// fact, and the road is composed from the door's own name).
    static var blockArchivedStatus: String {
        "Block archived \u{2014} \(RecoveryCopy.archivedForever), in "
            + "\(MobileNoteTrayModel.archivedRoadPhrase)."
    }

    // MARK: - Whole-block selection + Delete (round 2, batch 1b — R18 ≡ M11)

    /// **Her gesture, made to WORK.** Select one or more whole paragraphs
    /// and press delete: the blocks GO, through the same block-delete
    /// compound the ⋯ menu's act uses, under ONE undo entry. Batch 1 turned
    /// the crash into an honest refusal; this turns the refusal into the
    /// act she was reaching for.
    ///
    /// The Mac ruled this at 13j J9 and its road is the reference
    /// (`EditorSurfaceController.runBlockDeleteCompound`); the DECISION —
    /// which blocks does the span cover whole, and where does the caret
    /// land — is the shared brain's (`BlockRangeIndex.wholeBlockDeletion`,
    /// `caretLandingAfterRemoving`), so the two platforms cannot drift on
    /// it. What is per-platform here is only the flush contract, the
    /// receipt's words, and the caret write.
    ///
    /// **No pre-checks, on purpose (P-2, fire-and-DO).** The seal, a locked
    /// take, a block another pane deleted between the gesture and the press
    /// — every one of those refuses through the OPERATION, inside the
    /// compound, with nothing deleted, and the door speaks the ops layer's
    /// real answer rather than guessing at one. The gate above already
    /// stops a sealed note before the gesture is even armed; this door
    /// carries no second copy of that judgement.
    ///
    /// **NO CONFIRM, by her ruling** (author, 2026-08-21 — round 2 ladder
    /// R13, superseding the ladder's MAJOR 1: *"it's fine to have no
    /// confirm"*). The ⋯ menu's single-block door still asks, because that
    /// is a menu row and asking there costs a tap she already spent; this
    /// road is a keystroke, and the answer to "no way back" is the way
    /// back — the structural undo/redo door (M20) and the per-note tray
    /// (M21), both of which she asked for. The gate carries the same note
    /// at the routing site.
    ///
    /// **It ANSWERS whether it landed** (the batch-7 fix wave, cold review
    /// MINOR 3). A caller that has to decide what to do next — PR20's sheet
    /// puts picking mode away on a success and KEEPS her picks on a refusal
    /// (#59(k)) — was inferring that from a re-read of the listing, which
    /// made the discrimination ride on a read succeeding. The outcome is
    /// known right here; returning it is cheaper and cannot be wrong.
    /// `@discardableResult` because every other caller acts on the receipt.
    @discardableResult
    func deleteWholeBlockRun(_ blockIDs: [String]) async -> Bool {
        guard let model, !blockIDs.isEmpty else { return false }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return false
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        // Flush FIRST, like every structural door (the Takes board's
        // contract): the op validates against the store, and a tombstone
        // landed past a refused flush would strand the typed bytes outside
        // both the surface and the take they belong to.
        guard await flushPendingText() else { return false }
        // The landing is read AFTER the flush, from the then-current index:
        // the flush SUSPENDS, and a projection delivery landing in that
        // window re-tiles the entries. It names a SURVIVING block by ID —
        // never a surface offset, which the re-render would invalidate.
        let landing = model.index.caretLandingAfterRemoving(blockIDs)
        let stack = session.undoStack
        do {
            try await session.runner.run { ops in
                // ONE compound: N paragraphs deleted is ONE mistake to
                // reverse, not N (the Mac's "Delete Blocks" label, shared so
                // a future undo door on this phone reads the same words).
                // Every leg registers a redo, so the compound is redoable
                // too (13c A10: a compound is redoable exactly when every
                // leg is). A leg that throws after others landed unwinds
                // them — no partial acts.
                try stack.withCompound(label: "Delete Blocks", operations: ops) {
                    for blockID in blockIDs { try ops.deleteBlock(blockID) }
                }
            }
            model.report(
                Self.blocksDeletedStatus(blockIDs.count)
                    + (await strandedOriginalsNote(blockIDs: blockIDs) ?? ""),
                action: .undo)
            await model.refreshTakesFromStore()
            landCaret(landing)
            return true
        } catch {
            model.report(Self.refusalMessage(
                error,
                act: blockIDs.count == 1 ? "delete the paragraph" : "delete the paragraphs",
                nothingWas: "deleted"))
            return false
        }
    }

    // MARK: - Merge-then-edit (round 2, batch 3 — M22)

    /// **The ratified 2026-07-09 MERGE-THEN-EDIT, reaching the phone.** A
    /// selection that opens mid-paragraph and closes in another one, plus
    /// Delete (or typing over it), MERGES the touched run and applies the
    /// edit to the merged buffer — one act, one undo entry. Her correction
    /// is what brought it here (§30: *"i thought we added cross block edits
    /// on the mac app when there are no takes, where it just auto merges? is
    /// that being used here?"* — it was Mac-only, which was a parity gap),
    /// and her principle is what it serves (§31/R16: *"selecting a bunch of
    /// visible text and deleting should be allowed - the refusing because of
    /// different blocks is more annoying than it's worth"*).
    ///
    /// The DECISION and the ARITHMETIC are the shared brain's
    /// (`CrossBlockCompound.plan` / `.apply`, hoisted out of Mac app code at
    /// mobile round 2 and REBUILT to her item 5 rulings at 13u1 UNIT 2 —
    /// MobileSoul §3); this door is the phone's face on it: the flight
    /// latch, the pre-op flush, the caret write, and the words a refusal
    /// speaks.
    ///
    /// **What 13u1 UNIT 2 changed under this door, and what the phone still
    /// OWES.** The semantics are ruled once for both platforms (her item 5's
    /// own coordination flag), so the phone inherits them here rather than
    /// re-deciding them: blocks the selection covers WHOLE go to the
    /// Trash/tray, the surviving ends take their chosen takes' edits, the
    /// ends join only mid-paragraph and only with no fan on either, a locked
    /// take refuses the whole gesture, and the seventh quiet auto-commit
    /// occasion lands first. What is NOT built here is the phone's FACE for
    /// it — a receipt naming where every block went (the Mac's
    /// `CrossBlockEditCopy`) and its own walk. That is the mobile project's,
    /// recorded in the 13u1 closeout's parity row rather than guessed at
    /// from the Mac side.
    ///
    /// **No re-verify after the flush, deliberately — the compound carries a
    /// stronger guard.** The divide/merge doors re-check their caret pair
    /// because their plans are positional; this plan is a compare-and-set
    /// against every touched take's plan-time text, checked INSIDE the
    /// transaction (`editTakesAtomically`'s `expectedText`), so a buffer that
    /// moved during the flush refuses the whole compound before a single row
    /// changes. That is the Mac's own posture, byte for byte.
    ///
    /// **NO CONFIRM**, for the same reason its sibling delete door asks
    /// nothing (R13): this is a keystroke, and it is the gesture that makes
    /// her text behave like text.
    func runCrossBlockEdit(_ edit: CrossBlockCompound.Plan) async {
        guard let model else { return }
        guard !structuralInFlight else {
            model.report("Another structural change is still landing.")
            return
        }
        structuralInFlight = true
        defer { structuralInFlight = false }

        // Flush FIRST, like every structural door: the ops validate against
        // the store, and the compound's compare-and-set is stated in terms
        // of the SURFACE texts the plan captured — after the flush those are
        // the same bytes.
        guard await flushPendingText() else { return }
        let stack = session.undoStack
        do {
            let database = session.database
            let outcome = try await session.runner.run { ops in
                try CrossBlockCompound.apply(
                    edit, ops: ops, undoStack: stack,
                    liveActiveTakeCount: { blockID in
                        // The fan question, from the STORE at run time — the
                        // 13c R3-1 law the Mac states at its own door:
                        // never authorize from stale state.
                        try database.read { db in
                            try Queries.blockFan(db, blockID: blockID)
                                .filter { $0.deletedAt == nil && $0.status == .active }
                                .count
                        }
                    })
            }
            // Nothing to announce: the paragraphs joined and the selection
            // vanished, which is exactly what she asked the keystroke for
            // (the Mac says nothing here either). Clearing drops any stale
            // refusal line from an earlier attempt.
            //
            // **AND SINCE ROUND 2 BATCH 4 IT OFFERS UNDO** (M20). This is
            // the act that most needs it: R13 removed this road's confirm on
            // the recorded justification that *"the answer to 'no way back'
            // is the way back — the structural undo/redo door (M20)"*, and
            // until now that replacement did not exist. The receipt stays
            // WORDLESS — this fires at keystroke rate, from ⌫ or from typing
            // over a selection, so a sentence would be noise — and the bare
            // Undo is the whole affordance.
            model.report(nil, action: .undo)
            await model.refreshTakesFromStore()
            landCaret((blockID: outcome.caretBlockID, offset: outcome.caretOffset))
        } catch {
            model.report(Self.refusalMessage(
                error, act: "join these blocks", nothingWas: "changed"))
        }
    }

    /// The caret write both delete doors share — by IDENTITY, over the
    /// re-rendered surface (the landing named a SURVIVING block before the
    /// tombstone; a landing whose block did not survive simply isn't found
    /// and the caret stands still). M22's merge-then-edit lands through it
    /// too: its landing names the MERGED block, which the re-render has by
    /// then materialized.
    private func landCaret(_ landing: (blockID: String, offset: Int)) {
        guard let model, let range = model.rangeOfBlock(landing.blockID) else { return }
        model.textView?.selectedRange = NSRange(
            location: min(range.location + landing.offset, range.upperBound), length: 0)
    }

    /// **Did this delete strand a preserved original?** (13j's round-8b
    /// ruling (d), reaching the phone — ladder NIT 7.) Her named failure
    /// mode was believing an ancestor waiting in lineage is a guaranteed
    /// backup: when a delete takes the LAST live descendant of a divide's
    /// preserved original, the original stops being permanent and rides the
    /// family's fate — and deleting a divide's two successors together is
    /// the commonest way to do it, which is exactly what the whole-block
    /// run door makes easy.
    ///
    /// Asked AFTER the delete lands, from the STORE (`Queries`' own read —
    /// no new brain): whether the deleted blocks were the last live
    /// descendants is a fact about rows, never a guess from a projection.
    /// Nil when nothing was stranded — the ordinary case, and no sentence
    /// at all beats a reassuring one.
    private func strandedOriginalsNote(blockIDs: [String]) async -> String? {
        guard !blockIDs.isEmpty else { return nil }
        let stranded = (try? await session.database.read { db in
            try Queries.originalsStrandedBy(db, blockIDs: blockIDs)
        }) ?? []
        guard !stranded.isEmpty else { return nil }
        return Self.strandedOriginalNote(stranded.count)
    }

    /// The stranding sentence, in the PHONE's words.
    ///
    /// **ROUND 2 BATCH 4: IT GRADUATES, exactly as its own comment promised
    /// it would.** It used to withhold the destination — *"goes with it"* —
    /// because the Mac's version named a Trash this phone did not have, and
    /// 13j J8(a)'s doctrine forbids promising a door she cannot open. PR2
    /// built that door, so the sentence now says where the original goes,
    /// which is the whole point of telling her at all.
    /// Pinned static.
    static func strandedOriginalNote(_ count: Int) -> String {
        count == 1
            ? " The original preserved from this block's divide goes to the "
                + "\(RecoveryCopy.trashSection) with it."
            : " \(count) preserved originals go to the "
                + "\(RecoveryCopy.trashSection) with these blocks."
    }

    /// The whole-block-selection delete's receipt. It reuses the pinned
    /// single-block sentence for N = 1 so the two doors can never fork, and
    /// it keeps the phone's OWN words because the Mac's
    /// (`BlockSelectionCopy.deletedNote`) names ⌥⌘Z and the note's tray:
    /// this phone has no chord culture and its tray face is still the
    /// ledger's PL-11 row (batch 5). What it HAS since round 2 batch 4 is
    /// the undo door (M20) — which is why this receipt now carries an Undo
    /// ACTION beside it rather than another sentence.
    static func blocksDeletedStatus(_ count: Int) -> String {
        count <= 1 ? blockDeletedStatus : "\(count) blocks deleted."
    }

    // MARK: - Shared pieces

    /// The Takes board's pending-text contract, verbatim (one declared
    /// act, one contract, however many doors) — the contract itself moved
    /// onto the VM at round 2 batch 2, where the copy door became its
    /// third caller and the refusal sentence had already been written out
    /// twice (`MobileEditorViewModel.flushPendingText`). Behaviour is
    /// byte-identical; this is the forwarder its six call sites keep.
    private func flushPendingText() async -> Bool {
        guard let model else { return false }
        return await model.flushPendingText()
    }

    /// The entry whose CLOSED range [start, end] contains the caret (the
    /// planner's `entryTouching` rule — a caret at a block's exact end is
    /// block-side; the separator's trailing side maps to the next entry).
    private func entryTouching(caret: Int) -> (Int, Int)? {
        guard let model else { return nil }
        var location = 0
        for (i, entry) in model.index.entries.enumerated() {
            if caret >= location, caret <= location + entry.length {
                return (i, caret - location)
            }
            location += entry.length + 1
        }
        return nil
    }

    private func tailOrEmptyRefusal(empty: String, tail: String) -> String {
        (model?.index.entries.isEmpty ?? true) ? empty : tail
    }

    /// The everyday refusals in phone words; the rest is the shared refusal
    /// table's words where it has them (18m U3 — this door dumped the raw
    /// enum before), and the operations layer's own description where it has
    /// none.
    ///
    /// `nothingWas` is the verb the ROLLBACK sentence needs — "deleted" at
    /// the two delete doors, "changed" everywhere else. Every door here
    /// runs ONE `session.runner.run` transaction, so a throw means nothing
    /// landed; the word only decides how precisely the sentence can say so.
    /// It is why the three rollback arms below stay HERE (18m U3's collapse
    /// rule: an arm stays local for a phone door or a context the table
    /// lacks) — and `.lockedVariant` stays for the phone's takes-sheet road.
    /// (`.invalidCut`'s sentence moved to the table: the Mac planner already
    /// said it byte-for-byte.)
    static func refusalMessage(
        _ error: Error, act: String, nothingWas: String = "changed"
    ) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return SealedNoteCopy.sentence(act: act, words: .phone)
        case .lockedVariant:
            return MobileEditorViewModel.lockedTakeRefusal
        // **`blockNotFound`, in words** (round 2 batch 1b ladder, MINOR 2).
        // It dumped the raw enum here because until the whole-block-run
        // door existed, every phone door onto it named the ONE block the
        // caret was in. The run door holds a list of IDs across a flush,
        // and the store can move under it: a second ⌫ during the first
        // compound's flush re-plans now-stale IDs, another surface deletes
        // one, a sync arrival tombstones one. **The compound's atomic
        // rollback means she meets it with NOTHING deleted — that is the
        // fact the words must carry**, or a rolled-back gesture reads as a
        // half-done one and she goes looking for the wreckage.
        //
        // It is the phone's OWN sentence, not the Mac's: the Mac's
        // `BlockSelectionCopy.blockGone` says "the blocks you picked" and
        // "pick again", which is ⌘-click vocabulary this phone has no door
        // for. Same fact, this app's gesture.
        case .blockNotFound:
            return "One of these blocks is already gone — it may have been deleted "
                + "since you selected it. Nothing was \(nothingWas); try again."
        // **The compare-and-set refusal, in words (M22).** Merge-then-edit
        // leans on it BY DESIGN — the keystroke is refused so a compound can
        // reproduce it, and anything typed in that window makes the compound
        // decline rather than clobber newer text. A designed, reachable
        // refusal must not read as a Swift enum dump (the ladder MINOR 2
        // class), and the sentence has to carry the rollback: nothing landed.
        case .bufferChangedSinceGesture:
            return "The text changed while that was landing — nothing was "
                + "\(nothingWas). Try it again on the current text."
        // **The adjacency refusal, in words (M22).** Reachable from every
        // merge-shaped door, and the merge-then-edit road makes it easy to
        // meet: a NOT-YET-ARRIVED block renders with zero length, so a
        // selection can run straight past one without ever touching its
        // characters — the plan then names the two blocks she can read, and
        // the operations layer refuses because the gap sits between them.
        // (It also covers the ordinary race: a block landing between the
        // plan and the write.) Both readings are one sentence, and the
        // sentence carries the rollback: the op is one transaction, so
        // nothing landed.
        case .blocksNotAdjacent:
            return "Something sits between these paragraphs — a block that hasn't "
                + "arrived yet, or one that landed since you selected. "
                + "Nothing was \(nothingWas)."
        default:
            return OpsRefusalCopy.words(for: error, roads: .phone) ?? String(describing: error)
        }
    }
}
