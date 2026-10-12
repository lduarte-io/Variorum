import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-c U2 — THE GRANT SHEET's READ (VX-156 items 1 + 6; her kickoff's "sort
// by shelf … favorites"; round 2's last edited + recently edited): the offered
// books carry the Bookcase's own facts (shelf as the Bookcase resolves it, the
// union star, the honest "N notes", the state marks, made and LAST EDITED by
// the Bookcase's own derivation), the WHO row's order, and — the U1 ladder's
// R2-3 — a live grant that reaches nothing now is said as INERT, derived
// through the ONE rule on the ONE facts. P1 pinned by plan: ∝ the books'
// memberships, never the note corpus.

@Suite("13n-c U2 — the grant sheet's read: places, WHO and the inert row")
struct MCPGrantPlacesTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func grant(
        _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always, rung: MCPGrantRule.Rung = .read
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// A note with one block, so it carries a touch stamp.
    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        return try #require(try ops.database.read { try Container.fetchOne($0, key: post.id) })
    }

    // MARK: - The offered books' facts

    @Test func anOfferedBookCarriesTheBookcasesOwnFacts() throws {
        try withOperations { ops, db in
            let welcome = try ops.createShelf(name: "Welcome")
            let research = try ops.createShelf(name: "research")
            let sherlock = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            try ops.setReadingShelf(sherlock.id, shelf: welcome.id)
            let first = try note(ops, "a scandal in bohemia")
            let second = try note(ops, "the red-headed league")
            let set = try note(ops, "set aside")
            for post in [first, second, set] { _ = try ops.addPostToReading(post.id, to: sherlock.id) }
            try ops.archiveContainer(set.id)
            try ops.setStarred(.reading(sherlock.id), starred: true)
            _ = try ops.setReadingOwned(sherlock.id, owned: true)

            let empty = try ops.createReading(name: "nothing yet", kind: .book)
            try ops.setReadingShelf(empty.id, shelf: research.id)
            try ops.deleteShelf(research.id)   // the pointer now dangles → unshelved
            let finished = try ops.createReading(name: "done", kind: .book)
            try ops.lockReading(finished.id)

            let books = try db.read { try Queries.mcpGrantableBooks($0) }
            let byName = Dictionary(uniqueKeysWithValues: books.map { ($0.name, $0) })
            let s = try #require(byName["the adventures of sherlock holmes"])
            #expect(s.shelfID == welcome.id && s.starred)
            #expect(s.noteCount == 2, "the notes it SHOWS — an archived member is not counted (#169(a)(1))")
            #expect(s.marks == PlaceLabels.Marks(owned: true))
            let lastTouched = try db.read { db in
                try String.fetchOne(db, sql: "SELECT MAX(COALESCE(last_touched_at, created_at)) FROM container WHERE id IN (?, ?)",
                                    arguments: [first.id, second.id])
            }
            #expect(s.lastEdited == lastTouched, "last edited = the latest SHOWN member's touch (the Bookcase's derivation)")
            let e = try #require(byName["nothing yet"])
            #expect(e.shelfID == nil, "a dangling shelf pointer reads unshelved (§19)")
            #expect(e.noteCount == 0 && !e.starred)
            #expect(e.lastEdited == e.createdAt, "no shown notes ⇒ its birth (P-13id-U1-5's fallback)")
            #expect(try #require(byName["done"]).marks == PlaceLabels.Marks(finished: true))

            // The Bookcase's own answer agrees, book for book.
            let aggregates = try db.read { try Queries.bookcaseAggregates($0, wingID: "") }
            for book in books { #expect(aggregates.lastEdited[book.id] == book.lastEdited, "\(book.name)") }
        }
    }

    @Test func aShelfInAnotherWingReadsUnshelvedAndTheWingIsNamed() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "studio")
            let homeShelf = try ops.createShelf(name: "Welcome")
            let book = try ops.createReading(name: "percy", kind: .book, wingId: studio.id)
            // A hand-made dangling class: a shelf id from Home on a studio book.
            try db.write { try $0.execute(sql: "UPDATE reading SET shelf_id = ? WHERE id = ?", arguments: [homeShelf.id, book.id]) }
            let places = try db.read { try Queries.mcpGrantPlaces($0) }
            let offered = try #require(places.books.first { $0.id == book.id })
            #expect(offered.shelfID == nil, "a shelf belongs to ONE wing — elsewhere it dangles")
            #expect(places.wingName(offered.wingID) == "studio")
            #expect(places.place(offered).inHome == false)
            #expect(places.wingChoices.map(\.name) == ["Home", "studio"])
            #expect(places.shelves(inWing: "").map(\.id) == [homeShelf.id])
        }
    }

    @Test func theFenceStillDecidesWhatIsOffered() throws {
        try withOperations { ops, db in
            _ = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            let privateBook = try ops.createReading(name: "private", kind: .book)
            _ = try ops.setBookPrivate(privateBook.id, true)
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            _ = try ops.createReading(name: "a gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            #expect(try db.read { try Queries.mcpGrantableBooks($0) }.map(\.id) == [trait.id],
                    "U1's offer, untouched: never the daily Journal, a Private book or a gathering")
        }
    }

    // MARK: - Recently edited and the distinguishers

    @Test func recentlyEditedIsNewestFirstAndBounded() throws {
        try withOperations { ops, db in
            var ids: [String] = []
            for index in 0..<8 {
                let book = try ops.createReading(name: "book \(index)", kind: .book)
                let post = try note(ops, "note \(index)")
                _ = try ops.addPostToReading(post.id, to: book.id)
                ids.append(book.id)
            }
            let places = try db.read { try Queries.mcpGrantPlaces($0) }
            #expect(places.recentlyEdited().map(\.id) == Array(ids.reversed().prefix(Queries.mcpRecentlyEditedCount)))
            #expect(places.recentlyEdited(limit: 2).count == 2)
            #expect(places.recentlyEdited(limit: 0).isEmpty)
        }
    }

    @Test func twoSameNamedBooksAreToldApartByTheLadder() throws {
        try withOperations { ops, db in
            let welcome = try ops.createShelf(name: "Welcome")
            let first = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let second = try ops.createReading(name: "The Adventures of Sherlock Holmes", kind: .book)
            for book in [first, second] { try ops.setReadingShelf(book.id, shelf: welcome.id) }
            _ = try ops.createReading(name: "a letter", kind: .book)
            let places = try db.read { try Queries.mcpGrantPlaces($0) }
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let labels = places.bookDistinguishers(
                now: Date(timeIntervalSince1970: 1_782_864_000 + 86_400), calendar: calendar,
                locale: Locale(identifier: "en_US"))
            #expect(Set(labels.keys) == [first.id, second.id], "only the colliding pair gains a distinguisher")
            // Same wing, shelf, count (0) and state, same day — so the made TIME.
            #expect(labels[first.id]?.hasPrefix("made Jul 1, 12:00") == true, "\(labels)")
            #expect(labels[first.id] != labels[second.id])
        }
    }

    // MARK: - WHO

    @Test func whoListsApprovedClientsMostRecentlyGrantedFirst() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            let older = try approvedClient(ops, "older")
            let newer = try approvedClient(ops, "newer")
            let never = try approvedClient(ops, "never-granted")
            let pending = try ops.recordMCPContact(name: "pending", version: nil)
            _ = try ops.grantMCPAccess(older.id, grant(.book, book.id))
            let revokedLater = try ops.grantMCPAccess(newer.id, grant(.book, book.id))
            try ops.revokeMCPGrant(revokedLater)
            let order = try db.read { try Queries.mcpClientsByRecentGrant($0) }.map(\.name)
            #expect(order == ["newer", "older", "never-granted"],
                    "her newest grant first (revoked rows count — it is when SHE granted), then the never-granted; never a pending client")
            _ = never
            _ = pending
        }
    }

    // MARK: - R2-3: an inert grant is never called shared (RED-FIRST)

    @Test func aGrantWhoseTargetIsFencedSinceReadsInertAndIsNotCountedShared() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let open = try note(ops, "open note")
            let marked = try note(ops, "marked note")
            _ = try ops.grantMCPAccess(client.id, grant(.book, book.id))
            _ = try ops.grantMCPAccess(client.id, grant(.book, trait.id))
            _ = try ops.grantMCPAccess(client.id, grant(.note, marked.id, .always))
            _ = try ops.grantMCPAccess(client.id, grant(.note, open.id, .connection))
            _ = try ops.grantMCPAccess(client.id, grant(.wing, ""))

            func inert() throws -> [String: MCPGrantRule.Fence] {
                var answer: [String: MCPGrantRule.Fence] = [:]
                for row in try db.read({ try Queries.mcpSharedRows($0) }) {
                    if let fence = row.inertFence { answer[row.grant.scopeID] = fence }
                }
                return answer
            }
            #expect(try inert().isEmpty, "every grant reaches while nothing is fenced")
            #expect(try db.read { try Queries.mcpGrantReachCounts($0, clientID: client.id) } == (5, 0))

            _ = try ops.setBookPrivate(book.id, true)                 // a book marked Private
            try ops.setDailyJournalBook(trait.id)                      // a trait book made THE daily Journal
            _ = try ops.setNotePrivate(marked.id, true)                // an "always" note grant, the note marked
            _ = try ops.setNotePrivate(open.id, true)                  // a per-ask note grant: STILL reaches

            #expect(try inert() == [book.id: .privateMark, trait.id: .journal, marked.id: .privateMark],
                    "inert exactly where MCPGrantRule.reaches refuses: the fenced book, the daily Journal, an always grant on a Private note — never a per-ask note grant or a wing")
            let counts = try db.read { try Queries.mcpGrantReachCounts($0, clientID: client.id) }
            #expect(counts == (2, 3), "the client row's “N shared places” counts only grants that reach")

            _ = try ops.setBookPrivate(book.id, false)                // clearing the mark reopens it (P-13nb-U2-3)
            #expect(try inert()[book.id] == nil)
        }
    }

    // MARK: - P1

    @Test func theOfferedBooksReadIsEnteredPerBookNeverByTheNoteCorpus() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            let post = try note(ops, "n")
            _ = try ops.addPostToReading(post.id, to: book.id)
            let plan = try db.read { database in
                try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(Queries.mcpGrantableBooksSQL)")
                    .map { ($0["detail"] as String?) ?? "" }
            }.joined(separator: "\n")
            #expect(plan.contains("SEARCH rp USING"), "each book's memberships entered by its index; plan:\n\(plan)")
            #expect(!plan.contains("SCAN rp") && !plan.contains("SCAN reading_post"), "never a scan of the pair table; plan:\n\(plan)")
            #expect(!plan.contains("SCAN c") && !plan.contains("SCAN container"), "never a scan of the notes; plan:\n\(plan)")
        }
    }
}
