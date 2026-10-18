import Foundation
import GRDB

// VX-306 U3 — LOOK INSIDE's READ ROAD (`notes/plans/vx-306-castle-open-road.md` §9 U3 RECORD, the orchestrator's ruling
// P-VX306-U3-15: (b), the read-only facts sheet; `notes/CastleRules.md` rule 17: "Look inside: any copy … opens read-only
// with its own secrets (or its own quiet road on this Mac). The app writes nothing … Close it and the app forgets it.").
//
// Beside the ONE keying implementation (`AppDatabase.configuration(key:)`), like `ProtectionLibraryFiles` — so it runs
// headless in both configurations and no second keying road exists. DUMB: it reads what it is asked and decides nothing.
//
//   - THE CATALOGUED FILE IS NEVER OPENED IN PLACE (13x's rule — even a read-only open writes sidecars beside the file it
//     opens): `open` byte-copies it, with its non-empty `-wal`, into a FRESH private folder (`ProtectionLibraryFiles
//     .privateCopy`) and opens ONE keyed, READ-ONLY connection on that copy. The key lives only inside the connection's
//     configuration; `close()` closes the connection (the key goes with it) and deletes the private folder — closing
//     forgets. A reader dropped without `close()` closes in `deinit` the same way.
//   - RAW SQL over the library's own columns — NEVER the migrator (a copy is read as it is), never `Operations`, never the
//     ambient database: no write can reach any library by construction (the connection is read-only too).
//   - P1: a page of notes at a time, newest first, walking `idx_container_touched` (`(last_touched_at, id) WHERE
//     deleted_at IS NULL`) backward — no temp sort, the cost the pages she has looked at; a note's text is one note's
//     blocks; a book's count is its own memberships.
//   - A copy that holds no app tables yet (a library created but never opened — its file holds `protection_record` only)
//     reads as empty, never as an error.

public enum ProtectionCopyPeek {
    /// A book of the copy (gatherings assemble by rule and hold no membership — they are not listed).
    public struct Book: Equatable, Sendable, Identifiable {
        public var id: String
        public var name: String
        /// Its member notes (live, member-class).
        public var noteCount: Int
    }

    /// A note of the copy, as a list row.
    public struct Note: Equatable, Sendable, Identifiable {
        public var id: String
        public var title: String?
        /// Its own day (`entry_date`, `yyyy-MM-dd`) when it has one.
        public var entryDate: String?
        /// When it was last written (the list's order).
        public var touchedAt: String?
    }

    /// A note's text: its blocks in order, each its chosen take (the block's default when the chosen one is gone or
    /// archived) — exactly as the page reads.
    public struct NoteText: Equatable, Sendable {
        public var id: String
        public var title: String?
        public var blocks: [String]
    }

    public static let pageSize = 100

    /// The copy at `url` opened with `key`: a private byte copy under `directory`, one read-only keyed connection on it.
    /// Throws when `key` does not open the copy (the private folder is removed first).
    public static func open(_ url: URL, key: StoreKey, inside directory: URL) throws -> Reader {
        let copy = try ProtectionLibraryFiles.privateCopy(of: url, inside: directory)
        let folder = copy.deletingLastPathComponent()
        do {
            var configuration = AppDatabase.configuration(key: key)
            configuration.readonly = true
            let queue = try DatabaseQueue(path: copy.path, configuration: configuration)
            // The first page read is where SQLCipher refuses a wrong key.
            _ = try queue.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sqlite_master") }
            return Reader(queue: queue, folder: folder)
        } catch {
            try? FileManager.default.removeItem(at: folder)
            throw error
        }
    }

    /// One look — a read-only connection on a private copy. Not shared across threads concurrently (the caller reads
    /// from one task at a time); `close()` is idempotent.
    public final class Reader: @unchecked Sendable {
        private let lock = NSLock()
        private var queue: DatabaseQueue?
        /// The private folder the copy lives in (deleted at close).
        public let folder: URL

        init(queue: DatabaseQueue, folder: URL) {
            self.queue = queue
            self.folder = folder
        }

        deinit { close() }

        public var isClosed: Bool { lock.withLock { queue == nil } }

        /// Closing forgets: the connection closed (its key with it), the private folder deleted.
        public func close() {
            let outgoing: DatabaseQueue? = lock.withLock {
                defer { queue = nil }
                return queue
            }
            try? outgoing?.close()
            try? FileManager.default.removeItem(at: folder)
        }

        private func read<T>(_ body: (Database) throws -> T) throws -> T {
            guard let queue = lock.withLock({ queue }) else { throw ProtectionLibraryFiles.FileError("the look is closed") }
            return try queue.read(body)
        }

        /// The copy's books, by name.
        public func books() throws -> [Book] {
            try read { db in
                guard try db.tableExists("reading"), try db.tableExists("reading_post") else { return [] }
                let memberClause = try db.columns(in: "reading_post").contains { $0.name == "status" }
                    ? " AND rp.status = 'member'" : ""
                let sql = """
                    SELECT r.id, r.name,
                      (SELECT count(*) FROM reading_post rp
                        WHERE rp.reading_id = r.id AND rp.deleted_at IS NULL\(memberClause)) AS notes
                    FROM reading r
                    WHERE r.deleted_at IS NULL AND r.kind IN ('book', 'curated')
                    ORDER BY r.name COLLATE NOCASE, r.id
                    """
                return try Row.fetchAll(db, sql: sql).map {
                    Book(id: $0["id"], name: $0["name"], noteCount: $0["notes"])
                }
            }
        }

        /// The copy's living notes (not archived, not deleted — a note's saved versions are archived copies, so they stay
        /// out too), newest first, one page at a time.
        public func notes(offset: Int = 0, limit: Int = ProtectionCopyPeek.pageSize) throws -> [Note] {
            try read { db in
                guard try db.tableExists("container") else { return [] }
                return try Row.fetchAll(db, sql: ProtectionCopyPeek.notesSQL, arguments: [limit, offset]).map {
                    Note(id: $0["id"], title: $0["title"], entryDate: $0["entry_date"], touchedAt: $0["last_touched_at"])
                }
            }
        }

        /// One note's text, as the page reads it (nil: no such living note).
        public func note(id: String) throws -> NoteText? {
            try read { db in
                guard try db.tableExists("container"), try db.tableExists("container_block") else { return nil }
                guard let row = try Row.fetchOne(
                    db, sql: "SELECT id, title FROM container WHERE id = ? AND kind = 'post' AND deleted_at IS NULL",
                    arguments: [id]) else { return nil }
                let blocks = try String.fetchAll(db, sql: ProtectionCopyPeek.noteTextSQL, arguments: [id])
                return NoteText(id: row["id"], title: row["title"], blocks: blocks)
            }
        }

        /// The query plan of `sql` (the P1 pin reads it).
        func queryPlan(_ sql: String, arguments: StatementArguments = []) throws -> [String] {
            try read { db in
                try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + sql, arguments: arguments).map { $0["detail"] as String }
            }
        }
    }

    /// The notes page: the touched index walked backward (its partial `deleted_at IS NULL` is implied here). `+kind`
    /// keeps the planner off `idx_container_kind` — with no statistics it would take that index and sort the whole
    /// corpus in a temp b-tree (the P1 pin's red, measured).
    static let notesSQL = """
        SELECT id, title, entry_date, last_touched_at FROM container
        WHERE deleted_at IS NULL AND +kind = 'post' AND archived_at IS NULL
        ORDER BY last_touched_at DESC, id DESC
        LIMIT ? OFFSET ?
        """

    /// A note's blocks in order, each its chosen take — or the block's default when the chosen one is missing,
    /// tombstoned or archived (AppSpec §7 `container_block.chosen_variant_id`'s read-time fallback).
    static let noteTextSQL = """
        SELECT COALESCE(chosen.working_text, fallback.working_text, '') FROM container_block cb
        JOIN block b ON b.id = cb.block_id
        LEFT JOIN variant chosen ON chosen.id = cb.chosen_variant_id
          AND chosen.deleted_at IS NULL AND chosen.status = 'active'
        LEFT JOIN variant fallback ON fallback.id = b.default_variant_id AND fallback.deleted_at IS NULL
        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
        ORDER BY cb.position, cb.id
        """
}
