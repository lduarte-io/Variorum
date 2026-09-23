import Foundation

/// Phase 14c batch 2 (THE DESIGN items 3–4) — the account lifecycle seam:
/// the two server doors the re-key and deletion brains act through, plus
/// the entitlement read the deletion door's subscription warning consults.
///
/// A SEPARATE protocol from `SyncTransport`, deliberately: the sync
/// transport is the engine's per-round seam with fourteen conformers
/// across the suites, and the account acts are one-shot lifecycle
/// operations — folding them into `SyncTransport` would force every fake
/// and recording wrapper in the harness to take a stance on doors they
/// never exercise. Fakes conform HERE instead (the harness's lifecycle
/// fake bridges to `FakeSyncServer.truncateAccount`/`purgeAccount`).
public protocol AccountLifecycleProviding: Sendable {
    /// CF-8's truncate (09's `account_data_truncate`): delete the CALLING
    /// account's rows across the 18 data tables — never `key_vault`,
    /// never `entitlement`, never `sync_meta`. `activeKeyID` is the
    /// vault-key-id fence's comparand: the server refuses unless it
    /// matches the account's CURRENT `key_vault` row, which is what makes
    /// the re-key order (new vault FIRST) enforceable — a stale device
    /// cannot empty the account. Returns per-table deleted counts.
    ///
    /// `keyProof` (pre-13x decision 12; PER-REQUEST since 13y UNIT B): the
    /// right `activeKeyID` WITHOUT the proof deletes nothing — the
    /// server's gate checks the fence, then the challenge-verified proof
    /// (`SyncError.keyProofRefused` on refusal), then the 10-minute
    /// re-auth window (`SyncError.reauthRequired`). Takes the MATERIAL:
    /// the conformance owns the challenge dance.
    func truncateAccountData(activeKeyID: String, keyProof: KeyProofMaterial) async throws -> [String: Int]

    /// The deletion door's purge (09's `account_purge`, her Round-5
    /// ruling): the account's data rows + its `key_vault` row + its
    /// entitlement rows + the auth user itself. Local copies survive by
    /// construction — the server never reaches a device.
    func purgeAccount() async throws -> AccountPurgeReport

    /// The account's entitlement rows (plain authenticated PostgREST on
    /// `entitlement` — the P-ii pattern). Batch 2 uses this for the
    /// deletion door's subscription warning; batch 3's tier UX (L7) is
    /// the reader's real home and may promote it.
    func fetchEntitlements() async throws -> [AccountEntitlement]
}

/// What `account_purge` reports back (jsonb keys 1:1 with 09's body).
public struct AccountPurgeReport: Equatable, Sendable, Codable {
    public var dataRows: Int
    public var vaultRows: Int
    public var entitlementRows: Int
    public var authUserRemoved: Bool

    enum CodingKeys: String, CodingKey {
        case dataRows = "data_rows"
        case vaultRows = "vault_rows"
        case entitlementRows = "entitlement_rows"
        case authUserRemoved = "auth_user_removed"
    }

    public init(dataRows: Int, vaultRows: Int, entitlementRows: Int, authUserRemoved: Bool) {
        self.dataRows = dataRows
        self.vaultRows = vaultRows
        self.entitlementRows = entitlementRows
        self.authUserRemoved = authUserRemoved
    }
}

/// One `entitlement` row as the apps read it (owner-only SELECT policy).
public struct AccountEntitlement: Equatable, Sendable, Codable {
    public var feature: String
    /// ISO timestamp text, nil = non-expiring (the 09 column's letter).
    public var expiresAt: String?
    public var source: String?

    enum CodingKeys: String, CodingKey {
        case feature
        case expiresAt = "expires_at"
        case source
    }

    public init(feature: String, expiresAt: String? = nil, source: String? = nil) {
        self.feature = feature
        self.expiresAt = expiresAt
        self.source = source
    }
}

/// The production conformance: the two RPCs + the entitlement read over
/// URLSession, authenticated per call through `UserSessionProviding` —
/// the `SupabaseTransport` posture exactly (signed-out refuses before any
/// request composes; ONE 401 refresh-and-retry; refusal bodies classified
/// by marker token, so a fence refusal surfaces as the typed
/// `SyncError.encryptionKeysReplaced` the app already presents as CF-16).
public struct AccountLifecycleClient: AccountLifecycleProviding {
    public let configuration: SupabaseTransport.Configuration
    public let sessionProvider: any UserSessionProviding
    /// The HTTP hop, seam-injectable for the no-network suites.
    private let load: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(
        configuration: SupabaseTransport.Configuration,
        sessionProvider: any UserSessionProviding,
        session: URLSession = .shared
    ) {
        self.init(
            configuration: configuration,
            sessionProvider: sessionProvider,
            load: { try await session.data(for: $0) })
    }

    /// The seam-injectable form — PUBLIC like `KeyVaultClient`'s: the
    /// App-layer tests script responses through public API only.
    public init(
        configuration: SupabaseTransport.Configuration,
        sessionProvider: any UserSessionProviding,
        load: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.load = load
    }

    // MARK: - AccountLifecycleProviding

    public func truncateAccountData(activeKeyID: String, keyProof: KeyProofMaterial) async throws -> [String: Int] {
        // THE CHALLENGE DANCE (13y UNIT B): one nonce bound to this door;
        // a stale challenge fetches fresh and retries ONCE. Deliberately
        // NO enroll road here — the truncate runs mid-re-key on an
        // account whose vault write (the rotation's) already enrolled or
        // rotated the secret; an un-enrolled refusal surfaces typed.
        do {
            return try await sendTruncate(activeKeyID: activeKeyID, proof:
                keyProof.proof(challenge: try await fetchChallenge(), rpc: "account_data_truncate"))
        } catch SyncError.keyProofChallengeStale {
            return try await sendTruncate(activeKeyID: activeKeyID, proof:
                keyProof.proof(challenge: try await fetchChallenge(), rpc: "account_data_truncate"))
        }
    }

    private func sendTruncate(activeKeyID: String, proof: SyncKeyProof) async throws -> [String: Int] {
        struct Request: Encodable {
            let activeKeyID: String
            /// pre-13x: the key proof, a BODY parameter only.
            let keyProof: String
            /// 13y UNIT B: the single-use nonce the proof consumed.
            let challenge: String
            enum CodingKeys: String, CodingKey {
                case activeKeyID = "active_key_id"
                case keyProof = "key_proof"
                case challenge
            }
        }
        let data = try await send(
            method: "POST", path: "rest/v1/rpc/account_data_truncate",
            query: [],
            body: try JSONEncoder().encode(Request(
                activeKeyID: activeKeyID, keyProof: proof.proof, challenge: proof.challenge)))
        do {
            return try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            throw AccountLifecycleError.malformedResult(String(describing: error))
        }
    }

    /// One nonce off `sync_challenge(1)` — the lifecycle door's own road.
    private func fetchChallenge() async throws -> String {
        struct Request: Encodable { let n: Int }
        let data = try await send(
            method: "POST", path: "rest/v1/rpc/sync_challenge",
            query: [], body: try JSONEncoder().encode(Request(n: 1)))
        guard let nonce = try? JSONDecoder().decode([String].self, from: data).first else {
            throw AccountLifecycleError.malformedResult("sync_challenge returned no nonce")
        }
        return nonce
    }

    public func purgeAccount() async throws -> AccountPurgeReport {
        let data = try await send(
            method: "POST", path: "rest/v1/rpc/account_purge",
            query: [], body: Data("{}".utf8))
        do {
            return try JSONDecoder().decode(AccountPurgeReport.self, from: data)
        } catch {
            throw AccountLifecycleError.malformedResult(String(describing: error))
        }
    }

    public func fetchEntitlements() async throws -> [AccountEntitlement] {
        let session = try await sessionProvider.currentSession()
        let data = try await send(
            method: "GET", path: "rest/v1/entitlement",
            query: [
                URLQueryItem(name: "user_id", value: "eq.\(session.userID)"),
                URLQueryItem(name: "select", value: "feature,expires_at,source"),
            ],
            body: nil)
        do {
            return try JSONDecoder().decode([AccountEntitlement].self, from: data)
        } catch {
            throw AccountLifecycleError.malformedResult(String(describing: error))
        }
    }

    // MARK: - HTTP plumbing (the transports' shape)

    private func send(
        method: String, path: String, query: [URLQueryItem], body: Data?
    ) async throws -> Data {
        // Signed-out refuses BEFORE any request composes (the 9c posture).
        let session = try await sessionProvider.currentSession()
        let (data, status) = try await hop(
            method: method, path: path, query: query, body: body,
            bearer: session.accessToken)
        if status == 401 {
            // ONE refresh-and-retry; a second 401 surfaces — never a loop.
            let refreshed = try await sessionProvider.refreshedSession()
            let (retryData, retryStatus) = try await hop(
                method: method, path: path, query: query, body: body,
                bearer: refreshed.accessToken)
            guard (200..<300).contains(retryStatus) else {
                throw Self.classified(status: retryStatus, body: retryData)
            }
            return retryData
        }
        guard (200..<300).contains(status) else {
            throw Self.classified(status: status, body: data)
        }
        return data
    }

    /// The fence marker classifies exactly as at the sync transport — one
    /// state (CF-16's replaced keys), whichever door refused.
    private static func classified(status: Int, body: Data) -> any Error {
        let text = String(data: body, encoding: .utf8) ?? ""
        if text.contains(SyncServerRefusalMarker.staleKeyFence) {
            return SyncError.encryptionKeysReplaced
        }
        // 13y UNIT B: the challenge protocol's + the re-auth door's typed
        // refusals (ALREADY_ENROLLED before ENROLL — the belt).
        if text.contains(SyncServerRefusalMarker.keyProofAlreadyEnrolled) {
            return SyncError.keyProofAlreadyEnrolled
        }
        if text.contains(SyncServerRefusalMarker.keyProofEnroll) {
            return SyncError.keyProofEnrollRequired
        }
        if text.contains(SyncServerRefusalMarker.keyProofStaleChallenge) {
            return SyncError.keyProofChallengeStale
        }
        if text.contains(SyncServerRefusalMarker.reauthRequired) {
            return SyncError.reauthRequired
        }
        if text.contains(SyncServerRefusalMarker.keyProofRequired) {
            return SyncError.keyProofRefused
        }
        return AccountLifecycleError.httpFailure(status: status, body: text)
    }

    private func hop(
        method: String, path: String, query: [URLQueryItem], body: Data?, bearer: String
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
        request.httpBody = body
        let (data, response) = try await load(request)
        guard let http = response as? HTTPURLResponse else {
            throw AccountLifecycleError.notHTTP
        }
        return (data, http.statusCode)
    }
}

public enum AccountLifecycleError: Error, Equatable, Sendable {
    case notHTTP
    case httpFailure(status: Int, body: String)
    case malformedResult(String)
}
