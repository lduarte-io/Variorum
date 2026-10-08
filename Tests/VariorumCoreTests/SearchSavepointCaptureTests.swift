//
//  SearchSavepointCaptureTests.swift
//  VariorumCoreTests
//
//  VX-72 (the 13o follow-up run's U-C — her R-VX83-5, "search what you
//  saved"), P2 — the NINTH doc kind's capture across every road that writes a
//  savepoint: the OPERATIONS (a manual commit, the quiet auto occasions,
//  restore, a rename), the TAKE's own reach (tombstone + Put back — the
//  savepoint doc mirrors its ROW, the take's liveness is the query's: FORK 1 =
//  A, the §U-C RULINGS' condition 3), a fake-server REMOTE APPLY (incl. the
//  arrival-order case — a savepoint landing under a take this device holds
//  dead), the purge JANITOR's physical delete (prune and family purge —
//  condition 1), and the UPDATE arm's insurance (condition 1). The red-on-old
//  record (each road's pin red with its trigger dropped, verified by revert)
//  is in the run record's §U-C RECORD.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// Everything the derived family holds, as one string: the FTS5 segment rows
/// AND the doc rows. Equal before and after an act ⇔ the act wrote nothing
/// to the index.
private func indexFingerprint(_ db: AppDatabase) throws -> String {
    try db.read { db in
        let data = try String.fetchOne(db, sql: """
            SELECT group_concat(id || ':' || hex(block), ',') FROM (SELECT id, block FROM search_fts_data ORDER BY id)
            """) ?? ""
        let docs = try String.fetchOne(db, sql: """
            SELECT group_concat(id || ':' || kind || ':' || src_id || ':' || ifnull(variant_id, '-'), ',')
            FROM (SELECT * FROM search_doc ORDER BY id)
            """) ?? ""
        return data + "|" + docs
    }
}

/// A savepoint doc's own parent fact (nil when there is no such doc).
private func savepointParent(_ db: AppDatabase, _ commitID: String) throws -> String? {
    try db.read { db in
        try String.fetchOne(db, sql: "SELECT variant_id FROM search_doc WHERE kind = 'savepoint' AND src_id = ?",
                            arguments: [commitID])
    }
}

/// The newest savepoint of a take.
private func newestCommit(_ db: AppDatabase, _ variantID: String) throws -> String? {
    try db.read { db in
        try String.fetchOne(db, sql: """
            SELECT id FROM commit_point WHERE variant_id = ? ORDER BY created_at DESC, id DESC LIMIT 1
            """, arguments: [variantID])
    }
}

@Suite("VX-72 — the savepoint kind's capture (every road that writes one)")
struct SearchSavepointCaptureTests {
    // MARK: - The operations

    @Test func everySavepointRoadIsCapturedAndASavedTextNeverMoves() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "lanterns along the quay")
            let take = minted.variant.id

            // A deliberate ⌘S savepoint.
            let manual = try ops.commit(take)
            #expect(try searchHits(db, "lanterns") == ["savepoint:\(manual.id)", "take:\(take)"].sorted())
            #expect(try savepointParent(db, manual.id) == take, "its own parent fact (F3)")

            // The take moves on; the savepoint keeps the words it saved.
            try ops.autosave(take, text: "lamps along the quay", charDelta: 4)
            #expect(try searchHits(db, "lanterns") == ["savepoint:\(manual.id)"],
                    "the take's doc retired the old words; the savepoint's did not move")

            // A quiet auto savepoint — leaving the note with unsaved changes.
            let closed = try ops.closeAutoCommit(post.id)
            let close = try #require(closed.first)
            #expect(try searchHits(db, "lamps") == ["savepoint:\(close.id)", "take:\(take)"].sorted())

            // Another — locking a dirty take insures it.
            try ops.autosave(take, text: "torches along the quay", charDelta: 5)
            try ops.lockVariant(take)
            let lock = try #require(try newestCommit(db, take))
            #expect(try searchHits(db, "torches") == ["savepoint:\(lock)", "take:\(take)"].sorted())

            // Restore loads a savepoint into the BUFFER: the take's doc follows;
            // no savepoint doc moves.
            try ops.unlockVariant(take)
            try ops.restoreCommit(take, commitID: manual.id)
            #expect(try searchHits(db, "lanterns") == ["savepoint:\(manual.id)", "take:\(take)"].sorted())
            #expect(try searchHits(db, "torches") == ["savepoint:\(lock)"])

            // Naming a savepoint after the fact writes `message` — never
            // indexed, never retired: the index does not change at all.
            let before = try indexFingerprint(db)
            #expect(try ops.renameCommitPoint(manual.id, message: "the first draft"))
            #expect(try indexFingerprint(db) == before)
            #expect(try searchHits(db, "draft").isEmpty, "a savepoint's NAME is not its text")

            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    // MARK: - The take's reach (condition 3 — the doc mirrors the ROW)

    /// FORK 1 = A: the savepoint doc mirrors its `commit_point` row, so a
    /// dead take's savepoints LINGER in the index — and the integrity check
    /// reads them as CORRECT (doc ⇔ the physical row), never as drift. Whether
    /// they LIST is the composer's (P3's fence pins).
    @Test func aDeadTakesSavepointsLingerAsCorrectNeverAsDrift() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Reach Probe")
            let minted = try ops.newBlock(in: post.id, text: "the original harbor")
            let branch = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(branch.id, text: "a branched harbor", charDelta: 3)
            let saved = try ops.commit(branch.id)
            let main = try ops.commit(minted.variant.id)
            let lingering = ["savepoint:\(main.id)", "savepoint:\(saved.id)"].sorted()

            try ops.deleteVariant(branch.id)
            #expect(try searchHits(db, "branched") == ["savepoint:\(saved.id)"],
                    "the take's own doc left with its tombstone; its savepoint's stays")
            #expect(try savepointParent(db, saved.id) == branch.id)
            #expect(try ops.verifySearchIndex().isHealthy, "a dead take's savepoint is CORRECT, not drift")

            // The block's tombstone cascades to every take; no savepoint moves.
            try ops.deleteBlock(minted.block.id)
            #expect(try searchHits(db, "harbor").filter { $0.hasPrefix("savepoint:") } == lingering)
            #expect(try searchHits(db, "harbor").filter { $0.hasPrefix("take:") }.isEmpty)
            #expect(try ops.verifySearchIndex().isHealthy)

            // Put back: the takes return; the savepoints never left.
            _ = try ops.restoreBlock(minted.block.id)
            #expect(try savepointParent(db, saved.id) == branch.id)
            #expect(try searchHits(db, "harbor").filter { $0.hasPrefix("savepoint:") } == lingering)
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    // MARK: - Remote apply (the fake server)

    @Test func aRemoteSavepointIsCapturedAndArrivalOrderNeverDropsOne() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        let (blockID, takeID, firstID): (String, String, String) = try mac.with { ops, _ in
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "harbor lights at dusk")
            let saved = try ops.commit(minted.variant.id)
            return (minted.block.id, minted.variant.id, saved.id)
        }
        _ = try await syncToQuiescence(mac, phone, server: server)
        // The phone's savepoint arrived through SyncRow.apply — no operation
        // ran on the phone, and its index has it.
        #expect(try searchHits(phone.db, "dusk") == ["savepoint:\(firstID)", "take:\(takeID)"].sorted())
        #expect(try savepointParent(phone.db, firstID) == takeID)

        // A rename on the phone arrives at the Mac as a whole-row UPDATE: the
        // UPDATE arm's guard holds it at zero index work.
        try phone.with { ops, _ in _ = try ops.renameCommitPoint(firstID, message: "evening") }
        let macBefore = try indexFingerprint(mac.db)
        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try mac.db.fetchString("SELECT message FROM commit_point WHERE id = ?", [firstID]) == "evening",
                "the rename arrived")
        #expect(try indexFingerprint(mac.db) == macBefore, "…and wrote nothing to the index")

        // ARRIVAL ORDER: the phone deletes the block while the Mac, offline,
        // saves the take again — the phone then receives a savepoint under a
        // take it holds DEAD. The doc mirrors the row: indexed, never dropped.
        try phone.with { ops, _ in try ops.deleteBlock(blockID) }
        let secondID: String = try mac.with { ops, _ in
            try ops.autosave(takeID, text: "harbor fog at dawn", charDelta: 8)
            return try ops.commit(takeID).id
        }
        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try phone.db.deletedAt("variant", takeID) != nil, "the phone holds the take dead")
        #expect(try searchHits(phone.db, "dawn").contains("savepoint:\(secondID)"),
                "a savepoint arriving under a dead take is indexed — its row exists (condition 3)")
        #expect(try savepointParent(phone.db, secondID) == takeID)

        for client in [mac, phone] {
            #expect(try client.with { ops, _ in try ops.verifySearchIndex() }.isHealthy)
            let derivedInOutbox = try client.db.fetchString(
                "SELECT count(*) FROM sync_outbox WHERE table_name LIKE 'search%'")
            #expect(derivedInOutbox == "0", "the derived family never reaches the outbox")
        }
    }

    // MARK: - The janitor's physical delete (condition 1)

    @Test func theJanitorsPhysicalDeleteRetiresTheSavepoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Prune Probe")
            let minted = try ops.newBlock(in: post.id, text: "first saved anchor")
            let pruned = try ops.commit(minted.variant.id, kind: .auto)
            try ops.autosave(minted.variant.id, text: "second saved anchor", charDelta: 6)
            let kept = try ops.commit(minted.variant.id)

            // Savepoint PRUNING: the row itself is the family (a commit_point
            // root) — its own DELETE retires its doc and its FTS entry.
            try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let family = try PurgeFamily.expand(
                    db, roots: [SyncPurgeTarget(table: "commit_point", rowID: pruned.id)])
                try PurgeFamily.deleteLocal(db, family: family, stamp: "2026-08-19T00:00:00.000Z")
            }
            #expect(try searchHits(db, "first").isEmpty, "the pruned savepoint left the index")
            #expect(try searchHits(db, "anchor") == ["savepoint:\(kept.id)", "take:\(minted.variant.id)"].sorted())
            #expect(try ops.verifySearchIndex().isHealthy)

            // A FAMILY purge (a deleted block's, past the horizon): every take's
            // savepoints go with it.
            try ops.deleteBlock(minted.block.id)
            try db.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let family = try PurgeFamily.expand(
                    db, roots: [SyncPurgeTarget(table: "block", rowID: minted.block.id)])
                try PurgeFamily.deleteLocal(db, family: family, stamp: "2026-08-19T00:00:00.000Z")
            }
            #expect(try searchHits(db, "anchor").isEmpty)
            #expect(try db.fetchInt("SELECT count(*) FROM search_doc WHERE kind = 'savepoint'") == 0)
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    // MARK: - The UPDATE arm (condition 1 — load-bearing insurance)

    @Test func theUpdateArmKeepsTheIndexHonestUnderAnyRowRewrite() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "x")
            try ops.autosave(minted.variant.id, text: "unchanged saved words", charDelta: 20)
            let saved = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "the take moved on", charDelta: 10)

            // (a) remote apply's generic whole-row rewrite with the SAME values
            // costs the index nothing.
            let table = try #require(SyncSchema.table(named: "commit_point"))
            let fetched: SyncRow? = try db.read { (db: Database) throws -> SyncRow? in
                try SyncRow.fetch(db, table: table, rowID: saved.id)
            }
            let row = try #require(fetched)
            let changes = try db.applyingRemote { db -> Int in
                let before = db.totalChangesCount
                try row.apply(db)
                return db.totalChangesCount - before
            }
            #expect(changes == 1, "the commit_point row only — the UPDATE arm's WHEN held it back")
            #expect(try searchHits(db, "unchanged") == ["savepoint:\(saved.id)"])

            // (b) a rewrite that DOES change the text (no domain road writes
            // one — I5 — but a generic UPDATE could carry it): the index follows
            // in the same statement, F1's contract.
            try db.write { db in
                try db.execute(sql: "UPDATE commit_point SET text = 'rewritten saved words' WHERE id = ?",
                               arguments: [saved.id])
            }
            #expect(try searchHits(db, "unchanged").isEmpty)
            #expect(try searchHits(db, "rewritten") == ["savepoint:\(saved.id)"])
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    // MARK: - The rebuild door + the integrity check cover the ninth kind

    @Test func theRebuildAndTheIntegrityCheckCoverTheNinthKind() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Rebuild Probe")
            let minted = try ops.newBlock(in: post.id, text: "rebuildable words")
            let saved = try ops.commit(minted.variant.id)
            let before = try searchHits(db, "rebuildable")
            #expect(before == ["savepoint:\(saved.id)", "take:\(minted.variant.id)"].sorted())

            let first = try ops.rebuildSearchIndex()
            #expect(first.isHealthy)
            #expect(first.docCount == 3, "the title, the take, the savepoint")
            #expect(try searchHits(db, "rebuildable") == before, "the rebuild re-derives the savepoint")
            #expect(try ops.rebuildSearchIndex() == first, "idempotent")

            // MISSING / ORPHANED / FACT DRIFT, each named on the ninth kind.
            let other = try ops.commit(minted.variant.id, message: "second")
            try db.write { db in
                try db.execute(sql: "DELETE FROM search_doc WHERE kind = 'savepoint' AND src_id = ?",
                               arguments: [saved.id])
                try db.execute(sql: "INSERT INTO search_doc (kind, src_id, variant_id) VALUES ('savepoint', 'no-such-commit', 'v')")
                try db.execute(sql: "UPDATE search_doc SET variant_id = 'wrong' WHERE kind = 'savepoint' AND src_id = ?",
                               arguments: [other.id])
            }
            let report = try ops.verifySearchIndex()
            #expect(report.missing == [SearchDocKey(kind: "savepoint", srcID: saved.id)])
            #expect(report.orphaned == [SearchDocKey(kind: "savepoint", srcID: "no-such-commit")])
            #expect(report.factDrift == [SearchDocKey(kind: "savepoint", srcID: other.id)])
            #expect(try ops.rebuildSearchIndex().isHealthy, "the rebuild door heals every class")
        }
    }
}
