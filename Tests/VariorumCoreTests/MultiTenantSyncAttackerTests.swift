import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13x batch 4b — the two-user suite's WIRE arms (the postures design §14.29; §12 "Her attacker scenario"; ledger
/// 19): `sync_reencrypt` under an old key proof refuses at the gate (arm 10) and no ownership-change instruction exists
/// on the wire (arm 9).
///
/// VX-329 U1 (VX-380): her attacker scenario's NINE ARMS — a Standard account entering Castle through today's posture
/// switch (`CorpusRotation`'s walk, `StoreEncryptionMigration.rekey`, today's format-2 key file) — were DELETED WITH
/// THEIR SUBJECT: that switch is today's road and left with it (the plan's §6 CUT). The scenario's red under
/// `swift test -c release` (VX-380: the scripted 256 KiB Argon2 descriptor below the production floor) died with it.
/// The protection road's own attacker promise is pinned in `Protection/Scenario/Promises.swift` (THE ATTACKER over
/// every device × posture). The two arms below never touched the deleted switch — the fake server's gate and the
/// deployed function set are their subjects, and both survive — so they stay, byte-untouched.
extension MultiTenantSyncTests {

    // MARK: - (10) `sync_reencrypt` under an OLD key proof (RUN B B4, ledger row 16)

    /// THE TENTH ARM — S1's Q2 suite-completeness NIT (the stress pass's
    /// one routing into the suites): `sync_reencrypt` was the ONE data RPC
    /// the attacker scenario never fired. GREEN-BY-DESIGN — a coverage pin
    /// over the gate's standing order (`sync_key_gate`: fence → proof), not
    /// a defect claim; the nine arms above are byte-untouched. The shape is
    /// the stale-writer-after-re-key window — exactly where the walk's RPC
    /// lives: the vault has moved to a new corpus key id and the NEW
    /// master's proof hash; a writer still holding the OLD material fires
    /// the walk's own door.
    @Test func theTenthArmSyncReencryptUnderAnOldProofRefusesAtTheGate() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "hers", profile: .blog)
            return try ops.newBlock(in: post.id, text: "Sealed words.", at: .end).variant.id
        }
        _ = try await productionRound(a)
        let storedBefore = try #require(await server.currentRow(table: "variant", rowID: variantID))
        let seqBefore = await server.currentSeq(table: "variant", rowID: variantID)
        let headBefore = await server.headSeq
        #expect(seqBefore != nil, "the row is on the mirror — the pin isn't vacuous")

        // The re-key's server half (the CF-8 order — the vault FIRST): a
        // new corpus key id + the NEW master's proof secret (13y UNIT B:
        // the rotated account is ENROLLED under kp2′ — the hash at its
        // post-enroll value, the Vault-held secret beside it).
        let rotatedMaster = SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0xE0) }))
        let rotatedMaterial = KeyProofMaterial(master: rotatedMaster)
        let rotatedKeyID = "test-corpus-key-ARM10-000000001"
        await server.setVaultRow(
            corpusKeyID: rotatedKeyID, keyProofHash: KeyProof.macHash(master: rotatedMaster),
            keyProofMacSecret: rotatedMaterial.macKeyWire)

        // (i) The OLD key id with the old proof: the FENCE refuses first —
        // the gate's order, the SQL's own.
        await #expect(throws: SyncError.encryptionKeysReplaced,
                      "ARM 10: the fence first — sync_reencrypt with the old key id") {
            _ = try await server.reencrypt(
                [storedBefore], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_reencrypt"))
        }
        // (ii) The CURRENT id (readable from the vault by any session) with
        // the OLD proof — the row's letter: the PROOF refuses.
        await #expect(throws: SyncError.keyProofRefused,
                      "ARM 10: sync_reencrypt under an old proof — the proof refuses") {
            _ = try await server.reencrypt(
                [storedBefore], activeKeyID: rotatedKeyID, keyProof: server.mintProof(rpc: "sync_reencrypt"))
        }
        // Nothing replaced: bytes, the per-row seq and the head all unmoved.
        #expect(await server.currentRow(table: "variant", rowID: variantID) == storedBefore)
        #expect(await server.currentSeq(table: "variant", rowID: variantID) == seqBefore)
        #expect(await server.headSeq == headBefore)

        // The NON-VACUITY control: the CURRENT proof passes the same gate
        // on the same call — a stale-VERSION row answers `.skipped`, so the
        // refusals above are the gate's, not some always-throwing door, and
        // the control itself moves nothing.
        var staleVersion = storedBefore
        staleVersion.syncVersion += 7
        let outcomes = try await server.reencrypt(
            [staleVersion], activeKeyID: rotatedKeyID,
            keyProof: server.mintProof(rpc: "sync_reencrypt", material: rotatedMaterial))
        #expect(outcomes == [.skipped(currentVersion: storedBefore.syncVersion)],
                "the gate passes the current proof; the version guard alone answers")
        #expect(await server.currentRow(table: "variant", rowID: variantID) == storedBefore,
                "…and the control moved nothing either")

        // The DEPLOYED function's own wiring (the arm-9 text-pin
        // precedent): `sync_reencrypt`'s body routes through the ONE gate.
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        // 13y UNIT B: the DEPLOYED body is 12's (the challenge signature)
        // — the pin follows the deployed truth, as the precedent says.
        let sql12 = try String(
            contentsOf: root.appendingPathComponent("Server/supabase/12_phase13y_tenant_seq.sql"),
            encoding: .utf8)
        let reencryptBody = try #require(
            sql12.components(separatedBy: "create or replace function sync_reencrypt")
                .dropFirst().first?
                .components(separatedBy: "create or replace function ").first)
        #expect(reencryptBody.contains("perform sync_key_gate(active_key_id, key_proof, challenge, 'sync_reencrypt');"),
                "the deployed sync_reencrypt routes through the one gate, naming itself")
    }

    // MARK: - (9) No ownership-change instruction on the wire

    /// ARM 9 — NO OWNERSHIP-CHANGE INSTRUCTION EXISTS ON THE WIRE: the
    /// client's RPC request set, the transport protocols' requirements and
    /// the deployed function set are asserted BY NAME — none moves rows
    /// between owners, none takes an owner parameter (the push/pull stamp
    /// `auth.uid()`); the only road between partitions is arm 8's LOCAL
    /// re-stamp + a push under the other account's own gate. A text pin over
    /// the sources (the `AuthRLSDDLTests` precedent), so a road that grew
    /// back would announce itself by name.
    @Test func noOwnershipChangeInstructionExistsOnTheWire() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        func source(_ relative: String) throws -> String {
            try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
        }
        func names(_ pattern: String, in text: String) throws -> Set<String> {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(text.startIndex..., in: text)
            return Set(regex.matches(in: text, range: range).compactMap { match in
                Range(match.range(at: 1), in: text).map { String(text[$0]) }
            })
        }

        // THE CLIENT's request set, exactly.
        let transport = try source("Sources/VariorumCore/Sync/SupabaseTransport.swift")
        let vaultClient = try source("Sources/VariorumCore/Crypto/KeyVaultClient.swift")
        let lifecycle = try source("Sources/VariorumCore/Auth/AccountLifecycle.swift")
        // `rpc("name", body:)` for the bodied calls; `send("name", payload:)`
        // for the schema-version probe — both are the transport's one road.
        var clientRPCs = try names(#"(?:rpc|send)\(\s*"([a-z_]+)""#, in: transport)
        clientRPCs.formUnion(try names(#"rest/v1/rpc/([a-z_]+)"#, in: vaultClient + lifecycle + transport))
        // 13y (the R-13y-4 fork's Shape 1): `sync_visibility_horizon_ms`
        // joined the wire — the served A5 horizon the rotation walk's
        // production wait derives from. Zero parameters, so the
        // forbidden-word scan below covers it like every other road.
        // 13y UNIT B: `sync_challenge` (the nonce mint — one int) and
        // `key_proof_enroll` (kp1/kp2/active_key_id) joined — the
        // challenge protocol's two roads; both scanned below like every
        // other, and the allowlist extends by EXACTLY them (UNIT A's
        // precedent: never a relaxation of the blanket scans).
        #expect(clientRPCs == [
            "sync_push", "sync_pull", "sync_schema_version",
            "sync_horizon", "sync_purge_ledger", "sync_purge_execute", "sync_reencrypt",
            "key_vault_update", "account_data_truncate", "account_purge",
            "sync_visibility_horizon_ms",
            "sync_challenge", "key_proof_enroll",
        ], "the client's RPC set, by name — \(clientRPCs.sorted())")

        // THE TRANSPORT PROTOCOLS' requirements, exactly.
        let protocols = try source("Sources/VariorumCore/Sync/SyncTransport.swift")
        #expect(try names(#"\n\s*func ([a-zA-Z]+)\("#, in: protocols)
                == ["push", "pull", "schemaVersion", "syncHorizon", "purgeLedger", "executePurge", "reencrypt",
                    "visibilityHorizonMillis",
                    // 13y UNIT B: the challenge surface's two requirements.
                    "fetchChallenges", "enrollKeyProof"])
        let lifecycleProtocol = try #require(lifecycle.components(separatedBy: "public protocol AccountLifecycleProviding").dropFirst().first?
            .components(separatedBy: "\n}").first)
        #expect(try names(#"func ([a-zA-Z]+)\("#, in: lifecycleProtocol)
                == ["truncateAccountData", "purgeAccount", "fetchEntitlements"])

        // THE DEPLOYED function set: every client name exists server-side;
        // no function's NAME or PARAMETER LIST names an owner, a transfer,
        // a move, an adoption or a hand-over — the owner is `auth.uid()`.
        let sqlDir = root.appendingPathComponent("Server/supabase")
        let sqlFiles = try FileManager.default.contentsOfDirectory(at: sqlDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sql" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        #expect(sqlFiles.count >= 11, "the numbered chain — the pin isn't vacuous")
        var deployed: [String: String] = [:]  // name → the LAST parameter list deployed
        let signature = try NSRegularExpression(pattern: #"create or replace function ([a-z_]+)\(([^)]*)\)"#)
        for file in sqlFiles {
            let text = try String(contentsOf: file, encoding: .utf8)
            for match in signature.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let name = Range(match.range(at: 1), in: text).map({ String(text[$0]) }),
                      let params = Range(match.range(at: 2), in: text).map({ String(text[$0]) }) else { continue }
                deployed[name] = params
            }
        }
        for rpc in clientRPCs {
            #expect(deployed[rpc] != nil, "\(rpc) is a deployed function")
        }
        let forbidden = ["owner", "transfer", "reassign", "move", "adopt", "handover", "hand_over"]
        for (name, params) in deployed {
            for word in forbidden {
                #expect(!name.contains(word), "no deployed function is named for \(word): \(name)")
                #expect(!params.lowercased().contains(word), "no deployed function takes a \(word) parameter: \(name)(\(params))")
            }
        }
        // The row's owner is the CALLER's — stamped from `auth.uid()` in the
        // push and re-encrypt bodies, compared, never received.
        let sql11 = try source("Server/supabase/11_pre13x_postures.sql")
        #expect(sql11.contains("is distinct from") && sql11.contains("auth.uid()"),
                "the push guard reads the caller's uid — a payload never names another owner")
    }
}
