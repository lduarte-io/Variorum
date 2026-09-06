//
//  WordsCeremony.swift
//  Variorum (shared: Mac + Mobile — THE TWELVE WORDS' ONE brain)
//
//  pre-13x batch 3a — copy §2a's Screens 3 / 3b, factored out of
//  `PostureSwitchModel` (the 2b ceremony's own machinery was the reference)
//  so the sync-setup ceremony (3a) and the Castle ceremony (2b) — and 3b's
//  Replace All Keys and Regenerate — compose ONE brain, never a copy:
//    · the words EXIST (the library's, or the account's): *Type My Words…*
//      (validated as a phrase, then VERIFIED by the caller's closure —
//      against the key file, or against the vault) or *Generate New Ones*
//      (the new ones replace the old everywhere — decision 5's letter);
//    · no words: generate → shown ONCE → *I've written them down* →
//      confirmed by EXACT re-entry (copy §2a Screen 3b's errors).
//  The words in hand leave here only through `wordsInHand`; the brain never
//  lands anything — the composing model does (the vault's wrap, the key
//  file's copy).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class WordsCeremony {
    enum Step: Equatable {
        /// Words exist — choose: type them, or generate new ones.
        case existing
        /// Typing the existing words.
        case typeExisting
        /// Fresh words on screen (shown once).
        case show([String])
        /// Confirm the fresh words by exact re-entry.
        case confirm([String])
        /// The words are in hand.
        case done
    }

    private(set) var step: Step
    /// The twelve words the ceremony ends with (typed and verified, or
    /// generated and confirmed) — nil until `.done`.
    private(set) var wordsInHand: [String]?
    /// True when fresh words REPLACE an existing set (Generate New Ones):
    /// the caller replaces every copy of the old.
    private(set) var regenerated = false
    var lastError: String?

    init(wordsExist: Bool) throws {
        if wordsExist {
            step = .existing
        } else {
            step = .show(try RecoveryPhrase.generate())
        }
    }

    func chooseTypeMine() {
        guard case .existing = step else { return }
        lastError = nil
        step = .typeExisting
    }

    func chooseGenerateNew() throws {
        guard case .existing = step else { return }
        lastError = nil
        regenerated = true
        step = .show(try RecoveryPhrase.generate())
    }

    /// The existing words, typed: the phrase's own errors speak first
    /// (count, an unknown word, the checksum); then the caller VERIFIES
    /// them against the copy that must open (the key file's, or the
    /// vault's). Returns true when the words are in hand.
    @discardableResult
    func submitExisting(_ typed: String, verify: (String) async -> VaultTie.Verify) async -> Bool {
        guard case .typeExisting = step else { return false }
        lastError = nil
        let words = EncryptionSession.words(from: typed)
        do {
            _ = try RecoveryPhrase.recoveryWrapKey(words: words)
        } catch {
            lastError = EncryptionSession.message(for: error)
            return false
        }
        switch await verify(typed) {
        case .match:
            wordsInHand = words
            step = .done
            return true
        case .mismatch(let message):
            lastError = message
            return false
        case .couldNotCheck(let reason):
            lastError = "Couldn't check the words (\(reason))."
            return false
        }
    }

    func acknowledgeWritten() {
        guard case .show(let words) = step else { return }
        lastError = nil
        step = .confirm(words)
    }

    /// Screen 3b: the re-entry must be the shown words, exactly. Returns
    /// true when the words are in hand.
    @discardableResult
    func confirm(_ typed: String) -> Bool {
        guard case .confirm(let words) = step else { return false }
        lastError = nil
        let entered = EncryptionSession.words(from: typed).map { $0.lowercased() }
        guard entered.count == 12 else {
            lastError = EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(entered.count))
            return false
        }
        guard entered == words.map({ $0.lowercased() }) else {
            lastError = ProtectionCopy.wordsMismatch
            return false
        }
        wordsInHand = words
        step = .done
        return true
    }
}
