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

    /// A-439-9's boundary, FLIPPED as it asked ("when she rules the content
    /// edit, this pin flips with it"): her coordinator raised the three stale
    /// lesson lines at the VX-292 kickoff ("we should fix it"), R-292-9
    /// routed them here, and the vx-105 resolution split them (Option B): the
    /// guide names the door by its REGISTRY verb from here on — VX-292 U1
    /// derives "the tray & the Trash" and "comments & tags"; the first
    /// lesson's line ("start here") is vx-105's rewrite, so it is the ONLY
    /// place the old literal may still stand. After both merges none does —
    /// this pin holds on either side of vx-105's merge. The seeded TRUTH is
    /// `TutorialCurrencyTests.theLessonsNameTheRestoreDoorByItsMenuTitle`.
    @Test func theGuideNamesTheRestoreDoorByItsRegistryVerb() throws {
        let seeder = try source("Features/Tutorial/TutorialSeeder.swift")
        let old = "Restore Tutorial\\u{2026}"
        #expect(seeder.components(separatedBy: old).count - 1 <= 1,
                "at most the first lesson's line (vx-105's) still says the old name")
        let afterTheFirstLesson = try #require(
            seeder.components(separatedBy: "lesson(welcome, \"getting around\"").last)
        #expect(!afterTheFirstLesson.contains(old), "no later lesson says the old name")
        #expect(afterTheFirstLesson.components(
            separatedBy: "\\(CapabilityRegistry.capability(.restoreTutorial).verb)").count - 1 == 2,
                "the two lessons quote the registry's verb")
    }
}
