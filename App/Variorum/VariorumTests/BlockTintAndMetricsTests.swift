//
//  BlockTintAndMetricsTests.swift
//  VariorumTests
//
//  The pure status-bar helpers + what survives of the 9d tint machinery
//  after Phase 13 C1 retired its look (R6 — dotted seams are the boundary
//  mechanism; no per-block background colors).
//

import Foundation
import Testing
@testable import Variorum

@Suite("BlockTint survivors (Phase 13 C1 retired the tint look)")
struct BlockTintTests {
    // The pastel palette + never-adjacent index machinery retired with the
    // 9d tint LOOK. What survives is pinned here: the stable hash (the
    // lineage stripes' color identity); the container→view mapping keeps
    // its own registration pins in DecorRegistrationTests.

    @Test func theHashIsStableNotProcessSeeded() {
        // Pinned constant: the FNV-1a offset basis — a change to the hash
        // function would silently recolor every lineage stripe on upgrade;
        // make it loud.
        #expect(BlockTint.stableHash("") == 0xcbf2_9ce4_8422_2325)
        #expect(BlockTint.stableHash("a") != BlockTint.stableHash("b"))
    }
}

@Suite("TextMetrics (9d — word counts)")
struct TextMetricsTests {
    @Test func countsWordsAcrossPunctuationAndNewlines() {
        #expect(TextMetrics.wordCount("") == 0)
        #expect(TextMetrics.wordCount("   \n\n ") == 0)
        #expect(TextMetrics.wordCount("One") == 1)
        #expect(TextMetrics.wordCount("One two, three — four.\nFive?") == 5)
    }

    @Test func countsUnicodeProse() {
        #expect(TextMetrics.wordCount("Café noir. Déjà vu.") == 4)
    }
}
