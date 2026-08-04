import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9c, Step 3 — the in-repo pins for the mirror's RLS + RPC posture;
/// REWORKED at Phase 11, Step A1: `05_phase11_lockstep.sql` re-creates both
/// RPCs (the 04 header's own instruction — "future mirror tables must
/// repeat the per-table pattern below in their own lockstep migration"),
/// so the pinned truth is now the DEPLOYED COMPOSITION — the SQL files in
/// deploy (filename) order, where the LAST `create or replace` body of
/// each function is what the server runs. 04 itself is deployed history
/// and stays byte-untouched.
///
/// String-level pinning, same discipline as ever: the REAL enforcement
/// proof is the gated integration pass against the deployed project; what
/// these pins buy is that the artifacts cannot silently drift from the
/// client's schema truth (which tables sync, which carry `owner_id`, what
/// lockstep version the client expects), cannot drop the A5 visibility
/// horizon, and cannot lose the demotion posture.
@Suite("Mirror auth/RLS DDL pins (Phase 9c Step 3; reworked Phase 11 A1 — no network)")
struct AuthRLSDDLTests {
    private static func sqlFile(_ name: String) throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Tests/VariorumCoreTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
            .appendingPathComponent("Server/supabase/\(name)")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// The lockstep-event files, in deploy order. Every future event
    /// appends here; the marker pins below read the LAST one.
    private static let lockstepFiles = [
        "05_phase11_lockstep.sql",
        "06_phase13_lockstep.sql",
        "07_phase13b_lockstep.sql",
        "08_phase14b_lockstep.sql",
    ]

    /// The RLS/grant surface: 04 (the auth flip) + the lockstep events
    /// (05 Phase 11, 06 Phase 13, 07 Phase 13b), in deploy order.
    private static func composedSQL() throws -> String {
        try ([sqlFile("04_auth_rls.sql")] + lockstepFiles.map(sqlFile))
            .map(strippingComments)
            .joined(separator: "\n")
    }

    /// The body the deployed server actually runs: the LAST
    /// `create or replace function <name>` in deploy order, up to its
    /// terminating `$$;`.
    private static func finalBody(of functionName: String) throws -> String {
        let sql = try composedSQL()
        let marker = "create or replace function \(functionName)"
        guard let start = sql.range(of: marker, options: .backwards) else {
            Issue.record("no create-or-replace for \(functionName) in the composition")
            return ""
        }
        guard let end = sql.range(of: "$$;", range: start.upperBound..<sql.endIndex) else {
            Issue.record("unterminated body for \(functionName)")
            return ""
        }
        return String(sql[start.lowerBound..<end.upperBound])
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
        let sql = try Self.composedSQL()
        for table in SyncSchema.tables {
            #expect(sql.range(of: "alter table \(table.name) +enable row level security;",
                              options: .regularExpression) != nil,
                    "\(table.name) must get RLS enabled somewhere in the deployed composition")
        }
        // The server-only marker table is locked down too.
        #expect(sql.contains("alter table sync_meta enable row level security;"))
    }

    @Test func theBareKeyIsDemotedExecuteRevokedFromAnonAndPublic() throws {
        let sql = try Self.composedSQL()
        #expect(sql.contains("revoke execute on function sync_push(jsonb) from public, anon;"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, int) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_push(jsonb) to authenticated"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, int) to authenticated"))
        #expect(sql.contains("revoke all on all tables in schema public from anon, authenticated;"))
        // Phase 11: the version-check RPC keeps the same posture, and the
        // new tables get their per-table revokes (04's schema-wide revoke
        // ran before they existed).
        #expect(sql.contains("revoke execute on function sync_schema_version() from public, anon;"))
        #expect(sql.contains("grant execute on function sync_schema_version() to authenticated"))
        for table in ["canvas_layout", "lens", "lens_choice", "sync_meta",
                      "block_comment", "reading_section"] {
            #expect(sql.contains("revoke all on \(table) from anon, authenticated;"),
                    "\(table) needs its own revoke (created after 04's sweep)")
        }
    }

    @Test func bothDeployedRPCBodiesGateOnAnAuthenticatedUser() throws {
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            #expect(body.contains("raise exception 'sync requires an authenticated user'"),
                    "\(function)'s deployed body must refuse an unauthenticated caller")
            #expect(body.contains("caller := auth.uid()::text;"))
        }
    }

    /// The owner-guard table set is the CLIENT SCHEMA's truth, introspected:
    /// every synced table carrying `owner_id` appears in BOTH deployed
    /// bodies' `owner_tables` arrays, and nothing else does.
    @Test func ownerGuardArraysMatchTheClientSchemaExactly() throws {
        let expected = try Self.ownerCarryingTables()
        #expect(!expected.isEmpty)

        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            let marker = "owner_tables constant text[] := array["
            guard let start = body.range(of: marker),
                  let end = body.range(of: "];", range: start.upperBound..<body.endIndex)
            else {
                Issue.record("\(function)'s deployed body lacks the owner_tables array")
                continue
            }
            let names = Set(
                body[start.upperBound..<end.lowerBound]
                    .components(separatedBy: CharacterSet(charactersIn: "',\n "))
                    .filter { !$0.isEmpty })
            #expect(names == expected,
                    "\(function) owner_tables drifted from the client schema: \(names.sorted()) vs \(expected.sorted())")
        }
    }

    /// Same drift class for the allowlists: the deployed bodies must allow
    /// exactly the registry's tables.
    @Test func deployedAllowlistsMatchTheRegistryExactly() throws {
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            let marker = "allowed constant text[] := array["
            guard let start = body.range(of: marker),
                  let end = body.range(of: "];", range: start.upperBound..<body.endIndex)
            else {
                Issue.record("\(function)'s deployed body lacks the allowed array")
                continue
            }
            let names = Set(
                body[start.upperBound..<end.lowerBound]
                    .components(separatedBy: CharacterSet(charactersIn: "',\n "))
                    .filter { !$0.isEmpty })
            #expect(names == Set(SyncSchema.tables.map(\.name)),
                    "\(function)'s allowlist drifted from the registry")
        }
    }

    @Test func pushCarriesBothOwnerGuards() throws {
        let body = try Self.finalBody(of: "sync_push")
        // Incoming half: a pushed row must carry the caller's owner_id
        // (NULL rejected too — `is distinct from`).
        #expect(body.contains("(item->'columns'->>'owner_id') is distinct from caller"))
        // Stored half: a foreign-owned row is never overwritten NOR echoed
        // back in a reject.
        #expect(body.contains("(current_jsonb->>'owner_id') is distinct from caller"))
        #expect(body.contains("belongs to another owner"))
    }

    @Test func pullFiltersOwnerTablesToTheCaller() throws {
        let body = try Self.finalBody(of: "sync_pull")
        #expect(body.contains("if tbl = any (owner_tables) then"))
        #expect(body.contains("and t.owner_id = %L"))
    }

    /// Replacing `sync_pull` must not regress A5: the visibility horizon and
    /// the server-only column subtraction survive verbatim in the DEPLOYED
    /// bodies (04's and 05's alike).
    @Test func theVisibilityHorizonSurvivesEveryRework() throws {
        let pull = try Self.finalBody(of: "sync_pull")
        #expect(pull.contains("t.server_written_at <= clock_timestamp() - interval '2 seconds'"),
                "the deployed sync_pull must keep the A5 horizon")
        #expect(pull.contains("- 'sync_version' - 'server_seq' - 'server_written_at'"),
                "server-only columns must stay subtracted from payloads")
        let push = try Self.finalBody(of: "sync_push")
        #expect(push.contains("- 'sync_version' - 'server_seq' - 'server_written_at'"),
                "the reject branch keeps subtracting server-only columns")
    }

    // MARK: - The §12 version-check mechanism (Phase 11, A1)

    /// THE DRIFT PIN: the marker the LATEST lockstep file deploys must
    /// equal the client's `SyncSchema.lockstepVersion` — a future lockstep
    /// event that bumps one side without the other fails the build here.
    @Test func theDeployedLockstepMarkerMatchesTheClientVersion() throws {
        let sql = Self.strippingComments(try Self.sqlFile(Self.lockstepFiles.last!))
        guard let range = sql.range(
            of: #"insert into sync_meta \(key, value\) values \('lockstep_version', '(\d+)'\)"#,
            options: .regularExpression)
        else {
            Issue.record("the latest lockstep file must end by inserting the marker")
            return
        }
        let insert = String(sql[range])
        let digits = insert.components(separatedBy: "'")
            .compactMap { Int($0) }
        #expect(digits.last == SyncSchema.lockstepVersion,
                "the mirror marker (\(String(describing: digits.last))) must equal SyncSchema.lockstepVersion (\(SyncSchema.lockstepVersion))")
        // And the deploy-order history is monotonic: each event's marker
        // exceeds its predecessor's (a re-run of an OLD file after a newer
        // deploy would silently downgrade the advertised version — the
        // on-conflict upsert makes the last run win).
        var previous = 1
        for file in Self.lockstepFiles {
            let fileSQL = Self.strippingComments(try Self.sqlFile(file))
            guard let markerRange = fileSQL.range(
                of: #"insert into sync_meta \(key, value\) values \('lockstep_version', '(\d+)'\)"#,
                options: .regularExpression),
                  let value = String(fileSQL[markerRange])
                    .components(separatedBy: "'").compactMap(Int.init).last
            else {
                Issue.record("\(file) must insert a lockstep marker")
                continue
            }
            #expect(value > previous, "\(file)'s marker must exceed its predecessor's")
            previous = value
        }
    }

    @Test func theVersionRPCReadsTheMarkerAndDefaultsToOne() throws {
        let body = try Self.finalBody(of: "sync_schema_version")
        #expect(body.contains("security definer"))
        #expect(body.contains("from sync_meta where key = 'lockstep_version'"))
        #expect(body.contains("coalesce"), "a missing marker row reads as the pre-marker era")
        #expect(body.contains("), 1)"), "the pre-marker era is DEFINED as version 1")
    }

    /// The marker insert is EVERY lockstep file's LAST STATEMENT — a
    /// partially-executed deploy must never advertise the new version
    /// before the tables exist.
    @Test func theMarkerInsertIsTheLastStatementOfEveryLockstepFile() throws {
        for file in Self.lockstepFiles {
            let sql = Self.strippingComments(try Self.sqlFile(file))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(sql.hasSuffix("on conflict (key) do update set value = excluded.value;"),
                    "\(file): the lockstep marker upsert must terminate the file")
        }
    }

    // MARK: - Header choreography pins (prose, deliberately)

    @Test func theHeaderCarriesTheLockstepChoreography() throws {
        let sql04 = try Self.sqlFile("04_auth_rls.sql")
        #expect(sql04.contains("ONLY after the owner_id backfill has"))
        #expect(sql04.contains("SyncSpec §12"))
        let sql05 = try Self.sqlFile("05_phase11_lockstep.sql")
        #expect(sql05.contains("THE CHOREOGRAPHY"))
        #expect(sql05.contains("this file runs on the mirror FIRST"))
        #expect(sql05.contains("SyncSpec §12"))
        #expect(sql05.contains("NEVER headless"))
        // 06 (Phase 13): the choreography adapts to R53 — the deploy is
        // pre-authorized and the lockstep is mirror → Mac only (the phone
        // app is removed); the header must carry that record, not 05's.
        let sql06 = try Self.sqlFile("06_phase13_lockstep.sql")
        #expect(sql06.contains("THE CHOREOGRAPHY"))
        #expect(sql06.contains("this file runs on the mirror FIRST"))
        #expect(sql06.contains("SyncSpec §12"))
        #expect(sql06.contains("PRE-AUTHORIZED"))
        #expect(sql06.contains("R53"))
        #expect(sql06.contains("MIRROR → MAC only"))
        // 07 (Phase 13b, Stage 4): pre-authorized by the EOL addendum;
        // executed by the ORCHESTRATOR at the consolidated window, never a
        // batch implementer; still mirror → Mac only (the phone stays
        // uninstalled). And the no-RPC-rework reading is stated: v1_12
        // adds a column to an allowlisted table — 06's bodies stand.
        let sql07 = try Self.sqlFile("07_phase13b_lockstep.sql")
        #expect(sql07.contains("THE CHOREOGRAPHY"))
        #expect(sql07.contains("this file runs on the mirror FIRST"))
        #expect(sql07.contains("SyncSpec §12"))
        #expect(sql07.contains("PRE-AUTHORIZED"))
        #expect(sql07.contains("MIRROR → MAC only"))
        #expect(sql07.contains("NO RPC REWORK RIDES THIS EVENT"))
        #expect(sql07.contains("ORCHESTRATOR"))
        // 08 (Phase 14b): the vault event. Deploy is the ARCHITECT's gate
        // act (conditionally pre-authorized, Rounds 4/5 — ladder-clean
        // overnight or the morning checklist), never a batch implementer's;
        // no RPC rework (key_vault is account data, never a mirror table);
        // the marker bump is what fences pre-14b builds off the encrypted
        // corpus (wipe-and-repush, R-2).
        let sql08 = try Self.sqlFile("08_phase14b_lockstep.sql")
        #expect(sql08.contains("THE CHOREOGRAPHY"))
        #expect(sql08.contains("this file runs on the mirror FIRST"))
        #expect(sql08.contains("SyncSpec §12"))
        #expect(sql08.contains("ARCHITECT"))
        #expect(sql08.contains("never a batch implementer"))
        #expect(sql08.contains("NO RPC REWORK RIDES THIS EVENT"))
        #expect(sql08.contains("A1 rail"))
        #expect(sql08.contains("wipe-and-repush"))
    }

    // MARK: - The key_vault pins (Phase 14b — the vault is ACCOUNT data on
    // owner-only RLS, reached via plain authenticated PostgREST; it must
    // never look like a sync-mirror table)

    @Test func theVaultTableIsOwnerOnlyRLSWithRealPolicies() throws {
        let sql = Self.strippingComments(try Self.sqlFile("08_phase14b_lockstep.sql"))
        #expect(sql.contains("create table key_vault ("))
        #expect(sql.contains("alter table key_vault enable row level security;"))
        // Every policy binds to auth.uid() — the P-ii-verified pattern.
        for policy in ["key_vault_owner_select", "key_vault_owner_insert",
                       "key_vault_owner_update"] {
            #expect(sql.contains("create policy \(policy) on key_vault"),
                    "\(policy) missing")
        }
        #expect(sql.contains("using (auth.uid() = user_id)"))
        #expect(sql.contains("with check (auth.uid() = user_id)"))
        // The bare key stays demoted; authenticated reaches the vault ONLY
        // through RLS. And deliberately NO delete policy/grant: losing the
        // vault orphans the whole ciphertext corpus.
        #expect(sql.contains("revoke all on key_vault from anon;"))
        #expect(sql.contains("grant select, insert, update on key_vault to authenticated;"))
        #expect(!sql.contains("for delete"), "no casual delete door on the vault")
        #expect(!sql.contains("delete on key_vault"), "no delete grant on the vault")
    }

    /// The vault row's columns carry the client's KeyVaultFormat exactly:
    /// the twice-wrapped master (recovery wrap NULLABLE — the Round-5
    /// overnight state), both v1 class keys WITH their key ids (R-8; the
    /// AAD binds ciphertexts to a key id), and the versioned KDF
    /// descriptor (R-7's soft door).
    @Test func theVaultColumnsCarryTheFormatFieldsExactly() throws {
        let sql = Self.strippingComments(try Self.sqlFile("08_phase14b_lockstep.sql"))
        for column in [
            "user_id", "format_version",
            "kdf_algorithm", "kdf_argon2_version", "kdf_memory_kib",
            "kdf_iterations", "kdf_parallelism", "kdf_salt", "kdf_output_bytes",
            "master_wrapped_by_passphrase", "master_wrapped_by_recovery",
            "corpus_key_id", "corpus_key_wrapped_by_master",
            "journal_bridge_key_id", "journal_bridge_key_wrapped_by_master",
            "created_at", "updated_at",
        ] {
            #expect(sql.contains(column), "key_vault lacks column \(column)")
        }
        #expect(sql.range(
            of: #"master_wrapped_by_recovery\s+text,"#,
            options: .regularExpression) != nil,
            "the recovery wrap must be NULLABLE (the Round-5 overnight state)")
        #expect(sql.range(
            of: #"master_wrapped_by_passphrase\s+text not null"#,
            options: .regularExpression) != nil)
        // Never in the sync allowlists: the deployed RPC bodies must not
        // mention the vault (it is not a mirror table).
        for function in ["sync_push", "sync_pull"] {
            #expect(!(try Self.finalBody(of: function)).contains("key_vault"),
                    "\(function) must never touch key_vault")
        }
    }

    @Test func theHeaderCarriesTheSignupsOffPrecondition() throws {
        let sql = try Self.sqlFile("04_auth_rls.sql")
        #expect(sql.contains("LOAD-BEARING PRECONDITION"))
        #expect(sql.contains("Allow new users to sign up"))
        #expect(sql.contains("/auth/v1/signup"))
    }
}
