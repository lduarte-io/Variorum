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
/// - **The wire form (since 13y UNIT B — SUPERSEDED as the per-request
///   proof):** this v1 token base64-encoded is now the ENROLLMENT
///   authorization only — `key_proof_enroll`'s first argument (`kp1`), the
///   value whose `SHA-256` a pre-enrollment vault row stores. The proof
///   carried on every mutating RPC and both read RPCs is no longer this
///   static token but a PER-REQUEST value bound to a single-use server
///   challenge (`base64(HMAC-SHA256(kp2, nonce ‖ ':' ‖ rpc_name))` — see
///   `KeyProofMaterial` and `SyncKeyProof`), so a captured request body
///   holds a consumed nonce, not a reusable bearer. Never a URL query
///   item, never a header (a gateway log must never capture it).
/// - **What the server keeps:** `SHA-256(token)` as lowercase hex in
///   `key_vault.key_proof_hash`, compared in constant time inside the RPCs
///   (after enrollment the row moves to `SHA-256(kp2)` — `macHash` below).
///   The NULL-hash-accepts-its-first-proof migration arm is RETIRED (12
///   §5f); creation lands a hash by trigger and enrollment refuses a
///   hash-less row. A server compromise or a log capture therefore yields
///   at most the right to MUTATE the mirror, never the right to READ it —
///   the account-password class.
/// - **The rotation road:** a new master M′ gives a new token; the ONE
///   `key_vault_update` that installs the new hash is authorized by the
///   OLD proof; the old proof is refused from then on (pinned).
public enum KeyProof {
    /// The HMAC message — versioned so a future proof shape (`v2`) can
    /// coexist with this one at a lockstep event.
    public static let purpose = "variorum.key-proof.v1"

    /// 13y UNIT B (the ruled memo §3): the v2 purpose — `kp2`, the
    /// PER-REQUEST MAC KEY. Deliberately not the v1 value: every
    /// hypothetical captured log of the v1 era holds a value the new
    /// protocol never accepts. Like kp1, kp2 reveals nothing about M.
    public static let purposeV2 = "variorum.key-proof.v2"

    /// The raw 32-byte token for `master`.
    public static func token(master: SymmetricKey) -> Data {
        Data(HMAC<SHA256>.authenticationCode(for: Data(purpose.utf8), using: master))
    }

    /// The wire form (`key_proof`): the token, base64.
    public static func wireToken(master: SymmetricKey) -> String {
        token(master: master).base64EncodedString()
    }

    /// 13y UNIT B: kp2 — the per-request MAC key, raw 32 bytes.
    public static func macKey(master: SymmetricKey) -> Data {
        Data(HMAC<SHA256>.authenticationCode(for: Data(purposeV2.utf8), using: master))
    }

    /// What the vault's `key_proof_hash` carries AFTER enrollment (and
    /// what a rotation's payload installs beside `key_proof_mac`):
    /// SHA-256(kp2), lowercase hex.
    public static func macHash(master: SymmetricKey) -> String {
        hash(ofToken: macKey(master: master))
    }

    /// What the server stores for a raw token: SHA-256, lowercase hex.
    public static func hash(ofToken token: Data) -> String {
        SHA256.hash(data: token).map { String(format: "%02x", $0) }.joined()
    }

    /// The hash the vault's `key_proof_hash` carries for `master` at
    /// CREATION (the v1, pre-enrollment hash — the enroll road's
    /// authorization comparand). A rotation's vault update installs
    /// `macHash` since 13y UNIT B, and enrollment moves the row there
    /// too; this creation-era form is what both roads authorize AGAINST.
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

    /// VX-307 U1 — does `master` verify against a stored proof hash? The
    /// stored form is the v1 (creation) hash at birth and `macHash` (the
    /// kp2 form) after enrollment or a master change; a holder of M
    /// verifies against either. Client-side and fake-server use only — the
    /// production server verifies challenges against the Vault-held kp2.
    public static func verifies(master: SymmetricKey, storedHash: String) -> Bool {
        hash(master: master) == storedHash || macHash(master: master) == storedHash
    }
}

/// 13y UNIT B (the ruled memo §3; the orchestrator's adjudication approved
/// the pairing shapes) — THE PROOF MATERIAL one device holds: kp1's wire
/// form (the ENROLL road's authorization — the existing hash authorizes
/// the successor, once) beside kp2 (the per-request MAC key). ONE struct,
/// both derived from the SAME master, so both-or-neither holds by
/// construction — a site can never pair one master's kp1 with another's
/// kp2. Never persisted; computed on demand exactly as the wire token
/// always was.
public struct KeyProofMaterial: Equatable, Sendable {
    /// kp1's wire form — `key_proof_enroll`'s first parameter, and the
    /// value whose SHA-256 a pre-enroll vault row stores.
    public let legacyWireToken: String
    /// kp2 — the raw MAC key every per-request proof is computed under,
    /// and (base64) the secret enrollment lands in Supabase Vault.
    public let macKey: Data

    public init(master: SymmetricKey) {
        self.legacyWireToken = KeyProof.wireToken(master: master)
        self.macKey = KeyProof.macKey(master: master)
    }

    /// The crafted-world form (tests; a deliberately mismatched pair is a
    /// test's own statement).
    public init(legacyWireToken: String, macKey: Data) {
        self.legacyWireToken = legacyWireToken
        self.macKey = macKey
    }

    /// kp2's wire form — `key_proof_enroll`'s second parameter and the
    /// rotation payload's `key_proof_mac`.
    public var macKeyWire: String { macKey.base64EncodedString() }

    /// THE PER-REQUEST PROOF (memo §3): `HMAC-SHA256(kp2, nonce ‖ ':' ‖
    /// rpc_name)`, base64, paired with the nonce it consumed. Binding the
    /// RPC name stops cross-RPC splicing of an unconsumed pair; the body
    /// is deliberately NOT bound (TLS carries transit integrity — the
    /// memo's recorded reason). A malformed challenge simply produces a
    /// proof the server refuses as stale — never a client crash.
    public func proof(challenge: String, rpc: String) -> SyncKeyProof {
        var input = Data(base64Encoded: challenge) ?? Data()
        input.append(Data(":\(rpc)".utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: input, using: SymmetricKey(data: macKey))
        return SyncKeyProof(challenge: challenge, proof: Data(mac).base64EncodedString())
    }
}
