import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 1 — wire-shape pinning for the Fragments RPC transport,
/// NO network (the Phase 5/8 `SupabaseTransportTests` pattern).
///
/// **The shapes are PROVISIONAL:** the contract pins the RPC names and
/// semantics, not their JSON; these tests freeze THIS plan's documented
/// reading so drift on our side fails here, and the contract file carries
/// the ask for the Fragments agents to confirm or correct the shapes before
/// the (deferred, post-9c) real-project pass. Nothing here ever touches the
/// real project.
@Suite("Fragments transport wire shapes (Phase 9b, Step 1 — no network, PROVISIONAL)")
struct FragmentsTransportTests {
    @Test func pushRequestEncodesSnakeCaseEntryRows() throws {
        let entry = FragmentsEntry(
            id: "efd1b644-d604-5272-860d-ab4061668e96",
            userID: "user-author", date: "2026-07-09", body: "Dear diary…",
            createdAt: "2026-07-09T10:00:00.000Z",
            updatedAt: "2026-07-09T10:05:00.000Z")
        let data = try JSONEncoder().encode(
            FragmentsPushRequest(table: "journal_entries", entries: [WireEntry(entry: entry)]))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["table"] as? String == "journal_entries")
        let rows = json?["entries"] as? [[String: Any]]
        #expect(rows?.count == 1)
        #expect(rows?[0]["id"] as? String == "efd1b644-d604-5272-860d-ab4061668e96")
        #expect(rows?[0]["user_id"] as? String == "user-author")
        #expect(rows?[0]["date"] as? String == "2026-07-09")
        #expect(rows?[0]["body"] as? String == "Dear diary…")
        #expect(rows?[0]["created_at"] as? String == "2026-07-09T10:00:00.000Z")
        #expect(rows?[0]["updated_at"] as? String == "2026-07-09T10:05:00.000Z")
        #expect(rows?[0]["deleted_at"] is NSNull || rows?[0]["deleted_at"] == nil)
    }

    @Test func pushResultsDecodeToOutcomes() throws {
        let applied = """
            {"status": "applied", "server_updated_at": "2026-07-09T10:05:01.000Z"}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(WirePushResult.self, from: applied).outcome()
                == .applied(serverUpdatedAt: "2026-07-09T10:05:01.000Z"))

        let stale = """
            {"status": "stale"}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(WirePushResult.self, from: stale).outcome() == .stale)

        let rejected = """
            {"status": "rejected", "reason": "clock_ahead"}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(WirePushResult.self, from: rejected).outcome()
                == .rejected(reason: "clock_ahead"))

        let unknown = """
            {"status": "partial"}
            """.data(using: .utf8)!
        #expect(throws: FragmentsTransportError.malformedResult("unknown status 'partial'")) {
            _ = try JSONDecoder().decode(WirePushResult.self, from: unknown).outcome()
        }

        let appliedWithoutStamp = """
            {"status": "applied"}
            """.data(using: .utf8)!
        #expect(throws: FragmentsTransportError.malformedResult("applied without server_updated_at")) {
            _ = try JSONDecoder().decode(WirePushResult.self, from: appliedWithoutStamp).outcome()
        }
    }

    @Test func pullRequestEncodesTheKeysetCursor() throws {
        let data = try JSONEncoder().encode(FragmentsPullRequest(
            table: "journal_entries",
            afterUpdatedAt: "2026-07-09T10:05:01.000Z",
            afterID: "efd1b644-d604-5272-860d-ab4061668e96",
            limit: 200))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["table"] as? String == "journal_entries")
        #expect(json?["after_updated_at"] as? String == "2026-07-09T10:05:01.000Z")
        #expect(json?["after_id"] as? String == "efd1b644-d604-5272-860d-ab4061668e96")
        #expect(json?["limit"] as? Int == 200)
    }

    @Test func pulledEntriesDecodeIncludingTombstonesAndServerStamps() throws {
        let data = """
            [{"id": "efd1b644-d604-5272-860d-ab4061668e96", "user_id": "user-author",
              "date": "2026-07-09", "body": "", "created_at": "2026-07-09T10:00:00.000Z",
              "updated_at": "2026-07-09T12:00:00.000Z", "deleted_at": "2026-07-09T12:00:00.000Z",
              "server_updated_at": "2026-07-09T12:00:00.500Z"}]
            """.data(using: .utf8)!
        let entries = try JSONDecoder().decode([WireEntry].self, from: data).map(\.entry)
        #expect(entries.count == 1)
        #expect(entries[0].isTombstoned)
        #expect(entries[0].deletedAt == "2026-07-09T12:00:00.000Z")
        #expect(entries[0].serverUpdatedAt == "2026-07-09T12:00:00.500Z")
    }

    @Test func deleteRequestEncodesIDsAndStamp() throws {
        let data = try JSONEncoder().encode(FragmentsDeleteRequest(
            table: "journal_entries",
            ids: ["efd1b644-d604-5272-860d-ab4061668e96"],
            deletedAt: "2026-07-09T12:00:00.000Z"))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["table"] as? String == "journal_entries")
        #expect((json?["ids"] as? [String]) == ["efd1b644-d604-5272-860d-ab4061668e96"])
        #expect(json?["deleted_at"] as? String == "2026-07-09T12:00:00.000Z")
    }

    /// The credential posture (review focus 4): the transport authenticates
    /// with a USER session from the seam — the Authorization header carries
    /// the session's access token per call (so 9c's refresh slots in), and
    /// nothing in the bridge ever holds the Supabase personal access token.
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
        // Every endpoint consults the seam first; a signed-out session
        // refuses BEFORE any request is composed (offline-equivalent).
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.pull(after: nil, limit: 1)
        }
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.push([])
        }
        await #expect(throws: FragmentsSessionError.notSignedIn) {
            _ = try await transport.delete(ids: [], deletedAt: "2026-07-09T12:00:00.000Z")
        }
        #expect(counter.value == 3)
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
