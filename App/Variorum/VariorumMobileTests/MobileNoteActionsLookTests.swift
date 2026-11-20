//
//  MobileNoteActionsLookTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, part B — the walk's fixes, batch 2) — the note's
//  ⋯ sheet as it is DRAWN, read off a real window's pixels.
//
//  W-B3 — **"Delete Note…" wears the voice's alarm.** The walk measured the
//  row's title in iOS's red (#F23032, 3.43:1 on the room) where the Trash's
//  "Delete Now" wears the alarm; the sizing sheet's §D names the alarm for
//  exactly this door ("replaces the literal red on Delete note…") and §E's
//  menu row says "a removing act wears the alarm ink, last". THE MECHANISM:
//  `MobileNoteActionsSheet.deleteRow` handed `actRow` the literal `tint: .red`
//  (batch 2 adopted the rows onto the menu row and kept the tint). THE PIN:
//  the row's title is drawn in the alarm (a glyph-core pixel within a hair of
//  `tokens.alarm`), both voices × light/dark — red on old (no pixel near the
//  alarm: the title is the system red, the detail line the corrected muted).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-47 W-B3 — Delete Note… wears the alarm (rendered)", .serialized)
struct MobileNoteActionsAlarmTests {
    private func tokens(_ voice: ThemeVoice, dark: Bool) -> VoiceTokens {
        var settings = MobileShellRouter.placeholder
        settings.voice = voice
        return .resolve(settings: settings, dark: dark)
    }

    @Test(arguments: [ThemeVoice.study, .terminal], [false, true])
    func deleteNoteIsDrawnInTheAlarm(voice: ThemeVoice, dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["One.", "Two."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let tokens = tokens(voice, dark: dark)
            let sheet = MobileNoteActionsSheet(
                door: model.undoDoor, model: model, tokens: tokens, onDeleted: {})
                .environment(\.mobileSettingsDoor, MobileSettingsDoor(open: {}))
            try await withSceneSurface(sheet, dark: dark) { surface in
                await surface.settle(20)
                let row = try #require(surface.onScreen(MobileEditorViewModel.deleteNoteTitle),
                                       "the Delete Note row: \(surface.labels)")
                let pixels = try surface.render()
                let alarm = PixelColor(UIColor(tokens.alarm), traits: surface.traits)
                let nearest = try #require(
                    pixels.colors(in: row.accessibilityFrame).min { $0.distance(to: alarm) < $1.distance(to: alarm) },
                    "nothing drawn in the Delete Note row")
                print("PERF[sim] VM-47 W-B3 Delete Note \(voice) dark \(dark): nearest \(nearest) to the alarm \(alarm)")
                #expect(nearest.distance(to: alarm) <= 0.06,
                        "\(voice) dark \(dark): no part of Delete Note… is drawn in the alarm \(alarm) (nearest \(nearest))")
            }
        }
    }
}

//  W-B4 — **ONE hairline between two rows of the note's ⋯ sheet, never two.**
//  The walk measured two hairlines 13.3 pt apart with nothing between them,
//  above "Settings", in both voices. THE MECHANISM: the body's `VStack(spacing:
//  14)` draws a divider after `versionsRow`, then `undoRow` and `redoRow` —
//  which render NOTHING while the structural-undo stack is empty — then
//  `settingsRow`, which opened with its OWN divider (VM-53's row). THE FIX:
//  Settings' divider draws only when an undo or redo row sits above it. THE
//  PIN reads the drawn sheet: in the gap between each two consecutive rows
//  there is exactly ONE hairline, with the stack empty and with an undo row
//  showing — red on old in the first state (two hairlines in the gap between
//  Versions… and Settings).

@MainActor
@Suite("VM-47 W-B4 — one hairline between two rows of the note's sheet (rendered)", .serialized)
struct MobileNoteActionsHairlineTests {
    private var tokens: VoiceTokens { .resolve(settings: MobileShellRouter.placeholder, dark: false) }

    /// The hairlines drawn in one column between two rows: runs of pixels
    /// that differ from the sheet's room.
    private func hairlines(
        _ pixels: RenderedPixels, x: CGFloat, from top: CGFloat, to bottom: CGFloat, ground: PixelColor
    ) -> Int {
        let column = min(max(Int(x * pixels.scale), 0), pixels.width - 1)
        let y0 = max(Int(top * pixels.scale), 0), y1 = min(Int(bottom * pixels.scale), pixels.height)
        guard y0 < y1 else { return 0 }
        var runs = 0
        var inRun = false
        for y in y0 ..< y1 {
            let lined = pixels.pixel(column, y).distance(to: ground) > 0.03
            if lined && !inRun { runs += 1 }
            inRun = lined
        }
        return runs
    }

    /// The sheet's rows top to bottom, and the hairline count in each gap.
    private func gaps(withUndoRow: Bool) async throws -> [(between: String, lines: Int)] {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Keep me.", "Delete me."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            if withUndoRow {
                await model.structural.deleteBlock(blockID: model.index.entries[1].blockID)
            }
            #expect((model.undoDoor.undoLabel != nil) == withUndoRow, "the undo stack as the case needs it")
            let tokens = tokens
            let sheet = MobileNoteActionsSheet(
                door: model.undoDoor, model: model, tokens: tokens, onDeleted: {})
                .environment(\.mobileSettingsDoor, MobileSettingsDoor(open: {}))
            return try await withSceneSurface(sheet, dark: false) { surface in
                await surface.settle(20)
                var rows: [(String, CGRect)] = []
                for label in [VersionsPath.menuLabel, MobileNoteActionsSheet.settingsTitle,
                              MobileEditorViewModel.deleteNoteTitle] {
                    let row = try #require(surface.onScreen(label), "the \(label) row: \(surface.labels)")
                    rows.append((label, row.accessibilityFrame))
                }
                if withUndoRow {
                    let undo = try #require(
                        surface.elements.first { ($0.accessibilityLabel ?? "").hasPrefix("Undo ") },
                        "the undo row: \(surface.labels)")
                    rows.append((undo.accessibilityLabel ?? "Undo", undo.accessibilityFrame))
                }
                rows.sort { $0.1.minY < $1.1.minY }
                let pixels = try surface.render()
                let room = PixelColor(UIColor(tokens.room), traits: surface.traits)
                let x = rows[0].1.minX + 60
                return zip(rows, rows.dropFirst()).map { upper, lower in
                    (between: "\(upper.0) → \(lower.0)",
                     lines: hairlines(pixels, x: x, from: upper.1.maxY, to: lower.1.minY, ground: room))
                }
            }
        }
    }

    @Test(arguments: [false, true])
    func betweenTwoRowsThereIsOneHairline(withUndoRow: Bool) async throws {
        let found = try await gaps(withUndoRow: withUndoRow)
        print("PERF[sim] VM-47 W-B4 the note sheet's gaps (undo row \(withUndoRow)): \(found)")
        #expect(found.count == (withUndoRow ? 3 : 2), "the rows were found: \(found)")
        for gap in found {
            #expect(gap.lines == 1, "undo row \(withUndoRow): \(gap.lines) hairlines between \(gap.between)")
        }
    }
}
