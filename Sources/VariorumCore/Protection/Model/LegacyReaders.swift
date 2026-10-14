import CryptoKit
import Foundation
import GRDB

// VX-305 U1 — THE LEGACY READERS (design §3.7, §3.13, §3.15). Read-only, and
// they OUTLIVE the release switch: the migration runs after the switch ships,
// at each store's next unlock, and copies made before this change exist
// forever. So each of today's formats, names and rules that the new system
// must still READ is restated here, in the core, independent of the app code
// the switch deletes:
//   1. key files in FORMATS 1 AND 2 (`StoreKeyEnvelope`), read as the
//      pre-13x design says — and `KeyFileDocument`, which tells a format-3 file
//      from an older one;
//   2. TODAY'S MODE RULE as one pure function (`LegacyModeReader` —
//      `Posture.derive`'s inputs and corner 45's test, App/Variorum/Shared/
//      StoreProtection.swift:85-119), which decides nothing else and writes
//      nothing;
//   3. the reads of TODAY'S ITEMS — the per-library-ID custody items, the 13p
//      escrow item, the per-store sync custody and the old shared Apple key —
//      their names and their values (`LegacyItems`);
//   4. the in-file `RotationMarker`'s read and its CLEARING CHECK
//      (`LegacyRotationMarker`).
// Nothing here writes, mints or deletes anything.

// MARK: - 1. Key files of every format

/// A key file as found on disk: format 3, or an older one.
public enum KeyFileDocument: Equatable, Sendable {
    case format3(KeyFile)
    case legacy(LegacyKeyFile)

    /// Decode any key file. A newer format refuses (never guessed); bytes
    /// that are not a key file throw `unreadable`.
    public static func decode(_ data: Data) throws -> KeyFileDocument {
        struct Probe: Decodable { var formatVersion: Int }
        guard let probe = try? JSONDecoder().decode(Probe.self, from: data) else {
            throw StoreKeyEnvelopeError.unreadable("not a key file")
        }
        switch probe.formatVersion {
        case KeyFile.currentFormatVersion:
            do {
                return .format3(try ProtectionCoding.decoder().decode(KeyFile.self, from: data))
            } catch {
                throw StoreKeyEnvelopeError.unreadable(String(describing: error))
            }
        case StoreKeyEnvelope.formatVersion1, StoreKeyEnvelope.currentFormatVersion:
            do {
                return .legacy(LegacyKeyFile(envelope: try JSONDecoder().decode(StoreKeyEnvelope.self, from: data)))
            } catch {
                throw StoreKeyEnvelopeError.unreadable(String(describing: error))
            }
        case let newer where newer > KeyFile.currentFormatVersion:
            throw KeyFileError.newerFormat(newer)
        default:
            throw StoreKeyEnvelopeError.unreadable("unknown key file format \(probe.formatVersion)")
        }
    }

    public var formatVersion: Int {
        switch self {
        case .format3(let file): return file.formatVersion
        case .legacy(let file): return file.formatVersion
        }
    }

    public var libraryID: String {
        switch self {
        case .format3(let file): return file.libraryID
        case .legacy(let file): return file.libraryID
        }
    }

    /// The current key's fingerprint (nil on a wraps-less format-1 stub).
    public var fingerprint: String? {
        switch self {
        case .format3(let file): return file.fingerprint
        case .legacy(let file): return file.fingerprint
        }
    }

    /// Every fingerprint the file leads to without a secret (§3.7, §3.13 step
    /// 3's seed): format 3's current key, history and anchors; an older file's
    /// one key.
    public var heldFingerprints: [String] {
        switch self {
        case .format3(let file): return file.heldFingerprints
        case .legacy(let file): return [file.fingerprint].compactMap { $0 }
        }
    }
}

/// A key file in format 1 or 2, read as the pre-13x design §3.5 says: format 1
/// carries the passphrase and words wraps only ("no master-wrapped copy of the
/// library key, no iCloud copy, unknown descriptor"); format 2 adds the master
/// wrap, the Apple wrap — under the OLD SHARED key (`<scope>-apple-key`, the
/// one per Apple account every library shared) — and the vault facts last
/// reconciled.
public struct LegacyKeyFile: Equatable, Sendable {
    public let envelope: StoreKeyEnvelope

    public init(envelope: StoreKeyEnvelope) { self.envelope = envelope }

    public var formatVersion: Int { envelope.formatVersion }
    public var libraryID: String { envelope.storeID }
    public var fingerprint: String? { envelope.keyFingerprint }
    /// The old shared Apple key's id the Apple wrap names (format 2).
    public var sharedAppleKeyID: String? { envelope.apple == nil ? nil : envelope.appleKeyID }

    /// The roads it carries — its Apple wrap is the OLD SHARED key's.
    public var roads: Set<KeyFileRoad> {
        var roads: Set<KeyFileRoad> = []
        if envelope.passphrase != nil { roads.insert(.passphrase) }
        if envelope.recovery != nil { roads.insert(.words) }
        if envelope.master != nil { roads.insert(.master) }
        if envelope.apple != nil { roads.insert(.sharedApple) }
        return roads
    }

    /// What it was last reconciled against (format 2; nil on format 1).
    public var vaultFacts: VaultFacts? {
        guard envelope.vaultKDF != nil || envelope.vaultCorpusKeyID != nil
            || envelope.vaultRecoveryWrapDigest != nil else { return nil }
        return VaultFacts(
            kdf: envelope.vaultKDF, corpusKeyID: envelope.vaultCorpusKeyID,
            recoveryWrapDigest: envelope.vaultRecoveryWrapDigest)
    }

    /// The migration's attribution of the key it holds (§3.13 step 3): an
    /// Apple wrap marks a Standard key, none marks a Castle key. (A key with no
    /// readable key file at all is unknown and counts as Castle's —
    /// `FamilyTree.seeding`'s default.)
    public var attributedKind: ProtectionMode { envelope.apple != nil ? .standard : .castle }

    private func verified(_ key: StoreKey, _ road: KeyFileRoad) throws -> StoreKey {
        if let fingerprint, StoreKeyEnvelope.fingerprint(of: key) != fingerprint {
            throw KeyFileError.wrapsAnotherKey(road)
        }
        return key
    }

    public func open(passphrase: String, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> StoreKey {
        try verified(envelope.unwrapKey(passphrase: passphrase, floor: floor), .passphrase)
    }

    public func open(words: [String]) throws -> StoreKey {
        try verified(envelope.unwrapKey(recoveryWords: words), .words)
    }

    public func open(master: SymmetricKey) throws -> StoreKey {
        try verified(envelope.unwrapKey(master: master), .master)
    }

    /// Through the old shared Apple key, while it exists (§3.5 point 1: the
    /// route finder counts it as a road; this build only reads it).
    public func open(sharedApple: AppleKeyMaterial) throws -> StoreKey {
        if let expected = envelope.appleKeyID, expected != sharedApple.id {
            throw KeyFileError.appleKeyMismatch(expected: expected, offered: sharedApple.id)
        }
        return try verified(envelope.unwrapKey(apple: sharedApple.key), .sharedApple)
    }
}

// MARK: - 2. Today's mode rule

/// Today's stored 13p-era at-open mode (the app's `StoreAtOpenMode`).
public enum LegacyAtOpenMode: String, Codable, Sendable, CaseIterable {
    case auto
    case biometric
    case passphrase

    public var isDemanded: Bool { self != .auto }
}

/// Where the raw library key sits today, by presence (the app's
/// `RawKeyCustody`).
public enum LegacyRawKeyCustody: Sendable, CaseIterable {
    case silent
    case gatedOrNone
    case unknown
}

/// The two key-file facts today's rule reads.
public struct LegacyKeyFileFacts: Equatable, Sendable {
    public var hasAppleWrap: Bool
    public var hasPassphraseWrap: Bool

    public init(hasAppleWrap: Bool, hasPassphraseWrap: Bool) {
        self.hasAppleWrap = hasAppleWrap
        self.hasPassphraseWrap = hasPassphraseWrap
    }

    public init(_ envelope: StoreKeyEnvelope) {
        self.init(hasAppleWrap: envelope.apple != nil, hasPassphraseWrap: envelope.passphrase != nil)
    }
}

/// `Posture.derive`'s inputs, exactly.
public struct LegacyModeInputs: Equatable, Sendable {
    public var legacyMode: LegacyAtOpenMode?
    public var vaultHasAppleHeldCopy: Bool?
    public var keyFile: LegacyKeyFileFacts?
    public var rawKeyCustody: LegacyRawKeyCustody
    public var enrolled: Bool

    public init(
        legacyMode: LegacyAtOpenMode? = nil, vaultHasAppleHeldCopy: Bool? = nil,
        keyFile: LegacyKeyFileFacts?, rawKeyCustody: LegacyRawKeyCustody = .unknown, enrolled: Bool
    ) {
        self.legacyMode = legacyMode
        self.vaultHasAppleHeldCopy = vaultHasAppleHeldCopy
        self.keyFile = keyFile
        self.rawKeyCustody = rawKeyCustody
        self.enrolled = enrolled
    }
}

/// Today's reading (the app's `PostureReading`).
public enum LegacyModeReading: Equatable, Sendable {
    case determined(ProtectionMode)
    case indeterminate(shape: ProtectionMode)

    public var acting: ProtectionMode {
        switch self {
        case .determined(let mode): return mode
        case .indeterminate(let shape): return shape
        }
    }
}

public struct LegacyModeVerdict: Equatable, Sendable {
    /// Which of today's arms answered.
    public enum Source: Equatable, Sendable {
        case vault
        case enrolledShape
        case legacyMode
        case keyFile
        case freshLibrary
    }

    /// What today's rule says — byte for byte `Posture.derive`.
    public var reading: LegacyModeReading
    public var source: Source
    /// CORNER 45's AMBIGUOUS CASE: a local-only library with a passphrase, no
    /// Apple copy and the raw key in the silent item — today it reads Standard
    /// (Standard-waiting), but a library that was in Castle and whose custody
    /// move half-happened (VX-202's victims) reads the same. The migration
    /// records Castle, not yet confirmed, with a one-time notice (§3.13 step 2).
    public var isCorner45Ambiguous: Bool

    /// §3.13 step 2's recording, from today's reading: the vault's word,
    /// confirmed; an enrolled library without it, its custody shape, NOT
    /// confirmed; corner 45's ambiguous case, Castle, NOT confirmed; every
    /// other local reading as today reads it, confirmed. (An exposed-era
    /// library with no passphrase or words is Standard and never defaulted to
    /// Castle.)
    public var migrationRecord: (mode: ProtectionMode, confirmed: Bool) {
        if isCorner45Ambiguous { return (.castle, false) }
        switch reading {
        case .determined(let mode): return (mode, true)
        case .indeterminate(let shape): return (shape, false)
        }
    }

}

/// **Today's mode rule** — `Posture.derive` (App/Variorum/Shared/
/// StoreProtection.swift), restated as one pure, read-only function of its
/// own inputs. The migration calls it once per store; opening a copy with no
/// record calls it for as long as such copies exist (§3.7, §3.15). It decides
/// nothing else and writes nothing.
public enum LegacyModeReader {
    public static func read(_ inputs: LegacyModeInputs) -> LegacyModeVerdict {
        // 1. The vault's word, when in hand.
        if let vault = inputs.vaultHasAppleHeldCopy {
            return LegacyModeVerdict(
                reading: .determined(vault ? .standard : .castle), source: .vault, isCorner45Ambiguous: false)
        }
        // 2. An enrolled library whose vault hasn't answered: indeterminate,
        //    acting as its custody shape.
        if inputs.enrolled {
            return LegacyModeVerdict(
                reading: .indeterminate(shape: shapeReading(inputs.keyFile, inputs.rawKeyCustody)),
                source: .enrolledShape, isCorner45Ambiguous: false)
        }
        // 3. The 13p-era stored mode.
        if let legacy = inputs.legacyMode {
            return LegacyModeVerdict(
                reading: .determined(legacy.isDemanded ? .castle : .standard), source: .legacyMode,
                isCorner45Ambiguous: false)
        }
        // 4–5. The key file's rule, corner 45 included; no key file ⇒ fresh.
        guard let keyFile = inputs.keyFile else {
            return LegacyModeVerdict(reading: .determined(.standard), source: .freshLibrary, isCorner45Ambiguous: false)
        }
        let ambiguous = !keyFile.hasAppleWrap && keyFile.hasPassphraseWrap && inputs.rawKeyCustody == .silent
        return LegacyModeVerdict(
            reading: .determined(localReading(keyFile, inputs.rawKeyCustody)), source: .keyFile,
            isCorner45Ambiguous: ambiguous)
    }

    /// Arms 4–5: the local-only rule, corner 45 included.
    static func localReading(_ keyFile: LegacyKeyFileFacts?, _ custody: LegacyRawKeyCustody) -> ProtectionMode {
        guard let keyFile else { return .standard }
        if keyFile.hasAppleWrap { return .standard }
        guard keyFile.hasPassphraseWrap else { return .standard }
        switch custody {
        case .silent: return .standard
        case .gatedOrNone, .unknown: return .castle
        }
    }

    /// Arm 2's carried posture.
    static func shapeReading(_ keyFile: LegacyKeyFileFacts?, _ custody: LegacyRawKeyCustody) -> ProtectionMode {
        switch custody {
        case .silent: return .standard
        case .gatedOrNone: return .castle
        case .unknown: return localReading(keyFile, .unknown)
        }
    }
}

// MARK: - 3. Today's items — their names and their values

/// Today's Keychain items, as the fold reads them (§3.13 step 6) — names
/// restated from the code the switch deletes (cited per name), values decoded
/// read-only. Reading only: the migration removes them by its own repairs.
public enum LegacyItems {
    // The per-library-ID store-key family (core's `StoreKeyKeychain` —
    // Sources/VariorumCore/Persistence/StoreKey.swift, and the app's
    // `StoreKeyGuardKeychain`, App/Variorum/Shared/StoreKeyGuard.swift).
    public static let storeKeyService = "io.lduarte.Variorum.store-key"
    /// The silent item, per library ID — data-protection.
    public static func boundAccount(scope: String, libraryID: String) -> String { "\(scope)-\(libraryID)-bound" }
    /// The Touch ID item, per library ID.
    public static func gatedAccount(scope: String, libraryID: String) -> String { "\(scope)-\(libraryID)-biometric" }
    /// The #82-era silent item (data-protection; no library ID).
    public static func legacyBoundAccount(scope: String) -> String { "\(scope)-bound" }
    /// The 13p-era silent item (FILE-BASED keychain; no library ID).
    public static func legacyFileBasedAccount(scope: String) -> String { scope }
    /// The 13p-era Touch ID item (no library ID).
    public static func legacyGatedAccount(scope: String) -> String { "\(scope)-biometric" }

    // The 13p escrow item: a RAW library key in iCloud Keychain, named by the
    // library ID alone (StoreKeyGuard.swift:223 — synchronizable).
    public static let escrowService = "io.lduarte.Variorum.store-key-escrow"
    public static func escrowAccount(libraryID: String) -> String { libraryID }

    // The per-store sync custody (App/Variorum/Shared/EncryptionKeychain.swift
    // `SyncCustodyScope`) and the 14b fixed accounts before it.
    public static let syncCustodyService = "io.lduarte.Variorum.e2ee-keys"
    public static func syncBoundAccount(scope: String, libraryID: String) -> String { "\(scope)-\(libraryID)-sync" }
    public static func syncGatedAccount(scope: String, libraryID: String) -> String { "\(scope)-\(libraryID)-sync-biometric" }
    public static let fixedSyncAccounts = ["device-keys", "device-keys-biometric"]

    // The old shared Apple key: `ProtectionNames.appleKeyService` +
    // `ProtectionNames.oldSharedAppleKeyAccount(scope:)`.

    /// A store-key item's value — the raw 32 bytes.
    public static func storeKey(fromItemData data: Data) -> StoreKey? { StoreKey(data: data) }

    /// The sync custody record (`SyncCustodyRecord` — `{deviceID, material}`),
    /// or the 14b blob (the bare material, no identity).
    public struct SyncCustodyValue: Equatable, Sendable {
        /// The device identity the migration carries over (§3.13 step 3);
        /// nil on a 14b blob, which never had one.
        public var deviceID: String?
        public var material: DeviceKeyMaterial?
    }

    public static func syncCustody(fromItemData data: Data) -> SyncCustodyValue? {
        struct Record: Decodable {
            var deviceID: String
            var material: DeviceKeyMaterial?
        }
        if let record = try? JSONDecoder().decode(Record.self, from: data) {
            return SyncCustodyValue(deviceID: record.deviceID.isEmpty ? nil : record.deviceID, material: record.material)
        }
        if let bare = try? JSONDecoder().decode(DeviceKeyMaterial.self, from: data) {
            return SyncCustodyValue(deviceID: nil, material: bare)
        }
        return nil
    }

    /// The old shared Apple key's value (`AppleKey` — `{id, key}`).
    public static func appleKey(fromItemData data: Data) -> AppleKeyMaterial? {
        struct Value: Decodable {
            var id: String
            var key: Data
        }
        guard let value = try? JSONDecoder().decode(Value.self, from: data), value.key.count == 32 else { return nil }
        return AppleKeyMaterial(id: value.id, key: SymmetricKey(data: value.key))
    }
}

// MARK: - 4. The old marker: its read and its clearing check

/// The in-file `RotationMarker` (Sources/VariorumCore/Sync/CorpusRotation.swift),
/// restated for reading only — it lives inside the library file
/// (`sync_state.rekey_in_progress`), and copies carrying it exist forever
/// (§3.15). The JSON shape and the undecodable rule are today's exactly
/// (pinned against the live type).
public struct LegacyRotationMarker: Equatable, Sendable {
    public enum Step: String, Codable, Sendable, CaseIterable {
        case vaultWrite
        case reencrypt
        case rekeyLibrary
        case custody
        case snapshot
        case offer
    }

    public var step: Step
    public var entersCastle: Bool
    public var oldKeyFingerprint: String?
    public var newKeyFingerprint: String?
    public var newCorpusKeyID: String?
    public var startedAt: String
    public var follow: Bool?

    /// SyncSpec §3's local-only key.
    public static let syncStateKey = "rekey_in_progress"

    /// A stored value, decoded; a value this reader can't decode (a 14c-era
    /// wall-clock stamp) still counts as SET and reads as a `.vaultWrite`
    /// marker — today's most conservative reading.
    public static func decode(value: String) -> LegacyRotationMarker {
        struct Wire: Decodable {
            var step: Step
            var entersCastle: Bool
            var oldKeyFingerprint: String?
            var newKeyFingerprint: String?
            var newCorpusKeyID: String?
            var startedAt: String
            var follow: Bool?
        }
        if let wire = try? JSONDecoder().decode(Wire.self, from: Data(value.utf8)) {
            return LegacyRotationMarker(
                step: wire.step, entersCastle: wire.entersCastle, oldKeyFingerprint: wire.oldKeyFingerprint,
                newKeyFingerprint: wire.newKeyFingerprint, newCorpusKeyID: wire.newCorpusKeyID,
                startedAt: wire.startedAt, follow: wire.follow)
        }
        return LegacyRotationMarker(step: .vaultWrite, entersCastle: false, startedAt: value)
    }

    /// The marker inside an open library, if one is set.
    public static func read(_ db: Database) throws -> LegacyRotationMarker? {
        guard try db.tableExists("sync_state"),
              let value = try String.fetchOne(
                db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [syncStateKey])
        else { return nil }
        return decode(value: value)
    }

    /// What the disk says about the old act (§3.13 step 1).
    public struct Evidence: Equatable, Sendable {
        /// The fingerprint of the key the library opened under.
        public var opensUnder: String
        /// Whether the act's NEW key file landed beside the library (today's
        /// `variorum-keys-<newKeyFingerprint>.json`).
        public var newKeyFileLanded: Bool

        public init(opensUnder: String, newKeyFileLanded: Bool) {
            self.opensUnder = opensUnder
            self.newKeyFileLanded = newKeyFileLanded
        }
    }

    public enum Resolution: Equatable, Sendable {
        /// The library still opens under its old key and the new key never
        /// landed: the act never happened.
        case neverHappened
        /// Otherwise its commit happened: the migration carries on from the
        /// files as they are, with the mode not yet confirmed unless the vault
        /// is read, and no custody repair until it is.
        case commitHappened

        /// Either way the marker is cleared (§3.13 step 1).
        public var clearsTheMarker: Bool { true }
    }

    /// **THE CLEARING CHECK** (§3.13 step 1, §3.15): "if the library still
    /// opens under its old key and the new key never landed, the act never
    /// happened; otherwise its commit happened."
    ///
    /// A marker that names no fingerprints (`vaultWrite` / `reencrypt`, or a
    /// 14c-era value) never minted a new LIBRARY key — so the library opens
    /// under its old key and no new key exists by construction: the library's
    /// act never happened (PROVISIONAL reading, the U1 record). Such markers
    /// are written only on synced roads, where §3.13 step 2 takes the vault's
    /// word or records the mode not yet confirmed, and a rotation still
    /// standing on the server is finished by the new engine.
    public func resolve(_ evidence: Evidence) -> Resolution {
        guard let old = oldKeyFingerprint else { return .neverHappened }
        let opensUnderOld = evidence.opensUnder == old
        let newLanded = evidence.newKeyFileLanded
            || (newKeyFingerprint.map { $0 == evidence.opensUnder } ?? false)
        return opensUnderOld && !newLanded ? .neverHappened : .commitHappened
    }
}
