import Foundation

// VX-305 U2 — `assess(facts) → Assessment`: THE ONLY DECISION CODE (design
// §3.3). Everything that decides calls it — the route, the lobby, the doors,
// the views and the sync engine's key provider — and it is PURE: plain values
// in, plain values out; it reads no Keychain, file or network, and calls no
// writing leaf. The executor (U3) runs what it owes.
//
// The rules it encodes, each a small function below (table-tested one by one
// in AssessTests):
//   - §3.3, guards included: before unlock nothing decides; an unconfirmed
//     mode runs no custody repair in either direction; no repair makes a
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
//   - §3.10: the Touch ID road, VX-310's lobby rule as data;
//   - §3.7: the open rule — `OpenRule.swift`.

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

    // MARK: - The mode (§3.3, §3.13 step 2)

    public static func mode(_ facts: ProtectionFacts) -> ModeVerdict {
        guard let unlocked = facts.unlocked else {
            return ModeVerdict(mode: facts.rememberedModeHint, confirmed: false, source: .hintOnly, corner45: false)
        }
        if let record = unlocked.record {
            // Unconfirmed with no account is only ever corner 45's case — the
            // legacy reader records nothing else unconfirmed locally.
            return ModeVerdict(
                mode: record.mode, confirmed: record.modeConfirmed, source: .record,
                corner45: !record.modeConfirmed && record.account == nil)
        }
        // A library with no record yet: today's rule, read once (§3.15).
        let verdict = LegacyModeReader.read(unlocked.legacyModeInputs ?? LegacyModeInputs(keyFile: nil, enrolled: false))
        let recorded = verdict.migrationRecord
        return ModeVerdict(
            mode: recorded.mode, confirmed: recorded.confirmed, source: .legacyReader(verdict),
            corner45: verdict.isCorner45Ambiguous)
    }

    // MARK: - The account (§3.8's four situations)

    public static func account(_ facts: ProtectionFacts) -> AccountVerdict {
        let account = facts.unlocked?.record?.account
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
        let itemExists = fingerprint.map {
            facts.custody.contains(CustodyItemFact(fingerprint: $0, itemClass: .touchid))
        } ?? false
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
            custody: facts.custody + facts.legacyItems.compactMap { item in
                if case .silent = item.kind, let fingerprint = item.fingerprint {
                    return CustodyItemFact(fingerprint: fingerprint, itemClass: .silent)
                }
                return nil
            },
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
        guard let id = unlocked.liveKeyFileID, case .format3(let file)? = facts.catalog.keyFile(id: id)?.document
        else { return nil }
        return file
    }

    public static func repairs(
        _ facts: ProtectionFacts, _ unlocked: UnlockedFacts, mode: ModeVerdict, account: AccountVerdict,
        vault: VaultVerdict?, guards: ProtectionGuards
    ) -> (repairs: [Repair], faults: [Fault]) {
        var repairs: [Repair] = []
        var faults: [Fault] = []
        // A library with no record yet: the migration is owed, and it does its
        // own steps — no repair runs before it (§3.13).
        guard let record = unlocked.record else { return (repairs, faults) }
        // ALWAYS: the two homes agree — nothing lost by construction (newer
        // wins, the retired ids and the tree are unions).
        do {
            let memory = unlocked.memory
            var stale = memory == nil
                || memory?.currentFingerprint != record.currentFingerprint
                || memory?.keyEpoch != record.keyEpoch
                || memory?.familyTree != unlocked.familyTree
                || memory?.deviceSection != unlocked.thisMac
                || (record.modeConfirmed && memory?.lastConfirmed != ConfirmedFacts(mode: record.mode, account: record.account))
            // The key file and its mirror, for the current key: the file never
            // shrinks to match the mirror's word, nor the mirror to the file's.
            if let mirror = memory?.keyFileMirror, mirror.fingerprint == unlocked.currentFingerprint {
                if let live = liveKeyFile(facts, unlocked) {
                    if mirrorHoldsMore(mirror, than: live) {
                        repairs.append(.restoreKeyFileFromMirror)
                    } else if live != mirror {
                        stale = true
                    }
                } else {
                    repairs.append(.restoreKeyFileFromMirror)
                }
            }
            // Both gone — the live file and its mirror (a login-password holder
            // deleted the two): the newest catalogued copy of the current
            // key's file comes back (the lobby opened through such a file).
            if liveKeyFile(facts, unlocked) == nil,
               memory?.keyFileMirror.map({ $0.fingerprint != unlocked.currentFingerprint }) ?? true,
               let copy = facts.catalog.keyFiles
                .filter({ file in
                    if case .format3(let keyFile)? = file.document { return keyFile.fingerprint == unlocked.currentFingerprint }
                    return false
                })
                .max(by: { ($0.frozenAt ?? .distantPast, $0.id) < ($1.frozenAt ?? .distantPast, $1.id) }) {
                repairs.append(.restoreKeyFileFromCopy(keyFileID: copy.id))
            }
            if stale { repairs.append(.refreshMemory) }
            if unlocked.recordSection != unlocked.thisMac { repairs.append(.refreshRecordSection) }
        }
        guard let current = mode.mode else { return (repairs, faults) }
        let live = liveKeyFile(facts, unlocked)
        // §3.10: a choice of Touch ID with no item behind it records Always
        // ask quietly — NEVER a repair that makes an item (only a press does).
        if current == .castle, unlocked.thisMac.settings.gateStyle == .touchID,
           !facts.custody.contains(CustodyItemFact(fingerprint: unlocked.currentFingerprint, itemClass: .touchid)) {
            repairs.append(guards.noRepairMakesTouchIDOn
                ? .recordAlwaysAskQuietly : .makeTouchIDItem(fingerprint: unlocked.currentFingerprint))
        }
        // An unconfirmed (or ambiguous) mode runs no custody repair in either
        // direction: the library keeps today's custody shape (§3.13).
        if !mode.confirmed && guards.unconfirmedModeNoCustodyRepairOn { return (repairs, faults) }
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
        // No silent item for any key the library has had.
        for item in facts.custody where item.itemClass == .silent && tree.contains(item.fingerprint) {
            if let precondition = goesOnlyIf(item.fingerprint, current: current, live: live) {
                repairs.append(.deleteSilentItem(fingerprint: item.fingerprint, precondition: precondition))
            } else {
                faults.append(.silentItemIsOnlyRoad(fingerprint: item.fingerprint))
            }
        }
        // …including the per-library-ID silent items the migration kept, and
        // no 13p escrow item holding any of its keys — once the history holds it.
        for item in facts.legacyItems {
            guard let fingerprint = item.fingerprint, tree.contains(fingerprint) else { continue }
            switch item.kind {
            case .silent, .escrow:
                if let precondition = goesOnlyIf(fingerprint, current: current, live: live) {
                    repairs.append(.deleteLegacyItem(item.kind, fingerprint: fingerprint, precondition: precondition))
                } else if case .silent = item.kind {
                    faults.append(.silentItemIsOnlyRoad(fingerprint: fingerprint))
                }
            case .gated:
                continue
            }
        }
        // No format-1/2 key file beside the library once the history verifiably
        // holds its key (a key the fold couldn't reach keeps its file).
        for file in facts.catalog.keyFiles where file.role == .besideLibrary || file.role == .setAside {
            guard case .legacy? = file.document, let fingerprint = file.fingerprint,
                  let precondition = goesOnlyIf(fingerprint, current: current, live: live) else { continue }
            repairs.append(.deleteLegacyKeyFile(keyFileID: file.id, precondition: precondition))
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
        guard unlocked.record != nil else { return [.migrate] }
        let reading = facts.freshVault(for: account.account)
        // This device's own act in flight is its plan's to finish — never read
        // as the account moving elsewhere.
        let ownActInFlight = unlocked.thisMac.actInFlight != nil
        if !mode.confirmed {
            if mode.corner45 {
                // Corner 45: the one-time notice; her answer confirms — a key
                // change when it isn't the current key's kind.
                if let answer = unlocked.corner45Answer {
                    acts.append(.confirmMode(answer, isKeyChange: answer != current))
                } else {
                    acts.append(.corner45Notice)
                }
            } else if let settled = vault?.mode.settled {
                acts.append(.confirmMode(settled, isKeyChange: settled != current))
            }
        } else if let vault, let reading, !ownActInFlight {
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
                if let known, let corpus = reading.corpusKeyID, known != corpus {
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
        if mode.confirmed, current == .castle, unlocked.thisMac.oldSharedKeyStillStanding,
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
        guard mode.confirmed else { return [] }
        let mac8 = unlocked.thisMac.mac8
        var subjects: [String] = []
        for file in facts.catalog.keyFiles {
            let isLive = file.id == unlocked.liveKeyFileID
            guard isLive ? mode.mode == .standard : (file.role == .ownKeyFile && file.mac.isMac(mac8)) else { continue }
            guard case .format3(let keyFile)? = file.document else { continue }
            if let wrap = keyFile.apple {
                if !facts.appleKeys.readable.contains(wrap.keyID) { subjects.append(file.id) }
            } else if isLive, unlocked.thisMac.appleKeys.contains(where: { $0.isOwnLibraryKey && $0.retiredAt == nil }),
                      !unlocked.thisMac.appleKeys.contains(where: {
                          $0.isOwnLibraryKey && $0.retiredAt == nil && facts.appleKeys.readable.contains($0.id)
                      }) {
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
        return facts.catalog.keyFiles.contains { file in
            switch file.document {
            case .format3(let keyFile)?: return keyFile.sharedApple != nil
            case .legacy(let legacy)?: return legacy.envelope.apple != nil
            case nil: return false
            }
        }
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
        let liveLibrary = unlocked.record?.libraryID
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
        // The live library — local or synced, once its mode is confirmed
        // Standard (decision 35) — gains this Mac's own Apple key.
        let live = mode.mode == .standard && mode.confirmed
            && (account.account == nil || facts.freshVault(for: account.account) != nil)
            && liveKeyFile(facts, unlocked)?.apple == nil
        return MovePlan(otherLibraries: others, liveLibrary: live)
    }

    /// A key file whose current key is a Standard key (an Apple wrap).
    static func standardShaped(_ file: CatalogKeyFile) -> Bool {
        switch file.document {
        case .format3(let keyFile)?: return keyFile.apple != nil || keyFile.sharedApple != nil
        case .legacy(let legacy)?: return legacy.envelope.apple != nil
        case nil: return false
        }
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
        guard unlocked.record != nil else {
            for door in Door.allCases { doors[door] = .refused(.migrationOwed) }
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
            if current == .castle && mode.confirmed { return .refused(.wrongMode(.castle)) }
            if !mode.confirmed { return .refused(.modeNotConfirmed) }
            if signedOut { return .refused(.signedOutUseThisMacOnly) }
            let checks = retirementChecks(facts, finder: finder, account: account,
                                          actAccount: inSync ? account.account : nil, guards: guards)
            if let stop = checks?.doorStops.first { return .refused(.vaultOnOldSharedKey(account: stop)) }
            return .open(useCastleSpec(facts, unlocked, finder: finder, checks: checks, synced: inSync, guards: guards))
        }()
        // USE STANDARD (corner 45's Castle-not-yet-confirmed included: "Use
        // Standard offered as the key change it now is").
        doors[.useStandard] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            if current == .standard { return .refused(.wrongMode(.standard)) }
            if !mode.confirmed && !mode.corner45 { return .refused(.modeNotConfirmed) }
            if signedOut { return .refused(.signedOutUseThisMacOnly) }
            return .open(DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: inSync,
                                  words: [.ruleFive]))
        }()
        // REPLACE ALL KEYS — an enrolled library's security act.
        doors[.replaceAllKeys] = {
            if let refusal = gate(syncedAct: true) { return .refused(refusal) }
            if !mode.confirmed { return .refused(.modeNotConfirmed) }
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
            guard mode.confirmed else { return .refused(.modeNotConfirmed) }
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
            guard current == .castle, mode.confirmed, section.oldSharedKeyStillStanding else {
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
            if !mode.confirmed { return .refused(.modeNotConfirmed) }
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
        doors[.finishLeavingCastle] = {
            guard let unfinished = vault?.unfinishedLeave else { return .refused(.nothingToDo) }
            if followOwed && !unfinished.namedKeyReadableHere { return .refused(.followOwed) }
            return .open(DoorSpec(requires: .none, synced: true))
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
