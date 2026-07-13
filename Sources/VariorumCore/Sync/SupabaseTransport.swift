import Foundation

/// The real-server implementation of `SyncTransport` (SyncSpec §2): the two
/// RPC endpoints (`sync_push`, `sync_pull` — Server/supabase/02_sync_rpc.sql,
/// as reworked by 03/04) over URLSession, authenticated per call through the
/// `UserSessionProviding` seam (Phase 9c, Step 2 — replacing Phase 5's
/// static single-user token; the paste-in's fixed token rides a
/// `StaticSessionProvider` until Step 5 retires it into the real sign-in).
///
/// The auth posture, pinned by `SupabaseTransportSessionTests`:
///  - **signed-out refuses before any request composes** (the provider's
///    throw propagates; the scheduler's offline posture keeps outbox and
///    cursor intact — reused, never duplicated);
///  - **an HTTP 401 gets ONE refresh-and-retry** (the token looked valid
///    locally but the server judged it stale/revoked); a second 401
///    surfaces as a failed round — never a loop.
///
/// The engine never knows which transport it is talking to — the whole
/// correctness suite runs against the in-process fake; this type carries
/// only wire mapping and HTTP plumbing. The integration pass against the
/// real Supabase project is an **author-assist gate** (account, project,
/// and session are hers).
public struct SupabaseTransport: SyncTransport {
    public struct Configuration: Sendable {
        /// `https://<project>.supabase.co`
        public let projectURL: URL
        /// The project API key (`apikey` header). After Phase 9c's RLS flip
        /// this is a genuinely publishable key: it identifies the project
        /// and grants nothing — the session is the identity.
        public let apiKey: String

        public init(projectURL: URL, apiKey: String) {
            self.projectURL = projectURL
            self.apiKey = apiKey
        }
    }

    public let configuration: Configuration
    /// The per-call auth seam (Phase 9c): sign-in state and token refresh
    /// live behind the provider, never here.
    public let sessionProvider: any UserSessionProviding
    /// The HTTP hop, seam-injectable for the no-network suites (the same
    /// discipline as the bridge transport's fakes); production is
    /// `URLSession.data(for:)`.
    private let load: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(
        configuration: Configuration,
        sessionProvider: any UserSessionProviding,
        session: URLSession = .shared
    ) {
        self.init(
            configuration: configuration,
            sessionProvider: sessionProvider,
            load: { try await session.data(for: $0) })
    }

    init(
        configuration: Configuration,
        sessionProvider: any UserSessionProviding,
        load: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.load = load
    }

    // MARK: - SyncTransport

    public func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
        let data = try await rpc("sync_push", body: PushRequest(batch: batch.map(PushItem.init)))
        let results = try JSONDecoder().decode([PushResult].self, from: data)
        guard results.count == batch.count else {
            throw SupabaseTransportError.mismatchedResultCount(
                pushed: batch.count, returned: results.count)
        }
        return try results.map { try $0.outcome() }
    }

    public func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
        let data = try await rpc("sync_pull", body: PullRequest(sinceSeq: since, maxRows: limit))
        return try JSONDecoder().decode([PulledItem].self, from: data).map(\.pulledRow)
    }

    /// The mirror's deployed lockstep marker (SyncSpec §12; Phase 11, Step
    /// A1). `sync_schema_version()` is a zero-arg RPC returning a bare
    /// bigint; a 404 means the function does not exist — the pre-marker
    /// (9c-era) deployment, DEFINED as version 1, so a Phase-11 client
    /// against an un-migrated mirror refuses with a self-explaining
    /// mismatch instead of a raw HTTP error. Same auth posture as the
    /// other RPCs (signed-out refuses before composing; ONE 401
    /// refresh-and-retry).
    public func schemaVersion() async throws -> Int {
        let session = try await sessionProvider.currentSession()
        let payload = Data("{}".utf8)
        var (data, status) = try await send(
            "sync_schema_version", payload: payload, bearer: session.accessToken)
        if status == 401 {
            let refreshed = try await sessionProvider.refreshedSession()
            (data, status) = try await send(
                "sync_schema_version", payload: payload, bearer: refreshed.accessToken)
        }
        if status == 404 { return 1 }
        guard (200..<300).contains(status) else {
            throw SupabaseTransportError.httpFailure(
                status: status, body: String(data: data, encoding: .utf8) ?? "")
        }
        let body = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let version = Int(body) else {
            throw SupabaseTransportError.malformedResult(
                "sync_schema_version returned '\(body)', not an integer")
        }
        return version
    }

    // MARK: - HTTP plumbing

    private func rpc<Body: Encodable>(_ function: String, body: Body) async throws -> Data {
        // Signed-out refuses BEFORE any request composes (the seam's pinned
        // shape, mirrored from the 9b bridge transport): the provider's
        // throw propagates and the round fails cleanly.
        let session = try await sessionProvider.currentSession()
        let payload = try JSONEncoder().encode(body)

        let (data, status) = try await send(function, payload: payload, bearer: session.accessToken)
        if status == 401 {
            // ONE refresh-and-retry (Phase 9c, Step 2): the server judged
            // the token stale or revoked despite the provider considering
            // it current. A refresh failure propagates (a failed round);
            // a second 401 surfaces below — never a loop.
            let refreshed = try await sessionProvider.refreshedSession()
            let (retryData, retryStatus) = try await send(
                function, payload: payload, bearer: refreshed.accessToken)
            guard (200..<300).contains(retryStatus) else {
                throw SupabaseTransportError.httpFailure(
                    status: retryStatus,
                    body: String(data: retryData, encoding: .utf8) ?? "")
            }
            return retryData
        }
        guard (200..<300).contains(status) else {
            throw SupabaseTransportError.httpFailure(
                status: status,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        return data
    }

    private func send(
        _ function: String, payload: Data, bearer: String
    ) async throws -> (Data, Int) {
        var request = URLRequest(
            url: configuration.projectURL
                .appendingPathComponent("rest/v1/rpc")
                .appendingPathComponent(function))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.httpBody = payload

        let (data, response) = try await load(request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseTransportError.notHTTP
        }
        return (data, http.statusCode)
    }
}

public enum SupabaseTransportError: Error, Equatable, Sendable {
    case notHTTP
    case httpFailure(status: Int, body: String)
    case mismatchedResultCount(pushed: Int, returned: Int)
    case malformedResult(String)
}

// MARK: - Wire DTOs (shapes pinned in Server/supabase/02_sync_rpc.sql)

struct PushRequest: Encodable {
    let batch: [PushItem]
}

struct PushItem: Codable {
    let table: String
    let rowID: String
    let baseVersion: Int
    let columns: [String: SyncValue]

    enum CodingKeys: String, CodingKey {
        case table
        case rowID = "row_id"
        case baseVersion = "base_version"
        case columns
    }

    init(row: SyncRow) {
        self.table = row.table
        self.rowID = row.rowID
        self.baseVersion = row.syncVersion
        self.columns = row.columns
    }
}

struct PushResult: Codable {
    let status: String
    let newVersion: Int?
    let serverSeq: Int64?
    let current: PulledItem?

    enum CodingKeys: String, CodingKey {
        case status
        case newVersion = "new_version"
        case serverSeq = "server_seq"
        case current
    }

    func outcome() throws -> SyncPushOutcome {
        switch status {
        case "accepted":
            guard let newVersion, let serverSeq else {
                throw SupabaseTransportError.malformedResult("accepted without version/seq")
            }
            return .accepted(newVersion: newVersion, serverSeq: serverSeq)
        case "rejected":
            return .rejected(current: current?.pulledRow)
        default:
            throw SupabaseTransportError.malformedResult("unknown status '\(status)'")
        }
    }
}

struct PulledItem: Codable {
    let table: String
    let rowID: String
    let syncVersion: Int
    let serverSeq: Int64
    let columns: [String: SyncValue]

    enum CodingKeys: String, CodingKey {
        case table
        case rowID = "row_id"
        case syncVersion = "sync_version"
        case serverSeq = "server_seq"
        case columns
    }

    var pulledRow: SyncPulledRow {
        SyncPulledRow(
            row: SyncRow(table: table, rowID: rowID, columns: columns, syncVersion: syncVersion),
            serverSeq: serverSeq)
    }
}

struct PullRequest: Encodable {
    let sinceSeq: Int64
    let maxRows: Int

    enum CodingKeys: String, CodingKey {
        case sinceSeq = "since_seq"
        case maxRows = "max_rows"
    }
}
