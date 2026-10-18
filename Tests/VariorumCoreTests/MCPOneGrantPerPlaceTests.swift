import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-393 (VX-348 U5 — her ruling R-VX348-6 "Upgrade in place", the run record
// `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5): Settings ▸ MCP ▸ Shared
// with AI listed one wing twice for one client — `read · always` AND `read,
// suggest, write new and edit · always` — and one book twice. THE TRACE: the
// grants store's ONE mint (`insertMCPGrant`) never looked at what the client
// already held on the place, and every grant road but Change… — the sheet's
// new-grant confirm, ⌥⌘A, an ask's answer, Allow-AI-here, approve-with-grant,
// the bulk share — reached it without naming anything to replace. So a second
// grant on a place ADDED a row, and revoking one row left the other standing.
//
// Her ruling: ONE row per client × place; a new grant on an existing pair
// REPLACES its row on every road (Change…'s semantics); existing duplicates
// merge to the strongest at a LOCAL-ONLY grants-family migration; Revoke then
// means what it says.

@Suite("VX-393 — one grant row per client × place (upgrade in place)")
struct MCPOneGrantPerPlaceTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func spec(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// The client's LIVE grants on one place (a spent once grant is not live).
    private func live(
        _ db: AppDatabase, _ client: String, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) throws -> [MCPGrantRow] {
        try db.read { try Queries.mcpGrants($0, clientID: client) }
            .filter { $0.ruleGrant.isLive && $0.scopeKind == kind && $0.scopeID == id }
    }

    // MARK: - Every road replaces (RED ON OLD: each one added a second row)

    /// Her screenshot's pair, on every road that mints a grant: `read · always`
    /// on a wing, then `edit · always` on the SAME wing — one live row, at
    /// edit, and Shared with AI shows ONE row for the place.
    @Test func aNewGrantOnASharedPlaceReplacesItsRowOnEveryRoad() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "PlanetLillian")
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book, wingId: wing.id)
            let note = try ops.createPost(title: "ch 1", wingId: wing.id)
            let client = try approvedClient(ops)
            typealias Road = (String, (Operations.MCPGrantSpec) throws -> String)
            let roads: [Road] = [
                // ⌥⌘A, an ask's answer, the pane's own sheet.
                ("grantMCPAccess(_:_:)", { try ops.grantMCPAccess(client.id, $0) }),
                // THE grant sheet's new-grant confirm (nothing to replace named).
                ("grantMCPAccess(_:_:replacing: [])", { try ops.grantMCPAccess(client.id, $0, replacing: []) }),
                // Approve… on a client already approved, with a grant picked.
                ("approveMCPClient(_:granting:)", { try #require(try ops.approveMCPClient(client.id, granting: $0)) }),
            ]
            for (name, road) in roads {
                for (kind, id) in [(MCPGrantRule.ScopeKind.wing, wing.id), (.book, book.id), (.note, note.id)] {
                    _ = try road(spec(.read, kind, id))
                    let upgraded = try road(spec(.edit, kind, id))
                    let rows = try live(db, client.id, kind, id)
                    #expect(rows.map(\.id) == [upgraded], "\(name) on a \(kind): one row, the new one")
                    #expect(rows.first?.rung == .edit && rows.first?.duration == .always)
                }
            }
            // The Library's "Share N notes with AI…" (one act, one stamp).
            let other = try ops.createPost(title: "ch 2", wingId: wing.id)
            _ = try ops.grantMCPAccess(client.id, notes: [note.id, other.id], rung: .read, duration: .always)
            let bulk = try ops.grantMCPAccess(client.id, notes: [note.id, other.id], rung: .suggest, duration: .always)
            #expect(try live(db, client.id, .note, note.id).map(\.id) == [bulk[0]])
            #expect(try live(db, client.id, .note, other.id).map(\.id) == [bulk[1]])
            // Shared with AI: one row per place (the bulk act is one row of two).
            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(groups.map(\.memberCount).sorted() == [1, 1, 2], "the wing, the book, the bulk act — once each")
        }
    }

    /// Change…'s semantics on every road, a LOWER rung or a SHORTER duration
    /// included: the new grant is the place's row (PROVISIONAL P-VX393-1 —
    /// the ruling's letter; the pane shows the one row it leaves).
    @Test func aLowerOrShorterGrantReplacesTooAsChangeDoes() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "studio")
            let client = try approvedClient(ops)
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .wing, wing.id, .always))
            let shorter = try ops.grantMCPAccess(client.id, spec(.read, .wing, wing.id, .connection))
            let rows = try live(db, client.id, .wing, wing.id)
            #expect(rows.map(\.id) == [shorter] && rows.first?.rung == .read && rows.first?.duration == .connection)
        }
    }

    /// Change… to ANOTHER place: the grant it names is revoked AND that place's
    /// own row is replaced — one row there afterwards.
    @Test func changingAGrantToAnotherPlaceReplacesThatPlacesRowToo() throws {
        try withOperations { ops, db in
            let first = try ops.createWing(name: "first")
            let second = try ops.createWing(name: "second")
            let client = try approvedClient(ops)
            let a = try ops.grantMCPAccess(client.id, spec(.read, .wing, first.id))
            _ = try ops.grantMCPAccess(client.id, spec(.read, .wing, second.id))
            let moved = try ops.grantMCPAccess(client.id, spec(.edit, .wing, second.id), replacing: [a])
            #expect(try live(db, client.id, .wing, first.id).isEmpty)
            #expect(try live(db, client.id, .wing, second.id).map(\.id) == [moved])
        }
    }

    // MARK: - Revoke means what it says (RED ON OLD)

    /// After an upgrade, the place's ONE row revoked leaves nothing behind — the
    /// client reaches nothing there (before: the earlier `read` row stood on,
    /// silently, under a Revoke she had pressed).
    @Test func revokingThePlacesOneRowLeavesNothingBehind() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "PlanetLillian")
            let client = try approvedClient(ops)
            _ = try ops.grantMCPAccess(client.id, spec(.read, .wing, wing.id))
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .wing, wing.id))
            let shown = try db.read { try Queries.mcpSharedRows($0) }
            #expect(shown.count == 1, "Shared with AI shows the place once")
            try ops.revokeMCPGrant(try #require(shown.first).grant.id)
            #expect(try live(db, client.id, .wing, wing.id).isEmpty, "nothing left behind")
            let grants = try db.read { try Queries.mcpGrants($0, clientID: client.id) }.map(\.ruleGrant)
            #expect(MCPGrantRule.reach(grants: grants, openBook: false, wing: wing.id) == nil,
                    "the client reaches nothing in the wing")
        }
    }

    // MARK: - What is NOT the same place, or not the same kind

    /// A ONCE grant is one act's permission, not a standing row (PROVISIONAL
    /// P-VX393-3): it neither replaces the place's standing grant nor is
    /// replaced by a new one — each stays exactly as it was asked.
    @Test func aOnceGrantNeitherReplacesNorIsReplaced() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "a note")
            let client = try approvedClient(ops)
            let standing = try ops.grantMCPAccess(client.id, spec(.read, .note, note.id, .always))
            let once = try ops.grantMCPAccess(client.id, spec(.edit, .note, note.id, .once))
            #expect(Set(try live(db, client.id, .note, note.id).map(\.id)) == [standing, once])
            let upgraded = try ops.grantMCPAccess(client.id, spec(.suggest, .note, note.id, .always))
            #expect(Set(try live(db, client.id, .note, note.id).map(\.id)) == [upgraded, once],
                    "the standing row replaced; the once grant still waits for its one act")
            let secondOnce = try ops.grantMCPAccess(client.id, spec(.read, .note, note.id, .once))
            #expect(Set(try live(db, client.id, .note, note.id).map(\.id)) == [upgraded, once, secondOnce])
        }
    }

    /// One row per CLIENT × place: another client's grant on the same place,
    /// and the same client's grants on other places, are untouched.
    @Test func oneRowPerClientAndPlaceNeverAcrossThem() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "shared")
            let book = try ops.createReading(name: "inside", kind: .book, wingId: wing.id)
            let claude = try approvedClient(ops, "claude-code")
            let codex = try approvedClient(ops, "codex")
            let theirs = try ops.grantMCPAccess(codex.id, spec(.read, .wing, wing.id))
            let onBook = try ops.grantMCPAccess(claude.id, spec(.read, .book, book.id))
            let onWing = try ops.grantMCPAccess(claude.id, spec(.edit, .wing, wing.id))
            #expect(try live(db, codex.id, .wing, wing.id).map(\.id) == [theirs])
            #expect(try live(db, claude.id, .book, book.id).map(\.id) == [onBook])
            #expect(try live(db, claude.id, .wing, wing.id).map(\.id) == [onWing])
        }
    }

    // MARK: - The migration: existing duplicates merge to the strongest (RED ON OLD)

    private let stamp = "2026-10-09T12:00:00.000Z"
    private let later = "2026-10-10T12:00:00.000Z"

    /// A store holding her screenshot's duplicates — and the edges — arrives at
    /// `v1_30` with ONE live standing row per client × place: the strongest
    /// rung; between an "always" row and a while-connected one the ALWAYS row
    /// (no while-connected grant can be serving anything when a migration runs
    /// — every server start revokes them all — so it is no standing duplicate;
    /// PROVISIONAL P-VX393-2); between equals the newest. Once grants, other
    /// clients and rows already revoked are untouched.
    @Test func aStoreWithDuplicateGrantsKeepsEachPlacesStrongestAtTheMigration() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_29_mcp_comment_words")
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', :t, :t, :t),
                         ('cl2', 'codex', '1', 'approved', :t, :t, :t);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at,
                                       consumed_at, revoked_at) VALUES
                  ('wing-read', 'cl1', 'read', 'wing', 'w1', 'always', :t, NULL, NULL),
                  ('wing-edit', 'cl1', 'edit', 'wing', 'w1', 'always', :t, NULL, NULL),
                  ('book-old',  'cl1', 'read', 'book', 'b1', 'always', :t, NULL, NULL),
                  ('book-new',  'cl1', 'read', 'book', 'b1', 'always', :l, NULL, NULL),
                  ('note-conn', 'cl1', 'write_new', 'note', 'n1', 'connection', :l, NULL, NULL),
                  ('note-always', 'cl1', 'read', 'note', 'n1', 'always', :t, NULL, NULL),
                  ('note-once', 'cl1', 'edit', 'note', 'n1', 'once', :t, NULL, NULL),
                  ('home-conn', 'cl1', 'read', 'wing', '', 'connection', :t, NULL, NULL),
                  ('home-conn2', 'cl1', 'suggest', 'wing', '', 'connection', :t, NULL, NULL),
                  ('gone', 'cl1', 'edit', 'wing', 'w1', 'always', :t, NULL, :t),
                  ('codex-wing', 'cl2', 'read', 'wing', 'w1', 'always', :t, NULL, NULL);
                """, arguments: ["t": stamp, "l": later])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            let live = Set(try String.fetchAll(db, sql: "SELECT id FROM mcp_grant WHERE revoked_at IS NULL"))
            #expect(live == ["wing-edit", "book-new", "note-always", "note-once", "home-conn2", "codex-wing"],
                    "one standing row per client × place — the strongest; once grants and other clients untouched")
            #expect(try String.fetchOne(db, sql: "SELECT revoked_at FROM mcp_grant WHERE id = 'gone'") == stamp,
                    "a row already revoked keeps its own stamp")
            let merged = try String.fetchAll(db, sql: """
                SELECT id FROM mcp_grant WHERE id IN ('wing-read', 'book-old', 'note-conn', 'home-conn')
                  AND revoked_at IS NOT NULL
                """)
            #expect(merged.count == 4, "each duplicate is revoked, never deleted")
        }
    }

    /// After `v1_30` the family holds ONE live standing grant per client ×
    /// place BY CONSTRUCTION (a partial unique index — the store refuses a
    /// second, so no future road can mint one silently), while a once grant
    /// and a revoked row may stand beside it. Local-only like its family: no
    /// `sync_version`, no trigger, the marker untouched.
    @Test func theFamilyHoldsOneStandingGrantPerPlaceByConstruction() throws {
        #expect(SyncSchema.lockstepVersion == 13, "a local-only migration never moves the marker")
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', :t, :t, :t);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                  VALUES ('g1', 'cl1', 'read', 'wing', 'w1', 'always', :t);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                  VALUES ('g2', 'cl1', 'edit', 'wing', 'w1', 'once', :t);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at, revoked_at)
                  VALUES ('g3', 'cl1', 'edit', 'wing', 'w1', 'always', :t, :t);
                """, arguments: ["t": stamp])
        }
        for duration in ["always", "connection"] {
            #expect(throws: (any Error).self, "a second live \(duration) grant on the place refuses") {
                try db.write { db in
                    try db.execute(sql: """
                        INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                          VALUES ('g4', 'cl1', 'edit', 'wing', 'w1', ?, ?)
                        """, arguments: [duration, stamp])
                }
            }
        }
        try db.read { (db: Database) throws in
            #expect(SyncSchema.table(named: "mcp_grant") == nil)
            #expect(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'mcp_grant'
                """).isEmpty)
        }
    }
}
