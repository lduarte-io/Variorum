//
//  OpenListStarredFilterTests.swift
//  VariorumTests
//
//  **VX-589 (the VX-439 run, A-439-10) — a setting to hide starred notes from
//  the Open list.** Her notes (2026-10-20): *"ability to not see in Open what
//  is already in Starred"* · *"a setting where you could choose to not have
//  items that are starred show in the Open tabs. i'm noticing a lot of
//  duplication there."* A LOCAL preference (this Mac), default OFF, in
//  Settings ▸ General ▸ Open notes; DISPLAY ONLY — the strip keeps every row
//  (its order, its ⌘⇧n keys, closing and following), the list just does not
//  draw a starred note while the setting is on.
//
//  Pins: the preference (local, off by default, catalogued on General); the
//  pure filter; the drop's mapping from a slot among the DRAWN rows to the
//  strip (identity with nothing hidden — so every VX-288/VX-424 pin still
//  describes the list); the door landing a drag among the drawn rows while a
//  hidden row stays open; and the wiring, read.
//

import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private typealias Drop = SidebarLayout.OpenListDrop
private typealias Filter = SidebarLayout.OpenListStarredFilter

@MainActor
@Suite("VX-589 — hide starred notes from the Open list (a local, display-only setting)")
struct OpenListStarredFilterTests {
    // MARK: - The preference

    @Test func theSettingIsLocalOffByDefaultAndCataloguedOnGeneral() throws {
        let suite = "vx589.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(!Filter.isOn(defaults), "off unless she turns it on")
        defaults.set(true, forKey: Filter.settingKey)
        #expect(Filter.isOn(defaults))
        let row = try #require(SettingsCatalog.rows.first { $0.id == "hideStarredFromOpen" })
        #expect(row.pane == .general && row.title == "Hide starred notes from Open")
        #expect(row.blurb.contains("This Mac only."), "it says it is local")
        #expect(AppSettingsView.rowIDsRendered[.general]?.contains("hideStarredFromOpen") == true)
        for word in ["starred", "duplication", "tabs"] {
            #expect(row.keywords.contains(word), "her word “\(word)” finds it")
        }
    }

    // MARK: - The filter

    @Test func theListDrawsTheStripLessStarredNotesOnlyWhileOn() {
        let strip = ["a", "s1", "b", "s2", "c"]
        let starred: Set<String> = ["s1", "s2", "elsewhere"]
        #expect(Filter.displayed(strip, starredNotes: starred, hidingStarred: false) == strip, "off: the strip")
        #expect(Filter.displayed(strip, starredNotes: starred, hidingStarred: true) == ["a", "b", "c"],
                "on: less the starred, in the strip's order")
        #expect(Filter.displayed(strip, starredNotes: ["s2"], hidingStarred: true) == ["a", "s1", "b", "c"],
                "unstarred: its row is back")
        #expect(Filter.displayed(strip, starredNotes: [], hidingStarred: true) == strip)
        #expect(Filter.displayed(["s1"], starredNotes: ["s1"], hidingStarred: true).isEmpty,
                "every open note starred: the list draws nothing")
    }

    // MARK: - The drop among the drawn rows

    /// With nothing hidden the mapping is the identity — every slot of every
    /// list, every dragged row — so the list's own pins hold unchanged.
    @Test func withNothingHiddenASlotIsItsOwnStripSlot() {
        for count in 1...6 {
            let rows = (0..<count).map { "r\($0)" }
            for (from, dragged) in rows.enumerated() {
                for gap in 0...count {
                    let own = gap == from || gap == from + 1
                    #expect(Drop.stripGap(displayedGap: gap, displayed: rows, strip: rows, dragged: dragged)
                            == (own ? nil : gap), "\(count) rows, \(dragged) at gap \(gap)")
                }
            }
        }
    }

    /// With a starred row hidden: a slot among the DRAWN rows lands right
    /// before the drawn row at that slot (or after the last drawn row), and
    /// the drawn rows' own place offers nothing — even where a hidden row sits
    /// inside it in the strip.
    @Test func aSlotAmongTheDrawnRowsLandsInTheStripBesideTheSameRow() {
        let strip = ["a", "S", "b", "c"]
        let drawn = ["a", "b", "c"]
        #expect(Drop.stripGap(displayedGap: 2, displayed: drawn, strip: strip, dragged: "a") == 3, "before c")
        #expect(Drop.stripGap(displayedGap: 0, displayed: drawn, strip: strip, dragged: "c") == 0, "the top")
        #expect(Drop.stripGap(displayedGap: 3, displayed: drawn, strip: strip, dragged: "a") == 4, "after c, the last drawn")
        #expect(Drop.stripGap(displayedGap: 1, displayed: drawn, strip: strip, dragged: "a") == nil,
                "a's own lower gap among the drawn rows — no line, no move (S between them is not seen)")
        #expect(Drop.stripGap(displayedGap: 1, displayed: drawn, strip: strip, dragged: "b") == nil, "b's own upper gap")
        #expect(Drop.stripGap(displayedGap: 1, displayed: drawn, strip: strip, dragged: "S") == nil,
                "a hidden row is never dragged")
    }

    /// The door: a drag among the drawn rows lands beside the row the drawn
    /// list named; the hidden starred note stays OPEN (the strip still holds
    /// it — display only).
    @Test func aDropAmongTheDrawnRowsLandsAndTheHiddenNoteStaysOpen() {
        let workspace = WorkspaceModel()
        for id in ["a", "S", "b", "c"] { workspace.visit(.post(id)) }
        let drawn = ["a", "b", "c"]
        let state = OpenListDragState()
        state.read(SidebarLayout.ScrollWindow(offset: 0, viewport: 90, content: 90))
        state.began("a")
        state.targeted(.after("b"), true)
        #expect(state.lineTop(rows: drawn, rowHeight: 30) == 59, "the line among the drawn rows: the b/c boundary")
        let token = SidebarView.OpenNoteDragToken(noteID: "a", listID: state.listID)
        #expect(OpenListDropDoor.perform([token], onto: .after("b"), displayed: drawn, state: state,
                                         workspace: workspace, animation: nil))
        #expect(workspace.openNotes.shown == ["S", "b", "a", "c"], "a right after b; S still open")
        #expect(Filter.displayed(workspace.openNotes.shown, starredNotes: ["S"], hidingStarred: true)
                == ["b", "a", "c"], "as drawn: a one place down")
    }

    // MARK: - The wiring, read

    @Test func theOpenGroupDrawsTheFilteredRowsAndKeepsTheStripsKeys() throws {
        let sidebar = try String(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
                .appending(path: "Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        #expect(sidebar.contains(
            "@AppStorage(SidebarLayout.OpenListStarredFilter.settingKey) private var hideStarredFromOpen = false"))
        let group = try #require(sidebar.range(of: "private var openGroup: some View {"))
        let body = String(sidebar[group.upperBound...].prefix(2_400))
        #expect(body.contains("let shown = openListRows"), "the list draws the filtered rows")
        #expect(body.contains("ordinal: (workspace.openNotes.shown.firstIndex(of: noteID) ?? 99) + 1"),
                "the badge is the STRIP's key")
        #expect(body.contains("first: noteID == shown.first, rows: shown"), "the drops read the drawn rows")
        #expect(sidebar.contains(".modifier(OpenListRowDrop(state: openListDrag, noteID: noteID, rows: rows"))
        #expect(sidebar.contains(".modifier(OpenListEndZoneDrop(state: openListDrag, rows: shown"))
        #expect(sidebar.contains("openListRows.contains(noteID) else { return nil }"),
                "the current row is revealed only where it is drawn")
    }
}
