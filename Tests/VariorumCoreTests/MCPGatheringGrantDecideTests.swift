import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-549 (VX-548 batch 3) — A GATHERING AS A GRANT PLACE: the decide layer.
// Her sitting (2026-10-27, RATIFIED): "Gathering joins the grant scopes; reach
// is resolved by assembling the rule at read time. Reach moving with her
// tagging is confirmed as the feature, her words: 'this is the feature, routing
// work to an agent by each tag.' The Private fence wins every tie … and the
// fence is the MARK, never a tag that happens to be named 'private'."
//
// The pins drive the REAL facts derivation (`Queries.mcpNoteFacts` — the ONE
// membership function, `gatheringMembership`) and the ONE rule (`decide`,
// `decideGathering`), through the ONE grant op (`grantMCPAccess`). Red on the
// old tree by construction: a gathering grant could not be minted (the op had
// no gathering scope; v1_24's CHECK refused the row), and no note's facts named
// a gathering.

@Suite("VX-549 — a gathering grant reaches exactly the notes its rule assembles now")
struct MCPGatheringGrantDecideTests {
    private typealias Rule = MCPGrantRule

    private func approved(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String, wing: String = "", tags: [VariorumCore.Tag] = []) throws -> Container {
        let post = try ops.createPost(title: title, wingId: wing)
        _ = try ops.newBlock(in: post.id, text: "\(title) text", registeringUndo: false)
        for tag in tags { _ = try ops.applyTag(tag.id, toPost: post.id) }
        return post
    }

    private func spec(
        _ rung: Rule.Rung, _ kind: Rule.ScopeKind, _ id: String, _ duration: Rule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// The client's live grants and the note's CURRENT facts, decided at `rung`.
    private func decide(
        _ db: AppDatabase, _ client: MCPClient, note: String, _ rung: Rule.Rung = .read
    ) throws -> Rule.Decision {
        try db.read { db in
            let grants = try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant)
            guard let facts = try Queries.mcpNoteFacts(db, noteID: note) else {
                return .ask(.notShared, offersAlways: true)
            }
            return Rule.decide(
                client: .approved, grants: grants, openBook: try Queries.mcpSwitch(db, .openBook),
                target: .note(facts), rung: rung, consumes: false)
        }
    }

    private func members(_ db: AppDatabase, _ gatheringID: String) throws -> Set<String> {
        try db.read { Set(try Queries.assembleReading($0, readingID: gatheringID).map(\.postID)) }
    }

    // MARK: - Reach = the assembly, now; it moves with her tagging

    @Test func aGatheringGrantReachesItsAssemblyAndMovesWithHerTagging() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let parser = try ops.createTag(name: "parser")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let lexer = try note(ops, "lexer", tags: [parser])
            let essay = try note(ops, "essay")
            let grantID = try ops.grantMCPAccess(client.id, spec(.suggest, .gathering, gathering.id))

            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: lexer.id) }?.gatheringIDs == [gathering.id])
            #expect(try decide(db, client, note: lexer.id) == .allow(grantID: grantID, consumesOnce: false))
            #expect(try decide(db, client, note: lexer.id, .suggest) == .allow(grantID: grantID, consumesOnce: false))
            #expect(try decide(db, client, note: lexer.id, .writeNew) == .ask(.rungTooLow(granted: .suggest), offersAlways: true),
                    "a member past the grant's rung hears the rung — its grant is its knowledge")
            #expect(try decide(db, client, note: essay.id) == .ask(.notShared, offersAlways: true),
                    "a note the rule does not assemble is not reached")

            // Her tagging moves the reach — no share act (her ruled feature).
            _ = try ops.applyTag(parser.id, toPost: essay.id)
            #expect(try decide(db, client, note: essay.id).isAllowed, "tagged in → reached")
            try ops.removeTag(parser.id, fromPost: lexer.id)
            #expect(try decide(db, client, note: lexer.id) == .ask(.notShared, offersAlways: true),
                    "untagged out → not reached")

            // A note archived leaves the assembly (the ONE membership function's
            // own clause) and so the reach.
            try ops.archiveContainer(essay.id)
            #expect(!(try decide(db, client, note: essay.id).isAllowed))
        }
    }

    /// The facts name a gathering for a note EXACTLY when the gathering's own
    /// assembly shows it — the ONE membership function, never a parallel
    /// evaluation — across the shapes that differ: a subtree tag, another
    /// wing's same-path twin, a starred note under a ★ rule, an owned note
    /// under hide-owned.
    @Test func theFactsAgreeWithTheAssemblyNoteForNote() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let away = try ops.createWing(name: "away")
            let ideas = try ops.createTag(name: "ideas")
            let child = try ops.createTag(parent: ideas.id, name: "child")
            let twin = try ops.createTag(name: "ideas", wingID: away.id)
            let byTag = try ops.createReading(
                name: "ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(ideas.id)))
            let byStar = try ops.createReading(
                name: "starred ideas", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(ideas.id), .star])))
            let plain = try note(ops, "plain idea", tags: [ideas])
            let nested = try note(ops, "nested idea", tags: [child])
            let crossed = try note(ops, "away idea", wing: away.id, tags: [twin])
            let starred = try note(ops, "starred idea", tags: [ideas])
            try ops.setStarred(.post(starred.id), starred: true)
            let untagged = try note(ops, "nothing")
            // An owned note under a gathering that hides owned notes.
            let owner = try ops.createReading(name: "owner", kind: .book)
            let owned = try note(ops, "owned idea", tags: [ideas])
            _ = try ops.addPostToReading(owned.id, to: owner.id)
            _ = try ops.setReadingOwned(owner.id, owned: true)
            try ops.setReadingHideOwned(byTag.id, true)
            for gathering in [byTag, byStar] {
                _ = try ops.grantMCPAccess(client.id, spec(.read, .gathering, gathering.id))
            }

            let ids = [plain, nested, crossed, starred, untagged, owned].map(\.id)
            let facts = try db.read { try Queries.mcpNoteFacts($0, noteIDs: ids) }
            for gathering in [byTag, byStar] {
                let assembled = try members(db, gathering.id)
                for id in ids {
                    #expect((facts[id]?.gatheringIDs.contains(gathering.id) ?? false) == assembled.contains(id),
                            "\(gathering.name) × \(id)")
                }
            }
            #expect(try members(db, byTag.id) == [plain.id, nested.id, starred.id], "the subtree, never the twin or the owned")
            #expect(try members(db, byStar.id) == [starred.id])
        }
    }

    // MARK: - Every fence key wins (the one answer)

    @Test func everyFenceKeyWinsAndTheFenceIsTheMarkNeverATagNamedPrivate() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let privateTag = try ops.createTag(name: "private")
            let gathering = try ops.createReading(
                name: "the private tag", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(privateTag.id)))
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .gathering, gathering.id))

            // A note TAGGED "private" is an ordinary member — the fence is the MARK.
            let tagged = try note(ops, "tagged private", tags: [privateTag])
            #expect(try decide(db, client, note: tagged.id, .edit).isAllowed, "a tag named private is just a tag")

            // The Private MARK, its own.
            let marked = try note(ops, "marked", tags: [privateTag])
            _ = try ops.setNotePrivate(marked.id, true)
            #expect(try members(db, gathering.id).contains(marked.id), "it matches the rule…")
            #expect(try decide(db, client, note: marked.id) == .ask(.fenced(.privateMark), offersAlways: false),
                    "…and the fence wins: the one answer")

            // The Private mark through a live Private book.
            let privateBook = try ops.createReading(name: "diary", kind: .book)
            let inPrivateBook = try note(ops, "in a private book", tags: [privateTag])
            _ = try ops.addPostToReading(inPrivateBook.id, to: privateBook.id)
            _ = try ops.setBookPrivate(privateBook.id, true)
            #expect(try decide(db, client, note: inPrivateBook.id) == .ask(.fenced(.privateMark), offersAlways: false))

            // A ⌘J entry (its own journal profile), tagged in.
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            _ = try ops.applyTag(privateTag.id, toPost: entry.id)
            #expect(try members(db, gathering.id).contains(entry.id))
            #expect(try decide(db, client, note: entry.id) == .ask(.fenced(.journal), offersAlways: false))

            // A member of THE daily Journal, tagged in.
            let daily = try note(ops, "a day", tags: [privateTag])
            _ = ops.shelveInDailyJournalBook(daily.id)
            #expect(try decide(db, client, note: daily.id) == .ask(.fenced(.journal), offersAlways: false))
        }
    }

    // MARK: - An archived, rule-less, malformed or dead gathering reaches nothing

    @Test func aGatheringThatAssemblesEmptyReachesNothingAndADeadOneToo() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let parser = try ops.createTag(name: "parser")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let member = try note(ops, "lexer", tags: [parser])
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .gathering, gathering.id))
            #expect(try decide(db, client, note: member.id).isAllowed)

            try ops.archiveReading(gathering.id)
            #expect(try decide(db, client, note: member.id) == .ask(.notShared, offersAlways: true),
                    "archived: it assembles empty everywhere, so its grant reaches nothing")
            _ = try ops.unarchiveReading(gathering.id)
            #expect(try decide(db, client, note: member.id).isAllowed, "unarchived: reached again")

            // A rule-less gathering (a Trash restoree's state) and a malformed
            // one assemble empty — written as a synced row would land.
            for spec in [nil, "{not a rule"] as [String?] {
                try db.write { db in
                    try db.execute(sql: "UPDATE reading SET query_spec = ? WHERE id = ?", arguments: [spec, gathering.id])
                }
                #expect(try decide(db, client, note: member.id) == .ask(.notShared, offersAlways: true),
                        "\(String(describing: spec)): nothing assembled, nothing reached")
            }
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                               arguments: [try RuleGrammar.encode(.tag(parser.id)), gathering.id])
            }
            #expect(try decide(db, client, note: member.id).isAllowed)

            // A FENCED gathering (a stale Private stamp — no op mints one) reaches nothing.
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                               arguments: [gathering.id])
            }
            #expect(try decide(db, client, note: member.id) == .ask(.notShared, offersAlways: true))
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = NULL WHERE id = ?", arguments: [gathering.id])
            }

            // Bound into a book: no gathering any more — its grant reaches
            // nothing (a gathering grant never reaches a book) and its place
            // reads gone; the un-bind brings it back.
            _ = try ops.convertSmartReadingToCurated(gathering.id)
            #expect(try decide(db, client, note: member.id) == .ask(.notShared, offersAlways: true))
            #expect(try db.read { try Queries.mcpScopeTitle($0, kind: .gathering, id: gathering.id) } == nil)
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET kind = 'gathering' WHERE id = ?", arguments: [gathering.id])
                try db.execute(sql: "UPDATE reading_post SET deleted_at = '2026-07-02T00:00:00.000Z' WHERE reading_id = ?",
                               arguments: [gathering.id])
            }
            #expect(try decide(db, client, note: member.id).isAllowed)

            // Dead: deleted, its grant reaches nothing (a dead place, as every one).
            try ops.deleteReading(gathering.id)
            #expect(try decide(db, client, note: member.id) == .ask(.notShared, offersAlways: true))
        }
    }

    // MARK: - The op: a gathering is a grant place; one standing row per place

    @Test func theGrantOpNamesAGatheringAndRefusesWhatIsNotOne() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let parser = try ops.createTag(name: "parser")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let book = try ops.createReading(name: "a book", kind: .book)

            let first = try ops.grantMCPAccess(client.id, spec(.read, .gathering, gathering.id))
            let once = try ops.grantMCPAccess(client.id, spec(.edit, .gathering, gathering.id, .once))
            // VX-393 holds a gathering as one place: a standing grant replaces its row.
            let second = try ops.grantMCPAccess(client.id, spec(.suggest, .gathering, gathering.id, .connection))
            let live = try db.read { try Queries.mcpGrants($0, clientID: client.id) }
            #expect(Set(live.map(\.id)) == [once, second], "the first standing row replaced, the once beside it kept")
            #expect(try db.read { try Queries.mcpGrant($0, id: first) }?.revokedAt != nil)
            #expect(try db.read { try Queries.mcpScopeTitle($0, kind: .gathering, id: gathering.id) } == "parser things")

            // A book's id is no gathering, a gathering's id no book; a dead one is gone.
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "gathering", id: book.id)) {
                try ops.grantMCPAccess(client.id, spec(.read, .gathering, book.id))
            }
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "book", id: gathering.id)) {
                try ops.grantMCPAccess(client.id, spec(.read, .book, gathering.id))
            }
            let dead = try ops.createReading(
                name: "gone", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            try ops.deleteReading(dead.id)
            #expect(throws: OperationError.mcpGrantScopeNotFound(kind: "gathering", id: dead.id)) {
                try ops.grantMCPAccess(client.id, spec(.read, .gathering, dead.id))
            }
            // A fenced one (a stale Private stamp) refuses as a fenced book does.
            let stale = try ops.createReading(
                name: "stale", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                               arguments: [stale.id])
            }
            #expect(throws: OperationError.mcpGrantScopeFenced(kind: "gathering", id: stale.id)) {
                try ops.grantMCPAccess(client.id, spec(.read, .gathering, stale.id))
            }
            let inert = try ops.grantMCPAccess(client.id, spec(.read, .gathering, gathering.id, .once))
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                               arguments: [gathering.id])
            }
            let inertRow = try #require(try db.read { try Queries.mcpGrant($0, id: inert) })
            #expect(try db.read { try Queries.mcpGrantInertFence($0, inertRow) } == .privateMark,
                    "a grant on a gathering fenced since says it reaches nothing")
        }
    }

    // MARK: - The place: its own grant or its wing's, at the grant's rung

    @Test func thePlaceIsReachedByItsOwnGrantOrItsWingsAtTheRungNeverANoteOrBookGrant() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let wing = try ops.createWing(name: "variorum")
            let parser = try ops.createTag(name: "parser", wingID: wing.id)
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)),
                wingId: wing.id)
            let member = try note(ops, "lexer", wing: wing.id, tags: [parser])
            let book = try ops.createReading(name: "a book", kind: .book, wingId: wing.id)
            _ = try ops.addPostToReading(member.id, to: book.id)
            func place(_ rung: Rule.Rung, consumes: Bool = false) throws -> Rule.Decision {
                try db.read { db in
                    let facts = try #require(try Queries.mcpGatheringFacts(db, readingID: gathering.id))
                    return Rule.decideGathering(
                        client: .approved, grants: try Queries.mcpGrants(db, clientID: client.id).map(\.ruleGrant),
                        openBook: false, gathering: facts, rung: rung, consumes: consumes)
                }
            }
            // R-VX185-1 stands: a note grant and a book grant (even at edit) never reach it.
            let noteGrant = try ops.grantMCPAccess(client.id, spec(.edit, .note, member.id))
            let bookGrant = try ops.grantMCPAccess(client.id, spec(.edit, .book, book.id))
            #expect(try place(.read) == .ask(.notShared, offersAlways: true))
            try ops.revokeMCPGrants([noteGrant, bookGrant])

            // Its own grant, at its rung; a once write grant spends on a write.
            let own = try ops.grantMCPAccess(client.id, spec(.writeNew, .gathering, gathering.id, .once))
            #expect(try place(.read) == .allow(grantID: own, consumesOnce: false), "a read rides free under a once write grant")
            #expect(try place(.writeNew, consumes: true) == .allow(grantID: own, consumesOnce: true))
            #expect(try place(.edit) == .ask(.rungTooLow(granted: .writeNew), offersAlways: true))
            // The wing's grant, at its rung (a place in the wing, as a book is).
            let wingGrant = try ops.grantMCPAccess(client.id, spec(.edit, .wing, wing.id))
            #expect(try place(.edit) == .allow(grantID: wingGrant, consumesOnce: false))
            #expect(try place(.writeNew, consumes: true) == .allow(grantID: wingGrant, consumesOnce: false),
                    "a standing grant covers it before a once grant is spent")
        }
    }

    // MARK: - The faces' reads: the sheet's offer, the shared icon, the member rows

    /// The grant sheet's WHERE offers every live, unfenced gathering — a stale
    /// Private one never (the op refuses it) — each saying whether its rule
    /// needs a star (read/suggest-shaped, her ruling) and whether it is archived.
    @Test func theSheetsOfferIsEveryUnfencedGatheringWithItsStarShape() throws {
        try withOperations { ops, db in
            let parser = try ops.createTag(name: "parser")
            let byTag = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let byStar = try ops.createReading(
                name: "starred parser", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(parser.id), .star])))
            let shelved = try ops.createReading(
                name: "archived parser", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            try ops.archiveReading(shelved.id)
            let stale = try ops.createReading(
                name: "stale", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                               arguments: [stale.id])
            }
            _ = try ops.createReading(name: "a book", kind: .book)
            let offered = try db.read { try Queries.mcpGrantPlaces($0).gatherings }
            #expect(Set(offered.map(\.id)) == [byTag.id, byStar.id, shelved.id], "never the fenced one, never a book")
            #expect(offered.first { $0.id == byStar.id }?.needsStar == true)
            #expect(offered.first { $0.id == byTag.id }?.needsStar == false)
            #expect(offered.first { $0.id == shelved.id }?.archived == true)
        }
    }

    /// The shared icon on a DIRECTLY granted gathering (through the grown
    /// `decideGathering` — `mcpBookReaches`, the Bookcase's and the Library's
    /// one read): its own grant, at its rung, no "through"; its MEMBER notes'
    /// rows wear the mark through the one `decide` (`mcpNoteReaches`) and name
    /// the gathering as the why; a note outside the rule wears none.
    @Test func aGrantedGatheringAndItsMembersWearTheMarkThroughTheOneRule() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let parser = try ops.createTag(name: "parser")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let member = try note(ops, "lexer", tags: [parser])
            let outside = try note(ops, "essay")
            #expect(try db.read { try Queries.mcpBookReaches($0) }.isEmpty, "nothing granted, nothing marked")
            let grant = try ops.grantMCPAccess(client.id, spec(.suggest, .gathering, gathering.id))
            let icons = try db.read { try Queries.mcpBookReaches($0) }
            let onGathering = try #require(icons[gathering.id])
            #expect(onGathering.map(\.clientName) == ["claude-code"] && onGathering[0].rung == .suggest)
            #expect(onGathering[0].grant?.id == grant && onGathering[0].throughTitle == nil, "its own grant")
            #expect(try db.read { try Queries.mcpBookReach($0, readingID: gathering.id) } == onGathering)
            let rows = try db.read { try Queries.mcpNoteReaches($0, noteIDs: [member.id, outside.id]) }
            #expect(rows[member.id]?.first?.throughTitle == "parser things", "the why names the gathering")
            #expect(rows[member.id]?.first?.rung == .suggest)
            #expect(rows[outside.id] == nil)
        }
    }

    // MARK: - P1: the page drives; nothing is assembled while no gathering is granted

    @Test func theMembershipReadIsPageDrivenAndAbsentWithNoGatheringGrant() throws {
        try withOperations { ops, db in
            let client = try approved(ops)
            let parser = try ops.createTag(name: "parser")
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)))
            let member = try note(ops, "lexer", tags: [parser])
            for index in 0..<30 { _ = try note(ops, "other \(index)", tags: index.isMultiple(of: 2) ? [parser] : []) }

            // No gathering granted: the facts read never touches a reading's rule.
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .wing, ""))
            let quiet = try db.read { database -> [String] in
                let captured = LockIsolated<[String]>([])
                database.trace(options: .statement) { event in
                    guard case .statement(let statement) = event else { return }
                    let sql = statement.expandedSQL
                    captured.withValue { $0.append(sql) }
                }
                _ = try Queries.mcpNoteFacts(database, noteIDs: [member.id])
                database.trace(options: [])
                return captured.value
            }
            #expect(!quiet.contains { $0.contains("query_spec") || $0.contains("FROM \"reading\"") },
                    "no gathering is read: \(quiet)")
            #expect(quiet.filter { $0.contains("scope_kind = 'gathering'") }.count == 1, "one grants read")

            // Granted: the membership statement is driven by the page, each
            // note a primary-key seek — never a scan of the corpus.
            _ = try ops.grantMCPAccess(client.id, spec(.read, .gathering, gathering.id))
            let plan = try db.read { database -> String in
                let reading = try #require(try Reading.fetchOne(database, key: gathering.id))
                let membership = try #require(try Queries.gatheringMembership(database, reading))
                let json = String(decoding: try JSONEncoder().encode([member.id]), as: UTF8.self)
                return try Row.fetchAll(
                    database, sql: "EXPLAIN QUERY PLAN " + Queries.mcpGatheringMembersSQL(membership.conditions),
                    arguments: StatementArguments([json] + membership.arguments)
                ).map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
            }
            #expect(plan.hasPrefix("SCAN j VIRTUAL TABLE"), "the page drives:\n\(plan)")
            #expect(plan.contains("SEARCH c USING INDEX sqlite_autoindex_container_1"), "a PK seek:\n\(plan)")
            #expect(try db.read { try Queries.mcpNoteFacts($0, noteID: member.id) }?.gatheringIDs == [gathering.id])
        }
    }
}
