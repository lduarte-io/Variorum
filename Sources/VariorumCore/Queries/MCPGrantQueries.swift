import Foundation
import GRDB

// THE MCP DOOR's GRANTS STORE — the reads (13n-b U1; A-5/A-6/A-7). The store
// itself is `Persistence/MCPGrantSchema.swift`; the decision is the pure
// `Domain/MCPGrantRule`; this file reads the rows the rule takes and derives
// the CURRENT facts it decides on — THE FENCE's legs in ONE place.

/// A client as it named itself (`clientInfo.name` IS the identity — A-4).
public struct MCPClient: Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let version: String?
    public let state: MCPGrantRule.ClientState
    public let firstSeenAt: String
    public let lastSeenAt: String
    public let decidedAt: String?
}

/// One grant row.
public struct MCPGrantRow: Equatable, Sendable, Identifiable {
    public let id: String
    public let clientID: String
    public let rung: MCPGrantRule.Rung
    public let scopeKind: MCPGrantRule.ScopeKind
    public let scopeID: String
    public let duration: MCPGrantRule.Duration
    public let createdAt: String
    public let consumedAt: String?
    public let revokedAt: String?

    /// The row as the rule reads it.
    public var ruleGrant: MCPGrantRule.Grant {
        MCPGrantRule.Grant(
            id: id, rung: rung, scopeKind: scopeKind, scopeID: scopeID, duration: duration,
            consumedAt: consumedAt, revokedAt: revokedAt)
    }
}

/// The grants store's switches (A-6): both read OFF when no row exists.
public enum MCPSwitch: String, CaseIterable, Sendable {
    /// Settings ▸ MCP's "Enable the MCP server" (A-8).
    case server
    /// The ONE open-book switch (§9's spectrum).
    case openBook = "open_book"
}

/// One row of the coarse activity log.
public struct MCPActivityRow: Equatable, Sendable, Identifiable {
    public let id: Int64
    public let clientName: String
    public let act: String
    public let targetKind: String?
    public let targetID: String?
    public let targetTitle: String?
    public let allowed: Bool
    public let at: String
}

/// One live grant as the SHARED WITH AI list shows it.
public struct MCPSharedRow: Equatable, Sendable, Identifiable {
    public var id: String { grant.id }
    public let grant: MCPGrantRow
    public let clientName: String
    /// The note's display title, the book's name, or the wing's name
    /// ("Home" for the virtual Home wing); nil when the target is gone.
    public let targetTitle: String?
}

extension Queries {
    // MARK: - Clients

    public static func mcpClient(_ db: Database, name: String) throws -> MCPClient? {
        try Row.fetchOne(db, sql: "SELECT * FROM mcp_client WHERE name = ?", arguments: [name])
            .flatMap(mcpClient(from:))
    }

    public static func mcpClient(_ db: Database, id: String) throws -> MCPClient? {
        try Row.fetchOne(db, sql: "SELECT * FROM mcp_client WHERE id = ?", arguments: [id])
            .flatMap(mcpClient(from:))
    }

    /// The pane's clients, PENDING requests first (newest first), then the
    /// rest by when they were last seen. `limit` caps the page (R-13n-10 —
    /// the pane's "all N ›" road reads the count beside it).
    public static func mcpClients(
        _ db: Database, states: Set<MCPGrantRule.ClientState> = Set(MCPGrantRule.ClientState.allCases),
        limit: Int? = nil
    ) throws -> [MCPClient] {
        let json = String(decoding: try JSONEncoder().encode(states.map(\.rawValue).sorted()), as: UTF8.self)
        return try Row.fetchAll(
            db,
            sql: """
                SELECT * FROM mcp_client
                WHERE state IN (SELECT value FROM json_each(?))
                ORDER BY (state = 'pending') DESC, last_seen_at DESC, id
                \(limit.map { "LIMIT \($0)" } ?? "")
                """,
            arguments: [json]
        ).compactMap(mcpClient(from:))
    }

    public static func mcpClientCount(
        _ db: Database, states: Set<MCPGrantRule.ClientState> = Set(MCPGrantRule.ClientState.allCases)
    ) throws -> Int {
        let json = String(decoding: try JSONEncoder().encode(states.map(\.rawValue).sorted()), as: UTF8.self)
        return try Int.fetchOne(
            db, sql: "SELECT COUNT(*) FROM mcp_client WHERE state IN (SELECT value FROM json_each(?))",
            arguments: [json]) ?? 0
    }

    static func mcpClient(from row: Row) -> MCPClient? {
        guard let state = MCPGrantRule.ClientState(rawValue: row["state"]) else { return nil }
        return MCPClient(
            id: row["id"], name: row["name"], version: row["version"], state: state,
            firstSeenAt: row["first_seen_at"], lastSeenAt: row["last_seen_at"],
            decidedAt: row["decided_at"])
    }

    // MARK: - Grants

    /// A client's grants not yet revoked (a spent once grant included — the
    /// rule reads it dead; the shared list leaves it out).
    public static func mcpGrants(_ db: Database, clientID: String) throws -> [MCPGrantRow] {
        try Row.fetchAll(
            db,
            sql: "SELECT * FROM mcp_grant WHERE client_id = ? AND revoked_at IS NULL ORDER BY created_at, id",
            arguments: [clientID]
        ).compactMap(mcpGrant(from:))
    }

    public static func mcpGrant(_ db: Database, id: String) throws -> MCPGrantRow? {
        try Row.fetchOne(db, sql: "SELECT * FROM mcp_grant WHERE id = ?", arguments: [id])
            .flatMap(mcpGrant(from:))
    }

    static func mcpGrant(from row: Row) -> MCPGrantRow? {
        guard let rung = MCPGrantRule.Rung(rawValue: row["rung"]),
              let kind = MCPGrantRule.ScopeKind(rawValue: row["scope_kind"]),
              let duration = MCPGrantRule.Duration(rawValue: row["duration"])
        else { return nil }
        return MCPGrantRow(
            id: row["id"], clientID: row["client_id"], rung: rung, scopeKind: kind,
            scopeID: row["scope_id"], duration: duration, createdAt: row["created_at"],
            consumedAt: row["consumed_at"], revokedAt: row["revoked_at"])
    }

    /// **SHARED WITH AI** — every LIVE grant (not revoked, not a spent once
    /// grant), newest first, with its client's name and its target's title.
    public static func mcpSharedRows(
        _ db: Database, limit: Int? = nil, calendar: Calendar = JournalDay.storeCalendar
    ) throws -> [MCPSharedRow] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT g.*, cl.name AS client_name FROM mcp_grant g
                JOIN mcp_client cl ON cl.id = g.client_id
                WHERE g.revoked_at IS NULL
                  AND NOT (g.duration = 'once' AND g.consumed_at IS NOT NULL)
                ORDER BY g.created_at DESC, g.id
                \(limit.map { "LIMIT \($0)" } ?? "")
                """)
        return try rows.compactMap { row in
            guard let grant = mcpGrant(from: row) else { return nil }
            return MCPSharedRow(
                grant: grant, clientName: row["client_name"],
                targetTitle: try mcpScopeTitle(db, kind: grant.scopeKind, id: grant.scopeID, calendar: calendar))
        }
    }

    public static func mcpSharedCount(_ db: Database) throws -> Int {
        try Int.fetchOne(db, sql: """
            SELECT COUNT(*) FROM mcp_grant
            WHERE revoked_at IS NULL AND NOT (duration = 'once' AND consumed_at IS NOT NULL)
            """) ?? 0
    }

    /// A scope target's name as every surface shows it; nil when it is gone.
    public static func mcpScopeTitle(
        _ db: Database, kind: MCPGrantRule.ScopeKind, id: String,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> String? {
        switch kind {
        case .note:
            guard let row = try Row.fetchOne(
                db,
                sql: "SELECT title, entry_date, created_at FROM container WHERE id = ? AND deleted_at IS NULL",
                arguments: [id])
            else { return nil }
            return DisplayTitle.note(
                title: row["title"], entryDate: row["entry_date"], createdAt: row["created_at"],
                calendar: calendar)
        case .book:
            return try String.fetchOne(
                db, sql: "SELECT name FROM reading WHERE id = ? AND deleted_at IS NULL", arguments: [id])
        case .wing:
            if id.isEmpty { return Self.mcpHomeWingName }
            return try String.fetchOne(
                db, sql: "SELECT name FROM wing WHERE id = ? AND deleted_at IS NULL", arguments: [id])
        }
    }

    /// The virtual Home wing's name (R-13ia-2).
    public static let mcpHomeWingName = "Home"

    // MARK: - Switches

    public static func mcpSwitch(_ db: Database, _ key: MCPSwitch) throws -> Bool {
        try String.fetchOne(db, sql: "SELECT value FROM mcp_switch WHERE key = ?", arguments: [key.rawValue]) == "1"
    }

    /// The `mcp_switch` row recording the restore hold whose adoption has
    /// already landed the server OFF (R-13nb-6 — `landMCPAfterAdoption`).
    /// Not a switch: a stamp, beside the switches it governs.
    public static let mcpAdoptionAckKey = "adoption_hold_ack"

    // MARK: - Activity

    public static func mcpActivity(_ db: Database, limit: Int? = nil) throws -> [MCPActivityRow] {
        try Row.fetchAll(
            db,
            sql: "SELECT * FROM mcp_activity ORDER BY id DESC \(limit.map { "LIMIT \($0)" } ?? "")"
        ).map { row in
            MCPActivityRow(
                id: row["id"], clientName: row["client_name"], act: row["act"],
                targetKind: row["target_kind"], targetID: row["target_id"],
                targetTitle: row["target_title"], allowed: (row["outcome"] as String) == "allowed",
                at: row["at"])
        }
    }

    public static func mcpActivityCount(_ db: Database) throws -> Int {
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0
    }

    // MARK: - THE FACTS THE RULE DECIDES ON (A-7 — current, per call)

    /// The wing a `wing_id` column reads as: a DANGLING pointer reads as Home
    /// (`Queries.wingScope`'s rule, P-13id-U5-2).
    static func mcpResolvedWing(column: String) -> String {
        """
        CASE WHEN \(column) = '' OR \(column) NOT IN (SELECT w.id FROM wing w WHERE w.deleted_at IS NULL)
             THEN '' ELSE \(column) END
        """
    }

    /// **THE FENCE's legs — the ONE derivation site** (R-13nb-1 ratified the
    /// journal predicate; R-13nb-4 adds the Private mark). Per note:
    /// 1. its own `profile = 'journal'`;
    /// 2. a live MEMBER (status 'member') of a live reading whose profile is
    ///    `'journal'` (the trait) or `'daily'` (THE daily Journal) — an
    ///    archived book is still alive, so it still fences;
    /// 3. **the Private mark** — its own `ai_private_at`, or a live member of
    ///    a live reading carrying one (R-13nb-4, privacy winning ties; v1_25's
    ///    columns, wired at U2 — the `privateLeg` fragments below).
    ///
    /// A note is fenced iff any leg holds. Only live non-version POSTS have
    /// facts: a missing, tombstoned, scraps-group or version container reads
    /// nil, which every tool answers exactly as it answers an unshared note
    /// (no existence oracle). Batched for listings: one statement per page
    /// (P1 — ∝ the page, never the corpus).
    public static func mcpNoteFacts(
        _ db: Database, noteIDs: [String]
    ) throws -> [String: MCPGrantRule.NoteFacts] {
        guard !noteIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(noteIDs), as: UTF8.self)
        var facts: [String: MCPGrantRule.NoteFacts] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT c.id,
                       \(mcpResolvedWing(column: "c.wing_id")) AS wing,
                       (c.profile = 'journal') AS own_journal,
                       EXISTS (SELECT 1 FROM reading_post rp JOIN reading r ON r.id = rp.reading_id
                               WHERE rp.post_id = c.id AND rp.deleted_at IS NULL AND rp.status = 'member'
                                 AND r.deleted_at IS NULL AND r.profile IN ('journal', 'daily')) AS member_journal,
                       \(privateLegForNote) AS private_mark
                FROM json_each(?) j CROSS JOIN container c ON c.id = j.value
                WHERE c.deleted_at IS NULL AND c.kind = 'post'
                  AND NOT (c.archived_at IS NOT NULL AND c.archived_at = c.created_at)
                """,
            arguments: [json]) {
            let id: String = row["id"]
            facts[id] = MCPGrantRule.NoteFacts(
                id: id, wingID: row["wing"], bookIDs: [],
                fence: MCPGrantRule.fence(
                    journal: (row["own_journal"] as Bool? ?? false) || row["member_journal"],
                    privateMark: row["private_mark"]))
        }
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT rp.post_id, rp.reading_id FROM json_each(?) j
                CROSS JOIN reading_post rp ON rp.post_id = j.value
                JOIN reading r ON r.id = rp.reading_id
                WHERE rp.deleted_at IS NULL AND rp.status = 'member'
                  AND r.deleted_at IS NULL AND r.kind = 'book'
                """,
            arguments: [json]) {
            let postID: String = row["post_id"]
            facts[postID]?.bookIDs.insert(row["reading_id"])
        }
        return facts
    }

    public static func mcpNoteFacts(_ db: Database, noteID: String) throws -> MCPGrantRule.NoteFacts? {
        try mcpNoteFacts(db, noteIDs: [noteID])[noteID]
    }

    /// A BOOK's facts — live books only (a gathering is not a grant target in
    /// U1, PROVISIONAL P-13nb-U1-4). Fenced when it is a journal (the trait
    /// or THE daily Journal) or carries the Private mark (R-13nb-4).
    public static func mcpBookFacts(_ db: Database, readingID: String) throws -> MCPGrantRule.BookFacts? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT r.id, \(mcpResolvedWing(column: "r.wing_id")) AS wing,
                       (r.profile IN ('journal', 'daily')) AS journal,
                       \(privateLegForBook) AS private_mark
                FROM reading r
                WHERE r.id = ? AND r.deleted_at IS NULL AND r.kind = 'book'
                """,
            arguments: [readingID])
        else { return nil }
        return MCPGrantRule.BookFacts(
            id: row["id"], wingID: row["wing"],
            fence: MCPGrantRule.fence(journal: row["journal"] as Bool? ?? false, privateMark: row["private_mark"]))
    }

    /// One book a grant may name.
    public struct MCPGrantableBook: Equatable, Sendable, Identifiable {
        public let id: String
        public let name: String
        /// Its wing (a dangling pointer read as Home, `''`).
        public let wingID: String
    }

    /// **The books the grant sheet offers** — every live BOOK the fence does
    /// not exclude (a journal-trait book, THE daily Journal and a Private
    /// book are never a grant's scope — the op refuses them,
    /// so the sheet never offers them; P-2), by name. Gatherings are not
    /// grant targets in U1 (P-13nb-U1-4). Author-scale (a library's books).
    public static func mcpGrantableBooks(_ db: Database) throws -> [MCPGrantableBook] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.name, \(mcpResolvedWing(column: "r.wing_id")) AS wing
                FROM reading r
                WHERE r.deleted_at IS NULL AND r.kind = 'book'
                  AND (r.profile IS NULL OR r.profile NOT IN ('journal', 'daily'))
                  AND NOT (\(privateLegForBook))
                ORDER BY r.name COLLATE NOCASE, r.id
                """
        ).map { MCPGrantableBook(id: $0["id"], name: $0["name"], wingID: $0["wing"]) }
    }

    /// **The Private leg for a note** (R-13nb-4, wired at 13n-b U2 over
    /// v1_25's columns): its OWN stamp (`container.ai_private_at`), or a LIVE
    /// MEMBER (status 'member' — an arrival is never membership) of a LIVE
    /// reading carrying one. An ARCHIVED private book still fences (it is
    /// alive — the journal leg's precedent); a deleted one does not. NULL
    /// reads not-private. Expects the note aliased `c`.
    static let privateLegForNote = """
        (c.ai_private_at IS NOT NULL
         OR EXISTS (SELECT 1 FROM reading_post prp JOIN reading pr ON pr.id = prp.reading_id
                    WHERE prp.post_id = c.id AND prp.deleted_at IS NULL AND prp.status = 'member'
                      AND pr.deleted_at IS NULL AND pr.ai_private_at IS NOT NULL))
        """
    /// **The Private leg for a book** — its own stamp. Expects the book
    /// aliased `r`.
    static let privateLegForBook = "(r.ai_private_at IS NOT NULL)"

    // MARK: - The Private mark, as the faces read it (R-13nb-4)

    /// A note's OWN mark (not the book road — `mcpNoteFacts` answers whether
    /// it is fenced at all). False for anything that is not a live post.
    public static func isNotePrivate(_ db: Database, postID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT ai_private_at IS NOT NULL FROM container
                WHERE id = ? AND deleted_at IS NULL AND kind = 'post'
                """,
            arguments: [postID]) ?? false
    }

    /// A book's own mark. False for anything that is not a live reading.
    public static func isBookPrivate(_ db: Database, readingID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT ai_private_at IS NOT NULL FROM reading WHERE id = ? AND deleted_at IS NULL",
            arguments: [readingID]) ?? false
    }

    /// The live PRIVATE books a note is a live member of, by name — the
    /// note ⋯ menu's "private through “…”" line (the mark it cannot clear
    /// from the note). ∝ the note's memberships.
    public static func privateBooksHolding(_ db: Database, postID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT r.name FROM reading_post rp JOIN reading r ON r.id = rp.reading_id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND r.deleted_at IS NULL AND r.ai_private_at IS NOT NULL
                ORDER BY r.name COLLATE NOCASE, r.id
                """,
            arguments: [postID])
    }
}

// MARK: - THE GRANT IN CONTEXT (13n-b U2 — the faces outside Settings ▸ MCP)

/// One approved client's reach on a note, as the note's own face says it.
public struct MCPNoteSharing: Equatable, Sendable {
    public let clientName: String
    /// The highest rung the client may act at on this note right now.
    public let rung: MCPGrantRule.Rung
}

extension Queries {
    /// **Who can reach this note, and how far** — every APPROVED client
    /// whose standing (its live grants, or the open book) lets the pure rule
    /// allow at least a read on the note RIGHT NOW, with the highest rung it
    /// allows. The SAME rule the server consults per call (never a parallel
    /// SQL fence): a fenced note answers only per-ask note grants; a missing
    /// or version note answers nobody. ∝ the approved clients (a handful).
    public static func mcpNoteSharing(_ db: Database, noteID: String) throws -> [MCPNoteSharing] {
        guard let facts = try mcpNoteFacts(db, noteID: noteID) else { return [] }
        let openBook = try mcpSwitch(db, .openBook)
        var sharing: [MCPNoteSharing] = []
        for client in try mcpClients(db, states: [.approved]) {
            let grants = try mcpGrants(db, clientID: client.id).map(\.ruleGrant)
            let reached = MCPGrantRule.Rung.allCases.reversed().first { rung in
                MCPGrantRule.decide(
                    client: .approved, grants: grants, openBook: openBook,
                    target: .note(facts), rung: rung, consumes: false
                ).isAllowed
            }
            if let reached { sharing.append(MCPNoteSharing(clientName: client.name, rung: reached)) }
        }
        return sharing.sorted { $0.clientName < $1.clientName }
    }

    /// **The books an approved client can reach right now** — the Bookcase
    /// row's "shared with AI" chip (P-13n-3's word). Honest under every
    /// grant shape: a book grant on it, a wing grant on its wing, or the open
    /// book — each read through the pure rule on the book's own facts, so a
    /// journal or Private book (reached by nothing) never chips. ∝ the books
    /// (a shelf) × the approved clients (a handful).
    public static func mcpReachableBookIDs(_ db: Database) throws -> Set<String> {
        let clients = try mcpClients(db, states: [.approved])
        guard !clients.isEmpty else { return [] }
        let openBook = try mcpSwitch(db, .openBook)
        let standings = try clients.map { try mcpGrants(db, clientID: $0.id).map(\.ruleGrant) }
        guard openBook || standings.contains(where: { $0.contains(where: \.isLive) }) else { return [] }
        var reachable: Set<String> = []
        for id in try String.fetchAll(
            db, sql: "SELECT id FROM reading WHERE deleted_at IS NULL AND kind = 'book'") {
            guard let facts = try mcpBookFacts(db, readingID: id) else { continue }
            if standings.contains(where: { grants in
                MCPGrantRule.decide(
                    client: .approved, grants: grants, openBook: openBook,
                    target: .book(facts), rung: .read, consumes: false
                ).isAllowed
            }) {
                reachable.insert(id)
            }
        }
        return reachable
    }
}
