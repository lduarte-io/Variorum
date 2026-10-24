import CryptoKit
import Foundation

// VX-529 — THE RE-LOCK TO THE ACCOUNT'S PAIR (`notes/plans/fixes/vx-529-pair-catchup.md`, design §2): the account's
// passphrase or twelve words were re-made on another device (a key door there re-wrapped only the vault's master — the
// master, the sync keys and this library's key are unchanged), and this library's key file still carries the pair as it
// last knew it. The catch-up RE-LOCKS the current key and never re-keys it (rule 6's verb; rule 7: "a device holds one
// pair of secrets at a time"): the passphrase lock re-made under the account's current passphrase on the VAULT's
// descriptor (fact 1's invariant restored), the master's twelve-words copy refreshed byte for byte from the vault
// (§3.5a), a stale own words lock dropped. The key, its fingerprint and epoch, the history (rule 4), the master lock's own
// bytes and the Apple wrap are untouched — so every older backup keeps opening with the secrets of its day (rules 4–5),
// and the current secrets reach every older key through the history as before. A pure value: the act writes it, through
// the existing key-file road (rule 1's mirror follows).

/// What the re-lock does to the key file's passphrase lock (R-529-5: the catch-up accepts EITHER of the account's
/// current secrets).
public enum PassphraseLockChange: Sendable {
    /// The passphrase did not move: the lock stays as it is.
    case keep
    /// The account's current passphrase, derived under the VAULT's descriptor and verified against the vault by the
    /// caller, re-made as this file's passphrase lock (set where there was one, landed where there was none).
    case remake(PassphraseKey)
    /// The passphrase moved and the account's current WORDS were typed instead: the stale lock DROPS — the old
    /// passphrase stops opening this library at once; the lock is re-made the next time a passphrase is typed here
    /// (E6's window — P-VX529-4's heal, `landingTheAccountsPassphraseLock`).
    case drop
}

extension KeyFile {
    /// **This file re-locked to the account's pair.**
    ///   - `key`: the library's current key (this file's).
    ///   - `master`: the account's master, in hand — VERIFIED here to reach this file's key through its master lock
    ///     before anything is replaced (rule 22: "a key is deleted only after its replacement has been verified" — the
    ///     words' road after a drop IS the master lock, through the refreshed copy).
    ///   - `accountsWordsCopy`: the recovery wrap of the vault whose master `master` is (`AccountVault.isMaster` — the
    ///     caller's check), copied in byte for byte.
    ///   - `passphraseLock`: keep, re-make under the account's current passphrase, or drop (R-529-5's words arm).
    ///   - `dropsOwnWordsLock`: the account's words moved, so this file's own words lock holds the old words — dropped.
    /// Refuses (`KeyFileError`, nothing returned) a key that is not this file's, a master that does not open its master
    /// lock (or a file with none), and a result the twelve words would not open (rule 2).
    public func relockedToTheAccountsPair(
        key: StoreKey, master: SymmetricKey, accountsWordsCopy: Data, passphraseLock: PassphraseLockChange,
        dropsOwnWordsLock: Bool
    ) throws -> KeyFile {
        guard KeyFingerprint.of(key) == fingerprint else { throw KeyFileError.keyIsNotThisFilesKey }
        // Rule 22, first: the account's master opens THIS key through the master lock (`open(master:)` verifies the
        // fingerprint it reaches) — the road the words keep once the copy is the account's.
        _ = try open(master: master)
        var next = self
        switch passphraseLock {
        case .keep: break
        case .remake(let passphrase): next = try next.settingPassphrase(passphrase, for: key)
        case .drop: next = next.droppingPassphrase()
        }
        next = next.refreshingMasterWordsCopy(accountsWordsCopy)
        if dropsOwnWordsLock { next = next.droppingWords() }
        guard next.opensWithTheWords else { throw KeyFileError.noWordsLock }
        return next
    }
}
