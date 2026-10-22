import CryptoKit
import Foundation

// VX-305 U3 — THE ACCOUNT ACTS (design §3.8, §3.9: "set up sync,
// enroll/join, connect/Move, This Mac Only, Stop syncing here, deleting the
// account from this Mac. As the proposal describes, each on a plan, ... with
// §3.8's rules: every leave re-keys"). One file for the account's family —
// set up sync, enroll, the three leaves and Move share their steps (a recorded
// refinement of §2's one-file-per-act, the family's rules being one table).
//   - THE RECORD NAMES THE ACCOUNT; signing in or out never changes it — only
//     these acts do.
//   - LEAVING AN ACCOUNT (This Mac Only, Stop syncing here, deleting it from
//     this Mac) CHANGES NONE OF THE LIBRARY'S KEYS OR SECRETS (rule 16): the
//     record stops naming the account and this Mac forgets that account's
//     sync keys — nothing else; the account's Apple key left alone. Move is
//     that leave plus a join. (The leave's re-key and This Mac Only's mode
//     crossing left with VX-378 U1 — rule 16; a crossing is Use Castle's or
//     Use Standard's own act once the library is local.)
//   - JOINING types ONE of the account's secrets (rule 14) and ADOPTS THE
//     ACCOUNT'S PAIR (rule 7: "a device holds one pair of secrets at a time"):
//     in the library's own mode the key stays and is re-locked — the typed
//     secret's lock replaced by the account's, the library's own other lock
//     dropped unless it is provably the account's, the master with its
//     twelve-words copy added (so both of the account's secrets open it) — and
//     the face is told when the words were replaced (`wordsReplacedByAccount`).
//     Joining a Castle account from Standard is entering Castle (the re-key,
//     own Apple keys retired); joining a Standard account from Castle is leaving
//     Castle (the re-key carrying the history, a fresh own key, rule 5) — one
//     posture at a time.
//   - SET UP SYNC (the first device) HANDS THE LIBRARY'S PAIR UP (rule 7): the
//     library's passphrase (set now if it has none — rule 3) and its words,
//     both typed and verified, never made new, become the vault's two locks
//     (rule 14: never Apple); the account takes the library's posture.

/// The account family's program — enroll, Move and the leaves.
struct AccountMoveProgram: ActProgram {
    let act: ProtectionAct

    static func crossing(_ parameters: ActParameters) -> (from: ProtectionMode, to: ProtectionMode) {
        let from = parameters.fromKind ?? .castle
        return (from, parameters.newKind ?? from)
    }

    static func rekeys(_ parameters: ActParameters) -> Bool { parameters.rekeys == true }

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        let (from, to) = Self.crossing(parameters)
        let leaving = from == .castle && to == .standard, entering = from == .standard && to == .castle
        var steps: [String] = []
        if parameters.targetAccount != nil { steps.append("pickUpJoinKeys") }
        if Self.rekeys(parameters) {
            steps += LibraryRekey.steps(guards, mintsOwnAppleKey: leaving)
            steps += ["memory", "retireOldCustody"]
            if entering { steps += ["exportOff", "retireOwnAppleKeys"] }
        } else if parameters.targetAccount != nil {
            steps += ["joinKeyFile", "bindAccount", "memory"]
        } else {
            // A leave (rule 16): the record stops naming the account — no key,
            // no lock, no secret changes.
            steps += ["bindAccount"]
        }
        if parameters.forgetsAccount != nil { steps.append("forgetOldSyncKeys") }
        return steps + ["backup"]
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }

    /// With no plan, past the swap: what this Mac remembers, the outgoing
    /// key's items, the old account's sync keys (the record no longer names
    /// it), a fresh pair.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] {
        ["memory", "retireOldCustody", "forgetUnboundSyncKeys", "backup"]
    }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let (from, to) = Self.crossing(ctx.parameters)
        let leaving = from == .castle && to == .standard, entering = from == .standard && to == .castle
        let joining = ctx.parameters.targetAccount != nil
        switch step {
        case "pickUpJoinKeys": try await ctx.pickUpKeys()
        case "mintOwnAppleKey": _ = try ctx.mintOwnAppleKey()
        case "custodyItem": try ctx.newCustodyItem(kind: to)
        case "keyFile":
            var apple: AppleKeyMaterial?
            if leaving { apple = try ctx.ownAppleKey() } else if to == .standard { apple = ctx.existingOwnAppleKey() }
            let locks = try ctx.newLocks(
                passphrase: ctx.secrets.passphrase != nil, words: ctx.secrets.words != nil, master: joining, apple: apple)
            try ctx.newKeyFile(rekeyTo: to, locks: locks)
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: to)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: to) }
        case "memory":
            try ctx.rememberNewKey()
            if leaving { ctx.outcome.done.append(.ruleFive) }
            if ctx.parameters.wordsReplaced == true, !ctx.outcome.notices.contains(.wordsReplacedByAccount) {
                ctx.outcome.notices.append(.wordsReplacedByAccount)
            }
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: entering)
        case "exportOff": try ctx.turnExportOff()
        case "retireOwnAppleKeys": try ctx.retireOwnAppleKeys()
        case "joinKeyFile": try await ctx.joinKeyFile()
        case "bindAccount": try ctx.bindAccount(ctx.parameters.targetAccount)
        case "forgetOldSyncKeys": try ctx.forgetSyncKeys(of: ctx.parameters.forgetsAccount)
        case "forgetUnboundSyncKeys": try ctx.forgetUnboundSyncKeys()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

/// SET UP SYNC — the first device of an account.
struct SetUpSyncProgram: ActProgram {
    let act = ProtectionAct.setUpSync

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        ["createVault", "joinKeyFile", "bindAccount", "backup"]
    }

    /// With no plan: bind only when the session's account's vault is the one
    /// this device's sync keys hold (its own creation); otherwise nothing.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["bindIfVaultIsOurs"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "createVault": try await ctx.createVault()
        case "joinKeyFile": try await ctx.joinKeyFile()
        case "bindAccount":
            try ctx.bindAccount(ctx.parameters.targetAccount)
        case "bindIfVaultIsOurs": try await ctx.bindIfVaultIsOurs()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The account's vault, made (rules 7, 14): a master and a sync key
    /// minted; the master under the library's passphrase and words — the pair
    /// handed up — and nothing else; the library's posture. The new sync key's
    /// id is stamped in the plan before the write, so a resume knows its own
    /// vault. The sync keys held by the mode's rule.
    func createVault() async throws {
        guard let account = accountID else { throw ExecutorRefusal.noAccountSignedIn }
        let existing: VaultSnapshot?
        do {
            existing = try await executor.readVault(accountID: account)
        } catch where ProtectionExecutor.vaultOutOfReach(error) {
            throw ActRollback(refusal: .vaultOutOfReach(account: account))
        }
        if let existing {
            guard existing.rowKeyID == parameters.newRowKeyID else { throw ActRollback(refusal: .nothingToDo) }
            try holdSyncKeys(try material(for: existing), castleWay: existing.mode == .castle)
            return
        }
        let passphrase = try requirePassphrase()
        guard let words = secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
        let mode = try parameters.newKind ?? requireRecord().mode
        let (vault, fresh) = try VaultModel.creating(
            passphrase: passphrase, words: words, mode: mode, device: deviceName, ids: leaves.ids)
        var stamped = parameters
        stamped.newRowKeyID = fresh.rowKeyID
        plan.parameters = stamped
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        let written = try await leaves.vault.createVault(vault, accountID: account, device: deviceName)
        executor.noteFresh(written)
        try holdSyncKeys(fresh, castleWay: mode == .castle)
    }

    /// **The key file adopts the account's pair** (rule 7), the key kept: the
    /// typed passphrase's lock is the account's (its descriptor the vault's);
    /// the library's own passphrase lock goes unless its descriptor is the
    /// vault's (one descriptor names one passphrase — it IS the account's); the
    /// typed words' lock is the account's, and at a join where the words weren't
    /// typed the library's own words lock goes; the master's lock with its
    /// twelve-words copy beside it, so both of the account's secrets open the
    /// file (rule 2). Standard, this device's own Apple key for its key file if
    /// it has none.
    func joinKeyFile() async throws {
        guard var file = library.keyFile, file.fingerprint == library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        // The vault's master and its words copy as the account holds them now —
        // read here when this session hasn't (a resume after a crash).
        if let account = accountID, executor.freshVaults[account] == nil { _ = try await freshRead() }
        let locks = try newLocks(passphrase: secrets.passphrase != nil, words: secrets.words != nil, master: true)
        let vaultKDF = accountID.flatMap { executor.freshVaults[$0] }?.vault.kdf
        if let passphrase = locks.passphrase {
            if file.passphrase?.kdf != passphrase.kdf { file = try file.settingPassphrase(passphrase, for: library.key) }
        } else if let vaultKDF, let own = file.passphrase, own.kdf != vaultKDF {
            file.passphrase = nil
        }
        // VX-462 (W-VX309-5): where the master's twelve-words copy is written it holds the very words typed (a join
        // verified them against the vault; a set-up made the vault from them), so the copy IS the words' road and no
        // own words lock is kept beside it — an own lock can never be proven the account's (`wordsAreTheAccountsAlready`),
        // and a re-join after a leave (rule 16 changes no lock) would say the words were replaced by the same words. With
        // no copy to write (the vault unread), the typed words keep their own lock, as before.
        if let words = locks.words, locks.masterWordsCopy == nil {
            file = try file.settingWords(words, for: library.key)
        } else if locks.words != nil || parameters.typedSecret != nil {
            file.words = nil
        }
        if let master = locks.master { file = try file.settingMaster(master, wordsCopy: locks.masterWordsCopy, for: library.key) }
        guard file.opensWithTheWords else { throw KeyFileError.noWordsLock }
        if library.record?.mode == .standard, file.apple == nil {
            file = try file.settingApple(try mintOwnAppleKey(), for: library.key)
        }
        try executor.writeLiveKeyFile(file, &library)
    }

    /// The record names the account (none, or one id) — written into the
    /// live library, and what this Mac remembers follows.
    func bindAccount(_ account: String?) throws {
        guard var record = library.record else { throw ExecutorRefusal.recordMissing }
        let rowKeyID = account == nil ? nil : (parameters.followedRowKeyID ?? parameters.newRowKeyID)
        guard record.account != account || record.accountRowKeyID != rowKeyID else { return }
        record.account = account
        record.accountRowKeyID = rowKeyID
        record = record.stampingPassphraseFact(keyFile: library.keyFile)
        try leaves.library.writeRecord(record, with: library.key)
        library.record = record
        try rememberNewKey()
    }

    /// This Mac stops using the old account: its sync keys forgotten (every
    /// class, and session memory).
    func forgetSyncKeys(of account: String?) throws {
        guard let account else { return }
        for item in try leaves.syncKeys.syncKeyItems() where item.accountID == account {
            try leaves.syncKeys.deleteSyncKeys(accountID: account, itemClass: item.itemClass)
        }
        leaves.syncKeys.holdInSession(nil, accountID: account)
    }

    /// With no plan: every sync-keys item for an account the record no longer
    /// names goes.
    func forgetUnboundSyncKeys() throws {
        let bound = library.record?.account
        for item in try leaves.syncKeys.syncKeyItems() where item.accountID != bound {
            try leaves.syncKeys.deleteSyncKeys(accountID: item.accountID, itemClass: item.itemClass)
        }
    }

    func bindIfVaultIsOurs() async throws {
        guard library.record?.account == nil, let account = executor.configuration.session.accountID,
              let snapshot = try? await executor.readVault(accountID: account),
              let held = try ([.touchid, .silent] as [ProtectionNames.CustodyClass]).lazy
                .compactMap({ try self.leaves.syncKeys.readSyncKeys(accountID: account, itemClass: $0) }).first
                ?? leaves.syncKeys.sessionSyncKeys(accountID: account),
              held.rowKeyID == snapshot.rowKeyID
        else { return }
        material = held
        var next = parameters
        next.accountID = account
        next.newRowKeyID = held.rowKeyID
        plan.parameters = next
        try await joinKeyFile()
        try bindAccount(account)
    }
}

extension ProtectionExecutor {
    /// **Set up sync** — the first device of an account (no vault yet): the
    /// account takes the library's mode.
    public func setUpSync(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard record.account == nil else { throw ExecutorRefusal.nothingToDo }
        guard let account = configuration.session.accountID else { throw ExecutorRefusal.noAccountSignedIn }
        if try await readVault(accountID: account) != nil { throw ExecutorRefusal.nothingToDo }
        var parameters = ActParameters(
            gate: library.section.settings.gateStyle, synced: true, accountID: account, newKind: record.mode,
            targetAccount: account, changesAccount: true)
        // Rule 7: the library's pair is handed up — typed and verified, the
        // words never made new.
        let secrets = try localSecrets(library, typed: typed, parameters: &parameters)
        return try await perform(SetUpSyncProgram(), parameters: parameters, secrets: secrets, typed: typed, library: &library)
    }

    /// **Enroll — join the signed-in account's vault**, by §3.8's joining
    /// rules. One of the account's secrets, typed (rule 14).
    public func enroll(_ library: inout UnlockedLibrary, typed: TypedSecrets, gate: GateStyle? = nil) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard record.account == nil else { throw ExecutorRefusal.nothingToDo }
        guard let account = configuration.session.accountID else { throw ExecutorRefusal.noAccountSignedIn }
        return try await join(.enroll, account: account, leaving: nil, library: &library, typed: typed, gate: gate)
    }

    /// **Move it to the signed-in account** — leave the record's account (no
    /// key change — rule 16), join this one.
    public func move(_ library: inout UnlockedLibrary, typed: TypedSecrets, gate: GateStyle? = nil) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let old = record.account else { throw ExecutorRefusal.notSynced }
        guard let account = configuration.session.accountID, account != old else { throw ExecutorRefusal.nothingToDo }
        return try await join(.move, account: account, leaving: old, library: &library, typed: typed, gate: gate)
    }

    func join(
        _ act: ProtectionAct, account: String, leaving old: String?, library: inout UnlockedLibrary, typed: TypedSecrets,
        gate: GateStyle?
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        let accountMode = vault.mode
        let join = AssessRules.joinPlan(library: record.mode, vault: vault.reading)
        // A key change only where the join crosses postures (rule 16: the leave
        // half changes nothing; rule 7: a same-posture join re-locks).
        let rekeys = join != .sameMode
        var parameters = ActParameters(
            gate: gate ?? library.section.settings.gateStyle ?? (leaves.biometry.biometry().enrolled ? .touchID : .alwaysAsk),
            synced: true, accountID: account, newKind: accountMode, targetAccount: account, changesAccount: true,
            outgoingAppleKeyID: library.keyFile?.apple?.keyID)
        parameters.fromKind = record.mode
        parameters.rekeys = rekeys
        parameters.forgetsAccount = old
        // ONE of the account's secrets, typed (rule 14) — either, or both.
        var secrets = ActSecrets()
        if let text = typed.passphrase {
            try vault.vault.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: passphrase, words: nil) != nil else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            secrets.passphrase = passphrase
        }
        if let words = typed.words {
            let wordsKey = try WordsKey.derive(words)
            guard VaultModel.master(of: vault.vault, passphrase: nil, words: wordsKey) != nil else {
                throw ExecutorRefusal.wordsDoNotOpen
            }
            secrets.words = wordsKey
        }
        guard !secrets.isEmpty else { throw ExecutorRefusal.secretMissing }
        parameters.passphraseKDF = secrets.passphrase?.kdf
        parameters.typedSecret = secrets.passphrase != nil ? "passphrase" : "words"
        // Rule 7's sentence: said unless the library's words already ARE the
        // account's — the words typed here open the library's own words lock
        // (they were its words all along), or (VX-309 U2 — VX-456) its key
        // file proves it by wrap identity (`wordsAreTheAccountsAlready`).
        let ownLockOpens = typed.words.map { words in (try? library.keyFile?.open(words: words)) != nil } ?? false
        let liveFile = library.keyFile?.fingerprint == library.fingerprint ? library.keyFile : nil
        let sameWords = ownLockOpens || Self.wordsAreTheAccountsAlready(
            liveFile, vault: vault.vault,
            master: VaultModel.master(of: vault.vault, passphrase: secrets.passphrase, words: secrets.words))
        parameters.wordsReplaced = !sameWords
        return try await perform(
            AccountMoveProgram(act: act), parameters: parameters, secrets: secrets,
            typed: typed, toKey: rekeys ? leaves.ids.mintLibraryKey() : nil, library: &library)
    }

    /// **VX-309 U2 — VX-456: the library's twelve words ARE the account's
    /// already**, proven from the files alone — by wrap identity, never by
    /// deriving or storing words (READS only): the key file of the library's
    /// key carries NO words lock of its own, its master's twelve-words copy IS
    /// the account's recovery wrap byte for byte (RFC 3394 is deterministic:
    /// the same words over the same master make the same bytes, and the copy
    /// is the vault's, copied — §3.5a), and the master lock beside it opens
    /// under the account's master (`master` — what the typed secret reached in
    /// the vault). Then the only words that open the library are the
    /// account's, and a join replaces nothing (rule 7's moment stays quiet). A
    /// file WITH a words lock of its own beside a matching copy proves
    /// nothing — a New Words made while the library was local re-makes the own
    /// lock and leaves the copy as it was — so it answers false and the moment
    /// speaks (a true sentence either way; PROVISIONAL P-VX309-U2-1).
    static func wordsAreTheAccountsAlready(_ file: KeyFile?, vault: AccountVault, master: SymmetricKey?) -> Bool {
        guard let file, file.words == nil, let copy = file.masterWordsCopy, copy == vault.masterByWords,
              let master, (try? file.open(master: master)) != nil
        else { return false }
        return true
    }

    /// **The leaves** — This Mac Only, Stop syncing here, delete the account
    /// from this Mac (rule 16): the record stops naming the account and this
    /// Mac forgets its sync keys; no key, lock or secret changes, so nothing is
    /// typed (PROVISIONAL P-VX378-U1-2 — the face may still confirm).
    public func leaveAccount(_ act: ProtectionAct, _ library: inout UnlockedLibrary) async throws -> ActOutcome {
        guard [.thisMacOnly, .stopSyncingHere, .deleteAccountHere].contains(act) else { throw ExecutorRefusal.nothingToDo }
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let old = record.account else { throw ExecutorRefusal.notSynced }
        if case .signedIn(let id, _) = configuration.session, id != old { throw ExecutorRefusal.otherAccountSignedIn }
        var parameters = ActParameters(newKind: record.mode, targetAccount: nil, changesAccount: true)
        parameters.fromKind = record.mode
        parameters.forgetsAccount = old
        return try await perform(AccountMoveProgram(act: act), parameters: parameters, secrets: ActSecrets(), library: &library)
    }

    /// Secrets checked against the live key file (no vault in the act): the
    /// passphrase typed — or, where there is none yet (rule 3), set new; the
    /// words TYPED and verified (rule 7: only creating a library shows fresh
    /// words).
    func localSecrets(
        _ library: UnlockedLibrary, typed: TypedSecrets, parameters: inout ActParameters
    ) throws -> ActSecrets {
        var secrets = ActSecrets()
        guard !typed.wordsAreNew else { throw ExecutorRefusal.wordsMustBeTyped }
        if let fresh = typed.newPassphrase, library.keyFile?.passphrase == nil {
            secrets.passphrase = try freshPassphrase(fresh)
            parameters.passphraseIsNew = true
        } else if library.keyFile?.passphrase != nil {
            secrets.passphrase = try verifiedPassphrase(typed.passphrase, against: library.keyFile)
        } else {
            guard let text = typed.passphrase else { throw ExecutorRefusal.secretMissing }
            secrets.passphrase = try freshPassphrase(text)
            parameters.passphraseIsNew = true
        }
        guard let words = typed.words else { throw ExecutorRefusal.secretMissing }
        // Rule 2: verified — never adopted unverified (the no-words arm left
        // with VX-378 U1).
        secrets.words = try verifiedWords(words, against: library.keyFile)
        parameters.passphraseKDF = secrets.passphrase?.kdf
        parameters.wordsAreNew = typed.wordsAreNew
        return secrets
    }
}
