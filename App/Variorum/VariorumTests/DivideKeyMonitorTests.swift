//
//  DivideKeyMonitorTests.swift
//  VariorumTests
//
//  **18f ladder round 1, R1-1 (fable-reviewer)** — the divide sheet's
//  placement keys are the sheet's WINDOW's, and nobody else's.
//
//  Batch 1's row-3 fix put the sheet's ⇥/←/→ on a local `keyDown` monitor
//  (the controls inside its `ScrollView` take first responder and no focus
//  road gives it back — walked, three ways). A local monitor sees every key
//  the PROCESS dequeues, and that monitor's only guard was "the ceremony is
//  open": with the sheet modal on ONE window and a note open in another,
//  arrows typed in the other window were eaten and moved the ✂ here.
//
//  The door is now `CeremonyKeyMonitor` — the app's own shape for this
//  (`PageTurnKeyMonitor`), owned by a view in the sheet's window, deciding by
//  WINDOW NUMBER (`PaneFocusCatcher`'s lesson: `event.window` is nil for any
//  window a test builds). These pins drive its exposed body with real events
//  carrying real window numbers — the honest pair the `PaneFocusCatcher` pin
//  established: installation asserted, the decision driven — because a
//  synthesized event pushed at the app does not travel the queue a local
//  monitor watches in this test host.
//
//  RED-ON-OLD (by behavioural revert, recorded in the ladder's dispositions):
//  dropping the `windowNumber` guard in `MonitorView.handleKeyDown` reds
//  `aKeyForAnotherWindowIsNeitherEatenNorActedOn`; dropping the step rider in
//  `DivideWSheet.stepCut` (`return true` regardless of movement) reds
//  `aStepThatCannotMoveTheCutIsNotEaten`.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The divide sheet's placement keys belong to its window (18f ladder R1-1)", .serialized)
struct DivideKeyMonitorTests {
    /// ASYNC-POLL, never sync RunLoop pumping (the environment traps' rule).
    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 6) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// A two-take block, the ceremony opened on it, and the sheet mounted in
    /// a window of its own (exactly as `DivideCeremonyCostTests` mounts it).
    private func openSheet(
        _ h: EditorHarness
    ) async throws -> (window: NSWindow, hosting: NSHostingView<DivideWSheet>, ceremony: DivideWCeremony) {
        let slots = try h.storeSlots()
        let first = try #require(slots.first)
        let second = try h.session.operations.branchVariant(
            first.blockID, from: try #require(first.variantID))
        try h.session.operations.autosave(
            second.id, text: "A wholly different second take of this block.", charDelta: 0)
        try h.reload()
        h.textView.setSelectedRange(NSRange(location: 15, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor, ceremony: true)
        let state = try #require(h.model.divideWCeremony, "the ceremony opened")
        let ceremony = h.model.divideWCeremonyController

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 960, height: 700),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: DivideWSheet(ceremony: ceremony, presented: state))
        hosting.frame = NSRect(x: 0, y: 0, width: 960, height: 700)
        window.contentView = hosting
        await settle(window, hosting)
        return (window, hosting, ceremony)
    }

    private func findMonitor(in view: NSView) -> CeremonyKeyMonitor.MonitorView? {
        if let found = view as? CeremonyKeyMonitor.MonitorView { return found }
        for subview in view.subviews {
            if let found = findMonitor(in: subview) { return found }
        }
        return nil
    }

    private func otherWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// A real key event, addressed to a window by NUMBER — what the event
    /// actually carries (`PaneFocusCatcher`'s reason).
    private func key(
        _ keyCode: UInt16, for window: NSWindow, modifiers: NSEvent.ModifierFlags = []
    ) throws -> NSEvent {
        let characters = keyCode == 123 ? "\u{F702}" : (keyCode == 124 ? "\u{F703}" : "\t")
        return try #require(NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers,
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode))
    }

    /// **THE FINDING'S OWN PIN.** A → addressed to another window is neither
    /// consumed nor acted on; the same → addressed to the sheet's window is
    /// both — so the pin cannot go vacuous on a monitor that simply never
    /// answers.
    @Test func aKeyForAnotherWindowIsNeitherEatenNorActedOn() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (window, hosting, ceremony) = try await openSheet(h)
            defer { window.orderOut(nil); window.close() }
            let monitor = try #require(findMonitor(in: hosting), "the sheet installed its monitor view")
            #expect(monitor.isWatching, "…and it is watching its window")
            let other = otherWindow()
            defer { other.orderOut(nil); other.close() }
            #expect(other.windowNumber != window.windowNumber, "non-vacuity: two windows")

            let before = try #require(ceremony.state?.seedTake?.cut)

            #expect(monitor.handleKeyDown(try key(124, for: other)) == false,
                    "another window's → is not the sheet's")
            #expect(ceremony.state?.seedTake?.cut == before, "…and the ✂ did not move")

            #expect(monitor.handleKeyDown(try key(124, for: window)) == true,
                    "the sheet's own → is consumed")
            let after = try #require(ceremony.state?.seedTake?.cut)
            #expect(after > before, "…and the ✂ stepped forward one word (\(before) → \(after))")
        }
    }

    /// A ⌘ or ⌃ chord is never the sheet's — the vocabulary is ⇥/⇧⇥, ←/→ and
    /// ⌥←/→, and a chord that happens to carry an arrow belongs to whatever
    /// bound it.
    @Test func aCommandChordIsNeverTheSheets() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (window, hosting, ceremony) = try await openSheet(h)
            defer { window.orderOut(nil); window.close() }
            let monitor = try #require(findMonitor(in: hosting))
            let before = try #require(ceremony.state?.seedTake?.cut)

            #expect(monitor.handleKeyDown(try key(124, for: window, modifiers: [.command])) == false)
            #expect(monitor.handleKeyDown(try key(123, for: window, modifiers: [.control])) == false)
            #expect(ceremony.state?.seedTake?.cut == before)

            // ⌥→ IS the sheet's (a sentence step) — the chord rule refuses
            // only ⌘ and ⌃.
            #expect(monitor.handleKeyDown(try key(124, for: window, modifiers: [.option])) == true)
            #expect(ceremony.state?.seedTake?.cut != before)
        }
    }

    /// **The implementer's rider (R1-1):** the swallow follows the STEP. A →
    /// at a take's very end cannot move the ✂ and is passed on, not eaten;
    /// a ← from there moves it and is consumed.
    @Test func aStepThatCannotMoveTheCutIsNotEaten() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (window, hosting, ceremony) = try await openSheet(h)
            defer { window.orderOut(nil); window.close() }
            let monitor = try #require(findMonitor(in: hosting))
            let seed = try #require(ceremony.state?.seedTake)
            let end = seed.variant.workingText.utf16.count
            ceremony.placeCut(takeID: seed.id, cut: end)
            #expect(ceremony.state?.seedTake?.parkedAtEnd == true, "non-vacuity: parked at the end")

            #expect(monitor.handleKeyDown(try key(124, for: window)) == false,
                    "→ at the end moves nothing and is not eaten")
            #expect(ceremony.state?.seedTake?.cut == end)

            #expect(monitor.handleKeyDown(try key(123, for: window)) == true,
                    "← from the end moves the ✂ and is consumed")
            #expect((ceremony.state?.seedTake?.cut ?? end) < end)
        }
    }

    /// The monitor leaves with its view: once the sheet is out of its window
    /// nothing is watching — the lifecycle `PageTurnKeyMonitor` established.
    @Test func theMonitorLeavesWithItsWindow() async throws {
        try await withEditor(seedBlocks: ["First alpha. First omega."]) { h in
            let (window, hosting, _) = try await openSheet(h)
            let monitor = try #require(findMonitor(in: hosting))
            #expect(monitor.isWatching)
            window.contentView = nil
            await settle(window, hosting, turns: 2)
            #expect(!monitor.isWatching, "out of the window, the monitor is gone")
            window.orderOut(nil)
            window.close()
        }
    }
}
