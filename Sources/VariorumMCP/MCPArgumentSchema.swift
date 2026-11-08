import Foundation
import MCP

/// **VX-606 — THE SCHEMA THE WIRE PUBLISHES IS THE SCHEMA IT ENFORCES** (the
/// VX-648 run, batch 2; her word "refuse undeclared arguments on every tool").
///
/// The trace (the VX-548 mid window's MID-3: `read_note` served a call carrying
/// `"ids": true`): every tool's `inputSchema` in `MCPToolCatalog` declares
/// `additionalProperties: false`, and the client reads that schema from
/// `tools/list` — but nothing on the call road ever read it back. The SDK hands
/// `CallTool`'s `arguments` to `MCPSession`'s handler untouched; the handler
/// routes them to `MCPReadTools` / `MCPWriteTools` / `MCPShowTool`, whose
/// parsers pick out the keys they know and never look at the rest. So a
/// misspelled or invented argument was silently dropped — a client asking for
/// `ids` got the plain text form and believed it had asked for something else.
///
/// The rule, ONE place for every tool (never per-tool patchwork): before a call
/// is routed, its arguments are read against the declaration's own schema —
/// wherever an object schema says `additionalProperties: false`, a key its
/// `properties` do not declare refuses the call, at any depth the schema
/// describes (a declared property whose schema is itself a closed object, or an
/// array whose `items` is one, is read the same way). The refusal is a PARSE
/// refusal, like "note_id is required.": words, before any grant is decided, so
/// nothing is read, written, asked, spent or logged, and it depends only on the
/// published catalog, never on the store (no oracle). A schema that leaves
/// `additionalProperties` open is honoured as open.
enum MCPArgumentSchema {
    /// How many unknown names a refusal spells out before it counts the rest.
    static let namedLimit = 5

    /// The keys of `arguments` that `schema` does not declare, as paths
    /// (`ids`, `blocks[0].colour`), in a stable order. Empty = the call fits.
    static func undeclared(_ arguments: [String: Value]?, schema: Value) -> [String] {
        var found: [String] = []
        walk(.object(arguments ?? [:]), schema: schema, path: "", into: &found)
        return found
    }

    /// **The call door's check** (`MCPSession`'s `CallTool` handler): the
    /// refusal for a call to a DECLARED tool that carries an argument its schema
    /// does not declare; nil = route it (a name no catalog knows answers
    /// "Unknown tool" from the router, as before).
    static func refusal(tool name: String, arguments: [String: Value]?) -> String? {
        guard let declaration = MCPToolCatalog.declaration(named: name) else { return nil }
        let unknown = undeclared(arguments, schema: declaration.inputSchema)
        return unknown.isEmpty ? nil : words(tool: name, undeclared: unknown)
    }

    /// The sentence (PROVISIONAL — the VX-648 record's BATCH 2 bundle): the
    /// wire's technical register, as its other parse refusals ("note_id is
    /// required.", "section_id isn't a chapter of this book …").
    static func words(tool: String, undeclared names: [String]) -> String {
        let verb = names.count == 1 ? "isn't an argument" : "aren't arguments"
        return "\(spelled(names)) \(verb) of \(tool), so nothing was done — send only the arguments its input schema lists."
    }

    /// The parse refusals' list grammar — "a", "a and b", "a, b and c", past
    /// five "a, b, c, d, e and 2 more" (shared with VX-396's null-identifier
    /// sentence, `MCPNullIdentifier.words`).
    static func spelled(_ names: [String]) -> String {
        let shown = Array(names.prefix(namedLimit))
        let more = names.count - shown.count
        switch (shown.count, more) {
        case (1, _): return shown[0]
        case (_, 0): return shown.dropLast().joined(separator: ", ") + " and " + shown[shown.count - 1]
        default: return shown.joined(separator: ", ") + " and \(more) more"
        }
    }

    // MARK: - The walk

    private static func walk(_ value: Value, schema: Value, path: String, into found: inout [String]) {
        guard let schema = schema.objectValue else { return }
        if let object = value.objectValue {
            let properties = schema["properties"]?.objectValue ?? [:]
            let closed = schema["additionalProperties"] == .bool(false)
            for key in object.keys.sorted() {
                let keyPath = path.isEmpty ? key : "\(path).\(key)"
                if let property = properties[key] {
                    walk(object[key] ?? .null, schema: property, path: keyPath, into: &found)
                } else if closed {
                    found.append(keyPath)
                }
            }
        } else if let array = value.arrayValue, let items = schema["items"] {
            for (index, element) in array.enumerated() {
                walk(element, schema: items, path: "\(path)[\(index)]", into: &found)
            }
        }
    }
}
