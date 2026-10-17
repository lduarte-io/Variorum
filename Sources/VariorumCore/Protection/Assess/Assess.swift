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
        // RULE 21 (her ruling at the U4 stop): what the open said, reported
        // until what this Mac remembers has followed the library — no door
        // closes, nothing is repaired over it.
        if let notice = AssessRules.notice(facts, unlocked) { faults.append(.libraryNotice(notice)) }
        var found: [Fault] = []
        (repairs, found) = AssessRules.repairs(facts, unlocked, mode: mode, account: account, vault: vault, guards: guards)
        faults += found
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
    // MARK: - Rule 21

    /// The open's notice while what this Mac remembers hasn't followed the
    /// library yet (it names another key, or nothing, or other libraries too).
    public static func notice(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts) -> LibraryNotice? {
        guard let notice = unlocked.notice else { return nil }
        return memoryFollows(facts, unlocked) ? nil : notice
    }

    /// What this Mac remembers names the library in the live place, its
    /// current key and this Mac's device ID — and no other library (rule 21:
    /// "This Mac remembers four things about its library").
    static func memoryFollows(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts) -> Bool {
        guard let memory = unlocked.memory else { return false }
        return memory.libraryID == unlocked.record.libraryID
            && memory.currentFingerprint == unlocked.record.currentFingerprint
            && memory.deviceID == unlocked.thisMac.deviceID
            && facts.rememberedLibraryIDs.subtracting([unlocked.record.libraryID]).isEmpty
    }

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
        return VaultVerdict(mode: reading.mode, syncKeysCustody: reading.mode == .castle ? .castleWay : .silent)
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
        // RULE 27: a library in the slot and no road at all — no key file beside
        // it, none in any copy, no memory item (its sealed mirror), no custody
        // item holding a key. Anything that might still open it says nothing.
        var nothing: NoKeyFileAnywhere?
        if facts.unlocked == nil, facts.storeFile == .present, live == nil,
           !facts.catalog.keyFiles.contains(where: { $0.document != nil }),
           facts.rememberedLibraryIDs.isEmpty, facts.custody.isEmpty {
            nothing = NoKeyFileAnywhere(accountRoad: facts.session.accountID != nil)
        }
        return LobbyRoads(
            silentItems: facts.custody.filter { $0.itemClass == .silent }, appleKeyID: apple,
            custodyItems: facts.custody, typed: typed, vaultRoad: facts.session.accountID != nil,
            noKeyFileAnywhere: nothing)
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
        // 21.)
        // ALWAYS: what this Mac remembers names the library in the live place,
        // the record's current key and this Mac's device ID, and no other
        // library. ITS FINGERPRINT ARM IS BACK (her ruling at the U4 stop,
        // 2026-10-17: the memory follows the file after rule 21's notice — one
        // write, no repair); a refresh forgets every other library's item (this
        // Mac remembers ONE library). Never mid-act (the repairs don't run).
        do {
            let memory = unlocked.memory
            var stale = !memoryFollows(facts, unlocked)
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
            } else if liveKeyFile(facts, unlocked) == nil, unlocked.thisMac.actInFlight == nil,
                      !backupHoldsTheCurrentKeyFile(facts, unlocked) {
                // RULE 27: opened (by a quiet road) with no key file anywhere —
                // nothing to write back; said, never rebuilt. (A backup holding
                // the current key's file is rule 21's offer — `acts`.)
                faults.append(.noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: record.account != nil)))
            }
            if stale { repairs.append(.refreshMemory) }
            // (The held keys' vault facts left with VX-378 U2: the RECORD names
            // the sync key the library follows — `accountRowKeyID` — so a
            // wiped keychain loses nothing a follow reads.)
        }
        // The mode's repairs and faults read the live file only when it is the
        // CURRENT key's: another key's file in the live place is no "Castle
        // key with an Apple wrap" and owes no Standard wrap — it is its own
        // fault (U2 makes it the refusal of rule 21). Mid-act the live file is
        // the act's new key's by design (no fault).
        let rawLive = liveKeyFile(facts, unlocked)
        let live = rawLive.flatMap { $0.fingerprint == unlocked.currentFingerprint ? $0 : nil }
        if let rawLive, live == nil, unlocked.thisMac.actInFlight == nil, let id = unlocked.liveKeyFileID {
            faults.append(.liveKeyFileIsAnotherKeys(keyFileID: id))
            // RULE 27: and no home holds the library's own key file, nor does the
            // stray reach it through its history — said, never rebuilt.
            if unlocked.memory?.keyFileMirror?.fingerprint != unlocked.currentFingerprint,
               !backupHoldsTheCurrentKeyFile(facts, unlocked), !rawLive.heldFingerprints.contains(unlocked.currentFingerprint) {
                faults.append(.noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: record.account != nil)))
            }
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
        // RULE 8: the quiet roads are RE-MADE at an open, never asked for while
        // one works. The Apple road: the live key file's own wrap readable here
        // — else this Mac's own readable key takes the wrap, else a fresh Apple
        // key is made for it ("quietly makes a fresh Apple road"). A road that
        // was there and failed is also reported (rule 3's ask reads it).
        if let live, let id = unlocked.liveKeyFileID {
            let works = live.apple.map { facts.appleKeys.readable.contains($0.keyID) } ?? false
            if !works {
                if live.apple != nil || unlocked.thisMac.appleKeys.contains(where: { $0.retiredAt == nil }) {
                    faults.append(.appleRoadLost(keyFileID: id))
                }
                if appleWriteAllowed {
                    if let own = unlocked.thisMac.appleKeys
                        .first(where: { $0.retiredAt == nil && facts.appleKeys.readable.contains($0.id) }) {
                        repairs.append(.landAppleWrap(appleKeyID: own.id))
                    } else {
                        repairs.append(.remakeAppleRoad)
                    }
                }
            }
        }
        // The on-device road: Standard's silent item for the current key (rule
        // 8's "this Mac's login keychain"), re-made with the key in hand.
        if !facts.custody.contains(CustodyItemFact(fingerprint: unlocked.currentFingerprint, itemClass: .silent)) {
            repairs.append(.remakeOnDeviceItem)
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
            // The account moved elsewhere: the follow (one posture — rules 10,
            // 12, 15).
            switch (vault.mode, current) {
            case (.standard, .castle):
                // Out of Castle: quiet — the device already holds the account's
                // keys (the leave changed none).
                acts.append(.follow(.intoStandard, typesOneSecret: false))
            case (.castle, .standard):
                acts.append(.follow(.intoCastle, typesOneSecret: true))
            default:
                // Same posture, a sync key this library doesn't follow: it lagged
                // through an entry into Castle (the master changed with the key)
                // — one secret catches it up.
                if unlocked.record.accountRowKeyID != reading.rowKeyID {
                    acts.append(.follow(.keysReplaced, typesOneSecret: true))
                }
            }
        }
        if faults.contains(where: { if case .appleWrapOnCastleKey = $0 { return true } else { return false } }) {
            acts.append(.rekeyForFault)
        }
        // RULE 21's key-file offer (her ruling at the U4 stop): the key file
        // beside the library isn't its own — another key's, or none the sealed
        // copy can write back — and a home the app keeps key files in holds the
        // library's own (this Mac's keychain copy, a backup's): an offer, never a
        // refusal (nothing in flight).
        if !ownActInFlight, liveKeyFile(facts, unlocked)?.fingerprint != unlocked.currentFingerprint,
           unlocked.memory?.keyFileMirror?.fingerprint == unlocked.currentFingerprint
               ? liveKeyFile(facts, unlocked) != nil : backupHoldsTheCurrentKeyFile(facts, unlocked) {
            acts.append(.offerKeyFile)
        }
        if touchID.rearmQuestion { acts.append(.touchIDRearmQuestion) }
        acts += passphraseAsks(facts, unlocked, current: current, faults: faults)
        return acts
    }

    /// A key file of the library's current key in one of rule 19's folders (a
    /// backup's pair, an aside copy) — read by the name the file claims; the
    /// offer's search verifies it against the library (rule 21).
    static func backupHoldsTheCurrentKeyFile(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts) -> Bool {
        facts.catalog.keyFiles.contains { $0.role != .live && $0.fingerprint == unlocked.currentFingerprint }
    }

    /// RULE 3: a library with no passphrase is asked for one right before its
    /// first backup and at the first launch after a quiet road failed — the
    /// launch that finds it (the Apple road lost, or Standard's on-device item
    /// gone for the current key).
    static func passphraseAsks(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, current: ProtectionMode, faults: [Fault]
    ) -> [OwedAct] {
        guard !unlocked.record.passphraseSet else { return [] }
        var asks: [OwedAct] = []
        if !facts.catalog.copies(ofLibrary: unlocked.record.libraryID).contains(where: { $0.kind == .backup }) {
            asks.append(.askPassphrase(.beforeFirstBackup))
        }
        let appleRoadLost = faults.contains { if case .appleRoadLost = $0 { return true } else { return false } }
        let onDeviceItemGone = current == .standard
            && !facts.custody.contains(CustodyItemFact(fingerprint: unlocked.currentFingerprint, itemClass: .silent))
        if appleRoadLost || onDeviceItemGone { asks.append(.askPassphrase(.quietRoadFailed)) }
        return asks
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
        /// The common gates of a key or mode door: another account signed in,
        /// a follow owed, a synced act without its fresh vault.
        func gate(syncedAct: Bool) -> DoorRefusal? {
            if otherAccount { return .otherAccountSignedIn }
            if followOwed { return .followOwed }
            if syncedAct, inSync, reading == nil { return .needsFreshVault }
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
            // Rule 7: only creating a library shows fresh words — typed here.
            return .open(DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: true))
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
                  case .follow(let kind, let typed) = follow else { return .refused(.nothingToDo) }
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
        let outgoing = [liveKeyFile(facts, unlocked)?.apple?.keyID].compactMap { $0 }
        if guards.everyOwnKeyRetiredAtCastleOn {
            return Array(Set(unlocked.thisMac.ownLibraryAppleKeyIDsToRetire).union(outgoing)).sorted()
        }
        return outgoing
    }

    static func useCastleSpec(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, synced: Bool, guards: ProtectionGuards
    ) -> DoorSpec {
        var words: [Words] = [.floorSentence, .exportAPlainCopyFirst]
        // Copies under a key this Mac can't delete — an Apple key it lists as
        // its own and can't read here (one left in an Apple account it no
        // longer uses) wrapping the copy's key in its own key file — named,
        // with what that means.
        let notReadable = Set(unlocked.thisMac.appleKeys.filter { $0.retiredAt == nil }.map(\.id))
            .subtracting(facts.appleKeys.readable)
        let undeletable = facts.catalog.copies.filter { copy in
            facts.catalog.servingKeyFiles(of: copy).contains { file in
                guard let document = file.document, let wrap = document.apple else { return false }
                return document.fingerprint == (copy.fingerprint ?? document.fingerprint) && notReadable.contains(wrap.keyID)
            }
        }.map(\.id)
        if !undeletable.isEmpty { words.append(.copiesUnderAKeyThisMacCantDelete(undeletable)) }
        if unlocked.thisMac.settings.scheduledExport { words.append(.scheduledExportTurnsOff) }
        // The passphrase AND the words (rule 11's passphrase; the words because
        // nothing else can lock the new key — or, synced, the new master — under
        // them: rules 2, 14), both TYPED — rule 7: only creating a library shows
        // fresh words.
        return DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true,
            retiresOwnAppleKeys: ownKeysToRetire(facts, unlocked, guards: guards), synced: synced, words: words)
    }

    /// §3.8's joining rules: the account's mode against the library's.
    public static func joinPlan(library: ProtectionMode, vault: VaultReading?) -> JoinPlan {
        guard let vault else { return .setsUpInLibrarysMode }
        switch (vault.mode, library) {
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
        // Joining types ONE of the account's secrets (rule 14) and adopts the
        // account's pair (rule 7) — the master with its twelve-words copy makes
        // the other secret open the re-locked file.
        case .entersCastle:
            var spec = useCastleSpec(facts, unlocked, synced: true, guards: guards)
            spec.requires = .oneSecret
            spec.join = join
            return spec
        case .leavesCastle:
            return DoorSpec(requires: .oneSecret, rekeys: true, synced: true, join: join, words: [.ruleFive])
        case .sameMode:
            return DoorSpec(requires: .oneSecret, synced: true, join: join)
        case .setsUpInLibrarysMode:
            // The first device hands its library's pair up (rule 7): both
            // typed, the words never made new.
            return DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), synced: true, join: join)
        }
    }
}
