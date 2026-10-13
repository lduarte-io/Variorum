import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's EDIT PARITY ACROSS THE LIBRARY (VX-184 U5 — VX-196; her ruling
// R-VX184-1 at the pre-run sitting, 2026-10-12: "We defined Edit as 'as capable
// as you at the keyboard', we need to make that true" — her picks: a book's
// name, finish, archive and delete; its membership and order; its chapters; a
// note's delete and archive). Fourteen acts on the EDIT rung, each one of her
// own doors' row work, run through the SAME extracted body her door calls
// (`finishReadingRows`, `reopenReadingRows`, `archiveReadingRow`,
// `unarchiveReading(db:)`, `deleteReadingRow`, `restoreReadingRows`,
// `removeMembershipRow`, `reorderMembershipRow`, `renameSectionRow`,
// `deleteSectionRow`, `restoreSectionRow`, `reorderSectionRow`,
// `tombstoneNoteFamily`, `restoreNoteFamily`, `archiveContainerRow`,
// `unarchiveContainerRow`), with the server's decision handed in as a
// `WriteGuard` run FIRST inside the act's own write transaction (AF-10 (a)).
//
// THE UNDO STORY (the run record's U5 call 1, PROVISIONAL P-VX196-1): every act
// registers exactly ONE client-named entry — canon §12's "every write … ONE
// client-named undo entry", carried to acts her own doors leave off the stack
// (the archive family, the chapter family, finish/reopen, the Trash acts) as
// `move_note_to_wing` already wraps her undo-less wing move. Inverses and redos
// are exact-row from do-time images; the INVERSES are keyed on the act's own
// STAMPS, and their divergence is QUIET (the world moved past the entry — she
// put it back already); a finished or sealed book THROWS and keeps the entry
// (resolvable). A VALUE restore (a name, a place) is COMPARE-AND-SET: it writes
// only while the row still reads the value its act left there, so the UNDO
// never overwrites a name or place she gave it since through her own
// undo-less door — checked FIRST, before any refusal (VX-184 ladder round 1,
// the undo-overwrite class). THE REDOS DO NOT YET KEEP THAT PROMISE (VX-184
// ladder round 2, 2026-10-13): after she has put a row BACK herself (her
// reopen or finish, her unarchive, her Put back, her chapter restore, the old
// name or place again), ⌥⌘Z is quiet yet still moves the entry onto the redo
// stack (`UndoStack.undo` pops any inverse that does not throw), and the redos
// here — `refinishBook`, `reopenBookAgain`, `rearchiveBook`, `redeleteBook`,
// `redeleteChapter`, `redeleteNote`, `restoreNoteArchived`, each
// compare-and-set restorer — check only for the pre-act state her reversal
// produced, so ⇧⌥⌘Z re-applies the client's act over hers. (Keyed redos are
// safe: `unarchive_book`'s runs only on the archive's original stamp; her
// re-add of a removed note mints a new row, so `reremoveMembership` is quiet.)
// VX-276 owns the fix: the redo keyed on what its inverse wrote.
//
// PRIVATE, SEAL and OWN stay HERS ALONE (R-VX184-2): nothing here writes
// `ai_private_at`, `sealed_at`, a note's seal or `owned`, and neither
// `deleteReadingWithNotes` nor `archiveReadingWithNotes` is ever called.
//
// These ops decide nothing about clients — who may act is the server's
// per-call rule (`MCPWriteTools+LibraryEdits`).
extension Operations {
    /// The refusal only her DOORS make — mirrored at the act (AF-11 F-1:
    /// refuse exactly where her door refuses, never more; the wire words it).
    public enum MCPLibraryRefusal: Error, Equatable, Sendable {
        /// `move_note_in_book` on a book that sorts itself: her Book Panel and
        /// Outline place a note by hand only in MANUAL order
        /// (`BookPanelCopy.needsManualOrder`).
        case bookNotInManualOrder(bookID: String)
    }

    // MARK: - THE BOOK's NAME

    /// What `renameBookForClient` did.
    public struct MCPBookRename: Equatable, Sendable {
        public let bookID: String
        public let name: String
        public let changed: Bool
    }

    /// **`rename_book`'s act — her rename doors**: E13's guard first, INSIDE
    /// the act (`requireBookNameFree(excluding:)` — the name a live,
    /// un-archived book wears, case-folded, refuses `duplicateBookName`), then
    /// the name, trimmed (a blank one reads as the placeholder — `createBook`'s
    /// MCP precedent; the wire refuses a blank name first). A finished or
    /// sealed book renames (her op's posture). The same name writes nothing.
    /// ONE entry restoring the previous name exactly while the book still wears
    /// the act's name (no E13 re-check — the Put-back tolerance).
    @discardableResult
    public func renameBookForClient(
        _ readingID: String, name: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookRename {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newName = trimmed.isEmpty ? DisplayTitle.placeholder : trimmed
        let previous: String? = try database.write { db in
            try guardian?(db)
            var reading = try liveReading(db, readingID)
            guard reading.name != newName else { return nil }
            try requireBookNameFree(db, newName, excluding: readingID)
            let old = reading.name
            reading.name = newName
            reading.updatedAt = date.now
            try reading.update(db)
            return old
        }
        guard let previous else { return MCPBookRename(bookID: readingID, name: newName, changed: false) }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreBookName(readingID, from: newName, to: previous) },
            redo: { try $0.restoreBookName(readingID, from: previous, to: newName) })
        return MCPBookRename(bookID: readingID, name: newName, changed: true)
    }

    /// Both halves of the name entry, COMPARE-AND-SET (VX-184 ladder round 1 —
    /// the undo-overwrite class): `to` is written only while the book is live
    /// and still wears `from`. A name she gave it since (her rename door
    /// registers no entry) is hers — the entry is quiet, and still pops.
    func restoreBookName(_ readingID: String, from: String, to name: String) throws {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.name == from
            else { return }
            reading.name = name
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    // MARK: - FINISH / REOPEN

    /// What `setBookFinishedForClient` did.
    public struct MCPBookFinish: Equatable, Sendable {
        public let bookID: String
        public let finished: Bool
        public let changed: Bool
    }

    /// **`finish_book` / `reopen_book`'s act — her `lockReading` /
    /// `unlockReading`** (`finishReadingRows` / `reopenReadingRows`): a
    /// gathering refuses `wrongReadingKind` (the kind is the answer — her
    /// op's order); a SEALED book is finished already (no-op) and refuses a
    /// reopen (`readingSealed` — Unseal is hers alone, R-VX184-2). The state
    /// already as asked writes NOTHING (`changed: false`; her op would
    /// re-write `updated_at`). ONE entry (P-VX196-4):
    /// - a FINISH's undo revives exactly the arrival rows the finish
    ///   dismissed on its stamp (each only while its pair has no live row and
    ///   its note lives), then her reopen body (the catch-up) — what waited at
    ///   the door waits again; the redo finishes again on a fresh stamp;
    /// - a REOPEN's undo is her finish body again — it dismisses whatever
    ///   waits, the reopen's catch-up bells included (decided: there is no
    ///   row-free state to return to under S2); the redo reopens again.
    @discardableResult
    public func setBookFinishedForClient(
        _ readingID: String, finished: Bool, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookFinish {
        let landed: (changed: Bool, stamp: Date?) = try database.write { db in
            try guardian?(db)
            let reading = try liveReading(db, readingID)
            if finished {
                guard reading.kind == .book else {
                    throw OperationError.wrongReadingKind(id: readingID, expected: .book)
                }
                guard !reading.locked, let stamp = try finishReadingRows(db, readingID) else { return (false, nil) }
                return (true, stamp)
            }
            guard reading.sealedAt == nil else { throw OperationError.readingSealed(id: readingID) }
            guard reading.locked else { return (false, nil) }
            try reopenReadingRows(db, readingID)
            return (true, nil)
        }
        let result = MCPBookFinish(bookID: readingID, finished: finished, changed: landed.changed)
        guard landed.changed else { return result }
        if finished, let stamp = landed.stamp {
            let finishedOn = LockIsolated(DateFormatter.variorumISO8601.string(from: stamp))
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.revertFinishedBook(readingID, finishedOn: finishedOn.value) },
                redo: { ops in
                    if let stamp = try ops.refinishBook(readingID) { finishedOn.setValue(stamp) }
                })
        } else {
            undoStack?.register(
                label: undoLabel,
                inverse: { _ = try $0.refinishBook(readingID) },
                redo: { try $0.reopenBookAgain(readingID) })
        }
        return result
    }

    /// A finish's inverse: quiet unless the book is still finished; a book
    /// SEALED since refuses and keeps the entry (Unseal is hers).
    func revertFinishedBook(_ readingID: String, finishedOn stamp: String) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.locked
            else { return }
            guard reading.sealedAt == nil else { throw OperationError.readingSealed(id: readingID) }
            let dismissed = try ReadingPost.fetchAll(
                db,
                sql: """
                    SELECT * FROM reading_post
                    WHERE reading_id = ? AND status = 'arrival' AND deleted_at = ?
                    ORDER BY position, id
                    """,
                arguments: [readingID, stamp])
            for var row in dismissed {
                guard try Container.fetchOne(db, key: row.postId)?.deletedAt == nil,
                      try livePairRow(db, postID: row.postId, readingID: readingID) == nil
                else { continue }
                row.deletedAt = nil
                try row.update(db)
            }
            try reopenReadingRows(db, readingID)
        }
    }

    /// Her finish body again (a finish's redo; a reopen's inverse) — quiet
    /// when the book is gone or already finished. Returns the stamp it wrote.
    func refinishBook(_ readingID: String) throws -> String? {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  !reading.locked, let stamp = try finishReadingRows(db, readingID)
            else { return nil }
            return DateFormatter.variorumISO8601.string(from: stamp)
        }
    }

    /// A reopen's redo: her reopen body again — quiet when the book is gone
    /// or already open; a book SEALED since refuses and keeps the entry.
    func reopenBookAgain(_ readingID: String) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.locked
            else { return }
            try reopenReadingRows(db, readingID)
        }
    }

    // MARK: - ARCHIVE / UNARCHIVE A BOOK

    /// **`archive_book`'s act — her `archiveReading`** (`archiveReadingRow`:
    /// one row write — a plain book's notes stay live wherever they are, an
    /// OWNED book's stay its members, pending arrivals keep waiting; already
    /// archived refuses `readingAlreadyArchived`). Her owned book's SECOND
    /// choice (`archiveReadingWithNotes`) is hers alone (R-VX184-2) — this is
    /// her confirm's first, "book only" (P-VX196-3). ONE entry: her UNARCHIVE
    /// body while the book still wears the act's stamp (the catch-up bells
    /// what arrived while intake paused), the redo archiving it again.
    @discardableResult
    public func archiveBookForClient(
        _ readingID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Date {
        let stamp: Date = try database.write { db in
            try guardian?(db)
            return try archiveReadingRow(db, readingID)
        }
        let archivedOn = LockIsolated(DateFormatter.variorumISO8601.string(from: stamp))
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertArchivedBook(readingID, archivedOn: archivedOn.value) },
            redo: { ops in
                if let stamp = try ops.rearchiveBook(readingID) { archivedOn.setValue(stamp) }
            })
        return stamp
    }

    /// An archive's inverse: her unarchive body, only while the book wears
    /// the archive's exact stamp (quiet otherwise).
    func revertArchivedBook(_ readingID: String, archivedOn stamp: String) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.archivedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp
            else { return }
            _ = try unarchiveReading(db, id: readingID, now: date.now)
        }
    }

    /// An archive's redo: her archive body again, quiet when the book is gone
    /// or already archived. Returns the stamp it wrote.
    func rearchiveBook(_ readingID: String) throws -> String? {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.archivedAt == nil
            else { return nil }
            return DateFormatter.variorumISO8601.string(from: try archiveReadingRow(db, readingID))
        }
    }

    /// What `unarchiveBookForClient` did.
    public struct MCPBookUnarchive: Equatable, Sendable {
        public let bookID: String
        /// The notes that came back with it (archived WITH the book, on its
        /// stamp — her owned book's second archive choice).
        public let returned: [String]
    }

    /// **`unarchive_book`'s act — her `unarchiveReading`** (the exact-stamp
    /// members come back whole, the flag clears, a living book's catch-up
    /// bells; not archived refuses `readingNotArchived`). ONE entry: the book
    /// AND exactly the notes it brought back archived again on the ORIGINAL
    /// stamp (so her later unarchive returns them again — the exact-stamp
    /// letter); the bells stay (an archived book's arrivals keep waiting).
    /// The redo: her unarchive body while the book wears that stamp.
    @discardableResult
    public func unarchiveBookForClient(
        _ readingID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookUnarchive {
        let landed: (stamp: Date?, returned: [String]) = try database.write { db in
            try guardian?(db)
            let stamp = try liveReading(db, readingID).archivedAt
            return (stamp, try unarchiveReading(db, id: readingID, now: date.now))
        }
        if let stamp = landed.stamp {
            let returned = landed.returned
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreBookArchive(readingID, on: stamp, notes: returned) },
                redo: { try $0.revertArchivedBook(readingID, archivedOn: DateFormatter.variorumISO8601.string(from: stamp)) })
        }
        return MCPBookUnarchive(bookID: readingID, returned: landed.returned)
    }

    /// An unarchive's inverse: the book and the notes it returned, archived
    /// again on the original stamp — quiet when the book is gone or archived
    /// again since (a note archived or gone since keeps its own state).
    func restoreBookArchive(_ readingID: String, on stamp: Date, notes postIDs: [String]) throws {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  reading.archivedAt == nil
            else { return }
            let now = date.now
            for postID in postIDs {
                guard var note = try Container.fetchOne(db, key: postID), note.deletedAt == nil,
                      note.archivedAt == nil
                else { continue }
                note.archivedAt = stamp
                note.updatedAt = now
                try note.update(db)
            }
            reading.archivedAt = stamp
            reading.updatedAt = now
            try reading.update(db)
        }
    }

    // MARK: - DELETE A BOOK

    /// What `deleteBookForClient` did.
    public struct MCPBookDeletion: Equatable, Sendable {
        public let bookID: String
        /// The book OWNED its notes — they went back to the Pool, whole (her
        /// confirm's "book only"). A property of the book, never a count (an
        /// owned book's members can include notes the client cannot read).
        public let releasedNotes: Bool
    }

    /// **`delete_book`'s act — her `deleteReading`** (`deleteReadingRow`: THE
    /// DAILY JOURNAL refuses `dailyJournalCannotBeDeleted`, read inside this
    /// transaction — its road is archive; the cascade stamps its chapters and
    /// memberships; an OWNED book's notes are released to the Pool — her
    /// confirm's FIRST choice, P-VX196-3; `deleteReadingWithNotes` is hers
    /// alone). ONE entry: her restore door's body (`restoreReadingRows`:
    /// chapters and memberships on the exact stamp, the ownership pass, the
    /// catch-up) while the book still wears the act's stamp; the redo deletes
    /// it again (a book become THE daily Journal since refuses, keeps it).
    @discardableResult
    public func deleteBookForClient(
        _ readingID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookDeletion {
        let landed: (stamp: Date, owned: Bool) = try database.write { db in
            try guardian?(db)
            let owned = try liveReading(db, readingID).owned
            return (try deleteReadingRow(db, readingID), owned)
        }
        let deletedOn = LockIsolated(DateFormatter.variorumISO8601.string(from: landed.stamp))
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertDeletedBook(readingID, deletedOn: deletedOn.value) },
            redo: { ops in
                if let stamp = try ops.redeleteBook(readingID) { deletedOn.setValue(stamp) }
            })
        return MCPBookDeletion(bookID: readingID, releasedNotes: landed.owned)
    }

    /// A delete's inverse: her restore body, only while the book wears the
    /// delete's exact stamp (Put back since, or purged — quiet).
    func revertDeletedBook(_ readingID: String, deletedOn stamp: String) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID),
                  reading.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp
            else { return }
            try restoreReadingRows(db, id: readingID)
        }
    }

    /// A delete's redo: her delete body again — quiet when the book is gone.
    func redeleteBook(_ readingID: String) throws -> String? {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil else { return nil }
            return DateFormatter.variorumISO8601.string(from: try deleteReadingRow(db, readingID))
        }
    }

    // MARK: - MEMBERSHIP & ORDER

    /// What `removeNoteFromBookForClient` did.
    public struct MCPMembershipRemoval: Equatable, Sendable {
        public let noteID: String
        public let bookID: String
        /// An OWNED book: her door reads "Release" — the note goes back to the
        /// Pool, whole.
        public let released: Bool
        /// The note is in no live book now.
        public let bookless: Bool
    }

    /// **`remove_note_from_book`'s act — her `removePostFromReading`**
    /// (`removeMembershipRow`: a finished book refuses `lockedReading`; the
    /// MEMBER row tombstoned, member-class — decided; a note not in the book
    /// refuses `postNotInReading`). Registered under `releaseUndoLabel` on an
    /// OWNED book (her "Release from This Book"), else `removeUndoLabel`. ONE
    /// entry: the very row revived while it still wears the act's stamp (the
    /// book and note live, the same wing, no live twin; a finished book
    /// refuses and keeps it; the ownership revival pass), the redo removing it
    /// again.
    @discardableResult
    public func removeNoteFromBookForClient(
        _ postID: String, book readingID: String, removeUndoLabel: String, releaseUndoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPMembershipRemoval {
        let landed: (row: ReadingPost, bookless: Bool, owned: Bool) = try database.write { db in
            try guardian?(db)
            let owned = try liveReading(db, readingID).owned
            let removal = try removeMembershipRow(db, postID: postID, readingID: readingID)
            return (removal.row, removal.bookless, owned)
        }
        let rowID = landed.row.id
        let removedOn = LockIsolated(landed.row.deletedAt.map { DateFormatter.variorumISO8601.string(from: $0) } ?? "")
        undoStack?.register(
            label: landed.owned ? releaseUndoLabel : removeUndoLabel,
            inverse: { try $0.reviveRemovedMembership(rowID, removedOn: removedOn.value) },
            redo: { ops in
                if let stamp = try ops.reremoveMembership(rowID) { removedOn.setValue(stamp) }
            })
        return MCPMembershipRemoval(
            noteID: postID, bookID: readingID, released: landed.owned, bookless: landed.bookless)
    }

    /// A removal's inverse — see `removeNoteFromBookForClient`.
    func reviveRemovedMembership(_ rowID: String, removedOn stamp: String) throws {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: rowID), row.status == .member,
                  row.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp,
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil,
                  let note = try Container.fetchOne(db, key: row.postId), note.deletedAt == nil,
                  try sameEffectiveWing(db, note.wingId, book.wingId),
                  try livePairRow(db, postID: row.postId, readingID: row.readingId) == nil
            else { return }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            row.deletedAt = nil
            try row.update(db)
            try enforceOwnershipAfterRevival(db, postIDs: [row.postId], now: date.now)
        }
    }

    /// A removal's redo: the live member row tombstoned again — quiet when it
    /// is gone; a finished book refuses and keeps it. Returns the stamp.
    func reremoveMembership(_ rowID: String) throws -> String? {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: rowID), row.deletedAt == nil,
                  row.status == .member,
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil
            else { return nil }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            let now = date.now
            row.deletedAt = now
            try row.update(db)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }

    /// **`move_note_in_book`'s act — her `reorderReadingPost`**
    /// (`reorderMembershipRow`: a finished book refuses `lockedReading`; the
    /// note and an anchor must be live rows of the book — `postNotInReading`),
    /// behind HER DOORS' gate (`MCPLibraryRefusal.bookNotInManualOrder` — a
    /// book that sorts itself takes no hand placing). Its chapter is
    /// untouched (filing is `file_note_in_chapter`'s). ONE entry restoring the
    /// member row's exact previous position while the row still stands where
    /// the act put it, the redo the new one likewise.
    public func moveNoteInBookForClient(
        _ postID: String, book readingID: String, to insert: InsertPosition, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws {
        let moved: (rowID: String, from: String, to: String) = try database.write { db in
            try guardian?(db)
            guard try liveReading(db, readingID).sortField == .manual else {
                throw MCPLibraryRefusal.bookNotInManualOrder(bookID: readingID)
            }
            return try reorderMembershipRow(db, postID: postID, readingID: readingID, to: insert)
        }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreMembershipPosition(moved.rowID, from: moved.to, to: moved.from) },
            redo: { try $0.restoreMembershipPosition(moved.rowID, from: moved.from, to: moved.to) })
    }

    /// Both halves of the move entry, COMPARE-AND-SET (VX-184 ladder round 1):
    /// `to` only while the member row is live and still stands at `from` — a
    /// place she gave the note since (her own order doors register no entry)
    /// is hers, and the entry is quiet. Checked FIRST; past it, a finished
    /// book refuses and keeps the entry.
    func restoreMembershipPosition(_ rowID: String, from: String, to position: String) throws {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: rowID), row.deletedAt == nil,
                  row.status == .member, row.position == from,
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil
            else { return }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            row.position = position
            try row.update(db)
        }
    }

    // MARK: - CHAPTERS

    /// What `renameChapterForClient` did.
    public struct MCPChapterRename: Equatable, Sendable {
        public let sectionID: String
        public let bookID: String
        public let name: String
        public let changed: Bool
    }

    /// **`rename_chapter`'s act — her `renameSection`** (`renameSectionRow`:
    /// trimmed, blank refuses `invalidSectionName`, the same name writes
    /// nothing, ALLOWED under a finished book — rename stays free). ONE entry
    /// restoring the previous name exactly while the chapter still wears the
    /// act's name.
    @discardableResult
    public func renameChapterForClient(
        _ sectionID: String, name: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPChapterRename {
        let landed: (previous: String?, section: ReadingSection) = try database.write { db in
            try guardian?(db)
            let previous = try renameSectionRow(db, sectionID, name: name)
            return (previous, try liveSection(db, sectionID))
        }
        let rename = MCPChapterRename(
            sectionID: sectionID, bookID: landed.section.readingId, name: landed.section.name,
            changed: landed.previous != nil)
        if let previous = landed.previous {
            let newName = landed.section.name
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreChapterName(sectionID, from: newName, to: previous) },
                redo: { try $0.restoreChapterName(sectionID, from: previous, to: newName) })
        }
        return rename
    }

    /// Both halves of the chapter-name entry, COMPARE-AND-SET (VX-184 ladder
    /// round 1): `to` only while the chapter is live and still wears `from` —
    /// a name she gave it since (her chapter rename registers no entry) is
    /// hers, and the entry is quiet. Rename is free on a finished book, so
    /// nothing refuses.
    func restoreChapterName(_ sectionID: String, from: String, to name: String) throws {
        try database.write { db in
            guard var section = try ReadingSection.fetchOne(db, key: sectionID), section.deletedAt == nil,
                  section.name == from
            else { return }
            section.name = name
            section.updatedAt = date.now
            try section.update(db)
        }
    }

    /// **`delete_chapter`'s act — her `deleteSection`** (`deleteSectionRow`:
    /// a finished book refuses; the chapter tombstoned, its notes keep their
    /// pointer and read unfiled). ONE entry: her `restoreSection` flip while
    /// the chapter wears the act's stamp (the pointers reattach for free; a
    /// finished book refuses and keeps it; a book gone is quiet), the redo
    /// deleting it again.
    @discardableResult
    public func deleteChapterForClient(
        _ sectionID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> ReadingSection {
        let section: ReadingSection = try database.write { db in
            try guardian?(db)
            return try deleteSectionRow(db, sectionID)
        }
        let deletedOn = LockIsolated(section.deletedAt.map { DateFormatter.variorumISO8601.string(from: $0) } ?? "")
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reviveDeletedChapter(sectionID, deletedOn: deletedOn.value) },
            redo: { ops in
                if let stamp = try ops.redeleteChapter(sectionID) { deletedOn.setValue(stamp) }
            })
        return section
    }

    /// A chapter delete's inverse — see `deleteChapterForClient`.
    func reviveDeletedChapter(_ sectionID: String, deletedOn stamp: String) throws {
        try database.write { db in
            guard let section = try ReadingSection.fetchOne(db, key: sectionID),
                  section.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp,
                  try Reading.fetchOne(db, key: section.readingId)?.deletedAt == nil
            else { return }
            try restoreSectionRow(db, sectionID)
        }
    }

    /// A chapter delete's redo: her delete body again — quiet when the
    /// chapter is gone. Returns the stamp it wrote.
    func redeleteChapter(_ sectionID: String) throws -> String? {
        try database.write { db in
            guard let section = try ReadingSection.fetchOne(db, key: sectionID), section.deletedAt == nil,
                  try Reading.fetchOne(db, key: section.readingId)?.deletedAt == nil
            else { return nil }
            return try deleteSectionRow(db, sectionID).deletedAt.map { DateFormatter.variorumISO8601.string(from: $0) }
        }
    }

    /// **`move_chapter`'s act — her `reorderSection`** (`reorderSectionRow`:
    /// a finished book refuses; anchors are the SAME book's live chapters —
    /// `sectionNotFound`). ONE entry restoring the exact previous position
    /// while the chapter still stands where the act put it, the redo the new
    /// one likewise. Returns the chapter's book.
    @discardableResult
    public func moveChapterForClient(
        _ sectionID: String, to insert: InsertPosition, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> String {
        let moved: (bookID: String, from: String, to: String) = try database.write { db in
            try guardian?(db)
            let bookID = try liveSection(db, sectionID).readingId
            let positions = try reorderSectionRow(db, sectionID, to: insert)
            return (bookID, positions.from, positions.to)
        }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreChapterPosition(sectionID, from: moved.to, to: moved.from) },
            redo: { try $0.restoreChapterPosition(sectionID, from: moved.from, to: moved.to) })
        return moved.bookID
    }

    /// Both halves of the chapter-move entry, COMPARE-AND-SET (VX-184 ladder
    /// round 1): `to` only while the chapter and its book are live and the
    /// chapter still stands at `from` — a place she gave it since (her chapter
    /// order registers no entry) is hers, and the entry is quiet. Checked
    /// FIRST; past it, a finished book refuses and keeps the entry.
    func restoreChapterPosition(_ sectionID: String, from: String, to position: String) throws {
        try database.write { db in
            guard var section = try ReadingSection.fetchOne(db, key: sectionID), section.deletedAt == nil,
                  section.position == from,
                  let book = try Reading.fetchOne(db, key: section.readingId), book.deletedAt == nil
            else { return }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            section.position = position
            section.updatedAt = date.now
            try section.update(db)
        }
    }

    // MARK: - THE NOTE IN THE LIBRARY

    /// **`delete_note`'s act — her Trash road** (`deleteContainer`'s body,
    /// `tombstoneNoteFamily`: the note and its saved versions on ONE stamp,
    /// the cascade taking its placements, memberships, tags and references —
    /// 30 days in the Trash, restorable; a seal does not refuse — §9). ONE
    /// entry: her `restoreContainer` body (`restoreNoteFamily` + the
    /// ownership revival pass — purge intents voided on the way, the B1 belt)
    /// while the note still wears the act's stamp — Put back since, or purged,
    /// is quiet; the redo deletes it again on a fresh stamp.
    @discardableResult
    public func deleteNoteForClient(
        _ postID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Date {
        let stamp: Date = try database.write { db in
            try guardian?(db)
            _ = try livePost(db, postID)
            let now = date.now
            try tombstoneNoteFamily(db, id: postID, now: now)
            return now
        }
        let deletedOn = LockIsolated(DateFormatter.variorumISO8601.string(from: stamp))
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertDeletedNote(postID, deletedOn: deletedOn.value) },
            redo: { ops in
                if let stamp = try ops.redeleteNote(postID) { deletedOn.setValue(stamp) }
            })
        return stamp
    }

    /// A note delete's inverse — see `deleteNoteForClient`.
    func revertDeletedNote(_ postID: String, deletedOn stamp: String) throws {
        try database.write { db in
            guard let note = try Container.fetchOne(db, key: postID),
                  note.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp
            else { return }
            try restoreNoteFamily(db, id: postID)
            try enforceOwnershipAfterRevival(db, postIDs: [postID], now: date.now)
        }
    }

    /// A note delete's redo: her delete body again — quiet when the note is
    /// gone. Returns the stamp it wrote.
    func redeleteNote(_ postID: String) throws -> String? {
        try database.write { db in
            guard let note = try Container.fetchOne(db, key: postID), note.deletedAt == nil else { return nil }
            let now = date.now
            try tombstoneNoteFamily(db, id: postID, now: now)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }

    /// What `setNoteArchivedForClient` did.
    public struct MCPNoteArchive: Equatable, Sendable {
        public let noteID: String
        public let archived: Bool
        public let changed: Bool
    }

    /// **`archive_note` / `unarchive_note`'s act — her `archiveContainer` /
    /// `unarchiveContainer`** (`archiveContainerRow` / `unarchiveContainerRow`;
    /// a seal does not refuse — §9). The state already as asked writes
    /// NOTHING (`changed: false` — P-VX196-6: her doors never offer Archive on
    /// an archived note, and her op's re-stamp would break an owned book's
    /// exact-stamp unarchive). ONE entry restoring the EXACT prior
    /// `archived_at` (an unarchive's undo puts back the original stamp — a
    /// note archived WITH its owned book still returns with it), quiet when
    /// the note has moved on.
    @discardableResult
    public func setNoteArchivedForClient(
        _ postID: String, archived: Bool, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPNoteArchive {
        let landed: (changed: Bool, before: Date?, after: Date?) = try database.write { db in
            try guardian?(db)
            let note = try livePost(db, postID)
            guard (note.archivedAt != nil) != archived else { return (false, nil, nil) }
            if archived {
                let now = date.now
                try archiveContainerRow(db, postID, now: now)
                return (true, nil, now)
            }
            try unarchiveContainerRow(db, postID)
            return (true, note.archivedAt, nil)
        }
        if landed.changed {
            let before = landed.before, after = landed.after
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreNoteArchived(postID, from: after, to: before) },
                redo: { try $0.restoreNoteArchived(postID, from: before, to: after) })
        }
        return MCPNoteArchive(noteID: postID, archived: archived, changed: landed.changed)
    }

    /// Both halves of the note-archive entry: `archived_at` set to `to` only
    /// while the note is live and still wears `from` (compared by its stored
    /// spelling) — quiet otherwise.
    func restoreNoteArchived(_ postID: String, from: Date?, to: Date?) throws {
        let spelled = { (date: Date?) in date.map { DateFormatter.variorumISO8601.string(from: $0) } }
        try database.write { db in
            guard var note = try Container.fetchOne(db, key: postID), note.deletedAt == nil,
                  spelled(note.archivedAt) == spelled(from)
            else { return }
            note.archivedAt = to
            note.updatedAt = date.now
            try note.update(db)
        }
    }
}

extension Queries {
    /// **The book a LIVE chapter belongs to** (VX-196 — the chapter acts'
    /// address): the chapter's reading id, whatever that reading is (the
    /// server's facts then decide it — a gathering, a fenced or a dead book
    /// answer through the one rule). Nil for a chapter that is deleted or
    /// names nothing (the one answer).
    public static func mcpBookOf(section sectionID: String, _ db: Database) throws -> String? {
        try String.fetchOne(
            db, sql: "SELECT reading_id FROM reading_section WHERE id = ? AND deleted_at IS NULL",
            arguments: [sectionID])
    }
}
