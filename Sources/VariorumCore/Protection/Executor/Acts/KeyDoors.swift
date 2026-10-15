import CryptoKit
import Foundation

// VX-305 U3 — THE KEY DOORS (design §3.9): change passphrase (verifying the
// current one), new words (asking the passphrase), and the forgotten-
// passphrase reset — in Castle through Touch ID on an enrolled device or the
// twelve words (today's road, kept — her ruling), in Standard a plain confirm
// (this Mac holds the key). They RE-WRAP THE CURRENT KEY and re-lock nothing
// else: the history needs no secret, and the anchor keeps the secrets of its
// day (§3.4). A NEW passphrase always takes a fresh KDF descriptor (U2's
// hand-forward: the route finder's `.current` rests on it). Synced, the vault
// is re-wrapped too (one CAS write under the proof — a convenience act, never
// a rotation). Every one of them, while an anchor exists, says in its Done
// what still opens the copies from before the leave — the reset road never
// pointing at the passphrase she said she forgot.

struct KeyDoorProgram: ActProgram {
    let act: ProtectionAct

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        (parameters.synced == true ? ["vault"] : []) + ["keyFile", "memory"]
    }

    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "vault":
            let snapshot = try await ctx.freshRead()
            let held = try ctx.material(for: snapshot)
            var format = snapshot.format
            switch act {
            case .changePassphrase, .resetPassphrase:
                let passphrase = try ctx.requirePassphrase()
                if format.kdf == passphrase.kdf { return }  // landed already
                format = try format.rewrappingPassphrase(
                    masterKey: held.masterSymmetricKey, passphraseKey: passphrase.key, kdf: passphrase.kdf)
            default:
                guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
                if VaultModel.master(of: format, passphrase: nil, words: words) != nil { return }
                format = try format.replacingRecoveryWrap(masterKey: held.masterSymmetricKey, recoveryKey: words.key)
            }
            format.updatedByDevice = ctx.deviceName
            let written = try await ctx.leaves.vault.updateVault(
                format, accountID: snapshot.accountID, expectedRevision: snapshot.revision,
                proofMaster: held.masterSymmetricKey, device: ctx.deviceName)
            ctx.executor.noteFresh(written)
        case "keyFile":
            guard var file = ctx.library.keyFile, file.fingerprint == ctx.library.fingerprint else {
                throw ExecutorRefusal.noLiveKeyFile
            }
            // The sentence reads the file as the door found it — "the passphrase
            // you're replacing" is provable only against the lock it replaces.
            switch act {
            case .changePassphrase: ctx.saySentence(.changePassphrase)
            case .resetPassphrase: ctx.saySentence(.resetForgottenPassphrase)
            default: ctx.saySentence(.replacesWords)
            }
            switch act {
            case .changePassphrase, .resetPassphrase:
                file = try file.settingPassphrase(try ctx.requirePassphrase(), for: ctx.library.key)
            default:
                guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
                file = try file.settingWords(words, for: ctx.library.key)
                // §3.5a: the master's words copy refreshed while that master is current.
                if let account = ctx.accountID, let vault = ctx.executor.freshVaults[account] {
                    file = file.refreshingMasterWordsCopy(vault.format.masterWrappedByRecovery)
                }
            }
            try ctx.executor.writeLiveKeyFile(file, &ctx.library)
        case "memory":
            try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

/// How a forgotten-passphrase reset is authorized (§3.9, her ruling).
public enum ResetAuthorization: Sendable {
    /// Castle: the library opened by Touch ID on this enrolled device — the key
    /// in hand came through a press.
    case touchID
    /// Castle: the twelve words, typed (and verified).
    case words([String])
    /// Standard: a plain confirm — this Mac holds the key.
    case plainConfirm
}

extension ProtectionExecutor {
    /// **Change passphrase** — the current one verified (against the vault's
    /// copy when synced, so a word retired elsewhere is refused here), the new
    /// one on a fresh descriptor.
    public func changePassphrase(_ library: inout UnlockedLibrary, current: String, new: String) async throws -> ActOutcome {
        let parameters = try await keyDoorParameters(library)
        if let account = parameters.accountID, let vault = freshVaults[account] {
            try vault.format.kdf.validateFloor(configuration.floor)
            let typed = try PassphraseKey.derive(current, kdf: vault.format.kdf)
            guard VaultModel.master(of: vault.format, passphrase: typed, words: nil) != nil else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            try holdSyncKeysForTheSession(account: account, vault: vault, passphrase: typed, words: nil)
        } else {
            _ = try verifiedPassphrase(current, against: library.keyFile)
        }
        return try await keyDoor(.changePassphrase, &library, newPassphrase: new, words: nil, parameters: parameters)
    }

    /// **Reset a forgotten passphrase** — Castle: Touch ID on an enrolled
    /// device or the words; Standard: a plain confirm.
    public func resetPassphrase(
        _ library: inout UnlockedLibrary, authorization: ResetAuthorization, new: String
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        switch (record.mode, authorization) {
        case (.castle, .touchID):
            guard try leaves.custody.custodyItems().contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .touchid))
            else { throw ExecutorRefusal.nothingToDo }
        case (.castle, .words(let words)):
            _ = try verifiedWords(words, against: library.keyFile)
        case (.standard, _):
            break
        case (.castle, .plainConfirm):
            throw ExecutorRefusal.secretMissing
        }
        var words: WordsKey?
        if case .words(let typed) = authorization { words = try WordsKey.derive(typed) }
        let parameters = try await keyDoorParameters(library)
        if let account = parameters.accountID, let vault = freshVaults[account] {
            try holdSyncKeysForTheSession(account: account, vault: vault, passphrase: nil, words: words)
        }
        return try await keyDoor(.resetPassphrase, &library, newPassphrase: new, words: words, parameters: parameters)
    }

    /// A synced key door re-wraps the vault under the account's master, which
    /// the act reads from custody or this session — and an Always-ask device
    /// unlocked offline holds none yet (pre-13x §3.3). The door derives the
    /// account's keys from the vault with the secret typed THERE and holds them
    /// for the session, so the act never begins without what its vault step
    /// needs (it began, then refused inside its plan, leaving the act in flight
    /// with nothing able to finish it — VX-305 U4, found by the scenario
    /// world). Nothing is written to disk; a relock drops them.
    func holdSyncKeysForTheSession(account: String, vault: VaultSnapshot, passphrase: PassphraseKey?, words: WordsKey?) throws {
        for itemClass in [ProtectionNames.CustodyClass.touchid, .silent] {
            if let held = try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: itemClass),
               held.corpusKeyID == vault.corpusKeyID { return }
        }
        if let held = leaves.syncKeys.sessionSyncKeys(accountID: account), held.corpusKeyID == vault.corpusKeyID { return }
        guard let master = VaultModel.master(of: vault.format, passphrase: passphrase, words: words) else {
            throw ExecutorRefusal.secretsRequired(.changePassphrase)
        }
        leaves.syncKeys.holdInSession(try VaultModel.material(following: vault.format, master: master), accountID: account)
    }

    /// **New words** — asking the passphrase.
    public func regenerateWords(_ library: inout UnlockedLibrary, passphrase: String, newWords: [String]) async throws -> ActOutcome {
        var parameters = try await keyDoorParameters(library)
        let current: PassphraseKey
        if let account = parameters.accountID, let vault = freshVaults[account] {
            try vault.format.kdf.validateFloor(configuration.floor)
            current = try PassphraseKey.derive(passphrase, kdf: vault.format.kdf)
            guard VaultModel.master(of: vault.format, passphrase: current, words: nil) != nil else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
        } else {
            current = try verifiedPassphrase(passphrase, against: library.keyFile)
        }
        parameters.passphraseKDF = current.kdf
        parameters.wordsAreNew = true
        return try await perform(
            KeyDoorProgram(act: .regenerateWords), parameters: parameters,
            secrets: ActSecrets(passphrase: current, words: try WordsKey.derive(newWords)), library: &library)
    }

    func keyDoorParameters(_ library: UnlockedLibrary) async throws -> ActParameters {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        var parameters = ActParameters(synced: record.account != nil, accountID: record.account)
        if let account = record.account {
            try requireSignedIn(as: account)
            guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
            // The account moved since this device last followed — its keys or
            // its mode: pick up the new keys first (assess's `followOwed`; begun
            // here, the door refused inside its plan with stale keys, leaving
            // the act in flight — VX-305 U4, found by the scenario world).
            if let settled = vault.mode.settled, settled != record.mode { throw ExecutorRefusal.accountMoved }
            if let known = library.memory?.vaultFacts?.corpusKeyID, known != vault.corpusKeyID {
                throw ExecutorRefusal.accountMoved
            }
        }
        return parameters
    }

    func keyDoor(
        _ act: ProtectionAct, _ library: inout UnlockedLibrary, newPassphrase: String, words: WordsKey?,
        parameters: ActParameters
    ) async throws -> ActOutcome {
        var parameters = parameters
        let fresh = try freshPassphrase(newPassphrase)
        parameters.passphraseKDF = fresh.kdf
        parameters.passphraseIsNew = true
        return try await perform(
            KeyDoorProgram(act: act), parameters: parameters, secrets: ActSecrets(passphrase: fresh, words: words),
            typed: TypedSecrets(newPassphrase: newPassphrase), library: &library)
    }
}
