import Foundation
import GRDB
import OSLog

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
/// (`seq`), the round's corpus key id and device id, the build that wrote it — the stage `format` and the lockstep
/// marker (ladder R1, F1: the stage is an ON-DISK format that outlives app updates) — and the purge ledger's scan
/// point it was fetched under (ladder R2, R2-1). A round resumes only when base, key, device, format, marker and scan
/// point all match; anything else — a header that will not decode included — discards the stage and fetches from the
/// cursor, and so does a staged row that will not decode (one re-download, never a wedge).
///
/// WHY THE SCAN POINT (R2-1): 13j's returner road keeps purged rows off a device two ways — the feed never serves
/// them, and the pre-round ledger reconciliation (`PurgeJanitor.reconcileLedger`) drops any the store HOLDS, then
/// moves its scan point past their entries for good. That pass looks only at the live tables, never here, so a stage
/// fetched before a ledger advance may hold a row since purged, and resuming it would write that row back on this
/// device alone, permanently. A stage is valid only for the ledger state it was fetched under: any advance discards
/// it. The cost is one re-download exactly when a purge landed meanwhile (the ledger page is unpaged, so a pre-pass
/// with nothing new moves nothing). The stage is never a second truth: the apply
/// reads it whole, in `server_seq` order — each row once, at its newest staged seq: what a fresh round from the base
/// would fetch — and empties it in the transaction that moves the cursor, whether that apply reaches the head or
/// stalls.
///
/// ONE WRITER: the stage assumes one round at a time per store — the scheduler's serialization (`SyncScheduler`
/// is the only production caller of `pull()`); a retired chain's download is cancelled (VX-494 D3 — a save already
/// running finishes, ladder R3, R3-1) and, when
/// `SyncSession.configure` finds it, drained before the replacement starts; a lock closes the retired chain's pool
/// outright. The one road with no drain is `stop()` then `configure()` (a sign-out then a sign-in): `stop()` retires
/// the chain in an unstructured task and forgets it, so a new round could in principle overlap the old round's last
/// writes. THE BELT, so an overlap can only refuse, never commit past rows nobody applied:
///  - the apply refuses when the committed cursor is no longer the one its stage extends (`CursorMovedUnderRound` —
///    ladder R1, N2);
///  - CONTINUITY (ladder R2, R2-2), because another round can empty the stage WITHOUT moving the cursor (a save that
///    stalls at its batch's first row — the steady state of a stalled device — or a discard): a window is staged only
///    onto an EMPTY stage from the round's base, or onto a stage of the round's identity whose reach is exactly where
///    the window starts; and the apply saves only a stage of the round's identity reaching exactly its fetch cursor
///    (`StageMovedUnderRound`). So the stage always holds one unbroken download from its base to its reach.
/// Each refusal writes nothing and keeps whatever stage stands; the next round re-plans from the committed cursor,
/// and the scheduler runs it at once (R2-6 — `isOneWriterRefusal`).
/// Writes here touch only local-only tables (no outbox trigger fires), so they run as plain writes.
enum PullStage {
    static let headerKey = "pull_stage"

    /// THE STAGE FORMAT (ladder R1, F1 (1)): what a staged row's payload IS — today the synthesized `Codable` JSON of
    /// `SyncPulledRow` (and so of `SyncRow` and `SyncValue`), applied by today's apply. **Bump it whenever that
    /// encoding or its meaning to the apply changes** (a renamed or added property on those types, a new wire→row
    /// transform): a stage written under another format is discarded, never resumed.
    static let format = 1

    /// The core's one log line (F1 (2) — a discarded stage is worth a line in the unified log; nothing else here
    /// speaks).
    static let log = Logger(subsystem: "io.lduarte.Variorum", category: "sync")

    struct Header: Codable, Equatable {
        var base: Int64
        var seq: Int64
        var keyID: String
        var deviceID: String
        /// F1 (1): the stage format and the lockstep marker of the build that wrote it.
        var format: Int
        var lockstep: Int
        /// R2-1: the purge ledger's scan point the stage was fetched under (`PurgeJanitor.ledgerScanPoint`, read
        /// through the janitor's own name and reader — ladder R3, R3-4). NON-optional on purpose: a header written
        /// before the stage named it lacks the key, so its synthesized decode throws, `readHeader` reads it as
        /// unreadable, and `plan` discards the stage — never resumed.
        var ledgerScanPoint: Int64

        /// Whether this stage was fetched under the round identity given (its reach aside).
        func belongs(base: Int64, keyID: String, deviceID: String, ledgerScanPoint: Int64) -> Bool {
            self.base == base && self.keyID == keyID && self.deviceID == deviceID
                && format == PullStage.format && lockstep == SyncSchema.lockstepVersion
                && self.ledgerScanPoint == ledgerScanPoint
        }
    }

    /// Ladder R1, N2 — THE ONE-WRITER BELT's refusal: the committed cursor moved while this round was downloading
    /// (another round on this store committed), so this round's stage no longer extends it and saving it could
    /// commit the cursor past rows nobody applied. Nothing is written; the next round starts from the new cursor.
    struct CursorMovedUnderRound: Error, CustomStringConvertible {
        let roundBase: Int64
        let committed: Int64
        var description: String {
            "another sync round committed while this one was downloading (cursor \(roundBase) → \(committed)); "
                + "the next round starts from the new cursor"
        }
    }

    /// Ladder R2, R2-2 — THE ONE-WRITER BELT's continuity refusal: the stage this round is extending or saving is no
    /// longer the one it wrote or resumed (another round on this store emptied, replaced or advanced it, or the
    /// ledger moved under it). Writing on would stage a download with a hole in it, and saving it could commit the
    /// cursor past rows nobody applied. Nothing is written; the next round re-plans from the committed cursor.
    struct StageMovedUnderRound: Error, CustomStringConvertible {
        var description: String {
            "another sync round changed this round's download while it was running; "
                + "the next round starts from the committed cursor"
        }
    }

    /// Ladder R2, R2-6: the one-writer belt's two refusals. Both heal on the very next round (it re-plans from the
    /// committed cursor), so `SyncScheduler` runs that round at once instead of leaving these words on the sync row.
    static func isOneWriterRefusal(_ error: any Error) -> Bool {
        error is CursorMovedUnderRound || error is StageMovedUnderRound
    }

    /// A stage this round fetched itself, from its committed cursor, that still will not decode — impossible while
    /// this build encodes what it decodes; the stage is cleared and the round refuses rather than loop.
    struct UndecodableStage: Error, CustomStringConvertible {
        var description: String { "the pull stage this round downloaded would not decode" }
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
        if let header,
           header.belongs(
               base: base, keyID: keyID, deviceID: deviceID,
               ledgerScanPoint: try PurgeJanitor.ledgerScanPoint(db)),
           header.seq > base {
            return .resume(from: header.seq)
        }
        let staged = try hasStagedRows(db)
        let headerRow = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)", arguments: [headerKey]) ?? false
        return (headerRow || staged) ? .discardThenFresh : .fresh
    }

    /// One staged row with its payload already encoded (ladder R1, N3): the JSON encoding runs BEFORE the writer is
    /// taken, so a window's write holds the writer only for the upserts.
    struct EncodedRow: Sendable {
        let table: String
        let rowID: String
        let serverSeq: Int64
        let payload: String
    }

    /// A downloaded window's opened rows, encoded for the stage — off the writer.
    static func encode(_ window: [SyncPulledRow]) throws -> [EncodedRow] {
        let encoder = JSONEncoder()
        return try window.map { item in
            EncodedRow(
                table: item.row.table, rowID: item.row.rowID, serverSeq: item.serverSeq,
                payload: String(decoding: try encoder.encode(item), as: UTF8.self))
        }
    }

    /// One downloaded window — the feed's `(windowSince, seq]`: its encoded rows upserted through one cached statement
    /// (a row's newer download replaces an older one — the state-based feed serves a row again at a higher seq when
    /// it changed), the header advanced to the window's end. CONTINUITY first (R2-2 — the ONE WRITER belt above): the
    /// window lands only on an EMPTY stage when it starts at the round's base, or on a stage of the round's identity
    /// whose reach is exactly `windowSince`; anything else throws `StageMovedUnderRound`, nothing written.
    static func stage(
        _ db: Database, _ window: [EncodedRow], base: Int64, keyID: String, deviceID: String,
        from windowSince: Int64, through seq: Int64
    ) throws {
        let scanPoint = try PurgeJanitor.ledgerScanPoint(db)  // R2-1: read in this write's own transaction
        switch try headerRow(db) {
        case .absent:
            guard windowSince == base, try !hasStagedRows(db) else { throw StageMovedUnderRound() }
        case .unreadable:
            throw StageMovedUnderRound()
        case .readable(let header):
            guard header.belongs(base: base, keyID: keyID, deviceID: deviceID, ledgerScanPoint: scanPoint),
                  header.seq == windowSince
            else { throw StageMovedUnderRound() }
        }
        let upsert = try db.cachedStatement(sql: """
            INSERT INTO \(SyncPullStageSchema.table) (table_name, row_id, server_seq, payload)
            VALUES (?, ?, ?, ?)
            ON CONFLICT (table_name, row_id) DO UPDATE
              SET server_seq = excluded.server_seq, payload = excluded.payload
              WHERE excluded.server_seq > \(SyncPullStageSchema.table).server_seq
            """)
        for row in window {
            try upsert.execute(arguments: [row.table, row.rowID, row.serverSeq, row.payload])
        }
        try writeHeader(db, Header(
            base: base, seq: seq, keyID: keyID, deviceID: deviceID,
            format: format, lockstep: SyncSchema.lockstepVersion, ledgerScanPoint: scanPoint))
    }

    /// R2-2 (ii) — the apply's half of CONTINUITY, inside its transaction before any write: the stage it saves is still
    /// this round's — of the round's identity, reaching exactly the round's fetch cursor. Anything else (the stage
    /// emptied, replaced or advanced by another writer since the round's last window, or the ledger moved under it)
    /// throws `StageMovedUnderRound`.
    static func verifyRoundsStage(
        _ db: Database, base: Int64, keyID: String, deviceID: String, reach: Int64
    ) throws {
        guard case .readable(let header) = try headerRow(db),
              header.belongs(
                  base: base, keyID: keyID, deviceID: deviceID,
                  ledgerScanPoint: try PurgeJanitor.ledgerScanPoint(db)),
              header.seq == reach
        else { throw StageMovedUnderRound() }
    }

    /// Every staged row, in `server_seq` order — the batch the apply consumes — or nil when any staged payload will
    /// not decode (F1 (2)): a row nobody can read is treated as the unreadable header is, and the caller discards
    /// the stage. A database error still throws.
    static func rows(_ db: Database) throws -> [SyncPulledRow]? {
        let decoder = JSONDecoder()
        var rows: [SyncPulledRow] = []
        // Ladder R3, R3-5: each payload is decoded as the cursor reads it, so the stage's JSON (~79 MB at the live
        // proof's ~110k rows) is never held whole beside the decoded batch — the phone's memory (VM-8).
        let payloads = try String.fetchCursor(
            db, sql: "SELECT payload FROM \(SyncPullStageSchema.table) ORDER BY server_seq")
        while let payload = try payloads.next() {
            guard let row = try? decoder.decode(SyncPulledRow.self, from: Data(payload.utf8)) else { return nil }
            rows.append(row)
        }
        return rows
    }

    /// The stage and its header, gone — inside the apply transaction that moves the cursor, and wherever the
    /// cursor itself is reset.
    static func clear(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM \(SyncPullStageSchema.table)")
        try db.execute(sql: "DELETE FROM sync_state WHERE key = ?", arguments: [headerKey])
    }

    private enum HeaderRow {
        case absent
        case unreadable
        case readable(Header)
    }

    private static func headerRow(_ db: Database) throws -> HeaderRow {
        guard let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [headerKey])
        else { return .absent }
        // An unreadable header is a stage nobody can vouch for: `plan` discards it and `stage` never writes over it (a
        // header from before the stage named its format — F1 — or its ledger scan point — R2-1 — reads as unreadable).
        guard let header = try? JSONDecoder().decode(Header.self, from: Data(value.utf8)) else { return .unreadable }
        return .readable(header)
    }

    private static func readHeader(_ db: Database) throws -> Header? {
        if case .readable(let header) = try headerRow(db) { return header }
        return nil
    }

    private static func hasStagedRows(_ db: Database) throws -> Bool {
        try Bool.fetchOne(db, sql: "SELECT EXISTS (SELECT 1 FROM \(SyncPullStageSchema.table))") ?? false
    }

    private static func writeHeader(_ db: Database, _ header: Header) throws {
        let value = String(decoding: try JSONEncoder().encode(header), as: UTF8.self)
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [headerKey, value])
    }
}
