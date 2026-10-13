import Foundation
import GRDB

// THE MCP DOOR's SHARE FACES — the reads (13n-c U3: VX-156 items 2/3,
// VX-270 · VX-271 · VX-164). Three things the faces outside Settings ▸ MCP need, each
// derived from the grants store and the ONE rule — never a parallel fence:
// - SHARED PLACES grouped by act (the exact-stamp doctrine — the bulk share
//   writes N note grants on one `created_at`, read back as one row);
// - the REACH of an approved client on a note, a book or (VX-185) a
//   gathering, with the WHY (the grant `MCPGrantRule.decide` — for a
//   gathering `decideGathering` — itself would use: "readable through the
//   Home wing grant");
// - the chord's derivation (⌥⌘A — the newest grant she made).

/// **One row of SHARED PLACES** (13n-c U3 — VX-156 item 2; mockup §2's "3
/// notes · claude-code · read · while connected"): the live grants ONE act
/// minted. Every live NOTE grant sharing client · rung · duration ·
/// `created_at` is one act (the bulk share writes them in one transaction on
/// one clock read); a book or wing grant is always its own row. No schema —
/// grouping is on read. A group of one IS that one grant's row.
public struct MCPSharedGroup: Equatable, Sendable, Identifiable {
    public var id: String { lead.id }
    /// The members whose titles were read (at most `Queries.mcpSharedMemberTitles`),
    /// in the act's own order; the first is the LEAD.
    public let rows: [MCPSharedRow]
    /// EVERY member's grant id, in the act's order — Revoke covers them all.
    public let grantIDs: [String]
    /// Members reaching nothing now (an "always" note grant whose note is
    /// fenced since; a book grant's own inert fence) — R2-3's rule, per member.
    public let inertCount: Int
    /// **13n-c UX-fix ladder UXR1-2:** members whose TARGET is gone (deleted
    /// — no delete revokes a grant), counted over EVERY member, not only the
    /// titled few: the same liveness `MCPSharedRow.targetTitle` reads. The
    /// pane offers Change… only while something stands (`MCPChangeOffer`).
    public let goneCount: Int

    public init(rows: [MCPSharedRow], grantIDs: [String], inertCount: Int, goneCount: Int) {
        self.rows = rows
        self.grantIDs = grantIDs
        self.inertCount = inertCount
        self.goneCount = goneCount
    }

    public var lead: MCPSharedRow { rows[0] }
    public var memberCount: Int { grantIDs.count }
    /// More than one grant — the pane draws the act's row ("3 notes").
    public var isGroup: Bool { grantIDs.count > 1 }
}

/// **One approved client's reach on a place, and WHY** (13n-c U3 — VX-271's
/// popover, VX-164's in-note indicator): the highest rung it reaches now and
/// the standing `MCPGrantRule.decide` itself authorizes it with.
public struct MCPPlaceReach: Equatable, Sendable, Identifiable {
    public var id: String { client.id }
    /// The client (Change… re-opens the sheet on exactly it).
    public let client: MCPClient
    public var clientID: String { client.id }
    public var clientName: String { client.name }
    public let rung: MCPGrantRule.Rung
    /// The authorizing grant's row; nil = the open book.
    public let grant: MCPGrantRow?
    /// The WIDER place the reach comes through, named — a book holding the
    /// note, or a wing ("Home" for the virtual one); nil when the place's
    /// OWN grant authorizes it, and for the open book (`grant == nil`).
    public let throughTitle: String?

    public init(client: MCPClient, rung: MCPGrantRule.Rung, grant: MCPGrantRow?, throughTitle: String?) {
        self.client = client
        self.rung = rung
        self.grant = grant
        self.throughTitle = throughTitle
    }

    /// The open book is a switch, not a grant: always, until she turns it off.
    public var duration: MCPGrantRule.Duration { grant?.duration ?? .always }
    public var viaOpenBook: Bool { grant == nil }
}

extension Queries {
    /// How many member titles a grouped Shared places row reads (the rest
    /// are said as "and N more") — PROVISIONAL P-13nc-U3-4. ∝ the shown rows.
    public static let mcpSharedMemberTitles = 3

    // MARK: - Shared places, grouped by act

    /// **SHARED PLACES, one row per ACT** — newest act first; `limit` caps
    /// the ACTS (the pane's "all N ›" road counts acts too —
    /// `mcpSharedGroupCount`). Reads every live grant row once (the grants
    /// store is hers — ∝ her own grants, never the corpus) and then titles,
    /// fences and facts ONLY for the shown acts' first few members, plus one
    /// batched facts read per shown "always" note act for its inert count.
    public static func mcpSharedGroups(
        _ db: Database, limit: Int? = nil, memberTitles: Int = mcpSharedMemberTitles,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> [MCPSharedGroup] {
        let acts = try mcpSharedActs(db)
        let shown = limit.map { Array(acts.prefix($0)) } ?? acts
        return try shown.map { act in
            let titled = try act.members.prefix(max(memberTitles, 1)).map { member in
                MCPSharedRow(
                    grant: member.grant, clientName: member.clientName,
                    targetTitle: try mcpScopeTitle(
                        db, kind: member.grant.scopeKind, id: member.grant.scopeID, calendar: calendar),
                    inertFence: try mcpGrantInertFence(db, member.grant))
            }
            return MCPSharedGroup(
                rows: titled, grantIDs: act.members.map(\.grant.id),
                inertCount: try mcpSharedInertCount(db, act: act, titled: titled),
                goneCount: try mcpSharedGoneCount(db, act: act, titled: titled))
        }
    }

    /// **One act's members, EVERY one named** (13n-c Stage B R1 B3 — R-13n-10:
    /// every "all N ›" is a real road): a grouped row names its first few
    /// members and says "and N more ›"; this is that road. The act's LIVE
    /// grants in the order given (the act's own), each with its title and its
    /// inert fence (R2-3's rule, through the one rule). ∝ the act — one row
    /// read per member, never the corpus; a member revoked or spent since is
    /// left out (the same liveness `mcpSharedActs` reads).
    public static func mcpSharedActMembers(
        _ db: Database, grantIDs: [String], calendar: Calendar = JournalDay.storeCalendar
    ) throws -> [MCPSharedRow] {
        try grantIDs.compactMap { id in
            guard let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT g.*, cl.name AS client_name FROM mcp_grant g
                    JOIN mcp_client cl ON cl.id = g.client_id
                    WHERE g.id = ? AND g.revoked_at IS NULL
                      AND NOT (g.duration = 'once' AND g.consumed_at IS NOT NULL)
                    """,
                arguments: [id]),
                let grant = mcpGrant(from: row)
            else { return nil }
            return MCPSharedRow(
                grant: grant, clientName: row["client_name"],
                targetTitle: try mcpScopeTitle(db, kind: grant.scopeKind, id: grant.scopeID, calendar: calendar),
                inertFence: try mcpGrantInertFence(db, grant))
        }
    }

    /// How many ACTS Shared places holds (the "all N ›" road's N).
    public static func mcpSharedGroupCount(_ db: Database) throws -> Int {
        try mcpSharedActs(db).count
    }

    /// One act: its live grants (with the client's name), in the act's order.
    struct MCPSharedAct {
        struct Member {
            let grant: MCPGrantRow
            let clientName: String
        }
        var members: [Member]
    }

    /// Every live grant (not revoked, not a spent once grant), grouped by act:
    /// newest stamp first, and within one stamp the INSERTION order (`rowid`
    /// — the act's own order: the bulk share inserts in her listing's order).
    static func mcpSharedActs(_ db: Database) throws -> [MCPSharedAct] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT g.*, cl.name AS client_name FROM mcp_grant g
                JOIN mcp_client cl ON cl.id = g.client_id
                WHERE g.revoked_at IS NULL
                  AND NOT (g.duration = 'once' AND g.consumed_at IS NOT NULL)
                ORDER BY g.created_at DESC, g.rowid
                """)
        struct Key: Hashable {
            let clientID: String
            let rung: String
            let duration: String
            let stamp: String
            /// nil for a note grant (it groups); the grant's own id otherwise.
            let single: String?
        }
        var order: [Key] = []
        var acts: [Key: MCPSharedAct] = [:]
        for row in rows {
            guard let grant = mcpGrant(from: row) else { continue }
            let key = Key(
                clientID: grant.clientID, rung: grant.rung.rawValue, duration: grant.duration.rawValue,
                stamp: grant.createdAt, single: grant.scopeKind == .note ? nil : grant.id)
            let member = MCPSharedAct.Member(grant: grant, clientName: row["client_name"])
            if acts[key] == nil {
                order.append(key)
                acts[key] = MCPSharedAct(members: [member])
            } else {
                acts[key]?.members.append(member)
            }
        }
        return order.compactMap { acts[$0] }
    }

    /// An act's inert members, through the ONE rule (R2-3's): a single row
    /// says its own fence; a group of per-ask note grants can never be inert
    /// (a per-ask grant reaches even a fenced note of its own id — asked of
    /// the rule on a fenced twin, `mcpGrantInertFence`'s cost guard); a group
    /// of "always" note grants reads its notes' facts in ONE batched statement.
    static func mcpSharedInertCount(
        _ db: Database, act: MCPSharedAct, titled: [MCPSharedRow]
    ) throws -> Int {
        guard act.members.count > 1, let lead = act.members.first?.grant else {
            return titled.first?.inertFence == nil ? 0 : 1
        }
        let fencedTwin = MCPGrantRule.NoteFacts(id: lead.scopeID, wingID: "", fence: .privateMark)
        guard !MCPGrantRule.reaches(lead.ruleGrant, .note(fencedTwin)) else { return 0 }
        let facts = try mcpNoteFacts(db, noteIDs: act.members.map(\.grant.scopeID))
        return act.members.filter { member in
            guard let note = facts[member.grant.scopeID], note.fence != nil else { return false }
            return !MCPGrantRule.reaches(member.grant.ruleGrant, .note(note))
        }.count
    }

    /// **An act's members whose TARGET is gone** (the 13n-c UX-fix ladder's
    /// UXR1-2 — no delete revokes a grant, so a live grant can name a deleted
    /// note, book or wing): the liveness `mcpScopeTitle` reads. A single row
    /// says its own title's; a group (note grants only) counts EVERY member,
    /// not only the titled few, in ONE batched statement — ∝ the act.
    static func mcpSharedGoneCount(
        _ db: Database, act: MCPSharedAct, titled: [MCPSharedRow]
    ) throws -> Int {
        guard act.members.count > 1 else { return titled.first?.targetTitle == nil ? 1 : 0 }
        let json = String(decoding: try JSONEncoder().encode(act.members.map(\.grant.scopeID)), as: UTF8.self)
        let standing = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM json_each(?) j
                WHERE EXISTS (SELECT 1 FROM container c WHERE c.id = j.value AND c.deleted_at IS NULL)
                """,
            arguments: [json]) ?? 0
        return act.members.count - standing
    }

    // MARK: - Reach, with the why

    /// **Who reaches this NOTE, how far, and why** — every APPROVED client
    /// whose standing lets the ONE rule allow at least a read now (the same
    /// `decide` the server consults per call), by client name. A missing,
    /// version or scraps note answers nobody. ∝ the approved clients.
    public static func mcpNoteReach(_ db: Database, noteID: String) throws -> [MCPPlaceReach] {
        guard let facts = try mcpNoteFacts(db, noteID: noteID) else { return [] }
        return try mcpReach(db, place: .note(facts))
    }

    /// **Who reaches this BOOK — or GATHERING — how far, and why** — the
    /// Bookcase icon's popover and the Book Settings grant row. A fenced book
    /// or gathering answers nobody. VX-185: a gathering answers through ITS
    /// rule (`decideGathering` — a wing grant on its wing or the open book,
    /// VX-273 / R-VX185-1), so this read and `mcpBookReaches` agree for
    /// every id the Bookcase draws.
    public static func mcpBookReach(_ db: Database, readingID: String) throws -> [MCPPlaceReach] {
        guard let place = try mcpReachPlace(db, readingID: readingID) else { return [] }
        return try mcpReach(db, place: place)
    }

    /// **Every live book AND GATHERING an approved client reaches now, with
    /// who and why** — the Bookcase's icons (VX-271; the old chip's
    /// `mcpReachableBookIDs`, grown to say who and how far). VX-185 (her
    /// report: a gathering never wore the icon "even when you've shared the
    /// whole wing"): every live reading is decided by ITS kind's ONE rule — a
    /// book through `decide`, a gathering through `decideGathering` (wing-level
    /// reach on its wing, or the open book — never a note or book grant,
    /// R-VX185-1; a fenced one never). REACH, not presentation: an archived
    /// reading stays in the map as the wire still answers it by id; the
    /// Bookcase never draws an archived row of either kind
    /// (`bookcaseReadings`). One-shot or held; ∝ the readings × the approved
    /// clients (a handful), each client's grants read once, one facts row per
    /// reading — never an assembly, never `container`.
    public static func mcpBookReaches(_ db: Database) throws -> [String: [MCPPlaceReach]] {
        let clients = try mcpClients(db, states: [.approved])
        guard !clients.isEmpty else { return [:] }
        let openBook = try mcpSwitch(db, .openBook)
        let standings = try clients.map { ($0, try mcpGrants(db, clientID: $0.id)) }
        guard openBook || standings.contains(where: { $0.1.contains(where: { $0.ruleGrant.isLive }) }) else {
            return [:]
        }
        var titles: [String: String?] = [:]
        var out: [String: [MCPPlaceReach]] = [:]
        for id in try String.fetchAll(
            db, sql: "SELECT id FROM reading WHERE deleted_at IS NULL AND kind IN ('book', 'gathering')") {
            guard let place = try mcpReachPlace(db, readingID: id) else { continue }
            let reaches = try standings.compactMap { client, rows in
                try placeReach(db, client: client, rows: rows, openBook: openBook, place: place, titles: &titles)
            }
            if !reaches.isEmpty { out[id] = reaches.sorted { $0.clientName < $1.clientName } }
        }
        return out
    }

    /// **The place a reach is read on, and the ONE rule its kind answers to**
    /// (VX-185). A note and a book are grant targets (`decide`); a gathering
    /// is never a grant's scope (VX-273) and answers `decideGathering`.
    enum MCPReachPlace {
        case note(MCPGrantRule.NoteFacts)
        case book(MCPGrantRule.BookFacts)
        case gathering(MCPGrantRule.BookFacts)

        /// The approved client's reach here — read off the kind's own rule.
        func reach(grants: [MCPGrantRule.Grant], openBook: Bool) -> MCPGrantRule.Reach? {
            switch self {
            case .note(let facts): MCPGrantRule.reach(grants: grants, openBook: openBook, target: .note(facts))
            case .book(let facts): MCPGrantRule.reach(grants: grants, openBook: openBook, target: .book(facts))
            case .gathering(let facts): MCPGrantRule.reach(grants: grants, openBook: openBook, gathering: facts)
            }
        }

        /// Whether a grant names THIS place itself (its why is then nil). A
        /// gathering is never a grant's scope, so every reach on one names the
        /// wider place — its wing — or the open book.
        func isOwn(_ grant: MCPGrantRow) -> Bool {
            switch self {
            case .note(let facts): grant.scopeKind == .note && grant.scopeID == facts.id
            case .book(let facts): grant.scopeKind == .book && grant.scopeID == facts.id
            case .gathering: false
            }
        }
    }

    /// A live book's or gathering's place (nil for anything else — a missing,
    /// tombstoned or fenced-out id answers nobody, as before).
    static func mcpReachPlace(_ db: Database, readingID: String) throws -> MCPReachPlace? {
        if let facts = try mcpBookFacts(db, readingID: readingID) { return .book(facts) }
        if let facts = try mcpGatheringFacts(db, readingID: readingID) { return .gathering(facts) }
        return nil
    }

    static func mcpReach(_ db: Database, place: MCPReachPlace) throws -> [MCPPlaceReach] {
        let openBook = try mcpSwitch(db, .openBook)
        var titles: [String: String?] = [:]
        return try mcpClients(db, states: [.approved]).compactMap { client in
            try placeReach(
                db, client: client, rows: try mcpGrants(db, clientID: client.id), openBook: openBook,
                place: place, titles: &titles)
        }.sorted { $0.clientName < $1.clientName }
    }

    private static func placeReach(
        _ db: Database, client: MCPClient, rows: [MCPGrantRow], openBook: Bool,
        place: MCPReachPlace, titles: inout [String: String?]
    ) throws -> MCPPlaceReach? {
        guard let reach = place.reach(grants: rows.map(\.ruleGrant), openBook: openBook) else { return nil }
        guard case .grant(let ruled) = reach.standing,
              let grant = rows.first(where: { $0.id == ruled.id })
        else {
            return MCPPlaceReach(client: client, rung: reach.rung, grant: nil, throughTitle: nil)
        }
        var through: String?
        if !place.isOwn(grant) {
            let key = "\(grant.scopeKind.rawValue):\(grant.scopeID)"
            if let cached = titles[key] {
                through = cached
            } else {
                through = try mcpScopeTitle(db, kind: grant.scopeKind, id: grant.scopeID)
                titles[key] = through
            }
        }
        return MCPPlaceReach(client: client, rung: reach.rung, grant: grant, throughTitle: through)
    }

    // MARK: - ⌥⌘A's derivation

    /// **The newest grant she made** (13n-c U3 — the brief §4: "the newest
    /// grant row whose client is still approved → its client and its rung"):
    /// revoked and spent rows COUNT (it is a fact about her last choice, not
    /// about that grant's life). nil = no history.
    public static func mcpNewestGrant(_ db: Database) throws -> MCPShareChord.Newest? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT g.rung, cl.id AS client_id, cl.name AS client_name FROM mcp_grant g
                JOIN mcp_client cl ON cl.id = g.client_id
                WHERE cl.state = 'approved'
                ORDER BY g.created_at DESC, g.rowid DESC
                LIMIT 1
                """),
              let rung = MCPGrantRule.Rung(rawValue: row["rung"])
        else { return nil }
        return MCPShareChord.Newest(clientID: row["client_id"], clientName: row["client_name"], rung: rung)
    }
}
