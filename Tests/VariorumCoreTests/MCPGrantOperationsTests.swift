import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U1 P5 — THE GRANTS STORE's operations and the FACTS the rule decides
// on: exact state transitions (first contact is a pending request with no
// access; approve-with-grant is one transaction; deny revokes everything;
// revocation, consumption and the while-connected end are immediate), the
// scope validation at grant time, and the fence's legs derived in one place
// (R-13nb-1's journal predicate; the Private leg reads false until v1_25).

@Suite("13n-b U1 — the grants store's operations and facts")
struct MCPGrantOperationsTests {
    private func count(_ db: AppDatabase, _ sql: String) throws -> Int {
        try db.read { try Int.fetchOne($0, sql: sql) ?? -1 }
    }

    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    // MARK: - First contact

    @Test func firstContactIsAPendingRequestWithNoAccessAndAReturnKeepsItsState() throws {
        try withOperations { ops, db in
            let first = try ops.recordMCPContact(name: "  claude-code ", version: "2.1")
            #expect(first.name == "claude-code")
            #expect(first.state == .pending)
            #expect(first.firstSeenAt == first.lastSeenAt)
            #expect(try db.read { try Queries.mcpGrants($0, clientID: first.id) }.isEmpty)

            let again = try ops.recordMCPContact(name: "claude-code", version: "2.2")
            #expect(again.id == first.id, "the self-declared name IS the identity")
            #expect(again.version == "2.2")
            #expect(again.lastSeenAt > first.lastSeenAt)
            #expect(again.state == .pending)

            try ops.denyMCPClient(first.id)
            #expect(try ops.recordMCPContact(name: "claude-code", version: nil).state == .denied,
                    "a denied client stays denied when it comes back")
            #expect(throws: OperationError.mcpInvalidClientName(name: "   ")) {
                try ops.recordMCPContact(name: "   ", version: nil)
            }
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_client") == 1)
        }
    }

    @Test func theWaitingRoomIsBoundedOldestPendingForgotten() throws {
        try withOperations { ops, db in
            let kept = try approvedClient(ops, "approved-one")
            var names: [String] = []
            for index in 0...Operations.mcpPendingCap {
                let name = "spam-\(index)"
                names.append(name)
                try ops.recordMCPContact(name: name, version: nil)
            }
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_client WHERE state = 'pending'")
                    == Operations.mcpPendingCap)
            #expect(try db.read { try Queries.mcpClient($0, name: names[0]) } == nil,
                    "the oldest pending request is the one forgotten")
            #expect(try db.read { try Queries.mcpClient($0, name: names.last!) } != nil)
            #expect(try db.read { try Queries.mcpClient($0, id: kept.id) }?.state == .approved,
                    "the cap never touches an approved client")
        }
    }

    // MARK: - Approve, grant, deny, revoke

    @Test func approveWithAGrantIsOneActAndAGrantNeedsAnApprovedClient() throws {
        try withOperations { ops, db in
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let spec = Operations.MCPGrantSpec(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always)

            #expect(throws: OperationError.mcpClientNotApproved(id: client.id)) {
                try ops.grantMCPAccess(client.id, spec)
            }
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_grant") == 0, "a refusal writes nothing")

            let grantID = try #require(try ops.approveMCPClient(client.id, granting: spec))
            let after = try #require(try db.read { try Queries.mcpClient($0, id: client.id) })
            #expect(after.state == .approved)
            #expect(after.decidedAt != nil)
            let grants = try db.read { try Queries.mcpGrants($0, clientID: client.id) }
            #expect(grants.map(\.id) == [grantID])
            #expect(grants.first?.rung == .read && grants.first?.scopeKind == .book
                    && grants.first?.scopeID == book.id && grants.first?.duration == .always)
            #expect(try count(db, "SELECT COUNT(*) FROM sync_outbox WHERE table_name LIKE 'mcp_%'") == 0)
        }
    }

    @Test func aGrantsScopeMustBeALiveTargetAndNeverFencedForStanding() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            func spec(_ kind: MCPGrantRule.ScopeKind, _ id: String, _ d: MCPGrantRule.Duration = .always) -> Operations.MCPGrantSpec {
                .init(rung: .read, scopeKind: kind, scopeID: id, duration: d)
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "note", id: "nope")) {
                try ops.grantMCPAccess(client.id, spec(.note, "nope"))
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "book", id: "nope")) {
                try ops.grantMCPAccess(client.id, spec(.book, "nope"))
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "wing", id: "nope")) {
                try ops.grantMCPAccess(client.id, spec(.wing, "nope"))
            }
            _ = try ops.grantMCPAccess(client.id, spec(.wing, ""))  // Home is always live
            let wing = try ops.createWing(name: "Work")
            _ = try ops.grantMCPAccess(client.id, spec(.wing, wing.id))

            // THE daily Journal is never a scope; a journal NOTE never "always".
            // 13n-c U1 (justified edit, the ritual — R-AIR-1): the refused book
            // was a journal-TRAIT book ('journal'); since R-AIR-1 only the
            // 'daily' marker fences a book (the trait's grant is
            // MCPFenceRekeyTests' pin), so the fixture is THE daily Journal.
            let journalBook = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "book", id: journalBook.id)) {
                try ops.grantMCPAccess(client.id, spec(.book, journalBook.id))
            }
            let entry = try ops.createPost(title: "morning pages", profile: .journal)
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "note", id: entry.id)) {
                try ops.grantMCPAccess(client.id, spec(.note, entry.id))
            }
            _ = try ops.grantMCPAccess(client.id, spec(.note, entry.id, .once))
            _ = try ops.grantMCPAccess(client.id, spec(.note, entry.id, .connection))
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 4)
        }
    }

    @Test func denyRevokesEveryGrantAtOnce() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let note = try ops.createPost(title: "ch 7")
            for duration in MCPGrantRule.Duration.allCases {
                _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: duration))
            }
            try ops.denyMCPClient(client.id)
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.state == .denied)
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_grant WHERE revoked_at IS NULL") == 0)
            try ops.denyMCPClient(client.id)  // a no-op, not a refusal
        }
    }

    @Test func revocationIsImmediateThroughTheFacts() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let note = try ops.createPost(title: "ch 7")
            let grantID = try ops.grantMCPAccess(
                client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            func decision() throws -> MCPGrantRule.Decision {
                try db.read { db in
                    let facts = try #require(try Queries.mcpNoteFacts(db, noteID: note.id))
                    return MCPGrantRule.decide(
                        client: try Queries.mcpClient(db, id: client.id)?.state,
                        grants: try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant),
                        openBook: try Queries.mcpSwitch(db, .openBook),
                        target: .note(facts), rung: .read, consumes: true)
                }
            }
            #expect(try decision().isAllowed)
            try ops.revokeMCPGrant(grantID)
            #expect(try decision() == .ask(.notShared, offersAlways: true))
            #expect(throws: OperationError.mcpGrantNotFound(id: "nope")) { try ops.revokeMCPGrant("nope") }
        }
    }

    // MARK: - The server's in-transaction writes

    @Test func aOnceGrantIsConsumedExactlyOnce() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let note = try ops.createPost(title: "ch 7")
            let once = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .once))
            let always = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            try db.write { try ops.consumeMCPOnceGrant($0, once) }
            #expect(try db.read { try Queries.mcpGrant($0, id: once) }?.consumedAt != nil)
            #expect(throws: OperationError.mcpGrantNotFound(id: once)) {
                try db.write { try ops.consumeMCPOnceGrant($0, once) }
            }
            #expect(throws: OperationError.mcpGrantNotFound(id: always)) {
                try db.write { try ops.consumeMCPOnceGrant($0, always) }
            }
            let shared = try db.read { try Queries.mcpSharedRows($0) }
            #expect(shared.map(\.grant.id) == [always], "a spent once grant leaves SHARED WITH AI")
        }
    }

    @Test func whileConnectedEndsWithTheConnectionAndAtEveryServerStart() throws {
        try withOperations { ops, db in
            let a = try approvedClient(ops, "claude-code")
            let b = try approvedClient(ops, "local-llama")
            let note = try ops.createPost(title: "ch 7")
            func grant(_ c: MCPClient, _ d: MCPGrantRule.Duration) throws -> String {
                try ops.grantMCPAccess(c.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: d))
            }
            let aConn = try grant(a, .connection), aAlways = try grant(a, .always)
            let bConn = try grant(b, .connection)
            try ops.endMCPConnectionGrants(clientID: a.id)
            let revoked = Set(try db.read { try String.fetchAll($0, sql: "SELECT id FROM mcp_grant WHERE revoked_at IS NOT NULL") })
            #expect(revoked == [aConn], "only THIS client's while-connected grants end")
            try ops.sweepMCPConnectionGrants()
            let after = Set(try db.read { try String.fetchAll($0, sql: "SELECT id FROM mcp_grant WHERE revoked_at IS NOT NULL") })
            #expect(after == [aConn, bConn])
            #expect(!after.contains(aAlways))
        }
    }

    @Test func theActivityLogIsCoarseAndCapped() throws {
        try withOperations { ops, db in
            for index in 0..<(Operations.mcpActivityCap + 7) {
                try db.write { db in
                    try ops.recordMCPActivity(
                        db, clientName: "claude-code", act: "read_note", targetKind: "note",
                        targetID: "n\(index)", targetTitle: "t\(index)", allowed: index % 2 == 0)
                }
            }
            #expect(try db.read { try Queries.mcpActivityCount($0) } == Operations.mcpActivityCap)
            let newest = try #require(try db.read { try Queries.mcpActivity($0, limit: 1) }.first)
            #expect(newest.targetID == "n\(Operations.mcpActivityCap + 6)")
            let lastIndexWasEven = (Operations.mcpActivityCap + 6) % 2 == 0
            #expect(newest.allowed == lastIndexWasEven)
        }
    }

    @Test func theSwitchesReadOffUntilSetAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            for key in MCPSwitch.allCases {
                #expect(try db.read { try Queries.mcpSwitch($0, key) } == false)
            }
            try ops.setMCPSwitch(.server, on: true)
            #expect(try db.read { try Queries.mcpSwitch($0, .server) })
            #expect(try db.read { try Queries.mcpSwitch($0, .openBook) } == false)
            let stamp = try db.read { try String.fetchOne($0, sql: "SELECT updated_at FROM mcp_switch WHERE key = 'server'") }
            try ops.setMCPSwitch(.server, on: true)
            #expect(try db.read { try String.fetchOne($0, sql: "SELECT updated_at FROM mcp_switch WHERE key = 'server'") } == stamp)
            try ops.setMCPSwitch(.server, on: false)
            #expect(try db.read { try Queries.mcpSwitch($0, .server) } == false)
        }
    }

    // MARK: - THE FACTS (the fence's legs in one place — R-13nb-1)

    @Test func theJournalLegsFenceExactlyAsRuled() throws {
        try withOperations { ops, db in
            let plain = try ops.createPost(title: "plain")
            let ownProfile = try ops.createPost(title: "entry", profile: .journal)
            let traitMember = try ops.createPost(title: "in a notebook")
            let dailyMember = try ops.createPost(title: "in the daily journal")
            let arrivalOnly = try ops.createPost(title: "waiting at the door")
            let archivedJournalMember = try ops.createPost(title: "in an archived daily journal")
            let deletedJournalMember = try ops.createPost(title: "in a deleted daily journal")
            let notebook = try ops.createReading(name: "notebook", kind: .book, profile: "journal")
            let daily = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            // 13n-c U1 (justified edit, the ritual — R-AIR-1): the archived and
            // deleted fixtures were TRAIT books; the trait no longer fences, so
            // they are 'daily' bearers (a second live bearer is the
            // not-yet-converged stale case — it fences too, the conservative
            // direction). The daily Journal can't be deleted by its door
            // (`dailyJournalCannotBeDeleted`), so the deleted bearer is a
            // synced tombstone, written as one.
            let archivedNotebook = try ops.createReading(name: "old journal", kind: .book, profile: "daily")
            let deletedNotebook = try ops.createReading(name: "gone journal", kind: .book, profile: "daily")
            _ = try ops.addPostToReading(traitMember.id, to: notebook.id)
            _ = try ops.addPostToReading(dailyMember.id, to: daily.id)
            _ = try ops.addPostToReading(archivedJournalMember.id, to: archivedNotebook.id)
            _ = try ops.addPostToReading(deletedJournalMember.id, to: deletedNotebook.id)
            try ops.archiveReading(archivedNotebook.id)
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET deleted_at = '2026-07-01T00:59:00.000Z' WHERE id = ?",
                               arguments: [deletedNotebook.id])
            }
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('arrival-1', ?, ?, 'a5', 'arrival', '2026-07-01T00:00:00.000Z')
                    """, arguments: [notebook.id, arrivalOnly.id])
            }
            let facts = try db.read { db in
                try Queries.mcpNoteFacts(db, noteIDs: [plain.id, ownProfile.id, traitMember.id, dailyMember.id,
                                                       arrivalOnly.id, archivedJournalMember.id, deletedJournalMember.id])
            }
            #expect(facts[plain.id]?.fence == nil)
            #expect(facts[ownProfile.id]?.fence == .journal, "leg 1: its own profile")
            // 13n-c U1 (justified edit, the ritual — R-AIR-1): the trait is
            // no longer a fence leg.
            #expect(facts[traitMember.id]?.fence == nil, "R-AIR-1: a journal-trait book's member is not fenced")
            #expect(facts[dailyMember.id]?.fence == .journal, "leg 2: a member of THE daily Journal")
            #expect(facts[archivedJournalMember.id]?.fence == .journal, "an archived book is still alive")
            #expect(facts[arrivalOnly.id]?.fence == nil, "an arrival is never membership")
            #expect(facts[deletedJournalMember.id]?.fence == nil, "a deleted book is not alive")
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: notebook.id) }?.fence == nil,
                    "R-AIR-1 (justified edit, the ritual): the trait book is a book like any other")
            #expect(try db.read { try Queries.mcpBookFacts($0, readingID: daily.id) }?.fence == .journal)
            // U2 (justified edit): the Private leg is WIRED over v1_25 — the
            // U1 placeholder assertion ("reads 0") retired; its pins are
            // MCPPrivateMarkTests'.
            #expect(MCPGrantRule.fence(journal: true, privateMark: true) == .privateMark, "privacy wins ties")
        }
    }

    @Test func onlyLiveNonVersionPostsHaveFactsAndWingsResolveLikeEverySurface() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Work")
            let home = try ops.createPost(title: "home note")
            let inWing = try ops.createPost(title: "work note", wingId: wing.id)
            let dangling = try ops.createPost(title: "orphan")
            let version = try ops.createPost(title: "a version")
            let deleted = try ops.createPost(title: "deleted")
            let pool = try ops.createPool(title: "scraps")
            let liveBook = try ops.createReading(name: "live", kind: .book)
            let deadBook = try ops.createReading(name: "dead", kind: .book)
            _ = try ops.addPostToReading(home.id, to: liveBook.id)
            _ = try ops.addPostToReading(home.id, to: deadBook.id)
            try ops.deleteReading(deadBook.id)
            try ops.deleteContainer(deleted.id)
            try db.write { db in
                try db.execute(sql: "UPDATE container SET wing_id = 'gone-wing' WHERE id = ?", arguments: [dangling.id])
                try db.execute(sql: "UPDATE container SET archived_at = created_at WHERE id = ?", arguments: [version.id])
            }
            let facts = try db.read { db in
                try Queries.mcpNoteFacts(db, noteIDs: [home.id, inWing.id, dangling.id, version.id, deleted.id, pool.id, "nope"])
            }
            #expect(Set(facts.keys) == [home.id, inWing.id, dangling.id],
                    "a version, a tombstone, a scraps group and a stranger have no facts — one answer for all")
            #expect(facts[home.id]?.wingID == "")
            #expect(facts[inWing.id]?.wingID == wing.id)
            #expect(facts[dangling.id]?.wingID == "", "a dangling wing pointer reads as Home")
            #expect(facts[home.id]?.bookIDs == [liveBook.id], "live books only")
        }
    }

    @Test func aNoteMovedOutOfTheGrantedBookIsRefusedTodayEndToEnd() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let book = try ops.createReading(name: "ch", kind: .book)
            let note = try ops.createPost(title: "ch 7")
            _ = try ops.addPostToReading(note.id, to: book.id)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            func allowed() throws -> Bool {
                try db.read { db in
                    guard let facts = try Queries.mcpNoteFacts(db, noteID: note.id) else { return false }
                    return MCPGrantRule.decide(
                        client: .approved, grants: try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant),
                        openBook: false, target: .note(facts), rung: .read, consumes: false).isAllowed
                }
            }
            #expect(try allowed())
            _ = try ops.removePostFromReading(note.id, from: book.id)
            #expect(try allowed() == false, "a stale pointer refuses today")
        }
    }

    @Test func theGrantSheetOffersExactlyTheBooksAGrantMayName() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Work")
            let plain = try ops.createReading(name: "B plain", kind: .book)
            let inWing = try ops.createReading(name: "a in wing", kind: .book, wingId: wing.id)
            // 13n-c U1 (justified edit, the ritual — R-AIR-1): the trait book
            // is OFFERED now; THE daily Journal still is not.
            let notebook = try ops.createReading(name: "notebook", kind: .book, profile: "journal")
            _ = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            let dead = try ops.createReading(name: "dead", kind: .book)
            try ops.deleteReading(dead.id)
            let offered = try db.read { try Queries.mcpGrantableBooks($0) }
            #expect(offered.map(\.id) == [inWing.id, plain.id, notebook.id], "live, unfenced books by name")
            #expect(offered.first?.wingID == wing.id)
            // Every offered book is one the op accepts.
            let client = try approvedClient(ops)
            for book in offered {
                _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            }
        }
    }

    @Test func theSharedListNamesEachTargetAndLeavesTheDeadOut() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let note = try ops.createPost(title: "morning pages — oct 9")
            let wing = try ops.createWing(name: "Work")
            let g1 = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .connection))
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: wing.id, duration: .always))
            try ops.revokeMCPGrant(g1)
            let rows = try db.read { try Queries.mcpSharedRows($0) }
            #expect(rows.count == 3)
            #expect(Set(rows.compactMap(\.targetTitle)) == ["morning pages — oct 9", "Home", "Work"])
            #expect(rows.allSatisfy { $0.clientName == "claude-code" })
            #expect(try db.read { try Queries.mcpSharedCount($0) } == 3)
            #expect(try db.read { try Queries.mcpSharedRows($0, limit: 2) }.count == 2)
        }
    }
}
