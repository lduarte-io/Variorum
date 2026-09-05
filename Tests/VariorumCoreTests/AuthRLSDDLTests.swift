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
        "09_phase14c_multitenant.sql",
        "10_phase13j_purge.sql",
        "11_pre13x_postures.sql",
    ]

    /// The DATA RPCs — every function 11 re-creates with `key_proof` beside
    /// `active_key_id` (+ the new re-encryption door). `account_purge` is
    /// deliberately NOT here: deletion is mandated and loud, session-only.
    private static let proofGatedFunctions = [
        "sync_push", "sync_pull", "sync_horizon", "sync_purge_ledger",
        "sync_purge_execute", "account_data_truncate", "sync_reencrypt",
    ]

    /// Which lockstep file BORE each registry table's multi-tenant DDL.
    /// 09 is the clean rebuild (the original 18); tables that joined the
    /// registry at a LATER event carry their born-multi-tenant pattern in
    /// their own file (13j: `purge_intent` in 10). The reborn pin below
    /// reads each table's own bearer.
    private static func bearingFile(of tableName: String) -> String {
        tableName == "purge_intent" ? "10_phase13j_purge.sql" : "09_phase14c_multitenant.sql"
    }

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
            // Phase 14c: `caller` is a real uuid now (the composite PK's
            // type), no longer text-cast at assignment.
            #expect(body.contains("caller := auth.uid();"))
        }
    }

    // MARK: - Phase 14c: the born-multi-tenant rebuild pins (batch 1)

    /// The OLD RPC signatures must be dropped BEFORE the new ones exist:
    /// Postgres overloads by signature, so a lingering sync_pull(bigint,
    /// int) would keep serving the ten ownerless tables to any
    /// authenticated caller with no owner filter, no fence, and no
    /// entitlement — a cross-tenant read door beside the new one.
    @Test func theOldRPCSignaturesAreDroppedByTheRebuild() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        #expect(sql.contains("drop function if exists sync_push(jsonb);"))
        #expect(sql.contains("drop function if exists sync_pull(bigint, int);"))
        // And the new signatures carry the fence parameter + the posture.
        #expect(sql.contains("create or replace function sync_push(batch jsonb, active_key_id text)"))
        #expect(sql.contains("create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500)"))
        #expect(sql.contains("revoke execute on function sync_push(jsonb, text) from public, anon;"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, text, int) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_push(jsonb, text) to authenticated, service_role;"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, text, int) to authenticated, service_role;"))
    }

    /// Every data table is REBUILT with the composite tenant identity:
    /// owner_id uuid NOT NULL, primary key (owner_id, id) — (owner_id,
    /// key) for setting — the (owner_id, server_seq) changefeed index,
    /// and FORCED RLS with an owner policy. Registry-driven, so a future
    /// table that misses the rebuild pattern fails here.
    @Test func everyDataTableIsRebornMultiTenant() throws {
        // 13j rework (batch 6b): each table's checks read the file that
        // BORE its multi-tenant DDL — 09's rebuild for the original 18,
        // a later lockstep event's own file for tables born after it
        // (purge_intent in 10). A table BORN at a later event is created,
        // never dropped-and-rebuilt, so the drop assertion applies only
        // to 09's rebuilds; every other pattern assertion is identical.
        for table in SyncSchema.tables {
            let bearer = Self.bearingFile(of: table.name)
            let sql = Self.strippingComments(try Self.sqlFile(bearer))
            if bearer == "09_phase14c_multitenant.sql" {
                #expect(sql.contains("drop table if exists \(table.name);"),
                        "\(table.name) must be dropped before its rebuild")
            }
            #expect(sql.range(of: #"create table \#(table.name) \(\s*\n\s*owner_id\s+uuid not null,"#,
                              options: .regularExpression) != nil,
                    "\(table.name) must be reborn with owner_id uuid NOT NULL leading the composite PK")
            #expect(sql.contains("primary key (owner_id, \(table.primaryKey))"),
                    "\(table.name) must carry the composite PK (owner_id, \(table.primaryKey))")
            #expect(sql.contains("create index idx_owner_seq_\(table.name) on \(table.name) (owner_id, server_seq);"),
                    "\(table.name) needs its (owner_id, server_seq) changefeed index")
            #expect(sql.contains("alter table \(table.name) enable row level security;"),
                    "\(table.name) must re-enable RLS (the 04-era enable died with the drop)")
            #expect(sql.contains("alter table \(table.name) force row level security;"),
                    "\(table.name) must FORCE RLS — the ruled hybrid's database-enforced layer")
            #expect(sql.contains("create policy \(table.name)_owner_all on \(table.name)"),
                    "\(table.name) needs its owner policy")
            #expect(sql.contains("revoke all on \(table.name) from anon, authenticated;"),
                    "\(table.name) needs its direct-privilege revoke (the 04 sweep predates the rebuild)")
            #expect(sql.contains("create trigger stamp_seq_\(table.name) before insert or update on \(table.name)"),
                    "\(table.name) needs its seq/written-at stamp trigger back")
        }
        // The owner policies bind ALL roles (no `to` clause): under FORCE
        // RLS the definer role itself must match a policy, or the RPCs
        // default-deny themselves. Checked in BOTH bearing files (13j).
        for file in ["09_phase14c_multitenant.sql", "10_phase13j_purge.sql"] {
            let sql = Self.strippingComments(try Self.sqlFile(file))
            #expect(!sql.contains("_owner_all on") || !sql.contains("for all to authenticated"),
                    "\(file): owner policies must not carry a `to` clause — FORCE RLS binds the definer too")
            #expect(sql.contains("for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());"))
        }
    }

    /// THE VAULT-KEY-ID FENCE (THE DESIGN item 2) — since pre-13x 11 it
    /// lives in the ONE gate helper every data body calls first: the gate
    /// reads the caller's vault row FOR SHARE, compares the presented
    /// active_key_id against its corpus key id and refuses the whole
    /// round on mismatch OR a missing vault row, with the marker the
    /// client classifies into the CF-16 replaced state — then checks the
    /// proof. Every DATA body carries the call; `account_purge` does not.
    @Test func everyDeployedDataBodyCallsTheGateAndTheGateCarriesTheFence() throws {
        for function in Self.proofGatedFunctions {
            let body = try Self.finalBody(of: function)
            #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"),
                    "\(function) must call the gate — the fence + the proof — before any row is touched")
            #expect(!body.contains("select corpus_key_id into fence_key"),
                    "\(function) must not inline a second fence beside the gate's")
        }
        let gate = try Self.finalBody(of: "sync_key_gate")
        #expect(gate.contains("select corpus_key_id into fence_key from key_vault where user_id = caller for share;"),
                "the gate reads the caller's vault key id under a SHARE lock (decision 31)")
        #expect(gate.contains("if fence_key is null or fence_key is distinct from active_key_id then"),
                "the gate must fence on mismatch AND on a missing vault row")
        #expect(gate.contains(SyncServerRefusalMarker.staleKeyFence),
                "the fence refusal must carry the client-classifiable marker")
        #expect(gate.contains("perform sync_key_proof_check(key_proof);"),
                "the fence is followed by the proof — the authorization")
        let purge = try Self.finalBody(of: "account_purge")
        #expect(!purge.contains("sync_key_gate") && !purge.contains("key_proof"),
                "account_purge stays session-only — deletion is mandated and loud (decision 12)")
    }

    /// THE ENTITLEMENT GATE (THE DESIGN item 5): both deployed bodies
    /// enforce the hosted_sync entitlement from birth, with the
    /// client-classifiable marker.
    @Test func bothDeployedRPCBodiesEnforceEntitlement() throws {
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            #expect(body.contains("from entitlement"))
            #expect(body.contains("feature = 'hosted_sync'"))
            #expect(body.contains("(expires_at is null or expires_at > now())"))
            #expect(body.contains(SyncServerRefusalMarker.notEntitled),
                    "\(function)'s entitlement refusal must carry the client-classifiable marker")
        }
    }

    /// The entitlement table itself: born clean, never a mirror table
    /// (not in the allowlists), owner-only SELECT for the apps' reads,
    /// no write grants to authenticated, and the deploy-path seed for
    /// every existing auth user (= the author, with signups off).
    @Test func theEntitlementTableIsBornCleanAndSeeded() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        #expect(sql.contains("create table entitlement ("))
        #expect(sql.contains("primary key (user_id, feature)"))
        #expect(sql.contains("alter table entitlement enable row level security;"))
        #expect(sql.contains("create policy entitlement_owner_select on entitlement"))
        #expect(sql.contains("for select to authenticated using (auth.uid() = user_id);"))
        #expect(sql.contains("revoke all on entitlement from anon, authenticated;"))
        #expect(sql.contains("grant select on entitlement to authenticated;"))
        #expect(!sql.contains("grant insert") && !sql.contains("grant update"),
                "entitlement writes are server-side only (the webhook function / service_role)")
        #expect(sql.contains("select id, 'hosted_sync', '14c-deploy-seed' from auth.users"),
                "the deploy path seeds every existing auth user — hers, by construction")
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            #expect(!body.contains("'entitlement'"),
                    "\(function)'s allowlist must never carry entitlement — it is account data, not sync data")
        }
    }

    /// The tenant-scoped CAS: every lookup in the deployed push body keys
    /// on (caller, id) — the composite identity — for the lock+read, the
    /// replace-delete, and the stamp-on-insert.
    @Test func theDeployedPushBodyIsTenantScoped() throws {
        let body = try Self.finalBody(of: "sync_push")
        #expect(body.contains("where t.owner_id = $2 and t.%I = $1 for update"),
                "the CAS lock+read must be tenant-scoped")
        #expect(body.contains("delete from %I where owner_id = $2 and %I = $1"),
                "the CAS replace-delete must be tenant-scoped")
        #expect(body.contains("jsonb_build_object('sync_version', 1, 'owner_id', caller)"),
                "owner is stamped server-side into every insert")
        #expect(body.contains("jsonb_build_object('sync_version', current_version + 1, 'owner_id', caller)"))
        // The reject payload subtracts the stamped owner for the
        // mirror-only-owner tables (the client has no home for it).
        #expect(body.contains("else current_jsonb - 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id'"),
                "reject payloads must subtract owner_id for the mirror-only-owner tables")
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

    /// Phase 14c rework: the incoming client-carried owner guard survives
    /// for the eight owner-carrying tables; the 04-era STORED-half guard
    /// ("belongs to another owner") is deliberately RETIRED — the
    /// tenant-scoped CAS read cannot see another owner's row at all, so
    /// the guard became unreachable dead code (structural
    /// unaddressability replaces it; the two-user suites prove the
    /// behavior end-to-end).
    @Test func pushCarriesTheClientOwnerGuard() throws {
        let body = try Self.finalBody(of: "sync_push")
        // Incoming half: a pushed row must carry the caller's owner_id
        // (NULL rejected too — `is distinct from`).
        #expect(body.contains("(item->'columns'->>'owner_id') is distinct from caller"))
        #expect(body.contains("owner_id mismatch"))
    }

    /// Phase 14c: EVERY table's changefeed branch is tenant-scoped (not
    /// just the eight owner-carrying ones — 04's letter), and the
    /// mirror-only-owner branch subtracts the stamped owner_id.
    @Test func pullFiltersEveryTableToTheCallerAndSubtractsTheStampedOwner() throws {
        let body = try Self.finalBody(of: "sync_pull")
        #expect(body.contains("where t.owner_id = %L"),
                "every branch must filter to the caller's partition")
        // Both branches exist: keep-owner (client-carried) and
        // subtract-owner (mirror-only).
        #expect(body.contains("if tbl = any (owner_tables) then"))
        #expect(body.contains("- 'sync_version' - 'server_seq' - 'server_written_at' - 'owner_id' as cols"),
                "the mirror-only-owner branch must subtract the stamped owner_id")
        // And no branch is left unfiltered: every `from %I t` is followed
        // by the owner predicate in this body.
        let fromCount = body.components(separatedBy: "from %I t").count - 1
        let ownerFilterCount = body.components(separatedBy: "where t.owner_id = %L").count - 1
        #expect(fromCount == ownerFilterCount && fromCount > 0,
                "every changefeed branch must carry the owner filter (\(fromCount) from vs \(ownerFilterCount) filters)")
    }

    /// A named `constant text[] := array[...]` list inside a deployed
    /// function body, parsed for the drift pins (the allowlist/owner-array
    /// pattern, shared by the batch-2 account doors).
    private static func namedArray(_ name: String, in body: String) -> Set<String>? {
        let marker = "\(name) constant text[] := array["
        guard let start = body.range(of: marker),
              let end = body.range(of: "];", range: start.upperBound..<body.endIndex)
        else { return nil }
        return Set(
            body[start.upperBound..<end.lowerBound]
                .components(separatedBy: CharacterSet(charactersIn: "',\n "))
                .filter { !$0.isEmpty })
    }

    // MARK: - Phase 14c batch 2: the account lifecycle doors (THE DESIGN 3–4)

    /// CF-8's server half: the truncate door is auth-gated, FENCED (the
    /// sync RPCs' exact vault-key-id arm with the same classifiable
    /// marker — the re-key order's server-side enforcement: only the
    /// freshly-written vault's holder can empty the account), strictly
    /// tenant-scoped row deletes over EXACTLY the registry's tables, and
    /// never touches key_vault / entitlement / sync_meta. Deliberately NO
    /// entitlement gate (data removal is a right, never commerce-gated).
    @Test func theAccountTruncateDoorIsFencedTenantScopedAndRegistryExact() throws {
        let body = try Self.finalBody(of: "account_data_truncate")
        #expect(body.contains("raise exception 'account acts require an authenticated user'"))
        // pre-13x 11: the fence + the proof ride the ONE gate helper (the
        // gate's own pin holds the fence's letter); the right
        // active_key_id WITHOUT the proof deletes nothing.
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"),
                "the truncate must call the gate — the fence, then the proof")
        #expect(body.contains("delete from %I where owner_id = $1"),
                "row deletes, tenant-scoped by the composite identity — never TRUNCATE")
        #expect(!body.lowercased().contains("truncate table"),
                "TRUNCATE would cross tenants; the door is row-scoped by design")
        #expect(Self.namedArray("data_tables", in: body) == Set(SyncSchema.tables.map(\.name)),
                "the truncate's table list drifted from the registry")
        #expect(!body.contains("delete from key_vault"),
                "the truncate must never touch the vault — the new vault IS the re-key")
        #expect(!body.contains("delete from entitlement") && !body.contains("from entitlement"),
                "the truncate must never touch entitlement (the tier survives a re-key; no commerce gate either)")
        #expect(!body.contains("sync_meta"),
                "the marker is schema choreography — never the truncate's")
        #expect(!body.lowercased().contains("restart") && !body.lowercased().contains("setval"),
                "server_seq's sequence is never reset (SyncSpec §9)")
    }

    /// The deletion door's purge (her Round-5 ruling): data rows →
    /// key_vault → entitlement → THE AUTH USER LAST. The order is the
    /// RULED reporting shape, pinned as a deliberate choice — NOT an FK
    /// necessity (corrected 2026-08-05, ladder R1-2: key_vault.user_id's
    /// FK is ON DELETE CASCADE per 08, so user-first would cascade the
    /// vault row; explicit removals keep the counts report exact). No
    /// fence (deletion supersedes re-key) and no entitlement gate
    /// (deletion is a right). The local-copy-survives rule is true by
    /// construction — the body names only server tables.
    @Test func theAccountPurgeRemovesDataVaultEntitlementThenTheAuthUser() throws {
        let body = try Self.finalBody(of: "account_purge")
        #expect(body.contains("raise exception 'account acts require an authenticated user'"))
        #expect(Self.namedArray("data_tables", in: body) == Set(SyncSchema.tables.map(\.name)),
                "the purge's table list drifted from the registry")
        #expect(body.contains("delete from %I where owner_id = $1"),
                "data deletes are tenant-scoped by the composite identity")
        #expect(body.contains("delete from key_vault where user_id = caller;"))
        #expect(body.contains("delete from entitlement where user_id = caller;"))
        #expect(body.contains("delete from auth.users where id = caller;"))
        // The ORDER: the ruled reporting shape (deliberate, not FK-forced
        // — the vault FK is CASCADE; ladder R1-2); entitlement rides
        // between by the ruling's letter.
        let vault = try #require(body.range(of: "delete from key_vault"))
        let entitlement = try #require(body.range(of: "delete from entitlement"))
        let authUser = try #require(body.range(of: "delete from auth.users"))
        #expect(vault.lowerBound < entitlement.lowerBound
                && entitlement.lowerBound < authUser.lowerBound,
                "the purge order is data → vault → entitlement → auth user")
        #expect(!body.contains(SyncServerRefusalMarker.staleKeyFence),
                "no fence on deletion — deletion supersedes re-key")
        #expect(!body.contains(SyncServerRefusalMarker.notEntitled),
                "no entitlement gate on deletion — deletion is a right")
        #expect(!body.contains("sync_meta"))
        for key in ["'data_rows'", "'vault_rows'", "'entitlement_rows'", "'auth_user_removed'"] {
            #expect(body.contains(key), "the purge report must carry \(key)")
        }
    }

    /// Both account doors take the demotion posture: authenticated only —
    /// deliberately NO service_role grant (account acts are always a
    /// signed-in user's own, never server machinery's).
    @Test func theAccountDoorsCarryTheDemotionPosture() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        // service_role joined both revokes at the 14c gate (2026-08-11): the
        // live sweep caught Supabase's CREATE-time default-privilege grant to
        // service_role surviving the public+anon-only revokes — the pin now
        // demands the demotion be named in full, making this test's own
        // "never server machinery's" doc comment literal.
        #expect(sql.contains("revoke execute on function account_data_truncate(text) from public, anon, service_role;"))
        #expect(sql.contains("revoke execute on function account_purge() from public, anon, service_role;"))
        #expect(sql.contains("grant execute on function account_data_truncate(text) to authenticated;"))
        #expect(sql.contains("grant execute on function account_purge() to authenticated;"))
        #expect(!sql.contains("grant execute on function account_data_truncate(text) to authenticated, service_role")
                && !sql.contains("grant execute on function account_purge() to authenticated, service_role"),
                "the account doors are never server machinery's")
    }

    /// Phase 14c batch 3 (L9): the entitlement-WRITE door — the checkout
    /// webhook's ONE server function. Processor-agnostic (who / feature /
    /// active / until / via — no processor ids, no price), grant is an
    /// UPSERT (renewals move expires_at through the same call), revoke is
    /// a row DELETE (a row IS the entitlement), and the posture is
    /// service_role ONLY: the apps never write entitlement (batch 1's
    /// letter), so `authenticated` holds no execute grant here.
    @Test func theEntitlementWriteDoorIsServiceRoleOnlyAndProcessorAgnostic() throws {
        let body = try Self.finalBody(of: "entitlement_set")
        #expect(body.contains(
            "insert into entitlement (user_id, feature, granted_at, source, expires_at)"),
                "the grant arm writes the entitlement row's own facts — nothing processor-shaped")
        #expect(body.contains("on conflict (user_id, feature) do update"),
                "a renewal re-grants through the same call — upsert, never an error")
        #expect(body.contains("delete from entitlement"),
                "revoke is a row DELETE — a row IS the entitlement; history is the processor's")
        #expect(!body.contains("auth.uid()"),
                "the webhook has no user session — identity is the parameter, never the caller")
        #expect(body.contains("security definer"))

        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        #expect(sql.contains(
            "revoke execute on function entitlement_set(uuid, text, boolean, timestamptz, text) from public, anon, authenticated;"),
                "the apps (authenticated) are revoked by name — they never write entitlement")
        #expect(sql.contains(
            "grant execute on function entitlement_set(uuid, text, boolean, timestamptz, text) to service_role;"))
        #expect(!sql.contains("entitlement_set(uuid, text, boolean, timestamptz, text) to authenticated"),
                "no grant road back to the apps, ever")
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
    /// before the tables exist. Phase 14c: a file may now close with
    /// `commit;` (09's one-transaction wrapping, finding I-3), so the
    /// marker must be the last statement INSIDE the transaction — the
    /// same discipline, one statement further in.
    @Test func theMarkerInsertIsTheLastStatementOfEveryLockstepFile() throws {
        for file in Self.lockstepFiles {
            var sql = Self.strippingComments(try Self.sqlFile(file))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if sql.hasSuffix("commit;") {
                sql = String(sql.dropLast("commit;".count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            #expect(sql.hasSuffix("on conflict (key) do update set value = excluded.value;"),
                    "\(file): the lockstep marker upsert must be the last statement (inside the transaction, where one is opened)")
        }
    }

    // MARK: - Phase 14c, the dedicated isolation round: the deploy-shape
    // pins (findings I-3 + I-5). 09 rebuilds the whole mirror, so HOW it
    // executes is part of what it does: created-then-revoked objects must
    // never be reachable in a window, and the file must refuse to run
    // twice once real accounts exist.

    /// Statements Postgres refuses inside a transaction block — the set the
    /// wrapping must not contain. (ALTER TYPE … ADD VALUE is deliberately
    /// absent: legal inside a transaction since PG12, merely unusable in
    /// the same one, and 09 has no enum work at all.)
    private static let nonTransactionalStatements = [
        "create index concurrently", "drop index concurrently",
        "reindex concurrently", "vacuum", "create database", "drop database",
        "create tablespace", "drop tablespace", "alter system", "discard all",
    ]

    /// What can be wrong with the deploy SHAPE of a rebuild artifact — a
    /// pure check, so the doctored-fixture proof below can exercise it
    /// (the `truncateProblems` pattern): not wrapped in ONE transaction,
    /// a statement that cannot run inside one, the marker bump not last
    /// inside the transaction, the re-run guard missing, or the guard
    /// standing AFTER the first destructive statement (a guard that runs
    /// after the drops guards nothing).
    static func deployShapeProblems(strippedSQL: String) -> Set<String> {
        let sql = strippedSQL.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = sql.lowercased()
        var problems: Set<String> = []

        if !lowered.hasPrefix("begin;") { problems.insert("no-begin") }
        if !lowered.hasSuffix("commit;") { problems.insert("no-commit") }
        for statement in nonTransactionalStatements where lowered.contains(statement) {
            problems.insert("non-transactional:\(statement)")
        }

        let body = lowered.hasSuffix("commit;")
            ? String(lowered.dropLast("commit;".count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            : lowered
        if !body.hasSuffix("on conflict (key) do update set value = excluded.value;") {
            problems.insert("marker-not-last-in-transaction")
        }

        guard let guardRange = lowered.range(of: "do $rerun_guard$") else {
            problems.insert("no-rerun-guard")
            return problems
        }
        // The guard must precede every destructive statement in the file.
        for destructive in ["drop table", "drop function", "delete from", "truncate"] {
            if let first = lowered.range(of: destructive),
               first.lowerBound < guardRange.lowerBound {
                problems.insert("guard-after:\(destructive)")
            }
        }
        return problems
    }

    /// THE DEPLOY-SHAPE PIN (I-3 + I-5): 09 executes as ONE transaction,
    /// carries no statement Postgres would refuse inside one, bumps the
    /// marker last inside it, and opens with the re-run guard.
    @Test func theRebuildDeploysAsOneTransactionGuardedAgainstReRuns() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        let problems = Self.deployShapeProblems(strippedSQL: sql)
        #expect(problems.isEmpty,
                "09's deploy shape is unsound: \(problems.sorted()) — a created-then-revoked object must never be reachable in a window, and the guard must precede the drops")
    }

    /// The doctored-fixture proof that the shape check BITES (the
    /// `aDoctoredTruncateListIsFlaggedByTheCheck` pattern): each way a
    /// rebuild artifact can be mis-shaped is flagged by name.
    @Test func aDoctoredDeployShapeIsFlaggedByTheCheck() throws {
        let real = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Unwrapped (the pre-fix artifact's shape): no begin, no commit.
        let unwrapped = real
            .replacingOccurrences(of: "begin;", with: "", range: real.range(of: "begin;"))
            .replacingOccurrences(of: "commit;", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let unwrappedProblems = Self.deployShapeProblems(strippedSQL: unwrapped)
        #expect(unwrappedProblems.contains("no-begin") && unwrappedProblems.contains("no-commit"),
                "the check failed to flag an unwrapped deploy (got \(unwrappedProblems.sorted()))")

        // A guard-less artifact.
        let unguarded = real.replacingOccurrences(of: "do $rerun_guard$", with: "do $other$")
        #expect(Self.deployShapeProblems(strippedSQL: unguarded).contains("no-rerun-guard"),
                "the check failed to flag a missing re-run guard")

        // A guard moved BELOW the drops — present, and worthless.
        let lateGuard = "begin;\ndrop table if exists container;\ndo $rerun_guard$ begin end $rerun_guard$;\n"
            + "insert into sync_meta (key, value) values ('lockstep_version', '6')\n"
            + "  on conflict (key) do update set value = excluded.value;\ncommit;"
        #expect(Self.deployShapeProblems(strippedSQL: lateGuard).contains("guard-after:drop table"),
                "the check failed to flag a guard standing after the drops")

        // A statement Postgres refuses inside a transaction block.
        let concurrent = real.replacingOccurrences(
            of: "create index idx_owner_seq_container on container (owner_id, server_seq);",
            with: "create index concurrently idx_owner_seq_container on container (owner_id, server_seq);")
        #expect(Self.deployShapeProblems(strippedSQL: concurrent)
                    .contains("non-transactional:create index concurrently"),
                "the check failed to flag a statement that cannot run inside a transaction")

        // The marker no longer last inside the transaction.
        let markerNotLast = real.replacingOccurrences(
            of: "commit;", with: "revoke execute on function account_purge() from anon;\ncommit;")
        #expect(Self.deployShapeProblems(strippedSQL: markerNotLast)
                    .contains("marker-not-last-in-transaction"),
                "the check failed to flag a marker bump that is not the transaction's last statement")
    }

    /// THE RE-RUN GUARD's letter (I-5): it keys on evidence that is true
    /// ONLY after 09 itself has run — the marker at 6+, or the
    /// `entitlement` table no other artifact creates — never on "are the
    /// data tables non-empty" (under the FORCE RLS this very file installs,
    /// a deployer without BYPASSRLS reads its own tables as empty, so a
    /// data-presence condition would fail OPEN). It raises a named, hinted
    /// refusal and names the one deliberate override.
    @Test func theReRunGuardKeysOnEvidenceOnlyADeployedNineLeaves() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        #expect(sql.contains("deployed_marker >= 6 or entitlement_here"),
                "the guard must fire on the marker OR the entitlement table — both true only after 09 ran")
        #expect(sql.contains("to_regclass('public.entitlement') is not null"))
        #expect(sql.contains("VARIORUM_09_ALREADY_DEPLOYED"),
                "the refusal must be named, not generic")
        #expect(sql.contains("hint    ="), "the refusal must carry the operator's next step")
        #expect(sql.contains("current_setting('variorum.allow_09_rerun', true)")
                    && sql.contains("'yes-drop-every-tenants-data'"),
                "the deliberate override must be spelled in the file the operator is reading")
        // The first legitimate deploy MUST pass: nothing in the guard may
        // key on her corpus being present (marker 5 + rows + no entitlement
        // table is the gate's exact state).
        #expect(!sql.contains("count(*) from container"),
                "the guard must never key on data presence — FORCE RLS makes that read fail OPEN")
    }

    /// I-4: `sync_table_pk`'s demotion is COMPLETED — 04 revoked
    /// public+anon and left the `authenticated` grant that its 02-era
    /// creation inherited from Supabase's defaults. No grant replaces it:
    /// the only callers are the SECURITY DEFINER bodies, which call it as
    /// the function's OWNER.
    @Test func theHelperFunctionsExecuteGrantIsFullyRevoked() throws {
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        #expect(sql.contains(
            "revoke execute on function sync_table_pk(text) from public, anon, authenticated;"),
                "the helper's authenticated EXECUTE must be revoked — the demotion posture completed")
        let composed = try Self.composedSQL()
        #expect(!composed.contains("grant execute on function sync_table_pk"),
                "nothing may grant the helper back: the definer bodies call it as the owner")
        // The 14c-gate definer-owner repair (2026-08-11) is the ONE sanctioned
        // re-grant road, and only to variorum_definer — a NOLOGIN role no API
        // request can ever run as. The no-door-back posture holds; the grant
        // exists because ownership of the calling bodies moved off the
        // helper's owner (the BYPASSRLS repair), breaking the owner-equality
        // the original revoke reasoning rested on.
        let definerOwner = Self.strippingComments(
            try Self.sqlFile("maintenance/14c-gate-definer-owner.sql"))
        #expect(definerOwner.contains(
            "grant execute on function sync_table_pk(text) to variorum_definer;"))
        #expect(!definerOwner.contains("grant execute on function sync_table_pk(text) to authenticated")
                && !definerOwner.contains("grant execute on function sync_table_pk(text) to anon")
                && !definerOwner.contains("grant execute on function sync_table_pk(text) to public"),
                "the helper re-grant reaches only the nologin definer role")
    }

    /// THE 14C-GATE BYPASSRLS REPAIR (2026-08-11; live-probe obligation 2's
    /// consequence): the hosted `postgres` role carries BYPASSRLS — which
    /// overrides even FORCE RLS — so the ruled two-layer hybrid needed the
    /// three DATA functions owned by a dedicated NON-BYPASS role for the
    /// policy net to bind their bodies. account_purge (auth-schema DML) and
    /// entitlement_set (writes a select-only-policy table) deliberately keep
    /// postgres; the artifact's header carries the full reasoning.
    @Test func theDataDoorsAreOwnedByTheNonBypassDefinerRole() throws {
        let sql = Self.strippingComments(
            try Self.sqlFile("maintenance/14c-gate-definer-owner.sql"))
        #expect(sql.contains("create role variorum_definer with nologin nobypassrls;"))
        #expect(sql.contains("alter function sync_push(jsonb, text) owner to variorum_definer;"))
        #expect(sql.contains("alter function sync_pull(bigint, text, integer) owner to variorum_definer;"))
        #expect(sql.contains("alter function account_data_truncate(text) owner to variorum_definer;"))
        #expect(!sql.contains("alter function account_purge"),
                "the purge keeps postgres — auth-schema DML")
        #expect(!sql.contains("alter function entitlement_set"),
                "the entitlement writer keeps postgres — it writes a table whose only policy is a read")
        // The two reads the RPC bodies make against ENABLE-only tables need
        // their own own-row policies for the non-bypass owner, or the fence
        // and tier gate would default-deny every round.
        #expect(sql.contains("create policy key_vault_definer_fence_select on key_vault"))
        #expect(sql.contains("create policy entitlement_definer_gate_select on entitlement"))
        #expect(sql.contains("using (auth.uid() = user_id)"))
    }

    /// THE POST-DEPLOY GRANT SWEEP (I-3's other half; live-probe
    /// obligation 11): a committed, READ-ONLY verification query that
    /// prints the FINAL posture — every function's per-role EXECUTE and
    /// every table's RLS/policy/privilege state, each row carrying its
    /// expectation and a verdict. It must write NOTHING (the gate runs it
    /// against live production) and must cover the whole registry, so a
    /// future table cannot quietly escape the sweep.
    @Test func thePostDeployGrantSweepIsReadOnlyAndCoversEverything() throws {
        let raw = try Self.sqlFile("maintenance/14c-post-deploy-grant-sweep.sql")
        let sql = Self.strippingComments(raw)
        // Read-only: no statement in the file may START with a writing verb.
        let writingVerbs = ["create", "drop", "alter", "insert", "update", "delete",
                            "truncate", "grant", "revoke", "do ", "begin", "commit"]
        for line in sql.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces).lowercased()
            for verb in writingVerbs where trimmed.hasPrefix(verb) {
                Issue.record("the sweep must be read-only — found a statement starting `\(verb)`: \(trimmed)")
            }
        }
        #expect(sql.lowercased().contains("select"), "the sweep is a query — the pin isn't vacuous")
        // Coverage: every registry table, the three account-data tables,
        // and every function 09 or its predecessors expose.
        for table in SyncSchema.tables.map(\.name) + ["entitlement", "key_vault", "sync_meta"] {
            #expect(sql.contains("('\(table)',"),
                    "the sweep must carry an expectation for \(table)")
        }
        // pre-13x 11: every data RPC's expectation moved to its NEW
        // `key_proof` signature (11 drops the six old overloads — a
        // reappearance is the UNEXPECTED class the sweep exists to catch),
        // the two new doors and the two gate helpers joined, and the
        // vault's policy set + insert trigger + per-role UPDATE privilege
        // are asserted BY NAME (a count cannot tell the closure from
        // nothing).
        for function in ["sync_push(jsonb,text,text)", "sync_pull(bigint,text,integer,text,text)",
                         "account_data_truncate(text,text)", "account_purge()",
                         "entitlement_set(uuid,text,boolean,timestampwithtimezone,text)",
                         "sync_schema_version()", "sync_table_pk(text)",
                         "sync_horizon(text,text)", "sync_purge_ledger(bigint,text,text)",
                         "sync_purge_execute(jsonb,text,text)",
                         "sync_reencrypt(jsonb,text,text)", "key_vault_update(jsonb,integer,text)",
                         "sync_key_gate(text,text)", "sync_key_proof_check(text)",
                         "key_vault_require_proof_hash()"] {
            #expect(sql.contains("('\(function)'"),
                    "the sweep must carry an expectation for \(function)")
        }
        for old in ["('sync_push(jsonb,text)'", "('sync_pull(bigint,text,integer,text)'",
                    "('account_data_truncate(text)'", "('sync_horizon(text)'",
                    "('sync_purge_ledger(bigint,text)'", "('sync_purge_execute(jsonb,text)'"] {
            #expect(!sql.contains(old),
                    "the sweep must not EXPECT the dropped overload \(old) — it must surface it as UNEXPECTED")
        }
        for policy in ["key_vault_owner_select", "key_vault_owner_insert",
                       "key_vault_definer_fence_select", "key_vault_definer_update"] {
            #expect(sql.contains("('\(policy)')"),
                    "the sweep must expect the vault policy \(policy) by name")
        }
        #expect(!sql.contains("('key_vault_owner_update')"),
                "the dropped PATCH-road policy must never be EXPECTED — it is the UNEXPECTED class")
        #expect(sql.contains("('privilege:authenticated:UPDATE', false)"),
                "the sweep must assert the vault's UPDATE privilege is REVOKED from authenticated")
        #expect(sql.contains("('privilege:variorum_definer:UPDATE', true)"))
        #expect(sql.contains("('trigger:key_vault_require_proof_hash', true)"))
        // And it must surface an object nobody expected — a lingering old
        // RPC overload is the door this sweep exists to catch.
        #expect(sql.contains("UNEXPECTED FUNCTION"))
        #expect(sql.contains("UNEXPECTED TABLE"))
        #expect(sql.contains("UNEXPECTED POLICY"))
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
        // 09 (Phase 14c): the clean rebuild. Deploy is the ARCHITECT's
        // gate act at the author's EXPLICIT GO (choreography step 2 of
        // the ruled signup-door order), never a batch implementer's;
        // the A1 rail runs first because this file DROPS the data
        // tables; her corpus re-pushes from local truth afterwards.
        let sql09 = try Self.sqlFile("09_phase14c_multitenant.sql")
        #expect(sql09.contains("THE CHOREOGRAPHY"))
        #expect(sql09.contains("this file runs on the mirror FIRST"))
        #expect(sql09.contains("SyncSpec §12"))
        #expect(sql09.contains("ARCHITECT"))
        #expect(sql09.contains("never a batch implementer"))
        #expect(sql09.contains("EXPLICIT GO"))
        #expect(sql09.contains("A1 rail"))
        #expect(sql09.contains("re-pushes"))
        // 11 (pre-13x): the postures event. Deploy is the ORCHESTRATOR's
        // window under her standing PRE-AUTHORIZED go (design §16), never a
        // batch implementer's; scheduled immediately BEFORE batch 2's
        // migration + both installs (a marker-7 build refuses until then);
        // the A1 rail; the LIVE PATCH PROBE proves the closed write road.
        let sql11 = try Self.sqlFile("11_pre13x_postures.sql")
        #expect(sql11.contains("THE CHOREOGRAPHY"))
        #expect(sql11.contains("this file runs on the mirror FIRST"))
        #expect(sql11.contains("SyncSpec §12"))
        #expect(sql11.contains("ARCHITECT"))
        #expect(sql11.contains("never a batch implementer"))
        #expect(sql11.contains("PRE-AUTHORIZED"))
        #expect(sql11.contains("A1 rail"))
        #expect(sql11.contains("PHONE"))
        #expect(sql11.contains("LIVE PATCH PROBE"))
        #expect(sql11.contains("pre-13x-deploy-checklist.md"))
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
            "revision", "created_at", "updated_at",
        ] {
            #expect(sql.contains(column), "key_vault lacks column \(column)")
        }
        #expect(sql.range(
            of: #"master_wrapped_by_recovery\s+text,"#,
            options: .regularExpression) != nil,
            "the recovery wrap must be NULLABLE (the Round-5 overnight state)")
        // R1-2: the CAS token, server-defaulted so rows written before the
        // client carried it read as revision 1.
        #expect(sql.range(
            of: #"revision\s+integer not null default 1"#,
            options: .regularExpression) != nil,
            "key_vault needs the R1-2 revision CAS token with default 1")
        #expect(sql.range(
            of: #"master_wrapped_by_passphrase\s+text not null"#,
            options: .regularExpression) != nil)
        // Never in the sync allowlists: the vault is not a mirror table.
        // (Phase 14c rework: the deployed bodies now legitimately READ
        // key_vault — the vault-key-id fence — so the pin narrows from
        // "never mentioned" to "never allowlisted, never written".)
        // pre-13x 11: the data bodies still never write the vault. The ONE
        // vault write beside `key_vault_update` is the proof check's
        // MIGRATION ARM (the first proof landing its hash on a NULL-hash
        // row) — inside the helper, never in a data body.
        for function in Self.proofGatedFunctions {
            let body = try Self.finalBody(of: function)
            #expect(!body.contains("'key_vault'"),
                    "\(function)'s allowlist must never carry key_vault")
            #expect(!body.contains("insert into key_vault")
                        && !body.contains("update key_vault")
                        && !body.contains("delete from key_vault"),
                    "\(function) must never WRITE the vault — the gate reads it")
        }
    }

    @Test func theHeaderCarriesTheSignupsOffPrecondition() throws {
        let sql = try Self.sqlFile("04_auth_rls.sql")
        #expect(sql.contains("LOAD-BEARING PRECONDITION"))
        #expect(sql.contains("Allow new users to sign up"))
        #expect(sql.contains("/auth/v1/signup"))
    }

    // MARK: - The R-2 mirror-truncate gate artifact (Phase 14b ladder R1-1
    // — the one-time wipe half of wipe-and-repush; NOT schema choreography,
    // so it lives in maintenance/ outside the numbered chain)

    /// What can be wrong with a truncate artifact, as a pure check so the
    /// doctored-fixture proof below can exercise it (the
    /// `classificationProblems` shape): tables the registry syncs that the
    /// TRUNCATE misses (a missed table keeps pre-14b PLAINTEXT rows the
    /// decrypt seam then refuses on every pull — a permanent cursor
    /// wedge), tables the TRUNCATE names that the registry does not
    /// (anything extra is by definition not sync data — the forbidden
    /// class), the forbidden names explicitly (`key_vault`, `sync_meta`,
    /// `auth.*` — emptying the vault orphans the ciphertext corpus), and
    /// the statement count (ONE truncate statement, nothing else — no
    /// marker, no identity reset).
    static func truncateProblems(
        strippedSQL sql: String,
        registry: Set<String> = Set(SyncSchema.tables.map(\.name))
    )
        -> (missing: Set<String>, extra: Set<String>, forbidden: Set<String>,
            truncateCount: Int, statementCount: Int)
    {
        let lowered = sql.lowercased()
        let marker = "truncate table"
        var lists: [String] = []
        var searchStart = lowered.startIndex
        while let start = lowered.range(of: marker, range: searchStart..<lowered.endIndex) {
            guard let end = lowered.range(of: ";", range: start.upperBound..<lowered.endIndex)
            else { break }
            lists.append(String(lowered[start.upperBound..<end.lowerBound]))
            searchStart = end.upperBound
        }
        let named = Set(
            lists.joined(separator: ",")
                .components(separatedBy: CharacterSet(charactersIn: ", \n"))
                .filter { !$0.isEmpty })
        let forbidden = named.filter {
            $0 == "key_vault" || $0 == "sync_meta" || $0.hasPrefix("auth.")
        }
        return (
            missing: registry.subtracting(named),
            extra: named.subtracting(registry),
            forbidden: forbidden,
            truncateCount: lists.count,
            statementCount: lowered.filter { $0 == ";" }.count)
    }

    /// THE ARTIFACT PIN (R1-1): the committed gate artifact truncates
    /// EXACTLY the registry's tables — order-insensitive equality, provably
    /// free of `key_vault`/`sync_meta`/`auth.*`, one TRUNCATE statement and
    /// nothing else (no lockstep marker: the gate act is not schema
    /// choreography), and no `restart identity` (server_seq stays
    /// monotonic, SyncSpec §9).
    @Test func theMirrorTruncateArtifactMatchesTheRegistryExactly() throws {
        // 13j rework (batch 6b, annotated in place — a RULED registry
        // change, never a quietly relaxed pin): the artifact is a
        // ONE-TIME gate act, EXECUTED 2026-08-04 (twice) against the
        // 14b-era registry and superseded operationally by 14c's
        // tenant-scoped `account_data_truncate`. Its pin therefore
        // compares against the registry AS IT STOOD when the artifact
        // ran — the 18 names below, frozen — not the growing current
        // registry (13j's `purge_intent` postdates the act; demanding it
        // here would rewrite executed history). The CLAIM is unchanged:
        // the artifact that ran missed no then-synced table and touched
        // nothing forbidden.
        let registryAt14b: Set<String> = [
            "container", "block", "variant", "commit_point", "edge",
            "container_block", "reading", "reading_section", "reading_post",
            "tag", "post_tag", "block_tag", "reference", "canvas_layout",
            "lens", "lens_choice", "block_comment", "setting",
        ]
        let sql = Self.strippingComments(
            try Self.sqlFile("maintenance/14b-mirror-truncate.sql"))
        let problems = Self.truncateProblems(strippedSQL: sql, registry: registryAt14b)
        #expect(problems.missing.isEmpty,
                "the truncate artifact MISSES registry table(s) \(problems.missing.sorted()) — a missed table keeps plaintext rows and wedges every pull")
        #expect(problems.extra.isEmpty,
                "the truncate artifact names non-registry table(s) \(problems.extra.sorted())")
        #expect(problems.forbidden.isEmpty,
                "the truncate artifact must never touch \(problems.forbidden.sorted())")
        #expect(problems.truncateCount == 1, "exactly ONE truncate statement")
        #expect(problems.statementCount == 1, "the truncate is the artifact's ONLY statement")
        #expect(!sql.lowercased().contains("restart identity"),
                "server_seq's sequence is never reset (SyncSpec §9)")
        #expect(!sql.lowercased().contains("lockstep_version"),
                "the gate act bumps no marker — it is not schema choreography")
    }

    /// The artifact-class red-on-old (the doctored-fixture pattern the DDL
    /// pins use): a doctored list that skips a registry table, and one that
    /// names the vault, are both flagged — proving the pin above bites on
    /// exactly the R1-1 failure classes rather than passing vacuously.
    @Test func aDoctoredTruncateListIsFlaggedByTheCheck() {
        let allButSetting = SyncSchema.tables.map(\.name).filter { $0 != "setting" }
        let skipsATable = "truncate table\n  \(allButSetting.joined(separator: ",\n  "));"
        let skipped = Self.truncateProblems(strippedSQL: skipsATable)
        #expect(skipped.missing == ["setting"],
                "the check failed to flag the skipped table (got \(skipped.missing.sorted()))")

        let namesTheVault = "truncate table\n  "
            + (SyncSchema.tables.map(\.name) + ["key_vault"]).joined(separator: ",\n  ")
            + ";"
        let vaulted = Self.truncateProblems(strippedSQL: namesTheVault)
        #expect(vaulted.forbidden == ["key_vault"],
                "the check failed to flag the forbidden table")
        #expect(vaulted.extra == ["key_vault"])
    }

    // MARK: - Phase 13j batch 6b: the purge lockstep event (10) pins.
    // The memo (notes/plans/phase-13j-purge-memo.md) is the binding
    // design; the adjudication's two mechanical notes (the purge-execution
    // RPC; the device_cursor.seen_at disclosure) land here. The artifact
    // is FINALIZED, NOT DEPLOYED — deploy is the architect's one-window.

    /// 10 takes the 09 deploy shape: one transaction, re-run guard before
    /// the one destructive statement (the old pull-signature drop), the
    /// marker bump last inside the transaction. The same pure check that
    /// pins 09 — and the doctored-fixture proof there already shows it
    /// bites.
    @Test func thePurgeEventDeploysAsOneGuardedTransaction() throws {
        let sql = Self.strippingComments(try Self.sqlFile("10_phase13j_purge.sql"))
        let problems = Self.deployShapeProblems(strippedSQL: sql)
        #expect(problems.isEmpty,
                "10's deploy shape is unsound: \(problems.sorted())")
        // And the guard keys on evidence only a deployed 10 leaves.
        #expect(sql.contains("deployed_marker >= 7 or purge_table_here"))
        #expect(sql.contains("to_regclass('public.purge_intent') is not null"))
        #expect(sql.contains("VARIORUM_10_ALREADY_DEPLOYED"))
    }

    /// The old sync_pull overload is dropped FIRST (the 09 discipline: an
    /// overload left standing would be a cursor-less changefeed door
    /// beside the new one), the new signature carries the device
    /// parameter, and the grants move with it.
    @Test func thePurgeEventDropsTheOldPullSignatureAndCreatesTheNewOne() throws {
        let sql = Self.strippingComments(try Self.sqlFile("10_phase13j_purge.sql"))
        #expect(sql.contains("drop function if exists sync_pull(bigint, text, int);"))
        #expect(sql.contains(
            // RULED RENAME (2026-08-19): `for_device`, formerly `device_id`,
            // which shadowed the device_cursor column (the live 42702).
            "create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, for_device text default null)"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, text, int, text) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, text, int, text) to authenticated, service_role;"))
    }

    /// The three purge functions take the ACCOUNT-DOOR posture
    /// (authenticated only — a purge is a signed-in device's own act) and
    /// the DATA-function ownership (the non-bypass definer role, the 14c
    /// gate pattern), with the definer's table grants for the rows their
    /// bodies touch.
    @Test func thePurgeFunctionsCarryTheAccountDoorPostureAndDefinerOwnership() throws {
        let sql = Self.strippingComments(try Self.sqlFile("10_phase13j_purge.sql"))
        for function in ["sync_horizon(text)", "sync_purge_ledger(bigint, text)",
                         "sync_purge_execute(jsonb, text)"] {
            #expect(sql.contains("revoke execute on function \(function) from public, anon, service_role;"),
                    "\(function) must be revoked from server machinery by name")
            #expect(sql.contains("grant execute on function \(function) to authenticated;"))
            #expect(sql.contains("alter function \(function.replacingOccurrences(of: ", ", with: ", ")) owner to variorum_definer;"),
                    "\(function) must be owned by the non-bypass definer role")
        }
        #expect(sql.contains("alter function sync_pull(bigint, text, int, text) owner to variorum_definer;"),
                "the re-created sync_pull must return to the definer owner")
        #expect(sql.contains("grant select, insert, update, delete on purge_intent to variorum_definer;"))
        #expect(sql.contains("grant select, insert, update on device_cursor to variorum_definer;"))
        #expect(sql.contains("grant select, insert on purged_row to variorum_definer;"))
        // The CREATE-for-ownership-acquisition dance is closed again.
        #expect(sql.contains("grant usage, create on schema public to variorum_definer;"))
        #expect(sql.contains("revoke create on schema public from variorum_definer;"))
    }

    /// THE LEDGER CHECK (the memo's §2): the deployed push body refuses a
    /// row named in purged_row with the typed 'purged' status, BEFORE any
    /// CAS work — a stale peer can never resurrect a purged row.
    @Test func theDeployedPushBodyRefusesPurgedRowsBeforeTheCAS() throws {
        let body = try Self.finalBody(of: "sync_push")
        #expect(body.contains("from purged_row p"))
        #expect(body.contains("'status', 'purged'"))
        let ledgerCheck = try #require(body.range(of: "from purged_row"))
        let casLock = try #require(body.range(of: "for update"))
        #expect(ledgerCheck.lowerBound < casLock.lowerBound,
                "the ledger check must precede the CAS lock — a purged row has no CAS state")
    }

    /// THE DEVICE CURSOR (what makes a horizon computable): the deployed
    /// pull body upserts the caller's cursor monotonically — greatest(),
    /// so a replayed lower window can never regress what the server
    /// believes the device has seen — and stamps seen_at.
    @Test func theDeployedPullBodyRecordsTheDeviceCursorMonotonically() throws {
        let body = try Self.finalBody(of: "sync_pull")
        #expect(body.contains("insert into device_cursor (owner_id, device_id, last_seq, seen_at)"))
        #expect(body.contains("set last_seq = greatest(device_cursor.last_seq, excluded.last_seq)"))
        #expect(body.contains("seen_at  = now()"))
        // Null device = no upsert (mid-round windows pass null so a crash
        // before the apply commit can never over-report).
        #expect(body.contains("if dev is not null then"))
    }

    /// THE HORIZON (her round-8 ruling): min live-device cursor; a device
    /// unseen for 60 days leaves it; an account with no cursors answers 0
    /// (the janitor's safe no-op). Fenced; deliberately NO entitlement
    /// gate — purge is data removal, a right (the account_data_truncate
    /// reasoning, recorded in the artifact).
    @Test func theHorizonDropsDevicesUnseenForSixtyDays() throws {
        let body = try Self.finalBody(of: "sync_horizon")
        #expect(body.contains("min(last_seq)"))
        #expect(body.contains("seen_at > now() - interval '60 days'"))
        #expect(body.contains("coalesce"))
        // pre-13x 11: a READ RPC, and the proof gates it too — a session
        // without the keys gets nothing from the mirror, a seq included.
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"))
        #expect(!body.contains("from entitlement"),
                "no entitlement gate on purge — data removal is a right")
    }

    /// THE LEDGER PAGE: entries above the caller's scan point plus the
    /// coverage floor — 0 while ledger pruning is unbuilt (complete
    /// coverage from the beginning of time); the future pruning rider
    /// advances it, and a client below the floor takes the SAY-SO-FIRST
    /// returner road (round 10).
    @Test func theLedgerPageCarriesEntriesAndTheCoverageFloor() throws {
        let body = try Self.finalBody(of: "sync_purge_ledger")
        #expect(body.contains("'floor', 0"))
        #expect(body.contains("p.purged_seq > since_seq"))
        #expect(body.contains("'purged_seq', p.purged_seq"))
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"),
                "pre-13x: the ledger page is proof-gated too")
        #expect(!body.contains("from entitlement"))
    }

    /// THE PURGE-EXECUTION DOOR (the adjudication's note 1): tenant-scoped
    /// row deletes over the registry's tables only, every deleted row
    /// recorded in the ledger in the SAME transaction (idempotent upsert —
    /// a janitor resuming mid-family re-runs safely), one granted seq per
    /// call. The family expansion is deliberately CLIENT-side — the
    /// server stays dumb (SyncSpec §2).
    @Test func thePurgeExecutionDoorIsTenantScopedAndLedgerRecording() throws {
        let body = try Self.finalBody(of: "sync_purge_execute")
        #expect(body.contains("delete from %I where owner_id = $2 and %I = $1"),
                "purge deletes are tenant-scoped by the composite identity")
        #expect(body.contains("insert into purged_row (owner_id, table_name, row_id, purged_seq)"))
        #expect(body.contains("on conflict (owner_id, table_name, row_id) do nothing"),
                "the ledger upsert is what makes a resumed family purge idempotent")
        #expect(Self.namedArray("allowed", in: body) == Set(SyncSchema.tables.map(\.name)),
                "the purge door's allowlist drifted from the registry")
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"))
        #expect(!body.contains("from entitlement"))
        #expect(!body.lowercased().contains("truncate table"))
    }

    /// The account doors keep their pinned shapes with the registry grown:
    /// both data_tables arrays are registry-exact (checked by the standing
    /// pins above via finalBody), and account_purge now also removes the
    /// caller's purge-machinery rows — the whole account goes.
    @Test func theAccountPurgeTakesThePurgeMachineryRowsToo() throws {
        let body = try Self.finalBody(of: "account_purge")
        #expect(body.contains("delete from device_cursor where owner_id = caller;"))
        #expect(body.contains("delete from purged_row where owner_id = caller;"))
        // account_data_truncate deliberately touches NEITHER (purged
        // stays purged across a re-key; cursors stay valid under the
        // monotonic sequence) — pinned from the truncate's own body.
        let truncate = try Self.finalBody(of: "account_data_truncate")
        #expect(!truncate.contains("device_cursor") && !truncate.contains("purged_row"),
                "a re-key truncate must not touch the purge machinery")
    }

    /// 10's header carries the choreography record: pre-authorized deploy
    /// (her round-8 words), architect's one-window, the phone-refresh
    /// bundling, the A1 rail.
    @Test func thePurgeHeaderCarriesTheChoreography() throws {
        let sql = try Self.sqlFile("10_phase13j_purge.sql")
        #expect(sql.contains("THE CHOREOGRAPHY"))
        #expect(sql.contains("this file runs on the mirror FIRST"))
        #expect(sql.contains("SyncSpec §12"))
        #expect(sql.contains("ARCHITECT"))
        #expect(sql.contains("never a batch implementer"))
        #expect(sql.contains("PRE-AUTHORIZED"))
        #expect(sql.contains("A1 rail"))
        #expect(sql.contains("PHONE"))
    }

    // MARK: - pre-13x batch 1b: the POSTURES lockstep event (11) pins.
    // The design (notes/plans/pre-13x-postures-design.md §3.10, decisions
    // 12 / 31 / 32, ledger 16 / 25 / 29 / 34 / 35 / 38 / 41) is the binding
    // record; the batch record under its §19 carries the implementer's
    // readings. The artifact is DRAFTED AND PINNED, NOT DEPLOYED — deploy
    // is the orchestrator's window under her standing pre-authorization.

    /// 11 takes the 09/10 deploy shape: one transaction, the re-run guard
    /// before the six destructive drops, the marker bump last inside the
    /// transaction; the guard keys on evidence only a deployed 11 leaves.
    @Test func thePosturesEventDeploysAsOneGuardedTransaction() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let problems = Self.deployShapeProblems(strippedSQL: sql)
        #expect(problems.isEmpty, "11's deploy shape is unsound: \(problems.sorted())")
        #expect(sql.contains("deployed_marker >= 8 or proof_column_here"))
        #expect(sql.contains("column_name = 'key_proof_hash'"))
        #expect(sql.contains("VARIORUM_11_ALREADY_DEPLOYED"))
        #expect(sql.contains("current_setting('variorum.allow_11_rerun', true)"))
        #expect(sql.contains("hint    ="), "the refusal carries the operator's next step")
    }

    /// THE OLD SIGNATURES ARE DROPPED FIRST (the 09/10 discipline): a
    /// lingering proof-free overload beside the new one would be the exact
    /// door this event closes. Every new signature carries `key_proof`
    /// beside `active_key_id`; `account_purge` is never re-created.
    @Test func thePosturesEventDropsEveryOldSignatureFirstAndCreatesTheNewOnes() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let drops = [
            "drop function if exists sync_push(jsonb, text);",
            "drop function if exists sync_pull(bigint, text, int, text);",
            "drop function if exists sync_horizon(text);",
            "drop function if exists sync_purge_ledger(bigint, text);",
            "drop function if exists sync_purge_execute(jsonb, text);",
            "drop function if exists account_data_truncate(text);",
        ]
        let creates = [
            "create or replace function sync_push(batch jsonb, active_key_id text, key_proof text)",
            // `key_proof text default null` — forced by Postgres (a defaultless
            // parameter cannot follow defaulted ones) with the brief's ORDER
            // kept; the gate refuses a NULL proof with the typed marker.
            "create or replace function sync_pull(since_seq bigint, active_key_id text, max_rows int default 500, for_device text default null, key_proof text default null)",
            "create or replace function sync_horizon(active_key_id text, key_proof text)",
            "create or replace function sync_purge_ledger(since_seq bigint, active_key_id text, key_proof text)",
            "create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text)",
            "create or replace function account_data_truncate(active_key_id text, key_proof text)",
            "create or replace function sync_reencrypt(rows jsonb, active_key_id text, key_proof text)",
            "create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text)",
            "create or replace function sync_key_gate(active_key_id text, key_proof text)",
            "create or replace function sync_key_proof_check(key_proof text)",
        ]
        for drop in drops {
            #expect(sql.contains(drop), "11 must drop the old overload: \(drop)")
        }
        for create in creates {
            #expect(sql.contains(create), "11 must create: \(create)")
        }
        let dropEnds = drops.compactMap { sql.range(of: $0)?.upperBound }
        let createStarts = creates.compactMap { sql.range(of: $0)?.lowerBound }
        let lastDrop = try #require(dropEnds.max())
        let firstCreate = try #require(createStarts.min())
        #expect(lastDrop < firstCreate,
                "every OLD signature is dropped BEFORE any new function exists — no window holds both")
        #expect(!sql.contains("create or replace function account_purge"),
                "account_purge stays session-only and untouched (decision 12)")
    }

    /// The five additive columns, all NULLABLE (the author's row stays
    /// NULL until her first round lands the hash) — and the insert arm is
    /// a TRIGGER, never a CHECK, for exactly that reason.
    @Test func theVaultGainsExactlyTheFivePosturesColumnsAllNullable() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        for (column, type) in [
            ("master_wrapped_by_apple_held", "text"), ("apple_key_id", "text"),
            ("key_proof_hash", "text"), ("corpus_previous_wrapped_by_master", "text"),
            ("rotation_started_seq", "bigint"),
        ] {
            #expect(sql.contains("alter table key_vault add column \(column) \(type);"),
                    "11 must add \(column) \(type), nullable")
        }
        #expect(sql.components(separatedBy: "alter table key_vault add column").count - 1 == 5,
                "exactly five additive columns")
        #expect(!sql.contains("add column key_proof_hash text not null"),
                "NULLABLE — a NOT NULL would refuse the author's existing row")
        #expect(!sql.lowercased().contains("check (key_proof_hash"),
                "the insert arm is a TRIGGER, never a CHECK")
    }

    /// THE VAULT'S TABLE-LEVEL WRITE ROAD CLOSES (ledger 41 — MUST): the
    /// 08 update policy dropped, UPDATE revoked from `authenticated`, the
    /// definer role granted SELECT + UPDATE with an update policy in
    /// `device_cursor_owner_all`'s shape; no grant road back; still no
    /// delete grant. In deploy order the composition's LAST word on the
    /// vault's `authenticated` UPDATE is 11's revoke.
    @Test func theVaultsTableLevelWriteRoadIsClosed() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        #expect(sql.contains("drop policy if exists key_vault_owner_update on key_vault;"))
        #expect(sql.contains("revoke update on key_vault from authenticated;"))
        #expect(sql.contains("grant select, update on key_vault to variorum_definer;"))
        #expect(sql.contains("create policy key_vault_definer_update on key_vault"))
        #expect(sql.contains("for update to variorum_definer"))
        #expect(sql.contains("using (auth.uid() = user_id) with check (auth.uid() = user_id);"))
        #expect(!sql.contains("update on key_vault to authenticated"), "no road back")
        #expect(!sql.contains("delete on key_vault"),
                "still no delete grant — account_purge is the only removal")
        let composed = try Self.composedSQL()
        let grant = try #require(composed.range(
            of: "grant select, insert, update on key_vault to authenticated;", options: .backwards))
        let revoke = try #require(composed.range(
            of: "revoke update on key_vault from authenticated;", options: .backwards))
        #expect(grant.lowerBound < revoke.lowerBound,
                "08's grant is superseded by 11's revoke in deploy order")
    }

    /// THE INSERT ARM: a vault is CREATED with its key-proof hash (a
    /// `BEFORE INSERT` trigger raising the client-classifiable marker),
    /// INSERT-only so the migration arm's UPDATE of a NULL hash to its
    /// first proof still runs.
    @Test func aVaultIsCreatedWithItsProofHashByTriggerNeverByCheck() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let body = try Self.finalBody(of: "key_vault_require_proof_hash")
        #expect(body.contains("if new.key_proof_hash is null then"))
        #expect(body.contains(SyncServerRefusalMarker.keyProofRequired))
        #expect(body.contains("return new;"))
        #expect(sql.contains("create trigger key_vault_require_proof_hash before insert on key_vault"))
        #expect(sql.contains("for each row execute function key_vault_require_proof_hash();"))
        #expect(!sql.contains("before insert or update on key_vault"),
                "INSERT only — the migration arm UPDATEs a NULL hash to its first proof")
    }

    /// THE PROOF CHECK: the vault row read FOR SHARE (decision 31), the
    /// presented token decoded from base64 and SHA-256'd (the server keeps
    /// only the hash), compared in CONSTANT TIME — a fixed 64-step loop
    /// XOR-ing digits into an OR accumulator, never a short-circuiting
    /// string compare — with a malformed token refusing typed and the
    /// NULL-hash MIGRATION ARM landing the first proof.
    @Test func theProofCheckIsConstantTimeWithTheMigrationArm() throws {
        let body = try Self.finalBody(of: "sync_key_proof_check")
        #expect(body.contains("from key_vault where user_id = caller for share;"),
                "the vault row under a SHARE lock (decision 31)")
        #expect(body.contains("encode(sha256(decode(key_proof, 'base64')), 'hex')"),
                "SHA-256 of the RAW token; the wire carries base64")
        #expect(body.contains("exception when others then") && body.contains("presented_hash := null;"),
                "a malformed token refuses typed, never as a raw decode error")
        #expect(body.contains("for i in 1..64 loop"), "a FIXED 64-step loop — never short-circuiting")
        #expect(body.contains("ascii(substr(stored_hash, i, 1)) # ascii(substr(presented_hash, i, 1))"),
                "XOR per digit, OR-accumulated")
        #expect(body.contains("if hash_diff <> 0 then"))
        #expect(!body.contains("stored_hash = presented_hash")
                    && !body.contains("stored_hash <> presented_hash")
                    && !body.contains("is distinct from presented_hash"),
                "never a short-circuiting string compare")
        #expect(body.contains("if stored_hash is null then"), "the migration arm")
        #expect(body.contains("update key_vault set key_proof_hash = presented_hash where user_id = caller;"),
                "the FIRST proof lands its hash — once; the next call compares")
        #expect(body.components(separatedBy: SyncServerRefusalMarker.keyProofRequired).count - 1 == 2,
                "the malformed arm and the mismatch arm both refuse with the marker")
    }

    /// THE ROTATION'S WRITE (decision 6): version-neutral — the payload
    /// replaced where the version matches, a FRESH seq through the trigger,
    /// the version KEPT; a moved version SKIPPED with the current one;
    /// tenant-scoped, registry-exact, the push posture.
    @Test func theReencryptDoorIsVersionNeutralTenantScopedAndRegistryExact() throws {
        let body = try Self.finalBody(of: "sync_reencrypt")
        #expect(body.contains("security definer"))
        #expect(body.contains("caller := auth.uid();"))
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof);"))
        #expect(body.contains("feature = 'hosted_sync'"),
                "the push posture: the entitlement gate rides (batch 1b's recorded reading)")
        #expect(Self.namedArray("allowed", in: body) == Set(SyncSchema.tables.map(\.name)),
                "the re-encryption door's allowlist drifted from the registry")
        #expect(Self.namedArray("owner_tables", in: body) == (try Self.ownerCarryingTables()),
                "the owner guard's table set drifted from the client schema")
        #expect(body.contains("(item->'columns'->>'owner_id') is distinct from caller"))
        #expect(body.contains("where t.owner_id = $2 and t.%I = $1 for update"), "tenant-scoped CAS lock")
        #expect(body.contains("if current_version is null or current_version is distinct from expected_version then"),
                "a moved (or absent) version is SKIPPED")
        #expect(body.contains("'status', 'skipped', 'current_version', current_version"))
        #expect(body.contains("jsonb_build_object('sync_version', current_version, 'owner_id', caller)"),
                "the version is KEPT — never bumped")
        #expect(!body.contains("current_version + 1"), "version-neutral: no bump anywhere in the door")
        #expect(body.contains("delete from %I where owner_id = $2 and %I = $1"))
        #expect(body.contains("returning server_seq"), "a fresh seq through the trigger — above the rotation seq")
        #expect(body.contains("'status', 'replaced', 'server_seq', granted_seq"))
        #expect(!body.contains("purged_row"), "re-encryption never consults or writes the ledger")
        #expect(!body.lowercased().contains("truncate"))
    }

    /// THE ONE WRITE ROAD INTO THE VAULT: FOR UPDATE (decision 31's
    /// serialization point), the CURRENT proof authorizes (the NULL-hash
    /// arm lands the first), the R1-2 revision CAS inside, the WHOLE format
    /// replaced from the payload (no stale recovery wrap survives a re-key),
    /// the hash replaceable, and the rotation seq: `nextval` when a
    /// previous key is SET where none stands; kept on a carry-through;
    /// VARIORUM_ROTATION_IN_PROGRESS on a DIFFERENT one (decision 32);
    /// cleared with the key.
    @Test func theVaultUpdateDoorLocksForUpdateCASesAndRecordsTheRotationSeq() throws {
        let body = try Self.finalBody(of: "key_vault_update")
        #expect(body.contains("security definer"))
        #expect(body.contains("caller := auth.uid();"), "scoped to the caller — the 14c guard")
        #expect(body.contains("from key_vault where user_id = caller for update;"),
                "the serialization point (decision 31)")
        #expect(body.contains(SyncServerRefusalMarker.vaultAbsent))
        #expect(body.contains("perform sync_key_proof_check(key_proof);"), "the CURRENT proof authorizes")
        #expect(body.contains("incoming_previous := payload->>'corpus_previous_wrapped_by_master';"))
        #expect(body.contains("elsif vault_previous is null then")
                    && body.contains("next_seq := nextval('sync_server_seq');"),
                "a rotation begins: nextval INSIDE this transaction, the row locked")
        #expect(body.contains("elsif incoming_previous = vault_previous then")
                    && body.contains("next_seq := vault_seq;"),
                "a carry-through (a re-wrap mid-rotation) keeps the seq")
        #expect(body.contains(SyncServerRefusalMarker.rotationInProgress),
                "a DIFFERENT previous key while one stands refuses (decision 32)")
        #expect(body.contains("if incoming_previous is null then") && body.contains("next_seq := null;"),
                "clearing the key clears the seq with it")
        #expect(body.contains("corpus_previous_wrapped_by_master    = incoming_previous,"))
        #expect(body.contains("rotation_started_seq                 = next_seq,"))
        #expect(body.contains("where user_id = caller and revision = expected_revision;"), "the CAS inside")
        #expect(body.contains("revision                             = expected_revision + 1,"))
        #expect(body.contains(SyncServerRefusalMarker.vaultRevisionConflict))
        #expect(body.contains("key_proof_hash                       = coalesce(payload->>'key_proof_hash', key_proof_hash),"),
                "the hash is replaceable under the current proof — never NULLed by omission")
        #expect(body.contains("updated_at                           = now()"), "stamped server-side")
        for column in ["format_version", "kdf_algorithm", "kdf_argon2_version", "kdf_memory_kib",
                       "kdf_iterations", "kdf_parallelism", "kdf_salt", "kdf_output_bytes",
                       "master_wrapped_by_passphrase", "master_wrapped_by_recovery", "corpus_key_id",
                       "corpus_key_wrapped_by_master", "journal_bridge_key_id",
                       "journal_bridge_key_wrapped_by_master", "master_wrapped_by_apple_held",
                       "apple_key_id"] {
            #expect(body.contains("= payload->>'\(column)'") || body.contains("(payload->>'\(column)')::int"),
                    "the WHOLE format is replaced: \(column) comes from the payload")
        }
        #expect(!body.contains("payload->>'revision'") && !body.contains("payload->>'rotation_started_seq'")
                    && !body.contains("payload->>'user_id'") && !body.contains("payload->>'updated_at'"),
                "server-managed columns never come from the payload")
        #expect(body.contains("'revision', expected_revision + 1") && body.contains("'rotation_started_seq', next_seq"),
                "the receipt carries both")
    }

    /// Ownership + the demotion posture: every data function (the six
    /// re-created, the two new doors, the two helpers) owned by the
    /// non-bypass definer role; the sync RPCs keep the 09 posture; the
    /// doors take the account-door posture; the helpers are reachable by
    /// NO API role.
    @Test func thePosturesFunctionsAreDefinerOwnedAndDemoted() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        for function in ["sync_key_proof_check(text)", "sync_key_gate(text, text)",
                         "sync_push(jsonb, text, text)", "sync_pull(bigint, text, int, text, text)",
                         "sync_horizon(text, text)", "sync_purge_ledger(bigint, text, text)",
                         "sync_purge_execute(jsonb, text, text)", "account_data_truncate(text, text)",
                         "sync_reencrypt(jsonb, text, text)", "key_vault_update(jsonb, int, text)"] {
            #expect(sql.contains("alter function \(function) owner to variorum_definer;"),
                    "\(function) must be owned by the non-bypass definer role")
        }
        #expect(!sql.contains("alter function account_purge"), "the purge keeps postgres — auth-schema DML")
        #expect(sql.contains("revoke execute on function sync_push(jsonb, text, text) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_push(jsonb, text, text) to authenticated, service_role;"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, text, int, text, text) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, text, int, text, text) to authenticated, service_role;"))
        for door in ["sync_horizon(text, text)", "sync_purge_ledger(bigint, text, text)",
                     "sync_purge_execute(jsonb, text, text)", "account_data_truncate(text, text)",
                     "sync_reencrypt(jsonb, text, text)", "key_vault_update(jsonb, int, text)"] {
            #expect(sql.contains("revoke execute on function \(door) from public, anon, service_role;"),
                    "\(door) revoked from server machinery by name")
            #expect(sql.contains("grant execute on function \(door) to authenticated;"))
            #expect(!sql.contains("grant execute on function \(door) to authenticated, service_role"))
        }
        for helper in ["sync_key_proof_check(text)", "sync_key_gate(text, text)"] {
            #expect(sql.contains("revoke execute on function \(helper) from public, anon, authenticated, service_role;"))
            #expect(sql.contains("grant execute on function \(helper) to variorum_definer;"))
            #expect(!sql.contains("grant execute on function \(helper) to authenticated"))
        }
        #expect(sql.contains("grant usage, create on schema public to variorum_definer;"))
        #expect(sql.contains("revoke create on schema public from variorum_definer;"))
    }

    /// The 13j naming rule: no RPC parameter shadows a column it writes —
    /// the vault-writing functions' parameters against the vault's columns.
    @Test func noPosturesParameterShadowsAVaultColumn() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let vaultColumns = Set(SerializerCompletenessTests.keyVaultColumnClasses.keys)
        for signature in [
            "key_vault_update(payload jsonb, expected_revision int, key_proof text)",
            "sync_key_proof_check(key_proof text)",
            "sync_key_gate(active_key_id text, key_proof text)",
        ] {
            #expect(sql.contains(signature))
            let inside = signature.split(separator: "(")[1].dropLast()
            let params = inside.split(separator: ",").map {
                String($0.trimmingCharacters(in: .whitespaces).split(separator: " ")[0])
            }
            for param in params {
                #expect(!vaultColumns.contains(param), "\(param) shadows a key_vault column")
            }
        }
    }
}
