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

    // MARK: - 0. The unattended janitor needs no sign-in (ladder R1 F-R1)

    /// THE UNATTENDED JANITOR PURGES WITH NO SIGN-IN ON ITS PATH (ladder R1
    /// F-R1): the 13j janitor sweeps after every clean round, unattended, on
    /// refresh tokens — nothing on `SyncScheduler`'s path signs in, and the
    /// app's `verifyPassword` discards+revokes its fresh grant so the
    /// standing session's amr never freshens. So `sync_purge_execute` must
    /// carry NO re-auth window, or server-side physical removal (a shipped
    /// privacy promise) silently stops ~10 min after the last human sign-in.
    /// This pin runs the janitor exactly as the scheduler does — NO re-auth
    /// setup anywhere — and the eligible synced family purges, ledger and
    /// all. **RED-ON-OLD (behavioral revert, recorded in the ladder file):**
    /// with the pre-fix re-auth check re-added to `executePurge` and the
    /// fake's claim at production truth (stale), this sweep threw
    /// `reauthRequired` and purged nothing.
    @Test func theUnattendedJanitorPurgesAnEligibleFamilyWithNoSignIn() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // The scheduler's unattended path: no verifyPassword, no re-auth
        // setup — exactly what the janitor sees weeks into a session.
        let report = try await sweep(a, server)
        #expect(report.familiesPurged >= 1,
                "the janitor's autonomous door runs with no fresh password")
        #expect(try familyRowCount(a, post: family.post) == 0,
                "the local family is physically gone")
        #expect(await server.currentRow(table: "container", rowID: family.post) == nil,
                "the mirror's family is gone")
        #expect(await server.purgedLedgerCount() > 0,
                "every purged row leaves a content-free ledger entry")
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
        _ = try await server.executePurge(rows, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_purge_execute"))
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

    /// pre-13x 1a (§14.37, ledger row 39): a RE-MINTED device identity (a
    /// wiped Keychain — the store keeps its cursor and its ledger scan point;
    /// only the custody item's identity is new) is a RETURNER to the purge
    /// ledger: its first round reconciles the ledger from the STORE's scan
    /// point (the rows a peer purged meanwhile are dropped locally, nothing
    /// stranded, nothing resurrected) and the server records the NEW
    /// identity's cursor; the old identity's row is simply left behind.
    /// RED ON OLD: the identity lived in `sync_state` and could not be
    /// re-minted without the store — the scenario did not exist.
    @Test func aReMintedIdentityWithANonZeroCursorIsReconciledAsAReturner() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)
        let oldIdentity = b.deviceID
        let cursorBefore = try b.cursor()
        #expect(cursorBefore > 0, "a non-zero cursor — the returner's premise")

        // A purges the family (mirror + local); B has not seen it yet.
        let report = try await sweep(a, server)
        #expect(report.familiesPurged >= 1)
        #expect(try familyRowCount(b, post: family.post) > 0, "B still holds the family")

        // B's identity is RE-MINTED (a wiped Keychain): the store is
        // untouched — cursor and ledger scan point survive.
        b.deviceID = UUID().uuidString.lowercased()
        #expect(try b.cursor() == cursorBefore)

        // The first round as a returner: the ledger scan from the STORE's
        // scan point drops the purged family locally; the new identity's
        // cursor lands on the server; the old identity's row is untouched.
        _ = try await sweep(b, server)
        try await round(b)
        #expect(try familyRowCount(b, post: family.post) == 0, "reconciled — nothing stranded")
        #expect(await server.deviceCursor(b.deviceID) != nil, "the NEW identity's cursor is recorded")
        #expect(await server.deviceCursor(oldIdentity) != nil, "the old identity's row is left behind, never rewritten")
        #expect(try b.outboxCount() == 0)
        try await round(a)
        #expect(try a.syncedDump() == b.syncedDump(), "the stores converge")
    }

    // MARK: - 9. 13j ladder B (B1): a restored family is NEVER purged by
    // its stale intent — the single-device ⌥⌘Z door (the sharper red)

    @Test func anUndoneDeleteSurvivesItsOwnStaleIntent() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        let blockID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "kept", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "restored words", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: made.block.id)])
            return made.block.id
        }
        try await round(a)

        // ⌥⌘Z: the structural undo's inverse — the belt voids the intent.
        try a.with { ops, _ in try ops.revertDeleteBlock(blockID) }
        try await round(a)

        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 0,
                "a restored, visible block is never purged by a leftover intent")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL", [blockID]) == 1,
                "the block she brought back stays")
        #expect(await server.currentRow(table: "block", rowID: blockID) != nil,
                "…and its mirror copy stays with it")
        #expect(await server.isPurged(table: "block", rowID: blockID) == false,
                "no ledger entry ever fences it")
        #expect(try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM purge_intent
            WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL
            """, [blockID]) == 0, "the stale intent is voided, not honored")
    }

    // MARK: - 10. B1's second door: a peer's Put back BEFORE the intent
    // arrives — the sweep-time staleness check is the net there

    @Test func aPeerPutBackBeforeTheIntentArrivesSurvivesTheSweep() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let blockID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "shared", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "contested", at: .end)
            _ = try ops.newBlock(in: post.id, text: "the rest", at: .end)
            try ops.deleteBlock(made.block.id)
            return made.block.id
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // A confirms Delete Now; B restores BEFORE pulling the intent —
        // B's belt finds no intent to void, so only the sweep-time
        // staleness check stands between her Put back and the purge.
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: blockID)])
        }
        try b.with { ops, _ in _ = try ops.restoreBlock(blockID) }
        try await round(b)  // the restore pushes; the intent arrives after
        try await round(a)  // A pushes the intent + pulls the restore
        try await round(b)  // B's cursor passes the intent: it is published

        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 0)
        #expect(report.staleIntentsCompleted >= 1,
                "the stale intent completes WITHOUT a purge")
        #expect(await server.currentRow(table: "block", rowID: blockID) != nil)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL",
                [blockID]) == 1, "\(client.name): the restored block survives")
        }
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        // A second sweep is quiet: the completed intent claims nothing.
        let again = try await sweep(a, server)
        #expect(again.familiesPurged == 0 && again.staleIntentsCompleted == 0)
    }

    // MARK: - 10b. VX-179: the comment kind joins the staleness net — a
    // restored comment is never purged live by its stale intent

    /// VX-179 (2026-10-12, the comment true-delete door): `block_comment`
    /// joins `purgeableTables`, so the sweep-time staleness net must know
    /// the kind too — without it, a comment restored between the intent's
    /// mint and the sweep is purged LIVE (the one outcome B1 forbids).
    /// Test 10's choreography at comment grain. The intent row is minted
    /// directly here: the door op is the run's U1 and this pin guards the
    /// janitor's net beneath it. **RED-ON-OLD (revert-verified):** with
    /// `block_comment` absent from `familyVerdict`'s `tombstonedKinds`,
    /// this sweep purges the restored comment.
    @Test func aPeerRestoredCommentBeforeItsIntentArrivesSurvivesTheSweep() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let commentID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "annotated", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "the prose", at: .end)
            let comment = try ops.addBlockComment(to: made.block.id, text: "a kept note")
            try ops.deleteBlockComment(comment.id)
            return comment.id
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // A confirms Delete forever; B restores BEFORE pulling the intent —
        // B has no intent to void, so only the sweep-time staleness check
        // stands between the restore and a live purge.
        try a.with { _, db in
            try db.write { inner in
                try PurgeIntent(
                    id: "aa-intent-comment-0001", ownerId: a.ownerID,
                    tableName: "block_comment", rowId: commentID,
                    requestedAt: Date(), createdAt: Date(), updatedAt: Date())
                    .insert(inner)
            }
        }
        try b.with { ops, _ in try ops.restoreBlockComment(commentID) }
        try await round(b)  // the restore pushes; the intent arrives after
        try await round(a)  // A pushes the intent + pulls the restore
        try await round(b)  // B's cursor passes the intent: it is published

        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 0,
                "a restored comment is never purged by its stale intent")
        #expect(report.staleIntentsCompleted >= 1,
                "the stale intent completes WITHOUT a purge")
        #expect(await server.currentRow(table: "block_comment", rowID: commentID) != nil)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE id = ? AND deleted_at IS NULL",
                [commentID]) == 1, "\(client.name): the restored comment survives")
        }
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - 11. 13j ladder B (B3, her round-11 ruling): the LOCAL road

    @Test func aNeverSyncedFamilyPurgesLocallyWithNoLedgerAndNoMirrorContact() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // NEVER a round: the free, local, never-signed-in install. The
        // family's rows sit in the outbox forever by construction — outbox
        // presence must NOT disqualify (her adopted discriminator).
        let family = try buildAndDeleteFamily(a)
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        #expect(try a.outboxContains("container", family.post))

        let report = try await a.withAsync { _ in try await LocalPurge().sweep() }
        #expect(report.familiesPurged == 1)
        #expect(try familyRowCount(a, post: family.post) == 0,
                "never-synced things really delete, right here")
        #expect(try a.outboxContains("container", family.post) == false,
                "the family's outbox entries go with it")
        #expect(await server.purgedLedgerCount() == 0,
                "no ledger entry — there is no one to fence")
        #expect(await server.headSeq == 0, "no mirror contact of any kind")
        let intentState = try a.db.fetchString(
            "SELECT deleted_at FROM purge_intent WHERE table_name = 'container' AND row_id = ?",
            [family.post])
        #expect(intentState != nil, "the intent completes locally")

        // The 30-day road runs locally too — no intent needed.
        let aged = try buildAndDeleteFamily(a)
        try backdate(a, from: aged.deletedStamp, to: oldStamp)
        let second = try await a.withAsync { _ in try await LocalPurge().sweep() }
        #expect(second.familiesPurged == 1)
        #expect(try familyRowCount(a, post: aged.post) == 0)
    }

    @Test func oneSyncedMemberMakesTheWholeFamilyWaitForTheHorizon() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        let family = try buildAndDeleteFamily(a)
        try await round(a)  // the family is on the mirror: synced
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        let local = try await a.withAsync { _ in try await LocalPurge().sweep() }
        #expect(local.familiesPurged == 0,
                "one synced member ⇒ the whole family waits (family-completeness)")
        #expect(try familyRowCount(a, post: family.post) > 0)

        // The TRANSPORTED sweep's side of the same coin (round-1
        // residuals, Obs 1 — the hardening): on a CONFIGURED chain,
        // seq-absence is not proof of mirror absence (a reinit clears the
        // seq table wholesale), so a seq-absent-but-outbox-pending family
        // DEFERS — one round of latency — then drains, becomes synced,
        // and purges through the LEDGERED road (the truer story for rows
        // the mirror did see). The outbox-blind immediate purge belongs
        // to LocalPurge alone (asserted above and in test 11).
        let fresh = try buildAndDeleteFamily(a)
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: fresh.post)])
        }
        let held = try await sweep(a, server)
        #expect(held.familiesDeferred >= 1,
                "pending-but-seq-absent defers on the transported road")
        #expect(try familyRowCount(a, post: fresh.post) > 0)
        try await round(a)
        try await round(a)
        let swept = try await sweep(a, server)
        #expect(swept.familiesPurged >= 1)
        #expect(try familyRowCount(a, post: fresh.post) == 0)
        #expect(await server.isPurged(table: "container", rowID: fresh.post),
                "drained first ⇒ the purge is ledgered like any synced family's")
        #expect(await server.currentRow(table: "container", rowID: fresh.post) == nil)
    }

    // MARK: - 14. Round-1 residuals (Obs 1): the reinit window — seq
    // absence is NOT mirror absence on a configured chain

    @Test func aReinitializedStoreNeverLocalPurgesItsSyncedFamilies() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // A synced, 30-day-old deleted family — the mirror holds it all.
        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await round(a)
        try await round(a)

        // The reinit clears sync_row_seq WHOLESALE and re-enqueues every
        // row — the mirror is untouched. A sweep in this window must not
        // read the family as local-only: a local purge here would be a
        // transient resurrection (the mirror re-serves the rows) and, on
        // the old code, rows physically removed with the mirror copies
        // still standing.
        try await a.withAsync { _ in
            try await a.engine().resyncReinitialize()
        }
        let inWindow = try await sweep(a, server)
        #expect(inWindow.familiesPurged == 0,
                "seq-absent + outbox-pending defers — never the local road")
        #expect(try familyRowCount(a, post: family.post) > 0,
                "nothing removed while the mirror still holds the family")
        #expect(await server.currentRow(table: "container", rowID: family.post) != nil)
        #expect(await server.purgedLedgerCount() == 0)

        // The window self-closes: the next rounds re-record seqs (push
        // re-accepts at CAS; pull records the rest), and the family then
        // purges through the ledgered synced road.
        try await round(a)
        try await round(a)
        let after = try await sweep(a, server)
        #expect(after.familiesPurged >= 1)
        #expect(try familyRowCount(a, post: family.post) == 0)
        #expect(await server.isPurged(table: "container", rowID: family.post))
        #expect(await server.currentRow(table: "container", rowID: family.post) == nil)
    }

    // MARK: - 12. 13j ladder B (B2): a returner's unpushed CHILD of a
    // purged family never lands as a mirror orphan — the pre-drain screen

    @Test func aReturnersUnpushedChildNeverLandsAsAMirrorOrphan() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let (postID, blockID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "shared", profile: .generic)
            let made = try ops.newBlock(in: post.id, text: "prose", at: .end)
            return (post.id, made.block.id)
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // B goes dark holding a NEVER-PUSHED child — the one id no ledger
        // can ever name, because the server never saw it.
        let commentID: String = try b.with { ops, db in
            _ = try ops.addBlockComment(to: blockID, text: "typed while away")
            return try db.fetchString(
                "SELECT id FROM block_comment WHERE block_id = ?", [blockID])!
        }
        #expect(try b.outboxContains("block_comment", commentID))

        // A deletes the note; 30 days pass; B drops out; A's janitor purges.
        try a.with { ops, _ in try ops.deleteContainer(postID) }
        let stamp = try a.db.fetchString(
            "SELECT deleted_at FROM container WHERE id = ?", [postID])!
        try backdate(a, from: stamp, to: oldStamp)
        try await round(a)
        await server.setHorizonDropoutTicks(10)
        await server.advanceClock(by: 100)
        try await round(a)
        let purged = try await sweep(a, server)
        #expect(purged.familiesPurged >= 1)

        // B returns THROUGH THE SCHEDULER — the production road: the
        // pre-drain ledger screen runs before pull→push, so the orphan
        // never pushes. (Red on the old order: the round's drain ran
        // first and landed the comment as a permanent orphan under a
        // missing parent — the poison-row jam every peer's pull would
        // then stall on forever.)
        try await b.withAsync { _ in
            let engine = b.engine()
            let janitor = PurgeJanitor(transport: server, keyProvider: b.keyProvider)
            let scheduler = SyncScheduler(engine: engine, janitor: janitor)
            await scheduler.trigger()
            await scheduler.awaitIdle()
        }
        #expect(await server.currentRow(table: "block_comment", rowID: commentID) == nil,
                "the unpushed child died with its family — never a mirror orphan")
        #expect(try b.outboxContains("block_comment", commentID) == false)
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM block_comment WHERE id = ?", [commentID]) == 0,
                "the purge-wins doctrine's letter: writing under a purged family is discarded")
        try await round(a)
        try await round(b)
        try await round(a)
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    // MARK: - 13. 13j ladder B (B9): a root collected by both arms is one
    // purge and one count

    @Test func aDoubleCollectedRootPurgesOnceAndCountsOnce() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // A 31-day-old tombstone WITH a Delete Now intent: both collection
        // arms name the same container root.
        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try a.with { ops, _ in
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: family.post)])
        }
        try await round(a)
        try await round(a)

        let report = try await sweep(a, server)
        #expect(report.familiesPurged == 1,
                "one family, however many arms collected its root")
        #expect(try familyRowCount(a, post: family.post) == 0)
    }

    // MARK: - 15. R2-M2 (13j ladder B round 2): the scheduler's pre-pass
    // carries the janitor's own preflight discipline — a schema-skewed
    // mirror's ledger is never consumed (SyncSpec §12: disagreement means
    // refusal, never improvisation)

    @Test func theLedgerPrePassRefusesASchemaSkewedMirror() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // A synced 30-day family, then a PEER's purge lands on the mirror:
        // the ledger now names rows this store still holds.
        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await round(a)
        _ = try await server.executePurge(
            [SyncPurgeTarget(table: "container", rowID: family.post)],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_purge_execute"))

        // The mirror deploys the NEXT lockstep marker: this client is now
        // BEHIND. The standalone pre-pass (the scheduler's pre-round call)
        // must refuse before consuming anything — scan point unmoved,
        // no local rows dropped. Red on the pre-R2-M2 code: reconcileLedger
        // checked keys only, so the skewed mirror's ledger was consumed
        // and the scan point advanced under semantics a future §12 event
        // may have renumbered.
        await server.setDeployedLockstepVersion(SyncSchema.lockstepVersion + 1)
        let scanBefore = try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_purge_seq'")
        do {
            _ = try await a.withAsync { _ in
                try await PurgeJanitor(transport: server, keyProvider: a.keyProvider)
                    .reconcileLedger()
            }
            Issue.record("a schema-skewed mirror must refuse the pre-pass")
        } catch let error as SyncError {
            guard case .schemaLockstepMismatch = error else {
                Issue.record("the refusal must be the §12 mismatch, got \(error)")
                return
            }
        }
        #expect(try familyRowCount(a, post: family.post) > 0,
                "nothing dropped under skew — the family still stands locally")
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_purge_seq'") == scanBefore,
                "the scan point never moves under a refusal")

        // Lockstep restored: the SAME call consumes the ledger — the claim
        // the skew arm was fencing, and the proof the refusal was the only
        // thing standing between the skewed mirror and the drop.
        await server.setDeployedLockstepVersion(SyncSchema.lockstepVersion)
        let dropped = try await a.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: a.keyProvider)
                .reconcileLedger()
        }
        #expect(dropped > 0)
        #expect(try familyRowCount(a, post: family.post) == 0)
    }

    // MARK: - RUN B B2 row 10 (17d P9): a Put back racing the sweep's mirror purge

    /// **The verifier's more-reachable road, pinned (red on old):** the
    /// janitor's `eligibleSynced` arm re-expands the family INSIDE the
    /// removal's own transaction, AFTER `executePurge` — deliberately, so
    /// "a restore that raced the await loses to the purge" (the ruled
    /// purge-wins doctrine). But `expandContainer`'s member-block arm was
    /// liveness-conditional, so a Put back landing in that network window
    /// made the root LIVE and the re-expansion took the note, its
    /// placements and its side rows while stranding the just-revived
    /// blocks — live, unplaced, `last_container_id` nulled by the survivor
    /// detachment, invisible on every surface: the partial state
    /// `PurgeFamily`'s own header contract ("purge is never partial")
    /// forbids. The fix makes the revived note lose to the purge WHOLE.
    @Test func aPutBackRacingTheSweepsMirrorPurgeNeverLeavesAPartialFamily() async throws {
        let server = FakeSyncServer()
        let hooked = ExecutePurgeHookedTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: hooked)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)

        let family = try buildAndDeleteFamily(a)
        try backdate(a, from: family.deletedStamp, to: oldStamp)
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)

        // THE RACE: the Put back lands inside the sweep's network window —
        // after the mirror purge + the ledger write, before the janitor's
        // removal transaction re-expands. (The hook binds A's store
        // directly — `SyncClient` itself is not Sendable.)
        let aStore = a.db
        await hooked.armAfterNextExecutePurge {
            try withDependencies {
                $0.database = aStore
                $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_900_000) }
                $0.uuid = .incrementing
            } operation: {
                try Operations().restoreContainer(family.post)
            }
        }
        let sweep = try await a.withAsync { _ in
            try await PurgeJanitor(transport: hooked, keyProvider: a.keyProvider).sweep()
        }
        #expect(sweep.familiesPurged >= 1, "the family was horizon-eligible and purged")

        // Purge-wins, FAMILY-COMPLETE: zero family rows survive on A — the
        // note, its placements AND its blocks. Red on old: the blocks (and
        // their takes) stayed live and orphaned behind the removed note.
        #expect(try familyRowCount(a, post: family.post) == 0)
        for block in family.blocks {
            #expect(try a.db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id = ?", [block]) == 0,
                "no live orphaned block strands behind the purged note")
            #expect(try a.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ?", [block]) == 0,
                "its takes go with it")
        }

        // The pair converges to the purge, no stall, byte-identical.
        try await round(a)
        _ = try await b.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: b.keyProvider).reconcileLedger()
        }
        try await round(b)
        let pull = try await a.pull()
        #expect(!pull.stalled)
        #expect(try familyRowCount(b, post: family.post) == 0, "B converged to the purge")
        #expect(try a.syncedDump() == b.syncedDump())
    }
}

/// RUN B B2 row 10 — the race's instrument: the verifier's road needs the
/// Put back to land INSIDE the sweep's network window (after the mirror
/// purge + ledger write, before the removal transaction). This wrapper
/// delegates every call to the fake server and runs a one-shot armed hook
/// exactly there — inside `executePurge`, after the server's work returns.
private actor ExecutePurgeHookedTransport: SyncTransport, SyncPurgeTransport {
    private let server: FakeSyncServer
    private var afterExecutePurge: (@Sendable () throws -> Void)?

    init(server: FakeSyncServer) {
        self.server = server
    }

    func armAfterNextExecutePurge(_ hook: @escaping @Sendable () throws -> Void) {
        afterExecutePurge = hook
    }

    func schemaVersion() async -> Int {
        await server.schemaVersion()
    }

    // 13y UNIT B: the challenge surface forwards transparently
    // (wrappers forward — the standing doctrine).
    func fetchChallenges(_ count: Int) async throws -> [String] {
        try await server.fetchChallenges(count)
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        try await server.enrollKeyProof(
            legacyProof: legacyProof, macKey: macKey, activeKeyID: activeKeyID)
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        try await server.pull(since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof, deviceID: deviceID)
    }

    func syncHorizon(activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64 {
        try await server.syncHorizon(activeKeyID: activeKeyID, keyProof: keyProof)
    }

    func purgeLedger(since: Int64, activeKeyID: String, keyProof: SyncKeyProof) async throws -> SyncPurgeLedgerPage {
        try await server.purgeLedger(since: since, activeKeyID: activeKeyID, keyProof: keyProof)
    }

    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64 {
        let granted = try await server.executePurge(rows, activeKeyID: activeKeyID, keyProof: keyProof)
        if let hook = afterExecutePurge {
            afterExecutePurge = nil
            try hook()
        }
        return granted
    }
}
