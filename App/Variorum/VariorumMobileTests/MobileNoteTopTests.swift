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
//  **MOVED WITH R-260-13 (the VM-260 run, batch 4b — the note's top as she
//  picked it):** the title on its own row, ONE row of six icon doors under it
//  (copy · find · book · # · blocks/lens/more info · ⋯), no separator; the seal
//  and the date moved into the Note sheet's head; the membership line and the
//  five chips are gone from the top. So the chrome at rest is the title's row
//  and one 44 pt row (was three rows — the cap TIGHTENS 137 → 105 at a one-line
//  title); every door on the top is the title, the six and, while the tags are
//  open, the strip's add door; the four tools' guard is now the six doors' one
//  row. The scrolled state (only the row stays) and the new doors' acts are
//  `MobileNoteTopRowTests`.
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
    /// The note's top's doors, by the words each speaks (R-260-13: the title,
    /// then the one row's six, in order).
    static let doors = ["Rename Note"] + rowDoors
    /// The one row, in its order: copy · find · book · # · the stack door · ⋯.
    static let rowDoors = [
        "Copy Note", "Find in Note", "Books holding this note", "Tags",
        "Blocks, Lenses and More Info", MobileNoteActionsSheet.doorLabel,
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
    /// of the screen's safe area and the top of her text, at rest, under a
    /// one-line title: the title's row (its 44 pt door and at most 12 of air
    /// above it) and ONE row of 44 pt targets, and the 4 below them (≤ 105, a
    /// point for rounding) — the old tree measured 136 (three rows of 44 and the
    /// 4). And never less than the two rows: the targets stay.
    ///
    /// MOVED WITH R-260-13 (batch 4b): it held three rows of 44 + 4 (≤ 137 — the
    /// batch-2 reconcile's exact cap); her pick folds the membership line and the
    /// chips into the one row, so the cap TIGHTENS to two rows + the title's air.
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
            #expect(chrome <= 2 * PhoneMetrics.touchMinimum + 12 + MobileWriteScreen.mastheadBottom + 1,
                    "\(voice): the note's top takes \(chrome) pt above her text")
            #expect(chrome >= 2 * PhoneMetrics.touchMinimum - 0.5,
                    "\(voice): the title's row and the row of 44 pt targets stay (\(chrome))")
        }
    }

    /// **RED ON OLD in Study** (the chips were 44 tall only: "tags" ≈ 43 and
    /// "lens" ≈ 41 across at 15 pt — and a step-down alone would take them
    /// under 40). Every door on the note's top answers across 44 × 44, in both
    /// voices: the title (Rename), the row's six — and, while the tags are open,
    /// the strip's add door.
    ///
    /// MOVED WITH R-260-13 (batch 4b): the doors are the title and the one row's
    /// six (the membership line and the five chips left the top); the strip's
    /// add door joins while the tags are open. Red on old in BOTH voices now —
    /// the stack door does not exist there.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func everyDoorOnTheNoteTopAnswersAcrossFortyFour(voice: ThemeVoice) async throws {
        try await mounted(voice) { _, surface in
            var measured: [String] = []
            @MainActor func measure(_ label: String) throws {
                let door = try #require(surface.element(labeled: label),
                                        "\(label) in \(voice): \(surface.visibleLabels)")
                let frame = door.accessibilityFrame
                measured.append("\(label) \(Int(frame.width.rounded()))×\(Int(frame.height.rounded()))")
                #expect(frame.width >= 43.5 && frame.height >= 43.5, "\(label) in \(voice): \(frame)")
            }
            for label in Self.doors { try measure(label) }
            #expect(surface.activate("Tags"), "the # door in \(voice): \(surface.visibleLabels)")
            await surface.settle(30)
            try measure("Add Tag")
            print("PERF[sim] VM-272 note-top doors \(voice): \(measured.joined(separator: " · "))")
        }
    }

    /// **The six doors are ONE row of 44 × 44 targets that touch — centres 44
    /// apart, NO separator between them — centred on the screen**, in her order:
    /// copy · find · book · # · the stack door · ⋯.
    ///
    /// MOVED WITH R-260-13 (batch 4b): it was the four tools' GUARD (one row of
    /// four at the trailing gutter, green on both trees). Her pick: one row of
    /// six under the title, "I don't think there should be a verticle line
    /// between the options" — so the centres-44-apart law now also proves there
    /// is no separator, and the row is centred. RED ON OLD (no stack door, the
    /// book door and # were lines and chips on rows of their own).
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theSixDoorsAreOneRowOfFortyFourSquareTargets(voice: ThemeVoice) async throws {
        try await mounted(voice) { _, surface in
            let doors = try Self.rowDoors.map { label in
                try #require(surface.element(labeled: label), "\(label): \(surface.visibleLabels)")
                    .accessibilityFrame
            }
            print("PERF[sim] VM-260 4b the row \(voice): \(doors)")
            for (index, door) in doors.enumerated() {
                #expect(abs(door.width - 44) <= 0.5 && abs(door.height - 44) <= 0.5, "door \(index): \(door)")
                #expect(abs(door.midY - doors[0].midY) <= 0.5, "one row: \(doors)")
                if index > 0 {
                    #expect(abs(door.midX - doors[index - 1].midX - 44) <= 0.5,
                            "centres 44 apart — no separator: \(doors)")
                }
            }
            let middle = ((doors.first?.minX ?? 0) + (doors.last?.maxX ?? 0)) / 2
            #expect(abs(middle - 201) <= 0.5, "the row is centred on the screen: \(doors)")
        }
    }
}
