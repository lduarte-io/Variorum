//
//  EditorUndoLifecycleTests.swift
//  VariorumTests
//
//  VX-656 (the VX-677 run, batch 1 — the record `notes/plans/fixes/
//  vx-677-editor-panes-ai-door.md`, BATCH 1 RECORD): Write's FULL-DOCUMENT
//  editor carried VX-421's undo class. `EditorTextView` is built
//  `allowsUndo = true` (`makeEditor`, `makeInlineEditor`) and its delegate,
//  `EditorSurfaceDelegate`, answered no `undoManager(for:)` — so every
//  keystroke registered its undo on the WINDOW's manager, aimed at the editor
//  view. A mode switch dismantles the editor (`EditorSurface.dismantleNSView`
//  → the coordinator's `uninstall`, and `EditorView`'s `.onDisappear` →
//  `EditorViewModel.teardown()`), neither of which touched undo; `NSUndoManager`
//  retains no targets, so the next ⌘Z with no text input focused popped an
//  action into the freed editor — the exact mechanism VX-421 fixed for panes
//  (`PaneUndoLifecycleTests` is this file's shape).
//
//  The rule these pins hold (R-601-1's, carried to the other surface kind):
//  the editor's typing history is ITS OWN — answered by its delegate, never
//  the window's — and it goes with the editor.
//
//  RED ON OLD: marked per pin. Every red pin STOPS at a `#require` before the
//  ⌘Z that would replay into a torn-down editor, so the old tree reports red
//  without ever running a stale replay through a torn-down model (the DEBUG
//  identity oracle kills the process on corruption — a crash would end the
//  whole run, not just the pin). The guards are green on both sides.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The voice `withEditor` pins process-wide (Terminal — its calibrated
/// world), so the mounted surface's chrome agrees with the harness's own
/// typography rather than adopting the store-less default.
@MainActor fileprivate var terminal: EditorSurfaceChrome {
    EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: false)
}

/// Whether the host renders the editor at all — a mode switch away from Write
/// is, for the editor, exactly "no longer rendered". File-scope: the
/// `@Observable` macro cannot expand on a `private` nested type.
@MainActor @Observable
fileprivate final class EditorMount {
    var shown = true
}

/// The detail editor as `EditorView` mounts it: the REAL representable (its
/// `makeNSView` wires the real delegate and attaches the model; its
/// `dismantleNSView` runs the real coordinator's `uninstall`) plus
/// `EditorView`'s own `.onDisappear { model.teardown() }`.
fileprivate struct DetailEditorHost: View {
    let mount: EditorMount
    let model: EditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            if mount.shown {
                EditorSurface(model: model, chrome: terminal)
                    .frame(width: 520, height: 360)
                    .onDisappear { model.teardown() }
            }
        }
        .frame(width: 520, height: 360)
    }
}

/// The book view's INLINE editor (`makeInlineEditor` — the ticket's second
/// line), mounted the way its hosts mount it.
fileprivate struct InlineEditorHost: View {
    let mount: EditorMount
    let model: EditorViewModel
    @State private var height: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            if mount.shown {
                InlineEditorSurface(model: model, height: $height, chrome: terminal)
                    .frame(width: 520, height: max(height, 60))
                    .onDisappear { model.teardown() }
            }
        }
        .frame(width: 520, height: 360)
    }
}

/// An OFFSCREEN window that is never ordered in (`PaneLifecycleTests`' rig):
/// a window owns the keyboard and the undo road; nothing needs to be seen.
@MainActor
fileprivate struct EditorUndoRig<Host: View> {
    let window: NSWindow
    let hosting: NSHostingView<Host>

    init(_ host: Host) {
        hosting = NSHostingView(rootView: host)
        hosting.frame = NSRect(x: 0, y: 0, width: 520, height: 360)
        window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 520, height: 360),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 520, height: 360))
        content.addSubview(hosting)
        window.contentView = content
    }

    func close() {
        window.contentView = nil
        window.close()
    }

    /// Let SwiftUI apply what the rig changed — never pumping into the host
    /// app's own launch (`HostLaunchSettle`, the VX-601 rev-tree lesson).
    func settle() async {
        await HostLaunchSettle.wait()
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
        }
    }

    private static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// The mounted editor, nil once it is torn down.
    var editor: EditorTextView? { Self.find(in: hosting) }

    private static func find(in view: NSView) -> EditorTextView? {
        if let editor = view as? EditorTextView { return editor }
        for sub in view.subviews {
            if let found = find(in: sub) { return found }
        }
        return nil
    }

    /// Her keystrokes through the real edit door (the NSTextInputClient road
    /// typing and paste share), at `location` — inside the block's own text.
    func type(_ text: String, at location: Int, into editor: EditorTextView) {
        window.makeFirstResponder(editor)
        editor.setSelectedRange(NSRange(location: location, length: 0))
        editor.insertText(text, replacementRange: editor.selectedRange())
    }

    /// ⌘Z's own road: `undo:` up the responder chain to the window, which
    /// undoes through the FIRST RESPONDER's manager (measured at VX-179 U3-g).
    func commandZ() {
        let responder = window.firstResponder ?? window
        _ = responder.tryToPerform(Selector(("undo:")), with: nil)
    }
}

@MainActor
@Suite("VX-656 — Write's editor owns its undo history, and it goes with the editor", .serialized)
struct EditorUndoLifecycleTests {
    private static let block = "Write's own words, before her keystrokes."
    private static let typed = " And then she typed."

    /// A FRESH model over the harness's note, its header and projection
    /// parked BEFORE the mount — `applyProjection` parks while no text view
    /// is attached, and the representable's `attach` renders it. (The
    /// harness's own model is attached to the harness's own windowless view;
    /// re-attaching it to a fresh, empty view would leave its index naming
    /// text that view never got.)
    private static func mountableModel(_ h: EditorHarness) throws -> EditorViewModel {
        let model = EditorViewModel(session: h.session, postID: h.postID)
        model.tailIdleSleep = { _ in throw CancellationError() }
        model.longBlockLayout.sleep = { _ in throw CancellationError() }
        let (slots, header) = try h.database.read { db in
            (try Queries.renderPost(db, containerID: h.postID),
             try Queries.containerHeader(db, containerID: h.postID))
        }
        model.adoptHeader(header)
        model.applyProjection(slots)
        return model
    }

    /// Inside the block's text (never at its end, where a keystroke could
    /// meet the tail rule).
    private static var typingPlace: Int { (block as NSString).length - 1 }

    /// **RED ON OLD — the registration half.** While Write's editor lives, its
    /// typing goes onto ITS OWN history — never the window's. On the old tree
    /// the delegate answered nothing, so `NSTextView` fell back to the
    /// window's manager: the editor's manager WAS the window's, and the
    /// window's manager carried her keystrokes.
    @Test func writesTypingIsItsOwnNeverTheWindows() async throws {
        try await withEditor(seedBlocks: [Self.block]) { h in
            let mount = EditorMount()
            let model = try Self.mountableModel(h)
            let rig = EditorUndoRig(DetailEditorHost(mount: mount, model: model))
            defer { rig.close() }
            await rig.settle()
            let editor = try #require(rig.editor, "the editor mounted")
            #expect(editor.string == Self.block, "non-vacuity: the parked projection rendered")
            rig.type(Self.typed, at: Self.typingPlace, into: editor)
            await rig.settle()
            #expect(editor.undoManager?.canUndo == true,
                    "non-vacuity: her typing is undoable while the editor lives")
            #expect(editor.undoManager !== rig.window.undoManager,
                    "RED ON OLD: the editor's undo manager IS the window's")
            #expect(rig.window.undoManager?.canUndo != true,
                    "RED ON OLD: her keystrokes are on the window's undo manager")
        }
    }

    /// **RED ON OLD — the crash's precondition.** She types in Write; a mode
    /// switch tears the editor down; ⌘Z arrives with no text input holding
    /// the keyboard. On the old tree the window's manager still names the
    /// torn-down editor's typing — the next ⌘Z messages a view `NSUndoManager`
    /// never retained (`EXC_BAD_ACCESS` in `popAndInvoke` once it is freed).
    /// This pin STOPS at the `#require` on the old tree rather than run that
    /// line; on the fixed tree ⌘Z is a clean no-op.
    @Test func undoAfterATornDownEditorIsReleasedIsACleanNoOp() async throws {
        try await withEditor(seedBlocks: [Self.block]) { h in
            let mount = EditorMount()
            let model = try Self.mountableModel(h)
            let rig = EditorUndoRig(DetailEditorHost(mount: mount, model: model))
            defer { rig.close() }
            await rig.settle()
            weak var released: EditorTextView?
            do {
                let editor = try #require(rig.editor, "the editor mounted")
                released = editor
                rig.type(Self.typed, at: Self.typingPlace, into: editor)
            }
            await rig.settle()
            #expect(released?.undoManager?.canUndo == true, "non-vacuity: her typing is undoable")

            mount.shown = false  // the mode switch: Write is no longer rendered
            await rig.settle()
            #expect(rig.editor == nil, "non-vacuity: the editor was torn down")
            #expect(rig.window.firstResponder !== released, "AppKit dropped the removed responder")
            try #require(rig.window.undoManager?.canUndo != true,
                         "RED ON OLD: the window's manager still names the torn-down editor — the next ⌘Z messages it")
            rig.commandZ()  // the line that would crash: on the fixed tree, nothing to replay
            await rig.settle()
            #expect(rig.window.undoManager?.canUndo != true)
            await h.flush()
            let stored = try h.storeSlots().first?.text
            #expect(stored?.contains(Self.typed) == true,
                    "her typing stands in the store after the stray ⌘Z")
        }
    }

    /// **RED ON OLD — the INLINE editor (the book view's), the ticket's second
    /// line** (`makeInlineEditor`'s `allowsUndo`). The same delegate serves it,
    /// so the same two facts hold: its typing is its own while it lives, and
    /// nothing of it is left on the window's manager once it is torn down.
    @Test func theInlineEditorsTypingIsItsOwnAndGoesWithIt() async throws {
        try await withEditor(seedBlocks: [Self.block]) { h in
            let mount = EditorMount()
            let model = try Self.mountableModel(h)
            let rig = EditorUndoRig(InlineEditorHost(mount: mount, model: model))
            defer { rig.close() }
            await rig.settle()
            let editor = try #require(rig.editor, "the inline editor mounted")
            #expect(editor.string == Self.block, "non-vacuity: the parked projection rendered")
            rig.type(Self.typed, at: Self.typingPlace, into: editor)
            await rig.settle()
            #expect(editor.undoManager?.canUndo == true, "non-vacuity: her typing is undoable")
            #expect(editor.undoManager !== rig.window.undoManager,
                    "RED ON OLD: the inline editor's undo manager IS the window's")

            mount.shown = false
            await rig.settle()
            #expect(rig.editor == nil, "non-vacuity: the inline editor was torn down")
            try #require(rig.window.undoManager?.canUndo != true,
                         "RED ON OLD: the window's manager still names the torn-down inline editor")
            rig.commandZ()
            await rig.settle()
            #expect(editor.string.contains(Self.typed),
                    "a stray ⌘Z reached nothing of the torn-down editor's")
        }
    }

    /// GUARD (green on both sides) — **⌘Z in a living Write editor still
    /// undoes her typing** by AppKit's own road (`undo:` → the window → the
    /// first responder's manager, now answered by the editor's delegate), and
    /// a structural rewrite's history end still reaches it: the existing
    /// `textView.undoManager?.removeAllActions()` sites read the SAME manager
    /// the typing registered on.
    @Test func commandZInALivingEditorStillUndoesHerTyping() async throws {
        try await withEditor(seedBlocks: [Self.block]) { h in
            let mount = EditorMount()
            let model = try Self.mountableModel(h)
            let rig = EditorUndoRig(DetailEditorHost(mount: mount, model: model))
            defer { rig.close() }
            await rig.settle()
            let editor = try #require(rig.editor, "the editor mounted")
            rig.type(Self.typed, at: Self.typingPlace, into: editor)
            await rig.settle()
            let typedText = editor.string
            #expect(typedText.contains(Self.typed), "non-vacuity: she typed")

            rig.commandZ()
            await rig.settle()
            #expect(editor.string == Self.block, "⌘Z undid her typing in Write")
            #expect(editor.undoManager?.canRedo == true, "…and the redo half stands")

            model.clearTextUndo()  // the structural rewrites' own history end
            #expect(editor.undoManager?.canUndo != true && editor.undoManager?.canRedo != true,
                    "the history end reaches the manager her typing registered on")
        }
    }
}
