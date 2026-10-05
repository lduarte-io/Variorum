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
    /// Applied `reading` rows — the firing scope of the two FURNITURE
    /// convergence repairs (pre-13u Act 0): the Journal keeper and the
    /// sample-library dedupe both check only when a batch touched a book.
    var readingIDs: Set<String> = []
    /// Applied `container` rows — the seeded-furniture fold's note/pool
    /// occasion (17y B-DEDUPE): a reserved-titled container landing is the
    /// moment its grain can first have two copies to judge.
    var containerIDs: Set<String> = []
    /// True when the batch touched the daily-book designation setting —
    /// the Journal keeper's second (belt) firing occasion.
    var dailyDesignationTouched = false
    /// True for the PULL path's apply — a changefeed batch, or the
    /// empty-window re-fire — and false for a push chunk's reject-merges.
    /// The sample-library dedupe fires ONLY under a pull (the ladder's
    /// R2-1): only a pull can land the rows an in-flight copy is missing,
    /// so a push-path pass can only ever classify on a picture no pull has
    /// completed — and production's round is pull → push, so the push half
    /// ran the deferred pass at the first chunk of the SAME round, with
    /// nothing new landed, and retired the copy the pull had just deferred
    /// on. The Journal keeper is untouched by this flag: its evidence is
    /// the reading row itself.
    var isPullBatch = false
    /// Tag ids named by `post_tag` rows applied in this batch — the
    /// dedupe's EVIDENCE occasion (R2-1/R2-6): a reserved-path application
    /// landing is exactly the moment a tag-leg deferral was waiting for,
    /// so the pass re-examines the copy at that apply and at no other.
    var appliedPostTagTagIDs: Set<String> = []
    /// Same-name sample copies an ARRIVING retirement began killing in
    /// this batch (the two-copy meeting context), with the retirement's
    /// stamp and the copy's verdict from the REAL classifier read at the
    /// FIRST family death — a member container's or the reading's own
    /// live→dead transition, whichever arrives first in registry order —
    /// while the copy was still whole, the only moment the ruled
    /// classification can be computed. The defense leg reads these
    /// post-batch and defends only where the READING itself ended dead.
    var sampleCopyKills: [(copyID: String, stamp: String, verdict: SampleCopyVerdict)] = []
    /// Inline (write-time) repair count, for reporting.
    var inlineRepairs = 0
    // ——— 13i-a (the wings/shelves/books event) ———
    /// Post ids named by applied `reading_post` rows — the OWNED-exclusivity
    /// repair's firing scope (a membership landing is the only act that can
    /// create the violation from the membership side).
    var membershipPostIDs: Set<String> = []
    /// Applied `shelf` rows — the Welcome-keeper repair's firing scope.
    var shelfIDs: Set<String> = []
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
    ///
    /// Returns the row as it actually LANDED — the incoming row, or the
    /// inline repairs' resolution of it. `merge` compares THAT against the
    /// server row to decide whether local intent survived (the ladder's F1:
    /// comparing its own pre-repair copy instead cleared the outbox entry an
    /// inline repair had just enqueued, so the repair never pushed).
    @discardableResult
    func writeResolvedRow(
        _ db: Database, _ row: SyncRow, serverSeq: Int64, touched: inout TouchedRows
    ) throws -> SyncRow {
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
            case "canvas_layout":
                // Phase 11 (A1): two devices positioning the same card
                // offline mint two live rows for one (container, block) —
                // pure duplicate, keep the smaller id (the surviving row's
                // x/y then converges by ordinary metadata CAS).
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["container_id", "block_id"], touched: &touched)
            case "lens_choice":
                // Phase 11 (A1): same class for a lens's per-block pick.
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["lens_id", "block_id"], touched: &touched)
            case "purge_intent":
                // Phase 13j (v1_14): two devices asking to purge the same
                // row is not a conflict — the act is idempotent by nature.
                // Pure duplicate on (table_name, row_id): keep the smaller
                // id, tombstone the other (the memo's §5a repair rule).
                resolved = try repairDuplicateCollision(
                    db, row, naturalKey: ["table_name", "row_id"], touched: &touched)
            default:
                break
            }
        }
        // The Journal keeper's arrival-order independence, direction 2
        // (the ladder's F1): a live membership or chapter arriving under a
        // DEAD daily-Journal loser while a live keeper exists is the
        // keeper's, not the cascade's — it re-points (or dedupes) exactly
        // as the repair would have, instead of joining the loser's cascade
        // below. Runs BEFORE the orphan check so the re-pointed row is no
        // orphan; the post-side dead check still applies after it.
        if !resolved.isTombstoned, ["reading_post", "reading_section"].contains(resolved.table) {
            resolved = try repointJournalChildUnderDeadLoser(db, resolved, touched: &touched)
        }
        // The tag.path repair's arrival-order independence (RUN B B2 row 7
        // — 17i fix item 1, KnownIssues row 34; pre-existing since Phase
        // 5): SyncSpec §7's "re-point the duplicate's post_tag/block_tag
        // rows to the keeper" has NO time bound, but the collision repair
        // above re-points only applications PRESENT when the duplicate
        // dies. One arriving AFTER that (registry order puts `tag` before
        // both application tables, so the same batch suffices) met the
        // dead parent in the orphan check below, joined its cascade, and
        // that tombstone won the merge in both push orders — two devices
        // creating one path offline and applying it to DIFFERENT notes
        // lost one side's applications everywhere. The Journal keeper's
        // direction-2 shape, applied to tags: same-path is the §7
        // identity, exactly as mint-shape is the Journal's. Runs BEFORE
        // the orphan check so the re-pointed row is no orphan; the
        // post/block-side dead-parent check still applies after it.
        if !resolved.isTombstoned, ["post_tag", "block_tag"].contains(resolved.table) {
            resolved = try repointApplicationUnderDeadDuplicateTag(db, resolved, touched: &touched)
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
           ["container", "block", "reading", "tag", "lens"].contains(resolved.table),
           case .text(let stamp) = resolved.columns["deleted_at"] {
            let wasLive = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM \(resolved.table) WHERE id = ? AND deleted_at IS NULL)",
                arguments: [resolved.rowID]) ?? false
            if wasLive {
                touched.tombstonedParents.append((resolved.table, resolved.rowID, stamp))
            }
        }
        // The Journal keeper's arrival-order independence, direction 1 (the
        // ladder's F1): a daily-Journal LOSER landing dead while a live
        // keeper stands hands its live local memberships and chapters to
        // the keeper BEFORE the tombstone lands. Two shapes, one rule:
        //  - the loser is LIVE here (this device holds its entries — the
        //    loser's own device, or any device that pulled them): the (still
        //    active) cascade would otherwise kill them, and this device
        //    would push N membership tombstones that then WIN the merge
        //    against the repairer's re-points travelling in a later push
        //    chunk — the finding's whole-Journal-structure loss;
        //  - the loser is ABSENT here and arrives already dead (a fresh
        //    store, a third device: the feed is state-based, so the loser's
        //    only row is its tombstone, at a seq AFTER its memberships'):
        //    an INSERT fires no cascade, and the memberships applied earlier
        //    in the batch would dangle live under a dead book until the
        //    repairer's re-points land — which they never do if that device
        //    is gone.
        //    THIS LEG RELIES ON THE DRAIN ORDER (the ladder's R2-7): the
        //    keeper's `reading` insert reaches `server_seq` BEFORE the
        //    loser's tombstone only because the push sorts a table's rows
        //    by ascending id (`SyncEngine.precedesInDrain`) and the keeper
        //    is the smaller id by the repair's definition — so the fresh
        //    store applies the keeper first and `journalKeeperBesideRetiring`
        //    finds it standing when the tombstone lands. Stated here and at
        //    the comparator, and pinned by `TheDrainOrderTests`.
        // With no keeper in sight this is an ordinary delete: the cascade
        // takes its victims exactly as ever.
        // RUN B B2 row 15 Part 2 — the defense leg's KILL-TIME EVIDENCE:
        // an arriving retirement's FIRST family death names the copy, and
        // the REAL classifier reads it AT THAT MOMENT — while the copy is
        // still whole. The moment matters precisely: a retirement arrives
        // in REGISTRY order, member CONTAINERS before the reading row, so
        // a verdict taken at the reading's own tombstone reads a
        // half-killed copy (dead members = "her pruning" = EDITED) and
        // would revive every correct retirement forever — the scratch
        // trace's ping-pong. The hook therefore fires on the first
        // arriving live→dead transition of a member CONTAINER or of the
        // READING itself, once per copy per batch; the verdict and the
        // retirement's stamp are recorded for the post-batch defense
        // (`defendEditedSampleCopies`), which also requires the READING
        // to have actually died — a lone member-note deletion is an
        // ordinary delete, never a kill. Pull-only, like the pass
        // (R2-1's logic). Repair bookkeeping cannot mint this evidence:
        // the classifier reads domain rows, never the outbox.
        if resolved.isTombstoned, touched.isPullBatch, !sampleLibraryFacts.isEmpty,
           ["container", "reading"].contains(resolved.table),
           case .text(let killStamp) = resolved.columns["deleted_at"] {
            try recordSampleCopyKillEvidence(
                db, arriving: resolved, stamp: killStamp, touched: &touched)
        }
        if resolved.isTombstoned, resolved.table == "reading",
           let keeperID = try journalKeeperBesideRetiring(db, arriving: resolved) {
            touched.inlineRepairs += try moveJournalChildren(
                db, from: resolved.rowID, to: keeperID, stamp: nowStamp())
            // …and the DESIGNATION follows the children (the ladder's
            // R2-4): between this tombstone's chunk and the repairer's
            // `setting` chunk, a designation still naming the loser read
            // as "no designation" (the read is liveness-filtered), and
            // ⌘J / the phone's capture (and, until 2026-09-04, the
            // bridge) MINTED a third
            // mint-shape Journal — a Trash row and a dangling pin she never
            // caused, retired by the next batch.
            touched.inlineRepairs += try convergeDailyDesignation(
                db, to: keeperID, retiring: resolved.rowID)
        }
        try resolved.apply(db)
        noteApplied(resolved, touched: &touched)
        return resolved
    }

    // MARK: - The Journal keeper's arrival-order legs (the ladder's F1)

    /// The live keeper a dead-landing daily-Journal reading's children move
    /// to, or nil when the reading is not the daily mint's shape, is already
    /// dead here (nothing live to move), or no other candidate stands — then
    /// the tombstone is an ordinary delete.
    ///
    /// The shape is satisfied by EITHER the local row (when one exists and
    /// is live) OR the arriving row's own columns (the ladder's R2-2).
    /// The arriving tombstone is the REPAIRER's verdict: it retired a book
    /// it saw wearing the daily mint's shape. A loser she RENAMED here
    /// before that tombstone landed is not mint-shape locally — and
    /// reading the local row alone turned the repair's verdict into an
    /// ordinary delete: the cascade killed her N memberships, the victim
    /// sweep pushed N tombstones at the merge-stamped version, they were
    /// accepted, and the Journal emptied on both devices — F1's loss by
    /// another door. The local leg still stands on its own for the mirror
    /// case (an arriving tombstone whose columns she renamed elsewhere).
    /// The keeper is the smallest OTHER candidate: the repair only ever
    /// retires larger ids, so this is the same choice every device makes.
    private func journalKeeperBesideRetiring(
        _ db: Database, arriving row: SyncRow
    ) throws -> String? {
        var isMintShape = false
        if let local = try Reading.fetchOne(db, key: row.rowID) {
            guard local.deletedAt == nil else { return nil }
            isMintShape = Queries.isDailyJournalMintShape(local)
        }
        if !isMintShape,
           case .text(let kindText) = row.columns["kind"],
           let kind = ReadingKind(rawValue: kindText),
           case .text(let name) = row.columns["name"] {
            var profile: String?
            if case .text(let text) = row.columns["profile"] { profile = text }
            isMintShape = Queries.isDailyJournalMintShape(kind: kind, profile: profile, name: name)
        }
        guard isMintShape else { return nil }
        return try Queries.dailyJournalBookCandidates(db).first { $0 != row.rowID }
    }

    /// A live `reading_post` / `reading_section` arriving under a DEAD
    /// daily-Journal reading while a live keeper stands: re-point it to the
    /// keeper — a membership whose post the keeper already holds tombstones
    /// as a pure duplicate instead (`uq_reading_post_live`, the tag.path
    /// application rule) — and enqueue it explicitly. Byte-identical to
    /// what `moveJournalChildren` writes on the device that ran the repair,
    /// so the two devices' rows meet as equals under CAS.
    private func repointJournalChildUnderDeadLoser(
        _ db: Database, _ row: SyncRow, touched: inout TouchedRows
    ) throws -> SyncRow {
        guard case .text(let readingID) = row.columns["reading_id"],
              let parent = try Reading.fetchOne(db, key: readingID), parent.deletedAt != nil,
              Queries.isDailyJournalMintShape(parent),
              let keeperID = try Queries.dailyJournalBookCandidates(db).first
        else { return row }
        var resolved = row
        if row.table == "reading_post", case .text(let postID) = row.columns["post_id"],
           try keeperHoldsPost(db, keeperID: keeperID, postID: postID, excluding: row.rowID) {
            resolved.columns["deleted_at"] = .text(nowStamp())
        } else {
            resolved.columns["reading_id"] = .text(keeperID)
        }
        try enqueueExplicitly(db, table: row.table, rowID: row.rowID)
        touched.inlineRepairs += 1
        return resolved
    }

    /// A live `post_tag`/`block_tag` arriving under a DEAD tag while a
    /// LIVE tag carries the same path: the §7 tag.path rule's
    /// arrival-order leg (RUN B B2 row 7). Re-point it to the keeper — or
    /// tombstone it as a pure duplicate when the keeper is already applied
    /// to the same target (`uq_post_tag_live`/`uq_block_tag_live`) — and
    /// enqueue explicitly. Byte-identical to what `repairTagPathCollision`
    /// writes on the device that held the rows at collision time, so the
    /// two roads' rows meet as equals under CAS.
    ///
    /// A missing tag row stays a STRAGGLER (SyncSpec §5 tolerance — the
    /// leg reads only a locally-present dead tag), and a dead tag with NO
    /// live same-path keeper is an ordinary deletion: the cascade below
    /// takes the application exactly as ever. PROVISIONAL consequence,
    /// recorded (QUESTIONS — the run record's draft): a deliberate
    /// tombstone-then-recreate now also catches a stale offline
    /// application onto the recreation, because at arrival time the two
    /// histories are the same picture (dead tag + live same-path keeper) —
    /// the rescue direction, per the §6 "deleting an edit nobody chose to
    /// lose" doctrine.
    private func repointApplicationUnderDeadDuplicateTag(
        _ db: Database, _ row: SyncRow, touched: inout TouchedRows
    ) throws -> SyncRow {
        guard case .text(let tagID) = row.columns["tag_id"],
              let dead = try Row.fetchOne(
                  db,
                  sql: "SELECT path, wing_id FROM tag WHERE id = ? AND deleted_at IS NOT NULL",
                  arguments: [tagID]),
              // 13i-a (R-13ia-1): same-(wing, path) is the §7 identity now.
              let keeperID = try String.fetchOne(
                  db,
                  sql: """
                      SELECT id FROM tag
                      WHERE path = ? AND wing_id = ? AND deleted_at IS NULL AND id <> ?
                      ORDER BY id LIMIT 1
                      """,
                  arguments: [dead["path"] as String, dead["wing_id"] as String, tagID])
        else { return row }
        let targetColumn = row.table == "post_tag" ? "post_id" : "block_id"
        guard case .text(let targetID) = row.columns[targetColumn] else { return row }
        var resolved = row
        let keeperAlreadyApplied = try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM \(row.table)
                WHERE tag_id = ? AND \(targetColumn) = ? AND deleted_at IS NULL AND id <> ?)
                """,
            arguments: [keeperID, targetID, row.rowID]) ?? false
        if keeperAlreadyApplied {
            resolved.columns["deleted_at"] = .text(nowStamp())
        } else {
            resolved.columns["tag_id"] = .text(keeperID)
        }
        try enqueueExplicitly(db, table: row.table, rowID: row.rowID)
        touched.inlineRepairs += 1
        return resolved
    }

    private func keeperHoldsPost(
        _ db: Database, keeperID: String, postID: String, excluding membershipID: String
    ) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND id <> ?)
                """,
            arguments: [keeperID, postID, membershipID]) ?? false
    }

    /// Moves a daily-Journal loser's live chapters and memberships to the
    /// keeper, enqueuing every write (SyncSpec §7). Chapters move whole —
    /// duplicate names and interleaved positions are both legal, so nothing
    /// is lost and membership `section_id` pointers stay meaningful. A
    /// membership whose post the keeper already holds is a pure duplicate
    /// and tombstones (`uq_reading_post_live`). Shared by the post-batch
    /// repair and direction 1 above so the two roads cannot drift.
    private func moveJournalChildren(
        _ db: Database, from loserID: String, to keeperID: String, stamp: String
    ) throws -> Int {
        var repairs = 0
        let sections = try String.fetchAll(
            db,
            sql: "SELECT id FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL",
            arguments: [loserID])
        for sectionID in sections {
            try db.execute(
                sql: "UPDATE reading_section SET reading_id = ?, updated_at = ? WHERE id = ?",
                arguments: [keeperID, stamp, sectionID])
            try enqueueExplicitly(db, table: "reading_section", rowID: sectionID)
            repairs += 1
        }
        let memberships = try Row.fetchAll(
            db,
            sql: "SELECT id, post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
            arguments: [loserID])
        for membership in memberships {
            let membershipID: String = membership["id"]
            if try keeperHoldsPost(
                db, keeperID: keeperID, postID: membership["post_id"], excluding: membershipID) {
                try db.execute(
                    sql: "UPDATE reading_post SET deleted_at = ? WHERE id = ?",
                    arguments: [stamp, membershipID])
            } else {
                try db.execute(
                    sql: "UPDATE reading_post SET reading_id = ? WHERE id = ?",
                    arguments: [keeperID, membershipID])
            }
            try enqueueExplicitly(db, table: "reading_post", rowID: membershipID)
            repairs += 1
        }
        return repairs
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
        case "canvas_layout": parents = [("container_id", "container"), ("block_id", "block")]
        case "lens": parents = [("container_id", "container")]
        // A lens_choice's variant parent is deliberately absent: a dead
        // variant is the read-time fall-through class, never a cascade.
        case "lens_choice": parents = [("lens_id", "lens"), ("block_id", "block")]
        // Phase 13 (A1): comments cascade with their block; sections with
        // their reading. reading_post's SECTION parent is deliberately
        // absent — a dead section is the dangles-as-unsectioned read-time
        // class, never a cascade.
        case "block_comment": parents = [("block_id", "block")]
        case "reading_section": parents = [("reading_id", "reading")]
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
        case "container":
            touched.containerIDs.insert(row.rowID)
        case "reading":
            touched.readingIDs.insert(row.rowID)
        case "setting" where row.rowID == "daily_journal_book":
            touched.dailyDesignationTouched = true
        case "post_tag":
            if case .text(let tagID) = row.columns["tag_id"] {
                touched.appliedPostTagTagIDs.insert(tagID)
            }
        // 13i-a: the two new repairs' firing scopes.
        case "reading_post":
            if case .text(let postID) = row.columns["post_id"] {
                touched.membershipPostIDs.insert(postID)
            }
        case "shelf":
            touched.shelfIDs.insert(row.rowID)
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
        // 13i-a (R-13ia-1): the vocabulary is PER-WING — the collision is
        // (wing_id, path); identical paths in two wings are legal twins.
        // An absent wing column (a pre-window mirror row) reads as '' (Home).
        let wingID: String = if case .text(let wing) = row.columns["wing_id"] { wing } else { "" }
        guard let rivalID = try String.fetchOne(
            db,
            sql: """
                SELECT id FROM tag
                WHERE path = ? AND wing_id = ? AND deleted_at IS NULL AND id <> ?
                """,
            arguments: [path, wingID, row.rowID])
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
            // 13i-a (R1, sitting record §4): before the rival retires, the
            // kept reading_post row's STATUS resolves to 'member' when
            // EITHER side was one — a seating outranks the bell, whichever
            // id sorts smaller. (Only the two rows THIS collision holds are
            // consulted — an anciently-removed membership never promotes.)
            if row.table == "reading_post",
               case .text("arrival") = row.columns["status"],
               try Bool.fetchOne(
                   db,
                   sql: "SELECT status = 'member' FROM reading_post WHERE id = ?",
                   arguments: [rivalID]) ?? false {
                resolved.columns["status"] = .text("member")
                // Ladder R1 B-1: the PROMOTION is a repair write on the
                // KEPT row — it must push, or asymmetric rounds leave the
                // mirror (and the un-met device) holding 'arrival' forever
                // (§7's forgotten-enqueue divergence, exactly).
                try enqueueExplicitly(db, table: row.table, rowID: resolved.rowID)
            }
            try db.execute(
                sql: "UPDATE \(row.table) SET deleted_at = ? WHERE id = ?",
                arguments: [stamp, rivalID])
            try enqueueExplicitly(db, table: row.table, rowID: rivalID)
        } else {
            if row.table == "reading_post",
               case .text("member") = row.columns["status"] {
                // The incoming member retires; the kept rival, if a bell,
                // is promoted in place (same rule, other keep-shape).
                try db.execute(
                    sql: """
                        UPDATE reading_post SET status = 'member'
                        WHERE id = ? AND status = 'arrival'
                        """,
                    arguments: [rivalID])
                if db.changesCount > 0 {
                    try enqueueExplicitly(db, table: "reading_post", rowID: rivalID)
                }
            }
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
        // chosen is a legal domain state the fallback covers. Both legs are
        // indexed lookups (the PK; uq_cblock_ownership on live block_id) so
        // the pass stays batch-proportional (Phase 5 review — the previous
        // chosen_variant_id leg had no index and scanned live placements).
        // A chosen pointer parked on a FOREIGN block's placement is outside
        // this scope by design: the operations layer forbids minting one and
        // the read side gaps it (Operations.renderedVariant's same-block
        // guard).
        let placementScope = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.id, cb.chosen_variant_id FROM container_block cb
                WHERE cb.id IN (SELECT value FROM json_each(?))
                  AND cb.deleted_at IS NULL AND cb.chosen_variant_id IS NOT NULL
                UNION
                SELECT cb.id, cb.chosen_variant_id FROM container_block cb
                WHERE cb.block_id IN (SELECT value FROM json_each(?))
                  AND cb.deleted_at IS NULL AND cb.chosen_variant_id IS NOT NULL
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

        // The two FURNITURE convergence repairs (pre-13u Act 0): each fires
        // only when the batch touched a book — one small indexed check per
        // fired batch, then real work only in the once-per-store-life event
        // of two independently-seeded copies actually meeting.
        if !touched.readingIDs.isEmpty || touched.dailyDesignationTouched {
            repairs += try convergeDailyJournalDuplicates(db, touched: touched)
        }
        // RUN B B2 row 15 Part 2 — THE DEFENSE LEG, before the pass: a
        // same-name copy an arriving retirement killed this batch revives
        // exact-stamp when the ruled matrix says it must survive. See
        // `defendEditedSampleCopies` for the evidence arm and its rulings.
        if !touched.sampleCopyKills.isEmpty {
            repairs += try defendEditedSampleCopies(db, touched: touched)
        }
        // The dedupe's occasions — PULL-ONLY, three of them (the ladder's
        // F2, then R2-1/R2-6): a book touched by the batch, the one-shot
        // marker a deferred pass left, or a reserved-path tag application
        // arriving (the evidence a tag-leg deferral waited for). See
        // `sampleDedupeOccasion` for why the push path never fires it.
        if try sampleDedupeOccasion(db, touched: touched) {
            repairs += try dedupeSampleLibraryCopies(db, touched: touched)
        }
        // 13i-a (R2): OWNED exclusivity — fired by a membership landing or
        // a reading landing (an arriving owned flag can create the
        // violation from the book side with zero membership rows in the
        // batch).
        if !touched.membershipPostIDs.isEmpty || !touched.readingIDs.isEmpty {
            repairs += try repairOwnedExclusivity(db, touched: touched)
        }
        // 13i-a (R5): the Welcome-shelf keeper — fired by a shelf landing.
        if !touched.shelfIDs.isEmpty {
            repairs += try convergeWelcomeShelves(db, touched: touched)
        }
        // 17y B-DEDUPE (R-17y-5): the seeded-furniture pairwise fold —
        // pull-only occasions of its own (`furnitureDedupeOccasion`), run
        // AFTER the Welcome keeper so shelf pointers it reads are already
        // converged, and after the tag fold (the per-row apply) so rule
        // re-points see the folded vocabulary.
        if try furnitureDedupeOccasion(db, touched: touched) {
            repairs += try dedupeSeededFurniture(db, touched: touched)
        }
        return repairs
    }

    // MARK: - 13i-a: OWNED exclusivity (R2 — PROVISIONAL #167)

    /// Two devices racing acts that OWNED forbids from co-existing (a note
    /// membered in an owned book AND anywhere else) converge by the rule
    /// intake itself uses (sitting record §6): the EARLIEST-ACCEPTED act
    /// stands, and the later conflicting act repairs to what its door would
    /// have done knowing the truth —
    ///   * the later act is the OWNED-side membership → it DEMOTES to an
    ///     ARRIVAL (the bell: "lives elsewhere — claim / copy in / leave");
    ///   * the later act is a PLAIN-side membership beside a standing owned
    ///     one → it is TOMBSTONED (the ownership promise defended at the
    ///     door; the row is an ordinary recoverable tombstone).
    /// Rank: a never-accepted row carries no authority (`sync_row_seq` = 0,
    /// §3's rule — it ranks LAST), then ascending `server_seq`, then id.
    /// Deterministic on every device; idempotent (the repaired state has no
    /// violation); every write enqueues explicitly.
    private func repairOwnedExclusivity(_ db: Database, touched: TouchedRows) throws -> Int {
        // Scope: the batch's membership posts, plus every member post of a
        // touched OWNED reading (the flag may have just arrived).
        let candidatePosts = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT post_id FROM reading_post
                WHERE post_id IN (SELECT value FROM json_each(?))
                   OR reading_id IN (
                        SELECT id FROM reading
                        WHERE id IN (SELECT value FROM json_each(?)) AND owned = 1)
                """,
            arguments: [jsonArray(touched.membershipPostIDs), jsonArray(touched.readingIDs)])
        var repairs = 0
        let stamp = nowStamp()
        for postID in candidatePosts.sorted() {
            let members = try Row.fetchAll(
                db,
                sql: """
                    SELECT rp.id, r.owned AS owned,
                           COALESCE(s.server_seq, 0) AS seq
                    FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                    LEFT JOIN sync_row_seq s
                      ON s.table_name = 'reading_post' AND s.row_id = rp.id
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL
                      AND rp.status = 'member'
                    """,
                arguments: [postID])
            guard members.contains(where: { $0["owned"] as Int64 == 1 }),
                  members.count > 1 else { continue }
            let ranked = members.sorted { lhs, rhs in
                let (ls, rs) = (lhs["seq"] as Int64, rhs["seq"] as Int64)
                let (lRank, rRank) = (ls == 0 ? Int64.max : ls, rs == 0 ? Int64.max : rs)
                if lRank != rRank { return lRank < rRank }
                return (lhs["id"] as String) < (rhs["id"] as String)
            }
            let earliestIsOwned = (ranked[0]["owned"] as Int64) == 1
            for (index, member) in ranked.enumerated() {
                let membershipID: String = member["id"]
                let owned = (member["owned"] as Int64) == 1
                if earliestIsOwned {
                    if index == 0 { continue }  // the standing claim
                    if owned {
                        try db.execute(
                            sql: "UPDATE reading_post SET status = 'arrival' WHERE id = ?",
                            arguments: [membershipID])
                    } else {
                        try db.execute(
                            sql: "UPDATE reading_post SET deleted_at = ? WHERE id = ?",
                            arguments: [stamp, membershipID])
                    }
                    try enqueueExplicitly(db, table: "reading_post", rowID: membershipID)
                    repairs += 1
                } else if owned {
                    // The note was already membered when the claim arrived:
                    // every owned-side membership bells instead.
                    try db.execute(
                        sql: "UPDATE reading_post SET status = 'arrival' WHERE id = ?",
                        arguments: [membershipID])
                    try enqueueExplicitly(db, table: "reading_post", rowID: membershipID)
                    repairs += 1
                }
            }
        }
        return repairs
    }

    // MARK: - 13i-a: the Welcome-shelf keeper (R5)

    /// Two devices' seeders racing the Welcome shelf offline converge on
    /// the daily keeper's pattern, keyed on the `role='welcome'` marker
    /// (never the name — she may rename Welcome): per wing, the smallest id
    /// keeps; the losers' books re-point to the keeper; the losers
    /// tombstone. Every write enqueues explicitly.
    private func convergeWelcomeShelves(_ db: Database, touched: TouchedRows) throws -> Int {
        let wings = try String.fetchAll(
            db,
            sql: """
                SELECT wing_id FROM shelf
                WHERE role = 'welcome' AND deleted_at IS NULL
                GROUP BY wing_id HAVING COUNT(*) > 1
                """)
        var repairs = 0
        let stamp = nowStamp()
        for wing in wings {
            let duplicates = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM shelf
                    WHERE role = 'welcome' AND wing_id = ? AND deleted_at IS NULL
                    ORDER BY id
                    """,
                arguments: [wing])
            guard duplicates.count > 1, let keeper = duplicates.first else { continue }
            for loser in duplicates.dropFirst() {
                let books = try String.fetchAll(
                    db,
                    sql: "SELECT id FROM reading WHERE shelf_id = ? AND deleted_at IS NULL",
                    arguments: [loser])
                for bookID in books {
                    try db.execute(
                        sql: "UPDATE reading SET shelf_id = ? WHERE id = ?",
                        arguments: [keeper, bookID])
                    try enqueueExplicitly(db, table: "reading", rowID: bookID)
                    repairs += 1
                }
                try db.execute(
                    sql: "UPDATE shelf SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, loser])
                try enqueueExplicitly(db, table: "shelf", rowID: loser)
                repairs += 1
            }
        }
        return repairs
    }

    // MARK: - The Journal keeper (pre-13u Act 0, R-pre13u-1)

    /// Two designated daily-Journal books, each minted by a device that
    /// correctly saw "no Journal exists yet", converge deterministically:
    /// the `tag.path` pattern — **the smaller id keeps**, the loser's live
    /// chapters and memberships move to the keeper (a membership whose post
    /// the keeper already holds is a pure duplicate and tombstones —
    /// `uq_reading_post_live`), the loser is tombstoned, and the daily-book
    /// DESIGNATION converges to the keeper wherever it named a loser.
    ///
    /// The predicate is `Queries.dailyJournalBookCandidates` over the one
    /// pure function `Queries.isDailyJournalMintShape` — curated + the
    /// journal profile + the daily mint's default NAME under `BookNaming`'s
    /// key (narrowed at the ladder's F6: profile alone merged the deliberate
    /// second notebooks the Shelf and the phone mint on purpose; see that
    /// function's doc for the reasoning and the recorded renamed-keeper
    /// corner).
    ///
    /// What deliberately does NOT move, the tag.path class ("worst case a
    /// lost rename, never corruption"): the loser's row metadata (a custom
    /// name, extents, a finish) and its shelf-pin entry (which dangles
    /// harmlessly — the pins read is liveness-filtered). A keeper that is
    /// FINISHED still receives the loser's memberships: a repair is not
    /// authoring, the resolveSyncConflict-under-seal doctrine.
    ///
    /// The designation half runs whenever a keeper stands at all — not only
    /// when this pass retired a loser (the ladder's R2-4): on a fresh store
    /// the feed can deliver the retired loser's tombstone in one batch and
    /// the `setting` row still naming it AFTER (registry order), and a
    /// designation left dangling at a dead Journal is exactly what makes
    /// the next ⌘J mint a third.
    func convergeDailyJournalDuplicates(_ db: Database, touched: TouchedRows) throws -> Int {
        let candidates = try Queries.dailyJournalBookCandidates(db)
        guard let keeperID = candidates.first else { return 0 }
        var repairs = 0
        for loserID in candidates.dropFirst() {
            let stamp = nowStamp()
            // Chapters and memberships move whole to the keeper (the shared
            // leg direction 1 also runs, so the two roads cannot drift).
            repairs += try moveJournalChildren(db, from: loserID, to: keeperID, stamp: stamp)
            // The loser retires. Its live children have all just moved, so
            // the (still-active) cascade trigger finds nothing — the victim
            // sweep is the §7 belt for anything it stamped anyway.
            try db.execute(
                sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                arguments: [stamp, stamp, loserID])
            try enqueueExplicitly(db, table: "reading", rowID: loserID)
            repairs += 1
            repairs += try enqueueSuppressedCascadeVictims(
                db, parent: ("reading", loserID, stamp),
                arrivingDead: touched.arrivingDeadIDs)
        }
        repairs += try convergeDailyDesignation(db, to: keeperID, retiring: nil)
        return repairs
    }

    /// The daily-book designation converges to the keeper where it names a
    /// RETIRED candidate: the loser this call is retiring (`retiring` —
    /// direction 1, before its tombstone lands), or a reading that is DEAD
    /// here and wears the daily mint's shape (a loser another device
    /// retired, its tombstone already applied; the fresh-store leg). ONE
    /// rule for both roads, shared exactly like `moveJournalChildren` so
    /// they cannot drift (the ladder's R2-4).
    ///
    /// What it never touches: a designation naming a LIVE book — one she
    /// deliberately moved to a different, or renamed, book is hers, and the
    /// repair never overrides it. A designation at a dead NON-mint-shaped
    /// book is left dangling too (the ensure's own "reads as none" road).
    /// Plain UPDATE, never REPLACE: `sync_version` is the CAS token and
    /// must survive; enqueued explicitly (SyncSpec §7).
    private func convergeDailyDesignation(
        _ db: Database, to keeperID: String, retiring loserID: String?
    ) throws -> Int {
        guard let designated = try String.fetchOne(
                  db, sql: "SELECT value FROM setting WHERE key = 'daily_journal_book'"),
              designated != keeperID
        else { return 0 }
        if designated != loserID {
            guard let named = try Reading.fetchOne(db, key: designated),
                  named.deletedAt != nil,
                  Queries.isDailyJournalMintShape(named)
            else { return 0 }
        }
        try db.execute(
            sql: "UPDATE setting SET value = ? WHERE key = 'daily_journal_book'",
            arguments: [keeperID])
        try enqueueExplicitly(db, table: "setting", rowID: "daily_journal_book")
        return 1
    }

    func jsonArray(_ values: Set<String>) -> String {
        let data = try? JSONEncoder().encode(values.sorted())
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }

    // MARK: - Orphan repair, direction 1

    /// Enqueues the local cascade's victims for one freshly-applied parent
    /// tombstone: every child row carrying the parent's exact stamp whose
    /// own tombstone did not arrive in this batch. Mirrors Triggers.swift's
    /// cascade graph exactly; a container's stamped blocks recurse one level
    /// into the block cascade (same stamp throughout).
    ///
    /// Internal (not private) since pre-13u Act 0: the furniture repairs —
    /// the Journal keeper above and the sample-library dedupe in
    /// `SampleLibraryDedupe.swift` — mint parent tombstones of their own
    /// inside apply mode, and this sweep is what keeps their cascades'
    /// victims reaching the outbox (SyncSpec §7).
    func enqueueSuppressedCascadeVictims(
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
            _ = try enqueueMatching("canvas_layout", "container_id = ?", [parent.rowID])
            // The container cascade tombstoned its lenses (same stamp);
            // each lens's own trigger cascaded its choices in turn.
            let lenses = try enqueueMatching("lens", "container_id = ?", [parent.rowID])
            for lensID in lenses {
                enqueued += try enqueueSuppressedCascadeVictims(
                    db, parent: ("lens", lensID, parent.stamp), arrivingDead: arrivingDead)
            }
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
            _ = try enqueueMatching("canvas_layout", "block_id = ?", [parent.rowID])
            _ = try enqueueMatching("lens_choice", "block_id = ?", [parent.rowID])
            // Phase 13 (A1): the block's comments died with it locally.
            _ = try enqueueMatching("block_comment", "block_id = ?", [parent.rowID])
        case "reading":
            _ = try enqueueMatching("reading_post", "reading_id = ?", [parent.rowID])
            // Phase 13 (A1): the reading's chapters died with it locally.
            _ = try enqueueMatching("reading_section", "reading_id = ?", [parent.rowID])
        case "tag":
            _ = try enqueueMatching("post_tag", "tag_id = ?", [parent.rowID])
            _ = try enqueueMatching("block_tag", "tag_id = ?", [parent.rowID])
        case "lens":
            _ = try enqueueMatching("lens_choice", "lens_id = ?", [parent.rowID])
        default:
            break
        }
        return enqueued
    }
}
