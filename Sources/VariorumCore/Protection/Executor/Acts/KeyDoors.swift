import CryptoKit
import Foundation

// VX-305 U3 — THE KEY DOORS (design §3.9): change passphrase (verifying the
// current one), new words (asking the passphrase), and the forgotten-
// passphrase reset — in Castle through Touch ID on an enrolled device or the
// twelve words (today's road, kept — her ruling), in Standard a plain confirm
// (this Mac holds the key). They RE-WRAP THE CURRENT KEY and re-lock nothing
// else (rule 6): the history needs no secret — the current key opens it. A
// NEW passphrase always takes a fresh KDF descriptor (U2's hand-forward: the
// route finder's `.current` rests on it). Synced, the vault's lock on the
// master is re-made too (one CAS write under the proof — rule 7: "the key doors
// change the library's and the account's locks together"; no key changes —
// rule 15). (The anchor sentences these doors said left with VX-378 U1 — rule
// 6.)

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
            // Landed already (this act's own write): nothing to do.
            switch act {
            case .changePassphrase, .resetPassphrase:
                if snapshot.vault.kdf == (try ctx.requirePassphrase()).kdf { return }
            default:
                guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
                if VaultModel.master(of: snapshot.vault, passphrase: nil, words: words) != nil { return }
            }
            // Not landed, and no master in reach — the press's secret no longer
            // opens the vault (the account moved elsewhere since the press: a
            // passphrase changed on another device) and no held keys follow
            // it: before this, the act's first vault write, it ROLLS BACK, as a
            // vault write does; the follow picks the change up and
            // she presses again (VX-305 U4, the soak's seed 10 — it stuck in
            // flight with its vault in reach).
            let held: AccountKeys
            do {
                held = try ctx.material(for: snapshot)
            } catch ExecutorRefusal.secretsRequired {
                throw ActRollback(refusal: .accountMoved)
            }
            let vault: AccountVault
            switch act {
            case .changePassphrase, .resetPassphrase:
                vault = try VaultModel.rewrappingPassphrase(
                    snapshot.vault, master: held.masterKey, passphrase: try ctx.requirePassphrase(), device: ctx.deviceName)
            default:
                guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
                vault = try VaultModel.rewrappingWords(snapshot.vault, master: held.masterKey, words: words, device: ctx.deviceName)
            }
            let written = try await ctx.leaves.vault.updateVault(
                vault, accountID: snapshot.accountID, expectedRevision: snapshot.revision,
                proofMaster: held.masterKey, successorMaster: nil, device: ctx.deviceName)
            ctx.executor.noteFresh(written)
        case "keyFile":
            guard var file = ctx.library.keyFile, file.fingerprint == ctx.library.fingerprint else {
                throw ExecutorRefusal.noLiveKeyFile
            }
            switch act {
            case .changePassphrase, .resetPassphrase:
                file = try file.settingPassphrase(try ctx.requirePassphrase(), for: ctx.library.key)
            default:
                guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
                file = try file.settingWords(words, for: ctx.library.key)
                // §3.5a: the master's words copy refreshed while that master is
                // current — the vault's master must be the one this file's
                // master lock is under (a resume after another device replaced
                // the account's keys put the NEW master's copy beside the old
                // master's lock — VX-305 U4, the soak's seed 6).
                if let account = ctx.accountID, let vault = ctx.executor.freshVaults[account],
                   let master = VaultModel.master(of: vault.vault, passphrase: nil, words: words),
                   (try? file.open(master: master)) != nil {
                    file = file.refreshingMasterWordsCopy(vault.vault.masterByWords)
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
            try vault.vault.kdf.validateFloor(configuration.floor)
            let typed = try PassphraseKey.derive(current, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: typed, words: nil) != nil else {
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
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
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
               held.rowKeyID == vault.rowKeyID { return }
        }
        if let held = leaves.syncKeys.sessionSyncKeys(accountID: account), held.rowKeyID == vault.rowKeyID { return }
        guard let master = VaultModel.master(of: vault.vault, passphrase: passphrase, words: words) else {
            throw ExecutorRefusal.secretsRequired(.changePassphrase)
        }
        leaves.syncKeys.holdInSession(try vault.vault.keys(master: master), accountID: account)
    }

    /// **New words** — asking the passphrase.
    public func regenerateWords(_ library: inout UnlockedLibrary, passphrase: String, newWords: [String]) async throws -> ActOutcome {
        var parameters = try await keyDoorParameters(library)
        let current: PassphraseKey
        if let account = parameters.accountID, let vault = freshVaults[account] {
            try vault.vault.kdf.validateFloor(configuration.floor)
            current = try PassphraseKey.derive(passphrase, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: current, words: nil) != nil else {
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

    /// The account's sync key moved past the one this library follows
    /// (assess's `follow(.keysReplaced)` read — the record names it, rule 15).
    func libraryBehind(_ library: UnlockedLibrary, vault: VaultSnapshot) -> Bool {
        library.record?.accountRowKeyID != vault.rowKeyID
    }

    func keyDoorParameters(_ library: UnlockedLibrary) async throws -> ActParameters {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        var parameters = ActParameters(synced: record.account != nil, accountID: record.account)
        if let account = record.account {
            try requireSignedIn(as: account)
            guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
            // The account moved since this device last followed — its keys or
            // its mode: pick up the new keys first (assess's `followOwed`; begun
            // here, the door refused inside its plan with stale keys, leaving
            // the act in flight — VX-305 U4, found by the scenario world).
            if vault.mode != record.mode { throw ExecutorRefusal.accountMoved }
            if libraryBehind(library, vault: vault) { throw ExecutorRefusal.accountMoved }
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
