import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13x U2b, DRILL LEGS 3 + 4 — THE PLAINTEXT-EXPORT RE-OPEN, END TO
// END (corner 13 / §14.13 + ledger 22: the four local tables recreated
// BEFORE any write, cursor 0 + empty outbox under the same account = ZERO
// pushes; a foreign owner takes the adopt road) and THE RETURNER / PURGE
// FENCE (corner 37 + the 13j ledger: a backup older than a purge horizon
// reconciles at its first round, and nothing — the kept outbox's queued
// family edit included — ever re-pushes a purged row).
//
// Both legs run the DOOR'S OWN call sequence headless (the
// `LibraryOpenModel.confirmAdoption` work closures, call-for-call):
// classify → LibraryAdoption → (plaintext: LocalMachineryRecreation →
// StoreIdentity.establish + fresh key) → the HOLD → Resume. Purge-flavored
// convergence is asserted the PurgeConvergence way (explicit rounds + dump
// equality — executePurge consumes a seq no feed row carries, so
// cursor==head is deliberately not the bar there).
@Suite("13x U2b legs 3+4 — the export re-open + the returner/purge fence")
struct LibraryExportAndReturnerDrillTests {
    // MARK: - Shared helpers (the PurgeConvergence idiom, restated)

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func scratch(_ leg: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-\(leg)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// One device's committed round (the PurgeConvergence shape): push,
    /// then pull TWICE — the second pull's first window reports the
    /// advanced cursor, which is what the horizon reads.
    private func round(_ client: SyncClient) async throws {
        try await client.push()
        try await client.pull()
        try await client.pull()
    }

    private func sweep(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> PurgeJanitor.SweepReport {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider).sweep()
        }
    }

    private func reconcile(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> Int {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider)
                .reconcileLedger()
        }
    }

    /// Backdates one deletion event's EXACT stamp coherently across every
    /// tombstoned table (run BEFORE pushing, so the mirror holds the
    /// backdated stamps too).
    private func backdate(
        _ client: SyncClient, from original: String, to stamp: String
    ) throws {
        try client.db.write { db in
            for table in SyncSchema.tables where table.hasTombstone {
                try db.execute(
                    sql: "UPDATE \(table.name) SET deleted_at = ? WHERE deleted_at = ?",
                    arguments: [stamp, original])
            }
        }
    }

    private func familyRowCount(_ client: SyncClient, post: String) throws -> Int {
        var total = 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE container_id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM block WHERE last_container_id = ?
               OR id IN (SELECT block_id FROM container_block WHERE container_id = ?)
            """, [post, post]) ?? 0
        return total
    }

    // MARK: - Leg 3: the plaintext-export re-open, end to end

    @Test func theExportReopensUnderTheSameAccountFromCursorZeroWithZeroPushes() async throws {
        let dir = try scratch("leg3")
        defer { try? FileManager.default.removeItem(at: dir) }
        let server = FakeSyncServer()

        // ——— The origin library: real shape, synced to its head.
        let originURL = dir.appendingPathComponent("origin/variorum.sqlite")
        let o = try SyncClient(
            name: "O", prefix: "AA", transport: server,
            storeURL: originURL, custody: .inMemory(initial: StoreKey.mint()))
        let known: String = try o.with { ops, _ in
            let post = try ops.createPost(title: "the exported draft", profile: .blog)
            let made = try ops.newBlock(in: post.id, text: "Words that travel in the clear.", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            _ = try ops.addBlockComment(to: made.block.id, text: "a working note")
            _ = try ops.createPost(title: "a second note", profile: .generic)
            return post.id
        }
        _ = try await productionRound(o)
        _ = try await productionRound(o)
        #expect(try o.outboxCount() == 0)
        let head = await server.headSeq(for: FakeSyncServer.defaultUserID)
        #expect(head > 0)

        // ——— The export (decision 15), classified by the door's step 1.
        let export = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: o.db, to: export)
        #expect(LibraryClassifier.classify(at: export) == .plaintextExport(store: export),
                "the export classifies by the four ABSENT local tables + the riding sync columns")

        // ——— The door's plaintext road, call-for-call, on a NEW Mac.
        let newMac = dir.appendingPathComponent("new-mac/variorum.sqlite")
        let plan = LibraryAdoption.plan(
            adopting: export, keyFile: nil, intoStoreAt: newMac,
            now: Date(timeIntervalSince1970: 1_800_000_000))
        #expect(plan.landedKeyFile == nil, "no pair travels on the plaintext road")
        _ = try LibraryAdoption.execute(plan)
        let created = try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: newMac)
        #expect(created == SyncSchema.localOnlyTables.sorted(),
                "ALL FOUR local tables recreated BEFORE any write (§14.13 + ledger 22)")
        let freshKey = StoreKey.mint()
        _ = try StoreIdentity.establish(besideStore: newMac, key: freshKey)
        try LibraryRestoreHold.set(
            besideStore: newMac, asOf: nil, now: Date(timeIntervalSince1970: 1_800_000_000))
        #expect(LibraryRestoreHold.isHeld(besideStore: newMac),
                "the hold lands on the plaintext road too — one landing state everywhere")

        // §14.13's reconciliation state, verified BEFORE the first round:
        // empty outbox, no cursor, no row seqs.
        let probe = try DatabaseQueue(path: newMac.path, configuration: AppDatabase.configuration())
        let preState: (outbox: Int, state: Int, seqs: Int) = try await probe.read { db in
            (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_state") ?? -1,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_row_seq") ?? -1)
        }
        try probe.close()
        #expect(preState.outbox == 0 && preState.state == 0 && preState.seqs == 0,
                "empty outbox · no cursor · no row seqs — §14.13's exact pre-round state")

        // ——— Resume: the route's open ENCRYPTS the landed copy (the
        // shipped 13p migration), a FRESH device identity enrolls, and the
        // first round pulls from 0 and pushes NOTHING.
        #expect(LibraryRestoreHold.clear(besideStore: newMac))
        let n = try SyncClient(
            name: "N", prefix: "CC", transport: server, clockOffset: 300, seed: 5,
            storeURL: newMac, custody: .inMemory(initial: freshKey))
        #expect(StoreFilePresence.classify(at: newMac) == .encryptedOrUnknown,
                "the landed export is born encrypted at the route's open")
        #expect(n.deviceID != o.deviceID, "a copy is writing, never a device — fresh identity")
        #expect(try n.cursor() == 0)
        let first = try await productionRound(n)
        #expect(first.push.accepted == 0 && first.push.rejected == 0
            && first.push.deferred == 0 && first.push.purged == 0,
                "ZERO pushes — the same-account re-open is a pure catch-up (§14.13's letter)")
        #expect(try n.outboxCount() == 0)
        #expect(try n.cursor() == head, "the fresh cursor read the account's sequence to its head")
        #expect(try n.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL", [known]) == 1)
        #expect(try n.syncedDump() == o.syncedDump(), "the re-opened export converges byte-identically")
        #expect(await server.deviceCursor(n.deviceID) != nil,
                "the new identity's cursor is recorded — enrolled, not assumed")
    }

    @Test func aForeignOwnersExportTakesTheAdoptRoadIntoItsOwnPartition() async throws {
        let dir = try scratch("leg3b")
        defer { try? FileManager.default.removeItem(at: dir) }
        let server = FakeSyncServer()

        // The origin under account X (the default), synced; the export.
        let o = try SyncClient(
            name: "O", prefix: "AA", transport: server,
            storeURL: dir.appendingPathComponent("origin/variorum.sqlite"),
            custody: .inMemory(initial: StoreKey.mint()))
        let known: String = try o.with { ops, _ in
            let post = try ops.createPost(title: "words changing hands", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "The corpus that moves accounts.", at: .end)
            return post.id
        }
        _ = try await productionRound(o)
        _ = try await productionRound(o)
        let xHeadBefore = await server.headSeq(for: FakeSyncServer.defaultUserID)
        let export = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: o.db, to: export)

        // Account Y exists; the export lands on Y's machine (the same
        // plaintext road's file half).
        let yID = "00000000-aaaa-4bbb-8ccc-000000001313"
        await server.provisionAccount(
            yID, vaultCorpusKeyID: SyncTestKeys.corpusKeyID,
            keyProofHash: SyncTestKeys.keyProofHash)
        let yMac = dir.appendingPathComponent("y-mac/variorum.sqlite")
        _ = try LibraryAdoption.execute(LibraryAdoption.plan(
            adopting: export, keyFile: nil, intoStoreAt: yMac,
            now: Date(timeIntervalSince1970: 1_800_000_100)))
        _ = try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: yMac)
        let yKey = StoreKey.mint()
        _ = try StoreIdentity.establish(besideStore: yMac, key: yKey)

        // ——— THE ADOPT ROAD (a different owner in the rows): re-stamp +
        // resyncReinitialize, then the upload lands in Y's OWN partition
        // at Y's OWN sequence — X's rows untouched.
        let f = try SyncClient(
            name: "F", prefix: "EE", transport: server.connection(as: yID),
            clockOffset: 700, seed: 8, storeURL: yMac, custody: .inMemory(initial: yKey))
        f.ownerID = yID
        #expect(try f.db.fetchString(
            "SELECT owner_id FROM container WHERE id = ?", [known])
            == FakeSyncServer.defaultUserID,
                "the export's rows arrive stamped by the OTHER owner — the adopt road's premise")
        _ = try f.with { ops, _ in try ops.restampOwner(to: yID) }
        try await f.withAsync { _ in try await f.engine().resyncReinitialize() }
        #expect(try f.cursor() == 0)
        let upload = try await f.push()
        #expect(upload.accepted > 0 && upload.rejected == 0 && upload.deferred == 0)
        _ = try await f.pull()
        _ = try await f.pull()
        #expect(await server.headSeq(for: yID) == Int64(upload.accepted),
                "Y's sequence reads from ITS start — a fresh partition, nobody else's numbers")
        #expect(await server.currentRow(table: "container", rowID: known, for: yID) != nil,
                "the note lives in Y's partition under the SAME id (the (owner_id, id) keys)")
        #expect(await server.currentRow(
            table: "container", rowID: known, for: FakeSyncServer.defaultUserID) != nil,
                "X's copy is untouched — adoption re-stamps LOCALLY, never across the wire")
        #expect(await server.headSeq(for: FakeSyncServer.defaultUserID) == xHeadBefore,
                "nothing moved in X's partition")
        #expect(try f.outboxCount() == 0)
    }

    // MARK: - Leg 4: the returner / purge fence

    @Test func aBackupOlderThanThePurgeHorizonReconcilesAndNothingRePushesAPurgedRow() async throws {
        let dir = try scratch("leg4")
        defer { try? FileManager.default.removeItem(at: dir) }
        let server = FakeSyncServer()

        // ——— The Mac (A, encrypted, pair-backed) + the other device (B);
        // a doomed family and a bystander, converged LIVE.
        let aURL = dir.appendingPathComponent("mac/variorum.sqlite")
        let key = StoreKey.mint()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: aURL, custody: .inMemory(initial: key))
        let b = try SyncClient(
            name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        let world: (doomed: String, familyTake: String, bystander: String) = try a.with { ops, _ in
            let doomed = try ops.createPost(title: "the doomed family", profile: .generic)
            let made = try ops.newBlock(in: doomed.id, text: "First words.", at: .end)
            _ = try ops.newBlock(in: doomed.id, text: "Second words.", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            _ = try ops.addBlockComment(to: made.block.id, text: "a note")
            let bystander = try ops.createPost(title: "the bystander", profile: .generic)
            _ = try ops.newBlock(in: bystander.id, text: "Still here after everything.", at: .end)
            return (doomed.id, made.variant.id, bystander.id)
        }
        try await syncToQuiescence(a, b, server: server)

        // The queued family edit the backup will carry (QD's kept outbox —
        // the row that must NEVER resurrect the purged family).
        try a.with { ops, _ in
            try ops.autosave(world.familyTake, text: "a late family edit", charDelta: 10)
        }
        #expect(try a.outboxContains("variant", world.familyTake))

        // ——— THE BACKUP PAIR, taken while the family is LIVE.
        let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
        let backups = dir.appendingPathComponent("Backups", isDirectory: true)
        let snapshot = backups.appendingPathComponent(
            "variorum-backup-2026-07-01-080000-\(fp8).sqlite")
        try a.db.backup(to: snapshot)
        var pairEnvelope = StoreKeyEnvelope()
        try pairEnvelope.setPassphraseWrap(key: key, passphrase: "the day's word", kdf: fastKDF())
        let pairKeyFile = LibraryClassifier.pairedKeyFile(for: snapshot)
        try pairEnvelope.write(at: pairKeyFile)

        // ——— The account moves PAST THE HORIZON: the family deleted, the
        // stamps aged past the 30-day window, both devices caught up, A's
        // janitor sweeps — purged (mirror + local + the ledger).
        try a.with { ops, _ in try ops.deleteContainer(world.doomed) }
        let deletedStamp = try #require(try a.db.fetchString(
            "SELECT deleted_at FROM container WHERE id = ?", [world.doomed]))
        try backdate(a, from: deletedStamp, to: "2026-05-01T00:00:00.000Z")
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)
        let purge = try await sweep(a, server)
        #expect(purge.familiesPurged >= 1, "the 30-day road purged the family")
        #expect(await server.currentRow(table: "container", rowID: world.doomed) == nil)
        #expect(await server.isPurged(table: "container", rowID: world.doomed))
        #expect(await server.isPurged(table: "variant", rowID: world.familyTake))
        let ledgerEntries = await server.purgedLedgerCount()
        #expect(ledgerEntries > 0)

        // ——— THE RESTORE on a fresh Mac, the door's sequence: the pair
        // classifies, opens by its day's word, custody mints fresh
        // (corner 33's class), the hold lands.
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: pairKeyFile))
        let opener = try #require(try StoreKeyEnvelope.load(at: pairKeyFile))
            .unwrapKey(passphrase: "the day's word", floor: .relaxedForTests)
        #expect(opener == key)
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: nil,
            openingKeyFingerprint: StoreKeyEnvelope.fingerprint(of: opener))
            == .mintFreshCustody)
        let freshMac = dir.appendingPathComponent("fresh-mac/variorum.sqlite")
        _ = try LibraryAdoption.execute(LibraryAdoption.plan(
            adopting: snapshot, keyFile: pairKeyFile, intoStoreAt: freshMac,
            now: Date(timeIntervalSince1970: 1_800_000_200)))
        try LibraryRestoreHold.set(
            besideStore: freshMac,
            asOf: BackupRestoreCandidates.backupDate(snapshot),
            now: Date(timeIntervalSince1970: 1_800_000_200))
        #expect(LibraryRestoreHold.isHeld(besideStore: freshMac))

        // CORNER 37's premise, verified: a FRESH identity over a store
        // with a NON-ZERO cursor — the returner by construction — and the
        // backup still holds the purged family plus its queued edit.
        let r = try SyncClient(
            name: "R", prefix: "FF", transport: server, clockOffset: 11, seed: 9,
            storeURL: freshMac, custody: .inMemory(initial: opener))
        #expect(r.deviceID != a.deviceID && r.deviceID != b.deviceID)
        #expect(try r.cursor() > 0, "a non-zero cursor — the returner's premise")
        #expect(try familyRowCount(r, post: world.doomed) > 0,
                "the old backup carries rows the ledger says are purged")
        #expect(try r.outboxContains("variant", world.familyTake),
                "…and the queued family edit rides the kept outbox")

        // ——— Resume: the FIRST ROUND in the scheduled shape —
        // reconcileLedger BEFORE the drain, then pull → push, then sweep.
        #expect(LibraryRestoreHold.clear(besideStore: freshMac))
        let dropped = try await reconcile(r, server)
        #expect(dropped > 0, "the ledger scan from the STORE's scan point drops the purged family")
        #expect(try familyRowCount(r, post: world.doomed) == 0,
                "reconciled — nothing stranded, nothing resurrected")
        #expect(try r.outboxContains("variant", world.familyTake) == false,
                "the queued family edit is SWEPT WITH THE FAMILY (B2's letter) — it never pushes")
        let first = try await productionRound(r)
        #expect(first.push.purged == 0,
                "nothing even reached the server's fence — screened before the drain")
        _ = try await sweep(r, server)

        // ——— The ruled outcomes: the mirror holds nothing of the family,
        // the ledger stands, the bystander lives, the fleet converges.
        #expect(await server.currentRow(table: "container", rowID: world.doomed) == nil)
        #expect(await server.currentRow(table: "variant", rowID: world.familyTake) == nil,
                "nothing re-pushed a purged row")
        #expect(await server.isPurged(table: "container", rowID: world.doomed))
        #expect(await server.purgedLedgerCount() == ledgerEntries,
                "the ledger is read, never rewritten, by a returner")
        #expect(try r.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL",
            [world.bystander]) == 1)
        try await round(r)
        // B converges to the PURGED state through its own janitor leg —
        // exactly the PurgeConvergence precedent ("B's own sweep
        // reconciles the rest through the ledger scan"): until it runs, B
        // still holds the family's TOMBSTONED rows while the returner has
        // physically dropped them. The first dump comparison of this
        // drill ran WITHOUT this leg and went red on exactly that
        // difference — the traced composition gap, kept visible here.
        #expect(try familyRowCount(b, post: world.doomed) > 0,
                "before its own sweep, B still holds the tombstoned family")
        _ = try await sweep(b, server)
        #expect(try familyRowCount(b, post: world.doomed) == 0,
                "B's ledger scan drops the purged family too")
        try await round(b)
        try await round(r)
        #expect(try r.outboxCount() == 0 && b.outboxCount() == 0)
        #expect(try r.syncedDump() == b.syncedDump(),
                "the returner converges with the fleet by dump equality")
        #expect(await server.deviceCursor(r.deviceID) != nil,
                "the new identity's cursor is recorded; the old rows stand untouched")
    }
}
