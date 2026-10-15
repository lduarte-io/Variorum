//
//  MobileUndoWarningWordsTests.swift
//  VariorumMobileTests
//
//  VX-342 (RUN VX-336, U6b) — THE UNDO-OVERWRITE WARNING SPEAKS WITHOUT
//  SHOUTY CAPS, the phone's door. Her rule: rendered text is sentence case,
//  never a word capitalized for emphasis. The A12 warning's phone detail
//  (`MobileUndoDoor.discardingUndoDetail`) said "…as it was BEFORE the
//  divide…" — the Mac's twin, written per platform because each names its own
//  road.
//
//  A pure copy pin, red on the old words by assertion: the lowercase phrase is
//  absent and "BEFORE" is shouted.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

/// The words written all in capitals (two letters or more) — the shouting
/// her rule forbids.
private func shoutedWords(_ text: String) -> [String] {
    text.split(whereSeparator: { !$0.isLetter }).map(String.init)
        .filter { $0.count >= 2 && $0 == $0.uppercased() && $0 != $0.lowercased() }
}

@MainActor
@Suite("VX-342 — the undo-overwrite warning says \"before\", never shouted (the phone's door)")
struct MobileUndoWarningWordsTests {
    @Test func theWarningsDetailSaysBeforeInLowercaseAndShoutsNothing() {
        for (label, edited) in [("Divide", 1), ("Make Block", 3)] {
            let warning = UndoStack.PendingUndoWarning(label: label, bufferCount: edited)
            let detail = MobileUndoDoor.discardingUndoDetail(warning)
            #expect(detail.contains("as it was before the \(label.lowercased()),"),
                    "\(label): the detail says \"before\" in lowercase — \(detail)")
            #expect(shoutedWords(detail).isEmpty, "\(label): no shouted word in the detail — \(shoutedWords(detail))")
            #expect(shoutedWords(StructuralUndoCopy.discardingUndoQuestion(warning)).isEmpty)
        }
    }
}
