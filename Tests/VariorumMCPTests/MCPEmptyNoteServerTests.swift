import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-815 (the VX-827 run, U2 — the run record `notes/plans/fixes/vx-827-lineage.md`
// U2 RECORD, the trace U2-2): an empty note INSIDE the client's reach says it is
// empty. The TRACE: the text forms answer the core's document read verbatim —
// `read_note`'s Level 0 is `Queries.variorumDocumentText`, `export_note` is
// `Queries.renderedText` — and an empty note's document is the EMPTY STRING, which
// is exactly the core's tolerant read of a note that does not exist: the
// NOTHING-SHAPE. The fix speaks one sentence where the text form would hold
// nothing; the with_ids form was already honest (title, books, `blocks: []`). The
// fence is UNTOUCHED: a hidden note and an id naming nothing still answer one
// byte-identical refusal in every form (the control — green on both sides by
// design).
//
// RED ON OLD: the two `…SaysItIsEmpty…` pins fail on the pre-fix tree (the
// empty answers are byte-identical with the nothing-shape) and on the announced
// behavioral revert of the fix; the controls pass on both.

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

/// A READ book grant; in the book an untitled empty note, a titled empty one,
/// an untitled note with two blank blocks, and a note with words; outside it a
/// hidden note (ungranted) — and an id naming nothing.
private struct World {
    var book = "", untitled = "", titled = "", blank = "", worded = "", hidden = ""
    var untitledTitle = "", blankTitle = ""
}

private func build(_ h: ServerHarness) throws -> World {
    let ops = h.operations
    var w = World()
    w.book = try ops.createReading(name: "drafts", kind: .book).id
    w.untitled = try ops.createPost(title: nil).id
    w.titled = try ops.createPost(title: "An empty one").id
    let blank = try ops.createPost(title: nil)
    _ = try ops.newBlock(in: blank.id, text: "", registeringUndo: false)
    _ = try ops.newBlock(in: blank.id, text: "", registeringUndo: false)
    w.blank = blank.id
    let worded = try ops.createPost(title: "worded")
    _ = try ops.newBlock(in: worded.id, text: "Some words.", registeringUndo: false)
    w.worded = worded.id
    for id in [w.untitled, w.titled, w.blank, w.worded] { _ = try ops.addPostToReading(id, to: w.book) }
    w.hidden = try ops.createPost(title: nil).id
    (w.untitledTitle, w.blankTitle) = try h.database.read { db in
        (try Queries.mcpScopeTitle(db, kind: .note, id: w.untitled) ?? "",
         try Queries.mcpScopeTitle(db, kind: .note, id: w.blank) ?? "")
    }
    return w
}

@Suite("VX-815 — an empty granted note says it's empty; the fence stays one shape", .serialized)
struct MCPEmptyNoteServerTests {

    /// THE PIN (red on old): a granted empty note's Level 0 answer is no longer
    /// the nothing-shape — the store's own read of a note that does not exist —
    /// but the one sentence, naming the note; a titled empty note keeps its
    /// header (the normal read's shape, empty body); a note of blank blocks reads
    /// as empty too; a note with words is byte-unchanged.
    @Test func readNoteSaysAGrantedEmptyNoteIsEmpty() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book))
            let nothing = try await h.database.read { try Queries.variorumDocumentText($0, postID: "no-such-note") }
            #expect(nothing.isEmpty, "the store's read of a note that does not exist — the nothing-shape")

            let untitled = try await call(connection, "read_note", ["note_id": .string(w.untitled)])
            #expect(untitled.isError != true)
            #expect(text(untitled) != nothing, "a granted empty note never answers the nothing-shape")
            #expect(text(untitled) == MCPReadTools.emptyNoteWords(title: w.untitledTitle))
            let blank = try await call(connection, "read_note", ["note_id": .string(w.blank)])
            #expect(text(blank) == MCPReadTools.emptyNoteWords(title: w.blankTitle), "blank blocks are no words")
            let titled = text(try await call(connection, "read_note", ["note_id": .string(w.titled)]))
            #expect(titled == #"{t:"An empty one"}"#, "a header is something: the normal shape, an empty body")
            let worded = text(try await call(connection, "read_note", ["note_id": .string(w.worded)]))
            #expect(worded == (try await h.database.read { try Queries.variorumDocumentText($0, postID: w.worded) }))
            await h.hangUp(connection)
        }
    }

    /// THE PIN (red on old), `export_note`: an empty note's prose is nothing,
    /// so it says the sentence — titled or not — and a note with words exports
    /// byte-unchanged.
    @Test func exportNoteSaysAGrantedEmptyNoteIsEmpty() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book))
            let nothing = try await h.database.read { try Queries.renderedText($0, containerID: "no-such-note") }
            for (id, title) in [(w.untitled, w.untitledTitle), (w.titled, "An empty one"), (w.blank, w.blankTitle)] {
                let exported = try await call(connection, "export_note", ["note_id": .string(id)])
                #expect(exported.isError != true && text(exported) != nothing, "\(title): never the nothing-shape")
                #expect(text(exported) == MCPReadTools.emptyNoteWords(title: title))
            }
            let worded = text(try await call(connection, "export_note", ["note_id": .string(w.worded)]))
            #expect(worded == (try await h.database.read { try Queries.renderedText($0, containerID: w.worded) }))
            await h.hangUp(connection)
        }
    }

    /// THE CONTROL (green on both sides — the fence is untouchable): a hidden
    /// note and an id naming nothing answer ONE byte-identical refusal in every
    /// read form; a granted empty note's answer differs from it (it always did:
    /// the fence speaks a refusal — the trace's finding); the with_ids form of
    /// an empty note is the honest structure it already was.
    @Test func theFenceStaysOneShapeAndTheEmptyNoteIsNotIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try build(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book))
            let forms: [(String, [String: Value])] = [
                ("read_note", [:]), ("read_note", ["with_ids": true]), ("export_note", [:]),
            ]
            for (tool, extra) in forms {
                var hidden = extra
                hidden["note_id"] = .string(w.hidden)
                var missing = extra
                missing["note_id"] = "no-such-note"
                var empty = extra
                empty["note_id"] = .string(w.untitled)
                let a = try await call(connection, tool, hidden)
                let b = try await call(connection, tool, missing)
                let c = try await call(connection, tool, empty)
                #expect(a.isError == true && b.isError == true && text(a) == text(b), "\(tool) \(extra): hidden = missing")
                #expect(c.isError != true && text(c) != text(a), "\(tool) \(extra): the granted empty note is not the fence")
            }
            let structure = try json(try await call(connection, "read_note", ["note_id": .string(w.untitled), "with_ids": true]))
            #expect(structure["blocks"] as? [Any] != nil && (structure["blocks"] as? [Any])?.isEmpty == true)
            #expect(structure["title"] as? String == w.untitledTitle && structure["note_id"] as? String == w.untitled)
            await h.hangUp(connection)
        }
    }

    /// The descriptions say it, so a client knows the sentence is no text.
    @Test func theDescriptionsSayAnEmptyNoteAnswersTheSentence() {
        #expect(MCPToolCatalog.readNote.description.contains("an empty note"))
        #expect(MCPToolCatalog.exportNote.description.contains("an empty note"))
    }
}
