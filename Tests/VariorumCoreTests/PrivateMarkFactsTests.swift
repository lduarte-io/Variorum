import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// VX-831 — THE VISIBLE PRIVATE MARK's facts (`Queries.privateMarks` /
/// `privateBookMarks`): the store's own Private fact for the rows a host
/// draws — own, via a live Private book, none — read for exactly the ids
/// given (P1, the shared icon's law), never reach, never client state.
@Suite("VX-831 — the Private mark's facts: own · via a book · none, for the drawn ids only")
struct PrivateMarkFactsTests {
    private func marks(_ db: AppDatabase, _ ids: [String]) throws -> [String: Queries.PrivateMark] {
        try db.read { try Queries.privateMarks($0, noteIDs: ids) }
    }

    @Test func theThreeStatesOwnViaABookAndNone() throws {
        try withOperations { ops, db in
            let free = try ops.createPost(title: "free")
            let own = try ops.createPost(title: "own")
            let filed = try ops.createPost(title: "filed")
            let both = try ops.createPost(title: "both")
            let vault = try ops.createReading(name: "the vault", kind: .book)
            try ops.addPostToReading(filed.id, to: vault.id)
            try ops.addPostToReading(both.id, to: vault.id)
            try ops.setBookPrivate(vault.id, true)
            try ops.setNotePrivate(own.id, true)
            try ops.setNotePrivate(both.id, true)

            let read = try marks(db, [free.id, own.id, filed.id, both.id])
            let vaultRef = Queries.BookRef(id: vault.id, name: "the vault")
            #expect(read[free.id] == nil, "an unmarked note reads nothing back")
            #expect(read[own.id] == Queries.PrivateMark(own: true, viaBooks: []))
            #expect(read[filed.id] == Queries.PrivateMark(own: false, viaBooks: [vaultRef]))
            #expect(read[both.id] == Queries.PrivateMark(own: true, viaBooks: [vaultRef]))
            let allPrivate = read.values.allSatisfy { $0.isPrivate }
            #expect(allPrivate)
        }
    }

    @Test func viaABookMeansALiveMemberOfALivePrivateBook() throws {
        try withOperations { ops, db in
            let waiting = try ops.createPost(title: "waiting at the door")
            let gone = try ops.createPost(title: "in a deleted book")
            let shelved = try ops.createPost(title: "in an archived book")
            let plain = try ops.createPost(title: "in a plain book")
            let vault = try ops.createReading(name: "vault", kind: .book)
            let dead = try ops.createReading(name: "dead", kind: .book)
            let kept = try ops.createReading(name: "kept", kind: .book)
            let open = try ops.createReading(name: "open", kind: .book)
            try ops.addPostToReading(waiting.id, to: vault.id)
            try ops.addPostToReading(gone.id, to: dead.id)
            try ops.addPostToReading(shelved.id, to: kept.id)
            try ops.addPostToReading(plain.id, to: open.id)
            for book in [vault, dead, kept] { try ops.setBookPrivate(book.id, true) }
            // An ARRIVAL is never membership.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading_post SET status = 'arrival' WHERE post_id = ? AND reading_id = ?",
                    arguments: [waiting.id, vault.id])
            }
            try ops.deleteReading(dead.id)
            try ops.archiveReading(kept.id)

            let read = try marks(db, [waiting.id, gone.id, shelved.id, plain.id])
            #expect(read[waiting.id] == nil, "an arrival row is no membership")
            #expect(read[gone.id] == nil, "a deleted Private book marks nothing")
            #expect(read[shelved.id]?.viaBooks.map(\.name) == ["kept"], "an archived Private book is alive")
            #expect(read[plain.id] == nil, "a plain book marks nothing")
        }
    }

    /// The mark and the fence can never disagree: for live notes, the mark
    /// reads Private exactly where the fence's Private leg holds.
    @Test func theMarkIsExactlyTheFencesPrivateLeg() throws {
        try withOperations { ops, db in
            let notes = try (0..<5).map { try ops.createPost(title: "n\($0)") }
            let vault = try ops.createReading(name: "vault", kind: .book)
            try ops.setBookPrivate(vault.id, true)
            try ops.addPostToReading(notes[1].id, to: vault.id)
            try ops.setNotePrivate(notes[2].id, true)
            try ops.setNotePrivate(notes[3].id, true)
            try ops.addPostToReading(notes[3].id, to: vault.id)
            let ids = notes.map(\.id)
            let read = try marks(db, ids)
            let facts = try db.read { try Queries.mcpNoteFacts($0, noteIDs: ids) }
            for id in ids {
                #expect((read[id] != nil) == (facts[id]?.fence == .privateMark), "note \(id)")
            }
        }
    }

    @Test func onlyTheAskedIdsAreRead() throws {
        try withOperations { ops, db in
            let asked = try ops.createPost(title: "asked")
            let other = try ops.createPost(title: "not drawn")
            try ops.setNotePrivate(asked.id, true)
            try ops.setNotePrivate(other.id, true)
            #expect(Set(try marks(db, [asked.id]).keys) == [asked.id])
            #expect(try marks(db, []).isEmpty)
            #expect(try db.read { try Queries.privateBookMarks($0, readingIDs: []) }.isEmpty)
        }
    }

    @Test func aBookWearsItsOwnMarkAndAGatheringNever() throws {
        try withOperations { ops, db in
            let vault = try ops.createReading(name: "vault", kind: .book)
            let open = try ops.createReading(name: "open", kind: .book)
            let dead = try ops.createReading(name: "dead", kind: .book)
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "gathered", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(tag.id)))
            try ops.setBookPrivate(vault.id, true)
            try ops.setBookPrivate(dead.id, true)
            try ops.deleteReading(dead.id)
            // The ops refuse a gathering; a stale synced stamp is never drawn.
            #expect(throws: OperationError.self) { try ops.setBookPrivate(gathering.id, true) }
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET ai_private_at = '2026-11-05T00:00:00.000Z' WHERE id = ?",
                    arguments: [gathering.id])
            }
            let read = try db.read {
                try Queries.privateBookMarks($0, readingIDs: [vault.id, open.id, dead.id, gathering.id])
            }
            #expect(read == [vault.id])
        }
    }

    /// P1 — the shared icon's law, bound identically: both note statements
    /// and the book statement are driven by the ids (seeks), never a scan of
    /// `container`, `reading_post` or `reading`.
    @Test func everyStatementIsDrivenByTheIdsNeverAScan() throws {
        try withOperations { ops, db in
            let vault = try ops.createReading(name: "vault", kind: .book)
            for n in 0..<20 {
                let note = try ops.createPost(title: "n\(n)")
                try ops.addPostToReading(note.id, to: vault.id)
            }
            try ops.setBookPrivate(vault.id, true)
            for sql in [Queries.privateMarkOwnSQL, Queries.privateMarkViaSQL, Queries.privateBookMarkSQL] {
                let plan = try db.read { db -> String in
                    try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN \(sql)", arguments: ["[\"x\"]"])
                        .map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
                }
                for table in ["c", "rp", "r"] {
                    #expect(!plan.contains("SCAN \(table)"), "\(plan)")
                }
                // Non-vacuity: the table is reached, by a seek.
                #expect(plan.contains("SEARCH"), "\(plan)")
            }
            let via = try db.read { db -> String in
                try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN \(Queries.privateMarkViaSQL)", arguments: ["[\"x\"]"])
                    .map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
            }
            #expect(via.contains("idx_reading_post_post"), "\(via)")
        }
    }

    /// The hold re-reads as the facts move: a mark set or cleared, a filing
    /// into a Private book, a removal from it, the book's mark lifted — the
    /// held observation each host keeps over its drawn ids.
    @Test func aHeldReadFollowsEveryChangeOfTheFact() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "watched")
            let vault = try ops.createReading(name: "vault", kind: .book)
            try ops.setBookPrivate(vault.id, true)
            // R-878-K3: the hosts hold the GATED read, so a client is approved.
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            var values = db.observe { try Queries.privateMarksDrawn($0, noteIDs: [note.id]) }
                .makeAsyncIterator()
            #expect(try await values.next() == [:])
            try ops.setNotePrivate(note.id, true)
            #expect(try await values.next()?[note.id] == Queries.PrivateMark(own: true, viaBooks: []))
            try ops.addPostToReading(note.id, to: vault.id)
            #expect(try await values.next()?[note.id]?.viaBooks.map(\.id) == [vault.id])
            try ops.setNotePrivate(note.id, false)
            #expect(try await values.next()?[note.id] == Queries.PrivateMark(
                own: false, viaBooks: [Queries.BookRef(id: vault.id, name: "vault")]))
            _ = try ops.removePostFromReading(note.id, from: vault.id)
            #expect(try await values.next() == [:])
        }
    }

    // MARK: - R-878-K3 — the mark DRAWS only while a client is approved

    /// Her pick, "While a client is approved" — the shared icon's exact gate:
    /// with no approved client (none, a pending one, a denied one) the drawn
    /// reads say nothing is marked; an approval brings the facts; the plain
    /// facts (the fence parity, the Private row) never waited.
    @Test func theDrawnReadsWaitForAnApprovedClient() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "marked")
            let filed = try ops.createPost(title: "filed")
            let vault = try ops.createReading(name: "vault", kind: .book)
            try ops.addPostToReading(filed.id, to: vault.id)
            try ops.setBookPrivate(vault.id, true)
            try ops.setNotePrivate(note.id, true)
            func drawn() throws -> (notes: [String: Queries.PrivateMark], books: Set<String>) {
                try db.read { db in
                    (try Queries.privateMarksDrawn(db, noteIDs: [note.id, filed.id]),
                     try Queries.privateBookMarksDrawn(db, readingIDs: [vault.id]))
                }
            }
            let none = try drawn()
            #expect(none.notes.isEmpty && none.books.isEmpty, "no client: nothing drawn")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            let pending = try drawn()
            #expect(pending.notes.isEmpty && pending.books.isEmpty, "a waiting client is not approved")
            try ops.approveMCPClient(client.id, granting: nil)
            let approved = try drawn()
            #expect(Set(approved.notes.keys) == [note.id, filed.id])
            #expect(approved.books == [vault.id])
            try ops.denyMCPClient(client.id)
            let denied = try drawn()
            #expect(denied.notes.isEmpty && denied.books.isEmpty, "denied: no approved client")
            // The facts themselves never waited.
            #expect(Set(try marks(db, [note.id, filed.id]).keys) == [note.id, filed.id])
        }
    }

    /// "Nothing is read while no client is approved" — the shared icon's law,
    /// extended to the mark: the gated read's only read then is the grants
    /// store, so a held one sleeps through autosaves; an approval wakes it
    /// and the mark arrives.
    @Test func withNoApprovedClientTheHeldDrawnReadTouchesOnlyTheGrantsStore() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "marked")
            _ = try ops.newBlock(in: note.id, text: "a line", registeringUndo: false)
            let take = try #require(
                try await db.read { try Queries.renderPost($0, containerID: note.id) }.first?.variantID)
            try ops.setNotePrivate(note.id, true)
            let fetches = LockIsolated(0)
            var values = db.observe { db -> [String: Queries.PrivateMark] in
                fetches.withValue { $0 += 1 }
                return try Queries.privateMarksDrawn(db, noteIDs: [note.id])
            }.makeAsyncIterator()
            #expect(try await values.next() == [:])
            let first = fetches.value
            for index in 0..<3 {
                try ops.autosave(take, text: "a line, edited \(index)", charDelta: 2)
            }
            try await Task.sleep(for: .milliseconds(300))
            #expect(fetches.value == first, "no client: nothing past the grants store is read, so no autosave wakes it")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            #expect(try await values.next()?[note.id] == Queries.PrivateMark(own: true, viaBooks: []),
                    "an approval wakes it, and the mark is drawn")
            // The control (non-vacuity): with a client approved the read
            // reaches `container`, so the same autosave now does wake it.
            let approved = fetches.value
            try ops.autosave(take, text: "a line, edited again", charDelta: 2)
            for _ in 0..<100 where fetches.value == approved { try await Task.sleep(for: .milliseconds(10)) }
            #expect(fetches.value > approved, "approved: the read reaches the note, an autosave re-runs it")
        }
    }

    // MARK: - VX-900 — the twins' one rule: the switch dims a face, never gates a read

    /// Her ruling (the #264 sitting): both marks draw while a client is
    /// approved and only DIM while the server is off — so the server's switch
    /// must neither open the drawn reads' fence nor change what they answer.
    /// With no approved client, under BOTH switch states, the drawn reads say
    /// nothing is marked and read nothing but the client list; with one
    /// approved they answer the same with the switch off as on. A GUARD, green
    /// before VX-900 by nature (these reads never asked the server): the law
    /// the batch must not move — the existing fence above, extended across the
    /// switch.
    @Test func theServerSwitchNeitherOpensTheDrawnReadsFenceNorChangesTheirAnswer() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "marked")
            let filed = try ops.createPost(title: "filed")
            let vault = try ops.createReading(name: "vault", kind: .book)
            try ops.addPostToReading(filed.id, to: vault.id)
            try ops.setBookPrivate(vault.id, true)
            try ops.setNotePrivate(note.id, true)
            _ = try ops.recordMCPContact(name: "asking", version: "1")
            func traced() throws -> (notes: [String: Queries.PrivateMark], books: Set<String>, sqls: [String]) {
                try db.read { db in
                    var sqls: [String] = []
                    db.trace { sqls.append($0.description) }
                    defer { db.trace(options: [], nil) }
                    let notes = try Queries.privateMarksDrawn(db, noteIDs: [note.id, filed.id])
                    let books = try Queries.privateBookMarksDrawn(db, readingIDs: [vault.id])
                    return (notes, books, sqls)
                }
            }
            for on in [false, true] {
                try ops.setMCPSwitch(.server, on: on)
                let read = try traced()
                let label = on ? "server ON" : "server OFF"
                #expect(read.notes.isEmpty && read.books.isEmpty, "\(label): no approved client, nothing drawn")
                #expect(!read.sqls.isEmpty, "\(label): the gate ran (non-vacuity)")
                for table in ["container", "reading"] {
                    #expect(!read.sqls.contains { $0.contains(table) },
                            "\(label): nothing past the client list is read — no `\(table)` (\(read.sqls))")
                }
            }
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            try ops.setMCPSwitch(.server, on: true)
            let whileOn = try traced()
            try ops.setMCPSwitch(.server, on: false)
            let whileOff = try traced()
            #expect(Set(whileOn.notes.keys) == [note.id, filed.id] && whileOn.books == [vault.id],
                    "approved: the marks are drawn (non-vacuity)")
            #expect(whileOff.notes == whileOn.notes && whileOff.books == whileOn.books,
                    "the switch off changes nothing a drawn read answers — the face dims, the mark stays")
        }
    }

    /// The held twin: with no approved client a held drawn read sleeps through
    /// the server's switch flipping as it sleeps through autosaves — its only
    /// region is the client list, and the switch lives elsewhere.
    @Test func withNoApprovedClientTheSwitchFlippingWakesNoHeldDrawnRead() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "marked")
            try ops.setNotePrivate(note.id, true)
            let fetches = LockIsolated(0)
            var values = db.observe { db -> [String: Queries.PrivateMark] in
                fetches.withValue { $0 += 1 }
                return try Queries.privateMarksDrawn(db, noteIDs: [note.id])
            }.makeAsyncIterator()
            #expect(try await values.next() == [:])
            let first = fetches.value
            for on in [true, false, true] { try ops.setMCPSwitch(.server, on: on) }
            try await Task.sleep(for: .milliseconds(300))
            #expect(fetches.value == first, "no client: the switch flipping wakes nothing — nothing past the grants store")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            #expect(try await values.next()?[note.id] == Queries.PrivateMark(own: true, viaBooks: []),
                    "an approval wakes it (control) — the mark drawn whatever the switch")
        }
    }
}
