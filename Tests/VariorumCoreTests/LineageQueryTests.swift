import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Lineage & diff input queries (Phase 4, Step 3)")
struct LineageQueryTests {
    // MARK: - Chains through the real structural ops

    @Test func extractThenDivideBuildsATraversableChain() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Alpha beta. Gamma delta.")
            // Extract the prefix sentence → B (derived_from A, 'extract').
            let extracted = try ops.extract(a.block.id, span: 0..<11)
            // Divide B → B keeps "Alpha", C = "beta." (C derived_from B, 'divide').
            let divided = try ops.divide(extracted.block.id, cut: 5)

            let up = try db.read { try Queries.ancestors($0, of: divided.block.id) }
            #expect(up == [
                Queries.LineageNode(blockID: extracted.block.id, depth: 1),
                Queries.LineageNode(blockID: a.block.id, depth: 2),
            ])

            let down = try db.read { try Queries.descendants($0, of: a.block.id) }
            #expect(down.count == 2)
            #expect(down[0] == Queries.LineageNode(blockID: extracted.block.id, depth: 1))
            #expect(down[1] == Queries.LineageNode(blockID: divided.block.id, depth: 2))
        }
    }

    @Test func diamondPathsCollapseToShortestDepth() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First part. Second part.")
            let divided = try ops.divide(a.block.id, cut: 11)
            // merge(A, C) mints M with edges to both — plus C already derives
            // from A: a diamond (M→A direct, and M→C→A).
            let merged = try ops.merge(a.block.id, divided.block.id)

            let up = try db.read { try Queries.ancestors($0, of: merged.block.id) }
            let byID = Dictionary(uniqueKeysWithValues: up.map { ($0.blockID, $0.depth) })
            #expect(byID[a.block.id] == 1)           // direct edge wins over the 2-hop path
            #expect(byID[divided.block.id] == 1)
            #expect(up.count == 2)
        }
    }

    @Test func depthBoundTruncatesTheWalk() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One. Two. Three. Four.")
            let d1 = try ops.divide(a.block.id, cut: 4)     // A="One."  d1="Two. Three. Four."
            let d2 = try ops.divide(d1.block.id, cut: 4) // d1="Two." d2="Three. Four."
            let d3 = try ops.divide(d2.block.id, cut: 6) // d2="Three." d3="Four."

            let bounded = try db.read { try Queries.ancestors($0, of: d3.block.id, maxDepth: 2) }
            #expect(bounded.map(\.blockID) == [d2.block.id, d1.block.id])
            let full = try db.read { try Queries.ancestors($0, of: d3.block.id) }
            #expect(full.map(\.blockID) == [d2.block.id, d1.block.id, a.block.id])
        }
    }

    // MARK: - Bounded even against impossible graphs

    @Test func aCycleTerminatesAndExcludesTheOrigin() throws {
        // Unreachable through the operations layer; sync debris must never
        // hang a view, so the walk is bounded anyway.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "a")
            let b = try ops.newBlock(in: post.id, text: "b")
            try db.write { db in
                try Fixture.edge(db, id: "e1", source: a.block.id, target: b.block.id)
                try Fixture.edge(db, id: "e2", source: b.block.id, target: a.block.id)
            }
            let up = try db.read { try Queries.ancestors($0, of: a.block.id, maxDepth: 16) }
            #expect(up == [Queries.LineageNode(blockID: b.block.id, depth: 1)])
        }
    }

    // MARK: - Dead endpoints (edges may outlive an endpoint under sync)

    @Test func deadEndpointsAreFilteredButTraversedThrough() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Head. Middle. Tail.")
            let d1 = try ops.divide(a.block.id, cut: 5)     // a="Head." d1="Middle. Tail."
            let d2 = try ops.divide(d1.block.id, cut: 7) // d1="Middle." d2="Tail."
            // Kill the middle block but revive its edges (locally the cascade
            // takes edges with the block; a sync race can leave them live).
            try db.write { db in
                try Fixture.tombstone(db, table: "block", id: d1.block.id)
                try db.execute(
                    sql: "UPDATE edge SET deleted_at = NULL WHERE source_block_id = ? OR target_block_id = ?",
                    arguments: [d1.block.id, d1.block.id])
                // The cascade also tombstoned d2's placement world? No — only
                // d1's own rows; d2 is untouched.
            }
            let up = try db.read { try Queries.ancestors($0, of: d2.block.id) }
            // d1 (dead) is filtered from the projection; A is still reached
            // through it.
            #expect(up == [Queries.LineageNode(blockID: a.block.id, depth: 2)])
        }
    }

    // MARK: - Outline → draft mapping

    @Test func derivedBlocksFiltersDescendantsByContainer() throws {
        try withOperations { ops, db in
            let draft = try ops.createPost()
            let elsewhere = try ops.createPost()
            let outline = try ops.newBlock(in: draft.id, text: "Point one. Point two.")
            let divided = try ops.divide(outline.block.id, cut: 10)
            try ops.moveBlock(divided.block.id, to: elsewhere.id, at: .end)

            let inDraft = try db.read {
                try Queries.derivedBlocks($0, fromOutlineBlock: outline.block.id, inContainer: draft.id)
            }
            #expect(inDraft.isEmpty)
            let moved = try db.read {
                try Queries.derivedBlocks($0, fromOutlineBlock: outline.block.id, inContainer: elsewhere.id)
            }
            #expect(moved.map(\.blockID) == [divided.block.id])
        }
    }

    // MARK: - version_of peers

    @Test func versionPeersMatchEitherSideAndFilterDeadPeers() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "draft one")
            let b = try ops.newBlock(in: post.id, text: "draft two")
            let c = try ops.newBlock(in: post.id, text: "draft three")
            // No operation mints version_of yet (KnownIssues, Phase 11) —
            // rows by fixture, canonically (min, max) as the ops layer will.
            try db.write { db in
                let (s1, t1) = a.block.id < b.block.id ? (a.block.id, b.block.id) : (b.block.id, a.block.id)
                let (s2, t2) = a.block.id < c.block.id ? (a.block.id, c.block.id) : (c.block.id, a.block.id)
                try Fixture.edge(db, id: "v1", source: s1, target: t1, type: "version_of")
                try Fixture.edge(db, id: "v2", source: s2, target: t2, type: "version_of")
            }
            // A degenerate self-edge (sync debris; ops can't mint it) must
            // not report the block as its own peer (review finding).
            try db.write { db in
                try Fixture.edge(db, id: "self", source: a.block.id, target: a.block.id, type: "version_of")
            }
            let peersOfA = try db.read { try Queries.versionPeers($0, of: a.block.id) }
            #expect(Set(peersOfA) == [b.block.id, c.block.id])
            #expect(!peersOfA.contains(a.block.id))
            let peersOfB = try db.read { try Queries.versionPeers($0, of: b.block.id) }
            #expect(peersOfB == [a.block.id])

            // A dead peer disappears; the edge (revived) is ignored.
            try db.write { db in
                try Fixture.tombstone(db, table: "block", id: c.block.id)
                try db.execute(sql: "UPDATE edge SET deleted_at = NULL WHERE id = 'v2'")
            }
            let after = try db.read { try Queries.versionPeers($0, of: a.block.id) }
            #expect(after == [b.block.id])
        }
    }

    // MARK: - Released originals (13f W10b)

    /// Her sitting question, as a query: after a divide-W the original block
    /// is preserved whole and RELEASED, and nothing on the successors pointed
    /// at it. Both successors now name it.
    @Test func aDivideWsSuccessorsNameTheReleasedOriginal() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One alpha. One omega.")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(second.id, text: "Two alpha. Two omega.", charDelta: 0)
            let result = try ops.divideW(a.block.id, cuts: [a.variant.id: 11])

            let origins = try db.read { try Queries.unplacedOrigins($0, inContainer: post.id) }
            #expect(origins[result.first.block.id] == [a.block.id])
            #expect(origins[result.second.block.id] == [a.block.id])
            // …and the original itself is exactly what the safety net lists.
            let unplaced = try db.read { try Queries.unplacedBlocks($0) }
            #expect(unplaced.map(\.blockID) == [a.block.id])
            _ = second
        }
    }

    /// A merge releases BOTH sources, so the merged block names two — sorted,
    /// so the door's pick is the same on every device.
    @Test func aMergedBlockNamesBothReleasedSources() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.newBlock(in: post.id, text: "left")
            let c = try ops.newBlock(in: post.id, text: "right", at: .end)
            let merged = try ops.merge(b.block.id, c.block.id)

            let origins = try db.read { try Queries.unplacedOrigins($0, inContainer: post.id) }
            #expect(origins[merged.block.id] == [b.block.id, c.block.id].sorted())
            #expect(origins.count == 1, "only the merged block has released origins")
        }
    }

    /// The map is a PLACEMENT question, not a lineage one: an ordinary
    /// in-place divide leaves A placed, so neither half offers the door —
    /// and re-placing a released original retires it too (P-2: a door that
    /// can't act isn't rendered).
    @Test func aStillPlacedOriginNeverOffersTheDoor() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First part. Second part.")
            let divided = try ops.divide(a.block.id, cut: 11)  // A survives, placed
            #expect(try db.read {
                try Queries.unplacedOrigins($0, inContainer: post.id)
            }.isEmpty)
            _ = divided

            // Now release A the W way, then place it back into a pool.
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(second.id, text: "Other take.", charDelta: 0)
            let w = try ops.divideW(a.block.id, cuts: [a.variant.id: 6])
            #expect(try db.read {
                try Queries.unplacedOrigins($0, inContainer: post.id)
            }[w.first.block.id] == [a.block.id])

            let pool = try ops.createPool(title: "scraps")
            _ = try ops.placeBlock(a.block.id, in: pool.id, at: .end)
            #expect(try db.read {
                try Queries.unplacedOrigins($0, inContainer: post.id)
            }.isEmpty, "a re-placed original is reachable where it lives — no recovery door")
        }
    }

    // MARK: - Diff inputs

    @Test func diffPairReturnsBothBuffersVerbatim() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "the first  take")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(take2.id, text: "the second take\n", charDelta: 1)
            let pair = try db.read { try Queries.diffPair($0, a.variant.id, take2.id) }
            #expect(pair?.a == "the first  take")   // whitespace untouched —
            #expect(pair?.b == "the second take\n") // normalization is a view toggle
        }
    }

    @Test func diffPairToleratesMissingOrDeadVariants() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "alive")
            let dead = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.deleteVariant(dead.id)
            let deadPair = try db.read { try Queries.diffPair($0, a.variant.id, dead.id) }
            #expect(deadPair == nil)
            let missingPair = try db.read { try Queries.diffPair($0, a.variant.id, "never-arrived") }
            #expect(missingPair == nil)
        }
    }
}
