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
            // VX-275 (her ruling (a) — the VX-246 record's U3): an act that
            // meets a take her open editor may hold unflushed waits for HER
            // FLUSH first — its own turn, before the act's, never inside it —
            // so her typing is in the rows the act reads, rewrites, copies,
            // freezes or tombstones. Whatever the target (the flush's cost
            // never depends on the id named), and only once the call parsed.
            if job.flushesHerEditorFirst, let beforeWrite = hooks.beforeWrite {
                await beforeWrite(job.tool)
            }
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
        /// VX-253: the picks (`take_ids`) and, optionally, a rule that fills
        /// every block the picks don't cover (`MCPWriteTools+LensRule`).
        case saveLens(noteID: String, name: String, takeIDs: [String], rule: LensRule?)
        /// U3 (R-13nb-11 G-2): EITHER payload — plain prose, or the
        /// wire-document subset — and an optional entry date (R-13nb-26 (b)).
        /// VX-252: an optional chapter of the book (`section_id`).
        case createNote(title: String?, payload: NotePayload, entryDate: String?, place: Place, sectionID: String?)
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
        /// VX-336 U5b (VX-255): blocks added to a note — at its end at write
        /// new, anywhere at edit (`MCPWriteTools+InsertBlocks`).
        case insertBlocks(noteID: String, place: BlockInsertPlace, blocks: [Operations.MCPNoteBlock])
        /// VX-336 U6a (VX-311): her Duplicate on the wire — the copy bookless in
        /// the source's wing (`MCPWriteTools+DuplicateNote`). VX-371 (VX-383
        /// U2): `with_tags` (default true) and the book road (`book_id`, with
        /// an optional `section_id`).
        case duplicateNote(noteID: String, withTags: Bool, bookID: String?, sectionID: String?)
        /// VX-596: her star on the wire — a note or a book, starred or not
        /// (`MCPWriteTools+Star`).
        case setStarred(target: StarTarget, starred: Bool)

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
            case .insertBlocks: "insert_blocks"
            case .duplicateNote: "duplicate_note"
            case .setStarred: "set_starred"
            }
        }

        /// **VX-275 — does this act meet a take her open editor may hold
        /// unflushed?** True for the act list the VX-246 record's U3 trace
        /// argues, tool by tool: an act that TOMBSTONES her take (her flush
        /// would then be refused — her bytes stranded in memory), FREEZES it
        /// (a lock or an archive refuses her flush the same way), REWRITES or
        /// RESTRUCTURES it (it reads the STORED row, so her flush would write
        /// her old buffer over the act, or into a block it released), or
        /// COPIES it (a commit or a version would miss her last words — her
        /// own ⌘S and Save Version flush first). Every family answers through
        /// an exhaustive switch, so a new tool cannot compile without saying.
        var flushesHerEditorFirst: Bool {
            switch self {
            case .edit(let job): job.flushesHerEditorFirst
            case .carriage(let job): job.flushesHerEditorFirst
            case .deliberate(let job): job.flushesHerEditorFirst
            case .batch(let job): job.flushesHerEditorFirst
            case .noteEdit(let job): job.flushesHerEditorFirst
            case .libraryEdit(let job): job.flushesHerEditorFirst
            // New takes, comments, lenses, notes, books, tags and links touch
            // no take's text: her flush lands where she typed it.
            case .addTake, .addComment, .saveLens, .createNote, .importNote, .importBook, .applyTag,
                 .createBook, .addNoteToBook, .deleteComment, .removeTag, .linkVersions:
                false
            // VX-255 (the run record's D8): new blocks, and no take's text
            // read, rewritten, copied, frozen or tombstoned. Her caret's block
            // survives the act (same take, live, unlocked, same place), so her
            // flush lands where she typed and the editor's full render restores
            // her caret by identity; her open tail stays below the stored
            // blocks and crystallizes after the run, where the screen showed it.
            case .insertBlocks:
                false
            // VX-596: a star is a setting-list entry (and a book's column) —
            // no take's text read, rewritten, copied, frozen or tombstoned.
            case .setStarred:
                false
            // VX-311 (the run record's D-311-6, argued from VX-246 U3's COPY
            // row): a duplicate COPIES every take of the note — `copyPlacements`
            // reads the stored `working_text` rows — so it would miss her last
            // words while answering success; her own Duplicate as Version
            // flushes first (every door rides `AppSession.runCopying(from:)`,
            // 13e E10's "THE COPY FAMILY'S ONE ENTRY"). The same class as
            // `save_version`, so the same answer.
            case .duplicateNote:
                true
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
            let takeIDs = try stringArray(args, "take_ids")
            if let takeIDs, Set(takeIDs).count != takeIDs.count {
                throw ArgumentFailure(message: "take_ids lists a take twice.")
            }
            // VX-253: three explicit fills, never a magic word — the picks,
            // a label, or pin_chosen; the picks may ride either rule.
            let rule = try parseLensRule(args)
            guard takeIDs != nil || rule != nil else { throw ArgumentFailure(message: Self.noLensFillWords) }
            return .saveLens(
                noteID: try requiredString(args, "note_id"), name: try requiredText(args, "name"),
                takeIDs: takeIDs ?? [], rule: rule)
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
            // VX-252 (D2): a chapter is a chapter OF the book the note joins —
            // said at the parse, before any decision (independent of any target).
            let sectionID = try optionalString(args, "section_id")
            if sectionID != nil, try optionalString(args, "book_id") == nil {
                throw ArgumentFailure(message: Self.sectionWithoutBookWords)
            }
            return .createNote(
                title: try optionalString(args, "title"), payload: payload,
                entryDate: try entryDate(args), place: try place(args), sectionID: sectionID)
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
        case MCPToolCatalog.insertBlocks.name:
            return try parseInsertBlocks(args)
        case MCPToolCatalog.duplicateNote.name:
            return try parseDuplicateNote(args)
        case MCPToolCatalog.setStarred.name:
            return try parseSetStarred(args)
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

    /// The structured payload: `[{text, name?, takes?: [{text, label?}]}]` —
    /// `create_note`'s, and (VX-255) `insert_blocks`' one block parse.
    func noteBlocks(_ value: Value) throws -> [Operations.MCPNoteBlock] {
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
            throw ArgumentFailure(message: Self.entryDateWords)
        }
        return raw
    }

    /// `entry_date`'s one sentence — the parse's, and (VX-362) the op's own
    /// `invalidEntryDate` on the wire (`MCPWireRefusalCopy`): two validators,
    /// one sentence.
    static let entryDateWords = "entry_date must be a real day written yyyy-MM-dd (e.g. 2019-03-04)."

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
                // VX-254 (D-254-2): the digest of the text the act stored.
                return (["take_id": take.id, "block_id": blockID, "note_id": note,
                         "sha256": MCPTextDigest.sha256(take.workingText)],
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
        case .saveLens(let noteID, let name, let takeIDs, let rule):
            return try onNote(noteID, rung: .suggest, job: job, clientName: clientName) { title in
                var picks = try picks(noteID: noteID, takeIDs: takeIDs)
                var answer: [String: Any] = [:]
                // VX-253: the picks FIRST; the rule fills only the blocks they
                // don't cover — inside this closure, so only after the decision
                // allowed the note (an unreachable one never reaches the rule).
                if let rule {
                    let filled = try fillLens(rule, noteID: noteID, clientName: clientName, covered: Set(picks.keys))
                    picks.merge(filled.picks) { pick, _ in pick }
                    answer["unmatched_blocks"] = Array(filled.unmatched.prefix(Self.lensListCap))
                    answer["unmatched_count"] = filled.unmatched.count
                }
                let lens = try ops.saveLens(post: noteID, name: name, picks: picks, undoLabel: label(.lens))
                answer["lens_id"] = lens.id
                answer["note_id"] = noteID
                return (answer,
                        MCPWriteReceipt(clientName: clientName, act: .lens, targetID: noteID,
                                        targetTitle: title, detail: lens.name,
                                        show: .lens(noteID: noteID, lensID: lens.id)))
            }
        case .createNote(let title, let payload, let entryDate, let place, let sectionID):
            // VX-252 (F-3): the BOOK is decided first (`into`), so an
            // unreachable book answers the one not-shared sentence whatever
            // `section_id` names; inside, every id that isn't a live chapter of
            // THAT book speaks the one sentence its siblings speak
            // (`MCPWireRefusalCopy`) — hidden is never told from missing.
            // VX-549: a book id may name a GATHERING here — the note lands
            // bookless in its wing wearing what its rule needs (`into`'s
            // `admitsGathering`).
            return try into(place, job: job, clientName: clientName, admitsGathering: true) { destination in
                let minted: Operations.DocumentImport = switch payload {
                case .text(let text):
                    try ops.createNote(
                        title: title, text: text, entryDate: entryDate, in: destination, section: sectionID,
                        undoLabel: label(.note))
                case .blocks(let blocks):
                    try ops.createStructuredNote(
                        title: title, entryDate: entryDate, blocks: blocks, in: destination, section: sectionID,
                        undoLabel: label(.note))
                }
                return try noteAnswer(minted, act: .note, clientName: clientName, sectionID: sectionID)
            }
        case .importNote(let named, let place):
            return try into(place, job: job, clientName: clientName, admitsGathering: true) { destination in
                let minted = try ops.importNote(named, in: destination, undoLabel: label(.importNote))
                return try noteAnswer(minted, act: .importNote, clientName: clientName)
            }
        case .importBook(let book, let wingID):
            return try inWing(wingID, job: job, clientName: clientName) {
                // VX-363: the book's name is checked only against the books
                // this client can READ (VX-259's rule, on the third road that
                // names a book) — a hidden one neither blocks it nor is named.
                let result = try ops.importBook(
                    book, wingId: wingID, undoLabel: label(.importBook), namesCountedBy: readableBooks(clientName))
                return (["book_id": result.reading.id, "note_ids": result.postIDs, "chapter_ids": result.sectionIDs],
                        MCPWriteReceipt(clientName: clientName, act: .importBook, targetID: result.reading.id,
                                        targetTitle: result.reading.name, count: result.postIDs.count,
                                        show: .book(bookID: result.reading.id, sectionID: nil)))
            }
        case .applyTag(let noteID, let path):
            return try onNote(noteID, rung: .writeNew, job: job, clientName: clientName) { title in
                // VX-362 (a) (the run record's U9, F-2 — PROVISIONAL P-VX362-1):
                // a tag the note ALREADY wears is done, as at every tag door of
                // hers (seven catch `alreadyTagged` and move on — `TypedTagPath`:
                // "typing it again is a no-op, never an error"). The op threw, so
                // its transaction rolled back and it registered no undo entry;
                // the answer says `changed: false` and there is no receipt (a
                // receipt may only claim what landed). The Activity line is the
                // act's landed one, as every no-op on the wire logs.
                let tagID: String
                let changed: Bool
                do {
                    tagID = try ops.applyTagPath(path, toPost: noteID, undoLabel: label(.tag)).tagId
                    changed = true
                } catch OperationError.alreadyTagged(let worn, _) {
                    tagID = worn
                    changed = false
                }
                let tagPath = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [tagID])
                } ?? path
                return (["tag_id": tagID, "tag": tagPath, "note_id": noteID, "changed": changed],
                        changed
                            ? MCPWriteReceipt(clientName: clientName, act: .tag, targetID: noteID,
                                              targetTitle: title, detail: tagPath,
                                              show: .note(noteID: noteID, blockID: nil, select: nil))
                            : nil)
            }
        case .createBook(let name, let wingID):
            return try inWing(wingID, job: job, clientName: clientName) {
                let book = try ops.createBook(
                    named: name, inWing: wingID, undoLabel: label(.book), namesCountedBy: readableBooks(clientName))
                return (["book_id": book.id, "name": book.name],
                        MCPWriteReceipt(clientName: clientName, act: .book, targetID: book.id, targetTitle: book.name,
                                        show: .book(bookID: book.id, sectionID: nil)))
            }
        case .addNoteToBook(let noteID, let bookID, let sectionID):
            return try noteIntoBook(noteID, bookID, job: job, clientName: clientName) { title, bookName in
                let added = try ops.addNoteToBookForClient(
                    noteID, book: bookID, section: sectionID, undoLabel: label(.bookAdd))
                // VX-365 (VX-361's shape, P-VX361-1): every tag the note wears
                // once the act lands — its own, then the book's outflow, each
                // once — composed inside the act's transaction; `tags` their
                // paths, parallel. Always present (`[]` when none).
                var answer: [String: Any] = [
                    "note_id": noteID, "book_id": bookID, "tag_ids": added.tagIDs, "tags": added.tagPaths,
                ]
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
        case .insertBlocks(let noteID, let place, let blocks):
            return try performInsertBlocks(
                noteID: noteID, place: place, blocks: blocks, job: job, ops: ops, clientName: clientName)
        case .duplicateNote(let noteID, let withTags, let bookID, let sectionID):
            return try performDuplicateNote(
                noteID: noteID, withTags: withTags, bookID: bookID, sectionID: sectionID, job: job, ops: ops,
                clientName: clientName)
        case .setStarred(let target, let starred):
            return try performSetStarred(target, starred: starred, job: job, ops: ops, clientName: clientName)
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

    /// A note minted into a book or a wing — and, with `admitsGathering`
    /// (VX-549: `create_note` and `import_document`'s one document only — never
    /// `create_section` or `set_book_rule`, whose acts are a BOOK's), into a
    /// GATHERING named by its id in `book_id` (`intoGathering`).
    func into(
        _ place: Place, job: Job, clientName: String, spendsAfter: Bool = true, admitsGathering: Bool = false,
        _ act: (Operations.MCPNoteDestination) throws -> Act
    ) throws -> Result<Landed, Refused> {
        switch place {
        case .book(let bookID):
            let (standing, facts, name, gathering) = try database.read { db in
                let facts = try Queries.mcpBookFacts(db, readingID: bookID)
                return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                        try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar),
                        facts == nil && admitsGathering
                            ? try Queries.mcpGatheringFacts(db, readingID: bookID) : nil)
            }
            if let gathering {
                return try intoGathering(
                    gathering, name: name, standing: standing, job: job, clientName: clientName,
                    spendsAfter: spendsAfter, act)
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

    /// **A new note written INTO a gathering** (VX-549 — her sitting
    /// 2026-10-27, RATIFIED: "write_new mints the note bookless in the wing and
    /// applies the rule's tags so it assembles in"). The PLACE is decided at
    /// write new (`decideGathering` — its own grant or its wing's; a once grant
    /// spent by the landed write, AF-7); anything refused answers exactly as a
    /// book id does (`MCPRefusalCopy`'s `.book` noun — the client sent
    /// `book_id`, and a hidden gathering must read as a missing id), raising
    /// the just-in-time ask ON THE GATHERING where it exists unfenced (her
    /// answer can now mint a gathering grant). A refused row is logged as the
    /// book id the client sent (`list_my_activity` never tells a hidden
    /// gathering from a missing id); a landed one names the gathering. The act
    /// then plans inside its own transaction (`Operations.mintNoteEntry`'s
    /// gathering arm) and a rule only a star could satisfy refuses in her
    /// door's words through the ONE chain (`MCPWireRefusalCopy`) — never the
    /// not-shared shape. `spendsAfter` as the book arm's (the ladder's round
    /// 1, finding 3 — symmetry: a caller whose guard re-decides and spends
    /// inside the act's own transaction passes `false`; no tool admitting a
    /// gathering does today).
    private func intoGathering(
        _ facts: MCPGrantRule.BookFacts, name: String?, standing: MCPGrantAuthority.Standing, job: Job,
        clientName: String, spendsAfter: Bool, _ act: (Operations.MCPNoteDestination) throws -> Act
    ) throws -> Result<Landed, Refused> {
        let decision = MCPGrantAuthority.decide(standing, gathering: facts, rung: .writeNew, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = decision else {
            try log(clientName, job.tool, "book", facts.id, name, allowed: false)
            let ask = facts.fence == nil
                ? MCPAsk(clientName: clientName, scopeKind: .gathering, scopeID: facts.id, title: name ?? "",
                         rung: .writeNew, fence: nil)
                : nil
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(decision, .book, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "gathering", id: facts.id, title: name,
                        spending: consumesOnce && spendsAfter ? [grantID].compactMap { $0 } : []) {
            try act(.gathering(facts.id))
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
            // VX-357 — THE DOOR SAYS IT, in its one place: a landed write whose
            // text held U+0000 names how many the store's rule removed
            // (`MCPNullCharacters`); a write with none answers byte-unchanged.
            var answer = landed.answer
            let removed = job.nullCharactersWritten
            if removed > 0 { answer[MCPNullCharacters.answerKey] = removed }
            return .success(Landed(answer: try encode(answer), receipt: landed.receipt))
        } catch let refused as Refused {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            return .failure(refused)
        } catch let failure as ArgumentFailure {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: failure.message, isError: true)))
        } catch {
            try log(clientName, job.tool, kind, id, title, allowed: false)
            let words = MCPWireRefusalCopy.spoken(error, appWords: hooks.refusalWords)
            return .failure(Refused(outcome: Outcome(text: words, isError: true)))
        }
    }

    /// AF-7: the once grant is spent by the write that landed (inside the
    /// same serial body, so no second call can slip between).
    func spend(_ grantID: String) throws {
        try database.write { db in try grants.consumeMCPOnceGrant(db, grantID) }
    }

    /// **The statement `picks` resolves the given take ids with — P1 by
    /// construction** (VX-280; VX-184's ladder round 2 measured the shape it
    /// replaced): the GIVEN ids drive, each finding its take by key and then
    /// its block's ONE live placement through `uq_cblock_ownership` — ∝ the
    /// takes given, never the note's blocks. **`CROSS JOIN`, twice, on
    /// purpose** (the house's P1 discipline for `json_each` —
    /// `placedBlocksSQL`, `Queries.ownershipFactsSQL`): with plain JOINs the
    /// planner drove from the note's placements (`idx_cblock_order`), then
    /// every take of each block (`idx_variant_block`), with `json_each`
    /// scanned innermost. A `CROSS JOIN` keeps its left table outside its
    /// right, so the only order left is ids → take → placement. Membership
    /// per id is the old statement's (a live take of a block live-placed in
    /// this note), so every refusal `picks` speaks is unchanged. Pinned on the
    /// plan (`MCPPicksPlanTests`). Two placeholders: the ids as a JSON array,
    /// then the note.
    static let picksSQL = """
        SELECT v.id, v.block_id FROM json_each(?) j
        CROSS JOIN variant v ON v.id = j.value AND v.deleted_at IS NULL
        CROSS JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
        WHERE cb.container_id = ?
        """

    /// **The books a name check counts on the wire** (VX-259 — VX-184's ladder
    /// round 1; her ruling: "it's fine if an accidental book name duplicate is
    /// made - there's no schema protection against it and we already ruled
    /// that it's ok if that happens"): a reading counts only while THIS client
    /// can READ it now — the one rule `list_books` reads (a book at read under
    /// its grants or the open book, never a fenced one; a gathering under its
    /// wing's reach) — so `rename_book`, `create_book` and (VX-363)
    /// `import_document`'s book form never refuse with,
    /// or because of, a book the client cannot reach (F-7: anything it can't
    /// reach answers as if it did not exist). Non-consuming: a name check
    /// never spends a once grant. Asked inside the act's transaction, only of
    /// a reading whose name collides.
    func readableBooks(_ clientName: String) -> Operations.BookNameReach {
        { db, readingID in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            return MCPGrantAuthority.decide(
                standing, reading: try MCPGrantAuthority.readPlace(db, readingID: readingID)
            ).isAllowed
        }
    }

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

    /// A minted note's answer: its id, `block_ids` (kept — F-6), its tags, and
    /// VX-252's `blocks` — every block's shown take and every take it was born
    /// with (`MCPMintedBlocks`, the one shape). `section_id` echoes a chapter
    /// the note was filed under (`add_note_to_book`'s echo).
    ///
    /// VX-361 (the run record's U9, F-1 (a) — PROVISIONAL P-VX361-1):
    /// `tag_ids` is EVERY tag the note wears when the act lands — the header's
    /// in header order, then the ones a book's outflow applied, in outflow
    /// order (composed inside the act's transaction) — and `tags` their paths,
    /// parallel: the wire's tag word, as `apply_tag` and `set_book_rule` speak
    /// it. The header's list stays the prefix, so no caller loses what it had.
    func noteAnswer(
        _ minted: Operations.DocumentImport, act: Operations.MCPWriteAct, clientName: String,
        sectionID: String? = nil
    ) throws -> Act {
        let title = try database.read { db in
            try Queries.mcpScopeTitle(db, kind: .note, id: minted.post.id, calendar: calendar)
        }
        var answer: [String: Any] = [
            "note_id": minted.post.id, "block_ids": minted.blockIDs, "tag_ids": minted.tagIDs,
            "tags": minted.tagPaths, "blocks": MCPMintedBlocks.records(minted.blocks),
        ]
        if let sectionID { answer["section_id"] = sectionID }
        // VX-596 (RB-1, PROVISIONAL): a note born starred into a gathering says
        // so — the star is one of the author's, the client never asked for it by
        // name. Absent otherwise, so every other answer stays byte-unchanged
        // (VX-357's `null_characters_removed` shape).
        if minted.starred { answer[Self.starredMintKey] = true }
        return (answer,
                MCPWriteReceipt(clientName: clientName, act: act, targetID: minted.post.id, targetTitle: title,
                                show: .note(noteID: minted.post.id, blockID: nil, select: nil)))
    }

    /// VX-596: the answer key a born-starred mint carries (read by the
    /// descriptions, never retyped).
    static let starredMintKey = "starred"

    /// VX-252 (D2): `create_note`'s `section_id` without a book to be a chapter of.
    static let sectionWithoutBookWords =
        "section_id goes with book_id: it files the note under a chapter of the book the note joins."

    /// **The take label on an AI take** (P-13n-3's convention, re-voiced by
    /// her VX-267 ruling — *"why do we need claude-code * suggested * english.
    /// isn't it obvious it's suggested if it's claude? seems like an extra
    /// word."*): the client's name, then ` · ` and the client's own label when
    /// it gives one (trimmed; a blank label is none) — so the fan always says
    /// who. Worn only by the takes a client adds at SUGGEST, inside her
    /// writing (`add_take`, `add_takes` — her VX-197 split); every other
    /// take-writing tool stores a label exactly as given. Takes labelled
    /// before VX-267 keep `‹client› · suggested · ‹label›` (labels are text —
    /// no migration); the lens rule's matcher reads both forms.
    static func aiLabel(client: String, own: String?) -> String {
        // VX-357: the client's label with U+0000 removed first (the store's
        // rule, `StoredText`), so a label of nothing else is none.
        guard let own = StoredText.stripped(own)?.trimmingCharacters(in: .whitespacesAndNewlines), !own.isEmpty
        else { return client }
        return client + labelSeparator + own
    }

    /// The separator inside an AI take's label (`aiLabel`'s) — a spaced
    /// middle dot.
    static let labelSeparator = " \u{00B7} "

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
