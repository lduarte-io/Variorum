import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-857 (the VX-808 run) — BOOKS NEVER SPAN WINGS, UNDER SYNC: the
// convergence matrix the ruled fork names (the run record §6 Unit B1 — the
// proposal and the orchestrator's ruling A-808-1..5). `JournalWingConvergence
// Tests`' sibling: every scenario runs two (or three) in-memory clients against
// the fake server on the production path (real triggers, the real engine,
// E2EE payloads); every repair scenario asserts its EXPLICIT outbox rows and a
// positive activity count, and ends byte-identical at quiescence. Red-on-old
// is stated per test; the record carries the revert evidence (the pre-fix
// tree and each occasion's behavioral revert).
//
// The shared shape: A moves book X from Home to the wing "Studio" (its
// members move with it, ON A); B — offline, still seeing X in Home — files a
// note into X. Converged state then holds a live member of a book in Studio
// whose note sits in Home, unless the general mend repairs it.

// MARK: - Plumbing

private func wingOf(_ client: SyncClient, post postID: String) throws -> String? {
    try client.db.fetchString("SELECT wing_id FROM container WHERE id = ?", [postID])
}

private func isLiveMember(_ client: SyncClient, _ postID: String, of bookID: String) throws -> Bool {
    try client.db.fetchInt(
        """
        SELECT COUNT(*) FROM reading_post
        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
        """, [bookID, postID]) == 1
}

/// The pair's one row as (status, provenance, dead?) — the demotion's facts.
private func pairRow(
    _ client: SyncClient, _ postID: String, in bookID: String
) throws -> (id: String, status: String, provenance: String?, dead: Bool)? {
    try client.db.read { db in
        try Row.fetchOne(
            db, sql: """
                SELECT id, status, arrival_provenance, deleted_at FROM reading_post
                WHERE reading_id = ? AND post_id = ? ORDER BY id LIMIT 1
                """, arguments: [bookID, postID]
        ).map { ($0["id"], $0["status"], $0["arrival_provenance"], ($0["deleted_at"] as String?) != nil) }
    }
}

/// The note's live tag applications as path@wing — what adoption by path is
/// judged on.
private func tagsWorn(_ client: SyncClient, post postID: String) throws -> [String] {
    try client.db.read { db in
        try Row.fetchAll(
            db, sql: """
                SELECT t.path AS path, t.wing_id AS wing FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY t.path
                """, arguments: [postID]
        ).map { "\($0["path"] as String)@\($0["wing"] as String)" }
    }
}

private func syncAll(
    _ clients: [SyncClient], server: FakeSyncServer, maxRounds: Int = 12
) async throws {
    for _ in 1...maxRounds {
        for client in clients { try await client.push() }
        for client in clients { try await client.pull() }
        let head = await server.headSeq
        let quiet = try clients.allSatisfy { client in
            try client.outboxCount() == 0
                && client.db.fetchString(
                    "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == String(head)
        }
        if quiet { return }
    }
    throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
}

private func assertAllConverged(_ clients: [SyncClient], server: FakeSyncServer) async throws {
    try await syncAll(clients, server: server)
    let dumps = try clients.map { try $0.syncedDump() }
    for dump in dumps.dropFirst() {
        #expect(dump == dumps[0], "converged devices must be byte-identical")
    }
}

/// B files a fresh note into `bookID` (offline — the book as B sees it).
private func fileOffline(_ client: SyncClient, into bookID: String, title: String = "filed offline") throws -> String {
    try client.with { ops, _ in
        let note = try ops.createPost(title: title, profile: .generic)
        _ = try ops.addPostToReading(note.id, to: bookID)
        return note.id
    }
}

/// A raw membership row (status as given) — the shape a sync race or an older
/// or MCP-era writer leaves, which the ops doors themselves refuse.
private func insertRawMembership(
    _ client: SyncClient, id: String, book bookID: String, post postID: String, status: String
) throws {
    try client.with { _, db in
        try db.write { db in
            try db.execute(
                sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES (?, ?, ?, 'z0', ?, '2026-11-05T00:00:00.000Z')
                    """,
                arguments: [id, bookID, postID, status])
        }
    }
}

/// The wing mend's stamp (A-808-5, its spelling kept by A-808-6) — and, a
/// DEMOTION, its moment (A-808-7 (ii) — VX-808 Unit B2's AMENDMENT of this
/// suite: the stamp gained `at`, the mend's own stamp, so a demoted row never
/// mis-says since when): kind `wing_mend`, an `at`, no client (a repair).
private func isWingMendDemotion(_ json: String?) -> Bool {
    guard let provenance = ArrivalProvenance.decode(json), let at = provenance.at else { return false }
    return provenance.knownKind == .wingMend && provenance.client == nil
        && DateFormatter.variorumISO8601.date(from: at) != nil
        && json == (try? SyncEngine.wingMendArrivalProvenance(at: at))
}

// MARK: - The occasions

@Suite("VX-857 — the general mend's occasions: a moved book's offline filing follows it")
struct BookWingMendOccasionTests {
    /// BW1 — occasion (a), met at the MEMBERSHIP: A moves X to Studio and
    /// pushes; B, offline, files a tagged note with a saved version into X;
    /// A meets B's membership landing. The note moves into X's wing, its tag
    /// adopted by path, its saved version riding. RED ON OLD: the note stayed
    /// in Home, a live member of a book in Studio.
    @Test func bw1_aMovedBooksOfflineFilingFollowsIt_metAtTheMembership() async throws {
        let (a, b, server) = try furniturePair()
        let book = try a.with { ops, _ in try ops.createReading(name: "Harbour", kind: .book) }
        try await assertAllConverged([a, b], server: server)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(book.id, to: studio.id) }

        let note = try fileOffline(b, into: book.id)
        let version: String = try b.with { ops, _ in
            let tag = try ops.createTag(name: "tides")
            _ = try ops.applyTag(tag.id, toPost: note)
            _ = try ops.newBlock(in: note, text: "low water at six", at: .end)
            return try ops.saveNoteVersion(note).post.id
        }
        #expect(try wingOf(b, post: note) == "")

        try await a.push()   // the move reaches the server first
        try await b.push()   // then B's filing
        let pulled = try await a.pull()

        #expect(pulled.repairs > 0, "positive activity: the mend wrote")
        #expect(try wingOf(a, post: note) == studio.id)
        #expect(try wingOf(a, post: version) == studio.id, "its saved version rides")
        #expect(try tagsWorn(a, post: note) == ["tides@\(studio.id)"], "adopted by path — minted in Studio")
        #expect(try isLiveMember(a, note, of: book.id))
        #expect(try a.outboxContains("container", note))
        #expect(try a.outboxContains("container", version))
        let minted = try #require(try a.db.fetchString(
            "SELECT id FROM tag WHERE path = 'tides' AND wing_id = ? AND deleted_at IS NULL", [studio.id]))
        #expect(try a.outboxContains("tag", minted))
        for application in try await a.db.read({ db in
            try String.fetchAll(db, sql: "SELECT id FROM post_tag WHERE post_id = ?", arguments: [note])
        }) {
            #expect(try a.outboxContains("post_tag", application), "every application row pushes")
        }

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == studio.id)
            #expect(try wingOf(client, post: version) == studio.id)
            #expect(try isLiveMember(client, note, of: book.id))
            #expect(try tagsWorn(client, post: note) == ["tides@\(studio.id)"])
        }
    }

    /// BW2 — occasion (b), the other order, met at the BOOK's landing: B's
    /// filing reaches the server first (and B consumes its own echo, so its
    /// membership never re-lands — only the book's row can be the occasion);
    /// A moves X without having seen the filing; B meets the moved book (its
    /// own filing sits in the wing X left). RED ON OLD.
    @Test func bw2_theOtherOrder_metAtTheBooksLanding() async throws {
        let (a, b, server) = try furniturePair()
        let book = try a.with { ops, _ in try ops.createReading(name: "Harbour", kind: .book) }
        try await assertAllConverged([a, b], server: server)
        let note = try fileOffline(b, into: book.id)
        try await b.push()
        try await b.pull()   // the echo of B's own filing, consumed before the move lands
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(book.id, to: studio.id) }
        try await a.push()   // A has NOT pulled B's filing: it moved no such member
        let pulled = try await b.pull()

        #expect(pulled.repairs > 0)
        #expect(try wingOf(b, post: note) == studio.id, "B's own filing followed the book")
        #expect(try b.outboxContains("container", note))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == studio.id)
            #expect(try isLiveMember(client, note, of: book.id))
        }
    }

    /// BW3 — a FRESH third device meets the span whole (the book NEW here AND
    /// its member landing — occasions (b)-new and (a) both hold it): C pulls
    /// before A or B has mended and repairs it itself. RED ON OLD.
    @Test func bw3_aFreshDeviceMeetingTheSpanMendsIt() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 2000, seed: 3)
        let book = try a.with { ops, _ in try ops.createReading(name: "Harbour", kind: .book) }
        try await a.push()
        try await b.pull()
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(book.id, to: studio.id) }
        let note = try fileOffline(b, into: book.id)
        try await a.push()
        try await b.push()   // the server holds the span; nobody has mended yet

        let pulled = try await c.pull()
        #expect(pulled.repairs > 0, "the fresh device repaired the span it met")
        #expect(try wingOf(c, post: note) == studio.id)
        #expect(try c.outboxContains("container", note))

        try await assertAllConverged([a, b, c], server: server)
        for client in [a, b, c] {
            #expect(try wingOf(client, post: note) == studio.id)
            #expect(try isLiveMember(client, note, of: book.id))
        }
    }

    /// BW10 — the STRAGGLER-CONTAINER corner (vx-805 residual (6)): a fresh
    /// device whose feed delivers the membership BEFORE the note's container
    /// never lands the membership alone — the pull's FK fixpoint stalls on it
    /// — and the round that delivers the container lands both, where occasion
    /// (a) fires with the container present. No container occasion is needed.
    /// RED ON OLD (no mend for a non-Journal book).
    @Test func bw10_aMembershipNeverLandsAheadOfItsNotesContainer() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        // A spanning world on the server, nobody mending: X in Studio, the
        // note in Home, a live member row between them (written raw — the
        // shape the race leaves).
        let (book, note) = try a.with { ops, _ -> (String, String) in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Harbour", kind: .book, wingId: studio.id)
            let note = try ops.createPost(title: "straggling", profile: .generic)
            return (book.id, note.id)
        }
        try insertRawMembership(a, id: "0BW10000-0000-4000-8000-000000000001", book: book, post: note, status: "member")
        try await a.push()
        let stored = await server.storedRowsWithSeqs()
        let container = try #require(stored.first { $0.row.table == "container" && $0.row.rowID == note })
        let head = stored.map(\.serverSeq).max() ?? 0
        let scripted = ScriptedTransport(rows: stored.filter { $0 != container })
        let c = try SyncClient(name: "C", prefix: "CC", transport: scripted, clockOffset: 2000, seed: 3)

        let first = try await c.pull()
        #expect(first.stalled, "the membership waits for its note's container")
        #expect(try c.db.fetchInt("SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [note]) == 0,
                "never landed alone")

        await scripted.append([SyncPulledRow(row: container.row, serverSeq: head + 1)])
        let second = try await c.pull()
        #expect(!second.stalled)
        #expect(second.repairs > 0, "occasion (a) fired with the container present")
        let studio = try #require(try c.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [book]))
        #expect(try wingOf(c, post: note) == studio, "the note followed its book")
        #expect(try c.outboxContains("container", note))
    }
}

// MARK: - Book states: archived and frozen books mend too

@Suite("VX-857 — archived and frozen books home their members (a repair is not authoring)")
struct BookWingMendBookStateTests {
    /// BW4 — an ARCHIVED book still homes its notes (membership stays a fact):
    /// its offline filing follows it. RED ON OLD.
    @Test func bw4_anArchivedBooksFilingFollowsIt() async throws {
        let (a, b, server) = try furniturePair()
        let book = try a.with { ops, _ in
            let book = try ops.createReading(name: "Put away", kind: .book)
            try ops.archiveReading(book.id)
            return book
        }
        try await assertAllConverged([a, b], server: server)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(book.id, to: studio.id) }
        let note = try fileOffline(b, into: book.id)   // explicit adds land on an archived book
        try await a.push()
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(a, post: note) == studio.id)
        #expect(try a.outboxContains("container", note))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == studio.id)
            #expect(try isLiveMember(client, note, of: book.id))
            #expect(try client.db.fetchString("SELECT archived_at FROM reading WHERE id = ?", [book.id]) != nil)
        }
    }

    /// BW5 — a FINISHED (and a SEALED) book's offline filing follows it: B
    /// filed while it still saw the book open; the repair is not authoring,
    /// so the frozen assembly takes the member home. RED ON OLD.
    @Test(arguments: [false, true])
    func bw5_aFrozenBooksFilingFollowsIt(sealed: Bool) async throws {
        let (a, b, server) = try furniturePair()
        let book = try a.with { ops, _ in try ops.createReading(name: "Done", kind: .book) }
        try await assertAllConverged([a, b], server: server)
        let studio = try a.with { ops, _ -> Wing in
            if sealed { _ = try ops.sealReading(book.id) } else { try ops.lockReading(book.id) }
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(book.id, to: studio.id)
            return studio
        }
        let note = try fileOffline(b, into: book.id)   // B still sees it open, in Home
        try await a.push()
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(a, post: note) == studio.id)
        #expect(try a.outboxContains("container", note))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == studio.id)
            #expect(try isLiveMember(client, note, of: book.id), "the repair moved the note, never the row")
        }
    }
}

// MARK: - A note in books of two wings: the anchor, and the demotion (D)

@Suite("VX-857 — a note membered in books of two wings: one anchor, the rest demote (A-808-4/-5)")
struct BookWingMendAnchorTests {
    /// The shared world: books Y and X in Home, note P a member of Y — synced.
    /// A then moves X to Studio; B, offline, files P (already in Y) into X.
    private func twoBooks(
        _ a: SyncClient, _ b: SyncClient, server: FakeSyncServer, privateX: Bool = false
    ) async throws -> (y: String, x: String, note: String, studio: String) {
        let (y, x, note) = try a.with { ops, _ -> (String, String, String) in
            let y = try ops.createReading(name: "Y", kind: .book)
            let x = try ops.createReading(name: "X", kind: .book)
            if privateX { _ = try ops.setBookPrivate(x.id, true) }
            let note = try ops.createPost(title: "in two books", profile: .generic)
            _ = try ops.addPostToReading(note.id, to: y.id)
            return (y.id, x.id, note.id)
        }
        try await assertAllConverged([a, b], server: server)
        let studio = try a.with { ops, _ -> String in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(x, to: studio.id)
            return studio.id
        }
        _ = try b.with { ops, _ in try ops.addPostToReading(note, to: x) }   // B still sees X in Home
        return (y, x, note, studio)
    }

    /// BW6 — the anchor is the EARLIEST-ACCEPTED membership (Y's); the note
    /// stays in Home and the filing into X (now in Studio) DEMOTES to an
    /// arrival in place, stamped with the wing-mend provenance — a visible
    /// card at X's door, never a silent tombstone. RED ON OLD: P stayed a
    /// live member of both, X spanning wings.
    @Test func bw6_theEarliestMembershipAnchorsAndTheOtherDemotes() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await twoBooks(a, b, server: server)
        try await a.push()
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(a, post: world.note) == "", "the anchor (Y, earliest) keeps the note in Home")
        let row = try #require(try pairRow(a, world.note, in: world.x))
        #expect(row.status == "arrival" && !row.dead, "the filing into X waits at X's door")
        #expect(isWingMendDemotion(row.provenance), "it says why it waits, and since when")
        #expect(try a.outboxContains("reading_post", row.id), "the demotion pushes")
        #expect(try !a.outboxContains("container", world.note), "the note did not move")

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: world.note) == "")
            #expect(try isLiveMember(client, world.note, of: world.y))
            #expect(try !isLiveMember(client, world.note, of: world.x), "X no longer spans wings")
            let converged = try #require(try pairRow(client, world.note, in: world.x))
            #expect(converged.status == "arrival" && !converged.dead && isWingMendDemotion(converged.provenance))
        }
    }

    /// BW6b — a FROZEN book's loser takes the DISMISSAL-RECORD class: the
    /// anchor is a PRIVATE book (fenced outranks frozen); the filing into the
    /// finished book (moved to Studio) flips AND tombstones in one write — a
    /// finished book is never belled. RED ON OLD.
    @Test func bw6b_aFrozenBooksLoserBecomesADismissalRecord() async throws {
        let (a, b, server) = try furniturePair()
        let (z, f, note) = try a.with { ops, _ -> (String, String, String) in
            let z = try ops.createReading(name: "Private", kind: .book)
            _ = try ops.setBookPrivate(z.id, true)
            let f = try ops.createReading(name: "Finished", kind: .book)
            let note = try ops.createPost(title: "kept private", profile: .generic)
            _ = try ops.addPostToReading(note.id, to: z.id)
            return (z.id, f.id, note.id)
        }
        try await assertAllConverged([a, b], server: server)
        let studio = try a.with { ops, _ -> String in
            try ops.lockReading(f)
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(f, to: studio.id)
            return studio.id
        }
        _ = try b.with { ops, _ in try ops.addPostToReading(note, to: f) }   // B still sees F open, in Home
        try await a.push()
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(a, post: note) == "", "the fenced anchor keeps the note beside it")
        let row = try #require(try pairRow(a, note, in: f))
        #expect(row.status == "arrival" && row.dead, "a dismissal record — no live bell on a finished book")
        #expect(isWingMendDemotion(row.provenance))
        #expect(try a.outboxContains("reading_post", row.id))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == "")
            #expect(try isLiveMember(client, note, of: z))
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL", [f]) == 0)
            #expect(try client.db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [f]) == studio)
        }
    }

    /// BW7 — a PRIVATE book outranks an EARLIER plain one (fenced first): the
    /// note follows the private book into Studio and the plain membership
    /// demotes — so the resolution never strips the note's fence leg. RED ON
    /// OLD; red too with the rank's fenced term reverted (the plain book would
    /// anchor and the PRIVATE membership demote, unfencing the note).
    @Test func bw7_aPrivateBookOutranksAnEarlierPlainOne() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await twoBooks(a, b, server: server, privateX: true)
        try await a.push()
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(a, post: world.note) == world.studio, "the note follows the private book")
        #expect(try isLiveMember(a, world.note, of: world.x), "its fence leg stands")
        let row = try #require(try pairRow(a, world.note, in: world.y))
        #expect(row.status == "arrival" && !row.dead && isWingMendDemotion(row.provenance))
        #expect(try a.outboxContains("reading_post", row.id))
        #expect(try a.outboxContains("container", world.note))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: world.note) == world.studio)
            #expect(try isLiveMember(client, world.note, of: world.x))
            #expect(try !isLiveMember(client, world.note, of: world.y))
            let fenced = try await client.db.read { db in
                try Queries.mcpNoteFacts(db, noteID: world.note)
            }
            #expect(fenced?.fence != nil, "the note is still fenced from AI")
        }
    }

    /// BW9 — idempotence: after BW6's world converges, quiescent rounds write
    /// nothing — the demoted row is an arrival and never re-enters the mend's
    /// scope (A-808-3). RED ON OLD (the demotion asserts).
    @Test func bw9_quiescentRoundsAfterTheMendWriteNothing() async throws {
        let (a, b, server) = try furniturePair()
        let world = try await twoBooks(a, b, server: server)
        let moved = try fileOffline(b, into: world.x, title: "moves")   // a single-book note too
        try await assertAllConverged([a, b], server: server)
        #expect(try wingOf(a, post: moved) == world.studio)
        #expect(try pairRow(a, world.note, in: world.x)?.status == "arrival")
        let head = await server.headSeq
        for _ in 1...2 {
            for client in [a, b] {
                #expect(try await client.push().accepted == 0)
                #expect(try await client.pull().repairs == 0)
                #expect(try client.outboxCount() == 0)
            }
        }
        #expect(await server.headSeq == head, "nothing re-fired")
    }
}

// MARK: - Guards (green on both sides)

@Suite("VX-857 — the mend's guards: never a dead book, never an arrival, never a gathering, never her move-out")
struct BookWingMendGuardTests {
    /// BW8a — a membership arriving for a TOMBSTONED book never moves its note.
    @Test func bw8a_aDeadBookNeverMovesItsNote() async throws {
        let (a, b, server) = try furniturePair()
        let book = try a.with { ops, _ in try ops.createReading(name: "Gone", kind: .book) }
        try await assertAllConverged([a, b], server: server)
        try a.with { ops, _ in
            let studio = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(book.id, to: studio.id)
            try ops.deleteReading(book.id)
        }
        let note = try fileOffline(b, into: book.id)
        try await a.push()
        try await b.push()
        try await a.pull()
        #expect(try wingOf(a, post: note) == "", "never moved for a dead book")
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] { #expect(try wingOf(client, post: note) == "") }
    }

    /// BW8b — an ARRIVAL never moves a note (A-808-3 — an AI may propose at
    /// READ reach): an arrival for a Home note in a Studio book lands, and the
    /// note stays. (Its behavioral revert is the member-class filter in the
    /// mend's membership read.)
    @Test func bw8b_anArrivalNeverMovesANote() async throws {
        let (a, b, server) = try furniturePair()
        let (book, note) = try a.with { ops, _ -> (String, String) in
            let studio = try ops.createWing(name: "Studio")
            let book = try ops.createReading(name: "Harbour", kind: .book, wingId: studio.id)
            let note = try ops.createPost(title: "proposed", profile: .generic)
            return (book.id, note.id)
        }
        try await assertAllConverged([a, b], server: server)
        try insertRawMembership(b, id: "0BW8B000-0000-4000-8000-000000000001", book: book, post: note, status: "arrival")
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs == 0)
        #expect(try wingOf(a, post: note) == "", "a bell moves nothing")
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == "")
            #expect(try pairRow(client, note, in: book)?.status == "arrival")
        }
    }

    /// BW8c — a GATHERING holds nothing, so a stray live member row on one (a
    /// stale synced row) never mends: the mend reads books only.
    @Test func bw8c_aGatheringNeverMends() async throws {
        let (a, b, server) = try furniturePair()
        let (gathering, note) = try a.with { ops, _ -> (String, String) in
            let studio = try ops.createWing(name: "Studio")
            let spec = try Queries.SmartQuerySpec(profile: "journal").encodedJSON()
            let gathering = try ops.createReading(
                name: "Collected", kind: .gathering, querySpec: spec, wingId: studio.id)
            let note = try ops.createPost(title: "stray", profile: .generic)
            return (gathering.id, note.id)
        }
        try await assertAllConverged([a, b], server: server)
        try insertRawMembership(b, id: "0BW8C000-0000-4000-8000-000000000001", book: gathering, post: note, status: "member")
        try await b.push()
        let pulled = try await a.pull()
        #expect(pulled.repairs == 0)
        #expect(try wingOf(a, post: note) == "")
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] { #expect(try wingOf(client, post: note) == "") }
    }

    /// BW8d — her deliberate note move OUT of a book, pushed split between
    /// its container row and its membership tombstone, is met by the other
    /// device between the chunks: a container landing is no occasion, so the
    /// mend never undoes her move (M4's general twin).
    @Test func bw8d_aDeliberateMoveOutIsNeverUndoneBetweenTheChunks() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let (book, note, elsewhere) = try a.with { ops, _ -> (String, String, String) in
            let book = try ops.createReading(name: "Harbour", kind: .book)
            let note = try ops.createPost(title: "leaving", profile: .generic)
            _ = try ops.addPostToReading(note.id, to: book.id)
            return (book.id, note.id, try ops.createWing(name: "Elsewhere").id)
        }
        try await assertAllConverged([a, b], server: server)
        _ = try a.with { ops, _ in try ops.moveNoteToWing(note, to: elsewhere) }

        let split = try outboxRowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        try await b.pull()  // between the chunks: the note moved, its membership not yet dead
        #expect(try wingOf(b, post: note) == elsewhere)
        #expect(try !b.outboxContains("container", note), "no mend fired")

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: note) == elsewhere, "her move stands")
            #expect(try !isLiveMember(client, note, of: book))
        }
    }
}

// MARK: - The rank, pure

@Suite("VX-857 — the anchor rank, pure (A-808-4; tier 3 re-keyed by VX-893 (3))")
struct BookWingMendRankTests {
    private func membership(
        _ id: String, fenced: Bool = false, frozen: Bool = false, filed: String
    ) -> SyncEngine.Membership {
        SyncEngine.Membership(
            id: id, readingID: "r-\(id)", wingID: "", fenced: fenced, frozen: frozen, createdAt: filed)
    }

    /// fenced → frozen → earliest-FILED (`reading_post.created_at` — VX-893
    /// (3), the VX-912 run: converged bytes, replacing the per-device
    /// `sync_row_seq` and its never-accepted-last rule) → id; within a tier,
    /// ties fall through to the next term; a strict order.
    @Test func theRankIsFencedThenFrozenThenEarliestFiledThenID() {
        let plainEarly = membership("p1", filed: "2026-11-01T00:00:05.000Z")
        let plainLate = membership("p2", filed: "2026-11-01T00:00:09.000Z")
        let plainTwin = membership("p0", filed: "2026-11-01T00:00:09.000Z")   // p2's stamp: by id
        let frozen = membership("f1", frozen: true, filed: "2026-11-01T00:00:50.000Z")
        let fencedLate = membership("z2", fenced: true, filed: "2026-11-01T00:01:20.000Z")
        let fencedEarly = membership("z1", fenced: true, filed: "2026-11-01T00:01:10.000Z")
        let all = [plainLate, plainTwin, frozen, plainEarly, fencedLate, fencedEarly]
        #expect(all.sorted(by: SyncEngine.outranks).map(\.id) == ["z1", "z2", "f1", "p1", "p0", "p2"])
        #expect(SyncEngine.outranks(plainTwin, plainLate), "a created_at tie breaks by id")
        #expect(SyncEngine.outranks(plainEarly, frozen) == false, "a frozen book outranks an earlier filing")
        for x in all {
            #expect(!SyncEngine.outranks(x, x))
            for y in all where x.id != y.id {
                #expect(SyncEngine.outranks(x, y) != SyncEngine.outranks(y, x))
            }
        }
    }
}
