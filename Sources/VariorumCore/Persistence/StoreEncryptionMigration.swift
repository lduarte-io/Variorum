import Foundation
import GRDB

// Phase 13p, Batch 1 — the ONE-TIME migration of an existing plaintext
// store to whole-store encryption (THE DESIGN's migration paragraph, the
// spike memo's measured road: `sqlcipher_export()` into a keyed temp, then
// a verified atomic file swap — ~125 ms for a full 10k-block corpus).
//
// CRASH-SAFE AT EVERY STEP (the 14c re-run-guard discipline): a crash
// anywhere on this road relaunches into either the old plaintext store
// (still whole, still migratable — the re-run redoes everything from
// scratch) or the verified new one — never neither. The mechanism:
//
//   1. nothing touches the original until the very last step;
//   2. the temp is deleted and rebuilt on every attempt, so a partial temp
//      from a crashed run is never trusted;
//   3. the source's WAL is drained (TRUNCATE checkpoint) and PROVEN empty
//      before the swap — so the one dangerous window (a swapped-in
//      ciphertext file beside a plaintext WAL that SQLite might replay
//      into it) cannot open: any surviving `-wal` is zero-length and
//      recovery finds nothing to replay;
//   4. the swap itself is a single POSIX `rename(2)` — atomic replacement
//      on the same volume, never a copy;
//   5. re-running after ANY crash is decided by the file's own first bytes
//      (`StoreFilePresence`), not by recorded state that could lie.
//
// ATOMICITY COMES FROM THE VERIFIED FILE SWAP, NEVER A WRAPPING
// TRANSACTION: `ATTACH`/`DETACH` cannot run inside one (`DETACH` inside
// GRDB's normal `write {}` fails with "database is locked" — spike memo
// Q5's mechanism note), which is why the export runs via
// `writeWithoutTransaction`. Do not "improve" this into a transaction.
//
// Honest footnote, recorded not hidden (THE DESIGN): SSD free-space
// remnants of the old plaintext file are unrecoverable-in-practice under
// FileVault; we do not claim secure erasure of the pre-migration file.

public enum StoreEncryptionMigration {
    /// The crash-drill boundaries, in road order. The fault injector runs
    /// AFTER the named step completes — a test (or the kill-mid-road drill
    /// harness) aborts there to prove the relaunch lands whole.
    public enum Step: String, CaseIterable, Sendable {
        /// `sqlcipher_export()` finished; the keyed temp is fully written;
        /// the original is untouched and still open.
        case exported
        /// The source's row counts are captured, its WAL is drained
        /// (TRUNCATE checkpoint) and its connection closed.
        case checkpointed
        /// The temp reopened WITH the key, its header read as ciphertext,
        /// and its row counts matched the source's exactly.
        case verified
        /// The atomic rename put the encrypted file at the store's path.
        /// Only stale (drained) sidecar removal remains.
        case swapped
    }

    /// A migration failure that leaves the original store untouched.
    public struct MigrationError: Error, CustomStringConvertible {
        public let reason: String
        public var description: String { "StoreEncryptionMigration: \(reason)" }
    }

    /// Encrypts the plaintext store at `url` under `key`, in place, via the
    /// verified-swap road above. Returns `true` when a migration ran,
    /// `false` when there was nothing to do (no file, or already
    /// encrypted). Idempotent and re-runnable: the trigger is the file's
    /// own first bytes.
    ///
    /// `faultInjector` is the crash-drill seam: called after each `Step`,
    /// and whatever it does — throw to simulate an unwound crash, or
    /// SIGKILL the process for the real thing — the next run must land
    /// whole. Production passes nothing.
    @discardableResult
    public static func migrateIfNeeded(
        at url: URL,
        key: StoreKey,
        faultInjector: ((Step) throws -> Void)? = nil
    ) throws -> Bool {
        let temp = URL(fileURLWithPath: url.path + ".encrypting")
        guard StoreFilePresence.classify(at: url) == .plaintext else {
            // Nothing to migrate. A stale temp can only be a crashed
            // PREVIOUS attempt's leavings (post-swap, the temp has been
            // renamed away) — sweep it so it never lingers beside a
            // finished store.
            removeArtifacts(of: temp)
            return false
        }

        // 1. Every attempt starts from a clean temp: a partial temp from a
        //    crashed run is never trusted, always rebuilt.
        removeArtifacts(of: temp)

        // 2. Export through the plaintext source's own connection into the
        //    KEYED temp. A bare `DatabaseQueue` on purpose: the migrator
        //    must not run against a store that is mid-migration.
        var counts: [String: Int] = [:]
        do {
            let source = try DatabaseQueue(path: url.path)
            try source.writeWithoutTransaction { db in
                // P15 (pre-13u Act 9): catch-and-sanitize — a throwing
                // ATTACH (unwritable temp, SQLITE_CANTOPEN, the
                // attached-db limit) is the one traceable road where a
                // key-bearing statement fails, and GRDB's error
                // description carries the executed SQL verbatim. The
                // scrubbed text still names the cause; the key never
                // rides any description channel.
                do {
                    try db.execute(
                        sql: "ATTACH DATABASE ? AS encrypted KEY \"x'\(key.hexEncoded)'\"",
                        arguments: [temp.path])
                } catch {
                    throw MigrationError(reason:
                        "the encrypted temp could not be attached "
                        + "(\(key.redactedDescription(of: error))); "
                        + "the original store is untouched")
                }
                try db.execute(sql: "SELECT sqlcipher_export('encrypted')")
                try db.execute(sql: "DETACH DATABASE encrypted")
            }
            try faultInjector?(.exported)

            // 3. Capture the source's row counts (the verification
            //    baseline) and drain its WAL, so nothing the swap leaves
            //    behind could ever be replayed into the encrypted file.
            try source.writeWithoutTransaction { db in
                counts = try tableCounts(db)
                _ = try Row.fetchOne(db, sql: "PRAGMA wal_checkpoint(TRUNCATE)")
            }
            try source.close()
        }
        try faultInjector?(.checkpointed)

        // 3b. The belt on the drained-WAL claim: if a non-empty `-wal`
        //     somehow survives the checkpoint + close, swapping would open
        //     the replay window — refuse instead; the original is whole and
        //     a relaunch retries.
        let walPath = url.path + "-wal"
        if let size = (try? FileManager.default.attributesOfItem(atPath: walPath))?[.size]
            as? Int, size > 0 {
            throw MigrationError(reason:
                "the source's WAL did not drain (\(size) bytes remain); "
                + "the store is untouched — relaunching retries the migration")
        }

        // 4. Verify the temp: opens WITH the key, reads as ciphertext, and
        //    holds exactly the source's rows. Ciphertext that cannot be
        //    reopened is worthless, so this open is the proof, not a
        //    formality.
        do {
            let verify = try DatabaseQueue(
                path: temp.path, configuration: AppDatabase.configuration(key: key))
            let found = try verify.read { try tableCounts($0) }
            try verify.close()
            guard found == counts else {
                throw MigrationError(reason:
                    "the encrypted copy failed row-count verification "
                    + "(\(found.count) tables vs \(counts.count)); "
                    + "the original store is untouched")
            }
        } catch let error as MigrationError {
            throw error
        } catch {
            throw MigrationError(reason:
                "the encrypted copy failed verification (\(error)); "
                + "the original store is untouched")
        }
        guard StoreFilePresence.classify(at: temp) == .encryptedOrUnknown else {
            throw MigrationError(reason:
                "the exported copy is not ciphertext; the original store is untouched")
        }
        try faultInjector?(.verified)

        // 5. The atomic swap. POSIX rename(2) replaces the destination
        //    atomically on the same volume — there is no instant at which
        //    the store path holds neither file. (The verify open ran in
        //    rollback-journal mode and closed clean, so the temp has no
        //    sidecars to lose in the rename.)
        removeArtifacts(of: temp, mainFile: false)  // sidecar hygiene only
        guard rename(temp.path, url.path) == 0 else {
            let code = errno
            throw MigrationError(reason:
                "the atomic swap failed (errno \(code): "
                + "\(String(cString: strerror(code)))); the encrypted copy "
                + "remains at \(temp.lastPathComponent) and the original is untouched")
        }
        try faultInjector?(.swapped)

        // 6. The old store's sidecars are drained husks now (step 3 proved
        //    the -wal empty; the -shm indexes nothing). Sweep them.
        for suffix in ["-wal", "-shm"] {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
        return true
    }

    /// Does `key` open the ciphertext at `url`? SQLCipher defers key
    /// validation to the first page read, so the probe READS: a wrong key
    /// throws ("file is not a database"); a right one answers the schema
    /// table's count. Read-only, no migrator, nothing written.
    public static func opens(_ url: URL, key: StoreKey) -> Bool {
        do {
            var configuration = AppDatabase.configuration(key: key)
            configuration.readonly = true
            let queue = try DatabaseQueue(path: url.path, configuration: configuration)
            _ = try queue.read { db in
                try Int.fetchOne(db, sql: "SELECT count(*) FROM sqlite_master")
            }
            try queue.close()
            return true
        } catch {
            return false
        }
    }

    /// Row counts for every user table — the verification baseline. All
    /// tables, not a sample: the whole store is what the swap promises.
    static func tableCounts(_ db: Database) throws -> [String: Int] {
        let names = try String.fetchAll(db, sql: """
            SELECT name FROM sqlite_master
            WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
            """)
        var counts: [String: Int] = [:]
        for name in names {
            let quoted = name.replacingOccurrences(of: "\"", with: "\"\"")
            counts[name] = try Int.fetchOne(
                db, sql: "SELECT count(*) FROM \"\(quoted)\"") ?? 0
        }
        return counts
    }

    private static func removeArtifacts(of url: URL, mainFile: Bool = true) {
        if mainFile { try? FileManager.default.removeItem(at: url) }
        for suffix in ["-wal", "-shm"] {
            try? FileManager.default.removeItem(atPath: url.path + suffix)
        }
    }
}
