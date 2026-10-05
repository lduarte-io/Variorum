//
//  BookStateDoors.swift
//  Variorum
//
//  13i-c U3 — THE BOOK'S STATE DOORS (the sitting record §5, §6, §24; the
//  13i-c plan §5 and R-13ic-3). Finished · Sealed · Owned, each a PAIR of
//  acts (Finish/Reopen · Seal…/Unseal · Own Its Notes…/Stop Owning), plus
//  the Trash door R-13ic-4's gathering gate needs. Her one line is the
//  vocabulary: "Finished = the table of contents is done; Sealed = the book
//  is done." The ladder reads open → finished → sealed going up, and
//  sealed → open in ONE step down (R-13ic-3: "Unseal reopens the book too").
//
//  Two surfaces render these doors — the shelf row's menu and the Book
//  Settings sheet's STATE section — so everything a door IS lives here, in
//  four movable pieces (P-9), never in either surface:
//
//  1. **WHICH doors render** — `BookStateDoorSet`, a pure table over the
//     book's facts (P-1: gating is data, never a per-view if).
//  2. **THE WORDS** — `BookStateCopy`: every confirm's sentences and every
//     receipt are static copy on a pure type, so pins read them without a
//     window (the `BindCopy` precedent).
//  3. **THE MODEL** — `BookStateDoors`: read the preview the operation acts
//     on, then confirm or act; perform through the one operation; speak the
//     receipt or the operation's own refusal on the 18i status seam.
//  4. **THE FACE** — `BookStateConfirmSheet`: ONE renderer for every
//     confirm; it decides nothing.
//
//  The confirms LIST what a ceremony will do before it does it — the forks
//  a seal makes, the copies owning makes (her ruling: "the one
//  copy-as-consequence in the design is never silent") — read from the SAME
//  predicate the operation acts on (`Queries.sealPreview`,
//  `Queries.ownConversionPreview` — both `sharedMembers`), so a confirm can
//  never name a different set than the act forks.
//

import SwiftUI
import VariorumCore

// MARK: - Which doors render (data)

/// The facts the door table reads — a book's state, nothing else.
nonisolated struct BookStateFacts: Equatable, Sendable {
    var isBook: Bool
    var finished: Bool
    var sealed: Bool
    var owned: Bool

    init(isBook: Bool, finished: Bool, sealed: Bool, owned: Bool) {
        self.isBook = isBook
        self.finished = finished
        self.sealed = sealed
        self.owned = owned
    }

    init(_ reading: Reading) {
        self.init(
            isBook: reading.kind == .book, finished: reading.locked,
            sealed: reading.sealedAt != nil, owned: reading.owned)
    }
}

/// **WHICH STATE DOORS A BOOK RENDERS** — one pure table both surfaces read.
///
/// - The finish pair: Finish on an open book, Reopen on a finished one, and
///   NEITHER on a sealed book — `unlockReading` refuses a sealed book
///   (`readingSealed`; the one door down from Sealed is Unseal), so a Reopen
///   there could never act (P-2). The sheet shows its Finished control
///   disabled with the sealed words instead.
/// - The seal pair and the own pair: BOOKS only — both operations refuse a
///   gathering (`wrongReadingKind`: owning or sealing a gathering is a
///   category error, the sitting record §6), so a gathering never renders
///   them (P-2).
/// - Own Its Notes… still renders on a finished or sealed book: the operation
///   refuses there (`lockedReading`, PROVISIONAL P-13ic-2) WITH a road — reopen
///   (or unseal) first — and the door speaks exactly that (the brief: "refused
///   on a finished/sealed book with the op's words").
/// - **A GATHERING HAS NO FINISH** (13i-d U3 — KnownIssues row 107: P-13ic-U3-2
///   ruled to the sitting record §3's letter at the 13i-c adjudication; the
///   Bookcase's shelf-menu filter, U1's P-13id-U1-9, folds in HERE — F-U1-8 —
///   so the shelf menu and the settings sheet read one table): an open
///   gathering renders no state door at all; one ALREADY finished (13i-b
///   shipped Finish on a gathering) renders Reopen alone, as its way out.
///   Whether the OPERATIONS also refuse a gathering's finish is row 107's (c)
///   arm — proposed in the 13i-d U3 RECORD and stopped for the architect.
nonisolated enum BookStateDoorSet {
    static let all: [CapabilityID] = [
        .finishBook, .reopenBook, .sealBook, .unsealBook, .ownBook, .unownBook,
    ]

    static func rendered(for facts: BookStateFacts) -> [CapabilityID] {
        guard facts.isBook else {
            return facts.finished ? [.reopenBook] : []
        }
        var acts: [CapabilityID] = []
        if !facts.sealed {
            acts.append(facts.finished ? .reopenBook : .finishBook)
        }
        acts.append(facts.sealed ? .unsealBook : .sealBook)
        acts.append(facts.owned ? .unownBook : .ownBook)
        return acts
    }
}

/// The facts the ARCHIVE table reads (13i-e U2): whether the book is archived,
/// and whether it wears the daily marker — read through
/// `Queries.isDailyJournalMintShape`, the SAME predicate the delete ops' guard
/// keys on, so a face can never offer a delete the op refuses.
nonisolated struct BookArchiveFacts: Equatable, Sendable {
    var archived: Bool
    var isDailyJournal: Bool

    init(archived: Bool, isDailyJournal: Bool) {
        self.archived = archived
        self.isDailyJournal = isDailyJournal
    }

    init(_ reading: Reading) {
        self.init(
            archived: reading.archivedAt != nil,
            isDailyJournal: Queries.isDailyJournalMintShape(reading))
    }
}

/// **WHICH OF ARCHIVE · UNARCHIVE · DELETE A BOOK RENDERS** (13i-e U2 — her
/// rulings R-13ie-1…4 and the sitting record §10) — one pure table every
/// renderer reads (P-1: gating is data, never a per-view if):
/// - archived ⇒ **Unarchive**, else **Archive** — books AND gatherings
///   (R-13ie-3: "gatherings archive too, same door");
/// - **Delete** on every reading EXCEPT the daily Journal: "the daily Journal
///   can be archived, never deleted; it returns when a day arrives" — the op
///   refuses it (`dailyJournalCannotBeDeleted`), so a Delete there could
///   never act (P-2) and Archive stands in its place.
/// Each surface draws the subset its door family carries (the Bookcase row:
/// Archive + Delete — an archived book is never on it; the Archived surface's
/// rows: Unarchive + Delete; the settings sheet: Archive/Unarchive).
nonisolated enum BookArchiveDoorSet {
    static let all: [CapabilityID] = [.archiveBook, .unarchiveBook, .deleteBook]

    static func rendered(for facts: BookArchiveFacts) -> [CapabilityID] {
        var acts: [CapabilityID] = [facts.archived ? .unarchiveBook : .archiveBook]
        if !facts.isDailyJournal { acts.append(.deleteBook) }
        return acts
    }
}

// MARK: - The words

/// A confirm, whole — the sheet's item, carrying everything it says (the
/// `BindOffer` lesson: the item is the sheet's only input, so nothing it
/// renders can be read from a stale second piece of state).
nonisolated struct BookStateConfirm: Identifiable, Equatable, Sendable {
    let act: CapabilityID
    let readingID: String
    let title: String
    /// The sentences above the list.
    let lines: [String]
    /// The listed notes (a fork's / a copy's name and where else it lives).
    let list: [String]
    /// The sentences below the list (§24's waiting line rides here).
    let after: [String]
    let confirmLabel: String
    /// A SECOND way through the same door — the owned book's delete ("Delete
    /// Book and Its N Notes", 13i-c U4 — the sitting record §6's two-choice
    /// confirm). nil for every one-choice confirm.
    var alternateLabel: String? = nil

    var id: String { "\(act.rawValue)|\(readingID)" }
}

/// Every word the state doors say. Wording PROVISIONAL — 13s re-voices the
/// app; the TRUTH each sentence states is ruled (the sitting record §5, §6,
/// §24; the §25 lessons 1, 5, 6 — no sentence here may make one false).
nonisolated enum BookStateCopy {
    // The registry's verbs (title case — the shelf menu's own grammar).
    static let finishVerb = "Finish"
    static let reopenVerb = "Reopen"
    static let sealVerb = "Seal\u{2026}"
    static let unsealVerb = "Unseal"
    static let ownVerb = "Own Its Notes\u{2026}"
    static let unownVerb = "Stop Owning"
    static let deleteVerb = "Delete Book"
    /// R-13ic-4's door on the rule editor's gathering gate.
    static let deleteGatheringDoor = "Delete this gathering\u{2026}"

    static let unavailableNote =
        "A book's state lives on the book \u{2014} right-click it on the Bookcase, or open its "
        + "settings (the gear)."

    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    // MARK: Finish (§24 — the confirm carries ONE line, and only when N > 0)

    /// §24's line ("N waiting at the door will be dismissed"), its door
    /// re-worded to the ONE word at 17y B3 item (h) — R-17y-2: "the door
    /// line's 'N at the door' idiom re-words to the Arrivals family"
    /// (PROVISIONAL P-17y-B3-h3 on the sentence; 13s re-voices).
    static func waitingLine(_ count: Int) -> String {
        "\(count) waiting at \(ArrivalsCopy.word) will be dismissed."
    }

    /// The finish asks ONLY when something is waiting — else it acts.
    static func finishNeedsConfirm(pendingArrivals: Int) -> Bool { pendingArrivals > 0 }

    static func finish(readingID: String, name: String, pendingArrivals: Int) -> BookStateConfirm {
        BookStateConfirm(
            act: .finishBook, readingID: readingID,
            title: "Finish \(quoted(name))?",
            lines: [waitingLine(pendingArrivals)], list: [], after: [],
            confirmLabel: "Finish")
    }

    // MARK: Seal (§5 — the forks LISTED; finishing too; the waiting line)

    /// Lesson 6's second sentence, the seal's own promise.
    static let sealLead =
        "Sealed means the book is done: no note in it can change until you unseal it."
    static let sealFinishesToo = "Sealing finishes the book too."
    static let sealOwnedNoForks = "It owns its notes, so nothing needs copying."
    static let noForks = "None of its notes lives in another book, so nothing needs copying."
    static let sealForksLead =
        "These notes also live in other books, so each gets its own copy here, sealed with "
        + "the book \u{2014} the originals stay where they are, still editable:"

    /// One note a ceremony will copy: its name and where else it lives (the
    /// app's own value, mapped from `Queries.SharedMember` — so the words are
    /// pinned without a database).
    struct Fork: Equatable, Sendable {
        let title: String
        let elsewhere: [String]

        init(title: String, elsewhere: [String]) {
            self.title = title
            self.elsewhere = elsewhere
        }

        init(_ member: Queries.SharedMember) {
            self.init(title: member.title, elsewhere: member.elsewhere.map(\.name))
        }
    }

    static func seal(
        readingID: String, name: String, finished: Bool, owned: Bool,
        forks: [Fork], pendingArrivals: Int
    ) -> BookStateConfirm {
        var lines = [sealLead]
        if !finished { lines.append(sealFinishesToo) }
        if forks.isEmpty {
            lines.append(owned ? sealOwnedNoForks : noForks)
        } else {
            lines.append(sealForksLead)
        }
        return BookStateConfirm(
            act: .sealBook, readingID: readingID,
            title: "Seal \(quoted(name))?",
            lines: lines, list: forks.map(forkLine),
            after: pendingArrivals > 0 ? [waitingLine(pendingArrivals)] : [],
            confirmLabel: "Seal")
    }

    /// One listed note: its name and where else it lives.
    static func forkLine(_ fork: Fork) -> String {
        "\(fork.title) \u{2014} also in "
            + fork.elsewhere.map(quoted).joined(separator: ", ")
    }

    // MARK: Unseal (R-13ic-3 — it REOPENS the book)

    static let unsealLead =
        "Unsealing reopens the book too: its notes can change again, and it is no longer "
        + "finished."
    static let unsealCatchUp =
        "Anything that matched its rule while it was sealed waits at Arrivals."
    static let unsealIndependent = "A note you sealed on its own stays sealed."

    static func unseal(readingID: String, name: String, collects: Bool) -> BookStateConfirm {
        var lines = [unsealLead]
        if collects { lines.append(unsealCatchUp) }
        lines.append(unsealIndependent)
        return BookStateConfirm(
            act: .unsealBook, readingID: readingID,
            title: "Unseal \(quoted(name))?",
            lines: lines, list: [], after: [], confirmLabel: "Unseal")
    }

    // MARK: Own (§6 — the copies LISTED)

    /// Lessons 1 and 5, the owned book's promise.
    static let ownLead =
        "An owned book is the only place its notes live \u{2014} put one of them in another "
        + "book and you'll get a copy."
    static let ownForksLead =
        "These notes also live in other books. Each gets its own copy here; the originals "
        + "stay in their other books:"

    static func own(
        readingID: String, name: String, forks: [Fork]
    ) -> BookStateConfirm {
        BookStateConfirm(
            act: .ownBook, readingID: readingID,
            title: "Make \(quoted(name)) own its notes?",
            lines: [ownLead, forks.isEmpty ? noForks : ownForksLead],
            list: forks.map(forkLine), after: [],
            confirmLabel: "Own Its Notes")
    }

    // MARK: Delete (R-13ic-4's gathering gate — the ordinary Trash road)

    static func deleteGathering(readingID: String, name: String) -> BookStateConfirm {
        BookStateConfirm(
            act: .deleteBook, readingID: readingID,
            title: "Delete \(quoted(name))?",
            lines: [
                "It goes to the Trash \u{2014} Put back returns it for \(TrashWindow.days) days.",
                "No note is touched: a gathering holds none.",
            ],
            list: [], after: [], confirmLabel: "Delete Gathering")
    }

    // MARK: Delete a BOOK (13i-c U4 — the sitting record §6; lesson 8: "Deleting
    // a plain book never touches a note. Deleting an owned book asks: keep the
    // notes (they go to the Pool) or take them too. The Trash gives back
    // whatever went in together, together.")

    static func notes(_ count: Int) -> String { count == 1 ? "1 note" : "\(count) notes" }

    static let trashLine =
        "It goes to the Trash \u{2014} Put back returns it for \(TrashWindow.days) days."

    /// A PLAIN book's confirm — book-only, and it says why: a plain book's
    /// notes were never "its" notes (§6's asymmetry, visible at the door).
    static func deletePlainBook(readingID: String, name: String, notes count: Int) -> BookStateConfirm {
        BookStateConfirm(
            act: .deleteBook, readingID: readingID,
            title: "Delete \(quoted(name))?",
            lines: [
                count == 0
                    ? "Deleting a plain book never touches a note."
                    : "Deleting a plain book never touches a note \u{2014} its \(notes(count)) "
                        + "stay where they are, in the Library and any other book.",
                trashLine,
            ],
            list: [], after: [], confirmLabel: "Delete Book")
    }

    /// An OWNED book's TWO-CHOICE confirm (§6): the book only (its notes go
    /// to the Pool — nothing of hers destroyed) or the book AND its N notes
    /// (both to the Trash on one stamp — Put back returns them together).
    /// An owned book with no notes has nothing to choose: one button.
    static func deleteOwnedBook(readingID: String, name: String, notes count: Int) -> BookStateConfirm {
        guard count > 0 else {
            return BookStateConfirm(
                act: .deleteBook, readingID: readingID,
                title: "Delete \(quoted(name))?",
                lines: ["\(quoted(name)) owns its notes, and holds none right now.", trashLine],
                list: [], after: [], confirmLabel: "Delete Book")
        }
        return BookStateConfirm(
            act: .deleteBook, readingID: readingID,
            title: "Delete \(quoted(name))?",
            lines: [
                "\(quoted(name)) owns its notes. Delete the book only, and its \(notes(count)) "
                    + "go back to the Pool \u{2014} or delete the book and its \(notes(count)) "
                    + "together.",
                "Either way the book goes to the Trash for \(TrashWindow.days) days \u{2014} and "
                    + "Put back returns whatever went in together, together.",
            ],
            list: [], after: [], confirmLabel: "Delete Book Only",
            alternateLabel: count == 1
                ? "Delete Book and Its Note" : "Delete Book and Its \(count) Notes")
    }

    /// A plain book's delete landed — its notes untouched (lesson 8).
    static func deletedPlainBook(_ name: String) -> String {
        deleted(name) + " Its notes are untouched."
    }

    /// Book-only, owned: the notes are in the Pool now.
    static func deletedBookOnly(_ name: String, released count: Int) -> String {
        count == 0
            ? deleted(name)
            : "Deleted \(quoted(name)) \u{2014} it\u{2019}s in the Trash; its \(notes(count)) "
                + "\(count == 1 ? "is" : "are") in the Pool now."
    }

    /// With its notes: one stamp, one Put back.
    static func deletedWithNotes(_ name: String, notes count: Int) -> String {
        "Deleted \(quoted(name)) and its \(notes(count)) \u{2014} they\u{2019}re in the Trash "
            + "together; Put back on the book returns them together."
    }

    // MARK: Archive (13i-e U2 — R-13ie-1…4: kept forever, off the Bookcase;
    // the OWNED book's two-choice confirm is the delete confirm's twin)

    static let archiveVerb = "Archive"
    static let unarchiveVerb = "Unarchive"

    /// The door's label: an OWNED book's Archive ASKS (the two choices), so it
    /// carries the ellipsis; every other Archive acts at once.
    static func archiveDoorLabel(asks: Bool) -> String { asks ? archiveVerb + "\u{2026}" : archiveVerb }

    /// Whether the Archive door asks — an owned BOOK only (R-13ie-2: "a PLAIN
    /// book archives alone"; a gathering holds no notes).
    static func archiveAsks(_ reading: Reading) -> Bool { reading.kind == .book && reading.owned }

    /// The keep-forever promise (her rider: "you do want to keep it forever").
    static let keptLine =
        "Either way it's kept under Archived, with no countdown \u{2014} and Unarchive brings "
        + "back whatever went in together, together."

    /// An OWNED book's TWO-CHOICE archive confirm (R-13ie-2 — lesson 8's
    /// delete shape, mirrored): the book only (its notes stay in the Library,
    /// still its own — membership is a fact) or the book AND its N notes on
    /// one stamp. An owned book with no notes has nothing to choose.
    static func archiveOwnedBook(readingID: String, name: String, notes count: Int) -> BookStateConfirm {
        guard count > 0 else {
            return BookStateConfirm(
                act: .archiveBook, readingID: readingID,
                title: "Archive \(quoted(name))?",
                lines: [
                    "\(quoted(name)) owns its notes, and holds none right now.",
                    "It's kept under Archived, with no countdown \u{2014} Unarchive brings it back.",
                ],
                list: [], after: [], confirmLabel: "Archive Book")
        }
        return BookStateConfirm(
            act: .archiveBook, readingID: readingID,
            title: "Archive \(quoted(name))?",
            lines: [
                "\(quoted(name)) owns its notes. Archive the book only, and its \(notes(count)) "
                    + "stay in the Library \u{2014} still its own \u{2014} or archive the book and "
                    + "its \(notes(count)) together.",
                keptLine,
            ],
            list: [], after: [], confirmLabel: "Archive Book Only",
            alternateLabel: count == 1
                ? "Archive Book and Its Note" : "Archive Book and Its \(count) Notes")
    }

    /// The archive landed — its receipt names the road back, in the reading's
    /// own terms (a gathering shows nothing; the daily Journal comes back).
    static func archived(_ name: String, kind: ReadingKind, dailyJournal: Bool) -> String {
        let base = "Archived \(quoted(name)) \u{2014} it\u{2019}s kept under Archived"
        if dailyJournal { return base + ", and it comes back when a day arrives." }
        if kind == .gathering { return base + " and shows nothing until you unarchive it." }
        return base + "; its notes stay where they are."
    }

    /// With its notes: one stamp, one Unarchive.
    static func archivedWithNotes(_ name: String, notes count: Int) -> String {
        "Archived \(quoted(name)) and its \(notes(count)) \u{2014} they\u{2019}re kept under "
            + "Archived together; Unarchive on the book brings them back together."
    }

    /// Unarchive landed: what came back with it, and what now waits at its
    /// door (a living book's catch-up bells, never quiet seats — R-13ie-4).
    static func unarchived(_ name: String, returned: Int, waiting: Int) -> String {
        var line = "Unarchived \(quoted(name)) \u{2014} it\u{2019}s back on the Bookcase."
        if returned > 0 {
            line += returned == 1
                ? " Its note came back with it." : " Its \(returned) notes came back with it."
        }
        if waiting > 0 { line += " \(waiting) waiting at Arrivals." }
        return line
    }

    // MARK: The navigator's state chip (13i-c U4 — F-U3-7)

    /// The book navigator's one state word: "✓ sealed" on a SEALED book (it
    /// is finished too — "Sealed = the book is done" is the truer word),
    /// "✓ finished" on a finished one, nothing on an open one. 13i-e U2: an
    /// ARCHIVED book says so first — a book opened from Archived wears where
    /// it lives (PROVISIONAL P-13ie-U2-4).
    static func navigatorChip(finished: Bool, sealed: Bool, archived: Bool = false) -> String? {
        let state: String? = sealed ? "\u{2713} sealed" : (finished ? "\u{2713} finished" : nil)
        guard archived else { return state }
        return [BookArchiveCopy.word, state].compactMap { $0 }.joined(separator: " \u{00B7} ")
    }

    // MARK: Receipts (the 18i seam's RECEIPT class)

    static func finished(_ name: String) -> String {
        "Finished \(quoted(name)) \u{2014} its table of contents is done; the writing inside "
            + "can still change."
    }

    static func reopened(_ name: String) -> String { "Reopened \(quoted(name))." }

    static func sealed(_ name: String, forks: Int) -> String {
        let base = "Sealed \(quoted(name)) \u{2014} the book is done."
        switch forks {
        case 0: return base
        case 1: return base + " 1 shared note got its own copy here."
        default: return base + " \(forks) shared notes got their own copies here."
        }
    }

    static func unsealed(_ name: String) -> String {
        "Unsealed \(quoted(name)) \u{2014} it's open again."
    }

    static func owned(_ name: String, copies: Int) -> String {
        let base = "\(quoted(name)) owns its notes now."
        switch copies {
        case 0: return base
        case 1: return base + " 1 note that lived elsewhere got its own copy here."
        default: return base + " \(copies) notes that lived elsewhere got their own copies here."
        }
    }

    static func unowned(_ name: String) -> String {
        "\(quoted(name)) no longer owns its notes \u{2014} they stay, and can live in other "
            + "books too."
    }

    static func deleted(_ name: String) -> String {
        "Deleted \(quoted(name)) \u{2014} it's in the Trash."
    }

    // MARK: Refusals (the operation's own, named for its book)

    /// The finish ladder's refusal names the door that lifts it: a FINISHED
    /// book's way out is Reopen; a SEALED book's is Unseal (Reopen refuses
    /// there). Everything else speaks the shared table, then the books table.
    @MainActor
    static func refusal(for error: Error, name: String, sealed: Bool) -> String {
        if case OperationError.lockedReading = error {
            return sealed
                ? "\(quoted(name)) is sealed \u{2014} unseal it first (that reopens it too)."
                : "\(quoted(name)) is finished \u{2014} reopen it first."
        }
        return OpsRefusalCopy.macWords(for: error)
            ?? OpsRefusalCopy.words(for: error, roads: .mac)
            ?? ReadingsViewModel.message(error)
    }
}

// MARK: - The model

/// The state doors' one brain, shared by every surface that renders them.
/// Holds the confirm item (the sheet's item) and nothing persisted; every
/// write is an operation's; every outcome speaks on the status seam.
@MainActor
@Observable
final class BookStateDoors {
    @ObservationIgnored let session: AppSession
    /// The confirm on screen — the host presents `.sheet(item:)` over it.
    var pending: BookStateConfirm?

    init(session: AppSession) {
        self.session = session
    }

    /// What a door read before deciding: the book, fresh, and its preview.
    private struct Opening: Sendable {
        let reading: Reading
        let pendingArrivals: Int
        let sealPreview: Queries.SealPreview
        let ownForks: [Queries.SharedMember]
        /// The delete confirm's N (13i-c U4).
        let memberNotes: Int
        /// The owned archive confirm's N (13i-e U2) — the set
        /// `archiveReadingWithNotes` takes (`Queries.archiveWithNotesCount`).
        var archiveNotes: Int = 0
    }

    /// **A door was pressed.** Reads the book FRESH (a shelf row's snapshot
    /// may be a moment old) and the preview its act's confirm lists, then
    /// asks or acts:
    /// - Finish asks only when something waits at the door (§24), else acts;
    /// - Seal, Unseal, Own and Delete always ask (each changes what the book
    ///   is, and Seal/Own may copy — never silently);
    /// - Reopen and Stop Owning act at once (each moves nothing she wrote).
    func open(_ act: CapabilityID, readingID: String) async {
        let opening: Opening
        do {
            guard let fetched = try await session.database.read({ db -> Opening? in
                guard let reading = try Queries.reading(db, id: readingID) else { return nil }
                return Opening(
                    reading: reading,
                    pendingArrivals: act == .finishBook
                        ? try Queries.pendingArrivalCount(db, readingID: readingID) : 0,
                    sealPreview: act == .sealBook
                        ? try Queries.sealPreview(db, readingID: readingID) : .none,
                    ownForks: act == .ownBook
                        ? try Queries.ownConversionPreview(db, readingID: readingID) : [],
                    memberNotes: act == .deleteBook
                        ? try Queries.liveMemberNoteCount(db, readingID: readingID) : 0,
                    archiveNotes: act == .archiveBook
                        ? try Queries.archiveWithNotesCount(db, readingID: readingID) : 0)
            }) else {
                session.status.refuse(ReadingsViewModel.message(
                    OperationError.readingNotFound(id: readingID)))
                return
            }
            opening = fetched
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return
        }
        let reading = opening.reading
        switch act {
        case .finishBook:
            if BookStateCopy.finishNeedsConfirm(pendingArrivals: opening.pendingArrivals) {
                pending = BookStateCopy.finish(
                    readingID: readingID, name: reading.name,
                    pendingArrivals: opening.pendingArrivals)
            } else {
                await perform(.finishBook, readingID: readingID)
            }
        case .sealBook:
            pending = BookStateCopy.seal(
                readingID: readingID, name: reading.name, finished: reading.locked,
                owned: reading.owned, forks: opening.sealPreview.forks.map(BookStateCopy.Fork.init),
                pendingArrivals: opening.sealPreview.pendingArrivals)
        case .unsealBook:
            let collects: Bool = if case .rule = RuleGrammar.read(reading.querySpec) {
                true
            } else {
                false
            }
            pending = BookStateCopy.unseal(
                readingID: readingID, name: reading.name, collects: collects)
        case .ownBook:
            // A finished (or sealed) book: the operation refuses owning
            // (`lockedReading` — converting forks members, a structural act;
            // P-13ic-2). The door speaks that refusal instead of a confirm
            // that could only fail — the `offerToBind` precedent (a finished
            // gathering hears the bind's refusal, never an offer). The
            // confirm's own act still goes through the operation, which
            // refuses on its own if the book is finished meanwhile.
            guard !reading.locked else {
                session.status.refuse(BookStateCopy.refusal(
                    for: OperationError.lockedReading(id: readingID),
                    name: reading.name, sealed: reading.sealedAt != nil))
                return
            }
            pending = BookStateCopy.own(
                readingID: readingID, name: reading.name,
                forks: opening.ownForks.map(BookStateCopy.Fork.init))
        case .deleteBook:
            // 13i-c U4 — THREE ARMS (the sitting record §6; F-U3-2): a
            // gathering's (U3's — it holds no note), a PLAIN book's (book-only;
            // it never touches a note), an OWNED book's TWO-CHOICE confirm
            // (book only · book and its N notes — the asymmetry is the
            // ownership concept, visible at the door). The N is the set
            // `deleteReadingWithNotes` takes.
            switch (reading.kind, reading.owned) {
            case (.gathering, _):
                pending = BookStateCopy.deleteGathering(readingID: readingID, name: reading.name)
            case (.book, true):
                pending = BookStateCopy.deleteOwnedBook(
                    readingID: readingID, name: reading.name, notes: opening.memberNotes)
            case (.book, false):
                pending = BookStateCopy.deletePlainBook(
                    readingID: readingID, name: reading.name, notes: opening.memberNotes)
            }
        case .archiveBook:
            // 13i-e U2 (R-13ie-2): an OWNED book asks — the delete confirm's
            // twin (book only · book and its N notes); a plain book, a
            // gathering and the daily Journal archive at once (archive is
            // reversible and kept forever — "not too onerous").
            if BookStateCopy.archiveAsks(reading) {
                pending = BookStateCopy.archiveOwnedBook(
                    readingID: readingID, name: reading.name, notes: opening.archiveNotes)
            } else {
                await perform(.archiveBook, readingID: readingID)
            }
        default:
            await perform(act, readingID: readingID)
        }
    }

    /// The confirm's button: perform the act it named. `alternate` is the
    /// confirm's SECOND choice (the owned book's delete-with-notes).
    func confirm(alternate: Bool = false) async {
        guard let item = pending else { return }
        pending = nil
        await perform(item.act, readingID: item.readingID, alternate: alternate)
    }

    func cancel() { pending = nil }

    /// **THE ACT** — exactly one operation per door, its receipt on success,
    /// its own refusal (named for the book) on failure. Returns whether it
    /// landed (the rule editor closes after a delete).
    @discardableResult
    func perform(_ act: CapabilityID, readingID: String, alternate: Bool = false) async -> Bool {
        let named = (try? await session.database.read { db in
            try Queries.reading(db, id: readingID)
        }) ?? nil
        let name = named?.name ?? ""
        let owned = named?.owned ?? false
        let database = session.database
        do {
            let receipt: String = try await session.runner.run { ops in
                switch act {
                case .finishBook:
                    try ops.lockReading(readingID)
                    return BookStateCopy.finished(name)
                case .reopenBook:
                    try ops.unlockReading(readingID)
                    return BookStateCopy.reopened(name)
                case .sealBook:
                    let result = try ops.sealReading(readingID)
                    return BookStateCopy.sealed(name, forks: result.forked.count)
                case .unsealBook:
                    try ops.unsealReading(readingID)
                    return BookStateCopy.unsealed(name)
                case .ownBook:
                    let result = try ops.setReadingOwned(readingID, owned: true)
                    return BookStateCopy.owned(name, copies: result.copied.count)
                case .unownBook:
                    try ops.setReadingOwned(readingID, owned: false)
                    return BookStateCopy.unowned(name)
                // 13i-e U2 — ARCHIVE / UNARCHIVE (R-13ie-1…4).
                case .archiveBook where alternate:
                    // The owned book's second choice: the book AND its notes,
                    // ONE stamp (offered only on an owned book).
                    let notes = try ops.archiveReadingWithNotes(readingID)
                    return BookStateCopy.archivedWithNotes(name, notes: notes.count)
                case .archiveBook:
                    try ops.archiveReading(readingID)
                    return BookStateCopy.archived(
                        name, kind: named?.kind ?? .book,
                        dailyJournal: named.map(Queries.isDailyJournalMintShape) ?? false)
                case .unarchiveBook:
                    // What now waits at the door: a LIVING book's resume
                    // catch-up bells (never seats) — read before and after.
                    let waiting = { () -> Int in
                        (try? database.read { db in
                            try Queries.pendingArrivalCount(db, readingID: readingID)
                        }) ?? 0
                    }
                    let before = waiting()
                    let returned = try ops.unarchiveReading(readingID)
                    return BookStateCopy.unarchived(
                        name, returned: returned.count, waiting: max(0, waiting() - before))
                case .deleteBook where alternate:
                    // The owned book's second choice: the book AND its notes,
                    // ONE stamp (F-U2-7: offered only on an owned book).
                    let notes = try ops.deleteReadingWithNotes(readingID)
                    return BookStateCopy.deletedWithNotes(name, notes: notes.count)
                case .deleteBook:
                    let released = owned
                        ? try database.read { db in
                            try Queries.liveMemberNoteCount(db, readingID: readingID)
                        } : 0
                    try ops.deleteReading(readingID)
                    if named?.kind == .gathering { return BookStateCopy.deleted(name) }
                    return owned ? BookStateCopy.deletedBookOnly(name, released: released)
                        : BookStateCopy.deletedPlainBook(name)
                default:
                    throw OperationError.readingNotFound(id: readingID)
                }
            }
            session.status.receipt(receipt)
            return true
        } catch {
            session.status.refuse(BookStateCopy.refusal(
                for: error, name: name, sealed: named?.sealedAt != nil))
            return false
        }
    }
}

// MARK: - The face

/// **ONE confirm renderer** for every state door (and the gathering's Trash
/// door). It decides nothing: it shows its item and reports the press.
struct BookStateConfirmSheet: View {
    let confirm: BookStateConfirm
    let onConfirm: () -> Void
    /// The confirm's second choice, when it has one (13i-c U4 — the owned
    /// book's "Delete Book and Its N Notes").
    var onAlternate: (() -> Void)? = nil

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(confirm.title)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(Array(confirm.lines.enumerated()), id: \.offset) { _, line in
                ChromeNotice(tokens: tokens, text: line, ink: tokens.ink, lines: 4)
            }
            if !confirm.list.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(Array(confirm.list.enumerated()), id: \.offset) { _, item in
                            // A note's title is her prose — never `chromeLabel`'d.
                            Text("\u{00B7} " + item)
                                .font(tokens.small)
                                .foregroundStyle(tokens.ink)
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: 180)
            }
            ForEach(Array(confirm.after.enumerated()), id: \.offset) { _, line in
                ChromeNotice(tokens: tokens, text: line, lines: 2)
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                if let alternate = confirm.alternateLabel, let onAlternate {
                    Button(tokens.chromeLabel(alternate)) {
                        onAlternate()
                        dismiss()
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                }
                Button(tokens.chromeLabel(confirm.confirmLabel)) {
                    onConfirm()
                    dismiss()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 460, alignment: .leading)
        .background(tokens.surface)
        #if DEBUG
        .onAppear { BookStateProbe.shown = confirm }
        .onDisappear { if BookStateProbe.shown == confirm { BookStateProbe.shown = nil } }
        #endif
    }
}

extension View {
    /// Hosts the state doors' confirm over any surface that renders them —
    /// ONE presentation road, so the shelf, the settings sheet and the rule
    /// editor's gate cannot drift. `onLanded` hears an act that LANDED (the
    /// rule editor closes after its gathering went to the Trash).
    func bookStateConfirms(
        _ doors: BookStateDoors, onLanded: ((CapabilityID) -> Void)? = nil
    ) -> some View {
        sheet(item: Bindable(doors).pending) { item in
            BookStateConfirmSheet(
                confirm: item,
                onConfirm: {
                    Task {
                        if await doors.perform(item.act, readingID: item.readingID) {
                            onLanded?(item.act)
                        }
                    }
                },
                onAlternate: {
                    Task {
                        if await doors.perform(
                            item.act, readingID: item.readingID, alternate: true) {
                            onLanded?(item.act)
                        }
                    }
                })
        }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED CONFIRM SAID, AS A TEST ORACLE** (the `BindDoorProbe`
/// pattern): recorded on appear, cleared on disappear. DEBUG only.
@MainActor
enum BookStateProbe {
    static var shown: BookStateConfirm?
}
#endif
