//
//  MobileStructural.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M10) — the phone's divide/merge doors: the
//  Mac's own NO-CEREMONY paths, and honest refusals naming the Mac
//  exactly where a ceremony would open there. A sibling type beside the
//  takes controllers (the S1 NIT-3 law); the VM routes thinly.
//
//  DIVIDE (her ruling's letter, recorded at M10): auto-proceeds on a
//  fanned block when the cut lands uniquely in EVERY take — the ratified
//  #10 auto-proceed rule through the SHARED `CutPropagation` (the Mac
//  `propagatedCuts` mapping, mirrored exactly: the displayed take's
//  snapped cut carried into every other active take by unique match) —
//  and REFUSES where any take doesn't map, naming the Mac's take
//  ceremony. Single-take divide is the everyday in-place op. The cut
//  snaps through the ONE snap brain (`StructuralGesturePlanner.
//  snapToInteriorBoundary` — the ruled word rule with the gentle settle,
//  S4-22's letter).
//
//  MERGE: instant (`Operations.merge`) when NEITHER side carries a fan;
//  a fan on either side refuses to the Mac's pairing ceremony — the base
//  op COULD join chosen takes, but silently dropping her pairing options
//  is exactly what the ceremony exists to prevent (M10's in-sitting
//  precision). The fan check reads the STORE, never the projection (the
//  13d ruled discipline: a plan-time arity is an enablement hint, never
//  an authorization) — which also covers peeked blocks for free: a peek
//  requires a fan, so a peeked side always refuses to the ceremony.
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
            model.report("This note is locked — unlock it on the Mac to restructure.")
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

        let text = model.viewText(model.index.range(ofEntryAt: i))
        guard let cut = StructuralGesturePlanner.snapToInteriorBoundary(intra, in: text)
        else {
            model.report("No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks.")
            return
        }

        // THE FORK IS READ FROM THE STORE (the 13d ruled discipline).
        let blockID = entry.blockID
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
            guard entry.editable else {
                model.report("This take is locked — branch it or unlock it on the Mac to edit.")
                return
            }
            await runDivide(blockID: blockID) { ops in
                try ops.divide(blockID, cut: cut).block.id
            }
            return
        }

        // The fanned path: the displayed take must still BE in the live
        // fan (the Takes board's F-3 guard — a fallback would divide a
        // take she was never in).
        guard let displayedID = entry.variantID,
              let rendered = active.first(where: { $0.id == displayedID })
        else {
            model.report("This block's takes changed — try the divide again.")
            return
        }
        // The #10 auto-proceed mapping (the Mac `propagatedCuts`,
        // mirrored): the displayed take's cut carried into EVERY other
        // active take by CutPropagation's unique match.
        var cuts: [String: Int] = [displayedID: cut]
        for take in active where take.id != displayedID {
            guard let mapped = CutPropagation.propose(
                activeCut: cut,
                activeText: rendered.workingText,
                targetText: take.workingText)
            else {
                // Exactly where the Mac would open the W ceremony (M10:
                // refuse naming the Mac; the per-take decision is
                // genuinely a human's).
                model.report("One of this block's takes needs its cut placed by hand — "
                    + "that's the take ceremony, on the Mac for now.")
                return
            }
            cuts[take.id] = mapped
        }
        let markedCuts = cuts
        await runDivide(blockID: blockID) { ops in
            try ops.divideW(blockID, cuts: markedCuts).first.block.id
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
            model.report("This note is locked — unlock it on the Mac to restructure.")
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

        // The ceremony threshold reads the STORE (the 13d discipline):
        // ANY fan on either side is the Mac's pairing ceremony — the
        // phone refuses rather than silently dropping her pairing
        // options (M10's precision).
        let leadingID = leading.blockID
        let trailingID = trailing.blockID
        do {
            let counts = try await session.database.read { db in
                (first: try Queries.blockFan(db, blockID: leadingID)
                    .filter { $0.deletedAt == nil && $0.status == .active }.count,
                 second: try Queries.blockFan(db, blockID: trailingID)
                    .filter { $0.deletedAt == nil && $0.status == .active }.count)
            }
            if counts.first > 1 || counts.second > 1 {
                model.report("One of these blocks has other takes — pairing takes into a "
                    + "merge is the Mac's merge ceremony.")
                return
            }
        } catch {
            model.report(String(describing: error))
            return
        }

        let leadingLength = model.index.entries[i - 1].length
        do {
            let result = try await session.runner.run { ops in
                try ops.merge(leadingID, trailingID)
            }
            model.report(nil)
            await model.refreshTakesFromStore()
            // Caret at the join: right where the trailing half begins
            // (the Mac's instant-merge caret rule).
            if let range = model.rangeOfBlock(result.block.id) {
                let join = min(leadingLength, range.length)
                model.textView?.selectedRange = NSRange(
                    location: range.location + join, length: 0)
            }
        } catch {
            model.report(Self.refusalMessage(error, act: "merge the blocks"))
        }
    }

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
            return "This note is locked — unlock it on the Mac to \(act)."
        case .lockedVariant:
            return "This take is locked — branch it or unlock it on the Mac to edit."
        case .invalidCut:
            return "No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks."
        default:
            return String(describing: error)
        }
    }
}
