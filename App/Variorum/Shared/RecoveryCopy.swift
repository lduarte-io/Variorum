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
//  Two more things moved with the words because they are the same one
//  brain, not chrome: the Trash-row → purge-root table mapping (whose own
//  comment used to promise the phone "its own twin" — the drift class), and
//  `PreservedOriginPutBack`, the read-then-place composition both recovery
//  surfaces need.
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
    static let putBackAtEnd = "Put back at the end of this note."
    static let putBackBeside = "Put back where it came from."
    /// The block is live again but has nowhere to land (its note is gone).
    static let putBackUnplaced =
        "Put back — but its note is gone, so it's waiting unplaced."
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

/// **The preserved original's PUT BACK, in ONE place** (13j batch 3; hoisted
/// cross-platform at round 2 batch 4): the Mac tray's originals section, the
/// J3 peek, and the phone's Trash are three doors onto one act, and a second
/// copy of the composition is a second place for the landing rule to drift.
///
/// It is a face-level composition over `placeBlock` — the W-reversibility
/// primitive, exactly as the ceremony's "reversible by re-pointing at A"
/// promises — and NO operation's semantics change for it.
///
/// Putting a preserved original back is PLACING it, not flipping a tombstone.
/// The landing is re-read HERE, at act time, rather than taken from a
/// listing: a listing is a projection, and an argument read from a projection
/// is read from a snapshot (13c R3-1's lesson, applied at the only place it
/// can bite — the successor could have moved or gone since the panel last
/// rendered). The recorded corner is unchanged: if it moves in the
/// sub-millisecond window between this read and the write, `placeBlock`
/// refuses by name and she retries.
@MainActor
enum PreservedOriginPutBack {
    /// Returns the receipt; refusals throw for the caller to word.
    static func run(
        session: AppSession, postID: String, blockID: String
    ) async throws -> String {
        let landing = try await session.database.read { db in
            try Queries.preservedOriginals(db, postID: postID)
                .first { $0.blockID == blockID }?.landAfterBlockID
        }
        let insert: Operations.InsertPosition = landing.map { .after($0) } ?? .end
        try await session.runner.run { ops in
            _ = try ops.placeBlock(blockID, in: postID, at: insert)
        }
        return landing == nil ? RecoveryCopy.putBackAtEnd : RecoveryCopy.putBackBeside
    }
}
