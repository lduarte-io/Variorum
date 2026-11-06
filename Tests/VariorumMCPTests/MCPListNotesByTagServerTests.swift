import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-810 (the VX-827 run, U2 — the run record `notes/plans/fixes/vx-827-lineage.md`
// U2 RECORD): the list-by-tag road and the richer rows, end to end over a real
// socket. `list_notes` takes `tag` (a PATH, every tag tool's form) and lists only
// the notes wearing it or a tag under it — on the note itself or on a block it
// places (the ONE wearer rule, `Queries.notesWearingTag`) — read in the listing's
// own wing (a book's, a wing's; the bare form in each note's), within reach and the
// fence, paged as ever. Every row carries the note's own `tag_ids` + `tags` and its
// `entry_date` (null when undated — the VX-758 rider); `read_note`'s JSON forms carry
// the note's `tag_ids` + `tags`. (The two-store catalog's `list_notes · … tag …` arms
// pin the same answers byte for byte across a store with hidden wearers and one
// without.)

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

private func ids(_ answer: [String: Any]) -> [String] {
    (answer["notes"] as? [[String: Any]] ?? []).compactMap { $0["id"] as? String }
}

private func row(_ answer: [String: Any], _ id: String) -> [String: Any]? {
    (answer["notes"] as? [[String: Any]] ?? []).first { $0["id"] as? String == id }
}

/// The world: Home's book "drafts" (a READ book grant) holds `a` (wearing #percy),
/// `b` (#percy/pt-en on a BLOCK only), `c` (#other) and `d` (#percy, but PRIVATE —
/// fenced); Home holds `loose` (#percy, ungranted — hidden) and `secretOnly` (the
/// only wearer of #secret, ungranted); Studio (a READ wing grant) holds `s1` (its
/// OWN #percy) and `s2` (none); a gathering in Studio collects #idea (`g1` wears
/// #idea and #percy, `g2` #idea alone).
private struct World {
    var book = "", studio = "", gathering = ""
    var a = "", b = "", c = "", d = "", loose = "", secretOnly = "", s1 = "", s2 = "", g1 = "", g2 = ""
    var percy = "", studioPercy = "", ptEn = ""
}

private func build(_ h: ServerHarness) throws -> World {
    let ops = h.operations
    var w = World()
    let percy = try ops.createTag(name: "percy")
    let ptEn = try ops.createTag(parent: percy.id, name: "pt-en")
    let other = try ops.createTag(name: "other")
    let secret = try ops.createTag(name: "secret")
    (w.percy, w.ptEn) = (percy.id, ptEn.id)
    let book = try ops.createReading(name: "drafts", kind: .book)
    w.book = book.id
    func note(_ title: String, wing: String = "", in book: String? = nil, dated: String? = nil) throws -> String {
        let note = try ops.createPost(title: title, entryDate: dated, wingId: wing)
        _ = try ops.newBlock(in: note.id, text: "\(title) words.", registeringUndo: false)
        if let book { _ = try ops.addPostToReading(note.id, to: book) }
        return note.id
    }
    w.a = try note("a", in: book.id, dated: "2019-03-04")
    _ = try ops.applyTag(percy.id, toPost: w.a)
    w.b = try note("b", in: book.id)
    let bBlock = try ops.newBlock(in: w.b, text: "b's quoted line.", registeringUndo: false)
    _ = try ops.applyTag(ptEn.id, toBlock: bBlock.block.id)
    w.c = try note("c", in: book.id)
    _ = try ops.applyTag(other.id, toPost: w.c)
    w.d = try note("d", in: book.id)
    _ = try ops.applyTag(percy.id, toPost: w.d)
    _ = try ops.setNotePrivate(w.d, true)
    w.loose = try note("loose")
    _ = try ops.applyTag(percy.id, toPost: w.loose)
    w.secretOnly = try note("secret only")
    _ = try ops.applyTag(secret.id, toPost: w.secretOnly)
    let studio = try ops.createWing(name: "Studio")
    w.studio = studio.id
    let studioPercy = try ops.createTag(name: "percy", wingID: studio.id)
    w.studioPercy = studioPercy.id
    let idea = try ops.createTag(name: "idea", wingID: studio.id)
    w.s1 = try note("s1", wing: studio.id)
    _ = try ops.applyTag(studioPercy.id, toPost: w.s1)
    w.s2 = try note("s2", wing: studio.id)
    w.gathering = try ops.createReading(
        name: "ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(idea.id)), wingId: studio.id).id
    w.g1 = try note("g1", wing: studio.id)
    _ = try ops.applyTag(idea.id, toPost: w.g1)
    _ = try ops.applyTag(studioPercy.id, toPost: w.g1)
    w.g2 = try note("g2", wing: studio.id)
    _ = try ops.applyTag(idea.id, toPost: w.g2)
    return w
}

private func grantAll(_ h: ServerHarness, _ w: World) throws {
    _ = try h.approve("claude-code", spec(.read, .book, w.book))
    _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .wing, w.studio))
}

@Suite("VX-810 — list_notes by tag; tags and entry_date on the rows; tags in read_note's JSON", .serialized)
struct MCPListNotesByTagServerTests {

    /// The listing's own wing, the subtree, the post/block union, the fence:
    /// a book lists its readable wearers in book order (the Private one absent),
    /// a child path only its own, Studio its own #percy (Home's never), the bare
    /// form every readable wearer in each note's own wing — and nothing hidden.
    @Test func aTagListsTheReadableNotesWearingItInTheListingsOwnWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)

            let inBook = try json(try await call(connection, "list_notes", ["book_id": .string(w.book), "tag": "percy"]))
            #expect(ids(inBook) == [w.a, w.b], "book order: the note's own #percy, then a block's #percy/pt-en")
            #expect(inBook["chapters"] as? [Any] != nil, "the book's chapters ride as ever")
            let child = try json(try await call(connection, "list_notes", ["book_id": .string(w.book), "tag": "#percy/pt-en"]))
            #expect(ids(child) == [w.b], "a child path lists its own wearers; a leading # is tolerated")
            let inStudio = try json(try await call(connection, "list_notes", ["wing_id": .string(w.studio), "tag": "percy"]))
            #expect(Set(ids(inStudio)) == [w.s1, w.g1], "Studio's own #percy — Home's wearers are another wing's")
            let bare = try json(try await call(connection, "list_notes", ["tag": "percy"]))
            #expect(Set(ids(bare)) == [w.a, w.b, w.s1, w.g1],
                    "every readable wearer, each in its own wing — the Private and the ungranted ones absent")
            let gathered = try json(try await call(connection, "list_notes", ["book_id": .string(w.gathering), "tag": "percy"]))
            #expect(ids(gathered) == [w.g1], "a gathering's assembly, filtered")

            // The bare tagged listing IS the bare listing's wearers (the
            // wearers-as-candidates road agrees with the reach walk).
            let everything = try json(try await call(connection, "list_notes", ["limit": 200]))
            let wearing = Set(try await h.database.read { try Queries.notesWearingTag($0, path: "percy", wingID: nil) })
            #expect(ids(bare) == ids(everything).filter(wearing.contains), "the same notes, in the same order")
            await h.hangUp(connection)
        }
    }

    /// A path no note the client can read wears answers exactly as a path
    /// naming nothing — a tag worn only beyond reach is not even hinted; a
    /// path that names no path at all refuses at the call door in `remove_tag`'s
    /// words, logging nothing.
    @Test func aTagWornOnlyBeyondReachListsExactlyAsATagNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)
            for args: [String: Value] in [[:], ["book_id": .string(w.book)], ["wing_id": .string(w.studio)]] {
                var hidden = args
                hidden["tag"] = "secret"
                var nothing = args
                nothing["tag"] = "no/such/tag"
                let worn = try await call(connection, "list_notes", hidden)
                let named = try await call(connection, "list_notes", nothing)
                #expect(worn.isError != true && text(worn) == text(named), "\(args): \(text(worn)) vs \(text(named))")
                #expect(ids(try json(worn)).isEmpty)
            }
            let logged = try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0 }
            let refused = try await call(connection, "list_notes", ["tag": "///"])
            #expect(refused.isError == true && text(refused) == MCPWriteTools.tagPathWords)
            #expect(try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0 } == logged,
                    "a parse refusal is never logged")
            await h.hangUp(connection)
        }
    }

    /// Paged as every listing: a tagged listing walks page by page by its own
    /// cursor, and the pages together are the unpaged answer.
    @Test func aTaggedListingPagesAsEveryListing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)
            for base: [String: Value] in [["tag": "percy"], ["book_id": .string(w.book), "tag": "percy"]] {
                let whole = ids(try json(try await call(connection, "list_notes", base)))
                var paged: [String] = []
                var args = base
                args["limit"] = 1
                while true {
                    let page = try json(try await call(connection, "list_notes", args))
                    paged += ids(page)
                    guard let next = page["next_cursor"] as? String else { break }
                    args["cursor"] = .string(next)
                }
                #expect(paged == whole, "\(base): \(paged) vs \(whole)")
            }
            await h.hangUp(connection)
        }
    }

    /// Every row says the tags the note ITSELF wears (ids and paths, by path —
    /// a block's tag is the block's) and its entry_date, null when undated —
    /// in a book's, a wing's, a gathering's and the bare listing alike.
    @Test func everyRowCarriesTheNotesOwnTagsAndItsEntryDate() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)
            let inBook = try json(try await call(connection, "list_notes", ["book_id": .string(w.book)]))
            let a = try #require(row(inBook, w.a))
            #expect(a["tag_ids"] as? [String] == [w.percy] && a["tags"] as? [String] == ["percy"])
            #expect(a["entry_date"] as? String == "2019-03-04")
            let b = try #require(row(inBook, w.b))
            #expect(b["tag_ids"] as? [String] == [] && b["tags"] as? [String] == [],
                    "b's #percy/pt-en is its block's, not the note's")
            #expect(b["entry_date"] is NSNull, "undated: null, always present")
            #expect(text(try await call(connection, "list_notes", ["book_id": .string(w.book)])).contains(#""entry_date":null"#))
            let inStudio = try json(try await call(connection, "list_notes", ["wing_id": .string(w.studio)]))
            #expect(row(inStudio, w.s2)?["tags"] as? [String] == [] && row(inStudio, w.s2)?["entry_date"] is NSNull)
            let gathered = try json(try await call(connection, "list_notes", ["book_id": .string(w.gathering)]))
            #expect(row(gathered, w.g1)?["tags"] as? [String] == ["idea", "percy"], "by path")
            #expect(row(gathered, w.g1)?["entry_date"] is NSNull)
            let bare = try json(try await call(connection, "list_notes", [:]))
            #expect(row(bare, w.s1)?["tag_ids"] as? [String] == [w.studioPercy], "Studio's own tag's id")
            await h.hangUp(connection)
        }
    }

    /// `read_note`'s JSON forms carry the note's own tag_ids + tags — the
    /// with_ids read and every page — while a saved version's read (the key is
    /// the live read's, as `books` is) and the Level 0 text keep their shapes.
    @Test func readNotesJSONCarriesTheNotesOwnTags() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let version = try h.operations.saveNoteVersion(w.a).post.id
            _ = try h.operations.newBlock(in: w.a, text: "A second block.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)
            let read = try json(try await call(connection, "read_note", ["note_id": .string(w.a), "with_ids": true]))
            #expect(read["tag_ids"] as? [String] == [w.percy] && read["tags"] as? [String] == ["percy"])
            let untagged = try json(try await call(connection, "read_note", ["note_id": .string(w.b), "with_ids": true]))
            #expect(untagged["tag_ids"] as? [String] == [] && untagged["tags"] as? [String] == [],
                    "always present; a block's tag is the block's")
            var page = try json(try await call(connection, "read_note", ["note_id": .string(w.a), "limit": 1]))
            #expect(page["tags"] as? [String] == ["percy"], "the first page")
            let next = try #require(page["next_cursor"] as? String)
            page = try json(try await call(connection, "read_note", ["note_id": .string(w.a), "cursor": .string(next)]))
            #expect(page["tags"] as? [String] == ["percy"], "and every page, as entry_date")
            let moment = try json(try await call(connection, "read_note", [
                "note_id": .string(w.a), "version_id": .string(version), "with_ids": true,
            ]))
            #expect(moment["tags"] == nil && moment["tag_ids"] == nil && moment["books"] == nil,
                    "a saved version's read carries neither, as it carries no books")
            let level0 = text(try await call(connection, "read_note", ["note_id": .string(w.a)]))
            #expect(level0 == (try await h.database.read { try Queries.variorumDocumentText($0, postID: w.a) }),
                    "the Level 0 text is the document, its header saying the tags as ever")
            await h.hangUp(connection)
        }
    }

    /// VX-606: `tag` is declared (served), and an argument the schema does not
    /// declare — `tags`, the plural — refuses the call in the door's words.
    @Test func theTagArgumentIsDeclaredAndItsPluralIsNot() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            try grantAll(h, w)
            let served = try await call(connection, "list_notes", ["tag": "percy"])
            #expect(served.isError != true)
            let plural = try await call(connection, "list_notes", ["tags": .array(["percy"])])
            #expect(plural.isError == true
                    && text(plural) == MCPArgumentSchema.words(tool: "list_notes", undeclared: ["tags"]))
            let properties = try #require(MCPToolCatalog.listNotes.inputSchema.objectValue?["properties"]?.objectValue)
            #expect(properties["tag"]?.objectValue?["type"] == "string")
            for needle in ["tag (a tag's path", "on one of its blocks", "entry_date (null", "tag_ids and tags"] {
                #expect(MCPToolCatalog.listNotes.description.contains(needle), "the description says \(needle)")
            }
            #expect(MCPToolCatalog.readNote.description.contains("its tag_ids and tags"))
            await h.hangUp(connection)
        }
    }
}
