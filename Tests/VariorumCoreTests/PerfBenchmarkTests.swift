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
/// measured against a 1k-block and a 10k-block corpus, and the *ratio* must
/// stay near-flat — absolute timings are machine noise, ratios are the
/// assertion. A generous factor (3× for a 10× corpus) plus a small absolute
/// floor (sub-floor timings pass outright) keep the suite honest without
/// flaking on noisy hardware.
@Suite("P1 perf benchmarks (Phase 4, Step 6)", .serialized, .tags(.perf))
struct PerfBenchmarkTests {
    static let small = try! CorpusFactory.build(posts: 100, blocksPerPost: 10)
    static let large = try! CorpusFactory.build(posts: 1_000, blocksPerPost: 10)

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

    /// The P1 assertion: `large` must not scale with the corpus. Passes when
    /// under the noise floor or within `factor` of the small-corpus median.
    private func expectFlat(
        small smallTime: Duration, large largeTime: Duration,
        factor: Double = 3.0, floor: Duration = .milliseconds(2),
        _ label: Comment
    ) {
        let s = Self.seconds(smallTime)
        let l = Self.seconds(largeTime)
        // Medians land in the run log so closeouts and post-macOS-update
        // re-verifications have numbers to compare.
        print(String(format: "P1 %@ — 1k corpus: %.3fms, 10k corpus: %.3fms", "\(label)", s * 1000, l * 1000))
        #expect(
            l <= max(s * factor, Self.seconds(floor)),
            "\(label): small=\(s * 1000)ms large=\(l * 1000)ms")
    }

    @Test func postRenderIsFlatInCorpusSize() throws {
        // Sanity: the probe is real and identical in both corpora.
        let rows = try Self.large.db.read { try Queries.renderPost($0, containerID: Self.large.bigPostID) }
        #expect(rows.count == 50)
        #expect(rows.allSatisfy { !$0.isGap })

        let smallTime = try median {
            _ = try Self.small.db.read { try Queries.renderPost($0, containerID: Self.small.bigPostID) }
        }
        let largeTime = try median {
            _ = try Self.large.db.read { try Queries.renderPost($0, containerID: Self.large.bigPostID) }
        }
        expectFlat(small: smallTime, large: largeTime, "renderPost(50 blocks)")
    }

    @Test func readingAssemblyFirstPageIsFlatInCorpusSize() throws {
        let entries = try Self.large.db.read { try Queries.assembleReading($0, readingID: Self.large.bookReadingID) }
        #expect(entries.count == 50)

        let smallTime = try median {
            _ = try Self.small.db.read { try Queries.assembleReading($0, readingID: Self.small.bookReadingID) }
        }
        let largeTime = try median {
            _ = try Self.large.db.read { try Queries.assembleReading($0, readingID: Self.large.bookReadingID) }
        }
        expectFlat(small: smallTime, large: largeTime, "assembleReading(50 posts)")
    }

    @Test func timelinePageIsFlatInCorpusSize() throws {
        // A mid-corpus page, not the first: keyset must seek, never scan.
        func page(_ corpus: CorpusFactory.Corpus) throws -> [Queries.TimelineItem] {
            try corpus.db.read { db in
                let first = try Queries.timelinePage(db, order: .entryDate, limit: 50)
                return try Queries.timelinePage(db, order: .entryDate, after: first.last, limit: 50)
            }
        }
        #expect(try page(Self.large).count == 50)

        let smallTime = try median { _ = try page(Self.small) }
        let largeTime = try median { _ = try page(Self.large) }
        expectFlat(small: smallTime, large: largeTime, "timelinePage(50, keyset)")
    }

    @Test func tagSubtreeIsFlatInCorpusSize() throws {
        let subtree = try Self.large.db.read { try Queries.tagSubtree($0, rootID: Self.large.tagRootID) }
        #expect(subtree.count == 6)  // root + 5 sections, both corpora

        let smallTime = try median {
            _ = try Self.small.db.read { try Queries.tagSubtree($0, rootID: Self.small.tagRootID) }
        }
        let largeTime = try median {
            _ = try Self.large.db.read { try Queries.tagSubtree($0, rootID: Self.large.tagRootID) }
        }
        expectFlat(small: smallTime, large: largeTime, "tagSubtree(6 tags)")
    }

    @Test func autosaveIsFlatInPostLength() throws {
        // The storage half of P1: an edit writes one small variant row —
        // autosave into a 50-block post must cost what it costs in a
        // 5-block post. charDelta 0 after a warm-up crossing keeps churn
        // math off the rendered-length path (that scan runs only on
        // threshold crossings, by design).
        try CorpusFactory.withOperations(on: Self.large) { ops in
            try ops.autosave(Self.large.smallPostVariantID, text: "warm", charDelta: 1)
            try ops.autosave(Self.large.bigPostVariantID, text: "warm", charDelta: 1)

            let smallPostTime = try median(iterations: 30) {
                try ops.autosave(
                    Self.large.smallPostVariantID,
                    text: CorpusFactory.blockText(post: -2, block: 0), charDelta: 0)
            }
            let bigPostTime = try median(iterations: 30) {
                try ops.autosave(
                    Self.large.bigPostVariantID,
                    text: CorpusFactory.blockText(post: -1, block: 0), charDelta: 0)
            }
            expectFlat(
                small: smallPostTime, large: bigPostTime,
                floor: .milliseconds(1), "autosave(5-block vs 50-block post)")
        }
    }
}
