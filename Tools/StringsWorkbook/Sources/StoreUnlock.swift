// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation
import GRDB
import VariorumCore

/// The headless road onto an ENCRYPTED store — the locked lobby's own
/// typed-secret road, and nothing else (the record's "road decision").
///
/// It adds NO crypto and NO keying of its own: the key file is read by
/// `StoreKeyEnvelope.loadCurrent(besideStore:)`, the secret unwraps through
/// `StoreKeyEnvelope.unwrapKey(passphrase:)` / `(recoveryWords:)` (Argon2id +
/// RFC 3394 — a wrong secret refuses, never yields a key), the probe connection
/// is keyed by the core's ONE keying implementation (`artifactConfiguration()`,
/// P15-sanitized), and the real open is `AppDatabase.openStore(at:custody:)`
/// with `StoreKeyCustody.inMemory(initial:)` — exactly the lobby's call
/// (`AppBootstrap.swift:392`). No Keychain item is read, written or deleted;
/// the key lives in this process's memory and dies with it.
public enum StoreUnlock {
    public struct LocalRoads: Equatable, Sendable {
        public var keyFile: URL
        /// A LOCAL passphrase wrap exists in the key file.
        public var passphrase: Bool
        /// A LOCAL recovery-words wrap exists in the key file.
        public var recoveryWords: Bool
    }

    public enum UnlockError: Error, Equatable, CustomStringConvertible {
        case storeMissing(String)
        case notEncrypted(String)
        case noKeyFile(String)
        case keyFileUnreadable(String)
        case noPassphraseRoad
        case noRecoveryRoad
        case wrongPassphrase
        case wrongRecoveryWords(String)
        case schemaDiffers(missingInStore: [String], unknownToTool: [String])

        public var description: String {
            switch self {
            case .storeMissing(let path):
                return "no store exists at \(path) — refusing to create one (check the path)"
            case .notEncrypted(let path):
                return "\(path) is not an encrypted Variorum store — this tool opens only an "
                    + "already-encrypted library and never runs the encryption migration"
            case .noKeyFile(let folder):
                return "no key file (variorum-keys-….json) sits beside the store in \(folder)"
            case .keyFileUnreadable(let reason):
                return "the key file beside the store could not be read: \(reason)"
            case .noPassphraseRoad:
                return "this library's key file holds no passphrase copy — try --recovery-words"
            case .noRecoveryRoad:
                return "this library's key file holds no recovery-words copy — try the passphrase"
            case .wrongPassphrase:
                return "that passphrase does not unlock this library (nothing was opened)"
            case .wrongRecoveryWords(let reason):
                return "those words do not unlock this library: \(reason) (nothing was opened)"
            case .schemaDiffers(let missing, let unknown):
                return "the store's schema is not this tool's — store lacks \(missing), tool lacks "
                    + "\(unknown). Refusing: opening would migrate her library under a different build"
            }
        }
    }

    // MARK: - Before any secret

    /// Refuses unless `url` is an EXISTING, ENCRYPTED store. `openStore` would
    /// MINT a fresh store at a mistyped path and would run the one-time
    /// plaintext→encrypted migration on a plaintext file; this tool must do
    /// neither.
    public static func requireExistingEncryptedStore(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw UnlockError.storeMissing(url.path)
        }
        guard StoreFilePresence.classify(at: url) == .encryptedOrUnknown else {
            throw UnlockError.notEncrypted(url.path)
        }
    }

    /// Which local unlock roads the key file offers — read WITHOUT any secret
    /// (the key file is non-secret by design: wraps, salts, parameters).
    public static func localRoads(besideStore url: URL) throws -> LocalRoads {
        let envelope: StoreKeyEnvelope?
        do {
            envelope = try StoreKeyEnvelope.loadCurrent(besideStore: url)
        } catch {
            throw UnlockError.keyFileUnreadable(String(describing: error))
        }
        guard let envelope, let file = StoreKeyEnvelope.locate(besideStore: url) else {
            throw UnlockError.noKeyFile(url.deletingLastPathComponent().path)
        }
        return LocalRoads(
            keyFile: file, passphrase: envelope.passphrase != nil,
            recoveryWords: envelope.recovery != nil)
    }

    // MARK: - The two typed-secret roads

    public static func key(besideStore url: URL, passphrase: String) throws -> StoreKey {
        let envelope = try currentEnvelope(besideStore: url)
        guard envelope.passphrase != nil else { throw UnlockError.noPassphraseRoad }
        do {
            return try envelope.unwrapKey(passphrase: passphrase)
        } catch StoreKeyEnvelopeError.wrongPassphrase {
            throw UnlockError.wrongPassphrase
        }
    }

    /// `text` is the twelve words as typed; split on whitespace exactly as the
    /// app's lobby does (`EncryptionSession.words(from:)` — `RecoveryPhrase`
    /// does the trimming and case-folding).
    public static func key(besideStore url: URL, recoveryText text: String) throws -> StoreKey {
        let envelope = try currentEnvelope(besideStore: url)
        guard envelope.recovery != nil else { throw UnlockError.noRecoveryRoad }
        let words = text.split(whereSeparator: \.isWhitespace).map(String.init)
        do {
            return try envelope.unwrapKey(recoveryWords: words)
        } catch {
            throw UnlockError.wrongRecoveryWords(String(describing: error))
        }
    }

    static func currentEnvelope(besideStore url: URL) throws -> StoreKeyEnvelope {
        do {
            guard let envelope = try StoreKeyEnvelope.loadCurrent(besideStore: url) else {
                throw UnlockError.noKeyFile(url.deletingLastPathComponent().path)
            }
            return envelope
        } catch let error as UnlockError {
            throw error
        } catch {
            throw UnlockError.keyFileUnreadable(String(describing: error))
        }
    }

    // MARK: - The probe (before the real open)

    public struct Probe: Equatable, Sendable {
        /// The migrations this build knows and the store has applied — equal
        /// by the time a probe returns (`schemaDiffers` otherwise).
        public var migrations: [String]
        /// A book already named like the workbook (the one-shot guard), if any.
        public var existingWorkbook: String?
        public var books: Int
        public var notes: Int
    }

    /// Reads the store under `key` WITHOUT opening it the app's way: the real
    /// open runs the schema migrator, so this checks first that it would apply
    /// nothing (the store's `grdb_migrations` equals this build's list) and
    /// that the workbook is not already there. The connection is keyed by the
    /// core's own configuration, borrowed from a throwaway schema-only store in
    /// a private temp folder (deleted before returning), whose migration
    /// table is also this build's list. A wrong key fails here, before any
    /// write path exists.
    public static func probe(storeAt url: URL, key: StoreKey) throws -> Probe {
        // A DatabaseQueue at a missing path would CREATE a file — never here.
        try requireExistingEncryptedStore(at: url)
        let scratchFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent("strings-workbook-probe-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: scratchFolder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: scratchFolder) }

        let (known, configuration): ([String], Configuration) = try {
            let scratch = try AppDatabase.onDisk(
                url: scratchFolder.appendingPathComponent("schema.sqlite"), key: key)
            let (view, binding) = scratch.asRebindable()
            defer { _ = binding.lock() }
            let known = try view.read {
                try String.fetchAll($0, sql: "SELECT identifier FROM grdb_migrations ORDER BY identifier")
            }
            return (known, view.artifactConfiguration())
        }()

        let queue = try DatabaseQueue(path: url.path, configuration: configuration)
        defer { try? queue.close() }
        return try queue.read { db in
            let applied = try String.fetchAll(
                db, sql: "SELECT identifier FROM grdb_migrations ORDER BY identifier")
            let missing = known.filter { !applied.contains($0) }
            let unknown = applied.filter { !known.contains($0) }
            guard missing.isEmpty, unknown.isEmpty else {
                throw UnlockError.schemaDiffers(missingInStore: missing, unknownToTool: unknown)
            }
            return Probe(
                migrations: applied,
                existingWorkbook: try WorkbookMint.existingWorkbookName(db),
                books: try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading WHERE kind = 'book' AND deleted_at IS NULL
                    """) ?? 0,
                notes: try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL
                    """) ?? 0)
        }
    }

    // MARK: - The real open (the lobby's call)

    /// Opens the store exactly as the app's lobby does after an unlock, and
    /// returns the binding whose `lock()` closes the pool cleanly at the end.
    public static func open(storeAt url: URL, key: StoreKey) throws -> (AppDatabase, StoreBinding) {
        try requireExistingEncryptedStore(at: url)
        let database = try AppDatabase.openStore(at: url, custody: .inMemory(initial: key))
        return database.asRebindable()
    }
}
