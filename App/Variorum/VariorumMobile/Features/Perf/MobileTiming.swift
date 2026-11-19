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
//  · **survival** — the recorder is process-global, so it outlives the
//    session, the shell and a Castle lock (the unlock span crosses one); it is
//    also written to `UserDefaults` at every backgrounding and read back at
//    launch, so a kill in the background loses nothing and cold launches
//    accumulate. Durations and counts only, outside the store, keyed to the
//    running binary's build fingerprint — a new install starts clean.
//
//  The record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 1).
//

import QuartzCore
import UIKit
import VariorumCore

@MainActor
enum MobileTiming {
    private static var started = false
    private static var observers: [NSObjectProtocol] = []

    /// Whether the software keyboard is up (the last `keyboardDidShow` /
    /// `keyboardDidHide`).
    private(set) static var keyboardIsUp = false

    /// This build's fingerprint (`AppTiming.buildFingerprint`) — what a
    /// persisted record must match to be restored.
    static let build = AppTiming.buildFingerprint() ?? "unknown"

    /// A test runner's host keeps a recorder (the speed tests read it) but
    /// never reads or writes the app's persisted record.
    private static var persists: Bool { AppBootstrap.Launch.thisProcess == .app }

    /// Turns the layer on. Called once, first thing in the app's init — before
    /// the bootstrap begins opening the store, so the open's own marks land.
    static func start() {
        guard !started else { return }
        started = true
        AppTiming.recorder.setEnabled(true)
        if persists { AppTiming.restore(build: build) }
        AppTiming.launched(processStart: AppTiming.processStartInstant())
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
    /// record written now (iOS may end the process without another word).
    static func appLeaving() {
        AppTiming.appLeaving()
        persist()
    }

    /// Writes the record (numbers only) for the next launch of this build.
    static func persist() {
        guard persists else { return }
        AppTiming.persist(build: build)
    }

    /// The readout's Reset: nothing recorded, in memory or on disk.
    static func reset() {
        AppTiming.reset()
    }

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
