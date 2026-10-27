//
//  QuickEntryWingLabelTests.swift
//  VariorumTests
//
//  VX-552 (the VX-439 run, A-439-6 + C-552-1) — her ask: the wing you're in
//  always visible beside the New Note door, so a new note's landing place is
//  never a surprise. A DESIGN row: its pins are the words (pure) and the
//  composition — BOTH quick-entry hosts (the Bookcase's band and the
//  Library's bar) hand the bar the host's own current wing name, Home
//  included, and the window toolbar's New Note button wears the same label
//  (the VX-439 ladder's M-2: it mints into the current wing too — C-552-1's
//  "the two doors that mint into the current wing" had missed it; ⌘N, a menu
//  key, has no room beside it); the walk's capture (the orchestrator's) is the
//  look. The composition half reads the hosts' source
//  — a bar's construction cannot be mounted headlessly with its host's wing
//  model — the `theLibraryNoteRowMenuRendersItsDeclaredDoors` precedent.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VX-552 — the quick-entry bar says which wing a new note lands in")
struct QuickEntryWingLabelTests {
    @Test func theWordsNameTheWingAndItsRoad() {
        #expect(QuickEntryCopy.wingLabel(WingWords.home) == "in \(WingWords.home)")
        #expect(QuickEntryCopy.wingLabel("Work") == "in Work")
        #expect(QuickEntryCopy.wingHelp("Work")
                == "A note made here lands in the \u{201C}Work\u{201D} wing \u{2014} \u{2318}L switches wings")
        // Sentence case, no shouty caps (her standing rule).
        #expect(QuickEntryCopy.wingLabel("Home").first == "i")
    }

    private func source(_ path: String) throws -> String {
        try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/\(path)"),
            encoding: .utf8)
    }

    /// Both hosts compose the bar WITH the wing — and with Home when no wings
    /// model is handed (her "always": shown with one wing too).
    @Test func bothQuickEntryHostsHandTheBarTheirCurrentWing() throws {
        for host in ["Features/Shelf/ShelfView.swift", "Features/Library/LibraryCatalogView.swift"] {
            let text = try source(host)
            let start = try #require(text.range(of: "QuickEntryBar("), "\(host) composes the bar")
            let call = text[start.lowerBound...].prefix(400)
            #expect(call.contains("wingName: wings?.currentName ?? WingWords.home"),
                    "\(host) hands the bar the wing a note lands in")
        }
    }

    /// **The window toolbar's New Note button wears the label too** (the
    /// VX-439 ladder's M-2 — RED ON OLD: the item was not there). The ticket's
    /// own door — "beside the New Note button" — is the toolbar's
    /// `square.and.pencil`, on every surface, minting into the current wing
    /// (`LibraryViewModel.createPost`); C-552-1's "the two doors that mint into
    /// the current wing" missed it. So the item right after it carries the same
    /// words and hover as the bars (one vocabulary), from the shell's own wings
    /// model (the app's one wing — it follows the focused note), muted, one
    /// line, never a glass button (`sharedBackgroundVisibility(.hidden)` — it is
    /// a label, not a door). PROVISIONAL (her morning look decides the shape).
    @Test func theToolbarsNewNoteButtonWearsTheWingLabel() throws {
        let root = try source("RootView.swift")
        let button = try #require(root.range(of: "Button(\"New Note\", systemImage: \"square.and.pencil\")"),
                                  "the toolbar's New Note door")
        let after = String(root[button.upperBound...].prefix(2_400))
        let item = try #require(after.range(of: "ToolbarItem(placement: .navigation) {"),
                                "an item follows the New Note door")
        let label = String(after[item.lowerBound...].prefix(1_200))
        #expect(label.contains("QuickEntryCopy.wingLabel(wings.currentName)"), "the bars' words, the shell's wing")
        #expect(label.contains(".foregroundStyle(tokens.muted)") && label.contains(".lineLimit(1)"),
                "muted chrome, one line")
        #expect(label.contains(".help(QuickEntryCopy.wingHelp(wings.currentName))"), "the hover is the whole fact")
        #expect(label.contains(".sharedBackgroundVisibility(.hidden)"), "a label, not a glass button")
    }
}
