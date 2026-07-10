import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b — the fake Fragments server's pinned behaviors, RE-PINNED at
/// the checkpoint reconciliation (2026-07-09) to the Fragments agents'
/// answers: their migration 7's shipped SQL, not their spec prose. Every
/// bridge suite stands on this verified ground.
@Suite("Fake Fragments server pins migration 7 (Phase 9b, reconciled)")
struct FakeFragmentsServerTests {
    private let user = "user-author"
    private let canonical = "9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8"

    private func makeServer(visibilityHorizon: Int64 = 0) -> FakeFragmentsServer {
        FakeFragmentsServer(visibilityHorizon: visibilityHorizon, localUserID: canonical)
    }

    private func entry(
        day: String, body: String, updatedAt: String,
        id: String? = nil, createdAt: String? = nil
    ) -> FragmentsEntry {
        FragmentsEntry(
            id: id ?? FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: canonical, dayKey: day)!,
            userID: user, date: day, body: body,
            createdAt: createdAt ?? updatedAt, updatedAt: updatedAt)
    }

    // MARK: The aggregate push response (corrected wire shape)

    @Test func pushRespondsWithAggregateCounters() async throws {
        let server = makeServer()
        let first = try await server.push([entry(day: "2026-07-09", body: "b",
                                                 updatedAt: "2026-07-09T10:00:00.000Z")])
        #expect(first == FragmentsPushResponse(applied: 1, skipped: 0, conflicts: []))
        // An older push is SKIPPED silently — no reason, no stamp.
        let older = try await server.push([entry(day: "2026-07-09", body: "old",
                                                 updatedAt: "2026-07-09T09:00:00.000Z")])
        #expect(older == FragmentsPushResponse(applied: 0, skipped: 1, conflicts: []))
    }

    // MARK: Row-LWW: TIES GO TO THE PUSHER (>=, migration 7 — corrected
    // from the strict > this fake shipped with)

    @Test func lwwTiesGoToThePusherOnLiveRows() async throws {
        let server = makeServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "first", updatedAt: "2026-07-09T10:00:00.000Z")])
        let stampAfterFirst = await server.currentEntry(
            id: FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: canonical, dayKey: day)!)!.serverUpdatedAt
        // The EXACT same stamp re-applies (>=) — and bumps
        // server_updated_at, churning every device's pull: this is why the
        // bridge's never-push-unchanged guard is load-bearing.
        let tie = try await server.push([entry(day: day, body: "tie wins", updatedAt: "2026-07-09T10:00:00.000Z")])
        #expect(tie.applied == 1)
        let current = await server.currentEntry(
            id: FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: canonical, dayKey: day)!)
        #expect(current?.body == "tie wins")
        #expect(current?.serverUpdatedAt != stampAfterFirst,
                "a winning re-push bumps server_updated_at")
        // Strictly older is skipped; the stored body untouched.
        let older = try await server.push([entry(day: day, body: "old", updatedAt: "2026-07-09T09:59:59.000Z")])
        #expect(older.skipped == 1)
        #expect(await server.currentEntry(
            id: FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: canonical, dayKey: day)!)?.body == "tie wins")
    }

    // MARK: Live-unique (user_id, date) — a mis-derived id lands in
    // conflicts[] as unique_violation (never retryable)

    @Test func aForeignIDForAnOccupiedDayIsAUniqueViolationConflict() async throws {
        let server = makeServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "body", updatedAt: "2026-07-09T10:00:00.000Z")])
        let rogue = entry(
            day: day, body: "fork", updatedAt: "2026-07-09T11:00:00.000Z",
            id: "11111111-1111-4111-8111-111111111111")
        let response = try await server.push([rogue])
        #expect(response.applied == 0)
        #expect(response.conflicts.count == 1)
        #expect(response.conflicts[0].isUniqueViolation)
        #expect(response.conflicts[0].id == rogue.id)
        #expect(await server.entryCount == 1)
    }

    // MARK: Un-tombstone only on STRICTLY-newer edits (confirmed — the
    // SQL's resurrect guard; their spec prose wrongly says stale-can-resurrect)

    /// Migration 7's EXACT resurrect predicate (addendum precision on the
    /// truncated line): `t.deleted_at IS NOT NULL AND excluded.updated_at
    /// > t.deleted_at` — strictly newer than the TOMBSTONE's deleted_at,
    /// NOT its updated_at. The distinguishing case: sync_delete stamps
    /// deleted_at without touching updated_at, so a push newer than the
    /// row's last edit but older than its tombstone must STAY DEAD (an
    /// updated_at comparison would wrongly resurrect it).
    @Test func unTombstoneComparesStrictlyAgainstTheTombstoneStamp() async throws {
        let server = makeServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "alive", updatedAt: "2026-07-09T10:00:00.000Z")])
        // Deleted LATER; updated_at stays at 10:00 (sync_delete semantics).
        _ = try await server.fragmentsAppDeletes(day: day, deletedAt: "2026-07-09T11:00:00.000Z")
        let id = FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: canonical, dayKey: day)!
        #expect(await server.currentEntry(id: id)?.updatedAt == "2026-07-09T10:00:00.000Z",
                "the delete must not touch updated_at")
        // THE PREDICATE DISTINGUISHER: newer than updated_at, older than
        // the tombstone — must be skipped (updated_at-comparison would
        // resurrect).
        let between = try await server.push([entry(day: day, body: "between?", updatedAt: "2026-07-09T10:30:00.000Z")])
        #expect(between.skipped == 1)
        #expect(await server.currentEntry(id: id)?.deletedAt != nil)
        // AT the tombstone: skipped (strict).
        let atTombstone = try await server.push([entry(day: day, body: "revive?", updatedAt: "2026-07-09T11:00:00.000Z")])
        #expect(atTombstone.skipped == 1)
        #expect(await server.currentEntry(id: id)?.deletedAt != nil)
        // Strictly newer than the tombstone revives.
        let newer = try await server.push([entry(day: day, body: "revived", updatedAt: "2026-07-09T11:00:01.000Z")])
        #expect(newer.applied == 1)
        let current = await server.currentEntry(id: id)
        #expect(current?.deletedAt == nil)
        #expect(current?.body == "revived")
    }

    // MARK: created_at follows the WINNING push (corrected — the SET list
    // includes it; round 0's preserve-on-update was wrong)

    @Test func createdAtFollowsTheWinningPush() async throws {
        let server = makeServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "v1",
                                         updatedAt: "2026-07-09T10:00:00.000Z",
                                         createdAt: "2026-07-09T10:00:00.000Z")])
        _ = try await server.push([entry(day: day, body: "v2",
                                         updatedAt: "2026-07-09T11:00:00.000Z",
                                         createdAt: "2026-07-09T11:00:00.000Z")])
        let id = FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: canonical, dayKey: day)!
        #expect(await server.currentEntry(id: id)?.createdAt == "2026-07-09T11:00:00.000Z",
                "the winner's created_at replaces the row's — echo the pulled value to preserve it")
    }

    // MARK: The clock-ahead clamp (>10 min; conflicts[] with the prefix)

    @Test func clockAheadPushesLandInConflictsWithThePrefix() async throws {
        let server = makeServer()
        await server.setClockAheadLimit("2026-07-09T12:00:00.000Z")
        let response = try await server.push([entry(day: "2026-07-09", body: "from the future",
                                                    updatedAt: "2026-07-09T12:10:00.001Z")])
        #expect(response.applied == 0)
        #expect(response.conflicts.count == 1)
        #expect(response.conflicts[0].isClockAhead)
        #expect(await server.entryCount == 0)
    }

    // MARK: Keyset pull: bare ordered array over OPAQUE µs-style stamps
    // + the visibility horizon inside the RPC

    @Test func pullIsKeysetOrderedAndCursorExclusive() async throws {
        let server = makeServer()
        for (index, day) in ["2026-07-01", "2026-07-02", "2026-07-03"].enumerated() {
            _ = try await server.push([entry(day: day, body: "b\(index)",
                                             updatedAt: "2026-07-09T10:00:0\(index).000Z")])
        }
        let all = try await server.pull(after: nil, limit: 10)
        #expect(all.map(\.date) == ["2026-07-01", "2026-07-02", "2026-07-03"])
        // Server stamps are µs-precision opaque strings — the raw-storage
        // rule's substrate (a ms round-trip would corrupt them).
        #expect(all[0].serverUpdatedAt!.contains("."))
        let cursor = FragmentsPullCursor(
            serverUpdatedAt: all[0].serverUpdatedAt!, id: all[0].id)
        let rest = try await server.pull(after: cursor, limit: 10)
        #expect(rest.map(\.date) == ["2026-07-02", "2026-07-03"])
        #expect(try await server.pull(after: nil, limit: 2).map(\.date)
                == ["2026-07-01", "2026-07-02"])
    }

    @Test func visibilityHorizonWithholdsYoungRowsThenServesThem() async throws {
        let server = makeServer(visibilityHorizon: 2)
        _ = try await server.push([entry(day: "2026-07-09", body: "young",
                                         updatedAt: "2026-07-09T10:00:00.000Z")])
        #expect(try await server.pull(after: nil, limit: 10).isEmpty)
        await server.advanceClock(by: 1)
        #expect(try await server.pull(after: nil, limit: 10).isEmpty)
        await server.advanceClock(by: 1)
        let served = try await server.pull(after: nil, limit: 10)
        #expect(served.map(\.body) == ["young"])
    }

    @Test func aReplacedRowIsServedOnceAtItsNewestState() async throws {
        let server = makeServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "v1", updatedAt: "2026-07-09T10:00:00.000Z")])
        _ = try await server.push([entry(day: day, body: "v2", updatedAt: "2026-07-09T11:00:00.000Z")])
        let pulled = try await server.pull(after: nil, limit: 10)
        #expect(pulled.count == 1)
        #expect(pulled[0].body == "v2")
    }

    // MARK: sync_delete: server-stamped soft delete → {tombstoned: n}

    @Test func deleteTombstonesAndReportsTheCount() async throws {
        let server = makeServer()
        _ = try await server.push([entry(day: "2026-07-09", body: "b", updatedAt: "2026-07-09T10:00:00.000Z")])
        let id = FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: canonical, dayKey: "2026-07-09")!
        let count = try await server.delete(ids: [id, "00000000-0000-4000-8000-000000000099"])
        #expect(count == 1, "unknown ids are ignored")
        #expect(await server.currentEntry(id: id)?.deletedAt != nil)
        // The tombstone rides the pull stream.
        let pulled = try await server.pull(after: nil, limit: 10)
        #expect(pulled.count == 1)
        #expect(pulled[0].isTombstoned)
    }

    // MARK: user_settings.local_user_id (the canonical-user source)

    @Test func localUserIDIsReadableAndNilBeforeFirstSync() async throws {
        let unsynced = FakeFragmentsServer()
        #expect(try await unsynced.fetchLocalUserID() == nil)
        let synced = makeServer()
        #expect(try await synced.fetchLocalUserID() == canonical)
        // Lowercased by convention, defensively.
        await synced.setLocalUserID("9F1C2B3A-4D5E-6F70-8192-A3B4C5D6E7F8")
        #expect(try await synced.fetchLocalUserID() == canonical)
    }
}
