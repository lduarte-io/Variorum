import Foundation
import GRDB

/// The merge matrix (SyncSpec §6) — client-side, deterministic, and shared
/// by both paths that meet newer server truth: a push reject (CAS rebase)
/// and a pull over a locally-dirty row. Callers guarantee the surrounding
/// transaction is in apply mode; anything the merge creates (rescue/conflict
/// variants) is enqueued explicitly past the muted triggers.
extension SyncEngine {
    /// Merges the authoritative server row into the dirty local row.
    ///
    /// | Class                | Rule                                                      |
    /// |----------------------|-----------------------------------------------------------|
    /// | metadata / positions / counters | server-version-wins (CAS rebase; local intent dropped) |
    /// | any `deleted_at`     | tombstone wins over edits — whichever side carries it     |
    /// | `variant.working_text` | conflict-as-variant (S5): the losing side's text becomes a new variant; nothing clobbered |
    ///
    /// After the merge the local row carries the server's `sync_version`.
    /// The outbox entry is cleared when the merge accepted the server row
    /// wholesale (nothing of local intent left to push); it stays when local
    /// intent survived (a tombstone overlay), so the next push carries it.
    func merge(
        _ db: Database, local: SyncRow, server: SyncRow, serverSeq: Int64,
        touched: inout TouchedRows
    ) throws {
        guard let table = SyncSchema.table(named: server.table) else {
            throw SyncError.unknownTable(server.table)
        }
        var merged = server  // server-version-wins baseline

        // Tombstone-wins overlay: a local tombstone racing a server edit is
        // re-applied on top of the server row and pushed on the next cycle.
        if table.hasTombstone, local.isTombstoned, !server.isTombstoned {
            merged.columns["deleted_at"] = local.columns["deleted_at"]
        }

        // The one mutable text (S5): whichever side's text loses the row is
        // rescued as a conflict variant — never clobbered.
        if table.name == "variant" {
            try rescueLosingText(db, local: local, server: server, touched: &touched)
        }

        try writeResolvedRow(db, merged, serverSeq: serverSeq, touched: &touched)
        try recordSeq(db, table: merged.table, rowID: merged.rowID, seq: serverSeq)
        if merged.columns == server.columns {
            // Server accepted wholesale: local state now IS server state —
            // nothing left to push for this row.
            try clearOutboxEntry(db, table: merged.table, rowID: merged.rowID)
        }
    }

    /// S5 + the §6 tombstone-rescue rule, symmetric by side:
    /// - both live, texts differ → server text wins the row; the LOCAL text
    ///   is the loser (conflict-as-variant);
    /// - server tombstoned vs live local edit → the tombstone is honored;
    ///   the LOCAL edit is rescued first;
    /// - local tombstone vs live server edit → the tombstone overlay wins
    ///   the row; the SERVER text is rescued (deleting it would clobber an
    ///   edit no one chose to lose);
    /// - both tombstoned → nothing to rescue.
    ///
    /// A rescue lands only while the block is still live locally — a dead
    /// block's fan is unreachable, and inserting a live variant under a dead
    /// block would dangle (rescue skipped; coarse, not forensic).
    private func rescueLosingText(
        _ db: Database, local: SyncRow, server: SyncRow, touched: inout TouchedRows
    ) throws {
        guard let localText = local.workingText,
              let serverText = server.workingText,
              localText != serverText
        else { return }

        let losingText: String
        switch (local.isTombstoned, server.isTombstoned) {
        case (false, false), (false, true):
            losingText = localText
        case (true, false):
            losingText = serverText
        case (true, true):
            return
        }

        guard case .text(let blockID) = server.columns["block_id"] else { return }
        let blockIsLive = try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM block WHERE id = ? AND deleted_at IS NULL)",
            arguments: [blockID]) ?? false
        guard blockIsLive else { return }

        let parent: String?
        if case .text(let value) = local.columns["parent_variant_id"] {
            parent = value
        } else {
            parent = nil
        }
        let conflict = try Operations.insertConflictVariant(
            db, blockID: blockID, parentVariantID: parent,
            losingText: losingText, id: uuid().uuidString, now: date.now)
        // Born inside apply mode: the triggers are muted, so the new variant
        // reaches the outbox explicitly or it never syncs (SyncSpec §7).
        try enqueueExplicitly(db, table: "variant", rowID: conflict.id)
        touched.blocksWithVariantChanges.insert(blockID)
    }
}
