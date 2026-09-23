import CryptoKit
import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 3 (L8) — the `key_vault` PostgREST client against the
/// scripted server: round-trips, the refusal arms, single-flight, and the
/// 9c auth posture (one 401 refresh-and-retry).
@Suite("Key vault client (Phase 14b, L8)")
struct KeyVaultClientTests {

    private func sampleFormat(withRecovery: Bool = false) throws
        -> (format: KeyVaultFormat, master: SymmetricKey, passphraseKey: SymmetricKey,
            recoveryKey: SymmetricKey)
    {
        let master = SymmetricKey(size: .bits256)
        let passphraseKey = SymmetricKey(size: .bits256)
        let recoveryKey = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: withRecovery ? recoveryKey : nil,
            classKeys: [
                (keyClass: .corpus, keyID: "corpus-id-1", key: SymmetricKey(size: .bits256)),
                (keyClass: .journalBridge, keyID: "journal-id-1", key: SymmetricKey(size: .bits256)),
            ],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        return (format, master, passphraseKey, recoveryKey)
    }

    @Test func fetchOnAnEmptyVaultReturnsNil() async throws {
        let world = VaultTestWorld()
        #expect(try await world.client.fetchVault() == nil)
    }

    @Test func createThenFetchRoundTripsTheFormatExactly() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        try await world.client.createVault(sample.format)
        let fetched = try await world.client.fetchVault()
        // pre-13x 2c (decision 34): the write stamped THIS client's device
        // name into the seventh column; everything cryptographic is exact.
        var expected = sample.format
        expected.updatedByDevice = "test device"
        #expect(fetched?.format == expected)
        // A fresh row carries the CAS token at the column default (R1-2).
        #expect(fetched?.revision == 1)
        // The stored wire row carries the session's user — never a
        // caller-supplied id.
        #expect(world.server.storedRow(userID: world.userID) != nil)
    }

    @Test func createOverAnExistingVaultRefuses() async throws {
        let world = VaultTestWorld()
        try await world.client.createVault(try sampleFormat().format)
        await #expect(throws: KeyVaultClientError.vaultAlreadyExists) {
            try await world.client.createVault(try sampleFormat().format)
        }
    }

    @Test func updateReplacesTheRowAndRefusesWhenAbsent() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        // Absent → refuses; nothing invented.
        await #expect(throws: KeyVaultClientError.vaultAbsent) {
            try await world.client.updateVault(
                sample.format, expectedRevision: 1, keyProof: KeyProofMaterial(master: sample.master))
        }
        try await world.client.createVault(sample.format)
        let updated = try sample.format.addingRecoveryWrap(
            masterKey: sample.master, recoveryKey: sample.recoveryKey)
        try await world.client.updateVault(
            updated, expectedRevision: 1, keyProof: KeyProofMaterial(master: sample.master))
        let fetched = try await world.client.fetchVault()
        var expected = updated
        expected.updatedByDevice = "test device"  // decision 34: the writer's name (2c)
        // 13y UNIT B: the door's first act ENROLLED the fresh account —
        // the stored hash is SHA-256(kp2) and the dance refreshed the
        // payload's copy to match (the land-together rule).
        expected.keyProofHash = KeyProof.macHash(master: sample.master)
        #expect(fetched?.format == expected)
        #expect(fetched?.format.masterWrappedByRecovery != nil)
        // The CAS token advanced with the write (R1-2).
        #expect(fetched?.revision == 2)
    }

    /// The CAS mechanics at the client seam (R1-2): an update presenting a
    /// STALE revision token matches zero rows and refuses typed — the row
    /// is byte-untouched, and the refusal's contract is refetch-and-
    /// re-derive, never blind-retry.
    @Test func aStaleRevisionUpdateRefusesTypedWithoutWriting() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        try await world.client.createVault(sample.format)
        // A concurrent writer moves the row: revision 1 → 2.
        let moved = try sample.format.addingRecoveryWrap(
            masterKey: sample.master, recoveryKey: sample.recoveryKey)
        try await world.client.updateVault(
            moved, expectedRevision: 1, keyProof: KeyProofMaterial(master: sample.master))
        let rowBefore = world.server.storedRow(userID: world.userID)

        // The stale writer still holds token 1 — refused, nothing written.
        await #expect(throws: KeyVaultClientError.vaultRevisionConflict) {
            try await world.client.updateVault(
                sample.format, expectedRevision: 1, keyProof: KeyProofMaterial(master: sample.master))
        }
        #expect(world.server.storedRow(userID: world.userID) == rowBefore,
                "a refused stale update writes nothing")
        // Refetching yields the current token; the re-derived update lands.
        let current = try #require(try await world.client.fetchVault())
        #expect(current.revision == 2)
        try await world.client.updateVault(
            current.format, expectedRevision: current.revision,
            keyProof: KeyProofMaterial(master: sample.master))
        #expect(try await world.client.fetchVault()?.revision == 3)
    }

    // MARK: pre-13x — the ONE write road is the RPC, under the proof

    /// The update travels as `POST rest/v1/rpc/key_vault_update` with the
    /// proof in the BODY (never the URL), the row as `payload`, and the
    /// expected revision — and the receipt carries the new revision. A
    /// wrong proof refuses typed with the stored row byte-untouched.
    @Test func theUpdateRidesTheRPCWithTheProofInTheBodyAndAWrongProofWritesNothing() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        let requests = LockIsolated<[URLRequest]>([])
        let recording = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: world.userID)),
            load: { [load = world.server.load] request in
                requests.withValue { $0.append(request) }
                return try await load(request)
            })
        try await recording.createVault(sample.format)
        let material = KeyProofMaterial(master: sample.master)
        let receipt = try await recording.updateVault(
            try sample.format.addingRecoveryWrap(masterKey: sample.master, recoveryKey: sample.recoveryKey),
            expectedRevision: 1, keyProof: material)
        #expect(receipt == KeyVaultClient.UpdateReceipt(revision: 2, rotationStartedSeq: nil))
        // 13y UNIT B: a freshly created vault is UN-ENROLLED, so the door's
        // first act runs the whole production dance — challenge fetch,
        // the ENROLL refusal, the enroll road, a fresh challenge, the
        // update. The LAST request is the update that landed.
        let update = try #require(requests.value.last)
        #expect(update.httpMethod == "POST")
        #expect(update.url?.path.hasSuffix("/rest/v1/rpc/key_vault_update") == true, "the RPC, never a PATCH")
        #expect(update.url?.query() == nil, "no URL items — the proof and the filter both ride the body")
        // Decoded, not substring-matched: Foundation escapes `/` in JSON
        // strings, and a base64 token carries slashes.
        let body = try JSONSerialization.jsonObject(with: update.httpBody ?? Data()) as? [String: Any]
        // The proof is PER-REQUEST now: a bound HMAC beside its nonce —
        // never kp1's static wire token (the v1-era value the new
        // protocol never accepts on a gated call).
        let wireProof = try #require(body?["key_proof"] as? String, "the proof is a BODY parameter")
        #expect(wireProof != material.legacyWireToken, "the static bearer token never rides a gated call")
        #expect((body?["challenge"] as? String)?.isEmpty == false, "the nonce rides beside it")
        #expect(body?["expected_revision"] as? Int == 1)
        #expect((body?["payload"] as? [String: Any])?["corpus_key_id"] as? String == "corpus-id-1")
        // Decision 34 (2c): every write stamps THIS device's name into the
        // seventh column, and the fetched vault reads it back.
        #expect((body?["payload"] as? [String: Any])?["updated_by_device"] as? String == "test device",
                "the writing device's NAME rides every vault write")
        #expect(try await recording.fetchVault()?.format.updatedByDevice == "test device",
                "the row carries the last writer's name back")
        #expect(world.server.patchCount == 0, "the client never PATCHes")
        // Two update ATTEMPTS crossed the route: the enroll-refused first
        // try and the one that landed.
        #expect(world.server.updateCount == 2)

        // A wrong proof: refused typed, nothing written, the revision unmoved.
        let before = world.server.storedRow(userID: world.userID)
        await #expect(throws: KeyVaultClientError.keyProofRefused) {
            try await recording.updateVault(
                sample.format, expectedRevision: 2,
                keyProof: KeyProofMaterial(master: SymmetricKey(size: .bits256)))
        }
        #expect(world.server.storedRow(userID: world.userID) == before)
        #expect(try await recording.fetchVault()?.revision == 2)
    }

    /// The RPC's refusal markers classify into the client's typed errors,
    /// each one.
    @Test func theRPCsRefusalMarkersClassifyTyped() {
        #expect(KeyVaultClient.classifiedUpdateFailure(
            status: 400, body: "VARIORUM_VAULT_ABSENT: none") == .vaultAbsent)
        #expect(KeyVaultClient.classifiedUpdateFailure(
            status: 400, body: "VARIORUM_VAULT_REVISION_CONFLICT: moved") == .vaultRevisionConflict)
        #expect(KeyVaultClient.classifiedUpdateFailure(
            status: 400, body: "VARIORUM_KEY_PROOF_REQUIRED: none") == .keyProofRefused)
        #expect(KeyVaultClient.classifiedUpdateFailure(
            status: 400, body: "VARIORUM_ROTATION_IN_PROGRESS: wait") == .rotationInProgress)
        #expect(KeyVaultClient.classifiedUpdateFailure(
            status: 503, body: "down") == .httpFailure(status: 503, body: "down"))
    }

    @Test func aNewerFormatVersionRefusesByVersion() async throws {
        let world = VaultTestWorld()
        var row = try KeyVaultWireRow(
            format: try sampleFormat().format, userID: world.userID)
        row.formatVersion = KeyVaultFormat.currentFormatVersion + 1
        world.server.store(row)
        await #expect(throws: KeyVaultClientError.unsupportedFormatVersion(
            KeyVaultFormat.currentFormatVersion + 1)
        ) {
            try await world.client.fetchVault()
        }
    }

    @Test func aMalformedStoredRowRefusesTyped() async throws {
        let world = VaultTestWorld()
        var row = try KeyVaultWireRow(
            format: try sampleFormat().format, userID: world.userID)
        row.masterWrappedByPassphrase = "not!!base64"
        world.server.store(row)
        do {
            _ = try await world.client.fetchVault()
            Issue.record("a non-base64 wrap must refuse")
        } catch let error as KeyVaultClientError {
            guard case .malformedRow = error else {
                Issue.record("expected malformedRow, got \(error)")
                return
            }
        }
    }

    @Test func concurrentFetchesSingleFlightOntoOneRequest() async throws {
        let world = VaultTestWorld()
        try await world.client.createVault(try sampleFormat().format)
        let baseline = world.server.getCount
        async let a = world.client.fetchVault()
        async let b = world.client.fetchVault()
        async let c = world.client.fetchVault()
        _ = try await (a, b, c)
        #expect(world.server.getCount - baseline == 1,
                "concurrent fetches must coalesce onto one request (single-flight)")
    }

    /// The 9c auth posture: a server-judged-stale token gets ONE
    /// refresh-and-retry through the provider seam.
    @Test func a401GetsOneRefreshAndRetry() async throws {
        let server = ScriptedVaultServer()
        server.requiredBearer = "fresh-token"
        final class RefreshingProvider: UserSessionProviding, @unchecked Sendable {
            func currentSession() async throws -> UserSession {
                UserSession(accessToken: "stale-token", userID: "user-vault-test")
            }
            func refreshedSession() async throws -> UserSession {
                UserSession(accessToken: "fresh-token", userID: "user-vault-test")
            }
        }
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: RefreshingProvider(),
            load: server.load)
        // The GET 401s on the stale bearer, retries refreshed, succeeds.
        #expect(try await client.fetchVault() == nil)
    }

    @Test func serverFailuresSurfaceAsTypedHTTPErrors() async throws {
        let world = VaultTestWorld()
        world.server.forcedStatus = 503
        do {
            _ = try await world.client.fetchVault()
            Issue.record("a 503 must surface")
        } catch let error as KeyVaultClientError {
            guard case .httpFailure(let status, _) = error else {
                Issue.record("expected httpFailure, got \(error)")
                return
            }
            #expect(status == 503)
        }
    }

    /// The wire row refuses to encode a format missing either v1 class key
    /// — the DDL's columns ARE the class set (R-8).
    @Test func aFormatMissingAClassKeyHasNoWireForm() throws {
        let master = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: SymmetricKey(size: .bits256),
            recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "corpus-only", key: SymmetricKey(size: .bits256))],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        #expect(throws: KeyVaultClientError.self) {
            _ = try KeyVaultWireRow(format: format, userID: "u")
        }
    }
}
