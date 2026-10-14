import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE SUGGEST AND WRITE-NEW RUNGS' tool projections** (13n-b U2 — R-13n-4;
/// the mockup §9's lean set). Thin projections of `Operations+MCPWrites` (the
/// acts, each registering ONE undo entry labeled with the client — R-13n-6),
/// each gated PER CALL by the pure rule over CURRENT facts.
///
/// **Every call is ONE serial body on the session's executor** (AF-8 — in the
/// app, her `OperationsRunner`): the decision is read, the act lands, the once
/// grant is stamped, and the activity line is written, with nothing of hers
/// able to interleave — a revocation from the pane, or her own gesture, runs
/// strictly before or after. Arguments are parsed BEFORE the executor (a
/// malformed call never queues behind her work). The once grant is stamped
/// AFTER the act lands (AF-7 as amended: spent by its first write of any
/// rung), so a refused act never spends it.
///
/// **Scope discipline:** a creative act lands INSIDE the grant's scope — a
/// note into a granted book or wing, a book into a granted wing, a membership
/// only when the note AND the book are both reachable at write new (adding an
/// unreachable note to a granted book would pull it into the client's reach —
/// an escalation the double check forbids). The SUGGEST acts address blocks
/// and takes only inside the note the rule allowed.
struct MCPWriteTools: Sendable {
    let database: AppDatabase
    /// The host's grants-store operations (no undo stack): logging only.
    let grants: Operations
    let executor: any MCPWriteExecutor
    var hooks = MCPHostHooks()
    var calendar: Calendar = JournalDay.storeCalendar

    typealias Outcome = MCPReadTools.Outcome
    typealias ArgumentFailure = MCPReadTools.ArgumentFailure

    static let handledToolNames: Set<String> = Set(
        (MCPToolCatalog.suggest + MCPToolCatalog.writeNew + MCPToolCatalog.edit).map(\.name))

    func call(_ name: String, arguments: [String: Value]?, clientName: String) async -> Outcome {
        let args = arguments ?? [:]
        do {
            let job = try parse(name, args)
            let result: Result<Landed, Refused> = try await executor.run { ops in
                try self.perform(job, ops: ops, clientName: clientName)
            }
            switch result {
            case .success(let landed):
                if let receipt = landed.receipt { hooks.onWrite?(receipt) }
                return Outcome(text: landed.answer, isError: false)
            case .failure(let refused):
                return refused.outcome
            }
        } catch let failure as ArgumentFailure {
            return Outcome(text: failure.message, isError: true)
        } catch {
            return Outcome(text: "Variorum couldn't complete \(name): \(error)", isError: true)
        }
    }

    // MARK: - The parsed calls

    enum Job: Sendable {
        case addTake(blockID: String, text: String, label: String?)
        case addComment(blockID: String, text: String)
        case saveLens(noteID: String, name: String, takeIDs: [String])
        /// U3 (R-13nb-11 G-2): EITHER payload — plain prose, or the
        /// wire-document subset — and an optional entry date (R-13nb-26 (b)).
        case createNote(title: String?, payload: NotePayload, entryDate: String?, place: Place)
        case importNote(VariorumDocument.NamedDocument, place: Place)
        case importBook(VariorumDocument.Book, wingID: String)
        case applyTag(noteID: String, path: String)
        case createBook(name: String, wingID: String)
        case addNoteToBook(noteID: String, bookID: String, sectionID: String?)
        /// U3: the edit rung's jobs and `create_section` (`MCPWriteTools+Edit`).
        case edit(EditJob)
        /// U4: the carriage's write tools (`MCPWriteTools+Carriage`).
        case carriage(CarriageJob)
        /// VX-168 U2: the edit rung's deliberate acts (`MCPWriteTools+Deliberate`).
        case deliberate(DeliberateJob)
        /// VX-184 U3 (VX-173): the suggest rung's batch doors (`MCPWriteTools+Batches`).
        case batch(BatchJob)
        /// VX-184 U3 (VX-188): a client deleting its OWN comment (`MCPWriteTools+CommentDelete`).
        case deleteComment(commentID: String)
        /// VX-184 U3 (VX-190): un-tagging a note at edit (`MCPWriteTools+RemoveTag`).
        case removeTag(noteID: String, path: String)
        /// VX-184 U3 (VX-187): two notes linked as versions (`MCPWriteTools+LinkVersions`).
        case linkVersions(noteA: String, noteB: String, pairs: [Operations.MCPVersionPair])
        /// VX-184 U4 (VX-195): edit parity inside a note (`MCPWriteTools+NoteEdits`).
        case noteEdit(NoteEditJob)
        /// VX-184 U5 (VX-196): edit parity across the library (`MCPWriteTools+LibraryEdits`).
        case libraryEdit(LibraryEditJob)

        var tool: String {
            switch self {
            case .edit(let job): job.tool
            case .carriage(let job): job.tool
            case .deliberate(let job): job.tool
            case .batch(let job): job.tool
            case .noteEdit(let job): job.tool
            case .libraryEdit(let job): job.tool
            case .deleteComment: "delete_comment"
            case .removeTag: "remove_tag"
            case .linkVersions: "link_versions"
            case .addTake: "add_take"
            case .addComment: "add_comment"
            case .saveLens: "save_lens"
            case .createNote: "create_note"
            case .importNote, .importBook: "import_document"
            case .applyTag: "apply_tag"
            case .createBook: "create_book"
            case .addNoteToBook: "add_note_to_book"
            }
        }
    }

    /// `create_note`'s two payloads (R-13nb-11 G-2).
    enum NotePayload: Sendable, Equatable {
        /// Plain prose: each paragraph a block (the bulk rule — paste's road).
        case text(String)
        /// The wire-document subset: blocks as given (multi-paragraph
        /// welcome), with names and labeled takes.
        case blocks([Operations.MCPNoteBlock])
    }

    /// Where a creative act lands.
    enum Place: Sendable, Equatable {
        case book(String)
        case wing(String)
    }

    struct Landed: Sendable {
        let answer: String
        let receipt: MCPWriteReceipt?
    }

    struct Refused: Error, Sendable {
        let outcome: Outcome
    }

    private func parse(_ name: String, _ args: [String: Value]) throws -> Job {
        switch name {
        case MCPToolCatalog.addTake.name:
            // VX-168 U3 (VX-171 — R-VX171-2, her word, door-only): a BLANK
            // take is a legal take (the Mac's own blank-take gesture writes
            // `''`), so the text may be empty — but it must be SAID: no text
            // key at all is still no take.
            return .addTake(
                blockID: try requiredString(args, "block_id"), text: try presentString(args, "text"),
                label: try optionalString(args, "label"))
        case MCPToolCatalog.addComment.name:
            return .addComment(blockID: try requiredString(args, "block_id"), text: try requiredText(args, "text"))
        case MCPToolCatalog.saveLens.name:
            let takeIDs = try stringArray(args, "take_ids") ?? []
            guard Set(takeIDs).count == takeIDs.count else {
                throw ArgumentFailure(message: "take_ids lists a take twice.")
            }
            return .saveLens(
                noteID: try requiredString(args, "note_id"), name: try requiredText(args, "name"), takeIDs: takeIDs)
        case MCPToolCatalog.createNote.name:
            let text = try optionalString(args, "text")
            let blocksValue = args["blocks"].flatMap { $0 == .null ? nil : $0 }
            let payload: NotePayload
            switch (text, blocksValue) {
            case (let text?, nil): payload = .text(text)
            case (nil, let value?): payload = .blocks(try noteBlocks(value))
            case (.some, .some): throw ArgumentFailure(message: "Pass text or blocks, not both.")
            case (nil, nil): throw ArgumentFailure(message: "Pass text (plain prose) or blocks (structured).")
            }
            return .createNote(
                title: try optionalString(args, "title"), payload: payload,
                entryDate: try entryDate(args), place: try place(args))
        case MCPToolCatalog.importDocument.name:
            return try parseImport(args)
        case MCPToolCatalog.applyTag.name:
            return .applyTag(noteID: try requiredString(args, "note_id"), path: try requiredText(args, "tag"))
        case MCPToolCatalog.createBook.name:
            guard let wingID = try optionalString(args, "wing_id") else {
                throw ArgumentFailure(message: "wing_id is required (\"\" is Home).")
            }
            return .createBook(name: try requiredText(args, "name"), wingID: wingID)
        case MCPToolCatalog.addNoteToBook.name:
            return .addNoteToBook(
                noteID: try requiredString(args, "note_id"), bookID: try requiredString(args, "book_id"),
                sectionID: try optionalString(args, "section_id"))
        default:
            if let job = try parseEdit(name, args) { return .edit(job) }
            if let job = try parseCarriage(name, args) { return .carriage(job) }
            if let job = try parseDeliberate(name, args) { return .deliberate(job) }
            if let job = try parseBatch(name, args) { return .batch(job) }
            if name == MCPToolCatalog.deleteComment.name {
                return .deleteComment(commentID: try requiredString(args, "comment_id"))
            }
            if name == MCPToolCatalog.removeTag.name { return try parseRemoveTag(args) }
            if name == MCPToolCatalog.linkVersions.name { return try parseLinkVersions(args) }
            if let job = try parseNoteEdit(name, args) { return .noteEdit(job) }
            if let job = try parseLibraryEdit(name, args) { return .libraryEdit(job) }
            throw ArgumentFailure(message: "Unknown tool: \(name).")
        }
    }

    /// The structured payload: `[{text, name?, takes?: [{text, label?}]}]`.
    private func noteBlocks(_ value: Value) throws -> [Operations.MCPNoteBlock] {
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "blocks must be an array.") }
        return try items.enumerated().map { index, item in
            guard let fields = item.objectValue, let text = fields["text"]?.stringValue else {
                throw ArgumentFailure(message: "blocks[\(index)] needs a text.")
            }
            var name: String?
            if let value = fields["name"], value != .null {
                guard let string = value.stringValue else {
                    throw ArgumentFailure(message: "blocks[\(index)].name must be a string.")
                }
                name = string
            }
            var takes: [VariorumDocument.Take] = []
            if let value = fields["takes"], value != .null {
                guard let list = value.arrayValue else {
                    throw ArgumentFailure(message: "blocks[\(index)].takes must be an array.")
                }
                takes = try list.enumerated().map { takeIndex, take in
                    guard let takeFields = take.objectValue, let takeText = takeFields["text"]?.stringValue else {
                        throw ArgumentFailure(message: "blocks[\(index)].takes[\(takeIndex)] needs a text.")
                    }
                    let label = takeFields["label"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                    return VariorumDocument.Take(label: (label?.isEmpty ?? true) ? nil : label, text: takeText)
                }
            }
            return Operations.MCPNoteBlock(text: text, name: name, takes: takes)
        }
    }

    /// `entry_date`: a real calendar day, `yyyy-MM-dd` — the column's own
    /// shape (a journal entry's date).
    private func entryDate(_ args: [String: Value]) throws -> String? {
        guard let raw = try optionalString(args, "entry_date") else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        guard raw.count == 10, let day = formatter.date(from: raw), formatter.string(from: day) == raw else {
            throw ArgumentFailure(message: "entry_date must be a real day written yyyy-MM-dd (e.g. 2019-03-04).")
        }
        return raw
    }

    private func place(_ args: [String: Value]) throws -> Place {
        let bookID = try optionalString(args, "book_id")
        let wingID = try optionalString(args, "wing_id")
        switch (bookID, wingID) {
        case (let book?, nil): return .book(book)
        case (nil, let wing?): return .wing(wing)
        case (.some, .some): throw ArgumentFailure(message: "Pass book_id or wing_id, not both.")
        case (nil, nil): throw ArgumentFailure(message: "Pass book_id (a book) or wing_id (a wing; \"\" is Home).")
        }
    }

    /// One `document`, or one whole `book` (into a wing) — never both. A
    /// document that does not parse refuses with the parser's own line
    /// (fail-honest, the 13n-a doors' rule).
    private func parseImport(_ args: [String: Value]) throws -> Job {
        let document = try optionalString(args, "document")
        let bookValue = args["book"].flatMap { $0 == .null ? nil : $0 }
        switch (document, bookValue) {
        case (let text?, nil):
            return .importNote(
                VariorumDocument.NamedDocument(fallbackTitle: "", document: try parsed(text, label: "document")),
                place: try place(args))
        case (nil, let value?):
            guard try optionalString(args, "book_id") == nil else {
                throw ArgumentFailure(message: "A book imports into a wing: pass wing_id, not book_id.")
            }
            guard let wingID = try optionalString(args, "wing_id") else {
                throw ArgumentFailure(message: "A book imports into a wing: pass wing_id (\"\" is Home).")
            }
            guard let object = value.objectValue else { throw ArgumentFailure(message: "book must be an object.") }
            guard let name = object["name"]?.stringValue,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { throw ArgumentFailure(message: "book.name is required.") }
            var chapters: [VariorumDocument.Book.Chapter] = []
            for (index, chapter) in (object["chapters"]?.arrayValue ?? []).enumerated() {
                guard let fields = chapter.objectValue, let chapterName = fields["name"]?.stringValue else {
                    throw ArgumentFailure(message: "book.chapters[\(index)] needs a name.")
                }
                chapters.append(.init(
                    name: chapterName,
                    notes: try documents(fields["documents"], label: "book.chapters[\(index)].documents")))
            }
            let unfiled = try documents(object["documents"], label: "book.documents")
            let book = VariorumDocument.Book(name: name, chapters: chapters, unfiled: unfiled)
            guard book.noteCount > 0 else { throw ArgumentFailure(message: "The book holds no documents.") }
            return .importBook(book, wingID: wingID)
        case (.some, .some):
            throw ArgumentFailure(message: "Pass document or book, not both.")
        case (nil, nil):
            throw ArgumentFailure(message: "Pass document (one note) or book (a whole book).")
        }
    }

    private func documents(_ value: Value?, label: String) throws -> [VariorumDocument.NamedDocument] {
        guard let value, value != .null else { return [] }
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "\(label) must be an array.") }
        return try items.enumerated().map { index, item in
            guard let text = item.stringValue else { throw ArgumentFailure(message: "\(label)[\(index)] must be a string.") }
            return VariorumDocument.NamedDocument(fallbackTitle: "", document: try parsed(text, label: "\(label)[\(index)]"))
        }
    }

    private func parsed(_ text: String, label: String) throws -> VariorumDocument.Document {
        do {
            return try VariorumDocument.parse(text)
        } catch {
            let line = error.line.map { " at line \($0)" } ?? ""
            throw ArgumentFailure(message: "\(label) is not in the Variorum document format\(line): \(error.reason).")
        }
    }

    // MARK: - The serial body (decide → act → spend → log)

    private func perform(_ job: Job, ops: Operations, clientName: String) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch job {
        case .addTake(let blockID, let text, let takeLabel):
            return try onBlock(blockID, rung: .suggest, job: job, clientName: clientName) { note, title in
                let take = try ops.addTake(
                    toBlock: blockID, text: text, label: Self.aiLabel(client: clientName, own: takeLabel),
                    undoLabel: label(.take))
                return (["take_id": take.id, "block_id": blockID, "note_id": note],
                        MCPWriteReceipt(clientName: clientName, act: .take, targetID: note, targetTitle: title,
                                        show: .takes(noteID: note, blockID: blockID)))
            }
        case .addComment(let blockID, let text):
            return try onBlock(blockID, rung: .suggest, job: job, clientName: clientName) { note, title in
                // VX-188: the client is put on file as the comment's writer.
                let comment = try ops.addComment(
                    toBlock: blockID, text: text, author: clientName, undoLabel: label(.comment))
                return (["comment_id": comment.id, "block_id": blockID, "note_id": note],
                        MCPWriteReceipt(clientName: clientName, act: .comment, targetID: note, targetTitle: title,
                                        show: .note(noteID: note, blockID: blockID, select: nil)))
            }
        case .saveLens(let noteID, let name, let takeIDs):
            return try onNote(noteID, rung: .suggest, job: job, clientName: clientName) { title in
                let picks = try picks(noteID: noteID, takeIDs: takeIDs)
                let lens = try ops.saveLens(post: noteID, name: name, picks: picks, undoLabel: label(.lens))
                return (["lens_id": lens.id, "note_id": noteID],
                        MCPWriteReceipt(clientName: clientName, act: .lens, targetID: noteID,
                                        targetTitle: title, detail: lens.name,
                                        show: .lens(noteID: noteID, lensID: lens.id)))
            }
        case .createNote(let title, let payload, let entryDate, let place):
            return try into(place, job: job, clientName: clientName) { destination in
                let minted: Operations.DocumentImport = switch payload {
                case .text(let text):
                    try ops.createNote(
                        title: title, text: text, entryDate: entryDate, in: destination, undoLabel: label(.note))
                case .blocks(let blocks):
                    try ops.createStructuredNote(
                        title: title, entryDate: entryDate, blocks: blocks, in: destination, undoLabel: label(.note))
                }
                return try noteAnswer(minted, act: .note, clientName: clientName)
            }
        case .importNote(let named, let place):
            return try into(place, job: job, clientName: clientName) { destination in
                let minted = try ops.importNote(named, in: destination, undoLabel: label(.importNote))
                return try noteAnswer(minted, act: .importNote, clientName: clientName)
            }
        case .importBook(let book, let wingID):
            return try inWing(wingID, job: job, clientName: clientName) {
                let result = try ops.importBook(book, wingId: wingID, undoLabel: label(.importBook))
                return (["book_id": result.reading.id, "note_ids": result.postIDs, "chapter_ids": result.sectionIDs],
                        MCPWriteReceipt(clientName: clientName, act: .importBook, targetID: result.reading.id,
                                        targetTitle: result.reading.name, count: result.postIDs.count,
                                        show: .book(bookID: result.reading.id, sectionID: nil)))
            }
        case .applyTag(let noteID, let path):
            return try onNote(noteID, rung: .writeNew, job: job, clientName: clientName) { title in
                let application = try ops.applyTagPath(path, toPost: noteID, undoLabel: label(.tag))
                let tagPath = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [application.tagId])
                } ?? path
                return (["tag_id": application.tagId, "tag": tagPath, "note_id": noteID],
                        MCPWriteReceipt(clientName: clientName, act: .tag, targetID: noteID,
                                        targetTitle: title, detail: tagPath,
                                        show: .note(noteID: noteID, blockID: nil, select: nil)))
            }
        case .createBook(let name, let wingID):
            return try inWing(wingID, job: job, clientName: clientName) {
                let book = try ops.createBook(named: name, inWing: wingID, undoLabel: label(.book))
                return (["book_id": book.id, "name": book.name],
                        MCPWriteReceipt(clientName: clientName, act: .book, targetID: book.id, targetTitle: book.name,
                                        show: .book(bookID: book.id, sectionID: nil)))
            }
        case .addNoteToBook(let noteID, let bookID, let sectionID):
            return try noteIntoBook(noteID, bookID, job: job, clientName: clientName) { title, bookName in
                _ = try ops.addNoteToBook(noteID, book: bookID, section: sectionID, undoLabel: label(.bookAdd))
                var answer: [String: Any] = ["note_id": noteID, "book_id": bookID]
                if let sectionID { answer["section_id"] = sectionID }
                return (answer,
                        MCPWriteReceipt(clientName: clientName, act: .bookAdd, targetID: noteID,
                                        targetTitle: title, detail: bookName,
                                        show: .book(bookID: bookID, sectionID: sectionID)))
            }
        case .edit(let editJob):
            return try performEdit(editJob, job: job, ops: ops, clientName: clientName)
        case .carriage(let carriageJob):
            return try performCarriage(carriageJob, job: job, ops: ops, clientName: clientName)
        case .deliberate(let deliberateJob):
            return try performDeliberate(deliberateJob, job: job, ops: ops, clientName: clientName)
        case .batch(let batchJob):
            return try performBatch(batchJob, job: job, ops: ops, clientName: clientName)
        case .deleteComment(let commentID):
            return try performCommentDelete(commentID, job: job, ops: ops, clientName: clientName)
        case .removeTag(let noteID, let path):
            return try performRemoveTag(noteID: noteID, path: path, job: job, ops: ops, clientName: clientName)
        case .linkVersions(let noteA, let noteB, let pairs):
            return try performLinkVersions(
                noteA: noteA, noteB: noteB, pairs: pairs, job: job, ops: ops, clientName: clientName)
        case .noteEdit(let edit):
            return try performNoteEdit(edit, job: job, ops: ops, clientName: clientName)
        case .libraryEdit(let edit):
            return try performLibraryEdit(edit, job: job, ops: ops, clientName: clientName)
        }
    }

    /// An act's answer and its receipt — nil when the act wrote nothing (a
    /// U3 no-op edit or rename: a receipt may only claim what landed).
    typealias Act = (answer: [String: Any], receipt: MCPWriteReceipt?)

    /// A block's act: the block must be live-placed in a live, non-version
    /// note, and the RULE decides on that note. A block with no such note
    /// (released to lineage, in a scraps group, gone, a stranger's id) answers
    /// exactly as an unshared note — one answer, no existence oracle.
    func onBlock(
        _ blockID: String, rung: MCPGrantRule.Rung, job: Job, clientName: String,
        spendsAfter: Bool = true,
        _ act: (_ noteID: String, _ title: String?) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let noteID = try database.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT cb.container_id FROM container_block cb
                    JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                    WHERE cb.block_id = ? AND cb.deleted_at IS NULL
                    """,
                arguments: [blockID])
        }
        return try onNote(noteID ?? "", rung: rung, job: job, clientName: clientName,
                          logged: ("block", blockID), spendsAfter: spendsAfter) { title in
            try act(noteID ?? "", title)
        }
    }

    /// A note's act: decided on the note at `rung` (content-bearing — a once
    /// grant spends by its first write of any rung, AF-7 as amended; stamped
    /// AFTER the act lands). U3: `spendsAfter: false` for an act whose GUARD
    /// re-decides and spends inside the act's own transaction (the edit
    /// rung, `MCPWriteTools+Edit`) — this snapshot decision then only speaks
    /// the refusal and raises the ask.
    func onNote(
        _ noteID: String, rung: MCPGrantRule.Rung, job: Job, clientName: String,
        logged: (kind: String, id: String)? = nil, spendsAfter: Bool = true,
        _ act: (_ title: String?) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let logKind = logged?.kind ?? "note"
        let logID = logged?.id ?? noteID
        let (standing, facts, title) = try database.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                    facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar))
        }
        let decision = MCPGrantAuthority.decide(standing, note: facts, rung: rung, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = decision else {
            try log(clientName, job.tool, logKind, logID, title, allowed: false)
            let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                         title: title ?? "", rung: rung, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(decision, .note, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: logKind, id: logID, title: title,
                        spending: consumesOnce && spendsAfter ? [grantID].compactMap { $0 } : []) {
            try act(title)
        }
    }

    /// `add_note_to_book`: the NOTE and the BOOK both decided at write new
    /// before anything lands (adding an unreachable note to a granted book
    /// would pull it into the client's reach). A once grant authorizing BOTH
    /// (a once wing grant) is spent ONCE.
    ///
    /// Ladder round 1, F-2: `file_note_in_chapter` rides this same snapshot
    /// (with `spendsAfter: false` — its guard re-decides and spends inside
    /// the act's transaction), so BOTH its sides raise the just-in-time ask
    /// exactly as `add_note_to_book`'s do — the note side's refusal was a
    /// bare guard throw with no ask and no asked sentence, which mattered
    /// most for a FENCED member (a daily-Journal entry, a ⌘J entry or a
    /// Private note is reachable per-ask only, and she never heard the ask;
    /// since 13n-c T-2 the wire answers the one not-shared answer, the ask
    /// still reaching her).
    ///
    /// VX-184 U5: `rung` — the two decisions' rung (write new for the
    /// creative acts, as before; EDIT for `remove_note_from_book` /
    /// `move_note_in_book`, which change a book's membership or order), and
    /// `logsOnBook` — a landed act logged on the BOOK (its order changed),
    /// not the note. Defaults unchanged: every existing caller byte-identical.
    func noteIntoBook(
        _ noteID: String, _ bookID: String, job: Job, clientName: String,
        rung: MCPGrantRule.Rung = .writeNew, spendsAfter: Bool = true, logsOnBook: Bool = false,
        _ act: (_ title: String?, _ bookName: String?) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let (standing, noteFacts, title, bookFacts, bookName) = try database.read { db in
            let noteFacts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let bookFacts = try Queries.mcpBookFacts(db, readingID: bookID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), noteFacts,
                    noteFacts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                    bookFacts,
                    bookFacts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
        }
        let onNote = MCPGrantAuthority.decide(standing, note: noteFacts, rung: rung, consumes: true)
        guard case .allow(let noteGrant, let spendNote) = onNote else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            let ask = noteFacts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                             title: title ?? "", rung: rung, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onNote, .note, standing: standing, ask: ask)))
        }
        let onBook = MCPGrantAuthority.decide(standing, book: bookFacts, rung: rung, consumes: true)
        guard case .allow(let bookGrant, let spendBook) = onBook else {
            try log(clientName, job.tool, "book", bookID, bookName, allowed: false)
            let ask = bookFacts.map { MCPAsk(clientName: clientName, scopeKind: .book, scopeID: bookID,
                                             title: bookName ?? "", rung: rung, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onBook, .book, standing: standing, ask: ask)))
        }
        let spending = Set([spendNote ? noteGrant : nil, spendBook ? bookGrant : nil].compactMap { $0 })
        return try land(job, clientName: clientName, kind: logsOnBook ? "book" : "note",
                        id: logsOnBook ? bookID : noteID, title: logsOnBook ? bookName : title,
                        spending: spendsAfter ? spending.sorted() : []) {
            try act(title, bookName)
        }
    }

    /// A note minted into a book or a wing.
    func into(
        _ place: Place, job: Job, clientName: String, spendsAfter: Bool = true,
        _ act: (Operations.MCPNoteDestination) throws -> Act
    ) throws -> Result<Landed, Refused> {
        switch place {
        case .book(let bookID):
            let (standing, facts, name) = try database.read { db in
                (try MCPGrantAuthority.standing(db, clientName: clientName),
                 try Queries.mcpBookFacts(db, readingID: bookID),
                 try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
            }
            let decision = MCPGrantAuthority.decide(standing, book: facts, rung: .writeNew, consumes: true)
            guard case .allow(let grantID, let consumesOnce) = decision else {
                try log(clientName, job.tool, "book", bookID, name, allowed: false)
                let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .book, scopeID: bookID,
                                             title: name ?? "", rung: .writeNew, fence: $0.fence) }
                return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                    .refusal(decision, .book, standing: standing, ask: ask)))
            }
            return try land(job, clientName: clientName, kind: "book", id: bookID, title: name,
                            spending: consumesOnce && spendsAfter ? [grantID].compactMap { $0 } : []) {
                try act(.book(bookID))
            }
        case .wing(let wingID):
            return try inWing(wingID, job: job, clientName: clientName) { try act(.wing(wingID)) }
        }
    }

    /// A wing-scoped act (a note bookless in a wing, a new book, a whole
    /// imported book): wing-level reach at write new.
    func inWing(
        _ wingID: String, job: Job, clientName: String, _ act: () throws -> Act
    ) throws -> Result<Landed, Refused> {
        let (standing, wingName) = try database.read { db in
            (try MCPGrantAuthority.standing(db, clientName: clientName),
             try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar))
        }
        let decision = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = decision else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(decision, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "wing", id: wingID, title: wingName,
                        spending: consumesOnce ? [grantID].compactMap { $0 } : []) {
            try act()
        }
    }

    /// The act, its refusal in the app's own words, the once stamp(s) it
    /// spent, and the activity line. `spending` is stamped AFTER the act
    /// lands (a refused act never spends — AF-7) and never flips a landed
    /// act's answer: inside this serial body a spend can only fail on a grant
    /// already spent or revoked, which no later call can reuse. (The
    /// recorded corner, P-13nb-U2-8: a CRASH between a landed write and its
    /// stamp leaves the once grant unspent — one more write; the content
    /// reads keep U1's one-transaction stamp.)
    func land(
        _ job: Job, clientName: String, kind: String, id: String, title: String?,
        spending: [String] = [], logsReceiptTitle: Bool = true, _ act: () throws -> Act
    ) throws -> Result<Landed, Refused> {
        do {
            let landed = try act()
            for grantID in spending { try? spend(grantID) }
            // 13n-c U6, D-U6-2 (red-on-old): an act whose receipt titles
            // something other than the logged target (a wing move's receipt
            // names its DESTINATION, the sweep's coalescing key) logs its own.
            let logged = logsReceiptTitle ? landed.receipt?.targetTitle ?? title : title
            try log(clientName, job.tool, kind, id, logged, allowed: true)
            return .success(Landed(answer: try encode(landed.answer), receipt: landed.receipt))
        } catch let refused as Refused {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            return .failure(refused)
        } catch let failure as ArgumentFailure {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: failure.message, isError: true)))
        } catch {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            let words = MCPWireRefusalCopy.words(error) ?? hooks.refusalWords(error) ?? String(describing: error)
            return .failure(Refused(outcome: Outcome(text: words, isError: true)))
        }
    }

    /// AF-7: the once grant is spent by the write that landed (inside the
    /// same serial body, so no second call can slip between).
    func spend(_ grantID: String) throws {
        try database.write { db in try grants.consumeMCPOnceGrant(db, grantID) }
    }

    /// The statement `picks` resolves the given take ids with — two
    /// placeholders: the ids as a JSON array, then the note. (VX-280's
    /// pin reads its plan, `MCPPicksPlanTests`.)
    static let picksSQL = """
        SELECT v.id, v.block_id FROM json_each(?) j
        JOIN variant v ON v.id = j.value AND v.deleted_at IS NULL
        JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
        WHERE cb.container_id = ?
        """

    /// The lens's picks from take ids, resolved ONLY among the takes of THIS
    /// note's placed blocks — an id from anywhere else answers one way (no
    /// oracle on take ids), and two takes of one block refuse.
    func picks(noteID: String, takeIDs: [String]) throws -> [String: String] {
        let owners: [String: String] = try database.read { db in
            let json = String(decoding: try JSONEncoder().encode(takeIDs), as: UTF8.self)
            var owners: [String: String] = [:]
            for row in try Row.fetchAll(db, sql: Self.picksSQL, arguments: [json, noteID]) {
                owners[row["id"]] = row["block_id"]
            }
            return owners
        }
        var picks: [String: String] = [:]
        for takeID in takeIDs {
            guard let blockID = owners[takeID] else {
                throw ArgumentFailure(message: "take_id \(takeID) isn't a take of this note.")
            }
            guard picks[blockID] == nil else {
                throw ArgumentFailure(message: "A lens shows one take per block; take_ids names two takes of one block.")
            }
            picks[blockID] = takeID
        }
        return picks
    }

    func noteAnswer(
        _ minted: Operations.DocumentImport, act: Operations.MCPWriteAct, clientName: String
    ) throws -> Act {
        let title = try database.read { db in
            try Queries.mcpScopeTitle(db, kind: .note, id: minted.post.id, calendar: calendar)
        }
        return (["note_id": minted.post.id, "block_ids": minted.blockIDs, "tag_ids": minted.tagIDs],
                MCPWriteReceipt(clientName: clientName, act: act, targetID: minted.post.id, targetTitle: title,
                                show: .note(noteID: minted.post.id, blockID: nil, select: nil)))
    }

    /// **The take label on an AI take** (P-13n-3's convention, hers to
    /// re-voice at 13s-a): "<client> · suggested", then the client's own
    /// label when it gives one — so the fan always says who.
    static func aiLabel(client: String, own: String?) -> String {
        let base = "\(client) \u{00B7} suggested"
        guard let own = own?.trimmingCharacters(in: .whitespacesAndNewlines), !own.isEmpty else { return base }
        return "\(base) \u{00B7} \(own)"
    }

    // MARK: - Shared pieces

    func log(
        _ clientName: String, _ act: String, _ kind: String?, _ id: String?, _ title: String?, allowed: Bool
    ) throws {
        try database.write { db in
            try grants.recordMCPActivity(
                db, clientName: clientName, act: act, targetKind: kind, targetID: id,
                targetTitle: title, allowed: allowed)
        }
    }

    func encode(_ object: [String: Any]) throws -> String {
        // U4: an answer holding a non-JSON value (a `Date`, say) would raise
        // an Objective-C exception and take the APP down — refuse it as an
        // error instead.
        guard JSONSerialization.isValidJSONObject(object) else {
            throw MCPAnswerEncodingFailure()
        }
        return String(decoding: try JSONSerialization.data(
            withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
    }

    func requiredString(_ args: [String: Value], _ key: String) throws -> String {
        guard let value = try optionalString(args, key), !value.isEmpty else {
            throw ArgumentFailure(message: "\(key) is required.")
        }
        return value
    }

    /// Required to be PRESENT, and may be empty (VX-168 U3 — `add_take`'s
    /// blank take, R-VX171-2).
    func presentString(_ args: [String: Value], _ key: String) throws -> String {
        guard let value = try optionalString(args, key) else {
            throw ArgumentFailure(message: "\(key) is required.")
        }
        return value
    }

    /// Required AND not blank.
    func requiredText(_ args: [String: Value], _ key: String) throws -> String {
        let value = try requiredString(args, key)
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ArgumentFailure(message: "\(key) is required.")
        }
        return value
    }

    func optionalString(_ args: [String: Value], _ key: String) throws -> String? {
        guard let value = args[key], value != .null else { return nil }
        guard let string = value.stringValue else { throw ArgumentFailure(message: "\(key) must be a string.") }
        return string
    }

    func stringArray(_ args: [String: Value], _ key: String) throws -> [String]? {
        guard let value = args[key], value != .null else { return nil }
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "\(key) must be an array.") }
        return try items.map { item in
            guard let string = item.stringValue else { throw ArgumentFailure(message: "\(key) must hold strings.") }
            return string
        }
    }
}
