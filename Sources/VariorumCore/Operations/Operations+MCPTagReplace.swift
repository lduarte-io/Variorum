import Dependencies
import Foundation
import GRDB

// VX-812 — `replace_tag`'s ITEM (the VX-809 run, batch 3; her R-812: "a
// replace-tag-A-with-B across a wing … 'across a wing' means across the client's
// REACH in that wing — the sweep acts on and counts only what the client can
// see"). The SWEEP (which notes, in what order, under which grant) is the wire's
// (`MCPWriteTools+TagReplace`): it enumerates the wearers of A it may EDIT and
// runs THIS act once per note — each its own operation, its own transaction,
// its own client-named ⌥⌘Z entry (R-812's "each item still its own operation").
//
// One item = her un-tag of A and her tag of B on ONE note, in ONE transaction:
// A's application tombstoned (`remove_tag`'s row — a NON-EVENT for intake, §19:
// a book A brought the note into keeps it), then B adopted-else-minted by path in
// the note's wing (R-13ia-1's one rule) and applied through the ONE application
// road (`insertPostTag` — every living book hears B, as when she tags; a wire
// hand's would-be seat where membership fences bells, A-809-11). A note already
// wearing B keeps that application — the item still lands (A is off).
extension Operations {
    /// What one replacement did.
    public struct MCPTagReplacement: Equatable, Sendable {
        /// A's application the act tombstoned.
        public let removedApplicationID: String
        /// B's application the act inserted — nil when the note already wore B.
        public let appliedApplicationID: String?
        public let fromTagID: String
        public let toTagID: String
        /// B's path as stored.
        public let toPath: String
    }

    /// **One note's A → B** — the caller's guard FIRST inside the act's own
    /// transaction (the edit rung's re-decision, any once grant stamped there —
    /// AF-10 (a)), then: the note live; `fromTagID` a live tag the note wears
    /// (`tagNotApplied` otherwise — the sweep read it, but her un-tag may have
    /// landed since); `toPath` read by `TagPath.segments` (`invalidTagName` for
    /// none) and resolved in the NOTE's wing; A off on the act's one stamp, B on.
    /// A `toPath` naming A itself refuses `invalidTagName` (the wire refuses it
    /// at the parse first) — never a silent no-op.
    ///
    /// ONE undo entry, `undoLabel`, each half compare-and-set PER PART (the
    /// `set_book_rule` parts' precedent — VX-246 U2's quiet-half rule per row):
    /// the inverse revives A's application while it is dead on the act's stamp
    /// (and no live twin stands) and tombstones B's application the act
    /// inserted while it is still live; the redo does the reverse on the stamps
    /// its partner wrote. A half that writes nothing retires the entry.
    @discardableResult
    public func replaceTagForClient(
        _ fromTagID: String, with toPath: String, onNote postID: String, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTagReplacement {
        let (replacement, stamp): (MCPTagReplacement, String) = try database.write { db in
            try guardian?(db)
            let post = try livePost(db, postID)
            let from = try liveTag(db, fromTagID)
            guard let removed = try liveApplication(
                db, table: "post_tag", tagID: from.id, targetColumn: "post_id", targetID: postID)
            else { throw OperationError.tagNotApplied(tagID: from.id, targetID: postID) }
            let segments = TagPath.segments(toPath)
            guard !segments.isEmpty else { throw OperationError.invalidTagName(name: toPath) }
            let wing = try Queries.wingIsLive(db, id: post.wingId) ? post.wingId : ""
            var adoption = TagAdoption(wing: wing)
            guard let to = try adoptPath(db, segments.joined(separator: "/"), &adoption), to.id != from.id
            else { throw OperationError.invalidTagName(name: toPath) }
            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            try db.execute(sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ?", arguments: [stamp, removed])
            var applied: String?
            if try liveApplication(db, table: "post_tag", tagID: to.id, targetColumn: "post_id", targetID: postID) == nil {
                applied = try insertPostTag(db, tagID: to.id, postID: postID, now: now).id
            }
            return (MCPTagReplacement(
                removedApplicationID: removed, appliedApplicationID: applied,
                fromTagID: from.id, toTagID: to.id, toPath: to.path), stamp)
        }
        let removed = replacement.removedApplicationID
        let applied = replacement.appliedApplicationID
        // The stamps each half hands its partner: A's tombstone (the act's,
        // then each redo's), B's tombstone (each undo's).
        let removedOn = LockIsolated<String?>(stamp)
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                try ops.database.write { db in
                    let revived = try ops.reviveTagApplication(db, removed, deadOn: removedOn.value)
                    let unapplied = try applied.flatMap { try ops.tombstoneTagApplication(db, $0) }
                    if let unapplied { undoneOn.setValue(unapplied) }
                    return revived || unapplied != nil
                }
            },
            redo: { ops in
                try ops.database.write { db in
                    let reRemoved = try ops.tombstoneTagApplication(db, removed)
                    if let reRemoved { removedOn.setValue(reRemoved) }
                    let reApplied = try applied.map { try ops.reviveTagApplication(db, $0, deadOn: undoneOn.value) } ?? false
                    return reRemoved != nil || reApplied
                }
            })
        return replacement
    }

    /// Tombstones the live application; returns the stamp it wrote — nil when
    /// it was already dead (a quiet part). In the caller's transaction.
    func tombstoneTagApplication(_ db: Database, _ applicationID: String) throws -> String? {
        let stamp = DateFormatter.variorumISO8601.string(from: date.now)
        try db.execute(
            sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
            arguments: [stamp, applicationID])
        return db.changesCount > 0 ? stamp : nil
    }

    /// Revives the application only while it is dead on `stamp` — the stamp
    /// its partner half wrote — its tag and note live, and no live twin stands
    /// (`uq_post_tag_live`: a re-application by hand since keeps the pair). In
    /// the caller's transaction; returns whether it did (`reapplyAppliedTag`'s
    /// rule).
    func reviveTagApplication(_ db: Database, _ applicationID: String, deadOn stamp: String?) throws -> Bool {
        guard let stamp,
              let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT pt.tag_id, pt.post_id FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    JOIN container c ON c.id = pt.post_id AND c.deleted_at IS NULL
                    WHERE pt.id = ? AND pt.deleted_at = ?
                    """,
                arguments: [applicationID, stamp]),
              try liveApplication(db, table: "post_tag", tagID: row["tag_id"],
                                  targetColumn: "post_id", targetID: row["post_id"]) == nil
        else { return false }
        try db.execute(sql: "UPDATE post_tag SET deleted_at = NULL WHERE id = ?", arguments: [applicationID])
        try voidPurgeIntents(db, table: "post_tag", rowID: applicationID)
        return true
    }
}
