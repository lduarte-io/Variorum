import CryptoKit
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 14c, batch 1 (L3) — THE TWO-USER CONVERGENCE SUITES: the Phase 5
/// harness's second axis (two USERS × two devices each), per the sitting's
/// ruled proof bar. Each user's fleet converges independently over
/// ciphertext; zero cross-user rows flow through either RPC door; repairs
/// stay inside the partition; settings are scoped per account; a
/// stranger's corpus is exactly as unreadable as hers; the vault-key-id
/// fence refuses a stale writer with the CF-16 state; the entitlement
/// gate refuses an unentitled account visibly.
///
/// EMULATION CAVEAT (recorded per the batch brief, in force for every
/// test below): the fake server EMULATES the 09 mirror's Postgres
/// semantics — partitioned storage stands in for the composite
/// (owner_id, id) PK, Swift guards stand in for the RPC's RAISEs and the
/// forced-RLS policies. The REAL Postgres truth is proven at the gate's
/// integration pass + the live stranger-sees-zero probes with the
/// provisioned second account (the plan's ruled proof bar).
@Suite("Two-user convergence (Phase 14c, batch 1 — the second axis)")
struct MultiTenantSyncTests {
    // MARK: - The two accounts' worlds

    /// User A is the fake's default account (the suite key world — "her").
    private static let userA = FakeSyncServer.defaultUserID
    /// User B — "the stranger": own uid, own vault, OWN corpus key.
    private static let userB = "00000000-bbbb-4bbb-8ccc-000000000002"

    /// The stranger's key world: a DIFFERENT corpus key and key id, fixed
    /// for the same reasons as `SyncTestKeys` (assertions never depend on
    /// the key; a fixed key lets a test seal a crafted row exactly as B's
    /// seam would).
    enum StrangerKeys {
        static let corpusKeyID = "test-corpus-key-USERB-0000000002"
        static let corpusKey = SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x80) }))
        static let keys = SyncEncryptionKeys(corpusKey: corpusKey, corpusKeyID: corpusKeyID)

        static func seal(
            _ plaintext: String, table: String, rowID: String, column: String
        ) throws -> String {
            try PayloadCipher.seal(
                plaintext, key: corpusKey,
                binding: .init(table: table, rowID: rowID, column: column, keyID: corpusKeyID))
        }
    }

    private struct TwoUserWorld {
        let server: FakeSyncServer
        let a1: SyncClient
        let a2: SyncClient
        let b1: SyncClient
        let b2: SyncClient
    }

    /// Two users × two devices. A's devices ride the fake's default-user
    /// conformance (the single-user suites' exact shape); B's ride
    /// per-user connections — the fake twin of "authenticated as B".
    private func makeWorld() async throws -> TwoUserWorld {
        let server = FakeSyncServer()
        await server.provisionAccount(
            Self.userB, vaultCorpusKeyID: StrangerKeys.corpusKeyID)
        let a1 = try SyncClient(name: "A1", prefix: "AA", transport: server)
        let a2 = try SyncClient(
            name: "A2", prefix: "AB", transport: server, clockOffset: 313, seed: 2)
        let b1 = try SyncClient(
            name: "B1", prefix: "BA",
            transport: server.connection(as: Self.userB), clockOffset: 977, seed: 3)
        let b2 = try SyncClient(
            name: "B2", prefix: "BB",
            transport: server.connection(as: Self.userB), clockOffset: 1291, seed: 4)
        for b in [b1, b2] {
            b.ownerID = Self.userB
            b.keyProvider = FixedSyncKeyProvider(keys: StrangerKeys.keys)
        }
        return TwoUserWorld(server: server, a1: a1, a2: a2, b1: b1, b2: b2)
    }

    /// One FLEET's quiescence (two devices of one user). The shared
    /// `syncToQuiescence` compares cursors against the GLOBAL head seq,
    /// which no longer holds when another tenant owns the head — a
    /// user's cursor legitimately rests at their OWN partition's last
    /// seq. Quiet = both outboxes empty and one full round applies,
    /// merges, and repairs nothing on either device.
    @discardableResult
    private func fleetQuiesce(
        _ x: SyncClient, _ y: SyncClient, maxRounds: Int = 12
    ) async throws -> Int {
        for round in 1...maxRounds {
            try await x.push()
            try await y.push()
            let px = try await x.pull()
            let py = try await y.pull()
            let quiet = try x.outboxCount() == 0 && y.outboxCount() == 0
                && px.applied + px.merged + px.repairs == 0 && !px.stalled
                && py.applied + py.merged + py.repairs == 0 && !py.stalled
            if quiet { return round }
        }
        throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
    }

    // MARK: - The crown: independent convergence, zero cross-user rows

    @Test func twoFleetsConvergeIndependentlyOverCiphertextWithZeroCrossUserRows() async throws {
        let world = try await makeWorld()

        // Each user authors on both devices — real prose, distinct worlds.
        try world.a1.with { ops, _ in
            let post = try ops.createPost(title: "A's desk notes", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Her words, hers alone.", at: .end)
        }
        try world.a2.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-08-04").container
            _ = try ops.newBlock(in: entry.id, text: "A's phone thought.", at: .end)
        }
        try world.b1.with { ops, _ in
            let post = try ops.createPost(title: "B's manuscript", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "The stranger's own prose.", at: .end)
        }
        try world.b2.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-08-04").container
            _ = try ops.newBlock(in: entry.id, text: "B's phone thought.", at: .end)
        }

        try await fleetQuiesce(world.a1, world.a2)
        try await fleetQuiesce(world.b1, world.b2)
        // A second A round AFTER B's activity: B's pushes moved the global
        // head, and A must neither receive them nor destabilize.
        try await fleetQuiesce(world.a1, world.a2)

        // Each fleet converged byte-identical — independently.
        #expect(try world.a1.syncedDump() == world.a2.syncedDump())
        #expect(try world.b1.syncedDump() == world.b2.syncedDump())
        #expect(try world.a1.syncedDump() != world.b1.syncedDump(),
                "two tenants' corpora are different worlds")

        // ZERO cross-user rows through the pull door: no B container id
        // exists in any A store, and vice versa.
        let bContainerIDs = try await world.b1.db.read {
            try String.fetchAll($0, sql: "SELECT id FROM container")
        }
        let aContainerIDs = try await world.a1.db.read {
            try String.fetchAll($0, sql: "SELECT id FROM container")
        }
        #expect(!bContainerIDs.isEmpty && !aContainerIDs.isEmpty)
        for db in [world.a1.db, world.a2.db] {
            for id in bContainerIDs {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM container WHERE id = ?", [id]) == 0,
                    "a stranger's row must NEVER reach A's store")
            }
        }
        for db in [world.b1.db, world.b2.db] {
            for id in aContainerIDs {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM container WHERE id = ?", [id]) == 0,
                    "her rows must NEVER reach B's store")
            }
        }

        // The server partitions hold exactly each user's rows.
        #expect(await world.server.rowCount(table: "container", for: Self.userA)
                == aContainerIDs.count)
        #expect(await world.server.rowCount(table: "container", for: Self.userB)
                == bContainerIDs.count)

        // The 14b mirror-dump assertion, now spanning BOTH tenants: every
        // encrypted-classified value stored server-side is ciphertext —
        // structure visible, words never, for every account alike.
        for row in await world.server.allStoredRows {
            guard let table = SyncSchema.table(named: row.table) else { continue }
            for column in table.encryptedColumns {
                if case .text(let value)? = row.columns[column] {
                    #expect(PayloadCipher.isEncrypted(value),
                            "\(row.table).\(column) stored plaintext for row \(row.rowID)")
                }
            }
        }
    }

    /// The stranger-corpus-unreadable assertion (the ruled proof bar's
    /// E2EE carry-forward): A's stored ciphertext opens with A's key and
    /// REFUSES with B's — wrong key AND wrong AAD key id alike.
    @Test func aStrangersStoredCorpusIsExactlyAsUnreadableAsHers() async throws {
        let world = try await makeWorld()
        let variantID: String = try world.a1.with { ops, _ in
            let post = try ops.createPost(title: "hers", profile: .journal)
            return try ops.newBlock(in: post.id, text: "Words only A may read.", at: .end).variant.id
        }
        try await world.a1.push()

        let stored = await world.server.currentRow(
            table: "variant", rowID: variantID, for: Self.userA)
        guard case .text(let wire)? = stored?.columns["working_text"] else {
            Issue.record("A's variant must be on the mirror")
            return
        }
        #expect(PayloadCipher.isEncrypted(wire))
        // A's key opens it.
        #expect(try SyncTestKeys.open(
            wire, table: "variant", rowID: variantID, column: "working_text")
            == "Words only A may read.")
        // B's key — B's whole key WORLD — cannot.
        #expect(throws: (any Error).self, "the stranger's key must never open her value") {
            _ = try PayloadCipher.open(
                wire, key: StrangerKeys.corpusKey,
                binding: .init(
                    table: "variant", rowID: variantID,
                    column: "working_text", keyID: StrangerKeys.corpusKeyID))
        }
        // Even B's key under A's AAD binding (a hypothetical exfiltrated
        // binding) fails — the key itself is wrong.
        #expect(throws: (any Error).self) {
            _ = try PayloadCipher.open(
                wire, key: StrangerKeys.corpusKey,
                binding: .init(
                    table: "variant", rowID: variantID,
                    column: "working_text", keyID: SyncTestKeys.corpusKeyID))
        }
    }

    // MARK: - Composite identity: colliding ids, separate partitions

    /// The clean rebuild's letter: identity is (owner_id, id), so the SAME
    /// row id under two accounts is two unrelated rows — no CAS
    /// interference (both insert at base 0 → version 1), each user pulls
    /// their own. Under the pre-14c single-keyspace mirror the second
    /// push would have CAS-fought the first (rejected at base 0) — the
    /// red-on-old shape, verified by behavioral revert on the fake's
    /// partitioning (see the batch record).
    @Test func collidingRowIDsLandInSeparatePartitionsWithIndependentCAS() async throws {
        let world = try await makeWorld()
        let sharedID = "5haredc0-1111-4222-8333-444444444444"

        func containerRow(owner: String, sealedTitle: String) -> SyncRow {
            SyncRow(
                table: "container", rowID: sharedID,
                columns: [
                    "id": .text(sharedID), "owner_id": .text(owner),
                    "kind": .text("post"), "title": .text(sealedTitle),
                    "profile": .null, "entry_date": .null,
                    "locked": .integer(0), "locked_at": .null, "floating_notes": .null,
                    "segmentation_default": .null, "last_touched_at": .null,
                    "last_major_revision_at": .null, "churn_accumulator": .real(0),
                    "baseline_length": .integer(0), "word_target": .null,
                    "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                    "archived_at": .null, "deleted_at": .null,
                ],
                syncVersion: 0)
        }

        // Both users push the SAME id, each sealed under their own key.
        let aOutcome = try await world.server.push(
            [containerRow(
                owner: Self.userA,
                sealedTitle: try SyncTestKeys.seal(
                    "A's title", table: "container", rowID: sharedID, column: "title"))],
            activeKeyID: SyncTestKeys.corpusKeyID)
        let bOutcome = try await world.server.push(
            [containerRow(
                owner: Self.userB,
                sealedTitle: try StrangerKeys.seal(
                    "B's title", table: "container", rowID: sharedID, column: "title"))],
            activeKeyID: StrangerKeys.corpusKeyID, as: Self.userB)

        // Independent CAS: BOTH accepted as fresh inserts at version 1 —
        // no cross-tenant collision, improbable made impossible.
        guard case .accepted(let aVersion, _) = aOutcome[0],
              case .accepted(let bVersion, _) = bOutcome[0] else {
            Issue.record("both same-id pushes must accept — identity is (owner, id)")
            return
        }
        #expect(aVersion == 1)
        #expect(bVersion == 1)

        // Each fleet pulls ITS OWN row — same id, different worlds.
        _ = try await world.a1.pull()
        _ = try await world.b1.pull()
        #expect(try world.a1.db.fetchString(
            "SELECT title FROM container WHERE id = ?", [sharedID]) == "A's title")
        #expect(try world.b1.db.fetchString(
            "SELECT title FROM container WHERE id = ?", [sharedID]) == "B's title")
    }

    // MARK: - Scoped settings (the L2 subsumed redesign's proof)

    /// The `setting` table's 14c redesign: (owner_id, key) identity means
    /// two users' SAME setting key never CAS-fight. RED-ON-OLD: under the
    /// pre-14c shared keyspace, B's base-0 push of the key A already
    /// pushed was REJECTED, the metadata merge adopted A's value, and B's
    /// fleet converged to A's preference (verified by behavioral revert
    /// on the fake's partitioning — the batch record).
    @Test func twoUsersSettingsAreScopedAndNeverCASFight() async throws {
        let world = try await makeWorld()

        try world.a1.with { ops, _ in try ops.setSeamsVisible(true) }
        try world.b1.with { ops, _ in try ops.setSeamsVisible(false) }

        try await fleetQuiesce(world.a1, world.a2)
        try await fleetQuiesce(world.b1, world.b2)

        // Each user's OTHER device converged to their OWN preference.
        #expect(try world.a2.db.fetchString(
            "SELECT value FROM setting WHERE key = 'seams_visible'") == "1",
            "A's fleet keeps A's setting")
        #expect(try world.b2.db.fetchString(
            "SELECT value FROM setting WHERE key = 'seams_visible'") == "0",
            "B's fleet keeps B's setting — never A's (the CAS-fight class, closed)")

        // Server-side: one row per PARTITION, each at its own version 1
        // (no cross-tenant CAS ever fired).
        let aRow = await world.server.currentRow(
            table: "setting", rowID: "seams_visible", for: Self.userA)
        let bRow = await world.server.currentRow(
            table: "setting", rowID: "seams_visible", for: Self.userB)
        #expect(aRow?.columns["value"] == .text("1"))
        #expect(bRow?.columns["value"] == .text("0"))
        #expect(aRow?.syncVersion == 1)
        #expect(bRow?.syncVersion == 1, "B's insert was FRESH — no reject, no rebase")
    }

    // MARK: - Repairs stay in-partition

    /// The tag.path duplicate repair (SyncSpec §7) runs INSIDE a user's
    /// partition and never reaches across: A's two devices race the same
    /// tag path and repair to one keeper; B holds the IDENTICAL path and
    /// keeps their own row untouched — same natural key, different
    /// tenant, no dedupe.
    @Test func aTagPathRepairInAsFleetNeverTouchesBsIdenticalPath() async throws {
        let world = try await makeWorld()

        // A's race: both devices create "life" offline.
        try world.a1.with { ops, _ in _ = try ops.createTag(parent: nil, name: "life") }
        try world.a2.with { ops, _ in _ = try ops.createTag(parent: nil, name: "life") }
        // B's own "life", no race.
        let bTagID: String = try world.b1.with { ops, _ in
            try ops.createTag(parent: nil, name: "life").id
        }
        try await fleetQuiesce(world.b1, world.b2)
        let bServerRowBefore = await world.server.currentRow(
            table: "tag", rowID: bTagID, for: Self.userB)

        // A's fleet converges THROUGH the repair (keep lexically smaller
        // id, tombstone the duplicate).
        try await fleetQuiesce(world.a1, world.a2)
        for db in [world.a1.db, world.a2.db] {
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'life' AND deleted_at IS NULL") == 1,
                "A's race repairs to ONE live keeper")
        }

        // B's world: byte-untouched by A's repair — the identical natural
        // key deduped NOTHING across the partition boundary.
        try await fleetQuiesce(world.b1, world.b2)
        for db in [world.b1.db, world.b2.db] {
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'life' AND deleted_at IS NULL") == 1)
            #expect(try db.fetchString(
                "SELECT id FROM tag WHERE path = 'life' AND deleted_at IS NULL") == bTagID,
                "B keeps THEIR tag — a cross-tenant dedupe would be corruption")
        }
        let bServerRowAfter = await world.server.currentRow(
            table: "tag", rowID: bTagID, for: Self.userB)
        #expect(bServerRowAfter == bServerRowBefore,
                "B's server row is byte-identical through A's repair")
    }

    // MARK: - The vault-key-id fence (THE DESIGN 2; CF-8's structural half)

    /// A stale writer after a re-key: the account's vault names a NEW
    /// corpus key id (CF-8 writes the vault FIRST), so the device still
    /// holding the old keys refuses BOTH round halves with the typed
    /// CF-16 error — outbox intact, cursor unmoved, ZERO rows landed
    /// server-side past the fence. The road back is the re-key road
    /// itself: new keys + account truncate + resyncReinitialize + repush.
    @Test func aStaleWritersRoundRefusesWithTheReplacedStateAndHealsByTheReKeyRoad() async throws {
        let world = try await makeWorld()
        try world.a1.with { ops, _ in
            let post = try ops.createPost(title: "before the re-key", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Old-key era prose.", at: .end)
        }
        try await fleetQuiesce(world.a1, world.a2)

        // THE RE-KEY, server half: the vault row now names a new key id.
        let rotated = SyncEncryptionKeys(
            corpusKey: SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0xC0) })),
            corpusKeyID: "test-corpus-key-ROTATED-0000003")
        await world.server.setVaultCorpusKeyID(rotated.corpusKeyID, for: Self.userA)

        // The stale writer types on, then tries to sync with OLD keys.
        try world.a1.with { ops, _ in
            _ = try ops.createPost(title: "typed while stale", profile: .journal)
        }
        let outboxBefore = try world.a1.outboxCount()
        #expect(outboxBefore > 0)
        let cursorBefore = try world.a1.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        let serverRowsBefore = await world.server.rowCount(
            table: "container", for: Self.userA)

        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await world.a1.push()
        }
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await world.a1.pull()
        }
        #expect(try world.a1.outboxCount() == outboxBefore,
                "the fence refusal keeps the outbox byte-intact")
        #expect(try world.a1.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == cursorBefore,
                "the fence refusal never moves the cursor")
        #expect(await world.server.rowCount(table: "container", for: Self.userA)
                == serverRowsBefore,
                "ZERO rows land past the fence — the poison-push window is closed")

        // THE HEAL — the CF-8 order end to end: keys re-enrolled (the new
        // vault's), the account's partition truncated, the store
        // re-initialized, the corpus re-pushed under the NEW key.
        world.a1.keyProvider = FixedSyncKeyProvider(keys: rotated)
        world.a2.keyProvider = FixedSyncKeyProvider(keys: rotated)
        await world.server.truncateAccount(Self.userA)
        try await world.a1.withAsync { db in
            try await SyncEngine(transport: world.server).resyncReinitialize()
            _ = db
        }
        try await world.a2.withAsync { db in
            try await SyncEngine(transport: world.server).resyncReinitialize()
            _ = db
        }
        try await fleetQuiesce(world.a1, world.a2)
        #expect(try world.a1.syncedDump() == world.a2.syncedDump(),
                "the re-keyed fleet converges whole")
        #expect(try world.a1.outboxCount() == 0)
        // And the repushed mirror rows now seal under the ROTATED key.
        let repushed = await world.server.storedRows(for: Self.userA)
        let sealedTitles = repushed.filter { $0.table == "container" }.compactMap {
            row -> String? in
            guard case .text(let value)? = row.columns["title"] else { return nil }
            return value
        }
        #expect(!sealedTitles.isEmpty)
        for sealed in sealedTitles {
            #expect(PayloadCipher.isEncrypted(sealed))
            #expect(throws: (any Error).self, "the OLD key must no longer open the corpus") {
                _ = try SyncTestKeys.open(
                    sealed, table: "container", rowID: "any", column: "title")
            }
        }

        // B's world sailed through A's whole re-key untouched.
        try world.b1.with { ops, _ in
            _ = try ops.createPost(title: "B unaffected", profile: .blog)
        }
        try await fleetQuiesce(world.b1, world.b2)
    }

    // MARK: - The entitlement gate (THE DESIGN 5)

    /// An unentitled account's round refuses VISIBLY and typed — outbox
    /// intact, cursor unmoved — and heals with zero state surgery once
    /// the entitlement lands (the SyncSpec §12 refusal grammar: stalling
    /// is free, local writing untouched).
    @Test func anUnentitledAccountsRoundRefusesVisiblyAndHealsOnGrant() async throws {
        let world = try await makeWorld()
        try world.b1.with { ops, _ in
            let post = try ops.createPost(title: "written unentitled", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Local writing never blocks.", at: .end)
        }
        await world.server.setEntitled(false, for: Self.userB)
        let outboxBefore = try world.b1.outboxCount()
        #expect(outboxBefore > 0)

        await #expect(throws: SyncError.syncNotEntitled) { _ = try await world.b1.push() }
        await #expect(throws: SyncError.syncNotEntitled) { _ = try await world.b1.pull() }
        #expect(try world.b1.outboxCount() == outboxBefore,
                "the tier refusal keeps the outbox byte-intact")
        #expect(await world.server.rowCount(table: "container", for: Self.userB) == 0)

        // The plan activates — the SAME device heals, no state surgery.
        await world.server.setEntitled(true, for: Self.userB)
        try await fleetQuiesce(world.b1, world.b2)
        #expect(try world.b1.outboxCount() == 0)
        #expect(try world.b1.syncedDump() == world.b2.syncedDump())
    }

    // MARK: - The engine wire pin

    /// The engine sends its HELD key id on every round half — the fence's
    /// client half. A recording transport asserts the parameter's value
    /// and presence on push AND pull (its very existence on the protocol
    /// is the compile-time half of this pin).
    @Test func theEngineSendsItsHeldKeyIDOnBothRoundHalves() async throws {
        let server = FakeSyncServer()
        let recorder = KeyIDRecordingTransport(inner: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: recorder)
        try a.with { ops, _ in
            _ = try ops.createPost(title: "wire pin", profile: .blog)
        }
        _ = try await a.push()
        _ = try await a.pull()

        let pushed = await recorder.pushKeyIDs
        let pulled = await recorder.pullKeyIDs
        #expect(!pushed.isEmpty, "the push half must carry the key id")
        #expect(!pulled.isEmpty, "the pull half must carry the key id")
        #expect((pushed + pulled).allSatisfy { $0 == SyncTestKeys.corpusKeyID },
                "the id sent is exactly the provider's held corpus key id")
    }
}

/// Records every activeKeyID the engine presents, forwarding to the fake.
actor KeyIDRecordingTransport: SyncTransport {
    private let inner: FakeSyncServer
    private(set) var pushKeyIDs: [String] = []
    private(set) var pullKeyIDs: [String] = []

    init(inner: FakeSyncServer) {
        self.inner = inner
    }

    func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome] {
        pushKeyIDs.append(activeKeyID)
        return try await inner.push(batch, activeKeyID: activeKeyID)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String) async throws -> [SyncPulledRow] {
        pullKeyIDs.append(activeKeyID)
        return try await inner.pull(since: since, limit: limit, activeKeyID: activeKeyID)
    }

    func schemaVersion() async throws -> Int {
        await inner.schemaVersion()
    }
}
