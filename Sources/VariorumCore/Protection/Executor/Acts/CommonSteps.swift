import CryptoKit
import Foundation

// VX-305 U3 — THE STEPS THE ACTS SHARE. Every step is idempotent (a crash
// between a step's write and the plan marking it done re-runs it), and the
// library re-key runs in PREPARE-THEN-COMMIT order (§3.4, VX-235's class):
//   the new key's custody item → the new key file (its history the outgoing
//   key and every key before it — rule 4, every crossing alike) → the library
//   re-encrypted into a staged file → the record written into the staged file
//   → THE SWAP (the commit point) → what this Mac remembers → the outgoing
//   key's custody items go.
// Copies pause from the prepare to the swap. Whatever state a crash leaves, a
// road opens the file: the old custody item (it goes only after the swap),
// the new key, the new key through the history.

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
    /// before the swap; after it, through the new file's history.
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
            locks.master = held.masterKey
            locks.masterWordsCopy = snapshot.flatMap { $0.vault.isMaster(held.masterKey) ? $0.vault.masterByWords : nil }
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

    /// The new key file — a re-key to a key of `kind`, its history carrying
    /// every earlier key (rule 4); `kind` nil builds a file with no past (a
    /// landing, a creation).
    func newKeyFile(rekeyTo kind: ProtectionMode?, locks: NewKeyLocks) throws {
        let key = try requireToKey()
        if !(try libraryOpens(key)) { leaves.backups.pauseCopies() }
        if let live = library.keyFile, live.fingerprint == Self.fp(key) { return }
        guard let from = fromKey, let outgoing = library.keyFile, outgoing.fingerprint == Self.fp(from) else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        let file: KeyFile
        if let kind {
            file = try outgoing.rekeyed(from: from, to: key, kind: kind, locks: locks, at: now)
        } else {
            file = try KeyFile.building(libraryID: outgoing.libraryID, key: key, epoch: outgoing.epoch + 1, locks: locks)
        }
        try executor.writeLiveKeyFile(file, &library)
        log("the new key file written (\(Self.fp8(file.fingerprint)), history \(file.history.count))")
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
        var next = record.recordingRekey(to: Self.fp(key), kind: kind, at: now)
        if parameters.changesAccount == true {
            next.account = parameters.targetAccount
            if parameters.targetAccount == nil { next.accountRowKeyID = nil }
        }
        // The sync key the act took (rule 15) — Use Castle's own write, or the
        // keys a follow or a join picked up.
        if let taken = parameters.newRowKeyID ?? parameters.followedRowKeyID { next.accountRowKeyID = taken }
        next = next.stampingPassphraseFact(keyFile: library.keyFile)
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
        library.keyFile = try executor.liveFormat3()
        leaves.backups.resumeCopies()
        log("swapped — the library is under \(Self.fp8(Self.fp(key)))")
    }

    // MARK: - After the commit

    /// What this Mac remembers, agreeing with the record — the key file's
    /// mirror, the biometry hash when this key has a Touch ID item (a hint,
    /// §3.10). (The vault facts left with VX-378 U2: the record names the sync
    /// key the library follows.)
    func rememberNewKey() throws {
        let hasTouchID = try leaves.custody.custodyItems()
            .contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .touchid))
        let hash = hasTouchID ? leaves.biometry.biometryStateHash() : nil
        try executor.writeMemory(&library) { memory in
            if hasTouchID { memory.biometryStateHash = hash }
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
        // The keys the library has had: the live file's (rule 4 — the family
        // tree left with VX-378 U1).
        let tree = Set(live?.heldFingerprints ?? [])
        for item in try leaves.custody.custodyItems() where item.fingerprint != current {
            let outgoing = item.fingerprint == plan.fromFingerprint
            let sweep = sweepForCastle && item.itemClass == .silent && tree.contains(item.fingerprint)
            guard outgoing || sweep else { continue }
            // The outgoing key's Touch ID item goes with its key; a silent
            // item goes only once the history holds its key.
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
            section = section.retiringAppleKey(id: id, at: now)
        }
        try executor.writeFacts(&library, section: section)
        log("retired \(ids.count) own Apple key(s)")
    }

    // MARK: - The account (the `Sync/` half, MODELLED — phase 3 wires it)

    /// The account's sync keys in hand: this act's, custody's (either class),
    /// session memory.
    func syncMaterial() throws -> AccountKeys? {
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

    /// **Sync keys held the account's way** (rule 15's custody — by the
    /// account's mode, never by what they reach): the Castle way — a Touch ID
    /// item where this press chose Touch ID and a finger is enrolled, else
    /// session memory; a silent item in Standard. One item per account: the
    /// other class goes.
    func holdSyncKeys(_ held: AccountKeys, castleWay: Bool) throws {
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

    /// The vault, read fresh (this act's read is the session's). Out of reach —
    /// signed out, signed into another account, offline — the act ROLLS BACK
    /// (nothing account-side is left half-made: every step that reads the vault
    /// runs before the library's swap; VX-378 U2 — no act waits on a vault).
    func freshRead() async throws -> VaultSnapshot {
        guard let account = accountID else { throw ExecutorRefusal.notSynced }
        let snapshot: VaultSnapshot?
        do {
            snapshot = try await executor.readVault(accountID: account)
        } catch where ProtectionExecutor.vaultOutOfReach(error) {
            throw ActRollback(refusal: .vaultOutOfReach(account: account))
        }
        guard let snapshot else { throw ExecutorRefusal.needsFreshVault }
        return snapshot
    }

    /// The keys for the vault as read: custody's when they are its current
    /// sync key under its master, else from the vault with the secrets in hand.
    func material(for snapshot: VaultSnapshot) throws -> AccountKeys {
        if let held = try syncMaterial(), held.rowKeyID == snapshot.rowKeyID, snapshot.vault.isMaster(held.masterKey) {
            return held
        }
        guard let master = VaultModel.master(of: snapshot.vault, passphrase: secrets.passphrase, words: secrets.words) else {
            throw ExecutorRefusal.secretsRequired(act)
        }
        let derived = try snapshot.vault.keys(master: master)
        material = derived
        return derived
    }

    /// **Use Castle's one vault write** (rules 11, 15) — the account's own
    /// part of the entry: a new master and a new sync key, the outgoing sync
    /// key and every earlier one re-sealed under the new master, the mode
    /// Castle. The new sync key's id is stamped in the plan BEFORE the write, so
    /// a resume tells its own landed write (pick the new keys up) from another
    /// device's (the account moved: this act rolls back and the device follows).
    func enterCastleWrite() async throws {
        let snapshot = try await freshRead()
        if let stamped = parameters.newRowKeyID, snapshot.rowKeyID == stamped {
            try holdSyncKeys(try material(for: snapshot), castleWay: true)
            return
        }
        guard snapshot.rowKeyID == parameters.doorRowKeyID, snapshot.mode == .standard else {
            throw ActRollback(refusal: .accountMoved)
        }
        let passphrase = try requirePassphrase()
        guard let words = secrets.words else { throw ExecutorRefusal.secretsRequired(act) }
        guard VaultModel.master(of: snapshot.vault, passphrase: passphrase, words: nil) != nil else {
            // The account's passphrase changed elsewhere since the press — the
            // act rolls back before its write; the follow picks the change up.
            throw ActRollback(refusal: .accountMoved)
        }
        let current = try material(for: snapshot)
        let (vault, fresh) = try VaultModel.enteringCastle(
            snapshot.vault, held: current, passphrase: passphrase, words: words, device: deviceName, ids: leaves.ids)
        var stamped = parameters
        stamped.newRowKeyID = fresh.rowKeyID
        plan.parameters = stamped
        try leaves.plans.writePlan(try plan.sealed(under: library.key))
        let revision = resuming ? snapshot.revision : (parameters.doorRevision ?? snapshot.revision)
        let written = try await leaves.vault.updateVault(
            vault, accountID: snapshot.accountID, expectedRevision: revision, proofMaster: current.masterKey,
            device: deviceName)
        executor.noteFresh(written)
        log("the account entered Castle (sync key \(Self.fp8(fresh.rowKeyID)))")
        try holdSyncKeys(fresh, castleWay: true)
    }

    /// **Use Standard's vault write** (rule 12) — the MODE flag flipped, no key
    /// changed. Landed already (this act's, or another device's leave): the
    /// keys are held the Standard way and nothing is written.
    func leaveCastleWrite() async throws {
        let snapshot = try await freshRead()
        if snapshot.mode == .standard {
            try holdSyncKeys(try material(for: snapshot), castleWay: false)
            return
        }
        guard snapshot.rowKeyID == parameters.doorRowKeyID else { throw ActRollback(refusal: .accountMoved) }
        let held = try material(for: snapshot)
        let revision = resuming ? snapshot.revision : (parameters.doorRevision ?? snapshot.revision)
        let written = try await leaves.vault.updateVault(
            VaultModel.leavingCastle(snapshot.vault, device: deviceName), accountID: snapshot.accountID,
            expectedRevision: revision, proofMaster: held.masterKey, device: deviceName)
        executor.noteFresh(written)
        log("the account left Castle (its mode flag flipped; no key changed)")
        try holdSyncKeys(held, castleWay: false)
    }
}

extension ProtectionExecutor {
    /// Note a vault this executor wrote as its freshest read.
    func noteFresh(_ snapshot: VaultSnapshot) {
        freshVaults[snapshot.accountID] = snapshot
        vaultsReadThisSession.insert(snapshot.accountID)
    }
}
