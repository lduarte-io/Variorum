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
    /// VX-494: fail the Nth pull call from arming (1-based) — the download
    /// dying partway through a long first catch-up.
    private var failPullAtCall: Int?
    private var pullsSinceArm = 0
    /// VX-494 (ladder R1, N2): run a hook when the Nth pull call arrives,
    /// BEFORE the server answers it — another writer landing on the store
    /// while a round is still fetching.
    private var whilePullHook: (call: Int, hook: @Sendable () async throws -> Void)?
    private var pullsSinceHookArm = 0
    /// VX-494 (ladder R2, R2-6): run a hook before answering EACH pull call
    /// whose `since` matches, at most `remaining` times — another writer
    /// raiding the store round after round.
    private var whileEachPullHook: (
        remaining: Int, matching: @Sendable (Int64) -> Bool, hook: @Sendable () async throws -> Void
    )?
    /// VX-494: every pull call's `since`, in order — where each download
    /// window started, so a test can tell a resume from a restart.
    private(set) var pullSinces: [Int64] = []

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
    /// VX-494: the Nth pull call from now throws (1-based), once.
    func armFailPull(atCall call: Int) {
        failPullAtCall = call
        pullsSinceArm = 0
    }
    /// VX-494 (ladder R1, N2): the Nth pull call from now (1-based) first
    /// runs `hook`, once, then is answered normally. The hook must not call
    /// back into this transport.
    func armWhilePull(atCall call: Int, _ hook: @escaping @Sendable () async throws -> Void) {
        whilePullHook = (call, hook)
        pullsSinceHookArm = 0
    }
    /// VX-494 (ladder R2, R2-6): every pull call whose `since` satisfies
    /// `matching` first runs `hook`, then is answered normally — at most
    /// `times` times. The hook must not call back into this transport.
    func armWhileEachPull(
        times: Int, where matching: @escaping @Sendable (Int64) -> Bool,
        _ hook: @escaping @Sendable () async throws -> Void
    ) {
        whileEachPullHook = times > 0 ? (times, matching, hook) : nil
    }

    // MARK: SyncTransport

    func schemaVersion() async -> Int {
        await server.schemaVersion()
    }

    // 13y UNIT B: the challenge surface forwards transparently — the
    // fault arms target the DATA calls; a dropped challenge fetch is the
    // same failed-round class as a dropped version check.
    func fetchChallenges(_ count: Int) async throws -> [String] {
        try await server.fetchChallenges(count)
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        try await server.enrollKeyProof(
            legacyProof: legacyProof, macKey: macKey, activeKeyID: activeKeyID)
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
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

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        pullCalls += 1
        pullSinces.append(since)
        if let call = failPullAtCall {
            pullsSinceArm += 1
            if pullsSinceArm == call {
                failPullAtCall = nil
                throw InjectedNetworkFault()
            }
        }
        if let armed = whilePullHook {
            pullsSinceHookArm += 1
            if pullsSinceHookArm == armed.call {
                whilePullHook = nil
                try await armed.hook()
            }
        }
        if let armed = whileEachPullHook, armed.matching(since) {
            whileEachPullHook = armed.remaining > 1
                ? (armed.remaining - 1, armed.matching, armed.hook) : nil
            try await armed.hook()
        }
        if replayNextPull, !lastPullWindow.isEmpty {
            replayNextPull = false
            return lastPullWindow
        }
        let window = try await server.pull(since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof, deviceID: deviceID)
        if !window.isEmpty { lastPullWindow = window }
        return window
    }
}
