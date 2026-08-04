import Foundation

/// The `key_vault` PostgREST client (Phase 14b, batch 3 — ledger L8).
///
/// The vault is ACCOUNT data, not row-sync data: it is reached through plain
/// authenticated PostgREST under owner-only RLS (the P-ii-verified pattern,
/// `Server/supabase/08_phase14b_lockstep.sql`) — the sync engine never
/// touches it, and `key_vault` is never a sync-mirror table. Columns map
/// 1:1 to `KeyVaultFormat`/`PassphraseKDF.Descriptor` fields (the 08 file's
/// stated contract); all key material travels as base64 TEXT.
///
/// Auth posture, exactly the transports' (9c pattern): signed-out refuses
/// BEFORE any request composes (the provider's throw propagates); an HTTP
/// 401 gets ONE refresh-and-retry; a second 401 surfaces — never a loop.
/// The row's `user_id` is always the SESSION's user (`auth.uid()` under
/// RLS) — never caller-supplied, so a wiring bug cannot compose another
/// user's vault row.
///
/// Refusals are typed and total:
///  - a vault written by a NEWER format version refuses by version
///    (`unsupportedFormatVersion` — never guess at a future format);
///  - creating over an existing row refuses (`vaultAlreadyExists` —
///    idempotence by refusal, never overwrite; the mirror's PK is the
///    backstop);
///  - updating a missing row refuses (`vaultAbsent`);
///  - updating past a row another device moved refuses
///    (`vaultRevisionConflict` — the R1-2 CAS: every update filters on the
///    `revision` fetched with the vault and writes fetched+1, so a stale
///    read-modify-write can never silently revert the row; the caller
///    refetches and re-derives, never blind-retries);
///  - undecodable rows refuse (`malformedRow`), never crash.
public actor KeyVaultClient {
    /// One fetched vault: the format PLUS the server row's `revision` — the
    /// optimistic-concurrency token every update must present (R1-2). The
    /// two travel together deliberately: an update built from a fetch
    /// carries THAT fetch's token, so a write derived from stale state is
    /// refused by the server-side filter instead of winning silently.
    public struct FetchedVault: Equatable, Sendable {
        public let format: KeyVaultFormat
        public let revision: Int

        public init(format: KeyVaultFormat, revision: Int) {
            self.format = format
            self.revision = revision
        }
    }

    public struct Configuration: Sendable {
        /// `https://<project>.supabase.co` — the Variorum project (R-1: the
        /// vault lives on the account home).
        public let projectURL: URL
        /// The publishable API key (grants nothing by itself; RLS is the
        /// guard).
        public let apiKey: String

        public init(projectURL: URL, apiKey: String) {
            self.projectURL = projectURL
            self.apiKey = apiKey
        }
    }

    public let configuration: Configuration
    public let sessionProvider: any UserSessionProviding
    /// The HTTP hop, seam-injectable for the no-network suites (the same
    /// discipline as `SupabaseTransport`).
    private let load: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    /// Single-flight fetch: concurrent reads coalesce onto one request
    /// (enrollment + a status refresh racing must not double-hit the
    /// server; both observe the same settled answer).
    private var fetchTask: Task<FetchedVault?, Error>?

    public init(
        configuration: Configuration,
        sessionProvider: any UserSessionProviding,
        urlSession: URLSession = .shared
    ) {
        self.init(
            configuration: configuration,
            sessionProvider: sessionProvider,
            load: { try await urlSession.data(for: $0) })
    }

    /// The seam-injectable form — PUBLIC deliberately (unlike the sync
    /// transport's internal seam): the App-layer flow tests script vault
    /// responses without a network and without visibility into core
    /// internals. Production never passes `load`.
    public init(
        configuration: Configuration,
        sessionProvider: any UserSessionProviding,
        load: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.load = load
    }

    // MARK: - Read

    /// The signed-in user's vault (format + revision token), or nil when
    /// none exists yet. Single-flight: concurrent callers share one request.
    public func fetchVault() async throws -> FetchedVault? {
        if let inFlight = fetchTask {
            return try await inFlight.value
        }
        let task = Task { try await self.performFetch() }
        fetchTask = task
        defer { fetchTask = nil }
        return try await task.value
    }

    private func performFetch() async throws -> FetchedVault? {
        let session = try await sessionProvider.currentSession()
        let (data, _) = try await authorizedRequest(
            method: "GET",
            path: "rest/v1/key_vault",
            query: [URLQueryItem(name: "user_id", value: "eq.\(session.userID)"),
                    URLQueryItem(name: "select", value: "*")],
            body: nil,
            prefer: nil)
        let rows: [KeyVaultWireRow]
        do {
            rows = try JSONDecoder().decode([KeyVaultWireRow].self, from: data)
        } catch {
            throw KeyVaultClientError.malformedRow(String(describing: error))
        }
        guard let row = rows.first else { return nil }
        return FetchedVault(format: try row.format(), revision: row.revision)
    }

    // MARK: - Create

    /// Insert the account's vault row. REFUSES when a row already exists
    /// (the mirror's PK turns a race into an HTTP conflict — idempotence by
    /// refusal, never overwrite: overwriting a vault would orphan every
    /// ciphertext its keys guard).
    public func createVault(_ format: KeyVaultFormat) async throws {
        let session = try await sessionProvider.currentSession()
        let row = try KeyVaultWireRow(format: format, userID: session.userID)
        let body: Data
        do {
            body = try JSONEncoder().encode(row)
        } catch {
            throw KeyVaultClientError.malformedRow(String(describing: error))
        }
        do {
            _ = try await authorizedRequest(
                method: "POST",
                path: "rest/v1/key_vault",
                query: [],
                body: body,
                prefer: "return=minimal")
        } catch KeyVaultClientError.httpFailure(let status, let responseBody) {
            // PostgREST duplicate-key = HTTP 409 (SQLSTATE 23505 in the body).
            if status == 409 { throw KeyVaultClientError.vaultAlreadyExists }
            throw KeyVaultClientError.httpFailure(status: status, body: responseBody)
        }
    }

    // MARK: - Update

    /// Replace the vault row's format fields (change-passphrase re-wraps,
    /// recovery-wrap addition/replacement) — CAS-guarded (ladder R1-2):
    /// `expectedRevision` is the token that rode the fetch this update was
    /// derived from; the PATCH filters `revision=eq.<expectedRevision>` and
    /// writes `revision = expectedRevision + 1`, so a row another device
    /// moved in the meantime matches ZERO rows and refuses typed
    /// (`vaultRevisionConflict` — refetch and re-derive, never blind-retry:
    /// the worst pre-fix arm was a stale full-row PATCH silently reverting
    /// a freshly regenerated recovery wrap to the discarded words).
    /// Refuses when no row exists (`vaultAbsent`) — an update door must
    /// never invent a vault.
    public func updateVault(_ format: KeyVaultFormat, expectedRevision: Int) async throws {
        let session = try await sessionProvider.currentSession()
        var row = try KeyVaultWireRow(format: format, userID: session.userID)
        row.revision = expectedRevision + 1
        let body: Data
        do {
            body = try JSONEncoder().encode(row)
        } catch {
            throw KeyVaultClientError.malformedRow(String(describing: error))
        }
        let (data, _) = try await authorizedRequest(
            method: "PATCH",
            path: "rest/v1/key_vault",
            query: [URLQueryItem(name: "user_id", value: "eq.\(session.userID)"),
                    URLQueryItem(name: "revision", value: "eq.\(expectedRevision)")],
            body: body,
            prefer: "return=representation")
        // `return=representation` answers with the updated rows; an empty
        // array means no row matched the filter — either the vault is
        // absent, or its revision moved under the caller. A fresh read
        // disambiguates; either answer sends the caller back to CURRENT
        // state rather than retrying the stale write.
        let rows = (try? JSONDecoder().decode([KeyVaultWireRow].self, from: data)) ?? []
        guard !rows.isEmpty else {
            if try await performFetch() == nil { throw KeyVaultClientError.vaultAbsent }
            throw KeyVaultClientError.vaultRevisionConflict
        }
    }

    // MARK: - HTTP plumbing (the transports' shape)

    private func authorizedRequest(
        method: String, path: String, query: [URLQueryItem], body: Data?, prefer: String?
    ) async throws -> (Data, Int) {
        let session = try await sessionProvider.currentSession()
        let (data, status) = try await send(
            method: method, path: path, query: query, body: body,
            prefer: prefer, bearer: session.accessToken)
        if status == 401 {
            // ONE refresh-and-retry (the 9c posture): the server judged the
            // token stale despite the provider considering it current.
            let refreshed = try await sessionProvider.refreshedSession()
            let (retryData, retryStatus) = try await send(
                method: method, path: path, query: query, body: body,
                prefer: prefer, bearer: refreshed.accessToken)
            guard (200..<300).contains(retryStatus) else {
                throw KeyVaultClientError.httpFailure(
                    status: retryStatus,
                    body: String(data: retryData, encoding: .utf8) ?? "")
            }
            return (retryData, retryStatus)
        }
        guard (200..<300).contains(status) else {
            throw KeyVaultClientError.httpFailure(
                status: status, body: String(data: data, encoding: .utf8) ?? "")
        }
        return (data, status)
    }

    private func send(
        method: String, path: String, query: [URLQueryItem], body: Data?,
        prefer: String?, bearer: String
    ) async throws -> (Data, Int) {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        if let prefer { request.setValue(prefer, forHTTPHeaderField: "Prefer") }
        request.httpBody = body

        let (data, response) = try await load(request)
        guard let http = response as? HTTPURLResponse else {
            throw KeyVaultClientError.notHTTP
        }
        return (data, http.statusCode)
    }
}

/// Typed refusals for the vault client.
public enum KeyVaultClientError: Error, Equatable, Sendable {
    case notHTTP
    case httpFailure(status: Int, body: String)
    /// A vault row already exists — creating never overwrites (an
    /// overwritten vault orphans the whole ciphertext corpus).
    case vaultAlreadyExists
    /// No vault row exists for this account (update refused; enrollment
    /// has nothing to unwrap).
    case vaultAbsent
    /// The vault row changed since it was fetched (another device wrote
    /// it): the update's `revision=eq.<fetched>` CAS filter matched zero
    /// rows (ladder R1-2). REFETCH the vault and re-derive the update from
    /// its CURRENT state — never blind-retry, never overwrite.
    case vaultRevisionConflict
    /// The stored row was written by a NEWER vault format than this build
    /// speaks — refuse by version, never guess (L8's letter).
    case unsupportedFormatVersion(Int)
    /// The row's bytes do not decode as a vault row (or a format failed to
    /// encode as one).
    case malformedRow(String)
}

// MARK: - The wire row (1:1 with 08_phase14b_lockstep.sql)

/// One `key_vault` row as PostgREST carries it. Column names mirror the
/// DDL exactly; key material is base64 TEXT. `created_at`/`updated_at` are
/// server-defaulted and read-only here (never sync ordering — display
/// bookkeeping only).
struct KeyVaultWireRow: Codable, Equatable {
    var userID: String
    var formatVersion: Int
    var kdfAlgorithm: String
    var kdfArgon2Version: Int
    var kdfMemoryKiB: Int
    var kdfIterations: Int
    var kdfParallelism: Int
    var kdfSalt: String
    var kdfOutputBytes: Int
    var masterWrappedByPassphrase: String
    var masterWrappedByRecovery: String?
    var corpusKeyID: String
    var corpusKeyWrappedByMaster: String
    var journalBridgeKeyID: String
    var journalBridgeKeyWrappedByMaster: String
    /// The CAS token (ladder R1-2; the 08 column `revision integer not
    /// null default 1`): reads carry the row's current value; updates
    /// write fetched+1 behind the `revision=eq.<fetched>` filter.
    var revision: Int = 1

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case formatVersion = "format_version"
        case kdfAlgorithm = "kdf_algorithm"
        case kdfArgon2Version = "kdf_argon2_version"
        case kdfMemoryKiB = "kdf_memory_kib"
        case kdfIterations = "kdf_iterations"
        case kdfParallelism = "kdf_parallelism"
        case kdfSalt = "kdf_salt"
        case kdfOutputBytes = "kdf_output_bytes"
        case masterWrappedByPassphrase = "master_wrapped_by_passphrase"
        case masterWrappedByRecovery = "master_wrapped_by_recovery"
        case corpusKeyID = "corpus_key_id"
        case corpusKeyWrappedByMaster = "corpus_key_wrapped_by_master"
        case journalBridgeKeyID = "journal_bridge_key_id"
        case journalBridgeKeyWrappedByMaster = "journal_bridge_key_wrapped_by_master"
        case revision = "revision"
    }

    /// Hand-written decode for exactly one reason: `revision` defaults to
    /// 1 when the key is absent (the server column's own default — and the
    /// synthesized decoder would refuse rows written before the client
    /// carried the token). Encoding stays synthesized, which preserves the
    /// Codable NIL-OMISSION of `masterWrappedByRecovery` — the accident
    /// that protected the first-generation wrap pre-R1-2 (see the
    /// enrollment tests' pinned-knowledge note).
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decode(String.self, forKey: .userID)
        formatVersion = try container.decode(Int.self, forKey: .formatVersion)
        kdfAlgorithm = try container.decode(String.self, forKey: .kdfAlgorithm)
        kdfArgon2Version = try container.decode(Int.self, forKey: .kdfArgon2Version)
        kdfMemoryKiB = try container.decode(Int.self, forKey: .kdfMemoryKiB)
        kdfIterations = try container.decode(Int.self, forKey: .kdfIterations)
        kdfParallelism = try container.decode(Int.self, forKey: .kdfParallelism)
        kdfSalt = try container.decode(String.self, forKey: .kdfSalt)
        kdfOutputBytes = try container.decode(Int.self, forKey: .kdfOutputBytes)
        masterWrappedByPassphrase = try container.decode(
            String.self, forKey: .masterWrappedByPassphrase)
        masterWrappedByRecovery = try container.decodeIfPresent(
            String.self, forKey: .masterWrappedByRecovery)
        corpusKeyID = try container.decode(String.self, forKey: .corpusKeyID)
        corpusKeyWrappedByMaster = try container.decode(
            String.self, forKey: .corpusKeyWrappedByMaster)
        journalBridgeKeyID = try container.decode(String.self, forKey: .journalBridgeKeyID)
        journalBridgeKeyWrappedByMaster = try container.decode(
            String.self, forKey: .journalBridgeKeyWrappedByMaster)
        revision = try container.decodeIfPresent(Int.self, forKey: .revision) ?? 1
    }

    /// Format → row. Refuses a format missing either v1 class key — the
    /// DDL's columns ARE the v1 class set (R-8), so a different shape has
    /// no wire form.
    init(format: KeyVaultFormat, userID: String) throws {
        guard let corpus = format.classKey(for: .corpus),
              let journal = format.classKey(for: .journalBridge)
        else {
            throw KeyVaultClientError.malformedRow(
                "vault format lacks a corpus or journal_bridge class key")
        }
        self.userID = userID
        self.formatVersion = format.formatVersion
        self.kdfAlgorithm = format.kdf.algorithm
        self.kdfArgon2Version = format.kdf.argon2Version
        self.kdfMemoryKiB = format.kdf.memoryKiB
        self.kdfIterations = format.kdf.iterations
        self.kdfParallelism = format.kdf.parallelism
        self.kdfSalt = format.kdf.salt.base64EncodedString()
        self.kdfOutputBytes = format.kdf.outputBytes
        self.masterWrappedByPassphrase = format.masterWrappedByPassphrase.base64EncodedString()
        self.masterWrappedByRecovery = format.masterWrappedByRecovery?.base64EncodedString()
        self.corpusKeyID = corpus.keyID
        self.corpusKeyWrappedByMaster = corpus.wrappedByMaster.base64EncodedString()
        self.journalBridgeKeyID = journal.keyID
        self.journalBridgeKeyWrappedByMaster = journal.wrappedByMaster.base64EncodedString()
    }

    /// Row → format. A newer `format_version` refuses HERE (the client's
    /// refuse-by-version, L8); bad base64 refuses as malformed.
    func format() throws -> KeyVaultFormat {
        guard formatVersion <= KeyVaultFormat.currentFormatVersion else {
            throw KeyVaultClientError.unsupportedFormatVersion(formatVersion)
        }
        func decode(_ value: String, field: String) throws -> Data {
            guard let data = Data(base64Encoded: value) else {
                throw KeyVaultClientError.malformedRow("\(field) is not base64")
            }
            return data
        }
        return KeyVaultFormat(
            formatVersion: formatVersion,
            kdf: PassphraseKDF.Descriptor(
                algorithm: kdfAlgorithm,
                argon2Version: kdfArgon2Version,
                memoryKiB: kdfMemoryKiB,
                iterations: kdfIterations,
                parallelism: kdfParallelism,
                salt: try decode(kdfSalt, field: "kdf_salt"),
                outputBytes: kdfOutputBytes),
            masterWrappedByPassphrase: try decode(
                masterWrappedByPassphrase, field: "master_wrapped_by_passphrase"),
            masterWrappedByRecovery: try masterWrappedByRecovery.map {
                try decode($0, field: "master_wrapped_by_recovery")
            },
            classKeys: [
                KeyVaultFormat.WrappedClassKey(
                    keyClass: .corpus,
                    keyID: corpusKeyID,
                    wrappedByMaster: try decode(
                        corpusKeyWrappedByMaster, field: "corpus_key_wrapped_by_master")),
                KeyVaultFormat.WrappedClassKey(
                    keyClass: .journalBridge,
                    keyID: journalBridgeKeyID,
                    wrappedByMaster: try decode(
                        journalBridgeKeyWrappedByMaster,
                        field: "journal_bridge_key_wrapped_by_master")),
            ])
    }
}
