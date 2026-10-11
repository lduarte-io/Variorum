//
//  WingSwitcherChordTests.swift
//  VariorumTests (Mac)
//
//  13n-c U4 — ⌘L, THE WING SWITCHER (R-AIR-15, her ratified chord; R-AIR-5
//  "click-without-typing CYCLES … fast to click"; round 5, the Library
//  masthead). The held-⌘ cycling cannot be walked while the session is
//  locked, so its state transitions are pinned here (the brief's locked-
//  session note): the pure brain, the key monitor's classification, the
//  spoken switch, the masthead's cycle, the chord's declaration and the
//  switcher's two masthead homes.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private typealias Row = WingSwitcherBrain.Row

private let rows: [Row] = [
    Row(id: "", name: "Home"),
    Row(id: "w-var", name: "variorum"),
    Row(id: "w-let", name: "letters"),
    Row(id: "w-sao", name: "São Paulo notes"),
]

@MainActor
@Suite("13n-c U4 — ⌘L: the wing switcher's brain, keys, cycle and doors", .serialized)
struct WingSwitcherChordTests {
    // MARK: - The brain (pure)

    @Test func opensWithTheCurrentWingHighlighted() {
        let brain = WingSwitcherBrain(rows: rows, currentID: "w-let")
        #expect(brain.highlight == "w-let", "the press that opens is not a cycle — typing can follow")
        #expect(!brain.cycling)
        #expect(brain.visible == rows)
    }

    @Test func heldCommandLCyclesAndReleaseCommits() {
        var brain = WingSwitcherBrain(rows: rows, currentID: "")
        brain.tapL()
        #expect(brain.highlight == "w-var" && brain.cycling, "another L while ⌘ is held: the next wing")
        brain.tapL()
        #expect(brain.highlight == "w-let")
        #expect(brain.commandReleased() == .commit("w-let"), "releasing ⌘ commits (the ⌘-tab idiom)")
        brain.tapL()
        brain.tapL()
        #expect(brain.highlight == "", "it wraps")
        #expect(brain.commandReleased() == .close, "cycling back to where she is switches nothing")
    }

    @Test func aPressAndReleaseLeavesItOpenForTyping() {
        let brain = WingSwitcherBrain(rows: rows, currentID: "")
        #expect(brain.commandReleased() == .stay,
                "⌘L pressed and released: the field stays for typing (release commits only after a cycle)")
    }

    @Test func typingFiltersAndReturnCommitsTheFirstMatch() {
        var brain = WingSwitcherBrain(rows: rows, currentID: "")
        brain.type("VARI")
        #expect(brain.visible.map(\.id) == ["w-var"], "case-insensitive (the one picker brain's sameness)")
        #expect(brain.highlight == "w-var")
        #expect(brain.returnPressed() == .commit("w-var"))
        brain.type("sao")
        #expect(brain.visible.map(\.id) == ["w-sao"], "diacritic-insensitive")
        brain.type("zzz")
        #expect(brain.visible.isEmpty && brain.highlight == nil)
        #expect(brain.returnPressed() == .stay, "nothing matches, nothing commits")
    }

    @Test func returnOnTheCurrentWingClosesAndArrowsNeverArmRelease() {
        var brain = WingSwitcherBrain(rows: rows, currentID: "w-var")
        #expect(brain.returnPressed() == .close, "the current wing: close, switch nothing")
        brain.move(by: 1)
        #expect(brain.highlight == "w-let" && !brain.cycling)
        #expect(brain.commandReleased() == .stay, "↑/↓ choose; only a held-⌘ L arms the release")
        brain.move(by: -2)
        #expect(brain.highlight == "", "arrows wrap too")
        #expect(brain.returnPressed() == .commit(""))
    }

    @Test func aTypedChangeEndsTheHeldCycle() {
        var brain = WingSwitcherBrain(rows: rows, currentID: "")
        brain.tapL()
        #expect(brain.cycling)
        brain.type("let")
        #expect(!brain.cycling && brain.highlight == "w-let")
        #expect(brain.commandReleased() == .stay)
    }

    @Test func aRowClickCommitsAndTheCurrentRowCloses() {
        let brain = WingSwitcherBrain(rows: rows, currentID: "")
        #expect(brain.pick("w-sao") == .commit("w-sao"))
        #expect(brain.pick("") == .close)
    }

    // MARK: - The masthead's cycling click

    @Test func theMastheadCycleWrapsAndOneWingIsNoCycleDoor() {
        #expect(WingSwitcherBrain.next(after: "", in: rows)?.id == "w-var")
        #expect(WingSwitcherBrain.next(after: "w-sao", in: rows)?.id == "", "wraps to Home")
        #expect(WingSwitcherBrain.next(after: "", in: [rows[0]]) == nil,
                "one wing: nothing to cycle to — the word is no cycle door (P-2)")
        #expect(WingSwitcherBrain.next(after: "gone", in: rows)?.id == "", "a dangling current starts at the top")
    }

    // MARK: - The keys only a monitor sees

    @Test func theMonitorClassifiesOnlyTheSwitchersKeys() {
        func key(_ type: NSEvent.EventType, _ chars: String?, _ code: UInt16, _ flags: NSEvent.ModifierFlags)
            -> WingSwitcherKeys.Key? {
            WingSwitcherKeys.classify(type: type, characters: chars, keyCode: code, flags: flags)
        }
        #expect(key(.keyDown, "l", 37, .command) == .tapL)
        #expect(key(.keyDown, "L", 37, [.command, .capsLock]) == .tapL, "caps lock is not a modifier here")
        #expect(key(.keyDown, "l", 37, [.command, .shift]) == nil, "⇧⌘L is Save Choices as Lens")
        #expect(key(.keyDown, "l", 37, [.command, .control]) == nil, "⌃⌘L is Lock Library Now")
        #expect(key(.keyDown, "l", 37, []) == nil, "a typed l is typing")
        #expect(key(.flagsChanged, nil, 55, []) == .commandUp)
        #expect(key(.flagsChanged, nil, 56, [.command, .shift]) == nil, "⌘ still held")
        #expect(key(.keyDown, "\u{1B}", 53, []) == .escape)
        // Only an acted-on key is consumed, and ⌘'s release never is — so an
        // ask's sheet over the switcher (another window, never acted on here)
        // keeps its own Esc.
        #expect(WingSwitcherKeys.consumes(.tapL, acted: true))
        #expect(WingSwitcherKeys.consumes(.escape, acted: true))
        #expect(!WingSwitcherKeys.consumes(.escape, acted: false))
        #expect(!WingSwitcherKeys.consumes(.commandUp, acted: true), "⌘'s release is only observed")
    }

    // MARK: - The switch speaks; the cycle moves

    @Test func aSwitcherSwitchSpeaksNowInAndTheCycleSteps() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let wing = try Operations().createWing(name: "variorum")
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(wings.nextWing?.id == wing.id)
            wings.switchSaying(wing.id)
            #expect(session.wing.currentID == wing.id)
            #expect(session.status.spoken?.text == "Now in \u{201C}variorum\u{201D}.", "the existing receipt")
            session.status.clear()
            wings.switchSaying(wing.id)
            #expect(session.status.spoken == nil, "switching to where she is says nothing")
            wings.cycle()
            #expect(session.wing.currentID == "", "the cycle wraps to Home")
            #expect(session.status.spoken?.text == "Now in Home.")
            // The ⌘L model: a commit switches and closes; a stay keeps it up.
            let model = WingSwitcherModel(wings: wings)
            #expect(model.brain.highlight == "")
            #expect(!model.apply(.stay))
            #expect(model.apply(.commit(wing.id)) && session.wing.currentID == wing.id)
        }
    }

    // MARK: - Stage B R1 B6 — ⌘L with ONE wing (P-2)

    /// With one wing the switcher's only outcome is closing it — a door that
    /// does nothing (P-2; the masthead already declines to cycle there). So
    /// "Switch Wing…" is unavailable (grey) with its note naming where another
    /// wing comes from, and the app-wide menu reads the library's wing count
    /// from the session — the count a wings model's read writes, whichever
    /// window is key.
    @Test func switchWingIsUnavailableWithOneWing() async throws {
        #expect(CapabilityRegistry.availability(.switchWing, in: CapabilityContext(wingCount: 1)) == .unavailable)
        #expect(CapabilityRegistry.availability(.switchWing, in: CapabilityContext(wingCount: 2)) == .act)
        #expect(CapabilityRegistry.capability(.switchWing).unavailableNote.contains(WingCopy.newWingVerb),
                "the note names New Wing…")
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 67))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(session.wing.wingCount == 1)
            #expect(!session.commandRouter.isEnabled(.switchWing), "one wing (Home) — ⌘L is grey")
            _ = try Operations().createWing(name: "variorum")
            await wings.load()
            #expect(session.wing.wingCount == 2)
            #expect(session.commandRouter.isEnabled(.switchWing), "a second wing — ⌘L switches")
        }
    }

    // MARK: - The chord and the doors

    @Test func commandLIsDeclaredWiredAndFreeOfEveryOtherChord() {
        let cap = CapabilityRegistry.capability(.switchWing)
        #expect(cap.doors == [.menuBar, .surface] && cap.shortcutLabel == "\u{2318}L")
        #expect(cap.verb == "Switch Wing\u{2026}")
        #expect(EditorCommands.menuRendered.contains(.switchWing))
        let commandL = EditorCommands.keyEquivalent(for: .switchWing)
        #expect(commandL?.0 == "l" && commandL?.1 == .command)
        let optionComma = EditorCommands.keyEquivalent(for: .mcpSettings)
        #expect(optionComma?.0 == "," && optionComma?.1 == [.command, .option])
        // THE SWEEP, as a pin: no other act maps either chord.
        for id in CapabilityID.allCases where id != .switchWing && id != .mcpSettings {
            guard let other = EditorCommands.keyEquivalent(for: id) else { continue }
            #expect(!(other.0 == "l" && other.1 == .command), "\(id) collides with ⌘L")
            #expect(!(other.0 == "," && other.1 == [.command, .option]), "\(id) collides with ⌥⌘,")
        }
        #expect(WingSwitcherMenu.surfaceCapabilities.contains(.switchWing))
        #expect(WingSwitcherSheet.surfaceCapabilities.contains(.switchWing))
    }

    /// Round 5 (her words: the switcher "lives on the Bookcase only, which is
    /// weird"): ONE view in the shared home, rendered by BOTH mastheads; the
    /// switcher carries the Snippets line.
    @Test func theSwitcherLivesInTheSharedHomeOnBothMastheads() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Variorum")
        func code(_ path: String) throws -> String {
            try String(contentsOf: root.appending(path: path), encoding: .utf8)
        }
        #expect(FileManager.default.fileExists(atPath: root.appending(path: "Core/Views/WingSwitcherMenu.swift").path))
        #expect(!FileManager.default.fileExists(atPath: root.appending(path: "Features/Shelf/WingSwitcherMenu.swift").path))
        #expect(try code("Features/Shelf/ShelfView.swift").contains("WingSwitcherMenu(tokens:"))
        #expect(try code("Features/Library/LibraryCatalogView.swift").contains("WingSwitcherMenu(tokens:"))
        #expect(try code("Core/Views/WingSwitcherMenu.swift").contains("WingCopy.snippetsShared"))
        #expect(try code("Core/Views/WingSwitcherSheet.swift").contains("WingCopy.snippetsShared"))
        #expect(WingCopy.snippetsShared == "Snippets is the one room every wing shares.")
    }
}
