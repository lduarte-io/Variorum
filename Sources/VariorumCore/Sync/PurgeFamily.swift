import Foundation
import GRDB

/// **The purge family** (Phase 13j batch 6b — the memo's §4c: "purge is
/// never partial"): given root rows, the full set of rows that must go WITH
/// them, expanded client-side — the server stays dumb (SyncSpec §2), and
/// family semantics are domain knowledge.
///
/// The family is the FK CLOSURE under each root, which is exactly what
/// "family-completeness leaves ZERO orphan rows" means mechanically: the
/// local delete runs with foreign keys ON (deferred inside its own
/// transaction), so a missed child is a commit-time FK failure and a whole
/// rollback — the database itself enforces completeness.
///
/// **Which blocks ride a note's purge** (the Trash's own one-row rule, from
/// the other side): the note's exact-stamp cascade victims — the blocks
/// `restoreContainer` would have revived. A block deleted EARLIER from the
/// note (its own stamp, its own Trash row, its own clock) does NOT ride;
/// its placement row under the purged note goes (FK), and the block keeps
/// its own clock — recorded consequence: its later Put back falls back to
/// the fresh-at-end road, and its "from ‹note›" context nulls with the
/// note. An ARCHIVED block (kept-forever, live) never rides a purge.
///
/// **Stranded originals ride their family** (her round-8b ruling): a live,
/// unplaced, un-archived original whose ENTIRE descendant set is inside the
/// purge (or already absent) joins it — computed to a fixpoint, because an
/// original joining can strand ITS OWN original in turn.
struct PurgeFamily {
    /// Delete order, children-first: RESTRICT constraints are checked
    /// immediately even under deferred FKs (`container_block.
    /// chosen_variant_id` is the live one — placements before variants),
    /// and the rest reads naturally.
    static let deleteOrder: [String] = [
        "lens_choice", "lens", "canvas_layout", "block_comment",
        "post_tag", "block_tag", "reference", "reading_post",
        "reading_section", "commit_point", "container_block", "edge",
        "variant", "block", "reading", "container",
    ]

    /// The expanded family: every (table, row) the purge takes, plus the
    /// stranded originals that joined (block ids — for receipts/tests).
    struct Expansion: Equatable {
        var rows: Set<SyncPurgeTarget> = []
        var strandedOriginals: Set<String> = []

        var isEmpty: Bool { rows.isEmpty }

        /// The family's rows in children-first delete order (stable within
        /// a table by row id — determinism for tests and the mirror call).
        var orderedRows: [SyncPurgeTarget] {
            PurgeFamily.deleteOrder.flatMap { table in
                rows.filter { $0.table == table }.sorted { $0.rowID < $1.rowID }
            }
        }

        func ids(in table: String) -> Set<String> {
            Set(rows.filter { $0.table == table }.map(\.rowID))
        }

        mutating func insert(_ table: String, _ ids: [String]) {
            for id in ids { rows.insert(SyncPurgeTarget(table: table, rowID: id)) }
        }
    }

    // MARK: - Expansion

    /// Expands roots to the full family. Roots may name rows that no longer
    /// exist locally (an intent honored after the rows already went) — those
    /// contribute themselves only, so the mirror call still names them and
    /// the ledger still fences them.
    static func expand(_ db: Database, roots: [SyncPurgeTarget]) throws -> Expansion {
        var family = Expansion()
        for root in roots {
            family.rows.insert(root)
            switch root.table {
            case "container": try expandContainer(db, root.rowID, into: &family)
            case "reading": try expandReading(db, root.rowID, into: &family)
            case "block": try expandBlock(db, root.rowID, into: &family)
            case "variant": try expandVariant(db, root.rowID, into: &family)
            default: break  // commit_point and unknown kinds: the row itself
            }
        }
        try joinStrandedOriginals(db, into: &family)
        return family
    }

    private static func expandContainer(
        _ db: Database, _ containerID: String, into family: inout Expansion
    ) throws {
        let lenses = try String.fetchAll(
            db, sql: "SELECT id FROM lens WHERE container_id = ?", arguments: [containerID])
        family.insert("lens", lenses)
        if !lenses.isEmpty {
            family.insert("lens_choice", try String.fetchAll(
                db,
                sql: "SELECT id FROM lens_choice WHERE lens_id IN (SELECT id FROM lens WHERE container_id = ?)",
                arguments: [containerID]))
        }
        family.insert("canvas_layout", try String.fetchAll(
            db, sql: "SELECT id FROM canvas_layout WHERE container_id = ?", arguments: [containerID]))
        family.insert("reference", try String.fetchAll(
            db, sql: "SELECT id FROM reference WHERE container_id = ?", arguments: [containerID]))
        family.insert("post_tag", try String.fetchAll(
            db, sql: "SELECT id FROM post_tag WHERE post_id = ?", arguments: [containerID]))
        family.insert("reading_post", try String.fetchAll(
            db, sql: "SELECT id FROM reading_post WHERE post_id = ?", arguments: [containerID]))
        family.insert("container_block", try String.fetchAll(
            db, sql: "SELECT id FROM container_block WHERE container_id = ?", arguments: [containerID]))
        // The note's blocks: exact-stamp cascade victims ONLY (the
        // restoreContainer discriminator — a block with its own clock keeps
        // it; an archived block is live and never rides).
        let memberBlocks = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT b.id FROM block b
                JOIN container_block cb ON cb.block_id = b.id AND cb.container_id = ?
                JOIN container c ON c.id = ?
                WHERE b.deleted_at IS NOT NULL AND b.deleted_at = c.deleted_at
                """,
            arguments: [containerID, containerID])
        for blockID in memberBlocks {
            family.rows.insert(SyncPurgeTarget(table: "block", rowID: blockID))
            try expandBlock(db, blockID, into: &family)
        }
    }

    private static func expandReading(
        _ db: Database, _ readingID: String, into family: inout Expansion
    ) throws {
        family.insert("reading_section", try String.fetchAll(
            db, sql: "SELECT id FROM reading_section WHERE reading_id = ?", arguments: [readingID]))
        family.insert("reading_post", try String.fetchAll(
            db, sql: "SELECT id FROM reading_post WHERE reading_id = ?", arguments: [readingID]))
    }

    private static func expandBlock(
        _ db: Database, _ blockID: String, into family: inout Expansion
    ) throws {
        let variants = try String.fetchAll(
            db, sql: "SELECT id FROM variant WHERE block_id = ?", arguments: [blockID])
        family.insert("variant", variants)
        if !variants.isEmpty {
            family.insert("commit_point", try String.fetchAll(
                db,
                sql: "SELECT id FROM commit_point WHERE variant_id IN (SELECT id FROM variant WHERE block_id = ?)",
                arguments: [blockID]))
        }
        family.insert("container_block", try String.fetchAll(
            db, sql: "SELECT id FROM container_block WHERE block_id = ?", arguments: [blockID]))
        family.insert("edge", try String.fetchAll(
            db,
            sql: "SELECT id FROM edge WHERE source_block_id = ? OR target_block_id = ?",
            arguments: [blockID, blockID]))
        family.insert("block_tag", try String.fetchAll(
            db, sql: "SELECT id FROM block_tag WHERE block_id = ?", arguments: [blockID]))
        family.insert("block_comment", try String.fetchAll(
            db, sql: "SELECT id FROM block_comment WHERE block_id = ?", arguments: [blockID]))
        family.insert("canvas_layout", try String.fetchAll(
            db, sql: "SELECT id FROM canvas_layout WHERE block_id = ?", arguments: [blockID]))
        family.insert("lens_choice", try String.fetchAll(
            db, sql: "SELECT id FROM lens_choice WHERE block_id = ?", arguments: [blockID]))
    }

    private static func expandVariant(
        _ db: Database, _ variantID: String, into family: inout Expansion
    ) throws {
        family.insert("commit_point", try String.fetchAll(
            db, sql: "SELECT id FROM commit_point WHERE variant_id = ?", arguments: [variantID]))
        // A dangling lens pick naming the purged take: pure pointer, its
        // fall-through means removing it changes nothing rendered — and
        // its FK makes removal mandatory.
        family.insert("lens_choice", try String.fetchAll(
            db, sql: "SELECT id FROM lens_choice WHERE variant_id = ?", arguments: [variantID]))
    }

    /// Her round-8b ruling, at purge time: a live, unplaced, un-archived
    /// original whose ENTIRE descendant set is inside this purge (or
    /// already absent from the store) goes WITH the family. Fixpoint —
    /// an original joining can strand its own original.
    private static func joinStrandedOriginals(
        _ db: Database, into family: inout Expansion
    ) throws {
        while true {
            let familyBlocks = family.ids(in: "block")
            guard !familyBlocks.isEmpty else { return }
            // Ancestors of the family's blocks, read PAST edge tombstones
            // (the strandedOriginals doctrine: lineage is a fact about what
            // happened; deleting a block cascade-tombstones its edges).
            let candidates = try String.fetchAll(
                db,
                sql: """
                    WITH RECURSIVE anc(id) AS (
                      SELECT e.target_block_id FROM edge e
                      WHERE e.source_block_id IN (SELECT value FROM json_each(?))
                        AND e.type = 'derived_from'
                      UNION
                      SELECT e.target_block_id FROM edge e
                      JOIN anc a ON e.source_block_id = a.id
                      WHERE e.type = 'derived_from'
                    )
                    SELECT DISTINCT b.id FROM anc
                    JOIN block b ON b.id = anc.id
                    WHERE b.deleted_at IS NULL AND b.archived_at IS NULL
                      AND NOT EXISTS (
                        SELECT 1 FROM container_block placed
                        WHERE placed.block_id = b.id AND placed.deleted_at IS NULL)
                    """,
                arguments: [jsonArray(familyBlocks)])
            var joined = false
            for candidate in candidates where !familyBlocks.contains(candidate) {
                // Every descendant must be in the family or already absent.
                let survivingDescendants = try Int.fetchOne(
                    db,
                    sql: """
                        WITH RECURSIVE fam(id) AS (
                          SELECT e.source_block_id FROM edge e
                          WHERE e.target_block_id = ? AND e.type = 'derived_from'
                          UNION
                          SELECT e.source_block_id FROM edge e
                          JOIN fam f ON e.target_block_id = f.id
                          WHERE e.type = 'derived_from'
                        )
                        SELECT COUNT(*) FROM fam
                        JOIN block d ON d.id = fam.id
                        WHERE fam.id NOT IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [candidate, jsonArray(familyBlocks)]) ?? 0
                guard survivingDescendants == 0 else { continue }
                family.rows.insert(SyncPurgeTarget(table: "block", rowID: candidate))
                family.strandedOriginals.insert(candidate)
                try expandBlock(db, candidate, into: &family)
                joined = true
            }
            guard joined else { return }
        }
    }

    // MARK: - The local removal

    /// Physically removes the family's rows — the caller supplies the
    /// transaction (with `PRAGMA defer_foreign_keys = ON` executed inside
    /// it) so one family is exactly one transaction (memo §4b step 3).
    ///
    /// Beyond the deletes, three kinds of housekeeping:
    ///  1. **Survivor detachment**, as ordinary UPDATEs BEFORE the deletes:
    ///     rows OUTSIDE the family that reference family rows are re-pointed
    ///     to NULL explicitly (a surviving block's `last_container_id` at a
    ///     purged note; a surviving placement's `chosen_variant_id` at a
    ///     purged take; a surviving take's `parent_variant_id`; a surviving
    ///     membership's `section_id`). Explicit rather than left to the FK
    ///     actions so the change ENQUEUES and PUSHES — the mirror's
    ///     surviving rows converge instead of dangling (a peer pulling a
    ///     dangling reference would stall its cursor until this device's
    ///     push heals it; the batch record carries the transient-stall
    ///     analysis).
    ///  2. **Intent completion**: live purge_intent rows naming any family
    ///     member tombstone (the "janitor completed it" state; the row
    ///     keeps traveling so a late peer still learns).
    ///  3. **Bookkeeping**: sync_row_seq and sync_outbox rows for purged
    ///     rows go with them (the brief's letter) — a dirty entry whose row
    ///     no longer exists would pend forever.
    ///
    /// `enqueue` is non-nil when the caller's transaction runs in APPLY
    /// MODE (the engine's `.purged` handler): the outbox triggers are muted
    /// there, so every survivor/intent UPDATE enqueues explicitly (the
    /// SyncSpec §7 repair-write discipline). Janitor calls run in an
    /// ordinary write transaction and pass nil — the triggers capture.
    static func deleteLocal(
        _ db: Database, family: Expansion, stamp: String,
        enqueue: ((_ table: String, _ rowID: String) throws -> Void)? = nil
    ) throws {
        guard !family.isEmpty else { return }

        // 1. Survivor detachment.
        let containers = family.ids(in: "container")
        if !containers.isEmpty {
            let detached = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM block
                    WHERE last_container_id IN (SELECT value FROM json_each(?))
                      AND id NOT IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(containers), jsonArray(family.ids(in: "block"))])
            if !detached.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE block SET last_container_id = NULL, updated_at = ?
                        WHERE id IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [stamp, jsonArray(Set(detached))])
                for id in detached { try enqueue?("block", id) }
            }
        }
        let variants = family.ids(in: "variant")
        if !variants.isEmpty {
            // 13j ladder B (B10) — the fourth detachment arm, closing the
            // asymmetry with `chosen_variant_id` below: a SURVIVING block
            // whose `default_variant_id` names a purged take. Unreachable
            // through op discipline (delete/archive reassign the default;
            // SyncSpec §7 repairs a default that arrives dead) — but if the
            // state ever arose on a block with a pending outbox entry, the
            // DELETE-fired ON DELETE SET NULL would run the capture trigger
            // under ABORT semantics (the 2b class, SQLite 19) and wedge the
            // family's sweep on retry. Enqueued like its three siblings so
            // the mirror's surviving row converges.
            let dangling = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM block
                    WHERE default_variant_id IN (SELECT value FROM json_each(?))
                      AND id NOT IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(variants), jsonArray(family.ids(in: "block"))])
            if !dangling.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE block SET default_variant_id = NULL, updated_at = ?
                        WHERE id IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [stamp, jsonArray(Set(dangling))])
                for id in dangling { try enqueue?("block", id) }
            }
            let placements = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM container_block
                    WHERE chosen_variant_id IN (SELECT value FROM json_each(?))
                      AND id NOT IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(variants), jsonArray(family.ids(in: "container_block"))])
            if !placements.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE container_block SET chosen_variant_id = NULL, updated_at = ?
                        WHERE id IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [stamp, jsonArray(Set(placements))])
                for id in placements { try enqueue?("container_block", id) }
            }
            let children = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM variant
                    WHERE parent_variant_id IN (SELECT value FROM json_each(?))
                      AND id NOT IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(variants), jsonArray(variants)])
            if !children.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE variant SET parent_variant_id = NULL, updated_at = ?
                        WHERE id IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [stamp, jsonArray(Set(children))])
                for id in children { try enqueue?("variant", id) }
            }
        }
        let sections = family.ids(in: "reading_section")
        if !sections.isEmpty {
            let memberships = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM reading_post
                    WHERE section_id IN (SELECT value FROM json_each(?))
                      AND id NOT IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(sections), jsonArray(family.ids(in: "reading_post"))])
            if !memberships.isEmpty {
                try db.execute(
                    sql: """
                        UPDATE reading_post SET section_id = NULL
                        WHERE id IN (SELECT value FROM json_each(?))
                        """,
                    arguments: [jsonArray(Set(memberships))])
                for id in memberships { try enqueue?("reading_post", id) }
            }
        }

        // 2. Intent completion.
        var completedIntents: [String] = []
        for target in family.rows {
            let intents = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM purge_intent
                    WHERE table_name = ? AND row_id = ? AND deleted_at IS NULL
                    """,
                arguments: [target.table, target.rowID])
            completedIntents.append(contentsOf: intents)
        }
        if !completedIntents.isEmpty {
            try db.execute(
                sql: """
                    UPDATE purge_intent SET deleted_at = ?, updated_at = ?
                    WHERE id IN (SELECT value FROM json_each(?))
                    """,
                arguments: [stamp, stamp, jsonArray(Set(completedIntents))])
            for id in completedIntents { try enqueue?("purge_intent", id) }
        }

        // 2b. INTERNAL pointer pre-nulling, on rows about to die. Not for
        // the rows' sake — for the TRIGGERS': a DELETE that fires an FK
        // action (`block.default_variant_id` / `variant.parent_variant_id`
        // ON DELETE SET NULL) runs the outbox capture trigger under the FK
        // action's ABORT conflict semantics, demoting the trigger's
        // INSERT OR REPLACE and failing on the row's existing outbox entry
        // (found by this batch's own zero-orphan test — SQLite error 19).
        // Explicit UPDATEs first keep every trigger on its ordinary path;
        // the rows and their outbox entries are swept moments later.
        let familyBlocks = family.ids(in: "block")
        if !variants.isEmpty, !familyBlocks.isEmpty {
            try db.execute(
                sql: """
                    UPDATE block SET default_variant_id = NULL
                    WHERE id IN (SELECT value FROM json_each(?))
                      AND default_variant_id IS NOT NULL
                    """,
                arguments: [jsonArray(familyBlocks)])
        }
        if !variants.isEmpty {
            try db.execute(
                sql: """
                    UPDATE variant SET parent_variant_id = NULL
                    WHERE id IN (SELECT value FROM json_each(?))
                      AND parent_variant_id IS NOT NULL
                    """,
                arguments: [jsonArray(variants)])
        }
        if !containers.isEmpty, !familyBlocks.isEmpty {
            try db.execute(
                sql: """
                    UPDATE block SET last_container_id = NULL
                    WHERE id IN (SELECT value FROM json_each(?))
                      AND last_container_id IN (SELECT value FROM json_each(?))
                    """,
                arguments: [jsonArray(familyBlocks), jsonArray(containers)])
        }

        // 3. The deletes, children-first, then the bookkeeping sweep.
        for table in deleteOrder {
            let ids = family.ids(in: table)
            guard !ids.isEmpty else { continue }
            try db.execute(
                sql: "DELETE FROM \(table) WHERE id IN (SELECT value FROM json_each(?))",
                arguments: [jsonArray(ids)])
        }
        for target in family.rows {
            try db.execute(
                sql: "DELETE FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
                arguments: [target.table, target.rowID])
            try db.execute(
                sql: "DELETE FROM sync_outbox WHERE table_name = ? AND row_id = ?",
                arguments: [target.table, target.rowID])
        }
    }

    private static func jsonArray(_ values: some Collection<String>) -> String {
        let data = try? JSONEncoder().encode(values.sorted())
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
