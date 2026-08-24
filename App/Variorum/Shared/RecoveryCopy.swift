//
//  RecoveryCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE DELETION STORY'S SENTENCES, HOISTED** (round 2 batch 4 —
//  MobileSoul §3, and the parity inventory's §4(c) row: *"Each file's own
//  comment says the strings live in one home because copy elsewhere
//  promises the surface by name and would drift. That argument does not
//  stop at the platform boundary."*).
//
//  Until this file existed the whole vocabulary lived in Mac app code
//  (`Features/Library/RecoveryView.swift`'s `RecoveryPath`,
//  `Features/Tray/TrayPanel.swift`'s `TrayPath`), so the phone's Trash
//  would have had to re-write every sentence — and the two platforms would
//  then have described one 30-day clock two ways. What moved here is the
//  SEMANTIC-bearing half only, exactly as the inventory scoped it: the
//  clock language, archive-has-no-clock, the kind vocabulary, the
//  count-by-kind Empty-Trash confirm, and the three honest purge-receipt
//  populations. Pure Mac chrome wording (the Library menu item's label,
//  the tray's badge glyph and door phrase) stays where it was.
//
//  `RecoveryPath` and `TrayPath` now FORWARD here, so the Mac's pins ride
//  unmodified (the 3C parity pattern) and a rename lands once.
//
//  The Trash-row → purge-root table mapping moved with the words because it
//  is the same one brain, not chrome (its own comment used to promise the
//  phone "its own twin" — the drift class).
//
//  **13l Act 2 (A1-NIT-1's sibling, A1-NIT-2): the ACTS moved OUT.** The
//  first-act cold review named the shape — a `…Copy` file carrying two
//  `@MainActor` act compositions beside the sentences — and its disposition
//  said they should split "when that item grows the decision layer". Item 4
//  grew it, so `TrashPutBack`, `PreservedOriginPutBack`, `RecoveryRefusal`
//  and `DeletionRefusal` now live in `Shared/RecoveryActs.swift` with the
//  purge layer. This file is sentences again.
//

import Foundation
import VariorumCore

/// The deletion story's shared vocabulary. Every sentence here is about
/// what the STORE does — the 30-day window, archive's absence of a clock,
/// what a purge takes — which is why neither platform may own it alone.
nonisolated enum RecoveryCopy {
    // MARK: The two sections (they must never blur — her round-3 ruling)

    /// **The Trash** (13j J1, her word). One listing over every deleted
    /// thing, on the 30-day clock.
    static let trashSection = "Trash"
    /// The other half: kept forever, no clock, deliberately calm.
    static let archivedSection = "Archived"
    /// The surface that holds both, named the same on both platforms.
    static let surfaceName = "Archived & Deleted"

    /// The one verb, whatever kind the row is, wherever it is offered.
    static let putBackVerb = "Put back"

    /// How the Trash explains itself in one line — the promise stated where
    /// she can read it, because a countdown with no sentence is a threat.
    static let windowNote =
        "Deleted things wait here for \(TrashWindow.days) days, then they're gone."

    // MARK: The kind vocabulary

    /// The kind filter's words (plural).
    static func kindLabel(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "Notes"
        case .book: return "Books"
        case .block: return "Blocks"
        case .take: return "Takes"
        case .preservedOriginal: return "Originals"
        }
    }

    /// What ONE row calls itself, in the singular.
    static func rowKind(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "note"
        case .book: return "book"
        case .block: return "block"
        case .take: return "take"
        case .preservedOriginal: return "preserved original"
        }
    }

    // MARK: The clock

    /// **The countdown** (13j J1 — 30 days, her fixed window). Deleted rows
    /// wear it; ARCHIVED rows never do, which is the whole reason the two
    /// states are shown apart.
    static func daysLeftLabel(_ days: Int) -> String {
        switch days {
        case 0: return "leaves today"
        case 1: return "1 day left"
        default: return "\(days) days left"
        }
    }

    /// What an ARCHIVED row says instead of a countdown.
    static let archivedForever = "kept — no clock"

    /// **The stranded original's label** (her round-8b ruling): an original
    /// whose whole descendant family is in the Trash rides the family's
    /// clock, and says so where she can see it.
    static let goesWithItsFamily =
        "preserved original — goes with its deleted blocks"

    // MARK: Put-back receipts (the three landings)

    static let putBackWhereItWas = "Put back where it was."
    static let putBackBeside = "Put back where it came from."

    /// **WHAT A BLOCK CAME OUT OF, IN THE APP'S OWN WORDS** (13l Act 2,
    /// ledger row 26). A block does not only live in a note: the scraps area
    /// is a `kind='pool'` container holding ordinary blocks, and its blocks
    /// reach the Trash by the same road. These two receipts said "note"
    /// whatever the row was, which is the one lie the recovery story cannot
    /// afford (§8d — intuitive from every door). The word comes from the
    /// LANDING now (`Operations.BlockRestoreLanding.home`), which is the
    /// transaction's own answer, never a projection's.
    ///
    /// "scraps" and not "pool": the SURFACE is named Scraps everywhere she
    /// can see it (the row's own "Open scraps" door, the Blocks area), and
    /// "pool" is the model's word (R29 gave the sidebar's Pool to bookless
    /// NOTES, which is a different thing entirely — copy that said "pool"
    /// here would point her at the wrong room).
    static func homeWord(_ home: ContainerKind) -> String {
        switch home {
        case .post: return "note"
        case .pool: return "scraps"
        }
    }

    static func putBackAtEnd(_ home: ContainerKind) -> String {
        switch home {
        case .post: return "Put back at the end of this note."
        case .pool: return "Put back at the end of the scraps."
        }
    }

    /// The block is live again but has nowhere to land (its home is gone, or
    /// it remembers none). **A RECEIPT — something really happened.** Never a
    /// refusal: see `originalHasNoNote` below, which is the sentence for the
    /// case where nothing happened at all.
    static func putBackUnplaced(_ home: ContainerKind?) -> String {
        guard let home else {
            return "Put back — but it has no note to go back to, so it's waiting unplaced."
        }
        return "Put back — but its \(homeWord(home)) is gone, so it's waiting unplaced."
    }

    /// **The preserved original with no note to go back INTO** (batch 4.5b —
    /// §49's MINOR: *a success sentence in the red slot*). Putting a
    /// preserved original back means PLACING it, and placing needs a note;
    /// with none recorded there is nowhere to put it, so nothing happens.
    /// The shipped code answered that case with `putBackUnplaced` — a
    /// RECEIPT, rendered in the red slot, reading as though the block had
    /// been recovered when it had not moved at all.
    static let originalHasNoNote =
        "This original's note is gone, so there's nowhere to put it back — "
        + "it stays here."
    /// The one refusal either recovery surface needs in its own voice: the
    /// listing still opens under a seal (reading is free); it is putting
    /// back that the seal refuses.
    static let sealedPutBackRefusal =
        "This note is marked complete — unseal it to put this back."

    // MARK: The purge doors (in-Trash only, forever — her round-3 rider)

    static let deleteNowVerb = "Delete Now"
    static let emptyTrashVerb = "Empty Trash…"

    /// Delete Now's confirm, per row — destructive, unrecoverable, asked
    /// EVERY time by her round-10 ruling (there is no don't-ask state
    /// anywhere in the code, and none may be added).
    static func deleteNowConfirm(_ kind: Queries.TrashItem.Kind) -> String {
        "Delete this \(rowKind(kind)) for good? It skips the rest of its "
            + "\(TrashWindow.days) days — there's no putting it back."
    }

    /// Empty Trash's confirm NAMES THE FULL COUNT BY KIND (her round-8
    /// ruling). Preserved originals are named when they ride: they are the
    /// round-8b passengers, never separately purged.
    static func emptyTrashConfirm(_ counts: [Queries.TrashItem.Kind: Int]) -> String {
        let total = counts.filter { $0.key != .preservedOriginal }.values.reduce(0, +)
        guard total > 0 else { return "The Trash is empty — nothing to delete." }
        let order: [Queries.TrashItem.Kind] = [.note, .block, .take, .book]
        let parts = order.compactMap { kind -> String? in
            guard let count = counts[kind], count > 0 else { return nil }
            let word = kindLabel(kind).lowercased()
            let singular = rowKind(kind)
            return count == 1 ? "1 \(singular)" : "\(count) \(word)"
        }
        var sentence = "Empty the Trash? \(total) thing\(total == 1 ? "" : "s") "
            + "go\(total == 1 ? "es" : "") for good: \(parts.joined(separator: ", "))."
        if let originals = counts[.preservedOriginal], originals > 0 {
            sentence += " \(originals) preserved original\(originals == 1 ? " rides" : "s ride") along with "
                + "\(originals == 1 ? "its" : "their") famil\(originals == 1 ? "y" : "ies")."
        }
        return sentence
    }

    /// The receipts tell the truth about NOW vs the janitor (the J8 bar):
    /// the row left every surface the moment the intent was written; the
    /// bytes follow once every device on the account has seen the deletion.
    /// The three populations are synced · never-synced · signed-out-with-
    /// synced-history (13j ladder B, B3 + R2-M1).
    static func deleteNowReceipt(
        _ kind: Queries.TrashItem.Kind, synced: Bool, familyEverSynced: Bool = false
    ) -> String {
        if synced {
            return "The \(rowKind(kind)) is gone from the app now — the bytes follow "
                + "once every synced device has caught up."
        }
        if familyEverSynced {
            return "The \(rowKind(kind)) is gone from the app now — it once synced, "
                + "so the bytes finish clearing after you next sign in."
        }
        return "The \(rowKind(kind)) is gone from the app now — the app's own "
            + "cleanup removes the bytes."
    }

    static func emptyTrashReceipt(
        _ total: Int, synced: Bool, anyFamilyEverSynced: Bool = false
    ) -> String {
        let head = "The Trash is emptied — \(total) thing\(total == 1 ? "" : "s") gone from the app now; "
        if synced { return head + "the bytes follow once every synced device has caught up." }
        if anyFamilyEverSynced {
            return head + "anything that once synced finishes clearing after you "
                + "next sign in; the rest the app cleans up now."
        }
        return head + "the app's own cleanup removes the bytes."
    }

    // MARK: Move-to-Trash (the ordinary deletion doors' promise)

    /// **What "Delete" means everywhere OUTSIDE the Trash** — a tombstone,
    /// recoverable for the window. Round 2 batch 4's own sentences, born
    /// shared because the phone built the doors first and the Mac's 13l
    /// work will want the same words (its note-delete door carries no
    /// confirmation at all today — the inventory's R1 finding).
    static func moveToTrashDetail(_ kind: Queries.TrashItem.Kind) -> String {
        "The \(rowKind(kind)) goes to the \(trashSection) for \(TrashWindow.days) days. "
            + "You can put it back from \(surfaceName) until then."
    }

    /// Deleting a BOOK is not deleting its notes — the 13j books lesson,
    /// fixed at her instruction, said in the door that does it.
    static let deleteBookKeepsItsNotes =
        "Its notes stay in the library."

    static func movedToTrashReceipt(_ kind: Queries.TrashItem.Kind) -> String {
        "\(rowKind(kind).prefix(1).uppercased())\(rowKind(kind).dropFirst()) moved to the "
            + "\(trashSection) — \(TrashWindow.days) days to put it back."
    }

    // MARK: Put-back receipts, by kind and by landing (hoisted at 4.5b)

    /// What a put-back says when the op reports no landing of its own.
    static func putBackReceipt(_ kind: Queries.TrashItem.Kind) -> String {
        "\(rowKind(kind).prefix(1).uppercased())\(rowKind(kind).dropFirst()) put back."
    }

    /// **`restoreBlock` ANSWERS where it landed, and the receipt repeats the
    /// answer rather than guessing** (13j's F2 shape). The three landings,
    /// in the one home — this used to be a `MobileTrashModel` static while
    /// the Mac discarded the landing entirely, which is the drift §49's
    /// MAJOR names.
    ///
    /// **13l Act 2 (ledger row 26): the landing now also answers WHAT it went
    /// back into**, and this is the one place that turns that answer into a
    /// word — so the Trash, the note's tray and the phone cannot describe one
    /// scrap three ways. `.itsOldPlace` needs no kind: "where it was" is true
    /// of every home there is.
    static func landingReceipt(_ landing: Operations.BlockRestoreLanding) -> String {
        switch landing {
        case .itsOldPlace: return putBackWhereItWas
        case .endOfNote(let home): return putBackAtEnd(home)
        case .unplaced(let home): return putBackUnplaced(home)
        }
    }

    /// **`restoreVariant` ANSWERS what came back, and the take's receipt
    /// repeats the answer instead of assuming the fan** (13l Act 1, the
    /// first-act cold review's A1-MAJOR-1 — `landingReceipt`'s shape, one op
    /// over, and the THIRD door to adopt it).
    ///
    /// The restore is an EXACT FLIP (#68(b), ruled), so a take that was
    /// ARCHIVED when it was deleted comes back archived — into its block's
    /// archived listing, never the fan. That row is reachable from the Trash
    /// today: `deleteVariant` accepts an archived, unlocked, non-chosen take
    /// (I10's guard counts only ACTIVE takes, so `ensureNotLastActive`
    /// returns early), and `Queries.trash` lists deleted takes with NO status
    /// filter. The shipped road wrote `_ = try ops.restoreVariant(…)` and
    /// fell through to the generic `putBackReceipt(.take)`, so this surface
    /// said *"Take put back."* while the take landed somewhere she would not
    /// look — the same discard `BlockPastCopy.restored` (the block's History
    /// face) and `LensFallbackCopy.restoredDeletedButArchived` (a lens's
    /// dangling pick) were each corrected for at 13j ladder A's A3. Two doors
    /// onto one act answering *"where did it go?"* two ways is the M-C drift
    /// class the 4.5b hoist exists to kill.
    static func takeRestoredReceipt(_ status: VariantStatus) -> String {
        status == .archived ? takeRestoredArchived : putBackReceipt(.take)
    }

    /// The archived edition. Its two siblings word the same fact for the
    /// surface each speaks on; this is the Trash's, and it is the one BOTH
    /// platforms read.
    static let takeRestoredArchived =
        "Take put back — it was archived when it was deleted, so it's among "
        + "its block's archived takes, not the fan. Unarchive it there to "
        + "bring it back."
}

/// The Trash-row → purge-root table mapping. **Hoisted with the words**
/// (round 2 batch 4): it lived beside the Mac's only renderer, and its own
/// comment promised the phone "its own twin", which is the six-brains drift
/// class stated as a plan. One mapping, both platforms.
extension Queries.TrashItem.Kind {
    nonisolated var purgeTable: String {
        switch self {
        case .note: return "container"
        case .book: return "reading"
        case .block: return "block"
        case .take: return "variant"
        case .preservedOriginal: return "block"  // rides its family; no own door
        }
    }
}
