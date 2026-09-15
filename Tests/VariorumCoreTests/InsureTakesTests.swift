import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **THE SEVENTH QUIET AUTO-COMMIT OCCASION** (13u1 UNIT 2) — the author's
/// own insurance idea, adopted verbatim into item 5's design sketch: *"a
/// quiet auto-commit of the affected takes' state RIGHT BEFORE a multi-block
/// edit"*, and *"doubly right here because the gesture mixes the text-undo
/// and structural-undo worlds"*.
///
/// These pins hold the OCCASION's contract, which is the half a face cannot
/// keep for itself: what it commits, what it skips, and what it refuses.
@Suite("The seventh quiet auto-commit occasion (13u item 5)")
struct InsureTakesTests {

    /// The occasion itself: a take about to be edited by a compound leaves a
    /// `kind='auto'` savepoint of the state that is about to be overwritten.
    @Test func aDirtyTakeLeavesAQuietSavepointOfWhatIsAboutToBeOverwritten() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "the first paragraph", at: .end)

            let committed = try ops.insureTakes([minted.variant.id])
            #expect(committed.count == 1)
            #expect(committed[0].kind == .auto)
            #expect(committed[0].text == "the first paragraph")

            // …and it really is the state BEFORE the edit: the compound's
            // write lands after, and the savepoint still reads the old text.
            try ops.autosave(minted.variant.id, text: "the fir", charDelta: 12)
            let saved = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT text FROM commit_point WHERE variant_id = ? ORDER BY created_at",
                    arguments: [minted.variant.id])
            }
            #expect(saved == ["the first paragraph"])
        }
    }

    /// Deduped against the take's OWN last commit — the five occasions before
    /// it share this rule (`isDirty`), and a gesture must not stack identical
    /// savepoints on a take nobody has touched.
    @Test func aTakeAlreadySavedAtItsCurrentTextWritesNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "settled", at: .end)
            _ = try ops.commit(minted.variant.id)

            let nothing = try ops.insureTakes([minted.variant.id])
            #expect(nothing.isEmpty)
            #expect(
                try db.fetchInt(
                    "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                    [minted.variant.id]) == 1)
        }
    }

    /// A repeated id is one take, not two savepoints — the compound hands it
    /// the edges it plans to edit and must not have to de-duplicate first.
    @Test func aRepeatedTakeIsInsuredOnce() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "one", at: .end)
            let committed = try ops.insureTakes(
                [minted.variant.id, minted.variant.id, minted.variant.id])
            #expect(committed.count == 1)
        }
    }

    /// Locked takes are SKIPPED, never thrown on: `lockVariant` already
    /// insured exactly this buffer (the guard insures what it protects), and
    /// an insurance pass must never be the thing that decides a gesture.
    /// Archived, tombstoned and absent takes skip for the same reason.
    @Test func lockedArchivedAndVanishedTakesAreSkippedNotThrownOn() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let a = try ops.newBlock(in: post.id, text: "alpha", at: .end)
            let b = try ops.newBlock(in: post.id, text: "beta", at: .end)
            let second = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.lockVariant(a.variant.id)
            try ops.archiveVariant(second.id)

            let committed = try ops.insureTakes(
                [a.variant.id, second.id, "no-such-variant", b.variant.id])
            // Only the one live, active, unlocked, dirty take.
            #expect(committed.map(\.variantId) == [b.variant.id])
        }
    }

    /// The SEAL refuses — it freezes everything under the post, and this
    /// occasion is no exception (a sealed note's buffers were insured when it
    /// was sealed). The compound's own refusal fires first in the app; this
    /// pin holds the operation honest on its own.
    @Test func aSealedNoteRefusesTheInsurancePass() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "alpha", at: .end)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.self) {
                try ops.insureTakes([minted.variant.id])
            }
        }
    }

    /// **NOT a cadence occasion.** `savepoint_cadence` governs the two
    /// CADENCE occasions (`idleAutoCommit`, `closeAutoCommit`); the insurance
    /// occasions are on in every mode, because turning savepoints down must
    /// never turn protection off (13j J11's own line).
    @Test func theInsuranceRunsEvenWhenSavepointCadenceIsTurnedDown() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "alpha", at: .end)
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO setting (key, value) VALUES ('savepoint_cadence', 'only_on_commit')
                        ON CONFLICT(key) DO UPDATE SET value = excluded.value
                        """)
            }
            let cadence = try ops.closeAutoCommit(post.id)  // the cadence occasion stands down…
            #expect(cadence.isEmpty)
            let insured = try ops.insureTakes([minted.variant.id])  // …the insurance does not
            #expect(insured.count == 1)
        }
    }

    /// An empty list is a no-op — the compound that edits nothing (every
    /// touched block covered whole) asks for nothing.
    @Test func nothingToInsureWritesNothing() throws {
        try withOperations { ops, _ in
            let nothing = try ops.insureTakes([])
            #expect(nothing.isEmpty)
        }
    }
}
