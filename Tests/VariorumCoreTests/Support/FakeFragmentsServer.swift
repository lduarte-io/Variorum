import Foundation
@testable import VariorumCore

/// The in-process stand-in for Fragments' `journal_entries` satellite —
/// RE-PINNED 2026-07-09 to the Fragments agents' answers, i.e. to their
/// **migration 7's shipped SQL** (their spec prose lags it; "read the SQL,
/// not the spec prose"). Never the real project. The pinned behaviors, each
/// verified by `FakeFragmentsServerTests`:
///
///  - **`sync_push` = guarded upsert with an AGGREGATE response**
///    `{applied, skipped, conflicts:[{id,error}]}` — no per-row status, no
///    server stamps, no reasons (the corrected wire shape);
///  - **row-LWW with TIES TO THE PUSHER (`>=`) on live rows** (corrected
///    from round 0's strict `>`): re-pushing an unchanged row RE-APPLIES it
///    and bumps `server_updated_at`, churning every device's pull — which
///    makes the bridge's never-push-unchanged guard even more load-bearing;
///  - **un-tombstone only on STRICTLY-newer edits** (confirmed — the SQL's
///    resurrect guard; their spec PROSE wrongly says stale-can-resurrect;
///    this fake was already pinned to strictly-newer, per the contract);
///  - **`created_at` follows the winning push** (corrected — round 0's fake
///    preserved it, which the SQL does not: the SET list excludes only
///    `server_updated_at`/`deleted_at`/`user_id`/the key column);
///  - **the clock clamp** (>10 min ahead ⇒ a `conflicts[]` entry with the
///    `clock_ahead:` prefix — ask 14 ANSWERED) and **`unique_violation`**
///    (the `(user_id,date)` index — a mis-derived id) both land in
///    `conflicts[]`;
///  - **`sync_pull` = bare ordered array** over `(server_updated_at, id)`
///    ascending, with the ~2 s visibility horizon INSIDE the RPC; server
///    stamps are µs-precision OPAQUE strings (the cursor must store them
///    verbatim — a ms round-trip would move it backwards);
///  - **`sync_delete` = LWW-guarded server-stamped soft delete** returning
///    `{tombstoned}`; unknown ids ignored;
///  - **`user_settings.local_user_id`** readable (the canonical-user key;
///    nil until "Fragments' first device has synced" — the engine fails
///    closed on pushes until it exists).
///
/// NOT modeled: the omitted-NOT-NULL whole-call abort — the typed
/// `FragmentsEntry` carries all six NOT NULL columns non-optionally, so the
/// engine structurally cannot omit one (documented at the transport).
actor FakeFragmentsServer: FragmentsBridgeTransport {
    private struct StoredEntry {
        var entry: FragmentsEntry  // serverUpdatedAt always set once stored
        var writtenAtTick: Int64
    }

    /// id → current state. Rows are never removed; deletion is a tombstone.
    private var entries: [String: StoredEntry] = [:]
    /// Monotonic µs-style server stamp source — OPAQUE strings whose
    /// lexicographic order is assignment order, precision beyond what a
    /// ms date round-trip preserves (pinning the store-raw rule).
    private var serverStampCounter: Int64 = 0
    /// Logical clock for the visibility horizon; tests advance it.
    private var clock: Int64 = 0
    /// Rows written within the last `visibilityHorizon` ticks are invisible
    /// to pulls (the ~2 s changefeed fix, inside the RPC). 0 = no horizon.
    private let visibilityHorizon: Int64
    /// When set, a push whose `updated_at` exceeds this stamp is refused
    /// with the `clock_ahead:` conflict — models migration 7's >10-minute
    /// clamp (the real threshold is server wall clock + 10 min; tests place
    /// the limit explicitly).
    var clockAheadLimit: String?
    /// `user_settings.local_user_id` — nil models "the account has not
    /// synced from Fragments yet".
    var localUserID: String?

    /// Every applied write (upsert or delete) — the gratuitous-push
    /// assertion's counter: a body that never changed must never bump this.
    private(set) var acceptedWriteCount = 0

    init(visibilityHorizon: Int64 = 0, localUserID: String? = nil) {
        self.visibilityHorizon = visibilityHorizon
        self.localUserID = localUserID
    }

    func advanceClock(by ticks: Int64) {
        clock += ticks
    }

    func setClockAheadLimit(_ stamp: String?) {
        clockAheadLimit = stamp
    }

    func setLocalUserID(_ id: String?) {
        localUserID = id
    }

    private func nextServerStamp() -> String {
        serverStampCounter += 1
        return String(format: "1970-01-01T00:00:00.%06d+00:00", serverStampCounter)
    }

    // MARK: FragmentsBridgeTransport

    func push(_ batch: [FragmentsEntry]) throws -> FragmentsPushResponse {
        var response = FragmentsPushResponse(applied: 0, skipped: 0)
        for incoming in batch {
            if let limit = clockAheadLimit, incoming.updatedAt > limit {
                response.conflicts.append(FragmentsPushConflict(
                    id: incoming.id,
                    error: "clock_ahead: updated_at is more than 10 min ahead"))
                continue
            }
            let current = entries[incoming.id]
            if current == nil {
                // Live-unique (user_id, date): a NEW id colliding with a
                // live row for the same day is the DB-level unique
                // violation (a MIS-DERIVED id — never retryable).
                let collision = entries.values.contains {
                    $0.entry.deletedAt == nil
                        && $0.entry.userID == incoming.userID
                        && $0.entry.date == incoming.date
                }
                if collision {
                    response.conflicts.append(FragmentsPushConflict(
                        id: incoming.id,
                        error: "unique_violation: duplicate key value violates unique index journal_user_date"))
                    continue
                }
            }
            if let current {
                if current.entry.deletedAt == nil {
                    // Live row: TIES GO TO THE PUSHER (>=, migration 7).
                    guard incoming.updatedAt >= current.entry.updatedAt else {
                        response.skipped += 1
                        continue
                    }
                } else {
                    // Tombstoned row: resurrect only on STRICTLY newer.
                    guard incoming.updatedAt > current.entry.updatedAt else {
                        response.skipped += 1
                        continue
                    }
                }
            }
            var stored = incoming
            stored.serverUpdatedAt = nextServerStamp()
            stored.deletedAt = nil  // a winning upsert un-tombstones
            // created_at follows the WINNING push (migration 7 — the SET
            // list includes it; round 0's preserve-on-update was wrong).
            entries[incoming.id] = StoredEntry(entry: stored, writtenAtTick: clock)
            acceptedWriteCount += 1
            response.applied += 1
        }
        return response
    }

    func pull(after cursor: FragmentsPullCursor?, limit: Int) -> [FragmentsEntry] {
        entries.values
            .filter { $0.writtenAtTick <= clock - visibilityHorizon }
            .map(\.entry)
            .filter { entry in
                guard let cursor else { return true }
                let stamp = entry.serverUpdatedAt!
                return stamp > cursor.serverUpdatedAt
                    || (stamp == cursor.serverUpdatedAt && entry.id > cursor.id)
            }
            .sorted {
                ($0.serverUpdatedAt!, $0.id) < ($1.serverUpdatedAt!, $1.id)
            }
            .prefix(limit)
            .map { $0 }
    }

    func delete(ids: [String]) throws -> Int {
        // sync_delete: server-stamped soft delete; unknown ids ignored.
        var tombstoned = 0
        let stamp = nextServerStamp()
        for id in ids {
            guard var stored = entries[id], stored.entry.deletedAt == nil else { continue }
            stored.entry.deletedAt = stamp
            stored.entry.updatedAt = stamp
            stored.entry.serverUpdatedAt = nextServerStamp()
            stored.writtenAtTick = clock
            entries[id] = stored
            acceptedWriteCount += 1
            tombstoned += 1
        }
        return tombstoned
    }

    func fetchLocalUserID() throws -> String? {
        localUserID?.lowercased()
    }

    // MARK: Test inspection & the "author writes in Fragments" door

    var entryCount: Int { entries.count }

    func currentEntry(id: String) -> FragmentsEntry? {
        entries[id]?.entry
    }

    func liveEntry(userID: String, date: String) -> FragmentsEntry? {
        entries.values
            .map(\.entry)
            .first { $0.userID == userID && $0.date == date && $0.deletedAt == nil }
    }

    /// The deterministic id for a day under the server's OWN canonical
    /// user — what the Fragments app itself would derive.
    func entryID(day: String) -> String? {
        guard let canonical = localUserID else { return nil }
        return FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: canonical, dayKey: day)
    }

    /// Simulates the Fragments APP writing (its Day screen saving a body):
    /// an ordinary push under the deterministic id derived from the
    /// server's own canonical user — exactly what their client does.
    @discardableResult
    func fragmentsAppWrites(
        userID: String, day: String, body: String, updatedAt: String
    ) throws -> FragmentsPushResponse {
        guard let id = entryID(day: day) else {
            throw FragmentsTransportError.malformedResult(
                "fragmentsAppWrites needs localUserID (the app cannot write before first sync)")
        }
        let existing = entries[id]?.entry
        let entry = FragmentsEntry(
            id: id, userID: userID, date: day, body: body,
            createdAt: existing?.createdAt ?? updatedAt, updatedAt: updatedAt)
        return try push([entry])
    }

    /// Simulates a Fragments-side deletion of a day. (Today only the bridge
    /// could produce a journal tombstone — their UI has no journal-delete
    /// path, a reconciliation fact; kept for the defensive tombstone-landing
    /// pins.) `deletedAt` models the server's stamp at deletion time.
    @discardableResult
    func fragmentsAppDeletes(day: String, deletedAt: String) throws -> Bool {
        guard let id = entryID(day: day), var stored = entries[id] else { return false }
        guard deletedAt > stored.entry.updatedAt else { return false }
        stored.entry.deletedAt = deletedAt
        stored.entry.updatedAt = deletedAt
        stored.entry.serverUpdatedAt = nextServerStamp()
        stored.writtenAtTick = clock
        entries[id] = stored
        acceptedWriteCount += 1
        return true
    }
}
