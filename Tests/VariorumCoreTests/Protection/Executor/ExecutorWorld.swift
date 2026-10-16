//
//  ExecutorWorld.swift
//  VariorumCoreTests — VX-305 U3: the simple in-memory leaves the executor's
//  tests run against (U4 brings the realistic fakes). One `ExecutorWorld` is
//  one Mac — its keychain, its container, its library — implementing every
//  leaf; a shared `ICloudKeychain` and a shared `ExecutorVault` (the server,
//  with CAS, the key proof and one rotation at a time) connect devices.
//
//  Every WRITE is logged in order (the "exact writes" tests read the log), and
//  a crash can be injected after any write: the write lands, then the process
//  dies (`SimulatedCrash`) — session memory and the paused-copies flag go with
//  it, the disk and the keychain stay. `relaunch()` is the next launch.
//

import CryptoKit
import Foundation

@testable import VariorumCore

struct SimulatedCrash: Error {}

/// One write, as the log records it. Fingerprints are eight characters.
enum WorldWrite: Equatable, CustomStringConvertible {
    case custody(String, ProtectionNames.CustodyClass)
    case custodyDelete(String, ProtectionNames.CustodyClass)
    case legacyDelete(String)
    case syncKeys(ProtectionNames.CustodyClass)
    case syncKeysDelete(ProtectionNames.CustodyClass)
    case appleAdd(String)
    case appleDelete(String)
    case oldSharedDelete(String)
    case vaultCreate
    case vaultUpdate(String)
    case reencrypt
    case record(String)
    case stage(String)
    case stagedRecord(String)
    case swap(String)
    case discardStaged
    case keyFile(String)
    case keyFileAside(String)
    case ownKeyFile(String)
    case legacyKeyFileDelete(String)
    case memory(String)
    case plan
    case planDelete
    case backup(String)
    case sendPair(String)
    case copiesDelete
    case plaintextExport
    case legacyMarkerClear

    var description: String {
        switch self {
        case .custody(let fp, let c): return "custody+ \(c.rawValue) \(fp)"
        case .custodyDelete(let fp, let c): return "custody- \(c.rawValue) \(fp)"
        case .legacyDelete(let kind): return "legacy- \(kind)"
        case .syncKeys(let c): return "sync+ \(c.rawValue)"
        case .syncKeysDelete(let c): return "sync- \(c.rawValue)"
        case .appleAdd(let id): return "apple+ \(id)"
        case .appleDelete(let id): return "apple- \(id)"
        case .oldSharedDelete(let id): return "shared- \(id)"
        case .vaultCreate: return "vault create"
        case .vaultUpdate(let what): return "vault \(what)"
        case .reencrypt: return "reencrypt"
        case .record(let fp): return "record \(fp)"
        case .stage(let fp): return "stage \(fp)"
        case .stagedRecord(let fp): return "staged-record \(fp)"
        case .swap(let fp): return "swap \(fp)"
        case .discardStaged: return "discard-staged"
        case .keyFile(let fp): return "keyfile \(fp)"
        case .keyFileAside(let name): return "keyfile-aside \(name)"
        case .ownKeyFile(let library): return "own-keyfile \(library)"
        case .legacyKeyFileDelete(let id): return "legacy-keyfile- \(id)"
        case .memory(let fp): return "memory \(fp)"
        case .plan: return "plan"
        case .planDelete: return "plan-"
        case .backup(let fp): return "backup \(fp)"
        case .sendPair(let fp): return "send \(fp)"
        case .copiesDelete: return "copies-"
        case .plaintextExport: return "export"
        case .legacyMarkerClear: return "marker-"
        }
    }
}

func f8(_ key: StoreKey) -> String { String(PF.fp(key).prefix(8)) }
func f8(_ fingerprint: String) -> String { String(fingerprint.prefix(8)) }

/// iCloud Keychain, shared by the devices on one Apple account (U3: instant
/// propagation; U4's fake adds the delay, the off switch and the same-name rule).
final class ICloudKeychain {
    var keys: [String: AppleKeyMaterial] = [:]
    var oldShared: AppleKeyMaterial?
}

/// The server's vault: CAS on the revision, the key proof, one rotation at a
/// time, completion refused while rows remain below the seq.
final class ExecutorVault {
    struct Account {
        var revision: Int
        var format: KeyVaultFormat
        var rows: Int
        var updatedAt: Date?
    }

    var accounts: [String: Account] = [:]
    /// The rows a rotation finds below its seq.
    var corpusRows = 3
    var reachable = true
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)

    func snapshot(_ id: String) -> VaultSnapshot? {
        accounts[id].map {
            VaultSnapshot(accountID: id, revision: $0.revision, format: $0.format, rowsBelowRotationSeq: $0.rows,
                          updatedAt: $0.updatedAt)
        }
    }

    static func describe(_ format: KeyVaultFormat) -> String {
        var parts: [String] = []
        if format.previousCorpusKey != nil { parts.append("rotating") }
        if format.masterWrappedByAppleHeld != nil { parts.append("apple-wrap") }
        else if format.appleKeyID != nil { parts.append("apple-id-no-wrap") }
        return parts.isEmpty ? "castle" : parts.joined(separator: " ")
    }

    func create(_ format: KeyVaultFormat, accountID: String) throws -> VaultSnapshot {
        guard reachable else { throw VaultRefusal.unreachable }
        guard accounts[accountID] == nil else { throw VaultRefusal.vaultExists }
        clock += 60
        accounts[accountID] = Account(revision: 1, format: format, rows: 0, updatedAt: clock)
        return snapshot(accountID)!
    }

    func update(_ format: KeyVaultFormat, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey) throws -> VaultSnapshot {
        guard reachable else { throw VaultRefusal.unreachable }
        guard var account = accounts[accountID] else { throw VaultRefusal.vaultAbsent }
        guard account.revision == expectedRevision else { throw VaultRefusal.revisionConflict }
        guard KeyProof.hash(master: proofMaster) == account.format.keyProofHash else { throw VaultRefusal.keyProofRefused }
        var next = format
        if let incoming = format.previousCorpusKey {
            if let standing = account.format.previousCorpusKey {
                guard standing.keyID == incoming.keyID else { throw VaultRefusal.rotationInProgress }
            } else {
                account.rows = corpusRows
                next.rotationStartedSeq = Int64(account.revision + 100)
            }
        } else if account.format.previousCorpusKey != nil, account.rows > 0 {
            throw VaultRefusal.rotationRowsRemain
        }
        clock += 60
        account.format = next
        account.revision += 1
        account.updatedAt = clock
        accounts[accountID] = account
        return snapshot(accountID)!
    }

    func reencrypt(accountID: String, material: DeviceKeyMaterial) throws -> Int {
        guard reachable else { throw VaultRefusal.unreachable }
        guard var account = accounts[accountID] else { throw VaultRefusal.vaultAbsent }
        guard material.corpusKeyID == account.format.classKey(for: .corpus)?.keyID,
              material.previousCorpusKeyID == account.format.previousCorpusKey?.keyID
        else { throw VaultRefusal.keyProofRefused }
        let count = account.rows
        account.rows = 0
        accounts[accountID] = account
        return count
    }
}

final class ExecutorWorld: CustodyLeaf, LegacyItemsLeaf, SyncKeysLeaf, AppleKeysLeaf, VaultLeaf, LibraryFileLeaf,
    KeyFileStoreLeaf, MemoryStoreLeaf, PlanStoreLeaf, BackupsLeaf, ClockLeaf, IDsLeaf, BiometryLeaf, DiagnosticsLeaf
{
    struct LibraryFile {
        var fingerprint: String
        var record: ProtectionRecord?
        /// The writing — a counter standing in for the rows.
        var generation: Int
        var marker: LegacyRotationMarker?
    }

    struct Backup {
        var fingerprint: String
        var keyFile: KeyFile
        var record: ProtectionRecord?
        var deviceID: String
    }

    // The keychain.
    var custody: [CustodyItemFact: StoreKey] = [:]
    var legacy: [LegacyItemFact.Kind: StoreKey] = [:]
    var syncItems: [SyncKeysItemFact: DeviceKeyMaterial] = [:]
    var session: [String: DeviceKeyMaterial] = [:]
    let icloud: ICloudKeychain
    let server: ExecutorVault

    // The container.
    var live: LibraryFile?
    var staged: LibraryFile?
    var aside: [LibraryFile] = []
    var copies: [String: LibraryFile] = [:]
    var liveKeyFile: KeyFileDocument?
    var ownKeyFiles: [String: KeyFile] = [:]
    var legacyBeside: [String: LegacyKeyFile] = [:]
    var catalogKeyFiles: [String: KeyFileDocument] = [:]
    /// Key files moved out of the live place, by their set-aside names.
    var setAsideKeyFiles: [String: KeyFileDocument] = [:]
    var memories: [String: Sealed<DeviceMemory>] = [:]
    var plan: Sealed<ProtectionPlan>?
    var paused = false
    var backups: [Backup] = []
    var sent: [String: Backup] = [:]
    var exports: [String] = []

    // The rest.
    var clockTime = Date(timeIntervalSinceReferenceDate: 790_000_000)
    var bio = BiometryFacts.ready
    var stateHash: Data? = Data([7, 7])
    var logLines: [String] = []
    var diagnosticEntries: [ProtectionDiagnostic] = []

    /// The write log, and the crash.
    var writes: [WorldWrite] = []
    var crashAfterWrites: Int?
    /// Pauses and resumes of copies — in-process, not writes.
    var copyEvents: [String] = []

    init(icloud: ICloudKeychain = ICloudKeychain(), server: ExecutorVault = ExecutorVault()) {
        self.icloud = icloud
        self.server = server
    }

    // MARK: - The crash

    func wrote(_ write: WorldWrite) throws {
        writes.append(write)
        if let crash = crashAfterWrites, writes.count >= crash {
            crashAfterWrites = nil
            throw SimulatedCrash()
        }
    }

    /// The next launch: session memory and in-process state gone, the disk
    /// and the keychain as the crash left them.
    func relaunch() {
        session.removeAll()
        paused = false
        crashAfterWrites = nil
    }

    // MARK: - Custody

    func custodyItems() throws -> [CustodyItemFact] { Array(custody.keys).sorted { "\($0)" < "\($1)" } }

    func readCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws -> StoreKey? {
        if itemClass == .touchid, !(bio.hardware && bio.enrolled && bio.transient == nil) { return nil }
        return custody[CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)]
    }

    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass) throws {
        custody[CustodyItemFact(fingerprint: PF.fp(key), itemClass: itemClass)] = key
        try wrote(.custody(f8(key), itemClass))
    }

    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws {
        custody[CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)] = nil
        try wrote(.custodyDelete(f8(fingerprint), itemClass))
    }

    // MARK: - Legacy items

    func legacyItems() throws -> [LegacyItemFact] {
        legacy.map { kind, key in
            if case .gated = kind { return LegacyItemFact(kind: kind, fingerprint: nil) }
            return LegacyItemFact(kind: kind, fingerprint: PF.fp(key))
        }
    }

    func readLegacyItem(_ kind: LegacyItemFact.Kind) throws -> StoreKey? { legacy[kind] }

    func deleteLegacyItem(_ kind: LegacyItemFact.Kind) throws {
        legacy[kind] = nil
        try wrote(.legacyDelete("\(kind)"))
    }

    // MARK: - Sync keys

    func syncKeyItems() throws -> [SyncKeysItemFact] { Array(syncItems.keys) }

    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> DeviceKeyMaterial? {
        if itemClass == .touchid, !(bio.hardware && bio.enrolled && bio.transient == nil) { return nil }
        return syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)]
    }

    func writeSyncKeys(_ material: DeviceKeyMaterial, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = material
        try wrote(.syncKeys(itemClass))
    }

    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = nil
        try wrote(.syncKeysDelete(itemClass))
    }

    func holdInSession(_ material: DeviceKeyMaterial?, accountID: String) { session[accountID] = material }
    func sessionSyncKeys(accountID: String) -> DeviceKeyMaterial? { session[accountID] }

    // MARK: - Apple keys

    func readableAppleKeyIDs() throws -> Set<String> { Set(icloud.keys.keys) }
    func readAppleKey(id: String) throws -> AppleKeyMaterial? { icloud.keys[id] }

    func addAppleKey(_ key: AppleKeyMaterial) throws {
        icloud.keys[key.id] = key
        try wrote(.appleAdd(String(key.id.prefix(8))))
    }

    func deleteAppleKey(id: String) throws {
        guard icloud.keys[id] != nil else { return }
        icloud.keys[id] = nil
        try wrote(.appleDelete(String(id.prefix(8))))
    }

    func readOldSharedAppleKey() throws -> AppleKeyMaterial? { icloud.oldShared }

    func deleteOldSharedAppleKey(id: String) throws -> Bool {
        guard let shared = icloud.oldShared, shared.id == id else { return false }
        icloud.oldShared = nil
        try wrote(.oldSharedDelete(String(id.prefix(8))))
        return true
    }

    // MARK: - The vault (this device's port onto the shared server)

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        guard server.reachable else { throw VaultRefusal.unreachable }
        return server.snapshot(accountID)
    }

    func createVault(_ format: KeyVaultFormat, accountID: String, device: String) async throws -> VaultSnapshot {
        var named = format
        named.updatedByDevice = device
        let snapshot = try server.create(named, accountID: accountID)
        try wrote(.vaultCreate)
        return snapshot
    }

    func updateVault(
        _ format: KeyVaultFormat, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device: String
    ) async throws -> VaultSnapshot {
        var named = format
        named.updatedByDevice = device
        let snapshot = try server.update(named, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster)
        try wrote(.vaultUpdate(ExecutorVault.describe(snapshot.format)))
        return snapshot
    }

    func reencryptBelowRotationSeq(accountID: String, material: DeviceKeyMaterial) async throws -> Int {
        let count = try server.reencrypt(accountID: accountID, material: material)
        try wrote(.reencrypt)
        return count
    }

    // MARK: - The library file

    func libraryOpens(with key: StoreKey) throws -> Bool { live?.fingerprint == PF.fp(key) }

    func readRecord(with key: StoreKey) throws -> ProtectionRecord? {
        guard let live, live.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        return live.record
    }

    func writeRecord(_ record: ProtectionRecord, with key: StoreKey) throws {
        guard live?.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        live?.record = record
        try wrote(.record(f8(key)))
    }

    func stageReencryption(from key: StoreKey, to newKey: StoreKey) throws {
        guard let live, live.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        staged = LibraryFile(fingerprint: PF.fp(newKey), record: live.record, generation: live.generation, marker: live.marker)
        try wrote(.stage(f8(newKey)))
    }

    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws {
        guard let copy = copies[copyID], copy.fingerprint == PF.fp(opener) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        staged = LibraryFile(fingerprint: PF.fp(newKey), record: copy.record, generation: copy.generation, marker: copy.marker)
        try wrote(.stage(f8(newKey)))
    }

    func stagedFingerprint() throws -> String? { staged?.fingerprint }

    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws {
        guard staged?.fingerprint == PF.fp(newKey) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        staged?.record = record
        try wrote(.stagedRecord(f8(newKey)))
    }

    func swapStaged(setAside: Bool) throws {
        guard let staged else { throw ExecutorRefusal.nothingToDo }
        if setAside, let live { aside.append(live) }
        live = staged
        self.staged = nil
        try wrote(.swap(f8(staged.fingerprint)))
    }

    func discardStaged() throws {
        guard staged != nil else { return }
        staged = nil
        try wrote(.discardStaged)
    }

    func createLibrary(with key: StoreKey, record: ProtectionRecord) throws {
        guard live == nil else { throw ExecutorRefusal.nothingToDo }
        live = LibraryFile(fingerprint: PF.fp(key), record: record, generation: 1)
        try wrote(.record(f8(key)))
    }

    func exportPlaintext(with key: StoreKey, to destination: String) throws {
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        exports.append(destination)
        try wrote(.plaintextExport)
    }

    func readLegacyRotationMarker(with key: StoreKey) throws -> LegacyRotationMarker? {
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        return live?.marker
    }

    func clearLegacyRotationMarker(with key: StoreKey) throws {
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        live?.marker = nil
        try wrote(.legacyMarkerClear)
    }

    // MARK: - Key files

    func readLiveKeyFile() throws -> KeyFileDocument? { liveKeyFile }

    var liveFormat3: KeyFile? {
        if case .format3(let file)? = liveKeyFile { return file }
        return nil
    }

    func writeLiveKeyFile(_ file: KeyFile) throws {
        liveKeyFile = .format3(file)
        try wrote(.keyFile(f8(file.fingerprint)))
    }

    func readOwnKeyFile(libraryID: String, deviceID: String) throws -> KeyFile? { ownKeyFiles[libraryID] }

    func writeOwnKeyFile(_ file: KeyFile, deviceID: String) throws {
        ownKeyFiles[file.libraryID] = file
        try wrote(.ownKeyFile(String(file.libraryID.prefix(8))))
    }

    func legacyKeyFilesBesideLibrary() throws -> [(id: String, file: LegacyKeyFile)] {
        legacyBeside.sorted { $0.key < $1.key }.map { (id: $0.key, file: $0.value) }
    }

    func deleteLegacyKeyFile(id: String) throws {
        legacyBeside[id] = nil
        try wrote(.legacyKeyFileDelete(id))
    }

    func readKeyFile(catalogID: String) throws -> KeyFileDocument? { catalogKeyFiles[catalogID] }

    func setAsideLiveKeyFile(as name: String) throws -> Bool {
        guard let file = liveKeyFile else { return true }
        guard setAsideKeyFiles[name] == nil else { return false }
        setAsideKeyFiles[name] = file
        liveKeyFile = nil
        try wrote(.keyFileAside(name))
        return true
    }

    // MARK: - Memory, plans

    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>? { memories[libraryID] }

    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws {
        memories[libraryID] = memory
        try wrote(.memory(f8(memory.sealedUnder)))
    }

    func readPlan() throws -> Sealed<ProtectionPlan>? { plan }

    func writePlan(_ plan: Sealed<ProtectionPlan>) throws {
        self.plan = plan
        try wrote(.plan)
    }

    func deletePlan() throws {
        guard plan != nil else { return }
        plan = nil
        try wrote(.planDelete)
    }

    // MARK: - Backups

    func pauseCopies() {
        if !paused { copyEvents.append("pause") }
        paused = true
    }

    func resumeCopies() {
        if paused { copyEvents.append("resume") }
        paused = false
    }

    func takeBackupPair(with key: StoreKey, keyFile: KeyFile, deviceID: String) throws {
        guard !paused else { throw ExecutorRefusal.nothingToDo }
        guard try libraryOpens(with: key), keyFile.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        backups.append(Backup(fingerprint: PF.fp(key), keyFile: keyFile, record: live?.record, deviceID: deviceID))
        try wrote(.backup(f8(key)))
    }

    func writeSendPair(with key: StoreKey, keyFile: KeyFile, to destination: String) throws {
        guard !paused else { throw ExecutorRefusal.nothingToDo }
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        sent[destination] = Backup(fingerprint: PF.fp(key), keyFile: keyFile, record: live?.record, deviceID: "")
        try wrote(.sendPair(f8(key)))
    }

    func deleteCopies(ids: [String]) throws {
        for id in ids { copies[id] = nil }
        try wrote(.copiesDelete)
    }

    // MARK: - Clock, IDs, biometry, diagnostics

    func now() -> Date {
        clockTime += 1
        return clockTime
    }

    /// Every secret this world ever minted — the log scan's needles.
    var minted: [Data] = []

    func mintID() -> String { UUID().uuidString.lowercased() }
    func mintLibraryKey() -> StoreKey {
        let key = StoreKey.mint()
        minted.append(key.data)
        return key
    }
    func mintAppleKey() -> AppleKeyMaterial {
        let key = AppleKeyMaterial.mint()
        minted.append(PF.bytes(key.key))
        return key
    }
    func mintSymmetricKey() -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        minted.append(PF.bytes(key))
        return key
    }
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor { PF.fastKDF() }

    func biometry() -> BiometryFacts { bio }
    func biometryStateHash() -> Data? { stateHash }

    func log(_ line: String) { logLines.append(line) }
    func report(_ entry: ProtectionDiagnostic) { diagnosticEntries.append(entry) }

    // MARK: - Composition

    var leaves: ExecutorLeaves {
        ExecutorLeaves(
            custody: self, legacyItems: self, syncKeys: self, apple: self, vault: self, library: self, keyFiles: self,
            memory: self, plans: self, backups: self, clock: self, ids: self, biometry: self, diagnostics: self)
    }

    /// The written log as text, with known fingerprints named.
    func writeLog(naming names: [String: String] = [:]) -> [String] {
        writes.map { write in
            var text = write.description
            for (fingerprint, name) in names { text = text.replacingOccurrences(of: f8(fingerprint), with: name) }
            return text
        }
    }
}
