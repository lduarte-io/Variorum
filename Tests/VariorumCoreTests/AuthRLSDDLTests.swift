import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9c, Step 3 — the in-repo pins for `Server/supabase/04_auth_rls.sql`
/// (the mirror's RLS + RPC rework). String-level pinning, same discipline as
/// `serverSQLFilesCoverExactlyTheRegistry`: the REAL enforcement proof is
/// Step 6's env-gated integration pass against the deployed project (the
/// fake server deliberately models CAS + seq, never auth — the brief's
/// interpretation 5). What these pins buy: the artifact cannot silently
/// drift from the client's schema truth (which tables carry `owner_id`),
/// cannot drop the A5 visibility horizon while replacing `sync_pull`, and
/// cannot lose the demotion posture (anon execute revoked) in a future edit.
@Suite("Mirror auth/RLS DDL pins (Phase 9c, Step 3 — no network)")
struct AuthRLSDDLTests {
    private static func authSQL() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Tests/VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
            .appendingPathComponent("Server/supabase/04_auth_rls.sql")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// Code lines only — the pins target SQL, never prose.
    private static func strippingComments(_ sql: String) -> String {
        sql.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("--") }
            .joined(separator: "\n")
    }

    /// The client-side truth: which synced tables carry `owner_id`
    /// (introspected, never hardcoded — a future owner-carrying table that
    /// misses the mirror guards fails HERE).
    private static func ownerCarryingTables() throws -> Set<String> {
        let db = try AppDatabase.inMemory()
        return try db.read { database in
            var owners: Set<String> = []
            for table in SyncSchema.tables {
                let columns = Set(
                    try Row.fetchAll(database, sql: "PRAGMA table_info(\(table.name))")
                        .map { $0["name"] as String })
                if columns.contains("owner_id") { owners.insert(table.name) }
            }
            return owners
        }
    }

    @Test func everyMirrorTableGainsRowLevelSecurity() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        for table in SyncSchema.tables {
            #expect(sql.range(of: "alter table \(table.name) +enable row level security;",
                              options: .regularExpression) != nil,
                    "\(table.name) must get RLS enabled")
        }
    }

    @Test func theBareKeyIsDemotedExecuteRevokedFromAnonAndPublic() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        #expect(sql.contains("revoke execute on function sync_push(jsonb) from public, anon;"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, int) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_push(jsonb) to authenticated"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, int) to authenticated"))
        #expect(sql.contains("revoke all on all tables in schema public from anon, authenticated;"))
    }

    @Test func bothRPCsGateOnAnAuthenticatedUser() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        // Both function bodies re-created, each with the auth gate.
        #expect(sql.contains("create or replace function sync_push(batch jsonb)"))
        #expect(sql.contains("create or replace function sync_pull(since_seq bigint, max_rows int default 500)"))
        let gates = sql.components(separatedBy: "raise exception 'sync requires an authenticated user'").count - 1
        #expect(gates == 2, "both RPCs must refuse an unauthenticated caller (found \(gates))")
        #expect(sql.components(separatedBy: "caller := auth.uid()::text;").count - 1 == 2)
    }

    /// The owner-guard table set is the CLIENT SCHEMA's truth, introspected:
    /// every synced table carrying `owner_id` appears in BOTH functions'
    /// `owner_tables` arrays, and nothing else does.
    @Test func ownerGuardArraysMatchTheClientSchemaExactly() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        let expected = try Self.ownerCarryingTables()
        #expect(!expected.isEmpty)

        let marker = "owner_tables constant text[] := array["
        let pieces = sql.components(separatedBy: marker).dropFirst()
        #expect(pieces.count == 2, "both RPCs must declare the owner_tables guard array")
        for piece in pieces {
            guard let end = piece.range(of: "];") else {
                Issue.record("unterminated owner_tables array"); continue
            }
            let names = Set(
                piece[..<end.lowerBound]
                    .components(separatedBy: CharacterSet(charactersIn: "',\n "))
                    .filter { !$0.isEmpty })
            #expect(names == expected,
                    "owner_tables drifted from the client schema: \(names.sorted()) vs \(expected.sorted())")
        }
    }

    @Test func pushCarriesBothOwnerGuards() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        // Incoming half: a pushed row must carry the caller's owner_id
        // (NULL rejected too — `is distinct from`).
        #expect(sql.contains("(item->'columns'->>'owner_id') is distinct from caller"))
        // Stored half: a foreign-owned row is never overwritten NOR echoed
        // back in a reject.
        #expect(sql.contains("(current_jsonb->>'owner_id') is distinct from caller"))
        #expect(sql.contains("belongs to another owner"))
    }

    @Test func pullFiltersOwnerTablesToTheCaller() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        #expect(sql.contains("if tbl = any (owner_tables) then"))
        #expect(sql.contains("and t.owner_id = %L"))
    }

    /// Replacing `sync_pull` must not regress A5: the visibility horizon and
    /// the server-only column subtraction survive verbatim in 04's bodies.
    @Test func theVisibilityHorizonSurvivesTheAuthRework() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        #expect(sql.contains("t.server_written_at <= clock_timestamp() - interval '2 seconds'"),
                "04's sync_pull must keep the A5 horizon")
        #expect(sql.contains("- 'sync_version' - 'server_seq' - 'server_written_at'"),
                "server-only columns must stay subtracted from payloads")
        // And the reject branch keeps subtracting server_written_at too.
        #expect(sql.components(separatedBy: "- 'server_written_at'").count - 1 >= 2)
    }

    /// Both replaced bodies keep the 13-table allowlist in registry order —
    /// the same drift class `serverSQLFilesCoverExactlyTheRegistry` pins
    /// for 01/02.
    @Test func replacedBodiesKeepTheFullAllowlist() throws {
        let sql = Self.strippingComments(try Self.authSQL())
        for table in SyncSchema.tables {
            #expect(sql.components(separatedBy: "'\(table.name)'").count - 1 >= 2,
                    "\(table.name) missing from a replaced allowlist")
        }
    }

    /// The deployment choreography is load-bearing (SyncSpec §12) — the
    /// header must carry it so the author's paste can never be mis-ordered
    /// by a future reader. (Prose pin, deliberately: the choreography IS
    /// prose.)
    @Test func theHeaderCarriesTheLockstepChoreography() throws {
        let sql = try Self.authSQL()
        #expect(sql.contains("ONLY after the owner_id backfill has"))
        #expect(sql.contains("SyncSpec §12"))
    }
}
