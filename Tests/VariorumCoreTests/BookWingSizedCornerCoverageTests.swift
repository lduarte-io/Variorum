import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-893 (2) and (4) — the VX-912 run, batch B2 (`notes/plans/fixes/vx-912-
// open-source-gating.md`, "## B2 record"): the SIZED corners — what the shipped
// occasions and the belt cover, pinned. COVERAGE pins: green on both trees by
// design (never a fix's red-on-old); the record dispositions each corner.

// MARK: - The sized corners: what IS covered (green on both trees by design)

@Suite("VX-893 (2)/(4) — the sized corners: what the shipped occasions and the belt cover")
struct BookWingSizedCornerCoverageTests {
    /// C2 — corner (2), A-808-2's lost-filer residual: the FILER's push dies
    /// right after its note's container reaches the server, ahead of the
    /// membership; the mover applies the two in SEPARATE applies (the
    /// container alone first — a plain note, nothing to mend; the membership
    /// at the filer's retry), and the filer is then lost. The membership's
    /// apply is occasion (a) with the container present: the mover mends, and
    /// a fresh device pulls the mended note. COVERAGE — green on both trees
    /// (the shipped occasion); the wing-row half of the corner is W1's.
    @Test func c2_aLostFilersSplitPushIsMetInSeparateAppliesAndMended() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, clockOffset: 1000, seed: 2)
        let book = try a.with { ops, _ in try ops.createReading(name: "Harbour", kind: .book) }
        try await BookWingCorner.settle([a, b], server: server)
        let studio = try a.with { ops, _ -> String in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(book.id, to: studio.id)
            return studio.id
        }
        try await a.push()

        let note = try BookWingCorner.fileOffline(b, into: book.id)
        await transport.armFailNextPush(afterRows: try outboxRowsAhead(of: "reading_post", in: b))
        await #expect(throws: InjectedNetworkFault.self) { try await b.push() }

        let first = try await a.pull()
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM container WHERE id = ?", [note]) == 1)
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [note]) == 0)
        #expect(first.repairs == 0, "a plain note: nothing to mend")

        try await b.push()   // the retry lands the membership; B is then lost for good
        let second = try await a.pull()
        #expect(second.repairs > 0, "occasion (a), the container present")
        #expect(try BookWingCorner.wingOf(a, post: note) == studio)
        #expect(try a.outboxContains("container", note))

        try await BookWingCorner.settle([a], server: server)
        let fresh = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 2000, seed: 3)
        try await fresh.pull()
        #expect(try BookWingCorner.wingOf(fresh, post: note) == studio)
        #expect(try BookWingCorner.isLiveMember(fresh, note, of: book.id))
    }

    /// C3 — corner (4)(3), VX-805's residual (3) at every book: her book move
    /// meets a concurrent RENAME of the book that reached the server first.
    /// The merge is whole-row server-wins for metadata, so her move is lost
    /// (the book stays in Home) — and her own reject-batch mend (occasion
    /// (b): the book "landed" back in the wing it left on her device) takes
    /// its member back with it. CONSISTENT on every device: no book spans
    /// wings; she redoes the move. COVERAGE — green on both trees.
    @Test func c3_aRenameThatRevertsHerBookMoveKeepsTheBookAndItsMembersTogether() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let (book, note) = try a.with { ops, _ -> (String, String) in
            let book = try ops.createReading(name: "Harbour", kind: .book)
            let note = try ops.createPost(title: "a member", profile: .generic)
            _ = try ops.addPostToReading(note.id, to: book.id)
            return (book.id, note.id)
        }
        try await BookWingCorner.settle([a, b], server: server)

        try b.with { ops, _ in try ops.renameReading(book, name: "Harbour, renamed") }
        try await b.push()
        let studio = try a.with { ops, _ -> String in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(book, to: studio.id)
            return studio.id
        }
        #expect(try BookWingCorner.wingOf(a, post: note) == studio, "the premise: on A the member moved with its book")
        let pushed = try await a.push()
        #expect(pushed.rejected > 0, "the rename won the book's row")
        #expect(try a.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [book]) == "")
        #expect(try BookWingCorner.wingOf(a, post: note) == "", "the member followed the book back")

        try await BookWingCorner.settle([a, b], server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
        for client in [a, b] {
            #expect(try client.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [book]) == "")
            #expect(try BookWingCorner.wingOf(client, post: note) == "", "no book spans wings")
            #expect(try BookWingCorner.isLiveMember(client, note, of: book))
        }
        _ = studio
    }
}
