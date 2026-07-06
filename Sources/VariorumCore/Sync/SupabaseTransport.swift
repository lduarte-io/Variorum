import Foundation

/// The real-server implementation of `SyncTransport` (SyncSpec §2): the two
/// RPC endpoints (`sync_push`, `sync_pull` — Server/supabase/02_sync_rpc.sql)
/// over URLSession, with the single-user token (auth hardening is Phase 14).
///
/// The engine never knows which transport it is talking to — the whole
/// correctness suite runs against the in-process fake; this type carries
/// only wire mapping and HTTP plumbing. The one integration pass against a
/// real Supabase project is the Phase 5 **author-assist gate** (account,
/// project creation, and token are hers) and stays open until she runs it.
public struct SupabaseTransport: SyncTransport {
    public struct Configuration: Sendable {
        /// `https://<project>.supabase.co`
        public let projectURL: URL
        /// The project API key (`apikey` header).
        public let apiKey: String
        /// Single-user bearer token (`Authorization` header).
        public let authToken: String

        public init(projectURL: URL, apiKey: String, authToken: String) {
            self.projectURL = projectURL
            self.apiKey = apiKey
            self.authToken = authToken
        }
    }

    public let configuration: Configuration
    private let session: URLSession

    public init(configuration: Configuration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
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

    // MARK: - HTTP plumbing

    private func rpc<Body: Encodable>(_ function: String, body: Body) async throws -> Data {
        var request = URLRequest(
            url: configuration.projectURL
                .appendingPathComponent("rest/v1/rpc")
                .appendingPathComponent(function))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(configuration.authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseTransportError.notHTTP
        }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseTransportError.httpFailure(
                status: http.statusCode,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        return data
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
