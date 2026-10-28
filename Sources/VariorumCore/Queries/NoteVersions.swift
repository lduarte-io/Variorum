import Foundation
import GRDB

// **THE WHOLE-NOTE VERSIONS LISTING** (the post-13l polish round, ledger rows
// 16 and 23 — G1 and the V-family).
//
// Her floated shape, adopted: *"an easy door would be to make a copy of the
// note, archive it, and then let you look through the archived copies made at
// points in time — not automated, but an easy door for people who want to save
// the whole note as it is."* It is the round's headline, because her holistic
// worry named it as the one thing people would conclude the app is missing:
// *"people are going to conclude that the one thing they really want (my whole
// note at this point in time) … is way too hard to get."*
//
// ── THE CLASSIFIER, AND WHY IT IS NOT A COLUMN ───────────────────────────────
// **Version history = BORN ARCHIVED + version-linked to a live note.** Both
// halves are load-bearing and both already exist in the schema (V1):
//
//   · **born archived** — `archived_at = created_at`, both stamps written by
//     ONE clock call inside `saveNoteVersion`'s transaction. A same-row birth
//     fact, never a comparison across devices, so the no-clock-trust doctrine
//     is untouched and no CAS repair can rewrite the pair into a different
//     meaning;
//   · **version-linked** — the `version_of` edge the copy already mints, read
//     exactly the way `versionPeerPosts` reads it (posts are edges-only across
//     versions — I8 — and edges are block-to-block, so the post link rides the
//     blocks).
//
// A note that was ever LIVE is never version history: a `duplicateAsVersion`
// fork she made to work with is first-class at birth, and archiving it later
// makes it a set-aside WORK (her sixth-sitting catch, and the reason the
// conjunction is a conjunction).
//
// ── ONE HOME, WHICH IS THE POINT ─────────────────────────────────────────────
// `Queries.archivedPosts` EXCLUDES exactly what this file LISTS (V1): a note
// with fifteen saved moments would otherwise drown the genuinely set-aside
// notes on the Archived surface. The two predicates below are written to be
// exact complements, and the pins hold that.
//
// ── DON'T FORECLOSE THE AUTOMATED FUTURE ─────────────────────────────────────
// `notes/plans/whole-note-history-brief.md` is the automated rotation (master
// plan row **13w**) that will later fill THIS SAME listing. So a row carries a
// `cadence` from the start — today always `.manual`, because a manual door is
// the only thing that mints one — and the face renders automated rows
// indistinguishably except for that label.
extension Queries {
    /// One saved moment of a note, as the listing renders it.
    public struct NoteVersionItem: Equatable, Sendable, Identifiable {
        /// How the moment was taken. **Today always `.manual`** — the
        /// save-a-version door is the only thing that mints one. 13w's
        /// automated rotation fills the same listing and will answer this
        /// from a store fact of its own; the listing's shape does not have
        /// to change for it.
        public enum Cadence: String, Equatable, Sendable {
            case manual
            case automatic
        }

        /// The version container's id — what RESTORE, PROMOTE and Delete take.
        public let postID: String
        /// The moment itself: the copy's `created_at`, which IS its
        /// `archived_at` (the birth fact). **No title mutation** (V6): the
        /// listing shows the DATE by derived display and the copy's own title
        /// is never touched.
        public let savedAt: Date
        /// How many blocks the moment holds.
        public let blockCount: Int
        /// The first block's text, enough to recognise the moment by.
        public let preview: String?
        public let cadence: Cadence

        public var id: String { postID }

        public init(
            postID: String, savedAt: Date, blockCount: Int,
            preview: String? = nil, cadence: Cadence = .manual
        ) {
            self.postID = postID
            self.savedAt = savedAt
            self.blockCount = blockCount
            self.preview = preview
            self.cadence = cadence
        }
    }

    /// Which note the candidate must be a moment OF.
    enum VersionHistoryPeer {
        /// A NAMED note — the caller binds `:note`.
        case note
        /// ANY live note other than the candidate — the Archived surface's
        /// fence, which must exclude exactly what `noteVersions` lists.
        case anyLiveNote
    }

    /// **The version-history predicate, written ONCE — and read by EVERY
    /// scope** (the ladder's LR1-5: the Archived surface's fence used to be
    /// an inline near-copy of this, with real structural differences, so the
    /// classifier could disagree with itself).
    ///
    /// The candidate row is aliased `alias` (`v` here, `container` on the
    /// Archived surface). `peer` says which note it must be a moment of.
    ///
    /// ── WHY THE NOTE SIDE IS READ PAST TOMBSTONES (the ladder's LR1-1) ────
    /// The post-level link RIDES a block-level edge anchored on the note's
    /// FIRST block (I8 — posts are edges-only across versions, and edges are
    /// block-to-block; the anchor is QUESTIONS #19's ratified shape). That
    /// block is ordinary prose: **merge and divide-W release its placement,
    /// `archiveBlock` releases it, `deleteBlock` cascade-tombstones the edge
    /// itself.** Fencing this predicate to LIVE placements therefore made an
    /// everyday join — the one the round's own tutorial teaches — expel every
    /// saved moment from Note ▸ Versions, leak it onto the Archived surface,
    /// orphan it from the deletion ride, and make Restore and Promote refuse.
    ///
    /// So the note side asks the question lineage's way: **was this block
    /// this note's?** — a `container_block` row for the note, whatever its
    /// tombstone says. That is the `strandedOriginals` doctrine verbatim
    /// (*lineage is a fact about what happened*), and it is the same reading
    /// `versionOfNote` below has always used. Liveness that still matters is
    /// carried where it belongs: on the CONTAINERS (`v.deleted_at`, and the
    /// peer's own `deleted_at` under `.anyLiveNote`).
    ///
    /// ── THE EDGE, AND WHY THE UNLINK STILL UNLINKS ───────────────────────
    /// A `version_of` edge dies two ways, and they mean opposite things:
    ///
    /// - a **CASCADE** (`cascade_block_tombstone`) when an endpoint block is
    ///   deleted — the copy still happened, so the moment is still the note's
    ///   past. The cascade stamps the edge with its dead endpoint's OWN
    ///   `deleted_at`, and that exact-stamp signature is what this reads past
    ///   (the 13l exact-stamp doctrine, the same one `versionHistoryDeletedWith`
    ///   leans on);
    /// - a deliberate **`unmarkPostsAsVersions`**, which stamps a time no
    ///   endpoint block shares — so it still unlinks, and the pair really does
    ///   come apart (R60/R68's door, kept honest).
    ///
    /// `pastTombstones` drops even that: the deleted road passes it, because a
    /// whole-note deletion tombstones every placement and every edge with one
    /// stamp and the STAMP is what identifies the family there.
    ///
    /// **What this still cannot survive, recorded rather than hidden:**
    /// `moveBlock` REWRITES the anchor's `container_id` in place (no
    /// tombstone, no `last_container_id`), so moving a note's first block to
    /// another container takes the moments with it — they read as the
    /// destination's. Read-side means cannot tell that from a legitimate
    /// re-home; the durable answer is QUESTIONS #19's option (c), a
    /// post-level link, which is a schema call and hers. Pinned as documented
    /// behaviour in `NoteVersionsTests` and owned by 13w in KnownIssues.
    static func versionHistoryPredicate(
        alias: String = "v", of peer: VersionHistoryPeer = .note,
        pastTombstones: Bool = false
    ) -> String {
        let edgeFence = pastTombstones ? "" : """
              AND (e.deleted_at IS NULL
                   OR EXISTS (SELECT 1 FROM block cascaded
                               WHERE cascaded.id IN (e.source_block_id, e.target_block_id)
                                 AND cascaded.deleted_at = e.deleted_at))
            """
        let peerJoin: String
        let peerWhere: String
        switch peer {
        case .note:
            peerJoin = ""
            peerWhere = "AND theirs.container_id = :note"
        case .anyLiveNote:
            peerJoin = """
                  JOIN container peer
                    ON peer.id = theirs.container_id AND peer.id <> \(alias).id
                   AND peer.kind = 'post' AND peer.deleted_at IS NULL
                """
            peerWhere = ""
        }
        return """
              \(alias).kind = 'post'
              AND \(alias).archived_at IS NOT NULL
              AND \(alias).archived_at = \(alias).created_at
              AND EXISTS (
                SELECT 1 FROM edge e
                JOIN container_block mine
                  ON mine.block_id IN (e.source_block_id, e.target_block_id)
                 AND mine.container_id = \(alias).id
                JOIN container_block theirs
                  ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                 AND theirs.block_id <> mine.block_id
            \(peerJoin)
                WHERE e.type = 'version_of' \(edgeFence) \(peerWhere))
            """
    }

    /// **Note ▸ Versions** — the moments of one note, newest first.
    ///
    /// Cost is the note's own version count (each row reads its block count
    /// and one preview), never the corpus — and the pane is a summoned side
    /// panel, never ambient chrome. `limit` bounds a held observation the way
    /// every other listing's does.
    public static func noteVersions(
        _ db: Database, of postID: String, limit: Int? = nil
    ) throws -> [NoteVersionItem] {
        var sql = """
            SELECT v.id AS post_id, v.created_at AS saved_at,
                   (SELECT COUNT(*) FROM container_block cb
                     WHERE cb.container_id = v.id AND cb.deleted_at IS NULL) AS block_count,
                   (SELECT COALESCE(chosen.working_text, fallback.working_text)
                      FROM container_block cb
                      LEFT JOIN variant chosen ON chosen.id = cb.chosen_variant_id
                      LEFT JOIN block b ON b.id = cb.block_id
                      LEFT JOIN variant fallback ON fallback.id = b.default_variant_id
                     WHERE cb.container_id = v.id AND cb.deleted_at IS NULL
                     ORDER BY cb.position, cb.id LIMIT 1) AS preview
            FROM container v
            WHERE v.deleted_at IS NULL
              AND \(versionHistoryPredicate())
            ORDER BY v.created_at DESC, v.id DESC
            """
        var arguments: StatementArguments = ["note": postID]
        if let limit {
            sql += " LIMIT :limit"
            arguments += ["limit": limit]
        }
        return try Row.fetchAll(db, sql: sql, arguments: arguments).map { row in
            NoteVersionItem(
                postID: row["post_id"], savedAt: row["saved_at"],
                blockCount: row["block_count"] ?? 0, preview: row["preview"],
                // 13w's row will decide this from its own store fact; a manual
                // door is the only thing that can mint one today.
                cadence: .manual)
        }
    }

    /// One saved moment's identity and its moment — what Compare's columns and
    /// the "Compare with Latest Version" door need, without the listing's
    /// per-row block count and preview reads.
    public struct NoteVersionStamp: Equatable, Sendable {
        /// The version container's id.
        public let postID: String
        /// The copy's `created_at` — its birth moment (V6: the DATE is the
        /// version's derived name).
        public let savedAt: Date

        public init(postID: String, savedAt: Date) {
            self.postID = postID
            self.savedAt = savedAt
        }
    }

    /// **The note's saved moments, newest first — NOTE-DRIVEN** (VX-440 batch
    /// 1: Compare's columns and the "Compare with Latest Version" door,
    /// `notes/plans/fixes/vx-440-sheets-history-clarity.md`).
    ///
    /// The answer is `noteVersions`' exactly — same classifier
    /// (`versionHistoryPredicate`, LR1-5: one classifier, read by every scope),
    /// same order — and only the DRIVING differs. `noteVersions` seeks the
    /// partial `idx_container_note_version` index, i.e. walks every saved
    /// moment in the CORPUS and asks each whether it is this note's: fine for a
    /// pane summoned on purpose, wrong for what this read feeds — a fact held
    /// for every note visit (the door's availability), re-asked whenever the
    /// note's rows move. So the candidates come FROM THE NOTE: its placements
    /// (tombstoned included — the classifier reads the note side past its
    /// tombstones, LR1-1), their `version_of` edges in both directions (the
    /// two arms seek `idx_edge_source` / `idx_edge_target`), and the other
    /// endpoint's LIVE placement (the partial live-ownership index). The
    /// classifier then decides every candidate, so this can only ever answer
    /// a subset of `noteVersions`; it answers exactly that set because a saved
    /// moment's own placements are live for as long as the moment is (it is
    /// sealed at birth — nothing restructures it — and its deletion is
    /// `v.deleted_at`, fenced anyway). Pinned equal to the listing across the
    /// note-side shapes LR1-1 rescued (`VersionsInCompareTests`).
    ///
    /// Cost: the note's own placements and their version links — never the
    /// corpus (P1; the plan is pinned).
    public static func noteVersionStamps(
        _ db: Database, of postID: String, limit: Int? = nil
    ) throws -> [NoteVersionStamp] {
        var sql = """
            SELECT v.id AS post_id, v.created_at AS saved_at
            FROM container v
            WHERE v.id IN (
                SELECT mine.container_id
                  FROM container_block theirs
                  JOIN edge e
                    ON e.source_block_id = theirs.block_id AND e.type = 'version_of'
                  JOIN container_block mine
                    ON mine.block_id = e.target_block_id AND mine.deleted_at IS NULL
                 WHERE theirs.container_id = :note
                UNION
                SELECT mine.container_id
                  FROM container_block theirs
                  JOIN edge e
                    ON e.target_block_id = theirs.block_id AND e.type = 'version_of'
                  JOIN container_block mine
                    ON mine.block_id = e.source_block_id AND mine.deleted_at IS NULL
                 WHERE theirs.container_id = :note)
              AND v.deleted_at IS NULL
              AND \(versionHistoryPredicate())
            ORDER BY v.created_at DESC, v.id DESC
            """
        var arguments: StatementArguments = ["note": postID]
        if let limit {
            sql += " LIMIT :limit"
            arguments += ["limit": limit]
        }
        return try Row.fetchAll(db, sql: sql, arguments: arguments).map { row in
            NoteVersionStamp(postID: row["post_id"], savedAt: row["saved_at"])
        }
    }

    /// The note's NEWEST saved moment, if it has one — "Compare with Latest
    /// Version"'s target and its availability fact (VX-440 batch 1).
    public static func latestNoteVersionID(_ db: Database, of postID: String) throws -> String? {
        try noteVersionStamps(db, of: postID, limit: 1).first?.postID
    }

    /// The ids alone — what `deleteContainer`'s sweep needs (V2: versions ride
    /// the note's deletion).
    public static func noteVersionIDs(_ db: Database, of postID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT v.id FROM container v
                WHERE v.deleted_at IS NULL
                  AND \(versionHistoryPredicate())
                ORDER BY v.id
                """,
            arguments: ["note": postID])
    }

    /// Is this container THIS note's saved version? The doors' authorization,
    /// asked inside their own transaction rather than taken from a listing.
    public static func isVersionHistory(
        _ db: Database, _ versionID: String, of postID: String
    ) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (
                  SELECT 1 FROM container v
                  WHERE v.id = :version AND v.deleted_at IS NULL
                    AND \(versionHistoryPredicate()))
                """,
            arguments: ["version": versionID, "note": postID]) ?? false
    }

    /// **The versions that died WITH this note** (V2's restore half): born
    /// archived, version-linked to it, and carrying its EXACT `deleted_at`
    /// stamp — the 13l exact-stamp doctrine, so a version she deleted on its
    /// own earlier (a different stamp) stays dead, and a version deleted after
    /// the note stays dead too.
    ///
    /// Edges and placements are read PAST their tombstones here, because the
    /// note's own cascade took them down — the same reason `strandedOriginals`
    /// reads lineage past tombstones. The stamp is what makes that safe: two
    /// born-archived containers cannot share an ISO stamp to the second unless
    /// one transaction wrote both, which is exactly the case this identifies.
    public static func versionHistoryDeletedWith(
        _ db: Database, note postID: String, stamp: String
    ) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT v.id FROM container v
                WHERE v.deleted_at = :stamp
                  AND \(versionHistoryPredicate(pastTombstones: true))
                ORDER BY v.id
                """,
            arguments: ["note": postID, "stamp": stamp])
    }

    /// **Which note is this a saved version OF** — the Trash row's context
    /// (FOUND-ITEM 1: a deleted version rows in the Trash *"grouped under its
    /// note, honestly labeled"*).
    ///
    /// Tombstone-insensitive for `versionHistoryDeletedWith`'s reason: the
    /// common case is a version that rode its note's deletion, so both sides'
    /// placements and the edge between them are tombstoned. A live peer is
    /// preferred where the version outlived its note's blocks, then the
    /// lexically smallest id — deterministic either way.
    public static func versionOfNote(
        _ db: Database, versionID: String
    ) throws -> (id: String, title: String?)? {
        try versionsOfNotes(db, versionIDs: [versionID])[versionID]
    }

    /// **The same answer for MANY versions, in ONE statement** (pre-13u
    /// Act 4, 17c P19). `trash()`'s `.note` arm called the single-id door
    /// inside a `.map`, once per born-archived row — and that statement has
    /// no seekable driver for the note side, so SQLite drives `n` on
    /// `idx_container_kind` and the inner loop is (the version's placements
    /// × every post in the corpus). Measured: 3.75 ms at 2,000 containers →
    /// 35.7 ms at 20,000, per call. The Trash listing is a HELD observation
    /// whose region includes `variant`, so it re-fires at autosave rate:
    /// with fifteen deleted moments in the window that was fifteen corpus
    /// walks per keystroke's autosave.
    ///
    /// **What this fixes, and what it does not.** The N+1 is gone — one
    /// listing now pays ONE pass however many versions it lists — and the
    /// pass itself is far cheaper, because each edge direction is its own
    /// arm and can seek `idx_edge_source` / `idx_edge_target` (the old
    /// `block_id IN (source, target)` form could use neither). Measured for
    /// fifteen versions at 20,000 containers: 551 ms → 15.0 ms, and a single
    /// lookup 35.9 ms → 8.0 ms.
    /// What remains is that the pass is still LINEAR in the corpus: the
    /// planner drives `container` on `idx_container_kind` because the peer is
    /// reached through `container_block` BY BLOCK ID, and the only index on
    /// that column is the live-rows partial one (`uq_cblock_ownership …
    /// WHERE deleted_at IS NULL`), while this lookup is deliberately
    /// tombstone-insensitive — the common case is a version that rode its
    /// note's deletion, so both sides' placements are tombstoned.
    /// `block.last_container_id` is not a road either: `deleteContainer`
    /// cascades without stamping it. What would close it is an index on
    /// `container_block(block_id)`, which is a schema change with its own
    /// write-path cost — recorded in `KnownIssuesAndTechDebt.md` rather
    /// than taken here.
    ///
    /// **CHUNKED at `fanChunk`, like `activeFans`** (the pre-13u midpoint
    /// review's m1). SQLite binds a bounded number of host parameters
    /// (`SQLITE_MAX_VARIABLE_NUMBER`), and the caller that makes this list
    /// long already exists: `trash()` takes `limit: nil` for its one-shot
    /// callers, which makes the id list the whole 30-day deletion window.
    /// Latent at today's ceiling and at today's version counts — but 13w
    /// fills that listing at machine cadence, and the sibling batcher two
    /// files over already solved it, so the two batched reads share one
    /// shape rather than one of them carrying a cliff.
    ///
    /// **Merging is a plain union, not a reduction:** a version's rows can
    /// only come from the chunk that carries its id (the `mine` CTE filters
    /// on exactly that), so no version is ever scored across two chunks and
    /// the per-chunk answers cannot disagree. That is what makes the
    /// chunked result byte-identical to the single-statement one for any
    /// chunk size — the property `versionsOfNotesChunksEquivalently` pins.
    public static func versionsOfNotes(
        _ db: Database, versionIDs: [String]
    ) throws -> [String: (id: String, title: String?)] {
        guard !versionIDs.isEmpty else { return [:] }
        // The single-id door's ORDER BY, applied per version: a LIVE peer
        // wins, then the lexically smallest id — deterministic either way.
        var best: [String: (live: Bool, id: String, title: String?)] = [:]
        var start = 0
        while start < versionIDs.count {
            let chunk = Array(versionIDs[start..<min(start + fanChunk, versionIDs.count)])
            start += fanChunk
            try accumulateVersionPeers(db, chunk: chunk, into: &best)
        }
        return best.mapValues { (id: $0.id, title: $0.title) }
    }

    /// One chunk's pass, folded into the running answer.
    private static func accumulateVersionPeers(
        _ db: Database, chunk: [String],
        into best: inout [String: (live: Bool, id: String, title: String?)]
    ) throws {
        let placeholders = databaseQuestionMarks(count: chunk.count)
        let rows = try Row.fetchAll(
            db,
            sql: """
                WITH mine(version_id, block_id) AS (
                  SELECT cb.container_id, cb.block_id FROM container_block cb
                   WHERE cb.container_id IN (\(placeholders))
                ),
                -- The two edge directions as separate arms, so each one can
                -- SEEK (`idx_edge_source` / `idx_edge_target`); the old
                -- `block_id IN (source, target)` form could use neither.
                links(version_id, my_block, peer_block) AS (
                  SELECT mine.version_id, mine.block_id, e.target_block_id
                    FROM mine JOIN edge e ON e.source_block_id = mine.block_id
                   WHERE e.type = 'version_of'
                  UNION ALL
                  SELECT mine.version_id, mine.block_id, e.source_block_id
                    FROM mine JOIN edge e ON e.target_block_id = mine.block_id
                   WHERE e.type = 'version_of'
                )
                SELECT links.version_id AS version_id,
                       links.my_block AS my_block, links.peer_block AS peer_block,
                       n.id AS note_id, n.title AS title,
                       n.entry_date AS entry_date, n.created_at AS created_at,
                       (n.deleted_at IS NULL) AS peer_is_live
                  FROM links
                  JOIN container_block theirs ON theirs.block_id = links.peer_block
                  JOIN container n
                    ON n.id = theirs.container_id AND n.kind = 'post'
                   AND n.id <> links.version_id
                """,
            arguments: StatementArguments(chunk))
        for row in rows {
            // The old statement's `theirs.block_id <> mine.block_id`, applied
            // HERE and not in SQL: as a WHERE term — in the arms or in the
            // outer select — it costs the edge seeks the arms exist for
            // (measured 13.8 ms → 106 ms for fifteen versions at 20,000
            // containers). It fences a degenerate self-edge, which the
            // canonical `(min(id), max(id))` storage of `version_of` cannot
            // mint in the first place; free in Swift, so it stays.
            guard (row["my_block"] as String?) != (row["peer_block"] as String?)
            else { continue }
            let versionID: String = row["version_id"]
            let noteID: String = row["note_id"]
            let live = (row["peer_is_live"] as Int? ?? 0) == 1
            if let held = best[versionID],
               held.live != live ? held.live : held.id <= noteID {
                continue
            }
            best[versionID] = (
                live: live, id: noteID,
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["created_at"]))
        }
    }
}

extension AppDatabase {
    /// **Note ▸ Versions, live.** Held only while the pane is on screen: it
    /// reads `variant` (the previews) and `container_block`, so a standing
    /// observation would re-run at autosave rate — the tray panel's and the
    /// Block History pane's own class, adjudicated record-only for owner 12.
    /// Bounded by the note's version count either way (P1: never the corpus).
    public func observeNoteVersions(
        _ postID: String, limit: Int
    ) -> AsyncValueObservation<[Queries.NoteVersionItem]> {
        observe { try Queries.noteVersions($0, of: postID, limit: limit) }
    }

    /// **The note's newest saved moment, live** (VX-440 batch 1) — held for a
    /// note's visit by its detail, so "Compare with Latest Version" renders
    /// exactly while the note has one (P-2). The read is note-driven
    /// (`noteVersionStamps`), so a re-run costs the note's own placements and
    /// links, never the corpus; it reads no `variant`, so a keystroke's
    /// autosave re-asks only through the container row it touches.
    public func observeLatestNoteVersion(_ postID: String) -> AsyncValueObservation<String?> {
        observe { try Queries.latestNoteVersionID($0, of: postID) }
    }
}
