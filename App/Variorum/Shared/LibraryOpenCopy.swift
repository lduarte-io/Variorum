//
//  LibraryOpenCopy.swift
//  Variorum (shared — the adoption doors' and the restore-hold's words)
//
//  Phase 13x, U2 — PROVISIONAL strings per the pre-13x copy conventions
//  (honest content, placeholder voice; 13s re-voices — every constant here
//  is listed in the U2 RECORD's strings table). The kickoff rulings carry
//  the binding sentences: QC's missing-key-file remedy ("send the whole
//  folder — the key file travels with it"), the round-3 restore-hold
//  banner (her ratified shape), and copy §6's why-not sentence, which
//  stays at its ONE home (`ProtectionCopy.liveLibraryNotInICloudDrive`)
//  and is RENDERED by this phase's two faces.
//

import Foundation
import VariorumCore

nonisolated enum LibraryOpenCopy {
    // MARK: - The doors' names (QB: two framed doors, one machinery)

    static let openLibraryDoor = "Open Library…"
    static let restoreSectionTitle = "Restore from Backup"
    static let openCandidateDoor = "Open…"
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
    static let wrongKeyRefusal =
        "That key file doesn't open this library — it belongs to another copy."

    // MARK: - The unlock step (the lobby's roads over the picked pair)

    static let unlockLead = "This library is sealed. Enter its passphrase to open it."
    static let unlockWordsDoor = "Use its twelve words instead"

    // MARK: - The confirm step (what will happen, said before it does)

    static let confirmLead = "Ready to open this library."
    static let confirmStepAside =
        "Your current library steps aside first — a dated copy stays on this Mac "
        + "(Previous Libraries, next to your library), and a safety copy is kept with "
        + "your backups. The file you picked is only read."
    static let confirmFreshSlot = "Nothing stands here yet — the library you picked lands whole."
    static let confirmSyncWaits =
        "After it opens, sync waits until you press Resume — nothing uploads or "
        + "downloads before that."
    /// The plaintext road's extra sentence (ledger 5: fresh key + identity).
    static let confirmPlaintext =
        "This is an unencrypted copy. It gets a fresh key of its own the moment it "
        + "lands, and opens encrypted."
    static let confirmDoor = "Open This Library"

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

    // MARK: - The restore surface's rows (decision 11 rendered)

    /// The which-credential sentence for one candidate's facts.
    static func credentialLine(
        _ credentials: BackupRestoreCandidates.Credentials, secondLook: Bool
    ) -> String {
        var roads: [String] = []
        if secondLook { roads.append("your current passphrase or \(ProtectionCopy.biometryName) on this \(ProtectionCopy.deviceName)") }
        if credentials.passphrase { roads.append("the passphrase of its day") }
        if credentials.recovery { roads.append("your twelve words") }
        if credentials.apple { roads.append("your Apple account") }
        if credentials.master, !secondLook { roads.append("your current passphrase (online)") }
        guard !roads.isEmpty else { return bareCandidateLine }
        return "Opens with " + roads.joined(separator: " · ") + "."
    }
    static let bareCandidateLine =
        "No key file serves this copy — it can't be opened. Its key file may be in "
        + "another backup folder."
    static let restoreSectionBody =
        "Each copy below opens the same way your library does, with the keys of its day. "
        + "Opening one makes it your library — the current one steps aside, recoverable."

    // MARK: - Row 9's faces (the ONE why-not sentence rendered)

    /// The backup-folder picker's refusal of the live library's own folder
    /// (copy §8's recorded note). The sentence is ProtectionCopy's.
    static let pickedLiveLibraryFolderRefusal =
        "That's the folder your library lives in — backups need a place of their own. "
        + ProtectionCopy.liveLibraryNotInICloudDrive
    /// The adoption confirm's informational line when the SOURCE sits in
    /// iCloud Drive (the door adopts by copy; the guard teaches).
    static let sourceInICloudDriveLine =
        "This copy sits in iCloud Drive, so it is copied onto this \(ProtectionCopy.deviceName) first. "
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

    // MARK: - Progress / receipts

    static let classifyingLine = "Reading what you picked…"
    static let adoptingLine = "Opening the library — your current one is stepping aside…"
    /// 13x F1 (ladder R1-M3): the failure copy is PER ARM — this lead's
    /// facts (the dated copy + the safety copy exist) are TRUE only once
    /// the adoption moved past the landing's start, so it renders for
    /// the landing arm and the unknown class alone; the pre-move arms
    /// say nothing moved, and the mid-move arm names its two nets.
    static let adoptionFailedLead =
        "The library couldn't be opened. Nothing you picked was changed; your current "
        + "library is whole in its dated copy and the safety copy."
    /// Round 4's MINOR: a failure on a FRESH slot — no library stood here,
    /// so there is no current library, dated copy or safety copy to name.
    static let adoptionFailedFreshSlot =
        "The library couldn't be opened. No library was here before, nothing was "
        + "moved, and the file you picked was only read."
    /// The pre-move refusals (source missing/unreadable · the hot `-wal` ·
    /// a failed safety copy or hold write): NOTHING moved, and no dated
    /// copy exists to point at.
    static let adoptionRefusedNothingMoved =
        "The library couldn't be opened. Nothing moved — your current library stands "
        + "as it was, and the file you picked was only read."
    /// The mid-move arm: the safety copy EXISTS (it lands before any
    /// move), and what moved is in the aside home.
    static let adoptionFailedMidMove =
        "The library couldn't be opened — it stopped while your current library was "
        + "stepping aside. Your whole library is in its safety copy (Backups ▸ "
        + "safety-copies, beside your library), and the files that moved are in "
        + "Previous Libraries. The file you picked was only read."
}
