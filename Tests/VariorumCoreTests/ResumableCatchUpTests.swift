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
        let feed = try await stragglerFeed(a, server: server)

        // THE INTERLEAVING (the hook runs as B's third window is requested, before the server answers it).
        let otherReport = await armAnotherRound(on: b, server: server, transport: transport, atCall: 3)

        // The round under test. A refusal is an honest answer; committing past rows it never applied is the failure.
        _ = try? await b.pull(batchSize: 20)
        #expect(otherReport.value?.stalled == true && otherReport.value?.newCursor == feed.stallPoint,
                "non-vacuous: the other writer committed the cursor at the stall and cleared the stage")
        let missing = try await rowsMissingAtOrBelowCursor(b, server: server)
        #expect(missing.isEmpty,
                "B's committed cursor never passes a row B does not hold — \(missing.count) missing, e.g. \(missing.prefix(2))")

        // The straggler heals (its block reaches the server): both devices converge, nothing lost.
        try await healTheStraggler(a, server: server, blockID: feed.blockID)
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: nothing lost under the interleaving")
    }

    // MARK: The one-writer scenes (ladder R1 N2; ladder R2 R2-2 and R2-6)

    private static let lateBlockID = "a-block-that-arrives-late"

    /// The straggler feed: A's post with one block (at or below the stall point) · at the next seq a placement whose
    /// block has not reached the server · then 120 standalone posts, none referencing anything before them.
    /// `beforeTheStraggler` runs once the post is on the server, before the straggler is pushed.
    private func stragglerFeed(
        _ a: SyncClient, server: FakeSyncServer, beforeTheStraggler: () async throws -> Void = {}
    ) async throws -> (blockID: String, stallPoint: Int64) {
        let (postID, blockID) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the post", profile: .journal)
            return (post.id, try ops.newBlock(in: post.id, text: "the block", at: .end).block.id)
        }
        try await a.push()
        let stallPoint = await server.headSeq
        try await beforeTheStraggler()
        let straggler = SyncRow(
            table: "container_block", rowID: "straggler-placement",
            columns: [
                "id": .text("straggler-placement"), "container_id": .text(postID),
                "block_id": .text(Self.lateBlockID), "position": .text("b0"),
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
        return (blockID, stallPoint)
    }

    /// THE OTHER WRITER: when the `call`th pull from now is requested (before the server answers it), ANOTHER real
    /// engine round runs to its end on `client`'s store, straight to the server — same device, same key: a retired
    /// chain nobody drained (the `stop()` → `configure()` road). Its report lands in the returned box.
    private func armAnotherRound(
        on client: SyncClient, server: FakeSyncServer, transport: FaultInjectingTransport, atCall call: Int
    ) async -> LockIsolated<SyncEngine.PullReport?> {
        let db = client.db
        let keys = ClientIdentityKeyProvider(inner: client.keyProvider, deviceID: client.deviceID)
        let otherReport = LockIsolated<SyncEngine.PullReport?>(nil)
        await transport.armWhilePull(atCall: call) {
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
        return otherReport
    }

    /// The straggler heals: its block (a copy of A's under the late id) reaches the server.
    private func healTheStraggler(_ a: SyncClient, server: FakeSyncServer, blockID: String) async throws {
        let blockTable = try #require(SyncSchema.table(named: "block"))
        let blockRow = try #require(try await a.db.read { try SyncRow.fetch($0, table: blockTable, rowID: blockID) })
        var lateColumns = blockRow.columns
        lateColumns["id"] = .text(Self.lateBlockID)
        lateColumns["default_variant_id"] = .null
        lateColumns["last_container_id"] = .null
        let lateBlock = try SyncTestKeys.sealedForWire(
            SyncRow(table: "block", rowID: Self.lateBlockID, columns: lateColumns, syncVersion: 0))
        _ = try await server.push(
            [lateBlock], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
    }

    // MARK: Ladder round 2 — R2-1: a stage never outlives a purge the ledger named

    /// A stamp safely past the 30-day window for the harness clock (which starts 2026-07-01).
    private static let oldStamp = "2026-05-01T00:00:00.000Z"

    /// Backdates one deletion's EXACT stamp across every tombstoned table (the purge suite's helper).
    private func backdate(_ client: SyncClient, from original: String, to stamp: String) throws {
        try client.db.write { db in
            for table in SyncSchema.tables where table.hasTombstone {
                try db.execute(
                    sql: "UPDATE \(table.name) SET deleted_at = ? WHERE deleted_at = ?",
                    arguments: [stamp, original])
            }
        }
    }

    /// One device's committed round (the purge suite's): push, then pull twice — the second pull's first window
    /// reports the advanced cursor, which is what the horizon reads.
    private func committedRound(_ client: SyncClient) async throws {
        try await client.push()
        try await client.pull()
        try await client.pull()
    }

    private func sweep(_ client: SyncClient, _ server: FakeSyncServer) async throws -> PurgeJanitor.SweepReport {
        try await client.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: client.keyProvider).sweep()
        }
    }

    /// THE PIN (R2-1; red on the tip `b37c47c7c`: the stage resumed and the save wrote the purged note back, live, on
    /// B alone and for good — the round-2 reviewer's probe). The 13j returner road keeps purged rows off a device
    /// that left the horizon: the feed never serves them, and the pre-round ledger reconciliation drops any it still
    /// HOLDS, then moves its scan point past their entries. A staged row is held nowhere that pass looks — so a stage
    /// fetched before a ledger advance is discarded, never resumed, and the purged note never comes back.
    @Test func aStageFetchedBeforeAPurgeLandedIsNeverResumedAfterIt() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, clockOffset: 90, seed: 2)

        let doomed = try a.with { ops, _ in
            let post = try ops.createPost(title: "doomed", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Words that will be deleted.", at: .end)
            return post.id
        }
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()

        // B's first catch-up dies on its sixth window: five windows staged (the doomed note LIVE), nothing committed.
        await transport.armFailPull(atCall: 6)
        await #expect(throws: InjectedNetworkFault.self) {
            try await b.pull(batchSize: 40)
        }
        #expect(try b.cursor() == 0)
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM sync_pull_stage WHERE table_name = 'container' AND row_id = ?", [doomed]) == 1,
                "non-vacuous: the doomed note's container is staged live")

        // A deletes the note on the 30-day road (backdated); B goes dark past the 60-day window; A's sweep purges
        // the family — the mirror holds no row of it, and its ids enter the ledger.
        let stamp = try a.with { ops, db in
            try ops.deleteContainer(doomed)
            return try #require(try db.fetchString("SELECT deleted_at FROM container WHERE id = ?", [doomed]))
        }
        try backdate(a, from: stamp, to: Self.oldStamp)
        try await committedRound(a)
        await server.setHorizonDropoutTicks(10)
        await server.advanceClock(by: 100)
        try await committedRound(a)
        #expect(try await sweep(a, server).familiesPurged >= 1, "non-vacuous: the family was purged on the mirror")
        #expect(await server.currentRow(table: "container", rowID: doomed) == nil)

        // B returns: the scheduler's pre-round ledger reconciliation (B holds none of the family — only its stage
        // does — so it drops nothing and moves its scan point past the entries), then the round's pull.
        let dropped = try await b.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: b.keyProvider).reconcileLedger()
        }
        #expect(dropped == 0, "non-vacuous: the family lives only in the stage")
        let next = try await sinces(transport) {
            _ = try await b.pull(batchSize: 40)
        }
        #expect(next.first == 0, "a stage fetched before the ledger moved is discarded, never resumed")
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container WHERE id = ?", [doomed]) == 0,
                "a purged note never comes back on a returning device")

        // Explicit rounds — a purge consumes a seq no feed row carries, so cursor == head is not the quiet condition
        // (the purge suite's idiom): converged, the note nowhere.
        _ = try await sweep(b, server)
        try await committedRound(a)
        try await committedRound(b)
        try await committedRound(a)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container WHERE id = ?", [doomed]) == 0)
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: the purge holds on the returning device")
    }

    /// GUARD (R2-1, the upgrade road; red on the tip too, where no header carries the scan point): a stage header
    /// written before the stage named its ledger scan point is unreadable to this build — discarded, never resumed.
    @Test func aStageHeaderFromBeforeTheLedgerScanPointIsNeverResumed() async throws {
        try await expectRewrittenHeaderIsNeverResumed {
            $0.removeValue(forKey: "ledgerScanPoint")
        }
    }

    // MARK: Ladder round 2 — R2-2: the belt checks the stage's continuity, not only the cursor's value

    /// THE PIN (R2-2; red on the tip: the belt compared the cursor's VALUE, and a commit that stalls at its batch's
    /// FIRST row clears the stage without moving it — the round-2 reviewer's probe, 40 rows missing). B is current to
    /// the stall point, so the straggler is its next first row. B's round stages two windows; at its third, another
    /// round on B's store resumes that stage, stalls at the straggler (index 0 — the cursor unmoved) and empties the
    /// stage. B's round must refuse or commit honestly: its cursor never passes a row it does not hold.
    @Test func aRoundNeverCommitsPastRowsAFirstRowStallClearedFromUnderIt() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        let feed = try await stragglerFeed(a, server: server) {
            _ = try await b.pull(batchSize: 20)  // B committed to the stall point before the straggler exists
        }
        #expect(try b.cursor() == feed.stallPoint, "non-vacuous: the straggler is B's next first row")

        let otherReport = await armAnotherRound(on: b, server: server, transport: transport, atCall: 3)
        _ = try? await b.pull(batchSize: 20)
        #expect(otherReport.value?.stalled == true && otherReport.value?.newCursor == feed.stallPoint,
                "non-vacuous: the other writer's save stalled at its first row — the cursor unmoved — and cleared the stage")
        let missing = try await rowsMissingAtOrBelowCursor(b, server: server)
        #expect(missing.isEmpty,
                "B's committed cursor never passes a row B does not hold — \(missing.count) missing, e.g. \(missing.prefix(2))")

        try await healTheStraggler(a, server: server, blockID: feed.blockID)
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: nothing lost under the interleaving")
    }

    // MARK: Ladder round 2 — R2-6: the belt's refusal is followed at once by a healing round

    /// THE PIN (R2-6; red on the tip: the belt's refusal ended the trigger's work with its engine words on the sync
    /// row until something else triggered). The N2 interleaving, scheduled: ONE trigger, the round refused by the
    /// one-writer belt, then one follow-up round that re-plans from the committed cursor and ends clean (stalled
    /// honestly at the straggler) — the row never sits on the belt's text.
    @Test func aRoundTheOneWriterBeltRefusesIsFollowedAtOnceByAHealingRound() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        let feed = try await stragglerFeed(a, server: server)
        let otherReport = await armAnotherRound(on: b, server: server, transport: transport, atCall: 3)
        let scheduler = SyncScheduler(engine: b.engine(batchSize: 20))

        try await b.withAsync { _ in
            await scheduler.trigger()
        }
        await scheduler.awaitIdle()

        #expect(otherReport.value?.stalled == true && otherReport.value?.newCursor == feed.stallPoint,
                "non-vacuous: the other writer committed under the scheduled round")
        let status = await scheduler.status
        #expect(status.roundsCompleted == 2, "the belt's refusal is followed at once by one healing round")
        #expect(status.lastError == nil, "the healing round leaves no belt words on the row")
        #expect(try b.cursor() == feed.stallPoint, "the healing round re-planned from the committed cursor")
        let missing = try await rowsMissingAtOrBelowCursor(b, server: server)
        #expect(missing.isEmpty)
    }

    /// GUARD (R2-6's bound; red on the tip for another reason — there nothing refuses, so the raided round commits
    /// what it holds; teeth: the scheduler following every belt refusal). Another writer clears B's stage before each
    /// round's second window, three times: the belt refuses round 1, its ONE follow-up is refused too, and the
    /// scheduler then waits for the next trigger — a follow-up the belt refuses never requests another (no loop).
    @Test func theBeltsFollowUpRoundRunsOnceNeverALoop() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        try seedCorpus(a, posts: 4, blocksPerPost: 5)
        try await a.push()
        #expect(await server.headSeq > 40, "non-vacuous: more than two 20-row windows")

        let db = b.db
        await transport.armWhileEachPull(times: 3, where: { $0 > 0 }) {
            try await db.write { try PullStage.clear($0) }
        }
        let scheduler = SyncScheduler(engine: b.engine(batchSize: 20))
        try await b.withAsync { _ in
            await scheduler.trigger()
        }
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.roundsCompleted == 2, "one follow-up after the belt's refusal — and only one")
        #expect(status.lastError != nil, "the second refusal stands until the next trigger")
        #expect(try b.cursor() == 0, "nothing committed under the raids")
        let missing = try await rowsMissingAtOrBelowCursor(b, server: server)
        #expect(missing.isEmpty)
    }

    // MARK: Ladder round 3 — R3-1: a retire stops the download, never the save

    /// The mid-save hook's shared state (the SQL function below runs on B's writer, outside any actor).
    private final class MidSaveHook: @unchecked Sendable {
        var fired = false
        var scheduler: SyncScheduler?
    }

    /// THE PIN (R3-1; red on the tip `fed71e05b`: `retire()`'s cancel reached the save's GRDB write, which turned it
    /// into an interrupt — the save rolled back, the cursor at 0 and the whole download still staged; the round-3
    /// reviewer's probe). D3 stops a retired round's DOWNLOAD between windows; its SAVE is never cancelled, so a lock
    /// landing during it waits for it (`StoreBinding.lock()` checkpoints on the outgoing writer first — the behavior
    /// before D3) and the save commits. The lock, deterministically: a temp trigger on B's connection fires on the first
    /// `block` row the save writes (apply mode only) and retires the scheduler, waiting until the retire is delivered.
    @Test func aRetireDuringTheSaveLetsTheSaveCommit() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        let head = await server.headSeq

        let hook = MidSaveHook()
        let scheduler = SyncScheduler(engine: b.engine(batchSize: 40))
        hook.scheduler = scheduler
        try await b.db.write { db in
            db.add(function: DatabaseFunction("vx494_retire_mid_save", argumentCount: 0, pure: false) { _ in
                if !hook.fired, let scheduler = hook.scheduler {
                    hook.fired = true
                    let delivered = DispatchSemaphore(value: 0)
                    Task.detached {
                        await scheduler.retire()
                        delivered.signal()
                    }
                    delivered.wait()
                }
                return nil
            })
            try db.execute(sql: """
                CREATE TEMP TRIGGER vx494_retire_mid_save AFTER INSERT ON main.block
                WHEN (SELECT COUNT(*) FROM main._sync_applying) > 0
                BEGIN SELECT vx494_retire_mid_save(); END
                """)
        }

        try await b.withAsync { _ in
            await scheduler.trigger()
        }
        await scheduler.awaitIdle()

        #expect(hook.fired, "non-vacuous: the retire landed during the save")
        let cursor = try b.cursor()
        let staged = try stagedRowCount(b)
        #expect(cursor == head, "a retire that lands during the save lets the save commit")
        #expect(staged == 0, "the save's commit empties the stage")
        let status = await scheduler.status
        #expect(status.roundsCompleted == 1, "a retired scheduler starts no further round")
        #expect(status.isSyncing == false)

        // Nothing lost: the save that committed under the retire was whole.
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged: the retired round's save was the whole download")
    }
}
