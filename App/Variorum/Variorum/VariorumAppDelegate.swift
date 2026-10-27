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

    /// 13r U2: **the app's ONE update channel** (Sparkle, the XPC installer
    /// road). The same reason as `appearance`: one per app, and it exists
    /// before the first window. Inert in every DEBUG build: R-13r-7's fence
    /// is applied inside `forThisBuild()`, and nowhere else.
    let updates = UpdateChannel.forThisBuild()

    /// 13r U3-A: **What's New's ledger** — one per app, decided once at
    /// launch (a fresh install records its version silently; a CHANGED
    /// version shows the notes once). The first window claims the show.
    let whatsNew = WhatsNewLedger.forThisApp()

    /// 13r U3-A: **THE CALM-ASKS CADENCE's one scheduler** — the day-of-use
    /// counter and the shared rules (`CalmAsks.swift`). The update ask
    /// registers here (the channel is the delegate's); the backup-folder ask
    /// registers from the window that holds the store's services.
    let calmAsks = CalmAskScheduler.live()

    /// 13s-b U1a (R-13s-2/6/13): **the first-open tour offer's one model** —
    /// one per app for the `whatsNew` reason (decided once at launch from the
    /// device's local record); every window's Bookcase draws its line.
    let tourOffer = TourOfferModel.forThisApp()

    /// 13r U3-B — R-13r-5: **the app's ONE crash-reporting owner** (MetricKit,
    /// opt-in, default OFF). Here for the `appearance` reason: one per app,
    /// alive before the first window — and a subscriber registered at launch
    /// (only when she already said yes) is how MetricKit's pending reports
    /// arrive. Nothing it receives is ever sent automatically.
    let crashReports = CrashReporting.forThisApp()

    /// 13n-b U1 — A-8: **the app's ONE MCP door owner** (the local MCP server
    /// and the grants pane's state). One per app for the `crashReports`
    /// reason; attached to the open store at ready, detached at lock and at
    /// quit (below) — so the socket dies with the app. Never serves inside a
    /// test process.
    let mcp = MCPDoor()

    /// 13n-c UX walk W-UX-6 — ⌘L with ONE wing speaks its note
    /// (`OneWingChord`): the app-wide monitor, installed once at launch.
    private var oneWingChord: Any?

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
        // 13r U2: Sparkle's cycle starts once launching is done. On the
        // inert (Debug) channel this does nothing.
        updates.start()
        // 13r U3-A — R-13r-11: THE UPDATE ASK joins the cadence, ONLY where a
        // live updater can act (P-2 — never in a Debug build): from the 3rd
        // day of use, at a calm moment, Sparkle's own permission window. It
        // ranks first; while it is open it takes its day.
        if updates.isLive {
            calmAsks.register(.init(
                id: CalmAskScheduler.AskID.update, rank: 0,
                fromDay: calmAsks.numbers.updateAskFromDay,
                maxShows: .max, returnsAfterDays: 1, host: nil,
                wantsAsking: { [updates] in updates.wantsPermissionAsked },
                present: { [updates] in updates.askPermission() }))
        }
        calmAsks.start()
        oneWingChord = OneWingChord.install { [weak self] in self?.session }
        #if DEBUG
        // 18l U-VIS: the visual harness's oracle endpoint — registers nothing
        // unless the harness launched this process (`VARIORUM_VISUAL_WALK=1`).
        VisualWalkProbe.installIfRequested { [weak self] in self?.session }
        // 13r U3-B: the walk's synthetic crash report — a no-op unless the
        // walk launched this process with `VARIORUM_SYNTHETIC_CRASH_REPORT`,
        // and then delivered ONLY if crash reporting is ON (the real
        // subscriber's own delivery; an OFF app has nothing to deliver into).
        SyntheticCrashReport.injectIfRequested(into: crashReports)
        #endif
    }

    /// 13n-b U1 (A-8): the server stops with the app — the socket is
    /// unlinked and every connection hung up before the process exits.
    /// VX-394 (VX-548 batch 2b): with no end line said — P-VX394-5, "a QUIT
    /// logs nothing" (`MCPDoor.quit`; `detach()` here raced the exit with one).
    func applicationWillTerminate(_ notification: Notification) {
        mcp.quit()
        // VX-308 U3 — VX-448 (her ruling): the twelve words a new-road look copied leave the clipboard at quit (only while
        // the board still holds that copy) — a no-op when no look copied them.
        WordsClipboard.clearHeld()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        sanitizeWindowFrames()
        // 13r U3-A: a day of use is a day the app was opened OR brought
        // forward — an app left open across midnight counts the new day here.
        calmAsks.noteActive()
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
    /// Internal, not private, for the reason the house style gives
    /// elsewhere: the branch that decides whether ⌘Q is honoured should be
    /// checkable. Driving `applicationShouldTerminate` itself would mean
    /// calling `reply(toApplicationShouldTerminate:)` on the real `NSApp`
    /// inside a test host, which is exactly the thing a pin must not do.
    func declineQuitIfACaptureStands() -> Bool {
        guard let session, session.quickNotePark.declineQuitOnce() else { return false }
        if !session.quickNotePark.isPadShowing {
            session.status.refuse(QuickNoteCopy.parkedOnClose)
        }
        return true
    }
}
