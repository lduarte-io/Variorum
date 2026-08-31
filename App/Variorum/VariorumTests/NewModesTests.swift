//
//  NewModesTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — item 16 (W8-1): the mode row gains INDEX
//  (ruled: a new mode tab slotted after Takes) and READ (the read-only
//  page). The row's ORDER is the ⌘1–⌘8 mapping, the sidebar rail and the
//  masthead menu all at once (they render from `PostMode.allCases`), so
//  the order itself is the pin.
//

import Testing
@testable import Variorum

@Suite("The mode row with Index and Read (pre-13u Act 10 wave 2c)")
struct NewModesTests {
    @Test func theRowReadsAsRuledAndTheKeysFollowIt() {
        // Her ruling's letter: Index UNDER Takes (a new tab after it);
        // Read beside Index (the recorded taste call); no existing tab
        // removed (item 15's constraint survives as existing-tabs-stay).
        #expect(PostMode.allCases == [
            .write, .takes, .index, .read, .lenses, .compare, .blocks, .canvas,
        ])
        // ⌘1–⌘8 derive from this order (EditorCommands' ForEach) — eight
        // cases means eight ordinal keys, and Index is ⌘3.
        #expect(PostMode.allCases.count == 8)
        #expect(PostMode.allCases.firstIndex(of: .index) == 2)
        #expect(PostMode.allCases.firstIndex(of: .read) == 3)
    }

    @Test func theMemoryDecodesTheNewModesAndTheRetiredOutlineStillLands() {
        #expect(PostMode.fromStored("Index") == .index)
        #expect(PostMode.fromStored("Read") == .read)
        // The standing migrations hold unchanged.
        #expect(PostMode.fromStored("Outline") == .compare)
        #expect(PostMode.fromStored("NotAMode") == nil)
    }

    @Test func readIsTheProjectionTierSoEditingFamiliesGreyThere() {
        // READ has no editable surface anywhere in it (P-3's projection
        // tier) — ⌘B renders honestly grey instead of enabled-into-nil.
        #expect(CapabilityRegistry.isEnabled(
            .formatBold, in: CapabilityContext(mode: .read)) == false)
        // INDEX keeps the TOC's truth: its expanded row edits.
        #expect(CapabilityRegistry.isEnabled(
            .formatBold, in: CapabilityContext(mode: .index)))
        // Note-scoped READING stays available in Read — the tray door is
        // on its meta bar.
        #expect(CapabilityRegistry.isEnabled(
            .showNoteTray, in: CapabilityContext(mode: .read)))
    }

    /// The field guide's coverage contract carries the new modes (the walk
    /// pin EXTENDED deliberately, never rewritten): "ways of looking" opens
    /// with the index · read lesson, and the getting-around enumerator
    /// changed with the row — TutorialBookShapeTests holds plan ⇔ seed.
    @Test func theFieldGuideTeachesTheNewModes() {
        let looking = TutorialSeeder.plan.first { $0.chapter == "ways of looking" }
        #expect(looking?.lessons.first == "index \u{B7} read")
        #expect(looking?.lessons.contains("blocks \u{B7} canvas") == true,
                "the workbench lesson survives beside it")
    }

    @Test func theNewModesDeclareTheirRowMenuActs() {
        // Declared ⇔ rendered (P-1): Index carries the TOC listing's
        // archive/delete pair on its ⋯ menu.
        #expect(IndexModeView.surfaceCapabilities.contains(.archiveBlock))
        #expect(IndexModeView.surfaceCapabilities.contains(.deleteBlock))
    }
}
