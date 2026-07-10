import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b — wire-shape pinning for the Fragments RPC transport, NO
/// network. RECONCILED 2026-07-09 to the Fragments agents' answers (asks
/// 11/12/14 ANSWERED — the shapes are no longer PROVISIONAL): `p_`-prefixed
/// parameter objects; `sync_push` → the aggregate response; `sync_pull` →
/// a BARE array; `sync_delete(p_table, p_ids)` → `{tombstoned}`. The real
/// pass (9c Step 6) needs credentials only.
@Suite("Fragments transport wire shapes (Phase 9b — reconciled, no network)")
struct FragmentsTransportTests {
    @Test func pushParamsEncodeTheDocumentedShape() throws {
        let entry = FragmentsEntry(
            id: "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
            userID: "user-author", date: "2026-07-09", body: "Dear diary…",
            createdAt: "2026-07-09T10:00:00.000Z",
            updatedAt: "2026-07-09T10:05:00.000Z")
        let data = try JSONEncoder().encode(
            SyncPushParams(pTable: "journal_entries", pRows: [WireEntry(entry: entry)]))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["p_table"] as? String == "journal_entries")
        let rows = json?["p_rows"] as? [[String: Any]]
        #expect(rows?.count == 1)
        // ALL SIX NOT NULL columns present — an omitted one on an inserting
        // row aborts the ENTIRE call (not_null_violation, nothing written).
        #expect(rows?[0]["id"] as? String == "7ab43871-10ad-5597-a0d7-d721fcd3ecf9")
        #expect(rows?[0]["user_id"] as? String == "user-author")
        #expect(rows?[0]["date"] as? String == "2026-07-09")  // the column is `date`
        #expect(rows?[0]["body"] as? String == "Dear diary…")
        #expect(rows?[0]["created_at"] as? String == "2026-07-09T10:00:00.000Z")
        #expect(rows?[0]["updated_at"] as? String == "2026-07-09T10:05:00.000Z")
    }

    @Test func pushResponseDecodesAggregateCounters() throws {
        let clean = """
            {"applied": 1, "skipped": 0, "conflicts": []}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(FragmentsPushResponse.self, from: clean)
                == FragmentsPushResponse(applied: 1, skipped: 0, conflicts: []))

        let refused = """
            {"applied": 0, "skipped": 1, "conflicts": [
              {"id": "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
               "error": "clock_ahead: updated_at is more than 10 min ahead"}]}
            """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(FragmentsPushResponse.self, from: refused)
        #expect(decoded.skipped == 1)
        #expect(decoded.conflicts.count == 1)
        #expect(decoded.conflicts[0].isClockAhead)
        #expect(!decoded.conflicts[0].isUniqueViolation)

        let violation = FragmentsPushConflict(
            id: "x", error: "unique_violation: duplicate key value violates unique index journal_user_date")
        #expect(violation.isUniqueViolation)
        #expect(!violation.isClockAhead)
    }

    @Test func pullParamsEncodeThePPrefixedKeyset() throws {
        let data = try JSONEncoder().encode(SyncPullParams(
            pTable: "journal_entries",
            pAfterTs: "2026-07-09T10:05:01.692012+00:00",
            pAfterId: "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
            pLimit: 500))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["p_table"] as? String == "journal_entries")
        #expect(json?["p_after_ts"] as? String == "2026-07-09T10:05:01.692012+00:00")
        #expect(json?["p_after_id"] as? String == "7ab43871-10ad-5597-a0d7-d721fcd3ecf9")
        #expect(json?["p_limit"] as? Int == 500)
    }

    /// The pull response is a BARE array; `server_updated_at` is a
    /// µs-precision OPAQUE string that must survive verbatim into the
    /// cursor (a ms round-trip would move it backwards and re-deliver
    /// rows forever).
    @Test func pulledRowsDecodeFromABareArrayPreservingOpaqueStamps() throws {
        let microStamp = "2026-07-09T12:00:00.692012+00:00"
        let data = """
            [{"id": "7ab43871-10ad-5597-a0d7-d721fcd3ecf9", "user_id": "user-author",
              "date": "2026-07-09", "body": "", "created_at": "2026-07-09T10:00:00.000Z",
              "updated_at": "2026-07-09T12:00:00.000Z", "deleted_at": "2026-07-09T12:00:00.000Z",
              "server_updated_at": "\(microStamp)"}]
            """.data(using: .utf8)!
        let entries = try JSONDecoder().decode([WireEntry].self, from: data).map(\.entry)
        #expect(entries.count == 1)
        #expect(entries[0].isTombstoned, "tombstones ride the pull stream")
        #expect(entries[0].serverUpdatedAt == microStamp,
                "the µs stamp must survive byte-for-byte — it becomes the cursor")
    }

    @Test func deleteParamsAndResponse() throws {
        let data = try JSONEncoder().encode(SyncDeleteParams(
            pTable: "journal_entries",
            pIds: ["7ab43871-10ad-5597-a0d7-d721fcd3ecf9"]))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["p_table"] as? String == "journal_entries")
        #expect((json?["p_ids"] as? [String]) == ["7ab43871-10ad-5597-a0d7-d721fcd3ecf9"])

        let response = """
            {"tombstoned": 2}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(SyncDeleteResponse.self, from: response).tombstoned == 2)
    }

    /// The canonical-user read: `user_settings` rows decode minimally —
    /// exactly one column, everything else ignored.
    @Test func userSettingsRowsDecodeMinimally() throws {
        let data = """
            [{"id": "abc", "local_user_id": "9F1C2B3A-4D5E-6F70-8192-A3B4C5D6E7F8",
              "some_future_column": 42, "server_updated_at": "x"}]
            """.data(using: .utf8)!
        let rows = try JSONDecoder().decode([UserSettingsRow].self, from: data)
        #expect(rows.first?.localUserId == "9F1C2B3A-4D5E-6F70-8192-A3B4C5D6E7F8")
    }

    /// The credential posture (review focus 4): the transport authenticates
    /// with a USER session from the seam — per call, so 9c's refresh slots
    /// in — and nothing in the bridge ever holds the personal access token.
    @Test func transportAsksTheSessionSeamPerCall() async throws {
        struct CountingProvider: FragmentsSessionProviding {
            let counter: LockIsolatedBox
            func currentSession() async throws -> FragmentsUserSession {
                counter.increment()
                throw FragmentsSessionError.notSignedIn  // stop before any network
            }
        }
        let counter = LockIsolatedBox()
        let transport = FragmentsRPCTransport(
            configuration: .init(
                projectURL: URL(string: "https://example.supabase.co")!,
                apiKey: "publishable-key"),
            sessionProvider: CountingProvider(counter: counter))
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.pull(after: nil, limit: 1)
        }
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.push([])
        }
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.delete(ids: [])
        }
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.fetchLocalUserID()
        }
        #expect(counter.value == 4)
    }

    /// Round 2, NIT 8: a session authenticated as a DIFFERENT user than the
    /// one the bridge composes rows for is a wiring bug — refused before any
    /// request composes (their RLS must never be the only guard).
    @Test func transportRefusesASessionUserMismatch() async throws {
        let transport = FragmentsRPCTransport(
            configuration: .init(
                projectURL: URL(string: "https://example.supabase.co")!,
                apiKey: "publishable-key",
                expectedUserID: "user-author"),
            sessionProvider: StaticFragmentsSessionProvider(
                session: FragmentsUserSession(accessToken: "t", userID: "someone-else")))
        await #expect(throws: FragmentsTransportError.sessionUserMismatch(
            expected: "user-author", actual: "someone-else")) {
            _ = try await transport.pull(after: nil, limit: 1)
        }
    }
}

/// Tiny thread-safe counter for the seam test.
final class LockIsolatedBox: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int {
        lock.lock(); defer { lock.unlock() }
        return count
    }
    func increment() {
        lock.lock(); defer { lock.unlock() }
        count += 1
    }
}
