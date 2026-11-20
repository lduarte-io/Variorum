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
