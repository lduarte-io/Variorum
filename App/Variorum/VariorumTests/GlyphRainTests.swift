//
//  GlyphRainTests.swift
//  VariorumTests
//
//  17u (2026-09-25) — the locked lobby's glyph-rain backdrop: the pure
//  brain's contract, and the grep pin that keeps the retired endpaper tile
//  (`girl-and-the-fan` / `lobby-endpaper`) out of the app for good — her
//  ask: "make sure that doesn't appear anywhere anymore".
//

import Foundation
import Testing
@testable import Variorum

@Suite("17u — the lobby's glyph rain")
struct GlyphRainTests {
    /// Letters and numbers (plus code punctuation), all ASCII — every glyph
    /// fills exactly one monospaced cell, so the columns stay columns.
    @Test func theAlphabetIsLettersNumbersAndCodePunctuationOnly() {
        #expect(GlyphRain.glyphs.count > 60)
        for glyph in GlyphRain.glyphs {
            #expect(glyph.isASCII, "\(glyph) is not ASCII")
            #expect(!glyph.isWhitespace)
        }
        #expect(GlyphRain.glyphs.contains("7"))
        #expect(GlyphRain.glyphs.contains("K"))
        #expect(GlyphRain.glyphs.contains("x"))
        #expect(Set(GlyphRain.glyphs).count == GlyphRain.glyphs.count, "no glyph is doubled")
    }

    /// The same grid, seed and moment always draw the same frame — the
    /// brain holds no state, so nothing can drift between frames.
    @Test func aFrameIsAPureFunctionOfGridTimeAndSeed() {
        let rain = GlyphRain(columns: 40, rows: 30, seed: 0xC0FFEE)
        #expect(rain.cells(at: 12.5) == rain.cells(at: 12.5))
        #expect(rain.cells(at: 12.5) != GlyphRain(columns: 40, rows: 30, seed: 0xBEEF).cells(at: 12.5),
                "a different seed is a different rain")
    }

    /// Every lit cell lies on the grid, at an intensity in (0, 1]; a frame
    /// mid-run is populated (the still frame under Reduce Motion must not
    /// be blank) and never lights the whole grid (it is an undertone).
    @Test func cellsStayOnTheGridAtSaneIntensitiesAndTheFrameIsPopulatedButSparse() {
        let rain = GlyphRain(columns: 120, rows: 60, seed: 42)
        for time in stride(from: 0.0, through: 90, by: 3.7) {
            let cells = rain.cells(at: time)
            #expect(!cells.isEmpty, "blank frame at t=\(time)")
            #expect(cells.count < 120 * 60 / 2, "over half the grid lit at t=\(time)")
            for cell in cells {
                #expect((0..<120).contains(cell.column))
                #expect((0..<60).contains(cell.row))
                #expect(cell.intensity > 0 && cell.intensity <= 1)
            }
        }
    }

    /// The rain falls: a column's head moves DOWN the grid with time, one
    /// head per column, the brightest cell at the bottom of its trail.
    @Test func columnsFallTopDownWithOneHeadEach() {
        let rain = GlyphRain(columns: 8, rows: 200, seed: 7)
        for column in 0..<8 {
            let lane = GlyphRain.Lane(column: column, seed: 7)
            // Pick a moment when this column's head is comfortably on the grid.
            var t = 0.0
            while !(20..<150).contains(lane.head(at: t, rows: 200)) { t += 0.25 }
            let earlier = lane.head(at: t, rows: 200)
            let later = lane.head(at: t + 1, rows: 200)
            #expect(later > earlier, "column \(column) did not fall")
            #expect(abs((later - earlier) - lane.speed) < 1e-6, "a second of fall is the lane's speed in rows")

            let cells = rain.cells(at: t).filter { $0.column == column }
            let heads = cells.filter { $0.intensity == 1 }
            #expect(heads.count == 1, "column \(column) has \(heads.count) heads")
            #expect(heads.first?.row == cells.map(\.row).max(), "the head is the lowest lit cell")
            #expect(cells.count <= lane.trail + 1)
        }
    }

    /// The trail glyphs FLICKER — the same cell shows a different glyph at
    /// some later moment within one fall — while a frame's worth of time
    /// (~70 ms) usually leaves a trail cell's glyph alone (calm, not noise).
    @Test func trailGlyphsFlickerSlowly() {
        let rain = GlyphRain(columns: 30, rows: 40, seed: 99)
        let base = rain.cells(at: 30).filter { $0.intensity < 1 }
        let soon = Dictionary(uniqueKeysWithValues:
            rain.cells(at: 30 + GlyphRainBackdrop.frameInterval).map { ($0.column * 1000 + $0.row, $0.glyph) })
        let later = Dictionary(uniqueKeysWithValues:
            rain.cells(at: 30 + 1.0).map { ($0.column * 1000 + $0.row, $0.glyph) })
        var unchangedSoon = 0, changedLater = 0, comparedSoon = 0, comparedLater = 0
        for cell in base {
            if let g = soon[cell.column * 1000 + cell.row] { comparedSoon += 1; if g == cell.glyph { unchangedSoon += 1 } }
            if let g = later[cell.column * 1000 + cell.row] { comparedLater += 1; if g != cell.glyph { changedLater += 1 } }
        }
        #expect(comparedSoon > 50 && comparedLater > 50)
        #expect(Double(unchangedSoon) / Double(comparedSoon) > 0.8, "one frame later most trail glyphs still stand")
        #expect(Double(changedLater) / Double(comparedLater) > 0.5, "a second later most have flickered")
    }

    /// The retired tile appears NOWHERE in the app: not as a bundled
    /// resource, not by name in any Mac or shared source.
    @Test func theTessellatingEndpaperTileIsGoneFromTheApp() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let fm = FileManager.default
        var offenders: [String] = []
        let enumerator = try #require(fm.enumerator(at: appRoot, includingPropertiesForKeys: nil))
        for case let url as URL in enumerator {
            let relative = url.path.replacingOccurrences(of: appRoot.path + "/", with: "")
            if relative.hasPrefix("DerivedData") || relative.contains("/DerivedData/") {
                enumerator.skipDescendants(); continue
            }
            let name = url.lastPathComponent.lowercased()
            if name.contains("endpaper") || name.contains("girl-and-the-fan") {
                offenders.append(relative)
            }
            guard url.pathExtension == "swift", !relative.hasPrefix("VariorumTests/GlyphRainTests") else { continue }
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
            if text.contains("lobby-endpaper") || text.contains("girl-and-the-fan") {
                offenders.append(relative)
            }
        }
        #expect(offenders.isEmpty, "the retired lobby tile survives at: \(offenders)")
    }
}
