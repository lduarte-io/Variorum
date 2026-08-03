//
//  MobileTakesController.swift
//  VariorumMobile
//
//  Mobile Stage 2, batch 1 (M4/M5/M6/M9 + LK3/LK6/LK10): takes arrive on
//  the phone — the swipe-peek's brain. A SIBLING type beside
//  `MobileEditorViewModel` (the S1 ladder's NIT-3, binding: composition,
//  never VM growth): the VM routes thinly; this object owns the fan/peek
//  state and every takes decision.
//
//  THE PEEK MODEL (M6/M9, her rulings): flipping only PREVIEWS — the
//  display swaps to another take IN PLACE with ZERO store writes (no
//  variant row moves, no chosen pointer moves, no outbox row — pinned);
//  the peek is STICKY while the note is open and simply evaporates with
//  this object when the note closes; ✓ (`chooseDisplayed` →
//  `Operations.chooseVariant`) is the ONLY act that chooses, and its
//  refusals speak. Which take is CHOSEN stays unambiguous: the chrome
//  marks peeked blocks visibly, and flipping back ONTO the chosen take
//  ends the peek (displaying truth is not a peek).
//
//  MECHANISM — the peek is a PROJECTION OVERLAY, not a view overlay: the
//  spike proved the display-swap primitive (item 4), and the brief's
//  peeked-take EDITING requirement (R8/R23's letter — everything visible
//  in an editing surface is editable) is why the swap rides the RENDER
//  PATH rather than an opaque cover view. `overlay(_:)` maps every
//  incoming projection before the VM's policy sees it: a peeked slot's
//  `variantID`/`text`/`variantLocked` become the PEEKED take's, so the
//  index routes edits — and the autosave — to the displayed variant with
//  no second mechanism, the identity audit stays clean, and the sealed/
//  locked refusals fire exactly as they do for chosen text.
//
//  TEXT RESOLUTION is LEDGER-FIRST: the surface's own record of what a
//  variant holds (`MobileEditorViewModel.surfaceKnownText`) outranks the
//  fan cache, so flipping away from a just-edited take and back shows the
//  edited bytes even before the autosave flush lands. Documented
//  consequence: a REMOTE edit of the very take being peeked stays
//  invisible until the peek ends (the ledger self-perpetuates this
//  surface's text) — sync's conflict-as-variant (S5) owns the true
//  concurrent-edit story, exactly as on the Mac's live surface.
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileTakesController {
    private let runner: OperationsRunner
    weak var model: MobileEditorViewModel?

    /// blockID → the block's live ACTIVE fan in fan order (the one tested
    /// core read, `Queries.activeFans`, riding the takes projection).
    private(set) var fans: [String: [Variant]] = [:]
    /// blockID → the PEEKED take's variant id. Absent = the block displays
    /// its chosen truth. Session-local by construction — never persisted,
    /// never synced (M9's sticky-while-open rule is this dictionary's
    /// lifetime).
    private(set) var peeks: [String: String] = [:]
    /// blockID → the RAW (chosen-truth) slot while a peek covers it —
    /// recorded at flip-on, refreshed by every projection ingest, cleared
    /// when the peek ends. What "flip back to chosen" restores.
    private(set) var originals: [String: Queries.RenderedBlock] = [:]

    /// The chrome's hook: a peek flipped / was chosen / ended on this
    /// block — refresh and (re)show the pill there.
    var onPeekChanged: ((String) -> Void)?

    init(runner: OperationsRunner) {
        self.runner = runner
    }

    func isPeeking(_ blockID: String) -> Bool { peeks[blockID] != nil }

    /// The STORE's chosen truth for a block, peek-aware: while a peek
    /// covers the slot the raw (chosen-truth) slot lives in `originals`;
    /// otherwise the displayed slot IS the truth. The browser's ✓-ring
    /// reads this (S2 batch 2).
    func chosenVariantID(_ blockID: String) -> String? {
        originals[blockID]?.variantID ?? model?.slot(for: blockID)?.variantID
    }

    /// Ends a block's peek WITHOUT restoring the display (S2 batch 2 —
    /// the browser's ✓ door): the explicit choose decides what the page
    /// shows, so the caller follows with a fresh store refresh whose
    /// delivery lands the new truth through the ordinary projection door.
    /// A no-op where no peek exists.
    func endPeek(_ blockID: String) {
        guard peeks[blockID] != nil else { return }
        peeks[blockID] = nil
        originals[blockID] = nil
        onPeekChanged?(blockID)
    }

    // MARK: - Projection ingestion

    /// Adopts a delivery's fan state and PRUNES peeks the new state can no
    /// longer honor: a peeked take that vanished from the fan (archived or
    /// deleted elsewhere), or a fan that collapsed below two. The display
    /// heals through the accompanying slot apply — the raw slot flows past
    /// the overlay and the differential replaces the surface text.
    func adoptFans(_ new: [String: [Variant]]) {
        fans = new
        for (blockID, peek) in peeks {
            let fan = new[blockID] ?? []
            if fan.count < 2 || !fan.contains(where: { $0.id == peek }) {
                peeks[blockID] = nil
                originals[blockID] = nil
            }
        }
    }

    /// The overlay door — every projection the VM applies passes through
    /// here first. Peeked slots swap to the peeked take (id, text, lock);
    /// everything else passes untouched. Two self-healing rules ride it:
    /// a slot whose CHOSEN variant now equals the peek means the store
    /// caught up (our ✓ or the Mac's) — the peek is fulfilled and ends;
    /// a peek whose take is gone from the fan prunes (belt to
    /// `adoptFans`' suspenders — deliveries always run both).
    func overlay(_ slots: [Queries.RenderedBlock]) -> [Queries.RenderedBlock] {
        guard !peeks.isEmpty else { return slots }
        return slots.map { slot in
            guard let peek = peeks[slot.blockID] else { return slot }
            if slot.variantID == peek {
                peeks[slot.blockID] = nil
                originals[slot.blockID] = nil
                return slot
            }
            guard let take = fans[slot.blockID]?.first(where: { $0.id == peek }) else {
                peeks[slot.blockID] = nil
                originals[slot.blockID] = nil
                return slot
            }
            originals[slot.blockID] = slot
            return peekedSlot(over: slot, take: take)
        }
    }

    // MARK: - The flip (M5's gesture lands here)

    /// One horizontal flip on a fanned block: the display moves to the
    /// next/previous take in fan order, wrapping (the spike's carousel —
    /// the R24 strip made physical). Landing on the CHOSEN take ends the
    /// peek: the display is truth again, the marker goes. Bails under
    /// marked text (mutating mid-IME composition is the idle-mint guard's
    /// class) and on gap/fanless blocks.
    func flip(blockID: String, forward: Bool) {
        guard let model, !model.markedTextActive else { return }
        guard let current = model.slot(for: blockID) else { return }
        guard let fan = fans[blockID], fan.count > 1 else { return }
        let step = forward ? 1 : -1
        let nextIndex: Int
        if let i = fan.firstIndex(where: { $0.id == current.variantID }) {
            nextIndex = (i + step + fan.count) % fan.count
        } else {
            // The displayed variant is outside the active fan (an archived
            // default rendering by fallback): enter the carousel at its
            // nearest end.
            nextIndex = forward ? 0 : fan.count - 1
        }
        let next = fan[nextIndex]
        // `current` is the RAW slot exactly when no peek exists yet.
        let original = originals[blockID] ?? current
        if next.id == original.variantID {
            peeks[blockID] = nil
            originals[blockID] = nil
            model.displaySlot(original, for: blockID)
        } else {
            peeks[blockID] = next.id
            originals[blockID] = original
            model.displaySlot(peekedSlot(over: original, take: next), for: blockID)
        }
        onPeekChanged?(blockID)
    }

    // MARK: - ✓ (M6: the ONLY choosing act)

    /// Commits the peeked take as the slot's chosen variant through the
    /// operations layer (I3: the choice lives on the pointer). Rendered
    /// only while a peek exists (P-2 — displaying the chosen take offers
    /// no ✓); refusals speak through the VM's status voice. On success the
    /// peek simply ends — the surface already shows the take, and the
    /// store's delivery confirms as an echo.
    func chooseDisplayed(blockID: String) async {
        guard let peek = peeks[blockID] else { return }
        do {
            try await runner.run { ops in
                try ops.chooseVariant(blockID, variantID: peek)
            }
            peeks[blockID] = nil
            originals[blockID] = nil
            onPeekChanged?(blockID)
        } catch let error as OperationError {
            model?.report(Self.chooseRefusalMessage(error))
        } catch {
            model?.report(String(describing: error))
        }
    }

    /// The choose door's refusal copy. The sealed post is the one everyday
    /// case (the brief's named example); rarer races (archived take,
    /// unplaced block) speak in the operations layer's own words.
    static func chooseRefusalMessage(_ error: OperationError) -> String {
        switch error {
        case .lockedPost:
            "This note is locked — unlock it on the Mac to choose a take."
        default:
            String(describing: error)
        }
    }

    // MARK: - The pill's content (LK6 — brain here, pixels in the chrome)

    struct PillContent: Equatable {
        /// "take k/n" + " · label" where the take carries one.
        let text: String
        /// True while the displayed take is a PEEK — ✓ renders and acts.
        /// False when the display is the chosen truth — the pill states
        /// "✓ chosen" instead (P-2: no door that cannot act).
        let canChoose: Bool
    }

    func pillContent(blockID: String) -> PillContent? {
        guard let model, let slot = model.slot(for: blockID),
              let fan = fans[blockID], fan.count > 1
        else { return nil }
        let displayed = fan.first { $0.id == slot.variantID }
        let k = fan.firstIndex { $0.id == slot.variantID }.map { $0 + 1 }
        var text = k.map { "take \($0)/\(fan.count)" } ?? "take –/\(fan.count)"
        if let label = displayed?.label, !label.isEmpty {
            text += " · \(label)"
        }
        return PillContent(text: text, canChoose: peeks[blockID] != nil)
    }

    // MARK: - Helpers

    /// A peeked rendering of one slot: the block's placement identity with
    /// the PEEKED take's variant, text, and lock. The counts are the
    /// block's own (same block — the badge never changes by peeking).
    private func peekedSlot(
        over slot: Queries.RenderedBlock, take: Variant
    ) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: slot.blockID,
            placementID: slot.placementID,
            position: slot.position,
            variantID: take.id,
            text: model?.surfaceKnownText(variantID: take.id) ?? take.workingText,
            activeVariantCount: slot.activeVariantCount,
            liveVariantCount: slot.liveVariantCount,
            commentCount: slot.commentCount,
            variantLocked: take.locked)
    }
}
