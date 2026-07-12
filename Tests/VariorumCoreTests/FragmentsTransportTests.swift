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

    /// The four `conflicts[]` producers in their shipped SQL (ask 11,
    /// completed by the 2026-07-10 FINAL reply — the fourth was an omission
    /// in their earlier message, found by their own review). The two special
    /// classes fire exactly on their own strings; the other two producers —
    /// missing `updated_at`, and `"row carries no writable columns"`
    /// (verbatim; unreachable for a bridge sending all six columns) — must
    /// classify as NEITHER, so they land in the engine's generic
    /// refused-and-surfaced branch (visible every round, never parked as
    /// clock skew, never poisoned as a derivation bug).
    @Test func conflictErrorStringsCoverAllFourProducers() throws {
        let clockAhead = FragmentsPushConflict(
            id: "a", error: "clock_ahead: updated_at is more than 10 min ahead")
        #expect(clockAhead.isClockAhead && !clockAhead.isUniqueViolation)

        let uniqueViolation = FragmentsPushConflict(
            id: "b", error: "unique_violation: duplicate key value violates unique index journal_user_date")
        #expect(uniqueViolation.isUniqueViolation && !uniqueViolation.isClockAhead)

        // Producer 4, verbatim from their 2026-07-10 reply (shipped SQL).
        let noWritableColumns = FragmentsPushConflict(
            id: "c", error: "row carries no writable columns")
        #expect(!noWritableColumns.isClockAhead && !noWritableColumns.isUniqueViolation)

        // Producer 1 — missing `updated_at`. The exact server string is
        // theirs (not quoted verbatim in the contract); classification is
        // prefix/contains-based, so ANY string outside the two special
        // classes lands generic — that property is what this pins.
        let missingUpdatedAt = FragmentsPushConflict(
            id: "d", error: "row missing updated_at")
        #expect(!missingUpdatedAt.isClockAhead && !missingUpdatedAt.isUniqueViolation)

        // And all four decode cleanly inside a real aggregate response.
        let wire = """
            {"applied": 0, "skipped": 0, "conflicts": [
              {"id": "a", "error": "clock_ahead: updated_at is more than 10 min ahead"},
              {"id": "b", "error": "unique_violation: duplicate key value violates unique index journal_user_date"},
              {"id": "c", "error": "row carries no writable columns"},
              {"id": "d", "error": "row missing updated_at"}]}
            """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(FragmentsPushResponse.self, from: wire)
        #expect(decoded.conflicts.count == 4)
        #expect(decoded.conflicts.filter(\.isClockAhead).map(\.id) == ["a"])
        #expect(decoded.conflicts.filter(\.isUniqueViolation).map(\.id) == ["b"])
    }

    /// Ask 13, DEPLOYED (the 2026-07-11 ping — migration `20260707000013`
    /// live on hosted; SQL verified in their repo the same day): `replaced`
    /// now decodes TYPED (superseding this test's hedged predecessor, which
    /// pinned the key as ignored while the shape was a draft). The
    /// permanent ignore-unknown posture still holds for keys we don't
    /// consume — pinned here with `skipped_rows`, the fifth key their
    /// UNDEPLOYED migration 15 will add later.
    @Test func pushResponseDecodesReplacedReceiptsAndIgnoresUnknownKeys() throws {
        let withReceipt = """
            {"applied": 1, "skipped": 0, "conflicts": [],
             "replaced": [{"id": "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
                           "previous_body": "the destroyed text",
                           "previous_updated_at": "2026-07-09T10:00:00.692012+00:00"}],
             "skipped_rows": [{"table": "journal_entries", "id": "x"}]}
            """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(FragmentsPushResponse.self, from: withReceipt)
        #expect(decoded.replaced == [FragmentsReplacedReceipt(
            id: "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
            previousBody: "the destroyed text",
            previousUpdatedAt: "2026-07-09T10:00:00.692012+00:00")])
        #expect(decoded.applied == 1)

        // A pre-15.7 response (no key at all) decodes as nil —
        // consume-if-present is structural, never required.
        let without = """
            {"applied": 1, "skipped": 0, "conflicts": []}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(
            FragmentsPushResponse.self, from: without).replaced == nil)
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

    /// 9c review round 1 (MINOR) — THE RED-ON-OLD PIN: a Fragments token
    /// the SERVER judges stale (revocation, key rotation) gets ONE
    /// refresh-and-retry, mirroring the mirror transport's door. Pre-fix
    /// the transport surfaced the 401 without ever consulting
    /// `refreshedSession()`, wedging bridge rounds — visibly, state-intact,
    /// but wedged — until the local expiry margin tripped (up to ~59 min).
    @Test func a401RefreshesOnceAndRetriesWithTheNewBearer() async throws {
        final class RefreshingProvider: FragmentsSessionProviding, @unchecked Sendable {
            private let lock = NSLock()
            private var refreshes = 0
            var refreshCalls: Int {
                lock.lock(); defer { lock.unlock() }
                return refreshes
            }
            private func takeRefreshed() -> FragmentsUserSession {
                lock.lock(); defer { lock.unlock() }
                refreshes += 1
                return FragmentsUserSession(accessToken: "fresh", userID: "u1")
            }
            func currentSession() async throws -> FragmentsUserSession {
                FragmentsUserSession(accessToken: "stale", userID: "u1")
            }
            func refreshedSession() async throws -> FragmentsUserSession {
                takeRefreshed()
            }
        }
        final class ScriptedHTTP: @unchecked Sendable {
            private let lock = NSLock()
            private var script: [(Int, String)]
            private var recorded: [URLRequest] = []
            init(_ script: [(Int, String)]) { self.script = script }
            var requests: [URLRequest] {
                lock.lock(); defer { lock.unlock() }
                return recorded
            }
            func serve(_ request: URLRequest) throws -> (Data, URLResponse) {
                lock.lock(); defer { lock.unlock() }
                recorded.append(request)
                guard !script.isEmpty else {
                    throw FragmentsTransportError.malformedResult("script exhausted")
                }
                let (status, body) = script.removeFirst()
                return (Data(body.utf8), HTTPURLResponse(
                    url: request.url!, statusCode: status,
                    httpVersion: nil, headerFields: nil)!)
            }
        }

        let http = ScriptedHTTP([(401, "expired"), (200, "[]")])
        let provider = RefreshingProvider()
        let transport = FragmentsRPCTransport(
            configuration: .init(
                projectURL: URL(string: "https://example.supabase.co")!,
                apiKey: "publishable-key"),
            sessionProvider: provider,
            load: { try http.serve($0) })

        let rows = try await transport.pull(after: nil, limit: 1)
        #expect(rows.isEmpty)
        #expect(provider.refreshCalls == 1)
        #expect(http.requests.map { $0.value(forHTTPHeaderField: "Authorization") }
                == ["Bearer stale", "Bearer fresh"],
                "the retry must carry the REFRESHED bearer")
        // Same payload both times — the retry re-sends, never re-shapes.
        #expect(http.requests[0].httpBody == http.requests[1].httpBody)
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
