import Foundation
import VariorumCore

/// pre-13x batch 1b — the `key_vault_update` RPC, the CLOSED PATCH road and
/// the insert trigger, emulated over the raw-JSON `key_vault` doubles the app
/// suites keep (the core suites' `ScriptedVaultServer` is the LINKED, full
/// emulation over a `FakeSyncServer`; this is its minimal twin for flows that
/// never sync — the proof, the NULL-hash arm, the revision CAS, the rotation
/// seq and decision 32's refusal, the WHOLE replace, the receipt).
///
/// TWO BYTE-IDENTICAL COPIES: `VariorumTests/` and `VariorumMobileTests/` —
/// the project's synchronized folders share no test-support folder between
/// the two test targets (recorded in the 1b batch record's machinery notes;
/// the hoist is a project-file change, never a `Sync/` batch's).
enum VaultRPCEmulation {
    struct Served {
        let status: Int
        let body: Data
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var seq: Int64 = 0
    /// 13y UNIT B: the minted, unconsumed nonces (static is safe here —
    /// nonces are 32 random bytes, so worlds can't collide, and each is
    /// consumed by exactly the presentation that spends it).
    nonisolated(unsafe) private static var nonces: Set<String> = []
    /// 13y UNIT B: the Vault-held kp2 secret's twin rides the ROW JSON
    /// under this test-only key — per-WORLD storage (each double keeps one
    /// row), never a static that parallel worlds would cross-contaminate.
    /// The client's `KeyVaultWireRow` decode ignores unknown keys, so the
    /// GET road serves it harmlessly.
    static let secretKey = "_emu_key_proof_mac_secret"  // internal: EmulatedVault's enrollProof writes it

    private static func marker(_ name: String) -> Served {
        Served(status: 400, body: Data(#"{"code":"P0001","message":"\#(name): refused by the mirror"}"#.utf8))
    }

    /// THE CLOSED ROAD (11 section 2): a bare session's direct PATCH is
    /// `permission denied`, whatever it carries.
    static let patchRefused = Served(
        status: 403,
        body: Data(#"{"code":"42501","message":"permission denied for table key_vault"}"#.utf8))

    /// THE INSERT ARM's twin: nil when the POST body carries its
    /// `key_proof_hash`; the trigger's refusal otherwise.
    static func insertRefusal(_ body: Data?) -> Served? {
        guard let body,
              let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any],
              json["key_proof_hash"] is String
        else { return marker("VARIORUM_KEY_PROOF_REQUIRED") }
        return nil
    }

    /// The vault door's RPC routes (named for the update it was born
    /// serving; since 13y UNIT B it serves THREE paths, so the doubles'
    /// unconditional first call routes the challenge dance too): nil when
    /// `request` is none of `rpc/key_vault_update`, `rpc/sync_challenge`,
    /// `rpc/key_proof_enroll`; else the served answer — the update
    /// replacing `row` WHOLE from the payload on success.
    static func serveUpdate(_ request: URLRequest, row: inout Data?) -> Served? {
        // 13y UNIT B — `sync_challenge(1)`: one minted single-use nonce
        // (the vault door mints per call; `n` beyond existence is the
        // real RPC's batch concern, not this twin's).
        if request.url?.path.hasSuffix("/rest/v1/rpc/sync_challenge") == true {
            let nonce = Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
            lock.withLock { _ = nonces.insert(nonce) }
            return Served(status: 200, body: (try? JSONSerialization.data(withJSONObject: [nonce])) ?? Data())
        }
        // 13y UNIT B — `key_proof_enroll(kp1, kp2, active_key_id)`: once,
        // under the OLD hash's authorization; the secret and the
        // post-enroll hash land TOGETHER (12's letter). Latitudes of the
        // minimal twin, recorded: no `active_key_id` fence (the client
        // reads the fence from its own fetch) and the actor's/lock's
        // serialization stands in for FOR UPDATE.
        if request.url?.path.hasSuffix("/rest/v1/rpc/key_proof_enroll") == true {
            guard let body = request.httpBody,
                  let call = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any],
                  let kp1 = call["kp1"] as? String, let kp2 = call["kp2"] as? String
            else { return Served(status: 400, body: Data()) }
            guard let stored = row,
                  var current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any]
            else { return marker("VARIORUM_VAULT_ABSENT") }
            guard current[secretKey] == nil else {
                return marker(SyncServerRefusalMarker.keyProofAlreadyEnrolled)
            }
            guard let presented = KeyProof.hash(ofWireToken: kp1),
                  (current["key_proof_hash"] as? String) == presented,
                  let mac = Data(base64Encoded: kp2)
            else { return marker(SyncServerRefusalMarker.keyProofRequired) }
            current[secretKey] = kp2
            current["key_proof_hash"] = KeyProof.hash(ofToken: mac)
            row = try? JSONSerialization.data(withJSONObject: current)
            return Served(status: 200, body: Data("[]".utf8))
        }
        guard request.url?.path.hasSuffix("/rest/v1/rpc/key_vault_update") == true else { return nil }
        guard request.httpMethod == "POST", let body = request.httpBody,
              let call = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any],
              let payload = call["payload"] as? [String: Any],
              let expected = call["expected_revision"] as? Int,
              let proof = call["key_proof"] as? String,
              let challenge = call["challenge"] as? String  // 13y: defaultless, like 12's
        else { return Served(status: 400, body: Data()) }
        guard let stored = row,
              var current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any]
        else { return marker("VARIORUM_VAULT_ABSENT") }

        // THE PROOF, in 12's RULED order (13y UNIT B — the static-token
        // check and its NULL-hash adopt arm RETIRED with the protocol):
        // the enrolled secret FIRST (absent refuses ENROLL before any
        // nonce is consumed) → the nonce consumed atomically (single-use)
        // → the HMAC over `nonce ‖ ':' ‖ rpc_name` recomputed from it.
        guard let secretWire = current[secretKey] as? String,
              let secret = Data(base64Encoded: secretWire) else {
            return marker(SyncServerRefusalMarker.keyProofEnroll)
        }
        guard lock.withLock({ nonces.remove(challenge) != nil }) else {
            return marker(SyncServerRefusalMarker.keyProofStaleChallenge)
        }
        let expectedProof = KeyProofMaterial(legacyWireToken: "", macKey: secret)
            .proof(challenge: challenge, rpc: "key_vault_update").proof
        guard expectedProof == proof else {
            return marker(SyncServerRefusalMarker.keyProofRequired)
        }
        // The revision PRE-CHECK (12's finding-2 order: right after the
        // proof, so the successor rule below can never mask a stale fetch
        // behind a proof-flavored refusal).
        guard ((current["revision"] as? Int) ?? 1) == expected else {
            return marker("VARIORUM_VAULT_REVISION_CONFLICT")
        }
        // The successor rule: a CHANGED hash lands only beside its
        // sha256-matched `key_proof_mac`, which replaces the secret —
        // hash and secret together or not at all (a rotation's kp2′).
        var enrolledSecret = secretWire
        if let newHash = payload["key_proof_hash"] as? String,
           newHash != (current["key_proof_hash"] as? String) {
            guard let newMac = payload["key_proof_mac"] as? String,
                  let macRaw = Data(base64Encoded: newMac),
                  KeyProof.hash(ofToken: macRaw) == newHash
            else { return marker(SyncServerRefusalMarker.keyProofRequired) }
            enrolledSecret = newMac
        }

        // The rotation seq (decision 31) + one rotation at a time (32): the
        // previous key is its id AND its wrap (two columns); the SAME pair
        // carries through, a DIFFERENT one refuses.
        let incomingPreviousID = payload["corpus_previous_key_id"] as? String
        let incomingPrevious = payload["corpus_previous_wrapped_by_master"] as? String
        guard (incomingPreviousID == nil) == (incomingPrevious == nil) else {
            return Served(status: 400, body: Data(
                #"{"code":"P0001","message":"a previous corpus key travels as its id AND its wrap"}"#.utf8))
        }
        let storedPreviousID = current["corpus_previous_key_id"] as? String
        let storedPrevious = current["corpus_previous_wrapped_by_master"] as? String
        let nextSeq: Int64?
        if incomingPrevious == nil {
            nextSeq = nil
        } else if storedPrevious == nil {
            lock.lock(); seq += 1; nextSeq = seq; lock.unlock()
        } else if incomingPrevious == storedPrevious && incomingPreviousID == storedPreviousID {
            nextSeq = (current["rotation_started_seq"] as? NSNumber)?.int64Value
        } else {
            return marker("VARIORUM_ROTATION_IN_PROGRESS")
        }

        // The CAS inside.
        guard ((current["revision"] as? Int) ?? 1) == expected else {
            return marker("VARIORUM_VAULT_REVISION_CONFLICT")
        }

        // The WHOLE replace: the payload's columns, the server-managed ones
        // from here (an absent nullable key stays absent ⇒ NULL).
        var next = payload
        // 13y: the secret survives the replace (Vault-held on the real
        // server, never a row column); the wire-only `key_proof_mac` is
        // STRIPPED like the real store's (no such mirror column).
        next[secretKey] = enrolledSecret
        next.removeValue(forKey: "key_proof_mac")
        next["user_id"] = current["user_id"]
        next["revision"] = expected + 1
        next["rotation_started_seq"] = nextSeq.map { NSNumber(value: $0) } ?? NSNull()
        next["key_proof_hash"] = (payload["key_proof_hash"] as? String) ?? current["key_proof_hash"]
        // pre-13x 2c (decision 34): the seventh column comes FROM the
        // payload — the writing device's own name (the RPC's
        // `updated_by_device = payload->>'updated_by_device'`); absent ⇒ NULL.
        next["updated_by_device"] = (payload["updated_by_device"] as? String) ?? NSNull()
        next["updated_at"] = ISO8601DateFormatter().string(from: Date())
        guard let encoded = try? JSONSerialization.data(withJSONObject: next) else {
            return Served(status: 400, body: Data())
        }
        row = encoded
        let receipt: [String: Any] = [
            "revision": expected + 1,
            "rotation_started_seq": nextSeq.map { NSNumber(value: $0) } ?? NSNull(),
        ]
        return Served(status: 200, body: try! JSONSerialization.data(withJSONObject: receipt))
    }
}
