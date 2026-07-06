//
//  EditorCommands.swift
//  Variorum
//
//  Menu wiring (Phase 7 Steps 5 + 7): the commit shortcut and the
//  structural-undo item. Structural undo is DISTINCT from command-Z —
//  command-Z stays NSTextView's per-buffer text undo; the two stacks never
//  interleave (OverallModel §3). undo() runs through OperationsRunner, so
//  two concurrent invocations execute one at a time (the KnownIssues
//  serialization note).
//

import SwiftUI
import VariorumCore

struct EditorCommands: Commands {
    let bootstrap: AppBootstrap

    private var session: AppSession? {
        if case .ready(let session) = bootstrap.state { return session }
        return nil
    }

    var body: some Commands {
        CommandGroup(after: .saveItem) {
            Button("Commit Take") {
                session?.editorRouter.active?.commitCaretVariant()
            }
            .keyboardShortcut("s", modifiers: .command)
        }
        CommandGroup(after: .undoRedo) {
            Button("Undo Structural Change") {
                structuralUndo()
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
        }
    }

    private func structuralUndo() {
        guard let session else { return }
        let undoStack = session.undoStack // Sendable; the closure must not capture the session
        Task { @MainActor in
            do {
                let label = try await session.runner.run { ops in
                    try undoStack.undo(with: ops)
                }
                session.editorRouter.active?.showStatus(
                    label.map { "Undid: \($0)" } ?? "No structural change to undo.")
            } catch {
                // A failed inverse stays on the stack (UndoStack doctrine);
                // the user resolves (e.g. unseals the post) and retries.
                session.editorRouter.active?.showStatus("Undo failed: \(error)")
            }
        }
    }
}
