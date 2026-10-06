//
//  LibraryViewScopeSwitchTests.swift
//  VariorumTests
//
//  **17y B-WALK W-2 — THE VIEW AND THE SCOPE SWITCH EACH OTHER (her rulings,
//  the walk of 2026-10-05).** Her finding: "Notes [the Cards view] takes away
//  your ability to see books - the other selector should automatically switch
//  from 'All' to 'Notes' in that case" — and, at the walk's full return: "yes
//  to building the cards notes auto switch and if someone clicks on all from
//  inside card view, move them off the card view". The Cards view renders
//  NOTES only, so a scope chip reading "All" over it says something the
//  screen does not show (she fell for it herself on the dev store: "I was on
//  cards the whole time… the confusing user experience of being on 'all' but
//  not seeing books").
//
//  THE TWO SWITCHES (ruled): picking Cards moves the scope All → Notes;
//  picking All while in Cards moves the view off Cards, to List. Every other
//  combination is untouched (the edges are PROVISIONAL — QUESTIONS #188).
//
//  Red-on-old, stated: the source scan was committed AHEAD of the fix and ran
//  red on that tree — both pickers wrote the model's value directly
//  (`model.mode = $0`, `model.scope = $0`), so nothing could switch the
//  other. The rule's own pins (the pure table, the model's two doors) land
//  with the fix.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("17y B-WALK W-2 — picking Cards moves All to Notes; picking All in Cards moves to List")
struct LibraryViewScopeSwitchTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    /// Both pickers route through the model's doors — never a bare write that
    /// could not move the other value.
    @Test func bothPickersRouteThroughTheSwitchingDoors() throws {
        let view = try Self.source("Variorum/Features/Library/LibraryCatalogView.swift")
        #expect(!view.contains("model.mode = $0"), "the view picker writes the mode bare")
        #expect(!view.contains("model.scope = $0"), "the scope picker writes the scope bare")
        #expect(view.contains("model.pickMode($0)"), "the view picker picks through the model's door")
        #expect(view.contains("model.pickScope($0)"), "the scope picker picks through the model's door")
    }
}
