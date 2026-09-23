import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 14b, batch 2 — the seam's own pins (L4/L5): the key-provider
/// gating refuses visibly in the §12 grammar; the wire/mirror carry only
/// ciphertext while both LOCAL stores stay plaintext; the post-14b policy
/// (no plaintext mode) refuses an unencrypted arrival naming the row; and
/// the AAD binding makes a ciphertext swapped between rows refuse rather
/// than land. The crown assertion — the WHOLE existing convergence suite
/// set running green over ciphertext — is the suites themselves, bound to
/// the shared test key world by the harness default.
@Suite("E2EE seam & key gating (Phase 14b, batch 2)")
struct SyncEncryptionTests {
    // MARK: - L5: the visible refusal (the §12 lockstep-skew pin's shape)

    @Test func absentKeysRefuseBothHalvesWithOutboxCursorAndNetworkUntouchedThenHeal() async throws {
        let server = FakeSyncServer()
        let transport = CountingTransport(inner: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)

        // Seed real dirty state and a real cursor first, keys present.
        try a.with { ops, _ in
            _ = try ops.createPost(title: "before the lock", profile: .journal)
        }
        _ = try await a.push()
        _ = try await a.pull()
        let cursorBefore = try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        try a.with { ops, _ in
            _ = try ops.createPost(title: "written while locked", profile: .journal)
        }
        let outboxBefore = try a.outboxCount()
        #expect(outboxBefore > 0)
        let contactsBefore = await transport.contacts

        // The device locks (pre-enrollment / Keychain unavailable).
        a.keyProvider = LockedSyncKeyProvider()
        await #expect(throws: SyncError.encryptionKeysUnavailable) { _ = try await a.pull() }
        await #expect(throws: SyncError.encryptionKeysUnavailable) { _ = try await a.push() }

        #expect(try a.outboxCount() == outboxBefore,
                "the refusal keeps the outbox byte-intact")
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == cursorBefore,
                "the refusal never moves the cursor")
        #expect(await transport.contacts == contactsBefore,
                "keys are checked BEFORE any network contact — a locked device refuses for free")
        #expect(await server.rowCount(table: "container") == 1,
                "nothing was pushed past the refusal")

        // Enrollment completes (batch 3's flow) — the SAME client heals
        // with no state surgery, exactly like the §12 refusal.
        a.keyProvider = FixedSyncKeyProvider()
        _ = try await a.pull()
        _ = try await a.push()
        #expect(try a.outboxCount() == 0)
        #expect(await server.rowCount(table: "container") == 2)
    }

    @Test func theKeysRefusalIsVisibleAndNamesTheFixInTheStatusRow() async throws {
        let server = FakeSyncServer()
        let client = try SyncClient(name: "A", prefix: "AA", transport: server)
        let scheduler = SyncScheduler(engine: SyncEngine(
            transport: server, keyProvider: LockedSyncKeyProvider()))

        try await client.withAsync { _ in await scheduler.trigger() }
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.lastError?.contains("encryption passphrase") == true,
                "the refusal surfaces as a readable status NAMING THE FIX, not a case dump")
        #expect(status.lastErrorIsOffline == false,
                "locked keys are a real refusal, never presented as offline")
    }

    // MARK: - The seam end-to-end: ciphertext on the wire/mirror, plaintext
    // in every local store

    @Test func theMirrorStoresCiphertextWhileBothLocalStoresReadPlaintext() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "the plaintext title", profile: .journal)
            return try ops.newBlock(in: post.id, text: "The entry's prose.", at: .end).variant.id
        }
        try await syncToQuiescence(a, b, server: server)

        // The mirror's stored value is `e1:` ciphertext and never the words.
        let stored = await server.currentRow(table: "variant", rowID: variantID)
        guard case .text(let storedText)? = stored?.columns["working_text"] else {
            Issue.record("no stored working_text")
            return
        }
        #expect(PayloadCipher.isEncrypted(storedText))
        #expect(storedText != "The entry's prose.")
        #expect(try SyncTestKeys.openedText(stored, column: "working_text")
                == "The entry's prose.")

        // Both LOCAL stores are plaintext (the E2EE boundary is the
        // network/server — THE DESIGN's "what encrypts, where").
        for client in [a, b] {
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [variantID])
                == "The entry's prose.", "\(client.name) local store must be plaintext")
        }
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - The post-14b policy: no plaintext mode

    /// A non-`e1:` value arriving in an encrypted-classified column refuses
    /// the ROUND with a typed error naming table/row — wipe-and-repush
    /// (R-2) guarantees this never fires in practice; firing signals a real
    /// fault, and failing visible beats passing through silently.
    @Test func aPlaintextArrivalInAnEncryptedColumnRefusesTheRoundNamingTheRow() async throws {
        let server = FakeSyncServer()
        let b = try SyncClient(name: "B", prefix: "BB", transport: server)
        // A pre-14b writer's row: plaintext title, pushed straight to the
        // dumb server (which cannot tell — SyncSpec §2).
        let plaintextRow = SyncRow(
            table: "container", rowID: "c-pre14b",
            columns: [
                // Phase 14c: owned by the caller — the born-multi-tenant
                // mirror has no unowned partition to push into (the
                // isolation round's I-2 arm). What this row still models is
                // the pre-14b PLAINTEXT value, which is what the pull under
                // test refuses.
                "id": .text("c-pre14b"),
                "owner_id": .text(FakeSyncServer.defaultUserID), "kind": .text("post"),
                "title": .text("bare plaintext"), "profile": .null, "entry_date": .null,
                "locked": .integer(0), "locked_at": .null, "floating_notes": .null,
                "segmentation_default": .null, "last_touched_at": .null,
                "last_major_revision_at": .null, "churn_accumulator": .real(0),
                "baseline_length": .integer(0), "created_at": .text(Fixture.now),
                "updated_at": .text(Fixture.now), "archived_at": .null,
                "deleted_at": .null,
            ],
            syncVersion: 0)
        _ = try await server.push([plaintextRow], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        let outboxBefore = try b.outboxCount()
        await #expect(throws: SyncError.unencryptedValueInEncryptedColumn(
            table: "container", rowID: "c-pre14b", column: "title")) {
            _ = try await b.pull()
        }
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container") == 0,
                "nothing unverified lands")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == nil,
                "the cursor never moves past a refusal")
        #expect(try b.outboxCount() == outboxBefore, "the outbox is untouched")
    }

    /// The AAD binding end-to-end: a ciphertext lifted from one row and
    /// replayed under another row's id fails authentication and refuses the
    /// round — ids stay plaintext on the mirror, yet values cannot be
    /// swapped between rows undetected.
    @Test func aCiphertextSwappedBetweenRowsRefusesByAADBinding() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let (postOne, postTwo): (String, String) = try a.with { ops, _ in
            (try ops.createPost(title: "the private title", profile: nil).id,
             try ops.createPost(title: "the public title", profile: nil).id)
        }
        try await a.push()

        // The swap: post two's row re-pushed carrying post ONE's title
        // ciphertext (a dumb server accepts it; CAS is satisfied).
        let one = await server.currentRow(table: "container", rowID: postOne)!
        var two = await server.currentRow(table: "container", rowID: postTwo)!
        two.columns["title"] = one.columns["title"]
        _ = try await server.push([two], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        do {
            _ = try await b.pull()
            Issue.record("the swapped ciphertext must refuse the round")
        } catch let error as SyncError {
            guard case .payloadCryptoFailure(let table, let rowID, let column, _) = error else {
                Issue.record("wrong refusal: \(error)")
                return
            }
            #expect(table == "container")
            #expect(rowID == postTwo)
            #expect(column == "title")
        }
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container") == 0,
                "nothing from the poisoned batch lands (one transaction, refused whole)")
    }

    // MARK: - Seal-side totality

    /// An encrypted-classified column can only carry text (or NULL): a
    /// number smuggled in by SQLite's flexible typing refuses loudly at the
    /// seam rather than inventing an encoding (the blobInPayload doctrine).
    @Test func aNonTextValueInAnEncryptedColumnRefusesToSeal() throws {
        let crypto = SyncPayloadCrypto(keys: SyncTestKeys.keys)
        let row = SyncRow(
            table: "container", rowID: "c1",
            columns: ["id": .text("c1"), "title": .integer(42)],
            syncVersion: 0)
        #expect(throws: SyncError.payloadCryptoFailure(
            table: "container", rowID: "c1", column: "title",
            detail: "non-text value in an encrypted-classified column")) {
            _ = try crypto.encryptForWire(row)
        }
        // And NULL passes untouched in both directions — absence is
        // disclosed structure, not text.
        let nullRow = SyncRow(
            table: "container", rowID: "c1",
            columns: ["id": .text("c1"), "title": .null],
            syncVersion: 0)
        #expect(try crypto.encryptForWire(nullRow) == nullRow)
        #expect(try crypto.decryptFromWire(nullRow) == nullRow)
    }
}

/// Counts every transport contact — the keys-first refusal must make NONE.
actor CountingTransport: SyncTransport {
    private let inner: FakeSyncServer
    private(set) var contacts = 0

    init(inner: FakeSyncServer) {
        self.inner = inner
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        contacts += 1
        return try await inner.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        contacts += 1
        return try await inner.pull(since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof, deviceID: deviceID)
    }

    func schemaVersion() async throws -> Int {
        contacts += 1
        return await inner.schemaVersion()
    }

    // 13y UNIT B: the challenge surface forwards transparently
    // (wrappers forward — the standing doctrine).
    func fetchChallenges(_ count: Int) async throws -> [String] {
        try await inner.fetchChallenges(count)
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        try await inner.enrollKeyProof(
            legacyProof: legacyProof, macKey: macKey, activeKeyID: activeKeyID)
    }
}
