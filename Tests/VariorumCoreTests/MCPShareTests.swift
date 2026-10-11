import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-c U3 — GRANT FROM WHERE YOU ARE (VX-156 items 2 + 3; R-AIR-4/6/7): the
// bulk share (N note grants, ONE transaction, ONE stamp — any refusal refuses
// the whole act), Change… as a REPLACE in one act, Shared places grouped by
// act (the exact-stamp doctrine, no schema), the WHY read off the one
// `decide`, the reach reads that name the wider place, and ⌥⌘A's pure
// derivation (the newest grant's client + rung; while connected, else once;
// never always by a key).

@Suite("13n-c U3 — the share road: the bulk act, Change…, the groups, the why, the chord")
struct MCPShareTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        return post
    }

    private func grants(_ db: AppDatabase) throws -> [MCPGrantRow] {
        try db.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM mcp_grant ORDER BY rowid").compactMap(Queries.mcpGrant(from:))
        }
    }

    // MARK: - The bulk share

    @Test func aBulkShareMintsEveryNoteOnOneStampAsOneAct() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let parser = try note(ops, "parser notes")
            let grammar = try note(ops, "grammar sketch")
            let pages = try note(ops, "morning pages")
            let ids = try ops.grantMCPAccess(
                client.id, notes: [parser.id, grammar.id, parser.id, pages.id], rung: .read, duration: .connection)
            #expect(ids.count == 3, "a duplicate id collapses to one grant")
            let rows = try grants(db)
            #expect(rows.map(\.scopeID) == [parser.id, grammar.id, pages.id], "the act's order")
            #expect(Set(rows.map(\.createdAt)).count == 1, "ONE clock read — one stamp")
            #expect(rows.allSatisfy { $0.clientID == client.id && $0.rung == .read
                && $0.duration == .connection && $0.scopeKind == .note })
            #expect(rows.map(\.id) == ids)

            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.count == 1 && groups[0].isGroup && groups[0].memberCount == 3)
            #expect(groups[0].rows.map(\.targetTitle) == ["parser notes", "grammar sketch", "morning pages"])
            #expect(groups[0].grantIDs == ids && groups[0].inertCount == 0)
            #expect(try db.read { try Queries.mcpSharedGroupCount($0) } == 1)
        }
    }

    @Test func aBulkShareRefusesTheWholeActAndWritesNothing() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let open = try note(ops, "open")
            let secret = try note(ops, "secret")
            _ = try ops.setNotePrivate(secret.id, true)
            let book = try ops.createReading(name: "a book", kind: .book)

            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "note", id: "nowhere")) {
                try ops.grantMCPAccess(client.id, notes: [open.id, "nowhere"], rung: .read, duration: .always)
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "note", id: book.id),
                    "a book is not a note") {
                try ops.grantMCPAccess(client.id, notes: [open.id, book.id], rung: .read, duration: .once)
            }
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "note", id: secret.id),
                    "a fenced note never takes always — and the whole act refuses") {
                try ops.grantMCPAccess(client.id, notes: [open.id, secret.id], rung: .read, duration: .always)
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "note", id: "")) {
                try ops.grantMCPAccess(client.id, notes: [], rung: .read, duration: .once)
            }
            let pending = try ops.recordMCPContact(name: "codex", version: nil)
            #expect(throws: OperationError.mcpClientNotApproved(id: pending.id)) {
                try ops.grantMCPAccess(pending.id, notes: [open.id], rung: .read, duration: .once)
            }
            #expect(try grants(db).isEmpty, "a refused act wrote no row")

            // The per-ask durations are legal on a fenced note (R-13n-4).
            let ids = try ops.grantMCPAccess(
                client.id, notes: [open.id, secret.id], rung: .suggest, duration: .once)
            #expect(ids.count == 2)
        }
    }

    // MARK: - Shared places, grouped by act

    @Test func separateActsAreSeparateRowsAndBooksAndWingsNeverGroup() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            let c = try note(ops, "c")
            let first = try ops.grantMCPAccess(claude.id, notes: [a.id, b.id], rung: .read, duration: .always)
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let bookGrant = try ops.grantMCPAccess(
                claude.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            let wingGrant = try ops.grantMCPAccess(
                codex.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let second = try ops.grantMCPAccess(claude.id, notes: [c.id], rung: .read, duration: .always)

            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.map(\.grantIDs) == [second, [wingGrant], [bookGrant], first], "newest act first")
            #expect(groups.map(\.isGroup) == [false, false, false, true])
            #expect(try db.read { try Queries.mcpSharedGroupCount($0) } == 4)
            #expect(try db.read { try Queries.mcpSharedGroups($0, limit: 2) }.map(\.id) == [second[0], wingGrant],
                    "the limit caps ACTS")
            // A long act reads only the first few titles — the rest are counted.
            let many = try (0..<6).map { try note(ops, "n\($0)") }
            let manyIDs = try ops.grantMCPAccess(claude.id, notes: many.map(\.id), rung: .read, duration: .once)
            let newest = try #require(try db.read { try Queries.mcpSharedGroups($0, limit: 1) }.first)
            #expect(newest.grantIDs == manyIDs && newest.memberCount == 6)
            #expect(newest.rows.count == Queries.mcpSharedMemberTitles)
            #expect(newest.rows.map(\.targetTitle) == ["n0", "n1", "n2"])
        }
    }

    /// The doctrine at its edge: on ONE stamp (a frozen clock), note grants
    /// to one client at one rung and duration are one act — and a book or
    /// wing grant is never folded into anything.
    @Test func onOneStampNoteGrantsGroupAndBooksNever() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let a = try note(ops, "a")
            let b = try note(ops, "b")
            let one = try ops.createReading(name: "one", kind: .book)
            let two = try ops.createReading(name: "two", kind: .book)
            try withDependencies {
                $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            } operation: {
                let frozen = Operations()
                for book in [one, two] {
                    _ = try frozen.grantMCPAccess(
                        client.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
                }
                _ = try frozen.grantMCPAccess(
                    client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
                for post in [a, b] {
                    _ = try frozen.grantMCPAccess(
                        client.id, .init(rung: .read, scopeKind: .note, scopeID: post.id, duration: .always))
                }
            }
            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.map(\.memberCount) == [1, 1, 1, 2])
            #expect(groups.last?.rows.map(\.targetTitle) == ["a", "b"])
        }
    }

    @Test func anAlwaysActCountsItsInertMembersThroughTheRule() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let notes = try (0..<3).map { try note(ops, "note \($0)") }
            _ = try ops.grantMCPAccess(client.id, notes: notes.map(\.id), rung: .read, duration: .always)
            _ = try ops.setNotePrivate(notes[1].id, true)
            #expect(try db.read { try Queries.mcpSharedGroups($0) }.first?.inertCount == 1,
                    "an always grant on a note marked Private since reaches nothing (R2-3)")

            let perAsk = try (0..<2).map { try note(ops, "ask \($0)") }
            _ = try ops.grantMCPAccess(client.id, notes: perAsk.map(\.id), rung: .read, duration: .once)
            _ = try ops.setNotePrivate(perAsk[0].id, true)
            #expect(try db.read { try Queries.mcpSharedGroups($0) }.first?.inertCount == 0,
                    "a per-ask note grant reaches its own fenced note — never inert")
        }
    }

    @Test func revokeCoversEveryMemberOnOneStampOrNothing() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let notes = try (0..<3).map { try note(ops, "note \($0)") }
            let ids = try ops.grantMCPAccess(client.id, notes: notes.map(\.id), rung: .read, duration: .always)
            #expect(throws: OperationError.mcpGrantNotFound(id: "bogus")) {
                try ops.revokeMCPGrants([ids[0], "bogus"])
            }
            #expect(try grants(db).allSatisfy { $0.revokedAt == nil }, "a refused revoke revoked nothing")
            try ops.revokeMCPGrants(ids)
            let rows = try grants(db)
            #expect(rows.allSatisfy { $0.revokedAt != nil } && Set(rows.map(\.revokedAt)).count == 1)
            #expect(try db.read { try Queries.mcpSharedGroups($0) }.isEmpty)
        }
    }

    // MARK: - Change… replaces

    @Test func changeReplacesTheGrantItNamesInOneActOrChangesNothing() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let other = try approvedClient(ops, "codex")
            let parser = try note(ops, "parser notes")
            let old = try ops.grantMCPAccess(
                client.id, .init(rung: .edit, scopeKind: .note, scopeID: parser.id, duration: .connection))

            // Lowered: edit · while connected → read · once. The old grant must not stay live.
            let new = try ops.grantMCPAccess(
                client.id, .init(rung: .read, scopeKind: .note, scopeID: parser.id, duration: .once),
                replacing: [old])
            let rows = try grants(db)
            let oldRow = try #require(rows.first { $0.id == old })
            let newRow = try #require(rows.first { $0.id == new })
            #expect(oldRow.revokedAt == newRow.createdAt, "one act, one stamp")
            #expect(newRow.revokedAt == nil && newRow.rung == .read && newRow.duration == .once)
            #expect(try db.read { try Queries.mcpNoteReach($0, noteID: parser.id) }.first?.rung == .read,
                    "the lowered rung LANDS")

            // A refused replacement changes nothing.
            _ = try ops.setNotePrivate(parser.id, true)
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "note", id: parser.id)) {
                try ops.grantMCPAccess(
                    client.id, .init(rung: .read, scopeKind: .note, scopeID: parser.id, duration: .always),
                    replacing: [new])
            }
            #expect(try grants(db).first { $0.id == new }?.revokedAt == nil, "the old grant stands")
            #expect(try grants(db).count == 2)
            // Another client's grant is never this client's to replace.
            #expect(throws: OperationError.mcpGrantNotFound(id: new)) {
                try ops.grantMCPAccess(
                    other.id, .init(rung: .read, scopeKind: .note, scopeID: parser.id, duration: .once),
                    replacing: [new])
            }
            #expect(try grants(db).count == 2)
        }
    }

    @Test func changingAnActReplacesEveryMember() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let notes = try (0..<3).map { try note(ops, "note \($0)") }
            let ids = try ops.grantMCPAccess(client.id, notes: notes.map(\.id), rung: .read, duration: .once)
            let next = try ops.grantMCPAccess(
                client.id, notes: notes.map(\.id), rung: .suggest, duration: .always, replacing: ids)
            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.map(\.grantIDs) == [next], "one act replaced by one act")
            #expect(groups[0].lead.grant.rung == .suggest && groups[0].lead.grant.duration == .always)
        }
    }

    // MARK: - The why

    @Test func theWhyIsTheGrantDecideItselfUses() {
        let note = MCPGrantRule.NoteFacts(id: "n", wingID: "", bookIDs: ["b"])
        let own = MCPGrantRule.Grant(id: "g1", rung: .read, scopeKind: .note, scopeID: "n", duration: .once)
        let book = MCPGrantRule.Grant(id: "g2", rung: .suggest, scopeKind: .book, scopeID: "b", duration: .always)
        let wing = MCPGrantRule.Grant(id: "g3", rung: .read, scopeKind: .wing, scopeID: "", duration: .always)
        #expect(MCPGrantRule.reach(grants: [own, book, wing], openBook: false, target: .note(note))
                == .init(rung: .suggest, standing: .grant(book)), "the highest rung, and the grant behind it")
        #expect(MCPGrantRule.reach(grants: [own, wing], openBook: false, target: .note(note))
                == .init(rung: .read, standing: .grant(wing)), "a standing grant before a once grant")
        #expect(MCPGrantRule.reach(grants: [], openBook: true, target: .note(note))
                == .init(rung: .read, standing: .openBook))
        #expect(MCPGrantRule.reach(grants: [], openBook: false, target: .note(note)) == nil)

        var fenced = note
        fenced.fence = .privateMark
        #expect(MCPGrantRule.reach(grants: [book, wing], openBook: true, target: .note(fenced)) == nil,
                "a fenced note rides no standing grant and no open book")
        #expect(MCPGrantRule.reach(grants: [own, book], openBook: true, target: .note(fenced))
                == .init(rung: .read, standing: .grant(own)), "only its own per-ask grant")
        let spent = MCPGrantRule.Grant(
            id: "g4", rung: .read, scopeKind: .note, scopeID: "n", duration: .once, consumedAt: "x")
        #expect(MCPGrantRule.reach(grants: [spent], openBook: false, target: .note(note)) == nil)
    }

    @Test func theReachReadsNameTheWiderPlace() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let cursor = try approvedClient(ops, "cursor")
            let denied = try approvedClient(ops, "denied-one")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let parser = try note(ops, "parser notes")
            _ = try ops.addPostToReading(parser.id, to: book.id)
            _ = try ops.grantMCPAccess(
                claude.id, .init(rung: .suggest, scopeKind: .book, scopeID: book.id, duration: .always))
            _ = try ops.grantMCPAccess(codex.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let own = try ops.grantMCPAccess(
                cursor.id, .init(rung: .read, scopeKind: .note, scopeID: parser.id, duration: .connection))
            _ = try ops.grantMCPAccess(denied.id, .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
            try ops.denyMCPClient(denied.id)

            let reach = try db.read { try Queries.mcpNoteReach($0, noteID: parser.id) }
            #expect(reach.map(\.clientName) == ["claude-code", "codex", "cursor"], "a denied client reaches nothing")
            #expect(reach[0].rung == .suggest && reach[0].throughTitle == "the lightning thief")
            #expect(reach[1].rung == .read && reach[1].throughTitle == "Home" && reach[1].duration == .always)
            #expect(reach[2].grant?.id == own && reach[2].throughTitle == nil && reach[2].duration == .connection,
                    "the note's own grant needs no why")

            let bookReach = try db.read { try Queries.mcpBookReach($0, readingID: book.id) }
            #expect(bookReach.map(\.clientName) == ["claude-code", "codex"])
            #expect(bookReach[0].throughTitle == nil && bookReach[1].throughTitle == "Home")
            let all = try db.read { try Queries.mcpBookReaches($0) }
            #expect(all.keys.sorted() == [book.id] && all[book.id] == bookReach)

            try ops.setMCPSwitch(.openBook, on: true)
            let other = try note(ops, "loose")
            let openRead = try db.read { try Queries.mcpNoteReach($0, noteID: other.id) }
            #expect(openRead.first { $0.clientName == "cursor" }?.viaOpenBook == true)

            _ = try ops.setBookPrivate(book.id, true)
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: book.id) }.isEmpty)
            #expect(try db.read { try Queries.mcpBookReaches($0) }[book.id] == nil)
        }
    }

    @Test func noApprovedClientMeansNoBookReachAtAll() throws {
        try withOperations { ops, db in
            _ = try ops.createReading(name: "a book", kind: .book)
            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try db.read { try Queries.mcpBookReaches($0) }.isEmpty)
            _ = try ops.recordMCPContact(name: "pending", version: nil)
            #expect(try db.read { try Queries.mcpBookReaches($0) }.isEmpty)
        }
    }

    // MARK: - ⌥⌘A's derivation

    @Test func theChordGrantsTheNewestClientAndRungAndNeverAlways() {
        let newest = MCPShareChord.Newest(clientID: "c", clientName: "claude-code", rung: .suggest)
        #expect(MCPShareChord.decide(newest: newest, connected: true, reached: nil)
                == .grant(clientID: "c", clientName: "claude-code", rung: .suggest, duration: .connection))
        #expect(MCPShareChord.decide(newest: newest, connected: false, reached: .read)
                == .grant(clientID: "c", clientName: "claude-code", rung: .suggest, duration: .once))
        #expect(MCPShareChord.decide(newest: newest, connected: true, reached: .suggest)
                == .alreadyReaching(clientName: "claude-code", rung: .suggest))
        #expect(MCPShareChord.decide(newest: newest, connected: true, reached: .edit)
                == .alreadyReaching(clientName: "claude-code", rung: .edit))
        #expect(MCPShareChord.decide(newest: nil, connected: true, reached: nil) == .openSheet)
    }

    @Test func theNewestGrantIsHerLastChoiceAmongApprovedClients() throws {
        try withOperations { ops, db in
            #expect(try db.read { try Queries.mcpNewestGrant($0) } == nil, "no history")
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let parser = try note(ops, "parser notes")
            let first = try ops.grantMCPAccess(
                claude.id, .init(rung: .suggest, scopeKind: .note, scopeID: parser.id, duration: .once))
            try ops.revokeMCPGrant(first)
            #expect(try db.read { try Queries.mcpNewestGrant($0) }
                    == .init(clientID: claude.id, clientName: "claude-code", rung: .suggest),
                    "a revoked grant is still her last choice")
            _ = try ops.grantMCPAccess(codex.id, .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
            #expect(try db.read { try Queries.mcpNewestGrant($0) }?.clientName == "codex")
            try ops.denyMCPClient(codex.id)
            #expect(try db.read { try Queries.mcpNewestGrant($0) }?.clientName == "claude-code",
                    "a client denied since is skipped")
            try ops.denyMCPClient(claude.id)
            #expect(try db.read { try Queries.mcpNewestGrant($0) } == nil)
        }
    }
}
