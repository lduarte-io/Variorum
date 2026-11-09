import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **P-849-1 — her restore, INSURED** (PROVISIONAL; the run record
/// `notes/plans/fixes/vx-849-typed-over-rescue.md`, batch 3, piece 3).
///
/// `restoreCommit(_:commitID:insuringBuffer: true)`: inside the restore's ONE
/// transaction, when the restore will change the take's text AND the take's
/// buffer differs from its latest savepoint, ONE quiet `kind='auto'` savepoint
/// (unnamed — her road's kind) of the words about to be replaced lands first.
/// The insurance doctrine (OverallModel §3): insure what an act is about to
/// make unreachable — the words she typed since her last savepoint, which the
/// restore overwrites. The MCP door's bracket is the precedent; its road
/// (`restoreCommitForClient` → `restoreCommitRows`) is untouched. The default
/// (`false`) is the restore exactly as before.
@Suite("P-849-1 — the insured restore")
struct RestoreInsuranceTests {
    private func commits(_ db: AppDatabase, take: String) throws -> [Row] {
        try db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                SELECT id, text, kind, message, created_at FROM commit_point
                WHERE variant_id = ? ORDER BY created_at, id
                """,
                arguments: [take])
        }
    }

    /// THE PIN — the words the restore replaces, kept quietly first.
    @Test func anInsuredRestoreKeepsTheWordsItReplacesInAQuietSavepointFirst() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "The moment.")
            let take = made.variant.id
            let moment = try ops.commit(take)
            try ops.autosave(take, text: "The moment. Typed since.", charDelta: 13)

            try ops.restoreCommit(take, commitID: moment.id, insuringBuffer: true)

            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take]) == "The moment.")
            let rows = try commits(db, take: take)
            #expect(rows.count == 2, "the moment, then the insurance")
            let insurance = try #require(rows.last)
            #expect(insurance["text"] as String == "The moment. Typed since.", "the replaced words, kept")
            #expect(insurance["kind"] as String == "auto", "quiet — her road's kind")
            #expect((insurance["message"] as String?) == nil, "unnamed (the wire's bracket names its own)")
            #expect((insurance["id"] as String) != moment.id)
        }
    }

    /// The restore's text change, touch and churn are the restore's own: the
    /// quiet savepoint adds none (auto commits never register a text change —
    /// §10). Two twin notes, one restored insured and one not, end with the same
    /// churn, the same baseline and the same major-revision answer.
    @Test func theInsuranceIsQuietAndTheRestoreIsTheRestoreItAlwaysWas() throws {
        try withOperations { ops, db in
            func twin(insured: Bool) throws -> (churn: Double?, baseline: Int?, majorMoved: Bool, take: String) {
                let post = try ops.createPost(title: "p", profile: .blog)
                let made = try ops.seedBlock(in: post.id, text: "A moment of words, long enough to weigh.")
                let take = made.variant.id
                let moment = try ops.commit(take)
                try ops.autosave(take, text: "A moment of words, long enough to weigh. More.", charDelta: 6)
                let majorBefore = try db.fetchString(
                    "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id])
                try ops.restoreCommit(take, commitID: moment.id, insuringBuffer: insured)
                let churn = try db.read { db in
                    try Double.fetchOne(db, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                                        arguments: [post.id])
                }
                return (
                    churn,
                    try db.fetchInt("SELECT baseline_length FROM container WHERE id = ?", [post.id]),
                    try db.fetchString(
                        "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id]) != majorBefore,
                    take)
            }
            let insured = try twin(insured: true)
            let plain = try twin(insured: false)
            #expect(insured.churn == plain.churn, "the insurance adds no churn")
            #expect(insured.baseline == plain.baseline)
            #expect(insured.majorMoved == plain.majorMoved, "a quiet savepoint is no major revision")
            #expect(try commits(db, take: insured.take).last?["kind"] as String? == "auto")
            #expect(try db.outboxContains("variant", insured.take), "the restored row pushes as ever")
        }
    }

    /// GUARD — deduped: a buffer its latest savepoint already holds is not
    /// insured again.
    @Test func aBufferItsLastSavepointHoldsIsNotInsuredAgain() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "One.")
            let take = made.variant.id
            let first = try ops.commit(take)
            try ops.autosave(take, text: "One. Two.", charDelta: 5)
            _ = try ops.commit(take)
            try ops.restoreCommit(take, commitID: first.id, insuringBuffer: true)
            #expect(try commits(db, take: take).count == 2, "no third savepoint")
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take]) == "One.")
        }
    }

    /// GUARD — a restore that changes nothing writes nothing (the restore's
    /// own no-op), insured or not.
    @Test func aRestoreThatChangesNothingInsuresNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Same.")
            let take = made.variant.id
            let moment = try ops.commit(take)
            try ops.autosave(take, text: "Different.", charDelta: 10)
            _ = try ops.commit(take)
            try ops.autosave(take, text: "Same.", charDelta: 10)   // back to the moment's words, uncommitted
            try ops.restoreCommit(take, commitID: moment.id, insuringBuffer: true)
            #expect(try commits(db, take: take).count == 2, "the take already reads the moment: nothing to insure")
        }
    }

    /// GUARD — a refusal mints nothing: a locked take, a sealed post.
    @Test func aRefusedRestoreMintsNoInsurance() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Locked words.")
            let take = made.variant.id
            let moment = try ops.commit(take)
            try ops.autosave(take, text: "Locked words, typed on.", charDelta: 10)
            try ops.lockVariant(take)   // locking a dirty take insures it itself
            let afterLock = try commits(db, take: take).count
            #expect(throws: OperationError.self) {
                try ops.restoreCommit(take, commitID: moment.id, insuringBuffer: true)
            }
            #expect(try commits(db, take: take).count == afterLock, "a locked take: nothing minted")

            let sealedPost = try ops.createPost(title: "s", profile: .blog)
            let sealedMade = try ops.seedBlock(in: sealedPost.id, text: "Sealed words.")
            let sealedTake = sealedMade.variant.id
            let sealedMoment = try ops.commit(sealedTake)
            try ops.autosave(sealedTake, text: "Sealed words, typed on.", charDelta: 10)
            try ops.lockPost(sealedPost.id)   // the seal insures its dirty buffers itself
            let afterSeal = try commits(db, take: sealedTake).count
            #expect(throws: OperationError.self) {
                try ops.restoreCommit(sealedTake, commitID: sealedMoment.id, insuringBuffer: true)
            }
            #expect(try commits(db, take: sealedTake).count == afterSeal, "a sealed post: nothing minted")
        }
    }

    /// GUARD — the default is the restore exactly as before: no savepoint.
    @Test func theUninsuredRestoreKeepsNoSavepoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .blog)
            let made = try ops.seedBlock(in: post.id, text: "Plain.")
            let take = made.variant.id
            let moment = try ops.commit(take)
            try ops.autosave(take, text: "Plain, typed on.", charDelta: 10)
            try ops.restoreCommit(take, commitID: moment.id)
            #expect(try commits(db, take: take).count == 1)
            #expect(try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [take]) == "Plain.")
        }
    }
}
