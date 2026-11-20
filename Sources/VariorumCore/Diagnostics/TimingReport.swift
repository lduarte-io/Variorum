//
//  TimingReport.swift
//  VariorumCore
//
//  VM-65 (the VM-64 run, batch 1) — THE READOUT'S TEXT. One plain-text
//  rendering serves both the screen and the Copy button, so what she pastes to
//  a session is exactly what she read (the edit trace's precedent,
//  `MobileEditTrace.transcript`).
//
//  Pure: the caller hands in its labels (the face's words — DRAFT until her
//  wording pass) and the statistics; this lays them out. Two lines per entry,
//  because a phone is about fifty monospaced characters wide:
//
//      Tap the box → keyboard up
//        n 12 · median 312 ms · 188–940 ms · last 301 ms
//
//  Numbers only come from the record; the only words are the caller's labels.
//

import Foundation

public enum TimingReport {
    public enum Unit: Sendable, Equatable {
        /// Milliseconds (a span).
        case milliseconds
        /// A plain number (a per-act count, rows).
        case count
    }

    /// One entry: a label and its statistics (nil — never run).
    public struct Line: Sendable, Equatable {
        public var label: String
        public var stats: TimingStats?
        public var unit: Unit

        public init(_ label: String, _ stats: TimingStats?, unit: Unit) {
            self.label = label
            self.stats = stats
            self.unit = unit
        }
    }

    /// One total: a label and a number.
    public struct Total: Sendable, Equatable {
        public var label: String
        public var value: Int

        public init(_ label: String, _ value: Int) {
            self.label = label
            self.value = value
        }
    }

    public struct Section: Sendable, Equatable {
        public var heading: String
        public var lines: [Line]
        public var totals: [Total]

        public init(_ heading: String, lines: [Line] = [], totals: [Total] = []) {
            self.heading = heading
            self.lines = lines
            self.totals = totals
        }
    }

    /// The whole readout: a title line, the header lines (the build, what the
    /// numbers cover), each section, then the footer lines.
    public static func text(
        title: String, header: [String] = [], sections: [Section], footer: [String] = []
    ) -> String {
        var out = title + "\n"
        for line in header { out += line + "\n" }
        for section in sections {
            out += "\n" + section.heading + "\n"
            for line in section.lines {
                out += line.label + "\n"
                out += "  " + summary(line.stats, unit: line.unit) + "\n"
            }
            for total in section.totals {
                out += total.label + "  " + String(total.value) + "\n"
            }
        }
        if !footer.isEmpty {
            out += "\n"
            for line in footer { out += line + "\n" }
        }
        return out
    }

    /// `n 12 · median 312 ms · 188–940 ms · last 301 ms`; `n 120 (last 64) · …`
    /// once the ring has wrapped (the median and range are over the samples it
    /// still holds); `no runs yet` before the first.
    public static func summary(_ stats: TimingStats?, unit: Unit) -> String {
        guard let stats, stats.count > 0,
              let median = stats.median, let low = stats.minimum, let high = stats.maximum,
              let last = stats.last
        else { return "no runs yet" }
        let suffix = unit == .milliseconds ? " ms" : ""
        var n = "n \(stats.count)"
        if stats.count > stats.retainedCount { n += " (last \(stats.retainedCount))" }
        let range = low == high
            ? number(low, unit) + suffix
            : number(low, unit) + "–" + number(high, unit) + suffix
        return [
            n,
            "median " + number(median, unit) + suffix,
            range,
            "last " + number(last, unit) + suffix,
        ].joined(separator: " · ")
    }

    /// Milliseconds under 10 keep one decimal (a frame is 8–16 ms, and 4.2
    /// against 6.8 matters); everything else is whole. Counts are whole unless
    /// a median of an even run lands on a half.
    ///
    /// **Bounded before it is converted** (VM-64 ladder round 3, finding 5(b)):
    /// `Int(_:)` traps past `Int`'s range, and a value that large can come only
    /// from a damaged timing file, so a value past ±`drawnBound` is drawn at the
    /// bound, and a NaN (an infinite run's median) as 0.
    public static func number(_ value: Double, _ unit: Unit) -> String {
        let value = value.isNaN ? 0 : min(max(value, -drawnBound), drawnBound)
        switch unit {
        case .milliseconds:
            return value < 10 ? oneDecimal(value) : String(Int(value.rounded()))
        case .count:
            return value == value.rounded() ? String(Int(value)) : oneDecimal(value)
        }
    }

    /// The largest magnitude `number` draws — 10¹⁵ (about 31,700 years in
    /// milliseconds), far inside `Int`'s range even as tenths.
    static let drawnBound: Double = 1e15

    private static func oneDecimal(_ value: Double) -> String {
        let tenths = Int((value * 10).rounded())
        return "\(tenths / 10).\(abs(tenths % 10))"
    }
}
