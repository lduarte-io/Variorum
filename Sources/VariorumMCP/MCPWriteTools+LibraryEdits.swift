import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE EDIT RUNG's PARITY ACROSS THE LIBRARY on the wire** (VX-184 U5 —
/// VX-196; her ruling R-VX184-1, "We defined Edit as 'as capable as you at the
/// keyboard', we need to make that true" — her picks). Thin projections of
/// `Operations+MCPLibraryEdits` — her own doors' acts on a book's name, finish,
/// archive and delete, its membership and order, its chapters, and a note's
/// delete and archive — each the edit rung's two decisions (AF-10 (a)): the
/// SNAPSHOT speaks the refusal and raises the just-in-time ask (the ONE
/// not-shared answer for anything unreachable — a fenced book, the daily
/// Journal, a dead or foreign id; `rungTooLow` + the asked sentence for a live
/// holder below edit), then a `WriteGuard` re-decides INSIDE the act's
/// transaction and spends any once grant there. ONE client-named undo entry per
/// act (P-VX196-1).
///
/// **A GATHERING is read, never changed** (VX-273; the record's call 3,
/// PROVISIONAL P-VX196-2): a book id naming a gathering THIS client can read
/// (wing reach, or the open book — `decideGathering`, the one rule) hears what
/// it is — never "doesn't exist", which `list_books` has already contradicted;
/// one it cannot read is the one shape. Private, Seal and Own stay hers alone
/// (R-VX184-2): nothing here touches them.
extension MCPWriteTools {
    enum LibraryEditJob: Sendable {
        case renameBook(bookID: String, name: String)
        case setFinished(bookID: String, finished: Bool)
        case archiveBook(bookID: String)
        case unarchiveBook(bookID: String)
        case deleteBook(bookID: String)
        case removeNote(bookID: String, noteID: String)
        case moveNote(bookID: String, noteID: String, to: Slot)
        case renameChapter(sectionID: String, name: String)
        case deleteChapter(sectionID: String)
        case moveChapter(sectionID: String, to: Slot)
        case deleteNote(noteID: String)
        case setNoteArchived(noteID: String, archived: Bool)

        var tool: String {
            switch self {
            case .renameBook: MCPToolCatalog.renameBook.name
            case .setFinished(_, let finished): finished ? MCPToolCatalog.finishBook.name : MCPToolCatalog.reopenBook.name
            case .archiveBook: MCPToolCatalog.archiveBook.name
            case .unarchiveBook: MCPToolCatalog.unarchiveBook.name
            case .deleteBook: MCPToolCatalog.deleteBook.name
            case .removeNote: MCPToolCatalog.removeNoteFromBook.name
            case .moveNote: MCPToolCatalog.moveNoteInBook.name
            case .renameChapter: MCPToolCatalog.renameChapter.name
            case .deleteChapter: MCPToolCatalog.deleteChapter.name
            case .moveChapter: MCPToolCatalog.moveChapter.name
            case .deleteNote: MCPToolCatalog.deleteNote.name
            case .setNoteArchived(_, let archived):
                archived ? MCPToolCatalog.archiveNote.name : MCPToolCatalog.unarchiveNote.name
            }
        }
    }

    /// Where a move puts a note in its book's order, or a chapter in its
    /// book's chapters — exactly one road (`move_block`'s grammar).
    enum Slot: Sendable, Equatable {
        case after(String)
        case before(String)
        case start
        case end

        var insert: Operations.InsertPosition {
            switch self {
            case .after(let id): .after(id)
            case .before(let id): .before(id)
            case .start: .start
            case .end: .end
            }
        }

        var anchor: String? {
            switch self {
            case .after(let id), .before(let id): id
            case .start, .end: nil
            }
        }
    }

    // MARK: - The wire's own sentences (P-U5-WORDS, 13s-a sweepable)

    /// A write aimed at a gathering the client can READ (P-VX196-2) — her
    /// `RemoveFromBookCopy.removeTagHelp` truth: it holds no notes; a note
    /// leaves it by no longer matching.
    static func gatheringWords(_ name: String?) -> String {
        let named = name.map { "\u{201C}\($0)\u{201D}" } ?? "That"
        return "\(named) is a gathering \u{2014} it shows the notes its rule matches and holds none of its own, "
            + "so it can be read but not changed through this door. A note leaves it by no longer matching "
            + "(remove_tag takes a tag off a note); renaming, archiving or deleting a gathering is the author's."
    }

    /// A note named on a book act that is not one of the book's notes (the
    /// client can read it — an unreadable one is the one answer first).
    /// (The wire's refusal register: plain apostrophes, as `MCPWireRefusalCopy`'s.)
    static let notInBookWords =
        "That note isn't in this book \u{2014} list_notes with the book's id lists its notes."

    /// A chapter anchor of another book (the op's `sectionNotFound`).
    static let notThisBooksChapterWords =
        "That chapter isn't one of this book's \u{2014} list_notes with the book's id lists its chapters."

    /// `move_note_in_book` on a book that sorts itself — her Book Panel's own
    /// gate (`BookPanelCopy.needsManualOrder`), said for the door.
    static let notInManualOrderWords =
        "That book sorts itself (by date or by when its notes were edited), so a note can't be placed "
        + "by hand \u{2014} the author can set the book's order to manual order in Variorum."

    /// The receipt's detail on an OWNED book's delete — her "Delete Book Only":
    /// where its notes went.
    static let releasedNotesDetail = "its notes are in the Pool"

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseLibraryEdit(_ name: String, _ args: [String: Value]) throws -> LibraryEditJob? {
        switch name {
        case MCPToolCatalog.renameBook.name:
            return .renameBook(bookID: try requiredString(args, "book_id"), name: try requiredText(args, "name"))
        case MCPToolCatalog.finishBook.name:
            return .setFinished(bookID: try requiredString(args, "book_id"), finished: true)
        case MCPToolCatalog.reopenBook.name:
            return .setFinished(bookID: try requiredString(args, "book_id"), finished: false)
        case MCPToolCatalog.archiveBook.name:
            return .archiveBook(bookID: try requiredString(args, "book_id"))
        case MCPToolCatalog.unarchiveBook.name:
            return .unarchiveBook(bookID: try requiredString(args, "book_id"))
        case MCPToolCatalog.deleteBook.name:
            return .deleteBook(bookID: try requiredString(args, "book_id"))
        case MCPToolCatalog.removeNoteFromBook.name:
            return .removeNote(bookID: try requiredString(args, "book_id"), noteID: try requiredString(args, "note_id"))
        case MCPToolCatalog.moveNoteInBook.name:
            let noteID = try requiredString(args, "note_id")
            let slot = try slot(args, after: "after_note_id", before: "before_note_id", moving: noteID, noun: "note")
            return .moveNote(bookID: try requiredString(args, "book_id"), noteID: noteID, to: slot)
        case MCPToolCatalog.renameChapter.name:
            return .renameChapter(sectionID: try requiredString(args, "section_id"), name: try requiredText(args, "name"))
        case MCPToolCatalog.deleteChapter.name:
            return .deleteChapter(sectionID: try requiredString(args, "section_id"))
        case MCPToolCatalog.moveChapter.name:
            let sectionID = try requiredString(args, "section_id")
            let slot = try slot(
                args, after: "after_section_id", before: "before_section_id", moving: sectionID, noun: "chapter")
            return .moveChapter(sectionID: sectionID, to: slot)
        case MCPToolCatalog.deleteNote.name:
            return .deleteNote(noteID: try requiredString(args, "note_id"))
        case MCPToolCatalog.archiveNote.name:
            return .setNoteArchived(noteID: try requiredString(args, "note_id"), archived: true)
        case MCPToolCatalog.unarchiveNote.name:
            return .setNoteArchived(noteID: try requiredString(args, "note_id"), archived: false)
        default:
            return nil
        }
    }

    /// Exactly one of `after_…` · `before_…` · `at` ("start" | "end").
    private func slot(
        _ args: [String: Value], after afterKey: String, before beforeKey: String, moving id: String, noun: String
    ) throws -> Slot {
        let after = try optionalString(args, afterKey)
        let before = try optionalString(args, beforeKey)
        let at = try optionalString(args, "at")
        let slot: Slot
        switch (after, before, at) {
        case (let anchor?, nil, nil): slot = .after(anchor)
        case (nil, let anchor?, nil): slot = .before(anchor)
        case (nil, nil, "start"): slot = .start
        case (nil, nil, "end"): slot = .end
        case (nil, nil, .some): throw ArgumentFailure(message: "at must be \"start\" or \"end\".")
        default:
            throw ArgumentFailure(message: "Pass exactly one of \(afterKey), \(beforeKey) or at.")
        }
        if slot.anchor == id { throw ArgumentFailure(message: "A \(noun) can't move next to itself.") }
        return slot
    }

    /// The name of the GATHERING a book id names, when THIS client can read
    /// it (P-VX196-2) — nil for anything else (a book, a gathering it cannot
    /// read, a missing id).
    func readableGathering(_ bookID: String, clientName: String) throws -> String?? {
        try database.read { db in
            guard let facts = try Queries.mcpGatheringFacts(db, readingID: bookID),
                  MCPGrantAuthority.decide(try MCPGrantAuthority.standing(db, clientName: clientName),
                                           gathering: facts).isAllowed
            else { return nil }
            return .some(try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
        }
    }

    /// A CHAPTER's act: decided on its book at `rung` (`onBook` — a chapter id
    /// naming nothing, or a deleted one, is the one answer on the book's noun).
    func onChapter(
        _ sectionID: String, rung: MCPGrantRule.Rung, job: Job, clientName: String,
        _ act: (_ bookID: String, _ bookName: String?) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let bookID = try database.read { try Queries.mcpBookOf(section: sectionID, $0) } ?? ""
        return try onBook(bookID, rung: rung, job: job, clientName: clientName, spendsAfter: false) { name in
            try act(bookID, name)
        }
    }

    /// `move_note_in_book`'s guard: the book AND the note at EDIT on one
    /// standing read (`guardBookAndNote`), then the ANCHOR — readable to this
    /// client (non-consuming READ — an unreadable one is the one answer) and a
    /// live member of this book.
    private func guardNoteMove(_ clientName: String, bookID: String, noteID: String, anchor: String?) -> Operations.WriteGuard {
        let sides = guardBookAndNote(clientName, bookID: bookID, noteID: noteID, rung: .edit)
        return { db in
            try sides(db)
            guard let anchor else { return }
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let decision = MCPGrantAuthority.decide(
                standing, note: try Queries.mcpNoteFacts(db, noteID: anchor), rung: .read, consumes: false)
            guard decision.isAllowed else { throw Self.refused(decision, .note) }
            let member = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM reading_post WHERE reading_id = ? AND post_id = ?
                                   AND deleted_at IS NULL AND status = 'member')
                    """,
                arguments: [bookID, anchor]) ?? false
            guard member else { throw Refused(outcome: Outcome(text: Self.notInBookWords, isError: true)) }
        }
    }

    // MARK: - The decisions

    /// A BOOK's act, decided on the book at `rung` (the snapshot — the
    /// refusal and the ask; the act's guard re-decides and spends, so
    /// `spendsAfter: false` on every act here). A gathering the client can
    /// read hears its own sentence (P-VX196-2); anything else unreachable is
    /// the one answer.
    func onBook(
        _ bookID: String, rung: MCPGrantRule.Rung, job: Job, clientName: String,
        spendsAfter: Bool = true, _ act: (_ name: String?) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let (standing, facts, gathering, name) = try database.read { db in
            let facts = try Queries.mcpBookFacts(db, readingID: bookID)
            let gathering = facts == nil ? try Queries.mcpGatheringFacts(db, readingID: bookID) : nil
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts, gathering,
                    facts == nil && gathering == nil
                        ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
        }
        if let gathering, MCPGrantAuthority.decide(standing, gathering: gathering).isAllowed {
            try log(clientName, job.tool, "book", bookID, name, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.gatheringWords(name), isError: true)))
        }
        let decision = MCPGrantAuthority.decide(standing, book: facts, rung: rung, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = decision else {
            try log(clientName, job.tool, "book", bookID, name, allowed: false)
            let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .book, scopeID: bookID,
                                         title: name ?? "", rung: rung, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(decision, .book, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "book", id: bookID, title: name,
                        spending: consumesOnce && spendsAfter ? [grantID].compactMap { $0 } : []) {
            try act(name)
        }
    }

    /// Every BOOK the act touches, re-resolved on the act's own rows and
    /// decided at `rung` INSIDE its transaction; any once grant spent here,
    /// atomic with the act. A gathering, a fenced or a dead book answers the
    /// one `notShared` (the snapshot already said what a readable gathering is).
    func guardBooks(
        _ clientName: String, _ rung: MCPGrantRule.Rung, books: @escaping (Database) throws -> [String?]
    ) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            var spend = Set<String>()
            for bookID in try books(db) {
                let facts = try Queries.mcpBookFacts(db, readingID: bookID ?? "")
                let decision = MCPGrantAuthority.decide(standing, book: facts, rung: rung, consumes: true)
                guard case .allow(let grantID, let consumesOnce) = decision else {
                    throw Self.refused(decision, .book)
                }
                if consumesOnce, let grantID { spend.insert(grantID) }
            }
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }

    // MARK: - The serial body

    func performLibraryEdit(
        _ edit: LibraryEditJob, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch edit {
        case .renameBook(let bookID, let name):
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { _ in
                let result = try ops.renameBookForClient(
                    bookID, name: name, undoLabel: label(.bookName),
                    guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                // The receipt and the activity line name the book as it NOW reads.
                return (["book_id": bookID, "name": result.name, "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .bookName, targetID: bookID,
                                          targetTitle: result.name, detail: result.name,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
            }

        case .setFinished(let bookID, let finished):
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { name in
                let act: Operations.MCPWriteAct = finished ? .bookFinish : .bookReopen
                let result = try ops.setBookFinishedForClient(
                    bookID, finished: finished, undoLabel: label(act),
                    guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                // Never a count of what waited at the door (a count of rule
                // matches that are not members is P-13nb-U4-16's oracle class).
                return (["book_id": bookID, "finished": finished, "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: bookID, targetTitle: name,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
            }

        case .archiveBook(let bookID):
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { name in
                _ = try ops.archiveBookForClient(
                    bookID, undoLabel: label(.bookArchive), guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                return (["book_id": bookID, "archived": true],
                        MCPWriteReceipt(clientName: clientName, act: .bookArchive, targetID: bookID, targetTitle: name,
                                        show: .book(bookID: bookID, sectionID: nil)))
            }

        case .unarchiveBook(let bookID):
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { name in
                _ = try ops.unarchiveBookForClient(
                    bookID, undoLabel: label(.bookUnarchive), guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                return (["book_id": bookID, "archived": false],
                        MCPWriteReceipt(clientName: clientName, act: .bookUnarchive, targetID: bookID,
                                        targetTitle: name, show: .book(bookID: bookID, sectionID: nil)))
            }

        case .deleteBook(let bookID):
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { name in
                let result = try ops.deleteBookForClient(
                    bookID, undoLabel: label(.bookDelete), guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                return (["book_id": bookID, "deleted": true, "notes_released": result.releasedNotes,
                         "trash_days": TrashWindow.days],
                        MCPWriteReceipt(clientName: clientName, act: .bookDelete, targetID: bookID, targetTitle: name,
                                        detail: result.releasedNotes ? Self.releasedNotesDetail : nil))
            }

        case .removeNote(let bookID, let noteID):
            if let gathering = try readableGathering(bookID, clientName: clientName) {
                try log(clientName, job.tool, "book", bookID, gathering, allowed: false)
                return .failure(Refused(outcome: Outcome(text: Self.gatheringWords(gathering), isError: true)))
            }
            return try noteIntoBook(noteID, bookID, job: job, clientName: clientName, rung: .edit,
                                    spendsAfter: false) { title, bookName in
                let removal: Operations.MCPMembershipRemoval
                do {
                    removal = try ops.removeNoteFromBookForClient(
                        noteID, book: bookID, removeUndoLabel: label(.bookRemove),
                        releaseUndoLabel: label(.bookRelease),
                        guardedBy: guardBookAndNote(clientName, bookID: bookID, noteID: noteID, rung: .edit))
                } catch OperationError.postNotInReading {
                    throw Refused(outcome: Outcome(text: Self.notInBookWords, isError: true))
                }
                return (["note_id": noteID, "book_id": bookID, "removed": true, "released": removal.released,
                         "bookless": removal.bookless],
                        MCPWriteReceipt(clientName: clientName, act: removal.released ? .bookRelease : .bookRemove,
                                        targetID: noteID, targetTitle: title, detail: bookName,
                                        show: .book(bookID: bookID, sectionID: nil)))
            }

        case .moveNote(let bookID, let noteID, let slot):
            if let gathering = try readableGathering(bookID, clientName: clientName) {
                try log(clientName, job.tool, "book", bookID, gathering, allowed: false)
                return .failure(Refused(outcome: Outcome(text: Self.gatheringWords(gathering), isError: true)))
            }
            return try noteIntoBook(noteID, bookID, job: job, clientName: clientName, rung: .edit,
                                    spendsAfter: false, logsOnBook: true) { _, bookName in
                do {
                    try ops.moveNoteInBookForClient(
                        noteID, book: bookID, to: slot.insert, undoLabel: label(.bookOrder),
                        guardedBy: guardNoteMove(clientName, bookID: bookID, noteID: noteID, anchor: slot.anchor))
                } catch OperationError.postNotInReading {
                    throw Refused(outcome: Outcome(text: Self.notInBookWords, isError: true))
                } catch Operations.MCPLibraryRefusal.bookNotInManualOrder {
                    throw Refused(outcome: Outcome(text: Self.notInManualOrderWords, isError: true))
                }
                return (["note_id": noteID, "book_id": bookID, "moved": true],
                        MCPWriteReceipt(clientName: clientName, act: .bookOrder, targetID: bookID,
                                        targetTitle: bookName, show: .book(bookID: bookID, sectionID: nil)))
            }

        case .renameChapter(let sectionID, let name):
            return try onChapter(sectionID, rung: .edit, job: job, clientName: clientName) { bookID, bookName in
                let result = try ops.renameChapterForClient(
                    sectionID, name: name, undoLabel: label(.chapterName),
                    guardedBy: guardBooks(clientName, .edit) { db in [try Queries.mcpBookOf(section: sectionID, db)] })
                return (["section_id": sectionID, "book_id": bookID, "name": result.name, "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .chapterName, targetID: bookID,
                                          targetTitle: bookName, detail: result.name,
                                          show: .book(bookID: bookID, sectionID: sectionID))
                        : nil)
            }

        case .deleteChapter(let sectionID):
            return try onChapter(sectionID, rung: .edit, job: job, clientName: clientName) { bookID, bookName in
                let section = try ops.deleteChapterForClient(
                    sectionID, undoLabel: label(.chapterDelete),
                    guardedBy: guardBooks(clientName, .edit) { db in [try Queries.mcpBookOf(section: sectionID, db)] })
                return (["section_id": sectionID, "book_id": bookID, "deleted": true],
                        MCPWriteReceipt(clientName: clientName, act: .chapterDelete, targetID: bookID,
                                        targetTitle: bookName, detail: section.name,
                                        show: .book(bookID: bookID, sectionID: nil)))
            }

        case .moveChapter(let sectionID, let slot):
            return try onChapter(sectionID, rung: .edit, job: job, clientName: clientName) { bookID, bookName in
                do {
                    _ = try ops.moveChapterForClient(
                        sectionID, to: slot.insert, undoLabel: label(.chapterMove),
                        guardedBy: guardBooks(clientName, .edit) { db in [try Queries.mcpBookOf(section: sectionID, db)] })
                } catch OperationError.sectionNotFound {
                    throw Refused(outcome: Outcome(text: Self.notThisBooksChapterWords, isError: true))
                }
                let chapter = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT name FROM reading_section WHERE id = ?", arguments: [sectionID])
                }
                return (["section_id": sectionID, "book_id": bookID, "moved": true],
                        MCPWriteReceipt(clientName: clientName, act: .chapterMove, targetID: bookID,
                                        targetTitle: bookName, detail: chapter,
                                        show: .book(bookID: bookID, sectionID: sectionID)))
            }

        case .deleteNote(let noteID):
            // Her Trash road: the note and its saved versions, 30 days,
            // restorable — and one undo for her.
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                _ = try ops.deleteNoteForClient(
                    noteID, undoLabel: label(.noteDelete), guardedBy: guardEdit(clientName) { _ in [noteID] })
                return (["note_id": noteID, "deleted": true, "trash_days": TrashWindow.days],
                        MCPWriteReceipt(clientName: clientName, act: .noteDelete, targetID: noteID,
                                        targetTitle: title))
            }

        case .setNoteArchived(let noteID, let archived):
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                let act: Operations.MCPWriteAct = archived ? .noteArchive : .noteUnarchive
                let result = try ops.setNoteArchivedForClient(
                    noteID, archived: archived, undoLabel: label(act),
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
                return (["note_id": noteID, "archived": archived, "changed": result.changed],
                        result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: noteID, targetTitle: title,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : nil)
            }
        }
    }
}
