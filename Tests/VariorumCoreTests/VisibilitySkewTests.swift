import Foundation
import Testing
@testable import VariorumCore

/// Phase 8, amendment A5 — the changefeed visibility skew (SyncSpec §5,
/// found via the Fragments post-mortem 2026-07-07).
///
/// The mechanism: `server_seq` is assigned at WRITE time (trigger, inside
/// the transaction) but the row becomes visible at COMMIT time. Two
/// concurrent pushes can commit out of seq order; a pull racing them reads
/// past the gap, advances its cursor beyond a not-yet-visible lower seq, and
/// that row is **skipped forever** — client-side atomicity never touches
/// this. The fix is server-side: the changefeed serves only rows older than
/// a visibility horizon (mirrors gain `server_written_at`; the RPC excludes
/// rows written within ~2 s — 03_visibility_horizon.sql).
///
/// A synchronous fake server can never surface this class by accident, so
/// the fake gains an in-flight-transaction mode; these tests reproduce the
/// skip on the pre-fix shape (horizon 0) and pin that the horizon closes it.
@Suite("Changefeed visibility skew (Phase 8, A5)")
struct VisibilitySkewTests {
    /// Devices A and B each push one post; A's push transaction is held open
    /// while B's commits, so B's row (higher seq) is visible first.
    private struct Skew {
        let server: FakeSyncServer
        let observer: SyncClient
        let postA: String
        let postB: String
    }

    private func makeSkew(horizon: Int64) async throws -> Skew {
        let server = FakeSyncServer(visibilityHorizon: horizon)
        let deviceA = try SyncClient(name: "A", prefix: "AA", transport: server)
        let deviceB = try SyncClient(name: "B", prefix: "BB", transport: server, seed: 2)
        let observer = try SyncClient(name: "C", prefix: "CC", transport: server, seed: 3)

        let postA = try deviceA.with { ops, _ in
            try ops.createPost(title: "held-open transaction", profile: .journal).id
        }
        let postB = try deviceB.with { ops, _ in
            try ops.createPost(title: "commits first", profile: .journal).id
        }
        // A's transaction opens first (lower seq) but stays uncommitted
        // while B's commits around it.
        await server.holdNextPush()
        _ = try await deviceA.push()
        _ = try await deviceB.push()
        return Skew(server: server, observer: observer, postA: postA, postB: postB)
    }

    /// The pre-fix server (horizon 0): the racing pull reads past the hidden
    /// lower seq, the cursor advances beyond it, and the row is skipped
    /// FOREVER — the flaw, reproduced and documented.
    @Test func anUnfixedPullSkipsARowHiddenByAnInFlightTransaction() async throws {
        let skew = try await makeSkew(horizon: 0)

        // The racing pull: B's row (seq 2) is visible, A's (seq 1) is not.
        let first = try await skew.observer.pull()
        #expect(first.applied == 1)

        // A's transaction commits — at its ORIGINAL seq, below the cursor.
        await skew.server.commitHeldPushes()
        let second = try await skew.observer.pull()
        #expect(second.applied == 0, "the skipped row must stay invisible for this pin to be honest")

        let hasA = try skew.observer.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [skew.postA])
        let hasB = try skew.observer.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [skew.postB])
        #expect(hasB == 1)
        #expect(hasA == 0, "horizon-0 pull was expected to skip the held row forever — if it arrived, the fake no longer models the skew")
    }

    /// The fixed server (a nonzero horizon): rows younger than the horizon
    /// are never served, so a pull can never advance past a seq that might
    /// still be hidden — every committed row is eventually served, exactly
    /// once.
    @Test func theVisibilityHorizonNeverSkipsACommittedRow() async throws {
        let skew = try await makeSkew(horizon: 2)

        // The racing pull sees NOTHING: both rows are younger than the
        // horizon (this is the fix — the head is served slightly delayed).
        let racing = try await skew.observer.pull()
        #expect(racing.applied == 0)

        // A's transaction commits; time passes beyond the horizon.
        await skew.server.commitHeldPushes()
        await skew.server.advanceClock(by: 3)

        let settled = try await skew.observer.pull()
        #expect(settled.applied == 2, "both rows served once the horizon passes")

        // Exactly once, in seq order, nothing lost: both posts present, and
        // a further pull finds nothing new.
        let again = try await skew.observer.pull()
        #expect(again.applied == 0)
        let hasA = try skew.observer.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [skew.postA])
        let hasB = try skew.observer.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE id = ?", [skew.postB])
        #expect(hasA == 1)
        #expect(hasB == 1)
    }
}
