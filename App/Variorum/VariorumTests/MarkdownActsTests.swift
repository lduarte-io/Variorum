//
//  MarkdownActsTests.swift
//  VariorumTests
//
//  Phase 13g, batch 3 (L8 + L9's ruled half) — the formatting acts' FACES.
//  The edit arithmetic is pinned in the core suite (`MarkdownEditingTests`);
//  what is pinned here is everything that only exists in the app: the
//  registry declarations, the acts riding the REAL editing pipeline into the
//  store (so a formatting act is provably an ordinary edit, not a second
//  write path), the claim that they can never restructure a note, the
//  targeting rule, and the checkbox click's hit test through a real surface.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Markdown formatting acts (13g batch 3 — L8/L9)")
struct MarkdownActsTests {

    /// In the DECLARED ORDER — the rendered-submenu pin compares its rows
    /// against this list, so the order is part of the claim. (13g batch 4:
    /// `.formatAddLink` joins after Inline Code.)
    private static let allFormatting: [CapabilityID] = [
        .formatBold, .formatItalic, .formatStrikethrough, .formatCode, .formatAddLink,
        .formatHeading, .formatBulletList, .formatChecklist,
    ]

    // MARK: - The declarations (P-1)

    @Test func theFormattingActsAreDeclaredWithTheirDoorsAndTheirTwoChords() {
        for id in Self.allFormatting {
            let capability = CapabilityRegistry.capability(id)
            // 13k K7: the `.bottomBar` door joined the two — her formatting
            // toolbar. The expectation is UPDATED rather than loosened: the
            // door list is the claim, and this batch changed it deliberately.
            #expect(capability.doors == [.menuBar, .contextMenu, .bottomBar])
            #expect(capability.scope == .block)
            #expect(capability.takesAccess == .native,
                    "\(id) acts on whichever surface holds the keyboard — Takes included")
            #expect(!capability.unavailableNote.isEmpty)
        }
        // The sweep's two chords, and only those two.
        #expect(CapabilityRegistry.capability(.formatBold).shortcutLabel == "⌘B")
        #expect(CapabilityRegistry.capability(.formatItalic).shortcutLabel == "⌘I")
        #expect(EditorCommands.keyEquivalent(for: .formatBold)?.0 == "b")
        #expect(EditorCommands.keyEquivalent(for: .formatBold)?.1 == .command)
        #expect(EditorCommands.keyEquivalent(for: .formatItalic)?.0 == "i")
        #expect(EditorCommands.keyEquivalent(for: .formatItalic)?.1 == .command)
        for id in [CapabilityID.formatStrikethrough, .formatCode, .formatAddLink,
                   .formatHeading, .formatBulletList, .formatChecklist] {
            #expect(CapabilityRegistry.capability(id).shortcutLabel == nil,
                    "\(id) ships menu-first — no chord was ruled and none was invented")
        }
    }

    @Test func formattingIsAvailableWhereverTextIsEditedAndGreyWhereItIsNot() {
        for mode in PostMode.allCases {
            for id in Self.allFormatting {
                #expect(CapabilityRegistry.availability(id, in: CapabilityContext(mode: mode)) == .act,
                        "\(id) in \(mode): every mode hosts a live editable surface")
            }
        }
        for id in Self.allFormatting {
            // The book-inline / spread / pool editors and a board mounted
            // outside a detail carry no mode of their own.
            #expect(CapabilityRegistry.isEnabled(
                id, in: CapabilityContext(mode: nil, writeEditorAttached: true)))
            #expect(CapabilityRegistry.isEnabled(
                id, in: CapabilityContext(mode: nil, takesBoardAttached: true)))
            // …and honestly grey at the shelf, the library, the pool.
            #expect(!CapabilityRegistry.isEnabled(id, in: CapabilityContext(mode: nil)),
                    "\(id) is grey where there is no text to format")
        }
    }

    // MARK: - The ordinary editing pipeline (the load-bearing claim)

    @Test func boldRidesTheOrdinaryPipelineAllTheWayIntoTheStore() async throws {
        try await withEditor(seedBlocks: ["say this now"]) { h in
            h.textView.setSelectedRange((h.textView.string as NSString).range(of: "this"))
            #expect(MarkdownActs.apply(.bold, to: h.textView))
            #expect(h.documentText == "say **this** now")
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.count == 1)
            #expect(slots[0].text == "say **this** now",
                    "no operation, no schema — the markers are the text (F-1)")
            // The selection keeps the words she selected, inside the markers.
            #expect(h.textView.selectedRange() == NSRange(location: 6, length: 4))
        }
    }

    /// **The safety claim, as a pin.** A formatting act's edits are
    /// line-scoped, and a line sits inside one block — so an act spanning a
    /// block seam edits BOTH blocks and restructures NEITHER. (The editor's
    /// cross-block arm would have MERGED them: the ratified merge-then-edit,
    /// made for a deliberate hand-made selection and never for a machine-
    /// driven sweep — `EditorFind` states the same rule for find-and-replace,
    /// which has to pre-check for it where this gets it by construction.)
    ///
    /// DISCRIMINATING REVERT: drop `.reversed()` from `MarkdownActs.apply`'s
    /// loop and this fails with "- on- e\ntwo" — every edit after the first
    /// lands at an offset the first one moved.
    @Test func aFormattingActAcrossABlockSeamNeverRestructuresTheNote() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            #expect(h.documentText == "one\ntwo")
            h.textView.setSelectedRange(NSRange(location: 0, length: 7))
            #expect(MarkdownActs.apply(.bullet, to: h.textView))
            #expect(h.documentText == "- one\n- two")
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.count == 2, "two blocks in, two blocks out")
            #expect(slots.map(\.text) == ["- one", "- two"])
        }
    }

    @Test func anActIsONEUndoStep() async throws {
        try await withEditor(seedBlocks: ["say this now"]) { h in
            // The editor needs its WINDOW here and only here: an NSTextView
            // finds its undo manager through the responder chain, so a
            // windowless surface has none and the grouping this pin is about
            // would be a no-op rather than a pass.
            let window = Self.window()
            defer { window.close() }
            let scrollView = try #require(h.textView.enclosingScrollView)
            scrollView.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
            window.contentView?.addSubview(scrollView)
            window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange((h.textView.string as NSString).range(of: "this"))
            #expect(MarkdownActs.apply(.bold, to: h.textView))
            #expect(h.documentText == "say **this** now")
            h.textView.undoManager?.undo()
            #expect(h.documentText == "say this now",
                    "both markers go together — ⌘Z takes back the act, never half of it")
        }
    }

    @Test func aSealedNoteRefusesFormattingWithoutTouchingAByte() async throws {
        try await withEditor(seedBlocks: ["say this now"]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            h.textView.setSelectedRange((h.textView.string as NSString).range(of: "this"))
            #expect(MarkdownActs.apply(.bold, to: h.textView) == false)
            #expect(h.documentText == "say this now")
        }
    }

    @Test func theCheckboxActMakesAListLineFromTheCaretsOwnLine() async throws {
        try await withEditor(seedBlocks: ["milk", "eggs"]) { h in
            h.textView.setSelectedRange(NSRange(location: 1, length: 0))
            #expect(MarkdownActs.apply(.checkbox, to: h.textView))
            #expect(h.documentText == "- [ ] milk\neggs")
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["- [ ] milk", "eggs"])
        }
    }

    /// **P1, through the real door.** The core suite pins that the planner
    /// scans exactly the text it is handed; this pins that the DOOR hands it
    /// only the lines the selection touches — the `MarkdownStyling.restyle`
    /// shape, and the difference between "⌘B costs the paragraph" and "⌘B
    /// costs the note".
    ///
    /// DISCRIMINATING REVERT: hand `MarkdownEditing.plan` the whole document
    /// instead of `lineRange(for:)`'s substring and this fails with a count
    /// in the tens of thousands.
    @Test func theDoorScansTheLinesItTouchesAndNotTheNote() async throws {
        let line = "the quick brown fox jumps over the lazy dog and keeps going"
        let note = Array(repeating: line, count: 260).joined(separator: "\n")
        #expect(note.utf16.count > 15_000)
        try await withEditor(seedBlocks: [note]) { h in
            h.textView.setSelectedRange((h.textView.string as NSString).range(of: "brown"))
            MarkdownScanCount.reset()
            #expect(MarkdownActs.apply(.bold, to: h.textView))
            let scanned = MarkdownScanCount.current
            #expect(scanned > 0, "the counter is live — a zero would make this hollow")
            #expect(scanned < 500,
                    "one line planned plus the face's own line rescans, never the note — scanned \(scanned) of \(note.utf16.count)")
        }
    }

    // MARK: - Targeting (it must be OUR surface, and an editable one)

    /// DISCRIMINATING REVERT: drop `view is MarkdownFormattable` from
    /// `target(in:)` and the first expectation fails — a plain editable
    /// `NSTextView` (which is what every field editor in the app is) becomes
    /// a legitimate target for ⌘B.
    @Test func theTargetIsOneOfOurSurfacesAndOnlyOneOfOurs() {
        let window = Self.window()
        defer { window.close() }

        // A field editor is an editable NSTextView too — and must never
        // receive `****` from a menu key.
        let stranger = NSTextView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
        stranger.isEditable = true
        window.contentView?.addSubview(stranger)
        window.makeFirstResponder(stranger)
        #expect(MarkdownActs.target(in: window) == nil)

        let pane = PaneTextView.makeTakeSurface()
        pane.frame = NSRect(x: 0, y: 0, width: 200, height: 40)
        pane.string = "hello"
        window.contentView?.addSubview(pane)
        pane.isEditable = false
        window.makeFirstResponder(pane)
        #expect(MarkdownActs.target(in: window) == nil, "a READ pane is not a writing surface")
        pane.isEditable = true
        window.makeFirstResponder(pane)
        #expect(MarkdownActs.target(in: window) === pane)
    }

    // MARK: - L9: the click, through a real surface's own geometry

    @Test func aClickONTheBoxTogglesItAndACaretClickIsNeverEaten() throws {
        let window = Self.window()
        defer { window.close() }
        let pane = Self.livePane("- [ ] milk", in: window)

        let onBox = try #require(Self.point(inCharacterRange: 3..<4, of: pane),
                                 "a point over the box's middle character")
        pane.setSelectedRange(NSRange(location: 9, length: 0))
        #expect(MarkdownActs.toggleCheckbox(at: onBox, in: pane))
        #expect(pane.string == "- [x] milk")
        #expect(pane.selectedRange() == NSRange(location: 9, length: 0),
                "three characters for three — the caret can simply stay")

        // …and back.
        #expect(MarkdownActs.toggleCheckbox(at: onBox, in: pane))
        #expect(pane.string == "- [ ] milk")

        // A click on the ITEM is an ordinary caret click: not consumed, and
        // nothing toggled.
        let onWord = try #require(Self.point(inCharacterRange: 7..<8, of: pane))
        #expect(MarkdownActs.toggleCheckbox(at: onWord, in: pane) == false)
        #expect(pane.string == "- [ ] milk")
    }

    @Test func aREADPanesClickStillJustFocusesIt() throws {
        let window = Self.window()
        defer { window.close() }
        let pane = Self.livePane("- [ ] milk", in: window)
        pane.isEditable = false
        let onBox = try #require(Self.point(inCharacterRange: 3..<4, of: pane))
        #expect(MarkdownActs.toggleCheckbox(at: onBox, in: pane) == false,
                "her ruling's letter: first click focuses, as today")
        #expect(pane.string == "- [ ] milk")
    }

    /// **The helper names every formatting door, keyless ones included**
    /// (13g L12). The registry drift guard is the FLOOR — it can only see
    /// acts that declare a chord, and five of these eight deliberately don't
    /// — so a door with no key would be exactly as invisible as the whole
    /// 13f workspace was (WT-1's finding). This is the ceiling.
    @Test func theHelperNamesEveryFormattingDoorIncludingTheKeylessOnes() {
        let rows = HelperView.groups.flatMap(\.items)
        for id in Self.allFormatting {
            // Case-insensitively: the helper writes in PROSE ("bold — wraps
            // the selection…"), and prose is the point of a hand-written
            // list. What is asserted is that the door is findable.
            let verb = CapabilityRegistry.capability(id).verb
            #expect(rows.contains {
                $0.keys.localizedCaseInsensitiveContains(verb)
                    || $0.does.localizedCaseInsensitiveContains(verb)
            }, "the helper (⌘/) names the \(verb) door")
        }
        // …and the two click rules, which differ by surface and so cannot be
        // inferred from the menu at all.
        #expect(rows.contains { $0.keys.contains("⌘-click") })
    }

    // MARK: - L10: the link click (13g batch 4)

    /// **The scheme guard.** A link's target is ordinary text she typed, and
    /// a click must not hand an arbitrary scheme to the workspace: `file:`
    /// reaches the disk and the custom-scheme space is every other app on the
    /// machine. v1 opens `http`/`https` and nothing else — an inert address
    /// still RENDERS as a link (the syntax is what it is) and simply does
    /// nothing when clicked.
    ///
    /// DISCRIMINATING REVERT: drop `openableSchemes.contains(scheme)` from
    /// `MarkdownLink.openable` and the whole second list below turns
    /// openable — `file:///etc/passwd` included.
    @Test func onlyHttpAndHttpsAddressesAreOpenable() {
        for raw in [
            "https://apple.com", "http://example.test/a?b=c#d",
            "  https://apple.com  ", "https://x.test/a_(b)",
        ] {
            #expect(MarkdownLink.openable(raw) != nil, "\(raw)")
        }
        for raw in [
            "file:///etc/passwd", "mailto:a@b.test", "javascript:alert(1)",
            "ftp://x.test/a", "vscode://open", "https://", "", "   ", "not a url at all",
        ] {
            #expect(MarkdownLink.openable(raw) == nil, "\(raw)")
        }
    }

    @Test func theLinkGestureIsCommandClickAndNothingElse() {
        func event(_ modifiers: NSEvent.ModifierFlags, clicks: Int = 1) -> NSEvent {
            NSEvent.mouseEvent(
                with: .leftMouseDown, location: .zero, modifierFlags: modifiers,
                timestamp: 0, windowNumber: 0, context: nil,
                eventNumber: 0, clickCount: clicks, pressure: 1)!
        }
        #expect(MarkdownActs.isLinkClick(event(.command)))
        // A plain click places the caret (and may toggle a checkbox); every
        // other modifier belongs to selection or to the system.
        #expect(!MarkdownActs.isLinkClick(event([])))
        #expect(!MarkdownActs.isLinkClick(event([.command, .shift])))
        #expect(!MarkdownActs.isLinkClick(event(.option)))
        #expect(!MarkdownActs.isLinkClick(event(.command, clicks: 2)))
    }

    /// The WIRE, through a real surface's own geometry: a point over a link
    /// resolves to its address, a point over ordinary text resolves to none.
    /// `linkAddress` rather than `openLink` deliberately — the pin exercises
    /// point → index → span without a test launching a browser.
    @Test func aPointOverALinkResolvesToItsAddressAndNowhereElseDoes() throws {
        let window = Self.window()
        defer { window.close() }
        let text = "see [the docs](https://x.test/a) now"
        let pane = Self.livePane(text, in: window)

        let onWord = try #require(
            Self.point(inCharacterRange: 6..<12, of: pane),
            "a point over the link's own words")
        #expect(MarkdownActs.linkAddress(at: onWord, in: pane) == "https://x.test/a")

        // The dimmed `(url)` is visibly part of the link, so it opens too —
        // unlike the checkbox click, this gesture carries a modifier and
        // competes with nothing.
        let onAddress = try #require(Self.point(inCharacterRange: 20..<28, of: pane))
        #expect(MarkdownActs.linkAddress(at: onAddress, in: pane) == "https://x.test/a")

        let outside = try #require(Self.point(inCharacterRange: 0..<3, of: pane))
        #expect(MarkdownActs.linkAddress(at: outside, in: pane) == nil)
    }

    /// Opening a link is NOT an edit, so a read pane and a sealed editor
    /// follow one exactly like a live editor does (the checkbox click is the
    /// opposite: it writes, so it is gated on `isEditable`).
    @Test func aREADPaneFollowsALinkEvenThoughItRefusesEveryEdit() throws {
        let window = Self.window()
        defer { window.close() }
        let pane = Self.livePane("see [the docs](https://x.test/a) now", in: window)
        pane.isEditable = false
        let onWord = try #require(Self.point(inCharacterRange: 6..<12, of: pane))
        #expect(MarkdownActs.linkAddress(at: onWord, in: pane) == "https://x.test/a")
    }

    // MARK: - The context-menu door

    @Test func theFormatSubmenuIsRenderedOnlyWhereTheSurfaceCanBeEdited() throws {
        let window = Self.window()
        defer { window.close() }
        let pane = Self.livePane("hello", in: window)

        pane.isEditable = false
        #expect(MarkdownActs.formatMenuItem(for: pane) == nil,
                "a door that can never act here is not rendered (P-2)")

        pane.isEditable = true
        let item = try #require(MarkdownActs.formatMenuItem(for: pane))
        let submenu = try #require(item.submenu)
        #expect(submenu.items.map(\.title)
                == Self.allFormatting.map { CapabilityRegistry.capability($0).verb },
                "the rows are the registry's verbs, in the declared order")
        let heading = try #require(submenu.items.first { $0.title == "Heading" })
        #expect(heading.submenu?.items.map(\.title) == ["Heading 1", "Heading 2", "Heading 3"])
    }

    // MARK: - Fixtures

    private static func window() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        window.makeKeyAndOrderFront(nil)
        return window
    }

    private static func livePane(_ text: String, in window: NSWindow) -> PaneTextView {
        let pane = PaneTextView.makeTakeSurface()
        pane.frame = NSRect(x: 0, y: 0, width: 400, height: 60)
        window.contentView?.addSubview(pane)
        pane.string = text
        pane.isEditable = true
        window.layoutIfNeeded()
        window.display()
        _ = PaneMeasurement.height(of: pane)  // force TK2 to lay the line out
        return pane
    }

    /// A point in `view` whose INSERTION INDEX lands inside `range` — found
    /// from the surface's own geometry rather than from a font metric, so the
    /// pin exercises the wire a real click travels (point → insertion index →
    /// the hit test) instead of re-deriving it.
    private static func point(inCharacterRange range: Range<Int>, of view: NSTextView) -> NSPoint? {
        let inset = view.textContainerInset
        var x = inset.width
        while x < view.bounds.width - inset.width {
            let candidate = NSPoint(x: x, y: inset.height + 4)
            let index = view.characterIndexForInsertion(at: candidate)
            if range.contains(index) { return candidate }
            x += 0.5
        }
        return nil
    }
}
