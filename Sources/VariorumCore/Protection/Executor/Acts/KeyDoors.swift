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
    /// VX-447 (VX-308 U3): new words on a library whose key file is gone everywhere (`keyFileGoneEverywhere`) — the act
    /// MINTS the file it locks, so it begins without one. Only `regenerateWords` sets it, only after that read.
    var mintsKeyFile = false

    var needsLiveKeyFile: Bool { !mintsKeyFile }

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        (parameters.synced == true ? ["vault"] : []) + ["keyFile", "memory"]
    }

    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        if step == "vault" || step == "keyFile", let refusal = resumeCannotFinish(ctx) {
            ctx.log("resumes without what it needs to finish (\(refusal)) — rolls back, nothing written (rule 20)")
            throw ActRollback(refusal: refusal)
        }
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
            if mintsKeyFile, act == .regenerateWords, try ctx.executor.keyFileGoneEverywhere(ctx.library) {
                try mintKeyFile(ctx)
                return
            }
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

    /// **VX-308 ladder round 1, MAJOR-1 — a RESUMED new-words act that cannot finish ROLLS BACK** (rule 20: "the next open
    /// finishes the act or rolls it back from what is on disk"; F-U3-2's option (a), scoped to `regenerateWords` — Change
    /// and Reset stay that ticket's design call). Its vault and key-file steps need the act's NEW words, which a plan never
    /// holds and nobody was shown (they died with the process), and a resume never mints a key file (the registry builds
    /// the program without `mintsKeyFile`). Either missing — no words in hand, or no live key file of the key to lock — and
    /// the act cannot reach its new state, so it returns to its old one BEFORE writing anything, through `drive`'s one
    /// rollback (the act cleared, the plan deleted, copies resumed). A vault write that already landed stands, as any
    /// landed CAS write does: the next new words re-wrap it with words she is shown. (Before this the resume threw out of
    /// the settle and the act stayed in flight for good — every later act refused, VX-447's banner door, rule 27's
    /// recovery road, included.) A resume HOLDING words — typed at a lobby — runs exactly as before; a press never
    /// reaches here (`resuming` is false and its words are always in hand).
    ///
    /// **VX-309 U1a — VX-450: CHANGE and RESET join it** (the stuck-act class's remainder — F-U3-2's option (a) for the
    /// other two key doors). Their vault and key-file steps need the act's NEW passphrase — derived at a resume only from
    /// one typed there (`derive`, under the plan's fresh descriptor); a quiet open types nothing and a lobby that took the
    /// words types none — and a live key file of the key to re-lock. Either missing, the act cannot reach its new state:
    /// it rolls back BEFORE writing anything, as the words act does (a landed vault write stands, as any landed CAS write
    /// does — the account then opens with the passphrase she typed at the press, and the next Change re-locks both). A
    /// resume holding a typed passphrase runs exactly as before (the plan-level check in `resume` and the vault's own
    /// refusals still judge it).
    func resumeCannotFinish(_ ctx: ActContext) -> ExecutorRefusal? {
        guard ctx.resuming else { return nil }
        switch act {
        case .regenerateWords:
            if ctx.secrets.words == nil { return .secretsRequired(act) }
        case .changePassphrase, .resetPassphrase:
            if ctx.secrets.passphrase == nil { return .secretsRequired(act) }
        default:
            return nil
        }
        if ctx.library.keyFile?.fingerprint != ctx.library.fingerprint { return .noLiveKeyFile }
        return nil
    }

    /// **VX-309 U1b — F-U1a-1 (the U1a arbitration's option (a), VX-450's second arm): a passphrase typed at a resume that
    /// opens only the lock the act is REPLACING is not the act's secret.** Change and Reset take a NEW passphrase on a fresh
    /// descriptor; a resume derives what the open typed under that descriptor. Where it opens NO passphrase lock under the
    /// plan's descriptor among `files` (the live key file and this Mac's sealed mirror) but DOES open one under an older
    /// descriptor — the lock the act re-locks over — it is the passphrase being replaced: used, the key-file step (synced, the
    /// vault step too) would re-lock under the OLD passphrase on a new salt and say resumed (the press's passphrase never
    /// set); and where the act's new lock already landed it failed the plan-level or vault check, thrown out of the settle —
    /// the act in flight for good. Answered true, `resume` drops it from the act's secrets, so `resumeCannotFinish` rolls the
    /// act back before any write (the old state; or, where the new lock already landed, MAJOR-1's residue (1)). A passphrase
    /// that opens a lock under the plan's descriptor IS the act's (the same text re-chosen included); one that opens neither
    /// is judged by the checks as before. Reads only; every other act answers false.
    static func typedPassphraseOpensOnlyTheReplacedLock(
        _ typed: String, act: ProtectionAct, planKDF: PassphraseKDF.Descriptor?, files: [KeyFile],
        floor: PassphraseKDF.Floor
    ) -> Bool {
        guard act == .changePassphrase || act == .resetPassphrase, let planKDF else { return false }
        func opens(_ file: KeyFile, under kdf: PassphraseKDF.Descriptor) -> Bool {
            guard (try? kdf.validateFloor(floor)) != nil, let key = try? PassphraseKey.derive(typed, kdf: kdf) else {
                return false
            }
            return (try? file.open(passphrase: .passphraseKey(key), floor: floor)) != nil
        }
        if files.contains(where: { $0.passphrase?.kdf == planKDF && opens($0, under: planKDF) }) { return false }
        return files.contains { file in
            guard let kdf = file.passphrase?.kdf, kdf != planKDF else { return false }
            return opens(file, under: kdf)
        }
    }

    /// VX-447 — THE FILE THE ACT LOCKS, MINTED (rule 27's state, the library open): the current key under the locks this
    /// act can vouch for — the new words (rule 2: never a file the words would not open), and, synced, the account's
    /// passphrase the door verified against the vault plus the master with its twelve-words copy as the vault holds them
    /// after this act's own words write (§3.5a — so a synced file is what setting up sync made it). No Apple lock (the
    /// key doors re-lock nothing else — the open's quiet-road repairs re-make it, rule 8) and NO HISTORY: every copy
    /// that carried rule 4's list is gone, which is the state itself. The record's epoch; never a new key (rule 6).
    func mintKeyFile(_ ctx: ActContext) throws {
        let record = try ctx.requireRecord()
        guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
        var locks = NewKeyLocks(passphrase: ctx.secrets.passphrase, words: words)
        if let account = ctx.accountID {
            guard let vault = ctx.executor.freshVaults[account],
                  let master = VaultModel.master(of: vault.vault, passphrase: nil, words: words)
            else { throw ExecutorRefusal.needsFreshVault }
            locks.master = master
            locks.masterWordsCopy = vault.vault.masterByWords
        }
        let file = try KeyFile.building(
            libraryID: record.libraryID, key: ctx.library.key, epoch: record.keyEpoch, locks: locks)
        try ctx.executor.writeLiveKeyFile(file, &ctx.library)
        ctx.log("no key file anywhere — a fresh one minted for the current key (\(ActContext.fp8(file.fingerprint)), "
            + "no history: no copy carried it)")
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
    ///
    /// VX-307 U2b (VX-412; PROVISIONAL P-VX307-U2b-1): a library with NO passphrase is asked nothing — `passphrase:
    /// nil` — only while it is STANDARD, UNSYNCED and its live key file carries no passphrase lock: the reset door's
    /// Standard plain confirm, twinned (this Mac holds the key; the library is open). Rule 2's first look mints the
    /// words the user records ("rule 6's act — the key unchanged"), and the card above the quick entry offers them
    /// while no passphrase exists yet (rule 3: "the passphrase is a convenience over the words"), so the look cannot
    /// wait on a passphrase. A library WITH a passphrase is asked it, exactly as before; Castle always is (nil
    /// refuses `secretMissing`), and so is a synced library (its vault's lock is re-made under the account's master).
    ///
    /// VX-308 U3 — VX-447 (her ruling, QUESTIONS #235: the no-key-file banner becomes the door, "the act can proceed";
    /// PROVISIONAL P-VX308-U3-1): with the library OPEN and NO key file of its key anywhere this Mac keeps one
    /// (`keyFileGoneEverywhere` — rule 27's after-open state), the act MINTS the file it then locks. Asked exactly what
    /// the state can still check, each a twin of an authorization the core already has: Standard + unsynced, nothing
    /// (no lock survives to verify; the reset door's plain confirm); synced, the account's passphrase against the vault
    /// (the synced arm below, unchanged). Castle + unsynced still refuses (no lock, no plain confirm in Castle).
    public func regenerateWords(_ library: inout UnlockedLibrary, passphrase: String?, newWords: [String]) async throws -> ActOutcome {
        var parameters = try await keyDoorParameters(library)
        let mints = try keyFileGoneEverywhere(library)
        guard let passphrase else {
            if mints {
                guard library.record?.mode == .standard, parameters.accountID == nil else { throw ExecutorRefusal.secretMissing }
            } else {
                guard library.record?.mode == .standard, parameters.accountID == nil,
                      let file = library.keyFile, file.fingerprint == library.fingerprint, file.passphrase == nil
                else { throw ExecutorRefusal.secretMissing }
            }
            parameters.wordsAreNew = true
            return try await perform(
                KeyDoorProgram(act: .regenerateWords, mintsKeyFile: mints), parameters: parameters,
                secrets: ActSecrets(passphrase: nil, words: try WordsKey.derive(newWords)), library: &library)
        }
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
        // VX-447: only a SYNCED file-less library reaches here minting (unsynced, `verifiedPassphrase` found no lock to
        // open and refused above).
        return try await perform(
            KeyDoorProgram(act: .regenerateWords, mintsKeyFile: mints && parameters.accountID != nil),
            parameters: parameters,
            secrets: ActSecrets(passphrase: current, words: try WordsKey.derive(newWords)), library: &library)
    }

    /// **VX-447 — the key file is gone EVERYWHERE this Mac keeps one** (rule 27's after-open state — `Assess.repairs`'
    /// first `Fault.noKeyFileAnywhere` arm, read by the act itself; READS only): nothing at all in the live place (a
    /// stray — another key's file — is not this state: a mint would write over it, rule 21), no sealed mirror of the
    /// current key in what this Mac remembers (rule 1's restore is that one's road — every remembered item read as
    /// stated, so even an unverified copy refuses the mint), and no catalogued key file of this library carrying the
    /// current key (rule 21's offer is that one's road). A copy anywhere means its history is not lost: no fresh file.
    /// A throwing READ refuses. A remembered item whose payload this build cannot DECODE (a newer build's format, or
    /// damaged bytes) is SKIPPED, deliberately and logged (VX-308 ladder round 1, MINOR-1): it is read as no copy, exactly
    /// as the rest of the road reads it — the unlock reads this library's such item as nothing remembered, so the open's
    /// own repair (`refreshMemory`, rule 21's one-library rule) has already rewritten it and removed every other library's
    /// item before any door is reachable, and every act's begin rewrites it again; refusing here would protect no payload.
    func keyFileGoneEverywhere(_ library: UnlockedLibrary) throws -> Bool {
        guard library.keyFile == nil, try leaves.keyFiles.readLiveKeyFile() == nil,
              let libraryID = library.record?.libraryID else { return false }
        let current = library.fingerprint
        if library.memory?.keyFileMirror?.fingerprint == current { return false }
        for remembered in try leaves.memory.rememberedLibraryIDs() {
            guard let sealed = try leaves.memory.readMemory(libraryID: remembered) else { continue }
            guard let named = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) else {
                log("keyFileGoneEverywhere: a remembered item (\(remembered.prefix(8))) this build can't read — skipped, "
                    + "read as no copy")
                continue
            }
            if named.keyFileMirror?.fingerprint == current { return false }
        }
        return try !leaves.keyFiles.catalogedKeyFiles(ofLibrary: libraryID).contains { $0.fingerprint == current }
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
