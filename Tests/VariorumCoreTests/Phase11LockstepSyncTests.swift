import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A1 — the sync shaping of the lockstep event: the §12
/// version-check mechanism (shipping NOW, with the first post-sync
/// migration that needs it) and the new tables' convergence/repair story
/// (canvas_layout + lens + lens_choice crossing the wire; block.name as
/// plain metadata CAS).
@Suite("The §12 version check (Phase 11, A1)")
struct SchemaLockstepTests {
    @Test func aBehindMirrorRefusesBothHalvesWithOutboxAndCursorIntact() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // Seed real dirty state and a real cursor first, in lockstep.
        try a.with { ops, _ in
            _ = try ops.createPost(title: "before the event", profile: .journal)
        }
        _ = try await a.push()
        _ = try await a.pull()
        let cursorBefore = try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        try a.with { ops, _ in
            _ = try ops.createPost(title: "written while the mirror lags", profile: .journal)
        }
        let outboxBefore = try a.outboxCount()
        #expect(outboxBefore > 0)

        // The mirror has NOT run 05 yet (the pre-marker deployment = 1).
        await server.setDeployedLockstepVersion(1)

        let expected = SyncError.schemaLockstepMismatch(
            client: SyncSchema.lockstepVersion, server: 1)
        await #expect(throws: expected) { _ = try await a.pull() }
        await #expect(throws: expected) { _ = try await a.push() }

        #expect(try a.outboxCount() == outboxBefore,
                "the refusal keeps the outbox byte-intact")
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == cursorBefore,
                "the refusal never moves the cursor")
        #expect(await server.rowCount(table: "container") == 1,
                "nothing was pushed past the refusal")

        // The lockstep completes (mirror migrated) — the SAME client heals
        // with no state surgery.
        await server.setDeployedLockstepVersion(SyncSchema.lockstepVersion)
        _ = try await a.pull()
        _ = try await a.push()
        #expect(try a.outboxCount() == 0)
    }

    @Test func anAheadMirrorRefusesToo() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        await server.setDeployedLockstepVersion(SyncSchema.lockstepVersion + 1)
        await #expect(throws: SyncError.schemaLockstepMismatch(
            client: SyncSchema.lockstepVersion, server: SyncSchema.lockstepVersion + 1)) {
            _ = try await a.pull()
        }
    }

    @Test func theRefusalIsVisibleAndSelfExplainingInTheStatusRow() async throws {
        let server = FakeSyncServer()
        await server.setDeployedLockstepVersion(1)
        let client = try SyncClient(name: "A", prefix: "AA", transport: server)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: server, keyProvider: FixedSyncKeyProvider()))

        try await client.withAsync { _ in await scheduler.trigger() }
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.lastError?.contains("schema versions") == true,
                "the §12 refusal surfaces as a readable message, not a case dump")
        #expect(status.lastErrorIsOffline == false,
                "a lockstep mismatch is a real refusal, never presented as offline")
    }
}

@Suite("The version RPC on the real transport (Phase 11, A1 — no network)")
struct SchemaVersionTransportTests {
    private final class OneShotHTTP: @unchecked Sendable {
        private let lock = NSLock()
        private var script: [(status: Int, body: String)]
        private(set) var requestPaths: [String] = []
        init(_ script: [(status: Int, body: String)]) { self.script = script }
        /// Synchronous under the lock; the async loader closure calls it.
        private func serve(_ request: URLRequest) throws -> (Data, URLResponse) {
            lock.lock(); defer { lock.unlock() }
            requestPaths.append(request.url?.path ?? "")
            guard !script.isEmpty else {
                throw SupabaseTransportError.malformedResult("script exhausted")
            }
            let step = script.removeFirst()
            return (Data(step.body.utf8), HTTPURLResponse(
                url: request.url!, statusCode: step.status,
                httpVersion: nil, headerFields: nil)!)
        }
        func loader() -> @Sendable (URLRequest) async throws -> (Data, URLResponse) {
            { request in try self.serve(request) }
        }
    }

    private struct FixedProvider: UserSessionProviding {
        func currentSession() async throws -> UserSession {
            UserSession(accessToken: "token", userID: "u1")
        }
        func refreshedSession() async throws -> UserSession {
            UserSession(accessToken: "fresh", userID: "u1")
        }
    }

    private func transport(_ http: OneShotHTTP) -> SupabaseTransport {
        SupabaseTransport(
            configuration: .init(
                projectURL: URL(string: "https://example.supabase.co")!,
                apiKey: "publishable-key"),
            sessionProvider: FixedProvider(), load: http.loader())
    }

    @Test func aDeployedMarkerParsesFromTheBareScalar() async throws {
        let http = OneShotHTTP([(200, "2")])
        #expect(try await transport(http).schemaVersion() == 2)
        #expect(http.requestPaths.last?.hasSuffix("sync_schema_version") == true)
    }

    @Test func aMissingRPCReadsAsThePreMarkerVersionOne() async throws {
        // PostgREST 404s an unknown function — the 9c-era deployment, so
        // the engine refuses with a self-explaining MISMATCH, not a raw
        // HTTP error.
        let http = OneShotHTTP([(404, #"{"code":"PGRST202"}"#)])
        #expect(try await transport(http).schemaVersion() == 1)
    }

    @Test func a401RefreshesOnceLikeTheOtherRPCs() async throws {
        let http = OneShotHTTP([(401, ""), (200, "3")])
        #expect(try await transport(http).schemaVersion() == 3)
    }

    @Test func garbageRefusesAsMalformed() async throws {
        let http = OneShotHTTP([(200, "not-a-number")])
        await #expect(throws: SupabaseTransportError.malformedResult(
            "sync_schema_version returned 'not-a-number', not an integer")) {
            _ = try await transport(http).schemaVersion()
        }
    }
}

@Suite("Phase 11 tables under sync (A1 — convergence + repairs)")
struct Phase11SyncConvergenceTests {
    private func makePair() throws -> (FakeSyncServer, SyncClient, SyncClient) {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        return (server, a, b)
    }

    private func syncBoth(_ a: SyncClient, _ b: SyncClient) async throws {
        // Two rounds each: enough for repairs minted on one side to reach
        // the other (the Phase 5 suites' settle recipe).
        for _ in 0..<2 {
            for client in [a, b] {
                _ = try await client.pull()
                _ = try await client.push()
            }
        }
    }

    @Test func canvasPositionRaceConvergesByCASNeverCorruption() async throws {
        let (_, a, b) = try makePair()
        // One device builds the board and syncs it over.
        let (poolID, blockID) = try a.with { ops, _ -> (String, String) in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            _ = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 0, y: 0)
            return (pool.id, block.id)
        }
        try await syncBoth(a, b)

        // Both drag the SAME card offline.
        try a.with { ops, _ in
            _ = try ops.setCanvasPosition(container: poolID, block: blockID, x: 100, y: 10)
        }
        try b.with { ops, _ in
            _ = try ops.setCanvasPosition(container: poolID, block: blockID, x: 7, y: 700)
        }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.syncedDump() == (try b.syncedDump()),
                "the drag race converges byte-identically (either position wins — CAS)")
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL") == 1)
    }

    @Test func duplicateCanvasRowsRepairToTheSmallerIDAndTheRepairPushes() async throws {
        let (_, a, b) = try makePair()
        let (poolID, blockID) = try a.with { ops, _ -> (String, String) in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            return (pool.id, block.id)
        }
        try await syncBoth(a, b)

        // BOTH devices position the never-positioned card offline — two
        // fresh rows for one (container, block) pair.
        try a.with { ops, _ in
            _ = try ops.setCanvasPosition(container: poolID, block: blockID, x: 1, y: 1)
        }
        try b.with { ops, _ in
            _ = try ops.setCanvasPosition(container: poolID, block: blockID, x: 2, y: 2)
        }
        _ = try await a.push()
        _ = try await b.pull()  // B meets A's row — the collision repairs here

        let live = try b.db.read { db in
            try Row.fetchAll(db, sql: """
                SELECT id, deleted_at FROM canvas_layout ORDER BY id
                """)
        }
        #expect(live.count == 2)
        let keeper: String = live[0]["id"]
        let loser: String = live[1]["id"]
        #expect(live[0]["deleted_at"] == nil, "the smaller id survives")
        #expect(live[1]["deleted_at"] != nil, "the duplicate tombstones")
        #expect(try b.outboxContains("canvas_layout", loser)
                    || (try b.outboxContains("canvas_layout", keeper)),
                "the repair write reaches the outbox explicitly (SyncSpec §7)")

        try await syncBoth(a, b)
        try await syncBoth(a, b)
        #expect(try a.syncedDump() == (try b.syncedDump()))
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM canvas_layout WHERE deleted_at IS NULL") == 1)
    }

    @Test func lensChoiceDuplicateAndPickRaceBothConverge() async throws {
        let (_, a, b) = try makePair()
        let world = try a.with { ops, db -> (post: String, block: String, v1: String, v2: String, lens: String) in
            let post = try ops.createPost(title: "post", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "Chosen.", at: .end)
            let alt = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let lens = try ops.createLens(post: post.id, name: "thread")
            return (post.id, minted.block.id, minted.variant.id, alt.id, lens.id)
        }
        try await syncBoth(a, b)

        // Pick race on ONE existing choice row: both devices set a different
        // take for the same block through the same lens — metadata CAS.
        try a.with { ops, _ in
            _ = try ops.setLensChoice(lens: world.lens, block: world.block, variant: world.v1)
        }
        try b.with { ops, _ in
            _ = try ops.setLensChoice(lens: world.lens, block: world.block, variant: world.v2)
        }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.syncedDump() == (try b.syncedDump()),
                "duplicate choice rows repaired (smaller id keeps) and the pick converged")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM lens_choice WHERE deleted_at IS NULL") == 1,
                "one live override per (lens, block) on every device")
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
    }

    @Test func blockNamesAndLensesCrossTheWireAsPlainMetadata() async throws {
        let (_, a, b) = try makePair()
        let blockID = try a.with { ops, _ -> String in
            let post = try ops.createPost(title: "post", profile: .generic)
            let block = try ops.newBlock(in: post.id, text: "Prose.", at: .end).block
            try ops.setBlockName(block.id, name: "the thesis")
            _ = try ops.createLens(post: post.id, name: "reader's cut")
            return block.id
        }
        try await syncBoth(a, b)

        #expect(try b.db.fetchString(
            "SELECT name FROM block WHERE id = ?", [blockID]) == "the thesis")
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM lens WHERE deleted_at IS NULL") == 1)
        #expect(try a.syncedDump() == (try b.syncedDump()))

        // Rename race: CAS, either wins, convergence holds.
        try a.with { ops, _ in try ops.setBlockName(blockID, name: "A's handle") }
        try b.with { ops, _ in try ops.setBlockName(blockID, name: "B's handle") }
        try await syncBoth(a, b)
        try await syncBoth(a, b)
        #expect(try a.syncedDump() == (try b.syncedDump()))
        let converged = try a.db.fetchString("SELECT name FROM block WHERE id = ?", [blockID])
        #expect(converged == "A's handle" || converged == "B's handle")
    }

    @Test func aDeletedPoolsCanvasAndLensRowsCascadeAcrossDevices() async throws {
        let (_, a, b) = try makePair()
        let ids = try a.with { ops, _ -> (pool: String, layout: String, post: String, lens: String, choice: String) in
            let pool = try ops.createPool(title: "board")
            let block = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            let layout = try ops.setCanvasPosition(container: pool.id, block: block.id, x: 3, y: 4)
            let post = try ops.createPost(title: "post", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            let lens = try ops.createLens(post: post.id, name: "thread")
            let choice = try ops.setLensChoice(
                lens: lens.id, block: minted.block.id, variant: minted.variant.id)
            return (pool.id, layout.id, post.id, lens.id, choice.id)
        }
        try await syncBoth(a, b)

        // B deletes both containers; the cascades must land whole on A.
        try b.with { ops, _ in
            try ops.deleteContainer(ids.pool)
            try ops.deleteContainer(ids.post)
        }
        try await syncBoth(a, b)
        try await syncBoth(a, b)

        #expect(try a.db.deletedAt("canvas_layout", ids.layout) != nil)
        #expect(try a.db.deletedAt("lens", ids.lens) != nil)
        #expect(try a.db.deletedAt("lens_choice", ids.choice) != nil)
        #expect(try a.syncedDump() == (try b.syncedDump()))
    }
}
