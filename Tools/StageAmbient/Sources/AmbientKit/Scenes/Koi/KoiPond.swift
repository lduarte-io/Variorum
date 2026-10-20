import Foundation

// SCENE 1 — the koi pond, overhead. 5–9 koi wander on smooth noise, keep a little distance from each
// other at the same depth, turn softly away from the edges and (near the surface) from lilypads, and
// now and then pause, drift, rise to gulp at the surface (ripples), or dart. Lilypads ride a slow
// current and turn; leaves fall now and then, float, draw a curious koi, and sink. Nothing loops: every
// motion comes from noise and small state machines.

public final class KoiPond: AmbientScene {
    public static let name = "koi"
    public static let summary = "Koi in a pond, overhead: lilypads, ripples, the odd falling leaf"

    let size: PixelSize
    let bounds: Vec2
    /// Scene pixels per "design pixel" (designed at 280 rows), so a bigger canvas keeps the composition.
    let unit: Double
    var rng: SplitMix64
    var time = 0.0
    var koi: [Koi] = []
    var pads: [Lilypad] = []
    var ripples: [Ripple] = []
    var leaves: [Leaf] = []
    let water: Water
    let currentSeed: UInt64
    var nextLeaf: Double
    var nextInsect: Double
    var leafIDs = 0

    public init(size: PixelSize, seed: UInt64) {
        self.size = size
        bounds = Vec2(Double(size.width), Double(size.height))
        unit = Double(size.height) / 280
        rng = SplitMix64(seed: seed)
        water = Water(seed: rng.next())
        currentSeed = rng.next()
        nextLeaf = rng.range(35, 90)
        nextInsect = rng.range(15, 45)

        let padCount = rng.int(4, 7)
        for _ in 0..<padCount {
            let r = rng.range(9, 19) * unit
            var p = Vec2.zero
            for _ in 0..<20 { // a few tries to start them apart
                p = Vec2(rng.range(r + 4, bounds.x - r - 4), rng.range(r + 4, bounds.y - r - 4))
                if pads.allSatisfy({ $0.position.distance(to: p) > $0.radius + r + 6 }) { break }
            }
            pads.append(Lilypad(position: p, radius: r, rng: &rng))
        }

        let count = 5 + rng.int(0, 2) + rng.int(0, 2)
        for _ in 0..<count {
            let len = rng.range(40, 62) * unit
            let head = Vec2(rng.range(0.15, 0.85) * bounds.x, rng.range(0.15, 0.85) * bounds.y)
            koi.append(Koi(head: head, heading: rng.range(0, 2 * .pi), length: len, rng: &rng))
        }
    }

    // MARK: Update

    public func update(dt: Double) {
        time += dt
        for i in koi.indices { steer(koi[i], index: i, dt: dt) }
        for k in koi { k.follow() }
        updatePads(dt)
        updateLeaves(dt)
        water.update(dt, bounds: bounds, unit: unit)
        for i in ripples.indices { ripples[i].update(dt) }
        ripples.removeAll { $0.done }

        nextInsect -= dt
        if nextInsect <= 0 {
            nextInsect = rng.range(18, 55)
            let p = Vec2(rng.range(0.08, 0.92) * bounds.x, rng.range(0.08, 0.92) * bounds.y)
            if !pads.contains(where: { $0.position.distance(to: p) < $0.radius + 2 }) {
                ripples.append(Ripple(center: p, life: 2.2, speed: 6 * unit, strength: 0.4, rings: 1))
            }
        }
    }

    func chooseMode(_ k: Koi) {
        let r = rng.unit()
        let mode: Koi.Mode = r < 0.015 ? .dart : r < 0.10 ? .rise : r < 0.24 ? .pause : r < 0.44 ? .drift : .cruise
        k.mode = mode
        switch mode {
        case .cruise: k.modeLeft = rng.range(7, 20)
        case .drift: k.modeLeft = rng.range(4, 10)
        case .pause: k.modeLeft = rng.range(2.5, 7)
        case .rise: k.modeLeft = 14; k.gulped = false
        case .dart:
            k.modeLeft = rng.range(0.6, 1.1)
            k.dartTurn = (rng.chance(0.5) ? 1 : -1) * rng.range(2.5, 4.5)
            k.dartTurnLeft = 0.28
            if k.depth < 0.35 {
                ripples.append(Ripple(center: k.spine[Koi.joints - 2], life: 2.4, speed: 9 * unit,
                                      strength: 0.6, rings: 2))
            }
        }
    }

    func steer(_ k: Koi, index i: Int, dt: Double) {
        k.modeLeft -= dt
        if k.modeLeft <= 0 {
            if k.mode == .dart || k.mode == .rise { k.mode = .cruise; k.modeLeft = rng.range(6, 14) }
            else { chooseMode(k) }
        }
        if k.interestLeaf != nil {
            k.interestLeft -= dt
            if k.interestLeft <= 0 || !leaves.contains(where: { $0.id == k.interestLeaf && $0.phase == .floating }) {
                k.interestLeaf = nil
            }
        }

        // Speed and depth targets by mode.
        let L = k.length
        switch k.mode {
        case .cruise: k.targetSpeed = 0.38 * L * k.pace
        case .drift: k.targetSpeed = 0.13 * L * k.pace
        case .pause: k.targetSpeed = 0.012 * L
        case .rise: k.targetSpeed = 0.26 * L * k.pace
        case .dart: k.targetSpeed = 2.3 * L
        }
        if k.interestLeaf != nil { k.targetSpeed = max(k.targetSpeed, 0.3 * L) }
        let tau = k.mode == .dart ? 0.18 : (k.speed > k.targetSpeed * 1.5 ? 1.1 : 0.9)
        k.speed += (k.targetSpeed - k.speed) * approach(dt, tau)

        switch k.mode {
        case .rise:
            k.targetDepth = 0
            if !k.gulped, k.depth < 0.07 {
                k.gulped = true
                k.modeLeft = rng.range(1.0, 2.2)
                ripples.append(Ripple(center: k.head + k.forward * (0.04 * L), life: 3.2, speed: 8 * unit,
                                      strength: 0.85, rings: 2))
            }
        case .dart, .pause: break
        case .cruise, .drift:
            k.targetDepth = 0.05 + 0.62 * pow(Noise.smooth(time * 0.035 + k.noiseOffset, seed: k.seed &+ 9), 1.6)
        }
        if k.interestLeaf != nil { k.targetDepth = 0.04 }
        k.depth += (k.targetDepth - k.depth) * approach(dt, k.mode == .rise ? 1.6 : 3.0)

        // Steering: wander + separation + edges + (shallow) lilypads + a leaf, if curious.
        let head = k.head
        let fwd = k.forward
        var steer = fwd
        for (j, o) in koi.enumerated() where j != i && abs(o.depth - k.depth) < 0.35 {
            let reach = 0.3 * (k.length + o.length)
            for p in stride(from: 0, to: Koi.joints, by: 3) {
                let d = head - o.spine[p]
                let dist = d.length
                if dist < reach, dist > 1e-6 {
                    let w = (reach - dist) / reach
                    steer += d.normalized * (w * w * 1.8)
                }
            }
        }
        let look = head + fwd * (0.7 * L + k.speed * 0.8)
        let margin = 0.42 * L
        var edge = Vec2.zero
        if look.x < margin { edge.x += (margin - look.x) / margin }
        if look.x > bounds.x - margin { edge.x -= (look.x - (bounds.x - margin)) / margin }
        if look.y < margin { edge.y += (margin - look.y) / margin }
        if look.y > bounds.y - margin { edge.y -= (look.y - (bounds.y - margin)) / margin }
        steer += edge * 2.6
        if k.depth < 0.6 {
            let shallow = (0.6 - k.depth) / 0.6
            for p in pads {
                let d = look - p.position
                let reach = p.radius + 0.35 * L
                let dist = d.length
                if dist < reach, dist > 1e-6 { steer += d.normalized * ((reach - dist) / reach * 1.6 * shallow) }
            }
        }
        if let id = k.interestLeaf, let leaf = leaves.first(where: { $0.id == id }) {
            steer += (leaf.position - head).normalized * 1.1
            if leaf.position.distance(to: head) < 0.3 * L, k.depth < 0.2 {
                nibble(leafID: id)
                k.interestLeaf = nil
                k.mode = .cruise
                k.modeLeft = rng.range(5, 10)
            }
        }

        let moving = min(1, k.speed / (0.38 * L))
        let maxTurn = k.mode == .dart ? 3.2 : 0.5 + 1.15 * moving
        var turn = clamp(angleDelta(from: k.heading, to: steer.heading) * 1.8, -maxTurn, maxTurn)
        if k.mode == .pause { turn *= 0.3 }
        turn += Noise.wander(time * 0.16 + k.noiseOffset, seed: k.seed) * 0.55 * (k.mode == .pause ? 0.15 : 1)
        if k.dartTurnLeft > 0 {
            turn += k.dartTurn
            k.dartTurnLeft -= dt
        }
        k.heading += turn * dt
        k.heading = k.heading.truncatingRemainder(dividingBy: 2 * .pi)

        var h = head + k.forward * (k.speed * dt)
        // A hard fence well outside the soft one, in case anything ever pushes a koi too far.
        h.x = clamp(h.x, -0.25 * L, bounds.x + 0.25 * L)
        h.y = clamp(h.y, -0.25 * L, bounds.y + 0.25 * L)
        k.spine[0] = h
        k.phase += dt * 2 * .pi * (0.5 + 2.2 * k.speed / L)
        k.finPhase += dt * 2 * .pi * (k.mode == .pause ? 0.9 : 0.55)

        // A shallow koi brushing under a pad nudges it.
        if k.depth < 0.3 {
            for p in pads.indices where pads[p].position.distance(to: head) < pads[p].radius {
                pads[p].velocity += fwd * (k.speed * 0.02 * dt)
            }
        }
    }

    func updatePads(_ dt: Double) {
        for i in pads.indices {
            var p = pads[i]
            let cur = Vec2(Noise.wander(time * 0.02 + Double(i) * 13, seed: currentSeed),
                           Noise.wander(time * 0.02 + Double(i) * 13 + 500, seed: currentSeed)) * (1.3 * unit)
                + Vec2.angle(time * 2 * .pi / 540 + Double(i) * 1.7) * (0.55 * unit) // a slow circulation, so no pad lingers
            p.velocity += (cur - p.velocity) * approach(dt, 7)
            let m = p.radius + 3
            if p.position.x < m { p.velocity.x += (m - p.position.x) * 0.08 * dt }
            if p.position.x > bounds.x - m { p.velocity.x -= (p.position.x - (bounds.x - m)) * 0.08 * dt }
            if p.position.y < m { p.velocity.y += (m - p.position.y) * 0.08 * dt }
            if p.position.y > bounds.y - m { p.velocity.y -= (p.position.y - (bounds.y - m)) * 0.08 * dt }
            for j in pads.indices where j != i {
                let d = p.position - pads[j].position
                let overlap = p.radius + pads[j].radius + 2 - d.length
                if overlap > 0 { p.velocity += d.normalized * (overlap * 0.12 * dt) }
            }
            p.spin += (Noise.wander(time * 0.01 + Double(i) * 7, seed: p.seed) * 0.025 - p.spin) * approach(dt, 20)
            p.angle += p.spin * dt
            p.position += p.velocity * dt
            pads[i] = p
        }
    }

    func updateLeaves(_ dt: Double) {
        nextLeaf -= dt
        if nextLeaf <= 0 {
            nextLeaf = rng.range(60, 150)
            if leaves.filter({ $0.phase != .sinking }).count < 3 {
                leafIDs += 1
                let p = Vec2(rng.range(0.15, 0.85) * bounds.x, rng.range(0.15, 0.85) * bounds.y)
                leaves.append(Leaf(id: leafIDs, position: p, velocity: Vec2.angle(rng.range(0, 2 * .pi)) * (4 * unit),
                                   angle: rng.range(0, 2 * .pi), spin: rng.range(-0.9, 0.9),
                                   floatLeft: rng.range(50, 100), length: rng.range(6, 9) * unit,
                                   fallTime: rng.range(3.5, 5.5), swayPhase: rng.range(0, 2 * .pi)))
            }
        }
        for i in leaves.indices {
            var l = leaves[i]
            switch l.phase {
            case .falling:
                l.altitude -= dt / l.fallTime
                let sway = Vec2.angle(l.angle).perpendicular * (sin(time * 2.3 + l.swayPhase) * 7 * unit)
                l.position += (l.velocity + sway) * dt
                l.angle += l.spin * dt * 1.6
                if l.altitude <= 0 {
                    l.altitude = 0
                    l.phase = .floating
                    l.velocity = l.velocity * 0.25
                    l.spin *= 0.2
                    ripples.append(Ripple(center: l.position, life: 3, speed: 7 * unit, strength: 0.75, rings: 2))
                    attractKoi(to: l)
                }
            case .floating, .sinking:
                let cur = Vec2(Noise.wander(time * 0.02 + Double(l.id) * 3, seed: currentSeed &+ 5),
                               Noise.wander(time * 0.02 + Double(l.id) * 3 + 99, seed: currentSeed &+ 5)) * (1.0 * unit)
                l.velocity += (cur - l.velocity) * approach(dt, 5)
                l.position += l.velocity * dt
                l.angle += l.spin * dt
                if l.phase == .floating {
                    l.floatLeft -= dt
                    if l.floatLeft <= 0 { l.phase = .sinking }
                } else {
                    l.sink += dt / 14
                }
            }
            leaves[i] = l
        }
        leaves.removeAll { $0.done || !$0.position.isFinite }
    }

    func attractKoi(to leaf: Leaf) {
        let reach = 0.5 * bounds.x
        guard let k = koi.filter({ $0.mode != .dart && $0.interestLeaf == nil })
            .min(by: { $0.head.distance(to: leaf.position) < $1.head.distance(to: leaf.position) }),
            k.head.distance(to: leaf.position) < reach else { return }
        k.interestLeaf = leaf.id
        k.interestLeft = rng.range(10, 16)
        if k.mode == .pause { k.mode = .cruise; k.modeLeft = 12 }
    }

    func nibble(leafID: Int) {
        guard let i = leaves.firstIndex(where: { $0.id == leafID }) else { return }
        leaves[i].velocity += Vec2.angle(rng.range(0, 2 * .pi)) * (5 * unit)
        leaves[i].spin += rng.range(-0.6, 0.6)
        ripples.append(Ripple(center: leaves[i].position, life: 2.4, speed: 7 * unit, strength: 0.7, rings: 2))
    }

    // MARK: Gallery (tuning aid: every variety, still, at the surface, on black)

    public static func gallery(into canvas: Canvas) {
        var rng = SplitMix64(seed: 3)
        let unit = Double(canvas.height) / 280
        let cols = 3
        for (n, variety) in KoiVariety.allCases.enumerated() {
            let cx = (Double(n % cols) + 0.5) / Double(cols) * Double(canvas.width)
            let cy = (Double(n / cols) + 0.5) / 3 * Double(canvas.height)
            let k = Koi(head: Vec2(cx - 25 * unit, cy), heading: .pi, length: 54 * unit, rng: &rng, variety: variety)
            k.depth = 0
            k.heading = .pi * 0.92
            for _ in 0..<20 { k.spine[0] += Vec2.angle(k.heading) * 1; k.heading += 0.02; k.follow() }
            k.draw(into: canvas)
        }
    }

    // MARK: Draw

    public func draw(into canvas: Canvas) {
        water.draw(into: canvas, time: time, unit: unit)
        for k in koi.sorted(by: { $0.depth > $1.depth }) { k.draw(into: canvas) }
        for r in ripples { r.draw(into: canvas) }
        for p in pads { p.draw(into: canvas) }
        for l in leaves where l.phase != .falling { l.draw(into: canvas) }
        for l in leaves where l.phase == .falling { l.draw(into: canvas) }
    }
}
