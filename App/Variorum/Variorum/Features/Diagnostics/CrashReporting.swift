//
//  CrashReporting.swift
//  Variorum (MAC ONLY — the phone's crash-report face is a named mobile
//  candidate row, never built here)
//
//  Phase 13r U3-B — R-13r-5: **crash reporting through MetricKit, ZERO new
//  dependency, opt-in, default OFF — PROVABLY.** The binding record is
//  `notes/plans/phase-13r-distribution.md` (the SITTING RECORD's R-13r-5, the
//  U3 section, the U3-B RECORD).
//
//  THE PROMISE, in the order it is kept:
//   1. **OFF unless she turns it on.** The opt-in is a LOCAL preference of
//      this app on this Mac (the 18j `AppearanceChoice` pattern — never a
//      synced `setting`: whether this machine collects its own crash reports
//      is a fact about the machine, not the document). Only an explicit YES
//      turns it on; an absent, false or strange value is OFF.
//   2. **OFF means NOT SUBSCRIBED.** MetricKit hands an app nothing unless it
//      registers a subscriber with `MXMetricManager`. The registration goes
//      through an INJECTED seam (`CrashDiagnosticRegistration`) so that the
//      OFF state is a pinnable fact — "no registration happened" — rather
//      than a claim (`CrashReportingTests`).
//   3. **ON means the reports land HERE and nowhere else.** A delivered
//      `MXCrashDiagnostic` is written, byte for byte as MetricKit handed it,
//      into a local folder (`CrashReportStore`); the Diagnostics surface
//      shows those bytes VERBATIM.
//   4. **Nothing is ever sent automatically, ever.** No code in this app
//      transmits a report. The only road out is her own hand: Send opens
//      the support door's mail draft with the report attached, visible
//      before she sends it (`SupportDraft`).
//
//  THE ROAD, read from this machine's macOS 27.0 SDK headers before relying
//  on it: `MXMetricManager` (`add`/`remove`), `MXMetricManagerSubscriber
//  .didReceive(_: [MXDiagnosticPayload])`, `MXDiagnosticPayload
//  .crashDiagnostics`, `MXCrashDiagnostic.jsonRepresentation()` — all
//  `macos(12.0)`, marked "to be deprecated" (no warning) beside a Swift
//  `MetricManager` that is macOS 27+, which this macOS 26 target cannot use
//  without the availability gating AppSpec §1 rules out. Delivery is on the
//  OS's schedule (typically the next launch, up to about a day) — R-13r-5's
//  accepted trade-off.
//
//  WHY THE APP DELEGATE OWNS IT: one per app, alive before the first window
//  (a subscriber registered at launch is how MetricKit's pending payloads
//  arrive) — the `AppearanceController` / `UpdateChannel` precedent.
//

import Foundation
import MetricKit
import Observation

// MARK: - The opt-in (the pure half)

/// The LOCAL machine preference. A rule with no state, so its stored form is
/// pinnable without an app.
nonisolated enum CrashReportingPreference {
    /// This Mac's `UserDefaults` key (the app's own container).
    static let settingKey = "variorum.crashReports.optIn"

    /// **Only an explicit YES is ON.** Absent (every fresh install), `false`,
    /// or any value that is not a boolean reads OFF — the default can never
    /// be flipped by a stray value.
    static func remembered(_ defaults: UserDefaults) -> Bool {
        (defaults.object(forKey: settingKey) as? Bool) == true
    }
}

// MARK: - THE REGISTRATION SEAM (R-13r-5's "pinnable OFF")

/// The one door between this app and `MXMetricManager`'s subscriber list.
/// Production passes `MetricKitRegistration`; the pins pass a recorder and
/// assert that OFF registered nothing.
@MainActor
protocol CrashDiagnosticRegistration: AnyObject {
    func register(_ subscriber: CrashDiagnosticSubscriber)
    func unregister(_ subscriber: CrashDiagnosticSubscriber)
}

/// The real registration: MetricKit's shared manager.
@MainActor
final class MetricKitRegistration: CrashDiagnosticRegistration {
    func register(_ subscriber: CrashDiagnosticSubscriber) {
        MXMetricManager.shared.add(subscriber)
    }

    func unregister(_ subscriber: CrashDiagnosticSubscriber) {
        MXMetricManager.shared.remove(subscriber)
    }
}

// MARK: - The subscriber

/// MetricKit's subscriber. It takes DIAGNOSTIC payloads only — it does not
/// implement the metrics callback, so no metrics are ever delivered to it —
/// and of a diagnostic payload it keeps the CRASH diagnostics only (R-13r-5
/// names `MXCrashDiagnostic`; a hang or CPU-exception diagnostic in the same
/// payload is never stored, shown or sent).
///
/// MetricKit calls it on a queue of its own, so it is `nonisolated`; it hands
/// the bytes on through `deliver`, which the owner hops to the main actor.
nonisolated final class CrashDiagnosticSubscriber: NSObject, MXMetricManagerSubscriber,
    @unchecked Sendable
{
    /// Immutable after init; the only state.
    private let deliver: @Sendable ([Data]) -> Void

    init(deliver: @escaping @Sendable ([Data]) -> Void) {
        self.deliver = deliver
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        let reports = Self.crashReports(in: payloads)
        guard !reports.isEmpty else { return }
        deliver(reports)
    }

    /// Each crash diagnostic's own JSON, exactly as MetricKit renders it —
    /// one report per crash.
    static func crashReports(in payloads: [MXDiagnosticPayload]) -> [Data] {
        payloads.flatMap { $0.crashDiagnostics ?? [] }.map { $0.jsonRepresentation() }
    }

    /// The SAME delivery `didReceive` ends in, below the payload extraction
    /// (an `MXDiagnosticPayload` cannot be constructed outside MetricKit).
    /// The pins and the DEBUG walk's synthetic payload (`SyntheticCrashReport`)
    /// enter here — and only a REGISTERED subscriber exists to enter, so an
    /// OFF app has no door for a synthetic payload either.
    func deliverAsMetricKitWould(_ reports: [Data]) {
        deliver(reports)
    }
}

// MARK: - The one owner

/// **The app's ONE crash-reporting owner** (on `VariorumAppDelegate`). It
/// holds the opt-in, is the only thing that registers or unregisters the
/// subscriber, and keeps the list of received reports the Diagnostics
/// surface shows.
@MainActor
@Observable
final class CrashReporting {
    /// Whether this Mac collects crash reports. False until she says yes.
    private(set) var isOn: Bool
    /// Received reports, newest first (the store's own order).
    private(set) var reports: [CrashReport] = []

    @ObservationIgnored private let defaults: UserDefaults
    /// Internal for the pins (which registration a live owner holds).
    @ObservationIgnored let registration: CrashDiagnosticRegistration
    @ObservationIgnored let store: CrashReportStore
    @ObservationIgnored private let now: () -> Date
    /// Exists exactly while registered — the synthetic door's witness.
    @ObservationIgnored private(set) var subscriber: CrashDiagnosticSubscriber?

    init(
        defaults: UserDefaults,
        registration: CrashDiagnosticRegistration,
        store: CrashReportStore,
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.registration = registration
        self.store = store
        self.now = now
        isOn = CrashReportingPreference.remembered(defaults)
        reports = store.list()
        // THE LAUNCH ROAD: registered only when she already said yes.
        if isOn { subscribe() }
    }

    /// The app's own owner: this app's defaults, MetricKit, this Mac's folder.
    static func forThisApp(defaults: UserDefaults = .standard) -> CrashReporting {
        CrashReporting(
            defaults: defaults, registration: MetricKitRegistration(),
            store: .forThisApp())
    }

    /// Her answer. ON registers the subscriber; OFF unregisters it. Received
    /// reports stay on this Mac either way — they are hers, and turning
    /// collection off is not a request to delete what already arrived.
    func set(_ on: Bool) {
        guard on != isOn else { return }
        isOn = on
        defaults.set(on, forKey: CrashReportingPreference.settingKey)
        if on { subscribe() } else { unsubscribe() }
    }

    /// Re-reads the folder (the Diagnostics surface's appearance).
    func refresh() {
        reports = store.list()
    }

    /// Removes one received report from this Mac.
    func delete(_ report: CrashReport) {
        store.delete(report)
        reports = store.list()
    }

    /// A delivery from the subscriber. Stored only while ON: a delivery that
    /// races the switch to OFF is dropped, because OFF means nothing is
    /// collected.
    func receive(_ deliveries: [Data]) {
        guard isOn else { return }
        let stamp = now()
        for bytes in deliveries where !bytes.isEmpty {
            store.save(bytes, receivedAt: stamp)
        }
        reports = store.list()
    }

    private func subscribe() {
        guard subscriber == nil else { return }
        let subscriber = CrashDiagnosticSubscriber { [weak self] deliveries in
            Task { @MainActor in self?.receive(deliveries) }
        }
        self.subscriber = subscriber
        registration.register(subscriber)
    }

    private func unsubscribe() {
        guard let subscriber else { return }
        registration.unregister(subscriber)
        self.subscriber = nil
    }
}
