import CryptoKit
import Dependencies
import Foundation

// Phase 13p, Batch 1 — the store key and its open-time custody seam: one
// random 256-bit key per store. VX-329 U1: the protection core
// (`Sources/VariorumCore/Protection/`) holds every key; this file keeps the
// key type, its redaction, the generic custody seam `openStore` reads, and the
// presence classifier.

/// The whole-store SQLCipher key: 32 random bytes (AES-256). Deliberately
/// NOT the sync master key (R13p-4): a local-only signed-out user has a
/// store key with no account, and sync enrollment composes beside it.
public struct StoreKey: Equatable, Sendable {
    /// Exactly 32 bytes.
    public let data: Data

    public init?(data: Data) {
        guard data.count == 32 else { return nil }
        self.data = data
    }

    public init?(hexEncoded: String) {
        guard hexEncoded.count == 64 else { return nil }
        var bytes = Data(capacity: 32)
        var index = hexEncoded.startIndex
        while index < hexEncoded.endIndex {
            let next = hexEncoded.index(index, offsetBy: 2)
            guard let byte = UInt8(hexEncoded[index..<next], radix: 16) else { return nil }
            bytes.append(byte)
            index = next
        }
        self.init(data: bytes)
    }

    /// 64 lowercase hex characters — the `x'…'` pragma literal's payload.
    public var hexEncoded: String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    /// A fresh random 256-bit key (CryptoKit's CSPRNG — the same mint the
    /// 14b vault keys use).
    public static func mint() -> StoreKey {
        let symmetric = SymmetricKey(size: .bits256)
        let bytes = symmetric.withUnsafeBytes { Data($0) }
        guard let key = StoreKey(data: bytes) else {
            fatalError("SymmetricKey(.bits256) yielded a non-32-byte key")
        }
        return key
    }
}

extension StoreKey: CustomStringConvertible, CustomDebugStringConvertible {
    /// Redacted on purpose: a store key must never ride into a log line by
    /// way of an interpolation.
    public var description: String { "StoreKey(256-bit, redacted)" }
    public var debugDescription: String { description }

    /// P15 (pre-13u Act 9, 17a): exactly two statements embed this key as
    /// a literal — the raw-key `PRAGMA key` (which SQLite cannot bind a
    /// parameter into) and the migration's `ATTACH … KEY` — and GRDB's
    /// `DatabaseError.description` appends the executed SQL verbatim, so
    /// an error thrown BY either statement carried the full hex onto the
    /// store-failure screen (selectable text) and into the backup log's
    /// UserDefaults record. Both sites catch-and-sanitize through this:
    /// the error's text with every occurrence of the hex scrubbed.
    public func redactedDescription(of error: any Error) -> String {
        String(describing: error)
            .replacingOccurrences(of: hexEncoded, with: "<store key redacted>")
    }
}

/// P15: the sanitized replacement thrown where a key-bearing statement
/// failed. Its `description` AND `localizedDescription` carry the scrubbed
/// text, so every downstream channel (`String(describing:)` into
/// `StoreOpenError.reason`, `error.localizedDescription` into the backup
/// log) reads the same key-free sentence.
public struct RedactedKeyedStatementError: Error, CustomStringConvertible, LocalizedError, Sendable {
    public let description: String
    public var errorDescription: String? { description }
    public init(description: String) { self.description = description }
}

/// Persistence seam for the store key handed to `AppDatabase.openStore`. VX-329 U1: the device-Keychain custody that
/// lived here (today's per-store-id `StoreKeyKeychain` family — custody named by library ID, rule 26's retired road)
/// was deleted with today's road; the app opens every library with the key the protection core already holds
/// (`.inMemory(initial:)`), and tests inject in-memory doubles that NEVER touch the real Keychain (the default
/// test-context custody below guarantees it).
public struct StoreKeyCustody: Sendable {
    /// The held key, or nil when none is held (the open path refuses rather than guesses).
    public var load: @Sendable () -> StoreKey?
    /// Persist the key. `false` means custody could NOT keep it — the open
    /// path must then refuse to create an encrypted store (a store whose
    /// key cannot be kept would be unopenable at the next launch).
    public var save: @Sendable (StoreKey) -> Bool

    public init(
        load: @escaping @Sendable () -> StoreKey?,
        save: @escaping @Sendable (StoreKey) -> Bool
    ) {
        self.load = load
        self.save = save
    }
}

extension StoreKeyCustody {
    /// A scriptable in-memory custody for tests and drills — and the app's one road: the protection core's key in
    /// hand.
    public static func inMemory(initial: StoreKey? = nil) -> StoreKeyCustody {
        let box = InMemoryStoreKeyBox(initial: initial)
        return StoreKeyCustody(
            load: { box.value },
            save: { box.value = $0; return true })
    }

    /// The test-context default (`testValue`): ONE stable random key per
    /// process, never the Keychain. Stable-per-process on purpose — tests
    /// open, back up, copy, and REOPEN scratch stores, often concurrently,
    /// and a per-call key would make one test's store unopenable the moment
    /// another test's open ran; the Keychain is exactly what unsigned CLI
    /// test runners cannot (and must never) touch. `save` accepts and
    /// discards: `load` never returns nil here, so the mint road never runs
    /// under the default test custody — a test exercising mint/save
    /// semantics injects `.inMemory()` explicitly.
    static let processEphemeral: StoreKeyCustody = {
        let key = StoreKey.mint()
        return StoreKeyCustody(load: { key }, save: { _ in true })
    }()
}

nonisolated private final class InMemoryStoreKeyBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: StoreKey?
    init(initial: StoreKey?) { stored = initial }
    var value: StoreKey? {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
}

extension StoreKeyCustody: DependencyKey {
    /// The package's own `liveValue` open (the headless-misuse guard — the app never reaches it): VX-329 U1, no
    /// custody exists outside the protection core, so this holds nothing and keeps nothing — an encrypted store
    /// refuses typed, and a fresh one is never minted here.
    public static let liveValue = StoreKeyCustody(load: { nil }, save: { _ in false })
    /// See `processEphemeral` — never the Keychain in a test process.
    public static let testValue = StoreKeyCustody.processEphemeral
}

extension DependencyValues {
    public var storeKeyCustody: StoreKeyCustody {
        get { self[StoreKeyCustody.self] }
        set { self[StoreKeyCustody.self] = newValue }
    }
}


/// What sits at a store URL, read from the file's first bytes — the
/// migration trigger and the open path's routing fact.
public enum StoreFilePresence: Equatable, Sendable {
    /// No file (or an empty one): a fresh store will be created here.
    case absent
    /// The bytes lead with SQLite's plaintext magic — a pre-13p store, the
    /// one-time migration's subject.
    case plaintext
    /// Real bytes that are not the plaintext magic — an encrypted store,
    /// something that is not a database at all, OR a present file that
    /// refused to open/read (pre-13u Act 9, 17a P12/P13): the keyed open
    /// decides, loudly.
    case encryptedOrUnknown

    /// `SQLite format 3\0` — public so drills and verification tooling can
    /// assert against the same sixteen bytes this classifier reads.
    public static let plaintextMagic = Data([
        0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66,
        0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00,
    ])

    /// Pre-13u Act 9 (17a P12/P13): a PRESENT file whose open or read
    /// fails (EACCES after an oddly-permissioned restore, fd exhaustion,
    /// EIO, an unsatisfied iOS protection class) used to answer `.absent`
    /// — indistinguishable from "no store here". Two irreversible things
    /// keyed off that answer: the launch route PERSISTED a mode downgrade
    /// to Auto (silently turning off the R13p-5 gate), and `resolveStoreKey`
    /// skipped its never-mint-over-ciphertext refusal, minting and SAVING
    /// a bogus key whose later failures were untyped — a doorless dead
    /// end that survived the I/O condition clearing. Present-but-unreadable
    /// now answers `.encryptedOrUnknown`: the route stays demanded, the
    /// open refuses typed (`keyUnavailable`), and the sidecar recovery
    /// road can render. A present-but-EMPTY file stays `.absent` — that
    /// half of the doc is deliberate and unchanged.
    public static func classify(at url: URL) -> StoreFilePresence {
        let present = FileManager.default.fileExists(atPath: url.path)
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return present ? .encryptedOrUnknown : .absent
        }
        defer { try? handle.close() }
        do {
            // nil WITHOUT a throw is EOF — an empty file, which is the
            // deliberate `.absent` half; only a THROWING read is the
            // unreadable case.
            guard let head = try handle.read(upToCount: 16), !head.isEmpty else {
                return .absent
            }
            return head == plaintextMagic ? .plaintext : .encryptedOrUnknown
        } catch {
            return .encryptedOrUnknown
        }
    }
}
