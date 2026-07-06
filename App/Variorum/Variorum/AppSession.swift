//
//  AppSession.swift
//  Variorum
//
//  The composition root's shared state: the opened store plus the
//  session-scoped objects every feature receives by injection (no globals —
//  CLAUDE.md code hygiene). Cross-feature interaction routes through parent
//  composition holding this, never feature-to-feature calls.
//

import VariorumCore

@MainActor
final class AppSession {
    let database: AppDatabase
    /// The session-scoped structural undo stack (AppSpec §9) — in-memory,
    /// never persisted, wired to the Edit menu in EditorCommands.
    let undoStack: UndoStack
    let operations: Operations
    /// Serial off-main executor for every operations-layer write (P2), and
    /// the serialization guard `undo()` requires.
    let runner: OperationsRunner

    init(database: AppDatabase) {
        self.database = database
        let undo = UndoStack()
        self.undoStack = undo
        let ops = Operations(undoStack: undo)
        self.operations = ops
        self.runner = OperationsRunner(operations: ops)
    }
}
