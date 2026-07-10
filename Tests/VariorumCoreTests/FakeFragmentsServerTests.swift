import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 1 — the fake Fragments server's pinned behaviors, each
/// tied to a contract fact, so every bridge suite stands on verified ground
/// (the same discipline as Phase 5's `FakeSyncServerTests`).
@Suite("Fake Fragments server pins the contract (Phase 9b, Step 1)")
struct FakeFragmentsServerTests {
    private let config = FragmentsBridgeConfiguration(
        idNamespace: UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!,
        canonicalUserKey: "author",
        userID: "user-author")

    private func entry(
        day: String, body: String, updatedAt: String,
        id: String? = nil, deletedAt: String? = nil
    ) -> FragmentsEntry {
        FragmentsEntry(
            id: id ?? config.entryID(dayKey: day)!,
            userID: config.userID, date: day, body: body,
            createdAt: updatedAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }

    // MARK: Row-LWW on client-stamped updated_at (contract fact 4)

    @Test func lwwStrictlyNewerWinsOlderIsStale() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        #expect(try await server.push([entry(day: day, body: "first", updatedAt: "2026-07-09T10:00:00.000Z")])
                == [.applied(serverUpdatedAt: "00000000000000000001")])
        // Strictly newer applies.
        #expect(try await server.push([entry(day: day, body: "second", updatedAt: "2026-07-09T10:00:01.000Z")]).first
                == .applied(serverUpdatedAt: "00000000000000000002"))
        // Equal stamp is stale (strict LWW).
        #expect(try await server.push([entry(day: day, body: "tie", updatedAt: "2026-07-09T10:00:01.000Z")])
                == [.stale])
        // Older is stale; the stored body is untouched.
        #expect(try await server.push([entry(day: day, body: "old", updatedAt: "2026-07-09T09:00:00.000Z")])
                == [.stale])
        let current = await server.currentEntry(id: config.entryID(dayKey: day)!)
        #expect(current?.body == "second")
        #expect(await server.acceptedWriteCount == 2)
    }

    // MARK: Live-unique (user_id, date) — the DB-enforced one-per-day
    // (contract fact 6: a WRONG id derivation fails loudly, never forks a day)

    @Test func aForeignIDForAnOccupiedDayIsAUniqueViolation() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "body", updatedAt: "2026-07-09T10:00:00.000Z")])
        let rogue = entry(
            day: day, body: "fork", updatedAt: "2026-07-09T11:00:00.000Z",
            id: "11111111-1111-4111-8111-111111111111")
        #expect(try await server.push([rogue])
                == [.rejected(reason: "unique_violation(user_id,date)")])
        #expect(await server.entryCount == 1)
    }

    // MARK: Un-tombstone only on strictly-newer edits (contract fact 4)

    @Test func unTombstoneRequiresStrictlyNewer() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "alive", updatedAt: "2026-07-09T10:00:00.000Z")])
        _ = try await server.delete(
            ids: [config.entryID(dayKey: day)!], deletedAt: "2026-07-09T11:00:00.000Z")
        // Re-push stamped at (or before) the tombstone: stale, stays dead.
        #expect(try await server.push([entry(day: day, body: "revive?", updatedAt: "2026-07-09T11:00:00.000Z")])
                == [.stale])
        #expect(await server.currentEntry(id: config.entryID(dayKey: day)!)?.deletedAt != nil)
        // Strictly newer revives.
        let outcome = try await server.push(
            [entry(day: day, body: "revived", updatedAt: "2026-07-09T11:00:01.000Z")])
        if case .applied = outcome[0] {} else { Issue.record("strictly-newer edit must un-tombstone") }
        let current = await server.currentEntry(id: config.entryID(dayKey: day)!)
        #expect(current?.deletedAt == nil)
        #expect(current?.body == "revived")
    }

    @Test func deleteIsLWWGuardedToo() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "newer", updatedAt: "2026-07-09T12:00:00.000Z")])
        // A delete stamped before the row's edit is stale — the edit wins.
        #expect(try await server.delete(
            ids: [config.entryID(dayKey: day)!], deletedAt: "2026-07-09T11:00:00.000Z")
                == [.stale])
        #expect(await server.currentEntry(id: config.entryID(dayKey: day)!)?.deletedAt == nil)
    }

    // MARK: created_at preserved on update (documented reading; ask filed)

    @Test func createdAtSurvivesUpdates() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "v1", updatedAt: "2026-07-09T10:00:00.000Z")])
        _ = try await server.push([entry(day: day, body: "v2", updatedAt: "2026-07-09T11:00:00.000Z")])
        #expect(await server.currentEntry(id: config.entryID(dayKey: day)!)?.createdAt
                == "2026-07-09T10:00:00.000Z")
    }

    // MARK: Clock-ahead clamp (contract fact 4)

    @Test func clockAheadPushesAreRejected() async throws {
        let server = FakeFragmentsServer()
        await server.setClockAheadLimit("2026-07-09T12:00:00.000Z")
        #expect(try await server.push([entry(day: "2026-07-09", body: "from the future",
                                             updatedAt: "2026-07-09T12:10:00.000Z")])
                == [.rejected(reason: "clock_ahead")])
        #expect(await server.entryCount == 0)
    }

    // MARK: Keyset pull + the visibility horizon (contract facts 2/4 + ask 1)

    @Test func pullIsKeysetOrderedAndCursorExclusive() async throws {
        let server = FakeFragmentsServer()
        for (index, day) in ["2026-07-01", "2026-07-02", "2026-07-03"].enumerated() {
            _ = try await server.push([entry(day: day, body: "b\(index)",
                                             updatedAt: "2026-07-09T10:00:0\(index).000Z")])
        }
        let all = try await server.pull(after: nil, limit: 10)
        #expect(all.map(\.date) == ["2026-07-01", "2026-07-02", "2026-07-03"])
        // Strictly after the first row's (server_updated_at, id).
        let cursor = FragmentsPullCursor(
            serverUpdatedAt: all[0].serverUpdatedAt!, id: all[0].id)
        let rest = try await server.pull(after: cursor, limit: 10)
        #expect(rest.map(\.date) == ["2026-07-02", "2026-07-03"])
        // Limit truncates in order.
        #expect(try await server.pull(after: nil, limit: 2).map(\.date)
                == ["2026-07-01", "2026-07-02"])
    }

    @Test func visibilityHorizonWithholdsYoungRowsThenServesThem() async throws {
        let server = FakeFragmentsServer(visibilityHorizon: 2)
        _ = try await server.push([entry(day: "2026-07-09", body: "young",
                                         updatedAt: "2026-07-09T10:00:00.000Z")])
        // Younger than the horizon: invisible.
        #expect(try await server.pull(after: nil, limit: 10).isEmpty)
        await server.advanceClock(by: 1)
        #expect(try await server.pull(after: nil, limit: 10).isEmpty)
        // Old enough: served, at its ORIGINAL keyset position.
        await server.advanceClock(by: 1)
        let served = try await server.pull(after: nil, limit: 10)
        #expect(served.map(\.body) == ["young"])
    }

    @Test func aReplacedRowIsServedOnceAtItsNewestState() async throws {
        let server = FakeFragmentsServer()
        let day = "2026-07-09"
        _ = try await server.push([entry(day: day, body: "v1", updatedAt: "2026-07-09T10:00:00.000Z")])
        _ = try await server.push([entry(day: day, body: "v2", updatedAt: "2026-07-09T11:00:00.000Z")])
        // State-based, not an op log: one row, current state, newest stamp.
        let pulled = try await server.pull(after: nil, limit: 10)
        #expect(pulled.count == 1)
        #expect(pulled[0].body == "v2")
    }
}
