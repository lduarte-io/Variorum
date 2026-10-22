//
//  LibraryOpenCopy.swift
//  Variorum (shared — the copy doors' refusals, the restore-hold's and the hand-off's words)
//
//  Phase 13x, U2 — PROVISIONAL strings per the pre-13x copy conventions
//  (honest content, placeholder voice; 13s re-voices — every constant here
//  is listed in the U2 RECORD's strings table). The kickoff rulings carry
//  the binding sentences: QC's missing-key-file remedy ("send the whole
//  folder — the key file travels with it"), the round-3 restore-hold
//  banner (her ratified shape), and copy §6's why-not sentence, which
//  stays at its ONE home (`ProtectionCopy.liveLibraryNotInICloudDrive`)
//  and is RENDERED by this phase's two faces. VX-329 U1: 13x's adoption
//  flow's sentences (the unlock and confirm steps, the restore rows'
//  credential lines, the progress lines) left with today's road; what the
//  protection road's copy doors and the hand-off still speak stays here.
//

import Foundation
import VariorumCore

nonisolated enum LibraryOpenCopy {
    // MARK: - The doors' names (QB: two framed doors, one machinery)

    static let openLibraryDoor = "Open Library…"
    static let restoreSectionTitle = "Restore from Backup"
    static let sheetTitle = "Open a Library"

    // MARK: - Refusals (worded per verdict; the facts are the classifier's)

    /// Corner 33 + QC's remedy sentence.
    static let bareStoreRefusal =
        "This library is sealed, and no key file came with it — nothing can open it alone. "
        + "Ask for the whole folder: the key file travels with it."
    static let newerSchemaRefusal =
        "This library was written by a newer Variorum than this one. "
        + "Update Variorum, then open it again."
    static let notAVariorumStoreRefusal = "This isn't a Variorum library."
    static let unreadableRefusal = "This file couldn't be read as a library."
    /// The chooser's lead when a picked folder holds several stores
    /// (P-U1-3: reported, never guessed).
    static let severalStoresLead = "This folder holds more than one library — pick one."

    // MARK: - The restore-hold banner (round 3, her ratified shape)

    /// 13x F1 (ladder R1-N1 — §12's a-door-that-did-nothing rule): the
    /// Sync-now door's refusal while the restore hold stands.
    static let syncNowHeldRefusal =
        "Sync is waiting since the restore — press Resume Sync in the banner below."

    /// `hasAccount` false (round 4's NIT): with no account there is nothing
    /// to catch up WITH — Resume only clears the hold (P-U2-2), and the
    /// sentence must not name an account that does not exist.
    static func holdBanner(asOfDay: String?, hasAccount: Bool = true) -> String {
        let lead = asOfDay.map { "This is your library as of \($0). " }
            ?? "This library was just restored from a copy. "
        guard hasAccount else {
            return lead
                + "Sync is waiting until you press Resume. To keep something from this "
                + "backup, duplicate it first — duplicates stay."
        }
        return lead
            + "Sync is waiting — Resume to catch up with your account. Notes you deleted "
            + "since will leave again; edits made since will come back. To keep something "
            + "from this backup, duplicate it first — duplicates stay."
    }
    static let resumeSyncDoor = "Resume Sync"
    /// VX-339 (PROVISIONAL words — the run record's P-VX339-1): the banner's
    /// line when Resume could not remove the hold's marker beside the
    /// library — the hold still stands, so the banner stays and says so.
    static let resumeMarkerNotRemoved =
        "Sync is still waiting: Variorum couldn't remove the restore marker beside your library. "
        + "Press Resume Sync to try again."

    // MARK: - Row 9's faces (the ONE why-not sentence rendered)

    /// The backup-folder picker's refusal of the live library's own folder
    /// (copy §8's recorded note). The sentence is ProtectionCopy's.
    static let pickedLiveLibraryFolderRefusal =
        "That's the folder your library lives in — backups need a place of their own. "
        + ProtectionCopy.liveLibraryNotInICloudDrive

    // MARK: - The hand-off door (13x F1, ladder R1-MAJOR — deliverable 1's
    // face; QC's folder pair, produced where she can find and AirDrop it)

    /// The one verb, both faces — the registry's `.handOffLibrary`
    /// declares its verb FROM this constant (13x F2, ladder R2-2: one
    /// source of truth — re-voicing this line reaches the File menu and
    /// Data Safety alike, and the CapabilityRegistryTests equality pin
    /// goes red the moment the two decouple).
    static let handOffDoor = "Send Library to Another Mac…"
    static let handOffSheetTitle = "Send Library to Another Mac"
    static let handOffPanelMessage =
        "Choose where to put the travelling folder — somewhere easy to find and AirDrop."
    static let handOffPanelPrompt = "Put It Here"
    static let handOffProducingLine =
        "Making the travelling folder — a sealed copy of your library and its key file…"
    /// QC's teaching, said at the success moment (its mirror is the
    /// missing-key-file refusal's remedy).
    static func handOffDoneLead(folder: String) -> String {
        "“\(folder)” is ready. Send the whole folder — the key file travels with it, "
        + "and without the key file the library opens nothing."
    }
    static let handOffRevealDoor = "Show in Finder"
    /// Corner 33 at the producing end: a pair without its key file would
    /// arrive unopenable, so nothing is made.
    static let handOffNoKeyFileRefusal =
        "No key file sits beside this library yet, so a travelling copy would arrive "
        + "unopenable. Nothing was made."
    static let handOffFailedLead =
        "The travelling folder couldn't be made — nothing travels half-made."
    /// Data Safety's twin (the FAQ entry's own name).
    static let handOffSectionTitle = "Moving to another Mac"
    static let handOffSectionBody =
        "One folder holds a sealed copy of your library and its key file. AirDrop the "
        + "whole folder to the other Mac and open it there with File ▸ Open Library…"
}
