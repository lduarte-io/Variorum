//
//  SearchIndexCaptureTests.swift
//  VariorumCoreTests
//
//  13o U1, P5 + P6 — the derived search family's CAPTURE (R-13o-4's third
//  trigger family) across all three writing layers — OPERATIONS, the
//  tombstone CASCADES, and a fake-server REMOTE APPLY — plus the
//  tombstone/archive transitions, the own-row facts (F3), accent/case
//  folding (R-13o-11), the rebuild door's idempotence, and the integrity
//  check's nets. The red-on-old record (each layer's pin red with its
//  trigger dropped, verified by revert) is in the plan's U1 RECORD.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// The doc keys ("kind:src_id", sorted) an FTS5 MATCH finds — read straight
/// off the index, so these pins see exactly what the triggers wrote.
func searchHits(_ db: AppDatabase, _ match: String) throws -> [String] {
    try db.read { db in
        try String.fetchAll(db, sql: """
            SELECT d.kind || ':' || d.src_id FROM search_fts
            JOIN search_doc d ON d.id = search_fts.rowid
            WHERE search_fts MATCH ? ORDER BY d.kind, d.src_id
            """, arguments: [match])
    }
}

private func doc(_ db: AppDatabase, _ kind: String, _ srcID: String) throws -> Row? {
    try db.read { db in
        try Row.fetchOne(db, sql: "SELECT * FROM search_doc WHERE kind = ? AND src_id = ?",
                         arguments: [kind, srcID])
    }
}

@Suite("13o — the search index's capture (three layers)")
struct SearchIndexCaptureTests {
    // MARK: - Layer 1: operations

    @Test func theOperationsLayerIsCapturedForEveryKindAndEveryEdit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Lighthouse Diary")
            #expect(try searchHits(db, "lighthouse") == ["title:\(post.id)"])

            let minted = try ops.newBlock(in: post.id, text: "The keeper climbs the stair")
            let block = minted.block.id
            let take = minted.variant.id
            #expect(try searchHits(db, "keeper") == ["take:\(take)"])

            // An autosave retires the OLD words and indexes the NEW.
            try ops.autosave(take, text: "The warden climbs the stair", charDelta: 6)
            #expect(try searchHits(db, "keeper").isEmpty)
            #expect(try searchHits(db, "warden") == ["take:\(take)"])

            // A branch is a second live take — both are indexed (R-13o-6:
            // ALL live active takes, not only the rendered one).
            let branch = try ops.branchVariant(block, from: take)
            #expect(try searchHits(db, "warden") == ["take:\(branch.id)", "take:\(take)"].sorted())

            try ops.setTakeLabel(branch.id, label: "gentler version")
            #expect(try searchHits(db, "gentler") == ["take_label:\(branch.id)"])
            try ops.setTakeLabel(branch.id, label: nil)
            #expect(try searchHits(db, "gentler").isEmpty, "a cleared label leaves the index")

            try ops.setBlockName(block, name: "opening gambit")
            #expect(try searchHits(db, "gambit") == ["block_name:\(block)"])

            try ops.updateFloatingNotes(post.id, notes: "margin musings")
            #expect(try searchHits(db, "musings") == ["note_meta:\(post.id)"])

            let comment = try ops.addBlockComment(to: block, text: "check the tide tables")
            #expect(try searchHits(db, "tide") == ["comment:\(comment.id)"])
            try ops.editBlockComment(comment.id, text: "check the moon tables")
            #expect(try searchHits(db, "tide").isEmpty)
            #expect(try searchHits(db, "moon") == ["comment:\(comment.id)"])
            try ops.deleteBlockComment(comment.id)
            #expect(try searchHits(db, "moon").isEmpty, "a deleted comment leaves the index")
            try ops.restoreBlockComment(comment.id)
            #expect(try searchHits(db, "moon") == ["comment:\(comment.id)"], "…and comes back with it")

            let book = try ops.createReading(name: "Coastal Book", kind: .book)
            #expect(try searchHits(db, "coastal") == ["book:\(book.id)"])
            try ops.renameReading(book.id, name: "Inland Book")
            #expect(try searchHits(db, "coastal").isEmpty)
            #expect(try searchHits(db, "inland") == ["book:\(book.id)"])

            let chapter = try ops.createSection(in: book.id, name: "Harbour Chapter")
            #expect(try searchHits(db, "harbour") == ["chapter:\(chapter.id)"])
            try ops.renameSection(chapter.id, name: "Quay Chapter")
            #expect(try searchHits(db, "quay") == ["chapter:\(chapter.id)"])
            try ops.deleteSection(chapter.id)
            #expect(try searchHits(db, "quay").isEmpty)

            try ops.renameContainer(post.id, title: nil)
            #expect(try searchHits(db, "lighthouse").isEmpty, "a cleared title leaves the index")

            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    @Test func archiveTransitionsFlagTheDocAndTombstonesDropIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Archive Probe")
            let minted = try ops.newBlock(in: post.id, text: "a sturdy paragraph")
            let branch = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(branch.id, text: "a flimsy paragraph", charDelta: 1)

            try ops.archiveVariant(branch.id)
            #expect(try doc(db, "take", branch.id)?["archived"] == true,
                    "an archived take stays indexed, carrying its own fact (R-13o-6)")
            #expect(try searchHits(db, "flimsy") == ["take:\(branch.id)"])
            try ops.unarchiveVariant(branch.id)
            #expect(try doc(db, "take", branch.id)?["archived"] == false)

            try ops.archiveContainer(post.id)
            #expect(try doc(db, "title", post.id)?["archived"] == true,
                    "a note's OWN fact on its own title doc")
            #expect(try doc(db, "take", minted.variant.id)?["archived"] == false,
                    "a take's doc carries only ITS OWN row's fact — the note's archive is resolved at query time (F3)")

            try ops.deleteVariant(branch.id)
            #expect(try doc(db, "take", branch.id) == nil, "a tombstoned take leaves the index")
            #expect(try searchHits(db, "flimsy").isEmpty)
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    @Test func ownFactsFollowTheirSourceRowWhicheverLayerWrites() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Wing Probe")
            let book = try ops.createReading(name: "Wing Book", kind: .book)
            #expect(try doc(db, "title", post.id)?["wing_id"] == "")
            // A raw write (a repair, a remote apply, a wing move — any layer).
            try db.write { db in
                try db.execute(sql: "UPDATE container SET wing_id = 'w2' WHERE id = ?", arguments: [post.id])
                try db.execute(sql: "UPDATE reading SET wing_id = 'w2', archived_at = 'x' WHERE id = ?", arguments: [book.id])
            }
            #expect(try doc(db, "title", post.id)?["wing_id"] == "w2")
            #expect(try doc(db, "book", book.id)?["wing_id"] == "w2")
            #expect(try doc(db, "book", book.id)?["archived"] == true)
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    @Test func accentsAndCaseFoldThroughTheCapture() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "placeholder")
            try ops.autosave(minted.variant.id, text: "Le RÉSUMÉ du Café naïf", charDelta: 10)
            #expect(try searchHits(db, "resume cafe naif") == ["take:\(minted.variant.id)"])
            #expect(try searchHits(db, "\"res\" *") == ["take:\(minted.variant.id)"], "the prefix index folds too")
        }
    }

    // MARK: - Layer 2: the tombstone cascades (writes no operation makes)

    @Test func theCascadesAreCapturedThoughNoOperationTouchesTheChildren() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Cascading Probe")
            try ops.updateFloatingNotes(post.id, notes: "drifting margin")
            let first = try ops.newBlock(in: post.id, text: "first anchor paragraph")
            let second = try ops.newBlock(in: post.id, text: "second anchor paragraph")
            let label = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.setTakeLabel(label.id, label: "anchored label")
            try ops.setBlockName(first.block.id, name: "anchored name")
            let comment = try ops.addBlockComment(to: first.block.id, text: "anchored comment")

            // deleteBlock writes ONE row (the block); the block cascade writes
            // its takes and comments — the capture must ride the cascade.
            try ops.deleteBlock(first.block.id)
            #expect(try searchHits(db, "anchored").isEmpty,
                    "the block's name, its takes' label and its comment left with the cascade")
            #expect(try searchHits(db, "anchor") == ["take:\(second.variant.id)"],
                    "the cascade took only the deleted block's fields")
            _ = try ops.restoreBlock(first.block.id)
            #expect(try searchHits(db, "anchored") == [
                "block_name:\(first.block.id)", "comment:\(comment.id)", "take_label:\(label.id)",
            ].sorted(), "the exact-stamp revival brings every cascade victim's field back")

            // A note's tombstone cascades to every block, then every take.
            try ops.deleteContainer(post.id)
            #expect(try searchHits(db, "anchor OR anchored OR drifting OR cascading").isEmpty)
            try ops.restoreContainer(post.id)
            #expect(try searchHits(db, "anchor").count == 3, "two takes of the first block + the second")
            #expect(try searchHits(db, "drifting") == ["note_meta:\(post.id)"])

            // A book's tombstone cascades to its chapters.
            let book = try ops.createReading(name: "Cascade Book", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "Cascade Chapter")
            try ops.deleteReading(book.id)
            #expect(try searchHits(db, "cascade").isEmpty, "the book and (by cascade) its chapter")
            try ops.restoreReading(book.id)
            #expect(try searchHits(db, "cascade") == ["book:\(book.id)", "chapter:\(chapter.id)"].sorted())

            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    @Test func aPhysicalDeleteRetiresTheDoc() throws {
        // The purge janitor's road (physical DELETE) — exercised on a live
        // comment, the one source with no FK children.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "x")
            let comment = try ops.addBlockComment(to: minted.block.id, text: "ephemeral remark")
            try db.write { db in
                try db.execute(sql: "DELETE FROM block_comment WHERE id = ?", arguments: [comment.id])
            }
            #expect(try searchHits(db, "ephemeral").isEmpty)
            #expect(try ops.verifySearchIndex().isHealthy)
        }
    }

    // MARK: - Layer 3: remote apply (the fake server)

    @Test func aRemoteApplyIsCapturedExactlyLikeALocalWrite() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        let (postID, takeID): (String, String) = try mac.with { ops, _ in
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "harbor lights at dusk")
            _ = try ops.addBlockComment(to: minted.block.id, text: "verify the beacon")
            return (post.id, minted.variant.id)
        }
        _ = try await syncToQuiescence(mac, phone, server: server)
        // The phone's rows arrived through SyncRow.apply under the apply flag
        // — no operation ran on the phone, and the index has them all.
        #expect(try searchHits(phone.db, "harbor") == ["take:\(takeID)", "title:\(postID)"].sorted())
        #expect(try searchHits(phone.db, "beacon").count == 1)

        try phone.with { ops, _ in
            try ops.autosave(takeID, text: "harbor fog at dawn", charDelta: 8)
        }
        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try searchHits(mac.db, "lights").isEmpty, "the remote text edit retired the old words")
        #expect(try searchHits(mac.db, "fog") == ["take:\(takeID)"])

        try phone.with { ops, _ in try ops.deleteContainer(postID) }
        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try searchHits(mac.db, "harbor OR fog OR beacon").isEmpty,
                "a remote tombstone (and the local cascade it fires) retires everything")

        for client in [mac, phone] {
            #expect(try client.with { ops, _ in try ops.verifySearchIndex() }.isHealthy)
            let derivedInOutbox = try client.db.fetchString(
                "SELECT count(*) FROM sync_outbox WHERE table_name LIKE 'search%'")
            #expect(derivedInOutbox == "0", "the derived family never reaches the outbox")
        }
    }

    @Test func aWholeRowRemoteRewriteWithTheSameValuesWritesNothingToTheIndex() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Same Values")
            let minted = try ops.newBlock(in: post.id, text: "unchanged words")
            let table = try #require(SyncSchema.table(named: "variant"))
            let fetched: SyncRow? = try db.read { (db: Database) throws -> SyncRow? in
                try SyncRow.fetch(db, table: table, rowID: minted.variant.id)
            }
            let row = try #require(fetched)
            let changes = try db.applyingRemote { db -> Int in
                let before = db.totalChangesCount
                try row.apply(db)
                return db.totalChangesCount - before
            }
            #expect(changes == 1, "the variant row only — every capture trigger's WHEN held it back")
            #expect(try searchHits(db, "unchanged") == ["take:\(minted.variant.id)"])
        }
    }

    // MARK: - The rebuild door + the integrity check (P5)

    @Test func theRebuildIsIdempotentAndWritesNoSyncedRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Rebuild Probe")
            let minted = try ops.newBlock(in: post.id, text: "rebuildable words")
            _ = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.setBlockName(minted.block.id, name: "named rebuild")
            let before = try searchHits(db, "rebuild*")
            let outbox = try db.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 }

            let first = try ops.rebuildSearchIndex()
            #expect(first.isHealthy)
            #expect(try searchHits(db, "rebuild*") == before, "the rebuild re-derives the same doc set")
            let second = try ops.rebuildSearchIndex()
            #expect(second == first, "idempotent")
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 } == outbox,
                    "the derived family writes no synced row")
            #expect(first.docCount == 4, "the title, two takes, the block name — one doc per live field")
        }
    }

    @Test func theIntegrityCheckNamesEachKindOfDrift() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Drift Probe")
            let minted = try ops.newBlock(in: post.id, text: "honest words")
            let comment = try ops.addBlockComment(to: minted.block.id, text: "a remark")
            #expect(try ops.verifySearchIndex().isHealthy)

            // A doc removed behind the index's back → MISSING; a doc of a dead
            // source → ORPHANED; a wrong own fact → FACT DRIFT.
            try db.write { db in
                try db.execute(sql: "DELETE FROM search_doc WHERE kind = 'comment'")
                try db.execute(sql: "INSERT INTO search_doc (kind, src_id) VALUES ('take', 'no-such-variant')")
                try db.execute(sql: "UPDATE search_doc SET archived = 1 WHERE kind = 'take' AND src_id = ?",
                               arguments: [minted.variant.id])
            }
            let report = try ops.verifySearchIndex()
            #expect(report.missing == [SearchDocKey(kind: "comment", srcID: comment.id)])
            #expect(report.orphaned == [SearchDocKey(kind: "take", srcID: "no-such-variant")])
            #expect(report.factDrift == [SearchDocKey(kind: "take", srcID: minted.variant.id)])
            #expect(!report.isHealthy)

            let healed = try ops.rebuildSearchIndex()
            #expect(healed.isHealthy, "the rebuild door heals every class")
            #expect(try searchHits(db, "remark") == ["comment:\(comment.id)"])
        }
    }

    // MARK: - The trigger family, by introspection

    /// The third family's exact set, pinned the way `TriggerCoverageTests`
    /// pins the cascades: adding or losing a capture trigger is a visible
    /// diff. Three per source field (F2's eight kinds + VX-72's ninth, the
    /// savepoint — `v1_23`).
    ///
    /// JUSTIFIED EDIT (VX-72): the count 24 → 27, and the mechanical-only
    /// check made SOURCE-AWARE — it used to list a fixed set of "other"
    /// tables that included `commit_point`, which a savepoint trigger now
    /// names as its OWN source in its ON clause; it now refuses EVERY table
    /// in the schema but the trigger's own source and the derived family
    /// (strictly stronger: a savepoint trigger reading `variant` — the
    /// FORK 1 shape the ruling refused — turns it red).
    @Test func theCaptureTriggerSetIsExactlyThreePerSourceField() throws {
        let db = try AppDatabase.inMemory()
        let names = try db.read { db in
            Set(try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type = 'trigger' AND name LIKE 'search\\_%' ESCAPE '\\'"))
        }
        let expected: Set<String> = Set(SearchIndex.sources.flatMap { source in
            ["insert", "update", "delete"].map { "search_\(source.table)_\(source.kind)_\($0)" }
        })
        #expect(expected.count == 27)
        #expect(names == expected)
        // Mechanical only (R-13o-4): no capture trigger body names any table
        // but its own source (in its ON clause) and the derived family.
        let schemaTables = try db.read { db in
            Set(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'grdb_%'
                """))
        }.subtracting(SearchIndex.tables)
        #expect(schemaTables.contains("variant") && schemaTables.contains("commit_point"))
        for name in names {
            let (sql, ownTable) = try #require(try db.read { db -> (String, String)? in
                try Row.fetchOne(db, sql: "SELECT sql, tbl_name FROM sqlite_master WHERE name = ?", arguments: [name])
                    .map { ($0["sql"], $0["tbl_name"]) }
            })
            for table in schemaTables.subtracting([ownTable]) {
                #expect(!sql.contains(" \(table) ") && !sql.contains(" \(table)\n") && !sql.contains(" \(table);"),
                        "\(name) reads \(table) — a capture trigger reads only NEW/OLD and the derived family")
            }
        }
    }
}
