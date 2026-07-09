//
//  TextMetrics.swift
//  Variorum
//
//  Pure text measurements for the status bar (Phase 9d).
//

import Foundation

nonisolated enum TextMetrics {
    /// Unicode-correct word count (`.byWords` enumeration). Cost ∝ the
    /// counted text — callers pass block- or selection-scale strings only
    /// (P1: never the document).
    static func wordCount(_ text: String) -> Int {
        var count = 0
        text.enumerateSubstrings(
            in: text.startIndex..., options: [.byWords, .substringNotRequired]
        ) { _, _, _, _ in count += 1 }
        return count
    }
}
