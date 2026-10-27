//
//  BrowserNavKeysTests.swift
//  VariorumTests
//
//  **VX-560 (the VX-439 run, A-439-12) — ⌘← / ⌘→ go back and forward,
//  outside text.** Her scope call: inside the editor ⌘← / ⌘→ stay the start
//  and the end of the line; outside a text view they are the browser's Back
//  and Forward. ⌥⌘[ / ⌥⌘] remain the acts' chords and the menus' labels; the
//  registry carries ⌘← / ⌘→ as each act's alternate.
//
//  Pins: the pure rule (exactly ⌘, and never while text holds the keyboard);
//  the registry (the alternates declared, the menus' chords unchanged, and NO
//  menu key equivalent anywhere on a bare ⌘← / ⌘→ — which would take line
//  start/end from every text view); the act (Back/Forward through the shell,
//  or the declared refusal spoken); and the monitor in a window — a text
//  field keeps ⌘← as its line-start key, and with no text in charge the key
//  navigates (the `PagesArrowKeysHostTests` road).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-560 — ⌘← / ⌘→ are Back and Forward outside text", .serialized)
struct BrowserNavKeysTests {
    private typealias Keys = BrowserNavKeys
    private static let left = PageTurnKeys.leftArrowKeyCode
    private static let right = PageTurnKeys.rightArrowKeyCode

    // MARK: - The rule

    @Test func onlyExactlyCommandArrowNavigatesAndNeverWhileTextHoldsTheKeyboard() {
        let arrowFlags: NSEvent.ModifierFlags = [.numericPad, .function]
        #expect(Keys.direction(keyCode: Self.left, modifiers: .command, textIsFirstResponder: false) == .back)
        #expect(Keys.direction(keyCode: Self.right, modifiers: .command, textIsFirstResponder: false) == .forward)
        #expect(Keys.direction(keyCode: Self.left, modifiers: arrowFlags.union(.command), textIsFirstResponder: false)
                == .back, "an arrow's own flags are not modifiers she pressed")
        for chord: NSEvent.ModifierFlags in [[.command, .shift], [.command, .option], [.command, .control], [], .option] {
            #expect(Keys.direction(keyCode: Self.left, modifiers: chord, textIsFirstResponder: false) == nil,
                    "\(chord.rawValue): not the browser chord (⇧⌘← selects, ⌥⌘← pages a fan, ⌃⌘← steps takes)")
        }
        #expect(Keys.direction(keyCode: 0, modifiers: .command, textIsFirstResponder: false) == nil, "⌘A is not it")
        for key in [Self.left, Self.right] {
            #expect(Keys.direction(keyCode: key, modifiers: .command, textIsFirstResponder: true) == nil,
                    "in text ⌘←/⌘→ stay line start/end — always")
        }
        #expect(Keys.Direction.back.capability == .navigateBack)
        #expect(Keys.Direction.forward.capability == .navigateForward)
    }

    // MARK: - The registry

    @Test func theAlternatesAreDeclaredAndNoMenuKeyEverTakesTheLineKeys() {
        let back = CapabilityRegistry.capability(.navigateBack)
        let forward = CapabilityRegistry.capability(.navigateForward)
        #expect(back.alternateShortcutLabel == "\u{2318}\u{2190}" && forward.alternateShortcutLabel == "\u{2318}\u{2192}")
        #expect(back.shortcutLabel == "\u{2325}\u{2318}[" && forward.shortcutLabel == "\u{2325}\u{2318}]",
                "the menus keep showing ⌥⌘[ / ⌥⌘]")
        #expect(EditorCommands.keyEquivalent(for: .navigateBack)?.0 == KeyEquivalent("["))
        #expect(EditorCommands.keyEquivalent(for: .navigateBack)?.1 == [.command, .option])
        for capability in CapabilityRegistry.all {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: capability.id) else { continue }
            let bareCommandArrow = (key == .leftArrow || key == .rightArrow) && modifiers == .command
            #expect(!bareCommandArrow, "\(capability.id) would take ⌘←/⌘→ from every text view as a menu key")
        }
        let alternates = CapabilityRegistry.all.compactMap(\.alternateShortcutLabel)
        #expect(Set(alternates) == ["\u{2318}\u{2190}", "\u{2318}\u{2192}"], "the only alternates: \(alternates)")
        #expect(HelperView.shortcutKeysShown.isSuperset(of: Set(alternates)), "the helper (⌘/) shows them")
    }

    // MARK: - The act

    /// The key's act is the menu items' own: Back/Forward through the shell —
    /// or, where the act cannot go, its declared refusal SPOKEN.
    @Test func theKeyRunsBackAndForwardOrSpeaksTheDeclaredRefusal() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 560))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            session.commandRouter.canNavigateBack = { router.workspace.history().canGoBack }
            session.commandRouter.canNavigateForward = { router.workspace.history().canGoForward }
            router.adopt(.post("a"))
            RootView.navigate(.back, session: session, router: router)
            #expect(session.status.spoken?.kind == .refusal)
            #expect(session.status.spoken?.text == CapabilityRegistry.capability(.navigateBack).unavailableNote)
            #expect(router.workspace.focusedSelection == .post("a"), "nothing moved")
            router.adopt(.post("b"))
            RootView.navigate(.back, session: session, router: router)
            #expect(router.workspace.focusedSelection == .post("a"), "⌘← went back")
            RootView.navigate(.forward, session: session, router: router)
            #expect(router.workspace.focusedSelection == .post("b"), "⌘→ went forward")
        }
    }

    // MARK: - The monitor, in a window

    private final class Seen {
        var directions: [BrowserNavKeys.Direction] = []
    }

    private struct Host: View {
        let seen: Seen
        @State private var text = "a line"

        var body: some View {
            VStack {
                TextField("field", text: $text)
                Text("not text")
            }
            .padding(20)
            .background { BrowserNavKeyMonitor { seen.directions.append($0) } }
        }
    }

    private static func key(
        _ keyCode: UInt16, _ character: String, _ flags: NSEvent.ModifierFlags, window: NSWindow
    ) -> NSEvent? {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: flags,
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: character, charactersIgnoringModifiers: character,
            isARepeat: false, keyCode: keyCode)
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    /// **The door, as she presses it.** With the field's editor in charge,
    /// ⌘← is the field's line-start key (the caret goes to 0) and the monitor
    /// takes nothing; with no text in charge, ⌘← and ⌘→ navigate and ⇧⌘←
    /// does not.
    @Test func aTextFieldKeepsCommandArrowAndElsewhereItNavigates() async throws {
        let seen = Seen()
        let rig = BlocksWorkbenchFaceTests.Rig(Host(seen: seen), width: 420, height: 200)
        defer { rig.close() }
        #expect(await rig.poll(timeout: 5) { !Self.views(NSTextField.self, in: rig.hosting).isEmpty })
        let field = try #require(Self.views(NSTextField.self, in: rig.hosting).first)
        rig.window.makeFirstResponder(field)
        #expect(await rig.poll(timeout: 2) { rig.window.firstResponder is NSTextView }, "the field's editor holds the keyboard")
        let editor = try #require(rig.window.firstResponder as? NSTextView)
        editor.setSelectedRange(NSRange(location: (editor.string as NSString).length, length: 0))
        let start = editor.selectedRange().location
        #expect(start > 0)
        NSApp.sendEvent(try #require(Self.key(Self.left, "\u{F702}", [.command, .numericPad, .function], window: rig.window)))
        rig.pump(0.05)
        await rig.turn()
        #expect(editor.selectedRange().location == 0, "⌘← went to the line's start: \(editor.selectedRange())")
        #expect(seen.directions.isEmpty, "nothing navigated while text held the keyboard")

        rig.window.makeFirstResponder(nil)
        _ = await rig.poll(timeout: 2) { !(rig.window.firstResponder is NSTextView) }
        NSApp.sendEvent(try #require(Self.key(Self.left, "\u{F702}", [.command, .numericPad, .function], window: rig.window)))
        rig.pump(0.05)
        NSApp.sendEvent(try #require(Self.key(Self.right, "\u{F703}", [.command, .numericPad, .function], window: rig.window)))
        rig.pump(0.05)
        NSApp.sendEvent(try #require(Self.key(Self.left, "\u{F702}", [.command, .shift, .numericPad, .function], window: rig.window)))
        rig.pump(0.05)
        #expect(await rig.poll(timeout: 2) { seen.directions.count >= 2 })
        #expect(seen.directions == [.back, .forward], "⌘← back, ⌘→ forward, ⇧⌘← nothing: \(seen.directions)")
    }
}
