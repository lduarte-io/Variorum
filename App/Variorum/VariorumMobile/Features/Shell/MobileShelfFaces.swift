//
//  MobileShelfFaces.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf row's face brain, pure and pinned.
//
//  **LK5 (her look ruling, verbatim: "i think # of notes or tags matter
//  most for the library for books"):** book rows LEAD with the note count
//  and the book's tags; the other mocked faces rank behind — the daily
//  marker trails, and word progress / chapter counts / caps are
//  DELIBERATELY ABSENT from the phone shelf in v1 (recorded for the stage
//  gate; each is one aggregate away if a look round wants it).
//
//  **✓ finished is a STATE, not a stat** (LK5's rider): it rides the NAME
//  (" ✓" suffix, accent ink at the view) exactly as the Mac shelf row
//  renders it — never a meta-column statistic.
//
//  Tag display is LEAF-ONLY (the 13k K3 doctrine — chips display the
//  leaf; the full path stays the Mac's tooltip concern) — phone width
//  demands it and the ruling supplies it.
//
//  Mirrored SEMANTICS, never Mac chrome: the count/smart split is the Mac
//  `ShelfView.metaColumn`'s own (a smart book's membership is derived —
//  `postCount` counts `reading_post` rows, so smart books say "smart",
//  never a count); the tags-column source is `ShelfViewModel.tagsColumn`'s
//  (smart books show their own query tags — the spec IS their identity;
//  curated books show their member posts' most-applied paths).
//

import Foundation
import VariorumCore

nonisolated enum MobileShelfFaces {
    /// A tag path's displayed leaf ("life/goals/2024" → "2024"; a
    /// chapter NAME without "/" passes through unchanged).
    static func leaf(_ path: String) -> String {
        path.split(separator: "/").last.map(String.init) ?? path
    }

    /// The tags a book's row shows: smart → the spec's own query tags
    /// (tagsAll + tags, the Mac's order); curated → the most-applied
    /// member-post paths the caller aggregated (`Queries.shelfBookTags`).
    static func tagPaths(
        for book: Queries.ShelfBook, curatedTags: [String: [String]],
        ruleTags: [String: [String]] = [:]
    ) -> [String] {
        // 13u1 UNIT 1 (the sweep's P40): the smart-book rule is shared now
        // (`Shared/ShelfOrder.swift`) — this was a byte-identical copy of
        // the Mac's `ShelfViewModel.tagsColumn`, differing only in where the
        // curated aggregate came from. The face stays here; the brain does not.
        ShelfOrder.smartQueryTagPaths(of: book.reading, rulePaths: ruleTags)
            ?? curatedTags[book.reading.id] ?? []
    }

    /// The row's NAME text — the stored name plus the finished STATE
    /// (" ✓", the Mac grammar; the view adds accent ink and voice casing).
    /// THE one finished-state grammar (S3 ladder, NIT 2): every surface
    /// naming a book calls this — the book header respelled it once.
    static func name(for reading: Reading) -> String {
        reading.name + (reading.locked ? " ✓" : "")
    }

    static func name(for book: Queries.ShelfBook) -> String {
        name(for: book.reading)
    }

    /// The row's meta line, LK5-ordered: count · tags · daily. The count
    /// word follows the profile (journal books hold "entries" — the
    /// ratified mockup's own word; everything else holds "notes").
    static func meta(
        for book: Queries.ShelfBook, tagPaths: [String], isDaily: Bool
    ) -> String {
        var parts: [String] = []
        if book.reading.kind == .gathering {
            parts.append("smart")
        } else {
            let unit = Queries.hasJournalTrait(book.reading.profile) ? "entr" : "note"
            let count = book.postCount
            let word = unit == "entr" ? (count == 1 ? "entry" : "entries")
                                      : (count == 1 ? "note" : "notes")
            parts.append("\(count) \(word)")
        }
        if !tagPaths.isEmpty {
            parts.append(tagPaths.map { "#\(leaf($0))" }.joined(separator: " "))
        }
        if isDaily { parts.append("daily") }
        return parts.joined(separator: " · ")
    }

    /// **What a book ROW says aloud** — its name-with-state AND its meta line,
    /// PLAIN (the standing rule: VoiceOver reads words, not chrome styling, so
    /// a label is never voice-cased).
    ///
    /// It exists because an explicit `accessibilityLabel` on a row REPLACES the
    /// composed one SwiftUI would have built from the row's children — measured
    /// at the filter batch: labelling the Library's book rows with the name
    /// alone dropped the count and tags out of the accessibility tree
    /// entirely, while the Shelf's own rows (which set no label) still spoke
    /// both. One rule, so the two listings cannot come to say different things
    /// about the same book.
    static func spokenRow(name: String, meta: String) -> String {
        meta.isEmpty ? name : "\(name), \(meta)"
    }

    /// The pin door's word, state-mirroring (parity C2 — the Mac shelf
    /// menu's own words; voice-cased at render). Pure so the door's
    /// vocabulary is pinned, not promised.
    static func pinDoorTitle(pinned: Bool) -> String {
        pinned ? "Unpin from Shelf Top" : "Pin to Shelf Top"
    }

    /// Shelf order — **the Mac's own rule, not a mirror of it, since 13u1
    /// UNIT 1** (the sweep's P40 hoisted the two byte-identical copies into
    /// `Shared/ShelfOrder.swift`): pinned books first in pin order (R38),
    /// then journal-profile books by name, then the rest by name. A
    /// forwarder, so every phone caller and pin reads as it did.
    static func ordered(
        books: [Queries.ShelfBook], pins: [String]
    ) -> [Queries.ShelfBook] {
        ShelfOrder.ordered(books: books, pins: pins)
    }

    // MARK: - Today's Entry (round 2, batch 5 — R26.2)

    /// The door's words in ONE place. TWO surfaces offer it — the badge on
    /// the daily journal's row, and its fallback row for the states in
    /// which no such row exists — and they must not drift, exactly like
    /// the delete-book pair below.
    ///
    /// The badge is SHORT by design: it rides a row that already carries a
    /// name and a meta column, and phone width is the scarce thing.
    /// *(PROVISIONAL — the abbreviation is a taste call. The SPOKEN form
    /// stays the full name, so nothing an assistive reader hears changed.)*
    static let todayDoorTitle = "✎ today"
    static let todayDoorRowTitle = "✎ today's entry"
    static let todayDoorSpoken = "Today's Entry"

    // MARK: - Delete a book (round 2, batch 4 — PR4)

    /// The door's word, in ONE place: two doors offer it (the shelf row's
    /// long-press and the book-details sheet) and they must not drift.
    static let deleteBookDoorTitle = "Delete Book…"
    static let deleteBookConfirmTitle = "Delete Book"

    /// **13i-e U2 — the daily Journal's doors (the sitting record §10; P-2):**
    /// "the daily Journal can be archived, never deleted; it returns when a
    /// day arrives" — so both doors that offer Delete on a book offer ARCHIVE
    /// on the daily Journal instead (the op refuses its delete). On the phone
    /// the road back is Today's Entry itself (the comes-back); the phone's
    /// archive face for ORDINARY books is the mobile catch-up's (F-U1-4).
    static let archiveDailyJournalDoorTitle = "Archive"
    static let archiveDailyJournalDetail = BookArchiveCopy.dailyJournalCaption

    /// The archive landed — the phone has no Archived surface yet, so the
    /// receipt names the road that IS here.
    static func archivedDailyJournalReceipt(name: String) -> String {
        "Archived \u{201C}\(name)\u{201D} \u{2014} it comes back when a day arrives (Today\u{2019}s Entry)."
    }

    /// Which book door a row or sheet offers (P-2): Archive on the daily
    /// Journal — the marker the op's guard keys on — Delete everywhere else.
    static func offersArchiveInsteadOfDelete(_ reading: Reading) -> Bool {
        Queries.isDailyJournalMintShape(reading)
    }

    /// **The confirm names what goes AND what stays.** The second sentence
    /// is the 13j books lesson she had to teach once already: deleting a
    /// book does not delete its notes — only the ordered collection goes,
    /// and it goes to the Trash for the window like everything else.
    /// ONE NOUN FOR ONE ROAD (the post-13l polish round, ledger row 5): the
    /// last clause used to name **Archived & Deleted** after the sentence had
    /// already said **Trash** — the same two-nouns-for-one-road shape her A5
    /// ruling retired in `RecoveryCopy.moveToTrashDetail`, living on in this
    /// phone-local sibling. Fixed here in the same breath so the two confirms
    /// cannot describe one 30-day clock two ways.
    static func deleteBookConfirmDetail(name: String?) -> String {
        let subject = name.map { "\"\($0)\" goes" } ?? "The book goes"
        return "\(subject) to the \(RecoveryCopy.trashSection) for "
            + "\(TrashWindow.days) days. \(RecoveryCopy.deleteBookKeepsItsNotes) "
            + "You can put it back from there until then."
    }
}
