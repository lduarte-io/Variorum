import Foundation
import GRDB
import MCP
import VariorumCore

/// **`duplicate_note` — her Duplicate on the wire** (VX-311, VX-336
/// U6a — the run record's D-311-1…8 and the orchestrator's rulings on the
/// forks). A thin projection of `Operations.duplicateNoteForClient` (her op's
/// body, one transaction, ONE client-named undo entry). Why it exists: Compare
/// lines its rows up by shared `derived_from` lineage, and a `create_note` draft
/// shares none — a duplicate keeps block-by-block lineage, so Compare aligns.
///
/// **VX-371 (VX-383 U2 — D-C-4): the BOOK ROAD and `with_tags`.** Her words
/// (#227): *"it seems weird to me that if an AI creates a note it can put it in
/// a book with write new but it can't do that for a note it duplicated."* With
/// `book_id` (+ optional `section_id`) the landing side is `create_note`'s BOOK
/// decision — WRITE NEW on that book — in place of the wing's, and the copy is
/// FILED there in the same act (the one body: the book's gates and chapter, the
/// copy, the membership with the outflow, then the tags); a book of ANOTHER
/// wing reads as no book at all (the ONE not-shared shape, no ask — books never
/// span wings and the copy is born in the source's). Without `book_id`, the
/// wing road below stands byte-for-byte. `with_tags` (default true — her
/// door's default, P-C-3) chooses `DuplicateTags`: applied tags are heard by
/// the books that collect by them, as when she tags (VX-372).
///
/// **Where the copy lands, and what reach decides it (P-VX311-2, F-1 (a)):**
/// her door's copy lands BOOKLESS in the source's wing (that wing's Pool), so
/// the reach is `move_note_to_wing`'s two-sided shape, applied:
/// - the SOURCE: the note at READ through the ordinary rule (any note, book or
///   wing grant reaching it, or the open book) — a copy reads its content, so a
///   once READ grant is spent by it (AF-7 as amended);
/// - the LANDING: the source's (resolved) wing at WRITE NEW through
///   `decideWing` — a wing grant on THAT wing. A book grant can never name where
///   a bookless note lands, and the open book is read only: a client whose
///   write new is only a book hears the wing's refusal and the wing's ask.
///
/// **The fence (P-VX311-1, F-2 (a)):** a fenced source the client CAN read (its
/// own live per-ask grant) refuses in ONE sentence that names no leg, minting
/// nothing — the copy would keep the journal-profile leg but shed the daily
/// Journal's membership, a Private book's membership and the note's own
/// Private mark (no MCP road writes `ai_private_at` — R-VX184-2), so the copy
/// would reach further than the note does (P-13nb-U4-16's principle). An
/// UNREACHED fenced note never gets past the rule: the one not-shared shape.
///
/// The snapshot decides both sides (the source first) and raises ONE ask; the
/// act runs behind a guard that decides both AGAIN — the fence included — on
/// one standing read inside its own write transaction and stamps the once
/// grants of both sides there as ONE union (both spend or neither; a refused
/// act spends nothing) — `guardWingMove`'s shape.
///
/// **The answer (P-VX311-3, F-3/F-4 (a)):** VX-252's records of what the copy
/// MINTED (`MCPMintedBlocks` — the copy's active takes in fan order, the shown
/// take, and each block's `source_block_id`), `block_ids` beside them (F-6),
/// and where it landed in `move_note_to_wing`'s words. The receipt's Open ›
/// opens the COPY, like every note-minting act (F-5 (a)). P1: the decisions ∝
/// one note + one wing; the write and its answer ∝ the copied note.
extension MCPWriteTools {
    /// THE FENCE's one sentence (D-311-3) — no leg named (technical register,
    /// the MCP room's; PROVISIONAL words, her copy pass — VX-234).
    static let duplicateFencedWords =
        "This note is shared with you only per ask, so it can't be duplicated \u{2014} a copy would reach further "
        + "than the note does. The author can duplicate it in Variorum."

    // MARK: - The parse (VX-371)

    /// `note_id`, and VX-371's three: `with_tags` (a boolean, default true —
    /// the read tools' sentence for anything else), `book_id`, and
    /// `section_id` with `book_id` only (`create_note`'s rule and sentence,
    /// said at the parse before any decision).
    func parseDuplicateNote(_ args: [String: Value]) throws -> Job {
        let noteID = try requiredString(args, "note_id")
        var withTags = true
        if let value = args["with_tags"], value != .null {
            guard let bool = value.boolValue else { throw ArgumentFailure(message: "with_tags must be true or false.") }
            withTags = bool
        }
        let bookID = try optionalString(args, "book_id")
        let sectionID = try optionalString(args, "section_id")
        if sectionID != nil, bookID == nil { throw ArgumentFailure(message: Self.sectionWithoutBookWords) }
        return .duplicateNote(noteID: noteID, withTags: withTags, bookID: bookID, sectionID: sectionID)
    }

    // MARK: - The serial body

    func performDuplicateNote(
        noteID: String, withTags: Bool, bookID: String?, sectionID: String?, job: Job, ops: Operations,
        clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, facts, title, wingName) = try database.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                    facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                    try facts.flatMap { try Queries.mcpScopeTitle(db, kind: .wing, id: $0.wingID, calendar: calendar) })
        }
        let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
        guard onNote.isAllowed, let facts else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                         title: title ?? "", rung: .read, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onNote, .note, standing: standing, ask: ask)))
        }
        // The fence BEFORE the landing: a fenced copy refuses whatever the
        // landing allows, so no landing ask is raised for an act that can
        // never land.
        guard facts.fence == nil else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.duplicateFencedWords, isError: true)))
        }
        let wingID = facts.wingID
        let tags: Operations.DuplicateTags = withTags ? .applied : .none
        let undoLabel = Operations.MCPWriteAct.duplicate.undoLabel(client: clientName)

        // VX-371 — THE BOOK ROAD: `create_note`'s book decision on the landing.
        if let bookID {
            let (bookFacts, bookName) = try database.read { db in
                let raw = try Queries.mcpBookFacts(db, readingID: bookID)
                return (Self.inWing(raw, wingID),
                        raw == nil ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
            }
            let onBook = MCPGrantAuthority.decide(standing, book: bookFacts, rung: .writeNew, consumes: true)
            guard onBook.isAllowed else {
                try log(clientName, job.tool, "book", bookID, bookName, allowed: false)
                let ask = bookFacts.map { MCPAsk(clientName: clientName, scopeKind: .book, scopeID: bookID,
                                                 title: bookName ?? "", rung: .writeNew, fence: $0.fence) }
                return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                    .refusal(onBook, .book, standing: standing, ask: ask)))
            }
            let filing = Operations.DuplicateFiling(bookID: bookID, sectionID: sectionID)
            return try land(job, clientName: clientName, kind: "book", id: bookID, title: bookName,
                            logsReceiptTitle: false) {
                let made = try ops.duplicateNoteForClient(
                    noteID, tags: tags, filing: filing, undoLabel: undoLabel,
                    guardedBy: guardDuplicate(clientName, noteID: noteID, bookID: bookID))
                return try duplicateAnswer(
                    made, sourceID: noteID, filing: filing, bookName: bookName, poolWords: "",
                    standing: standing, clientName: clientName)
            }
        }

        // THE WING ROAD (VX-311 — byte-for-byte): her door's landing, bookless
        // in the source's wing, decided at WRITE NEW on that wing.
        let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard onWing.isAllowed else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onWing, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "note", id: noteID, title: title, logsReceiptTitle: false) {
            let made = try ops.duplicateNoteForClient(
                noteID, tags: tags, filing: nil, undoLabel: undoLabel,
                guardedBy: guardDuplicate(clientName, noteID: noteID, bookID: nil))
            return try duplicateAnswer(
                made, sourceID: noteID, filing: nil, bookName: nil,
                poolWords: Self.landedWords(wingTitle: wingName ?? Queries.mcpHomeWingName, isHome: wingID.isEmpty),
                standing: standing, clientName: clientName)
        }
    }

    /// **The answer and the receipt** — VX-252's records of what the copy
    /// MINTED (+ `source_block_id`), `block_ids` (F-6), and (VX-371) every tag
    /// the copy wears once it lands (`tag_ids` + `tags`, P-VX361-1's shape,
    /// read inside the act), the `book_id`/`section_id` given, and `landed`.
    /// The receipt targets the COPY (Open › opens it — P-VX311-3) and names the
    /// book it was filed into. P1: ∝ the copy and its books.
    private func duplicateAnswer(
        _ made: Operations.MCPDuplicate, sourceID: String, filing: Operations.DuplicateFiling?,
        bookName: String?, poolWords: String, standing: MCPGrantAuthority.Standing, clientName: String
    ) throws -> Act {
        let copy = made.copy
        let others = made.memberBookIDs.filter { $0 != filing?.bookID }
        let (copyTitle, chapterName, named) = try database.read { db in
            let chapter = try filing?.sectionID.flatMap { id in
                try String.fetchOne(db, sql: "SELECT name FROM reading_section WHERE id = ?", arguments: [id])
            }
            // A book intake seated the copy in is NAMED only where this client
            // can read it (names stay with grants, AF-10 (f) — `move_note_to_
            // wing`'s `left_books`); the rest are counted.
            let named: [String?] = try others.map { id in
                guard MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: id), rung: .read).isAllowed
                else { return nil }
                return try Queries.mcpScopeTitle(db, kind: .book, id: id, calendar: calendar)
            }
            return (try Queries.mcpScopeTitle(db, kind: .note, id: copy.post.id, calendar: calendar), chapter, named)
        }
        var answer: [String: Any] = [
            "note_id": copy.post.id, "source_note_id": sourceID,
            "block_ids": copy.blocks.map(\.blockID), "blocks": MCPMintedBlocks.records(copy.blocks),
            "tag_ids": made.tagIDs, "tags": made.tagPaths,
            "landed": Self.duplicateLandedWords(
                filedIn: filing.map { _ in bookName ?? "the book" }, chapter: chapterName, poolWords: poolWords,
                alsoIn: named.compactMap { $0 }, unnamed: named.filter { $0 == nil }.count),
        ]
        if let filing {
            answer["book_id"] = filing.bookID
            if let sectionID = filing.sectionID { answer["section_id"] = sectionID }
        }
        return (answer, MCPWriteReceipt(
            clientName: clientName, act: .duplicate, targetID: copy.post.id, targetTitle: copyTitle,
            detail: filing == nil ? nil : bookName,
            show: .note(noteID: copy.post.id, blockID: nil, select: nil)))
    }

    /// **Where the copy is, in words** (VX-371 — PROVISIONAL P-U2-1, VX-234's
    /// pass): filed — "the end of “B”" (`create_note`'s "it joins the book at
    /// its end"), with ", in its chapter “C”"; not filed — the wing road's
    /// Pool words, unless a book collecting one of its applied tags took it in.
    /// Every book that took it in by a tag follows, named where this client
    /// can read it and counted where it can't ("a book not shared with you").
    /// An ARRIVAL is no membership: a book ringing for the copy is not said.
    static func duplicateLandedWords(
        filedIn book: String?, chapter: String?, poolWords: String, alsoIn named: [String], unnamed: Int
    ) -> String {
        var items = named.map { "\u{201C}\($0)\u{201D}" }
        if unnamed == 1 { items.append("a book not shared with you") }
        if unnamed > 1 { items.append("\(unnamed) books not shared with you") }
        let total = named.count + unnamed
        let tookIn: String? = items.isEmpty ? nil : {
            let list = items.count == 1
                ? items[0] : items.dropLast().joined(separator: ", ") + " and " + items[items.count - 1]
            return list + (total == 1 ? ", which collects one of its tags" : ", which collect its tags")
        }()
        guard let book else { return tookIn ?? poolWords }
        let filed = "the end of \u{201C}\(book)\u{201D}" + (chapter.map { ", in its chapter \u{201C}\($0)\u{201D}" } ?? "")
        return tookIn.map { filed + ", and " + $0 } ?? filed
    }

    /// A book of ANOTHER wing reads as no book (VX-371): books never span
    /// wings and the copy is born in the source's — so it answers the ONE
    /// not-shared shape, byte-identical to an id naming nothing, and raises no
    /// ask (no grant could make it the landing). Both wings RESOLVED (a
    /// dangling pointer reads as Home — the facts' own rule).
    static func inWing(_ facts: MCPGrantRule.BookFacts?, _ wingID: String) -> MCPGrantRule.BookFacts? {
        facts.flatMap { $0.wingID == wingID ? $0 : nil }
    }

    /// The guard: the source at READ (and unfenced) and the LANDING — the
    /// book at WRITE NEW (VX-371, in the source's wing) or else the source's
    /// wing at WRITE NEW — decided again on ONE standing read inside the act's
    /// transaction; the once grants of both sides stamped as one union, there
    /// and only there.
    func guardDuplicate(_ clientName: String, noteID: String, bookID: String?) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            guard case .allow(let noteGrant, let spendNote) = onNote, let facts else {
                throw Self.refused(onNote, .note)
            }
            guard facts.fence == nil else {
                throw Refused(outcome: Outcome(text: Self.duplicateFencedWords, isError: true))
            }
            let onLanding: MCPGrantRule.Decision
            let landing: MCPRefusalCopy.Target
            if let bookID {
                onLanding = MCPGrantAuthority.decide(
                    standing, book: Self.inWing(try Queries.mcpBookFacts(db, readingID: bookID), facts.wingID),
                    rung: .writeNew, consumes: true)
                landing = .book
            } else {
                onLanding = MCPGrantAuthority.decideWing(standing, wingID: facts.wingID, rung: .writeNew, consumes: true)
                landing = .wing
            }
            guard case .allow(let landingGrant, let spendLanding) = onLanding else {
                throw Self.refused(onLanding, landing)
            }
            let spend = Set([spendNote ? noteGrant : nil, spendLanding ? landingGrant : nil].compactMap { $0 })
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }
}
