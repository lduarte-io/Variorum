import Foundation

// VX-305 U2 — THE OPEN RULE (design §3.7, VX-209): what opening a copy does,
// decided by `assess` from the copy's non-secret facts and the library this
// Mac remembers with its ID.
//   - IS IT OURS? The family tree decides — its two homes unioned, seeded at
//     the migration — never the history: after a leave the new key's history
//     is empty, and this library's own Castle-era copies are still its own. A
//     copy whose key isn't in the tree is flagged "made on another Mac, or not
//     by you".
//   - A copy of a library this Mac remembers is re-encrypted under that
//     library's CURRENT key, straight from the staged copy into place, and
//     takes the library's current facts — opening a copy NEVER LOWERS the mode
//     (rule 4). A Castle-era copy opened into a Standard library opens with the
//     passphrase or the words through the anchor, and the confirm says its
//     writing will then open through the Apple account.
//   - A Castle copy not in the tree, of a library this Mac remembers in
//     Standard, raises the library to Castle through Use Castle's own steps.
//   - A DIFFERENT library keeps its own mode and lands under a fresh key with
//     no history: one secret unlocks the pair, the other is typed or made new;
//     a Standard pair through an Apple key this Mac can read lands with
//     nothing typed, under this Mac's own Apple key.
//   - A copy with no record (made before this change) has its mode worked out
//     once with today's rules — an exposed-era Standard copy with no
//     passphrase or words is never defaulted to Castle.
//   - A plaintext export: the same library is encrypted under the current key
//     and mode; otherwise it becomes a new library in Standard.
//   - Any copy's act in flight is cleared when it's opened.

/// The library this Mac remembers with the copy's ID (the slot's, or another
/// it knows).
public struct OpenTarget: Equatable, Sendable {
    public var libraryID: String
    public var mode: ProtectionMode
    public var account: String?
    /// The family tree at open.
    public var familyTree: FamilyTree
    /// The live key file's current key and its history (no anchor) — what a
    /// history-based "is it ours?" would read (the guard's off-reading).
    public var liveHistoryFingerprints: [String]

    public init(
        libraryID: String, mode: ProtectionMode, account: String?, familyTree: FamilyTree,
        liveHistoryFingerprints: [String]
    ) {
        self.libraryID = libraryID
        self.mode = mode
        self.account = account
        self.familyTree = familyTree
        self.liveHistoryFingerprints = liveHistoryFingerprints
    }
}

/// A picked copy, keylessly.
public struct OpenFacts: Equatable, Sendable {
    /// Its library ID — its key file's (or a plaintext export's own).
    public var libraryID: String?
    /// The key it is under (nil for a plaintext export).
    public var keyFingerprint: String?
    /// Its record's mode, when it carries one (read after its pair opens).
    public var recordMode: ProtectionMode?
    /// Its key file's two facts today's rule reads — for a copy with no
    /// record.
    public var keyFileFacts: LegacyKeyFileFacts?
    public var isPlaintextExport: Bool
    /// The account its rows were stamped by.
    public var rowsAccount: String?
    /// Its record names an account — a synced pair (it lands held).
    public var synced: Bool
    /// A Standard pair that opens through an Apple key this Mac can read.
    public var opensThroughReadableAppleKey: Bool
    /// The library this Mac remembers with the copy's ID, if any.
    public var target: OpenTarget?

    public init(
        libraryID: String?, keyFingerprint: String?, recordMode: ProtectionMode? = nil,
        keyFileFacts: LegacyKeyFileFacts? = nil, isPlaintextExport: Bool = false, rowsAccount: String? = nil,
        synced: Bool = false, opensThroughReadableAppleKey: Bool = false, target: OpenTarget?
    ) {
        self.libraryID = libraryID
        self.keyFingerprint = keyFingerprint
        self.recordMode = recordMode
        self.keyFileFacts = keyFileFacts
        self.isPlaintextExport = isPlaintextExport
        self.rowsAccount = rowsAccount
        self.synced = synced
        self.opensThroughReadableAppleKey = opensThroughReadableAppleKey
        self.target = target
    }

    /// The copy's own mode: its record's, else today's rule read once (§3.7,
    /// §3.15) — custody unknown (a copy is a file), never enrolled.
    public var copyMode: ProtectionMode {
        if let recordMode { return recordMode }
        return LegacyModeReader.read(
            LegacyModeInputs(keyFile: keyFileFacts, rawKeyCustody: .unknown, enrolled: false)).reading.acting
    }
}

/// One secret unlocks a different library's pair; the other is typed or made
/// new — or, for a Standard pair through a readable Apple key, nothing.
public enum LandingSecrets: Equatable, Sendable {
    case oneSecretOtherTypedOrMadeNew
    case noneThroughAppleKey
}

public struct Landing: Equatable, Sendable {
    /// The pair's own mode (a landing never changes it).
    public var mode: ProtectionMode
    /// A fresh key, an empty history (her round-2 ruling). The guard's
    /// off-reading keeps the key it came with — today's behaviour.
    public var freshKey: Bool
    public var secrets: LandingSecrets
    /// Standard: this Mac's own Apple key for it.
    public var mintsOwnAppleKey: Bool
    /// A synced pair lands held (the restore hold), and a secret made new at
    /// its landing becomes the account's at Resume Sync.
    public var landsHeld: Bool
    /// The library that stood here goes to the older libraries.
    public var replacedLibraryGoesAside: Bool
}

public struct OwnLineOpen: Equatable, Sendable {
    /// The library's CURRENT mode — never the copy's.
    public var takesMode: ProtectionMode
    /// "Made on another Mac, or not by you" — its key isn't in the tree.
    public var flaggedForeign: Bool
    /// A Castle-era copy into a Standard library: it opens through the anchor
    /// with the passphrase or the words, and the confirm says its writing will
    /// then open through the Apple account.
    public var castleEraIntoStandard: Bool
    /// Its rows belong to another account: the Move road runs inside the
    /// open's plan.
    public var runsMoveRoad: Bool
    /// Re-encrypted under the library's current key (never the copy's).
    public var reencryptsUnderCurrentKey: Bool
}

public enum OpenVerdict: Equatable, Sendable {
    case ownLine(OwnLineOpen)
    /// A Castle copy not in the tree, of a library remembered in Standard:
    /// Use Castle's own steps — both secrets typed, a fresh key — or cancel.
    case raisesToCastle
    case differentLibrary(Landing)
    /// The same library: encrypted under the current key and mode; another:
    /// a new library in Standard.
    case plaintextExport(sameLibrary: Bool, mode: ProtectionMode)

    /// Every copy's act in flight is cleared when it's opened (§3.6, §3.7).
    public var clearsActInFlight: Bool { true }
}

public enum OpenRule {
    public static func verdict(_ facts: OpenFacts, guards: ProtectionGuards = .all) -> OpenVerdict {
        if facts.isPlaintextExport {
            if let target = facts.target, target.libraryID == facts.libraryID {
                return .plaintextExport(sameLibrary: true, mode: target.mode)
            }
            return .plaintextExport(sameLibrary: false, mode: .standard)
        }
        let copyMode = facts.copyMode
        guard let target = facts.target, target.libraryID == facts.libraryID, let fingerprint = facts.keyFingerprint else {
            return .differentLibrary(Landing(
                mode: copyMode, freshKey: guards.rekeyAtEveryCrossingOn,
                secrets: copyMode == .standard && facts.opensThroughReadableAppleKey
                    ? .noneThroughAppleKey : .oneSecretOtherTypedOrMadeNew,
                mintsOwnAppleKey: copyMode == .standard, landsHeld: facts.synced, replacedLibraryGoesAside: true))
        }
        let ours = guards.ownLineByFamilyTreeOn
            ? target.familyTree.contains(fingerprint)
            : target.liveHistoryFingerprints.contains(fingerprint)
        if !ours, copyMode == .castle, target.mode == .standard { return .raisesToCastle }
        return .ownLine(OwnLineOpen(
            takesMode: guards.neverLowerOnOpenOn ? target.mode : copyMode,
            flaggedForeign: !ours,
            castleEraIntoStandard: ours && copyMode == .castle && target.mode == .standard,
            runsMoveRoad: facts.rowsAccount != nil && facts.rowsAccount != target.account,
            reencryptsUnderCurrentKey: true))
    }
}
