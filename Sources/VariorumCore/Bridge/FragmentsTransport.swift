import Foundation

/// One `journal_entries` row as it travels (contract fact 1):
/// `journal_entries(id uuid PK, user_id, date, body text, created_at,
/// updated_at, deleted_at, server_updated_at)`. `updated_at` is
/// CLIENT-stamped and is the row-LWW authority on the Fragments side;
/// `server_updated_at` is server-stamped and is the pull keyset's ordering
/// key — nil on client-composed pushes.
public struct FragmentsEntry: Equatable, Sendable {
    public var id: String
    public var userID: String
    public var date: String
    public var body: String
    public var createdAt: String
    public var updatedAt: String
    public var deletedAt: String?
    public var serverUpdatedAt: String?

    public init(
        id: String, userID: String, date: String, body: String,
        createdAt: String, updatedAt: String,
        deletedAt: String? = nil, serverUpdatedAt: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.date = date
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.serverUpdatedAt = serverUpdatedAt
    }

    public var isTombstoned: Bool { deletedAt != nil }
}

/// Keyset cursor over `(server_updated_at, id)` — the pull ordering the
/// Fragments post-mortem records for their `sync_pull`.
public struct FragmentsPullCursor: Equatable, Sendable, Codable {
    public var serverUpdatedAt: String
    public var id: String

    public init(serverUpdatedAt: String, id: String) {
        self.serverUpdatedAt = serverUpdatedAt
        self.id = id
    }
}

/// Per-entry push verdict. Fragments' `sync_push` is a guarded upsert under
/// row-LWW: `.applied` means the row was written; `.stale` means the server
/// row's `updated_at` is not older — nothing was written, and the pull
/// reconciles; `.rejected` is their guard machinery (clock-ahead clamp,
/// constraint violation) — the bridge records nothing and retries later.
public enum FragmentsPushOutcome: Equatable, Sendable {
    case applied(serverUpdatedAt: String)
    case stale
    case rejected(reason: String)
}

/// The transport seam for Fragments' RPC dialect (`sync_push` guarded upsert
/// / `sync_pull` keyset / `sync_delete`), `journal_entries` only. The fake
/// test server and the real RPC client are the two implementations; the
/// engine never knows which it holds.
public protocol FragmentsBridgeTransport: Sendable {
    /// Guarded upsert; results index-aligned with the batch.
    func push(_ entries: [FragmentsEntry]) async throws -> [FragmentsPushOutcome]
    /// Rows strictly after the cursor in `(server_updated_at, id)` order,
    /// at most `limit`, honoring the server-side ~2 s visibility horizon.
    func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry]
    /// LWW-guarded tombstone. Part of the pinned dialect; the Phase 9b
    /// engine never calls it (Variorum-side deletions deliberately do not
    /// propagate — QUESTIONS record).
    func delete(ids: [String], deletedAt: String) async throws -> [FragmentsPushOutcome]
}

// MARK: - The real RPC client (wire shapes PROVISIONAL)

/// URLSession implementation of the dialect against Fragments' Supabase
/// project.
///
/// **PROVISIONAL (Phase 9b):** the contract pins the RPC NAMES and semantics
/// but not their JSON shapes; the DTOs below are this plan's documented
/// reading (snake_case keys mirroring the table's column names, Supabase
/// `rest/v1/rpc/<fn>` POST convention), pinned by no-network tests and
/// carried as a contract ask for the author's Fragments agents to confirm or
/// correct. The (deferred, post-9c) real-project pass is the reconciliation
/// point — nothing automated ever touches the real project.
public struct FragmentsRPCTransport: FragmentsBridgeTransport {
    public struct Configuration: Sendable {
        /// `https://<fragments-project>.supabase.co`
        public let projectURL: URL
        /// The Fragments project's publishable API key (`apikey` header —
        /// grants nothing by itself; their RLS is the guard).
        public let apiKey: String
        /// When set, every call cross-checks the session's authenticated
        /// user against this id and refuses on mismatch (review round 2,
        /// NIT 8): a 9c wiring bug composing rows as one user while
        /// authenticated as another would otherwise leave their RLS as the
        /// only guard. 9c passes the bridge configuration's `userID`.
        public let expectedUserID: String?

        public init(projectURL: URL, apiKey: String, expectedUserID: String? = nil) {
            self.projectURL = projectURL
            self.apiKey = apiKey
            self.expectedUserID = expectedUserID
        }
    }

    public let configuration: Configuration
    /// The user-auth seam (9c absorbs): a bearer session per call, so token
    /// refresh lives behind the provider, never here.
    public let sessionProvider: any FragmentsSessionProviding
    private let urlSession: URLSession

    public init(
        configuration: Configuration,
        sessionProvider: any FragmentsSessionProviding,
        urlSession: URLSession = .shared
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.urlSession = urlSession
    }

    // MARK: FragmentsBridgeTransport

    public func push(_ entries: [FragmentsEntry]) async throws -> [FragmentsPushOutcome] {
        let data = try await rpc(
            "sync_push",
            body: FragmentsPushRequest(table: "journal_entries", entries: entries.map(WireEntry.init)))
        let results = try JSONDecoder().decode([WirePushResult].self, from: data)
        guard results.count == entries.count else {
            throw FragmentsTransportError.mismatchedResultCount(
                pushed: entries.count, returned: results.count)
        }
        return try results.map { try $0.outcome() }
    }

    public func pull(
        after cursor: FragmentsPullCursor?, limit: Int
    ) async throws -> [FragmentsEntry] {
        let data = try await rpc(
            "sync_pull",
            body: FragmentsPullRequest(
                table: "journal_entries",
                afterUpdatedAt: cursor?.serverUpdatedAt,
                afterID: cursor?.id,
                limit: limit))
        return try JSONDecoder().decode([WireEntry].self, from: data).map(\.entry)
    }

    public func delete(ids: [String], deletedAt: String) async throws -> [FragmentsPushOutcome] {
        let data = try await rpc(
            "sync_delete",
            body: FragmentsDeleteRequest(table: "journal_entries", ids: ids, deletedAt: deletedAt))
        let results = try JSONDecoder().decode([WirePushResult].self, from: data)
        guard results.count == ids.count else {
            throw FragmentsTransportError.mismatchedResultCount(
                pushed: ids.count, returned: results.count)
        }
        return try results.map { try $0.outcome() }
    }

    // MARK: HTTP plumbing

    private func rpc<Body: Encodable>(_ function: String, body: Body) async throws -> Data {
        let session = try await sessionProvider.currentSession()
        if let expected = configuration.expectedUserID, session.userID != expected {
            throw FragmentsTransportError.sessionUserMismatch(
                expected: expected, actual: session.userID)
        }
        var request = URLRequest(
            url: configuration.projectURL
                .appendingPathComponent("rest/v1/rpc")
                .appendingPathComponent(function))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw FragmentsTransportError.notHTTP
        }
        guard (200..<300).contains(http.statusCode) else {
            throw FragmentsTransportError.httpFailure(
                status: http.statusCode,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        return data
    }
}

public enum FragmentsTransportError: Error, Equatable, Sendable {
    case notHTTP
    /// The authenticated session's user is not the user the bridge is
    /// configured to compose rows for (round 2, NIT 8 — a wiring bug,
    /// refused before any request composes).
    case sessionUserMismatch(expected: String, actual: String)
    case httpFailure(status: Int, body: String)
    case mismatchedResultCount(pushed: Int, returned: Int)
    case malformedResult(String)
}

// MARK: - Wire DTOs (PROVISIONAL shapes; contract ask filed)

struct WireEntry: Codable {
    let id: String
    let userID: String
    let date: String
    let body: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let serverUpdatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case date
        case body
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case serverUpdatedAt = "server_updated_at"
    }

    init(entry: FragmentsEntry) {
        id = entry.id
        userID = entry.userID
        date = entry.date
        body = entry.body
        createdAt = entry.createdAt
        updatedAt = entry.updatedAt
        deletedAt = entry.deletedAt
        serverUpdatedAt = entry.serverUpdatedAt
    }

    var entry: FragmentsEntry {
        FragmentsEntry(
            id: id, userID: userID, date: date, body: body,
            createdAt: createdAt, updatedAt: updatedAt,
            deletedAt: deletedAt, serverUpdatedAt: serverUpdatedAt)
    }
}

struct FragmentsPushRequest: Encodable {
    let table: String
    let entries: [WireEntry]
}

struct FragmentsPullRequest: Encodable {
    let table: String
    let afterUpdatedAt: String?
    let afterID: String?
    let limit: Int

    enum CodingKeys: String, CodingKey {
        case table
        case afterUpdatedAt = "after_updated_at"
        case afterID = "after_id"
        case limit
    }
}

struct FragmentsDeleteRequest: Encodable {
    let table: String
    let ids: [String]
    let deletedAt: String

    enum CodingKeys: String, CodingKey {
        case table
        case ids
        case deletedAt = "deleted_at"
    }
}

struct WirePushResult: Codable {
    let status: String
    let serverUpdatedAt: String?
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case status
        case serverUpdatedAt = "server_updated_at"
        case reason
    }

    func outcome() throws -> FragmentsPushOutcome {
        switch status {
        case "applied":
            guard let serverUpdatedAt else {
                throw FragmentsTransportError.malformedResult("applied without server_updated_at")
            }
            return .applied(serverUpdatedAt: serverUpdatedAt)
        case "stale":
            return .stale
        case "rejected":
            return .rejected(reason: reason ?? "unspecified")
        default:
            throw FragmentsTransportError.malformedResult("unknown status '\(status)'")
        }
    }
}
