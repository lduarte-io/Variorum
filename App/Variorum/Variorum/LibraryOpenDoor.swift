//
//  LibraryOpenDoor.swift
//  Variorum (Mac)
//
//  Phase 13x, U2 rows 6+7 — THE DOORS' MAC FACES: the presenter (one per
//  scene — the main window's serves File ▸ Open Library… and the lobby
//  faces; Settings' serves Restore from Backup…), the sheet that renders
//  the one Shared flow (`LibraryOpenModel`), and the RESTORE-HOLD BANNER
//  (round 3's landing state — the bottom-bar idiom beside
//  `ProtectionNoticeBar`, a standing bar until the one Resume press).
//  Every sentence is `LibraryOpenCopy`'s (PROVISIONAL; 13s re-voices).
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

/// One scene's door state: holds the flow model while a flow runs; the
/// scene attaches ONE sheet over it (two scenes = two presenters, so the
/// main window's sheet and Settings' can never both fire).
@MainActor
@Observable
final class LibraryOpenPresenter {
    var model: LibraryOpenModel?
    /// VX-306 U3 — the two doors on the NEW road (nil on today's road): a picked copy's flow, or a Restore row's
    /// Make this my library. Today's adoption step is retired behind it there (today's road keeps `model`).
    var roadDoors: CopyDoorsModel?

    /// The File-menu / face door: pick a thing, then run the one flow.
    func openPanel(bootstrap: AppBootstrap) {
        guard model == nil, roadDoors == nil else { return }
        let panel = NSOpenPanel()
        panel.title = LibraryOpenCopy.sheetTitle
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        // The one open format plus the folder pair (QC) — anything else
        // classifies honestly rather than being unpickable.
        panel.allowedContentTypes = [.folder, .data]
        guard panel.runModal() == .OK, let picked = panel.url else { return }
        begin(bootstrap: bootstrap, picked: picked)
    }

    /// VX-306 U3 — a Restore row's *Make this my library…* on the new road.
    func beginMakeMine(roads: CopyDoorsRoads, row: CopyDoorRow) {
        guard model == nil, roadDoors == nil else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        Task { await fresh.openMakeMine(row) }
    }

    func dismissRoad() {
        roadDoors = nil
    }

    /// The restore surface's per-row door (the source already known).
    func begin(bootstrap: AppBootstrap, picked: URL) {
        let fresh = LibraryOpenModel(bootstrap: bootstrap)
        model = fresh
        fresh.begin(picked: picked)
    }

    func dismiss() {
        model = nil
    }
}

/// 13x F1 (ladder R1-MAJOR) — the HAND-OFF door's presenter: one per
/// scene (the File menu's and Settings' twin), the open-door pattern,
/// the destination panel's seam split from the act so the pins drive
/// `begin` directly (the picker-pin precedent).
@MainActor
@Observable
final class LibraryHandOffPresenter {
    var model: LibraryHandOffModel?

    /// The destination panel, then the one flow.
    func openPanel(session: AppSession?, bootstrap: AppBootstrap) {
        guard model == nil, let session,
              let storeURL = bootstrap.liveStoreURL else { return }
        let panel = NSOpenPanel()
        panel.title = LibraryOpenCopy.handOffSheetTitle
        panel.message = LibraryOpenCopy.handOffPanelMessage
        panel.prompt = LibraryOpenCopy.handOffPanelPrompt
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.urls(
            for: .downloadsDirectory, in: .userDomainMask).first
        guard panel.runModal() == .OK, let picked = panel.url else { return }
        begin(session: session, storeURL: storeURL, into: picked)
    }

    func begin(session: AppSession, storeURL: URL, into parent: URL) {
        let fresh = LibraryHandOffModel(reveal: { folder in
            NSWorkspace.shared.activateFileViewerSelecting([folder])
        })
        model = fresh
        Task {
            await fresh.begin(
                database: session.database, storeURL: storeURL, into: parent)
        }
    }

    func dismiss() { model = nil }
}

/// The hand-off's one face: producing → done (QC's teaching +
/// Show in Finder) → or the worded refusal.
struct LibraryHandOffSheet: View {
    @Bindable var model: LibraryHandOffModel
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(LibraryOpenCopy.handOffSheetTitle)
                .font(.title3.weight(.semibold))
            switch model.phase {
            case .producing:
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text(LibraryOpenCopy.handOffProducingLine)
                        .foregroundStyle(.secondary)
                }
            case .done(let folder):
                Text(LibraryOpenCopy.handOffDoneLead(folder: folder.lastPathComponent))
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer()
                    Button(LibraryOpenCopy.handOffRevealDoor) { model.revealAgain() }
                    Button("Done") { onClose() }
                        .keyboardShortcut(.defaultAction)
                }
            case .refused(let message, let detail):
                Text(message)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack { Spacer(); Button("Close") { onClose() } }
            }
        }
        .padding(22)
        .frame(minWidth: 460, alignment: .leading)
    }
}

/// The flow's one face — phases rendered plainly; the voice tokens are
/// the session's where one exists, the fallback elsewhere (the lobby).
struct LibraryOpenSheet: View {
    @Bindable var model: LibraryOpenModel
    var onClose: () -> Void

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(LibraryOpenCopy.sheetTitle)
                .font(.title3.weight(.semibold))
            switch model.phase {
            case .classifying:
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text(LibraryOpenCopy.classifyingLine).foregroundStyle(.secondary)
                }
            case .refused(let message, let detail):
                Text(message)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack { Spacer(); Button("Close") { onClose() } }
            case .choosing(let stores):
                Text(LibraryOpenCopy.severalStoresLead)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(stores, id: \.self) { store in
                    Button(store.lastPathComponent) { model.choose(store) }
                }
                HStack { Spacer(); Button("Cancel") { onClose() } }
            case .unlock:
                Text(LibraryOpenCopy.unlockLead)
                    .fixedSize(horizontal: false, vertical: true)
                if model.passphraseOffered {
                    PeekableSecretField(
                        label: "Encryption passphrase", text: $passphrase,
                        onSubmit: { submitPassphrase() })
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }
                if model.recoveryOffered {
                    DisclosureGroup(isExpanded: $showsRecoveryRoad) {
                        TextField(
                            "The 12 recovery words, separated by spaces",
                            text: $recoveryText, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .autocorrectionDisabled()
                            .privacySensitive()
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 360)
                        Button("Unlock with Recovery Phrase") { submitRecovery() }
                            .disabled(model.busy || recoveryText.trimmingCharacters(
                                in: .whitespacesAndNewlines).isEmpty)
                    } label: {
                        Text(LibraryOpenCopy.unlockWordsDoor)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 360)
                }
                if let error = model.lastError {
                    Text(error)
                        .font(.caption)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                if model.showsOfflineNote {
                    Text(ProtectionCopy.lobbyOfflineNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Spacer()
                    Button("Cancel") { onClose() }
                    if model.passphraseOffered {
                        Button("Unlock") { submitPassphrase() }
                            .keyboardShortcut(.defaultAction)
                            .disabled(model.busy || passphrase.isEmpty)
                    }
                }
            case .confirm:
                Text(LibraryOpenCopy.confirmLead)
                    .font(.callout.weight(.semibold))
                // VX-209: the current library is Castle and this copy is
                // not — said before the press, in the alarm voice the Castle
                // notices speak in (PROVISIONAL placement).
                if model.leavesCastle {
                    Text(LibraryOpenCopy.confirmLeavesCastle)
                        .font(.caption)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(model.willStepAside
                     ? LibraryOpenCopy.confirmStepAside
                     : LibraryOpenCopy.confirmFreshSlot)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if model.isPlaintextRoad {
                    Text(LibraryOpenCopy.confirmPlaintext)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if model.sourceInICloudDrive {
                    Text(LibraryOpenCopy.sourceInICloudDriveLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(LibraryOpenCopy.confirmSyncWaits)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer()
                    Button("Cancel") { onClose() }
                    Button(LibraryOpenCopy.confirmDoor) {
                        Task { await model.confirmAdoption() }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy)
                }
            case .adopting:
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text(LibraryOpenCopy.adoptingLine).foregroundStyle(.secondary)
                }
            case .done:
                // The reopen is already routing; the sheet leaves.
                Color.clear.frame(height: 1)
                    .onAppear { onClose() }
            }
        }
        .padding(22)
        .frame(minWidth: 460, alignment: .leading)
    }

    private func submitPassphrase() {
        let typed = passphrase
        passphrase = ""
        Task { await model.unlock(passphrase: typed) }
    }

    private func submitRecovery() {
        let text = recoveryText
        recoveryText = ""
        Task { await model.unlock(recoveryText: text) }
    }
}

/// THE RESTORE-HOLD BANNER (round 3's ruled landing state): a standing
/// bottom bar on the adopted library — the ruled sentence + the ONE
/// Resume press; no dismiss (the hold IS the state; Resume ends it).
struct RestoreHoldBar: View {
    @Bindable var model: RestoreHoldModel
    /// Whether this Mac belongs to an account, read by the composition
    /// root at render (W-4) — the banner's account clause only.
    var hasAccount = true

    var body: some View {
        if model.isHeld {
            HStack(spacing: 10) {
                // The line limit is load-bearing (the b6dae25 class, W-2):
                // this bar is non-scrolling window chrome, and without it
                // the window's near-zero-width minimum-size probe measures
                // the sentence one character per line.
                Text(LibraryOpenCopy.holdBanner(
                    asOfDay: model.asOfDay, hasAccount: hasAccount))
                    .font(.caption)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button(LibraryOpenCopy.resumeSyncDoor) {
                    Task { await model.resume() }
                }
                .disabled(model.resuming)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
        }
    }
}
