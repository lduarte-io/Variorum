//
//  MobileNoteTopTests.swift
//  VariorumMobileTests
//
//  VM-272 (the VM-260 run, batch 2) — **THE NOTE'S TOP GIVES THE SCREEN BACK TO
//  WRITING.** Her words, from two screenshots of a note with the keyboard up:
//  "the top part is so huge it takes up half of the area … i liked the icons at
//  the top being smaller and less obtrusive." The traced mechanism (the run
//  record, batch 2): the masthead stacks three rows of 44 pt targets — the title
//  with its four tools, the membership line, the chip flow — and put 26 pt of
//  padding on top of them (10 above, 4 + 4 between, 8 below) under a 24 pt title
//  and 22 pt tools: 158 pt at one chip row. And its chips were 44 TALL only, so
//  in Study "tags" and "lens" answered under 44 across.
//
//  THE PINS, on the app's own screen (`MobileWriteScreen` with the model it
//  drove — the screen's own test seam), in both voices:
//  · the chrome above the text — RED ON OLD (measured 167 / 166.3 in the
//    batch-2 window; the cap now 137 since the reconcile, below);
//  · every door on the note's top answers across 44 × 44 — RED ON OLD in Study
//    (the tags and lens chips' widths);
//  · the four tools are one 44 pt row of 44 × 44 targets, centres 44 apart — a
//    GUARD (green on both: road (b) changes the glyph, never the frame).
//  The keyboard does not enter it: the masthead is the screen's top inset and
//  the keyboard moves only the text below it (the keyboard-reveal UI test holds
//  that road, and the window's capture shows the note with the keyboard up).
//
//  Only symbols both trees declare.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-272 — the note's top gives the screen back to writing", .serialized)
struct MobileNoteTopTests {
    /// The note's top's doors, by the words each speaks.
    static let doors = [
        "Rename Note", "Copy Note", "Find in Note", MobileWriteScreen.lockDoorTitle,
        MobileNoteActionsSheet.doorLabel, "Books holding this note",
        "Entry Date", "Tags", "More Info", "Blocks", "Lenses",
    ]

    /// The app's Write screen over a short note, in one voice, at the phone's width.
    private func mounted(
        _ voice: ThemeVoice,
        _ body: @MainActor (MobileEditorViewModel, HostedSurface<MobileWriteScreen>) async throws -> Void
    ) async throws {
        try await withEditorWorld { session, _ in
            // The harness door for the editor face's voice (the screen's tokens
            // follow it with no router); the world resets it at its next start.
            MobileEditorStyle.voice = voice
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let postID = try await makePost(session, blocks: [
                "A first paragraph with a few plain words.",
                "A second one, so the page has a little to show.",
            ])
            let model = MobileEditorViewModel(session: session, postID: postID)
            let surface = HostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model),
                size: CGSize(width: 402, height: 874))
            defer { surface.tearDown() }
            for _ in 0..<300 {
                if let tv = model.textView, tv.textStorage.length > 0 { break }
                await surface.settle(1)
            }
            await surface.settle(30)
            try await body(model, surface)
        }
    }

    /// **RED ON OLD — "the top part is so huge".** The chrome between the top
    /// of the screen's safe area and the top of her text: three rows of 44 pt
    /// targets and the 4 below them (≤ 137, a point for rounding) — the old
    /// tree measured 167 / 166.3. And never less than the three rows: the
    /// targets stay.
    ///
    /// RECONCILED (the batch-2 window measured the tip at 145.0 / 144.3 against
    /// a cap of 140 — the arithmetic 136 missed 9 pt, on the old tree too): 8 of
    /// it was `safeAreaInset`'s default spacing under the masthead (now
    /// `spacing: 0`), the rest the title row on its title's baseline, the tools
    /// hanging a point below their 44 (Study 1.0, Terminal 0.3 — now centred).
    /// Both gone, the layout is exact, so the cap tightened 140 → 137.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theNoteTopGivesTheScreenBackToWriting(voice: ThemeVoice) async throws {
        try await mounted(voice) { model, surface in
            let tv = try #require(model.textView, "the editor is up")
            let textTop = tv.convert(tv.bounds, to: nil).minY
            let safeTop = surface.host.view.safeAreaInsets.top
            let chrome = textTop - safeTop
            let title = surface.element(labeled: "Rename Note")?.accessibilityFrame ?? .null
            print("PERF[sim] VM-272 note top \(voice): chrome \(chrome) (text at \(textTop), safe top \(safeTop), "
                  + "title row \(title))")
            #expect(chrome <= 3 * PhoneMetrics.touchMinimum + MobileWriteScreen.mastheadBottom + 1,
                    "\(voice): the note's top takes \(chrome) pt above her text")
            #expect(chrome >= 3 * PhoneMetrics.touchMinimum - 0.5,
                    "\(voice): three rows of 44 pt targets stay (\(chrome))")
        }
    }

    /// **RED ON OLD in Study** (the chips were 44 tall only: "tags" ≈ 43 and
    /// "lens" ≈ 41 across at 15 pt — and a step-down alone would take them
    /// under 40). Every door on the note's top answers across 44 × 44, in both
    /// voices: the title (Rename), the four tools, the membership line, the
    /// five chips.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func everyDoorOnTheNoteTopAnswersAcrossFortyFour(voice: ThemeVoice) async throws {
        try await mounted(voice) { _, surface in
            var measured: [String] = []
            for label in Self.doors {
                let door = try #require(surface.element(labeled: label),
                                        "\(label) in \(voice): \(surface.visibleLabels)")
                let frame = door.accessibilityFrame
                measured.append("\(label) \(Int(frame.width.rounded()))×\(Int(frame.height.rounded()))")
                #expect(frame.width >= 43.5 && frame.height >= 43.5, "\(label) in \(voice): \(frame)")
            }
            print("PERF[sim] VM-272 note-top doors \(voice): \(measured.joined(separator: " · "))")
        }
    }

    /// **A GUARD** (green on both trees): the four tools stay one row of
    /// 44 × 44 targets that touch — centres 44 apart — at the row's trailing
    /// end; road (b) changes what each draws, never its frame.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theToolsAreOneRowOfFortyFourSquareTargets(voice: ThemeVoice) async throws {
        try await mounted(voice) { _, surface in
            let tools = try ["Copy Note", "Find in Note", MobileWriteScreen.lockDoorTitle,
                             MobileNoteActionsSheet.doorLabel].map { label in
                try #require(surface.element(labeled: label), "\(label): \(surface.visibleLabels)")
                    .accessibilityFrame
            }
            for (index, tool) in tools.enumerated() {
                #expect(abs(tool.width - 44) <= 0.5 && abs(tool.height - 44) <= 0.5, "tool \(index): \(tool)")
                #expect(abs(tool.midY - tools[0].midY) <= 0.5, "one row: \(tools)")
                if index > 0 {
                    #expect(abs(tool.midX - tools[index - 1].midX - 44) <= 0.5, "centres 44 apart: \(tools)")
                }
            }
            #expect(abs((tools.last?.maxX ?? 0) - (402 - PhoneMetrics.gutter)) <= 0.5,
                    "the last tool ends at the gutter: \(tools)")
        }
    }
}
