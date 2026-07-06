//
//  AppSession.swift
//  Variorum
//
//  The composition root's shared state: the opened store plus the
//  session-scoped objects every feature receives by injection (no globals —
//  CLAUDE.md code hygiene). Cross-feature interaction routes through parent
//  composition holding this, never feature-to-feature calls.
//

import Observation
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
    /// The focused editor + per-post scroll anchors (text locations, never
    /// pixel offsets — the memo's restore rule). Menu commands route here.
    let editorRouter = EditorRouter()

    init(database: AppDatabase) {
        self.database = database
        let undo = UndoStack()
        self.undoStack = undo
        let ops = Operations(undoStack: undo)
        self.operations = ops
        self.runner = OperationsRunner(operations: ops)
    }
}

/// Parent-composition routing for the focused editor: commands address the
/// active editor through this, never feature-to-feature.
@MainActor
@Observable
final class EditorRouter {
    weak var active: EditorViewModel?
    /// Top visible text location per post (UTF-16 offset) — content-anchored
    /// reopen restore (accepted memo: never px-anchor).
    @ObservationIgnored var scrollAnchors: [String: Int] = [:]
}
