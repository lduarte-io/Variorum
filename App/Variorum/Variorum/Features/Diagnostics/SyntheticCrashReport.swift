//
//  SyntheticCrashReport.swift
//  Variorum (Mac) — DEBUG ONLY, and inside DEBUG only when asked for
//
//  Phase 13r U3-B — the acceptance's "the surface exercised via an INJECTED
//  SYNTHETIC payload through the seam". MetricKit delivers on the OS's
//  schedule (R-13r-5's accepted trade-off), so a walk cannot wait for a real
//  crash; this door hands a crash report's bytes to the REGISTERED
//  subscriber's own delivery (`deliverAsMetricKitWould`) — everything below
//  MetricKit's payload object is the real road: the subscriber, the hop to
//  the main actor, the owner's ON gate, the store, the Diagnostics list.
//
//  GATED THREE TIMES (the `VisualWalkProbe` precedent, plus the opt-in):
//  `#if DEBUG` (a Release build compiles this file to nothing); inside DEBUG,
//  only when the process was launched with `VARIORUM_SYNTHETIC_CRASH_REPORT`
//  naming a file; and only when crash reporting is ON — an OFF app has no
//  subscriber, so there is nothing to deliver INTO, exactly as with MetricKit.
//
//  The app is sandboxed, so the file must be readable from inside the
//  container — the walk writes it under the Debug app's own
//  `~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/`.
//

#if DEBUG
import Foundation

@MainActor
enum SyntheticCrashReport {
    /// The launch environment key the walk sets: a path to a crash report.
    static let environmentKey = "VARIORUM_SYNTHETIC_CRASH_REPORT"

    enum Outcome: String, Equatable {
        case notRequested
        /// The named file could not be read (outside the sandbox, or absent).
        case unreadable
        /// Crash reporting is OFF: no subscriber exists, nothing is delivered.
        case offSoNothingDelivered
        case delivered
    }

    /// Called once from `applicationDidFinishLaunching` (DEBUG). A no-op
    /// unless the walk launched this process with the key set.
    @discardableResult
    static func injectIfRequested(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        into owner: CrashReporting
    ) -> Outcome {
        guard let path = environment[environmentKey], !path.isEmpty else { return .notRequested }
        let outcome: Outcome
        if let bytes = FileManager.default.contents(atPath: path) {
            if let subscriber = owner.subscriber {
                subscriber.deliverAsMetricKitWould([bytes])
                outcome = .delivered
            } else {
                outcome = .offSoNothingDelivered
            }
        } else {
            outcome = .unreadable
        }
        // The walk reads this line (DEBUG only).
        NSLog("[13r-u3b] synthetic crash report: %@", outcome.rawValue)
        return outcome
    }
}
#endif
