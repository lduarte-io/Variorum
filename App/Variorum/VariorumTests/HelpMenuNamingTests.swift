//
//  HelpMenuNamingTests.swift
//  VariorumTests
//
//  VX-602 (the VX-439 run, A-439-9 + C-602-1) — her CLEAN checklist: "what's
//  under the help menu is SO confusing. 'Restore Tutorial' should be restore
//  field guide. take the tour should be the onboarding tutorial still. it's
//  just confusing." A WORDING row, so its pins are the words: each Help door
//  names its own thing — the field guide's two doors say "field guide", the
//  tour says "onboarding tutorial" — and the sentences that name a door
//  follow its name. The field guide's own seeded CONTENT is deliberately NOT
//  re-worded (A-439-9: a content edit stales her real store's seeded guide —
//  flagged for her morning bundle), and this pin says so.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VX-602 — the Help menu names the field guide and the onboarding tutorial apart")
struct HelpMenuNamingTests {
    @Test func eachHelpDoorNamesItsOwnThing() {
        #expect(CapabilityRegistry.capability(.restoreTutorial).verb == "Restore Field Guide\u{2026}")
        #expect(HelpMenuCopy.openFieldGuide == "Open the Field Guide")
        #expect(CapabilityRegistry.capability(.takeTour).verb == "Take the Onboarding Tutorial")
        #expect(TourOfferCopy.helpRoad == "Run it any time from Help \u{25B8} Take the Onboarding Tutorial.")
        // "tutorial" names ONE Help door now, the tour; the two field-guide
        // doors never say it.
        let doors = [
            CapabilityRegistry.capability(.restoreTutorial).verb, HelpMenuCopy.openFieldGuide,
            CapabilityRegistry.capability(.takeTour).verb,
        ]
        #expect(doors.filter { $0.localizedCaseInsensitiveContains("tutorial") }
                == [CapabilityRegistry.capability(.takeTour).verb])
        #expect(doors.filter { $0.localizedCaseInsensitiveContains("field guide") }.count == 2)
    }

    @Test func theSentencesNamingADoorFollowItsName() {
        #expect(HelpMenuCopy.restoreFieldGuideName == "Restore Field Guide")
        #expect(TutorialSeeder.replaceQuestion == "Restore the field guide?")
    }

    private func source(_ path: String) throws -> String {
        try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/\(path)"),
            encoding: .utf8)
    }

    /// The Help menu and ⌘K render the field guide's door from the ONE name;
    /// the old literal is gone from both.
    @Test func theOldNamesAreGoneFromTheMenuAndThePalette() throws {
        for file in ["EditorCommands.swift", "RootView.swift"] {
            let text = try source(file)
            #expect(text.contains("HelpMenuCopy.openFieldGuide"), "\(file) renders the one name")
            #expect(!text.contains("\"Open the Tutorial"), "\(file) no longer says Open the Tutorial")
        }
        #expect(!(try source("Registry/CapabilityRegistry.swift")).contains("\"Restore Tutorial"))
    }

    /// A-439-9's boundary, stated: the guide's own lessons still say the old
    /// door name (three lines, flagged for her — a re-seed is hers to order).
    /// When she rules the content edit, this pin flips with it.
    @Test func theGuidesSeededContentIsNotReworded() throws {
        let seeder = try source("Features/Tutorial/TutorialSeeder.swift")
        #expect(seeder.components(separatedBy: "Restore Tutorial\\u{2026}").count - 1 == 3,
                "the three lesson lines stand as seeded (morning bundle 3)")
    }
}
