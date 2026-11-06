import Foundation

/// **WHAT CHANGED BETWEEN TWO TEXTS, WORD BY WORD — at view time, stored
/// nowhere** (VX-801, the run record `notes/plans/fixes/vx-827-lineage.md`,
/// THE DESIGN MEMO's Commits face and Compare).
///
/// The block's History surface washes a saved moment against the take now
/// ("plain · against now") and Compare sets two or three moments side by side
/// with the changed words washed — removed struck, added washed (her reference
/// shots, the exploration sitting). Both read THIS function.
///
/// **It is OverallModel §8's legal diff and nothing more:** a view-time
/// comparison between two texts that are already identified (two moments of
/// the same block, or a moment and the take's buffer). It never infers block
/// identity, never tracks which words moved (I8/"coarse, not forensic"), and
/// writes nothing — the answer is recomputed every time it is asked.
///
/// ── THE SHAPE OF THE ANSWER ────────────────────────────────────────────────
///
/// Words are compared, not characters (a character diff of prose is
/// word-salad — the reason S5 is conflict-as-variant): a TOKEN is a run of
/// word characters (letters, digits, marks, an apostrophe inside a word), a
/// run of whitespace, or one other character (punctuation, a symbol). The
/// comparison is a shortest edit script over the tokens (Myers), and then one
/// cleanup a reader needs: a plain space standing between two REPLACEMENTS is
/// absorbed into one change, so "slowly becomes" → "starts to become" reads as
/// one struck phrase beside one washed phrase, never as four fragments
/// (`changeCount` counts that as ONE change — her reference's "4 changes
/// since"). A paragraph break is never absorbed: changes in two paragraphs
/// stay two changes.
///
/// Every answer keeps both texts byte for byte: the old side's runs
/// concatenate to `old`, the new side's to `new`, and the unified runs'
/// same+removed / same+added do the same (pinned).
///
/// ── P1 ─────────────────────────────────────────────────────────────────────
///
/// The cost is the two texts' own (a block's moments — never the note's
/// length, never the corpus): a common prefix and suffix are trimmed first,
/// and the edit search past them is BOUNDED by `editBudget` — a pair of texts
/// that differ by more than that many token edits is answered as ONE change
/// spanning the differing middle, which is the truth told coarsely, never a
/// hang (pinned). Memory is O(budget²) at the very worst, transient.
public enum TextCompare {
    public enum Kind: String, Equatable, Sendable {
        case same, removed, added
    }

    /// One run of text with one fate.
    public struct Run: Equatable, Sendable {
        public let kind: Kind
        public let text: String

        public init(_ kind: Kind, _ text: String) {
            self.kind = kind
            self.text = text
        }
    }

    public struct Comparison: Equatable, Sendable {
        /// The OLD text in runs: `.same` and `.removed` (what the newer text
        /// no longer has) — the struck side of Compare.
        public let old: [Run]
        /// The NEW text in runs: `.same` and `.added` — the washed side.
        public let new: [Run]
        /// One reading of both: `.same`, and within each change the removed
        /// words before the added ones — the single pane's "against now".
        public let unified: [Run]
        /// How many separate changes (a replacement, an insertion or a
        /// removal, after the space cleanup) — "N changes since".
        public let changeCount: Int

        public var isIdentical: Bool { changeCount == 0 }

        public init(old: [Run], new: [Run], unified: [Run], changeCount: Int) {
            self.old = old
            self.new = new
            self.unified = unified
            self.changeCount = changeCount
        }
    }

    /// The edit search's bound — the most token edits (Myers' D) it will
    /// look for before answering coarsely. A block rewritten past this is one
    /// change; anything an author compares in practice is far inside it.
    public static let editBudget = 1_000

    /// **The comparison.** Pure; `editBudget` is a parameter so the coarse
    /// arm is pinnable without a megabyte of fixture.
    public static func compare(
        _ old: String, _ new: String, editBudget: Int = TextCompare.editBudget
    ) -> Comparison {
        if old == new {
            let runs = old.isEmpty ? [] : [Run(.same, old)]
            return Comparison(old: runs, new: runs, unified: runs, changeCount: 0)
        }
        let a = tokens(old)
        let b = tokens(new)
        let items = absorbingSpaces(segments(a, b, budget: max(0, editBudget)))
        return answer(items)
    }

    // MARK: - Tokens

    /// The text cut into tokens (see the type's doc): word runs, whitespace
    /// runs, and single other characters. Concatenating them gives the text
    /// back exactly. Internal so the suite can pin the cut.
    static func tokens(_ text: String) -> [String] {
        let chars = Array(text)
        var out: [String] = []
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if isWordCharacter(c) {
                var j = i + 1
                while j < chars.count {
                    if isWordCharacter(chars[j]) {
                        j += 1
                    } else if isApostrophe(chars[j]), j + 1 < chars.count,
                              isWordCharacter(chars[j + 1]) {
                        // An apostrophe INSIDE a word ("don't", "author’s")
                        // belongs to it.
                        j += 2
                    } else {
                        break
                    }
                }
                out.append(String(chars[i..<j]))
                i = j
            } else if c.isWhitespace {
                var j = i + 1
                while j < chars.count, chars[j].isWhitespace { j += 1 }
                out.append(String(chars[i..<j]))
                i = j
            } else {
                out.append(String(c))
                i += 1
            }
        }
        return out
    }

    private static func isWordCharacter(_ c: Character) -> Bool {
        c.isLetter || c.isNumber || c.unicodeScalars.allSatisfy {
            $0.properties.generalCategory == .nonspacingMark
                || $0.properties.generalCategory == .spacingMark
                || $0.properties.generalCategory == .enclosingMark
                || $0.properties.generalCategory == .connectorPunctuation
        }
    }

    private static func isApostrophe(_ c: Character) -> Bool {
        c == "'" || c == "\u{2019}"
    }

    // MARK: - The edit script

    /// One stretch of the answer before runs are drawn: words both texts
    /// share, or one change (what left · what arrived; either may be empty).
    enum Segment: Equatable {
        case same(String)
        case change(removed: String, added: String)
    }

    /// The tokens' shortest edit script, as segments: a trimmed common
    /// prefix and suffix around a bounded Myers search of the middle.
    static func segments(_ a: [String], _ b: [String], budget: Int) -> [Segment] {
        // Intern the tokens so the search compares integers, not strings.
        var ids: [String: Int] = [:]
        func id(_ token: String) -> Int {
            if let known = ids[token] { return known }
            let next = ids.count
            ids[token] = next
            return next
        }
        let x = a.map(id)
        let y = b.map(id)

        var prefix = 0
        while prefix < x.count, prefix < y.count, x[prefix] == y[prefix] { prefix += 1 }
        var suffix = 0
        while suffix < x.count - prefix, suffix < y.count - prefix,
              x[x.count - 1 - suffix] == y[y.count - 1 - suffix] {
            suffix += 1
        }
        let xm = Array(x[prefix..<(x.count - suffix)])
        let ym = Array(y[prefix..<(y.count - suffix)])

        var builder = SegmentBuilder()
        builder.same(a[0..<prefix].joined())

        if let ops = myers(xm, ym, budget: budget) {
            for op in ops {
                switch op {
                case .equal(let i, _): builder.same(a[prefix + i])
                case .delete(let i): builder.removed(a[prefix + i])
                case .insert(let j): builder.added(b[prefix + j])
                }
            }
        } else {
            // Past the budget: the differing middle, said as ONE change —
            // coarse, true, and bounded (P1).
            builder.removed(a[prefix..<(a.count - suffix)].joined())
            builder.added(b[prefix..<(b.count - suffix)].joined())
        }

        builder.same(a[(a.count - suffix)...].joined())
        return builder.segments
    }

    private struct SegmentBuilder {
        var segments: [Segment] = []

        mutating func same(_ text: String) {
            guard !text.isEmpty else { return }
            if case .same(let prior) = segments.last {
                segments[segments.count - 1] = .same(prior + text)
            } else {
                segments.append(.same(text))
            }
        }

        mutating func removed(_ text: String) {
            guard !text.isEmpty else { return }
            if case .change(let r, let a) = segments.last {
                segments[segments.count - 1] = .change(removed: r + text, added: a)
            } else {
                segments.append(.change(removed: text, added: ""))
            }
        }

        mutating func added(_ text: String) {
            guard !text.isEmpty else { return }
            if case .change(let r, let a) = segments.last {
                segments[segments.count - 1] = .change(removed: r, added: a + text)
            } else {
                segments.append(.change(removed: "", added: text))
            }
        }
    }

    enum Op: Equatable {
        case equal(Int, Int)
        case delete(Int)
        case insert(Int)
    }

    /// Myers' O((N+M)·D) shortest edit script, D ≤ `budget` — nil past it.
    /// The per-step frontiers are kept (only their live diagonals, 2d+1 each)
    /// for the walk back.
    static func myers(_ a: [Int], _ b: [Int], budget: Int) -> [Op]? {
        let n = a.count
        let m = b.count
        if n == 0 { return (0..<m).map(Op.insert) }
        if m == 0 { return (0..<n).map(Op.delete) }
        let maxD = min(n + m, budget)
        let offset = maxD + 1
        var v = [Int](repeating: 0, count: 2 * maxD + 3)
        var trace: [[Int]] = []
        var found: Int?
        search: for d in 0...maxD {
            for k in stride(from: -d, through: d, by: 2) {
                var x: Int
                if k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1]) {
                    x = v[offset + k + 1]
                } else {
                    x = v[offset + k - 1] + 1
                }
                var y = x - k
                while x < n, y < m, a[x] == b[y] {
                    x += 1
                    y += 1
                }
                v[offset + k] = x
                if x >= n, y >= m {
                    trace.append(Array(v[(offset - d)...(offset + d)]))
                    found = d
                    break search
                }
            }
            trace.append(Array(v[(offset - d)...(offset + d)]))
        }
        guard let dFound = found else { return nil }

        var ops: [Op] = []
        var x = n
        var y = m
        if dFound > 0 {
            for d in stride(from: dFound, to: 0, by: -1) {
                let prior = trace[d - 1]
                func at(_ k: Int) -> Int { prior[k + d - 1] }
                let k = x - y
                let priorK = (k == -d || (k != d && at(k - 1) < at(k + 1))) ? k + 1 : k - 1
                let priorX = at(priorK)
                let priorY = priorX - priorK
                while x > priorX, y > priorY {
                    ops.append(.equal(x - 1, y - 1))
                    x -= 1
                    y -= 1
                }
                if x == priorX {
                    ops.append(.insert(y - 1))
                    y -= 1
                } else {
                    ops.append(.delete(x - 1))
                    x -= 1
                }
            }
        }
        while x > 0, y > 0 {
            ops.append(.equal(x - 1, y - 1))
            x -= 1
            y -= 1
        }
        return ops.reversed()
    }

    // MARK: - The cleanup, and the runs

    /// A plain space (no line break) standing between two changes joins them
    /// into one when the joined change still REPLACES words on both sides:
    /// "slowly becomes" → "starts to become" is one struck phrase and one
    /// washed phrase, whichever way the edit script happened to align the
    /// space. Two pure insertions (or two pure removals) around a kept space
    /// are never joined, so a space both texts keep is never struck or washed
    /// on its own; a paragraph break is never absorbed, so two paragraphs'
    /// changes stay two.
    static func absorbingSpaces(_ segments: [Segment]) -> [Segment] {
        var out: [Segment] = []
        var i = 0
        while i < segments.count {
            let segment = segments[i]
            if case .same(let gap) = segment,
               !gap.isEmpty, gap.allSatisfy({ $0.isWhitespace && !$0.isNewline }),
               case .change(let r1, let a1)? = out.last,
               i + 1 < segments.count,
               case .change(let r2, let a2) = segments[i + 1],
               !(r1.isEmpty && r2.isEmpty), !(a1.isEmpty && a2.isEmpty) {
                out[out.count - 1] = .change(removed: r1 + gap + r2, added: a1 + gap + a2)
                i += 2
                continue
            }
            out.append(segment)
            i += 1
        }
        return out
    }

    static func answer(_ segments: [Segment]) -> Comparison {
        var old: [Run] = []
        var new: [Run] = []
        var unified: [Run] = []
        var changes = 0
        func append(_ run: Run, to runs: inout [Run]) {
            guard !run.text.isEmpty else { return }
            if let last = runs.last, last.kind == run.kind {
                runs[runs.count - 1] = Run(run.kind, last.text + run.text)
            } else {
                runs.append(run)
            }
        }
        for segment in segments {
            switch segment {
            case .same(let text):
                append(Run(.same, text), to: &old)
                append(Run(.same, text), to: &new)
                append(Run(.same, text), to: &unified)
            case .change(let removed, let added):
                guard !removed.isEmpty || !added.isEmpty else { continue }
                changes += 1
                append(Run(.removed, removed), to: &old)
                append(Run(.added, added), to: &new)
                append(Run(.removed, removed), to: &unified)
                append(Run(.added, added), to: &unified)
            }
        }
        return Comparison(old: old, new: new, unified: unified, changeCount: changes)
    }
}
