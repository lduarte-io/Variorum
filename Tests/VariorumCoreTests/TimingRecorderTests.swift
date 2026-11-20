import Foundation
import Synchronization
import Testing
@testable import VariorumCore

/// VM-65 (the VM-64 run, batch 1) — THE TIMING LAYER'S BRAIN, headless. The
/// record is `notes/plans/fixes/vm-64-timing-and-lags.md` §4 batch 1 ("brain
/// tests headless: statistics, the ring's bound, an unmatched begin, a
/// re-entrant span"). NEW-MECHANISM tests, green by design: the layer did not
/// exist before this batch, so no red-on-old is owed; every rule is pinned by
/// a positive arm beside its refusal arm.
///
/// A hand-driven clock makes every duration exact.
@Suite("The timing layer's brain (VM-65)")
struct TimingRecorderTests {
    enum Series: String, TimingSeriesKey {
        case tapToKeyboard, openToNote, filing, readsPerOpen, rows
        var signpostName: StaticString {
            switch self {
            case .tapToKeyboard: return "tapToKeyboard"
            case .openToNote: return "openToNote"
            case .filing: return "filing"
            case .readsPerOpen: return "readsPerOpen"
            case .rows: return "rows"
            }
        }
    }

    enum Counter: String, TimingCounterKey {
        case read, build, save
    }

    /// A clock the test moves by hand (nanoseconds).
    final class HandClock: Sendable {
        private let now = Mutex<UInt64>(1_000_000_000)
        func read() -> UInt64 { now.withLock { $0 } }
        func advance(ms: Double) { now.withLock { $0 += UInt64(ms * 1_000_000) } }
    }

    private func recorder(
        capacity: Int = TimingStats.defaultCapacity, clock: HandClock
    ) -> TimingRecorder<Series, Counter> {
        TimingRecorder(capacity: capacity, enabled: true, clock: { clock.read() })
    }

    // MARK: - Statistics

    @Test func theStatisticsAreCountMedianRangeAndLast() {
        var stats = TimingStats(capacity: 8)
        #expect(stats.median == nil && stats.minimum == nil && stats.maximum == nil && stats.last == nil)
        for value in [30.0, 10, 20] { stats.record(value) }
        #expect(stats.count == 3)
        #expect(stats.median == 20)          // odd: the middle one
        #expect(stats.minimum == 10)
        #expect(stats.maximum == 30)
        #expect(stats.last == 20)
        stats.record(40)
        #expect(stats.median == 25)          // even: the mean of the middle two
        #expect(stats.retained == [30, 10, 20, 40])  // oldest first
    }

    /// THE RING'S BOUND: past its capacity the ring holds exactly `capacity`
    /// samples — the newest — while the all-time count and the last keep
    /// counting; the median and range are over what it holds.
    @Test func theRingHoldsItsCapacityAndTheCountOutlivesTheWrap() {
        var stats = TimingStats(capacity: 4)
        for value in 1...1_000 { stats.record(Double(value)) }
        #expect(stats.count == 1_000)
        #expect(stats.retainedCount == 4)
        #expect(stats.retained == [997, 998, 999, 1_000])
        #expect(stats.median == 998.5)
        #expect(stats.minimum == 997 && stats.maximum == 1_000)
        #expect(stats.last == 1_000)
    }

    @Test func aRecordersRingsAreBoundedToo() throws {
        let clock = HandClock()
        let timing = recorder(capacity: 5, clock: clock)
        for _ in 0..<500 { timing.record(.rows, value: 1) }
        let stats = try #require(timing.snapshot().stats(.rows))
        #expect(stats.count == 500)
        #expect(stats.retainedCount == 5)
    }

    // MARK: - Keyed spans

    @Test func aKeyedSpanRecordsTheTimeBetweenItsBeginAndItsEnd() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.begin(.tapToKeyboard, staleAfter: .seconds(30))
        #expect(timing.isOpen(.tapToKeyboard))
        clock.advance(ms: 312)
        #expect(timing.end(.tapToKeyboard) == 312)
        #expect(!timing.isOpen(.tapToKeyboard))
        #expect(timing.snapshot().stats(.tapToKeyboard)?.last == 312)
    }

    /// AN UNMATCHED BEGIN records nothing, ever — and an end long after it has
    /// gone stale is dropped (counted), never paired with it.
    @Test func anUnmatchedBeginRecordsNothingAndGoesStale() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.begin(.tapToKeyboard, staleAfter: .seconds(10))
        clock.advance(ms: 60_000)
        #expect(timing.snapshot().stats(.tapToKeyboard) == nil)   // never ended: nothing
        #expect(timing.end(.tapToKeyboard) == nil)                // stale: dropped
        let snap = timing.snapshot()
        #expect(snap.stats(.tapToKeyboard) == nil)
        #expect(snap.abandoned == 1)
        // …and the stale begin is gone: the next pair is a clean one.
        timing.begin(.tapToKeyboard, staleAfter: .seconds(10))
        clock.advance(ms: 250)
        #expect(timing.end(.tapToKeyboard) == 250)
    }

    @Test func anEndWithNothingOpenIsCountedAndRecordsNothing() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        #expect(timing.end(.openToNote) == nil)
        let snap = timing.snapshot()
        #expect(snap.unmatchedEnds == 1)
        #expect(snap.stats(.openToNote) == nil)
    }

    /// A RE-ENTRANT KEYED SPAN: a second begin while one is open RESTARTS it —
    /// the later act is the one now waited on — and one end records ONE sample.
    @Test func aSecondBeginRestartsTheKeyedSpan() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.begin(.openToNote, staleAfter: .seconds(30))
        clock.advance(ms: 100)
        timing.begin(.openToNote, staleAfter: .seconds(30))
        clock.advance(ms: 40)
        #expect(timing.end(.openToNote) == 40)
        let snap = timing.snapshot()
        #expect(snap.stats(.openToNote)?.count == 1)
        #expect(snap.restarts == 1)
        #expect(timing.end(.openToNote) == nil)                   // nothing left open
    }

    @Test func aBeginAtAnEarlierInstantMeasuresFromThere() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        let processStart = clock.read()
        clock.advance(ms: 180)
        timing.begin(.openToNote, at: processStart, staleAfter: .seconds(60))
        clock.advance(ms: 20)
        #expect(timing.end(.openToNote) == 200)
        // An instant in the future is clamped to now (never a negative span).
        timing.begin(.openToNote, at: clock.read() + 5_000_000_000, staleAfter: .seconds(60))
        clock.advance(ms: 7)
        #expect(timing.end(.openToNote) == 7)
    }

    /// `endIfOpen`: a moment that only sometimes closes a span (the keyboard
    /// rising) records when a span waits, and is silent — not an unmatched
    /// end — when none does. A stale begin is still dropped.
    @Test func endIfOpenRecordsAWaitingSpanAndIsSilentOtherwise() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        #expect(timing.endIfOpen(.tapToKeyboard) == nil)
        #expect(timing.snapshot().unmatchedEnds == 0)
        timing.begin(.tapToKeyboard, staleAfter: .seconds(30))
        clock.advance(ms: 280)
        #expect(timing.endIfOpen(.tapToKeyboard) == 280)
        timing.begin(.tapToKeyboard, staleAfter: .seconds(1))
        clock.advance(ms: 5_000)
        #expect(timing.endIfOpen(.tapToKeyboard) == nil)
        let snap = timing.snapshot()
        #expect(snap.abandoned == 1 && snap.unmatchedEnds == 0)
        #expect(snap.stats(.tapToKeyboard)?.retained == [280])
    }

    @Test func aCancelledSpanRecordsNothing() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.begin(.openToNote, staleAfter: .seconds(30))
        timing.cancel(.openToNote)
        clock.advance(ms: 5)
        #expect(timing.end(.openToNote) == nil)
        #expect(timing.snapshot().unmatchedEnds == 1)
    }

    // MARK: - Token spans

    /// A RE-ENTRANT TOKEN SPAN: two overlapping runs of one series each record
    /// their own duration.
    @Test func overlappingTokenSpansEachRecordTheirOwn() throws {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        let outer = timing.start(.filing)
        clock.advance(ms: 10)
        let inner = timing.start(.filing)
        clock.advance(ms: 5)
        #expect(timing.finish(inner) == 5)
        clock.advance(ms: 1)
        #expect(timing.finish(outer) == 16)
        let stats = try #require(timing.snapshot().stats(.filing))
        #expect(stats.count == 2)
        #expect(stats.retained == [5, 16])
    }

    @Test func aDiscardedTokenRecordsNothing() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        let token = timing.start(.filing)
        clock.advance(ms: 9)
        timing.discard(token)
        #expect(timing.snapshot().stats(.filing) == nil)
    }

    // MARK: - Counting windows

    /// A window tallies ONLY its named counters, between its opening and its
    /// closing act, as one sample.
    @Test func aWindowTalliesItsCountersAsOneSample() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.count(.read)                                       // before: not in it
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(10), policy: .keepFirst)
        timing.count(.read)
        timing.count(.build)                                      // not counted by it
        timing.count(.read, by: 2)
        timing.closeWindow(.readsPerOpen)
        timing.count(.read)                                       // after: not in it
        let snap = timing.snapshot()
        #expect(snap.stats(.readsPerOpen)?.retained == [3])
        #expect(snap.counter(.read) == 5)                         // the totals see everything
        #expect(snap.counter(.build) == 1)
    }

    @Test func aWindowPastItsDeadlineRecordsWhatItHadAndStopsCounting() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .keepFirst)
        timing.count(.read)
        clock.advance(ms: 1_500)
        timing.count(.read)                                       // after the deadline
        #expect(timing.snapshot().stats(.readsPerOpen)?.retained == [1])
        // A window that expires with nothing after it is recorded at the next read.
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .keepFirst)
        timing.count(.read, by: 2)
        clock.advance(ms: 2_000)
        #expect(timing.snapshot().stats(.readsPerOpen)?.retained == [1, 2])
    }

    @Test func keepFirstFoldsASecondOpeningIntoTheOpenWindow() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.openWindow(.readsPerOpen, counting: [.save], for: .seconds(10), policy: .keepFirst)
        timing.count(.save)
        timing.openWindow(.readsPerOpen, counting: [.save], for: .seconds(10), policy: .keepFirst)
        timing.count(.save)
        timing.closeWindow(.readsPerOpen)
        #expect(timing.snapshot().stats(.readsPerOpen)?.retained == [2])
    }

    @Test func restartRecordsTheOpenWindowAndStartsAFreshOne() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .restart)
        timing.count(.read)
        timing.count(.read)
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .restart)
        timing.count(.read)
        timing.closeWindow(.readsPerOpen)
        #expect(timing.snapshot().stats(.readsPerOpen)?.retained == [2, 1])
    }

    @Test func aCancelledWindowRecordsNothing() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .keepFirst)
        timing.count(.read)
        timing.cancelWindow(.readsPerOpen)
        clock.advance(ms: 5_000)
        #expect(timing.snapshot().stats(.readsPerOpen) == nil)
    }

    // MARK: - Enabling

    /// INERT UNLESS ENABLED: nothing records, nothing opens, and turning it off
    /// drops what is open while keeping what was recorded.
    @Test func aDisabledRecorderRecordsNothing() {
        let clock = HandClock()
        let timing = TimingRecorder<Series, Counter>(clock: { clock.read() })
        #expect(!timing.isEnabled)
        timing.begin(.openToNote, staleAfter: .seconds(30))
        clock.advance(ms: 10)
        #expect(timing.end(.openToNote) == nil)
        #expect(timing.start(.filing) == nil)
        timing.record(.rows, value: 3)
        timing.count(.read)
        timing.openWindow(.readsPerOpen, counting: [.read], for: .seconds(1), policy: .keepFirst)
        let snap = timing.snapshot()
        #expect(snap.series.isEmpty && snap.counters.isEmpty)
        #expect(snap.unmatchedEnds == 0)

        timing.setEnabled(true)
        timing.record(.rows, value: 3)
        timing.begin(.openToNote, staleAfter: .seconds(30))
        timing.setEnabled(false)
        timing.setEnabled(true)
        #expect(!timing.isOpen(.openToNote))                     // the open span went
        #expect(timing.snapshot().stats(.rows)?.last == 3)       // the record stayed
    }

    @Test func resetForgetsEverything() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.record(.rows, value: 3)
        timing.count(.read)
        _ = timing.end(.openToNote)
        timing.reset()
        let snap = timing.snapshot()
        #expect(snap.series.isEmpty && snap.counters.isEmpty && snap.unmatchedEnds == 0)
    }

    // MARK: - Persistence

    /// The archive round-trips through JSON with every number intact, names a
    /// later catalog no longer has are dropped, and another version is refused.
    @Test func theArchiveRoundTripsAndDropsUnknownNames() throws {
        let clock = HandClock()
        let timing = recorder(capacity: 4, clock: clock)
        for value in 1...6 { timing.record(.rows, value: Double(value)) }
        timing.begin(.openToNote, staleAfter: .seconds(30))
        clock.advance(ms: 33)
        timing.end(.openToNote)
        timing.count(.save, by: 7)
        _ = timing.end(.filing)

        var archive = timing.archive(build: "build-A")
        archive.series["aSeriesALaterBuildRemoved"] = TimingStats()
        archive.counters["aCounterALaterBuildRemoved"] = 9
        let data = try JSONEncoder().encode(archive)
        let decoded = try JSONDecoder().decode(TimingArchive.self, from: data)
        #expect(decoded == archive)

        let fresh = recorder(capacity: 4, clock: clock)
        #expect(fresh.restore(decoded))
        let snap = fresh.snapshot()
        let rows = try #require(snap.stats(.rows))
        #expect(rows.count == 6 && rows.retained == [3, 4, 5, 6] && rows.last == 6)
        #expect(snap.stats(.openToNote)?.retained == [33])
        #expect(snap.counter(.save) == 7)
        #expect(snap.unmatchedEnds == 1)
        #expect(snap.series.count == 2)

        var other = decoded
        other.version = TimingArchive.currentVersion + 1
        #expect(!fresh.restore(other))
        #expect(fresh.snapshot().counter(.save) == 7)            // unchanged
    }

    /// The persisted JSON is numbers and the catalog's own names — nothing
    /// else can reach it (the API has no string parameter).
    @Test func thePersistedShapeIsNumbersAndCatalogNames() throws {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        timing.record(.rows, value: 2)
        timing.count(.read)
        let json = try #require(String(
            data: JSONEncoder().encode(timing.archive(build: "b")), encoding: .utf8))
        for key in ["\"rows\"", "\"read\"", "\"samples\"", "\"capacity\""] {
            #expect(json.contains(key))
        }
    }

    @Test func aDecodedSeriesIsHeldToTheRingsInvariants() throws {
        let json = #"{"capacity":3,"count":1,"samples":[1,2,3,4,5]}"#
        let stats = try JSONDecoder().decode(TimingStats.self, from: Data(json.utf8))
        #expect(stats.retained == [3, 4, 5])
        #expect(stats.count == 3)                                 // never below what it holds
        #expect(stats.last == 5)
    }

    // MARK: - A damaged record (VM-64 ladder round 3, finding 5(b))
    //
    // The timing file is read at every launch (`absorb`, on its own queue) and
    // a build's table is drawn by the readout as decoded, so a damaged
    // `timing.json` must be held to the ring's bound by the decode and must not
    // trap the report. BUG pins: red on the code before the round-3 fix.

    /// **A decoded capacity is held to the ring's own bound** — the newest
    /// `defaultCapacity` samples kept, the all-time count kept. Read in-process:
    /// neither size traps the old code (a probe showed `reserveCapacity(Int.max)`
    /// is a silent no-op), so its wrong answer is read here.
    /// RED ON OLD: the capacity was taken as written (100,000; `Int.max`), so
    /// every sample the file held was kept, and the first sample reserved that
    /// many slots up front (8 TB of address space at 2⁴⁰ in the same probe).
    @Test func aDecodedCapacityIsHeldToTheRingsBound() throws {
        let samples = (0..<70).map { String($0) }.joined(separator: ",")
        let json = #"{"capacity":100000,"count":70,"samples":["# + samples + "]}"
        let stats = try JSONDecoder().decode(TimingStats.self, from: Data(json.utf8))
        #expect(stats.capacity == TimingStats.defaultCapacity)
        #expect(stats.retained == (6..<70).map(Double.init), "the newest 64 kept, oldest first")
        #expect(stats.count == 70)
        #expect(stats.last == 69)

        let huge = #"{"capacity":9223372036854775807,"count":1,"samples":[5]}"#
        let damaged = try JSONDecoder().decode(TimingStats.self, from: Data(huge.utf8))
        #expect(damaged.capacity == TimingStats.defaultCapacity)
        #expect(damaged.retained == [5])
    }

    /// **A value outside `Int`'s range is reported without trapping.** A trap
    /// cannot be caught in-process, so the body runs in a child process (Swift
    /// Testing's exit test) and is expected to exit cleanly; on the old code
    /// the child dies and the parent records one issue — the suite survives.
    /// RED ON OLD: `TimingReport.number` converted with `Int(_:)` on both of its
    /// roads, which traps past `Int`'s range (and on a non-finite value) —
    /// observed `.signal(SIGTRAP)`.
    @Test func aSampleOutsideIntsRangeIsReportedWithoutTrapping() async {
        await #expect(processExitsWith: .success) {
            let json = #"{"capacity":4,"count":3,"samples":[1e300,-1e300,5]}"#
            let stats = try JSONDecoder().decode(TimingStats.self, from: Data(json.utf8))
            _ = TimingReport.summary(stats, unit: .milliseconds)
            _ = TimingReport.summary(stats, unit: .count)
            for value in [Double.infinity, -.infinity, .nan, 1e19, -1e19] {
                _ = TimingReport.number(value, .milliseconds)
                _ = TimingReport.number(value, .count)
            }
        }
    }

    /// **…and what it draws is bounded** (on the fixed code only — the old code
    /// traps here, which is the pin above): a value past ±10¹⁵ is drawn at the
    /// bound, a NaN (∞'s median) as 0, and an ordinary value as before.
    @Test func aValueOutsideTheDrawnBoundIsDrawnAtTheBound() async {
        await #expect(processExitsWith: .success) {
            precondition(TimingReport.number(1e300, .milliseconds) == "1000000000000000")
            precondition(TimingReport.number(-1e300, .milliseconds) == "-1000000000000000.0")
            precondition(TimingReport.number(.infinity, .count) == "1000000000000000")
            precondition(TimingReport.number(.nan, .count) == "0")
            precondition(TimingReport.number(312.4, .milliseconds) == "312")
        }
    }

    // MARK: - The author's sharpening: per-build tables that survive a quit

    /// A wall clock the test sets by hand.
    final class HandDate: Sendable {
        private let now = Mutex(Date(timeIntervalSince1970: 1_763_510_400))  // a fixed day
        func read() -> Date { now.withLock { $0 } }
        func advance(days: Double) { now.withLock { $0 += days * 86_400 } }
    }

    /// THE RECORD'S FIRST DAY: stamped by its first sample or count (never by
    /// a begin), carried by the archive, and cleared by a reset.
    @Test func theRecordKnowsTheDayOfItsFirstSample() {
        let clock = HandClock()
        let day = HandDate()
        let timing = TimingRecorder<Series, Counter>(
            enabled: true, clock: { clock.read() }, date: { day.read() })
        timing.begin(.openToNote, staleAfter: .seconds(30))
        #expect(timing.snapshot().since == nil)                   // a begin is not a sample
        let first = day.read()
        timing.count(.read)
        day.advance(days: 3)
        timing.record(.rows, value: 1)
        #expect(timing.snapshot().since == first)                 // the FIRST, not the latest
        #expect(timing.archive(build: "b").since == first)
        timing.reset()
        #expect(timing.snapshot().since == nil)
        timing.record(.rows, value: 1)
        #expect(timing.snapshot().since == day.read())
    }

    /// SAVES ARE BATCHED: the change handler hears the FIRST change after the
    /// record was taken for saving, once — not once per mark — and a save
    /// re-arms it. A change racing the save is never lost.
    @Test func theChangeHandlerHearsTheFirstChangeAfterEachSave() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        let calls = Mutex(0)
        timing.setChangeHandler { calls.withLock { $0 += 1 } }
        timing.begin(.openToNote, staleAfter: .seconds(30))       // a begin changes nothing kept
        #expect(calls.withLock { $0 } == 0)
        for _ in 0..<50 { timing.count(.read) }
        timing.record(.rows, value: 2)
        #expect(calls.withLock { $0 } == 1)
        #expect(timing.hasUnsavedChanges)
        _ = timing.archive(build: "b", markingSaved: true)
        #expect(!timing.hasUnsavedChanges)
        timing.count(.read)
        #expect(calls.withLock { $0 } == 2)
        _ = timing.archive(build: "b")                            // a read alone does not re-arm
        timing.count(.read)
        #expect(calls.withLock { $0 } == 2)
    }

    /// **A NO-OP END CHANGES NOTHING KEPT** (the VM-64 ladder, round 1, finding 3
    /// — the midpoint review's finding 6). `endIfOpen` with nothing open is the
    /// ordinary case — every keyboard rise asks it — and it records nothing and
    /// counts nothing, so the change handler must not hear of it: telling it
    /// scheduled a save of an unchanged table. Every end that DID change the
    /// record still tells it, once per save: a recorded span, an unmatched
    /// `end` (counted), a stale begin dropped (counted). RED on the pre-fix tree
    /// at the first two expectations.
    @Test func aNoOpEndIfOpenLeavesTheRecordUnchanged() {
        let clock = HandClock()
        let timing = recorder(clock: clock)
        let calls = Mutex(0)
        timing.setChangeHandler { calls.withLock { $0 += 1 } }

        #expect(timing.endIfOpen(.tapToKeyboard) == nil)
        #expect(calls.withLock { $0 } == 0, "an end with nothing open and nothing counted changes nothing")
        #expect(!timing.hasUnsavedChanges)

        // A recorded span is a change.
        timing.begin(.tapToKeyboard, staleAfter: .seconds(30))
        clock.advance(ms: 40)
        #expect(timing.endIfOpen(.tapToKeyboard) == 40)
        #expect(calls.withLock { $0 } == 1)
        _ = timing.archive(build: "b", markingSaved: true)

        // Nothing open again: still nothing.
        #expect(timing.endIfOpen(.tapToKeyboard) == nil)
        #expect(calls.withLock { $0 } == 1)
        #expect(!timing.hasUnsavedChanges)

        // An unmatched `end` is COUNTED — a change.
        #expect(timing.end(.openToNote) == nil)
        #expect(calls.withLock { $0 } == 2)
        _ = timing.archive(build: "b", markingSaved: true)

        // A stale begin dropped is COUNTED — a change, through either end.
        timing.begin(.tapToKeyboard, staleAfter: .seconds(1))
        clock.advance(ms: 5_000)
        #expect(timing.endIfOpen(.tapToKeyboard) == nil)
        #expect(calls.withLock { $0 } == 3)
        let snap = timing.snapshot()
        #expect(snap.abandoned == 1 && snap.unmatchedEnds == 1)
    }

    /// ABSORB folds a persisted record UNDER the live one: the archived samples
    /// first, the live ones after (the ring keeps the newest), counts add, the
    /// earlier first day wins, and a span open across it stays open.
    @Test func absorbFoldsAPersistedRecordUnderTheLiveOne() throws {
        let clock = HandClock()
        let day = HandDate()
        let older = TimingRecorder<Series, Counter>(
            capacity: 4, enabled: true, clock: { clock.read() }, date: { day.read() })
        for value in [1.0, 2, 3] { older.record(.rows, value: value) }
        older.count(.save, by: 5)
        let archived = older.archive(build: "b")

        day.advance(days: 2)
        let live = TimingRecorder<Series, Counter>(
            capacity: 4, enabled: true, clock: { clock.read() }, date: { day.read() })
        live.begin(.openToNote, staleAfter: .seconds(30))
        live.record(.rows, value: 10)
        live.record(.rows, value: 11)
        live.count(.save, by: 2)
        #expect(live.absorb(archived))

        let snap = live.snapshot()
        let rows = try #require(snap.stats(.rows))
        #expect(rows.count == 5)
        #expect(rows.retained == [2, 3, 10, 11])                  // newest four, live last
        #expect(rows.last == 11)
        #expect(snap.counter(.save) == 7)
        #expect(snap.since == archived.since)                     // the earlier day
        #expect(live.isOpen(.openToNote))                         // untouched
    }

    /// PER-BUILD KEYING: a new build gets a fresh table and the old one becomes
    /// the previous table, untouched; the same build coming back finds its own.
    @Test func eachBuildKeepsItsOwnTable() {
        var book = TimingBook()
        #expect(book.open(build: "before", label: "1.0 (1) · BEFORE") == nil)
        var before = TimingArchive(build: "before", label: "1.0 (1) · BEFORE")
        before.counters["read"] = 3
        book.store(before)

        // The AFTER build installed in place: a fresh table in front, BEFORE kept.
        #expect(book.open(build: "after", label: "1.0 (1) · AFTER") == nil)
        #expect(book.current?.build == "after")
        #expect(book.current?.counters.isEmpty == true)           // nothing blended in
        #expect(book.previous == before)

        var after = TimingArchive(build: "after", label: "1.0 (1) · AFTER")
        after.counters["read"] = 9
        book.store(after)
        #expect(book.previous == before)                          // storing one never touches the other

        // Going back to BEFORE (reinstalled) finds its own table again.
        let reopened = book.open(build: "before", label: "1.0 (1) · BEFORE")
        #expect(reopened == before)
        #expect(book.current == before && book.previous == after)
    }

    /// THE BOUND: at most two tables — opening a third build drops the oldest.
    @Test func theBookKeepsAtMostTwoBuilds() {
        var book = TimingBook()
        for name in ["one", "two", "three", "four"] {
            book.open(build: name, label: name)
        }
        #expect(book.builds.count == TimingBook.keptBuilds)
        #expect(book.builds.map(\.build) == ["four", "three"])
        book.store(TimingArchive(build: "five"))
        #expect(book.builds.map(\.build) == ["five", "four"])
    }

    /// THE ROUND-TRIP THROUGH THE PERSISTED FORM: a recorder's record, kept in
    /// the book, written, read back in a "new process", and absorbed there,
    /// comes back number for number — and a malformed or future file reads as
    /// no book at all.
    @Test func aRecordSurvivesTheBookAndTheFile() throws {
        let clock = HandClock()
        let day = HandDate()
        let first = TimingRecorder<Series, Counter>(
            capacity: 4, enabled: true, clock: { clock.read() }, date: { day.read() })
        for value in 1...6 { first.record(.rows, value: Double(value)) }
        first.begin(.tapToKeyboard, staleAfter: .seconds(30))
        clock.advance(ms: 280)
        first.end(.tapToKeyboard)
        first.count(.build, by: 2)
        _ = first.end(.openToNote)

        var book = TimingBook()
        book.open(build: "b1", label: "1.0 (1) · B1")
        book.store(first.archive(build: "b1", label: "1.0 (1) · B1", markingSaved: true))
        let bytes = try book.encoded()

        var reread = try #require(TimingBook.decode(bytes))
        #expect(reread == book)
        let opened = reread.open(build: "b1", label: "1.0 (1) · B1")
        let kept = try #require(opened)
        let second = TimingRecorder<Series, Counter>(
            capacity: 4, enabled: true, clock: { clock.read() }, date: { day.read() })
        #expect(second.absorb(kept))
        let a = first.snapshot()
        let b = second.snapshot()
        #expect(a.series == b.series)
        #expect(a.counters == b.counters)
        #expect(a.unmatchedEnds == b.unmatchedEnds && a.since == b.since)

        #expect(TimingBook.decode(Data("not a book".utf8)) == nil)
        var future = book
        future.version = TimingBook.currentVersion + 1
        #expect(TimingBook.decode(try future.encoded()) == nil)
    }

    // MARK: - Concurrency

    /// Marks arrive from many threads at once (a listing's fetch closure counts
    /// on GRDB's queues while the main actor marks): nothing is lost.
    @Test func concurrentMarksAreAllCounted() async {
        let timing = TimingRecorder<Series, Counter>(enabled: true)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<8 {
                group.addTask {
                    for _ in 0..<1_000 {
                        timing.count(.read)
                        timing.record(.rows, value: 1)
                    }
                }
            }
        }
        let snap = timing.snapshot()
        #expect(snap.counter(.read) == 8_000)
        #expect(snap.stats(.rows)?.count == 8_000)
    }

    // MARK: - The readout's text

    @Test func theReadoutTextIsTwoLinesPerEntry() {
        var stats = TimingStats(capacity: 2)
        for value in [188.0, 940, 312] { stats.record(value) }
        let text = TimingReport.text(
            title: "TIMING",
            header: ["Release"],
            sections: [
                .init("Spans", lines: [
                    .init("Tap the box → keyboard up", stats, unit: .milliseconds),
                    .init("Open → note on screen", nil, unit: .milliseconds),
                ]),
                .init("Totals", totals: [.init("Saves", 24)]),
            ],
            footer: ["2 starts never finished"])
        #expect(text == """
            TIMING
            Release

            Spans
            Tap the box → keyboard up
              n 3 (last 2) · median 626 ms · 312–940 ms · last 312 ms
            Open → note on screen
              no runs yet

            Totals
            Saves  24

            2 starts never finished

            """)
    }

    @Test func numbersAreFormattedForTheirUnit() {
        #expect(TimingReport.number(4.24, .milliseconds) == "4.2")
        #expect(TimingReport.number(12.6, .milliseconds) == "13")
        #expect(TimingReport.number(2, .count) == "2")
        #expect(TimingReport.number(2.5, .count) == "2.5")
        var single = TimingStats()
        single.record(2)
        #expect(TimingReport.summary(single, unit: .count) == "n 1 · median 2 · 2 · last 2")
    }
}
