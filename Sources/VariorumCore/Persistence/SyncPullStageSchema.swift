import Foundation

// VX-494 — THE PULL STAGE'S TABLE (`notes/plans/fixes/vx-494-catchup-hang.md`, THE FIX DESIGN, D2).
//
// A first catch-up on a large library downloads the whole changefeed before its one apply transaction can run.
// The stage holds each downloaded window — the rows already OPENED at the wire seam, plaintext like every local
// row — so a round interrupted before its apply (a lock, a quit, a dropped connection) resumes the download where
// it stopped instead of starting again from the committed cursor. The apply reads the stage in `server_seq` order
// and empties it in the same transaction that advances the cursor.
//
// LOCAL-ONLY, by registration (`SyncSchema.localOnlyTables`): no `sync_version`, no outbox trigger, never a payload
// or a mirror; the plaintext export drops it; `LocalMachineryRecreation` re-creates it empty. NOT a SyncSpec §12
// lockstep event — nothing on the wire changes, the marker stays 14.
//
// ONE VALUE, TWO USERS: the migration `v1_32_sync_pull_stage` and `LocalMachineryRecreation`.

public enum SyncPullStageSchema {
    public static let table = "sync_pull_stage"

    /// One row per synced row downloaded and not yet applied: its table and id, the `server_seq` it was served
    /// at (a newer download of the same row replaces an older one), and the opened `SyncPulledRow` as JSON.
    public static let ddl = """
        CREATE TABLE sync_pull_stage (
          table_name TEXT NOT NULL,
          row_id     TEXT NOT NULL,
          server_seq INTEGER NOT NULL,
          payload    TEXT NOT NULL,
          PRIMARY KEY (table_name, row_id)
        );
        """
}
