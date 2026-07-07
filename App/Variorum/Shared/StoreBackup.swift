//
//  StoreBackup.swift
//  Variorum (shared; wired on the Mac — the phone's store is re-derivable
//  from the mirror)
//
//  Phase 8, A1 — rotating cold copies (author decision 2026-07-06):
//  Supabase is a live MIRROR, not a backup — a destructive bug replicates
//  faithfully. These copies are the missing net: on launch and daily while
//  running, one consistent snapshot via SQLite's backup API (safe under
//  WAL), kept to a cap, pruned oldest-first. Restore stays manual — point
//  the recoverable-open path at a copy; the restore DRILL is Phase 12's.
//

import Foundation
import VariorumCore

@MainActor
final class StoreBackup {
    struct Configuration: Sendable {
        /// A new copy when the newest is older than this (launch + daily).
        var interval: TimeInterval = 24 * 60 * 60
        /// Copies kept; older ones pruned.
        var keep: Int = 14
    }

    nonisolated static let filePrefix = "variorum-backup-"
    nonisolated static let fileExtension = "sqlite"

    private let database: AppDatabase
    private let directory: URL
    private let configuration: Configuration
    /// Injectable clock (tests) — the default is the wall clock.
    private let now: @Sendable () -> Date
    private var timerTask: Task<Void, Never>?
    private(set) var lastError: String?

    init(
        database: AppDatabase,
        directory: URL,
        configuration: Configuration = Configuration(),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.database = database
        self.directory = directory
        self.configuration = configuration
        self.now = now
    }

    /// Launch + daily while running: one due-check now, then hourly
    /// re-checks (cheap directory stat; the interval decides if a copy is
    /// actually written).
    func start(recheckEvery recheck: Duration = .seconds(60 * 60)) {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.backupIfDue()
                do { try await Task.sleep(for: recheck) } catch { return }
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
    }

    /// Writes a copy when the newest existing one is older than the
    /// interval (or none exists). Off the main thread (P2).
    func backupIfDue() async {
        let database = database
        let directory = directory
        let configuration = configuration
        let stamp = now()
        do {
            _ = try await Task.detached(priority: .utility) {
                try StoreBackup.performBackupIfDue(
                    database: database, directory: directory,
                    configuration: configuration, now: stamp)
            }.value
            lastError = nil
        } catch {
            // A failed backup must never take the app down — surfaced,
            // retried on the next check.
            lastError = String(describing: error)
        }
    }

    // MARK: - The blocking worker (off-main by contract)

    /// Returns the new copy's URL, or nil when the newest copy is fresh
    /// enough. Static + nonisolated so tests drive it deterministically.
    @discardableResult
    nonisolated static func performBackupIfDue(
        database: AppDatabase, directory: URL,
        configuration: Configuration, now: Date
    ) throws -> URL? {
        dispatchPrecondition(condition: .notOnQueue(.main))
        if let newest = try existingBackups(in: directory).last,
           let newestDate = date(fromBackupURL: newest),
           now.timeIntervalSince(newestDate) < configuration.interval {
            return nil
        }
        let url = directory.appendingPathComponent(
            "\(filePrefix)\(stampFormatter.string(from: now)).\(fileExtension)")
        try database.backup(to: url)
        try prune(directory: directory, keep: configuration.keep)
        return url
    }

    /// Oldest-first pruning down to `keep` (names sort chronologically —
    /// the stamp format is lexicographic).
    nonisolated static func prune(directory: URL, keep: Int) throws {
        let backups = try existingBackups(in: directory)
        guard backups.count > keep else { return }
        for url in backups.dropLast(keep) {
            try FileManager.default.removeItem(at: url)
        }
    }

    /// This directory's backup files, oldest first.
    nonisolated static func existingBackups(in directory: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter {
                $0.lastPathComponent.hasPrefix(filePrefix)
                    && $0.pathExtension == fileExtension
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    nonisolated static func date(fromBackupURL url: URL) -> Date? {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix(filePrefix) else { return nil }
        return stampFormatter.date(from: String(name.dropFirst(filePrefix.count)))
    }

    /// Filename-safe, lexicographically chronological. (DateFormatter is
    /// documented thread-safe for formatting on modern OS versions.)
    nonisolated private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
