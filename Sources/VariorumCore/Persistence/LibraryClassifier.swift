import Foundation
import GRDB

// Phase 13x, U1 row 1 — THE PICKED-THING CLASSIFIER (the 13x plan's U1 §1;
// the kickoff rulings QB/QC). ONE brain behind both framed doors — *File ▸
// Open Library…* and *Restore from Backup…* — answering "what is this?"
// for a URL the user picked, BEFORE any secret is typed and WITHOUT
// inventing a byte of crypto: every fact it reads is non-secret by design
// (file magic, key-file names and fingerprints, a plaintext store's own
// schema tables).
//
// TWO STAGES, by construction. `classify(at:)` is KEYLESS: an encrypted
// copy's inside is unreadable until a secret opens it, so for ciphertext
// the verdict is about the PAIR (corner 33: a library arriving WITH its
// key file opens by the lobby's ordinary roads; without it nothing opens).
// `schemaVerdict(at:key:)` is the POST-UNLOCK consult: with the key in
// hand it reads `grdb_migrations` read-only and renders the migrator's
// superseded check honestly (the sync trace's item 5 — a copy from a
// NEWER build refuses, never crashes). Neither stage ever runs the
// migrator against the picked file.
//
// The pair rules this file reads are the SHIPPED ones, restated from their
// owners rather than re-invented: the live key file's fingerprint name
// (`StoreKeyEnvelope.filename(forFingerprint:)`, §3.5), the snapshot's own
// pair (`<snapshot>.keys.json`, pre-13x 2a row 42 — `StoreBackup
// .pairedKeyFile` writes it; the rule is one `deletingPathExtension`), the
// folder's fingerprint-named file serving pre-row-42 snapshots, and the
// legacy `variorum-keys.json` serving legacy snapshots (design §6).

public enum LibraryClassifier {
    /// THE VERDICT TABLE (pinned by `LibraryClassifierTests`, one pin per
    /// row). The door words are U2's; every refusal-shaped verdict here
    /// carries the facts a sentence needs.
    public enum Verdict: Equatable, Sendable {
        /// An encrypted store with a key file beside it — the hand-off
        /// shape and a hand-copied library folder alike. Opens by the
        /// lobby's ordinary roads (the key file's wraps).
        case encryptedLibrary(store: URL, keyFile: URL)
        /// A backup snapshot with the key file that serves it: its own
        /// pair (`…keys.json`), the folder's fingerprint-named file
        /// matched by the snapshot name's fp8, or the legacy folder file
        /// for a stamp-only name (design §6, decision 11).
        case snapshotPair(store: URL, keyFile: URL)
        /// A picked FOLDER holding one store and its key file (the
        /// AirDropped hand-off folder — QC's ruling).
        case folderHoldingPair(store: URL, keyFile: URL)
        /// A picked folder holding SEVERAL stores: the door offers them;
        /// the classifier never guesses (PROVISIONAL P-U1-3).
        case folderHoldingStores([URL])
        /// A plaintext export (decision 15): Variorum-shaped, every one of
        /// the four local-only tables ABSENT (`SyncSchema.localOnlyTables`
        /// — §14.13's reconciliation subject).
        case plaintextExport(store: URL)
        /// A plaintext FULL library (local tables present — a pre-13p
        /// store). PROVISIONAL P-U1-1: not one of the ruled seven; the
        /// door's handling is U2's.
        case plaintextLibrary(store: URL)
        /// A bare opaque file with NO key file that serves it — an
        /// encrypted library missing its key file, or not a database at
        /// all (indistinguishable without a key, deliberately). The
        /// honest refusal; the remedy sentence ("send the whole folder —
        /// the key file travels with it") is the door's.
        case bareStoreWithoutKeyFile(store: URL)
        /// A READABLE plaintext store written by a newer build — the
        /// migrator's superseded check, keyless half.
        case newerSchema(store: URL, unknownMigrations: [String])
        /// Readable, and not a Variorum store (no migration table, or no
        /// Variorum tables) — or a folder holding no store at all.
        case notAVariorumStore(URL)
        /// Present but unopenable/undecodable plaintext (the P12/P13
        /// honesty class — never guessed into a neighboring verdict;
        /// PROVISIONAL P-U1-2).
        case unreadable(URL, reason: String)
    }

    // MARK: - Stage 1: keyless classification

    public static func classify(at url: URL) -> Verdict {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        guard exists else { return .notAVariorumStore(url) }
        if isDirectory.boolValue { return classifyFolder(url) }
        switch StoreFilePresence.classify(at: url) {
        case .absent:
            // An EMPTY file (classify's deliberate `.absent` half): nothing
            // to open.
            return .notAVariorumStore(url)
        case .plaintext:
            return classifyPlaintext(url)
        case .encryptedOrUnknown:
            return classifyOpaque(url)
        }
    }

    /// The folder arm (QB/QC: the door takes the `.sqlite` or the folder
    /// itself). One store inside ⇒ the inner verdict, pair-shaped verdicts
    /// wrapped as `folderHoldingPair`; several ⇒ reported, never guessed.
    private static func classifyFolder(_ folder: URL) -> Verdict {
        let entries = (try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: nil)) ?? []
        let stores = entries
            .filter { $0.pathExtension == "sqlite" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            // The verdict speaks in the CALLER's path form (`/var/…` and
            // `/private/var/…` are one folder; a verdict must compare equal
            // to the URL the door built).
            .map { folder.appendingPathComponent($0.lastPathComponent, isDirectory: false) }
        switch stores.count {
        case 0:
            return .notAVariorumStore(folder)
        case 1:
            switch classify(at: stores[0]) {
            case .encryptedLibrary(let store, let keyFile),
                 .snapshotPair(let store, let keyFile):
                return .folderHoldingPair(store: store, keyFile: keyFile)
            case let inner:
                return inner
            }
        default:
            return .folderHoldingStores(stores)
        }
    }

    // MARK: - The opaque arm (ciphertext — the key-file hunt)

    /// The snapshot pair rule (pre-13x 2a row 42): the key file written
    /// WITH a snapshot, beside it, under the snapshot's own name. The
    /// writer is `StoreBackup.pairedKeyFile` (Shared); the rule is one
    /// path transform, restated here so core can READ what Shared writes.
    public static func pairedKeyFile(for snapshot: URL) -> URL {
        snapshot.deletingPathExtension().appendingPathExtension("keys.json")
    }

    /// The fp8 a backup snapshot's name carries
    /// (`variorum-backup-<stamp>-<fp8>.sqlite`); nil for stamp-only names
    /// and for names that are not the app's backup shape at all.
    static func backupNameFingerprint(_ url: URL) -> (isBackupNamed: Bool, fp8: String?) {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix("variorum-backup-") else { return (false, nil) }
        let tail = name.dropFirst("variorum-backup-".count)
        // `yyyy-MM-dd-HHmmss` is 17 characters; the optional tail is
        // `-` + 8 lowercase hex (StoreBackup's own naming, restated).
        guard tail.count >= 17 else { return (true, nil) }
        let suffix = tail.dropFirst(17)
        guard suffix.hasPrefix("-"), suffix.count == 9,
              suffix.dropFirst().allSatisfy({ "0123456789abcdef".contains($0) })
        else { return (true, nil) }
        return (true, String(suffix.dropFirst()))
    }

    private static func classifyOpaque(_ store: URL) -> Verdict {
        // 1. The snapshot's OWN pair, whatever the name (the hand-off and
        //    row-42 shapes alike carry the key file beside the store; the
        //    pair name wins over the folder hunt because it was written
        //    WITH this exact snapshot).
        let pair = pairedKeyFile(for: store)
        let (isBackupNamed, nameFP8) = backupNameFingerprint(store)
        if let envelope = try? StoreKeyEnvelope.load(at: pair) {
            // A name that carries fp8 must AGREE with the pair it names —
            // a mismatched pair does not open this snapshot and must not
            // be offered as if it did.
            if let fp8 = nameFP8, let fingerprint = envelope.keyFingerprint,
               StoreKeyEnvelope.shortFingerprint(fingerprint) != fp8 {
                // fall through to the folder hunt
            } else {
                return .snapshotPair(store: store, keyFile: pair)
            }
        }
        if isBackupNamed {
            // 2. A backup-named snapshot without its own pair: the
            //    folder's fingerprint-named file (serving pre-row-42
            //    snapshots) matched by fp8, else — for a stamp-only
            //    legacy name — whatever key file the folder holds.
            let folder = store.deletingLastPathComponent()
            let candidates = StoreKeyEnvelope.keyFileURLs(besideStore: store)
                // The caller's path form, as in the folder arm.
                .map { folder.appendingPathComponent($0.lastPathComponent, isDirectory: false) }
            if let fp8 = nameFP8 {
                if let match = candidates.first(where: {
                    StoreKeyEnvelope.fingerprint(fromFilename: $0.lastPathComponent)?
                        .hasPrefix(fp8) == true
                }) {
                    return .snapshotPair(store: store, keyFile: match)
                }
                // A folder key file of a DIFFERENT key does not open this
                // snapshot — saying so is the honest refusal.
                return .bareStoreWithoutKeyFile(store: store)
            }
            if let located = StoreKeyEnvelope.locate(besideStore: store) {
                return .snapshotPair(store: store, keyFile: rebased(located, besideStore: store))
            }
            return .bareStoreWithoutKeyFile(store: store)
        }
        // 3. An ordinary name: the live-key-file rule (§3.5 — the current
        //    key file beside the store). The hand-off folder classifies
        //    here: its key file rides under its own fingerprint name.
        if let located = StoreKeyEnvelope.locate(besideStore: store) {
            return .encryptedLibrary(store: store, keyFile: rebased(located, besideStore: store))
        }
        // 4. Nothing serves it (corner 33's refusal).
        return .bareStoreWithoutKeyFile(store: store)
    }

    // MARK: - The plaintext arm (readable without any key)

    /// A discovered sibling, spoken in the CALLER's path form (directory
    /// listings resolve `/var/…` to `/private/var/…`; a verdict must
    /// compare equal to URLs the door built from the picked one).
    private static func rebased(_ discovered: URL, besideStore store: URL) -> URL {
        store.deletingLastPathComponent()
            .appendingPathComponent(discovered.lastPathComponent, isDirectory: false)
    }

    private static func classifyPlaintext(_ store: URL) -> Verdict {
        do {
            return try readPlaintext(store)
        } catch {
            return .unreadable(store, reason: String(describing: error))
        }
    }

    private static func readPlaintext(_ store: URL) throws -> Verdict {
        let queue = try openForInspection(store)
        defer { try? queue.close() }
        return try queue.read { db in
            guard try db.tableExists("grdb_migrations") else {
                return .notAVariorumStore(store)
            }
            // The Variorum shape: the two tables everything else points at.
            guard try db.tableExists("block"), try db.tableExists("container") else {
                return .notAVariorumStore(store)
            }
            // The migrator's superseded check, keyless half: identifiers
            // this build has never heard of mean a NEWER build wrote it.
            let applied = try Set(String.fetchAll(
                db, sql: "SELECT identifier FROM grdb_migrations"))
            let known = Set(AppDatabase.migrator.migrations)
            let unknown = applied.subtracting(known).sorted()
            if !unknown.isEmpty {
                return .newerSchema(store: store, unknownMigrations: unknown)
            }
            // Export vs full library: the export drops ALL FOUR local-only
            // tables (`StorePlaintextExport`); any one present means local
            // machinery, which no export carries.
            for table in SyncSchema.localOnlyTables {
                if try db.tableExists(table) { return .plaintextLibrary(store: store) }
            }
            // §14.13's precondition, verified rather than assumed: the
            // synced tables keep `sync_version` and `owner_id`.
            let columns = try db.columns(in: "container").map(\.name)
            guard columns.contains("sync_version"), columns.contains("owner_id") else {
                return .plaintextLibrary(store: store)
            }
            return .plaintextExport(store: store)
        }
    }

    /// Read-only first; a WAL-journaled plaintext file (a Finder-copied
    /// pre-13p library) can refuse a read-only open outright, so the
    /// fallback opens read-write — SELECT-only inside, but SQLite may
    /// materialize `-shm`/`-wal` sidecars. Recorded, not hidden: on a
    /// read-only volume the fallback fails too and the verdict is
    /// `.unreadable`, never a guess.
    private static func openForInspection(_ store: URL) throws -> DatabaseQueue {
        var readOnly = AppDatabase.configuration()
        readOnly.readonly = true
        if let queue = try? DatabaseQueue(path: store.path, configuration: readOnly) {
            return queue
        }
        return try DatabaseQueue(path: store.path, configuration: AppDatabase.configuration())
    }

    // MARK: - Stage 2: the post-unlock schema consult

    /// What the OPEN road would meet (advisory, never the migrator's run):
    /// `.current` opens as-is, `.behindThisBuild` opens and migrates up,
    /// `.newer` is the honest refusal the door renders (the sync trace's
    /// item 5), `.unreadable` covers a wrong key and a torn file alike.
    public enum SchemaVerdict: Equatable, Sendable {
        case current
        case behindThisBuild(unapplied: [String])
        case newer(unknownMigrations: [String])
        case unreadable(reason: String)
    }

    /// `key` nil = a plaintext file (the export's consult).
    public static func schemaVerdict(at url: URL, key: StoreKey?) -> SchemaVerdict {
        do {
            var configuration = AppDatabase.configuration(key: key)
            configuration.readonly = true
            let queue: DatabaseQueue
            do {
                queue = try DatabaseQueue(path: url.path, configuration: configuration)
            } catch {
                // 13x F1 (ladder R1-N2 — `openForInspection`'s recorded
                // sentence, owed here too): a WAL-journaled copy can
                // refuse a read-only open outright, so the fallback opens
                // read-write — SELECT-only inside, but SQLite may
                // materialize `-shm`/`-wal` sidecars beside the PICKED
                // SOURCE. Recorded, not hidden: on a read-only volume the
                // fallback fails too and the verdict is `.unreadable`,
                // never a guess (the never-rewritten doctrine's honest
                // edge, same as stage 1's).
                queue = try DatabaseQueue(
                    path: url.path, configuration: AppDatabase.configuration(key: key))
            }
            defer { try? queue.close() }
            return try queue.read { db in
                let applied = try Set(String.fetchAll(
                    db, sql: "SELECT identifier FROM grdb_migrations"))
                let known = AppDatabase.migrator.migrations
                let unknown = applied.subtracting(known).sorted()
                if !unknown.isEmpty { return .newer(unknownMigrations: unknown) }
                let unapplied = known.filter { !applied.contains($0) }
                return unapplied.isEmpty ? .current : .behindThisBuild(unapplied: unapplied)
            }
        } catch {
            return .unreadable(reason: String(describing: error))
        }
    }
}
