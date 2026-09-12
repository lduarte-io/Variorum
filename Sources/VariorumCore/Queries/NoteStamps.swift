import Foundation
import GRDB

// The note's two TIME facts, as one read (18d batch 1 — the sidebar's note
// box, her U-10; §5.4's fact line *"edited Sep 4 · saved Sep 2"*).
//
// Why a query and not two: the box shows the pair or neither, and the pair is
// one indexed read over the note's own rows — the container row it already
// owns, and the newest savepoint across the note's live variants. Cost ∝ this
// note's own blocks and takes, never the corpus (P1); the display's day
// derivation is the caller's (a stamp is data, a day is a face).
extension Queries {
    /// The note's two stamps for a facts line.
    ///
    /// `editedAt` is `last_touched_at` falling back to `created_at` — the
    /// shelf's and the Library panel's own COALESCE, so three surfaces cannot
    /// disagree about when a note was last worked on. `savedAt` is the newest
    /// `commit_point.created_at` across the note's LIVE blocks' LIVE variants
    /// — deliberately every take, not just the rendered one: a savepoint
    /// written on a take she is no longer looking at is still a moment this
    /// note has.
    public struct NoteStamps: Equatable, Sendable {
        /// The mint — `container.created_at`, NOT NULL by schema.
        ///
        /// **Added at 18h batch 1** (her ruling R-Q7): the masthead's quiet
        /// stamp flips *edited …* ↔ *created …* on a click, so the note's
        /// created stamp is a THIRD fact of the same one read rather than a
        /// second query beside it. 18d's two fields are byte-unchanged and
        /// its pins ride untouched.
        public let createdAt: Date
        /// Any keystroke's stamp, falling back to the mint (never nil for a
        /// live container — `created_at` is NOT NULL).
        public let editedAt: Date
        /// The newest savepoint under the note; nil ⇒ nothing has ever been
        /// committed here (a fresh note), which the face says by omission.
        public let savedAt: Date?

        public init(createdAt: Date, editedAt: Date, savedAt: Date?) {
            self.createdAt = createdAt
            self.editedAt = editedAt
            self.savedAt = savedAt
        }
    }

    /// nil ⇒ the container is missing or tombstoned (the `containerHeader`
    /// convention: read sides tolerate a gone row, never crash).
    public static func noteStamps(_ db: Database, postID: String) throws -> NoteStamps? {
        guard let container = try Container.fetchOne(db, key: postID),
              container.deletedAt == nil
        else { return nil }
        let saved = try Date.fetchOne(
            db,
            sql: """
                SELECT MAX(cp.created_at)
                FROM commit_point cp
                JOIN variant v ON v.id = cp.variant_id AND v.deleted_at IS NULL
                JOIN block b ON b.id = v.block_id AND b.deleted_at IS NULL
                JOIN container_block cb
                  ON cb.block_id = b.id AND cb.deleted_at IS NULL
                WHERE cb.container_id = ?
                """,
            arguments: [postID])
        return NoteStamps(
            createdAt: container.createdAt,
            editedAt: container.lastTouchedAt ?? container.createdAt, savedAt: saved)
    }
}
