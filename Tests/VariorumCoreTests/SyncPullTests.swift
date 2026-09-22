import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The pull half (SyncSpec §5): one apply-mode transaction with deferred
/// FKs, clean rows verbatim, dirty rows through the merge, an in-transaction
/// cursor, and straggler tolerance.
///
/// RUN B batch B4 (ledger row 14) — the sweep's ruling for this suite: the
/// SUBJECT here is ONE HALF of the round (the pull's own apply mechanics),
/// so most tests have no room for a full round — a bare pull IS
/// production's first half, and the `ScriptedTransport` tests craft batch
/// shapes no round-trip can produce (the transport cannot even accept a
/// push). Stagings that drive a real device's round use `productionRound`;
/// the two echo tests keep push-then-pull deliberately: that sequence is
/// production's own ADJACENT halves (round N's push, round N+1's pull),
/// and the echo between them is the subject itself.
@Suite("Pull engine & apply mode (Phase 5, Step 4)")
struct SyncPullTests {
    // MARK: - Clean apply

    @Test func cleanApplyWritesRowsAndVersionsAndReEnqueuesNothing() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "hello", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "an entry", at: .end)
        }
        _ = try await productionRound(a)

        let report = try await b.pull()
        #expect(report.applied > 0)
        #expect(report.stalled == false)
        // The world arrived…
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container") == 1)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM block") == 1)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant") == "an entry")
        // …with the server's versions, no version-0 stragglers…
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM container WHERE sync_version = 0") == 0)
        // …the cursor at head, seq bookkeeping recorded…
        #expect(try b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'")
                == String(await server.headSeq))
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM sync_row_seq")! > 0)
        // …and NOTHING re-enqueued: echo suppression end-to-end. (B's three
        // seeded settings were dirty and merged clean — also cleared.)
        #expect(try b.outboxCount() == 0)
    }

    // B4 exempt: the SUBJECT is the order itself — a push followed by its
    // own echo pull, which is production's adjacent halves.
    @Test func echoOfOwnPushAppliesAsANoOp() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            _ = try ops.createPost(title: "mine", profile: nil)
        }
        try await a.push()
        let before = try a.syncedDump()
        try await a.pull()  // the changefeed now replays A's own rows
        #expect(try a.syncedDump() == before, "an echo must change nothing")
        #expect(try a.outboxCount() == 0)
    }

    @Test func windowSizeNeverAffectsTheOutcome() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.newBlock(in: post.id, text: "one", at: .end)
            _ = try ops.newBlock(in: post.id, text: "two", at: .end)
            let reading = try ops.createReading(name: "r", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
        }
        _ = try await productionRound(a)

        // Two fresh devices, one pulling in windows of 1, one in windows of
        // 100: same converged bytes (the apply transaction always covers the
        // full fetched set — window size is transport granularity only).
        let tiny = try SyncClient(name: "T", prefix: "CC", transport: server)
        let wide = try SyncClient(name: "W", prefix: "DD", transport: server)
        try await tiny.pull(batchSize: 1)
        try await wide.pull(batchSize: 100)
        #expect(try tiny.syncedDump() == wide.syncedDump())
    }

    // MARK: - Dirty rows merge

    @Test func dirtyRowMergesAndTheConflictVariantSurfaces() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server)
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "p", profile: nil)
            return try ops.newBlock(in: post.id, text: "shared base", at: .end).variant.id
        }
        _ = try await productionRound(a)
        try await b.pull()

        // Both edit offline. A rounds first: its edit is server truth.
        try a.with { ops, _ in try ops.autosave(variantID, text: "A's take", charDelta: 3) }
        _ = try await productionRound(a)
        try b.with { ops, _ in try ops.autosave(variantID, text: "B's take", charDelta: 3) }

        let report = try await b.pull()
        #expect(report.merged >= 1)
        // Server text won the row; B's take became a conflict card, enqueued.
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID]) == "A's take")
        let conflictID = try b.db.fetchString(
            "SELECT id FROM variant WHERE label = 'conflict'")
        #expect(conflictID != nil)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [conflictID ?? ""]) == "B's take")
        #expect(try b.outboxContains("variant", conflictID ?? ""),
                "the conflict card must push, or the devices diverge")
    }

    /// The echo guard (Phase 5 review BLOCKER): pulling this device's own
    /// accepted row while the author has typed past it must NOT merge — the
    /// incoming version is not newer than what was already integrated, so
    /// the local edit is a pending CAS win. Merging would revert the buffer
    /// under her cursor and demote the newer text to a spurious 'conflict'
    /// card on every push→type→pull cycle.
    // B4 exempt: the SUBJECT is the order itself — push, type, then the
    // periodic pull replaying the device's own rows (adjacent production
    // halves with the author's typing between them).
    @Test func pullingYourOwnEchoWhileTypingNeitherRevertsNorForksTheBuffer() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "p", profile: .journal)
            return try ops.newBlock(in: post.id, text: "pushed text", at: .end).variant.id
        }
        try await a.push()

        // The author keeps typing after the push…
        try a.with { ops, _ in
            try ops.autosave(variantID, text: "newer text, still typing", charDelta: 8)
        }
        // …then a periodic pull replays the device's own accepted rows.
        try await a.pull()

        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID])
            == "newer text, still typing", "the buffer must not revert under the cursor")
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM variant WHERE label = 'conflict'") == 0,
            "no conflict existed — no card")
        #expect(try a.outboxContains("variant", variantID), "the edit still ships")

        // And the next push lands it cleanly on top of the same version.
        try await a.push()
        #expect(try a.outboxCount() == 0)
        let serverRow = await server.currentRow(table: "variant", rowID: variantID)
        #expect(try SyncTestKeys.openedText(serverRow, column: "working_text")
                == "newer text, still typing")
    }

    /// The straggler guard runs to a FIXPOINT (Phase 5 review MAJOR): a
    /// prefix row whose referent arrives at/after the stop point must ALSO
    /// stall — otherwise the deferred-FK commit fails and every retry
    /// rolls the whole batch back instead of stalling gracefully.
    // B4 exempt: ScriptedTransport — no room for a round (crafted batch
    // shapes; the transport takes no pushes).
    @Test func prefixRowLeaningOnAPostStopReferentStallsInsteadOfFailing() async throws {
        let scripted = ScriptedTransport(rows: [
            // b1 leans on v1, which arrives AFTER b2 — and b2 leans on a
            // variant the server has never seen.
            SyncPulledRow(row: TestRows.block(id: "b1", defaultVariant: "v1"), serverSeq: 1),
            SyncPulledRow(row: TestRows.block(id: "b2", defaultVariant: "v-never-pushed"), serverSeq: 2),
            SyncPulledRow(row: try TestRows.variant(id: "v1", block: "b1", text: "hi"), serverSeq: 3),
        ])
        let b = try SyncClient(name: "B", prefix: "BB", transport: scripted)
        let first = try await b.pull()  // must not throw
        #expect(first.stalled == true)
        #expect(first.applied == 0, "b1's referent sits past the stop — the whole prefix shrinks")
        let heldCursor = try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        #expect(heldCursor == nil || heldCursor == "0", "cursor holds at its origin")

        // The owing device finally ships the missing variant: everything
        // applies in one healed batch.
        await scripted.append([
            SyncPulledRow(row: try TestRows.variant(id: "v-never-pushed", block: "b2", text: "late"), serverSeq: 4)
        ])
        let second = try await b.pull()
        #expect(second.stalled == false)
        #expect(second.applied == 4)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM block") == 2)
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == "4")
    }

    // MARK: - Atomicity: one transaction, cursor inside it

    // B4 exempt: ScriptedTransport — no room for a round.
    @Test func aFailingRowRollsBackTheWholeBatchAndTheCursor() async throws {
        let b = try SyncClient(
            name: "B", prefix: "BB",
            transport: ScriptedTransport(rows: []))
        let postID: String = try b.with { ops, _ in
            try ops.createPost(title: "before", profile: nil).id
        }
        try b.db.clearOutbox()

        var retitle = try await b.db.read {
            try SyncRow.fetch($0, table: SyncSchema.table(named: "container")!, rowID: postID)!
        }
        retitle.columns["title"] = .text("after")
        retitle.syncVersion = 2
        var bogus = retitle
        bogus.columns["id"] = .text("c-bogus")
        bogus.columns["kind"] = .text("not-a-kind")  // violates the CHECK
        let bogusRow = SyncRow(
            table: "container", rowID: "c-bogus", columns: bogus.columns, syncVersion: 1)

        // Each crafted wire row seals under its OWN rowID (the AAD binds
        // per-row) — the failure under test must stay the CHECK violation
        // at apply, never a decrypt refusal.
        let scripted = ScriptedTransport(rows: [
            SyncPulledRow(row: try SyncTestKeys.sealedForWire(retitle), serverSeq: 1),
            SyncPulledRow(row: try SyncTestKeys.sealedForWire(bogusRow), serverSeq: 2),
        ])
        let engine = SyncEngine(transport: scripted, keyProvider: FixedSyncKeyProvider())
        await #expect(throws: (any Error).self) {
            try await withDependenciesForTest(db: b.db) {
                try await engine.pull()
            }
        }
        // Everything rolled back: the valid first row AND the cursor.
        #expect(try b.db.fetchString("SELECT title FROM container WHERE id = ?", [postID]) == "before")
        #expect(try b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == nil)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM sync_row_seq") == 0)
    }

    /// A multi-row structural op split across tiny pull windows still lands
    /// in ONE transaction: child rows may precede their parents in seq order
    /// and deferred FKs resolve at commit (SyncSpec §5).
    // B4 exempt: ScriptedTransport — no room for a round.
    @Test func childBeforeParentWithinOneBatchCommitsUnderDeferredFKs() async throws {
        let b = try SyncClient(name: "B", prefix: "BB", transport: ScriptedTransport(rows: []))
        // Craft a world where the variant (child) carries a LOWER seq than
        // its block (parent), and the block a lower seq than its container.
        let scripted = ScriptedTransport(rows: [
            SyncPulledRow(row: try TestRows.variant(id: "v1", block: "b1", text: "hi"), serverSeq: 1),
            SyncPulledRow(row: TestRows.block(id: "b1", defaultVariant: "v1"), serverSeq: 2),
            SyncPulledRow(row: TestRows.placement(id: "p1", container: "c1", block: "b1", chosen: "v1"), serverSeq: 3),
            SyncPulledRow(row: try TestRows.container(id: "c1", title: "post"), serverSeq: 4),
        ])
        let engine = SyncEngine(
            transport: scripted, batchSize: 1,  // one row per window
            keyProvider: FixedSyncKeyProvider())
        let report = try await withDependenciesForTest(db: b.db) {
            try await engine.pull()
        }
        #expect(report.applied == 4)
        #expect(report.stalled == false)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM variant") == 1)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM block") == 1)
        #expect(try b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == "4")
    }

    // MARK: - Cascades during apply

    /// A parent tombstone arriving before its children's tombstones: the
    /// local cascade (transition-guarded, active during apply — SyncSpec §3)
    /// pre-produces the same child rows; the children's rows then apply over
    /// them idempotently. Nothing re-enqueues on the pulling device.
    // B4 exempt: ScriptedTransport — no room for a round.
    @Test func parentTombstoneBeforeChildrenAppliesIdempotently() async throws {
        let scripted = ScriptedTransport(rows: [])
        let b = try SyncClient(name: "B", prefix: "BB", transport: scripted)
        let made: (block: String, variant: String, placement: String) = try b.with { ops, db in
            let post = try ops.createPost(title: "p", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "text", at: .end)
            return (made.block.id, made.variant.id, made.placement.id)
        }
        try b.db.clearOutbox()

        let stamp = "2026-07-06T10:00:00.000Z"
        var blockTombstone = try await b.db.read {
            try SyncRow.fetch($0, table: SyncSchema.table(named: "block")!, rowID: made.block)!
        }
        blockTombstone.columns["deleted_at"] = .text(stamp)
        blockTombstone.syncVersion = 2
        // Local fetches are plaintext; the wire carries sealed rows.
        await scripted.append([
            SyncPulledRow(row: try SyncTestKeys.sealedForWire(blockTombstone), serverSeq: 1)
        ])
        try await b.pull()

        // The local cascade fired with the block's exact stamp…
        #expect(try b.db.deletedAt("variant", made.variant) == stamp)
        #expect(try b.db.deletedAt("container_block", made.placement) == stamp)
        // …its writes suppressed by apply mode — and because THIS batch did
        // not deliver the victims' own tombstones, the orphan repair
        // (direction 1) enqueued them explicitly: as far as this device can
        // know they are local-only originals the other devices have never
        // seen die. (Without this, a child created-and-pushed by this device
        // after the deleter last saw the parent would die silently here and
        // the stores would diverge.)
        #expect(try b.outboxContains("variant", made.variant))
        #expect(try b.outboxContains("container_block", made.placement))

        // The children's own tombstone rows now arrive (same stamp, as the
        // originating device's cascade produced them) and apply over ours.
        var variantTombstone = try await b.db.read {
            try SyncRow.fetch($0, table: SyncSchema.table(named: "variant")!, rowID: made.variant)!
        }
        variantTombstone.syncVersion = 2
        var placementTombstone = try await b.db.read {
            try SyncRow.fetch($0, table: SyncSchema.table(named: "container_block")!, rowID: made.placement)!
        }
        placementTombstone.syncVersion = 2
        await scripted.append([
            SyncPulledRow(row: try SyncTestKeys.sealedForWire(variantTombstone), serverSeq: 2),
            SyncPulledRow(row: try SyncTestKeys.sealedForWire(placementTombstone), serverSeq: 3),
        ])
        try await b.pull()

        #expect(try b.db.deletedAt("variant", made.variant) == stamp)
        #expect(try b.db.fetchInt("SELECT sync_version FROM variant WHERE id = ?", [made.variant]) == 2)
        // The children's tombstones proved server-known after all: the merge
        // accepted them wholesale and cleared the direction-1 entries.
        #expect(try b.outboxCount() == 0)
    }

    // MARK: - Stragglers (SyncSpec §5's designed-for rarity)

    /// A row whose referent has not reached the server (the other device's
    /// outbox still owes it): the batch stops just before it, the cursor
    /// holds, the read side renders what arrived — and the stall self-heals
    /// when the referent lands.
    // B4 exempt: ScriptedTransport — no room for a round.
    @Test func stragglerStallsTheCursorThenSelfHeals() async throws {
        let scripted = ScriptedTransport(rows: [
            SyncPulledRow(row: try TestRows.container(id: "c1", title: "post"), serverSeq: 1),
            // A variant whose block is missing from server AND batch.
            SyncPulledRow(row: try TestRows.variant(id: "v1", block: "b-late", text: "hi"), serverSeq: 2),
        ])
        let b = try SyncClient(name: "B", prefix: "BB", transport: scripted)
        let first = try await b.pull()
        #expect(first.stalled == true)
        #expect(first.applied == 1)
        #expect(try b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == "1")
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM variant") == 0, "the straggler was held back")

        // The read layer renders the partial world without complaint
        // (SyncSpec §5's read-side contract, proven in Phase 4 — one
        // integration assertion here).
        let rendered = try await b.db.read { try Queries.renderPost($0, containerID: "c1") }
        #expect(rendered.isEmpty)

        // The owing device finally pushes the block; the next pull heals.
        await scripted.append([
            SyncPulledRow(row: TestRows.block(id: "b-late", defaultVariant: "v1"), serverSeq: 3)
        ])
        let second = try await b.pull()
        #expect(second.stalled == false)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM variant") == 1)
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM block") == 1)
        #expect(try b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == "3")
    }
}

// MARK: - Scripted transport + row builders

/// Vends exactly the rows a test scripts, in seq order — for batch shapes a
/// real server round-trip cannot easily produce.
actor ScriptedTransport: SyncTransport {
    private var rows: [SyncPulledRow]

    init(rows: [SyncPulledRow]) {
        self.rows = rows.sorted { $0.serverSeq < $1.serverSeq }
    }

    func append(_ more: [SyncPulledRow]) {
        rows = (rows + more).sorted { $0.serverSeq < $1.serverSeq }
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) -> [SyncPushOutcome] {
        batch.map { _ in .accepted(newVersion: 1, serverSeq: 0) }  // unused in these tests
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) -> [SyncPulledRow] {
        Array(rows.filter { $0.serverSeq > since }.prefix(limit))
    }

    func schemaVersion() -> Int {
        SyncSchema.lockstepVersion  // scripted batches model an in-lockstep server
    }
}

enum TestRows {
    static let now = Fixture.now

    /// Crafted rows model WIRE payloads (Phase 14b): the text-bearing
    /// builders seal their encrypted-classified values with the suite key,
    /// exactly as a real device's seam would before pushing.
    static func container(id: String, title: String, deletedAt: String? = nil) throws -> SyncRow {
        try SyncTestKeys.sealedForWire(SyncRow(
            table: "container", rowID: id,
            columns: [
                "id": .text(id), "owner_id": .null, "kind": .text("post"),
                "title": .text(title), "profile": .null, "entry_date": .null,
                "locked": .integer(0), "locked_at": .null, "floating_notes": .null,
                "segmentation_default": .null, "last_touched_at": .null,
                "last_major_revision_at": .null, "churn_accumulator": .real(0),
                "baseline_length": .integer(0), "created_at": .text(now),
                "updated_at": .text(now), "archived_at": .null,
                "deleted_at": deletedAt.map(SyncValue.text) ?? .null,
            ],
            syncVersion: 1))
    }

    static func block(id: String, defaultVariant: String?, deletedAt: String? = nil) -> SyncRow {
        SyncRow(
            table: "block", rowID: id,
            columns: [
                "id": .text(id), "owner_id": .null,
                "default_variant_id": defaultVariant.map(SyncValue.text) ?? .null,
                "last_container_id": .null, "created_at": .text(now),
                "updated_at": .text(now), "archived_at": .null,
                "deleted_at": deletedAt.map(SyncValue.text) ?? .null,
            ],
            syncVersion: 1)
    }

    static func variant(
        id: String, block: String, text: String,
        status: String = "active", label: String? = nil,
        fanPosition: String = "V", deletedAt: String? = nil
    ) throws -> SyncRow {
        try SyncTestKeys.sealedForWire(SyncRow(
            table: "variant", rowID: id,
            columns: [
                "id": .text(id), "block_id": .text(block), "parent_variant_id": .null,
                "working_text": .text(text), "status": .text(status),
                "locked": .integer(0), "label": label.map(SyncValue.text) ?? .null,
                "fan_position": .text(fanPosition), "created_at": .text(now),
                "updated_at": .text(now),
                "deleted_at": deletedAt.map(SyncValue.text) ?? .null,
            ],
            syncVersion: 1))
    }

    static func placement(
        id: String, container: String, block: String, chosen: String?,
        position: String = "V", deletedAt: String? = nil
    ) -> SyncRow {
        SyncRow(
            table: "container_block", rowID: id,
            columns: [
                "id": .text(id), "container_id": .text(container), "block_id": .text(block),
                "position": .text(position),
                "chosen_variant_id": chosen.map(SyncValue.text) ?? .null,
                "created_at": .text(now), "updated_at": .text(now),
                "deleted_at": deletedAt.map(SyncValue.text) ?? .null,
            ],
            syncVersion: 1)
    }
}

/// Binds a bare test-dependency world around an engine call that needs one
/// (deterministic uuid/date/rng + the given database).
func withDependenciesForTest<T>(
    db: AppDatabase, _ body: () async throws -> T
) async throws -> T {
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return Date(timeIntervalSince1970: 1_782_950_400 + Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
    } operation: {
        try await body()
    }
}
