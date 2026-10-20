import Foundation
import Testing
@testable import AmbientKit

@Suite struct CanvasTests {
    @Test func ditherIsExactAtTheEnds() {
        let c = Canvas(size: PixelSize(width: 16, height: 16))
        let f = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 256)
        defer { f.deallocate() }
        c.clear(0)
        c.dither(into: f)
        #expect(f.allSatisfy { $0 == 0 })
        c.clear(1)
        c.dither(into: f)
        #expect(f.allSatisfy { $0 == 255 })
        c.clear(0.5)
        c.dither(into: f)
        #expect(f.filter { $0 == 255 }.count == 128)
    }

    @Test func plottingOffTheCanvasOrAtNonsenseIsHarmless() {
        let c = Canvas(size: PixelSize(width: 4, height: 4))
        c.plot(-1, 0, 1)
        c.plot(0, 99, 1)
        c.plot(Vec2(.nan, .infinity), 1)
        c.fillDisc(center: Vec2(1000, 1000), radius: 3, 1)
        c.fillDisc(center: Vec2(-50, 2), radius: 2, 1)
        #expect(c.pixels.allSatisfy { $0 == 0 })
    }

    @Test func lightenNeverAccumulates() {
        let c = Canvas(size: PixelSize(width: 2, height: 2))
        for _ in 0..<10 { c.plot(0, 0, 0.3, .lighten) }
        #expect(c.value(0, 0) == 0.3)
    }
}

@Suite struct ConfigTests {
    static let committed = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("ambient.json")

    @Test func theCommittedConfigLoadsAndNamesOnlyRealScenes() {
        let (config, problem) = AmbientConfig.load(Self.committed)
        #expect(problem == nil)
        #expect(!config.scenes.isEmpty)
        for s in config.scenes { #expect(SceneRegistry.type(named: s.name) != nil, "unregistered scene \(s.name)") }
        #expect(config.fps <= 15)
    }

    @Test func missingKeysKeepDefaultsAndUnknownScenesFallBackToKoi() throws {
        let c = try JSONDecoder().decode(AmbientConfig.self, from: Data(#"{"scenes":[{"name":"nope","weight":3}]}"#.utf8))
        #expect(c.fps == AmbientConfig().fps)
        #expect(c.playable == [SceneWeight(name: "koi", weight: 1)])
    }

    @Test func absurdValuesAreClamped() throws {
        let c = try JSONDecoder().decode(AmbientConfig.self, from: Data(#"{"fps":500,"pixelScale":0}"#.utf8))
        #expect(c.fps == 30)
        #expect(c.pixelScale == 1)
    }
}

@Suite struct PickerTests {
    @Test func oneSceneIsAlwaysPicked() {
        var rng = SplitMix64(seed: 1)
        let one = [SceneWeight(name: "koi", weight: 1)]
        #expect(ScenePicker.pick(from: one, excluding: "koi", using: &rng) == "koi")
    }

    @Test func rotationNeverRepeatsWhenThereIsAChoice() {
        var rng = SplitMix64(seed: 2)
        let two = [SceneWeight(name: "a", weight: 1), SceneWeight(name: "b", weight: 5)]
        for _ in 0..<200 { #expect(ScenePicker.pick(from: two, excluding: "b", using: &rng) == "a") }
    }

    @Test func weightsShapeThePicks() {
        var rng = SplitMix64(seed: 3)
        let s = [SceneWeight(name: "a", weight: 1), SceneWeight(name: "b", weight: 3), SceneWeight(name: "z", weight: 0)]
        var counts: [String: Int] = [:]
        for _ in 0..<8000 { counts[ScenePicker.pick(from: s, excluding: nil, using: &rng), default: 0] += 1 }
        #expect(counts["z"] == nil)
        let share = Double(counts["b", default: 0]) / 8000
        #expect(abs(share - 0.75) < 0.03)
    }
}

@Suite struct DirectorTests {
    let size = PixelSize(width: 144, height: 94)

    @Test func theSameSeedRendersTheSameFrames() {
        let a = Director(size: size, config: AmbientConfig(), seed: 42)
        let b = Director(size: size, config: AmbientConfig(), seed: 42)
        for _ in 0..<30 { a.step(dt: 1.0 / 12); b.step(dt: 1.0 / 12) }
        #expect(Array(a.frame) == Array(b.frame))
    }

    @Test func framesAreOneBit() {
        let d = Director(size: size, config: AmbientConfig(), seed: 7)
        for _ in 0..<12 { d.step(dt: 1.0 / 12) }
        #expect(d.frame.allSatisfy { $0 == 0 || $0 == 255 })
        #expect(d.frame.contains(255))
    }

    @Test func nextDissolvesAndSettles() {
        var cfg = AmbientConfig()
        cfg.dissolveSeconds = 1
        let d = Director(size: size, config: cfg, seed: 9)
        d.step(dt: 0.1)
        d.next()
        #expect(d.isDissolving)
        for _ in 0..<15 { d.step(dt: 0.1) }
        #expect(!d.isDissolving)
        #expect(d.currentName == KoiPond.name)
    }

    @Test func rotationFiresOnTheClockButNotWhenStaying() {
        var cfg = AmbientConfig()
        cfg.rotateMinutes = 0.05 // 3 s
        cfg.dissolveSeconds = 0.5
        let rotating = Director(size: size, config: cfg, seed: 1)
        let staying = Director(size: size, config: cfg, seed: 1, stay: true)
        var sawRotation = false
        for _ in 0..<40 {
            rotating.step(dt: 0.1)
            staying.step(dt: 0.1)
            sawRotation = sawRotation || rotating.isDissolving
            #expect(!staying.isDissolving)
        }
        #expect(sawRotation)
    }

    @Test func aHugeGapIsCapped() {
        let d = Director(size: size, config: AmbientConfig(), seed: 5)
        d.step(dt: 3600) // a wake after an hour of display sleep must not explode the simulation
        d.step(dt: .nan)
        #expect(d.frame.contains(255))
    }
}

@Suite struct KoiPondTests {
    let size = PixelSize(width: 576, height: 373)

    @Test func koiAndPadsStayInTheirPondForAnHour() {
        let pond = KoiPond(size: size, seed: 11)
        #expect((5...9).contains(pond.koi.count))
        #expect((4...7).contains(pond.pads.count))
        let w = Double(size.width), h = Double(size.height)
        for _ in 0..<(12 * 3600) {
            pond.update(dt: 1.0 / 12)
        }
        for k in pond.koi {
            #expect(k.head.isFinite)
            let slack = 0.25 * k.length + 1e-6
            #expect(k.head.x >= -slack && k.head.x <= w + slack && k.head.y >= -slack && k.head.y <= h + slack)
            for i in 1..<Koi.joints {
                #expect(abs(k.spine[i].distance(to: k.spine[i - 1]) - k.segLen) < 1e-6)
            }
            #expect(k.depth >= -0.01 && k.depth <= 1.01)
        }
        for p in pond.pads {
            #expect(p.position.x > -p.radius && p.position.x < w + p.radius)
            #expect(p.position.y > -p.radius && p.position.y < h + p.radius)
        }
    }

    @Test func koiSpendMostOfTheirTimeInView() {
        let pond = KoiPond(size: size, seed: 23)
        var inView = 0, total = 0
        for step in 0..<(12 * 600) {
            pond.update(dt: 1.0 / 12)
            guard step % 12 == 0 else { continue }
            for k in pond.koi {
                total += 1
                if k.middle.x > 0, k.middle.x < Double(size.width), k.middle.y > 0, k.middle.y < Double(size.height) { inView += 1 }
            }
        }
        #expect(Double(inView) / Double(total) > 0.97)
    }

    @Test func somethingSurfacesFallsAndRipplesInTenMinutes() {
        let pond = KoiPond(size: size, seed: 5)
        var maxRipples = 0, sawLeaf = false, sawSurface = false
        for _ in 0..<(12 * 600) {
            pond.update(dt: 1.0 / 12)
            maxRipples = max(maxRipples, pond.ripples.count)
            sawLeaf = sawLeaf || !pond.leaves.isEmpty
            sawSurface = sawSurface || pond.koi.contains { $0.depth < 0.07 }
        }
        #expect(maxRipples > 0)
        #expect(sawLeaf)
        #expect(sawSurface)
    }

    /// Rail 8 on the scene itself (before the host's orbit): sampled every 5 s for 20 minutes, no pixel is
    /// lit in nearly every sample.
    @Test func nothingBrightStaysStill() {
        let size = PixelSize(width: 288, height: 187)
        let pond = KoiPond(size: size, seed: 3)
        let canvas = Canvas(size: size)
        let frame = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size.count)
        defer { frame.deallocate() }
        var lit = [Int](repeating: 0, count: size.count)
        let samples = 240
        for _ in 0..<samples {
            for _ in 0..<60 { pond.update(dt: 1.0 / 12) }
            canvas.clear()
            pond.draw(into: canvas)
            canvas.dither(into: frame)
            for i in 0..<lit.count where frame[i] == 255 { lit[i] += 1 }
        }
        let worst = Double(lit.max() ?? 0) / Double(samples)
        print("nothingBrightStaysStill: worst pixel lit in \(Int(worst * 100))% of samples")
        #expect(worst < 0.5, "a pixel was lit in \(Int(worst * 100))% of samples")
    }
}

@Suite struct WaterTests {
    /// The caustic web is the edges of a cell pattern, found by searching the 3×3 cells around each pixel.
    /// That search must find the true two nearest points however far the lattice has drifted (a search
    /// that looked at the wrong cells lit whole blocks after a minute or two).
    @Test(arguments: [0.0, 40, 120, 600, 3600])
    func theCellSearchFindsTheTrueNearestPoints(at t: Double) {
        let unit = 373.0 / 280
        let hw = 289, hh = 188
        let points = CellPoints(width: hw, height: hh, time: t, unit: unit, seed: 7)
        var misses = 0, total = 0
        for y in stride(from: 0, to: hh, by: 3) {
            for x in stride(from: 0, to: hw, by: 3) {
                let a = points.nearestTwo(Double(x), Double(y))
                let b = points.nearestTwoExhaustive(Double(x), Double(y))
                total += 1
                if abs(a.0 - b.0) > 1e-9 || abs(a.1 - b.1) > 1e-9 { misses += 1 }
            }
        }
        #expect(misses == 0, "\(misses) of \(total) pixels found the wrong nearest points at \(t) s")
    }
}
