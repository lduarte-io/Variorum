import CryptoKit
import Foundation

// VX-305 U3 — THE PLAN RUNNER (design §3.6, §3.9): begin → steps → end, the
// resume from the first unfinished step, and — with no plan to resume — the
// roll back before the commit point or the finish from the record after it.
// Each act is an `ActProgram` (one file per act under `Acts/`); this file is
// the machinery they share.

/// What an act's press, door or plan ended in.
public struct ActOutcome: Equatable, Sendable {
    public var act: ProtectionAct
    /// The key the library is under at the end.
    public var fingerprint: String
    /// A follow that picked up the keys and holds its library's re-key while
    /// the vault reads a rotation in progress (§3.9).
    public var held: Bool
    public var notices: [ActNotice]
    /// The Done's typed words (rule 5's sentence after a leave).
    public var done: [Words]

    public init(act: ProtectionAct, fingerprint: String, held: Bool = false, notices: [ActNotice] = [], done: [Words] = []) {
        self.act = act
        self.fingerprint = fingerprint
        self.held = held
        self.notices = notices
        self.done = done
    }
}

/// The notices an act leaves (phase 4/5 render them).
public enum ActNotice: Equatable, Sendable {
    /// Entering Castle turned this device's scheduled Markdown export off.
    case scheduledExportTurnedOff
    /// A follow that holds its library re-key while the rotation finishes.
    case heldForRotation
}

/// What the open's settle did with an act in flight.
public enum SettleOutcome: Equatable, Sendable {
    case nothingInFlight
    /// The plan this Mac's section names resumed from its first unfinished
    /// step and finished.
    case resumed(ActOutcome)
    /// No usable plan, past the commit point: the act's fixed remaining
    /// steps ran from the record.
    case finishedFromRecord(ActOutcome)
    /// No usable plan, before the commit point: the act rolled back.
    case rolledBack(ProtectionAct)
    /// THE ACT NAMED AND WAITING (her ruling 2026-10-14/15, the soak's seed
    /// 2): a synced act past its commit point whose account's vault can't be
    /// reached this session — signed out, signed into another account, or
    /// offline. It stays in flight, named by this Mac's section and its plan;
    /// the library is open, sync waits, copies stay paused; it finishes at the
    /// next vault reach (signing in here — or another device of the account
    /// finishes the rotation). Before the commit point the act rolled back
    /// instead. The face ("Finish leaving Castle — sign in to finish") is
    /// phase 3/4's.
    case waiting(ProtectionAct, account: String)
}

/// A resume stopped for a vault it can't reach, past its commit point.
struct ActWaiting: Error {
    var act: ProtectionAct
    var account: String
}

/// A step's way of saying the act must roll back now (before its commit
/// point): the account moved elsewhere before this device's first write, or a
/// resume no longer holds what only the press had (a copy's key).
struct ActRollback: Error {
    var refusal: ExecutorRefusal
}

/// The act rolled back (`drive` caught an `ActRollback` and undid it).
struct ActRolledBack: Error {
    var act: ProtectionAct
    var refusal: ExecutorRefusal
}

/// **One act's program.**
protocol ActProgram {
    var act: ProtectionAct { get }
    /// The act reads or re-keys the live key file — it never begins without
    /// one of the current key (it would refuse inside its plan, leaving the
    /// act in flight with nothing able to finish it — VX-305 U4).
    var needsLiveKeyFile: Bool { get }
    /// The steps, in order, for these parameters.
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String]
    /// The steps that write anything for the act's NEW key — reset when the
    /// key has to be minted afresh (nothing of it was durable).
    func newKeySteps(_ parameters: ActParameters) -> Set<String>
    /// The steps a plan-less finish runs after the commit point — derivable
    /// from the record alone, idempotent, needing no secret.
    func finishingSteps(_ library: UnlockedLibrary) -> [String]
    func run(_ step: String, _ ctx: ActContext) async throws
}

extension ActProgram {
    var needsLiveKeyFile: Bool {
        switch act {
        case .deviceSettings, .touchIDRearm, .offerDelete, .plaintextExport, .land,
             .createLibrary:
            return false
        default:
            return true
        }
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { [] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { [] }
}

/// The act's state while it runs — the library as the act changes it, the
/// plan, the secrets in hand (never stored), the new key, the sync keys.
public final class ActContext {
    unowned let executor: ProtectionExecutor
    var library: UnlockedLibrary
    var plan: ProtectionPlan
    var secrets: ActSecrets
    /// The words as typed, for the act's span only (a resume opens the new
    /// key's file by the words road).
    var typedWords: [String]?
    var toKey: StoreKey?
    /// The outgoing key, held from the begin for the act's span.
    var heldFromKey: StoreKey?
    /// The account's sync keys in hand (custody, session memory, or the vault).
    var material: DeviceKeyMaterial?
    var outcome: ActOutcome
    /// A resume after a relaunch (no press made the item a door would).
    let resuming: Bool

    init(
        executor: ProtectionExecutor, library: UnlockedLibrary, plan: ProtectionPlan, secrets: ActSecrets,
        typed: TypedSecrets?, toKey: StoreKey?, resuming: Bool
    ) {
        self.executor = executor
        self.library = library
        self.plan = plan
        self.secrets = secrets
        self.typedWords = typed?.words
        self.toKey = toKey
        if library.fingerprint == plan.fromFingerprint { self.heldFromKey = library.key }
        self.resuming = resuming
        self.outcome = ActOutcome(act: plan.act, fingerprint: library.fingerprint)
    }

    var leaves: ExecutorLeaves { executor.leaves }
    var parameters: ActParameters { plan.parameters ?? ActParameters() }
    var act: ProtectionAct { plan.act }
    var now: Date { executor.now() }
    var floor: PassphraseKDF.Floor { executor.configuration.floor }
    func log(_ line: String) { executor.log("\(act.rawValue): \(line)") }

    func requireRecord() throws -> ProtectionRecord {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        return record
    }

    func requireToKey() throws -> StoreKey {
        guard let toKey else { throw ExecutorRefusal.secretsRequired(act) }
        return toKey
    }

    func requirePassphrase() throws -> PassphraseKey {
        guard let passphrase = secrets.passphrase else { throw ExecutorRefusal.secretsRequired(act) }
        return passphrase
    }

    /// A held follow (or any act with nothing more to do): every remaining
    /// step is marked done without running.
    func skipRemaining() {
        for index in plan.steps.indices { plan.steps[index].done = true }
    }

    /// This Mac's facts, changed and written (the record's section, then what
    /// this Mac remembers).
    func updateSection(_ change: (DeviceSection) -> DeviceSection) throws {
        try executor.writeFacts(&library, section: change(library.section))
    }
}

extension ProtectionExecutor {
    /// The program for an act (the registry).
    static func program(for act: ProtectionAct) -> any ActProgram {
        switch act {
        case .enterCastle: return EnterCastleProgram()
        case .leaveCastle: return LeaveCastleProgram()
        case .replaceAllKeys: return ReplaceAllKeysProgram()
        case .follow: return FollowProgram()
        case .land: return LandProgram()
        case .sendLibrary: return SendLibraryProgram()
        case .createLibrary: return CreateLibraryProgram()
        case .setUpSync: return SetUpSyncProgram()
        case .enroll, .move, .thisMacOnly, .stopSyncingHere, .deleteAccountHere: return AccountMoveProgram(act: act)
        case .changePassphrase, .resetPassphrase, .regenerateWords: return KeyDoorProgram(act: act)
        case .deviceSettings: return DeviceSettingsProgram()
        case .touchIDRearm: return TouchIDRearmProgram()
        case .offerDelete: return OfferDeleteProgram()
        case .plaintextExport: return PlaintextExportProgram()
        }
    }

    // MARK: - Begin, drive, end

    /// **Begin and run an act.** `toKey`: the new library key a re-key mints
    /// at its press (named in the act in flight from the first write).
    func perform(
        _ program: any ActProgram, parameters: ActParameters, secrets: ActSecrets, typed: TypedSecrets? = nil,
        toKey: StoreKey? = nil, library: inout UnlockedLibrary
    ) async throws -> ActOutcome {
        guard library.record != nil else { throw ExecutorRefusal.recordMissing }
        if let inFlight = library.section.actInFlight { throw ExecutorRefusal.actInFlight(inFlight.act) }
        if program.needsLiveKeyFile, library.keyFile?.fingerprint != library.fingerprint { throw ExecutorRefusal.noLiveKeyFile }
        let at = now()
        var parameters = parameters
        if toKey != nil, let outgoing = library.keyFile, outgoing.fingerprint == library.fingerprint {
            parameters.outgoingKeyFile = outgoing
        }
        let (section, sequence) = library.section.beginningAct(
            program.act, from: library.fingerprint, to: toKey.map(Self.fp), fromKind: library.record?.mode, at: at)
        // The act in flight, named in this Mac's section FIRST: a crash before
        // the plan lands leaves an act with no plan — rolled back at the open.
        try writeFacts(&library, section: section)
        let plan = ProtectionPlan(
            libraryID: libraryID, deviceID: section.deviceID, sequence: sequence, act: program.act,
            fromFingerprint: library.fingerprint, toFingerprint: toKey.map(Self.fp),
            steps: program.steps(parameters, guards: guards).map { PlanStep(name: $0) }, createdAt: at,
            parameters: parameters)
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        log("\(program.act.rawValue): begun #\(sequence) \(Self.fp8(library.fingerprint)) → \(Self.fp8(toKey.map(Self.fp)))")
        let ctx = ActContext(
            executor: self, library: library, plan: plan, secrets: secrets, typed: typed, toKey: toKey,
            resuming: false)
        defer { library = ctx.library }
        do {
            try await drive(program, ctx)
        } catch let rolledBack as ActRolledBack {
            throw rolledBack.refusal
        }
        return ctx.outcome
    }

    /// Run the plan from its first unfinished step to the end.
    func drive(_ program: any ActProgram, _ ctx: ActContext) async throws {
        while let index = ctx.plan.firstUnfinishedStep {
            let step = ctx.plan.steps[index].name
            do {
                try await program.run(step, ctx)
            } catch let stop as ActRollback {
                try dropUnlandedAccountKey(ctx)
                try rollBack(&ctx.library, act: ctx.act, outgoingKeyFile: ctx.plan.parameters?.outgoingKeyFile)
                throw ActRolledBack(act: ctx.act, refusal: stop.refusal)
            }
            if ctx.plan.firstUnfinishedStep == index { ctx.plan.steps[index].done = true }
            try leaves.plans.writePlan(try ctx.plan.sealed(under: ctx.library.key))
        }
        try endAct(ctx)
    }

    /// The act ends: cleared in this Mac's section, the plan deleted, copies
    /// resume.
    func endAct(_ ctx: ActContext) throws {
        let sequence = ctx.plan.sequence
        if ctx.library.section.actInFlight?.sequence == sequence {
            try ctx.updateSection { $0.endingAct(sequence: sequence) }
        }
        try leaves.plans.deletePlan()
        leaves.backups.resumeCopies()
        ctx.outcome.fingerprint = ctx.library.fingerprint
        log("\(ctx.act.rawValue): done #\(sequence) under \(Self.fp8(ctx.library.fingerprint))")
    }

    // MARK: - Settle: what an open does with an act in flight

    /// **At open, after unlock**: an act this Mac's section names resumes
    /// from its plan; with no plan it you can trust, it rolls back before its
    /// commit point or finishes from the record after it. A plan nothing names
    /// is ignored, reported and deleted. `typed`: the secrets a resume may
    /// need (a plan never holds one).
    public func settle(_ library: inout UnlockedLibrary, typed: TypedSecrets = .none) async throws -> SettleOutcome {
        let sealed = try leaves.plans.readPlan()
        let reach = reach(key: library.key, keyFile: library.keyFile)
        func verified() -> ProtectionPlan? {
            guard let sealed, let plan = try? sealed.open(purpose: .plan, libraryID: libraryID, reach: reach),
                  plan.libraryID == libraryID else { return nil }
            return plan
        }
        guard let inFlight = library.section.actInFlight else {
            if sealed != nil {
                if !guards.planNamedBySectionOn, let plan = verified() {
                    // Guard off (DEBUG mutation pins only): a plan nothing
                    // names resumes — the planted and the replayed plan.
                    return .resumed(try await resume(plan, &library, typed: typed))
                }
                // (A plan nothing here names never restores a key file — the
                // restore for an act no identity here resumes left with VX-378
                // U1, rules 21 and 23.)
                leaves.diagnostics.report(.planIgnored(.noActInFlight))
                log("settle: a plan this Mac's section doesn't name — ignored")
                try leaves.plans.deletePlan()
            }
            // A staged file exists only between an act's stage and its swap; with
            // nothing of this device in flight it is debris (an act no plan of
            // this identity can resume — a Mac replaced mid-act) and goes
            // (promise 6 — VX-305 U4, found by the scenario world).
            if try leaves.library.stagedFingerprint() != nil {
                try leaves.library.discardStaged()
                log("settle: a staged file with nothing in flight — discarded")
            }
            return .nothingInFlight
        }
        var resumable: ProtectionPlan?
        if sealed != nil {
            if let plan = verified() {
                if plan.isNamed(by: library.section) || !guards.planNamedBySectionOn {
                    resumable = plan
                } else {
                    leaves.diagnostics.report(.planIgnored(.notNamed))
                    log("settle: the plan on disk is not the one this Mac's section names — ignored")
                }
            } else {
                leaves.diagnostics.report(.planIgnored(.unsealed))
                log("settle: the plan on disk fails its seal — ignored")
            }
        }
        if let resumable {
            do {
                return .resumed(try await resume(resumable, &library, typed: typed))
            } catch let rolledBack as ActRolledBack {
                return .rolledBack(rolledBack.act)
            } catch let waiting as ActWaiting {
                log("settle: \(waiting.act.rawValue) waits for its account's vault — named, copies paused")
                return .waiting(waiting.act, account: waiting.account)
            }
        }
        // No plan to trust. Past the commit point (the library opens under
        // the act's new key, or the act re-keys nothing): finish from the
        // record. Before it: roll back.
        let program = Self.program(for: inFlight.act)
        let committed = inFlight.toFingerprint == nil || inFlight.toFingerprint == library.fingerprint
        guard committed else {
            try rollBack(&library, act: inFlight.act)
            return .rolledBack(inFlight.act)
        }
        let plan = ProtectionPlan(
            libraryID: libraryID, deviceID: library.section.deviceID, sequence: inFlight.sequence, act: inFlight.act,
            fromFingerprint: inFlight.fromFingerprint, toFingerprint: inFlight.toFingerprint,
            steps: program.finishingSteps(library).map { PlanStep(name: $0) }, createdAt: now(),
            parameters: ActParameters(accountID: library.record?.account))
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        leaves.diagnostics.report(.actFinishedFromRecord(inFlight.act))
        log("settle: \(inFlight.act.rawValue) finishes from the record (no plan, past its commit point)")
        let ctx = ActContext(
            executor: self, library: library, plan: plan, secrets: ActSecrets(), typed: nil,
            toKey: library.key, resuming: true)
        defer { library = ctx.library }
        try await drive(program, ctx)
        return .finishedFromRecord(ctx.outcome)
    }

    /// The vault this session can't reach — signed out, signed into another
    /// account, offline.
    static func vaultOutOfReach(_ error: Error) -> Bool {
        switch error {
        case ExecutorRefusal.vaultOutOfReach, ExecutorRefusal.needsFreshVault: return true
        case VaultRefusal.unreachable, VaultRefusal.notSignedIn: return true
        default: return false
        }
    }

    func resume(_ plan: ProtectionPlan, _ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        let program = Self.program(for: plan.act)
        // Copies pause from the prepare to the swap (§3.9) — and a resume of a
        // re-key not yet swapped pauses them again: the pause is this process's
        // and a crash took it, so a resume that started past the prepare ran
        // with copies on, and one that then waited left them on (her ruling:
        // while it waits, copies stay paused — VX-305 U4).
        if let to = plan.toFingerprint, library.fingerprint != to { leaves.backups.pauseCopies() }
        let secrets = try derive(typed, under: plan.parameters?.passphraseKDF, newPassphrase: plan.parameters?.passphraseIsNew == true)
        // The passphrase typed at a resume must be the press's: every lock
        // under the plan's descriptor that this Mac holds opens with it. One
        // descriptor names one passphrase (the route finder's `.current` rests
        // on it) — a different passphrase derived under it would make the
        // lines lie (promise 9 — VX-305 U4, found by the scenario world).
        if let derived = secrets.passphrase, let kdf = plan.parameters?.passphraseKDF {
            let locks = [library.keyFile, library.memory?.keyFileMirror].compactMap { $0 }.filter { $0.passphrase?.kdf == kdf }
            if !locks.isEmpty,
               !locks.contains(where: { (try? $0.open(passphrase: .passphraseKey(derived), floor: configuration.floor)) != nil }) {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
        }
        let ctx = ActContext(
            executor: self, library: library, plan: plan, secrets: secrets, typed: typed, toKey: nil,
            resuming: true)
        defer { library = ctx.library }
        log("\(plan.act.rawValue): resumes #\(plan.sequence) at step \(plan.firstUnfinishedStep.map(String.init) ?? "end")")
        var waitsFor: String?
        if plan.parameters?.synced == true, let account = ctx.accountID {
            // A synced act resumes from the vault as it stands now.
            do {
                let vault = try await readVault(accountID: account)
                // …and a passphrase derived under the vault's own descriptor must
                // open the vault (the press's did — one descriptor, one passphrase).
                if let vault, let derived = secrets.passphrase, derived.kdf == vault.format.kdf,
                   VaultModel.master(of: vault.format, passphrase: derived, words: nil) == nil {
                    throw ExecutorRefusal.passphraseDoesNotOpen
                }
            } catch where Self.vaultOutOfReach(error) {
                // Her ruling 2026-10-14/15: before the commit point — the
                // rotation's first write never begun, the library not swapped —
                // the act ROLLS BACK (nothing account-side happened); past it,
                // it runs what needs no vault and WAITS, named, for the rest.
                guard plan.pastCommitPoint(libraryFingerprint: ctx.library.fingerprint) else {
                    try dropUnlandedAccountKey(ctx)
                    try rollBack(&ctx.library, act: plan.act, outgoingKeyFile: plan.parameters?.outgoingKeyFile)
                    throw ActRolledBack(act: plan.act, refusal: .vaultOutOfReach(account: account))
                }
                waitsFor = account
            }
        }
        do {
            try reachNewKey(ctx, program)
            try await drive(program, ctx)
        } catch where waitsFor != nil && Self.vaultOutOfReach(error) {
            throw ActWaiting(act: plan.act, account: waitsFor!)
        }
        return ctx.outcome
    }

    /// The act's new key on a resume: the library already under it; its
    /// custody item; its key file, opened with the secrets in hand. If
    /// nothing of it was ever made durable (no item, its file not written),
    /// the act's new-key steps restart under a freshly minted key.
    func reachNewKey(_ ctx: ActContext, _ program: any ActProgram) throws {
        guard let to = ctx.plan.toFingerprint else { return }
        if ctx.library.fingerprint == to { ctx.toKey = ctx.library.key; return }
        let items = try leaves.custody.custodyItems()
        for itemClass in [ProtectionNames.CustodyClass.silent, .touchid]
        where items.contains(CustodyItemFact(fingerprint: to, itemClass: itemClass)) {
            if let key = try leaves.custody.readCustody(fingerprint: to, itemClass: itemClass), Self.fp(key) == to {
                ctx.toKey = key
                return
            }
        }
        if let live = ctx.library.keyFile, live.fingerprint == to {
            if let passphrase = ctx.secrets.passphrase,
               let key = try? live.open(passphrase: .passphraseKey(passphrase), floor: configuration.floor) {
                ctx.toKey = key
                return
            }
            if let words = ctx.typedWords, let key = try? live.open(.words(words), floor: configuration.floor) {
                ctx.toKey = key
                return
            }
            throw ExecutorRefusal.secretsRequired(ctx.act)
        }
        // Nothing of the new key is durable: mint afresh, rename the act.
        let fresh = leaves.ids.mintLibraryKey()
        let freshFingerprint = Self.fp(fresh)
        let reset = program.newKeySteps(ctx.parameters)
        for index in ctx.plan.steps.indices where reset.contains(ctx.plan.steps[index].name) {
            ctx.plan.steps[index].done = false
        }
        ctx.plan.toFingerprint = freshFingerprint
        try ctx.updateSection { section in
            var next = section.bumped()
            next.actInFlight?.toFingerprint = freshFingerprint
            return next
        }
        try leaves.plans.writePlan(try ctx.plan.sealed(under: ctx.library.key))
        ctx.toKey = fresh
        log("\(ctx.act.rawValue): the new key was never made durable — re-minted \(Self.fp8(freshFingerprint))")
    }

    // MARK: - Roll back (before the commit point)

    /// Two devices minted for one account and the vault's CAS kept the other's
    /// (§3.5): the key this act minted, which the vault does not name, is
    /// deleted and recorded retired — it wraps nothing.
    func dropUnlandedAccountKey(_ ctx: ActContext) throws {
        guard let minted = ctx.parameters.accountAppleKeyID, let account = ctx.accountID else { return }
        if freshVaults[account]?.format.appleKeyID == minted { return }
        try leaves.apple.deleteAppleKey(id: minted)
        try ctx.updateSection {
            $0.retiringAppleKey(id: minted, purpose: .account, accountID: account, origin: .minted, at: now())
        }
    }

    /// Undo an act that never reached its commit point: the staged file
    /// discarded, the live key file restored from the sealed mirror when the
    /// act had replaced it, the new key's custody items deleted (a key the
    /// library never had), an own Apple key the act minted that wraps
    /// nothing retired (a Castle library — every other own key was retired at
    /// its entry), the act cleared in this Mac's section, the plan deleted.
    /// `outgoingKeyFile`: the copy the act's plan carried — the restore's
    /// source when the memory's mirror is gone (a wiped keychain — VX-305 U4,
    /// the soak's seed 18).
    func rollBack(_ library: inout UnlockedLibrary, act: ProtectionAct, outgoingKeyFile: KeyFile? = nil) throws {
        guard let inFlight = library.section.actInFlight else { return }
        try leaves.library.discardStaged()
        let live = try liveFormat3()
        let restore = [library.memory?.keyFileMirror, outgoingKeyFile].compactMap { $0 }
            .first { $0.fingerprint == library.fingerprint }
        if let live, live.fingerprint != library.fingerprint, let restore {
            try writeLiveKeyFile(restore, &library)
        } else {
            library.keyFile = live
        }
        // (A key the library never had: neither the current key nor one the
        // live file's history holds — rule 4; the family tree left with
        // VX-378 U1.)
        if let to = inFlight.toFingerprint, to != library.fingerprint,
           !(library.keyFile?.heldFingerprints.contains(to) ?? false) {
            for item in try leaves.custody.custodyItems() where item.fingerprint == to {
                try leaves.custody.deleteCustody(fingerprint: item.fingerprint, itemClass: item.itemClass)
            }
        }
        var section = library.section.endingAct(sequence: inFlight.sequence)
        if library.record?.mode == .castle {
            let wrapped = library.keyFile?.apple?.keyID
            for id in section.ownLibraryAppleKeyIDsToRetire where id != wrapped {
                try leaves.apple.deleteAppleKey(id: id)
                section = section.retiringAppleKey(id: id, purpose: .library, origin: .minted, at: now())
            }
        }
        try writeFacts(&library, section: section)
        try leaves.plans.deletePlan()
        leaves.backups.resumeCopies()
        leaves.diagnostics.report(.actRolledBack(act))
        log("\(act.rawValue): rolled back #\(inFlight.sequence) — the library stays under \(Self.fp8(library.fingerprint))")
    }

    // MARK: - Secrets

    /// Derive typed secrets for a resume: the passphrase under the act's own
    /// descriptor (the door's, reused — or a new passphrase's fresh one); the
    /// words as typed.
    func derive(_ typed: TypedSecrets, under kdf: PassphraseKDF.Descriptor?, newPassphrase: Bool) throws -> ActSecrets {
        var secrets = ActSecrets()
        let text = newPassphrase ? (typed.newPassphrase ?? typed.passphrase) : typed.passphrase
        if let text, let kdf {
            try kdf.validateFloor(configuration.floor)
            secrets.passphrase = try PassphraseKey.derive(text, kdf: kdf)
        }
        if let words = typed.words { secrets.words = try WordsKey.derive(words) }
        return secrets
    }

    /// The typed passphrase, derived under the descriptor of the lock it must
    /// open (the live key file's), and verified there.
    func verifiedPassphrase(_ typed: String?, against file: KeyFile?) throws -> PassphraseKey {
        guard let typed else { throw ExecutorRefusal.secretMissing }
        guard let wrap = file?.passphrase else { throw ExecutorRefusal.passphraseDoesNotOpen }
        try wrap.kdf.validateFloor(configuration.floor)
        let key = try PassphraseKey.derive(typed, kdf: wrap.kdf)
        guard let file, (try? file.open(passphrase: .passphraseKey(key), floor: configuration.floor)) != nil else {
            throw ExecutorRefusal.passphraseDoesNotOpen
        }
        return key
    }

    /// The typed words, verified against the file's words road.
    func verifiedWords(_ typed: [String]?, against file: KeyFile?) throws -> WordsKey {
        guard let typed else { throw ExecutorRefusal.secretMissing }
        guard let file, (try? file.open(.words(typed), floor: configuration.floor)) != nil else {
            throw ExecutorRefusal.wordsDoNotOpen
        }
        return try WordsKey.derive(typed)
    }

    /// A NEW passphrase: always a fresh descriptor (U2's hand-forward — the
    /// route finder's `.current` reading rests on it).
    func freshPassphrase(_ typed: String) throws -> PassphraseKey {
        try PassphraseKey.derive(typed, kdf: leaves.ids.mintPassphraseKDF())
    }
}
