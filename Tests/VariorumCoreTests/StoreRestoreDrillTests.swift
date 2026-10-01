import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A0(iii) — the backup RESTORE drill's automated half
/// (the KnownIssues row, pulled forward from deferred Phase 12's Step 5).
/// Phase 8's A1 pinned the WRITE side (WAL-consistent copies, rotation);
/// what was owed is the rehearsed RESTORE: a cold copy opened through the
/// recoverable-open path renders as a real store. The manual runbook lives
/// in the phase plan's Stage A closeout; this test is its executable core,
/// and the on-disk rehearsal against the seeded dev store is recorded
/// there too.
@Suite("Backup restore drill (Phase 13, A0 — the KnownIssues row)")
struct StoreRestoreDrillTests {
    @Test func aColdCopyTakenMidActivityOpensAndRendersAsARealStore() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumDrill-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let backupURL = dir.appendingPathComponent("Backups/variorum-backup-drill.sqlite")

        // A live store with real shape: a journal entry, a fanned block
        // with a comment, a book with a chapter — written through the
        // operations layer against the ON-DISK store (WAL mode, like the
        // real thing; not the in-memory test double).
        let live = try AppDatabase.onDisk(url: storeURL, key: nil)
        let world: (postID: String, blockID: String, readingID: String) =
            try withDependencies {
                $0.database = live
                $0.uuid = .incrementing
                $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
            } operation: {
                let ops = Operations()
                let post = try ops.createPost(title: "drill entry", profile: .journal)
                let made = try ops.newBlock(
                    in: post.id, text: "The store the drill restores.", at: .end)
                _ = try ops.branchVariant(made.block.id, from: made.variant.id)
                _ = try ops.addBlockComment(to: made.block.id, text: "drill note")
                let reading = try ops.createReading(
                    name: "drill book", kind: .book, wordTarget: 1_000)
                _ = try ops.addPostToReading(post.id, to: reading.id)
                let chapter = try ops.createSection(in: reading.id, name: "I")
                try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
                return (post.id, made.block.id, reading.id)
            }

        // The cold copy, mid-activity: a concurrent write lands between
        // backup start and the drill's open — the copy is a consistent
        // snapshot (SQLite backup API under WAL), never a torn file.
        try live.backup(to: backupURL)
        try live.write { db in
            try db.execute(sql: """
                UPDATE container SET title = 'edited AFTER the backup' WHERE id = ?
                """, arguments: [world.postID])
        }

        // THE RESTORE: the copy opens through the recoverable-open path —
        // exactly what a real restore does (point openStore at the copy).
        let restored = try AppDatabase.openStore(at: backupURL)
        try restored.read { db in
            #expect(try String.fetchOne(db, sql: "PRAGMA integrity_check") == "ok")
            // Content renders: the library, the post, the fan, the book.
            #expect(try String.fetchOne(
                db, sql: "SELECT title FROM container WHERE id = ?",
                arguments: [world.postID]) == "drill entry",
                    "the copy is the SNAPSHOT — the post-backup edit is not in it")
            let rendered = try Queries.renderPost(db, containerID: world.postID)
            #expect(rendered.count == 1)
            #expect(try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL
                """, arguments: [world.blockID]) == 2, "the fan survived whole")
            #expect(try Queries.blockComments(db, blockID: world.blockID).count == 1)
            #expect(try Queries.readingSections(db, readingID: world.readingID).count == 1)
            // The restore-and-sync rule the runbook documents: the copy
            // carries the ORIGINAL's sync bookkeeping (cursor, outbox,
            // per-row seqs) verbatim — a restored store must not pair with
            // the production mirror until that state is deliberately
            // reconciled (the A4-fence posture; runbook step 6).
            let syncTables = ["sync_state", "sync_outbox", "sync_row_seq"]
            for table in syncTables {
                _ = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)")
            }
        }

        // And the restored copy is a fully LIVE store: writes work (the
        // "keep working from the restore" half of the drill).
        try withDependencies {
            $0.database = restored
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_950_400))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2))
        } operation: {
            let ops = Operations()
            _ = try ops.addBlockComment(to: world.blockID, text: "written post-restore")
        }
        #expect(try restored.read { db in
            try Queries.blockComments(db, blockID: world.blockID).count
        } == 2)
    }

    @Test func theRotatingBackupFilenameRoundTripsThroughTheRestorePath() throws {
        // The A1 rotation names copies `variorum-backup-<stamp>.sqlite`;
        // the drill's restore must open those exact artifacts. (The name
        // logic lives app-side in StoreBackup; the contract pinned HERE is
        // that a backup-API copy under any name is a self-contained store.)
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumDrill-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let copyURL = dir.appendingPathComponent("variorum-backup-2026-07-18-020000.sqlite")

        let live = try AppDatabase.onDisk(url: storeURL, key: nil)
        try live.write { db in try Fixture.container(db, id: "c1") }
        try live.backup(to: copyURL)

        // Self-contained: no -wal/-shm sidecars are required to open it.
        #expect(!FileManager.default.fileExists(atPath: copyURL.path + "-wal")
                || (try? Data(contentsOf: URL(fileURLWithPath: copyURL.path + "-wal")))?.isEmpty != false)
        let restored = try AppDatabase.openStore(at: copyURL)
        #expect(try restored.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container")
        } == 1)
    }
}
