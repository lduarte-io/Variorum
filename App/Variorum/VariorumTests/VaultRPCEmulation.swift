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

    /// The RPC route: nil when `request` is not `rpc/key_vault_update`; else
    /// the served answer, replacing `row` WHOLE from the payload on success.
    static func serveUpdate(_ request: URLRequest, row: inout Data?) -> Served? {
        guard request.url?.path.hasSuffix("/rest/v1/rpc/key_vault_update") == true else { return nil }
        guard request.httpMethod == "POST", let body = request.httpBody,
              let call = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any],
              let payload = call["payload"] as? [String: Any],
              let expected = call["expected_revision"] as? Int,
              let proof = call["key_proof"] as? String
        else { return Served(status: 400, body: Data()) }
        guard let stored = row,
              var current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any]
        else { return marker("VARIORUM_VAULT_ABSENT") }

        // The proof — the NULL-hash arm lands the first.
        guard let presented = KeyProof.hash(ofWireToken: proof) else {
            return marker("VARIORUM_KEY_PROOF_REQUIRED")
        }
        if let storedHash = current["key_proof_hash"] as? String {
            guard storedHash == presented else { return marker("VARIORUM_KEY_PROOF_REQUIRED") }
        } else {
            current["key_proof_hash"] = presented
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
