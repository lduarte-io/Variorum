//
//  DataSafetyModel.swift
//  Variorum
//
//  Phase 13l, Act 4 (ledger row 12) — the Data Safety face's projection.
//
//  Her kickoff ruling: the freshness evidence is "the small face + log", and
//  "Back Up Now…" is an ADJUNCT, never the load-bearing mechanism. So the
//  face's own load-bearing half is a READ OF THE FILES: how many snapshots
//  each destination holds, when the newest one was taken, how far back the
//  kept set reaches. A schedule can stop silently; a folder's newest file
//  cannot lie about its date, and that read is what catches the failure this
//  whole phase exists to kill.
//
//  The persisted log (`BackupLog`) is the second half — it is the only thing
//  that can report a run which produced NO file (an unplugged drive, a
//  revoked folder), because a failure leaves nothing behind to read.
//
//  No business rules live here: retention is `BackupRetention` (pure), the
//  run is `StoreBackup`, the destination is `BackupDestination`. This holds
//  a projection and calls them.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class DataSafetyModel {
    /// What one backup folder holds, right now, read from the folder itself.
    nonisolated struct FolderSummary: Sendable, Equatable {
        var displayPath: String
        var exists: Bool
        var count: Int
        var newest: Date?
        var oldest: Date?
    }

    /// Nothing picked yet, a pick we can no longer reach, or a live one.
    enum Destination: Equatable {
        case unset
        case unreachable
        case set(displayPath: String, summary: FolderSummary)
    }

    private let backup: StoreBackup?
    /// A PROVIDER, not the object: `UserDefaults` is not `Sendable` and the
    /// folder reads happen off-main (P2 — a folder on a sleeping external
    /// drive can block for seconds).
    private let defaults: @Sendable () -> UserDefaults

    private(set) var primary: FolderSummary?
    private(set) var destination: Destination = .unset
    private(set) var log: [BackupRunRecord] = []
    private(set) var busy = false
    /// The last thing an act had to say — a receipt or a refusal, never a
    /// silent outcome (P-2's letter applied to a Settings pane).
    private(set) var note: String?

    init(
        backup: StoreBackup?,
        defaults: @escaping @Sendable () -> UserDefaults = { .standard }
    ) {
        self.backup = backup
        self.defaults = defaults
    }

    /// True when this app can back up at all — false only when the store
    /// opened but the services did not (Settings reached before the main
    /// window's composition). Honest rather than a face full of dashes.
    var isWired: Bool { backup != nil }

    // MARK: - Reading the evidence

    func refresh() async {
        guard let backup else { return }
        let directory = backup.directory
        let defaults = self.defaults
        let read = await Task.detached(priority: .utility) {
            let store = defaults()
            return (primary: DataSafetyModel.summarize(directory),
                    secondary: DataSafetyModel.summarizeSecondDestination(in: store),
                    log: BackupLog.read(store))
        }.value
        primary = read.primary
        destination = read.secondary
        log = read.log
    }

    nonisolated static func summarize(_ directory: URL) -> FolderSummary {
        let display = BackupDestination.displayPath(directory)
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return FolderSummary(displayPath: display, exists: false, count: 0)
        }
        let dated = ((try? StoreBackup.existingBackups(in: directory)) ?? [])
            .compactMap(StoreBackup.date(fromBackupURL:))
        return FolderSummary(
            displayPath: display, exists: true, count: dated.count,
            newest: dated.max(), oldest: dated.min())
    }

    nonisolated static func summarizeSecondDestination(
        in defaults: UserDefaults
    ) -> Destination {
        guard BackupDestination.isSet(in: defaults) else { return .unset }
        guard let resolved = BackupDestination.resolve(in: defaults) else {
            return .unreachable
        }
        let folder = BackupDestination.backupsFolder(in: resolved.picked)
        let summary = BackupDestination.withAccess(to: resolved.picked) {
            summarize(folder)
        }
        return .set(
            displayPath: BackupDestination.displayPath(resolved.picked),
            summary: summary)
    }

    // MARK: - The acts

    /// `.chooseBackupFolder` — and it SEEDS immediately. Picking a folder
    /// and then waiting up to a day for the first copy to appear would make
    /// the face say "no copies yet" about a folder she just chose, which
    /// reads as broken. One forced run puts a snapshot there while she is
    /// still looking at the pane.
    func chooseFolder() async {
        guard !busy else { return }
        guard let picked = ExportPanels.chooseFolder(
            prompt: "Use This Folder") else { return }
        busy = true
        defer { busy = false }
        do {
            try BackupDestination.remember(picked, in: defaults())
        } catch {
            note = error.localizedDescription
            return
        }
        let record = await backup?.backUpNow()
        await refresh()
        note = record.map(Self.receipt) ?? "Folder set."
    }

    /// `.forgetBackupFolder` — stops copying there. It never deletes what is
    /// already in the folder: those copies are hers, and a settings toggle
    /// that quietly removed backups would be the opposite of this phase.
    func forgetFolder() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        BackupDestination.forget(in: defaults())
        await refresh()
        note = "Copies stop going there. The copies already in that folder stay where they are."
    }

    /// `.backUpNow` — the adjunct door.
    func backUpNow() async {
        guard !busy, let backup else { return }
        busy = true
        defer { busy = false }
        let record = await backup.backUpNow()
        await refresh()
        note = Self.receipt(record)
    }

    // MARK: - Receipts (facts, worded; 13s owns the voice)

    nonisolated static func receipt(_ record: BackupRunRecord) -> String {
        var parts: [String] = []
        switch record.primary.outcome {
        case .written where record.primary.integrityFailed:
            parts.append("Copied here, but the check on the copy said “\(record.primary.integrity ?? "")”.")
        case .written:
            parts.append("Copied, checked, ok.")
        case .upToDate:
            parts.append("Already up to date here.")
        case .failed:
            parts.append("The copy beside your library failed: \(record.primary.detail ?? "unknown").")
        case .noDestination:
            parts.append("No place to copy to.")
        }
        switch record.secondary.outcome {
        case .written where record.secondary.integrityFailed:
            parts.append("Copied to your folder, but the check there said “\(record.secondary.integrity ?? "")”.")
        case .written:
            parts.append("Copied to your folder too\(record.secondary.pruned > 0 ? ", \(record.secondary.pruned) old \(record.secondary.pruned == 1 ? "copy" : "copies") retired" : "").")
        case .upToDate:
            parts.append("Your folder already has today's copy.")
        case .failed:
            parts.append("Your folder: \(record.secondary.detail ?? "unknown").")
        case .noDestination:
            break
        }
        return parts.joined(separator: " ")
    }
}
