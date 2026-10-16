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
//     this Mac, Move) RE-KEYS, in either mode: the new key's history takes the
//     old one, the anchor rides along unchanged; in Castle both secrets, in
//     Standard the passphrase typed or set new and the words typed or made
//     new; in Standard the new key under this Mac's EXISTING own Apple key
//     (minting nothing); the account's Apple key left alone; this Mac stops
//     using the old account (its sync keys forgotten — after the swap, the
//     record's binding being what governs).
//   - Signed out, This Mac Only carries a mode — Use Castle's or Use
//     Standard's crossing applied to this Mac only (§3.8's one plain road).
//   - JOINING: in the library's own mode the master's wrap is added and the
//     key stays (the passphrase copy re-wrapped under the account's, corner
//     27; an anchor untouched); joining a Castle account from Standard is
//     entering Castle (the re-key, own Apple keys retired, the old shared
//     key's checks); joining a Standard account from Castle is leaving Castle
//     (the anchor, a fresh own key, rule 5).
//   - SET UP SYNC (the first device): the account takes the library's mode;
//     Standard mints the account's fresh Apple key for the vault, and this
//     device's own for its key file if it has none.

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
        var steps: [String] = leaving && Self.rekeys(parameters) ? ["anchor"] : []
        if parameters.targetAccount != nil { steps.append("pickUpJoinKeys") }
        if Self.rekeys(parameters) {
            steps += LibraryRekey.steps(guards, mintsOwnAppleKey: leaving)
            steps += ["memory", "retireOldCustody"]
            if entering { steps += ["exportOff", "retireOwnAppleKeys", "retireOldSharedKey"] }
        } else {
            steps += ["joinKeyFile", "bindAccount", "memory"]
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
        case "anchor":
            guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(ctx.act) }
            try ctx.writeAnchor(.pressingDevice(passphrase: try ctx.requirePassphrase(), words: words))
        case "pickUpJoinKeys":
            try await ctx.pickUpKeys()
            // A Standard account's Apple key, as this device follows it.
            if let id = ctx.accountID.flatMap({ ctx.executor.freshVaults[$0] })?.format.appleKeyID,
               !ctx.library.section.appleKeys.contains(where: { $0.id == id }) {
                try ctx.updateSection {
                    $0.recordingAppleKey(AppleKeyRecord(id: id, purpose: .account, accountID: ctx.accountID, origin: .followed))
                }
            }
        case "mintOwnAppleKey": _ = try ctx.mintAppleKey(purpose: .library)
        case "custodyItem": try ctx.newCustodyItem(kind: to)
        case "keyFile":
            var apple: AppleKeyMaterial?
            if leaving { apple = try ctx.ownAppleKey() } else if to == .standard { apple = ctx.existingOwnAppleKey() }
            let crossing: KeyFileCrossing = leaving ? .leavingCastle : entering ? .enteringCastle(openers: ctx.anchorOpeners()) : .withinMode
            try ctx.newKeyFile(crossing, locks: try ctx.newLocks(passphrase: true, words: true, master: joining, apple: apple))
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: to)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: to) }
        case "memory":
            try ctx.rememberNewKey()
            if leaving { ctx.outcome.done.append(.ruleFive) }
            if ctx.parameters.forgetsAccount != nil { ctx.saySentence(.replacesWords) }
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: entering)
        case "exportOff": try ctx.turnExportOff()
        case "retireOwnAppleKeys": try ctx.retireOwnAppleKeys()
        case "retireOldSharedKey": try await ctx.retireOldSharedKey()
        case "joinKeyFile": try ctx.joinKeyFile()
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
        (parameters.newKind == .standard ? ["mintAccountAppleKey"] : []) + ["createVault", "joinKeyFile", "bindAccount", "backup"]
    }

    /// With no plan: bind only when the session's account's vault is the one
    /// this device's sync keys hold (its own creation); otherwise nothing.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["bindIfVaultIsOurs"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "mintAccountAppleKey": _ = try ctx.mintAppleKey(purpose: .account)
        case "createVault": try await ctx.createVault()
        case "joinKeyFile": try ctx.joinKeyFile()
        case "bindAccount":
            try ctx.bindAccount(ctx.parameters.targetAccount)
            if ctx.parameters.wordsAreNew == true { ctx.saySentence(.replacesWords) }
        case "bindIfVaultIsOurs": try await ctx.bindIfVaultIsOurs()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The account's vault, made: M, C, J minted; M under the passphrase and
    /// the words; Standard, M under the account's fresh Apple key. The new
    /// corpus key id is stamped in the plan before the write, so a resume
    /// knows its own vault. The sync keys held by the mode's rule.
    func createVault() async throws {
        guard let account = accountID else { throw ExecutorRefusal.noAccountSignedIn }
        if let existing = try await executor.readVault(accountID: account) {
            guard existing.corpusKeyID == parameters.newCorpusKeyID else { throw ActRollback(refusal: .nothingToDo) }
            try holdSyncKeys(try material(for: existing), castleWay: existing.mode != .standard(appleKeyID: existing.format.appleKeyID))
            return
        }
        let passphrase = try requirePassphrase()
        var apple = try parameters.accountAppleKeyID.flatMap { try leaves.apple.readAppleKey(id: $0) }
        if parameters.newKind == .standard, apple == nil {
            // The account key this act minted is gone — its keychain replaced or
            // reset, or the Apple ID switched, before iCloud Keychain carried it
            // — and no vault names it (none exists yet): one minter, a fresh
            // one, the lost id recorded retired (it wraps nothing). A resume
            // never sticks on it (VX-305 U4, the soak's seed 6).
            if let lost = parameters.accountAppleKeyID {
                try updateSection { $0.retiringAppleKey(id: lost, purpose: .account, accountID: account, origin: .minted, at: now) }
            }
            apple = try mintAppleKey(purpose: .account)
        }
        let (format, fresh) = try VaultModel.creating(
            passphrase: passphrase, words: secrets.words, apple: apple, device: deviceName, ids: leaves.ids)
        var stamped = parameters
        stamped.newCorpusKeyID = fresh.corpusKeyID
        plan.parameters = stamped
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        let written = try await leaves.vault.createVault(format, accountID: account, device: deviceName)
        executor.noteFresh(written)
        try holdSyncKeys(fresh, castleWay: parameters.newKind == .castle)
    }

    /// Joining in the library's own mode: the master's wrap (with its words
    /// copy) added to the live key file and the key kept; the passphrase copy
    /// re-wrapped under the account's (corner 27 — the anchor untouched);
    /// words made new replace the words lock; Standard, this device's own
    /// Apple key for its key file if it has none.
    func joinKeyFile() throws {
        guard var file = library.keyFile, file.fingerprint == library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        let locks = try newLocks(passphrase: secrets.passphrase != nil, words: secrets.words != nil, master: true)
        if let passphrase = locks.passphrase, file.passphrase?.kdf != passphrase.kdf {
            file = try file.settingPassphrase(passphrase, for: library.key)
        }
        if let words = locks.words { file = try file.settingWords(words, for: library.key) }
        if let master = locks.master { file = try file.settingMaster(master, wordsCopy: locks.masterWordsCopy, for: library.key) }
        if library.record?.mode == .standard, file.apple == nil {
            file = try file.settingApple(try mintAppleKey(purpose: .library), for: library.key)
        }
        try executor.writeLiveKeyFile(file, &library)
    }

    /// The record names the account (none, or one id) — written into the
    /// live library, and what this Mac remembers follows.
    func bindAccount(_ account: String?) throws {
        guard var record = library.record else { throw ExecutorRefusal.recordMissing }
        guard record.account != account else { return }
        record.account = account
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
              let snapshot = try await executor.readVault(accountID: account),
              let held = try ([.touchid, .silent] as [ProtectionNames.CustodyClass]).lazy
                .compactMap({ try self.leaves.syncKeys.readSyncKeys(accountID: account, itemClass: $0) }).first
                ?? leaves.syncKeys.sessionSyncKeys(accountID: account),
              held.corpusKeyID == snapshot.corpusKeyID
        else { return }
        material = held
        var next = parameters
        next.accountID = account
        plan.parameters = next
        try joinKeyFile()
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
        let secrets = try localSecrets(library, typed: typed, wordsMayBeNew: true, parameters: &parameters)
        return try await perform(SetUpSyncProgram(), parameters: parameters, secrets: secrets, typed: typed, library: &library)
    }

    /// **Enroll — join the signed-in account's vault**, by §3.8's joining
    /// rules. The account's passphrase and words, typed.
    public func enroll(_ library: inout UnlockedLibrary, typed: TypedSecrets, gate: GateStyle? = nil) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard record.account == nil else { throw ExecutorRefusal.nothingToDo }
        guard let account = configuration.session.accountID else { throw ExecutorRefusal.noAccountSignedIn }
        return try await join(.enroll, account: account, leaving: nil, library: &library, typed: typed, gate: gate)
    }

    /// **Move it to the signed-in account** — leave the record's account (a
    /// re-key), join this one.
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
        if vault.reading.rotationInProgress { throw ExecutorRefusal.rotationInProgress }
        let accountMode = vault.mode.settled ?? .castle
        let join = AssessRules.joinPlan(library: record.mode, vault: vault.reading)
        let rekeys = join != .sameMode || old != nil
        var parameters = ActParameters(
            gate: gate ?? library.section.settings.gateStyle ?? (leaves.biometry.biometry().enrolled ? .touchID : .alwaysAsk),
            synced: true, accountID: account, newKind: accountMode, targetAccount: account, changesAccount: true,
            outgoingAppleKeyID: library.keyFile?.apple?.keyID)
        parameters.fromKind = record.mode
        parameters.rekeys = rekeys
        parameters.forgetsAccount = old
        // The account's secrets, typed (both — §3.8's joining doors).
        guard let text = typed.passphrase, let words = typed.words else { throw ExecutorRefusal.secretMissing }
        try vault.format.kdf.validateFloor(configuration.floor)
        let passphrase = try PassphraseKey.derive(text, kdf: vault.format.kdf)
        let wordsKey = try WordsKey.derive(words)
        guard VaultModel.master(of: vault.format, passphrase: passphrase, words: nil) != nil else {
            throw ExecutorRefusal.passphraseDoesNotOpen
        }
        guard VaultModel.master(of: vault.format, passphrase: nil, words: wordsKey) != nil else {
            throw ExecutorRefusal.wordsDoNotOpen
        }
        parameters.passphraseKDF = passphrase.kdf
        parameters.typedSecret = "passphrase"
        return try await perform(
            AccountMoveProgram(act: act), parameters: parameters, secrets: ActSecrets(passphrase: passphrase, words: wordsKey),
            typed: typed, toKey: rekeys ? leaves.ids.mintLibraryKey() : nil, library: &library)
    }

    /// **The leaves** — This Mac Only, Stop syncing here, delete the account
    /// from this Mac: every leave re-keys, in either mode. `mode`: This Mac
    /// Only's one plain road while signed out may carry Use Castle's or Use
    /// Standard's crossing for this Mac only.
    public func leaveAccount(
        _ act: ProtectionAct, _ library: inout UnlockedLibrary, typed: TypedSecrets, mode: ProtectionMode? = nil,
        gate: GateStyle? = nil
    ) async throws -> ActOutcome {
        guard [.thisMacOnly, .stopSyncingHere, .deleteAccountHere].contains(act) else { throw ExecutorRefusal.nothingToDo }
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let old = record.account else { throw ExecutorRefusal.notSynced }
        if case .signedIn(let id, _) = configuration.session, id != old { throw ExecutorRefusal.otherAccountSignedIn }
        let to = act == .thisMacOnly ? (mode ?? record.mode) : record.mode
        var parameters = ActParameters(
            gate: gate ?? library.section.settings.gateStyle ?? (leaves.biometry.biometry().enrolled ? .touchID : .alwaysAsk),
            newKind: to, targetAccount: nil, changesAccount: true, outgoingAppleKeyID: library.keyFile?.apple?.keyID)
        parameters.fromKind = record.mode
        parameters.rekeys = guards.rekeyAtEveryCrossingOn || record.mode == .castle || to != record.mode
        parameters.forgetsAccount = old
        // In Castle both secrets (the words typed or made new); in Standard
        // the passphrase typed or set new, the words typed or made new.
        let secrets = try localSecrets(
            library, typed: typed, wordsMayBeNew: true, parameters: &parameters, passphraseMayBeNew: record.mode == .standard)
        return try await perform(
            AccountMoveProgram(act: act), parameters: parameters, secrets: secrets, typed: typed,
            toKey: parameters.rekeys == true ? leaves.ids.mintLibraryKey() : nil, library: &library)
    }

    /// Secrets checked against the live key file (no vault in the act): the
    /// passphrase typed — or, where `passphraseMayBeNew` (Standard's forgot
    /// road: this Mac holds the key) or there is none, set new; the words
    /// typed, or made new where allowed.
    func localSecrets(
        _ library: UnlockedLibrary, typed: TypedSecrets, wordsMayBeNew: Bool, parameters: inout ActParameters,
        passphraseMayBeNew: Bool = false
    ) throws -> ActSecrets {
        var secrets = ActSecrets()
        if let fresh = typed.newPassphrase, passphraseMayBeNew || library.keyFile?.passphrase == nil {
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
        if typed.wordsAreNew || library.keyFile?.words == nil {
            guard wordsMayBeNew || library.keyFile?.words == nil else { throw ExecutorRefusal.wordsMustBeTyped }
            secrets.words = try WordsKey.derive(words)
        } else {
            secrets.words = try verifiedWords(words, against: library.keyFile)
        }
        parameters.passphraseKDF = secrets.passphrase?.kdf
        parameters.wordsAreNew = typed.wordsAreNew
        return secrets
    }
}
