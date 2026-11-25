//
//  BookOrderPick.swift
//  VariorumCore
//
//  VX-1040 (the VX-1036 run, batch 1 — the design record's D-1, confirmed as
//  drawn at R-1036-33; her R-1036-2: "i do think that it should maybe
//  automatically save as the book's order … maybe save as this book's order
//  should be a choice when you're changing the manual order") — **WHAT A PICK
//  ON A BOOK'S ORDER DIAL MEANS.**
//
//  - On a GATHERING, and on a book whose stored order is NOT manual, a pick IS
//    the book's order at once — saved through the one road
//    (`Operations.setReadingSort`, the same operation the wire's
//    `set_book_order` calls), so every reader follows it.
//  - On a HAND-ORDERED book a pick stays a LOOK — view-local, nothing written
//    (A31's lens grammar) — with "Save as This Book's Order" and "Back to
//    manual order" both in plain sight; the hand order is kept in the rows
//    either way.
//  - A FINISHED book (sealed included — a seal finishes) looks and cannot
//    save, as before: its order is part of what "done" froze, and the op
//    refuses anyway.
//
//  Pure, over the book's own facts, so both platforms read one rule.
//

import Foundation

public enum BookOrderPick {
    public enum Meaning: Equatable, Sendable {
        /// A way of looking — nothing written.
        case look
        /// The book's order, saved at once.
        case save
    }

    public static func meaning(kind: ReadingKind, storedField: SortField, finished: Bool) -> Meaning {
        if finished { return .look }
        if kind == .gathering { return .save }
        return storedField == .manual ? .look : .save
    }

    public static func meaning(for reading: Reading) -> Meaning {
        meaning(kind: reading.kind, storedField: reading.sortField, finished: reading.locked)
    }
}
