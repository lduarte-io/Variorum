//
//  VX347CommitLeavesMountTests.swift
//  VariorumTests
//
//  VX-347 — **⌘S always commits; only ⎋ doesn't** (her ruling, superseding
//  QUESTIONS #121(b); the record is `notes/plans/fixes/vx-348-prelaunch-
//  sweep.md`'s U2 UNIT RECORD). Her words: *"command S should always commit
//  your take even without an extra keystroke to enter (but if you click
//  escape, then that can deliberately not save. the keyboard shortcut is
//  lying right now since it's really command S enter)."*
//
//  Every cell here drives the PRODUCT's presenter — Write's own bar
//  (`CommitBar`, whose `savepointNameAsk` is the one modifier every commit
//  door composes) — over the real `EditorViewModel` and the real store, and
//  leaves the field by a real road: the popover's own close (where a click
//  away and a closing window end), a posted ⎋ / ⏎ / typed name, the host
//  leaving its window, ⌘S again. **These cells use only APIs the pre-fix
//  tree has**, so each is red on old by BEHAVIOUR, never by compile (the
//  ones marked GUARD are green on both sides by design).
//
//  Hosting (VX-179's measured machinery, `CommentTextAreaTests` /
//  `CommentPanelHostLifecycleTests`): the bar's window is ordered in
//  OFF-DISPLAY at alpha 0 (a popover needs a visible anchor) and the
//  popover's own window is set alpha 0 the turn it appears; keys are posted
//  only through `deliveryWindow(for:)`, never to the test host's own window;
//  every wait is a drained turn.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rig

/// Catches every popover that shows while it listens, so ONE cell can close
/// the field's popover by its own `performClose` (the road AppKit's transient
/// dismissal ends on — `willClose`, then the binding).
///
/// **FIX LEG (the batch's harness finding):** the first rig listened for
/// `didShowNotification` only, which AppKit posts when the show ANIMATION
/// ends — the cells looked the popover up the moment its window appeared, so
/// `fieldPopover()` answered nil on both trees and the cells never tested the
/// behaviour. `willShowNotification` is posted synchronously inside the show
/// itself, before the window exists; both are heard, and the lookup waits.
@MainActor
final class SavepointPopoverCatcher {
    private(set) var shown: [NSPopover] = []
    private var tokens: [NSObjectProtocol] = []

    init() {
        for name in [NSPopover.willShowNotification, NSPopover.didShowNotification] {
            tokens.append(NotificationCenter.default.addObserver(
                forName: name, object: nil, queue: .main
            ) { [weak self] note in
                // Read before the hop: the notification itself is not Sendable.
                let popover = note.object as? NSPopover
                MainActor.assumeIsolated {
                    guard let self, let popover, !self.shown.contains(where: { $0 === popover })
                    else { return }
                    self.shown.append(popover)
                }
            })
        }
    }

    func stop() {
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        tokens = []
        shown = []
    }
}

@MainActor
enum SavepointFieldRig {
    /// One DRAINED turn (VX-282 U5c's shape): the queued app events
    /// dispatched and the run loop given a slice inside its own pool.
    static func turns(_ count: Int = 20) async {
        for _ in 0..<count {
            drainedSlice()
            await Task.yield()
        }
    }

    private static func drainedSlice() {
        autoreleasepool {
            while let event = NSApp.nextEvent(
                matching: [.keyDown, .leftMouseDown, .leftMouseUp], until: nil,
                inMode: .default, dequeue: true)
            {
                NSApp.sendEvent(event)
            }
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
    }

    @discardableResult
    static func turns(until predicate: () -> Bool, max: Int) async -> Bool {
        for _ in 0..<max {
            if autoreleasepool(invoking: predicate) { return true }
            await turns(1)
        }
        return autoreleasepool(invoking: predicate)
    }

    /// Write's bar, mounted the product's way in an off-display window.
    @MainActor
    struct Mounted {
        let window: NSWindow
        let hosting: NSHostingView<AnyView>
        let catcher: SavepointPopoverCatcher
        let before: Set<ObjectIdentifier>

        /// The field's popover window, once it is up: a popover's window hangs
        /// from the window it was shown from, so the child of THIS bar's window
        /// (never another suite's window — suites run beside each other);
        /// failing that, a window new since the mount.
        func popoverWindow() -> NSWindow? {
            let fresh = NSApp.windows.filter {
                !before.contains(ObjectIdentifier($0)) && $0 !== window && $0.isVisible
            }
            return fresh.first { $0.parent === window } ?? fresh.first
        }

        /// The popover showing the field — the one whose content is in the
        /// field's window.
        func fieldPopover() -> NSPopover? {
            guard let field = popoverWindow() else { return nil }
            return catcher.shown.last { $0.contentViewController?.view.window === field }
        }

        func tearDown() {
            catcher.stop()
            hosting.rootView = AnyView(Color.clear)
            window.orderOut(nil)
            window.contentView = nil
        }
    }

    static func mountWritesBar(_ model: EditorViewModel) async -> Mounted {
        let window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 1100, height: 220),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.alphaValue = 0
        let before = Set(NSApp.windows.map(ObjectIdentifier.init))
        let hosting = NSHostingView(rootView: AnyView(
            CommitBar(model: model)
                .environment(ThemeStore(session: model.session))))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 220)
        window.contentView = hosting
        window.orderFrontRegardless()  // off every display
        let catcher = SavepointPopoverCatcher()
        await turns()
        return Mounted(window: window, hosting: hosting, catcher: catcher, before: before)
    }

    /// ⌘S at the caret, through the door — and the field's popover up.
    static func pressCommandS(
        _ model: EditorViewModel, _ mounted: Mounted
    ) async throws -> NSWindow {
        model.commitCaretVariant()
        let up = await turns(until: {
            model.savepointAsk != nil && mounted.popoverWindow() != nil
        }, max: 120)
        try #require(up, "premise: ⌘S put the name field up")
        let popover = try #require(mounted.popoverWindow())
        popover.alphaValue = 0
        return popover
    }

    /// **A CLICK AWAY, AS IT ENDS** (FIX LEG — the deterministic road). A
    /// transient dismissal closes the popover and SwiftUI then writes nil
    /// through the host's binding (`set: { model.savepointAsk = $0 }`) — the
    /// road VX-179's `closingThePopoverSavesADirtyInPlaceEdit` dismisses by
    /// ("the road a click-away and the panel's own close both end on"). The
    /// binding going nil closes the popover too, so BOTH of the presenter's
    /// dismissal reports run — the host's change and the popover's own
    /// `willClose` — and the cell holds that they file ONE commit.
    static func dismissTheField(_ model: EditorViewModel) async {
        model.savepointAsk = nil  // SwiftUI's own write at the dismissal's end
        await turns(40)
    }

    /// The field's popover closing by its OWN `performClose` — the watcher's
    /// road (`willClose`). Looked up after it is caught, never assumed.
    static func closeThePopoverItself(_ mounted: Mounted) async throws {
        await turns(until: { mounted.fieldPopover() != nil }, max: 100)
        let popover = try #require(mounted.fieldPopover(), "premise: the field's popover was caught showing")
        popover.performClose(nil)
        await turns(40)
    }

    /// The field takes the keyboard (the product's `.task { focused = true }`
    /// asks for it; offscreen the cell makes sure).
    static func focusTheField(in popover: NSWindow) async throws {
        let field = try #require(textField(in: popover.contentView), "premise: the field is in the popover")
        if !(popover.firstResponder is NSText) {
            popover.makeFirstResponder(field)
            await turns()
        }
    }

    static func textField(in view: NSView?) -> NSTextField? {
        guard let view else { return nil }
        if let field = view as? NSTextField, field.isEditable { return field }
        for child in view.subviews {
            if let found = textField(in: child) { return found }
        }
        return nil
    }

    /// **The ONE key road** (VX-179 U3 PIN LEG's): a key is posted only
    /// where AppKit delivers it INTO the popover — the key window when that
    /// is the popover's own or its parent, the popover's window when nothing
    /// is key. Any other key window is the TEST HOST's own, so the cell stops
    /// there by name and never types into it.
    static func deliveryWindow(for popover: NSWindow) throws -> NSWindow {
        guard let key = NSApp.keyWindow else { return popover }
        try #require(
            key === popover || key === popover.parent,
            "premise: the key window is the popover's or its parent's — never the host app's own")
        return key
    }

    static func key(_ characters: String, keyCode: UInt16, to window: NSWindow) async {
        NSApp.postEvent(NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
            context: nil, characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode)!, atStart: false)
        await turns(4)
    }

    static func type(_ text: String, to window: NSWindow) async {
        for character in text {
            await key(String(character), keyCode: 0, to: window)
        }
    }

    static func savepoints(_ h: EditorHarness, slot index: Int = 0) throws -> [CommitPoint] {
        let variantID = try #require(try h.storeSlots()[index].variantID)
        return try h.database.read { try Queries.commitHistory($0, variantID: variantID) }
    }

    /// Waits for the filing's own `Task` (flush, then the op) to land.
    @discardableResult
    static func awaitSavepoints(
        _ h: EditorHarness, slot index: Int = 0, count: Int, max: Int = 200
    ) async -> Bool {
        await turns(until: { ((try? savepoints(h, slot: index))?.count ?? -1) >= count }, max: max)
    }
}

// MARK: - The leave-ways, one cell each

@MainActor
@Suite("VX-347 — ⌘S always commits; only ⎋ doesn't (the product's presenter)", .serialized)
struct VX347CommitLeavesMountTests {
    private typealias Rig = SavepointFieldRig

    private func caretInFirstBlock(_ h: EditorHarness) {
        h.textView.setSelectedRange(NSRange(location: 3, length: 0))
        h.model.updateCaretContext()
    }

    /// **A CLICK AWAY FILES IT, UNNAMED — RED ON OLD.** The pre-fix
    /// presenter cancelled on every dismissal ("one road, so a dismissal can
    /// never half-commit"), so ⌘S was really ⌘S ⏎. Left the way a click away
    /// ends (`dismissTheField` — both of the presenter's dismissal reports
    /// run, and they file ONE commit).
    @Test func aClickAwayFilesTheCommitUnnamed() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)
            #expect(try Rig.savepoints(h).isEmpty, "premise: the door itself writes nothing")

            await Rig.dismissTheField(h.model)
            await Rig.awaitSavepoints(h, count: 1)

            let saved = try Rig.savepoints(h)
            #expect(saved.count == 1, "leaving the field by a click away files the commit")
            #expect(saved.first?.message == nil, "unnamed when nothing was typed")
            #expect(saved.first?.kind == .manual)
            #expect(saved.first?.text == "draft text")
            #expect(h.model.savepointAsk == nil, "the field is gone")
        }
    }

    /// **WHAT WAS TYPED RIDES A CLICK AWAY — RED ON OLD.** A name typed and
    /// never ⏎'d is still her name.
    @Test func aClickAwayFilesTheNameSheTyped() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            let popover = try await Rig.pressCommandS(h.model, mounted)
            try await Rig.focusTheField(in: popover)
            await Rig.type("kept", to: try Rig.deliveryWindow(for: popover))
            #expect(try Rig.savepoints(h).isEmpty, "premise: typing files nothing yet")

            await Rig.dismissTheField(h.model)
            await Rig.awaitSavepoints(h, count: 1)

            let saved = try Rig.savepoints(h)
            #expect(saved.count == 1)
            #expect(saved.first?.message == "kept", "the name typed into the field rides the click away")
        }
    }

    /// **THE POPOVER CLOSING ITSELF FILES IT — RED ON OLD.** The watcher's
    /// road: AppKit's transient dismissal closes the popover (`performClose`)
    /// and the presenter hears its `willClose` — one commit, whatever the
    /// binding does after.
    @Test func thePopoversOwnCloseFilesTheCommit() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            try await Rig.closeThePopoverItself(mounted)
            await Rig.awaitSavepoints(h, count: 1)
            await Rig.turns(40)  // the binding's own write after the close

            let saved = try Rig.savepoints(h)
            #expect(saved.count == 1, "the popover's own close files the commit — once")
            #expect(saved.first?.message == nil)
            #expect(h.model.savepointAsk == nil)
        }
    }

    /// **⎋ ALONE IS "DON'T SAVE" — GUARD** (green on both sides by design).
    /// The ⎋ is settled before the popover closes, so the closing that
    /// follows can never file it.
    @Test func escapeAloneFilesNothing() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            let popover = try await Rig.pressCommandS(h.model, mounted)
            try await Rig.focusTheField(in: popover)
            let delivery = try Rig.deliveryWindow(for: popover)
            await Rig.type("not this", to: delivery)
            await Rig.key("\u{1b}", keyCode: 53, to: delivery)
            let closed = await Rig.turns(until: { h.model.savepointAsk == nil }, max: 120)
            #expect(closed, "⎋ closes the field")
            await Rig.turns(60)  // the popover's own close, and any filing it could start

            #expect(try Rig.savepoints(h).isEmpty,
                    "⎋ is the deliberate \u{201C}don't save\u{201D} — no commit, named or not")
        }
    }

    /// **⏎ FILES ONCE — GUARD.** The field's ⏎ and the popover's own closing
    /// after it are two reports of ONE leave; one commit, never two.
    @Test func returnFilesExactlyOnce() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            let popover = try await Rig.pressCommandS(h.model, mounted)
            try await Rig.focusTheField(in: popover)
            await Rig.key("\r", keyCode: 36, to: try Rig.deliveryWindow(for: popover))
            await Rig.awaitSavepoints(h, count: 1)
            await Rig.turns(60)  // the popover's own close after the ⏎

            let saved = try Rig.savepoints(h)
            #expect(saved.count == 1, "one ⏎, one commit — the closing after it is the same leave")
            #expect(saved.first?.message == nil)
        }
    }

    /// **HER ⌘S NEVER DEDUPES — GUARD.** An unchanged take committed twice
    /// is two commits (today's behaviour, kept: `commit` appends always —
    /// P-VX168-U2-1's note); VX-347 adds roads, never a dedupe.
    @Test func anUnchangedTakeCommittedTwiceIsTwoCommits() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            for round in 1...2 {
                let popover = try await Rig.pressCommandS(h.model, mounted)
                try await Rig.focusTheField(in: popover)
                await Rig.key("\r", keyCode: 36, to: try Rig.deliveryWindow(for: popover))
                await Rig.awaitSavepoints(h, count: round)
                await Rig.turns(60)
            }
            let saved = try Rig.savepoints(h)
            #expect(saved.count == 2, "append always — the second commit of the same text is still a commit")
            #expect(Set(saved.map(\.text)) == ["draft text"])
        }
    }

    /// **THE HOST GOING FILES IT — RED ON OLD** (a mode switch, ⇧⌘W, a
    /// closing sheet: the bar leaves the hierarchy with the field up).
    @Test func theHostGoingFilesTheCommit() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            mounted.hosting.rootView = AnyView(Color.clear)  // Write's bar goes
            await Rig.awaitSavepoints(h, count: 1)

            #expect(try Rig.savepoints(h).count == 1, "the field leaving with its host files the commit")
        }
    }

    /// **THE WINDOW CLOSING FILES IT — RED ON OLD.**
    @Test func theWindowClosingFilesTheCommit() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            mounted.window.close()
            mounted.window.contentView = nil  // a closed window's views go with it
            await Rig.awaitSavepoints(h, count: 1)

            #expect(try Rig.savepoints(h).count == 1, "closing the window with the field up files the commit")
        }
    }

    /// **⌘S AGAIN FILES THE OPEN FIELD — RED ON OLD** (PROVISIONAL
    /// P-VX347-2): the second press leaves the field (so it files) and opens
    /// no second one. Pre-fix it re-set the same ask and nothing happened.
    @Test func commandSAgainFilesTheOpenField() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            h.model.commitCaretVariant()  // ⌘S again
            await Rig.awaitSavepoints(h, count: 1)
            await Rig.turns(40)

            #expect(try Rig.savepoints(h).count == 1, "⌘S always commits")
            #expect(h.model.savepointAsk == nil, "…and opens no second field")
        }
    }

    /// **A CLICK INTO ANOTHER BLOCK COMMITS THE TAKE ⌘S ASKED ABOUT — RED ON
    /// OLD** (nothing filed there at all). The click moves the caret before
    /// the filing runs; the commit is still the first block's.
    @Test func aClickIntoAnotherBlockCommitsTheTakeAskedAbout() async throws {
        try await withEditor(seedBlocks: ["first block", "second block"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            // The click lands in the second block: the caret moves first…
            let second = ("first block" as NSString).length + 1 + 3
            h.textView.setSelectedRange(NSRange(location: second, length: 0))
            h.model.updateCaretContext()
            await Rig.dismissTheField(h.model)  // …and the popover closes on it
            await Rig.awaitSavepoints(h, slot: 0, count: 1)

            #expect(try Rig.savepoints(h, slot: 0).count == 1, "the take ⌘S asked about is committed")
            #expect(try Rig.savepoints(h, slot: 1).isEmpty, "never the take the click landed in")
        }
    }

    /// **TYPING ON AFTER LEAVING — RED ON OLD.** Back in her take, she types
    /// on: the commit holds the take as it was when the field left, and her
    /// new words are the buffer's, not the commit's.
    @Test func typingOnAfterTheFieldLeavesKeepsTheCommitAsItWas() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            await Rig.dismissTheField(h.model)  // the click back into the take…
            await Rig.awaitSavepoints(h, count: 1)  // …files at once…
            h.type(" and more", at: ("draft text" as NSString).length)  // …and she types on
            await h.flush()

            let saved = try Rig.savepoints(h)
            #expect(saved.count == 1)
            #expect(saved.first?.text == "draft text", "the commit is the take as the field left it")
            #expect(try h.storeSlots()[0].text == "draft text and more", "the typing on is the buffer's")
        }
    }

    /// **A LOCKED TAKE STILL REFUSES — RED ON OLD** (pre-fix, the click away
    /// said nothing at all): leaving the field reaches the same filer ⏎ does,
    /// and the filer's refusal speaks. No MANUAL commit. (The field does open
    /// on a locked take — the door checks the seal, not the take's lock — and
    /// locking this never-committed, so dirty, take first appends ONE quiet
    /// auto commit: the lock insures what it guards, AppSpec §9. Fix leg: the
    /// first cut counted that one and failed on every tree.)
    @Test func aLockedTakeStillRefusesWhenTheFieldIsLeft() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            let variantID = try #require(try h.storeSlots()[0].variantID)
            try h.session.operations.lockVariant(variantID)
            try h.reload()
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)

            await Rig.dismissTheField(h.model)
            let spoke = await Rig.turns(until: { h.model.statusMessage != nil }, max: 200)

            #expect(spoke, "the refusal speaks")
            let saved = try Rig.savepoints(h)
            #expect(saved.allSatisfy { $0.kind == .auto },
                    "premise: only the lock's own quiet savepoint")
            #expect(saved.filter { $0.kind == .manual }.isEmpty,
                    "a locked take takes no commit, whichever way the field is left")
        }
    }

    /// **A SEAL THAT LANDS WHILE THE FIELD IS UP STILL REFUSES — RED ON
    /// OLD.** The door refuses a sealed note before it opens a field (the
    /// shipped `SavepointSealedDoorTests`); a seal arriving after it (another
    /// window, a sync) is met by the filer, on every leave.
    @Test func aSealThatLandsWhileTheFieldIsUpStillRefuses() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await Rig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            caretInFirstBlock(h)
            _ = try await Rig.pressCommandS(h.model, mounted)
            try h.session.operations.lockPost(h.postID)

            await Rig.dismissTheField(h.model)
            let spoke = await Rig.turns(until: { h.model.statusMessage != nil }, max: 200)

            #expect(spoke, "the seal's refusal speaks")
            #expect(h.model.statusMessage == OpsRefusalCopy.message(
                for: OperationError.lockedPost(id: h.postID)))
            // A seal's own quiet savepoints are `.auto`; no MANUAL commit landed.
            #expect(try Rig.savepoints(h).filter { $0.kind == .manual }.isEmpty)
        }
    }
}
