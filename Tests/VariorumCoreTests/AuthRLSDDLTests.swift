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
        "12_phase13y_tenant_seq.sql",
        // 13i-a (the wings/shelves/books event, marker 10): wing + shelf
        // born multi-tenant; the additive mirror columns; the six
        // registry-carrying RPC bodies redefined — the CANONICAL bodies
        // for those six live HERE now (the 13y fold-in precedent).
        "13_phase13i_wings.sql",
        // 13i-c (the outflow event, marker 11 — R-13ic-1): ONE additive
        // column on reading; no table, no RPC change.
        "14_phase13i_c_outflow.sql",
        // 13i-e (the book-archive event, marker 12 — R-13ie-1): ONE additive
        // column on reading (`archived_at`); no table, no RPC change.
        "15_phase13ie_archive.sql",
        // 13n-b (the private-mark event, marker 13 — R-13nb-4): TWO additive
        // columns (`container.ai_private_at` + `reading.ai_private_at`,
        // PLAIN, the archived_at class — the AI fence's third leg); no
        // table, no RPC change. Deploy is HER closeout window.
        "16_phase13nb_private.sql",
        // VX-307/VX-329 (the key-vault event, marker 14): the vault's new
        // wire shape — `mode` + `earlier_row_keys`, the mode backfill,
        // key_vault_update's canonical body (now the CANONICAL home for
        // that function), sync_reencrypt retired. HELD at VX-307; deploys
        // in VX-329's release window at her explicit go (the vx307 deploy
        // checklist; rehearsed green on the throwaway at VX-308 §5R).
        "17_phase_vx307_vault.sql",
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
        switch tableName {
        case "purge_intent": "10_phase13j_purge.sql"
        // 13i-a: the two wings/shelves tables are BORN at 13, on 09's
        // exact posture.
        case "wing", "shelf": "13_phase13i_wings.sql"
        default: "09_phase14c_multitenant.sql"
        }
    }

    /// The RLS/grant surface: 04 (the auth flip) + the lockstep events
    /// (05 Phase 11, 06 Phase 13, 07 Phase 13b), in deploy order.
    private static func composedSQL() throws -> String {
        try ([sqlFile("04_auth_rls.sql")] + lockstepFiles.map(sqlFile))
            .map(strippingComments)
            .joined(separator: "\n")
    }

    /// pre-13x ladder round 1, F1 (BLOCKER-1): the MAINTENANCE OVERLAY the
    /// author deploys AFTER 11 — a body-only repair to `key_vault_update`
    /// (the completion guard). Not a lockstep file (the marker stays 8),
    /// so it is not in `lockstepFiles`; the pins that read what the
    /// deployed server RUNS for that function read it through
    /// `deployedBody(of:)`, which lays it over the composition.
    private static let ladderOverlayFile = "maintenance/pre13x-ladder-rotation-clearing-guard.sql"

    /// The two fenced F1 regions of the overlay (the declarations and the
    /// clause) — what the overlay ADDS to 11's body, and nothing else.
    private static let overlayFenceOpen = "-- >>> F1 GUARD"
    private static let overlayFenceClose = "-- <<< F1 GUARD"

    /// The overlay's text with every fenced F1 region removed — what must
    /// equal 11's own text for the function it replaces.
    private static func overlayWithoutFences(_ sql: String) -> String {
        var out = ""
        var inside = false
        for line in sql.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix(overlayFenceOpen) { inside = true; continue }
            if trimmed.hasPrefix(overlayFenceClose) { inside = false; continue }
            if !inside { out += line + "\n" }
        }
        return out
    }

    /// The body a text runs for `functionName`: the LAST `create or replace
    /// function <name>` in it, up to its terminating `$$;`.
    private static func lastBody(of functionName: String, in sql: String) -> String? {
        let marker = "create or replace function \(functionName)"
        guard let start = sql.range(of: marker, options: .backwards),
              let end = sql.range(of: "$$;", range: start.upperBound..<sql.endIndex)
        else { return nil }
        return String(sql[start.lowerBound..<end.upperBound])
    }

    /// What the deployed server RUNS for `functionName` once the ladder
    /// overlay is deployed after 11: the overlay's body where it carries
    /// one, else the composition's. SUPERSEDED-BY-12 (Phase 13y): a
    /// function 12 re-creates is deployed AFTER the overlay, so for those
    /// the composition's last body IS the deployed truth — the overlay is
    /// history (its own header says so, and its re-run guard refuses once
    /// the deployed body carries the guard text 12 folds in).
    private static func deployedBody(of functionName: String) throws -> String {
        let twelve = strippingComments(try sqlFile("12_phase13y_tenant_seq.sql"))
        if lastBody(of: functionName, in: twelve) != nil {
            return try finalBody(of: functionName)
        }
        let overlay = strippingComments(try sqlFile(ladderOverlayFile))
        if let body = lastBody(of: functionName, in: overlay) { return body }
        return try finalBody(of: functionName)
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
        // 13y UNIT B: the gate call carries the per-request challenge and
        // names the calling RPC — the HMAC binding that stops cross-RPC
        // splicing rides the name each body passes as a literal.
        for function in Self.proofGatedFunctions {
            let body = try Self.finalBody(of: function)
            #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, '\(function)');"),
                    "\(function) must call the gate — the fence + the proof — before any row is touched, naming ITSELF")
            #expect(!body.contains("select corpus_key_id into fence_key"),
                    "\(function) must not inline a second fence beside the gate's")
        }
        let gate = try Self.finalBody(of: "sync_key_gate")
        #expect(gate.contains("select corpus_key_id into fence_key from key_vault where user_id = caller for share;"),
                "the gate reads the caller's vault key id under a SHARE lock (decision 31) — on a landed hash")
        #expect(gate.contains("select corpus_key_id into fence_key from key_vault where user_id = caller for update;"),
                "…and FOR UPDATE from the start on a NULL hash (a conservative lock on an impossible state since the arm's retirement)")
        #expect(gate.contains("if fence_key is null or fence_key is distinct from active_key_id then"),
                "the gate must fence on mismatch AND on a missing vault row")
        #expect(gate.contains(SyncServerRefusalMarker.staleKeyFence),
                "the fence refusal must carry the client-classifiable marker")
        #expect(gate.contains("perform sync_key_proof_check(key_proof, challenge, rpc_name);"),
                "the fence is followed by the proof — the authorization, challenge-verified")
        // account_purge stays session-only — deletion is mandated and loud
        // (decision 12). Since UNIT B its body DOES name the challenge
        // TABLE (the account's nonces go with the account), so the pin is
        // on the gate machinery, never the substring.
        let purge = try Self.finalBody(of: "account_purge")
        #expect(!purge.contains("sync_key_gate") && !purge.contains("sync_key_proof_check"),
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
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'account_data_truncate');"),
                "the truncate must call the gate — the fence, then the challenge-verified proof")
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
    /// the server-only column subtraction survive in the DEPLOYED bodies.
    /// RE-POINTED at Phase 13y (the R-13y-4 fork's ruling, Shape 1): the
    /// deployed pull no longer carries an inline `interval '2 seconds'` —
    /// it DERIVES its filter from the ONE serving function
    /// (`sync_visibility_horizon_ms()`), so the pin now asserts the
    /// derivation and BANS the inline literal (an inline literal
    /// reappearing IS the drift this mechanism exists to make impossible).
    @Test func theVisibilityHorizonSurvivesEveryRework() throws {
        let pull = try Self.finalBody(of: "sync_pull")
        #expect(pull.contains("sync_visibility_horizon_ms()"),
                "the deployed sync_pull derives the A5 horizon from the one serving function")
        #expect(pull.contains("t.server_written_at <= clock_timestamp() - %L::interval"),
                "every branch's filter subtracts the DERIVED interval")
        #expect(!pull.contains("interval '"),
                "no inline interval literal survives in the pull body — served and enforced cannot drift")
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

    /// SIGNUP AUTO-ENTITLEMENT (maintenance, 2026-09-24 — her word at the
    /// 13y window's tail; the record rides 13t's row): every new auth user
    /// is granted `hosted_sync` at signup by an auth.users trigger, making
    /// her ruled "sync is open at v1" posture (and the friends beta) real
    /// without her hand on the door. The artifact must be idempotent, keep
    /// the footgun revoke pair, never overwrite a deliberate
    /// `entitlement_set` state, and carry the backfill for pre-trigger
    /// signups. The kill-switch (`entitlement_set(..., false)`) is
    /// untouched by construction — the trigger only ever fires at INSERT
    /// on auth.users, never re-granting a revoked account.
    @Test func signupAutoEntitlementIsIdempotentGuardedAndKillSwitchSafe() throws {
        let sql = Self.strippingComments(
            try Self.sqlFile("maintenance/beta-signup-auto-entitle.sql"))
        #expect(sql.contains("create or replace function signup_auto_entitle() returns trigger"))
        #expect(sql.contains("security definer"))
        #expect(sql.contains("set search_path = public"))
        #expect(sql.contains("revoke execute on function signup_auto_entitle() from public, anon, authenticated;"),
                "every new function carries its footgun revoke pair")
        #expect(sql.contains("drop trigger if exists variorum_signup_auto_entitle on auth.users;"))
        #expect(sql.contains("after insert on auth.users"),
                "the grant fires at signup and ONLY at signup — the trigger never re-grants a revoked account")
        #expect(sql.contains("on conflict (user_id, feature) do nothing"),
                "a deliberate entitlement_set state wins over the default")
        // THE KILL-SWITCH RE-RUN SAFETY (the act's cold review, F-1 — the
        // MAJOR): entitlement_set(false) DELETEs the row, so any blanket
        // every-user insert cannot distinguish a pre-trigger gap from a
        // deliberate revocation — a re-run of the original backfill would
        // have silently re-granted every revoked account. The artifact
        // must therefore write NO entitlement rows outside the trigger:
        // a gap repair is a deliberate act scoped to the gap's
        // created_at window, never a file this header invites re-running.
        #expect(!sql.contains("signup-auto-backfill")
                && !sql.contains("from auth.users u"),
                "no blanket entitlement insert may live in a re-runnable artifact (F-1)")
        // THE CONTAINMENT ARM (F-2): a bookkeeping failure degrades to an
        // unentitled signup (typed, repairable), never a suite-wide
        // signup outage — an AFTER INSERT error would abort GoTrue's own
        // insert for Variorum AND Fragments signups alike.
        #expect(sql.contains("exception when others then"),
                "the entitlement insert can never abort the suite's signup door")
        #expect(sql.contains("raise warning"),
                "a contained failure is logged, not swallowed silently")
        // The anonymous guard (NIT-1): config-dependent signups never
        // earn an open-ended grant.
        #expect(sql.contains("coalesce(new.is_anonymous, false)"))
        // The sweep must know BOTH halves (F-4): the function as an INFO
        // registry row, and the trigger as an ASSERTED fact row — an INFO
        // row can never fail, and a lost trigger silently unentitles
        // every new signup while sync refuses typed.
        let sweep = try Self.sqlFile("maintenance/14c-post-deploy-grant-sweep.sql")
        #expect(sweep.contains("('signup_auto_entitle()'"),
                "the sweep's registry carries the signup trigger function as an INFO row")
        #expect(sweep.contains("('trigger:auth.users:variorum_signup_auto_entitle', true)"),
                "the trigger itself is an asserted sweep fact — its loss is a MISMATCH, never silence (F-4)")
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
        for table in SyncSchema.tables.map(\.name)
            + ["entitlement", "key_vault", "sync_meta", "sync_tenant_seq",
               "key_proof_challenge", "sync_write_budget"] {
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
        // 13y (12): sync_pull's expectation moved to its REORDERED NIT-4
        // signature (key_proof defaultless — 12 drops the 11-era spelling,
        // whose reappearance is the UNEXPECTED class), the counter helper
        // `next_tenant_seq(uuid)` joined on the helper posture, and the
        // served-horizon function joined on the version RPC's posture
        // (the R-13y-4 fork's Shape 1).
        // 13y UNIT B: every gated signature moved to its CHALLENGE spelling
        // (12 drops ALL 11-era overloads — a reappearance is the UNEXPECTED
        // class, a challenge-free door), and the new surface joined:
        // the mint, the enroll road, the hoisted constant-time helper.
        for function in ["sync_push(jsonb,text,text,text)", "sync_pull(bigint,text,text,text,integer,text)",
                         "account_data_truncate(text,text,text)", "account_purge()",
                         "entitlement_set(uuid,text,boolean,timestampwithtimezone,text)",
                         "sync_schema_version()", "sync_table_pk(text)",
                         "sync_horizon(text,text,text)", "sync_purge_ledger(bigint,text,text,text)",
                         "sync_purge_execute(jsonb,text,text,text)",
                         "sync_reencrypt(jsonb,text,text,text)", "key_vault_update(jsonb,integer,text,text)",
                         "sync_key_gate(text,text,text,text)", "sync_key_proof_check(text,text,text)",
                         "sync_challenge(integer)", "key_proof_enroll(text,text,text)",
                         "sync_constant_time_equal(text,text)",
                         "key_vault_require_proof_hash()", "next_tenant_seq(uuid)",
                         "sync_visibility_horizon_ms()"] {
            #expect(sql.contains("('\(function)'"),
                    "the sweep must carry an expectation for \(function)")
        }
        for old in ["('sync_push(jsonb,text)'", "('sync_pull(bigint,text,integer,text)'",
                    "('account_data_truncate(text)'", "('sync_horizon(text)'",
                    "('sync_purge_ledger(bigint,text)'", "('sync_purge_execute(jsonb,text)'",
                    "('sync_pull(bigint,text,integer,text,text)'",
                    // The 11-era key_proof spellings — dropped by 12's UNIT B.
                    "('sync_push(jsonb,text,text)'", "('sync_pull(bigint,text,text,integer,text)'",
                    "('account_data_truncate(text,text)'", "('sync_horizon(text,text)'",
                    "('sync_purge_ledger(bigint,text,text)'", "('sync_purge_execute(jsonb,text,text)'",
                    "('sync_reencrypt(jsonb,text,text)'", "('key_vault_update(jsonb,integer,text)'",
                    "('sync_key_gate(text,text)'", "('sync_key_proof_check(text)'"] {
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
        // 13y ladder R1 (F-R2): the sweep verifies the definer role's
        // SCHEMA-USAGE reach LIVE — `extensions` (pgcrypto: the two new
        // bodies' gen_random_bytes/hmac) and `vault` (the MAC secret) — via
        // has_schema_privilege, the honest end-state check whichever
        // mechanism (explicit grant OR the inherited authenticated
        // membership) supplies it.
        #expect(sql.contains("has_schema_privilege('variorum_definer', s.schema_name, 'USAGE')"),
                "the sweep must verify the definer's schema-usage reach live")
        #expect(sql.contains("('extensions'), ('vault')"),
                "the schema-usage fact must cover both extensions (pgcrypto) and vault (the MAC secret)")
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
        // 12 (Phase 13y): the per-tenant sequence event. Deploy is the
        // ORCHESTRATOR's ONE end-of-phase window under her standing
        // pre-authorization (R-13y-2), never a batch implementer's; the
        // window bundles BOTH device builds; the A1 rail; and the
        // GOVERNANCE RIDER (R-13y-4): the pre-deploy summary names the
        // two QUESTIONS #144 PROVISIONALs, one line each, before anything
        // fires. The carry-over proof (her cursors intact — the floor,
        // proven live) closes the window.
        let sql12 = try Self.sqlFile("12_phase13y_tenant_seq.sql")
        #expect(sql12.contains("THE CHOREOGRAPHY"))
        #expect(sql12.contains("this file runs on the mirror FIRST"))
        #expect(sql12.contains("SyncSpec §12"))
        #expect(sql12.contains("ORCHESTRATOR"))
        #expect(sql12.contains("never a batch implementer"))
        #expect(sql12.contains("PRE-AUTHORIZED"))
        #expect(sql12.contains("A1 rail"))
        #expect(sql12.contains("PHONE"))
        #expect(sql12.contains("#144"))
        #expect(sql12.contains("pre-deploy summary"))
        #expect(sql12.contains("carry-over proof") || sql12.contains("CARRY-OVER PROOF"))
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
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_horizon');"))
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
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_ledger');"),
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
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_execute');"))
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

    /// The seven additive columns, all NULLABLE (the author's row stays
    /// NULL until her first round lands the hash) — the previous corpus key
    /// as its id + its bare wrap, two columns (the orchestrator's ruling on
    /// 1b's question 1); `updated_by_device` the seventh (decision 34, batch
    /// 2c — the writing device's NAME) — and the insert arm is a TRIGGER,
    /// never a CHECK, for exactly that reason.
    @Test func theVaultGainsExactlyTheSevenPosturesColumnsAllNullable() throws {
        let sql = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        for (column, type) in [
            ("master_wrapped_by_apple_held", "text"), ("apple_key_id", "text"),
            ("key_proof_hash", "text"), ("corpus_previous_key_id", "text"),
            ("corpus_previous_wrapped_by_master", "text"), ("rotation_started_seq", "bigint"),
            ("updated_by_device", "text"),
        ] {
            #expect(sql.contains("alter table key_vault add column \(column) \(type);"),
                    "11 must add \(column) \(type), nullable")
        }
        #expect(sql.components(separatedBy: "alter table key_vault add column").count - 1 == 7,
                "exactly seven additive columns")
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
        #expect(!sql.contains("grant delete on key_vault") && !sql.contains("grant all on key_vault"),
                "still no delete grant — account_purge is the only removal")
        // The window's sweep (2026-09-06) found `authenticated` still holding DELETE from
        // Supabase's default grant at 08's CREATE (RLS's missing DELETE policy fenced it);
        // 11 names the revoke so a future deploy lands the posture directly.
        #expect(sql.contains("revoke delete on key_vault from authenticated;"),
                "the default DELETE grant is revoked by name")
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
        // 13y UNIT B re-pointed this pin at 11's OWN file: the check it
        // pins — the static compare with the NULL-hash migration arm — is
        // the marker-8 ERA's deployed body (history, byte-untouched),
        // superseded in the composition by 12's challenge-verified check
        // (its own pins sit in the 12 block; the migration arm RETIRED
        // with the static road — hers landed 2026-09-06).
        let eleven = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let body = try #require(Self.lastBody(of: "sync_key_proof_check", in: eleven))
        #expect(body.contains("select true, key_proof_hash into vault_found, stored_hash\n    from key_vault where user_id = caller;"),
                "the re-read under the lock the CALLER holds — no lock clause of its own (an upgrade under a second share lock would deadlock)")
        #expect(!body.contains("for share") && !body.contains("for update"),
                "the proof check takes no lock: the gate (or key_vault_update) chose it")
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

    /// THE NULL-HASH ARM TAKES THE ROW FOR UPDATE (the orchestrator's ruling
    /// on 1b's question 5): the gate PEEKS the hash unlocked and chooses the
    /// lock — FOR UPDATE from the start on a NULL (the migration arm's
    /// exclusive write), FOR SHARE on a landed hash — so two racing first
    /// rounds serialize on the row lock and never on the deadlock detector;
    /// the proof check's write runs under that held lock and only when the
    /// re-read still finds NULL.
    @Test func theNullHashArmTakesTheRowForUpdateFromTheStartNeverByUpgrade() throws {
        let gate = try Self.finalBody(of: "sync_key_gate")
        #expect(gate.contains("select key_proof_hash into peek_hash from key_vault where user_id = caller;"),
                "the unlocked peek decides the lock")
        let peek = try #require(gate.range(of: "select key_proof_hash into peek_hash"))
        let forUpdate = try #require(gate.range(of: "if peek_hash is null then\n    select corpus_key_id into fence_key from key_vault where user_id = caller for update;"))
        let forShare = try #require(gate.range(of: "else\n    select corpus_key_id into fence_key from key_vault where user_id = caller for share;"))
        let fence = try #require(gate.range(of: "if fence_key is null or fence_key is distinct from active_key_id then"))
        #expect(peek.lowerBound < forUpdate.lowerBound && forUpdate.lowerBound < forShare.lowerBound
                    && forShare.lowerBound < fence.lowerBound,
                "peek → the lock branches → the fence — the lock is taken BEFORE any check, once, for the round")
        // The ARM itself is the marker-8 era's (11's own file — retired by
        // 12's challenge-verified check, whose body carries NO hash-landing
        // write; the 12 block pins the retirement).
        let eleven = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let check = try #require(Self.lastBody(of: "sync_key_proof_check", in: eleven))
        #expect(check.contains("if stored_hash is null then") && check.contains("update key_vault set key_proof_hash = presented_hash where user_id = caller;"),
                "the arm's write, only when the re-read under the held lock still finds NULL")
        #expect(!check.contains("deadlock detector aborting"), "the deadlock detector is no longer the arm's resolution")
        // `key_vault_update` holds FOR UPDATE before it calls the check —
        // the same exclusive discipline (pinned in its own test; the call
        // is challenge-verified since UNIT B).
        let update = try Self.finalBody(of: "key_vault_update")
        let lock = try #require(update.range(of: "for update;"))
        let call = try #require(update.range(of: "perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');"))
        #expect(lock.lowerBound < call.lowerBound)
    }

    /// THE ROTATION'S WRITE (decision 6): version-neutral — the payload
    /// replaced where the version matches, a FRESH seq through the trigger,
    /// the version KEPT; a moved version SKIPPED with the current one;
    /// tenant-scoped, registry-exact, the push posture.
    @Test func theReencryptDoorIsVersionNeutralTenantScopedAndRegistryExact() throws {
        let body = try Self.finalBody(of: "sync_reencrypt")
        #expect(body.contains("security definer"))
        #expect(body.contains("caller := auth.uid();"))
        #expect(body.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_reencrypt');"))
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
        // THE ROTATION-ERA body — 12's canonical one (the F1 completion
        // guard FOLDED IN, and the rotation seq minted from the CALLER'S
        // OWN counter, M3); 11's era body (the overlay's) stays pinned
        // line for line by the sibling
        // `theClearingGuardOverlayIsElevensBodyPlusOneClause`, and the
        // fold-in's exactness by `theCompletionGuardIsTheOverlaysBodyWithExactlyTheMintSwapped`.
        // VX-329 (marker 14): 17 REDEFINES the door and RETIRES rotation,
        // so 12's body is HISTORY here (read from 12's own file), and the
        // DEPLOYED body's pin is `theMarker14VaultDoorRetiresRotation…`.
        // The last pre-17 definition is 13's (13i-a re-carried the body
        // with the wing/shelf ciphertext registry) — the rotation era's
        // deployed truth; 12's fold-in exactness is the siblings' pin.
        let thirteen = Self.strippingComments(try Self.sqlFile("13_phase13i_wings.sql"))
        let deployed = try #require(Self.lastBody(of: "key_vault_update", in: thirteen))
        try Self.expectVaultUpdateDoor(deployed, mintsRotationSeqWith: "next_tenant_seq(caller)")
        #expect(deployed.contains(SyncServerRefusalMarker.rotationRowsRemain),
                "F1 (BLOCKER-1): completion is 'no row of mine below it' — the clearing arm refuses while one remains")
        #expect(deployed.contains("if vault_previous is not null then")
                    && deployed.contains("for rows_below_tbl in select jsonb_object_keys(ciphertext_columns) loop")
                    && deployed.contains("select string_agg(format('t.%I is not null', c.col), ' or ')")
                    && deployed.contains("'select count(*) from %I t where t.owner_id = $1 and t.server_seq < $2 and (%s)'")
                    && deployed.contains("into rows_below using caller, vault_seq;")
                    && deployed.contains("if rows_below > 0 then"),
                "the guard counts the CALLER's rows below the rotation seq that CARRY ciphertext (an encrypted column not null), per encrypted table, only while a previous key stands")
        // The clause sits INSIDE the clearing arm, BEFORE the seq clears —
        // a refused completion clears nothing.
        let arm = try #require(deployed.range(of: "if incoming_previous is null then"))
        let guardSite = try #require(deployed.range(of: SyncServerRefusalMarker.rotationRowsRemain))
        let clearSite = try #require(deployed.range(of: "next_seq := null;"))
        #expect(arm.lowerBound < guardSite.lowerBound && guardSite.lowerBound < clearSite.lowerBound,
                "the guard runs in the clearing arm before the seq is nulled")
    }

    /// THE MARKER-14 DOOR (VX-307's artifact, registered at VX-329): the
    /// DEPLOYED `key_vault_update` is 17's — the FOR UPDATE lock, the
    /// challenge-verified proof and the revision CAS kept byte-faithful
    /// from 12; EVERY rotation arm retired with rotation itself; the mode
    /// shape landed (`mode` + `earlier_row_keys` from the payload, a
    /// pre-VX307 payload refused loudly). The artifact's own text pins are
    /// `VX307VaultArtifactTests`; THIS pin is the chain's resolution — the
    /// deployed truth is 17's body, not 12's.
    @Test func theMarker14VaultDoorRetiresRotationAndLandsTheModeShape() throws {
        let body = try Self.finalBody(of: "key_vault_update")
        let seventeen = Self.strippingComments(try Self.sqlFile("17_phase_vx307_vault.sql"))
        #expect(body == (try #require(Self.lastBody(of: "key_vault_update", in: seventeen))),
                "the deployed door IS 17's body — the chain resolves past 12")
        // Kept from 12, byte-faithful clauses:
        #expect(body.contains("from key_vault where user_id = caller for update;"),
                "the serialization point (decision 31) survives the redefinition")
        #expect(body.contains("perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');"))
        #expect(body.contains(SyncServerRefusalMarker.vaultAbsent))
        #expect(body.contains(SyncServerRefusalMarker.vaultRevisionConflict))
        #expect(body.contains("where user_id = caller and revision = expected_revision;"), "the CAS belt inside")
        // The mode shape:
        #expect(body.contains("VARIORUM_PRE_VX307_PAYLOAD"),
                "a payload with no mode is a pre-VX307 client's and refuses loudly")
        #expect(body.contains("mode                                 = payload->>'mode',")
                    && body.contains("earlier_row_keys                     = payload->'earlier_row_keys',"),
                "mode and the earlier keys land from the payload (rule 15's kept list)")
        // Rotation retired whole:
        #expect(!body.contains("VARIORUM_ROTATION") && !body.contains("next_tenant_seq")
                    && !body.contains("corpus_previous_key_id") && !body.contains("rotation_started_seq"),
                "no rotation arm survives in the deployed door (VX-329 — rotation retires with today's road)")
        #expect(!body.contains("payload->>'revision'") && !body.contains("payload->>'user_id'")
                    && !body.contains("payload->>'updated_at'"),
                "server-managed columns never come from the payload")
        #expect(body.contains("return jsonb_build_object('revision', expected_revision + 1);"),
                "the receipt carries the new revision — and no rotation seq exists to carry")
    }

    /// The one write road's clauses, as a sentence about a BODY. `mint` is
    /// the rotation-begin expression the body must take its seq from —
    /// `next_tenant_seq(caller)` since 13y's 12 (the caller's own counter);
    /// the 11-era bodies said `nextval('sync_server_seq')`.
    private static func expectVaultUpdateDoor(
        _ body: String, mintsRotationSeqWith mint: String
    ) throws {
        #expect(body.contains("security definer"))
        #expect(body.contains("caller := auth.uid();"), "scoped to the caller — the 14c guard")
        #expect(body.contains("from key_vault where user_id = caller for update;"),
                "the serialization point (decision 31)")
        #expect(body.contains(SyncServerRefusalMarker.vaultAbsent))
        // 13y UNIT B: the door's ONLY callers here are 12's bodies — the
        // proof is challenge-verified, bound to the door's own name.
        #expect(body.contains("perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');"),
                "the CURRENT proof authorizes — challenge-verified")
        #expect(body.contains("incoming_previous_id := payload->>'corpus_previous_key_id';")
                    && body.contains("incoming_previous := payload->>'corpus_previous_wrapped_by_master';"),
                "the previous key is its id AND its wrap — two columns")
        #expect(body.contains("if (incoming_previous is null) <> (incoming_previous_id is null) then"),
                "one without the other refuses")
        #expect(body.contains("elsif vault_previous is null then")
                    && body.contains("next_seq := \(mint);"),
                "a rotation begins: the seq minted INSIDE this transaction, the row locked, from \(mint)")
        #expect(body.contains("elsif incoming_previous = vault_previous and incoming_previous_id = vault_previous_id then")
                    && body.contains("next_seq := vault_seq;"),
                "a carry-through (a re-wrap mid-rotation with the SAME previous key) keeps the seq — decision 32's precision")
        #expect(body.contains(SyncServerRefusalMarker.rotationInProgress),
                "a DIFFERENT previous key while one stands refuses (decision 32)")
        #expect(body.contains("if incoming_previous is null then") && body.contains("next_seq := null;"),
                "clearing the key clears the seq with it")
        #expect(body.contains("corpus_previous_key_id               = incoming_previous_id,"))
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
                       "apple_key_id", "updated_by_device"] {
            #expect(body.contains("= payload->>'\(column)'") || body.contains("(payload->>'\(column)')::int"),
                    "the WHOLE format is replaced: \(column) comes from the payload")
        }
        // Decision 34 (2c): the seventh column is written from the payload —
        // the writing device's own name; never a server guess, never ignored.
        #expect(body.contains("updated_by_device                    = payload->>'updated_by_device',"),
                "the seventh column: the writer's name comes FROM the payload")
        #expect(!body.contains("payload->>'revision'") && !body.contains("payload->>'rotation_started_seq'")
                    && !body.contains("payload->>'user_id'") && !body.contains("payload->>'updated_at'"),
                "server-managed columns never come from the payload")
        #expect(body.contains("'revision', expected_revision + 1") && body.contains("'rotation_started_seq', next_seq"),
                "the receipt carries both")
    }

    /// pre-13x ladder round 1, F1 (BLOCKER-1) — THE MAINTENANCE OVERLAY IS
    /// 11's BODY PLUS ONE CLAUSE: with its two fenced F1 regions removed,
    /// the overlay's `key_vault_update` (signature and body) EQUALS 11's
    /// section-13 text line for line — so the repair can never quietly
    /// re-shape the door; it carries the re-run guard, re-owns and
    /// re-grants exactly as 11 does, names the finding in its header, and
    /// never touches the lockstep marker (a stricter refusal is additive —
    /// SyncSpec §12's letter; the marker stays 8).
    @Test func theClearingGuardOverlayIsElevensBodyPlusOneClause() throws {
        let raw = try Self.sqlFile(Self.ladderOverlayFile)
        #expect(raw.contains("BLOCKER-1") && raw.contains("notes/plans/pre-13x-ladder-round-1.md"),
                "the header names the finding it repairs")
        #expect(raw.components(separatedBy: Self.overlayFenceOpen).count == 4
                    && raw.components(separatedBy: Self.overlayFenceClose).count == 4,
                "exactly three fenced F1 regions: the re-run guard, the declarations, the clause")
        // The body, minus the fences, IS 11's.
        let stripped11 = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let body11 = try #require(Self.lastBody(of: "key_vault_update", in: stripped11))
        let overlayMinusFences = Self.strippingComments(Self.overlayWithoutFences(raw))
        let overlayBody = try #require(Self.lastBody(of: "key_vault_update", in: overlayMinusFences))
        let lines11 = body11.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let overlayLines = overlayBody.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        #expect(overlayLines == lines11,
                "the overlay's key_vault_update, fences removed, is 11's line for line (signature included)")
        #expect(overlayLines.first == "create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text) returns jsonb",
                "the SAME signature — a body change only")
        // The guard's history: 11 never carried it; 12's fold-in did; the
        // marker-14 door (17) RETIRES it with rotation itself (VX-329).
        #expect(!body11.contains(SyncServerRefusalMarker.rotationRowsRemain), "11 itself is untouched")
        let stripped12 = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body12 = try #require(Self.lastBody(of: "key_vault_update", in: stripped12))
        #expect(body12.contains(SyncServerRefusalMarker.rotationRowsRemain),
                "12's fold-in carried the guard — the rotation era's deployed truth")
        #expect(!(try Self.deployedBody(of: "key_vault_update")).contains(SyncServerRefusalMarker.rotationRowsRemain),
                "the marker-14 door retires the guard with rotation (17 redefines the body)")
        // The re-run guard: refuses below marker 8 and a second deploy.
        #expect(raw.contains("VARIORUM_CLEARING_GUARD_NEEDS_11") && raw.contains("if deployed_marker < 8 then"))
        #expect(raw.contains("VARIORUM_CLEARING_GUARD_ALREADY_DEPLOYED")
                    && raw.contains("like '%VARIORUM_ROTATION_ROWS_REMAIN%'"))
        // Ownership + the posture, 11's own statements for this function.
        let overlay = Self.strippingComments(raw)
        for statement in [
            "grant usage, create on schema public to variorum_definer;",
            "alter function key_vault_update(jsonb, int, text) owner to variorum_definer;",
            "revoke create on schema public from variorum_definer;",
            "revoke execute on function key_vault_update(jsonb, int, text) from public, anon, service_role;",
            "grant execute on function key_vault_update(jsonb, int, text) to authenticated;",
        ] {
            #expect(overlay.contains(statement), "the overlay re-owns and re-grants as 11 does: \(statement)")
        }
        #expect(!overlay.contains("lockstep_version', '") && !overlay.contains("insert into sync_meta"),
                "no marker bump — the repair is body-only and additive")
        #expect(!overlay.contains("drop function"), "a replace, never a drop — the signature never leaves the mirror")
        // One transaction.
        #expect(overlay.contains("begin;") && overlay.contains("commit;"))
    }

    /// F1 (BLOCKER-1) — THE GUARD'S COLUMN MAP IS THE REGISTRY'S: the
    /// overlay's `ciphertext_columns` jsonb EQUALS, table by table, the
    /// registry's `encryptedColumns` for every table that has any (`SyncSchema
    /// .tablesCarryingCiphertext`) — never an all-plain table (which would
    /// make the guard refuse a completion over rows under no key), never a
    /// ciphertext table or column missing (which would let a straggler
    /// through), never an extra column (which would count plain values as
    /// ciphertext). The predicate — at least one of those columns NOT NULL —
    /// is `SyncSchema.rowCarriesCiphertext`'s letter. A future encrypted
    /// column fails HERE.
    @Test func theClearingGuardCountsExactlyTheTablesThatCarryCiphertext() throws {
        let overlay = Self.strippingComments(try Self.sqlFile(Self.ladderOverlayFile))
        let open = try #require(overlay.range(of: "ciphertext_columns constant jsonb := '"))
        let close = try #require(overlay.range(of: "'::jsonb;", range: open.upperBound..<overlay.endIndex))
        let json = String(overlay[open.upperBound..<close.lowerBound])
        let decoded = try #require(try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: [String]])
        let listed = decoded.mapValues { Set($0) }
        // The overlay is a SUPERSEDED pre-13x artifact (12 folded it); its
        // map is pinned against the registry AS OF ITS ERA — tables born
        // at 13i-a (wing, shelf) are subtracted, exactly as the floor pin
        // freezes 12's era. The LIVE map's exactness pin is the canonical
        // body's (`theCompletionGuardLivesInTheCanonicalTwelveBody`,
        // resolved through the composition — 13's body since 13i-a).
        let registry = Dictionary(uniqueKeysWithValues: SyncSchema.tablesCarryingCiphertext
            .filter { !["wing", "shelf"].contains($0.name) }
            .map { ($0.name, $0.encryptedColumns) })
        #expect(listed == registry, "the SQL's map is the registry's encrypted columns per table: SQL \(listed) vs registry \(registry)")
        #expect(!registry.isEmpty && registry.count < SyncSchema.tables.count,
                "the pin isn't vacuous: some tables carry ciphertext, some carry none")
        // The predicate reads those columns and nothing else.
        #expect(overlay.contains("format('t.%I is not null', c.col)") && overlay.contains("' or '"),
                "a row carries ciphertext when at least one of its encrypted columns is not null")
        // Every listed table is one `sync_reencrypt` re-stamps (11's allowed list).
        let reencrypt = try Self.finalBody(of: "sync_reencrypt")
        for table in listed.keys {
            #expect(reencrypt.contains("'\(table)'"), "\(table) is a table the walk can re-stamp above the seq")
        }
        // The all-plain tables are the complement, by name.
        let plain = Set(SyncSchema.tables.map(\.name)).subtracting(registry.keys)
        #expect(plain.contains("purge_intent") && plain.contains("edge") && plain.contains("setting"),
                "the orchestrator's named exclusions are plain-only in the registry")
        for table in plain {
            #expect(listed[table] == nil, "\(table) carries no ciphertext and must not hold a completion")
        }
        // The client predicate agrees with the map: a row with every encrypted
        // column NULL carries no ciphertext; one `e1:` value does.
        let blank = SyncRow(table: "block", rowID: "b", columns: ["id": .text("b"), "name": .null, "presentation": .null], syncVersion: 0)
        #expect(!SyncSchema.rowCarriesCiphertext(blank))
        var named = blank
        named.columns["name"] = .text("e1:sealed")
        #expect(SyncSchema.rowCarriesCiphertext(named))
        #expect(!SyncSchema.rowCarriesCiphertext(SyncRow(table: "edge", rowID: "e", columns: ["id": .text("e"), "type": .text("derived_from")], syncVersion: 0)),
                "a plain table's row never carries ciphertext")
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

    // MARK: - Phase 13y UNIT A: the per-tenant `server_seq` event (12) pins.
    // The plan (notes/plans/phase-13y-per-tenant-seq.md — the Step 0 survey's
    // verdict table + findings F-S1..F-S4) is the binding record; the
    // artifact is AUTHORED AND PINNED, NOT DEPLOYED — deploy is the
    // orchestrator's ONE end-of-phase window (R-13y-2).

    /// A body's code lines, trimmed and non-empty — the equality surface
    /// the verbatim-modulo pins below compare on (the overlay pin's idiom).
    private static func codeLines(_ body: String) -> [String] {
        body.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// 13y UNIT B: remove EXACTLY ONE contiguous occurrence of `block`
    /// from `lines`, or nil when the block is not there whole and in
    /// order. The verbatim-modulo pins use it for multi-line insertions
    /// whose members include COMMON lines (`begin`, `end if;`) a set
    /// filter would strip everywhere — the insertion is pinned as one
    /// exact contiguous slice, never as loose membership.
    private static func removingContiguousBlock(
        _ block: [String], from lines: [String]
    ) -> [String]? {
        guard !block.isEmpty, lines.count >= block.count else { return nil }
        for start in 0...(lines.count - block.count) {
            if Array(lines[start..<(start + block.count)]) == block {
                var out = lines
                out.removeSubrange(start..<(start + block.count))
                return out
            }
        }
        return nil
    }

    /// 12 takes the 09/10/11 deploy shape: one transaction, the re-run
    /// guard before the destructive drop, the marker bump last inside the
    /// transaction; the guard keys on evidence only a deployed 12 leaves
    /// (the marker at 9+, or the `sync_tenant_seq` table no other artifact
    /// creates) and spells its one deliberate override.
    @Test func theTenantSeqEventDeploysAsOneGuardedTransaction() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let problems = Self.deployShapeProblems(strippedSQL: sql)
        #expect(problems.isEmpty, "12's deploy shape is unsound: \(problems.sorted())")
        #expect(sql.contains("deployed_marker >= 9 or counter_table_here"))
        #expect(sql.contains("to_regclass('public.sync_tenant_seq') is not null"))
        #expect(sql.contains("VARIORUM_12_ALREADY_DEPLOYED"))
        #expect(sql.contains("current_setting('variorum.allow_12_rerun', true)")
                    && sql.contains("'yes-rerun-the-tenant-seq-event'"),
                "the deliberate override must be spelled in the file the operator is reading")
        #expect(sql.contains("hint    ="), "the refusal carries the operator's next step")
    }

    /// NIT-4 (the pre-13x ladder): `sync_pull`'s `key_proof` is DEFAULTLESS
    /// — the OLD signature (the only reason the proof ever carried
    /// `default null`) is dropped FIRST, the reordered one created, the
    /// ownership dance run and the grants re-stated (they died with the
    /// drop). No defaulted proof survives anywhere in 12.
    @Test func theTenantSeqEventDropsTheOldPullSignatureAndMakesTheProofDefaultless() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        // 13y UNIT B: EVERY 11-era gated signature is dropped first (an
        // overload left standing would be a CHALLENGE-FREE door beside the
        // new one — the static-bearer road this half of the event closes),
        // the helpers included.
        let drops = [
            "drop function if exists sync_pull(bigint, text, int, text, text);",
            "drop function if exists sync_push(jsonb, text, text);",
            "drop function if exists sync_horizon(text, text);",
            "drop function if exists sync_purge_ledger(bigint, text, text);",
            "drop function if exists sync_purge_execute(jsonb, text, text);",
            "drop function if exists account_data_truncate(text, text);",
            "drop function if exists sync_reencrypt(jsonb, text, text);",
            "drop function if exists key_vault_update(jsonb, int, text);",
            "drop function if exists sync_key_gate(text, text);",
            "drop function if exists sync_key_proof_check(text);",
        ]
        let create = "create or replace function sync_pull(since_seq bigint, active_key_id text, key_proof text, challenge text, max_rows int default 500, for_device text default null)"
        #expect(sql.contains(create),
                "the reordered signature: key_proof AND the challenge defaultless, before the defaulted parameters")
        let createSite = try #require(sql.range(of: create))
        for drop in drops {
            let dropSite = try #require(sql.range(of: drop), "the 11-era overload must be dropped: \(drop)")
            #expect(dropSite.lowerBound < createSite.lowerBound,
                    "every drop precedes the creates — no window holds both: \(drop)")
        }
        #expect(!sql.contains("key_proof text default null"),
                "the proof is defaultless everywhere in 12 — NIT-4's letter")
        #expect(!sql.contains("challenge text default"),
                "the challenge is defaultless everywhere in 12 — the same letter")
        #expect(sql.contains("alter function sync_pull(bigint, text, text, text, int, text) owner to variorum_definer;"))
        #expect(sql.contains("revoke execute on function sync_pull(bigint, text, text, text, int, text) from public, anon;"))
        #expect(sql.contains("grant execute on function sync_pull(bigint, text, text, text, int, text) to authenticated, service_role;"))
        #expect(sql.contains("grant usage, create on schema public to variorum_definer;")
                    && sql.contains("revoke create on schema public from variorum_definer;"),
                "the CREATE-for-acquisition dance is opened and closed in the same transaction")
    }

    /// The reordered `sync_pull` is 11's body VERBATIM below the signature
    /// MODULO exactly the horizon derivation (the R-13y-4 fork's ruling,
    /// Shape 1, the piece that closed UNIT A): one declare line added —
    /// the horizon read ONCE from `sync_visibility_horizon_ms()` — and
    /// the two branch filters swapped from the inline literal to the
    /// derived interval (each swap is a filter line + its format-args
    /// line) — PLUS, since UNIT B, exactly the challenge-gate swap (the
    /// gate call gains the challenge and names the RPC). Line for line,
    /// nothing else moved: a quiet body change can ride neither the
    /// reorder, the derivation, nor the challenge. (This pin's earlier
    /// form asserted plain equality below the signature; the ruled swaps
    /// re-shaped it — the `theCompletionGuardIsTheOverlaysBody…` idiom.)
    @Test func theTenantSeqPullIsElevensBodyWithExactlyTheHorizonDerivationSwapped() throws {
        let eleven = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let twelve = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body11 = Self.codeLines(try #require(Self.lastBody(of: "sync_pull", in: eleven)))
        let body12 = Self.codeLines(try #require(Self.lastBody(of: "sync_pull", in: twelve)))
        #expect(body11.first != body12.first, "the signature lines differ — the reorder + the challenge")
        let declare = "horizon interval := make_interval(secs => sync_visibility_horizon_ms() / 1000.0);"
        #expect(body12.filter { $0 == declare }.count == 1,
                "the horizon is read ONCE into a local, from the one serving function")
        let swapped = Array(body11.dropFirst()).map { line in
            switch line {
            case "and t.server_written_at <= clock_timestamp() - interval '2 seconds'$q$,":
                return "and t.server_written_at <= clock_timestamp() - %L::interval$q$,"
            case "tbl, sync_table_pk(tbl), tbl, caller, since_seq);":
                return "tbl, sync_table_pk(tbl), tbl, caller, since_seq, horizon);"
            case "perform sync_key_gate(active_key_id, key_proof);":
                return "perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_pull');"
            default:
                return line
            }
        }
        #expect(Array(body12.dropFirst()).filter { $0 != declare } == swapped,
                "12's sync_pull is 11's below the signature with exactly the horizon derivation + the challenge gate swapped in")
        #expect(swapped != Array(body11.dropFirst()), "the swap is real — the pin isn't vacuous")
    }

    /// THE SERVED HORIZON (the R-13y-4 fork's ruling, Shape 1 — Step 1's
    /// last piece): `sync_visibility_horizon_ms()` is a sibling zero-arg
    /// definer function on `sync_schema_version()`'s exact shape — SQL,
    /// STABLE, definer, `search_path` pinned, public/anon revoked,
    /// authenticated + service_role granted, `variorum_definer`-owned via
    /// the acquisition dance — returning the constant 2000. The pull's
    /// derivation from it is pinned above (the verbatim-modulo pin + the
    /// re-pointed A5 pin). A NEW-MECHANISM pin, green by design — not a
    /// defect fix, so no red-on-old is owed; the non-vacuous arm is the
    /// derivation pins' ban on the inline literal.
    @Test func theServedHorizonIsAConstantFunctionOnTheVersionRPCsShape() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body = try #require(Self.lastBody(of: "sync_visibility_horizon_ms", in: sql))
        #expect(body.contains("create or replace function sync_visibility_horizon_ms() returns bigint"))
        #expect(body.contains("language sql stable security definer"),
                "the version RPC's exact shape — zero-arg, STABLE, definer")
        #expect(body.contains("set search_path = public"))
        #expect(body.contains("select 2000;"),
                "the deployed constant — the client's wait derives against the SERVED value, never this literal")
        #expect(sql.contains("alter function sync_visibility_horizon_ms() owner to variorum_definer;"),
                "the acquisition dance re-owns the new function")
        #expect(sql.contains("revoke execute on function sync_visibility_horizon_ms() from public, anon;"))
        #expect(sql.contains("grant execute on function sync_visibility_horizon_ms() to authenticated, service_role;"),
                "sync_schema_version()'s exact grant pair")
        // THE CROSS-PIN (the client half): the deployed constant, fed to
        // the client's ONE derivation, yields exactly the retired
        // hardcoded wait — if either side moves alone, this line names
        // the other (a horizon change is a §12 act moving BOTH: the
        // function above and, for free, every derived wait).
        let constant = try #require(Int64(
            body.components(separatedBy: "select ").last?
                .components(separatedBy: ";").first ?? ""))
        #expect(CorpusRotation.horizonWait(forServedMillis: constant) == .milliseconds(2500),
                "served \(constant) + the derived margin must equal the wait the retired hardcode stated")
    }

    /// The per-owner counter table takes the `device_cursor` posture
    /// exactly: server-only (never in an allowlist), FORCE RLS with the
    /// no-`to`-clause owner policy (the definer must match it), API-role
    /// privileges revoked, the definer's row grants for the upsert.
    @Test func theCounterTableTakesTheDeviceCursorPosture() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        #expect(sql.contains("create table sync_tenant_seq ("))
        #expect(sql.contains("primary key (owner_id)"))
        #expect(sql.contains("alter table sync_tenant_seq enable row level security;"))
        #expect(sql.contains("alter table sync_tenant_seq force row level security;"))
        #expect(sql.contains("create policy sync_tenant_seq_owner_all on sync_tenant_seq"))
        #expect(sql.contains("for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());"))
        #expect(sql.contains("revoke all on sync_tenant_seq from anon, authenticated;"))
        #expect(sql.contains("grant select, insert, update on sync_tenant_seq to variorum_definer;"))
        #expect(!sql.contains("on sync_tenant_seq to authenticated"), "no API-role road back")
        for function in Self.proofGatedFunctions {
            let body = try Self.finalBody(of: function)
            #expect(!body.contains("'sync_tenant_seq'"),
                    "\(function)'s allowlist must never carry the counter table")
        }
    }

    /// The ONE counter function: a row-locked upsert-increment (the row
    /// lock IS the per-tenant serialization — one account's writers
    /// serialize on their own row; tenants never contend), SECURITY
    /// INVOKER (the stamp_server_seq class), on the helper posture — no
    /// API role can execute it (Supabase's CREATE-time EXECUTE-to-PUBLIC
    /// default revoked by name; the definer bodies and the trigger are
    /// its only callers).
    @Test func theCounterFunctionIsARowLockedUpsertIncrementOnTheHelperPosture() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body = try #require(Self.lastBody(of: "next_tenant_seq", in: sql))
        #expect(body.contains("create or replace function next_tenant_seq(for_tenant uuid) returns bigint"))
        #expect(body.contains("insert into sync_tenant_seq (owner_id, last_seq)"))
        #expect(body.contains("on conflict (owner_id) do update"))
        #expect(body.contains("set last_seq = sync_tenant_seq.last_seq + 1"))
        #expect(body.contains("returning last_seq into granted;"),
                "the upsert RETURNING is what makes mint-and-lock one statement")
        #expect(body.contains("set search_path = public"))
        #expect(!body.contains("security definer"),
                "SECURITY INVOKER — the FORCE-RLS policy binds even a misuse to the caller's own row")
        #expect(sql.contains("revoke execute on function next_tenant_seq(uuid) from public, anon, authenticated, service_role;"))
        #expect(sql.contains("grant execute on function next_tenant_seq(uuid) to variorum_definer;"))
        #expect(!sql.contains("next_tenant_seq(uuid) to authenticated")
                    && !sql.contains("next_tenant_seq(uuid) to service_role")
                    && !sql.contains("next_tenant_seq(uuid) to anon"),
                "the helper is reachable by NO API role")
    }

    /// THE STRUCTURAL CLOSURE (the phase's WHY): every mint site draws
    /// from the OWNER's counter — the stamp trigger (M1, `new.owner_id`),
    /// the purge door's granted ledger seq (M2, `caller`) and the
    /// rotation-begin seq (M3, `caller`) — and the GLOBAL sequence is
    /// DROPPED (F-S4: fail-loud — a future `nextval` of it ERRORS instead
    /// of silently reopening the cross-tenant disclosure). No `nextval`
    /// survives anywhere in 12.
    @Test func everyMintSiteDrawsFromTheOwnersCounterAndTheGlobalSequenceRetires() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let trigger = try Self.finalBody(of: "stamp_server_seq")
        #expect(trigger.contains("new.server_seq := next_tenant_seq(new.owner_id);"),
                "M1: every data row's seq draws from its OWNER's counter")
        #expect(trigger.contains("new.server_written_at := clock_timestamp();"),
                "the A5 substrate stays — the horizon is untouched by this event")
        #expect(try Self.finalBody(of: "sync_purge_execute")
                    .contains("granted_seq := next_tenant_seq(caller);"),
                "M2: the granted ledger seq is the caller's own")
        let twelveBody = try #require(Self.lastBody(of: "key_vault_update",
                                                    in: Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))))
        #expect(twelveBody.contains("next_seq := next_tenant_seq(caller);"),
                "M3: the rotation seq is the caller's own — 12's body, the rotation era's deployed truth (17 retires the mint with rotation — the deployed-door pin)")
        #expect(!(try Self.finalBody(of: "key_vault_update")).contains("next_tenant_seq"),
                "the marker-14 door mints nothing: rotation retired, M3's site gone from the deployed body (VX-329)")
        #expect(!sql.contains("nextval"),
                "no global mint survives anywhere in 12")
        #expect(sql.contains("drop sequence if exists sync_server_seq;"),
                "the global sequence retires fail-loud (F-S4)")
    }

    /// THE FLOOR (F-S1 — wider than data-max, deliberately): each owner's
    /// counter initializes to the GREATEST seq any of their bookkeeping
    /// already compares against — EVERY registry table's rows, their
    /// device cursors (a purge can leave data-max below a served cursor —
    /// a narrower floor would mint seqs the pulls never serve), their
    /// ledger entries, and a standing rotation seq. No cursor resets, by
    /// construction; the window's carry-over proof is this floor live.
    @Test func theFloorCoversEveryDataTableAndTheThreeExtraSources() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let open = try #require(sql.range(of: "select owner_id, max(server_seq) from ("))
        let close = try #require(sql.range(of: ") seq_sources", range: open.upperBound..<sql.endIndex))
        let floor = String(sql[open.upperBound..<close.lowerBound])
        // The floor is a 13y DEPLOY-TIME act over the tables that existed
        // AT 13y — it ran once, at the 12 window, and 13i-a's wing/shelf
        // mirrors are born EMPTY under counters that already exist, so no
        // floor ever covers them. The oracle is therefore the 12-era
        // registry, frozen here (13i-a; a FUTURE table joins this
        // subtraction the same way).
        let bornAfterTheFloor: Set<String> = ["wing", "shelf"]
        for table in SyncSchema.tables where !bornAfterTheFloor.contains(table.name) {
            #expect(floor.contains("select owner_id, server_seq from \(table.name)"),
                    "the floor must read \(table.name)'s seqs")
        }
        #expect(floor.contains("select owner_id, last_seq from device_cursor"),
                "the floor must cover the device cursors (F-S1's traced corner)")
        #expect(floor.contains("select owner_id, purged_seq from purged_row"),
                "the floor must cover the purge ledger")
        #expect(floor.contains("select user_id, rotation_started_seq from key_vault where rotation_started_seq is not null"),
                "the floor must cover a standing rotation seq")
        // Exactly the registry's tables + the three extra sources — one
        // SELECT branch each, nothing extra.
        let branchCount = floor.components(separatedBy: "select ").count - 1
        let floorTables = SyncSchema.tables.count - bornAfterTheFloor.count
        #expect(branchCount == floorTables + 3,
                "the floor has \(branchCount) branches; expected \(floorTables) 13y-era tables + 3 extra sources")
        #expect(sql.contains("group by owner_id"))
        #expect(sql.contains("set last_seq = greatest(sync_tenant_seq.last_seq, excluded.last_seq)"),
                "a re-run can only raise a floor, never lower one")
    }

    /// THE FOLD-IN's text pin (the plan's named deliverable — "verified on
    /// the deployed body, never assumed from the overlay's state"): the
    /// CANONICAL 12 body carries the rotation completion guard — the
    /// refusal marker, the per-table count, the guard INSIDE the clearing
    /// arm before the seq clears — and its ciphertext map EQUALS the
    /// client registry's encrypted columns exactly (the overlay pin's
    /// check, applied to 12).
    @Test func theCompletionGuardLivesInTheCanonicalTwelveBody() throws {
        // The rotation era's CANONICAL body — the last pre-17 definition,
        // 13's (13i-a re-carried 12's fold-in with the wing/shelf registry;
        // the deployed door since VX-329 is 17's, pinned by
        // `theMarker14VaultDoorRetiresRotationAndLandsTheModeShape`).
        let body = try #require(Self.lastBody(of: "key_vault_update",
                                              in: Self.strippingComments(try Self.sqlFile("13_phase13i_wings.sql"))))
        #expect(body.contains(SyncServerRefusalMarker.rotationRowsRemain),
                "completion is 'no row of mine below it' — in the CANONICAL body now")
        #expect(body.contains("if vault_previous is not null then")
                    && body.contains("for rows_below_tbl in select jsonb_object_keys(ciphertext_columns) loop")
                    && body.contains("select string_agg(format('t.%I is not null', c.col), ' or ')")
                    && body.contains("'select count(*) from %I t where t.owner_id = $1 and t.server_seq < $2 and (%s)'")
                    && body.contains("into rows_below using caller, vault_seq;")
                    && body.contains("if rows_below > 0 then"),
                "the guard counts the CALLER's ciphertext-carrying rows below the rotation seq")
        let arm = try #require(body.range(of: "if incoming_previous is null then"))
        let guardSite = try #require(body.range(of: SyncServerRefusalMarker.rotationRowsRemain))
        let clearSite = try #require(body.range(of: "next_seq := null;"))
        #expect(arm.lowerBound < guardSite.lowerBound && guardSite.lowerBound < clearSite.lowerBound,
                "the guard runs in the clearing arm before the seq is nulled")
        // The map is the registry's, byte-exact (a future encrypted column
        // fails HERE, in the canonical file — the overlay's twin pin keeps
        // the historical artifact honest independently).
        let open = try #require(body.range(of: "ciphertext_columns constant jsonb := '"))
        let close = try #require(body.range(of: "'::jsonb;", range: open.upperBound..<body.endIndex))
        let json = String(body[open.upperBound..<close.lowerBound])
        let decoded = try #require(
            try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: [String]])
        let listed = decoded.mapValues { Set($0) }
        let registry = Dictionary(
            uniqueKeysWithValues: SyncSchema.tablesCarryingCiphertext.map { ($0.name, $0.encryptedColumns) })
        #expect(listed == registry,
                "12's ciphertext map drifted from the registry: \(listed) vs \(registry)")
        // And the superseded overlay says so in its header.
        let overlayHeader = try Self.sqlFile(Self.ladderOverlayFile)
        #expect(overlayHeader.contains("SUPERSEDED BY `12_phase13y_tenant_seq.sql`"),
                "the overlay must carry the superseded-by-12 header note")
    }

    /// THE FOLD-IN's exactness: 12's `key_vault_update` is the OVERLAY's
    /// deployed body (11 + the guard) with EXACTLY the enumerated UNIT A +
    /// UNIT B moves — the M3 mint swap, the challenge signature and
    /// proof-check swaps, and the two contiguous UNIT B insertions (the
    /// successor declarations; the hash-and-secret-land-together block) —
    /// line for line, nothing else moved. The strongest form of "the
    /// guard's body folded in, never re-shaped".
    @Test func theCompletionGuardIsTheOverlaysBodyWithExactlyTheMintSwapped() throws {
        let overlay = Self.strippingComments(try Self.sqlFile(Self.ladderOverlayFile))
        let twelve = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let overlayBody = Self.codeLines(try #require(Self.lastBody(of: "key_vault_update", in: overlay)))
        let twelveBody = Self.codeLines(try #require(Self.lastBody(of: "key_vault_update", in: twelve)))
        let swapped = overlayBody.map { line in
            switch line {
            case "next_seq := nextval('sync_server_seq');":
                return "next_seq := next_tenant_seq(caller);"
            case "create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text) returns jsonb":
                return "create or replace function key_vault_update(payload jsonb, expected_revision int, key_proof text, challenge text) returns jsonb"
            case "perform sync_key_proof_check(key_proof);":
                return "perform sync_key_proof_check(key_proof, challenge, 'key_vault_update');"
            default:
                return line
            }
        }
        // The two UNIT B insertions, each ONE exact contiguous slice.
        let successorDeclarations = [
            "incoming_hash text;",
            "incoming_mac text;",
            "incoming_mac_hash text;",
            "vault_current_hash text;",
            "mac_secret_id uuid;",
        ]
        let successorBlock = [
            "if vault_revision is distinct from expected_revision then",
            "raise exception 'VARIORUM_VAULT_REVISION_CONFLICT: the vault changed since it was fetched — fetch it again and re-derive';",
            "end if;",
            "incoming_hash := payload->>'key_proof_hash';",
            "incoming_mac := payload->>'key_proof_mac';",
            "select key_proof_hash into vault_current_hash from key_vault where user_id = caller;",
            "if incoming_mac is not null then",
            "begin",
            "incoming_mac_hash := encode(sha256(decode(incoming_mac, 'base64')), 'hex');",
            "exception when others then",
            "incoming_mac_hash := null;",
            "end;",
            "if incoming_mac_hash is null or incoming_hash is null",
            "or incoming_mac_hash <> incoming_hash then",
            "raise exception 'VARIORUM_KEY_PROOF_REQUIRED: the successor proof secret must hash to the payload''s key_proof_hash — they land together or not at all';",
            "end if;",
            "elsif incoming_hash is not null and incoming_hash is distinct from vault_current_hash then",
            "raise exception 'VARIORUM_KEY_PROOF_REQUIRED: a new key_proof_hash lands only beside its key_proof_mac — a hash that moved without its secret would refuse every follower';",
            "end if;",
            "if incoming_mac is not null then",
            "select s.id into mac_secret_id",
            "from vault.secrets s where s.name = 'kp:' || caller::text;",
            "if mac_secret_id is null then",
            "perform vault.create_secret(incoming_mac, 'kp:' || caller::text);",
            "else",
            "perform vault.update_secret(mac_secret_id, incoming_mac);",
            "end if;",
            "end if;",
        ]
        let withoutBlock = try #require(
            Self.removingContiguousBlock(successorBlock, from: twelveBody),
            "the hash-and-secret block must sit whole and contiguous in 12's body")
        let withoutBoth = try #require(
            Self.removingContiguousBlock(successorDeclarations, from: withoutBlock),
            "the successor declarations must sit whole and contiguous in 12's declare section")
        #expect(swapped == withoutBoth,
                "12's key_vault_update is the overlay's body with exactly the enumerated swaps + the two UNIT B insertions")
        #expect(overlayBody != swapped, "the swaps are real — the pin isn't vacuous")
    }

    /// The purge door's fold: 12's `sync_purge_execute` is 11's body with
    /// EXACTLY the M2 mint swapped + the UNIT B challenge signature/gate
    /// swaps — and NO re-auth window (ladder R1 F-R1: the 13j janitor calls
    /// this door unattended, so a 10-minute amr check would freeze the
    /// autonomous purge pipeline; the re-ruling struck it from this door
    /// only). Red-on-old on the DDL side: the pre-fix body carried the
    /// re-auth block, so `swapped == body12` would fail (swapped has no
    /// re-auth to match it).
    @Test func thePurgeExecutionDoorIsElevensBodyWithExactlyTheMintSwapped() throws {
        let eleven = Self.strippingComments(try Self.sqlFile("11_pre13x_postures.sql"))
        let twelve = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body11 = Self.codeLines(try #require(Self.lastBody(of: "sync_purge_execute", in: eleven)))
        let body12 = Self.codeLines(try #require(Self.lastBody(of: "sync_purge_execute", in: twelve)))
        let swapped = body11.map { line in
            switch line {
            case "granted_seq := nextval('sync_server_seq');":
                return "granted_seq := next_tenant_seq(caller);"
            case "create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text) returns bigint":
                return "create or replace function sync_purge_execute(rows jsonb, active_key_id text, key_proof text, challenge text) returns bigint"
            case "perform sync_key_gate(active_key_id, key_proof);":
                return "perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_purge_execute');"
            default:
                return line
            }
        }
        #expect(swapped == body12,
                "12's sync_purge_execute is 11's body with EXACTLY the mint/challenge/gate swaps — no re-auth (F-R1)")
        #expect(body11 != swapped, "the swaps are real — the pin isn't vacuous")
        // F-R1: this door carries NO re-auth window — its caller is the
        // unattended janitor. (Red-on-old: the pre-fix body contained it.)
        #expect(!body12.contains { $0.contains("VARIORUM_REAUTH_REQUIRED") },
                "sync_purge_execute must NOT demand re-auth — the janitor runs it unattended")
    }

    /// The re-auth window's exact lines (memo §5 — 10 minutes, the JWT's
    /// newest password-method amr timestamp), shared by the two
    /// destructive doors' exactness pins and the guard pin below.
    private static let reauthBlock = [
        "select to_timestamp(max((amr_entry->>'timestamp')::bigint))",
        "into newest_password_auth",
        "from jsonb_array_elements(coalesce(auth.jwt()->'amr', '[]'::jsonb)) amr_entry",
        "where amr_entry->>'method' = 'password';",
        "if newest_password_auth is null",
        "or newest_password_auth < now() - interval '10 minutes' then",
        "raise exception 'VARIORUM_REAUTH_REQUIRED: this act needs a fresh sign-in — confirm the account password and try again';",
        "end if;",
    ]

    /// The whole account goes (the 13j letter, extended): `account_purge`
    /// removes the caller's counter row beside the purge machinery's; and
    /// `account_data_truncate` deliberately does NOT touch the counter —
    /// the owner's sequence stays monotonic across a re-key (cursors stay
    /// valid; SyncSpec §9 per-owner). 12's purge body is 10's with exactly
    /// the one added line.
    @Test func theAccountPurgeTakesTheCounterRowAndTheTruncateNeverDoes() throws {
        let purge = try Self.finalBody(of: "account_purge")
        #expect(purge.contains("delete from sync_tenant_seq where owner_id = caller;"),
                "the account's counter row goes with the account")
        let truncate = try Self.finalBody(of: "account_data_truncate")
        #expect(!truncate.contains("sync_tenant_seq"),
                "a re-key truncate must not touch the counter — monotonic per owner, cursors stay valid")
        // Exactness: 12's purge body is 10's plus exactly ONE contiguous
        // insertion — the counter-row delete (UNIT A) followed by UNIT B's
        // cleanup: the challenge nonces, the budget row, and the
        // best-effort Vault-secret delete (never fails the purge; a
        // dangling secret for a dead uuid authorizes nothing — recorded,
        // window-verified).
        let ten = Self.strippingComments(try Self.sqlFile("10_phase13j_purge.sql"))
        let twelve = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body10 = Self.codeLines(try #require(Self.lastBody(of: "account_purge", in: ten)))
        let body12 = Self.codeLines(try #require(Self.lastBody(of: "account_purge", in: twelve)))
        let insertion = [
            "delete from sync_tenant_seq where owner_id = caller;",
            "delete from key_proof_challenge where owner_id = caller;",
            "delete from sync_write_budget where owner_id = caller;",
            "begin",
            "delete from vault.secrets where name = 'kp:' || caller::text;",
            "exception when others then",
            "null;",
            "end;",
        ]
        let withoutTheBlock = try #require(
            Self.removingContiguousBlock(insertion, from: body12),
            "the account cleanup must sit whole and contiguous in 12's purge body")
        #expect(withoutTheBlock == body10,
                "12's account_purge is 10's body plus exactly the counter + UNIT B cleanup insertion")
        #expect(withoutTheBlock != body12, "the added block is real — the pin isn't vacuous")
    }

    /// The 13j naming rule, applied to 12: no parameter shadows a column
    /// the function writes — `for_tenant` against the counter's columns,
    /// the reordered pull's parameters against `device_cursor`'s, and
    /// UNIT B's parameters against the challenge/budget/vault columns.
    @Test func noTenantSeqParameterShadowsAColumnItWrites() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let counterColumns: Set<String> = ["owner_id", "last_seq"]
        #expect(sql.contains("create or replace function next_tenant_seq(for_tenant uuid)"))
        #expect(!counterColumns.contains("for_tenant"),
                "for_tenant shadows a sync_tenant_seq column")
        let cursorColumns: Set<String> = ["owner_id", "device_id", "last_seq", "seen_at"]
        for param in ["since_seq", "active_key_id", "key_proof", "challenge", "max_rows", "for_device"] {
            #expect(!cursorColumns.contains(param),
                    "sync_pull's \(param) shadows a device_cursor column it writes")
        }
        // UNIT B: the proof check DELETEs against key_proof_challenge; the
        // mint INSERTs into it; the enroll road UPDATEs key_vault; the
        // push writes sync_write_budget.
        let challengeColumns: Set<String> = ["owner_id", "nonce", "issued_at"]
        for param in ["key_proof", "challenge", "rpc_name", "n"] {
            #expect(!challengeColumns.contains(param),
                    "\(param) shadows a key_proof_challenge column it writes")
        }
        let budgetColumns: Set<String> = ["owner_id", "lifetime_rows", "window_start", "window_rows"]
        for param in ["batch", "active_key_id", "key_proof", "challenge"] {
            #expect(!budgetColumns.contains(param),
                    "sync_push's \(param) shadows a sync_write_budget column it writes")
        }
        let vaultColumns: Set<String> = ["user_id", "key_proof_hash", "corpus_key_id", "revision"]
        for param in ["kp1", "kp2", "active_key_id"] {
            #expect(!vaultColumns.contains(param),
                    "key_proof_enroll's \(param) shadows a key_vault column it writes")
        }
    }

    // MARK: - Phase 13y UNIT B: the key-proof challenge · the abuse guard ·
    // the re-auth doors (the ruled memo
    // notes/plans/phase-13y-memo-key-proof-challenge.md; QUESTIONS #144).
    // NEW-MECHANISM pins, green by design (stated per the brief): the
    // artifact is authored, not deployed — these hold its letter exactly
    // as the UNIT A block holds Steps 1–3's.

    /// The two UNIT B tables take the `device_cursor` posture exactly:
    /// server-only (never in an allowlist), FORCE RLS with the
    /// no-`to`-clause owner policy, API-role privileges revoked, the
    /// definer's row grants for exactly the verbs the bodies use.
    @Test func theChallengeAndBudgetTablesTakeTheDeviceCursorPosture() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        for table in ["key_proof_challenge", "sync_write_budget"] {
            #expect(sql.contains("create table \(table) ("))
            #expect(sql.contains("alter table \(table) enable row level security;"))
            #expect(sql.contains("alter table \(table) force row level security;"))
            #expect(sql.contains("create policy \(table)_owner_all on \(table)"))
            #expect(sql.contains("revoke all on \(table) from anon, authenticated;"))
            #expect(!sql.contains("on \(table) to authenticated"), "no API-role road back onto \(table)")
            for function in Self.proofGatedFunctions where function != "sync_push" {
                let body = try Self.finalBody(of: function)
                if table == "sync_write_budget", function == "account_data_truncate" { continue }
                #expect(!body.contains("'\(table)'"),
                        "\(function)'s allowlist must never carry \(table)")
            }
        }
        #expect(sql.contains("grant select, insert, delete on key_proof_challenge to variorum_definer;"),
                "the mint inserts, the check deletes — exactly those verbs")
        #expect(sql.contains("grant select, insert, update, delete on sync_write_budget to variorum_definer;"),
                "the push upserts and updates, the truncate deletes — exactly those verbs")
    }

    /// THE MINT (memo §3/§7 edge 7): session-gated ONLY (no vault
    /// requirement — a not-yet-enrolled account fetches challenges too),
    /// `n` clamped to 32, the caller's expired rows GC'd at every mint
    /// (the 5-minute TTL literal), the 64-row cap evicting oldest-first,
    /// nonces from `gen_random_bytes(32)` under the widened search_path
    /// (pgcrypto lives in `extensions` on Supabase).
    @Test func theChallengeMintIsSessionGatedCappedAndSelfGC() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body = try #require(Self.lastBody(of: "sync_challenge", in: sql))
        #expect(body.contains("create or replace function sync_challenge(n int) returns jsonb"))
        #expect(body.contains("set search_path = public, extensions"))
        #expect(body.contains("raise exception 'sync requires an authenticated user'"),
                "session-gated: a sessionless caller gets nothing")
        #expect(!body.contains("sync_key_gate") && !body.contains("key_vault"),
                "…and ONLY session-gated — no vault requirement, no proof (the enroll road needs a challenge first)")
        #expect(body.contains("granted := least(greatest(coalesce(n, 1), 1), 32);"),
                "n is clamped to 32 per call")
        #expect(body.contains("issued_at < clock_timestamp() - interval '5 minutes'"),
                "the caller's EXPIRED rows are GC'd at every mint — the one TTL literal")
        #expect(body.contains("extensions.gen_random_bytes(32)"))
        #expect(body.contains("if live > 64 then") && body.contains("order by c.issued_at asc")
                    && body.contains("limit live - 64"),
                "the per-owner cap: 64 live nonces, oldest evicted")
        #expect(body.contains("encode(fresh, 'base64')"),
                "the wire carries base64 nonces (44 chars — under PG's 76-char line fold)")
    }

    /// THE ENROLL ROAD (memo §3): FOR UPDATE on the vault row (racing
    /// devices serialize; the loser meets ALREADY_ENROLLED and proceeds),
    /// the fence, ONCE per account (an existing Vault secret refuses),
    /// the OLD hash authorizing via the hoisted constant-time compare,
    /// and the secret + the hash landing TOGETHER
    /// (`vault.create_secret(kp2)` + `key_proof_hash = SHA-256(kp2)`).
    /// The NULL-hash migration arm RETIRED: a hash-less row refuses.
    @Test func theEnrollRoadIsOnceForUpdateAndLandsHashAndSecretTogether() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body = try #require(Self.lastBody(of: "key_proof_enroll", in: sql))
        #expect(body.contains("create or replace function key_proof_enroll(kp1 text, kp2 text, active_key_id text) returns void"))
        #expect(body.contains("from key_vault where user_id = caller for update;"),
                "one enrollment at a time, per account — the row lock serializes the race")
        #expect(body.contains("if vault_fence_key is null or vault_fence_key is distinct from active_key_id then")
                    && body.contains(SyncServerRefusalMarker.staleKeyFence),
                "the fence rides the enroll road too — stale-device honesty")
        #expect(body.contains("from vault.secrets s where s.name = 'kp:' || caller::text;")
                    && body.contains("VARIORUM_KEY_PROOF_ALREADY_ENROLLED"),
                "ONCE per account: an existing secret refuses (the racing loser proceeds — its kp2 is the same)")
        #expect(body.contains("encode(sha256(decode(kp1, 'base64')), 'hex')")
                    && body.contains("not sync_constant_time_equal(stored_hash, presented_hash)"),
                "the OLD hash authorizes the successor, constant-time")
        #expect(body.contains("if stored_hash is null or presented_hash is null"),
                "the NULL-hash arm is RETIRED — a hash-less row refuses, never adopts")
        #expect(!body.contains("update key_vault set key_proof_hash = presented_hash"),
                "…and no first-comer's hash ever lands here")
        let secret = try #require(body.range(of: "perform vault.create_secret(kp2, 'kp:' || caller::text);"))
        let hash = try #require(body.range(of: "update key_vault set key_proof_hash = successor_hash where user_id = caller;"))
        #expect(secret.lowerBound < hash.lowerBound,
                "the secret and the hash land together, one transaction — the function IS the transaction")
    }

    /// THE REWORKED CHECK (memo §3), in the RULED order: the vault re-read
    /// under the caller's held lock (no lock clause of its own — 11's
    /// letter kept) → the Vault-held secret (ABSENT refuses ENROLL,
    /// BEFORE any nonce is consumed — the enroll retry's challenge
    /// survives) → the nonce consumed ATOMICALLY (DELETE … RETURNING —
    /// single-use by construction, THE replay closure) → the 5-minute
    /// SERVER-clock TTL → the HMAC over `nonce ‖ ':' ‖ rpc_name` (the
    /// cross-RPC splicing binding) compared via the hoisted constant-time
    /// helper. The static compare and the migration arm are GONE.
    @Test func theProofCheckConsumesTheNonceInTheRuledOrderAndTheMigrationArmRetires() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        let body = try #require(Self.lastBody(of: "sync_key_proof_check", in: sql))
        #expect(body.contains("create or replace function sync_key_proof_check(key_proof text, challenge text, rpc_name text) returns void"))
        #expect(body.contains("set search_path = public, extensions"))
        #expect(!body.contains("for share") && !body.contains("for update"),
                "the check takes no lock of its own — the gate (or key_vault_update) chose it")
        let vaultRead = try #require(body.range(of: "select true into vault_found from key_vault where user_id = caller;"))
        let secretRead = try #require(body.range(of: "from vault.decrypted_secrets ds"))
        let enrollRefusal = try #require(body.range(of: "VARIORUM_KEY_PROOF_ENROLL"))
        let consume = try #require(body.range(of: "delete from key_proof_challenge"))
        let returning = try #require(body.range(of: "returning issued_at into nonce_issued_at;"))
        let ttl = try #require(body.range(of: "if nonce_issued_at < clock_timestamp() - interval '5 minutes' then"))
        let hmac = try #require(body.range(of: "extensions.hmac("))
        let compare = try #require(body.range(of: "not sync_constant_time_equal(expected_hex, presented_hex)"))
        #expect(vaultRead.lowerBound < secretRead.lowerBound
                    && secretRead.lowerBound < enrollRefusal.lowerBound
                    && enrollRefusal.lowerBound < consume.lowerBound
                    && consume.lowerBound < returning.upperBound
                    && returning.upperBound < ttl.lowerBound
                    && ttl.lowerBound < hmac.lowerBound
                    && hmac.lowerBound < compare.lowerBound,
                "the ruled order: vault → secret (enroll BEFORE consume) → atomic consume → TTL → HMAC → constant-time")
        #expect(body.contains("presented_nonce || convert_to(':' || rpc_name, 'utf8')"),
                "the binding: nonce ‖ ':' ‖ rpc_name — cross-RPC splicing refuses")
        // THE ARGUMENT-ORDER ARM (ladder round 2, R2-F1 — BLOCKER):
        // pgcrypto's hmac is (data, key, type) — the MESSAGE must be the
        // FIRST argument and the Vault-held kp2 (`decode(stored_mac, …)`)
        // the SECOND, or the server computes HMAC_msg(kp2) where the
        // client (`KeyProofMaterial.proof`, memo §3) computes
        // HMAC_kp2(msg) and every honest per-request proof refuses on the
        // real mirror. No executing suite can see a SQL argument-order
        // error (the fakes compute with the client's own function) — this
        // text arm is the one witness. Red-on-old: the pre-fix body
        // passed decode(stored_mac, …) first.
        let message = try #require(
            body.range(of: "presented_nonce || convert_to(':' || rpc_name, 'utf8')"))
        let macKey = try #require(body.range(of: "decode(stored_mac, 'base64')"))
        #expect(hmac.lowerBound < message.lowerBound && message.upperBound <= macKey.lowerBound,
                "hmac(data, key, type): the message is the DATA (first), kp2 the KEY (second) — swapped, the mirror refuses every honest proof")
        // THE FAIL-CLOSED ARM (ladder round 3, R3-F2 — post-cap hardening;
        // GREEN-BY-DESIGN, stated plainly: no red-on-old is possible
        // because every deployed gate call passes a LITERAL rpc_name, so a
        // NULL expected_hex is unreachable today). Unguarded, `false or
        // not NULL` is NULL and the IF would not fire — a NULL expected
        // comparand would fail OPEN (a silent proof BYPASS) instead of
        // refusing. The compare guards BOTH comparands, §5f's own idiom.
        #expect(body.contains("if expected_hex is null or presented_hex is null"),
                "the final compare fails CLOSED on a NULL comparand — both sides guarded (§5f's idiom)")
        #expect(body.components(separatedBy: "VARIORUM_KEY_PROOF_STALE_CHALLENGE").count - 1 == 3,
                "malformed, unknown/consumed, and expired all refuse STALE — fetch fresh and retry once")
        #expect(!body.contains("update key_vault"),
                "the migration arm is RETIRED — the check writes nothing to the vault")
        #expect(!body.contains("encode(sha256(decode(key_proof, 'base64')), 'hex')"),
                "…and the static bearer compare is GONE — the proof is per-request now")
    }

    /// THE MINIMAL ABUSE GUARD (memo §4; the adjudicated shape): the
    /// ruled numbers verbatim — 2,000 per call (the measured shipped
    /// chunk ×10) · the 500,000-row lifetime pool · 50,000 per tumbling
    /// 24-hour window — the REFUSE-WHOLE boundary (no overshoot: the
    /// check reads `window_rows + batch_rows > 50000` BEFORE the loop),
    /// the retry-after in the typed message, the increment counting the
    /// ACTUAL accepted rows AFTER the loop, the budget row locked AFTER
    /// the gate's vault lock (one order, no cycle), and the exemptions:
    /// push is the ONLY quota'd door; the truncate RESETS the pool.
    @Test func theQuotaLivesInThePushAloneWithTheRuledNumbers() throws {
        let push = try Self.finalBody(of: "sync_push")
        #expect(push.contains("if batch_rows > 2000 then"), "the per-call cap: 200 × 10")
        #expect(push.contains("if budget_lifetime >= 500000 then"), "the lifetime first-load pool")
        #expect(push.contains("elsif budget_window_rows + batch_rows > 50000 then"),
                "the refuse-whole boundary — no overshoot, pinned as stated (the adjudication's point 1)")
        #expect(push.contains("clock_timestamp() - budget_window_start >= interval '24 hours'"),
                "the tumbling window (its ≤2× seam worst case ACCEPTED — point 2; 13t re-prices)")
        #expect(push.components(separatedBy: "VARIORUM_WRITE_QUOTA").count - 1 == 2,
                "both refusals — the cap and the window — are typed")
        #expect(push.contains("retry_after_seconds="), "the typed refusal carries a retry-after")
        let gate = try #require(push.range(of: "perform sync_key_gate("))
        let budgetLock = try #require(push.range(of: "insert into sync_write_budget (owner_id) values (caller)"))
        let loop = try #require(push.range(of: "for item in select * from jsonb_array_elements(batch) loop"))
        let increment = try #require(push.range(of: "set lifetime_rows = lifetime_rows + accepted_rows,"))
        #expect(gate.lowerBound < budgetLock.lowerBound && budgetLock.lowerBound < loop.lowerBound
                    && loop.lowerBound < increment.lowerBound,
                "gate (vault lock) → budget lock → the CAS loop → the accepted-count increment — one lock order (point 3)")
        #expect(push.contains("if accepted_rows > 0 then"),
                "the increment counts ACCEPTED rows — CAS rejects burn nothing")
        // The exemptions, each with its reason in the artifact.
        #expect(!(try Self.finalBody(of: "sync_reencrypt")).contains("sync_write_budget"),
                "sync_reencrypt is EXEMPT — a rotation rewrites the corpus by design")
        #expect(!(try Self.finalBody(of: "sync_purge_execute")).contains("sync_write_budget"),
                "sync_purge_execute takes no quota — removal is a right")
        #expect((try Self.finalBody(of: "account_data_truncate"))
                    .contains("delete from sync_write_budget where owner_id = caller;"),
                "the truncate RESETS the pool — the adopt road's repush is a first load")
    }

    /// THE RE-AUTH DOOR (memo §5 as AMENDED 2026-09-23; QUESTIONS #144(c)):
    /// `account_data_truncate` — and ONLY it — carries the EXACT 10-minute
    /// amr window, AFTER the gate (the fence and proof outrank) and BEFORE
    /// any destructive work. `sync_purge_execute` carries NO re-auth
    /// (ladder R1 F-R1: its production caller is the unattended 13j
    /// janitor, which a re-auth window would freeze).
    @Test func theReauthWindowGuardsTheTruncateDoorAfterTheGate() throws {
        let body = try Self.finalBody(of: "account_data_truncate")
        for line in Self.reauthBlock {
            #expect(body.contains(line), "account_data_truncate must carry the re-auth line: \(line)")
        }
        let gate = try #require(body.range(of: "perform sync_key_gate("))
        let reauth = try #require(body.range(of: "VARIORUM_REAUTH_REQUIRED"))
        let work = try #require(body.range(of: "foreach tbl in array data_tables loop"))
        #expect(gate.lowerBound < reauth.lowerBound && reauth.lowerBound < work.lowerBound,
                "account_data_truncate: gate → re-auth → the destructive work")
        // Every OTHER door — the round doors AND `sync_purge_execute`
        // (F-R1) — carries NO re-auth: a round runs unattended, and so does
        // the janitor's purge.
        for function in ["sync_push", "sync_pull", "sync_horizon", "sync_purge_ledger",
                         "sync_reencrypt", "sync_purge_execute"] {
            #expect(!(try Self.finalBody(of: function)).contains("VARIORUM_REAUTH_REQUIRED"),
                    "\(function) never demands re-auth — it runs unattended")
        }
    }

    /// THE VAULT GRANTS + the PUBLIC-execute footgun sweep (memo §2's
    /// named footgun): the definer role's vault-schema reach is stated,
    /// and EVERY function 12 creates or re-creates carries its explicit
    /// revoke-from-PUBLIC pair — Supabase grants EXECUTE to PUBLIC at
    /// CREATE, so an unswept new function is an open door.
    @Test func theVaultGrantsAndEveryNewFunctionsRevokePairLand() throws {
        let sql = Self.strippingComments(try Self.sqlFile("12_phase13y_tenant_seq.sql"))
        #expect(sql.contains("grant usage on schema vault to variorum_definer;"))
        #expect(sql.contains("grant select on vault.secrets, vault.decrypted_secrets to variorum_definer;"))
        // The 13y window's fix (2026-09-24): the blanket ALL-FUNCTIONS grant
        // refused LIVE — it sweeps in supabase_admin's zero-grant internals
        // (`_crypto_aead_det_encrypt`/`_noncegen`), and Postgres ERRORS a
        // grant whose grantor holds nothing grantable, rolling the whole
        // file back. Named bare-name grants (unique names — version-proof)
        // cover the definer's exact reach: the two write helpers plus the
        // one internal the `decrypted_secrets` view makes its CALLER run.
        #expect(sql.contains("grant execute on function vault.create_secret, vault.update_secret to variorum_definer;"),
                "the vault write helpers granted by bare name (the window's live fix)")
        #expect(sql.contains("grant execute on function vault._crypto_aead_det_decrypt to variorum_definer;"),
                "the decrypt internal the decrypted_secrets view makes its caller execute")
        #expect(!sql.contains("all functions in schema vault"),
                "the blanket vault grant must never return — it refused live at the 13y window")
        // 13y ladder R1 (F-R2): the two new bodies resolve pgcrypto in the
        // `extensions` schema AS the definer — the explicit grant states the
        // dependency (the definer's `authenticated` membership very likely
        // already inherits it; the live sweep/probe verify the end state).
        #expect(sql.contains("grant usage on schema extensions to variorum_definer;"),
                "sync_challenge/sync_key_proof_check resolve extensions.* as the definer — the grant states it")
        for signature in ["sync_push(jsonb, text, text, text)",
                          "sync_pull(bigint, text, text, text, int, text)",
                          "sync_horizon(text, text, text)",
                          "sync_purge_ledger(bigint, text, text, text)",
                          "sync_purge_execute(jsonb, text, text, text)",
                          "account_data_truncate(text, text, text)",
                          "sync_reencrypt(jsonb, text, text, text)",
                          "key_vault_update(jsonb, int, text, text)",
                          "sync_challenge(int)", "key_proof_enroll(text, text, text)",
                          "sync_key_gate(text, text, text, text)",
                          "sync_key_proof_check(text, text, text)",
                          "sync_constant_time_equal(text, text)",
                          "next_tenant_seq(uuid)", "sync_visibility_horizon_ms()"] {
            #expect(sql.contains("revoke execute on function \(signature) from public, anon"),
                    "\(signature) must carry its revoke-from-PUBLIC pair")
            // `next_tenant_seq` stays the deployer's deliberately — UNIT
            // A's `stamp_server_seq` class (SECURITY INVOKER; ownership
            // carries no privilege there, and 11 §14's letter keeps the
            // trigger-class functions with the deployer).
            if signature != "next_tenant_seq(uuid)" {
                #expect(sql.contains("alter function \(signature) owner to variorum_definer;"),
                        "\(signature) must return to the non-bypass definer owner")
            }
        }
    }
}
