//
//  BookReadMintTests.swift
//  VariorumTests — the VX-1036 run, batch 2, P7 (ledger row 15): which book modes turn a mint door's note to the
//  Outline so it lands live. The source pin (`BookReadMintSourceTests`) holds that the one mint act asks this rule at
//  the press; this holds the rule.
//
//  The VX-1036 ladder, round 1 — N1 (renamed from `onlyReadTurnsToTheOutline`, false since batch 3 put List in the
//  rule) and R1-3 (the Index joins: it makes a note live only by a block landing, and a newborn note has no block).
//

import Testing
@testable import Variorum

@MainActor
@Suite("VX-1036 P7 — the modes a mint turns to the Outline")
struct BookReadMintTests {
    @Test func theModesWithNoWayToMakeANewbornNoteLiveTurnToTheOutline() {
        #expect(BookReadMint.turnsToOutline(.read), "Read mounts no editor — the note lands live on the Outline")
        #expect(BookReadMint.turnsToOutline(.list), "List is rows only, no editor (P-1036-B3-2)")
        #expect(BookReadMint.turnsToOutline(.index),
                "the Index goes live only on a block, and a note born in a book has none yet (R1-3)")
        for mode in [BookStructureModel.ViewMode.outline, .spread] {
            #expect(!BookReadMint.turnsToOutline(mode), "\(mode) lands a minted note its own way (batch 1's arrival)")
        }
        // Every mode is answered: the two that stay plus the three that turn.
        #expect(BookModeTabs.order.filter(BookReadMint.turnsToOutline).count == 3)
    }
}
