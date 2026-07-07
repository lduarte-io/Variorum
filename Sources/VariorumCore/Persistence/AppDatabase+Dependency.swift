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

        public init(storePath: String, reason: String) {
            self.storePath = storePath
            self.reason = reason
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
    public static func openStore(at url: URL) throws -> AppDatabase {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            return try AppDatabase.onDisk(url: url)
        } catch let error as StoreOpenError {
            throw error
        } catch {
            throw StoreOpenError(storePath: url.path, reason: String(describing: error))
        }
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
