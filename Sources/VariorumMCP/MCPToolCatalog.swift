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
/// U1 shipped the READ rung (`list_books`, `list_notes`, `read_note`,
/// `search`, `export_note`); U2 adds SUGGEST (`add_take`, `add_comment`,
/// `save_lens`) and WRITE NEW (`create_note`, `import_document`, `apply_tag`,
/// `create_book`, `add_note_to_book`); U3 the EDIT rung (`edit_take`,
/// `divide_block`, `merge_blocks`, `move_block`, `delete_block`,
/// `set_block_name`) and write new's `create_section`.
struct MCPToolDeclaration: Sendable {
    let name: String
    let rung: MCPGrantRule.Rung
    let title: String
    let description: String
    let inputSchema: Value
    /// Beyond the rung: the grant SCOPE KINDS this tool can act under at all
    /// — `list_books` lists books (a note grant never names one), a note
    /// lands in a book or a wing, a book is born in a wing.
    let scopes: Set<MCPGrantRule.ScopeKind>
    /// Round 1 F1: the tool serves only STANDING grants (never a once grant)
    /// — `search`. Its listing reads `Standing.searchGrants`, the SAME set
    /// the serving roads read, so a tool is never offered to a standing it
    /// can never act for (P-2 on the wire).
    var needsStandingReach: Bool = false

    /// Listed for this standing? Approved, and the open book (read) or a
    /// live grant at this rung of a scope kind the tool acts under —
    /// standing (non-once) when the tool never serves a once grant.
    func isListed(for standing: MCPGrantAuthority.Standing) -> Bool {
        guard standing.state == .approved else { return false }
        if standing.openBook, rung == .read { return true }
        let grants = needsStandingReach ? standing.searchGrants : standing.liveGrants
        return grants.contains { grant in grant.rung >= rung && scopes.contains(grant.scopeKind) }
    }

    var tool: Tool {
        Tool(
            name: name, title: title, description: description, inputSchema: inputSchema,
            annotations: .init(
                // U3: the edit rung changes what is already there (every act
                // undoable, the delete a tombstone — but honest hints say so).
                title: title, readOnlyHint: rung == .read, destructiveHint: rung == .edit,
                idempotentHint: rung == .read, openWorldHint: false))
    }

    static let everyScope: Set<MCPGrantRule.ScopeKind> = [.note, .book, .wing]
}

enum MCPToolCatalog {
    static let read: [MCPToolDeclaration] = [listBooks, listNotes, readNote, search, exportNote]
    static let suggest: [MCPToolDeclaration] = [addTake, addComment, saveLens]
    static let writeNew: [MCPToolDeclaration] = [
        createNote, importDocument, applyTag, createBook, addNoteToBook, createSection,
    ]
    static let edit: [MCPToolDeclaration] = [
        editTake, divideBlock, mergeBlocks, moveBlock, deleteBlock, setBlockName,
    ]
    static let all: [MCPToolDeclaration] = read + suggest + writeNew + edit

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
        scopes: [.book, .wing])

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
        scopes: MCPToolDeclaration.everyScope)

    static let readNote = MCPToolDeclaration(
        name: "read_note", rung: .read, title: "Read a note",
        description: """
            One note in the Variorum document format: a header line with its title and tags \
            ({t:"…"} {#tag/path}), then each block's chosen take as a paragraph, followed — when \
            the block has other takes — by a "--- Alternates for this block ---" section listing \
            them. Blank lines separate blocks. Returns the text. With with_ids: true it returns \
            JSON instead — the note's blocks in order, each with its block_id, its name if the \
            author named it, the shown take's text, every take (take_id, label, chosen, text) and \
            its comments — the ids add_take, add_comment and save_lens address. Ids are live: the \
            author's own merges and divides make new blocks, so an id can go stale between calls \
            (a write with a stale id is refused) — read again to get current ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note's id."]),
                "with_ids": .object(["type": "boolean",
                                     "description": "Return JSON with block and take ids (default false)."]),
            ]),
            "required": .array(["note_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

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
        scopes: MCPToolDeclaration.everyScope,
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
        scopes: MCPToolDeclaration.everyScope)

    // MARK: - The SUGGEST rung (U2 — "it cannot touch a word you wrote")

    static let addTake = MCPToolDeclaration(
        name: "add_take", rung: .suggest, title: "Add a take",
        description: """
            Add a new take (an alternative text) to one block, at the END of its fan. The take is \
            labeled with this client's name (plus your label, if given), is never chosen and \
            never locked — the author's text is never touched; she chooses. Get block ids from \
            read_note with with_ids: true. Returns JSON with the new take_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to add a take to."]),
                "text": .object(["type": "string", "description": "The take's text."]),
                "label": .object(["type": "string", "description": "A short label, e.g. \"english\"."]),
            ]),
            "required": .array(["block_id", "text"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let addComment = MCPToolDeclaration(
        name: "add_comment", rung: .suggest, title: "Comment on a block",
        description: """
            Leave a working comment on one block (it shows in the block's gutter; the text is \
            untouched). Returns JSON with the comment_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to comment on."]),
                "text": .object(["type": "string", "description": "The comment."]),
            ]),
            "required": .array(["block_id", "text"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let saveLens = MCPToolDeclaration(
        name: "save_lens", rung: .suggest, title: "Save a lens",
        description: """
            Save a named lens on a note: a way of reading it that shows the given takes in place \
            of the chosen ones (at most one take per block; other blocks show their chosen take). \
            A lens never changes what the note shows by default. Returns JSON with the lens_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note."]),
                "name": .object(["type": "string", "description": "The lens's name."]),
                "take_ids": .object(["type": "array", "items": .object(["type": "string"]),
                                     "description": "The takes the lens shows, one per block."]),
            ]),
            "required": .array(["note_id", "name", "take_ids"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    // MARK: - The WRITE NEW rung (U2 — "make new notes, apply tags and build books")

    static let createNote = MCPToolDeclaration(
        name: "create_note", rung: .writeNew, title: "Create a note",
        description: """
            Create a new note from plain text (each paragraph becomes a block) inside a shared \
            book (book_id — it joins the book at its end) or a shared wing (wing_id; "" is Home — \
            it lands bookless). Returns JSON with the note_id and its block_ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "title": .object(["type": "string", "description": "The note's title."]),
                "text": .object(["type": "string", "description": "The note's text."]),
                "book_id": .object(["type": "string", "description": "Create it in this book."]),
                "wing_id": .object(["type": "string", "description": "Create it bookless in this wing."]),
            ]),
            "required": .array(["text"]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let importDocument = MCPToolDeclaration(
        name: "import_document", rung: .writeNew, title: "Import a document",
        description: """
            Import text in the Variorum document format (what read_note returns): a header \
            {t:"title"} {#tag/path}, paragraphs as blocks, "--- Alternates for this block ---" \
            sections as extra takes. Either one `document` into a shared book (book_id) or wing \
            (wing_id), or a whole `book` {name, chapters: [{name, documents}], documents} into a \
            shared wing. One import is one undo for the author. Returns JSON with the new ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "document": .object(["type": "string", "description": "One note in the format."]),
                "book": .object([
                    "type": "object",
                    "description": "A whole book: its name, its chapters' documents, and unfiled documents.",
                    "properties": .object([
                        "name": .object(["type": "string"]),
                        "chapters": .object(["type": "array", "items": .object([
                            "type": "object",
                            "properties": .object([
                                "name": .object(["type": "string"]),
                                "documents": .object(["type": "array", "items": .object(["type": "string"])]),
                            ]),
                        ])]),
                        "documents": .object(["type": "array", "items": .object(["type": "string"])]),
                    ]),
                ]),
                "book_id": .object(["type": "string", "description": "Import the document into this book."]),
                "wing_id": .object(["type": "string", "description": "Import into this wing (\"\" is Home)."]),
            ]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let applyTag = MCPToolDeclaration(
        name: "apply_tag", rung: .writeNew, title: "Tag a note",
        description: """
            Apply a tag to a note by its path (e.g. "percy/pt-en"); a missing tag is created in the \
            note's wing. Books that collect by that tag hear it, as when the author tags. Returns \
            JSON with the tag_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note."]),
                "tag": .object(["type": "string", "description": "The tag's path."]),
            ]),
            "required": .array(["note_id", "tag"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let createBook = MCPToolDeclaration(
        name: "create_book", rung: .writeNew, title: "Create a book",
        description: """
            Create a new, empty book in a shared wing ("" is Home). Returns JSON with the book_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "name": .object(["type": "string", "description": "The book's name."]),
                "wing_id": .object(["type": "string", "description": "The wing (\"\" is Home)."]),
            ]),
            "required": .array(["name", "wing_id"]),
            "additionalProperties": false,
        ]),
        scopes: [.wing])

    static let addNoteToBook = MCPToolDeclaration(
        name: "add_note_to_book", rung: .writeNew, title: "Add a note to a book",
        description: """
            Add a note to a book (at its end), optionally filed under one of the book's chapters \
            (section_id — from list_notes or create_section). Both must be shared with this client \
            at write new. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note."]),
                "book_id": .object(["type": "string", "description": "The book."]),
                "section_id": .object(["type": "string", "description": "File it under this chapter of the book."]),
            ]),
            "required": .array(["note_id", "book_id"]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let createSection = MCPToolDeclaration(
        name: "create_section", rung: .writeNew, title: "Add a chapter",
        description: """
            Add a chapter (a section) at the end of a shared book's chapter order. Notes are filed \
            under it with add_note_to_book's section_id. Returns JSON with the section_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "book_id": .object(["type": "string", "description": "The book."]),
                "name": .object(["type": "string", "description": "The chapter's name."]),
            ]),
            "required": .array(["book_id", "name"]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    // MARK: - The EDIT rung (U3 — "it can also edit takes — with a commit before and after every change")

    static let editTake = MCPToolDeclaration(
        name: "edit_take", rung: .edit, title: "Edit a take",
        description: """
            Replace one take's text. expected_text must be the take's text EXACTLY as you read it \
            (read_note with with_ids: true) — if the author changed it since, the edit is refused and \
            nothing is written; read again. Variorum saves a commit named "before <your name>'s edit" \
            and one named "after <your name>'s edit", so the author can always compare and come back, \
            and the edit is one undo for her. Returns JSON with the commit ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "take_id": .object(["type": "string", "description": "The take to edit."]),
                "text": .object(["type": "string", "description": "The take's whole new text."]),
                "expected_text": .object(["type": "string", "description": "The take's current text, exactly as read."]),
            ]),
            "required": .array(["take_id", "text", "expected_text"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let divideBlock = MCPToolDeclaration(
        name: "divide_block", rung: .edit, title: "Divide a block",
        description: """
            Divide one block in two, at the place in its shown take where second_half_starts_with \
            begins (those words must appear exactly once in that text). A block with other takes \
            divides the way the author's own divide does: the shown take splits, and every other \
            take stays whole on the first block. The halves are new blocks — ids change; read again. \
            Returns JSON with both block ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to divide."]),
                "second_half_starts_with": .object([
                    "type": "string", "description": "The words the second block begins with.",
                ]),
            ]),
            "required": .array(["block_id", "second_half_starts_with"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let mergeBlocks = MCPToolDeclaration(
        name: "merge_blocks", rung: .edit, title: "Merge two blocks",
        description: """
            Merge two ADJACENT blocks of one note (first_block_id directly before second_block_id) \
            into one new block, joined by a newline. Where either has other takes, every take comes \
            along (the two shown takes are joined; the rest ride whole), as the author's own merge \
            does. The two sources stay in the note's history; the merged block has a NEW id. \
            Returns JSON with its block_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "first_block_id": .object(["type": "string", "description": "The earlier block."]),
                "second_block_id": .object(["type": "string", "description": "The block right after it."]),
            ]),
            "required": .array(["first_block_id", "second_block_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let moveBlock = MCPToolDeclaration(
        name: "move_block", rung: .edit, title: "Move a block",
        description: """
            Move a block: right after another block (after_block_id), right before one \
            (before_block_id), or to the start or end of a note (note_id, with at: "start" or \
            "end"; default end). Either note must be shared with this client at edit. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to move."]),
                "after_block_id": .object(["type": "string", "description": "Put it right after this block."]),
                "before_block_id": .object(["type": "string", "description": "Put it right before this block."]),
                "note_id": .object(["type": "string", "description": "Put it in this note (with at)."]),
                "at": .object(["type": "string", "enum": .array(["start", "end"]),
                               "description": "Where in note_id (default end)."]),
            ]),
            "required": .array(["block_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let deleteBlock = MCPToolDeclaration(
        name: "delete_block", rung: .edit, title: "Delete a block",
        description: """
            Delete one block. Nothing is destroyed: it goes to the note's tray of deleted things, \
            every take with it, where the author can put it back (and it is one undo for her). \
            Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to delete."]),
            ]),
            "required": .array(["block_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let setBlockName = MCPToolDeclaration(
        name: "set_block_name", rung: .edit, title: "Name a block",
        description: """
            Give a block a name ("the opening") — a handle for talking about it; ids stay the only \
            address. A blank or null name clears it. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block."]),
                "name": .object(["type": ["string", "null"], "description": "The name (blank or null clears)."]),
            ]),
            "required": .array(["block_id", "name"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)
}
