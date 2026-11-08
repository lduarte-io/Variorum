import Foundation
import MCP
import VariorumCore

/// **VX-396 — AN IDENTIFIER HOLDING U+0000 REFUSES AT THE DOOR'S IDENTIFIER
/// PARSE** (the VX-912 run, batch B4; born at VX-348 U1 — VX-357's identity
/// finding; the record `notes/plans/fixes/vx-912-open-source-gating.md`, "B4 record").
///
/// The trace: GRDB binds every TEXT with length -1, so SQLite reads a bound
/// string only up to its first NUL, while Swift compares the whole string.
/// VX-357 strips U+0000 from PROSE in the operations layer (ruled), and
/// deliberately not from identifiers — an identity must bind the same on every
/// lookup. So an identifier holding one was, to SQL, its prefix: a
/// `clientInfo.name` read and wrote the row of the name before the NUL (her
/// Activity logged a stranger under her client's name; a waiting setup was
/// minted on it; a name of only U+0000 minted a client named ''), a block id
/// landed a take on its prefix's block, a book id listed its prefix's book, a
/// refused note id was logged against its prefix's note, and a cursor's id
/// resumed as its prefix.
///
/// The rule, at the three seams where the door parses an identifier — each a
/// PARSE refusal: one sentence, before any decision, so nothing is read,
/// written, asked, spent or logged, and it depends only on what the client
/// sent (no oracle):
/// - **at naming** (`MCPSession.run`): a declared `clientInfo.name` holding
///   U+0000 is answered on the `initialize` frame's own id and the connection
///   ends — before the hold and the admission (a store that logged it would log
///   it under the prefix: the bug itself);
/// - **at the call door** (`MCPSession`'s `CallTool` handler, right after
///   VX-606's schema check): a declared tool's IDENTIFIER argument holding
///   U+0000, at any depth its published schema describes, refuses the call,
///   naming the argument by its path (`note_id`, `note_ids[1]`,
///   `takes[0].block_id`);
/// - **at the cursor's own parse** (`PageCursor`, `NotePageCursor`): a decoded
///   cursor holding U+0000 is not one this server returned — the stale
///   sentence each already speaks.
///
/// Prose is VX-357's lane, untouched: text, labels, names, titles, messages,
/// comments and tag paths are stripped and counted by the operations; a
/// precondition or locator holding a NUL refuses honestly at its op
/// (P-VX357-4). The classification below says which argument names are which,
/// for every argument the catalog publishes (pinned exhaustive).
struct MCPNullIdentifier: Error, Equatable, Sendable {
    /// Where the null was: nil = the connection's `clientInfo.name`; otherwise
    /// the call's argument paths, in the walk's stable order (keys sorted at
    /// each level, array items in order).
    let arguments: [String]?

    /// A declared `clientInfo.name` holding U+0000 — nil when it holds none
    /// (or the frame named no one: the admission's own refusal speaks then).
    static func clientName(_ name: String?) -> MCPNullIdentifier? {
        guard let name, StoredText.containsNull(name) else { return nil }
        return MCPNullIdentifier(arguments: nil)
    }

    /// **The call door's check:** a call to a DECLARED tool whose identifier
    /// arguments hold U+0000; nil = route it (a tool no catalog knows answers
    /// "Unknown tool" from the router, as before).
    static func call(tool name: String, arguments: [String: Value]?) -> MCPNullIdentifier? {
        guard let declaration = MCPToolCatalog.declaration(named: name) else { return nil }
        var found: [String] = []
        walk(.object(arguments ?? [:]), schema: declaration.inputSchema, path: "", into: &found)
        return found.isEmpty ? nil : MCPNullIdentifier(arguments: found)
    }

    /// The connection's sentence (PROVISIONAL P-912-B4-1 — her copy pass):
    /// the handshake refusals' register ("Variorum refused this connection: …").
    static let clientNameWords =
        "Variorum refused this connection: its client name holds a null character (U+0000), which a client "
        + "name can't carry. Reconnect under a name without one."

    /// The words, spoken through THE ONE CHAIN (`MCPWireRefusalCopy.words`).
    /// The call's sentence (PROVISIONAL P-912-B4-2): the wire's parse register,
    /// VX-606's shape and its list grammar.
    var words: String {
        guard let arguments, !arguments.isEmpty else { return Self.clientNameWords }
        let named = MCPArgumentSchema.spelled(arguments)
        let holds = arguments.count == 1 ? "holds a null character" : "hold null characters"
        return "\(named) \(holds) (U+0000), which no Variorum id carries, so nothing was done \u{2014} send each "
            + "id exactly as an answer gave it."
    }

    // MARK: - The classification (every argument name the catalog publishes, once)

    /// Argument names whose values are row ids — a string, or an array of
    /// strings. A NUL in one refuses the call.
    static let identifierKeys: Set<String> = [
        "after_block_id", "after_note_id", "after_section_id", "before_block_id", "before_note_id",
        "before_section_id", "block_a", "block_b", "block_id", "book_id", "comment_id", "commit_id",
        "commit_ids", "first_block_id", "lens_id", "note_a", "note_b", "note_id", "note_ids", "peer_ids",
        "second_block_id", "section_id", "take_id", "take_ids", "version_id", "wing_id",
    ]

    /// Argument names whose value is an object KEYED by ids (`propose_notes_to_book`'s
    /// `reasons`: a note id → its reason). A NUL in a key refuses the call;
    /// the values are prose.
    static let identifierKeyedKeys: Set<String> = ["reasons"]

    /// Every other argument name: prose (VX-357 strips it), flags, numbers,
    /// enums, day keys, tag paths and rules, preconditions and locators (they
    /// refuse honestly at their op), the containers the walk descends into, and
    /// `cursor` — opaque here, its ids checked at its own parse.
    static let otherKeys: Set<String> = [
        "at", "blocks", "book", "brief", "chapters", "comments", "cursor", "document", "documents",
        "entry_date", "expected_text", "ids_only", "include_archived", "include_commits", "include_reads",
        "label", "limit", "message", "name", "new_matches", "new_str", "old_str", "order", "outflow", "pairs",
        "pin_chosen", "query", "reason", "rule", "second_half_starts_with", "select", "sort_dir", "sort_field",
        "starred", "tag", "tags", "takes", "target", "text", "title", "with", "with_commits", "with_ids",
        "with_lenses", "with_lineage", "with_tags", "with_tray", "with_versions",
    ]

    // MARK: - The walk (the published schema, read back — VX-606's road)

    /// Only what the schema DECLARES is read (an undeclared key is VX-606's to
    /// refuse, an open object's contents the tool's to parse); a value of the
    /// wrong shape is the tool's parse to word, never this walk's.
    private static func walk(_ value: Value, schema: Value, path: String, into found: inout [String]) {
        guard let schema = schema.objectValue else { return }
        if let object = value.objectValue {
            let properties = schema["properties"]?.objectValue ?? [:]
            for key in object.keys.sorted() {
                guard let property = properties[key], let child = object[key] else { continue }
                let keyPath = path.isEmpty ? key : "\(path).\(key)"
                if identifierKeys.contains(key) {
                    check(child, path: keyPath, into: &found)
                } else if identifierKeyedKeys.contains(key) {
                    if let keyed = child.objectValue, keyed.keys.contains(where: StoredText.containsNull) {
                        found.append("a key of \(keyPath)")
                    }
                } else {
                    walk(child, schema: property, path: keyPath, into: &found)
                }
            }
        } else if let array = value.arrayValue, let items = schema["items"] {
            for (index, element) in array.enumerated() {
                walk(element, schema: items, path: "\(path)[\(index)]", into: &found)
            }
        }
    }

    private static func check(_ value: Value, path: String, into found: inout [String]) {
        switch value {
        case .string(let id):
            if StoredText.containsNull(id) { found.append(path) }
        case .array(let items):
            for (index, item) in items.enumerated() {
                if case .string(let id) = item, StoredText.containsNull(id) { found.append("\(path)[\(index)]") }
            }
        default:
            break
        }
    }
}
