//
//  BookReadMintTests.swift
//  VariorumTests — the VX-1036 run, batch 2, P7 (ledger row 15): which book modes turn a mint door's note to the
//  Outline so it lands live. The source pin (`BookReadMintSourceTests`) holds that the one mint act asks this rule at
//  the press; this holds the rule.
//

import Testing
@testable import Variorum

@MainActor
@Suite("VX-1036 P7 — the modes a mint turns to the Outline")
struct BookReadMintTests {
    @Test func onlyReadTurnsToTheOutline() {
        #expect(BookReadMint.turnsToOutline(.read), "Read mounts no editor — the note lands live on the Outline")
        for mode in [BookStructureModel.ViewMode.outline, .index, .spread] {
            #expect(!BookReadMint.turnsToOutline(mode), "\(mode) lands a minted note its own way (batch 1's arrival)")
        }
    }
}
