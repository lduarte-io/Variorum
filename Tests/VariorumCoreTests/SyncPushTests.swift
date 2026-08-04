import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The push half (SyncSpec §4): outbox drain, CAS bookkeeping in apply mode
/// (the Phase 1 trap), the clear-vs-re-dirty race, and reject→merge→re-push
/// convergence within one bounded call.
@Suite("Push engine (Phase 5, Step 3)")
struct SyncPushTests {
    /// THE master-plan assertion: a full push cycle ends with an EMPTY
    /// outbox. If any engine bookkeeping write ran outside apply mode, the
    /// write would re-enqueue the row it just pushed and this test would see
    /// it (SyncSpec §4; TriggerTests documented the trap in Phase 1).
    @Test func fullPushCycleEndsWithAnEmptyOutbox() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            let post = try ops.createPost(title: "hello", profile: .journal)
            let made = try ops.newBlock(in: post.id, text: "first entry", at: .end)
            try ops.autosave(made.variant.id, text: "first entry, longer", charDelta: 8)
            _ = try ops.commit(made.variant.id)
        }
        #expect(try a.outboxCount() > 0)

        let report = try await a.push()
        #expect(report.accepted > 0)
        #expect(try a.outboxCount() == 0, "the drain must end empty — anything left loops forever")

        // Local rows carry their server-granted versions and seq bookkeeping.
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE sync_version = 0") == 0)
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM sync_row_seq")! > 0)

        // And a second push has nothing to say: the server head is unmoved —
        // the bookkeeping writes provably ran suppressed.
        let headAfterFirst = await server.headSeq
        let second = try await a.push()
        #expect(second.accepted == 0)
        #expect(await server.headSeq == headAfterFirst)
    }

    @Test func batchSpansEverySyncedTable() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, db in
            let post = try ops.createPost(title: "post", profile: .journal)
            let b1 = try ops.newBlock(in: post.id, text: "one. two.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "three.", at: .end).block
            let v1 = try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [b1.id])!
            _ = try ops.commit(v1)
            _ = try ops.merge(b1.id, b2.id)  // edges
            let reading = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            // Phase 13 (A1): the lockstep event's chapter table.
            let chapter = try ops.createSection(in: reading.id, name: "ch. I")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            let tag = try ops.createTag(parent: nil, name: "life")
            _ = try ops.applyTag(tag.id, toPost: post.id)
            let anyBlock = try db.fetchString(
                "SELECT block_id FROM container_block WHERE deleted_at IS NULL LIMIT 1")!
            _ = try ops.applyTag(tag.id, toBlock: anyBlock)
            _ = try ops.addReference(to: post.id, kind: .url, url: "https://example.org")
            // Phase 11 (A1): the lockstep event's tables.
            let pool = try ops.createPool(title: "board")
            let scrap = try ops.newBlock(in: pool.id, text: "card", at: .end).block
            _ = try ops.setCanvasPosition(container: pool.id, block: scrap.id, x: 8, y: 9)
            let postBlock = try db.fetchString(
                "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL LIMIT 1",
                [post.id])!
            let postVariant = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [postBlock])!
            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: postBlock, variant: postVariant)
            // Phase 13 (A1): the lockstep event's table.
            _ = try ops.addBlockComment(to: postBlock, text: "note")
        }

        try await a.push()
        #expect(try a.outboxCount() == 0)
        for table in SyncSchema.tables {
            #expect(await server.rowCount(table: table.name) > 0,
                    "\(table.name) never reached the server")
        }
    }

    /// The clear-vs-re-dirty race (the plan's named risk): an edit landing
    /// between the outbox snapshot and the accept bookkeeping must NOT be
    /// cleared away — that would lose the edit forever. With a single
    /// iteration the row stays enqueued; the next call ships the newer text.
    @Test func rowReDirtiedMidPushStaysEnqueuedAndShipsNext() async throws {
        let server = FakeSyncServer()
        let interfering = InterferingTransport(inner: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: interfering)
        let variantID: String = try a.with { ops, db in
            let post = try ops.createPost(title: "p", profile: nil)
            return try ops.newBlock(in: post.id, text: "pushed text", at: .end).variant.id
        }
        // The interference fires after the server accepted the batch but
        // before the client records the outcome — the exact race window.
        await interfering.arm { [db = a.db] in
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET working_text = 'edited mid-push' WHERE id = ?",
                    arguments: [variantID])
            }
        }

        try await a.push(maxIterations: 1)
        #expect(try a.outboxContains("variant", variantID),
                "a mid-push edit must survive the accept bookkeeping")
        // The mirror stores ciphertext (Phase 14b); assertions on server
        // text open it with the suite key.
        let afterFirst = await server.currentRow(table: "variant", rowID: variantID)
        #expect(try SyncTestKeys.openedText(afterFirst, column: "working_text") == "pushed text")

        try await a.push()
        #expect(try a.outboxCount() == 0)
        let afterSecond = await server.currentRow(table: "variant", rowID: variantID)
        #expect(try SyncTestKeys.openedText(afterSecond, column: "working_text")
                == "edited mid-push", "the newer edit ships on the next cycle")
    }

    /// Reject → deterministic merge → re-push, all within one bounded call:
    /// metadata rejects converge by accepting the server version; a local
    /// tombstone racing a server edit re-applies on top and pushes through.
    @Test func rejectMergesAndConvergesWithinOneCall() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "original", profile: nil).id
        }
        try await a.push()

        // Another writer moves the row on the server (base 1 → version 2).
        // A competing device would seal its values (Phase 14b) — so does
        // the crafted row.
        var competing = await server.currentRow(table: "container", rowID: postID)!
        competing.columns["title"] = .text(try SyncTestKeys.seal(
            "competing title", table: "container", rowID: postID, column: "title"))
        _ = try await server.push([competing])

        // Local intent: a metadata edit (loses, CAS rebase)…
        try a.with { ops, _ in
            try ops.renameContainer(postID, title: "local title")
        }
        let report = try await a.push()
        #expect(report.rejected == 1)
        #expect(try a.outboxCount() == 0)
        #expect(try a.db.fetchString("SELECT title FROM container WHERE id = ?", [postID])
                == "competing title")
        #expect(try a.db.fetchInt("SELECT sync_version FROM container WHERE id = ?", [postID]) == 2)

        // …and a tombstone (wins over the edit, and pushes through).
        var competing2 = await server.currentRow(table: "container", rowID: postID)!
        competing2.columns["title"] = .text(try SyncTestKeys.seal(
            "edited again remotely", table: "container", rowID: postID, column: "title"))
        _ = try await server.push([competing2])
        try a.with { ops, _ in
            try ops.deleteContainer(postID)
        }
        let report2 = try await a.push()
        #expect(report2.rejected >= 1)
        #expect(try a.outboxCount() == 0)
        let serverRow = await server.currentRow(table: "container", rowID: postID)
        #expect(serverRow?.isTombstoned == true, "the tombstone overlay re-pushed and stuck")
        #expect(try SyncTestKeys.openedText(serverRow, column: "title")
                == "edited again remotely",
                "the server edit's metadata survived under the tombstone")
    }

    /// The reject-path twin of the clear-vs-re-dirty race (Phase 5 review
    /// BLOCKER): an edit landing during the network await of a push that
    /// gets REJECTED must be merged from the CURRENT row — merging the
    /// stale pre-transport snapshot would overwrite the newer text with the
    /// server baseline, rescue only the stale text, and clear the outbox
    /// entry: real, silent text loss.
    @Test func rejectMidPushEditIsRescuedNotClobbered() async throws {
        let server = FakeSyncServer()
        let interfering = InterferingTransport(inner: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: interfering)
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "p", profile: nil)
            return try ops.newBlock(in: post.id, text: "base text", at: .end).variant.id
        }
        try await a.push()

        // A competing writer moves the variant on the server…
        var competing = await server.currentRow(table: "variant", rowID: variantID)!
        competing.columns["working_text"] = .text(try SyncTestKeys.seal(
            "competing text", table: "variant", rowID: variantID, column: "working_text"))
        _ = try await server.push([competing])
        // …the author edits locally (base is now stale — the push will
        // reject)…
        try a.with { ops, _ in
            try ops.autosave(variantID, text: "local edit before push", charDelta: 5)
        }
        // …and edits AGAIN in the reject's network window.
        await interfering.arm { [db = a.db] in
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET working_text = 'edit landed mid-push' WHERE id = ?",
                    arguments: [variantID])
            }
        }

        try await a.push()
        // The server text won the row (S5), and the text rescued into the
        // conflict card is the MID-PUSH edit — the buffer state that
        // actually existed at merge time — not the stale snapshot.
        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE id = ?", [variantID]) == "competing text")
        let rescued = try a.db.fetchString(
            "SELECT working_text FROM variant WHERE label = 'conflict'")
        #expect(rescued == "edit landed mid-push", "the mid-push edit must be what survives")
    }

    /// A reject whose server row is absent (mirror reset): rebase to 0 and
    /// re-push as an insert.
    @Test func rejectWithNoServerRowRebasesToInsert() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "p", profile: nil).id
        }
        // Fake a client that believes the server holds version 3.
        try await a.db.write { db in
            try db.execute(
                sql: "UPDATE container SET sync_version = 3 WHERE id = ?", arguments: [postID])
        }
        try await a.push()
        #expect(try a.outboxCount() == 0)
        let serverRow = await server.currentRow(table: "container", rowID: postID)
        #expect(serverRow != nil)
        #expect(serverRow?.syncVersion == 1, "re-accepted as a fresh insert")
    }

    @Test func deviceIDIsMintedOnceAndKept() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try await a.push()
        let minted = try a.db.fetchString("SELECT value FROM sync_state WHERE key = 'device_id'")
        #expect(minted != nil)
        try await a.push()
        #expect(try a.db.fetchString("SELECT value FROM sync_state WHERE key = 'device_id'") == minted)
    }
}

/// Wraps the fake server and runs a one-shot interference after the server
/// has accepted a push but before the client processes the outcome — the
/// clear-vs-re-dirty race window.
actor InterferingTransport: SyncTransport {
    private let inner: FakeSyncServer
    private var interference: (@Sendable () throws -> Void)?

    init(inner: FakeSyncServer) {
        self.inner = inner
    }

    func arm(_ body: @escaping @Sendable () throws -> Void) {
        interference = body
    }

    func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
        let outcomes = try await inner.push(batch)
        if let body = interference {
            interference = nil
            try body()
        }
        return outcomes
    }

    func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
        try await inner.pull(since: since, limit: limit)
    }

    func schemaVersion() async -> Int {
        await inner.schemaVersion()
    }
}
