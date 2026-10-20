import Foundation

// The scene system: a protocol every scene implements, the registry that names them, the JSON config
// that weights them, and the Director that runs one (or two, mid-dissolve) and hands the host 1-bit
// frames. Adding a scene = one type conforming to `AmbientScene`, one line in `SceneRegistry.all`, one
// entry in `ambient.json`.

public protocol AmbientScene: AnyObject {
    /// The name `Tools/ambient on --scene NAME` and `ambient.json` use.
    static var name: String { get }
    /// One line for `Tools/ambient list`.
    static var summary: String { get }
    /// Setup: build the scene for a canvas of this size. The same seed always builds the same scene.
    init(size: PixelSize, seed: UInt64)
    /// Advance the simulation by `dt` seconds (the Director keeps every step small).
    func update(dt: Double)
    /// Paint the current state; the Director dithers it to 1 bit.
    func draw(into canvas: Canvas)
}

public enum SceneRegistry {
    public static var all: [any AmbientScene.Type] { [KoiPond.self] }

    public static func type(named name: String) -> (any AmbientScene.Type)? {
        all.first { $0.name == name }
    }
}

public struct SceneWeight: Codable, Sendable, Equatable {
    public var name: String
    public var weight: Double
    public init(name: String, weight: Double) { self.name = name; self.weight = weight }
}

public struct AmbientConfig: Codable, Sendable, Equatable {
    /// Frame cap. The host never wakes faster than this.
    public var fps: Double = 12
    /// Screen points per scene pixel (nearest-neighbour). 3 on the Pro = a 576 × 373 scene.
    public var pixelScale: Double = 3
    /// Minutes before dissolving to the next weighted pick; 0 = never rotate.
    public var rotateMinutes: Double = 10
    public var dissolveSeconds: Double = 3
    public var scenes: [SceneWeight] = [SceneWeight(name: KoiPond.name, weight: 1)]

    public init() {}

    enum CodingKeys: String, CodingKey { case fps, pixelScale, rotateMinutes, dissolveSeconds, scenes }

    /// Missing keys keep their defaults, so a config only needs what it changes.
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = AmbientConfig()
        fps = clamp(try c.decodeIfPresent(Double.self, forKey: .fps) ?? d.fps, 1, 30)
        pixelScale = clamp(try c.decodeIfPresent(Double.self, forKey: .pixelScale) ?? d.pixelScale, 1, 16)
        rotateMinutes = max(0, try c.decodeIfPresent(Double.self, forKey: .rotateMinutes) ?? d.rotateMinutes)
        dissolveSeconds = clamp(try c.decodeIfPresent(Double.self, forKey: .dissolveSeconds) ?? d.dissolveSeconds, 0, 30)
        scenes = try c.decodeIfPresent([SceneWeight].self, forKey: .scenes) ?? d.scenes
    }

    public static func load(_ url: URL?) -> (AmbientConfig, String?) {
        guard let url else { return (AmbientConfig(), nil) }
        do {
            return (try JSONDecoder().decode(AmbientConfig.self, from: Data(contentsOf: url)), nil)
        } catch {
            return (AmbientConfig(), "config \(url.path) unreadable (\(error)); using defaults")
        }
    }

    /// The scenes that can actually run: registered, positive weight. Never empty (koi is the floor).
    public var playable: [SceneWeight] {
        let p = scenes.filter { $0.weight > 0 && SceneRegistry.type(named: $0.name) != nil }
        return p.isEmpty ? [SceneWeight(name: KoiPond.name, weight: 1)] : p
    }
}

public enum ScenePicker {
    /// A weighted-random pick. With more than one candidate the current scene is left out, so a
    /// rotation always changes the picture; with one, it is picked again (the Director re-seeds it).
    public static func pick(from scenes: [SceneWeight], excluding current: String?,
                            using rng: inout SplitMix64) -> String {
        var pool = scenes.filter { $0.weight > 0 }
        if pool.count > 1, let current { pool.removeAll { $0.name == current } }
        guard !pool.isEmpty else { return scenes.first?.name ?? KoiPond.name }
        let total = pool.reduce(0) { $0 + $1.weight }
        var r = rng.unit() * total
        for s in pool {
            r -= s.weight
            if r < 0 { return s.name }
        }
        return pool[pool.count - 1].name
    }
}

/// Runs the show: the current scene, the rotation clock, the dissolve. The host calls `step` once per
/// frame and shows `frame`.
public final class Director {
    public let size: PixelSize
    public let config: AmbientConfig
    public private(set) var currentName: String
    public private(set) var isDissolving = false
    /// The 1-bit frame (0 / 255 per pixel), valid after `step`.
    public let frame: UnsafeMutableBufferPointer<UInt8>
    /// When true, rotation never fires (`--stay`); `next()` still works.
    public var stay: Bool

    private var rng: SplitMix64
    private var current: any AmbientScene
    private let canvas: Canvas
    private var incoming: (name: String, scene: any AmbientScene)?
    private var dissolveProgress = 0.0
    private var sinceRotate = 0.0
    private let incomingCanvas: Canvas
    private let incomingFrame: UnsafeMutableBufferPointer<UInt8>
    /// Each pixel's moment in the dissolve, uniform in [0, 1): the classic random pixel dissolve.
    private let dissolveOrder: [Float]

    public init(size: PixelSize, config: AmbientConfig, seed: UInt64, start: String? = nil, stay: Bool = false) {
        self.size = size
        self.config = config
        self.stay = stay
        rng = SplitMix64(seed: seed)
        let name = start.flatMap { SceneRegistry.type(named: $0) != nil ? $0 : nil }
            ?? ScenePicker.pick(from: config.playable, excluding: nil, using: &rng)
        currentName = name
        current = Director.make(name, size: size, seed: rng.next())
        canvas = Canvas(size: size)
        incomingCanvas = Canvas(size: size)
        frame = .allocate(capacity: size.count)
        frame.initialize(repeating: 0)
        incomingFrame = .allocate(capacity: size.count)
        incomingFrame.initialize(repeating: 0)
        var orderRNG = SplitMix64(seed: seed ^ 0xD15_501E)
        dissolveOrder = (0..<size.count).map { _ in Float(orderRNG.unit()) }
    }

    deinit {
        frame.deallocate()
        incomingFrame.deallocate()
    }

    static func make(_ name: String, size: PixelSize, seed: UInt64) -> any AmbientScene {
        let type = SceneRegistry.type(named: name) ?? KoiPond.self
        return type.init(size: size, seed: seed)
    }

    /// Begin dissolving to the next weighted pick now (`Tools/ambient next`). With one playable scene
    /// this dissolves into a freshly seeded copy of it. Ignored mid-dissolve.
    public func next() {
        guard incoming == nil else { return }
        let name = ScenePicker.pick(from: config.playable, excluding: currentName, using: &rng)
        incoming = (name, Director.make(name, size: size, seed: rng.next()))
        dissolveProgress = 0
        isDissolving = true
    }

    /// Advance by `dt` seconds and render the frame. Long gaps (a wake from display sleep) are capped,
    /// and every simulation step stays at or under 1/15 s.
    public func step(dt rawDT: Double) {
        let dt = clamp(rawDT.isFinite ? rawDT : 0, 0, 0.5)
        sinceRotate += dt
        if !stay, config.rotateMinutes > 0, incoming == nil, sinceRotate >= config.rotateMinutes * 60 {
            next()
        }
        Director.advance(current, dt)
        canvas.clear()
        current.draw(into: canvas)
        canvas.dither(into: frame)

        guard let inc = incoming else { return }
        Director.advance(inc.scene, dt)
        incomingCanvas.clear()
        inc.scene.draw(into: incomingCanvas)
        incomingCanvas.dither(into: incomingFrame)
        dissolveProgress += config.dissolveSeconds > 0 ? dt / config.dissolveSeconds : 1
        let p = Float(min(1, dissolveProgress))
        for i in 0..<size.count where dissolveOrder[i] < p {
            frame[i] = incomingFrame[i]
        }
        if dissolveProgress >= 1 {
            current = inc.scene
            currentName = inc.name
            incoming = nil
            isDissolving = false
            sinceRotate = 0
        }
    }

    private static func advance(_ scene: any AmbientScene, _ dt: Double) {
        var left = dt
        while left > 1e-9 {
            let h = min(left, 1.0 / 15)
            scene.update(dt: h)
            left -= h
        }
    }
}
