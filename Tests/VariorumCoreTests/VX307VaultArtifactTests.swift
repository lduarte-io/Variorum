import Foundation
import Testing

@testable import VariorumCore

/// VX-307 U1 — THE HELD LOCKSTEP ARTIFACT's shape pins
/// (`Server/supabase/17_phase_vx307_vault.sql`, marker 13 → 14).
///
/// The artifact is WRITTEN at VX-307 and DEPLOYED only in the release window
/// that carries VX-329's switch (her ruling, the plan §1), so it is
/// deliberately NOT in `AuthRLSDDLTests.lockstepFiles` — the drift pin there
/// rightly binds the DEPLOYED marker (16's, 13) to the client's
/// `SyncSchema.lockstepVersion`. VX-329's release registers 17 in that array
/// AND bumps the client to 14 in the same commit; until then, these pins
/// keep the held artifact's shape from drifting.
struct VX307VaultArtifactTests {
    static func artifact() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Server/supabase/17_phase_vx307_vault.sql")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// Comment lines removed, so pins read executable text only.
    static func stripped(_ sql: String) -> String {
        sql.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("--") }
            .joined(separator: "\n")
    }

    static func body(of functionName: String, in sql: String) -> String? {
        let marker = "create or replace function \(functionName)"
        guard let start = sql.range(of: marker, options: .backwards),
              let end = sql.range(of: "$$;", range: start.upperBound..<sql.endIndex)
        else { return nil }
        return String(sql[start.lowerBound..<end.upperBound])
    }

    @Test func theArtifactIsGuardedOneTransactionAndMarkerLast() throws {
        let sql = Self.stripped(try Self.artifact())
        #expect(sql.contains("variorum.allow_17_rerun"), "the re-run guard's override")
        #expect(sql.contains("VARIORUM_17_ALREADY_DEPLOYED"))
        #expect(sql.contains("VARIORUM_17_PREREQUISITE_MISSING"))
        #expect(sql.contains("VARIORUM_17_ROTATION_IN_FLIGHT"),
                "fail-loud on a standing rotation — nulling it would strand the re-encryption")
        #expect(sql.contains("begin;") && sql.contains("commit;"), "one transaction")
        // The marker insert is the LAST statement inside the transaction.
        guard let marker = sql.range(of: "insert into sync_meta (key, value) values ('lockstep_version', '14')"),
              let commit = sql.range(of: "commit;", options: .backwards)
        else {
            Issue.record("the marker insert and the commit must both exist")
            return
        }
        #expect(marker.lowerBound < commit.lowerBound)
        let between = sql[marker.upperBound..<commit.lowerBound]
        #expect(!between.contains("alter table") && !between.contains("create or replace"),
                "nothing executes after the marker")
    }

    @Test func theTwoColumnsArriveAndTheBridgeRelaxes() throws {
        let sql = Self.stripped(try Self.artifact())
        #expect(sql.contains("alter table key_vault add column mode text"))
        #expect(sql.contains("alter table key_vault add column earlier_row_keys jsonb"))
        #expect(sql.contains("alter table key_vault alter column journal_bridge_key_id drop not null"))
        #expect(sql.contains("alter table key_vault alter column journal_bridge_key_wrapped_by_master drop not null"))
    }

    @Test func theBackfillRestatesTodaysPostureSemanticAndClearsTheRotation() throws {
        let sql = Self.stripped(try Self.artifact())
        // Today's deployed encoding (PostureSwitch: the Apple-held wrap
        // absent ⇒ Castle) — the backfill is that semantic, never a guess.
        #expect(sql.contains(
            "set mode = case when master_wrapped_by_apple_held is not null then 'standard' else 'castle' end"))
        #expect(sql.contains("corpus_previous_key_id = null"))
        #expect(sql.contains("corpus_previous_wrapped_by_master = null"))
        #expect(sql.contains("rotation_started_seq = null"))
        #expect(sql.contains("where mode is null"), "the backfill is idempotent on a re-run override")
    }

    @Test func theRotationWalkIsDropped() throws {
        let sql = Self.stripped(try Self.artifact())
        #expect(sql.contains("drop function if exists sync_reencrypt(jsonb, text, text, text);"))
        #expect(Self.body(of: "sync_reencrypt", in: sql) == nil, "never re-created")
    }

    @Test func theUpdateBodyKeepsTheProofAndSheddersTheRotation() throws {
        let sql = Self.stripped(try Self.artifact())
        guard let body = Self.body(of: "key_vault_update", in: sql) else {
            Issue.record("17 must redefine key_vault_update")
            return
        }
        // KEPT, byte-faithful intents from 12's canonical body:
        #expect(body.contains("security definer"))
        #expect(body.contains("for update"), "the per-account serialization lock")
        #expect(body.contains("sync_key_proof_check(key_proof, challenge, 'key_vault_update')"),
                "the 13y challenge-verified proof, unchanged")
        #expect(body.contains("VARIORUM_VAULT_ABSENT"))
        #expect(body.contains("VARIORUM_VAULT_REVISION_CONFLICT"), "the CAS pre-check")
        #expect(body.contains("and revision = expected_revision"), "the UPDATE's own filter as the belt")
        #expect(body.contains("VARIORUM_KEY_PROOF_REQUIRED"), "hash and secret land together")
        #expect(body.contains("vault.create_secret") && body.contains("vault.update_secret"),
                "kp2′ lands in Supabase Vault in the same transaction")
        // NEW:
        #expect(body.contains("VARIORUM_PRE_VX307_PAYLOAD"), "a pre-VX307 payload refuses loudly")
        #expect(body.contains("mode                                 = payload->>'mode'")
                || body.contains("mode = payload->>'mode'"))
        #expect(body.contains("earlier_row_keys"))
        // GONE — no rotation arm survives:
        #expect(!body.contains("rotation_started_seq"))
        #expect(!body.contains("next_tenant_seq"))
        #expect(!body.contains("VARIORUM_ROTATION"))
        #expect(!body.contains("corpus_previous_key_id"))
        // The retired/left columns are not written by the new body:
        #expect(!body.contains("journal_bridge_key_id "))
        #expect(!body.contains("master_wrapped_by_apple_held "))
        // The posture is re-asserted beside the function:
        #expect(sql.contains("alter function key_vault_update(jsonb, int, text, text) owner to variorum_definer;"))
        #expect(sql.contains("grant execute on function key_vault_update(jsonb, int, text, text) to authenticated;"))
    }

    /// The held marker is exactly the deployed chain's successor; the client
    /// stays on the DEPLOYED marker until VX-329's release bumps it with the
    /// registration (the drift pin in `AuthRLSDDLTests` then takes over).
    @Test func theHeldMarkerIsTheClientVersionsSuccessorWhileHeld() throws {
        let sql = Self.stripped(try Self.artifact())
        #expect(sql.contains("('lockstep_version', '14')"))
        #expect(SyncSchema.lockstepVersion == 13 || SyncSchema.lockstepVersion == 14,
                "13 while 17 is held; 14 the moment VX-329 deploys and registers it")
    }
}
