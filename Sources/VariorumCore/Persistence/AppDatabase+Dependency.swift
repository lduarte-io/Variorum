import Dependencies
import Foundation
import GRDB

extension AppDatabase: DependencyKey {
    /// The live on-disk store in Application Support. Root composition wires
    /// this for real at the app phase (Phase 7). There is deliberately no
    /// `testValue`: tests must inject `.inMemory()` explicitly, so an
    /// unoverridden `@Dependency(\.database)` access fails the test.
    public static let liveValue: AppDatabase = {
        do {
            let folder = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Variorum", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return try AppDatabase.onDisk(url: folder.appendingPathComponent("variorum.sqlite"))
        } catch {
            fatalError("Could not open the Variorum database: \(error)")
        }
    }()
}

extension DependencyValues {
    public var database: AppDatabase {
        get { self[AppDatabase.self] }
        set { self[AppDatabase.self] = newValue }
    }
}
