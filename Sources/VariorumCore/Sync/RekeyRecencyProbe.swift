import Dependencies
import Foundation
import GRDB

/// pre-13u Act 10 wave 2a — **T1's guard, the read seam** (memo §9b: the
/// stale-copy re-key clobber is "the sharpest unguarded edge the new model
/// exposes"). Replace Encryption Keys makes LOCAL the truth; when local is
/// a month-old backup, the wipe-and-repush flattens everything the server
/// learned since. The guard is ONE recency comparison before the door
/// acts — and per her refinement it is CONCRETE without keys: ids, dates
/// and sequence numbers are deliberately PLAIN in the disclosure envelope,
/// so this probe counts the notes the server holds that this copy lacks,
/// the ones with newer changes, and names the newest date — while reading
/// no content.
///
/// **READ-ONLY BY CONSTRUCTION** (the Fable rider's condition, honored):
/// - `deviceID: nil` on EVERY window — a probe is not a round, and nil
///   records NO server-side `device_cursor` (SyncTransport's own
///   contract), so the purge horizon never learns of this read.
/// - The local database is only ever READ (the cursor + the container
///   listing); the client cursor never moves; the outbox is untouched.
/// - Payloads are never decrypted: the compared columns (`id`, `kind`,
///   `deleted_at`, `updated_at`) are PLAIN by the 14b classification —
///   the raw wire rows suffice, and a keyless machine could run this.
///
/// The comparison anchors on the LOCAL COPY'S OWN CURSOR: a stale backup
/// carries the cursor of the day it was taken, so `pull(since: cursor)`
/// returns exactly what the server learned after that day — a fresh or
/// never-synced store (cursor 0) sees the whole server picture, which is
/// what makes the near-empty corner (emptiness about to clobber a full
/// server) report honestly through the same numbers.
///
/// Wall-clock caveat, stated: `updated_at` ordering is display-grade
/// (SyncSpec §9 — seq is the only ordering AUTHORITY); for a WARNING
/// about month-scale staleness that is exactly the right tool, and the
/// one she ruled ("dates … name the newest date").
public struct RekeyRecencyReport: Equatable, Sendable {
    /// Live notes on the server whose id this copy has never seen.
    public var notesOnlyOnServer: Int
    /// Notes both sides know whose server copy is newer than this one's.
    public var notesNewerOnServer: Int
    /// The newest `updated_at` among the rows counted above (ISO-8601 as
    /// stored; the face formats it for display). nil when nothing counted.
    public var latestServerChange: String?

    /// The warning fires on ANY of the above — one honest sentence, never
    /// a refusal (the door stays hers).
    public var serverIsAhead: Bool {
        notesOnlyOnServer > 0 || notesNewerOnServer > 0
    }

    public init(
        notesOnlyOnServer: Int = 0, notesNewerOnServer: Int = 0,
        latestServerChange: String? = nil
    ) {
        self.notesOnlyOnServer = notesOnlyOnServer
        self.notesNewerOnServer = notesNewerOnServer
        self.latestServerChange = latestServerChange
    }
}

public struct RekeyRecencyProbe: Sendable {
    @Dependency(\.database) var database

    public let transport: any SyncTransport
    public let keyProvider: any SyncKeyProviding
    /// Window size, the engine's granularity (never affects the answer).
    public var batchSize: Int

    public init(
        transport: any SyncTransport,
        keyProvider: any SyncKeyProviding,
        batchSize: Int = 200
    ) {
        self.transport = transport
        self.keyProvider = keyProvider
        self.batchSize = batchSize
    }

    public func assess() async throws -> RekeyRecencyReport {
        // The key id rides the fence exactly as a round's would — a device
        // already fenced off (keys replaced elsewhere) throws here, and
        // the face words "couldn't compare" rather than blocking the door.
        let keys = try keyProvider.currentKeys()
        // 13y UNIT B: one signer per probe run — the per-request proof.
        let signer = SyncChallengeSigner(
            transport: transport, material: keys.keyProof,
            activeKeyID: keys.corpusKeyID)

        // The local copy's own vantage: its committed cursor, and its
        // container listing (id → updated_at). One read transaction; no
        // write of any kind.
        let (since, local) = try await database.read { db -> (Int64, [String: String]) in
            let cursor = try Int64(
                String.fetchOne(
                    db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
                ?? "0") ?? 0
            var map: [String: String] = [:]
            let rows = try Row.fetchAll(
                db, sql: "SELECT id, updated_at FROM container")
            for row in rows {
                map[row["id"]] = row["updated_at"]
            }
            return (cursor, map)
        }

        // The fetch loop — the engine's paging, minus everything that
        // writes: deviceID nil on EVERY window (a probe is not a round),
        // rows never decrypted, never applied.
        var serverRows: [String: SyncRow] = [:]
        var fetchCursor = since
        while true {
            let windowSince = fetchCursor
            let window = try await signer.call(rpc: "sync_pull") { proof in
                try await self.transport.pull(
                    since: windowSince, limit: self.batchSize,
                    activeKeyID: keys.corpusKeyID, keyProof: proof, deviceID: nil)
            }
            guard !window.isEmpty else { break }
            for item in window where item.row.table == "container" {
                // Keep the LAST state seen (state-based feed; a later seq
                // is the row's current truth).
                serverRows[item.row.rowID] = item.row
            }
            fetchCursor = window.last!.serverSeq
        }

        var report = RekeyRecencyReport()
        for (rowID, row) in serverRows {
            // Live NOTES only: a tombstoned server row is nothing this
            // door can lose, and pools are workspace furniture.
            guard case .text("post")? = row.columns["kind"] else { continue }
            if case .text? = row.columns["deleted_at"] { continue }
            guard case .text(let serverStamp)? = row.columns["updated_at"] else { continue }
            if let localStamp = local[rowID] {
                // ISO-8601 strings order lexicographically.
                if serverStamp > localStamp {
                    report.notesNewerOnServer += 1
                } else {
                    continue
                }
            } else {
                report.notesOnlyOnServer += 1
            }
            if report.latestServerChange.map({ serverStamp > $0 }) ?? true {
                report.latestServerChange = serverStamp
            }
        }
        return report
    }
}

/// The face's decision, pure (the mechanism the red-on-old probe reverts):
/// a server-ahead report interposes ONE warning between the press and the
/// act; anything else proceeds. Never a refusal.
public enum RekeyGuardRule {
    public enum Decision: Equatable, Sendable {
        case proceed
        case warnFirst
    }

    public static func decide(_ report: RekeyRecencyReport?) -> Decision {
        guard let report, report.serverIsAhead else { return .proceed }
        return .warnFirst
    }
}
