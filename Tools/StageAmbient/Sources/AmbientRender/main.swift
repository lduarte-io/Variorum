import AmbientKit
import AppKit
import ImageIO
import QuartzCore
import UniformTypeIdentifiers

// AmbientRender — the offscreen dev aids: render GIFs and PNG stills, benchmark a scene, list the scenes,
// draw the koi gallery. It never opens a window, and its own name keeps it apart from the window app
// "StageAmbient" (the name the wrapper and the coordinator's pre-GO check look for).

struct Options {
    var config: URL?
    var scene: String?
    var stay = false
    var seed: UInt64 = 1
    var renderGIF: URL?
    var framesDir: URL?
    var gallery: URL?
    var bench = false
    var list = false
    var seconds = 20.0
    var skip = 0.0
    var every = 1
    var size: PixelSize?
    var scale = 2

    static func parse(_ args: [String]) -> Options {
        var o = Options()
        var i = 1
        func value() -> String {
            i += 1
            guard i < args.count else { fail("\(args[i - 1]) needs a value") }
            return args[i]
        }
        while i < args.count {
            switch args[i] {
            case "--config": o.config = URL(fileURLWithPath: value())
            case "--scene": o.scene = value()
            case "--stay": o.stay = true
            case "--seed": o.seed = UInt64(value()) ?? 1
            case "--render-gif": o.renderGIF = URL(fileURLWithPath: value())
            case "--frames": o.framesDir = URL(fileURLWithPath: value(), isDirectory: true)
            case "--gallery": o.gallery = URL(fileURLWithPath: value())
            case "--bench": o.bench = true
            case "--list": o.list = true
            case "--seconds": o.seconds = Double(value()) ?? o.seconds
            case "--skip": o.skip = Double(value()) ?? 0
            case "--every": o.every = max(1, Int(value()) ?? 1)
            case "--gif-scale", "--scale": o.scale = max(1, Int(value()) ?? 2)
            case "--size":
                let p = value().split(separator: "x").compactMap { Int($0) }
                guard p.count == 2 else { fail("--size wants WxH") }
                o.size = PixelSize(width: p[0], height: p[1])
            default: fail("unknown argument \(args[i])")
            }
            i += 1
        }
        return o
    }
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("AmbientRender: \(message)\n".utf8))
    exit(2)
}

func writePNG(_ img: CGImage, to url: URL) {
    guard let d = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(d, img, nil)
    CGImageDestinationFinalize(d)
}

/// The size the window app would use on this Mac's built-in screen.
@MainActor
func defaultSceneSize(_ config: AmbientConfig) -> PixelSize {
    let builtIn = NSScreen.screens.first { s in
        guard let n = s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
        return CGDisplayIsBuiltin(CGDirectDisplayID(n.uint32Value)) != 0
    }
    let screen = (builtIn ?? NSScreen.screens.first)?.frame.size ?? CGSize(width: 1728, height: 1117)
    return PixelSize(width: Int((screen.width / config.pixelScale).rounded(.up)),
                     height: Int((screen.height / config.pixelScale).rounded(.up)))
}

let o = Options.parse(CommandLine.arguments)
let (config, problem) = AmbientConfig.load(o.config)
if let problem { FileHandle.standardError.write(Data("AmbientRender: \(problem)\n".utf8)) }

if o.list {
    for type in SceneRegistry.all {
        let w = config.scenes.first { $0.name == type.name }?.weight ?? 0
        print("\(type.name)\tweight \(w)\t\(type.summary)")
    }
    exit(0)
}

let size = o.size ?? defaultSceneSize(config)

if let url = o.gallery {
    let canvas = Canvas(size: size)
    KoiPond.gallery(into: canvas)
    let frame = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size.count)
    canvas.dither(into: frame)
    if let img = FrameImage.gray(frame, size: size, scale: o.scale) { writePNG(img, to: url) }
    print("wrote \(url.path)")
    exit(0)
}

guard o.bench || o.renderGIF != nil || o.framesDir != nil else {
    fail("nothing to do: --render-gif PATH, --frames DIR, --bench, --gallery PATH or --list")
}

let director = Director(size: size, config: config, seed: o.seed, start: o.scene, stay: o.stay)
let dt = 1 / config.fps
var skipped = 0.0
while skipped < o.skip {
    let h = min(0.25, o.skip - skipped)
    director.step(dt: h)
    skipped += h
}
let frames = Int(o.seconds * config.fps)

if o.bench {
    let t0 = CACurrentMediaTime()
    for _ in 0..<frames { director.step(dt: dt) }
    let per = (CACurrentMediaTime() - t0) / Double(max(1, frames))
    print(String(format: "bench: scene=%@ size=%dx%d frames=%d  %.3f ms/frame  ≈ %.2f%% of one core at %.0f fps (a tight loop on a fast core; on screen the same work runs slower-clocked)",
                 director.currentName, size.width, size.height, frames, per * 1000, per * config.fps * 100, config.fps))
    exit(0)
}

var gif: CGImageDestination?
let kept = (frames + o.every - 1) / o.every
if let url = o.renderGIF {
    gif = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, kept, nil)
    if let gif {
        CGImageDestinationSetProperties(gif, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
    }
}
if let dir = o.framesDir { try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true) }
let delay = Double(o.every) / config.fps
for f in 0..<frames {
    director.step(dt: dt)
    guard f % o.every == 0, let img = FrameImage.gray(director.frame, size: size, scale: o.scale) else { continue }
    if let gif {
        CGImageDestinationAddImage(gif, img, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]] as CFDictionary)
    }
    if let dir = o.framesDir { writePNG(img, to: dir.appendingPathComponent(String(format: "frame-%05d.png", f))) }
}
if let gif, !CGImageDestinationFinalize(gif) { fail("could not write the GIF") }
print("rendered scene=\(director.currentName) size=\(size.width)x\(size.height) frames=\(kept) seed=\(o.seed)")
