import CryptoKit
import Foundation

// VX-307 U1 — THE VAULT'S WIRE (the marker-14 `key_vault` shape,
// `Server/supabase/17_phase_vx307_vault.sql`): the PostgREST/RPC client the
// production `VaultLeaf` stands on. ADDITIVE beside today's
// `KeyVaultClient`/`KeyVaultFormat` (the Release road, byte-unchanged, until
// VX-329); nothing of today's road calls this, and this calls nothing of
// today's.
//
// The shape it speaks is the core's `AccountVault` (rules 7, 11, 12, 14, 15):
// the master under the passphrase and the words ONLY, the MODE flag, the
// current sync key, every earlier sync key under the current master, the key
// proof's hash, the last writer. Reads refuse a pre-event row (`mode` absent
// ⇒ `VaultRefusal.preLockstepRow`) and a newer format version — never guess.
//
// Auth posture: the transports' (signed-out refuses before any request
// composes; ONE 401 refresh-and-retry; the row's user_id is always the
// SESSION's user — never caller-supplied). The proof is 13y's challenge
// protocol, byte-unchanged: one nonce per call, the per-request MAC bound to
// the RPC name, the enroll road run once on an un-enrolled account, one
// fresh retry on a stale challenge. The proof travels in the BODY only.

/// One `key_vault` row as PostgREST carries it on marker 14. Columns the new
/// shape does not own (the journal-bridge pair, the Apple-held pair, the
/// rotation trio) are deliberately absent: a read ignores them, a write
/// leaves them untouched (the RPC's new body does not set them).
struct AccountVaultWireRow: Codable, Equatable {
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
    /// THE MODE FLAG — 'standard' | 'castle'. nil on a fetched row means a
    /// pre-VX307 row (refused as `preLockstepRow`); a write always carries it.
    var mode: String?
    /// Every earlier sync key: `{key_id: base64 wrap}`, each under the
    /// CURRENT master (rule 15). nil reads as empty.
    var earlierRowKeys: [String: String]?
    var keyProofHash: String?
    var revision: Int = 1
    var updatedAt: String?
    var updatedByDevice: String?
    /// WRITE-ONLY (13y memo §3): kp2′, riding a payload that installs a new
    /// `key_proof_hash`; the server lands it in Supabase Vault and never
    /// serves it back.
    var keyProofMac: String?

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
        case mode
        case earlierRowKeys = "earlier_row_keys"
        case keyProofHash = "key_proof_hash"
        case revision
        case updatedAt = "updated_at"
        case updatedByDevice = "updated_by_device"
        case keyProofMac = "key_proof_mac"
    }

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
        masterWrappedByPassphrase = try container.decode(String.self, forKey: .masterWrappedByPassphrase)
        masterWrappedByRecovery = try container.decodeIfPresent(String.self, forKey: .masterWrappedByRecovery)
        corpusKeyID = try container.decode(String.self, forKey: .corpusKeyID)
        corpusKeyWrappedByMaster = try container.decode(String.self, forKey: .corpusKeyWrappedByMaster)
        mode = try container.decodeIfPresent(String.self, forKey: .mode)
        earlierRowKeys = try container.decodeIfPresent([String: String].self, forKey: .earlierRowKeys)
        keyProofHash = try container.decodeIfPresent(String.self, forKey: .keyProofHash)
        revision = try container.decodeIfPresent(Int.self, forKey: .revision) ?? 1
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        updatedByDevice = try container.decodeIfPresent(String.self, forKey: .updatedByDevice)
        keyProofMac = nil
    }

    /// Model → row. The floor is the caller's (`AccountVaultClient`'s own,
    /// checked again on read).
    init(vault: AccountVault, userID: String) {
        self.userID = userID
        formatVersion = vault.formatVersion
        kdfAlgorithm = vault.kdf.algorithm
        kdfArgon2Version = vault.kdf.argon2Version
        kdfMemoryKiB = vault.kdf.memoryKiB
        kdfIterations = vault.kdf.iterations
        kdfParallelism = vault.kdf.parallelism
        kdfSalt = vault.kdf.salt.base64EncodedString()
        kdfOutputBytes = vault.kdf.outputBytes
        masterWrappedByPassphrase = vault.masterByPassphrase.base64EncodedString()
        masterWrappedByRecovery = vault.masterByWords.base64EncodedString()
        corpusKeyID = vault.rowKey.keyID
        corpusKeyWrappedByMaster = vault.rowKey.wrappedByMaster.base64EncodedString()
        mode = vault.mode.rawValue
        earlierRowKeys = vault.earlierRowKeys.mapValues { $0.base64EncodedString() }
        keyProofHash = vault.keyProofHash
        updatedByDevice = vault.updatedByDevice
    }

    /// Row → model. A row without `mode` is a pre-VX307 row (`preLockstepRow`
    /// — the mirror has not run 17); a newer format refuses by version; bad
    /// base64 refuses as malformed; a descriptor below the floor refuses
    /// before any derivation could run on it (the 11 3b discipline).
    func vault(floor: PassphraseKDF.Floor) throws -> AccountVault {
        guard formatVersion <= AccountVault.currentFormatVersion else {
            throw AccountVaultWireError.unsupportedFormatVersion(formatVersion)
        }
        guard let modeRaw = mode else { throw VaultRefusal.preLockstepRow }
        guard let mode = ProtectionMode(rawValue: modeRaw) else {
            throw AccountVaultWireError.malformedRow("mode '\(modeRaw)' is neither standard nor castle")
        }
        func decode(_ value: String, field: String) throws -> Data {
            guard let data = Data(base64Encoded: value) else {
                throw AccountVaultWireError.malformedRow("\(field) is not base64")
            }
            return data
        }
        guard let recovery = masterWrappedByRecovery else {
            throw AccountVaultWireError.malformedRow("a marker-14 vault row carries its words wrap (rule 14)")
        }
        guard let hash = keyProofHash else {
            throw AccountVaultWireError.malformedRow("a vault row carries its key-proof hash (the insert trigger)")
        }
        let kdf = PassphraseKDF.Descriptor(
            algorithm: kdfAlgorithm, argon2Version: kdfArgon2Version, memoryKiB: kdfMemoryKiB,
            iterations: kdfIterations, parallelism: kdfParallelism,
            salt: try decode(kdfSalt, field: "kdf_salt"), outputBytes: kdfOutputBytes)
        try kdf.validateFloor(floor)
        var earlier: [String: Data] = [:]
        for (id, wrap) in earlierRowKeys ?? [:] {
            earlier[id] = try decode(wrap, field: "earlier_row_keys[\(id)]")
        }
        return AccountVault(
            formatVersion: formatVersion, kdf: kdf,
            masterByPassphrase: try decode(masterWrappedByPassphrase, field: "master_wrapped_by_passphrase"),
            masterByWords: try decode(recovery, field: "master_wrapped_by_recovery"),
            mode: mode,
            rowKey: VaultKey(
                keyID: corpusKeyID,
                wrappedByMaster: try decode(corpusKeyWrappedByMaster, field: "corpus_key_wrapped_by_master")),
            earlierRowKeys: earlier, keyProofHash: hash, updatedByDevice: updatedByDevice)
    }
}

/// Wire refusals that are not the vault's typed `VaultRefusal` family.
public enum AccountVaultWireError: Error, Equatable, Sendable {
    case notHTTP
    case httpFailure(status: Int, body: String)
    case unsupportedFormatVersion(Int)
    case malformedRow(String)
    /// The challenge was unknown, consumed or expired twice (one fresh
    /// retry already ran) — retry the act.
    case challengeStale
}

/// The marker-14 vault client. An actor (single-flight fetch, the transports'
/// discipline); the HTTP hop is seam-injectable so the fake server's RPC
/// emulation runs without a network.
public actor AccountVaultClient {
    public struct Configuration: Sendable {
        public let projectURL: URL
        public let apiKey: String
        /// Decision 34: every vault write names THIS device, by name.
        public let deviceName: String
        public let floor: PassphraseKDF.Floor

        public init(
            projectURL: URL, apiKey: String, deviceName: String, floor: PassphraseKDF.Floor = PassphraseKDF.floor
        ) {
            self.projectURL = projectURL
            self.apiKey = apiKey
            self.deviceName = deviceName
            self.floor = floor
        }
    }

    public let configuration: Configuration
    let sessionProvider: any UserSessionProviding
    private let load: @Sendable (URLRequest) async throws -> (Data, URLResponse)
    private var fetchTask: Task<VaultSnapshot?, Error>?

    public init(
        configuration: Configuration, sessionProvider: any UserSessionProviding,
        urlSession: URLSession = .shared
    ) {
        self.init(
            configuration: configuration, sessionProvider: sessionProvider,
            load: { try await urlSession.data(for: $0) })
    }

    /// The seam-injectable form — public so the fake server's HTTP emulation
    /// (tests) scripts responses without a network. Production never passes
    /// `load`.
    public init(
        configuration: Configuration, sessionProvider: any UserSessionProviding,
        load: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.configuration = configuration
        self.sessionProvider = sessionProvider
        self.load = load
    }

    // MARK: - The leaf's three calls

    /// The signed-in account's vault, or nil when none exists yet. Refuses
    /// when `accountID` is not the session's user (`notSignedIn` — the
    /// executor's own `requireSignedIn` is the belt above this).
    public func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        if let inFlight = fetchTask { return try await inFlight.value }
        let task = Task { try await self.performFetch(accountID: accountID) }
        fetchTask = task
        defer { fetchTask = nil }
        return try await task.value
    }

    private func performFetch(accountID: String) async throws -> VaultSnapshot? {
        let session = try await signedInSession(as: accountID)
        let (data, _) = try await authorizedRequest(
            method: "GET", path: "rest/v1/key_vault",
            query: [URLQueryItem(name: "user_id", value: "eq.\(session.userID)"),
                    URLQueryItem(name: "select", value: "*")],
            body: nil, prefer: nil)
        let rows: [AccountVaultWireRow]
        do {
            rows = try JSONDecoder().decode([AccountVaultWireRow].self, from: data)
        } catch {
            throw AccountVaultWireError.malformedRow(String(describing: error))
        }
        guard let row = rows.first else { return nil }
        return VaultSnapshot(
            accountID: session.userID, revision: row.revision,
            vault: try row.vault(floor: configuration.floor), updatedAt: Self.day(row.updatedAt))
    }

    /// Create the account's vault (sync setup, the first device). The row
    /// lands with its key-proof hash (the insert trigger refuses one
    /// without); creating over an existing row refuses (`vaultExists`).
    public func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        let session = try await signedInSession(as: accountID)
        var row = AccountVaultWireRow(vault: vault, userID: session.userID)
        row.updatedByDevice = device
        let body: Data
        do {
            body = try JSONEncoder().encode(row)
        } catch {
            throw AccountVaultWireError.malformedRow(String(describing: error))
        }
        let data: Data
        do {
            (data, _) = try await authorizedRequest(
                method: "POST", path: "rest/v1/key_vault", query: [],
                body: body, prefer: "return=representation")
        } catch AccountVaultWireError.httpFailure(let status, let responseBody) {
            if status == 409 { throw VaultRefusal.vaultExists }
            if responseBody.contains(SyncServerRefusalMarker.keyProofRequired) { throw VaultRefusal.keyProofRefused }
            throw AccountVaultWireError.httpFailure(status: status, body: responseBody)
        }
        let rows = (try? JSONDecoder().decode([AccountVaultWireRow].self, from: data)) ?? []
        return VaultSnapshot(
            accountID: session.userID, revision: rows.first?.revision ?? 1, vault: vault,
            updatedAt: Self.day(rows.first?.updatedAt))
    }

    /// The ONE write after creation — `key_vault_update` under the
    /// challenge-verified proof (13y, byte-unchanged) and the revision CAS.
    /// `successorMaster` rides as `key_proof_mac` (kp2′) whenever the write
    /// installs a new hash (entering Castle); the enroll road runs once on
    /// an un-enrolled account; a stale challenge earns one fresh retry.
    public func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
        let session = try await signedInSession(as: accountID)
        var row = AccountVaultWireRow(vault: vault, userID: session.userID)
        row.updatedByDevice = device
        row.keyProofMac = successorMaster.map { KeyProofMaterial(master: $0).macKeyWire }
        let material = KeyProofMaterial(master: proofMaster)
        do {
            return try await sendUpdate(row, vault: vault, expectedRevision: expectedRevision, material: material)
        } catch AccountVaultWireError.challengeStale {
            return try await sendUpdate(row, vault: vault, expectedRevision: expectedRevision, material: material)
        } catch WireEnrollRequired.required {
            // The enroll fence's comparand is the CURRENT row's corpus key id
            // — read, never guessed from the payload (a Castle entry's
            // payload carries the NEW id).
            guard let current = try await performFetch(accountID: accountID) else { throw VaultRefusal.vaultAbsent }
            try await enroll(material, activeKeyID: current.rowKeyID)
            // Enrollment moved the stored hash to SHA-256(kp2): a payload
            // whose hash is the SAME master's pre-enroll (v1) form follows it
            // — and ONLY that case: any other differing hash is a master
            // change that must carry its secret (`successorMaster`), and
            // overwriting it here would mask the server's together-rule.
            if successorMaster == nil, row.keyProofHash == KeyProof.hash(master: proofMaster) {
                row.keyProofHash = KeyProof.macHash(master: proofMaster)
            }
            return try await sendUpdate(row, vault: vault, expectedRevision: expectedRevision, material: material)
        }
    }

    // MARK: - The RPC plumbing

    private enum WireEnrollRequired: Error { case required }

    private func sendUpdate(
        _ row: AccountVaultWireRow, vault: AccountVault, expectedRevision: Int, material: KeyProofMaterial
    ) async throws -> VaultSnapshot {
        struct Request: Encodable {
            let payload: AccountVaultWireRow
            let expectedRevision: Int
            let keyProof: String
            let challenge: String
            enum CodingKeys: String, CodingKey {
                case payload
                case expectedRevision = "expected_revision"
                case keyProof = "key_proof"
                case challenge
            }
        }
        let proof = material.proof(challenge: try await fetchChallenge(), rpc: "key_vault_update")
        let body: Data
        do {
            body = try JSONEncoder().encode(
                Request(payload: row, expectedRevision: expectedRevision, keyProof: proof.proof, challenge: proof.challenge))
        } catch {
            throw AccountVaultWireError.malformedRow(String(describing: error))
        }
        let data: Data
        do {
            (data, _) = try await authorizedRequest(
                method: "POST", path: "rest/v1/rpc/key_vault_update", query: [], body: body, prefer: nil)
        } catch AccountVaultWireError.httpFailure(let status, let responseBody) {
            throw Self.classified(status: status, body: responseBody)
        }
        struct Receipt: Decodable { let revision: Int }
        guard let receipt = try? JSONDecoder().decode(Receipt.self, from: data) else {
            throw AccountVaultWireError.malformedRow("key_vault_update returned no receipt")
        }
        return VaultSnapshot(accountID: row.userID, revision: receipt.revision, vault: vault, updatedAt: nil)
    }

    private func fetchChallenge() async throws -> String {
        struct Request: Encodable { let n: Int }
        let data: Data
        do {
            (data, _) = try await authorizedRequest(
                method: "POST", path: "rest/v1/rpc/sync_challenge", query: [],
                body: try JSONEncoder().encode(Request(n: 1)), prefer: nil)
        } catch AccountVaultWireError.httpFailure(let status, let responseBody) {
            throw Self.classified(status: status, body: responseBody)
        }
        guard let nonce = try? JSONDecoder().decode([String].self, from: data).first else {
            throw AccountVaultWireError.malformedRow("sync_challenge returned no nonce")
        }
        return nonce
    }

    /// `key_proof_enroll(kp1, kp2, active_key_id)` — the racing loser's
    /// ALREADY_ENROLLED counts as success (its kp2 is the same value).
    private func enroll(_ material: KeyProofMaterial, activeKeyID: String) async throws {
        struct Request: Encodable {
            let kp1: String
            let kp2: String
            let activeKeyID: String
            enum CodingKeys: String, CodingKey {
                case kp1, kp2
                case activeKeyID = "active_key_id"
            }
        }
        do {
            _ = try await authorizedRequest(
                method: "POST", path: "rest/v1/rpc/key_proof_enroll", query: [],
                body: try JSONEncoder().encode(Request(
                    kp1: material.legacyWireToken, kp2: material.macKeyWire, activeKeyID: activeKeyID)),
                prefer: nil)
        } catch AccountVaultWireError.httpFailure(let status, let responseBody) {
            if responseBody.contains(SyncServerRefusalMarker.keyProofAlreadyEnrolled) { return }
            throw Self.classified(status: status, body: responseBody)
        }
    }

    /// The typed refusals, classified by marker (tokens, never sentences).
    /// ALREADY_ENROLLED is checked before ENROLL (the belt).
    static func classified(status: Int, body: String) -> Error {
        if body.contains(SyncServerRefusalMarker.vaultAbsent) { return VaultRefusal.vaultAbsent }
        if body.contains(SyncServerRefusalMarker.vaultRevisionConflict) { return VaultRefusal.revisionConflict }
        if body.contains(SyncServerRefusalMarker.keyProofAlreadyEnrolled) { return VaultRefusal.keyProofRefused }
        if body.contains(SyncServerRefusalMarker.keyProofEnroll) { return WireEnrollRequired.required }
        if body.contains(SyncServerRefusalMarker.keyProofStaleChallenge) { return AccountVaultWireError.challengeStale }
        if body.contains(SyncServerRefusalMarker.keyProofRequired) { return VaultRefusal.keyProofRefused }
        if body.contains("VARIORUM_PRE_VX307_PAYLOAD") { return VaultRefusal.preLockstepRow }
        return AccountVaultWireError.httpFailure(status: status, body: body)
    }

    // MARK: - HTTP (the transports' shape: one 401 refresh-and-retry; a
    // transport error reads as unreachable — nothing was read or written)

    private func signedInSession(as accountID: String) async throws -> UserSession {
        let session: UserSession
        do {
            session = try await sessionProvider.currentSession()
        } catch {
            throw VaultRefusal.notSignedIn
        }
        guard session.userID == accountID else { throw VaultRefusal.notSignedIn }
        return session
    }

    private func authorizedRequest(
        method: String, path: String, query: [URLQueryItem], body: Data?, prefer: String?
    ) async throws -> (Data, Int) {
        let session = try await sessionProvider.currentSession()
        let (data, status) = try await send(
            method: method, path: path, query: query, body: body, prefer: prefer, bearer: session.accessToken)
        if status == 401 {
            let refreshed = try await sessionProvider.refreshedSession()
            let (retryData, retryStatus) = try await send(
                method: method, path: path, query: query, body: body, prefer: prefer, bearer: refreshed.accessToken)
            guard (200..<300).contains(retryStatus) else {
                if retryStatus == 401 { throw VaultRefusal.notSignedIn }
                throw AccountVaultWireError.httpFailure(
                    status: retryStatus, body: String(data: retryData, encoding: .utf8) ?? "")
            }
            return (retryData, retryStatus)
        }
        guard (200..<300).contains(status) else {
            throw AccountVaultWireError.httpFailure(status: status, body: String(data: data, encoding: .utf8) ?? "")
        }
        return (data, status)
    }

    private func send(
        method: String, path: String, query: [URLQueryItem], body: Data?, prefer: String?, bearer: String
    ) async throws -> (Data, Int) {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        if let prefer { request.setValue(prefer, forHTTPHeaderField: "Prefer") }
        request.httpBody = body
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await load(request)
        } catch is URLError {
            // The network: nothing was read or written (the executor rolls
            // an act back on it).
            throw VaultRefusal.unreachable
        }
        guard let http = response as? HTTPURLResponse else { throw AccountVaultWireError.notHTTP }
        return (data, http.statusCode)
    }

    /// `updated_at` as a day (display only — VX-113's notice names it).
    static func day(_ stamp: String?) -> Date? {
        guard let stamp else { return nil }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: stamp) { return date }
        return ISO8601DateFormatter().date(from: stamp)
    }
}
