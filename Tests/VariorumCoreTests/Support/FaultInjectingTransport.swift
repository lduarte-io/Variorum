import Foundation
@testable import VariorumCore

/// The injected network failure — reaches the engine exactly like a dropped
/// connection would.
struct InjectedNetworkFault: Error {}

/// Phase 8, amendment A2: a fault-injecting wrapper around the Phase 5 fake
/// server. The Phase 5 correctness suite proved merges/repairs against a
/// well-behaved transport; this wrapper misbehaves in the exact ways real
/// networks do, so "safe by CAS design" becomes "safe by regression test":
///
///  - **lost ack** — the server applies a push, the response never arrives;
///  - **duplicate delivery** — one push request is applied twice (a network
///    retry the client never asked for); the first response is lost;
///  - **mid-drain failure** — a multi-row push applies partially server-side
///    before the connection dies;
///  - **stale pull replay** — one pull window is answered with the previous
///    window again (proxy/retry duplication).
///
/// Faults are one-shot: armed by a test, consumed by the next matching call,
/// then the wrapper forwards transparently (so quiescence helpers work).
actor FaultInjectingTransport: SyncTransport {
    private let server: FakeSyncServer

    private var dropAckOnNextPush = false
    private var duplicateNextPushDelivery = false
    private var failNextPushAfterRows: Int?
    private var whilePushInFlight: (@Sendable () async throws -> Void)?
    private var replayNextPull = false
    private var lastPullWindow: [SyncPulledRow] = []

    /// Calls observed, for the positive-activity assertions.
    private(set) var pushCalls = 0
    private(set) var pullCalls = 0

    init(server: FakeSyncServer) {
        self.server = server
    }

    // MARK: Arming (one-shot each)

    func armDropAckOnNextPush() { dropAckOnNextPush = true }
    func armDuplicateNextPushDelivery() { duplicateNextPushDelivery = true }
    func armFailNextPush(afterRows rows: Int) { failNextPushAfterRows = rows }
    /// Runs once, inside the next push's await window (after the server
    /// applied, before the response returns) — the (d) scenario's edit.
    func armWhileNextPushInFlight(_ hook: @escaping @Sendable () async throws -> Void) {
        whilePushInFlight = hook
    }
    func armReplayNextPull() { replayNextPull = true }

    // MARK: SyncTransport

    func schemaVersion() async -> Int {
        await server.schemaVersion()
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
        pushCalls += 1

        if let rows = failNextPushAfterRows {
            failNextPushAfterRows = nil
            // The connection dies mid-drain: only a prefix reaches the
            // server, and the client gets no outcomes at all.
            _ = try await server.push(Array(batch.prefix(rows)), activeKeyID: activeKeyID, keyProof: keyProof)
            throw InjectedNetworkFault()
        }

        if duplicateNextPushDelivery {
            duplicateNextPushDelivery = false
            // The network delivers the request twice; the first response is
            // lost and the duplicate's response is what arrives.
            _ = try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)
            return try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)
        }

        let outcomes = try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof)

        if let hook = whilePushInFlight {
            whilePushInFlight = nil
            try await hook()
        }

        if dropAckOnNextPush {
            dropAckOnNextPush = false
            throw InjectedNetworkFault()
        }
        return outcomes
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
        pullCalls += 1
        if replayNextPull, !lastPullWindow.isEmpty {
            replayNextPull = false
            return lastPullWindow
        }
        let window = try await server.pull(since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof, deviceID: deviceID)
        if !window.isEmpty { lastPullWindow = window }
        return window
    }
}
