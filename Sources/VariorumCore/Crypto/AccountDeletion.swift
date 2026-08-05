import Foundation

/// Phase 14c batch 2 (ledger L5) — account deletion, the brain (THE
/// DESIGN item 4; her Round-5 ruling: IMMEDIATE HARD PURGE behind real
/// friction). The friction has three layers, split honestly by who CAN
/// enforce what:
///
///  - the TYPED CONFIRMATION naming the consequence is the surface's
///    (the view refuses its button until the exact phrase is typed);
///  - the ENCRYPTION PASSPHRASE authorization is THIS brain's: the
///    vault's master must unwrap under it before the purge is called —
///    the server can never verify a passphrase (that is the E2EE
///    design), so the client-side unwrap IS the authorization;
///  - the server's own gate is the authenticated session (09's
///    `account_purge` — auth.uid() scopes everything it deletes).
///
/// **PROVISIONAL (recorded in the batch record): a VAULT-LESS account
/// deletes with the typed confirmation alone.** A signed-in account that
/// never ran encryption setup has no passphrase to authorize with — and
/// refusing deletion outright would deny the account-deletion right
/// (App Store 5.1.1(v) is 14c's own operationalia row) for exactly the
/// accounts with the least to protect (no vault ⇒ nothing synced under
/// the tier's mandatory E2EE). Options weighed: (i) refuse (denies the
/// right); (ii) demand the account PASSWORD instead (a second
/// credential surface for a corner case, and the session already proves
/// it); (iii) the chosen arm — proceed on the session + typed phrase.
///
/// Her pinned copy rule (the CF-6 class) lives at the surface: the door
/// MUST say the local copy survives. It is true by construction — the
/// purge touches only the server.
public struct AccountDeletion: Sendable {
    public let client: KeyVaultClient
    public let lifecycle: any AccountLifecycleProviding

    public init(client: KeyVaultClient, lifecycle: any AccountLifecycleProviding) {
        self.client = client
        self.lifecycle = lifecycle
    }

    /// Authorize, then purge. `passphrase` may be nil/empty ONLY for a
    /// vault-less account (the PROVISIONAL arm above); when a vault
    /// exists it is required and verified by a real master unwrap —
    /// wrong speaks (`wrongPassphrase`), never guesses.
    @discardableResult
    public func run(passphrase: String?) async throws -> AccountPurgeReport {
        if let fetched = try await client.fetchVault() {
            guard let passphrase, !passphrase.isEmpty else {
                throw VaultEnrollmentError.emptyPassphrase
            }
            let key = try PassphraseKDF.deriveKey(
                passphrase: passphrase, descriptor: fetched.format.kdf)
            do {
                _ = try fetched.format.unwrapMaster(withPassphraseKey: key)
            } catch KeyVaultError.unwrapFailed {
                throw VaultEnrollmentError.wrongPassphrase
            }
        }
        // The purge — the account's server side dies in one act. The
        // caller's LOCAL after-acts (custody cleared via the CF-11 forget
        // machinery, then sign-out) are the app's, after this returns.
        return try await lifecycle.purgeAccount()
    }
}
