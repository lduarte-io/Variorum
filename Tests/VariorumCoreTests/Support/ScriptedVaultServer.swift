import Foundation
@testable import VariorumCore

/// A scripted PostgREST responder for `key_vault` (Phase 14b batch 3): the
/// no-network test double the vault client and the enrollment flows script
/// against (the vault-bootstrap runner did too, until its deletion at VX-329's
/// ladder round 1). Models exactly what the
/// deployed table does — one row per user, PK refusal on duplicate insert
/// — plus the auth arms (401 on a wrong bearer, for the refresh-and-retry
/// pin). Never a network socket.
///
/// PRE-13X BATCH 1B (11_pre13x_postures.sql): the vault's table-level
/// write road is CLOSED and the ONE write after creation is the
/// `key_vault_update` RPC. This double is LINKED to a `FakeSyncServer` —
/// the RPC's gates (the proof, the NULL-hash arm, the revision CAS, the
/// rotation seq, decision 32's refusal) run on ITS vault row, so exactly
/// ONE emulation of the RPC exists and the row the sync RPCs fence on IS
/// the row the vault client writes (the one-Postgres wiring). What this
/// double models on top:
///  - **PATCH is `permission denied`** (42501) — the closed road: a bare
///    session's direct write is refused whatever it carries;
///  - **a POST without `key_proof_hash` is refused** with the marker — the
///    `BEFORE INSERT` trigger's twin;
///  - **a POST provisions the linked account** (the vault row's corpus key
///    id + proof hash), exactly as writing the real row makes the fence's
///    comparand and the proof's hash exist;
///  - **the RPC route** decodes `{payload, expected_revision, key_proof}`,
///    identifies the caller by the payload's `user_id` (the client always
///    composes it from the SESSION — the stand-in for `auth.uid()`),
///    refuses an absent row with the marker, runs the sync fake's
///    `keyVaultUpdate`, and on success replaces the stored row WHOLE from
///    the payload (an absent nullable key ⇒ nil — the RPC's full-replace
///    semantics), stamping the receipt's revision + rotation seq and a
///    server-side `updated_at`; refusals answer 400 with the marker in the
///    body, exactly as PostgREST serves a RAISE.
final class ScriptedVaultServer: @unchecked Sendable {
    private let lock = NSLock()
    private var rowsByUser: [String: KeyVaultWireRow] = [:]
    private(set) var requestCount = 0
    private(set) var getCount = 0
    private(set) var postCount = 0
    /// Counts REFUSED direct PATCHes (the closed road) since pre-13x.
    private(set) var patchCount = 0
    /// Counts `key_vault_update` RPC calls (accepted or refused).
    private(set) var updateCount = 0
    /// When set, requests whose bearer differs answer 401 (the stale-token
    /// arm; the retry with a refreshed session then succeeds).
    var requiredBearer: String?
    /// When set, EVERY request answers this status with an empty body
    /// (server-down arms).
    var forcedStatus: Int?

    /// The linked mirror — the vault row the RPCs gate on lives there.
    let syncServer: FakeSyncServer

    /// 13y UNIT B: bearer → user, for the challenge/enroll routes (whose
    /// requests carry no user id — the real server reads auth.uid()).
    /// `KeyVaultClient` composes bearers as `token-<uid suffix>` via the
    /// worlds' StaticSessionProvider; worlds with several users register
    /// here (VaultTestWorld does at init). Unregistered bearers fall back
    /// to the fake's default account — the single-user worlds' truth.
    private var bearerUsers: [String: String] = [:]

    func registerBearer(_ bearer: String, userID: String) {
        lock.lock(); defer { lock.unlock() }
        bearerUsers[bearer] = userID
    }

    private func user(forBearer header: String?) -> String {
        lock.lock(); defer { lock.unlock() }
        let bearer = (header ?? "").replacingOccurrences(of: "Bearer ", with: "")
        return bearerUsers[bearer] ?? FakeSyncServer.defaultUserID
    }

    init(syncServer: FakeSyncServer = FakeSyncServer()) {
        self.syncServer = syncServer
    }

    /// Seed a stored row directly (e.g. a newer-format vault). Does NOT
    /// provision the linked account — the format-only suites' seeding.
    func store(_ row: KeyVaultWireRow) {
        lock.lock()
        defer { lock.unlock() }
        rowsByUser[row.userID] = row
    }

    func storedRow(userID: String) -> KeyVaultWireRow? {
        lock.lock()
        defer { lock.unlock() }
        return rowsByUser[userID]
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return rowsByUser.isEmpty
    }

    /// The injectable `load` closure for `KeyVaultClient`.
    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return try await self.respond(to: request)
        }
    }

    private func response(
        _ request: URLRequest, _ status: Int, body: Data = Data()
    ) -> (Data, URLResponse) {
        (body, HTTPURLResponse(
            url: request.url!, statusCode: status, httpVersion: "HTTP/1.1",
            headerFields: nil)!)
    }

    /// PostgREST serves a RAISE as a non-2xx JSON body carrying the message
    /// — the client classifies by marker.
    private func refusal(_ request: URLRequest, marker: String) -> (Data, URLResponse) {
        response(request, 400, body: Data(
            #"{"code":"P0001","message":"\#(marker): refused by the mirror"}"#.utf8))
    }

    // The locked state accessors are SYNCHRONOUS (Swift refuses `NSLock`
    // calls from an async context); the async router below sequences them
    // around the one `await` (the linked mirror's actor).

    private func countRequest() -> (forced: Int?, bearer: String?) {
        lock.lock(); defer { lock.unlock() }
        requestCount += 1
        return (forcedStatus, requiredBearer)
    }

    private func serveGet(_ request: URLRequest, user: String?) -> (Data, URLResponse) {
        lock.lock(); defer { lock.unlock() }
        getCount += 1
        guard let user else { return response(request, 400) }
        let rows = rowsByUser[user].map { [$0] } ?? []
        return response(request, 200, body: try! JSONEncoder().encode(rows))
    }

    private enum PostVerdict { case refusedNoHash, duplicate, stored }

    private func servePost(_ row: KeyVaultWireRow) -> PostVerdict {
        lock.lock(); defer { lock.unlock() }
        postCount += 1
        // The BEFORE INSERT trigger's twin: a vault is created with its
        // proof hash, never without.
        guard row.keyProofHash != nil else { return .refusedNoHash }
        guard rowsByUser[row.userID] == nil else { return .duplicate }
        rowsByUser[row.userID] = row
        return .stored
    }

    private func servePatch(_ request: URLRequest) -> (Data, URLResponse) {
        // THE CLOSED ROAD (11 section 2): UPDATE is revoked from
        // `authenticated` and the owner update policy is dropped — a bare
        // session's direct write is `permission denied`, whatever it
        // carries. Nothing is written; nothing is inspected.
        lock.lock(); defer { lock.unlock() }
        patchCount += 1
        return response(request, 403, body: Data(
            #"{"code":"42501","message":"permission denied for table key_vault"}"#.utf8))
    }

    private func countUpdate() {
        lock.lock(); defer { lock.unlock() }
        updateCount += 1
    }

    private func rowExists(_ userID: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return rowsByUser[userID] != nil
    }

    private func storeUpdated(_ row: KeyVaultWireRow) {
        lock.lock(); defer { lock.unlock() }
        rowsByUser[row.userID] = row
    }

    private func respond(to request: URLRequest) async throws -> (Data, URLResponse) {
        let (forced, bearerRequired) = countRequest()
        if let forced { return response(request, forced) }
        if let bearerRequired {
            let bearer = request.value(forHTTPHeaderField: "Authorization") ?? ""
            guard bearer == "Bearer \(bearerRequired)" else {
                return response(request, 401, body: Data(#"{"message":"JWT expired"}"#.utf8))
            }
        }
        guard let url = request.url else { return response(request, 404) }

        if url.path.hasSuffix("/rest/v1/rpc/sync_challenge") {
            return try await respondToChallenge(request)
        }
        if url.path.hasSuffix("/rest/v1/rpc/key_proof_enroll") {
            return try await respondToEnroll(request)
        }
        if url.path.hasSuffix("/rest/v1/rpc/key_vault_update") {
            return try await respondToUpdate(request)
        }
        guard url.path.hasSuffix("/rest/v1/key_vault") else { return response(request, 404) }

        switch request.httpMethod {
        case "GET":
            return serveGet(request, user: userFilter(url))
        case "POST":
            guard let body = request.httpBody,
                  let row = try? JSONDecoder().decode(KeyVaultWireRow.self, from: body)
            else { return response(request, 400) }
            switch servePost(row) {
            case .refusedNoHash:
                return refusal(request, marker: SyncServerRefusalMarker.keyProofRequired)
            case .duplicate:
                // PostgREST duplicate key: HTTP 409, SQLSTATE 23505.
                return response(request, 409, body: Data(
                    #"{"code":"23505","message":"duplicate key value violates unique constraint \"key_vault_pkey\""}"#
                        .utf8))
            case .stored:
                // Writing the real row makes the fence's comparand and the
                // proof's hash exist — the linked account is provisioned.
                await syncServer.provisionAccount(
                    row.userID, vaultCorpusKeyID: row.corpusKeyID, keyProofHash: row.keyProofHash)
                return response(request, 201)
            }
        case "PATCH":
            return servePatch(request)
        default:
            return response(request, 405)
        }
    }

    /// 13y UNIT B — `sync_challenge(n)`'s route: bridges to the linked
    /// fake's mint (session-gated only; no vault requirement).
    private func respondToChallenge(_ request: URLRequest) async throws -> (Data, URLResponse) {
        struct Request: Decodable { let n: Int }
        guard request.httpMethod == "POST", let body = request.httpBody,
              let call = try? JSONDecoder().decode(Request.self, from: body)
        else { return response(request, 400) }
        let userID = user(forBearer: request.value(forHTTPHeaderField: "Authorization"))
        let minted = await syncServer.fetchChallenges(call.n, as: userID)
        return response(request, 200, body: try JSONEncoder().encode(minted))
    }

    /// 13y UNIT B — `key_proof_enroll`'s route: bridges to the linked
    /// fake's enroll twin; refusals answer as PostgREST serves a RAISE.
    private func respondToEnroll(_ request: URLRequest) async throws -> (Data, URLResponse) {
        struct Request: Decodable {
            let kp1: String
            let kp2: String
            let activeKeyID: String
            enum CodingKeys: String, CodingKey {
                case kp1
                case kp2
                case activeKeyID = "active_key_id"
            }
        }
        guard request.httpMethod == "POST", let body = request.httpBody,
              let call = try? JSONDecoder().decode(Request.self, from: body)
        else { return response(request, 400) }
        let userID = user(forBearer: request.value(forHTTPHeaderField: "Authorization"))
        do {
            try await syncServer.enrollKeyProof(
                legacyProof: call.kp1, macKey: call.kp2,
                activeKeyID: call.activeKeyID, as: userID)
            // The one-Postgres linkage: the stored wire row's hash moves
            // WITH the enrollment (the real table has one row).
            if var stored = storedRow(userID: userID) {
                stored.keyProofHash = await syncServer.vaultRow(for: userID)?.keyProofHash
                storeUpdated(stored)
            }
        } catch SyncError.keyProofAlreadyEnrolled {
            return refusal(request, marker: SyncServerRefusalMarker.keyProofAlreadyEnrolled)
        } catch SyncError.keyProofRefused {
            return refusal(request, marker: SyncServerRefusalMarker.keyProofRequired)
        } catch SyncError.encryptionKeysReplaced {
            return refusal(request, marker: SyncServerRefusalMarker.staleKeyFence)
        }
        return response(request, 200)
    }

    /// The `key_vault_update` RPC's route.
    private func respondToUpdate(_ request: URLRequest) async throws -> (Data, URLResponse) {
        struct Request: Decodable {
            let payload: KeyVaultWireRow
            let expectedRevision: Int
            let keyProof: String
            /// 13y UNIT B: the single-use nonce.
            let challenge: String
            enum CodingKeys: String, CodingKey {
                case payload
                case expectedRevision = "expected_revision"
                case keyProof = "key_proof"
                case challenge
            }
        }
        countUpdate()
        guard request.httpMethod == "POST", let body = request.httpBody,
              let call = try? JSONDecoder().decode(Request.self, from: body)
        else { return response(request, 400) }
        let userID = call.payload.userID
        // 13y UNIT B: `key_proof_mac` is WRITE-ONLY on the wire row (its
        // decode always yields nil), so the route reads it off the raw
        // payload json — exactly where the RPC reads it.
        let rawPayload = (try? JSONSerialization.jsonObject(with: body) as? [String: Any])
            .flatMap { $0["payload"] as? [String: Any] }
        let keyProofMac = rawPayload?["key_proof_mac"] as? String
        // `select … for update` finds no row: VARIORUM_VAULT_ABSENT.
        guard rowExists(userID) else {
            return refusal(request, marker: SyncServerRefusalMarker.vaultAbsent)
        }
        let receipt: FakeSyncServer.VaultUpdateReceipt
        do {
            receipt = try await syncServer.keyVaultUpdate(
                as: userID, expectedRevision: call.expectedRevision,
                keyProof: SyncKeyProof(challenge: call.challenge, proof: call.keyProof),
                newCorpusKeyID: call.payload.corpusKeyID,
                newKeyProofHash: call.payload.keyProofHash,
                newKeyProofMac: keyProofMac,
                previousCorpusKeyID: call.payload.corpusPreviousKeyID,
                previousCorpusKey: call.payload.corpusPreviousWrappedByMaster,
                updatedByDevice: call.payload.updatedByDevice)
        } catch KeyVaultClientError.vaultAbsent {
            return refusal(request, marker: SyncServerRefusalMarker.vaultAbsent)
        } catch KeyVaultClientError.keyProofRefused {
            return refusal(request, marker: SyncServerRefusalMarker.keyProofRequired)
        } catch KeyVaultClientError.keyProofEnrollRequired {
            return refusal(request, marker: SyncServerRefusalMarker.keyProofEnroll)
        } catch KeyVaultClientError.keyProofChallengeStale {
            return refusal(request, marker: SyncServerRefusalMarker.keyProofStaleChallenge)
        } catch KeyVaultClientError.rotationInProgress {
            return refusal(request, marker: SyncServerRefusalMarker.rotationInProgress)
        } catch KeyVaultClientError.vaultRevisionConflict {
            return refusal(request, marker: SyncServerRefusalMarker.vaultRevisionConflict)
        } catch KeyVaultClientError.rotationRowsRemain {
            // F1 (BLOCKER-1): the completion guard's refusal, served as
            // PostgREST serves the RAISE — the client classifies by marker.
            return refusal(request, marker: SyncServerRefusalMarker.rotationRowsRemain)
        } catch FakeSyncServerError.previousKeyHalfMissing {
            return response(request, 400, body: Data(
                #"{"code":"P0001","message":"a previous corpus key travels as its id AND its wrap"}"#.utf8))
        }
        // The write: the format columns replaced WHOLE from the payload;
        // the server-managed columns from the receipt / the clock.
        var stored = call.payload
        stored.userID = userID
        stored.revision = receipt.revision
        stored.rotationStartedSeq = receipt.rotationStartedSeq
        // The hash: the payload's when carried, else the row's (the RPC's
        // `coalesce(payload->>'key_proof_hash', key_proof_hash)`) — which
        // the NULL-hash arm may just have landed.
        if stored.keyProofHash == nil {
            stored.keyProofHash = await syncServer.vaultRow(for: userID)?.keyProofHash
        }
        stored.updatedAt = DateFormatter.variorumISO8601.string(from: Date())
        storeUpdated(stored)
        let receiptJSON: [String: Any] = [
            "revision": receipt.revision,
            "rotation_started_seq": receipt.rotationStartedSeq.map { NSNumber(value: $0) } ?? NSNull(),
        ]
        return response(request, 200, body: try JSONSerialization.data(withJSONObject: receiptJSON))
    }

    private func userFilter(_ url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let item = components.queryItems?.first(where: { $0.name == "user_id" }),
              let value = item.value, value.hasPrefix("eq.")
        else { return nil }
        return String(value.dropFirst(3))
    }
}

/// One scripted vault world: server + client + enrollment, under a fixed
/// signed-in session. The user is the sync fake's DEFAULT account by
/// default (pre-13x: the vault row and the sync fence are one row), so a
/// world that also syncs composes over one identity.
struct VaultTestWorld {
    let server: ScriptedVaultServer
    let client: KeyVaultClient
    let enrollment: VaultEnrollment
    let userID: String
    /// The linked mirror (the vault row the RPCs gate on).
    var syncServer: FakeSyncServer { server.syncServer }

    init(
        userID: String = FakeSyncServer.defaultUserID, accessToken: String = "token-1",
        syncServer: FakeSyncServer? = nil
    ) {
        self.init(
            server: ScriptedVaultServer(syncServer: syncServer ?? FakeSyncServer()),
            userID: userID, accessToken: accessToken)
    }

    /// A second device against a SHARED server (same account, its own
    /// client) — the R1-2 cross-device interleaving's world.
    init(server: ScriptedVaultServer, userID: String = FakeSyncServer.defaultUserID,
         accessToken: String = "token-1") {
        server.registerBearer(accessToken, userID: userID)
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: accessToken, userID: userID)),
            load: server.load)
        self.server = server
        self.client = client
        self.enrollment = VaultEnrollment(client: client)
        self.userID = userID
    }
}
