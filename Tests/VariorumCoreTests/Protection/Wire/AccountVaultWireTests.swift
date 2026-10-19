import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

// VX-307 U1 piece 2 — THE FAKE SERVER speaking the marker-14 vault shape
// (`17_phase_vx307_vault.sql`'s semantics, emulated at the HTTP seam the
// production client injects), and the wire client proven against it: the
// round-trip, the challenge dance (single-use nonces, the enroll road, one
// stale retry), the CAS, the hash-and-secret-together rule, and every typed
// refusal. No network anywhere.

/// The marker-14 mirror, in process: one vault row, single-use nonces, the
/// Vault-held kp2 secret, and the artifact's `key_vault_update` semantics.
final class FakeVaultHTTPServer: @unchecked Sendable {
    struct Row {
        var json: [String: Any]
        var revision: Int
        /// `key_proof_hash` as stored (v1 form at creation; SHA-256(kp2) after
        /// enrollment or a master change).
        var storedHash: String
    }

    private let lock = NSLock()
    var row: Row?
    /// Supabase Vault's `kp:` secret — the per-request MAC key, raw.
    var kp2Secret: Data?
    var nonces: Set<String> = []
    /// Knobs and counters the tests read.
    var enrolls = 0
    var updates = 0
    var dropNextChallenge = false
    /// A pre-lockstep mirror (16-era): rows serve without `mode`.
    var preLockstep = false

    func seed(_ vault: AccountVault, userID: String, revision: Int = 1) {
        let data = try! JSONEncoder().encode(AccountVaultWireRow(vault: vault, userID: userID))
        var json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        json["revision"] = revision
        json["updated_at"] = "2026-10-18T12:00:00.000+00:00"
        row = Row(json: json, revision: revision, storedHash: vault.keyProofHash)
    }

    /// The injectable `load` (synchronous under the lock; async only in
    /// signature).
    func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try serve(request)
    }

    private func serve(_ request: URLRequest) throws -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
        let path = request.url!.path
        let body = request.httpBody.flatMap {
            (try? JSONSerialization.jsonObject(with: $0)) as? [String: Any]
        } ?? [:]
        let (status, payload): (Int, Any) = handle(path: path, request: request, body: body)
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.fragmentsAllowed])
        let response = HTTPURLResponse(
            url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }

    private func refusal(_ marker: String) -> (Int, Any) { (400, ["message": marker]) }

    private func handle(path: String, request: URLRequest, body: [String: Any]) -> (Int, Any) {
        switch path {
        case let p where p.hasSuffix("rest/v1/key_vault") && request.httpMethod == "GET":
            guard var json = row?.json else { return (200, [[String: Any]]()) }
            json["key_proof_hash"] = row!.storedHash
            if preLockstep {
                json["mode"] = nil
                json["earlier_row_keys"] = nil
            }
            return (200, [json])
        case let p where p.hasSuffix("rest/v1/key_vault") && request.httpMethod == "POST":
            guard row == nil else { return (409, ["message": "duplicate key"]) }
            guard let hash = body["key_proof_hash"] as? String else {
                return refusal("VARIORUM_KEY_PROOF_REQUIRED: a vault is created with its key-proof hash")
            }
            var json = body
            json["revision"] = 1
            json["updated_at"] = "2026-10-18T12:00:00.000+00:00"
            row = Row(json: json, revision: 1, storedHash: hash)
            return (201, [json])
        case let p where p.hasSuffix("rpc/sync_challenge"):
            if dropNextChallenge {
                // A nonce minted and lost (expired server-side before use).
                dropNextChallenge = false
                return (200, [Data(UUID().uuidString.utf8).base64EncodedString()])
            }
            let nonce = Data(UUID().uuidString.utf8).base64EncodedString()
            nonces.insert(nonce)
            return (200, [nonce])
        case let p where p.hasSuffix("rpc/key_proof_enroll"):
            guard let current = row else { return refusal("VARIORUM_VAULT_ABSENT") }
            guard kp2Secret == nil else { return refusal("VARIORUM_KEY_PROOF_ALREADY_ENROLLED") }
            guard let kp1 = body["kp1"] as? String, let raw = Data(base64Encoded: kp1),
                  KeyProof.hash(ofToken: raw) == current.storedHash
            else { return refusal("VARIORUM_KEY_PROOF_REQUIRED: enrollment is authorized by the stored hash") }
            guard let kp2 = body["kp2"] as? String, let kp2Raw = Data(base64Encoded: kp2) else {
                return refusal("VARIORUM_KEY_PROOF_REQUIRED")
            }
            guard (body["active_key_id"] as? String) == (current.json["corpus_key_id"] as? String) else {
                return refusal("VARIORUM_STALE_KEY_FENCE")
            }
            kp2Secret = kp2Raw
            row!.storedHash = KeyProof.hash(ofToken: kp2Raw)
            enrolls += 1
            return (200, NSNull())
        case let p where p.hasSuffix("rpc/key_vault_update"):
            guard var current = row else { return refusal("VARIORUM_VAULT_ABSENT") }
            // 13y's order: the proof check first (enroll fence, nonce, MAC).
            guard let kp2Secret else { return refusal("VARIORUM_KEY_PROOF_ENROLL: enroll the proof secret first") }
            guard let challenge = body["challenge"] as? String, nonces.remove(challenge) != nil else {
                return refusal("VARIORUM_KEY_PROOF_STALE_CHALLENGE")
            }
            var input = Data(base64Encoded: challenge) ?? Data()
            input.append(Data(":key_vault_update".utf8))
            let mac = Data(HMAC<SHA256>.authenticationCode(for: input, using: SymmetricKey(data: kp2Secret)))
                .base64EncodedString()
            guard (body["key_proof"] as? String) == mac else {
                return refusal("VARIORUM_KEY_PROOF_REQUIRED: the proof is not the current master's")
            }
            guard let expected = body["expected_revision"] as? Int, expected == current.revision else {
                return refusal("VARIORUM_VAULT_REVISION_CONFLICT")
            }
            guard let payload = body["payload"] as? [String: Any] else { return refusal("VARIORUM_PRE_VX307_PAYLOAD") }
            guard let mode = payload["mode"] as? String, ["standard", "castle"].contains(mode) else {
                return refusal("VARIORUM_PRE_VX307_PAYLOAD: the payload carries no mode")
            }
            // Hash and secret land together (the artifact's rule, verbatim).
            let incomingHash = payload["key_proof_hash"] as? String
            let incomingMac = payload["key_proof_mac"] as? String
            if let incomingMac {
                guard let raw = Data(base64Encoded: incomingMac), let incomingHash,
                      KeyProof.hash(ofToken: raw) == incomingHash
                else { return refusal("VARIORUM_KEY_PROOF_REQUIRED: they land together or not at all") }
                self.kp2Secret = raw
                current.storedHash = incomingHash
            } else if let incomingHash, incomingHash != current.storedHash {
                return refusal("VARIORUM_KEY_PROOF_REQUIRED: a hash never moves without its secret")
            }
            // The new body's column set: the payload lands whole; the
            // journal-bridge / Apple-held / rotation columns are untouched.
            for key in ["format_version", "kdf_algorithm", "kdf_argon2_version", "kdf_memory_kib",
                        "kdf_iterations", "kdf_parallelism", "kdf_salt", "kdf_output_bytes",
                        "master_wrapped_by_passphrase", "master_wrapped_by_recovery",
                        "corpus_key_id", "corpus_key_wrapped_by_master", "mode", "earlier_row_keys",
                        "updated_by_device"] {
                current.json[key] = payload[key]
            }
            if let incomingHash { current.json["key_proof_hash"] = incomingHash }
            current.revision += 1
            current.json["revision"] = current.revision
            row = current
            updates += 1
            return (200, ["revision": current.revision])
        default:
            return (404, ["message": "no route for \(path)"])
        }
    }
}

struct FixedSessions: UserSessionProviding {
    let userID: String
    func currentSession() async throws -> UserSession { UserSession(accessToken: "t", userID: userID) }
}

@Suite struct AccountVaultWireTests {
    *[removed for publication]*

    static func client(_ server: FakeVaultHTTPServer) -> AccountVaultClient {
        AccountVaultClient(
            configuration: AccountVaultClient.Configuration(
                projectURL: URL(string: "https://fake.supabase.co")!, apiKey: "k", deviceName: "Mac A",
                floor: .relaxedForTests),
            sessionProvider: FixedSessions(userID: account),
            load: { try await server.load($0) })
    }

    static func mintVault(mode: ProtectionMode = .standard) throws -> (AccountVault, AccountKeys, PassphraseKey, WordsKey) {
        let passphrase = try PF.passphraseKey("a passphrase long enough")
        let words = try PF.wordsKey(try PF.words())
        let (vault, keys) = try VaultModel.creating(
            passphrase: passphrase, words: words, mode: mode, device: "Mac A", ids: WireIDs())
        return (vault, keys, passphrase, words)
    }

    @Test func createThenFetchRoundTripsTheVaultWhole() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, _, _, _) = try Self.mintVault()
        let created = try await client.createVault(vault, accountID: Self.account, device: "Mac A")
        #expect(created.revision == 1)
        let fetched = try await client.fetchVault(accountID: Self.account)
        #expect(fetched?.vault == vault)
        #expect(fetched?.revision == 1)
        #expect(fetched?.mode == .standard)
        #expect(fetched?.updatedAt != nil)
    }

    @Test func aSecondCreateRefusesVaultExists() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, _, _, _) = try Self.mintVault()
        _ = try await client.createVault(vault, accountID: Self.account, device: "Mac A")
        await #expect(throws: VaultRefusal.vaultExists) {
            _ = try await client.createVault(vault, accountID: Self.account, device: "Mac A")
        }
    }

    @Test func aPreLockstepRowRefusesPreLockstepNeverGuesses() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, _, _, _) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        server.preLockstep = true
        await #expect(throws: VaultRefusal.preLockstepRow) {
            _ = try await client.fetchVault(accountID: Self.account)
        }
    }

    @Test func theFirstUpdateRunsTheEnrollRoadOnceAndLands() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, _, _) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        // A mode-keeping re-wrap (the key doors' shape): no successor.
        let written = try await client.updateVault(
            vault, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
            successorMaster: nil, device: "Mac A")
        #expect(written.revision == 2)
        #expect(server.enrolls == 1, "the un-enrolled account enrolled exactly once")
        #expect(server.updates == 1)
        // Enrollment moved the stored hash to the kp2 form.
        #expect(server.row?.storedHash == KeyProof.macHash(master: keys.masterKey))
        // The next update needs no enroll — and derives from a FETCH (the
        // R1-2 contract: an update built from a fetch carries that fetch's
        // row, its enrolled hash included).
        let fetched = try #require(try await client.fetchVault(accountID: Self.account))
        _ = try await client.updateVault(
            fetched.vault, accountID: Self.account, expectedRevision: fetched.revision, proofMaster: keys.masterKey,
            successorMaster: nil, device: "Mac A")
        #expect(server.enrolls == 1)
    }

    @Test func enteringCastleLandsTheNewHashAndSecretTogether() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, passphrase, words) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        let ids = WireIDs()
        let (castle, fresh) = try VaultModel.enteringCastle(
            vault, held: keys, passphrase: passphrase, words: words, device: "Mac A", ids: ids)
        let written = try await client.updateVault(
            castle, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
            successorMaster: fresh.masterKey, device: "Mac A")
        #expect(written.revision == 2)
        #expect(server.row?.storedHash == KeyProof.macHash(master: fresh.masterKey))
        // The row now reads back whole: Castle, one earlier key.
        let fetched = try await client.fetchVault(accountID: Self.account)
        #expect(fetched?.mode == .castle)
        #expect(fetched?.vault.earlierRowKeys.count == 1)
        #expect(try fetched?.vault.keys(master: fresh.masterKey).rowKey(for: keys.rowKeyID) != nil,
                "a row sealed under the outgoing key still reads (rule 15)")
        // And the OLD master's proof is refused from now on.
        await #expect(throws: VaultRefusal.keyProofRefused) {
            _ = try await client.updateVault(
                castle, accountID: Self.account, expectedRevision: 2, proofMaster: keys.masterKey,
                successorMaster: nil, device: "Mac A")
        }
    }

    @Test func aNewHashWithoutItsSecretRefuses() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, passphrase, words) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        let (castle, _) = try VaultModel.enteringCastle(
            vault, held: keys, passphrase: passphrase, words: words, device: "Mac A", ids: WireIDs())
        await #expect(throws: VaultRefusal.keyProofRefused) {
            _ = try await client.updateVault(
                castle, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
                successorMaster: nil, device: "Mac A")
        }
        // And a WRONG successor refuses the same way.
        await #expect(throws: VaultRefusal.keyProofRefused) {
            _ = try await client.updateVault(
                castle, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
                successorMaster: SymmetricKey(size: .bits256), device: "Mac A")
        }
        #expect(server.updates == 0, "nothing landed")
    }

    @Test func aStaleRevisionRefusesConflictAndWritesNothing() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, _, _) = try Self.mintVault()
        server.seed(vault, userID: Self.account, revision: 5)
        await #expect(throws: VaultRefusal.revisionConflict) {
            _ = try await client.updateVault(
                vault, accountID: Self.account, expectedRevision: 4, proofMaster: keys.masterKey,
                successorMaster: nil, device: "Mac A")
        }
        #expect(server.updates == 0)
        #expect(server.row?.revision == 5)
    }

    @Test func aWrongMasterRefusesTheProof() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, _, _) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        // Enroll the right master first (the stored hash moves to kp2 form).
        _ = try await client.updateVault(
            vault, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
            successorMaster: nil, device: "Mac A")
        await #expect(throws: VaultRefusal.keyProofRefused) {
            _ = try await client.updateVault(
                vault, accountID: Self.account, expectedRevision: 2, proofMaster: SymmetricKey(size: .bits256),
                successorMaster: nil, device: "Mac A")
        }
    }

    @Test func aStaleChallengeEarnsExactlyOneFreshRetry() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        let (vault, keys, _, _) = try Self.mintVault()
        server.seed(vault, userID: Self.account)
        server.dropNextChallenge = true
        let written = try await client.updateVault(
            vault, accountID: Self.account, expectedRevision: 1, proofMaster: keys.masterKey,
            successorMaster: nil, device: "Mac A")
        #expect(written.revision == 2, "the one retry landed")
    }

    @Test func anotherAccountsIDRefusesNotSignedIn() async throws {
        let server = FakeVaultHTTPServer()
        let client = Self.client(server)
        await #expect(throws: VaultRefusal.notSignedIn) {
            _ = try await client.fetchVault(accountID: "someone-else")
        }
    }

    @Test func aTransportErrorReadsAsUnreachable() async throws {
        let client = AccountVaultClient(
            configuration: AccountVaultClient.Configuration(
                projectURL: URL(string: "https://fake.supabase.co")!, apiKey: "k", deviceName: "Mac A",
                floor: .relaxedForTests),
            sessionProvider: FixedSessions(userID: Self.account),
            load: { _ in throw URLError(.notConnectedToInternet) })
        await #expect(throws: VaultRefusal.unreachable) {
            _ = try await client.fetchVault(accountID: Self.account)
        }
    }
}

/// Fresh random IDs for the wire tests (no seeding needed — nothing replays).
final class WireIDs: IDsLeaf, @unchecked Sendable {
    func mintID() -> String { PF.id() }
    func mintLibraryKey() -> StoreKey { StoreKey.mint() }
    func mintAppleKey() -> AppleKeyMaterial { AppleKeyMaterial.mint() }
    func mintSymmetricKey() -> SymmetricKey { SymmetricKey(size: .bits256) }
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor { PF.fastKDF() }
    func mintWords() -> [String] { (try? PF.words()) ?? [] }
}
