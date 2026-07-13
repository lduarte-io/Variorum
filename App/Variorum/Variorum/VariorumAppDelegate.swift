//
//  VariorumAppDelegate.swift
//  Variorum
//
//  Quit-time safety: flush the focused editor's pending autosave and
//  crystallize a non-blank open tail before the process exits, so nothing
//  typed is ever lost to ⌘Q (the mutability rule's "always autosaving").
//

import AppKit

@MainActor
final class VariorumAppDelegate: NSObject, NSApplicationDelegate {
    weak var session: AppSession?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Phase 11 (review round 1, MINOR 2): the focused editor is no
        // longer the only surface holding a debounced buffer — the takes
        // board's panes and the TOC's expanded block register their
        // flushes with the session; the quit door awaits them ALL.
        let pendingEditor = session?.editorRouter.active?.finalizeWork()
        let registry = session?.quitFinalize
        if pendingEditor == nil, registry?.isEmpty != false {
            return .terminateNow
        }
        Task { @MainActor in
            if let pendingEditor { await pendingEditor.value }
            if let registry { await registry.finalizeAll() }
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }
}
