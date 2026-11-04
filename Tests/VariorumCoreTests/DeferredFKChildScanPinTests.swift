//
//  DeferredFKChildScanPinTests.swift
//  VariorumCoreTests
//
//  VX-720 (VX-500 U4) — THE PIN for the v1_36 FK child indexes, in the U1b bisection's arm E/F shape, UNGATED and
//  fast. THE MECHANISM (the U1b record): under `PRAGMA defer_foreign_keys = ON` — the posture every pull apply sets
//  (SyncSpec §5) — while ANY deferred FK violation is pending, each INSERT into a parent table makes SQLite search
//  every CHILD table for rows naming the new key (sqlite.org/foreignkeys.html §4); `block.default_variant_id →
//  variant(id)` had no index, and the feed's registry order lands every block (its default pointer dangling) before
//  any take, so each of N take inserts scanned the N-row `block` table — O(N²), ~75% of a 109k-row first catch-up's
//  save. v1_36's `idx_block_default_variant` turns the scan into a probe.
//
//  THE SHAPE: a RATIO, never a tight number (the load guard — both arms run in this one test, so machine load inflates
//  them together and largely cancels). Arm "pending" is the bisection's arm E (all blocks first, each
//  `default_variant_id` naming its not-yet-inserted take, then the takes); arm "control" is arm G (the same inserts,
//  defaults NULL — no pending violation, so no child search runs). On the v1_36 tree both arms are index-probe-cheap
//  (U1b measured 20.2 vs 19.4 µs a take at 10k — ratio ≈ 1); on the tree WITHOUT the migration the pending arm pays
//  the scan (316 µs at 10k, growing with N — ratio ≈ 13–16 at this size). The bound of 4 sits ≥ 3× from both sides.
//  RED-ON-OLD is run by the traps' named scratch revert of the v1_36 registration at a committed tip (the U4 record
//  carries the failing lines); the structural arrival pin is `MigrationTests.theDeferredFKChildIndexesArriveForAnOlderStore`.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-720 — the apply-shaped take insert is an index probe, not a block-table scan (v1_36)")
struct DeferredFKChildScanPinTests {
    /// One arm: on a fresh real migrated in-memory store, in apply mode (the pull's posture), N blocks first —
    /// `default_variant_id` naming the take to come (`pendingViolations`) or NULL (the control) — then N takes,
    /// the `INSERT INTO variant` statements timed alone. The statement shapes are the U1b bisection's, verbatim.
    private func timedTakeInserts(count: Int, pendingViolations: Bool) throws -> Duration {
        let store = try AppDatabase.inMemory()
        var insertTime = Duration.zero
        try store.applyingRemote { db in
            // The pin is about FK machinery: if enforcement were off, no child search would run on ANY tree and
            // a green here would be hollow. Assert the posture rather than assume it.
            #expect(try Bool.fetchOne(db, sql: "PRAGMA foreign_keys") == true,
                    "the store enforces foreign keys — the scan this pin bounds is FK machinery")
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            let insertBlock = try db.cachedStatement(sql: """
                INSERT INTO block (id, default_variant_id, created_at, updated_at, sync_version)
                VALUES (?, ?, '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z', 1)
                """)
            let insertVariant = try db.cachedStatement(sql: """
                INSERT INTO variant (block_id, created_at, deleted_at, fan_position, id, label, locked, parent_variant_id, status,
                  updated_at, working_text, sync_version)
                VALUES (?, '2026-07-01T00:00:00.000Z', NULL, 'a0', ?, NULL, 0, NULL, 'active', '2026-07-01T00:00:00.000Z', ?, 1)
                """)
            func blockID(_ i: Int) -> String { String(format: "BB000000-0000-4000-8000-%012d", i) }
            func variantID(_ i: Int) -> String { String(format: "CC000000-0000-4000-8000-%012d", i) }
            for i in 0..<count {
                try insertBlock.execute(arguments: [blockID(i), pendingViolations ? variantID(i) : nil])
            }
            for i in 0..<count {
                let body = "post \(i % 97), block \(i % 31)"
                let start = ContinuousClock.now
                try insertVariant.execute(arguments: [blockID(i), variantID(i), body])
                insertTime += ContinuousClock.now - start
            }
            // Every pending violation is resolved by its take's arrival, so this transaction COMMITS — the feed's
            // own property, and why the apply is legal at all under deferred FKs.
        }
        return insertTime
    }

    @Test func aTakeInsertUnderPendingDeferredViolationsCostsLikeOneWithoutThem() throws {
        let count = 8_000
        let control = try timedTakeInserts(count: count, pendingViolations: false)
        let pending = try timedTakeInserts(count: count, pendingViolations: true)
        #expect(control > .zero, "non-vacuous: the control arm did real work")
        let ratio = Double(pending.components.attoseconds + pending.components.seconds * 1_000_000_000_000_000_000)
            / Double(max(1, control.components.attoseconds + control.components.seconds * 1_000_000_000_000_000_000))
        // Printed on every run (green included) so a future flake has its forensics in the log.
        print("[vx720-pin] \(count) takes: pending \(pending) · control \(control) · ratio \(String(format: "%.2f", ratio))× (bound 4)")
        #expect(ratio < 4,
                """
                a take insert under pending deferred violations costs like one without them — the child search \
                on block(default_variant_id) is an index probe, not a scan of every block (v1_36). \
                pending \(pending) vs control \(control) over \(count) takes: ratio \(String(format: "%.1f", ratio))× \
                (the un-migrated tree reads ≈ 13–16× here; the migrated one ≈ 1×)
                """)
    }
}
