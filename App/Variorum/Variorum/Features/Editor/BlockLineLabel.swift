//
//  BlockLineLabel.swift
//  Variorum (Mac)
//
//  13g batch 6 (R5-4) — her morning ruling, verbatim: *"stop showing the
//  actual ID of the block (1R3D9145 as an example), and rather than blk,
//  show 'block 1/1'."*
//
//  The ORDINAL machinery is 9d's and is untouched: the number is derived at
//  read time from the current order, and `block.id` remains the identity
//  (AppSpec §14's 2026-07-09 delta). Only the rendered STRING changes — and
//  it changes in ONE place, because two bottom bars render it (Write's
//  `CommitBar`, Takes' `TakesBottomBar`) and a label she reads in both must
//  not be able to drift between them.
//

import Foundation

nonisolated enum BlockLineLabel {
    /// "block 3/16" — the caret block's place in the note's current order.
    /// `ordinal` is 1-based; nil means the surface knows a block but not yet
    /// where it sits, which reads as an em dash rather than a wrong number.
    static func caret(ordinal: Int?, of count: Int) -> String {
        guard let ordinal else { return "block —" }
        return "block \(ordinal)/\(count)"
    }
}
