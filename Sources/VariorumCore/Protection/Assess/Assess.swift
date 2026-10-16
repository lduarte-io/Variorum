import Foundation

// VX-305 U2 — `assess(facts) → Assessment`: THE ONLY DECISION CODE (design
// §3.3). Everything that decides calls it — the route, the lobby, the doors,
// the views and the sync engine's key provider — and it is PURE: plain values
// in, plain values out; it reads no Keychain, file or network, and calls no
// writing leaf. The executor (U3) runs what it owes.
//
// The rules it encodes, each a small function below (table-tested one by one
// in AssessTests):
//   - §3.3, guards included: before unlock nothing decides; no repair makes a
//     Touch ID item or changes a key's kind; in Standard nothing destructive
//     runs on the record's word alone; a synced library writes nothing
//     Apple-reachable without a fresh vault read for its account (decision 35);
//     a lost Apple road is reported (no repair mints — rule 8's re-make is
//     U2's; Re-link left with VX-378 U1);
//   - §3.5: one Apple key per library per Mac and one per account; entering
//     Castle retires every own key this Mac's section lists; copies under a key
//     this Mac can't delete are named at Use Castle's door (the old shared key,
//     its retirement and the move's gifts left with rules 26 and 19);
//   - §3.9: the vault's mode; a follower's hold; sync keys held the
//     account's way (rule 15's custody; the stuck leave left with VX-378 U1);
//   - §3.8: the four account situations; no leave re-keys (rule 16); the
//     joining rules;
//   - §3.10: the Touch ID road, VX-310's lobby rule as data.
// (A copy is a copy — rule 17: the open rule left with VX-378 U1; Look inside
// and Make this my library are U2's.)

/// **The assessment.** `guards` is `.all` everywhere but the DEBUG mutation
/// pins.
public func assess(_ facts: ProtectionFacts, guards: ProtectionGuards = .all) -> Assessment {
    let launch = AssessRules.launch(facts)
    let mode = AssessRules.mode(facts)
    let account = AssessRules.account(facts)
    let vault = AssessRules.vault(facts, account: account, guards: guards)
    let touchID = AssessRules.touchID(facts, guards: guards)
    let finder = AssessRules.routeFinder(facts)
    var repairs: [Repair] = []
    var faults: [Fault] = []
    var acts: [OwedAct] = []
    if let unlocked = facts.unlocked {
        (repairs, faults) = AssessRules.repairs(facts, unlocked, mode: mode, account: account, vault: vault, guards: guards)
        acts = AssessRules.acts(facts, unlocked, mode: mode, account: account, vault: vault, faults: faults,
                                touchID: touchID)
    }
    let doors = AssessRules.doors(facts, mode: mode, account: account, vault: vault, acts: acts,
                                  faults: faults, guards: guards)
    var opensWith: [String: OpensWith] = [:]
    for copy in facts.catalog.copies { opensWith[copy.id] = finder.opensWith(copy: copy) }
    return Assessment(
        launch: launch, mode: mode, account: account, vault: vault, lobby: AssessRules.lobby(facts),
        touchID: touchID, repairs: repairs, faults: faults, acts: acts, doors: doors, opensWith: opensWith)
}

public enum AssessRules {
    // MARK: - The launch

    public static func launch(_ facts: ProtectionFacts) -> LaunchVerdict {
        if facts.unlocked != nil { return .open }
        switch facts.storeFile {
        case .absent: return facts.containerMarker ? .libraryMissing : .startFresh
        case .present, .plaintext: return .lobby
        }
    }

    // MARK: - The mode (§3.3)

    public static func mode(_ facts: ProtectionFacts) -> ModeVerdict {
        guard let unlocked = facts.unlocked else {
            return ModeVerdict(mode: facts.rememberedModeHint, source: .hintOnly)
        }
        return ModeVerdict(mode: unlocked.record.mode, source: .record)
    }

    // MARK: - The account (§3.8's four situations)

    public static func account(_ facts: ProtectionFacts) -> AccountVerdict {
        let account = facts.unlocked?.record.account
        guard let account else {
            return AccountVerdict(situation: .localOnly, account: nil, confirmed: false)
        }
        switch facts.session {
        case .signedOut:
            return AccountVerdict(situation: .signedOut(account: account), account: account, confirmed: false)
        case .signedIn(let signedIn, let email) where signedIn != account:
            let sameEmail = email != nil && email == facts.libraryAccountEmail
            return AccountVerdict(
                situation: .otherAccount(library: account, signedIn: signedIn, sameEmail: sameEmail),
                account: account, confirmed: false)
        case .signedIn:
            return AccountVerdict(
                situation: .inSync(account: account), account: account,
                confirmed: facts.freshVault(for: account) != nil)
        }
    }

    // MARK: - The vault (§3.9)

    public static func vault(_ facts: ProtectionFacts, account: AccountVerdict, guards: ProtectionGuards) -> VaultVerdict? {
        guard let reading = facts.freshVault(for: account.account) else { return nil }
        let mode = reading.mode
        return VaultVerdict(
            mode: mode, rotationInProgress: reading.rotationInProgress,
            completesWithoutAppleCopy: reading.previousCorpusKeyID != nil && reading.appleKeyID == nil && !reading.hasAppleWrap,
            syncKeysCustody: mode == .castle ? .castleWay : .silent, followHoldsLibraryRekey: reading.rotationInProgress)
    }

    // MARK: - Touch ID (§3.10, VX-310)

    public static func touchID(_ facts: ProtectionFacts, guards: ProtectionGuards) -> TouchIDAssessment {
        let fingerprint = facts.unlocked?.currentFingerprint ?? facts.slotFingerprintHint
        // With no fingerprint to name the current key (before unlock, the key
        // file AND the memory item both gone — no hint), ANY Touch ID item in
        // this scope counts: VX-310's letter, "the button whenever a Touch ID
        // item exists" — a press verifies itself, a wrong key's item failing
        // honestly into the passphrase road (VX-305 ladder round 1, NIT 6).
        let itemExists = fingerprint.map {
            facts.custody.contains(CustodyItemFact(fingerprint: $0, itemClass: .touchid))
        } ?? facts.custody.contains { $0.itemClass == .touchid }
        let usableHere = facts.biometry.hardware && facts.biometry.enrolled
        let button = itemExists && usableHere
        var quietLine: TouchIDQuietLine?
        if !button { quietLine = usableHere ? .notSetUpForThisLibrary : .notSetUpOnThisMac }
        let pressFailedOnItem = facts.touchIDPress == .failedOnExistingItem && itemExists
        var rearm = facts.unlocked != nil && pressFailedOnItem
        if !guards.noRearmWithoutItemOn, let unlocked = facts.unlocked,
           unlocked.thisMac.settings.gateStyle == .touchID, !itemExists {
            rearm = true
        }
        return TouchIDAssessment(
            button: button, autoAsk: button && facts.biometry.transient == nil,
            pressSays: button ? facts.biometry.transient : nil, quietLine: quietLine,
            changedLine: pressFailedOnItem, rearmQuestion: rearm)
    }

    // MARK: - The route finder over this device's facts

    public static func routeFinder(_ facts: ProtectionFacts) -> RouteFinder {
        RouteFinder(RouteFacts(
            catalog: facts.catalog, liveKeyFileID: facts.unlocked?.liveKeyFileID ?? facts.catalog.liveKeyFile?.id,
            custody: facts.custody, readableAppleKeyIDs: facts.appleKeys.readable))
    }

    // MARK: - The lobby (before unlock: roads only)

    public static func lobby(_ facts: ProtectionFacts) -> LobbyRoads {
        let live = (facts.unlocked?.liveKeyFileID ?? facts.catalog.liveKeyFile?.id)
            .flatMap { facts.catalog.keyFile(id: $0)?.document }
        var typed = Set<TypedRoad>()
        if live?.passphrase != nil { typed.insert(.passphrase) }
        if live?.words != nil || live?.masterWordsCopy != nil { typed.insert(.words) }
        // Roads needing no person: every silent item (whatever fingerprint it
        // names — each verifies itself) and the live file's Apple wrap when its
        // key is readable here.
        let apple = live?.apple.flatMap { facts.appleKeys.readable.contains($0.keyID) ? $0.keyID : nil }
        return LobbyRoads(
            silentItems: facts.custody.filter { $0.itemClass == .silent }, appleKeyID: apple,
            custodyItems: facts.custody, typed: typed, vaultRoad: facts.session.accountID != nil)
    }

    // MARK: - Repairs (§3.3, guards included)

    static func liveKeyFile(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts) -> KeyFile? {
        guard let id = unlocked.liveKeyFileID else { return nil }
        return facts.catalog.keyFile(id: id)?.document
    }

    public static func repairs(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, mode: ModeVerdict, account: AccountVerdict,
        vault: VaultVerdict?, guards: ProtectionGuards
    ) -> (repairs: [Repair], faults: [Fault]) {
        var repairs: [Repair] = []
        var faults: [Fault] = []
        let record = unlocked.record
        // (A library file older than what this Mac remembers no longer loses
        // to the memory by a repair — "memory wins" left with VX-378 U1, rule
        // 21: U2 detects the disagreement and refuses.)
        // ALWAYS: what this Mac remembers names the record's current key and
        // this Mac's device ID. (Its fingerprint arm follows the record until
        // U2's refusal replaces it — rule 21; the two homes, the tree, the
        // epoch and the facts last confirmed left with VX-378 U1.)
        do {
            let memory = unlocked.memory
            var stale = memory == nil
                || memory?.currentFingerprint != record.currentFingerprint
                || memory?.deviceID != unlocked.thisMac.deviceID
            // The key file and its mirror, for the current key: the mirror is
            // written back ONLY when the live file is absent (rule 1). Another
            // key's file in the live place, or a live file with fewer roads
            // than the mirror, is no repair's to undo (rule 21 — the restore
            // over a stray and `mirrorHoldsMore` left with VX-378 U1).
            if let mirror = memory?.keyFileMirror, mirror.fingerprint == unlocked.currentFingerprint {
                if let live = liveKeyFile(facts, unlocked) {
                    if live.fingerprint == mirror.fingerprint, live != mirror { stale = true }
                } else {
                    repairs.append(.restoreKeyFileFromMirror)
                }
            }
            if stale { repairs.append(.refreshMemory) }
            // A synced library whose memory names no vault facts (the memory
            // item gone — a wiped keychain): the keys this device holds are
            // recorded, so a later replacement of the account's keys reads as
            // a follow owed (VX-305 U4, found by the scenario world).
            if let account = record.account, facts.session.accountID == account, facts.freshVault(for: account) != nil,
               memory != nil, memory?.vaultFacts?.corpusKeyID == nil {
                repairs.append(.recordHeldSyncKeysFacts)
            }
        }
        // The mode's repairs and faults read the live file only when it is the
        // CURRENT key's: another key's file in the live place is no "Castle
        // key with an Apple wrap" and owes no Standard wrap — it is its own
        // fault (U2 makes it the refusal of rule 21). Mid-act the live file is
        // the act's new key's by design (no fault).
        let rawLive = liveKeyFile(facts, unlocked)
        let live = rawLive.flatMap { $0.fingerprint == unlocked.currentFingerprint ? $0 : nil }
        if rawLive != nil, live == nil, unlocked.thisMac.actInFlight == nil, let id = unlocked.liveKeyFileID {
            faults.append(.liveKeyFileIsAnotherKeys(keyFileID: id))
        }
        guard let current = mode.mode else { return (repairs, faults) }
        // §3.10: a choice of Touch ID with no item behind it records Always
        // ask quietly — NEVER a repair that makes an item (only a press does).
        if current == .castle, unlocked.thisMac.settings.gateStyle == .touchID,
           !facts.custody.contains(CustodyItemFact(fingerprint: unlocked.currentFingerprint, itemClass: .touchid)) {
            repairs.append(guards.noRepairMakesTouchIDOn
                ? .recordAlwaysAskQuietly : .makeTouchIDItem(fingerprint: unlocked.currentFingerprint))
        }
        switch current {
        case .castle:
            castleRepairs(facts, unlocked, live: live, account: account, vault: vault, guards: guards,
                          repairs: &repairs, faults: &faults)
        case .standard:
            standardRepairs(facts, unlocked, live: live, account: account, guards: guards,
                            repairs: &repairs, faults: &faults)
        }
        return (repairs, faults)
    }

    /// The precondition under which a key's copy may go: the current key's
    /// typed road, or the live history holding it; nil = it may be the only
    /// road, so it stays.
    static func goesOnlyIf(
        _ fingerprint: String, current: String, live: KeyFile?
    ) -> RepairPrecondition? {
        if fingerprint == current {
            return (live?.passphrase != nil || live?.words != nil) ? .currentKeyHasTypedRoad : nil
        }
        return (live?.history.contains { $0.fingerprint == fingerprint } ?? false) ? .historyHolds(fingerprint: fingerprint) : nil
    }

    static func castleRepairs(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, live: KeyFile?, account: AccountVerdict,
        vault: VaultVerdict?, guards: ProtectionGuards, repairs: inout [Repair], faults: inout [Fault]
    ) {
        let current = unlocked.currentFingerprint
        // The keys the library has had: the current key's file and its
        // history (rule 4 — the family tree left with VX-378 U1).
        let tree = Set(live?.heldFingerprints ?? []).union([current])
        // No Apple key of this Mac's own for the library left unretired in
        // Castle — entering Castle retires every one (§3.5); an entry whose
        // last steps no one ran leaves them listed (VX-305 U4, the scenario
        // world).
        let unretired = unlocked.thisMac.ownLibraryAppleKeyIDsToRetire
        if !unretired.isEmpty, unlocked.thisMac.actInFlight == nil {
            repairs.append(.retireOwnAppleKeys(ids: unretired))
        }
        // No silent item for any key the library has had.
        for item in facts.custody where item.itemClass == .silent && tree.contains(item.fingerprint) {
            if let precondition = goesOnlyIf(item.fingerprint, current: current, live: live) {
                repairs.append(.deleteSilentItem(fingerprint: item.fingerprint, precondition: precondition))
            } else {
                faults.append(.silentItemIsOnlyRoad(fingerprint: item.fingerprint))
            }
        }
        // A Castle key never has an Apple wrap: a planted file — a fault the
        // re-key answers.
        if let live, live.apple != nil, let id = unlocked.liveKeyFileID {
            faults.append(.appleWrapOnCastleKey(keyFileID: id))
        }
        // Delete on sight, BY RECORDED ID ONLY — never for belonging to "this
        // library": another Mac's copy of it may be in Standard under a key of
        // its own.
        let retired = unlocked.thisMac.retiredAppleKeyIDs
        if guards.deleteOnSightByIDOnlyOn {
            for id in facts.appleKeys.readable.intersection(retired).sorted() {
                repairs.append(.deleteRetiredAppleKey(id: id))
            }
        } else {
            for id in facts.appleKeys.readable.sorted() where id != live?.apple?.keyID {
                repairs.append(.deleteRetiredAppleKey(id: id))
            }
        }
        // The library's sync keys reach Castle-era keys: a silent item for them
        // is reported (PROVISIONAL P-U2-2 — the acts re-file sync keys).
        if let account = account.account, vault?.syncKeysCustody != .silent,
           facts.syncKeys.contains(SyncKeysItemFact(accountID: account, itemClass: .silent)) {
            faults.append(.silentSyncKeysWhileCastleWay(account: account))
        }
    }

    static func standardRepairs(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, live: KeyFile?, account: AccountVerdict,
        guards: ProtectionGuards, repairs: inout [Repair], faults: inout [Fault]
    ) {
        // Decision 35: a synced library writes nothing Apple-reachable without
        // a fresh vault read for its account.
        let synced = account.account != nil
        let appleWriteAllowed = !synced || facts.freshVault(for: account.account) != nil
            || !guards.freshVaultBeforeAppleWriteOn
        if let live, let id = unlocked.liveKeyFileID {
            if let wrap = live.apple {
                if !facts.appleKeys.readable.contains(wrap.keyID) {
                    faults.append(.appleRoadLost(keyFileID: id))
                }
            } else if let own = unlocked.thisMac.appleKeys
                .first(where: { $0.isOwnLibraryKey && $0.retiredAt == nil && facts.appleKeys.readable.contains($0.id) }) {
                // This Mac's own key, readable: the wrap lands (no repair
                // ever mints one).
                if appleWriteAllowed { repairs.append(.landAppleWrap(appleKeyID: own.id)) }
            } else if unlocked.thisMac.appleKeys.contains(where: { $0.isOwnLibraryKey && $0.retiredAt == nil }) {
                faults.append(.appleRoadLost(keyFileID: id))
            }
        }
        // No Touch ID item for a Standard key — and nothing destructive on a
        // Standard record's word alone (a login-password holder can rewrite
        // it, rule 3): reported, never deleted by a repair.
        for item in facts.custody where item.itemClass == .touchid {
            if guards.standardRecordNoDestructiveRepairOn {
                faults.append(.touchIDItemInStandard(fingerprint: item.fingerprint))
            } else {
                repairs.append(.deleteTouchIDItem(fingerprint: item.fingerprint))
            }
        }
    }

    // MARK: - Acts owed

    public static func acts(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, mode: ModeVerdict, account: AccountVerdict,
        vault: VaultVerdict?, faults: [Fault], touchID: TouchIDAssessment
    ) -> [OwedAct] {
        var acts: [OwedAct] = []
        guard let current = mode.mode else { return acts }
        let reading = facts.freshVault(for: account.account)
        // This device's own act in flight is its plan's to finish — never read
        // as the account moving elsewhere.
        let ownActInFlight = unlocked.thisMac.actInFlight != nil
        if let vault, let reading, !ownActInFlight {
            // The account moved elsewhere: the follow.
            let known = unlocked.memory?.vaultFacts?.corpusKeyID
            switch vault.mode {
            case .standard where current == .castle:
                acts.append(.follow(.intoStandard, typesOneSecret: true, holdsLibraryRekey: vault.rotationInProgress))
            case .castle where current == .standard:
                acts.append(.follow(.intoCastle, typesOneSecret: true, holdsLibraryRekey: vault.rotationInProgress))
            default:
                // What this Mac remembers names no vault facts (its memory item
                // went): the library's master words copy against the vault's
                // recovery wrap tells whether its master is the account's.
                let behind = known == nil && liveKeyFile(facts, unlocked).map { live in
                    live.master != nil && live.masterWordsCopy != nil && live.masterWordsCopy != reading.recoveryWrap
                } == true
                if (known.map { known in reading.corpusKeyID.map { $0 != known } ?? false } ?? false) || behind {
                    // Keys replaced in the same mode: Castle types one secret;
                    // Standard reads the new master through the account's Apple
                    // key, or takes a secret when it can't be read here.
                    let typed = current == .castle
                        || !(reading.appleKeyID.map { facts.appleKeys.readable.contains($0) } ?? false)
                    acts.append(.follow(.keysReplaced, typesOneSecret: typed, holdsLibraryRekey: vault.rotationInProgress))
                }
            }
        }
        if faults.contains(where: { if case .appleWrapOnCastleKey = $0 { return true } else { return false } }) {
            acts.append(.rekeyForFault)
        }
        if touchID.rearmQuestion { acts.append(.touchIDRearmQuestion) }
        return acts
    }

    // MARK: - Doors

    public static func doors(
        _ facts: ProtectionFacts, mode: ModeVerdict, account: AccountVerdict, vault: VaultVerdict?,
        acts: [OwedAct], faults: [Fault], guards: ProtectionGuards
    ) -> [Door: DoorState] {
        var doors: [Door: DoorState] = [:]
        guard let unlocked = facts.unlocked, let current = mode.mode else {
            for door in Door.allCases { doors[door] = .refused(.locked) }
            return doors
        }
        let section = unlocked.thisMac
        let reading = facts.freshVault(for: account.account)
        let followOwed = acts.contains { if case .follow = $0 { return true } else { return false } }
        let signedIn = facts.session.accountID != nil
        var inSync = false, signedOut = false, otherAccount = false, sameEmail = false
        switch account.situation {
        case .localOnly: break
        case .inSync: inSync = true
        case .signedOut: signedOut = true
        case .otherAccount(_, _, let same): otherAccount = true; sameEmail = same
        }
        let rotation: DoorRefusal? = reading.flatMap {
            $0.rotationInProgress ? .rotationInProgress(device: $0.updatedByDevice, day: $0.updatedAt) : nil
        }
        /// The common gates of a key or mode door: another account signed in,
        /// a follow owed, a synced act without its fresh vault, a rotation.
        func gate(syncedAct: Bool) -> DoorRefusal? {
            if otherAccount { return .otherAccountSignedIn }
            if followOwed { return .followOwed }
            if syncedAct, inSync {
                if reading == nil { return .needsFreshVault }
                if let rotation { return rotation }
            }
            return nil
        }

        // USE CASTLE.
        doors[.useCastle] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            if current == .castle { return .refused(.wrongMode(.castle)) }
            if signedOut { return .refused(.signedOutUseThisMacOnly) }
            return .open(useCastleSpec(facts, unlocked, synced: inSync, guards: guards))
        }()
        // USE STANDARD.
        doors[.useStandard] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            if current == .standard { return .refused(.wrongMode(.standard)) }
            if signedOut { return .refused(.signedOutUseThisMacOnly) }
            return .open(DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: inSync,
                                  words: [.ruleFive]))
        }()
        // REPLACE ALL KEYS — an enrolled library's security act.
        doors[.replaceAllKeys] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            guard inSync else { return .refused(signedOut ? .signedOutUseThisMacOnly : .notSynced) }
            return .open(DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: true), rekeys: true, synced: true))
        }()
        // THE KEY DOORS — re-wrap the current key only (rule 6).
        for (door, requires) in [
            (Door.changePassphrase, SecretRequirement.currentPassphrase),
            (.newWords, .currentPassphrase),
            (.resetForgottenPassphrase, current == .castle ? .touchIDOrWords : .plainConfirm),
        ] {
            doors[door] = {
                if otherAccount { return .refused(.otherAccountSignedIn) }
                if followOwed { return .refused(.followOwed) }
                if inSync, reading == nil { return .refused(.needsFreshVault) }
                return .open(DoorSpec(requires: requires, synced: inSync))
            }()
        }
        // TURN ON SYNC — a local library; the joining rules.
        doors[.turnOnSync] = {
            guard case .localOnly = account.situation else { return .refused(.nothingToDo) }
            guard signedIn else { return .refused(.noAccountSignedIn) }
            let join = joinPlan(library: current, vault: facts.vault.flatMap { $0.accountID == facts.session.accountID ? $0 : nil })
            return .open(joinSpec(join, facts, unlocked, guards: guards))
        }()
        // THE LEAVES — none changes a key or a secret (rule 16), so none asks
        // for one (PROVISIONAL P-VX378-U1-2).
        for door in [Door.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
            doors[door] = {
                if otherAccount { return .refused(.otherAccountSignedIn) }
                if followOwed, door != .deleteAccountHere { return .refused(.followOwed) }
                guard inSync || signedOut else { return .refused(.notSynced) }
                if door == .deleteAccountHere, !inSync { return .refused(.noAccountSignedIn) }
                return .open(DoorSpec(requires: .none))
            }()
        }
        // MOVE it to the signed-in account — leave X (no key change), join Y.
        doors[.moveToSignedInAccount] = {
            guard otherAccount else { return .refused(.nothingToDo) }
            let join = joinPlan(library: current, vault: facts.vault.flatMap { $0.accountID == facts.session.accountID ? $0 : nil })
            var spec = joinSpec(join, facts, unlocked, guards: guards)
            if sameEmail { spec.words.append(.sameEmailDifferentAccount) }
            return .open(spec)
        }()
        doors[.signOut] = signedIn ? .open(DoorSpec(requires: .none)) : .refused(.noAccountSignedIn)
        // THE FOLLOW.
        doors[.followNow] = {
            guard let follow = acts.first(where: { if case .follow = $0 { return true } else { return false } }),
                  case .follow(let kind, let typed, _) = follow else { return .refused(.nothingToDo) }
            let leaves = kind == .intoStandard
            return .open(DoorSpec(requires: typed ? .oneSecret : .none, rekeys: true,
                                  retiresOwnAppleKeys: kind == .intoCastle ? ownKeysToRetire(facts, unlocked, guards: guards) : [],
                                  synced: true, words: leaves ? [.ruleFive] : []))
        }()
        return doors
    }

    /// Every own Apple key entering Castle retires (§3.5): every id this
    /// Mac's section lists as its own for the library — not only the one the
    /// live key file names.
    static func ownKeysToRetire(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts, guards: ProtectionGuards) -> [String] {
        if guards.everyOwnKeyRetiredAtCastleOn { return unlocked.thisMac.ownLibraryAppleKeyIDsToRetire }
        return [liveKeyFile(facts, unlocked)?.apple?.keyID].compactMap { $0 }
    }

    static func useCastleSpec(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, synced: Bool, guards: ProtectionGuards
    ) -> DoorSpec {
        var words: [Words] = [.floorSentence, .exportAPlainCopyFirst]
        // Copies under a key this Mac can't delete — an Apple key it lists as
        // its own and can't read here (one left in an Apple account it no
        // longer uses) wrapping the copy's key in its own key file — named,
        // with what that means.
        let notReadable = Set(unlocked.thisMac.appleKeys.filter { $0.isOwnLibraryKey && $0.retiredAt == nil }.map(\.id))
            .subtracting(facts.appleKeys.readable)
        let undeletable = facts.catalog.copies.filter { copy in
            facts.catalog.servingKeyFiles(of: copy).contains { file in
                guard let document = file.document, let wrap = document.apple else { return false }
                return document.fingerprint == (copy.fingerprint ?? document.fingerprint) && notReadable.contains(wrap.keyID)
            }
        }.map(\.id)
        if !undeletable.isEmpty { words.append(.copiesUnderAKeyThisMacCantDelete(undeletable)) }
        if unlocked.thisMac.settings.scheduledExport { words.append(.scheduledExportTurnsOff) }
        return DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: true), rekeys: true,
            retiresOwnAppleKeys: ownKeysToRetire(facts, unlocked, guards: guards), synced: synced, words: words)
    }

    /// §3.8's joining rules: the account's mode against the library's.
    public static func joinPlan(library: ProtectionMode, vault: VaultReading?) -> JoinPlan {
        guard let vault else { return .setsUpInLibrarysMode }
        switch (vault.mode.settled, library) {
        case (.castle, .standard): return .entersCastle
        case (.standard, .castle): return .leavesCastle
        default: return .sameMode
        }
    }

    static func joinSpec(
        _ join: JoinPlan, _ facts: ProtectionFacts, _ unlocked: UnlockedFacts,
        guards: ProtectionGuards
    ) -> DoorSpec {
        switch join {
        case .entersCastle:
            var spec = useCastleSpec(facts, unlocked, synced: true, guards: guards)
            spec.join = join
            return spec
        case .leavesCastle:
            return DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: true, join: join,
                            words: [.ruleFive])
        case .sameMode, .setsUpInLibrarysMode:
            return DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: true), synced: true, join: join)
        }
    }
}
