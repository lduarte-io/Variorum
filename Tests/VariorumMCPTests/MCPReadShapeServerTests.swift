import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U3 — VX-186: `read_note` with `with_ids` sends each shown text ONCE.
// Until this unit every block carried the shown take's text twice: once as the
// block's `text`, once inside that take's own entry (`MCPNoteStructure.read` —
// the run record's trace). The deduped shape: the block NAMES the take it
// shows (`shown_take_id`) and every take carries its own text, once; `chosen`
// keeps meaning the note's own shown take, and under a lens `via` keeps saying
// how the shown take resolved (VX-172's marker, coherent with the id).

/// The take a with_ids block shows — the entry its `shown_take_id` names
/// (VX-186's shape; every other pin reads a block's shown text through this).
func shownTake(_ block: [String: Any]) -> [String: Any]? {
    guard let id = block["shown_take_id"] as? String else { return nil }
    return (block["takes"] as? [[String: Any]])?.first { $0["take_id"] as? String == id }
}

/// The text a with_ids block shows (VX-186: read from its shown take's entry —
/// the block itself carries no text).
func shownText(_ block: [String: Any]) -> String? {
    shownTake(block)?["text"] as? String
}

@Suite("VX-186 — read_note with ids sends each shown text once", .serialized)
struct MCPReadShapeServerTests {
    private func spec(_ id: String) -> Operations.MCPGrantSpec {
        .init(rung: .read, scopeKind: .book, scopeID: id, duration: .always)
    }

    /// A 20-block note in a book: every block's text distinct; block 3 fanned
    /// (her take + "block 03, another take"); a lens showing that other take.
    private struct World {
        let book: Reading
        let note: Container
        let blockIDs: [String]
        let texts: [String]
        let otherTake: String
        let lensID: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "twenty")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        var blockIDs: [String] = []
        var texts: [String] = []
        var block3: (block: String, take: String)?
        for index in 1...20 {
            let text = String(format: "Block %02d says its own distinct words, once.", index)
            let minted = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
            blockIDs.append(minted.block.id)
            texts.append(text)
            if index == 3 { block3 = (minted.block.id, minted.variant.id) }
        }
        let anchor = try #require(block3)
        let other = try h.operations.branchVariant(anchor.block, from: anchor.take)
        try h.operations.autosave(other.id, text: "Block 03, another take entirely.", charDelta: 10)
        let lens = try h.operations.createLens(post: note.id, name: "the other three")
        _ = try h.operations.setLensChoice(lens: lens.id, block: anchor.block, variant: other.id)
        return World(book: book, note: note, blockIDs: blockIDs, texts: texts, otherTake: other.id, lensID: lens.id)
    }

    private func occurrences(of needle: String, in haystack: String) -> Int {
        haystack.components(separatedBy: needle).count - 1
    }

    /// THE PIN (red on the pre-fix tree — every shown text crossed twice): in
    /// the with_ids answer, every take's text appears EXACTLY ONCE — read
    /// plain and read through a lens.
    @Test func everyTextCrossesTheWireOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(w.book.id))

            let plain = text(try await connection.client.callTool(name: "read_note", arguments: [
                "note_id": .string(w.note.id), "with_ids": .bool(true),
            ]))
            for words in w.texts + ["Block 03, another take entirely."] {
                #expect(occurrences(of: words, in: plain) == 1, "\(words) crossed \(occurrences(of: words, in: plain)) times")
            }
            let throughLens = text(try await connection.client.callTool(name: "read_note", arguments: [
                "note_id": .string(w.note.id), "with_ids": .bool(true), "lens_id": .string(w.lensID),
            ]))
            for words in w.texts + ["Block 03, another take entirely."] {
                #expect(occurrences(of: words, in: throughLens) == 1,
                        "through the lens, \(words) crossed \(occurrences(of: words, in: throughLens)) times")
            }
            // The size the duplicate cost: the prose now crosses once.
            let prose = (w.texts + ["Block 03, another take entirely."]).reduce(0) { $0 + $1.utf8.count }
            #expect(plain.utf8.count < 2 * prose, "the answer no longer carries the prose twice")
            await h.hangUp(connection)
        }
    }

    /// THE SHAPE: no block carries a text of its own; each names the take it
    /// shows (`shown_take_id`), whose entry carries the text. Without a lens
    /// that is the take marked chosen; through a lens, `via: "lens"` blocks
    /// name the lens's take and `via: "chosen"` blocks the chosen one — and
    /// the shown texts read back as the note reads.
    @Test func eachBlockNamesTheTakeItShows() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(w.book.id))

            let plain = try json(try await connection.client.callTool(name: "read_note", arguments: [
                "note_id": .string(w.note.id), "with_ids": .bool(true),
            ]))
            let blocks = try #require(plain["blocks"] as? [[String: Any]])
            #expect(blocks.map { $0["block_id"] as? String } == w.blockIDs)
            for block in blocks {
                #expect(block["text"] == nil, "a block carries no text of its own — its shown take does")
                let shown = try #require(shownTake(block), "every block names the take it shows")
                #expect(shown["chosen"] as? Bool == true, "without a lens the shown take is the note's chosen")
            }
            #expect(blocks.compactMap(shownText) == w.texts, "the shown texts read as the note reads")

            let lensed = try json(try await connection.client.callTool(name: "read_note", arguments: [
                "note_id": .string(w.note.id), "with_ids": .bool(true), "lens_id": .string(w.lensID),
            ]))
            let throughLens = try #require(lensed["blocks"] as? [[String: Any]])
            for (index, block) in throughLens.enumerated() {
                #expect(block["text"] == nil)
                let shown = try #require(shownTake(block))
                if index == 2 {
                    #expect(block["via"] as? String == "lens")
                    #expect(shown["take_id"] as? String == w.otherTake, "the lens's take is the one shown")
                    #expect(shown["chosen"] as? Bool == false, "chosen stays the note's own fact — a lens is a view")
                } else {
                    #expect(block["via"] as? String == "chosen")
                    #expect(shown["chosen"] as? Bool == true)
                }
            }
            var lensTexts = w.texts
            lensTexts[2] = "Block 03, another take entirely."
            #expect(throughLens.compactMap(shownText) == lensTexts)
            await h.hangUp(connection)
        }
    }
}
