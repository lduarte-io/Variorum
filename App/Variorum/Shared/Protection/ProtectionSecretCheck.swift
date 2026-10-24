//
//  ProtectionSecretCheck.swift
//  Variorum (shared: Mac + Mobile — the Mac's door this unit; the phone's key doors are later, the brain is one)
//
//  VX-510 D-B7 — VX-513, THE READ-ONLY CHECK (her R-510-15, "Yes, in this run"; her Air report: "I also no longer seen an
//  option in settings to test your passphrase / 12 words to make sure you have them right"). One typed secret, read as Look
//  inside reads it (`MakeMineModel.copySecrets` — twelve valid words are the words, anything else a passphrase), checked
//  OFF THE MAIN ACTOR against:
//    - the OPEN library's live key file's locks, by the unlock's own derivation (`ProtectionOpenRoad.typedCandidatesAndKeys`
//      — the KDF floor checked before any derivation, the passphrase derived once per descriptor; the words by their own
//      lock or through the master's twelve-words copy), the key that yields compared with the open key; and
//    - on a SYNCED library, the account's vault (rules 7, 14): ONE fresh read through the vault leaf, bounded
//      (`ProtectionOpenRoad.boundedVaultRead` — VX-501's race: a slow server costs the check at most `vaultBound`), never
//      the executor's read, which fills the session's `freshVaults`; the master by the typed secret
//      (`AccountVault.master` non-nil) — the passphrase's key the library check derived, reused when its descriptor is the
//      vault's (one Argon2id), else derived once under the vault's own (its floor first).
//  It says one of: they open this library (and the account) · they open this library but not the account (an honest split —
//  a passphrase changed elsewhere names the change, VX-113's sentence) · they don't open this library — and, synced, whether
//  they open the account instead (PROVISIONAL P-VX510-B3-2, the record's unit B3) · or the account could not be checked
//  (signed out, another account, out of reach — the pane's own sentences). IT WRITES NOTHING — no key file, no keychain item,
//  no vault, no ledger, no session hold, no act lock — reads no keychain item (a custody or sync-keys Touch ID read prompts:
//  VX-503's lesson), and keeps nothing: the secret and every key derived from it are gone with the call. One protection-log
//  line per check, never the secret.
//

import CryptoKit
import Foundation
import VariorumCore

/// What a check said — pure, the sheet's lines derive from it.
nonisolated enum SecretCheckOutcome: Equatable, Sendable {
    /// What was typed, as the check read it.
    enum Kind: Equatable, Sendable {
        case passphrase
        case words
    }

    /// The account's half, on a library whose secrets opened it.
    enum Account: Equatable, Sendable {
        /// The library names no account.
        case notSynced
        case opens
        /// They open the library but not the account's vault — `changedElsewhere`: VX-113's sentence (the passphrase
        /// typed is the library's, its descriptor no longer the vault's — changed on another device).
        case doesNotOpen(changedElsewhere: String?)
        /// The account could not be checked now — why, in the pane's own sentence.
        case unchecked(String)
    }

    /// The typed secret opens the open library.
    case opens(Kind, account: Account)
    /// It does not; `opensAccount`: synced, and it opens the account's vault instead.
    case doesNotOpen(Kind, opensAccount: Bool)
    /// Nothing was checked — why (the words' own sentence for twelve words that are not the words; a door no longer open).
    case refused(String)

    /// What the sheet says, in order.
    var lines: [String] {
        switch self {
        case .opens(let kind, .notSynced):
            return [ProtectionWords.checkSecretsOpensLibrary(kind)]
        case .opens(let kind, .opens):
            return [ProtectionWords.checkSecretsOpensLibraryAndAccount(kind)]
        case .opens(let kind, .doesNotOpen(let changedElsewhere)):
            return [ProtectionWords.checkSecretsOpensLibraryNotAccount(kind)] + [changedElsewhere].compactMap { $0 }
        case .opens(let kind, .unchecked(let why)):
            return [ProtectionWords.checkSecretsOpensLibrary(kind), why]
        case .doesNotOpen(let kind, opensAccount: true):
            return [ProtectionWords.checkSecretsOpensAccountNotLibrary(kind)]
        case .doesNotOpen(.passphrase, opensAccount: false):
            return [ProtectionWords.passphraseDoesNotOpen]
        case .doesNotOpen(.words, opensAccount: false):
            return [ProtectionWords.wordsDoNotOpen]
        case .refused(let sentence):
            return [sentence]
        }
    }

    /// The first line is a warning (something the typed secret does not open, or nothing checked).
    var warns: Bool {
        switch self {
        case .opens(_, .notSynced), .opens(_, .opens), .opens(_, .unchecked): return false
        case .opens(_, .doesNotOpen), .doesNotOpen, .refused: return true
        }
    }
}

nonisolated enum ProtectionSecretCheck {
    /// How long a check waits for the account's vault before it says the account could not be checked (VX-501's bound,
    /// P-VX510-B2-1's value — PROVISIONAL with it).
    static let vaultBound: Duration = .seconds(10)

    /// THE CHECK — `typed` against the open library on `session` (and, synced, its account as `signIn`). Reads only.
    static func check(
        _ session: ProtectionRoadSession, typed text: String, signIn: SessionFact, within bound: Duration = vaultBound
    ) async -> SecretCheckOutcome {
        let library = session.library
        // Nothing typed is nothing checked (the ladder's F-R1-4): the sheet's own ask, never "that passphrase doesn't open"
        // (unreachable through the sheet — its `canSubmit` refuses an empty field).
        guard !text.isEmpty else { return .refused(ProtectionWords.checkSecretsLead) }
        // The library's own locks: the live key file of the key the library is open under (the door stands only then).
        guard let keyFile = library.keyFile, keyFile.fingerprint == library.fingerprint else {
            ProtectionOpenRoad.log("road: a secret check found no key file of the open key beside the library — nothing checked")
            return .refused(ProtectionWords.crossingDoorClosed)
        }
        // Read as Look inside reads it: twelve valid words are the words, anything else a passphrase.
        let reading = MakeMineModel.copySecrets(text, currentPair: .none)
        let kind: SecretCheckOutcome.Kind
        let secret: ProtectionSecret
        if let words = reading.words {
            kind = .words
            secret = .words(words)
        } else {
            kind = .passphrase
            secret = .passphrase(text)
        }
        let derived = ProtectionOpenRoad.typedCandidatesAndKeys(secret, files: [keyFile], floor: session.system.floor)
        let opensLibrary = derived.keys.contains(library.key)
        // Twelve tokens that are not the words, opening nothing as a passphrase: the words' own sentence (the count, an
        // unknown word, the checksum — the lobby's refusals).
        if !opensLibrary, kind == .passphrase, let refusal = wordsShapeRefusal(text) {
            log(library: false, account: "not checked (twelve words that are not the words)")
            return .refused(refusal)
        }
        guard let account = library.record?.account else {
            log(library: opensLibrary, account: "none (the library doesn't sync)")
            return opensLibrary ? .opens(kind, account: .notSynced) : .doesNotOpen(kind, opensAccount: false)
        }
        let accountHalf = await checkAccount(
            account, session: session, signIn: signIn, text: text, kind: kind, derived: derived.unlock,
            libraryPassphraseKDF: keyFile.passphrase?.kdf, within: bound)
        switch accountHalf {
        case .opens:
            log(library: opensLibrary, account: "opens")
            return opensLibrary ? .opens(kind, account: .opens) : .doesNotOpen(kind, opensAccount: true)
        case .doesNotOpen(let changedElsewhere):
            log(library: opensLibrary, account: changedElsewhere == nil ? "does not open" : "does not open (changed elsewhere)")
            // VX-113's sentence names a change of the LIBRARY's passphrase elsewhere — said only where it opened the library.
            return opensLibrary
                ? .opens(kind, account: .doesNotOpen(changedElsewhere: changedElsewhere))
                : .doesNotOpen(kind, opensAccount: false)
        case .unchecked(let why):
            log(library: opensLibrary, account: "not checked")
            return opensLibrary ? .opens(kind, account: .unchecked(why)) : .doesNotOpen(kind, opensAccount: false)
        case .notSynced:
            return opensLibrary ? .opens(kind, account: .notSynced) : .doesNotOpen(kind, opensAccount: false)
        }
    }

    /// The account's half: signed in as the library's account, one bounded vault read through the leaf, the master by the
    /// typed secret.
    static func checkAccount(
        _ account: String, session: ProtectionRoadSession, signIn: SessionFact, text: String,
        kind: SecretCheckOutcome.Kind, derived: ProtectionOpenRoad.TypedUnlockSecret,
        libraryPassphraseKDF: PassphraseKDF.Descriptor?, within bound: Duration
    ) async -> SecretCheckOutcome.Account {
        guard let signedIn = signIn.accountID else { return .unchecked(ProtectionWords.doorRefusedSignedOut) }
        guard signedIn == account else { return .unchecked(ProtectionWords.doorRefusedOtherAccount) }
        let snapshot: VaultSnapshot
        switch await ProtectionOpenRoad.boundedVaultRead(session.system.leaves.vault, accountID: account, within: bound) {
        case .read(let read?):
            snapshot = read
        case .read(nil), .failed, .timedOut:
            return .unchecked(ProtectionWords.doorRefusedNeedsVault)
        }
        let vault = snapshot.vault
        let master: SymmetricKey?
        switch (kind, derived) {
        case (.passphrase, .passphrase(let keys)):
            if let reused = keys.first(where: { $0.kdf == vault.kdf }) {
                master = vault.master(passphrase: reused, words: nil)
            } else if (try? vault.kdf.validateFloor(session.system.floor)) != nil,
                      let fresh = try? PassphraseKey.derive(text, kdf: vault.kdf) {
                master = vault.master(passphrase: fresh, words: nil)
            } else {
                master = nil  // the vault's descriptor below the floor opens to no passphrase here (no cheap KDF, ever)
            }
        case (.words, .words(let words)):
            master = (try? WordsKey.derive(words)).flatMap { vault.master(passphrase: nil, words: $0) }
        default:
            master = nil
        }
        if master != nil { return .opens }
        if kind == .passphrase, let known = libraryPassphraseKDF, known != vault.kdf {
            return .doesNotOpen(changedElsewhere: ProtectionWords.passphraseChangedElsewhere(
                device: vault.updatedByDevice, day: snapshot.updatedAt.map { ProtectionWords.day($0) }))
        }
        return .doesNotOpen(changedElsewhere: nil)
    }

    /// Twelve whitespace-separated tokens that are not twelve valid words: the words' own refusal sentence. Anything else
    /// (another count — a passphrase of other words) says nothing here.
    static func wordsShapeRefusal(_ text: String) -> String? {
        let tokens = WordsInput.words(from: text)
        guard tokens.count == 12 else { return nil }
        do {
            try RecoveryPhrase.validate(tokens)
            return nil
        } catch let error as RecoveryPhraseError {
            return ProtectionOpenRoad.sentence(for: error)
        } catch {
            return ProtectionWords.wordsDoNotOpen
        }
    }

    private static func log(library opens: Bool, account: String) {
        ProtectionOpenRoad.log("road: a secret check (read-only, nothing written) — the library: "
            + (opens ? "opens" : "does not open") + "; the account: \(account)")
    }
}
