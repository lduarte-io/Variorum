//
//  MobileRecoveryDoors.swift
//  VariorumMobile
//
//  **THE TWO-ROOMS IA's DOOR DECLARATION** (round 2, batch 6c — her ruling,
//  QUESTIONS #84, verbatim: *"i read the proposal and I want this option:
//  **Two rooms** — The Mac's own asymmetry, translated literally. Archive
//  becomes a room you browse; the Trash becomes a utility you visit. Two
//  doors, two destinations, nothing shared."*).
//
//  Two rooms means two doors, and the trash door has **two renderers** — the
//  Library's path line and the Shelf's. That is the design record's finding
//  1 made real: **books live on the Shelf and a deleted book rows in the
//  Trash**, so a door reachable only from the Library would make deleting a
//  book from the Shelf a tab switch away from its own recovery. One
//  declaration here; the Library and the Shelf each render it.
//
//  **Why a declaration file at all, for what looks like two strings.** The
//  round's own drift class (MobileSoul §3, `KnownIssuesAndTechDebt`'s
//  forked-brains row) is a rule that lives twice because the second renderer
//  copied the first. The glyph, the accessibility word, and the destination
//  are one decision; a second copy of them on the Shelf is exactly how the
//  two path lines would come to disagree about what 🗑 means.
//
//  **The words are `RecoveryCopy`'s, never new ones.** `Trash` and
//  `Archived` are the shared section nouns both platforms already speak;
//  this file names DOORS, not sentences.
//

import SwiftUI
import VariorumCore

/// The Two-rooms doors, declared once.
///
/// **PROVISIONAL — the design record's Q7 (the word) and Q3 (glyph vs
/// word).** The Archive door and its room say **"Archived"** (the Mac's
/// surface noun, `RecoveryCopy.archivedSection`) and the Trash says
/// **"Trash"**; the trash door renders as the mockup's 🗑 glyph with the
/// word as its accessibility label. Both are one string each if she
/// re-words them.
enum MobileRecoveryDoors {
    /// Option 2's own drawing: *"A 🗑 glyph joins the path line."* The word
    /// rides as the accessibility label, so VoiceOver — and every pin —
    /// names the room rather than an emoji.
    static let trashGlyph = "\u{1F5D1}"

    /// What the trash door is CALLED (VoiceOver, and the pins' handle).
    static var trashLabel: String { RecoveryCopy.trashSection }

    /// The Library's trailing row, narrowed: it no longer claims deletion,
    /// so it can finally say what it is.
    static var archiveLabel: String { RecoveryCopy.archivedSection }
}

/// **THE FILTERLESS ROOMS' TRUNCATION SENTENCE, DECLARED ONCE** (added at
/// the 6c fix wave, m3/n9).
///
/// The Trash's marker ends *"— narrow the filter to see more"* because the
/// Trash HAS a filter to narrow. The Archive room does not (its filters are
/// her #85 batch's), and neither does Note ▸ Versions — so both say the same
/// shorter thing, and that makes it one sentence with one home rather than
/// two copies that drift the moment either room's wording is touched. It
/// lives beside the door declaration for the same stated reason that file
/// exists: a rule the second renderer copied is the round's own drift class.
nonisolated enum MobileRoomListing {
    static func truncationMarker(shown: Int) -> String {
        "Showing the first \(shown)."
    }

    /// **The TWO-NUMBER form, for a listing that knows its exact total** (the
    /// filter batch's cold review, m4).
    ///
    /// The one-number sentence above is honest where the total genuinely is
    /// not known: those rooms bound their FETCH at `window + 1`, so all they
    /// hold is *"there is at least one more"*. A listing whose delivery is
    /// WHOLE and whose window is a RENDER window knows exactly how many there
    /// are — the Library's books listing (`Queries.bookshelf` takes no limit)
    /// and the scraps area, which already speaks a two-number sentence of its
    /// own. Saying less than is known would be the omission, not the
    /// restraint.
    static func truncationMarker(shown: Int, of total: Int) -> String {
        "Showing the first \(shown) of \(total)."
    }
}

/// **The trash door, one renderer for both path lines.** A real `Button`
/// (§15's trap (b): a door a pin can drive), labelled with the room's word.
struct MobileTrashDoor: View {
    let tokens: VoiceTokens
    let act: () -> Void

    var body: some View {
        Button(action: act) {
            Text(MobileRecoveryDoors.trashGlyph)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MobileRecoveryDoors.trashLabel)
    }
}
