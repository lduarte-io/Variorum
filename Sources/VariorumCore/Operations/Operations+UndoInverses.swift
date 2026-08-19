import Dependencies
import Foundation
import GRDB

// The internal revert operations structural undo emits (AppSpec §9). Each is
// an ordinary single-transaction operation — outbox capture and cascade
// rules apply like anywhere else, so sync never knows undo exists. They are
// exact-row inverses: tombstone/status flips plus pre-image restores, never
// fresh rows — which is why do → undo round-trips to row equality. They are
// internal (never registered, never public): only the undo stack calls them.
//
// 13c batch 1B (A10) adds the RE-APPLY half beside each inverse — structural
// REDO. Same doctrine, other direction: exact rows from the SAME do-time
// pre-images, never a re-run of the forward operation (a re-run would mint
// fresh UUIDs and strand the inverse that captured the old ones). Most
// re-applies are the existing inverse called with the other pre-image
// (`restorePlacementLocation`, `revertChosenPointers`); the two that need
// their own body are `reapplyStructural` and `reapplyMintedContainer`.
// None of them registers — so a redo, like an undo, never clears the redo
// stack from under itself.
extension Operations {
    /// Inverse of `deleteBlock`: flip the block, its cascade victims, AND the
    /// original placement row (position + chosen variant intact). The public
    /// `restoreBlock` tray gesture flips the same stamp-matched row when it
    /// survives (13j F2), minting fresh at the end only as its fallback.
    /// The placement stays dead if its container has since died;
    /// a since-locked container refuses (resolve, then retry the undo).
    /// A block already alive (restored from the tray meanwhile) makes this
    /// entry obsolete — a quiet no-op success, so the pop happens and the
    /// stack never wedges on an unresolvable refusal.
    func revertDeleteBlock(_ blockID: String) throws {
        try database.write { db in
            guard var block = try Block.fetchOne(db, key: blockID) else {
                throw OperationError.blockNotFound(id: blockID)
            }
            guard let deletedAt = block.deletedAt else { return }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now

            if let placementRow = try Row.fetchOne(
                db,
                sql: "SELECT id, container_id FROM container_block WHERE block_id = ? AND deleted_at = ?",
                arguments: [blockID, stamp]),
               let container = try Container.fetchOne(db, key: placementRow["container_id"] as String),
               container.deletedAt == nil {
                try ensureUnlocked(container)
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                    arguments: [
                        DateFormatter.variorumISO8601.string(from: now),
                        placementRow["id"] as String,
                    ])
            }

            block.deletedAt = nil
            block.updatedAt = now
            try block.update(db)
            try flipBlockCascadeTombstones(db, blockID: blockID, stamp: stamp, now: now)
            // 13j ladder B (B1): the ⌥⌘Z road is the single-device door of
            // the stale-intent hole — a restored row voids any live intent
            // naming it, or a Delete Now confirmed BETWEEN the delete and
            // this undo would still purge the row she just brought back.
            try voidPurgeIntents(db, table: "block", rowID: blockID)
        }
    }

    /// Inverse of `deleteVariant`: flip the tombstone and, when the variant
    /// had been the block default, point the default back at it. The block
    /// must still be live (its own deletion supersedes this entry — undoing
    /// would strand a live variant under a dead block) and its post unsealed
    /// (the seal refuses everything under the post, undo included); either
    /// refusal leaves the entry on the stack for retry.
    func revertDeleteVariant(_ variantID: String, wasDefault: Bool) throws {
        try database.write { db in
            guard var variant = try Variant.fetchOne(db, key: variantID) else {
                throw OperationError.variantNotFound(id: variantID)
            }
            _ = try liveBlock(db, variant.blockId)
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            let now = date.now
            if variant.deletedAt != nil {
                variant.deletedAt = nil
                variant.updatedAt = now
                try variant.update(db)
                // 13j ladder B (B1): the ⌥⌘Z road voids any live intent
                // naming the restored take (revertDeleteBlock's reason).
                try voidPurgeIntents(db, table: "variant", rowID: variantID)
            }
            if wasDefault {
                try restoreDefaultVariant(db, blockID: variant.blockId, to: variantID, now: now)
            }
        }
    }

    /// Inverse of `archiveVariant`: back to active, default pointer
    /// restored. Same seal guard as every other write under a post.
    func revertArchiveVariant(_ variantID: String, wasDefault: Bool) throws {
        try database.write { db in
            try unarchiveTakeRow(db, variantID: variantID, wasDefault: wasDefault)
        }
    }

    /// The un-archive ROW work, shared (13e batch 3): `revertArchiveVariant`
    /// is this in its own transaction, and `revertStructural` runs it inside
    /// the transaction that also tombstones the blocks a take↔block
    /// conversion minted — one archive-inverse brain, two callers.
    private func unarchiveTakeRow(
        _ db: Database, variantID: String, wasDefault: Bool
    ) throws {
        var variant = try liveVariant(db, variantID)
        try ensurePlacementUnlocked(db, blockID: variant.blockId)
        let now = date.now
        if variant.status == .archived {
            variant.status = .active
            variant.updatedAt = now
            try variant.update(db)
        }
        if wasDefault {
            try restoreDefaultVariant(db, blockID: variant.blockId, to: variantID, now: now)
        }
    }

    /// Inverse of `moveBlock` and `reorder`: put the live placement back at
    /// its exact pre-image location — same container, same position string.
    func restorePlacementLocation(
        _ blockID: String, containerID: String, position: String
    ) throws {
        try database.write { db in
            guard var placement = try livePlacement(db, blockID: blockID) else {
                throw OperationError.blockNotPlaced(id: blockID)
            }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            if placement.containerId != containerID {
                try ensureUnlocked(try liveContainer(db, containerID))
            }
            placement.containerId = containerID
            placement.position = position
            placement.updatedAt = date.now
            try placement.update(db)
        }
    }

    /// Inverse (and, with the other pre-image, the re-apply) of
    /// `reorderTake`: put the take back at its exact pre-image `fan_position`.
    /// The `restorePlacementLocation` shape, one table over — exact-row, never
    /// a fresh key. The take must still be live and its post unsealed; either
    /// refusal leaves the entry on the stack for retry.
    func restoreFanPosition(_ variantID: String, position: String) throws {
        try database.write { db in
            var variant = try liveVariant(db, variantID)
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            guard variant.fanPosition != position else { return }
            variant.fanPosition = position
            variant.updatedAt = date.now
            try variant.update(db)
        }
    }

    /// One buffer's do-time images, for `revertStructural`: the text before
    /// the structural op (what undo restores) and the text the op wrote
    /// (how undo recognizes a buffer that diverged afterwards).
    struct TextPreImage: Sendable {
        let variantID: String
        let text: String
        let postOpText: String
    }

    /// **The insurance question, asked ONCE (13d batch 5 — ledger A12).**
    /// True when restoring this pre-image would overwrite a buffer the
    /// author edited SINCE the structural operation — the case the fourth
    /// quiet auto-commit occasion insures (OverallModel §3). `revertStructural`
    /// consults it to decide the commit; `UndoStack.pendingUndoWarning`
    /// consults the same predicate to decide the author's confirm, so the
    /// dialog and the commit can never disagree about what the class IS.
    ///
    /// Unchanged buffers (still the op's own output) and buffers already
    /// back at the pre-image are not the class; neither is a diverged buffer
    /// whose divergence is already committed (`dirty == false`) — nothing
    /// would be set aside that a commit does not already hold.
    static func wouldInsure(currentText: String, preImage: TextPreImage, dirty: Bool) -> Bool {
        currentText != preImage.text && currentText != preImage.postOpText && dirty
    }

    /// The variants a structural undo over `preImages` would insure, right
    /// now — the A12 warning's whole input. **Never throws and never
    /// writes:** it is asked on the way to a dialog, and a store hiccup must
    /// degrade to "no warning" (the undo itself still insures — the commit
    /// is inside `revertStructural`'s transaction, not here), never to a
    /// blocked undo. A variant that has since died or been re-pointed
    /// answers no: `revertStructural` would refuse or skip it.
    func insuranceTargets(_ preImages: [TextPreImage]) -> [String] {
        guard !preImages.isEmpty else { return [] }
        return (try? database.read { db in
            try preImages.compactMap { preImage -> String? in
                guard let variant = try Variant.fetchOne(db, key: preImage.variantID),
                      variant.deletedAt == nil
                else { return nil }
                return Self.wouldInsure(
                    currentText: variant.workingText, preImage: preImage,
                    dirty: try isDirty(db, variant)) ? preImage.variantID : nil
            }
        }) ?? []
    }

    /// A freshly minted block as the structural op made it, for
    /// `revertStructural`: variantID → working_text at mint time, so undo
    /// can tell an untouched mint (vanishes as if never made) from one the
    /// author worked on since (lands in the tray).
    struct MintedPreImage: Sendable {
        let blockID: String
        let birthTexts: [String: String]

        init(_ blockID: String, _ variants: [Variant]) {
            self.blockID = blockID
            self.birthTexts = Dictionary(
                uniqueKeysWithValues: variants.map { ($0.id, $0.workingText) })
        }
    }

    /// Inverse of the block-minting structural ops (extract, divide,
    /// divide-W, merge, poolDragCopy): restore edited buffers to their
    /// pre-image text, tombstone the freshly minted blocks (the trigger
    /// chain cascades to their variants, placements, and edges — fresh rows
    /// by construction, so nothing else carries their stamp), and flip
    /// released placement rows back live, exact position and chosen variant
    /// intact.
    ///
    /// Refusal buckets per the Phase 2 rule: **resolvable refusals throw**
    /// and keep the entry — a sealed container (unlock, retry), a dead,
    /// archived, or locked buffer-restore target (restore/unarchive/unlock,
    /// retry). **Divergence is left alone quietly** — a minted block already
    /// deleted stays deleted; a released block re-homed meanwhile keeps its
    /// new placement (I2) and one whose block or container died stays
    /// released. An *untouched* mint vanishes as if never made — no
    /// `lastContainerId`, so it never haunts the deleted-blocks tray. But a
    /// mint whose fan diverged since do-time (a buffer edited, a take
    /// branched) carries author work: its tombstone is stamped with its
    /// current home so the tray can reach it (the insurance doctrine's
    /// mirror case — nothing typed becomes unreachable; Phase 3 review
    /// finding, on the ratify list).
    ///
    /// `unarchivingTakes` is 13e batch 3's half (E5/E6b — the take↔block
    /// doors): those operations mint a block AND archive the take it came
    /// from, so their inverse must do both, in ONE transaction. Defaulted
    /// empty, so every pre-13e caller reads unchanged. The takes come back
    /// FIRST — restoring the source block's fan before the mints go, so no
    /// intermediate state has a live block with nothing in it.
    func revertStructural(
        restoringTexts: [TextPreImage],
        tombstoningBlocks: [MintedPreImage],
        revivingPlacementRows: [String],
        unarchivingTakes: [(variantID: String, wasDefault: Bool)] = []
    ) throws {
        try database.write { db in
            let now = date.now

            for take in unarchivingTakes {
                // Divergence is quiet (the standing bucket): a take deleted
                // since — or whose row is gone — means the world moved past
                // this entry. A SEALED post still throws, keeping the entry.
                guard let variant = try Variant.fetchOne(db, key: take.variantID),
                      variant.deletedAt == nil
                else { continue }
                try unarchiveTakeRow(
                    db, variantID: take.variantID, wasDefault: take.wasDefault)
            }

            for preImage in restoringTexts {
                var variant = try liveVariant(db, preImage.variantID)
                _ = try liveBlock(db, variant.blockId)
                try ensurePlacementUnlocked(db, blockID: variant.blockId)
                try ensureEditable(variant)
                guard variant.workingText != preImage.text else { continue }
                if Self.wouldInsure(
                    currentText: variant.workingText, preImage: preImage,
                    dirty: try isDirty(db, variant)) {
                    // The buffer diverged after the structural op and the
                    // restore is about to overwrite it: insure first — the
                    // fourth quiet auto-commit occasion, mirroring
                    // lockVariant/lockPost/long-idle (the ratified doctrine:
                    // a quiet commit insures exactly what an operation is
                    // about to make unreachable). Phase 3 review finding;
                    // on the closeout ratify list.
                    _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now)
                }
                variant.workingText = preImage.text
                variant.updatedAt = now
                try variant.update(db)
            }

            for minted in tombstoningBlocks {
                guard var block = try Block.fetchOne(db, key: minted.blockID),
                      block.deletedAt == nil
                else { continue }  // already gone — the world moved past this
                try ensurePlacementUnlocked(db, blockID: minted.blockID)
                let liveVariants = try Variant.fetchAll(
                    db,
                    sql: "SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [minted.blockID])
                let diverged = liveVariants.contains {
                    minted.birthTexts[$0.id] != $0.workingText
                }
                if diverged, let placement = try livePlacement(db, blockID: minted.blockID) {
                    block.lastContainerId = placement.containerId
                }
                block.deletedAt = now
                block.updatedAt = now
                try block.update(db)
            }

            for rowID in revivingPlacementRows {
                guard let row = try ContainerBlock.fetchOne(db, key: rowID),
                      row.deletedAt != nil,
                      let block = try Block.fetchOne(db, key: row.blockId),
                      block.deletedAt == nil,
                      let container = try Container.fetchOne(db, key: row.containerId),
                      container.deletedAt == nil
                else { continue }
                try ensureUnlocked(container)
                guard try livePlacement(db, blockID: row.blockId) == nil else { continue }
                var revived = row
                revived.deletedAt = nil
                revived.updatedAt = now
                try revived.update(db)
            }
        }
    }

    /// The RE-APPLY half of `revertStructural` (13c 1B — A10): puts back
    /// exactly what the inverse un-did, from the SAME captured pre-images —
    /// released placements re-tombstoned, minted blocks un-tombstoned
    /// (their cascade victims by the stamp the inverse wrote), buffers set
    /// to their post-op text. Exact-row like its mirror: no row is ever
    /// minted here, so undo → redo returns the store to the post-op state
    /// with every ID intact.
    ///
    /// Refusal buckets mirror `revertStructural` exactly: **resolvable
    /// refusals throw** and keep the entry on the redo stack (a sealed
    /// container; a dead, archived, or locked buffer target). **Divergence
    /// is left alone quietly** — a placement already released, a minted
    /// block already alive or gone, stays as it is; the world moved past
    /// this entry and redo pops rather than wedging.
    ///
    /// Insurance rides here too (the quiet-auto-commit doctrine): a buffer
    /// the author edited since the UNDO is about to be overwritten by the
    /// post-op text, so it is committed first — the same fourth-occasion
    /// reasoning that guards `revertStructural`, applied to the other
    /// direction.
    ///
    /// `rearchivingTakes` is 13e batch 3's mirror (E5/E6b): redo puts the
    /// minted blocks back AND re-archives the takes they came from, in ONE
    /// transaction. Defaulted empty, so every pre-13e caller reads
    /// unchanged. Same divergence rule as everywhere here: a take that died
    /// or is already archived is left alone quietly; a sealed post throws
    /// and keeps the entry.
    func reapplyStructural(
        restoringTexts: [TextPreImage],
        untombstoningBlocks: [MintedPreImage],
        releasingPlacementRows: [String],
        rearchivingTakes: [String] = []
    ) throws {
        try database.write { db in
            let now = date.now
            let nowStamp = DateFormatter.variorumISO8601.string(from: now)

            for variantID in rearchivingTakes {
                guard let take = try Variant.fetchOne(db, key: variantID),
                      take.deletedAt == nil, take.status == .active
                else { continue }
                try ensurePlacementUnlocked(db, blockID: take.blockId)
                // I10, on the redo road too: if the other takes have gone
                // since the undo, re-archiving this one would leave a live
                // block with no live active take. Resolvable ⇒ it throws and
                // the entry stays for retry (the `archiveVariant` redo path's
                // own posture, which runs this same guard).
                try ensureNotLastActive(db, take)
                var archived = take
                archived.status = .archived
                archived.updatedAt = now
                try archived.update(db)
                try reassignDefaultIfNeeded(
                    db, blockID: take.blockId, removing: take.id, now: now)
            }

            // Mirror of the inverse's revive: the sources the forward op
            // released to lineage go back out of the post.
            for rowID in releasingPlacementRows {
                guard let row = try ContainerBlock.fetchOne(db, key: rowID),
                      row.deletedAt == nil,
                      let container = try Container.fetchOne(db, key: row.containerId),
                      container.deletedAt == nil
                else { continue }
                try ensureUnlocked(container)
                var released = row
                released.deletedAt = now
                released.updatedAt = now
                try released.update(db)
            }

            // Mirror of the inverse's tombstone: the minted blocks come
            // back with their placement row and stamp-matched cascade
            // victims — `revertDeleteBlock`'s exact shape, since that is
            // literally the transition being reversed.
            for minted in untombstoningBlocks {
                guard var block = try Block.fetchOne(db, key: minted.blockID),
                      let deletedAt = block.deletedAt
                else { continue }  // already alive, or gone — obsolete, quiet
                let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
                if let placementRow = try Row.fetchOne(
                    db,
                    sql: "SELECT id, container_id FROM container_block WHERE block_id = ? AND deleted_at = ?",
                    arguments: [minted.blockID, stamp]),
                   let container = try Container.fetchOne(db, key: placementRow["container_id"] as String),
                   container.deletedAt == nil {
                    try ensureUnlocked(container)
                    try db.execute(
                        sql: "UPDATE container_block SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                        arguments: [nowStamp, placementRow["id"] as String])
                }
                block.deletedAt = nil
                block.updatedAt = now
                try block.update(db)
                try flipBlockCascadeTombstones(db, blockID: minted.blockID, stamp: stamp, now: now)
            }

            for preImage in restoringTexts {
                var variant = try liveVariant(db, preImage.variantID)
                _ = try liveBlock(db, variant.blockId)
                try ensurePlacementUnlocked(db, blockID: variant.blockId)
                try ensureEditable(variant)
                guard variant.workingText != preImage.postOpText else { continue }
                if variant.workingText != preImage.text, try isDirty(db, variant) {
                    _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now)
                }
                variant.workingText = preImage.postOpText
                variant.updatedAt = now
                try variant.update(db)
            }
        }
    }

    /// The RE-APPLY half of `revertMintedContainer` (13c 1B): the minted
    /// post comes back with everything that died with it —
    /// `restoreContainer`'s exact-stamp cascade contract is precisely the
    /// reverse of the tombstone the inverse wrote. Already live (restored
    /// from the recovery surface meanwhile) ⇒ obsolete, quiet.
    func reapplyMintedContainer(_ containerID: String) throws {
        let stillDead = try database.read { db in
            try Container.fetchOne(db, key: containerID)?.deletedAt != nil
        }
        guard stillDead else { return }
        try restoreContainer(containerID)
    }

    /// The RE-APPLY half of `revertImportedBlocks` (13c 1B): the imported
    /// blocks come back — per block, exactly `revertDeleteBlock`'s
    /// transition (it is the same tombstone being reversed).
    func reapplyImportedBlocks(_ blockIDs: [String]) throws {
        for blockID in blockIDs {
            try revertDeleteBlock(blockID)
        }
    }

    private func restoreDefaultVariant(
        _ db: Database, blockID: String, to variantID: String, now: Date
    ) throws {
        var block = try liveBlock(db, blockID)
        guard block.defaultVariantId != variantID else { return }
        block.defaultVariantId = variantID
        block.updatedAt = now
        try block.update(db)
    }
}
