//
//  BookStateCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-78 batch A (VM-81, VM-83) — THE BOOK STATE DOORS' WORDS THE PHONE
//  SPEAKS TOO, hoisted out of the Mac's `Features/Readings/BookStateDoors.swift`
//  (MobileSoul §3: a brain built Mac-side in app-local code is a parity
//  defect; the fix is a hoist, never a phone copy). WORDS ONLY: the confirm
//  item (`BookStateConfirm`), the door tables (`BookStateDoorSet`,
//  `BookArchiveDoorSet`) and everything that reaches the capability registry
//  stay in the Mac's file — later waves hoist those (W-070, W-112). The Mac
//  extends this enum in that file, so every Mac call site and pin reads
//  exactly as before and every string is byte-identical.
//
//  Wording PROVISIONAL as it was on the Mac (13s re-voices the app); the
//  TRUTH each sentence states is ruled (the 13i sitting record §5, §6, §24).
//

import Foundation
import VariorumCore

nonisolated enum BookStateCopy {
    // The registry's verbs (title case — the shelf menu's own grammar).
    static let finishVerb = "Finish"
    static let reopenVerb = "Reopen"
    static let deleteVerb = "Delete Book"

    /// **VX-611 — the delete door's verb, chosen by the reading's KIND.** ONE
    /// capability (`.deleteBook`, P-1 — the registry keeps the book's verb as
    /// its declared word); every renderer of its door on a ROW (the Bookcase
    /// row's menu, `BookRowMenu`, the Archived books group's button, the
    /// phone's shelf row and Book Details) and the rule editor's gathering-gate
    /// hover draw these words instead of the registry's, so a gathering's door
    /// says what it deletes. Its confirm already did (`deleteGathering` —
    /// "Delete Gathering").
    static func deleteVerb(_ kind: ReadingKind) -> String {
        kind == .gathering ? "Delete Gathering" : deleteVerb
    }

    /// The row's door label: the kind's verb and the ellipsis (it asks first).
    static func deleteDoorLabel(_ kind: ReadingKind) -> String {
        deleteVerb(kind) + "\u{2026}"
    }

    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    /// The archived book's way out (13i-e U2) — VM-81 (W-120): the phone's
    /// Book Details draws it on an archived book.
    static let unarchiveVerb = "Unarchive"

    // MARK: Finish (§24 — the confirm carries ONE line, and only when N > 0)

    /// §24's line ("N waiting at the door will be dismissed"), its door
    /// re-worded to the ONE word at 17y B3 item (h) — R-17y-2: "the door
    /// line's 'N at the door' idiom re-words to the Arrivals family"
    /// (PROVISIONAL P-17y-B3-h3 on the sentence; 13s re-voices).
    static func waitingLine(_ count: Int) -> String {
        "\(count) waiting at \(ArrivalsCopy.word) will be dismissed."
    }

    /// The finish asks ONLY when something is waiting — else it acts. N is
    /// always `Queries.pendingArrivalCount` — the dismissal's own predicate
    /// (`pendingArrivalRowsWhere`), so a confirm can never promise a
    /// different number than `lockReading` takes.
    static func finishNeedsConfirm(pendingArrivals: Int) -> Bool { pendingArrivals > 0 }

    /// The finish confirm's title ("Finish “Ideas inbox”?").
    static func finishTitle(_ name: String) -> String { "Finish \(quoted(name))?" }

    // MARK: What Finished and Sealed mean (the settings sheet's captions)

    /// Her one line, the finished half ("Finished = the table of contents is
    /// done"): what a finished book IS, true on both platforms. The Mac's
    /// settings caption (`CollectingCopy.finishedCaption`) is this sentence
    /// and its own second one about how a finished book opens there.
    static let finishedMeans =
        "Finished means the table of contents is done \u{2014} the writing inside can still "
        + "change."

    /// …and the sealed half ("Sealed = the book is done"), the state's own
    /// caption (`CollectingCopy.sealedCaption` on the Mac).
    static let sealedMeans = "Sealed \u{2014} the book is done; no note in it can change."
}
