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
        try Row.fetchOne(
            db,
            sql: """
                SELECT n.id AS note_id, n.title AS title,
                       n.entry_date AS entry_date, n.created_at AS created_at
                FROM edge e
                JOIN container_block mine
                  ON mine.block_id IN (e.source_block_id, e.target_block_id)
                 AND mine.container_id = :version
                JOIN container_block theirs
                  ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                 AND theirs.block_id <> mine.block_id
                JOIN container n
                  ON n.id = theirs.container_id AND n.kind = 'post' AND n.id <> :version
                WHERE e.type = 'version_of'
                ORDER BY (n.deleted_at IS NULL) DESC, n.id
                LIMIT 1
                """,
            arguments: ["version": versionID]
        ).map { row in
            (id: row["note_id"],
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
}
