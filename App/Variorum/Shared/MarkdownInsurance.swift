//
//  MarkdownInsurance.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, like StoreBackup)
//
//  Phase 13l, Act 5 (ledger row 16) — THE PLAIN-TEXT INSURANCE, automated.
//
//  The brief's scope item 3, in her kickoff's words: both candidates IN —
//  "the bulk-`.md` plaintext insurance (automated, to the backup
//  destination)". The gesture already exists (11b's one-gesture bulk library
//  export); what did not exist was a schedule, so the insurance only helped
//  on days she remembered it. This is that schedule.
//
//  WHY IT IS ITS OWN FILE, NAMED THIS. Everything else Variorum writes
//  outside the store is either the store itself (a `.sqlite` snapshot, which
//  is exactly as readable or unreadable as the store) or ciphertext on the
//  mirror. THIS writes her prose to disk as plain text, on a timer, into a
//  folder that may be cloud-synced. That is a deliberate trade — a
//  SQLite-eating disaster still leaves prose — and it is the ONE such escape
//  in the app. Phase 13p (note protection) has to be able to FIND it in one
//  grep and decide what it does about protected notes; a run folded into
//  `StoreBackup` or a face's view model would have been findable only by
//  someone who already knew. The runbook's §2 names the trade in words.
//
//  It rides `StoreBackup`'s existing run rather than minting a second clock:
//  one hourly tick, one run record, one log, one face. Its DUE-NESS is its
//  own (weekly, not daily), so on six days out of seven the leg answers
//  `.upToDate` and costs a directory listing.
//
//  CADENCE + RETENTION ARE **PROVISIONAL** (QUESTIONS #75): weekly, keep 4.
//  The brief left both unruled and named the lean; these are that lean.
//

import Foundation
import VariorumCore

nonisolated enum MarkdownInsurance {
    /// PROVISIONAL (#75) — the brief's recorded lean, implemented.
    struct Policy: Sendable, Equatable {
        /// A fresh export when the newest is older than this.
        var interval: TimeInterval = 7 * 24 * 60 * 60
        /// Export folders kept; older ones pruned whole.
        var keep: Int = 4

        static let standard = Policy()
    }

    /// The subfolder inside `<picked>/Variorum/`, beside `Backups/`.
    static let folderName = "md-exports"

    // MARK: - The 13p default flip (R13p-8's rider, author verbatim: "the
    // automatic plaintext backup is going to be ended 13p, when encryption
    // is added, since it weakens encryption. i think it can still be
    // available to users that want it, but it should be off by default once
    // encryption is present.")
    //
    // Encryption is present from Batch 1 on — every store `openStore`
    // touches is keyed — so the AUTOMATIC weekly export is OFF unless the
    // user turns it on. Batch 2 builds the opt-in face (and the
    // Locked-down warning sentence that a scheduled plain-text export
    // re-opens the door the encryption closed); this key is what that face
    // flips. Device-local like the destination bookmark, and for the same
    // reason.

    /// The opt-in's defaults key.
    static let enabledDefaultsKey = "variorum.backup.markdownInsurance.enabled"

    /// OFF unless deliberately turned on — the R13p-8 rider's letter.
    static func isEnabled(in defaults: UserDefaults) -> Bool {
        defaults.bool(forKey: enabledDefaultsKey)
    }

    static func setEnabled(_ enabled: Bool, in defaults: UserDefaults) {
        defaults.set(enabled, forKey: enabledDefaultsKey)
    }

    /// `<picked>/Variorum/md-exports` — one export per dated subfolder.
    static func exportsFolder(in picked: URL) -> URL {
        BackupDestination.variorumFolder(in: picked)
            .appendingPathComponent(folderName, isDirectory: true)
    }

    // MARK: - The run (one leg of the backup run — see the file header)

    /// Writes one dated export folder when one is due, prunes to the
    /// policy, and reports. NEVER throws, for `StoreBackup`'s reason: an
    /// unplugged drive is a thing to SAY, not a thing to crash on.
    ///
    /// **No picked folder ⇒ `.noDestination`, and nothing is written.**
    /// Deliberate, and the brief's letter ("to the picked destination's
    /// `md-exports/` subfolder"): a plain-text copy inside the app's own
    /// sandbox container would sit on the same disk as the store, in a
    /// folder she has no reason to open, and would die with the container it
    /// is insuring against. The face says the folder is what turns this on.
    /// The alternative (a container copy when nothing is picked) is recorded
    /// at #75.
    static func performRun(
        database: AppDatabase, defaults: UserDefaults,
        policy: Policy = .standard, now: Date, force: Bool
    ) -> BackupRunRecord.Leg {
        dispatchPrecondition(condition: .notOnQueue(.main))
        // The 13p gate, FIRST — before the destination is even consulted,
        // and before `force`: with the option off, Back Up Now must not
        // write plaintext either (the door is the setting, not the button).
        guard isEnabled(in: defaults) else {
            return BackupRunRecord.Leg(outcome: .disabled)
        }
        var leg = BackupRunRecord.Leg(outcome: .noDestination)
        guard BackupDestination.isSet(in: defaults) else { return leg }
        guard let resolved = BackupDestination.resolve(in: defaults) else {
            // The same wording as the snapshot leg's: one cause, one
            // sentence, whichever leg noticed first.
            leg.outcome = .failed
            leg.detail = "The backup folder can't be found — it may have moved, "
                + "been renamed, or be on a disconnected drive. Pick it again."
            return leg
        }
        let target = exportsFolder(in: resolved.picked)
        return BackupDestination.withAccess(to: resolved.picked) {
            performExport(
                database: database, into: target, policy: policy, now: now, force: force)
        }
    }

    /// The act itself, given a folder that is already reachable. Split from
    /// `performRun` above so the two concerns separate — finding the
    /// destination is one thing, exporting into it is another — and so this
    /// half is drivable by a test with a plain temp directory, which a
    /// security-scoped bookmark is not.
    static func performExport(
        database: AppDatabase, into target: URL,
        policy: Policy = .standard, now: Date, force: Bool
    ) -> BackupRunRecord.Leg {
        var leg = BackupRunRecord.Leg(outcome: .noDestination)
        leg.destination = BackupDestination.displayPath(target)
        do {
            // 18o U1 (row 84): the newest export stamped no later than now —
            // the snapshots' one rule (`StoreBackup.stampIsTrusted`): a
            // future-dated folder is not evidence of freshness.
            let newest = try existingExports(in: target).reversed().lazy
                .compactMap { url in self.date(fromExportURL: url).map { (url: url, date: $0) } }
                .first { StoreBackup.stampIsTrusted($0.date, now: now) }
            if !force, let newest,
               now.timeIntervalSince(newest.date) < policy.interval {
                leg.outcome = .upToDate
                leg.file = newest.url.lastPathComponent
                return leg
            }
            // The manifest is the CORE's projection, unchanged and
            // unduplicated — one-way, nothing written to the store.
            let manifest = try database.read { db in
                try Queries.bulkExportManifest(db)
            }
            let folder = target.appendingPathComponent(
                stampFormatter.string(from: now), isDirectory: true)
            try FileManager.default.createDirectory(
                at: folder, withIntermediateDirectories: true)
            leg.files = try ExportWriter.write(manifest, to: folder)
            leg.outcome = .written
            leg.file = folder.lastPathComponent
            leg.pruned = try prune(in: target, keep: policy.keep)
        } catch {
            leg.outcome = .failed
            leg.detail = String(describing: error)
        }
        return leg
    }

    // MARK: - Retention (whole folders, oldest first)

    /// Removes export folders beyond `keep`, oldest first. Returns how many
    /// went. Deliberately simpler than the far folder's 14+4 rule (`Retention`): these
    /// are bulky (a copy of every note) and their job is "the most recent
    /// prose exists in plain text", not reach into the past — the snapshots
    /// beside them are what reach.
    @discardableResult
    static func prune(in directory: URL, keep: Int) throws -> Int {
        let folders = try existingExports(in: directory)
        guard folders.count > keep else { return 0 }
        let doomed = folders.dropLast(keep)
        for url in doomed { try FileManager.default.removeItem(at: url) }
        return doomed.count
    }

    /// This directory's export folders, oldest first (the stamp format is
    /// lexicographic, exactly like the snapshots' names).
    static func existingExports(in directory: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { date(fromExportURL: $0) != nil }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static func date(fromExportURL url: URL) -> Date? {
        stampFormatter.date(from: url.lastPathComponent)
    }

    /// The snapshots' stamp format exactly (UTC, filename-safe,
    /// lexicographically chronological) — one convention for everything the
    /// app writes into a backup folder, so the two listings sort alike.
    private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
