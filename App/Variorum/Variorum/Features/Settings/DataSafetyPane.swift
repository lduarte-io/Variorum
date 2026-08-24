//
//  DataSafetyPane.swift
//  Variorum
//
//  Phase 13l, Act 4 (ledger row 12) — Settings ▸ Data Safety.
//
//  Her kickoff ruling, in one line: **the small face + log** — last backup
//  time, destination, last integrity result, "Back Up Now…" as an adjunct,
//  the full log behind it. The slots for Act 5's two items (the automated
//  `.md` export and the sync-status line) are deliberately NOT rendered as
//  empty rows: a face that says "Last export: —" about a feature that does
//  not exist is a lie in the shape of a placeholder (P-2).
//
//  This pane is also the app's RESTORE FACE — the place where restoring is
//  discussed — because restoring itself is a Finder operation, not a button
//  (§3 of the runbook: quit, swap the file, open). So the warning pair her
//  post-sitting ruling requires ("we need to tell the user it clearly either
//  way") lives here, beside the copies it is about.
//

import SwiftUI
import VariorumCore

struct DataSafetyPane: View {
    let services: AppServices?
    @State private var model: DataSafetyModel

    /// P-1: the three acts this surface renders, declared once and walked.
    static let surfaceCapabilities: [CapabilityID] = [
        .backUpNow, .chooseBackupFolder, .forgetBackupFolder,
    ]

    init(services: AppServices?) {
        self.services = services
        _model = State(initialValue: DataSafetyModel(backup: services?.backup))
    }

    var body: some View {
        Form {
            if model.isWired {
                copiesSection
                folderSection
                restoreSection
                logSection
            } else {
                Section("Backups") {
                    Text("Open the main window — backups run with the app.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .task { await model.refresh() }
    }

    // MARK: - The evidence

    private var copiesSection: some View {
        Section("Copies of your library") {
            if let primary = model.primary {
                folderRow(
                    title: "Beside your library",
                    path: primary.displayPath, summary: primary)
            }
            HStack {
                Button(CapabilityRegistry.capability(.backUpNow).verb) {
                    Task { await model.backUpNow() }
                }
                .disabled(model.busy)
                if model.busy { ProgressView().controlSize(.small) }
                Spacer()
            }
            Text("Variorum copies your library once a day while it is open. "
                 + "A day the app stayed closed has no copy — which is why the dates above "
                 + "matter more than the schedule does.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let note = model.note {
                Text(note).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var folderSection: some View {
        Section("A second folder") {
            switch model.destination {
            case .unset:
                Text("Not set. The copies above are on this disk, beside the library "
                     + "they copy — so they survive a mistake, but not the disk. "
                     + "Pick a folder somewhere else: an external drive, or a folder "
                     + "your cloud service syncs.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            case .unreachable:
                Text("The folder you picked can't be reached — it may have moved, "
                     + "been renamed, or be on a disconnected drive. Nothing has been "
                     + "copied there since. Pick it again.")
                    .font(.callout)
                    .foregroundStyle(.orange)
            case .set(let displayPath, let summary):
                folderRow(title: displayPath, path: summary.displayPath, summary: summary)
                Text("Kept there: the 14 most recent days that have a copy, plus one "
                     + "copy from each of the 4 weeks before those.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Button(model.destination == .unset
                       ? CapabilityRegistry.capability(.chooseBackupFolder).verb
                       : "Change Folder…") {
                    Task { await model.chooseFolder() }
                }
                .disabled(model.busy)
                if model.destination != .unset {
                    Button(CapabilityRegistry.capability(.forgetBackupFolder).verb) {
                        Task { await model.forgetFolder() }
                    }
                    .disabled(model.busy)
                }
                Spacer()
            }
        }
    }

    private func folderRow(
        title: String, path: String, summary: DataSafetyModel.FolderSummary
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.callout)
            Text(path)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .truncationMode(.middle)
            if summary.count == 0 {
                Text("No copies here yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(Self.freshness(summary))
                    .font(.caption)
                    .foregroundStyle(summary.isStale ? AnyShapeStyle(Color.orange) : AnyShapeStyle(.secondary))
            }
        }
    }

    // MARK: - Restoring (the warning pair — her post-sitting ruling)

    private var restoreSection: some View {
        Section("Restoring a copy") {
            Text("Restoring is a Finder operation, not a button: quit Variorum, move "
                 + "the current library file aside, put the copy in its place, open "
                 + "Variorum. The step-by-step is in **\(DataSafetyCopy.runbookFilename)**, "
                 + "which sits in every backup folder above.")
                .font(.callout)
            Text(syncing
                 ? DataSafetyCopy.syncedRestoreWarning
                 : DataSafetyCopy.localRestoreWarning)
                .font(.callout)
            Text(syncing
                 ? DataSafetyCopy.localRestoreWarning
                 : DataSafetyCopy.syncedRestoreWarning)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(DataSafetyCopy.bothSidedDeletionTruth)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// Which warning leads. Both are always shown — she may sign in later,
    /// and a warning that appears only after the fact is not a warning.
    private var syncing: Bool {
        guard let services else { return false }
        return services.sync.allowsSync && services.sync.isConfigured
    }

    // MARK: - The log (behind the face, per her ruling)

    private var logSection: some View {
        Section {
            DisclosureGroup("Backup log") {
                if model.log.isEmpty {
                    Text("Nothing recorded yet on this Mac.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.log, id: \.id) { (record: BackupRunRecord) in
                        VStack(alignment: .leading, spacing: 1) {
                            Text(record.at.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                            Text(DataSafetyModel.receipt(record))
                                .font(.caption)
                                .foregroundStyle(record.everythingWorked ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.orange))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Words for a folder's state

    static func freshness(_ summary: DataSafetyModel.FolderSummary) -> String {
        var parts: [String] = []
        if let newest = summary.newest {
            parts.append("Newest: \(newest.formatted(date: .abbreviated, time: .shortened))")
        }
        parts.append("\(summary.count) \(summary.count == 1 ? "copy" : "copies")")
        if let oldest = summary.oldest, summary.count > 1 {
            parts.append("back to \(oldest.formatted(date: .abbreviated, time: .omitted))")
        }
        return parts.joined(separator: " · ")
    }
}

extension DataSafetyModel.FolderSummary {
    /// Older than two days is worth a colour: the job runs daily while the
    /// app is open, so two days means either the app was closed or something
    /// stopped — and the whole point of this face is that she finds out
    /// which without having to wonder.
    var isStale: Bool {
        guard let newest else { return true }
        return Date().timeIntervalSince(newest) > 2 * 24 * 60 * 60
    }
}
