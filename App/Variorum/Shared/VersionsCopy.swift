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

    /// The pane's standing sentence. It made the confirm's own over-promise
    /// two inches above the button — *"so nothing is ever a one-way door"* —
    /// and is corrected with it (13u3 UNIT E): the words come back, the
    /// history does not.
    static let explainer =
        "Whole moments of this note, saved by hand. Opening one reads it; "
        + "restoring makes the note say that again — and saves where it is "
        + "now first, so none of its words are lost."

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
        momentTitle(item.savedAt)
    }

    /// **A saved moment's derived name, wherever it is shown** — the listing's
    /// row, a Compare column, the full-size band (VX-440 batch 1). One format,
    /// so the moment she picked in the pane is the moment the column names.
    static func momentTitle(_ savedAt: Date) -> String {
        savedAt.formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: VX-440 batch 1 — the moment in Compare and at full size

    /// **Stop counting it as a version = PROMOTE, after a confirm** (her VX-437
    /// ruling: *"you should be allowed to stop counting it as a version but i
    /// think that should mean that it is automatically promoted"*). ONE ask,
    /// shared by Compare's unmark on a saved moment and the full-size band's
    /// Promote door. PROVISIONAL P-440-5 (the plan's copy, sentence case).
    static let stopCountingTitle = "Stop counting this as a version?"
    static let stopCountingDetail =
        "It becomes a regular note \u{2014} unarchived, unsealed, wearing the note's current tags."
    static let stopCountingVerb = "Promote"

    /// A saved moment's column in Compare says what it is under its date
    /// (PROVISIONAL P-440-6 — the batch record).
    static let compareRelationship = "a saved version of this note"

    /// The unmark door's help on a saved moment's column — it asks first, and
    /// what it asks is the promote (P-440-6).
    static let compareUnmarkHelp =
        "Stop counting this as a version \u{2014} it becomes a regular note of its own "
        + "(asks first)"

    /// **The one-press door** (R-440-1): the note menus, File and ⌘K seat the
    /// newest moment beside the live note in Compare. Rendered only while the
    /// note HAS a moment (P-2); the note below is what a press with none —
    /// a race — speaks.
    static let compareWithLatestVerb = "Compare with Latest Version"
    static let compareWithLatestUnavailable =
        "Compare with Latest Version needs a saved version of the note you have open "
        + "\u{2014} \u{2318}\u{21E7}S saves one."

    /// The Versions row's two new doors (R-440-1, R-440-2) and their help.
    static let compareWithNowVerb = "Compare with now"
    static let compareWithNowHelp =
        "Opens Compare with this moment beside the note as it is now"
    static let openFullSizeVerb = "Open full size"
    static let openFullSizeHelp =
        "Reads this moment on a whole page, without changing the note"

    /// **The full-size face's identity band** (R-440-2): "A saved version of
    /// ‹title› · ‹date›", with the one road back and the promote.
    static func bandLine(noteTitle: String, savedAt: Date) -> String {
        "A saved version of \u{201C}\(noteTitle)\u{201D} \u{00B7} \(momentTitle(savedAt))"
    }
    static let backToNoteVerb = "Back to the note"
    static let promoteToNoteVerb = "Promote to a regular note\u{2026}"

    /// What the full-size face says when what it was opened on is no longer
    /// one of the note's saved moments (promoted, deleted or unlinked since —
    /// a back/forward visit can arrive after any of them).
    static let fullSizeGone =
        "This isn't one of the note's saved versions any more."

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

    /// **The promise, said as narrowly as it is true** (13u3 UNIT E, item
    /// 15(a)). This sentence used to end *"so this is never a one-way door"*,
    /// which is true of the note's WORDS — the version of NOW holds every one
    /// of them — and false of everything else the Delete Now road takes with
    /// the outgoing blocks: the savepoints on their takes, the takes deleted
    /// from them, the comments deleted from them. A copy carries words, never
    /// the past (the standing rule the tutorial now teaches), so the promise
    /// says WORDS and the sentence below names the rest.
    static let restoreConfirmDetail =
        "Where the note is right now is saved as a new version first, so none "
        + "of its words are lost. The note keeps its name, its books and "
        + "everything that points at it."

    /// **…and what the road takes that no version holds** (item 15(a), her
    /// #80(e) ratification: *"keep as built — defensible, and the confirm can
    /// name it"*). Counted at ask time by `Queries.restoreCost`, spoken in
    /// numbers rather than categories, and pointing at PROMOTE — the zero-loss
    /// road she confirmed at the sitting: promoting the moment mints it as a
    /// note of its own and deletes nothing.
    ///
    /// Nothing to name ⇒ the confirm is EXACTLY the sentence it has always
    /// been, which is what keeps the everyday restore unchanged.
    static func restoreConfirmDetail(_ cost: Queries.RestoreCost) -> String {
        guard let line = restoreCostLine(cost) else { return restoreConfirmDetail }
        return restoreConfirmDetail + "\n\n" + line + " " + restorePromoteInstead
    }

    /// The zero-loss road, named where the loss is named.
    static let restorePromoteInstead =
        "Promote instead keeps everything \u{2014} it makes this moment a note "
        + "of its own and deletes nothing."

    /// The loss itself, in her own grain: what is going, and that nothing
    /// brings it back. Nil when there is nothing to say.
    static func restoreCostLine(_ cost: Queries.RestoreCost) -> String? {
        var pieces: [String] = []
        if cost.savedMoments > 0 {
            pieces.append(cost.savedMoments == 1
                ? "1 saved moment" : "\(cost.savedMoments) saved moments")
        }
        if cost.deletedTakes > 0 {
            pieces.append(cost.deletedTakes == 1
                ? "1 deleted take" : "\(cost.deletedTakes) deleted takes")
        }
        if cost.deletedComments > 0 {
            pieces.append(cost.deletedComments == 1
                ? "1 deleted comment" : "\(cost.deletedComments) deleted comments")
        }
        // Population 4 — the set-aside originals. Measured empty for a restore
        // today (the version of NOW's own copy is every outgoing block's
        // surviving descendant, so nothing strands — `RestoreCost.swift`'s
        // header carries the mechanism), and named here anyway because her
        // ruling names it and the zero is one line of the copy loop away from
        // being a number again.
        if !cost.setAsideOriginals.isEmpty {
            let count = cost.setAsideOriginals.count
            pieces.append(count == 1
                ? "1 set-aside original and its \(takesPhrase(cost.setAsideTakes))"
                : "\(count) set-aside originals and their \(takesPhrase(cost.setAsideTakes))")
        }
        guard !pieces.isEmpty else { return nil }
        return "A version holds the words, not the history. Going with these "
            + "paragraphs, and held by no version: \(list(pieces)). Nothing "
            + "puts them back."
    }

    private static func takesPhrase(_ count: Int) -> String {
        count == 1 ? "1 take" : "\(count) takes"
    }

    /// "a", "a and b", "a, b and c" — the app's own listing grain.
    private static func list(_ pieces: [String]) -> String {
        guard pieces.count > 1 else { return pieces.first ?? "" }
        return pieces.dropLast().joined(separator: ", ")
            + " and " + (pieces.last ?? "")
    }

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
