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
//  THE PIN measures where the NAME BEGINS — its layout origin — off the
//  rendered shelf in Terminal: at AX5 it is where it is at xxxLarge, where
//  chrome stops growing. The origin is read as the name's first ink less its
//  first glyph's own left side bearing at the size the row draws it.
//
//  **Why the first form of this pin was the wrong measure** (the walk's fixes,
//  batch 2, piece 1): it compared the name's first INK, and allowed 1 pt. The
//  name is her words (`rowTitle`, full range), so between xxxLarge and AX5 it
//  keeps growing by design, and its first glyph's side bearing grows with it —
//  SF Mono Semibold's "l" sits 0.089 em right of its origin, so the ink moves
//  ≈ 2 pt right (the windows' fixed-tree reading: 51.3 → 53.3 pt) with nothing
//  in the column changing. The pre-fix tree's own readings (54.0 → 84.3 pt,
//  marker and name both on `rowTitle`) fix the two sizes the row draws
//  (≈ 19.4 and ≈ 42.3 pt), and 0.089 em × their difference is 2.04 pt — the
//  whole residue. So the pin now measures the origin: red on old by ≈ 28 pt
//  (the column's own growth), level on new.
//

import CoreText
import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Terminal's marker column holds at xxxLarge (VM-47, the walk's W-A3)", .serialized)
struct MobileShelfMarkerColumnTests {
    /// The book's name as the row draws it (the Terminal voice lowercases).
    private static let name = "Ledger"

    /// **The first glyph's own left side bearing** — how far its ink sits
    /// right of the name's layout origin — in the role's face at the size the
    /// row resolves for this text size. It grows with the name, which is her
    /// words' class.
    private func leadingBearing(_ tokens: VoiceTokens, size: DynamicTypeSize) throws -> CGFloat {
        let drawn = tokens.chromeLabel(Self.name)
        let first = try #require(drawn.first, "the row draws a name")
        let points = PhoneType.resolved(.rowTitle, voice: tokens.voice, at: size.phoneCategory).pointSize
        let font = PhoneType.baseUIFont(
            PhoneType.spec(.rowTitle, voice: tokens.voice), voice: tokens.voice, pointSize: points) as CTFont
        var characters = Array(String(first).utf16)
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        try #require(CTFontGetGlyphsForCharacters(font, &characters, &glyphs, characters.count),
                     "the row's face draws \(first)")
        var bounds = CGRect.zero
        CTFontGetBoundingRectsForGlyphs(font, .horizontal, &glyphs, &bounds, 1)
        return bounds.minX
    }

    /// Where the book row's name begins — its first ink, and its layout
    /// origin (the ink less the glyph's bearing) — in points from the
    /// screen's left edge, on the real shelf at one text size.
    private func nameStart(
        _ session: AppSession, size: DynamicTypeSize
    ) async throws -> (ink: CGFloat, origin: CGFloat) {
        let tokens = VoiceTokens.terminalLight
        let shelf = MobileShelfView(
            model: MobileShelfViewModel(session: session),
            stars: MobileStarsModel(session: session),
            quickNote: MobileQuickNoteModel(session: session),
            tokens: tokens, tabBar: { EmptyView() },
            onOpenBook: { _ in }, onOpenForWriting: { _ in })
            .dynamicTypeSize(size)
        let ink = try await withSceneSurface(shelf, dark: false) { surface in
            await surface.settle(40)
            let row = try #require(
                surface.elements.first {
                    ($0.accessibilityLabel ?? "").range(of: Self.name, options: .caseInsensitive) != nil
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
        return (ink, ink - (try leadingBearing(tokens, size: size)))
    }

    /// **The name keeps the room the column gives back:** at AX5 her book's
    /// name begins where it begins at xxxLarge (the chrome's hold), never
    /// further right. 1 pt holds the pixel grid (each reading is the first
    /// third-of-a-point column past the glyph's edge) — the old column grew
    /// twenty-eight times that.
    @Test func atAX5TheNameStartsWhereItDoesAtXXXLarge() async throws {
        try await withEditorWorld { session, _ in
            let name = Self.name
            _ = try await session.runner.run { ops in
                try ops.createReading(name: name, kind: .book)
            }
            let held = try await nameStart(session, size: .xxxLarge)
            let largest = try await nameStart(session, size: .accessibility5)
            let resting = try await nameStart(session, size: .large)
            print("PERF[sim] VM-47 W-A3 — Terminal book name: first ink \(resting.ink) (large) · \(held.ink) (xxxLarge) · \(largest.ink) (AX5); origin \(resting.origin) · \(held.origin) · \(largest.origin)")
            #expect(largest.origin <= held.origin + 1,
                    "the marker column grew past the chrome's hold: the name begins at \(largest.origin) pt at AX5, \(held.origin) pt at xxxLarge (first ink \(largest.ink) / \(held.ink))")
            #expect(resting.origin <= held.origin + 0.5,
                    "and it grows up to xxxLarge, never shrinks: \(resting.origin) → \(held.origin)")
        }
    }
}
