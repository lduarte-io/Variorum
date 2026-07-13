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
