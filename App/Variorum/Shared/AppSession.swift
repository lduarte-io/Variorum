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
import Foundation
import VariorumCore

/// The undo stack's menu-facing mirror (Phase 9 — per-op undo labels): a
/// tiny observable the Edit menu reads, refreshed by the stack's change
/// observer. The stack stays the truth; this is a projection.
@MainActor
@Observable
final class UndoMenuState {
    private(set) var topLabel: String?
    /// 13c 1B (A10): the redo half's label, from the same refresh — the
    /// stack stays the truth, this is a projection of BOTH its ends.
    private(set) var topRedoLabel: String?

    func refresh(from stack: UndoStack) {
        topLabel = stack.topLabel
        topRedoLabel = stack.topRedoLabel
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
    /// Phase 11 (review round 1, MINOR 2): every LIVE editing surface with
    /// its own autosave debounce — the takes board's panes, the TOC's
    /// expanded block — registers a flush here; the quit door awaits them
    /// ALL, not just the focused editor (the Phase 10 quit-door class,
    /// reintroduced by the new surfaces, closed the same way).
    /// (13b 1a refinement: surfaces no longer register themselves — the
    /// per-post autosave registry below registers each coordinator ONCE,
    /// so the quit door covers every surface of every open post by
    /// construction.)
    let quitFinalize = QuitFinalizeRegistry()

    /// Phase 13b Stage 1b (P-1/P-4): the ONE command-routing brain — the
    /// menu bar/palette/bars route surface commands and mode switches
    /// through this; surfaces register handlers by composition. Replaces
    /// the notification regimes (see `Registry/CommandRouter.swift`).
    let commandRouter = CommandRouter()
    /// Phase 13b Stage 1b (AD-14): the ONE status/refusal presentation —
    /// transient outcomes land here and render as the shell's toast.
    let status = StatusCenter()

    /// Phase 13b Stage 1a (N3): ONE `AutosaveCoordinator` per open post.
    /// Three surfaces used to mint their own (Editor / Takes / BlockTOC),
    /// so TWO debounced pipelines could run over one post at once (the
    /// Write takes panel over the Write editor) and flush a stale buffer
    /// OVER a newer one — the ordering was luck. One coordinator per post
    /// makes the newest text win structurally (one pending entry per
    /// variant). Coordinators are session-cached (tiny — a dictionary and
    /// an armed task only while dirty; bounded by posts opened per
    /// session) and each registers with the quit door exactly once.
    private var postAutosaves: [String: AutosaveCoordinator] = [:]

    func autosave(forPost postID: String) -> AutosaveCoordinator {
        if let existing = postAutosaves[postID] { return existing }
        let coordinator = AutosaveCoordinator(runner: runner)
        postAutosaves[postID] = coordinator
        _ = quitFinalize.register { [weak coordinator] in
            await coordinator?.flushNow()
        }
        return coordinator
    }

    /// 13b Stage 4, Batch 4B (S4-23 ruling 3): the merge ceremony's
    /// per-SESSION join memory — the last CONFIRMED join choice seeds the
    /// next sheet's pairings; a fresh launch resets to the canon default
    /// (one AppSession per launch; parallel test worlds stay independent).
    var mergeJoinMemory: MergeJoin?

    /// 13b Stage 2 ladder (NIT-6): the tutorial doors' in-flight latch —
    /// a double-pressed Restore must never race two discoveries into two
    /// live field guides. Session-scoped (parallel test worlds stay
    /// independent); `begin` runs synchronously at PRESS time, so the
    /// second press bails before any await can interleave.
    private(set) var tutorialDoorInFlight = false

    func beginTutorialDoor() -> Bool {
        if tutorialDoorInFlight { return false }
        tutorialDoorInFlight = true
        return true
    }

    func endTutorialDoor() {
        tutorialDoorInFlight = false
    }
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
        #if os(macOS)
        // 13b 1b composition wiring: routed speech lands in the status
        // center; the router's context reads the observable editor router
        // and undo mirror (so menu enablement tracks them).
        let status = self.status
        commandRouter.speak = { status.speak($0) }
        let editorRouter = self.editorRouter
        commandRouter.writeEditorAttached = { editorRouter.active != nil }
        commandRouter.undoAvailable = { menuState.topLabel != nil }
        commandRouter.redoAvailable = { menuState.topRedoLabel != nil }
        #endif
    }
}


#if os(macOS)
/// The quit door's finalize registry (Phase 11, review round 1, MINOR 2):
/// weak-closure entries so a dead surface no-ops; surfaces unregister at
/// teardown. `finalizeAll` runs every entry — the delegate awaits it
/// beside the focused editor's own finalize before replying to ⌘Q.
@MainActor
final class QuitFinalizeRegistry {
    private var entries: [UUID: @MainActor () async -> Void] = [:]

    var isEmpty: Bool { entries.isEmpty }

    func register(_ flush: @escaping @MainActor () async -> Void) -> UUID {
        let token = UUID()
        entries[token] = flush
        return token
    }

    func unregister(_ token: UUID) {
        entries[token] = nil
    }

    func finalizeAll() async {
        for flush in entries.values {
            await flush()
        }
    }
}
#endif
