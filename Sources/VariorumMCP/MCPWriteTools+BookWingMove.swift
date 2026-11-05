import Foundation
import GRDB
import MCP
import VariorumCore

/// **`move_book_to_wing`** (VX-807 — the VX-809 run, batch 2; her R-807: "the
/// app's confirm shows HER everything; the WIRE's answer reach-scopes" — "the
/// op answers what the app's confirm shows: the notes that come, the
/// memberships cut, the waiting arrivals dismissed"). The author's own Move to
/// Wing ▸ for a book on the wire: her op (`Operations.mcpMoveBookToWing` wraps
/// `moveReadingToWing` whole), ONE client-named undo entry with an exact-row
/// inverse (A-809-14).
///
/// **A-809-2 — two decisions, each on its own side (`move_note_to_wing`'s R1,
/// one level up):** the BOOK at EDIT through the ordinary rule (a book or wing
/// grant reaching it — a fenced book, the daily Journal among them, answers
/// the one not-shared shape); the DESTINATION wing at WRITE NEW through
/// `decideWing`. The snapshot decides both first and raises ONE ask, the
/// book's first; the guard decides both AGAIN inside the act's transaction on
/// one standing read and stamps the once grants of both sides as one union.
///
/// **A-809-16 (P-809-11):** a GATHERING does not move on the wire — its wing is
/// what every grant on it reaches. A gathering the client can read hears its
/// sentence; one it can't, the one shape (`set_book_rule`'s road, A-648-5).
/// **R-805-5:** the daily Journal refuses at the wire whatever her op does —
/// its book facts are fenced, so the one shape answers first, and the op's own
/// belt stands behind it (`MCPBookMoveRefusal.dailyJournal`).
///
/// **The answer (R-807 + R-825's law):** what her confirm shows, REACH-SCOPED —
/// the notes that came that the client can read (archived ones said), each
/// severed stay-behind membership whose note AND book it can read, the waiting
/// notes it can read that were dismissed, the destination's readable twins of
/// the book's name — with `beyond_reach`, the one fixed sentence (P-809-1);
/// nothing hidden named, counted or id-leaked; no position key. Her receipt
/// counts every note (hers).
///
/// **Refusals whose cause is beyond reach (A-809-4):** a member held by a
/// finished or sealed stay-behind book is said in her door's words where the
/// client can read the note AND that book (decided over the readable pairs in
/// the op's order, so a readable cause wins), else the book move's one fixed
/// sentence; a member whose fence the move would shed (A-809-15) always speaks
/// that sentence (the fencing book is always unreadable).
extension MCPWriteTools {
    /// A-809-16's sentence (PROVISIONAL, the gathering sentence's family).
    static func gatheringMoveWords(_ name: String?) -> String {
        let named = name.map { "\u{201C}\($0)\u{201D}" } ?? "That"
        return "\(named) is a gathering \u{2014} it shows the notes its rule matches in its own wing, so moving "
            + "it would change which notes it gathers and what any grant on it reaches. Moving a gathering is "
            + "the author's, in Variorum."
    }

    /// R-805-5's belt, said (unreachable while the daily Journal's book facts
    /// are fenced — the one shape answers first). PROVISIONAL.
    static let dailyJournalMoveWords = "The daily Journal moves only by the author's hand, in Variorum."

    /// The answer's list cap (the door's 200 — `lensListCap`'s precedent).
    static let bookMoveListCap = 200

    func performBookWingMove(
        bookID: String, wingID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, bookFacts, gathering, bookName, wingName) = try database.read { db in
            let facts = try Queries.mcpBookFacts(db, readingID: bookID)
            let gathering = facts == nil ? try Queries.mcpGatheringFacts(db, readingID: bookID) : nil
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts, gathering,
                    facts == nil && gathering == nil
                        ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar),
                    try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar))
        }
        if let gathering, MCPGrantAuthority.decide(standing, gathering: gathering).isAllowed {
            try log(clientName, job.tool, "book", bookID, bookName, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.gatheringMoveWords(bookName), isError: true)))
        }
        let onBook = MCPGrantAuthority.decide(standing, book: bookFacts, rung: .edit, consumes: true)
        guard onBook.isAllowed else {
            try log(clientName, job.tool, "book", bookID, bookName, allowed: false)
            let ask = bookFacts.map { MCPAsk(clientName: clientName, scopeKind: .book, scopeID: bookID,
                                             title: bookName ?? "", rung: .edit, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onBook, .book, standing: standing, ask: ask)))
        }
        let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard onWing.isAllowed else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onWing, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "book", id: bookID, title: bookName,
                        logsReceiptTitle: false) {
            let moved: Operations.MCPBookWingMove
            do {
                moved = try ops.mcpMoveBookToWing(
                    bookID, to: wingID, undoLabel: Operations.MCPWriteAct.bookWingMove.undoLabel(client: clientName),
                    guardedBy: guardBookWingMove(clientName, bookID: bookID, wingID: wingID),
                    reach: Self.readReach(standing))
            } catch let error as OperationError {
                if let refused = try bookFrozenWords(error, bookID: bookID, bookName: bookName, standing: standing) {
                    throw refused
                }
                throw error
            } catch let refusal as Operations.MCPBookMoveRefusal {
                throw Refused(outcome: Outcome(text: Self.bookMoveRefusalWords(refusal, bookName: bookName),
                                               isError: true))
            }
            let wingTitle = wingName ?? Queries.mcpHomeWingName
            let answer: [String: Any] = [
                "moved": true, "book_id": bookID, "wing_id": wingID,
                "landed": Self.bookLandedWords(wingTitle: wingTitle, isHome: wingID.isEmpty),
                "notes": moved.notes, "archived_notes": moved.archivedNotes,
                "left_books": moved.leftBooks.prefix(Self.bookMoveListCap).map {
                    ["note_id": $0.noteID, "book_id": $0.bookID, "name": $0.name]
                },
                "left_books_count": moved.leftBooks.count,
                "dismissed_arrivals": moved.dismissedArrivals,
                "same_name_in_wing": moved.twins.map { ["book_id": $0.bookID, "name": $0.name] },
                Self.beyondReachKey: Self.beyondReachWords,
            ]
            // The receipt's target is the DESTINATION wing (the note move's
            // coalescing key); its count is HER count — every note that came.
            return (answer, MCPWriteReceipt(
                clientName: clientName, act: .bookWingMove, targetID: wingID, targetTitle: wingTitle,
                detail: bookName, count: moved.move.notes, show: .book(bookID: bookID, sectionID: nil)))
        }
    }

    /// A-809-2's guard: the book at EDIT and the destination wing at WRITE NEW,
    /// decided again on ONE standing read inside the act's transaction; the
    /// once grants of both sides stamped as one union, there and only there.
    func guardBookWingMove(_ clientName: String, bookID: String, wingID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let onBook = MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .edit, consumes: true)
            guard case .allow(let bookGrant, let spendBook) = onBook else { throw Self.refused(onBook, .book) }
            let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
            guard case .allow(let wingGrant, let spendWing) = onWing else { throw Self.refused(onWing, .wing) }
            let spend = Set([spendBook ? bookGrant : nil, spendWing ? wingGrant : nil].compactMap { $0 })
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }

    /// What the answer may name or count: the one rule at READ, never
    /// consuming, over the standing that authorized the act (the snapshot's —
    /// `move_note_to_wing`'s `left_books` rule), on the act's own rows read
    /// inside its transaction before her body.
    static func readReach(_ standing: MCPGrantAuthority.Standing) -> Operations.MCPReadReach {
        { db, target in
            switch target {
            case .note(let id):
                MCPGrantAuthority.decide(
                    standing, note: try Queries.mcpNoteFacts(db, noteID: id), rung: .read, consumes: false
                ).isAllowed
            case .reading(let id):
                MCPGrantAuthority.decide(standing, reading: try MCPGrantAuthority.readPlace(db, readingID: id))
                    .isAllowed
            }
        }
    }

    /// The wire's own refusals of a book move, in words.
    static func bookMoveRefusalWords(_ refusal: Operations.MCPBookMoveRefusal, bookName: String?) -> String {
        switch refusal {
        case .wouldShedAFence: bookMoveHiddenCauseWords
        case .dailyJournal: dailyJournalMoveWords
        case .gathering: gatheringMoveWords(bookName)
        // Only a replay (her ⌥⌘Z / ⇧⌥⌘Z) throws it; her face words it there.
        case .changedSince: bookMoveHiddenCauseWords
        }
    }

    /// **A frozen stay-behind book, reach-pure (A-809-4 — the note move's S-2,
    /// one level up):** decided over the stay-behind member rows whose NOTE and
    /// BOOK the client can read, in the op's own order — the first finished or
    /// sealed one is named, by her hook's words, or (no hook) the op's own
    /// refusal keyed to THAT book; when none is readable, the book move's one
    /// fixed sentence. Read after the act's transaction rolled back, so it is
    /// the store as the act found it. nil for any other error.
    private func bookFrozenWords(
        _ error: OperationError, bookID: String, bookName: String?, standing: MCPGrantAuthority.Standing
    ) throws -> Refused? {
        switch error {
        case .lockedReading, .readingSealed: break
        default: return nil
        }
        let reach = Self.readReach(standing)
        let frozen = try database.read { db in
            try Queries.bookMoveStayBehind(db, readingID: bookID).first { row in
                guard row.finished || row.sealed else { return false }
                return try reach(db, .note(row.noteID)) && reach(db, .reading(row.bookID))
            }
        }
        guard let frozen else { return Refused(outcome: Outcome(text: Self.bookMoveHiddenCauseWords, isError: true)) }
        if let hook = hooks.bookMoveFrozenWords, let bookName {
            return Refused(outcome: Outcome(text: hook(bookName, frozen.noteTitle, frozen.bookName), isError: true))
        }
        let keyed: OperationError = frozen.sealed
            ? .readingSealed(id: frozen.bookID) : .lockedReading(id: frozen.bookID)
        return Refused(outcome: Outcome(
            text: MCPWireRefusalCopy.spoken(keyed, appWords: hooks.refusalWords), isError: true))
    }

    /// Where a moved book lands — unshelved on that wing's Bookcase. Home is a
    /// place-name, never quoted (`landedWords`' rule).
    static func bookLandedWords(wingTitle: String, isHome: Bool) -> String {
        "unshelved on the Bookcase of " + (isHome ? "Home" : "\u{201C}\(wingTitle)\u{201D}")
    }
}
