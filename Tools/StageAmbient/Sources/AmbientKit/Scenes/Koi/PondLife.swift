import Foundation

// Everything in the pond that isn't a koi: the water's drifting caustic web, lilypads (some flowering)
// riding a slow current, ripple rings, and the odd leaf that falls, floats, and sinks.

/// The water: two tileable noise fields drifting in different directions; where their sum crosses the
/// middle, a faint, sparse web of light (caustics) shows. Plus a few slow surface glints. Mostly black,
/// never still. The web changes slowly, so it is recomputed only every few frames and cached.
final class Water {
    /// The web is computed at 1/reduction resolution and bilinearly upsampled.
    static let reduction = 4
    let a: TileNoise
    let b: TileNoise
    let patches: TileNoise
    private var field: [Float] = []
    private var half: [Float] = []
    private let seed: UInt64
    private var fieldTime = -1.0
    private var glints: [Glint] = []
    private var rng: SplitMix64

    struct Glint {
        var position: Vec2
        var age: Double
        let life: Double
        let length: Int
    }

    init(seed: UInt64) {
        a = TileNoise(size: 128, period: 5, seed: seed)
        b = TileNoise(size: 128, period: 4, seed: seed &+ 11)
        patches = TileNoise(size: 64, period: 3, seed: seed &+ 23)
        rng = SplitMix64(seed: seed &+ 31)
        self.seed = seed &+ 41
    }

    func update(_ dt: Double, bounds: Vec2, unit: Double) {
        let target = Int(bounds.x * bounds.y / 9000)
        while glints.count < target {
            glints.append(Glint(position: Vec2(rng.range(0, bounds.x), rng.range(0, bounds.y)),
                                age: -rng.range(0, 6), life: rng.range(4, 9), length: rng.int(2, 4)))
        }
        for i in glints.indices {
            glints[i].age += dt
            glints[i].position.x += 0.6 * unit * dt
        }
        glints.removeAll { $0.age >= $0.life }
    }

    func draw(into canvas: Canvas, time t: Double, unit: Double) {
        let w = canvas.width, h = canvas.height
        // The web drifts about a pixel a second, so once a second is plenty.
        if field.count != w * h || t - fieldTime >= 1.0 || t < fieldTime {
            computeField(width: w, height: h, time: t, unit: unit)
        }
        for i in 0..<(w * h) { canvas.pixels[i] = field[i] }
        for g in glints where g.age > 0 {
            let v = Float(sin(.pi * g.age / g.life)) * 0.75
            for dx in 0..<g.length { canvas.plot(Int(g.position.x) + dx, Int(g.position.y), v, .lighten) }
        }
    }

    /// Caustics as the bright edges of a slowly wobbling cell pattern (where the two nearest cell
    /// points are nearly equidistant), computed at reduced resolution and upsampled.
    private func computeField(width w: Int, height h: Int, time t: Double, unit: Double) {
        if field.count != w * h { field = [Float](repeating: 0, count: w * h) }
        fieldTime = t
        let r = Water.reduction
        let hw = (w + r - 1) / r + 1, hh = (h + r - 1) / r + 1
        if half.count != hw * hh { half = [Float](repeating: 0, count: hw * hh) }
        let points = CellPoints(width: hw, height: hh, time: t, unit: unit, seed: seed)
        let cell = points.cell
        let kp = 0.03 * Double(r) / unit
        let op = Vec2(t * 0.2, -t * 0.12)
        for y in 0..<hh {
            let fy = Double(y)
            for x in 0..<hw {
                let fx = Double(x)
                let (f1, f2) = points.nearestTwo(fx, fy)
                let edge = f2.squareRoot() - f1.squareRoot()
                let e = 1 - edge / (0.16 * cell)
                var v: Float = 0
                if e > 0 {
                    let m = 0.3 + 0.9 * Double(patches.sample(fx * kp + op.x, fy * kp + op.y))
                    v = Float(e * e * 0.13 * m)
                }
                half[y * hw + x] = v
            }
        }
        // Bilinear upsample to full resolution.
        for y in 0..<h {
            let sy = Double(y) / Double(r), y0 = Int(sy), ty = Float(sy - Double(y0))
            for x in 0..<w {
                let sx = Double(x) / Double(r), x0 = Int(sx), tx = Float(sx - Double(x0))
                let a = half[y0 * hw + x0], b = half[y0 * hw + x0 + 1]
                let c = half[(y0 + 1) * hw + x0], d = half[(y0 + 1) * hw + x0 + 1]
                let top = a + (b - a) * tx, bottom = c + (d - c) * tx
                field[y * w + x] = top + (bottom - top) * ty
            }
        }
    }
}

/// The caustics' feature points: one per cell, jittered and slowly circling, the whole lattice drifting.
/// A point never leaves its own cell, so the two nearest points to any pixel lie in the 3×3 cells around
/// it.
struct CellPoints {
    let cell: Double
    let cols: Int
    let rows: Int
    let baseX: Int
    let baseY: Int
    let drift: Vec2
    private(set) var px: [Double]
    private(set) var py: [Double]

    init(width hw: Int, height hh: Int, time t: Double, unit: Double, seed: UInt64) {
        let r = Double(Water.reduction)
        cell = 26 / r * unit // reduced pixels per cell (≈ 26 design pixels)
        drift = Vec2(t * 0.7 / r * unit, t * 0.24 / r * unit)
        // A pixel's own cell can be up to ceil((hw - 1) / cell) past the base, and its search reaches one
        // more on each side: + 4 covers both margins.
        cols = Int(Double(hw) / cell) + 4
        rows = Int(Double(hh) / cell) + 4
        baseX = Int((drift.x / cell).rounded(.down))
        baseY = Int((drift.y / cell).rounded(.down))
        px = [Double](repeating: 0, count: cols * rows)
        py = px
        for r in 0..<rows {
            for c in 0..<cols {
                let gx = c - 1 + baseX, gy = r - 1 + baseY
                let h1 = Noise.hash(gx, gy, seed), h2 = Noise.hash(gx, gy, seed &+ 1)
                let h3 = Noise.hash(gx, gy, seed &+ 2)
                // Jitter + wobble stay inside [0.07, 0.93] of the cell.
                let jx = 0.5 + 0.18 * (h1 * 2 - 1) + 0.25 * sin(t * (0.12 + 0.12 * h3) + h1 * 6.28)
                let jy = 0.5 + 0.18 * (h2 * 2 - 1) + 0.25 * cos(t * (0.1 + 0.12 * h1) + h2 * 6.28)
                px[r * cols + c] = (Double(gx) + jx) * cell - drift.x
                py[r * cols + c] = (Double(gy) + jy) * cell - drift.y
            }
        }
    }

    /// The two smallest squared distances from a half-res pixel to the points of the 3×3 cells around it.
    func nearestTwo(_ fx: Double, _ fy: Double) -> (Double, Double) {
        let r0 = Int(((fy + drift.y) / cell).rounded(.down)) + 1 - baseY
        let c0 = Int(((fx + drift.x) / cell).rounded(.down)) + 1 - baseX
        var f1 = Double.greatestFiniteMagnitude, f2 = f1
        for r in max(0, r0 - 1)...min(rows - 1, max(0, r0 + 1)) {
            for c in max(0, c0 - 1)...min(cols - 1, max(0, c0 + 1)) {
                let dx = px[r * cols + c] - fx, dy = py[r * cols + c] - fy
                let d = dx * dx + dy * dy
                if d < f1 { f2 = f1; f1 = d } else if d < f2 { f2 = d }
            }
        }
        return (f1, f2)
    }

    /// The same, over every point — the reference the search must match.
    func nearestTwoExhaustive(_ fx: Double, _ fy: Double) -> (Double, Double) {
        var f1 = Double.greatestFiniteMagnitude, f2 = f1
        for i in px.indices {
            let dx = px[i] - fx, dy = py[i] - fy
            let d = dx * dx + dy * dy
            if d < f1 { f2 = f1; f1 = d } else if d < f2 { f2 = d }
        }
        return (f1, f2)
    }
}

struct Ripple {
    var center: Vec2
    var age = 0.0
    let life: Double
    let speed: Double
    let strength: Double
    let rings: Int

    mutating func update(_ dt: Double) { age += dt }
    var done: Bool { age >= life }

    func draw(into canvas: Canvas) {
        let fade = pow(max(0, 1 - age / life), 1.6)
        for k in 0..<rings {
            let r = 1.5 + speed * age - Double(k) * 3.2
            guard r > 0.5 else { continue }
            canvas.ring(center: center, radius: r, Float(strength * fade * (k == 0 ? 1 : 0.55)), .lighten)
        }
    }
}

struct Flower {
    /// Offset from the pad's centre, in the pad's own (rotating) frame.
    let offset: Vec2
    let radius: Double
    let twist: Double
    let petals: Int
}

struct Lilypad {
    var position: Vec2
    var velocity = Vec2.zero
    var angle: Double
    var spin: Double
    let radius: Double
    let notch: Double
    let edge: [Double]   // the rim's small irregularity, by angle
    let veins: Int
    let flower: Flower?
    let seed: UInt64

    init(position: Vec2, radius: Double, rng: inout SplitMix64) {
        self.position = position
        self.radius = radius
        angle = rng.range(0, 2 * .pi)
        spin = rng.range(-0.02, 0.02)
        notch = rng.range(0.16, 0.3)
        seed = rng.next()
        veins = rng.int(9, 13)
        var e = [Double](repeating: 0, count: 48)
        let off = rng.range(0, 50)
        for i in 0..<48 { e[i] = 1 + 0.05 * (Noise.smooth(Double(i) * 0.35 + off, seed: seed) * 2 - 1) }
        edge = e
        if rng.chance(0.45) {
            let fr = radius * rng.range(0.42, 0.55)
            flower = Flower(offset: Vec2.angle(rng.range(0, 2 * .pi)) * (radius * rng.range(0.15, 0.35)),
                            radius: max(3.2, fr), twist: rng.range(0, 1), petals: rng.int(7, 9))
        } else {
            flower = nil
        }
    }

    func rim(at a: Double) -> Double {
        let x = (a / (2 * .pi)).truncatingRemainder(dividingBy: 1) * 48
        let xx = x < 0 ? x + 48 : x
        let i = Int(xx) % 48, t = xx - xx.rounded(.down)
        return radius * (edge[i] + (edge[(i + 1) % 48] - edge[i]) * t)
    }

    func draw(into canvas: Canvas) {
        let r = radius * 1.06
        guard let ys = canvas.clipped(position.y - r, position.y + r, limit: canvas.height),
              let xs = canvas.clipped(position.x - r, position.x + r, limit: canvas.width) else { return }
        let lightDir = -2.3
        for y in ys {
            let dy = Double(y) + 0.5 - position.y
            for x in xs {
                let dx = Double(x) + 0.5 - position.x
                let d = (dx * dx + dy * dy).squareRoot()
                guard d <= r else { continue }
                let world = atan2(dy, dx)
                let local = angleDelta(from: angle, to: world)
                let re = rim(at: local)
                guard d <= re else { continue }
                if abs(local) < notch * (d > radius * 0.1 ? 1 : 0) { continue }
                var v = 0.27 + 0.08 * cos(world - lightDir) * (d / re)
                if re - d < 1.0 { v = 0.95 }
                else if abs(abs(local) - notch) < 0.9 / max(d, 1) { v = 0.62 } // the notch's cut edges
                else if d > radius * 0.14 {
                    let vein = (local + .pi) / (2 * .pi) * Double(veins)
                    if abs(vein - vein.rounded()) * (2 * .pi / Double(veins)) * d < 0.5 { v = 0.47 }
                }
                if d < radius * 0.09 { v = 0.5 }
                canvas.plot(x, y, Float(v))
            }
        }
        if let flower { drawFlower(flower, into: canvas) }
    }

    func drawFlower(_ f: Flower, into canvas: Canvas) {
        let c = position + f.offset.rotated(by: angle)
        let r = f.radius
        guard let ys = canvas.clipped(c.y - r, c.y + r, limit: canvas.height),
              let xs = canvas.clipped(c.x - r, c.x + r, limit: canvas.width) else { return }
        let n = Double(f.petals)
        for y in ys {
            let dy = Double(y) + 0.5 - c.y
            for x in xs {
                let dx = Double(x) + 0.5 - c.x
                let d = (dx * dx + dy * dy).squareRoot()
                guard d <= r else { continue }
                let a = atan2(dy, dx) - angle * 1.0 - f.twist * 2 * .pi
                if d < r * 0.22 { canvas.plot(x, y, 0.5); continue }
                // Outer petals, then an inner ring offset by half a petal.
                let outer = (a / (2 * .pi) * n), oFrac = abs(outer - outer.rounded())
                let oWidth = 0.42 * pow(sin(.pi * min(1, d / r)), 0.55)
                if oFrac < oWidth {
                    canvas.plot(x, y, oFrac > oWidth - 0.08 ? 0.55 : 1.0)
                    continue
                }
                if d < r * 0.66 {
                    let inner = (a / (2 * .pi) * n + 0.5), iFrac = abs(inner - inner.rounded())
                    if iFrac < 0.4 * pow(sin(.pi * min(1, d / (r * 0.66))), 0.5) {
                        canvas.plot(x, y, 0.86)
                        continue
                    }
                }
                canvas.plot(x, y, 0.1)
            }
        }
    }
}

/// A lilypad (and its flower) rendered into a small private canvas, blitted opaquely each frame.
struct PadSprite {
    struct Key: Equatable { let x: Int, y: Int, a: Int }
    let key: Key
    let originX: Int
    let originY: Int
    let canvas: Canvas

    static func key(for pad: Lilypad) -> Key {
        Key(x: Int((pad.position.x * 2).rounded()), y: Int((pad.position.y * 2).rounded()),
            a: Int((pad.angle * 40).rounded()))
    }

    init(pad: Lilypad, key: Key) {
        self.key = key
        let r = pad.radius * 1.06 + 2
        originX = Int((pad.position.x - r).rounded(.down))
        originY = Int((pad.position.y - r).rounded(.down))
        let side = Int((2 * r).rounded(.up)) + 2
        canvas = Canvas(size: PixelSize(width: side, height: side))
        canvas.clear(-1) // transparent
        var local = pad
        local.position = pad.position - Vec2(Double(originX), Double(originY))
        local.draw(into: canvas)
    }

    func blit(into target: Canvas) {
        let w = canvas.width
        for y in 0..<canvas.height {
            let ty = originY + y
            guard ty >= 0, ty < target.height else { continue }
            for x in 0..<w {
                let v = canvas.pixels[y * w + x]
                if v >= 0 { target.plot(originX + x, ty, v) }
            }
        }
    }
}

struct Leaf {
    enum Phase { case falling, floating, sinking }
    let id: Int
    var position: Vec2
    var velocity: Vec2
    var angle: Double
    var spin: Double
    var phase: Phase = .falling
    var altitude = 1.0
    var floatLeft: Double
    var sink = 0.0
    let length: Double
    let fallTime: Double
    let swayPhase: Double

    var done: Bool { phase == .sinking && sink >= 1 }

    func draw(into canvas: Canvas) {
        let scale = 1 + 0.75 * altitude
        let len = length * scale, wid = length * 0.42 * scale
        let fade = Float(phase == .sinking ? max(0, 1 - sink) : 1)
        let axis = Vec2.angle(angle), across = axis.perpendicular
        let step = 0.45
        var t = -1.0
        while t <= 1 {
            let half = 0.5 * wid * (1 - t * t)
            var a = -half
            while a <= half {
                let mid = abs(a) < 0.5
                let edge = half - abs(a) < 0.6
                let v: Float = mid ? 0.92 : (edge ? 0.8 : 0.5)
                canvas.plot(position + axis * (t * len * 0.5) + across * a, v * fade, .set)
                a += step
            }
            t += step / max(1, len * 0.5)
        }
        // The stem.
        let base = position - axis * (len * 0.5)
        canvas.line(from: base, to: base - axis * (len * 0.22) + across * (len * 0.06), 0.85 * fade)
    }
}
