import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13x U2b, DRILL LEG 1 — THE SAME-MAC RESTORE, END TO END (the U2b
// brief; the kickoff sitting's QA→round-3 ruling + QD). The story the door
// promises, run headless over the fake server:
//
//   a live library syncs · the Mac dies with its LAST EDIT still queued
//   (the outbox row the backup carries — QD's kept outbox) · the account
//   moves on without it (the same take edited elsewhere; a note trashed)
//   · the backup PAIR is adopted back on the same Mac (the door's own call
//   sequence: classify → second look → LibraryAdoption → the HOLD) · inside
//   the held window the user duplicates the since-trashed note (the hold
//   banner's duplicate-first recipe) · Resume → catch-up.
//
// The ruled outcomes, each pinned: the DUPLICATE SURVIVES (fresh UUIDs —
// the recipe works); the re-trashed original LEAVES AGAIN (tombstone
// catch-up — correct and said; the saying is the banner's, evidenced at
// the U2 Mac slot); the kept outbox's stale-dirty row lands as EXACTLY ONE
// conflict card carrying the dead Mac's words (QD's accepted price, S5's
// shape); the same device identity rides throughout (same-Mac custody —
// the server never meets a second device); both devices converge
// byte-identically.
@Suite("13x U2b leg 1 — the same-Mac restore drill (hold → duplicate → Resume)")
struct LibrarySameMacRestoreDrillTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// Close the pool, then make the store look the way a closed library
    /// does on disk (an empty or absent `-wal`): the pool's own close may
    /// leave checkpointed frames behind in the sidecar (the
    /// KeyedStoreConvergence measurement), and `LibraryAdoption` honestly
    /// refuses a non-empty `-wal` as "looks open". A real door reaches
    /// this state through `AppBootstrap`'s lock road; the harness drains
    /// the WAL through one keyed connection — a test-world stand-in for
    /// the app's own close, recorded, not hidden.
    private func closeAndSettle(_ db: AppDatabase, at url: URL, key: StoreKey) throws {
        _ = db.asRebindable().binding.lock()
        let wal = URL(fileURLWithPath: url.path + "-wal")
        guard let size = try? FileManager.default
            .attributesOfItem(atPath: wal.path)[.size] as? Int, size > 0 else { return }
        let queue = try DatabaseQueue(
            path: url.path, configuration: AppDatabase.configuration(key: key))
        try queue.writeWithoutTransaction { db in
            _ = try Row.fetchOne(db, sql: "PRAGMA wal_checkpoint(TRUNCATE)")
        }
        try queue.close()
    }

    @Test func theSameMacRestoreHoldsDuplicatesResumesAndTheAccountCatchesUp() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-leg1-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        // ——— The live library: THE MAC (A, encrypted on disk) + THE OTHER
        // DEVICE (B). One account, two devices, converged.
        let server = FakeSyncServer()
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let key = StoreKey.mint()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: storeURL, custody: .inMemory(initial: key))
        let b = try SyncClient(
            name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        let world: (trashedNote: String, keptNote: String, take: String) = try a.with { ops, _ in
            let doomed = try ops.createPost(title: "the note she will trash", profile: .generic)
            _ = try ops.newBlock(in: doomed.id, text: "Words she second-guessed.", at: .end)
            let kept = try ops.createPost(title: "the long draft", profile: .blog)
            let made = try ops.newBlock(in: kept.id, text: "The shared take.", at: .end)
            return (doomed.id, kept.id, made.variant.id)
        }
        try await productionQuiescence(a, b, server: server)

        // ——— The dead Mac's last words: a dirty edit QUEUED, never pushed.
        try a.with { ops, _ in
            try ops.autosave(world.take, text: "the dead Mac's last words", charDelta: 24)
        }
        #expect(try a.outboxContains("variant", world.take),
                "the stale edit is queued — the row the backup must carry (QD)")
        let cursorAtBackup = try a.cursor()
        #expect(cursorAtBackup > 0, "the backup carries a real cursor")

        // ——— The backup PAIR (row 42's shape): the snapshot under the
        // backup name + ITS OWN `.keys.json` written with it.
        let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
        let backups = dir.appendingPathComponent("Backups", isDirectory: true)
        let snapshot = backups.appendingPathComponent(
            "variorum-backup-2026-07-02-010203-\(fp8).sqlite")
        try a.db.backup(to: snapshot)
        var pairEnvelope = StoreKeyEnvelope()
        try pairEnvelope.setPassphraseWrap(
            key: key, passphrase: "the day's word", kdf: fastKDF())
        let pairKeyFile = LibraryClassifier.pairedKeyFile(for: snapshot)
        try pairEnvelope.write(at: pairKeyFile)

        // ——— The account moves on WITHOUT the dead Mac: the same take
        // edited elsewhere and pushed; the note trashed and pushed.
        try b.with { ops, _ in
            try ops.autosave(world.take, text: "the account moved on", charDelta: 20)
        }
        _ = try await productionRound(b)
        try b.with { ops, _ in
            try ops.deleteContainer(world.trashedNote)
        }
        _ = try await productionRound(b)
        #expect(try b.outboxCount() == 0)

        // ——— THE RESTORE, the door's own sequence. The pair classifies;
        // the SECOND LOOK composes `alreadyAligned` (same key, the live
        // custody serves it — ledger 14's class, no folder touched).
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: pairKeyFile))
        let pairRead = try #require(try StoreKeyEnvelope.load(at: pairKeyFile))
        #expect(pairRead.belongs(to: key), "the live custody's key serves the pair")
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: StoreKeyEnvelope.fingerprint(of: key),
            openingKeyFingerprint: StoreKeyEnvelope.fingerprint(of: key))
            == .alreadyAligned)

        try closeAndSettle(a.db, at: storeURL, key: key)
        let plan = LibraryAdoption.plan(
            adopting: snapshot, keyFile: pairKeyFile, intoStoreAt: storeURL,
            now: Date(timeIntervalSince1970: 1_800_000_000))
        _ = try LibraryAdoption.execute(plan)
        let asOf = BackupRestoreCandidates.backupDate(snapshot)
        #expect(asOf != nil, "the pair's name carries its day — the banner's as-of fact")
        try LibraryRestoreHold.set(
            besideStore: storeURL, asOf: asOf,
            now: Date(timeIntervalSince1970: 1_800_000_000))

        // ——— THE HOLD STANDS (round 3's landing state; the gate's
        // zero-rounds half is the U2 Mac slot's pinned seam).
        #expect(LibraryRestoreHold.isHeld(besideStore: storeURL))
        #expect(LibraryRestoreHold.read(besideStore: storeURL)?.asOf == asOf)

        // The SAME Mac: custody survived, so the restored library is the
        // SAME device — same identity, the backup's own cursor.
        let r = try SyncClient(
            name: "R", prefix: "DD", transport: server, clockOffset: 5, seed: 7,
            storeURL: storeURL, custody: .inMemory(initial: key))
        r.deviceID = a.deviceID
        #expect(try r.cursor() == cursorAtBackup,
                "the restored library pulls from ITS OWN old cursor — the catch-up premise")
        #expect(try r.outboxContains("variant", world.take),
                "QD: the kept outbox still carries the dead Mac's queued edit")

        // ——— Inside the held window: the since-trashed note is LIVE in
        // the copy (that is why she restored), and she DUPLICATES it —
        // the banner's recipe. Fresh UUIDs by construction.
        #expect(try r.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL",
            [world.trashedNote]) == 1,
                "the trashed note is alive in the restored copy")
        let duplicate = try r.with { ops, _ in
            try ops.duplicateAsVersion(world.trashedNote)
        }
        #expect(duplicate.post.id != world.trashedNote)

        // ——— RESUME: the one press — the marker clears, rounds run.
        #expect(LibraryRestoreHold.clear(besideStore: storeURL))
        #expect(!LibraryRestoreHold.isHeld(besideStore: storeURL))
        try await productionQuiescence(r, b, server: server)

        // ——— THE RULED OUTCOMES, counted on both devices.
        for client in [r, b] {
            // The re-trashed original leaves again (tombstone catch-up).
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NOT NULL",
                [world.trashedNote]) == 1,
                    "\(client.name): the since-trashed original honestly leaves again")
            // The duplicate survives.
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL",
                [duplicate.post.id]) == 1,
                    "\(client.name): the duplicate survives the catch-up — the recipe is real")
            // The account's newer text won the row.
            #expect(try client.db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [world.take])
                == "the account moved on",
                    "\(client.name): the server text wins the row (S5's letter)")
            // EXACTLY ONE conflict card, carrying the dead Mac's words.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM variant
                WHERE label = 'conflict' AND deleted_at IS NULL
                """, []) == 1,
                    "\(client.name): the stale-dirty row lands as exactly ONE conflict card (QD)")
            #expect(try client.db.fetchString(
                """
                SELECT working_text FROM variant
                WHERE label = 'conflict' AND deleted_at IS NULL
                """, []) == "the dead Mac's last words",
                    "\(client.name): nothing typed on the dead Mac is lost")
        }
        #expect(try r.outboxCount() == 0 && b.outboxCount() == 0)
        #expect(try r.syncedDump() == b.syncedDump(), "the pair converges byte-identically")
        // Same-Mac identity: the server never met a second device.
        #expect(await server.deviceCursor(a.deviceID) != nil,
                "the restored library reports under the SAME device identity")
    }
}
