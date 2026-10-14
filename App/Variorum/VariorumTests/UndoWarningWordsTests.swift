//
//  UndoWarningWordsTests.swift
//  VariorumTests (Mac)
//
//  VX-342 (RUN VX-336, U6b) — THE UNDO-OVERWRITE WARNING SPEAKS WITHOUT
//  SHOUTY CAPS. Her rule: rendered text is sentence case, never a word
//  capitalized for emphasis. The A12 warning's detail (the Mac's door,
//  `ShellActions.discardingUndoDetail`) said "…as it was BEFORE the divide…".
//
//  A pure copy pin, in its OWN suite (not appended to
//  `DestructiveUndoWarningTests`, whose `redoNeverAsks` is VX-167's
//  order-dependent pin — a one-suite red run must never meet it). Red on the
//  old words by assertion: the lowercase phrase is absent and "BEFORE" is
//  shouted.
//

import Testing
import VariorumCore
@testable import Variorum

/// The words written all in capitals (two letters or more) — the shouting
/// her rule forbids. A one-letter word ("⌘S"'s S) never counts.
private func shoutedWords(_ text: String) -> [String] {
    text.split(whereSeparator: { !$0.isLetter }).map(String.init)
        .filter { $0.count >= 2 && $0 == $0.uppercased() && $0 != $0.lowercased() }
}

@Suite("VX-342 — the undo-overwrite warning says \"before\", never shouted (the Mac's door)")
struct UndoWarningWordsTests {
    @Test func theWarningsDetailSaysBeforeInLowercaseAndShoutsNothing() {
        for (label, edited) in [("Divide", 1), ("Make Block", 3), ("claude-code's blocks", 1)] {
            let warning = UndoStack.PendingUndoWarning(label: label, bufferCount: edited)
            let detail = ShellActions.discardingUndoDetail(warning)
            #expect(detail.contains("as it was before the \(label.lowercased()),"),
                    "\(label): the detail says \"before\" in lowercase — \(detail)")
            #expect(shoutedWords(detail).isEmpty, "\(label): no shouted word in the detail — \(shoutedWords(detail))")
            // The shared question was already sentence case; held here too.
            #expect(shoutedWords(ShellActions.discardingUndoQuestion(warning)).isEmpty)
        }
    }
}
