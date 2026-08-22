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
