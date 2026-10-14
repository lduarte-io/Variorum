import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 U5 — VX-196's FOURTEEN ACTS (`Operations+MCPLibraryEdits`): exact state
// transitions, each act HER door's row work through the SAME extracted body her
// door calls, the caller's guard FIRST inside the act's own transaction, and ONE
// client-named entry whose inverse and redo round-trip the same rows. Who may act
// is the server's per-call rule (the `MCP*ServerTests` of this unit). Her own
// doors' suites run UNMODIFIED as the extractions' parity proof.

private struct GuardRefused: Error, Equatable {}

@Suite("VX-196 — edit parity across the library: the acts")
struct MCPLibraryEditActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private let refuse: Operations.WriteGuard = { _ in throw GuardRefused() }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    private func note(_ db: AppDatabase, _ id: String) throws -> Container {
        try #require(try db.read { try Container.fetchOne($0, key: id) })
    }

    private func members(_ db: AppDatabase, _ bookID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL
                      AND status = 'member' ORDER BY position, post_id
                    """,
                arguments: [bookID])
        }
    }

    private func chapters(_ db: AppDatabase, _ bookID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT name FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id",
                arguments: [bookID])
        }
    }

    private func pending(_ db: AppDatabase, _ bookID: String) throws -> Int {
        try db.read { try Queries.pendingArrivalCount($0, readingID: bookID) }
    }

    // MARK: - Every act: the guard first, nothing written when it refuses

    @Test func everyActRunsTheGuardFirstAndARefusalWritesNothing() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "one")
            let first = try ops.createPost(title: "ch 1")
            let second = try ops.createPost(title: "ch 2")
            for post in [first, second] { _ = try ops.addPostToReading(post.id, to: book.id) }
            let archived = try ops.createReading(name: "old", kind: .book)
            try ops.archiveReading(archived.id)
            let closed = try ops.createPost(title: "kept")
            try ops.archiveContainer(closed.id)
            let tables = ["reading", "reading_post", "reading_section", "container", "block", "variant"]
            func snapshot() throws -> [String] {
                try db.read { db in
                    try tables.flatMap { try Row.fetchAll(db, sql: "SELECT * FROM \($0) ORDER BY id").map(\.description) }
                }
            }
            let before = try snapshot()
            let acts: [(String, () throws -> Void)] = [
                ("rename book", { _ = try ops.renameBookForClient(book.id, name: "x", undoLabel: "x", guardedBy: refuse) }),
                ("finish", { _ = try ops.setBookFinishedForClient(book.id, finished: true, undoLabel: "x",
                                                                  guardedBy: refuse) }),
                ("reopen", { _ = try ops.setBookFinishedForClient(book.id, finished: false, undoLabel: "x",
                                                                  guardedBy: refuse) }),
                ("archive book", { _ = try ops.archiveBookForClient(book.id, undoLabel: "x", guardedBy: refuse) }),
                ("unarchive book", { _ = try ops.unarchiveBookForClient(archived.id, undoLabel: "x", guardedBy: refuse) }),
                ("delete book", { _ = try ops.deleteBookForClient(book.id, undoLabel: "x", guardedBy: refuse) }),
                ("remove", { _ = try ops.removeNoteFromBookForClient(
                    first.id, book: book.id, removeUndoLabel: "x", releaseUndoLabel: "x", guardedBy: refuse) }),
                ("move note", { try ops.moveNoteInBookForClient(second.id, book: book.id, to: .start, undoLabel: "x",
                                                                guardedBy: refuse) }),
                ("rename chapter", { _ = try ops.renameChapterForClient(chapter.id, name: "x", undoLabel: "x",
                                                                        guardedBy: refuse) }),
                ("delete chapter", { _ = try ops.deleteChapterForClient(chapter.id, undoLabel: "x", guardedBy: refuse) }),
                ("move chapter", { _ = try ops.moveChapterForClient(chapter.id, to: .end, undoLabel: "x",
                                                                    guardedBy: refuse) }),
                ("delete note", { _ = try ops.deleteNoteForClient(first.id, undoLabel: "x", guardedBy: refuse) }),
                ("archive note", { _ = try ops.setNoteArchivedForClient(first.id, archived: true, undoLabel: "x",
                                                                        guardedBy: refuse) }),
                ("unarchive note", { _ = try ops.setNoteArchivedForClient(closed.id, archived: false, undoLabel: "x",
                                                                          guardedBy: refuse) }),
            ]
            for (name, act) in acts {
                #expect(throws: GuardRefused.self, "\(name)") { try act() }
            }
            #expect(try snapshot() == before, "a refused guard writes nothing, anywhere")
            #expect(stack.depth == 0)
        }
    }

    // MARK: - The book's name

    @Test func aBookRenameIsHerRenameWithTheNameGuardInsideTheAct() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            _ = try ops.createReading(name: "letters", kind: .book)
            #expect(throws: OperationError.duplicateBookName(name: "letters")) {
                try ops.renameBookForClient(book.id, name: " Letters ", undoLabel: label(.bookName))
            }
            #expect(stack.depth == 0)
            let same = try ops.renameBookForClient(book.id, name: "drafts", undoLabel: label(.bookName))
            #expect(!same.changed && stack.depth == 0, "the same name writes nothing")
            try ops.lockReading(book.id)
            let renamed = try ops.renameBookForClient(book.id, name: "  Drafts, done ", undoLabel: label(.bookName))
            #expect(renamed == .init(bookID: book.id, name: "Drafts, done", changed: true), "a finished book renames")
            #expect(try stack.undo(with: ops) == label(.bookName))
            #expect(try reading(db, book.id).name == "drafts")
            #expect(try stack.redo(with: ops) == label(.bookName))
            #expect(try reading(db, book.id).name == "Drafts, done")
        }
    }

    // MARK: - Finish / reopen

    @Test func aFinishsUndoRevivesWhatItDismissedAndAReopensUndoFinishesAgain() throws {
        try withUndo { ops, stack, db in
            let travel = try ops.createTag(name: "travel")
            let book = try ops.createReading(
                name: "travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(travel.id)),
                intakeSeating: .arrivals)
            let waiting = try ops.createPost(title: "a trip")
            _ = try ops.applyTag(travel.id, toPost: waiting.id)
            let arrival = try #require(try db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                                    arguments: [book.id])
            })
            stack.removeAll()

            let finished = try ops.setBookFinishedForClient(book.id, finished: true, undoLabel: label(.bookFinish))
            #expect(try finished.changed && reading(db, book.id).locked && pending(db, book.id) == 0)
            #expect(try ops.setBookFinishedForClient(book.id, finished: true, undoLabel: label(.bookFinish)).changed == false)
            #expect(stack.depth == 1)
            #expect(try stack.undo(with: ops) == label(.bookFinish))
            #expect(try !reading(db, book.id).locked)
            #expect(try db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                                    arguments: [book.id])
            } == arrival, "the very arrival row waits again")
            #expect(try stack.redo(with: ops) == label(.bookFinish))
            #expect(try reading(db, book.id).locked && pending(db, book.id) == 0)
            #expect(try stack.undo(with: ops) == label(.bookFinish))
            #expect(try pending(db, book.id) == 1, "revived on the redo's own stamp")

            // A reopen's undo is her finish again; a SEALED book refuses the
            // reopen (Unseal is hers) and the finish is a no-op on it.
            try ops.lockReading(book.id)
            stack.removeAll()
            let reopened = try ops.setBookFinishedForClient(book.id, finished: false, undoLabel: label(.bookReopen))
            #expect(try reopened.changed && !reading(db, book.id).locked)
            #expect(try stack.undo(with: ops) == label(.bookReopen))
            #expect(try reading(db, book.id).locked)
            try ops.unlockReading(book.id)
            _ = try ops.sealReading(book.id)
            stack.removeAll()
            #expect(throws: OperationError.readingSealed(id: book.id)) {
                try ops.setBookFinishedForClient(book.id, finished: false, undoLabel: label(.bookReopen))
            }
            #expect(try ops.setBookFinishedForClient(book.id, finished: true, undoLabel: label(.bookFinish)).changed == false)
            #expect(stack.depth == 0)

            // A gathering has no finish (her op's answer: the kind).
            let gathering = try ops.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(travel.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setBookFinishedForClient(gathering.id, finished: true, undoLabel: label(.bookFinish))
            }
        }
    }

    // MARK: - Archive / unarchive a book

    @Test func aBooksArchiveAndUnarchiveKeepTheExactStampsAndTheUndoIsQuietOnceSheMovedOn() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let stamp = try ops.archiveBookForClient(book.id, undoLabel: label(.bookArchive))
            #expect(try reading(db, book.id).archivedAt == stamp)
            #expect(throws: OperationError.readingAlreadyArchived(id: book.id)) {
                try ops.archiveBookForClient(book.id, undoLabel: label(.bookArchive))
            }
            // She unarchived and archived it again by hand: the entry is quiet.
            try ops.unarchiveReading(book.id)
            try ops.archiveReading(book.id)
            let hers = try reading(db, book.id).archivedAt
            #expect(try stack.undo(with: ops) == label(.bookArchive))
            #expect(try reading(db, book.id).archivedAt == hers, "quiet — her own archive stands")

            // Her archive-with-notes on an owned book; the client's unarchive
            // and its undo, on her ORIGINAL stamp.
            let owned = try ops.createReading(name: "the novel", kind: .book)
            let member = try ops.createPost(title: "ch 1")
            _ = try ops.addPostToReading(member.id, to: owned.id)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            _ = try ops.archiveReadingWithNotes(owned.id)
            let herStamp = try #require(try reading(db, owned.id).archivedAt)
            stack.removeAll()
            let result = try ops.unarchiveBookForClient(owned.id, undoLabel: label(.bookUnarchive))
            #expect(result.returned == [member.id])
            #expect(try reading(db, owned.id).archivedAt == nil && note(db, member.id).archivedAt == nil)
            #expect(try stack.undo(with: ops) == label(.bookUnarchive))
            #expect(try reading(db, owned.id).archivedAt == herStamp && note(db, member.id).archivedAt == herStamp)
            #expect(try stack.redo(with: ops) == label(.bookUnarchive))
            #expect(try reading(db, owned.id).archivedAt == nil && note(db, member.id).archivedAt == nil)
            #expect(try reading(db, owned.id).owned, "Own is hers — untouched")
        }
    }

    // MARK: - Delete a book

    @Test func aBookDeleteIsHerDeleteAndTheDailyJournalNeverDeletesEvenPastTheGuard() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "one")
            let member = try ops.createPost(title: "ch 1")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let deletion = try ops.deleteBookForClient(book.id, undoLabel: label(.bookDelete))
            #expect(!deletion.releasedNotes)
            let stamp = try #require(try reading(db, book.id).deletedAt)
            #expect(try db.read { try ReadingSection.fetchOne($0, key: chapter.id)?.deletedAt } == stamp)
            #expect(try stack.undo(with: ops) == label(.bookDelete))
            #expect(try reading(db, book.id).deletedAt == nil && members(db, book.id) == [member.id])
            #expect(try chapters(db, book.id) == ["one"])
            // Now it becomes THE daily Journal: the redo refuses and keeps it.
            try ops.setDailyJournalBook(book.id)
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: book.id)) { try stack.redo(with: ops) }
            #expect(stack.redoDepth == 1, "the entry stays")
            // The act itself refuses THE daily Journal inside the write, even
            // past an allowing guard (the wire never reaches it — fenced).
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: book.id)) {
                try ops.deleteBookForClient(book.id, undoLabel: label(.bookDelete), guardedBy: { _ in })
            }
            // An OWNED book: "book only" — its notes back to the Pool.
            let owned = try ops.createReading(name: "the novel", kind: .book)
            let ownedNote = try ops.createPost(title: "its own")
            _ = try ops.addPostToReading(ownedNote.id, to: owned.id)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            #expect(try ops.deleteBookForClient(owned.id, undoLabel: label(.bookDelete)).releasedNotes)
            #expect(try note(db, ownedNote.id).deletedAt == nil
                    && db.read { try Queries.noteMemberships($0, postID: ownedNote.id) }.isEmpty)
            // Put back from the Trash first: the undo is quiet.
            try ops.restoreReading(owned.id)
            #expect(try stack.undo(with: ops) == label(.bookDelete))
            #expect(try reading(db, owned.id).deletedAt == nil && members(db, owned.id) == [ownedNote.id])
        }
    }

    // MARK: - Membership & order

    @Test func aRemovalRevivesTheVeryRowAndAFinishedBookKeepsTheEntry() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let other = try ops.createReading(name: "letters", kind: .book)
            let target = try ops.createPost(title: "ch 1")
            for reading in [book, other] { _ = try ops.addPostToReading(target.id, to: reading.id) }
            let row = try #require(try db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ?",
                                    arguments: [book.id, target.id])
            })
            let removal = try ops.removeNoteFromBookForClient(
                target.id, book: book.id, removeUndoLabel: label(.bookRemove), releaseUndoLabel: label(.bookRelease))
            #expect(removal == .init(noteID: target.id, bookID: book.id, released: false, bookless: false))
            #expect(stack.topLabel == label(.bookRemove))
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) { try stack.undo(with: ops) }
            #expect(stack.depth == 1, "a finished book keeps the entry (resolvable)")
            try ops.unlockReading(book.id)
            #expect(try stack.undo(with: ops) == label(.bookRemove))
            #expect(try db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                                    arguments: [book.id, target.id])
            } == row, "the very row")
            #expect(throws: OperationError.postNotInReading(postID: "nope", readingID: book.id)) {
                try ops.removeNoteFromBookForClient("nope", book: book.id, removeUndoLabel: "x", releaseUndoLabel: "x")
            }

            let owned = try ops.createReading(name: "the novel", kind: .book)
            let ownedNote = try ops.createPost(title: "its own")
            _ = try ops.addPostToReading(ownedNote.id, to: owned.id)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            stack.removeAll()
            let release = try ops.removeNoteFromBookForClient(
                ownedNote.id, book: owned.id, removeUndoLabel: label(.bookRemove), releaseUndoLabel: label(.bookRelease))
            #expect(release.released && release.bookless && stack.topLabel == label(.bookRelease))
        }
    }

    @Test func aNoteMoveIsGatedOnManualOrderAndItsUndoRestoresTheExactPlace() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let notes = try (1...3).map { try ops.createPost(title: "ch \($0)") }
            for post in notes { _ = try ops.addPostToReading(post.id, to: book.id) }
            let ids = notes.map(\.id)
            try ops.moveNoteInBookForClient(ids[2], book: book.id, to: .before(ids[0]), undoLabel: label(.bookOrder))
            #expect(try members(db, book.id) == [ids[2], ids[0], ids[1]])
            #expect(try stack.undo(with: ops) == label(.bookOrder))
            #expect(try members(db, book.id) == ids)
            #expect(try stack.redo(with: ops) == label(.bookOrder))
            #expect(try members(db, book.id) == [ids[2], ids[0], ids[1]])
            try ops.setReadingSort(book.id, field: .lastTouched, direction: .desc)
            #expect(throws: Operations.MCPLibraryRefusal.bookNotInManualOrder(bookID: book.id)) {
                try ops.moveNoteInBookForClient(ids[0], book: book.id, to: .end, undoLabel: label(.bookOrder))
            }
        }
    }

    // MARK: - Chapters

    @Test func chapterActsAreHerSectionDoorsWithTheirOwnUndos() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let one = try ops.createSection(in: book.id, name: "one")
            let two = try ops.createSection(in: book.id, name: "two")
            let member = try ops.createPost(title: "ch 1")
            _ = try ops.addPostToReading(member.id, to: book.id)
            try ops.assignPostToSection(member.id, in: book.id, section: one.id)

            let renamed = try ops.renameChapterForClient(two.id, name: " two, revised ", undoLabel: label(.chapterName))
            #expect(renamed == .init(sectionID: two.id, bookID: book.id, name: "two, revised", changed: true))
            #expect(try ops.renameChapterForClient(two.id, name: "two, revised", undoLabel: "x").changed == false)
            #expect(try ops.moveChapterForClient(two.id, to: .start, undoLabel: label(.chapterMove)) == book.id)
            #expect(try chapters(db, book.id) == ["two, revised", "one"])
            _ = try ops.deleteChapterForClient(one.id, undoLabel: label(.chapterDelete))
            #expect(try chapters(db, book.id) == ["two, revised"])
            #expect(try db.read { db in
                try String.fetchOne(db, sql: "SELECT section_id FROM reading_post WHERE post_id = ?", arguments: [member.id])
            } == one.id, "the pointer is never rewritten")
            // A finished book: the chapter's revival refuses and keeps the entry.
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) { try stack.undo(with: ops) }
            try ops.unlockReading(book.id)
            #expect(try stack.undo(with: ops) == label(.chapterDelete))
            #expect(try stack.undo(with: ops) == label(.chapterMove))
            #expect(try stack.undo(with: ops) == label(.chapterName))
            #expect(try chapters(db, book.id) == ["one", "two"], "her chapters, exactly")
            #expect(try stack.redo(with: ops) == label(.chapterName))
            #expect(try stack.redo(with: ops) == label(.chapterMove))
            #expect(try stack.redo(with: ops) == label(.chapterDelete))
            #expect(try chapters(db, book.id) == ["two, revised"])
        }
    }

    // MARK: - The note in the library

    @Test func aNoteDeleteIsHerTrashRoadAndItsArchiveKeepsTheExactStamp() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let target = try ops.createPost(title: "ch 1")
            _ = try ops.addPostToReading(target.id, to: book.id)
            _ = try ops.seedBlock(in: target.id, text: "Her words.")
            let version = try ops.saveNoteVersion(target.id).post
            stack.removeAll()
            let stamp = try ops.deleteNoteForClient(target.id, undoLabel: label(.noteDelete))
            #expect(try note(db, target.id).deletedAt == stamp && note(db, version.id).deletedAt == stamp)
            #expect(try stack.undo(with: ops) == label(.noteDelete))
            #expect(try note(db, target.id).deletedAt == nil && note(db, version.id).deletedAt == nil)
            #expect(try members(db, book.id) == [target.id])
            #expect(try db.read { try Queries.renderedText($0, containerID: target.id) } == "Her words.")
            #expect(try stack.redo(with: ops) == label(.noteDelete))
            try ops.restoreContainer(target.id)
            #expect(try stack.undo(with: ops) == label(.noteDelete), "quiet — she put it back")
            #expect(try note(db, target.id).deletedAt == nil)

            // Archive / unarchive: no-op guarded; the exact prior stamp.
            stack.removeAll()
            #expect(try ops.setNoteArchivedForClient(target.id, archived: false, undoLabel: "x").changed == false)
            let archived = try ops.setNoteArchivedForClient(target.id, archived: true, undoLabel: label(.noteArchive))
            #expect(archived.changed)
            let first = try #require(try note(db, target.id).archivedAt)
            #expect(try ops.setNoteArchivedForClient(target.id, archived: true, undoLabel: "x").changed == false)
            #expect(try note(db, target.id).archivedAt == first, "never re-stamped")
            #expect(try stack.undo(with: ops) == label(.noteArchive))
            #expect(try note(db, target.id).archivedAt == nil)
            #expect(try stack.redo(with: ops) == label(.noteArchive))
            #expect(try note(db, target.id).archivedAt == first, "the act's own stamp, again")
            let unarchived = try ops.setNoteArchivedForClient(target.id, archived: false, undoLabel: label(.noteUnarchive))
            #expect(try unarchived.changed && note(db, target.id).archivedAt == nil)
            #expect(try stack.undo(with: ops) == label(.noteUnarchive))
            #expect(try note(db, target.id).archivedAt == first, "the original stamp, exactly")
        }
    }

    // MARK: - The address read

    @Test func aChapterAddressesItsBookWhileItLives() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "one")
            #expect(try db.read { try Queries.mcpBookOf(section: chapter.id, $0) } == book.id)
            try ops.deleteSection(chapter.id)
            #expect(try db.read { try Queries.mcpBookOf(section: chapter.id, $0) } == nil)
            #expect(try db.read { try Queries.mcpBookOf(section: "no-such", $0) } == nil)
        }
    }
}
