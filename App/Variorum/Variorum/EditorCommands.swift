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
    /// The "Show Blocks" tint toggle (9d) — shared with `EditorView` via
    /// AppStorage so the menu state and every editor's overlay agree.
    @AppStorage("showBlockBoundaries") private var showBlocks = false

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
        // two named commands). Doors fire and speak (author 2026-07-09,
        // superseding the disabled-door posture): items are enabled whenever
        // an editor is focused, invocation plans against the CURRENT
        // selection, and a refusal surfaces its copy in the status bar —
        // a refused shortcut was previously a silently dead key. The planner
        // verdict still dims the button bar (`gestureAvailability`).
        CommandMenu("Block") {
            Button("Divide Block at Cursor") {
                session?.editorRouter.active?.divideAtCursor()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Button("Extract Selection") {
                session?.editorRouter.active?.extractSelection()
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Button("Make Block from Selection") {
                session?.editorRouter.active?.makeBlockFromSelection()
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Divider()

            Button("Merge Blocks") {
                session?.editorRouter.active?.mergeBlocks()
            }
            .keyboardShortcut("m", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            Divider()

            // The fan door (9d): ANY block, any arity — the badge stays
            // fan-only, the door does not.
            Button("Show Takes") {
                session?.editorRouter.active?.openCaretFan()
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
            .disabled(session?.editorRouter.active == nil)

            // The "Show Blocks" tint mode (9d): stable soft-pastel block
            // backgrounds, same color never adjacent (BlockTint).
            Toggle("Show Blocks", isOn: $showBlocks)
                .keyboardShortcut("b", modifiers: [.command, .shift])
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
