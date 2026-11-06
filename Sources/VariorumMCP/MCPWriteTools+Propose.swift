import Foundation
import GRDB
import MCP
import VariorumCore

/// **`propose_notes_to_book` — a set of notes proposed to a book's Arrivals**
/// (VX-811 — the VX-808 run, Unit B2; her rulings, the run record
/// `notes/plans/fixes/vx-808-arrivals-books.md` §3: "let's let the AI do a mass
/// act that makes them wait, so you can use it as a way to go through a bunch
/// of notes"; "read level on everything should be able to propose … it's only
/// proposing i guess"; an OPTIONAL per-note reason; the fork's ruling
/// A-808-8).
///
/// The call is ALWAYS a list (`note_ids`, VX-812's grammar — no single form):
/// each item is its own act — the snapshot decision on the note and then the
/// book at READ (`noteIntoBook`: the one not-shared shape, the ask raised; the
/// fence keeps a Private book and THE daily Journal unreachable at read, so no
/// proposal ever names one), its own guard re-deciding inside the act's
/// transaction and spending any once grant that authorized it, its own Activity
/// line (a landed item logged on the BOOK, so a long call coalesces), its own
/// client-named undo entry, its receipt on the call's one run key. The op
/// (`Operations.proposeNoteToBook`) decides the verdict rows.
///
/// Purity (R-825): every verdict reads only the note and the book the client
/// reads — capacity and ownership are never consulted (an arrival is no
/// membership), so a book full of Private members or a note an unreadable owned
/// book claims proposes exactly as in a store without them, and the answer's
/// `waits` sentence is fixed (never conditional on any state).
extension MCPWriteTools {
    /// The always-present key (A-808-8) and its one sentence (PROVISIONAL —
    /// the B2 bundle).
    static let waitsKey = "waits"
    static let waitsWords =
        "Each landed note waits at the book's Arrivals until the author adds or dismisses it — nothing is in "
        + "the book until then, a full book still takes proposals, and a note the author dismissed may be "
        + "proposed again."

    /// A pair the note LEFT as a member — decided (PROVISIONAL P-808-B2-4).
    static let proposalLeftTheBookWords =
        "That note was in this book and was taken out, so it isn't proposed again \u{2014} the author can add "
        + "it back in Variorum."

    /// A gathering the client can read (an unreadable one is the one shape).
    /// PROVISIONAL (the B2 bundle).
    static func proposalGatheringWords(_ name: String?) -> String {
        let named = name.map { "\u{201C}\($0)\u{201D}" } ?? "That"
        return "\(named) is a gathering \u{2014} it shows the notes its rule matches and holds none of its own, "
            + "so nothing waits at its door: propose to a book instead."
    }

    /// A reason past the cap (PROVISIONAL P-808-B2-1).
    static func reasonCapWords(_ key: String, count: Int) -> String {
        "\(key) holds \(count) characters \u{2014} a reason holds at most \(ArrivalProvenance.reasonCap)."
    }

    // MARK: - The parse (before the executor)

    func parsePropose(_ args: [String: Value]) throws -> Job {
        guard let value = args["note_ids"], value != .null else {
            throw ArgumentFailure(message: "note_ids is required: 1 to \(Self.listCap) notes.")
        }
        let ids = try validatedNoteIDs(value)
        let bookID = try requiredString(args, "book_id")
        let reason = try optionalString(args, "reason")
        var reasons: [String: String] = [:]
        if let value = args["reasons"], value != .null {
            guard let object = value.objectValue else {
                throw ArgumentFailure(message: "reasons must be an object: a note_id to its reason.")
            }
            let listed = Set(ids)
            for key in object.keys.sorted() {
                guard listed.contains(key) else {
                    throw ArgumentFailure(message: "reasons names \(key), which note_ids doesn't list.")
                }
                guard let text = object[key]?.stringValue else {
                    throw ArgumentFailure(message: "reasons[\(key)] must be a string.")
                }
                reasons[key] = text
            }
        }
        if let count = ArrivalProvenance.normalizedReason(reason)?.count, count > ArrivalProvenance.reasonCap {
            throw ArgumentFailure(message: Self.reasonCapWords("reason", count: count))
        }
        for key in reasons.keys.sorted() {
            if let count = ArrivalProvenance.normalizedReason(reasons[key])?.count,
               count > ArrivalProvenance.reasonCap {
                throw ArgumentFailure(message: Self.reasonCapWords("reasons[\(key)]", count: count))
            }
        }
        return .noteList(tool: MCPToolCatalog.proposeNotesToBook.name, items: ids.map { id in
            NoteListItem(noteID: id, job: .proposeNote(noteID: id, bookID: bookID, reason: reasons[id] ?? reason))
        })
    }

    // MARK: - One item (its own act)

    func performProposeNote(
        noteID: String, bookID: String, reason: String?, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        // A gathering holds nothing: one the client can READ hears why (the
        // `set_book_rule` precedent — P-VX196-2's posture, never "doesn't
        // exist" for what `list_books` lists); one it can't is the one shape,
        // through the book decision below.
        if let gathering = try readableGathering(bookID, clientName: clientName) {
            try log(clientName, job.tool, "book", bookID, gathering, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.proposalGatheringWords(gathering), isError: true)))
        }
        return try noteIntoBook(
            noteID, bookID, job: job, clientName: clientName, rung: .read, spendsAfter: false, logsOnBook: true
        ) { title, bookName in
            let outcome: Operations.MCPProposalOutcome
            do {
                outcome = try ops.proposeNoteToBook(
                    noteID, book: bookID, provenance: .proposed(client: clientName, reason: reason),
                    undoLabel: Operations.MCPWriteAct.proposal.undoLabel(client: clientName),
                    guardedBy: guardProposal(clientName, noteID: noteID, bookID: bookID))
            } catch Operations.MCPProposalRefusal.leftTheBook {
                throw Refused(outcome: Outcome(text: Self.proposalLeftTheBookWords, isError: true))
            } catch Operations.MCPProposalRefusal.reasonTooLong {
                throw Refused(outcome: Outcome(
                    text: Self.reasonCapWords("reason", count: ArrivalProvenance.normalizedReason(reason)?.count ?? 0),
                    isError: true))
            }
            let changed = outcome != .alreadyWaiting
            // A note already waiting is done (apply_tag's no-op shape): nothing
            // written, no entry, no receipt — the landed Activity line.
            return (["note_id": noteID, "book_id": bookID, "changed": changed],
                    changed
                        ? MCPWriteReceipt(clientName: clientName, act: .proposal, targetID: bookID,
                                          targetTitle: bookName, detail: title,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
        }
    }

    /// **The item's guard** — the note and the book re-decided at READ on one
    /// standing read inside the act's transaction (`guardBookAndNote`'s shape),
    /// and EVERY once grant that authorized a side spent there, atomically —
    /// whatever its rung (PROVISIONAL P-808-B2-2, AF-7's letter: a once grant
    /// is ONE act's permission, and a proposal is a content-bearing WRITE; the
    /// pure rule's `spends` reads a once write grant as spent only at suggest
    /// and above, so the read-rung write spends it here, `MCPGrantRule`
    /// untouched). A standing grant that also covers a side is chosen first
    /// (`best`), so a once grant is spent only when nothing else covers.
    func guardProposal(_ clientName: String, noteID: String, bookID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let onNote = MCPGrantAuthority.decide(
                standing, note: try Queries.mcpNoteFacts(db, noteID: noteID), rung: .read, consumes: true)
            guard case .allow(let noteGrant, _) = onNote else { throw Self.refused(onNote, .note) }
            let onBook = MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .read, consumes: true)
            guard case .allow(let bookGrant, _) = onBook else { throw Self.refused(onBook, .book) }
            let once = Set([noteGrant, bookGrant].compactMap { $0 }.filter { standing.grant(id: $0)?.duration == .once })
            for grantID in once.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }
}
