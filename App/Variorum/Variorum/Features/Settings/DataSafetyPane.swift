//
//  DataSafetyPane.swift
//  Variorum
//
//  Phase 13l, Act 4 (ledger row 12) — Settings ▸ Data Safety.
//
//  Her kickoff ruling, in one line: **the small face + log** — last backup
//  time, destination, last integrity result, "Back Up Now…" as an adjunct,
//  the full log behind it.
//
//  Phase 13l, Act 5 — the two slots ruling 3 named are FILLED, and neither
//  was a placeholder waiting to be populated (Act 4 declined to render them
//  empty, P-2): "Plain-text copies" (row 16) and "Your account" (row 17).
//  Row 17 renders NO doors and is not meant to: the sync row in the main
//  window is where syncing is acted on; this is evidence, and its job is to
//  answer "is anything I have written still only on this Mac".
//
//  This pane is also the app's RESTORE FACE — the place where restoring is
//  discussed, beside the Restore list (rule 17's doors over this Mac's
//  copies). So the warning pair her post-sitting ruling requires ("we need
//  to tell the user it clearly either way") lives here, beside the copies it
//  is about. VX-329 U1: today's rows (the flat-backup Restore list, the
//  posture lines read from today's controller) left with today's road; the
//  decrypted export authorizes against the open library's key file.
//

import AppKit
import SwiftUI
import VariorumCore

struct DataSafetyPane: View {
    let services: AppServices?
    @State private var model: DataSafetyModel

    /// P-1: the five acts this surface renders, declared once and walked
    /// (pre-13x 3b: the decrypted export joins; 13x F1 R1-MAJOR: the
    /// hand-off twin joins).
    static let surfaceCapabilities: [CapabilityID] = [
        .backUpNow, .chooseBackupFolder, .forgetBackupFolder, .exportPlaintextLibrary,
        .handOffLibrary,
    ]

    /// pre-13x 3b (copy §4): the decrypted export's brain, made when the door
    /// opens; nil = the door.
    @State private var plaintextExport: PlaintextExportModel?
    @State private var exportPassphrase = ""

    /// 13x F1 (R1-MAJOR): the hand-off act's Data Safety twin — Settings'
    /// own presenter acts; nil hosts render no door (P-2).
    let handOffDoor: (() -> Void)?
    /// VX-306 U3 — the Restore list: the catalogue's copies with their doors (nil hosts: no list).
    let roadDoors: RoadDoorsHost?
    @State private var roadList: CopyDoorsListModel?
    /// VX-307 U2c (VX-379's pane rows; U2a's F-6): the open library's protection faces — the Castle warning reads ITS
    /// posture, the decrypted export its key file (nil hosts: neither).
    let roadStanding: RoadStandingModel?

    init(
        services: AppServices?,
        handOffDoor: (() -> Void)? = nil,
        roadDoors: RoadDoorsHost? = nil,
        roadStanding: RoadStandingModel? = nil
    ) {
        self.services = services
        self.handOffDoor = handOffDoor
        self.roadDoors = roadDoors
        self.roadStanding = roadStanding
        _model = State(initialValue: DataSafetyModel(
            backup: services?.backup,
            sync: services?.sync,
            database: services?.session.database,
            // A closure rather than a captured value: the pane can outlive a
            // sign-in, and the facts are re-read on every refresh.
            signedIn: { services?.account.variorum != nil },
            // VX-309 U1a (VX-397): this Mac's pairs of this library per place.
            roadCounts: roadStanding?.copyCounts))
    }

    var body: some View {
        Form {
            if model.isWired {
                copiesSection
                if let roadList, let roadDoors {
                    RoadRestoreRows(
                        list: roadList, lookInside: roadDoors.lookInside, makeMine: roadDoors.makeMine,
                        deleteCopies: roadDoors.deleteCopies)
                }
                handOffSection
                folderSection
                exportsSection
                plaintextExportSection
                syncSection
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
        .task {
            await model.refresh()
            // VX-306 U3: the list, re-read at each appearance (a reopen rebuilds the pane).
            if let roadDoors {
                let list = roadList ?? CopyDoorsListModel(roads: roadDoors.roads)
                roadList = list
                await list.refresh()
            }
        }
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
            // VX-309 U2 (F-U2c-4, F-U1a-3 — PROVISIONAL P-VX309-U2-9): what the counts are (this Mac's pairs of this
            // library — VX-397) and what opens a backup (rule 5's sentence).
            if roadStanding != nil {
                Text(ProtectionWords.dataSafetyTheCountsAreThisMacs)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(ProtectionWords.dataSafetyWhatOpensABackup)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let note = model.note {
                Text(note).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Moving to another Mac (13x F1, R1-MAJOR — deliverable 1's twin)

    /// The hand-off act's Data Safety face: one sentence saying what the
    /// folder is and how it is used, and the ONE declared door (the File
    /// menu renders the same act). Settings' own presenter runs the
    /// panel + flow + sheet.
    @ViewBuilder
    private var handOffSection: some View {
        if let handOffDoor {
            Section(LibraryOpenCopy.handOffSectionTitle) {
                Text(LibraryOpenCopy.handOffSectionBody)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button(CapabilityRegistry.capability(.handOffLibrary).verb) {
                        handOffDoor()
                    }
                    .disabled(model.busy)
                    Spacer()
                }
            }
        }
    }

    private var folderSection: some View {
        Section(DataSafetyCopy.secondFolderSection) {
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
                // VX-309 U2 (F-U1a-3): one pair a day goes there (P-VX309-U1a-2) — said beside the retention line.
                Text(ProtectionWords.dataSafetySecondFolderKept)
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

    // MARK: - Plain text (13l Act 5, row 16)

    /// The `.md` insurance's evidence. It has NO door of its own,
    /// deliberately: the manual bulk export already exists in the Library
    /// (⌘K "Export Library…"), and a second button here would be a second
    /// road to the same act — while the road this section is about is the
    /// automatic one, whose whole failure mode is that a manual button feels
    /// like enough.
    @ViewBuilder
    private var exportsSection: some View {
        Section("Plain-text copies") {
            // 13p Batch 2 (R13p-8's rider): THE opt-in — the one deliberate
            // plaintext escape, off by default, a setting rather than a
            // button (the gate is checked before force in the run itself).
            Toggle("Keep a weekly plain-text copy of every note", isOn: Binding(
                get: { model.insuranceEnabled },
                set: { on in Task { await model.setInsurance(on) } }))
                // 18k C5 (P38): greyed while any of the pane's acts runs, as
                // its three siblings are (its own run holds `busy` too).
                .disabled(model.busy
                    || (model.destination == .unset && !model.insuranceEnabled))
            if model.destination == .unset && !model.insuranceEnabled {
                Text("Pick a second folder above first — the plain-text copies "
                     + "only ever go there.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if Self.castleWarningShows(roadPosture: roadPosture) {
                // R13p-8's rider: under a locked-down posture the warning
                // speaks whether she is about to turn it on or already has.
                // VX-307 U2c (U2a's F-6): in rule 11's words, over the OPEN
                // library's posture.
                Text(ProtectionCopy.plaintextExportUnderLockedDown)
                    .font(.caption)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let exports = model.exports {
                folderRow(
                    title: "Every note as Markdown",
                    path: exports.displayPath, summary: exports,
                    // While the option is OFF an old export is a fact, not
                    // an alarm — the stale colour would train her to
                    // ignore it (the option being off IS the explanation).
                    staleAfter: model.insuranceEnabled
                        ? Self.exportStaleAfter : .infinity)
                if !model.insuranceEnabled && exports.count > 0 {
                    Text("The automatic export is off — the files above are from "
                         + "when it was on, and stay until you remove them.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("Written weekly while the option is on — off by default "
                     + "now that your library is encrypted, because a scheduled "
                     + "plain-text copy re-opens the door encryption closed. The "
                     + "4 most recent are kept. When on, this is the copy that "
                     + "survives a problem with the library file itself — plain "
                     + "text any program can open, no Variorum required.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Note that these are readable by anything that can read the folder — "
                     + "including whatever syncs it, if you picked a cloud folder.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Variorum can also keep a plain-text copy of every note in a folder "
                     + "you pick — the copy that survives a problem with the library "
                     + "file itself. It is off by default now that your library is "
                     + "encrypted; the manual Export Library command is always there.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - The decrypted export (pre-13x 3b — decision 15; copy §4)

    /// Copy §4's *Export an unencrypted copy of your library.* — the
    /// authorization by posture (Castle: the passphrase; Standard: the
    /// passphrase if set, else *Export* directly — checked against the open
    /// library's key file), a chosen destination (never the backups folder),
    /// the export off the main actor. Rendered only when the open library's
    /// faces and the store are composed (P-2).
    @ViewBuilder
    private var plaintextExportSection: some View {
        if let roadStanding, let services {
            Section(ProtectionCopy.exportPlaintextTitle) {
                Text(ProtectionCopy.exportPlaintextBody)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
                if let export = plaintextExport {
                    switch export.phase {
                    case .authorize(let needsPassphrase):
                        if needsPassphrase {
                            Text(ProtectionCopy.exportPlaintextAuthorize)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $exportPassphrase)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Button(needsPassphrase ? ProtectionCopy.exportPlaintextChooseDoor : ProtectionCopy.exportPlaintextPlainDoor) {
                                let typed = exportPassphrase
                                exportPassphrase = ""
                                Task {
                                    await export.authorize(passphrase: needsPassphrase ? typed : nil)
                                    if case .choosing = export.phase { await chooseExportDestination(export) }
                                }
                            }
                            .disabled(export.busy || (needsPassphrase && exportPassphrase.isEmpty))
                            Button("Cancel") { plaintextExport = nil; exportPassphrase = "" }
                            Spacer()
                        }
                    case .choosing:
                        HStack {
                            Button(ProtectionCopy.exportPlaintextChooseDoor) {
                                Task { await chooseExportDestination(export) }
                            }
                            .disabled(export.busy)
                            Button("Cancel") { plaintextExport = nil }
                            Spacer()
                        }
                    case .exporting:
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text("Writing the unencrypted copy…").font(.caption).foregroundStyle(.secondary)
                        }
                    case .done(let path):
                        Text("Written: \(path)").font(.caption).foregroundStyle(.secondary)
                        Button("Close") { plaintextExport = nil }
                    case .failed(let sentence):
                        Text(sentence).font(.caption).alarmVoice()
                            .fixedSize(horizontal: false, vertical: true)
                        Button("Close") { plaintextExport = nil }
                    }
                    if let error = export.lastError {
                        Text(error).font(.caption).alarmVoice()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    Button(CapabilityRegistry.capability(.exportPlaintextLibrary).verb) {
                        plaintextExport = PlaintextExportModel(facts: exportFacts(standing: roadStanding, services: services))
                    }
                    .disabled(model.busy)
                }
            }
        }
    }

    /// The facts the export composes (VX-329 U1 — PROVISIONAL P-VX329-U1-2): the open library's posture and whether
    /// its key file carries a passphrase lock; the typed passphrase checked against that key file (rule 7 — a synced
    /// library's pair IS the account's); the refused folders (the app's own backups, beside the library and in the
    /// picked second folder); the export over the session's database, off-main.
    private func exportFacts(standing: RoadStandingModel, services: AppServices) -> PlaintextExportModel.Facts {
        let database = services.session.database
        return PlaintextExportModel.Facts(
            isCastle: { standing.posture == .castle },
            hasPassphrase: { standing.passphraseIsSet },
            verifyPassphrase: { typed in
                switch await standing.checkPassphrase(typed) {
                case true?: return .match
                case false?: return .mismatch(ProtectionCopy.wrongPassphraseRefusal)
                case nil: return .couldNotCheck("no passphrase is set on this library")
                }
            },
            refusedFolders: {
                var folders: [URL] = []
                if let backup = services.backup { folders.append(backup.directory) }
                if let resolved = BackupDestination.resolve(in: .standard) {
                    folders.append(BackupDestination.variorumFolder(in: resolved.picked))
                }
                return folders
            },
            export: { destination in
                try await Task.detached(priority: .userInitiated) {
                    try StorePlaintextExport.export(from: database, to: destination)
                }.value
            })
    }

    /// The save panel: a user-chosen destination, defaulting away from the
    /// backups folder; the model refuses one inside it.
    @MainActor
    private func chooseExportDestination(_ export: PlaintextExportModel) async {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Variorum-unencrypted.sqlite"
        panel.canCreateDirectories = true
        panel.title = ProtectionCopy.exportPlaintextTitle
        guard await panel.begin() == .OK, let url = panel.url else { return }
        await export.export(to: url)
    }

    // MARK: - Syncing (13l Act 5, row 17 — evidence only, no doors)

    @ViewBuilder
    private var syncSection: some View {
        if let facts = model.syncFacts {
            let face = SyncSafetyFace.face(facts)
            Section("Your account") {
                // Ledger row 31, her words: *"a gentle green on fully synced
                // might look nice"*. The TONE is the standing's own decision
                // (shared with the phone), and it is worn through the voice's
                // vocabulary — the literal `Color.orange` that used to stand
                // for "not calm" is gone, and signed-out stays quiet, which
                // her #75(d) ratification asked for and a two-way `isCalm`
                // could not express.
                Group {
                    switch face.tone {
                    case .settled: Text(face.headline).positiveVoice()
                    case .attention: Text(face.headline).alarmVoice()
                    case .quiet: Text(face.headline)
                    }
                }
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(face.details, id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    /// `staleAfter` is the row's own idea of overdue, because the two jobs
    /// have different cadences (13l Act 5): a snapshot is daily, so two days
    /// is late; a plain-text export is weekly, so two days is normal and
    /// colouring it would train her to ignore the colour.
    private func folderRow(
        title: String, path: String, summary: DataSafetyModel.FolderSummary,
        staleAfter: TimeInterval = DataSafetyPane.snapshotStaleAfter
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
                    .foregroundStyle(summary.isStale(after: staleAfter)
                                     ? AnyShapeStyle(Color.orange) : AnyShapeStyle(.secondary))
            }
        }
    }

    /// Two days: the snapshot job runs daily while the app is open, so two
    /// days means either the app was closed or something stopped. A guess,
    /// flagged at QUESTIONS #74(c).
    static let snapshotStaleAfter: TimeInterval = 2 * 24 * 60 * 60
    /// Nine days: the export job runs weekly, plus a couple of days' slack
    /// for a week the app was mostly closed. The same guess, one cadence up
    /// (#75).
    static let exportStaleAfter: TimeInterval = 9 * 24 * 60 * 60

    // MARK: - Restoring (the warning pair — her post-sitting ruling)

    private var restoreSection: some View {
        Section("Restoring a copy") {
            // No markdown emphasis here: this string is INTERPOLATED, and an
            // interpolated `Text` is not a `LocalizedStringKey`, so `**…**`
            // renders as literal asterisks. Caught in the drill's own
            // screenshot of this pane.
            // (The Restore list above says what restoring is in its own lead — `restoreListLead`, rule 17.)
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

    /// VX-307 U2c — the open library's posture (nil: no library's faces composed).
    private var roadPosture: ProtectionMode? { roadStanding?.posture }

    /// VX-307 U2c (U2a's F-6): whether the Castle warning shows — by the open library's posture. Pure — pinned.
    static func castleWarningShows(roadPosture: ProtectionMode?) -> Bool {
        roadPosture == .castle
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
    /// Older than the caller's cadence is worth a colour — the whole point
    /// of this face is that she finds out a job stopped without having to
    /// wonder. 13l Act 5 made the threshold a PARAMETER because the pane now
    /// shows two jobs with two cadences; the snapshot's two days is
    /// unchanged (`DataSafetyPane.snapshotStaleAfter`).
    ///
    /// 18o U1 (row 84): a newest stamped LATER than now reads stale too — the
    /// summaries never hand one over any more (they read only trusted
    /// stamps), and this is the belt: a future date is never evidence of
    /// freshness (`StoreBackup.stampIsTrusted`).
    func isStale(after interval: TimeInterval, now: Date = Date()) -> Bool {
        guard let newest, StoreBackup.stampIsTrusted(newest, now: now) else { return true }
        return now.timeIntervalSince(newest) > interval
    }
}
