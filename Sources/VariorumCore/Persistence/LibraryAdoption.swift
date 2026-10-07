import Foundation

// Phase 13x, U1 row 3 — THE ADOPT-BY-COPY MOVE-ASIDE BRAIN (her lean,
// direction-ruled at the kickoff sitting; mechanics PROVISIONAL P-U1-5).
// What happens on disk when an arriving copy becomes THE library: the
// current library and its key files step aside to a timestamped,
// recoverable home, an A1-shaped safety copy lands FIRST, and the copy —
// the SOURCE — is only ever read. No crypto, no custody, no sync: pure
// file mechanics the U2 door composes (the open roads, the custody rule
// and the restore-hold are the door's own steps around this).
//
// THE ORDER, load-bearing and pinned:
//   1. the source pair is verified readable (nothing is touched on a
//      refusal — a half-checked adoption changes nothing);
//   2. the live store must look CLOSED (a non-empty `-wal` refuses — the
//      lock-time copy's own rule; the door closes the pool first);
//   3. the A1-shaped SAFETY COPY: the closed store's bytes and every key
//      file beside it, into `Backups/safety-copies/
//      variorum-adopt-safety-<stamp>/` (the standing A1 rail's home);
//   4. the MOVE ASIDE: the store, its (quiet) sidecars and every key file
//      move WHOLE into `Previous Libraries/<stamp>/` — never deleted; the
//      old library's key files are its recovery legs and travel WITH it
//      (the custody-collision memo's consequence: after adoption the
//      moved-aside library opens by its own key-file roads);
//   5. the LANDING: the source store's bytes copied to the store path,
//      the source key file's bytes landed under its CANONICAL name
//      (`variorum-keys-<fp>.json` — a snapshot-pair-named key file is
//      normalized so `StoreKeyEnvelope.locate` finds it beside the
//      adopted library).
//
// The one non-atomic window (between 4 and 5): a crash there leaves no
// store at the path — the launch routes `libraryMissing` (§3.7, the lock
// stays) and the library is whole in BOTH the aside home and the safety
// copy. Recorded, not hidden.

public enum LibraryAdoption {
    /// Every URL one adoption will touch — pure, so the door can SAY what
    /// will happen before it does (and the pins can assert it).
    public struct Plan: Equatable, Sendable {
        /// The library's canonical place (what steps aside and where the
        /// copy lands).
        public var storeURL: URL
        /// The picked copy — read, never written.
        public var sourceStore: URL
        /// The key file that serves it (the classifier's verdict carries it).
        public var sourceKeyFile: URL
        /// Step 3's home: `Backups/safety-copies/variorum-adopt-safety-<stamp>/`.
        public var safetyCopyFolder: URL
        /// Step 4's home: `Previous Libraries/<stamp>/`.
        public var asideFolder: URL
        /// Step 5's landings.
        public var landedStore: URL
        public var landedKeyFile: URL
    }

    /// What one executed adoption did.
    public struct Receipt: Equatable, Sendable {
        public var plan: Plan
        /// The files that stepped aside (empty when no library stood here).
        public var movedAside: [URL]
        /// The safety copies written (empty when no library stood here).
        public var safetyCopied: [URL]
    }

    public enum AdoptionError: Error, Equatable {
        case sourceMissing(String)
        case sourceKeyFileMissing(String)
        /// The source key file exists but is not a readable key file.
        case sourceKeyFileUnreadable(String)
        /// A non-empty `-wal` beside the live store — the pool is not
        /// closed; the door must lock first.
        case libraryLooksOpen(String)
        /// Step 3 failed — NOTHING has moved; the library stands as it was.
        case safetyCopyFailed(String)
        /// Step 4 failed mid-move — the safety copy exists; what moved is
        /// in the aside folder, the rest in place. The message says both.
        case moveAsideFailed(String)
        /// Step 5 failed — the old library is whole in the aside home AND
        /// the safety copy; the store path may be empty (§3.7 routes it).
        case landingFailed(String)
    }

    /// The pure half: every URL, from the inputs and the clock alone.
    public static func plan(
        adopting sourceStore: URL, keyFile sourceKeyFile: URL,
        intoStoreAt storeURL: URL, now: Date
    ) -> Plan {
        let folder = storeURL.deletingLastPathComponent()
        let stamp = stampFormatter.string(from: now)
        let landedKeyFile: URL
        if let envelope = try? StoreKeyEnvelope.load(at: sourceKeyFile) {
            landedKeyFile = envelope.preferredURL(besideStore: storeURL)
        } else {
            // The execute step refuses an unreadable key file before
            // anything moves; this fallback only keeps `plan` total.
            landedKeyFile = folder.appendingPathComponent(
                sourceKeyFile.lastPathComponent, isDirectory: false)
        }
        return Plan(
            storeURL: storeURL,
            sourceStore: sourceStore,
            sourceKeyFile: sourceKeyFile,
            safetyCopyFolder: folder
                .appendingPathComponent("Backups", isDirectory: true)
                .appendingPathComponent("safety-copies", isDirectory: true)
                .appendingPathComponent("variorum-adopt-safety-\(stamp)", isDirectory: true),
            asideFolder: folder
                .appendingPathComponent("Previous Libraries", isDirectory: true)
                .appendingPathComponent(stamp, isDirectory: true),
            landedStore: storeURL,
            landedKeyFile: landedKeyFile)
    }

    /// The acting half. Blocking (library-sized copies) — callers run it
    /// off the main thread with the pool CLOSED.
    @discardableResult
    public static func execute(_ plan: Plan) throws -> Receipt {
        let fm = FileManager.default

        // 1. The source pair, verified readable — before anything changes.
        guard fm.fileExists(atPath: plan.sourceStore.path) else {
            throw AdoptionError.sourceMissing(plan.sourceStore.path)
        }
        guard fm.fileExists(atPath: plan.sourceKeyFile.path) else {
            throw AdoptionError.sourceKeyFileMissing(plan.sourceKeyFile.path)
        }
        let sourceKeyFileBytes: Data
        do {
            let loaded = try StoreKeyEnvelope.load(at: plan.sourceKeyFile)
            guard loaded != nil else {
                throw AdoptionError.sourceKeyFileMissing(plan.sourceKeyFile.path)
            }
            sourceKeyFileBytes = try Data(contentsOf: plan.sourceKeyFile)
        } catch let error as AdoptionError {
            throw error
        } catch {
            throw AdoptionError.sourceKeyFileUnreadable(String(describing: error))
        }

        // 2. The live store must look closed.
        let liveExists = fm.fileExists(atPath: plan.storeURL.path)
        let wal = URL(fileURLWithPath: plan.storeURL.path + "-wal")
        if liveExists,
           let size = try? fm.attributesOfItem(atPath: wal.path)[.size] as? Int, size > 0 {
            throw AdoptionError.libraryLooksOpen(wal.path)
        }

        // What steps aside: the store, its quiet sidecars, every key file.
        var departing: [URL] = []
        if liveExists {
            departing.append(plan.storeURL)
            for suffix in ["-wal", "-shm"] {
                let sidecar = URL(fileURLWithPath: plan.storeURL.path + suffix)
                if fm.fileExists(atPath: sidecar.path) { departing.append(sidecar) }
            }
            departing.append(contentsOf: StoreKeyEnvelope.keyFileURLs(besideStore: plan.storeURL))
        }

        // 3. The A1-shaped safety copy — FIRST, so every later step has a
        //    second net. A failure here aborts with nothing moved.
        var safetyCopied: [URL] = []
        if !departing.isEmpty {
            do {
                try fm.createDirectory(at: plan.safetyCopyFolder, withIntermediateDirectories: true)
                for file in departing {
                    let destination = plan.safetyCopyFolder
                        .appendingPathComponent(file.lastPathComponent, isDirectory: false)
                    try fm.copyItem(at: file, to: destination)
                    safetyCopied.append(destination)
                }
            } catch {
                throw AdoptionError.safetyCopyFailed(String(describing: error))
            }
        }

        // 4. The move aside — whole files, never deleted.
        var movedAside: [URL] = []
        if !departing.isEmpty {
            do {
                try fm.createDirectory(at: plan.asideFolder, withIntermediateDirectories: true)
                for file in departing {
                    let destination = plan.asideFolder
                        .appendingPathComponent(file.lastPathComponent, isDirectory: false)
                    try fm.moveItem(at: file, to: destination)
                    movedAside.append(destination)
                }
            } catch {
                throw AdoptionError.moveAsideFailed(
                    "moved \(movedAside.count) of \(departing.count): \(String(describing: error))")
            }
        }

        // 5. The landing — the source is COPIED, never moved.
        do {
            try fm.createDirectory(
                at: plan.landedStore.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fm.copyItem(at: plan.sourceStore, to: plan.landedStore)
            try sourceKeyFileBytes.write(to: plan.landedKeyFile, options: .atomic)
        } catch {
            throw AdoptionError.landingFailed(String(describing: error))
        }

        return Receipt(plan: plan, movedAside: movedAside, safetyCopied: safetyCopied)
    }

    /// `yyyy-MM-dd-HHmmss` UTC — the backup stamps' own shape.
    nonisolated(unsafe) private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
