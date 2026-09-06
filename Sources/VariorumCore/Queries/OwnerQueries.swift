import Foundation
import GRDB

extension Queries {
    /// pre-13x 2c — THE OWNER DISTINCTION's read (the postures design §3.6):
    /// the account that LAST SYNCED this library's rows, as their `owner_id`
    /// stamp says — the first non-NULL stamp across the owner-carrying
    /// synced tables in registry order. nil = no stamped row (a library that
    /// never synced; nothing to disagree with). The reconcile compares it
    /// with the signed-in user id: SAME ⇒ a rotated account FOLLOWS (§7);
    /// DIFFERENT ⇒ another vault — the adopt road (batch 3). `adoptOwnerID`
    /// stamps only NULL owners, so a library that synced under X keeps X's
    /// stamp when Y signs in — which is exactly what makes this readable.
    public static func stampedOwnerID(_ db: Database) throws -> String? {
        for table in SyncSchema.tables where table.plainColumns.contains("owner_id") {
            if let owner = try String.fetchOne(
                db, sql: "SELECT owner_id FROM \(table.name) WHERE owner_id IS NOT NULL LIMIT 1") {
                return owner
            }
        }
        return nil
    }

    /// pre-13x 3a — THE EXACT FOREIGN-OWNER READ (decision 17; §3.6; ledger
    /// 15): a library is FOREIGN to the signed-in account when ANY
    /// owner-carrying synced row's `owner_id` is non-NULL and ≠ `userID` —
    /// a MIXED library (rows born under Y beside X's) reads foreign, which
    /// `stampedOwnerID`'s first-row read could miss. Tombstones count: they
    /// still sync. This is the verdict's read; the adopt road
    /// (`Operations.restampOwner`) is what makes it false again.
    public static func foreignOwnerExists(_ db: Database, signedIn userID: String) throws -> Bool {
        for table in SyncSchema.tables where table.plainColumns.contains("owner_id") {
            let hit = try Int.fetchOne(
                db,
                sql: "SELECT 1 FROM \(table.name) WHERE owner_id IS NOT NULL AND owner_id != ? LIMIT 1",
                arguments: [userID])
            if hit != nil { return true }
        }
        return false
    }
}
