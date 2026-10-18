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
    /// anchor pair). Refuses when the posts are already linked.
    ///
    /// **A BLOCKLESS POST GAINS ITS ANCHOR BLOCK** (her ruling U-19 (1),
    /// 2026-09-06, verbatim *"a is good"*; ledger row 17). It used to refuse
    /// with `postHasNoBlocks` — the link had nothing to ride, so a note she
    /// had only just made could not be marked as a version of anything, and
    /// Compare had no answer but the raw error. The anchor is now MINTED, in
    /// this same transaction: one ordinary block with one live EMPTY take
    /// (I10 holds — "live" is about the variant row, not its characters),
    /// placed at the end of the note. Nothing about the block is
    /// special-cased: it is the block a note's first Return would have made,
    /// and U-19 (2)'s rule governs it from then on — an abandoned empty
    /// block STAYS as an empty paragraph, never auto-removed — so
    /// `unmarkPostsAsVersions` (the tags/locks recovery class) removes the
    /// LINK and leaves the block for her to type into or delete, exactly as
    /// it would any other empty block.
    ///
    /// Two consequences, both deliberate. The mint stamps `last_touched_at`
    /// and never churn: AppSpec §9's structural rule — a block appearing in
    /// the note is restructuring it, and restructuring must never reshuffle
    /// the meaningful sort. And it refuses under a SEALED post, since
    /// minting a block is precisely the kind of act the seal freezes
    /// (the everything-UNDER-the-post letter). The LINK itself stays free
    /// under a seal, like tagging and adding to a reading — only a post that
    /// needs a block minted is gated, so a sealed post that HAS blocks marks
    /// as a version exactly as it always has.
    @discardableResult
    public func markPostsAsVersions(_ postAID: String, _ postBID: String) throws -> Edge {
        try database.write { db in
            let postA = try livePost(db, postAID)
            let postB = try livePost(db, postBID)
            if try Queries.versionPeerPosts(db, of: postAID).contains(postBID) {
                throw OperationError.postsAlreadyVersionLinked(a: postAID, b: postBID)
            }
            let now = date.now
            func anchorBlock(_ post: Container) throws -> String {
                // The first-live-placed-block rule is `firstLivePlacedBlock`'s,
                // consumed rather than typed a second time (17o c/d/e ladder
                // round 1, NIT-2). The helper's own sentence has claimed since
                // 13l that it IS this rule made shared, and it was the more
                // correct of the two copies: it JOINs `block` on liveness, so a
                // live placement left over a TOMBSTONED block is not chosen as
                // an anchor — an edge there would render nothing. Where that
                // leaves a post with no live placed block at all, the mint arm
                // below gives it one, which is exactly what U-19 (1) asks for.
                //
                // **MEASURED at the round-2 pin** (17o c/d/e, MINOR-2), and
                // sharper than the round-1 record guessed: the retired inline
                // copy did not anchor a live edge on the dead block — it handed
                // the dead id to `insertVersionOfEdge`, whose `liveBlock` guard
                // threw `blockNotFound`. So the old road REFUSED the link in
                // this state, with a raw enum naming a block she cannot see;
                // the new one links it correctly. Pinned by
                // `aLivePlacementOverATombstonedBlockIsNotAnAnchor` and
                // `theRacedShapeUnderASealRefusesRatherThanAnchoringOnTheDeadBlock`.
                if let id = try Self.firstLivePlacedBlock(db, of: post.id) {
                    return id
                }
                try ensureUnlocked(post)
                let minted = try mintBlock(db, text: "", in: post.id, at: .end, now: now)
                try touchContainer(db, post.id, now: now)
                return minted.block.id
            }
            return try insertVersionOfEdge(
                db, try anchorBlock(postA), try anchorBlock(postB),
                originOp: "manual", now: now)
        }
    }

    // MARK: - The two copy operations (spike rounds 5–6, her go)

    /// Everything a post copy mints, for callers and the row-level pins.
    public struct PostCopyResult: Equatable, Sendable {
        public let post: Container
        /// Source block id → its copy, in position order.
        public let blockCopies: [(source: String, copy: String)]
        public let versionEdge: Edge
        /// VX-311 (VX-336 U6a — D-311-4): what the copy MINTED, per copied
        /// block in position order — VX-252's record (`MintedBlockTakes`), its
        /// `sourceBlockID` set — built from the copy machine's own rows, never
        /// a second read. Filled by `copyPost`; empty where a caller builds
        /// its own result (the outline, the saved version). Outside `==`
        /// (a projection of the rows `blockCopies` already names), so every
        /// existing construction and comparison is unchanged.
        public var blocks: [MintedBlockTakes] = []

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
    /// first slot pair (the post-level link's anchor). Reading
    /// memberships, references, and lenses deliberately do NOT ride
    /// ("lenses never ride any copy" — spike record item 5; the rest
    /// recorded as build-time calls in the closeout). A sealed source is
    /// legal — reading isn't authoring; the source is never touched.
    ///
    /// **What a duplicate does with the note's TAGS** (VX-372, VX-383 U1 —
    /// D-C-1; her ticket: *"a direct duplicate door, with tags / without tags;
    /// a duplicate with tags counts as tagging"*). Her two doors, one act each
    /// — `verb` is the door's word (P-C-1, PROVISIONAL for her VX-234 wording
    /// pass: "Duplicate as Version" retires as a label; the versions machinery
    /// and the `version_of` edge are unchanged) and the undo entry's label.
    public enum DuplicateTags: String, Equatable, Sendable, CaseIterable {
        /// **Duplicate with Tags** — each live tag the source wears in its
        /// wing is APPLIED to the copy through the one application road
        /// (`insertPostTag`), so intake hears it exactly as when she tags.
        case applied
        /// **Duplicate without Tags** — the copy wears none, so no book hears it.
        case none

        /// The door's word, and the undo entry's label.
        public var verb: String {
            switch self {
            case .applied: "Duplicate with Tags"
            case .none: "Duplicate without Tags"
            }
        }
    }

    /// **The note's TAGS, by her choice** (VX-372 — D-C-1, superseding 17y
    /// item (c)'s ROW copy, PROVISIONAL P-17y-B3-c1, for this door). With
    /// `.applied` (the default — her door's, and P-C-3's for the wire) the
    /// copy is then TAGGED: each live tag the source wears in its wing,
    /// application order kept, applied through `insertPostTag`, in this op's
    /// own transaction — so every living book whose rule hears a tag decides
    /// by `IntakeDecision` exactly as when she tags: a book that joins
    /// quietly SEATS the copy, one whose dial says Arrivals BELLS it, capacity
    /// waits at the door, and the ownership table holds (the copy is membered
    /// nowhere until the first seat). Finished, sealed and archived books stay
    /// paused (the one table). With `.none` the copy wears no tag at all. The
    /// tags live HERE, never in `copyPost`: Diverge (`divergePostForReading`)
    /// and `promoteLens` compose that body and stay tag-less (her lean — a
    /// diverged copy is meant to differ).
    ///
    /// **ONE undo entry covers the seats** (`registerMintedContainerEntry`):
    /// the inverse tombstones the copy, and the container trigger takes its
    /// applications, memberships and arrivals on that ONE stamp; the redo's
    /// `restoreContainer` revives exactly those on it — so a row she judged
    /// in between (a dismissal, on her own stamp; a seat she pressed, the same
    /// row) stays as she judged it. Pinned `DuplicateAppliesTagsTests`,
    /// `DuplicateWithoutTagsTests`, `DuplicateCarriesTagsTests`.
    @discardableResult
    public func duplicateAsVersion(
        _ postID: String, tags: DuplicateTags = .applied
    ) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try duplicateAsVersionBody(db, postID, tags: tags)
        }
        registerMintedContainerEntry(label: tags.verb, result.post.id)
        return result
    }

    /// **Where a duplicate is FILED** (VX-371, VX-383 U2 — D-C-4): a BOOK of
    /// the source's wing, and optionally a chapter of it. Only the MCP door's
    /// `duplicate_note` files (`create_note`'s book road, applied to a copy);
    /// her own doors pass none, so their rows are byte-unchanged.
    public struct DuplicateFiling: Equatable, Sendable {
        public let bookID: String
        public let sectionID: String?

        public init(bookID: String, sectionID: String? = nil) {
            self.bookID = bookID
            self.sectionID = sectionID
        }
    }

    /// **The duplicate's ROWS, inside the caller's transaction** — her door's
    /// body, extracted ONCE (VX-311, VX-336 U6a — D-311-1, the orchestrator's
    /// ruling) so her door and the MCP door's `duplicate_note`
    /// (`duplicateNoteForClient`, its guard first) run the very same brain and
    /// can never drift — the tag choice included (VX-372, D-C-1): the copy
    /// machine with the source's own chosen and whole fans, then, with
    /// `.applied`, the note's live tags APPLIED (`applyLiveTags`).
    ///
    /// **`filing`** (VX-371 — D-C-4; nil for every door of hers): the copy
    /// joins that book in this same transaction, in `create_note`'s order
    /// (`mintNoteEntry`): the book's gates and the chapter are checked BEFORE
    /// anything is minted (a live book — a gathering refuses
    /// `wrongReadingKind`, a finished one `lockedReading`; a chapter of THAT
    /// book — `sectionNotFound` / `sectionNotInReading`); then the family
    /// copy; then the MEMBERSHIP through the hand-add's one choke point
    /// (`addPostToReading` — capacity, the wing, ownership, the book's
    /// OUTFLOW), the chapter stamped on that row; and only THEN the tags. The
    /// order is load-bearing: the book's own pair is decided before any tag is
    /// applied, so a destination that collects one of the copy's tags takes it
    /// ONCE, filed (tags first, intake would seat it and the filing would
    /// refuse `alreadyInReading`), and the applications are heard by the OTHER
    /// books — an owned destination's copy then BELLS at a plain collecting
    /// book (the ownership table). An ARCHIVED book takes the add (explicit
    /// adds land — AppSpec §9, 13i-e).
    func duplicateAsVersionBody(
        _ db: Database, _ postID: String, tags: DuplicateTags, filing: DuplicateFiling? = nil
    ) throws -> PostCopyResult {
        if let filing {
            let book = try liveReading(db, filing.bookID)
            guard book.kind == .book else {
                throw OperationError.wrongReadingKind(id: filing.bookID, expected: .book)
            }
            guard !book.locked else { throw OperationError.lockedReading(id: filing.bookID) }
            if let sectionID = filing.sectionID {
                let section = try liveSection(db, sectionID)
                guard section.readingId == filing.bookID else {
                    throw OperationError.sectionNotInReading(sectionID: sectionID, readingID: filing.bookID)
                }
            }
        }
        let copy = try copyPost(db, sourceID: postID, chosenPicks: nil, carryFans: true)
        if let filing {
            var membership = try addPostToReading(db, copy.post.id, to: filing.bookID, at: .end)
            if let sectionID = filing.sectionID {
                membership.sectionId = sectionID
                try membership.update(db)
            }
        }
        switch tags {
        case .applied:
            try applyLiveTags(db, from: postID, to: copy.post.id, now: date.now)
        case .none:
            break
        }
        return copy
    }

    /// **The source's live tags, APPLIED to `targetID`** (VX-372 — D-C-1 and
    /// D-C-3's one road): every live application of a live tag in the
    /// TARGET's wing (a duplicate's and a saved version's wing is the
    /// source's — this is also the wing belt `applyAutoTag` keeps, so no tag
    /// ever crosses wings), in the source's application order, each through
    /// `insertPostTag` — the ONE post-tag insert road, so each application is
    /// an applying ACT that intake hears. A tag the target already wears
    /// (impossible on a fresh copy, kept as the guard) is skipped, as is
    /// every application once the target is gone.
    func applyLiveTags(
        _ db: Database, from sourceID: String, to targetID: String, now: Date
    ) throws {
        guard let target = try Container.fetchOne(db, key: targetID),
              target.deletedAt == nil, target.kind == .post
        else { return }
        for tagID in try liveTagIDs(db, of: sourceID, inWing: target.wingId) {
            guard try liveApplication(db, table: "post_tag", tagID: tagID,
                                      targetColumn: "post_id", targetID: targetID) == nil
            else { continue }
            try insertPostTag(db, tagID: tagID, postID: targetID, now: now)
        }
    }

    /// The note's live tags in `wingID` — every live application of a live tag
    /// of that wing, in application order (`created_at, id`): what
    /// `applyLiveTags` applies, and (VX-371) the head of `duplicate_note`'s
    /// answered tag list — one statement, so the two can never disagree.
    func liveTagIDs(_ db: Database, of postID: String, inWing wingID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT pt.tag_id FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL AND t.wing_id = ?
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY pt.created_at, pt.id
                """,
            arguments: [wingID, postID])
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
        registerMintedContainerEntry(label: "Make Outline Note", result.post.id)
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
        registerMintedContainerEntry(label: "Promote Lens", result.post.id)
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
        registerPointerEntry(label: "Adopt Lens", moves: adoptedPointerMoves(moved))
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
            try adoptSwapRows(db, lensID: lensID)
        }
        if !moved.isEmpty {
            registerPointerEntry(label: "Adopt Lens", moves: adoptedPointerMoves(moved))
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
            registerPointerEntry(label: "Adopt Lens", moves: adoptedPointerMoves(moved))
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
        registerMintedContainerEntry(label: "Make Into a Note", result.post.id)
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
            let trimmed = StoredText.stripped(lensName).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
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

    /// **THE ADOPT-SWAP's ROWS** (her "✓ Make this the note" on a lens column
    /// — R89/R92: the outgoing chosen preserved as a full-fidelity lens, then
    /// every effective pick → chosen), inside the caller's transaction:
    /// `adoptLensPreservingChosen`'s body, extracted byte-for-byte (VX-168 U2)
    /// so the MCP door's `adopt_lens` lands HER door's rows through the same
    /// brain. Returns the preservation lens and the pointers that moved.
    func adoptSwapRows(_ db: Database, lensID: String) throws -> (Lens, [AdoptedPointer]) {
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

    /// The slots the adopt doors register (13c 1B; VX-246 U2 — VX-277): each
    /// slot's pointer before (`previous`) and after (`adopted`) the adopt, as
    /// the ONE pointer entry's moves (`registerPointerEntry`) — the client's
    /// `choose_take` / `adopt_lens` rule, slot by slot, so the undo never
    /// overwrites her later ✓ and the redo never re-chooses over her ✓ back.
    /// One pointer-restore brain for her doors and the client's alike.
    func adoptedPointerMoves(_ moved: [AdoptedPointer]) -> [PointerMove] {
        moved.map { (placementID: $0.placementID, from: $0.previous, to: $0.adopted) }
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
        _ db: Database, sourceID: String, chosenPicks: [String: String]?, carryFans: Bool,
        intoWing destinationWing: String? = nil
    ) throws -> PostCopyResult {
        let source = try livePost(db, sourceID)
        let now = date.now

        // 13i-c U2: the copy is born in the SOURCE's wing — a copy door is
        // never a wing crossing (the sitting record §9's total isolation).
        // 13i-d U5: the ONE explicit crossing — `copyNoteToWing` — names its
        // destination (`intoWing`); every other copy door passes nil.
        var copy = Container(
            id: newID(), ownerId: currentOwnerID(), kind: .post,
            title: source.title, profile: source.profile, entryDate: source.entryDate,
            locked: false, floatingNotes: source.floatingNotes,
            segmentationDefault: source.segmentationDefault,
            lastTouchedAt: now, wingId: destinationWing ?? source.wingId,
            createdAt: now, updatedAt: now)
        try copy.insert(db)

        let outcome = try copyPlacements(
            db, from: sourceID, into: copy.id,
            chosenPicks: chosenPicks, carryFans: carryFans, now: now)

        guard let (anchorSource, anchorCopy) = outcome.firstPair else {
            throw OperationError.postHasNoBlocks(id: sourceID)
        }
        let versionEdge = try insertVersionOfEdge(
            db, anchorSource, anchorCopy, originOp: "manual", now: now)

        // The copy starts "clean": baseline = its rendered length, zero
        // churn — first edits accumulate against real content, exactly like
        // a post that just crossed a threshold (AppSpec §10's rebaseline).
        copy.baselineLength = outcome.renderedLength
        try copy.update(db)

        return PostCopyResult(
            post: copy, blockCopies: outcome.blockCopies, versionEdge: versionEdge,
            blocks: outcome.minted)
    }

    /// What one run of the block-copy loop produced.
    struct PlacementCopyOutcome {
        var blockCopies: [(source: String, copy: String)] = []
        var renderedLength = 0
        /// `(source block, its copy)` for the FIRST slot that copied — the
        /// `version_of` anchor's pair where a caller mints one.
        var firstPair: (String, String)?
        /// VX-311 (VX-336 U6a — D-311-4): each copied block's record, from the
        /// rows this loop wrote (additive — no caller's rows change).
        var minted: [MintedBlockTakes] = []
    }

    /// **The block-copy loop, over an EXISTING target container** (the
    /// post-13l polish round, ledger row 23 — V4's identity-preserving
    /// restore).
    ///
    /// It was `copyPost`'s body verbatim and is unchanged by the extraction:
    /// `copyPost` still inserts its container, calls this, mints the
    /// `version_of` anchor and rebaselines. What the split buys is the one
    /// thing V4 needs and no copy operation had — copying a family INTO a
    /// container that already exists, so *"the live note's CONTENT becomes the
    /// chosen version's"* without the container ever crossing the live/version
    /// line (her seventh-sitting catch, which is the whole reason restore is
    /// not a swap).
    func copyPlacements(
        _ db: Database, from sourceID: String, into targetID: String,
        chosenPicks: [String: String]?, carryFans: Bool, now: Date
    ) throws -> PlacementCopyOutcome {
        let placements = try ContainerBlock
            .filter(Column("container_id") == sourceID && Column("deleted_at") == nil)
            .order(Column("position"), Column("id"))
            .fetchAll(db)

        var outcome = PlacementCopyOutcome()

        for placement in placements {
            guard let block = try Block.fetchOne(db, key: placement.blockId),
                  block.deletedAt == nil
            else { continue }  // gap slots (SyncSpec §5) copy as nothing

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
            // **17b P5 (RUN A, batch A1) — A PICK IS HONOURED ONLY WHILE IT
            // IS A LIVE ACTIVE TAKE**, which is what `promotePicks`' own
            // docstring has always promised ("a pick naming a take that
            // isn't live on its block falls through harmlessly") and what
            // its two siblings already enforce (`effectiveLensSelection`
            // joins `AND v.status = 'active'`; `adoptPicksPreservingChosen`
            // validates `take.status == .active`). The fan read above
            // filters tombstones and NOTHING ELSE, so an ARCHIVED take used
            // to resolve here — and under `carryFans: false` it became the
            // copy's only take: a live placed block with zero live ACTIVE
            // variants (I10 at birth), refusing every keystroke through
            // `editableVariant`. The words were wrong too: the board falls
            // through to the slot's chosen the moment a pick leaves the
            // live active fan (`TakesViewModel.resolvedTake`), so the
            // column was showing one take while the door labelled "only
            // what this column shows" copied another.
            //
            // Treating a stale pick as NO PICK — for `shownVariant` AND for
            // the chosen pointer — is what makes the copy show exactly what
            // the column showed, on both `carryFans` arms.
            let livePick = chosenPicks?[block.id].flatMap { pick in
                fan.first { $0.id == pick && $0.status == .active }
            }
            // Which variant each slot of the copy CHOOSES: the source
            // slot's own chosen (duplicate, and any slot whose pick went
            // stale), or the lens's effective pick where a live one exists
            // (promote) — the ONE difference between the two operations.
            let sourceChosenID = livePick?.id ?? placement.chosenVariantId
            let shownVariant = livePick ?? resolved

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

            // 13e E4's rider: THE one fan-copy machine (`copyFan`) — its
            // second pass lands a parent sitting LATER in fan order, which
            // reorder-takes made reachable (the KnownIssues row's FIX-2).
            let copied = try copyFan(db, takes: toCopy, toBlock: blockCopy.id, now: now)
            let copyIDs = copied.copyIDs
            let copiedVariants = copied.variants

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
                id: newID(), containerId: targetID, blockId: blockCopy.id,
                position: placement.position, chosenVariantId: chosenCopyID,
                createdAt: now, updatedAt: now)
                .insert(db)

            _ = try insertLineageEdge(
                db, from: blockCopy.id, to: block.id, originOp: "manual", now: now)
            // Phase 13 (A2) travel: working notes ride both copy operations
            // (duplicate-as-version AND promote — the plan's letter).
            try copyLiveComments(db, from: block.id, to: blockCopy.id, now: now)

            if outcome.firstPair == nil { outcome.firstPair = (block.id, blockCopy.id) }
            outcome.blockCopies.append((source: block.id, copy: blockCopy.id))
            // VX-311 (VX-336 U6a — D-311-4, F-3 (a)): what this slot MINTED,
            // said from the rows just written (never a second read): the copy's
            // ACTIVE takes in the store's own fan order — the copies' own
            // `(fan_position, id)`, exactly what `read_note` lists — and the
            // take it SHOWS by the read-time rule (the chosen copy while it is
            // an active take, else the default copy, else the first active —
            // AppSpec §7's fallback, read_note's own). Archived copies ride the
            // note (her door's) but sit outside the fan, as read_note's resting
            // answer has them.
            let activeCopies = copiedVariants.filter { $0.status == .active }
                .sorted { ($0.fanPosition, $0.id) < ($1.fanPosition, $1.id) }
            let activeIDs = Set(activeCopies.map(\.id))
            let shownCopyID = [chosenCopyID, defaultCopyID].compactMap { $0 }.first(where: activeIDs.contains)
                ?? activeCopies.first?.id ?? defaultCopyID
            outcome.minted.append(MintedBlockTakes(
                blockID: blockCopy.id, shownTakeID: shownCopyID,
                takes: activeCopies.map { MintedTake(id: $0.id, label: $0.label, text: $0.workingText) },
                sourceBlockID: block.id))
            if let shownText = (chosenCopyID.flatMap { id in copiedVariants.first { $0.id == id } }
                                ?? copiedVariants.first(where: { $0.id == defaultCopyID }))?
                .workingText, !shownText.isEmpty {
                outcome.renderedLength += shownText.count
            }
        }
        return outcome
    }

    /// Inverse of the post-minting copy operations: tombstone the minted
    /// container — the ordinary cascade takes its placements, blocks,
    /// variants, and edges (all fresh rows by construction), and
    /// `restoreContainer` remains the recovery door if the author undoes a
    /// copy she had already worked in (deleted posts are recoverable —
    /// nothing typed becomes unreachable). Already-dead ⇒ obsolete no-op.
    ///
    /// Returns the stamp it wrote — nil when the container was already dead
    /// (her Delete since, a sync tombstone): R2-1's rule, so the entry
    /// retires and its stamp-keyed redo (`reapplyMintedContainer`) never runs
    /// (VX-119, VX-246 U2).
    func revertMintedContainer(_ containerID: String) throws -> String? {
        try database.write { db in
            guard var container = try Container.fetchOne(db, key: containerID),
                  container.deletedAt == nil
            else { return nil }
            let now = date.now
            container.deletedAt = now
            container.updatedAt = now
            try container.update(db)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }
}
