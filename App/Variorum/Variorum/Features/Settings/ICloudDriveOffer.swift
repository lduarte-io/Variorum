//
//  ICloudDriveOffer.swift
//  Variorum (MAC ONLY — the phone has no picked-folder road: `StoreBackup`
//  is not wired there and `BackupDestination.remember` refuses on iOS by
//  design)
//
//  pre-13x batch 5b, item 0(a) — THE iCLOUD DRIVE OFFER (design §1 decision
//  24: "Backups may be kept in iCloud Drive (the offer at the first backup
//  run); the LIVE library never lives there"; copy §6's title, body, the
//  addendum by posture and the three doors; ledger 64 — a ruled decision no
//  earlier brief owned, found by 5a's copy walk).
//
//  ONE sheet, ONCE per store, at the FIRST backup run, over the 13l
//  picked-folder machinery (`BackupDestination`): *Use iCloud Drive* opens
//  the folder picker ALREADY POINTED at iCloud Drive's root and remembers
//  the pick as the second destination (the backups then land at
//  `<pick>/Variorum/Backups` — the 13l folder shape inside the pick);
//  *Choose Another Folder…* is the existing picker; *Not Now* marks the
//  offer asked. Never again after any door.
//
//  WHY THE PICKER AND NOT A WRITE: the app is SANDBOXED (see
//  `BackupDestination`'s header), so nothing here may write into
//  `~/Library/Mobile Documents/com~apple~CloudDocs` on its own — a
//  user-selected folder is the only sandbox-legal road to a folder outside
//  the container, and `NSOpenPanel.directoryURL` is the hint the powerbox
//  honors. A cancelled panel (iCloud Drive absent on this Mac, or the user
//  backing out) leaves the sheet OPEN with one line and the mark UNSET —
//  *Not Now* is the door that answers the question.
//
//  THE MARK is per store VARIANT (the `SampleLibrarySeeded.<variant>` shape:
//  Debug and Release share a defaults domain, so an unscoped key would let
//  a dev-store offer suppress the real store's). A store that ALREADY has
//  a second folder picked when its first run lands is marked silently —
//  the question is answered by the pick that exists.
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class ICloudDriveOfferModel {
    /// The injectable seams (production: `Leaves.live`; the pins: scripted —
    /// no panel ever opens in a test).
    struct Leaves {
        var variant: AppDatabase.StoreVariant
        var defaults: () -> UserDefaults
        /// The folder picker: `at` is where the panel opens (nil = its own
        /// default); nil back = cancelled.
        var pickFolder: @MainActor (_ at: URL?) -> URL?
        /// `BackupDestination.remember` in production.
        var remember: (URL, UserDefaults) throws -> Void
        /// The 13l seed-immediately precedent: a forced run so the first
        /// copy lands in the folder she just chose.
        var backUpNow: @MainActor () async -> Void
        var posture: @MainActor () -> Posture

        @MainActor
        static func live(services: AppServices, protection: ProtectionController?) -> Leaves {
            Leaves(
                variant: services.storeVariant,
                defaults: { .standard },
                pickFolder: { at in
                    ExportPanels.chooseFolder(
                        prompt: at == nil ? "Use This Folder" : ProtectionCopy.iCloudOfferUseDoor,
                        directoryURL: at)
                },
                remember: { url, defaults in try BackupDestination.remember(url, in: defaults) },
                backUpNow: { [weak services] in _ = await services?.backup?.backUpNow() },
                posture: { protection?.posture ?? .standard })
        }
    }

    /// The device-local mark: `variorum.backup.iCloudDriveOffered.<variant>`.
    nonisolated static func markKey(for variant: AppDatabase.StoreVariant) -> String {
        "variorum.backup.iCloudDriveOffered.\(variant.rawValue)"
    }

    /// iCloud Drive's root for the current user — the REAL home, not the
    /// sandbox container's (`BackupDestination.displayPath`'s own trick):
    /// `/Users/<user>/Library/Mobile Documents/com~apple~CloudDocs`. Only
    /// ever handed to the panel as the folder it opens in.
    nonisolated static var driveRoot: URL {
        URL(fileURLWithPath: "/Users/" + NSUserName(), isDirectory: true)
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Mobile Documents", isDirectory: true)
            .appendingPathComponent("com~apple~CloudDocs", isDirectory: true)
    }

    private let leaves: Leaves
    /// The sheet shows while this is true.
    private(set) var isDue = false
    private(set) var busy = false
    /// The last thing a door had to say (a cancelled pick, a refused
    /// bookmark) — never a silent outcome.
    private(set) var note: String?

    init(leaves: Leaves) {
        self.leaves = leaves
    }

    var posture: Posture { leaves.posture() }

    nonisolated static func isMarked(variant: AppDatabase.StoreVariant, in defaults: UserDefaults) -> Bool {
        defaults.bool(forKey: markKey(for: variant))
    }

    /// The trigger: after a backup run (`nil` = none yet ⇒ nothing is due).
    /// Due exactly when the mark is unset AND no second folder is picked; a
    /// picked folder writes the mark and asks nothing.
    func consider(after run: BackupRunRecord?) {
        guard run != nil else { isDue = false; return }
        let defaults = leaves.defaults()
        guard !Self.isMarked(variant: leaves.variant, in: defaults) else { isDue = false; return }
        if BackupDestination.isSet(in: defaults) {
            mark(defaults)
            isDue = false
            return
        }
        isDue = true
    }

    /// *Use iCloud Drive* — the picker opened at iCloud Drive's root.
    func useICloudDrive() async {
        await pick(at: Self.driveRoot)
    }

    /// *Choose Another Folder…* — the existing picker.
    func chooseAnotherFolder() async {
        await pick(at: nil)
    }

    /// *Not Now* — asked, answered, never again.
    func notNow() {
        mark(leaves.defaults())
        isDue = false
    }

    private func pick(at directory: URL?) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        note = nil
        guard let picked = leaves.pickFolder(directory) else {
            note = ProtectionCopy.iCloudOfferNoFolderPicked
            return
        }
        let defaults = leaves.defaults()
        do {
            try leaves.remember(picked, defaults)
        } catch {
            note = error.localizedDescription
            return
        }
        mark(defaults)
        isDue = false
        await leaves.backUpNow()
    }

    private func mark(_ defaults: UserDefaults) {
        defaults.set(true, forKey: Self.markKey(for: leaves.variant))
    }
}

/// Copy §6's sheet: the title, the body, the addendum by posture, the three
/// doors.
struct ICloudDriveOfferSheet: View {
    let model: ICloudDriveOfferModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ProtectionCopy.iCloudOfferTitle)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.iCloudOfferBody)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Text(model.posture == .castle
                 ? ProtectionCopy.iCloudOfferCastleAddendum
                 : ProtectionCopy.iCloudOfferStandardAddendum)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let note = model.note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionCopy.iCloudOfferNotNowDoor) { model.notNow() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(ProtectionCopy.iCloudOfferChooseDoor) {
                    Task { await model.chooseAnotherFolder() }
                }
                .disabled(model.busy)
                Button(ProtectionCopy.iCloudOfferUseDoor) {
                    Task { await model.useICloudDrive() }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(model.busy)
            }
        }
        .padding(24)
        .frame(width: 460)
    }
}
