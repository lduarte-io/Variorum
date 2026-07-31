import Dependencies
import Foundation
import GRDB

// Phase 11, Step A2 — the `version_of` operation (the KnownIssues row) and
// the two copy operations from the kickoff spike's ruling (round 5/6, her
// go): `duplicateAsVersion(post)` copies the post EXACTLY as it is — its
// own chosen + whole fans, no lens/view involvement; `promoteLens(lens)`
// materializes one lens — chosen := the lens's effective picks, fans ride
// by default with chosen-only offered at the gesture. **The two differ in
// exactly ONE thing: where the copy's chosen comes from** (pinned). Her
// governing frame: "a lens is the same structure with different choices; a
// version is a different structure; promote is the bridge."
extension Operations {
    // MARK: - version_of (block-level, the schema's letter)

    /// Mints the undirected `version_of` edge, stored canonically as
    /// (min(id), max(id)) so two devices creating the same relationship
    /// converge to one row (AppSpec §7; SyncSpec §7 treats a reversed pair
    /// as a duplicate). Refuses self-links and existing live links.
    /// No undo entry: like tags/locks, a version mark is trivially
    /// re-toggled (`removeVersionOf`) — the AppSpec §9 exclusion class.
    @discardableResult
    public func markVersionOf(
        _ blockAID: String, _ blockBID: String, originOp: String = "manual"
    ) throws -> Edge {
        try database.write { db in
            try insertVersionOfEdge(db, blockAID, blockBID, originOp: originOp, now: date.now)
        }
    }

    /// Tombstones the live version link between the two blocks (either
    /// orientation — one relationship).
    public func removeVersionOf(_ blockAID: String, _ blockBID: String) throws {
        try database.write { db in
            let (low, high) = blockAID < blockBID ? (blockAID, blockBID) : (blockBID, blockAID)
            guard let edgeID = try String.fetchOne(
                db,
                sql: """
                    SELECT id FROM edge
                    WHERE type = 'version_of' AND deleted_at IS NULL
                      AND ((source_block_id = ? AND target_block_id = ?)
                        OR (source_block_id = ? AND target_block_id = ?))
                    """,
                arguments: [low, high, high, low])
            else {
                throw OperationError.versionLinkNotFound(a: blockAID, b: blockBID)
            }
            try db.execute(
                sql: "UPDATE edge SET deleted_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), edgeID])
        }
    }

    /// UNMARK POSTS AS VERSIONS (taste checkpoint, Sitting 9 — R60/R68:
    /// "mark as versions should still be … at least unmarkable"): tombstone
    /// EVERY live `version_of` edge between the two posts' placed blocks —
    /// the peer traversal matches any of them, so removing only one could
    /// leave the pair still reading as linked. Trivially re-markable (the
    /// tags/locks class — no undo entry). Refuses when no link exists.
    public func unmarkPostsAsVersions(_ postAID: String, _ postBID: String) throws {
        try database.write { db in
            // A cross-post edge: one endpoint placed in A, the other in B
            // (either orientation) — the same shape the peer traversal
            // matches, so unmarking removes exactly what made them peers.
            let crossPredicate = """
                type = 'version_of' AND deleted_at IS NULL
                  AND ((source_block_id IN (SELECT block_id FROM container_block
                          WHERE container_id = ? AND deleted_at IS NULL)
                        AND target_block_id IN (SELECT block_id FROM container_block
                          WHERE container_id = ? AND deleted_at IS NULL))
                    OR (source_block_id IN (SELECT block_id FROM container_block
                          WHERE container_id = ? AND deleted_at IS NULL)
                        AND target_block_id IN (SELECT block_id FROM container_block
                          WHERE container_id = ? AND deleted_at IS NULL)))
                """
            let count = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM edge WHERE " + crossPredicate,
                arguments: [postAID, postBID, postBID, postAID]) ?? 0
            guard count > 0 else {
                throw OperationError.versionLinkNotFound(a: postAID, b: postBID)
            }
            let stamped = DateFormatter.variorumISO8601.string(from: date.now)
            try db.execute(
                sql: "UPDATE edge SET deleted_at = ? WHERE " + crossPredicate,
                arguments: [stamped, postAID, postBID, postBID, postAID])
        }
    }

    /// The post-level door ("Mark as Versions", brief item 2): posts are
    /// edges-only across versions (I8) and edges are block-to-block (the
    /// schema's letter), so the post relationship RIDES a block-level edge —
    /// minted between the two posts' FIRST live blocks (PROVISIONAL anchor,
    /// QUESTIONS #19; the peer traversal `Queries.versionPeerPosts` matches
    /// ANY live version_of edge between the posts' placed blocks, so the
    /// relationship survives later restructuring of everything but the
    /// anchor pair). Refuses when either post is blockless or the posts are
    /// already linked.
    @discardableResult
    public func markPostsAsVersions(_ postAID: String, _ postBID: String) throws -> Edge {
        try database.write { db in
            _ = try livePost(db, postAID)
            _ = try livePost(db, postBID)
            if try Queries.versionPeerPosts(db, of: postAID).contains(postBID) {
                throw OperationError.postsAlreadyVersionLinked(a: postAID, b: postBID)
            }
            func firstBlock(_ postID: String) throws -> String {
                guard let id = try String.fetchOne(
                    db,
                    sql: """
                        SELECT block_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        ORDER BY position, id LIMIT 1
                        """,
                    arguments: [postID])
                else { throw OperationError.postHasNoBlocks(id: postID) }
                return id
            }
            return try insertVersionOfEdge(
                db, try firstBlock(postAID), try firstBlock(postBID),
                originOp: "manual", now: date.now)
        }
    }

    // MARK: - The two copy operations (spike rounds 5–6, her go)

    /// Everything a post copy mints, for callers and the row-level pins.
    public struct PostCopyResult: Equatable, Sendable {
        public let post: Container
        /// Source block id → its copy, in position order.
        public let blockCopies: [(source: String, copy: String)]
        public let versionEdge: Edge

        public static func == (lhs: PostCopyResult, rhs: PostCopyResult) -> Bool {
            lhs.post == rhs.post && lhs.versionEdge == rhs.versionEdge
                && lhs.blockCopies.elementsEqual(rhs.blockCopies, by: ==)
        }
    }

    /// DUPLICATE AS VERSION: the post EXACTLY as it is — its own chosen +
    /// whole fans; ignores columns and lenses; unambiguous from anywhere
    /// (round 5's ruling, superseding the round-4 unification). Copies the
    /// container row (title/profile/entry_date/notes/segmentation verbatim;
    /// never born locked — the poolDragCopy copy doctrine), every live slot
    /// (whole live fan, archived takes riding with statuses preserved,
    /// commits never copied, parent trees remapped, block names copied),
    /// per-block `derived_from` edges, and ONE `version_of` edge on the
    /// first slot pair (the post-level link's anchor). Tags, reading
    /// memberships, references, and lenses deliberately do NOT ride
    /// ("lenses never ride any copy" — spike record item 5; the rest
    /// recorded as build-time calls in the closeout). A sealed source is
    /// legal — reading isn't authoring; the source is never touched.
    @discardableResult
    public func duplicateAsVersion(_ postID: String) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try copyPost(db, sourceID: postID, chosenPicks: nil, carryFans: true)
        }
        undoStack?.register(
            label: "Duplicate as Version",
            inverse: { try $0.revertMintedContainer(result.post.id) },
            redo: { try $0.reapplyMintedContainer(result.post.id) })
        return result
    }

    /// MAKE OUTLINE POST (taste checkpoint, Sitting 9 — R99; her batch-10
    /// answer: FIRST SENTENCE PER BLOCK): a linked condensation copy — one
    /// block per source block, seeded with the source's rendered take's
    /// first sentence (the read-time `tocHandle` rule, block names ignored;
    /// an EMPTY source block seeds an empty block — the mint never invents
    /// prose), named "outline of <title>", each minted block
    /// `derived_from` its source (the HONEST direction: the outline
    /// descends from the draft), plus ONE `version_of` anchor on the first
    /// pair (the post-level link, the copy family's letter). The Outline
    /// view maps kin in EITHER derivation direction, so the minted outline
    /// pairs immediately. Refuses a blockless source. A sealed source is
    /// legal — reading isn't authoring; the source is never touched.
    @discardableResult
    public func mintOutlinePost(of postID: String) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            let source = try livePost(db, postID)
            let now = date.now
            let sourceTitle = source.title?.isEmpty == false ? source.title! : "untitled"
            let outline = Container(
                id: newID(), ownerId: currentOwnerID(), kind: .post,
                title: "outline of \(sourceTitle)",
                profile: nil, entryDate: nil, locked: false, floatingNotes: nil,
                segmentationDefault: source.segmentationDefault,
                lastTouchedAt: now, createdAt: now, updatedAt: now)
            try outline.insert(db)

            let placements = try ContainerBlock
                .filter(Column("container_id") == postID && Column("deleted_at") == nil)
                .order(Column("position"), Column("id"))
                .fetchAll(db)

            var blockCopies: [(source: String, copy: String)] = []
            for placement in placements {
                guard let block = try Block.fetchOne(db, key: placement.blockId),
                      block.deletedAt == nil,
                      let take = try? renderedVariant(db, block: block, placement: placement)
                else { continue }  // gap slots (SyncSpec §5) mint nothing

                let text = take.workingText
                let sentence = text.isEmpty
                    ? ""
                    : Queries.tocHandle(name: nil, text: text)
                let minted = try mintBlock(
                    db, text: sentence, in: outline.id, at: .end, now: now)
                let edge = Edge(
                    id: newID(), sourceBlockId: minted.block.id, targetBlockId: block.id,
                    type: .derivedFrom, originOp: "manual", createdAt: now)
                try edge.insert(db)
                try registerTextChange(
                    db, blockID: minted.block.id, charDelta: sentence.count,
                    forceMajorRevision: false, now: now)
                blockCopies.append((source: block.id, copy: minted.block.id))
            }
            guard let firstPair = blockCopies.first else {
                throw OperationError.postHasNoBlocks(id: postID)
            }
            let versionEdge = try insertVersionOfEdge(
                db, firstPair.copy, firstPair.source, originOp: "manual", now: now)
            return PostCopyResult(
                post: outline, blockCopies: blockCopies, versionEdge: versionEdge)
        }
        undoStack?.register(
            label: "Make Outline Post",
            inverse: { try $0.revertMintedContainer(result.post.id) },
            redo: { try $0.reapplyMintedContainer(result.post.id) })
        return result
    }

    /// PROMOTE LENS: a new version-post whose chosen := the lens's
    /// EFFECTIVE picks (fall-through slots follow the source's chosen).
    /// Fans ride by DEFAULT; `carryFans: false` is the choose-at-promote
    /// option (round 6: her call — carry-all default, chosen-only offered
    /// at the gesture), materializing each block as the single take the
    /// lens shows. The original post AND the lens are untouched; lenses
    /// never ride the copy. Differs from `duplicateAsVersion` in exactly
    /// one thing: where the copy's chosen comes from (pinned).
    @discardableResult
    public func promoteLens(_ lensID: String, carryFans: Bool = true) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            let lens = try liveLens(db, lensID)
            let picks = try Queries.effectiveLensSelection(db, lens: lensID)
            return try copyPost(
                db, sourceID: lens.containerId, chosenPicks: picks, carryFans: carryFans)
        }
        undoStack?.register(
            label: "Promote Lens",
            inverse: { try $0.revertMintedContainer(result.post.id) },
            redo: { try $0.reapplyMintedContainer(result.post.id) })
        return result
    }

    /// ADOPT LENS: every effective pick → the slot's chosen, ONE compound
    /// (the ✓-everything gesture — the one lens→chosen door besides the
    /// per-slot ✓). Writes exactly `chooseVariant`'s row transition per
    /// diverging slot, in one transaction; refuses under a sealed post
    /// (chosen pointers are frozen). The lens itself is untouched (its
    /// overrides now match chosen — harmlessly redundant, still a lens).
    /// Undo restores the pre-image pointers (the spike's "one compound").
    public func adoptLens(_ lensID: String) throws {
        let moved: [AdoptedPointer] = try database.write { db in
            let lens = try liveLens(db, lensID)
            let post = try livePost(db, lens.containerId)
            try ensureUnlocked(post)
            let picks = try Queries.effectiveLensSelection(db, lens: lensID)
            return try applyAdoptedPicks(db, postID: post.id, picks: picks)
        }
        guard !moved.isEmpty else { return }
        let halves = adoptUndoHalves(moved)
        undoStack?.register(
            label: "Adopt Lens",
            inverse: { try $0.revertChosenPointers(halves.previous) },
            redo: { try $0.revertChosenPointers(halves.adopted) })
    }

    /// ADOPT-SWAP (taste checkpoint, Sitting 9 — R89/R92: "adopting swaps,
    /// never destroys"): adopt the lens AND, in the SAME transaction,
    /// preserve the OUTGOING chosen arrangement as a lens of its own —
    /// named "chosen until <date>", integer-suffixed on collision — so
    /// promoting a way of looking to being-the-post can always be undone by
    /// promoting the old one back. The preservation lens records an
    /// EXPLICIT pick for every renderable slot (full-fidelity, not sparse:
    /// later chosen moves must never bleed through what it preserves).
    /// Returns the preservation lens; no undo entry for it (the lens class
    /// — trivially deleted); the adopt half registers its pointer inverse
    /// exactly like `adoptLens`.
    @discardableResult
    public func adoptLensPreservingChosen(_ lensID: String) throws -> Lens {
        let (preservation, moved): (Lens, [AdoptedPointer]) = try database.write { db in
            let lens = try liveLens(db, lensID)
            let post = try livePost(db, lens.containerId)
            try ensureUnlocked(post)
            let now = date.now
            let preservation = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: post.id,
                name: try preservationLensName(db, postID: post.id, now: now),
                createdAt: now, updatedAt: now)
            try preservation.insert(db)
            for placement in try ContainerBlock
                .filter(Column("container_id") == post.id && Column("deleted_at") == nil)
                .order(Column("position"), Column("id"))
                .fetchAll(db) {
                guard let block = try? liveBlock(db, placement.blockId),
                      let shown = try? renderedVariant(db, block: block, placement: placement)
                else { continue }  // gap slots preserve nothing
                try LensChoice(
                    id: newID(), lensId: preservation.id, blockId: block.id,
                    variantId: shown.id, createdAt: now, updatedAt: now)
                    .insert(db)
            }
            let picks = try Queries.effectiveLensSelection(db, lens: lensID)
            let moved = try applyAdoptedPicks(db, postID: post.id, picks: picks)
            return (preservation, moved)
        }
        if !moved.isEmpty {
            let halves = adoptUndoHalves(moved)
            undoStack?.register(
                label: "Adopt Lens",
                inverse: { try $0.revertChosenPointers(halves.previous) },
                redo: { try $0.revertChosenPointers(halves.adopted) })
        }
        return preservation
    }

    /// ADOPT-SWAP for PICKS (the scratch column's "✓ Make this the post" —
    /// R89's obvious door on every non-Chosen column, same preservation
    /// promise as `adoptLensPreservingChosen`): the sparse view picks →
    /// chosen, with the outgoing chosen preserved as a full-fidelity lens
    /// first, ONE transaction. Stale picks (not a live active take of
    /// their block) are skipped like `setLensChoice` would refuse them —
    /// the swap never half-applies a dead pick.
    @discardableResult
    public func adoptPicksPreservingChosen(
        post postID: String, picks: [String: String]
    ) throws -> Lens {
        let (preservation, moved): (Lens, [AdoptedPointer]) = try database.write { db in
            let post = try livePost(db, postID)
            try ensureUnlocked(post)
            let now = date.now
            let preservation = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: post.id,
                name: try preservationLensName(db, postID: post.id, now: now),
                createdAt: now, updatedAt: now)
            try preservation.insert(db)
            var validated: [String: String] = [:]
            for placement in try ContainerBlock
                .filter(Column("container_id") == post.id && Column("deleted_at") == nil)
                .order(Column("position"), Column("id"))
                .fetchAll(db) {
                guard let block = try? liveBlock(db, placement.blockId),
                      let shown = try? renderedVariant(db, block: block, placement: placement)
                else { continue }
                try LensChoice(
                    id: newID(), lensId: preservation.id, blockId: block.id,
                    variantId: shown.id, createdAt: now, updatedAt: now)
                    .insert(db)
                if let pick = picks[block.id],
                   let take = try Variant.fetchOne(db, key: pick),
                   take.blockId == block.id, take.deletedAt == nil, take.status == .active {
                    validated[block.id] = pick
                }
            }
            let moved = try applyAdoptedPicks(db, postID: post.id, picks: validated)
            return (preservation, moved)
        }
        if !moved.isEmpty {
            let halves = adoptUndoHalves(moved)
            undoStack?.register(
                label: "Adopt Lens",
                inverse: { try $0.revertChosenPointers(halves.previous) },
                redo: { try $0.revertChosenPointers(halves.adopted) })
        }
        return preservation
    }

    /// PROMOTE PICKS (taste checkpoint — R78: direct promote, no forced
    /// lens save): a new version-post whose chosen := the given SPARSE
    /// picks overlaying the source's chosen (un-picked slots follow chosen
    /// — the same fall-through `promoteLens` has, pinned). This is the
    /// scratch column's "Make this a post" door — the picks are view state
    /// that never needed to become a lens first. A pick naming a take that
    /// isn't live on its block falls through harmlessly (the copy resolves
    /// like an un-picked slot). Same undo as every post mint.
    @discardableResult
    public func promotePicks(
        post postID: String, picks: [String: String], carryFans: Bool = true
    ) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try copyPost(db, sourceID: postID, chosenPicks: picks, carryFans: carryFans)
        }
        undoStack?.register(
            label: "Make Into a Post",
            inverse: { try $0.revertMintedContainer(result.post.id) },
            redo: { try $0.reapplyMintedContainer(result.post.id) })
        return result
    }

    /// BRANCH ALL FANS: the eager thread — a new lens whose pick on EVERY
    /// renderable slot is a freshly branched take of what the slot shows
    /// (the transparent/lazy lens stays the default for new threads; this
    /// is the explicit command — spike round 3). One transaction; refuses
    /// under a sealed post (fan growth). No undo entry: the takes are
    /// branch-class rows (branchVariant registers none) and the lens is
    /// trivially deleted — recorded in the closeout.
    @discardableResult
    public func branchAllFans(post postID: String, lensName: String) throws -> Lens {
        try database.write { db in
            let post = try livePost(db, postID)
            try ensureUnlocked(post)
            let trimmed = lensName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw OperationError.invalidLensName(name: lensName)
            }
            let now = date.now
            let lens = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: postID,
                name: trimmed, createdAt: now, updatedAt: now)
            try lens.insert(db)
            for (blockID, takeID) in try branchAllFanTakes(db, postID: postID, now: now)
                .sorted(by: { $0.key < $1.key }) {
                try LensChoice(
                    id: newID(), lensId: lens.id, blockId: blockID,
                    variantId: takeID, createdAt: now, updatedAt: now)
                    .insert(db)
            }
            return lens
        }
    }

    /// BRANCH ALL FANS, no lens (taste checkpoint — R80/R82's "write new
    /// takes" column): mints a fresh take on every renderable slot,
    /// branched from what the slot shows, and returns the picks map
    /// (blockID → new take) for the caller's UNNAMED column. Same seal
    /// refusal; same no-undo rationale (branch-class rows).
    @discardableResult
    public func branchAllFans(post postID: String) throws -> [String: String] {
        try database.write { db in
            let post = try livePost(db, postID)
            try ensureUnlocked(post)
            return try branchAllFanTakes(db, postID: postID, now: date.now)
        }
    }

    // MARK: - Internals

    /// The branch-every-slot loop both `branchAllFans` doors share: a fresh
    /// take per renderable slot, branched from what the slot shows, fan's
    /// end. Returns blockID → minted take id.
    private func branchAllFanTakes(
        _ db: Database, postID: String, now: Date
    ) throws -> [String: String] {
        var picks: [String: String] = [:]
        for placement in try ContainerBlock
            .filter(Column("container_id") == postID && Column("deleted_at") == nil)
            .order(Column("position"), Column("id"))
            .fetchAll(db) {
            guard let block = try? liveBlock(db, placement.blockId),
                  let shown = try? renderedVariant(db, block: block, placement: placement)
            else { continue }  // gap slots render gaps; nothing to branch
            let next = try String.fetchOne(
                db,
                sql: """
                    SELECT fan_position FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position DESC, id DESC LIMIT 1
                    """,
                arguments: [block.id])
            let take = Variant(
                id: newID(), blockId: block.id, parentVariantId: shown.id,
                workingText: shown.workingText,
                fanPosition: FractionalIndex.between(next, nil),
                createdAt: now, updatedAt: now)
            try take.insert(db)
            picks[block.id] = take.id
        }
        return picks
    }

    /// The adopt loop both adopt doors share: every pick → its slot's
    /// chosen (exactly `chooseVariant`'s row transition), returning the
    /// pre-image pointers for the compound undo.
    private func applyAdoptedPicks(
        _ db: Database, postID: String, picks: [String: String]
    ) throws -> [AdoptedPointer] {
        var restored: [AdoptedPointer] = []
        let now = date.now
        for placement in try ContainerBlock
            .filter(Column("container_id") == postID && Column("deleted_at") == nil)
            .order(Column("position"), Column("id"))
            .fetchAll(db) {
            guard let pick = picks[placement.blockId],
                  placement.chosenVariantId != pick else { continue }
            restored.append(AdoptedPointer(
                placementID: placement.id, previous: placement.chosenVariantId, adopted: pick))
            var updated = placement
            updated.chosenVariantId = pick
            updated.updatedAt = now
            try updated.update(db)
        }
        return restored
    }

    /// One slot the adopt moved: both images, so undo and REDO (13c 1B —
    /// A10) each restore an exact pointer rather than re-deriving one.
    struct AdoptedPointer: Sendable {
        let placementID: String
        let previous: String?
        let adopted: String?
    }

    /// The two pointer sets the adopt doors register (13c 1B): `inverse`
    /// restores `previous`, `redo` restores `adopted` — both through the
    /// SAME `revertChosenPointers` body, so there is exactly one pointer-
    /// restore brain.
    private func adoptUndoHalves(
        _ moved: [AdoptedPointer]
    ) -> (previous: [(placementID: String, chosen: String?)],
          adopted: [(placementID: String, chosen: String?)]) {
        (moved.map { (placementID: $0.placementID, chosen: $0.previous) },
         moved.map { (placementID: $0.placementID, chosen: $0.adopted) })
    }

    /// "chosen until Jul 18, 2026" — the adopt-swap preservation lens's
    /// auto-name (R92; her pick), integer-suffixed against the post's LIVE
    /// lens names on collision ("… (1)", "… (2)", first free). Fixed
    /// en_US_POSIX format so the name is deterministic under test.
    private func preservationLensName(
        _ db: Database, postID: String, now: Date
    ) throws -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        let base = "chosen until \(formatter.string(from: now))"
        let names = Set(try String.fetchAll(
            db,
            sql: "SELECT name FROM lens WHERE container_id = ? AND deleted_at IS NULL",
            arguments: [postID]))
        guard names.contains(base) else { return base }
        var n = 1
        while names.contains("\(base) (\(n))") { n += 1 }
        return "\(base) (\(n))"
    }

    func insertVersionOfEdge(
        _ db: Database, _ blockAID: String, _ blockBID: String, originOp: String, now: Date
    ) throws -> Edge {
        guard blockAID != blockBID else {
            throw OperationError.cannotVersionLinkBlockToItself(id: blockAID)
        }
        _ = try liveBlock(db, blockAID)
        _ = try liveBlock(db, blockBID)
        let (low, high) = blockAID < blockBID ? (blockAID, blockBID) : (blockBID, blockAID)
        let exists = try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM edge
                WHERE type = 'version_of' AND deleted_at IS NULL
                  AND ((source_block_id = ? AND target_block_id = ?)
                    OR (source_block_id = ? AND target_block_id = ?)))
                """,
            arguments: [low, high, high, low]) ?? false
        guard !exists else {
            throw OperationError.versionLinkExists(a: blockAID, b: blockBID)
        }
        let edge = Edge(
            id: newID(), sourceBlockId: low, targetBlockId: high,
            type: .versionOf, originOp: originOp, createdAt: now)
        try edge.insert(db)
        return edge
    }

    /// The one copy machine both operations share — they differ ONLY in
    /// `chosenPicks` (nil = the source's own chosen; a map = the lens's
    /// effective picks overlaying it) and `carryFans`.
    /// Internal (not private) since 13f batch 5: `divergePostForReading`
    /// composes THIS copy inside its own transaction — the whole point of
    /// W23 is that the copy and the membership swap are one act, so the
    /// copy body cannot be reached through `duplicateAsVersion` (which
    /// opens its own write and registers its own undo entry).
    func copyPost(
        _ db: Database, sourceID: String, chosenPicks: [String: String]?, carryFans: Bool
    ) throws -> PostCopyResult {
        let source = try livePost(db, sourceID)
        let now = date.now

        var copy = Container(
            id: newID(), ownerId: currentOwnerID(), kind: .post,
            title: source.title, profile: source.profile, entryDate: source.entryDate,
            locked: false, floatingNotes: source.floatingNotes,
            segmentationDefault: source.segmentationDefault,
            lastTouchedAt: now,
            createdAt: now, updatedAt: now)
        try copy.insert(db)

        let placements = try ContainerBlock
            .filter(Column("container_id") == sourceID && Column("deleted_at") == nil)
            .order(Column("position"), Column("id"))
            .fetchAll(db)

        var blockCopies: [(source: String, copy: String)] = []
        var renderedLength = 0
        var firstPair: (String, String)?

        for placement in placements {
            guard let block = try Block.fetchOne(db, key: placement.blockId),
                  block.deletedAt == nil
            else { continue }  // gap slots (SyncSpec §5) copy as nothing

            // Which variant each slot of the copy CHOOSES: the source
            // slot's own chosen (duplicate), or the lens's effective pick
            // where one exists (promote) — the ONE difference between the
            // two operations.
            let sourceChosenID = chosenPicks?[block.id]
                ?? placement.chosenVariantId

            let fan = try Variant.fetchAll(
                db,
                sql: """
                    SELECT * FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [block.id])
            // What this slot RESOLVES to (for chosen-only copies and the
            // default fallback): chosen if healthy, else block default.
            let resolved = try? renderedVariant(db, block: block, placement: placement)
            let lensShown = chosenPicks?[block.id].flatMap { pick in
                fan.first { $0.id == pick }
            }
            let shownVariant = lensShown ?? resolved

            let toCopy: [Variant]
            if carryFans {
                toCopy = fan
            } else if let shownVariant {
                toCopy = [shownVariant]
            } else {
                toCopy = []
            }
            // A slot with no live variants (the SyncSpec §5 gap window)
            // copies as NOTHING — and the block row is minted only now
            // that the variant set is known non-empty (review round 1,
            // MINOR 4: the ops layer performs no physical deletes, S2's
            // letter; a compensating DELETE fired no outbox capture and
            // stranded a phantom entry the drain could never clear).
            guard !toCopy.isEmpty else { continue }

            var blockCopy = Block(
                id: newID(), ownerId: currentOwnerID(), name: block.name,
                presentation: block.presentation,
                createdAt: now, updatedAt: now)
            try blockCopy.insert(db)

            var copyIDs: [String: String] = [:]
            var copiedVariants: [Variant] = []
            for take in toCopy { copyIDs[take.id] = newID() }
            for take in toCopy {
                let variant = Variant(
                    id: copyIDs[take.id]!, blockId: blockCopy.id,
                    parentVariantId: take.parentVariantId.flatMap { copyIDs[$0] },
                    workingText: take.workingText, status: take.status,
                    locked: false, label: take.label,
                    fanPosition: take.fanPosition,
                    createdAt: now, updatedAt: now)
                try variant.insert(db)
                copiedVariants.append(variant)
            }

            // chosen: the copy of the slot's pick (nil or unhealthy source
            // chosen ⇒ nil — the read-time default fallback carries).
            let chosenCopyID = sourceChosenID.flatMap { copyIDs[$0] }
            // default: the copy of the source's default where it rode
            // along, else the copy of what the slot showed, else the
            // first copied take (I10: never a live block without a live
            // active default's fallback).
            let defaultCopyID = block.defaultVariantId.flatMap { copyIDs[$0] }
                ?? shownVariant.flatMap { copyIDs[$0.id] }
                ?? copiedVariants[0].id
            blockCopy.defaultVariantId = defaultCopyID
            try blockCopy.update(db)

            try ContainerBlock(
                id: newID(), containerId: copy.id, blockId: blockCopy.id,
                position: placement.position, chosenVariantId: chosenCopyID,
                createdAt: now, updatedAt: now)
                .insert(db)

            _ = try insertLineageEdge(
                db, from: blockCopy.id, to: block.id, originOp: "manual", now: now)
            // Phase 13 (A2) travel: working notes ride both copy operations
            // (duplicate-as-version AND promote — the plan's letter).
            try copyLiveComments(db, from: block.id, to: blockCopy.id, now: now)

            if firstPair == nil { firstPair = (block.id, blockCopy.id) }
            blockCopies.append((source: block.id, copy: blockCopy.id))
            if let shownText = (chosenCopyID.flatMap { id in copiedVariants.first { $0.id == id } }
                                ?? copiedVariants.first(where: { $0.id == defaultCopyID }))?
                .workingText, !shownText.isEmpty {
                renderedLength += shownText.count
            }
        }

        guard let (anchorSource, anchorCopy) = firstPair else {
            throw OperationError.postHasNoBlocks(id: sourceID)
        }
        let versionEdge = try insertVersionOfEdge(
            db, anchorSource, anchorCopy, originOp: "manual", now: now)

        // The copy starts "clean": baseline = its rendered length, zero
        // churn — first edits accumulate against real content, exactly like
        // a post that just crossed a threshold (AppSpec §10's rebaseline).
        copy.baselineLength = renderedLength
        try copy.update(db)

        return PostCopyResult(post: copy, blockCopies: blockCopies, versionEdge: versionEdge)
    }

    /// Inverse of the post-minting copy operations: tombstone the minted
    /// container — the ordinary cascade takes its placements, blocks,
    /// variants, and edges (all fresh rows by construction), and
    /// `restoreContainer` remains the recovery door if the author undoes a
    /// copy she had already worked in (deleted posts are recoverable —
    /// nothing typed becomes unreachable). Already-dead ⇒ obsolete no-op.
    func revertMintedContainer(_ containerID: String) throws {
        try database.write { db in
            guard var container = try Container.fetchOne(db, key: containerID),
                  container.deletedAt == nil
            else { return }
            let now = date.now
            container.deletedAt = now
            container.updatedAt = now
            try container.update(db)
        }
    }

    /// Inverse of `adoptLens`: put the pre-image chosen pointers back.
    /// Slots re-pointed or unlocked-refused since keep the standing refusal
    /// buckets: dead placement ⇒ skip quietly (the world moved on); a
    /// sealed post throws (unlock, retry).
    func revertChosenPointers(_ preImages: [(placementID: String, chosen: String?)]) throws {
        try database.write { db in
            let now = date.now
            for preImage in preImages {
                guard var placement = try ContainerBlock.fetchOne(db, key: preImage.placementID),
                      placement.deletedAt == nil
                else { continue }
                try ensureUnlocked(try liveContainer(db, placement.containerId))
                // A pre-image pointing at a variant that has since died is
                // healed by the read-time fallback; restore it anyway —
                // exact-row inverse, the fallback covers rendering.
                placement.chosenVariantId = preImage.chosen
                placement.updatedAt = now
                try placement.update(db)
            }
        }
    }
}
