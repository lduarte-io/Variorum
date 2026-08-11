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
        let sql = Self.strippingComments(try Self.sqlFile("09_phase14c_multitenant.sql"))
        for table in SyncSchema.tables {
            #expect(sql.contains("drop table if exists \(table.name);"),
                    "\(table.name) must be dropped before its rebuild")
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
        // default-deny themselves.
        #expect(!sql.contains("_owner_all on") || !sql.contains("for all to authenticated"),
                "owner policies must not carry a `to` clause — FORCE RLS binds the definer too")
        #expect(sql.contains("for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());"))
    }

    /// THE VAULT-KEY-ID FENCE (THE DESIGN item 2): both deployed bodies
    /// compare the presented active_key_id against the caller's
    /// key_vault corpus key id and refuse the whole round on mismatch
    /// OR a missing vault row, with the marker the client classifies
    /// into the CF-16 replaced state.
    @Test func bothDeployedRPCBodiesCarryTheVaultKeyIDFence() throws {
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            #expect(body.contains("select corpus_key_id into fence_key from key_vault where user_id = caller;"),
                    "\(function) must read the caller's vault key id")
            #expect(body.contains("if fence_key is null or fence_key is distinct from active_key_id then"),
                    "\(function) must fence on mismatch AND on a missing vault row")
            #expect(body.contains(SyncServerRefusalMarker.staleKeyFence),
                    "\(function)'s fence refusal must carry the client-classifiable marker")
        }
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
        #expect(body.contains("select corpus_key_id into fence_key from key_vault where user_id = caller;"),
                "the truncate must read the caller's vault key id — the fence")
        #expect(body.contains("if fence_key is null or fence_key is distinct from active_key_id then"),
                "the truncate must fence on mismatch AND on a missing vault row")
        #expect(body.contains(SyncServerRefusalMarker.staleKeyFence),
                "the fence refusal must carry the client-classifiable marker")
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
        for function in ["sync_push(jsonb,text)", "sync_pull(bigint,text,integer)",
                         "account_data_truncate(text)", "account_purge()",
                         "entitlement_set(uuid,text,boolean,timestampwithtimezone,text)",
                         "sync_schema_version()", "sync_table_pk(text)"] {
            #expect(sql.contains("('\(function)'"),
                    "the sweep must carry an expectation for \(function)")
        }
        // And it must surface an object nobody expected — a lingering old
        // RPC overload is the door this sweep exists to catch.
        #expect(sql.contains("UNEXPECTED FUNCTION"))
        #expect(sql.contains("UNEXPECTED TABLE"))
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
        for function in ["sync_push", "sync_pull"] {
            let body = try Self.finalBody(of: function)
            #expect(!body.contains("'key_vault'"),
                    "\(function)'s allowlist must never carry key_vault")
            #expect(!body.contains("insert into key_vault")
                        && !body.contains("update key_vault")
                        && !body.contains("delete from key_vault"),
                    "\(function) must never WRITE the vault — the fence only reads it")
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
    static func truncateProblems(strippedSQL sql: String)
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
        let registry = Set(SyncSchema.tables.map(\.name))
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
        let sql = Self.strippingComments(
            try Self.sqlFile("maintenance/14b-mirror-truncate.sql"))
        let problems = Self.truncateProblems(strippedSQL: sql)
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
}
