//
//  GlyphRainBackdrop.swift
//  Variorum
//
//  17u (2026-09-25, her ask between rounds) — THE LOCKED LOBBY'S BACKDROP.
//  Her words: *"replace the lock screen decoration with code that animates
//  a view of top down lines of code, kind of a matrix style decoration of
//  letters and numbers flickering … black and white on the lock screen and
//  shouldn't be distracting from the central pane."* This retires the
//  tessellating endpaper tile from the lobby (the asset left the bundle
//  with it; a grep pin keeps it out).
//
//  THE SHAPE: columns of monospaced glyphs — digits, letters, a little code
//  punctuation — falling top-down at unequal speeds, each a bright head with
//  a trail fading to nothing, the trail's glyphs flickering now and then.
//  Monochrome by construction: the ONE ink is the voice's `ink` token over
//  the voice's `room` (black on paper in light; white on the black room in
//  dark — R51), never a literal colour. It stays an undertone: the head
//  never exceeds a third of the ink's strength, the rates are slow, and the
//  room washes back in behind the card so the pane stays the loudest thing.
//
//  THE BRAIN IS PURE: a frame is a function of (grid, time, seed) — no stored
//  state to drift, nothing to reset, the same shape the travelling-dots
//  indicator takes. Reduce Motion ⇒ the timeline is paused and one settled
//  frame stands still (the seed's own moment, mid-fall, so the still frame
//  is populated rather than blank).
//

import SwiftUI

/// THE BRAIN (pure; the pin reads it). Each column runs on its own cycle
/// — fall the height of the grid, trail out the bottom, wait a while above
/// the top, fall again — with speed, trail length, pause and phase all
/// hashed from the column's index under one seed, so no two columns keep
/// step and the same seed always draws the same rain.
nonisolated struct GlyphRain: Sendable {
    /// The alphabet — letters and numbers, plus the punctuation that makes a
    /// column read as a line of code. ASCII only, so every glyph fills one
    /// monospaced cell.
    nonisolated static let glyphs: [Character] = Array(
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{}()[]<>=;:/*+-.#$%&_")

    /// One lit cell of a frame.
    nonisolated struct Cell: Equatable, Sendable {
        var column: Int
        var row: Int
        var glyph: Character
        /// 1 at the head of a column, decaying to 0 along the trail.
        var intensity: Double
    }

    /// Rows per second — slow enough to read as rain, not static.
    nonisolated static let speedRange: ClosedRange<Double> = 2.5...7.5
    /// Trail length in rows.
    nonisolated static let trailRange: ClosedRange<Int> = 6...24
    /// The pause above the top between falls, in rows of travel.
    nonisolated static let pauseRange: ClosedRange<Int> = 8...70
    /// How often a trail glyph swaps (per second) — the flicker.
    nonisolated static let trailFlickerHz: Double = 1.4
    /// The head swaps faster — the classic falling-code shimmer.
    nonisolated static let headFlickerHz: Double = 5

    var columns: Int
    var rows: Int
    var seed: UInt64

    /// Every lit cell at `time` (seconds — any monotonic clock; only
    /// differences matter). Deterministic for the same inputs.
    func cells(at time: Double) -> [Cell] {
        guard columns > 0, rows > 0 else { return [] }
        var out: [Cell] = []
        out.reserveCapacity(columns * 12)
        for column in 0..<columns {
            let lane = Lane(column: column, seed: seed)
            let head = lane.head(at: time, rows: rows)
            // Rows in (head - trail, head] that are on the grid.
            let top = max(0, Int((head - Double(lane.trail)).rounded(.down)) + 1)
            let bottom = min(rows - 1, Int(head.rounded(.down)))
            guard top <= bottom else { continue }
            for row in top...bottom {
                let distance = head - Double(row)          // 0…trail
                let isHead = row == bottom && distance < 1
                let fade = 1 - distance / Double(lane.trail)
                let intensity = isHead ? 1 : max(0.04, fade * fade * 0.7)
                let hz = isHead ? Self.headFlickerHz : Self.trailFlickerHz
                let tick = UInt64((time * hz + lane.jitter(row: row) * 7).rounded(.down))
                let index = Int(Self.mix(seed, UInt64(column), UInt64(row), tick) % UInt64(Self.glyphs.count))
                out.append(Cell(column: column, row: row, glyph: Self.glyphs[index], intensity: intensity))
            }
        }
        return out
    }

    /// One column's cycle parameters, all hashed from its index.
    nonisolated struct Lane: Sendable {
        let speed: Double
        let trail: Int
        let pause: Int
        let phase: Double
        private let column: Int
        private let seed: UInt64

        init(column: Int, seed: UInt64) {
            self.column = column
            self.seed = seed
            speed = GlyphRain.unit(seed, UInt64(column), 1).lerp(GlyphRain.speedRange)
            trail = Int(GlyphRain.unit(seed, UInt64(column), 2).lerp(
                Double(GlyphRain.trailRange.lowerBound)...Double(GlyphRain.trailRange.upperBound)).rounded())
            pause = Int(GlyphRain.unit(seed, UInt64(column), 3).lerp(
                Double(GlyphRain.pauseRange.lowerBound)...Double(GlyphRain.pauseRange.upperBound)).rounded())
            phase = GlyphRain.unit(seed, UInt64(column), 4)
        }

        /// The head's row at `time`, as a continuous value. Negative while
        /// the column waits above the top; past `rows + trail` it has left
        /// the grid entirely and the cycle wraps.
        func head(at time: Double, rows: Int) -> Double {
            let cycle = Double(rows + trail + pause)
            let travelled = (time * speed + phase * cycle).truncatingRemainder(dividingBy: cycle)
            return travelled - Double(pause)
        }

        /// A per-cell phase offset so trail glyphs never flicker in unison.
        func jitter(row: Int) -> Double {
            GlyphRain.unit(seed, UInt64(column), 100 + UInt64(row))
        }
    }

    // MARK: - Hashing

    /// SplitMix64-style mixing over the seed and up to three lanes of input.
    nonisolated static func mix(_ a: UInt64, _ b: UInt64, _ c: UInt64 = 0, _ d: UInt64 = 0) -> UInt64 {
        var z = a &+ 0x9E37_79B9_7F4A_7C15 &* (b &+ 1)
        z ^= c &* 0xBF58_476D_1CE4_E5B9
        z ^= d &* 0x94D0_49BB_1331_11EB
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A hash folded into 0..<1.
    nonisolated static func unit(_ a: UInt64, _ b: UInt64, _ c: UInt64) -> Double {
        Double(mix(a, b, c) >> 11) / Double(1 << 53)
    }
}

nonisolated private extension Double {
    func lerp(_ range: ClosedRange<Double>) -> Double {
        range.lowerBound + self * (range.upperBound - range.lowerBound)
    }
}

/// The lobby's backdrop view: the rain drawn in one `Canvas`, driven by a
/// timeline at a deliberately low frame rate (the stepped cadence IS the
/// look), with the room washing back in behind the card.
struct GlyphRainBackdrop: View {
    var tokens: VoiceTokens
    var scheme: ColorScheme
    /// Where the card sits, as a fraction of the height — the wash is
    /// centred there so the pane always reads clear.
    var cardCentreY: CGFloat = 0.36

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var seed = UInt64.random(in: 0...UInt64.max)
    @State private var started = Date()

    nonisolated static let cellSize = CGSize(width: 10, height: 17)
    nonisolated static let fontSize: CGFloat = 12
    /// One frame every ~70 ms — the falling-code step.
    nonisolated static let frameInterval: Double = 1.0 / 14
    /// The head's strength as a fraction of the ink; everything else is
    /// dimmer. Dark can carry a touch more without shouting (R51's black
    /// room swallows a lot).
    nonisolated static func peakOpacity(dark: Bool) -> Double { dark ? 0.42 : 0.30 }

    var body: some View {
        SwiftUI.TimelineView(.animation(minimumInterval: Self.frameInterval, paused: reduceMotion)) { context in
            // Under Reduce Motion the paused timeline hands back one date;
            // a fixed offset puts that still frame mid-fall.
            let time = reduceMotion ? 40 : context.date.timeIntervalSince(started) + 40
            Canvas(rendersAsynchronously: true) { canvas, size in
                let rain = GlyphRain(
                    columns: Int(size.width / Self.cellSize.width) + 1,
                    rows: Int(size.height / Self.cellSize.height) + 1,
                    seed: seed)
                let peak = Self.peakOpacity(dark: scheme == .dark)
                let font = Font.system(size: Self.fontSize, weight: .regular, design: .monospaced)
                var resolved: [Character: GraphicsContext.ResolvedText] = [:]
                for cell in rain.cells(at: time) {
                    let text = resolved[cell.glyph] ?? {
                        let r = canvas.resolve(Text(String(cell.glyph)).font(font).foregroundStyle(tokens.ink))
                        resolved[cell.glyph] = r
                        return r
                    }()
                    var layer = canvas
                    layer.opacity = cell.intensity * peak
                    layer.draw(
                        text,
                        at: CGPoint(
                            x: CGFloat(cell.column) * Self.cellSize.width,
                            y: CGFloat(cell.row) * Self.cellSize.height),
                        anchor: .topLeading)
                }
            }
        }
        .overlay {
            // The wash: the room rises behind the card and thins toward the
            // edges, so the rain frames the pane rather than competing with it.
            GeometryReader { geo in
                RadialGradient(
                    colors: [tokens.room.opacity(0.85), tokens.room.opacity(0.45), tokens.room.opacity(0)],
                    center: UnitPoint(x: 0.5, y: cardCentreY),
                    startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height) * 0.62)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
