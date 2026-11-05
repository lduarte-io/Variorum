//
//  WingNumberKeysTests.swift
//  VariorumTests (Mac)
//
//  VX-824 (the VX-828 run, batch B) — her ask: *"map the Command1, command2,
//  command3, etc. to moving between different wings when you aren't in a
//  note"*; her ruling, shape (a): ⌘digit is CONTEXTUAL — inside a note the
//  mode row, everywhere else wing N in the switcher's order, Home first.
//
//  THE MECHANISM BEFORE (traced, B0): outside a note the View menu's mode
//  items are grey (`.switchMode` — `ctx.mode != nil`), and a grey menu item
//  swallows its chord in silence — ⌘1–⌘9 did nothing at all there.
//
//  THE PINS: the chord's key (exactly ⌘ + one digit); the rule's table — the
//  three contexts the brief names (in a note ⇒ the mode row; the capture box
//  holding the keys ⇒ the wing — the fork's Q-B1 (a); a writing surface
//  holding the keys ⇒ passed on) and P-828-1's two arms; the words as
//  drafted; the keyboard holder's classes; the declaration; and the WHOLE
//  ROAD with real NSEvents and a real window — `RootView.wingNumberKey`,
//  exactly what the monitor runs.
//
//  RED ON OLD: a new act — compile-red on the pre-fix tree (no `.goToWing`,
//  no `WingNumberKeys`). The behavioral revert that shows the road's teeth
//  (R-B1, the record): make `WingNumberKeys.decide` answer `.passOn` always
//  (the old silent swallow) — every "goes" / "refuses" line here goes red,
//  every "passes on" line stays green.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

private typealias Row = WingSwitcherBrain.Row

private let threeWings: [Row] = [
    Row(id: "", name: "Home"),
    Row(id: "w-studio", name: "studio"),
    Row(id: "w-letters", name: "letters"),
]

@MainActor
@Suite("VX-824 — ⌘1–⌘9: wings from the keyboard, the mode row inside a note", .serialized)
struct WingNumberKeysTests {
    // MARK: - The key

    @Test func theChordIsCommandAndOneDigitOnly() {
        func n(_ chars: String?, _ flags: NSEvent.ModifierFlags) -> Int? {
            WingNumberKeys.number(charactersIgnoringModifiers: chars, modifiers: flags)
        }
        for digit in 1...9 {
            #expect(n("\(digit)", .command) == digit, "⌘\(digit)")
        }
        #expect(n("0", .command) == nil, "⌘0 names no wing")
        #expect(n("1", [.command, .shift]) == nil, "⌘⇧1 is the Open list's")
        #expect(n("1", [.command, .option]) == nil)
        #expect(n("1", [.command, .control]) == nil)
        #expect(n("1", []) == nil, "a typed 1 is typing")
        #expect(n("1", [.command, .numericPad]) == 1, "the keypad's own flag is not a modifier she pressed")
        #expect(n("1", [.command, .capsLock]) == 1, "caps lock is not a modifier here")
        #expect(n("12", .command) == nil)
        #expect(n("l", .command) == nil, "⌘L is the switcher's")
        #expect(n(nil, .command) == nil)
    }

    // MARK: - The rule (the brief's three contexts + P-828-1)

    @Test func insideANoteTheKeysStayTheModeRow() {
        #expect(WingNumberKeys.decide(number: 2, available: false, holder: .other, wings: threeWings) == .passOn,
                "a note in the focused pane: ⌘2 reaches the mode row")
        #expect(WingNumberKeys.decide(number: 2, available: false, holder: .writingSurface, wings: threeWings)
                    == .passOn)
        #expect(WingNumberKeys.decide(number: 9, available: false, holder: .other, wings: threeWings) == .passOn,
                "inside a note even a number no wing answers is the menu's, never a wing refusal")
    }

    @Test func outsideANoteTheKeysGoToTheWingInSwitcherOrder() {
        #expect(WingNumberKeys.decide(number: 1, available: true, holder: .other, wings: threeWings) == .goTo(""),
                "Home is ⌘1")
        #expect(WingNumberKeys.decide(number: 2, available: true, holder: .other, wings: threeWings)
                    == .goTo("w-studio"))
        #expect(WingNumberKeys.decide(number: 3, available: true, holder: .other, wings: threeWings)
                    == .goTo("w-letters"))
        #expect(WingNumberKeys.decide(number: nil, available: true, holder: .other, wings: threeWings) == .passOn,
                "not the chord's key")
    }

    /// Q-B1 (a): a WRITING surface holding the keys passes the chord on (a
    /// book's live note, a snippet, a comment) — the capture box, a field or
    /// nothing do not (`.other`), which is what keeps ⌘digit alive on the
    /// Bookcase, where VX-332 rests the caret in the quick entry.
    @Test func aWritingSurfaceHoldingTheKeysPassesTheChordOn() {
        #expect(WingNumberKeys.decide(number: 2, available: true, holder: .writingSurface, wings: threeWings)
                    == .passOn)
    }

    /// P-828-1 (i): a number no wing answers is a REFUSAL, spoken — never a
    /// silent swallow. With ONE wing ⌘1 is Home's Bookcase (P-828-1 (ii)(a),
    /// accepted) and ⌘2 speaks ⌘L's note's shape.
    @Test func aNumberNoWingAnswersIsARefusal() {
        #expect(WingNumberKeys.decide(number: 5, available: true, holder: .other, wings: threeWings)
                    == .refuse(WingCopy.noWingAtNumber(5, wingCount: 3)))
        let home = [Row(id: "", name: "Home")]
        #expect(WingNumberKeys.decide(number: 1, available: true, holder: .other, wings: home) == .goTo(""))
        #expect(WingNumberKeys.decide(number: 2, available: true, holder: .other, wings: home)
                    == .refuse(WingCopy.noWingAtNumber(2, wingCount: 1)))
    }

    /// The fork's drafts, verbatim (PROVISIONAL — hers to tune).
    @Test func theRefusalsAreTheDraftedWords() {
        #expect(WingCopy.noWingAtNumber(5, wingCount: 3)
                    == "There's no wing 5 \u{2014} \u{2318}1\u{2013}\u{2318}3 go to your 3 wings, Home first.")
        #expect(WingCopy.noWingAtNumber(2, wingCount: 1)
                    == "There is only one wing so far \u{2014} New Wing\u{2026} under the wing name at the "
                    + "top of the Bookcase makes another, and then \u{2318}2 goes to it.")
    }

    // MARK: - Who holds the keys

    @Test func theWritingSurfacesAreTheNoteProseAndTheCommentText() {
        #expect(WingNumberKeys.holder(EditorTextView.makeInlineEditor()) == .writingSurface,
                "a book's live note / the Pool / Snippets")
        #expect(WingNumberKeys.holder(PaneTextView(usingTextLayoutManager: true)) == .writingSurface,
                "the panes' TK2 surface (Read's edit face)")
        #expect(WingNumberKeys.holder(CommentNSTextView(frame: .zero)) == .writingSurface, "a comment")
        #expect(WingNumberKeys.holder(CaptureNSTextView(usingTextLayoutManager: true)) == .other,
                "the capture box is not a note — the Bookcase's resting caret")
        #expect(WingNumberKeys.holder(NSTextView(frame: .zero)) == .other, "a field editor")
        #expect(WingNumberKeys.holder(nil) == .other)
    }

    // MARK: - The declaration (P-1)

    @Test func theChordIsDeclaredAsTheMonitorsAlternate() {
        let act = CapabilityRegistry.capability(.goToWing)
        #expect(act.doors == [.surface], "the window's key monitor is its door — no menu item")
        #expect(act.shortcutLabel == nil, "a menu key equivalent would take ⌘1–⌘7 from the mode row")
        #expect(act.alternateShortcutLabel == "\u{2318}1\u{2013}9")
        #expect(act.scope == .app && act.takesAccess == nil)
        #expect(RootView.surfaceCapabilities.contains(.goToWing), "the full window renders its door")
        // The mode row's mirror: unavailable exactly where ⌘1–⌘n are the modes.
        for mode in PostMode.allCases {
            #expect(CapabilityRegistry.availability(.goToWing, in: CapabilityContext(mode: mode)) == .unavailable)
            #expect(CapabilityRegistry.availability(.switchMode, in: CapabilityContext(mode: mode)) == .act)
        }
        #expect(CapabilityRegistry.availability(.goToWing, in: CapabilityContext(mode: nil)) == .act)
        #expect(CapabilityRegistry.availability(.switchMode, in: CapabilityContext(mode: nil)) == .unavailable)
        // The helper shows it (13g L1), read from the declaration.
        let row = ShortcutCatalog.rows.first { $0.acts == [.goToWing] }
        #expect(row?.tokens == ["\u{2318}1\u{2013}9"])
        #expect(row?.group == .navigation)
        // Searching the chord by name finds BOTH meanings — the contextual pair.
        let three = ShortcutCatalogFilter.sections(query: "cmd 3", expanded: []).flatMap(\.rows).map(\.keysText)
        #expect(three.contains(PostMode.keyLabel()) && three.contains("\u{2318}1\u{2013}9"), "\(three)")
    }

    // MARK: - THE ROAD (real events, a real window, the session's router)

    private func chord(_ digit: Int, in window: NSWindow, flags: NSEvent.ModifierFlags = .command) throws -> NSEvent {
        let codes: [Int: UInt16] = [1: 18, 2: 19, 3: 20, 4: 21, 5: 23, 6: 22, 7: 26, 8: 28, 9: 25]
        return try #require(NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: flags, timestamp: 0,
            windowNumber: window.windowNumber, context: nil,
            characters: "\(digit)", charactersIgnoringModifiers: "\(digit)",
            isARepeat: false, keyCode: codes[digit] ?? 18))
    }

    private func makeWindow(holding responder: NSView?) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: window.contentLayoutRect)
        window.contentView = content
        if let responder {
            responder.frame = NSRect(x: 0, y: 0, width: 300, height: 100)
            content.addSubview(responder)
            window.makeFirstResponder(responder)
        }
        return window
    }

    private func withWingWorld(
        _ body: @MainActor (AppSession, WingsModel, ShellRouter, Wing) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 824))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let studio = try session.operations.createWing(name: "studio")
            let wings = WingsModel(session: session)
            await wings.load()
            let router = ShellRouter()
            RootView.wireWingLanding(wings: wings, router: router)
            try await body(session, wings, router, studio)
        }
    }

    /// The Bookcase at rest: the capture box holds the keys (VX-332) and no
    /// note is open — ⌘2 goes to wing 2, said, landing on its Bookcase; the
    /// key is consumed.
    @Test func onTheBookcaseWithTheCaptureBoxHoldingTheKeysTheChordGoes() async throws {
        try await withWingWorld { session, wings, router, studio in
            let capture = CaptureNSTextView(usingTextLayoutManager: true)
            let window = makeWindow(holding: capture)
            #expect(window.firstResponder === capture, "premise: the quick entry holds the keyboard")
            let consumed = RootView.wingNumberKey(
                try chord(2, in: window), window: window, session: session, wings: wings)
            #expect(consumed, "the chord's key — consumed")
            #expect(session.wing.currentID == studio.id, "wing 2 in the switcher's order")
            #expect(session.status.spoken?.text == "Now in \u{201C}studio\u{201D}.")
            #expect(router.pendingSelection == .shelf, "landing on its Bookcase (VX-833)")
        }
    }

    /// Inside a note: the mode row's — passed on, nothing switched or said.
    @Test func insideANoteTheChordPassesToTheModeRow() async throws {
        try await withWingWorld { session, wings, router, _ in
            _ = session.commandRouter.registerDetail(postID: "p-note", mode: .write, applyMode: { _ in })
            let window = makeWindow(holding: EditorTextView.makeInlineEditor())
            let consumed = RootView.wingNumberKey(
                try chord(2, in: window), window: window, session: session, wings: wings)
            #expect(!consumed, "inside a note ⌘2 reaches the mode row")
            #expect(session.wing.currentID == "")
            #expect(session.status.spoken == nil)
            #expect(router.pendingSelection == nil)
            let empty = makeWindow(holding: nil)
            let bare = RootView.wingNumberKey(
                try chord(2, in: empty), window: empty, session: session, wings: wings)
            #expect(!bare, "a note open with nothing holding the keys — still the mode row")
        }
    }

    /// A book's live note (no note detail, a writing surface holding the keys):
    /// passed on — the grey mode item's old silence, untouched (Q-B1 (a)).
    @Test func writingInABooksLiveNoteTheChordPassesOn() async throws {
        try await withWingWorld { session, wings, router, _ in
            #expect(session.commandRouter.activeMode == nil, "premise: no note detail (a book view)")
            let window = makeWindow(holding: EditorTextView.makeInlineEditor())
            let consumed = RootView.wingNumberKey(
                try chord(2, in: window), window: window, session: session, wings: wings)
            #expect(!consumed, "she is writing — the chord never jumps wings under her hands")
            #expect(session.wing.currentID == "")
            #expect(router.pendingSelection == nil)
        }
    }

    /// A number no wing answers: consumed, the refusal spoken, nothing moved.
    @Test func aNumberNoWingAnswersSpeaksAndMovesNothing() async throws {
        try await withWingWorld { session, wings, router, _ in
            let window = makeWindow(holding: nil)
            let consumed = RootView.wingNumberKey(
                try chord(7, in: window), window: window, session: session, wings: wings)
            #expect(consumed, "consumed — it never reaches the grey mode item's silence")
            #expect(session.status.spoken?.kind == .refusal)
            #expect(session.status.spoken?.text == WingCopy.noWingAtNumber(7, wingCount: 2))
            #expect(session.wing.currentID == "")
            #expect(router.pendingSelection == nil)
        }
    }

    /// ⌘1 on the CURRENT wing (Home): nothing switched, nothing said — it
    /// lands on the Bookcase (P-828-1 (ii)(a)). ⌘⇧1 is never the chord's.
    @Test func theCurrentWingsNumberLandsSilentlyAndShiftIsNotTheChord() async throws {
        try await withWingWorld { session, wings, router, _ in
            let window = makeWindow(holding: nil)
            let home = RootView.wingNumberKey(
                try chord(1, in: window), window: window, session: session, wings: wings)
            #expect(home, "the chord's key — consumed")
            #expect(session.wing.currentID == "")
            #expect(session.status.spoken == nil, "the wing did not change — nothing to say")
            #expect(router.pendingSelection == .shelf, "but she lands on Home's Bookcase")
            router.pendingSelection = nil
            let shifted = RootView.wingNumberKey(
                try chord(1, in: window, flags: [.command, .shift]), window: window,
                session: session, wings: wings)
            #expect(!shifted, "⌘⇧1 is the Open list's")
            #expect(router.pendingSelection == nil)
        }
    }
}
