//
//  TakesChoreographer.swift
//  Variorum
//
//  13b Stage 3, N10 — the TakesViewModel P-9 decomposition, seam 2 of 2
//  (the plan's "choreography/landings" candidate, proposed from the code):
//  the CROSS-SURFACE choreography moves out of the conductor — the
//  fire-and-DO move-and-execute parking (1b's D3 replacement), the pane
//  selection the choreography carries, and the LANDING consumption (N9's
//  "just start typing" ring, the cross-mode bloom, the minted block's
//  focus-when-its-slot-arrives). These are the pieces that talk to the
//  ROUTER and to other surfaces; the conductor keeps the board's own
//  semantics (projection, columns, ops-call gestures, the keyboard
//  family) and forwards every existing name, so every view and pin call
//  site reads unchanged (behavior parity is the batch contract).
//
//  The back-reference is `unowned`: the view model owns the choreographer
//  strongly and is the only owner; the one internal Task here
//  (moveToWriteAndRun's flush-then-park) captures the MODEL through the
//  method the forwarder invoked, matching the pre-move capture shape.
//

import Foundation
import Observation
import VariorumCore

@MainActor
final class TakesChoreographer {
    unowned let model: TakesViewModel

    init(model: TakesViewModel) {
        self.model = model
    }

    // MARK: - Fire-and-DO (13b 1b, R115/R118 — the D3 lecture's replacement)

    enum MoveAndExecuteAct: Equatable {
        case structural(StructuralAct)
        case deleteInEveryTake
    }

    /// The ONE mode-switch choreography's takes-side half: park a Write
    /// landing (block + carried caret/selection + the gesture) on the
    /// router, flush this surface's pending text (same per-post
    /// coordinator — the arriving editor serializes on it), and switch
    /// modes VISIBLY. The gesture then plans against the real landed
    /// selection, so any refusal is the operation's own, spoken — the
    /// lecture-and-redirect door is retired (its copy was also factually
    /// wrong for Divide).
    /// `targetBlockID` names the block the landing addresses. Default (nil) is
    /// the routed target — the pane you're in — which is every pre-13e caller.
    /// 13e E3 passes the SECOND block of a ⌘-click merge pair, because the
    /// seam that pair means is the one above THAT block, not above whichever
    /// pane happens to hold the ring.
    func moveToWriteAndRun(_ act: MoveAndExecuteAct, targetBlockID: String? = nil) {
        // A NAMED target that the board no longer holds refuses; it never
        // falls back to the routed one, which would carry a different pair
        // than the author picked.
        let addressed: Queries.RenderedBlock?
        if let targetBlockID {
            addressed = model.projection.slots.first { $0.blockID == targetBlockID }
        } else {
            addressed = model.commandTargetSlot
        }
        guard let slot = addressed else {
            model.speak("Click into a block first — then the gesture knows where to act.")
            return
        }
        var intent = WriteIntent(postID: model.postID, blockID: slot.blockID)
        // The caret/selection transfers when the focused pane shows the
        // CHOSEN take (Write shows chosen — same text, same offsets). A
        // non-chosen pane lands at the block's start; on a fanned block
        // divide opens the take ceremony, where cuts are adjusted per
        // take (the W memo's reading).
        let carried: NSRange? = {
            guard let sel = paneSelection,
                  sel.variantID == model.focusedPane?.variantID,
                  sel.variantID == slot.variantID else { return nil }
            return sel.range
        }()
        switch act {
        case .structural(.merge), .structural(.mergeWithCeremony):
            // The merge memo: joining from Takes joins UPWARD — the caret
            // lands at the block's start, the seam with the block above.
            // (13j J4b: the ceremony door carries the same way — its sheet
            // mounts in Write, and it reads the same seam.)
            intent.offsetInBlock = 0
        case .structural(.divide), .structural(.divideWithCeremony):
            intent.offsetInBlock = carried?.location ?? 0
        case .structural(.extract), .structural(.makeBlock), .deleteInEveryTake:
            intent.offsetInBlock = carried?.location ?? 0
            intent.selectionLength = carried?.length ?? 0
        }
        switch act {
        case .structural(let gesture): intent.followUp = .structural(gesture)
        case .deleteInEveryTake: intent.followUp = .deleteInEveryTake
        }
        // Flush FIRST, then switch: the arriving editor's first render
        // reads the store, and the gesture must plan against the text the
        // author sees (the one per-post coordinator serializes the rest).
        // A REFUSED switch clears the parking (round-1 MAJOR, half a): a
        // stale intent surviving here would execute a structural gesture
        // unprompted at the next editor mount. `requestMode` speaks the
        // refusal itself (both failure branches).
        // Strong model capture, deliberately — the pre-move Task held the
        // view model for the flush-then-park's duration; the choreographer
        // rides its owner's lifetime.
        Task { [model, postID = model.postID] in
            await model.autosave.flushNow()
            model.session.commandRouter.pendingWriteIntent = intent
            if !model.session.commandRouter.requestMode(.write, postID: postID) {
                model.session.commandRouter.pendingWriteIntent = nil
            }
        }
    }

    // MARK: - Pane selection (the choreography's carried caret)

    /// The live pane's current selection, reported by the pane surface —
    /// what a fire-and-DO landing carries into Write.
    private(set) var paneSelection: (variantID: String, range: NSRange)?

    func notePaneSelection(variantID: String, range: NSRange) {
        paneSelection = (variantID, range)
    }

    // MARK: - Landings (13b 1b — N9/AD-17 + the cross-mode bloom)

    /// True on the PRIMARY takes board only (never the Write panel's
    /// embedded model): landing focus + cross-mode landings apply there.
    var landingEnabled = false
    private var landingFocusDone = false
    /// A freshly-minted block's variant: its pane takes the ring when the
    /// slot arrives (the add-block door's second half).
    private var pendingFocusVariantID: String?

    /// Parks the add-block door's second half (the conductor's
    /// `addBlockAtEnd` calls this after the mint).
    func parkFocus(onVariant variantID: String) {
        pendingFocusVariantID = variantID
    }

    /// The landing column for programmatic focus: the takes board's main
    /// column, or the lens board's first column.
    var landingColumnID: String {
        model.host == .takes
            ? TakesViewModel.takesMainColumnID
            : (model.columns.first?.id ?? "main")
    }

    func consumeLandings(_ new: Queries.TakesProjection) {
        // A minted block's pane goes live the moment its slot arrives.
        if let want = pendingFocusVariantID,
           let slot = new.slots.first(where: { $0.variantID == want }) {
            pendingFocusVariantID = nil
            model.focus(TakesViewModel.PaneKey(
                columnID: landingColumnID, blockID: slot.blockID, variantID: want))
            return
        }
        guard landingEnabled else { return }
        // A cross-mode landing (Lenses' ⌘⇧T: blooms live in Takes — GO
        // there and bloom, visibly). Post-stamped (the round-1 MAJOR's
        // staleness discipline): a landing for ANOTHER post is left alone —
        // consuming it here would bloom a foreign block and eat THIS
        // board's landing focus below.
        if let landing = model.session.commandRouter.pendingTakesLanding,
           landing.postID == model.postID {
            model.session.commandRouter.pendingTakesLanding = nil
            switch landing {
            case .bloom(_, let blockID):
                model.board.bloom(blockID)
                if let slot = new.slots.first(where: { $0.blockID == blockID }),
                   let variantID = slot.variantID {
                    model.focus(TakesViewModel.PaneKey(
                        columnID: landingColumnID, blockID: blockID, variantID: variantID))
                }
            }
            landingFocusDone = true
            return
        }
        // N9/AD-17 — "just start typing" at the Takes landing: with
        // nothing focused, an article pane takes the ring — the note's
        // CURRENT block's (the Act 10 correction round, row 39: the one
        // fact every mode enters on — Write's caret block, Read's
        // selection, Blocks' row), else the first block's.
        if !landingFocusDone, model.focusedPane == nil {
            let fact = model.session.commandRouter.focusedBlock
            let current = fact?.postID == model.postID
                ? new.slots.first { $0.blockID == fact?.blockID } : nil
            if let slot = current ?? new.slots.first, let variantID = slot.variantID {
                landingFocusDone = true
                model.landAuthorityFocus(TakesViewModel.PaneKey(
                    columnID: landingColumnID, blockID: slot.blockID, variantID: variantID))
            }
        }
    }
}
