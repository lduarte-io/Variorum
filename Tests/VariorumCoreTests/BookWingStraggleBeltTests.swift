import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-893 (1) — the VX-912 run, batch B2 (`notes/plans/fixes/vx-912-open-source-
// gating.md`, "## B2 record"): F-1, the wing-row straggle belt (the one-shot
// deferral marker — the seeded-furniture fold's pattern, SyncSpec §7) on the
// production path: in-memory clients, the fake server (W1 with its A5
// visibility band), real triggers, the real engine, E2EE payloads; explicit
// outbox rows and positive activity asserted; byte-identical at quiescence.
// Red-on-old is stated per test; the record carries the evidence.

// MARK: - Corner (1): the straggle belt

@Suite("VX-893 (1) — the wing-row straggle belt: a deferred mend waits for its wing, then lands")
struct BookWingStraggleBeltTests {
    /// W1 — F-1's mechanism on the production road, the A5 visibility band:
    /// A moves a book into a new wing and pushes, then RENAMES the wing, so
    /// the wing's only stored row is the rename, inside the band — and A is
    /// then lost. B (whose filing into that book was pushed and echoed
    /// before) pulls inside the band: the book lands in its new wing, the
    /// wing's row does not, and the mend rightly defers (the wing is unknown
    /// here). The band passes; B's next pull lands the wing row — on the old
    /// tree that is no occasion, and B quiesces with its book spanning wings
    /// (nobody else is left to mend it). With the belt the deferral is
    /// honored at that pull: the note follows its book, the repair pushes,
    /// the marker is spent, and quiescent rounds write nothing. RED ON OLD at
    /// B's second pull and at its lone quiescence.
    @Test func w1_aStragglingWingLandsAfterTheOccasionAndTheNextPullMends() async throws {
        let band: Int64 = 2
        let server = FakeSyncServer(visibilityHorizon: band)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let book = try a.with { ops, _ in try ops.createReading(name: "Harbour", kind: .book) }
        try await BookWingCorner.settle([a, b], server: server, band: band)

        let note = try BookWingCorner.fileOffline(b, into: book.id)
        try await b.push()
        await server.advanceClock(by: band + 1)
        try await b.pull()   // B consumes its own echo: the filing never re-lands later

        let studio = try a.with { ops, _ -> String in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(book.id, to: studio.id)
            return studio.id
        }
        try await a.push()
        await server.advanceClock(by: band + 1)
        try a.with { ops, _ in try ops.renameWing(studio, to: "Studio, renamed") }
        try await a.push()   // the wing's latest row sits inside the band; A is then lost

        let first = try await b.pull()
        #expect(try b.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [book.id]) == studio,
                "the book landed in its new wing")
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM wing WHERE id = ?", [studio]) == 0, "the wing straggles")
        #expect(first.repairs == 0)
        #expect(try BookWingCorner.wingOf(b, post: note) == "", "the mend deferred — the book's wing is unknown here")
        #expect(try b.outboxCount() == 0)
        #expect(try BookWingCorner.deferrals(b) == [note: ""], "the deferral is recorded: the note, and the wing it sat in")

        await server.advanceClock(by: band + 1)
        let second = try await b.pull()
        #expect(try b.db.fetchInt("SELECT COUNT(*) FROM wing WHERE id = ?", [studio]) == 1, "the wing landed")
        #expect(second.repairs > 0, "positive activity: the deferred mend landed")
        #expect(try BookWingCorner.wingOf(b, post: note) == studio, "the note followed its book")
        #expect(try BookWingCorner.isLiveMember(b, note, of: book.id))
        #expect(try b.outboxContains("container", note), "the repair write pushes")
        #expect(try BookWingCorner.deferrals(b) == nil, "spent")

        // B alone (A is lost): it quiesces mended, and quiescent rounds write nothing.
        try await BookWingCorner.settle([b], server: server, band: band)
        let head = await server.headSeq
        for _ in 1...2 {
            #expect(try await b.push().accepted == 0)
            await server.advanceClock(by: band + 1)
            #expect(try await b.pull().repairs == 0)
            #expect(try b.outboxCount() == 0)
        }
        #expect(await server.headSeq == head, "nothing re-fired")
        #expect(try BookWingCorner.wingOf(b, post: note) == studio)
        #expect(try BookWingCorner.deferrals(b) == nil)

        // A rejoins: byte-identical, the book and its member in one wing.
        try await BookWingCorner.settle([a, b], server: server, band: band)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
        for client in [a, b] {
            #expect(try BookWingCorner.wingOf(client, post: note) == studio)
            #expect(try BookWingCorner.isLiveMember(client, note, of: book.id))
        }
    }

    /// W2 — the belt's own guard: a deferred note whose CONTAINER moved
    /// before its wing arrived (her deliberate move-out's first chunk — the
    /// membership's tombstone still in flight) has left the deferred picture,
    /// and is NEVER judged: judging it then is exactly the container-landing
    /// judgment the occasion discipline forbids (it would undo her move). On a
    /// scripted feed: C meets the span with the book's wing held back (the
    /// mend defers and records it); the next feed lands the wing row AND the
    /// moved container together. The entry is spent unjudged and her move
    /// stands. Red when the belt's wing check is reverted (the note is mended
    /// back into the book's wing); the deferral premise is the belt's own (it
    /// does not exist on the old tree, where the move stands by default).
    @Test func w2_aDeferredNoteThatMovedSinceIsNeverJudged() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let (studio, book, note) = try a.with { ops, _ -> (String, String, String) in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Harbour", kind: .book, wingId: studio.id)
            let note = try ops.createPost(title: "spanning", profile: .generic)
            return (studio.id, book.id, note.id)
        }
        // The span the race leaves (raw: the shape no op door mints).
        try a.with { _, db in
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('0W200000-0000-4000-8000-000000000001', ?, ?, 'z0', 'member',
                                '2026-11-05T00:00:00.000Z')
                        """,
                    arguments: [book, note])
            }
        }
        try await a.push()
        let first = await server.storedRowsWithSeqs()
        let head = first.map(\.serverSeq).max() ?? 0
        let studioRow = try #require(first.first { $0.row.table == "wing" && $0.row.rowID == studio })

        // Her move-out's first chunk: the note's container in another wing.
        let elsewhere = try a.with { ops, _ in try ops.createWing(name: "Elsewhere").id }
        try a.with { _, db in
            try db.write { try $0.execute(
                sql: "UPDATE container SET wing_id = ? WHERE id = ?", arguments: [elsewhere, note]) }
        }
        try await a.push()
        let later = await server.storedRowsWithSeqs()
        let moved = try #require(later.first { $0.row.table == "container" && $0.row.rowID == note })
        let elsewhereRow = try #require(later.first { $0.row.table == "wing" && $0.row.rowID == elsewhere })

        let scripted = ScriptedTransport(rows: first.filter { $0 != studioRow })
        let c = try SyncClient(name: "C", prefix: "CC", transport: scripted, clockOffset: 2000, seed: 3)
        _ = try await c.pull()
        #expect(try BookWingCorner.wingOf(c, post: note) == "", "the mend deferred on the straggling wing")
        #expect(try BookWingCorner.deferrals(c) == [note: ""], "and recorded it")

        await scripted.append([
            SyncPulledRow(row: studioRow.row, serverSeq: head + 1),
            SyncPulledRow(row: elsewhereRow.row, serverSeq: head + 2),
            SyncPulledRow(row: moved.row, serverSeq: head + 3),
        ])
        let second = try await c.pull()
        #expect(second.repairs == 0, "the moved note is never judged")
        #expect(try BookWingCorner.wingOf(c, post: note) == elsewhere, "her move stands")
        #expect(try !c.outboxContains("container", note))
        #expect(try BookWingCorner.deferrals(c) == nil, "the entry was spent unjudged")
    }
}
