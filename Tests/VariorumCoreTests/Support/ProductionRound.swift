import Foundation
import Testing
@testable import VariorumCore

/// RUN B batch B1 — **the hunt's instrument** (17i's harness-realism brief;
/// the memo `notes/plans/pre-13u-memo-sync-disagreements.md`).
///
/// PRODUCTION'S ROUND SHAPE, as `SyncScheduler.runOneRound` actually runs it
/// (A3, pinned): **pull → push**, one device at a time, with the push drain
/// chunked at `batchSize` — and each chunk is its own server transaction
/// (each `transport.push` call is one actor call on the fake, exactly as
/// each RPC call is one transaction on the real mirror). The convergence
/// suites' convenience order (push → push → pull → pull, whole outboxes in
/// one batch) is a sequence production never runs — the pre-13u ladder's
/// own lesson (R2-1/R2-2 passed in the first order and failed in the
/// second). This file gives the probes production's order — and since RUN B
/// batch B4 (ledger row 14, the postmortem's lesson-8 deliverable) it is
/// the convergence suites' DEFAULT round shape: the convenience order is
/// retired from every suite the TRAPS name, surviving only where a test's
/// SUBJECT is the order itself or its composition has no room for a round
/// (each exemption named at its line; the sweep table is the B4 record's).
///
/// What this deliberately does NOT model: the janitor legs of a scheduled
/// round (`reconcileLedger` before, `sweep` after). Purge-flavored probes
/// compose those explicitly per scenario — the janitor needs the purge
/// transport surface, which the fault-injecting wrapper does not carry.

/// One device's production round: pull, then push, both at `batchSize`
/// (transport granularity — push chunks are separate server transactions).
@discardableResult
func productionRound(
    _ client: SyncClient, batchSize: Int = 200
) async throws -> (pull: SyncEngine.PullReport, push: SyncEngine.PushReport) {
    let pull = try await client.pull(batchSize: batchSize)
    let push = try await client.push(batchSize: batchSize)
    return (pull, push)
}

/// Alternating production rounds until both devices are quiet: empty
/// outboxes, cursors at head. NOT for purge scenarios — `executePurge`
/// consumes a `server_seq` no feed row ever carries, so cursor == head is
/// unreachable when a purge is the last write (the PurgeConvergenceTests
/// idiom — explicit rounds + dump equality — serves those).
@discardableResult
func productionQuiescence(
    _ a: SyncClient, _ b: SyncClient, server: FakeSyncServer,
    batchSize: Int = 200, maxRounds: Int = 12
) async throws -> Int {
    for round in 1...maxRounds {
        _ = try await productionRound(a, batchSize: batchSize)
        _ = try await productionRound(b, batchSize: batchSize)
        let head = await server.headSeq
        let quiet = try a.outboxCount() == 0 && b.outboxCount() == 0
            && a.cursor() == head && b.cursor() == head
        if quiet { return round }
    }
    throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
}

/// THE INTERLEAVING POINTS, exposed: a weave is a list of half-rounds, so a
/// scenario can put one device's pull between another's pushes — the
/// cross-device orderings production actually produces and the convenience
/// order never does.
enum ProductionStep {
    case pull(SyncClient)
    case push(SyncClient)
}

func runProduction(_ steps: [ProductionStep], batchSize: Int = 200) async throws {
    for step in steps {
        switch step {
        case .pull(let client): _ = try await client.pull(batchSize: batchSize)
        case .push(let client): _ = try await client.push(batchSize: batchSize)
        }
    }
}

/// THE CHUNK SPLIT at a registry boundary (the P4 sweep's second axis): the
/// pusher's drain lands every table BEFORE `table` in its own committed
/// server transaction(s), then the connection dies (the armed mid-drain
/// fault) — so another device's round can run between the two halves,
/// exactly the cross-chunk window the furniture ladder's F1/F2 findings
/// came from. The pusher's own next push resumes the drain (the outbox
/// kept everything).
///
/// Uses `outboxRowsAhead(of:in:)` (FurnitureConvergenceRepairTests.swift)
/// — the drain sorts by registry order, so "rows ahead of the boundary" is
/// exactly the prefix that lands.
func pushSplitAtBoundary(
    _ pusher: SyncClient, table: String, transport: FaultInjectingTransport
) async throws {
    let ahead = try outboxRowsAhead(of: table, in: pusher)
    await transport.armFailNextPush(afterRows: ahead)
    do {
        _ = try await pusher.push()
        Issue.record("the armed mid-drain fault at the \(table) boundary did not fire")
    } catch is InjectedNetworkFault {
        // The designed split: the prefix landed, nothing from `table` on.
    }
}
