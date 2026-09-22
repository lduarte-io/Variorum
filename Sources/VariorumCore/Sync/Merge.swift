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
    /// The outbox entry is cleared when the row that LANDED equals the
    /// server row wholesale (nothing of local intent left to push); it stays
    /// when local intent survived (a tombstone overlay) — or when an inline
    /// repair altered the landing (a collision tombstone, an orphan stamp,
    /// the Journal keeper's re-point), so the repair's explicit enqueue is
    /// honored and the next push carries it (SyncSpec §7; the ladder's F1
    /// found the pre-repair copy being compared instead).
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
            let cardMinted = try rescueLosingText(
                db, local: local, server: server, touched: &touched)
            // RUN B B2 row 15 Part 1 (F-1's bytes; PROVISIONAL — the §6
            // silent-cell reading, QUESTIONS #143(a)): when the LOCAL
            // side's dirty text loses the row and the conflict-card
            // rescue cannot land (the block is dead — a whole-family
            // tombstone arriving over an unpushed edit), the edit RIDES
            // THE ROW instead of being clobbered by the server's old
            // text: the same end-state B1's P1 probe blessed for the
            // pushed direction ("the edit rides the row INTO the
            // Trash"), applied to the unpushed one. §6's own ratified
            // warrant: "deleting an edit nobody chose to lose is the one
            // forbidden outcome." The merged row then differs from the
            // server, so the outbox entry SURVIVES below and the ridden
            // text pushes — both devices converge with the edit intact
            // on the (still tombstoned) row, and Put back returns it.
            // SCOPED to the arriving-TOMBSTONE shape, the traced
            // construction — and the LOCAL side's tombstone state is
            // deliberately NOT consulted, because the loss's real shape
            // is (true, true): the arriving BLOCK tombstone's local
            // cascade stamps the dirty row EARLIER IN THE SAME BATCH
            // (cascades stay active during apply), so by the time the
            // variant row merges, the unpushed edit sits on a
            // locally-tombstoned row. That is F-1's B-side mechanism
            // and the phone-first P1 order alike. What stays UNCHANGED,
            // recorded in the run record rather than silently decided:
            // a LIVE server row over a dirty local edit under a dead
            // block (the untraced both-edited corner, where riding
            // would merely swap WHOSE bytes die — one row, no card
            // possible) keeps its shipped server-wins behavior; and in
            // (true, true) with BOTH sides edited (both rode), riding
            // keeps the LOCAL edit where the old code kept the first
            // pusher's — one side's bytes lose the row either way,
            // recorded as the same corner's other face.
            //
            // LADDER R1 F-R1: dirty ROW is not dirty TEXT. The outbox
            // is a dirty-ROW set (SyncSpec §3) — `setTakeLabel`, a lock,
            // a fan reorder all enqueue the row with `working_text`
            // untouched, and the first overlay rode that STALE ancestor
            // text over a server row carrying the peer's newer, final
            // edit (the only new bytes died — §6's forbidden class, a
            // regression against pre-run server-wins). State-based rows
            // hold no last-acked pre-image, so "is my text an edit" is
            // answered by the one discriminator current state can
            // honestly give: the ride fires ONLY when `working_text` is
            // the SOLE divergence between the rows (every column equal
            // but text and the volatile bookkeeping). A metadata-only-
            // dirty row diverges in the metadata it dirtied → server-
            // wins again; a text-only-dirty row rides exactly as ruled.
            // Recorded corners (#143(a)'s amendment): mixed dirt (text
            // edit + metadata divergence on either side) refuses the
            // ride and falls back to the PRE-run server-wins — never
            // worse than old code; byte-identical metadata minted
            // independently on both devices would still ride.
            if !cardMinted, server.isTombstoned,
               let localText = local.workingText,
               let serverText = server.workingText,
               localText != serverText,
               Self.textIsTheOnlyDivergence(local: local, server: server) {
                merged.columns["working_text"] = .text(localText)
            }
        }

        let landed = try writeResolvedRow(db, merged, serverSeq: serverSeq, touched: &touched)
        try recordSeq(db, table: merged.table, rowID: merged.rowID, seq: serverSeq)
        if landed.columns == server.columns {
            // Server accepted wholesale: local state now IS server state —
            // nothing left to push for this row.
            try clearOutboxEntry(db, table: merged.table, rowID: merged.rowID)
        }
    }

    /// F-R1's discriminator: true when `working_text` is the ONLY
    /// divergence between the two rows. Volatile bookkeeping is excluded —
    /// `deleted_at` (tombstone semantics are the tombstone-wins rules'),
    /// `updated_at` (touch bookkeeping, bumped by both sides' acts) —
    /// and `sync_version` rides outside `columns` by construction. What
    /// remains for a variant row (id, block_id, parent_variant_id,
    /// status, locked, label, fan_position, created_at) is exactly the
    /// row's INTENT surface: equality there means the local dirt, if
    /// any, is text.
    private static func textIsTheOnlyDivergence(local: SyncRow, server: SyncRow) -> Bool {
        let volatile: Set<String> = ["working_text", "deleted_at", "updated_at"]
        let keys = Set(local.columns.keys).union(server.columns.keys).subtracting(volatile)
        return keys.allSatisfy { local.columns[$0] == server.columns[$0] }
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
    /// block would dangle (rescue skipped; coarse, not forensic). Returns
    /// whether a card WAS minted (row 15 Part 1's caller reads it: a
    /// losing local edit no card could hold rides the merged row instead).
    @discardableResult
    private func rescueLosingText(
        _ db: Database, local: SyncRow, server: SyncRow, touched: inout TouchedRows
    ) throws -> Bool {
        guard let localText = local.workingText,
              let serverText = server.workingText,
              localText != serverText
        else { return false }

        let losingText: String
        switch (local.isTombstoned, server.isTombstoned) {
        case (false, false), (false, true):
            losingText = localText
        case (true, false):
            losingText = serverText
        case (true, true):
            return false
        }

        guard case .text(let blockID) = server.columns["block_id"] else { return false }
        let blockIsLive = try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM block WHERE id = ? AND deleted_at IS NULL)",
            arguments: [blockID]) ?? false
        guard blockIsLive else { return false }

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
        return true
    }
}
