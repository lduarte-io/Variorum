//
//  MobileEditTrace.swift
//  VariorumMobile
//
//  ═══════════════════════════════════════════════════════════════════════
//  E1 — THE SETTLING EXPERIMENT (mobile round 2; temporary instrument)
//  ═══════════════════════════════════════════════════════════════════════
//
//  ## Why this file exists
//
//  Round 2's founding defect (M1) was a crash: `BlockRangeIndex`'s mutators
//  trapping when a stale gate verdict was consumed against the wrong edit.
//  That is FIXED on both platforms (`ArmedEdit.describes` binds the verdict
//  to the edit it answered about). What is NOT settled is **where the stale
//  verdict came from.** `notes/plans/mobile-round-2-crash-trace.md` §3c
//  ranks three candidates and labels the leader **SUSPECTED, not proven**:
//
//  > **M1 — the gate and the storage report are not 1:1 within one
//  > coordinated edit.** `NSTextStorage.coordinateEditing:` coalesces
//  > however many mutations happen inside it into ONE `didProcessEditing`
//  > carrying the union range and the NET delta — and UIKit's
//  > `deleteBackward` composes a delete with a re-insert inside one such
//  > block. If the gate is consulted per mutation, the last consult
//  > overwrites the first and the surviving verdict describes only the
//  > sub-edit while the delta is the net.
//
//  The round-2 ladder round 2 (§21) named the experiment that settles it —
//  *"log each consult's `(range, replacementLength)` and each report's
//  `(editedRange, delta)`; flag any report whose OLD span extends past the
//  last consult's `range.upperBound`"* — and ruled that **it must run on
//  her iOS 26.6 DEVICE, not the 26.2 simulator**, because it is an
//  input-path question and a non-reproduction on an older runtime is a
//  RUNTIME GAP, never an answer (round 2 §9's recorded gap).
//
//  Phase 13u is about to build a much larger cross-block gesture in this
//  exact seam (her 13u item 5 — *"the crash fix is stability, the semantics
//  are ruled HERE"*), which is why settling the root now is worth an hour.
//
//  ## What it records
//
//  Every gate consult (`shouldChangeText`) and every storage report
//  (`didProcessEditing`), in order, with the numbers that decide the
//  question — and three derived MISMATCH signals per report, computed
//  against the LAST consult that preceded it:
//
//  · **OVERRUN** — the report's OLD span (`location`, `length - delta`)
//    ends past the last consult's `range.upperBound`. **This is the flag
//    the ladder specified.**
//  · **STARTS-BEFORE** — the report begins before the approved range
//    (`_deleteBackwardAndNotify:…overrideOriginalContextBeforeInputWith:`
//    re-establishes context BEFORE the input point, by its own name).
//  · **NET≠** — the net delta is not the approved one
//    (`delta != replacementLength - range.length`). This is the crash's own
//    signature: a 5-character approval consumed by a 15-character net
//    deletion.
//
//  **All three are recorded because the specified one alone is NOT
//  sufficient**, and this was checked rather than assumed (the §63 lesson —
//  a settling experiment specified on paper may not reproduce the thing;
//  drive it). Re-run the trace's §5 worked example through the three
//  predicates:
//
//  | her crash | last consult | report old span | OVERRUN | STARTS-BEFORE | NET≠ |
//  |---|---|---|---|---|---|
//  | 15:52:43 `.block(2)` | (16,5) upper 21 | (12,15) upper 27 | **fires** | fires | fires |
//  | 13:59:27 `.tail`     | (22,5) upper 27 | (12,15) upper 27 | **silent** | fires | fires |
//
//  The tail crash's old span ends EXACTLY at the consult's upper bound, so
//  the specified predicate is silent on one of the two crashes we have.
//  `MobileEditTraceTests` pins both rows.
//
//  **And the specified predicate needed a carve-out to be usable at all.**
//  iOS WIDENS the reported `editedRange` of an insertion or a replacement
//  while never touching `delta` (round 2 measured both: a one-character
//  insert at offset 8 reported `{8, 9}`; a 5→6 replacement reported length
//  7). The old span is reconstructed from `length - delta`, so on a widened
//  report it always overshoots — the predicate as written fires on EVERY
//  ordinary keystroke, which would bury the real signal. It is therefore
//  evaluated only on PURE REMOVALS, where the reconstruction is exact, and
//  the readout prints the denominator so a zero is never read as "tested
//  and clean" when it was "not tested". Both of her crashes are pure
//  removals, so nothing the experiment exists to see is lost. The
//  false-positive rate is PINNED at the 100k fixture
//  (`MobilePerfWalkTests.theEditTraceIsInertDisarmedAndQuietArmedAt100k`)
//  rather than argued.
//
//  ## The discipline this instrument owes
//
//  · **ZERO behaviour change.** Every entry point is a pure append. No
//    routing, verdict, refusal or ordering is touched.
//  · **Inert unless armed**, and armed from the PHONE (Settings ▸
//    Diagnostics) with no Mac attached. The disarmed cost is one static
//    `Bool` read and a return — no allocation, no formatting, no log.
//  · **Release-live.** Her installs are Release by the A4 fence, and the
//    crash only ever happened there, so no `#if DEBUG` may gate the capture.
//  · **Bounded memory** (MobileSoul §2): a fixed `ringCapacity` ring, sized
//    once and then written in place. Counters are monotonic and survive the
//    wrap, so a long session's totals stay true even after the detail
//    scrolls off.
//  · **O(1) per edit** (P1): integers into a pre-sized ring; every string is
//    built at READ time, never on the keystroke road.
//
//  ## Removing it
//
//  When E1 is settled, delete this file and the five call sites it names
//  (`MobileEditorViewModel`: `shouldChangeText`'s first line and its arming
//  arm; `storageDidEdit`'s suppressed guard and its routing decision;
//  `desyncRecovery`) plus the Settings ▸ Diagnostics section. Nothing else
//  refers to it.
//

import Foundation
import SwiftUI
import UIKit
import os

// MARK: - The recorder

@MainActor
enum MobileEditTrace {
    /// The arming survives relaunch deliberately: the gesture under
    /// investigation used to KILL the app, and even healed it can be
    /// followed by a background/foreground cycle. She should never have to
    /// re-arm mid-experiment.
    static let armingDefaultsKey = "VariorumMobileEditTraceArmed"

    /// Bounded by construction (MobileSoul §2). 300 events is ~40 gestures'
    /// worth of gate/report pairs — far more than one walk produces, and
    /// ~19 KB of `Event`s.
    static let ringCapacity = 300

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "edit-trace")

    // MARK: The store, and why it is task-local-overridable

    /// Everything the recorder holds. A reference type so a test can bind
    /// its OWN and be immune to whatever else is running.
    ///
    /// **Why this indirection exists** (round-2 ladder round 1, MINOR 4 —
    /// the lesson `EditorAssertionSeam`'s doc comment already records):
    /// a plain set of statics is PROCESS-GLOBAL state, and Swift Testing
    /// runs suites in PARALLEL. A suite that arms the recorder holds it
    /// across many `await`s, and every other `@MainActor` editor suite
    /// scheduled during those suspensions would append ITS keystrokes into
    /// the same ring — so an absolute assertion like "one suspect
    /// signature" would break on scheduling, nondeterministically. A
    /// task-local override is scoped to the binding task and the tasks it
    /// spawns, and is invisible to every test running beside it.
    ///
    /// Production never binds one: `shipping` is the only store the app
    /// ever writes.
    @MainActor
    final class Recorder {
        var armed: Bool
        var ring: [Event] = []
        var writeIndex = 0
        var sequence = 0
        /// The consult a report is paired against, and how many consults
        /// arrived since the previous report (the headline test: *gate
        /// calls > reports* is M1 confirmed).
        var lastConsultRange = NSRange(location: 0, length: 0)
        var lastConsultReplacementLength = -1
        var consultsSinceReport = 0
        var summary = Summary()

        init(armed: Bool = false) { self.armed = armed }
    }

    /// The app's one store. Its arming is read ONCE from `UserDefaults`
    /// (lazy static init, `swift_once`), then held in memory — the
    /// keystroke road must never touch the defaults store. Deliberately NOT
    /// read at app construction: the 13e batch-9 lesson was about
    /// synchronous main-thread loads at launch, and this one happens at the
    /// first gate consult, long after.
    private static let shipping = Recorder(
        armed: UserDefaults.standard.bool(forKey: armingDefaultsKey))

    /// TESTS ONLY. Never bound in the app.
    @TaskLocal static var testRecorder: Recorder?

    private static var current: Recorder { testRecorder ?? shipping }

    // MARK: Arming

    static var isArmed: Bool { current.armed }

    static func setArmed(_ on: Bool) {
        let recorder = current
        recorder.armed = on
        // A bound test store is scratch state; only the app's own arming is
        // remembered across launches.
        if recorder === shipping {
            UserDefaults.standard.set(on, forKey: armingDefaultsKey)
            if on {
                log.notice("edit trace ARMED")
            } else {
                log.notice("edit trace disarmed")
            }
        }
    }

    // MARK: The event

    struct Flags: OptionSet, Sendable {
        let rawValue: UInt8
        /// Consult: this consult armed a verdict (returned `true` with an
        /// `ArmedEdit` parked).
        static let armed = Flags(rawValue: 1 << 0)
        /// Report: no gate consult happened since the previous report —
        /// the autocorrect / dictation / marked-text class.
        static let gateless = Flags(rawValue: 1 << 1)
        /// Report: an arming was parked and `ArmedEdit.describes` refused
        /// it. The routing fell through to `fallbackVerdict`.
        static let armingRejected = Flags(rawValue: 1 << 2)
        /// ★ Report: the OLD span ends past the last consult's upper bound.
        /// **The signature the ladder specified.**
        static let overrun = Flags(rawValue: 1 << 3)
        /// Report: the report begins before the approved range.
        static let startsBefore = Flags(rawValue: 1 << 4)
        /// Report: the net delta is not the approved net change.
        static let netMismatch = Flags(rawValue: 1 << 5)
        /// Report: the OLD span could not be reconstructed safely, so the
        /// overrun predicate was NOT evaluated for it — see `report(…)`.
        /// Bookkeeping, never a finding; deliberately not rendered per
        /// event (it would mark nearly every keystroke), only counted.
        static let overrunNotTestable = Flags(rawValue: 1 << 6)

        /// Any of the three ways a report can fail to describe the consult
        /// that preceded it. A gate-less report is NOT a mismatch — it had
        /// nothing to disagree with.
        static let mismatch: Flags = [.overrun, .startsBefore, .netMismatch]
    }

    struct Event: Sendable {
        enum Kind: UInt8, Sendable {
            case consult
            case report
            /// A storage edit taken under `suppressEditProcessing` — the
            /// programmatic road (structural doors, renders). Recorded so
            /// nothing that reaches storage is invisible.
            case suppressedReport
            case desyncRecovery
        }

        var seq: Int
        var kind: Kind
        /// consult: `range.location` · report: `editedRange.location`
        var location: Int
        /// consult: `range.length` · report: `editedRange.length`
        var length: Int
        /// consult: the replacement's UTF-16 length, or **-1** for an
        /// attribute-only consult (`replacement == nil`) ·
        /// report: `changeInLength`
        var value: Int
        /// report: gate consults since the previous report.
        var consultsBefore: Int
        var flags: Flags
    }

    // MARK: Counters (monotonic — they outlive the ring's wrap)

    struct Summary: Sendable, Equatable {
        var consults = 0
        var reports = 0
        var suppressedReports = 0
        var gatelessReports = 0
        var armingsRejected = 0
        /// ★ Reports whose OLD span overran the last consult — the
        /// specified signature.
        var overruns = 0
        /// Reports the overrun predicate could actually be evaluated on
        /// (pure removals — see `report(…)`'s widening carve-out). The
        /// denominator `overruns` is a count out of; recorded so a zero is
        /// never mistaken for "tested and clean" when it was "not tested".
        var overrunTestable = 0
        /// Reports failing ANY of the three predicates.
        var mismatches = 0
        var desyncRecoveries = 0
        /// The largest number of gate consults seen before a single report.
        /// `> 1` is M1's fingerprint on its own.
        var maxConsultsBeforeAReport = 0
        var eventsDropped = 0
    }

    static var summary: Summary { current.summary }

    // MARK: - Entry points (all pure appends)

    /// `MobileEditorViewModel.shouldChangeText`, first line.
    /// `replacementLength` is -1 for an attribute-only consult.
    static func gate(range: NSRange, replacementLength: Int) {
        let r = current
        guard r.armed else { return }
        r.lastConsultRange = range
        r.lastConsultReplacementLength = replacementLength
        r.consultsSinceReport += 1
        r.summary.consults += 1
        append(
            into: r,
            kind: .consult, location: range.location, length: range.length,
            value: replacementLength, consultsBefore: 0, flags: [])
        log.notice(
            "GATE loc=\(range.location, privacy: .public) len=\(range.length, privacy: .public) repl=\(replacementLength, privacy: .public)")
    }

    /// Called immediately after `pendingEdit = ArmedEdit(...)` — marks the
    /// consult just recorded as having armed a verdict. O(1): it rewrites
    /// the slot it just wrote.
    static func armedVerdict() {
        let r = current
        guard r.armed, !r.ring.isEmpty else { return }
        let last = (r.writeIndex - 1 + r.ring.count) % r.ring.count
        guard r.ring[last].kind == .consult else { return }
        r.ring[last].flags.insert(.armed)
    }

    /// `MobileEditorViewModel.storageDidEdit`, after the binding is
    /// computed. `hadArming` = a verdict was parked; `bound` = it survived
    /// `ArmedEdit.describes`.
    static func report(
        editedRange: NSRange, delta: Int, hadArming: Bool, bound: Bool
    ) {
        let r = current
        guard r.armed else { return }
        let consults = r.consultsSinceReport
        var flags: Flags = []
        if hadArming, !bound { flags.insert(.armingRejected) }
        if consults == 0 {
            flags.insert(.gateless)
        } else {
            // ── OVERRUN — the ladder's named predicate, with the ONE carve
            // out that makes it usable on this platform.
            //
            // It reconstructs the OLD span exactly as `fallbackVerdict`
            // does — `(location, length - delta)` — and that reconstruction
            // is only trustworthy for a PURE REMOVAL. iOS WIDENS the
            // reported `editedRange` of an insertion or a replacement
            // (measured in round 2: a one-character insert at offset 8
            // reported `{8, 9}`; a 5→6 replacement reported length 7) while
            // never touching `delta`. On a widened report the reconstructed
            // old span always overshoots, so the predicate as specified
            // fires on EVERY ordinary keystroke — which would bury the real
            // signal in noise and make the whole experiment worthless.
            //
            // DRIVEN, NOT TRUSTED (§63's lesson): the false-positive rate is
            // pinned at the 100k fixture in `MobilePerfWalkTests`, and both
            // of HER crashes are pure removals — `(12, 0)` Δ−15 — so the
            // carve-out costs the experiment nothing it was built to see.
            // `netMismatch` and `startsBefore` below are immune to widening
            // by measurement (it moves neither `delta` nor `location`) and
            // stay armed on every report.
            if editedRange.length == 0, delta < 0 {
                if editedRange.location - delta > r.lastConsultRange.upperBound {
                    flags.insert(.overrun)
                }
            } else {
                flags.insert(.overrunNotTestable)
            }
            if editedRange.location < r.lastConsultRange.location {
                flags.insert(.startsBefore)
            }
            if r.lastConsultReplacementLength >= 0,
               delta != r.lastConsultReplacementLength - r.lastConsultRange.length {
                flags.insert(.netMismatch)
            }
        }

        r.summary.reports += 1
        if flags.contains(.gateless) { r.summary.gatelessReports += 1 }
        if flags.contains(.armingRejected) { r.summary.armingsRejected += 1 }
        if flags.contains(.overrun) { r.summary.overruns += 1 }
        if flags.contains(.gateless) == false, flags.contains(.overrunNotTestable) == false {
            r.summary.overrunTestable += 1
        }
        if !flags.isDisjoint(with: .mismatch) { r.summary.mismatches += 1 }
        r.summary.maxConsultsBeforeAReport =
            max(r.summary.maxConsultsBeforeAReport, consults)
        r.consultsSinceReport = 0

        append(
            into: r,
            kind: .report, location: editedRange.location,
            length: editedRange.length, value: delta,
            consultsBefore: consults, flags: flags)
        log.notice(
            "EDIT loc=\(editedRange.location, privacy: .public) len=\(editedRange.length, privacy: .public) delta=\(delta, privacy: .public) consults=\(consults, privacy: .public) flags=\(flags.rawValue, privacy: .public)")
    }

    /// A storage edit taken under `suppressEditProcessing` (programmatic).
    static func suppressedReport(editedRange: NSRange, delta: Int) {
        let r = current
        guard r.armed else { return }
        r.summary.suppressedReports += 1
        append(
            into: r,
            kind: .suppressedReport, location: editedRange.location,
            length: editedRange.length, value: delta, consultsBefore: 0,
            flags: [])
    }

    /// `MobileEditorViewModel.desyncRecovery`, first line.
    static func desyncRecovery() {
        let r = current
        guard r.armed else { return }
        r.summary.desyncRecoveries += 1
        append(
            into: r,
            kind: .desyncRecovery, location: 0, length: 0, value: 0,
            consultsBefore: 0, flags: [])
        log.notice("DESYNC RECOVERY")
    }

    // MARK: - The ring's one writer

    private static func append(
        into r: Recorder,
        kind: Event.Kind, location: Int, length: Int, value: Int,
        consultsBefore: Int, flags: Flags
    ) {
        r.sequence += 1
        let event = Event(
            seq: r.sequence, kind: kind, location: location, length: length,
            value: value, consultsBefore: consultsBefore, flags: flags)
        if r.ring.count < ringCapacity {
            // Reserved once, so these appends never reallocate after the
            // first — and after `ringCapacity` there are no appends at all.
            if r.ring.isEmpty { r.ring.reserveCapacity(ringCapacity) }
            r.ring.append(event)
            r.writeIndex = r.ring.count % ringCapacity
        } else {
            r.ring[r.writeIndex] = event
            r.writeIndex = (r.writeIndex + 1) % ringCapacity
            r.summary.eventsDropped += 1
        }
    }

    // MARK: - Reading (never on the keystroke road)

    /// Oldest first.
    static var events: [Event] {
        let r = current
        guard r.ring.count == ringCapacity else { return r.ring }
        return Array(r.ring[r.writeIndex...]) + Array(r.ring[..<r.writeIndex])
    }

    static func clear() {
        let r = current
        r.ring.removeAll(keepingCapacity: true)
        r.writeIndex = 0
        r.sequence = 0
        r.consultsSinceReport = 0
        r.lastConsultRange = NSRange(location: 0, length: 0)
        r.lastConsultReplacementLength = -1
        r.summary = Summary()
    }

    /// The one-screen answer, plus the detail — plain text, so the readout's
    /// Copy button hands her something she can paste straight into a
    /// message.
    static func transcript() -> String {
        var out = "VARIORUM EDIT TRACE (E1)\n"
        out += headline()
        out += "\n--- events (oldest first) ---\n"
        let all = events
        if all.isEmpty {
            out += "(nothing recorded)\n"
        }
        for event in all {
            out += line(for: event) + "\n"
        }
        return out
    }

    static func headline() -> String {
        let s = summary
        var out = ""
        out += "gate calls          \(s.consults)\n"
        out += "storage edits       \(s.reports)\n"
        out += "  gate-less         \(s.gatelessReports)   (autocorrect/dictation — expected)\n"
        out += "  arming rejected   \(s.armingsRejected)\n"
        out += "  most gate calls before one edit: \(s.maxConsultsBeforeAReport)\n"
        out += "\n"
        out += "SUSPECT SIGNATURE   \(s.mismatches)\n"
        out += "  of which overrun  \(s.overruns) of \(s.overrunTestable) testable\n"
        out += "\n"
        out += "desync recoveries   \(s.desyncRecoveries)\n"
        out += "programmatic edits  \(s.suppressedReports)\n"
        if s.eventsDropped > 0 {
            out += "(detail: oldest \(s.eventsDropped) events scrolled off; counts above are complete)\n"
        }
        return out
    }

    static func line(for event: Event) -> String {
        switch event.kind {
        case .consult:
            let repl = event.value < 0 ? "attrs-only" : "repl \(event.value)"
            let armed = event.flags.contains(.armed) ? " → armed" : ""
            return "#\(event.seq) GATE  at \(event.location) len \(event.length)  \(repl)\(armed)"
        case .report:
            var marks: [String] = []
            if event.flags.contains(.overrun) { marks.append("OVERRUN") }
            if event.flags.contains(.startsBefore) { marks.append("starts-before") }
            if event.flags.contains(.netMismatch) { marks.append("net≠") }
            if event.flags.contains(.armingRejected) { marks.append("arming rejected") }
            if event.flags.contains(.gateless) { marks.append("gate-less") }
            let tail = marks.isEmpty ? "" : "  ⚠ " + marks.joined(separator: " · ")
            let delta = event.value >= 0 ? "+\(event.value)" : "\(event.value)"
            return "#\(event.seq) EDIT  at \(event.location) len \(event.length)  Δ\(delta)  after \(event.consultsBefore) gate\(event.consultsBefore == 1 ? "" : "s")\(tail)"
        case .suppressedReport:
            let delta = event.value >= 0 ? "+\(event.value)" : "\(event.value)"
            return "#\(event.seq) prog  at \(event.location) len \(event.length)  Δ\(delta)"
        case .desyncRecovery:
            return "#\(event.seq) ⟳ DESYNC RECOVERY (healed from the store)"
        }
    }
}

// MARK: - The readout

/// E1's readout — the whole point of the instrument being on a PHONE.
///
/// A log only readable over a cable is not sufficient: she may be holding
/// the phone away from the desk. This screen answers the experiment's
/// question in its first six lines, and the event list underneath is the
/// evidence. `os_log` rides in addition (subsystem `io.lduarte.Variorum`,
/// category `edit-trace`) for whoever pulls the device log afterwards.
@MainActor
struct MobileEditTraceView: View {
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss
    /// Re-read on each appearance and on demand — the recorder is a plain
    /// static store, deliberately not `@Observable`, because nothing on the
    /// keystroke road may notify SwiftUI.
    @State private var snapshot: [MobileEditTrace.Event] = []
    @State private var headline = ""
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tokens.path(["Settings", "edit-trace"]))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer()
                Button { dismiss() } label: {
                    Text(tokens.chromeLabel("Done"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(headline)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(tokens.ink)
                        .textSelection(.enabled)

                    Divider().overlay(tokens.line)

                    if snapshot.isEmpty {
                        Text(tokens.chromeLabel(
                            "Nothing recorded yet. Arm the trace, type in a note, then come back."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                    ForEach(snapshot.reversed(), id: \.seq) { event in
                        Text(MobileEditTrace.line(for: event))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(
                                event.flags.isDisjoint(with: MobileEditTrace.Flags.mismatch)
                                    ? tokens.muted : tokens.accent)
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Divider().overlay(tokens.line)
            HStack(spacing: 18) {
                Button {
                    UIPasteboard.general.string = MobileEditTrace.transcript()
                    copied = true
                } label: {
                    Text(tokens.chromeLabel(copied ? "Copied" : "Copy"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Copy the edit trace")
                Button {
                    refresh()
                } label: {
                    Text(tokens.chromeLabel("Refresh"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    MobileEditTrace.clear()
                    copied = false
                    refresh()
                } label: {
                    Text(tokens.chromeLabel("Clear"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear the edit trace")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(tokens.room.ignoresSafeArea())
        .onAppear { refresh() }
    }

    private func refresh() {
        snapshot = MobileEditTrace.events
        headline = MobileEditTrace.headline()
    }
}
