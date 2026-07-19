import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A2 — `version_of` (the KnownIssues op) and the two copy
/// operations (the spike's round-5/6 rulings). The load-bearing pins: the
/// canonical (min,max) storage both input orders; the post-level peer
/// traversal; the two copy ops differing in EXACTLY one thing (where the
/// copy's chosen comes from); adopt atomic + compound-undoable; nothing
/// touching the source or its lenses.
@Suite("version_of + the copy operations (Phase 11, A2)")
struct VersionOperationsTests {
    // MARK: - version_of

    @Test func versionOfStoresCanonicallyBothInputOrders() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let b1 = try ops.newBlock(in: post.id, text: "one", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "two", at: .end).block
            let (low, high) = b1.id < b2.id ? (b1.id, b2.id) : (b2.id, b1.id)

            // Input order reversed from canonical — storage still (min, max).
            let edge = try ops.markVersionOf(high, low)
            #expect(edge.sourceBlockId == low)
            #expect(edge.targetBlockId == high)
            #expect(edge.type == .versionOf)
            #expect(edge.originOp == "manual")

            // Either orientation is the SAME relationship: re-marking
            // refuses; peers read symmetric.
            #expect(throws: OperationError.versionLinkExists(a: low, b: high)) {
                _ = try ops.markVersionOf(low, high)
            }
            let (peers1, peers2) = try db.read { database in
                (try Queries.versionPeers(database, of: b1.id),
                 try Queries.versionPeers(database, of: b2.id))
            }
            #expect(peers1 == [b2.id])
            #expect(peers2 == [b1.id])

            // Self-links refuse; un-marking tombstones; re-marking after
            // un-marking re-creates freshly (live-unique class).
            #expect(throws: OperationError.cannotVersionLinkBlockToItself(id: b1.id)) {
                _ = try ops.markVersionOf(b1.id, b1.id)
            }
            try ops.removeVersionOf(low, high)
            #expect(try db.deletedAt("edge", edge.id) != nil)
            // Round 1 NIT: un-marking a link that does NOT exist says so —
            // never the inverted "already exists".
            #expect(throws: OperationError.versionLinkNotFound(a: low, b: high)) {
                try ops.removeVersionOf(low, high)
            }
            let fresh = try ops.markVersionOf(low, high)
            #expect(fresh.id != edge.id)
        }
    }

    @Test func markPostsAsVersionsAnchorsTheFirstBlocksAndThePeerTraversalFindsThem() throws {
        try withOperations { ops, db in
            let a = try ops.createPost(title: "article v1", profile: .blog)
            let aFirst = try ops.newBlock(in: a.id, text: "A first.", at: .end).block
            _ = try ops.newBlock(in: a.id, text: "A second.", at: .end)
            let b = try ops.createPost(title: "article v2", profile: .blog)
            let bFirst = try ops.newBlock(in: b.id, text: "B first.", at: .end).block

            let edge = try ops.markPostsAsVersions(a.id, b.id)
            let pair = Set([edge.sourceBlockId, edge.targetBlockId])
            #expect(pair == Set([aFirst.id, bFirst.id]), "the anchor is the first block pair")

            let (peersA, peersB) = try db.read { database in
                (try Queries.versionPeerPosts(database, of: a.id),
                 try Queries.versionPeerPosts(database, of: b.id))
            }
            #expect(peersA == [b.id])
            #expect(peersB == [a.id])

            #expect(throws: OperationError.postsAlreadyVersionLinked(a: a.id, b: b.id)) {
                _ = try ops.markPostsAsVersions(a.id, b.id)
            }

            let empty = try ops.createPost(title: "blockless", profile: .blog)
            #expect(throws: OperationError.postHasNoBlocks(id: empty.id)) {
                _ = try ops.markPostsAsVersions(a.id, empty.id)
            }
        }
    }

    // MARK: - The copy world (shared fixture)

    private struct World {
        let postID: String
        let block1: String
        let block2: String
        let chosen1: String
        let alt1: String
        let lensID: String
    }

    /// Two blocks; block 1 fanned (chosen + alt, alt archived-sibling too),
    /// a lens picking the alt on block 1; block names and spacing set so
    /// the copies can be compared row-level.
    private func makeWorld(_ ops: Operations, _ db: AppDatabase) throws -> World {
        let post = try ops.createPost(title: "the article", profile: .blog)
        let minted1 = try ops.newBlock(in: post.id, text: "Take one.", at: .end)
        let minted2 = try ops.newBlock(in: post.id, text: "Steady second block.", at: .end)
        try ops.setBlockName(minted1.block.id, name: "opener")
        let alt = try ops.branchVariant(minted1.block.id, from: minted1.variant.id)
        try ops.autosave(alt.id, text: "Take two, bolder.", charDelta: 8)
        let archived = try ops.branchVariant(minted1.block.id, from: minted1.variant.id)
        try ops.archiveVariant(archived.id)
        let lens = try ops.createLens(post: post.id, name: "bolder thread")
        _ = try ops.setLensChoice(lens: lens.id, block: minted1.block.id, variant: alt.id)
        return World(
            postID: post.id, block1: minted1.block.id, block2: minted2.block.id,
            chosen1: minted1.variant.id, alt1: alt.id, lensID: lens.id)
    }

    @Test func duplicateAsVersionCopiesThePostExactlyAsItIs() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let result = try ops.duplicateAsVersion(w.postID)

            // The copy renders byte-identically to the source (its own
            // chosen — the lens is IGNORED).
            let sourceText = try db.read { try Queries.renderedText($0, containerID: w.postID) }
            let copyText = try db.read { try Queries.renderedText($0, containerID: result.post.id) }
            #expect(copyText == sourceText)
            #expect(copyText.hasPrefix("Take one."), "duplicate follows chosen, never the lens")

            // Container row: verbatim identity fields, never born locked.
            #expect(result.post.title == "the article")
            #expect(result.post.profile == .blog)
            #expect(result.post.locked == false)

            // Whole fans ride, statuses preserved, commits never copied,
            // block names copied.
            let copyBlock1 = result.blockCopies[0].copy
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [copyBlock1]) == 3, "chosen + alt + archived all ride")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND status = 'archived'",
                [copyBlock1]) == 1, "statuses preserved")
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM commit_point cp
                JOIN variant v ON v.id = cp.variant_id WHERE v.block_id = ?
                """, [copyBlock1]) == 0, "commits never copied")
            #expect(try db.fetchString(
                "SELECT name FROM block WHERE id = ?", [copyBlock1]) == "opener")

            // Lineage: derived_from per block + ONE version_of anchor; the
            // post-level peers see each other.
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM edge WHERE type = 'derived_from'
                AND deleted_at IS NULL AND origin_op = 'manual'
                """) == 2)
            let peerPosts = try db.read { try Queries.versionPeerPosts($0, of: w.postID) }
            #expect(peerPosts == [result.post.id])

            // Lenses never ride; the source and its lens are untouched.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM lens WHERE container_id = ?", [result.post.id]) == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM lens WHERE container_id = ? AND deleted_at IS NULL",
                [w.postID]) == 1)
            #expect(try db.deletedAt("container", w.postID) == nil)
        }
    }

    @Test func promoteLensDiffersFromDuplicateInExactlyTheChosenPointers() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let duplicated = try ops.duplicateAsVersion(w.postID)
            let promoted = try ops.promoteLens(w.lensID)

            // THE ONE DIFFERENCE: what the copy renders.
            let dupText = try db.read { try Queries.renderedText($0, containerID: duplicated.post.id) }
            let promText = try db.read { try Queries.renderedText($0, containerID: promoted.post.id) }
            #expect(dupText.hasPrefix("Take one."))
            #expect(promText.hasPrefix("Take two, bolder."), "promote's chosen := the lens's picks")
            #expect(dupText.hasSuffix("Steady second block."))
            #expect(promText.hasSuffix("Steady second block."),
                    "un-overridden slots follow the source's chosen in BOTH")

            // EVERYTHING ELSE equal: same fan shapes, same names, same
            // container identity fields, same edge counts.
            for (dup, prom) in zip(duplicated.blockCopies, promoted.blockCopies) {
                let dupFan = try db.fetchInt(
                    "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    [dup.copy])
                let promFan = try db.fetchInt(
                    "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    [prom.copy])
                #expect(dupFan == promFan, "fans ride promote by default — identical shape")
                #expect(try db.fetchString("SELECT name FROM block WHERE id = ?", [dup.copy])
                        == (try db.fetchString("SELECT name FROM block WHERE id = ?", [prom.copy])))
            }
            #expect(duplicated.post.title == promoted.post.title)
            #expect(duplicated.post.profile == promoted.post.profile)

            // The lens and the source survive promote untouched.
            #expect(try db.deletedAt("lens", w.lensID) == nil)
            let sourceText = try db.read { try Queries.renderedText($0, containerID: w.postID) }
            #expect(sourceText.hasPrefix("Take one."), "the original's chosen never moves")
        }
    }

    @Test func promoteFollowsTheSourcesRechosenSlotWhereTheLensIsSilent() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            // Block 2 gains a second take the author ✓-chose — chosen ≠
            // default now, and the lens is SILENT on block 2. The sparse
            // effective-picks map must fall through to the source slot's
            // CHOSEN, not to nil (which the read-time fallback renders as
            // the copy's default — the wrong text).
            let base2 = try #require(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block2]))
            let rechosen = try ops.branchVariant(w.block2, from: base2)
            try ops.autosave(rechosen.id, text: "Rewritten second block.", charDelta: 10)
            try ops.chooseVariant(w.block2, variantID: rechosen.id)

            let promoted = try ops.promoteLens(w.lensID)
            let text = try db.read { try Queries.renderedText($0, containerID: promoted.post.id) }
            #expect(text.hasSuffix("Rewritten second block."),
                    "a lens-silent slot follows the source's CHOSEN, never its default")
            let copyBlock2 = promoted.blockCopies[1].copy
            let copyChosen = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [copyBlock2])
            #expect(copyChosen != nil, "the copy carries a real chosen pointer, not a nil fallback")
        }
    }

    @Test func chosenOnlyPromoteMaterializesSingleVariantBlocks() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let promoted = try ops.promoteLens(w.lensID, carryFans: false)

            let copyBlock1 = promoted.blockCopies[0].copy
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ?", [copyBlock1]) == 1,
                    "chosen-only: exactly the take the lens shows")
            let text = try db.read { try Queries.renderedText($0, containerID: promoted.post.id) }
            #expect(text.hasPrefix("Take two, bolder."))
        }
    }

    // MARK: - The taste-checkpoint gestures (Sitting 9 — R78/R80/R89/R92)

    /// The test clock's day rendered exactly as the op renders it (local
    /// zone — "chosen until" wants HER calendar day, so the test derives
    /// the expectation instead of pinning a zone).
    private static var testClockDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: 1_782_864_000))
    }

    @Test func adoptSwapAdoptsTheLensAndPreservesTheOutgoingChosenAsALens() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let preservation = try ops.adoptLensPreservingChosen(w.lensID)

            // The adopt half: block 1's chosen moved to the lens's pick.
            let chosen1 = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block1])
            #expect(chosen1 == w.alt1, "adopt: every effective pick → chosen")

            // The preservation half: a lens named on the test clock's day,
            // whose EXPLICIT picks render the OUTGOING chosen exactly.
            #expect(preservation.name == "chosen until \(Self.testClockDay)")
            #expect(preservation.containerId == w.postID)
            let preservedPick1 = try db.fetchString(
                """
                SELECT variant_id FROM lens_choice
                WHERE lens_id = ? AND block_id = ? AND deleted_at IS NULL
                """, [preservation.id, w.block1])
            #expect(preservedPick1 == w.chosen1, "the OLD chosen is preserved, explicitly")
            let preservedCount = try db.fetchInt(
                "SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
                [preservation.id])
            #expect(preservedCount == 2, "full-fidelity: EVERY renderable slot gets a pick")

            // Swapping back: adopting the preservation lens restores the
            // old arrangement — nothing was destroyed.
            try ops.adoptLens(preservation.id)
            let restored1 = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block1])
            #expect(restored1 == w.chosen1, "promote the old one back — the R89 swap promise")
        }
    }

    @Test func adoptSwapPreservationNamesSuffixOnCollision() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            _ = try ops.createLens(post: w.postID, name: "chosen until \(Self.testClockDay)")
            let first = try ops.adoptLensPreservingChosen(w.lensID)
            #expect(first.name == "chosen until \(Self.testClockDay) (1)")
            let second = try ops.adoptLensPreservingChosen(w.lensID)
            #expect(second.name == "chosen until \(Self.testClockDay) (2)",
                    "increasing integer, first free — R92's letter")
        }
    }

    @Test func promotePicksMakesThePostDirectlyFromSparseViewPicks() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lensesBefore = try db.fetchInt("SELECT COUNT(*) FROM lens") ?? 0

            let result = try ops.promotePicks(post: w.postID, picks: [w.block1: w.alt1])
            let text = try db.read { try Queries.renderedText($0, containerID: result.post.id) }
            #expect(text.hasPrefix("Take two, bolder."), "the pick IS the copy's chosen")
            #expect(text.hasSuffix("Steady second block."), "un-picked slots follow the source's chosen")

            // Direct: NO lens was minted anywhere (R78 — the forced
            // save-as-lens step is retired).
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens") == lensesBefore)

            // A stale pick (not a take of its block) falls through, never throws.
            let lenient = try ops.promotePicks(post: w.postID, picks: [w.block1: "no-such-take"])
            let lenientText = try db.read { try Queries.renderedText($0, containerID: lenient.post.id) }
            #expect(lenientText.hasPrefix("Take one."), "invalid view picks resolve like un-picked slots")
        }
    }

    @Test func branchAllFansWithoutALensMintsTakesAndReturnsPicksOnly() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lensesBefore = try db.fetchInt("SELECT COUNT(*) FROM lens") ?? 0
            let fan1Before = try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL", [w.block1]) ?? 0

            let picks = try ops.branchAllFans(post: w.postID)
            #expect(picks.count == 2, "one fresh take per renderable slot")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens") == lensesBefore,
                    "the unnamed column needs NO lens row")
            let fan1After = try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL", [w.block1])
            #expect(fan1After == fan1Before + 1)
            // Each minted take inherits the SHOWN text (branch semantics).
            let mintedText = try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [picks[w.block1]])
            #expect(mintedText == "Take one.")

            // The seal refuses fan growth here like everywhere.
            try ops.lockPost(w.postID)
            #expect(throws: OperationError.lockedPost(id: w.postID)) {
                _ = try ops.branchAllFans(post: w.postID)
            }
        }
    }

    @Test func aSealedSourceDuplicatesFineAndTheCopyIsUnsealed() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            try ops.lockPost(w.postID)
            let result = try ops.duplicateAsVersion(w.postID)
            #expect(result.post.locked == false)
            #expect(try db.fetchInt(
                "SELECT locked FROM container WHERE id = ?", [w.postID]) == 1,
                    "the source's seal is untouched")
        }
    }

    @Test func copyUndoTombstonesTheMintRecoverably() throws {
        let undoStack = UndoStack()
        try withOperations { ops0, db in
            let ops = Operations(undoStack: undoStack)
            let w = try makeWorld(ops, db)
            let result = try ops.duplicateAsVersion(w.postID)
            #expect(try db.deletedAt("container", result.post.id) == nil)

            try undoStack.undo(with: ops)

            #expect(try db.deletedAt("container", result.post.id) != nil,
                    "undo tombstones the minted post (recoverable via restoreContainer)")
            for pair in result.blockCopies {
                #expect(try db.deletedAt("block", pair.copy) != nil,
                        "the cascade takes the minted blocks")
            }
            #expect(try db.deletedAt("container", w.postID) == nil, "the source never moves")
            _ = ops0
        }
    }

    // MARK: - adoptLens + branchAllFans

    @Test func adoptLensWritesChosenAtomicallyAndUndoesAsOneCompound() throws {
        let undoStack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: undoStack)
            let w = try makeWorld(ops, db)

            func chosen(_ blockID: String) throws -> String? {
                try db.fetchString(
                    "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    [blockID])
            }
            #expect(try chosen(w.block1) == w.chosen1)

            try ops.adoptLens(w.lensID)
            #expect(try chosen(w.block1) == w.alt1, "the pick became chosen (I3's setter)")

            try undoStack.undo(with: ops)
            #expect(try chosen(w.block1) == w.chosen1, "one compound undo restores the pre-image")
        }
    }

    @Test func adoptLensRefusesUnderASealAndViewingNeverWroteChosen() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            try ops.lockPost(w.postID)
            #expect(throws: OperationError.lockedPost(id: w.postID)) {
                try ops.adoptLens(w.lensID)
            }
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [w.block1]) == w.chosen1)
        }
    }

    @Test func branchAllFansMintsATakePerSlotIntoAFreshLens() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let thread = try ops.branchAllFans(post: w.postID, lensName: "new thread")

            let picks = try db.read { try Queries.lensChoices($0, lens: thread.id) }
            #expect(picks.count == 2, "every renderable slot got a pick")
            for (blockID, variantID) in picks {
                let parent = try db.fetchString(
                    "SELECT parent_variant_id FROM variant WHERE id = ?", [variantID])
                let shown = blockID == w.block1 ? w.chosen1 : parent
                #expect(parent == shown, "each take branches from what the slot showed")
                let text = try db.fetchString(
                    "SELECT working_text FROM variant WHERE id = ?", [variantID])
                let parentText = try db.fetchString(
                    "SELECT working_text FROM variant WHERE id = ?", [parent!])
                #expect(text == parentText, "branch inherits the buffer (the default gesture)")
            }
            // The post's chosen pointers never moved (visible ≠ chosen).
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [w.block1]) == w.chosen1)

            // Sealed refuses (fan growth).
            try ops.lockPost(w.postID)
            #expect(throws: OperationError.lockedPost(id: w.postID)) {
                _ = try ops.branchAllFans(post: w.postID, lensName: "too late")
            }
        }
    }
}

// MARK: - Review round 1, MINOR 4: no physical deletes, no phantom outbox
// rows. Red-on-old: the pre-fix copyPost inserted the block (outbox
// capture fired) then hard-DELETEd it (no capture) — a permanent phantom
// entry the push drain could never clear.

@Suite("copyPost never strands a phantom outbox row (Phase 11, round 1 MINOR 4)")
struct CopyPostPhantomOutboxTests {
    @Test func aGapSlotCopiesAsNothingWithoutMintingOrDeleting() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let healthy = try ops.newBlock(in: post.id, text: "Healthy slot.", at: .end)
            let doomed = try ops.newBlock(in: post.id, text: "Loses its takes.", at: .end)
            // Force the SyncSpec §5 gap state (a live block with zero live
            // variants) BELOW the ops layer — the sync-race window the
            // surrounding code explicitly tolerates.
            try db.write { database in
                try database.execute(
                    sql: "UPDATE variant SET deleted_at = '2026-01-01T00:00:00.000Z' WHERE block_id = ?",
                    arguments: [doomed.block.id])
            }
            try db.clearOutbox()

            let copy = try ops.duplicateAsVersion(post.id)

            #expect(copy.blockCopies.map(\.source) == [healthy.block.id],
                    "the gap slot copied as nothing")
            // EVERY outbox block row references a block that exists — no
            // phantom from an insert-then-delete.
            let phantoms = try db.read { database in
                try Int.fetchOne(database, sql: """
                    SELECT COUNT(*) FROM sync_outbox o
                    WHERE o.table_name = 'block'
                      AND NOT EXISTS (SELECT 1 FROM block b WHERE b.id = o.row_id)
                    """)
            }
            #expect(phantoms == 0,
                    "no outbox entry for a nonexistent block (S2: the ops layer never physically deletes)")
            // And the ops layer's standing invariant directly: every block
            // row ever minted still exists.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block") == 3,
                    "source pair + the one healthy copy — nothing inserted-and-deleted")
        }
    }
}
