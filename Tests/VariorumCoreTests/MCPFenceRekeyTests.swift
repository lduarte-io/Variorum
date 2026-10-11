import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-c U1 — THE FENCE RE-KEY (VX-163, R-AIR-1, her Air round 2026-10-11):
// "for the default command J journal I think it's a fair choice but I am
// questioning it being applied to all journal style books (especially since it
// can be turned on and off for any book)." The never-always fence keys on (a)
// THE daily Journal — the book wearing the 'daily' marker — whose entries are
// per-ask only, and (b) anything wearing the Private mark. A journal-TRAIT book
// (`setJournalTrait`'s toggleable 'journal' profile) is a book like any other.
// D-1 (the orchestrator's kickoff decision, PROVISIONAL P-13nc-1): a note's OWN
// `profile='journal'` — the shape ⌘J's `createOrOpenJournalEntry` mints — stays
// a fence leg, so a day entry stays per-ask wherever it is later filed.
//
// Every pin reads the facts through the ONE derivation site
// (`Queries.mcpNoteFacts` / `mcpBookFacts` / `mcpGrantableBooks`) and decides
// through the ONE pure rule — never a parallel fence.

@Suite("13n-c U1 — the fence re-key (R-AIR-1)")
struct MCPFenceRekeyTests {
    private typealias Rule = MCPGrantRule

    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func grant(
        _ rung: Rule.Rung, _ kind: Rule.ScopeKind, _ id: String, _ duration: Rule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// A READ grant (the common case).
    private func grant(
        _ kind: Rule.ScopeKind, _ id: String, _ duration: Rule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        grant(.read, kind, id, duration)
    }

    /// Does `grants` (or the open book) let an approved client READ this note
    /// right now — the server's own question, through the one rule.
    private func reads(
        _ db: AppDatabase, _ noteID: String, grants: [Rule.Grant], openBook: Bool = false
    ) throws -> Bool {
        let facts = try db.read { try Queries.mcpNoteFacts($0, noteID: noteID) }
        guard let facts else { return false }
        return Rule.decide(
            client: .approved, grants: grants, openBook: openBook, target: .note(facts), rung: .read,
            consumes: false
        ).isAllowed
    }

    private func standing(_ kind: Rule.ScopeKind, _ id: String) -> [Rule.Grant] {
        [Rule.Grant(id: "g-\(kind.rawValue)", rung: .read, scopeKind: kind, scopeID: id, duration: .always)]
    }

    // MARK: - A trait book is a book like any other

    @Test func aJournalTraitBookIsOfferedAndTakesAStandingGrant() throws {
        try withOperations { ops, db in
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            // The toggle's road too: a plain book turned journal-style stays grantable.
            let toggled = try ops.createReading(name: "reading log", kind: .book)
            try ops.setJournalTrait(toggled.id, on: true)
            let daily = try ops.createReading(name: "journal", kind: .book, profile: "daily")

            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: trait.id) }?.fence == nil,
                    "the trait is not a fence")
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: toggled.id) }?.fence == nil)
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: daily.id) }?.fence == .journal,
                    "THE daily Journal stays fenced")

            let offered = try db.read { try Queries.mcpGrantableBooks($0) }.map(\.id)
            #expect(offered.contains(trait.id) && offered.contains(toggled.id), "the sheet offers trait books")
            #expect(!offered.contains(daily.id), "never the daily Journal")

            let client = try approvedClient(ops)
            _ = try ops.grantMCPAccess(client.id, grant(.book, trait.id, .always))
            _ = try ops.grantMCPAccess(client.id, grant(.suggest, .book, toggled.id, .connection))
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "book", id: daily.id)) {
                try ops.grantMCPAccess(client.id, grant(.book, daily.id, .once))
            }
        }
    }

    @Test func aTraitBooksMemberIsReachedByABookGrantAWingGrantAndTheOpenBook() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Work")
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal", wingId: wing.id)
            let member = try ops.newPostInReading(trait.id, title: "the flood dream")
            let facts = try #require(try db.read { try Queries.mcpNoteFacts($0, noteID: member.id) })
            #expect(facts.fence == nil, "a trait book's member is not fenced")
            #expect(facts.wingID == wing.id)

            #expect(try reads(db, member.id, grants: standing(.book, trait.id)), "a book grant on the trait book")
            #expect(try reads(db, member.id, grants: standing(.wing, wing.id)), "a wing grant on its wing")
            #expect(try reads(db, member.id, grants: [], openBook: true), "the open book")
            #expect(try reads(db, member.id, grants: standing(.wing, "")) == false, "never another wing's grant")

            // The faces' reads follow by construction (the chip and the note's line).
            let client = try approvedClient(ops)
            _ = try ops.grantMCPAccess(client.id, grant(.book, trait.id))
            #expect(try db.read { try Queries.mcpReachableBookIDs($0) } == [trait.id], "the trait book chips")
            #expect(try db.read { try Queries.mcpNoteSharing($0, noteID: member.id) }
                    == [MCPNoteSharing(clientName: "claude-code", rung: .read)])
        }
    }

    // MARK: - THE daily Journal stays fenced, every road

    @Test func theDailyJournalsMembersStayFencedUnderEveryStandingGrant() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let dailyID) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            // A note WITHOUT the day profile, filed in the daily Journal by hand:
            // the MEMBER leg alone fences it (the own-profile leg is D-1's).
            let filed = try ops.createPost(title: "a loose page")
            _ = try ops.addPostToReading(filed.id, to: dailyID)
            #expect(try db.read { try String.fetchOne($0, sql: "SELECT profile FROM reading WHERE id = ?",
                                                      arguments: [dailyID]) } == "daily")

            for note in [entry.id, filed.id] {
                #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: note) }?.fence == .journal)
                #expect(try reads(db, note, grants: standing(.wing, "")) == false, "never a Home-wing grant")
                #expect(try reads(db, note, grants: standing(.book, dailyID)) == false, "never a book grant")
                #expect(try reads(db, note, grants: [], openBook: true) == false, "never the open book")
                #expect(try reads(db, note, grants: [Rule.Grant(
                    id: "ask", rung: .read, scopeKind: .note, scopeID: note, duration: .once)]),
                        "only a per-ask note grant")
            }
            // Archived, the daily Journal still fences (it is alive — and it can
            // never be deleted, `dailyJournalCannotBeDeleted`).
            try ops.archiveReading(dailyID)
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: filed.id) }?.fence == .journal)
        }
    }

    // MARK: - D-1: a ⌘J day entry stays per-ask wherever it is filed

    @Test func aDayEntryFiledInATraitBookStaysFencedByItsOwnProfile() throws {
        try withOperations { ops, db in
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            _ = try ops.addPostToReading(entry.id, to: trait.id)
            let sibling = try ops.newPostInReading(trait.id, title: "written in the book")

            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: entry.id) }?.fence == .journal,
                    "D-1: its own profile is the entries the daily door makes")
            #expect(try reads(db, entry.id, grants: standing(.book, trait.id)) == false)
            #expect(try reads(db, entry.id, grants: standing(.wing, "")) == false)
            #expect(try reads(db, sibling.id, grants: standing(.book, trait.id)), "its book's other notes are not")
        }
    }

    // MARK: - F1 (the ladder's MAJOR — the recorded F-8, built): a LIVE
    // per-ask grant holder asking a HIGHER rung hears the honest rung

    /// The client's grant IS its knowledge of the note, so `rungTooLow` opens
    /// no oracle — while a SPENT once grant, a revoked grant, or anyone
    /// else's reach stays the fence's one answer (no road for a lapsed
    /// grant — the implementer's refinement on F1).
    @Test func aLivePerAskGrantHolderAskingHigherHearsRungTooLowNeverTheOneAnswer() {
        for fence in [Rule.Fence.journal, .privateMark] {
            let facts = Rule.NoteFacts(id: "n", wingID: "", bookIDs: [], fence: fence)
            let connected = Rule.Grant(
                id: "g-conn", rung: .read, scopeKind: .note, scopeID: "n", duration: .connection)
            #expect(Rule.decide(client: .approved, grants: [connected], openBook: false,
                                target: .note(facts), rung: .suggest, consumes: true)
                    == .ask(.rungTooLow(granted: .read), offersAlways: false),
                    "the honest rung — and never offering always on a fenced note (\(fence))")
            // An UNSPENT once grant is live too.
            let once = Rule.Grant(
                id: "g-once", rung: .suggest, scopeKind: .note, scopeID: "n", duration: .once)
            #expect(Rule.decide(client: .approved, grants: [once], openBook: false,
                                target: .note(facts), rung: .edit, consumes: true)
                    == .ask(.rungTooLow(granted: .suggest), offersAlways: false))
            // A SPENT once grant is not live: the fence's one answer returns,
            // even at the rung it once covered.
            let spent = Rule.Grant(
                id: "g-spent", rung: .read, scopeKind: .note, scopeID: "n",
                duration: .once, consumedAt: "t")
            #expect(Rule.decide(client: .approved, grants: [spent], openBook: false,
                                target: .note(facts), rung: .read, consumes: true)
                    == .ask(.fenced(fence), offersAlways: false),
                    "a lapsed grant opens no road")
            // A revoked grant likewise.
            let revoked = Rule.Grant(
                id: "g-rev", rung: .edit, scopeKind: .note, scopeID: "n",
                duration: .connection, revokedAt: "t")
            #expect(Rule.decide(client: .approved, grants: [revoked], openBook: false,
                                target: .note(facts), rung: .read, consumes: true)
                    == .ask(.fenced(fence), offersAlways: false))
            // A WIDER grant (book/wing) never reaches a fenced note, so it
            // earns no rung answer either — the fence stays the one answer.
            let wing = Rule.Grant(
                id: "g-wing", rung: .edit, scopeKind: .wing, scopeID: "", duration: .always)
            #expect(Rule.decide(client: .approved, grants: [wing], openBook: false,
                                target: .note(facts), rung: .suggest, consumes: true)
                    == .ask(.fenced(fence), offersAlways: false))
        }
    }

    // MARK: - Privacy still wins ties

    @Test func privacyStillWinsInsideATraitBook() throws {
        try withOperations { ops, db in
            let privateTrait = try ops.createReading(name: "secret diary", kind: .book, profile: "journal")
            try ops.setBookPrivate(privateTrait.id, true)
            let inPrivateTrait = try ops.newPostInReading(privateTrait.id, title: "locked away")
            let trait = try ops.createReading(name: "dream journal", kind: .book, profile: "journal")
            let privateNote = try ops.newPostInReading(trait.id, title: "not this one")
            try ops.setNotePrivate(privateNote.id, true)

            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: privateTrait.id) }?.fence == .privateMark)
            #expect(!(try db.read { try Queries.mcpGrantableBooks($0) }.map(\.id).contains(privateTrait.id)),
                    "a Private trait book is never offered")
            let client = try approvedClient(ops)
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "book", id: privateTrait.id)) {
                try ops.grantMCPAccess(client.id, grant(.book, privateTrait.id))
            }
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: inPrivateTrait.id) }?.fence == .privateMark)
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: privateNote.id) }?.fence == .privateMark)
            #expect(try reads(db, privateNote.id, grants: standing(.book, trait.id)) == false,
                    "a Private note in a granted trait book stays fenced")
            #expect(try reads(db, inPrivateTrait.id, grants: standing(.wing, "")) == false)
        }
    }
}
