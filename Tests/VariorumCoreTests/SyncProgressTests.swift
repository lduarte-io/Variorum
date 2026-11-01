import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// VX-496 — the sync row's progress (the run record `notes/plans/fixes/vx-500-sync-followups.md`, D-496). A first
/// catch-up used to read "Syncing…" for its whole length — her ~12 minutes of download and ~4 of save with nothing to
/// tell a working round from a stuck one. The engine now reports a LONG catch-up's progress through `pull(progress:)`
/// and the scheduler publishes it on its status: the download's rows so far with the server's count of the whole
/// catch-up when the transport can answer it (`SyncPullCountTransport`), then the save's rows against its batch.
/// An ordinary round — one window — reports nothing. VX-505's typed `lastErrorIsRetrying` rides the same status.
///
/// THE TOTAL'S RELATION TO THE FEED (her ruling R-500-1, VX-500 U1a): the server's count is INDEX-ONLY — owner + seq,
/// no horizon filter — so it counts the rows still inside the two-second visibility horizon that the feed will serve a
/// moment later: `total ≥ the rows served right now`, equal once the horizon has passed. The fake's count mirrors that
/// exactly (`FakeSyncServer.pullRemaining`). The equalities the pins below assert (`done == total` at the download's
/// end) are honest because these suites run the fake at its default horizon of 0 — nothing is ever inside it — and the
/// relation itself is pinned under a non-zero horizon (`theCountIsIndexOnlyAndCountsRowsStillInsideTheHorizon`).
@Suite("VX-496 — a long catch-up reports its download and its save; an ordinary round reports nothing")
struct SyncProgressTests {
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

    /// The whole feed's row count, as the fake answers the count RPC.
    private func feedCount(_ server: FakeSyncServer) async throws -> Int {
        Int(try await server.pullRemaining(
            since: 0, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull_remaining")))
    }

    /// Every status the scheduler published while `body`'s trigger ran, read until `rounds` have completed and the
    /// scheduler is idle (the stream yields the current status first, then every publish).
    private func statuses(
        of scheduler: SyncScheduler, untilRounds rounds: Int, _ body: () async throws -> Void
    ) async throws -> [SyncScheduler.Status] {
        let stream = await scheduler.statusUpdates()
        try await body()
        var seen: [SyncScheduler.Status] = []
        for await status in stream {
            seen.append(status)
            if status.roundsCompleted >= rounds, !status.isSyncing { break }
        }
        return seen
    }

    /// THE PIN: over a transport that can count (the fake server itself), a catch-up spanning many 40-row windows
    /// reports its download — every reading carrying the server's count as its total, `done` climbing monotonically to
    /// it — then its save from zero to the whole batch; the round's end clears the progress and the stores converge.
    @Test func aMultiWindowCatchUpReportsItsDownloadWithTheServersTotalThenItsSave() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        let total = try await feedCount(server)
        #expect(total > 80, "non-vacuous: more than two 40-row windows")

        let scheduler = SyncScheduler(engine: b.engine(batchSize: 40))
        let seen = try await statuses(of: scheduler, untilRounds: 1) {
            try await b.withAsync { _ in await scheduler.trigger() }
        }

        let downloading = seen.compactMap(\.progress).filter { $0.phase == .downloading }
        let saving = seen.compactMap(\.progress).filter { $0.phase == .saving }
        #expect(downloading.count >= 2, "the download reported more than once")
        #expect(downloading.allSatisfy { $0.total == total }, "every download reading carries the server's count")
        #expect(downloading.last?.done == total, "the download ended at the whole feed")
        #expect(downloading.map(\.done) == downloading.map(\.done).sorted(), "the readings never step back")
        #expect(saving.first?.done == 0 && saving.first?.total == total, "the save opens at zero of its batch")
        #expect(saving.last?.done == total && saving.last?.total == total, "the save ended whole")
        #expect(seen.last?.progress == nil && seen.last?.isSyncing == false, "the round's end clears the progress")
        #expect(seen.last?.lastError == nil)
        #expect(try b.cursor() == (await server.headSeq), "converged")
    }

    /// An everyday round — one window holds the whole feed — never carries a progress: the row keeps "Syncing…".
    @Test func anOrdinaryOneWindowRoundCarriesNoProgress() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        try seedCorpus(a, posts: 2, blocksPerPost: 2)
        try await a.push()

        let scheduler = SyncScheduler(engine: b.engine(batchSize: 200))
        let seen = try await statuses(of: scheduler, untilRounds: 1) {
            try await b.withAsync { _ in await scheduler.trigger() }
        }
        #expect(seen.contains { $0.isSyncing }, "the round ran")
        #expect(seen.allSatisfy { $0.progress == nil }, "a one-window round reports nothing")
        #expect(try b.cursor() == (await server.headSeq), "converged")
    }

    /// A transport without the count surface (a wrapper — production before `sync_pull_remaining` deploys, a 404): the
    /// download still reports its rows so far, with NO total; the save's total is the batch's own, always known.
    @Test func aTransportWithoutTheCountSurfaceReportsRowsSoFarWithoutATotal() async throws {
        let server = FakeSyncServer()
        let spy = GatedSpyTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: spy, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        let total = try await feedCount(server)

        let scheduler = SyncScheduler(engine: b.engine(batchSize: 40))
        let seen = try await statuses(of: scheduler, untilRounds: 1) {
            try await b.withAsync { _ in await scheduler.trigger() }
        }
        let downloading = seen.compactMap(\.progress).filter { $0.phase == .downloading }
        let saving = seen.compactMap(\.progress).filter { $0.phase == .saving }
        #expect(downloading.count >= 2 && downloading.allSatisfy { $0.total == nil },
                "rows so far, no total — the count surface is absent")
        #expect(downloading.last?.done == total)
        #expect(saving.last?.done == total && saving.last?.total == total, "the save's total is its own batch")
        #expect(try b.cursor() == (await server.headSeq), "converged")
    }

    /// A RESUMED catch-up (VX-494's stage) counts the staged rows as already downloaded: its first reading starts
    /// past the stage, and the download still ends at the whole feed.
    @Test func aResumedCatchUpCountsTheStagedRowsAsAlreadyDownloaded() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        try seedCorpus(a, posts: 12, blocksPerPost: 10)
        try await a.push()
        let total = try await feedCount(server)
        await transport.armFailPull(atCall: 6)
        await #expect(throws: InjectedNetworkFault.self) { try await b.pull(batchSize: 40) }
        let staged = try #require(try b.db.fetchInt("SELECT COUNT(*) FROM sync_pull_stage"))
        #expect(staged == 200, "five full windows staged before the fault")
        #expect(total > staged + 40, "non-vacuous: the resumed round's first window is full")

        let scheduler = SyncScheduler(engine: b.engine(batchSize: 40))
        let seen = try await statuses(of: scheduler, untilRounds: 1) {
            try await b.withAsync { _ in await scheduler.trigger() }
        }
        let downloading = seen.compactMap(\.progress).filter { $0.phase == .downloading }
        #expect(downloading.first?.done == staged + 40, "the first reading counts the stage plus the first new window")
        #expect(downloading.last?.done == total, "the download ended at the whole feed")
        #expect(try b.cursor() == (await server.headSeq), "converged")
    }

    /// R-500-1 — the count's relation to the feed, as the server has it: under a non-zero horizon the feed serves nothing
    /// written inside it, while the INDEX-ONLY count counts every committed row past the cursor; once the horizon has
    /// passed the feed serves exactly that many. The fake mirrors the server's shape (owner + seq, no horizon term), so a
    /// progress total can run AHEAD of the rows served by the rows still inside the horizon — never behind.
    @Test func theCountIsIndexOnlyAndCountsRowsStillInsideTheHorizon() async throws {
        let server = FakeSyncServer(visibilityHorizon: 5)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try seedCorpus(a, posts: 3, blocksPerPost: 3)
        try await a.push()

        let insideTheHorizon = try await server.pull(
            since: 0, limit: 500, activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        let countedAtOnce = try await feedCount(server)
        #expect(insideTheHorizon.isEmpty, "every row was written inside the horizon — the feed serves none yet")
        #expect(countedAtOnce > 0, "…while the index-only count already counts them all")

        await server.advanceClock(by: 5)
        let served = try await server.pull(
            since: 0, limit: 500, activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(served.count == countedAtOnce, "past the horizon the feed serves exactly what was counted")
        #expect(try await feedCount(server) == countedAtOnce, "the count never moved — it never read the horizon")
    }

    /// VX-505 (D-505): an ordinary failed round — offline, a fault — is never flagged as retrying.
    @Test func anOrdinaryErrorIsNeverFlaggedRetrying() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)
        await transport.armFailPull(atCall: 1)
        let scheduler = SyncScheduler(engine: b.engine(batchSize: 40))
        let seen = try await statuses(of: scheduler, untilRounds: 1) {
            try await b.withAsync { _ in await scheduler.trigger() }
        }
        #expect(seen.last?.lastError != nil, "the round failed")
        #expect(seen.last?.lastErrorIsRetrying == false, "a plain fault is not the belt's refusal")
    }

    /// The scheduler's monotone rule for the engine's unordered hops: a later phase advances; the same phase advances
    /// only forward; the save never steps back to the download.
    @Test func aProgressReadingOnlyAdvances() {
        let d10 = SyncProgress(phase: .downloading, done: 10, total: nil)
        let d40 = SyncProgress(phase: .downloading, done: 40, total: 100)
        let s0 = SyncProgress(phase: .saving, done: 0, total: 100)
        #expect(SyncScheduler.advances(from: d10, to: d40))
        #expect(!SyncScheduler.advances(from: d40, to: d10))
        #expect(SyncScheduler.advances(from: d40, to: d40), "an equal reading is not a step back")
        #expect(SyncScheduler.advances(from: d40, to: s0))
        #expect(!SyncScheduler.advances(from: s0, to: d40))
    }
}
