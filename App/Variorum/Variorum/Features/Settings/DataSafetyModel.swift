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
    /// 13l Act 5 (row 17): the sync-status face's two sources — the
    /// scheduler's in-memory status, and a local read of the outbox + pull
    /// cursor. READ-SIDE ONLY: nothing here triggers or configures a round.
    private let sync: SyncSession?
    private let signedIn: () -> Bool
    private let database: AppDatabase?

    private(set) var primary: FolderSummary?
    private(set) var destination: Destination = .unset
    /// 13l Act 5 (row 16): the plain-text exports in the picked folder, read
    /// from the folder for the same reason the snapshots are — a schedule
    /// can stop silently; a folder's newest entry cannot lie about its date.
    private(set) var exports: FolderSummary?
    private(set) var log: [BackupRunRecord] = []
    /// 13p Batch 2 (R13p-8's rider — the opt-in FACE's state): whether the
    /// automatic weekly plain-text export is on. OFF by default since the
    /// library became encrypted; the toggle below is the ONE door.
    private(set) var insuranceEnabled = false
    /// 13l Act 5 (row 17): the local half of the sync facts, refreshed with
    /// everything else. nil until the first refresh (or when there is no
    /// store to read).
    private(set) var syncFacts: SyncSafetyFacts?
    private(set) var busy = false
    /// The last thing an act had to say — a receipt or a refusal, never a
    /// silent outcome (P-2's letter applied to a Settings pane).
    private(set) var note: String?
    /// 13x U2 row 6 — the Restore surface's rows: the in-container
    /// folder's snapshot pairs with their which-credential facts and the
    /// same-fingerprint second look (`BackupRestoreCandidates`).
    private(set) var restoreCandidates: [BackupRestoreCandidates.Candidate] = []

    init(
        backup: StoreBackup?,
        defaults: @escaping @Sendable () -> UserDefaults = { .standard },
        sync: SyncSession? = nil,
        database: AppDatabase? = nil,
        signedIn: @escaping () -> Bool = { false }
    ) {
        self.backup = backup
        self.defaults = defaults
        self.sync = sync
        self.database = database
        self.signedIn = signedIn
    }

    /// True when this app can back up at all — false only when the store
    /// opened but the services did not (Settings reached before the main
    /// window's composition). Honest rather than a face full of dashes.
    var isWired: Bool { backup != nil }

    // MARK: - Reading the evidence

    func refresh() async {
        await refreshSyncFacts()
        guard let backup else { return }
        let directory = backup.directory
        let defaults = self.defaults
        // 13x U2 row 6: the live key's fingerprint for the second look
        // (nil — locked, plaintext-era — just never lights it).
        let liveFingerprint = database?.storeKeyFingerprint
        let read = await Task.detached(priority: .utility) {
            let store = defaults()
            return (primary: DataSafetyModel.summarize(directory),
                    secondary: DataSafetyModel.summarizeSecondDestination(in: store),
                    exports: DataSafetyModel.summarizeExports(in: store),
                    log: BackupLog.read(store),
                    insurance: MarkdownInsurance.isEnabled(in: store),
                    candidates: BackupRestoreCandidates.gather(
                        in: directory, liveKeyFingerprint: liveFingerprint))
        }.value
        primary = read.primary
        destination = read.secondary
        exports = read.exports
        log = read.log
        insuranceEnabled = read.insurance
        restoreCandidates = read.candidates
    }

    /// 13p Batch 2: the opt-in's act. Turning it ON runs a backup pass so
    /// the first export lands while she is looking (the chooseFolder
    /// seed-immediately precedent); turning it OFF writes nothing more —
    /// existing files stay until their own retention would have taken
    /// them, and the face says so.
    ///
    /// **18k C5 (17e P38): it takes the pane's ONE latch, like its three
    /// siblings.** Turning it on runs a forced backup, and without `busy` the
    /// pane left Back Up Now and the folder doors live over that run (the
    /// toggle itself greys while theirs run — `DataSafetyPane`). The run
    /// itself is single-flight in `StoreBackup` whatever reaches it; this is
    /// the pane saying so with its own doors.
    func setInsurance(_ enabled: Bool) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        let defaults = self.defaults
        await Task.detached(priority: .utility) {
            MarkdownInsurance.setEnabled(enabled, in: defaults())
        }.value
        insuranceEnabled = enabled
        if enabled, let backup {
            let record = await backup.backUpNow()
            note = Self.receipt(record)
        }
        await refresh()
    }

    /// 13l Act 5 (row 17). Two facts come from the store (the outbox's size,
    /// the pull cursor) and three from the session; the store read goes
    /// through the reader pool off-main like every other read (P2). A
    /// FAILED read leaves the facts nil and the section says nothing — a
    /// data-safety face that invents a reassuring line when it could not
    /// read is worse than one that stays quiet.
    private func refreshSyncFacts() async {
        guard let sync else { return }
        var local: (pending: Int, cursor: Int64?) = (0, nil)
        if let database {
            local = (try? await database.read { db in
                try SyncSafetyFacts.read(db)
            }) ?? (0, nil)
        }
        syncFacts = SyncSafetyFacts(
            allowsSync: sync.allowsSync,
            isConfigured: sync.isConfigured,
            signedIn: signedIn(),
            pending: local.pending,
            cursor: local.cursor,
            lastSuccessAt: sync.status.lastSuccessAt)
    }

    /// 18o U1 (row 84): `newest` and `oldest` — the face's freshness and its
    /// reach — read only stamps no later than `now` (`StoreBackup
    /// .stampIsTrusted`, the due-checks' one rule): a copy stamped ahead of
    /// the clock is COUNTED (it is a real file) but never shown as the
    /// newest, so it can no longer hold the row out of the stale colour while
    /// the copies it can trust grow old.
    nonisolated static func summarize(_ directory: URL, now: Date = Date()) -> FolderSummary {
        let display = BackupDestination.displayPath(directory)
        guard FileManager.default.fileExists(atPath: directory.path) else {
            return FolderSummary(displayPath: display, exists: false, count: 0)
        }
        let dated = ((try? StoreBackup.existingBackups(in: directory)) ?? [])
            .compactMap(StoreBackup.date(fromBackupURL:))
        let trusted = dated.filter { StoreBackup.stampIsTrusted($0, now: now) }
        return FolderSummary(
            displayPath: display, exists: true, count: dated.count,
            newest: trusted.max(), oldest: trusted.min())
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

    /// 13l Act 5 (row 16): the plain-text exports, read from the folder.
    /// nil = there is no picked folder, which is also the only state in
    /// which no export can exist (the insurance writes only there — see
    /// `MarkdownInsurance`'s header for why).
    nonisolated static func summarizeExports(
        in defaults: UserDefaults, now: Date = Date()
    ) -> FolderSummary? {
        guard BackupDestination.isSet(in: defaults),
              let resolved = BackupDestination.resolve(in: defaults)
        else { return nil }
        let folder = MarkdownInsurance.exportsFolder(in: resolved.picked)
        return BackupDestination.withAccess(to: resolved.picked) {
            let display = BackupDestination.displayPath(folder)
            guard FileManager.default.fileExists(atPath: folder.path) else {
                return FolderSummary(displayPath: display, exists: false, count: 0)
            }
            let dated = ((try? MarkdownInsurance.existingExports(in: folder)) ?? [])
                .compactMap(MarkdownInsurance.date(fromExportURL:))
            // 18o U1 (row 84): the snapshots' rule (`summarize`, above).
            let trusted = dated.filter { StoreBackup.stampIsTrusted($0, now: now) }
            return FolderSummary(
                displayPath: display, exists: true, count: dated.count,
                newest: trusted.max(), oldest: trusted.min())
        }
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
        // 13x U2 row 9 (pre-13x ledger 4; copy §8's recorded note): the
        // live library's own folder — or one that contains it — is never
        // a backup destination; the refusal renders copy §6's why-not
        // sentence (`ProtectionCopy.liveLibraryNotInICloudDrive`, its ONE
        // home). The store's folder is the backup directory's parent by
        // construction (`AppServices` composes `<store folder>/Backups`).
        if let backup,
           LibraryPlacementGuard.isLiveLibraryFolder(
               picked,
               storeURL: backup.directory.deletingLastPathComponent()
                   .appendingPathComponent("variorum.sqlite", isDirectory: false)) {
            note = LibraryOpenCopy.pickedLiveLibraryFolderRefusal
            return
        }
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
        case .disabled:
            // Unreachable for the snapshot legs (nothing turns them off);
            // exhaustiveness keeps the compiler honest if that ever changes.
            break
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
        case .noDestination, .disabled:
            break
        }
        // 13l Act 5 (row 16): the plain-text leg. Silent when it was
        // up to date — a weekly job would otherwise say "nothing due" in
        // six receipts out of seven, and a log line that always reads the
        // same is a line nobody reads.
        switch record.markdown?.outcome {
        case .written:
            let count = record.markdown?.files ?? 0
            parts.append("Plain-text copy written (\(count) file\(count == 1 ? "" : "s")).")
        case .failed:
            parts.append("Plain-text copy: \(record.markdown?.detail ?? "unknown").")
        case .upToDate, .noDestination, nil:
            break
        case .disabled:
            // 13p (R13p-8's rider): off by default is the designed state —
            // silent in the receipt, exactly like "nothing due". Batch 2's
            // opt-in face is where the setting speaks.
            break
        }
        return parts.joined(separator: " ")
    }
}
