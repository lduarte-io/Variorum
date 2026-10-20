import Foundation

// The drawing surface every scene paints into: an intensity field (0 = black, 1 = white) at the scene's
// small logical resolution, ordered-dithered into the 1-bit frame the host shows. Exact 0 and 1 dither
// exactly, so a scene that wants hard 1-bit pixels (glyphs, outlines) gets them; anything between is
// shading. Coordinates are pixels, y down, origin top-left.

public struct PixelSize: Sendable, Equatable {
    public var width: Int
    public var height: Int
    public init(width: Int, height: Int) {
        self.width = max(1, width)
        self.height = max(1, height)
    }
    public var count: Int { width * height }
}

public enum Blend: Sendable {
    /// Replace what is there (opaque paint).
    case set
    /// Add and clamp at 1 (light, glints, translucent fins).
    case add
    /// Keep the brighter of the two.
    case lighten
}

public final class Canvas {
    public let size: PixelSize
    public var width: Int { size.width }
    public var height: Int { size.height }
    /// Row-major intensities, `width * height` of them.
    public let pixels: UnsafeMutableBufferPointer<Float>

    public init(size: PixelSize) {
        self.size = size
        pixels = .allocate(capacity: size.count)
        pixels.initialize(repeating: 0)
    }

    deinit { pixels.deallocate() }

    public func clear(_ value: Float = 0) {
        pixels.update(repeating: value)
    }

    @inline(__always)
    public func value(_ x: Int, _ y: Int) -> Float {
        guard x >= 0, y >= 0, x < width, y < height else { return 0 }
        return pixels[y * width + x]
    }

    @inline(__always)
    public func plot(_ x: Int, _ y: Int, _ v: Float, _ blend: Blend = .set) {
        guard x >= 0, y >= 0, x < width, y < height else { return }
        let i = y * width + x
        switch blend {
        case .set: pixels[i] = v
        case .add: pixels[i] = min(1, pixels[i] + v)
        case .lighten: pixels[i] = max(pixels[i], v)
        }
    }

    /// Plots the pixel containing a sub-pixel point.
    @inline(__always)
    public func plot(_ p: Vec2, _ v: Float, _ blend: Blend = .set) {
        plot(ifloor(p.x), ifloor(p.y), v, blend)
    }

    /// The pixel rows (or columns) a span `[lo, hi]` touches, clipped to the canvas; nil when none.
    @inline(__always)
    public func clipped(_ lo: Double, _ hi: Double, limit: Int) -> ClosedRange<Int>? {
        let a = max(0, ifloor(lo)), b = min(limit - 1, ifloor(hi))
        return a <= b ? a...b : nil
    }

    public func fillDisc(center c: Vec2, radius r: Double, _ v: Float, _ blend: Blend = .set) {
        guard let ys = clipped(c.y - r, c.y + r, limit: height),
              let xs = clipped(c.x - r, c.x + r, limit: width) else { return }
        let r2 = r * r
        for y in ys {
            let dy = Double(y) + 0.5 - c.y
            for x in xs {
                let dx = Double(x) + 0.5 - c.x
                if dx * dx + dy * dy <= r2 { plot(x, y, v, blend) }
            }
        }
    }

    /// A one-pixel ring, sampled densely enough to leave no gaps.
    public func ring(center c: Vec2, radius r: Double, _ v: Float, _ blend: Blend = .add) {
        guard r > 0 else { return }
        let steps = max(12, Int(2 * .pi * r * 1.5))
        var last = (Int.min, Int.min)
        for k in 0..<steps {
            let a = Double(k) / Double(steps) * 2 * .pi
            let x = ifloor(c.x + r * cos(a)), y = ifloor(c.y + r * sin(a))
            if (x, y) == last { continue }
            last = (x, y)
            plot(x, y, v, blend)
        }
    }

    public func line(from a: Vec2, to b: Vec2, _ v: Float, _ blend: Blend = .set) {
        let d = b - a
        let steps = max(1, Int(max(abs(d.x), abs(d.y)) * 1.5))
        for k in 0...steps {
            plot(a + d * (Double(k) / Double(steps)), v, blend)
        }
    }

    /// Ordered (Bayer 4×4) dithering into a 1-bit frame stored one byte per pixel (0 or 255), the
    /// layout a DeviceGray `CGImage` reads directly.
    public func dither(into frame: UnsafeMutableBufferPointer<UInt8>) {
        precondition(frame.count >= size.count)
        let w = width
        for y in 0..<height {
            let row = y * w
            let by = (y & 3) << 2
            for x in 0..<w {
                frame[row + x] = pixels[row + x] > Dither.bayer4[by | (x & 3)] ? 255 : 0
            }
        }
    }
}

/// `Int(floor(v))` that never traps: non-finite or absurd values land far off-canvas instead.
@inline(__always)
public func ifloor(_ v: Double) -> Int {
    guard v.isFinite else { return Int.min / 4 }
    return Int(min(1e9, max(-1e9, v)).rounded(.down))
}

public enum Dither {
    /// Thresholds strictly inside (0, 1): intensity 0 never lights a pixel and 1 always does.
    public static let bayer4: [Float] = {
        let m: [Float] = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
        return m.map { ($0 + 0.5) / 16 }
    }()
}
