import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-268 (RUN VX-281, U2) — THE SHARED ICON ON EVERY ROW THE ASK GLYPH MARKS. Her
// report: "claude-code reaches two books, the Bookcase wears the icon on both, and the
// Library shows nothing on those books or on their notes." The ONE icon had two hosts
// (the Bookcase and the in-note indicator); the rows the ask glyph marks — the
// Library's, the Pool's, the Book Panel's, the wing switcher's — read no reach at all,
// and the core had no read sized for them: `mcpNoteReach` is one note at a time,
// `mcpBookReaches` decides every reading of every wing, and nothing read a WING's
// reach.
//
// These are the core's STATE pins for the three rows' reads (new API — the seam
// commit answers nothing, so every positive leg here is RED there, by construction;
// the bug's red-on-old is the Mac suite `MCPSharedRowsTests`): each batched read
// agrees with the ONE rule exactly — the singular read for notes, the whole map for
// books and gatherings, `decideWing` read off from the top rung for wings — the open
// book matches the Bookcase, VX-272 holds (no approved client, no reach), and P1's
// shape is pinned (the statements do not grow with the ids; nothing reads
// `container` when nothing can reach).

@Suite("VX-268 — the rows' reach reads: batched, one rule, ∝ the rows shown")
struct MCPRowReachTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String, wing: String = "") throws -> Container {
        let post = try ops.createPost(title: title, wingId: wing)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        return post
    }

    private func grant(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// The batched read and the singular one, for every id — the row and the
    /// note's own indicator can never disagree.
    private func agreesWithTheSingular(_ db: AppDatabase, _ ids: [String], _ label: String) throws {
        let batched = try db.read { try Queries.mcpNoteReaches($0, noteIDs: ids) }
        for id in ids {
            let singular = try db.read { try Queries.mcpNoteReach($0, noteID: id) }
            #expect((batched[id] ?? []) == singular, "\(label): \(id)")
            #expect(batched[id] == nil || !(batched[id] ?? []).isEmpty, "an unreached note is ABSENT, never []")
        }
    }

    // MARK: - Notes: the batched read IS the singular read, under every grant shape

    @Test func theBatchedNoteReadAgreesWithTheSingularUnderEveryShape() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            _ = try ops.recordMCPContact(name: "pending-one", version: nil)
            let variorum = try ops.createWing(name: "variorum")
            let own = try note(ops, "own grant")
            let member = try note(ops, "a member")
            let loose = try note(ops, "loose")
            let away = try note(ops, "away", wing: variorum.id)
            let secret = try note(ops, "a secret")
            _ = try ops.setNotePrivate(secret.id, true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            _ = try ops.addPostToReading(member.id, to: book.id)
            let ids = [own.id, member.id, loose.id, away.id, secret.id, entry.container.id, "no-such-note"]

            try agreesWithTheSingular(db, ids, "nothing granted")
            #expect(try db.read { try Queries.mcpNoteReaches($0, noteIDs: ids) }.isEmpty)

            let ownGrant = try ops.grantMCPAccess(claude.id, grant(.suggest, .note, own.id, .connection))
            let bookGrant = try ops.grantMCPAccess(claude.id, grant(.edit, .book, book.id))
            try agreesWithTheSingular(db, ids, "a note grant and a book grant")
            let reaches = try db.read { try Queries.mcpNoteReaches($0, noteIDs: ids) }
            // The positive controls (red on the seam): the rows' read SAYS them.
            #expect(reaches[own.id]?.first?.grant?.id == ownGrant)
            #expect(reaches[own.id]?.first?.throughTitle == nil, "its own grant: no why")
            #expect(reaches[member.id]?.first?.grant?.id == bookGrant)
            #expect(reaches[member.id]?.first?.throughTitle == "the lightning thief", "the why names the book")
            #expect(reaches[loose.id] == nil && reaches[away.id] == nil)

            // A wing grant reaches its wing's unfenced notes, never another wing's.
            _ = try ops.grantMCPAccess(codex.id, grant(.read, .wing, variorum.id))
            _ = try ops.grantMCPAccess(codex.id, grant(.writeNew, .wing, ""))
            try agreesWithTheSingular(db, ids, "wing grants")
            let wings = try db.read { try Queries.mcpNoteReaches($0, noteIDs: ids) }
            #expect(wings[away.id]?.map(\.clientName) == ["codex"])
            #expect(wings[away.id]?.first?.throughTitle == "variorum")
            #expect(wings[loose.id]?.first?.throughTitle == "Home")
            // The fence: a wing grant never reaches a Private note or a ⌘J entry.
            #expect(wings[secret.id] == nil, "Private: fenced")
            #expect(wings[entry.container.id] == nil, "a ⌘J entry: fenced")

            // A per-ask grant on a fenced note DOES reach it (its own, never always).
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .note, secret.id, .once))
            try agreesWithTheSingular(db, ids, "a once grant on a fenced note")
            #expect(try db.read { try Queries.mcpNoteReaches($0, noteIDs: [secret.id]) }[secret.id] != nil)

            // Duplicates and dead ids are harmless; the order of ids is not the answer's.
            let twice = try db.read { try Queries.mcpNoteReaches($0, noteIDs: [own.id, own.id, "x"]) }
            #expect(twice.keys.sorted() == [own.id])

            // Revoked: gone from the row.
            try ops.revokeMCPGrant(ownGrant)
            try agreesWithTheSingular(db, ids, "revoked")
            #expect(try db.read { try Queries.mcpNoteReaches($0, noteIDs: [own.id]) }[own.id] == nil)
        }
    }

    // MARK: - The open book matches the Bookcase: every unfenced note, every approved client

    @Test func theOpenBookReachesEveryUnfencedNoteForEveryApprovedClient() throws {
        try withOperations { ops, db in
            _ = try approvedClient(ops)
            _ = try approvedClient(ops, "codex")
            let denied = try approvedClient(ops, "gone")
            try ops.denyMCPClient(denied.id)
            let plain = try note(ops, "plain")
            let other = try note(ops, "in another wing", wing: try ops.createWing(name: "w").id)
            let secret = try note(ops, "secret")
            _ = try ops.setNotePrivate(secret.id, true)
            try ops.setMCPSwitch(.openBook, on: true)

            let reaches = try db.read { try Queries.mcpNoteReaches($0, noteIDs: [plain.id, other.id, secret.id]) }
            for id in [plain.id, other.id] {
                let reach = try #require(reaches[id], "the open book reaches every unfenced note")
                #expect(reach.map(\.clientName) == ["claude-code", "codex"], "approved clients only, by name")
                #expect(reach.allSatisfy { $0.viaOpenBook && $0.rung == .read && $0.duration == .always })
            }
            #expect(reaches[secret.id] == nil, "never a fenced note")
            try agreesWithTheSingular(db, [plain.id, other.id, secret.id], "the open book")
        }
    }

    // MARK: - VX-272 and P1: nothing to say ⇒ nothing read

    @Test func noApprovedClientMeansNoReachAndTheNotesAreNeverRead() throws {
        try withOperations { ops, db in
            let ids = try (0..<3).map { try note(ops, "note \($0)").id }
            let pending = try ops.recordMCPContact(name: "asking", version: nil)
            let denied = try approvedClient(ops, "denied")
            _ = try ops.grantMCPAccess(denied.id, grant(.edit, .wing, ""))
            try ops.denyMCPClient(denied.id)
            _ = pending
            try ops.setMCPSwitch(.openBook, on: true)

            let read = try db.read { db -> ([String: [MCPPlaceReach]], [String]) in
                var sqls: [String] = []
                db.trace { sqls.append($0.description) }
                defer { db.trace(options: [], nil) }
                return (try Queries.mcpNoteReaches(db, noteIDs: ids), sqls)
            }
            // GUARD (green on the seam by nature) paired with the control below.
            #expect(read.0.isEmpty, "VX-272: no approved client, no reach — the open book included")
            #expect(!read.1.contains { $0.contains("container") }, "nothing reads a note when nobody can reach one")

            // An approved client with no live grant, the open book off: still nothing read.
            let claude = try approvedClient(ops)
            try ops.setMCPSwitch(.openBook, on: false)
            let quiet = try db.read { db -> [String] in
                var sqls: [String] = []
                db.trace { sqls.append($0.description) }
                defer { db.trace(options: [], nil) }
                _ = try Queries.mcpNoteReaches(db, noteIDs: ids)
                return sqls
            }
            #expect(!quiet.contains { $0.contains("container") }, "no live grant, no open book: no note read")

            // The positive control (red on the seam).
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .note, ids[0]))
            #expect(try db.read { try Queries.mcpNoteReaches($0, noteIDs: ids) }.keys.sorted() == [ids[0]])
        }
    }

    /// **P1 — ∝ the rows shown, never per row:** the statements the batched read
    /// runs do not grow with the ids (one facts read for the page, one grants read
    /// per approved client), where the singular read per row would.
    @Test func theBatchedReadsStatementsDoNotGrowWithTheRows() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let book = try ops.createReading(name: "a book", kind: .book)
            let ids = try (0..<40).map { index -> String in
                let post = try note(ops, "note \(index)")
                if index.isMultiple(of: 3) { _ = try ops.addPostToReading(post.id, to: book.id) }
                return post.id
            }
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .book, book.id))
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .wing, ""))
            func statements(_ count: Int) throws -> Int {
                try db.read { db in
                    var total = 0
                    db.trace { _ in total += 1 }
                    defer { db.trace(options: [], nil) }
                    _ = try Queries.mcpNoteReaches(db, noteIDs: Array(ids.prefix(count)))
                    return total
                }
            }
            let few = try statements(2)
            let many = try statements(40)
            #expect(few > 0, "the read ran (red on the seam: it reads nothing)")
            #expect(few == many, "statements for 2 rows (\(few)) and 40 rows (\(many)) are the same — ∝ the page, one batch")
        }
    }

    // MARK: - Books and gatherings: the listed rows' read IS the whole map, restricted

    @Test func theListedBooksReadAgreesWithTheBookcasesMap() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let variorum = try ops.createWing(name: "variorum")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let bare = try ops.createReading(name: "a bare book", kind: .book)
            let gathering = try ops.createReading(
                name: "every star", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let away = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.star),
                wingId: variorum.id)
            let diary = try ops.createReading(name: "diary", kind: .book)
            _ = try ops.setBookPrivate(diary.id, true)
            let listed = [book.id, bare.id, gathering.id, away.id, diary.id, "no-such-book"]
            func agrees(_ label: String) throws {
                let whole = try db.read { try Queries.mcpBookReaches($0) }
                let rows = try db.read { try Queries.mcpBookReaches($0, readingIDs: listed) }
                for id in listed { #expect(rows[id] == whole[id], "\(label): \(id)") }
                #expect(Set(rows.keys).isSubset(of: Set(listed)), "only what is listed")
            }
            try agrees("nothing granted")
            let bookGrant = try ops.grantMCPAccess(claude.id, grant(.edit, .book, book.id))
            try agrees("a book grant")
            _ = try ops.grantMCPAccess(codex.id, grant(.read, .wing, ""))
            try agrees("a Home wing grant")
            let rows = try db.read { try Queries.mcpBookReaches($0, readingIDs: listed) }
            // The positive controls (red on the seam).
            #expect(rows[book.id]?.map(\.clientName) == ["claude-code", "codex"])
            #expect(rows[book.id]?.first?.grant?.id == bookGrant && rows[book.id]?.first?.throughTitle == nil)
            #expect(rows[gathering.id]?.map(\.clientName) == ["codex"], "a gathering: the wing grant only (R-VX185-1)")
            #expect(rows[gathering.id]?.first?.throughTitle == "Home")
            #expect(rows[away.id] == nil, "never across wings")
            #expect(rows[diary.id] == nil, "a Private book: fenced")
            try ops.setMCPSwitch(.openBook, on: true)
            try agrees("the open book")
            #expect(try db.read { try Queries.mcpBookReaches($0, readingIDs: [away.id]) }[away.id] != nil)
        }
    }

    // MARK: - Wings: decideWing, read off from the top rung — never a parallel rule

    @Test func aWingsReachIsDecideWingReadOffFromTheTop() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let variorum = try ops.createWing(name: "variorum")
            let elsewhere = try ops.createWing(name: "elsewhere")
            let book = try ops.createReading(name: "a book", kind: .book, wingId: elsewhere.id)
            let inside = try note(ops, "inside", wing: elsewhere.id)
            let wingIDs = ["", variorum.id, elsewhere.id]

            func agrees(_ label: String) throws {
                let all = try db.read { try Queries.mcpWingReaches($0) }
                try db.read { db in
                    let openBook = try Queries.mcpSwitch(db, .openBook)
                    for wing in wingIDs {
                        var expected: [String: (MCPGrantRule.Rung, String?)] = [:]
                        for client in try Queries.mcpClients(db, states: [.approved]) {
                            let rows = try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant)
                            for rung in MCPGrantRule.Rung.allCases.reversed() {
                                if case .allow(let grantID, _) = MCPGrantRule.decideWing(
                                    client: .approved, grants: rows, openBook: openBook,
                                    wingID: wing, rung: rung) {
                                    expected[client.name] = (rung, grantID)
                                    break
                                }
                            }
                        }
                        let shown = all[wing] ?? []
                        #expect(Set(shown.map(\.clientName)) == Set(expected.keys), "\(label): wing '\(wing)'")
                        for reach in shown {
                            #expect(reach.rung == expected[reach.clientName]?.0, "\(label): rung, wing '\(wing)'")
                            #expect(reach.grant?.id == expected[reach.clientName]?.1 ?? nil, "\(label): grant")
                        }
                    }
                }
                #expect(Set(all.keys).isSubset(of: Set(wingIDs)), "live wings only")
            }

            try agrees("nothing granted")
            #expect(try db.read { try Queries.mcpWingReaches($0) }.isEmpty)

            // P-VX281-U2-4: note and book grants INSIDE a wing never icon the wing.
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .book, book.id))
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .note, inside.id))
            try agrees("a book grant and a note grant inside a wing")
            #expect(try db.read { try Queries.mcpWingReaches($0) }[elsewhere.id] == nil)

            // A wing grant: its own place (no why), its rung and duration.
            let homeEdit = try ops.grantMCPAccess(claude.id, grant(.edit, .wing, ""))
            _ = try ops.grantMCPAccess(codex.id, grant(.read, .wing, variorum.id, .connection))
            try agrees("wing grants")
            let all = try db.read { try Queries.mcpWingReaches($0) }
            // The positive controls (red on the seam).
            let home = try #require(all[""])
            #expect(home.map(\.clientName) == ["claude-code"] && home[0].grant?.id == homeEdit)
            #expect(home[0].rung == .edit && home[0].duration == .always && home[0].throughTitle == nil)
            #expect(all[variorum.id]?.first?.rung == .read && all[variorum.id]?.first?.duration == .connection)
            #expect(all[elsewhere.id] == nil)

            // A once wing grant below a standing one: the highest rung's best grant.
            _ = try ops.grantMCPAccess(codex.id, grant(.writeNew, .wing, variorum.id, .once))
            try agrees("a once grant over a standing one")
            #expect(try db.read { try Queries.mcpWingReaches($0) }[variorum.id]?.first?.rung == .writeNew)

            // The open book: every wing, at read, for every approved client.
            try ops.setMCPSwitch(.openBook, on: true)
            try agrees("the open book")
            let open = try db.read { try Queries.mcpWingReaches($0) }
            #expect(open[elsewhere.id]?.allSatisfy { $0.viaOpenBook && $0.rung == .read } == true)
            #expect(open[elsewhere.id]?.map(\.clientName) == ["claude-code", "codex"])

            // A deleted wing leaves the map; a denied client leaves every row.
            try ops.deleteWing(variorum.id)
            try ops.denyMCPClient(codex.id)
            try agrees("a wing deleted, a client denied")
            #expect(try db.read { try Queries.mcpWingReaches($0) }[variorum.id] == nil)
        }
    }
}
