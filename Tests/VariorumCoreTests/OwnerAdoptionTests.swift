import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VM-67 (the VM-64 run, batch 4) — LAUNCH AND UNLOCK STOP SCANNING EVERY TABLE.
// The record: `notes/plans/fixes/vm-64-timing-and-lags.md` (§5 / §7, batch 4).
//
// THE MECHANISM (audit F 3A/6A, re-verified): `AppServices.connectSyncIfAllowed`
// runs `Operations.adoptOwnerID` at every launch with a session, every unlock,
// every sign-in. It opened ONE write transaction and ran `UPDATE t SET owner_id =
// ? WHERE owner_id IS NULL` over every owner-carrying synced table; no index
// served `owner_id IS NULL`, so every statement was `SCAN t` — the whole corpus
// read (and decrypted) on every launch and unlock, holding the runner and the
// writer, even with nothing unowned.
//
// THE PINS (red on the pre-fix tree — the record names the revert and its result):
// 1. With nothing unowned, adoption runs NO write statement on the writer: no
//    BEGIN, no UPDATE, no COMMIT (a statement trace on the writer connection).
// 2. Every statement adoption runs reaches an owner table ONLY through that
//    table's unowned-row index (`EXPLAIN QUERY PLAN` of each traced statement) —
//    both when nothing is unowned and when something is.
// THE STATE TRANSITIONS (S4 — every row that needs an owner still gets one, on
// every road today's code adopts it): signed-out rows in every owner table, live
// and tombstoned; the mixed case; an account change; a write already queued on the
// writer when adoption is called; a store arriving whole from a build before the
// index.

/// One statement the writer ran, copied while SQLite still held it.
private struct TracedStatement: Sendable {
    let sql: String
    let expandedSQL: String

    var verb: String {
        String(sql.drop { $0.isWhitespace }.prefix { !$0.isWhitespace }).uppercased()
    }
}

/// Runs `body` with a statement trace on the store's WRITER connection (the one
/// every write — and, on an in-memory queue, every read — goes through), and
/// answers what ran. The trace is removed before this returns.
private func tracingTheWriter<T>(
    _ db: AppDatabase, _ body: () throws -> T
) throws -> (T, [TracedStatement]) {
    let log = LockIsolated<[TracedStatement]>([])
    try db.writeWithoutTransaction { connection in
        connection.trace(options: .statement) { event in
            guard case .statement(let statement) = event else { return }
            let entry = TracedStatement(sql: statement.sql, expandedSQL: statement.expandedSQL)
            log.withValue { $0.append(entry) }
        }
    }
    defer { try? db.writeWithoutTransaction { $0.trace(options: .statement, nil) } }
    let result = try body()
    return (result, log.value)
}

/// The synced tables whose live DDL carries `owner_id` (introspected — the
/// adoption's own truth source, never a hand list).
private func ownerTables(_ db: AppDatabase) throws -> [String] {
    try db.read { db in
        try SyncSchema.tables.map(\.name).filter { table in
            try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                .contains { ($0["name"] as String) == "owner_id" }
        }
    }
}

/// **The scan oracle.** For every data statement in `statements`, its query plan
/// (read after the trace is gone): each plan line that reads an owner table must
/// read it through that table's unowned-row index. Answers the violations and the
/// owner tables the plans reached.
private func planReadings(
    _ db: AppDatabase, _ statements: [TracedStatement], ownerTables: [String]
) throws -> (violations: [String], reached: Set<String>) {
    var violations: [String] = []
    var reached: Set<String> = []
    try db.writeWithoutTransaction { connection in
        for statement in statements where ["SELECT", "UPDATE", "DELETE", "INSERT", "WITH"].contains(statement.verb) {
            let details = try Row.fetchAll(connection, sql: "EXPLAIN QUERY PLAN " + statement.expandedSQL)
                .map { $0["detail"] as String }
            for detail in details {
                for table in ownerTables {
                    // `SCAN t …` / `SEARCH t …` (older SQLite: `SCAN TABLE t`) — the
                    // line reads `t` itself; `block` never matches `block_comment`.
                    let reads = ["SCAN \(table)", "SEARCH \(table)", "SCAN TABLE \(table)", "SEARCH TABLE \(table)"]
                        .contains { detail == $0 || detail.hasPrefix($0 + " ") }
                    guard reads else { continue }
                    reached.insert(table)
                    if !detail.contains("idx_\(table)_unowned") {
                        violations.append("\(statement.sql) → \(detail)")
                    }
                }
            }
        }
    }
    return (violations, reached)
}

private let stamp = "2026-11-19T00:00:00.000Z"

@Suite("VM-67 — owner adoption reads only the unowned rows, and writes nothing when there are none")
struct OwnerAdoptionTests {
    static let me = "vm67-0000-4000-8000-000000000001"
    static let other = "vm67-0000-4000-8000-000000000002"

    /// Adoption as `owner`, from a fresh `Operations` (the runner's shape).
    private func adopt(as owner: String) throws -> Operations.OwnerAdoptionReport {
        try withDependencies { $0.ownerIdentity = OwnerIdentity { owner } } operation: {
            try Operations().adoptOwnerID()
        }
    }

    /// A row in EVERY owner-carrying table, live, plus a tombstone in most —
    /// minted through the ordinary doors under whatever identity is ambient.
    /// Answers the ids by table. (A future owner-carrying table makes
    /// `everyOwnerTableHoldsARow` below red until it is seeded here.)
    @discardableResult
    private func mintInEveryOwnerTable(_ ops: Operations, _ label: String = "a") throws -> [String: [String]] {
        var ids: [String: [String]] = [:]
        func note(_ table: String, _ id: String) { ids[table, default: []].append(id) }

        let wing = try ops.createWing(name: "Away \(label)")
        note("wing", wing.id)
        let doomedWing = try ops.createWing(name: "Gone \(label)")
        try ops.deleteWing(doomedWing.id)
        note("wing", doomedWing.id)

        let shelf = try ops.createShelf(name: "Shelf \(label)")
        note("shelf", shelf.id)
        let doomedShelf = try ops.createShelf(name: "Old shelf \(label)")
        try ops.deleteShelf(doomedShelf.id)
        note("shelf", doomedShelf.id)

        let post = try ops.createPost(title: "a note", profile: .blog)
        note("container", post.id)
        let pool = try ops.createPool(title: "scraps")
        note("container", pool.id)
        let block = try ops.seedBlock(in: post.id, text: "kept words")
        note("block", block.block.id)
        let doomedBlock = try ops.seedBlock(in: post.id, text: "doomed words")
        try ops.deleteBlock(doomedBlock.block.id)
        note("block", doomedBlock.block.id)

        let tag = try ops.createTag(name: "life-\(label)")
        note("tag", tag.id)
        let doomedTag = try ops.createTag(name: "gone-\(label)")
        try ops.deleteTag(doomedTag.id)
        note("tag", doomedTag.id)

        let reading = try ops.createReading(name: "A book \(label)", kind: .book)
        note("reading", reading.id)
        let doomedReading = try ops.createReading(name: "Gone book \(label)", kind: .book)
        _ = try ops.deleteReading(doomedReading.id)
        note("reading", doomedReading.id)

        let reference = try ops.addReference(to: post.id, kind: .url, url: "https://example.com/a")
        note("reference", reference.id)
        let doomedReference = try ops.addReference(to: post.id, kind: .url, url: "https://example.com/b")
        try ops.removeReference(doomedReference.id)
        note("reference", doomedReference.id)

        let layout = try ops.setCanvasPosition(container: post.id, block: block.block.id, x: 10, y: 20)
        note("canvas_layout", layout.id)

        let lens = try ops.createLens(post: post.id, name: "A lens \(label)")
        note("lens", lens.id)
        let doomedLens = try ops.createLens(post: post.id, name: "Gone lens \(label)")
        try ops.deleteLens(doomedLens.id)
        note("lens", doomedLens.id)

        let comment = try ops.addBlockComment(to: block.block.id, text: "a working note")
        note("block_comment", comment.id)
        let doomedComment = try ops.addBlockComment(to: block.block.id, text: "a deleted note")
        try ops.deleteBlockComment(doomedComment.id)
        note("block_comment", doomedComment.id)

        // A purge intent: Delete Now on a note already in the Trash.
        let trashed = try ops.createPost(title: "in the trash")
        try ops.deleteContainer(trashed.id)
        note("container", trashed.id)
        #expect(try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: trashed.id)]) == 1)
        let intent = try #require(try ops.database.read { db in
            try String.fetchOne(db, sql: "SELECT id FROM purge_intent WHERE row_id = ?", arguments: [trashed.id])
        })
        note("purge_intent", intent)
        return ids
    }

    private func unownedCount(_ db: AppDatabase, _ table: String) throws -> Int {
        try db.fetchInt("SELECT COUNT(*) FROM \(table) WHERE owner_id IS NULL") ?? -1
    }

    // MARK: - The pins

    /// **PIN 1 — nothing unowned, nothing written.** Every row was stamped at
    /// birth (signed in), so adoption has nothing to do: it must run no write
    /// statement on the writer at all — no BEGIN, no UPDATE, no COMMIT — and
    /// still answer one zero per owner table. RED on the pre-fix tree: it ran
    /// BEGIN IMMEDIATE, eleven UPDATEs and a COMMIT every time.
    @Test func withNothingUnownedTheWriterRunsNoTransactionAndNoWrite() throws {
        try withOperations { _, db in
            _ = try withDependencies { $0.ownerIdentity = OwnerIdentity { Self.me } } operation: {
                try mintInEveryOwnerTable(Operations())
            }
            try db.clearOutbox()
            let (report, statements) = try tracingTheWriter(db) { try adopt(as: Self.me) }

            let writes = statements.filter {
                ["BEGIN", "COMMIT", "END", "SAVEPOINT", "RELEASE", "UPDATE", "INSERT", "DELETE", "REPLACE"].contains($0.verb)
            }
            #expect(writes.isEmpty, "nothing unowned ⇒ no write statement; ran: \(writes.map(\.sql))")
            #expect(report.total == 0)
            #expect(Set(report.adoptedByTable.keys) == Set(try ownerTables(db)),
                    "the report still answers every owner table (its shape is unchanged)")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0, "nothing enqueued")
        }
    }

    /// **PIN 2 — no owner table is scanned.** Every statement adoption runs —
    /// with nothing unowned (the ordinary launch) AND with rows to adopt — reads
    /// an owner table only through that table's unowned-row index, so its cost
    /// is the rows to adopt, never the corpus (P1). And every owner table is
    /// reached (the oracle cannot pass by running nothing). RED on the pre-fix
    /// tree: every statement was `SCAN <table>`.
    @Test func everyStatementReachesAnOwnerTableOnlyThroughItsUnownedIndex() throws {
        try withOperations { ops, db in
            let tables = try ownerTables(db)
            // A corpus with something unowned (signed out), then adopted.
            try mintInEveryOwnerTable(ops)
            let (first, adopting) = try tracingTheWriter(db) { try adopt(as: Self.me) }
            #expect(first.total > 0)
            let whileAdopting = try planReadings(db, adopting, ownerTables: tables)
            #expect(whileAdopting.violations.isEmpty, "adopting read an owner table past its index: \(whileAdopting.violations)")
            #expect(whileAdopting.reached == Set(tables), "every owner table reached while adopting")

            // Now nothing is unowned: the ordinary launch.
            let (second, idle) = try tracingTheWriter(db) { try adopt(as: Self.me) }
            #expect(second.total == 0)
            let whileIdle = try planReadings(db, idle, ownerTables: tables)
            #expect(whileIdle.violations.isEmpty, "a launch with nothing to adopt scanned: \(whileIdle.violations)")
            #expect(whileIdle.reached == Set(tables), "every owner table checked with nothing to adopt")
        }
    }

    // MARK: - The state transitions (S4: no row that needs an owner is skipped)

    /// The seeding helper reaches every owner-carrying table, so the transitions
    /// below cover them all.
    @Test func everyOwnerTableHoldsARowFromTheSeed() throws {
        try withOperations { ops, db in
            let ids = try mintInEveryOwnerTable(ops)
            #expect(Set(ids.keys) == Set(try ownerTables(db)),
                    "seed every owner-carrying table here — a new one is otherwise unproven")
        }
    }

    /// **Road 1 — minted signed out**, in every owner table, live AND tombstoned
    /// (tombstones still sync): one pass adopts every one — counts per table equal
    /// the rows, every adopted row re-enters the outbox, and `updated_at` and
    /// `sync_version` do not move (adoption is not an edit; the version is the
    /// server's token).
    @Test func signedOutRowsInEveryOwnerTableAreAdoptedLiveAndTombstoned() throws {
        try withOperations { ops, db in
            let ids = try mintInEveryOwnerTable(ops)
            var before: [String: Int] = [:]
            for table in try ownerTables(db) {
                before[table] = try unownedCount(db, table)
                #expect(before[table]! > 0, "\(table) holds an unowned row before the pass")
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container WHERE deleted_at IS NOT NULL AND owner_id IS NULL")! > 0)
            try db.write { d in
                for table in ids.keys { try d.execute(sql: "UPDATE \(table) SET sync_version = 4") }
            }
            try db.clearOutbox()
            let stamps = try db.read { d in
                try Dictionary(uniqueKeysWithValues: ids.keys.sorted().map { table in
                    (table, try String.fetchAll(d, sql: "SELECT COALESCE(updated_at, '') FROM \(table) ORDER BY id"))
                })
            }

            let report = try adopt(as: Self.me)

            for (table, rows) in ids {
                #expect(try unownedCount(db, table) == 0, "\(table) still holds unowned rows")
                #expect(report.adoptedByTable[table] == before[table], "\(table): the report counts every adopted row")
                for id in rows {
                    #expect(try db.fetchString("SELECT owner_id FROM \(table) WHERE id = ?", [id]) == Self.me)
                    #expect(try db.outboxContains(table, id), "\(table) \(id) re-enters the outbox — the adoption pushes")
                }
                #expect(try db.fetchInt("SELECT COUNT(*) FROM \(table) WHERE sync_version != 4") == 0,
                        "\(table): sync_version is the server's token")
            }
            let after = try db.read { d in
                try Dictionary(uniqueKeysWithValues: ids.keys.sorted().map { table in
                    (table, try String.fetchAll(d, sql: "SELECT COALESCE(updated_at, '') FROM \(table) ORDER BY id"))
                })
            }
            #expect(after == stamps, "adoption is not an edit: no updated_at moves")
            // Idempotent: the next pass adopts nothing and writes nothing.
            let (again, statements) = try tracingTheWriter(db) { try adopt(as: Self.me) }
            #expect(again.total == 0)
            #expect(!statements.contains { $0.verb == "BEGIN" || $0.verb == "UPDATE" })
        }
    }

    /// **The mixed case.** Rows stamped for me, rows stamped for another
    /// account, and unowned rows, side by side in the same tables: only the
    /// unowned rows are adopted; an owned row — mine or theirs — keeps its owner,
    /// its version and its stamp, and never re-enters the outbox.
    @Test func theMixedCaseAdoptsOnlyTheUnownedRows() throws {
        try withOperations { ops, db in
            let mine = try withDependencies { $0.ownerIdentity = OwnerIdentity { Self.me } } operation: {
                try mintInEveryOwnerTable(Operations(), "mine")
            }
            let theirs = try withDependencies { $0.ownerIdentity = OwnerIdentity { Self.other } } operation: {
                try mintInEveryOwnerTable(Operations(), "theirs")
            }
            let unowned = try mintInEveryOwnerTable(ops, "unowned")
            try db.clearOutbox()

            let report = try adopt(as: Self.me)

            for (table, rows) in unowned {
                #expect(report.adoptedByTable[table] == rows.count, "\(table): exactly the unowned rows adopt")
                for id in rows {
                    #expect(try db.fetchString("SELECT owner_id FROM \(table) WHERE id = ?", [id]) == Self.me)
                    #expect(try db.outboxContains(table, id))
                }
            }
            for (owner, minted) in [(Self.me, mine), (Self.other, theirs)] {
                for (table, rows) in minted {
                    for id in rows {
                        #expect(try db.fetchString("SELECT owner_id FROM \(table) WHERE id = ?", [id]) == owner,
                                "\(table) \(id) keeps its owner")
                        #expect(!(try db.outboxContains(table, id)), "\(table) \(id) is untouched — no outbox row")
                    }
                }
            }
        }
    }

    /// **An account change.** A library holding X's rows and rows minted signed
    /// out, then Y signs in: adoption stamps ONLY the unowned rows to Y — X's
    /// rows stay X's (moving a library between accounts is `restampOwner`, the
    /// adopt road, never this) — and the next pass, with nothing unowned, writes
    /// nothing. After the adopt road re-stamps everything to Y, adoption again
    /// has nothing to do and writes nothing.
    @Test func anAccountChangeAdoptsOnlyTheUnownedRowsAndThenWritesNothing() throws {
        let x = "vm67-0000-4000-8000-00000000000a"
        let y = "vm67-0000-4000-8000-00000000000b"
        try withOperations { ops, db in
            let xs = try withDependencies { $0.ownerIdentity = OwnerIdentity { x } } operation: {
                try mintInEveryOwnerTable(Operations(), "x")
            }
            let signedOut = try mintInEveryOwnerTable(ops, "signed-out")

            let report = try adopt(as: y)
            #expect(report.total == signedOut.values.map(\.count).reduce(0, +))
            for (table, rows) in signedOut {
                for id in rows { #expect(try db.fetchString("SELECT owner_id FROM \(table) WHERE id = ?", [id]) == y) }
            }
            for (table, rows) in xs {
                for id in rows { #expect(try db.fetchString("SELECT owner_id FROM \(table) WHERE id = ?", [id]) == x) }
            }

            let (again, quiet) = try tracingTheWriter(db) { try adopt(as: y) }
            #expect(again.total == 0)
            #expect(!quiet.contains { $0.verb == "BEGIN" || $0.verb == "UPDATE" }, "nothing unowned ⇒ nothing written")

            _ = try withDependencies { $0.ownerIdentity = OwnerIdentity { y } } operation: {
                try Operations().restampOwner(to: y)
            }
            let (afterMove, moved) = try tracingTheWriter(db) { try adopt(as: y) }
            #expect(afterMove.total == 0)
            #expect(!moved.contains { $0.verb == "BEGIN" || $0.verb == "UPDATE" })
            for table in try ownerTables(db) {
                #expect(try db.fetchInt("SELECT COUNT(*) FROM \(table) WHERE owner_id IS NULL OR owner_id != ?", [y]) == 0)
            }
        }
    }

    /// **Visibility — no later than before.** A write already queued on the
    /// writer when adoption is called (here: an unowned note being minted, its
    /// transaction still open) is adopted BY THAT PASS — the pass waits its turn
    /// on the writer's queue and then sees the row, exactly as the one write
    /// transaction it replaced did. (A probe on a READER would answer at once
    /// from the snapshot before that write and leave the row unowned until the
    /// next launch — the design this pins out.) On-disk WAL pool, as on her
    /// phone.
    @Test func aRowFromAWriteAlreadyQueuedIsAdoptedByThatPass() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm67-visibility-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let db = try AppDatabase.onDisk(url: folder.appendingPathComponent("store.sqlite"), key: nil)

        let ops = withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.ownerIdentity = OwnerIdentity { Self.me }
        } operation: { Operations() }
        _ = try ops.createPost(title: "already mine")
        #expect(try unownedCount(db, "container") == 0)

        let inside = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let calling = DispatchSemaphore(value: 0)
        let finished = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            try? db.write { connection in
                try connection.execute(sql: """
                    INSERT INTO container (id, kind, created_at, updated_at)
                    VALUES ('minted-while-signed-out', 'post', ?, ?)
                    """, arguments: [stamp, stamp])
                inside.signal()
                release.wait()
            }
        }
        inside.wait()
        let result = LockIsolated<Operations.OwnerAdoptionReport?>(nil)
        DispatchQueue.global().async {
            calling.signal()
            result.setValue(try? ops.adoptOwnerID())
            finished.signal()
        }
        calling.wait()
        // Time enough for a design that does NOT wait for the writer to be wrong;
        // the right one is right however long this is.
        Thread.sleep(forTimeInterval: 0.3)
        release.signal()
        #expect(finished.wait(timeout: .now() + 30) == .success)

        #expect(result.value?.adoptedByTable["container"] == 1, "the queued write's row is adopted by this pass")
        #expect(try db.fetchString("SELECT owner_id FROM container WHERE id = 'minted-while-signed-out'") == Self.me)
    }

    /// **A store arriving whole from before the index** (a restore from a safety
    /// copy, a library opened from its folder pair, a plaintext export adopted)
    /// carries its unowned rows in: the open's migration builds the index over
    /// them, the first pass adopts every one, and even that pass reads each
    /// owner table only through its index.
    @Test func aStoreFromBeforeTheIndexAdoptsItsUnownedRowsThroughTheIndex() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vm67-older-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("store.sqlite")
        do {
            let older = try DatabaseQueue(path: url.path)
            try AppDatabase.migrator.migrate(older, upTo: "v1_37_arrival_provenance_and_pin")
            try older.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                try db.execute(sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                      VALUES ('n1', 'post', 'older note', '\(stamp)', '\(stamp)');
                    INSERT INTO container (id, kind, title, created_at, updated_at, deleted_at)
                      VALUES ('n2', 'post', 'older trashed', '\(stamp)', '\(stamp)', '\(stamp)');
                    INSERT INTO block (id, default_variant_id, created_at, updated_at)
                      VALUES ('b1', 'v1', '\(stamp)', '\(stamp)');
                    INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
                      VALUES ('v1', 'b1', 'older words', 'a0', '\(stamp)', '\(stamp)');
                    INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                      VALUES ('p1', 'n1', 'b1', 'a0', 'v1', '\(stamp)', '\(stamp)');
                    INSERT INTO tag (id, name, path, created_at, updated_at)
                      VALUES ('t1', 'older', 'older', '\(stamp)', '\(stamp)');
                    INSERT INTO reading (id, name, kind, created_at, updated_at)
                      VALUES ('r1', 'Older book', 'book', '\(stamp)', '\(stamp)');
                    INSERT INTO block_comment (id, block_id, text, created_at, updated_at)
                      VALUES ('c1', 'b1', 'older comment', '\(stamp)', '\(stamp)');
                    """)
            }
        }
        let db = try AppDatabase.onDisk(url: url, key: nil)
        let tables = try ownerTables(db)
        let (report, statements) = try withDependencies { $0.database = db } operation: {
            try tracingTheWriter(db) { try adopt(as: Self.me) }
        }
        #expect(report.adoptedByTable["container"] == 2, "live and tombstoned")
        #expect(report.adoptedByTable["block"] == 1)
        #expect(report.adoptedByTable["tag"] == 1)
        #expect(report.adoptedByTable["reading"] == 1)
        #expect(report.adoptedByTable["block_comment"] == 1)
        #expect(report.total == 6)
        for table in tables { #expect(try unownedCount(db, table) == 0, "\(table) fully owned") }
        let readings = try planReadings(db, statements, ownerTables: tables)
        #expect(readings.violations.isEmpty, "the index serves rows that pre-date it: \(readings.violations)")
        #expect(readings.reached == Set(tables))
    }
}
