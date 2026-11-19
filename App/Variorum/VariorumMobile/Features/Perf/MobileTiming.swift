//
//  MobileTiming.swift
//  VariorumMobile
//
//  VM-65 (the VM-64 run, batch 1) — THE PHONE'S HALF OF THE TIMING LAYER: the
//  catalog and its marks are shared (`Shared/AppTiming.swift`), the brain is
//  Core's (`VariorumCore/Diagnostics`); what only a phone has lives here —
//
//  · **turning it on**, at launch, before the bootstrap starts opening, with
//    the launch spans begun at the process's true start;
//  · **the keyboard watch** — `keyboardDidShow` is the "keyboard up" moment,
//    and whether the keyboard is already up decides whether a tap on the box
//    is waiting for one;
//  · **the next-frame tick** — a span that ends "on screen" ends at the
//    display-link tick after the render (the frame carrying it has been
//    committed by then), so the layout the render set off is inside it;
//  · **survival** (the author's sharpening, 2026-11-19 — the record's §5/§7):
//    the record outlives a full quit and an install in place, ONE TABLE PER
//    BUILD (`TimingBook`, Core), this build's and the previous build's, in one
//    small file in the app's own container —
//    `Library/Application Support/Timing/timing.json` — outside the store,
//    durations and counts only. Saves are BATCHED off every timed path: the
//    recorder tells this store about the first change after a save; the store
//    writes `saveDelay` later on its own utility queue, and at once (on that
//    queue, under a background-task grant) when the app is backgrounded. So a
//    crash loses at most the last `saveDelay` of marks. The launch never waits
//    on the file either: the record starts measuring at once and the kept
//    table is read on the store's queue and folded under it (`absorb`).
//
//  The record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 1).
//

import QuartzCore
import Synchronization
import UIKit
import VariorumCore

@MainActor
enum MobileTiming {
    private static var started = false
    private static var observers: [NSObjectProtocol] = []

    /// Whether the software keyboard is up (the last `keyboardDidShow` /
    /// `keyboardDidHide`).
    private(set) static var keyboardIsUp = false

    /// The running build as the record keys it and as the readout names it.
    ///
    /// **The key is the short version, the build number AND the executable's
    /// fingerprint** (PROVISIONAL P-65-3). Her words key a table on the build
    /// number; but the phone does not stamp its build number — every phone
    /// build says `1` (the project file's `CURRENT_PROJECT_VERSION`; only the
    /// Mac target runs `StampBuildNumber.sh`) — so the number alone would blend
    /// the BEFORE build into the AFTER build, which her own rule forbids. The
    /// fingerprint (`LC_UUID`) changes with every build of new code; the label
    /// shows all three.
    static let build: (key: String, label: String) = {
        let info = Bundle.main.infoDictionary ?? [:]
        let short = info["CFBundleShortVersionString"] as? String ?? "?"
        let number = info["CFBundleVersion"] as? String ?? "?"
        let print = AppTiming.buildFingerprint() ?? "unknown"
        #if DEBUG
        let configuration = "Debug"
        #else
        let configuration = "Release"
        #endif
        return ("\(short)|\(number)|\(print)",
                "\(short) (\(number)) \(configuration) · \(print.prefix(8))")
    }()

    /// A test runner's host keeps a recorder (the speed tests read it) but
    /// never reads or writes the app's timing file.
    private static var persists: Bool { AppBootstrap.Launch.thisProcess == .app }

    private static let store = MobileTimingStore(file: MobileTimingStore.defaultFile)

    /// Turns the layer on. Called once, first thing in the app's init — before
    /// the bootstrap begins opening the store, so the open's own marks land.
    static func start() {
        guard !started else { return }
        started = true
        AppTiming.recorder.setEnabled(true)
        AppTiming.launched(processStart: AppTiming.processStartInstant())
        if persists {
            store.load(build: build.key, label: build.label)
            AppTiming.recorder.setChangeHandler { [store] in store.saveSoon() }
        }
        let center = NotificationCenter.default
        observers = [
            center.addObserver(
                forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main
            ) { _ in
                MainActor.assumeIsolated {
                    keyboardIsUp = true
                    AppTiming.keyboardUp()
                }
            },
            center.addObserver(
                forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main
            ) { _ in
                MainActor.assumeIsolated { keyboardIsUp = false }
            },
        ]
    }

    /// The app is going to the background: the leaving is counted and the
    /// record saved now (iOS may end the process without another word).
    static func appLeaving() {
        AppTiming.appLeaving()
        saveNow()
    }

    /// Saves now, on the store's queue, under a background-task grant of its
    /// own (the leaving's grant may end first).
    static func saveNow() {
        guard persists else { return }
        let grant = SaveGrant()
        grant.begin()
        store.saveNow {
            Task { @MainActor in grant.end() }
        }
    }

    /// The readout's Reset: THIS build's table only — nothing recorded, in
    /// memory and in the file. The previous build's table is untouched (it
    /// ages out when a newer build opens — PROVISIONAL P-65-4).
    static func reset() {
        AppTiming.recorder.reset()
        saveNow()
    }

    /// The previous build's table, as last saved (nil — none kept).
    static var previousBuild: TimingArchive? { store.previous }

    // MARK: - "On screen" moments

    /// The editor's first render of a note: the text is on screen one frame on.
    static func noteRendered() {
        afterNextFrame { AppTiming.notePainted() }
    }

    /// The shell appeared.
    static func homeAppeared() {
        afterNextFrame { AppTiming.homeOnScreen() }
    }

    /// The lock screen appeared.
    static func lockScreenAppeared() {
        afterNextFrame { AppTiming.lockScreenShown() }
    }

    /// Runs `body` at the next display-link tick — after the frame that carries
    /// whatever the caller just did has been committed. A one-shot: the link
    /// invalidates itself, which releases it and its target. Inert (no link)
    /// while the recorder is off.
    static func afterNextFrame(_ body: @escaping @MainActor () -> Void) {
        guard AppTiming.isEnabled else { return }
        NextFrameTick.schedule(body)
    }
}

/// A save's own background-task grant: begun before the save is queued, handed
/// back exactly once — when the save is done, or when iOS says time is up
/// (the save is milliseconds; the handler is there so an overrun is never
/// fatal — `BackgroundAssertion`'s lesson).
@MainActor
private final class SaveGrant {
    private var token = UIBackgroundTaskIdentifier.invalid

    func begin() {
        token = UIApplication.shared.beginBackgroundTask(withName: "Variorum timing save") { [self] in
            end()
        }
    }

    func end() {
        guard token != .invalid else { return }
        UIApplication.shared.endBackgroundTask(token)
        token = .invalid
    }
}

/// One display-link tick, then gone. The run loop holds the link and the link
/// holds this target until `fire` invalidates it.
@MainActor
private final class NextFrameTick: NSObject {
    private var body: (@MainActor () -> Void)?
    private var link: CADisplayLink?

    static func schedule(_ body: @escaping @MainActor () -> Void) {
        let tick = NextFrameTick()
        tick.body = body
        let link = CADisplayLink(target: tick, selector: #selector(fire))
        tick.link = link
        link.add(to: .main, forMode: .common)
    }

    @objc private func fire() {
        link?.invalidate()
        link = nil
        let run = body
        body = nil
        run?()
    }
}

// MARK: - The timing file

/// The timing file's one owner: reads it once (at launch, on its own queue),
/// writes it in batches, and holds the book the readout reads the previous
/// build's table from. Every file touch is on `queue` (serial, utility), never
/// the main thread and never a timed path.
nonisolated final class MobileTimingStore: @unchecked Sendable {
    /// How long after the first unsaved change a save runs — the most a crash
    /// can lose.
    static let saveDelay: DispatchTimeInterval = .seconds(20)

    /// `Library/Application Support/Timing/timing.json` in the app's container.
    static var defaultFile: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Timing", isDirectory: true)
            .appendingPathComponent("timing.json", isDirectory: false)
    }

    private let file: URL?
    private let recorder: TimingRecorder<AppTimingSeries, AppTimingCounter>
    private let queue = DispatchQueue(label: "io.lduarte.Variorum.timing-file", qos: .utility)
    /// Written on `queue`, read by the readout on the main thread.
    private let book = Mutex(TimingBook())
    /// Confined to `queue` (set by `load`, read by `write`).
    private var buildKey = ""
    private var buildLabel = ""

    /// `recorder`: the app's one (tests hand in their own).
    init(
        file: URL?,
        recorder: TimingRecorder<AppTimingSeries, AppTimingCounter> = AppTiming.recorder
    ) {
        self.file = file
        self.recorder = recorder
    }

    /// Reads the file, opens this build's table (keeping the previous build's)
    /// and folds the kept table under whatever the launch has measured since.
    func load(build key: String, label: String) {
        queue.async { [self] in
            buildKey = key
            buildLabel = label
            var loaded = file.flatMap { try? Data(contentsOf: $0) }.flatMap(TimingBook.decode) ?? TimingBook()
            if let kept = loaded.open(build: key, label: label) {
                recorder.absorb(kept)
            }
            book.withLock { $0 = loaded }
        }
    }

    /// A change landed: save `saveDelay` from now (the recorder calls this at
    /// most once per save, so these never pile up).
    func saveSoon() {
        queue.asyncAfter(deadline: .now() + Self.saveDelay) { [self] in write() }
    }

    /// Saves as soon as the queue is free, then calls `done` (on the queue).
    func saveNow(done: (@Sendable () -> Void)? = nil) {
        queue.async { [self] in
            write()
            done?()
        }
    }

    /// The previous build's table.
    var previous: TimingArchive? { book.withLock { $0.previous } }

    /// On `queue` only. Takes the record (marking it saved FIRST, so a mark
    /// racing the write is saved again later, never lost), keeps it as this
    /// build's table, and writes the book atomically.
    private func write() {
        guard let file, !buildKey.isEmpty else { return }
        let archive = recorder.archive(build: buildKey, label: buildLabel, markingSaved: true)
        let bytes = book.withLock { book -> Data? in
            book.store(archive)
            return try? book.encoded()
        }
        guard let bytes else { return }
        try? FileManager.default.createDirectory(
            at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        // Readable after the first unlock since boot, so a save while the phone
        // is locked (a backgrounding) still lands. Numbers only.
        try? bytes.write(to: file, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}
