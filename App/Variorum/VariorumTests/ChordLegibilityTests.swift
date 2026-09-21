//
//  ChordLegibilityTests.swift
//  VariorumTests
//
//  **13u4 UNIT S1 — item 7: "where is the merge shortcut said ??"**
//  Her report, verbatim: *"where is the merge shortcut said ?? I don't see
//  it in the shortcuts list or in the menu. it only shows up as shift
//  command M if you try merging w takes on blocks that don't have takes -
//  then the command shortcut shows up & is helpful."*
//
//  The unit's audit found the registry knew ⌘⇧M all along, and so did the
//  ⌘/ helper and the menu bar — but the THREE menus she writes from
//  (Write's bottom-bar `block ▾`, Write's right-click menu, and the Takes
//  bar's `block ▾`) rendered the four PLAIN structural rows from hard-coded
//  literals, while the two CEREMONY rows beside them were built from
//  `Capability.menuTitle()`, which appends the declared chord. So those
//  menus said "Merge choosing takes… (⌥⌘⇧M)" directly above a silent
//  "Merge" — a face teaching the opposite of the registry.
//
//  These are the H-pattern truth pins: prose (or a menu row) names a chord
//  ⇒ a pin asserts the surface renders it. They are deliberately written
//  over the DECLARATION rather than over a literal "⌘⇧M", so a key she
//  re-picks moves in the registry alone and these stay green — except the
//  two pins that spell ⌘⇧M out, which exist so her own sentence has a
//  literal answer somewhere in the suite.
//
//  RED-ON-OLD: every pin in the first suite fails on the pre-fix tree (the
//  four literals carried no chord). The helper and menu-bar pins were
//  GREEN on both sides and are recorded as such in the unit record — they
//  are the half of her report that was already true, kept as guards.
//

import SwiftUI  // `KeyEquivalent` / `EventModifiers` in the menu-wiring pin
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The merge chord is said where she merges (13u4 S1, item 7)")
struct ChordLegibilityTests {
    /// Every structural row Write's `block ▾` renders wears its DECLARED
    /// chord. Generalized over the declaration rather than over ⌘⇧M alone,
    /// because the defect was the CLASS — four literals, not one row.
    @Test func theWriteBarsBlockMenuSaysEveryDeclaredChord() {
        for row in CommitBar.structuralRows {
            let capability = CapabilityRegistry.capability(row.id)
            guard let chord = capability.shortcutLabel else {
                Issue.record("\(row.id) is on the block ▾ menu with no declared chord")
                continue
            }
            #expect(row.title.contains(chord),
                    "block ▾'s \(row.id) row says \(chord) — it reads \"\(row.title)\"")
        }
    }

    /// Her own sentence, answered literally on the door she uses.
    @Test func theWriteBarsMergeRowReadsMergeWithTheChord() {
        let merge = CommitBar.structuralRows.first { $0.id == .merge }
        #expect(merge?.title == "Merge (⌘⇧M)")
    }

    /// The Takes bar's `block ▾` — R118's parity half: no surface is behind
    /// another, and that includes what a row is allowed to tell her.
    @Test func theTakesBarsBlockMenuSaysEveryDeclaredChord() {
        for door in TakesBottomBar.structuralBar {
            // `StructuralAct` and `CapabilityID` share their raw values for
            // all six structural verbs — the registry-side vocabulary and
            // the planner-side one were minted to line up.
            guard let id = CapabilityID(rawValue: door.act.rawValue),
                  let chord = CapabilityRegistry.capability(id).shortcutLabel else {
                Issue.record("\(door.act) has no declared capability with a chord")
                continue
            }
            #expect(door.title.contains(chord),
                    "the Takes bar's \(door.act) row says \(chord) — it reads \"\(door.title)\"")
        }
    }

    @Test func theTakesBarsMergeRowReadsMergeWithTheChord() {
        let merge = TakesBottomBar.structuralBar.first { $0.act == .merge }
        #expect(merge?.title == "Merge (⌘⇧M)")
    }

    /// Write's RIGHT-CLICK menu — the door a block is most often acted on
    /// from, and the one whose ceremony rows already carried their chords.
    @Test func writesContextMenuSaysEveryStructuralChord() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let titles = h.model.contextMenuItems().map(\.title)
            for id in [CapabilityID.divide, .divideWithCeremony, .extract,
                       .makeBlock, .merge, .mergeWithCeremony] {
                let capability = CapabilityRegistry.capability(id)
                // The EXACT row, not "the chord appears somewhere on this
                // menu": ⌥⌘⇧M CONTAINS ⌘⇧M, so a loose `contains` over the
                // whole list is satisfied by the ceremony row — which is
                // precisely the state her report describes. Measured on the
                // reverted tree, where the loose form found only ⌘⇧E and
                // ⌘⇧K missing and let the two she asked about pass.
                #expect(titles.contains(capability.menuTitle()),
                        "the context menu renders \(id) as \"\(capability.menuTitle())\"")
            }
            #expect(titles.contains("Merge Blocks (⌘⇧M)"))
        }
    }

    // MARK: - The two faces that were ALREADY telling the truth (green on
    // both sides — kept as guards, and recorded as not-the-defect)

    /// The ⌘/ helper has carried ⌘⇧M since the helper was born (2db2a0b3,
    /// Sitting 9). Half of her report ("I don't see it in the shortcuts
    /// list") is answered by the list already; what was missing was every
    /// door she reaches for while writing.
    @Test func theHelperListSaysTheMergeChord() {
        let rows = HelperView.groups.flatMap(\.items)
        #expect(rows.contains { $0.keys == "⌘⇧M" },
                "the ⌘/ helper's shortcut list carries ⌘⇧M")
    }

    /// The menu bar wires it, and the act is in the rendered set — so
    /// AppKit draws "⇧⌘M" on Block ▸ Merge Blocks.
    @Test func theMenuBarWiresAndRendersTheMergeChord() throws {
        #expect(EditorCommands.menuRendered.contains(.merge))
        let wiring = try #require(EditorCommands.keyEquivalent(for: .merge))
        #expect(wiring.0 == "m")
        #expect(wiring.1 == [.command, .shift])
    }
}
