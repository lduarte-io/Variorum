//
//  QuickEntryWingLabelTests.swift
//  VariorumTests
//
//  VX-552 (the VX-439 run, A-439-6 + C-552-1) — her ask: the wing you're in
//  always visible beside the New Note door, so a new note's landing place is
//  never a surprise. A DESIGN row: its pins are the words (pure) and the
//  composition — BOTH quick-entry hosts (the Bookcase's band and the
//  Library's bar, the two doors that mint into the current wing) hand the bar
//  the host's own current wing name, Home included; the walk's capture (the
//  orchestrator's) is the look. The composition half reads the hosts' source
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
}
