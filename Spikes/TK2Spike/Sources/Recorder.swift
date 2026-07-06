// TK2Spike — measurement recorder (throwaway; Phase 6).
// Named probes -> values; dumped as an aligned table on exit.

import Foundation

@inline(__always) func nowMS() -> Double {
    Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000
}

func fmt(_ v: Double, _ places: Int = 2) -> String {
    String(format: "%.\(places)f", v)
}

/// avg / p50 / p95 / max over a sample set, as one cell.
func stats(_ xs: [Double]) -> String {
    guard !xs.isEmpty else { return "n=0" }
    let sorted = xs.sorted()
    let avg = xs.reduce(0, +) / Double(xs.count)
    let p50 = sorted[Int(Double(sorted.count - 1) * 0.50)]
    let p95 = sorted[Int(Double(sorted.count - 1) * 0.95)]
    return "n=\(xs.count) avg=\(fmt(avg)) p50=\(fmt(p50)) p95=\(fmt(p95)) max=\(fmt(sorted.last!))"
}

final class Recorder {
    static let shared = Recorder()

    struct Row {
        let section: String
        let probe: String
        let value: String
        let unit: String
        let note: String
    }

    private(set) var rows: [Row] = []

    func rec(_ section: String, _ probe: String, _ value: String, _ unit: String = "", note: String = "") {
        rows.append(Row(section: section, probe: probe, value: value, unit: unit, note: note))
        // Live echo so a crash mid-run still leaves the numbers gathered so far.
        print("  [\(section)] \(probe) = \(value)\(unit.isEmpty ? "" : " \(unit)")\(note.isEmpty ? "" : "  (\(note))")")
    }

    func rec(_ section: String, _ probe: String, ms: Double, note: String = "") {
        rec(section, probe, fmt(ms), "ms", note: note)
    }

    func dump() {
        print("\n==================== TK2 SPIKE RESULTS ====================")
        var lastSection = ""
        let probeWidth = rows.map { $0.probe.count }.max() ?? 10
        for row in rows {
            if row.section != lastSection {
                print("\n-- \(row.section) --")
                lastSection = row.section
            }
            let unit = row.unit.isEmpty ? "" : " \(row.unit)"
            let note = row.note.isEmpty ? "" : "   // \(row.note)"
            print("\(row.probe.padding(toLength: max(probeWidth, row.probe.count), withPad: " ", startingAt: 0)) | \(row.value)\(unit)\(note)")
        }
        print("\n===========================================================")
    }
}
