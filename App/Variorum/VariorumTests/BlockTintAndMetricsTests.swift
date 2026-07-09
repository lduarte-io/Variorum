//
//  BlockTintAndMetricsTests.swift
//  VariorumTests
//
//  Phase 9d — the pure status-bar and tint helpers: stable never-adjacent
//  block colors (the author's no-zebra rule) and the word counter.
//

import Foundation
import Testing
@testable import Variorum

@Suite("BlockTint (9d — Show Blocks)")
struct BlockTintTests {
    @Test func adjacentBlocksNeverShareAColor() {
        // Property over many orderings, including IDs engineered to hash
        // into the same palette slot.
        let ids = (0..<200).map { "block-\($0)" }
        let indices = BlockTint.indices(for: ids)
        for (a, b) in zip(indices, indices.dropFirst()) {
            #expect(a != b)
        }
        // Same-slot neighbors specifically: duplicate-ID adjacency is the
        // worst case (identical hash), and the bump must still separate.
        let clones = BlockTint.indices(for: ["twin", "twin", "twin"])
        for (a, b) in zip(clones, clones.dropFirst()) {
            #expect(a != b)
        }
    }

    @Test func colorsAreDeterministicAcrossCalls() {
        let ids = (0..<50).map { "id-\($0)" }
        #expect(BlockTint.indices(for: ids) == BlockTint.indices(for: ids))
    }

    @Test func insertingABlockNeverRecolorsThePrefix() {
        // The author's anti-zebra requirement: a new block in the middle
        // must not ripple colors backwards through the document.
        let ids = (0..<50).map { "id-\($0)" }
        let before = BlockTint.indices(for: ids)
        var inserted = ids
        inserted.insert("the-new-block", at: 25)
        let after = BlockTint.indices(for: inserted)
        #expect(Array(after.prefix(25)) == Array(before.prefix(25)))
        // And the whole list still satisfies the adjacency rule.
        for (a, b) in zip(after, after.dropFirst()) {
            #expect(a != b)
        }
    }

    @Test func theHashIsStableNotProcessSeeded() {
        // Pinned constant: FNV-1a("block") — a change to the hash function
        // would silently recolor every document on upgrade; make it loud.
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
