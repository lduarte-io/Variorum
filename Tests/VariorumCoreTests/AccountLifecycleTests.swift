import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 14c batch 2 (L4/L5) — the account lifecycle doors' brains: the
/// deletion door's passphrase authorization, the post-purge fence
/// backstop, and the lifecycle client's wire shape. (CF-8's truncate-road
/// re-key pins retired with `AccountRekey` at pre-13x 2b — `CorpusRotationTests`.)
///
/// EMULATION CAVEAT (the batch-1 discipline, in force here): the vault
/// lives on a `ScriptedVaultServer` and the mirror on `FakeSyncServer` —
/// two fakes where production has one Postgres. The world below WIRES
/// them the way the real server is wired (the sync fence's comparand IS
/// the vault row's corpus key id — a successful vault write moves the
/// comparand), and the lifecycle fake bridges the truncate to the fake
/// mirror. The REAL Postgres truth (the deployed RPCs, the FK order, the
/// auth-user removal) is the DDL pins + the gate's live probe.
@Suite("Account lifecycle doors (Phase 14c, batch 2)", .serialized)
struct AccountLifecycleTests {
    private static let passphrase = "orchard-lantern-13"

    /// The recording lifecycle fake: bridges `truncateAccountData` to the
    /// fake mirror (as the deployed RPC bridges it to Postgres), records
    /// every act into the shared event log, and can throw once (the
    /// failure-resume arm).
    private final class RecordingLifecycle: AccountLifecycleProviding, @unchecked Sendable {
        let server: FakeSyncServer
        let userID: String
        let events: LockIsolated<[String]>
        let purgeCalls = LockIsolated(0)
        let failNextTruncate = LockIsolated(false)

        init(server: FakeSyncServer, userID: String, events: LockIsolated<[String]>) {
            self.server = server
            self.userID = userID
            self.events = events
        }

        func truncateAccountData(activeKeyID: String, keyProof: String) async throws -> [String: Int] {
            events.withValue { $0.append("truncate:\(activeKeyID)") }
            if failNextTruncate.withValue({ value -> Bool in
                defer { value = false }
                return value
            }) {
                throw AccountLifecycleError.httpFailure(status: 503, body: "gateway hiccup")
            }
            // Through the fake's GATE (the real RPC's): the right key id
            // without the proof deletes nothing.
            try await server.truncateAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof)
            return [:]
        }

        func purgeAccount() async throws -> AccountPurgeReport {
            purgeCalls.withValue { $0 += 1 }
            await server.purgeAccount(userID)
            return AccountPurgeReport(
                dataRows: 0, vaultRows: 1, entitlementRows: 1, authUserRemoved: true)
        }

        func fetchEntitlements() async throws -> [AccountEntitlement] { [] }
    }

    /// One re-key world: a `SyncClient` fleet member over the fake mirror,
    /// a scripted vault whose SUCCESSFUL writes move the mirror's fence
    /// comparand (the one-Postgres wiring), and the recording lifecycle.
    private struct RekeyWorld {
        let server: FakeSyncServer
        let client: SyncClient
        let vault: ScriptedVaultServer
        let vaultClient: KeyVaultClient
        let enrollment: VaultEnrollment
        let lifecycle: RecordingLifecycle
        let events: LockIsolated<[String]>
        /// pre-13x: the vault row and the sync fence are ONE row — the
        /// vault's user IS the sync fake's default account.
        static let vaultUserID = FakeSyncServer.defaultUserID
    }

    private func makeRekeyWorld() async throws -> RekeyWorld {
        let server = FakeSyncServer()
        let client = try SyncClient(name: "A1", prefix: "AA", transport: server)
        let db = client.db
        let events = LockIsolated<[String]>([])
        // The one-Postgres wiring (pre-13x: BUILT INTO the linked fakes —
        // a vault CREATE provisions the mirror's fence comparand + proof
        // hash, and `key_vault_update` runs on the mirror's vault row):
        // the loader below only LOGS each successful write for the ORDER
        // pin. The event's `marker=` suffix records whether the persisted
        // rekey marker was set AT the write (ladder R1-1: the brain must
        // set it BEFORE the vault write, so a crash in every later window
        // leaves it behind).
        let vault = ScriptedVaultServer(syncServer: server)
        let vaultClient = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: RekeyWorld.vaultUserID)),
            load: { [weak vault, weak server] request in
                guard let vault, let server else { throw URLError(.cancelled) }
                let response = try await vault.load(request)
                if let method = request.httpMethod, method == "POST",
                   (response.1 as? HTTPURLResponse).map({ (200..<300).contains($0.statusCode) }) == true,
                   let row = vault.storedRow(userID: RekeyWorld.vaultUserID) {
                    let markerSet = (try? await db.read { try RotationMarker.isSet($0) }) ?? false
                    events.withValue {
                        $0.append("vault-write:\(row.corpusKeyID):marker=\(markerSet ? "set" : "clear")")
                    }
                }
                return response
            })
        let lifecycle = RecordingLifecycle(
            server: server, userID: FakeSyncServer.defaultUserID, events: events)
        return RekeyWorld(
            server: server, client: client, vault: vault, vaultClient: vaultClient,
            enrollment: VaultEnrollment(client: vaultClient), lifecycle: lifecycle,
            events: events)
    }

    private func keys(of material: DeviceKeyMaterial) -> SyncEncryptionKeys {
        SyncEncryptionKeys(
            corpusKey: material.corpusSymmetricKey, corpusKeyID: material.corpusKeyID,
            keyProof: KeyProof.wireToken(master: material.masterSymmetricKey))
    }

    /// Drain one client to an empty outbox (pull → push per A3).
    private func drain(_ client: SyncClient, maxRounds: Int = 12) async throws {
        for _ in 1...maxRounds {
            try await client.pull()
            try await client.push()
            if try client.outboxCount() == 0 { return }
        }
        throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
    }

    // (The 14c `AccountRekey` brain's six pins — the truncate road — retired
    // with the brain at pre-13x 2b: the rotation is IN PLACE now, and its
    // road is pinned in `CorpusRotationTests`.)

    // MARK: - Account deletion (L5)

    /// The deletion brain's authorization: a WRONG passphrase refuses and
    /// the purge is NEVER called (red-on-old by behavioral revert:
    /// removing the unwrap check purges anyway); the right passphrase
    /// authorizes and the purge runs.
    @Test func theDeletionDoorIsAuthorizedByThePassphraseBeforeThePurge() async throws {
        let world = try await makeRekeyWorld()
        _ = try await world.enrollment.setUp(passphrase: Self.passphrase)
        let deletion = AccountDeletion(client: world.vaultClient, lifecycle: world.lifecycle)

        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            try await deletion.run(passphrase: "not-the-passphrase")
        }
        #expect(world.lifecycle.purgeCalls.value == 0,
                "a refused authorization must never reach the purge")
        await #expect(throws: VaultEnrollmentError.emptyPassphrase) {
            try await deletion.run(passphrase: nil)
        }
        #expect(world.lifecycle.purgeCalls.value == 0,
                "a vault-holding account requires the passphrase — nil is not an arm")

        let report = try await deletion.run(passphrase: Self.passphrase)
        #expect(world.lifecycle.purgeCalls.value == 1)
        #expect(report.authUserRemoved)
    }

    /// PROVISIONAL (recorded): a VAULT-LESS account deletes on the typed
    /// confirmation + session alone — no passphrase exists to demand, and
    /// refusing would deny the deletion right to exactly the accounts
    /// with nothing synced.
    @Test func aVaultlessAccountDeletesWithoutAPassphrase() async throws {
        let world = try await makeRekeyWorld()  // no setUp — no vault
        let deletion = AccountDeletion(client: world.vaultClient, lifecycle: world.lifecycle)
        let report = try await deletion.run(passphrase: nil)
        #expect(world.lifecycle.purgeCalls.value == 1)
        #expect(report.authUserRemoved)
    }

    /// The post-purge backstop: a LINGERING device (the real world's
    /// JWT-until-expiry window) refuses at the fence's missing-vault arm —
    /// no post-deletion write can land, outbox intact.
    @Test func aLingeringDevicesRoundRefusesAtTheFenceAfterThePurge() async throws {
        let server = FakeSyncServer()
        let device = try SyncClient(name: "A1", prefix: "AA", transport: server)
        try device.with { ops, _ in
            _ = try ops.createPost(title: "pre-deletion", profile: .blog)
        }
        try await device.push()

        await server.purgeAccount(FakeSyncServer.defaultUserID)

        try device.with { ops, _ in
            _ = try ops.createPost(title: "typed after deletion", profile: .blog)
        }
        let outbox = try device.outboxCount()
        await #expect(throws: SyncError.encryptionKeysReplaced) { _ = try await device.push() }
        await #expect(throws: SyncError.encryptionKeysReplaced) { _ = try await device.pull() }
        #expect(try device.outboxCount() == outbox,
                "the refusal keeps local writing intact — the local copy survives, exactly her ruling's letter")
    }

    // MARK: - The production client's wire shape

    /// The lifecycle client classifies the fence marker into the SAME
    /// typed error as the sync transport (one CF-16 state, every door),
    /// retries exactly once on 401, and decodes the purge/entitlement
    /// shapes.
    @Test func theLifecycleClientClassifiesRetriesAndDecodes() async throws {
        let calls = LockIsolated<[String]>([])
        func client(
            _ respond: @escaping @Sendable (URLRequest, Int) -> (Int, String)
        ) -> AccountLifecycleClient {
            let ordinal = LockIsolated(0)
            return AccountLifecycleClient(
                configuration: SupabaseTransport.Configuration(
                    projectURL: URL(string: "https://mirror.test.invalid")!,
                    apiKey: "publishable-test-key"),
                sessionProvider: StaticSessionProvider(
                    session: UserSession(accessToken: "token-1", userID: "user-x")),
                load: { request in
                    let n = ordinal.withValue { v -> Int in v += 1; return v }
                    calls.withValue { $0.append("\(request.httpMethod ?? "?") \(request.url!.path)") }
                    let (status, body) = respond(request, n)
                    return (Data(body.utf8), HTTPURLResponse(
                        url: request.url!, statusCode: status,
                        httpVersion: "HTTP/1.1", headerFields: nil)!)
                })
        }

        // The fence marker → the CF-16 typed error, same as at sync.
        let fenced = client { _, _ in
            (400, #"{"message":"VARIORUM_STALE_KEY_FENCE: stale key id"}"#)
        }
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await fenced.truncateAccountData(activeKeyID: "old-id", keyProof: "proof")
        }
        // pre-13x: the proof's refusal classifies into ITS typed error —
        // the right key id without the proof deletes nothing.
        let proofless = client { _, _ in
            (400, #"{"message":"VARIORUM_KEY_PROOF_REQUIRED: no proof"}"#)
        }
        await #expect(throws: SyncError.keyProofRefused) {
            _ = try await proofless.truncateAccountData(activeKeyID: "new-id", keyProof: "")
        }

        // ONE 401 refresh-and-retry, then the decoded truncate counts.
        let retried = client { _, n in
            n == 1 ? (401, #"{"message":"JWT expired"}"#)
                   : (200, #"{"container": 3, "variant": 7}"#)
        }
        let counts = try await retried.truncateAccountData(activeKeyID: "new-id", keyProof: "proof")
        // The proof rides the BODY, never the URL.
        #expect(calls.value.allSatisfy { !$0.contains("key_proof") })
        #expect(counts == ["container": 3, "variant": 7])

        // The purge report decodes 1:1 with 09's jsonb keys.
        let purger = client { _, _ in
            (200, #"{"data_rows": 42, "vault_rows": 1, "entitlement_rows": 1, "auth_user_removed": true}"#)
        }
        let report = try await purger.purgeAccount()
        #expect(report == AccountPurgeReport(
            dataRows: 42, vaultRows: 1, entitlementRows: 1, authUserRemoved: true))

        // The entitlement read (the P-ii pattern): owner-filtered GET.
        calls.withValue { $0.removeAll() }
        let reader = client { request, _ in
            #expect(request.url!.query()?.contains("user_id=eq.user-x") == true,
                    "the read is owner-filtered")
            return (200, #"[{"feature": "hosted_sync", "expires_at": null, "source": "14c-deploy-seed"}]"#)
        }
        let entitlements = try await reader.fetchEntitlements()
        #expect(entitlements == [AccountEntitlement(
            feature: "hosted_sync", expiresAt: nil, source: "14c-deploy-seed")])
        #expect(calls.value == ["GET /rest/v1/entitlement"])
    }

    // MARK: - key_vault.updated_at (R2-1's declined one-liner, decided)

    /// Every vault UPDATE stamps `updated_at` truthfully (a re-key
    /// replaces the row's whole contents through this path — an
    /// insert-time-only stamp would mislead); the CREATE leaves it to the
    /// server default. Red-on-old: without the client write, the stored
    /// row's stamp stays nil through every update.
    @Test func vaultUpdatesStampUpdatedAtAndCreatesLeaveItToTheServer() async throws {
        let world = VaultTestWorld()
        let material = try await world.enrollment.setUp(passphrase: Self.passphrase)
        #expect(world.server.storedRow(userID: world.userID)?.updatedAt == nil,
                "the create omits the stamp — the server default covers the insert")

        let words = try RecoveryPhrase.generate()
        try await world.enrollment.landRecoveryWrap(words: words, material: material)
        #expect(world.server.storedRow(userID: world.userID)?.updatedAt != nil,
                "an update stamps updated_at — the row's timestamp stays truthful")
    }
}
