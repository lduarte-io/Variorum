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
        guard let active = session?.editorRouter.active,
              let pending = active.finalizeWork()
        else { return .terminateNow }
        Task { @MainActor in
            await pending.value
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }
}
