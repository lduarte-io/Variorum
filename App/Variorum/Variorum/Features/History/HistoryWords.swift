//
//  HistoryWords.swift
//  Variorum (Mac)
//
//  **The Mac's history words that outlived the Block History panel** (VX-827
//  U3b retired the panel whole — `Features/Tray/BlockHistoryPane.swift`). A
//  hoist moves an ADDRESS, never a behaviour: every string and rule below is
//  byte-identical to what the panel's file shipped, kept because a living
//  surface still speaks it (the Commits face's acts and rail, the bars'
//  door, the tray's road, the helper). What nothing composes any more left
//  with the panel — its jump door, its region headers and meaning lines, the
//  read-in-full sheet, the row view and its open-row anatomy.
//

import Foundation
import VariorumCore

/// **THE MAC'S OWN WORDS FOR THE HISTORY DOOR** — the half of the vocabulary
/// that names a MAC door or chord (the shared half is
/// `Shared/BlockHistoryFace.swift`).
nonisolated extension BlockHistoryPath {
    /// The bar's door label. Lowercased by the voice like its neighbour
    /// ("commit ⌘S"); the pairing IS the teaching moment (her G4 chapter:
    /// write a moment · see the moments).
    static let doorLabel = "history"

    /// How copy elsewhere points at the door.
    static let doorPhrase = "the history door in the note's bottom bar"

    /// **Bring back as a take** (R-440-3; the op is
    /// `Operations.bringBackCommitAsTake`). PROVISIONAL words (P-440-4/-10).
    static let bringBackAsTakeVerb = "Bring back as a take"
    static let bringBackAsTakeHelp =
        "Makes this saved moment a take of its own on this block \u{2014} the last in "
        + "its fan, never chosen \u{2014} so you can read it and work on it in the editor. "
        + "The moment itself stays"

    /// The act's receipt (P-440-4: "a quiet receipt names the act"), naming
    /// the take by the label it was born with when the moment had a name.
    static func broughtBackAsTake(label: String?) -> String {
        guard let label else {
            return "Brought back as a take \u{2014} it's the last take in this block's fan."
        }
        return "Brought back as the take \u{201C}\(label)\u{201D} \u{2014} it's the last "
            + "take in this block's fan."
    }

    /// Restore's hover words, one home (the panel's row said them; the
    /// Commits face's foot says them now).
    static let restoreHelp = "Loads this saved moment back into the take's buffer \u{2014} "
        + "the moment itself stays, and saving again appends"
}

/// **THE MAC'S LINEAGE FACE, BY NAME** (VX-827 U3b) — where a block kept
/// whole by a divide or a merge waits on the Mac now: the block's Lineage face
/// (block ▾ ▸ Lineage, or "lineage ›" on its history). One home, so every
/// sentence that names the place follows it (the `TrayPath.originalsPath`
/// argument, made good a third time). The phone's Block History still has its
/// Came from region (`BlockHistoryPath.cameFromPath`). PROVISIONAL words
/// (#264).
nonisolated enum BlockLineagePath {
    /// The surface's name (the registry verb's noun).
    static let name = "Block Lineage"
    /// Where an original waits.
    static let place = "the block\u{2019}s Lineage"
    /// The same, with the way in spelled out.
    static let placeWithDoor =
        "the block\u{2019}s Lineage (block \u{25BE} \u{25B8} Lineage in the bottom bar)"
}

/// **WHAT A COMMIT'S RESTING LINE SAYS, ON THE MAC** (VX-144; VX-674 her
/// ruling) — the parts the Commits face's rail still reads: an unnamed
/// commit rests on its first words, muted; a named one on its name. (The
/// panel's row anatomy — the ◦ glyph, the longer preview, the details line,
/// the toggle's words — retired with the panel.)
nonisolated enum CommitRowFace {
    /// **VX-674 (her ruling on P-440-9's flagged gap, QUESTIONS #249) — an
    /// UNNAMED commit's resting words.** A NAMED commit keeps its name alone
    /// (nil here); the quiet mark is unchanged.
    static func restingWords(_ commit: CommitPoint) -> String? {
        guard SavepointRowFace.name(commit) == nil else { return nil }
        return restingPreview(commit.text)
    }

    /// The resting preview's character cap — far past what one line shows, so
    /// the layout's truncation is what the eye meets; the bound is the cost's.
    static let restingCap = 160

    /// The resting preview over a moment's text: leading blank lines and
    /// spaces dropped, the FIRST LINE only, capped by `Character` so a cut can
    /// never split a grapheme, trailing spaces trimmed, no ellipsis of its own
    /// (VX-144's "…had.…" lesson); an empty moment says so in the take's own
    /// words (PROVISIONAL P-674-1).
    static func restingPreview(_ text: String) -> String {
        let body = text.drop { $0.isWhitespace }
        guard !body.isEmpty else { return BlockPastCopy.emptyTake }
        let line = body.prefix(restingCap).prefix { !$0.isNewline }
        var words = String(line)
        while let last = words.last, last.isWhitespace { words.removeLast() }
        return words
    }

    /// A quiet moment's hover words (the rail's quiet dot — the panel row's
    /// ◦ glyph retired with the row; the rail's legend draws it as a small
    /// hollow dot, and "quiet" rides the pane's meta line).
    static let quietGlyphHelp = "A quiet commit \u{2014} the app saved this moment on its own"

    /// The automatic commit's one word (`SavepointRowFace`'s, kept).
    static let quietMark = "quiet"
}
