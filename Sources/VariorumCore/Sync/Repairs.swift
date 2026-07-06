import Foundation
import GRDB

/// What a batch touched — the scope of the post-apply repair pass, so repair
/// cost is proportional to batch size, never corpus size (P1).
struct TouchedRows {
    /// Blocks whose variant rows changed in this batch (applied variant rows
    /// + rescue variants) — the I10 / dangling-default / dangling-chosen
    /// candidates.
    var blocksWithVariantChanges: Set<String> = []
    /// Applied block rows.
    var blockIDs: Set<String> = []
    /// Applied container_block rows.
    var placementIDs: Set<String> = []
    /// Cascade parents (container/block/reading/tag) whose applied row
    /// transitioned live→dead in THIS batch: their local cascade fired with
    /// the outbox triggers muted, so the victims must be enqueued explicitly
    /// (the orphan repair, direction 1).
    var tombstonedParents: [(table: String, rowID: String, stamp: String)] = []
    /// Rows arriving in this batch already tombstoned — their tombstones are
    /// server-known, so direction 1 need not re-push them.
    var arrivingDeadIDs: [String: Set<String>] = [:]
    /// Inline (write-time) repair count, for reporting.
    var inlineRepairs = 0
}

/// Apply-time repairs (SyncSpec §7): concurrent offline writes can produce
/// two *live* rows that violate a live-unique index when they meet. The dumb
/// server accepted both; the client resolves them deterministically, at
/// apply time, and **every repair write enqueues its outbox row explicitly**
/// (the triggers are muted inside apply — a forgotten enqueue means silent
/// divergence).
///
/// Two layers:
/// - **write-time** (`writeResolvedRow`): collisions with a live-unique
///   index are resolved before the incoming row lands — the index would
///   reject the write itself, so a post-pass could never see the state;
/// - **post-batch** (`runPostApplyRepairs`): cross-row rules no index
///   enforces — I10 resurrection, dangling `chosen_variant_id`, dead
///   `default_variant_id` — checked over exactly the rows the batch touched.
extension SyncEngine {
    // MARK: - Write-time: live-unique collisions

    /// Lands an incoming (or merged) row, first resolving any live-unique
    /// collision per its table's SyncSpec §7 rule. Tombstoned incoming rows
    /// can't collide with a live-row partial index and land verbatim.
    func writeResolvedRow(
        _ db: Database, _ row: SyncRow, serverSeq: Int64, touched: inout TouchedRows
    ) throws {
        var resolved = row
        if !row.isTombstoned {
            switch row.table {
            case "container_block":
                resolved = try repairPlacementCollision(db, row, serverSeq: serverSeq, touched: &touched)
            case "tag":
                resolved = try repairTagPathCollision(db, row, touched: &touched)
            case "edge":
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["source_block_id", "target_block_id", "type"],
                    touched: &touched)
            case "reading_post":
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["reading_id", "post_id"], touched: &touched)
            case "post_tag":
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["tag_id", "post_id"], touched: &touched)
            case "block_tag":
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["tag_id", "block_id"], touched: &touched)
            default:
                break
            }
        }
        // Orphan repair, direction 2: a live child arriving under a
        // locally-dead parent joins the parent's cascade — same stamp, so
        // every device converges byte-identically, and `restoreContainer`/
        // `restoreBlock` still recognize it as a cascade victim.
        if !resolved.isTombstoned,
           let orphanStamp = try deadParentStamp(db, row: resolved) {
            resolved.columns["deleted_at"] = .text(orphanStamp)
            try enqueueExplicitly(db, table: resolved.table, rowID: resolved.rowID)
            touched.inlineRepairs += 1
        }
        // Orphan repair, direction 1 (detection): a cascade parent
        // transitioning live→dead right now fires the local cascade with
        // the triggers muted — its victims are collected post-batch.
        if resolved.isTombstoned,
           ["container", "block", "reading", "tag"].contains(resolved.table),
           case .text(let stamp) = resolved.columns["deleted_at"] {
            let wasLive = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM \(resolved.table) WHERE id = ? AND deleted_at IS NULL)",
                arguments: [resolved.rowID]) ?? false
            if wasLive {
                touched.tombstonedParents.append((resolved.table, resolved.rowID, stamp))
            }
        }
        try resolved.apply(db)
        noteApplied(resolved, touched: &touched)
    }

    /// The nearest locally-dead cascade parent's stamp for a live incoming
    /// row, or nil. Missing parents are stragglers, not orphans (SyncSpec
    /// §5 tolerance); `commit_point`/`setting` have no tombstones and the
    /// top-level tables have no cascade parent (a live unplaced block is a
    /// LEGAL state — released to lineage).
    private func deadParentStamp(_ db: Database, row: SyncRow) throws -> String? {
        let parents: [(column: String, table: String)]
        switch row.table {
        case "container_block": parents = [("container_id", "container"), ("block_id", "block")]
        case "variant": parents = [("block_id", "block")]
        case "reading_post": parents = [("reading_id", "reading"), ("post_id", "container")]
        case "post_tag": parents = [("tag_id", "tag"), ("post_id", "container")]
        case "block_tag": parents = [("tag_id", "tag"), ("block_id", "block")]
        case "reference": parents = [("container_id", "container")]
        case "edge": parents = [("source_block_id", "block"), ("target_block_id", "block")]
        default: return nil
        }
        for parent in parents {
            guard case .text(let parentID) = row.columns[parent.column] else { continue }
            if let stamp = try String.fetchOne(
                db,
                sql: "SELECT deleted_at FROM \(parent.table) WHERE id = ? AND deleted_at IS NOT NULL",
                arguments: [parentID]) {
                return stamp
            }
        }
        return nil
    }

    private func noteApplied(_ row: SyncRow, touched: inout TouchedRows) {
        switch row.table {
        case "block":
            touched.blockIDs.insert(row.rowID)
        case "variant":
            if case .text(let blockID) = row.columns["block_id"] {
                touched.blocksWithVariantChanges.insert(blockID)
            }
        case "container_block":
            touched.placementIDs.insert(row.rowID)
        default:
            break
        }
    }

    /// I2 move/move race: two live placements for one block. The one with
    /// the **higher server_seq wins** (later intent; a row the server never
    /// accepted ranks 0); the loser is tombstoned locally and the repair
    /// pushes. Deterministic on every device because seq is global.
    private func repairPlacementCollision(
        _ db: Database, _ row: SyncRow, serverSeq: Int64, touched: inout TouchedRows
    ) throws -> SyncRow {
        guard case .text(let blockID) = row.columns["block_id"] else { return row }
        let rivals = try Row.fetchAll(
            db,
            sql: """
                SELECT id FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL AND id <> ?
                """,
            arguments: [blockID, row.rowID])
        guard !rivals.isEmpty else { return row }

        var resolved = row
        let stamp = nowStamp()
        for rival in rivals {
            let rivalID: String = rival["id"]
            let rivalSeq = try knownSeq(db, table: "container_block", rowID: rivalID)
            // Global seq never ties; ties are only possible at 0 vs 0, which
            // cannot happen (the incoming row has a real seq) — the id
            // tiebreak is pure paranoia for determinism.
            let incomingWins = serverSeq != rivalSeq ? serverSeq > rivalSeq : row.rowID > rivalID
            if incomingWins {
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, rivalID])
                try enqueueExplicitly(db, table: "container_block", rowID: rivalID)
                touched.placementIDs.insert(rivalID)
                touched.inlineRepairs += 1
            } else {
                resolved.columns["deleted_at"] = .text(stamp)
                resolved.columns["updated_at"] = .text(stamp)
                try enqueueExplicitly(db, table: "container_block", rowID: resolved.rowID)
                touched.inlineRepairs += 1
                break  // the incoming row is dead; nothing further collides
            }
        }
        return resolved
    }

    /// `tag.path` duplicate creation: keep the row with the lexically
    /// smaller `id`; re-point the duplicate's live applications to the
    /// keeper (unless the keeper is already applied there — then the
    /// application is itself a pure duplicate and tombstones); tombstone
    /// the duplicate.
    private func repairTagPathCollision(
        _ db: Database, _ row: SyncRow, touched: inout TouchedRows
    ) throws -> SyncRow {
        guard case .text(let path) = row.columns["path"] else { return row }
        guard let rivalID = try String.fetchOne(
            db,
            sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL AND id <> ?",
            arguments: [path, row.rowID])
        else { return row }

        var resolved = row
        let stamp = nowStamp()
        let (keeperID, duplicateID) = row.rowID < rivalID ? (row.rowID, rivalID) : (rivalID, row.rowID)
        // Re-point the duplicate's live applications to the keeper.
        for (table, targetColumn) in [("post_tag", "post_id"), ("block_tag", "block_id")] {
            let applications = try Row.fetchAll(
                db,
                sql: "SELECT id, \(targetColumn) AS target FROM \(table) WHERE tag_id = ? AND deleted_at IS NULL",
                arguments: [duplicateID])
            for application in applications {
                let applicationID: String = application["id"]
                let keeperAlreadyApplied = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM \(table)
                        WHERE tag_id = ? AND \(targetColumn) = ? AND deleted_at IS NULL)
                        """,
                    arguments: [keeperID, application["target"] as String]) ?? false
                if keeperAlreadyApplied {
                    try db.execute(
                        sql: "UPDATE \(table) SET deleted_at = ? WHERE id = ?",
                        arguments: [stamp, applicationID])
                } else {
                    try db.execute(
                        sql: "UPDATE \(table) SET tag_id = ? WHERE id = ?",
                        arguments: [keeperID, applicationID])
                }
                try enqueueExplicitly(db, table: table, rowID: applicationID)
                touched.inlineRepairs += 1
            }
        }
        if keeperID == row.rowID {
            try db.execute(
                sql: "UPDATE tag SET deleted_at = ?, updated_at = ? WHERE id = ?",
                arguments: [stamp, stamp, duplicateID])
            try enqueueExplicitly(db, table: "tag", rowID: duplicateID)
        } else {
            resolved.columns["deleted_at"] = .text(stamp)
            resolved.columns["updated_at"] = .text(stamp)
            try enqueueExplicitly(db, table: "tag", rowID: resolved.rowID)
        }
        touched.inlineRepairs += 1
        return resolved
    }

    /// Pure duplicates (`edge` triple, `reading_post` pair, `post_tag` /
    /// `block_tag` pairs): keep the smaller `id`, tombstone the other. For
    /// undirected `version_of` edges the operations layer stores the pair
    /// canonically as (min, max), so a REVERSED pair is the same
    /// relationship and counts as a duplicate (SyncSpec §7, review #8).
    private func repairDuplicateCollision(
        _ db: Database, _ row: SyncRow, naturalKey: [String], touched: inout TouchedRows
    ) throws -> SyncRow {
        let keyValues = naturalKey.map { row.columns[$0] ?? .null }
        guard keyValues.allSatisfy({ if case .text = $0 { return true } else { return false } })
        else { return row }

        var matchClauses = [naturalKey.map { "\($0) = ?" }.joined(separator: " AND ")]
        var arguments = keyValues.map(\.databaseValue)
        if row.table == "edge", case .text("version_of") = row.columns["type"] {
            matchClauses.append("(source_block_id = ? AND target_block_id = ? AND type = 'version_of')")
            arguments += [
                row.columns["target_block_id"]!.databaseValue,
                row.columns["source_block_id"]!.databaseValue,
            ]
        }
        guard let rivalID = try String.fetchOne(
            db,
            sql: """
                SELECT id FROM \(row.table)
                WHERE (\(matchClauses.joined(separator: " OR "))) AND deleted_at IS NULL AND id <> ?
                ORDER BY id LIMIT 1
                """,
            arguments: StatementArguments(arguments + [row.rowID.databaseValue]))
        else { return row }

        var resolved = row
        let stamp = nowStamp()
        if row.rowID < rivalID {
            try db.execute(
                sql: "UPDATE \(row.table) SET deleted_at = ? WHERE id = ?",
                arguments: [stamp, rivalID])
            try enqueueExplicitly(db, table: row.table, rowID: rivalID)
        } else {
            resolved.columns["deleted_at"] = .text(stamp)
            try enqueueExplicitly(db, table: row.table, rowID: resolved.rowID)
        }
        touched.inlineRepairs += 1
        return resolved
    }

    // MARK: - Post-batch: cross-row rules

    /// Runs after every row of the batch has landed, inside the same apply
    /// transaction, scoped to the touched rows. Order matters: I10
    /// resurrection first (it can re-legitimize a chosen pointer and mint
    /// the variant a default reassignment needs), then dangling chosen, then
    /// dead defaults.
    @discardableResult
    func runPostApplyRepairs(_ db: Database, touched: TouchedRows) throws -> Int {
        var repairs = 0
        let candidateBlocks = touched.blocksWithVariantChanges.union(touched.blockIDs).sorted()

        // Orphan repair, direction 1: a parent tombstone applied in this
        // batch fired the LOCAL cascade with the outbox triggers muted. Any
        // victim whose tombstone the batch itself is not delivering is a
        // local-only original (rows this device created and pushed after the
        // deleting device last saw the parent) — enqueue it explicitly or
        // the other devices never learn it died. Victims are identified by
        // the cascade's own contract: deleted_at == the parent's exact stamp.
        for parent in touched.tombstonedParents {
            repairs += try enqueueSuppressedCascadeVictims(
                db, parent: parent, arrivingDead: touched.arrivingDeadIDs)
        }

        // I10 double-tombstone race: a live block left with zero live active
        // variants. Resurrect the tombstoned variant with the highest
        // server_seq — deterministic on every device — status active, label
        // 'rescued' (resurrection over block-deletion: both devices wanted
        // the block alive with SOME text; SyncSpec §7).
        for blockID in candidateBlocks {
            let blockLive = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM block WHERE id = ? AND deleted_at IS NULL)",
                arguments: [blockID]) ?? false
            guard blockLive else { continue }
            let hasLiveActive = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active')
                    """,
                arguments: [blockID]) ?? false
            guard !hasLiveActive else { continue }

            let stamp = nowStamp()
            if let tombstoned = try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    LEFT JOIN sync_row_seq s ON s.table_name = 'variant' AND s.row_id = v.id
                    WHERE v.block_id = ? AND v.deleted_at IS NOT NULL
                    ORDER BY COALESCE(s.server_seq, 0) DESC, v.id DESC LIMIT 1
                    """,
                arguments: [blockID]) {
                try db.execute(
                    sql: """
                        UPDATE variant SET deleted_at = NULL, status = 'active',
                          label = 'rescued', updated_at = ? WHERE id = ?
                        """,
                    arguments: [stamp, tombstoned])
                try enqueueExplicitly(db, table: "variant", rowID: tombstoned)
                repairs += 1
            } else if let archived = try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    LEFT JOIN sync_row_seq s ON s.table_name = 'variant' AND s.row_id = v.id
                    WHERE v.block_id = ? AND v.deleted_at IS NULL AND v.status = 'archived'
                    ORDER BY COALESCE(s.server_seq, 0) DESC, v.id DESC LIMIT 1
                    """,
                arguments: [blockID]) {
                // PROVISIONAL: the archive/archive race (each device archived
                // a different last-active variant) is the same I10 hole by a
                // different door; SyncSpec §7 defines only the tombstone
                // variant. Same doctrine applied: deterministic rescue,
                // never a dead block. Logged in notes/QUESTIONS.md.
                try db.execute(
                    sql: "UPDATE variant SET status = 'active', label = 'rescued', updated_at = ? WHERE id = ?",
                    arguments: [stamp, archived])
                try enqueueExplicitly(db, table: "variant", rowID: archived)
                repairs += 1
            }
            // else: no variant rows at all — a cross-batch straggler; the
            // read side renders a gap (SyncSpec §5) and a later batch
            // completes the block.
        }

        // Dangling chosen_variant_id → NULL (read-time fallback already
        // renders the default; the repair makes the converged state explicit
        // and pushes). Scoped precisely: only a pointer at a variant row
        // that EXISTS and is TOMBSTONED is dangling — a missing variant row
        // is a straggler the next batch may legitimize, and an archived
        // chosen is a legal domain state the fallback covers.
        let placementScope = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.id, cb.chosen_variant_id FROM container_block cb
                WHERE cb.deleted_at IS NULL AND cb.chosen_variant_id IS NOT NULL
                  AND (cb.id IN (SELECT value FROM json_each(?))
                       OR cb.chosen_variant_id IN (
                            SELECT id FROM variant WHERE block_id IN (SELECT value FROM json_each(?))))
                """,
            arguments: [
                jsonArray(touched.placementIDs), jsonArray(touched.blocksWithVariantChanges),
            ])
        for placement in placementScope {
            let chosenID: String = placement["chosen_variant_id"]
            let chosenIsTombstoned = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM variant WHERE id = ? AND deleted_at IS NOT NULL)",
                arguments: [chosenID]) ?? false
            guard chosenIsTombstoned else { continue }
            let placementID: String = placement["id"]
            try db.execute(
                sql: "UPDATE container_block SET chosen_variant_id = NULL, updated_at = ? WHERE id = ?",
                arguments: [nowStamp(), placementID])
            try enqueueExplicitly(db, table: "container_block", rowID: placementID)
            repairs += 1
        }

        // default_variant_id that arrived dead (or NULL, or archived): the
        // AppSpec §9 lifecycle rule, applied at sync time — reassign to the
        // most recently updated live active variant. A default pointing at a
        // MISSING row is straggler-tolerated like chosen above.
        for blockID in candidateBlocks {
            guard let block = try Row.fetchOne(
                db,
                sql: "SELECT default_variant_id FROM block WHERE id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            else { continue }
            let defaultID: String? = block["default_variant_id"]
            if let defaultID {
                let defaultIsHealthy = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM variant
                        WHERE id = ? AND block_id = ? AND deleted_at IS NULL AND status = 'active')
                        """,
                    arguments: [defaultID, blockID]) ?? false
                if defaultIsHealthy { continue }
                let defaultExists = try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM variant WHERE id = ?)",
                    arguments: [defaultID]) ?? false
                if !defaultExists { continue }  // straggler
            }
            guard let replacement = try String.fetchOne(
                db,
                sql: """
                    SELECT id FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                    ORDER BY updated_at DESC, id DESC LIMIT 1
                    """,
                arguments: [blockID]), replacement != defaultID
            else { continue }
            try db.execute(
                sql: "UPDATE block SET default_variant_id = ?, updated_at = ? WHERE id = ?",
                arguments: [replacement, nowStamp(), blockID])
            try enqueueExplicitly(db, table: "block", rowID: blockID)
            repairs += 1
        }
        return repairs
    }

    private func jsonArray(_ values: Set<String>) -> String {
        let data = try? JSONEncoder().encode(values.sorted())
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }

    // MARK: - Orphan repair, direction 1

    /// Enqueues the local cascade's victims for one freshly-applied parent
    /// tombstone: every child row carrying the parent's exact stamp whose
    /// own tombstone did not arrive in this batch. Mirrors Triggers.swift's
    /// cascade graph exactly; a container's stamped blocks recurse one level
    /// into the block cascade (same stamp throughout).
    private func enqueueSuppressedCascadeVictims(
        _ db: Database,
        parent: (table: String, rowID: String, stamp: String),
        arrivingDead: [String: Set<String>]
    ) throws -> Int {
        var enqueued = 0
        func enqueueMatching(_ childTable: String, _ whereClause: String, _ arguments: [String]) throws -> [String] {
            let ids = try String.fetchAll(
                db,
                sql: "SELECT id FROM \(childTable) WHERE \(whereClause) AND deleted_at = ?",
                arguments: StatementArguments(arguments + [parent.stamp]))
            for id in ids where arrivingDead[childTable]?.contains(id) != true {
                try enqueueExplicitly(db, table: childTable, rowID: id)
                enqueued += 1
            }
            return ids
        }
        switch parent.table {
        case "container":
            let placements = try enqueueMatching("container_block", "container_id = ?", [parent.rowID])
            _ = try enqueueMatching("reading_post", "post_id = ?", [parent.rowID])
            _ = try enqueueMatching("post_tag", "post_id = ?", [parent.rowID])
            _ = try enqueueMatching("reference", "container_id = ?", [parent.rowID])
            // The container cascade tombstoned its singly-owned blocks first
            // (same stamp); each of those fired the block cascade in turn.
            for placementID in placements {
                if let blockID = try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE id = ? AND EXISTS (SELECT 1 FROM block WHERE id = block_id AND deleted_at = ?)",
                    arguments: [placementID, parent.stamp]) {
                    if arrivingDead["block"]?.contains(blockID) != true {
                        try enqueueExplicitly(db, table: "block", rowID: blockID)
                        enqueued += 1
                    }
                    enqueued += try enqueueSuppressedCascadeVictims(
                        db, parent: ("block", blockID, parent.stamp), arrivingDead: arrivingDead)
                }
            }
        case "block":
            _ = try enqueueMatching("variant", "block_id = ?", [parent.rowID])
            _ = try enqueueMatching("container_block", "block_id = ?", [parent.rowID])
            _ = try enqueueMatching(
                "edge", "(source_block_id = ? OR target_block_id = ?)",
                [parent.rowID, parent.rowID])
            _ = try enqueueMatching("block_tag", "block_id = ?", [parent.rowID])
        case "reading":
            _ = try enqueueMatching("reading_post", "reading_id = ?", [parent.rowID])
        case "tag":
            _ = try enqueueMatching("post_tag", "tag_id = ?", [parent.rowID])
            _ = try enqueueMatching("block_tag", "tag_id = ?", [parent.rowID])
        default:
            break
        }
        return enqueued
    }
}
