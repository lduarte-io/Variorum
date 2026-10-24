import CryptoKit
import Foundation

// VX-529 — THE PAIR CATCH-UP, the follow's third kind (`notes/plans/fixes/vx-529-pair-catchup.md`, design §2; the
// architect's ruling on the fork: Shape A — a no-re-key arm INSIDE `FollowProgram`). The account's passphrase or twelve
// words were re-made on another device (a key door there re-wrapped only the vault's master): the master, the sync keys
// and this library's key are all unchanged, and this library's key file still carries the pair as it last knew it. The
// catch-up RE-LOCKS the current key and never re-keys it (rule 6's verb; rule 7: one pair at a time):
//   - the door (`followThePair`) re-reads the vault and re-derives the halves that moved FROM THAT READ; the passphrase
//     half types the account's current passphrase, verified against the vault (the old one names the change — P1's
//     split); the words half types nothing (R-529-2) — the master comes from what this device already holds, prompt-
//     free first (S-1/E14: none in hand ⇒ `secretMissing`); the master must reach this key through the key file's
//     master lock (rule 22's precondition);
//   - the act runs as `.follow` with `toKey` nil (no new key: no custody item, no staged file, no swap, no Apple key,
//     nothing written to the server): the account's keys held per posture, then the key file re-locked
//     (`KeyFile.relockedToTheAccountsPair` — through the existing key-file road), then what this Mac remembers follows it
//     (rule 1's mirror). No backup step: the key doors take none after a re-lock (S-2, verified — the run record's P6a).
// Every step is idempotent and a crash at any write leaves the old state or the new one (rule 20): the re-lock is ONE
// key-file write, and a step finding it landed (`AssessRules.pairFollow` nil against its fresh read) does nothing more.

enum PairCatchUp {
    /// The act's steps (the architect's ruling).
    static let steps = ["pickUpKeys", "relock", "memory"]
    /// With no plan to trust, the act in flight naming no new key: what this Mac remembers, nothing else.
    static let finishingSteps = ["memory"]

    static func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "pickUpKeys": try await ctx.pickUpThePairsKeys()
        case "relock": try await ctx.relockToTheAccountsPair()
        case "memory": try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ProtectionExecutor {
    /// **The pair catch-up's door** — every check a READ, before anything begins (nothing written by a refusal).
    func followThePair(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        try requireSignedIn(as: account)
        guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        // E2/E4: the account moved posture or sync key since the assessment — the follow owed now is another kind.
        if vault.mode != record.mode || libraryBehind(library, vault: vault) { throw ExecutorRefusal.accountMoved }
        guard let file = library.keyFile, file.fingerprint == library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        // Which halves moved — from THIS read (the vault may have moved again since the door was drawn).
        guard case .pairChanged(let passphraseMoved, _)? = AssessRules.pairFollow(file, vault.reading) else {
            throw ExecutorRefusal.nothingToDo
        }
        var secrets = ActSecrets()
        if let text = typed.passphrase {
            try vault.vault.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: passphrase, words: nil) != nil else {
                throw refusalForAPassphraseTheVaultRefuses(text, library, vault: vault)
            }
            secrets.passphrase = passphrase
        } else if passphraseMoved {
            // The passphrase lock can be re-made only by the passphrase (design §2): the words cannot stand in for it.
            throw ExecutorRefusal.secretMissing
        }
        if let words = typed.words {
            let wordsKey = try WordsKey.derive(words)
            guard VaultModel.master(of: vault.vault, passphrase: nil, words: wordsKey) != nil else {
                throw ExecutorRefusal.wordsDoNotOpen
            }
            secrets.words = wordsKey
        }
        // S-1 / E14: the account's master — from the secrets typed, else what this device holds.
        guard let keys = try pairKeysAtTheDoor(account: account, vault: vault, secrets: secrets,
                                               castle: record.mode == .castle) else {
            throw ExecutorRefusal.secretMissing
        }
        // Rule 22's precondition, at the door: that master reaches THIS key through the key file's master lock — the
        // road the words keep once the copy is the account's. Else this file is not under the account's master: no pair
        // to catch up to here — follow first.
        guard (try? file.open(master: keys.masterKey)) != nil else { throw ExecutorRefusal.accountMoved }
        let parameters = ActParameters(
            gate: library.section.settings.gateStyle, synced: true, accountID: account,
            passphraseKDF: secrets.passphrase?.kdf,
            typedSecret: secrets.passphrase != nil ? "passphrase" : (secrets.words != nil ? "words" : nil),
            follow: FollowProgram.pairChangedName, newKind: record.mode)
        return try await perform(
            FollowProgram(), parameters: parameters, secrets: secrets, typed: typed, material: keys, library: &library)
    }

    /// The account's sync keys for the pair catch-up's door: from the secrets typed; else this session's; else the
    /// silent item; else — Castle only (VX-517: a Standard library never reads the Touch ID class), last and once — the
    /// Touch ID item (a read there is a press). Each held copy counts only as the vault's CURRENT keys under its master.
    func pairKeysAtTheDoor(account: String, vault: VaultSnapshot, secrets: ActSecrets, castle: Bool) throws -> AccountKeys? {
        if let master = VaultModel.master(of: vault.vault, passphrase: secrets.passphrase, words: secrets.words) {
            return try vault.vault.keys(master: master)
        }
        func current(_ held: AccountKeys?) -> AccountKeys? {
            guard let held, held.rowKeyID == vault.rowKeyID, vault.vault.isMaster(held.masterKey) else { return nil }
            return held
        }
        if let held = current(leaves.syncKeys.sessionSyncKeys(accountID: account)) { return held }
        if let held = current(try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .silent)) { return held }
        if castle, let held = current(try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .touchid)) { return held }
        return nil
    }
}

extension ActContext {
    /// The account's keys in hand for the catch-up's steps: the door's (this press — read once); else from the
    /// secrets in hand (a resume: typed at the lobby — VX-503's secrets-first); else what this device holds, prompt-free
    /// first, the Touch ID class last and only in Castle (VX-517). Each counts only as the vault's current keys.
    func pairKeysInHand(_ snapshot: VaultSnapshot) throws -> AccountKeys? {
        func current(_ held: AccountKeys?) -> AccountKeys? {
            guard let held, held.rowKeyID == snapshot.rowKeyID, snapshot.vault.isMaster(held.masterKey) else { return nil }
            return held
        }
        if let held = current(material) { return held }
        if let master = VaultModel.master(of: snapshot.vault, passphrase: secrets.passphrase, words: secrets.words),
           let keys = try? snapshot.vault.keys(master: master) {
            material = keys
            return keys
        }
        guard let account = accountID else { return nil }
        var candidates = [leaves.syncKeys.sessionSyncKeys(accountID: account),
                          try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .silent)]
        if library.record?.mode == .castle {
            candidates.append(try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .touchid))
        }
        guard let held = candidates.lazy.compactMap({ current($0) }).first else { return nil }
        material = held
        return held
    }

    /// The account's keys held per posture (rule 15's custody, VX-517's classes): Standard files them in the silent
    /// item (`holdSyncKeys` — prompt-free); Castle holds them in session memory for the engine (VX-487 (a)). A pair change
    /// changes no key, so an item custody already holds still holds these — never re-read or re-written (a Touch ID read
    /// would be a press for nothing).
    func holdThePairsKeys(_ keys: AccountKeys, castle: Bool) throws {
        guard let account = accountID else { return }
        if castle {
            leaves.syncKeys.holdInSession(keys, accountID: account)
            material = keys
        } else {
            try holdSyncKeys(keys, castleWay: false)
        }
    }

    /// **Step 1 — the account's keys**, from a fresh read: the account must still be in this library's posture under the
    /// sync key it follows (else it moved on — this follow rolls back, the one now owed runs instead); the keys held per
    /// posture; the followed sync key stamped (the same key — idempotent).
    func pickUpThePairsKeys() async throws {
        let snapshot = try await freshRead()
        let record = try requireRecord()
        guard snapshot.mode == record.mode, snapshot.rowKeyID == record.accountRowKeyID else {
            throw ActRollback(refusal: .accountMoved)
        }
        guard let keys = try pairKeysInHand(snapshot) else {
            throw ActRollback(refusal: resuming ? .secretsRequired(act) : .secretMissing)
        }
        try holdThePairsKeys(keys, castle: snapshot.mode == .castle)
        try stampFollowed(keys.rowKeyID)
    }

    /// **Step 2 — the re-lock** (one key-file write): landed already ⇒ nothing. Else the passphrase half needs the
    /// account's current passphrase in hand — the press's, or a resume's typed at the lobby — opening the vault as it
    /// stands (E4: it moved again since the door ⇒ the act rolls back, naming the change); the master must reach this
    /// key (rule 22, checked by the re-lock itself). A missing secret at a resume rolls back too — the old state.
    func relockToTheAccountsPair() async throws {
        guard let account = accountID else { throw ExecutorRefusal.notSynced }
        let snapshot: VaultSnapshot
        if let read = executor.freshVaults[account] { snapshot = read } else { snapshot = try await freshRead() }
        guard let file = library.keyFile, file.fingerprint == library.fingerprint else {
            throw ActRollback(refusal: .noLiveKeyFile)
        }
        guard case .pairChanged(let passphraseMoved, let wordsMoved)? = AssessRules.pairFollow(file, snapshot.reading) else {
            log("the key file already carries the account's pair — nothing to re-lock")
            return
        }
        var passphrase: PassphraseKey?
        if passphraseMoved {
            guard let typed = secrets.passphrase, typed.kdf == snapshot.vault.kdf,
                  VaultModel.master(of: snapshot.vault, passphrase: typed, words: nil) != nil else {
                throw ActRollback(refusal: resuming
                    ? .secretsRequired(act)
                    : .passphraseChangedElsewhere(device: snapshot.vault.updatedByDevice, day: snapshot.updatedAt))
            }
            passphrase = typed
        }
        guard let keys = try pairKeysInHand(snapshot) else {
            throw ActRollback(refusal: resuming ? .secretsRequired(act) : .secretMissing)
        }
        let relocked: KeyFile
        do {
            relocked = try file.relockedToTheAccountsPair(
                key: library.key, master: keys.masterKey, accountsWordsCopy: snapshot.vault.masterByWords,
                accountsPassphrase: passphrase, dropsOwnWordsLock: wordsMoved)
        } catch let error as KeyFileError {
            log("the account's master does not reach this key file (\(error)) — rolls back, nothing written")
            throw ActRollback(refusal: .accountMoved)
        }
        try executor.writeLiveKeyFile(relocked, &library)
        let halves = [passphraseMoved ? "passphrase" : nil, wordsMoved ? "words" : nil].compactMap { $0 }
        log("re-locked to the account's pair (\(halves.joined(separator: " and "))) — the key unchanged "
            + "(\(Self.fp8(library.fingerprint)))")
    }
}
