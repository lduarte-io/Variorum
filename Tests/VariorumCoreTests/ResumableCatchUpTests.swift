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
}
