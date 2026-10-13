import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's WING MOVE (13n-c U6 — VX-160, VX-160's ratified "I want per
// item move to be allowed via mcp"; the brief §10's R1 · T1 · U1, nodded
// through at the sitting). Like every act the door takes, an ORDINARY
// OPERATION: HER door's act (`moveNoteToWing` — the one relocation, her tag
// adoption by path, her severed memberships, her refusals), run inside ONE
// transaction behind the caller's `WriteGuard`, plus the ONE thing her door
// deliberately lacks and every MCP write must carry (P-13nb-U2-4): a
// client-named structural-undo entry with an EXACT-ROW inverse and redo.
//
// Her door registers no entry ("moving back is the symmetric door"), and her
// primitive reports only the books it left — so the act WRAPS it, never
// re-derives it: the note's live membership rows, its live tag applications
// (the note's own and its placed blocks') and its versions' wings are read
// BEFORE and AFTER her act, inside the same transaction, and the difference is
// the entry's exact rows. The inverse and the redo then flip THOSE rows — no
// fresh row, no re-run of the adoption (minted tags stay as vocabulary,
// P-13nb-U2-6's precedent).
extension Operations {
    /// What one MCP wing move did: her door's answer, plus the books it left
    /// by ID (the wire names a book only where the client can read it — AF-10
    /// (f): names stay with grants).
    public struct MCPWingMove: Equatable, Sendable {
        public let move: NoteWingMove
        /// The readings whose MEMBER row the move severed, earliest first, each
        /// once (her `leftBooks` names them in the same order).
        public let leftBookIDs: [String]
    }

    /// One tag application row (`post_tag` or `block_tag`).
    struct WingMoveApplication: Hashable, Sendable {
        let table: String
        let id: String
    }

    /// The exact rows one wing move changed — what its undo and redo replay.
    struct WingMoveRows: Sendable {
        let postID: String
        /// The note's STORED `wing_id` before the move (a dangling pointer kept
        /// as it was — the undo writes back exactly what stood).
        let sourceWing: String
        let destinationWing: String
        /// Each saved version the move re-homed → its stored `wing_id` before.
        let versionWings: [String: String]
        /// The membership rows (members AND arrivals) the move severed.
        let severed: [String]
        /// Applications live before the move and dead after (re-pointed away).
        let removedApplications: [WingMoveApplication]
        /// Applications live after the move and not before (their re-pointed
        /// copies in the destination's vocabulary).
        let addedApplications: [WingMoveApplication]
    }

    /// **`move_note_to_wing`'s act** — her door (`moveNoteToWing(_:_:to:)`,
    /// the same body her Move to Wing ▸ runs) inside ONE transaction, the
    /// caller's guard FIRST (the server's two decisions, re-made on the act's
    /// own facts, once grants stamped there — AF-10 (a)'s seam). Her refusals
    /// are hers, unchanged: `postAlreadyInWing`, `wingNotFound`, and a MEMBER
    /// of a finished or sealed book (`lockedReading` / `readingSealed`) — each
    /// rolls the whole act back.
    ///
    /// ONE undo entry, `undoLabel` ("claude-code's wing move"): the inverse
    /// puts the note and its versions back in the wing they came from, revives
    /// the exact membership rows the move severed (on the stamp that severed
    /// them) and the exact applications it re-pointed, and tombstones the
    /// re-pointed copies; tags the move minted stay. The redo is the same rows
    /// the other way. See `revertMCPWingMove` / `reapplyMCPWingMove` for the
    /// edges (obsolete, refused).
    @discardableResult
    public func mcpMoveNoteToWing(
        _ postID: String, to wingID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPWingMove {
        let landed: (result: MCPWingMove, rows: WingMoveRows, stamp: String) = try database.write { db in
            try guardian?(db)
            let source = try livePost(db, postID).wingId
            let memberships = try wingMoveMemberships(db, postID: postID)
            let before = try wingMoveState(db, postID: postID)
            let (move, now) = try moveNoteToWing(db, postID, to: wingID)
            let after = try wingMoveState(db, postID: postID)
            var leftIDs: [String] = []
            for (row, reading) in memberships where row.status == .member && !leftIDs.contains(reading.id) {
                leftIDs.append(reading.id)
            }
            let rows = WingMoveRows(
                postID: postID, sourceWing: source, destinationWing: wingID,
                versionWings: before.versionWings.filter { after.versionWings[$0.key] != $0.value },
                severed: memberships.map(\.row.id).filter { !after.memberships.contains($0) },
                removedApplications: before.applications.filter { !after.applications.contains($0) },
                addedApplications: after.applications.filter { !before.applications.contains($0) })
            return (MCPWingMove(move: move, leftBookIDs: leftIDs), rows,
                    DateFormatter.variorumISO8601.string(from: now))
        }
        let rows = landed.rows
        // The stamps the replays match on: the forward direction's (the act,
        // then each redo) and the backward direction's (each undo).
        let forward = LockIsolated(landed.stamp)
        let backward = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                if let stamp = try ops.revertMCPWingMove(rows, forwardStamp: forward.value) {
                    backward.setValue(stamp)
                }
            },
            redo: { ops in
                if let stamp = try ops.reapplyMCPWingMove(rows, backwardStamp: backward.value) {
                    forward.setValue(stamp)
                }
            })
        return landed.result
    }

    // MARK: - The rows a move reads (before and after, inside its transaction)

    /// The note's live membership rows (her `wingMoveMemberships` predicate),
    /// its live applications (the note's own + its PLACED blocks' — exactly
    /// the rows her `relocateNote` re-points) and its live versions' stored
    /// wings.
    private func wingMoveState(_ db: Database, postID: String) throws -> (
        memberships: Set<String>, applications: [WingMoveApplication], versionWings: [String: String]
    ) {
        let memberships = Set(try wingMoveMemberships(db, postID: postID).map(\.row.id))
        var applications = try String.fetchAll(
            db,
            sql: "SELECT id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL ORDER BY created_at, id",
            arguments: [postID]
        ).map { WingMoveApplication(table: "post_tag", id: $0) }
        applications += try String.fetchAll(
            db,
            sql: """
                SELECT bt.id FROM container_block cb
                JOIN block_tag bt ON bt.block_id = cb.block_id AND bt.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY bt.created_at, bt.id
                """,
            arguments: [postID]
        ).map { WingMoveApplication(table: "block_tag", id: $0) }
        var versionWings: [String: String] = [:]
        for versionID in try Queries.noteVersionIDs(db, of: postID) {
            guard let version = try Container.fetchOne(db, key: versionID), version.deletedAt == nil
            else { continue }
            versionWings[versionID] = version.wingId
        }
        return (memberships, applications, versionWings)
    }

    // MARK: - The replays

    /// **The inverse — the note back where it came from, on the move's own
    /// rows.** Returns the stamp it tombstoned the re-pointed copies on (the
    /// redo revives exactly those), or nil when the entry is OBSOLETE and
    /// nothing was written.
    ///
    /// - **Obsolete (quiet — the 13i-d letter: a replay that would cross wings
    ///   does nothing):** the note is gone (trashed since), it is no longer in
    ///   the wing the move took it to (her own door moved it on), or EITHER of
    ///   the entry's wings is no longer live (the combined ladder R1's F1: a
    ///   dead stood-in wing reads as Home everywhere else, so a replay keyed
    ///   on its stored id would miss the note's effective — Home — vocabulary
    ///   and could carry a Home application across wings, or un-obsolete an
    ///   entry her own door had already moved on), or the note's own CURRENT
    ///   wing is no longer live (the ladder R2's N1, RULED quiet-obsolete at
    ///   her sitting's fourth round: a dead stored pointer resolving to Home
    ///   must not satisfy the stood-in check against a HOME entry wing and
    ///   replay a note her door moved on — the moved-on letter outranks
    ///   dangling-reads-as-Home inside these guards, both directions).
    /// - **Refused, the entry KEPT (resolvable — PROVISIONAL P-13nc-U6-3):** the
    ///   note has since joined a book (a member or a waiting arrival) or taken a
    ///   tag in the wing it would leave — putting it back would split that book
    ///   or that vocabulary across wings (§9). `wingMoveChangedSince`.
    /// - Otherwise, in ONE transaction: the re-pointed copies tombstoned; the
    ///   original applications revived (their tag live, their block still
    ///   placed in the note, no live twin); the note and the versions the move
    ///   re-homed back to their stored wing; the severed rows revived where
    ///   they stood (on the stamp that severed them, the book live and in the
    ///   note's wing, no live row for the pair, a SEALED book only for a sealed
    ///   note — `restoreContainer`'s letter; a FINISHED book takes its row back,
    ///   R-13id-3's "a restore returns what was there"), purge intents voided,
    ///   then the revival pass (`enforceOwnershipAfterRevival`).
    func revertMCPWingMove(_ rows: WingMoveRows, forwardStamp: String) throws -> String? {
        try database.write { db in
            guard var note = try Container.fetchOne(db, key: rows.postID), note.deletedAt == nil,
                  // F1 (the combined ladder R1): BOTH wings must be live — a
                  // dead stood-in wing makes the entry OBSOLETE, never
                  // "effectively Home" (`sameEffectiveWing` alone would read a
                  // dead destination as Home, and the stored-id vocabulary
                  // check below could not see the note's Home applications).
                  try Queries.wingIsLive(db, id: rows.destinationWing),
                  // R2-N1 (ruled quiet-obsolete): the note's own stored wing
                  // must be live too — dead, it resolves to Home and would
                  // pass `sameEffectiveWing` against a HOME stood-in wing,
                  // replaying an entry her door had moved on. `wingIsLive('')`
                  // is true, so a genuine Home note stands untouched.
                  try Queries.wingIsLive(db, id: note.wingId),
                  try sameEffectiveWing(db, note.wingId, rows.destinationWing),
                  try Queries.wingIsLive(db, id: rows.sourceWing)
            else { return nil }
            try refuseIfWingMoveChangedSince(
                db, rows.postID, leaving: rows.destinationWing,
                knownApplications: Set(rows.addedApplications), knownMemberships: [])
            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            for application in rows.addedApplications {
                try db.execute(
                    sql: "UPDATE \(application.table) SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                    arguments: [stamp, application.id])
            }
            for application in rows.removedApplications {
                try reviveWingMoveApplication(db, application, postID: rows.postID, stamp: forwardStamp)
            }
            note.wingId = rows.sourceWing
            note.updatedAt = now
            try note.update(db)
            try rehomeVersions(
                db, rows.versionWings.map { ($0.key, from: rows.destinationWing, to: $0.value) }, now: now)
            for rowID in rows.severed {
                try reviveWingMoveMembership(db, rowID, note: note, stamp: forwardStamp)
            }
            try enforceOwnershipAfterRevival(db, postIDs: [rows.postID], now: now)
            return stamp
        }
    }

    /// **The redo — the same move again, on the same rows.** Returns the stamp
    /// it severed and re-pointed on (the next undo revives exactly those), or
    /// nil when OBSOLETE (the note gone, no longer in the wing it came from,
    /// EITHER wing no longer live — F1 — or the note's own CURRENT wing dead —
    /// R2-N1, the inverse's rules mirrored). Her door's refusal is re-run first: a
    /// severed row that is a live MEMBER of a sealed or finished book refuses
    /// (`readingSealed` / `lockedReading` — reopen or unseal, then redo),
    /// keeping the entry. Anything the note joined or was tagged with in its
    /// wing SINCE the undo refuses as the inverse does (`wingMoveChangedSince`).
    func reapplyMCPWingMove(_ rows: WingMoveRows, backwardStamp: String?) throws -> String? {
        try database.write { db in
            guard var note = try Container.fetchOne(db, key: rows.postID), note.deletedAt == nil,
                  // F1: both wings live, as the inverse requires (a dead
                  // source must not resolve to Home and replay). R2-N1: the
                  // note's own stored wing live too (the inverse's rule).
                  try Queries.wingIsLive(db, id: rows.sourceWing),
                  try Queries.wingIsLive(db, id: note.wingId),
                  try sameEffectiveWing(db, note.wingId, rows.sourceWing),
                  try Queries.wingIsLive(db, id: rows.destinationWing)
            else { return nil }
            var live: [ReadingPost] = []
            for rowID in rows.severed {
                guard let row = try ReadingPost.fetchOne(db, key: rowID), row.deletedAt == nil,
                      let reading = try Reading.fetchOne(db, key: row.readingId), reading.deletedAt == nil
                else { continue }
                if row.status == .member {
                    if reading.sealedAt != nil { throw OperationError.readingSealed(id: reading.id) }
                    if reading.locked { throw OperationError.lockedReading(id: reading.id) }
                }
                live.append(row)
            }
            try refuseIfWingMoveChangedSince(
                db, rows.postID, leaving: rows.sourceWing,
                knownApplications: Set(rows.removedApplications), knownMemberships: Set(rows.severed))
            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            for var row in live {
                row.deletedAt = now
                try row.update(db)
            }
            for application in rows.removedApplications {
                try db.execute(
                    sql: "UPDATE \(application.table) SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                    arguments: [stamp, application.id])
            }
            if let backwardStamp {
                for application in rows.addedApplications {
                    try reviveWingMoveApplication(db, application, postID: rows.postID, stamp: backwardStamp)
                }
            }
            note.wingId = rows.destinationWing
            note.updatedAt = now
            try note.update(db)
            try rehomeVersions(
                db, rows.versionWings.map { ($0.key, from: $0.value, to: rows.destinationWing) }, now: now)
            return stamp
        }
    }

    // MARK: - The replays' pieces

    /// The divergence check (P-13nc-U6-3): a live membership row of the note
    /// that is not one of the entry's own, or a live application of a live tag
    /// of the wing the note would LEAVE that is not one of the entry's own
    /// (the note's or a placed block's), refuses the replay.
    ///
    /// `leaving` MUST name a LIVE wing — the replays' guards ensure it (F1 +
    /// R2-N1: both of the entry's wings AND the note's current wing live,
    /// else obsolete). A dead id here would
    /// scope `wingScope` to rows that no longer exist as read (the note's
    /// effective wing is Home then) and the check would miss the very
    /// vocabulary it protects.
    private func refuseIfWingMoveChangedSince(
        _ db: Database, _ postID: String, leaving wingID: String,
        knownApplications: Set<WingMoveApplication>, knownMemberships: Set<String>
    ) throws {
        if try wingMoveMemberships(db, postID: postID).contains(where: { !knownMemberships.contains($0.row.id) }) {
            throw OperationError.wingMoveChangedSince(postID: postID)
        }
        let scope = Queries.wingScope(column: "t.wing_id", wingID: wingID)
        let leavingVocabulary = try String.fetchAll(
            db,
            sql: """
                SELECT 'post_tag' || char(31) || pt.id FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL AND \(scope.sql)
                UNION ALL
                SELECT 'block_tag' || char(31) || bt.id FROM container_block cb
                JOIN block_tag bt ON bt.block_id = cb.block_id AND bt.deleted_at IS NULL
                JOIN tag t ON t.id = bt.tag_id AND t.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND \(scope.sql)
                """,
            arguments: StatementArguments([postID] + scope.arguments + [postID] + scope.arguments))
        for key in leavingVocabulary {
            let parts = key.split(separator: "\u{1F}", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            if !knownApplications.contains(WingMoveApplication(table: parts[0], id: parts[1])) {
                throw OperationError.wingMoveChangedSince(postID: postID)
            }
        }
    }

    /// Revive one application the move (or a replay) tombstoned on `stamp` —
    /// only while its tag is live, its target is still this note (or a block
    /// still placed in it), and no live twin holds the pair (the live-unique
    /// index). A row that diverged stays as it is (quiet).
    private func reviveWingMoveApplication(
        _ db: Database, _ application: WingMoveApplication, postID: String, stamp: String
    ) throws {
        let (column, targetJoin): (String, String) = application.table == "post_tag"
            ? ("post_id", "a.post_id = :post")
            : ("block_id", """
                EXISTS (SELECT 1 FROM container_block cb WHERE cb.block_id = a.block_id
                        AND cb.container_id = :post AND cb.deleted_at IS NULL)
                """)
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT a.tag_id AS tag_id, a.\(column) AS target FROM \(application.table) a
                JOIN tag t ON t.id = a.tag_id AND t.deleted_at IS NULL
                WHERE a.id = :id AND a.deleted_at = :stamp AND \(targetJoin)
                """,
            arguments: ["id": application.id, "stamp": stamp, "post": postID])
        else { return }
        guard try liveApplication(
            db, table: application.table, tagID: row["tag_id"], targetColumn: column,
            targetID: row["target"]) == nil
        else { return }
        try db.execute(
            sql: "UPDATE \(application.table) SET deleted_at = NULL WHERE id = ?", arguments: [application.id])
        try voidPurgeIntents(db, table: application.table, rowID: application.id)
    }

    /// Revive one membership row the move (or a redo) severed on `stamp`, under
    /// the revival rules `restoreContainer` reads (see the inverse's doc).
    private func reviveWingMoveMembership(
        _ db: Database, _ rowID: String, note: Container, stamp: String
    ) throws {
        guard var row = try ReadingPost.fetchOne(
                db, sql: "SELECT * FROM reading_post WHERE id = ? AND deleted_at = ?", arguments: [rowID, stamp]),
              let reading = try Reading.fetchOne(db, key: row.readingId), reading.deletedAt == nil,
              reading.sealedAt == nil || note.locked,
              try Queries.membershipRevivalStaysInOneWing(db, postID: note.id, readingID: reading.id),
              try livePairRow(db, postID: note.id, readingID: reading.id) == nil
        else { return }
        row.deletedAt = nil
        try row.update(db)
        try voidPurgeIntents(db, table: "reading_post", rowID: rowID)
    }

    /// The note's saved versions re-homed — each only while still live and
    /// still standing in its `from` wing (a version re-homed since stays put).
    private func rehomeVersions(
        _ db: Database, _ moves: [(id: String, from: String, to: String)], now: Date
    ) throws {
        for move in moves.sorted(by: { $0.id < $1.id }) {
            guard var version = try Container.fetchOne(db, key: move.id), version.deletedAt == nil,
                  try sameEffectiveWing(db, version.wingId, move.from)
            else { continue }
            version.wingId = move.to
            version.updatedAt = now
            try version.update(db)
        }
    }
}
