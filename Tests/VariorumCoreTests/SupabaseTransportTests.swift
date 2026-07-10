import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Wire-shape pinning for the Supabase transport — NO network: the real
/// integration pass is the Phase 5 author-assist gate. These tests keep the
/// Swift DTOs byte-aligned with the shapes documented in
/// `Server/supabase/02_sync_rpc.sql`, so drift on either side fails here
/// before it fails against the author's project.
@Suite("Supabase transport wire shapes (Phase 5, Step 8 — no network)")
struct SupabaseTransportTests {
    @Test func pushItemEncodesTheDocumentedShape() throws {
        let row = SyncRow(
            table: "variant", rowID: "v1",
            columns: [
                "id": .text("v1"), "block_id": .text("b1"),
                "working_text": .text("hello"), "locked": .integer(0),
                "deleted_at": .null,
            ],
            syncVersion: 3)
        let data = try JSONEncoder().encode(PushItem(row: row))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["table"] as? String == "variant")
        #expect(json?["row_id"] as? String == "v1")
        #expect(json?["base_version"] as? Int == 3)
        let columns = json?["columns"] as? [String: Any]
        #expect(columns?["working_text"] as? String == "hello")
        #expect(columns?["locked"] as? Int == 0)
        #expect(columns?["deleted_at"] is NSNull)
        #expect(columns?["sync_version"] == nil, "sync_version rides as base_version, never a column")
    }

    @Test func pushResultsDecodeToOutcomes() throws {
        let accepted = """
            {"status": "accepted", "new_version": 4, "server_seq": 99}
            """.data(using: .utf8)!
        let outcome = try JSONDecoder().decode(PushResult.self, from: accepted).outcome()
        #expect(outcome == .accepted(newVersion: 4, serverSeq: 99))

        let rejected = """
            {"status": "rejected", "current": {"table": "container", "row_id": "c1",
             "sync_version": 2, "server_seq": 41,
             "columns": {"id": "c1", "title": "server truth", "locked": 0}}}
            """.data(using: .utf8)!
        let rejectedOutcome = try JSONDecoder().decode(PushResult.self, from: rejected).outcome()
        guard case .rejected(let current) = rejectedOutcome, let current else {
            Issue.record("reject with current row decoded wrong"); return
        }
        #expect(current.serverSeq == 41)
        #expect(current.row.syncVersion == 2)
        #expect(current.row.columns["title"] == .text("server truth"))
        #expect(current.row.columns["locked"] == .integer(0))

        let rejectedNil = """
            {"status": "rejected", "current": null}
            """.data(using: .utf8)!
        #expect(try JSONDecoder().decode(PushResult.self, from: rejectedNil).outcome()
                == .rejected(current: nil))

        let unknown = """
            {"status": "partial"}
            """.data(using: .utf8)!
        #expect(throws: SupabaseTransportError.malformedResult("unknown status 'partial'")) {
            _ = try JSONDecoder().decode(PushResult.self, from: unknown).outcome()
        }
    }

    @Test func pulledItemsDecodeToPulledRows() throws {
        let data = """
            [{"table": "setting", "row_id": "idle_commit_hours",
              "sync_version": 5, "server_seq": 12,
              "columns": {"key": "idle_commit_hours", "value": "24"}}]
            """.data(using: .utf8)!
        let items = try JSONDecoder().decode([PulledItem].self, from: data).map(\.pulledRow)
        #expect(items.count == 1)
        #expect(items[0].serverSeq == 12)
        #expect(items[0].row.table == "setting")
        #expect(items[0].row.rowID == "idle_commit_hours")
        #expect(items[0].row.syncVersion == 5)
        #expect(items[0].row.columns["value"] == .text("24"))
    }

    @Test func pullRequestEncodesSnakeCaseParameters() throws {
        let data = try JSONEncoder().encode(PullRequest(sinceSeq: 42, maxRows: 500))
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(json?["since_seq"] as? Int == 42)
        #expect(json?["max_rows"] as? Int == 500)
    }

    /// The mirror DDL must track the registry: every synced table appears in
    /// both .sql files' table lists, and the local-only tables in neither.
    /// (String-level pinning — the real schema check is the author-assisted
    /// integration pass.)
    @Test func serverSQLFilesCoverExactlyTheRegistry() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Tests/VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
            .appendingPathComponent("Server/supabase")
        let schema = try strippingComments(String(
            contentsOf: root.appendingPathComponent("01_mirror_schema.sql"), encoding: .utf8))
        let rpc = try strippingComments(String(
            contentsOf: root.appendingPathComponent("02_sync_rpc.sql"), encoding: .utf8))

        for table in SyncSchema.tables {
            #expect(schema.contains("create table \(table.name) ("),
                    "mirror DDL missing \(table.name)")
            #expect(rpc.contains("'\(table.name)'"), "RPC allowlist missing \(table.name)")
        }
        for local in SyncSchema.localOnlyTables {
            #expect(!schema.contains("create table \(local) "),
                    "\(local) is local-only and must not be mirrored")
        }
        #expect(!schema.contains("file_bookmark"),
                "file_bookmark is local-only (AppSpec §7) and must not be mirrored")
        #expect(!schema.lowercased().contains("references "),
                "mirrors carry NO foreign keys (SyncSpec §2 — load-bearing)")
        #expect(!schema.lowercased().contains("unique"),
                "mirrors carry NO uniqueness beyond the PK (SyncSpec §2)")
    }

    /// The SQL pins target code, not prose: drop `--` comment lines.
    private func strippingComments(_ sql: String) -> String {
        sql.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("--") }
            .joined(separator: "\n")
    }
}

// MARK: - Phase 9c, Step 2: the session seam + token refresh (no network)

/// The transport's auth posture (sync-engine surgery — the standing rider):
/// a live bearer session per call through `UserSessionProviding`; signed-out
/// refuses BEFORE any request composes; an HTTP 401 gets exactly ONE
/// refresh-and-retry; every failure shape leaves the round to the
/// scheduler's offline posture (outbox intact, cursor unmoved) — pinned
/// end-to-end below, including a full convergence scenario over the seam.
@Suite("Supabase transport session seam + refresh (Phase 9c, Step 2 — no network)")
struct SupabaseTransportSessionTests {
    private static let projectConfiguration = SupabaseTransport.Configuration(
        projectURL: URL(string: "https://example.supabase.co")!,
        apiKey: "publishable-key")

    /// Scripted HTTP hop: canned (status, body) per attempt, every request
    /// recorded (bearer assertions read the Authorization headers).
    private final class ScriptedHTTP: @unchecked Sendable {
        private let lock = NSLock()
        private var script: [(status: Int, body: String)]
        private var recorded: [URLRequest] = []

        init(_ script: [(status: Int, body: String)]) {
            self.script = script
        }

        var requests: [URLRequest] {
            lock.lock(); defer { lock.unlock() }
            return recorded
        }

        var bearers: [String?] {
            requests.map { $0.value(forHTTPHeaderField: "Authorization") }
        }

        /// Synchronous under the lock; the async loader closure just calls it.
        private func serve(_ request: URLRequest) throws -> (Data, URLResponse) {
            lock.lock(); defer { lock.unlock() }
            recorded.append(request)
            guard !script.isEmpty else {
                throw SupabaseTransportError.malformedResult("script exhausted")
            }
            let step = script.removeFirst()
            return (
                Data(step.body.utf8),
                HTTPURLResponse(
                    url: request.url!, statusCode: step.status,
                    httpVersion: nil, headerFields: nil)!)
        }

        func loader() -> @Sendable (URLRequest) async throws -> (Data, URLResponse) {
            { request in try self.serve(request) }
        }
    }

    /// A provider with a distinct refresh door: counts both calls, and can
    /// be told to fail either one.
    private final class RefreshableProvider: UserSessionProviding, @unchecked Sendable {
        private let lock = NSLock()
        private(set) var currentCalls = 0
        private(set) var refreshCalls = 0
        var currentResult: Result<UserSession, UserSessionError>
        var refreshResult: Result<UserSession, UserSessionError>

        init(
            current: Result<UserSession, UserSessionError>,
            refresh: Result<UserSession, UserSessionError>
        ) {
            self.currentResult = current
            self.refreshResult = refresh
        }

        /// Synchronous under the lock; the async protocol methods call them.
        private func takeCurrent() throws -> UserSession {
            lock.lock(); defer { lock.unlock() }
            currentCalls += 1
            return try currentResult.get()
        }

        private func takeRefreshed() throws -> UserSession {
            lock.lock(); defer { lock.unlock() }
            refreshCalls += 1
            return try refreshResult.get()
        }

        func currentSession() async throws -> UserSession {
            try takeCurrent()
        }

        func refreshedSession() async throws -> UserSession {
            try takeRefreshed()
        }
    }

    // MARK: The pinned shapes

    @Test func signedOutRefusesBeforeAnyRequestComposes() async throws {
        let http = ScriptedHTTP([])
        let provider = RefreshableProvider(
            current: .failure(.notSignedIn), refresh: .failure(.notSignedIn))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: http.loader())

        await #expect(throws: UserSessionError.notSignedIn) {
            _ = try await transport.pull(since: 0, limit: 10)
        }
        await #expect(throws: UserSessionError.notSignedIn) {
            _ = try await transport.push([])
        }
        #expect(http.requests.isEmpty, "a signed-out session must never compose a request")
        #expect(provider.refreshCalls == 0)
    }

    @Test func a401RefreshesOnceAndRetriesWithTheNewBearer() async throws {
        let http = ScriptedHTTP([(401, ""), (200, "[]")])
        let provider = RefreshableProvider(
            current: .success(UserSession(accessToken: "stale", userID: "u1")),
            refresh: .success(UserSession(accessToken: "fresh", userID: "u1")))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: http.loader())

        let rows = try await transport.pull(since: 0, limit: 10)
        #expect(rows.isEmpty)
        #expect(provider.refreshCalls == 1)
        #expect(http.bearers == ["Bearer stale", "Bearer fresh"],
                "the retry must carry the REFRESHED bearer")
        // Same payload both times — the retry re-sends, never re-shapes.
        #expect(http.requests[0].httpBody == http.requests[1].httpBody)
    }

    @Test func aSecond401SurfacesAfterExactlyOneRetry() async throws {
        let http = ScriptedHTTP([(401, "expired"), (401, "expired")])
        let provider = RefreshableProvider(
            current: .success(UserSession(accessToken: "stale", userID: "u1")),
            refresh: .success(UserSession(accessToken: "still-stale", userID: "u1")))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: http.loader())

        await #expect(throws: SupabaseTransportError.httpFailure(status: 401, body: "expired")) {
            _ = try await transport.pull(since: 0, limit: 10)
        }
        #expect(http.requests.count == 2, "exactly one retry — never a loop")
        #expect(provider.refreshCalls == 1)
    }

    @Test func aRefreshFailureSurfacesWithoutASecondRequest() async throws {
        let http = ScriptedHTTP([(401, "")])
        let provider = RefreshableProvider(
            current: .success(UserSession(accessToken: "stale", userID: "u1")),
            refresh: .failure(.notSignedIn))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: http.loader())

        await #expect(throws: UserSessionError.notSignedIn) {
            _ = try await transport.pull(since: 0, limit: 10)
        }
        #expect(http.requests.count == 1)
        #expect(provider.refreshCalls == 1)
    }

    /// Only a 401 means "the session is stale" — every other failure status
    /// surfaces directly, with no refresh attempt (a 500 must not burn a
    /// refresh, and a 403/404 is a server-shape problem, not a token one).
    @Test func aNon401FailureSurfacesWithoutARefresh() async throws {
        let http = ScriptedHTTP([(503, "unavailable")])
        let provider = RefreshableProvider(
            current: .success(UserSession(accessToken: "t", userID: "u1")),
            refresh: .success(UserSession(accessToken: "t2", userID: "u1")))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: http.loader())

        await #expect(throws: SupabaseTransportError.httpFailure(status: 503, body: "unavailable")) {
            _ = try await transport.pull(since: 0, limit: 10)
        }
        #expect(http.requests.count == 1)
        #expect(provider.refreshCalls == 0)
    }

    // MARK: Refusal leaves engine state byte-intact (the scheduler's
    // offline posture, reused not duplicated)

    @Test func aRefusedRoundLeavesOutboxAndCursorByteIntact() async throws {
        let provider = RefreshableProvider(
            current: .failure(.notSignedIn), refresh: .failure(.notSignedIn))
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: provider, load: ScriptedHTTP([]).loader())
        let client = try SyncClient(name: "A", prefix: "AA", transport: transport)

        try client.with { ops, _ in
            let post = try ops.createPost(title: "unsent", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Typed while signed out.", at: .end)
        }
        let before = try syncStateSnapshot(client.db)
        #expect(!before.outbox.isEmpty, "the scenario needs pending rows to protect")

        await #expect(throws: UserSessionError.notSignedIn) { try await client.push() }
        await #expect(throws: UserSessionError.notSignedIn) { try await client.pull() }

        let after = try syncStateSnapshot(client.db)
        #expect(after.outbox == before.outbox, "a refused round must keep the outbox byte-intact")
        #expect(after.cursor == before.cursor, "a refused round must not move the cursor")
        #expect(after.rowSeqs == before.rowSeqs)
    }

    private struct EngineStateSnapshot: Equatable {
        var outbox: [String]
        /// `sync_state.last_server_seq` only — the engine legitimately mints
        /// `device_id` lazily on its first round, and that bookkeeping is
        /// not protocol state a refusal must preserve.
        var cursor: String?
        var rowSeqs: [String]
    }

    private func syncStateSnapshot(_ db: AppDatabase) throws -> EngineStateSnapshot {
        try db.read { database in
            EngineStateSnapshot(
                outbox: try Row.fetchAll(
                    database,
                    sql: "SELECT table_name, row_id, queued_at FROM sync_outbox ORDER BY table_name, row_id"
                ).map(\.description),
                cursor: try String.fetchOne(
                    database, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'"),
                rowSeqs: try Row.fetchAll(
                    database,
                    sql: "SELECT table_name, row_id, server_seq FROM sync_row_seq ORDER BY table_name, row_id"
                ).map(\.description))
        }
    }

    // MARK: A full convergence scenario over the seam (transport wire
    // mapping + session auth + engine, end to end against the fake server
    // spoken to over the documented HTTP shapes — the harness stays
    // auth-agnostic: the fake models CAS + seq, never auth)

    @Test func aFullConvergenceScenarioRunsOverTheSessionSeam() async throws {
        let server = FakeSyncServer()
        let bearers = LockIsolated<[String?]>([])
        let loader: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            bearers.withValue { $0.append(request.value(forHTTPHeaderField: "Authorization")) }
            let body = request.httpBody ?? Data()
            let responseBody: Data
            if request.url!.lastPathComponent == "sync_push" {
                struct PushWire: Decodable { let batch: [PushItem] }
                let batch = try JSONDecoder().decode(PushWire.self, from: body).batch.map {
                    SyncRow(table: $0.table, rowID: $0.rowID,
                            columns: $0.columns, syncVersion: $0.baseVersion)
                }
                let outcomes = try await server.push(batch)
                let results = outcomes.map { outcome -> PushResult in
                    switch outcome {
                    case .accepted(let newVersion, let serverSeq):
                        return PushResult(
                            status: "accepted", newVersion: newVersion,
                            serverSeq: serverSeq, current: nil)
                    case .rejected(let current):
                        return PushResult(
                            status: "rejected", newVersion: nil, serverSeq: nil,
                            current: current.map {
                                PulledItem(
                                    table: $0.row.table, rowID: $0.row.rowID,
                                    syncVersion: $0.row.syncVersion,
                                    serverSeq: $0.serverSeq, columns: $0.row.columns)
                            })
                    }
                }
                responseBody = try JSONEncoder().encode(results)
            } else {
                struct PullWire: Decodable {
                    let since_seq: Int64
                    let max_rows: Int
                }
                let params = try JSONDecoder().decode(PullWire.self, from: body)
                let rows = try await server.pull(since: params.since_seq, limit: params.max_rows)
                responseBody = try JSONEncoder().encode(rows.map {
                    PulledItem(
                        table: $0.row.table, rowID: $0.row.rowID,
                        syncVersion: $0.row.syncVersion,
                        serverSeq: $0.serverSeq, columns: $0.row.columns)
                })
            }
            return (
                responseBody,
                HTTPURLResponse(
                    url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let transport = SupabaseTransport(
            configuration: Self.projectConfiguration,
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "session-token", userID: "author")),
            load: loader)

        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, clockOffset: 977, seed: 2)

        // The Step 7 basic scenario: disjoint offline edits on two devices.
        try a.with { ops, _ in
            let post = try ops.createPost(title: "from the Mac", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Desk thoughts.", at: .end)
        }
        try b.with { ops, _ in
            let entry = try ops.createPost(title: "from the phone", profile: .journal)
            _ = try ops.newBlock(in: entry.id, text: "Phone thoughts.", at: .end)
        }

        for _ in 1...4 {
            try await a.push()
            try await b.push()
            _ = try await a.pull()
            _ = try await b.pull()
        }

        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.syncedDump() == b.syncedDump(), "byte-identical synced tables over the seam")
        let seen = bearers.value
        #expect(!seen.isEmpty)
        #expect(seen.allSatisfy { $0 == "Bearer session-token" },
                "every request over the seam must carry the session bearer")
    }
}
