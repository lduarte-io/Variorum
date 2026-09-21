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

    /// **U-19 (1), her word: a note with no blocks yet can be marked as a
    /// version** (ledger row 17; the use report's punchlist 12, image 2).
    /// The post-level link rides a block-level edge (I8 + the schema's
    /// letter), so a blockless post had nothing to anchor on and the op
    /// refused with `postHasNoBlocks` — on a note she had only just made.
    /// It now mints the anchor: ONE ordinary block, ONE live empty take
    /// (I10 satisfied — "live" is about the row, not the characters), placed
    /// at the end, in the SAME transaction as the edge, so the link exists
    /// the moment she asks for it. Nothing about the block is special: the
    /// link's own recovery door removes the LINK and leaves it standing,
    /// which is U-19 (2)'s rule (an empty block stays as an empty paragraph)
    /// applied to a block this op happens to have made.
    @Test func aBlocklessPostGainsAnEmptyAnchorBlockAndTheLinkLands() throws {
        try withOperations { ops, db in
            let a = try ops.createPost(title: "the essay", profile: .blog)
            let aFirst = try ops.newBlock(in: a.id, text: "A first.", at: .end).block
            let fresh = try ops.createPost(title: "the fresh note", profile: .blog)
            #expect(try db.read { try Queries.renderPost($0, containerID: fresh.id) }.isEmpty,
                    "it really has no blocks — the shape that used to refuse")

            let edge = try ops.markPostsAsVersions(a.id, fresh.id)

            let slots = try db.read { try Queries.renderPost($0, containerID: fresh.id) }
            #expect(slots.count == 1, "exactly one block was minted, not two")
            let minted = try #require(slots.first)
            #expect(minted.text == "", "an EMPTY block — U-19 (1)'s letter")
            #expect(minted.activeVariantCount == 1, "one live take on it (I10)")
            #expect(minted.variantID != nil, "and the slot renders it, so it is an ordinary block")

            #expect(Set([edge.sourceBlockId, edge.targetBlockId])
                    == Set([aFirst.id, minted.blockID]),
                    "the edge anchors on the block it just minted")
            let (peersA, peersFresh) = try db.read { database in
                (try Queries.versionPeerPosts(database, of: a.id),
                 try Queries.versionPeerPosts(database, of: fresh.id))
            }
            #expect(peersA == [fresh.id], "the peer traversal finds it at once")
            #expect(peersFresh == [a.id])

            // BOTH sides blockless: two anchors, one edge, no refusal.
            let one = try ops.createPost(title: "one", profile: .blog)
            let two = try ops.createPost(title: "two", profile: .blog)
            _ = try ops.markPostsAsVersions(one.id, two.id)
            for post in [one, two] {
                let made = try db.read { try Queries.renderPost($0, containerID: post.id) }
                #expect(made.count == 1 && made[0].text == "")
            }
            #expect(try db.read { try Queries.versionPeerPosts($0, of: one.id) } == [two.id])

            // The link's recovery door is unchanged and leaves the block —
            // U-19 (2): an empty block is never auto-removed.
            try ops.unmarkPostsAsVersions(a.id, fresh.id)
            #expect(try db.read { try Queries.versionPeerPosts($0, of: a.id) }.isEmpty)
            #expect(try db.read { try Queries.renderPost($0, containerID: fresh.id) }.count == 1,
                    "the block she can now type in stays")

            // The mint is restructuring, not authoring: `last_touched_at`
            // stamps, churn does not (AppSpec §9's structural rule).
            let row = try db.read { database in
                try Row.fetchOne(
                    database,
                    sql: "SELECT last_touched_at, churn_accumulator, last_major_revision_at "
                        + "FROM container WHERE id = ?",
                    arguments: [fresh.id])
            }
            let touched: String? = try #require(row)["last_touched_at"]
            #expect(touched != nil, "a block appeared in the note")
            #expect((try #require(row)["churn_accumulator"] as Double) == 0)
            let major: String? = try #require(row)["last_major_revision_at"]
            #expect(major == nil, "and the meaningful sort is not reshuffled")
        }
    }

    /// **The liveness JOIN, pinned** (17o c/d/e ladder round 2, MINOR-2). The
    /// round-1 NIT-2 fix replaced `markPostsAsVersions`' inline anchor SELECT
    /// with `firstLivePlacedBlock`, which JOINs `block` on liveness where the
    /// inline copy did not — a real behavioural delta in a public operation,
    /// and it shipped with no guard, because none of row 17's three pins ever
    /// puts a tombstoned block under a LIVE placement.
    ///
    /// That state is not hypothetical: it is the doubly-raced sync shape
    /// SyncSpec §5/§7 designs for (rows arrive out of order, and a read must
    /// tolerate a placement whose block has not arrived or has died). Anchoring
    /// a `version_of` edge there would put the post's whole version identity on
    /// a block that renders NOTHING. The post reads as blockless instead, and
    /// U-19 (1)'s road gives it a live empty anchor — which is the same answer
    /// it gives any other blockless post.
    ///
    /// RED ON OLD, and sharper than the finding predicted: the old road did
    /// not anchor a live edge on the dead block — it handed the dead id to
    /// `insertVersionOfEdge`, whose `liveBlock` guard threw
    /// `blockNotFound(id:)`. The old behaviour was a REFUSAL naming a block she
    /// cannot see; the new one is the link she asked for.
    @Test func aLivePlacementOverATombstonedBlockIsNotAnAnchor() throws {
        try withOperations { ops, db in
            let raced = try ops.createPost(title: "the raced note", profile: .blog)
            let dead = try ops.newBlock(in: raced.id, text: "It was here.", at: .end).block
            let peer = try ops.createPost(title: "the peer", profile: .blog)
            let peerFirst = try ops.newBlock(in: peer.id, text: "Peer first.", at: .end).block

            // The race, built exactly: the BLOCK row is tombstoned while its
            // placement stays live. The block cascade tombstones the placement,
            // so the same transaction puts it back — which is the state a
            // half-delivered batch really leaves behind.
            try db.write { database in
                try database.execute(
                    sql: "UPDATE block SET deleted_at = ? WHERE id = ?",
                    arguments: ["2026-07-01T00:00:00.000Z", dead.id])
                try database.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [dead.id])
            }
            let placed = try db.read { database in
                try String.fetchAll(
                    database,
                    sql: "SELECT block_id FROM container_block "
                        + "WHERE container_id = ? AND deleted_at IS NULL",
                    arguments: [raced.id])
            }
            #expect(placed == [dead.id], "the placement is live and points at the dead block")

            let edge = try ops.markPostsAsVersions(raced.id, peer.id)
            let anchor = try #require(
                [edge.sourceBlockId, edge.targetBlockId].first { $0 != peerFirst.id })
            #expect(anchor != dead.id,
                    "a placement over a tombstoned block is not a place to anchor an edge")

            let (live, text, count) = try db.read { database -> (Bool, String?, Int) in
                let alive = try Bool.fetchOne(
                    database,
                    sql: "SELECT deleted_at IS NULL FROM block WHERE id = ?",
                    arguments: [anchor]) ?? false
                let body = try String.fetchOne(
                    database,
                    sql: "SELECT working_text FROM variant "
                        + "WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'",
                    arguments: [anchor])
                let n = try Int.fetchOne(
                    database,
                    sql: "SELECT COUNT(*) FROM variant "
                        + "WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'",
                    arguments: [anchor]) ?? 0
                return (alive, body, n)
            }
            #expect(live, "the anchor is a LIVE block")
            #expect(text == "" && count == 1, "…minted with one live empty take (U-19 (1))")

            let peers = try db.read { try Queries.versionPeerPosts($0, of: raced.id) }
            #expect(peers == [peer.id], "and the link is findable from the raced note")
        }
    }

    /// The same race under a SEAL: the mint arm's `ensureUnlocked` is the
    /// refusal the old road did not have — it anchored on the dead block
    /// silently. Pinned beside the delta it belongs to (round 2, MINOR-2).
    ///
    /// RED ON OLD: `blockNotFound` — the dead id reached
    /// `insertVersionOfEdge`'s `liveBlock` guard before the seal was ever
    /// consulted, so the refusal she got named the wrong thing.
    @Test func theRacedShapeUnderASealRefusesRatherThanAnchoringOnTheDeadBlock() throws {
        try withOperations { ops, db in
            let raced = try ops.createPost(title: "sealed and raced", profile: .blog)
            let dead = try ops.newBlock(in: raced.id, text: "It was here.", at: .end).block
            let peer = try ops.createPost(title: "the peer", profile: .blog)
            _ = try ops.newBlock(in: peer.id, text: "Peer first.", at: .end)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE block SET deleted_at = ? WHERE id = ?",
                    arguments: ["2026-07-01T00:00:00.000Z", dead.id])
                try database.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [dead.id])
            }
            try ops.lockPost(raced.id)

            #expect(throws: OperationError.lockedPost(id: raced.id)) {
                _ = try ops.markPostsAsVersions(raced.id, peer.id)
            }
            #expect(try db.read { try Queries.versionPeerPosts($0, of: raced.id) }.isEmpty,
                    "and nothing was linked on the way to the refusal")
        }
    }

    /// A SEALED blockless post refuses, because minting a block is exactly
    /// what the seal freezes (the everything-under-the-post letter). The
    /// LINK itself stays free under a seal — a sealed post with blocks marks
    /// as a version like any other, the way tagging and adding to a book do.
    @Test func theAnchorMintIsGatedByTheSealButTheLinkItselfIsNot() throws {
        try withOperations { ops, db in
            let sealedBlockless = try ops.createPost(title: "sealed, empty", profile: .blog)
            try ops.lockPost(sealedBlockless.id)
            let other = try ops.createPost(title: "the other", profile: .blog)
            _ = try ops.newBlock(in: other.id, text: "Something.", at: .end)
            #expect(throws: OperationError.lockedPost(id: sealedBlockless.id)) {
                _ = try ops.markPostsAsVersions(sealedBlockless.id, other.id)
            }
            #expect(try db.read { try Queries.renderPost($0, containerID: sealedBlockless.id) }
                        .isEmpty,
                    "and nothing was minted on the way to the refusal")

            let sealedWithBlocks = try ops.createPost(title: "sealed, written", profile: .blog)
            _ = try ops.newBlock(in: sealedWithBlocks.id, text: "Finished.", at: .end)
            try ops.lockPost(sealedWithBlocks.id)
            _ = try ops.markPostsAsVersions(sealedWithBlocks.id, other.id)
            #expect(try db.read { try Queries.versionPeerPosts($0, of: sealedWithBlocks.id) }
                    == [other.id], "the seal freezes authoring, not linking")
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

            // **A JUSTIFIED EDIT (17o batch d, ledger row 17), the claim
            // REPLACED by her ruling U-19 (1):** a blockless post used to
            // refuse the link; it now GAINS its anchor block. The whole
            // shape is pinned in
            // `aBlocklessPostGainsAnEmptyAnchorBlockAndTheLinkLands` below.

            // Sitting 9 (R60/R68): UNMARK removes every cross-post link —
            // the peers stop seeing each other; re-marking works fresh;
            // unmarking again says there's nothing to unmark.
            try ops.unmarkPostsAsVersions(a.id, b.id)
            let peersAfter = try db.read { try Queries.versionPeerPosts($0, of: a.id) }
            #expect(peersAfter.isEmpty, "unmarked — the pair no longer reads as versions")
            #expect(throws: OperationError.versionLinkNotFound(a: a.id, b: b.id)) {
                try ops.unmarkPostsAsVersions(a.id, b.id)
            }
            _ = try ops.markPostsAsVersions(a.id, b.id)
            #expect(try db.read { try Queries.versionPeerPosts($0, of: a.id) } == [b.id],
                    "trivially re-markable — the tags/locks class")
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

    @Test func adoptPicksSwapPreservesThenAdoptsAndSkipsStalePicks() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let preservation = try ops.adoptPicksPreservingChosen(
                post: w.postID, picks: [w.block1: w.alt1, w.block2: "gone-take"])

            let chosen1 = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block1])
            #expect(chosen1 == w.alt1, "the live pick adopted")
            let preservedPick1 = try db.fetchString(
                """
                SELECT variant_id FROM lens_choice
                WHERE lens_id = ? AND block_id = ? AND deleted_at IS NULL
                """, [preservation.id, w.block1])
            #expect(preservedPick1 == w.chosen1, "the outgoing chosen preserved first")

            // The stale pick was skipped, never half-applied.
            let chosen2 = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block2])
            #expect(chosen2 != "gone-take")

            // Swap-back works here too.
            try ops.adoptLens(preservation.id)
            let restored1 = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.block1])
            #expect(restored1 == w.chosen1)
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

// MARK: - 17b P5 (RUN A, batch A1) — an ARCHIVED pick is not a pick

/// **RED ON OLD — `promotePicks` honoured an ARCHIVED pick, which its own
/// docstring says it does not.** The fan read inside `copyPlacements`
/// filters `deleted_at IS NULL` and nothing else, so an archived take was
/// a candidate for `lensShown`; under `carryFans: false` it became the
/// copy's ONLY take (a live, placed block with zero live ACTIVE
/// variants — **I10 at birth**), and under either flag the copy's chosen
/// pointer landed on it, so the words the copy showed were not the words
/// the column showed. The door says *"only what this column shows"* and
/// the view falls through to the slot's chosen when a pick leaves the live
/// active fan (`TakesViewModel.resolvedTake`), so the fix is the operation
/// honouring the contract it already documents: *"a pick naming a take
/// that isn't live on its block falls through harmlessly."*
///
/// DISCRIMINATING REVERT (verified): drop `&& $0.status == .active` from
/// the pick resolution in `copyPlacements` and restore the raw
/// `chosenPicks?[block.id] ?? placement.chosenVariantId` for
/// `sourceChosenID` — every expectation below that names the archived take
/// fails.
@Suite("promotePicks treats an archived pick as no pick (17b P5)")
struct PromotePicksArchivedPickTests {
    /// The world the board produces: a block whose column pick was archived
    /// from the same board afterwards (scratch picks are never pruned).
    private struct Scene {
        var postID: String
        var blockID: String
        var chosenID: String
        var archivedID: String
    }

    private func scene(_ ops: Operations) throws -> Scene {
        let post = try ops.createPost(title: "the article", profile: .blog)
        let minted = try ops.newBlock(in: post.id, text: "Take one.", at: .end)
        let alt = try ops.branchVariant(minted.block.id, from: minted.variant.id)
        try ops.autosave(alt.id, text: "Take two, bolder.", charDelta: 8)
        try ops.archiveVariant(alt.id)
        return Scene(
            postID: post.id, blockID: minted.block.id,
            chosenID: minted.variant.id, archivedID: alt.id)
    }

    private func activeTakes(_ db: AppDatabase, ofBlock blockID: String) throws -> Int {
        try db.fetchInt(
            """
            SELECT COUNT(*) FROM variant
            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
            """, [blockID]) ?? -1
    }

    @Test func theOnlyTakeOfACopiedBlockIsNeverAnArchivedOne() throws {
        try withOperations { ops, db in
            let s = try scene(ops)

            // "New note, only what this column shows" — the door that made
            // the dead block.
            let copy = try ops.promotePicks(
                post: s.postID, picks: [s.blockID: s.archivedID], carryFans: false)
            let copiedBlock = try #require(copy.blockCopies.first?.copy)

            #expect(try self.activeTakes(db, ofBlock: copiedBlock) >= 1,
                    "I10 at birth: a live placed block has a live ACTIVE take")
            let text = try db.read { try Queries.renderedText($0, containerID: copy.post.id) }
            #expect(text == "Take one.",
                    "the column showed the slot's chosen — the copy carries those words, not the archived pick's")

            // The consequence the old shape produced, driven for real: a
            // block whose only take is archived refuses every keystroke.
            let copiedTake = try #require(try db.fetchString(
                """
                SELECT id FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY fan_position, id LIMIT 1
                """, [copiedBlock]))
            try ops.autosave(copiedTake, text: "She can type in it.", charDelta: 8)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [copiedTake])
                    == "She can type in it.")
        }
    }

    @Test func carryingTheFanNeverPointsTheCopysChosenAtAnArchivedTake() throws {
        try withOperations { ops, db in
            let s = try scene(ops)

            let copy = try ops.promotePicks(
                post: s.postID, picks: [s.blockID: s.archivedID], carryFans: true)
            let copiedBlock = try #require(copy.blockCopies.first?.copy)

            let chosen = try db.fetchString(
                """
                SELECT chosen_variant_id FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """, [copiedBlock])
            let chosenStatus = try chosen.flatMap { id in
                try db.fetchString("SELECT status FROM variant WHERE id = ?", [id])
            }
            #expect(chosenStatus != "archived",
                    "the slot's chosen pointer never names an archived take (the read-time fallback is a net, not a plan)")
            let text = try db.read { try Queries.renderedText($0, containerID: copy.post.id) }
            #expect(text == "Take one.", "and it still renders what the column showed")

            // The archived take DID ride along (carryFans preserves
            // statuses — the standing rule, untouched by this fix).
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'archived'
                """, [copiedBlock]) == 1)
        }
    }

    /// The neighbouring arms stay exactly as they were: a LIVE pick is
    /// still honoured, and a pick naming nothing still falls through.
    @Test func aLivePickIsStillThePicksWholePoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the article", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "Take one.", at: .end)
            let alt = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(alt.id, text: "Take two, bolder.", charDelta: 8)

            let copy = try ops.promotePicks(
                post: post.id, picks: [minted.block.id: alt.id], carryFans: false)
            let text = try db.read { try Queries.renderedText($0, containerID: copy.post.id) }
            #expect(text == "Take two, bolder.", "the live pick IS the copy's chosen")

            let lenient = try ops.promotePicks(
                post: post.id, picks: [minted.block.id: "no-such-take"], carryFans: false)
            let lenientText = try db.read {
                try Queries.renderedText($0, containerID: lenient.post.id)
            }
            #expect(lenientText == "Take one.", "an unknown pick resolves like an un-picked slot")
        }
    }
}
