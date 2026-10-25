import CryptoKit
import Foundation

// VX-529 unit 2 — P-VX529-4's HEAL, WIRED (PROVISIONAL; `notes/plans/fixes/vx-529-pair-catchup.md`, the E6 sweep and scope 7):
// a SYNCED library with NO passphrase lock of its own (joined by the twelve words — edge E6 — or R-529-5's words arm's
// window) LANDS the account's current passphrase as its lock at a moment that passphrase was TYPED and verified against
// the account's vault — the lobby's vault road (R-529-1: the act has the secret in hand). Never the check door (its ruled
// contract: "checking changes nothing"); the synced key doors land it inside their own plans (`KeyDoorProgram`, New words).
//
// THE SHAPE: re-locks, never re-keys (rule 6) — `KeyFile.landingTheAccountsPassphraseLock` (unit 1's primitive: lands where
// MISSING only, the master verified to reach this key first — rule 22) through the existing key-file road, then what this
// Mac remembers follows the file (rule 1's mirror). ONE key-file write, so a crash leaves the old file or the new one (rule
// 20: "a crash at any point leaves either the old state or the new one"); a crash between the file and the mirror leaves
// the mirror one lock behind, which the next open's `refreshMemory` repair brings to the live file — the shape of the
// `landAppleWrap` repair, which adds a lock to the live key file the same unplanned way. No key, no vault, no custody item,
// no sync key, no record field changes (the record's passphrase fact is already true for a synced library — rule 7).

extension ProtectionExecutor {
    /// **The heal** — `passphrase`: typed (never stored), verified here against the account's vault under the VAULT's own
    /// descriptor (the floor first). `vault`: the account's vault as the caller read it this moment (the lobby's one
    /// bounded read — nothing is trusted from it but what verifies: the typed passphrase must open ITS master, and that
    /// master must open this library's key file's master lock); nil: this session's read, else one read now.
    /// Returns true when the lock landed; false when there was nothing to land (a lock already stands — the account's, or a
    /// stale one owing the catch-up: never replaced here). Refuses, writing nothing: a library that doesn't sync, an act in
    /// flight (its plan's to finish), no live key file of the current key, another account's vault, the account moved
    /// (posture or sync key — the follow first), a passphrase the vault refuses (`refusalForAPassphraseTheVaultRefuses`'
    /// split), a master that doesn't reach this key.
    @discardableResult
    public func landTheAccountsPassphraseLock(
        _ library: inout UnlockedLibrary, passphrase text: String, vault given: VaultSnapshot? = nil
    ) async throws -> Bool {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        if let inFlight = library.section.actInFlight { throw ExecutorRefusal.actInFlight(inFlight.act) }
        guard let file = library.keyFile, file.fingerprint == library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        guard file.passphrase == nil else { return false }
        let snapshot: VaultSnapshot
        if let given {
            snapshot = given
        } else {
            try requireSignedIn(as: account)
            var read = freshVault(for: account)
            if read == nil { read = try await readVault(accountID: account) }
            guard let read else { throw ExecutorRefusal.needsFreshVault }
            snapshot = read
        }
        guard snapshot.accountID == account else { throw ExecutorRefusal.accountMoved }
        if snapshot.mode != record.mode || libraryBehind(library, vault: snapshot) { throw ExecutorRefusal.accountMoved }
        try snapshot.vault.kdf.validateFloor(configuration.floor)
        let passphrase = try PassphraseKey.derive(text, kdf: snapshot.vault.kdf)
        guard let master = VaultModel.master(of: snapshot.vault, passphrase: passphrase, words: nil) else {
            throw refusalForAPassphraseTheVaultRefuses(text, library, vault: snapshot)
        }
        let landed: KeyFile
        do {
            landed = try file.landingTheAccountsPassphraseLock(passphrase, key: library.key, master: master)
        } catch is KeyFileError {
            throw ExecutorRefusal.accountMoved
        }
        guard landed != file else { return false }
        try writeLiveKeyFile(landed, &library)
        try writeMemory(&library)
        log("heal: the account's passphrase landed as this library's own lock (E6 — P-VX529-4); the key unchanged "
            + "(\(Self.fp8(library.fingerprint)))")
        return true
    }
}
