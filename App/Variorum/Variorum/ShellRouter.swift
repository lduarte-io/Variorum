//
//  ShellRouter.swift
//  Variorum (Mac)
//
//  Phase 13, B2 — the shell's routing channel: menu commands (⌘N New Post,
//  ⌘J Today, ⌘K palette — R41/R15) and the palette execute against this;
//  RootView adopts pending requests into its selection. Parent-composition
//  routing, never feature-to-feature (the EditorRouter pattern, one level
//  up).
//
//  Phase 13f, batch 3: it also carries the window's WORKSPACE (its open
//  notes and per-pane history). One shell, one workspace — so the state is
//  per-window by construction the moment batch 4 mints a second window, and
//  the navigation doors below stay what they are here: requests, adopted by
//  RootView exactly like every other pending selection (P-4 — the router
//  decides what a destination means, the doors only name one).
//

import Observation

@MainActor
@Observable
final class ShellRouter {
    /// A navigation the next RootView pass adopts (then clears).
    var pendingSelection: SidebarSelection?
    /// ⌘K — the palette open request (R15: every buried capability
    /// typeable).
    var paletteRequested = false

    /// 13f batch 3: the window's open notes + per-pane back/forward.
    let workspace = WorkspaceModel()

    // MARK: - The navigation doors (menu + strip)

    /// ⌘[ — walk the active pane back. Silent when there is nowhere to go:
    /// the menu item is grey exactly then (the registry's `canNavigateBack`),
    /// so this can only be reached by a race, and a race should not speak.
    func goBack(in pane: PaneID = .primary) {
        if let destination = workspace.goBack(in: pane) {
            pendingSelection = destination
        }
    }

    /// ⌘] — the mirror.
    func goForward(in pane: PaneID = .primary) {
        if let destination = workspace.goForward(in: pane) {
            pendingSelection = destination
        }
    }

    /// ⌘⇧n — the nth SHOWN row of the Open strip (1-based).
    func openNote(ordinal: Int) {
        if let id = workspace.openNotes.id(atOrdinal: ordinal) {
            pendingSelection = .post(id)
        }
    }
}
