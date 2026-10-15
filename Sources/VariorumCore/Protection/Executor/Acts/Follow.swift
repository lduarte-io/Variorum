import CryptoKit
import Foundation

// VX-305 U3 — THE FOLLOW (design §3.9: into Castle, into Standard, keys
// replaced). On a plan carrying every fact a resume needs; EVERY follow into
// or out of Castle types ONE secret, once — the passphrase or the words,
// through the vault — and no such follow waits on an Apple key.
//   - A follower that sees a rotation in progress — a previous corpus key
//     standing, or an id with no wrap (a leave not yet complete) — follows the
//     keys (held by what they reach: Castle-kind while the previous key
//     stands), walks and re-encrypts, completes a rotation with no id (anyone
//     may, never with an Apple copy) or a leave whose named key it reads — but
//     never clears the previous key while an id stands with no wrap — and
//     HOLDS its own library's re-key until the vault reads Standard or Castle.
//   - Into Standard: the ANCHOR FIRST — under the secret typed at the follow,
//     and under the outgoing Castle key with that key's own locks from this
//     device's key file copied beside it (the master's road left out when the
//     vault's master is still the Castle-era one); then a new Standard key
//     (its silent item, this Mac's own FRESH Apple key) with an empty history;
//     the Castle key's Touch ID item goes with its key; rule 5's sentence.
//   - Into Castle: a new Castle key (a Touch ID item made at this press where
//     this device's gate style says so, or none), its history taking every
//     older key (the anchor folded with the typed secret); every own Apple key
//     deleted and recorded retired, the account's recorded retired; the
//     scheduled export off, with one notice.
//   - Keys replaced, same mode: the history grows.
// A follower's new key file is locked under the secret it typed and under the
// new master, with that master's words copy beside it — plus, in Standard,
// this Mac's own Apple key.

struct FollowProgram: ActProgram {
    let act = ProtectionAct.follow

    static func kind(_ parameters: ActParameters) -> FollowKind {
        switch parameters.follow {
        case "intoCastle": return .intoCastle
        case "intoStandard": return .intoStandard
        default: return .keysReplaced
        }
    }

    static func name(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle: return "intoCastle"
        case .intoStandard: return "intoStandard"
        case .keysReplaced: return "keysReplaced"
        }
    }

    static func afterCommit(_ kind: FollowKind) -> [String] {
        switch kind {
        case .intoCastle: return ["memory", "retireOldCustody", "exportOff", "retireOwnAppleKeys", "recordAccountKeyRetired", "backup"]
        case .intoStandard, .keysReplaced: return ["memory", "retireOldCustody", "backup"]
        }
    }

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        let kind = Self.kind(parameters)
        switch kind {
        case .intoStandard:
            return ["anchor", "pickUpKeys", "helpRotation"] + LibraryRekey.steps(guards, mintsOwnAppleKey: true)
                + Self.afterCommit(kind)
        case .intoCastle, .keysReplaced:
            return ["pickUpKeys", "helpRotation"] + LibraryRekey.steps(guards) + Self.afterCommit(kind)
        }
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }

    /// With no plan: the kind read from the family tree — the outgoing key's
    /// kind for life against the new one's.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] {
        guard let inFlight = library.section.actInFlight, let from = inFlight.fromFingerprint,
              let fromKind = library.familyTree.entry(from)?.kind, let toKind = library.record?.mode
        else { return Self.afterCommit(.keysReplaced) }
        switch (fromKind, toKind) {
        case (.standard, .castle): return Self.afterCommit(.intoCastle)
        case (.castle, .standard): return Self.afterCommit(.intoStandard)
        default: return Self.afterCommit(.keysReplaced)
        }
    }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = Self.kind(ctx.parameters)
        let newKind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        switch step {
        case "anchor":
            guard let live = ctx.library.keyFile else { throw ExecutorRefusal.noLiveKeyFile }
            try ctx.writeAnchor(.follower(
                typed: try ctx.typedLock(), outgoingKeyFile: live,
                includeMasterRoad: ctx.parameters.includeMasterRoad ?? true))
        case "pickUpKeys": try await ctx.pickUpKeys()
        case "helpRotation": try await ctx.helpRotation()
        case "mintOwnAppleKey": _ = try ctx.mintAppleKey(purpose: .library)
        case "custodyItem": try ctx.newCustodyItem(kind: newKind)
        case "keyFile":
            let typedIsWords = ctx.parameters.typedSecret == "words"
            var apple: AppleKeyMaterial?
            if kind == .intoStandard {
                apple = try ctx.ownAppleKey()
            } else if kind == .keysReplaced, newKind == .standard {
                apple = ctx.existingOwnAppleKey()
            }
            let locks = try ctx.newLocks(
                passphrase: !typedIsWords && ctx.secrets.passphrase != nil, words: typedIsWords, master: true, apple: apple)
            let crossing: KeyFileCrossing
            switch kind {
            case .intoStandard: crossing = .leavingCastle
            case .intoCastle: crossing = .enteringCastle(openers: ctx.anchorOpeners())
            case .keysReplaced: crossing = .withinMode
            }
            try ctx.newKeyFile(crossing, locks: locks)
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: newKind)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: newKind) }
        case "memory":
            try ctx.rememberNewKey()
            if kind == .intoStandard { ctx.outcome.done = [.ruleFive] }
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: kind == .intoCastle)
        case "exportOff": try ctx.turnExportOff()
        case "retireOwnAppleKeys": try ctx.retireOwnAppleKeys()
        case "recordAccountKeyRetired": try ctx.recordAccountKeyRetired()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The one secret typed at this follow, as the lock it makes.
    func typedLock() throws -> TypedLock {
        if parameters.typedSecret == "words" {
            guard let words = secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
            return .words(words)
        }
        return .passphrase(try requirePassphrase())
    }

    /// The new master from the vault by the typed secret (nothing unwrapped
    /// on the server), the class keys and — while a rotation stands — the
    /// previous corpus key; held by what they reach.
    func pickUpKeys() async throws {
        let snapshot = try await freshRead()
        var master = VaultModel.master(of: snapshot.format, passphrase: secrets.passphrase, words: secrets.words)
        if master == nil, secrets.isEmpty, let id = snapshot.format.appleKeyID,
           let apple = try leaves.apple.readAppleKey(id: id) {
            // Keys replaced in Standard: the new master through the account's
            // Apple key, as today — nothing typed.
            master = try? snapshot.format.unwrapMaster(withAppleKey: apple.key)
        }
        guard let master else { throw ExecutorRefusal.secretsRequired(act) }
        let following = try VaultModel.material(following: snapshot.format, master: master)
        try holdSyncKeys(following, castleWay: reachesCastleEra(snapshot))
        try stampFollowed(following.corpusKeyID)
    }

    /// The corpus key this act took, stamped in its plan (see
    /// `ActParameters.followedCorpusKeyID`).
    func stampFollowed(_ corpusKeyID: String) throws {
        guard parameters.followedCorpusKeyID != corpusKeyID else { return }
        var next = parameters
        next.followedCorpusKeyID = corpusKeyID
        plan.parameters = next
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
    }

    /// Do the keys of this vault reach a Castle-era key? In Castle; through a
    /// leave's rotation until the previous corpus key leaves the vault (§3.2).
    func reachesCastleEra(_ snapshot: VaultSnapshot) -> Bool {
        switch snapshot.mode {
        case .castle: return true
        case .leavingCastle: return executor.guards.castleKindCustodyThroughLeaveOn
        case .standard: return false
        }
    }

    /// A follower in a rotation's window: walk; complete what it may; then
    /// hold the library's re-key while the vault still reads a rotation in
    /// progress.
    func helpRotation() async throws {
        var snapshot = try await freshRead()
        if snapshot.format.previousCorpusKey != nil, snapshot.rowsBelowRotationSeq > 0 {
            _ = try await leaves.vault.reencryptBelowRotationSeq(
                accountID: snapshot.accountID, material: try material(for: snapshot))
            snapshot = try await freshRead()
        }
        let isLeave = snapshot.format.appleKeyID != nil && snapshot.format.masterWrappedByAppleHeld == nil
        let mayComplete: Bool
        if isLeave {
            let readable = try snapshot.format.appleKeyID.map { try leaves.apple.readAppleKey(id: $0) != nil } ?? false
            mayComplete = readable || parameters.mintsFreshAccountKey == true || !executor.guards.leaveIDGatesCompletionOn
        } else {
            mayComplete = snapshot.format.previousCorpusKey != nil
        }
        if mayComplete {
            try await completeRotation(castleWayAfter: !isLeave && snapshot.format.masterWrappedByAppleHeld == nil)
            snapshot = try await freshRead()
        }
        if snapshot.reading.rotationInProgress {
            outcome.held = true
            outcome.notices.append(.heldForRotation)
            log("holds its library re-key — the vault reads a rotation in progress")
            skipRemaining()
            return
        }
        try holdSyncKeys(try material(for: snapshot), castleWay: reachesCastleEra(snapshot))
    }

    /// A device that follows into Castle records the account's key as
    /// retired (and deletes its own — `retireOwnAppleKeys`), never the old
    /// shared key (§3.5).
    func recordAccountKeyRetired() throws {
        let ids = library.section.appleKeys
            .filter { $0.purpose == .account && $0.retiredAt == nil && ($0.accountID == nil || $0.accountID == accountID) }
            .map(\.id)
        guard !ids.isEmpty else { return }
        try updateSection { section in
            ids.reduce(section) {
                $0.retiringAppleKey(id: $1, purpose: .account, accountID: accountID, origin: .followed, at: now)
            }
        }
    }
}

extension ProtectionExecutor {
    /// **The follow** — `typed`: the passphrase or the words, once (nothing
    /// for keys replaced in Standard when the account's Apple key reads here);
    /// `gate`: into Castle, this device's gate style — none chosen yet: Touch
    /// ID where a finger is enrolled, the item made at this press, else Always
    /// ask (§3.10).
    /// `mintingIfTheNamedKeyNeverArrives`: FINISH LEAVING CASTLE, started on
    /// another device (§3.9) — the press that stopped waiting for the key the
    /// vault names mints a fresh account key to complete the leave.
    public func follow(
        _ library: inout UnlockedLibrary, kind: FollowKind, typed: TypedSecrets, gate: GateStyle? = nil,
        mintingIfTheNamedKeyNeverArrives: Bool = false
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        try requireSignedIn(as: account)
        guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        var secrets = ActSecrets()
        var typedSecret: String?
        if let text = typed.passphrase {
            try vault.format.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.format.kdf)
            guard VaultModel.master(of: vault.format, passphrase: passphrase, words: nil) != nil else {
                // VX-113: the old passphrase after a change elsewhere — named.
                if let known = library.memory?.vaultFacts?.kdf, known != vault.format.kdf {
                    throw ExecutorRefusal.passphraseChangedElsewhere(device: vault.format.updatedByDevice, day: vault.updatedAt)
                }
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            secrets.passphrase = passphrase
            typedSecret = "passphrase"
        } else if let words = typed.words {
            let wordsKey = try WordsKey.derive(words)
            guard VaultModel.master(of: vault.format, passphrase: nil, words: wordsKey) != nil else {
                throw ExecutorRefusal.wordsDoNotOpen
            }
            secrets.words = wordsKey
            typedSecret = "words"
        } else if kind != .keysReplaced || record.mode != .standard {
            throw ExecutorRefusal.secretMissing
        }
        var parameters = ActParameters(
            synced: true, accountID: account, passphraseKDF: secrets.passphrase?.kdf, typedSecret: typedSecret,
            follow: FollowProgram.name(kind),
            newKind: kind == .intoCastle ? .castle : kind == .intoStandard ? .standard : record.mode,
            ownAppleKeyID: kind == .keysReplaced ? library.keyFile?.apple?.keyID : nil)
        if mintingIfTheNamedKeyNeverArrives { parameters.mintsFreshAccountKey = true }
        if kind == .intoStandard {
            // The master's road is left out of the anchor when the vault's
            // master is still the Castle-era one this device's file holds (an
            // older build left without changing it).
            let master = VaultModel.master(of: vault.format, passphrase: secrets.passphrase, words: secrets.words)
            let unchanged = master.flatMap { try? library.keyFile?.open(master: $0) } != nil
            parameters.includeMasterRoad = !unchanged
        }
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
