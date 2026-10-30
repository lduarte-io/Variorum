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

    /// **VX-105 (R-105-4, her words: "they should be able to restore sherlock,
    /// jeyll and hyde, the prince, etc. each individual. the sample library is
    /// too confusing we don't need that.")** — Help's book doors each name
    /// their book, the Sherlock door included: Restore “the adventures of
    /// sherlock holmes”, over the one name constant (the Jekyll and Prince
    /// doors' idiom). Four restore-a-seeded-thing doors on Help, no fifth, and
    /// no door anywhere says "sample library". RED ON OLD: the verb read
    /// "Restore the Sample Library".
    @Test func theSherlockDoorNamesItsBookAndNoDoorSaysSampleLibrary() throws {
        #expect(CapabilityRegistry.capability(.restoreSampleLibrary).verb
                == "Restore \u{201C}the adventures of sherlock holmes\u{201D}")
        #expect(CapabilityRegistry.capability(.restoreSampleLibrary).verb
                == "Restore \u{201C}\(SampleLibrarySeeder.bookName)\u{201D}", "one name constant")
        #expect(CapabilityRegistry.capability(.restorePrinceBook).verb
                == "Restore \u{201C}\(SampleLibraryPrinceBook.name)\u{201D}")
        #expect(CapabilityRegistry.capability(.restoreJekyllBook).verb
                == "Restore \u{201C}\(SampleLibraryJekyllBook.name)\u{201D}")
        let seededDoors: [CapabilityID] = [
            .restorePrinceBook, .restoreSampleLibrary, .restoreJekyllBook, .restoreClassicsGathering,
        ]
        for id in seededDoors {
            #expect(CapabilityRegistry.capability(id).doors.contains(.menuBar), "\(id) on the Help menu")
            #expect(ShellActions.paletteActs.contains(id), "\(id) typeable in \u{2318}K")
        }
        for capability in CapabilityRegistry.all {
            #expect(!capability.verb.localizedCaseInsensitiveContains("sample library"),
                    "no door says sample library: \(capability.verb)")
        }
        // The menu and the palette render the registry's verb — no literal of the old name anywhere they read.
        for file in ["EditorCommands.swift", "Registry/CapabilityRegistry.swift", "Registry/ShellActions.swift"] {
            #expect(!(try source(file)).contains("\"Restore the Sample Library"), "\(file) spells no old name")
        }
        #expect(try source("EditorCommands.swift").contains("Button(verb(.restoreSampleLibrary))"))
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
