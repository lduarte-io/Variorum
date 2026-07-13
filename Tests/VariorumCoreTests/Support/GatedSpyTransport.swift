import Foundation
@testable import VariorumCore

/// A3's observation instrument: records every transport call in order,
/// can hold calls at a gate (so a test can prove a round is still running
/// when more triggers land), and can fail on demand (the offline posture).
/// Forwards to the fake server when open and healthy.
actor GatedSpyTransport: SyncTransport {
    enum Call: Equatable {
        case pull
        /// Row count carried, so "one outbox drain" is assertable.
        case push(rows: Int)
    }

    private let server: FakeSyncServer
    private(set) var calls: [Call] = []
    private var gated = false
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var arrivalWaiters: [CheckedContinuation<Void, Never>] = []
    private var failing = false

    init(server: FakeSyncServer) {
        self.server = server
    }

    /// Subsequent calls suspend at the gate until `openGate()`.
    func closeGate() { gated = true }

    func openGate() {
        gated = false
        let waiters = gateWaiters
        gateWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    /// Simulates offline: every call throws until healed.
    func setFailing(_ failing: Bool) { self.failing = failing }

    var pushedRowTotal: Int {
        calls.reduce(0) { total, call in
            if case .push(let rows) = call { return total + rows }
            return total
        }
    }

    /// Push calls that actually carried rows (an outbox drain).
    var drainingPushCalls: Int {
        calls.filter {
            if case .push(let rows) = $0 { return rows > 0 }
            return false
        }.count
    }

    /// Suspends until a transport call is waiting at the CLOSED gate — the
    /// proof a round is genuinely mid-flight (A3's "simultaneous trigger"
    /// tests need the round to have started before the next triggers land).
    func awaitCallAtGate() async {
        if !gateWaiters.isEmpty { return }
        await withCheckedContinuation { arrivalWaiters.append($0) }
    }

    private func passGate() async {
        if gated {
            await withCheckedContinuation { continuation in
                gateWaiters.append(continuation)
                let arrivals = arrivalWaiters
                arrivalWaiters.removeAll()
                for waiter in arrivals { waiter.resume() }
            }
        }
    }

    // MARK: SyncTransport

    func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
        calls.append(.push(rows: batch.count))
        if failing { throw InjectedNetworkFault() }
        await passGate()
        return try await server.push(batch)
    }

    func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
        calls.append(.pull)
        if failing { throw InjectedNetworkFault() }
        await passGate()
        return try await server.pull(since: since, limit: limit)
    }

    /// Forwards to the fake server. Deliberately unrecorded and ungated:
    /// the A3 pins assert pull/push ordering and gate arrival on the
    /// round's DATA calls; the version check is round plumbing. The
    /// failing flag still applies (offline fails the check first, which is
    /// the same skipped-round outcome the posture pins).
    func schemaVersion() async throws -> Int {
        if failing { throw InjectedNetworkFault() }
        return await server.schemaVersion()
    }
}
