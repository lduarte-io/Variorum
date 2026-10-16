import CryptoKit
import Foundation

// VX-305 U3 — THE STEPS THE ACTS SHARE. Every step is idempotent (a crash
// between a step's write and the plan marking it done re-runs it), and the
// library re-key runs in PREPARE-THEN-COMMIT order (§3.4, VX-235's class):
//   the new key's custody item → the new key file (the history it takes, the
//   anchor carried; leaving Castle, the anchor written FIRST into the outgoing
//   file) → the library re-encrypted into a staged file → the record written
//   into the staged file → THE SWAP (the commit point) → what this Mac
//   remembers → the outgoing key's custody items go.
// Copies pause from the prepare to the swap. Whatever state a crash leaves, a
// road opens the file: the old custody item (it goes only after the swap),
// the new key, the new key through the history — or, leaving Castle, the
// anchor with the secrets of the leave.

/// The library re-key's steps, in prepare-then-commit order (guard off —
/// DEBUG mutation pins only — the swap runs first and the key file after it).
enum LibraryRekey {
    static func steps(_ guards: ProtectionGuards) -> [String] {
        guards.prepareBeforeCommitOn
            ? ["custodyItem", "keyFile", "stage", "recordIntoStaged", "swap"]
            : ["stage", "recordIntoStaged", "swap", "custodyItem", "keyFile"]
    }

    static let newKeySteps: Set<String> = ["custodyItem", "keyFile", "stage", "recordIntoStaged", "swap"]
}

extension ActContext {
    static func fp(_ key: StoreKey) -> String { StoreKeyEnvelope.fingerprint(of: key) }
    static func fp8(_ fingerprint: String?) -> String { ProtectionExecutor.fp8(fingerprint) }

    var deviceID: String { library.section.deviceID }
    var deviceName: String { executor.configuration.deviceName }
    var accountID: String? { parameters.accountID ?? library.record?.account }

    /// The act's OUTGOING key — the library's key at its begin: in hand
    /// before the swap; after it, through the new file's history (none after a
    /// leave — the anchor holds it).
    var fromKey: StoreKey? {
        if let heldFromKey { return heldFromKey }
        if library.fingerprint == plan.fromFingerprint { return library.key }
        if let from = plan.fromFingerprint, let live = library.keyFile, live.fingerprint == library.fingerprint {
            return try? live.historyKey(from, currentKey: library.key)
        }
        return nil
    }

    func libraryOpens(_ key: StoreKey) throws -> Bool { try leaves.library.libraryOpens(with: key) }

    // MARK: - Locks for a new key file

    /// The new key's locks from the secrets in hand: the passphrase (the
    /// door's derived key — its descriptor reused), the words, the master
    /// with its twelve-words copy (§3.5a — the vault's recovery wrap, byte for
    /// byte), and an Apple key (a Standard key only).
    func newLocks(passphrase: Bool, words: Bool, master: Bool, apple: AppleKeyMaterial? = nil) throws -> NewKeyLocks {
        var locks = NewKeyLocks(apple: apple)
        if passphrase { locks.passphrase = try requirePassphrase() }
        if words {
            guard let wordsKey = secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
            locks.words = wordsKey
        }
        if master, let account = accountID {
            // The master as the vault holds it now (read this session), else
            // custody's — a crash under Always ask lost the session's copy,
            // and the secrets in hand open the vault's.
            let snapshot = executor.freshVaults[account]
            guard let held = try snapshot.map({ try material(for: $0) }) ?? syncMaterial() else {
                throw ExecutorRefusal.secretsRequired(act)
            }
            locks.master = held.masterSymmetricKey
            locks.masterWordsCopy = snapshot?.format.masterWrappedByRecovery
        }
        return locks
    }

    // MARK: - Prepare

    /// The new key's custody item, of its kind for life: silent for a Standard
    /// key; for a Castle key a Touch ID item made at THIS press where it chose
    /// Touch ID and a finger is enrolled — else none (Always ask: the key file
    /// and the history are the road). Copies pause from here to the swap.
    func newCustodyItem(kind: ProtectionMode) throws {
        let key = try requireToKey()
        if !(try libraryOpens(key)) { leaves.backups.pauseCopies() }
        switch kind {
        case .standard:
            try leaves.custody.writeCustody(key, itemClass: .silent)
        case .castle:
            let biometry = leaves.biometry.biometry()
            if parameters.gate == .touchID, biometry.hardware, biometry.enrolled {
                try leaves.custody.writeCustody(key, itemClass: .touchid)
            }
        }
    }

    /// The new key file — the history it takes and the anchor it carries per
    /// the crossing (§3.4); `crossing` nil builds a file with no past (a
    /// landing, a creation).
    func newKeyFile(_ crossing: KeyFileCrossing?, locks: NewKeyLocks) throws {
        let key = try requireToKey()
        if !(try libraryOpens(key)) { leaves.backups.pauseCopies() }
        if let live = library.keyFile, live.fingerprint == Self.fp(key) { return }
        guard let from = fromKey, let outgoing = library.keyFile, outgoing.fingerprint == Self.fp(from) else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        let file: KeyFile
        if let crossing {
            let rekeyed = try outgoing.rekeyed(
                crossing, from: from, to: key, locks: locks, at: now, guards: executor.guards, floor: floor)
            file = rekeyed.keyFile
            for kept in rekeyed.unopenedAnchors {
                leaves.diagnostics.report(.anchorKeptUnopened(madeAt: kept.madeAt, outgoing8: Self.fp8(kept.outgoingFingerprint)))
                outcome.notices.append(.anchorKeptUnopened(day: kept.madeAt))
            }
        } else {
            file = try KeyFile.building(libraryID: outgoing.libraryID, key: key, epoch: outgoing.epoch + 1, locks: locks)
        }
        try executor.writeLiveKeyFile(file, &library)
        log("the new key file written (\(Self.fp8(file.fingerprint)), history \(file.history.count), anchor \(file.anchor != nil))")
    }

    /// The library re-encrypted into the staged file under the new key.
    func stage() throws {
        leaves.backups.pauseCopies()
        let key = try requireToKey()
        if try libraryOpens(key) { return }
        guard let from = fromKey, try libraryOpens(from) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        try leaves.library.stageReencryption(from: from, to: key)
    }

    /// The record written into the staged file BEFORE the swap (§3.4): the
    /// new key born `kind` on this Mac, the old one retired, the epoch
    /// advanced, the mode its kind (confirmed); every device section that
    /// verifies re-sealed under the new key, this Mac's carrying the act in
    /// flight — so a copy of the swapped file carries a key and a record that
    /// match.
    func recordIntoStaged(kind: ProtectionMode) throws {
        let key = try requireToKey()
        if try libraryOpens(key) { return }
        let record = try requireRecord()
        let reach = executor.reach(key: library.key, keyFile: library.keyFile, extra: [fromKey].compactMap { $0 })
        var next = record.recordingRekey(to: Self.fp(key), kind: kind, by: deviceID, at: now)
        if parameters.changesAccount == true { next.account = parameters.targetAccount }
        let others = record.verifiedSections(reach: reach).filter { $0.deviceID != deviceID }
        next.deviceSections = try (others + [library.section]).map {
            try Sealed.sealing($0, purpose: .deviceSection, libraryID: next.libraryID, key: key)
        }
        try leaves.library.writeStagedRecord(next, with: key)
    }

    /// THE SWAP — the commit point. Idempotent: a library already under the
    /// new key was swapped.
    func swap(restage: () throws -> Void) throws {
        let key = try requireToKey()
        if !(try libraryOpens(key)) {
            if try leaves.library.stagedFingerprint() != Self.fp(key) { try restage() }
            try leaves.library.swapStaged(setAside: false)
        }
        if heldFromKey == nil { heldFromKey = fromKey }
        library.key = key
        guard let record = try leaves.library.readRecord(with: key) else { throw ExecutorRefusal.recordMissing }
        library.record = record
        library.familyTree = library.familyTree.union(record.familyTree)
        library.keyFile = try executor.liveFormat3()
        leaves.backups.resumeCopies()
        log("swapped — the library is under \(Self.fp8(Self.fp(key)))")
    }

    // MARK: - After the commit

    /// What this Mac remembers, agreeing with the record — the key file's
    /// mirror, the vault facts a synced act read, the biometry hash when this
    /// key has a Touch ID item (a hint, §3.10).
    func rememberNewKey() throws {
        let hasTouchID = try leaves.custody.custodyItems()
            .contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .touchid))
        // The vault's facts are what this device FOLLOWED — recorded only by an
        // act that worked the account's keys itself (a rotation, a follow, a
        // join, a synced key door). A settings act after a fresh read must not
        // record keys it never picked up: that hid the follow owed when the
        // account had replaced its keys elsewhere (promise 7 — VX-305 U4,
        // found by the scenario world).
        let vault = parameters.synced == true ? accountID.flatMap { executor.freshVaults[$0] } : nil
        // …and only the keys it TOOK: a vault read since that moved past them
        // (the account replaced its keys again before a resume finished this
        // act) leaves the follow owed — its corpus key recorded alone (VX-305
        // U4, the soak's seed 11).
        let took = parameters.followedCorpusKeyID ?? parameters.newCorpusKeyID
        let hash = hasTouchID ? leaves.biometry.biometryStateHash() : nil
        try executor.writeMemory(&library) { memory in
            if hasTouchID { memory.biometryStateHash = hash }
            if let vault {
                if let took, took != vault.corpusKeyID {
                    memory.vaultFacts = VaultFacts(corpusKeyID: took)
                } else {
                    memory.vaultFacts = VaultFacts(
                        kdf: vault.format.kdf, corpusKeyID: vault.corpusKeyID,
                        recoveryWrapDigest: vault.format.recoveryWrapDigest)
                }
            }
        }
    }

    /// The outgoing key's custody items go — only after the swap. Entering
    /// Castle sweeps too (§3.9): every silent item for a key the library has
    /// had — each only once the history VERIFIABLY holds its key (opened with
    /// the current key). (Today's items and key files left with rule 26.)
    func retireOldCustody(sweepForCastle: Bool) throws {
        let current = library.fingerprint
        guard current != plan.fromFingerprint else { return }
        let live = library.keyFile
        func historyHolds(_ fingerprint: String) -> Bool {
            guard let live, live.fingerprint == current else { return false }
            return (try? live.historyKey(fingerprint, currentKey: library.key)) != nil
        }
        let tree = Set(library.familyTree.fingerprints)
        for item in try leaves.custody.custodyItems() where item.fingerprint != current {
            let outgoing = item.fingerprint == plan.fromFingerprint
            let sweep = sweepForCastle && item.itemClass == .silent && tree.contains(item.fingerprint)
            guard outgoing || sweep else { continue }
            // The outgoing key's Touch ID item goes with its key; a silent
            // item goes only once the history holds its key (in a leave the
            // anchor holds it — and a leave's outgoing key is a Castle key,
            // with no silent item).
            if item.itemClass == .silent, sweepForCastle, !historyHolds(item.fingerprint) { continue }
            try leaves.custody.deleteCustody(fingerprint: item.fingerprint, itemClass: item.itemClass)
        }
    }

    /// Entering Castle turns this device's scheduled Markdown export off, with
    /// one notice (pre-13x decision 6, kept — §3.12).
    func turnExportOff() throws {
        guard executor.guards.exportOffAtCastleOn, library.section.settings.scheduledExport else { return }
        var settings = library.section.settings
        settings.scheduledExport = false
        try updateSection { $0.withSettings(settings) }
        outcome.notices.append(.scheduledExportTurnedOff)
    }

    /// A fresh backup pair under the key the library is under now.
    func freshBackup() throws {
        guard let live = library.keyFile, live.fingerprint == library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        try leaves.backups.takeBackupPair(with: library.key, keyFile: live, deviceID: deviceID)
    }

    /// **Entering Castle retires every Apple key of this Mac's own for the
    /// library** (§3.5) — every id this Mac's section lists as its own and
    /// not yet retired, not only the one the outgoing key file named: each
    /// deleted, its id recorded as retired, with no sheet.
    func retireOwnAppleKeys() throws {
        let ids = executor.guards.everyOwnKeyRetiredAtCastleOn
            ? library.section.ownLibraryAppleKeyIDsToRetire
            : [parameters.outgoingAppleKeyID].compactMap { $0 }
        guard !ids.isEmpty else { return }
        var section = library.section
        for id in ids {
            try leaves.apple.deleteAppleKey(id: id)
            let record = section.appleKeys.first { $0.id == id }
            section = section.retiringAppleKey(
                id: id, purpose: .library, origin: record?.origin ?? .minted, at: now)
        }
        try executor.writeFacts(&library, section: section)
        log("retired \(ids.count) own Apple key(s)")
    }

    // MARK: - The account (the `Sync/` half, MODELLED — phase 3 wires it)

    /// The account's sync keys in hand: this act's, custody's (either class),
    /// session memory.
    func syncMaterial() throws -> DeviceKeyMaterial? {
        if let material { return material }
        guard let account = accountID else { return nil }
        for itemClass in [ProtectionNames.CustodyClass.touchid, .silent] {
            if let held = try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: itemClass) {
                material = held
                return held
            }
        }
        material = leaves.syncKeys.sessionSyncKeys(accountID: account)
        return material
    }

    /// **Sync keys held by what they can reach** (§3.2): the Castle way — a
    /// Touch ID item where this press chose Touch ID and a finger is enrolled,
    /// else session memory — while they reach a Castle-era key; a silent item
    /// otherwise. One item per account: the other class goes.
    func holdSyncKeys(_ held: DeviceKeyMaterial, castleWay: Bool) throws {
        guard let account = accountID else { return }
        let items = try leaves.syncKeys.syncKeyItems()
        func drop(_ itemClass: ProtectionNames.CustodyClass) throws {
            if items.contains(SyncKeysItemFact(accountID: account, itemClass: itemClass)) {
                try leaves.syncKeys.deleteSyncKeys(accountID: account, itemClass: itemClass)
            }
        }
        if castleWay {
            let gate = parameters.gate ?? library.section.settings.gateStyle
            let biometry = leaves.biometry.biometry()
            if gate == .touchID, biometry.hardware, biometry.enrolled {
                // Idempotent: the item already holding exactly these keys is
                // left as it is.
                if try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .touchid) != held {
                    try leaves.syncKeys.writeSyncKeys(held, accountID: account, itemClass: .touchid)
                }
                leaves.syncKeys.holdInSession(nil, accountID: account)
            } else {
                try drop(.touchid)
                leaves.syncKeys.holdInSession(held, accountID: account)
            }
            try drop(.silent)
        } else {
            if try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .silent) != held {
                try leaves.syncKeys.writeSyncKeys(held, accountID: account, itemClass: .silent)
            }
            try drop(.touchid)
            leaves.syncKeys.holdInSession(nil, accountID: account)
        }
        material = held
    }

    /// The vault, read fresh (this act's read is the session's).
    func freshRead() async throws -> VaultSnapshot {
        guard let account = accountID else { throw ExecutorRefusal.notSynced }
        guard let snapshot = try await executor.readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        return snapshot
    }

    /// The material for the vault as read: custody's when it holds the
    /// vault's current corpus key, else from the vault with the secrets in hand.
    func material(for snapshot: VaultSnapshot) throws -> DeviceKeyMaterial {
        if let held = try syncMaterial(), held.corpusKeyID == snapshot.corpusKeyID,
           (snapshot.format.previousCorpusKey == nil || held.previousCorpusKeyID == snapshot.format.previousCorpusKey?.keyID) {
            return held
        }
        guard let master = VaultModel.master(of: snapshot.format, passphrase: secrets.passphrase, words: secrets.words) else {
            throw ExecutorRefusal.secretsRequired(act)
        }
        let derived = try VaultModel.material(following: snapshot.format, master: master)
        material = derived
        return derived
    }

    /// **A rotation's first write** — the account's commit point (past it a
    /// crash resumes, never rolls back). The new corpus key id is stamped in
    /// the plan BEFORE the write, so a resume tells its own landed write (pick
    /// the new keys up from the vault) from another device's rotation (the
    /// account moved: this act rolls back and the device follows).
    func rotationWrite(apple: RotationAppleCopy, castleWay: Bool) async throws {
        let snapshot = try await freshRead()
        if let stamped = parameters.newCorpusKeyID, snapshot.corpusKeyID == stamped {
            try holdSyncKeys(try material(for: snapshot), castleWay: castleWay)
            return
        }
        guard snapshot.corpusKeyID == parameters.oldCorpusKeyID else { throw ActRollback(refusal: .accountMoved) }
        if snapshot.format.previousCorpusKey != nil { throw ActRollback(refusal: .rotationInProgress) }
        let passphrase = try requirePassphrase()
        guard VaultModel.master(of: snapshot.format, passphrase: passphrase, words: nil) != nil else {
            // The account's passphrase changed elsewhere since the press —
            // before this device's first vault write the act rolls back (it
            // refused and stuck in flight — VX-305 U4, found by the scenario
            // world); the follow picks up the change, then she presses again.
            throw ActRollback(refusal: .accountMoved)
        }
        let current = try material(for: snapshot)
        let (format, fresh) = try VaultModel.rotationBegin(
            current: current, passphrase: passphrase, words: secrets.words, apple: apple, device: deviceName,
            ids: leaves.ids)
        var stamped = parameters
        stamped.newCorpusKeyID = fresh.corpusKeyID
        plan.parameters = stamped
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        let revision = resuming ? snapshot.revision : (parameters.doorRevision ?? snapshot.revision)
        let written = try await leaves.vault.updateVault(
            format, accountID: snapshot.accountID, expectedRevision: revision, proofMaster: current.masterSymmetricKey,
            device: deviceName)
        executor.noteFresh(written)
        log("the vault rotated (\(Self.fp8(fresh.corpusKeyID)))")
        try holdSyncKeys(fresh, castleWay: castleWay)
    }

    /// THE WALK: every row below the rotation seq re-encrypted (any device
    /// holding the new master may run it).
    func walk() async throws {
        let snapshot = try await freshRead()
        guard snapshot.format.previousCorpusKey != nil, snapshot.rowsBelowRotationSeq > 0 else { return }
        let held = try material(for: snapshot)
        _ = try await leaves.vault.reencryptBelowRotationSeq(accountID: snapshot.accountID, material: held)
    }

    /// **The completing write.** A leave's (an id with no wrap) adds the
    /// account's Apple wrap under the NAMED key and clears the previous corpus
    /// key in one write — made only by a device that reads that key (just the
    /// wrap when an older build already cleared the key). A rotation with no
    /// id completes with no Apple copy, by anyone. Then the sync keys are held
    /// by what they reach now.
    func completeRotation(castleWayAfter: Bool) async throws {
        let snapshot = try await freshRead()
        let held = try material(for: snapshot)
        let isLeave = snapshot.format.appleKeyID != nil && snapshot.format.masterWrappedByAppleHeld == nil
        var named: AppleKeyMaterial?
        if isLeave, let id = snapshot.format.appleKeyID {
            named = try leaves.apple.readAppleKey(id: id)
            // The finisher stopped waiting — or this is the ACTOR's own resume
            // and the key it minted itself is gone (its keychain wiped or
            // replaced before iCloud Keychain carried it): nothing will ever
            // bring it, so the minter mints afresh (VX-305 U4, found by the
            // scenario world — the actor's leave waited for ever).
            let ownMintLost = named == nil && parameters.accountAppleKeyID == id && act == .leaveCastle
            if named == nil, parameters.mintsFreshAccountKey == true || ownMintLost {
                // The finisher stopped waiting for the named key: a fresh
                // account key, minted here, completes the leave instead.
                named = try mintAppleKey(purpose: .account)
            }
            if named == nil {
                guard !executor.guards.leaveIDGatesCompletionOn else { throw ExecutorRefusal.waitingForNamedAppleKey }
            }
        }
        if snapshot.format.previousCorpusKey != nil || (isLeave && named != nil) {
            let format = try VaultModel.completing(
                snapshot.format, master: held.masterSymmetricKey, namedKey: named, device: deviceName)
            let written = try await leaves.vault.updateVault(
                format, accountID: snapshot.accountID, expectedRevision: snapshot.revision,
                proofMaster: held.masterSymmetricKey, device: deviceName)
            executor.noteFresh(written)
        }
        var settled = held
        settled.previousCorpusKey = nil
        settled.previousCorpusKeyID = nil
        settled.rotationStartedSeq = nil
        try holdSyncKeys(settled, castleWay: castleWayAfter)
    }

    /// Use Castle on a synced library: the account's former Apple key goes
    /// once its rotation completes — deleted and recorded as retired by the
    /// acting device (§3.5). The old shared key is the retirement's own.
    func retireAccountAppleKey() throws {
        guard let id = parameters.retiringAccountAppleKeyID else { return }
        if let shared = try leaves.apple.readOldSharedAppleKey(), shared.id == id { return }
        try leaves.apple.deleteAppleKey(id: id)
        try updateSection {
            $0.retiringAppleKey(id: id, purpose: .account, accountID: accountID, origin: .minted, at: now)
        }
    }

    // MARK: - The anchor (§3.4) — written FIRST, into the outgoing file

    /// Seal the outgoing Castle key, its whole history and any earlier anchor
    /// into the anchor and write it into the CURRENT key file before any other
    /// step of a leave. Idempotent: an anchor of this very key is already
    /// written (a resume never seals a second one — it keeps its day).
    func writeAnchor(_ inputs: AnchorLockInputs) throws {
        guard let from = fromKey, let live = library.keyFile, live.fingerprint == Self.fp(from) else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        if let anchor = live.anchor, anchor.outgoingFingerprint == live.fingerprint, anchor.outgoingEpoch == live.epoch {
            return
        }
        var anchor = try CastleAnchor.sealing(
            outgoingKeyFile: live, outgoingKey: from, locks: inputs, madeAt: now, madeBy: deviceID,
            anchorKey: leaves.ids.mintSymmetricKey())
        #if DEBUG
        if case .follower = inputs, !executor.guards.followerAnchorTypedLockOn {
            // Guard off (DEBUG mutation pins only): the follower's anchor
            // without the lock under the secret typed at its follow.
            anchor.locks.passphrase = nil
            anchor.locks.words = nil
        }
        #endif
        try executor.writeLiveKeyFile(try live.writingAnchor(anchor), &library)
        log("the anchor written first (\(Self.fp8(anchor.outgoingFingerprint)))")
    }

    // MARK: - The old shared key (§3.5 points 2, 4, 5)

    /// **Retiring the old shared key** — Use Castle's last step, or its own
    /// door: the moves run again (keys of this Mac's own beside it), the
    /// vault read fresh again — a vault it can read that names it now keeps
    /// the key (the last-step race: the act lands with the door and §3.1's
    /// first exception showing) — then the old-name item deleted ONLY by the
    /// id this device's section lists, and recorded retired on THIS device's
    /// section only.
    func retireOldSharedKey() async throws {
        let readable = try leaves.apple.readOldSharedAppleKey()
        let recorded = library.section.oldSharedKey
        if recorded?.retiredAt != nil { return }
        guard readable != nil || recorded != nil else { return }
        if executor.guards.retirementRerunsMovesOn {
            try await executor.moveOffSharedKey(self, freshPair: true)
        }
        // The session's vault, read now — or, offline, not read at all: the
        // signed-out case's twin, this device's own knowledge standing in for
        // it too (VX-305 U4, the soak's seed 15 — a throw here stuck the
        // retirement in flight).
        var sessionVaultRead = false
        if executor.guards.doorTimeVaultCheckOn, let account = executor.configuration.session.accountID {
            let vault: VaultSnapshot??
            do { vault = .some(try await executor.readVault(accountID: account)) } catch where ProtectionExecutor.vaultOutOfReach(error) { vault = nil }
            if let vault {
                sessionVaultRead = true
                if let vault, vault.format.masterWrappedByAppleHeld != nil,
                   let id = vault.format.appleKeyID, id == (recorded?.id ?? readable?.id) {
                    leaves.diagnostics.report(.oldSharedKeyStayed(account: account))
                    outcome.notices.append(.oldSharedKeyStayed(account: account))
                    log("the old shared key stays — a vault it can read names it")
                    return
                }
            }
        }
        // Signed out (or in another account), the vault can't be read — this
        // device's own knowledge stands in (P-U2-4, at the act): an account it
        // last knew on the old key, other than one THIS act rotates into
        // Castle, keeps the key (This Mac Only leaving a Standard account on
        // the old key must never cost its other devices their Apple road —
        // VX-305 U4, found by the scenario world).
        if executor.guards.doorTimeVaultCheckOn, let shared = recorded?.id ?? readable?.id {
            let rotated = act == .enterCastle && parameters.synced == true ? accountID : nil
            if let stays = library.section.appleKeys.first(where: {
                $0.purpose == .account && $0.id == shared && $0.retiredAt == nil && $0.accountID != nil && $0.accountID != rotated
                    && ($0.accountID != executor.configuration.session.accountID || !sessionVaultRead)
            })?.accountID {
                leaves.diagnostics.report(.oldSharedKeyStayed(account: stays))
                outcome.notices.append(.oldSharedKeyStayed(account: stays))
                log("the old shared key stays — an account this device knew still stands on it")
                return
            }
        }
        let id: String
        if executor.guards.oldSharedKeyDeletedByRecordedIDOn {
            // The id this device's section lists — or, never listed, the item
            // as it stands at this act, listed now.
            guard let listed = recorded?.id ?? readable?.id else { return }
            id = listed
        } else {
            guard let current = readable?.id else { return }
            id = current
        }
        _ = try leaves.apple.deleteOldSharedAppleKey(id: id)
        try updateSection { section in
            var next = section.bumped()
            next.oldSharedKey = OldSharedKeyRecord(id: id, retiredAt: now)
            return next
        }
        log("the old shared Apple key retired")
    }
}

extension ProtectionExecutor {
    /// Note a vault this executor wrote as its freshest read.
    func noteFresh(_ snapshot: VaultSnapshot) {
        freshVaults[snapshot.accountID] = snapshot
        vaultsReadThisSession.insert(snapshot.accountID)
    }
}
