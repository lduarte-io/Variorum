import CryptoKit
import Foundation

/// THE KEY PROOF (pre-13x postures design §3.10, decision 12): the one
/// value a device presents to prove it holds the account's master key M —
/// without which a session alone can neither write the vault nor touch
/// the mirror. The server cannot verify a passphrase (that is E2EE), so
/// the proof is what stands between a bare session and the corpus.
///
/// - **The token:** `HMAC-SHA256(M, "variorum.key-proof.v1")` — 32 bytes,
///   computed on demand by every device that holds M (the key provider's
///   `currentKeys()`), never stored anywhere client-side.
/// - **The wire form:** the token base64-encoded, the `key_proof` BODY
///   parameter of every mutating RPC and of the two read RPCs — never a URL
///   query item, never a header (a gateway log must never capture it).
/// - **What the server keeps:** `SHA-256(token)` as lowercase hex in
///   `key_vault.key_proof_hash`, compared in constant time inside the RPCs;
///   a vault whose hash is NULL accepts its FIRST proof (the author's
///   existing vault — the migration arm). A server compromise or a log
///   capture therefore yields at most the right to MUTATE the mirror,
///   never the right to READ it — the account-password class.
/// - **The rotation road:** a new master M′ gives a new token; the ONE
///   `key_vault_update` that installs the new hash is authorized by the
///   OLD proof; the old proof is refused from then on (pinned).
public enum KeyProof {
    /// The HMAC message — versioned so a future proof shape (`v2`) can
    /// coexist with this one at a lockstep event.
    public static let purpose = "variorum.key-proof.v1"

    /// The raw 32-byte token for `master`.
    public static func token(master: SymmetricKey) -> Data {
        Data(HMAC<SHA256>.authenticationCode(for: Data(purpose.utf8), using: master))
    }

    /// The wire form (`key_proof`): the token, base64.
    public static func wireToken(master: SymmetricKey) -> String {
        token(master: master).base64EncodedString()
    }

    /// What the server stores for a raw token: SHA-256, lowercase hex.
    public static func hash(ofToken token: Data) -> String {
        SHA256.hash(data: token).map { String(format: "%02x", $0) }.joined()
    }

    /// The hash the vault's `key_proof_hash` carries for `master` — what
    /// vault CREATION lands, and what a rotation's vault update installs.
    public static func hash(master: SymmetricKey) -> String {
        hash(ofToken: token(master: master))
    }

    /// The server's side of the compare, given the wire form: nil when the
    /// presented value is not base64 (the RPC's malformed-token arm). Used
    /// by the fake server; production compares inside Postgres.
    public static func hash(ofWireToken wire: String) -> String? {
        guard let raw = Data(base64Encoded: wire) else { return nil }
        return hash(ofToken: raw)
    }
}
