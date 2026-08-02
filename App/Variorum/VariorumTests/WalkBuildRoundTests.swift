//
//  WalkBuildRoundTests.swift
//  VariorumTests
//
//  Phase 13k, batch 1 — the Mac-side pins for the fully-ruled set:
//  **K3** (tag chips show the LEAF), **K5** (⏎ continues a list) and
//  **K6** (the right-click callout door). K1/K2 are Domain + read-side and
//  are pinned in core (`DisplayTitleTests`); their app-side wiring rides
//  `NodSetTests`' chrome pin.
//

import AppKit
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - K3: a chip says the LEAF, and keeps the path's colour

/// Her ruling, 2026-08-02: *"chips should show leaf only"* — the alternative
/// QUESTIONS #52(e) recorded, now taken. The colour is deliberately NOT
/// narrowed with the label.
@MainActor
@Suite("K3 — tag chips show the leaf (13k)")
struct TagChipLeafTests {
    @Test func aChipsLabelIsTheLastSegmentOfItsPath() {
        #expect(TagChipLabel.leaf(of: "life/goals/2024") == "2024")
        #expect(TagChipLabel.leaf(of: "life") == "life")
        #expect(TagChipLabel.leaf(of: "a/b") == "b")
    }

    /// A chip must never be blank: a degenerate path reads as itself.
    @Test func aDegeneratePathReadsAsItselfRatherThanAsNothing() {
        #expect(TagChipLabel.leaf(of: "") == "")
        #expect(TagChipLabel.leaf(of: "life/") == "life")
        #expect(TagChipLabel.leaf(of: "/") == "/")
    }

    /// **The half that must NOT change with it.** Two tags whose leaves are
    /// identical still wear different colours, because the colour is keyed
    /// on the whole path — which is exactly why leaf-only labels are safe.
    ///
    /// DISCRIMINATING REVERT (verified): key `TagChipColor.hue` on
    /// `TagChipLabel.leaf(of: path)` instead of the path and the first
    /// expectation fails — `life/goals` and `work/goals` become one colour.
    @Test func theCOLOURStaysKeyedOnTheWHOLEPath() {
        #expect(TagChipColor.hue(forPath: "life/goals")
                != TagChipColor.hue(forPath: "work/goals"))
        // …and is stable, which is what "same tag, same colour, forever"
        // means (the 9d never-re-ripple family).
        #expect(TagChipColor.hue(forPath: "life/goals")
                == TagChipColor.hue(forPath: "life/goals"))
    }
}

// MARK: - K6: the right-click callout door

/// Her report, 2026-08-01: she went looking for callouts in the RIGHT-CLICK
/// and they were not there. The act is unchanged (13c R2-2's routed
/// transform); what this adds is a door and a declaration.
@MainActor
@Suite("K6 — the right-click callout door (13k)", .serialized)
struct CalloutContextMenuTests {
    /// P-1: the door is DECLARED, so the registry walk covers it — and the
    /// menu-bar door it joins is untouched.
    @Test func theCalloutCapabilityDeclaresTheContextMenuDoor() {
        let capability = CapabilityRegistry.capability(.callout)
        #expect(capability.doors.contains(.contextMenu))
        #expect(capability.doors.contains(.menuBar))
        #expect(capability.shortcutLabel == "⌥⌘C")
    }

    /// ONE vocabulary, three renderers — the `MarkdownActs.rows` pattern.
    /// The rows carry the toggle, the five palette colours, the emoji prompt
    /// and the remove row, in that order.
    @Test func theRowsAreOneVocabularyTheThreeDoorsShare() {
        let titles = CalloutMenu.rowTitles
        #expect(titles.first == "Toggle Callout")
        #expect(titles.last == "Remove Callout")
        #expect(titles.contains("Emoji…"))
        for name in CalloutPalette.names {
            #expect(titles.contains(name.capitalized))
        }
        #expect(titles.count == CalloutPalette.names.count + 3)
        // Exactly one row prompts, and it carries no edit of its own.
        let prompting = CalloutMenu.rows.filter(\.promptsForEmoji)
        #expect(prompting.count == 1)
        #expect(prompting[0].edit == nil)
    }

    /// **The pin that is RED on the pre-13k code:** Write's own context menu
    /// carries a "Callout" submenu, whose rows are the shared vocabulary.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `calloutMenuItem` wiring
    /// from `EditorViewModel.attach` and this test fails at its `#require` —
    /// the right-click has a Format submenu and no Callout one, which is
    /// exactly the state she reported.
    @Test func theEditorsRightClickCarriesTheCalloutSubmenu() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let event = NSEvent.mouseEvent(
                with: .rightMouseDown, location: NSPoint(x: 20, y: 20),
                modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
                eventNumber: 0, clickCount: 1, pressure: 1)!
            let menu = try #require(h.textView.menu(for: event))
            let callout = try #require(
                menu.items.first { $0.title == CalloutMenu.title },
                "the right-click must offer the Callout submenu (K6)")
            let submenu = try #require(callout.submenu)
            let rendered = submenu.items.filter { !$0.isSeparatorItem }.map(\.title)
            #expect(rendered == CalloutMenu.rowTitles)
            // It sits BESIDE Format, which stays exactly as it was.
            #expect(menu.items.contains { $0.title == MarkdownActs.menuTitle })
        }
    }

    /// The submenu ACTS — one click dispatches the row's edit through the
    /// caller's own route (P-2: a rendered door performs the act). Driven
    /// through the real `NSMenuItem` target, which is where the trampoline
    /// pattern's retention could silently fail.
    @Test func clickingARowDispatchesThatRowsEdit() throws {
        var seen: [CalloutEdit] = []
        let item = CalloutMenu.menuItem { seen.append($0) }
        let submenu = try #require(item.submenu)
        let rows = submenu.items.filter { !$0.isSeparatorItem }

        let toggle = try #require(rows.first { $0.title == "Toggle Callout" })
        _ = toggle.target?.perform(toggle.action, with: toggle)
        let green = try #require(rows.first { $0.title == "Green" })
        _ = green.target?.perform(green.action, with: green)
        let remove = try #require(rows.first { $0.title == "Remove Callout" })
        _ = remove.target?.perform(remove.action, with: remove)

        #expect(seen == [.toggle, .color("green"), .color(nil)])
    }

    /// The registry walk's own union already covers the new door; this names
    /// the two renderers explicitly so a future edit that drops one from a
    /// surface fails with its name rather than by set arithmetic.
    @Test func bothTextSurfacesDeclareTheDoorTheyRender() {
        #expect(EditorViewModel.contextMenuCapabilities.contains(.callout))
        #expect(TakesCellView.contextMenuCapabilities.contains(.callout))
    }
}

// MARK: - K5: ⏎ continues a list

/// Her ruling: *⏎ at the end of a texted list line mints the next lead; ⏎ on
/// an EMPTY list item removes the lead and exits the list.*
///
/// Every pin here drives a REAL Return key event through the real AppKit
/// interpretation path (the `ReturnKeyTraceTests` discipline — the whole
/// question is what the KEY does), because the continuation's safety claim
/// is precisely that `super.insertNewline` runs unchanged underneath it.
@MainActor
@Suite("K5 — ⏎ continues a list (13k)", .serialized)
struct ListContinuationTests {
    private static func returnEvent(shift: Bool, windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero,
            modifierFlags: shift ? .shift : [], timestamp: 0,
            windowNumber: windowNumber, context: nil,
            characters: "\r", charactersIgnoringModifiers: "\r",
            isARepeat: false, keyCode: 36)!
    }

    private static func host(_ view: NSView) -> (window: NSWindow, teardown: () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        return (window, {
            window.orderOut(nil)
            window.close()
        })
    }

    /// A texted bullet mints the next bullet, and the caret lands after it.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `.continueList` arm's lead
    /// insertion from `MarkdownActs.insertNewlineContinuingLists` and this
    /// test fails with `"- milk\n"` — the newline lands, the lead does not.
    @Test func aTextedBulletMintsTheNextLead() async throws {
        // MID-BLOCK deliberately (the document end is its own pin below, and
        // there the tail gesture owns the keystroke): one block whose text
        // already carries a second line, caret at the end of the first.
        try await withEditor(seedBlocks: ["- milk\nsecond"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- milk\n- \nsecond")
            #expect(h.textView.selectedRange().location == 9)
            // I4: the newline and the lead are the block's CONTENT — the
            // structure is untouched, and one block is still one block.
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- \nsecond"])
        }
    }

    /// A checklist item continues UNCHECKED (QUESTIONS #49(h)'s rule:
    /// checking is the click).
    @Test func aTextedChecklistItemMintsAnUncheckedBox() async throws {
        try await withEditor(seedBlocks: ["- [x] milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 10, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- [x] milk\n- [ ] ")
        }
    }

    /// The exit half — the ONE place the keystroke is consumed: the lead
    /// goes and NO newline is inserted.
    ///
    /// DISCRIMINATING REVERT (verified): make the `.exitList` arm fall
    /// through to `ordinary()` and this test fails with `"- milk\n- \n"` —
    /// the empty item survives and the list never ends.
    @Test func anEmptyListItemExitsTheListWithoutMakingALine() async throws {
        try await withEditor(seedBlocks: ["- milk\n- "]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 9, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- milk\n")
            #expect(try h.storeSlots().map(\.text) == ["- milk\n"])
        }
    }

    /// **The ratified gesture is BYTE-UNTOUCHED.** ⏎ at the exact document
    /// end still opens the tail (Phase 7's ruling) — and because the lead is
    /// a second, ordinary insertion at the caret the newline left, it lands
    /// in the tail as ordinary tail text rather than changing what the
    /// keystroke meant.
    @Test func theDocumentEndTailGestureStillFiresAndTheLeadLandsInTheTail() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))

            #expect(h.model.hasOpenTail, "the ratified open-tail gesture still fires")
            #expect(h.model.index.entries.count == 1)
            #expect(h.documentText == "- milk\n- ")
            // Surface-only: nothing minted, exactly as before.
            #expect(try h.storeSlots().map(\.text) == ["- milk"])
        }
    }

    /// `one_block`'s newlines-don't-mint is untouched: the newline AND the
    /// lead are content of the one block.
    @Test func oneBlockKeepsBothTheNewlineAndTheLeadAsContent() async throws {
        try await withEditor(profile: .journal, seedBlocks: ["- milk"]) { h in
            #expect(h.model.header?.effectiveSegmentation == .oneBlock)
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail)
            #expect(try h.storeSlots().map(\.text) == ["- milk\n- "])
        }
    }

    /// **⇧⏎ is a different gesture and stays byte-identical** (A15): its
    /// newline lands inside the block and NO lead follows it.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `isSoftNewline` guard from
    /// `EditorTextView.insertNewline` and this test fails with
    /// `"- milk\n- "` — ⇧⏎ starts sprouting bullets.
    @Test func shiftReturnNeverContinuesTheList() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail)  // A15/B1, unchanged
            #expect(h.documentText == "- milk\n")
            #expect(try h.storeSlots().map(\.text) == ["- milk\n"])
        }
    }

    /// A SEALED note refuses the whole keystroke in its own words, with no
    /// new refusal code — the lead rides the same `shouldChangeText` verdict
    /// the newline does, so a refused newline can never be led.
    @Test func aSealedNoteRefusesTheContinuationWithoutTouchingAByte() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            _ = try h.session.operations.lockPost(h.postID)
            try h.reload()
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "- milk")
            #expect(try h.storeSlots().map(\.text) == ["- milk"])
        }
    }

    /// **⌘Z takes back the keystroke she pressed, not half of it** — the
    /// brief's own edge, pinned as BEHAVIOUR.
    ///
    /// **REVERT MEASURED, AND IT DOES NOT DISCRIMINATE — recorded rather
    /// than claimed (13k batch 1, revert G).** Dropping the explicit
    /// `beginUndoGrouping`/`endUndoGrouping` pair around the newline and the
    /// lead leaves this test GREEN, because `NSUndoManager.groupsByEvent` is
    /// on by default: both edits happen inside ONE key event, so AppKit's
    /// own per-event group already contains them. The explicit group is
    /// therefore redundant TODAY and is kept deliberately — it states the
    /// intent at the one place that owns it and does not depend on an AppKit
    /// default staying true — but this pin proves the BEHAVIOUR, not that
    /// mechanism, and the hallucination guard says say so.
    @Test func oneUndoTakesBackBothTheNewlineAndTheLead() async throws {
        try await withEditor(seedBlocks: ["- milk"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 6, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            #expect(h.documentText == "- milk\n- ")

            let undoManager = try #require(h.textView.undoManager)
            undoManager.undo()
            #expect(h.documentText == "- milk")
        }
    }

    /// Ordinary prose is untouched — the door only ever fires on a list
    /// line, which is what keeps ⏎ the keystroke it always was everywhere
    /// else in the app.
    @Test func plainProseIsUnaffected() async throws {
        try await withEditor(seedBlocks: ["alpha beta"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 5, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(h.documentText == "alpha\n beta")
            #expect(try h.storeSlots().map(\.text) == ["alpha\n beta"])
        }
    }

    /// A take pane gets the same rule (R118 — Write is never privileged over
    /// Takes), and its ⇧⏎ is excluded the same way.
    @Test func aTakePaneContinuesListsToo() throws {
        let view = PaneTextView.makeTakeSurface()
        view.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
        view.isEditable = true
        let hosted = Self.host(view)
        defer { hosted.teardown() }
        hosted.window.makeFirstResponder(view)

        view.string = "- milk"
        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(
            with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n- ")

        // The empty item exits.
        view.keyDown(
            with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n")

        // ⇧⏎ stays a plain newline.
        view.string = "- milk"
        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(
            with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
        #expect(view.string == "- milk\n")
    }
}
