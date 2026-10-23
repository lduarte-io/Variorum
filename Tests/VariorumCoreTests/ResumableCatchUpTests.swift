import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// VX-494 — the first catch-up on a large library. Her real crossing (the record
/// `notes/plans/fixes/vx-494-catchup-hang.md`) needed ~16 silent, all-or-nothing minutes: the round fetched the
/// whole feed into memory in 200-row windows, then saved it in one transaction, and any interruption before that
/// commit (Castle's idle lock, a quit) threw the download away so the next round started again from 0. These pins
/// hold the three fixes: the download is RESUMABLE (D2), the production engine pulls in LARGE windows (D1), and a
/// RETIRED round stops downloading (D3). The apply transaction itself is unchanged — the existing sync suites are
/// its evidence.
@Suite("VX-494 — the first catch-up resumes, downloads in large windows, and stops when retired")
struct ResumableCatchUpTests {
    /// A corpus big enough for many windows at the test's window size.
    private func seedCorpus(_ client: SyncClient, posts: Int, blocksPerPost: Int) throws {
        try client.with { ops, _ in
            for p in 0..<posts {
                let post = try ops.createPost(title: "post \(p)", profile: .journal)
                for b in 0..<blocksPerPost {
                    _ = try ops.newBlock(in: post.id, text: "post \(p), block \(b)", at: .end)
                }
            }
        }
    }

    private func stagedRowCount(_ client: SyncClient) throws -> Int {
        try client.db.fetchInt("SELECT COUNT(*) FROM sync_pull_stage") ?? -1
    }

    /// Ladder R1's standing scene: A's 12 × 10 corpus pushed, then B's first catch-up (40-row windows) dies on its
    /// sixth window — five windows staged, nothing committed. Returns where a resume would start (the failed
    /// window's `since`). Assumes a fresh `transport`.
    private func interruptFirstCatchUp(
        _ a: SyncClient, _ b: SyncClient, transport: FaultInjectingTransport
    ) async throws -> Int64 {
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        await transport.armFailPull(atCall: 6)
        await #expect(throws: InjectedNetworkFault.self) {
            try await b.pull(batchSize: 40)
        }
        #expect(try b.cursor() == 0, "nothing committed")
        let sinces = await transport.pullSinces
        #expect(sinces.count == 6)
        let failedAt = try #require(sinces.last)
        #expect(failedAt > 0, "five windows landed before the fault")
        #expect(try stagedRowCount(b) > 0, "non-vacuous: a stage stands")
        return failedAt
    }

    /// Every `since` the transport saw while `body` ran — where each of its download windows started.
    private func sinces(
        _ transport: FaultInjectingTransport, during body: () async throws -> Void
    ) async throws -> [Int64] {
        let before = await transport.pullSinces.count
        try await body()
        return Array(await transport.pullSinces.dropFirst(before))
    }

    private struct StageHeaderMissing: Error {}

    /// Rewrites one key of the stage's `sync_state` header in place — what a stage written by another build looks
    /// like to this one.
    private func rewriteStageHeader(_ client: SyncClient, _ edit: @escaping (inout [String: Any]) -> Void) throws {
        try client.db.write { db in
            guard let value = try String.fetchOne(
                db, sql: "SELECT value FROM sync_state WHERE key = 'pull_stage'"),
                var header = try JSONSerialization.jsonObject(with: Data(value.utf8)) as? [String: Any]
            else { throw StageHeaderMissing() }
            edit(&header)
            let rewritten = try JSONSerialization.data(withJSONObject: header, options: [.sortedKeys])
            try db.execute(
                sql: "UPDATE sync_state SET value = ? WHERE key = 'pull_stage'",
                arguments: [String(decoding: rewritten, as: UTF8.self)])
        }
    }

    /// Every server row at or below `client`'s committed cursor that the client does not hold. A round that commits
    /// past rows it never applied leaves them here forever (the feed never serves them again); an honest cursor
    /// leaves this empty.
    private func rowsMissingAtOrBelowCursor(
        _ client: SyncClient, server: FakeSyncServer
    ) async throws -> [String] {
        let cursor = try client.cursor()
        let served = await server.storedRowsWithSeqs()
        return try await client.db.read { db in
            try served.filter { $0.serverSeq <= cursor }.compactMap { item in
                guard let table = SyncSchema.table(named: item.row.table) else { return item.row.table }
                let held = try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM \(table.name) WHERE \(table.primaryKey) = ?)",
                    arguments: [item.row.rowID]) ?? false
                return held ? nil : "\(item.row.table):\(item.row.rowID)@\(item.serverSeq)"
            }
        }
    }

    // MARK: D2 — the download survives an interruption

    /// THE PIN (red on the pre-fix engine: its second round starts again from 0). The download dies on its sixth
    /// window; nothing is committed (the save never ran — unchanged); the next round resumes at exactly the window
    /// that failed, downloads only the rest, and the store converges with nothing lost or doubled.
    @Test func anInterruptedFirstCatchUpResumesWhereItStopped() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        let head = await server.headSeq
        #expect(head > 300, "non-vacuous: many 40-row windows of feed")

        await transport.armFailPull(atCall: 6)
        await #expect(throws: InjectedNetworkFault.self) {
            try await b.pull(batchSize: 40)
        }
        #expect(try b.cursor() == 0, "nothing committed: the save never ran (unchanged)")
        let firstRound = await transport.pullSinces
        #expect(firstRound.count == 6)
        let failedAt = try #require(firstRound.last)
        #expect(failedAt > 0, "five windows landed before the fault")

        let report = try await b.pull(batchSize: 40)
        let secondRound = Array(await transport.pullSinces.dropFirst(firstRound.count))
        #expect(secondRound.first == failedAt,
                "the download resumes at the window that failed — never from 0")
        #expect(!secondRound.contains(0), "no window of the resumed round re-reads the start of the feed")
        #expect(try b.cursor() == head, "the resumed round commits the whole feed")
        #expect(report.applied > 0)
        #expect(!report.stalled)
        #expect(try stagedRowCount(b) == 0, "the commit empties the stage")

        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: nothing lost, nothing doubled")
    }

    /// GUARD (green on both sides by design — the pre-fix engine always starts from 0; teeth shown by reverting the
    /// identity check): a stage belongs to the round identity that fetched it. Another device identity (a copy of the
    /// library is a new device — rule 21's device ID) never resumes it: the round starts from the committed cursor.
    @Test func aStageFetchedUnderAnotherDeviceIsNeverResumed() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()

        await transport.armFailPull(atCall: 6)
        await #expect(throws: InjectedNetworkFault.self) {
            try await b.pull(batchSize: 40)
        }
        let firstRound = await transport.pullSinces
        b.deviceID = "another-device-\(UUID().uuidString.lowercased())"

        _ = try await b.pull(batchSize: 40)
        let secondRound = Array(await transport.pullSinces.dropFirst(firstRound.count))
        #expect(secondRound.first == 0, "a stage from another device identity is discarded, never resumed")
        #expect(try b.cursor() == (await server.headSeq))
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    /// GUARD: a round whose save STALLS (a row whose referent has not reached the server) keeps today's semantics
    /// exactly — the cursor holds at the stall and the stage is emptied with the commit, so the next round fetches
    /// from the stall point as before (no stale stage outlives a committed cursor).
    @Test func aStalledSaveEmptiesTheStageAndHoldsTheCursorAsBefore() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        // A straggler: a placement whose block never reached the server — pushed alone, by hand.
        let postID = try a.with { ops, _ in try ops.createPost(title: "the post", profile: .journal).id }
        try await a.push()
        let orphan = SyncRow(
            table: "container_block", rowID: "orphan-placement",
            columns: [
                "id": .text("orphan-placement"), "container_id": .text(postID),
                "block_id": .text("a-block-that-never-arrives"), "position": .text("a0"),
                "chosen_variant_id": .null, "created_at": .text("2026-07-01T00:00:00.000Z"),
                "updated_at": .text("2026-07-01T00:00:00.000Z"), "deleted_at": .null,
            ],
            syncVersion: 0)
        _ = try await server.push(
            [orphan], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))

        let report = try await b.pull(batchSize: 40)
        #expect(report.stalled, "non-vacuous: the save stalled at the orphan")
        #expect(try b.cursor() > 0, "the prefix before the stall committed")
        #expect(try b.cursor() < (await server.headSeq), "the cursor holds at the stall point")
        #expect(try stagedRowCount(b) == 0, "the commit empties the stage — the next round refetches from the stall")
    }

    // MARK: D1 — the production engine downloads in large windows

    /// THE PIN (red on the pre-fix engine: one 200-row size served push chunks and pull windows alike, so this
    /// ~1,850-row catch-up took ten windows). The production engine's pull window is its own, large size; the push
    /// chunk is untouched (the abuse guard's per-call cap is pinned against it in `AbuseGuardTests`).
    @Test func theProductionEngineDownloadsInLargeWindows() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        try seedCorpus(a, posts: 40, blocksPerPost: 15)
        try await a.push()
        let head = await server.headSeq
        #expect(head > 1_500 && head < 2_000, "non-vacuous: far more than one 200-row window, under one 2,000-row one")

        _ = try await b.withAsync { _ in
            try await SyncEngine(
                transport: transport,
                keyProvider: ClientIdentityKeyProvider(inner: b.keyProvider, deviceID: b.deviceID)
            ).pull()
        }
        #expect(try b.cursor() == head)
        #expect(await transport.pullCalls == 2,
                "the whole feed in one window, then the empty end-of-feed window")
        #expect(SyncEngine(transport: server).batchSize == 200, "the push chunk is unchanged")
    }

    // MARK: D3 — a retired round stops downloading

    /// THE PIN (red on the pre-fix scheduler: `retire()` let the in-flight round run on — after a lock it kept
    /// downloading the whole feed in the background until its save failed on the closed library). Retiring stops the
    /// round at the window in flight; it never fetches the rest, and nothing is committed.
    @Test func retiringASchedulerStopsItsInFlightDownload() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try seedCorpus(a, posts: 10, blocksPerPost: 10)
        try await a.push()
        let spy = GatedSpyTransport(server: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: spy, seed: 2)
        let scheduler = SyncScheduler(engine: b.engine(batchSize: 20))

        await spy.closeGate()
        try await b.withAsync { _ in
            await scheduler.trigger()
            await spy.awaitCallAtGate()  // the round's first download window is mid-flight
        }
        await scheduler.retire()  // the lock's teardown (SyncSession.stop)
        await spy.openGate()
        await scheduler.awaitIdle()

        let pulls = await spy.calls.filter { $0 == .pull }.count
        #expect(pulls == 1, "a retired round stops at the window in flight; it never downloads the rest")
        #expect(try b.cursor() == 0, "nothing committed")
        #expect(await scheduler.status.isSyncing == false)
    }

    // MARK: Ladder round 1 — F1: a stage nobody can vouch for is discarded, never a wedge

    /// THE PIN (F1 (2); red on the tip `5996c5d36`: `PullStage.rows` threw on the bad payload and every later round
    /// threw the same way, the cursor at 0 forever — the reviewer's probe). A staged row that will not decode costs one
    /// re-download from the committed cursor, never a wedge.
    @Test func anUndecodableStagedRowCostsOneDownloadNeverAWedge() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        _ = try await interruptFirstCatchUp(a, b, transport: transport)
        let head = await server.headSeq

        try await b.db.write { db in
            try db.execute(sql: """
                UPDATE sync_pull_stage SET payload = '{"renamed":1}'
                WHERE rowid = (SELECT MIN(rowid) FROM sync_pull_stage)
                """)
        }

        var report = SyncEngine.PullReport()
        let next = try await sinces(transport) {
            report = try await b.pull(batchSize: 40)
        }
        #expect(next.contains(0), "the stage is fetched again from the committed cursor")
        #expect(try b.cursor() == head, "the round commits the whole feed")
        #expect(report.applied > 0)
        #expect(try stagedRowCount(b) == 0, "the commit empties the stage")

        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: nothing lost, nothing doubled")
    }

    /// The shared body of the two header pins: a stage whose header names another stage `format` or another lockstep
    /// marker (a stage written by another build) is discarded and the round fetches from the committed cursor.
    private func expectRewrittenHeaderIsNeverResumed(
        _ edit: @escaping (inout [String: Any]) -> Void
    ) async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        _ = try await interruptFirstCatchUp(a, b, transport: transport)
        try rewriteStageHeader(b, edit)

        let next = try await sinces(transport) {
            _ = try await b.pull(batchSize: 40)
        }
        #expect(next.first == 0, "a stage from another build is discarded, never resumed")
        #expect(try b.cursor() == (await server.headSeq))
        #expect(try stagedRowCount(b) == 0)
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    /// THE PIN (F1 (1), the format leg; red on the tip: the header carried no format, so a stage from a build whose
    /// staged rows meant something else resumed as if it were this build's). The header's `format` one behind ⇒ fresh.
    @Test func aStageOfAnotherStageFormatIsNeverResumed() async throws {
        try await expectRewrittenHeaderIsNeverResumed {
            $0["format"] = (($0["format"] as? Int) ?? 1) - 1
        }
    }

    /// THE PIN (F1 (1), the lockstep leg; red on the tip). A marker bump is exactly when the client's wire→row
    /// transform may change: a stage fetched under another lockstep marker ⇒ fresh.
    @Test func aStageOfAnotherLockstepMarkerIsNeverResumed() async throws {
        try await expectRewrittenHeaderIsNeverResumed {
            $0["lockstep"] = (($0["lockstep"] as? Int) ?? SyncSchema.lockstepVersion) - 1
        }
    }

    // MARK: Ladder round 1 — F2: a resumed round reports nothing as this device's cursor

    /// GUARD (F2; green on the tip by design — teeth: `windowDevice` sent on "the round's first window" instead of
    /// "a window whose since is the committed cursor"). The 13j rule on a RESUMED round: its first `since` is an
    /// uncommitted fetch position, so the device id never rides it — the server's device cursor still reads the
    /// committed 0 after the interrupted and the resumed round (an over-report would let the purge horizon pass
    /// tombstones this device never integrated).
    @Test func aResumedRoundNeverReportsItsReachAsTheDevicesCursor() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        let failedAt = try await interruptFirstCatchUp(a, b, transport: transport)
        #expect(await server.deviceCursor(b.deviceID) == 0, "the interrupted round reported its committed cursor")

        let next = try await sinces(transport) {
            _ = try await b.pull(batchSize: 40)
        }
        #expect(next.first == failedAt, "non-vacuous: the round resumed")
        #expect(try b.cursor() == (await server.headSeq), "and committed")
        #expect(await server.deviceCursor(b.deviceID) == 0,
                "the resumed round's windows carried no device id — the committed 0 stands")
    }

    // MARK: Ladder round 1 — F3: the two identity lines no pin held

    /// GUARD (F3 (a); green on the tip — teeth: `plan` without its key-id leg). A stage fetched under one corpus key
    /// is never resumed under another: the account reset under a new key (the mirror wiped, the vault rewritten,
    /// A's library re-pushed under it) and B re-joined with its committed cursor still 0 — B starts from 0.
    @Test func aStageFetchedUnderAnotherCorpusKeyIsNeverResumed() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        _ = try await interruptFirstCatchUp(a, b, transport: transport)

        let rekeyed = SyncEncryptionKeys(
            corpusKey: SyncTestKeys.corpusKey, corpusKeyID: "test-corpus-key-0000000000000002",
            keyProof: SyncTestKeys.proofMaterial)
        await server.wipe()
        await server.setVaultRow(
            corpusKeyID: rekeyed.corpusKeyID, keyProofHash: SyncTestKeys.macKeyHash,
            keyProofMacSecret: SyncTestKeys.macKeyWire)
        a.keyProvider = FixedSyncKeyProvider(keys: rekeyed)
        try await a.withAsync { _ in try await a.engine().resyncReinitialize() }
        try await a.push()
        b.keyProvider = FixedSyncKeyProvider(keys: rekeyed)

        let next = try await sinces(transport) {
            _ = try await b.pull(batchSize: 40)
        }
        #expect(next.first == 0, "a stage fetched under another corpus key is discarded, never resumed")
        #expect(try b.cursor() == (await server.headSeq))
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }

    /// GUARD (F3 (b); green on the tip — teeth: `resyncReinitialize` without its `PullStage.clear`). The base-0
    /// corner the plan's base check cannot see: a first catch-up interrupted (base 0), then the wipe-and-repush
    /// (the cursor cleared — 0 again). The stage leaves with the cursor; the next round starts from 0 and never
    /// applies rows the wiped mirror no longer holds.
    @Test func reinitializingForTheWipeAndRepushEmptiesTheStage() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        _ = try await interruptFirstCatchUp(a, b, transport: transport)

        await server.wipe()
        try await b.withAsync { _ in try await b.engine().resyncReinitialize() }
        #expect(try stagedRowCount(b) == 0, "the stage extends the cursor just cleared — gone with it")

        let next = try await sinces(transport) {
            _ = try await b.pull(batchSize: 40)
        }
        #expect(next.first == 0, "the next round starts from 0")
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container WHERE title LIKE 'post %'") == 0,
                "B never applies A's rows the wiped mirror no longer holds")
    }

    // MARK: Ladder round 1 — N2: a round never commits past rows another writer cleared from under it

    /// THE PIN (N2; the interleaving the reviewer traced, built with a transport hook — red on the tip ⇒ the belt,
    /// green ⇒ record-only). One store, two rounds: B's round downloads in 20-row windows; when its third window is
    /// requested, ANOTHER round on B's store (same device, same key — a retired chain nobody drained, the
    /// `stop()` → `configure()` road) runs to its end: it resumes B's stage, stalls at a straggler placement,
    /// commits the cursor at the stall and empties the stage. B's round then fetches the rest and saves. The
    /// invariant: B's committed cursor never passes a row B does not hold — the feed never serves such a row again.
    @Test func aRoundNeverCommitsPastRowsAnotherWriterClearedFromUnderIt() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)

        // The feed: a post with one block (at or below S) · at S+1 a straggler placement whose block has not
        // reached the server · then 120 standalone posts, none referencing anything before them.
        let (postID, blockID) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the post", profile: .journal)
            return (post.id, try ops.newBlock(in: post.id, text: "the block", at: .end).block.id)
        }
        try await a.push()
        let stallPoint = await server.headSeq
        let lateBlockID = "a-block-that-arrives-late"
        let straggler = SyncRow(
            table: "container_block", rowID: "straggler-placement",
            columns: [
                "id": .text("straggler-placement"), "container_id": .text(postID),
                "block_id": .text(lateBlockID), "position": .text("b0"),
                "chosen_variant_id": .null, "created_at": .text("2026-07-01T00:00:00.000Z"),
                "updated_at": .text("2026-07-01T00:00:00.000Z"), "deleted_at": .null,
            ],
            syncVersion: 0)
        _ = try await server.push(
            [straggler], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        try a.with { ops, _ in
            for i in 0..<120 { _ = try ops.createPost(title: "standalone \(i)", profile: .journal) }
        }
        try await a.push()
        #expect(await server.headSeq - stallPoint > 100, "non-vacuous: many rows past the straggler")

        // THE INTERLEAVING (the hook runs as B's third window is requested, before the server answers it).
        let db = b.db
        let keys = ClientIdentityKeyProvider(inner: b.keyProvider, deviceID: b.deviceID)
        let otherReport = LockIsolated<SyncEngine.PullReport?>(nil)
        await transport.armWhilePull(atCall: 3) {
            let report = try await withDependencies {
                $0.database = db
                $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_865_000) }
                $0.uuid = .incrementing
                $0.ownerIdentity = OwnerIdentity { FakeSyncServer.defaultUserID }
            } operation: {
                try await SyncEngine(
                    transport: server, batchSize: 20, pullWindowSize: 20, keyProvider: keys
                ).pull()
            }
            otherReport.setValue(report)
        }

        // The round under test. A refusal is an honest answer; committing past rows it never applied is the failure.
        _ = try? await b.pull(batchSize: 20)
        #expect(otherReport.value?.stalled == true && otherReport.value?.newCursor == stallPoint,
                "non-vacuous: the other writer committed the cursor at the stall and cleared the stage")
        let missing = try await rowsMissingAtOrBelowCursor(b, server: server)
        #expect(missing.isEmpty,
                "B's committed cursor never passes a row B does not hold — \(missing.count) missing, e.g. \(missing.prefix(2))")

        // The straggler heals (its block reaches the server): both devices converge, nothing lost.
        let blockTable = try #require(SyncSchema.table(named: "block"))
        let blockRow = try #require(try await a.db.read { try SyncRow.fetch($0, table: blockTable, rowID: blockID) })
        var lateColumns = blockRow.columns
        lateColumns["id"] = .text(lateBlockID)
        lateColumns["default_variant_id"] = .null
        lateColumns["last_container_id"] = .null
        let lateBlock = try SyncTestKeys.sealedForWire(
            SyncRow(table: "block", rowID: lateBlockID, columns: lateColumns, syncVersion: 0))
        _ = try await server.push(
            [lateBlock], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: nothing lost under the interleaving")
    }
}
