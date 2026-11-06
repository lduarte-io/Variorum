import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-808 Unit B2 — PROVENANCE AT EVERY ARRIVAL DOOR (the run record
// `notes/plans/fixes/vx-808-arrivals-books.md`, A-808-6..9): every road that
// mints, re-poses or DEMOTES-TO an arrival stamps its cause; `client` rides a
// stamp whose act a wire client took; a demotion carries its moment (`at`); a
// seat CARRIES the stamp it found (A-808-9). One test per door — red on old by
// construction (no road stamped before this batch; the column was born NULL).
// The two Sync/ demotion sites (the OWNED repair, the wing mend) are pinned in
// their convergence suites (`Phase13iRepairTests`, `BookWingConvergenceTests`).

@Suite("VX-808 B2 — every arrival door stamps why it waits")
struct ArrivalProvenanceStampsTests {
    private let client = "claude-code"

    /// The pair's LIVE arrival row's stamp (nil: none, or not an arrival).
    private func stamp(_ db: AppDatabase, _ bookID: String, _ postID: String) throws -> String? {
        try db.read {
            try String.fetchOne(
                $0,
                sql: """
                    SELECT arrival_provenance FROM reading_post
                    WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'arrival'
                    """,
                arguments: [bookID, postID])
        }
    }

    private func status(_ db: AppDatabase, _ bookID: String, _ postID: String) throws -> String? {
        try db.read {
            try String.fetchOne(
                $0, sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [bookID, postID])
        }
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        try ops.createPost(title: title)
    }

    // MARK: - The events

    @Test func aTaggingBellIsStampedTaggedWithItsTagAndAWireClientsCarriesTheName() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "travel")
            let waits = try ops.createReading(
                name: "Travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)), intakeSeating: .arrivals)
            let hers = try note(ops, "hers")
            _ = try ops.applyTag(tag.id, toPost: hers.id)
            #expect(try stamp(db, waits.id, hers.id) == #"{"kind":"tagged","tag":"\#(tag.id)"}"#)
            // A-809-11's fence bell IS a tagging event with a client: a Private
            // book that would seat the note waits instead, and says who.
            let diary = try ops.createReading(name: "Diary", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            _ = try ops.setBookPrivate(diary.id, true)
            let theirs = try note(ops, "theirs")
            _ = try ops.heardAsWireClient(named: client).applyTagPath("travel", toPost: theirs.id, undoLabel: "x")
            #expect(try stamp(db, diary.id, theirs.id) == #"{"client":"claude-code","kind":"tagged","tag":"\#(tag.id)"}"#)
            #expect(try stamp(db, waits.id, theirs.id) == #"{"client":"claude-code","kind":"tagged","tag":"\#(tag.id)"}"#)
            // A SEAT carries none (a member is no arrival).
            let plain = try ops.createReading(name: "Plain", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let seated = try note(ops, "seated")
            _ = try ops.applyTag(tag.id, toPost: seated.id)
            #expect(try status(db, plain.id, seated.id) == "member")
            #expect(try db.read {
                try String.fetchOne($0, sql: "SELECT arrival_provenance FROM reading_post WHERE reading_id = ? AND post_id = ?",
                                    arguments: [plain.id, seated.id])
            } == nil)
        }
    }

    @Test func aStarringBellIsStampedStarred() throws {
        try withOperations { ops, db in
            let waits = try ops.createReading(
                name: "Stars", kind: .book, querySpec: try RuleGrammar.encode(.star), intakeSeating: .arrivals)
            let hers = try note(ops, "hers")
            try ops.setStarred(.post(hers.id), starred: true)
            #expect(try stamp(db, waits.id, hers.id) == #"{"kind":"starred"}"#)
        }
    }

    @Test func aDismissedPairReposedByAFreshTaggingIsStampedOnItsNewRow() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "travel")
            let again = try ops.createTag(parent: tag.id, name: "again")
            let book = try ops.createReading(
                name: "Travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)), intakeSeating: .arrivals)
            let one = try note(ops, "one")
            _ = try ops.applyTag(tag.id, toPost: one.id)
            let first = try #require(try db.read {
                try String.fetchOne($0, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ?",
                                    arguments: [book.id, one.id])
            })
            try ops.dismissArrival(first)
            _ = try ops.applyTag(again.id, toPost: one.id)  // a fresh act, the subtree's tag
            #expect(try stamp(db, book.id, one.id) == #"{"kind":"tagged","tag":"\#(again.id)"}"#)
        }
    }

    // MARK: - The sweeps

    @Test func aBooksBirthBellIsStampedBackfill() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "travel")
            let one = try note(ops, "one")
            _ = try ops.applyTag(tag.id, toPost: one.id)
            let book = try ops.createReading(
                name: "Travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)), intakeSeating: .arrivals)
            #expect(try stamp(db, book.id, one.id) == #"{"kind":"backfill"}"#)
        }
    }

    @Test func aRuleWritesBellsAreStampedRuleEditWhateverTheOccasionAndAWireWriteNamesItsClient() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "travel"), other = try ops.createTag(name: "other")
            let one = try note(ops, "one"), two = try note(ops, "two"), three = try note(ops, "three")
            for post in [one, two] { _ = try ops.applyTag(tag.id, toPost: post.id) }
            _ = try ops.applyTag(other.id, toPost: three.id)
            // Her rule set on a RULE-LESS book (backfill-classed), the dial at wait.
            let fresh = try ops.createReading(name: "Fresh", kind: .book, intakeSeating: .arrivals)
            try ops.setReadingQuerySpec(fresh.id, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            #expect(try stamp(db, fresh.id, one.id) == #"{"kind":"rule_edit"}"#)
            // Her rule EDITED (catch-up-classed).
            let edited = try ops.createReading(name: "Edited", kind: .book, querySpec: try RuleGrammar.encode(.tag(other.id)))
            try ops.setReadingQuerySpec(edited.id, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            #expect(try stamp(db, edited.id, two.id) == #"{"kind":"rule_edit"}"#)
            // The wire's set_book_rule: always belling, its client named.
            let wired = try ops.createReading(name: "Wired", kind: .book)
            var write = Operations.MCPBookRuleWrite()
            write.rule = .some(.tag("travel"))
            _ = try ops.heardAsWireClient(named: client).setBookRule(wired.id, write, undoLabel: "x")
            #expect(try stamp(db, wired.id, one.id) == #"{"client":"claude-code","kind":"rule_edit"}"#)
        }
    }

    @Test func eachResumesCatchUpIsStampedWithWhichResume() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "travel")
            func book(_ name: String) throws -> Reading {
                try ops.createReading(name: name, kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            }
            let reopened = try book("Reopened"), restored = try book("Restored")
            let unarchived = try book("Unarchived"), unsealed = try book("Unsealed")
            try ops.lockReading(reopened.id)
            try ops.deleteReading(restored.id)
            try ops.archiveReading(unarchived.id)
            _ = try ops.sealReading(unsealed.id)
            let gap = try note(ops, "gap")
            _ = try ops.applyTag(tag.id, toPost: gap.id)  // heard by none: every book paused
            try ops.unlockReading(reopened.id)
            try ops.restoreReading(restored.id)
            _ = try ops.unarchiveReading(unarchived.id)
            try ops.unsealReading(unsealed.id)
            for (reading, after) in [(reopened, "reopen"), (restored, "restore"), (unarchived, "unarchive"),
                                     (unsealed, "unseal")] {
                #expect(try stamp(db, reading.id, gap.id) == #"{"after":"\#(after)","kind":"catchup"}"#, "\(after)")
            }
        }
    }

    // MARK: - The daily door and the revival pass

    @Test func theDailyDoorsOwnershipBellIsStampedJournalFiling() throws {
        try withOperations { ops, db in
            let owned = try ops.createReading(name: "Owned", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let entry = try ops.createPost(title: "a day", profile: .journal, entryDate: "2026-07-01")
            _ = try ops.addPostToReading(entry.id, to: owned.id)
            guard case .waitingAtDoor(let journal) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not bell"); return
            }
            #expect(try stamp(db, journal, entry.id) == #"{"kind":"journal_filing"}"#)
        }
    }

    @Test func theRevivalPassesDemotionIsStampedOwnedElsewhereWithItsMoment() throws {
        try withOperations { ops, db in
            // N joins owned X; X goes to the Trash (its membership on its
            // stamp); N joins owned Y; X comes back — the earliest-created
            // membership (X's) stands, Y's later owned-side row DEMOTES.
            let first = try ops.createReading(name: "First", kind: .book)
            _ = try ops.setReadingOwned(first.id, owned: true)
            let later = try ops.createReading(name: "Later", kind: .book)
            _ = try ops.setReadingOwned(later.id, owned: true)
            let n = try note(ops, "claimed")
            _ = try ops.addPostToReading(n.id, to: first.id)
            try ops.deleteReading(first.id)
            _ = try ops.addPostToReading(n.id, to: later.id)
            try ops.restoreReading(first.id)
            #expect(try status(db, first.id, n.id) == "member" && status(db, later.id, n.id) == "arrival")
            let provenance = try #require(ArrivalProvenance.decode(try stamp(db, later.id, n.id)))
            #expect(provenance.knownKind == .ownedElsewhere && provenance.client == nil)
            let at = try #require(provenance.at.flatMap(DateFormatter.variorumISO8601.date(from:)))
            let created = try #require(try db.read {
                try Date.fetchOne($0, sql: "SELECT created_at FROM reading_post WHERE reading_id = ? AND post_id = ?",
                                  arguments: [later.id, n.id])
            })
            #expect(at > created, "since when is the demotion's moment, never the filing's")
        }
    }

    // MARK: - A seat carries (A-808-9)

    @Test func aSeatCarriesTheStampItFound() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Lisbon", kind: .book)
            let one = try note(ops, "one")
            guard case .proposed(let arrival) = try ops.proposeNoteToBook(
                one.id, book: book.id, provenance: .proposed(client: client, reason: "why"), undoLabel: "x")
            else { Issue.record("did not land"); return }
            let seated = try ops.seatArrival(arrival.id)
            #expect(seated.status == .member && seated.arrivalProvenance == arrival.arrivalProvenance,
                    "CARRY, never clear — readers read it on live arrivals only")
        }
    }
}
