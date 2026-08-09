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
        for book: Queries.ShelfBook, curatedTags: [String: [String]]
    ) -> [String] {
        if book.reading.kind == .smart {
            guard let json = book.reading.querySpec,
                  let spec = try? JSONDecoder().decode(
                      Queries.SmartQuerySpec.self, from: Data(json.utf8))
            else { return [] }
            return (spec.tagsAll ?? []) + (spec.tags ?? [])
        }
        return curatedTags[book.reading.id] ?? []
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
        if book.reading.kind == .smart {
            parts.append("smart")
        } else {
            let unit = book.reading.profile == "journal" ? "entr" : "note"
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

    /// The pin door's word, state-mirroring (parity C2 — the Mac shelf
    /// menu's own words; voice-cased at render). Pure so the door's
    /// vocabulary is pinned, not promised.
    static func pinDoorTitle(pinned: Bool) -> String {
        pinned ? "Unpin from Shelf Top" : "Pin to Shelf Top"
    }

    /// Shelf order — the Mac `ShelfViewModel.ordered` SEMANTICS mirrored
    /// (pinned books first in pin order (R38), then journal-profile books
    /// by name, then the rest by name).
    static func ordered(
        books: [Queries.ShelfBook], pins: [String]
    ) -> [Queries.ShelfBook] {
        var pinned: [Queries.ShelfBook] = []
        for pin in pins {
            if let book = books.first(where: { $0.reading.id == pin }) {
                pinned.append(book)
            }
        }
        let rest = books.filter { !pins.contains($0.reading.id) }
        let journals = rest.filter { $0.reading.profile == "journal" }
            .sorted { $0.reading.name < $1.reading.name }
        let others = rest.filter { $0.reading.profile != "journal" }
            .sorted { $0.reading.name < $1.reading.name }
        return pinned + journals + others
    }
}
