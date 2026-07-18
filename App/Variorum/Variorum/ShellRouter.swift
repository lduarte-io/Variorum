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

import Observation

@MainActor
@Observable
final class ShellRouter {
    /// A navigation the next RootView pass adopts (then clears).
    var pendingSelection: SidebarSelection?
    /// ⌘K — the palette open request (R15: every buried capability
    /// typeable).
    var paletteRequested = false
}
