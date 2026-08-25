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

    /// **The version-history predicate, written ONCE.**
    ///
    /// `:note` is the note whose versions are wanted; the candidate row is
    /// aliased `v`. `liveOnly` fences the edge and both placements to live
    /// rows — the ordinary reading; the deleted road passes `false` because a
    /// whole-note deletion cascade-tombstones every placement and every edge,
    /// and *lineage is a fact about what happened* (the `strandedOriginals`
    /// doctrine, which this borrows verbatim).
    static func versionHistoryPredicate(liveOnly: Bool) -> String {
        let edgeLive = liveOnly ? "AND e.deleted_at IS NULL" : ""
        let mineLive = liveOnly ? "AND mine.deleted_at IS NULL" : ""
        let theirsLive = liveOnly ? "AND theirs.deleted_at IS NULL" : ""
        return """
              v.kind = 'post'
              AND v.archived_at IS NOT NULL AND v.archived_at = v.created_at
              AND EXISTS (
                SELECT 1 FROM edge e
                JOIN container_block mine
                  ON mine.block_id IN (e.source_block_id, e.target_block_id)
                 AND mine.container_id = v.id \(mineLive)
                JOIN container_block theirs
                  ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                 AND theirs.block_id <> mine.block_id \(theirsLive)
                WHERE e.type = 'version_of' \(edgeLive)
                  AND theirs.container_id = :note)
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
              AND \(versionHistoryPredicate(liveOnly: true))
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
                  AND \(versionHistoryPredicate(liveOnly: true))
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
                    AND \(versionHistoryPredicate(liveOnly: true)))
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
                  AND \(versionHistoryPredicate(liveOnly: false))
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
