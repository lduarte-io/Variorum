import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U2 Q1/Q2 — THE PRIVATE MARK (R-13nb-4): the fence's third leg over
// v1_25's two stamps, derived in the ONE place (`Queries.mcpNoteFacts`), and
// the set/clear ops' exact transitions. The brief's pins: NULL reads
// not-private; a note in a private AND a granted book is fenced (privacy wins
// ties); an archived private book still fences (the journal leg's precedent);
// marking fences the very next decision (the end-to-end "next call on a
// connected client" pin is `MCPServerTests`').

@Suite("13n-b U2 — the Private mark: the fence's third leg and its ops")
struct MCPPrivateMarkTests {
    private func facts(_ db: AppDatabase, _ ids: [String]) throws -> [String: MCPGrantRule.NoteFacts] {
        try db.read { try Queries.mcpNoteFacts($0, noteIDs: ids) }
    }

    private func approvedClient(_ ops: Operations) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: "claude-code", version: nil)
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func decideRead(_ db: AppDatabase, _ clientID: String, note noteID: String) throws -> MCPGrantRule.Decision {
        try db.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            guard let facts else { return .refuse(.notShared) }
            return MCPGrantRule.decide(
                client: .approved, grants: try Queries.mcpGrants(db, clientID: clientID).map(\.ruleGrant),
                openBook: try Queries.mcpSwitch(db, .openBook), target: .note(facts), rung: .read, consumes: false)
        }
    }

    // MARK: - The leg

    @Test func nullReadsNotPrivateEverywhere() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "plain")
            let book = try ops.createReading(name: "plain book", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)
            // An explicit NULL (what a marker-12 peer's row, or a cleared mark,
            // carries) reads exactly as a fresh row: not private.
            try db.write { db in
                try db.execute(sql: "UPDATE container SET ai_private_at = NULL WHERE id = ?", arguments: [note.id])
                try db.execute(sql: "UPDATE reading SET ai_private_at = NULL WHERE id = ?", arguments: [book.id])
            }
            #expect(try facts(db, [note.id])[note.id]?.fence == nil)
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: book.id) }?.fence == nil)
            #expect(try db.read { try Queries.isNotePrivate($0, postID: note.id) } == false)
            #expect(try db.read { try Queries.isBookPrivate($0, readingID: book.id) } == false)
            #expect(try db.read { try Queries.mcpGrantableBooks($0) }.map(\.id) == [book.id])
        }
    }

    @Test func theThirdLegFencesExactlyAsRuled() throws {
        try withOperations { ops, db in
            let own = try ops.createPost(title: "own mark")
            let member = try ops.createPost(title: "in a private book")
            let arrival = try ops.createPost(title: "waiting at a private book's door")
            let archivedMember = try ops.createPost(title: "in an archived private book")
            let deletedMember = try ops.createPost(title: "in a deleted private book")
            let journalAndPrivate = try ops.createPost(title: "a journal entry, marked too", profile: .journal)
            let privateBook = try ops.createReading(name: "private", kind: .book)
            let archivedBook = try ops.createReading(name: "archived private", kind: .book)
            let deletedBook = try ops.createReading(name: "deleted private", kind: .book)
            _ = try ops.addPostToReading(member.id, to: privateBook.id)
            _ = try ops.addPostToReading(archivedMember.id, to: archivedBook.id)
            _ = try ops.addPostToReading(deletedMember.id, to: deletedBook.id)
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('arrival-p', ?, ?, 'a5', 'arrival', '2026-07-01T00:00:00.000Z')
                    """, arguments: [privateBook.id, arrival.id])
            }
            try ops.setNotePrivate(own.id, true)
            try ops.setNotePrivate(journalAndPrivate.id, true)
            for book in [privateBook, archivedBook, deletedBook] { try ops.setBookPrivate(book.id, true) }
            try ops.archiveReading(archivedBook.id)
            try ops.deleteReading(deletedBook.id)

            let all = try facts(db, [own.id, member.id, arrival.id, archivedMember.id, deletedMember.id,
                                     journalAndPrivate.id])
            #expect(all[own.id]?.fence == .privateMark, "its own mark")
            #expect(all[member.id]?.fence == .privateMark, "a live member of a live private book")
            #expect(all[archivedMember.id]?.fence == .privateMark, "an archived private book is still alive")
            #expect(all[arrival.id]?.fence == nil, "an arrival is never membership")
            #expect(all[deletedMember.id]?.fence == nil, "a deleted book is not alive")
            #expect(all[journalAndPrivate.id]?.fence == .privateMark, "privacy wins ties")
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: privateBook.id) }?.fence == .privateMark)
            #expect(try db.read { try Queries.privateBooksHolding($0, postID: member.id) } == ["private"])
        }
    }

    @Test func aNoteInAPrivateAndAGrantedBookIsFencedAndThePrivateBookIsNeverAScope() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let granted = try ops.createReading(name: "shared", kind: .book)
            let privateBook = try ops.createReading(name: "mine alone", kind: .book)
            let both = try ops.createPost(title: "in both")
            let sharedOnly = try ops.createPost(title: "shared only")
            _ = try ops.addPostToReading(both.id, to: granted.id)
            _ = try ops.addPostToReading(both.id, to: privateBook.id)
            _ = try ops.addPostToReading(sharedOnly.id, to: granted.id)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: granted.id, duration: .always))
            try ops.setBookPrivate(privateBook.id, true)

            #expect(try decideRead(db, client.id, note: sharedOnly.id).isAllowed)
            #expect(try decideRead(db, client.id, note: both.id) == .ask(.fenced(.privateMark), offersAlways: false),
                    "privacy wins ties: membership in ANY live private book fences the note everywhere")
            #expect(try db.read { try Queries.mcpGrantableBooks($0) }.map(\.id) == [granted.id],
                    "the grant sheet never offers a Private book")
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "book", id: privateBook.id)) {
                try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: privateBook.id, duration: .always))
            }
        }
    }

    @Test func markingFencesTheVeryNextDecisionAndClearingReopensIt() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let book = try ops.createReading(name: "shared", kind: .book)
            let note = try ops.createPost(title: "ch 1")
            _ = try ops.addPostToReading(note.id, to: book.id)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try decideRead(db, client.id, note: note.id).isAllowed)

            try ops.setNotePrivate(note.id, true)
            #expect(try decideRead(db, client.id, note: note.id) == .ask(.fenced(.privateMark), offersAlways: false),
                    "neither the standing book grant nor the open book reaches a Private note")
            try ops.setNotePrivate(note.id, false)
            #expect(try decideRead(db, client.id, note: note.id).isAllowed)

            try ops.setBookPrivate(book.id, true)
            #expect(try decideRead(db, client.id, note: note.id) == .ask(.fenced(.privateMark), offersAlways: false))
            try ops.setBookPrivate(book.id, false)
            #expect(try decideRead(db, client.id, note: note.id).isAllowed, "the grant survived as data")
        }
    }

    // MARK: - The ops

    @Test func theMarkIsIdentityMetadataNoOpGuardedUntouchingAndSynced() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "note")
            let book = try ops.createReading(name: "book", kind: .book)
            let touchedBefore = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            try db.clearOutbox()

            #expect(try ops.setNotePrivate(note.id, false) == false, "clearing an unmarked note writes nothing")
            #expect(try ops.setBookPrivate(book.id, false) == false)
            #expect(try !db.outboxContains("container", note.id))
            #expect(try !db.outboxContains("reading", book.id))

            #expect(try ops.setNotePrivate(note.id, true))
            #expect(try ops.setBookPrivate(book.id, true))
            #expect(try db.outboxContains("container", note.id), "a synced column: the outbox carries it")
            #expect(try db.outboxContains("reading", book.id))
            let stamp = try db.fetchString("SELECT ai_private_at FROM container WHERE id = ?", [note.id])
            #expect(stamp != nil)
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id]) == touchedBefore,
                    "no touch stamp — marking never reshuffles the library")

            try db.clearOutbox()
            #expect(try ops.setNotePrivate(note.id, true) == false, "marking a marked note writes nothing")
            #expect(try db.fetchString("SELECT ai_private_at FROM container WHERE id = ?", [note.id]) == stamp)
            #expect(try !db.outboxContains("container", note.id))

            #expect(try ops.setNotePrivate(note.id, false))
            #expect(try ops.setBookPrivate(book.id, false))
            #expect(try db.fetchString("SELECT ai_private_at FROM container WHERE id = ?", [note.id]) == nil)
            #expect(try db.fetchString("SELECT ai_private_at FROM reading WHERE id = ?", [book.id]) == nil)
        }
    }

    @Test func gatheringsAndScrapsRefuseTheMarkAndSealsFinishesAndArchivesAllowIt() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "percy")
            let gathering = try ops.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setBookPrivate(gathering.id, true)
            }
            let pool = try ops.createPool(title: "scraps")
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.setNotePrivate(pool.id, true)
            }
            #expect(throws: OperationError.readingNotFound(id: "nope")) { try ops.setBookPrivate("nope", true) }

            // PROVISIONAL P-13nb-U2-1: the mark protects rather than authors.
            let sealedNote = try ops.createPost(title: "sealed")
            try ops.lockPost(sealedNote.id)
            #expect(try ops.setNotePrivate(sealedNote.id, true))
            let archivedNote = try ops.createPost(title: "archived")
            try ops.archiveContainer(archivedNote.id)
            #expect(try ops.setNotePrivate(archivedNote.id, true))
            let finished = try ops.createReading(name: "finished", kind: .book)
            try ops.lockReading(finished.id)
            #expect(try ops.setBookPrivate(finished.id, true))
            let archivedBook = try ops.createReading(name: "put away", kind: .book)
            try ops.archiveReading(archivedBook.id)
            #expect(try ops.setBookPrivate(archivedBook.id, true))
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading WHERE ai_private_at IS NOT NULL") == 2)
        }
    }
}
