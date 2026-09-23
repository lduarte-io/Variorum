import Foundation

/// 13y UNIT B (the ruled memo §3) — THE CHALLENGE SIGNER: what turns the
/// device's proof MATERIAL into one PER-REQUEST proof per gated RPC call.
///
/// One signer serves one round (the engine mints one per push()/pull(); the
/// janitor one per sweep; the rotation walk one per walk): it fetches a
/// nonce batch once (`sync_challenge(8)`), consumes one nonce per call, and
/// owns the TWO recovery roads the memo rules — both bounded, so a round
/// can never wedge (memo §7 edge 2):
///
///  - **stale-challenge → fetch-fresh-retry-ONCE**: an unknown, consumed or
///    expired nonce refuses typed server-side; the signer drops its stash,
///    fetches fresh, retries the call once, and SURFACES the second refusal
///    (the §12 grammar — outbox intact, cursor unmoved, the caller's round
///    fails visibly);
///  - **the ENROLL road**: the account holds no Vault secret yet (the
///    typed VARIORUM_KEY_PROOF_ENROLL, raised BEFORE any nonce is
///    consumed) — the signer enrolls ONCE (`key_proof_enroll(kp1, kp2,
///    active_key_id)`; a racing loser's ALREADY_ENROLLED counts as success,
///    its kp2 is the same value — memo §7 edge 1) and retries. A second
///    enroll refusal after a successful enrollment propagates typed —
///    something is genuinely wrong and the round must say so.
///
/// An actor: calls interleave at suspension points, the stash mutates only
/// on the actor, and a nonce is popped BEFORE the body awaits — two
/// interleaved calls can never spend one nonce.
public actor SyncChallengeSigner {
    private let transport: any SyncChallengeTransport
    private let material: KeyProofMaterial
    private let activeKeyID: String
    private let batchSize: Int
    private var stash: [String] = []
    private var enrolled = false

    public init(
        transport: any SyncChallengeTransport,
        material: KeyProofMaterial,
        activeKeyID: String,
        batchSize: Int = 8
    ) {
        self.transport = transport
        self.material = material
        self.activeKeyID = activeKeyID
        self.batchSize = batchSize
    }

    /// One gated call under one fresh proof, with the two recovery roads.
    /// `rpc` is the SERVER function's name — the HMAC binding, so a proof
    /// minted for one door can never be spliced onto another.
    public func call<T: Sendable>(
        rpc: String, _ body: @Sendable (SyncKeyProof) async throws -> T
    ) async throws -> T {
        do {
            return try await body(try await nextProof(rpc: rpc))
        } catch SyncError.keyProofChallengeStale {
            // Fetch-fresh-retry-ONCE (memo §3): the stash may be stale
            // wholesale (a laptop sleeping mid-round outlives the TTL).
            stash = []
            return try await body(try await nextProof(rpc: rpc))
        } catch SyncError.keyProofEnrollRequired {
            guard !enrolled else { throw SyncError.keyProofEnrollRequired }
            enrolled = true
            do {
                try await transport.enrollKeyProof(
                    legacyProof: material.legacyWireToken,
                    macKey: material.macKeyWire,
                    activeKeyID: activeKeyID)
            } catch SyncError.keyProofAlreadyEnrolled {
                // The racing loser proceeds — both devices derive the
                // same kp2 from the same master (memo §7 edge 1).
            }
            // The enroll refusal fired BEFORE any nonce was consumed, but
            // a fresh pop is cheaper than tracking which one survived.
            return try await body(try await nextProof(rpc: rpc))
        }
    }

    private func nextProof(rpc: String) async throws -> SyncKeyProof {
        if stash.isEmpty {
            stash = try await transport.fetchChallenges(batchSize)
        }
        guard !stash.isEmpty else {
            // A server answering zero nonces has nothing to sign with —
            // the stale refusal is the honest class (fetch again next
            // round; nothing is lost).
            throw SyncError.keyProofChallengeStale
        }
        return material.proof(challenge: stash.removeFirst(), rpc: rpc)
    }
}
