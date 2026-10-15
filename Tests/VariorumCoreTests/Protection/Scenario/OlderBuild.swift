//
//  OlderBuild.swift
//  VariorumCoreTests — VX-305 U4: TODAY'S STORES, built from the old formats
//  (the phase plan §6's starting states — "every shape today's builds leave,
//  built as fixtures from the old formats"), and TODAY'S BUILD as an actor on
//  any device (design §4.1: "an older build … reads and mints only the old
//  shared key, writes its wraps under it, and its Re-link re-lands the
//  account's vault copy under it; it reads the vault's mode from the Apple
//  wrap alone, and completes any rotation it finds, carrying the vault's other
//  fields — `apple_key_id` among them — through").
//
//  HER RULING 2026-10-15 (the legacy cut widened — "no old backups or builds
//  have to be considered"): today's STORES stay fully in scope (they are the
//  migration's inputs); today's BUILD as a live, concurrent actor is beyond
//  scope — the switch updates every device first. The generator no longer
//  drives the actor's acts; the fixed scenarios that do are kept while green,
//  each marked "beyond scope".
//
//  The old formats are today's real ones: format 1/2 key files
//  (`StoreKeyEnvelope`, named `variorum-keys[-<fp16>].json`), today's custody
//  items by library ID (`<scope>-<libraryID>-bound` / `-biometric`), the per-
//  store sync custody `{deviceID, material}`, the 13p escrow item (a raw key in
//  iCloud Keychain named by the library ID), the old shared `<scope>-apple-key`
//  `{id, key}`, the in-file `RotationMarker`, and the vault in today's shape
//  (Standard: the master under the old shared key, `apple_key_id` its id).
//  The older build's acts restate `PostureSwitch`'s `leaveCastle`,
//  `followIntoStandard`, the follow into Castle, `AppleRelinkModel`'s re-land
//  and `CorpusRotation.complete` against the same fakes.
//

import CryptoKit
import Foundation

@testable import VariorumCore

/// A library on a device as TODAY's build leaves it.
struct TodaySpec {
    var mode: ProtectionMode = .standard
    var passphrase = true
    var words = true
    /// Standard: the key file carries the old shared key's wrap (landed).
    var appleLanded = true
    /// Castle: a Touch ID item (today's gated item), or none (Always ask).
    var gate: GateStyle = .touchID
    /// VX-202's victims: the raw key in the SILENT item while Castle-shaped.
    var silentInCastle = false
    /// Enrolled in this account (its vault made first — `todayAccount`).
    var account: String?
    /// A device that joined sync without typing a secret: its key file has
    /// only the master and Apple wraps.
    var joinedWithoutSecret = false
    /// A 13p escrow item: the raw key in iCloud Keychain, named by library ID.
    var escrow = false
    /// Today's stuck marker inside the library file.
    var marker: LegacyRotationMarker?
    /// Older keys of this library, each with its own fingerprint-named key
    /// file beside (the old key's fold) — `.standard` era keys carry the old
    /// shared key's wrap, `.castle` era keys don't.
    var olderKeys: [ProtectionMode] = []
    /// Format 1: `variorum-keys.json`, the passphrase and words wraps only.
    var format1 = false
    var legacyAtOpenMode: LegacyAtOpenMode?
    /// One library on two Macs from a hand-off made before this change: the
    /// same id and the same key.
    var sameAs: TodayLib?
}

struct TodayLib {
    var libraryID: String
    var key: StoreKey
    var olderKeys: [StoreKey]
    var holder: String
}

extension SWorld {
    // MARK: - Today's Apple key, today's account

    /// The old shared `<scope>-apple-key` of an Apple account — one per Apple
    /// account and scope, shared by every library on it (today: minted by the
    /// first Standard library, then read). In the cloud and on every device
    /// signed into the account (a past sync).
    @discardableResult
    func ensureOldShared(_ appleAccount: String) -> AppleKeyMaterial {
        let account = appleAccounts[appleAccount]!
        let name = KName.oldShared(Self.scope)
        if let held = account.cloud[name]?.item?.value.appleKey { return held }
        let key = mintApple()
        let item = KItem(value: .apple(id: key.id, bytes: PF.bytes(key.key)), synchronizable: true)
        let version = nextSyncVersion()
        account.cloud[name] = AppleAccountFake.Entry(item: item, version: version)
        for device in devices where device.appleAccount == appleAccount && device.iCloudOn {
            device.keychain.synced[name] = DeviceKeychain.Replica(item: item, version: version, dirty: false)
        }
        return key
    }

    /// An account's vault in today's shape: M under P and W; Standard — M
    /// under the old shared key, `apple_key_id` its id. Returns the material.
    @discardableResult
    func todayAccount(_ id: String, mode: ProtectionMode, appleAccount: String = SWorld.appleA,
                      passphrase: String? = nil, words: [String]? = nil) throws -> DeviceKeyMaterial {
        let p = passphrase ?? newPassphrase(), w = words ?? newWords()
        setKnown(id, passphrase: p, words: w)
        let kdf = fastKDF()
        let pk = passphraseKey(p, kdf)!
        let wk = try WordsKey.derive(w)
        let master = SymmetricKey(data: rng.bytes(32)), corpus = SymmetricKey(data: rng.bytes(32)), journal = SymmetricKey(data: rng.bytes(32))
        let corpusID = rng.uuid(), journalID = rng.uuid()
        var format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: pk.key, recoveryKey: wk.key,
            classKeys: [(.corpus, corpusID, corpus), (.journalBridge, journalID, journal)], kdf: kdf)
        if mode == .standard {
            let shared = ensureOldShared(appleAccount)
            format = try format.settingAppleHeldCopy(masterKey: master, appleKey: shared.key, appleKeyID: shared.id)
        } else {
            truth.castleCorpusKeyIDs.insert(corpusID)
        }
        format.updatedByDevice = "an older build"
        server.accounts[id] = ServerFake.Account(revision: 1, format: format, rowsBelowSeq: 0, updatedAt: clock)
        return DeviceKeyMaterial(
            masterKey: PF.bytes(master), corpusKey: PF.bytes(corpus), corpusKeyID: corpusID,
            journalBridgeKey: PF.bytes(journal), journalBridgeKeyID: journalID)
    }

    /// The account's master, by its passphrase (the vault's descriptor).
    func todayMaster(_ account: String) -> SymmetricKey? {
        guard let vault = server.snapshot(account), let p = known(account).passphrase,
              let pk = passphraseKey(p, vault.format.kdf) else { return nil }
        return try? vault.format.unwrapMaster(withPassphraseKey: pk.key)
    }

    // MARK: - A library as today's build leaves it

    @discardableResult
    func today(on device: SDevice, _ spec: TodaySpec) throws -> TodayLib {
        let libraryID = spec.sameAs?.libraryID ?? rng.uuid()
        let key = spec.sameAs?.key ?? mintKey()
        let holder = self.holder(device, account: spec.account, libraryID: libraryID)
        if spec.account == nil, truth.known[holder] == nil {
            if let other = spec.sameAs, let known = truth.known[other.holder] {
                truth.known[holder] = known
            } else {
                setKnown(holder, passphrase: spec.passphrase ? newPassphrase() : nil, words: spec.words ? newWords() : nil)
            }
        }
        let secrets = known(holder)
        if spec.joinedWithoutSecret { truth.silentlyJoined.insert(device.name) }
        let material: DeviceKeyMaterial? = try spec.account.map { account in
            guard let master = todayMaster(account), let vault = server.snapshot(account) else { throw WorldRefusal.noLibrary }
            return try VaultModel.material(following: vault.format, master: master)
        }
        let shared = spec.mode == .standard && spec.appleLanded ? ensureOldShared(device.appleAccount ?? Self.appleA) : nil
        func envelope(for key: StoreKey, apple: Bool) throws -> StoreKeyEnvelope {
            var envelope = StoreKeyEnvelope(storeID: libraryID)
            if spec.passphrase, !spec.joinedWithoutSecret, let p = secrets.passphrase {
                try envelope.setPassphraseWrap(key: key, passphrase: p, kdf: fastKDF())
            }
            if spec.words, !spec.joinedWithoutSecret, let w = secrets.words { try envelope.setRecoveryWrap(key: key, words: w) }
            if let material { try envelope.setMasterWrappedCopy(key: key, under: material.masterSymmetricKey) }
            if apple, let shared { try envelope.setAppleWrappedCopy(key: key, under: shared.key, appleKeyID: shared.id) }
            if let account = spec.account, let vault = server.snapshot(account) {
                try envelope.recordVaultReconciliation(
                    kdf: vault.format.kdf, corpusKeyID: vault.corpusKeyID, recoveryWrapDigest: vault.format.recoveryWrapDigest)
            }
            if spec.format1 {
                envelope.formatVersion = StoreKeyEnvelope.formatVersion1
                envelope.master = nil
                envelope.apple = nil
                envelope.appleKeyID = nil
            }
            envelope.keyFingerprint = PF.fp(key)
            return envelope
        }
        let current = try envelope(for: key, apple: shared != nil)
        device.container.files[spec.format1 ? StoreKeyEnvelope.legacyFilename : SPath.legacyKeyFile(PF.fp(key))] =
            .keyFile(.legacy(LegacyKeyFile(envelope: current)))
        var older: [StoreKey] = []
        for era in spec.olderKeys {
            let old = mintKey()
            older.append(old)
            device.container.files[SPath.legacyKeyFile(PF.fp(old))] =
                .keyFile(.legacy(LegacyKeyFile(envelope: try envelope(for: old, apple: era == .standard && shared != nil))))
        }
        device.container.files[SPath.slot] = .library(LibraryImage(
            libraryID: libraryID, fingerprint: PF.fp(key), record: nil, writing: 1, legacyMarker: spec.marker,
            rowsOwner: spec.account))
        device.container.files[SPath.marker] = .marker
        // Today's custody by library ID.
        switch spec.mode {
        case .standard:
            device.keychain.local[KName.legacyBound(Self.scope, libraryID)] = KItem(value: .key(key))
        case .castle:
            if spec.gate == .touchID {
                device.keychain.local[KName.legacyGated(Self.scope, libraryID)] = KItem(
                    value: .key(key), touchID: true, enrollment: device.biometry.generation)
            }
            if spec.silentInCastle { device.keychain.local[KName.legacyBound(Self.scope, libraryID)] = KItem(value: .key(key)) }
        }
        device.olderDeviceID = rng.uuid()
        if let account = spec.account, let material {
            let gated = spec.mode == .castle && spec.gate == .touchID
            if spec.mode == .standard || gated {
                device.keychain.local[KName.legacySync(Self.scope, libraryID, gated: gated)] = KItem(
                    value: .legacySync(deviceID: device.olderDeviceID, material: material), touchID: gated,
                    enrollment: device.biometry.generation)
            }
            device.session = .signedIn(accountID: account, email: nil)
        }
        if spec.escrow {
            let item = KItem(value: .key(key), synchronizable: true)
            let version = nextSyncVersion()
            if let apple = device.appleAccount { appleAccounts[apple]?.cloud[KName.escrow(libraryID)] = .init(item: item, version: version) }
            device.keychain.synced[KName.escrow(libraryID)] = .init(item: item, version: version, dirty: false)
        }
        device.legacySettings = DeviceSettings(gateStyle: spec.mode == .castle ? spec.gate : nil)
        device.legacyAtOpenMode = spec.legacyAtOpenMode
        if spec.sameAs != nil { truth.handedOffBeforeChange.insert(PF.fp(key)) }
        if spec.mode == .castle { truth.castleBorn.insert(PF.fp(key)) }
        return TodayLib(libraryID: libraryID, key: key, olderKeys: older, holder: holder)
    }

    /// Another library this Mac holds only copies of (an older library, or
    /// backups only), as today wrote them: in `Previous Libraries/<stamp>/` or
    /// as flat backup pairs, each with its own frozen key file.
    @discardableResult
    func todayOtherLibrary(on device: SDevice, mode: ProtectionMode, passphrase: Bool, words: Bool,
                           asOlderLibrary: Bool = true) throws -> TodayLib {
        let libraryID = rng.uuid(), key = mintKey()
        let holder = self.holder(device, account: nil, libraryID: libraryID)
        setKnown(holder, passphrase: passphrase ? newPassphrase() : nil, words: words ? newWords() : nil)
        let secrets = known(holder)
        var envelope = StoreKeyEnvelope(storeID: libraryID)
        if let p = secrets.passphrase { try envelope.setPassphraseWrap(key: key, passphrase: p, kdf: fastKDF()) }
        if let w = secrets.words { try envelope.setRecoveryWrap(key: key, words: w) }
        if mode == .standard {
            let shared = ensureOldShared(device.appleAccount ?? Self.appleA)
            try envelope.setAppleWrappedCopy(key: key, under: shared.key, appleKeyID: shared.id)
        }
        envelope.keyFingerprint = PF.fp(key)
        let image = LibraryImage(libraryID: libraryID, fingerprint: PF.fp(key), record: nil, writing: 3)
        let at = tick()
        if asOlderLibrary {
            let folder = "\(CatalogNames.previousLibrariesFolderName)/\(CatalogNames.stampString(at))"
            device.container.files["\(folder)/\(SPath.slot)"] = .library(image)
            device.container.files["\(folder)/\(SPath.legacyKeyFile(PF.fp(key)))"] = .keyFile(.legacy(LegacyKeyFile(envelope: envelope)))
            truth.copies["container:\(folder)/\(SPath.slot)"] = CopyTruth(
                libraryID: libraryID, fingerprint: PF.fp(key), madeAt: at, madeOn: device.name, mode: mode, byOlderBuild: true,
                holder: holder)
        } else {
            let name = SPath.snapshot(at, PF.fp(key))
            device.container.files["\(CatalogNames.backupsFolderName)/\(name)"] = .library(image)
            device.container.files["\(CatalogNames.backupsFolderName)/\(SPath.pair(of: name))"] =
                .keyFile(.legacy(LegacyKeyFile(envelope: envelope)))
            truth.copies["container:\(CatalogNames.backupsFolderName)/\(name)"] = CopyTruth(
                libraryID: libraryID, fingerprint: PF.fp(key), madeAt: at, madeOn: device.name, mode: mode, byOlderBuild: true,
                holder: holder)
        }
        if mode == .castle { truth.castleBorn.insert(PF.fp(key)) }
        return TodayLib(libraryID: libraryID, key: key, olderKeys: [], holder: holder)
    }

    // MARK: - Today's build as an actor

    /// The slot's current key file, as today finds it (the fingerprint file
    /// whose fingerprint is the slot's; else the legacy name).
    func todayKeyFile(_ device: SDevice) -> (path: String, envelope: StoreKeyEnvelope)? {
        guard let slot = device.slot else { return nil }
        for (path, legacy) in legacyBeside(device) where legacy.fingerprint == slot.fingerprint || legacy.fingerprint == nil {
            return (path, legacy.envelope)
        }
        return nil
    }

    /// Today's raw key in hand: the bound item, the gated item (a press), else
    /// the typed passphrase through the key file.
    func todayKey(_ device: SDevice) -> StoreKey? {
        guard let slot = device.slot else { return nil }
        for name in [KName.legacyBound(Self.scope, slot.libraryID), KName.legacyGated(Self.scope, slot.libraryID)] {
            if let item = device.keychain.local[name], let key = pressRead(device, item)?.libraryKey, PF.fp(key) == slot.fingerprint {
                return key
            }
        }
        if let file = todayKeyFile(device), let holder = slotHolder(device), let p = known(holder).passphrase,
           let key = try? file.envelope.unwrapKey(passphrase: p, floor: PF.floor) {
            return key
        }
        return nil
    }

    /// Today's sync custody on an older device: the per-store item, or the
    /// session's memory.
    func todayMaterial(_ device: SDevice) -> DeviceKeyMaterial? {
        guard let slot = device.slot else { return nil }
        for gated in [false, true] {
            if let item = device.keychain.local[KName.legacySync(Self.scope, slot.libraryID, gated: gated)],
               let value = pressRead(device, item)?.material {
                return value
            }
        }
        return slot.rowsOwner.flatMap { device.sessionMemory[$0] }
    }

    /// Read the old shared key, else MINT it under the old name (today's
    /// `readOrMint`) — two devices minting leave one survivor.
    func todayReadOrMintShared(_ device: SDevice) -> AppleKeyMaterial {
        if let held = oldSharedKey(device) { return held }
        let key = mintApple()
        addSynced(device, KName.oldShared(Self.scope), KItem(value: .apple(id: key.id, bytes: PF.bytes(key.key))))
        return key
    }

    /// An older build's backup: today's flat `Backups/` pair, its frozen
    /// key file today's envelope.
    func olderBackup(_ device: SDevice) throws {
        guard device.build == .older, let slot = device.slot, let file = todayKeyFile(device) else { throw WorldRefusal.noLibrary }
        writePair(device, image: slot, keyFile: .legacy(LegacyKeyFile(envelope: file.envelope)), deviceID: "", olderBuild: true)
    }

    /// TODAY'S LEAVE (`PostureSwitch.leaveCastle`): the old shared key read or
    /// minted; ONE vault write adding the master under it (no rotation, the
    /// current proof); the key file's Apple copy of the SAME library key under
    /// it; custody gated → silent. Nothing rotated: the Castle-era master and
    /// library key now sit under the old shared Apple key (promise 13's one
    /// stated exception, §8).
    func olderLeaveCastle(_ device: SDevice) async throws {
        guard device.build == .older, let slot = device.slot, let key = todayKey(device),
              var file = todayKeyFile(device) else { throw WorldRefusal.noLibrary }
        let shared = todayReadOrMintShared(device)
        if let account = slot.rowsOwner, device.online, device.session.accountID == account,
           let material = todayMaterial(device), let vault = server.snapshot(account) {
            let updated = try vault.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: shared.key, appleKeyID: shared.id)
            _ = try server.update(updated, accountID: account, expectedRevision: vault.revision, proofMaster: material.masterSymmetricKey)
            truth.olderBuildLeaveKeys.insert(material.corpusKeyID)
            truth.olderExposedMasters.insert(material.masterKey)
        }
        try file.envelope.setAppleWrappedCopy(key: key, under: shared.key, appleKeyID: shared.id)
        device.container.files[file.path] = .keyFile(.legacy(LegacyKeyFile(envelope: file.envelope)))
        todayMoveCustody(device, key: key, toSilent: true)
        truth.olderBuildLeaveKeys.insert(PF.fp(key))
    }

    /// Today's custody move: gated → silent (both items), or the reverse.
    func todayMoveCustody(_ device: SDevice, key: StoreKey, toSilent: Bool) {
        guard let slot = device.slot else { return }
        let bound = KName.legacyBound(Self.scope, slot.libraryID), gated = KName.legacyGated(Self.scope, slot.libraryID)
        let syncBound = KName.legacySync(Self.scope, slot.libraryID, gated: false)
        let syncGated = KName.legacySync(Self.scope, slot.libraryID, gated: true)
        if toSilent {
            device.keychain.local[gated] = nil
            device.keychain.local[bound] = KItem(value: .key(key))
            if let item = device.keychain.local[syncGated] ?? device.keychain.local[syncBound] {
                device.keychain.local[syncGated] = nil
                device.keychain.local[syncBound] = KItem(value: item.value)
            }
        } else {
            device.keychain.local[bound] = nil
            device.keychain.local[gated] = KItem(value: .key(key), touchID: true, enrollment: device.biometry.generation)
        }
    }

    /// TODAY'S RE-LINK (`AppleRelinkModel`): READ the old shared key (never
    /// mint), and re-land the account's vault copy of the master under it —
    /// one CAS write under the proof.
    func olderRelink(_ device: SDevice) throws {
        guard device.build == .older, let slot = device.slot, let account = slot.rowsOwner, device.online,
              let shared = oldSharedKey(device), let material = todayMaterial(device), let vault = server.snapshot(account)
        else { throw WorldRefusal.noLibrary }
        let castle = vault.format.masterWrappedByAppleHeld == nil
        let updated = try vault.format.settingAppleHeldCopy(
            masterKey: material.masterSymmetricKey, appleKey: shared.key, appleKeyID: shared.id)
        _ = try server.update(updated, accountID: account, expectedRevision: vault.revision, proofMaster: material.masterSymmetricKey)
        // Today's Re-link reads no mode: on an account in Castle it puts the
        // Castle-era master under the old shared key exactly as an older
        // build's leave does — §8's exception, the same class (hand-forward:
        // the exception's sentence names a leave or a follow, not a Re-link).
        if castle {
            truth.olderBuildLeaveKeys.insert(material.corpusKeyID)
            truth.olderExposedMasters.insert(material.masterKey)
        }
    }

    /// TODAY'S FOLLOW. It reads the vault's mode from the Apple wrap ALONE: a
    /// wrap — Standard (the silent follow: the old shared key read or minted,
    /// the key file's Apple copy, custody silent; nothing typed, nothing
    /// rotated); no wrap and keys replaced — the follow into Castle (one secret
    /// typed, the new master picked up, its own library re-keyed under a new
    /// format-2 file with no Apple copy, custody gated; any rotation it finds
    /// walked and COMPLETED, carrying the vault's other fields through).
    func olderFollow(_ device: SDevice, typing: ProtectionSecret?) async throws {
        guard device.build == .older, let slot = device.slot, let account = slot.rowsOwner, device.online,
              device.session.accountID == account, let vault = server.snapshot(account),
              let key = todayKey(device), var file = todayKeyFile(device) else { throw WorldRefusal.noLibrary }
        let held = todayMaterial(device)
        if vault.format.masterWrappedByAppleHeld != nil {
            // Standard by the wrap: the silent follow.
            if file.envelope.apple == nil {
                let shared = todayReadOrMintShared(device)
                try file.envelope.setAppleWrappedCopy(key: key, under: shared.key, appleKeyID: shared.id)
                device.container.files[file.path] = .keyFile(.legacy(LegacyKeyFile(envelope: file.envelope)))
                todayMoveCustody(device, key: key, toSilent: true)
                truth.olderBuildLeaveKeys.insert(PF.fp(key))
            }
            if vault.format.previousCorpusKey != nil, let held, held.corpusKeyID == vault.corpusKeyID {
                try olderComplete(device, account: account, material: held)
            }
            return
        }
        // Castle by the wrap's absence.
        var master: SymmetricKey?
        switch typing {
        case .passphrase(let p)?:
            if let pk = passphraseKey(p, vault.format.kdf) { master = try? vault.format.unwrapMaster(withPassphraseKey: pk.key) }
        case .words(let w)?:
            if let wk = try? WordsKey.derive(w) { master = try? vault.format.unwrapMaster(withRecoveryKey: wk.key) }
        default:
            break
        }
        guard let master else { throw ExecutorRefusal.secretMissing }
        let material = try VaultModel.material(following: vault.format, master: master)
        let gated = device.legacySettings.gateStyle == .touchID && device.biometry.enrolled
        device.keychain.local[KName.legacySync(Self.scope, slot.libraryID, gated: false)] = nil
        if gated {
            device.keychain.local[KName.legacySync(Self.scope, slot.libraryID, gated: true)] = KItem(
                value: .legacySync(deviceID: device.olderDeviceID, material: material), touchID: true,
                enrollment: device.biometry.generation)
        } else {
            device.sessionMemory[account] = material
        }
        if held?.corpusKeyID != vault.corpusKeyID || file.envelope.apple != nil {
            // Re-key its own library: a new key, a new format-2 file under the
            // typed secret and the new master, no Apple copy; the old file
            // retired from the live folder.
            let newKey = mintKey()
            var envelope = StoreKeyEnvelope(storeID: slot.libraryID)
            if case .passphrase(let p)? = typing { try envelope.setPassphraseWrap(key: newKey, passphrase: p, kdf: vault.format.kdf) }
            if case .words(let w)? = typing { try envelope.setRecoveryWrap(key: newKey, words: w) }
            try envelope.setMasterWrappedCopy(key: newKey, under: master)
            try envelope.recordVaultReconciliation(
                kdf: vault.format.kdf, corpusKeyID: vault.corpusKeyID, recoveryWrapDigest: vault.format.recoveryWrapDigest)
            envelope.keyFingerprint = PF.fp(newKey)
            device.container.files[file.path] = nil
            device.container.files[SPath.legacyKeyFile(PF.fp(newKey))] = .keyFile(.legacy(LegacyKeyFile(envelope: envelope)))
            var image = slot
            image.fingerprint = PF.fp(newKey)
            device.container.files[SPath.slot] = .library(image)
            device.keychain.local[KName.legacyBound(Self.scope, slot.libraryID)] = nil
            device.keychain.local[KName.legacyGated(Self.scope, slot.libraryID)] = nil
            if gated { todayMoveCustody(device, key: newKey, toSilent: false) }
            truth.castleBorn.insert(PF.fp(newKey))
            file = (SPath.legacyKeyFile(PF.fp(newKey)), envelope)
        }
        if vault.format.previousCorpusKey != nil { try olderComplete(device, account: account, material: material) }
    }

    /// `CorpusRotation.complete`, today's: walk what's left below the seq and
    /// clear the previous key — carrying every other field through untouched,
    /// `apple_key_id` among them (no wrap added).
    func olderComplete(_ device: SDevice, account: String, material: DeviceKeyMaterial) throws {
        guard let vault = server.snapshot(account), vault.format.previousCorpusKey != nil else { return }
        var held = material
        if held.previousCorpusKeyID == nil, let previous = try? vault.format.unwrapPreviousCorpusKey(masterKey: held.masterSymmetricKey) {
            held = held.carryingPreviousCorpusKey(PF.bytes(previous.key), keyID: previous.keyID, startedSeq: 1)
        }
        _ = try server.reencrypt(accountID: account, material: held)
        guard let fresh = server.snapshot(account) else { return }
        _ = try server.update(
            fresh.format.clearingPreviousCorpusKey(), accountID: account, expectedRevision: fresh.revision,
            proofMaster: held.masterSymmetricKey)
    }
}
