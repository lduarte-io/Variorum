import Foundation
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-396 (the VX-912 run, batch B4) — the pure half: the classification, the
// walk and the words (new API, so unit pins, not red-on-old pins; the server
// pins in `MCPNullIdentifierServerTests` carry the red). The classification is
// EXHAUSTIVE: every argument name the catalog publishes is in exactly one set,
// so a tool added later cannot ship an identifier the call door never checks.

/// Every argument name the catalog publishes, with the JSON types its schemas
/// give it (a boolean flag like `with_ids` is no identifier, whatever its name).
private func declaredArguments() -> [String: Set<String>] {
    var names: [String: Set<String>] = [:]
    func walk(_ schema: Value) {
        guard let object = schema.objectValue else { return }
        for (key, property) in object["properties"]?.objectValue ?? [:] {
            var types = names[key] ?? []
            switch property.objectValue?["type"] {
            case .string(let type)?: types.insert(type)
            case .array(let list)?: list.compactMap(\.stringValue).forEach { types.insert($0) }
            default: break
            }
            names[key] = types
            walk(property)
        }
        if let items = object["items"] { walk(items) }
        for combinator in ["anyOf", "oneOf", "allOf"] {
            if case .array(let schemas)? = object[combinator] { schemas.forEach(walk) }
        }
    }
    MCPToolCatalog.all.forEach { walk($0.inputSchema) }
    return names
}

@Suite("VX-396 — MCPNullIdentifier: the classification, the walk, the words")
struct MCPNullIdentifierTests {
    @Test func everyArgumentTheCatalogPublishesIsClassifiedExactlyOnce() {
        let ids = MCPNullIdentifier.identifierKeys
        let keyed = MCPNullIdentifier.identifierKeyedKeys
        let other = MCPNullIdentifier.otherKeys
        #expect(ids.isDisjoint(with: keyed) && ids.isDisjoint(with: other) && keyed.isDisjoint(with: other))
        let arguments = declaredArguments()
        let declared = Set(arguments.keys)
        let classified = ids.union(keyed).union(other)
        #expect(declared.subtracting(classified).isEmpty,
                "unclassified (say which set each belongs to): \(declared.subtracting(classified).sorted())")
        #expect(classified.subtracting(declared).isEmpty,
                "classified but published by no tool: \(classified.subtracting(declared).sorted())")
        // The identifier set's own shape: every STRING or ARRAY argument named
        // `…_id` / `…_ids` is in it (a boolean flag like `with_ids` is not).
        for (name, types) in arguments where name.hasSuffix("_id") || name.hasSuffix("_ids") {
            guard !types.isDisjoint(with: ["string", "array"]) else { continue }
            #expect(ids.contains(name), "\(name) names ids")
        }
    }

    @Test func theWalkFindsAnIdentifierAtEveryDepthTheSchemaDescribes() {
        func paths(_ tool: String, _ arguments: [String: Value]) -> [String]? {
            MCPNullIdentifier.call(tool: tool, arguments: arguments)?.arguments
        }
        #expect(paths("read_note", ["note_id": "n\u{0}x"]) == ["note_id"])
        #expect(paths("apply_tag", ["note_ids": ["a", "b\u{0}", "c\u{0}"], "tag": "t"]) == ["note_ids[1]", "note_ids[2]"])
        #expect(paths("add_takes", ["note_id": "n", "takes": [["block_id": "b", "text": "t"],
                                                               ["block_id": "b\u{0}", "text": "t"]]])
                == ["takes[1].block_id"])
        #expect(paths("link_versions", ["note_a": "a", "note_b": "b",
                                        "pairs": [["block_a": "x\u{0}", "block_b": "y\u{0}"]]])
                == ["pairs[0].block_a", "pairs[0].block_b"])
        #expect(paths("propose_notes_to_book", ["note_ids": ["a"], "book_id": "k",
                                                "reasons": ["a\u{0}": "why"]]) == ["a key of reasons"])
        #expect(paths("list_notes", ["wing_id": "\u{0}"]) == ["wing_id"])
        // Clean, absent, null and wrong-shaped identifiers: nothing to say.
        #expect(MCPNullIdentifier.call(tool: "read_note", arguments: ["note_id": "n"]) == nil)
        #expect(MCPNullIdentifier.call(tool: "read_note", arguments: nil) == nil)
        #expect(MCPNullIdentifier.call(tool: "create_note", arguments: ["section_id": .null, "wing_id": ""]) == nil)
        #expect(MCPNullIdentifier.call(tool: "read_note", arguments: ["note_id": 7]) == nil, "the tool's parse words it")
        // PROSE is VX-357's lane — stripped and counted by the op, never refused here.
        #expect(MCPNullIdentifier.call(tool: "add_take", arguments: ["block_id": "b", "text": "a\u{0}b",
                                                                     "label": "l\u{0}"]) == nil)
        #expect(MCPNullIdentifier.call(tool: "edit_take", arguments: ["take_id": "t", "expected_text": "x\u{0}",
                                                                      "text": "y"]) == nil,
                "a precondition refuses honestly at its op (P-VX357-4)")
        // Only what the schema declares is read; an unknown tool is the router's.
        #expect(MCPNullIdentifier.call(tool: "read_note", arguments: ["note_idx": "n\u{0}"]) == nil)
        #expect(MCPNullIdentifier.call(tool: "no_such_tool", arguments: ["note_id": "n\u{0}"]) == nil)
    }

    @Test func theWordsSpeakThroughTheOneChain() {
        let tail = " (U+0000), which no Variorum id carries, so nothing was done \u{2014} send each id exactly as an "
            + "answer gave it."
        let one = MCPNullIdentifier(arguments: ["note_id"])
        let two = MCPNullIdentifier(arguments: ["note_ids[1]", "takes[0].block_id"])
        let many = MCPNullIdentifier(arguments: ["a", "b", "c", "d", "e", "f", "g"])
        #expect(one.words == "note_id holds a null character" + tail)
        #expect(two.words == "note_ids[1] and takes[0].block_id hold null characters" + tail)
        #expect(many.words == "a, b, c, d, e and 2 more hold null characters" + tail)
        #expect(MCPNullIdentifier.clientName("claude-code\u{0}x")?.words == MCPNullIdentifier.clientNameWords)
        #expect(MCPNullIdentifier.clientName("claude-code") == nil && MCPNullIdentifier.clientName(nil) == nil)
        // The wire's own words come first in the chain, ahead of the app's table.
        for refusal in [one, two, MCPNullIdentifier(arguments: nil)] {
            #expect(MCPWireRefusalCopy.spoken(refusal, appWords: { _ in "the app's words" }) == refusal.words)
        }
    }

    @Test func theCursorsRefuseANullAtTheirOwnParse() {
        func encoded(_ text: String) -> String { Data(text.utf8).base64EncodedString() }
        #expect(PageCursor(encoded: encoded("b\n0\nnote")) != nil)
        #expect(PageCursor(encoded: encoded("b\n0\nnote\u{0}x")) == nil)
        #expect(PageCursor(encoded: encoded("r\n2026-07-01T00:00:00.000Z\u{0}\nnote")) == nil)
        #expect(PageCursor(encoded: encoded("g\n0\nnote\u{0}")) == nil)
        #expect(NotePageCursor(encoded: encoded("n\nnote\na0\nplacement")) != nil)
        #expect(NotePageCursor(encoded: encoded("n\nnote\na0\nplacement\u{0}x")) == nil)
        #expect(NotePageCursor(encoded: encoded("n\nnote\u{0}\na0\nplacement")) == nil)
    }
}
