//
//  MobileTodayDoor.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — Today's Entry (M7): create-or-open THE day's
//  entry (the notebook rule, `createOrOpenJournalEntry`) plus the SHARED
//  daily-book shelving half (`Operations.shelveInDailyJournalBook` — the
//  one implementation all four doors share since 13c batch 1D + the 13d
//  #37(iii) ruling: it CREATES AND PINS the Journal book when none is
//  designated, never blocks the mint, and never re-shelves a membership
//  she removed). Both halves run in ONE runner closure — the Mac
//  `JournalBooks.openToday` composition, the phone's edition.
//
//  Since parity C2 the wordings point at the PHONE'S OWN doors (the
//  no-redirect principle — the book-details surface holds finish/reopen
//  and the daily designation, so the old "on the Mac" tails dissolved
//  with the doors' arrival): every outcome the shared helper can report
//  speaks, and a clean shelving says nothing (P-2: the door acts; where
//  it cannot, it speaks honestly). The Phase 8 A1-class pins live in
//  `MobileShellTests`.
//

import Foundation
import SwiftUI
import VariorumCore

@MainActor
enum MobileTodayDoor {
    struct Outcome: Equatable {
        let postID: String
        /// nil when there is nothing to say (shelved / already decided).
        let note: String?
    }

    /// Opens (or mints) the day's entry and shelves it into the daily
    /// journal book. `day` is injectable for tests; nil = the user's
    /// calendar day now.
    static func open(
        session: AppSession, day: String? = nil, calendar: Calendar = .current
    ) async throws -> Outcome {
        let entryDay = day ?? JournalDay.dayString(from: Date(), calendar: calendar)
        // VM-58: the wing she stands in — Core's own input (VX-435): a living
        // Journal's entry is born beside the Journal, wherever it is; only
        // when NO Journal lives do the entry and the fresh Journal land
        // where she stands. The Mac's Today door passes the same.
        let standingWing = session.wing.currentID
        let opened: (postID: String, shelving: Operations.DailyBookShelving) =
            try await session.runner.run { ops in
                let entry = try ops.createOrOpenJournalEntry(
                    entryDate: entryDay, standingWing: standingWing)
                return (entry.container.id,
                        ops.shelveInDailyJournalBook(entry.container.id))
            }
        // Act 0 (R-pre13u-1): a door that put content in the store says so.
        // Announce and move on — nothing here awaits what it starts. This
        // door in particular can beat the furniture to the Journal book
        // (`shelveInDailyJournalBook` creates and pins one itself), which
        // is why the starter Journal's mint re-checks inside its own turn.
        session.noteFirstWrite()
        return Outcome(postID: opened.postID, note: shelvingNote(opened.shelving))
    }

    /// The phone's wording for a shelving outcome — nil when there is
    /// nothing to say. Since parity C2 every note names a PHONE road
    /// (inventory #8/#9/#10 dissolved — the book-details surface holds
    /// finish/reopen and the daily designation; extents stay unbuilt by
    /// LK5's ranking, so the full-book note names the designation road).
    static func shelvingNote(_ shelving: Operations.DailyBookShelving) -> String? {
        switch shelving {
        case .shelved, .alreadyDecided:
            return nil
        case .bookFinished:
            return "Entry saved. Your daily journal book is finished, so it wasn't added — reopen it from its book details."
        case .bookAtCapacity:
            return "Entry saved. Your daily journal book is full, so it wasn't added — choose another book as your daily journal (a book's details has the door)."
        case .wrongKind:
            return "Entry saved. Your daily journal is a smart book, which can't hold entries — choose a hand-picked book as your daily journal (a book's details has the door)."
        // 13i-c U2 (the sitting record §6): book ownership kept the entry
        // from joining on its own — it waits at the journal's door.
        case .waitingAtDoor:
            return "Entry saved. It's waiting at your daily journal's door — it already "
                + "lives in another book, and one of them owns its notes."
        case .refused(let reason):
            return "Entry saved, but it wasn't added to your daily journal book: \(reason)"
        }
    }
}

/// P33 (parity A3, her ruled flip: "the SHELF gains its own + New Note
/// door") — the ONE bookless mint both tabs share: the Library's door and
/// the shelf's twin call exactly this, so the mint path cannot fork. The
/// Mac ⌘N's semantics (NO stored placeholder title, 13g R6-3); a bookless
/// mint lands in the Pool filter, honestly; both doors open the note for
/// writing (the landing is part of the twin promise).
@MainActor
enum MobileNewNoteDoor {
    /// The door's WORD — since VM-255 a book's own foot row (`MobileBookView`,
    /// the Mac book's "+ new note" twin); voice-cased at render; pinned.
    static let doorTitle = "+ New Note"

    /// **The roots' door is a writing glyph** (VM-255, her words: "new note
    /// should also be a writing icon, the way it's a writing icon on the mac
    /// app") — the Mac toolbar's New Note (`RootView`'s `square.and.pencil`);
    /// S-260-2, the Mac's SYMBOL, never its view.
    static let symbol = "square.and.pencil"
    /// The glyph door's name — spoken, and the word the pins drive it by.
    static let spokenName = "New Note"

    /// Mints the nameless bookless note; returns its id.
    ///
    /// VM-58: born in the wing the phone stands in (the Mac's ⌘N: "what she
    /// makes there lives there") — so it lands in that wing's Pool.
    static func mint(session: AppSession) async throws -> String {
        let wing = session.wing.currentID
        let id = try await session.runner.run { ops in
            try ops.createPost(title: nil, wingId: wing)
        }.id
        // Act 0 (R-pre13u-1): the first-write signal. Announce, move on.
        session.noteFirstWrite()
        return id
    }
}

/// **The roots' New Note door — the writing glyph** (VM-255): the phone's icon
/// button (the glyph at the layer's icon size, a 44 × 44 hit area) in the accent
/// the word door wore; the root's own act (mint, then open for writing).
struct MobileNewNoteGlyphDoor: View {
    let tokens: VoiceTokens
    let act: () -> Void

    var body: some View {
        Button(action: act) {
            Image(systemName: MobileNewNoteDoor.symbol)
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens, tone: .accent))
        .accessibilityLabel(MobileNewNoteDoor.spokenName)
    }
}

// (The Bookcase path line's Settings gear — VM-50, P-47-9 — retired into the
// roots' ⋯ menu at VM-53, and the ⋯ became a gear again at VM-255:
// `MobileSettingsGear.swift`, where `MobileSettingsDoor` is the shell's
// Settings door itself.)
