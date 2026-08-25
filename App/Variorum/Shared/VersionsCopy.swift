//
//  VersionsCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE VERSIONS FAMILY'S VOCABULARY, IN ONE HOME** (the post-13l polish
//  round, ledger rows 16 and 23 — G1 and the V-rulings).
//
//  Everything here is about what the STORE does — what a saved moment IS, what
//  restoring one means, what promoting one costs — which is why neither
//  platform may own it alone. `RecoveryCopy`'s own header makes the argument
//  and this file inherits it: the phone owes a Versions face (a closeout
//  parity note), and when it builds one it must not re-write the sentences
//  that describe one machinery.
//
//  The five-places map is the reason the words matter: her north star is that
//  everything a user ever had is in exactly ONE of five places, and **this note's
//  VERSIONS** is the fourth. The copy's job is to make that legible in one
//  sentence per surface.
//

import Foundation
import VariorumCore

/// The whole-note Versions door and its listing, in words.
nonisolated enum VersionsPath {
    /// The surface's name — the pane's title, the menu item, the registry verb.
    static let name = "Versions"

    /// The `note ▾` menu's row (an ellipsis, because it opens something).
    static let menuLabel = "Versions\u{2026}"

    /// The save door's verb. ⌘⇧S beside ⌘S's take-commit, and **the pairing
    /// IS the teaching moment** (her G4 chapter, ledger row 26): ⌘S saves this
    /// TAKE's moment, ⌘⇧S saves this NOTE's.
    static let saveVerb = "Save a Version"

    /// How copy elsewhere points at the door.
    static let doorPhrase = "Versions in the note menu"

    static let explainer =
        "Whole moments of this note, saved by hand. Opening one reads it; "
        + "restoring makes the note say that again — and saves where it is "
        + "now first, so nothing is ever a one-way door."

    static let empty =
        "No saved moments yet. \u{2318}\u{21E7}S saves the whole note as it is "
        + "right now, and the moment waits here for as long as the note does."

    /// The row's own three verbs.
    static let openVerb = "Read"
    static let restoreVerb = "Restore"
    static let promoteVerb = "Promote"
    static let deleteVerb = "Delete\u{2026}"

    static let restoreHelp =
        "The note goes back to saying this. It keeps its name, its books and "
        + "everything pointing at it — and where it is now is saved as a new "
        + "moment first."

    static let promoteHelp =
        "Takes this moment out of the past and makes it a note of its own, in "
        + "the Library, to work with. It leaves this list for good."

    static let deleteHelp =
        "Sends this moment to the Trash for \(TrashWindow.days) days."

    /// A row's quiet line: when it was saved, how much of the note it holds,
    /// and — for 13w's automated future — whether it was taken by hand.
    ///
    /// **The automated rotation renders here indistinguishably except for the
    /// label** (`notes/plans/whole-note-history-brief.md`, master plan row
    /// 13w): its rows are the same rows, and this is the one place that says
    /// which kind a moment is.
    static func rowMeta(_ item: Queries.NoteVersionItem) -> [String] {
        var pieces = [item.savedAt.formatted(date: .abbreviated, time: .shortened)]
        pieces.append(item.blockCount == 1 ? "1 block" : "\(item.blockCount) blocks")
        if item.cadence == .automatic { pieces.append("saved for you") }
        return pieces
    }

    /// A row's title. **NO TITLE MUTATION** (V6, her *"maybe its name should
    /// have the date"* answered by derivation): the copy's own title is never
    /// touched, and the DATE is what the row leads with.
    static func rowTitle(_ item: Queries.NoteVersionItem) -> String {
        item.savedAt.formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: The receipts

    static let saved =
        "Saved a version \u{2014} the whole note as it is now, in \(name)."

    /// The restore's receipt names the ONE thing she needs to know she did not
    /// lose: where it is now was saved first.
    static let restored =
        "The note says this again \u{2014} and where it was a moment ago is "
        + "saved in \(name), so you can go back."

    static let promoted =
        "This moment is a note of its own now, in the Library. It has left "
        + "\(name)."

    static let deleted =
        "The moment moved to the \(RecoveryCopy.trashSection) \u{2014} "
        + "\(TrashWindow.days) days to put it back."

    /// **The confirm before a restore.** A note-scale content replacement asks,
    /// on the confirmation-consistency principle's SCALE clause (notes confirm;
    /// blocks and takes do not) — and the ask is where the save-first promise
    /// is readable BEFORE the press rather than only after it.
    static let restoreConfirmTitle = "Make the note say this again?"
    static let restoreConfirmDetail =
        "Where the note is right now is saved as a new version first, so this "
        + "is never a one-way door. The note keeps its name, its books and "
        + "everything that points at it."

    // MARK: The Trash's version rows (FOUND-ITEM 1)

    /// What a version row calls itself in the Trash. A version IS a container,
    /// so it rides the note doors unchanged — what the row owes is the truth
    /// about which kind of thing it is.
    static let trashRowKind = "saved version"

    /// The row's context line: whose moment it is.
    static func trashRowOf(_ noteTitle: String) -> String {
        "a version of \u{201C}\(noteTitle)\u{201D}"
    }

    /// Put back returns it where it lives (never the Library).
    static let putBackReceipt =
        "Version put back \u{2014} it's in its note's \(name) again."

    /// The one honest line the note-delete confirm gains (V2, ratified: *"I
    /// agree it should auto delete versions and not ask for a confirmation
    /// dialog"*). **No extra question at delete time** — a mid-delete dialog
    /// nobody can answer well is friction; the keep road is restoring the
    /// version before, or Put back within the window after.
    static func versionsGoWithIt(_ count: Int) -> String? {
        guard count > 0 else { return nil }
        return count == 1
            ? "Its 1 saved version goes with it."
            : "Its \(count) saved versions go with it."
    }
}
