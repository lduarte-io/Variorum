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
/// **A GATHERING is read, never changed** (R-AIR-12; the record's call 3,
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

        var tool: String {
            switch self {
            case .renameBook: MCPToolCatalog.renameBook.name
            case .setFinished(_, let finished): finished ? MCPToolCatalog.finishBook.name : MCPToolCatalog.reopenBook.name
            case .archiveBook: MCPToolCatalog.archiveBook.name
            case .unarchiveBook: MCPToolCatalog.unarchiveBook.name
            case .deleteBook: MCPToolCatalog.deleteBook.name
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
            + "(remove_tag takes a tag off a note); renaming, archiving or deleting a gathering is the author\u{2019}s."
    }

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
        default:
            return nil
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
        }
    }
}
