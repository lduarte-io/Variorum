//
//  NewModesTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — item 16 (W8-1): the mode row gained INDEX and
//  READ (eight). The Act 10 correction round (her rulings R-cor-5/7) folded
//  Index INTO Read: ONE tab named Read with an in-place `edit · read` switch
//  — so the row is SEVEN. Its ORDER is the ⌘1–⌘7 mapping, the sidebar rail
//  and the masthead menu all at once (they render from `PostMode.allCases`),
//  so the order itself is the pin.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("The mode row with Read's two faces (the Act 10 correction round)")
struct NewModesTests {
    @Test func theRowReadsAsRuledAndTheKeysFollowIt() {
        // Her ruling's letter: Write · Takes · Read · Lenses · Compare ·
        // Blocks · Canvas — the Index tab retired INTO Read.
        #expect(PostMode.allCases == [
            .write, .takes, .read, .lenses, .compare, .blocks, .canvas,
        ])
        // ⌘1–⌘7 derive from this order (EditorCommands' ForEach) — seven
        // cases means seven ordinal keys, and Read is ⌘3.
        #expect(PostMode.allCases.count == 7)
        #expect(PostMode.allCases.firstIndex(of: .read) == 2)
        #expect(PostMode.allCases.firstIndex(of: .blocks) == 5)
        // The registry's one verb names the same span.
        #expect(CapabilityRegistry.capability(.switchMode).verb.contains("⌘1–⌘7"))
    }

    @Test func theMemoryDecodesTheRetiredTabsIntoTheirSuccessors() {
        // A note left in the retired Index tab reopens in Read (its
        // successor — Read's `edit` face IS the index surface), exactly as
        // a note left in Outline reopens in Compare.
        #expect(PostMode.fromStored("Index") == .read)
        #expect(PostMode.fromStored("Read") == .read)
        #expect(PostMode.fromStored("Outline") == .compare)
        #expect(PostMode.fromStored("NotAMode") == nil)
    }

    @Test func readIsEditableOnlyWhileItsEditFaceIsAttached() {
        // The mode alone cannot say which face shows. With no `edit` face
        // attached, READ is the projection tier — ⌘B renders honestly grey
        // instead of enabled-into-nil.
        #expect(CapabilityRegistry.isEnabled(
            .formatBold, in: CapabilityContext(mode: .read)) == false)
        // The `edit` face reports itself like a takes board — and the
        // family is available over the one live pane it hosts.
        #expect(CapabilityRegistry.isEnabled(
            .formatBold, in: CapabilityContext(mode: .read, readEditAttached: true)))
        // Note-scoped READING stays available in Read either way — the
        // tray door is on the column's footer.
        #expect(CapabilityRegistry.isEnabled(
            .showNoteTray, in: CapabilityContext(mode: .read)))
    }

    @Test func theReadFaceOpensOnEditByRulingAndIsRememberedPerNote() {
        let defaults = UserDefaults(suiteName: "read-face-memory-\(UUID().uuidString)")!
        // "still default open to the index edit though" — her ruling.
        #expect(ReadModeView.rememberedFace(postID: "p1", defaults: defaults) == .edit)
        ReadModeView.remember(.read, postID: "p1", defaults: defaults)
        #expect(ReadModeView.rememberedFace(postID: "p1", defaults: defaults) == .read)
        // Per NOTE: another note still opens on edit.
        #expect(ReadModeView.rememberedFace(postID: "p2", defaults: defaults) == .edit)
    }

    /// The field guide's coverage contract carries the merged tab (the walk
    /// pin EXTENDED deliberately, never rewritten): "ways of looking" opens
    /// with the read lesson, and the getting-around enumerator changed with
    /// the row — TutorialWalkTests holds plan ⇔ seed.
    @Test func theFieldGuideTeachesTheMergedTab() {
        let looking = TutorialSeeder.plan.first { $0.chapter == "ways of looking" }
        #expect(looking?.lessons.first == "read")
        #expect(looking?.lessons.contains("blocks \u{B7} canvas") == true,
                "the workbench lesson survives beside it")
    }

    @Test func theColumnDeclaresItsRowMenuActsUnderBothNames() {
        // Declared ⇔ rendered (P-1): the `▸ 01` column carries the TOC
        // listing's archive/delete pair on its ⋯ menu — under the retired
        // tab's forwarded name too, so every pin that unions it reads on.
        #expect(NoteIndexColumn.surfaceCapabilities.contains(.archiveBlock))
        #expect(NoteIndexColumn.surfaceCapabilities.contains(.deleteBlock))
        #expect(IndexModeView.surfaceCapabilities == NoteIndexColumn.surfaceCapabilities)
        #expect(ReadModeView.surfaceCapabilities == NoteIndexColumn.surfaceCapabilities)
    }
}
