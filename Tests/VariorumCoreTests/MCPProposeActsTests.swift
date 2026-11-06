import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-811 (the VX-808 run, Unit B2 — the run record
// `notes/plans/fixes/vx-808-arrivals-books.md` §3's VX-811 block and §6 Unit
// B2): THE PROPOSAL's act — `proposeNoteToBook`. Exact state transitions, one
// verdict row per test: the caller's guard first; the book (a book, live, not
// finished — archived lands); the note (live, the book's wing); the pair
// (IntakeDecision's EVENT rows: member refuses, waiting is a no-op, left-as-
// member is decided, dismissed re-poses beside its record, fresh bells); NOT the
// rule, the dial, capacity or ownership. ONE client-named entry per landed
// proposal, compare-and-set both ways. Who may propose is the server's per-call
// rule (`MCPProposeServerTests`).

private struct GuardRefused: Error, Equatable {}

@Suite("VX-811 — a note proposed to a book's Arrivals: the act")
struct MCPProposeActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private var label: String { Operations.MCPWriteAct.proposal.undoLabel(client: client) }

    private func proposed(_ reason: String? = nil) -> ArrivalProvenance {
        .proposed(client: client, reason: reason)
    }

    /// Every `reading_post` row of the pair, oldest first — the whole record.
    private func pairRows(_ db: AppDatabase, _ postID: String, _ bookID: String) throws -> [ReadingPost] {
        try db.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ? ORDER BY created_at, id",
                arguments: [bookID, postID])
        }
    }

    private func dump(_ db: AppDatabase) throws -> [Row] {
        try db.read { try Row.fetchAll($0, sql: "SELECT * FROM reading_post ORDER BY id") }
    }

    private func members(_ db: AppDatabase, _ bookID: String) throws -> Int {
        try db.read {
            try Int.fetchOne(
                $0, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'",
                arguments: [bookID]) ?? 0
        }
    }

    private func note(_ ops: Operations, _ title: String, wing: String = "") throws -> Container {
        let post = try ops.createPost(title: title, wingId: wing)
        _ = try ops.newBlock(in: post.id, text: "\(title) words.", registeringUndo: false)
        return post
    }

    // MARK: - A fresh pair

    @Test func aFreshPairWaitsAtTheEndUnsectionedStampedAndOneEntryRoundTrips() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let member = try note(ops, "member")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let candidate = try note(ops, "candidate")
            let touched = try db.read { try Container.fetchOne($0, key: candidate.id)?.lastTouchedAt }
            let outcome = try ops.proposeNoteToBook(
                candidate.id, book: book.id, provenance: proposed("It fits the Lisbon chapter."), undoLabel: label)
            guard case .proposed(let arrival) = outcome else { Issue.record("not proposed: \(outcome)"); return }
            let rows = try pairRows(db, candidate.id, book.id)
            #expect(rows == [arrival], "exactly one row for the pair: the arrival")
            #expect(arrival.status == .arrival && arrival.deletedAt == nil && arrival.sectionId == nil)
            #expect(arrival.arrivalProvenance
                    == #"{"client":"claude-code","kind":"proposed","reason":"It fits the Lisbon chapter."}"#,
                    "canonical JSON: sorted keys, the client and its reason")
            let memberPosition = try #require(try pairRows(db, member.id, book.id).first?.position)
            #expect(arrival.position > memberPosition, "at the END of the book's list")
            #expect(try db.read { try Container.fetchOne($0, key: candidate.id)?.lastTouchedAt } == touched,
                    "no touch — a membership is no text edit")
            #expect(try members(db, book.id) == 1, "an arrival is no membership")
            #expect(stack.depth == 1 && stack.topLabel == label, "ONE client-named entry")
            #expect(try stack.undo(with: ops) == label)
            let undone = try #require(try pairRows(db, candidate.id, book.id).first)
            #expect(undone.id == arrival.id && undone.deletedAt != nil && undone.status == .arrival,
                    "the undo tombstones the act's own row (the dismissal-record class)")
            #expect(try stack.redo(with: ops) == label)
            #expect(try pairRows(db, candidate.id, book.id) == [arrival], "the redo revives the same row, whole")
        }
    }

    @Test func aBlankOrNullOnlyReasonIsNoneAndAReasonIsStoredStrippedAndTrimmed() throws {
        try withUndo { ops, _, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let one = try note(ops, "one"), two = try note(ops, "two")
            _ = try ops.proposeNoteToBook(one.id, book: book.id, provenance: proposed("  \u{0}\n "), undoLabel: label)
            _ = try ops.proposeNoteToBook(two.id, book: book.id, provenance: proposed(" why\u{0} not \n"), undoLabel: label)
            #expect(try pairRows(db, one.id, book.id).first?.arrivalProvenance == #"{"client":"claude-code","kind":"proposed"}"#)
            #expect(try pairRows(db, two.id, book.id).first?.provenance?.reason == "why not")
        }
    }

    @Test func aReasonPastTheCapRefusesWithNothingWritten() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let one = try note(ops, "one")
            let before = try dump(db)
            let long = String(repeating: "a", count: ArrivalProvenance.reasonCap + 1)
            #expect(throws: Operations.MCPProposalRefusal.reasonTooLong) {
                try ops.proposeNoteToBook(one.id, book: book.id, provenance: proposed(long), undoLabel: label)
            }
            #expect(try dump(db) == before && stack.depth == 0)
            let exact = String(repeating: "a", count: ArrivalProvenance.reasonCap)
            _ = try ops.proposeNoteToBook(one.id, book: book.id, provenance: proposed(exact), undoLabel: label)
            #expect(try pairRows(db, one.id, book.id).first?.provenance?.reason == exact, "the cap itself lands")
        }
    }

    // MARK: - The pair's rows (IntakeDecision's EVENT rows)

    @Test func aMemberRefusesInHerDoorsWordsWithNothingWritten() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let member = try note(ops, "member")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let before = try dump(db)
            #expect(throws: OperationError.alreadyInReading(postID: member.id, readingID: book.id)) {
                try ops.proposeNoteToBook(member.id, book: book.id, provenance: proposed(), undoLabel: label)
            }
            #expect(try dump(db) == before && stack.depth == 0)
        }
    }

    @Test func aNoteAlreadyWaitingIsANoOpWhateverRangItsBellAndKeepsItsProvenance() throws {
        try withUndo { ops, stack, db in
            // A bell intake rang (the dial says wait) — a waiting row of another cause.
            let tag = try ops.createTag(name: "travel")
            let book = try ops.createReading(
                name: "Travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)), intakeSeating: .arrivals)
            let rung = try note(ops, "rung")
            _ = try ops.applyTag(tag.id, toPost: rung.id)
            // …and an earlier proposal.
            let asked = try note(ops, "asked")
            _ = try ops.proposeNoteToBook(asked.id, book: book.id, provenance: proposed("first"), undoLabel: label)
            let depth = stack.depth
            let before = try dump(db)
            for post in [rung, asked] {
                #expect(try ops.proposeNoteToBook(post.id, book: book.id, provenance: proposed("again"), undoLabel: label)
                        == .alreadyWaiting)
            }
            #expect(try dump(db) == before, "nothing written — the waiting rows keep their own provenance")
            #expect(stack.depth == depth, "no entry: nothing to undo")
        }
    }

    @Test func aNoteThatLeftTheBookAsAMemberIsDecidedAndNeverReposed() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let gone = try note(ops, "gone")
            _ = try ops.addPostToReading(gone.id, to: book.id)
            _ = try ops.removePostFromReading(gone.id, from: book.id)
            let before = try dump(db)
            #expect(throws: Operations.MCPProposalRefusal.leftTheBook) {
                try ops.proposeNoteToBook(gone.id, book: book.id, provenance: proposed(), undoLabel: label)
            }
            #expect(try dump(db) == before && stack.depth == 0, "tombstone-means-decided (a removed MEMBER stays decided)")
        }
    }

    @Test func aDismissedPairIsReposedOnANewRowBesideItsDismissalRecord() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let judged = try note(ops, "judged")
            guard case .proposed(let first) = try ops.proposeNoteToBook(
                judged.id, book: book.id, provenance: proposed("first"), undoLabel: label)
            else { Issue.record("the first proposal did not land"); return }
            try ops.dismissArrival(first.id)
            let record = try #require(try pairRows(db, judged.id, book.id).first)
            #expect(record.deletedAt != nil && record.status == .arrival, "her dismissal: the record")
            guard case .proposed(let second) = try ops.proposeNoteToBook(
                judged.id, book: book.id, provenance: proposed("second"), undoLabel: label)
            else { Issue.record("the fresh act did not re-pose the pair"); return }
            #expect(second.id != record.id, "a NEW arrival row — the dismissal record is never revived")
            #expect(try pairRows(db, judged.id, book.id) == [record, second],
                    "the record untouched (its own provenance kept), the new row live beside it")
            #expect(second.provenance?.reason == "second")
            #expect(stack.depth == 2)
        }
    }

    // MARK: - The book

    @Test func aFinishedOrSealedBookRefusesWithNothingWritten() throws {
        try withUndo { ops, stack, db in
            let finished = try ops.createReading(name: "done", kind: .book)
            try ops.lockReading(finished.id)
            let sealed = try ops.createReading(name: "sealed", kind: .book)
            _ = try ops.sealReading(sealed.id)
            let one = try note(ops, "one")
            let before = try dump(db)
            for id in [finished.id, sealed.id] {
                #expect(throws: OperationError.lockedReading(id: id)) {
                    try ops.proposeNoteToBook(one.id, book: id, provenance: proposed(), undoLabel: label)
                }
            }
            #expect(try dump(db) == before && stack.depth == 0)
        }
    }

    @Test func anArchivedBookTakesTheProposalAndAnArchivedNoteMayBeProposed() throws {
        try withUndo { ops, _, db in
            let shelved = try ops.createReading(name: "put away", kind: .book)
            try ops.archiveReading(shelved.id)
            let one = try note(ops, "one")
            let away = try note(ops, "away")
            try ops.archiveContainer(away.id)
            for post in [one, away] {
                guard case .proposed = try ops.proposeNoteToBook(
                    post.id, book: shelved.id, provenance: proposed(), undoLabel: label)
                else { Issue.record("\(post.title ?? "") did not land"); continue }
            }
            #expect(try pairRows(db, one.id, shelved.id).count == 1 && pairRows(db, away.id, shelved.id).count == 1)
        }
    }

    @Test func aGatheringRefusesWrongKindAndAGoneBookRefusesNotFound() throws {
        try withUndo { ops, _, db in
            let tag = try ops.createTag(name: "idea")
            let gathering = try ops.createReading(name: "Ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let gone = try ops.createReading(name: "gone", kind: .book)
            try ops.deleteReading(gone.id)
            let one = try note(ops, "one")
            let before = try dump(db)
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.proposeNoteToBook(one.id, book: gathering.id, provenance: proposed(), undoLabel: label)
            }
            #expect(throws: OperationError.readingNotFound(id: gone.id)) {
                try ops.proposeNoteToBook(one.id, book: gone.id, provenance: proposed(), undoLabel: label)
            }
            #expect(try dump(db) == before)
        }
    }

    @Test func aNoteOfAnotherWingRefusesCrossWing() throws {
        try withUndo { ops, _, db in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Home book", kind: .book)
            let elsewhere = try note(ops, "elsewhere", wing: studio.id)
            let before = try dump(db)
            #expect(throws: OperationError.crossWingMembership(postID: elsewhere.id, readingID: book.id)) {
                try ops.proposeNoteToBook(elsewhere.id, book: book.id, provenance: proposed(), undoLabel: label)
            }
            #expect(try dump(db) == before)
        }
    }

    // MARK: - What is NOT consulted

    @Test func aFullBookStillTakesAProposalAndItsMembersAreUnchanged() throws {
        try withUndo { ops, _, db in
            let book = try ops.createReading(name: "Capped", kind: .book, maxPosts: 1)
            let member = try note(ops, "member")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let extra = try note(ops, "extra")
            guard case .proposed = try ops.proposeNoteToBook(extra.id, book: book.id, provenance: proposed(), undoLabel: label)
            else { Issue.record("capacity blocked a bell"); return }
            #expect(try members(db, book.id) == 1)
        }
    }

    @Test func ownershipIsNotConsultedEitherWay() throws {
        try withUndo { ops, _, _ in
            // An OWNED book and a note membered elsewhere; a PLAIN book and a
            // note an owned book holds — her hand-add refuses both; a proposal
            // lands both (the Add runs the consult — VX-821).
            let owned = try ops.createReading(name: "Owned", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let membered = try note(ops, "membered")
            _ = try ops.addPostToReading(membered.id, to: other.id)
            let claimed = try note(ops, "claimed")
            _ = try ops.addPostToReading(claimed.id, to: owned.id)
            #expect(throws: (any Error).self) { try ops.addPostToReading(membered.id, to: owned.id) }
            #expect(throws: (any Error).self) { try ops.addPostToReading(claimed.id, to: plain.id) }
            for (post, book) in [(membered, owned), (claimed, plain)] {
                guard case .proposed = try ops.proposeNoteToBook(
                    post.id, book: book.id, provenance: proposed(), undoLabel: label)
                else { Issue.record("ownership blocked a bell"); continue }
            }
        }
    }

    @Test func theRuleAndTheDialAreNotConsulted() throws {
        try withUndo { ops, _, db in
            // A book with a rule the note does not match, set to join quietly:
            // the proposal still only bells — never a seat.
            let tag = try ops.createTag(name: "travel")
            let book = try ops.createReading(
                name: "Travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)), intakeSeating: .auto)
            let unmatched = try note(ops, "unmatched")
            guard case .proposed(let arrival) = try ops.proposeNoteToBook(
                unmatched.id, book: book.id, provenance: proposed(), undoLabel: label)
            else { Issue.record("did not land"); return }
            #expect(arrival.status == .arrival)
            #expect(try members(db, book.id) == 0)
        }
    }

    // MARK: - The guard

    @Test func theGuardRunsFirstInsideTheTransactionAndItsRefusalWritesNothing() throws {
        try withUndo { ops, stack, db in
            let finished = try ops.createReading(name: "done", kind: .book)
            try ops.lockReading(finished.id)
            let one = try note(ops, "one")
            let before = try dump(db)
            let ran = LockIsolated(false)
            #expect(throws: GuardRefused()) {
                try ops.proposeNoteToBook(
                    one.id, book: finished.id, provenance: proposed(), undoLabel: label,
                    guardedBy: { _ in ran.setValue(true); throw GuardRefused() })
            }
            #expect(ran.value, "the guard is asked before the book's own refusal")
            #expect(try dump(db) == before && stack.depth == 0)
        }
    }

    // MARK: - The undo's compare-and-set

    @Test func theUndoIsQuietOnceSheAddedOrDismissedTheArrival() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let added = try note(ops, "added")
            guard case .proposed(let arrival) = try ops.proposeNoteToBook(
                added.id, book: book.id, provenance: proposed(), undoLabel: label)
            else { Issue.record("did not land"); return }
            _ = try ops.seatArrival(arrival.id)
            let afterAdd = try dump(db)
            _ = try stack.undo(with: ops)
            #expect(try dump(db) == afterAdd, "her Add is hers to keep — the undo changes nothing")
            #expect(stack.depth == 0)

            let dismissed = try note(ops, "dismissed")
            guard case .proposed(let second) = try ops.proposeNoteToBook(
                dismissed.id, book: book.id, provenance: proposed(), undoLabel: label)
            else { Issue.record("did not land"); return }
            try ops.dismissArrival(second.id)
            let afterDismiss = try dump(db)
            _ = try stack.undo(with: ops)
            #expect(try dump(db) == afterDismiss, "her Dismiss is hers to keep")
        }
    }

    @Test func theRedoIsQuietWhenTheBookWasFinishedOrThePairGotALiveRowSince() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "Travel", kind: .book)
            let one = try note(ops, "one")
            _ = try ops.proposeNoteToBook(one.id, book: book.id, provenance: proposed(), undoLabel: label)
            _ = try stack.undo(with: ops)
            try ops.lockReading(book.id)
            let finished = try dump(db)
            _ = try stack.redo(with: ops)
            #expect(try dump(db) == finished, "a finished book is never belled by a redo")

            let open = try ops.createReading(name: "Open", kind: .book)
            let two = try note(ops, "two")
            _ = try ops.proposeNoteToBook(two.id, book: open.id, provenance: proposed(), undoLabel: label)
            _ = try stack.undo(with: ops)
            _ = try ops.addPostToReading(two.id, to: open.id)
            let added = try dump(db)
            _ = try stack.redo(with: ops)
            #expect(try dump(db) == added, "a live row for the pair since keeps it")
        }
    }

    // MARK: - The stamp's spelling

    /// The canonical spelling: sorted keys, absent fields omitted; a demotion
    /// carries its moment; malformed reads as absent; an unknown kind survives.
    @Test func theCanonicalSpellingAndTheReadersTolerance() throws {
        let moment = Date(timeIntervalSince1970: 1_782_864_000)
        #expect(try ArrivalProvenance(kind: .wingMend, at: moment).encodedJSON()
                == #"{"at":"2026-07-01T00:00:00.000Z","kind":"wing_mend"}"#)
        #expect(try ArrivalProvenance(kind: .catchup, client: "c", after: .unarchive).encodedJSON()
                == #"{"after":"unarchive","client":"c","kind":"catchup"}"#)
        #expect(try ArrivalProvenance(kind: .tagged, tag: "t/1").encodedJSON() == #"{"kind":"tagged","tag":"t/1"}"#,
                "slashes unescaped")
        #expect(ArrivalProvenance.decode("{not json") == nil && ArrivalProvenance.decode(nil) == nil,
                "malformed reads as absent")
        let future = try #require(ArrivalProvenance.decode(#"{"kind":"from_the_future","extra":1}"#))
        #expect(future.knownKind == nil && future.kind == "from_the_future", "an unknown kind survives the decode")
    }
}
