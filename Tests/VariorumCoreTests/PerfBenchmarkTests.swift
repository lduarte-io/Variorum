import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// `Tag` alone would collide with the VariorumCore model — qualify Testing's.
extension Testing.Tag {
    @Testing.Tag static var perf: Testing.Tag
}

/// P1 asserted, not hoped (AppSpec §4): the same fixed-size probes are
/// measured against a 1k-block and a 10k-block corpus, and the large-corpus
/// median must stay `≤ max(small × factor, budget)` — flat by RATIO (3× for a
/// 10× corpus), or under an absolute BUDGET on a host fast enough that the
/// small median × 3 falls below it.
///
/// **WHICH TERM BINDS DEPENDS ON THE HOST, AND EVERY RUN SAYS SO (17f/P48).**
/// This docstring used to claim "absolute timings are machine noise, ratios
/// are the assertion" — and that was not what the gate enforced: with the
/// former 2 ms floor against sub-millisecond medians, the floor was the only
/// binding term in four to five of the six pins on a quiet host, so
/// `libraryPageIsFlat…` tolerated a 6.45× regression under a name asserting
/// flatness. The project had already ruled this class a defect on the phone
/// (`MobilePerfWalkTests`' bounds comment: *"a pin named 'flat' whose floor is
/// the only binding bound is the record-claim class"*) and renamed those pins;
/// the core suite never got that pass. It has one now: the names say
/// flat-OR-under-budget, `expectFlat` prints and reports which term actually
/// bound on this run, and the budget is derived below instead of round.
///
/// Three corpora: `small` (100 posts × 10 blocks), `large` (1000 × 10 — the
/// corpus-size axis), and `tall` (100 × 100 — same post count as small, 10×
/// the text: the corpus-*text* axis the library benchmark isolates).
@Suite("P1 perf benchmarks (Phase 4, Step 6)", .serialized, .tags(.perf))
struct PerfBenchmarkTests {
    // Result-wrapped so a corpus-build failure fails the suite's tests
    // instead of crashing the test process (review nit).
    static let small = Result { try CorpusFactory.build(posts: 100, blocksPerPost: 10) }
    static let large = Result { try CorpusFactory.build(posts: 1_000, blocksPerPost: 10) }
    static let tall = Result { try CorpusFactory.build(posts: 100, blocksPerPost: 100) }

    private static func seconds(_ d: Duration) -> Double {
        Double(d.components.seconds) + Double(d.components.attoseconds) * 1e-18
    }

    private func median(iterations: Int = 20, _ body: () throws -> Void) throws -> Duration {
        let clock = ContinuousClock()
        // One warm-up outside the samples (statement compilation, page cache).
        try body()
        var samples: [Duration] = []
        for _ in 0..<iterations {
            samples.append(try clock.measure(body))
        }
        return samples.sorted()[samples.count / 2]
    }

    /// The absolute budget for a bounded query probe, **derived, not round**
    /// (17f/P48). Measured large-corpus medians for these five probes, over two
    /// hosts (a quiet one and this machine under agent load): 0.32–1.27 ms.
    /// 1 ms sits above the cheapest of them (`library`, 0.32–0.40 ms) with ~2.5×
    /// of headroom and BELOW the dearest (`timelinePage`, ~1.27 ms) — so at
    /// least one pin is always ratio-bound and the budget can never become the
    /// suite's only teeth.
    ///
    /// Why tightening it does not flake: the budget binds only when
    /// `small × 3 < 1 ms`, i.e. when the small median is under ~0.33 ms — which
    /// means a fast host, on which the large median is correlated and far below
    /// the budget too. The dangerous case (a load spike inside one half only)
    /// is what the median of 20 iterations absorbs. The former 2 ms value was
    /// the whole of P48: it left `library` a 6.45× tolerated regression.
    private static let queryBudget = Duration.milliseconds(1)

    /// The P1 assertion: `large` must not scale with the corpus —
    /// `large ≤ max(small × factor, budget)`. **Reports which term bound**, so
    /// no reader (and no closeout) can mistake a budget pass for a flatness
    /// measurement.
    private func expectFlat(
        small smallTime: Duration, large largeTime: Duration,
        factor: Double = 3.0, floor: Duration = PerfBenchmarkTests.queryBudget,
        _ label: Comment
    ) {
        let s = Self.seconds(smallTime)
        let l = Self.seconds(largeTime)
        let ratioBound = s * factor
        let budget = Self.seconds(floor)
        let bound = max(ratioBound, budget)
        let binding = ratioBound >= budget
            ? String(format: "RATIO ×%.1f", factor)
            : String(format: "BUDGET %.1fms", budget * 1000)
        // Medians land in the run log so closeouts and post-macOS-update
        // re-verifications have numbers to compare — and the binding term
        // rides with them, because "0.4 ms, flat" and "0.4 ms, under a budget
        // that would also have passed 1.0 ms" are different facts.
        print(String(
            format: "P1 %@ — small: %.3fms, big: %.3fms (%.2f×) — bound by %@ at %.3fms",
            "\(label)", s * 1000, l * 1000, s > 0 ? l / s : 0, binding, bound * 1000))
        #expect(
            l <= bound,
            """
            \(label): small=\(s * 1000)ms large=\(l * 1000)ms \
            ratio=\(s > 0 ? l / s : 0)× — bound by \(binding) at \(bound * 1000)ms
            """)
    }

    @Test func postRenderIsFlatOrUnderBudgetInCorpusSize() throws {
        let small = try Self.small.get()
        let large = try Self.large.get()
        // Sanity: the probe is real and identical in both corpora.
        let rows = try large.db.read { try Queries.renderPost($0, containerID: large.bigPostID) }
        #expect(rows.count == 50)
        #expect(rows.allSatisfy { !$0.isGap })

        let smallTime = try median {
            _ = try small.db.read { try Queries.renderPost($0, containerID: small.bigPostID) }
        }
        let largeTime = try median {
            _ = try large.db.read { try Queries.renderPost($0, containerID: large.bigPostID) }
        }
        expectFlat(small: smallTime, large: largeTime, "renderPost(50 blocks), 1k vs 10k corpus")
    }

    @Test func readingAssemblyFirstPageIsFlatOrUnderBudgetInCorpusSize() throws {
        let small = try Self.small.get()
        let large = try Self.large.get()
        let entries = try large.db.read { try Queries.assembleReading($0, readingID: large.bookReadingID) }
        #expect(entries.count == 50)

        let smallTime = try median {
            _ = try small.db.read { try Queries.assembleReading($0, readingID: small.bookReadingID) }
        }
        let largeTime = try median {
            _ = try large.db.read { try Queries.assembleReading($0, readingID: large.bookReadingID) }
        }
        expectFlat(small: smallTime, large: largeTime, "assembleReading(50 posts), 1k vs 10k corpus")
    }

    @Test func timelinePageIsFlatOrUnderBudgetInCorpusSize() throws {
        let small = try Self.small.get()
        let large = try Self.large.get()
        // A mid-corpus page, not the first: keyset must seek, never scan.
        func page(_ corpus: CorpusFactory.Corpus) throws -> [Queries.TimelineItem] {
            try corpus.db.read { db in
                let first = try Queries.timelinePage(db, order: .entryDate, limit: 50)
                return try Queries.timelinePage(db, order: .entryDate, after: first.last, limit: 50)
            }
        }
        #expect(try page(large).count == 50)

        let smallTime = try median { _ = try page(small) }
        let largeTime = try median { _ = try page(large) }
        expectFlat(small: smallTime, large: largeTime, "timelinePage(50, keyset), 1k vs 10k corpus")
    }

    @Test func libraryPageIsFlatOrUnderBudgetInCorpusTextSize() throws {
        // The MAJOR review finding's measurement: a bounded library page is
        // what `observeLibrary` re-fetches at container-write rate, so its
        // cost must track the post count, never the corpus text. Same 100
        // posts in both corpora here — the tall one holds 10× the text.
        let small = try Self.small.get()
        let tall = try Self.tall.get()
        #expect(try tall.db.read { try Queries.library($0, limit: 50) }.count == 50)

        let smallTime = try median {
            _ = try small.db.read { try Queries.library($0, sort: .lastTouched, limit: 50) }
        }
        let tallTime = try median {
            _ = try tall.db.read { try Queries.library($0, sort: .lastTouched, limit: 50) }
        }
        expectFlat(
            small: smallTime, large: tallTime,
            "library(limit 50), 100 posts at 1k vs 10k blocks")
    }

    @Test func tagSubtreeIsFlatOrUnderBudgetInCorpusSize() throws {
        let small = try Self.small.get()
        let large = try Self.large.get()
        let subtree = try large.db.read { try Queries.tagSubtree($0, rootID: large.tagRootID) }
        #expect(subtree.count == 6)  // root + 5 sections, both corpora

        let smallTime = try median {
            _ = try small.db.read { try Queries.tagSubtree($0, rootID: small.tagRootID) }
        }
        let largeTime = try median {
            _ = try large.db.read { try Queries.tagSubtree($0, rootID: large.tagRootID) }
        }
        expectFlat(small: smallTime, large: largeTime, "tagSubtree(6 tags), 1k vs 10k corpus")
    }

    @Test func autosaveIsFlatInPostLength() throws {
        let large = try Self.large.get()
        // The storage half of P1: an edit writes one small variant row —
        // autosave into a 50-block post must cost what it costs in a
        // 5-block post. charDelta 0 after a warm-up crossing keeps churn
        // math off the rendered-length path (that scan runs only on
        // threshold crossings, by design).
        try CorpusFactory.withOperations(on: large) { ops in
            try ops.autosave(large.smallPostVariantID, text: "warm", charDelta: 1)
            try ops.autosave(large.bigPostVariantID, text: "warm", charDelta: 1)

            let smallPostTime = try median(iterations: 30) {
                try ops.autosave(
                    large.smallPostVariantID,
                    text: CorpusFactory.blockText(post: -2, block: 0), charDelta: 0)
            }
            let bigPostTime = try median(iterations: 30) {
                try ops.autosave(
                    large.bigPostVariantID,
                    text: CorpusFactory.blockText(post: -1, block: 0), charDelta: 0)
            }
            expectFlat(
                small: smallPostTime, large: bigPostTime,
                floor: .milliseconds(1), "autosave(5-block vs 50-block post)")
        }
    }
}
