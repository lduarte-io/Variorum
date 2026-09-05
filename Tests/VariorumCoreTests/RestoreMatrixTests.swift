import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13l, Act 4 (ledger row 15) — **the deletion-aware restore matrix,
/// headless.**
///
/// Her requirement at the 13j close, verbatim: *"we have to make sure that
/// items that have been deleted when restored from backup are restored or
/// not in the expected way, including after a true delete."*
///
/// The scenarios are M1–M7 in the phase plan's Scope §7. Four of them are
/// pinned here; three are rehearsed live in the drill instead, and which is
/// which is deliberate:
///
/// | # | what | where |
/// |---|---|---|
/// | M1 | tombstoned at backup time → comes back tombstoned, same clock | here + the drill |
/// | M2 | deleted after the backup, SYNCED → the tombstone re-pulls, it lands in the Trash | here |
/// | M3 | deleted after the backup, LOCAL-ONLY → the deletion is undone | the drill (a store with no account IS the scenario) |
/// | M4 | PURGED after the backup, SYNCED → really deleted survives the restore | **here — the centrepiece** |
/// | M5 | purged after the backup, LOCAL-ONLY → it comes back | the drill (her accept-and-say-it ruling; the doc is the deliverable) |
/// | M6 | purged content lives on inside older backup FILES | the drill (an assertion about files, not rows) |
/// | M7 | a restored store's older cursor never drags the server's back | here |
///
/// Every "restored" client is built from a REAL `AppDatabase.backup(to:)`
/// snapshot of a converged device, copied and reopened — never from
/// hand-written rows or a wound-back clock. That is the whole point: the
/// thing under test is what those bytes do when they meet the account again.
@Suite("The deletion-aware restore matrix (13l — M1/M2/M4/M7)")
struct RestoreMatrixTests {
    // MARK: - Helpers (the purge battery's, deliberately)

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

    /// One device's committed round (the battery's shape: the second pull's
    /// first window is what reports the advanced cursor).
    private func round(_ client: SyncClient) async throws {
        try await client.push()
        try await client.pull()
        try await client.pull()
    }

    private func familyRowCount(_ client: SyncClient, post: String) throws -> Int {
        var total = 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE container_id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM block
            WHERE id IN (SELECT block_id FROM container_block WHERE container_id = ?)
            """, [post]) ?? 0
        return total
    }

    /// The harness clock's own era — every stamp these tests reason about is
    /// minted from it, so "in the window" is a fact, not a wall-clock race.
    private let harnessNow = Date(timeIntervalSince1970: 1_782_864_000 + 600)

    // MARK: - M1: tombstoned AT backup time

    @Test func aThingDeletedBeforeTheBackupComesBackDeletedOnItsOriginalClock() throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let live = try SyncClient(
            name: "live", prefix: "AA", transport: server,
            storeURL: scratch.url("live.sqlite"))

        let (doomed, kept, stamp) = try live.with { ops, db -> (String, String, String) in
            let doomed = try ops.createPost(title: "already in the Trash", profile: .generic)
            _ = try ops.newBlock(in: doomed.id, text: "Deleted before the backup was taken.")
            let kept = try ops.createPost(title: "still here", profile: .generic)
            _ = try ops.newBlock(in: kept.id, text: "Untouched.")
            try ops.deleteContainer(doomed.id)
            let stamp = try db.fetchString(
                "SELECT deleted_at FROM container WHERE id = ?", [doomed.id])!
            return (doomed.id, kept.id, stamp)
        }

        let snapshot = try scratch.snapshot(live, as: "backup.sqlite")
        let restored = try scratch.restore(
            snapshot, as: "restored", prefix: "AC", transport: server)

        // Tombstoned, and on the SAME clock — a restore must not look like a
        // fresh deletion, or the 30 days would start over.
        #expect(try restored.db.deletedAt("container", doomed) == stamp,
                "the tombstone's own stamp travels inside the backup")
        // And it is where she would look for it.
        let listed = try restored.db.read { db in
            try Queries.deletedPosts(db, now: harnessNow).map(\.postID)
        }
        #expect(listed.contains(doomed), "it comes back IN the Trash")
        let keptBlocks = try restored.db.read { db in
            try Queries.renderPost(db, containerID: kept).count
        }
        #expect(keptBlocks == 1, "everything else restores untouched")

        // Restorable, for the remainder of its window — the whole promise.
        try restored.with { ops, _ in try ops.restoreContainer(doomed) }
        #expect(try restored.db.deletedAt("container", doomed) == nil)
        let revivedBlocks = try restored.db.read { db in
            try Queries.renderPost(db, containerID: doomed).count
        }
        #expect(revivedBlocks == 1, "its writing came back with it")
    }

    // MARK: - M2: deleted AFTER the backup, on a synced account

    @Test func aDeletionMadeAfterTheBackupReAppliesAndLandsInTheTrash() async throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: scratch.url("a.sqlite"))
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let post = try a.with { ops, _ in
            let post = try ops.createPost(title: "deleted after the backup", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Words that outlive the copy.")
            return post.id
        }
        try await syncToQuiescence(a, b, server: server)

        // THE BACKUP — taken while the post is alive and everything is
        // pushed, which is what a real scheduled backup looks like.
        let snapshot = try scratch.snapshot(a, as: "backup.sqlite")

        // …and then it is deleted, on the OTHER device, and both converge.
        let deletedStamp = try b.with { ops, db in
            try ops.deleteContainer(post)
            return try db.fetchString(
                "SELECT deleted_at FROM container WHERE id = ?", [post])!
        }
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.db.fetchString(
            "SELECT deleted_at FROM container WHERE id = ?", [post]) == deletedStamp)

        // THE RESTORE: those older bytes, opened again. The post is live in
        // them, and the cursor is from before the deletion was published.
        let restored = try scratch.restore(
            snapshot, as: "restored", prefix: "AC", transport: server)
        #expect(try restored.db.fetchString(
            "SELECT deleted_at FROM container WHERE id = ?", [post]) == nil,
                "the backup genuinely predates the deletion")
        #expect(try restored.cursor() < a.cursor(), "and its cursor is genuinely behind")

        // One ordinary round. Nothing special happens — which is the point:
        // the changefeed is state-based, so the tombstone is simply one of
        // the rows this device has not read yet.
        try await round(restored)

        #expect(try restored.db.deletedAt("container", post) == deletedStamp,
                "the deletion re-applies, on its ORIGINAL clock — not today's")
        let inTrash = try await restored.db.read { [harnessNow] db in
            try Queries.deletedPosts(db, now: harnessNow).map(\.postID)
        }
        #expect(inTrash.contains(post),
                "so it is in the Trash, recoverable for the rest of its 30 days")
        // And it did not resurrect on the mirror on the way past.
        let mirrored = await server.currentRow(table: "container", rowID: post)
        #expect(mirrored?.isTombstoned == true)
    }

    // MARK: - M4: PURGED after the backup — the centrepiece

    /// "Really deleted" must survive a backup restore, and the machinery that
    /// makes it survive already exists (13j): the restored store is EXACTLY
    /// a returner, and `reconcileLedger` runs before anything is pushed.
    @Test func aRestoredStoreIsAReturnerAndTheLedgerReDropsThePurgedFamily() async throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: scratch.url("a.sqlite"))
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let post = try a.with { ops, _ in
            let post = try ops.createPost(title: "permanently deleted", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "This is meant to be gone for good.")
            _ = try ops.newBlock(in: post.id, text: "Both blocks, and the takes under them.")
            return post.id
        }
        try await syncToQuiescence(a, b, server: server)

        let snapshot = try scratch.snapshot(a, as: "backup.sqlite")
        #expect(try familyRowCount(a, post: post) > 0)

        // Delete Now: the tombstone, the intent, and the janitor.
        try a.with { ops, _ in
            try ops.deleteContainer(post)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post)])
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)
        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 1)
        #expect(try familyRowCount(a, post: post) == 0)
        #expect(await server.currentRow(table: "container", rowID: post) == nil)
        #expect(await server.isPurged(table: "container", rowID: post))

        // THE RESTORE. These bytes still believe the note exists — and they
        // still hold its blocks and takes.
        let restored = try scratch.restore(
            snapshot, as: "restored", prefix: "AC", transport: server)
        #expect(try familyRowCount(restored, post: post) > 0,
                "the backup is genuinely from before the purge")
        // A local edit made on the restored store before it ever reaches the
        // network — the outbox entry a naive restore would push.
        let take = try restored.db.fetchString(
            """
            SELECT v.id FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
            WHERE cb.container_id = ? ORDER BY v.id LIMIT 1
            """, [post])!
        try await restored.db.write { db in
            try db.execute(
                sql: "UPDATE variant SET working_text = 'typed on the restored store' WHERE id = ?",
                arguments: [take])
        }
        #expect(try restored.outboxContains("variant", take))

        // THE PRE-DRAIN LEDGER PASS (13j ladder B, B2 — what the scheduler
        // runs ahead of every round). The purged family goes, outbox and all,
        // BEFORE a single row is pushed.
        let dropped = try await reconcile(restored, server)
        #expect(dropped > 0, "the ledger names the family this store still held")
        #expect(try familyRowCount(restored, post: post) == 0,
                "really deleted survives a backup restore")
        #expect(try restored.outboxContains("variant", take) == false,
                "and the restored store's pending write goes with the family")

        // Now let it round freely: nothing it holds can put the note back.
        try await round(restored)
        #expect(await server.currentRow(table: "container", rowID: post) == nil,
                "nothing was resurrected on the mirror")
        #expect(await server.currentRow(table: "variant", rowID: take) == nil)
        try await round(a)
        #expect(try familyRowCount(a, post: post) == 0, "and A never learns of a return")
    }

    /// The second road to the same promise: if a restored store pushes
    /// BEFORE any reconciliation (the scheduler's pre-pass skipped, a bare
    /// `push()`), the server refuses per row with the typed `purged` answer
    /// and the client drops the row locally.
    @Test func aPushFromARestoredStoreNamingAPurgedRowIsRefusedAndDroppedLocally() async throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: scratch.url("a.sqlite"))
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let post = try a.with { ops, _ in
            let post = try ops.createPost(title: "gone for good", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Purged while the backup slept.")
            return post.id
        }
        try await syncToQuiescence(a, b, server: server)
        let snapshot = try scratch.snapshot(a, as: "backup.sqlite")

        try a.with { ops, _ in
            try ops.deleteContainer(post)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: post)])
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)
        _ = try await sweep(a, server)
        #expect(await server.isPurged(table: "container", rowID: post))

        let restored = try scratch.restore(
            snapshot, as: "restored", prefix: "AC", transport: server)
        try await restored.db.write { db in
            try db.execute(
                sql: "UPDATE container SET title = 'edited on the restored store' WHERE id = ?",
                arguments: [post])
        }
        #expect(try restored.outboxContains("container", post))

        let pushed = try await restored.push()
        #expect(pushed.purged >= 1, "the server answers 'purged', never a CAS accept")
        #expect(try restored.outboxContains("container", post) == false,
                "the refused entry is dropped, never retried forever")
        #expect(try restored.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [post]) == 0,
                "and the local copy goes with the refusal")
        #expect(await server.currentRow(table: "container", rowID: post) == nil)
    }

    // MARK: - M7: the device cursor under a restore

    @Test func aRestoredStoresOlderCursorNeverDragsTheServersBack() async throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: scratch.url("a.sqlite"))
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        try a.with { ops, _ in
            let post = try ops.createPost(title: "early", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Before the backup.")
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)

        // pre-13x 1a (§3.3): a backup carries NO identity — the identity
        // rides the sync-key custody item on the machine that made it.
        let deviceID = a.deviceID
        let snapshot = try scratch.snapshot(a, as: "backup.sqlite")
        let cursorAtBackup = try a.cursor()
        let recordedAtBackup = await server.deviceCursor(deviceID)
        #expect(recordedAtBackup ?? 0 >= cursorAtBackup - 1)
        #expect(try a.storedDeviceID() == nil, "no identity in the file")

        // Life goes on: B writes, A reads, everyone's cursor advances.
        try b.with { ops, _ in
            let post = try ops.createPost(title: "after", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Written after the backup was taken.")
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        let advanced = try #require(await server.deviceCursor(deviceID))
        #expect(advanced > (recordedAtBackup ?? 0), "the account has moved on")

        // THE RESTORE — a copy of the library is WRITING, NEVER A DEVICE
        // (the design's rule): the restored client has no custody for the
        // store id and gets a FRESH identity; its cursor is the older one.
        // (M7's original premise — "device identity travels inside a
        // backup" — is the one the postures design reverses.)
        let restored = try scratch.restore(
            snapshot, as: "restored", prefix: "AC", transport: server)
        #expect(restored.deviceID != deviceID,
                "a restored copy is a NEW device — a fresh identity, never the source's")
        #expect(try restored.storedDeviceID() == nil, "the backup carried none")
        #expect(try restored.cursor() < advanced)
        let restoredCursor = try restored.cursor()

        try await round(restored)

        // The source device's cursor is untouched by the restore's round
        // (a different identity wrote its own row); the restored device's
        // row records where IT stood — an in-window laggard, so the purge
        // horizon HOLDS at its position: nothing it has not integrated
        // becomes purgeable (the safe direction; the laggard rule).
        #expect(await server.deviceCursor(deviceID) == advanced,
                "the source's cursor is untouched — a different identity")
        let restoredRecorded = try #require(await server.deviceCursor(restored.deviceID))
        #expect(restoredRecorded >= restoredCursor)
        let horizonAfter = try await server.syncHorizon(
            activeKeyID: a.keyProvider.currentKeys().corpusKeyID)
        #expect(horizonAfter <= restoredRecorded,
                "the horizon holds at the restored device's position — nothing it has not seen is purgeable")
        // And the re-pull was harmless: the restored store caught up.
        #expect(try restored.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE title = 'after' AND deleted_at IS NULL") == 1)
    }
}
