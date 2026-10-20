import Foundation

// Small deterministic math every scene shares: a 2-D vector, a seedable RNG (so offscreen renders and
// tests repeat exactly), and smooth value noise (the source of every "movement from code, never a loop").

public struct Vec2: Sendable, Equatable {
    public var x: Double
    public var y: Double
    public init(_ x: Double, _ y: Double) { self.x = x; self.y = y }
    public static let zero = Vec2(0, 0)
    public static func angle(_ a: Double) -> Vec2 { Vec2(cos(a), sin(a)) }

    public var length: Double { (x * x + y * y).squareRoot() }
    public var normalized: Vec2 {
        let l = length
        return l > 1e-9 ? Vec2(x / l, y / l) : .zero
    }
    /// The left-hand perpendicular (y-down screen space).
    public var perpendicular: Vec2 { Vec2(-y, x) }
    public var heading: Double { atan2(y, x) }
    public var isFinite: Bool { x.isFinite && y.isFinite }

    public static func + (a: Vec2, b: Vec2) -> Vec2 { Vec2(a.x + b.x, a.y + b.y) }
    public static func - (a: Vec2, b: Vec2) -> Vec2 { Vec2(a.x - b.x, a.y - b.y) }
    public static func * (a: Vec2, k: Double) -> Vec2 { Vec2(a.x * k, a.y * k) }
    public static func += (a: inout Vec2, b: Vec2) { a = a + b }
    public static func -= (a: inout Vec2, b: Vec2) { a = a - b }
    public func dot(_ b: Vec2) -> Double { x * b.x + y * b.y }
    public func distance(to b: Vec2) -> Double { (self - b).length }
    public func rotated(by a: Double) -> Vec2 {
        let c = cos(a), s = sin(a)
        return Vec2(x * c - y * s, x * s + y * c)
    }
    public static func lerp(_ a: Vec2, _ b: Vec2, _ t: Double) -> Vec2 { a + (b - a) * t }
}

/// The signed smallest rotation from `a` to `b`, in (-π, π].
public func angleDelta(from a: Double, to b: Double) -> Double {
    var d = (b - a).truncatingRemainder(dividingBy: 2 * .pi)
    if d > .pi { d -= 2 * .pi }
    if d <= -.pi { d += 2 * .pi }
    return d
}

/// Frame-rate-independent exponential approach: the fraction of the gap to close this step.
@inline(__always)
public func approach(_ dt: Double, _ tau: Double) -> Double { 1 - exp(-dt / max(1e-6, tau)) }

@inline(__always)
public func clamp<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T { min(hi, max(lo, v)) }

@inline(__always)
public func smoothstep(_ e0: Double, _ e1: Double, _ x: Double) -> Double {
    let t = clamp((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)
}

/// SplitMix64: tiny, fast, fully deterministic for a seed.
public struct SplitMix64: RandomNumberGenerator, Sendable {
    private var state: UInt64
    public init(seed: UInt64) { state = seed }
    public mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
    public mutating func unit() -> Double { Double(next() >> 11) / Double(1 << 53) }
    public mutating func range(_ lo: Double, _ hi: Double) -> Double { lo + (hi - lo) * unit() }
    public mutating func chance(_ p: Double) -> Bool { unit() < p }
    public mutating func int(_ lo: Int, _ hi: Int) -> Int { lo + Int(next() % UInt64(hi - lo + 1)) }
}

public enum Noise {
    @inline(__always)
    static func hash(_ i: Int, _ j: Int, _ seed: UInt64) -> Double {
        var h = UInt64(bitPattern: Int64(i)) &* 0x9E37_79B9_7F4A_7C15
        h ^= UInt64(bitPattern: Int64(j)) &* 0xC2B2_AE3D_27D4_EB4F
        h ^= seed &* 0x1656_67B1_9E37_79F9
        h = (h ^ (h >> 29)) &* 0xBF58_476D_1CE4_E5B9
        h ^= h >> 32
        return Double(h & 0xFFFFFF) / Double(0xFFFFFF)
    }

    @inline(__always)
    static func fade(_ t: Double) -> Double { t * t * t * (t * (t * 6 - 15) + 10) }

    /// Smooth 1-D value noise in [0, 1].
    public static func smooth(_ x: Double, seed: UInt64) -> Double {
        let i = Int(x.rounded(.down)), f = x - x.rounded(.down)
        let a = hash(i, 0, seed), b = hash(i + 1, 0, seed)
        return a + (b - a) * fade(f)
    }

    /// Smooth 2-D value noise in [0, 1].
    public static func smooth(_ x: Double, _ y: Double, seed: UInt64) -> Double {
        let xf = x.rounded(.down), yf = y.rounded(.down)
        let i = Int(xf), j = Int(yf)
        let u = fade(x - xf), v = fade(y - yf)
        let a = hash(i, j, seed), b = hash(i + 1, j, seed)
        let c = hash(i, j + 1, seed), d = hash(i + 1, j + 1, seed)
        let top = a + (b - a) * u, bottom = c + (d - c) * u
        return top + (bottom - top) * v
    }

    /// Two octaves of 1-D noise, centred on zero: roughly [-1, 1]. The wander signal.
    public static func wander(_ t: Double, seed: UInt64) -> Double {
        let n = smooth(t, seed: seed) * 0.7 + smooth(t * 2.3 + 17.1, seed: seed &+ 1) * 0.3
        return n * 2 - 1
    }
}

/// A precomputed tileable noise texture (bilinear-sampled), so a full-screen field costs a few lookups
/// per pixel instead of a noise evaluation.
public struct TileNoise: Sendable {
    public let size: Int
    let values: [Float]

    /// `period` lattice cells across the tile; two octaves.
    public init(size: Int, period: Int, seed: UInt64) {
        self.size = size
        var v = [Float](repeating: 0, count: size * size)
        func lattice(_ x: Double, _ y: Double, _ p: Int, _ s: UInt64) -> Double {
            let xf = x.rounded(.down), yf = y.rounded(.down)
            let i = Int(xf), j = Int(yf)
            let u = Noise.fade(x - xf), w = Noise.fade(y - yf)
            func h(_ a: Int, _ b: Int) -> Double { Noise.hash(((a % p) + p) % p, ((b % p) + p) % p, s) }
            let top = h(i, j) + (h(i + 1, j) - h(i, j)) * u
            let bottom = h(i, j + 1) + (h(i + 1, j + 1) - h(i, j + 1)) * u
            return top + (bottom - top) * w
        }
        for y in 0..<size {
            for x in 0..<size {
                let fx = Double(x) / Double(size), fy = Double(y) / Double(size)
                let a = lattice(fx * Double(period), fy * Double(period), period, seed)
                let b = lattice(fx * Double(period * 2), fy * Double(period * 2), period * 2, seed &+ 7)
                v[y * size + x] = Float(a * 0.68 + b * 0.32)
            }
        }
        values = v
    }

    @inline(__always)
    public func sample(_ x: Double, _ y: Double) -> Float {
        let xf = x.rounded(.down), yf = y.rounded(.down)
        let m = size - 1
        let i = Int(xf) & m, j = Int(yf) & m
        let i1 = (i + 1) & m, j1 = (j + 1) & m
        let u = Float(x - xf), w = Float(y - yf)
        let a = values[j * size + i], b = values[j * size + i1]
        let c = values[j1 * size + i], d = values[j1 * size + i1]
        let top = a + (b - a) * u, bottom = c + (d - c) * u
        return top + (bottom - top) * w
    }
}
