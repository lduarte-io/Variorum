import Foundation

// One koi seen from overhead: a spine of joints the head drags (follow-the-leader, with a joint-angle
// limit so it bends instead of folding), a body width profile, fins, and a variety pattern whose
// "colours" are dither densities. The swimming wave is applied at draw time, so the physics stays a
// plain chain.

enum KoiVariety: CaseIterable {
    case kohaku, sanke, showa, tancho, ogon, chagoi, asagi, shiroUtsuri, kigoi

    var weight: Double {
        switch self {
        case .kohaku: 3
        case .sanke: 2
        case .showa: 1.5
        case .ogon: 1.5
        case .tancho: 1
        case .asagi: 1
        case .shiroUtsuri: 1
        case .chagoi: 0.8
        case .kigoi: 0.7
        }
    }

    static func pick(_ rng: inout SplitMix64) -> KoiVariety {
        let total = allCases.reduce(0) { $0 + $1.weight }
        var r = rng.unit() * total
        for v in allCases {
            r -= v.weight
            if r < 0 { return v }
        }
        return .kohaku
    }
}

/// A koi's markings, precomputed once on an (along × across) grid so drawing is a lookup.
struct KoiPattern {
    static let alongSamples = 96
    static let acrossSamples = 25
    let variety: KoiVariety
    private let grid: [Float]

    init(variety: KoiVariety, length: Double, seed: UInt64) {
        self.variety = variety
        var rng = SplitMix64(seed: seed)
        let ox = rng.range(0, 100), oy = rng.range(0, 100)
        let ox2 = rng.range(0, 100), oy2 = rng.range(0, 100)
        var g = [Float](repeating: 0, count: Self.alongSamples * Self.acrossSamples)
        for ia in 0..<Self.alongSamples {
            let s = Double(ia) / Double(Self.alongSamples - 1) * Koi.bodyEnd
            for ic in 0..<Self.acrossSamples {
                let u = Double(ic) / Double(Self.acrossSamples - 1) * 2 - 1
                let acrossPx = u * Koi.halfWidth(s) * length
                g[ia * Self.acrossSamples + ic] = Float(Self.base(variety, s: s, u: u, alongPx: s * length,
                                                                  acrossPx: acrossPx,
                                                                  o: (ox, oy, ox2, oy2), seed: seed))
            }
        }
        grid = g
    }

    /// `s` in [0, bodyEnd], `u` in [-1, 1].
    @inline(__always)
    func value(s: Double, u: Double) -> Float {
        let ia = clamp(Int(s / Koi.bodyEnd * Double(Self.alongSamples - 1) + 0.5), 0, Self.alongSamples - 1)
        let ic = clamp(Int((u + 1) / 2 * Double(Self.acrossSamples - 1) + 0.5), 0, Self.acrossSamples - 1)
        return grid[ia * Self.acrossSamples + ic]
    }

    // Dither densities standing in for colours: white 1.0, "hi" (red/orange) ~0.45, sumi (black) ~0.12.
    static let white = 1.0, hi = 0.5, sumi = 0.08

    static func scaleEdge(_ alongPx: Double, _ acrossPx: Double) -> Bool {
        let p = alongPx / 3.2, q = acrossPx / 3.2
        let e1 = abs((p + q) - (p + q).rounded(.down) - 0.5)
        let e2 = abs((p - q) - (p - q).rounded(.down) - 0.5)
        return max(e1, e2) > 0.40
    }

    static func base(_ v: KoiVariety, s: Double, u: Double, alongPx: Double, acrossPx: Double,
                     o: (Double, Double, Double, Double), seed: UInt64) -> Double {
        let patch = Noise.smooth(s * 5.0 + o.0, u * 1.3 + o.1, seed: seed)
        let spot = Noise.smooth(s * 12 + o.2, u * 2.8 + o.3, seed: seed &+ 3)
        let head = s < 0.15
        switch v {
        case .kohaku:
            return patch > (head ? 0.42 : 0.52) ? hi : white
        case .sanke:
            if spot > 0.76, abs(u) < 0.8, s > 0.16 { return sumi }
            return patch > (head ? 0.44 : 0.53) ? hi : white
        case .showa:
            if spot > 0.6 { return white }
            return patch > 0.5 ? hi : 0.2
        case .tancho:
            let ds = (s - 0.075) / 0.05, du = u / 0.7
            return ds * ds + du * du < 1 ? hi : white
        case .ogon:
            return scaleEdge(alongPx, acrossPx) ? 1.0 : 0.84
        case .chagoi:
            return scaleEdge(alongPx, acrossPx) ? 0.55 : 0.36
        case .asagi:
            if head { return 0.88 }
            if abs(u) > 0.62 { return 0.7 }
            return scaleEdge(alongPx, acrossPx) ? 0.85 : 0.48
        case .shiroUtsuri:
            return patch > 0.44 ? sumi + 0.06 : white
        case .kigoi:
            return 0.72
        }
    }
}

final class Koi {
    static let joints = 14
    /// Where the body ends and the tail fin begins, as a fraction of the length.
    static let bodyEnd = 0.8

    enum Mode { case cruise, drift, pause, rise, dart }

    var spine: [Vec2]
    var heading: Double
    var speed = 0.0
    var targetSpeed = 0.0
    var depth: Double
    var targetDepth: Double
    var phase: Double
    var finPhase: Double
    let length: Double
    let segLen: Double
    let girth: Double
    let pace: Double
    let pattern: KoiPattern
    let seed: UInt64
    let noiseOffset: Double

    var mode: Mode = .cruise
    var modeLeft: Double
    var gulped = false
    var dartTurn = 0.0
    var dartTurnLeft = 0.0
    var interestLeaf: Int?
    var interestLeft = 0.0

    init(head: Vec2, heading: Double, length: Double, rng: inout SplitMix64, variety: KoiVariety? = nil) {
        self.heading = heading
        self.length = length
        segLen = length / Double(Self.joints - 1)
        girth = rng.range(0.9, 1.15)
        pace = rng.range(0.82, 1.18)
        seed = rng.next()
        noiseOffset = rng.range(0, 1000)
        pattern = KoiPattern(variety: variety ?? KoiVariety.pick(&rng), length: length, seed: rng.next())
        depth = rng.range(0.1, 0.6)
        targetDepth = depth
        phase = rng.range(0, 2 * .pi)
        finPhase = rng.range(0, 2 * .pi)
        modeLeft = rng.range(2, 12)
        let back = Vec2.angle(heading + .pi)
        spine = (0..<Self.joints).map { head + back * (Double($0) * length / Double(Self.joints - 1)) }
        speed = 0.3 * length * pace
        targetSpeed = speed
    }

    var head: Vec2 { spine[0] }
    var forward: Vec2 { .angle(heading) }
    var middle: Vec2 { spine[Self.joints / 2] }

    /// Half the body's width at `s`, as a fraction of the length (before girth and depth).
    static func halfWidth(_ s: Double) -> Double {
        let pts: [(Double, Double)] = [(0, 0.0), (0.025, 0.056), (0.07, 0.08), (0.13, 0.096), (0.22, 0.104),
                                       (0.32, 0.104), (0.45, 0.094), (0.58, 0.074), (0.70, 0.05), (0.80, 0.03)]
        if s <= 0 { return 0 }
        for k in 1..<pts.count where s <= pts[k].0 {
            let (s0, w0) = pts[k - 1], (s1, w1) = pts[k]
            let t = (s - s0) / (s1 - s0)
            return w0 + (w1 - w0) * (k == 1 ? t.squareRoot() : t * t * (3 - 2 * t))
        }
        return pts[pts.count - 1].1
    }

    /// Drag the chain behind the head: every link keeps its length, and no joint bends past ~17°.
    func follow() {
        let limit = 0.30
        for i in 1..<Self.joints {
            var dir = spine[i] - spine[i - 1]
            if dir.length < 1e-6 { dir = Vec2.angle(heading + .pi) }
            var ang = dir.heading
            let ref = i == 1 ? heading + .pi : (spine[i - 1] - spine[i - 2]).heading
            let d = angleDelta(from: ref, to: ang)
            if abs(d) > limit { ang = ref + clamp(d, -limit, limit) }
            spine[i] = spine[i - 1] + Vec2.angle(ang) * segLen
        }
    }

    // MARK: Drawing

    func draw(into canvas: Canvas) {
        let n = Self.joints
        let activity = clamp(0.25 + speed / (0.45 * length), 0.25, 1.4)
        let amp = 0.07 * length * activity
        // The swimming wave: a lateral travelling sine, growing toward the tail.
        var pts = spine
        var tangents = [Vec2](repeating: .zero, count: n)
        for i in 0..<n {
            let a = spine[max(0, i - 1)], b = spine[min(n - 1, i + 1)]
            tangents[i] = (a - b).normalized // pointing toward the head
        }
        for i in 0..<n {
            let s = Double(i) / Double(n - 1)
            let off = amp * pow(s, 1.4) * sin(phase - s * 5.5)
            pts[i] = spine[i] + tangents[i].perpendicular * off
        }
        for i in 0..<n {
            let a = pts[max(0, i - 1)], b = pts[min(n - 1, i + 1)]
            let t = (a - b).normalized
            tangents[i] = t.length > 0 ? t : tangents[i]
        }

        let depthFactor = 1 - 0.52 * depth
        let widthScale = (1 - 0.12 * depth) * girth
        let df = Float(depthFactor)

        // Point along the body at fraction s: centre, tangent (toward the head), normal.
        func frame(_ s: Double) -> (Vec2, Vec2, Vec2) {
            let x = clamp(s, 0, 1) * Double(n - 1)
            let i = min(n - 2, Int(x)), t = x - Double(i)
            let c = Vec2.lerp(pts[i], pts[i + 1], t)
            let tan = Vec2.lerp(tangents[i], tangents[i + 1], t).normalized
            return (c, tan, tan.perpendicular)
        }

        let step = 0.45
        let alongSteps = Int(length / step)

        // Tail fin: translucent, forked, swishing with the wave.
        for k in 0...alongSteps {
            let s = Double(k) / Double(alongSteps)
            guard s >= Self.bodyEnd - 0.01 else { continue }
            let (c, _, nrm) = frame(s)
            let tf = (s - Self.bodyEnd) / (1 - Self.bodyEnd)
            let f = (0.03 + 0.1 * pow(tf, 0.65)) * length * widthScale
            var a = -f
            while a <= f {
                let un = a / max(f, 1e-6)
                let notch = s > 0.94 && abs(un) < (s - 0.94) / 0.06 * 0.45
                if !notch {
                    canvas.plot(c + nrm * a, (abs(un) > 0.8 ? 0.55 : 0.3) * df, .lighten)
                }
                a += step
            }
        }

        // Pectoral fins (paddling harder when slow) and small pelvic fins.
        let paddle = 0.16 + 0.32 * (1.4 - activity) / 1.15
        for (sFin, len, wid, spread, amp2) in [(0.17, 0.17, 0.07, 0.95, paddle), (0.46, 0.085, 0.032, 1.05, 0.1)] {
            let (c, tan, nrm) = frame(sFin)
            let hw = Self.halfWidth(sFin) * length * widthScale
            for side in [-1.0, 1.0] {
                let root = c + nrm * (side * hw * 0.8)
                let swing = spread + amp2 * sin(finPhase + side * 0.6)
                let dir = (tan * -1).rotated(by: -side * swing)
                let across = dir.perpendicular
                let fl = len * length, fw = wid * length
                var r = 0.0
                while r <= fl {
                    let w = fw * pow(sin(.pi * pow(r / fl, 0.75)), 0.6)
                    var a = -w
                    while a <= w {
                        canvas.plot(root + dir * r + across * a, 0.3 * df, .lighten)
                        a += step
                    }
                    r += step
                }
            }
        }

        // The body: pattern × rounded-back light inside a crisp bright outline (the silhouette has to
        // read in 1 bit whatever the markings), dimmer and narrower when deep.
        for k in 0...alongSteps {
            let s = Double(k) / Double(alongSteps)
            guard s <= Self.bodyEnd else { break }
            let (c, _, nrm) = frame(s)
            let hw = Self.halfWidth(s) * length * widthScale
            guard hw > 0.2 else { continue }
            var a = -hw
            while a <= hw {
                let un = a / hw
                let p = pattern.value(s: s, u: un)
                let v: Float = hw - abs(a) < 0.9 ? max(p, 0.85) : p * Float(0.86 + 0.14 * (1 - un * un))
                canvas.plot(c + nrm * a, v * df, .set)
                a += step
            }
        }

        // Eyes: one dark pixel each side of the head (big enough koi only).
        if length > 26 {
            let (c, _, nrm) = frame(0.06)
            let hw = Self.halfWidth(0.06) * length * widthScale
            canvas.plot(c + nrm * (hw * 0.7), 0, .set)
            canvas.plot(c - nrm * (hw * 0.7), 0, .set)
        }
    }
}
