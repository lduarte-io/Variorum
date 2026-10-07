import Foundation
import GRDB

/// **THE SEARCH INDEX'S MAINTENANCE DOORS** (13o U1 P5 — the plan's U1 item
/// 3: "drop + rebuild from truth, integrity check comparing doc rows against
/// source rows — the restore/doubt/drift net").
///
/// The index is DERIVED (R-13o-3): nothing of hers lives in it, so both doors
/// are safe at any moment — no synced row is written (the outbox is
/// untouched), no stamp moves, no undo entry is registered (there is nothing
/// to undo: truth is unchanged). Faces (a Settings row, a post-restore pass)
/// are later units'; the doors are here.
extension Operations {
    /// **The rebuild door** — every doc re-derived from the live source rows
    /// and the index re-read from them, then verified, in ONE transaction:
    /// the answer is the state it leaves. Idempotent. Cost ∝ the corpus
    /// (measured ~0.66 s at 55k takes) — a deliberate act, never a keystroke.
    @discardableResult
    public func rebuildSearchIndex() throws -> SearchIndexIntegrity {
        try database.write { db in
            try SearchIndex.rebuild(db)
            return try SearchIndex.integrity(db)
        }
    }

    /// **The integrity check** — the doc set against the source rows and the
    /// index against its content (`SearchIndexIntegrity`). Writes nothing; it
    /// runs on the writer only because FTS5 spells its check as an INSERT.
    public func verifySearchIndex() throws -> SearchIndexIntegrity {
        try database.write { db in try SearchIndex.integrity(db) }
    }
}
