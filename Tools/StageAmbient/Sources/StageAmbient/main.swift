import AmbientKit
import AppKit
import ImageIO
import QuartzCore
import UniformTypeIdentifiers

// StageAmbient — the host. Window mode (what `Tools/ambient on` launches through LaunchServices) puts
// one borderless black window over the built-in display at screen-saver level and shows the Director's
// 1-bit frames, scaled up nearest-neighbour, at the configured frame cap. Offscreen modes
// (--render-gif / --frames / --bench) run the same Director with no window at all.
//
// The rails (README.md), each enforced here:
//  1. The process is "StageAmbient" — never "Variorum".
//  2. A stage claim whose reason doesn't start with "HOLD:" ends it within ~0.3 s (polled 4×/s).
//  3. No screensaver machinery: an ordinary app window.
//  4. Nothing is posted and no power or user-activity assertion is taken: input is detected by READING
//     the HID system's idle time, the same number the coordinator reads.
//  5. Real input ends it (polled 10×/s).
//  6. One small layer update per frame at ~12 fps; the scene is a few hundred pixels across.
//  7. The cursor hides while up and is shown again on every exit path we control; the window server
//     restores it if the process dies outright. Activation goes back to the app that was frontmost.
//  8. Everything in the scene moves, and the whole picture orbits by a device pixel or two.

// MARK: Arguments

struct Options {
    var config: URL?
    var scene: String?
    var stay = false
    var seed: UInt64?
    var allowClaimant: String?
    var stageDir = StageClaim.defaultLockDirectory
    var returnPID: pid_t?
    var log = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".variorum/ambient.log")
    var state = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".variorum/ambient.state")
    // Offscreen.
    var renderGIF: URL?
    var framesDir: URL?
    var bench = false
    var list = false
    var seconds = 20.0
    var skip = 0.0
    var every = 1
    var size: PixelSize?
    var gifScale = 2
    var gallery: URL?

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
            case "--seed": o.seed = UInt64(value())
            case "--allow-claimant": o.allowClaimant = value()
            case "--stage-dir": o.stageDir = URL(fileURLWithPath: value(), isDirectory: true)
            case "--return-pid": o.returnPID = pid_t(value())
            case "--log": o.log = URL(fileURLWithPath: value())
            case "--state": o.state = URL(fileURLWithPath: value())
            case "--render-gif": o.renderGIF = URL(fileURLWithPath: value())
            case "--frames": o.framesDir = URL(fileURLWithPath: value(), isDirectory: true)
            case "--bench": o.bench = true
            case "--list": o.list = true
            case "--gallery": o.gallery = URL(fileURLWithPath: value())
            case "--seconds": o.seconds = Double(value()) ?? o.seconds
            case "--skip": o.skip = Double(value()) ?? 0
            case "--every": o.every = max(1, Int(value()) ?? 1)
            case "--gif-scale": o.gifScale = max(1, Int(value()) ?? 2)
            case "--size":
                let p = value().split(separator: "x").compactMap { Int($0) }
                guard p.count == 2 else { fail("--size wants WxH") }
                o.size = PixelSize(width: p[0], height: p[1])
            default:
                // LaunchServices may add its own arguments (e.g. -psn_…); ignore anything unknown.
                break
            }
            i += 1
        }
        return o
    }
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("StageAmbient: \(message)\n".utf8))
    exit(2)
}

// MARK: Log and state (the coordinator reads both; stage.log is Tools/stage's alone)

final class Journal: @unchecked Sendable {
    let log: URL
    let state: URL
    private let stamp: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return f
    }()

    init(log: URL, state: URL) {
        self.log = log
        self.state = state
        try? FileManager.default.createDirectory(at: log.deletingLastPathComponent(), withIntermediateDirectories: true)
    }

    func line(_ text: String) {
        let entry = "\(stamp.string(from: Date()))  \(text)\n"
        if let h = try? FileHandle(forWritingTo: log) {
            h.seekToEndOfFile()
            h.write(Data(entry.utf8))
            try? h.close()
        } else {
            try? Data(entry.utf8).write(to: log)
        }
    }

    func writeState(pid: pid_t, scene: String, since: Date, window: Int) {
        let f = ISO8601DateFormatter()
        f.timeZone = .current
        let iso = f.string(from: since)
        let text = "PID=\(pid)\nSCENE=\(scene)\nSINCE=\(iso)\nWINDOW=\(window)\n"
        try? Data(text.utf8).write(to: state, options: .atomic)
    }

    func clearState() { try? FileManager.default.removeItem(at: state) }
}

// MARK: Frames → images

func grayImage(_ frame: UnsafeMutableBufferPointer<UInt8>, size: PixelSize, scale: Int = 1) -> CGImage? {
    let w = size.width * scale, h = size.height * scale
    var data = Data(count: w * h)
    data.withUnsafeMutableBytes { (dst: UnsafeMutableRawBufferPointer) in
        let d = dst.bindMemory(to: UInt8.self)
        if scale == 1 {
            for i in 0..<size.count { d[i] = frame[i] }
        } else {
            for y in 0..<h {
                let sy = y / scale
                for x in 0..<w { d[y * w + x] = frame[sy * size.width + x / scale] }
            }
        }
    }
    guard let provider = CGDataProvider(data: data as CFData) else { return nil }
    return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: w,
                   space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                   provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
}

@MainActor
func builtInScreen() -> NSScreen? {
    let builtIn = NSScreen.screens.first { s in
        guard let n = s.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
        return CGDisplayIsBuiltin(CGDirectDisplayID(n.uint32Value)) != 0
    }
    return builtIn ?? NSScreen.screens.first
}

@MainActor
func defaultSceneSize(_ config: AmbientConfig) -> PixelSize {
    let screen = builtInScreen()?.frame.size ?? CGSize(width: 1728, height: 1117)
    return PixelSize(width: Int((screen.width / config.pixelScale).rounded(.up)),
                     height: Int((screen.height / config.pixelScale).rounded(.up)))
}

// MARK: Offscreen modes

@MainActor
func runOffscreen(_ o: Options, config: AmbientConfig) -> Never {
    let size = o.size ?? defaultSceneSize(config)
    let seed = o.seed ?? 1
    let director = Director(size: size, config: config, seed: seed, start: o.scene, stay: o.stay)
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
        print(String(format: "bench: scene=%@ size=%dx%d frames=%d  %.3f ms/frame  ≈ %.2f%% of one core at %.0f fps",
                     director.currentName, size.width, size.height, frames, per * 1000, per * config.fps * 100, config.fps))
        exit(0)
    }

    var gif: CGImageDestination?
    if let url = o.renderGIF {
        gif = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, (frames + o.every - 1) / o.every, nil)
        if let gif {
            CGImageDestinationSetProperties(gif, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
        }
    }
    if let dir = o.framesDir { try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true) }
    let delay = Double(o.every) / config.fps
    for f in 0..<frames {
        director.step(dt: dt)
        guard f % o.every == 0, let img = grayImage(director.frame, size: size, scale: o.gifScale) else { continue }
        if let gif {
            CGImageDestinationAddImage(gif, img, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]] as CFDictionary)
        }
        if let dir = o.framesDir {
            let url = dir.appendingPathComponent(String(format: "frame-%05d.png", f))
            if let d = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
                CGImageDestinationAddImage(d, img, nil)
                CGImageDestinationFinalize(d)
            }
        }
    }
    if let gif, !CGImageDestinationFinalize(gif) { fail("could not write the GIF") }
    print("rendered scene=\(director.currentName) size=\(size.width)x\(size.height) frames=\((frames + o.every - 1) / o.every) seed=\(seed)")
    exit(0)
}

// MARK: Window mode

final class AmbientWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Swallows whatever input reaches the window (so the waking keystroke never lands in a hidden app);
/// the HID watcher will have decided to quit already.
final class AmbientView: NSView {
    var onInput: (String) -> Void = { _ in }
    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func keyDown(with event: NSEvent) { onInput("key") }
    override func flagsChanged(with event: NSEvent) { onInput("key") }
    override func mouseDown(with event: NSEvent) { onInput("mouse") }
    override func rightMouseDown(with event: NSEvent) { onInput("mouse") }
    override func otherMouseDown(with event: NSEvent) { onInput("mouse") }
    override func scrollWheel(with event: NSEvent) { onInput("scroll") }
}

@MainActor
final class Host: NSObject, NSApplicationDelegate {
    let options: Options
    let config: AmbientConfig
    let journal: Journal
    var window: AmbientWindow?
    let imageLayer = CALayer()
    var director: Director?
    var sceneSize = PixelSize(width: 1, height: 1)
    var timers: [Timer] = []
    var signals: [DispatchSourceSignal] = []
    let launched = CACurrentMediaTime()
    var lastFrame = CACurrentMediaTime()
    var startedAt = Date()
    var previousApp: NSRunningApplication?
    var cursorHidden = false
    var becameActive = false
    var pendingSince: Double?
    var paused: Set<String> = []
    var shownScene = ""
    var finished = false
    var layerOrigin = CGPoint.zero

    init(options: Options, config: AmbientConfig, journal: Journal) {
        self.options = options
        self.config = config
        self.journal = journal
    }

    func applicationDidFinishLaunching(_ note: Notification) {
        let verdict = StageClaim.read(lockDirectory: options.stageDir, allowedClaimant: options.allowClaimant)
        guard verdict.permitsAmbient else { return refuse("stage \(describe(verdict))", code: 3) }
        if let session = CGSessionCopyCurrentDictionary() as? [String: Any],
           (session["CGSSessionScreenIsLocked"] as? Bool) == true {
            return refuse("screen locked", code: 4)
        }
        let me = NSRunningApplication.current
        if let id = me.bundleIdentifier,
           NSRunningApplication.runningApplications(withBundleIdentifier: id).contains(where: { $0.processIdentifier != me.processIdentifier }) {
            return refuse("already running", code: 5)
        }
        guard let screen = builtInScreen() else { return refuse("no screen", code: 6) }

        if let pid = options.returnPID, pid != me.processIdentifier, let app = NSRunningApplication(processIdentifier: pid) {
            previousApp = app
        } else if let front = NSWorkspace.shared.frontmostApplication, front.processIdentifier != me.processIdentifier {
            previousApp = front
        }

        let frame = screen.frame
        sceneSize = PixelSize(width: Int((frame.width / config.pixelScale).rounded(.up)),
                              height: Int((frame.height / config.pixelScale).rounded(.up)))
        let director = Director(size: sceneSize, config: config,
                                seed: options.seed ?? UInt64.random(in: 1...UInt64.max),
                                start: options.scene, stay: options.stay)
        self.director = director

        let w = AmbientWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false, screen: screen)
        w.level = .screenSaver
        w.backgroundColor = .black
        w.isOpaque = true
        w.hasShadow = false
        w.isReleasedWhenClosed = false
        w.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        w.animationBehavior = .none
        let view = AmbientView(frame: NSRect(origin: .zero, size: frame.size))
        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor(gray: 0, alpha: 1)
        view.onInput = { [weak self] kind in self?.finish("input (\(kind) event)") }
        imageLayer.magnificationFilter = .nearest
        imageLayer.minificationFilter = .nearest
        imageLayer.contentsGravity = .resize
        imageLayer.actions = ["contents": NSNull(), "position": NSNull(), "bounds": NSNull()]
        let lw = CGFloat(sceneSize.width) * config.pixelScale, lh = CGFloat(sceneSize.height) * config.pixelScale
        layerOrigin = CGPoint(x: ((frame.width - lw) / 2).rounded(.down), y: ((frame.height - lh) / 2).rounded(.down))
        imageLayer.frame = CGRect(origin: layerOrigin, size: CGSize(width: lw, height: lh))
        view.layer?.addSublayer(imageLayer)
        w.contentView = view
        window = w

        renderFrame(dt: 0)
        w.makeKeyAndOrderFront(nil)
        w.makeFirstResponder(view)
        NSApp.activate()

        installWatchers()
        _ = repeating(1 / config.fps) { $0.tick() }
        startedAt = Date()
        journal.line("ON      pid=\(me.processIdentifier) scene=\(director.currentName) size=\(sceneSize.width)x\(sceneSize.height) fps=\(Int(config.fps)) stage=\(describe(verdict)) return-to=\(previousApp?.localizedName ?? "none")")
        writeState()
    }

    func applicationDidBecomeActive(_ note: Notification) {
        becameActive = true
        if !cursorHidden {
            NSCursor.hide()
            cursorHidden = true
        }
    }

    func applicationDidResignActive(_ note: Notification) {
        guard becameActive else { return }
        let front = NSWorkspace.shared.frontmostApplication?.localizedName ?? "another app"
        finish("lost focus to \(front)", restoreFocus: false)
    }

    // MARK: Watchers

    @discardableResult
    func repeating(_ interval: Double, _ body: @escaping @MainActor (Host) -> Void) -> Timer {
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { if let self { body(self) } }
        }
        t.tolerance = interval * 0.1
        RunLoop.main.add(t, forMode: .common)
        timers.append(t)
        return t
    }

    func installWatchers() {
        // Rail 5: real input. Reading the idle time posts nothing and asserts nothing.
        repeating(0.1) { host in
            let idle = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
            if InputRule.inputArrived(uptime: CACurrentMediaTime() - host.launched, idle: idle) {
                host.finish(String(format: "input (HID idle %.2f s)", idle))
            }
        }
        // Rail 2: the stage. A lock directory with no claim file is a claim being written; give it
        // half a second, then treat it as someone else's.
        repeating(0.25) { host in
            let v = StageClaim.read(lockDirectory: host.options.stageDir, allowedClaimant: host.options.allowClaimant)
            switch v {
            case .foreign: host.finish("stage \(host.describe(v))")
            case .pending:
                let now = CACurrentMediaTime()
                if let since = host.pendingSince {
                    if now - since >= 0.5 { host.finish("stage \(host.describe(v))") }
                } else {
                    host.pendingSince = now
                }
            case .free, .hold, .allowed: host.pendingSince = nil
            }
        }
        // Signals: off (TERM/INT/HUP) and next (USR1).
        for sig in [SIGTERM, SIGINT, SIGHUP, SIGUSR1] {
            signal(sig, SIG_IGN)
            let src = DispatchSource.makeSignalSource(signal: sig, queue: .main)
            src.setEventHandler { [weak self] in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    if sig == SIGUSR1 {
                        self.journal.line("NEXT    dissolving from scene=\(self.director?.currentName ?? "?")")
                        self.director?.next()
                    } else {
                        self.finish("signal \(sig == SIGTERM ? "TERM" : sig == SIGINT ? "INT" : "HUP")")
                    }
                }
            }
            src.resume()
            signals.append(src)
        }
        // Pause drawing while nobody could see it.
        let ws = NSWorkspace.shared.notificationCenter
        for (name, key, on) in [(NSWorkspace.screensDidSleepNotification, "display", true),
                                (NSWorkspace.screensDidWakeNotification, "display", false),
                                (NSWorkspace.sessionDidResignActiveNotification, "session", true),
                                (NSWorkspace.sessionDidBecomeActiveNotification, "session", false)] {
            ws.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.setPaused(key, on) }
            }
        }
        let dnc = DistributedNotificationCenter.default()
        for (name, on) in [("com.apple.screenIsLocked", true), ("com.apple.screenIsUnlocked", false)] {
            dnc.addObserver(forName: Notification.Name(name), object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.setPaused("lock", on) }
            }
        }
    }

    func setPaused(_ reason: String, _ on: Bool) {
        let was = !paused.isEmpty
        if on { paused.insert(reason) } else { paused.remove(reason) }
        if was != !paused.isEmpty {
            journal.line(paused.isEmpty ? "RESUME" : "PAUSE   \(reason)")
            lastFrame = CACurrentMediaTime()
        }
    }

    func describe(_ v: StageVerdict) -> String {
        switch v {
        case .free: "free"
        case .hold(let who): "hold who=\(who)"
        case .allowed(let who): "allowed who=\(who)"
        case .foreign(let who, let reason): "claim who=\(who) reason=\(reason)"
        case .pending: "claim being written (lock without a claim file)"
        }
    }

    // MARK: Frames

    func tick() {
        guard paused.isEmpty, !finished else { return }
        let now = CACurrentMediaTime()
        renderFrame(dt: now - lastFrame)
        lastFrame = now
    }

    func renderFrame(dt: Double) {
        guard let director else { return }
        director.step(dt: dt)
        guard let img = grayImage(director.frame, size: sceneSize) else { return }
        // Rail 8: a slow orbit of up to ~2.5 points, in whole device pixels.
        let t = CACurrentMediaTime() - launched
        let ox = (sin(t * 2 * .pi / 420) * 2.5 * 2).rounded() / 2
        let oy = (sin(t * 2 * .pi / 660 + 1.3) * 2.5 * 2).rounded() / 2
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer.contents = img
        imageLayer.frame.origin = CGPoint(x: layerOrigin.x + ox, y: layerOrigin.y + oy)
        CATransaction.commit()
        if director.currentName != shownScene {
            if !shownScene.isEmpty { journal.line("SCENE   \(director.currentName)") }
            shownScene = director.currentName
            if window != nil { writeState() }
        }
    }

    func writeState() {
        journal.writeState(pid: NSRunningApplication.current.processIdentifier,
                           scene: shownScene.isEmpty ? director?.currentName ?? "?" : shownScene,
                           since: startedAt, window: window?.windowNumber ?? 0)
    }

    // MARK: Exits

    func refuse(_ why: String, code: Int32) {
        journal.line("REFUSED \(why)")
        FileHandle.standardError.write(Data("StageAmbient: refused — \(why)\n".utf8))
        exit(code)
    }

    /// The one exit path: stop drawing, put the cursor back, hide the window, hand activation back to
    /// whatever was frontmost, log why, and go.
    func finish(_ why: String, restoreFocus: Bool = true) {
        guard !finished else { return }
        finished = true
        timers.forEach { $0.invalidate() }
        signals.forEach { $0.cancel() }
        if cursorHidden { NSCursor.unhide(); cursorHidden = false }
        window?.orderOut(nil)
        if restoreFocus, let prev = previousApp, !prev.isTerminated, NSApp.isActive {
            NSApp.yieldActivation(to: prev)
            prev.activate(from: .current, options: [])
        }
        journal.clearState()
        let up = CACurrentMediaTime() - launched
        journal.line(String(format: "OFF     %@ (up %.1f s, return-to=%@)", why, up,
                            restoreFocus ? (previousApp?.localizedName ?? "none") : "-"))
        // A beat for the activation hand-back to land before the process goes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { exit(0) }
    }
}

// MARK: main

let options = Options.parse(CommandLine.arguments)
let (config, configProblem) = AmbientConfig.load(options.config)
if let configProblem { FileHandle.standardError.write(Data("StageAmbient: \(configProblem)\n".utf8)) }

if options.list {
    for type in SceneRegistry.all {
        let w = config.scenes.first { $0.name == type.name }?.weight ?? 0
        print("\(type.name)\tweight \(w)\t\(type.summary)")
    }
    exit(0)
}
if let url = options.gallery {
    // Tuning aid: every koi variety, still, on black.
    let size = options.size ?? PixelSize(width: 432, height: 280)
    let canvas = Canvas(size: size)
    KoiPond.gallery(into: canvas)
    let frame = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size.count)
    canvas.dither(into: frame)
    if let img = grayImage(frame, size: size, scale: options.gifScale),
       let d = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) {
        CGImageDestinationAddImage(d, img, nil)
        CGImageDestinationFinalize(d)
    }
    exit(0)
}
if options.renderGIF != nil || options.framesDir != nil || options.bench {
    runOffscreen(options, config: config)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let host = Host(options: options, config: config, journal: Journal(log: options.log, state: options.state))
app.delegate = host
app.run()
