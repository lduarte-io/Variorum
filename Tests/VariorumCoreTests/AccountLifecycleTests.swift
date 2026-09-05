import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 14c batch 2 (L4/L5) — the account lifecycle doors' brains:
/// CF-8's re-key ORDER OF OPERATIONS (the safety design, pinned), the
/// re-key road end to end in the two-fake harness, the failure-resume
/// road, the deletion door's passphrase authorization, and the
/// post-purge fence backstop.
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

        func truncateAccountData(activeKeyID: String) async throws -> [String: Int] {
            events.withValue { $0.append("truncate:\(activeKeyID)") }
            if failNextTruncate.withValue({ value -> Bool in
                defer { value = false }
                return value
            }) {
                throw AccountLifecycleError.httpFailure(status: 503, body: "gateway hiccup")
            }
            await server.truncateAccount(userID)
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
        static let vaultUserID = "user-rekey-test"
    }

    private func makeRekeyWorld() async throws -> RekeyWorld {
        let server = FakeSyncServer()
        let client = try SyncClient(name: "A1", prefix: "AA", transport: server)
        let db = client.db
        let events = LockIsolated<[String]>([])
        let vault = ScriptedVaultServer()
        // The one-Postgres wiring: a successful vault POST/PATCH moves the
        // sync fence's comparand to the row's corpus key id — exactly what
        // writing the real key_vault row does — and logs the write for the
        // ORDER pin. The event's `marker=` suffix records whether the
        // persisted rekey marker was set AT the write (ladder R1-1: the
        // brain must set it BEFORE the vault write, so a crash in every
        // later window leaves it behind).
        let vaultClient = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: RekeyWorld.vaultUserID)),
            load: { [weak vault, weak server] request in
                guard let vault, let server else { throw URLError(.cancelled) }
                let response = try await vault.load(request)
                if let method = request.httpMethod, method == "POST" || method == "PATCH",
                   (response.1 as? HTTPURLResponse).map({ (200..<300).contains($0.statusCode) }) == true,
                   String(data: response.0, encoding: .utf8) != "[]",
                   let row = vault.storedRow(userID: RekeyWorld.vaultUserID) {
                    await server.setVaultCorpusKeyID(row.corpusKeyID)
                    let markerSet = (try? await db.read { try AccountRekeyMarker.isSet($0) }) ?? false
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
            corpusKey: material.corpusSymmetricKey, corpusKeyID: material.corpusKeyID)
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

    private func brain(
        _ world: RekeyWorld,
        onNewVaultMaterial: (@Sendable (DeviceKeyMaterial) async -> Void)? = nil
    ) -> AccountRekey {
        AccountRekey(
            client: world.vaultClient, lifecycle: world.lifecycle,
            transport: world.server, database: world.client.db,
            deviceID: world.client.deviceID,
            onNewVaultMaterial: onNewVaultMaterial)
    }

    // MARK: - CF-8: the order of operations IS the safety design

    /// THE ORDER PIN: the NEW vault is written FIRST, the truncate runs
    /// second and PRESENTS the new corpus key id (the fence's comparand —
    /// only the freshly-written vault's holder can empty the account),
    /// and custody is handed to the caller BETWEEN the two. Red-on-old by
    /// behavioral revert: swapping the brain's vault-write and truncate
    /// steps fails the order assertion below.
    @Test func theRekeyWritesTheNewVaultFirstAndTruncatesUnderTheNewKeyID() async throws {
        let world = try await makeRekeyWorld()
        let old = try await world.enrollment.setUp(passphrase: Self.passphrase)
        world.events.withValue { $0.removeAll() }  // setup's own vault-write

        let adopted = LockIsolated<DeviceKeyMaterial?>(nil)
        let material = try await brain(world, onNewVaultMaterial: { m in
            adopted.setValue(m)
        }).run(passphrase: Self.passphrase)

        let events = world.events.value
        let vaultWrite = try #require(
            events.firstIndex { $0.hasPrefix("vault-write:") },
            "the re-key must write the new vault")
        let truncate = try #require(
            events.firstIndex { $0.hasPrefix("truncate:") },
            "the re-key must truncate the account")
        #expect(vaultWrite < truncate,
                "THE ORDER: the new vault lands BEFORE the truncate — every stale writer is fenced before any row is deleted (C-3)")
        #expect(events[vaultWrite] == "vault-write:\(material.corpusKeyID):marker=set",
                "the vault write carries the NEW corpus key id — and the persisted rekey marker was ALREADY SET at that instant (ladder R1-1: marker before vault write, so every crash window from 2→3 onward leaves it behind)")
        #expect(events[truncate] == "truncate:\(material.corpusKeyID)",
                "the truncate presents the NEW key id — the fence's requirement")
        #expect(material.corpusKeyID != old.corpusKeyID,
                "a re-key mints a genuinely fresh corpus key")
        #expect(material.journalBridgeKeyID != old.journalBridgeKeyID,
                "…and a fresh journal-bridge key")
        #expect(adopted.value == material,
                "custody is handed over mid-run, before the truncate")

        // The new vault carries NO recovery wrap — the surface lands in
        // the standing CF-5 mandatory-phrase step.
        let fetched = try #require(try await world.vaultClient.fetchVault())
        #expect(fetched.format.masterWrappedByRecovery == nil)
        #expect(fetched.format.classKey(for: .corpus)?.keyID == material.corpusKeyID)

        // Ladder R1-1: a COMPLETED road clears the persisted marker.
        let markerAfter = try await world.client.db.read { try AccountRekeyMarker.isSet($0) }
        #expect(!markerAfter, "the marker clears only when the whole road completes — and it did")
    }

    /// A WRONG passphrase refuses the whole act with NOTHING touched: no
    /// vault write, no truncate, no re-enqueue.
    @Test func aWrongPassphraseRefusesTheRekeyWithNothingTouched() async throws {
        let world = try await makeRekeyWorld()
        let old = try await world.enrollment.setUp(passphrase: Self.passphrase)
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: old))
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "hers", profile: .journal)
        }
        try await drain(world.client)
        world.events.withValue { $0.removeAll() }
        let rowsBefore = await world.server.rowCount(table: "container")
        #expect(rowsBefore > 0)

        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            try await brain(world).run(passphrase: "not-the-passphrase")
        }
        #expect(world.events.value.isEmpty, "no vault write, no truncate")
        #expect(await world.server.rowCount(table: "container") == rowsBefore)
        #expect(try world.client.outboxCount() == 0, "no re-enqueue either")
        // Ladder R1-1: the marker is written AFTER authorization — a
        // refused passphrase leaves no rekey-in-progress residue.
        let markerSet = try await world.client.db.read { try AccountRekeyMarker.isSet($0) }
        #expect(!markerSet, "a refused authorization never sets the marker")
    }

    // MARK: - The re-key road, end to end

    /// The whole CF-8 road through the REAL brain: corpus authored and
    /// synced under the old key → re-key → the mirror is emptied and the
    /// re-enqueued corpus drains re-sealed under the NEW key (the old key
    /// provably unable to open it); a stale writer holding the OLD keys
    /// refuses both round halves with the CF-16 state, outbox intact.
    /// (The bridge-staging leg left with the bridge, 2026-09-04.)
    @Test func theRekeyRoadReSealsTheCorpusAndFencesStaleWriters() async throws {
        let world = try await makeRekeyWorld()
        let old = try await world.enrollment.setUp(passphrase: Self.passphrase)
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: old))

        try world.client.with { ops, _ in
            let post = try ops.createPost(title: "Before the re-key", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Old-key era prose.", at: .end)
        }
        try await drain(world.client)
        #expect(await world.server.rowCount(table: "container") > 0)

        // A second device still holding the OLD keys, with pending work.
        let stale = try SyncClient(
            name: "A2", prefix: "AB", transport: world.server, clockOffset: 313, seed: 2)
        stale.keyProvider = FixedSyncKeyProvider(keys: keys(of: old))
        try stale.with { ops, _ in
            _ = try ops.createPost(title: "typed while stale", profile: .journal)
        }
        let staleOutbox = try stale.outboxCount()
        #expect(staleOutbox > 0)

        // THE RE-KEY.
        let material = try await brain(world, onNewVaultMaterial: { _ in }).run(
            passphrase: Self.passphrase)

        // Right after the brain: mirror emptied, everything re-enqueued.
        #expect(await world.server.rowCount(table: "container") == 0)
        let expectedRows = try await world.client.db.read { db in
            var total = 0
            for table in SyncSchema.tables {
                total += try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table.name)") ?? 0
            }
            return total
        }
        #expect(try world.client.outboxCount() == expectedRows,
                "resyncReinitialize re-enqueued EVERY synced row")

        // THE FENCE: the stale device refuses BOTH halves, outbox intact.
        await #expect(throws: SyncError.encryptionKeysReplaced) { _ = try await stale.push() }
        await #expect(throws: SyncError.encryptionKeysReplaced) { _ = try await stale.pull() }
        #expect(try stale.outboxCount() == staleOutbox)

        // The drain (the app scheduler's job — driven by hand here): the
        // corpus re-arrives sealed under the NEW key only.
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: material))
        try await drain(world.client)
        #expect(try world.client.outboxCount() == 0)
        let repushed = await world.server.storedRows(for: FakeSyncServer.defaultUserID)
        let sealedTexts = repushed.filter { $0.table == "variant" }.compactMap { row -> (String, String)? in
            guard case .text(let value)? = row.columns["working_text"] else { return nil }
            return (row.rowID, value)
        }
        #expect(!sealedTexts.isEmpty)
        for (rowID, sealed) in sealedTexts {
            #expect(PayloadCipher.isEncrypted(sealed))
            #expect(try PayloadCipher.open(
                sealed, key: material.corpusSymmetricKey,
                binding: .init(table: "variant", rowID: rowID,
                               column: "working_text", keyID: material.corpusKeyID))
                == "Old-key era prose.")
            #expect(throws: (any Error).self, "the OLD key must no longer open the corpus") {
                _ = try PayloadCipher.open(
                    sealed, key: old.corpusSymmetricKey,
                    binding: .init(table: "variant", rowID: rowID,
                                   column: "working_text", keyID: old.corpusKeyID))
            }
        }
    }

    /// THE RESUME ROAD (the sequence is not atomic — pinned): a truncate
    /// that fails mid-run leaves the NEW vault live (this device already
    /// enrolled through the mid-run handoff), and RUNNING THE DOOR AGAIN
    /// completes the whole road.
    @Test func aFailedTruncateLeavesTheRerunRoadThatCompletes() async throws {
        let world = try await makeRekeyWorld()
        let old = try await world.enrollment.setUp(passphrase: Self.passphrase)
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: old))
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "resumable", profile: .blog)
        }
        try await drain(world.client)

        world.lifecycle.failNextTruncate.setValue(true)
        let adopted = LockIsolated<DeviceKeyMaterial?>(nil)
        await #expect(throws: AccountLifecycleError.httpFailure(
            status: 503, body: "gateway hiccup")
        ) {
            try await brain(world, onNewVaultMaterial: { m in adopted.setValue(m) })
                .run(passphrase: Self.passphrase)
        }
        // The failure's honest residue: the new vault is live (stale
        // writers fenced), custody was already handed over, the mirror
        // still holds old-key rows — exactly what the rerun heals. And
        // (ladder R1-1) the persisted marker is STILL SET: the rerun
        // road survives a relaunch, not just this session's error string.
        let interim = try #require(adopted.value)
        let vaultNow = try #require(try await world.vaultClient.fetchVault())
        #expect(vaultNow.format.classKey(for: .corpus)?.keyID == interim.corpusKeyID)
        #expect(await world.server.rowCount(table: "container") > 0,
                "the failed truncate left the old rows — the wedge the rerun clears")
        let markerMidRoad = try await world.client.db.read { try AccountRekeyMarker.isSet($0) }
        #expect(markerMidRoad,
                "a mid-run failure leaves the marker set — the persisted rerun prompt (R1-1)")

        // THE RERUN: same passphrase (it unwraps the NEW vault), full road.
        let final = try await brain(world, onNewVaultMaterial: { _ in })
            .run(passphrase: Self.passphrase)
        #expect(await world.server.rowCount(table: "container") == 0)
        #expect(try world.client.outboxCount() > 0)
        let markerHealed = try await world.client.db.read { try AccountRekeyMarker.isSet($0) }
        #expect(!markerHealed, "the completed rerun clears the marker (R1-1)")
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: final))
        try await drain(world.client)
        #expect(try world.client.outboxCount() == 0)
    }

    /// Ladder R1-1 (MAJOR), the crash-window closure: the marker a
    /// mid-run crash leaves behind refuses BOTH round halves across a
    /// RELAUNCH — outbox intact, cursor unmoved, nothing reaching the
    /// mirror — and the completed door clears it, after which rounds
    /// drain again. (Every `push()`/`pull()` below builds a FRESH engine
    /// over the same store: that IS the relaunch shape.) The pre-fix
    /// silent windows this closes, traced at review round 1: a
    /// truncated-but-not-reinitialized mirror read idle while near-empty
    /// (clean rows never re-enqueue; dirty rows self-heal via the
    /// nil-current rebase), and an untruncated old-key corpus synced on
    /// quietly, poisoning every later enrollment. RED-ON-OLD by
    /// behavioral revert: with the engine's marker check removed, both
    /// refusal expectations fail (the rounds proceed).
    @Test func theRekeyMarkerRefusesRoundsAcrossRelaunchUntilTheDoorCompletes() async throws {
        let world = try await makeRekeyWorld()
        let old = try await world.enrollment.setUp(passphrase: Self.passphrase)
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: old))
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "before the crash", profile: .blog)
        }
        try await drain(world.client)

        // The state a crash leaves: the marker set (as the brain persists
        // it before its vault write) plus whatever was in flight.
        try await world.client.db.write { db in try AccountRekeyMarker.set(db) }
        try world.client.with { ops, _ in
            _ = try ops.createPost(title: "typed after the crash", profile: .journal)
        }
        let outboxBefore = try world.client.outboxCount()
        #expect(outboxBefore > 0)
        let cursorBefore = try await world.client.db.read { db in
            try String.fetchOne(
                db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        }
        let serverRows = await world.server.rowCount(table: "container")

        await #expect(throws: SyncError.accountRekeyIncomplete) {
            _ = try await world.client.push()
        }
        await #expect(throws: SyncError.accountRekeyIncomplete) {
            _ = try await world.client.pull()
        }
        #expect(try world.client.outboxCount() == outboxBefore,
                "outbox intact — nothing is lost while paused")
        let cursorAfter = try await world.client.db.read { db in
            try String.fetchOne(
                db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        }
        #expect(cursorAfter == cursorBefore, "cursor unmoved — the §12 refusal grammar")
        #expect(await world.server.rowCount(table: "container") == serverRows,
                "no write reached the mirror past the marker")

        // THE DOOR COMPLETES: the full brain run clears the marker and
        // the drain proceeds under the new keys.
        let material = try await brain(world, onNewVaultMaterial: { _ in })
            .run(passphrase: Self.passphrase)
        let markerAfter = try await world.client.db.read { try AccountRekeyMarker.isSet($0) }
        #expect(!markerAfter, "the completed road clears the marker")
        world.client.keyProvider = FixedSyncKeyProvider(keys: keys(of: material))
        try await drain(world.client)
        #expect(try world.client.outboxCount() == 0, "rounds drain again once the road completes")
    }

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
            _ = try await fenced.truncateAccountData(activeKeyID: "old-id")
        }

        // ONE 401 refresh-and-retry, then the decoded truncate counts.
        let retried = client { _, n in
            n == 1 ? (401, #"{"message":"JWT expired"}"#)
                   : (200, #"{"container": 3, "variant": 7}"#)
        }
        let counts = try await retried.truncateAccountData(activeKeyID: "new-id")
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
