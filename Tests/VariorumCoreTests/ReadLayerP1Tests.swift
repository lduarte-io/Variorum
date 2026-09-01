//
//  ReadLayerP1Tests.swift
//  VariorumCoreTests
//
//  Pre-13u round, Act 4 — the pins for 17c's four read-layer findings
//  (P18–P21). All four were traced by READING; these are the red-on-old
//  pins the standing rule demands, and they are written as **shape** facts
//  — query plans and statement counts — rather than timings, so they cannot
//  pass or fail with machine load (the P48 lesson: a pin that cannot fail
//  is a hole in the mechanism every review depends on).
//
//  The measured before/after numbers live in the batch record; each pin's
//  own comment names the one it belongs to.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// Runs `body` against the store while capturing every statement SQLite
/// executes (expanded, so each can be EXPLAINed as it really ran).
private func captureStatements(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> [String] {
    try db.read { database in
        let captured = LockIsolated<[String]>([])
        let capturing = LockIsolated(true)
        database.trace(options: .statement) { event in
            guard capturing.value, case .statement(let statement) = event else { return }
            // `TraceEvent.Statement` is not Sendable, so the SQL is read
            // right here and only the String escapes the closure.
            let sql = statement.expandedSQL
            captured.withValue { $0.append(sql) }
        }
        try body(database)
        capturing.setValue(false)
        return captured.value
    }
}

/// The query plan of every SELECT-shaped statement `body` ran, joined.
private func capturedPlans(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> String {
    let statements = try captureStatements(db, body)
    return try db.read { database in
        var plans: [String] = []
        for sql in statements {
            let head = sql.trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(6).uppercased()
            guard head.hasPrefix("SELECT") || head.hasPrefix("WITH") else { continue }
            plans += try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }
        return plans.joined(separator: "\n")
    }
}

/// The harness stamps writes from the injected clock (2026-07-01, ticking
/// one second per read), so every 30-day recovery window in this file is
/// read from that clock too — `Date()` would put the fixtures outside it.
private let readLayerNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)

@Suite("17c — the read layer's P1 debt")
struct ReadLayerP1Tests {

    // MARK: - P18: the tray's takes listing

    /// RED ON OLD: the shipped statement began `FROM variant v` and reached
    /// the note only through `COALESCE(cb.container_id, b.last_container_id)
    /// = :post`, which nothing can seek — the measured plan opened with
    /// `SCAN v`, a full scan of the largest table in the store, inside a
    /// panel observation held while she types.
    @Test func theTrayTakesListingIsDrivenByTheNoteAndNeverScansTheVariantTable() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note")
            let block = try ops.newBlock(in: post.id, text: "one")
            let take = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.deleteVariant(take.id)

            let plan = try capturedPlans(db) { database in
                _ = try Queries.trayTakes(
                    database, postID: post.id, now: readLayerNow, limit: 500)
            }
            #expect(!plan.contains("SCAN variant"), "plan was:\n\(plan)")
            #expect(!plan.contains("SCAN v\n") && !plan.hasSuffix("SCAN v"),
                    "the variant table must never be scanned; plan was:\n\(plan)")
            // The note drives, exactly as the four sibling listings do.
            #expect(plan.contains("idx_cblock_order")
                    || plan.contains("idx_block_last_container"),
                    "the note must drive the listing; plan was:\n\(plan)")
        }
    }

    /// The rewrite is only legal if it selects the same rows. The COALESCE
    /// it replaced said: the block's home is its LIVE placement, falling
    /// back to `last_container_id` when it has none.
    @Test func theRewrittenTrayListingSelectsExactlyWhatTheCoalesceDid() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            let other = try ops.createPost(title: "another note")

            // (1) A take deleted on a block placed HERE — listed.
            let mine = try ops.newBlock(in: post.id, text: "mine")
            let mineTake = try ops.branchVariant(mine.block.id, from: mine.variant.id)
            try ops.deleteVariant(mineTake.id)

            // (2) A take deleted on a block that has since MOVED away — the
            // COALESCE resolved it to the other note, so it is not listed.
            let moved = try ops.newBlock(in: post.id, text: "moved")
            let movedTake = try ops.branchVariant(moved.block.id, from: moved.variant.id)
            try ops.deleteVariant(movedTake.id)
            try ops.moveBlock(moved.block.id, to: other.id, at: .end)

            // (3) A RELEASED original — live, unplaced, `last_container_id`
            // pointing here — still audits in the note it was released from.
            let released = try ops.newBlock(in: post.id, text: "released")
            let releasedTake = try ops.branchVariant(
                released.block.id, from: released.variant.id)
            try ops.deleteVariant(releasedTake.id)
            try db.write { database in
                try database.execute(
                    sql: """
                        UPDATE block SET last_container_id = ? WHERE id = ?
                        """, arguments: [post.id, released.block.id])
                try database.execute(
                    sql: "UPDATE container_block SET deleted_at = ? WHERE block_id = ?",
                    arguments: ["2026-08-30T00:00:00.000Z", released.block.id])
            }

            let listed = try db.read { database in
                try Queries.trayTakes(database, postID: post.id, now: readLayerNow)
            }
            #expect(Set(listed.map(\.blockID)) == [mine.block.id, released.block.id])

            // And the moved block's take audits in its NEW home.
            let there = try db.read { database in
                try Queries.trayTakes(database, postID: other.id, now: readLayerNow)
            }
            #expect(there.map(\.blockID) == [moved.block.id])
        }
    }

    // MARK: - P19: the Trash listing's peer lookup

    /// RED ON OLD: `trash()`'s `.note` arm called `versionOfNote` inside a
    /// `.map`, so the statement count grew with the number of deleted saved
    /// versions in the window — inside a held observation that re-fires at
    /// autosave rate. The count is now the same for one version and for ten.
    @Test func theTrashListingCostsTheSameStatementsHoweverManyVersionsItLists() throws {
        try withOperations { ops, db in
            func statementsForListing(deletedVersions: Int) throws -> Int {
                let post = try ops.createPost(title: "a note \(deletedVersions)")
                _ = try ops.newBlock(in: post.id, text: "body")
                for _ in 0..<deletedVersions {
                    let version = try ops.saveNoteVersion(post.id)
                    try ops.deleteContainer(version.post.id)
                }
                return try captureStatements(db) { database in
                    _ = try Queries.trash(database, now: readLayerNow, limit: 501)
                }.count
            }
            let one = try statementsForListing(deletedVersions: 1)
            let ten = try statementsForListing(deletedVersions: 10)
            #expect(one == ten,
                    Comment(rawValue: "the peer lookup must be ONE statement for the "
                            + "page, not one per version (\(one) vs \(ten))"))

            // …and it still answers: every deleted version names its note.
            let rows = try db.read { database in
                try Queries.trash(database, now: readLayerNow, limit: 501)
            }
            let versions = rows.filter(\.isVersion)
            #expect(versions.count == 11)
            #expect(versions.allSatisfy { $0.versionOfNoteID != nil })
        }
    }

    /// The batched door must answer exactly what the single-id door did,
    /// including its ordering rule: a LIVE peer wins over a dead one, and
    /// the lexically smallest id breaks the tie.
    @Test func theBatchedPeerLookupKeepsTheSingleDoorsAnswer() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: post.id, text: "body")
            let first = try ops.saveNoteVersion(post.id)
            let second = try ops.saveNoteVersion(post.id)

            let batched = try db.read { database in
                try Queries.versionsOfNotes(
                    database, versionIDs: [first.post.id, second.post.id])
            }
            #expect(batched[first.post.id]?.id == post.id)
            #expect(batched[second.post.id]?.id == post.id)

            // The single-id door delegates, so the two can never disagree.
            let single = try db.read { database in
                try Queries.versionOfNote(database, versionID: first.post.id)
            }
            #expect(single?.id == batched[first.post.id]?.id)
            #expect(single?.title == batched[first.post.id]?.title)

            // An id with no version link answers nothing, as before. (A
            // NOTE's own id is not that case: the link is symmetric, so
            // asking about the note names its version — which is exactly
            // what the single-id door always did.)
            let unrelated = try ops.createPost(title: "unrelated")
            let none = try db.read { database in
                try Queries.versionsOfNotes(database, versionIDs: [unrelated.id])
            }
            #expect(none.isEmpty)
        }
    }

    /// **The pre-13u midpoint review's m1.** The batched door built ONE
    /// `IN (…)` list however long the caller's list was, while its sibling
    /// `Queries.activeFans` had chunked at `fanChunk` for exactly this
    /// reason. The caller that makes the list long already exists:
    /// `trash(limit: nil)` makes it the whole 30-day deletion window, which
    /// 13w's automated rotation will fill at machine cadence.
    ///
    /// **What this pin claims, and what it does NOT.** It is a SHAPE pin,
    /// like its siblings above: with a thousand ids the door must issue more
    /// than one statement, which is red on the unchunked code (exactly one)
    /// and green here. It does NOT claim the parameter ceiling was reachable
    /// — that was checked rather than assumed, and on this SQLCipher build a
    /// 65,536-parameter `IN` list SUCCEEDS while 100,000 throws "too many SQL
    /// variables", so the ceiling is far above any list a real Trash window
    /// produces. The finding is a LATENT cliff plus an inconsistency with the
    /// sibling batcher, and this pin holds the fix's shape and its answer
    /// without pretending the cliff was live.
    @Test func theBatchedPeerLookupChunksItsParameterList() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: post.id, text: "body")
            let first = try ops.saveNoteVersion(post.id)
            let second = try ops.saveNoteVersion(post.id)
            let third = try ops.saveNoteVersion(post.id)

            // The three real ids at the head, ON the 400-boundary, and at
            // the tail, so the merge is exercised as a union ACROSS chunks —
            // a chunk-boundary answer that got dropped shows here and
            // nowhere else.
            var ids = (0..<1_000).map { "absent-\($0)" }
            ids[0] = first.post.id
            ids[400] = second.post.id
            ids[ids.count - 1] = third.post.id

            // SHAPE: one statement per chunk, not one for the whole list.
            let peerStatements = try captureStatements(db) { database in
                _ = try Queries.versionsOfNotes(database, versionIDs: ids)
            }.filter { $0.contains("peer_is_live") }
            #expect(peerStatements.count == 3,
                    Comment(rawValue: "1,000 ids must be read in chunks of "
                            + "\(Queries.fanChunk), not one unbounded IN list "
                            + "(\(peerStatements.count) statements)"))

            // ANSWER: the chunked result is the unchunked result.
            let batched = try db.read { database in
                try Queries.versionsOfNotes(database, versionIDs: ids)
            }
            #expect(batched.count == 3, "ids the store does not know answer nothing")
            #expect(batched[second.post.id]?.id == post.id,
                    "a version sitting exactly on a chunk boundary must still answer")
            let short = try db.read { database in
                try Queries.versionsOfNotes(
                    database,
                    versionIDs: [first.post.id, second.post.id, third.post.id])
            }
            #expect(short.count == batched.count)
            for (versionID, peer) in short {
                #expect(batched[versionID]?.id == peer.id)
                #expect(batched[versionID]?.title == peer.title)
            }
        }
    }

    // MARK: - P20: the version-history classifier

    /// RED ON OLD (before migration `v1_15`): the classifier's only
    /// non-subquery terms are `archived_at IS NOT NULL` and `archived_at =
    /// created_at`, neither indexed, so the plan was `SEARCH v USING INDEX
    /// idx_container_kind (kind=?)` — a walk of every post in the corpus,
    /// run by `deleteContainer` INSIDE its own write transaction even for a
    /// note with no saved versions.
    @Test func theVersionClassifierSeeksItsOwnIndexInsteadOfWalkingEveryPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note")
            _ = try ops.newBlock(in: post.id, text: "body")
            _ = try ops.saveNoteVersion(post.id)

            let plan = try capturedPlans(db) { database in
                _ = try Queries.noteVersionIDs(database, of: post.id)
            }
            #expect(plan.contains("idx_container_note_version"), "plan was:\n\(plan)")
            #expect(!plan.contains("SEARCH v USING INDEX idx_container_kind"),
                    "the classifier must not walk every post; plan was:\n\(plan)")
        }
    }

    /// The same index has to serve the `restoreContainer` road, which asks
    /// the classifier with a tombstone STAMP instead of `IS NULL`.
    @Test func theDeletedWithRoadSeeksTheSameIndex() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note")
            _ = try ops.newBlock(in: post.id, text: "body")
            _ = try ops.saveNoteVersion(post.id)
            try ops.deleteContainer(post.id)
            let stamp = try db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT deleted_at FROM container WHERE id = ?",
                    arguments: [post.id])
            }

            let plan = try capturedPlans(db) { database in
                _ = try Queries.versionHistoryDeletedWith(
                    database, note: post.id, stamp: stamp ?? "")
            }
            #expect(plan.contains("idx_container_note_version"), "plan was:\n\(plan)")
        }
    }

    // MARK: - P21: the takes projection's fan fetch

    /// RED ON OLD: `activeFans` ran one `Variant` fetch per block inside a
    /// Swift loop, and `takesProjection` hands it every non-gap slot of the
    /// post — then `observeTakes` holds that projection over a region that
    /// includes `variant`, so a note of N blocks issued N statements at
    /// autosave rate.
    @Test func theFanFetchIsOneStatementForTheWholeNote() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note")
            var blockIDs: [String] = []
            for i in 0..<40 {
                let block = try ops.newBlock(in: post.id, text: "block \(i)")
                _ = try ops.branchVariant(block.block.id, from: block.variant.id)
                blockIDs.append(block.block.id)
            }
            let statements = try captureStatements(db) { database in
                _ = try Queries.activeFans(database, blockIDs: blockIDs)
            }
            #expect(statements.count == 1,
                    "40 blocks must cost ONE statement, not 40 (was \(statements.count))")
        }
    }

    /// Batching is only legal if it returns the same dictionary: an entry
    /// for every block asked about (empty where the fan is), each fan in
    /// `(fan_position, id)` order.
    @Test func theBatchedFanFetchMatchesThePerBlockShape() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a note")
            let plain = try ops.newBlock(in: post.id, text: "plain")
            let fanned = try ops.newBlock(in: post.id, text: "fanned")
            let second = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let third = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            // An archived take is not part of the live fan…
            try ops.archiveVariant(third.id)
            // …and a block whose every take is archived answers with an
            // EMPTY array, never a missing key.
            let hidden = try ops.newBlock(in: post.id, text: "hidden")
            let hiddenTake = try ops.branchVariant(hidden.block.id, from: hidden.variant.id)
            try ops.archiveVariant(hiddenTake.id)

            let fans = try db.read { database in
                try Queries.activeFans(
                    database,
                    blockIDs: [plain.block.id, fanned.block.id, hidden.block.id,
                               "no-such-block"])
            }
            #expect(fans.keys.count == 4)
            #expect(fans[plain.block.id]?.map(\.id) == [plain.variant.id])
            #expect(fans[fanned.block.id]?.map(\.id) == [fanned.variant.id, second.id])
            #expect(fans[hidden.block.id]?.map(\.id) == [hidden.variant.id])
            #expect(fans["no-such-block"] == [])

            // Order is the fan's own, not insertion order: reposition the
            // second take ahead of the first and the answer follows.
            try db.write { database in
                try database.execute(
                    sql: "UPDATE variant SET fan_position = ? WHERE id = ?",
                    arguments: ["A0", second.id])
            }
            let reordered = try db.read { database in
                try Queries.activeFans(database, blockIDs: [fanned.block.id])
            }
            #expect(reordered[fanned.block.id]?.map(\.id) == [second.id, fanned.variant.id])
        }
    }
}
