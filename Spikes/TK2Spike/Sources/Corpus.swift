// TK2Spike — deterministic 50k-word corpus generator (throwaway; Phase 6).
//
// Shapes per the phase plan: paragraph-shaped, mixed paragraph lengths, a few very
// long paragraphs (the shapes journals/books actually have), plus occasional
// markdown-heading blocks (headings are markdown text in Variorum, AppSpec §14.8).
// Every paragraph carries a block-ID-like custom attribute — the real editor rides
// custom attributes (AppSpec §4), so every fact is measured with them present.

import AppKit

struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

enum Corpus {
    static let blockIDKey = NSAttributedString.Key("dev.variorum.spike.blockID")
    static let defaultSeed: UInt64 = 0x50_4B_32_53_50_49_4B_45  // "PK2SPIKE"

    struct Built {
        let attributed: NSAttributedString
        /// UTF-16 offset of each paragraph start (paragraph == spike "block").
        let paragraphStarts: [Int]
        let wordCount: Int
        let charCount: Int   // UTF-16 length
        let paragraphCount: Int
        let buildMS: Double

        func paragraphIndex(forOffset offset: Int) -> Int {
            // Last start <= offset (binary search).
            var lo = 0, hi = paragraphStarts.count - 1
            while lo < hi {
                let mid = (lo + hi + 1) / 2
                if paragraphStarts[mid] <= offset { lo = mid } else { hi = mid - 1 }
            }
            return lo
        }
    }

    private static let vocabulary: [String] = [
        "the", "a", "of", "and", "to", "in", "she", "wrote", "block", "variant",
        "paragraph", "sentence", "morning", "notebook", "quiet", "draft", "again",
        "keeps", "open", "choices", "lineage", "pointer", "graph", "reading",
        "chapter", "journal", "yesterday", "slowly", "beautiful", "structure",
        "text", "editor", "window", "light", "coffee", "harbor", "letters",
        "unfinished", "deliberate", "永続", "café", "naïve", "threshold",
        "interdisciplinary", "counterintuitively", "meandering", "verisimilitude",
        "small", "held", "aside", "twice", "returned", "margin", "afternoon",
        "certainty", "doubt", "revision", "fan", "commit", "prose",
    ]

    static func build(seed: UInt64 = defaultSeed, targetWords: Int = 50_000) -> Built {
        let t0 = nowMS()
        var rng = SplitMix64(seed: seed)
        let result = NSMutableAttributedString()
        var paragraphStarts: [Int] = []
        var words = 0
        var paragraphIndex = 0
        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.textColor,
        ]

        func sentence(_ rng: inout SplitMix64, words wordTarget: Int) -> String {
            var parts: [String] = []
            for i in 0..<wordTarget {
                var w = vocabulary[Int.random(in: 0..<vocabulary.count, using: &rng)]
                if i == 0 { w = w.prefix(1).uppercased() + w.dropFirst() }
                if i != wordTarget - 1, Int.random(in: 0..<12, using: &rng) == 0 { w += "," }
                parts.append(w)
            }
            return parts.joined(separator: " ") + "."
        }

        while words < targetWords {
            var paragraph: String
            var paragraphWords = 0
            if paragraphIndex % 37 == 20 {
                // Heading-like block (markdown heading text, short, no period).
                let n = Int.random(in: 3...6, using: &rng)
                var parts: [String] = ["##"]
                for _ in 0..<n {
                    parts.append(vocabulary[Int.random(in: 0..<vocabulary.count, using: &rng)])
                }
                paragraph = parts.joined(separator: " ")
                paragraphWords = n
            } else {
                let target: Int
                if paragraphIndex % 150 == 120 {
                    target = Int.random(in: 1_800...2_200, using: &rng)  // the very long ones
                } else {
                    switch Int.random(in: 0..<10, using: &rng) {
                    case 0: target = Int.random(in: 20...40, using: &rng)
                    case 1, 2: target = Int.random(in: 120...260, using: &rng)
                    default: target = Int.random(in: 40...120, using: &rng)
                    }
                }
                var sentences: [String] = []
                while paragraphWords < target {
                    let n = Int.random(in: 6...18, using: &rng)
                    sentences.append(sentence(&rng, words: n))
                    paragraphWords += n
                }
                paragraph = sentences.joined(separator: " ")
            }

            var attrs = baseAttrs
            attrs[blockIDKey] = String(format: "blk-%06d", paragraphIndex)
            if paragraphIndex > 0 {
                result.append(NSAttributedString(string: "\n", attributes: attrs))
            }
            paragraphStarts.append(result.length)
            result.append(NSAttributedString(string: paragraph, attributes: attrs))
            words += paragraphWords
            paragraphIndex += 1
        }

        return Built(
            attributed: result,
            paragraphStarts: paragraphStarts,
            wordCount: words,
            charCount: result.length,
            paragraphCount: paragraphIndex,
            buildMS: nowMS() - t0
        )
    }
}
