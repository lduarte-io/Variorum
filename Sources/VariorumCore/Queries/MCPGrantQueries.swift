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
    /// VX-168: a setup key is bound to the name (`mcp_client.setup_key_hash`
    /// is set). The faces read only this fact — the hash never leaves the
    /// grants store's own reads.
    public let isSetupBound: Bool

    /// 13n-c U3: public, so the app's pins can name a client.
    public init(
        id: String, name: String, version: String?, state: MCPGrantRule.ClientState,
        firstSeenAt: String, lastSeenAt: String, decidedAt: String?, isSetupBound: Bool = false
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.state = state
        self.firstSeenAt = firstSeenAt
        self.lastSeenAt = lastSeenAt
        self.decidedAt = decidedAt
        self.isSetupBound = isSetupBound
    }
}

/// **A setup waiting for her OK** (VX-258): a copied key a connection
/// presented under a name that carries her approval, which it was not copied
/// for. Her Allow binds it to the name (`allowMCPRebind`); her Don't allow
/// forgets it (`declineMCPRebind`). The face reads these; the key's hash
/// never leaves the store.
public struct MCPRebindRequest: Equatable, Sendable, Identifiable {
    public let id: String
    public let clientID: String
    public let clientName: String
    /// What the waiting connection declared in `initialize` — what tells her
    /// a stranger from the client she knows.
    public let version: String?
    public let askedAt: String

    public init(id: String, clientID: String, clientName: String, version: String?, askedAt: String) {
        self.id = id
        self.clientID = clientID
        self.clientName = clientName
        self.version = version
        self.askedAt = askedAt
    }
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

    /// 13n-c U3: public, so the app's pins can name a grant.
    public init(
        id: String, clientID: String, rung: MCPGrantRule.Rung, scopeKind: MCPGrantRule.ScopeKind,
        scopeID: String, duration: MCPGrantRule.Duration, createdAt: String, consumedAt: String?,
        revokedAt: String?
    ) {
        self.id = id
        self.clientID = clientID
        self.rung = rung
        self.scopeKind = scopeKind
        self.scopeID = scopeID
        self.duration = duration
        self.createdAt = createdAt
        self.consumedAt = consumedAt
        self.revokedAt = revokedAt
    }

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

    /// 13n-b U3: public so the activity face's coalescing is testable from
    /// the app's suites.
    public init(
        id: Int64, clientName: String, act: String, targetKind: String?, targetID: String?,
        targetTitle: String?, allowed: Bool, at: String
    ) {
        self.id = id
        self.clientName = clientName
        self.act = act
        self.targetKind = targetKind
        self.targetID = targetID
        self.targetTitle = targetTitle
        self.allowed = allowed
        self.at = at
    }
}

/// One live grant as the SHARED list shows it.
public struct MCPSharedRow: Equatable, Sendable, Identifiable {
    public var id: String { grant.id }
    public let grant: MCPGrantRow
    public let clientName: String
    /// The note's display title, the book's name, or the wing's name
    /// ("Home" for the virtual Home wing); nil when the target is gone.
    public let targetTitle: String?
    /// **13n-c U2 (the U1 ladder's R2-3; P-13nb-U2-3): why this live grant
    /// reaches NOTHING right now** — its target is fenced since it was made
    /// (a book marked Private, a trait book made THE daily Journal, a note
    /// marked Private under an "always" grant). nil = it reaches its target
    /// (or the target is gone — `targetTitle` says that). The faces must
    /// not call such a grant shared while it is inert.
    public let inertFence: MCPGrantRule.Fence?

    public init(
        grant: MCPGrantRow, clientName: String, targetTitle: String?,
        inertFence: MCPGrantRule.Fence? = nil
    ) {
        self.grant = grant
        self.clientName = clientName
        self.targetTitle = targetTitle
        self.inertFence = inertFence
    }
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

    /// **The WHO row's order** (13n-c U2 — the brief §3): every APPROVED
    /// client, the most recently GRANTED first (its newest grant row's
    /// stamp, revoked rows included — "the last grant she made" is a fact
    /// about her, not about the grant's life; brief §4's derivation), then
    /// the never-granted by when they were last seen.
    public static func mcpClientsByRecentGrant(_ db: Database) throws -> [MCPClient] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT cl.*, (SELECT MAX(g.created_at) FROM mcp_grant g WHERE g.client_id = cl.id) AS last_granted
                FROM mcp_client cl
                WHERE cl.state = 'approved'
                ORDER BY (last_granted IS NULL), last_granted DESC, cl.last_seen_at DESC, cl.id
                """
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
            decidedAt: row["decided_at"], isSetupBound: (row["setup_key_hash"] as String?) != nil)
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
                targetTitle: try mcpScopeTitle(db, kind: grant.scopeKind, id: grant.scopeID, calendar: calendar),
                inertFence: try mcpGrantInertFence(db, grant))
        }
    }

    /// **Why a live grant reaches nothing right now** (13n-c U2 — R2-3): the
    /// fence of a target the ONE rule's scope test refuses it — read on the
    /// ONE derivation site's facts (`mcpNoteFacts` / `mcpBookFacts`) through
    /// `MCPGrantRule.reaches`, never a parallel fence. nil when the grant
    /// reaches (a per-ask note grant on a fenced note DOES), when its target
    /// is gone, and always for a wing (a wing is never fenced; its fenced
    /// notes are filtered one by one).
    public static func mcpGrantInertFence(_ db: Database, _ grant: MCPGrantRow) throws -> MCPGrantRule.Fence? {
        let target: MCPGrantRule.Target
        let fence: MCPGrantRule.Fence?
        switch grant.scopeKind {
        case .note:
            // The cost guard, ASKED OF THE RULE (never a second fence): a
            // note grant that reaches even a FENCED note of its own id (a
            // per-ask grant — once or while connected) can be made inert by
            // no fence, so its note's facts are never read. Only an "always"
            // note grant pays the facts read — so the pane's held snapshot
            // reads `container` for these rows only when such a grant exists.
            let fencedTwin = MCPGrantRule.NoteFacts(id: grant.scopeID, wingID: "", fence: .privateMark)
            if MCPGrantRule.reaches(grant.ruleGrant, .note(fencedTwin)) { return nil }
            guard let facts = try mcpNoteFacts(db, noteID: grant.scopeID) else { return nil }
            (target, fence) = (.note(facts), facts.fence)
        case .book:
            guard let facts = try mcpBookFacts(db, readingID: grant.scopeID) else { return nil }
            (target, fence) = (.book(facts), facts.fence)
        case .wing:
            return nil
        case .gathering:
            // VX-549: a gathering grant reaches nothing while its gathering is
            // fenced (`decideGathering`'s own first clause — the one answer a
            // fenced book gets); no op fences a gathering, a stale row could.
            return try mcpGatheringFacts(db, readingID: grant.scopeID)?.fence
        }
        guard let fence, !MCPGrantRule.reaches(grant.ruleGrant, target) else { return nil }
        return fence
    }

    /// A client's live grants, split by whether they reach (13n-c U2 —
    /// R2-3's twin on the client row: "N shared places" counts only grants
    /// that reach; an inert one is said as inert). ∝ the client's grants.
    public static func mcpGrantReachCounts(
        _ db: Database, clientID: String
    ) throws -> (reaching: Int, inert: Int) {
        var reaching = 0, inert = 0
        for grant in try mcpGrants(db, clientID: clientID) where grant.ruleGrant.isLive {
            if try mcpGrantInertFence(db, grant) == nil { reaching += 1 } else { inert += 1 }
        }
        return (reaching, inert)
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
        case .book, .gathering:
            // VX-549: a gathering's name, as the Bookcase shows it (a book and
            // a gathering are one table — the id names one kind).
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
        ).map(mcpActivityRow(from:))
    }

    /// **ONE client's own rows — `list_my_activity`'s read** (VX-261, VX-336
    /// U7 — the run record's D-261-3/6): the rows logged under `clientName`
    /// at or after `since` (its current approval's `decided_at` — the era
    /// cut, P-VX261-1), whose act is one of `acts` (the tools the answer
    /// lists — never a connection row), newest first, keyset-paged on the
    /// row id (`before` = the previous page's last id, exclusive). Rows as
    /// LOGGED, joined to nothing (the oracle rule, D-261-4). Cost ∝ the log's
    /// cap (≤ `mcpActivityCap` + 1 rows by construction), never the corpus —
    /// no index needed.
    public static func mcpOwnActivity(
        _ db: Database, clientName: String, since: String, acts: [String], before: Int64?, limit: Int
    ) throws -> [MCPActivityRow] {
        let json = String(decoding: try JSONEncoder().encode(acts), as: UTF8.self)
        return try Row.fetchAll(
            db,
            sql: """
                SELECT * FROM mcp_activity
                WHERE client_name = ? AND at >= ? AND act IN (SELECT value FROM json_each(?))
                  AND (? IS NULL OR id < ?)
                ORDER BY id DESC
                LIMIT ?
                """,
            arguments: [clientName, since, json, before, before, limit]
        ).map(mcpActivityRow(from:))
    }

    private static func mcpActivityRow(from row: Row) -> MCPActivityRow {
        MCPActivityRow(
            id: row["id"], clientName: row["client_name"], act: row["act"],
            targetKind: row["target_kind"], targetID: row["target_id"],
            targetTitle: row["target_title"], allowed: (row["outcome"] as String) == "allowed",
            at: row["at"])
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
    /// journal predicate; R-13nb-4 adds the Private mark; 13n-c's VX-163
    /// RE-KEYED the journal legs on THE daily Journal — her words: "for the
    /// default command J journal I think it's a fair choice but I am
    /// questioning it being applied to all journal style books"). Per note:
    /// 1. its own `profile = 'journal'` — the shape ⌘J's
    ///    `createOrOpenJournalEntry` gives every day entry (the ONLY door that
    ///    mints it; the copy roads carry it), so a day entry stays per-ask
    ///    wherever it is later filed (13n-c D-1, PROVISIONAL P-13nc-1);
    /// 2. a live MEMBER (status 'member') of a live reading wearing THE daily
    ///    Journal's marker (`profile = 'daily'` — every live bearer, a
    ///    not-yet-converged stale one included: the conservative direction).
    ///    A journal-TRAIT book (`profile = 'journal'`, `setJournalTrait`'s
    ///    toggle) is NOT a fence leg since VX-163 — its members are shared
    ///    like any book's. An archived daily Journal is still alive, so it
    ///    still fences;
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
                                 AND r.deleted_at IS NULL AND \(dailyJournalLegForBook)) AS member_journal,
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
        try mcpGatheringMemberships(db, into: &facts)
        return facts
    }

    /// **VX-549 — which GRANTED gatherings assemble each of these notes NOW**
    /// (her sitting 2026-10-27, RATIFIED: "reach is resolved by assembling the
    /// rule at read time"). The gatherings asked are exactly those a LIVE grant
    /// names (any client's — the facts are the store's, the rule then reads
    /// only the asking client's grants through `reaches`); each is asked
    /// through THE ONE membership function its own surfaces assemble by
    /// (`gatheringMembership` — the wing, the rule, the hide-owned exclusion,
    /// living unarchived posts), never a parallel evaluation. A gathering that
    /// assembles EMPTY — archived, rule-less, malformed (the function's nil) —
    /// or that is FENCED (a stale Private stamp or 'daily' marker; no op mints
    /// either on a gathering) holds nothing here, so its grant reaches no note.
    ///
    /// P1: one read of the live gathering grants (∝ her own grants — a
    /// handful); per granted gathering, its row, its fence and ONE statement
    /// over exactly the notes being decided (the page-driven `CROSS JOIN` — the
    /// id list drives, each note a primary-key seek): ∝ the notes decided × the
    /// granted gatherings, never the corpus. With no gathering granted, one
    /// read and nothing else.
    private static func mcpGatheringMemberships(
        _ db: Database, into facts: inout [String: MCPGrantRule.NoteFacts]
    ) throws {
        guard !facts.isEmpty else { return }
        let granted = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT scope_id FROM mcp_grant
                WHERE scope_kind = 'gathering' AND revoked_at IS NULL
                  AND NOT (duration = 'once' AND consumed_at IS NOT NULL)
                ORDER BY scope_id
                """)
        guard !granted.isEmpty else { return }
        let json = String(decoding: try JSONEncoder().encode(facts.keys.sorted()), as: UTF8.self)
        for gatheringID in granted {
            guard let reading = try Reading.fetchOne(db, key: gatheringID), reading.deletedAt == nil,
                  reading.kind == .gathering,
                  try mcpGatheringFacts(db, readingID: gatheringID)?.fence == nil,
                  let membership = try gatheringMembership(db, reading)
            else { continue }
            let members = try String.fetchAll(
                db, sql: mcpGatheringMembersSQL(membership.conditions),
                arguments: StatementArguments([json] + membership.arguments))
            for id in members { facts[id]?.gatheringIDs.insert(gatheringID) }
        }
    }

    /// The membership statement over a page of notes (split out so the P1 pin
    /// reads the shipped text): the id list DRIVES (`CROSS JOIN` keeps
    /// `json_each` outside — the house's page-driven shape, `smartMembershipSQL`'s
    /// measured reason), each note a primary-key seek, then the gathering's
    /// own conditions (`gatheringMembership`). First placeholder: the ids as
    /// a JSON array; then the conditions' arguments.
    static func mcpGatheringMembersSQL(_ conditions: [String]) -> String {
        """
        SELECT j.value FROM json_each(?) j
        CROSS JOIN container c ON c.id = j.value
        WHERE \(conditions.joined(separator: " AND "))
        """
    }

    public static func mcpNoteFacts(_ db: Database, noteID: String) throws -> MCPGrantRule.NoteFacts? {
        try mcpNoteFacts(db, noteIDs: [noteID])[noteID]
    }

    /// A BOOK's facts — live books only (a gathering answers through
    /// `mcpGatheringFacts` — its own scope kind since VX-549, never a book's
    /// road). Fenced when it is THE daily Journal (its
    /// 'daily' marker — VX-163: a journal-TRAIT book is not) or carries the
    /// Private mark (R-13nb-4).
    public static func mcpBookFacts(_ db: Database, readingID: String) throws -> MCPGrantRule.BookFacts? {
        try mcpReadingFacts(db, readingID: readingID, kind: .book)
    }

    /// **A GATHERING's facts** (13n-c VX-273 — its reach is the rule's
    /// `decideGathering`): a live gathering's id and wing, and its fence on the
    /// SAME two fragments a book's facts read (no op marks a gathering Private
    /// or daily; a stale synced row could — the conservative direction). nil
    /// for anything that is not a live gathering: a BOOK answers through
    /// `mcpBookFacts` and never here, so no grant road can mistake one for the
    /// other.
    public static func mcpGatheringFacts(
        _ db: Database, readingID: String
    ) throws -> MCPGrantRule.BookFacts? {
        try mcpReadingFacts(db, readingID: readingID, kind: .gathering)
    }

    /// The one statement both read (so a book's facts and a gathering's can
    /// never drift apart).
    private static func mcpReadingFacts(
        _ db: Database, readingID: String, kind: ReadingKind
    ) throws -> MCPGrantRule.BookFacts? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT r.id, \(mcpResolvedWing(column: "r.wing_id")) AS wing,
                       \(dailyJournalLegForBook) AS journal,
                       \(privateLegForBook) AS private_mark
                FROM reading r
                WHERE r.id = ? AND r.deleted_at IS NULL AND r.kind = ?
                """,
            arguments: [readingID, kind.rawValue])
        else { return nil }
        return MCPGrantRule.BookFacts(
            id: row["id"], wingID: row["wing"],
            fence: MCPGrantRule.fence(journal: row["journal"] as Bool? ?? false, privateMark: row["private_mark"]))
    }

    /// One book a grant may name — and, since 13n-c U2, what the grant
    /// sheet says about it at scale (her "hundreds of books"): its shelf, its
    /// star, the notes it shows, its state, when it was made and last edited.
    public struct MCPGrantableBook: Equatable, Sendable, Identifiable {
        public let id: String
        public let name: String
        /// Its wing (a dangling pointer read as Home, `''`).
        public let wingID: String
        /// Its shelf as the Bookcase reads it: nil when unshelved, and when
        /// the pointer DANGLES (a dead shelf, or one in another wing — the
        /// Bookcase's "unshelved" class, §19).
        public let shelfID: String?
        /// The UNION star (the Bookcase's own — `starredReadingIDs`).
        public let starred: Bool
        /// The notes it SHOWS — live, un-archived members (the Bookcase's
        /// honest "N notes", #169(a)(1)).
        public let noteCount: Int
        public let marks: PlaceLabels.Marks
        /// `reading.created_at`, canonical ISO-8601 text.
        public let createdAt: String
        /// Its derived "last edited" (the Bookcase's own derivation —
        /// `memberLastEditedSQL` over `shownMemberNoteJoinSQL`, falling back
        /// to its birth), canonical ISO-8601 text.
        public let lastEdited: String

        public init(
            id: String, name: String, wingID: String, shelfID: String? = nil, starred: Bool = false,
            noteCount: Int = 0, marks: PlaceLabels.Marks = .init(), createdAt: String, lastEdited: String
        ) {
            self.id = id
            self.name = name
            self.wingID = wingID
            self.shelfID = shelfID
            self.starred = starred
            self.noteCount = noteCount
            self.marks = marks
            self.createdAt = createdAt
            self.lastEdited = lastEdited
        }
    }

    /// **The books the grant sheet offers** — every live BOOK the fence does
    /// not exclude (THE daily Journal and a Private book are never a grant's
    /// scope — the op refuses them, so the sheet never offers them; P-2; a
    /// journal-TRAIT book IS offered since VX-163), by name. Gatherings are
    /// offered beside them since VX-549 (`mcpGrantableGatherings`). Author-scale.
    ///
    /// **13n-c U2 — the facts it carries, and their cost (P1, said exactly):**
    /// one statement over the library's live books; each book's shown-member
    /// count and last-edited stamp are correlated aggregates entered through
    /// `reading_post`'s `reading_id` index, each member a primary-key seek
    /// into `container` (pinned by plan) — so the work is ∝ the books' own
    /// memberships, never the note corpus. The star is the Bookcase's union
    /// (one read of the starred list); the shelf is resolved against the live
    /// shelves of the book's own wing (a dangling pointer reads unshelved).
    /// One-shot (the sheet's appearance), never held.
    public static func mcpGrantableBooks(_ db: Database) throws -> [MCPGrantableBook] {
        let starred = try starredReadingIDs(db)
        let shelfWings = Dictionary(uniqueKeysWithValues: try Row.fetchAll(
            db, sql: "SELECT id, wing_id FROM shelf WHERE deleted_at IS NULL"
        ).map { ($0["id"] as String, $0["wing_id"] as String) })
        return try Row.fetchAll(db, sql: mcpGrantableBooksSQL).map { row in
            let wing: String = row["wing"]
            let shelf: String? = row["shelf_id"]
            let createdAt: String = row["created_at"]
            return MCPGrantableBook(
                id: row["id"], name: row["name"], wingID: wing,
                shelfID: shelf.flatMap { shelfWings[$0] == wing ? $0 : nil },
                starred: starred.contains(row["id"]),
                noteCount: row["notes"],
                marks: PlaceLabels.Marks(
                    living: row["living"], finished: row["locked"],
                    sealed: (row["sealed_at"] as String?) != nil, owned: row["owned"],
                    archived: (row["archived_at"] as String?) != nil),
                createdAt: createdAt,
                lastEdited: bookLastEdited(memberStamp: row["member_stamp"], createdAtStamp: createdAt))
        }
    }

    /// The offered-books statement (split out so the P1 pin reads the shipped
    /// text). No placeholders.
    static let mcpGrantableBooksSQL = """
        SELECT r.id, r.name, \(mcpResolvedWing(column: "r.wing_id")) AS wing, r.shelf_id,
               r.locked, r.owned, r.sealed_at, r.archived_at, r.created_at,
               \(livingBookSQL(alias: "r")) AS living,
               (SELECT COUNT(*) FROM reading_post rp \(shownMemberNoteJoinSQL)
                 WHERE rp.reading_id = r.id AND \(liveMemberRowSQL)) AS notes,
               (SELECT \(memberLastEditedSQL) FROM reading_post rp \(shownMemberNoteJoinSQL)
                 WHERE rp.reading_id = r.id AND \(liveMemberRowSQL)) AS member_stamp
        FROM reading r
        WHERE r.deleted_at IS NULL AND r.kind = 'book'
          AND NOT (\(dailyJournalLegForBook))
          AND NOT (\(privateLegForBook))
        ORDER BY r.name COLLATE NOCASE, r.id
        """

    /// **The live books a grant may NOT name** (13n-c U3 — a book row's
    /// "Share with AI…" is drawn only where the op could act, P-2): exactly
    /// the complement of `mcpGrantableBooksSQL`'s fence filter, on the SAME
    /// two fragments (THE daily Journal's marker, the Private mark) — never a
    /// parallel fence. ∝ the fenced books (a handful).
    public static func mcpFencedBookIDs(_ db: Database) throws -> Set<String> {
        Set(try String.fetchAll(
            db,
            sql: """
                SELECT r.id FROM reading r
                WHERE r.deleted_at IS NULL AND r.kind = 'book'
                  AND ((\(dailyJournalLegForBook)) OR (\(privateLegForBook)))
                """))
    }

    /// How many books the grant picker's "Recently edited" quick section
    /// shows before typing (13n-c U2 — her "that's often what I want";
    /// PROVISIONAL P-13nc-U2-1).
    public static let mcpRecentlyEditedCount = 5

    /// **Everything the grant sheet's book and wing pickers show** (13n-c
    /// U2): the offered books with their facts, the live shelves of every
    /// wing in strip order (left to right — All's top to bottom, §24), and
    /// the live additional wings in switcher order (Home is virtual, '').
    public static func mcpGrantPlaces(_ db: Database) throws -> MCPGrantPlaces {
        MCPGrantPlaces(
            books: try mcpGrantableBooks(db),
            shelves: try Shelf.fetchAll(
                db, sql: "SELECT * FROM shelf WHERE deleted_at IS NULL ORDER BY position, id"),
            wings: try wings(db))
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

    /// **The daily-Journal leg for a book** (13n-c VX-163) — THE daily
    /// Journal's own marker, through the ONE constant every daily mint stamps
    /// (`dailyJournalBookProfile`), never the trait's 'journal'. NULL-safe: a
    /// NULL profile reads false. Expects the book aliased `r`; used by the
    /// member leg, the book's facts and the sheet's offer alike, so the three
    /// can never drift apart.
    static let dailyJournalLegForBook = "(r.profile IS NOT NULL AND r.profile = '\(dailyJournalBookProfile)')"

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

    public init(clientName: String, rung: MCPGrantRule.Rung) {
        self.clientName = clientName
        self.rung = rung
    }
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

    /// **The books an approved client can reach right now** — since 13n-c U3
    /// a PARITY ORACLE only: no face reads it. The Bookcase's "shared with AI"
    /// text chip it once fed is retired; the ONE shared icon reads
    /// `mcpBookReaches` (who, how far and why), and the pins hold the icon's
    /// BOOK set equal to this one under every grant shape (`MCPShareTests`;
    /// since VX-185 the icon map also holds the GATHERINGS `decideGathering`
    /// reaches — their parity pin is `MCPGatheringReachTests`). Kept
    /// because it is the simplest honest statement of the set: a book grant on
    /// it, a wing grant on its wing, or the open book — each read through the
    /// pure rule on the book's own facts, so THE daily Journal or a Private
    /// book (reached by nothing) is never in it (a journal-TRAIT book is, like
    /// any book, since VX-163). ∝ the books × the approved clients (13n-c
    /// Stage B R1 B11: the doc corrected; the dead app-side readers removed).
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

// MARK: - The setup keys (VX-168 — K2, R-VX168-1; moved here from
// Operations+MCPSetupKeys.swift at the ladder's F-4: the family's reads live
// in the family's query home)

extension Queries {
    /// The hash of the key bound to a client; nil = unbound (or no client).
    public static func mcpSetupKeyHash(_ db: Database, clientID: String) throws -> String? {
        try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE id = ?", arguments: [clientID])
    }

    /// Where a presented key (by its hash) stands: bound to a client, still
    /// unclaimed, or unknown here. VX-198: with the presenting `name`, a key
    /// that name was bound to until a newer setup re-bound it stands
    /// `replaced` — remembered by the rebind's own Activity row (keyed on the
    /// name AND the hash, so the reason belongs to its name only; a row the
    /// log's cap has pruned is forgotten, and the key reads unknown again —
    /// P-VX198-1).
    /// VX-258: a key claimed by a connection and waiting for her OK stands
    /// `awaiting` (its client named) — read after a binding, before the
    /// unclaimed set; the replaced memory reads her Allow's rows too (an
    /// allowed wait replaces a key exactly as a re-run setup does).
    public static func mcpSetupKeyStanding(
        _ db: Database, hash: String, name: String? = nil
    ) throws -> MCPSetupKeyRule.KeyStanding {
        if let clientID = try String.fetchOne(
            db, sql: "SELECT id FROM mcp_client WHERE setup_key_hash = ?", arguments: [hash]) {
            return .boundTo(clientID: clientID)
        }
        if let clientID = try String.fetchOne(
            db, sql: "SELECT client_id FROM mcp_rebind_request WHERE key_hash = ?", arguments: [hash]) {
            return .awaiting(clientID: clientID)
        }
        let pending = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM mcp_setup_key WHERE key_hash = ?)", arguments: [hash]) ?? false
        if pending { return .unclaimed }
        if let name, try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM mcp_activity
                               WHERE act IN (SELECT value FROM json_each(?)) AND client_name = ?
                                 AND target_kind = ? AND target_id = ?)
                """,
            arguments: [
                String(decoding: try JSONEncoder().encode(MCPSetupKeyRule.replacingActs), as: UTF8.self), name,
                MCPSetupKeyRule.replacedTargetKind, hash,
            ]) ?? false {
            return .replaced
        }
        return .unknown
    }

    /// **The setups waiting for her OK** (VX-258 — the Waiting section's
    /// re-bind rows; the face is VX-281's pane): each waiting key's request
    /// id, the client it would bind, the version its connection declared and
    /// when it first arrived, oldest first. Never the hash.
    public static func mcpRebindRequests(_ db: Database) throws -> [MCPRebindRequest] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.client_id, c.name, r.version, r.asked_at
                FROM mcp_rebind_request r JOIN mcp_client c ON c.id = r.client_id
                ORDER BY r.asked_at, r.id
                """
        ).map {
            MCPRebindRequest(
                id: $0["id"], clientID: $0["client_id"], clientName: $0["name"], version: $0["version"],
                askedAt: $0["asked_at"])
        }
    }

    /// How many copied keys wait unpresented (the drill's and the pins' read).
    public static func mcpUnclaimedSetupKeyCount(_ db: Database) throws -> Int {
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_setup_key") ?? 0
    }
}
