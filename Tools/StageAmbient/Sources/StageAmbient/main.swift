import AmbientKit
import AppKit
import QuartzCore

// StageAmbient — the window app `Tools/ambient on` launches through LaunchServices. It puts one
// borderless black window over the built-in display at screen-saver level and shows the Director's 1-bit
// frames, scaled up nearest-neighbour, at the configured frame cap. Window mode only: the offscreen aids
// are AmbientRender, so a process named "StageAmbient" is always the ambient on screen.
//
// The rails (README.md), each held here; the decisions themselves are AmbientKit's pure rules (Rails.swift):
//  1. The process is "StageAmbient" — never "Variorum".
//  2. A stage claim whose reason doesn't start with "HOLD:" ends it within ~0.3 s (polled 4×/s).
//  3. No screensaver machinery: an ordinary app window.
//  4. Nothing is posted and no power or user-activity assertion is taken: input is detected by READING
//     the HID system's idle time, the same number the coordinator reads.
//  5. Real input ends it (polled 10×/s), counting from `on`'s idle gate.
//  6. One small layer update per frame at ~12 fps; the scene is a few hundred pixels across.
//  7. The cursor hides while up and is shown again on every exit path we control; the window server
//     restores it if the process dies outright. Activation goes back to the app that was frontmost.
//  8. Everything in the scene moves, and the whole picture orbits by up to 2.5 points.

struct Options {
    var config: URL?
    var scene: String?
    var stay = false
    var seed: UInt64?
    var allowClaimant: String?
    var stageDir = StageClaim.defaultLockDirectory
    var returnPID: pid_t?
    /// `Tools/ambient on`'s idle gate (seconds since 1970): input after it counts.
    var inputSince: Double?
    /// Hiding the cursor needs the app active (macOS shows it again for any app that isn't), so the
    /// ambient takes activation while up and hands it back on every exit. --no-activate opts out.
    var activate = true
    var log = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".variorum/ambient.log")
    var state = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".variorum/ambient.state")

    static func parse(_ args: [String]) -> Options {
        var o = Options()
        var i = 1
        func value() -> String? {
            i += 1
            return i < args.count ? args[i] : nil
        }
        while i < args.count {
            switch args[i] {
            case "--config": o.config = value().map { URL(fileURLWithPath: $0) }
            case "--scene": o.scene = value()
            case "--stay": o.stay = true
            case "--seed": o.seed = value().flatMap { UInt64($0) }
            case "--allow-claimant": o.allowClaimant = value()
            case "--stage-dir": if let v = value() { o.stageDir = URL(fileURLWithPath: v, isDirectory: true) }
            case "--return-pid": o.returnPID = value().flatMap { pid_t($0) }
            case "--input-since": o.inputSince = value().flatMap { Double($0) }
            case "--no-activate": o.activate = false
            case "--log": if let v = value() { o.log = URL(fileURLWithPath: v) }
            case "--state": if let v = value() { o.state = URL(fileURLWithPath: v) }
            default: break // LaunchServices may add arguments of its own; ignore anything unknown.
            }
            i += 1
        }
        return o
    }
}

// MARK: Log and state (the coordinator reads both; stage.log is Tools/stage's alone)

final class Journal {
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
        let text = "PID=\(pid)\nSCENE=\(scene)\nSINCE=\(f.string(from: since))\nWINDOW=\(window)\n"
        try? Data(text.utf8).write(to: state, options: .atomic)
    }

    func clearState() { try? FileManager.default.removeItem(at: state) }
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
func displayID(_ screen: NSScreen) -> CGDirectDisplayID {
    (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? CGMainDisplayID()
}

// MARK: Window

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
    /// Seconds between `on`'s idle gate and launch, when the wrapper passed one.
    let gateAgeAtLaunch: Double?
    var lastFrame = CACurrentMediaTime()
    var startedAt = Date()
    var previousApp: NSRunningApplication?
    var cursorHidden = false
    var becameActive = false
    var isUp = false
    var launchVerdict: StageVerdict?
    var stageWatch = StageWatch()
    var paused: Set<String> = []
    var shownScene = ""
    var finished = false
    var layerOrigin = CGPoint.zero
    var hiddenOn = CGMainDisplayID()
    /// Three frame buffers the layer's images point into, reused in turn (no allocation per frame).
    /// Core Animation copies an image's bits at commit; three keeps a margin — never cut this to one.
    var imageBuffers: [UnsafeMutableRawPointer] = []
    var nextBuffer = 0

    init(options: Options, config: AmbientConfig, journal: Journal) {
        self.options = options
        self.config = config
        self.journal = journal
        gateAgeAtLaunch = options.inputSince.map { Date().timeIntervalSince1970 - $0 }
    }

    func applicationDidFinishLaunching(_ note: Notification) {
        let me = NSRunningApplication.current
        if let id = me.bundleIdentifier,
           NSRunningApplication.runningApplications(withBundleIdentifier: id).contains(where: { $0.processIdentifier != me.processIdentifier }) {
            return refuse("already running", code: 5)
        }
        guard let screen = builtInScreen() else { return refuse("no screen", code: 6) }
        let verdict = StageClaim.read(lockDirectory: options.stageDir, allowedClaimant: options.allowClaimant)
        let locked = (CGSessionCopyCurrentDictionary() as? [String: Any])?["CGSSessionScreenIsLocked"] as? Bool ?? false
        if let no = LaunchRule.refusal(stage: verdict, screenLocked: locked,
                                       displayAsleep: CGDisplayIsAsleep(displayID(screen)) != 0) {
            return refuse(no.reason, code: no.exitCode)
        }

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
        hiddenOn = displayID(screen)

        renderFrame(dt: 0)
        w.makeKeyAndOrderFront(nil)
        w.makeFirstResponder(view)
        guard w.isVisible else { return refuse("the window did not come up", code: 8) }
        launchVerdict = verdict
        installWatchers()
        repeating(1 / config.fps) { $0.tick() }
        if options.activate {
            // Activation is a request the system may decline. The ambient is up only once it is active
            // (that is what lets it hide the cursor and swallow the waking keystroke):
            // applicationDidBecomeActive declares it; if that never comes, it refuses.
            NSApp.activate(ignoringOtherApps: true)
            if NSApp.isActive { declareUp() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self, !self.isUp, !self.finished else { return }
                self.refuse("activation was declined (the cursor could not be hidden)", code: 9)
            }
        } else {
            declareUp()
        }
    }

    /// The moment the ambient is really up: visible, active, cursor hidden. Only now does the state file
    /// appear, and `on` waits for it before it says ON.
    func declareUp() {
        guard !isUp, !finished, let director, window?.isVisible == true else { return }
        hideCursor()
        isUp = true
        startedAt = Date()
        journal.line("ON      pid=\(NSRunningApplication.current.processIdentifier) scene=\(director.currentName) size=\(sceneSize.width)x\(sceneSize.height) fps=\(Int(config.fps)) stage=\(launchVerdict?.summary ?? "?") return-to=\(previousApp?.localizedName ?? "none")")
        writeState()
    }

    func hideCursor() {
        guard !cursorHidden else { return }
        CGDisplayHideCursor(hiddenOn)
        cursorHidden = true
    }

    func applicationDidBecomeActive(_ note: Notification) {
        becameActive = true
        if window != nil { declareUp() }
    }

    func applicationDidResignActive(_ note: Notification) {
        guard becameActive else { return }
        let front = NSWorkspace.shared.frontmostApplication?.localizedName ?? "another app"
        finish("lost focus to \(front)", restoreFocus: false)
    }

    /// A quit Apple Event (osascript, a logout or restart) tidies up like every other exit and then lets
    /// the termination proceed. Never .terminateCancel: that would abort a logout or restart.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        wrapUp("quit request")
        return .terminateNow
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
        // Rail 5: real input since `on`'s idle gate (else since launch, after a short grace). Reading the
        // idle time posts nothing and asserts nothing.
        repeating(0.1) { host in
            let uptime = CACurrentMediaTime() - host.launched
            let idle = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
            let watching = InputRule.watching(uptime: uptime, gateAge: host.gateAgeAtLaunch.map { $0 + uptime })
            if InputRule.inputArrived(watching: watching, idle: idle) {
                host.finish(String(format: "input (HID idle %.2f s)", idle))
            }
        }
        // Rail 2: the stage, with the mid-write grace (StageWatch).
        repeating(0.25) { host in
            let v = StageClaim.read(lockDirectory: host.options.stageDir, allowedClaimant: host.options.allowClaimant)
            if host.stageWatch.mustGo(after: v, at: CACurrentMediaTime()) { host.finish("stage \(v.summary)") }
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
        guard let img = reusableImage(director.frame) else { return }
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
            if isUp { writeState() }
        }
    }

    /// The frame as a 32-bit image already in the screen's colour space, written into one of three
    /// reused buffers: Core Animation can take it as it is instead of re-rendering a gray image every frame.
    func reusableImage(_ frame: UnsafeMutableBufferPointer<UInt8>) -> CGImage? {
        let count = sceneSize.count
        if imageBuffers.isEmpty {
            imageBuffers = (0..<3).map { _ in UnsafeMutableRawPointer.allocate(byteCount: count * 4, alignment: 64) }
        }
        let buf = imageBuffers[nextBuffer]
        nextBuffer = (nextBuffer + 1) % imageBuffers.count
        let px = buf.bindMemory(to: UInt32.self, capacity: count)
        for i in 0..<count { px[i] = frame[i] == 0 ? 0xFF00_0000 : 0xFFFF_FFFF }
        guard let provider = CGDataProvider(dataInfo: nil, data: buf, size: count * 4, releaseData: { _, _, _ in }) else { return nil }
        let space = window?.screen?.colorSpace?.cgColorSpace ?? CGColorSpaceCreateDeviceRGB()
        return CGImage(width: sceneSize.width, height: sceneSize.height, bitsPerComponent: 8, bitsPerPixel: 32,
                       bytesPerRow: sceneSize.width * 4, space: space,
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }

    func writeState() {
        journal.writeState(pid: NSRunningApplication.current.processIdentifier,
                           scene: shownScene.isEmpty ? director?.currentName ?? "?" : shownScene,
                           since: startedAt, window: window?.windowNumber ?? 0)
    }

    // MARK: Exits

    func refuse(_ why: String, code: Int32) {
        finished = true
        timers.forEach { $0.invalidate() }
        restoreScreen(handBackFocus: true)
        journal.clearState()
        journal.line("REFUSED \(why)")
        FileHandle.standardError.write(Data("StageAmbient: refused — \(why)\n".utf8))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { exit(code) }
    }

    /// Cursor back, window away, and (unless someone else just took it) activation handed back to the app
    /// that was frontmost when `on` ran.
    func restoreScreen(handBackFocus: Bool) {
        if cursorHidden { CGDisplayShowCursor(hiddenOn); cursorHidden = false }
        window?.orderOut(nil)
        if handBackFocus, let prev = previousApp, !prev.isTerminated, NSApp.isActive {
            NSApp.yieldActivation(to: prev)
            prev.activate(from: .current, options: [])
        }
    }

    /// Everything an exit does before the process goes, once: stop drawing, restore the screen and
    /// focus, clear the state file, and log why.
    func wrapUp(_ why: String, restoreFocus: Bool = true) {
        guard !finished else { return }
        finished = true
        timers.forEach { $0.invalidate() }
        signals.forEach { $0.cancel() }
        restoreScreen(handBackFocus: restoreFocus)
        journal.clearState()
        let up = CACurrentMediaTime() - launched
        journal.line(String(format: "OFF     %@ (up %.1f s, return-to=%@)", why, up,
                            restoreFocus ? (previousApp?.localizedName ?? "none") : "-"))
    }

    /// The exit for everything but a quit request: wrap up, then go after a beat for the activation
    /// hand-back to land.
    func finish(_ why: String, restoreFocus: Bool = true) {
        guard !finished else { return }
        wrapUp(why, restoreFocus: restoreFocus)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { exit(0) }
    }
}

// MARK: main

let options = Options.parse(CommandLine.arguments)
let (config, configProblem) = AmbientConfig.load(options.config)
let journal = Journal(log: options.log, state: options.state)
if let configProblem { journal.line("CONFIG  \(configProblem)") }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let host = Host(options: options, config: config, journal: journal)
app.delegate = host
app.run()
