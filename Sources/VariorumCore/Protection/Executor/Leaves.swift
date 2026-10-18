import CryptoKit
import Foundation

// VX-305 U3 — THE LEAVES (the phase plan §2: "Leaves (protocols: Custody,
// SyncKeys, AppleKeys, Vault, LibraryFile, KeyFileStore, MemoryStore,
// PlanStore, Backups, Clock, IDs, Biometry/LAEnvironment)"). Every place the
// protection system touches the world is one of these, and THE EXECUTOR IS THE
// ONLY THING THAT CALLS A WRITING LEAF (design §3.3): `assess` takes plain
// values and calls nothing. Phase 2 wires the real Keychain, file and
// SQLCipher leaves, phase 3 the vault's RPCs; U3 tests
// against simple in-memory leaves and U4 brings the realistic fakes.
//
// The leaves are deliberately DUMB: a leaf reads or writes exactly what it is
// told, verifies nothing about protection, and decides nothing. Every
// decision — which item may go, which key a wrap names, whether a vault read
// is fresh — is the executor's, so a guard that switches one off (the DEBUG
// mutation pins) reaches the bug it guards against.
//
// Only the vault is asynchronous (it is the network); everything else is the
// device's own Keychain and disk.

// MARK: - Custody — one Keychain item per library key, of the key's kind for life (§3.2)

public protocol CustodyLeaf: AnyObject {
    /// This scope's items, enumerated by name — no secret read.
    func custodyItems() throws -> [CustodyItemFact]
    /// The key an item holds. A Touch ID item's read is a press (nil: no such
    /// item, the press failed, or Touch ID is unusable for now).
    func readCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws -> StoreKey?
    /// Write (or replace) the item for `key`. A Touch ID item is made only at
    /// a person's press — an act's step, never a repair (§3.10).
    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass) throws
    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws
}

/// The sync keys — the bound account's master, its current sync key and every
/// earlier one (`AccountKeys`, rule 15) — held by the ACCOUNT'S MODE (rule
/// 15's custody): Castle, a Touch ID item or session memory; Standard, a silent
/// item. One item per account.
public protocol SyncKeysLeaf: AnyObject {
    func syncKeyItems() throws -> [SyncKeysItemFact]
    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys?
    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws
    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws
    /// Session memory (Always ask): never a disk write, gone at a relock or a
    /// crash. nil clears it.
    func holdInSession(_ keys: AccountKeys?, accountID: String)
    func sessionSyncKeys(accountID: String) -> AccountKeys?
}

/// Apple keys: iCloud Keychain items, synchronizable, NAMED BY THEIR OWN ID
/// (`<scope>-apple-key-<id>`) (§3.5; the old shared `<scope>-apple-key` left
/// with rule 26).
public protocol AppleKeysLeaf: AnyObject {
    /// The ids of this scope's own-named items readable here.
    func readableAppleKeyIDs() throws -> Set<String>
    func readAppleKey(id: String) throws -> AppleKeyMaterial?
    /// Add a freshly minted key under its own name (iCloud Keychain carries it
    /// wherever it is on — Variorum can't see).
    func addAppleKey(_ key: AppleKeyMaterial) throws
    func deleteAppleKey(id: String) throws
}

/// The vault (server): CAS on the revision and the key proof, over the row
/// `AccountVault` models (rules 14, 15 — P and W only, the mode flag, the
/// earlier sync keys; VX-378 U2). The server's change to this shape is a
/// SyncSpec §12 lockstep event, VX-307's; phase 3 wires the client behind it.
/// (The walk that re-encrypted rows below a rotation seq left with VX-378 U2:
/// rows are read under the key their own label names, rule 15.)
public protocol VaultLeaf: AnyObject {
    func fetchVault(accountID: String) async throws -> VaultSnapshot?
    /// Create the account's vault (sync setup, the first device).
    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot
    /// One CAS write under the CURRENT master's proof (decision 12).
    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device: String
    ) async throws -> VaultSnapshot
}

/// The library file — SQLCipher in the slot (phase 2). The record lives
/// inside it (`protection_record`, local-only), so reading or writing the
/// record needs the key it is under.
public protocol LibraryFileLeaf: AnyObject {
    /// Does `key` open the live library file? (Every road verifies itself.)
    func libraryOpens(with key: StoreKey) throws -> Bool
    /// The record inside the live file (nil: a library from before this
    /// design — rule 26: it is not handled, and never unlocks).
    func readRecord(with key: StoreKey) throws -> ProtectionRecord?
    func writeRecord(_ record: ProtectionRecord, with key: StoreKey) throws
    /// Export-and-swap's first half: the live library re-encrypted into a
    /// staged file under `newKey` (`sqlcipher_export`), the live file untouched.
    func stageReencryption(from key: StoreKey, to newKey: StoreKey) throws
    /// A copy (by its catalog id) re-encrypted into the staged file under
    /// `newKey`, opened with `opener` — Make this my library (rule 17).
    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws
    /// Does `key` open the copy (by its catalog id)? A READ — Look inside's
    /// proof, which writes nothing (rule 17).
    func copyOpens(copyID: String, with key: StoreKey) throws -> Bool
    /// The fingerprint of the key the staged file is under (nil: none staged).
    func stagedFingerprint() throws -> String?
    /// The record written into the staged file before the swap (§3.4).
    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws
    /// THE SWAP — the staged file into the slot, atomically. `setAside` keeps
    /// the outgoing library as an older library (`Previous Libraries/`), WITH
    /// `asideKeyFile` — its own key file (rule 1: the key file is as essential
    /// as the library), which the executor names since the live place may
    /// already hold the incoming library's.
    func swapStaged(setAside: Bool, asideKeyFile: KeyFile?) throws
    func discardStaged() throws
    /// A new library in the empty slot, under `key`, its record inside.
    func createLibrary(with key: StoreKey, record: ProtectionRecord) throws
    /// A plaintext export carrying its library ID (§3.7).
    func exportPlaintext(with key: StoreKey, to destination: String) throws
}

/// Key files: THE live one beside the library. Format 3 only (rule 26; this
/// Mac's own key files for other libraries — the move's gifts — left with
/// rule 19).
public protocol KeyFileStoreLeaf: AnyObject {
    func readLiveKeyFile() throws -> KeyFile?
    func writeLiveKeyFile(_ file: KeyFile) throws
    /// Every catalogued key file OF THIS LIBRARY outside the live place — the
    /// backups' (this Mac's folders and the shared ones), Previous Libraries'
    /// — whose own `libraryID` is `libraryID`. A READ. Entering Castle sweeps
    /// the keys these files name and the Apple keys they are wrapped under
    /// (rule 11): a key the live file's history has forgotten — a Time Machine
    /// rollback put an older file back while the keychain kept the rolled-back
    /// stretch's items — is still this library's by the file's own word, and
    /// its backup's history reaches the library's earlier keys (the gate's
    /// seed 3, VX-378 U4).
    func catalogedKeyFiles(ofLibrary libraryID: String) throws -> [KeyFile]
}

/// What this Mac remembers — one sealed non-secret item per library ID.
public protocol MemoryStoreLeaf: AnyObject {
    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>?
    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws
    /// The library IDs this scope's memory items name, enumerated by name — no
    /// item read (rule 21: "this Mac remembers … its library").
    func rememberedLibraryIDs() throws -> Set<String>
    /// The item for `libraryID` deleted — only at a door that makes another
    /// library this Mac's (a creation, Make this my library).
    func deleteMemory(libraryID: String) throws
}

/// The plan beside the library (one at a time; excluded from backups).
public protocol PlanStoreLeaf: AnyObject {
    func readPlan() throws -> Sealed<ProtectionPlan>?
    func writePlan(_ plan: Sealed<ProtectionPlan>) throws
    func deletePlan() throws
}

/// Backups: pairs (the snapshot + its frozen key file), never rewritten.
public protocol BackupsLeaf: AnyObject {
    /// Copies pause from an act's prepare to its swap (§3.7) — in-process.
    func pauseCopies()
    func resumeCopies()
    /// A fresh backup pair of the live library under `key`, its frozen key
    /// file `keyFile` (this Mac's `Backups/<library8>/<mac8>/`).
    func takeBackupPair(with key: StoreKey, keyFile: KeyFile, deviceID: String) throws
    /// Send Library: the pair, written to a folder she picked.
    func writeSendPair(with key: StoreKey, keyFile: KeyFile, to destination: String) throws
    /// Delete copies (each with its pair) by catalog id.
    func deleteCopies(ids: [String]) throws
}

public protocol ClockLeaf: AnyObject {
    func now() -> Date
}

/// Every random thing the executor mints — one leaf, so U4's world can seed it
/// and a failing seed replays exactly.
public protocol IDsLeaf: AnyObject {
    func mintID() -> String
    func mintLibraryKey() -> StoreKey
    func mintAppleKey() -> AppleKeyMaterial
    func mintSymmetricKey() -> SymmetricKey
    /// A FRESH KDF descriptor for a NEW passphrase (a fresh salt — the route
    /// finder's `.current` reading rests on it: an equal descriptor is the
    /// same passphrase; U2's hand-forward).
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor
    /// A library's twelve words, minted at its creation (rule 2: "every
    /// library has twelve words from the moment it is created") — BIP-39,
    /// shown once, never stored.
    func mintWords() -> [String]
}

/// `LAEnvironment` (the Apple facts §5).
public protocol BiometryLeaf: AnyObject {
    func biometry() -> BiometryFacts
}

/// The log and Diagnostics. Nothing written here ever carries key material
/// (design §3.2) — the executor speaks in act names, step names and
/// eight-character fingerprints.
public protocol DiagnosticsLeaf: AnyObject {
    func log(_ line: String)
    func report(_ entry: ProtectionDiagnostic)
}

/// What Diagnostics lists — typed, so no entry can carry a secret.
public enum ProtectionDiagnostic: Equatable, Sendable {
    /// A plan on disk this Mac's section doesn't name, or one failing its
    /// seal — ignored (§3.6).
    case planIgnored(PlanIgnoredReason)
    /// An act rolled back before its commit point, or finished from the
    /// record after it, with no plan to resume (§3.6).
    case actRolledBack(ProtectionAct)
    case actFinishedFromRecord(ProtectionAct)
    /// A repair skipped because its precondition did not verify.
    case repairSkipped(String)

    public enum PlanIgnoredReason: String, Equatable, Sendable {
        case unsealed
        case notNamed
        case noActInFlight
    }
}

/// All the leaves, together.
public struct ExecutorLeaves {
    public var custody: any CustodyLeaf
    public var syncKeys: any SyncKeysLeaf
    public var apple: any AppleKeysLeaf
    public var vault: any VaultLeaf
    public var library: any LibraryFileLeaf
    public var keyFiles: any KeyFileStoreLeaf
    public var memory: any MemoryStoreLeaf
    public var plans: any PlanStoreLeaf
    public var backups: any BackupsLeaf
    public var clock: any ClockLeaf
    public var ids: any IDsLeaf
    public var biometry: any BiometryLeaf
    public var diagnostics: any DiagnosticsLeaf

    public init(
        custody: any CustodyLeaf, syncKeys: any SyncKeysLeaf,
        apple: any AppleKeysLeaf, vault: any VaultLeaf, library: any LibraryFileLeaf,
        keyFiles: any KeyFileStoreLeaf, memory: any MemoryStoreLeaf, plans: any PlanStoreLeaf,
        backups: any BackupsLeaf, clock: any ClockLeaf, ids: any IDsLeaf, biometry: any BiometryLeaf,
        diagnostics: any DiagnosticsLeaf
    ) {
        self.custody = custody
        self.syncKeys = syncKeys
        self.apple = apple
        self.vault = vault
        self.library = library
        self.keyFiles = keyFiles
        self.memory = memory
        self.plans = plans
        self.backups = backups
        self.clock = clock
        self.ids = ids
        self.biometry = biometry
        self.diagnostics = diagnostics
    }
}
