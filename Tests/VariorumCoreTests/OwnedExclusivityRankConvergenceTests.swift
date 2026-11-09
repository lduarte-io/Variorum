import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-921 — the VX-849 run, batch 6 (`notes/plans/fixes/vx-849-typed-over-rescue.md`, "### BATCH 6 RECORD"): the
// OWNED exclusivity repair's claimant rank on `reading_post.created_at` (converged bytes), the VX-893 (3) worked
// pattern applied to SyncSpec §7's OWNED paragraph. Two mid-convergence devices whose `sync_row_seq` pictures rank
// DIFFERENT claimants first stand the SAME claimant. The production path: two clients + the fake server. Each pin
// asserts its seq pictures DO differ at decision time, so it exercises the gap, not a coincidence. Red-on-old is
// stated on each test.

@Suite("VX-921 — the OWNED claimant rank is converged bytes: two mid-convergence devices stand one claimant")
struct OwnedExclusivityRankConvergenceTests {

    /// Note N is filed into plain book Y on A (the EARLIER filing, accepted first); B, not having seen it, claims N
    /// into owned book X (the LATER filing, accepted second). B pulls Y's filing and repairs on its picture — Y's row
    /// at its first seq — so the plain filing stands and X's claim waits at Arrivals. A then pins N in Y (an innocuous
    /// later edit of Y's row, re-accepted ABOVE X's claim) and pulls X's claim: under the seq rank A stands X's claim
    /// and TOMBSTONES Y's filing — converged, N is a member of NOTHING (the claim a visible arrival, the filing
    /// silently gone). Under `created_at` both devices stand Y's filing: one live member, the claim a visible arrival,
    /// byte-identical. RED ON OLD at A's repair and at convergence.
    @Test func aPlainFilingAndALaterOwnedClaimStandTheEarlierFilingWhateverEachDevicesSeqPicture() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let note = try a.with { ops, _ in try ops.createPost(title: "filed, then claimed", profile: .generic).id }
        try await BookWingCorner.settle([a, b], server: server)

        // A files N into the plain book; B — never having seen that — claims it into its owned book.
        let y = try a.with { ops, _ -> String in
            let y = try ops.createReading(name: "Y", kind: .book)
            _ = try ops.addPostToReading(note, to: y.id)
            return y.id
        }
        let x = try b.with { ops, _ -> String in
            let x = try ops.createReading(name: "X", kind: .book)
            _ = try ops.setReadingOwned(x.id, owned: true)
            _ = try ops.addPostToReading(note, to: x.id)
            return x.id
        }
        try await a.push()   // Y's filing is accepted FIRST
        try await b.push()   // X's claim second

        // B pulls Y's filing and repairs on its picture: the filing stands, the claim bells.
        let pulledB = try await b.pull()
        let inY = try #require(try BookWingCorner.membershipID(b, note, in: y))
        let inX = try #require(try BookWingCorner.membershipID(b, note, in: x))
        #expect(pulledB.repairs > 0)
        let seqBY = try #require(try BookWingCorner.knownSeq(b, membership: inY))
        let seqBX = try #require(try BookWingCorner.knownSeq(b, membership: inX))
        #expect(seqBY < seqBX, "B's picture: Y's filing is the earlier-accepted")
        #expect(try BookWingCorner.isLiveMember(b, note, of: y), "B stands the earlier filing")
        #expect(try BookWingCorner.row(b, inX)?.status == "arrival", "B bells the later claim")

        // A pins N in Y (a later edit of Y's row), pushes, then pulls X's claim — B's demotion not yet pushed —
        // and repairs on its own picture.
        try a.with { ops, _ in try ops.setMembershipPinned(note, in: y, pinned: true) }
        try await a.push()
        let pulledA = try await a.pull()
        #expect(pulledA.repairs > 0)
        let seqAY = try #require(try BookWingCorner.knownSeq(a, membership: inY))
        let seqAX = try #require(try BookWingCorner.knownSeq(a, membership: inX))
        #expect(seqAY > seqAX, "A's picture differs: the seq rank would stand X's claim here")
        let createdY = try #require(try a.db.fetchString("SELECT created_at FROM reading_post WHERE id = ?", [inY]))
        let createdX = try #require(try a.db.fetchString("SELECT created_at FROM reading_post WHERE id = ?", [inX]))
        #expect(createdY < createdX, "the premise: Y's filing is the earlier")
        #expect(try BookWingCorner.isLiveMember(a, note, of: y), "A stands the earlier filing too — never tombstones it")
        #expect(try BookWingCorner.row(a, inY)?.dead == false)
        #expect(try BookWingCorner.row(a, inX)?.status == "arrival", "A bells the later claim too")
        #expect(try a.outboxContains("reading_post", inX), "A's repair write pushes (SyncSpec §7's explicit outbox row)")

        try await BookWingCorner.settle([a, b], server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
        for client in [a, b] {
            #expect(try BookWingCorner.isLiveMember(client, note, of: y), "\(client.name): the earlier filing stands")
            #expect(try !BookWingCorner.isLiveMember(client, note, of: x))
            #expect(try liveMemberCount(client, note) == 1, "\(client.name): the note is membered exactly once")
            let claim = try #require(try BookWingCorner.row(client, inX))
            #expect(claim.status == "arrival" && !claim.dead && isOwnedElsewhereDemotion(claim.provenance),
                    "\(client.name): the later claim waits, visibly, at X's door")
        }
    }

    /// The owned-versus-owned twin (QUESTIONS #167's "competing owned books: first claim wins"): A claims N into owned
    /// book X1 (the EARLIER claim, accepted first); B, not having seen it, claims N into owned book X2 (the LATER
    /// claim). B repairs on its picture and bells X2's claim; A pins N in X1 (re-accepted above X2's) and, pulling X2's
    /// claim, would under the seq rank stand X2 and bell X1 — converged, BOTH claims arrivals, N a member of nothing.
    /// Under `created_at` both stand X1's claim. RED ON OLD at A's repair and at convergence.
    @Test func twoOwnedClaimsStandTheEarlierClaimWhateverEachDevicesSeqPicture() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let note = try a.with { ops, _ in try ops.createPost(title: "claimed twice", profile: .generic).id }
        try await BookWingCorner.settle([a, b], server: server)

        func claim(_ client: SyncClient, into name: String) throws -> String {
            try client.with { ops, _ -> String in
                let book = try ops.createReading(name: name, kind: .book)
                _ = try ops.setReadingOwned(book.id, owned: true)
                _ = try ops.addPostToReading(note, to: book.id)
                return book.id
            }
        }
        let first = try claim(a, into: "X1")
        let later = try claim(b, into: "X2")
        try await a.push()   // X1's claim is accepted FIRST
        try await b.push()   // X2's claim second

        let pulledB = try await b.pull()
        let inFirst = try #require(try BookWingCorner.membershipID(b, note, in: first))
        let inLater = try #require(try BookWingCorner.membershipID(b, note, in: later))
        #expect(pulledB.repairs > 0)
        let seqBFirst = try #require(try BookWingCorner.knownSeq(b, membership: inFirst))
        let seqBLater = try #require(try BookWingCorner.knownSeq(b, membership: inLater))
        #expect(seqBFirst < seqBLater, "B's picture: X1's claim is the earlier-accepted")
        #expect(try BookWingCorner.isLiveMember(b, note, of: first), "B stands the earlier claim")
        #expect(try BookWingCorner.row(b, inLater)?.status == "arrival", "B bells the later claim")

        try a.with { ops, _ in try ops.setMembershipPinned(note, in: first, pinned: true) }
        try await a.push()
        let pulledA = try await a.pull()
        #expect(pulledA.repairs > 0)
        let seqAFirst = try #require(try BookWingCorner.knownSeq(a, membership: inFirst))
        let seqALater = try #require(try BookWingCorner.knownSeq(a, membership: inLater))
        #expect(seqAFirst > seqALater, "A's picture differs: the seq rank would stand X2's claim here")
        let createdFirst = try #require(try a.db.fetchString(
            "SELECT created_at FROM reading_post WHERE id = ?", [inFirst]))
        let createdLater = try #require(try a.db.fetchString(
            "SELECT created_at FROM reading_post WHERE id = ?", [inLater]))
        #expect(createdFirst < createdLater, "the premise: X1's claim is the earlier")
        #expect(try BookWingCorner.isLiveMember(a, note, of: first), "A stands the earlier claim too")
        #expect(try BookWingCorner.row(a, inLater)?.status == "arrival", "A bells the later claim too")
        #expect(try a.outboxContains("reading_post", inLater), "A's repair write pushes")

        try await BookWingCorner.settle([a, b], server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
        for client in [a, b] {
            #expect(try BookWingCorner.isLiveMember(client, note, of: first), "\(client.name): the first claim stands")
            #expect(try liveMemberCount(client, note) == 1, "\(client.name): the note is membered exactly once")
            let bell = try #require(try BookWingCorner.row(client, inLater))
            #expect(bell.status == "arrival" && !bell.dead && isOwnedElsewhereDemotion(bell.provenance),
                    "\(client.name): the later claim waits, visibly, at X2's door")
        }
    }

    /// The pure rank (`SyncEngine.ownedClaimOutranks`): earliest-filed → id, and NOTHING else — whether a row is
    /// owned never ranks it (the repair's arms read `owned` AFTER the rank), and no per-device fact exists to read.
    /// A strict total order over distinct rows. Names the new rank, so COMPILE-red on the pre-fix tree; its behavioral
    /// twin is R-921a (the record).
    @Test func theClaimRankIsEarliestFiledThenID() {
        func claim(_ id: String, owned: Bool = false, filed: String) -> SyncEngine.OwnedClaim {
            SyncEngine.OwnedClaim(id: id, owned: owned, createdAt: filed)
        }
        let plainEarly = claim("p1", filed: "2026-11-01T00:00:05.000Z")
        let ownedLate = claim("o1", owned: true, filed: "2026-11-01T00:00:09.000Z")
        let plainTwin = claim("a0", filed: "2026-11-01T00:00:09.000Z")   // o1's stamp: by id
        let ownedEarlier = claim("z9", owned: true, filed: "2026-11-01T00:00:01.000Z")
        let all = [ownedLate, plainTwin, plainEarly, ownedEarlier]
        #expect(all.sorted(by: SyncEngine.ownedClaimOutranks).map(\.id) == ["z9", "p1", "a0", "o1"])
        #expect(SyncEngine.ownedClaimOutranks(plainTwin, ownedLate), "a created_at tie breaks by id")
        #expect(SyncEngine.ownedClaimOutranks(plainEarly, ownedLate), "an earlier PLAIN filing outranks a later claim")
        for x in all {
            #expect(!SyncEngine.ownedClaimOutranks(x, x))
            for y in all where x.id != y.id {
                #expect(SyncEngine.ownedClaimOutranks(x, y) != SyncEngine.ownedClaimOutranks(y, x))
            }
        }
    }
}

/// A note's live MEMBER rows (arrivals are no membership).
private func liveMemberCount(_ client: SyncClient, _ postID: String) throws -> Int? {
    try client.db.fetchInt(
        "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'",
        [postID])
}

/// The OWNED repair's demotion stamp (A-808-7): kind `owned_elsewhere`, its moment as `at`, no client.
private func isOwnedElsewhereDemotion(_ json: String?) -> Bool {
    guard let provenance = ArrivalProvenance.decode(json) else { return false }
    return provenance.knownKind == .ownedElsewhere && provenance.client == nil && provenance.at != nil
}
