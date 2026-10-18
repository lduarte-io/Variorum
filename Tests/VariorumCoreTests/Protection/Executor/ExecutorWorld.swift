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
    case syncKeys(ProtectionNames.CustodyClass)
    case syncKeysDelete(ProtectionNames.CustodyClass)
    case appleAdd(String)
    case appleDelete(String)
    case vaultCreate
    case vaultUpdate(String)
    case record(String)
    case stage(String)
    case stagedRecord(String)
    case swap(String)
    case discardStaged
    case keyFile(String)
    case memory(String)
    case memoryDelete(String)
    case plan
    case planDelete
    case backup(String)
    case sendPair(String)
    case copiesDelete
    case plaintextExport

    var description: String {
        switch self {
        case .custody(let fp, let c): return "custody+ \(c.rawValue) \(fp)"
        case .custodyDelete(let fp, let c): return "custody- \(c.rawValue) \(fp)"
        case .syncKeys(let c): return "sync+ \(c.rawValue)"
        case .syncKeysDelete(let c): return "sync- \(c.rawValue)"
        case .appleAdd(let id): return "apple+ \(id)"
        case .appleDelete(let id): return "apple- \(id)"
        case .vaultCreate: return "vault create"
        case .vaultUpdate(let what): return "vault \(what)"
        case .record(let fp): return "record \(fp)"
        case .stage(let fp): return "stage \(fp)"
        case .stagedRecord(let fp): return "staged-record \(fp)"
        case .swap(let fp): return "swap \(fp)"
        case .discardStaged: return "discard-staged"
        case .keyFile(let fp): return "keyfile \(fp)"
        case .memory(let fp): return "memory \(fp)"
        case .memoryDelete(let id): return "memory- \(id)"
        case .plan: return "plan"
        case .planDelete: return "plan-"
        case .backup(let fp): return "backup \(fp)"
        case .sendPair(let fp): return "send \(fp)"
        case .copiesDelete: return "copies-"
        case .plaintextExport: return "export"
        }
    }
}

func f8(_ key: StoreKey) -> String { String(PF.fp(key).prefix(8)) }
func f8(_ fingerprint: String) -> String { String(fingerprint.prefix(8)) }

/// iCloud Keychain, shared by the devices on one Apple account (U3: instant
/// propagation; U4's fake adds the delay, the off switch and the same-name rule).
final class ICloudKeychain {
    var keys: [String: AppleKeyMaterial] = [:]
    /// VX-390: each key's stamp — the library it was made for.
    var stamps: [String: String] = [:]
}

/// The server's vault (the model's row — VX-378 U2): CAS on the revision and
/// the key proof. Nothing else: no rotation, no walk.
final class ExecutorVault {
    struct Account {
        var revision: Int
        var vault: AccountVault
        var updatedAt: Date?
    }

    var accounts: [String: Account] = [:]
    var reachable = true
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)

    func snapshot(_ id: String) -> VaultSnapshot? {
        accounts[id].map { VaultSnapshot(accountID: id, revision: $0.revision, vault: $0.vault, updatedAt: $0.updatedAt) }
    }

    static func describe(_ vault: AccountVault) -> String { vault.mode.rawValue }

    func create(_ vault: AccountVault, accountID: String) throws -> VaultSnapshot {
        guard reachable else { throw VaultRefusal.unreachable }
        guard accounts[accountID] == nil else { throw VaultRefusal.vaultExists }
        clock += 60
        accounts[accountID] = Account(revision: 1, vault: vault, updatedAt: clock)
        return snapshot(accountID)!
    }

    func update(_ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey) throws -> VaultSnapshot {
        guard reachable else { throw VaultRefusal.unreachable }
        guard var account = accounts[accountID] else { throw VaultRefusal.vaultAbsent }
        guard account.revision == expectedRevision else { throw VaultRefusal.revisionConflict }
        guard KeyProof.hash(master: proofMaster) == account.vault.keyProofHash else { throw VaultRefusal.keyProofRefused }
        clock += 60
        account.vault = vault
        account.revision += 1
        account.updatedAt = clock
        accounts[accountID] = account
        return snapshot(accountID)!
    }
}

final class ExecutorWorld: CustodyLeaf, SyncKeysLeaf, AppleKeysLeaf, VaultLeaf, LibraryFileLeaf,
    KeyFileStoreLeaf, MemoryStoreLeaf, PlanStoreLeaf, BackupsLeaf, ClockLeaf, IDsLeaf, BiometryLeaf, DiagnosticsLeaf
{
    struct LibraryFile {
        var fingerprint: String
        var record: ProtectionRecord?
        /// The writing — a counter standing in for the rows.
        var generation: Int
    }

    struct Backup {
        var fingerprint: String
        var keyFile: KeyFile
        var record: ProtectionRecord?
        var deviceID: String
    }

    // The keychain.
    var custody: [CustodyItemFact: StoreKey] = [:]
    var syncItems: [SyncKeysItemFact: AccountKeys] = [:]
    var session: [String: AccountKeys] = [:]
    let icloud: ICloudKeychain
    let server: ExecutorVault

    // The container.
    var live: LibraryFile?
    var staged: LibraryFile?
    var aside: [LibraryFile] = []
    /// The key file set aside with each, in the same order.
    var asideKeyFiles: [KeyFile?] = []
    var copies: [String: LibraryFile] = [:]
    var liveKeyFile: KeyFile?
    var memories: [String: Sealed<DeviceMemory>] = [:]
    var plan: Sealed<ProtectionPlan>?
    var paused = false
    var backups: [Backup] = []
    var sent: [String: Backup] = [:]
    var exports: [String] = []

    // The rest.
    var clockTime = Date(timeIntervalSinceReferenceDate: 790_000_000)
    var bio = BiometryFacts.ready
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

    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass, libraryID: String) throws {
        // The stamp rides the fact (identity is the name — remove first so the
        // stored key carries the new stamp).
        let fact = CustodyItemFact(fingerprint: PF.fp(key), itemClass: itemClass, libraryID: libraryID)
        custody.removeValue(forKey: fact)
        custody[fact] = key
        try wrote(.custody(f8(key), itemClass))
    }

    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws {
        custody[CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)] = nil
        try wrote(.custodyDelete(f8(fingerprint), itemClass))
    }

    // MARK: - Sync keys

    func syncKeyItems() throws -> [SyncKeysItemFact] { Array(syncItems.keys) }

    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? {
        if itemClass == .touchid, !(bio.hardware && bio.enrolled && bio.transient == nil) { return nil }
        return syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)]
    }

    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = keys
        try wrote(.syncKeys(itemClass))
    }

    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        syncItems[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = nil
        try wrote(.syncKeysDelete(itemClass))
    }

    func holdInSession(_ keys: AccountKeys?, accountID: String) { session[accountID] = keys }
    func sessionSyncKeys(accountID: String) -> AccountKeys? { session[accountID] }

    // MARK: - Apple keys

    func readableAppleKeyIDs() throws -> Set<String> { Set(icloud.keys.keys) }
    func readAppleKey(id: String) throws -> AppleKeyMaterial? { icloud.keys[id] }

    func addAppleKey(_ key: AppleKeyMaterial, libraryID: String) throws {
        icloud.keys[key.id] = key
        icloud.stamps[key.id] = libraryID
        try wrote(.appleAdd(String(key.id.prefix(8))))
    }

    func deleteAppleKey(id: String) throws {
        guard icloud.keys[id] != nil else { return }
        icloud.keys[id] = nil
        icloud.stamps[id] = nil
        try wrote(.appleDelete(String(id.prefix(8))))
    }

    func appleKeyIDs(ofLibrary libraryID: String) throws -> Set<String> {
        Set(icloud.keys.keys.filter { icloud.stamps[$0] == libraryID })
    }

    // MARK: - The vault (this device's port onto the shared server)

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        guard server.reachable else { throw VaultRefusal.unreachable }
        return server.snapshot(accountID)
    }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        var named = vault
        named.updatedByDevice = device
        let snapshot = try server.create(named, accountID: accountID)
        try wrote(.vaultCreate)
        return snapshot
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device: String
    ) async throws -> VaultSnapshot {
        var named = vault
        named.updatedByDevice = device
        let snapshot = try server.update(named, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster)
        try wrote(.vaultUpdate(ExecutorVault.describe(snapshot.vault)))
        return snapshot
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
        staged = LibraryFile(fingerprint: PF.fp(newKey), record: live.record, generation: live.generation)
        try wrote(.stage(f8(newKey)))
    }

    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws {
        guard let copy = copies[copyID], copy.fingerprint == PF.fp(opener) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        staged = LibraryFile(fingerprint: PF.fp(newKey), record: copy.record, generation: copy.generation)
        try wrote(.stage(f8(newKey)))
    }

    func copyOpens(copyID: String, with key: StoreKey) throws -> Bool { copies[copyID]?.fingerprint == PF.fp(key) }

    func stagedFingerprint() throws -> String? { staged?.fingerprint }

    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws {
        guard staged?.fingerprint == PF.fp(newKey) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        staged?.record = record
        try wrote(.stagedRecord(f8(newKey)))
    }

    func swapStaged(setAside: Bool, asideKeyFile: KeyFile?) throws {
        guard let staged else { throw ExecutorRefusal.nothingToDo }
        if setAside, let live {
            aside.append(live)
            asideKeyFiles.append(asideKeyFile)
        }
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

    // MARK: - Key files

    func readLiveKeyFile() throws -> KeyFile? { liveKeyFile }

    /// The harness's backups and sent pairs, by their key files' own libraryID.
    func catalogedKeyFiles(ofLibrary libraryID: String) throws -> [KeyFile] {
        (backups + Array(sent.values)).map(\.keyFile).filter { $0.libraryID == libraryID }
    }

    /// The live key file (format 3 — the only one there is since rule 26).
    var liveFormat3: KeyFile? { liveKeyFile }

    func writeLiveKeyFile(_ file: KeyFile) throws {
        liveKeyFile = file
        try wrote(.keyFile(f8(file.fingerprint)))
    }

    // MARK: - Memory, plans

    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>? { memories[libraryID] }
    func rememberedLibraryIDs() throws -> Set<String> { Set(memories.keys) }

    func deleteMemory(libraryID: String) throws {
        guard memories[libraryID] != nil else { return }
        memories[libraryID] = nil
        try wrote(.memoryDelete(String(libraryID.prefix(8))))
    }

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
    func mintWords() -> [String] { (try? PF.words()) ?? [] }

    func biometry() -> BiometryFacts { bio }

    func log(_ line: String) { logLines.append(line) }
    func report(_ entry: ProtectionDiagnostic) { diagnosticEntries.append(entry) }

    // MARK: - Composition

    var leaves: ExecutorLeaves {
        ExecutorLeaves(
            custody: self, syncKeys: self, apple: self, vault: self, library: self, keyFiles: self,
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
