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
            // Per-op labels (Phase 9, KnownIssues entry): the stack's change
            // observer keeps UndoMenuState current; disabled when empty.
            Button(Self.undoMenuTitle(for: session?.undoMenuState.topLabel)) {
                structuralUndo()
            }
            .keyboardShortcut("z", modifiers: [.command, .option])
            .disabled(session?.undoMenuState.topLabel == nil)
        }
        // The structural gestures' menu-bar door (Phase 9, contract item 1:
        // two named commands — Steps 4–5 add theirs here). Enablement is the
        // planner's verdict, read from the focused editor; invocation
        // re-plans, so a stale enablement surfaces the refusal instead of
        // acting (never silent).
        CommandMenu("Block") {
            Button("Divide Block at Cursor") {
                session?.editorRouter.active?.divideAtCursor()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            .disabled(!(session?.editorRouter.active?.gestureAvailability.divide ?? false))

            Button("Extract Selection") {
                session?.editorRouter.active?.extractSelection()
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(!(session?.editorRouter.active?.gestureAvailability.extract ?? false))

            Button("Make Block from Selection") {
                session?.editorRouter.active?.makeBlockFromSelection()
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            .disabled(!(session?.editorRouter.active?.gestureAvailability.makeBlock ?? false))

            Divider()

            Button("Merge Blocks") {
                session?.editorRouter.active?.mergeBlocks()
            }
            .keyboardShortcut("m", modifiers: [.command, .shift])
            .disabled(!(session?.editorRouter.active?.gestureAvailability.merge ?? false))
        }
    }

    /// Pure label derivation, tested directly ("Undo Divide", "Undo
    /// Extract", … — generic when the stack is empty).
    static func undoMenuTitle(for topLabel: String?) -> String {
        topLabel.map { "Undo \($0)" } ?? "Undo Structural Change"
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
