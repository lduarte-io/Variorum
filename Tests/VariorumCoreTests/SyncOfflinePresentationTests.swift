import Foundation
import Testing
@testable import VariorumCore

/// Phase 11, Step A0 — the offline-label fix (KnownIssues row re-owned from
/// Phase 10, author-approved 2026-07-12). Offline is FREE by design (A3: the
/// round is skipped, the outbox keeps everything, the next trigger retries),
/// so the status surface must present it as waiting/pending, never as
/// "SyncError". This is presentation-only classification: the round's
/// behavior (pinned by `SyncSchedulerTests`) is untouched.
@Suite("Offline presentation classification (Phase 11, A0)")
struct SyncOfflinePresentationTests {
    // MARK: - The pure classifier: error → presented state

    @Test func urlErrorNetworkDownClassesClassifyAsOffline() {
        let offlineCodes: [URLError.Code] = [
            .notConnectedToInternet, .networkConnectionLost,
            .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed,
            .timedOut, .dataNotAllowed, .internationalRoamingOff,
        ]
        for code in offlineCodes {
            #expect(SyncScheduler.isOfflineError(URLError(code)),
                    "URLError(\(code.rawValue)) is a network-down class")
        }
    }

    @Test func realRefusalsKeepTheErrorFace() {
        // HTTP refusals (auth, schema, server errors) are never "offline".
        #expect(!SyncScheduler.isOfflineError(
            SupabaseTransportError.httpFailure(status: 401, body: "forbidden")))
        #expect(!SyncScheduler.isOfflineError(
            SupabaseTransportError.httpFailure(status: 500, body: "boom")))
        #expect(!SyncScheduler.isOfflineError(SupabaseTransportError.notHTTP))
        // Non-network URLError codes stay real errors too.
        #expect(!SyncScheduler.isOfflineError(URLError(.badServerResponse)))
        #expect(!SyncScheduler.isOfflineError(URLError(.cancelled)))
        // Arbitrary domain errors are refusals.
        struct SomeFailure: Error {}
        #expect(!SyncScheduler.isOfflineError(SomeFailure()))
    }

    @Test func aWrappedUnderlyingURLErrorStillClassifiesAsOffline() {
        // A transport/auth layer may wrap the URLSession failure; the
        // classifier walks the NSError underlying chain.
        let underlying = URLError(.notConnectedToInternet) as NSError
        let wrapped = NSError(
            domain: "VariorumTest.AuthRefresh", code: 7,
            userInfo: [NSUnderlyingErrorKey: underlying])
        #expect(SyncScheduler.isOfflineError(wrapped))

        let doubleWrapped = NSError(
            domain: "VariorumTest.Outer", code: 1,
            userInfo: [NSUnderlyingErrorKey: wrapped])
        #expect(SyncScheduler.isOfflineError(doubleWrapped))
    }

    // MARK: - The scheduler surfaces the classification (behavior unchanged)

    @Test func anOfflineRoundPresentsAsWaitingWithTheOutboxIntact() async throws {
        let server = FakeSyncServer()
        let transport = OfflineOrForwardingTransport(server: server)
        let client = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: transport))

        try client.with { ops, _ in
            let entry = try ops.createPost(title: "written offline", profile: .journal)
            _ = try ops.newBlock(in: entry.id, text: "Captured in airplane mode.", at: .end)
        }
        let pendingBefore = try client.outboxCount()
        #expect(pendingBefore > 0)

        // Airplane mode: the transport throws the real URLSession offline
        // error class.
        await transport.setOfflineError(URLError(.notConnectedToInternet))
        try await client.withAsync { _ in await scheduler.trigger() }
        await scheduler.awaitIdle()

        var status = await scheduler.status
        #expect(status.lastError != nil, "the failure is still recorded verbatim")
        #expect(status.lastErrorIsOffline,
                "an offline round classifies as waiting, never a sync error")
        #expect(try client.outboxCount() == pendingBefore,
                "A3 unchanged: the offline round leaves the outbox exactly as it was")

        // Back online: one trigger drains and clears the classification.
        await transport.setOfflineError(nil)
        try await client.withAsync { _ in await scheduler.trigger() }
        await scheduler.awaitIdle()

        status = await scheduler.status
        #expect(status.lastError == nil)
        #expect(!status.lastErrorIsOffline)
        #expect(try client.outboxCount() == 0)
    }

    @Test func aRealRefusalRoundKeepsTheErrorFace() async throws {
        let server = FakeSyncServer()
        let transport = OfflineOrForwardingTransport(server: server)
        let client = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let scheduler = SyncScheduler(engine: SyncEngine(transport: transport))

        try client.with { ops, _ in
            _ = try ops.createPost(title: "refused content", profile: .journal)
        }
        await transport.setOfflineError(
            SupabaseTransportError.httpFailure(status: 500, body: "server error"))
        try await client.withAsync { _ in await scheduler.trigger() }
        await scheduler.awaitIdle()

        let status = await scheduler.status
        #expect(status.lastError != nil)
        #expect(!status.lastErrorIsOffline, "a real refusal is never presented as offline")
    }
}

/// Forwards to the fake server unless an error is installed — the offline
/// classification needs the REAL error types on the wire path.
actor OfflineOrForwardingTransport: SyncTransport {
    private let server: FakeSyncServer
    private var error: (any Error)?

    init(server: FakeSyncServer) {
        self.server = server
    }

    func setOfflineError(_ error: (any Error)?) {
        self.error = error
    }

    func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
        if let error { throw error }
        return try await server.push(batch)
    }

    func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
        if let error { throw error }
        return try await server.pull(since: since, limit: limit)
    }

    func schemaVersion() async throws -> Int {
        if let error { throw error }
        return await server.schemaVersion()
    }
}
