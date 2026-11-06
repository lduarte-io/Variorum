import Dependencies
import Foundation
import GRDB

// **VX-811 — A CLIENT PROPOSES A NOTE TO A BOOK** (the VX-808 run, Unit B2;
// the run record `notes/plans/fixes/vx-808-arrivals-books.md` §3's VX-811
// block — her rulings, two rounds: "let's let the AI do a mass act that makes
// them wait, so you can use it as a way to go through a bunch of notes";
// "read level on everything should be able to propose … it's only proposing i
// guess"; "an OPTIONAL per-note reason rides the propose act").
//
// ONE pair, ONE act: the note waits at the book's Arrivals — an ARRIVAL row
// (`status='arrival'`, insert-only), stamped `{"kind":"proposed","client":…,
// "reason":…?}`. An arrival is no membership: nothing joins the book, nothing
// widens any reach, and her Add (`seatArrival` and its ownership-aware arms) is
// the one door that seats it. The no-backfill fence stands (VX-811 ruling 1):
// no wire act seats in bulk.
//
// The verdicts (the B2 fork, ruled in the run record), decided inside the act's
// own transaction AFTER the caller's guard:
// - the BOOK: live, a book (a gathering holds nothing — `wrongReadingKind`),
//   not finished or sealed (`lockedReading` — finishing dismisses waiters, a
//   finished book hears no intake). An ARCHIVED book takes the proposal: the
//   explicit doors stay open while archived (R-13ie-4 pauses auto-ingestion
//   only; `IntakeDecision.intakeRuns` is intake's gate, which no explicit door
//   consults).
// - the NOTE: a live post of the book's own wing (`crossWingMembership` — a
//   book never spans wings, and a cross-wing arrival could never be added).
// - the PAIR — exactly `IntakeDecision.verdict`'s EVENT rows, the pair being a
//   fresh deliberate act's: a live MEMBER refuses `alreadyInReading` (her
//   doors' words); a live ARRIVAL already waits (nothing written); a pair the
//   note LEFT AS A MEMBER is decided (`MCPProposalRefusal.leftTheBook`); a
//   DISMISSED pair is RE-POSED — a NEW arrival row beside the dismissal record
//   (`materializeIntake`'s own re-pose shape); a fresh pair gets its arrival.
// - NOT consulted, by design: the book's rule, whether the note matches it,
//   the join dial, CAPACITY and OWNERSHIP — an arrival is no membership, so a
//   full book still takes one, and the Add runs the ownership consult exactly
//   as her hand-add does (VX-821: the choice is hers at the add, never the
//   proposer's).
//
// The new row lands at the END of the book's list, unsectioned (an arrival's
// place — §4). No touch, no churn (a membership is no text edit).
extension Operations {
    /// What a proposal did.
    public enum MCPProposalOutcome: Equatable, Sendable {
        /// The note now waits at the door: the arrival row this act minted.
        case proposed(ReadingPost)
        /// It was already waiting there (any cause): nothing was written.
        case alreadyWaiting
    }

    /// The proposal's own refusals (never an `OperationError`: no door of hers
    /// proposes — the `MCPBookRuleRefusal` precedent; the wire words them).
    public enum MCPProposalRefusal: Error, Equatable, Sendable {
        /// The note was a member of this book and left it (taken out, moved
        /// in elsewhere, forked) — tombstone-means-decided: a member-class
        /// tombstone is never re-posed (AppSpec §9: "a removed MEMBER stays
        /// decided").
        case leftTheBook
        /// A reason longer than `ArrivalProvenance.reasonCap` (the wire refuses
        /// it at its call door first).
        case reasonTooLong
    }

    /// **Propose `postID` to `bookID`'s Arrivals** — one act, one transaction,
    /// ONE client-named undo entry when it wrote (`undoLabel`): the inverse
    /// tombstones the minted arrival only while it still WAITS (her Add or her
    /// Dismiss since is hers to keep — the undo is then quiet and retires); the
    /// redo revives it only while it is dead on the undo's own stamp and the
    /// pair has no live row, into a live, unfinished book of the note's wing.
    /// An undone proposal leaves a tombstoned arrival — the dismissal-record
    /// class, so a later fresh act re-poses the pair (PROVISIONAL, the B2
    /// bundle; `add_note_to_book`'s undo leaves its member-class mark the same
    /// way).
    @discardableResult
    public func proposeNoteToBook(
        _ postID: String, book bookID: String, provenance: ArrivalProvenance, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPProposalOutcome {
        if let reason = provenance.reason, reason.count > ArrivalProvenance.reasonCap {
            throw MCPProposalRefusal.reasonTooLong
        }
        let stamp = try provenance.encodedJSON()
        let outcome: MCPProposalOutcome = try database.write { db in
            try guardian?(db)
            let reading = try liveReading(db, bookID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: bookID, expected: .book)
            }
            guard !reading.locked else { throw OperationError.lockedReading(id: bookID) }
            try requireSameWing(db, post: try livePost(db, postID), book: reading)
            switch try intakePairState(db, readingID: bookID, postID: postID) {
            case .live:
                if try liveMembership(db, postID: postID, readingID: bookID) != nil {
                    throw OperationError.alreadyInReading(postID: postID, readingID: bookID)
                }
                return .alreadyWaiting
            case .leftAsMember:
                throw MCPProposalRefusal.leftTheBook
            case .dismissed, .fresh:
                let arrival = ReadingPost(
                    id: newID(), readingId: bookID, postId: postID,
                    position: try readingPosition(db, readingID: bookID, at: .end),
                    status: .arrival, createdAt: date.now, arrivalProvenance: stamp)
                try arrival.insert(db)
                return .proposed(arrival)
            }
        }
        if case .proposed(let arrival) = outcome {
            let undoneOn = LockIsolated<String?>(nil)
            undoStack?.register(
                label: undoLabel,
                inverse: { ops in
                    guard let undone = try ops.revertProposal(arrival) else { return false }
                    undoneOn.setValue(undone)
                    return true
                },
                redo: { try $0.reapplyProposal(arrival, undoneOn: undoneOn.value) })
        }
        return outcome
    }

    /// The undo: tombstones the proposal's row while it is still a live
    /// arrival; returns the stamp it wrote (nil = nothing of the act's left).
    func revertProposal(_ arrival: ReadingPost) throws -> String? {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: arrival.id), row.deletedAt == nil,
                  row.status == .arrival
            else { return nil }
            let now = date.now
            row.deletedAt = now
            try row.update(db)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }

    /// The redo: revives the row only over what its undo left — dead on the
    /// undo's own stamp, still an arrival, no live row for the pair since —
    /// into a live, unfinished book the note still shares a wing with.
    /// Anything else is not the undo's result, and the redo is quiet.
    @discardableResult
    func reapplyProposal(_ arrival: ReadingPost, undoneOn: String?) throws -> Bool {
        guard let undoneOn else { return false }
        return try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: arrival.id), row.status == .arrival,
                  row.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == undoneOn,
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil,
                  book.kind == .book, !book.locked,
                  let note = try Container.fetchOne(db, key: row.postId), note.deletedAt == nil,
                  try sameEffectiveWing(db, note.wingId, book.wingId),
                  try livePairRow(db, postID: row.postId, readingID: row.readingId) == nil
            else { return false }
            row.deletedAt = nil
            try row.update(db)
            return true
        }
    }
}
