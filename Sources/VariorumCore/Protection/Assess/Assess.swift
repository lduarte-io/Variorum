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
//     a lost Apple road offers Re-link's library arm (no repair mints);
//   - §3.5: one Apple key per library per Mac and one per account; entering
//     Castle retires every own key this Mac's section lists; copies under a key
//     this Mac can't delete are named at Use Castle's door; the old shared key —
//     what still needs it, what its retirement would strand, what would then
//     hang on an Apple key alone, and the door-time vault check; the move's
//     subjects (gifts only for this Mac's copies);
//   - §3.9: the vault's three states; a follower's hold; only a device that
//     reads the leave's named key completes it; sync keys held by what they
//     reach;
//   - §3.8: the four account situations; every leave re-keying in both modes;
//     the joining rules;
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
    var actAccount: String?
    if case .inSync(let synced) = account.situation { actAccount = synced }
    let retirement = AssessRules.retirementChecks(
        facts, finder: finder, account: account, actAccount: actAccount, guards: guards)
    let doors = AssessRules.doors(facts, mode: mode, account: account, vault: vault, acts: acts, finder: finder,
                                  faults: faults, guards: guards)
    var opensWith: [String: OpensWith] = [:]
    for copy in facts.catalog.copies { opensWith[copy.id] = finder.opensWith(copy: copy) }
    return Assessment(
        launch: launch, mode: mode, account: account, vault: vault, lobby: AssessRules.lobby(facts, finder: finder),
        touchID: touchID, repairs: repairs, faults: faults, acts: acts, doors: doors,
        movePlan: AssessRules.movePlan(facts, mode: mode, account: account, guards: guards),
        retirement: retirement, opensWith: opensWith)
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
        var mayCompleteLeave = false
        var unfinished: UnfinishedLeave?
        if case .leavingCastle(let id) = mode {
            let readable = facts.appleKeys.readable.contains(id)
            mayCompleteLeave = guards.leaveIDGatesCompletionOn ? readable : true
            // A leave this device isn't running: the finish door's facts.
            if facts.unlocked?.thisMac.actInFlight?.act != .leaveCastle {
                unfinished = UnfinishedLeave(
                    device: reading.updatedByDevice, day: reading.updatedAt, namedAppleKeyID: id,
                    namedKeyReadableHere: readable)
            }
        }
        let custody: SyncKeysCustody
        switch mode {
        case .castle: custody = .castleWay
        case .leavingCastle: custody = guards.castleKindCustodyThroughLeaveOn ? .castleWay : .silent
        case .standard: custody = .silent
        }
        return VaultVerdict(
            mode: mode, rotationInProgress: reading.rotationInProgress, mayCompleteLeave: mayCompleteLeave,
            completesWithoutAppleCopy: reading.previousCorpusKeyID != nil && reading.appleKeyID == nil && !reading.hasAppleWrap,
            syncKeysCustody: custody, followHoldsLibraryRekey: reading.rotationInProgress, unfinishedLeave: unfinished)
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
        let section = facts.unlocked?.thisMac
        let notReadable = Set(section?.appleKeys.filter { $0.isOwnLibraryKey && $0.retiredAt == nil }.map(\.id) ?? [])
            .subtracting(facts.appleKeys.readable)
        let session = facts.session.accountID
        let vault = facts.vault.flatMap { $0.accountID == session ? $0 : nil }
        return RouteFinder(RouteFacts(
            catalog: facts.catalog, liveKeyFileID: facts.unlocked?.liveKeyFileID ?? facts.catalog.liveKeyFile?.id,
            custody: facts.custody,
            readableAppleKeyIDs: facts.appleKeys.readable, oldSharedAppleKeyID: facts.appleKeys.oldSharedID,
            ownAppleKeyIDsNotReadableHere: notReadable, vaultRecoveryWrap: vault?.recoveryWrap,
            signedInToVault: vault != nil))
    }

    // MARK: - The lobby (before unlock: roads only)

    public static func lobby(_ facts: ProtectionFacts, finder: RouteFinder) -> LobbyRoads {
        let fingerprint = facts.unlocked?.currentFingerprint ?? facts.slotFingerprintHint
        let opens = fingerprint.map { finder.opensWith(fingerprint: $0) } ?? OpensWith(routes: [])
        // Roads needing no person: every silent item (whatever fingerprint it
        // names — each verifies itself) and an Apple wrap readable here.
        var automatic = opens.routes.filter { [.appleAccount, .oldSharedAppleKey].contains($0.opener) }
        for item in facts.custody where item.itemClass == .silent {
            automatic.append(Route(opener: .thisMac, steps: [.custody(fingerprint: item.fingerprint, itemClass: .silent)]))
        }
        return LobbyRoads(
            automatic: automatic, custodyItems: facts.custody,
            typed: OpensWith(routes: opens.routes.filter { $0.opener.isSecret && $0.opener != .accountOnline }),
            vaultRoad: facts.session.accountID != nil)
    }

    // MARK: - Repairs (§3.3, guards included)

    static func liveKeyFile(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts) -> KeyFile? {
        guard let id = unlocked.liveKeyFileID else { return nil }
        return facts.catalog.keyFile(id: id)?.document
    }

    /// P-U4-6 (ratified (a), "Memory wins"; §3.6 "a library file replayed
    /// alone loses to the memory"): the key file that PROVES a library file
    /// older than this Mac's own memory loses to it — the memory's current
    /// key's file whose history holds the file's key. The live one; or, when
    /// the file came back ALONE — the live place holds no key file of THIS
    /// library (absent, or another library's, as a landing that set this one
    /// aside leaves it) — the memory's own sealed mirror of that file (VX-305
    /// ladder round 1, NEW-1). A whole-pair restore — the file's own key file
    /// live beside it, her Time Machine restore (P-U4-12) — never qualifies;
    /// nor does a file only the ANCHOR reaches (P-U4-6's residue: a leave's
    /// new key takes no history). One reading, shared by assess's arm, the
    /// executor's re-key and the settle that runs it first.
    static func olderLibraryFileProof(
        memoryFingerprint: String, mirror: KeyFile?, live: KeyFile?, fileFingerprint: String, libraryID: String
    ) -> KeyFile? {
        func holds(_ file: KeyFile) -> Bool { file.history.contains { $0.fingerprint == fileFingerprint } }
        if let live, live.fingerprint == memoryFingerprint { return holds(live) ? live : nil }
        guard live.map({ $0.libraryID != libraryID }) ?? true, let mirror, mirror.fingerprint == memoryFingerprint,
              mirror.libraryID == libraryID, holds(mirror) else { return nil }
        return mirror
    }

    public static func repairs(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, mode: ModeVerdict, account: AccountVerdict,
        vault: VaultVerdict?, guards: ProtectionGuards
    ) -> (repairs: [Repair], faults: [Fault]) {
        var repairs: [Repair] = []
        var faults: [Fault] = []
        let record = unlocked.record
        // FIRST: a library file older than what this Mac remembers (a library
        // file replayed alone, §3.6) loses to the memory — before any repair
        // moves toward its stale record.
        // (Only THIS Mac's memory speaks for it: an item another identity
        // left — a replayed one from the Mac this one replaced — names
        // another section, and its versions mean nothing here; VX-305 U4, the
        // soak's seed 17.)
        let ownMemory = unlocked.memory.flatMap { $0.deviceSection.deviceID == unlocked.thisMac.deviceID ? $0 : nil }
        // (The proof: the live file of the memory's key, or — the file back
        // alone, the live place holding no file of this library — the
        // memory's own sealed mirror; `olderLibraryFileProof`.)
        if guards.libraryFileLosesToMemoryOn, let memory = ownMemory, memory.keyEpoch > record.keyEpoch,
           memory.currentFingerprint != record.currentFingerprint,
           olderLibraryFileProof(
               memoryFingerprint: memory.currentFingerprint, mirror: memory.keyFileMirror, live: liveKeyFile(facts, unlocked),
               fileFingerprint: unlocked.currentFingerprint, libraryID: record.libraryID) != nil {
            return ([.rekeyOlderLibraryFile(toFingerprint: memory.currentFingerprint)], faults)
        }
        // …and under the SAME key: a library file replayed from before an act
        // that changed the library's facts without a re-key (joining an
        // account) — this Mac's section in the memory is newer than the file's,
        // and the facts last confirmed here differ from the file's.
        if guards.libraryFileLosesToMemoryOn, let memory = ownMemory, memory.keyEpoch == record.keyEpoch,
           memory.currentFingerprint == record.currentFingerprint, let recordSection = unlocked.recordSection,
           memory.deviceSection.version > recordSection.version, let confirmed = memory.lastConfirmed,
           confirmed != ConfirmedFacts(mode: record.mode, account: record.account),
           unlocked.familyTree.entry(record.currentFingerprint).map({ $0.kind == confirmed.mode }) ?? true {
            return ([.restoreRecordFactsFromMemory], faults)
        }
        // ALWAYS: the two homes agree — nothing lost by construction (newer
        // wins, the retired ids and the tree are unions).
        do {
            let memory = unlocked.memory
            var stale = memory == nil
                || memory?.currentFingerprint != record.currentFingerprint
                || memory?.keyEpoch != record.keyEpoch
                || memory?.familyTree != unlocked.familyTree
                || memory?.deviceSection != unlocked.thisMac
                || memory?.lastConfirmed != ConfirmedFacts(mode: record.mode, account: record.account)
            // The key file and its mirror, for the current key: the file never
            // shrinks to match the mirror's word, nor the mirror to the file's.
            if let mirror = memory?.keyFileMirror, mirror.fingerprint == unlocked.currentFingerprint {
                if let live = liveKeyFile(facts, unlocked) {
                    if live.fingerprint != mirror.fingerprint {
                        // Another key's file in the live place with nothing in
                        // flight: an act its own identity can't resume (a Mac
                        // replaced mid-act) left it — the roll back's restore
                        // (VX-305 U4, found by the scenario world).
                        repairs.append(.restoreKeyFileFromMirror)
                    } else if mirrorHoldsMore(mirror, than: live) {
                        repairs.append(.restoreKeyFileFromMirror)
                    } else if live != mirror {
                        stale = true
                    }
                } else {
                    repairs.append(.restoreKeyFileFromMirror)
                }
            }
            // No file of the current key in the live place — both gone (a
            // login-password holder deleted the live file and its mirror), OR
            // ANOTHER key's file there with no mirror of the current key's (a
            // roll back with no plan to trust and the memory item gone: VX-305
            // ladder round 1, the MAJOR — §3.3's "Always: the record, what this
            // Mac remembers and the key file agree") — with nothing in flight:
            // the newest catalogued frozen copy of the current key's own file,
            // same library, comes back (the executor sets another key's file
            // ASIDE first, never deleting it). This repairs the LIVE KEY FILE
            // from this Mac's own catalogued frozen pair: it never offers, opens
            // or restores a library copy, never touches the library file and
            // adds no unlock-screen face — it is not her dropped newest-copy
            // offer (P-U4-10, "lets drop the healthy copy deal"). A restored
            // file keeps the locks of its day; re-locking under current secrets
            // is P-R1-1's door. With no such copy the state stays — P-R1-1.
            if unlocked.thisMac.actInFlight == nil,
               liveKeyFile(facts, unlocked)?.fingerprint != unlocked.currentFingerprint,
               memory?.keyFileMirror.map({ $0.fingerprint != unlocked.currentFingerprint }) ?? true,
               let copy = facts.catalog.keyFiles
                .filter({ file in
                    guard let keyFile = file.document else { return false }
                    return keyFile.fingerprint == unlocked.currentFingerprint && keyFile.libraryID == record.libraryID
                })
                .max(by: { ($0.frozenAt ?? .distantPast, $0.id) < ($1.frozenAt ?? .distantPast, $1.id) }) {
                repairs.append(.restoreKeyFileFromCopy(keyFileID: copy.id))
            }
            if stale { repairs.append(.refreshMemory) }
            if unlocked.recordSection != unlocked.thisMac { repairs.append(.refreshRecordSection) }
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
        // CURRENT key's: another key's file in the live place (a roll back
        // with nothing to restore from — VX-305 ladder round 1) is no "Castle
        // key with an Apple wrap" and owes no Standard wrap — it is its own
        // fault. Mid-act the live file is the act's new key's by design (no
        // fault). The raw file stays for the arms above that need it whatever
        // its key (`rekeyOlderLibraryFile`, the restores).
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

    /// Does the sealed mirror hold a road the live file (same key) lost — a
    /// secret or master lock, a history entry, the anchor? Apple wraps are
    /// left out: they leave legitimately and a repair never re-adds one.
    static func mirrorHoldsMore(_ mirror: KeyFile, than live: KeyFile) -> Bool {
        let roads: Set<KeyFileRoad> = [.passphrase, .words, .master, .masterThroughWords]
        if !mirror.roads.intersection(roads).isSubset(of: live.roads) { return true }
        if !Set(mirror.history.map(\.fingerprint)).isSubset(of: Set(live.history.map(\.fingerprint))) { return true }
        if mirror.anchor != nil && live.anchor == nil { return true }
        return !Set(mirror.keptAnchors.map(\.outgoingFingerprint)).isSubset(of: Set(live.keptAnchors.map(\.outgoingFingerprint)))
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
        let tree = Set(unlocked.familyTree.fingerprints).union([current])
        // No Apple key of this Mac's own for the library left unretired in
        // Castle — entering Castle retires every one (§3.5); an entry whose
        // last steps no one ran (a Mac replaced past the commit point, its act
        // its predecessor's) leaves them listed (VX-305 U4, the scenario world).
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
        if let live, live.apple != nil || live.sharedApple != nil, let id = unlocked.liveKeyFileID {
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
        if let shared = unlocked.thisMac.oldSharedKey, shared.retiredAt != nil, facts.appleKeys.oldSharedID == shared.id {
            repairs.append(.deleteRetiredOldSharedKey(id: shared.id))
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
            case .leavingCastle where current == .castle:
                acts.append(.follow(.intoStandard, typesOneSecret: true, holdsLibraryRekey: true))
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
        let lost = relinkSubjects(facts, unlocked, mode: mode)
        if !lost.isEmpty { acts.append(.relinkLibraryArm(keyFileIDs: lost)) }
        if current == .castle, unlocked.thisMac.oldSharedKeyStillStanding,
           unlocked.memory?.nudgeDismissals[retireOldSharedKeyNudge] == nil {
            acts.append(.retireOldSharedKeyAsk)
        }
        if touchID.rearmQuestion { acts.append(.touchIDRearmQuestion) }
        return acts
    }

    /// The nudge name the old shared key's one calm ask is dismissed under.
    public static let retireOldSharedKeyNudge = "retire-old-shared-key"

    /// Re-link's library arm (§3.9): every Standard key file this Mac holds —
    /// the live one, and this Mac's own key files for other libraries — whose
    /// own Apple key can't be read here.
    static func relinkSubjects(_ facts: ProtectionFacts, _ unlocked: UnlockedFacts, mode: ModeVerdict) -> [String] {
        let mac8 = unlocked.thisMac.mac8
        var subjects: [String] = []
        for file in facts.catalog.keyFiles {
            let isLive = file.id == unlocked.liveKeyFileID
            guard isLive ? mode.mode == .standard : (file.role == .ownKeyFile && file.mac.isMac(mac8)) else { continue }
            guard let keyFile = file.document else { continue }
            // The live place's file counts only when it is the current key's
            // (another key's file there is its own fault — VX-305 ladder round 1).
            if isLive, keyFile.fingerprint != unlocked.currentFingerprint { continue }
            let readsOwn = unlocked.thisMac.appleKeys.contains {
                $0.isOwnLibraryKey && $0.retiredAt == nil && facts.appleKeys.readable.contains($0.id)
            }
            if let wrap = keyFile.apple {
                if !facts.appleKeys.readable.contains(wrap.keyID) { subjects.append(file.id) }
            } else if isLive, unlocked.thisMac.appleKeys.contains(where: { $0.isOwnLibraryKey && $0.retiredAt == nil }), !readsOwn {
                subjects.append(file.id)
            } else if isLive, unlocked.record.account == nil, !readsOwn {
                // A LOCAL Standard library whose live file carries no Apple wrap
                // and whose Mac reads no own key for it — the road is lost even
                // when this identity never listed the key that carried it (a Mac
                // replaced with no memory item, after a leave found its own key
                // gone — VX-305 U4, the soak's seed 4). Synced libraries keep
                // decision 35's road (a held landing waits for Resume Sync).
                subjects.append(file.id)
            }
        }
        return subjects
    }

    // MARK: - The old shared key (§3.5 points 2 and 4)

    /// Does this store still have the old shared key — this device's section
    /// lists it standing, the old-name item is readable here, or a catalogued
    /// key file carries its wrap?
    static func oldSharedKeyStands(_ facts: ProtectionFacts) -> Bool {
        if facts.unlocked?.thisMac.oldSharedKeyStillStanding == true { return true }
        if facts.appleKeys.oldSharedID != nil { return true }
        return facts.catalog.keyFiles.contains { $0.document?.sharedApple != nil }
    }

    /// The old shared key's id: the readable item's, else the one this
    /// device's section recorded.
    static func oldSharedID(_ facts: ProtectionFacts) -> String? {
        facts.appleKeys.oldSharedID ?? facts.unlocked?.thisMac.oldSharedKey?.id
    }

    /// **The checks at the door** (§3.5 point 4). `actAccount`: the account
    /// the act itself moves into Castle (its vault never stops it).
    public static func retirementChecks(
        _ facts: ProtectionFacts, finder: RouteFinder, account: AccountVerdict, actAccount: String?,
        guards: ProtectionGuards
    ) -> RetirementChecks? {
        guard let unlocked = facts.unlocked, oldSharedKeyStands(facts) else { return nil }
        let held = Set(unlocked.familyTree.fingerprints).union([unlocked.currentFingerprint])
            .union(liveKeyFile(facts, unlocked)?.heldFingerprints ?? [])
        let routes = finder.retirementRoutes(thisMac: unlocked.thisMac.deviceID, libraryFingerprints: held)
        // Accounts named by the record or this device's section whose vault
        // isn't read this session — "can't be checked".
        let readable = facts.vault.flatMap { $0.accountID == facts.session.accountID ? $0.accountID : nil }
        var named = Set(unlocked.thisMac.appleKeys.compactMap { $0.purpose == .account ? $0.accountID : nil })
        if let record = account.account { named.insert(record) }
        let unchecked = named.filter { $0 != readable }.sorted()
        // The vaults that stop the act at its door.
        var stops: [String] = []
        if guards.doorTimeVaultCheckOn, let shared = oldSharedID(facts) {
            if let vault = facts.vault, vault.accountID == readable, vault.hasAppleWrap, vault.appleKeyID == shared,
               vault.accountID != actAccount {
                stops.append(vault.accountID)
            }
            // While signed out (or in another account): the library's account,
            // as this device last knew its vault.
            if let record = account.account, record != readable, record != actAccount,
               unlocked.thisMac.appleKeys.contains(where: {
                   $0.purpose == .account && $0.accountID == record && $0.id == shared && $0.retiredAt == nil
               }) {
                stops.append(record)
            }
        }
        return RetirementChecks(routes: routes, uncheckedAccounts: unchecked, doorStops: stops)
    }

    /// **The move's subjects** (§3.5 point 2): keys of this Mac's own beside
    /// the old one. Gifts only for this Mac's copies.
    public static func movePlan(
        _ facts: ProtectionFacts, mode: ModeVerdict, account: AccountVerdict, guards: ProtectionGuards
    ) -> MovePlan {
        guard let unlocked = facts.unlocked else { return MovePlan(otherLibraries: [], liveLibrary: false) }
        let mac8 = unlocked.thisMac.mac8
        let liveLibrary = unlocked.record.libraryID
        var newest: [String: CatalogCopy] = [:]
        for copy in facts.catalog.copies {
            guard let library = copy.library, library != liveLibrary, copy.stamp != nil else { continue }
            if guards.giftsOnlyForThisMacsCopiesOn, !copy.mac.isMac(mac8) { continue }
            if let held = newest[library], (held.stamp ?? .distantPast) >= (copy.stamp ?? .distantPast) { continue }
            newest[library] = copy
        }
        let gifted = Set(facts.catalog.keyFiles.filter { $0.role == .ownKeyFile && $0.mac.isMac(mac8) }.compactMap(\.library))
        let others = newest.filter { library, copy in
            !gifted.contains(library) && facts.catalog.servingKeyFiles(of: copy).first.map(standardShaped) == true
        }.keys.sorted()
        // The live library — local or synced, in Standard (decision 35) —
        // gains this Mac's own Apple key.
        let live = mode.mode == .standard
            && (account.account == nil || facts.freshVault(for: account.account) != nil)
            && liveKeyFile(facts, unlocked)?.apple == nil
        return MovePlan(otherLibraries: others, liveLibrary: live)
    }

    /// A key file whose current key is a Standard key (an Apple wrap).
    static func standardShaped(_ file: CatalogKeyFile) -> Bool {
        guard let keyFile = file.document else { return false }
        return keyFile.apple != nil || keyFile.sharedApple != nil
    }

    // MARK: - Doors

    public static func doors(
        _ facts: ProtectionFacts, mode: ModeVerdict, account: AccountVerdict, vault: VaultVerdict?,
        acts: [OwedAct], finder: RouteFinder, faults: [Fault], guards: ProtectionGuards
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
        func anchorWords(_ door: SecretReplacingDoor) -> [Words] {
            finder.anchorSentence(for: door).map { [.anchor($0)] } ?? []
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
        // The leave requirements, by mode (§3.8).
        let leaveRequires: SecretRequirement = current == .castle
            ? .passphraseAndWords(wordsMayBeNew: true) : .passphraseOrSetNewAndWordsOrMadeNew
        let leaveRekeys = guards.rekeyAtEveryCrossingOn || current == .castle

        // USE CASTLE.
        doors[.useCastle] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            if current == .castle { return .refused(.wrongMode(.castle)) }
            if signedOut { return .refused(.signedOutUseThisMacOnly) }
            let checks = retirementChecks(facts, finder: finder, account: account,
                                          actAccount: inSync ? account.account : nil, guards: guards)
            if let stop = checks?.doorStops.first { return .refused(.vaultOnOldSharedKey(account: stop)) }
            return .open(useCastleSpec(facts, unlocked, finder: finder, checks: checks, synced: inSync, guards: guards))
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
            let onOldKey = reading.map { $0.hasAppleWrap && $0.appleKeyID != nil && $0.appleKeyID == oldSharedID(facts) } ?? false
            return .open(DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: true), rekeys: true, synced: true,
                                  relinksAccountFirst: onOldKey, words: anchorWords(.replacesWords)))
        }()
        // THE KEY DOORS — re-wrap the current key only; each says its anchor
        // sentence while an anchor exists.
        for (door, secretDoor, requires) in [
            (Door.changePassphrase, SecretReplacingDoor.changePassphrase, SecretRequirement.currentPassphrase),
            (.newWords, .replacesWords, .currentPassphrase),
            (.resetForgottenPassphrase, .resetForgottenPassphrase, current == .castle ? .touchIDOrWords : .plainConfirm),
        ] {
            doors[door] = {
                if otherAccount { return .refused(.otherAccountSignedIn) }
                if followOwed { return .refused(.followOwed) }
                if inSync, reading == nil { return .refused(.needsFreshVault) }
                return .open(DoorSpec(requires: requires, synced: inSync, words: anchorWords(secretDoor)))
            }()
        }
        // RE-LINK the account (Standard; a fresh account key minted at the
        // press, never the old shared key).
        doors[.relinkAccount] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            guard current == .standard else { return .refused(.wrongMode(current)) }
            guard inSync, let reading else { return .refused(inSync ? .needsFreshVault : .notSynced) }
            let unreadable = reading.appleKeyID.map { !facts.appleKeys.readable.contains($0) } ?? true
            let onOldKey = reading.appleKeyID != nil && reading.appleKeyID == oldSharedID(facts)
            guard unreadable || onOldKey else { return .refused(.nothingToDo) }
            return .open(DoorSpec(requires: .currentPassphrase, synced: true, words: [.relinkConsent]))
        }()
        // RE-LINK's library arm.
        doors[.relinkLibraryArm] = {
            if otherAccount { return .refused(.otherAccountSignedIn) }
            let subjects = relinkSubjects(facts, unlocked, mode: mode)
            return subjects.isEmpty ? .refused(.nothingToDo) : .open(DoorSpec(requires: .none))
        }()
        // RETIRE THE OLD APPLE KEY — a library already in Castle before this change.
        doors[.retireOldSharedKey] = {
            if let refusal = gate(syncedAct: false) { return .refused(refusal) }
            guard current == .castle, section.oldSharedKeyStillStanding else {
                return .refused(.nothingToDo)
            }
            let checks = retirementChecks(facts, finder: finder, account: account, actAccount: nil, guards: guards)
            if let stop = checks?.doorStops.first { return .refused(.vaultOnOldSharedKey(account: stop)) }
            return .open(DoorSpec(requires: .none, retiresOldSharedKey: true,
                                  words: checks.map { [.retirementSheet($0)] } ?? []))
        }()
        // TURN ON SYNC — a local library; the joining rules.
        doors[.turnOnSync] = {
            guard case .localOnly = account.situation else { return .refused(.nothingToDo) }
            guard signedIn else { return .refused(.noAccountSignedIn) }
            let join = joinPlan(library: current, vault: facts.vault.flatMap { $0.accountID == facts.session.accountID ? $0 : nil })
            return .open(joinSpec(join, facts, unlocked, finder: finder, guards: guards))
        }()
        // THE LEAVES — every one re-keys, in both modes (§3.8).
        for door in [Door.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
            doors[door] = {
                if otherAccount { return .refused(.otherAccountSignedIn) }
                if followOwed, door != .deleteAccountHere { return .refused(.followOwed) }
                guard inSync || signedOut else { return .refused(.notSynced) }
                if door == .deleteAccountHere, !inSync { return .refused(.noAccountSignedIn) }
                return .open(DoorSpec(requires: leaveRequires, rekeys: leaveRekeys, words: anchorWords(.replacesWords)))
            }()
        }
        // MOVE it to the signed-in account — leave X (a re-key), join Y.
        doors[.moveToSignedInAccount] = {
            guard otherAccount else { return .refused(.nothingToDo) }
            let join = joinPlan(library: current, vault: facts.vault.flatMap { $0.accountID == facts.session.accountID ? $0 : nil })
            var spec = joinSpec(join, facts, unlocked, finder: finder, guards: guards)
            spec.rekeys = spec.rekeys || leaveRekeys
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
        // FINISH LEAVING CASTLE, started on another device.
        // The press waits for the named key and mints a fresh account key
        // only if that one never arrives (§3.9) — so it stands whether or not
        // the named key is readable here (`unfinishedLeave.namedKeyReadableHere`
        // tells the face which it is doing); a device that still owes the
        // follow types its one secret at it. VX-305 U4, found by the scenario
        // world: refusing it while the follow was owed left an account whose
        // acting device was lost before its key reached iCloud mid-leave for
        // ever — every other device owes that follow.
        doors[.finishLeavingCastle] = {
            guard vault?.unfinishedLeave != nil else { return .refused(.nothingToDo) }
            let typed = acts.contains { if case .follow(_, let typed, _) = $0 { return typed } else { return false } }
            return .open(DoorSpec(requires: typed ? .oneSecret : .none, synced: true))
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
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, finder: RouteFinder, checks: RetirementChecks?,
        synced: Bool, guards: ProtectionGuards
    ) -> DoorSpec {
        var words: [Words] = [.floorSentence, .exportAPlainCopyFirst]
        // Copies under a key this Mac can't delete — one left in an Apple
        // account it no longer uses — named, with what that means.
        let undeletable = facts.catalog.copies.filter {
            finder.opensWith(copy: $0).openers.contains(.appleKeyNotReadableHere)
        }.map(\.id)
        if !undeletable.isEmpty { words.append(.copiesUnderAKeyThisMacCantDelete(undeletable)) }
        if let checks { words.append(.retirementSheet(checks)) }
        if unlocked.thisMac.settings.scheduledExport { words.append(.scheduledExportTurnsOff) }
        // An anchor those secrets can't open is kept, and the door says so.
        if let sentence = finder.anchorSentence(for: .useCastleCannotFold) { words.append(.anchor(sentence)) }
        return DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: true), rekeys: true,
            retiresOwnAppleKeys: ownKeysToRetire(facts, unlocked, guards: guards),
            retiresOldSharedKey: checks != nil, synced: synced, words: words)
    }

    /// §3.8's joining rules: the account's mode against the library's.
    public static func joinPlan(library: ProtectionMode, vault: VaultReading?) -> JoinPlan {
        guard let vault, let account = vault.mode.settled else {
            return vault == nil ? .setsUpInLibrarysMode : .sameMode
        }
        switch (account, library) {
        case (.castle, .standard): return .entersCastle
        case (.standard, .castle): return .leavesCastle
        default: return .sameMode
        }
    }

    static func joinSpec(
        _ join: JoinPlan, _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, finder: RouteFinder,
        guards: ProtectionGuards
    ) -> DoorSpec {
        switch join {
        case .entersCastle:
            var spec = useCastleSpec(facts, unlocked, finder: finder,
                                     checks: retirementChecks(facts, finder: finder, account: account(facts),
                                                              actAccount: facts.session.accountID, guards: guards),
                                     synced: true, guards: guards)
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
