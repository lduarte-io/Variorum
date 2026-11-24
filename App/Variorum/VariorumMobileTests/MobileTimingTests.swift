//
//  MobileTimingTests.swift
//  VariorumMobileTests
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING READOUT AND ITS FILE, on the
//  phone. The brain is pinned headless in Core (`TimingRecorderTests`); these
//  pin what only the phone's face decides:
//
//   · COVERAGE — every series of the catalog is on the readout exactly once,
//     and every counter is in its totals (a mark that measures something no
//     one can read is a mark that silently does nothing);
//   · BOTH TABLES — this build's table, then the previous build's under it,
//     each headed by its build and its first day (the author's sharpening);
//   · THE FILE KEEPS BUILDS APART — a record saved by one build is found
//     again by that build after a "quit", while a different build starts
//     clean and leaves the first build's table readable as the previous one.
//
//  Each test drives a recorder and a temporary file of its OWN — never the
//  app's recorder or its timing file, which other suites in the same process
//  read and write. *(Corrected at the VM-64 ladder's round 2: this line first
//  said "the suites run in parallel". In this host they run one after another
//  — the scheme's `parallelizable = "NO"` is built into the xctestrun as
//  `InProcessParallelizationEnabled = false`, and the round's probe saw seven
//  suites run in turn; what a shared recorder or file risks here is an earlier
//  suite's leftovers, not a neighbour running beside it.)*
//  NEW-MECHANISM tests, green by design (no fix in this batch).
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile timing readout and its file (VM-65)")
struct MobileTimingTests {
    private typealias Recorder = TimingRecorder<AppTimingSeries, AppTimingCounter>

    @Test func everySeriesIsOnTheReadoutExactlyOnce() {
        let shown = MobileTimingCopy.spans.flatMap { $0.rows.map(\.0) } + MobileTimingCopy.counts.map(\.0)
        #expect(Set(shown) == Set(AppTimingSeries.allCases))
        #expect(shown.count == AppTimingSeries.allCases.count)
        let labels = MobileTimingCopy.spans.flatMap { $0.rows.map(\.1) } + MobileTimingCopy.counts.map(\.1)
        #expect(labels.allSatisfy { !$0.isEmpty })
    }

    @Test func everyCounterIsInTheTotalsExactlyOnce() {
        let shown = MobileTimingCopy.totals.map(\.0)
        #expect(Set(shown) == Set(AppTimingCounter.allCases))
        #expect(shown.count == AppTimingCounter.allCases.count)
    }

    /// The readout: this build's table headed by its build and its first day,
    /// the previous build's under it when one is kept — and nothing of a
    /// previous build when none is.
    @Test func theReadoutShowsThisBuildThenThePreviousOne() {
        let recorder = Recorder(enabled: true)
        recorder.record(.boxTapToKeyboard, value: 312)
        let current = MobileTimingCopy.table(recorder.snapshot(), label: "1.0 (1) Debug · AFTER")

        let alone = MobileTimingCopy.report(current: current, previous: nil)
        // VM-64 ladder round 2, finding 9: the heading is the words as drafted,
        // never forced into capitals (her sentence-case rule).
        #expect(alone.contains("\(MobileTimingCopy.title) — \(MobileTimingCopy.thisBuild)"))
        #expect(!alone.contains(MobileTimingCopy.title.uppercased()))
        #expect(alone.contains("1.0 (1) Debug · AFTER"))
        #expect(alone.contains("collecting since "))
        #expect(alone.contains("n 1 · median 312 ms"))
        #expect(!alone.contains(MobileTimingCopy.previousBuild))

        var before = TimingArchive(build: "before", label: "1.0 (1) Release · BEFORE")
        before.series[AppTimingSeries.boxTapToKeyboard.rawValue] = {
            var stats = TimingStats()
            stats.record(940)
            return stats
        }()
        let both = MobileTimingCopy.report(current: current, previous: MobileTimingCopy.table(before))
        #expect(both.contains("\(MobileTimingCopy.title) — \(MobileTimingCopy.previousBuild)"))
        #expect(both.contains("1.0 (1) Release · BEFORE"))
        #expect(both.contains("n 1 · median 940 ms"))
        #expect(both.contains("nothing collected yet"))     // BEFORE's archive carries no first day
        // This build first.
        let afterAt = both.range(of: "AFTER")!.lowerBound
        let beforeAt = both.range(of: "BEFORE")!.lowerBound
        #expect(afterAt < beforeAt)
    }

    /// THE FILE KEEPS BUILDS APART, across "quits" (a fresh store over the same
    /// file is a fresh process).
    @Test func theFileKeepsEachBuildsTableAcrossAQuit() async throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm65-timing-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("timing.json")

        // BEFORE, first launch: records, saves.
        let beforeRecorder = Recorder(enabled: true)
        let beforeStore = MobileTimingStore(file: file, recorder: beforeRecorder)
        beforeStore.load(build: "before", label: "BEFORE")
        beforeRecorder.record(.boxOpenToNote, value: 400)
        beforeRecorder.count(.autosaveWrite, by: 3)
        await save(beforeStore)
        let written = try #require(TimingBook.decode(try Data(contentsOf: file)))
        #expect(written.current?.build == "before")
        #expect(written.current?.series[AppTimingSeries.boxOpenToNote.rawValue]?.retained == [400])

        // AFTER, installed in place: starts clean; BEFORE is the previous table.
        let afterRecorder = Recorder(enabled: true)
        let afterStore = MobileTimingStore(file: file, recorder: afterRecorder)
        afterStore.load(build: "after", label: "AFTER")
        afterRecorder.record(.boxOpenToNote, value: 90)
        await save(afterStore)
        #expect(afterRecorder.snapshot().stats(.boxOpenToNote)?.retained == [90])   // nothing blended in
        #expect(afterStore.previous?.build == "before")
        #expect(afterStore.previous?.series[AppTimingSeries.boxOpenToNote.rawValue]?.retained == [400])
        #expect(afterStore.previous?.counters[AppTimingCounter.autosaveWrite.rawValue] == 3)

        // AFTER again, after a quit: its own table comes back, folded under the
        // new process's first sample.
        let againRecorder = Recorder(enabled: true)
        againRecorder.record(.boxOpenToNote, value: 85)
        let againStore = MobileTimingStore(file: file, recorder: againRecorder)
        againStore.load(build: "after", label: "AFTER")
        await save(againStore)
        #expect(againRecorder.snapshot().stats(.boxOpenToNote)?.retained == [90, 85])
        #expect(againStore.previous?.build == "before")
    }

    /// Waits for the store's queue to run a save (it runs after the load,
    /// which was queued first — the store's own ordering).
    private func save(_ store: MobileTimingStore) async {
        await withCheckedContinuation { (done: CheckedContinuation<Void, Never>) in
            store.saveNow { done.resume() }
        }
    }
}
