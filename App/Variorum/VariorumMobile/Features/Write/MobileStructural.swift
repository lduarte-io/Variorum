//
//  MobileStructural.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M10; divide re-ruled at the gate — Q-M2) —
//  the phone's divide/merge doors. A sibling type beside the takes
//  controllers (the S1 NIT-3 law); the VM routes thinly.
//
//  DIVIDE (Q-M2 — her duplicate-shape ruling, 2026-08-03 gate sitting;
//  SUPERSEDES M10's auto-proceed/refuse pair): single-take divide is
//  the everyday in-place op; a FANNED block divides through the shared
//  `Operations.divideDuplicating` — the DISPLAYED (peek-aware) take is
//  cut into B and C, and every OTHER active take is duplicated WHOLE
//  onto both successors. No `CutPropagation`, no unique-match gate, no
//  refusal naming any platform ("it sidesteps smart divide rules
//  entirely - the takes that you aren't dividing are just duplicated,
//  one per each block"). The cut snaps through the ONE snap brain
//  (`StructuralGesturePlanner.snapToInteriorBoundary` — the ruled word
//  rule with the gentle settle, S4-22's letter).
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
//  released sources in lineage (the divideDuplicating parallel; the
//  core refuses archived carries by design). The fan check reads the
//  STORE, never the projection (the 13d ruled discipline: a plan-time
//  arity is an enablement hint, never an authorization).
//
//  Both doors FLUSH FIRST (the Takes board's `prepareDivide` contract:
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

        // The fanned path (Q-M2, her duplicate-shape ruling — the ruled
        // DEFAULT): the DISPLAYED (peek-aware) take is cut; every other
        // active take duplicates WHOLE onto both successors through the
        // shared core op. The displayed take must still BE in the live
        // fan (the Takes board's F-3 guard — a fallback would divide a
        // take she was never in).
        guard let displayedID = fresh.variantID,
              active.contains(where: { $0.id == displayedID })
        else {
            model.report("This block's takes changed — try the divide again.")
            return
        }
        await runDivide(blockID: blockID) { ops in
            try ops.divideDuplicating(
                blockID, displayedVariantID: displayedID, cut: cut).first.block.id
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
            model.report(nil)
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
            // The canon join resolved on the post-flush store texts —
            // the plain merge's exact rule, through the ONE join brain.
            let pairing = Operations.MergePairing(
                firstVariantID: head.id, secondVariantID: tail.id,
                join: MergeJoin.canon(head: head.workingText, tail: tail.workingText))
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
            model.report(nil)
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
                model.report(otherTakes > 0 ? Self.fannedExtractHint(otherTakes) : nil)
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
                model.report(nil)
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
    static let blockInsertedStatus = "New block added below — type away."

    // MARK: - Delete block (the ⋯ menu's destructive act — S4 ladder MAJOR 1)

    /// Deletes a block through the SAME structural-act contract as
    /// divide/merge — the one-flight latch, then flush-FIRST with the
    /// post-flush dirty re-check. `deleteBlock` IS a structural op (it
    /// registers structural undo and rides `runStructural` on the Mac),
    /// and the contract's second half is what makes the tray-copy promise
    /// TRUE: a refused flush keeps its text pending (`isDirty` stays
    /// true), and a tombstone landed past it would strand the typed bytes
    /// outside both the surface and the tray's copy — the text-loss class
    /// the flush-first contract exists to kill (the `.none` door does not
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
        do {
            try await session.runner.run { ops in
                try ops.deleteBlock(blockID)
            }
            model.report(Self.blockDeletedStatus)
            await model.refreshTakesFromStore()
        } catch {
            model.report(Self.refusalMessage(error, act: "delete the block"))
        }
    }

    /// The delete report (parity C2, inventory #5 — the "on the Mac"
    /// redirect dissolved: the tray fact stays, neutrally; the recovery
    /// DOOR rides PL-3/13j). Pinned static.
    static let blockDeletedStatus =
        "Block deleted — it waits in this note's deleted-blocks tray."

    // MARK: - Shared pieces

    /// The Takes board's pending-text contract, verbatim (one declared
    /// act, one contract, however many doors).
    private func flushPendingText() async -> Bool {
        guard let model else { return false }
        await model.autosave.flushNow()
        guard !model.autosave.isDirty else {
            model.report("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        return true
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

    static func refusalMessage(_ error: Error, act: String) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return "This note is locked — unlock it to \(act)."
        case .lockedVariant:
            return MobileEditorViewModel.lockedTakeRefusal
        case .invalidCut:
            return "No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks."
        default:
            return String(describing: error)
        }
    }
}
