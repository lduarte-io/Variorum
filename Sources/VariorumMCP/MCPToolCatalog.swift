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

/// **13n-c UX walk W-UX-14 — the catalog's scope facts, read by the app's
/// grant faces' truth pin.** The ask sheet and the grant sheet say what a rung
/// lets a client do AT A SCOPE ("it can also make new notes and chapters in
/// it…"); a sentence that names a tool the scope can never act under is an
/// overclaim (a book grant can never build a book — `create_book` is
/// wing-only). One public read, so the pin ties each claim to the catalog.
public enum MCPToolFacts {
    /// The grant scope kinds the named tool acts under (nil: no such tool).
    public static func scopes(of tool: String) -> Set<MCPGrantRule.ScopeKind>? {
        MCPToolCatalog.declaration(named: tool)?.scopes
    }

    /// The rung the named tool needs (nil: no such tool).
    public static func rung(of tool: String) -> MCPGrantRule.Rung? {
        MCPToolCatalog.declaration(named: tool)?.rung
    }

    /// Every tool's name, in the catalog's order (W-UX-13: the Activity list's
    /// words are pinned against EVERY tool — none may say a raw tool id).
    public static var toolNames: [String] { MCPToolCatalog.all.map(\.name) }
}

enum MCPToolCatalog {
    static let read: [MCPToolDeclaration] = [listBooks, listNotes, readNote, search, exportNote]
    static let suggest: [MCPToolDeclaration] = [
        addTake, addComment, saveLens,
        // VX-184 U3 — VX-173's batch doors (one note, one act, the cap stated).
        addTakes, addComments,
    ]
    static let writeNew: [MCPToolDeclaration] = [
        createNote, importDocument, applyTag, createBook, addNoteToBook, createSection,
        // U4 — the carriage (R-13nb-18, R-13nb-26 f, P-13nb-U3-8 → PROVISIONAL).
        saveVersion, fileNoteInChapter, setBookRule,
    ]
    static let edit: [MCPToolDeclaration] = [
        editTake, divideBlock, mergeBlocks, moveBlock, deleteBlock, setBlockName,
        // U4 — the tray's Put back (R-13nb-14) and the date (R-13nb-26 b).
        putBack, setEntryDate,
        // 13n-c U6 — the per-item note move across wings (VX-160, R-AIR-2).
        moveNoteToWing,
        // VX-168 U2 — the deliberate acts: VX-169's commit (her settlement:
        // edit) and VX-174's merge button (R-MERGE-1: edit).
        saveCommit, chooseTake, adoptLens,
    ]
    /// U4 (R-13nb-23, AF-11 F-3): the read rung's one navigation tool —
    /// its own handler (it awaits the app), its own list.
    static let navigation: [MCPToolDeclaration] = [showInApp]
    static let all: [MCPToolDeclaration] = read + navigation + suggest + writeNew + edit

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
            book): each book's id, name, wing and live note count, and how it collects — its rule \
            (tags by path: {"tag": "percy"}, {"star": true}, combined with {"and": […]}, {"or": […]}, \
            {"not": …}), its outflow (the tags notes written there wear), new_matches ("join" or \
            "wait" at Arrivals), word_target / max_notes, and whether it is finished, sealed, owned \
            or collecting now. Archived books appear only with include_archived: true. The daily \
            Journal and Private books are never listed. A wing shared with you (or the open book) also \
            lists its gatherings (kind "gathering"): saved rules that gather notes by tag or star, \
            read-only — list_notes and search take their id like a book's. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "include_archived": .object(["type": "boolean",
                                             "description": "Also list archived books (default false)."]),
            ]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let listNotes = MCPToolDeclaration(
        name: "list_notes", rung: .read, title: "List notes",
        description: """
            Notes this client can read. With book_id: that book's notes in book order, each with \
            the chapter it is filed under (section_id, section_name) when it has one — or a \
            gathering's notes, in its own order. With \
            wing_id: that wing's notes, most recently edited first. With neither: every note \
            shared with this client, most recently edited first. Paged — pass next_cursor back \
            as cursor. Archived notes appear only with include_archived: true (marked archived). \
            Daily Journal entries and Private notes appear only when shared one ask at a time. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "include_archived": .object(["type": "boolean",
                                             "description": "Also list archived notes (default false)."]),
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
            them. Blank lines separate blocks — except in format v2: when a block holds blank lines \
            of its own, the header starts with {v:2} and a "--- next block ---" line separates the \
            blocks instead. Returns the text. With with_ids: true it returns \
            JSON instead — the note's blocks in order, each with its block_id, its name if the \
            author named it, shown_take_id (the take the block shows), every take (take_id, label, \
            chosen, text — each text once, on its take) and its comments — the ids add_take, \
            add_comment and save_lens address — plus the note's \
            entry_date and the books (and chapters) holding it that you can read. Ids are live: the \
            author's own merges and divides make new blocks, so an id can go stale between calls \
            (a write with a stale id is refused) — read again to get current ids. with_commits: true \
            adds each take's commits (saved moments), newest first, with their text; past about \
            100,000 characters of commit text, older ones say text_omitted — fetch those by \
            commit_ids (up to 20 per call). More, each by asking: include_archived: true (archived \
            takes join each block's takes, marked archived); with_tray: true (the note's tray — \
            deleted blocks and takes, kept 30 days; put_back restores one); with_lineage: true \
            (each block's lineage — what it was divided, merged or copied from or into — and each \
            take's parent_take_id; a relative outside what you can read shows only \
            beyond_grant); with_lenses: true (its saved lenses and the take each shows per block); \
            with_versions: true (its saved versions — version_id reads one, in either form). \
            lens_id reads the note through one of its lenses, in either form: each block shows the \
            take the lens shows there, else its chosen take; with with_ids each block's \
            shown_take_id is that take and via says which ("lens" or "chosen"), and chosen still \
            marks the note's own chosen take.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note's id."]),
                "with_ids": .object(["type": "boolean",
                                     "description": "Return JSON with block and take ids (default false)."]),
                "with_commits": .object(["type": "boolean",
                                         "description": "Add each take's commits (implies with_ids)."]),
                "commit_ids": .object(["type": "array", "items": .object(["type": "string"]), "maxItems": 20,
                                       "description": "Commits whose full text to include (implies with_ids)."]),
                "include_archived": .object(["type": "boolean",
                                             "description": "Include archived takes (implies with_ids)."]),
                "with_tray": .object(["type": "boolean",
                                      "description": "Add the note's tray of deleted things (implies with_ids)."]),
                "with_lineage": .object(["type": "boolean",
                                         "description": "Add lineage and take ancestry (implies with_ids)."]),
                "with_lenses": .object(["type": "boolean",
                                        "description": "Add the note's saved lenses (implies with_ids)."]),
                "with_versions": .object(["type": "boolean",
                                          "description": "Add the note's saved versions (implies with_ids)."]),
                "version_id": .object(["type": "string",
                                       "description": "Read this saved version of the note instead."]),
                "lens_id": .object(["type": "string",
                                    "description": "Read the note through this lens of it (with_lenses lists them)."]),
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
            tag). Narrow with book_id (a book or a gathering) or note_id. include_commits: true also \
            searches commits (saved \
            moments' text) — those passages carry a commit_id and saved_at. include_archived: true \
            also searches archived notes, books and takes (marked archived). Returns JSON passages: \
            the note, the block, and the words around each match (matches wrapped in **).
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "query": .object(["type": "string", "description": "What to search for."]),
                "book_id": .object(["type": "string", "description": "Search only this book."]),
                "note_id": .object(["type": "string", "description": "Search only this note."]),
                "include_commits": .object(["type": "boolean",
                                            "description": "Also search commits (default false)."]),
                "include_archived": .object(["type": "boolean",
                                             "description": "Also search archived things (default false)."]),
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
            never locked — the author's text is never touched; they choose. Get block ids from \
            read_note with with_ids: true. Returns JSON with the new take_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "The block to add a take to."]),
                "text": .object(["type": "string", "description": """
                    The take's text. An empty text adds a blank take: a lens that shows it shows the \
                    block as an empty line.
                    """]),
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

    /// VX-184 U3 (VX-173): `add_take` as ONE act for many blocks of one note.
    static let addTakes = MCPToolDeclaration(
        name: "add_takes", rung: .suggest, title: "Add takes to many blocks",
        description: """
            Add many takes in one act: each item adds a new take (an alternative text) to one block \
            of note_id, at the END of that block's fan, exactly as add_take does — labeled with this \
            client's name (plus the item's label, if given), never chosen and never locked; an \
            empty text adds a blank take. Every block must be a block of that note (read_note with \
            with_ids: true gives the ids). One call carries at most 200 takes. All or nothing: if \
            any item can't land, none does, and the refusal names the item. The whole batch is one \
            undo for the author. Returns JSON with the new take_ids, in the items' order.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note every block belongs to."]),
                "takes": .object([
                    "type": "array", "minItems": 1, "maxItems": .int(MCPWriteTools.batchCap),
                    "description": "The takes, in order (at most 200).",
                    "items": .object([
                        "type": "object",
                        "properties": .object([
                            "block_id": .object(["type": "string", "description": "The block to add this take to."]),
                            "text": .object(["type": "string",
                                             "description": "The take's text (empty: a blank take)."]),
                            "label": .object(["type": "string", "description": "A short label, e.g. \"english\"."]),
                        ]),
                        "required": .array(["block_id", "text"]),
                    ]),
                ]),
            ]),
            "required": .array(["note_id", "takes"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    /// VX-184 U3 (VX-173): `add_comment` as ONE act for many blocks of one note.
    static let addComments = MCPToolDeclaration(
        name: "add_comments", rung: .suggest, title: "Comment on many blocks",
        description: """
            Leave many working comments in one act, each on one block of note_id (it shows in the \
            block's gutter; the text is untouched), exactly as add_comment does. Every block must be \
            a block of that note. One call carries at most 200 comments. All or nothing: if any \
            item can't land, none does, and the refusal names the item. The whole batch is one undo \
            for the author. Returns JSON with the new comment_ids, in the items' order.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note every block belongs to."]),
                "comments": .object([
                    "type": "array", "minItems": 1, "maxItems": .int(MCPWriteTools.batchCap),
                    "description": "The comments, in order (at most 200).",
                    "items": .object([
                        "type": "object",
                        "properties": .object([
                            "block_id": .object(["type": "string", "description": "The block to comment on."]),
                            "text": .object(["type": "string", "description": "The comment."]),
                        ]),
                        "required": .array(["block_id", "text"]),
                    ]),
                ]),
            ]),
            "required": .array(["note_id", "comments"]),
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
            Create a new note inside a shared book (book_id — it joins the book at its end) or a \
            shared wing (wing_id; "" is Home — it lands bookless). Give EITHER text (plain prose: \
            each paragraph becomes a block) OR blocks (structured: each block's shown text exactly \
            — a blank line inside it stays inside the one block — with an optional name and its \
            other takes, each with an optional label). entry_date (yyyy-MM-dd) sets the \
            note's date, e.g. for old journal entries. Returns JSON with the note_id and its block_ids.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "title": .object(["type": "string", "description": "The note's title."]),
                "text": .object(["type": "string", "description": "The note's text, as plain prose."]),
                "blocks": .object([
                    "type": "array",
                    "description": "The note's blocks, in order (instead of text).",
                    "items": .object([
                        "type": "object",
                        "properties": .object([
                            "text": .object(["type": "string", "description": "The block's shown text."]),
                            "name": .object(["type": "string", "description": "A name for the block."]),
                            "takes": .object([
                                "type": "array",
                                "description": "Other takes, joining the block's fan (never chosen).",
                                "items": .object([
                                    "type": "object",
                                    "properties": .object([
                                        "text": .object(["type": "string",
                                                         "description": "The take's text (empty: a blank take)."]),
                                        "label": .object(["type": "string"]),
                                    ]),
                                    "required": .array(["text"]),
                                ]),
                            ]),
                        ]),
                        "required": .array(["text"]),
                    ]),
                ]),
                "entry_date": .object(["type": "string", "description": "The note's date, yyyy-MM-dd."]),
                "book_id": .object(["type": "string", "description": "Create it in this book."]),
                "wing_id": .object(["type": "string", "description": "Create it bookless in this wing."]),
            ]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let importDocument = MCPToolDeclaration(
        name: "import_document", rung: .writeNew, title: "Import a document",
        description: """
            Import text in the Variorum document format (what read_note returns): a header \
            {t:"title"} {#tag/path}, paragraphs as blocks, "--- Alternates for this block ---" \
            sections as extra takes; with {v:2} first in the header, "--- next block ---" lines \
            separate the blocks and blank lines stay inside them. Either one `document` into a shared book (book_id) or wing \
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
            and the edit is one undo for the author. Returns JSON with the commit ids.
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
            "end"; default end). Both notes must be shared with this client at edit, and in the same \
            wing. Returns JSON.
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
            every take with it, where the author can put it back (and it is one undo for them). \
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

    /// 13n-c U6 (VX-160 — R-AIR-2/-9, the brief §10's R1 · T1 · U1): the
    /// author's own Move to Wing, on the wire. Listed at EDIT (the source's
    /// rung) under any scope kind: a client short on the destination's write
    /// new is still offered it, and its refusal raises that wing's ask.
    static let moveNoteToWing = MCPToolDeclaration(
        name: "move_note_to_wing", rung: .edit, title: "Move a note to another wing",
        description: """
            Move a note to another wing (wing_id; "" is Home) — each wing is a separate library, \
            so the note leaves every book it is in here, lands bookless in that wing's Pool, and \
            its tags come with it (a tag the other wing lacks is made there by its path). Needs \
            edit on the note and write new on the wing it goes to. A note in a finished or sealed \
            book can't move until the author reopens it. One undo for the author puts it back, \
            books and tags too. Returns JSON: where it landed, the books it left (named where you \
            can read them) and the tags adopted or made.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note to move."]),
                "wing_id": .object(["type": "string", "description": "The wing it goes to (\"\" is Home)."]),
            ]),
            "required": .array(["note_id", "wing_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    // MARK: - VX-168 U2 — the deliberate acts (VX-169 save_commit; VX-174 the merge button)

    /// VX-169 (her settlement, the 2026-10-12 pre-run sitting): a client
    /// commits a take with its own message — EDIT ("whoever may edit a take
    /// may commit it"), `kind='manual'`, the name prefixed. Append-only: the
    /// one write the author's undo never walks back, as their own commits.
    static let saveCommit = MCPToolDeclaration(
        name: "save_commit", rung: .edit, title: "Commit a take",
        description: """
            Commit one take: save its text as it stands now as a commit (a saved moment the author \
            can compare against and come back to), with your message. The commit is stored as \
            "<your name>: <message>", so the author's history says who saved it. The take's text \
            does not change. A commit is kept for good: the author's undo does not remove it, as \
            it does not remove their own. Get take ids from read_note with with_ids: true. \
            Returns JSON with the commit_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "take_id": .object(["type": "string", "description": "The take to commit."]),
                "message": .object(["type": "string", "description": "What this moment is, e.g. \"fact-checked\"."]),
            ]),
            "required": .array(["take_id", "message"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    /// VX-174 (R-MERGE-1): her ✓ on a take — the pointer moves, no text is
    /// written.
    static let chooseTake = MCPToolDeclaration(
        name: "choose_take", rung: .edit, title: "Choose a take",
        description: """
            Choose one take of a block, so the note shows that take there — as the author does \
            when choosing between takes. No text changes: the take the block showed before stays \
            among its takes, and the choice is one undo for the author. Choosing the take already \
            shown changes nothing. Get take ids from read_note with with_ids: true. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "take_id": .object(["type": "string", "description": "The take the block should show."]),
            ]),
            "required": .array(["take_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    /// VX-174 (R-MERGE-1): her "✓ Make this the note" on a lens column —
    /// adopting SWAPS, never destroys (R92): what the note showed is kept as
    /// a lens.
    static let adoptLens = MCPToolDeclaration(
        name: "adopt_lens", rung: .edit, title: "Make a lens the note",
        description: """
            Make a saved lens the note: every block where the lens shows a take now shows that \
            take, as the author's own "Make this the note" does. What the note showed before is \
            kept as a new lens named "chosen until <date>", so nothing is lost, and the whole \
            change is one undo for the author. A lens that already agrees with the note changes \
            nothing. Get lens ids from read_note with with_lenses: true. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "lens_id": .object(["type": "string", "description": "The lens to make the note."]),
            ]),
            "required": .array(["lens_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    // MARK: - U4 — the carriage's write tools (R-13nb-14/18, R-13nb-26 b/f; AF-11)

    static let putBack = MCPToolDeclaration(
        name: "put_back", rung: .edit, title: "Put back from the tray",
        description: """
            Put a deleted block (block_id) or a deleted take (take_id) back from its note's tray \
            (read_note with with_tray: true lists them; they wait there 30 days). A block returns \
            to its own place in the note; a take to its block's takes. One undo for the author. \
            Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "block_id": .object(["type": "string", "description": "A deleted block from the tray."]),
                "take_id": .object(["type": "string", "description": "A deleted take from the tray."]),
            ]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let setEntryDate = MCPToolDeclaration(
        name: "set_entry_date", rung: .edit, title: "Set a note's date",
        description: """
            Set a note's date (entry_date, yyyy-MM-dd — e.g. bringing in an old journal entry), or \
            clear it with null. One undo for the author. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note."]),
                "entry_date": .object(["type": ["string", "null"], "description": "yyyy-MM-dd, or null to clear."]),
            ]),
            "required": .array(["note_id", "entry_date"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let saveVersion = MCPToolDeclaration(
        name: "save_version", rung: .writeNew, title: "Save a version of a note",
        description: """
            Save the whole note as it is now as a version (the author's Note ▸ Versions — an \
            edition they can come back to). Nothing in the note changes. read_note with \
            with_versions: true lists them. Returns JSON with the version_id.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note."]),
            ]),
            "required": .array(["note_id"]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)

    static let fileNoteInChapter = MCPToolDeclaration(
        name: "file_note_in_chapter", rung: .writeNew, title: "File a note under a chapter",
        description: """
            File a note that is already in a book under one of that book's chapters (section_id — \
            from list_notes or create_section), or unfile it with null. Its place in the book is \
            unchanged. Returns JSON.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "note_id": .object(["type": "string", "description": "The note (a member of the book)."]),
                "book_id": .object(["type": "string", "description": "The book."]),
                "section_id": .object(["type": ["string", "null"], "description": "The chapter, or null to unfile."]),
            ]),
            "required": .array(["note_id", "book_id", "section_id"]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    static let setBookRule = MCPToolDeclaration(
        name: "set_book_rule", rung: .writeNew, title: "Set what a book collects",
        description: """
            Change how a book collects, as the author's rule editor does — any of: rule (tags by \
            path, e.g. {"or": [{"tag": "percy"}, {"tag": "percy/pt-en"}]}; {"star": true} for \
            starred; {"not": …}; null clears it), outflow (the tag paths notes written in the book \
            wear; [] clears), new_matches ("join" quietly at the end, or "wait" at Arrivals). A \
            missing tag is created in the book's wing. A finished or archived book keeps the \
            change and collects again when the author reopens it. One undo for the author. \
            Returns JSON with the book's collecting facts.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "book_id": .object(["type": "string", "description": "The book."]),
                "rule": .object(["description": "The rule (one term), or null to clear."]),
                "outflow": .object(["type": "array", "items": .object(["type": "string"]),
                                    "description": "Tag paths, in order."]),
                "new_matches": .object(["type": "string", "enum": .array(["join", "wait"]),
                                        "description": "Join quietly at the end, or wait at Arrivals."]),
            ]),
            "required": .array(["book_id"]),
            "additionalProperties": false,
        ]),
        scopes: [.book, .wing])

    // MARK: - U4 — navigation (R-13nb-23 + R-13nb-26 (g); AF-11 F-3)

    static let showInApp = MCPToolDeclaration(
        name: "show_in_app", rung: .read, title: "Show in Variorum",
        description: """
            Move the author's Variorum window to something you want them to see — ONLY when they \
            ask you to show them, never on your own (it moves nothing unless Variorum is the app \
            in front, and never raises a window). target "note" (note_id; block_id lands on that \
            block, and select — words in that block's shown take — selects them with the find \
            bar ready), "takes" (note_id + block_id: the note's Takes, that block's takes open), \
            "lens" (note_id + lens_id: the Lenses board showing that lens), "book" (book_id, \
            optionally section_id: that chapter) or "wing" (wing_id; "" is Home: Variorum switches \
            to that wing, as its own wing switcher does). Returns JSON, or why nothing moved.
            """,
        inputSchema: .object([
            "type": "object",
            "properties": .object([
                "target": .object(["type": "string", "enum": .array(["note", "takes", "lens", "book", "wing"]),
                                   "description": "What to show (default note)."]),
                "note_id": .object(["type": "string"]),
                "block_id": .object(["type": "string"]),
                "select": .object(["type": "string", "description": "Words to select in the block's shown take."]),
                "lens_id": .object(["type": "string"]),
                "book_id": .object(["type": "string"]),
                "section_id": .object(["type": "string", "description": "A chapter of the book."]),
                "wing_id": .object(["type": "string", "description": "The wing (\"\" is Home)."]),
            ]),
            "additionalProperties": false,
        ]),
        scopes: MCPToolDeclaration.everyScope)
}
