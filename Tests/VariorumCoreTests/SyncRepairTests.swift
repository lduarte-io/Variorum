import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// SyncSpec §7: every live-unique index (and both invariant-shaped races)
/// gets its deterministic apply-time repair. Each test asserts the trio the
/// spec demands: (a) the deterministic outcome, (b) both devices converge
/// on the same choice, (c) **the repair's outbox row exists** — a repair
/// that never pushes is silent divergence.
///
/// RUN B batch B4 (ledger row 14): every round is production's shape. The
/// both-accepted races — where the repair's determinism keys on both rows
/// having server seqs — run as a CONCURRENT weave of production rounds
/// (`runProduction([.pull(a), .pull(b), .push(a), .push(b)])`): two offline
/// devices coming back at once, each round pull → push, the pulls landing
/// before either push. The never-accepted variant of the same races (one
/// row stranded, ranking seq 0) is the sweep suite's S4 — not duplicated.
@Suite("Apply-time repairs (Phase 5, Step 6)")
struct SyncRepairTests {
    /// A + B sharing one fake server, with a synced starting world built by
    /// `seed` on A and pulled to B.
    private func twoDevices(
        seed: (Operations, AppDatabase) throws -> Void
    ) async throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        try a.with { ops, db in try seed(ops, db) }
        try await productionQuiescence(a, b, server: server)  // world + settings seeds converge
        return (a, b, server)
    }

    private func assertConverged(
        _ a: SyncClient, _ b: SyncClient, _ server: FakeSyncServer
    ) async throws {
        try await productionQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
    }

    // MARK: - I2: move/move (place/place) race

    @Test func placementRaceConvergesToTheHigherSeq() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            let b1 = try ops.newBlock(in: post.id, text: "one.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "two.", at: .end).block
            _ = try ops.merge(b1.id, b2.id)  // releases b1, b2: live, unplaced
        }
        let released = try a.db.fetchString(
            """
            SELECT b.id FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS
              (SELECT 1 FROM container_block cb WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
            ORDER BY b.id LIMIT 1
            """)!

        // Both devices re-place the same released block, offline.
        let placementA: String = try a.with { ops, _ in
            let home = try ops.createPost(title: "A's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }
        let placementB: String = try b.with { ops, _ in
            let home = try ops.createPost(title: "B's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }
        // Concurrent production rounds (B4): both pulls run before either
        // push lands — the both-accepted meeting the seq ranking exists
        // for. A pushes first: its placement gets the LOWER seq; B's the
        // higher — later intent.
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])

        try await a.pull()
        // Deterministic outcome on A: B's placement (higher seq) won; A's
        // own placement was tombstoned by the repair — and the repair write
        // reached the outbox explicitly.
        #expect(try a.db.deletedAt("container_block", placementA) != nil)
        #expect(try a.db.deletedAt("container_block", placementB) == nil)
        #expect(try a.outboxContains("container_block", placementA),
                "the I2 repair must push or the devices silently diverge")

        try await b.pull()
        // Same choice on B: the incoming (lower-seq) rival lands tombstoned.
        #expect(try b.db.deletedAt("container_block", placementA) != nil)
        #expect(try b.db.deletedAt("container_block", placementB) == nil)
        #expect(try b.outboxContains("container_block", placementA))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            [released]) == 1, "exactly one live placement survives (I2)")
    }

    // MARK: - tag.path duplicate

    @Test func duplicateTagPathsKeepTheLexicallySmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            _ = try ops.createPost(title: "post", profile: nil)
        }
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!

        // Both devices independently create "ideas" and apply it to the
        // same post. A's UUIDs (AA…) sort below B's (BB…), so A's tag is
        // the deterministic keeper everywhere.
        let tagA: String = try a.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: postID)
            return tag.id
        }
        let tagB: String = try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: postID)
            return tag.id
        }
        // Concurrent production rounds (B4): both duplicates land before
        // either device meets the other's — the mirror accepts both (§2).
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])
        try await b.pull()

        // On B: the incoming (smaller-id) tag keeps; B's duplicate is
        // tombstoned, its application deduped against the keeper's, and
        // every repair write is enqueued.
        #expect(try b.db.deletedAt("tag", tagB) != nil)
        #expect(try b.db.deletedAt("tag", tagA) == nil)
        #expect(try b.outboxContains("tag", tagB))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM tag WHERE path = 'ideas' AND deleted_at IS NULL") == 1)
        #expect(try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL
            """, [postID]) == 1, "one live application survives, pointing at the keeper")
        #expect(try a.db.fetchString(
            "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [postID]) == tagA)
    }

    /// **RUN B B2 row 7 (17i fix item 1 — KnownIssues row 34; pre-existing
    /// since Phase 5, MAJOR):** the §7 sentence "re-point the duplicate's
    /// `post_tag`/`block_tag` rows to the keeper" has no time bound — it
    /// must hold for applications arriving AFTER the duplicate died.
    /// The pin as the row states it: two devices create "ideas" offline
    /// and each applies it to its OWN note; converge → BOTH notes tagged
    /// on both devices.
    ///
    /// The broken direction, traced: B rounds first (production pull→push
    /// — its pull is empty, so its push lands tag_B + its application
    /// un-repaired); A's pull then retires tag_B at the write-time
    /// collision (keeper = the smaller id, A's) and re-points "the
    /// duplicate's live applications" — but B's application arrives LATER
    /// IN THE SAME BATCH (registry order: `tag` before `post_tag`), meets
    /// the freshly-dead parent, and was orphan-stamped into its cascade;
    /// that tombstone then won the merge in both push orders. Red on old:
    /// B's note untagged everywhere. (The Phase 5 pin above applies both
    /// tags to the SAME post, which masks exactly this.)
    @Test(arguments: [200, 1])
    func applicationsArrivingAfterTheDuplicateTagDiedRepointToTheKeeper(batchSize: Int) async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            _ = try ops.createPost(title: "A's note", profile: nil)
            _ = try ops.createPost(title: "B's note", profile: nil)
        }
        let noteA = try a.db.fetchString(
            "SELECT id FROM container WHERE title = ?", ["A's note"])!
        let noteB = try a.db.fetchString(
            "SELECT id FROM container WHERE title = ?", ["B's note"])!

        // Offline: each device creates "ideas" and applies it to its OWN
        // note. A's UUIDs (AA…) sort below B's (BB…) — A's tag is the
        // deterministic keeper everywhere.
        let tagA: String = try a.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: noteA)
            return tag.id
        }
        let tagB: String = try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: noteB)
            return tag.id
        }

        // B rounds FIRST: its rows land un-repaired (the pull half is
        // empty). A's pull then meets tag_B and its application in ONE
        // batch, tag first. A's round is spelled as its two halves —
        // production's own order — so the (c) leg is asserted between
        // them, before the push drains the repair's rows.
        _ = try await productionRound(b, batchSize: batchSize)
        let aPull = try await a.pull(batchSize: batchSize)
        #expect(aPull.repairs >= 1, "A's pull ran the collision repair")
        // The repair's outbox rows exist on A (the suite's (c) leg): the
        // retired duplicate and the re-pointed application both push.
        #expect(try a.outboxContains("tag", tagB))
        let bApplication = try a.db.fetchString(
            "SELECT id FROM post_tag WHERE post_id = ?", [noteB])
        #expect(bApplication != nil, "B's application reached A")
        if let bApplication {
            #expect(try a.outboxContains("post_tag", bApplication),
                    "the arrival-order repair must push or the devices silently diverge")
        }
        _ = try await a.push(batchSize: batchSize)

        try await productionQuiescence(a, b, server: server, batchSize: batchSize)
        try await assertConverged(a, b, server)

        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'ideas' AND deleted_at IS NULL") == 1,
                "\(client.name): one keeper")
            #expect(try client.db.deletedAt("tag", tagA) == nil, "\(client.name)")
            #expect(try client.db.deletedAt("tag", tagB) != nil, "\(client.name)")
            for note in [noteA, noteB] {
                #expect(try client.db.fetchString(
                    """
                    SELECT tag_id FROM post_tag
                    WHERE post_id = ? AND deleted_at IS NULL
                    """, [note]) == tagA,
                    "\(client.name): BOTH notes carry a live application pointing at the keeper")
            }
        }
    }

    /// Row 7's block_tag twin, one construction: the same §7 sentence
    /// covers both application tables, and the arrival-order leg must
    /// serve `block_tag` identically (its registry slot also follows
    /// `tag`).
    @Test func blockTagApplicationsArrivingAfterTheDuplicateDiedRepointToo() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.newBlock(in: post.id, text: "A's block.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "B's block.", at: .end)
        }
        let blocks = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM block ORDER BY created_at, id")
        }
        let tagA: String = try a.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "marks")
            _ = try ops.applyTag(tag.id, toBlock: blocks[0])
            return tag.id
        }
        let tagB: String = try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "marks")
            _ = try ops.applyTag(tag.id, toBlock: blocks[1])
            return tag.id
        }
        _ = try await productionRound(b)
        _ = try await productionRound(a)
        try await productionQuiescence(a, b, server: server)
        try await assertConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.deletedAt("tag", tagB) != nil, "\(client.name)")
            for block in blocks {
                #expect(try client.db.fetchString(
                    """
                    SELECT tag_id FROM block_tag
                    WHERE block_id = ? AND deleted_at IS NULL
                    """, [block]) == tagA,
                    "\(client.name): both blocks stay tagged, on the keeper")
            }
        }
    }

    /// RUN B batch B4 — the registry-boundary chunk-split arm for the TAG
    /// family (ledger row 14). It went looking for the row-7 durable
    /// predicate's cross-batch green and FOUND A GAP instead — **B4 finding
    /// F-3**, routed as **ledger row 17 and FIXED in batch B5** (the ruled
    /// Shape A: the fingerprint defer in `SyncEngine.push`). This test is
    /// the finding's red-on-old pin, unwrapped at the fix.
    ///
    /// THE OLD MECHANISM, traced (history — what the fix ends): B's push
    /// dies AT the `post_tag` boundary — tag_B lands UNACKED, its
    /// application is stranded in the outbox. A's round retires tag_B at
    /// the collision (nothing to re-point yet) and its push commits INSIDE
    /// the A5 visibility band. B's resume round: the pull is EMPTY — the
    /// feed is STATE-BASED, so A's repair re-stamped tag_B's one row to a
    /// new seq inside the band and B's own echo is gone from the feed. B's
    /// push then re-sent tag_B at base 0 and the CAS REJECT delivered the
    /// tombstone — outside the changefeed, outside seq order, ahead of the
    /// keeper B had never seen. The reject-merge honored it; the LOCAL
    /// CASCADE killed B's live, never-seen-live application; the bounded
    /// push loop shipped it DEAD in the same call. On A it ARRIVED
    /// TOMBSTONED, so the arrival-order leg (`!resolved.isTombstoned`)
    /// never fired. Tombstone-wins converged both stores on the loss:
    /// noteB untagged EVERYWHERE — §7's "re-point the duplicate's rows to
    /// the keeper" (no time bound) and row 7's both-notes-tagged contract
    /// broken in the cross-batch order.
    ///
    /// THE FIX ASSERTED HERE (row 17's ruling): the reject DEFERS the
    /// out-of-context tombstone — visibly, through `PushReport.deferred`
    /// (row 12's honest reader; the state is never silent) — the stranded
    /// application ships LIVE in the same drain, row 7's arrival leg
    /// re-points it on A, and B's post-band pull delivers the retirement
    /// keeper-first where the collision repair does the rest. Both notes
    /// tagged on the keeper, on both devices; with row 7's two pins (the
    /// both-pushed arrival order) this asserts the contract in BOTH orders.
    @Test func aRejectDeliveredRetirementCascadesTheStrandedApplicationBeforeTheKeeperArrives() async throws {
        let server = FakeSyncServer(visibilityHorizon: 2)
        let bFault = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: bFault, clockOffset: 1000, seed: 2)
        func settle() async throws {
            for _ in 1...4 {
                _ = try await productionRound(a)
                await server.advanceClock(by: 2)
                _ = try await productionRound(b)
                await server.advanceClock(by: 2)
            }
        }
        try a.with { ops, _ in
            _ = try ops.createPost(title: "A's note", profile: nil)
            _ = try ops.createPost(title: "B's note", profile: nil)
        }
        try await settle()
        #expect(try a.outboxCount() == 0 && b.outboxCount() == 0, "the seed settled")
        let noteA = try a.db.fetchString("SELECT id FROM container WHERE title = ?", ["A's note"])!
        let noteB = try a.db.fetchString("SELECT id FROM container WHERE title = ?", ["B's note"])!

        // Offline: each device creates "ideas" and applies it to its own
        // note; A's tag (AA…) is the deterministic keeper.
        let tagA: String = try a.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: noteA)
            return tag.id
        }
        let tagB: String = try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: noteB)
            return tag.id
        }

        // B's round: the pull is empty; the push dies AT the post_tag
        // boundary — tag_B lands (unacked, still base 0 on B), its
        // application is stranded.
        _ = try await b.pull()
        try await pushSplitAtBoundary(b, table: "post_tag", transport: bFault)
        await server.advanceClock(by: 2)  // tag_B leaves the band

        // A's full round in the gap: its pull meets tag_B ALONE — the
        // collision retires it with NO application in sight to re-point —
        // and its push (the retirement + A's own tag and application)
        // commits INSIDE the band.
        let gapPull = try await a.pull()
        #expect(gapPull.repairs >= 1, "A's pull ran the collision repair on the bare duplicate")
        #expect(try a.db.deletedAt("tag", tagB) != nil)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM post_tag WHERE post_id = ?", [noteB]) == 0,
            "B's application has NOT arrived — the split held it back")
        _ = try await a.push()

        // B's resume round. The pull: EMPTY — the state-based feed holds
        // only tag_B's tombstone, re-stamped inside the band; B's own echo
        // is gone, so the unacked chunk cannot heal by merge.
        let bResumePull = try await b.pull()
        #expect(bResumePull.applied == 0 && bResumePull.merged == 0,
                "the band + the state-based feed hide everything from B")
        #expect(try b.db.deletedAt("tag", tagB) == nil, "B still holds its tag live")
        // The push: tag_B re-sends at base 0 → the CAS reject answers with
        // the tombstone — the F-3 fingerprint (server dead · local live ·
        // base 0) — and the fix DEFERS it, VISIBLY (row 12's counter: the
        // deferral is never silent). tag_B stays live locally, the
        // application survives and ships LIVE in the same drain.
        let bResumePush = try await b.push()
        #expect(bResumePush.deferred >= 1,
                "the out-of-context tombstone defers, and the report says so (row 12)")
        #expect(try b.db.deletedAt("tag", tagB) == nil,
                "the retirement did NOT land by reject — it waits for the feed")
        #expect(try b.db.fetchString(
            "SELECT deleted_at FROM post_tag WHERE post_id = ?", [noteB]) == nil,
            "B's application survives the resume drain LIVE")
        #expect(try b.outboxCount() >= 1, "tag_B stays enqueued for the post-band retry")
        await server.advanceClock(by: 2)

        // A's next pull: the application arrives — LIVE, under the locally
        // dead duplicate, with the keeper standing — and row 7's
        // arrival-order leg re-points it to the keeper and pushes.
        _ = try await a.pull()
        let bAppOnA = try a.db.fetchString(
            "SELECT id FROM post_tag WHERE post_id = ?", [noteB])
        #expect(bAppOnA != nil, "B's application reached A")
        #expect(try a.db.fetchString(
            "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [noteB]) == tagA,
            "row 7's arrival leg re-pointed the live arrival to the keeper")
        if let bAppOnA {
            #expect(try a.outboxContains("post_tag", bAppOnA),
                    "the re-point must push or the devices silently diverge (SyncSpec §7)")
        }

        try await settle()
        #expect(try a.syncedDump() == b.syncedDump(),
                "the stores converge — byte-identical")
        // THE CONTRACT (§7's sentence; row 7's letter), formerly wrapped as
        // finding F-3, now bare — the red-on-old for the B5 fix: BOTH notes
        // tagged on the keeper, on BOTH devices.
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'ideas' AND deleted_at IS NULL") == 1,
                "\(client.name): one keeper")
            #expect(try client.db.deletedAt("tag", tagB) != nil,
                "\(client.name): the duplicate is retired everywhere in the end")
            for note in [noteA, noteB] {
                #expect(try client.db.fetchString(
                    """
                    SELECT tag_id FROM post_tag
                    WHERE post_id = ? AND deleted_at IS NULL
                    """, [note]) == tagA,
                    "\(client.name): BOTH notes carry a live application pointing at the keeper")
            }
        }
    }

    // MARK: - Pure duplicates: edge (incl. reversed version_of), reading_post, post_tag

    @Test func reversedVersionOfEdgesAreDuplicatesKeepingTheSmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.newBlock(in: post.id, text: "one.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "two.", at: .end)
        }
        let blocks = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM block ORDER BY id")
        }
        // No operation mints version_of yet (KnownIssues, Phase 11); the
        // repair must still hold for hand-made rows — including a REVERSED
        // pair, which the canonical (min,max) storage rule makes the same
        // relationship (SyncSpec §7, review #8).
        try a.with { _, db in
            try db.write { db in
                try Fixture.edge(db, id: "AA-edge", source: blocks[0], target: blocks[1], type: "version_of")
            }
        }
        try b.with { _, db in
            try db.write { db in
                try Fixture.edge(db, id: "BB-edge", source: blocks[1], target: blocks[0], type: "version_of")
            }
        }
        // Concurrent production rounds (B4): both duplicates land before
        // either device meets the other's — the mirror accepts both (§2).
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])
        try await b.pull()

        #expect(try b.db.deletedAt("edge", "BB-edge") != nil)
        #expect(try b.db.deletedAt("edge", "AA-edge") == nil)
        #expect(try b.outboxContains("edge", "BB-edge"))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL") == 1)
    }

    @Test func duplicateReadingMembershipsKeepTheSmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.createReading(name: "book", kind: .book, maxPosts: nil)
            _ = post
        }
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!
        let readingID = try a.db.fetchString("SELECT id FROM reading")!
        let membershipA: String = try a.with { ops, _ in
            try ops.addPostToReading(postID, to: readingID).id
        }
        let membershipB: String = try b.with { ops, _ in
            try ops.addPostToReading(postID, to: readingID).id
        }
        // Concurrent production rounds (B4): both duplicates land before
        // either device meets the other's — the mirror accepts both (§2).
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])
        try await b.pull()

        let (keeper, loser) = membershipA < membershipB
            ? (membershipA, membershipB) : (membershipB, membershipA)
        #expect(try b.db.deletedAt("reading_post", loser) != nil)
        #expect(try b.db.deletedAt("reading_post", keeper) == nil)
        #expect(try b.outboxContains("reading_post", loser))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE deleted_at IS NULL") == 1)
    }

    // MARK: - I10: double-tombstone resurrection

    @Test func doubleTombstoneResurrectsTheHighestSeqVariantAsRescued() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            // The slot renders the default (no chosen pointer), so either
            // variant is individually deletable.
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let fan = try await a.db.read { db in
            try String.fetchAll(
                db, sql: "SELECT id FROM variant WHERE block_id = ? ORDER BY fan_position", arguments: [blockID])
        }
        let (v1, v2) = (fan[0], fan[1])

        // A deletes v1 (v2 survives); B deletes v2 (v1 survives). Both legal
        // locally; tombstones-win would leave a live block with no live
        // variant — I10 violated with neither device breaking a rule.
        try a.with { ops, _ in try ops.deleteVariant(v1) }
        try b.with { ops, _ in try ops.deleteVariant(v2) }
        // Concurrent production rounds (B4): both tombstones accepted
        // before either pull — v1's gets the lower seq, v2's the HIGHER.
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])

        try await a.pull()
        // Deterministic choice: resurrect the tombstoned variant with the
        // highest server_seq — v2 — status active, label 'rescued'.
        #expect(try a.db.deletedAt("variant", v2) == nil)
        #expect(try a.db.fetchString("SELECT label FROM variant WHERE id = ?", [v2]) == "rescued")
        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [v2]) == "active")
        #expect(try a.db.deletedAt("variant", v1) != nil, "the lower-seq tombstone stands")
        #expect(try a.outboxContains("variant", v2), "the resurrection must push")

        try await b.pull()
        #expect(try b.db.deletedAt("variant", v2) == nil, "B makes the SAME choice")
        #expect(try b.db.fetchString("SELECT label FROM variant WHERE id = ?", [v2]) == "rescued")

        try await assertConverged(a, b, server)
        // I10 + the default lifecycle hold in the converged world.
        #expect(try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS (
              SELECT 1 FROM variant v WHERE v.block_id = b.id
                AND v.deleted_at IS NULL AND v.status = 'active')
            """) == 0)
        #expect(try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID]) == v2,
            "the default re-points at the one live active variant")
    }

    /// PROVISIONAL (logged in QUESTIONS): the archive/archive race is the
    /// same I10 hole by a different door — SyncSpec §7 defines only the
    /// tombstone case, so the same doctrine is applied: deterministic
    /// rescue, never a block with no active take.
    @Test func archiveArchiveRaceRescuesByUnarchivingTheHighestSeq() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
        }
        let fan = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM variant ORDER BY fan_position")
        }
        try a.with { ops, _ in try ops.archiveVariant(fan[0]) }
        try b.with { ops, _ in try ops.archiveVariant(fan[1]) }
        // Concurrent production rounds (B4): both archives accepted first.
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])
        try await a.pull()

        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[1]]) == "active",
                "the higher-seq archived take is rescued back to active")
        #expect(try a.db.fetchString("SELECT label FROM variant WHERE id = ?", [fan[1]]) == "rescued")
        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[0]]) == "archived")
        #expect(try a.outboxContains("variant", fan[1]))

        try await b.pull()
        #expect(try b.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[1]]) == "active")

        try await assertConverged(a, b, server)
    }

    // MARK: - Dangling pointers

    @Test func danglingChosenVariantIsNulledOnBothDevices() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let placementID = try a.db.fetchString("SELECT id FROM container_block")!
        let fan = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM variant ORDER BY fan_position")
        }
        let v1 = fan[0]

        // B points the slot at v1 while A deletes v1 (fine on A, where the
        // slot shows the default). Different rows, both CAS-accepted;
        // RESTRICT never fires under soft delete (AppSpec §9 review #3).
        try b.with { ops, _ in try ops.chooseVariant(blockID, variantID: v1) }
        try a.with { ops, _ in try ops.deleteVariant(v1) }
        // Concurrent production rounds (B4): both writes accepted before
        // either device meets the other's — the repair fires on RECEIPT,
        // on each side.
        try await runProduction([.pull(a), .pull(b), .push(a), .push(b)])

        // A pulls B's chosen=v1 over a variant A knows is dead: the pointer
        // lands (FKs only need row existence), then the post-batch repair
        // NULLs it explicitly — and pushes.
        try await a.pull()
        #expect(try a.db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE id = ?", [placementID]) == nil)
        #expect(try a.outboxContains("container_block", placementID),
                "the NULL repair must push")

        try await b.pull()
        // B received v1's tombstone: its own chosen pointer dangles → NULL.
        #expect(try b.db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE id = ?", [placementID]) == nil)

        try await assertConverged(a, b, server)
        // The read layer renders the block through the default fallback.
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!
        let rendered = try await a.db.read { db in
            try Queries.renderPost(db, containerID: postID)
        }
        #expect(rendered.first?.text == "the original")
    }

    @Test func defaultVariantArrivingDeadIsReassigned() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "take one", at: .end)
            let v2 = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(v2.id, text: "take two", charDelta: 4)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let defaultID = try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID])!

        // A deletes the default; A's own device reassigns locally and pushes
        // the fixed block row. To exercise the RECEIVING side's repair, a
        // "third device" then CAS-writes the block row back to the dead
        // default on the server (the §7 review-#2 shape: a block row naming
        // a variant that arrives tombstoned).
        try a.with { ops, _ in
            try ops.deleteVariant(defaultID)
        }
        _ = try await productionRound(a)
        var staleBlock = await server.currentRow(table: "block", rowID: blockID)!
        staleBlock.columns["default_variant_id"] = .text(defaultID)
        _ = try await server.push([staleBlock], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        try await b.pull()
        let bDefault = try b.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID])
        #expect(bDefault != nil)
        #expect(bDefault != defaultID, "the dead-arriving default was reassigned")
        #expect(try b.db.fetchString(
            "SELECT status FROM variant WHERE id = ?", [bDefault ?? ""]) == "active")
        #expect(try b.outboxContains("block", blockID), "the reassignment must push")

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID]) == bDefault)
    }
}
