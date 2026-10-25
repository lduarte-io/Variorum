import CryptoKit
import Foundation

// VX-529 unit 2 — THE LOBBY'S VAULT ROAD, the decision (`notes/plans/fixes/vx-529-pair-catchup.md`, scope 3; R-529-1, her
// pick: "Open through the vault"). A PURE reading: no leaf, no write — the app's open road reads the vault (one bounded
// read, signed in, only after every local road refused the typed passphrase) and hands it here with the key files this Mac
// holds for the slot; the answer is the key to try (the ordinary open verifies it against the slot, then the catch-up lands
// with the typed secret in hand) or what the lobby honestly says.
//
// THE ROAD (design fact 3): the typed passphrase, derived under the VAULT's own descriptor (its floor first — no cheap KDF,
// ever), opens the vault's master; that master opens a held key file's MASTER lock (a synced key file carries the current
// key under the account's master — `KeyFile.open(master:)`, which verifies the fingerprint it reaches). It stores nothing
// and changes no shape: the master lock the file already holds is the road.
//
// WHAT IT SAYS WHEN IT DOESN'T OPEN — only what the read proves. Before unlock this Mac cannot read which account the
// library is bound to (the record is inside it); "this library is the account's" is proven without a secret only by the
// live key file's master's twelve-words copy BEING the vault's recovery wrap, byte for byte (§3.5a — the copy is the
// vault's bytes; a different account's, or a later Castle master's, never matches). With that proof: a passphrase lock
// under another descriptor than the vault's ⇒ the account's passphrase was changed elsewhere (VX-113's comparison) — named;
// no passphrase lock at all (edge E6) ⇒ the typed passphrase is not the account's (the only passphrase that could open it
// here). Without the proof — another account signed in, both halves moved, an unsynced file — nothing beyond today's
// refusal (never a named change for a vault that may not be this library's).

/// What the lobby's vault road found for one typed passphrase.
public enum VaultRoadAnswer: Equatable, Sendable {
    /// The typed passphrase opens the account's vault and its master opens a held key file's master lock: the key to try
    /// (unverified against the slot — the ordinary open does that), and the passphrase as the vault derives it (never
    /// derived a second time downstream).
    case opens(StoreKey, derived: PassphraseKey)
    /// This library is the account's (proven), the account's passphrase was changed elsewhere, and the typed one opens
    /// neither the library nor the account: the change named — the vault's last writer and its day.
    case passphraseChangedElsewhere(device: String?, day: Date?)
    /// This library is the account's (proven) and holds no passphrase lock of its own (edge E6): the typed passphrase is
    /// not the account's.
    case notTheAccountsPassphrase
    /// Nothing the read proves beyond today's refusal.
    case nothingToSay

    /// Two answers are the same answer (a derived passphrase by its descriptor — its bytes are never compared or shown).
    public static func == (lhs: VaultRoadAnswer, rhs: VaultRoadAnswer) -> Bool {
        switch (lhs, rhs) {
        case let (.opens(a, derived: p), .opens(b, derived: q)): return a == b && p.kdf == q.kdf
        case let (.passphraseChangedElsewhere(d1, t1), .passphraseChangedElsewhere(d2, t2)): return d1 == d2 && t1 == t2
        case (.notTheAccountsPassphrase, .notTheAccountsPassphrase), (.nothingToSay, .nothingToSay): return true
        default: return false
        }
    }
}

public enum VaultRoad {
    /// The answer for `typed` against `vault` over `files` (every key file this Mac holds for the slot, the live one among
    /// them — tried in order) and `live` (the key file beside the library, as read before unlock).
    public static func answer(
        _ typed: String, vault: VaultSnapshot, files: [KeyFile], live: KeyFile?, floor: PassphraseKDF.Floor
    ) -> VaultRoadAnswer {
        guard !typed.isEmpty, (try? vault.vault.kdf.validateFloor(floor)) != nil,
              let derived = try? PassphraseKey.derive(typed, kdf: vault.vault.kdf) else { return .nothingToSay }
        if let master = VaultModel.master(of: vault.vault, passphrase: derived, words: nil) {
            for file in files {
                if let key = try? file.open(master: master) { return .opens(key, derived: derived) }
            }
            return .nothingToSay
        }
        guard let live, let copy = live.masterWordsCopy, live.master != nil, copy == vault.vault.masterByWords else {
            return .nothingToSay
        }
        guard let lock = live.passphrase else { return .notTheAccountsPassphrase }
        if lock.kdf != vault.vault.kdf {
            return .passphraseChangedElsewhere(device: vault.vault.updatedByDevice, day: vault.updatedAt)
        }
        return .nothingToSay
    }
}
