//
//  SearchGatheringScopeTests.swift
//  VariorumCoreTests
//
//  13o U3, P6 — THE WITHIN-A-GATHERING SCOPE (P-13o-U1-10, now due), built
//  to the architect's ruling B: `.book(id)` on a GATHERING searches its
//  ASSEMBLED members, the gathering's membership WHERE factored into ONE
//  function (`Queries.gatheringMembership`) that BOTH `assembleReading` and
//  the composer read — "the two can never drift". The pins: the one-function
//  sharing (both statements carry its conditions verbatim, traced), the
//  member-set PARITY across every gathering shape (tag, star, NOT, legacy,
//  hide-owned, archived, rule-less, malformed), the ruled consequences, the
//  worn-day arm, and the page's plan.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func parse(_ text: String, visibility: SearchVisibility = .living) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"))
}

/// Every note a question finds inside one book/gathering (every page).
private func notesFound(
    _ db: AppDatabase, _ text: String, in readingID: String, visibility: SearchVisibility = .living
) throws -> Set<String> {
    try db.read { db in
        var ids: Set<String> = []
        var cursor: SearchComposer.Cursor?
        repeat {
            let page = try Queries.searchPassages(
                db, query: parse(text, visibility: visibility),
                scope: SearchScope(wingID: "", within: .book(id: readingID)), after: cursor, limit: 100)
            ids.formUnion(page.passages.filter { $0.family != .books }.compactMap(\.noteID))
            cursor = page.next
        } while cursor != nil
        return ids
    }
}

private func assembled(_ db: AppDatabase, _ readingID: String) throws -> Set<String> {
    Set(try db.read { db in try Queries.assembleReading(db, readingID: readingID) }.map(\.postID))
}

@Suite("13o U3 — the within-a-gathering scope (ruling B)")
struct SearchGatheringScopeTests {
    /// **THE DRIFT PIN** (the ruling's own ask — "the composer's arm and
    /// assembleReading's arm are the same function"): both executed
    /// statements carry `gatheringMembership`'s conditions VERBATIM.
    @Test func theAssemblyAndTheSearchReadTheOneMembershipFunction() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let gathering = try ops.createReading(
                name: "All dreams", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(dream.id), .not(.star)])))
            let note = try ops.createPost(title: "Night")
            _ = try ops.newBlock(in: note.id, text: "the lantern")
            _ = try ops.applyTag(dream.id, toPost: note.id)

            try db.read { db in
                let reading = try #require(try Queries.reading(db, id: gathering.id))
                let membership = try #require(try Queries.gatheringMembership(db, reading))
                let clause = membership.conditions.joined(separator: " AND ")
                var traced: [String] = []
                db.trace { event in
                    if case .statement(let statement) = event { traced.append(statement.sql) }
                }
                _ = try Queries.assembleReading(db, readingID: gathering.id)
                let assembly = traced
                traced = []
                _ = try Queries.searchPassages(
                    db, query: parse("lantern"), scope: SearchScope(wingID: "", within: .book(id: gathering.id)))
                let search = traced
                db.trace(options: [])
                #expect(assembly.contains { $0.contains("FROM container c") && $0.contains(clause) },
                        "the assembly's gathering arm IS the membership function's WHERE")
                #expect(search.contains { $0.contains("search_fts MATCH") && $0.contains(clause) },
                        "the search's gathering scope IS the same WHERE")
                let environment = try Queries.searchEnvironment(
                    db, scope: SearchScope(wingID: "", within: .book(id: gathering.id)))
                guard case .members(let conditions, let arguments) = environment.gathering else {
                    Issue.record("a live gathering's scope carries its members"); return
                }
                #expect(conditions == membership.conditions && arguments.count == membership.arguments.count,
                        "the environment holds the one function's answer, whole")
            }
        }
    }

    /// **THE PARITY CELLS** — for every gathering shape, the notes its scope
    /// finds for a word every note carries are EXACTLY its assembled members.
    @Test func theScopeFindsExactlyTheAssembledMembersInEveryShape() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let lucid = try ops.createTag(parent: dream.id, name: "lucid")
            let nightmare = try ops.createTag(name: "nightmare")
            var notes: [String: String] = [:]
            func note(_ name: String, tags: [String] = [], profile: Profile? = nil) throws -> String {
                let post = try ops.createPost(title: name, profile: profile)
                _ = try ops.newBlock(in: post.id, text: "the shared lantern word")
                for tag in tags { _ = try ops.applyTag(tag, toPost: post.id) }
                notes[name] = post.id
                return post.id
            }
            _ = try note("plain dream", tags: [dream.id])
            _ = try note("lucid", tags: [lucid.id])
            _ = try note("bad dream", tags: [dream.id, nightmare.id])
            _ = try note("untagged")
            let starred = try note("starred")
            try ops.setStarred(.post(starred), starred: true)
            _ = try note("journaled", profile: .journal)
            let archivedNote = try note("archived dream", tags: [dream.id])
            try ops.archiveContainer(archivedNote)
            // An OWNED book's member, also dream-tagged (hide-owned's cell).
            let owner = try ops.createReading(name: "Owner", kind: .book)
            _ = try ops.setReadingOwned(owner.id, owned: true)
            let ownedNote = try note("owned dream", tags: [dream.id])
            _ = try ops.addPostToReading(ownedNote, to: owner.id)

            let shapes: [(String, RuleTerm)] = [
                ("tag subtree", .tag(dream.id)),
                ("tag and not", .and([.tag(dream.id), .not(.tag(nightmare.id))])),
                ("star", .star),
                ("or", .or([.tag(lucid.id), .star])),
                ("legacy profile", .legacyProfile("journal")),
            ]
            for (label, term) in shapes {
                let gathering = try ops.createReading(
                    name: "G \(label)", kind: .gathering, querySpec: try RuleGrammar.encode(term))
                let members = try assembled(db, gathering.id)
                #expect(!members.isEmpty, "\(label): the cell has members")
                #expect(try notesFound(db, "lantern", in: gathering.id) == members, "\(label): found == assembled")
                #expect(try notesFound(db, "lantern", in: gathering.id, visibility: .includingArchived) == members,
                        "\(label): the archived facet adds nothing inside a gathering (ruled)")
                #expect(!members.contains(archivedNote), "\(label): an archived note is never assembled")
            }

            // Hide-owned composes exactly as the gathering's own pages show.
            let hiding = try ops.createReading(
                name: "G hiding", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(dream.id)))
            try ops.setReadingHideOwned(hiding.id, true)
            let hidden = try assembled(db, hiding.id)
            #expect(!hidden.contains(ownedNote), "control: the gathering hides the owned note")
            #expect(try notesFound(db, "lantern", in: hiding.id) == hidden)
            let showing = try ops.createReading(
                name: "G showing", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(dream.id)))
            #expect(try notesFound(db, "lantern", in: showing.id).contains(ownedNote),
                    "the default SHOWS owned notes — the search follows")
        }
    }

    @Test func anArchivedRulelessOrMalformedGatheringAnswersEmpty() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let post = try ops.createPost(title: "Lantern note")
            _ = try ops.newBlock(in: post.id, text: "lantern prose")
            _ = try ops.applyTag(dream.id, toPost: post.id)
            let spec = try RuleGrammar.encode(.tag(dream.id))
            let archived = try ops.createReading(name: "Lantern archived", kind: .gathering, querySpec: spec)
            try ops.archiveReading(archived.id)
            let ruleless = try ops.createReading(name: "Lantern ruleless", kind: .gathering, querySpec: spec)
            let malformed = try ops.createReading(name: "Lantern malformed", kind: .gathering, querySpec: spec)
            // The Trash-restoree and corrupt-row classes, by direct row write.
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = NULL WHERE id = ?", arguments: [ruleless.id])
                try db.execute(sql: "UPDATE reading SET query_spec = '{nope' WHERE id = ?", arguments: [malformed.id])
            }
            let living = try ops.createReading(name: "Lantern living", kind: .gathering, querySpec: spec)
            #expect(try notesFound(db, "lantern", in: living.id) == [post.id], "control")
            for gathering in [archived, ruleless, malformed] {
                let page = try db.read { db in
                    try Queries.searchPassages(
                        db, query: parse("lantern"), scope: SearchScope(wingID: "", within: .book(id: gathering.id)))
                }
                #expect(page.passages.isEmpty, "\(gathering.name): EMPTY — its own name included")
                #expect(try assembled(db, gathering.id).isEmpty, "\(gathering.name): the assembly agrees")
            }
        }
    }

    @Test func theWornDayArmAndTheCountsHonorTheGathering() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let member = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.newBlock(in: member.id, text: "lantern")
            _ = try ops.applyTag(dream.id, toPost: member.id)
            let outsider = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.newBlock(in: outsider.id, text: "lantern")
            let gathering = try ops.createReading(
                name: "Dreams", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(dream.id)))
            let scope = SearchScope(wingID: "", within: .book(id: gathering.id))
            let page = try db.read { db in
                try Queries.searchPassages(
                    db, query: SearchQueryParser.parse("september 14", locale: Locale(identifier: "en_US")),
                    scope: scope)
            }
            #expect(Set(page.passages.filter { $0.kind == .wornDay }.compactMap(\.noteID)) == [member.id],
                    "the nameless note wearing the day — the member only")
            let counts = try #require(try db.read { db in
                try Queries.searchCounts(db, query: parse("lantern"), scope: scope)
            })
            #expect(counts.living.notes == 1 && counts.living.passages == 1)
        }
    }

    @Test func theGatheringScopeKeepsThePageDrivenByTheIndex() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let gathering = try ops.createReading(
                name: "Dreams", kind: .gathering,
                querySpec: try RuleGrammar.encode(.or([.tag(dream.id), .star])))
            try ops.setReadingHideOwned(gathering.id, true)
            let plan: String = try db.read { db in
                let scope = SearchScope(wingID: "", within: .book(id: gathering.id))
                let environment = try Queries.searchEnvironment(db, scope: scope)
                let statement = try #require(try SearchComposer.passages(
                    parse("harbor lights"), scope: scope, after: nil, limit: 50, environment: environment))
                return try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                                        arguments: Queries.arguments(statement.arguments))
                    .map { $0["detail"] as String }.joined(separator: "\n")
            }
            #expect(plan.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "the FTS index drives:\n\(plan)")
            for alias in ["d", "pl", "c", "b", "r", "container", "post_tag", "pt"] {
                #expect(!plan.split(separator: "\n").contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                        "SCAN \(alias) is a corpus walk:\n\(plan)")
            }
        }
    }
}
