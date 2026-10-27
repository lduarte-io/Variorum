import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-549 (VX-548 batch 3) — A GATHERING AS A GRANT PLACE, on the wire. Her
// sitting (2026-10-27, RATIFIED): "Gathering joins the grant scopes; reach is
// resolved by assembling the rule at read time … The Private fence wins every
// tie … Rungs: read/suggest behave normally over members; write_new mints the
// note bookless in the wing and applies the rule's tags so it assembles in …
// edit applies to member notes. Starring is not on the wire … so write_new on a
// rule tagging can't satisfy (star terms) refuses honestly."
//
// Every pin drives a real client over the socket. Red on the old tree by
// construction: no grant could name a gathering (v1_24's CHECK and the op's
// three scope kinds), so every client here held nothing it could use.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-549 — a gathering as a grant place, on the wire", .serialized)
struct MCPGatheringGrantServerTests {
    /// The wing "variorum": a gathering of #parser notes (two plain members, a
    /// PRIVATE-marked member, a note TAGGED "private" too), a note outside the
    /// rule, and a book of #parser notes that collects by the tag (living).
    private struct World {
        let wing: Wing
        let parser: VariorumCore.Tag
        let gathering: Reading
        let living: Reading
        let members: [Container]
        let marked: Container
        let outside: Container
    }

    private func world(
        _ h: ServerHarness, rule: (VariorumCore.Tag, Operations) throws -> RuleTerm = { tag, _ in .tag(tag.id) }
    ) throws -> World {
        let ops = h.operations
        let wing = try ops.createWing(name: "variorum")
        let parser = try ops.createTag(name: "parser", wingID: wing.id)
        let gathering = try ops.createReading(
            name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(try rule(parser, ops)),
            wingId: wing.id)
        let living = try ops.createReading(
            name: "parser book", kind: .book, querySpec: try RuleGrammar.encode(.tag(parser.id)), wingId: wing.id)
        var members: [Container] = []
        for (title, words) in [("lexer", "the lexer reads quillwort"), ("grammar", "the grammar of quillwort")] {
            let note = try ops.createPost(title: title, wingId: wing.id)
            _ = try ops.newBlock(in: note.id, text: words, registeringUndo: false)
            try ops.applyTag(parser.id, toPost: note.id)
            members.append(note)
        }
        let marked = try ops.createPost(title: "private parser", wingId: wing.id)
        _ = try ops.newBlock(in: marked.id, text: "quillwort marshlantern", registeringUndo: false)
        try ops.applyTag(parser.id, toPost: marked.id)
        _ = try ops.setNotePrivate(marked.id, true)
        let outside = try ops.createPost(title: "an essay", wingId: wing.id)
        _ = try ops.newBlock(in: outside.id, text: "quillwort elsewhere", registeringUndo: false)
        return World(wing: wing, parser: parser, gathering: gathering, living: living, members: members,
                     marked: marked, outside: outside)
    }

    // Sync reads (the async overloads would win inside the test bodies).
    private func assembled(_ h: ServerHarness, _ gathering: String) throws -> Set<String> {
        try h.database.read { Set(try Queries.assembleReading($0, readingID: gathering).map(\.postID)) }
    }

    private func members(_ h: ServerHarness, ofBook book: String) throws -> [String] {
        try h.database.read { db in
            try String.fetchAll(db, sql: """
                SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                """, arguments: [book])
        }
    }

    private func row(_ h: ServerHarness, _ sql: String, _ arguments: StatementArguments) throws -> Row? {
        try h.database.read { try Row.fetchOne($0, sql: sql, arguments: arguments) }
    }

    private func containerCount(_ h: ServerHarness) throws -> Int? {
        try h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") }
    }

    private func consumedAt(_ h: ServerHarness, _ grant: String) throws -> String? {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
        }
    }

    private func noteIDs(_ result: (content: [Tool.Content], isError: Bool?)) throws -> Set<String> {
        Set(try #require(try json(result)["notes"] as? [[String: Any]]).compactMap { $0["id"] as? String })
    }

    // MARK: - Read and suggest over the members — its assembly, now

    @Test func aGatheringGrantReadsListsAndSearchesItsAssemblyAndNothingElse() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .gathering, w.gathering.id))

            // The catalog lists the read tools a gathering can act under.
            let tools = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(tools.isSuperset(of: ["list_books", "list_notes", "read_note", "search", "export_note"]))
            #expect(!tools.contains("create_note"), "read only — no write tool")
            #expect(!tools.contains("list_wings"), "a gathering grant grants no wing")

            // list_books: the gathering alone, its notes counted through the fence.
            let books = try #require(try json(try await call(connection, "list_books", [:]))["books"] as? [[String: Any]])
            #expect(books.map { $0["id"] as? String } == [w.gathering.id], "the gathering, never the book beside it")
            #expect(books.first?["kind"] as? String == "gathering" && books.first?["notes"] as? Int == 2,
                    "two members — the Private one never counts")

            // list_wings: hidden = missing — a gathering grant names no wing.
            let wings = try #require(try json(try await call(connection, "list_wings", [:]))["wings"] as? [Any])
            #expect(wings.isEmpty)
            let wingList = try await call(connection, "list_notes", ["wing_id": .string(w.wing.id)])
            #expect(wingList.isError == true && text(wingList) == MCPRefusalCopy.words(.notShared, .wing))

            // list_notes by its id, and every shared note: its assembly, fenced per note.
            let listed = try await call(connection, "list_notes", ["book_id": .string(w.gathering.id)])
            #expect(try noteIDs(listed) == Set(w.members.map(\.id)))
            #expect(try noteIDs(try await call(connection, "list_notes", [:])) == Set(w.members.map(\.id)))

            // read_note: a member reads; a non-member, the Private member and a
            // missing id answer the ONE not-shared shape, byte for byte.
            #expect(try await call(connection, "read_note", ["note_id": .string(w.members[0].id)]).isError != true)
            let missing = try await call(connection, "read_note", ["note_id": .string("no-such-note")])
            let outside = try await call(connection, "read_note", ["note_id": .string(w.outside.id)])
            let marked = try await call(connection, "read_note", ["note_id": .string(w.marked.id)])
            #expect(missing.isError == true && text(missing) == MCPRefusalCopy.words(.notShared, .note))
            #expect(text(outside) == text(missing) && text(marked) == text(missing),
                    "outside the rule, and the Private MARK, answer exactly as a missing id")

            // search: the members' words only — standing reach (an always grant).
            for arguments: [String: Value] in [["query": .string("quillwort")],
                                               ["query": .string("quillwort"), "book_id": .string(w.gathering.id)]] {
                let found = try json(try await call(connection, "search", arguments))
                let notes = Set((found["passages"] as? [[String: Any]] ?? []).compactMap { $0["note_id"] as? String })
                #expect(notes == Set(w.members.map(\.id)), "\(arguments): never the essay, never the Private member")
            }

            // Her tagging moves the reach — no share act.
            try h.operations.applyTag(w.parser.id, toPost: w.outside.id)
            #expect(try await call(connection, "read_note", ["note_id": .string(w.outside.id)]).isError != true,
                    "tagged in: readable at once")
            try h.operations.removeTag(w.parser.id, fromPost: w.members[0].id)
            let untagged = try await call(connection, "read_note", ["note_id": .string(w.members[0].id)])
            #expect(text(untagged) == text(missing), "untagged out: gone from reach, the one answer")
            await h.hangUp(connection)
        }
    }

    @Test func suggestActsOnAMemberAndANoteOutsideTheRuleAnswersAsMissing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .gathering, w.gathering.id))
            let memberBlock = try #require(try row(
                h, "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                [w.members[0].id]))["block_id"] as String
            let outsideBlock = try #require(try row(
                h, "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                [w.outside.id]))["block_id"] as String
            let take = try await call(connection, "add_take", ["block_id": .string(memberBlock), "text": .string("a take")])
            #expect(take.isError != true, "\(text(take))")
            let refused = try await call(connection, "add_take", ["block_id": .string(outsideBlock), "text": .string("x")])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.notShared, .note))
            let past = try await call(connection, "edit_take", [
                "take_id": .string(try #require(try json(take)["take_id"] as? String)), "text": .string("y"),
                "expected_text": .string("a take"),
            ])
            #expect(past.isError == true && text(past).hasPrefix(MCPRefusalCopy.words(.rungTooLow(granted: .suggest), .note)),
                    "past its rung on a member: the rung, never the not-shared shape")
            await h.hangUp(connection)
        }
    }

    // MARK: - Edit applies to member notes through the existing guards

    @Test func editAppliesToMemberNotesThroughTheExistingGuardsAndStopsWhenTheNoteLeaves() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .gathering, w.gathering.id))
            let renamed = try await call(connection, "rename_note",
                                         ["note_id": .string(w.members[1].id), "title": .string("grammar, again")])
            #expect(renamed.isError != true, "\(text(renamed))")
            let outside = try await call(connection, "rename_note",
                                         ["note_id": .string(w.outside.id), "title": .string("nope")])
            #expect(outside.isError == true && text(outside) == MCPRefusalCopy.words(.notShared, .note))
            // remove_tag at edit takes the note out of the rule — and out of reach.
            let untag = try await call(connection, "remove_tag",
                                       ["note_id": .string(w.members[1].id), "tag": .string("parser")])
            #expect(untag.isError != true, "\(text(untag))")
            let after = try await call(connection, "rename_note",
                                       ["note_id": .string(w.members[1].id), "title": .string("gone")])
            #expect(after.isError == true && text(after) == MCPRefusalCopy.words(.notShared, .note),
                    "it left the gathering, so it left the grant's reach")
            await h.hangUp(connection)
        }
    }

    // MARK: - write_new: bookless in its wing, the rule's tags, one undo

    @Test func writeNewMintsBooklessInTheWingWearingTheRulesTagsWithOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            // `#parser AND NOT #draft` — a NOT a fresh note meets by not wearing it.
            let w = try world(h) { parser, ops in
                .and([.tag(parser.id), .not(.tag(try ops.createTag(name: "draft", wingID: parser.wingId).id))])
            }
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.writeNew, .gathering, w.gathering.id, .once)))
            #expect(try await connection.client.listTools().tools.map(\.name).contains("create_note"))
            let livingBefore = try members(h, ofBook: w.living.id)

            let result = try await call(connection, "create_note", [
                "book_id": .string(w.gathering.id), "title": .string("a new parser note"),
                "text": .string("first paragraph\n\nsecond paragraph"),
            ])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            // VX-252's record shape with VX-361's tag listing — no key more, none less.
            #expect(Set(answer.keys) == ["note_id", "block_ids", "tag_ids", "tags", "blocks"])
            #expect(answer["tags"] as? [String] == ["parser"] && answer["tag_ids"] as? [String] == [w.parser.id])
            let noteID = try #require(answer["note_id"] as? String)
            #expect((answer["blocks"] as? [[String: Any]])?.count == 2)

            // Bookless, in the gathering's wing, and the gathering shows it.
            let note = try #require(try row(h, "SELECT wing_id FROM container WHERE id = ?", [noteID]))
            #expect(note["wing_id"] as String == w.wing.id)
            #expect(try assembled(h, w.gathering.id).contains(noteID))
            // The ONE application road: the living book collecting #parser heard it.
            #expect(Set(try members(h, ofBook: w.living.id)) == Set(livingBefore + [noteID]),
                    "a living book hears the tag, as when the author tags")
            #expect(try consumedAt(h, once) != nil, "the once grant is one act — spent by it")

            // ONE client-named undo takes it all back.
            #expect(h.undoStack.depth == 1
                    && h.undoStack.topLabel == Operations.MCPWriteAct.note.undoLabel(client: "claude-code"))
            #expect(try h.undoStack.undo(with: h.writeOperations) != nil)
            #expect(try row(h, "SELECT id FROM container WHERE id = ? AND deleted_at IS NULL", [noteID]) == nil)
            #expect(!(try assembled(h, w.gathering.id).contains(noteID)))
            #expect(Set(try members(h, ofBook: w.living.id)) == Set(livingBefore), "its seat went with it")

            // Activity: the landed act, on the gathering.
            let activity = try #require(try row(
                h, "SELECT * FROM mcp_activity WHERE act = 'create_note' ORDER BY id DESC LIMIT 1", []))
            #expect(activity["target_kind"] as String == "gathering" && activity["target_id"] as String == w.gathering.id)
            #expect(activity["outcome"] as String == "allowed")
            await h.hangUp(connection)
        }
    }

    @Test func importDocumentIntoAGatheringWearsTheHeadersTagsThenTheRules() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .gathering, w.gathering.id))
            let result = try await call(connection, "import_document", [
                "book_id": .string(w.gathering.id), "document": .string("{t:\"imported\"} {#ideas}\n\none paragraph"),
            ])
            #expect(result.isError != true, "\(text(result))")
            let answer = try json(result)
            #expect(answer["tags"] as? [String] == ["ideas", "parser"], "the header's first, then the rule's")
            #expect(try assembled(h, w.gathering.id).contains(try #require(answer["note_id"] as? String)))
            await h.hangUp(connection)
        }
    }

    // MARK: - A rule tagging can't satisfy refuses in words — never the not-shared shape

    @Test func aRuleThatNeedsAStarRefusesWriteNewInWordsAndWritesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h) { parser, _ in .and([.tag(parser.id), .star]) }
            let connection = try await h.connect(as: "claude-code")
            let once = try #require(try h.approve("claude-code", spec(.writeNew, .gathering, w.gathering.id, .once)))
            h.asks.setValue([])
            let notesBefore = try containerCount(h)
            let refused = try await call(connection, "create_note",
                                         ["book_id": .string(w.gathering.id), "text": .string("a starred idea")])
            #expect(refused.isError == true)
            #expect(text(refused) == GatheringMint.Blocker.needsStar.reason)
            #expect(text(refused) == "Its rule needs a starred note, and only the author can star one.")
            #expect(text(refused) != MCPRefusalCopy.words(.notShared, .book), "never the not-shared shape")
            #expect(try containerCount(h) == notesBefore,
                    "nothing minted — refused before the mint")
            #expect(try consumedAt(h, once) == nil, "a refused act never spends the once grant")
            #expect(h.asks.value.isEmpty, "no ask could change it")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    @Test func aStarOrATagRuleTakesTheTagOnTheWire() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h) { parser, _ in .or([.star, .tag(parser.id)]) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .gathering, w.gathering.id))
            let result = try await call(connection, "create_note",
                                        ["book_id": .string(w.gathering.id), "text": .string("tagged, not starred")])
            #expect(result.isError != true, "\(text(result))")
            #expect(try json(result)["tags"] as? [String] == ["parser"], "the tag option, where her door would star")
            await h.hangUp(connection)
        }
    }

    // MARK: - Past the rung, hidden, missing, archived, dead

    @Test func aWriteIntoAGatheringPastTheRungAsksOnItAndAHiddenOneAnswersAsMissing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let reader = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .gathering, w.gathering.id))
            h.asks.setValue([])
            let past = try await call(reader, "create_note",
                                      ["book_id": .string(w.gathering.id), "text": .string("more")])
            #expect(past.isError == true)
            #expect(text(past) == MCPRefusalCopy.words(.rungTooLow(granted: .read), .book, asked: true))
            #expect(h.asks.value.map(\.scopeKind) == [.gathering] && h.asks.value.first?.scopeID == w.gathering.id
                    && h.asks.value.first?.rung == .writeNew, "her ask names the gathering — her answer can grant it")

            // A client holding nothing on it: the gathering and a missing id read alike.
            let stranger = try await h.connect(as: "codex")
            _ = try h.approve("codex", spec(.read, .note, w.outside.id))
            let hidden = try await call(stranger, "create_note",
                                        ["book_id": .string(w.gathering.id), "text": .string("x")])
            let nowhere = try await call(stranger, "create_note",
                                         ["book_id": .string("no-such-place"), "text": .string("x")])
            #expect(hidden.isError == true && text(hidden) == text(nowhere)
                    && text(hidden) == MCPRefusalCopy.words(.notShared, .book))
            let listed = try await call(stranger, "list_notes", ["book_id": .string(w.gathering.id)])
            let listedNowhere = try await call(stranger, "list_notes", ["book_id": .string("no-such-place")])
            #expect(text(listed) == text(listedNowhere))
            // …and its own log reads them alike too (list_my_activity never tells).
            let acts = try #require(try json(try await call(stranger, "list_my_activity", [:]))["acts"] as? [[String: Any]])
            let refusedWrites = acts.filter { $0["tool"] as? String == "create_note" }
            #expect(refusedWrites.count == 2 && Set(refusedWrites.map { $0["target_kind"] as? String }) == ["book"])
            await h.hangUp(reader)
            await h.hangUp(stranger)
        }
    }

    @Test func anArchivedGatheringReachesNothingAndRefusesTheMintInHerWordsAndADeadOneIsGone() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .gathering, w.gathering.id))
            let missing = MCPRefusalCopy.words(.notShared, .note)
            try h.operations.archiveReading(w.gathering.id)
            #expect(text(try await call(connection, "read_note", ["note_id": .string(w.members[0].id)])) == missing,
                    "archived: it assembles empty, so its grant reaches no note")
            let archived = try #require(try json(try await call(
                connection, "list_books", ["include_archived": .bool(true)]))["books"] as? [[String: Any]])
            #expect(archived.first { $0["id"] as? String == w.gathering.id }?["notes"] as? Int == 0)
            let mint = try await call(connection, "create_note",
                                      ["book_id": .string(w.gathering.id), "text": .string("x")])
            #expect(mint.isError == true && text(mint) == GatheringMint.Blocker.archived.reason,
                    "her door's own words: \(text(mint))")

            _ = try h.operations.unarchiveReading(w.gathering.id)
            #expect(try await call(connection, "read_note", ["note_id": .string(w.members[0].id)]).isError != true)

            // Dead: every dead place's answer.
            try h.operations.deleteReading(w.gathering.id)
            #expect(text(try await call(connection, "read_note", ["note_id": .string(w.members[0].id)])) == missing)
            let deadList = try await call(connection, "list_notes", ["book_id": .string(w.gathering.id)])
            #expect(deadList.isError == true && text(deadList) == MCPRefusalCopy.words(.notShared, .book))
            let deadMint = try await call(connection, "create_note",
                                          ["book_id": .string(w.gathering.id), "text": .string("x")])
            #expect(text(deadMint) == MCPRefusalCopy.words(.notShared, .book))
            await h.hangUp(connection)
        }
    }
}
