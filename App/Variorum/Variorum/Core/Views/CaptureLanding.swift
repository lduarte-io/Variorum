//
//  CaptureLanding.swift
//  Variorum (Mac) — Core/Views (the shared home: two features read it — the
//  Bookcase/Library band's File Without Opening and the quick-note pad)
//
//  **WHERE A JUST-FILED CAPTURE LANDED, said once** (the VX-915 run's ladder
//  round 1, F-1). VX-911's band receipt read the note's BOOK rows after the
//  filing and named them ("Filed in …"); the pad's filing in another wing
//  (VX-841) spoke "the Pool of “W”" without reading anything — so a capture a
//  living book in W SEATED (the quicknote tag lands through the one
//  application road) was told it sat in a Pool it had already left. The read
//  and the naming rule move here so both capture doors say a landing the same
//  way, and the rule exists once.
//

import GRDB
import VariorumCore

nonisolated enum CaptureLanding {
    /// **The books that hold the note now** — the duplicate's landing read:
    /// BOOKS only. An arrival is no membership (`readingsContaining` lists
    /// member rows), so a note waiting at a book's Arrivals is still in the
    /// Pool; and a gathering is a view over notes, never a home, so a note it
    /// shows is still bookless (the Pool's definition).
    static func books(_ db: Database, postID: String) throws -> [String] {
        try Queries.readingsContaining(db, postID: postID)
            .filter { $0.kind == .book }
            .map(\.name)
    }

    /// **The landing as a place** — no book holds it: `pool` (the band's "the
    /// Pool", the pad's "the Pool of “W”"); one book: its name, quoted;
    /// several: counted.
    static func place(books: [String], pool: String) -> String {
        switch books.count {
        case 0: return pool
        case 1: return "\u{201C}\(books[0])\u{201D}"
        default: return "\(books.count) books"
        }
    }
}
