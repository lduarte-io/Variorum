//
//  PoolDragTests.swift
//  VariorumTests
//
//  Phase 10 Step 7 — the minimal pool's drag-into-draft: the UI path emits
//  EXACTLY the Phase 3 `poolDragCopy` (fresh block, copied variant(s),
//  `pool_copy` lineage edge, placement at the drop's boundary; commits
//  never copied; P stays in its pool), the drop-point → insertion mapping,
//  the ⌥-carries-the-fan modifier, and the no-text-on-the-pasteboard
//  discipline (review focus 6).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Pool drag (Phase 10 Step 7)")
struct PoolDragTests {
    /// Seeds a pool scrap (with a commit + a second take for the fan
    /// cases) beside the editor's post.
    @MainActor
    private func seedPool(_ h: EditorHarness) throws -> (poolID: String, scrapID: String) {
        let pool = try h.session.operations.createPool(title: "P")
        let scrap = try h.session.operations.newBlock(in: pool.id, text: "a loose idea")
        _ = try h.session.operations.commit(scrap.variant.id, kind: .manual)
        _ = try h.session.operations.branchVariant(scrap.block.id, from: scrap.variant.id)
        return (pool.id, scrap.block.id)
    }

    @Test func aDropEmitsExactlyPoolDragCopy() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let (poolID, scrapID) = try seedPool(h)
            let before = try h.storeSlots()

            // Drop at offset 1 — the first half of "alpha" ⇒ before it.
            let consumed = h.model.poolDrop(blockID: scrapID, atOffset: 1, includeFan: false)
            #expect(consumed)
            await h.settle()
            for _ in 0..<200 {
                if try h.storeSlots().count == 3 { break }
                await Task.yield()
            }

            let after = try h.storeSlots()
            #expect(after.count == 3)
            let copy = after[0]
            #expect(copy.text == "a loose idea")
            #expect(copy.blockID != scrapID, "a COPY — never shared ownership")
            #expect(after[1].blockID == before[0].blockID)

            // Row-level: one pool_copy edge from the copy to the source;
            // commits never copied; the copy carries ONE variant (rendered
            // take only — includeFan false).
            let (edges, commitCount, variantCount, poolSlots) =
                try await h.database.read { [copyID = copy.blockID] db in
                    (try Row.fetchAll(
                        db,
                        sql: "SELECT * FROM edge WHERE source_block_id = ? AND deleted_at IS NULL",
                        arguments: [copyID]),
                     try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM commit_point c
                            JOIN variant v ON v.id = c.variant_id
                            WHERE v.block_id = ?
                            """,
                        arguments: [copyID]) ?? -1,
                     try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                        arguments: [copyID]) ?? -1,
                     try Queries.renderPost(db, containerID: poolID))
                }
            #expect(edges.count == 1)
            #expect(edges[0]["target_block_id"] == scrapID)
            #expect(edges[0]["type"] == "derived_from")
            #expect(edges[0]["origin_op"] == "pool_copy")
            #expect(commitCount == 0, "commits are never copied")
            #expect(variantCount == 1, "includeFan false copies the rendered take only")
            #expect(poolSlots.map(\.blockID) == [scrapID], "P stays in its pool")
        }
    }

    @Test func optionCarriesTheWholeFan() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let (_, scrapID) = try seedPool(h)
            // The modifier rides the callback parameter (the view reads ⌥).
            _ = h.model.poolDrop(
                blockID: scrapID, atOffset: 999, includeFan: true)
            await h.settle()
            for _ in 0..<200 {
                if try h.storeSlots().count == 2 { break }
                await Task.yield()
            }
            let after = try h.storeSlots()
            #expect(after.count == 2)
            let copy = after[1]  // offset past everything ⇒ .end
            let variants = try await h.database.read { [id = copy.blockID] db in
                try Queries.blockFan(db, blockID: id)
            }
            #expect(variants.count == 2, "the whole live fan came along")
        }
    }

    @Test func dropOffsetsMapToBlockBoundaries() async throws {
        try await withEditor(seedBlocks: ["aaaa", "bbbb"]) { h in
            // Document: "aaaa\nbbbb" — entries at 0..<4 and 5..<9.
            let slots = try h.storeSlots()
            let a = slots[0].blockID
            let b = slots[1].blockID
            #expect(h.model.insertPosition(forOffset: 0) == .before(a))
            #expect(h.model.insertPosition(forOffset: 1) == .before(a))
            #expect(h.model.insertPosition(forOffset: 4) == .after(a))
            #expect(h.model.insertPosition(forOffset: 6) == .before(b))
            #expect(h.model.insertPosition(forOffset: 9) == .after(b))
            #expect(h.model.insertPosition(forOffset: 999) == .end)
        }
    }

    @Test func aSealedPostRefusesTheDropVisibly() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let (_, scrapID) = try seedPool(h)
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            let consumed = h.model.poolDrop(blockID: scrapID, atOffset: 0, includeFan: false)
            #expect(consumed, "consumed — never falls through to a text insert")
            #expect(h.model.statusMessage?.contains("sealed") == true)
            await h.settle()
            #expect(try h.storeSlots().count == 1, "nothing landed under the seal")
        }
    }

    @Test func theDragPayloadIsTheBlockIDNeverTheText() async throws {
        let provider = PoolViewModel.dragProvider(blockID: "block-123")
        #expect(provider.registeredTypeIdentifiers
                == [EditorTextView.poolBlockType.rawValue])
        let data: Data = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Data, Error>) in
            _ = provider.loadDataRepresentation(
                forTypeIdentifier: EditorTextView.poolBlockType.rawValue
            ) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data ?? Data())
                }
            }
        }
        #expect(String(data: data, encoding: .utf8) == "block-123",
                "the payload is the ID; the text copy is the operation's (review focus 6)")
    }
}
