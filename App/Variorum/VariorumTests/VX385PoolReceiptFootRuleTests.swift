//
//  VX385PoolReceiptFootRuleTests.swift
//  VariorumTests
//
//  **VX-385 + VX-355 (the VX-348 run, U4) — when the Pool's foot speaks.**
//  NEW API (fixed-only — removed from the red product); the red-on-old proof
//  is `VX385PoolQuietReceiptTests.swift`. The Library's message-slot order:
//  the Pool's own error first (a refusal, its own overlay), then the one
//  status seam's quiet receipt; else nothing — no reserved blank line.
//

import Testing
@testable import Variorum

@Suite("VX-385 — the Pool's foot slot")
struct VX385PoolReceiptFootRuleTests {
    @Test func theFootSpeaksOnlyAQuietReceiptAndNeverOverTheErrors() {
        #expect(PoolReceiptFoot.shows(error: nil, quietReceipt: true), "a quiet receipt speaks")
        #expect(!PoolReceiptFoot.shows(error: nil, quietReceipt: false), "nothing to say: no foot, no blank line")
        #expect(!PoolReceiptFoot.shows(error: "No books match.", quietReceipt: true),
                "the Pool's own error wins — its slot, as the Library's does")
        #expect(!PoolReceiptFoot.shows(error: "No books match.", quietReceipt: false))
    }
}
