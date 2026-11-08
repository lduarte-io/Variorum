import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-893 (3) — the VX-912 run, batch B2 (`notes/plans/fixes/vx-912-open-source-
// gating.md`, "## B2 record"): the general book wing mend's anchor rank, tier 3
// on `reading_post.created_at` (converged bytes) — two mid-convergence devices
// with different `sync_row_seq` pictures pick ONE anchor. The production path,
// two clients + the fake server. Red-on-old is stated on the test.

// MARK: - Corner (3): the anchor rank on converged bytes

@Suite("VX-893 (3) — the anchor rank is converged bytes: two mid-convergence devices pick one anchor")
struct BookWingAnchorRankConvergenceTests {
    /// T3 — note P is a member of book Y (Home); B files it into book X too
    /// (the LATER filing); A moves X into a new wing. Each device mends the
    /// note on its OWN picture before seeing the other's mend: B with Y's row
    /// at its old seq, A after an innocuous later edit of Y's row (a pin) —
    /// so Y's row carries the higher seq on A. The seq rank then anchors Y on
    /// B and X on A, and each demotes the other's anchor: converged, P is a
    /// member of NOTHING (both rows visible arrivals — the recorded worst
    /// case). `created_at` is the same bytes on both: both anchor Y (the
    /// earlier filing), the filing into X waits at X's door, byte-identical.
    /// RED ON OLD at A's mend and at convergence; the seq pictures are
    /// asserted to differ, so the test exercises the gap, not a coincidence.
    @Test func t3_twoDevicesWithDifferentSeqPicturesPickTheSameAnchor() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let (y, x, note) = try a.with { ops, _ -> (String, String, String) in
            let y = try ops.createReading(name: "Y", kind: .book)
            let x = try ops.createReading(name: "X", kind: .book)
            let note = try ops.createPost(title: "in two books", profile: .generic)
            _ = try ops.addPostToReading(note.id, to: y.id)
            return (y.id, x.id, note.id)
        }
        try await BookWingCorner.settle([a, b], server: server)

        _ = try b.with { ops, _ in try ops.addPostToReading(note, to: x) }
        let studio = try a.with { ops, _ -> String in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(x, to: studio.id)
            return studio.id
        }
        try await a.push()

        // B pushes its filing, pulls the move, and mends on its picture.
        try await b.push()
        let pulledB = try await b.pull()
        let inY = try #require(try BookWingCorner.membershipID(b, note, in: y))
        let inX = try #require(try BookWingCorner.membershipID(b, note, in: x))
        #expect(pulledB.repairs > 0)
        let seqBY = try #require(try BookWingCorner.knownSeq(b, membership: inY))
        let seqBX = try #require(try BookWingCorner.knownSeq(b, membership: inX))
        #expect(seqBY < seqBX, "B's picture: Y's row is the earlier-accepted")
        #expect(try BookWingCorner.wingOf(b, post: note) == "")
        #expect(try BookWingCorner.row(b, inX)?.status == "arrival", "B demotes the filing into X")

        // A pins P in Y (a later edit of Y's row), pushes, then pulls B's
        // filing — B's demotion not yet pushed — and mends on its picture.
        try a.with { ops, _ in try ops.setMembershipPinned(note, in: y, pinned: true) }
        try await a.push()
        let pulledA = try await a.pull()
        #expect(pulledA.repairs > 0)
        let seqAY = try #require(try BookWingCorner.knownSeq(a, membership: inY))
        let seqAX = try #require(try BookWingCorner.knownSeq(a, membership: inX))
        #expect(seqAY > seqAX, "A's picture differs: the seq rank would anchor X here")
        let createdY = try #require(try a.db.fetchString("SELECT created_at FROM reading_post WHERE id = ?", [inY]))
        let createdX = try #require(try a.db.fetchString("SELECT created_at FROM reading_post WHERE id = ?", [inX]))
        #expect(createdY < createdX, "the premise: Y's filing is the earlier")
        #expect(try BookWingCorner.wingOf(a, post: note) == "", "A anchors the earlier filing too")
        #expect(try BookWingCorner.isLiveMember(a, note, of: y))
        #expect(try BookWingCorner.row(a, inX)?.status == "arrival")
        #expect(try a.outboxContains("reading_post", inX), "A's demotion pushes")

        try await BookWingCorner.settle([a, b], server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
        for client in [a, b] {
            #expect(try BookWingCorner.wingOf(client, post: note) == "")
            #expect(try BookWingCorner.isLiveMember(client, note, of: y), "one anchor stands")
            #expect(try !BookWingCorner.isLiveMember(client, note, of: x))
            let filed = try #require(try BookWingCorner.row(client, inX))
            #expect(filed.status == "arrival" && !filed.dead && BookWingCorner.isWingMendDemotion(filed.provenance),
                    "the later filing waits, visibly, at X's door")
            #expect(try client.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [x]) == studio)
        }
    }
}
