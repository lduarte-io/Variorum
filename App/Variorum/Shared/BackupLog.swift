//
//  BackupLog.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, like StoreBackup)
//
//  Phase 13l, Act 4 (ledger rows 11–12) — what a backup run DID, kept so the
//  Data Safety face can answer without asking anything to run.
//
//  Her ruling at the kickoff: the freshness evidence is "the small face +
//  log". The face's load-bearing half reads the FILES (a folder's newest
//  snapshot cannot lie about when it was written, and a job that silently
//  stopped is exactly what that read catches). This log is the second half:
//  what the last runs attempted, where, and what the integrity check said —
//  the part the files themselves cannot tell you, because a run that FAILED
//  leaves no file at all.
//
//  Device-local, like the destination bookmark and for the same reason: a
//  run is a fact about one machine on one day, not document semantics.
//

import Foundation

/// One backup run's outcome. Codable so the log survives relaunch; every
/// field is a fact, never a rendered sentence (the face composes the words —
//  13s owns voice).
nonisolated struct BackupRunRecord: Codable, Sendable, Equatable, Identifiable {
    nonisolated enum Outcome: String, Codable, Sendable {
        /// A fresh snapshot was written here on this run.
        case written
        /// Nothing was due — the newest copy here is still fresh enough.
        case upToDate
        /// Nowhere to write: no folder picked, or the pick is unreachable.
        case noDestination
        /// It was attempted and it failed. `detail` says how.
        case failed
    }

    /// One destination's half of the run.
    nonisolated struct Leg: Codable, Sendable, Equatable {
        var outcome: Outcome
        /// The snapshot's filename, when one was written.
        var file: String?
        /// `PRAGMA integrity_check` on the file just written — "ok" or what
        /// SQLite said. nil when nothing was written to check.
        var integrity: String?
        /// Where this leg wrote, in her words (`~/Desktop/Variorum/Backups`).
        var destination: String?
        /// Files this leg's retention rule removed.
        var pruned: Int = 0
        var detail: String?

        var succeeded: Bool { outcome == .written || outcome == .upToDate }
        /// A written file whose integrity check did NOT say "ok" — the one
        /// outcome that looks like success and is not.
        var integrityFailed: Bool { integrity != nil && integrity != "ok" }
    }

    var id: String { at.timeIntervalSince1970.description }
    var at: Date
    var primary: Leg
    var secondary: Leg

    var everythingWorked: Bool {
        primary.succeeded && !primary.integrityFailed
            && (secondary.outcome == .noDestination
                || (secondary.succeeded && !secondary.integrityFailed))
    }
}

/// The last N runs, device-local. Deliberately tiny and deliberately not a
/// database table: it is diagnostic evidence about this machine, and putting
/// it in the store would make it sync, which would make one Mac's disk error
/// appear on the phone.
nonisolated enum BackupLog {
    static let defaultsKey = "variorum.backup.log"
    /// Enough to see a pattern (a fortnight of daily runs is 14), few enough
    /// that the face never needs paging.
    static let capacity = 20

    static func read(_ defaults: UserDefaults = .standard) -> [BackupRunRecord] {
        guard let data = defaults.data(forKey: defaultsKey),
              let records = try? JSONDecoder().decode([BackupRunRecord].self, from: data)
        else { return [] }
        return records
    }

    /// Newest first, capped. Append never throws: a log that cannot be
    /// written must never take a backup down with it.
    static func append(_ record: BackupRunRecord, to defaults: UserDefaults = .standard) {
        var records = read(defaults)
        records.insert(record, at: 0)
        if records.count > capacity { records.removeLast(records.count - capacity) }
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: defaultsKey)
    }

    static func clear(_ defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: defaultsKey)
    }
}
