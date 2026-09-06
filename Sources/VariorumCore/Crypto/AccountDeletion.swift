import Foundation

/// Phase 14c batch 2 (ledger L5) → pre-13x 3b (decision 16; §5's row):
/// account deletion, the brain. IMMEDIATE HARD PURGE behind real friction —
/// and the friction is the APP's, by the account's own credential: the
/// account password typed and verified by a fresh re-authentication (the
/// password grant, its token pair discarded) plus the typed phrase naming
/// the consequence. **The encryption passphrase is NOT an authorization
/// here** (keystone 3: the account password signs you in and can delete
/// your account; it never touches your keys — and the vault dies WHOLE with
/// the purge, so no key act is being authorized). The server's own gate is
/// the authenticated session (09's `account_purge` — `auth.uid()` scopes
/// everything it deletes). Every account deletes the same way, enrolled or
/// not — the 14c "vault-less account" PROVISIONAL dissolves.
///
/// Her pinned copy rule (the CF-6 class) lives at the surface: the door
/// MUST say the local copy survives. It is true by construction — the
/// purge touches only the server; custody stays on the device (dead
/// server-side), A stays in iCloud.
public struct AccountDeletion: Sendable {
    public let lifecycle: any AccountLifecycleProviding

    public init(lifecycle: any AccountLifecycleProviding) {
        self.lifecycle = lifecycle
    }

    /// The purge — the account's server side dies in one act. The caller's
    /// friction (the re-authentication, the typed phrase) and its LOCAL
    /// after-acts (the marker cleared, sign-out; custody KEPT) are the
    /// app's, around this.
    @discardableResult
    public func run() async throws -> AccountPurgeReport {
        try await lifecycle.purgeAccount()
    }
}
