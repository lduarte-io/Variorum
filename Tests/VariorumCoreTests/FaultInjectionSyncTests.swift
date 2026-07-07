import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// Phase 8, amendment A2 — the transport fault-injection suite. Phase 5
/// proved the merge/repair logic against a well-behaved transport; these
/// scenarios exercise interrupted-network conditions the same phase real
/// networks arrive. Every scenario asserts convergence (byte-identical
/// synced tables, empty outboxes), no `working_text` loss, no spurious
/// conflict variants, bounded push cycles — and POSITIVE activity counts, so
/// an accidentally-empty scenario can never pass vacuously.
@Suite("Transport fault injection (Phase 8, A2)")
struct FaultInjectionSyncTests {
    private func conflictVariantCount(_ client: SyncClient) throws -> Int {
        try client.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") ?? 0
    }

    // MARK: (a) — response lost AFTER the server applied a push

    @Test func aLostAckReconvergesWithNoDuplicateApplicationAndNoTextLoss() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let postID = try a.with { ops, _ in
            let post = try ops.createPost(title: "written before the outage", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "The entry text.", at: .end)
            return post.id
        }

        await transport.armDropAckOnNextPush()
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        // The server applied everything; the client recorded nothing.
        #expect(await server.rowCount(table: "container") == 1)
        #expect(try a.outboxCount() > 0, "a lost ack must leave the outbox intact")

        // The retry re-pushes with a stale base; every row CAS-rejects with
        // the client's own now-winning rows and the merge recognizes them.
        let retry = try await a.push()
        #expect(retry.rejected > 0, "positive activity: the retry must actually merge rejects")
        #expect(retry.iterations <= 2, "bounded push cycles")
        #expect(try a.outboxCount() == 0)

        // No duplicate application: the CAS refused the second apply, so the
        // server row is still at version 1.
        let serverPost = await server.currentRow(table: "container", rowID: postID)
        #expect(serverPost?.syncVersion == 1)

        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariantCount(a) == 0)
        #expect(try conflictVariantCount(b) == 0)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE working_text = 'The entry text.'") != nil,
            "no text loss: the entry reached the other device")
    }

    // MARK: (e) — the lost-ack ECHO on an edited variant (the reject-path
    // twin of the pull path's merged-equals-server rule)

    @Test func theLostAckEchoMintsNoSpuriousConflictVariant() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let variantID = try a.with { ops, _ in
            let post = try ops.createPost(title: "journal", profile: .journal)
            return try ops.newBlock(in: post.id, text: "Morning page.", at: .end).variant.id
        }
        _ = try await syncToQuiescence(a, b, server: server)
        let variantsBefore = try a.db.fetchInt("SELECT COUNT(*) FROM variant") ?? 0

        // The edit whose ack gets lost.
        try a.with { ops, _ in
            try ops.autosave(variantID, text: "Morning page, revised.", charDelta: 10)
        }
        await transport.armDropAckOnNextPush()
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        // The retry pushes a stale base; the server rejects with the
        // client's OWN row (byte-equal working_text). The reject-merge must
        // recognize the echo: no conflict variant, outbox cleared.
        let retry = try await a.push()
        #expect(retry.rejected > 0, "positive activity: the echo reject was actually exercised")
        #expect(try a.outboxCount() == 0)
        #expect(try conflictVariantCount(a) == 0,
                "a lost-ack echo must never mint a spurious conflict variant")
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM variant") == variantsBefore)
        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID])
            == "Morning page, revised.")

        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariantCount(b) == 0)
    }

    // MARK: (b) — one push request delivered twice

    @Test func aDuplicatedPushDeliveryAppliesOnce() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let postID = try a.with { ops, _ in
            let post = try ops.createPost(title: "sent twice", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Delivered twice, applied once.", at: .end)
            return post.id
        }

        // The network delivers the batch twice; the first response is lost,
        // so the client sees only the duplicate's outcomes: all rejected
        // with its own rows.
        await transport.armDuplicateNextPushDelivery()
        let report = try await a.push()
        #expect(report.rejected > 0, "positive activity: the duplicate's rejects were merged")
        #expect(report.iterations <= 2, "bounded push cycles")
        #expect(try a.outboxCount() == 0)

        // Applied once: the CAS refused the duplicate, version stayed 1.
        let serverPost = await server.currentRow(table: "container", rowID: postID)
        #expect(serverPost?.syncVersion == 1)
        #expect(await server.rowCount(table: "container") == 1)

        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariantCount(a) == 0)
        #expect(try conflictVariantCount(b) == 0)
    }

    // MARK: (b′) — a stale pull window replayed mid-pull

    @Test func aStalePullReplayNeitherDuplicatesContentNorWedges() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, seed: 2)

        try a.with { ops, _ in
            _ = try ops.createPost(title: "first post", profile: .journal)
        }
        _ = try await a.push()
        let first = try await b.pull()
        #expect(first.applied > 0, "positive activity: the first window landed")

        try a.with { ops, _ in
            _ = try ops.createPost(title: "second post", profile: .journal)
        }
        _ = try await a.push()

        // The next pull is answered with the PREVIOUS window first (a stale
        // replay), then behaves — the engine must terminate, re-apply the
        // stale rows idempotently, and still land the new content.
        await transport.armReplayNextPull()
        let replayed = try await b.pull()
        #expect(replayed.applied > 0, "positive activity: the replayed pull applied rows")
        #expect(!replayed.stalled)

        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE deleted_at IS NULL") == 2,
            "each post exactly once — replay must not duplicate")
        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariantCount(b) == 0)
    }

    // MARK: (c) — connection dies mid-drain across a multi-row push

    @Test func aMidDrainFailureRetriesToConvergence() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "BB", prefix: "BB", transport: server, seed: 2)

        try a.with { ops, _ in
            _ = try ops.createPost(title: "one", profile: .journal)
            _ = try ops.createPost(title: "two", profile: .journal)
            _ = try ops.createPost(title: "three", profile: .journal)
        }
        let pending = try a.outboxCount()
        #expect(pending == 6, "3 containers + the 3 seeded settings")

        // Only a prefix reaches the server before the connection dies.
        await transport.armFailNextPush(afterRows: 4)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        #expect(try a.outboxCount() == pending, "a mid-drain failure must leave the whole outbox")

        // The retry: the applied prefix CAS-rejects as echoes, the remainder
        // accepts fresh — one call, bounded.
        let retry = try await a.push()
        #expect(retry.rejected == 4, "positive activity: the applied prefix merged as echoes")
        #expect(retry.accepted == 2, "positive activity: the unapplied remainder landed")
        #expect(retry.iterations <= 2)
        #expect(try a.outboxCount() == 0)
        #expect(await server.rowCount(table: "container") == 3)

        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try conflictVariantCount(a) == 0)
        #expect(try conflictVariantCount(b) == 0)
    }

    // MARK: (d) — a local edit lands during the push await

    @Test func anEditLandingDuringThePushAwaitStaysEnqueuedAndWins() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)

        let variantID = try a.with { ops, _ in
            let post = try ops.createPost(title: "journal", profile: .journal)
            return try ops.newBlock(in: post.id, text: "Draft.", at: .end).variant.id
        }
        _ = try await syncToQuiescence(a, b, server: server)

        // The edit that goes out on the wire…
        try a.with { ops, _ in
            try ops.autosave(variantID, text: "Draft, first revision.", charDelta: 16)
        }
        // …and the newer edit that lands while the ack is still in flight.
        // (The hook binds its own dependency world: only Sendable values
        // cross into the transport actor.)
        let db = a.db
        await transport.armWhileNextPushInFlight {
            try withDependencies {
                $0.database = db
                $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_865_000) }
                $0.uuid = .incrementing
            } operation: {
                try Operations().autosave(
                    variantID, text: "Draft, second revision — mid-flight.", charDelta: 20)
            }
        }

        let report = try await a.push()
        // Phase 5's clear-vs-re-dirty payload comparison, pinned end-to-end:
        // the accept must NOT clear the re-dirtied entry; the next iteration
        // ships the newer text on top of the granted version. Each autosave
        // dirties the variant AND its container's touch stamp, so both
        // iterations carry two rows.
        #expect(report.accepted == 4, "positive activity: the stale flush AND the newer text landed")
        #expect(report.iterations == 2, "bounded: one follow-up iteration, no loop")
        #expect(try a.outboxCount() == 0)
        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID])
            == "Draft, second revision — mid-flight.")
        #expect(try conflictVariantCount(a) == 0, "the newer edit wins by CAS, never as a conflict card")

        _ = try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID])
            == "Draft, second revision — mid-flight.")
        #expect(try conflictVariantCount(b) == 0)
    }
}
