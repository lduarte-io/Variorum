//
//  QuickEntryOpeningFocusTests.swift
//  VariorumTests
//
//  VX-282 U6 — VX-326: THE FIX'S OWN PINS (GUARDS of the fixed product — they
//  name `CaptureOpeningFocus`, `openingFocusRequest`, `armOpeningFocus` and
//  `QuickEntryOpeningFocus`, which the old tree does not have). The red-on-old
//  pins and the launch rig are `QuickEntryLaunchFocusTests.swift`; the binding
//  record is `notes/plans/fixes/vx-282-editor-notes-fixes.md` § U6.
//
//  · the rule as a table (`CaptureOpeningFocusRuleTests`);
//  · the box's opening road — it waits for its window, takes only a free
//    keyboard, is never served late, and is served once
//    (`CaptureOpeningFocusBoxTests`);
//  · the scope — VX-332 (the VX-439 run, her ruling "YES — focus on every
//    return"): EVERY Bookcase mount asks through the opening road, so a
//    navigation back puts the caret in the box (RED ON OLD — VX-326 spent a
//    one-shot shell claim and the later mount's counted raise dropped), and a
//    running tour's mount stands down (`QuickEntryOpeningScopeTests`). The
//    one-shot claim (`QuickEntryOpeningFocus`) retired with the ruling, and
//    its own pin (`theClaimIsTrueExactlyOnce`) with it.
//

import AppKit
import Dependencies
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, as a table (VX-326 — the fix's own pins; GUARDS)

@Suite("VX-326 — the capture box's opening ask: the rule")
struct CaptureOpeningFocusRuleTests {
    private typealias Rule = CaptureOpeningFocus

    @Test func outOfItsWindowTheAskWaits() {
        for keyboard: Rule.Holder in [.nobody, .theBox, .someoneElse] {
            for sheet in [false, true] {
                #expect(Rule.verdict(.init(inWindow: false, keyboard: keyboard, sheetOnWindow: sheet)) == .wait)
            }
        }
    }

    @Test func inItsWindowTheAskTakesOnlyAFreeKeyboard() {
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .nobody, sheetOnWindow: false)) == .take)
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .someoneElse, sheetOnWindow: false)) == .drop,
                "never steals from another responder")
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .nobody, sheetOnWindow: true)) == .drop,
                "a sheet on the window holds its keyboard")
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .someoneElse, sheetOnWindow: true)) == .drop)
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .theBox, sheetOnWindow: false)) == .alreadyHeld)
    }
}

// MARK: - The box's opening road (the fix's own pins; GUARDS)

/// A host for the bare box with both of its asks.
@MainActor
@Observable
private final class OpeningBoxRig {
    var text = ""
    var focusRequest = 0
    var openingFocusRequest = 0
}

private struct OpeningBoxRigView: View {
    @Bindable var rig: OpeningBoxRig

    var body: some View {
        CaptureTextView(
            text: $rig.text, style: CaptureTextStyle(tokens: .terminalLight), maxHeight: 160,
            focusRequest: rig.focusRequest, openingFocusRequest: rig.openingFocusRequest,
            onFile: {})
            .frame(width: 400, height: 60)
    }
}

@MainActor
private struct MountedBox {
    let window: NSWindow
    let content: NSView
    let hosting: NSView
    let field: NSTextField
    let box: CaptureNSTextView
    let rig: OpeningBoxRig

    static func mount() async throws -> MountedBox {
        let rig = OpeningBoxRig()
        let hosting = NSHostingView(rootView: OpeningBoxRigView(rig: rig))
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 420, height: 120),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 120))
        hosting.frame = NSRect(x: 0, y: 40, width: 420, height: 80)
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(nil)  // AppKit's own pick of the field undone (the rig's harness fact)
        await LaunchFocusRig.settle(turns: 100) { LaunchFocusRig.windowedBox(window) != nil }
        let box = try #require(LaunchFocusRig.windowedBox(window), "the box mounted")
        return MountedBox(window: window, content: content, hosting: hosting, field: field, box: box, rig: rig)
    }

    /// The host out of the window and back — SwiftUI's re-parent shape
    /// (`PaneFindFaceTests.reparent`), with the pin's act in between.
    func detach() { hosting.removeFromSuperview() }
    func reattach() { content.addSubview(hosting) }

    func close() { LaunchFocusRig.close(window) }
}

@MainActor
@Suite("VX-326 — the capture box's opening ask waits for its window, takes only a free keyboard, once",
       .serialized)
struct CaptureOpeningFocusBoxTests {
    /// The launch's order, driven at the box: the ask arrives while the box
    /// is OUT of its window; it waits, and the arrival decides (a free
    /// keyboard: the caret).
    @Test func anAskArmedOutOfTheWindowIsDecidedOnArrival() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        #expect(LaunchFocusRig.keyboardIsFree(window), "non-vacuity: a free keyboard")
        mounted.detach()
        #expect(box.window == nil, "non-vacuity: the box is out of its window")
        box.armOpeningFocus()
        await LaunchFocusRig.settle(turns: 5)
        #expect(box.openingFocusPending, "the ask waits for the window")
        #expect(window.firstResponder !== box)

        mounted.reattach()
        await LaunchFocusRig.settle(turns: 20) { window.firstResponder === box }
        #expect(window.firstResponder === box, "arrived on a free keyboard — the caret is the box's")
        #expect(!box.openingFocusPending, "decided, once")
    }

    /// Never steals, never late: a field takes the keyboard while the ask
    /// waits; the arrival drops it, and no later re-attach or release serves it.
    @Test func anAskNeverStealsAndIsNeverServedLate() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        mounted.detach()
        box.armOpeningFocus()
        window.makeFirstResponder(mounted.field)
        let holder = window.firstResponder
        #expect(holder !== window && holder !== box, "non-vacuity: the field holds the keyboard")

        mounted.reattach()
        await LaunchFocusRig.settle(turns: 20)
        #expect(window.firstResponder === holder, "the field keeps it")
        #expect(!box.openingFocusPending, "the ask is spent — dropped")

        window.makeFirstResponder(nil)  // the keyboard freed later
        mounted.detach()
        mounted.reattach()
        await LaunchFocusRig.settle(turns: 20)
        #expect(window.firstResponder !== box, "a dropped ask is never served later")
    }

    /// Through the representable: an ask raised with the box in a window whose
    /// keyboard is free takes the caret; served ONCE — a release and a
    /// re-attach afterwards leave it away (VX-112's contract, unchanged).
    @Test func anAskOnAFreeWindowTakesTheCaretAndIsServedOnce() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        #expect(window.firstResponder !== box, "nothing has asked yet")
        #expect(LaunchFocusRig.keyboardIsFree(window), "non-vacuity: a free keyboard")
        mounted.rig.openingFocusRequest += 1
        await LaunchFocusRig.settle(turns: 20) { window.firstResponder === box }
        #expect(window.firstResponder === box)

        window.makeFirstResponder(nil)  // the release (the tour's own act)
        mounted.detach()
        mounted.reattach()
        await LaunchFocusRig.settle(turns: 20)
        #expect(window.firstResponder !== box, "released, the box stays away — the ask was served once")
    }

    /// Through the representable: a sheet on the window holds its keyboard —
    /// the ask is dropped, and closing the sheet does not serve it.
    @Test func anAskWithASheetOnTheWindowIsDropped() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        let sheet = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        sheet.isReleasedWhenClosed = false
        window.beginSheet(sheet, completionHandler: nil)
        await LaunchFocusRig.settle(turns: 60) { window.attachedSheet === sheet }
        try #require(window.attachedSheet === sheet, "non-vacuity: the sheet is on the window")

        mounted.rig.openingFocusRequest += 1
        await LaunchFocusRig.settle(turns: 20)
        #expect(window.firstResponder !== box)
        #expect(!box.openingFocusPending, "dropped")
        window.endSheet(sheet)
        await LaunchFocusRig.settle(turns: 30) { window.attachedSheet == nil }
        #expect(window.firstResponder !== box, "the sheet's close serves nothing")
    }
}

// MARK: - Every Bookcase mount asks (VX-332 — the VX-439 run)

/// A bare quick-entry bar beside a stand-in field, for the stand-down pins.
@MainActor
private func mountBar(
    session: AppSession, standsDown: Bool
) async -> (window: NSWindow, field: NSTextField) {
    let window = NSWindow(
        contentRect: NSRect(x: 80, y: 80, width: 720, height: 200),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 200))
    let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
    content.addSubview(field)
    window.contentView = content
    window.makeKeyAndOrderFront(nil)
    window.makeFirstResponder(nil)  // AppKit's own pick of the field undone (the rig's harness fact)
    // The bar arrives AFTER the window is up — a mount into a window already
    // showing something, the navigation-back shape.
    let hosting = NSHostingView(rootView: QuickEntryBar(
        session: session, onOpen: { _ in }, autofocus: true, standsDown: standsDown)
        .environment(ThemeStore(session: session)))
    hosting.frame = NSRect(x: 0, y: 40, width: 720, height: 160)
    content.addSubview(hosting)
    return (window, field)
}

@MainActor
@Suite("VX-332 — every Bookcase mount asks for the caret, never stealing, and stands down for a tour",
       .serialized)
struct QuickEntryOpeningScopeTests {
    /// **THE PIN — RED ON OLD.** The shell opens on the Bookcase (the caret in
    /// its quick entry); a navigation to the Library and back mounts a NEW
    /// Bookcase bar, and the caret lands in IT — through the waiting road, the
    /// counted raise untouched. On the old tree the claim was spent, the later
    /// mount raised the counted request, `takeFocus` met a box not yet in its
    /// window and dropped it: the window kept the keyboard (the VX-282
    /// record's O-U6-1 — the ticket's "navigating back to the Bookcase never
    /// puts the caret in quick entry").
    @Test func aNavigationBackToTheBookcasePutsTheCaretInItsQuickEntry() async throws {
        try await LaunchFocusRig.world(seed: 329) { session in
            let boot = LaunchFocusBoot()
            let router = ShellRouter()
            let (window, _) = LaunchFocusRig.window(boot: boot, session: session, router: router)
            defer { LaunchFocusRig.close(window) }
            await LaunchFocusRig.settle(turns: 10)
            boot.ready = true
            await LaunchFocusRig.settle(turns: 300) { LaunchFocusRig.windowedBox(window) != nil }
            let first = try #require(LaunchFocusRig.windowedBox(window))
            await LaunchFocusRig.settle(turns: 20) { window.firstResponder === first }
            #expect(window.firstResponder === first, "the shell's opening: the caret in the quick entry")

            // The Library carries a quick-entry bar of its own (no autofocus):
            // its box is told apart by identity.
            router.pendingSelection = .library
            await LaunchFocusRig.settle(turns: 300) {
                router.workspace.focusedSelection == .library
                    && LaunchFocusRig.windowedBox(window).map { $0 !== first } == true
            }
            #expect(router.workspace.focusedSelection == .library)
            let libraryBox = LaunchFocusRig.windowedBox(window)
            await LaunchFocusRig.settle(turns: 20)
            router.pendingSelection = .shelf
            await LaunchFocusRig.settle(turns: 300) {
                router.workspace.focusedSelection == .shelf
                    && LaunchFocusRig.windowedBox(window).map { $0 !== first && $0 !== libraryBox } == true
            }
            let second = try #require(LaunchFocusRig.windowedBox(window), "back on the Bookcase")
            #expect(second !== first && second !== libraryBox, "a new Bookcase bar mounted")
            await LaunchFocusRig.settle(turns: 40) { window.firstResponder === second }
            let secondAsks = try #require(second.delegate as? CaptureTextView.Coordinator)
            #expect(secondAsks.lastOpeningFocusRequest == 1, "the return asked, through the waiting road")
            #expect(secondAsks.lastFocusRequest == 0, "never the counted (stealing) raise")
            #expect(window.firstResponder === second, "VX-332: back on the Bookcase, the caret is in its quick entry")
        }
    }

    /// GUARD (never steal): a mount while another responder holds the
    /// window's keyboard leaves it there.
    @Test func aMountNeverTakesTheKeyboardFromAField() async throws {
        try await LaunchFocusRig.world(seed: 332) { session in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 720, height: 200),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { LaunchFocusRig.close(window) }
            let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 200))
            let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            content.addSubview(field)
            window.contentView = content
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(field)
            let holder = window.firstResponder
            #expect(holder !== window && holder != nil, "non-vacuity: the field holds the keyboard")
            let hosting = NSHostingView(rootView: QuickEntryBar(
                session: session, onOpen: { _ in }, autofocus: true)
                .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 40, width: 720, height: 160)
            content.addSubview(hosting)
            await LaunchFocusRig.settle(turns: 100) { LaunchFocusRig.windowedBox(window) != nil }
            let box = try #require(LaunchFocusRig.windowedBox(window))
            await LaunchFocusRig.settle(turns: 30)
            #expect(window.firstResponder === holder, "the field keeps it")
            #expect(window.firstResponder !== box)
        }
    }

    /// **The tour stands the bar down** (the W-U1a-1 lesson): a Bookcase mount
    /// while a tour runs does not ask — on a FREE keyboard the box stays
    /// away; the same mount with no tour takes it (non-vacuity).
    @Test func aMountDuringATourStandsDown() async throws {
        try await LaunchFocusRig.world(seed: 333) { session in
            let touring = await mountBar(session: session, standsDown: true)
            defer { LaunchFocusRig.close(touring.window) }
            await LaunchFocusRig.settle(turns: 100) { LaunchFocusRig.windowedBox(touring.window) != nil }
            let quiet = try #require(LaunchFocusRig.windowedBox(touring.window))
            await LaunchFocusRig.settle(turns: 30)
            #expect(LaunchFocusRig.keyboardIsFree(touring.window), "nothing took the free keyboard")
            #expect(touring.window.firstResponder !== quiet, "the tour's bar never asked")
            let asks = try #require(quiet.delegate as? CaptureTextView.Coordinator)
            #expect(asks.lastOpeningFocusRequest == 0 && asks.lastFocusRequest == 0)

            let plain = await mountBar(session: session, standsDown: false)
            defer { LaunchFocusRig.close(plain.window) }
            await LaunchFocusRig.settle(turns: 100) { LaunchFocusRig.windowedBox(plain.window) != nil }
            let asking = try #require(LaunchFocusRig.windowedBox(plain.window))
            await LaunchFocusRig.settle(turns: 40) { plain.window.firstResponder === asking }
            #expect(plain.window.firstResponder === asking, "with no tour the same mount takes the free keyboard")
        }
    }
}
