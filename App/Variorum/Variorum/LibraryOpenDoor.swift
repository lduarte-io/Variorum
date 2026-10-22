//
//  LibraryOpenDoor.swift
//  Variorum (Mac)
//
//  Phase 13x, U2 rows 6+7 — THE DOORS' MAC FACES: the presenter (one per
//  scene — the main window's serves File ▸ Open Library… and the lobby
//  faces; Settings' serves Restore from Backup…), the hand-off's presenter
//  and sheet, and the RESTORE-HOLD BANNER (round 3's landing state — a
//  standing bar until the one Resume press). VX-306 U3 → VX-329 U1: the
//  doors are the protection road's copy doors (`CopyDoorsModel` — rule 17);
//  13x's adoption flow and its sheet left with today's road.
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
    /// VX-306 U3 — the two doors: a picked copy's flow, or a Restore row's Make this my library.
    var roadDoors: CopyDoorsModel?

    /// The File-menu / face door: pick a thing, then run the one flow.
    func openPanel(bootstrap: AppBootstrap) {
        guard roadDoors == nil else { return }
        let panel = NSOpenPanel()
        panel.title = LibraryOpenCopy.sheetTitle
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        // The one open format plus the folder pair (QC) — anything else
        // classifies honestly rather than being unpickable.
        panel.allowedContentTypes = [.folder, .data]
        guard panel.runModal() == .OK, let picked = panel.url else { return }
        // VX-306 U3: a picked copy is filed first and the two doors act on it (P-VX306-U3-0 (a)) — with a library open
        // both doors; with none (the missing face, rule 27's lobby) Look inside and the empty-slot landing (T-5).
        guard let roads = bootstrap.copyDoorsRoads() ?? bootstrap.copyDoorsRoadsWithoutALibrary() else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        Task { await fresh.begin(picked: picked) }
    }

    /// VX-309 U1b — the faces with NO library open (the missing face, rule 27's lobby) on the new road: their *Restore from
    /// Backup…* opens this Mac's catalogued copies with each row's doors (rule 17: "The app's Restore from Backup is this
    /// door") — Look inside, and Make this my library into the empty slot (T-5).
    func openRestoreList(bootstrap: AppBootstrap) {
        guard roadDoors == nil, let roads = bootstrap.copyDoorsRoadsWithoutALibrary() else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        Task { await fresh.beginListing() }
    }

    /// VX-306 U3 — a Restore row's *Look inside…* on the new road (P-VX306-U3-15).
    func beginLookInside(roads: CopyDoorsRoads, row: CopyDoorRow) {
        guard roadDoors == nil else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        Task { await fresh.openLookInside(row) }
    }

    /// VX-306 U3 — a Restore row's *Make this my library…* on the new road.
    func beginMakeMine(roads: CopyDoorsRoads, row: CopyDoorRow) {
        guard roadDoors == nil else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        Task { await fresh.openMakeMine(row) }
    }

    /// VX-309 U1c — VX-265: a Restore row's *Delete…* on the new road (rule 19's confirm; the list re-reads on the
    /// copies-changed seam once the copies went).
    func beginDeleteCopies(roads: CopyDoorsRoads, choice: CopyDeleteChoice) {
        guard roadDoors == nil else { return }
        let fresh = CopyDoorsModel(roads: roads)
        roadDoors = fresh
        fresh.openDeleteCopies(choice)
    }

    func dismissRoad() {
        // A look standing is forgotten (its reader closed, its private folder deleted) whatever closed the sheet.
        roadDoors?.close()
        roadDoors = nil
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
        guard model == nil, session != nil else { return }
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
        begin(bootstrap: bootstrap, into: picked)
    }

    func begin(bootstrap: AppBootstrap, into parent: URL) {
        let fresh = LibraryHandOffModel(reveal: { folder in
            NSWorkspace.shared.activateFileViewerSelecting([folder])
        })
        model = fresh
        Task {
            // The bootstrap lives as long as the app; the act is one bounded send.
            await fresh.begin(into: parent) { parent in await bootstrap.sendLibrary(into: parent) }
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

/// THE RESTORE-HOLD BANNER (round 3's ruled landing state): a standing
/// bottom bar on the adopted library — the ruled sentence + the ONE
/// Resume press; no dismiss (the hold IS the state; Resume ends it).
struct RestoreHoldBar: View {
    @Bindable var model: RestoreHoldModel
    /// Whether the OPEN LIBRARY syncs with an account (VX-473 — its record,
    /// never this Mac's sign-in), read by the composition root at render
    /// (W-4) — the banner's account clause only.
    var hasAccount = true

    var body: some View {
        if model.isHeld {
            HStack(spacing: 10) {
                // The line limit is load-bearing (the b6dae25 class, W-2):
                // this bar is non-scrolling window chrome, and without it
                // the window's near-zero-width minimum-size probe measures
                // the sentence one character per line.
                VStack(alignment: .leading, spacing: 4) {
                    Text(LibraryOpenCopy.holdBanner(
                        asOfDay: model.asOfDay, hasAccount: hasAccount))
                        .font(.caption)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                    // VX-339: a Resume that could not remove the marker says
                    // so here, and the banner stays (the hold still stands).
                    // Line-limited for the same minimum-size reason.
                    if let failure = model.resumeFailure {
                        Text(failure)
                            .font(.caption.weight(.semibold))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
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
