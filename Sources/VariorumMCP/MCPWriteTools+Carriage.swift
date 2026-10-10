import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE CARRIAGE's WRITE TOOLS** (13n-b U4 — R-13nb-14's keyboard bar,
/// R-13nb-18, R-13nb-26 b/f; AF-11): `put_back` and `set_entry_date` on the
/// EDIT rung, `save_version`, `file_note_in_chapter` (PROVISIONAL) and
/// `set_book_rule` on WRITE NEW. Thin projections of `Operations+MCPCarriage`
/// — her doors' own row work, each one client-named undo entry.
///
/// Every act here takes the in-transaction GUARD (AF-10 (a), carried to the
/// new acts of this unit): the snapshot decision (`spendsAfter: false`) speaks
/// the refusal and raises the ask; the guard re-decides on the act's own rows
/// inside its write transaction and spends any once grant there, atomically.
extension MCPWriteTools {
    enum CarriageJob: Sendable {
        case putBackBlock(blockID: String)
        case putBackTake(takeID: String)
        case setEntryDate(noteID: String, entryDate: String?)
        case saveVersion(noteID: String)
        case fileInChapter(noteID: String, bookID: String, sectionID: String?)
        case setBookRule(bookID: String, write: Operations.MCPBookRuleWrite)

        var tool: String {
            switch self {
            case .putBackBlock, .putBackTake: MCPToolCatalog.putBack.name
            case .setEntryDate: MCPToolCatalog.setEntryDate.name
            case .saveVersion: MCPToolCatalog.saveVersion.name
            case .fileInChapter: MCPToolCatalog.fileNoteInChapter.name
            case .setBookRule: MCPToolCatalog.setBookRule.name
            }
        }
    }

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseCarriage(_ name: String, _ args: [String: Value]) throws -> CarriageJob? {
        switch name {
        case MCPToolCatalog.putBack.name:
            switch (try optionalString(args, "block_id"), try optionalString(args, "take_id")) {
            case (let block?, nil): return .putBackBlock(blockID: block)
            case (nil, let take?): return .putBackTake(takeID: take)
            default:
                throw ArgumentFailure(message: "Pass block_id (a deleted block) or take_id (a deleted take) — one of them.")
            }
        case MCPToolCatalog.setEntryDate.name:
            guard args.keys.contains("entry_date") else {
                throw ArgumentFailure(message: "entry_date is required: a day written yyyy-MM-dd, or null to clear it.")
            }
            return .setEntryDate(noteID: try requiredString(args, "note_id"), entryDate: try dayKey(args))
        case MCPToolCatalog.saveVersion.name:
            return .saveVersion(noteID: try requiredString(args, "note_id"))
        case MCPToolCatalog.fileNoteInChapter.name:
            guard args.keys.contains("section_id") else {
                throw ArgumentFailure(message: "section_id is required: a chapter of the book, or null to unfile the note.")
            }
            return .fileInChapter(
                noteID: try requiredString(args, "note_id"), bookID: try requiredString(args, "book_id"),
                sectionID: try optionalString(args, "section_id"))
        case MCPToolCatalog.setBookRule.name:
            var write = Operations.MCPBookRuleWrite()
            if let value = args["rule"] {
                write.rule = value == .null ? .some(nil) : .some(try MCPBookFacts.decodeRule(value))
            }
            if let value = args["outflow"], value != .null {
                guard let items = value.arrayValue else { throw ArgumentFailure(message: "outflow must be an array of tag paths.") }
                write.outflowPaths = try items.map { item in
                    guard let path = item.stringValue else { throw ArgumentFailure(message: "outflow must hold tag paths.") }
                    return path.hasPrefix("#") ? String(path.dropFirst()) : path
                }
            }
            switch try optionalString(args, "new_matches") {
            case nil: break
            case "join": write.seating = .auto
            case "wait": write.seating = .arrivals
            default: throw ArgumentFailure(message: "new_matches must be \"join\" (join quietly at the end) or \"wait\" (wait at Arrivals).")
            }
            guard write.rule != nil || write.outflowPaths != nil || write.seating != nil else {
                throw ArgumentFailure(message: "Pass rule, outflow or new_matches — at least one.")
            }
            return .setBookRule(bookID: try requiredString(args, "book_id"), write: write)
        default:
            return nil
        }
    }

    /// `entry_date`: a real day (`yyyy-MM-dd`) or null — the column's own shape.
    private func dayKey(_ args: [String: Value]) throws -> String? {
        guard let value = args["entry_date"], value != .null else { return nil }
        guard let raw = value.stringValue else { throw ArgumentFailure(message: "entry_date must be a string or null.") }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        guard raw.count == 10, let day = formatter.date(from: raw), formatter.string(from: day) == raw else {
            throw ArgumentFailure(message: "entry_date must be a real day written yyyy-MM-dd (e.g. 2019-03-04).")
        }
        return raw
    }

    // MARK: - The serial body

    func performCarriage(_ carriage: CarriageJob, job: Job, ops: Operations, clientName: String) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch carriage {
        case .putBackBlock(let blockID):
            // The tray's home while it is deleted; its placement once it is
            // back (so the op's own "already back" answer speaks, decided on
            // the note it is back in).
            let home = try database.read {
                try Queries.mcpTrayHome(block: blockID, $0) ?? Queries.mcpContainerOf(block: blockID, $0)
            }
            return try onNote(home ?? "", rung: .edit, job: job, clientName: clientName,
                              logged: ("block", blockID), spendsAfter: false) { title in
                let noteID = home ?? ""
                let landing = try ops.putBackBlock(
                    blockID, undoLabel: label(.putBack),
                    guardedBy: trayGuard(clientName) { db in
                        // Re-resolved on the act's own rows: the tray's home
                        // while it is deleted; its placement once it is back
                        // (so the op's own "already back" answer speaks).
                        try Queries.mcpTrayHome(block: blockID, db) ?? Queries.mcpContainerOf(block: blockID, db)
                    } inTray: { db, home, now in
                        // A block still deleted must be ONE OF ITS NOTE'S
                        // TRAY'S (her tray panel's population — 30 days, no
                        // purge intent, never a cascade victim of a deleted
                        // note).
                        guard try Queries.mcpTrayHome(block: blockID, db) != nil else { return true }
                        return try Queries.trayBlocks(db, postID: home, now: now)
                            .contains { $0.blockID == blockID }
                    })
                let where_: String = switch landing {
                case .itsOldPlace: "its_old_place"
                case .endOfNote: "end_of_note"
                case .unplaced: "unplaced"
                }
                return (["block_id": blockID, "note_id": noteID, "landed": where_],
                        MCPWriteReceipt(clientName: clientName, act: .putBack, targetID: noteID,
                                        targetTitle: title, detail: "a block",
                                        show: where_ == "unplaced" ? nil
                                            : .note(noteID: noteID, blockID: blockID, select: nil)))
            }

        case .putBackTake(let takeID):
            let home = try database.read {
                try Queries.mcpTrayHome(take: takeID, $0) ?? Queries.mcpContainerOf(take: takeID, $0)
            }
            return try onNote(home ?? "", rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let noteID = home ?? ""
                let status = try ops.putBackTake(
                    takeID, undoLabel: label(.putBack),
                    guardedBy: trayGuard(clientName) { db in
                        try Queries.mcpTrayHome(take: takeID, db) ?? Queries.mcpContainerOf(take: takeID, db)
                    } inTray: { db, home, now in
                        guard try Queries.mcpTrayHome(take: takeID, db) != nil else { return true }
                        return try Queries.trayTakes(db, postID: home, now: now)
                            .contains { $0.variantID == takeID }
                    })
                let blockID = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT block_id FROM variant WHERE id = ?", arguments: [takeID])
                }
                return (["take_id": takeID, "note_id": noteID, "archived": status == .archived],
                        MCPWriteReceipt(clientName: clientName, act: .putBack, targetID: noteID,
                                        targetTitle: title, detail: "a take",
                                        show: blockID.map { .takes(noteID: noteID, blockID: $0) }))
            }

        case .setEntryDate(let noteID, let entryDate):
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                let changed = try ops.setNoteEntryDate(
                    noteID, entryDate: entryDate, undoLabel: label(.entryDate),
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
                return (["note_id": noteID, "entry_date": entryDate ?? NSNull(), "changed": changed],
                        changed
                        ? MCPWriteReceipt(clientName: clientName, act: .entryDate, targetID: noteID,
                                          targetTitle: title, detail: entryDate,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : nil)
            }

        case .saveVersion(let noteID):
            return try onNote(noteID, rung: .writeNew, job: job, clientName: clientName, spendsAfter: false) { title in
                let result = try ops.saveVersion(
                    of: noteID, undoLabel: label(.version),
                    guardedBy: guardNotes(clientName, rung: .writeNew) { _ in [noteID] })
                return (["note_id": noteID, "version_id": result.post.id,
                         "saved_at": DateFormatter.variorumISO8601.string(from: result.post.createdAt)],
                        MCPWriteReceipt(clientName: clientName, act: .version, targetID: noteID, targetTitle: title,
                                        show: .note(noteID: noteID, blockID: nil, select: nil)))
            }

        case .fileInChapter(let noteID, let bookID, let sectionID):
            return try into(.book(bookID), job: job, clientName: clientName, spendsAfter: false) { _ in
                let changed = try ops.fileNoteInChapter(
                    noteID, book: bookID, section: sectionID, undoLabel: label(.filing),
                    guardedBy: { db in
                        // The book AND the note, each at write new (the
                        // add_note_to_book double decision — a note the
                        // client cannot reach is never reorganized).
                        try guardBook(clientName, bookID)(db)
                        try guardNotes(clientName, rung: .writeNew) { _ in [noteID] }(db)
                    })
                let names = try database.read { db -> (note: String?, chapter: String?) in
                    (try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                     try sectionID.flatMap {
                         try String.fetchOne(db, sql: "SELECT name FROM reading_section WHERE id = ?", arguments: [$0])
                     })
                }
                return (["note_id": noteID, "book_id": bookID, "section_id": sectionID ?? NSNull(), "changed": changed],
                        changed
                        ? MCPWriteReceipt(clientName: clientName, act: .filing, targetID: noteID,
                                          targetTitle: names.note, detail: names.chapter,
                                          show: .book(bookID: bookID, sectionID: sectionID))
                        : nil)
            }

        case .setBookRule(let bookID, let write):
            return try into(.book(bookID), job: job, clientName: clientName, spendsAfter: false) { _ in
                let result: Operations.MCPBookRuleResult
                do {
                    result = try ops.setBookRule(
                        bookID, write, undoLabel: label(.bookRule), guardedBy: guardBook(clientName, bookID))
                } catch Operations.MCPBookRuleRefusal.storedRuleUnreadable {
                    throw Refused(outcome: Outcome(text: MCPBookFacts.unreadableRuleWords, isError: true))
                }
                let (facts, name) = try database.read { db in
                    (try MCPBookFacts.facts(db, readingID: bookID),
                     try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
                }
                var answer = facts
                answer["book_id"] = bookID
                answer["changed"] = result.changed
                if result.mintedTags > 0 { answer["minted_tags"] = result.mintedTags }
                // AF-11 F-1: the answer SAYS when intake is paused — her Save
                // lands on a finished, sealed or archived book, and the
                // matches wait for the reopen.
                if !result.intakeRuns, result.after.querySpec != nil {
                    answer["intake_paused"] = MCPBookFacts.intakePausedWords
                }
                return (answer, result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .bookRule, targetID: bookID, targetTitle: name,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
            }
        }
    }

    /// `put_back`'s guard: the edit decision on the item's note, re-made on
    /// the act's own rows (the home re-resolved inside the transaction), and
    /// the tray-membership check — never a door her tray does not offer.
    private func trayGuard(
        _ clientName: String, home: @escaping (Database) throws -> String?,
        inTray: @escaping (Database, String, Date) throws -> Bool
    ) -> Operations.WriteGuard {
        let now = hooks.now()
        return { db in
            let noteID = try home(db)
            try guardEdit(clientName) { _ in [noteID] }(db)
            guard let noteID, try inTray(db, noteID, now) else {
                throw Refused(outcome: Outcome(text: Self.notInTrayWords, isError: true))
            }
        }
    }

    /// 13s-a sweepable (P-13nb-U4's words).
    static let notInTrayWords =
        "That isn't in the note's tray any more — deleted things wait there \(TrashWindow.days) days. "
        + "read_note with with_tray: true lists what is."
}

extension MCPBookFacts {
    /// Her rule editor's own notice for an unreadable stored rule
    /// (`RuleEditorCopy.malformedNotice`, verbatim — AF-11 F-1: refuse as her
    /// editor does).
    static let unreadableRuleWords =
        "This rule is stored in a form this version can\u{2019}t read, so it can\u{2019}t be edited here "
        + "\u{2014} nothing about it will be changed."

    /// The answer's sentence when a book's intake is paused (finished,
    /// sealed or archived). 13s-a sweepable.
    static let intakePausedWords =
        "Saved — this book isn't collecting right now (it's finished or archived), so new matches wait "
        + "until the author reopens it."
}
