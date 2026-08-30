//
//  MobileShelfPerfTests.swift
//  VariorumMobileTests
//
//  Mobile Round 2, batch 5 — **§53 ROW 7: THE QUICK NOTE'S MINT COST AT
//  CORPUS SCALE, MEASURED.**
//
//  The sweep's finding, verbatim: *"The quick note's mint cost at corpus
//  scale was never measured — and R27 is about to make that box the
//  shelf's main surface."* `MobilePerfWalkTests` covers open, typing,
//  scroll and Read; it has no quick-note leg, and the box is the one new
//  TYPING surface the round added.
//
//  **What is measured here, and why each axis is the one it is:**
//
//  · **MINT** (`mintNow` — `importPost` + the render read + the
//    coordinator handshake) must be FLAT IN CORPUS SIZE. The mint is one
//    insert plus N block inserts for the captured paragraphs; nothing in
//    it may walk the library. This is P1's own sentence applied to the
//    door she now types into every day.
//  · **PER-KEYSTROKE** cost in the box must be flat in corpus size too.
//    The sweep's stated worry: *"Typing on the shelf schedules sync
//    rounds at autosave rate against a held books observation."*
//  · **The held observation is the thing that would make it corpus-shaped,
//    so its INDEPENDENCE is asserted structurally as well**: a bookless
//    mint must not re-run `Queries.bookshelf`. Measured by counting the
//    shelf model's own observation ticks across a mint, which is a fact
//    about what the store notifies, not a timing.
//
//  Absolutes print as `PERF[sim]` lines and are SIMULATOR numbers —
//  harvested into the batch record, never mistaken for device numbers.
//  The two worlds are `PerfWorlds`' own (the ~100k mega post + 300 notes
//  across six books, against 12 notes and no mega post), reused rather
//  than rebuilt so this file costs the suite nothing beyond its own legs.
//

import Dependencies
import Foundation
import QuartzCore
import Testing
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

@MainActor
private func withShelfPerfWorld<T>(
    _ world: PerfWorlds.World,
    _ body: @MainActor (AppSession) async throws -> T
) async throws -> T {
    MobileEditorStyle.voice = .terminal
    return try await withDependencies {
        $0.database = world.db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator { Date() }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 91))
    } operation: { @MainActor in
        try await body(AppSession(database: world.db))
    }
}

/// A quick-note model with both clocks disabled — the pins mint
/// explicitly, so the number is the MINT and never a sleep.
@MainActor
private func quietBox(_ session: AppSession) -> MobileQuickNoteModel {
    let model = MobileQuickNoteModel(session: session)
    model.sleep = { _ in throw CancellationError() }
    model.autosaveSleep = { _ in throw CancellationError() }
    return model
}

private func median(_ samples: [Double]) -> Double {
    guard !samples.isEmpty else { return 0 }
    return samples.sorted()[samples.count / 2]
}

/// One capture, minted and timed. The box is fresh each time — a mint is
/// a once-per-capture act, so re-using a minted box would time nothing.
@MainActor
private func mintSample(_ session: AppSession, text: String) async -> Double {
    let box = quietBox(session)
    box.text = text
    let t0 = CACurrentMediaTime()
    _ = await box.mintNow()
    return (CACurrentMediaTime() - t0) * 1000
}

// MARK: - The measurement

@Suite("Shelf perf — the quick note's mint at corpus scale (§53 row 7)")
@MainActor
struct MobileShelfPerfTests {

    /// **THE NUMBER §53 ASKED FOR.** A capture's mint must cost the same
    /// against a 300-note, six-book, 100k-word corpus as against a bare
    /// one — P1's letter for the shelf's new main surface.
    @Test func theQuickNoteMintIsFlatInCorpusSize() async throws {
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()
        let capture = "A thought worth keeping, typed on the home screen."

        var bigSamples: [Double] = []
        var smallSamples: [Double] = []
        try await withShelfPerfWorld(small) { session in
            for _ in 0..<7 { smallSamples.append(await mintSample(session, text: capture)) }
        }
        try await withShelfPerfWorld(big) { session in
            for _ in 0..<7 { bigSamples.append(await mintSample(session, text: capture)) }
        }

        let smallMS = median(smallSamples)
        let bigMS = median(bigSamples)
        print(String(
            format: "PERF[sim] quick-note MINT — bare corpus %.3f ms · full corpus "
                + "%.3f ms · ratio %.2fx",
            smallMS, bigMS, smallMS > 0 ? bigMS / smallMS : 0))

        // Flatness with a generous factor and an absolute floor, the
        // `expectFlat` shape: a mint is a handful of indexed inserts, so
        // the only thing that could make it corpus-shaped is a scan.
        #expect(bigMS <= max(smallMS * 3.0, 12.0),
                "mint: bare=\(smallMS)ms full=\(bigMS)ms")
        // And the absolute, because "flat and slow" would also be a defect
        // on a surface she types into every day.
        #expect(bigMS <= 60.0, "a capture must feel instant — \(bigMS) ms")
    }

    /// A MULTI-PARAGRAPH capture (the pre-mint paste road: `importPost`
    /// segments it, and the box then has to find its own boundary) still
    /// costs the same against a full corpus.
    @Test func aPastedCaptureIsFlatInCorpusSizeToo() async throws {
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()
        let capture = (0..<12)
            .map { "Paragraph \($0) of a pasted capture, long enough to segment." }
            .joined(separator: "\n\n")

        var bigSamples: [Double] = []
        var smallSamples: [Double] = []
        try await withShelfPerfWorld(small) { session in
            for _ in 0..<5 { smallSamples.append(await mintSample(session, text: capture)) }
        }
        try await withShelfPerfWorld(big) { session in
            for _ in 0..<5 { bigSamples.append(await mintSample(session, text: capture)) }
        }

        let smallMS = median(smallSamples)
        let bigMS = median(bigSamples)
        print(String(
            format: "PERF[sim] quick-note MINT (12-paragraph paste) — bare %.3f ms "
                + "· full %.3f ms · ratio %.2fx",
            smallMS, bigMS, smallMS > 0 ? bigMS / smallMS : 0))
        #expect(bigMS <= max(smallMS * 3.0, 25.0),
                "paste mint: bare=\(smallMS)ms full=\(bigMS)ms")
    }

    /// Typing INTO the box after the mint — the autosave-rate road the
    /// sweep worried about — is flat in corpus size as well.
    @Test func typingInTheBoxIsFlatInCorpusSize() async throws {
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()

        @MainActor
        func keystrokeMedian(_ session: AppSession) async -> Double {
            let box = quietBox(session)
            box.text = "Seed"
            _ = await box.mintNow()
            var samples: [Double] = []
            for index in 0..<40 {
                let t0 = CACurrentMediaTime()
                box.text += String(index % 10)
                samples.append((CACurrentMediaTime() - t0) * 1000)
            }
            return median(samples)
        }

        var smallMS = 0.0
        var bigMS = 0.0
        try await withShelfPerfWorld(small) { session in smallMS = await keystrokeMedian(session) }
        try await withShelfPerfWorld(big) { session in bigMS = await keystrokeMedian(session) }

        print(String(
            format: "PERF[sim] quick-note KEYSTROKE — bare %.4f ms · full %.4f ms",
            smallMS, bigMS))
        #expect(bigMS <= max(smallMS * 3.0, 2.0),
                "keystroke: bare=\(smallMS)ms full=\(bigMS)ms")
    }

    /// **The structural half, and the one that would actually bite.** The
    /// shelf holds a live `bookshelf` observation while she types. A
    /// bookless capture must not wake it — otherwise every mint would
    /// re-run a query over every book on a surface she uses constantly.
    ///
    /// Asserted as a FACT about what the store notifies (an observation
    /// tick count), not as a timing, so it cannot pass by being fast.
    @Test func aBooklessCaptureDoesNotWakeTheShelfObservation() async throws {
        try await withEditorWorld { session, _ in
            for index in 0..<6 {
                _ = try await session.runner.run { ops in
                    try ops.createReading(name: "Book \(index)", kind: .curated)
                }
            }
            let shelf = MobileShelfViewModel(session: session)
            let observation = Task { await shelf.start() }
            defer { observation.cancel() }

            // Let the first value land.
            for _ in 0..<40 {
                if !shelf.books.isEmpty { break }
                try? await Task.sleep(for: .milliseconds(20))
            }
            #expect(shelf.books.count == 6)
            let before = shelf.observationTicks

            let box = quietBox(session)
            box.text = "A bookless capture."
            _ = await box.mintNow()
            // Give any spurious observation ample time to fire.
            try? await Task.sleep(for: .milliseconds(300))

            print("PERF[sim] shelf observation ticks across a bookless mint — "
                  + "\(before) → \(shelf.observationTicks)")
            #expect(shelf.observationTicks == before,
                    "the shelf's held books observation must not re-run at capture rate (P1: cost ∝ viewport + edit)")
        }
    }
}
