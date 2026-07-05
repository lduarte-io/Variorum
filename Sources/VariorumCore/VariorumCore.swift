import Dependencies
import GRDB

/// Phase 0 placeholder proving the dependency graph resolves and SQLite opens.
/// Replaced by the real persistence stack in Phase 1 (notes/plans/phase-01-schema-and-migrations.md).
public enum VariorumCore {
    public static func sqliteVersion() throws -> String {
        try DatabaseQueue().read { db in
            try String.fetchOne(db, sql: "SELECT sqlite_version()") ?? "unknown"
        }
    }
}
