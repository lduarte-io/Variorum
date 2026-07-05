import GRDB

extension AppDatabase {
    /// The schema migrator. `v1_core` (tables, indexes, triggers, seeds —
    /// AppSpec §7, SyncSpec §3/§8) registers here in the schema commit.
    static var migrator: DatabaseMigrator {
        let migrator = DatabaseMigrator()
        return migrator
    }
}
