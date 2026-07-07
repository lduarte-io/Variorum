//
//  AppSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  The composition root's shared state: the opened store plus the
//  session-scoped objects every feature receives by injection (no globals —
//  CLAUDE.md code hygiene). Cross-feature interaction routes through parent
//  composition holding this, never feature-to-feature calls.
//
//  Phase 8: compiled into BOTH app targets. The iOS capture surface uses the
//  same session shape over the same store — the mobile journal is a UI
//  profile, never a separate data model (CoreDescription pillar 8).
//

import Observation
import VariorumCore

/// The undo stack's menu-facing mirror (Phase 9 — per-op undo labels): a
/// tiny observable the Edit menu reads, refreshed by the stack's change
/// observer. The stack stays the truth; this is a projection.
@MainActor
@Observable
final class UndoMenuState {
    private(set) var topLabel: String?

    func refresh(from stack: UndoStack) {
        topLabel = stack.topLabel
    }
}

@MainActor
final class AppSession {
    let database: AppDatabase
    /// The session-scoped structural undo stack (AppSpec §9) — in-memory,
    /// never persisted. (On the Mac it wires to the Edit menu; the mobile
    /// surface performs no structural ops, so it stays empty there.)
    let undoStack: UndoStack
    let operations: Operations
    /// Serial off-main executor for every operations-layer write (P2), and
    /// the serialization guard `undo()` requires.
    let runner: OperationsRunner
    /// The Edit menu's window onto the undo stack (top label, live).
    let undoMenuState = UndoMenuState()

    #if os(macOS)
    /// The focused editor + per-post scroll anchors (text locations, never
    /// pixel offsets — the memo's restore rule). Menu commands route here.
    /// Mac-only: the TK2 editor is the Mac's surface (AppSpec §4).
    let editorRouter = EditorRouter()
    #endif

    init(database: AppDatabase) {
        self.database = database
        let undo = UndoStack()
        self.undoStack = undo
        let ops = Operations(undoStack: undo)
        self.operations = ops
        self.runner = OperationsRunner(operations: ops)
        // The stack mutates on the runner's executor; the menu mirror
        // refreshes on main. (Captures the state object and the stack, never
        // self — no cycle through the session.)
        let menuState = undoMenuState
        undo.setChangeObserver {
            Task { @MainActor in menuState.refresh(from: undo) }
        }
    }
}
