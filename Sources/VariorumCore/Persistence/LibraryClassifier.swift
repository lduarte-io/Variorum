import Foundation
import GRDB

// Phase 13x, U1 row 1 — THE PICKED-THING CLASSIFIER (the 13x plan's U1 §1;
// the kickoff rulings QB/QC), answering "what is this?" for a URL the user
// picked, BEFORE any secret is typed and WITHOUT inventing a byte of crypto:
// every fact it reads is non-secret by design (file magic, file NAMES, a
// plaintext store's own schema tables).
//
// TWO STAGES, by construction. `classify(at:)` is KEYLESS: an encrypted
// copy's inside is unreadable until a secret opens it, so for ciphertext
// the verdict is about what sits BESIDE it. `schemaVerdict(at:key:)` is the
// POST-UNLOCK consult: with the key in hand it reads `grdb_migrations` and
// renders the migrator's superseded check honestly (the sync trace's item 5
// — a copy from a NEWER build refuses, never crashes). Neither stage ever
// runs the migrator against the picked file — and (13x F3, ladder R3-1)
// neither ever OPENS the picked file in place: every SQLite read goes
// through `withStagedRead`, on our own copy, so the picked folder is only
// ever read.
//
// VX-329 U1 — THE RELEASE SWITCH: today's key-file READERS left with today's
// road (rule 26 — stores and copies from before this design are neither
// migrated nor handled). This design's pair (a store with its format-3 key
// file) is the new road's to recognise (`PickedCopy`, which decodes it); the
// classifier serves only the HONEST WORDS for everything else, and so it
// still NAMES — by file name, reading no byte of it — a key file beside an
// encrypted store: `.encryptedLibrary` says "a key file is there" (this
// build's own name, or one an older Variorum wrote), so the refusal never
// claims a copy is keyless when it is not (the plan's §6 OPEN DESIGN NOTE).
// `.bareStoreWithoutKeyFile` is reserved for an encrypted store with NO
// key-file-shaped name beside it.

public enum LibraryClassifier {
    /// THE VERDICT TABLE (pinned by `LibraryClassifierTests`, one pin per
    /// row). Every refusal-shaped verdict carries the facts a sentence needs.
    public enum Verdict: Equatable, Sendable {
        /// An encrypted store with a key-file-shaped file beside it (named,
        /// never read — see `keyFileBeside`): its own `<stem>.keys.json`,
        /// this design's `variorum-library-keys.json`, or a key file an
        /// older Variorum wrote (`variorum-keys.json`,
        /// `variorum-keys-<fp16>.json`). A picked folder holding one store
        /// classifies as that store.
        case encryptedLibrary(store: URL, keyFile: URL)
        /// A picked folder holding SEVERAL stores: the door offers them;
        /// the classifier never guesses (PROVISIONAL P-U1-3).
        case folderHoldingStores([URL])
        /// A plaintext export (decision 15): Variorum-shaped, every one of
        /// the four local-only tables ABSENT (`SyncSchema.localOnlyTables`
        /// — §14.13's reconciliation subject).
        case plaintextExport(store: URL)
        /// A plaintext FULL library (local tables present — a pre-13p
        /// store). PROVISIONAL P-U1-1.
        case plaintextLibrary(store: URL)
        /// A bare opaque file with NO key-file-shaped file beside it — an
        /// encrypted library missing its key file, or not a database at
        /// all (indistinguishable without a key, deliberately). The
        /// honest refusal; the remedy sentence is the door's.
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
    /// itself). One store inside ⇒ the inner verdict; several ⇒ reported,
    /// never guessed.
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
            return classify(at: stores[0])
        default:
            return .folderHoldingStores(stores)
        }
    }

    // MARK: - The opaque arm (ciphertext — what sits beside it, by NAME)

    /// This design's key file beside a library (`ProtectionNames.keyFilename`, restated — core's Persistence cannot see
    /// the Protection model's names file without a cycle of meaning; the pin holds the two equal).
    static let thisDesignsKeyFilename = "variorum-library-keys.json"
    /// The names an OLDER Variorum (before this design) wrote for its key files — recognised by NAME only, never
    /// read (rule 26): the fixed legacy name and the fingerprint-named form.
    static let olderKeyFilename = "variorum-keys.json"
    static let olderFingerprintKeyFilePrefix = "variorum-keys-"

    /// Whether `name` is an older Variorum's fingerprint-named key file (`variorum-keys-<fp16>.json`).
    static func isOlderFingerprintKeyFileName(_ name: String) -> Bool {
        guard name.hasPrefix(olderFingerprintKeyFilePrefix), name.hasSuffix(".json") else { return false }
        let middle = name.dropFirst(olderFingerprintKeyFilePrefix.count).dropLast(".json".count)
        return middle.count == 16 && middle.allSatisfy { "0123456789abcdef".contains($0) }
    }

    /// The first key-file-shaped file beside `store`, in a FIXED order (never by date): the store's own
    /// `<stem>.keys.json`, this design's `variorum-library-keys.json`, an older Variorum's fingerprint-named files (by
    /// name), then its fixed-name file. nil when none is there. Names only — no byte is read.
    static func keyFileBeside(_ store: URL) -> URL? {
        let manager = FileManager.default
        let folder = store.deletingLastPathComponent()
        let own = store.deletingPathExtension().appendingPathExtension("keys.json")
        if manager.fileExists(atPath: own.path) { return own }
        let thisDesigns = folder.appendingPathComponent(thisDesignsKeyFilename, isDirectory: false)
        if manager.fileExists(atPath: thisDesigns.path) { return thisDesigns }
        let names = ((try? manager.contentsOfDirectory(atPath: folder.path)) ?? []).sorted()
        if let older = names.first(where: isOlderFingerprintKeyFileName) {
            return folder.appendingPathComponent(older, isDirectory: false)
        }
        let legacy = folder.appendingPathComponent(olderKeyFilename, isDirectory: false)
        return manager.fileExists(atPath: legacy.path) ? legacy : nil
    }

    private static func classifyOpaque(_ store: URL) -> Verdict {
        if let keyFile = keyFileBeside(store) {
            return .encryptedLibrary(store: store, keyFile: keyFile)
        }
        // Nothing key-file-shaped serves it (corner 33's refusal).
        return .bareStoreWithoutKeyFile(store: store)
    }

    // MARK: - The plaintext arm (readable without any key)

    private static func classifyPlaintext(_ store: URL) -> Verdict {
        do {
            return try readPlaintext(store)
        } catch {
            return .unreadable(store, reason: String(describing: error))
        }
    }

    private static func readPlaintext(_ store: URL) throws -> Verdict {
        // The staged read (13x F3 — Q4): our copy, never the picked file;
        // the verdicts below still speak the PICKED URL.
        try withStagedRead(of: store, key: nil) { db in
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

    // MARK: - THE STAGED READ (13x F3 — ladder R3-1; the orchestrator's
    // rulings Q2–Q4, `notes/plans/phase-13x-library-portability.md`)

    /// Every SQLite read of a PICKED file happens here, on OUR copy — never
    /// on the picked file in place. Measured at F3 (the old tree): a
    /// read-only open of the picked store REWROTE (or created) the `-shm`
    /// beside it, and a failed first read (GRDB's `validateFormat` runs
    /// inside the open, so a wrong key fails there) took a read-write
    /// fallback whose close-time checkpoint folded the picked `-wal` into
    /// the picked MAIN FILE and deleted its sidecars — "the file you picked
    /// was only read" made false by the consult itself.
    ///
    /// The copy is the main file plus its non-empty `-wal` — the committed
    /// frames a hot-copied library carries, the SAME pair the landing
    /// carries (`PickedCopy.file`) — and NEVER its `-shm`: a
    /// rebuildable index, never trusted across a copy. It opens read-write
    /// (it is ours), so SQLite's own recovery rebuilds the index and folds
    /// the wal in exactly as the landing's reopen will: the consult reads
    /// what lands, wherever the picked copy sits (a non-writable folder
    /// included — nothing is ever written beside it).
    ///
    /// Home and residue (the Q3 ruling): its own per-consult, owner-only
    /// subdirectory of the per-user temporary directory, removed on every
    /// exit path by the `defer`s — only a crash mid-consult leaves one
    /// (ciphertext for an encrypted source; plaintext only when the picked
    /// file was already a plaintext file). `copyItem` clones on APFS;
    /// elsewhere the cost is one copy of the picked library at a deliberate
    /// door the user started (P1 binds steady state, not this act).
    static func withStagedRead<T>(
        of picked: URL, key: StoreKey?, _ body: (Database) throws -> T
    ) throws -> T {
        let fm = FileManager.default
        let stage = fm.temporaryDirectory.appendingPathComponent(
            "variorum-picked-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(
            at: stage, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        defer { try? fm.removeItem(at: stage) }
        let staged = stage.appendingPathComponent("picked.sqlite", isDirectory: false)
        try fm.copyItem(at: picked, to: staged)
        var stagedFiles = [staged]
        let wal = URL(fileURLWithPath: picked.path + "-wal")
        if let size = try? fm.attributesOfItem(atPath: wal.path)[.size] as? Int, size > 0 {
            let stagedWal = URL(fileURLWithPath: staged.path + "-wal")
            try fm.copyItem(at: wal, to: stagedWal)
            stagedFiles.append(stagedWal)
        }
        // A copy keeps the picked file's mode and flags; ours is owner
        // read-write (and never Finder-locked, so the cleanup can remove it).
        for file in stagedFiles {
            try? fm.setAttributes(
                [.immutable: false, .posixPermissions: 0o600], ofItemAtPath: file.path)
        }
        let queue = try DatabaseQueue(
            path: staged.path, configuration: AppDatabase.configuration(key: key))
        defer { try? queue.close() }
        return try queue.read(body)
    }

    // MARK: - Stage 2: the post-unlock schema consult

    /// What the OPEN road would meet (advisory, never the migrator's run):
    /// `.current` opens as-is, `.behindThisBuild` opens and migrates up,
    /// `.newer` is the honest refusal the door renders (the sync trace's
    /// item 5). The two failure classes are SEPARATE (13x F3, ladder R3-1
    /// constraint 3 — the old single `.unreadable` wore the wrong-key
    /// sentence for a torn copy and an unreachable `-shm` alike):
    /// `.keyRejected` is the ONE place "that key doesn't open this" is
    /// true; `.unreadable` is every other reason, carried for the detail.
    public enum SchemaVerdict: Equatable, Sendable {
        case current
        case behindThisBuild(unapplied: [String])
        case newer(unknownMigrations: [String])
        /// The key in hand does not open the file — VX-80's class letter
        /// (`AppDatabase.openStore`'s `keyRejected`): SQLCipher's first
        /// page read refused it (`SQLITE_NOTADB`) on an encrypted presence
        /// with a key in hand. (A ciphertext copy torn AT page 1 is
        /// indistinguishable from a wrong key by construction — as there.)
        case keyRejected
        /// Anything else that stops the read (a torn copy, an I/O failure,
        /// a staging copy that could not be made, a non-Variorum inside).
        case unreadable(reason: String)
    }

    /// `key` nil = a plaintext file (the export's consult).
    public static func schemaVerdict(at url: URL, key: StoreKey?) -> SchemaVerdict {
        do {
            return try withStagedRead(of: url, key: key) { db in
                let applied = try Set(String.fetchAll(
                    db, sql: "SELECT identifier FROM grdb_migrations"))
                let known = AppDatabase.migrator.migrations
                let unknown = applied.subtracting(known).sorted()
                if !unknown.isEmpty { return .newer(unknownMigrations: unknown) }
                let unapplied = known.filter { !applied.contains($0) }
                return unapplied.isEmpty ? .current : .behindThisBuild(unapplied: unapplied)
            }
        } catch let error as DatabaseError
            where key != nil && error.resultCode == .SQLITE_NOTADB
            && StoreFilePresence.classify(at: url) == .encryptedOrUnknown {
            return .keyRejected
        } catch {
            return .unreadable(reason: String(describing: error))
        }
    }
}
