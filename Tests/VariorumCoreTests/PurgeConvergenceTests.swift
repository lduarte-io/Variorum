import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13j batch 6b — the PURGE convergence battery (the memo's §7.6 +
/// the engine discipline: any sync change not covered by a convergence
/// test is unreviewed, AppSpec §15.3). Two in-memory clients against the
/// fake server, the janitor riding each device's own dependency world:
/// the 30-day road, the Delete Now intent road, the ledger fence against a
/// stale peer, the 60-day horizon drop-out, mid-family resumption, the
/// pruning modes, no-horizon no-op, and the say-so-first returner road.
@Suite("Purge convergence (13j 6b — fake server, two devices)")
struct PurgeConvergenceTests {
    // MARK: - Helpers

    private func sweep(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> PurgeJanitor.SweepReport {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider).sweep()
        }
    }

    /// Backdates one deletion event's EXACT stamp across every tombstoned
    /// table — coherently, so the cascade-victim discriminator (stamp
    /// equality) survives the move. Run BEFORE pushing, so the server
    /// holds the backdated stamps too.
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

    /// One device's committed round: push, then pull TWICE — the second
    /// pull's first window reports the advanced cursor, which is what the
    /// horizon reads.
    private func round(_ client: SyncClient) async throws {
        try await client.push()
        try await client.pull()
        try await client.pull()
    }

    /// A dated stamp safely past the 30-day window for the harness clock
    /// (which starts 2026-07-01).
    private let oldStamp = "2026-05-01T00:00:00.000Z"

    /// Builds a post with two blocks (one fanned, committed, commented)
    /// and deletes the whole post; returns (postID, blockIDs, variantIDs).
    private func buildAndDeleteFamily(
        _ client: SyncClient
    ) throws -> (post: String, blocks: [String], deletedStamp: String) {
        try client.with { ops, db in
            let post = try ops.createPost(title: "doomed", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "First words.", at: .end)
            let second = try ops.newBlock(in: post.id, text: "Second words.", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            _ = try ops.commit(made.variant.id, message: "kept")
            _ = try ops.addBlockComment(to: made.block.id, text: "note")
            try ops.deleteContainer(post.id)
            let stamp = try db.fetchString(
                "SELECT deleted_at FROM container WHERE id = ?", [post.id])!
            return (post.id, [made.block.id, second.block.id], stamp)
        }
    }

    private func familyRowCount(_ client: SyncClient, post: String) throws -> Int {
        var total = 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE container_id = ?", [post]) ?? 0
        total += try client.db.fetchInt(
            "SELECT COUNT(*) FROM block WHERE last_container_id = ? OR id IN (SELECT block_id FROM container_block WHERE container_id = ?)",
            [post, post]) ?? 0
        return total
    }

    // MARK: - 1. The 30-day road + the ledger fence (resurrection banned)

    @Test func aThirtyDayDeletionPurgesEverywhereAndAStalePeerCannotResurrectIt() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // B holds a pending "offline edit" to a family take — the stale
        // peer whose re-push must never resurrect the purged row.
        let familyVariant = try b.db.fetchString(
            "SELECT v.id FROM variant v JOIN container_block cb ON cb.block_id = v.block_id WHERE cb.container_id = ? ORDER BY v.id LIMIT 1",
            [family.post])!
        try await b.db.write { db in
            try db.execute(
                sql: "UPDATE variant SET working_text = 'late edit' WHERE id = ?",
                arguments: [familyVariant])
        }
        #expect(try b.outboxContains("variant", familyVariant))

        // A's janitor purges: mirror + local, family-complete.
        let report = try await sweep(a, server)
        #expect(report.familiesPurged >= 1)
        #expect(report.rowsPurgedLocally > 5)
        #expect(try familyRowCount(a, post: family.post) == 0,
                "A's local family must be physically gone")
        #expect(await server.currentRow(table: "container", rowID: family.post) == nil,
                "the mirror's family must be gone")
        #expect(await server.purgedLedgerCount() > 5,
                "every purged row leaves a content-free ledger entry")
        #expect(await server.isPurged(table: "variant", rowID: familyVariant))

        // The stale peer pushes: the ledger refuses per-row with 'purged',
        // the outbox entry drops, and B's LOCAL copy goes with it — a
        // purged row cannot be resurrected, and the stores converge.
        let pushReport = try await b.push()
        #expect(pushReport.purged >= 1, "the push must be refused as purged, not accepted")
        #expect(try b.outboxContains("variant", familyVariant) == false,
                "the refused entry is dropped, never retried")
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE id = ?", [familyVariant]) == 0,
                "the purged row's local copy goes with the refusal")
        #expect(await server.currentRow(table: "variant", rowID: familyVariant) == nil,
                "nothing landed on the mirror")

        // B's own sweep reconciles the rest through the ledger scan.
        _ = try await sweep(b, server)
        #expect(try familyRowCount(b, post: family.post) == 0,
                "B converges to the purged state")
        // Explicit rounds rather than syncToQuiescence: executePurge
        // consumes a server_seq no feed row ever carries (exactly as the
        // real RPC's nextval does), so "cursor == head" is unreachable
        // when the purge is the last write — convergence is dumps + empty
        // outboxes, which is what convergence means.
        try await round(a)
        try await round(b)
        try await round(a)
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - 2. Delete Now: the intent road purges a YOUNG tombstone

    @Test func deleteNowsIntentPurgesAYoungTombstoneOnEveryDevice() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        // NO backdating — the tombstone is minutes old; the intent is the
        // impatience door (her round-3 ruling).
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 1)
        #expect(try familyRowCount(a, post: family.post) == 0)
        #expect(await server.currentRow(table: "container", rowID: family.post) == nil)
        // The intent COMPLETES (tombstoned, kept traveling) — never purged
        // itself.
        let intentState = try a.db.fetchString(
            "SELECT deleted_at FROM purge_intent WHERE table_name = 'container' AND row_id = ?",
            [family.post])
        #expect(intentState != nil, "the completed intent survives as a tombstoned row")

        // A second sweep is a no-op: an intent applied twice is one purge.
        let again = try await sweep(a, server)
        #expect(again.familiesPurged == 0)

        // B learns through the intent + the ledger and converges.
        _ = try await b.pull()
        _ = try await sweep(b, server)
        #expect(try familyRowCount(b, post: family.post) == 0)
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - 3. Intent minted twice (two devices) = one purge

    @Test func anIntentMintedOnTwoDevicesDedupesAndPurgesOnce() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        try await syncToQuiescence(a, b, server: server)

        // Both devices ask for the purge OFFLINE — two intent rows with
        // different ids for one (table, row) pair.
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        try b.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        try await syncToQuiescence(a, b, server: server)

        // The live-unique repair (§7, pure duplicate — smaller id wins)
        // leaves exactly ONE live intent on both devices.
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM purge_intent
                WHERE table_name = 'container' AND row_id = ? AND deleted_at IS NULL
                """,
                [family.post]) == 1,
                    "\(client.name): the duplicate intents must dedupe to one")
        }

        try await round(a)
        try await round(b)
        let ledgerBefore = await server.purgedLedgerCount()
        #expect(ledgerBefore == 0)
        _ = try await sweep(a, server)
        let ledgerAfterA = await server.purgedLedgerCount()
        #expect(ledgerAfterA > 0)
        _ = try await sweep(b, server)
        // B's sweep executes nothing new — the ledger set is unchanged
        // (executePurge is idempotent and B's copies were reconciled).
        #expect(await server.purgedLedgerCount() == ledgerAfterA,
                "two intents, two sweeps — ONE purge")
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try familyRowCount(a, post: family.post) == 0)
        #expect(try familyRowCount(b, post: family.post) == 0)
    }

    // MARK: - 4. The horizon: an in-window laggard HOLDS it; a 60-day
    // drop-out does not

    @Test func anInWindowLaggardHoldsTheHorizonAndADropoutDoesNot() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        // Both devices establish cursors on a shared corpus.
        try a.with { ops, _ in
            _ = try ops.createPost(title: "shared", profile: .generic)
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // A deletes a family and backdates it; B does NOT pull — its
        // cursor sits BELOW the deletion's seqs, recently seen.
        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await round(a)

        let held = try await sweep(a, server)
        #expect(held.familiesPurged == 0,
                "a live device that has not seen the deletion HOLDS the horizon")
        #expect(held.familiesDeferred >= 1)
        #expect(await server.currentRow(table: "container", rowID: family.post) != nil,
                "nothing may leave the mirror while a live device is behind")

        // B goes dark past the 60-day window (modeled in clock ticks);
        // A's fresh pull re-stamps its own seen-at.
        await server.setHorizonDropoutTicks(10)
        await server.advanceClock(by: 100)
        try await round(a)
        let after = try await sweep(a, server)
        #expect(after.familiesPurged >= 1,
                "a device unseen for 60 days leaves the horizon — purging proceeds")
        #expect(await server.currentRow(table: "container", rowID: family.post) == nil)

        // The dropout returns: its next rounds + sweep reconcile it
        // through the ledger — never a resurrection.
        try await round(b)
        _ = try await b.push()
        _ = try await sweep(b, server)
        #expect(try familyRowCount(b, post: family.post) == 0)
        // Explicit rounds, the test-1 reason: a purge consumes a seq no
        // feed row carries, so cursor==head is not the quiet condition.
        try await round(a)
        try await round(b)
        try await round(a)
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - 5. Mid-family resumption

    @Test func theJanitorResumesCleanlyAfterACrashBetweenMirrorAndLocal() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await round(a)

        // The crash shape: the mirror purge EXECUTED, the local removal
        // never ran (the janitor died between its two halves).
        let rows: [SyncPurgeTarget] = try await a.db.read { db in
            try PurgeFamily.expand(
                db, roots: [SyncPurgeTarget(table: "container", rowID: family.post)]
            ).orderedRows
        }
        _ = try await server.executePurge(rows, activeKeyID: SyncTestKeys.corpusKeyID)
        let ledger = await server.purgedLedgerCount()
        #expect(try familyRowCount(a, post: family.post) > 0,
                "the crash left the local rows standing")

        // The next sweep completes the family — through the ledger scan,
        // which is exactly why the executePurge-then-local order is safe.
        let report = try await sweep(a, server)
        #expect(report.ledgerRowsDropped > 0)
        #expect(try familyRowCount(a, post: family.post) == 0)
        #expect(await server.purgedLedgerCount() == ledger,
                "resumption re-mints nothing — the ledger set is unchanged")
        let again = try await sweep(a, server)
        #expect(again.familiesPurged == 0 && again.ledgerRowsDropped == 0,
                "a completed family stays completed")
    }

    // MARK: - 6. Pruning: Standard's numbers, Never's silence, ⌘S immunity

    @Test func pruningMintsOnlyEligibleQuietSavepointsAndNeverEverManual() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        let variantID: String = try a.with { ops, db in
            let post = try ops.createPost(title: "journal", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            // 14 old QUIET savepoints + 2 old MANUAL + 2 young quiet.
            for index in 0..<18 {
                _ = try ops.commit(made.variant.id, message: "sp\(index)")
            }
            _ = db
            return made.variant.id
        }
        // Shape the fixture by SQL: kinds + ages.
        try await a.db.write { db in
            let ids = try String.fetchAll(
                db,
                sql: "SELECT id FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                arguments: [variantID])
            for (index, id) in ids.enumerated() {
                if index < 14 {
                    try db.execute(
                        sql: "UPDATE commit_point SET kind = 'auto', created_at = ? WHERE id = ?",
                        arguments: [String(format: "2026-01-01T00:00:%02d.000Z", index), id])
                } else if index < 16 {
                    try db.execute(
                        sql: "UPDATE commit_point SET kind = 'manual', created_at = ? WHERE id = ?",
                        arguments: [String(format: "2026-01-02T00:00:%02d.000Z", index), id])
                } else {
                    try db.execute(
                        sql: "UPDATE commit_point SET kind = 'auto' WHERE id = ?",
                        arguments: [id])
                }
            }
        }
        try await round(a)

        // Standard (the default): 16 quiet − newest 10 = 6 candidates, all
        // past the 90-day bar → 6 intents. Manuals never appear.
        let first = try await sweep(a, server)
        #expect(first.pruneIntentsMinted == 6)
        let mintedFor = try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM purge_intent pi
            JOIN commit_point cp ON cp.id = pi.row_id
            WHERE pi.table_name = 'commit_point' AND cp.kind = 'manual'
            """) ?? 0
        #expect(mintedFor == 0, "deliberate savepoints NEVER prune")

        // The intents publish, then purge on the next pass.
        try await round(a)
        let second = try await sweep(a, server)
        #expect(second.familiesPurged == 6)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [variantID]) == 12,
                "18 − 6 pruned = 12 survive: the newest ten quiet and both manuals")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND kind = 'manual'",
            [variantID]) == 2)

        // Never: nothing further mints, however old the backlog grows.
        try a.with { ops, _ in try ops.setHistoryPruning(.never) }
        try await a.db.write { db in
            try db.execute(
                sql: "UPDATE commit_point SET created_at = '2025-06-01T00:00:00.000Z' WHERE kind = 'auto'")
        }
        try await round(a)
        let never = try await sweep(a, server)
        #expect(never.pruneIntentsMinted == 0, "Never means never (memo §4d)")
    }

    // MARK: - 7. No horizon ⇒ no-op

    @Test func withNoRecordedCursorsTheJanitorDoesNothing() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await a.push()  // push only: no pull ever ⇒ no device cursor

        let report = try await sweep(a, server)
        #expect(report.skippedNoHorizon, "no horizon is the designed safe no-op")
        #expect(report.familiesPurged == 0)
        #expect(try familyRowCount(a, post: family.post) > 0)
        #expect(await server.currentRow(table: "container", rowID: family.post) != nil)
        #expect(await server.purgedLedgerCount() == 0)
    }

    // MARK: - 8. The say-so-first returner road (round 10)

    @Test func aLeftBehindDeviceIsToldToReloadAndTheRoadSavesItsWriting() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            _ = try ops.createPost(title: "old corpus", profile: .generic)
        }
        try await round(a)

        // The ledger's floor moved past this device's scan point — the
        // future-pruned state the fake models (floor 0 in production
        // until the pruning rider).
        await server.setLedgerFloor(1_000)

        // Unsynced writing exists — the thing the road must save.
        let newPost: String = try a.with { ops, _ in
            try ops.createPost(title: "written while away", profile: .generic).id
        }

        // The SAY-SO: the sweep refuses with the reload error; nothing is
        // purged, nothing is lost.
        await #expect {
            _ = try await self.sweep(a, server)
        } throws: { error in
            if case .deviceLeftBehindReloadRequired(let floor, let scanPoint)? = error as? SyncError {
                return floor == 1_000 && scanPoint == 0
            }
            return false
        }

        // The road (on the user's go): unsynced writes pushed FIRST, then
        // the existing resyncReinitialize; the floor is acknowledged.
        try await a.withAsync { _ in
            let engine = a.engine()
            try await PurgeJanitor(transport: server, keyProvider: a.keyProvider)
                .reonboardFromAccount(using: engine)
        }
        #expect(await server.currentRow(table: "container", rowID: newPost) != nil,
                "anything written here first gets saved up — nothing typed is lost")

        // The gate is open again; ordinary rounds resume and converge.
        try await round(a)
        let after = try await sweep(a, server)
        #expect(after.skippedNoHorizon == false)
        #expect(try a.outboxCount() == 0)
    }
}
