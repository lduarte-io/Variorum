import Dependencies
import Foundation
import GRDB

// BOOK ARCHIVE (13i-e U1 — her kickoff rulings R-13ie-1…4; the binding record
// is the 13i-e plan's U1 RECORD, `notes/plans/phase-13i-e-daily-journal.md`).
//
// Her words, R-13ie-1: *"a book is a set of rules + ordering now so it makes
// sense to archive it - the only question is what happens to the notes
// within."* So `reading.archived_at` (v1_21) is the container-archive class —
// KEPT, out of view: out of the Bookcase, listed under Archived, never a step
// toward deletion ("you do want to keep it forever"). Three doors:
//
// - `archiveReading` — a book OR a gathering (R-13ie-3); a PLAIN book archives
//   ALONE, its notes stay live everywhere they already are (R-13ie-2).
// - `archiveReadingWithNotes` — the OWNED book's second choice: the book and
//   its member notes on ONE stamp (the delete-with-notes shape, mirrored —
//   "Lesson 8's ruled delete shape, mirrored").
// - `unarchiveReading` — the exact-stamp members come back whole, then the
//   flag clears, then a LIVING book's RESUME CATCH-UP (bells, never quiet
//   seats — the unseal / un-finish road).
//
// While archived, AUTO-INGESTION pauses (`IntakeDecision.intakeRuns` — the one
// table) and a gathering's assembly answers EMPTY everywhere its rule is
// consulted; the EXPLICIT add doors stay open (her amendment to R-13ie-4 — no
// `readingArchived` refusal exists anywhere). Finished, Sealed, Owned and the
// daily marker are orthogonal states. No structural-undo entry anywhere in the
// family: the door is the recovery (the Trash-class rule).
extension Operations {
    /// **ARCHIVE A BOOK OR A GATHERING** — `archived_at = now`, one row write,
    /// nothing else moves: a plain book's notes stay live wherever they are
    /// (R-13ie-2), pending arrivals KEEP WAITING (archive is reversible; the
    /// finish's dismissal deliberately not mirrored — the plan's edge), a
    /// gathering stops assembling until unarchived (R-13ie-3). The daily
    /// Journal archives like any book — that is its road, since it can never
    /// be deleted (the sitting record §10).
    ///
    /// Refuses a dead or missing reading (`readingNotFound`) and one already
    /// archived (`readingAlreadyArchived` — PROVISIONAL P-13ie-U1-1).
    public func archiveReading(_ id: String) throws {
        try database.write { db in
            _ = try archiveReadingRow(db, id)
        }
    }

    /// `archiveReading`'s row work inside a caller's transaction (VX-184 U5 —
    /// `archive_book`, and its undo's redo). Byte-identical behaviour.
    /// Returns the archive's stamp.
    @discardableResult
    func archiveReadingRow(_ db: Database, _ id: String) throws -> Date {
            var reading = try liveReading(db, id)
            guard reading.archivedAt == nil else {
                throw OperationError.readingAlreadyArchived(id: id)
            }
            let now = date.now
            reading.archivedAt = now
            reading.updatedAt = now
            try reading.update(db)
            return now
    }

    /// **"Archive the book and its N notes"** — the OWNED book's second choice
    /// (R-13ie-2; `deleteReadingWithNotes`' shape, mirrored). ONE clock read
    /// for the whole act: every live MEMBER note of the book that is not
    /// already archived gets `archived_at` on the SAME stamp as the book, so
    /// `unarchiveReading` returns exactly those notes whole.
    ///
    /// - A note archived on its own BEFORE this act keeps its own stamp — it
    ///   is not re-stamped, so the book's unarchive leaves it archived (the
    ///   plan's edge — `restoreContainer`'s exact-stamp letter).
    /// - Never a tombstone; never a saved VERSION (versions are born archived
    ///   by the classifier, so the not-already-archived fence leaves them
    ///   untouched — re-stamping one would break `archived_at == created_at`).
    /// - An arrival's note is not a member and is never taken.
    /// - A SEALED member archives too (AppSpec §9's seal letter: "the post
    ///   itself may still be archived").
    ///
    /// The DOOR offers this only on an OWNED book (U2); the op refuses a
    /// gathering (`wrongReadingKind` — it holds no notes) and nothing else
    /// (PROVISIONAL P-13ie-U1-2 — the 13i-c §6 letter, mirrored). Refuses an
    /// already-archived book (`readingAlreadyArchived`). Returns the notes it
    /// archived, in the book's order. Registers nothing and leaves the redo
    /// future alone (`archiveContainer`'s class — archive removes no content;
    /// P-13ie-U1-4).
    @discardableResult
    public func archiveReadingWithNotes(_ id: String) throws -> [String] {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            guard reading.archivedAt == nil else {
                throw OperationError.readingAlreadyArchived(id: id)
            }
            let now = date.now
            let postIDs = try String.fetchAll(
                db,
                sql: """
                    SELECT rp.post_id \(Queries.archiveWithNotesSource)
                    ORDER BY rp.position, rp.id
                    """,
                arguments: [id])
            for postID in postIDs {
                guard var note = try Container.fetchOne(db, key: postID) else { continue }
                note.archivedAt = now
                note.updatedAt = now
                try note.update(db)
            }
            reading.archivedAt = now
            reading.updatedAt = now
            try reading.update(db)
            return postIDs
        }
    }

    /// **UNARCHIVE** — the book comes back WHOLE and, if it is a LIVING book,
    /// RESUMES its auto-ingestion with a catch-up (R-13ie-4: "Unarchive
    /// RESUMES auto-ingestion with the catch-up — the unseal precedent").
    /// Returns the notes it brought back, in the book's order. Refuses a dead
    /// reading and one that is not archived (`readingNotArchived` —
    /// P-13ie-U1-1). No undo entry — Archive is the door back.
    @discardableResult
    public func unarchiveReading(_ id: String) throws -> [String] {
        try database.write { db in
            try unarchiveReading(db, id: id, now: date.now)
        }
    }

    /// The `unarchiveReading` body at db level — shared with
    /// `shelveInDailyJournalBook`'s COMES-BACK (the daily Journal "returns when
    /// a day arrives": the shelving's own transaction runs exactly this before
    /// it files the day's entry). In order:
    ///
    /// 1. **the notes archived WITH the book** — live MEMBER notes whose
    ///    `archived_at` equals the book's stamp — come back (the exact-stamp
    ///    pattern: a note archived on its own carries a different stamp and
    ///    stays archived; a note that LEFT the book while it was archived is
    ///    no longer a member and stays archived — "rows whose story diverged
    ///    stay as they are", P-13ie-U1-3);
    /// 2. **the flag clears**;
    /// 3. **the RESUME CATCH-UP** — `intakeSweep(.catchUp)`, which runs only
    ///    when the book's intake runs (a live BOOK, a readable rule, not
    ///    finished — and now unarchived): the gap's matches WAIT AT ARRIVALS
    ///    (gap = judgment), never quiet seats. A gathering needs nothing — its
    ///    assembly answers again at read.
    @discardableResult
    func unarchiveReading(_ db: Database, id: String, now: Date) throws -> [String] {
        var reading = try liveReading(db, id)
        guard let archivedAt = reading.archivedAt else {
            throw OperationError.readingNotArchived(id: id)
        }
        let stamp = DateFormatter.variorumISO8601.string(from: archivedAt)
        let returned = try String.fetchAll(
            db,
            sql: """
                SELECT rp.post_id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                 AND c.kind = 'post' AND c.archived_at = ?
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.position, rp.id
                """,
            arguments: [stamp, id])
        for postID in returned {
            guard var note = try Container.fetchOne(db, key: postID) else { continue }
            note.archivedAt = nil
            note.updatedAt = now
            try note.update(db)
        }
        reading.archivedAt = nil
        reading.updatedAt = now
        try reading.update(db)
        try intakeSweep(db, book: reading, occasion: .catchUp, now: now)
        return returned
    }
}

extension Queries {
    /// **THE ARCHIVE-WITH-NOTES SET, written ONCE** (13i-e — the 13i-c
    /// ladder's MAJOR discipline: a confirm's N and its act's rows are one set
    /// by construction): the book's live MEMBER notes that are not already
    /// archived. Read by `archiveReadingWithNotes` (the act) and
    /// `archiveWithNotesCount` (the owned two-choice confirm's "the book and
    /// its N notes"). One placeholder: the reading's id.
    static let archiveWithNotesSource = """
        FROM reading_post rp
        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
         AND c.kind = 'post' AND c.archived_at IS NULL
        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
        """

    /// **The archive confirm's N** — exactly the notes `archiveReadingWithNotes`
    /// will archive (a member archived on its own already is not counted: it
    /// keeps its own stamp and is not taken). Distinct from
    /// `liveMemberNoteCount` (the DELETE confirm's N, which counts archived
    /// members because the delete takes them). ∝ the book's own rows.
    public static func archiveWithNotesCount(_ db: Database, readingID: String) throws -> Int {
        try Int.fetchOne(
            db, sql: "SELECT COUNT(*) \(archiveWithNotesSource)", arguments: [readingID]) ?? 0
    }
}
