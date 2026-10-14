import Dependencies
import Foundation
import GRDB

// **THE VERSIONS FAMILY** (the post-13l polish round, ledger rows 16 and 23 —
// G1 and the V-rulings). The Google-Docs answer, in this model's own terms:
// *"my whole note at this point in time."*
//
// Nothing here is a new CONCEPT. A saved version is the copy operation the app
// has had since Phase 11, plus two states it already has (archive hides it, the
// seal freezes it) and one edge it already mints (`version_of` classifies it) —
// V4b's three-mechanisms line, each doing its own job. Zero schema.
extension Operations {
    // MARK: - Save a version (G1 · V4b · V5 · V6)

    /// **SAVE A VERSION — the whole note as it is, at this moment.**
    ///
    /// ONE transaction: a full family copy (blocks · takes · comments —
    /// V7's honest cost, chosen), minted **ARCHIVED and SEALED at birth**.
    ///
    /// - **born archived** (`archived_at == created_at`, from ONE clock read)
    ///   is the classifier — `Queries.noteVersions` lists exactly this, and
    ///   `Queries.archivedPosts` excludes exactly this, so a note with fifteen
    ///   moments never drowns the Archived surface (V1);
    /// - **born sealed** is the freeze (V4b, from her seventh-sitting question
    ///   *"can archived notes be edited?"* — yes, archive is visibility, so a
    ///   moment that must not drift needs the seal, which already refuses
    ///   edits, commits and pointer changes) — **and the seal insures what it
    ///   protects** (the ladder's LR1-2): one quiet auto commit per copied
    ///   take, AppSpec §9's `lockPost` occasion applied, so a promoted moment
    ///   is never one edit away from being unrecoverable;
    /// - **no title mutation** (V6): the listing shows the DATE by derived
    ///   display, and the copy's own title is never touched.
    ///
    /// **The copy carries NO `entry_date`, and that is the V3 MUST-PIN.** The
    /// notebook rule's day lookup (`canonicalJournalEntry`) reads every LIVE
    /// journal-profile container with an `entry_date`, and a day with more
    /// than one is the converged double-create case every day door then has
    /// to pick from (the retired Fragments bridge's day scan PAUSED such a
    /// day outright — the pin's original reason, 2026-08-24; the pin stands
    /// on the notebook rule alone). `copyPost` copies `entry_date` verbatim, so
    /// without this line saving a version of a journal entry would silently
    /// stop that day pushing. Dropping the date is the honest fix as well as
    /// the safe one: **a saved moment is not a day.** The day belongs to the
    /// live note, the notebook rule allows exactly one entry per day, and the
    /// listing dates a version by when it was SAVED. It also survives PROMOTE
    /// correctly — a promoted version becomes a first-class note that does not
    /// claim a day another note already holds.
    ///
    /// Refuses a blockless note (`postHasNoBlocks`, `copyPost`'s own guard —
    /// there is no moment to save yet). A SEALED note may be saved: reading is
    /// not authoring, and the source is never touched.
    @discardableResult
    public func saveNoteVersion(_ postID: String) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try mintNoteVersion(db, of: postID)
        }
        registerMintedContainerEntry(label: "Save a Version", result.post.id)
        return result
    }

    /// The mint, inside a caller's transaction — `saveNoteVersion`'s body and
    /// the first step of `restoreNoteVersion` (which must be ONE transaction
    /// with the swap, and must register no entry of its own).
    @discardableResult
    func mintNoteVersion(_ db: Database, of postID: String) throws -> PostCopyResult {
        let copied = try copyPost(db, sourceID: postID, chosenPicks: nil, carryFans: true)
        var version = copied.post
        // ONE clock read decides both stamps: `copyPost` wrote `created_at`,
        // and the birth fact is that `archived_at` EQUALS it. Reading
        // `date.now` again here would be a second tick and the classifier
        // would be a coin-flip on how fast the machine is.
        version.archivedAt = version.createdAt
        version.locked = true
        version.lockedAt = version.createdAt
        version.entryDate = nil  // V3 — see the door's comment above
        version.updatedAt = version.createdAt
        // **THE SEAL INSURES WHAT IT PROTECTS** (the ladder's LR1-2) —
        // AppSpec §9's ruled doctrine, APPLIED rather than re-invented. This
        // is `lockPost`'s own helper, called for `lockPost`'s own reason: the
        // line below seals the copy, and sealing a post auto-commits its
        // dirty buffers first. Not a seventh quiet occasion — the same one.
        //
        // It matters because a COPY carries no commits (the pool-drag rule,
        // and right): a moment's takes were born with zero savepoints, which
        // the seal hid until PROMOTE took the seal off — and then one edit
        // destroyed the moment's own text with nothing to restore it from and
        // no Trash row to find. An EMPTY take still takes none (`isDirty`'s
        // own answer, the landed-deletion rule).
        //
        // Ordered exactly as `lockPost` orders it: commit, then freeze. One
        // per copied take, so the cost is the fan's, never the corpus's.
        _ = try autoCommitDirtyVariants(db, containerID: version.id, now: version.createdAt)
        try version.update(db)
        return PostCopyResult(
            post: version, blockCopies: copied.blockCopies, versionEdge: copied.versionEdge)
    }

    // MARK: - Restore (V4, her fifth + seventh + eighth sittings)

    /// What a restore did, for the door's receipt and the row-level pins.
    public struct NoteVersionRestore: Equatable, Sendable {
        /// The version of NOW this restore saved FIRST — nil only when the
        /// note had no blocks, in which case there was no moment to save.
        public let savedVersionID: String?
        public let restoredFrom: String
        public let blocksRestored: Int
        /// The outgoing blocks that took the Delete Now road.
        public let blocksRemoved: Int
    }

    /// **RESTORE A VERSION — the note BECOMES its past, keeping its identity.**
    ///
    /// Her fifth-sitting ratification (*"I really like the restore as swap
    /// idea"*) sharpened by her seventh-sitting catch, which was right: if the
    /// restore swapped CONTAINER roles, the once-live note would be
    /// archived-LATER — never version-classed, orphaned from its own listing,
    /// and immune to riding deletions. **So no container ever crosses the
    /// live/version line.** ONE transaction:
    ///
    /// 1. **save a version of NOW** (a fresh born-archived copy) — always
    ///    first, so the restore is repeatable and nothing is a one-way door;
    /// 2. the outgoing blocks take the **DELETE NOW road** — tombstone plus a
    ///    purge intent per block, in this transaction. Her eighth-sitting
    ///    ruling: *"it's fine to just instantly hard delete those remaining
    ///    blocks — there's no loss risk."* The S2-safe implementation of
    ///    "instant hard delete" is exactly this, never a raw row DELETE: the
    ///    intent's read-side fence hides the rows from the Trash, the tray and
    ///    everything else the moment it lands, and the janitor removes the
    ///    bytes on its ordinary horizon;
    /// 3. the version's family is **copied in** at the version's own order —
    ///    fresh rows, so the version itself stays sealed, archived and
    ///    untouched;
    /// 4. **every version link is re-anchored** onto the note's new first
    ///    block (see below);
    /// 5. the note is TOUCHED without churn — restructuring is working on the
    ///    note, but it must not reshuffle the meaningful sort (AppSpec §9).
    ///
    /// **Why step 4 exists, and it is not optional.** A post-level version
    /// link RIDES a block-level edge anchored on the note's first block (I8).
    /// Step 2 deletes that block — so without re-anchoring, restoring a version
    /// would silently sever the note from EVERY version it has, including the
    /// one saved seconds earlier in step 1. Each peer gets one fresh edge to
    /// the new first block; a peer that is already linked is skipped.
    ///
    /// **And the peers are enumerated THE CLASSIFIER'S WAY** (the ladder's
    /// LR2-1, correcting this doc's own earlier claim that they are "read
    /// while their links are still live"). `versionPeerPosts` fences all three
    /// liveness reads — the note-side placement, the peer-side placement, the
    /// edge — which is exactly the fence LR1-1 had to remove from the
    /// classifier, because merge, divide-W and `archiveBlock` release the
    /// anchor's placement and `deleteBlock` cascade-tombstones its edge. So
    /// the moments LR1-1 rescued were precisely the ones step 4 skipped: they
    /// stayed listed while their only link went on hanging off a block the
    /// note no longer places, which the tombstone-tolerant read can carry only
    /// for as long as the ROW exists. It does not last: a deleted anchor rides
    /// its own 30-day clock (or a Delete Now), and a released original strands
    /// into a purge family the moment its last descendant goes — and
    /// `PurgeFamily.expandBlock` takes every edge a purged block carries. Once
    /// the janitor executes there is nothing left to read past, and the moment
    /// silently unlinks: out of the listing, ONTO the Archived surface as a
    /// sealed stranger, orphaned from the deletion ride, Restore and Promote
    /// refusing.
    ///
    /// Hence `Queries.noteVersionIDs` — the classifier itself, asked before
    /// step 2 takes anything — unioned with the live compare peers, which
    /// carry the version links that are NOT version history (`markPostsAsVersions`
    /// and `duplicateAsVersion`'s live forks). **One classifier, read by every
    /// scope, this operation's read included** (LR1-5's doctrine).
    ///
    /// **What it deliberately leaves alone:** the note's ARCHIVED blocks and
    /// its preserved originals have no live placement, so they are not
    /// outgoing. Archive is forever and rides no deletion — the covenant.
    ///
    /// **NO undo entry** (the recovery-door class, with `restoreReading` and
    /// `restoreSection` as the precedent): the door IS the recovery, and its
    /// road back is the version of NOW that step 1 always saves. An inverse
    /// would also be a lie — step 2's purge intents are the one act in this
    /// app with no way back, which is exactly why step 1 comes first.
    ///
    /// Refuses a sealed note (replacing a note's whole content is authoring),
    /// and refuses anything that is not this note's saved version
    /// (`notVersionHistory` — the classifier's own answer, asked inside this
    /// transaction rather than taken from a listing).
    @discardableResult
    public func restoreNoteVersion(
        _ postID: String, from versionID: String
    ) throws -> NoteVersionRestore {
        // **AND IT CLEARS THE REDO FUTURE** (17b P6): no entry is registered
        // here — the door IS the recovery — but replacing a note's whole
        // content is unmistakably a new structural act, and AppSpec §9's
        // rule has no exception for acts that happen not to be undoable. It
        // runs AFTER the write, so a refused restore (a seal, a version that
        // is not this note's) leaves her future exactly as it found it.
        // Like `register`, the clear sits OUTSIDE the transaction: a future
        // compound composing this op as a leg and then rolling back would
        // still have cleared the future — the recorded R1-10 class (13c
        // Stage 1), accepted; no caller composes it today (ladder round 1,
        // hazard note).
        let restored: NoteVersionRestore = try database.write { db in
            let post = try livePost(db, postID)
            try ensureUnlocked(post)
            guard try Queries.isVersionHistory(db, versionID, of: postID) else {
                throw OperationError.notVersionHistory(version: versionID, note: postID)
            }
            let now = date.now

            // Read the peers BEFORE step 2 takes the block they are anchored
            // on — and read them the CLASSIFIER's way (the ladder's LR2-1):
            // the moments this note HAS, whatever ordinary work has done to
            // the anchor's placement or edge, plus the live compare peers
            // that are not version history at all.
            var peers = try Queries.noteVersionIDs(db, of: postID)
            peers.append(contentsOf: try Queries.versionPeerPosts(db, of: postID))

            // 1 — the version of NOW.
            let outgoing = try ContainerBlock
                .filter(Column("container_id") == postID && Column("deleted_at") == nil)
                .order(Column("position"), Column("id"))
                .fetchAll(db)
            var savedVersionID: String?
            if !outgoing.isEmpty {
                let saved = try mintNoteVersion(db, of: postID)
                savedVersionID = saved.post.id
                peers.append(saved.post.id)
            }

            // 2 — the outgoing blocks, on the Delete Now road.
            var removed = 0
            for placement in outgoing {
                guard var block = try Block.fetchOne(db, key: placement.blockId),
                      block.deletedAt == nil
                else { continue }
                // The tray's access path, recorded exactly as `deleteBlock`
                // records it — the intent hides the row either way, and a
                // block whose intent is later voided must still know its home.
                block.lastContainerId = postID
                block.deletedAt = now
                block.updatedAt = now
                try block.update(db)  // the trigger chain takes placement/takes/edges/tags
                _ = try mintPurgeIntents(
                    db, [SyncPurgeTarget(table: "block", rowID: block.id)], now: now)
                removed += 1
            }

            // 3 — the version's family, into the SAME container.
            let landed = try copyPlacements(
                db, from: versionID, into: postID,
                chosenPicks: nil, carryFans: true, now: now)

            // 4 — re-anchor every version link onto the new first block.
            if let newFirst = landed.blockCopies.first?.copy {
                for peer in Set(peers) where peer != postID {
                    guard let peerBlock = try Self.firstLivePlacedBlock(db, of: peer)
                    else { continue }
                    do {
                        _ = try insertVersionOfEdge(
                            db, newFirst, peerBlock, originOp: "manual", now: now)
                    } catch OperationError.versionLinkExists {
                        continue  // already joined — nothing to re-anchor
                    }
                }
            }

            // 5 — touch without churn (the structural-op rule, AppSpec §9),
            // and REBASELINE (the ladder's LR1-6).
            //
            // The churn counters describe how far the note has drifted from a
            // length (AppSpec §10: `churn / max(baseline, 1) ≥ threshold`).
            // A restore replaces the note's whole content, so both numbers
            // now describe text that is no longer here — a long note restored
            // to a short moment would cross on the next typo; a short one
            // restored to a long moment would never cross at all. `copyPost`
            // rebaselines its copy for exactly this reason; this is the same
            // act on the same container, off the same number the copy loop
            // already returned. The `last_major_revision_at` stamp is
            // deliberately NOT moved: restructuring must never reshuffle the
            // meaningful sort, which is the same rule the touch obeys.
            var touched = post
            touched.lastTouchedAt = now
            touched.churnAccumulator = 0
            touched.baselineLength = landed.renderedLength
            touched.updatedAt = now
            try touched.update(db)

            return NoteVersionRestore(
                savedVersionID: savedVersionID, restoredFrom: versionID,
                blocksRestored: landed.blockCopies.count, blocksRemoved: removed)
        }
        undoStack?.clearRedoFuture()
        return restored
    }

    // MARK: - Promote (V1's "work with it as a new note" road)

    /// **PROMOTE — the past becomes a NEW first-class note.**
    ///
    /// Her V1 ruling: *"Unarchiving a version PROMOTES it — it goes live,
    /// leaves the Versions listing, becomes first-class forever."* Which is
    /// two column writes and nothing else, because the classifier is derived:
    /// clearing `archived_at` breaks the born-archived half, so the row stops
    /// being version history the instant it goes live, and **a later re-archive
    /// stamps a NEW `archived_at ≠ created_at`, which makes it a WORK she set
    /// aside** — never version history again. That derivation is the "forever"
    /// in her sentence, and it is pinned.
    ///
    /// The seal comes off with the archive: the freeze existed to keep the
    /// moment a moment, and a promoted version is a note to write in.
    ///
    /// **No undo entry**, deliberately: it is a one-way act by her ruling, and
    /// an inverse that restored `archived_at = created_at` would quietly
    /// re-mint a birth fact this row no longer has.
    ///
    /// Refuses anything that is not version history of the named note.
    public func promoteNoteVersion(_ versionID: String, of postID: String) throws {
        try database.write { db in
            guard try Queries.isVersionHistory(db, versionID, of: postID) else {
                throw OperationError.notVersionHistory(version: versionID, note: postID)
            }
            var version = try liveContainer(db, versionID)
            version.archivedAt = nil
            version.locked = false
            version.lockedAt = nil
            version.updatedAt = date.now
            try version.update(db)
        }
    }

    // MARK: - Internals

    /// A container's first live placed block, in the order the note reads —
    /// the `version_of` anchor's own rule, made shared rather than typed a
    /// second time. **And now actually consumed there** (17o c/d/e ladder
    /// round 1, NIT-2): `markPostsAsVersions`' anchor (`Operations+Versions
    /// .swift`, `firstBlock` until 17o batch d renamed it `anchorBlock`) had
    /// kept its own inline copy, and the two disagreed — this one JOINs
    /// `block` on liveness and the copy did not. This is the rule; a live
    /// placement over a tombstoned block is not a place to anchor an edge.
    static func firstLivePlacedBlock(_ db: Database, of containerID: String) throws -> String? {
        try String.fetchOne(
            db,
            sql: """
                SELECT cb.block_id FROM container_block cb
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id LIMIT 1
                """,
            arguments: [containerID])
    }
}
