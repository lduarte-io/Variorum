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
//  · **Saving is the app's, and never on a timed path.** The recorder never
//    writes anything anywhere; it tells a change handler about the FIRST
//    change after the record was last taken for saving (one atomic exchange
//    per mark), so the app can batch a save for later, off the main thread. A
//    persisted record comes back by `absorb`, which folds it UNDER what the
//    new process has already measured — so a launch never waits on a file.
//    One table per build is `TimingBook`'s.
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
    /// When the first sample or count of this record landed (nil — nothing
    /// yet). The readout says "since" its day.
    public var since: Date?

    public func stats(_ key: Series) -> TimingStats? { series[key] }
    public func counter(_ key: Counter) -> Int { counters[key] ?? 0 }
}

/// The persisted shape of one build's record (`TimingRecorder.archive`,
/// `restore`, `absorb`; `TimingBook` keeps one per build): numbers keyed by the
/// catalog's raw names, the build they were measured on, and the day the
/// record began.
public struct TimingArchive: Codable, Sendable, Equatable {
    public static let currentVersion = 1

    public var version: Int
    /// The key that tells one build from another (the caller's — the phone's
    /// is its version, build number and executable fingerprint).
    public var build: String
    /// How the readout names the build (display only).
    public var label: String?
    /// When the record's first sample or count landed.
    public var since: Date?
    public var series: [String: TimingStats]
    public var counters: [String: Int]
    public var restarts: Int
    public var abandoned: Int
    public var unmatchedEnds: Int

    /// An empty record for `build`.
    public init(build: String, label: String? = nil) {
        self.version = TimingArchive.currentVersion
        self.build = build
        self.label = label
        self.since = nil
        self.series = [:]
        self.counters = [:]
        self.restarts = 0
        self.abandoned = 0
        self.unmatchedEnds = 0
    }
}

// MARK: - The recorder

/// **The largest count a persisted record may bring into a sum** (`merged`) —
/// 10¹⁵, the readout's own `TimingReport.drawnBound` as an `Int`: a count past
/// it can come only from a damaged file, and below it every later mark's
/// checked `+=` stays far inside `Int` (VM-64 ladder round 3, finding 5(b)).
/// File scope because a generic type cannot hold a static stored property.
private let archivedCountBound = Int(TimingReport.drawnBound)

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
        var since: Date?
    }

    public let capacity: Int
    private let enabled: Atomic<Bool>
    private let state = Mutex(State())
    private let clock: @Sendable () -> TimingInstant
    private let date: @Sendable () -> Date
    private let signposter: OSSignposter?
    /// Set by the first change after a save (`archive(…, markingSaved: true)`),
    /// so the change handler hears about a dirty record ONCE per save, not per
    /// mark — saving is the app's to batch, off the paths being timed.
    private let dirty = Atomic<Bool>(false)
    private let changeHandler = Mutex<(@Sendable () -> Void)?>(nil)

    public init(
        capacity: Int = TimingStats.defaultCapacity,
        enabled: Bool = false,
        signposter: OSSignposter? = nil,
        clock: @escaping @Sendable () -> TimingInstant = TimingClock.now,
        date: @escaping @Sendable () -> Date = { Date() }
    ) {
        precondition(capacity > 0, "a timing ring needs at least one slot")
        self.capacity = capacity
        self.enabled = Atomic(enabled)
        self.signposter = signposter
        self.clock = clock
        self.date = date
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

    // MARK: Saving (the app's, batched — never on a timed path)

    /// `handler` is called — on whatever thread made the change — at the first
    /// change after the record was last taken for saving, and not again until
    /// it is taken again. O(1): one atomic exchange per change.
    public func setChangeHandler(_ handler: (@Sendable () -> Void)?) {
        changeHandler.withLock { $0 = handler }
    }

    /// Whether something changed since the record was last taken for saving.
    public var hasUnsavedChanges: Bool { dirty.load(ordering: .relaxed) }

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
        // `kept`: whether the record that is SAVED moved — a sample, or one of
        // the footer's counts. An `endIfOpen` that found nothing open moves
        // neither (the open spans are never saved), so it tells the change
        // handler nothing — the windows' own rule (`openWindow`, `closeWindow`).
        let (recorded, signpost, kept) = state.withLock { s -> (Double?, OSSignpostIntervalState??, Bool) in
            guard let open = s.pending.removeValue(forKey: series) else {
                if countingUnmatched { s.unmatchedEnds += 1 }
                return (nil, nil, countingUnmatched)
            }
            let elapsed = now > open.start ? now - open.start : 0
            guard elapsed <= open.staleAfter else {
                s.abandoned += 1
                return (nil, .some(open.signpost), true)
            }
            let ms = TimingClock.milliseconds(from: open.start, to: now)
            record(ms, into: series, &s)
            return (ms, .some(open.signpost), true)
        }
        if let signpost { endSignpost(series, signpost) }
        if kept { changed() }
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
        changed()
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
        changed()
    }

    /// Adds `n` to `counter`, and to every open window that counts it.
    public func count(_ counter: Counter, by n: Int = 1) {
        guard isEnabled else { return }
        let now = clock()
        state.withLock { s in
            s.counters[counter, default: 0] += n
            noteFirst(&s)
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
        changed()
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
        let recorded = state.withLock { s -> Bool in
            var recorded = false
            if let open = s.windows[series] {
                if now >= open.deadline {
                    closeExpired(series, open, &s)
                    recorded = true
                } else if policy == .keepFirst {
                    return false
                } else {
                    s.windows[series] = nil
                    record(Double(open.tally), into: series, &s)
                    recorded = true
                }
            }
            s.windows[series] = Window(
                deadline: now &+ TimingClock.nanoseconds(duration), counting: counting, tally: 0)
            return recorded
        }
        if recorded { changed() }
    }

    /// Records the open window's tally now (a no-op when none is open).
    public func closeWindow(_ series: Series) {
        guard isEnabled else { return }
        let recorded = state.withLock { s -> Bool in
            guard let open = s.windows.removeValue(forKey: series) else { return false }
            record(Double(open.tally), into: series, &s)
            return true
        }
        if recorded { changed() }
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
        let (snap, recorded) = state.withLock { s -> (TimingSnapshot<Series, Counter>, Bool) in
            var recorded = false
            for (key, window) in s.windows where now >= window.deadline {
                closeExpired(key, window, &s)
                recorded = true
            }
            return (TimingSnapshot(
                series: s.series, counters: s.counters, restarts: s.restarts,
                abandoned: s.abandoned, unmatchedEnds: s.unmatchedEnds, since: s.since), recorded)
        }
        if recorded { changed() }
        return snap
    }

    /// Back to nothing recorded. Open spans and windows are dropped too.
    public func reset() {
        let open = state.withLock { s -> [(Series, OSSignpostIntervalState?)] in
            let open = s.pending.map { ($0.key, $0.value.signpost) }
            s = State()
            return open
        }
        for (key, signpost) in open { endSignpost(key, signpost) }
        changed()
    }

    /// The record as numbers keyed by the catalog's raw names. `markingSaved`:
    /// the caller is about to save it, so the next change is news again (the
    /// mark happens BEFORE the read, so a change racing the save is never
    /// lost — at worst it is saved twice).
    public func archive(build: String, label: String? = nil, markingSaved: Bool = false) -> TimingArchive {
        if markingSaved { dirty.store(false, ordering: .relaxed) }
        let snap = snapshot()
        var archive = TimingArchive(build: build, label: label)
        archive.since = snap.since
        archive.series = Dictionary(uniqueKeysWithValues: snap.series.map { ($0.key.rawValue, $0.value) })
        archive.counters = Dictionary(uniqueKeysWithValues: snap.counters.map { ($0.key.rawValue, $0.value) })
        archive.restarts = snap.restarts
        archive.abandoned = snap.abandoned
        archive.unmatchedEnds = snap.unmatchedEnds
        return archive
    }

    /// Replaces the record with `archive`'s numbers. Names this catalog no
    /// longer has are dropped; a series is re-ringed to this recorder's
    /// capacity (its newest samples kept). Open spans and windows are dropped.
    /// Returns false (and changes nothing) for an archive of another version.
    @discardableResult
    public func restore(_ archive: TimingArchive) -> Bool {
        guard archive.version == TimingArchive.currentVersion else { return false }
        let fresh = merged(archive, into: State())
        let open = state.withLock { s -> [(Series, OSSignpostIntervalState?)] in
            let open = s.pending.map { ($0.key, $0.value.signpost) }
            s = fresh
            return open
        }
        for (key, signpost) in open { endSignpost(key, signpost) }
        return true
    }

    /// Folds a persisted record UNDER what is already recorded: per series the
    /// archived samples come first and the live ones after them (the ring
    /// keeps the newest), counts add up, and the record's first day is the
    /// earlier one. Open spans and windows stay open. This is what lets a
    /// launch start measuring at once and read its file afterwards, off the
    /// path it is timing. False (nothing changed) for another version.
    @discardableResult
    public func absorb(_ archive: TimingArchive) -> Bool {
        guard archive.version == TimingArchive.currentVersion else { return false }
        state.withLock { s in s = merged(archive, into: s) }
        return true
    }

    // MARK: - Private

    /// `archive` folded under `live` (see `absorb`); `restore` folds it under
    /// an empty state.
    ///
    /// **Every decoded count is held to `0…archivedCountBound` before it is
    /// added** (VM-64 ladder round 3, finding 5(b)): the sums are checked
    /// arithmetic, so a damaged file's count near `Int.max` trapped this fold —
    /// the launch's `absorb`, before the file could ever be rewritten. A BOUND,
    /// not saturation: a sum saturated at `Int.max` would trap at the next
    /// mark's `+= 1` instead; held far below it, every later mark still counts.
    private func merged(_ archive: TimingArchive, into live: State) -> State {
        func bounded(_ decoded: Int) -> Int { min(max(0, decoded), archivedCountBound) }
        var s = live
        for (name, stats) in archive.series {
            guard let key = Series(rawValue: name) else { continue }
            let current = s.series[key]
            var ringed = TimingStats(capacity: capacity)
            for value in stats.retained { ringed.record(value) }
            if let current { for value in current.retained { ringed.record(value) } }
            ringed.adoptCount(bounded(stats.count) + (current?.count ?? 0), last: current?.last ?? stats.last)
            s.series[key] = ringed
        }
        for (name, value) in archive.counters {
            guard let key = Counter(rawValue: name) else { continue }
            s.counters[key, default: 0] += bounded(value)
        }
        s.restarts += bounded(archive.restarts)
        s.abandoned += bounded(archive.abandoned)
        s.unmatchedEnds += bounded(archive.unmatchedEnds)
        switch (archive.since, s.since) {
        case let (old?, new?): s.since = min(old, new)
        case let (old?, nil): s.since = old
        default: break
        }
        return s
    }

    private func record(_ value: Double, into series: Series, _ s: inout State) {
        s.series[series, default: TimingStats(capacity: capacity)].record(value)
        noteFirst(&s)
    }

    /// The record's first day: stamped by its first sample or count.
    private func noteFirst(_ s: inout State) {
        if s.since == nil { s.since = date() }
    }

    private func closeExpired(_ series: Series, _ window: Window, _ s: inout State) {
        s.windows[series] = nil
        record(Double(window.tally), into: series, &s)
    }

    /// The first change after a save tells the handler; later ones do not.
    private func changed() {
        guard !dirty.exchange(true, ordering: .relaxed) else { return }
        changeHandler.withLock { $0 }?()
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
