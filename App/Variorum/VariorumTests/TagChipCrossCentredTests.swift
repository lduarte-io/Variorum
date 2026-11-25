//
//  TagChipCrossCentredTests.swift
//  VariorumTests
//
//  **VX-1081 (VX-1036 batch 2) — the pill's × is centred on its text.** Her
//  words (2026-11-24, R-1036-20): *"the x on the tag pill is not centered
//  with the text, which should be fixed."*
//
//  THE MECHANISM (traced by reading, measured by render): the card's stack
//  aligns on the FIRST TEXT BASELINE (rows 10/11 — so a row aligns on the
//  chip text's baseline), and the × was a 7-pt bold symbol wrapped in a
//  `Text`, so ITS baseline went onto the label's baseline: the glyph stood ON
//  the line, its ink from the baseline up, while the label's lowercase ink —
//  what the eye centres on — sits around the x-height's middle. Measured on
//  the pre-fix card at 3×, off-screen, both voices: the ×'s ink centre stood
//  +0.50 to +0.67 pt BELOW the label's x-height middle (its bottom on the
//  baseline, its top a point under the x-height).
//
//  THE PIN measures INK, the eye's own measure: the card is drawn at 3× in a
//  borderless window that is never ordered in (nothing appears on screen),
//  the label is a tag of x-height-only letters ("season" — no ascender, no
//  descender, so its ink box IS the x-height band), and the × is the last run
//  of ink columns. RED ON OLD (+0.50…+0.67 pt, past the one-pixel tolerance);
//  green once the × is centred on the x-height middle.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1081 — the tag pill's × is centred on its text", .serialized)
struct TagChipCrossCentredTests {
    /// One device pixel at the render's 3× — the eye's floor.
    static let tolerance: CGFloat = 1.0 / 3.0

    @Test(arguments: [ThemeVoice.terminal, .study], [false, true])
    func theCrossInkCentresOnTheLabelsXHeightMiddle(voice: ThemeVoice, dark: Bool) throws {
        let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
        let card = TagChipCard(
            tokens: tokens,
            tag: Tag(id: "t", name: "season", path: "season", createdAt: Date(), updatedAt: Date()),
            onRemove: { _ in })
        let image = try #require(ChipInk.render(card.padding(6).background(tokens.surface), dark: dark))
        let ink = try #require(ChipInk.measure(image), "the card drew a label and a ×")
        let offset = ink.crossMiddle - ink.labelMiddle
        #expect(abs(offset) <= Self.tolerance,
                "\(voice) \(dark ? "dark" : "light"): the ×'s ink centre stands \(offset) pt from the label's x-height middle (+ is below)")
    }
}

/// The off-screen ink oracle (a test instrument, shared by nothing else).
@MainActor
enum ChipInk {
    static let scale: CGFloat = 3

    /// AppKit's own drawing path, OFF-SCREEN: a hosting view in a borderless
    /// window that is never ordered in.
    static func render(_ view: some View, dark: Bool) -> CGImage? {
        let host = NSHostingView(rootView: AnyView(view.environment(\.colorScheme, dark ? .dark : .light)))
        host.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        let size = host.fittingSize
        host.frame = CGRect(origin: .zero, size: size)
        let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        defer { window.close() }
        host.layoutSubtreeIfNeeded()
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(size.width * scale), pixelsHigh: Int(size.height * scale),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 32) else { return nil }
        rep.size = size
        host.cacheDisplay(in: host.bounds, to: rep)
        return rep.cgImage
    }

    struct Ink { let labelMiddle: CGFloat; let crossMiddle: CGFloat }

    /// The label's and the ×'s ink, in points from the image's top: the chip's
    /// box is the ink that differs from the page; its fill is the commonest
    /// colour inside; the glyph ink is what differs from the fill; columns of
    /// ink merge across gaps under 2 pt (letters), so the 3-pt gap before the
    /// × leaves it the last run.
    static func measure(_ image: CGImage) -> Ink? {
        let w = image.width, h = image.height
        guard let data = image.dataProvider?.data, let ptr = CFDataGetBytePtr(data) else { return nil }
        let bpr = image.bytesPerRow, bpp = image.bitsPerPixel / 8
        func px(_ x: Int, _ y: Int) -> (Int, Int, Int) {
            let o = y * bpr + x * bpp
            return (Int(ptr[o]), Int(ptr[o + 1]), Int(ptr[o + 2]))
        }
        func differs(_ a: (Int, Int, Int), _ b: (Int, Int, Int), _ t: Int) -> Bool {
            abs(a.0 - b.0) + abs(a.1 - b.1) + abs(a.2 - b.2) > t
        }
        let page = px(2, 2)
        var minX = w, maxX = 0, minY = h, maxY = 0
        for y in 0..<h { for x in 0..<w where differs(px(x, y), page, 12) {
            minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
        } }
        guard maxX - minX > 12, maxY - minY > 12 else { return nil }
        let x0 = minX + 6, x1 = maxX - 6, y0 = minY + 6, y1 = maxY - 6
        var counts: [Int: Int] = [:]
        for y in y0...y1 { for x in x0...x1 {
            let p = px(x, y); counts[(p.0 << 16) | (p.1 << 8) | p.2, default: 0] += 1
        } }
        guard let key = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        let fill = ((key >> 16) & 0xFF, (key >> 8) & 0xFF, key & 0xFF)
        var colInk = [Bool](repeating: false, count: w)
        for x in x0...x1 { for y in y0...y1 where differs(px(x, y), fill, 60) { colInk[x] = true; break } }
        var runs: [(Int, Int)] = []
        var x = x0
        while x <= x1 {
            if colInk[x] {
                let start = x
                while x <= x1 && colInk[x] { x += 1 }
                if let last = runs.last, start - last.1 < Int(2 * scale) {
                    runs[runs.count - 1].1 = x - 1
                } else {
                    runs.append((start, x - 1))
                }
            } else {
                x += 1
            }
        }
        guard runs.count >= 2 else { return nil }
        func middle(_ from: Int, _ to: Int) -> CGFloat {
            var top = h, bottom = 0
            for x in from...to { for y in y0...y1 where differs(px(x, y), fill, 60) {
                top = min(top, y); bottom = max(bottom, y)
            } }
            return CGFloat(top + bottom) / 2 / scale
        }
        return Ink(
            labelMiddle: middle(runs[0].0, runs[runs.count - 2].1),
            crossMiddle: middle(runs[runs.count - 1].0, runs[runs.count - 1].1))
    }
}
