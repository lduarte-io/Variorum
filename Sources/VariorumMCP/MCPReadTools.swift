import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE READ RUNG's tool projections** (13n-b U1 — R-13n-4's "read + search
/// within scope"; the mockup §9). Thin projections of the queries the app
/// itself reads through — `read_note` IS `Queries.variorumDocumentText` (the
/// Level 0 format), `export_note` IS `Queries.renderedText`, `search` IS the
/// 13o engine (`Queries.searchPassages`) — each gated PER CALL by the pure
/// rule over CURRENT facts, inside ONE write transaction that also spends a
/// once grant and records the coarse activity line, so a once grant can never
/// be read twice and every refusal is logged.
///
/// P1: every call costs ∝ its scope — a book's members, a wing's page by the
/// recency index, the grants' own candidates, the search engine's matches —
/// never the corpus.
struct MCPReadTools: Sendable {
    let database: AppDatabase
    let operations: Operations
    var calendar: Calendar = JournalDay.storeCalendar

    struct Outcome: Equatable, Sendable {
        let text: String
        let isError: Bool
    }

    static let defaultPageSize = 50
    static let maxPageSize = 200
    static let defaultSearchLimit = 20
    static let maxSearchLimit = 50

    /// Route one `tools/call`. Unknown names answer as an error; a KNOWN tool
    /// the client cannot use answers with the rule's own refusal (the list is
    /// a courtesy — the rule is the boundary).
    func call(_ name: String, arguments: [String: Value]?, clientName: String) -> Outcome {
        let args = arguments ?? [:]
        do {
            switch name {
            case MCPToolCatalog.listBooks.name: return try listBooks(clientName: clientName)
            case MCPToolCatalog.listNotes.name: return try listNotes(args, clientName: clientName)
            case MCPToolCatalog.readNote.name: return try readNote(args, clientName: clientName, plain: false)
            case MCPToolCatalog.exportNote.name: return try readNote(args, clientName: clientName, plain: true)
            case MCPToolCatalog.search.name: return try search(args, clientName: clientName)
            default: return Outcome(text: "Unknown tool: \(name).", isError: true)
            }
        } catch let failure as ArgumentFailure {
            return Outcome(text: failure.message, isError: true)
        } catch {
            return Outcome(text: "Variorum couldn't complete \(name): \(error)", isError: true)
        }
    }

    static let handledToolNames: Set<String> = ["list_books", "list_notes", "read_note", "export_note", "search"]

    // MARK: - read_note / export_note

    private func readNote(_ args: [String: Value], clientName: String, plain: Bool) throws -> Outcome {
        let noteID = try requiredString(args, "note_id")
        let act = plain ? MCPToolCatalog.exportNote.name : MCPToolCatalog.readNote.name
        return try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
            guard case .allow(let grantID, let consumesOnce) = decision else {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                return refusal(decision, .note)
            }
            if consumesOnce, let grantID { try operations.consumeMCPOnceGrant(db, grantID) }
            let text = plain
                ? try Queries.renderedText(db, containerID: noteID)
                : try Queries.variorumDocumentText(db, postID: noteID)
            try log(db, clientName, act, "note", noteID, title, allowed: true)
            return Outcome(text: text, isError: false)
        }
    }

    // MARK: - list_books

    private func listBooks(clientName: String) throws -> Outcome {
        try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard standing.state == .approved else {
                try log(db, clientName, MCPToolCatalog.listBooks.name, nil, nil, nil, allowed: false)
                return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .book)
            }
            let live = standing.liveGrants
            let bookIDs = live.filter { $0.scopeKind == .book }.map(\.scopeID)
            let wingIDs = live.filter { $0.scopeKind == .wing }.map(\.scopeID)
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT r.id, r.name, r.archived_at IS NOT NULL AS archived,
                           \(Self.resolvedWing("r.wing_id")) AS wing
                    FROM reading r
                    WHERE r.deleted_at IS NULL AND r.kind = 'book'
                      AND (:all OR r.id IN (SELECT value FROM json_each(:books))
                           OR \(Self.resolvedWing("r.wing_id")) IN (SELECT value FROM json_each(:wings)))
                    ORDER BY r.name COLLATE NOCASE, r.id
                    """,
                arguments: ["all": standing.openBook, "books": try json(bookIDs), "wings": try json(wingIDs)])
            var books: [[String: Any]] = []
            for row in rows {
                let id: String = row["id"]
                let decision = MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: id), rung: .read)
                guard decision.isAllowed else { continue }
                let wing: String = row["wing"]
                books.append([
                    "id": id, "name": row["name"] as String, "archived": row["archived"] as Bool,
                    "wing": try Queries.mcpScopeTitle(db, kind: .wing, id: wing) ?? Queries.mcpHomeWingName,
                    "wing_id": wing,
                    "notes": try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM reading_post rp JOIN container c ON c.id = rp.post_id
                            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                              AND c.deleted_at IS NULL
                            """,
                        arguments: [id]) ?? 0,
                ])
            }
            try log(db, clientName, MCPToolCatalog.listBooks.name, nil, nil, nil, allowed: true)
            return Outcome(text: try encode(["books": books]), isError: false)
        }
    }

    // MARK: - list_notes

    private func listNotes(_ args: [String: Value], clientName: String) throws -> Outcome {
        let limit = min(max(try optionalInt(args, "limit") ?? Self.defaultPageSize, 1), Self.maxPageSize)
        let cursor = try optionalString(args, "cursor").flatMap(PageCursor.init(encoded:))
        if try optionalString(args, "cursor") != nil, cursor == nil {
            throw ArgumentFailure(message: "cursor is not a next_cursor this server returned.")
        }
        let bookID = try optionalString(args, "book_id")
        let wingID = try optionalString(args, "wing_id")
        guard bookID == nil || wingID == nil else {
            throw ArgumentFailure(message: "Pass book_id or wing_id, not both.")
        }
        let act = MCPToolCatalog.listNotes.name
        return try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            var page: [PageRow]
            if let bookID {
                let decision = MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .read)
                guard decision.isAllowed else {
                    try log(db, clientName, act, "book", bookID, nil, allowed: false)
                    return refusal(decision, .book)
                }
                page = try bookPage(db, bookID: bookID, after: cursor, limit: limit)
            } else if let wingID {
                let decision = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .read)
                guard decision.isAllowed else {
                    try log(db, clientName, act, "wing", wingID, nil, allowed: false)
                    return refusal(decision, .wing)
                }
                page = try recencyPage(db, wingID: wingID, candidates: nil, after: cursor, limit: limit)
            } else {
                guard standing.state == .approved else {
                    try log(db, clientName, act, nil, nil, nil, allowed: false)
                    return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .note)
                }
                page = try sharedPage(db, standing: standing, after: cursor, limit: limit)
            }
            let full = page.count == limit
            let facts = try Queries.mcpNoteFacts(db, noteIDs: page.map(\.id))
            var notes: [[String: Any]] = []
            for row in page {
                let decision = MCPGrantAuthority.decide(standing, note: facts[row.id], rung: .read, consumes: false)
                guard decision.isAllowed, let noteFacts = facts[row.id] else { continue }
                notes.append([
                    "id": row.id, "title": row.title, "edited": row.touched,
                    "book_ids": noteFacts.bookIDs.sorted(), "wing_id": noteFacts.wingID,
                ])
            }
            try log(db, clientName, act, bookID != nil ? "book" : (wingID != nil ? "wing" : nil),
                    bookID ?? wingID, nil, allowed: true)
            var answer: [String: Any] = ["notes": notes]
            if full, let last = page.last { answer["next_cursor"] = last.cursor.encoded }
            return Outcome(text: try encode(answer), isError: false)
        }
    }

    /// One listed note before the rule's per-note pass.
    private struct PageRow {
        let id: String
        let title: String
        let touched: String
        let cursor: PageCursor
    }

    /// A book's live member notes in book order, keyset-paged on
    /// `(position, post id)` — ∝ the page.
    private func bookPage(_ db: Database, bookID: String, after cursor: PageCursor?, limit: Int) throws -> [PageRow] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.title, c.entry_date, c.created_at,
                       COALESCE(c.last_touched_at, c.created_at) AS touched, rp.position
                FROM reading_post rp JOIN container c ON c.id = rp.post_id
                WHERE rp.reading_id = :book AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND c.deleted_at IS NULL AND c.kind = 'post'
                  AND (:after IS NULL OR (rp.position, c.id) > (:after, :afterID))
                ORDER BY rp.position, c.id
                LIMIT :limit
                """,
            arguments: ["book": bookID, "after": cursor?.key, "afterID": cursor?.id ?? "", "limit": limit]
        ).map { row in
            PageRow(id: row["id"], title: displayTitle(row), touched: row["touched"],
                    cursor: PageCursor(key: row["position"], id: row["id"]))
        }
    }

    /// Living (unarchived) notes by recency, keyset-paged on `(touched, id)`:
    /// a whole wing through the recency index, or — when `candidates` is
    /// given — only those ids (cost ∝ the candidates, never the corpus).
    private func recencyPage(
        _ db: Database, wingID: String?, candidates: [String]?, after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow] {
        var clauses: [String] = [
            "c.deleted_at IS NULL", "c.kind = 'post'", "c.archived_at IS NULL",
            "(:after IS NULL OR (COALESCE(c.last_touched_at, c.created_at), c.id) < (:after, :afterID))",
        ]
        var arguments: [String: (any DatabaseValueConvertible)?] = [
            "after": cursor?.key, "afterID": cursor?.id ?? "", "limit": limit,
        ]
        if let wingID {
            let scope = Queries.wingScope(column: "c.wing_id", wingID: wingID)
            let fragment = scope.sql.replacingOccurrences(of: "?", with: ":wing")
            clauses.append(fragment)
            if fragment.contains(":wing") { arguments["wing"] = wingID }
        }
        let source: String
        if let candidates {
            source = "json_each(:candidates) j JOIN container c ON c.id = j.value"
            arguments["candidates"] = try json(candidates)
        } else {
            source = "container c"
        }
        return try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.title, c.entry_date, c.created_at,
                       COALESCE(c.last_touched_at, c.created_at) AS touched
                FROM \(source)
                WHERE \(clauses.joined(separator: " AND "))
                ORDER BY touched DESC, c.id DESC
                LIMIT :limit
                """,
            arguments: StatementArguments(arguments)
        ).map { row in
            PageRow(id: row["id"], title: displayTitle(row), touched: row["touched"],
                    cursor: PageCursor(key: row["touched"], id: row["id"]))
        }
    }

    /// EVERY note shared with the client: under the open book or a wing grant
    /// the reached wings' notes by recency; otherwise the grants' own
    /// candidates (shared notes + the shared books' members).
    private func sharedPage(
        _ db: Database, standing: MCPGrantAuthority.Standing, after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow] {
        let live = standing.liveGrants
        if standing.openBook {
            return try recencyPage(db, wingID: nil, candidates: nil, after: cursor, limit: limit)
        }
        let noteIDs = live.filter { $0.scopeKind == .note }.map(\.scopeID)
        let bookIDs = live.filter { $0.scopeKind == .book }.map(\.scopeID)
        let wingIDs = Set(live.filter { $0.scopeKind == .wing }.map(\.scopeID))
        var candidates = Set(noteIDs)
        if !bookIDs.isEmpty {
            candidates.formUnion(try String.fetchAll(
                db,
                sql: """
                    SELECT rp.post_id FROM reading_post rp
                    WHERE rp.reading_id IN (SELECT value FROM json_each(?))
                      AND rp.deleted_at IS NULL AND rp.status = 'member'
                    """,
                arguments: [try json(bookIDs)]))
        }
        if wingIDs.isEmpty {
            return try recencyPage(db, wingID: nil, candidates: candidates.sorted(), after: cursor, limit: limit)
        }
        // Wing-level reach: the reached wings' notes plus any candidate
        // outside them, merged by recency (each source keyset-paged by the
        // same cursor, so the merge pages exactly).
        var rows: [PageRow] = []
        for wing in wingIDs.sorted() {
            rows += try recencyPage(db, wingID: wing, candidates: nil, after: cursor, limit: limit)
        }
        rows += try recencyPage(db, wingID: nil, candidates: candidates.sorted(), after: cursor, limit: limit)
        var seen = Set<String>()
        return rows
            .sorted { ($0.touched, $0.id) > ($1.touched, $1.id) }
            .filter { seen.insert($0.id).inserted }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - search

    private func search(_ args: [String: Value], clientName: String) throws -> Outcome {
        let text = try requiredString(args, "query")
        let limit = min(max(try optionalInt(args, "limit") ?? Self.defaultSearchLimit, 1), Self.maxSearchLimit)
        let bookID = try optionalString(args, "book_id")
        let noteID = try optionalString(args, "note_id")
        let query = SearchQueryParser.parse(text, typeAhead: false, calendar: calendar)
        guard !query.isEmpty else { throw ArgumentFailure(message: "Give search some words to look for.") }
        let act = MCPToolCatalog.search.name
        return try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            var scopes: [SearchScope] = []
            if let noteID {
                let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
                let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: false)
                guard isStandingAllow(decision, standing), let facts else {
                    try log(db, clientName, act, "note", noteID, nil, allowed: false)
                    return refusal(decision.isAllowed ? .ask(.notShared, offersAlways: true) : decision, .note)
                }
                scopes = [SearchScope(wingID: facts.wingID, within: .note(id: noteID))]
            } else if let bookID {
                let facts = try Queries.mcpBookFacts(db, readingID: bookID)
                let decision = MCPGrantAuthority.decide(standing, book: facts, rung: .read)
                // Round 1 F1: search serves STANDING reach only — a once book
                // grant would pass the book decision and then fail every
                // passage, an eternally empty page; refuse it here instead,
                // the same rule the catalog's listing reads.
                guard isStandingAllow(decision, standing), let facts else {
                    try log(db, clientName, act, "book", bookID, nil, allowed: false)
                    return refusal(decision.isAllowed ? .ask(.notShared, offersAlways: true) : decision, .book)
                }
                scopes = [SearchScope(wingID: facts.wingID, within: .book(id: bookID))]
            } else {
                guard standing.state == .approved else {
                    try log(db, clientName, act, nil, nil, nil, allowed: false)
                    return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .note)
                }
                scopes = try reachedScopes(db, standing)
            }
            var passages: [[String: Any]] = []
            var truncated = false
            var seen = Set<String>()
            scopeLoop: for scope in scopes {
                let page = try Queries.searchPassages(db, query: query, scope: scope, limit: limit, calendar: calendar)
                if page.next != nil { truncated = true }
                let facts = try Queries.mcpNoteFacts(db, noteIDs: page.passages.compactMap(\.noteID))
                for passage in page.passages where seen.insert(passage.id).inserted {
                    guard try passes(db, passage, facts, standing) else { continue }
                    passages.append(encodePassage(passage))
                    if passages.count == limit { truncated = true; break scopeLoop }
                }
            }
            try log(db, clientName, act, bookID != nil ? "book" : (noteID != nil ? "note" : nil),
                    bookID ?? noteID, nil, allowed: true)
            return Outcome(text: try encode(["passages": passages, "truncated": truncated]), isError: false)
        }
    }

    /// Every scope the client's reach covers, wing-level first: the open
    /// book's wings (Home and every live wing) or the wing grants', then the
    /// shared books outside them, then the shared notes outside both (a once
    /// grant never feeds search — search reads words without spending it).
    private func reachedScopes(_ db: Database, _ standing: MCPGrantAuthority.Standing) throws -> [SearchScope] {
        let live = standing.searchGrants  // F1: the ONE standing-reach rule
        var wings: [String] = live.filter { $0.scopeKind == .wing }.map(\.scopeID)
        if standing.openBook {
            wings = [""] + (try String.fetchAll(db, sql: "SELECT id FROM wing WHERE deleted_at IS NULL ORDER BY position, id"))
        }
        let wingSet = Set(wings)
        var scopes = Array(Set(wings)).sorted().map { SearchScope(wingID: $0, within: .library) }
        var bookIDs: Set<String> = []
        for grant in live where grant.scopeKind == .book {
            guard let facts = try Queries.mcpBookFacts(db, readingID: grant.scopeID),
                  !wingSet.contains(facts.wingID) else { continue }
            bookIDs.insert(facts.id)
            scopes.append(SearchScope(wingID: facts.wingID, within: .book(id: facts.id)))
        }
        for grant in live where grant.scopeKind == .note {
            guard let facts = try Queries.mcpNoteFacts(db, noteID: grant.scopeID),
                  !wingSet.contains(facts.wingID), facts.bookIDs.isDisjoint(with: bookIDs) else { continue }
            scopes.append(SearchScope(wingID: facts.wingID, within: .note(id: facts.id)))
        }
        return scopes
    }

    /// A passage shows only when the rule allows its note (or its book, for a
    /// book or chapter name) AND the allowing grant is a standing one.
    private func passes(
        _ db: Database, _ passage: SearchPassage, _ facts: [String: MCPGrantRule.NoteFacts],
        _ standing: MCPGrantAuthority.Standing
    ) throws -> Bool {
        if let noteID = passage.noteID {
            let decision = MCPGrantAuthority.decide(standing, note: facts[noteID], rung: .read, consumes: false)
            return isStandingAllow(decision, standing)
        }
        if let readingID = passage.readingID {
            return MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: readingID), rung: .read).isAllowed
        }
        return false
    }

    private func isStandingAllow(_ decision: MCPGrantRule.Decision, _ standing: MCPGrantAuthority.Standing) -> Bool {
        guard case .allow(let grantID, _) = decision else { return false }
        return standing.grant(id: grantID)?.duration != .once
    }

    private func encodePassage(_ passage: SearchPassage) -> [String: Any] {
        var entry: [String: Any] = [
            "kind": passage.kind.rawValue,
            "snippet": passage.snippet.map { $0.isMatch ? "**\($0.text)**" : $0.text }.joined(),
        ]
        if let noteID = passage.noteID {
            entry["note_id"] = noteID
            entry["note_title"] = passage.homeTitle
        }
        if let readingID = passage.readingID {
            entry["book_id"] = readingID
            entry["book_name"] = passage.homeTitle
        }
        if let blockID = passage.blockID { entry["block_id"] = blockID }
        return entry
    }

    // MARK: - Shared pieces

    private func refusal(_ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target) -> Outcome {
        guard let reason = MCPRefusalCopy.reason(of: decision) else {
            return Outcome(text: "Not allowed.", isError: true)
        }
        return Outcome(text: MCPRefusalCopy.words(reason, target), isError: true)
    }

    private func log(
        _ db: Database, _ clientName: String, _ act: String, _ kind: String?, _ id: String?,
        _ title: String?, allowed: Bool
    ) throws {
        try operations.recordMCPActivity(
            db, clientName: clientName, act: act, targetKind: kind, targetID: id,
            targetTitle: title, allowed: allowed)
    }

    private func displayTitle(_ row: Row) -> String {
        DisplayTitle.note(
            title: row["title"], entryDate: row["entry_date"], createdAt: row["created_at"], calendar: calendar)
    }

    static func resolvedWing(_ column: String) -> String {
        "CASE WHEN \(column) = '' OR \(column) NOT IN (SELECT w.id FROM wing w WHERE w.deleted_at IS NULL) "
            + "THEN '' ELSE \(column) END"
    }

    private func json(_ values: [String]) throws -> String {
        String(decoding: try JSONEncoder().encode(values), as: UTF8.self)
    }

    private func encode(_ object: [String: Any]) throws -> String {
        String(decoding: try JSONSerialization.data(
            withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
    }

    // MARK: - Arguments

    struct ArgumentFailure: Error {
        let message: String
    }

    private func requiredString(_ args: [String: Value], _ key: String) throws -> String {
        guard let value = try optionalString(args, key), !value.isEmpty else {
            throw ArgumentFailure(message: "\(key) is required.")
        }
        return value
    }

    private func optionalString(_ args: [String: Value], _ key: String) throws -> String? {
        guard let value = args[key], value != .null else { return nil }
        guard let string = value.stringValue else { throw ArgumentFailure(message: "\(key) must be a string.") }
        return string
    }

    private func optionalInt(_ args: [String: Value], _ key: String) throws -> Int? {
        guard let value = args[key], value != .null else { return nil }
        if let int = value.intValue { return int }
        if case .double(let double) = value, double.rounded() == double { return Int(double) }
        throw ArgumentFailure(message: "\(key) must be an integer.")
    }
}

/// A keyset page's resume point — `(sort key, id)`, opaque to the client.
struct PageCursor: Equatable, Sendable {
    let key: String
    let id: String

    var encoded: String { Data("\(key)\n\(id)".utf8).base64EncodedString() }

    init(key: String, id: String) {
        self.key = key
        self.id = id
    }

    init?(encoded: String) {
        guard let data = Data(base64Encoded: encoded),
              let text = String(data: data, encoding: .utf8),
              let split = text.firstIndex(of: "\n")
        else { return nil }
        key = String(text[..<split])
        id = String(text[text.index(after: split)...])
        guard !key.isEmpty, !id.isEmpty else { return nil }
    }
}
