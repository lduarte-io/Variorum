//
//  MobileShelfMarkerColumnTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, finding W-A3) — **TERMINAL'S RESERVED MARKER
//  COLUMN HOLDS AT xxxLARGE, AS CHROME DOES.** The walk measured it: in
//  Terminal the Bookcase's book names start at 47.5 pt at the default size and
//  at 83 pt at AX5, so "journal", "the pocket guide" and "the prince" read
//  "jo…", "the…", "the…" — the invisible "› " column had grown to about 55 pt.
//
//  THE MECHANISM (`MobileShelfView.bookRow`): the column is the voice's
//  selection marker drawn at `.opacity(0)` so names align, and it was set in
//  `rowTitle` — her words' class, which follows the text size across the whole
//  range. A marker is chrome: batch 1's role map puts the ★, the ✓ and the pick
//  marks on `meta`, which holds at xxxLarge (the wing list's reserved ✓ column
//  is the same construct, on `meta`). The fix gives the column `meta`.
//
//  THE PIN measures where the name's first ink falls, off the rendered shelf
//  in Terminal: at AX5 it is no further right than at xxxLarge, where chrome
//  stops growing. RED ON OLD: the column grew by ≈30 pt between the two sizes.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Terminal's marker column holds at xxxLarge (VM-47, the walk's W-A3)", .serialized)
struct MobileShelfMarkerColumnTests {
    /// Where the book row's name begins, in points from the screen's left
    /// edge, on the real shelf at one text size.
    private func nameStart(_ session: AppSession, size: DynamicTypeSize) async throws -> CGFloat {
        let tokens = VoiceTokens.terminalLight
        let shelf = MobileShelfView(
            model: MobileShelfViewModel(session: session),
            stars: MobileStarsModel(session: session),
            quickNote: MobileQuickNoteModel(session: session),
            tokens: tokens, tabBar: { EmptyView() },
            onOpenBook: { _ in }, onOpenForWriting: { _ in })
            .dynamicTypeSize(size)
        return try await withSceneSurface(shelf, dark: false) { surface in
            await surface.settle(40)
            let row = try #require(
                surface.elements.first {
                    ($0.accessibilityLabel ?? "").range(of: "ledger", options: .caseInsensitive) != nil
                        && !$0.accessibilityFrame.isEmpty
                },
                "the book's row at \(size): \(surface.labels)")
            let frame = row.accessibilityFrame
            let pixels = try surface.render()
            let paper = PixelColor(UIColor(tokens.surface), traits: surface.traits)
            let ground = pixels.color(at: CGPoint(x: frame.minX + 2, y: frame.midY))
            try #require(ground.distance(to: paper) <= 0.05,
                         "the row sits on the paper at \(size): \(ground) against \(paper)")
            return try #require(
                pixels.firstInkColumn(in: frame.insetBy(dx: 1, dy: 1), ground: ground),
                "no ink in the book's row at \(size) (frame \(frame))")
        }
    }

    /// **The name keeps the room the column gives back:** at AX5 her book's
    /// name starts where it starts at xxxLarge (the chrome's hold), never
    /// further right.
    @Test func atAX5TheNameStartsWhereItDoesAtXXXLarge() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops in
                try ops.createReading(name: "Ledger", kind: .book)
            }
            let held = try await nameStart(session, size: .xxxLarge)
            let largest = try await nameStart(session, size: .accessibility5)
            let resting = try await nameStart(session, size: .large)
            print("PERF[sim] VM-47 W-A3 — Terminal book name starts at \(resting) (large) · \(held) (xxxLarge) · \(largest) (AX5)")
            #expect(largest <= held + 1,
                    "the marker column grew past the chrome's hold: the name starts at \(largest) pt at AX5, \(held) pt at xxxLarge")
            #expect(resting <= held + 0.5, "and it grows up to xxxLarge, never shrinks: \(resting) → \(held)")
        }
    }
}
