//
//  EditorRouterActiveTests.swift
//  VariorumTests
//
//  **13u2 UNIT B — KnownIssues row 49's fix, pinned at its mechanism.**
//
//  The defect, measured on the dev build (the UNIT B RECORD has the trace and
//  the numbers): focusing a LONG note in the book's Outline makes SwiftUI
//  realize the row's `InlineEditorSurface` TWICE, ~40 ms apart, each with its
//  own `EditorViewModel`, and it never calls `dismantleNSView` on the first.
//  The second view is an ORPHAN — its `window` is nil at +0.05 s, +0.5 s and
//  +2 s after its mount, and its `index.entries` stays empty forever, while
//  the real editor reads `window != nil` and 262 entries. Because
//  `EditorRouter.active` meant "the last text view to ATTACH", the orphan held
//  it for as long as the note stayed focused, and the quit and lock doors
//  asked IT to `finalizeWork()` — a shadow has no pending text, so the door
//  believed there was nothing to await and the note's OPEN TAIL could go
//  uncrystallized.
//
//  The fix claims `active` again when a text view reaches a WINDOW, which is
//  the exact discriminator the measurement found. These pins hold that in the
//  app's own order — real attaches, shadow attaches, real reaches the screen —
//  through AppKit's real `viewDidMoveToWindow`, never a stub.
//
//  **Red on old:** on the pre-fix tree the second arm reads
//  `active === shadow` after the real view is installed in a window, because
//  nothing could take `active` back. Measured before the fix landed.
//
//  Why a MECHANISM pin rather than a hosted book: a hosted `BookView` mount
//  does not reliably grow the Outline's second surface (the same reason
//  `NoteBoxCompositionTests.theCaretDoorsActOnTheEditorSheIsWritingInNotTheLastToAttach`
//  reproduces the shadow by hand) — it is a live-app timing. A pin that waited
//  for SwiftUI to produce it would be green on both sides and prove nothing.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("EditorRouter.active names the editor on screen (13u2 UNIT B — KnownIssues row 49)")
struct EditorRouterActiveTests {
    /// One in-memory world with a single note holding one block.
    private func withNote<T>(
        _ body: @MainActor (AppSession, _ postID: String) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 49))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the shadow's note")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "A paragraph with enough words in it to lay out like real prose.")
            return try await body(session, post.id)
        }
    }

    /// A window whose content view is a plain container, so a text view can be
    /// put ON SCREEN for real — `viewDidMoveToWindow` is AppKit's, and the fix
    /// rides it.
    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: 600, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        return window
    }

    /// **THE SHIPPED MEANING, restated so the fix cannot be mistaken for a
    /// relaxation:** a text view that attaches still takes `active` at once —
    /// every harness that attaches a bare view, and the shadow pin in
    /// `NoteBoxCompositionTests`, depend on exactly that and ride unmodified.
    @Test func attachingStillTakesActiveAtOnce() async throws {
        try await withNote { session, postID in
            let model = EditorViewModel(session: session, postID: postID)
            model.attach(textView: EditorTextView.makeInlineEditor(), scrollView: nil)
            #expect(session.editorRouter.active === model)
        }
    }

    /// **THE FIX.** The app's own order: the real editor attaches (its view is
    /// not in a window yet — SwiftUI installs it after `makeNSView` returns),
    /// the SHADOW attaches and takes `active` exactly as it does live, and
    /// then the real view reaches the screen — which is the moment the real
    /// editor is the answer to "which editor is on screen", and the moment it
    /// takes `active` back.
    ///
    /// RED ON OLD: without the window-entry claim the last line reads
    /// `active === shadow`.
    @Test func theViewThatReachesTheScreenTakesActiveBackFromAShadow() async throws {
        try await withNote { session, postID in
            let window = makeWindow()
            defer {
                window.orderOut(nil)
                window.close()
            }

            // 1. The real editor attaches, its view not yet in a window.
            let real = EditorViewModel(session: session, postID: postID)
            let realView = EditorTextView.makeInlineEditor()
            real.attach(textView: realView, scrollView: nil)
            #expect(realView.window == nil, "SwiftUI installs the view after makeNSView")

            // 2. The shadow attaches — the second realization the trace found.
            let shadow = EditorViewModel(session: session, postID: postID)
            let shadowView = EditorTextView.makeInlineEditor()
            shadow.attach(textView: shadowView, scrollView: nil)
            #expect(session.editorRouter.active === shadow,
                    "the last to attach still takes it — the shipped meaning")

            // 3. The real view reaches the screen.
            window.contentView?.addSubview(realView)
            window.makeKeyAndOrderFront(nil)
            #expect(realView.window != nil, "the real view is on screen")

            #expect(session.editorRouter.active === real,
                    "the editor SHE IS LOOKING AT holds `active` — red on old")
        }
    }

    /// **AND THE ORPHAN CAN NEVER TAKE IT BACK.** The shadow's view is never
    /// installed in a window (measured: nil at +0.05 s, +0.5 s and +2 s), so
    /// once the real view has claimed, nothing the shadow does moves the
    /// router — including the layout traffic that keeps running against an
    /// orphan SwiftUI never dismantled.
    @Test func anOrphanViewNeverClaimsActive() async throws {
        try await withNote { session, postID in
            let window = makeWindow()
            defer {
                window.orderOut(nil)
                window.close()
            }
            let real = EditorViewModel(session: session, postID: postID)
            let realView = EditorTextView.makeInlineEditor()
            real.attach(textView: realView, scrollView: nil)
            window.contentView?.addSubview(realView)
            window.makeKeyAndOrderFront(nil)
            #expect(session.editorRouter.active === real)

            let shadow = EditorViewModel(session: session, postID: postID)
            let shadowView = EditorTextView.makeInlineEditor()
            shadow.attach(textView: shadowView, scrollView: nil)
            // The orphan gets a superview but never a window — exactly what the
            // dev-build probe measured for the second realization.
            let orphanHost = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
            orphanHost.addSubview(shadowView)
            #expect(shadowView.window == nil, "the orphan is off-screen, as it is live")

            // The attach itself still claims (the shipped meaning), and the
            // real view's next screen event takes it straight back.
            #expect(session.editorRouter.active === shadow)
            realView.removeFromSuperview()
            window.contentView?.addSubview(realView)
            #expect(session.editorRouter.active === real,
                    "the on-screen editor wins every time")
        }
    }

    /// **TEARDOWN STILL LETS GO, and a released model cannot re-take it.** The
    /// window-entry claim is armed at `attach` and disarmed at `teardown`, so
    /// a view re-parented on its way out never resurrects a model that has
    /// already said goodbye.
    @Test func aTornDownModelDoesNotReclaimActiveOnAWindowChange() async throws {
        try await withNote { session, postID in
            let window = makeWindow()
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = EditorViewModel(session: session, postID: postID)
            let view = EditorTextView.makeInlineEditor()
            model.attach(textView: view, scrollView: nil)
            window.contentView?.addSubview(view)
            window.makeKeyAndOrderFront(nil)
            #expect(session.editorRouter.active === model)

            _ = model.teardown()
            #expect(session.editorRouter.active == nil, "teardown is the one door that clears it")

            view.removeFromSuperview()
            window.contentView?.addSubview(view)
            #expect(session.editorRouter.active == nil,
                    "a released model does not come back through a window change")
        }
    }
}
