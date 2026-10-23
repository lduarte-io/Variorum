import Foundation
import GRDB

/// VX-494 (D2) — THE PULL STAGE: a first catch-up's downloaded windows, held in the local-only `sync_pull_stage`
/// table (v1_32) until the round's one apply transaction commits them.
///
/// Before it, `pullRound` fetched the whole changefeed into memory and only then applied it, so on a large library
/// (her ~108k rows: ~12 minutes of download, ~4 of apply) any interruption before the commit — Castle's idle lock, a
/// quit, a dropped connection — discarded the download and the next round started again from the committed cursor.
/// Now each window, once opened at the wire seam, lands here in its own small write, and a round whose stage matches
/// its identity resumes the download where the stage stops.
///
/// THE IDENTITY (one `sync_state` header row): the committed cursor the stage extends (`base`), how far it reaches
/// (`seq`), and the round's corpus key id and device id. A round resumes only when all three of base, key and device
/// match; anything else discards the stage and fetches from the cursor. The stage is never a second truth: the apply
/// reads it whole, in `server_seq` order — exactly the rows today's in-memory fetch would have held — and empties it
/// in the transaction that moves the cursor, whether that apply reaches the head or stalls.
///
/// ONE WRITER: the stage assumes one round at a time per store — the scheduler's serialization (`SyncScheduler`
/// is the only production caller of `pull()`); a retired chain is cancelled (VX-494 D3) and drained before a
/// replacement starts (`SyncSession.configure`), and a lock closes the retired chain's pool outright.
/// Writes here touch only local-only tables (no outbox trigger fires), so they run as plain writes.
enum PullStage {
    static let headerKey = "pull_stage"

    struct Header: Codable, Equatable {
        var base: Int64
        var seq: Int64
        var keyID: String
        var deviceID: String
    }

    /// What a round does with the stage it finds — decided by a READ, so an ordinary round (no stage) never takes
    /// the writer: resume from the stage's reach when the stage was fetched by this same round identity from this
    /// same committed cursor; start from the cursor when there is nothing staged; discard it first otherwise.
    enum Plan: Equatable {
        case resume(from: Int64)
        case fresh
        case discardThenFresh
    }

    static func plan(
        _ db: Database, base: Int64, keyID: String, deviceID: String
    ) throws -> Plan {
        let header = try readHeader(db)
        if let header, header.base == base, header.keyID == keyID, header.deviceID == deviceID,
           header.seq > base {
            return .resume(from: header.seq)
        }
        let staged = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM \(SyncPullStageSchema.table))") ?? false
        let headerRow = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)", arguments: [headerKey]) ?? false
        return (headerRow || staged) ? .discardThenFresh : .fresh
    }

    /// One downloaded window: its opened rows upserted (a row's newer download replaces an older one — the
    /// state-based feed serves a row again at a higher seq when it changed), the header advanced to the window's end.
    static func stage(
        _ db: Database, _ window: [SyncPulledRow], base: Int64, keyID: String, deviceID: String,
        through seq: Int64
    ) throws {
        let encoder = JSONEncoder()
        for item in window {
            let payload = String(decoding: try encoder.encode(item), as: UTF8.self)
            try db.execute(
                sql: """
                    INSERT INTO \(SyncPullStageSchema.table) (table_name, row_id, server_seq, payload)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT (table_name, row_id) DO UPDATE
                      SET server_seq = excluded.server_seq, payload = excluded.payload
                      WHERE excluded.server_seq > \(SyncPullStageSchema.table).server_seq
                    """,
                arguments: [item.row.table, item.row.rowID, item.serverSeq, payload])
        }
        try writeHeader(db, Header(base: base, seq: seq, keyID: keyID, deviceID: deviceID))
    }

    /// Every staged row, in `server_seq` order — the batch the apply consumes.
    static func rows(_ db: Database) throws -> [SyncPulledRow] {
        let decoder = JSONDecoder()
        return try String.fetchAll(
            db, sql: "SELECT payload FROM \(SyncPullStageSchema.table) ORDER BY server_seq")
            .map { try decoder.decode(SyncPulledRow.self, from: Data($0.utf8)) }
    }

    /// The stage and its header, gone — inside the apply transaction that moves the cursor, and wherever the
    /// cursor itself is reset.
    static func clear(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM \(SyncPullStageSchema.table)")
        try db.execute(sql: "DELETE FROM sync_state WHERE key = ?", arguments: [headerKey])
    }

    private static func readHeader(_ db: Database) throws -> Header? {
        guard let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [headerKey])
        else { return nil }
        // An unreadable header is a stage nobody can vouch for: treated as absent, so `resumePoint` discards it.
        return try? JSONDecoder().decode(Header.self, from: Data(value.utf8))
    }

    private static func writeHeader(_ db: Database, _ header: Header) throws {
        let value = String(decoding: try JSONEncoder().encode(header), as: UTF8.self)
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [headerKey, value])
    }
}
