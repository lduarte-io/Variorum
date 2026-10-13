import Dependencies
import Foundation
import GRDB

// The purge-intent door (Phase 13j batch 6b — the memo's §4a: Delete Now
// and Empty Trash "both do the same two things: write a purge intent …
// remove the rows locally the moment the local horizon allows"). This op
// is the FIRST thing: the intent write, through the operations API like
// every mutation. The second — the physical removal — is the janitor's
// (`PurgeJanitor`), horizon-gated, never a door's own act.
extension Operations {
    /// The tables an intent may name: the memo's four Trash roots plus
    /// `commit_point` for savepoint pruning (§4d — "the janitor consults
    /// [the setting] before minting any savepoint purge intent"), plus
    /// `block_comment` since VX-179 (her R-VX179-3, 2026-10-12: a deleted
    /// comment gets "Delete forever…" in the comments panel's deleted fold
    /// — the Delete Now road, confirm each time). A comment is childless, so
    /// `PurgeFamily.expand`'s default arm (the row itself) is its whole
    /// family; the server's purge arrays already carried the table.
    static let purgeableTables: Set<String> = [
        "container", "reading", "block", "variant", "commit_point", "block_comment",
    ]

    /// **Write purge intents** — "this is going, everywhere." One
    /// transaction for the whole batch (Empty Trash is one act); one
    /// intent row per target, deduped against the live-unique
    /// (table_name, row_id) pair, so asking twice is one purge (the act
    /// is idempotent by nature — SyncSpec §7's pure-duplicate repair
    /// covers the cross-device race the same way).
    ///
    /// Refusals: a LIVE container/reading/block/variant/comment refuses
    /// (`purgeTargetNotDeleted` — only things in the Trash purge; a
    /// full-delete door must never exist in a note context, her round-3
    /// rider); a deleted comment under a dead block (`blockNotFound`) or a
    /// sealed post (`lockedPost`) refuses (VX-179); a MANUAL savepoint refuses
    /// (`deliberateSavepointNeverPruned` — her round-9 ruling's belt); an
    /// unknown table refuses (`unsupportedPurgeTarget`). A missing row
    /// with a standing intent skips (already going); a missing row with
    /// no intent refuses through the kind's own not-found error.
    ///
    /// **No undo entry, deliberately**: the confirm is the guard (round
    /// 10 — Delete Now confirms EVERY time), and an undo whose inverse
    /// raced the janitor would be a door that sometimes lies. Not a
    /// recovery door either — it is the recovery story's deliberate END.
    /// No touch, no churn: nothing content-shaped changed.
    ///
    /// Returns the number of intents actually minted (skips excluded).
    @discardableResult
    public func requestPurge(_ targets: [SyncPurgeTarget]) throws -> Int {
        try database.write { db in
            try mintPurgeIntents(db, targets, now: date.now)
        }
    }

    /// **The intent write, inside a caller's transaction** (the post-13l
    /// polish round, ledger row 23 — V4's restore).
    ///
    /// `requestPurge` opens its own write, which is right for a door; a
    /// COMPOSITE that must be one transaction cannot use it. Her eighth-sitting
    /// ruling put the version restore's outgoing blocks on the Delete Now road
    /// *"in the restore's own transaction"*, and a Delete Now is exactly a
    /// tombstone plus this. So the body moves here and the public door keeps
    /// its whole contract by calling it — one implementation of the refusals,
    /// the dedup and the already-purged skip, never two.
    @discardableResult
    func mintPurgeIntents(
        _ db: Database, _ targets: [SyncPurgeTarget], now: Date
    ) throws -> Int {
            var minted = 0
            for target in targets {
                guard Self.purgeableTables.contains(target.table) else {
                    throw OperationError.unsupportedPurgeTarget(table: target.table)
                }
                let standing = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM purge_intent
                        WHERE table_name = ? AND row_id = ? AND deleted_at IS NULL)
                        """,
                    arguments: [target.table, target.rowID]) ?? false
                if standing { continue }

                // A row already GONE with any intent standing (live or
                // completed) is already purged — skip, never re-mint (a
                // fresh intent for a purged id would circulate forever
                // with nothing to complete it).
                guard try validatePurgeable(db, target) else { continue }

                let intent = PurgeIntent(
                    id: newID(),
                    ownerId: currentOwnerID(),
                    tableName: target.table,
                    rowId: target.rowID,
                    requestedAt: now,
                    createdAt: now,
                    updatedAt: now)
                try intent.insert(db)
                minted += 1
            }
            return minted
    }

    /// **The restore-side belt (13j ladder B, B1):** a restore door that
    /// flips a tombstone back VOIDS any live intent naming the row, inside
    /// the restore's own transaction — so a later re-delete can never be
    /// claimed by a leftover intent, and the janitor's sweep-time staleness
    /// check becomes the second net rather than the only one. The voided
    /// intent is an ordinary tombstoned row: the outbox trigger captures
    /// it, so peers stop fencing too. Quiet by design — restoring a row
    /// with no intent standing writes nothing.
    ///
    /// The residual, traced and accepted (the 6b response's race
    /// endpoints): a restore landing on a device that has not yet PULLED
    /// the intent voids nothing here — the sweep-time staleness check
    /// covers that device's own janitor, and the voiding device's
    /// tombstone converges the rest.
    func voidPurgeIntents(_ db: Database, table: String, rowID: String) throws {
        let stamp = DateFormatter.variorumISO8601.string(from: date.now)
        try db.execute(
            sql: """
                UPDATE purge_intent SET deleted_at = :stamp, updated_at = :stamp
                WHERE table_name = :table AND row_id = :row AND deleted_at IS NULL
                """,
            arguments: ["stamp": stamp, "table": table, "row": rowID])
    }

    /// The target must be purgeABLE: tombstoned for the four Trash kinds,
    /// a QUIET savepoint for commit_point, a tombstoned comment under a live,
    /// unsealed block for block_comment (VX-179). Returns whether an intent
    /// should be MINTED — a row already gone with any intent standing
    /// (live or completed) answers false (already purged — idempotence);
    /// gone with no intent at all refuses through the kind's own error.
    private func validatePurgeable(_ db: Database, _ target: SyncPurgeTarget) throws -> Bool {
        func anyIntentStands() throws -> Bool {
            try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM purge_intent WHERE table_name = ? AND row_id = ?)",
                arguments: [target.table, target.rowID]) ?? false
        }
        switch target.table {
        case "container", "reading", "block", "variant":
            guard let row = try Row.fetchOne(
                db, sql: "SELECT deleted_at FROM \(target.table) WHERE id = ?",
                arguments: [target.rowID])
            else {
                if try anyIntentStands() { return false }  // already purged
                switch target.table {
                case "container": throw OperationError.containerNotFound(id: target.rowID)
                case "reading": throw OperationError.readingNotFound(id: target.rowID)
                case "block": throw OperationError.blockNotFound(id: target.rowID)
                default: throw OperationError.variantNotFound(id: target.rowID)
                }
            }
            guard (row["deleted_at"] as String?) != nil else {
                throw OperationError.purgeTargetNotDeleted(table: target.table, id: target.rowID)
            }
            return true
        case "commit_point":
            guard let kind = try String.fetchOne(
                db, sql: "SELECT kind FROM commit_point WHERE id = ?",
                arguments: [target.rowID])
            else {
                if try anyIntentStands() { return false }
                throw OperationError.commitNotFound(id: target.rowID)
            }
            guard kind == "auto" else {
                throw OperationError.deliberateSavepointNeverPruned(id: target.rowID)
            }
            return true
        case "block_comment":
            // VX-179 (R-VX179-3): the comments panel's deleted fold. Only a
            // TOMBSTONED comment purges — a live one refuses exactly as a
            // live note does (the door lives where things are already
            // deleted, never in the writing).
            guard let comment = try BlockComment.fetchOne(db, key: target.rowID) else {
                if try anyIntentStands() { return false }  // already purged
                throw OperationError.commentNotFound(id: target.rowID)
            }
            guard comment.deletedAt != nil else {
                throw OperationError.purgeTargetNotDeleted(table: target.table, id: target.rowID)
            }
            // **The block must be LIVE** — `restoreBlockComment`'s own guard
            // pair, for a traced reason rather than symmetry. The fold this
            // door lives on exists only for a live block, so every comment it
            // lists was deleted on its OWN stamp. A comment under a DEAD
            // block is either one of those (its block died later — the
            // block's own Trash family takes it, `PurgeFamily.expandBlock`)
            // or a CASCADE victim carrying the block's exact stamp. Purging
            // the second kind alone is the hazard: `restoreBlock` /
            // `restoreContainer` / ⌥⌘Z flip it back live on the stamp
            // (`flipBlockCascadeTombstones`), none of those roads voids a
            // comment intent, and the LIVE intent left standing would hide
            // her next delete of it from the fold and hand it to the janitor
            // with no confirm — the 13j B1 class. Refusing here means a
            // comment intent is only ever minted for a comment deleted
            // individually under a live block, whose stamp no later block
            // death can share (the cascade trigger stamps LIVE comments only).
            _ = try liveBlock(db, comment.blockId)
            // **The seal (PROVISIONAL — VX-179's decided default, QUESTIONS
            // #23(a)'s posture extended):** every comment write refuses under
            // a sealed post, and a permanent delete is a write. A block with
            // no live placement (released to lineage) has no post to seal it
            // and passes, exactly as every other comment write does.
            try ensurePlacementUnlocked(db, blockID: comment.blockId)
            return true
        default:
            throw OperationError.unsupportedPurgeTarget(table: target.table)
        }
    }
}
