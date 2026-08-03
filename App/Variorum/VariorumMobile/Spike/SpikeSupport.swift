//
//  SpikeSupport.swift
//  VariorumMobile — Stage 0 TK2-on-iOS spike (THROWAWAY; deleted at stage close)
//
//  Recorder + deterministic corpus + attribute auditing. Mirrors the Mac
//  Phase 6 spike's harness shape (Spikes/TK2Spike): seeded corpus with a
//  block-ID custom attribute on every paragraph range, named probes with
//  ms/px values, environment stamping. Never imported by production code.
//

#if DEBUG

import UIKit

// MARK: - Recorder

/// Named-probe recorder. Every line goes to stdout with a greppable prefix
/// (captured via `simctl launch --console-pty`) AND to
/// Documents/tk2spike-results.log (pulled via `simctl get_app_container`
/// after XCUITest-driven runs, where stdout isn't ours).
final class SpikeRecorder {
    static let shared = SpikeRecorder()
    private(set) var lines: [String] = []
    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("tk2spike-results.log")
    }()

    func reset() {
        lines = []
        try? FileManager.default.removeItem(at: fileURL)
    }

    func record(_ line: String) {
        let stamped = "TK2SPIKE|\(line)"
        lines.append(stamped)
        print(stamped)
        let data = Data((stamped + "\n").utf8)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        } else {
            try? data.write(to: fileURL)
        }
    }

    /// Stamp the exact environment into the results (the §5 matrix makes
    /// every number point-release-scoped by definition).
    func stampEnvironment() {
        let device = UIDevice.current
        record("0.env|os=\(device.systemName) \(device.systemVersion)|model=\(device.model)")
        let pi = ProcessInfo.processInfo
        record("0.env|osVersion=\(pi.operatingSystemVersionString)")
        #if targetEnvironment(simulator)
        let sim = pi.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "unknown"
        let runtime = pi.environment["SIMULATOR_RUNTIME_VERSION"] ?? "unknown"
        record("0.env|simulator=\(sim)|runtime=\(runtime)")
        #else
        record("0.env|device=physical")
        #endif
    }
}

// MARK: - Timing

@inline(__always)
func spikeMS(_ body: () -> Void) -> Double {
    let t0 = CACurrentMediaTime()
    body()
    return (CACurrentMediaTime() - t0) * 1000
}

struct SpikeStats {
    let avg: Double
    let p95: Double
    let max: Double
    init(_ samples: [Double]) {
        guard !samples.isEmpty else { avg = 0; p95 = 0; max = 0; return }
        avg = samples.reduce(0, +) / Double(samples.count)
        let sorted = samples.sorted()
        let rank = Swift.min(sorted.count - 1, Int((0.95 * Double(sorted.count)).rounded(.up)) - 1)
        p95 = sorted[Swift.max(0, rank)]
        max = sorted.last ?? 0
    }
    var line: String {
        String(format: "avg=%.2fms p95=%.2fms max=%.2fms", avg, p95, max)
    }
}

// MARK: - Seeded RNG (SplitMix64 — the suite's own pattern)

struct SpikeRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// MARK: - Corpus

/// Deterministic paragraph-shaped corpus with a block-ID custom attribute
/// on every paragraph range (including its trailing newline — a deliberate,
/// documented convention for the spike; real separator ownership is a
/// Stage 1 `BlockRangeIndex` decision, per the Mac spike's NIT 8).
enum SpikeCorpus {
    nonisolated static let blockIDKey = NSAttributedString.Key("spike.blockID")

    private static let vocabulary: [String] = [
        "the", "quiet", "morning", "held", "its", "breath", "while", "she",
        "wrote", "another", "paragraph", "about", "rivers", "and", "callous",
        "light", "under", "winter", "windows", "each", "sentence", "leaning",
        "toward", "something", "unsaid", "a", "notebook", "keeps", "choices",
        "open", "longer", "than", "memory", "does", "blocks", "of", "prose",
        "carry", "their", "variants", "gently", "forward",
    ]

    struct Result {
        let text: NSMutableAttributedString
        let blockCount: Int
        let wordCount: Int
        let utf16Length: Int
        /// Character (UTF-16) ranges per block, including the trailing newline.
        let blockRanges: [NSRange]
    }

    /// ~targetWords of mixed paragraphs: short/medium paragraphs, a markdown
    /// heading every ~25 blocks, and three ~2,000-word giants spread through
    /// the document (the shapes journals/books actually have — Mac spike).
    static func make(seed: UInt64 = 7, targetWords: Int = 50_000, giants: Bool = true) -> Result {
        var rng = SpikeRNG(seed: seed)
        let body = UIFont.preferredFont(forTextStyle: .body)
        let color = UIColor.label
        let out = NSMutableAttributedString()
        var words = 0
        var block = 0
        var ranges: [NSRange] = []
        // Giants at roughly 20/50/80% through the word budget (suppressed
        // for small corpora — a giant would swallow the whole budget).
        let giantAt = giants ? [targetWords / 5, targetWords / 2, (targetWords * 4) / 5] : []
        var giantsPlaced = 0

        func sentence(_ rng: inout SpikeRNG, words wordsWanted: Int) -> String {
            var parts: [String] = []
            parts.reserveCapacity(wordsWanted)
            for i in 0..<wordsWanted {
                var w = vocabulary[Int(rng.next() % UInt64(vocabulary.count))]
                if i == 0 { w = w.prefix(1).uppercased() + w.dropFirst() }
                parts.append(w)
            }
            return parts.joined(separator: " ") + "."
        }

        while words < targetWords {
            let isHeading = block % 25 == 24
            let isGiant = giantsPlaced < giantAt.count && words >= giantAt[giantsPlaced]
            var paragraph: String
            var paragraphWords: Int
            if isHeading {
                paragraph = "## Section \(block)"
                paragraphWords = 2
            } else {
                let sentences: Int
                if isGiant {
                    sentences = 200  // ~2,000 words
                    giantsPlaced += 1
                } else {
                    sentences = 3 + Int(rng.next() % 6)
                }
                var parts: [String] = []
                paragraphWords = 0
                for _ in 0..<sentences {
                    let n = 6 + Int(rng.next() % 9)
                    parts.append(sentence(&rng, words: n))
                    paragraphWords += n
                }
                paragraph = parts.joined(separator: " ")
            }
            paragraph += "\n"
            let start = out.length
            out.append(
                NSAttributedString(
                    string: paragraph,
                    attributes: [
                        .font: body,
                        .foregroundColor: color,
                        blockIDKey: NSNumber(value: block),
                    ]))
            ranges.append(NSRange(location: start, length: out.length - start))
            words += paragraphWords
            block += 1
        }
        return Result(
            text: out, blockCount: block, wordCount: words,
            utf16Length: out.length, blockRanges: ranges)
    }

    /// The small interactive corpus for gesture/menu/keyboard scenarios:
    /// a handful of on-screen paragraphs; block 2 is the "fanned" block.
    static func makeInteractive() -> Result {
        make(seed: 99, targetWords: 260, giants: false)
    }
}

// MARK: - Attribute auditing

nonisolated enum SpikeAttributeAudit {
    struct Run {
        let range: NSRange
        let blockID: Int?  // nil = attribute missing
    }

    static func runs(in storage: NSAttributedString, range: NSRange) -> [Run] {
        var out: [Run] = []
        let clamped = NSIntersectionRange(range, NSRange(location: 0, length: storage.length))
        guard clamped.length > 0 else { return out }
        storage.enumerateAttribute(SpikeCorpus.blockIDKey, in: clamped) { value, r, _ in
            out.append(Run(range: r, blockID: (value as? NSNumber)?.intValue))
        }
        return out
    }

    static func describe(_ runs: [Run]) -> String {
        runs.map { run in
            "[\(run.range.location),+\(run.range.length):\(run.blockID.map(String.init) ?? "MISSING")]"
        }.joined()
    }

    /// Classify a mutated paragraph against its expected single block ID:
    /// INTACT (one run, right ID) / GAP (attribute missing somewhere) /
    /// BLEED (a foreign block's ID inside the range) / SPLIT (right ID but
    /// fragmented — harmless but recorded).
    static func classify(_ runs: [Run], expected: Int) -> String {
        if runs.contains(where: { $0.blockID == nil }) { return "GAP" }
        if runs.contains(where: { $0.blockID != nil && $0.blockID != expected }) { return "BLEED" }
        if runs.count > 1 { return "SPLIT(\(runs.count))" }
        return "INTACT"
    }

    /// A cheap fingerprint of string + block-ID runs, for zero-write proofs.
    static func fingerprint(_ storage: NSAttributedString) -> Int {
        var hasher = Hasher()
        hasher.combine(storage.string)
        for run in runs(in: storage, range: NSRange(location: 0, length: storage.length)) {
            hasher.combine(run.range.location)
            hasher.combine(run.range.length)
            hasher.combine(run.blockID)
        }
        return hasher.finalize()
    }
}

#endif
