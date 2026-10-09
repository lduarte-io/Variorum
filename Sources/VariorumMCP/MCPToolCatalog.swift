import Foundation
import MCP
import VariorumCore

/// **THE TOOL CATALOG — P-1's registry applied to the wire** (13n-b U1; the
/// lean vocabulary of the mockup §9). Every tool is declared EXACTLY ONCE:
/// its name, its rung, what it does, its input schema, and WHEN IT IS LISTED.
/// A tool the client's grants cannot use is not listed (P-2 on the wire: no
/// door that can never act); a listed tool still consults the rule on every
/// call (the list is a courtesy, never the boundary). The handlers are
/// `MCPReadTools`'s; the catalog walk (`MCPServerTests`) pins declared ⇔
/// handled.
///
/// U1 ships the READ rung: `list_books`, `list_notes`, `read_note`, `search`,
/// `export_note`. U2 adds suggest + write new; U3 edit.
struct MCPToolDeclaration: Sendable {
    let name: String
    let rung: MCPGrantRule.Rung
    let title: String
    let description: String
    let inputSchema: Value
    /// Beyond the rung: the grant shapes this tool can act under at all.
    let needsBookOrWingReach: Bool
    /// Round 1 F1: the tool serves only STANDING grants (never a once grant)
    /// — `search`. Its listing reads `Standing.searchGrants`, the SAME set
    /// the serving roads read, so a tool is never offered to a standing it
    /// can never act for (P-2 on the wire).
    var needsStandingReach: Bool = false

    /// Listed for this standing? Approved, and the open book (read) or a
    /// live grant at this rung — of a book or wing when the tool lists
    /// books, standing (non-once) when the tool never serves a once grant.
    func isListed(for standing: MCPGrantAuthority.Standing) -> Bool {
        guard standing.state == .approved else { return false }
        if standing.openBook, rung == .read { return true }
        let grants = needsStandingReach ? standing.searchGrants : standing.liveGrants
        return grants.contains { grant in
            grant.rung >= rung && (!needsBookOrWingReach || grant.scopeKind != .note)
        }
    }

    var tool: Tool {
        Tool(
            name: name, title: title, description: description, inputSchema: inputSchema,
            annotations: .init(
                title: title, readOnlyHint: rung == .read, destructiveHint: false,
                idempotentHint: rung == .read, openWorldHint: false))
    }
}

enum MCPToolCatalog {
    static let all: [MCPToolDeclaration] = [listBooks, listNotes, readNote, search, exportNote]

    static func declaration(named name: String) -> MCPToolDeclaration? {
        all.first { $0.name == name }
    }

    static func listed(for standing: MCPGrantAuthority.Standing) -> [Tool] {
        all.filter { $0.isListed(for: standing) }.map(\.tool)
    }

    // MARK: - The read rung

    static let listBooks = MCPToolDeclaration(
        name: "list_books", rung: .read, title: "List books",
        description: """
            The Variorum books shared with this client (by a book or wing grant, or the open \
            book): each book's id, name, wing and live note count. Journals and Private books \
            are never listed. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([:]),
            "additionalProperties": false,
        ]),
        needsBookOrWingReach: true)

    static let listNotes = MCPToolDeclaration(
        name: "list_notes", rung: .read, title: "List notes",
        description: """
            Notes this client can read. With book_id: that book's notes in book order. With \
            wing_id: that wing's notes, most recently edited first. With neither: every note \
            shared with this client, most recently edited first. Paged — pass next_cursor back \
            as cursor. Journal entries and Private notes appear only when shared one ask at a \
            time. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "book_id": .object(["type": "string", "description": "List this book's notes."]),
                "wing_id": .object(["type": "string", "description": "List this wing's notes (\"\" is Home)."]),
                "cursor": .object(["type": "string", "description": "next_cursor from the previous page."]),
                "limit": .object(["type": "integer", "minimum": 1, "maximum": 200,
                                  "description": "Page size (default 50)."]),
            ]),
            "additionalProperties": false,
        ]),
        needsBookOrWingReach: false)

    static let readNote = MCPToolDeclaration(
        name: "read_note", rung: .read, title: "Read a note",
        description: """
            One note in the Variorum document format: a header line with its title and tags \
            ({t:"…"} {#tag/path}), then each block's chosen take as a paragraph, followed — when \
            the block has other takes — by a "--- Alternates for this block ---" section listing \
            them. Blank lines separate blocks. Returns the text.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note's id."]),
            ]),
            "required": .array(["note_id"]),
            "additionalProperties": false,
        ]),
        needsBookOrWingReach: false)

    static let search = MCPToolDeclaration(
        name: "search", rung: .read, title: "Search",
        description: """
            Full-text search over the notes and books shared with this client (Variorum's own \
            search: every word must match, "quoted phrases" stay together, #tag/path filters by \
            tag). Narrow with book_id or note_id. Returns JSON passages: the note, the block, \
            and the words around each match (matches wrapped in **).
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "query": .object(["type": "string", "description": "What to search for."]),
                "book_id": .object(["type": "string", "description": "Search only this book."]),
                "note_id": .object(["type": "string", "description": "Search only this note."]),
                "limit": .object(["type": "integer", "minimum": 1, "maximum": 50,
                                  "description": "Most passages to return (default 20)."]),
            ]),
            "required": .array(["query"]),
            "additionalProperties": false,
        ]),
        needsBookOrWingReach: false,
        // Round 1 F1: search never serves a once grant, so a once-only
        // standing is never offered it.
        needsStandingReach: true)

    static let exportNote = MCPToolDeclaration(
        name: "export_note", rung: .read, title: "Export a note as plain text",
        description: """
            One note as plain prose: each block's chosen take, joined as the note reads — no \
            alternates, no header. Returns the text.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note's id."]),
            ]),
            "required": .array(["note_id"]),
            "additionalProperties": false,
        ]),
        needsBookOrWingReach: false)
}
