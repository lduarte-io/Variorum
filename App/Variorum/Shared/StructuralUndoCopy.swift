//
//  StructuralUndoCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  **The structural undo/redo door's sentences, in ONE home** (round 2
//  batch 4 — M20, her own proposal: *"the phone just needs a structural
//  undo / redo? and a block restore door?"*).
//
//  The STACK has always been shared (`UndoStack` in core, session-scoped on
//  `AppSession`) and the phone has been REGISTERING entries since parity C2
//  — divide, merge, extract, delete, the takes browser's verbs, the whole
//  "Delete Blocks" compound. What the phone never had was a door onto it,
//  which is the distinction the round's own §24 MAJOR turned on: *a
//  capability verified at the API is not a capability until a door reaches
//  it.*
//
//  These are the words that door speaks. They live here rather than twice
//  because they name the stack's OUTCOMES ("Undid: Divide", "there is
//  nothing to undo"), which is one behaviour on both platforms — and
//  because the Mac already shipped them, so a second phrasing on the phone
//  would be drift, not localization.
//
//  What deliberately did NOT move: the Mac's `discardingUndoDetail`, whose
//  sentence names ⌘S. A chord is a platform fact, so the destructive-undo
//  warning's DETAIL is written per-platform over the shared QUESTION below
//  — the same split the phone's structural refusals already use against the
//  Mac's `RefusalCopy`.
//

import Foundation
import VariorumCore

nonisolated enum StructuralUndoCopy {
    /// The two doors' verbs, with the entry's own label ("Divide", "Delete
    /// Blocks") — the per-op labels `UndoStack` has carried since Phase 9.
    static func undoDoorTitle(_ label: String) -> String { "Undo \(label)" }
    static func redoDoorTitle(_ label: String) -> String { "Redo \(label)" }

    /// The receipts.
    static func undone(_ label: String) -> String { "Undid: \(label)" }
    static func redone(_ label: String) -> String { "Redid: \(label)" }
    static let nothingToUndo = "No structural change to undo."
    static let nothingToRedo = "No structural change to redo."
    static let undoCancelled = "Undo cancelled — nothing changed."

    /// **A press that found nothing of its entry's to change** (VX-246 U2 —
    /// VX-276/VX-277/VX-119): the act's result was already gone (put back,
    /// restored, renamed back, chosen again — by her own undo-less door or a
    /// sync), so the stack RETIRED the entry instead of writing over hers.
    /// The door did nothing, so it speaks a REFUSAL (AppSpec §12), naming
    /// the entry (an MCP entry keeps its client's name). Words as built —
    /// on the FOR VX-234 list.
    static func undoFoundNothing(_ label: String) -> String {
        "Nothing to undo — \(label) was already undone or changed since."
    }

    static func redoFoundNothing(_ label: String) -> String {
        "Nothing to redo — it changed again after \(label) was undone."
    }

    /// **The door's in-flight refusal** (18k C5, 17e P33): a second press
    /// while the first is still landing. The door reads the stack across
    /// suspensions (the A12 warning, then the act), so a press inside the
    /// first's flight would act on an entry nobody was asked about. The
    /// phone's door said this first (`MobileUndoDoor`, M20); the Mac's door
    /// adopted the rule at 18k, and the words moved here so the one sentence
    /// has one home — the same words every structural door's own flight
    /// guard already speaks.
    static let anotherIsLanding = "Another structural change is still landing."

    /// A failed inverse STAYS on the stack (the `UndoStack` doctrine): the
    /// user resolves the refusal — unseal the note, say — and presses again.
    static func undoFailed(_ message: String) -> String { "Undo failed: \(message)" }
    static func redoFailed(_ message: String) -> String { "Redo failed: \(message)" }

    /// **The destructive-undo warning's question** (A12, her 13d ruling):
    /// it fires ONLY when the undo would discard text edited since the
    /// operation — the insurance class, `UndoStack.pendingUndoWarning`.
    /// Every other structural undo stays silent, and redo is untouched.
    static func discardingUndoQuestion(_ warning: UndoStack.PendingUndoWarning) -> String {
        "Undo \(warning.label)?"
    }
}
