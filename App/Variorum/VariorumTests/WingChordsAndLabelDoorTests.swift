//
//  WingChordsAndLabelDoorTests.swift
//  VariorumTests
//
//  VX-648 batch 3 — two wing doors, both ⌘L's family, both through roads that
//  already exist:
//
//  · VX-632 (her ruling at the VX-620 bundle sitting, #245 RB-6, 2026-10-27:
//    BOTH chords — "⌥⌘L Move to Wing… and ⇧⌥⌘L Copy to Wing…", the deliberate
//    ⌥ variants of ⌘L): the View menu's two items over VX-377's keyboard
//    selector, under the ⌘K rows' own gates. ⌥⌘L is ONE item serving the
//    note's Move on a note pane and the book's on a book pane (`WingChords`;
//    A-648-7). A grey chord SPEAKS (`OneWingChord` — W-UX-6 generalized).
//  · VX-644 (her word 2026-10-28: "the wing swap is not there and it is
//    supposed to be" — VX-552's remainder): the "in ‹wing›" label — the
//    toolbar's beside New Note and both quick-entry bars' — IS the wing
//    switcher's door: ⌘L's own act in its window (`ShellActions
//    .openWingSwitcher`), with one wing ⌘L's ruled note spoken.
//
//  Red on old by construction: the chords, `WingChords`, `openWingSwitcher`
//  and the label's door did not exist (VX-377's own pin said "no chord — RB-6
//  is her call", flipped deliberately in `WingPaletteDoorsTests`). The
//  composition halves read the sources (a menu bar and a toolbar cannot be
//  mounted headlessly — `QuickEntryWingLabelTests`' precedent); the press and
//  the look are the walk's.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-632 / VX-644 — ⌘L's family: the wing chords and the wing label's door", .serialized)
struct WingChordsAndLabelDoorTests {
    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 632))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func source(_ path: String) throws -> String {
        try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/\(path)"),
            encoding: .utf8)
    }

    /// A REAL key event (the W-UX-6 pin's road): L is virtual key 37.
    private func keyL(_ flags: CGEventFlags) throws -> NSEvent {
        let cg = try #require(CGEvent(keyboardEventSource: nil, virtualKey: 37, keyDown: true))
        cg.flags = flags
        return try #require(NSEvent(cgEvent: cg))
    }

    private static let moveLabel = "\u{2325}\u{2318}L"
    private static let copyLabel = "\u{21E7}\u{2325}\u{2318}L"

    // MARK: - VX-632 · the registry (P-1)

    /// The three acts carry the `.menuBar` door, the menu renders them, the
    /// chords are declared and wired ONCE each — ⌥⌘L on the note's Move (the
    /// one item's key; the book's Move reaches it through that item by focus
    /// and wears no label, so the key table keeps one owner per chord), ⇧⌥⌘L
    /// on the Copy — no other act maps either (RB-6's sweep as a pin), and the
    /// helper (⌘/) shows both.
    @Test func theChordsAreDeclaredWiredFreeAndShown() {
        let move = CapabilityRegistry.capability(.moveNoteToWing)
        #expect(move.doors.contains(.menuBar) && move.shortcutLabel == Self.moveLabel, "the note's Move owns ⌥⌘L")
        let moveKey = EditorCommands.keyEquivalent(for: .moveNoteToWing)
        #expect(moveKey?.0 == "l" && moveKey?.1 == [.command, .option])
        let book = CapabilityRegistry.capability(.moveBookToWing)
        #expect(book.doors.contains(.menuBar), "the book's Move is the same item's act")
        #expect(book.shortcutLabel == nil && EditorCommands.keyEquivalent(for: .moveBookToWing) == nil,
                "one owner per chord — the item's key is the note act's")
        #expect(WingChords.acts(.move) == [.moveNoteToWing, .moveBookToWing], "the one item serves both")
        let copy = CapabilityRegistry.capability(.copyNoteToWing)
        #expect(copy.doors.contains(.menuBar) && copy.shortcutLabel == Self.copyLabel)
        let copyKey = EditorCommands.keyEquivalent(for: .copyNoteToWing)
        #expect(copyKey?.0 == "l" && copyKey?.1 == [.command, .option, .shift])
        #expect(Set(EditorCommands.menuRendered).isSuperset(of: [.moveNoteToWing, .moveBookToWing, .copyNoteToWing]))
        // THE SWEEP, as a pin: nothing else maps either chord.
        let wingActs: Set<CapabilityID> = [.moveNoteToWing, .moveBookToWing, .copyNoteToWing]
        for id in CapabilityID.allCases where !wingActs.contains(id) {
            guard let other = EditorCommands.keyEquivalent(for: id) else { continue }
            #expect(!(other.0 == "l" && other.1 == [.command, .option]), "\(id) collides with ⌥⌘L")
            #expect(!(other.0 == "l" && other.1 == [.command, .option, .shift]), "\(id) collides with ⇧⌥⌘L")
        }
        #expect(HelperView.shortcutKeysShown.isSuperset(of: [Self.moveLabel, Self.copyLabel]),
                "the helper (⌘/) shows both chords")
        // The menu face's words (A-648-7): the verb + the ellipsis, derived.
        #expect(WingCopy.menuTitle(copy.verb) == "Copy to Wing\u{2026}")
        #expect(WingCopy.menuTitle(CapabilityRegistry.capability(.moveNoteToWing).verb) == "Move to Wing\u{2026}")
        #expect(CapabilityRegistry.capability(.moveNoteToWing).verb == "Move to Wing",
                "every non-menu face keeps the bare verb")
    }

    /// ONE Move item, two acts, by focus — and its enablement is exactly the
    /// focused pane's act's registry gate (the ⌘K rows' gates).
    @Test func oneMoveItemServesTheNoteAndTheBookByFocus() {
        #expect(WingChords.act(.move, showing: .post("n")) == .moveNoteToWing)
        #expect(WingChords.act(.move, showing: .reading("b")) == .moveBookToWing)
        #expect(WingChords.act(.move, showing: .shelf) == .moveNoteToWing)
        #expect(WingChords.act(.move, showing: nil) == .moveNoteToWing)
        #expect(WingChords.act(.copy, showing: .post("n")) == .copyNoteToWing)
        #expect(WingChords.act(.copy, showing: .reading("b")) == .copyNoteToWing,
                "a book has no copy door — the note's act answers (and refuses)")
        func enabled(_ chord: WingChords.Chord, note: Bool = false, book: Bool = false, wings: Int) -> Bool {
            let context = CapabilityContext(focusedPaneShowsNote: note, focusedPaneShowsBook: book, wingCount: wings)
            return WingChords.enabled(chord) { CapabilityRegistry.isEnabled($0, in: context) }
        }
        #expect(enabled(.move, note: true, wings: 2) && enabled(.copy, note: true, wings: 2), "a note pane, two wings")
        #expect(enabled(.move, book: true, wings: 2), "a book pane: the book's Move")
        #expect(!enabled(.copy, book: true, wings: 2), "a book pane: no copy")
        #expect(!enabled(.move, note: true, wings: 1) && !enabled(.copy, note: true, wings: 1), "one wing")
        #expect(!enabled(.move, book: true, wings: 1), "one wing, a book")
        #expect(!enabled(.move, wings: 3) && !enabled(.copy, wings: 3), "a place — nothing to move")
    }

    /// The chord's act is the ⌘K rows' own road (`openWingDestination`): the
    /// selector's request for the focused note or book, or the act's note.
    @Test func theChordOpensTheSelectorThroughTheRowsRoad() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let note = try ops.createPost(title: "moving note")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            let wings = WingsModel(session: session)
            await wings.load()
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            shell.workspace.select(.post(note.id))
            actions.wingChord(.move)
            #expect(shell.wingDestinationRequest == nil, "one wing: no selector")
            #expect(session.status.spoken?.kind == .refusal)
            session.status.clear()

            _ = try ops.createWing(name: "Work")
            await wings.load()
            actions.wingChord(.move)
            #expect(shell.wingDestinationRequest?.act == .moveNote(note.id))
            actions.wingChord(.copy)
            #expect(shell.wingDestinationRequest?.act == .copyNote(note.id))
            #expect(session.status.spoken == nil, "nothing to say — the selector opens")

            shell.wingDestinationRequest = nil
            shell.workspace.select(.reading(book.id))
            actions.wingChord(.move)
            #expect(shell.wingDestinationRequest?.act == .moveBook(book.id), "a book pane: the book's Move")
            shell.wingDestinationRequest = nil
            actions.wingChord(.copy)
            #expect(shell.wingDestinationRequest == nil, "a book has no copy")
            #expect(session.status.spoken?.text == CapabilityRegistry.capability(.copyNoteToWing).unavailableNote)
        }
    }

    /// **A grey chord SPEAKS** (W-UX-6's rule, `OneWingChord` generalized —
    /// A-648-7): with one wing ⌘L's ruled note; with more and nothing to act
    /// on, the note act's own note; an ENABLED chord passes to the menu
    /// untouched. Fed REAL events.
    @Test func aGreyChordSpeaksAndAnEnabledOnePassesOn() async throws {
        let move = try keyL([.maskCommand, .maskAlternate])
        let copy = try keyL([.maskCommand, .maskAlternate, .maskShift])
        let controlled = try keyL([.maskCommand, .maskAlternate, .maskControl])
        try await withWorld { session, _ in
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(session.wing.wingCount == 1)
            #expect(WingChords.chord(charactersIgnoringModifiers: move.charactersIgnoringModifiers,
                                     flags: move.modifierFlags) == .move)
            #expect(WingChords.chord(charactersIgnoringModifiers: copy.charactersIgnoringModifiers,
                                     flags: copy.modifierFlags) == .copy)
            #expect(!OneWingChord.speak(controlled, session: session), "⌃⌥⌘L is no chord of ours")

            // One wing, a note in the pane: both chords grey → both speak ⌘L's note.
            session.commandRouter.focusedPaneShowsNote = { true }
            for event in [move, copy] {
                #expect(OneWingChord.speak(event, session: session), "consumed — grey, and answered")
                #expect(session.status.spoken?.text == WingCopy.switchWingUnavailable)
                #expect(session.status.spoken?.kind == .refusal)
                session.status.clear()
            }

            _ = try Operations().createWing(name: "Work")
            await wings.load()
            #expect(session.wing.wingCount == 2)
            // Two wings, a note in the pane: both chords are the menu's.
            #expect(!OneWingChord.speak(move, session: session) && !OneWingChord.speak(copy, session: session))
            #expect(session.status.spoken == nil)
            // A book in the pane: Move is the menu's, Copy speaks the note's note.
            session.commandRouter.focusedPaneShowsNote = { false }
            session.commandRouter.focusedPaneShowsBook = { true }
            #expect(!OneWingChord.speak(move, session: session))
            #expect(OneWingChord.speak(copy, session: session))
            #expect(session.status.spoken?.text == WingCopy.noteUnavailableNote)
            session.status.clear()
            // A place: both speak the note's note.
            session.commandRouter.focusedPaneShowsBook = { false }
            #expect(OneWingChord.speak(move, session: session))
            #expect(session.status.spoken?.text == WingCopy.noteUnavailableNote)
        }
    }

    /// The View menu renders the two items exactly: the menu titles, the
    /// chords, the registry gate, the shell's chord act.
    @Test func theViewMenuRendersBothItemsUnderTheirGates() throws {
        let menu = try source("EditorCommands.swift")
        let moveItem = try #require(menu.range(of: "Button(WingCopy.menuTitle(verb(.moveNoteToWing))) { actions?.wingChord(.move) }"))
        let moveTail = String(menu[moveItem.upperBound...].prefix(240))
        #expect(moveTail.contains(".keyboardShortcut(\"l\", modifiers: [.command, .option])"))
        #expect(moveTail.contains(".disabled(!WingChords.enabled(.move, isEnabled: enabled))"))
        let copyItem = try #require(menu.range(of: "Button(WingCopy.menuTitle(verb(.copyNoteToWing))) { actions?.wingChord(.copy) }"))
        let copyTail = String(menu[copyItem.upperBound...].prefix(240))
        #expect(copyTail.contains(".keyboardShortcut(\"l\", modifiers: [.command, .option, .shift])"))
        #expect(copyTail.contains(".disabled(!WingChords.enabled(.copy, isEnabled: enabled))"))
        // Beside ⌘L — after Switch Wing… in the same group.
        let switchItem = try #require(menu.range(of: "Button(verb(.switchWing))"))
        #expect(switchItem.upperBound < moveItem.lowerBound && moveItem.upperBound < copyItem.lowerBound)
    }

    // MARK: - VX-644 · the label IS the switcher's door

    @Test func theLabelIsADeclaredSurfaceDoorOfSwitchWing() {
        #expect(CapabilityRegistry.capability(.switchWing).doors.contains(.surface))
        #expect(RootView.surfaceCapabilities.contains(.switchWing), "the toolbar's label")
        #expect(QuickEntryBar.surfaceCapabilities == [.switchWing], "both quick-entry bars' label")
    }

    /// The press is ⌘L's own act in its window: the switcher's request (the
    /// window adopts it and presents ⌘L's sheet — `RootView`'s one
    /// `wingSwitcherRequested` road), or with ONE wing ⌘L's note spoken.
    @Test func theLabelsPressIsCommandLsOwnAct() async throws {
        try await withWorld { session, _ in
            let wings = WingsModel(session: session)
            await wings.load()
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            actions.openWingSwitcher()
            #expect(!shell.wingSwitcherRequested, "one wing: no switcher — nothing to switch to")
            #expect(session.status.spoken?.text == CapabilityRegistry.capability(.switchWing).unavailableNote)
            #expect(session.status.spoken?.kind == .refusal, "said as ⌘L says it")
            session.status.clear()

            _ = try Operations().createWing(name: "Work")
            await wings.load()
            actions.openWingSwitcher()
            #expect(shell.wingSwitcherRequested, "two wings: ⌘L's sheet, asked of this window")
            #expect(session.status.spoken == nil)
        }
    }

    /// Every label renders the door, and the hosts hand it the shell's act
    /// (composition by source — `QuickEntryWingLabelTests`' precedent).
    @Test func everyWingLabelRendersTheDoor() throws {
        let root = try source("RootView.swift")
        let newNote = try #require(root.range(of: "Button(\"New Note\", systemImage: \"square.and.pencil\")"))
        let toolbar = String(root[newNote.upperBound...].prefix(3_000))
        #expect(toolbar.contains("ShellActions(session: session, shell: router).openWingSwitcher()"),
                "the toolbar's label presses ⌘L's act")
        #expect(toolbar.contains(".buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))"),
                "a quiet voiced word — the chrome vocabulary, no glass")
        #expect(toolbar.contains("QuickEntryCopy.wingLabel(wings.currentName)"), "still reads \u{201C}in \u{2039}wing\u{203A}\u{201D}")
        #expect(root.components(separatedBy: "onSwitchWing: { ShellActions(session: session, shell: router).openWingSwitcher() }").count == 3,
                "both quick-entry hosts get the act")
        for host in ["Features/Shelf/ShelfView.swift", "Features/Library/LibraryCatalogView.swift"] {
            let text = try source(host)
            let start = try #require(text.range(of: "QuickEntryBar("))
            #expect(text[start.lowerBound...].prefix(500).contains("onWingLabel: onSwitchWing"), "\(host) hands the bar the door")
        }
        let bar = try source("Features/Shelf/QuickEntryBar.swift")
        #expect(bar.contains("Button(action: onWingLabel) { label }"), "the bar's label is a button when a host hands the act")
    }
}
