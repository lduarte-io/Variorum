import Dependencies
import Foundation
import GRDB

extension AppDatabase: DependencyKey {
    /// The live on-disk store in Application Support — the *headless-misuse
    /// guard*, not the app's open path. The app shell (Phase 7) opens the
    /// store through the recoverable path below (`openStore` → `install`)
    /// before any view exists, so a failed open renders a recovery surface
    /// and this `fatalError` is never reached in the app (KnownIssues
    /// "AppDatabase.liveValue failure UX", resolved Phase 7). There is
    /// deliberately no `testValue`: tests must inject `.inMemory()`
    /// explicitly, so an unoverridden `@Dependency(\.database)` access fails
    /// the test.
    public static let liveValue: AppDatabase = {
        do {
            return try AppDatabase.openStore(at: try AppDatabase.defaultStoreURL())
        } catch {
            fatalError("Could not open the Variorum database: \(error)")
        }
    }()
}

// MARK: - The app shell's recoverable-open path (Phase 7)

extension AppDatabase {
    /// The typed failure the shell renders (alert with retry / reveal /
    /// quit). Wraps whatever the filesystem or SQLite threw, preserving the
    /// store path and the underlying description — never a bare `fatalError`.
    public struct StoreOpenError: Error, Equatable, Sendable {
        /// Filesystem path of the store the open targeted (or of the folder
        /// that could not be resolved).
        public let storePath: String
        /// The underlying error, preserved verbatim for the alert.
        public let reason: String
        /// Phase 13p (ladder R1-M3): true for exactly ONE refusal class —
        /// an ENCRYPTED store whose key custody holds nothing (the
        /// `resolveStoreKey` refusal). The failure surface keys the
        /// sidecar-present unlock road on this typed fact, never on
        /// matching the reason's prose.
        public let keyUnavailable: Bool
        /// VX-80 (the Castle-follow crash window): true for exactly ONE
        /// refusal class — an ENCRYPTED store whose resolved key WAS in
        /// hand and failed the open with SQLCipher's not-a-database class
        /// (a wrong key, or a file that is not a database at all —
        /// indistinguishable by design). The stranded state this types: a
        /// re-key completed its verified swap and the process died before
        /// custody moved, so custody opens the file with the OLD key
        /// forever. The failure surface keys the sidecar-present unlock
        /// road on this typed fact, never on the reason's prose (R1-M3's
        /// own precedent).
        public let keyRejected: Bool

        public init(
            storePath: String, reason: String,
            keyUnavailable: Bool = false, keyRejected: Bool = false
        ) {
            self.storePath = storePath
            self.reason = reason
            self.keyUnavailable = keyUnavailable
            self.keyRejected = keyRejected
        }
    }

    /// Which on-disk store a build opens (Phase 8, A4 — dev-store
    /// separation): the author's real corpus lives under `Variorum/`; debug
    /// builds default to a separate `Variorum-dev/` home so development
    /// activity can never land in her writing by accident. The resolution
    /// POLICY (debug default + explicit opt-in) lives in the app layer
    /// (`StoreLocation`); this type only knows the two homes.
    public enum StoreVariant: String, CaseIterable, Sendable {
        case real = "Variorum"
        case dev = "Variorum-dev"
    }

    /// The canonical on-disk location: `Application Support/<variant>/
    /// variorum.sqlite` (inside the app container when sandboxed).
    public static func defaultStoreURL(variant: StoreVariant = .real) throws -> URL {
        do {
            return try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask,
                     appropriateFor: nil, create: true)
                .appendingPathComponent(variant.rawValue, isDirectory: true)
                .appendingPathComponent("variorum.sqlite")
        } catch {
            throw StoreOpenError(
                storePath: "~/Library/Application Support",
                reason: String(describing: error))
        }
    }

    /// Opens (creating parent folders as needed) with the typed failure the
    /// shell renders. Every thrown error is a `StoreOpenError`.
    ///
    /// Phase 13p (whole-store encryption): this is the KEYED open — the one
    /// road the app, the restore drill, and 13x's adoption door all take.
    /// The store key comes from `custody` (nil = the injected
    /// `\.storeKeyCustody` dependency — the real device Keychain in the
    /// app, an in-memory process key under test): a fresh store MINTS a key
    /// into custody and is born encrypted; an encrypted store whose custody
    /// holds no key REFUSES honestly (never minting a key that could not
    /// open it — Batch 2's recovery roads are what re-derive one).
    public static func openStore(
        at url: URL, custody: StoreKeyCustody? = nil
    ) throws -> AppDatabase {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let custody = custody ?? ambientStoreKeyCustody()
            let presence = StoreFilePresence.classify(at: url)
            let key = try resolveStoreKey(at: url, presence: presence, custody: custody)
            // The one-time plaintext→encrypted migration (13p): a no-op on
            // fresh and already-encrypted stores (it also sweeps a crashed
            // attempt's stale temp), the verified export/swap road on a
            // pre-13p plaintext store — including an old plaintext BACKUP
            // being restored through this door, which is exactly how the
            // R13p-15 aged-out plaintext tail comes back in encrypted.
            try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key)
            do {
                return try AppDatabase.onDisk(url: url, key: key)
            } catch let error as DatabaseError
                where presence == .encryptedOrUnknown && error.resultCode == .SQLITE_NOTADB {
                // VX-80: the WRONG-KEY class, typed. The key in hand came
                // from custody (an encrypted presence never mints), and
                // SQLCipher's first page read refused it — the Castle-follow
                // crash window's stranded state (store re-keyed, custody
                // never moved). The failure surface keys its recovery road
                // on `keyRejected`, never on this reason's prose. No key
                // material rides the reason: the failing statement is a
                // schema read (the PRAGMA key road is separately redacted).
                throw StoreOpenError(
                    storePath: url.path, reason: String(describing: error),
                    keyRejected: true)
            }
        } catch let error as StoreOpenError {
            throw error
        } catch {
            throw StoreOpenError(storePath: url.path, reason: String(describing: error))
        }
    }

    /// The injected default custody. In the app process the shell passes
    /// custody EXPLICITLY (per resolved store variant); this serves bare
    /// `openStore(at:)` calls — the package's own `liveValue`, tests, and
    /// artifact opens.
    private static func ambientStoreKeyCustody() -> StoreKeyCustody {
        @Dependency(\.storeKeyCustody) var custody
        return custody
    }

    /// Load-or-mint, with the two honest refusals: an encrypted store whose
    /// key is gone (refuse, do NOT mint over the emptiness), and a custody
    /// that cannot KEEP a fresh mint (refuse to create a store that would
    /// be unopenable at the next launch).
    private static func resolveStoreKey(
        at url: URL, presence: StoreFilePresence, custody: StoreKeyCustody
    ) throws -> StoreKey {
        if let held = custody.load() { return held }
        if presence == .encryptedOrUnknown {
            throw StoreOpenError(
                storePath: url.path,
                reason: "This library is encrypted, and its key is not available "
                    + "on this device.",
                keyUnavailable: true)
        }
        let minted = StoreKey.mint()
        guard custody.save(minted) else {
            throw StoreOpenError(
                storePath: url.path,
                reason: "A key for this library could not be saved to the Keychain, "
                    + "so an encrypted library was not created — a store whose key "
                    + "cannot be kept would be unopenable at the next launch.")
        }
        return minted
    }

    /// Wires a successfully opened store as the live `\.database` dependency.
    /// Called exactly once by root composition, after the recoverable-open
    /// path succeeds and before anything constructs `Operations` or reads
    /// `@Dependency(\.database)`.
    public static func install(_ database: AppDatabase) {
        prepareDependencies { $0.database = database }
    }
}

extension DependencyValues {
    public var database: AppDatabase {
        get { self[AppDatabase.self] }
        set { self[AppDatabase.self] = newValue }
    }
}
