//
//  TimingRecorder.swift
//  VariorumCore
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING LAYER. Her words, the reason it
//  exists: "There's significant lag when going to the quick entry box, when
//  going from the quick entry box into a note." Her ruling (sitting 1,
//  Performance): timing built into the app — markers at the moments she feels
//  and a readout — instead of an Instruments session, so every later fix has
//  numbers before and after. The record is
//  `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 1, §7 its closeout).
//
//  ## What it records — and the one thing it cannot
//
//  Named SERIES of numbers and named COUNTERS, keyed by the app's own catalog
//  (two `String`-backed enums; the phone's lives in `Shared/AppTiming.swift`):
//
//  · **Keyed spans** — `begin` at one moment, `end` at another, possibly in
//    another file (the tap is in the capture box, the keyboard arrives through
//    a notification). One span per series is open at a time:
//      - a second `begin` RESTARTS it (the later act is the one now waited on;
//        `restarts` counts it);
//      - an `end` whose begin is older than the begin's own stale limit is
//        DROPPED, never recorded (`abandoned` counts it) — a begin that never
//        met its end must not pair with an unrelated end much later;
//      - an `end` with nothing open records nothing (`unmatchedEnds`).
//  · **Token spans** — `start` returns a token, `finish(token)` records it.
//    Re-entrant by construction: two overlapping runs each record their own.
//  · **Values** — a number recorded as-is (rows stamped, rows sent).
//  · **Counters** — monotonic totals.
//  · **Counting windows** — events of the named counters between an opening
//    act and a closing act (or a deadline), recorded as ONE sample of a series.
//    That is how "per act" counts are honest: "note reads per open" is the
//    reads between the arrival and its first live delivery, not a ratio of
//    two session totals that other activity pollutes.
//
//  **Durations and counts only.** No entry point takes a string, so no note
//  text, title or id can reach the record, the readout, the persisted copy or
//  a signpost (review focus 1).
//
//  ## The discipline it owes
//
//  · **Inert unless enabled.** Every entry point's first act is one relaxed
//    atomic load; disabled, nothing else runs — no lock, no clock, no
//    signpost. The phone enables its recorder at launch; the Mac never does,
//    so the Mac, which compiles every shared mark, records nothing.
//  · **O(1) per mark** (P1): a lock, a clock read, a dictionary slot and a
//    ring write. A counter also checks the open windows, of which there are at
//    most one per series of a closed catalog. Statistics are computed at READ
//    time only.
//  · **Bounded** (MobileSoul §2): one fixed ring per series; the catalog is
//    closed (enums), so the number of series, pending spans and windows is
//    bounded by construction.
//  · **Thread-safe.** Marks arrive from the main actor and from GRDB's reader
//    queues (a listing's fetch closure counts its own re-runs).
//  · **Instruments sees the same spans**: each span is also an `os_signpost`
//    interval (the caller's signposter — the app's is subsystem
//    `io.lduarte.Variorum`, category `timing`).
//

import Foundation
import os
import Synchronization

// MARK: - The catalog's two key kinds

/// A series' key: a span's durations or a per-act count. `String`-backed so a
/// persisted record can name it; a key a later build no longer has is dropped
/// on restore.
public protocol TimingSeriesKey: Hashable, Sendable, CaseIterable, RawRepresentable
where RawValue == String {
    /// The `os_signpost` interval's name for a span of this series.
    var signpostName: StaticString { get }
}

/// A monotonic counter's key.
public protocol TimingCounterKey: Hashable, Sendable, CaseIterable, RawRepresentable
where RawValue == String {}

// MARK: - The clock

/// A monotonic clock reading, in nanoseconds.
public typealias TimingInstant = UInt64

public enum TimingClock {
    /// `CLOCK_MONOTONIC_RAW`: never steps, and keeps counting while the device
    /// sleeps — so a begin left open across a sleep reads as old (and is
    /// dropped as stale) rather than as fresh.
    @Sendable public static func now() -> TimingInstant {
        clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
    }

    /// A `Duration` in whole nanoseconds (negative clamps to zero).
    public static func nanoseconds(_ duration: Duration) -> UInt64 {
        let (seconds, attoseconds) = duration.components
        guard seconds >= 0 else { return 0 }
        let whole = UInt64(seconds).multipliedReportingOverflow(by: 1_000_000_000)
        guard !whole.overflow else { return .max }
        return whole.partialValue &+ UInt64(max(0, attoseconds) / 1_000_000_000)
    }

    static func milliseconds(from start: TimingInstant, to end: TimingInstant) -> Double {
        end > start ? Double(end - start) / 1_000_000 : 0
    }
}

// MARK: - Tokens and windows

/// A token span's handle. Holds a clock reading and the signpost's state —
/// nothing else.
public struct TimingToken<Series: TimingSeriesKey>: Sendable {
    public let series: Series
    let start: TimingInstant
    let signpost: OSSignpostIntervalState?
}

/// What a second opening of a series' window does while one is open.
public enum TimingWindowPolicy: Sendable {
    /// The open window keeps counting; the second opening is part of the same
    /// act (a leaving's teardown inside the app's own leaving).
    case keepFirst
    /// The open window is recorded as it stands and a fresh one starts (each
    /// save gets the wake-ups that followed IT).
    case restart
}

// MARK: - What a reader sees

public struct TimingSnapshot<Series: TimingSeriesKey, Counter: TimingCounterKey>: Sendable {
    public var series: [Series: TimingStats]
    public var counters: [Counter: Int]
    /// Keyed spans begun again while open.
    public var restarts: Int
    /// Keyed spans whose end came after their stale limit (never recorded).
    public var abandoned: Int
    /// Ends that found no open span.
    public var unmatchedEnds: Int

    public func stats(_ key: Series) -> TimingStats? { series[key] }
    public func counter(_ key: Counter) -> Int { counters[key] ?? 0 }
}

/// The persisted shape (`TimingRecorder.archive` / `restore`): numbers keyed
/// by the catalog's raw names, plus the build they were measured on.
public struct TimingArchive: Codable, Sendable, Equatable {
    public static let currentVersion = 1

    public var version: Int
    /// Whatever the app uses to tell one build from another; a record is only
    /// restored into the build that measured it (the caller's check).
    public var build: String
    public var series: [String: TimingStats]
    public var counters: [String: Int]
    public var restarts: Int
    public var abandoned: Int
    public var unmatchedEnds: Int
}

// MARK: - The recorder

public final class TimingRecorder<Series: TimingSeriesKey, Counter: TimingCounterKey>: Sendable {
    private struct Pending {
        var start: TimingInstant
        var staleAfter: UInt64
        var signpost: OSSignpostIntervalState?
    }

    private struct Window {
        var deadline: TimingInstant
        var counting: Set<Counter>
        var tally: Int
    }

    private struct State {
        var series: [Series: TimingStats] = [:]
        var counters: [Counter: Int] = [:]
        var pending: [Series: Pending] = [:]
        var windows: [Series: Window] = [:]
        var restarts = 0
        var abandoned = 0
        var unmatchedEnds = 0
    }

    public let capacity: Int
    private let enabled: Atomic<Bool>
    private let state = Mutex(State())
    private let clock: @Sendable () -> TimingInstant
    private let signposter: OSSignposter?

    public init(
        capacity: Int = TimingStats.defaultCapacity,
        enabled: Bool = false,
        signposter: OSSignposter? = nil,
        clock: @escaping @Sendable () -> TimingInstant = TimingClock.now
    ) {
        precondition(capacity > 0, "a timing ring needs at least one slot")
        self.capacity = capacity
        self.enabled = Atomic(enabled)
        self.signposter = signposter
        self.clock = clock
    }

    // MARK: Enabling

    public var isEnabled: Bool { enabled.load(ordering: .relaxed) }

    /// Turning it off drops what is open (spans, windows) and keeps what was
    /// recorded.
    public func setEnabled(_ on: Bool) {
        enabled.store(on, ordering: .relaxed)
        guard !on else { return }
        let open = state.withLock { s -> [(Series, OSSignpostIntervalState?)] in
            let open = s.pending.map { ($0.key, $0.value.signpost) }
            s.pending.removeAll()
            s.windows.removeAll()
            return open
        }
        for (key, signpost) in open { endSignpost(key, signpost) }
    }

    // MARK: Keyed spans

    /// Opens `series`' span at now (or at `instant`, a reading of this
    /// recorder's clock taken earlier — the process's start, for a launch).
    /// An open span of the same series RESTARTS. `staleAfter`: an `end` later
    /// than this after the begin is dropped, never recorded.
    public func begin(_ series: Series, at instant: TimingInstant? = nil, staleAfter: Duration) {
        guard isEnabled else { return }
        let now = clock()
        let start = min(instant ?? now, now)
        let signpost = beginSignpost(series)
        let replaced = state.withLock { s -> OSSignpostIntervalState?? in
            let old = s.pending[series]
            if old != nil { s.restarts += 1 }
            s.pending[series] = Pending(
                start: start, staleAfter: TimingClock.nanoseconds(staleAfter), signpost: signpost)
            return old.map { $0.signpost }
        }
        if let replaced { endSignpost(series, replaced) }
    }

    /// Closes `series`' span and records its duration in milliseconds, which
    /// it returns. nil when nothing was open (counted) or the begin had gone
    /// stale (counted, never recorded).
    @discardableResult
    public func end(_ series: Series) -> Double? {
        end(series, countingUnmatched: true)
    }

    /// `end` for a moment that closes a span only when one is waiting — the
    /// keyboard rises for many reasons and ends a tap's span only after a tap;
    /// a first paint ends the Open press's span only after an Open press.
    /// Nothing open is the ordinary case here, so it is not counted.
    @discardableResult
    public func endIfOpen(_ series: Series) -> Double? {
        end(series, countingUnmatched: false)
    }

    private func end(_ series: Series, countingUnmatched: Bool) -> Double? {
        guard isEnabled else { return nil }
        let now = clock()
        let (recorded, signpost) = state.withLock { s -> (Double?, OSSignpostIntervalState??) in
            guard let open = s.pending.removeValue(forKey: series) else {
                if countingUnmatched { s.unmatchedEnds += 1 }
                return (nil, nil)
            }
            let elapsed = now > open.start ? now - open.start : 0
            guard elapsed <= open.staleAfter else {
                s.abandoned += 1
                return (nil, .some(open.signpost))
            }
            let ms = TimingClock.milliseconds(from: open.start, to: now)
            record(ms, into: series, &s)
            return (ms, .some(open.signpost))
        }
        if let signpost { endSignpost(series, signpost) }
        return recorded
    }

    /// Drops `series`' open span without recording (a road that made the wait
    /// meaningless — the lock screen showing on a cold launch).
    public func cancel(_ series: Series) {
        guard isEnabled else { return }
        let signpost = state.withLock { $0.pending.removeValue(forKey: series)?.signpost }
        if let signpost { endSignpost(series, signpost) }
    }

    /// Whether `series` has a span open.
    public func isOpen(_ series: Series) -> Bool {
        guard isEnabled else { return false }
        return state.withLock { $0.pending[series] != nil }
    }

    // MARK: Token spans

    /// Starts a token span (nil while disabled — `finish(nil)` is a no-op, so
    /// a call site needs no branch).
    public func start(_ series: Series) -> TimingToken<Series>? {
        guard isEnabled else { return nil }
        return TimingToken(series: series, start: clock(), signpost: beginSignpost(series))
    }

    /// Records a token span's duration in milliseconds, which it returns.
    @discardableResult
    public func finish(_ token: TimingToken<Series>?) -> Double? {
        guard let token else { return nil }
        endSignpost(token.series, token.signpost)
        guard isEnabled else { return nil }
        let ms = TimingClock.milliseconds(from: token.start, to: clock())
        state.withLock { record(ms, into: token.series, &$0) }
        return ms
    }

    /// Ends a token span WITHOUT recording (a road that did not do the act the
    /// series measures — an empty box that had nothing to file).
    public func discard(_ token: TimingToken<Series>?) {
        guard let token else { return }
        endSignpost(token.series, token.signpost)
    }

    // MARK: Values and counters

    /// Records `value` into `series` as-is (a count of rows, not a duration).
    public func record(_ series: Series, value: Double) {
        guard isEnabled else { return }
        state.withLock { record(value, into: series, &$0) }
    }

    /// Adds `n` to `counter`, and to every open window that counts it.
    public func count(_ counter: Counter, by n: Int = 1) {
        guard isEnabled else { return }
        let now = clock()
        state.withLock { s in
            s.counters[counter, default: 0] += n
            guard !s.windows.isEmpty else { return }
            for key in Array(s.windows.keys) {
                guard var window = s.windows[key] else { continue }
                if now >= window.deadline {
                    closeExpired(key, window, &s)
                } else if window.counting.contains(counter) {
                    window.tally += n
                    s.windows[key] = window
                }
            }
        }
    }

    // MARK: Counting windows

    /// Opens a window that tallies `counting` for `duration` (or until
    /// `closeWindow`), then records the tally as one sample of `series`.
    public func openWindow(
        _ series: Series, counting: Set<Counter>, for duration: Duration,
        policy: TimingWindowPolicy
    ) {
        guard isEnabled else { return }
        let now = clock()
        state.withLock { s in
            if let open = s.windows[series] {
                if now >= open.deadline {
                    closeExpired(series, open, &s)
                } else if policy == .keepFirst {
                    return
                } else {
                    s.windows[series] = nil
                    record(Double(open.tally), into: series, &s)
                }
            }
            s.windows[series] = Window(
                deadline: now &+ TimingClock.nanoseconds(duration), counting: counting, tally: 0)
        }
    }

    /// Records the open window's tally now (a no-op when none is open).
    public func closeWindow(_ series: Series) {
        guard isEnabled else { return }
        state.withLock { s in
            guard let open = s.windows.removeValue(forKey: series) else { return }
            record(Double(open.tally), into: series, &s)
        }
    }

    /// Drops the open window without recording.
    public func cancelWindow(_ series: Series) {
        guard isEnabled else { return }
        state.withLock { s in s.windows[series] = nil }
    }

    // MARK: Reading

    /// Everything recorded, with any window past its deadline recorded first.
    /// Readable while disabled (the record outlives the switch).
    public func snapshot() -> TimingSnapshot<Series, Counter> {
        let now = clock()
        return state.withLock { s in
            for (key, window) in s.windows where now >= window.deadline {
                closeExpired(key, window, &s)
            }
            return TimingSnapshot(
                series: s.series, counters: s.counters, restarts: s.restarts,
                abandoned: s.abandoned, unmatchedEnds: s.unmatchedEnds)
        }
    }

    /// Back to nothing recorded. Open spans and windows are dropped too.
    public func reset() {
        let open = state.withLock { s -> [(Series, OSSignpostIntervalState?)] in
            let open = s.pending.map { ($0.key, $0.value.signpost) }
            s = State()
            return open
        }
        for (key, signpost) in open { endSignpost(key, signpost) }
    }

    /// The record as numbers keyed by the catalog's raw names.
    public func archive(build: String) -> TimingArchive {
        let snap = snapshot()
        return TimingArchive(
            version: TimingArchive.currentVersion, build: build,
            series: Dictionary(uniqueKeysWithValues: snap.series.map { ($0.key.rawValue, $0.value) }),
            counters: Dictionary(uniqueKeysWithValues: snap.counters.map { ($0.key.rawValue, $0.value) }),
            restarts: snap.restarts, abandoned: snap.abandoned, unmatchedEnds: snap.unmatchedEnds)
    }

    /// Replaces the record with `archive`'s numbers. Names this catalog no
    /// longer has are dropped; a series is re-ringed to this recorder's
    /// capacity (its newest samples kept). Open spans and windows are dropped.
    /// Returns false (and changes nothing) for an archive of another version.
    @discardableResult
    public func restore(_ archive: TimingArchive) -> Bool {
        guard archive.version == TimingArchive.currentVersion else { return false }
        var fresh = State()
        for (name, stats) in archive.series {
            guard let key = Series(rawValue: name) else { continue }
            var ringed = TimingStats(capacity: capacity)
            for value in stats.retained { ringed.record(value) }
            ringed.adoptCount(max(stats.count, ringed.count), last: stats.last)
            fresh.series[key] = ringed
        }
        for (name, value) in archive.counters {
            guard let key = Counter(rawValue: name) else { continue }
            fresh.counters[key] = max(0, value)
        }
        fresh.restarts = max(0, archive.restarts)
        fresh.abandoned = max(0, archive.abandoned)
        fresh.unmatchedEnds = max(0, archive.unmatchedEnds)
        let open = state.withLock { s -> [(Series, OSSignpostIntervalState?)] in
            let open = s.pending.map { ($0.key, $0.value.signpost) }
            s = fresh
            return open
        }
        for (key, signpost) in open { endSignpost(key, signpost) }
        return true
    }

    // MARK: - Private

    private func record(_ value: Double, into series: Series, _ s: inout State) {
        s.series[series, default: TimingStats(capacity: capacity)].record(value)
    }

    private func closeExpired(_ series: Series, _ window: Window, _ s: inout State) {
        s.windows[series] = nil
        record(Double(window.tally), into: series, &s)
    }

    private func beginSignpost(_ series: Series) -> OSSignpostIntervalState? {
        guard let signposter, signposter.isEnabled else { return nil }
        return signposter.beginInterval(series.signpostName, id: signposter.makeSignpostID())
    }

    private func endSignpost(_ series: Series, _ signpost: OSSignpostIntervalState?) {
        guard let signposter, let signpost else { return }
        signposter.endInterval(series.signpostName, signpost)
    }
}
