//
//  DiffView.swift
//  Variorum
//
//  Phase 11, Step A4 — the diff view (AppSpec §12): LINE-based over the two
//  rendered texts (the plan's answered interpretation 2 — a display choice,
//  nothing stored; sentence chunking can layer on later), with the
//  whitespace-normalization toggle. Inputs come from `Queries.diffPair`
//  (two takes) or `Queries.renderedText` (two posts) — the view computes at
//  read time and writes NOTHING.
//
//  Swap-and-reread is deliberately NOT a separate build (the plan's A4
//  note): a scratch column IS the swap — visible, not chosen — and ✓/adopt
//  are the commit gestures. Recorded in the closeout so §12's view list
//  stays accounted for.
//

import SwiftUI
import VariorumCore

// MARK: - The pure line diff

nonisolated enum LineDiff {
    enum Kind: Equatable {
        case same, removed, added
    }

    struct Line: Equatable, Identifiable {
        let kind: Kind
        let text: String
        let index: Int
        var id: Int { index }
    }

    /// A classic line-level LCS diff. `normalizeWhitespace` compares lines
    /// with whitespace runs collapsed and edges trimmed (the §12 toggle) —
    /// the DISPLAYED text stays verbatim either way (the view never edits
    /// what it shows).
    static func compute(a: String, b: String, normalizeWhitespace: Bool) -> [Line] {
        let aLines = a.components(separatedBy: "\n")
        let bLines = b.components(separatedBy: "\n")
        func key(_ line: String) -> String {
            guard normalizeWhitespace else { return line }
            return line.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        }
        let aKeys = aLines.map(key)
        let bKeys = bLines.map(key)

        // LCS table (post/block scale — bounded by the inputs' own sizes).
        let n = aKeys.count, m = bKeys.count
        var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in stride(from: n - 1, through: 0, by: -1) {
            for j in stride(from: m - 1, through: 0, by: -1) {
                table[i][j] = aKeys[i] == bKeys[j]
                    ? table[i + 1][j + 1] + 1
                    : max(table[i + 1][j], table[i][j + 1])
            }
        }
        var lines: [Line] = []
        var i = 0, j = 0, index = 0
        func append(_ kind: Kind, _ text: String) {
            lines.append(Line(kind: kind, text: text, index: index))
            index += 1
        }
        while i < n, j < m {
            if aKeys[i] == bKeys[j] {
                append(.same, aLines[i]); i += 1; j += 1
            } else if table[i + 1][j] >= table[i][j + 1] {
                append(.removed, aLines[i]); i += 1
            } else {
                append(.added, bLines[j]); j += 1
            }
        }
        while i < n { append(.removed, aLines[i]); i += 1 }
        while j < m { append(.added, bLines[j]); j += 1 }
        return lines
    }
}

// MARK: - The face

struct DiffView: View {
    let leftTitle: String
    let rightTitle: String
    let leftText: String
    let rightText: String
    @State private var normalizeWhitespace = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Diff — \(leftTitle) → \(rightTitle)").font(.headline)
                Spacer()
                Toggle("Ignore whitespace", isOn: $normalizeWhitespace)
                    .toggleStyle(.checkbox)
                Button("Close") { dismiss() }
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(LineDiff.compute(
                        a: leftText, b: rightText,
                        normalizeWhitespace: normalizeWhitespace)) { line in
                        HStack(alignment: .top, spacing: 6) {
                            Text(marker(line.kind))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(color(line.kind))
                                .frame(width: 14)
                            Text(line.text.isEmpty ? " " : line.text)
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(background(line.kind))
                    }
                }
            }
        }
        .padding(12)
        .frame(minWidth: 560, minHeight: 380)
    }

    private func marker(_ kind: LineDiff.Kind) -> String {
        switch kind {
        case .same: return " "
        case .removed: return "−"
        case .added: return "+"
        }
    }

    private func color(_ kind: LineDiff.Kind) -> Color {
        switch kind {
        case .same: return .secondary
        case .removed: return .red
        case .added: return .green
        }
    }

    private func background(_ kind: LineDiff.Kind) -> Color {
        switch kind {
        case .same: return .clear
        case .removed: return .red.opacity(0.08)
        case .added: return .green.opacity(0.08)
        }
    }
}
