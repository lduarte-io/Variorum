import Foundation

/// One `journal_entries` row as it travels (contract fact 1, full DDL
/// confirmed 2026-07-09 under their ID FREEZE): `journal_entries(id uuid
/// PK, user_id, date, body, created_at, updated_at, deleted_at,
/// server_updated_at)` — the first six are NOT NULL with no defaults, and
/// an omitted NOT NULL column on an inserting push aborts the ENTIRE call
/// (`not_null_violation`, nothing written), so pushes always send all six.
/// `updated_at` is CLIENT-stamped and is the row-LWW authority;
/// `server_updated_at` is server-stamped, µs-precision, and **opaque** —
/// the pull keyset's ordering key, stored verbatim, never
/// parsed-and-reformatted (a ms round-trip would move the cursor backwards
/// and re-deliver rows forever).
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

/// Keyset cursor over `(server_updated_at, id)` — confirmed 2026-07-09:
/// server-stamped, immune to device clocks (a cursor on `updated_at` would
/// skip rows permanently). Both components stored as the RAW server
/// strings.
public struct FragmentsPullCursor: Equatable, Sendable, Codable {
    public var serverUpdatedAt: String
    public var id: String

    public init(serverUpdatedAt: String, id: String) {
        self.serverUpdatedAt = serverUpdatedAt
        self.id = id
    }
}

/// `sync_push`'s AGGREGATE response (migration 7; corrected 2026-07-09 —
/// the per-row status/server_updated_at DTO this phase originally guessed
/// does not exist): `applied` = rows the guarded upsert wrote; `skipped` =
/// rows that lost LWW silently (or failed the resurrect guard);
/// `conflicts` = per-row refusals. You cannot tell WHICH of N rows applied
/// — so the engine pushes ONE row per call, making `applied == 1`
/// unambiguous.
public struct FragmentsPushResponse: Equatable, Sendable, Codable {
    public var applied: Int
    public var skipped: Int
    public var conflicts: [FragmentsPushConflict]

    public init(applied: Int, skipped: Int, conflicts: [FragmentsPushConflict] = []) {
        self.applied = applied
        self.skipped = skipped
        self.conflicts = conflicts
    }
}

/// One `conflicts[]` refusal. Their shipped SQL has exactly FOUR producers
/// (ask 11, completed by their 2026-07-10 FINAL reply): (1) a row missing
/// `updated_at`, (2) the `clock_ahead:` clamp, (3) `unique_violation` on
/// `(user_id, date)`, and (4) `"row carries no writable columns"` — a pushed
/// row carrying no recognized writable column for the table (their 2026-07-10
/// addition; unreachable for this bridge, which always sends all six journal
/// columns). Only (2) and (3) get special handling; (1) and (4) fall to the
/// engine's generic refused-and-surfaced branch (visible every round, never
/// destructive) — pinned in `FragmentsTransportTests`.
public struct FragmentsPushConflict: Equatable, Sendable, Codable {
    public var id: String
    public var error: String

    public init(id: String, error: String) {
        self.id = id
        self.error = error
    }

    /// The clock clamp (migration 7; `updated_at` >10 min ahead — ask 14
    /// ANSWERED): matched on the prefix. Parked and surfaced; self-heals
    /// as the wall clock catches up.
    public var isClockAhead: Bool { error.hasPrefix("clock_ahead:") }
    /// The `(user_id, date)` unique index tripped — the safety net for a
    /// MIS-DERIVED id. A derivation BUG: surfaced permanently, never
    /// retried (confirmed treatment, ask (c)).
    public var isUniqueViolation: Bool { error.contains("unique_violation") }
}

/// The transport seam for Fragments' RPC dialect (`sync_push` guarded
/// upsert / `sync_pull` keyset / `sync_delete`), reconciled 2026-07-09 to
/// their migration-7 semantics (the shipped SQL — their spec prose lags
/// it). Scope: `journal_entries`, plus ONE deliberate read of
/// `user_settings.local_user_id` (the canonical-user key — an amended
/// contract fact; never guessed).
public protocol FragmentsBridgeTransport: Sendable {
    /// Guarded upsert. The engine calls this with ONE entry per call (per
    /// day) so the aggregate counters are unambiguous.
    func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse
    /// Rows strictly after the cursor in `(server_updated_at, id)` order,
    /// at most `limit`; the ~2 s visibility horizon lives INSIDE the RPC.
    /// Tombstones ride the same stream.
    func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry]
    /// LWW-guarded soft delete (server-stamped); returns the tombstoned
    /// count. Part of the pinned dialect; the engine never calls it
    /// (QUESTIONS #14(a), ratified).
    func delete(ids: [String]) async throws -> Int
    /// `user_settings.local_user_id` — the canonical-user key for id
    /// derivation, minted by Fragments' first device, distinct from the
    /// auth uid by design. `nil` = the account has not synced from
    /// Fragments yet; the engine FAILS CLOSED on pushes until it exists.
    func fetchLocalUserID() async throws -> String?
}

// MARK: - The real RPC client (reconciled wire shapes)

/// URLSession implementation of the dialect against Fragments' Supabase
/// project. Wire shapes were CORRECTED 2026-07-09 by the Fragments agents
/// (asks 11/12/14 ANSWERED — no longer PROVISIONAL): PostgREST RPC `POST
/// /rest/v1/rpc/<fn>` with `p_`-prefixed parameter objects; `sync_push` →
/// the aggregate `{applied, skipped, conflicts}` response; `sync_pull` →
/// a BARE array of row objects ordered `(server_updated_at, id)`;
/// `sync_delete(p_table, p_ids)` → `{tombstoned}`. All three RPCs are
/// SECURITY INVOKER (their RLS applies) — the user-auth session seam is
/// the identity, never the PAT. The real pass (9c Step 6) needs
/// credentials only.
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
    /// The user-auth seam (9c absorbed): a bearer session per call;
    /// proactive refresh lives behind the provider, and a server-side 401
    /// gets ONE refresh-and-retry here (9c review round 1 — the mirror
    /// transport's door, mirrored: a token the SERVER judges stale despite
    /// looking locally fresh must not wedge bridge rounds until the local
    /// expiry margin trips, up to ~59 visible-but-failed minutes).
    public let sessionProvider: any FragmentsSessionProviding
    /// The HTTP hop, seam-injectable for the no-network suites (the same
    /// discipline as the mirror transport).
    private let load: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(
        configuration: Configuration,
        sessionProvider: any FragmentsSessionProviding,
        urlSession: URLSession = .shared
    ) {
        self.init(
            configuration: configuration,
            sessionProvider: sessionProvider,
            load: { try await urlSession.data(for: $0) })
    }

    init(
        configuration: Configuration,
        sessionProvider: any FragmentsSessionProviding,
        load: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.load = load
    }

    // MARK: FragmentsBridgeTransport

    public func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse {
        let data = try await rpc(
            "sync_push",
            body: SyncPushParams(pTable: "journal_entries", pRows: entries.map(WireEntry.init)))
        return try JSONDecoder().decode(FragmentsPushResponse.self, from: data)
    }

    public func pull(
        after cursor: FragmentsPullCursor?, limit: Int
    ) async throws -> [FragmentsEntry] {
        // First pull: epoch + zero UUID (their documented convention).
        let data = try await rpc(
            "sync_pull",
            body: SyncPullParams(
                pTable: "journal_entries",
                pAfterTs: cursor?.serverUpdatedAt ?? "1970-01-01T00:00:00Z",
                pAfterId: cursor?.id ?? "00000000-0000-0000-0000-000000000000",
                pLimit: limit))
        // A BARE JSON array of row objects — no envelope.
        return try JSONDecoder().decode([WireEntry].self, from: data).map(\.entry)
    }

    public func delete(ids: [String]) async throws -> Int {
        let data = try await rpc(
            "sync_delete",
            body: SyncDeleteParams(pTable: "journal_entries", pIds: ids))
        return try JSONDecoder().decode(SyncDeleteResponse.self, from: data).tombstoned
    }

    public func fetchLocalUserID() async throws -> String? {
        // The one deliberate read outside journal_entries (amended contract
        // fact): user_settings.local_user_id, via the same keyset RPC.
        let data = try await rpc(
            "sync_pull",
            body: SyncPullParams(
                pTable: "user_settings",
                pAfterTs: "1970-01-01T00:00:00Z",
                pAfterId: "00000000-0000-0000-0000-000000000000",
                pLimit: 10))
        let rows = try JSONDecoder().decode([UserSettingsRow].self, from: data)
        // Lowercased UUID text by their convention; defensively lowercased.
        return rows.compactMap(\.localUserId).first?.lowercased()
    }

    // MARK: HTTP plumbing

    private func rpc<Body: Encodable>(_ function: String, body: Body) async throws -> Data {
        let session = try await sessionProvider.currentSession()
        try checkExpectedUser(session)
        let payload = try JSONEncoder().encode(body)

        let (data, status) = try await send(function, payload: payload, bearer: session.accessToken)
        if status == 401 {
            // ONE refresh-and-retry (9c review round 1 — mirrors the sync
            // transport): the server judged the token stale despite the
            // provider considering it current. A refresh failure
            // propagates; a second 401 surfaces below — never a loop.
            let refreshed = try await sessionProvider.refreshedSession()
            try checkExpectedUser(refreshed)
            let (retryData, retryStatus) = try await send(
                function, payload: payload, bearer: refreshed.accessToken)
            guard (200..<300).contains(retryStatus) else {
                throw FragmentsTransportError.httpFailure(
                    status: retryStatus,
                    body: String(data: retryData, encoding: .utf8) ?? "")
            }
            return retryData
        }
        guard (200..<300).contains(status) else {
            throw FragmentsTransportError.httpFailure(
                status: status,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        return data
    }

    /// Round 2, NIT 8 (9b): a session authenticated as a different user
    /// than the bridge composes rows for is a wiring bug — refused before
    /// any request, and re-checked after a refresh.
    private func checkExpectedUser(_ session: FragmentsUserSession) throws {
        if let expected = configuration.expectedUserID, session.userID != expected {
            throw FragmentsTransportError.sessionUserMismatch(
                expected: expected, actual: session.userID)
        }
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
            throw FragmentsTransportError.notHTTP
        }
        return (data, http.statusCode)
    }
}

public enum FragmentsTransportError: Error, Equatable, Sendable {
    case notHTTP
    case httpFailure(status: Int, body: String)
    /// The authenticated session's user is not the user the bridge is
    /// configured to compose rows for (round 2, NIT 8 — a wiring bug,
    /// refused before any request composes).
    case sessionUserMismatch(expected: String, actual: String)
    case malformedResult(String)
}

// MARK: - Wire DTOs (reconciled to migration 7 — no longer PROVISIONAL)

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

/// Their `user_settings` row, decoded minimally: the bridge reads exactly
/// one column and ignores everything else.
struct UserSettingsRow: Codable {
    let localUserId: String?

    enum CodingKeys: String, CodingKey {
        case localUserId = "local_user_id"
    }
}

struct SyncPushParams: Encodable {
    let pTable: String
    let pRows: [WireEntry]

    enum CodingKeys: String, CodingKey {
        case pTable = "p_table"
        case pRows = "p_rows"
    }
}

struct SyncPullParams: Encodable {
    let pTable: String
    let pAfterTs: String
    let pAfterId: String
    let pLimit: Int

    enum CodingKeys: String, CodingKey {
        case pTable = "p_table"
        case pAfterTs = "p_after_ts"
        case pAfterId = "p_after_id"
        case pLimit = "p_limit"
    }
}

struct SyncDeleteParams: Encodable {
    let pTable: String
    let pIds: [String]

    enum CodingKeys: String, CodingKey {
        case pTable = "p_table"
        case pIds = "p_ids"
    }
}

struct SyncDeleteResponse: Codable {
    let tombstoned: Int
}
