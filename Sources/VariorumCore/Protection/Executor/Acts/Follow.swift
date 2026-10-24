import CryptoKit
import Foundation

// VX-305 U3 — THE FOLLOW (rules 10, 12, 15; design §3.9): the account's posture
// or sync key changed on another device, and this one follows — on a plan
// carrying every fact a resume needs; no follow waits on an Apple key.
//   - INTO CASTLE (rule 10: "each typing a secret once"): the new master from
//     the vault by the typed secret (the passphrase or the words); a new Castle
//     key (a Touch ID item made at this press where this device's gate style
//     says so, or none), its history taking every older key; every own Apple key
//     deleted and recorded retired; the scheduled export off, with one notice.
//   - OUT OF CASTLE (rule 12: "other devices follow out quietly, with a
//     notice"): nothing typed — the leave changed no key, so the keys this
//     device holds still open the vault; a new Standard key (its silent item,
//     this Mac's own FRESH Apple key) whose history carries the Castle key and
//     every key before it (rule 4); the Castle key's Touch ID item goes with its
//     key; rule 5's sentence, and the notice.
//   - KEYS REPLACED, same posture: a device that lagged through an entry into
//     Castle catches up — one secret, the new master; the history grows.
// A follower's new key file is locked under the secret it typed (if any) and
// under the new master, with that master's twelve-words copy beside it (old
// design §3.5a — so both secrets open it: the words through the copy, the
// passphrase directly or through the vault) — plus, in Standard, this Mac's own
// Apple key. (The follower's anchor, its typed lock and the finish of a stuck
// leave left with VX-378 U1 — rules 4, 12; the rotation it helped and held for
// with VX-378 U2 — rule 15.)

struct FollowProgram: ActProgram {
    let act = ProtectionAct.follow

    /// VX-529 — the pair catch-up's name in the plan's existing free-form `follow` field: the act in flight stays
    /// `.follow`, so no new stored act value exists for any build to meet (the architect's ruling, Shape A; R-510-20).
    static let pairChangedName = "pairChanged"

    /// VX-529: this plan is the follow's third kind — a RE-LOCK, never a re-key (`PairCatchUp`).
    static func isPairCatchUp(_ parameters: ActParameters) -> Bool { parameters.follow == pairChangedName }

    static func kind(_ parameters: ActParameters) -> FollowKind {
        switch parameters.follow {
        case "intoCastle": return .intoCastle
        case "intoStandard": return .intoStandard
        // VX-529: the halves that moved are read from the vault at the act's own step — never stored in the plan.
        case Self.pairChangedName: return .pairChanged(passphrase: false, words: false)
        default: return .keysReplaced
        }
    }

    static func name(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle: return "intoCastle"
        case .intoStandard: return "intoStandard"
        case .keysReplaced: return "keysReplaced"
        case .pairChanged: return pairChangedName
        }
    }

    static func afterCommit(_ kind: FollowKind) -> [String] {
        switch kind {
        case .intoCastle: return ["memory", "retireOldCustody", "exportOff", "retireOwnAppleKeys", "backup"]
        case .intoStandard, .keysReplaced: return ["memory", "retireOldCustody", "backup"]
        // VX-529: a re-lock (no new key — nothing to retire, no swap): what this Mac remembers follows the re-locked
        // file (the pair catch-up's own steps are `PairCatchUp`'s).
        case .pairChanged: return PairCatchUp.finishingSteps
        }
    }

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        if Self.isPairCatchUp(parameters) { return PairCatchUp.steps }
        let kind = Self.kind(parameters)
        return ["pickUpKeys"] + LibraryRekey.steps(guards, mintsOwnAppleKey: kind == .intoStandard) + Self.afterCommit(kind)
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }

    /// With no plan: the kind read from the act in flight — the library's mode
    /// when the act began against the record's now.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] {
        // VX-529: a follow whose act in flight names NO new key re-keys nothing — the pair catch-up (every other kind
        // mints one at its press): its finish is what this Mac remembers, nothing else.
        if let inFlight = library.section.actInFlight, inFlight.toFingerprint == nil { return PairCatchUp.finishingSteps }
        guard let fromKind = library.section.actInFlight?.fromKind, let toKind = library.record?.mode
        else { return Self.afterCommit(.keysReplaced) }
        switch (fromKind, toKind) {
        case (.standard, .castle): return Self.afterCommit(.intoCastle)
        case (.castle, .standard): return Self.afterCommit(.intoStandard)
        default: return Self.afterCommit(.keysReplaced)
        }
    }

    func run(_ step: String, _ ctx: ActContext) async throws {
        if Self.isPairCatchUp(ctx.parameters) {
            try await PairCatchUp.run(step, ctx)
            return
        }
        let kind = Self.kind(ctx.parameters)
        let newKind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        // One posture per account (rule 20 too): a follow RESUMED after the
        // account moved on to another posture elsewhere — before its swap —
        // follows into a posture the account no longer has; it rolls back, and
        // the follow now owed runs instead (census class (M), VX-378 U4: a
        // follow out resumed after the account went back into Castle left the
        // library Standard under a Castle account, holding the Castle rows' key).
        if ctx.resuming, ctx.library.fingerprint == ctx.plan.fromFingerprint,
           step == "pickUpKeys" || step == "mintOwnAppleKey" || LibraryRekey.newKeySteps.contains(step),
           let account = ctx.accountID, let vault = ctx.executor.freshVault(for: account), vault.mode != newKind {
            throw ActRollback(refusal: .accountMoved)
        }
        switch step {
        case "pickUpKeys": try await ctx.pickUpKeys()
        case "mintOwnAppleKey": _ = try ctx.mintOwnAppleKey()
        case "custodyItem": try ctx.newCustodyItem(kind: newKind)
        case "keyFile":
            var apple: AppleKeyMaterial?
            if kind == .intoStandard {
                apple = try ctx.ownAppleKey()
            } else if kind == .keysReplaced, newKind == .standard {
                apple = ctx.existingOwnAppleKey()
            }
            let locks = try ctx.newLocks(
                passphrase: ctx.secrets.passphrase != nil, words: ctx.secrets.words != nil, master: true, apple: apple)
            try ctx.newKeyFile(rekeyTo: newKind, locks: locks)
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: newKind)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: newKind) }
        case "memory":
            try ctx.rememberNewKey()
            if kind == .intoStandard {
                ctx.outcome.done = [.ruleFive]
                ctx.outcome.notices.append(.followedOutOfCastle)
            }
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: kind == .intoCastle)
        case "exportOff": try ctx.turnExportOff()
        case "retireOwnAppleKeys": try ctx.retireOwnAppleKeys()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The account's keys from the vault: the keys this device holds when they
    /// still open it (the quiet follow out — the leave changed no key), else the
    /// master by the typed secret (nothing unwrapped on the server); held the
    /// account's way (rule 15's custody), and the sync key taken stamped.
    func pickUpKeys() async throws {
        let snapshot = try await freshRead()
        let keys = try material(for: snapshot)
        try holdSyncKeys(keys, castleWay: snapshot.mode == .castle)
        try stampFollowed(keys.rowKeyID)
    }

    /// The sync key this act took, stamped in its plan (see
    /// `ActParameters.followedRowKeyID`).
    func stampFollowed(_ rowKeyID: String) throws {
        guard parameters.followedRowKeyID != rowKeyID else { return }
        var next = parameters
        next.followedRowKeyID = rowKeyID
        plan.parameters = next
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
    }
}

extension ProtectionExecutor {
    /// **The follow** — `typed`: the passphrase or the words, once (nothing for
    /// the quiet follow out of Castle, while this device holds the account's
    /// keys); `gate`: into Castle, this device's gate style — none chosen yet:
    /// Touch ID where a finger is enrolled, the item made at this press, else
    /// Always ask (§3.10).
    public func follow(
        _ library: inout UnlockedLibrary, kind: FollowKind, typed: TypedSecrets, gate: GateStyle? = nil
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        if case .pairChanged = kind {
            // VX-529 — the follow's third kind: a re-lock to the account's pair,
            // its own entry checks and steps (`PairCatchUp.swift`). (F-2's guard,
            // which refused it before its program existed, is retired.)
            return try await followThePair(&library, typed: typed)
        }
        try requireSignedIn(as: account)
        guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        var secrets = ActSecrets()
        var typedSecret: String?
        if let text = typed.passphrase {
            try vault.vault.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: passphrase, words: nil) != nil else {
                // VX-113: the old passphrase after a change elsewhere — named
                // (the live key file's passphrase lock is the account's as this
                // library last knew it — rule 7's one pair).
                if let known = library.keyFile?.passphrase?.kdf, known != vault.vault.kdf {
                    throw ExecutorRefusal.passphraseChangedElsewhere(device: vault.vault.updatedByDevice, day: vault.updatedAt)
                }
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            secrets.passphrase = passphrase
            typedSecret = "passphrase"
        } else if let words = typed.words {
            let wordsKey = try WordsKey.derive(words)
            guard VaultModel.master(of: vault.vault, passphrase: nil, words: wordsKey) != nil else {
                throw ExecutorRefusal.wordsDoNotOpen
            }
            secrets.words = wordsKey
            typedSecret = "words"
        } else if kind != .intoStandard {
            // Into Castle, and catching up on a replaced sync key, type one
            // secret (rules 10, 15); only the follow out is quiet (rule 12).
            throw ExecutorRefusal.secretMissing
        }
        var parameters = ActParameters(
            synced: true, accountID: account, passphraseKDF: secrets.passphrase?.kdf, typedSecret: typedSecret,
            follow: FollowProgram.name(kind),
            newKind: kind == .intoCastle ? .castle : kind == .intoStandard ? .standard : record.mode,
            ownAppleKeyID: kind == .keysReplaced ? library.keyFile?.apple?.keyID : nil,
            outgoingAppleKeyID: library.keyFile?.apple?.keyID)
        if kind == .intoCastle {
            let chosen = gate ?? library.section.settings.gateStyle
                ?? (leaves.biometry.biometry().enrolled ? .touchID : .alwaysAsk)
            parameters.gate = chosen
            if library.section.settings.gateStyle != chosen {
                var settings = library.section.settings
                settings.gateStyle = chosen
                library.section = library.section.withSettings(settings)
            }
        } else {
            parameters.gate = library.section.settings.gateStyle
        }
        return try await perform(
            FollowProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
