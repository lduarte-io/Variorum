import Foundation
import GRDB

/// **The sample-library dedupe's injected facts** (pre-13u Act 0,
/// R-pre13u-8) — everything the engine needs to recognise and classify a
/// seeded sample-library copy, and nothing else.
///
/// ── WHY INJECTED ──────────────────────────────────────────────────────
/// The identity predicate and the per-note manifest live with the seeder in
/// `App/Variorum/Shared/SampleLibrary/` — app-target code this module
/// cannot see. The engine therefore takes the facts the way it takes its
/// E2EE keys (`keyProvider`): a value handed in at wiring by the app layer,
/// with a nil default that leaves the repair INERT — an engine nobody wired
/// facts into cannot misidentify a book, which is the safe failure shape.
/// Both platforms wire it at the ONE shared composition site
/// (`SyncSession.configure`), so the two apps cannot drift.
///
/// ── WHY THE HASH RECIPE RIDES ALONG ───────────────────────────────────
/// The manifest's stored hashes and the repair's freshly-computed ones must
/// be the SAME recipe or every comparison silently fails. The recipe is
/// core's own public `BridgeHash.body` (SHA-256 hex of the UTF-8 bytes —
/// chosen at the Opus half precisely because both sides can name it), and
/// it travels here as a function reference so the wiring site hands the
/// pair — hashes and recipe — from one place. A drift would make every
/// note read as edited, which fails SAFE: both copies survive; an edited
/// copy is never retired by a recipe bug.
public struct SampleLibraryDedupeFacts: Sendable {
    /// The reserved book name — the seeder's own `discover` rule: EXACT,
    /// case-sensitive match on a live reading's name. Deliberately not
    /// folded: a copy she renamed stops matching, reads as her own book,
    /// and is left alone (a rename is engagement).
    public var bookName: String
    /// The reserved tag path. A live application pointing at any OTHER tag
    /// is engagement (she organised the copy).
    public var tagPath: String
    /// note title → hash of the text the seed stores for it. A closure
    /// because building it parses the bundled resource (~0.5 MB) — the
    /// repair calls it only when two same-name copies actually meet, which
    /// happens at most about once in a store's life.
    public var loadNoteHashes: @Sendable () throws -> [String: String]
    /// The recipe the stored hashes were built with.
    public var hash: @Sendable (String) -> String

    public init(
        bookName: String,
        tagPath: String,
        loadNoteHashes: @escaping @Sendable () throws -> [String: String],
        hash: @escaping @Sendable (String) -> String
    ) {
        self.bookName = bookName
        self.tagPath = tagPath
        self.loadNoteHashes = loadNoteHashes
        self.hash = hash
    }
}

/// **The sample-library pristine-copy dedupe** (pre-13u Act 0, R-pre13u-8)
/// — the SyncSpec §7 class applied to seeded demo content: two devices each
/// correctly decided "no sample library exists yet", both seeded, and the
/// pair met under sync. Her ruled resolution:
///
///   - both PRISTINE → deterministic keeper (smaller id); the other's
///     whole family retires — nothing lost, the copies are byte-identical;
///   - exactly one EDITED → the EDITED copy is kept, the pristine retired;
///   - both EDITED → BOTH survive (the documented concurrent-divide class
///     — **an edited copy is NEVER silently retired**).
///
/// A copy is PRISTINE when its live notes are exactly the manifest's titles
/// with matching per-note rendered-text hashes AND it shows no other sign
/// of her hands (a fanned or archived take, a savepoint, a comment, a tag,
/// a membership in another book, a seal, floating notes, a reference — all
/// invisible to the rendered text, all her writing or her acts, and the
/// whole point of the rule is that her work is never the copy retired).
/// Every extension of the ruled hash rule errs in ONE direction only:
/// toward classifying EDITED, which keeps copies, never retires them.
///
/// A copy whose rows are still in flight (a membership's post not yet
/// arrived, a block without any variant row — the SyncSpec §5 straggler
/// class) is INDETERMINATE, and any indeterminate copy defers the WHOLE
/// pass: acting on partial data could retire the wrong copy on one device
/// and a different one on another. Deferring is free — a later batch
/// completes the picture and every device then computes the same verdicts.
///
/// ── WHEN THE PASS RUNS, AND WHAT A DEFERRAL WAITS FOR (the ladder's F2,
/// then round 2's R2-1/R2-3/R2-6) ────────────────────────────────────────
/// The pass fires ONLY under a PULL (`TouchedRows.isPullBatch`) — never
/// from a push chunk's reject-merge transaction — on three occasions:
///   1. the batch applied a `reading` row (the F2 occasion);
///   2. the ONE-SHOT local marker left by occasion 1's own deferral: a
///      copy whose book arrived THIS batch is indeterminate for the pass,
///      because its engagement rows sort after `reading_post` in the push
///      order and can still be in the pusher's next chunk; the marker
///      re-fires the pass at the next pull — an empty window included,
///      that being the head-reached moment — and is spent the instant a
///      pass runs, whatever it decides (R2-3);
///   3. a `post_tag` row for the RESERVED path applied in this batch: the
///      evidence the reserved-tag completeness guard waits for.
/// The guard (`classifySampleCopy`, R2-1): every live member post of a
/// seeded copy carries the reserved tag, and `post_tag` is the FIRST
/// engagement table in the push order — so a member with NO `post_tag`
/// row for the reserved path (live or dead; any tag row wearing the path,
/// live or dead — a collision-retired duplicate counts) proves the
/// pusher's tag chunk has not landed, and the copy is INDETERMINATE. That
/// deferral re-arms nothing: it is re-examined at the apply that lands
/// the reserved-path applications (occasion 3), which is exactly when its
/// evidence can first exist. What the guard cannot see: an engagement row
/// in a table AFTER `post_tag` (`block_tag`, `reference`, `block_comment`)
/// travelling in a chunk of its own behind a landed tag chunk — the
/// recorded residual (its KnownIssues row, owner 13y).
extension SyncEngine {
    enum SampleCopyVerdict: Equatable {
        case pristine
        case edited
        case indeterminate
    }

    /// Whether this batch is one of the pass's three occasions (above).
    /// Pull-only by construction; cost: two flag reads, one local-only
    /// marker read, and — only when the batch applied `post_tag` rows —
    /// one indexed lookup of their tag ids against the reserved path.
    func sampleDedupeOccasion(_ db: Database, touched: TouchedRows) throws -> Bool {
        guard touched.isPullBatch, let facts = sampleLibraryFacts else { return false }
        if !touched.readingIDs.isEmpty { return true }
        if try sampleDedupePending(db) { return true }
        guard !touched.appliedPostTagTagIDs.isEmpty else { return false }
        return try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM tag
                               WHERE path = ? AND id IN (SELECT value FROM json_each(?)))
                """,
            arguments: [facts.tagPath, jsonArray(touched.appliedPostTagTagIDs)]) ?? false
    }

    /// The pass. Fires from `runPostApplyRepairs` on the occasions above;
    /// the candidate scan is one indexed read, and the expensive work
    /// (manifest load + per-note classification) runs only when two live
    /// same-name copies actually coexist.
    func dedupeSampleLibraryCopies(_ db: Database, touched: TouchedRows) throws -> Int {
        guard let facts = sampleLibraryFacts else { return 0 }
        // The seeder's own `discover` rule: EXACT live-name match.
        let copies = try String.fetchAll(
            db,
            sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
            arguments: [facts.bookName])
        guard copies.count > 1 else { return 0 }
        // The ladder's F2: a copy whose `reading` row arrived in THIS batch
        // is indeterminate for the pass. Its engagement signals — post_tag,
        // block_tag, reference, block_comment — sort AFTER reading_post in
        // the push order and can still be in the pusher's next chunk, so a
        // pull landing between the chunks would read an edited-by-comment
        // copy as pristine and retire it. Classify only copies quiescent
        // since a prior batch; the deferral leaves a ONE-SHOT local marker
        // so the next apply (or the next pull, even an empty one) re-runs
        // the pass instead of waiting for another book to change. Bounded
        // by construction: the marker is cleared the moment a pass runs
        // past this check, whatever that pass then decides.
        if copies.contains(where: touched.readingIDs.contains) {
            try setSampleDedupePending(db, true)
            return 0
        }
        try setSampleDedupePending(db, false)
        let manifest = try facts.loadNoteHashes()
        let reservedTagID = try String.fetchOne(
            db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
            arguments: [facts.tagPath])

        var pristine: [String] = []
        var edited: [String] = []
        for copyID in copies {
            switch try classifySampleCopy(
                db, copyID: copyID, manifest: manifest,
                reservedTagID: reservedTagID, reservedTagPath: facts.tagPath, hash: facts.hash) {
            case .pristine: pristine.append(copyID)
            case .edited: edited.append(copyID)
            case .indeterminate: return 0  // defer the whole pass
            }
        }
        // Survivors: every edited copy; plus, when none is edited, the
        // smallest-id pristine one. (Three-plus copies generalize the ruled
        // pair rules: pristine copies are redundant beside ANY survivor.)
        let retired = edited.isEmpty ? Array(pristine.dropFirst()) : pristine
        var repairs = 0
        for copyID in retired {
            repairs += try retireSampleCopy(
                db, copyID: copyID, arrivingDead: touched.arrivingDeadIDs)
        }
        return repairs
    }

    /// The F2 marker: LOCAL-ONLY (`sync_state`, never synced — it names a
    /// fact about this device's apply history, not about the corpus). Read
    /// by `sampleDedupeOccasion` as the pass's second firing occasion and by
    /// `pull` at an empty window; never by the push path (R2-1).
    static let sampleDedupePendingKey = "sample_dedupe_pending"

    func sampleDedupePending(_ db: Database) throws -> Bool {
        try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)",
            arguments: [Self.sampleDedupePendingKey]) ?? false
    }

    private func setSampleDedupePending(_ db: Database, _ pending: Bool) throws {
        if pending {
            try db.execute(
                sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, '1')",
                arguments: [Self.sampleDedupePendingKey])
        } else {
            try db.execute(
                sql: "DELETE FROM sync_state WHERE key = ?",
                arguments: [Self.sampleDedupePendingKey])
        }
    }

    /// One copy's verdict, computed from SYNCED rows only — the same answer
    /// on every device once the rows have converged, which is what makes
    /// the keeper choice deterministic.
    private func classifySampleCopy(
        _ db: Database, copyID: String, manifest: [String: String],
        reservedTagID: String?, reservedTagPath: String, hash: (String) -> String
    ) throws -> SampleCopyVerdict {
        // Book-level acts: a finish, an extent, a grouping.
        guard let reading = try Row.fetchOne(
            db,
            sql: "SELECT locked, word_target, max_posts, grouping_tag_id FROM reading WHERE id = ?",
            arguments: [copyID])
        else { return .indeterminate }
        if (reading["locked"] as Int? ?? 0) != 0
            || (reading["word_target"] as Int?) != nil
            || (reading["max_posts"] as Int?) != nil
            || (reading["grouping_tag_id"] as String?) != nil {
            return .edited
        }

        let memberships = try Row.fetchAll(
            db, sql: "SELECT post_id, deleted_at FROM reading_post WHERE reading_id = ?",
            arguments: [copyID])
        // No membership rows AT ALL: a straggling copy (its memberships are
        // in flight) — a copy she emptied would carry tombstones. Defer.
        guard !memberships.isEmpty else { return .indeterminate }
        let livePostIDs = memberships
            .filter { ($0["deleted_at"] as String?) == nil }
            .map { $0["post_id"] as String }
        let deadMemberships = memberships.count - livePostIDs.count
        // Fewer live notes than shipped with no tombstone evidence: rows
        // may still be in flight — defer, never guess. (A pruned copy shows
        // its tombstones; a purge that removed them leaves the copy
        // indeterminate forever, which fails safe: both copies survive.)
        if livePostIDs.count < manifest.count && deadMemberships == 0 {
            return .indeterminate
        }

        var titles = Set<String>()
        for postID in livePostIDs.sorted() {
            guard let post = try Row.fetchOne(
                db,
                sql: """
                    SELECT title, locked, archived_at, entry_date, floating_notes, deleted_at
                    FROM container WHERE id = ?
                    """,
                arguments: [postID])
            else { return .indeterminate }  // the post has not arrived yet
            if (post["deleted_at"] as String?) != nil { return .edited }
            if (post["locked"] as Int? ?? 0) != 0
                || (post["archived_at"] as String?) != nil
                || (post["entry_date"] as String?) != nil {
                return .edited
            }
            if let notes = post["floating_notes"] as String?, !notes.isEmpty { return .edited }
            // A cleared title, a title the manifest does not know, or a
            // duplicated one: her act, or her note — never pristine.
            guard let title = post["title"] as String?,
                  manifest[title] != nil,
                  titles.insert(title).inserted
            else { return .edited }

            // The reserved-tag COMPLETENESS guard (the ladder's R2-1): the
            // seed tags every note it mints, and `post_tag` is the first
            // engagement table in the push order — a shipped note with no
            // application of the reserved path at all (any liveness, any
            // tag row wearing the path: a collision-retired duplicate's
            // dead application counts) means the pusher's tag chunk has
            // not landed, and the engagement rows behind it cannot have
            // either. Indeterminate — re-examined when those applications
            // arrive (the third occasion), never guessed pristine. After
            // the title check on purpose: a note SHE added carries no
            // reserved tag and is already `.edited` above.
            let reservedTagLanded = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM post_tag pt
                                   JOIN tag t ON t.id = pt.tag_id
                                   WHERE pt.post_id = ? AND t.path = ?)
                    """,
                arguments: [postID, reservedTagPath]) ?? false
            guard reservedTagLanded else { return .indeterminate }

            // Structural completeness (stragglers defer) + fan shape (a
            // fanned or archived take is engagement the render cannot see).
            let placements = try Row.fetchAll(
                db,
                sql: "SELECT block_id, deleted_at FROM container_block WHERE container_id = ?",
                arguments: [postID])
            guard !placements.isEmpty else { return .indeterminate }
            let liveBlocks = placements
                .filter { ($0["deleted_at"] as String?) == nil }
                .map { $0["block_id"] as String }
            for blockID in liveBlocks {
                let blockExists = try Bool.fetchOne(
                    db, sql: "SELECT EXISTS (SELECT 1 FROM block WHERE id = ?)",
                    arguments: [blockID]) ?? false
                guard blockExists else { return .indeterminate }
                guard let shape = try Row.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) AS total,
                          COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'active'
                                            THEN 1 ELSE 0 END), 0) AS active,
                          COALESCE(SUM(CASE WHEN deleted_at IS NULL AND status = 'archived'
                                            THEN 1 ELSE 0 END), 0) AS archived
                        FROM variant WHERE block_id = ?
                        """,
                    arguments: [blockID])
                else { return .indeterminate }
                guard (shape["total"] as Int? ?? 0) > 0 else { return .indeterminate }
                if (shape["active"] as Int? ?? 0) != 1 || (shape["archived"] as Int? ?? 0) != 0 {
                    return .edited
                }
            }

            // Engagement the seed never produces: another book's membership,
            // a tag beyond the reserved one, a block tag, a comment, a
            // MANUAL savepoint, a reference. `kind = 'manual'` is
            // load-bearing (the ladder's F5): the six quiet AUTO occasions
            // (OverallModel §3 — leaving a note, the idle backstop, the
            // seals, …) are insurance the system mints on its own, and
            // `isDirty` reads a never-committed seeded take as dirty, so
            // merely opening a story and leaving stamps it `'auto'` — on
            // every device, since commit_point syncs. Counting those made
            // "both pristine" unreachable in any real store (two Sherlock
            // books forever, silently). Only her deliberate ⌘S is her hand.
            let engagement = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM reading_post
                                   WHERE post_id = ?1 AND reading_id <> ?2 AND deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM post_tag
                                   WHERE post_id = ?1 AND deleted_at IS NULL AND tag_id <> ?3)
                        OR EXISTS (SELECT 1 FROM block_tag bt
                                   JOIN container_block cb ON cb.block_id = bt.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND bt.deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM block_comment bc
                                   JOIN container_block cb ON cb.block_id = bc.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND bc.deleted_at IS NULL)
                        OR EXISTS (SELECT 1 FROM commit_point cp
                                   JOIN variant v ON v.id = cp.variant_id
                                   JOIN container_block cb ON cb.block_id = v.block_id
                                   WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                     AND cp.kind = 'manual')
                        OR EXISTS (SELECT 1 FROM reference
                                   WHERE container_id = ?1 AND deleted_at IS NULL)
                    """,
                arguments: [postID, copyID, reservedTagID ?? ""]) ?? false
            if engagement { return .edited }

            // The ruled per-note rule itself, last: byte-identity of the
            // rendered text against the shipped manifest.
            let rendered = try Queries.renderedText(db, containerID: postID)
            guard manifest[title] == hash(rendered) else { return .edited }
        }
        // Every live note pristine — but only the EXACT shipped set is a
        // pristine COPY: fewer titles with tombstone evidence is a pruning,
        // and any dead membership at all records an act of hers. Reaching
        // here with fewer titles MEANS tombstone evidence exists (the
        // no-evidence case deferred above), so both legs read EDITED — the
        // ladder's F3 found the second leg returning `.indeterminate`, which
        // deferred the whole pass forever and kept both copies instead of
        // the ruled "edited kept, pristine retired".
        guard titles.count == manifest.count, deadMemberships == 0 else {
            return .edited
        }
        return .pristine
    }

    /// Retires one copy, family-complete: the book (its cascade takes the
    /// memberships and chapters at this exact stamp), then each member note
    /// (the container cascade takes placements, blocks, variants, tags,
    /// references). Ordinary tombstones — the Trash lists them — and every
    /// write reaches the outbox: the direct writes explicitly, the cascades
    /// via the victim sweep (SyncSpec §7).
    ///
    /// **Put back, honestly** (the ladder's F4): this family shape — a book
    /// AND its member notes under ONE stamp — is one no ordinary op mints,
    /// and `restoreReading` revives only stamp-matched MEMBERSHIPS, never
    /// containers. Putting the retired BOOK back therefore yields a book
    /// whose members are still in the Trash; each note's own Put back
    /// revives it (and its membership, by the stamp). Fourteen rows in a
    /// Trash she never asked to fill, and a fourteen-step road out — both
    /// recorded for her at QUESTIONS #85(e); widening the recovery door is
    /// an op-semantics call, not this repair's.
    private func retireSampleCopy(
        _ db: Database, copyID: String, arrivingDead: [String: Set<String>]
    ) throws -> Int {
        var repairs = 0
        let stamp = nowStamp()
        let memberPosts = try String.fetchAll(
            db,
            sql: "SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL ORDER BY post_id",
            arguments: [copyID])
        try db.execute(
            sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
            arguments: [stamp, stamp, copyID])
        try enqueueExplicitly(db, table: "reading", rowID: copyID)
        repairs += 1
        repairs += try enqueueSuppressedCascadeVictims(
            db, parent: ("reading", copyID, stamp), arrivingDead: arrivingDead)
        for postID in memberPosts {
            try db.execute(
                sql: "UPDATE container SET deleted_at = ?, updated_at = ? WHERE id = ? AND deleted_at IS NULL",
                arguments: [stamp, stamp, postID])
            try enqueueExplicitly(db, table: "container", rowID: postID)
            repairs += 1
            repairs += try enqueueSuppressedCascadeVictims(
                db, parent: ("container", postID, stamp), arrivingDead: arrivingDead)
        }
        return repairs
    }
}
