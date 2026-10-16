import CryptoKit
import Foundation

// VX-305 U3 — THE LEAVES (the phase plan §2: "Leaves (protocols: Custody,
// SyncKeys, AppleKeys, Vault, LibraryFile, KeyFileStore, MemoryStore,
// PlanStore, Backups, Clock, IDs, Biometry/LAEnvironment)"). Every place the
// protection system touches the world is one of these, and THE EXECUTOR IS THE
// ONLY THING THAT CALLS A WRITING LEAF (design §3.3): `assess` takes plain
// values and calls nothing. Phase 2 wires the real Keychain, file and
// SQLCipher leaves, phase 3 the vault's RPCs and the rotation driver; U3 tests
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

/// Today's items, by the legacy readers' names (`LegacyItems`) — read by the
/// migration's fold, deleted by the Castle repairs once the history holds
/// their key (§3.3, §3.13).
public protocol LegacyItemsLeaf: AnyObject {
    func legacyItems() throws -> [LegacyItemFact]
    /// The raw key a legacy item holds (a gated item's read is a press).
    func readLegacyItem(_ kind: LegacyItemFact.Kind) throws -> StoreKey?
    func deleteLegacyItem(_ kind: LegacyItemFact.Kind) throws
}

/// The sync keys — M, C, J for the bound account — held by what they can
/// reach (§3.2): a Touch ID item or session memory while they reach a
/// Castle-era key, a silent item otherwise. One item per account.
public protocol SyncKeysLeaf: AnyObject {
    func syncKeyItems() throws -> [SyncKeysItemFact]
    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> DeviceKeyMaterial?
    func writeSyncKeys(_ material: DeviceKeyMaterial, accountID: String, itemClass: ProtectionNames.CustodyClass) throws
    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws
    /// Session memory (Always ask): never a disk write, gone at a relock or a
    /// crash. nil clears it.
    func holdInSession(_ material: DeviceKeyMaterial?, accountID: String)
    func sessionSyncKeys(accountID: String) -> DeviceKeyMaterial?
}

/// Apple keys: iCloud Keychain items, synchronizable, NAMED BY THEIR OWN ID
/// (`<scope>-apple-key-<id>`), plus the old shared `<scope>-apple-key` this
/// build only reads and retires (§3.5).
public protocol AppleKeysLeaf: AnyObject {
    /// The ids of this scope's own-named items readable here.
    func readableAppleKeyIDs() throws -> Set<String>
    func readAppleKey(id: String) throws -> AppleKeyMaterial?
    /// Add a freshly minted key under its own name (iCloud Keychain carries it
    /// wherever it is on — Variorum can't see).
    func addAppleKey(_ key: AppleKeyMaterial) throws
    func deleteAppleKey(id: String) throws
    /// The old shared key's `{id, key}`, while readable here.
    func readOldSharedAppleKey() throws -> AppleKeyMaterial?
    /// Delete the old-name item — but only when the item there now carries
    /// `id` (the leaf reads its value first; a new old-name item an older
    /// build minted later has another id and is left alone). Returns whether
    /// it deleted.
    func deleteOldSharedAppleKey(id: String) throws -> Bool
}

/// The vault (server) — the existing protocol, unchanged (§3.12): CAS on the
/// revision, the key proof, one rotation at a time, the rotation fields.
/// Phase 3 wires `KeyVaultClient` and `CorpusRotation` behind it (the `Sync/`
/// half, Fable's); here it is MODELLED, so the acts' order, resume and guards
/// are fixed before any `Sync/` line is written.
public protocol VaultLeaf: AnyObject {
    func fetchVault(accountID: String) async throws -> VaultSnapshot?
    /// Create the account's vault (sync setup, the first device).
    func createVault(_ format: KeyVaultFormat, accountID: String, device: String) async throws -> VaultSnapshot
    /// One CAS write under the CURRENT master's proof (decision 12).
    func updateVault(
        _ format: KeyVaultFormat, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device: String
    ) async throws -> VaultSnapshot
    /// THE WALK (decision 31): every row of the account still under the
    /// previous corpus key, re-encrypted under the current one — version-
    /// neutral; any device holding the new master may run it. Returns how
    /// many rows it replaced.
    func reencryptBelowRotationSeq(accountID: String, material: DeviceKeyMaterial) async throws -> Int
}

/// The library file — SQLCipher in the slot (phase 2). The record lives
/// inside it (`protection_record`, local-only), so reading or writing the
/// record needs the key it is under.
public protocol LibraryFileLeaf: AnyObject {
    /// Does `key` open the live library file? (Every road verifies itself.)
    func libraryOpens(with key: StoreKey) throws -> Bool
    /// The record inside the live file (nil: a library from before this
    /// change — the migration's subject).
    func readRecord(with key: StoreKey) throws -> ProtectionRecord?
    func writeRecord(_ record: ProtectionRecord, with key: StoreKey) throws
    /// Export-and-swap's first half: the live library re-encrypted into a
    /// staged file under `newKey` (`sqlcipher_export`), the live file untouched.
    func stageReencryption(from key: StoreKey, to newKey: StoreKey) throws
    /// A copy (by its catalog id) re-encrypted into the staged file under
    /// `newKey`, opened with `opener` — opening a copy, a landing.
    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws
    /// The fingerprint of the key the staged file is under (nil: none staged).
    func stagedFingerprint() throws -> String?
    /// The record written into the staged file before the swap (§3.4).
    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws
    /// THE SWAP — the staged file into the slot, atomically. `setAside` keeps
    /// the outgoing library as an older library (`Previous Libraries/`).
    func swapStaged(setAside: Bool) throws
    func discardStaged() throws
    /// A new library in the empty slot, under `key`, its record inside.
    func createLibrary(with key: StoreKey, record: ProtectionRecord) throws
    /// A plaintext export carrying its library ID (§3.7).
    func exportPlaintext(with key: StoreKey, to destination: String) throws
    /// Today's in-file `RotationMarker` (`sync_state.rekey_in_progress`).
    func readLegacyRotationMarker(with key: StoreKey) throws -> LegacyRotationMarker?
    func clearLegacyRotationMarker(with key: StoreKey) throws
}

/// Key files: THE live one beside the library, this Mac's own key files for
/// other libraries (`Backups/<library8>/<mac8>/`), and today's format-1/2
/// files beside the library (by their catalog ids).
public protocol KeyFileStoreLeaf: AnyObject {
    func readLiveKeyFile() throws -> KeyFileDocument?
    func writeLiveKeyFile(_ file: KeyFile) throws
    func readOwnKeyFile(libraryID: String, deviceID: String) throws -> KeyFile?
    func writeOwnKeyFile(_ file: KeyFile, deviceID: String) throws
    func legacyKeyFilesBesideLibrary() throws -> [(id: String, file: LegacyKeyFile)]
    func deleteLegacyKeyFile(id: String) throws
    /// Any key file the catalog lists, by its catalog id (a copy's serving
    /// file — the move reads another library's key through it).
    func readKeyFile(catalogID: String) throws -> KeyFileDocument?
    /// Move whatever sits in the live place aside, to `name` beside the
    /// library — never deleting it, never overwriting: false (nothing moved)
    /// when `name` is taken; true when moved, or when the live place is empty
    /// (VX-305 ladder round 1).
    func setAsideLiveKeyFile(as name: String) throws -> Bool
}

/// What this Mac remembers — one sealed non-secret item per library ID.
public protocol MemoryStoreLeaf: AnyObject {
    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>?
    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws
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
}

/// `LAEnvironment` (the Apple facts §5).
public protocol BiometryLeaf: AnyObject {
    func biometry() -> BiometryFacts
    /// The enrollment state hash — a hint, never a verdict (§3.10).
    func biometryStateHash() -> Data?
}

/// The log and Diagnostics. Nothing written here ever carries key material, a
/// hardware marker or the record's salt (design §3.2) — the executor speaks
/// in act names, step names and eight-character fingerprints.
public protocol DiagnosticsLeaf: AnyObject {
    func log(_ line: String)
    func report(_ entry: ProtectionDiagnostic)
}

/// What Diagnostics lists — typed, so no entry can carry a secret.
public enum ProtectionDiagnostic: Equatable, Sendable {
    /// A library file older than what this Mac remembers (a library file
    /// replayed alone, §3.6) — re-encrypted under the current key, the
    /// memory's facts kept (VX-305 U4). Eight-character prefixes only.
    case olderLibraryFileRekeyed(older8: String, current8: String)
    /// A plan on disk this Mac's section doesn't name, or one failing its
    /// seal — ignored (§3.6).
    case planIgnored(PlanIgnoredReason)
    /// An anchor the entry into Castle couldn't open — kept beside the
    /// history (§3.4): its day and the outgoing key's fingerprint.
    case anchorKeptUnopened(madeAt: Date, outgoing8: String)
    /// An act rolled back before its commit point, or finished from the
    /// record after it, with no plan to resume (§3.6).
    case actRolledBack(ProtectionAct)
    case actFinishedFromRecord(ProtectionAct)
    /// The old shared key stayed at Use Castle's last step: a vault it can
    /// read now names it (the last-step race, §3.5 point 4).
    case oldSharedKeyStayed(account: String)
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
    public var legacyItems: any LegacyItemsLeaf
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
        custody: any CustodyLeaf, legacyItems: any LegacyItemsLeaf, syncKeys: any SyncKeysLeaf,
        apple: any AppleKeysLeaf, vault: any VaultLeaf, library: any LibraryFileLeaf,
        keyFiles: any KeyFileStoreLeaf, memory: any MemoryStoreLeaf, plans: any PlanStoreLeaf,
        backups: any BackupsLeaf, clock: any ClockLeaf, ids: any IDsLeaf, biometry: any BiometryLeaf,
        diagnostics: any DiagnosticsLeaf
    ) {
        self.custody = custody
        self.legacyItems = legacyItems
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
