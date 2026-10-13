import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-185 (RUN VX-184, U2) — THE GATHERINGS ICON. Her report: "gatherings don't
// show as being shared with AI right now (the icon doesn't appear on them)
// even when you've shared the whole wing with AI … if they're shared as part of
// the wing, that needs to be clear." The wire has read a wing's gatherings since
// 13n-c U6 (R-AIR-12 — `MCPGrantRule.decideGathering`: wing-level reach on the
// gathering's wing, or the open book); the Bookcase's icon map
// (`Queries.mcpBookReaches`) enumerated `kind = 'book'` only, so no gathering
// ever wore the icon. Her ruling R-VX185-1: "I think that's fine on the
// gathering isn't marked shared even if each individual note is marked shared"
// — only a wing grant or the open book icons a gathering.
//
// RED-ON-OLD, stated: this file uses only API that stood before the fix (the
// reach reads, `decideGathering`, `mcpGatheringFacts`, the ops), so it compiled
// and ran RED on the pre-fix tree — every test below fails there on its
// positive leg (the gathering absent from the map). The R-VX185-1 and fence
// legs are GUARDS, green on both sides by nature (the old map iconed no
// gathering at all); each test pairs its guard with a positive control so the
// test as a whole is red-capable.

@Suite("VX-185 — a gathering wears the shared icon under a wing grant or the open book, never a note or book grant")
struct MCPGatheringReachTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String, wing: String = "", tag: String? = nil) throws -> Container {
        let post = try ops.createPost(title: title, wingId: wing)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        if let tag { _ = try ops.applyTag(tag, toPost: post.id) }
        return post
    }

    private func gathering(_ ops: Operations, _ name: String, wing: String = "", tag: String? = nil) throws -> Reading {
        try ops.createReading(
            name: name, kind: .gathering,
            querySpec: try RuleGrammar.encode(tag.map { .tag($0) } ?? .star), wingId: wing)
    }

    private func grant(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    private func icons(_ db: AppDatabase) throws -> [String: [MCPPlaceReach]] {
        try db.read { try Queries.mcpBookReaches($0) }
    }

    // MARK: - A wing grant icons the gathering, and names the wing

    @Test func aWingGrantIconsTheWingsGatheringsAndNamesTheWing() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let variorum = try ops.createWing(name: "variorum")
            let ideas = try ops.createTag(name: "ideas")
            let home = try gathering(ops, "every idea", tag: ideas.id)
            _ = try note(ops, "an idea", tag: ideas.id)
            let away = try gathering(ops, "parser things", wing: variorum.id)
            let homeGrant = try ops.grantMCPAccess(claude.id, grant(.edit, .wing, ""))
            let awayGrant = try ops.grantMCPAccess(codex.id, grant(.writeNew, .wing, variorum.id, .connection))

            let all = try icons(db)
            let onHome = try #require(all[home.id], "a Home wing grant icons a Home gathering")
            #expect(onHome.map(\.clientName) == ["claude-code"], "a wing grant never crosses wings")
            #expect(onHome[0].grant?.id == homeGrant && onHome[0].grant?.scopeKind == .wing)
            #expect(onHome[0].throughTitle == "Home", "the why names the wing")
            #expect(onHome[0].rung == .read, "a gathering is read only — decideGathering's one rung, whatever the grant's")
            #expect(onHome[0].duration == .always)

            let onAway = try #require(all[away.id])
            #expect(onAway.map(\.clientName) == ["codex"])
            #expect(onAway[0].grant?.id == awayGrant && onAway[0].throughTitle == "variorum")
            #expect(onAway[0].rung == .read && onAway[0].duration == .connection)

            // The singular read and the map agree, for a gathering as for a book.
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: home.id) } == onHome)
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: away.id) } == onAway)

            // Revoking the wing grant takes the icon off — it was the wing's.
            try ops.revokeMCPGrant(homeGrant)
            #expect(try icons(db)[home.id] == nil)
            #expect(try icons(db)[away.id] != nil)
        }
    }

    // MARK: - R-VX185-1: note and book grants never icon a gathering

    @Test func noteAndBookGrantsNeverIconAGatheringEvenWhenEveryNoteIsShared() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let drafts = try ops.createTag(name: "draft")
            let gathered = try gathering(ops, "every draft", tag: drafts.id)
            let book = try ops.createReading(name: "the drafts book", kind: .book)
            let members = try ["rivers", "doors"].map { try note(ops, "a draft about \($0)", tag: drafts.id) }
            for member in members {
                _ = try ops.addPostToReading(member.id, to: book.id)
                _ = try ops.grantMCPAccess(claude.id, grant(.read, .note, member.id))
            }
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .book, book.id))
            #expect(try db.read { try Queries.assembleReading($0, readingID: gathered.id) }.count == 2)
            for member in members {
                #expect(try db.read { try Queries.mcpNoteReach($0, noteID: member.id) }.map(\.clientName)
                        == ["claude-code"], "every individual note IS shared")
            }

            // GUARD (green on both sides by nature): her R-VX185-1.
            #expect(try icons(db)[gathered.id] == nil, "note grants on every member never icon the gathering")
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: gathered.id) }.isEmpty)
            #expect(try icons(db)[book.id] != nil, "the book its notes share IS iconed — by its own grant")

            // The positive control (red on old): the wing grant is what icons it.
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .wing, ""))
            #expect(try icons(db)[gathered.id]?.first?.throughTitle == "Home")
        }
    }

    // MARK: - The open book icons every unfenced gathering

    @Test func theOpenBookIconsAGatheringForEveryApprovedClient() throws {
        try withOperations { ops, db in
            _ = try approvedClient(ops)
            _ = try approvedClient(ops, "codex")
            _ = try ops.recordMCPContact(name: "pending-one", version: nil)
            let variorum = try ops.createWing(name: "variorum")
            let home = try gathering(ops, "every star")
            let away = try gathering(ops, "parser things", wing: variorum.id)
            #expect(try icons(db).isEmpty)

            try ops.setMCPSwitch(.openBook, on: true)
            for id in [home.id, away.id] {
                let reach = try #require(try icons(db)[id], "the open book reaches every wing's gatherings")
                #expect(reach.map(\.clientName) == ["claude-code", "codex"], "approved clients only")
                #expect(reach.allSatisfy { $0.viaOpenBook && $0.rung == .read && $0.throughTitle == nil })
            }
            try ops.setMCPSwitch(.openBook, on: false)
            #expect(try icons(db).isEmpty)
        }
    }

    // MARK: - Archived: the archived-book rule

    /// The reach map is REACH, not presentation (the wire answers an archived
    /// book by id under its grant — `listBooks`'s "Presentation, never reach");
    /// the Bookcase never draws an archived reading of either kind
    /// (`bookcaseReadings`, the ONE archived choke point). An archived gathering
    /// follows exactly the rule an archived book does.
    @Test func anArchivedGatheringFollowsTheArchivedBookRule() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let book = try ops.createReading(name: "kept book", kind: .book)
            let gathered = try gathering(ops, "kept gathering")
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .wing, ""))
            func onTheBookcase() throws -> Set<String> {
                Set(try db.read { try Queries.bookcase($0, wingID: "") }.books.map(\.reading.id))
            }
            #expect(try icons(db)[book.id] != nil && icons(db)[gathered.id] != nil, "live: both iconed")
            #expect(try onTheBookcase().isSuperset(of: [book.id, gathered.id]))

            try ops.archiveReading(book.id)
            try ops.archiveReading(gathered.id)
            let all = try icons(db)
            #expect((all[gathered.id] != nil) == (all[book.id] != nil), "the archived-book rule, both kinds")
            #expect(all[gathered.id]?.first?.throughTitle == all[book.id]?.first?.throughTitle)
            #expect(try onTheBookcase().isDisjoint(with: [book.id, gathered.id]),
                    "neither is on the Bookcase, so neither row draws")

            _ = try ops.unarchiveReading(book.id)
            _ = try ops.unarchiveReading(gathered.id)
            #expect(try icons(db)[gathered.id] != nil && onTheBookcase().contains(gathered.id))
        }
    }

    // MARK: - The fence holds (decideGathering's own — never relaxed)

    /// No op marks a gathering Private or daily; a stale synced row could. Such
    /// a gathering matches nothing — not a wing grant, not the open book.
    @Test func aFencedGatheringNeverWearsTheIcon() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let plain = try gathering(ops, "plain")
            let marked = try gathering(ops, "marked by sync")
            let daily = try gathering(ops, "a stale daily bearer")
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = ? WHERE id = ?",
                               arguments: ["2026-07-01T00:00:09.000Z", marked.id])
                try db.execute(sql: "UPDATE reading SET profile = ? WHERE id = ?",
                               arguments: [Queries.dailyJournalBookProfile, daily.id])
            }
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .wing, ""))
            try ops.setMCPSwitch(.openBook, on: true)
            let all = try icons(db)
            #expect(all[plain.id] != nil, "the positive control (red on old)")
            #expect(all[marked.id] == nil, "a Private-stamped gathering: the fence (guard)")
            #expect(all[daily.id] == nil, "a 'daily'-marked gathering: the fence (guard)")
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: marked.id) }.isEmpty)
        }
    }

    // MARK: - The ONE decide: the map's gatherings ARE decideGathering's

    /// Under every grant shape the gatherings in the icon map are exactly the
    /// ones `decideGathering` allows for some approved client — and each named
    /// grant is the one it names (never a parallel rule).
    @Test func theMapsGatheringsAreExactlyWhatDecideGatheringAllows() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops)
            let codex = try approvedClient(ops, "codex")
            let variorum = try ops.createWing(name: "variorum")
            let gatherings = [
                try gathering(ops, "home one"),
                try gathering(ops, "home two"),
                try gathering(ops, "away one", wing: variorum.id),
            ]
            let book = try ops.createReading(name: "a book", kind: .book, wingId: variorum.id)
            func agrees() throws {
                let all = try icons(db)
                try db.read { db in
                    let openBook = try Queries.mcpSwitch(db, .openBook)
                    for reading in gatherings {
                        let facts = try #require(try Queries.mcpGatheringFacts(db, readingID: reading.id))
                        var allowed: [String: String?] = [:]
                        for client in try Queries.mcpClients(db, states: [.approved]) {
                            let rows = try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant)
                            if case .allow(let grantID, _) = MCPGrantRule.decideGathering(
                                client: .approved, grants: rows, openBook: openBook, gathering: facts) {
                                allowed[client.name] = grantID
                            }
                        }
                        let shown = all[reading.id] ?? []
                        #expect(Set(shown.map(\.clientName)) == Set(allowed.keys), "\(reading.name)")
                        for reach in shown {
                            #expect(reach.grant?.id == allowed[reach.clientName] ?? nil, "\(reading.name)")
                        }
                    }
                }
            }
            try agrees()
            _ = try ops.grantMCPAccess(claude.id, grant(.edit, .book, book.id))
            try agrees()
            let wing = try ops.grantMCPAccess(codex.id, grant(.suggest, .wing, variorum.id, .once))
            try agrees()
            #expect(try icons(db)[gatherings[2].id]?.first?.grant?.id == wing, "a once wing grant reads too")
            _ = try ops.grantMCPAccess(claude.id, grant(.read, .wing, ""))
            try agrees()
            try ops.setMCPSwitch(.openBook, on: true)
            try agrees()
            try ops.denyMCPClient(codex.id)
            try agrees()
            #expect(try icons(db).keys.contains(gatherings[0].id), "the positive control (red on old)")
        }
    }
}
