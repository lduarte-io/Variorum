import Foundation
@testable import VariorumCore

/// The in-process stand-in for Fragments' `journal_entries` satellite,
/// pinned to `notes/fragments-bridge-contract.md` — never to the real
/// project (the manual real-project pass is deferred post-9c, author's
/// call). The pinned behaviors, each verified by `FakeFragmentsServerTests`
/// so bridge suites stand on tested ground:
///
///  - **live-unique `(user_id, date)`** (contract fact 6, DB-enforced): an
///    insert whose `(user_id, date)` collides with a LIVE row under a
///    different id is rejected — the deterministic id is what makes both
///    apps converge on ONE row, and the fake fails loudly if a derivation
///    ever drifts;
///  - **row-LWW on client-stamped `updated_at`** (fact 4): an upsert applies
///    only when strictly newer than the stored row; otherwise `.stale`;
///  - **un-tombstone only on strictly-newer edits** (fact 4) — subsumed by
///    strict LWW, exercised by its own test;
///  - **clock-ahead clamp** (fact 4): an optional limit stamp; pushes
///    stamped beyond it are `.rejected`;
///  - **`server_updated_at` keyset + the ~2 s visibility horizon** (facts
///    2/4): pulls serve rows strictly after `(server_updated_at, id)`,
///    never rows younger than the horizon (modeled as logical ticks, like
///    `FakeSyncServer`);
///  - `created_at` is preserved on update (documented reading; contract ask
///    filed).
actor FakeFragmentsServer: FragmentsBridgeTransport {
    private struct StoredEntry {
        var entry: FragmentsEntry  // serverUpdatedAt always set once stored
        var writtenAtTick: Int64
    }

    /// id → current state. Rows are never removed; deletion is a tombstone.
    private var entries: [String: StoredEntry] = [:]
    /// Monotonic `server_updated_at` source (zero-padded so lexicographic
    /// order == assignment order, like a timestamp column).
    private var serverStampCounter: Int64 = 0
    /// Logical clock for the visibility horizon; tests advance it.
    private var clock: Int64 = 0
    /// Rows written within the last `visibilityHorizon` ticks are invisible
    /// to pulls (their ~2 s changefeed fix). 0 = no horizon.
    private let visibilityHorizon: Int64
    /// When set, a push whose `updated_at` exceeds this stamp is rejected —
    /// the clock-ahead clamp (contract fact 4).
    var clockAheadLimit: String?

    /// Every applied write (upsert or delete) — the gratuitous-push
    /// assertion's counter: a body that never changed must never bump this.
    private(set) var acceptedWriteCount = 0

    init(visibilityHorizon: Int64 = 0) {
        self.visibilityHorizon = visibilityHorizon
    }

    func advanceClock(by ticks: Int64) {
        clock += ticks
    }

    func setClockAheadLimit(_ stamp: String?) {
        clockAheadLimit = stamp
    }

    // MARK: FragmentsBridgeTransport

    func push(_ batch: [FragmentsEntry]) throws -> [FragmentsPushOutcome] {
        batch.map { incoming in
            if let limit = clockAheadLimit, incoming.updatedAt > limit {
                return .rejected(reason: "clock_ahead")
            }
            let current = entries[incoming.id]
            if current == nil {
                // Live-unique (user_id, date): a NEW id colliding with a
                // live row for the same day is a DB-level unique violation
                // (contract fact 6) — the guard a wrong id derivation hits.
                let collision = entries.values.contains {
                    $0.entry.deletedAt == nil
                        && $0.entry.userID == incoming.userID
                        && $0.entry.date == incoming.date
                }
                if collision {
                    return .rejected(reason: "unique_violation(user_id,date)")
                }
            }
            if let current, incoming.updatedAt <= current.entry.updatedAt {
                // Row-LWW on client stamps; un-tombstone requires strictly
                // newer too (this branch covers both).
                return .stale
            }
            serverStampCounter += 1
            let serverStamp = String(format: "%020d", serverStampCounter)
            var stored = incoming
            stored.serverUpdatedAt = serverStamp
            if let current {
                stored.createdAt = current.entry.createdAt  // preserved on update
            }
            entries[incoming.id] = StoredEntry(entry: stored, writtenAtTick: clock)
            acceptedWriteCount += 1
            return .applied(serverUpdatedAt: serverStamp)
        }
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

    func delete(ids: [String], deletedAt: String) throws -> [FragmentsPushOutcome] {
        ids.map { id in
            guard var stored = entries[id] else {
                return .rejected(reason: "not_found")
            }
            guard deletedAt > stored.entry.updatedAt else { return .stale }
            serverStampCounter += 1
            let serverStamp = String(format: "%020d", serverStampCounter)
            stored.entry.deletedAt = deletedAt
            stored.entry.updatedAt = deletedAt
            stored.entry.serverUpdatedAt = serverStamp
            stored.writtenAtTick = clock
            entries[id] = stored
            acceptedWriteCount += 1
            return .applied(serverUpdatedAt: serverStamp)
        }
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

    /// Simulates the Fragments APP writing (its Day screen saving a body):
    /// an ordinary push under the deterministic id — exactly what their
    /// client does. Returns the outcome so tests can assert it applied.
    @discardableResult
    func fragmentsAppWrites(
        configuration: FragmentsBridgeConfiguration,
        day: String, body: String, updatedAt: String
    ) throws -> FragmentsPushOutcome {
        let id = configuration.entryID(dayKey: day)!
        let existing = entries[id]?.entry
        let entry = FragmentsEntry(
            id: id, userID: configuration.userID, date: day, body: body,
            createdAt: existing?.createdAt ?? updatedAt, updatedAt: updatedAt)
        return try push([entry])[0]
    }

    /// Simulates the Fragments APP deleting a day's entry.
    @discardableResult
    func fragmentsAppDeletes(
        configuration: FragmentsBridgeConfiguration,
        day: String, deletedAt: String
    ) throws -> FragmentsPushOutcome {
        try delete(ids: [configuration.entryID(dayKey: day)!], deletedAt: deletedAt)[0]
    }
}
