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

    /// 18j (her R-Q12): **the app's ONE appearance owner** — follow system ·
    /// light · dark, applied as `NSApp.appearance` so every window, sheet,
    /// menu and the Settings scene inherit it (see `AppearanceChoice.swift`
    /// for why this and not five `preferredColorScheme` modifiers). It lives
    /// here for the same reason `WindowRegistry` and `GlobalHotKeyCenter`
    /// live on the App: there is one of it, however many windows exist —
    /// and the delegate is the app-level object that exists BEFORE the first
    /// window, which is what makes the launch application deterministic.
    let appearance = AppearanceController()

    // MARK: - Window sanitation (Sitting 9 batch 8 — the wedged window)
    //
    // Her main window came up TALLER THAN THE SCREEN and macOS's
    // constrainment kept pinning it to the top: moves snapped back, the
    // bottom edge (and its resize corners) sat unreachable below the
    // screen, and every bottom bar looked "missing." Root cause: a
    // persisted oversized frame the restoration kept re-imposing. The
    // sanitizer makes that state unsurvivable — at launch and on every
    // activation, any non-fullscreen window larger than its screen's
    // visible frame is clamped back inside it.

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 18j: before anything is drawn, so a chosen dark app never flashes
        // the system's light appearance on its way up. Idempotent — the
        // controller's own init applies it too, and neither order matters.
        appearance.apply()
        sanitizeWindowFrames()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        sanitizeWindowFrames()
    }

    private func sanitizeWindowFrames() {
        for window in NSApp.windows where window.isVisible {
            guard !window.styleMask.contains(.fullScreen),
                  let screen = window.screen ?? NSScreen.main
            else { continue }
            let visible = screen.visibleFrame
            var frame = window.frame
            guard frame.height > visible.height + 1 || frame.width > visible.width + 1
                || frame.minY < visible.minY - 1
            else { continue }
            frame.size.height = min(frame.height, visible.height)
            frame.size.width = min(frame.width, visible.width)
            frame.origin.y = max(visible.minY, min(frame.origin.y, visible.maxY - frame.height))
            frame.origin.x = max(visible.minX, min(frame.origin.x, visible.maxX - frame.width))
            window.setFrame(frame, display: true, animate: false)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // 17o batch b's ladder, R1-4: the caret place the session dict
        // holds is written NOW — synchronously, ahead of both branches —
        // because no view disappears when the process exits, so the
        // router's own leaving door (`unregisterDetail`) never runs at ⌘Q.
        session?.commandRouter.persistCurrentBlocks()
        // Phase 11 (review round 1, MINOR 2): the focused editor is no
        // longer the only surface holding a debounced buffer — the takes
        // board's panes and the TOC's expanded block register their
        // flushes with the session; the quit door awaits them ALL.
        let pendingEditor = session?.editorRouter.active?.finalizeWork()
        let registry = session?.quitFinalize
        if pendingEditor == nil, registry?.isEmpty != false {
            // 17b row 65's rider: a refusal can stand with the pad CLOSED
            // (its quit closure went with the window), so this road consults
            // the park too — otherwise the one case the park exists for
            // would quit straight past it.
            return declineQuitIfACaptureStands() ? .terminateCancel : .terminateNow
        }
        Task { @MainActor in
            if let pendingEditor { await pendingEditor.value }
            // The pad's own quit closure runs in here, and a refusal inside
            // it is what ARMS the park — so the decision below must come
            // after `finalizeAll`, never before it.
            if let registry { await registry.finalizeAll() }
            sender.reply(
                toApplicationShouldTerminate: !self.declineQuitIfACaptureStands())
        }
        return .terminateLater
    }

    /// **17b row 65's 1b RIDER — the one-shot quit decline** (the
    /// orchestrator's ruling, binding 4; PROVISIONAL, QUESTIONS #137).
    ///
    /// The park is memory-only by design, so a quit is the one road that
    /// can still take a refused capture — and macOS already has a grammar
    /// for "you have unsaved work": decline the termination once and leave
    /// it on screen. **Bounded so she can never be trapped by a store that
    /// will not take it: a second consecutive ⌘Q always proceeds**, and a
    /// refusal that is resolved and later arises again re-arms its own
    /// single decline (`QuickNotePark.park` clears the spent flag).
    ///
    /// When the pad is on screen it is already speaking its refusal line
    /// (its `finalizeAtQuit` just ran), so nothing is said twice; when it is
    /// not, the status seam carries the same sentence the close road speaks,
    /// because a quit that quietly refuses to quit is its own defect.
    private func declineQuitIfACaptureStands() -> Bool {
        guard let session, session.quickNotePark.declineQuitOnce() else { return false }
        if !session.quickNotePark.isPadShowing {
            session.status.refuse(QuickNoteCopy.parkedOnClose)
        }
        return true
    }
}
